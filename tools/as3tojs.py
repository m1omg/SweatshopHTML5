#!/usr/bin/env python3
"""A purpose-built AS3 -> JavaScript translator for the decompiled Sweatshop
sources (FFDec output). It is not a general AS3 compiler: it relies on the
very regular formatting of decompiler output.

Classes are emitted as ES5 constructor functions named after their fully
qualified name with dots replaced by '_' (e.g. ss_app_App). Flash API classes
are provided by web/js/flash.js using the same naming scheme.

Usage: as3tojs.py <scripts_dir> <out.js> [file-list...]
       (without a file list, all game sources under ss/ and org/fatlib/ are translated)
"""
import os
import re
import sys
import json

KEYWORDS = {
    'if', 'else', 'for', 'while', 'do', 'return', 'break', 'continue', 'switch', 'case', 'default',
    'new', 'delete', 'typeof', 'instanceof', 'in', 'this', 'super', 'null', 'undefined', 'true', 'false',
    'var', 'const', 'function', 'try', 'catch', 'finally', 'throw', 'void', 'each', 'is', 'as',
    'NaN', 'Infinity', 'arguments', 'get', 'set', 'with',
}

GLOBALS = {
    'Math', 'String', 'Number', 'Boolean', 'Array', 'Object', 'Date', 'Error', 'RegExp', 'JSON',
    'parseInt', 'parseFloat', 'isNaN', 'isFinite', 'escape', 'unescape', 'encodeURIComponent',
    'decodeURIComponent', 'encodeURI', 'decodeURI', 'trace', 'int', 'uint', 'Class', 'Function',
    'XML', 'XMLList', 'Vector', 'undefined', 'NaN', 'Infinity', 'isXMLName', 'setTimeout',
    'clearTimeout', 'setInterval', 'clearInterval', 'getTimer', 'navigateToURL', 'describeType',
    'getDefinitionByName', 'getQualifiedClassName', 'ArgumentError', 'RangeError', 'TypeError',
}

# Methods that cannot be translated mechanically (E4X literals/filters, Dictionary
# with object keys...). They are re-implemented by hand in web/js/patches.js.
SKIP_METHODS = {
    'ss.game.components.ui.HUDRenderer.compactHUDXML',
    'ss.story.StoryEngine.trigger',
    'ss.data.Level.summary',
    'org.fatlib.utils.ClassUtils.getSuperClassName',
}

PRIMITIVE_TYPES = {'int', 'uint', 'Number', 'String', 'Boolean', 'Array', 'Object', 'Function',
                   'Class', 'XML', 'XMLList', 'Error'}


# --------------------------------------------------------------------------- lexer

class Tok:
    __slots__ = ('t', 'v', 'nl')

    def __init__(self, t, v, nl=False):
        self.t = t  # 'id', 'num', 'str', 'op', 'regex', 'xml'
        self.v = v
        self.nl = nl  # preceded by newline

    def __repr__(self):
        return '%s:%s' % (self.t, self.v)


OPS = sorted(['>>>=', '===', '!==', '>>>', '<<=', '>>=', '...', '==', '!=', '<=', '>=', '&&', '||',
              '++', '--', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '<<', '>>', '::', '.<', '.@',
              '..', '&&=', '||='], key=len, reverse=True)


def lex(src):
    toks = []
    i = 0
    n = len(src)
    nl = False
    while i < n:
        c = src[i]
        if c == '\n':
            nl = True
            i += 1
            continue
        if c in ' \t\r﻿':
            i += 1
            continue
        if src.startswith('//', i):
            j = src.find('\n', i)
            i = n if j < 0 else j
            continue
        if src.startswith('/*', i):
            j = src.find('*/', i + 2)
            i = n if j < 0 else j + 2
            continue
        if c.isalpha() or c == '_' or c == '$':
            j = i + 1
            while j < n and (src[j].isalnum() or src[j] in '_$'):
                j += 1
            toks.append(Tok('id', src[i:j], nl))
            nl = False
            i = j
            continue
        if c.isdigit() or (c == '.' and i + 1 < n and src[i + 1].isdigit()):
            m = re.compile(r'0[xX][0-9a-fA-F]+|\d*\.?\d+(?:[eE][+-]?\d+)?').match(src, i)
            toks.append(Tok('num', m.group(0), nl))
            nl = False
            i = m.end()
            continue
        if c in '"\'':
            j = i + 1
            while src[j] != c:
                if src[j] == '\\':
                    j += 1
                j += 1
            toks.append(Tok('str', src[i:j + 1], nl))
            nl = False
            i = j + 1
            continue
        if c == '/':
            prev = toks[-1] if toks else None
            if prev is None or (prev.t == 'op' and prev.v not in (')', ']', '}')) or (
                    prev.t == 'id' and prev.v in ('return', 'case', 'typeof', 'in')):
                # regex literal
                j = i + 1
                in_class = False
                while True:
                    ch = src[j]
                    if ch == '\\':
                        j += 2
                        continue
                    if ch == '[':
                        in_class = True
                    elif ch == ']':
                        in_class = False
                    elif ch == '/' and not in_class:
                        break
                    j += 1
                j += 1
                while j < n and src[j].isalpha():
                    j += 1
                toks.append(Tok('regex', src[i:j], nl))
                nl = False
                i = j
                continue
        for op in OPS:
            if src.startswith(op, i):
                toks.append(Tok('op', op, nl))
                nl = False
                i += len(op)
                break
        else:
            toks.append(Tok('op', c, nl))
            nl = False
            i += 1
    return toks


# --------------------------------------------------------------------------- model

class Member:
    def __init__(self, name, kind, static, mods):
        self.name = name
        self.kind = kind  # 'var', 'const', 'method', 'get', 'set'
        self.static = static
        self.mods = mods
        self.type = None
        self.init = None  # token list
        self.params = None  # list of (name, type, default tokens, rest)
        self.body = None  # token list
        self.rettype = None


class ClassDef:
    def __init__(self, name, pkg, is_interface):
        self.name = name
        self.pkg = pkg
        self.fq = (pkg + '.' + name) if pkg else name
        self.js = self.fq.replace('.', '_')
        self.is_interface = is_interface
        self.extends = None
        self.implements = []
        self.members = []
        self.ctor = None
        self.imports = {}  # simple name -> fq
        self.file = None
        self.static_code = []

    def mangled(self):
        return self.js


def parse_type(toks, i):
    """parse type annotation starting at toks[i]; returns (type string, new index)"""
    if toks[i].v == '*':
        return '*', i + 1
    parts = [toks[i].v]
    i += 1
    while i < len(toks) and toks[i].v in ('.', '.<'):
        if toks[i].v == '.<':
            # Vector.<T>
            depth = 1
            i += 1
            inner = []
            while depth:
                if toks[i].v == '.<':
                    depth += 1
                elif toks[i].v == '>':
                    depth -= 1
                elif toks[i].v == '>>':
                    depth -= 2
                if depth > 0:
                    inner.append(toks[i].v)
                i += 1
            parts.append('<' + ''.join(inner) + '>')
            continue
        parts.append('.')
        parts.append(toks[i + 1].v)
        i += 2
    return ''.join(parts), i


def match_brace(toks, i, open_='{', close='}'):
    depth = 0
    j = i
    while j < len(toks):
        if toks[j].t == 'op':
            if toks[j].v == open_:
                depth += 1
            elif toks[j].v == close:
                depth -= 1
                if depth == 0:
                    return j
        j += 1
    raise ValueError('unbalanced')


MODS = {'public', 'private', 'protected', 'internal', 'override', 'final', 'static', 'dynamic', 'native'}


def parse_file(path, rel):
    src = open(path, encoding='utf-8').read()
    toks = lex(src)
    classes = []
    i = 0
    pkg = ''
    imports = {}
    pkg_depth_end = None
    while i < len(toks):
        t = toks[i]
        if t.v == 'package':
            i += 1
            p = []
            while toks[i].v != '{':
                p.append(toks[i].v)
                i += 1
            pkg = ''.join(p)
            pkg_depth_end = match_brace(toks, i)
            i += 1
            continue
        if t.v == 'import':
            i += 1
            p = []
            while toks[i].v != ';':
                p.append(toks[i].v)
                i += 1
            fq = ''.join(p)
            if fq.endswith('.*'):
                imports.setdefault('*', []).append(fq[:-2])
            else:
                imports[fq.split('.')[-1]] = fq
            i += 1
            continue
        if t.v == 'use':  # use namespace
            while toks[i].v != ';':
                i += 1
            i += 1
            continue
        if t.v == '[':  # metadata
            i = match_brace(toks, i, '[', ']') + 1
            continue
        if t.v in MODS:
            i += 1
            continue
        if t.v in ('class', 'interface'):
            cur_pkg = pkg if (pkg_depth_end is not None and i < pkg_depth_end) else ''
            c = ClassDef(toks[i + 1].v, cur_pkg, t.v == 'interface')
            c.file = rel
            c.imports = dict(imports)
            i += 2
            while toks[i].v != '{':
                if toks[i].v == 'extends':
                    if c.is_interface:
                        i += 1
                        while toks[i].v != '{':
                            if toks[i].t == 'id':
                                ty, i = parse_type(toks, i)
                                c.implements.append(ty)
                            else:
                                i += 1
                        break
                    ty, i = parse_type(toks, i + 1)
                    c.extends = ty
                    continue
                if toks[i].v == 'implements':
                    i += 1
                    while toks[i].v != '{':
                        if toks[i].t == 'id':
                            ty, i = parse_type(toks, i)
                            c.implements.append(ty)
                        else:
                            i += 1
                    break
                i += 1
            end = match_brace(toks, i)
            parse_class_body(c, toks[i + 1:end])
            classes.append(c)
            i = end + 1
            continue
        if t.v in ('function', 'var', 'const', 'namespace'):
            # package-level function/var: not expected
            raise ValueError('top level %s in %s' % (t.v, rel))
        i += 1
    return classes


def parse_params(toks):
    params = []
    i = 0
    while i < len(toks):
        rest = False
        if toks[i].v == '...':
            rest = True
            i += 1
        name = toks[i].v
        i += 1
        ty = None
        default = None
        if i < len(toks) and toks[i].v == ':':
            ty, i = parse_type(toks, i + 1)
        if i < len(toks) and toks[i].v == '=':
            j = i + 1
            depth = 0
            while j < len(toks) and not (depth == 0 and toks[j].v == ','):
                if toks[j].v in '([{':
                    depth += 1
                elif toks[j].v in ')]}':
                    depth -= 1
                j += 1
            default = toks[i + 1:j]
            i = j
        params.append((name, ty, default, rest))
        if i < len(toks) and toks[i].v == ',':
            i += 1
    return params


def parse_class_body(c, toks):
    i = 0
    while i < len(toks):
        mods = set()
        while toks[i].v in MODS or (toks[i].t == 'id' and toks[i + 1].t == 'id' and toks[i].v not in (
                'var', 'const', 'function') and toks[i + 1].v in ('var', 'const', 'function', 'static')):
            mods.add(toks[i].v)
            i += 1
        t = toks[i]
        if t.v == '[':
            i = match_brace(toks, i, '[', ']') + 1
            continue
        if t.v in ('var', 'const'):
            i += 1
            while True:
                m = Member(toks[i].v, t.v, 'static' in mods, mods)
                i += 1
                if toks[i].v == ':':
                    m.type, i = parse_type(toks, i + 1)
                if toks[i].v == '=':
                    j = i + 1
                    depth = 0
                    while not (depth == 0 and toks[j].v in (';', ',')):
                        if toks[j].v in ('(', '[', '{'):
                            depth += 1
                        elif toks[j].v in (')', ']', '}'):
                            depth -= 1
                        j += 1
                    m.init = toks[i + 1:j]
                    i = j
                c.members.append(m)
                if toks[i].v == ',':
                    i += 1
                    continue
                break
            if toks[i].v == ';':
                i += 1
            continue
        if t.v == 'function':
            i += 1
            kind = 'method'
            if toks[i].v in ('get', 'set') and toks[i + 1].t == 'id' and toks[i + 1].v != '(':
                kind = toks[i].v
                i += 1
            name = toks[i].v
            i += 1
            pend = match_brace(toks, i, '(', ')')
            params = parse_params(toks[i + 1:pend])
            i = pend + 1
            rettype = None
            if toks[i].v == ':':
                rettype, i = parse_type(toks, i + 1)
            m = Member(name, kind, 'static' in mods, mods)
            m.params = params
            m.rettype = rettype
            if toks[i].v == '{':
                bend = match_brace(toks, i)
                m.body = toks[i + 1:bend]
                i = bend + 1
            else:
                m.body = None  # interface
                if toks[i].v == ';':
                    i += 1
            if name == c.name and kind == 'method':
                c.ctor = m
            else:
                c.members.append(m)
            continue
        if t.v == ';':
            i += 1
            continue
        # static initializer code
        j = i
        depth = 0
        while j < len(toks):
            if toks[j].v == '{':
                depth += 1
            elif toks[j].v == '}':
                depth -= 1
            elif toks[j].v == ';' and depth == 0:
                break
            j += 1
        c.static_code.append(toks[i:j + 1])
        i = j + 1


# --------------------------------------------------------------------------- runtime model

def load_runtime_model(path):
    """runtime_api.json: { 'flash.display.MovieClip': {'extends': ..., 'members': [...], 'static': [...]} }"""
    with open(path) as f:
        return json.load(f)


class World:
    def __init__(self, classes, runtime):
        self.classes = {c.fq: c for c in classes}
        self.runtime = runtime
        self.method_names = set()
        for c in classes:
            for m in c.members:
                if m.kind == 'method' and not m.static:
                    self.method_names.add(m.name)
        for fq, r in runtime.items():
            for n in r.get('methods', []):
                self.method_names.add(n)
        self.by_pkg = {}
        for c in classes:
            self.by_pkg.setdefault(c.pkg, {})[c.name] = c.fq
        for fq in runtime:
            pkg, _, nm = fq.rpartition('.')
            self.by_pkg.setdefault(pkg, {})[nm] = fq

    def chain(self, fq):
        out = []
        cur = fq
        while cur:
            out.append(cur)
            if cur in self.classes:
                cd = self.classes[cur]
                cur = self.resolve_class(cd, cd.extends) if cd.extends else None
            elif cur in self.runtime:
                cur = self.runtime[cur].get('extends')
            else:
                break
        return out

    def compute_renames(self):
        """AS3 private members live in a per-class namespace; in JS they would collide with
        same-named members of ancestors/descendants. Mangle such private names."""
        def names_of(fq):
            if fq in self.classes:
                return {m.name for m in self.classes[fq].members if not m.static}
            r = self.runtime[fq]
            return set(r.get('members', []) + r.get('methods', []))
        descendants = {}
        for c in self.classes.values():
            for anc in self.chain(c.fq)[1:]:
                descendants.setdefault(anc, []).append(c.fq)
        for c in self.classes.values():
            c.renames = {}
        for c in self.classes.values():
            others = set()
            for anc in self.chain(c.fq)[1:]:
                others |= names_of(anc)
            for d in descendants.get(c.fq, []):
                others |= names_of(d)
            for m in c.members:
                if not m.static and 'private' in m.mods and m.name in others:
                    c.renames[m.name] = m.name + '$' + c.name

    def resolve_class(self, c, name):
        """Resolve a simple class name inside class c to fq name, or None."""
        if '.' in name and (name in self.classes or name in self.runtime):
            return name
        if name in c.imports and name != '*':
            return c.imports[name]
        for wp in c.imports.get('*', []):
            if name in self.by_pkg.get(wp, {}):
                return self.by_pkg[wp][name]
        if name in self.by_pkg.get(c.pkg, {}):
            return self.by_pkg[c.pkg][name]
        # same file internal classes
        if name in self.by_pkg.get('', {}):
            return self.by_pkg[''][name]
        return None

    def instance_members(self, fq):
        """dict name -> declaring fq for instance members, walking hierarchy."""
        res = {}
        chain = []
        cur = fq
        while cur:
            chain.append(cur)
            if cur in self.classes:
                cd = self.classes[cur]
                cur = self.resolve_class(cd, cd.extends) if cd.extends else None
                if cd.extends and cur is None:
                    raise ValueError('cannot resolve %s in %s' % (cd.extends, cd.fq))
            elif cur in self.runtime:
                cur = self.runtime[cur].get('extends')
            else:
                raise ValueError('unknown class ' + cur)
        for fq2 in reversed(chain):
            if fq2 in self.classes:
                for m in self.classes[fq2].members:
                    if not m.static:
                        res[m.name] = fq2
            else:
                r = self.runtime[fq2]
                for n in r.get('members', []) + r.get('methods', []):
                    res[n] = fq2
        return res

    def static_members(self, fq):
        res = {}
        cur = fq
        while cur:
            if cur in self.classes:
                cd = self.classes[cur]
                for m in cd.members:
                    if m.static and m.name not in res:
                        res[m.name] = cur
                cur = self.resolve_class(cd, cd.extends) if cd.extends else None
            elif cur in self.runtime:
                for n in self.runtime[cur].get('static', []):
                    if n not in res:
                        res[n] = cur
                cur = self.runtime[cur].get('extends')
            else:
                break
        return res


def jsname(fq):
    return fq.replace('.', '_')


# --------------------------------------------------------------------------- code emitter

class Emitter:
    def __init__(self, world, cls):
        self.w = world
        self.c = cls
        self.inst = world.instance_members(cls.fq)
        self.stat = world.static_members(cls.fq)
        self.super_fq = world.resolve_class(cls, cls.extends) if cls.extends else None
        self.warnings = []
        self.local_types = {}
        self.renames = getattr(cls, 'renames', {})
        self.ret_int = None

    def class_ref(self, name):
        if name in PRIMITIVE_TYPES or name == '*':
            return None
        fq = self.w.resolve_class(self.c, name)
        if fq:
            return jsname(fq)
        return None

    def default_for(self, ty):
        if ty in ('int', 'uint'):
            return '0'
        if ty == 'Number':
            return 'NaN'
        if ty == 'Boolean':
            return 'false'
        if ty == '*':
            return 'undefined'
        return 'null'

    # -- expressions ------------------------------------------------------
    def translate(self, toks, locals_, static_ctx, in_ctor=False):
        """Translate a token list (function body or expression) into JS string."""
        toks = list(toks)
        out = []  # list of strings (tokens)
        # Precompute: collect var declarations
        i = 0
        n = len(toks)
        brace_stack = []  # 'b' block or 'o' object

        def prev_tok(k=1):
            return out[-k] if len(out) >= k else None

        while i < n:
            t = toks[i]
            v = t.v
            # newline handling: keep line structure light
            if t.t == 'id':
                if v in ('var', 'const'):
                    # var declaration: strip types
                    out.append('var')
                    i += 1
                    # parse declarators
                    while True:
                        name = toks[i].v
                        out.append(name)
                        locals_.add(name)
                        i += 1
                        ty = None
                        if i < n and toks[i].v == ':':
                            ty, i = parse_type(toks, i + 1)
                            self.local_types[name] = ty
                        if i < n and toks[i].v == '=':
                            # initializer handled by main loop; mark int coercion
                            out.append('=')
                            i += 1
                            j = i
                            depth = 0
                            while j < n and not (depth == 0 and toks[j].v in (';', ',', 'in', 'of')):
                                if toks[j].v in ('(', '[', '{'):
                                    depth += 1
                                elif toks[j].v in (')', ']', '}'):
                                    depth -= 1
                                    if depth < 0:
                                        break
                                j += 1
                            sub = self.translate(toks[i:j], locals_, static_ctx)
                            if ty == 'String' and ('children()' in sub or '.attr(' in sub or 'getNextLine' in sub or '.name()' in sub):
                                sub = '$str(' + sub + ')'
                            if ty in ('int', 'uint') and ('/' in sub or '*' in sub or 'Math.random' in sub or '.' in sub):
                                sub = 'int(' + sub + ')' if ty == 'int' else 'uint(' + sub + ')'
                            out.append(sub)
                            i = j
                        elif ty is not None and not (i < n and toks[i].v == 'in'):
                            # uninitialized typed local: AS3 default
                            d = self.default_for(ty)
                            out.append('=')
                            out.append(d)
                        if i < n and toks[i].v == ',':
                            out.append(',')
                            i += 1
                            continue
                        break
                    continue
                if v == 'for' and i + 1 < n and toks[i + 1].v == 'each':
                    # for each (X in Y) -> for (X of $each(Y))
                    i += 2
                    assert toks[i].v == '('
                    close = match_brace(toks, i, '(', ')')
                    inner = toks[i + 1:close]
                    # find 'in' at depth 0
                    depth = 0
                    k = 0
                    while k < len(inner):
                        if inner[k].v in '([{':
                            depth += 1
                        elif inner[k].v in ')]}':
                            depth -= 1
                        elif inner[k].v == 'in' and depth == 0:
                            break
                        k += 1
                    lhs = inner[:k]
                    rhs = inner[k + 1:]
                    lhs_js = self.translate_for_lhs(lhs, locals_, static_ctx)
                    rhs_js = self.translate(rhs, locals_, static_ctx)
                    out.append('for (%s of $each(%s))' % (lhs_js, rhs_js))
                    i = close + 1
                    continue
                if v == 'for' and i + 1 < n and toks[i + 1].v == '(':
                    close = match_brace(toks, i + 1, '(', ')')
                    inner = toks[i + 2:close]
                    # detect for-in
                    depth = 0
                    k = 0
                    is_in = False
                    has_semi = any(x.v == ';' for x in inner)
                    if not has_semi:
                        while k < len(inner):
                            if inner[k].v in '([{':
                                depth += 1
                            elif inner[k].v in ')]}':
                                depth -= 1
                            elif inner[k].v == 'in' and depth == 0:
                                is_in = True
                                break
                            k += 1
                    if is_in:
                        lhs_js = self.translate_for_lhs(inner[:k], locals_, static_ctx)
                        rhs_js = self.translate(inner[k + 1:], locals_, static_ctx)
                        out.append('for (%s in $keys(%s))' % (lhs_js, rhs_js))
                        # NB: $keys returns an object safe for for-in (dictionary support)
                        i = close + 1
                        continue
                    out.append('for')
                    i += 1
                    continue
                if v == 'function':
                    # nested function expression or declaration -> arrow
                    j = i + 1
                    fname = None
                    if toks[j].t == 'id':
                        fname = toks[j].v
                        j += 1
                    pend = match_brace(toks, j, '(', ')')
                    params = parse_params(toks[j + 1:pend])
                    j = pend + 1
                    if toks[j].v == ':':
                        _, j = parse_type(toks, j + 1)
                    bend = match_brace(toks, j)
                    inner_locals = set(locals_)
                    ps = self.params_js(params, inner_locals, static_ctx)
                    body = self.translate(toks[j + 1:bend], inner_locals, static_ctx)
                    fn = '((%s) => {\n%s\n})' % (ps, body)
                    if fname:
                        locals_.add(fname)
                        out.append('var %s = %s;' % (fname, fn))
                    else:
                        out.append(fn)
                    i = bend + 1
                    continue
                if v == 'return' and self.ret_int and i + 1 < n and toks[i + 1].v != ';':
                    j = self.expr_end(toks, i + 1)
                    sub = self.translate(toks[i + 1:j], locals_, static_ctx)
                    out.append('return')
                    out.append(self.ret_int + '(' + sub + ')' if not re.match(r'^-?\d+$', sub) else sub)
                    i = j
                    continue
                if v == 'super':
                    nxt = toks[i + 1].v if i + 1 < n else ''
                    sup = jsname(self.super_fq) if self.super_fq else 'Object'
                    if nxt == '(':
                        close = match_brace(toks, i + 1, '(', ')')
                        args = self.translate(toks[i + 2:close], locals_, static_ctx)
                        if self.super_fq:
                            out.append('%s.call(this%s)' % (sup, (', ' + args) if args.strip() else ''))
                        else:
                            out.append('void 0')
                        i = close + 1
                        continue
                    if nxt == '.':
                        mname = toks[i + 2].v
                        if i + 3 < n and toks[i + 3].v == '(':
                            close = match_brace(toks, i + 3, '(', ')')
                            args = self.translate(toks[i + 4:close], locals_, static_ctx)
                            out.append('%s.prototype.%s.call(this%s)' % (sup, mname, (', ' + args) if args.strip() else ''))
                            i = close + 1
                            continue
                        if i + 3 < n and toks[i + 3].v == '=' :
                            self.warnings.append('super setter %s' % mname)
                            out.append('$sset(%s.prototype, this, "%s", ' % (sup, mname))
                            # translate rest of statement
                            j = i + 4
                            depth = 0
                            while j < n and not (depth == 0 and toks[j].v == ';'):
                                if toks[j].v in '([{':
                                    depth += 1
                                elif toks[j].v in ')]}':
                                    depth -= 1
                                j += 1
                            out.append(self.translate(toks[i + 4:j], locals_, static_ctx))
                            out.append(')')
                            i = j
                            continue
                        out.append('$sget(%s.prototype, this, "%s")' % (sup, mname))
                        i += 3
                        continue
                if v in ('is', 'as') and out:
                    # binary operator: wrap left operand
                    ty, j = parse_type(toks, i + 1)
                    tref = self.type_ref(ty)
                    start = self.find_operand_start(out)
                    left = self.join(out[start:])
                    del out[start:]
                    if v == 'is':
                        out.append('$is(%s, %s)' % (left, tref))
                    else:
                        out.append('$as(%s, %s)' % (left, tref))
                    i = j
                    continue
                if v == 'new' and i + 1 < n and toks[i + 1].v == 'Vector':
                    # new Vector.<T>(...)
                    _, j = parse_type(toks, i + 1)
                    out.append('new Array')
                    i = j
                    continue
                if v == 'Vector' and i + 1 < n and toks[i + 1].v == '.<':
                    _, j = parse_type(toks, i)
                    out.append('Array')
                    i = j
                    continue
                # identifier resolution
                prev = toks[i - 1].v if i > 0 else None
                is_member_access = prev in ('.', '.@', '..')
                is_obj_key = (i + 1 < n and toks[i + 1].v == ':' and brace_stack and brace_stack[-1] == 'o'
                              and prev in ('{', ','))
                if is_member_access or is_obj_key or v in KEYWORDS:
                    if v == 'this' and static_ctx:
                        out.append('this')
                    elif is_member_access and prev == '.' and i >= 2 and toks[i - 2].v == 'this' and v in self.renames:
                        out.append(self.renames[v])
                        v = self.renames[v]
                    else:
                        out.append(v)
                    if is_member_access and prev == '.' and i >= 2 and toks[i - 2].v == 'this' and not static_ctx:
                        ty = self.field_type(toks[i].v)
                        if ty in ('int', 'uint'):
                            i = self.coerce_assign(toks, i, out, locals_, static_ctx, ty)
                            continue
                    # method closure bound when accessed via '.'
                    if is_member_access and toks[i].v in self.w.method_names and not self.is_call_or_assign(toks, i):
                        start = self.find_operand_start(out[:-2])
                        obj = self.join(out[start:-2])
                        if obj:
                            del out[start:]
                            out.append('$b(%s, "%s")' % (obj, v))
                    i += 1
                    continue
                if v in locals_:
                    if self.local_types.get(v) in ('int', 'uint') and prev not in ('.',):
                        out.append(v)
                        i = self.coerce_assign(toks, i, out, locals_, static_ctx, self.local_types[v])
                        continue
                    out.append(v)
                    i += 1
                    if self.local_types.get(v) == 'String' and i < n and toks[i].v == '=' and prev not in ('.',):
                        j = i + 1
                        depth = 0
                        while j < n and not (depth == 0 and toks[j].v in (';', ',', ')')):
                            if toks[j].v in ('(', '[', '{'):
                                depth += 1
                            elif toks[j].v in (')', ']', '}'):
                                depth -= 1
                            j += 1
                        sub = self.translate(toks[i + 1:j], locals_, static_ctx)
                        if 'children()' in sub or '.attr(' in sub or 'getNextLine' in sub or '.name()' in sub:
                            out.append('=')
                            out.append('$str(' + sub + ')')
                            i = j
                    continue
                if prev == '(' and i >= 2 and toks[i - 2].v == 'catch':
                    locals_.add(v)
                    out.append(v)
                    i += 1
                    if toks[i].v == ':':
                        _, i = parse_type(toks, i + 1)
                    continue
                # fully qualified class reference a.b.C
                if i + 2 < n and toks[i + 1].v == '.':
                    k = i
                    parts = [v]
                    found = None
                    while k + 2 < n and toks[k + 1].v == '.' and toks[k + 2].t == 'id':
                        parts.append(toks[k + 2].v)
                        k += 2
                        cand = '.'.join(parts)
                        if cand in self.w.classes or cand in self.w.runtime:
                            found = (cand, k)
                    if found:
                        out.append(jsname(found[0]))
                        i = found[1] + 1
                        continue
                if not static_ctx and v in self.inst:
                    jsn = self.renames.get(v, v)
                    if v in self.w.method_names and not self.is_call_or_assign(toks, i) and self.is_method(self.inst[v], v):
                        out.append('$b(this, "%s")' % jsn)
                    else:
                        out.append('this.' + jsn)
                    ty = self.field_type(v)
                    if ty in ('int', 'uint'):
                        i = self.coerce_assign(toks, i, out, locals_, static_ctx, ty)
                        continue
                    i += 1
                    continue
                if v in self.stat:
                    out.append(jsname(self.stat[v]) + '.' + v)
                    i += 1
                    continue
                cref = self.class_ref(v)
                if cref:
                    fq = self.w.resolve_class(self.c, v)
                    is_class = fq in self.w.classes or fq in self.w.runtime
                    if is_class and i + 1 < n and toks[i + 1].v == '(' and prev != 'new':
                        # AS3 cast call Type(expr) -> (expr)
                        out.append('$cast')
                        i += 1
                        continue
                    out.append(cref)
                    i += 1
                    continue
                if v in GLOBALS or v in PRIMITIVE_TYPES:
                    out.append(v)
                    i += 1
                    continue
                self.warnings.append('unresolved identifier %s' % v)
                out.append(v)
                i += 1
                continue
            if t.t == 'op':
                if v == '{':
                    p = toks[i - 1] if i > 0 else None
                    if p is not None and (p.v in ('(', '=', ',', ':', '[', '?', 'return', '||', '&&', '!') and not
                                          (p.v == ':' and False)):
                        brace_stack.append('o')
                    else:
                        brace_stack.append('b')
                    out.append('{')
                    i += 1
                    continue
                if v == '}':
                    if brace_stack:
                        brace_stack.pop()
                    out.append('}')
                    i += 1
                    continue
                if v == '.@':
                    out.append('.attr("%s")' % toks[i + 1].v)
                    self.warnings.append('E4X attribute access')
                    i += 2
                    continue
                if v == '..':
                    self.warnings.append('E4X descendant access')
                out.append(v)
                i += 1
                continue
            if t.t == 'num':
                out.append(v)
                i += 1
                continue
            out.append(v)
            i += 1
        return self.join(out)

    def field_type(self, name):
        decl = self.inst.get(name)
        if decl in self.w.classes:
            for m in self.w.classes[decl].members:
                if m.name == name and not m.static and m.kind in ('var', 'const'):
                    return m.type
        return None

    def expr_end(self, toks, j):
        n = len(toks)
        depth = 0
        while j < n:
            v = toks[j].v
            if v in ('(', '[', '{'):
                depth += 1
            elif v in (')', ']', '}'):
                depth -= 1
                if depth < 0:
                    break
            elif depth == 0 and v in (';', ','):
                break
            j += 1
        return j

    def coerce_assign(self, toks, i, out, locals_, static_ctx, ty):
        """out already ends with the assignment target (toks[i]). If an assignment follows,
        translate it with AS3 int/uint coercion. Returns the next token index."""
        n = len(toks)
        if i + 1 >= n:
            return i + 1
        op = toks[i + 1].v
        if op not in ('=', '+=', '-=', '*=', '/=', '%='):
            return i + 1
        j = self.expr_end(toks, i + 2)
        sub = self.translate(toks[i + 2:j], locals_, static_ctx)
        fn = 'int' if ty == 'int' else 'uint'
        if op == '=':
            if re.match(r'^-?\d+$', sub) or sub.startswith(fn + '('):
                out.append('=')
                out.append(sub)
            else:
                out.append('=')
                out.append('%s(%s)' % (fn, sub))
        else:
            start = self.find_operand_start(out)
            target = self.join(out[start:])
            out.append('=')
            out.append('%s(%s %s (%s))' % (fn, target, op[0], sub))
        return j

    def is_method(self, decl_fq, name):
        if decl_fq in self.w.classes:
            for m in self.w.classes[decl_fq].members:
                if m.name == name:
                    return m.kind == 'method'
            return False
        return name in self.w.runtime[decl_fq].get('methods', [])

    def is_call_or_assign(self, toks, i):
        if i + 1 >= len(toks):
            return False
        nv = toks[i + 1].v
        if nv == '(':
            return True
        if nv in ('=', '+=', '-=', '*=', '/=', '||=', '&&=', '++', '--'):
            return True
        if i > 0 and toks[i - 1].v in ('++', '--', 'delete'):
            return True
        # `delete obj.x` / typeof x
        return False

    def find_operand_start(self, out):
        """Walk back over output tokens to find the start of the postfix expression."""
        k = len(out) - 1
        if k < 0:
            return 0
        while k >= 0:
            tok = out[k]
            if tok in (')', ']'):
                # match
                close = tok
                open_ = '(' if tok == ')' else '['
                depth = 0
                while k >= 0:
                    if out[k] == close:
                        depth += 1
                    elif out[k] == open_:
                        depth -= 1
                        if depth == 0:
                            break
                    k -= 1
                k -= 1
                # function call name before '('
                continue
            if tok == '.' or tok.startswith('.'):
                k -= 1
                continue
            if re.match(r'^[A-Za-z_$][\w$]*$', tok) or re.match(r'^[\w$.]+$', tok) or tok.startswith('$b(') or tok.startswith('$is(') or tok.startswith('$as(') or tok.startswith('"') or tok.startswith("'"):
                # identifier; check whether previous token is '.' continuing chain or 'new'
                if k - 1 >= 0 and (out[k - 1] == '.' or out[k - 1].startswith('.')):
                    k -= 1
                    continue
                if k - 1 >= 0 and out[k - 1] == 'new':
                    return k - 1
                return k
            return k + 1
        return 0

    def translate_for_lhs(self, lhs, locals_, static_ctx):
        if lhs and lhs[0].v in ('var', 'const'):
            name = lhs[1].v
            locals_.add(name)
            return 'var ' + name
        return self.translate(lhs, locals_, static_ctx)

    def type_ref(self, ty):
        if ty in ('int', 'uint', 'Number', 'String', 'Boolean', 'Array', 'Object', 'Function', 'Class', 'XML'):
            return '$T.' + ty
        if ty.startswith('Vector'):
            return '$T.Array'
        if ty == 'Error':
            return 'Error'
        r = self.class_ref(ty)
        if r is None:
            self.warnings.append('unknown type %s' % ty)
            return ty
        return r

    def param_coercions(self, params):
        out = ''
        for name, ty, default, rest in params:
            if ty in ('int', 'uint') and not rest:
                out += '%s = %s(%s);\n' % (name, ty, name)
        return out

    def params_js(self, params, locals_, static_ctx):
        res = []
        for name, ty, default, rest in params:
            locals_.add(name)
            if ty:
                self.local_types[name] = ty
            if rest:
                res.append('...' + name)
            elif default is not None:
                res.append(name + ' = ' + self.translate(default, locals_, static_ctx))
            else:
                res.append(name)
        return ', '.join(res)

    def join(self, out):
        s = []
        prev = ''
        for tok in out:
            if not tok:
                continue
            if s:
                a = prev[-1:]
                b = tok[:1]
                if (a.isalnum() or a in '_$') and (b.isalnum() or b in '_$'):
                    s.append(' ')
                elif tok in ('{',) or prev in (';', '{', '}'):
                    s.append(' ' if tok != '}' else '\n')
                    if prev in (';', '{', '}'):
                        s[-1] = '\n'
                elif tok in ('=', '==', '===', '!=', '!==', '&&', '||', '?', ':', '+=', '-=', '<', '>', '<=', '>=', '+', '-', '*', '/', '%', '|', '&', '*=', '/=') or prev in ('=', '==', '===', '!=', '!==', '&&', '||', '?', ':', ',', '+=', '-=', '<', '>', '<=', '>=', '*=', '/='):
                    s.append(' ')
            s.append(tok)
            prev = tok
        return ''.join(s)

    # -- class -----------------------------------------------------------
    def emit(self):
        c = self.c
        js = c.js
        lines = []
        if c.is_interface:
            lines.append('function %s() {}' % js)
            lines.append('$interface(%s, "%s", [%s]);' % (js, c.fq, ', '.join(self.type_ref(x) for x in c.implements)))
            return '\n'.join(lines), ''
        # constructor
        locals_ = set()
        ctor_params = ''
        body = ''
        if c.ctor:
            self.local_types = {}
            ctor_params = self.params_js(c.ctor.params, locals_, False)
            body = self.param_coercions(c.ctor.params) + self.translate(c.ctor.body, locals_, False, in_ctor=True)
        field_inits = []
        for m in c.members:
            if m.static or m.kind not in ('var', 'const'):
                continue
            fname = self.renames.get(m.name, m.name)
            if m.init is not None:
                field_inits.append('this.%s = %s;' % (fname, self.translate(m.init, set(), False)))
            else:
                field_inits.append('this.%s = %s;' % (fname, self.default_for(m.type)))
        cb = c.ctor.body if c.ctor else []
        has_super_call = any(cb[k].v == 'super' and k + 1 < len(cb) and cb[k + 1].v == '(' for k in range(len(cb)))
        sup = jsname(self.super_fq) if self.super_fq else None
        ctor_lines = ['function %s(%s) {' % (js, ctor_params)]
        ctor_lines += ['  ' + x for x in field_inits]
        if sup and not has_super_call:
            ctor_lines.append('  %s.call(this);' % sup)
        ctor_lines.append(body)
        ctor_lines.append('}')
        head = '\n'.join(ctor_lines)
        # prototype
        proto = []
        ifaces = ', '.join(self.type_ref(x) for x in c.implements)
        proto.append('$class(%s, %s, "%s", [%s]);' % (js, sup or 'null', c.fq, ifaces))
        accessors = {}
        for m in c.members:
            if m.kind in ('method', 'get', 'set'):
                self.local_types = {}
                l2 = set()
                ps = self.params_js(m.params, l2, m.static)
                self.ret_int = m.rettype if m.rettype in ('int', 'uint') else None
                if c.fq + '.' + m.name in SKIP_METHODS:
                    b = 'throw new Error("not translated: see patches.js");'
                else:
                    b = self.param_coercions(m.params) + self.translate(m.body or [], l2, m.static)
                self.ret_int = None
                fn = 'function (%s) {\n%s\n}' % (ps, b)
                target = js if m.static else js + '.prototype'
                mname = m.name if m.static else self.renames.get(m.name, m.name)
                if m.kind == 'method':
                    proto.append('%s.%s = %s;' % (target, mname, fn))
                else:
                    accessors.setdefault((target, mname), {})[m.kind] = fn
        for (target, name), d in accessors.items():
            parts = []
            for k in ('get', 'set'):
                if k in d:
                    parts.append('%s: %s' % (k, d[k]))
            proto.append('$accessor(%s, "%s", {%s});' % (target, name, ', '.join(parts)))
        # statics (lazy)
        statics = []
        for m in c.members:
            if m.static and m.kind in ('var', 'const'):
                if m.init is not None:
                    expr = self.translate(m.init, set(), True)
                    statics.append('$static(%s, "%s", function () { return %s; });' % (js, m.name, expr))
                else:
                    statics.append('%s.%s = %s;' % (js, m.name, self.default_for(m.type)))
        for code in c.static_code:
            statics.append(self.translate(code, set(), True))
        return head + '\n' + '\n'.join(proto), '\n'.join(statics)


def topo_sort(world, classes):
    order = []
    seen = set()

    def visit(c):
        if c.fq in seen:
            return
        seen.add(c.fq)
        if c.extends:
            p = world.resolve_class(c, c.extends)
            if p in world.classes:
                visit(world.classes[p])
        for i in c.implements:
            p = world.resolve_class(c, i)
            if p in world.classes:
                visit(world.classes[p])
        order.append(c)

    for c in classes:
        visit(c)
    return order


# Sources that are not translated: embedded-asset classes, analytics / Facebook / Twitter
# integrations, the debug console and the preloader. web/js/patches.js provides replacements.
EXCLUDE = re.compile(r'^ss/(remote/(Social|Tracking|GoogleAnalytics|Omniture)\.as|resources/ResourceIndex.*|'
                     r'.*_HUDXML\.as|.*__d\.as|.*GlobalUI_UI_JSON\.as|.*SplashScreen_Splash\.as|app/Preloader.*|'
                     r'utils/Console\.as|utils/ContextMenuUtils\.as)$')


def collect_sources(root):
    files = []
    for top in ('ss', os.path.join('org', 'fatlib')):
        for dirpath, _, names in os.walk(os.path.join(root, top)):
            for nm in names:
                if nm.endswith('.as'):
                    rel = os.path.relpath(os.path.join(dirpath, nm), root).replace(os.sep, '/')
                    if not EXCLUDE.match(rel):
                        files.append(rel)
    return sorted(files)


def main():
    root = sys.argv[1]
    out = sys.argv[2]
    runtime = load_runtime_model(os.path.join(os.path.dirname(__file__), 'runtime_api.json'))
    files = sys.argv[3:] or collect_sources(root)
    classes = []
    for rel in files:
        classes += parse_file(os.path.join(root, rel), rel)
    world = World(classes, runtime)
    world.compute_renames()
    for c in classes:
        for k, v in c.renames.items():
            sys.stderr.write('%s: private %s renamed to %s\n' % (c.fq, k, v))
    order = topo_sort(world, classes)
    parts = ['// Generated by tools/as3tojs.py from the decompiled Sweatshop sources.\n']
    statics = []
    warns = 0
    for c in order:
        e = Emitter(world, c)
        try:
            code, st = e.emit()
        except Exception as ex:
            sys.stderr.write('FAILED %s: %r\n' % (c.fq, ex))
            raise
        parts.append('// ---- %s (%s)\n%s\n' % (c.fq, c.file, code))
        if st:
            statics.append(st)
        for w in sorted(set(e.warnings)):
            sys.stderr.write('%s: %s\n' % (c.fq, w))
            warns += 1
    parts.append('// ---- static initializers\n' + '\n'.join(statics) + '\n')
    with open(out, 'w') as f:
        f.write('\n'.join(parts))
    sys.stderr.write('%d classes, %d warnings\n' % (len(order), warns))


if __name__ == '__main__':
    main()
