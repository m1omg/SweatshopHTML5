#!/usr/bin/env python3
"""Convert a (vector) SWF asset library into a JSON description usable by the
HTML5 canvas runtime in web/js/display.js.

Shapes become SVG path strings (consumed by Path2D), sprites become frame
lists of display-list operations, fonts become glyph outlines.
Bitmaps and sounds are exported separately (see build_assets.py).

Usage: swf2json.py input.swf output.json
"""
import json
import struct
import sys
import zlib


class Bits:
    def __init__(self, data, pos=0):
        self.d = data
        self.pos = pos  # byte position
        self.bit = 0  # bit buffer
        self.nbits = 0

    def align(self):
        self.nbits = 0

    def ub(self, n):
        v = 0
        for _ in range(n):
            if self.nbits == 0:
                self.bit = self.d[self.pos]
                self.pos += 1
                self.nbits = 8
            self.nbits -= 1
            v = (v << 1) | ((self.bit >> self.nbits) & 1)
        return v

    def sb(self, n):
        if n == 0:
            return 0
        v = self.ub(n)
        if v & (1 << (n - 1)):
            v -= 1 << n
        return v

    def fb(self, n):
        return self.sb(n) / 65536.0

    def u8(self):
        self.align()
        v = self.d[self.pos]
        self.pos += 1
        return v

    def u16(self):
        self.align()
        v = struct.unpack_from('<H', self.d, self.pos)[0]
        self.pos += 2
        return v

    def s16(self):
        self.align()
        v = struct.unpack_from('<h', self.d, self.pos)[0]
        self.pos += 2
        return v

    def u32(self):
        self.align()
        v = struct.unpack_from('<I', self.d, self.pos)[0]
        self.pos += 4
        return v

    def fixed8(self):
        self.align()
        v = struct.unpack_from('<h', self.d, self.pos)[0]
        self.pos += 2
        return v / 256.0

    def string(self):
        self.align()
        end = self.d.index(0, self.pos)
        s = self.d[self.pos:end].decode('utf-8', 'replace')
        self.pos = end + 1
        return s

    def bytes(self, n):
        self.align()
        v = self.d[self.pos:self.pos + n]
        self.pos += n
        return v

    def rect(self):
        self.align()
        n = self.ub(5)
        r = [self.sb(n), self.sb(n), self.sb(n), self.sb(n)]
        self.align()
        # xmin, xmax, ymin, ymax -> x0, y0, x1, y1 in pixels
        return [r[0] / 20, r[2] / 20, r[1] / 20, r[3] / 20]

    def matrix(self):
        self.align()
        a, d, b, c = 1.0, 1.0, 0.0, 0.0
        if self.ub(1):
            n = self.ub(5)
            a = self.fb(n)
            d = self.fb(n)
        if self.ub(1):
            n = self.ub(5)
            b = self.fb(n)
            c = self.fb(n)
        n = self.ub(5)
        tx = self.sb(n)
        ty = self.sb(n)
        self.align()
        return [a, b, c, d, tx, ty]  # translation in twips

    def rgb(self):
        r, g, b = self.u8(), self.u8(), self.u8()
        return [r, g, b, 255]

    def rgba(self):
        return [self.u8(), self.u8(), self.u8(), self.u8()]

    def cxform(self, alpha):
        self.align()
        has_add = self.ub(1)
        has_mult = self.ub(1)
        n = self.ub(4)
        m = [1.0, 1.0, 1.0, 1.0]
        a = [0, 0, 0, 0]
        cnt = 4 if alpha else 3
        if has_mult:
            for i in range(cnt):
                m[i] = self.sb(n) / 256.0
        if has_add:
            for i in range(cnt):
                a[i] = self.sb(n)
        self.align()
        return m + a


def px_matrix(m):
    return [r6(m[0]), r6(m[1]), r6(m[2]), r6(m[3]), r2(m[4] / 20), r2(m[5] / 20)]


def r2(v):
    v = round(v, 2)
    return int(v) if v == int(v) else v


def r6(v):
    v = round(v, 5)
    return int(v) if v == int(v) else v


# ---------------------------------------------------------------- shapes

def read_fill(b, shape_ver):
    t = b.u8()
    if t == 0x00:
        return {'c': b.rgba() if shape_ver >= 3 else b.rgb()}
    if t in (0x10, 0x12, 0x13):
        m = b.matrix()
        b.align()
        spread = b.ub(2)
        interp = b.ub(2)
        n = b.ub(4)
        stops = []
        for _ in range(n):
            ratio = b.u8()
            c = b.rgba() if shape_ver >= 3 else b.rgb()
            stops.append([ratio] + c)
        res = {'g': {0x10: 'l', 0x12: 'r', 0x13: 'f'}[t],
               'm': [r6(m[0]), r6(m[1]), r6(m[2]), r6(m[3]), r2(m[4] / 20), r2(m[5] / 20)],
               's': stops}
        if spread:
            res['sp'] = spread
        if t == 0x13:
            res['fp'] = b.fixed8()
        return res
    if t in (0x40, 0x41, 0x42, 0x43):
        bid = b.u16()
        m = b.matrix()
        # bitmap px -> shape px
        mm = [r6(m[0] / 20), r6(m[1] / 20), r6(m[2] / 20), r6(m[3] / 20), r2(m[4] / 20), r2(m[5] / 20)]
        return {'b': bid, 'm': mm, 'rep': t in (0x40, 0x42), 'sm': t in (0x40, 0x41)}
    raise ValueError('unknown fill type %x' % t)


def read_fills(b, ver):
    n = b.u8()
    if n == 0xff and ver >= 2:
        n = b.u16()
    return [read_fill(b, ver) for _ in range(n)]


def read_lines(b, ver):
    n = b.u8()
    if n == 0xff and ver >= 2:
        n = b.u16()
    res = []
    for _ in range(n):
        w = b.u16() / 20
        if ver == 4:
            b.align()
            start_cap = b.ub(2)
            join = b.ub(2)
            has_fill = b.ub(1)
            no_h = b.ub(1)
            no_v = b.ub(1)
            b.ub(1)  # pixel hinting
            b.ub(5)
            b.ub(1)  # noClose
            end_cap = b.ub(2)
            st = {'w': w}
            if join == 2:
                st['ml'] = b.fixed8()
            if has_fill:
                f = read_fill(b, 4)
                st['f'] = f
                st['c'] = f.get('c', [0, 0, 0, 255])
            else:
                st['c'] = b.rgba()
            if start_cap:
                st['cap'] = start_cap
            if join:
                st['j'] = join
            if no_h or no_v:
                st['ns'] = 1
            res.append(st)
        else:
            res.append({'w': w, 'c': b.rgba() if ver >= 3 else b.rgb()})
    return res


def read_shape_records(b, ver, fill_bits, line_bits, fills, lines, with_styles=True):
    """Returns list of layers: each layer = (fills, lines, edges)
    edge = (fill0, fill1, line, x0, y0, [cx, cy,] x1, y1) in twips."""
    layers = []
    cur_edges = []
    layers.append((fills, lines, cur_edges))
    x = y = 0
    f0 = f1 = ln = 0
    while True:
        if b.ub(1) == 0:
            new_styles = b.ub(1)
            line_flag = b.ub(1)
            fill1_flag = b.ub(1)
            fill0_flag = b.ub(1)
            move = b.ub(1)
            if not (new_styles or line_flag or fill1_flag or fill0_flag or move):
                break
            if move:
                n = b.ub(5)
                x = b.sb(n)
                y = b.sb(n)
                cur_edges.append(('M', x, y))
            if fill0_flag:
                f0 = b.ub(fill_bits)
            if fill1_flag:
                f1 = b.ub(fill_bits)
            if line_flag:
                ln = b.ub(line_bits)
            if new_styles:
                nf = read_fills(b, ver)
                nl = read_lines(b, ver)
                b.align()
                fill_bits = b.ub(4)
                line_bits = b.ub(4)
                cur_edges = []
                layers.append((nf, nl, cur_edges))
                f0 = f1 = ln = 0
                cur_edges.append(('M', x, y))
        else:
            if b.ub(1):  # straight
                n = b.ub(4) + 2
                if b.ub(1):
                    dx = b.sb(n)
                    dy = b.sb(n)
                else:
                    if b.ub(1):
                        dx = 0
                        dy = b.sb(n)
                    else:
                        dx = b.sb(n)
                        dy = 0
                cur_edges.append(('L', f0, f1, ln, x, y, x + dx, y + dy))
                x += dx
                y += dy
            else:
                n = b.ub(4) + 2
                cdx = b.sb(n)
                cdy = b.sb(n)
                adx = b.sb(n)
                ady = b.sb(n)
                cx, cy = x + cdx, y + cdy
                ax, ay = cx + adx, cy + ady
                cur_edges.append(('Q', f0, f1, ln, x, y, cx, cy, ax, ay))
                x, y = ax, ay
    return layers


def fmt(v):
    v = v / 20.0
    s = ('%.2f' % v).rstrip('0').rstrip('.')
    return s if s != '-0' else '0'


def build_fill_path(edges):
    """edges: list of (kind, x0,y0,[cx,cy],x1,y1) all directed. Join into contours."""
    if not edges:
        return ''
    # index by start point
    from collections import defaultdict
    by_start = defaultdict(list)
    for i, e in enumerate(edges):
        by_start[(e[1], e[2])].append(i)
    used = [False] * len(edges)
    out = []
    for i in range(len(edges)):
        if used[i]:
            continue
        e = edges[i]
        start = (e[1], e[2])
        out.append('M' + fmt(e[1]) + ' ' + fmt(e[2]))
        cur = i
        while True:
            used[cur] = True
            e = edges[cur]
            if e[0] == 'L':
                out.append('L' + fmt(e[3]) + ' ' + fmt(e[4]))
                end = (e[3], e[4])
            else:
                out.append('Q' + fmt(e[3]) + ' ' + fmt(e[4]) + ' ' + fmt(e[5]) + ' ' + fmt(e[6]))
                end = (e[5], e[6])
            if end == start:
                break
            nxt = None
            for j in by_start.get(end, ()):
                if not used[j]:
                    nxt = j
                    break
            if nxt is None:
                break
            cur = nxt
        out.append('Z')
    return ''.join(out)


def build_line_path(edges):
    out = []
    last = None
    for e in edges:
        if (e[1], e[2]) != last:
            out.append('M' + fmt(e[1]) + ' ' + fmt(e[2]))
        if e[0] == 'L':
            out.append('L' + fmt(e[3]) + ' ' + fmt(e[4]))
            last = (e[3], e[4])
        else:
            out.append('Q' + fmt(e[3]) + ' ' + fmt(e[4]) + ' ' + fmt(e[5]) + ' ' + fmt(e[6]))
            last = (e[5], e[6])
    return ''.join(out)


def layers_to_draw(layers):
    """Convert parsed layers into an ordered draw list."""
    draw = []
    for fills, lines, edges in layers:
        per_fill = {}
        per_line = {}
        for e in edges:
            if e[0] == 'M':
                continue
            f0, f1, ln = e[1], e[2], e[3]
            if e[0] == 'L':
                fwd = ('L', e[4], e[5], e[6], e[7])
                rev = ('L', e[6], e[7], e[4], e[5])
            else:
                fwd = ('Q', e[4], e[5], e[6], e[7], e[8], e[9])
                rev = ('Q', e[8], e[9], e[6], e[7], e[4], e[5])
            if f1:
                per_fill.setdefault(f1, []).append(fwd)
            if f0:
                per_fill.setdefault(f0, []).append(rev)
            if ln:
                per_line.setdefault(ln, []).append(fwd)
        for fi in sorted(per_fill):
            if fi - 1 < len(fills):
                draw.append({'f': fills[fi - 1], 'p': build_fill_path(per_fill[fi])})
        for li in sorted(per_line):
            if li - 1 < len(lines):
                draw.append({'l': lines[li - 1], 'p': build_line_path(per_line[li])})
    return draw


def parse_shape(b, ver):
    cid = b.u16()
    bounds = b.rect()
    if ver == 4:
        b.rect()
        b.u8()
    fills = read_fills(b, ver)
    lines = read_lines(b, ver)
    b.align()
    fb_ = b.ub(4)
    lb_ = b.ub(4)
    layers = read_shape_records(b, ver, fb_, lb_, fills, lines)
    return cid, {'t': 'shape', 'r': [r2(v) for v in bounds], 'd': layers_to_draw(layers)}


def parse_glyph(b):
    b.align()
    fb_ = b.ub(4)
    lb_ = b.ub(4)
    layers = read_shape_records(b, 1, fb_, lb_, [{'c': [0, 0, 0, 255]}], [])
    # all glyph edges use fill style 1 on one side
    d = layers_to_draw(layers)
    return ''.join(x['p'] for x in d if 'f' in x)


# ---------------------------------------------------------------- morph shapes

def read_morph_fill(b):
    t = b.u8()
    if t == 0:
        return {'c': b.rgba()}, {'c': b.rgba()}
    if t in (0x10, 0x12, 0x13):
        m1 = b.matrix()
        m2 = b.matrix()
        n = b.u8() & 0x0f
        s1, s2 = [], []
        for _ in range(n):
            s1.append([b.u8()] + b.rgba())
            s2.append([b.u8()] + b.rgba())
        g = {0x10: 'l', 0x12: 'r', 0x13: 'f'}[t]
        a = {'g': g, 'm': px_matrix_g(m1), 's': s1}
        z = {'g': g, 'm': px_matrix_g(m2), 's': s2}
        if t == 0x13:
            a['fp'] = b.fixed8()
            z['fp'] = b.fixed8()
        return a, z
    if t in (0x40, 0x41, 0x42, 0x43):
        bid = b.u16()
        m1 = b.matrix()
        m2 = b.matrix()
        f = lambda m: [r6(m[0] / 20), r6(m[1] / 20), r6(m[2] / 20), r6(m[3] / 20), r2(m[4] / 20), r2(m[5] / 20)]
        return ({'b': bid, 'm': f(m1), 'rep': t in (0x40, 0x42), 'sm': t in (0x40, 0x41)},
                {'b': bid, 'm': f(m2), 'rep': t in (0x40, 0x42), 'sm': t in (0x40, 0x41)})
    raise ValueError('morph fill %x' % t)


def px_matrix_g(m):
    return [r6(m[0]), r6(m[1]), r6(m[2]), r6(m[3]), r2(m[4] / 20), r2(m[5] / 20)]


def parse_morph(b, ver, tag_end):
    cid = b.u16()
    r1 = b.rect()
    r2_ = b.rect()
    if ver == 2:
        b.rect()
        b.rect()
        b.u8()
    offset = b.u32()
    end_edges_pos = b.pos + offset
    n = b.u8()
    if n == 0xff:
        n = b.u16()
    fills = [read_morph_fill(b) for _ in range(n)]
    n = b.u8()
    if n == 0xff:
        n = b.u16()
    lines = []
    for _ in range(n):
        w1 = b.u16() / 20
        w2 = b.u16() / 20
        if ver == 2:
            b.align()
            b.ub(2)
            join = b.ub(2)
            has_fill = b.ub(1)
            b.ub(3)
            b.ub(5)
            b.ub(1)
            b.ub(2)
            if join == 2:
                b.u16()
            if has_fill:
                fa, fz = read_morph_fill(b)
                ca, cz = fa.get('c', [0, 0, 0, 255]), fz.get('c', [0, 0, 0, 255])
            else:
                ca, cz = b.rgba(), b.rgba()
        else:
            ca, cz = b.rgba(), b.rgba()
        lines.append(({'w': w1, 'c': ca}, {'w': w2, 'c': cz}))
    b.align()
    fbits = b.ub(4)
    lbits = b.ub(4)
    start_layers = read_shape_records(b, 3, fbits, lbits, [f[0] for f in fills], [l[0] for l in lines])
    b.pos = end_edges_pos
    b.align()
    fbits = b.ub(4)
    lbits = b.ub(4)
    end_layers = read_shape_records(b, 3, fbits, lbits, [], [])
    # Pair edges: end shape only has edges; style changes come from start.
    s_edges = start_layers[0][2]
    e_edges = [e for e in end_layers[0][2] if e[0] != 'M']
    # Build list of (start_edge, end_edge) pairs, converting lines to quads where needed
    pairs = []
    ei = 0
    for e in s_edges:
        if e[0] == 'M':
            continue
        if ei >= len(e_edges):
            break
        ee = e_edges[ei]
        ei += 1
        pairs.append((e, ee))

    def to_q(e):
        if e[0] == 'Q':
            return e[4:10]
        x0, y0, x1, y1 = e[4], e[5], e[6], e[7]
        return (x0, y0, (x0 + x1) / 2, (y0 + y1) / 2, x1, y1)

    # Output: per style edges with both start & end coords (as quads)
    per_fill = {}
    per_line = {}
    for s, e in pairs:
        qs = to_q(s)
        qe = to_q(e)
        f0, f1, ln = s[1], s[2], s[3]
        fwd = (qs, qe)
        rev = ((qs[4], qs[5], qs[2], qs[3], qs[0], qs[1]), (qe[4], qe[5], qe[2], qe[3], qe[0], qe[1]))
        if f1:
            per_fill.setdefault(f1, []).append(fwd)
        if f0:
            per_fill.setdefault(f0, []).append(rev)
        if ln:
            per_line.setdefault(ln, []).append(fwd)

    def contour_order(edges):
        # chain by start coords (start shape), emit flat number lists with -1 markers for moveTo
        from collections import defaultdict
        bs = defaultdict(list)
        for i, (qs, qe) in enumerate(edges):
            bs[(qs[0], qs[1])].append(i)
        used = [False] * len(edges)
        out_s, out_e = [], []
        for i in range(len(edges)):
            if used[i]:
                continue
            start = (edges[i][0][0], edges[i][0][1])
            out_s.append(['M', edges[i][0][0] / 20, edges[i][0][1] / 20])
            out_e.append(['M', edges[i][1][0] / 20, edges[i][1][1] / 20])
            cur = i
            while True:
                used[cur] = True
                qs, qe = edges[cur]
                out_s.append(['Q'] + [v / 20 for v in qs[2:]])
                out_e.append(['Q'] + [v / 20 for v in qe[2:]])
                end = (qs[4], qs[5])
                if end == start:
                    break
                nxt = None
                for j in bs.get(end, ()):
                    if not used[j]:
                        nxt = j
                        break
                if nxt is None:
                    break
                cur = nxt
        return out_s, out_e

    draw = []
    for fi in sorted(per_fill):
        a, z = contour_order(per_fill[fi])
        draw.append({'f': fills[fi - 1], 'a': flat(a), 'z': flat(z)})
    for li in sorted(per_line):
        edges = per_line[li]
        a = []
        z = []
        last = None
        for qs, qe in edges:
            if (qs[0], qs[1]) != last:
                a.append(['M', qs[0] / 20, qs[1] / 20])
                z.append(['M', qe[0] / 20, qe[1] / 20])
            a.append(['Q'] + [v / 20 for v in qs[2:]])
            z.append(['Q'] + [v / 20 for v in qe[2:]])
            last = (qs[4], qs[5])
        draw.append({'l': lines[li - 1], 'a': flat(a), 'z': flat(z)})
    return cid, {'t': 'morph', 'r': [r2(v) for v in r1], 'd': draw}


def flat(cmds):
    out = []
    for c in cmds:
        if c[0] == 'M':
            out.append(0)
            out += [r2(v) for v in c[1:]]
        else:
            out.append(1)
            out += [r2(v) for v in c[1:]]
    return out


# ---------------------------------------------------------------- filters

def read_filters(b):
    n = b.u8()
    res = []
    for _ in range(n):
        t = b.u8()
        if t == 0:  # drop shadow
            c = b.rgba()
            bx = b.u32() / 65536
            by = b.u32() / 65536
            ang = struct.unpack('<i', b.bytes(4))[0] / 65536
            dist = struct.unpack('<i', b.bytes(4))[0] / 65536
            strength = b.fixed8()
            fl = b.u8()
            res.append({'t': 'ds', 'c': c, 'bx': bx, 'by': by, 'a': ang, 'd': dist, 's': strength,
                        'in': (fl >> 7) & 1, 'ko': (fl >> 6) & 1, 'q': fl & 0x1f})
        elif t == 1:  # blur
            bx = b.u32() / 65536
            by = b.u32() / 65536
            q = b.u8() >> 3
            res.append({'t': 'blur', 'bx': bx, 'by': by, 'q': q})
        elif t == 2:  # glow
            c = b.rgba()
            bx = b.u32() / 65536
            by = b.u32() / 65536
            strength = b.fixed8()
            fl = b.u8()
            res.append({'t': 'glow', 'c': c, 'bx': bx, 'by': by, 's': strength,
                        'in': (fl >> 7) & 1, 'ko': (fl >> 6) & 1, 'q': fl & 0x1f})
        elif t == 3:  # bevel
            sc = b.rgba()
            hc = b.rgba()
            bx = b.u32() / 65536
            by = b.u32() / 65536
            ang = struct.unpack('<i', b.bytes(4))[0] / 65536
            dist = struct.unpack('<i', b.bytes(4))[0] / 65536
            strength = b.fixed8()
            fl = b.u8()
            res.append({'t': 'bevel', 'sc': sc, 'hc': hc, 'bx': bx, 'by': by, 'a': ang, 'd': dist, 's': strength,
                        'in': (fl >> 7) & 1, 'ko': (fl >> 6) & 1, 'top': (fl >> 4) & 1, 'q': fl & 0x0f})
        elif t in (4, 7):  # gradient glow / bevel
            n2 = b.u8()
            cols = [b.rgba() for _ in range(n2)]
            b.bytes(n2)
            b.bytes(16)
            b.fixed8()
            b.u8()
            res.append({'t': 'gglow', 'c': cols[-1] if cols else [0, 0, 0, 255]})
        elif t == 5:  # convolution
            mx = b.u8()
            my = b.u8()
            b.bytes(8)
            b.bytes(4 * mx * my)
            b.rgba()
            b.u8()
            res.append({'t': 'conv'})
        elif t == 6:  # color matrix
            m = list(struct.unpack('<20f', b.bytes(80)))
            res.append({'t': 'cm', 'm': [round(v, 4) for v in m]})
        else:
            raise ValueError('filter %d' % t)
    return res


# ---------------------------------------------------------------- text

def parse_edit_text(b):
    cid = b.u16()
    bounds = b.rect()
    b.align()
    has_text = b.ub(1)
    word_wrap = b.ub(1)
    multiline = b.ub(1)
    password = b.ub(1)
    read_only = b.ub(1)
    has_color = b.ub(1)
    has_max = b.ub(1)
    has_font = b.ub(1)
    has_font_class = b.ub(1)
    auto_size = b.ub(1)
    has_layout = b.ub(1)
    no_select = b.ub(1)
    border = b.ub(1)
    was_static = b.ub(1)
    html = b.ub(1)
    use_outlines = b.ub(1)
    t = {'t': 'text', 'r': [r2(v) for v in bounds]}
    if has_font:
        t['font'] = b.u16()
    if has_font_class:
        t['fontClass'] = b.string()
    if has_font:
        t['size'] = b.u16() / 20
    if has_color:
        t['color'] = b.rgba()
    if has_max:
        t['max'] = b.u16()
    if has_layout:
        t['align'] = ['left', 'right', 'center', 'justify'][b.u8() & 3]
        t['ml'] = b.u16() / 20
        t['mr'] = b.u16() / 20
        t['indent'] = b.u16() / 20
        t['leading'] = b.s16() / 20
    t['var'] = b.string()
    if has_text:
        t['text'] = b.string()
    if word_wrap: t['wrap'] = 1
    if multiline: t['multi'] = 1
    if password: t['pw'] = 1
    if read_only: t['ro'] = 1
    if auto_size: t['auto'] = 1
    if no_select: t['nosel'] = 1
    if border: t['border'] = 1
    if html: t['html'] = 1
    if use_outlines: t['outl'] = 1
    return cid, t


def parse_static_text(b, ver):
    cid = b.u16()
    bounds = b.rect()
    m = b.matrix()
    gbits = b.u8()
    abits = b.u8()
    recs = []
    font = None
    size = 0
    color = [0, 0, 0, 255]
    x = 0
    y = 0
    while True:
        flags = b.u8()
        if flags == 0:
            break
        has_font = flags & 8
        has_color = flags & 4
        has_y = flags & 2
        has_x = flags & 1
        if has_font:
            font = b.u16()
        if has_color:
            color = b.rgba() if ver == 2 else b.rgb()
        if has_x:
            x = b.s16() / 20
        if has_y:
            y = b.s16() / 20
        if has_font:
            size = b.u16() / 20
        n = b.u8()
        glyphs = []
        b.align()
        cx = x
        for _ in range(n):
            gi = b.ub(gbits)
            adv = b.sb(abits) / 20
            glyphs.append([gi, r2(cx)])
            cx += adv
        b.align()
        x = cx
        recs.append({'font': font, 'size': size, 'c': color, 'y': y, 'g': glyphs})
    return cid, {'t': 'stext', 'r': [r2(v) for v in bounds], 'm': px_matrix(m), 'recs': recs}


def parse_font(b, ver, tag_end):
    cid = b.u16()
    flags = b.u8()
    has_layout = flags & 0x80
    wide_offsets = flags & 0x08
    wide_codes = flags & 0x04
    italic = flags & 0x02
    bold = flags & 0x01
    b.u8()
    nl = b.u8()
    name = b.bytes(nl).decode('utf-8', 'replace').rstrip('\x00')
    n = b.u16()
    table_start = b.pos
    offs = []
    for _ in range(n):
        offs.append(b.u32() if wide_offsets else b.u16())
    code_off = (b.u32() if wide_offsets else b.u16()) if n > 0 else 0
    scale = 20480.0 if ver == 3 else 1024.0
    glyphs = []
    for i in range(n):
        gb = Bits(b.d, table_start + offs[i])
        try:
            path = parse_glyph_scaled(gb, scale)
        except Exception:
            path = ''
        glyphs.append(path)
    b.pos = table_start + code_off
    codes = []
    for _ in range(n):
        codes.append(b.u16() if wide_codes else b.u8())
    font = {'t': 'font', 'name': name, 'bold': bool(bold), 'italic': bool(italic), 'codes': codes, 'glyphs': glyphs}
    if has_layout:
        font['ascent'] = r6(b.u16() / scale)
        font['descent'] = r6(b.u16() / scale)
        font['leading'] = r6(b.s16() / scale)
        font['adv'] = [r6(b.s16() / scale) for _ in range(n)]
    return cid, font


def parse_glyph_scaled(b, scale):
    b.align()
    fb_ = b.ub(4)
    lb_ = b.ub(4)
    layers = read_shape_records(b, 1, fb_, lb_, [{'c': [0, 0, 0, 255]}], [])
    # rescale edges to em units (multiply by 20/scale so fmt's /20 yields em)
    out = []
    for fills, lines, edges in layers:
        ne = []
        k = 20.0 * 1000 / scale  # output in 1/1000 em
        for e in edges:
            if e[0] == 'M':
                ne.append(('M', e[1] * k, e[2] * k))
            else:
                ne.append(tuple(list(e[:4]) + [v * k for v in e[4:]]))
        out.append((fills, lines, ne))
    d = layers_to_draw(out)
    return ''.join(x['p'] for x in d if 'f' in x)


# ---------------------------------------------------------------- buttons

def parse_button2(b, tag_end):
    cid = b.u16()
    b.u8()  # track as menu
    action_offset = b.u16()
    recs = []
    while True:
        fl = b.u8()
        if fl == 0:
            break
        has_blend = fl & 0x20
        has_filters = fl & 0x10
        states = fl & 0x0f  # hit(8) down(4) over(2) up(1)
        ch = b.u16()
        depth = b.u16()
        m = b.matrix()
        cx = b.cxform(True)
        r = {'s': states, 'id': ch, 'dp': depth, 'm': px_matrix(m)}
        if cx != [1, 1, 1, 1, 0, 0, 0, 0]:
            r['cx'] = cx
        if has_filters:
            r['fl'] = read_filters(b)
        if has_blend:
            r['bl'] = b.u8()
        recs.append(r)
    return cid, {'t': 'button', 'recs': recs}


def parse_button1(b):
    cid = b.u16()
    recs = []
    while True:
        fl = b.u8()
        if fl == 0:
            break
        states = fl & 0x0f
        ch = b.u16()
        depth = b.u16()
        m = b.matrix()
        recs.append({'s': states, 'id': ch, 'dp': depth, 'm': px_matrix(m)})
    return cid, {'t': 'button', 'recs': recs}


# ---------------------------------------------------------------- timeline

def parse_place(b, ver, tag_end):
    p = {}
    if ver == 1:
        p['id'] = b.u16()
        p['dp'] = b.u16()
        p['m'] = px_matrix(b.matrix())
        if b.pos < tag_end:
            p['cx'] = b.cxform(False)
        return p
    fl = b.u8()
    fl2 = b.u8() if ver == 3 else 0
    p['dp'] = b.u16()
    if fl & 1:
        p['mv'] = 1
    if ver == 3 and (fl2 & 0x08 or (fl2 & 0x10 and fl & 0x02)):
        b.string()  # class name
    if fl & 0x02:
        p['id'] = b.u16()
    if fl & 0x04:
        p['m'] = px_matrix(b.matrix())
    if fl & 0x08:
        p['cx'] = b.cxform(True)
    if fl & 0x10:
        p['ra'] = b.u16()
    if fl & 0x20:
        p['nm'] = b.string()
    if fl & 0x40:
        p['clip'] = b.u16()
    if ver == 3:
        if fl2 & 0x01:
            p['fl'] = read_filters(b)
        if fl2 & 0x02:
            p['bl'] = b.u8()
        if fl2 & 0x04:
            p['cab'] = b.u8()
        if fl2 & 0x20 and b.pos < tag_end:
            p['vis'] = b.u8()
    return p


def parse_tags(b, end, ctx, is_root):
    frames = []
    cur = []
    labels = {}
    frame_no = 0
    while b.pos < end:
        hdr = b.u16()
        code = hdr >> 6
        ln = hdr & 0x3f
        if ln == 0x3f:
            ln = b.u32()
        start = b.pos
        tend = start + ln
        try:
            handle_tag(b, code, tend, ctx, cur, labels, frame_no, is_root)
        except Exception as ex:
            sys.stderr.write('tag %d at %d failed: %r\n' % (code, start, ex))
        if code == 1:
            frames.append(cur)
            cur = []
            frame_no += 1
        if code == 0:
            break
        b.pos = tend
        b.align()
    return frames, labels


def handle_tag(b, code, tend, ctx, cur, labels, frame_no, is_root):
    chars = ctx['chars']
    if code in (2, 22, 32, 83):
        ver = {2: 1, 22: 2, 32: 3, 83: 4}[code]
        cid, s = parse_shape(b, ver)
        chars[cid] = s
    elif code in (46, 84):
        cid, s = parse_morph(b, 1 if code == 46 else 2, tend)
        chars[cid] = s
    elif code == 39:
        cid = b.u16()
        fc = b.u16()
        fr, lb = parse_tags(b, tend, ctx, False)
        sp = {'t': 'sprite', 'n': fc, 'f': fr}
        if lb:
            sp['lb'] = lb
        chars[cid] = sp
    elif code in (4, 26, 70):
        cur.append(['p', parse_place(b, {4: 1, 26: 2, 70: 3}[code], tend)])
    elif code == 5:
        b.u16()
        cur.append(['r', b.u16()])
    elif code == 28:
        cur.append(['r', b.u16()])
    elif code == 43:
        labels[b.string()] = frame_no + 1
    elif code == 76:
        n = b.u16()
        for _ in range(n):
            cid = b.u16()
            nm = b.string()
            ctx['classes'][nm] = cid
    elif code == 56:  # ExportAssets
        n = b.u16()
        for _ in range(n):
            cid = b.u16()
            nm = b.string()
            ctx['exports'][nm] = cid
    elif code == 37:
        cid, t = parse_edit_text(b)
        chars[cid] = t
    elif code in (11, 33):
        cid, t = parse_static_text(b, 1 if code == 11 else 2)
        chars[cid] = t
    elif code in (48, 75):
        cid, f = parse_font(b, 2 if code == 48 else 3, tend)
        chars[cid] = f
    elif code == 34:
        cid, bt = parse_button2(b, tend)
        chars[cid] = bt
    elif code == 7:
        cid, bt = parse_button1(b)
        chars[cid] = bt
    elif code in (6, 21, 35, 90, 20, 36):
        cid = b.u16()
        chars[cid] = {'t': 'bitmap'}
        ctx['bitmaps'].append(cid)
    elif code == 14:
        cid = b.u16()
        fl = b.u8()
        chars[cid] = {'t': 'sound'}
        ctx['sounds'].append(cid)
    elif code == 15:
        sid = b.u16()
        fl = b.u8()
        cur.append(['s', sid, 1 if fl & 0x20 else 0])  # sync stop
    elif code == 60:  # DefineVideoStream
        cid = b.u16()
        n = b.u16()
        w = b.u16()
        h = b.u16()
        fl = b.u8()
        codec = b.u8()
        chars[cid] = {'t': 'video', 'n': n, 'w': w, 'h': h, 'sm': fl & 1, 'codec': codec}
    elif code == 78:
        cid = b.u16()
        ctx['grids'][cid] = [r2(v) for v in b.rect()]
    elif code == 9:
        ctx['bg'] = b.rgb()
    elif code == 18 or code == 45:  # sound stream head
        pass


def convert(path):
    data = open(path, 'rb').read()
    sig = data[:3]
    if sig == b'CWS':
        body = zlib.decompress(data[8:])
    elif sig == b'FWS':
        body = data[8:]
    else:
        raise ValueError('unsupported SWF signature %r' % sig)
    b = Bits(body)
    rect = b.rect()
    b.align()
    fr = b.u16() / 256.0
    fc = b.u16()
    ctx = {'chars': {}, 'classes': {}, 'exports': {}, 'bitmaps': [], 'sounds': [], 'grids': {}}
    frames, labels = parse_tags(b, len(body), ctx, True)
    for cid, g in ctx['grids'].items():
        if cid in ctx['chars']:
            ctx['chars'][cid]['grid'] = g
    root = {'t': 'sprite', 'n': fc, 'f': frames}
    if labels:
        root['lb'] = labels
    ctx['chars'][0] = root
    return {
        'size': [r2(rect[2]), r2(rect[3])],
        'fps': fr,
        'chars': {str(k): v for k, v in ctx['chars'].items()},
        'classes': ctx['classes'],
        'bitmaps': ctx['bitmaps'],
        'sounds': ctx['sounds'],
    }


if __name__ == '__main__':
    res = convert(sys.argv[1])
    with open(sys.argv[2], 'w') as f:
        json.dump(res, f, separators=(',', ':'))
