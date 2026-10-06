// Language-level helpers used by the translated ActionScript code (see tools/as3tojs.py).
'use strict';

// URL query parameters (e.g. ?debug=1 logs the game's internal messages to the console)
const $flags = (function () {
  const o = {};
  for (const [k, v] of new URLSearchParams(location.search)) o[k] = v;
  return o;
})();

function $class(ctor, parent, fqName, interfaces) {
  if (parent) {
    ctor.prototype = Object.create(parent.prototype);
    ctor.prototype.constructor = ctor;
  }
  ctor.$fq = fqName;
  ctor.$interfaces = (interfaces || []).filter(Boolean);
  ctor.$parent = parent || null;
}

function $interface(ctor, fqName, parents) {
  ctor.$fq = fqName;
  ctor.$isInterface = true;
  ctor.$interfaces = (parents || []).filter(Boolean);
}

function $accessor(target, name, desc) {
  const existing = Object.getOwnPropertyDescriptor(target, name);
  const d = { configurable: true, enumerable: false };
  // A subclass overriding only the getter (or setter) inherits the other half in AS3.
  let inherited = null;
  if (!desc.get || !desc.set) {
    let p = Object.getPrototypeOf(target);
    while (p && !inherited) {
      inherited = Object.getOwnPropertyDescriptor(p, name);
      p = Object.getPrototypeOf(p);
    }
  }
  d.get = desc.get || (existing && existing.get) || (inherited && inherited.get) || undefined;
  d.set = desc.set || (existing && existing.set) || (inherited && inherited.set) || undefined;
  Object.defineProperty(target, name, d);
}

// Lazily initialised static members (AS3 initialises class statics on first use).
function $static(target, name, init) {
  Object.defineProperty(target, name, {
    configurable: true, enumerable: true,
    get() {
      const v = init();
      Object.defineProperty(target, name, { value: v, writable: true, configurable: true, enumerable: true });
      return v;
    },
    set(v) {
      Object.defineProperty(target, name, { value: v, writable: true, configurable: true, enumerable: true });
    },
  });
}

function $implements(ctor, iface) {
  while (ctor) {
    const list = ctor.$interfaces;
    if (list) {
      for (const i of list) {
        if (i === iface || $implements(i, iface)) return true;
      }
    }
    ctor = ctor.$parent;
  }
  return false;
}

const $T = {
  int: { [Symbol.hasInstance]: (v) => typeof v === 'number' && (v | 0) === v },
  uint: { [Symbol.hasInstance]: (v) => typeof v === 'number' && (v >>> 0) === v },
  Number: { [Symbol.hasInstance]: (v) => typeof v === 'number' },
  String: { [Symbol.hasInstance]: (v) => typeof v === 'string' },
  Boolean: { [Symbol.hasInstance]: (v) => typeof v === 'boolean' },
  Array: { [Symbol.hasInstance]: (v) => Array.isArray(v) },
  Object: { [Symbol.hasInstance]: (v) => v != null },
  Function: { [Symbol.hasInstance]: (v) => typeof v === 'function' },
  Class: { [Symbol.hasInstance]: (v) => typeof v === 'function' },
  XML: { [Symbol.hasInstance]: (v) => v instanceof XML },
};

function $is(v, type) {
  if (v == null || type == null) return false;
  if (type.$isInterface) {
    return typeof v === 'object' && $implements(v.constructor, type);
  }
  if (typeof type === 'function') {
    if (v instanceof type) return true;
    return false;
  }
  return v instanceof type;
}

function $as(v, type) {
  return $is(v, type) ? v : null;
}

// Bound method closure (AS3 method closures keep `this`). Cached so that
// removeEventListener receives the same function object.
function $b(obj, name) {
  if (obj == null) return obj[name];
  const f = obj[name];
  if (typeof f !== 'function' || f.$fq) return f;
  if (Object.prototype.hasOwnProperty.call(obj, name)) return f;
  let cache = obj.__bound;
  if (!cache) {
    cache = new Map();
    Object.defineProperty(obj, '__bound', { value: cache, enumerable: false });
  }
  let entry = cache.get(name);
  if (!entry || entry.f !== f) {
    entry = { f, b: f.bind(obj) };
    cache.set(name, entry);
  }
  return entry.b;
}

// for each (x in obj)
function $each(obj) {
  if (obj == null) return [];
  if (Array.isArray(obj)) return obj;
  if (obj instanceof flash_utils_Dictionary) return Array.from(obj.$map.values());
  if (obj instanceof XMLList) return obj.toArray();
  if (typeof obj === 'string') return [];
  if (typeof obj[Symbol.iterator] === 'function' && !(obj instanceof flash_display_DisplayObject)) return obj;
  return Object.keys(obj).map((k) => obj[k]);
}

// for (k in obj)
function $keys(obj) {
  if (obj == null) return {};
  if (obj instanceof flash_utils_Dictionary) {
    // Keys of a Dictionary may be objects: expose through a proxy array of keys
    const out = {};
    let i = 0;
    for (const k of obj.$map.keys()) out[i++] = k;
    return $dictKeyIter(obj);
  }
  return obj;
}

function $dictKeyIter(d) {
  // Object whose enumerable keys are the dictionary keys (string keys only).
  const o = {};
  for (const k of d.$map.keys()) o[k] = true;
  return o;
}

function $sget(proto, self, name) {
  let p = proto;
  while (p) {
    const d = Object.getOwnPropertyDescriptor(p, name);
    if (d) return d.get ? d.get.call(self) : d.value;
    p = Object.getPrototypeOf(p);
  }
  return undefined;
}

function $sset(proto, self, name, v) {
  let p = proto;
  while (p) {
    const d = Object.getOwnPropertyDescriptor(p, name);
    if (d) {
      if (d.set) d.set.call(self, v);
      else self[name] = v;
      return;
    }
    p = Object.getPrototypeOf(p);
  }
  self[name] = v;
}

function int(v) {
  if (typeof v === 'string') v = Number(v);
  return v | 0;
}
int.MAX_VALUE = 2147483647;
int.MIN_VALUE = -2147483648;

function uint(v) {
  if (typeof v === 'string') v = Number(v);
  return v >>> 0;
}
uint.MAX_VALUE = 4294967295;
uint.MIN_VALUE = 0;

function trace(...args) {
  console.log(...args);
}

// ---- Array extensions used by AS3 code
Array.CASEINSENSITIVE = 1;
Array.DESCENDING = 2;
Array.UNIQUESORT = 4;
Array.RETURNINDEXEDARRAY = 8;
Array.NUMERIC = 16;

(function () {
  const nativeSort = Array.prototype.sort;
  function makeCmp(opts, getter) {
    const numeric = opts & Array.NUMERIC;
    const ci = opts & Array.CASEINSENSITIVE;
    const desc = opts & Array.DESCENDING;
    return function (x, y) {
      let a = getter ? getter(x) : x;
      let b = getter ? getter(y) : y;
      let r;
      if (numeric) {
        r = Number(a) - Number(b);
      } else {
        a = String(a); b = String(b);
        if (ci) { a = a.toLowerCase(); b = b.toLowerCase(); }
        r = a < b ? -1 : a > b ? 1 : 0;
      }
      return desc ? -r : r;
    };
  }
  Object.defineProperty(Array.prototype, 'sort', {
    configurable: true, writable: true,
    value: function (a, b) {
      if (typeof a === 'number') return nativeSort.call(this, makeCmp(a));
      if (typeof a === 'function') {
        const r = nativeSort.call(this, a);
        if (typeof b === 'number' && b & Array.DESCENDING) this.reverse();
        return r;
      }
      return nativeSort.call(this, makeCmp(0));
    },
  });
  Object.defineProperty(Array.prototype, 'sortOn', {
    configurable: true, writable: true,
    value: function (field, opts) {
      opts = opts || 0;
      if (Array.isArray(field)) {
        const fields = field;
        const optList = Array.isArray(opts) ? opts : fields.map(() => opts);
        return nativeSort.call(this, (x, y) => {
          for (let i = 0; i < fields.length; i++) {
            const r = makeCmp(optList[i] || 0, (o) => o[fields[i]])(x, y);
            if (r) return r;
          }
          return 0;
        });
      }
      return nativeSort.call(this, makeCmp(opts, (o) => o[field]));
    },
  });
})();

// AS3 Number/String helpers that differ from JS
if (!String.prototype.localeCompare) {
  String.prototype.localeCompare = function (s) { return this < s ? -1 : this > s ? 1 : 0; };
}

function $cast(v) {
  return v;
}

function $str(v) {
  if (v == null) return null;
  return typeof v === 'string' ? v : String(v);
}

// Flash's escape()/unescape() use UTF-8 (System.useCodePage = false), unlike the JS globals.
(function () {
  const jsUnescape = window.unescape;
  window.unescape = function (s) {
    s = String(s);
    return s.replace(/(%[0-9A-Fa-f]{2})+/g, (run) => {
      try {
        return decodeURIComponent(run);
      } catch (e) {
        return jsUnescape(run);
      }
    }).replace(/%u([0-9A-Fa-f]{4})/g, (m, h) => String.fromCharCode(parseInt(h, 16)));
  };
  window.escape = function (s) {
    return encodeURIComponent(String(s)).replace(/[!'()~]/g, (c) => '%' + c.charCodeAt(0).toString(16).toUpperCase());
  };
})();

class ArgumentError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ArgumentError';
  }
}
