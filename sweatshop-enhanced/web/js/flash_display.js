// Display list: DisplayObject, containers, MovieClip timelines, shapes, Graphics, bitmaps.
'use strict';

const $DEG = Math.PI / 180;
const $ID = [1, 0, 0, 1, 0, 0];

function $mul(m, n) {
  // apply m then n  (point' = n * (m * p))
  return [
    m[0] * n[0] + m[1] * n[2],
    m[0] * n[1] + m[1] * n[3],
    m[2] * n[0] + m[3] * n[2],
    m[2] * n[1] + m[3] * n[3],
    m[4] * n[0] + m[5] * n[2] + n[4],
    m[4] * n[1] + m[5] * n[3] + n[5],
  ];
}
function $inv(m) {
  const det = m[0] * m[3] - m[1] * m[2];
  if (!det) return [1, 0, 0, 1, -m[4], -m[5]];
  const a = m[3] / det, b = -m[1] / det, c = -m[2] / det, d = m[0] / det;
  return [a, b, c, d, -(a * m[4] + c * m[5]), -(b * m[4] + d * m[5])];
}
function $apply(m, x, y) {
  return [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]];
}
// concatenate color transforms: child (c) inside parent (p)
function $cxMul(c, p) {
  if (!c) return p;
  if (!p) return c;
  return [
    c[0] * p[0], c[1] * p[1], c[2] * p[2], c[3] * p[3],
    c[4] * p[0] + p[4], c[5] * p[1] + p[5], c[6] * p[2] + p[6], c[7] * p[3] + p[7],
  ];
}
function $boundsOf(rect, m) {
  // rect [x0,y0,x1,y1] transformed by m -> [x0,y0,x1,y1]
  const p = [$apply(m, rect[0], rect[1]), $apply(m, rect[2], rect[1]), $apply(m, rect[0], rect[3]), $apply(m, rect[2], rect[3])];
  let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
  for (const q of p) {
    if (q[0] < x0) x0 = q[0];
    if (q[0] > x1) x1 = q[0];
    if (q[1] < y0) y0 = q[1];
    if (q[1] > y1) y1 = q[1];
  }
  return [x0, y0, x1, y1];
}
function $unionB(a, b) {
  if (!a) return b;
  if (!b) return a;
  return [Math.min(a[0], b[0]), Math.min(a[1], b[1]), Math.max(a[2], b[2]), Math.max(a[3], b[3])];
}

let $instanceCounter = 0;

// Change tracking for bitmap caching: every change bumps $seq and stamps the object and all of
// its ancestors, so a cached ancestor knows its bitmap is stale.
let $seq = 1;
function $touch(o) {
  const s = ++$seq;
  while (o) {
    o.$chg = s;
    o = o.$parent;
  }
}

// The page URL and its query string play the role of the SWF url and flashvars.
let $loaderInfoObj = null;
function $loaderInfo() {
  if (!$loaderInfoObj) {
    const parameters = {};
    for (const [k, v] of new URLSearchParams(location.search)) parameters[k] = v;
    $loaderInfoObj = { url: location.href, parameters, bytesLoaded: 1, bytesTotal: 1, applicationDomain: null };
  }
  return $loaderInfoObj;
}

// ------------------------------------------------------------------ DisplayObject
function flash_display_DisplayObject() {
  flash_events_EventDispatcher.call(this);
  this.$parent = null;
  this.$name = 'instance' + (++$instanceCounter);
  this.$m = [1, 0, 0, 1, 0, 0];
  this.$sx = 1; this.$sy = 1; this.$rotX = 0; this.$rotY = 0; // cached decomposition (degrees)
  this.$cx = null;
  this.$visible = true;
  this.$filters = null;
  this.$blend = null;
  this.$mask = null;
  this.$maskOf = null;
  this.$clipDepth = 0;
  this.$depth = null; // timeline depth
  this.$scripted = false; // transform changed from code: timeline no longer drives it
  this.cacheAsBitmap = false;
  this.opaqueBackground = null;
  this.scrollRect = null;
  this.scale9Grid = null;
  this.$transform = null;
  this.$chg = 0;
  this.$cache = null;
}
$class(flash_display_DisplayObject, flash_events_EventDispatcher, 'flash.display.DisplayObject');

(function (P) {
  P.$setMatrix = function (m) {
    this.$m = m.slice();
    const a = m[0], b = m[1], c = m[2], d = m[3];
    this.$sx = Math.sqrt(a * a + b * b);
    this.$sy = Math.sqrt(c * c + d * d);
    this.$rotX = Math.atan2(b, a) / $DEG;
    this.$rotY = Math.atan2(-c, d) / $DEG;
    $touch(this.$parent);
  };
  P.$getMatrix = function () { return this.$m; };
  P.$recompose = function () {
    $touch(this.$parent);
    const rx = this.$rotX * $DEG, ry = this.$rotY * $DEG;
    const m = this.$m;
    m[0] = this.$sx * Math.cos(rx);
    m[1] = this.$sx * Math.sin(rx);
    m[2] = -this.$sy * Math.sin(ry);
    m[3] = this.$sy * Math.cos(ry);
  };
  $accessor(P, 'x', { get() { return this.$m[4]; }, set(v) { v = +v; if (isNaN(v)) return; if (this.$m[4] !== v) { this.$m[4] = v; $touch(this.$parent); } this.$scripted = true; } });
  $accessor(P, 'y', { get() { return this.$m[5]; }, set(v) { v = +v; if (isNaN(v)) return; if (this.$m[5] !== v) { this.$m[5] = v; $touch(this.$parent); } this.$scripted = true; } });
  $accessor(P, 'scaleX', { get() { return this.$sx; }, set(v) { v = +v; if (isNaN(v)) return; this.$sx = v; this.$recompose(); this.$scripted = true; } });
  $accessor(P, 'scaleY', { get() { return this.$sy; }, set(v) { v = +v; if (isNaN(v)) return; this.$sy = v; this.$recompose(); this.$scripted = true; } });
  $accessor(P, 'rotation', {
    get() {
      let r = this.$rotX % 360;
      if (r > 180) r -= 360;
      if (r < -180) r += 360;
      return r;
    },
    set(v) {
      v = +v; if (isNaN(v)) return;
      const skew = this.$rotY - this.$rotX;
      this.$rotX = v; this.$rotY = v + skew; this.$recompose(); this.$scripted = true;
    },
  });
  $accessor(P, 'alpha', {
    get() { return this.$cx ? this.$cx[3] : 1; },
    set(v) {
      v = +v; if (isNaN(v)) return;
      if (!this.$cx) this.$cx = [1, 1, 1, 1, 0, 0, 0, 0]; else this.$cx = this.$cx.slice();
      this.$cx[3] = v;
      this.$scriptedCx = true;
      $touch(this.$parent);
    },
  });
  P.$setColorTransform = function (a) {
    this.$cx = a ? a.slice() : null;
    this.$scriptedCx = true;
    $touch(this.$parent);
  };
  $accessor(P, 'visible', {
    get() { return this.$visible; },
    set(v) {
      v = !!v;
      if (v !== this.$visible) { this.$visible = v; $touch(this.$parent); }
    },
  });
  $accessor(P, 'name', { get() { return this.$name; }, set(v) { this.$name = v; } });
  $accessor(P, 'parent', { get() { return this.$parent; } });
  $accessor(P, 'stage', {
    get() {
      let o = this;
      while (o.$parent) o = o.$parent;
      return o instanceof flash_display_Stage ? o : null;
    },
  });
  $accessor(P, 'root', {
    get() {
      let o = this;
      while (o.$parent && !(o.$parent instanceof flash_display_Stage)) o = o.$parent;
      return o;
    },
  });
  $accessor(P, 'loaderInfo', { get() { return $loaderInfo(); } });
  $accessor(P, 'transform', {
    get() { return this.$transform || (this.$transform = new flash_geom_Transform(this)); },
    set(t) {
      if (t && t.$obj) {
        this.$setMatrix(t.$obj.$m);
        this.$cx = t.$obj.$cx ? t.$obj.$cx.slice() : null;
      }
    },
  });
  $accessor(P, 'filters', {
    get() { return this.$filters ? this.$filters.slice() : []; },
    set(v) { this.$filters = v && v.length ? v.slice() : null; this.$scriptedFilters = true; $touch(this); },
  });
  $accessor(P, 'blendMode', { get() { return this.$blend || 'normal'; }, set(v) { this.$blend = v === 'normal' ? null : v; $touch(this); } });
  $accessor(P, 'mask', {
    get() { return this.$mask; },
    set(m) {
      if (this.$mask) this.$mask.$maskOf = null;
      this.$mask = m || null;
      if (m) m.$maskOf = this;
      $touch(this);
    },
  });
  $accessor(P, 'mouseX', { get() { return this.globalToLocal(new flash_geom_Point($mouse.x, $mouse.y)).x; } });
  $accessor(P, 'mouseY', { get() { return this.globalToLocal(new flash_geom_Point($mouse.x, $mouse.y)).y; } });

  P.$globalMatrix = function () {
    let m = this.$m;
    let p = this.$parent;
    while (p) {
      m = $mul(m, p.$m);
      p = p.$parent;
    }
    return m;
  };
  P.localToGlobal = function (pt) {
    const q = $apply(this.$globalMatrix(), pt.x, pt.y);
    return new flash_geom_Point(q[0], q[1]);
  };
  P.globalToLocal = function (pt) {
    const q = $apply($inv(this.$globalMatrix()), pt.x, pt.y);
    return new flash_geom_Point(q[0], q[1]);
  };
  // bounds of own content in own coordinate space, transformed by m. Returns [x0,y0,x1,y1] or null
  P.$contentBounds = function (m) { return null; };
  P.$bounds = function (m) {
    return this.$contentBounds(m);
  };
  P.getBounds = function (target) {
    let m = this.$globalMatrix();
    if (target) m = $mul(m, $inv(target.$globalMatrix()));
    const b = this.$bounds(m);
    if (!b) {
      const p = $apply(m, 0, 0);
      return new flash_geom_Rectangle(p[0], p[1], 0, 0);
    }
    return new flash_geom_Rectangle(b[0], b[1], b[2] - b[0], b[3] - b[1]);
  };
  P.getRect = function (target) { return this.getBounds(target); };
  $accessor(P, 'width', {
    get() { const b = this.$bounds(this.$m); return b ? b[2] - b[0] : 0; },
    set(v) {
      v = +v; if (isNaN(v)) return;
      const b = this.$bounds([1, 0, 0, 1, 0, 0]);
      const w = b ? b[2] - b[0] : 0;
      if (!w) return;
      this.$sx = (this.$sx < 0 ? -1 : 1) * v / w;
      this.$recompose();
      this.$scripted = true;
    },
  });
  $accessor(P, 'height', {
    get() { const b = this.$bounds(this.$m); return b ? b[3] - b[1] : 0; },
    set(v) {
      v = +v; if (isNaN(v)) return;
      const b = this.$bounds([1, 0, 0, 1, 0, 0]);
      const h = b ? b[3] - b[1] : 0;
      if (!h) return;
      this.$sy = (this.$sy < 0 ? -1 : 1) * v / h;
      this.$recompose();
      this.$scripted = true;
    },
  });
  P.hitTestPoint = function (x, y, shapeFlag = false) {
    if (!shapeFlag) {
      const b = this.$bounds(this.$globalMatrix());
      return !!b && x >= b[0] && x <= b[2] && y >= b[1] && y <= b[3];
    }
    return $hitContent(this, x, y, this.$parent ? this.$parent.$globalMatrix() : $ID, true);
  };
  P.hitTestObject = function (o) {
    const a = this.getBounds(null), b = o.getBounds(null);
    return a.intersects(b);
  };
  P.toString = function () { return '[object ' + (this.constructor.$fq || 'DisplayObject').split('.').pop() + ']'; };
  // drawing (implemented by subclasses)
  P.$draw = function (r, m, cx) {};
  // shape-accurate hit test of own content (not children); m = global matrix of this object
  P.$hitSelf = function (x, y, m) { return false; };
})(flash_display_DisplayObject.prototype);

// ------------------------------------------------------------------ InteractiveObject
function flash_display_InteractiveObject() {
  flash_display_DisplayObject.call(this);
  this.mouseEnabled = true;
  this.doubleClickEnabled = false;
  this.tabEnabled = false;
  this.tabIndex = -1;
  this.focusRect = null;
  this.contextMenu = null;
}
$class(flash_display_InteractiveObject, flash_display_DisplayObject, 'flash.display.InteractiveObject');

// ------------------------------------------------------------------ DisplayObjectContainer
function flash_display_DisplayObjectContainer() {
  flash_display_InteractiveObject.call(this);
  this.$children = [];
  this.mouseChildren = true;
  this.tabChildren = true;
}
$class(flash_display_DisplayObjectContainer, flash_display_InteractiveObject, 'flash.display.DisplayObjectContainer');

// Hand the cached bitmaps of a removed subtree back to the renderer's canvas pool, so that
// short-lived objects (e.g. rain drops) don't keep allocating new canvases.
function $releaseCaches(o) {
  if (o.$cache) {
    const cv = o.$cache.canvas;
    o.$cache = null;
    $cachedObjs.delete(o);
    if (cv) $releaseLayer(cv);
  }
  const ch = o.$children;
  if (ch) for (let i = 0; i < ch.length; i++) $releaseCaches(ch[i]);
}

function $dispatchAddedToStage(o) {
  o.dispatchEvent(new flash_events_Event('addedToStage'));
  if (o.$children) for (const c of o.$children.slice()) $dispatchAddedToStage(c);
}
function $dispatchRemovedFromStage(o) {
  o.dispatchEvent(new flash_events_Event('removedFromStage'));
  if (o.$children) for (const c of o.$children.slice()) $dispatchRemovedFromStage(c);
}

(function (P) {
  $accessor(P, 'numChildren', { get() { return this.$children.length; } });
  P.addChild = function (c) { return this.addChildAt(c, this.$children.length - (c.$parent === this ? 1 : 0)); };
  P.addChildAt = function (c, index) {
    if (c == null) throw new TypeError('Parameter child must be non-null.');
    if (c === this) throw new Error('An object cannot be added as a child of itself.');
    const wasOnStage = !!c.stage;
    if (c.$parent) {
      if (c.$parent === this) {
        const i = this.$children.indexOf(c);
        this.$children.splice(i, 1);
        this.$children.splice(Math.min(index, this.$children.length), 0, c);
        $touch(this);
        return c;
      }
      c.$parent.removeChild(c);
    }
    this.$children.splice(Math.max(0, Math.min(index, this.$children.length)), 0, c);
    c.$parent = this;
    $touch(this);
    c.dispatchEvent(new flash_events_Event('added', true));
    if (this.stage && !wasOnStage) $dispatchAddedToStage(c);
    return c;
  };
  P.removeChild = function (c) {
    const i = this.$children.indexOf(c);
    if (i < 0) throw new Error('The supplied DisplayObject must be a child of the caller.');
    return this.removeChildAt(i);
  };
  P.removeChildAt = function (i) {
    const c = this.$children[i];
    if (!c) throw new RangeError('The supplied index is out of bounds.');
    c.dispatchEvent(new flash_events_Event('removed', true));
    const onStage = !!this.stage;
    if (onStage) $dispatchRemovedFromStage(c);
    const j = this.$children.indexOf(c);
    if (j >= 0) this.$children.splice(j, 1);
    c.$parent = null;
    $touch(this);
    $releaseCaches(c);
    return c;
  };
  P.getChildAt = function (i) {
    const c = this.$children[i];
    if (!c) throw new RangeError('The supplied index is out of bounds.');
    return c;
  };
  P.getChildByName = function (name) {
    for (const c of this.$children) if (c.$name === name) return c;
    return null;
  };
  P.getChildIndex = function (c) {
    const i = this.$children.indexOf(c);
    if (i < 0) throw new Error('The supplied DisplayObject must be a child of the caller.');
    return i;
  };
  P.setChildIndex = function (c, index) {
    const i = this.$children.indexOf(c);
    if (i < 0) throw new Error('The supplied DisplayObject must be a child of the caller.');
    this.$children.splice(i, 1);
    this.$children.splice(Math.max(0, Math.min(index, this.$children.length)), 0, c);
    if (i !== index) $touch(this);
  };
  P.swapChildren = function (a, b) {
    const i = this.$children.indexOf(a), j = this.$children.indexOf(b);
    this.$children[i] = b; this.$children[j] = a;
    $touch(this);
  };
  P.swapChildrenAt = function (i, j) {
    const a = this.$children[i];
    this.$children[i] = this.$children[j];
    this.$children[j] = a;
    $touch(this);
  };
  P.contains = function (c) {
    while (c) {
      if (c === this) return true;
      c = c.$parent;
    }
    return false;
  };
  P.$bounds = function (m) {
    let b = this.$contentBounds(m);
    for (const c of this.$children) {
      if (c.$maskOf || c.$isClipMask) continue;
      const cb = c.$bounds($mul(c.$m, m));
      b = $unionB(b, cb);
    }
    return b;
  };
})(flash_display_DisplayObjectContainer.prototype);

// ------------------------------------------------------------------ Graphics
function flash_display_Graphics(owner) {
  this.$owner = owner;
  this.$cmds = []; // {fill: style, path: Path2D} | {line: style, path}
  this.$bounds = null;
  this.$fill = null;
  this.$fillPath = null;
  this.$line = null;
  this.$linePath = null;
  this.$x = 0;
  this.$y = 0;
}
$class(flash_display_Graphics, null, 'flash.display.Graphics');
(function (P) {
  P.$flushFill = function () {
    if (this.$fill && this.$fillPath) {
      this.$fillPath.closePath();
      this.$cmds.push({ fill: this.$fill, path: this.$fillPath });
    }
    this.$fillPath = null;
  };
  P.$flushLine = function () {
    if (this.$line && this.$linePath) this.$cmds.push({ line: this.$line, path: this.$linePath });
    this.$linePath = null;
  };
  P.$ext = function (x, y, pad = 0) {
    const b = this.$bounds;
    if (!b) this.$bounds = [x - pad, y - pad, x + pad, y + pad];
    else {
      if (x - pad < b[0]) b[0] = x - pad;
      if (y - pad < b[1]) b[1] = y - pad;
      if (x + pad > b[2]) b[2] = x + pad;
      if (y + pad > b[3]) b[3] = y + pad;
    }
  };
  P.clear = function () {
    this.$cmds = [];
    this.$bounds = null;
    this.$fill = this.$fillPath = this.$line = this.$linePath = null;
    this.$x = this.$y = 0;
  };
  P.beginFill = function (color = 0, alpha = 1) {
    this.$flushFill();
    this.$flushLine();
    this.$fill = { c: [(color >> 16) & 255, (color >> 8) & 255, color & 255, Math.round(alpha * 255)] };
    this.$fillPath = new Path2D();
    this.$fillPath.moveTo(this.$x, this.$y);
    if (this.$line) { this.$linePath = new Path2D(); this.$linePath.moveTo(this.$x, this.$y); }
  };
  P.beginGradientFill = function (type, colors, alphas, ratios, matrix = null, spread = 'pad') {
    this.$flushFill();
    this.$flushLine();
    const m = matrix ? [matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty] : [0.0610, 0, 0, 0.0610, 50, 50];
    const s = colors.map((c, i) => [ratios[i], (c >> 16) & 255, (c >> 8) & 255, c & 255, Math.round(alphas[i] * 255)]);
    this.$fill = { g: type === 'radial' ? 'r' : 'l', m, s };
    this.$fillPath = new Path2D();
    this.$fillPath.moveTo(this.$x, this.$y);
  };
  P.beginBitmapFill = function (bmd, matrix = null, repeat = true, smooth = false) {
    this.$flushFill();
    this.$flushLine();
    const m = matrix ? [matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty] : [1, 0, 0, 1, 0, 0];
    this.$fill = { bmd, m, rep: repeat, sm: smooth };
    this.$fillPath = new Path2D();
    this.$fillPath.moveTo(this.$x, this.$y);
  };
  P.endFill = function () {
    this.$flushFill();
    this.$fill = null;
  };
  P.lineStyle = function (thickness = NaN, color = 0, alpha = 1) {
    this.$flushLine();
    if (thickness === undefined || thickness === null || isNaN(thickness)) {
      this.$line = null;
      return;
    }
    this.$line = { w: thickness, c: [(color >> 16) & 255, (color >> 8) & 255, color & 255, Math.round(alpha * 255)] };
    this.$linePath = new Path2D();
    this.$linePath.moveTo(this.$x, this.$y);
  };
  P.moveTo = function (x, y) {
    this.$x = x; this.$y = y;
    if (this.$fillPath) this.$fillPath.moveTo(x, y);
    if (this.$linePath) this.$linePath.moveTo(x, y);
    this.$ext(x, y);
  };
  P.lineTo = function (x, y) {
    if (this.$fillPath) this.$fillPath.lineTo(x, y);
    if (this.$linePath) this.$linePath.lineTo(x, y);
    this.$ext(this.$x, this.$y, this.$line ? this.$line.w / 2 : 0);
    this.$ext(x, y, this.$line ? this.$line.w / 2 : 0);
    this.$x = x; this.$y = y;
  };
  P.curveTo = function (cx, cy, x, y) {
    if (this.$fillPath) this.$fillPath.quadraticCurveTo(cx, cy, x, y);
    if (this.$linePath) this.$linePath.quadraticCurveTo(cx, cy, x, y);
    this.$ext(cx, cy);
    this.$ext(x, y);
    this.$x = x; this.$y = y;
  };
  P.$shape = function (fn, b) {
    const pad = this.$line ? this.$line.w / 2 : 0;
    if (this.$fillPath) fn(this.$fillPath);
    if (this.$linePath) fn(this.$linePath);
    if (!this.$fillPath && !this.$linePath) return;
    this.$ext(b[0], b[1], pad);
    this.$ext(b[2], b[3], pad);
  };
  P.drawRect = function (x, y, w, h) {
    this.$shape((p) => { p.moveTo(x, y); p.lineTo(x + w, y); p.lineTo(x + w, y + h); p.lineTo(x, y + h); p.lineTo(x, y); }, [x, y, x + w, y + h]);
    this.$x = x; this.$y = y;
  };
  P.drawRoundRect = function (x, y, w, h, ew, eh) {
    const rx = Math.min(w / 2, (ew || 0) / 2), ry = Math.min(h / 2, ((eh === undefined || isNaN(eh)) ? ew : eh) / 2);
    this.$shape((p) => {
      p.moveTo(x + rx, y);
      p.lineTo(x + w - rx, y);
      p.ellipse(x + w - rx, y + ry, rx, ry, 0, -Math.PI / 2, 0);
      p.lineTo(x + w, y + h - ry);
      p.ellipse(x + w - rx, y + h - ry, rx, ry, 0, 0, Math.PI / 2);
      p.lineTo(x + rx, y + h);
      p.ellipse(x + rx, y + h - ry, rx, ry, 0, Math.PI / 2, Math.PI);
      p.lineTo(x, y + ry);
      p.ellipse(x + rx, y + ry, rx, ry, 0, Math.PI, Math.PI * 1.5);
    }, [x, y, x + w, y + h]);
  };
  P.drawCircle = function (x, y, r) {
    this.$shape((p) => { p.moveTo(x + r, y); p.arc(x, y, Math.abs(r), 0, Math.PI * 2); }, [x - r, y - r, x + r, y + r]);
  };
  P.drawEllipse = function (x, y, w, h) {
    this.$shape((p) => { p.moveTo(x + w, y + h / 2); p.ellipse(x + w / 2, y + h / 2, w / 2, h / 2, 0, 0, Math.PI * 2); }, [x, y, x + w, y + h]);
  };
  P.$all = function () {
    // committed + pending commands
    const out = this.$cmds.slice();
    if (this.$fill && this.$fillPath) out.push({ fill: this.$fill, path: this.$fillPath });
    if (this.$line && this.$linePath) out.push({ line: this.$line, path: this.$linePath });
    return out;
  };
  for (const name of ['clear', 'beginFill', 'beginGradientFill', 'beginBitmapFill', 'endFill', 'lineStyle', 'moveTo',
    'lineTo', 'curveTo', 'drawRect', 'drawRoundRect', 'drawCircle', 'drawEllipse']) {
    const f = P[name];
    P[name] = function (...args) {
      $touch(this.$owner);
      return f.apply(this, args);
    };
  }
})(flash_display_Graphics.prototype);

// ------------------------------------------------------------------ Sprite / Shape
function flash_display_Sprite() {
  flash_display_DisplayObjectContainer.call(this);
  this.$graphics = null;
  this.buttonMode = false;
  this.useHandCursor = true;
  this.hitArea = null;
  this.dropTarget = null;
}
$class(flash_display_Sprite, flash_display_DisplayObjectContainer, 'flash.display.Sprite');
$accessor(flash_display_Sprite.prototype, 'graphics', {
  get() { return this.$graphics || (this.$graphics = new flash_display_Graphics(this)); },
});
flash_display_Sprite.prototype.$contentBounds = function (m) {
  return this.$graphics && this.$graphics.$bounds ? $boundsOf(this.$graphics.$bounds, m) : null;
};
flash_display_Sprite.prototype.$draw = function (r, m, cx) {
  if (this.$graphics) r.drawGraphics(this.$graphics, m, cx);
};
flash_display_Sprite.prototype.$hitSelf = function (x, y, m) {
  return !!this.$graphics && $hitGraphics(this.$graphics, x, y, m);
};
flash_display_Sprite.prototype.startDrag = function () {};
flash_display_Sprite.prototype.stopDrag = function () {};

function flash_display_Shape() {
  flash_display_DisplayObject.call(this);
  this.$graphics = null;
}
$class(flash_display_Shape, flash_display_DisplayObject, 'flash.display.Shape');
$accessor(flash_display_Shape.prototype, 'graphics', {
  get() { return this.$graphics || (this.$graphics = new flash_display_Graphics(this)); },
});
flash_display_Shape.prototype.$contentBounds = flash_display_Sprite.prototype.$contentBounds;
flash_display_Shape.prototype.$draw = flash_display_Sprite.prototype.$draw;
flash_display_Shape.prototype.$hitSelf = flash_display_Sprite.prototype.$hitSelf;

function mx_core_SpriteAsset() {
  flash_display_Sprite.call(this);
}
$class(mx_core_SpriteAsset, flash_display_Sprite, 'mx.core.SpriteAsset');

// ------------------------------------------------------------------ Symbol shapes (from library)
function $SymbolShape(lib, def) {
  flash_display_DisplayObject.call(this);
  this.$lib = lib;
  this.$def = def;
}
$class($SymbolShape, flash_display_DisplayObject, 'flash.display.Shape');
$SymbolShape.prototype.$contentBounds = function (m) { return $boundsOf(this.$def.r, m); };
$SymbolShape.prototype.$draw = function (r, m, cx) { r.drawShapeDef(this.$lib, this.$def, m, cx); };
$SymbolShape.prototype.$hitSelf = function (x, y, m) { return $hitShapeDef(this.$def, x, y, m); };

function $MorphShape(lib, def) {
  flash_display_DisplayObject.call(this);
  this.$lib = lib;
  this.$def = def;
  this.$ratio = 0;
  this.$cache = null;
}
$class($MorphShape, flash_display_DisplayObject, 'flash.display.MorphShape');
$MorphShape.prototype.$shapeDef = function () {
  const t = this.$ratio / 65535;
  if (this.$cache && this.$cache.t === t) return this.$cache.def;
  const d = [];
  for (const e of this.$def.d) {
    const a = e.a, z = e.z;
    let s = '';
    for (let i = 0; i < a.length;) {
      if (a[i] === 0) {
        s += 'M' + (a[i + 1] + (z[i + 1] - a[i + 1]) * t) + ' ' + (a[i + 2] + (z[i + 2] - a[i + 2]) * t);
        i += 3;
      } else {
        s += 'Q' + (a[i + 1] + (z[i + 1] - a[i + 1]) * t) + ' ' + (a[i + 2] + (z[i + 2] - a[i + 2]) * t) + ' ' +
          (a[i + 3] + (z[i + 3] - a[i + 3]) * t) + ' ' + (a[i + 4] + (z[i + 4] - a[i + 4]) * t);
        i += 5;
      }
    }
    if (e.f) {
      d.push({ f: $lerpFill(e.f[0], e.f[1], t), p: s });
    } else {
      const la = e.l[0], lz = e.l[1];
      d.push({ l: { w: la.w + (lz.w - la.w) * t, c: $lerpColor(la.c, lz.c, t) }, p: s });
    }
  }
  const def = { t: 'shape', r: this.$def.r, d };
  this.$cache = { t, def };
  return def;
};
function $lerpColor(a, b, t) {
  return [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t];
}
function $lerpFill(a, b, t) {
  if (a.c) return { c: $lerpColor(a.c, b.c, t) };
  if (a.g) {
    return {
      g: a.g, m: a.m.map((v, i) => v + (b.m[i] - v) * t),
      s: a.s.map((st, i) => { const e = b.s[i] || st; return [st[0] + (e[0] - st[0]) * t].concat($lerpColor(st.slice(1), e.slice(1), t)); }),
    };
  }
  return a;
}
$MorphShape.prototype.$contentBounds = function (m) { return $boundsOf(this.$def.r, m); };
$MorphShape.prototype.$draw = function (r, m, cx) { r.drawShapeDef(this.$lib, this.$shapeDef(), m, cx); };
$MorphShape.prototype.$hitSelf = function (x, y, m) { return $hitShapeDef(this.$shapeDef(), x, y, m); };

// Embedded video (DefineVideoStream), converted to MP4 by tools/build_assets.py. The timeline
// drives the frame number through the placement "ratio"; the <video> element plays in real
// time and is re-synchronised when it drifts.
const $activeVideos = new Set();
function $Video(lib, id, def) {
  flash_display_DisplayObject.call(this);
  this.$lib = lib;
  this.$vid = id;
  this.$def = def;
  this.$ratio = 0;
  this.$lastRatio = -1;
  this.$el = null;
  this.$drawn = 0;
}
$class($Video, flash_display_DisplayObject, 'flash.media.Video');
$Video.prototype.$contentBounds = function (m) { return $boundsOf([0, 0, this.$def.w, this.$def.h], m); };
$Video.prototype.$element = function () {
  if (!this.$el) {
    const file = this.$lib.json.vid && this.$lib.json.vid[this.$vid];
    if (!file) return null;
    const el = document.createElement('video');
    el.preload = 'auto';
    el.playsInline = true;
    el.src = this.$lib.base + this.$lib.name + '/' + file;
    try {
      // route the soundtrack through the game's master volume (mute button)
      $audio.init();
      $audio.ctx.createMediaElementSource(el).connect($audio.master);
    } catch (e) { /* fall back to the element's own output */ }
    this.$el = el;
  }
  return this.$el;
};
$Video.prototype.$draw = function (r, m, cx) {
  const el = this.$element();
  if (!el) return;
  $activeVideos.add(this);
  this.$drawn = $player.frameCount;
  const fps = ($player.stage && $player.stage.frameRate) || 25;
  const t = this.$ratio / fps;
  if (this.$ratio !== this.$lastRatio) {
    if (el.paused) {
      if (Math.abs(el.currentTime - t) > 0.05) el.currentTime = t;
      const p = el.play();
      if (p && p.catch) p.catch(() => {});
    } else if (Math.abs(el.currentTime - t) > 0.3) {
      el.currentTime = t;
    }
  } else if (!el.paused) {
    el.pause();
  }
  this.$lastRatio = this.$ratio;
  $touch(this);
  if (el.readyState >= 2) {
    const w = this.$def.w, h = this.$def.h;
    r.setT(m);
    const ctx = r.ctx;
    const alpha = cx ? Math.max(0, Math.min(1, cx[3] + cx[7] / 255)) : 1;
    if (alpha !== 1) ctx.globalAlpha = alpha;
    ctx.drawImage(el, 0, 0, w, h, 0, 0, w, h);
    if (alpha !== 1) ctx.globalAlpha = 1;
  }
};
// called by the player after each frame: stop videos that are no longer displayed
function $pauseHiddenVideos() {
  for (const v of $activeVideos) {
    if (v.$drawn !== $player.frameCount) {
      if (v.$el && !v.$el.paused) v.$el.pause();
      v.$lastRatio = -1;
      $activeVideos.delete(v);
    }
  }
}

// Static text (DefineText)
function $StaticText(lib, def) {
  flash_display_DisplayObject.call(this);
  this.$lib = lib;
  this.$def = def;
}
$class($StaticText, flash_display_DisplayObject, 'flash.text.StaticText');
$StaticText.prototype.$contentBounds = function (m) { return $boundsOf(this.$def.r, m); };
$StaticText.prototype.$draw = function (r, m, cx) { r.drawStaticText(this.$lib, this.$def, m, cx); };
$StaticText.prototype.$hitSelf = function (x, y, m) {
  const p = $apply($inv(m), x, y);
  const b = this.$def.r;
  return p[0] >= b[0] && p[0] <= b[2] && p[1] >= b[1] && p[1] <= b[3];
};

// ------------------------------------------------------------------ MovieClip
function flash_display_FrameLabel(name, frame) {
  this.name = name;
  this.frame = frame;
}
$class(flash_display_FrameLabel, null, 'flash.display.FrameLabel');

function flash_display_MovieClip() {
  flash_display_Sprite.call(this);
  this.$frame = 1;
  this.$playing = true;
  this.$sym = null; // {lib, def, id, states, stops}
  this.enabled = true;
  this.$justCreated = true;
  // Subclasses with a linked symbol (created through the library) get their timeline here
  const pending = $pendingSymbol;
  if (pending) {
    $pendingSymbol = null;
    this.$initTimeline(pending.lib, pending.id);
  }
}
$class(flash_display_MovieClip, flash_display_Sprite, 'flash.display.MovieClip');
let $pendingSymbol = null;
const $missingLabels = new Set();

(function (P) {
  $accessor(P, 'currentFrame', { get() { return this.$frame; } });
  $accessor(P, 'totalFrames', { get() { return this.$sym ? this.$sym.def.n || 1 : 1; } });
  $accessor(P, 'framesLoaded', { get() { return this.totalFrames; } });
  $accessor(P, 'currentLabel', {
    get() {
      if (!this.$sym) return null;
      const labels = this.$sym.labelList;
      let best = null;
      for (const l of labels) if (l.frame <= this.$frame) best = l.name;
      return best;
    },
  });
  $accessor(P, 'currentFrameLabel', {
    get() {
      if (!this.$sym) return null;
      for (const l of this.$sym.labelList) if (l.frame === this.$frame) return l.name;
      return null;
    },
  });
  $accessor(P, 'currentLabels', {
    get() {
      if (!this.$sym) return [];
      return this.$sym.labelList.map((l) => new flash_display_FrameLabel(l.name, l.frame));
    },
  });
  $accessor(P, 'isPlaying', { get() { return this.$playing; } });

  P.$initTimeline = function (lib, id) {
    this.$sym = lib.timelineInfo(id);
    this.$frame = 1;
    this.$playing = this.$sym.def.n > 1;
    this.$buildFrame(1, null, true);
    this.$runFrameScript();
  };
  P.play = function () { this.$playing = true; };
  P.stop = function () { this.$playing = false; };
  P.$resolveFrame = function (f) {
    if (typeof f === 'string') {
      if (!this.$sym) return null;
      const n = this.$sym.def.lb ? this.$sym.def.lb[f] : undefined;
      if (n === undefined) {
        // Flash falls back to ToNumber(label) ("" -> 0, "12" -> 12) before giving up
        const asNum = Number(f);
        if (!isNaN(asNum)) return Math.max(1, Math.floor(asNum));
        // The original content asks for some labels that don't exist (e.g. "_special" vs
        // "_specials" in the HUD); the game shipped working, so ignore like the player did.
        const key = this.$sym.lib.name + ':' + this.$sym.id + ':' + f;
        if (!$missingLabels.has(key)) {
          $missingLabels.add(key);
          if ($flags.debug) console.warn('frame label not found:', f, 'in symbol', key);
        }
        return null;
      }
      return n;
    }
    return Math.floor(f);
  };
  P.gotoAndStop = function (f) {
    const n = this.$resolveFrame(f);
    this.$playing = false;
    if (n != null) this.$goto(n);
  };
  P.gotoAndPlay = function (f) {
    const n = this.$resolveFrame(f);
    this.$playing = true;
    if (n != null) this.$goto(n);
  };
  P.nextFrame = function () { this.$playing = false; this.$goto(this.$frame + 1); };
  P.prevFrame = function () { this.$playing = false; this.$goto(this.$frame - 1); };
  P.addFrameScript = function (...args) {
    if (!this.$extraScripts) this.$extraScripts = {};
    for (let i = 0; i < args.length; i += 2) this.$extraScripts[args[i] + 1] = args[i + 1];
  };
  P.$goto = function (n) {
    if (!this.$sym) return;
    const total = this.$sym.def.n || 1;
    if (n < 1) n = 1;
    if (n > total) n = total;
    if (n === this.$frame) return;
    const old = this.$frame;
    this.$frame = n;
    this.$buildFrame(n, old, false);
    this.$runFrameScript();
  };
  P.$runFrameScript = function () {
    const stops = this.$sym.stops;
    if (stops && stops.has(this.$frame)) this.$playing = false;
    if (this.$extraScripts && this.$extraScripts[this.$frame]) this.$extraScripts[this.$frame].call(this);
  };
  // advance one frame (called by the player loop)
  P.$advance = function () {
    if (!this.$playing || !this.$sym) return;
    const total = this.$sym.def.n || 1;
    if (total <= 1) return;
    const next = this.$frame >= total ? 1 : this.$frame + 1;
    const old = this.$frame;
    this.$frame = next;
    this.$buildFrame(next, old, false);
    this.$runFrameScript();
  };
  P.$buildFrame = function (frame, oldFrame, initial) {
    const sym = this.$sym;
    const states = sym.lib.frameStates(sym.id);
    const ns = states[frame - 1];
    const os = oldFrame ? states[oldFrame - 1] : null;
    if (ns !== os) $touch(this);
    // existing timeline children by depth
    const byDepth = new Map();
    for (const c of this.$children) if (c.$depth !== null && c.$timeline === this) byDepth.set(c.$depth, c);
    // remove/update
    for (const [d, c] of byDepth) {
      const rec = ns.get(d);
      if (rec && rec.id === c.$charId && rec.pf === c.$pf) {
        const oldRec = os ? os.get(d) : null;
        if (rec !== oldRec) this.$applyRecord(c, rec, false);
      } else {
        this.$removeTimelineChild(c);
        byDepth.delete(d);
      }
    }
    // create new
    for (const [d, rec] of ns) {
      if (byDepth.has(d)) continue;
      const c = sym.lib.createCharacter(rec.id);
      if (!c) continue;
      c.$depth = d;
      c.$timeline = this;
      c.$charId = rec.id;
      c.$pf = rec.pf;
      if (rec.nm) c.$name = rec.nm;
      this.$applyRecord(c, rec, true);
      // insert by depth
      let idx = this.$children.length;
      for (let i = 0; i < this.$children.length; i++) {
        const o = this.$children[i];
        if (o.$depth !== null && o.$timeline === this && o.$depth > d) { idx = i; break; }
      }
      this.addChildAt(c, idx);
      if (rec.nm && $canAssignChildProp(this, rec.nm)) this[rec.nm] = c;
    }
    // clip-depth masks
    this.$hasClips = false;
    for (const c of this.$children) if (c.$clipDepth) { this.$hasClips = true; break; }
    // timeline sounds
    const snd = sym.sounds && sym.sounds[frame];
    if (snd && !initial) for (const s of snd) sym.lib.playTimelineSound(s);
    else if (snd && initial) for (const s of snd) sym.lib.playTimelineSound(s);
  };
  P.$applyRecord = function (c, rec, isNew) {
    if (isNew || !c.$scripted) {
      c.$setMatrix(rec.m || $ID);
      c.$scripted = false;
    }
    if (isNew || !c.$scriptedCx) {
      c.$cx = rec.cx || null;
    }
    if (rec.ra !== undefined && (c instanceof $MorphShape || c instanceof $Video)) c.$ratio = rec.ra;
    c.$clipDepth = rec.clip || 0;
    c.$isClipMask = !!rec.clip;
    if (isNew || !c.$scriptedFilters) {
      c.$filters = rec.fl ? rec.fl.map($filterFromRecord).filter(Boolean) : null;
    }
    c.$blend = rec.bl ? $BLEND_NAMES[rec.bl] : null;
    if (rec.vis !== undefined) c.$visible = !!rec.vis;
  };
  P.$removeTimelineChild = function (c) {
    if (c.$parent === this) this.removeChild(c);
    const nm = c.$name;
    if (nm && this[nm] === c && $canAssignChildProp(this, nm)) this[nm] = null;
  };
})(flash_display_MovieClip.prototype);

const $BLEND_NAMES = [null, null, 'layer', 'multiply', 'screen', 'lighten', 'darken', 'difference', 'add', 'subtract',
  'invert', 'alpha', 'erase', 'overlay', 'hardlight'];

function $filterFromRecord(f) {
  const rgb = (c) => (c[0] << 16) | (c[1] << 8) | c[2];
  switch (f.t) {
    case 'glow':
      return new flash_filters_GlowFilter(rgb(f.c), f.c[3] / 255, f.bx, f.by, f.s, f.q || 1, !!f.in, !!f.ko);
    case 'ds':
      return new flash_filters_DropShadowFilter(f.d, f.a / $DEG, rgb(f.c), f.c[3] / 255, f.bx, f.by, f.s, f.q || 1, !!f.in, !!f.ko);
    case 'blur':
      return new flash_filters_BlurFilter(f.bx, f.by, f.q || 1);
    case 'bevel':
      if (!f.hc) return null;
      return new flash_filters_BevelFilter(f.d, f.a / $DEG, rgb(f.hc), f.hc[3] / 255, rgb(f.sc), f.sc[3] / 255, f.bx, f.by, f.s,
        f.q || 1, f.in ? 'inner' : (f.top ? 'full' : 'outer'), !!f.ko);
    case 'cm':
      return new flash_filters_ColorMatrixFilter(f.m);
    default:
      return null;
  }
}

// Properties that must never be shadowed by timeline instance names.
function $canAssignChildProp(obj, name) {
  if (name in flash_display_MovieClip.prototype) return false;
  const d = Object.getOwnPropertyDescriptor(obj, name);
  if (d && (d.get || d.set)) return false;
  // a class defined accessor on a subclass prototype
  let p = Object.getPrototypeOf(obj);
  while (p && p !== flash_display_MovieClip.prototype) {
    const pd = Object.getOwnPropertyDescriptor(p, name);
    if (pd && (pd.get || pd.set || typeof pd.value === 'function')) return false;
    p = Object.getPrototypeOf(p);
  }
  return true;
}

// ------------------------------------------------------------------ SimpleButton
function flash_display_SimpleButton(lib, def) {
  flash_display_InteractiveObject.call(this);
  this.useHandCursor = true;
  this.enabled = true;
  this.trackAsMenu = false;
  this.$state = 'up';
  this.$states = {};
  this.$children = [];
  if (lib && def) {
    for (const st of ['up', 'over', 'down', 'hit']) {
      const bit = { up: 1, over: 2, down: 4, hit: 8 }[st];
      const c = new flash_display_Sprite();
      const recs = def.recs.filter((r) => r.s & bit).sort((a, b) => a.dp - b.dp);
      for (const r of recs) {
        const o = lib.createCharacter(r.id);
        if (!o) continue;
        o.$setMatrix(r.m);
        o.$cx = r.cx || null;
        if (r.fl) o.$filters = r.fl.map($filterFromRecord).filter(Boolean);
        if (r.bl) o.$blend = $BLEND_NAMES[r.bl];
        c.addChild(o);
      }
      this.$states[st] = c;
    }
  }
  this.$setVisualState('up');
}
$class(flash_display_SimpleButton, flash_display_InteractiveObject, 'flash.display.SimpleButton');
(function (P) {
  P.$setVisualState = function (s) {
    if (this.$state !== s) $touch(this);
    this.$state = s;
    const c = this.$states[s];
    for (const old of this.$children) old.$parent = null;
    this.$children = c ? [c] : [];
    if (c) c.$parent = this;
  };
  $accessor(P, 'upState', { get() { return this.$states.up; }, set(v) { this.$states.up = v; if (this.$state === 'up') this.$setVisualState('up'); } });
  $accessor(P, 'overState', { get() { return this.$states.over; }, set(v) { this.$states.over = v; } });
  $accessor(P, 'downState', { get() { return this.$states.down; }, set(v) { this.$states.down = v; } });
  $accessor(P, 'hitTestState', { get() { return this.$states.hit; }, set(v) { this.$states.hit = v; } });
  P.$bounds = function (m) {
    const c = this.$states[this.$state] || this.$states.up;
    return c ? c.$bounds($mul(c.$m, m)) : null;
  };
})(flash_display_SimpleButton.prototype);

// ------------------------------------------------------------------ Bitmap / BitmapData
function flash_display_BitmapData(width, height, transparent = true, fill = 0xffffffff) {
  this.$canvas = document.createElement('canvas');
  this.$canvas.width = Math.max(1, width | 0);
  this.$canvas.height = Math.max(1, height | 0);
  this.$ctx = this.$canvas.getContext('2d', { willReadFrequently: true });
  this.transparent = transparent;
  this.$version = 0;
  this.$imageData = null; // pending pixel edits
  if (width > 0 && height > 0 && fill !== undefined) {
    if (!transparent) fill = (fill | 0xff000000) >>> 0;
    const a = ((fill >>> 24) & 255) / 255;
    if (a > 0) {
      this.$ctx.fillStyle = 'rgba(' + ((fill >> 16) & 255) + ',' + ((fill >> 8) & 255) + ',' + (fill & 255) + ',' + a + ')';
      this.$ctx.fillRect(0, 0, width, height);
    }
  }
}
$class(flash_display_BitmapData, null, 'flash.display.BitmapData');
let $renderCount = 0;
(function (P) {
  // pixels changed: bump the version and invalidate caches of the Bitmaps showing us
  // (at most once between two renders, as setPixel32 may be called thousands of times)
  P.$changed = function () {
    this.$version++;
    if (this.$touchedAt === $renderCount || !this.$owners) return;
    this.$touchedAt = $renderCount;
    for (const o of this.$owners) $touch(o);
  };
  $accessor(P, 'width', { get() { return this.$canvas.width; } });
  $accessor(P, 'height', { get() { return this.$canvas.height; } });
  $accessor(P, 'rect', { get() { return new flash_geom_Rectangle(0, 0, this.$canvas.width, this.$canvas.height); } });
  P.$commit = function () {
    if (this.$imageData) {
      this.$ctx.putImageData(this.$imageData, 0, 0);
      this.$imageData = null;
    }
  };
  P.$pixels = function () {
    if (!this.$imageData) this.$imageData = this.$ctx.getImageData(0, 0, this.$canvas.width, this.$canvas.height);
    return this.$imageData;
  };
  P.$source = function () {
    this.$commit();
    return this.$canvas;
  };
  P.setPixel32 = function (x, y, c) {
    x |= 0; y |= 0;
    if (x < 0 || y < 0 || x >= this.$canvas.width || y >= this.$canvas.height) return;
    const d = this.$pixels().data;
    const i = (y * this.$canvas.width + x) * 4;
    d[i] = (c >> 16) & 255; d[i + 1] = (c >> 8) & 255; d[i + 2] = c & 255;
    d[i + 3] = this.transparent ? (c >>> 24) & 255 : 255;
    this.$changed();
  };
  P.setPixel = function (x, y, c) { this.setPixel32(x, y, (c & 0xffffff) | 0xff000000); };
  P.getPixel32 = function (x, y) {
    x |= 0; y |= 0;
    if (x < 0 || y < 0 || x >= this.$canvas.width || y >= this.$canvas.height) return 0;
    const d = this.$pixels().data;
    const i = (y * this.$canvas.width + x) * 4;
    return ((d[i + 3] << 24) | (d[i] << 16) | (d[i + 1] << 8) | d[i + 2]) >>> 0;
  };
  P.getPixel = function (x, y) { return this.getPixel32(x, y) & 0xffffff; };
  P.fillRect = function (r, c) {
    this.$commit();
    const a = this.transparent ? ((c >>> 24) & 255) / 255 : 1;
    this.$ctx.clearRect(r.x, r.y, r.width, r.height);
    if (a > 0) {
      this.$ctx.fillStyle = 'rgba(' + ((c >> 16) & 255) + ',' + ((c >> 8) & 255) + ',' + (c & 255) + ',' + a + ')';
      this.$ctx.fillRect(r.x, r.y, r.width, r.height);
    }
    this.$changed();
  };
  P.copyPixels = function (src, rect, pt) {
    this.$commit();
    const s = src.$source ? src.$source() : src;
    this.$ctx.clearRect(pt.x, pt.y, rect.width, rect.height);
    this.$ctx.drawImage(s, rect.x, rect.y, rect.width, rect.height, pt.x, pt.y, rect.width, rect.height);
    this.$changed();
  };
  P.draw = function (source, matrix = null, ct = null) {
    this.$commit();
    const m = matrix ? [matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty] : [1, 0, 0, 1, 0, 0];
    const cx = ct ? ct.$toArray() : null;
    if (source instanceof flash_display_BitmapData) {
      const img = cx ? $recolor(source.$source(), cx, source) : source.$source();
      this.$ctx.save();
      this.$ctx.setTransform(m[0], m[1], m[2], m[3], m[4], m[5]);
      this.$ctx.drawImage(img, 0, 0);
      this.$ctx.restore();
    } else if (source instanceof flash_display_DisplayObject) {
      const r = new $Renderer(this.$ctx, 1);
      r.renderObject(source, m, cx, true);
    }
    this.$changed();
  };
  P.colorTransform = function (rect, ct) {
    const d = this.$pixels().data;
    const w = this.$canvas.width;
    const x0 = Math.max(0, rect.x | 0), y0 = Math.max(0, rect.y | 0);
    const x1 = Math.min(w, (rect.x + rect.width) | 0), y1 = Math.min(this.$canvas.height, (rect.y + rect.height) | 0);
    for (let y = y0; y < y1; y++) {
      for (let x = x0; x < x1; x++) {
        const i = (y * w + x) * 4;
        d[i] = d[i] * ct.redMultiplier + ct.redOffset;
        d[i + 1] = d[i + 1] * ct.greenMultiplier + ct.greenOffset;
        d[i + 2] = d[i + 2] * ct.blueMultiplier + ct.blueOffset;
        d[i + 3] = d[i + 3] * ct.alphaMultiplier + ct.alphaOffset;
      }
    }
    this.$changed();
  };
  P.lock = function () {};
  P.unlock = function () { this.$commit(); };
  P.clone = function () {
    const b = new flash_display_BitmapData(this.width, this.height, this.transparent, 0);
    b.$ctx.drawImage(this.$source(), 0, 0);
    return b;
  };
  P.dispose = function () {};
  P.applyFilter = function () {};
  P.threshold = function () { return 0; };
  P.noise = function () {};
  P.scroll = function (dx, dy) {
    this.$commit();
    const c = document.createElement('canvas');
    c.width = this.$canvas.width; c.height = this.$canvas.height;
    c.getContext('2d').drawImage(this.$canvas, 0, 0);
    this.$ctx.clearRect(0, 0, c.width, c.height);
    this.$ctx.drawImage(c, dx, dy);
  };
})(flash_display_BitmapData.prototype);

function flash_display_Bitmap(bitmapData = null, pixelSnapping = 'auto', smoothing = false) {
  flash_display_DisplayObject.call(this);
  this.$bmd = null;
  this.bitmapData = bitmapData;
  this.pixelSnapping = pixelSnapping;
  this.smoothing = smoothing;
}
$class(flash_display_Bitmap, flash_display_DisplayObject, 'flash.display.Bitmap');
$accessor(flash_display_Bitmap.prototype, 'bitmapData', {
  get() { return this.$bmd; },
  set(v) {
    if (this.$bmd && this.$bmd.$owners) this.$bmd.$owners.delete(this);
    this.$bmd = v || null;
    if (v) {
      if (!v.$owners) v.$owners = new Set();
      v.$owners.add(this);
    }
    $touch(this);
  },
});
flash_display_Bitmap.prototype.$contentBounds = function (m) {
  if (!this.bitmapData) return null;
  return $boundsOf([0, 0, this.bitmapData.width, this.bitmapData.height], m);
};
flash_display_Bitmap.prototype.$draw = function (r, m, cx) {
  if (this.bitmapData) r.drawBitmap(this.bitmapData, m, cx, this.smoothing);
};
flash_display_Bitmap.prototype.$hitSelf = function (x, y, m) {
  if (!this.bitmapData) return false;
  const p = $apply($inv(m), x, y);
  return p[0] >= 0 && p[1] >= 0 && p[0] < this.bitmapData.width && p[1] < this.bitmapData.height;
};
function mx_core_BitmapAsset(bmd) {
  flash_display_Bitmap.call(this, bmd || null);
}
$class(mx_core_BitmapAsset, flash_display_Bitmap, 'mx.core.BitmapAsset');

// ------------------------------------------------------------------ Loader (only used for structure)
function flash_display_Loader() {
  flash_display_DisplayObjectContainer.call(this);
  this.contentLoaderInfo = new flash_events_EventDispatcher();
}
$class(flash_display_Loader, flash_display_DisplayObjectContainer, 'flash.display.Loader');
function flash_display_LoaderInfo() {}
$class(flash_display_LoaderInfo, null, 'flash.display.LoaderInfo');

const flash_display_BlendMode = {
  NORMAL: 'normal', ADD: 'add', MULTIPLY: 'multiply', SCREEN: 'screen', LAYER: 'layer', OVERLAY: 'overlay', ERASE: 'erase',
  ALPHA: 'alpha', LIGHTEN: 'lighten', DARKEN: 'darken', DIFFERENCE: 'difference', HARDLIGHT: 'hardlight', INVERT: 'invert',
  SUBTRACT: 'subtract',
};
const flash_display_StageScaleMode = { NO_SCALE: 'noScale', SHOW_ALL: 'showAll', EXACT_FIT: 'exactFit', NO_BORDER: 'noBorder' };
const flash_display_StageAlign = { TOP_LEFT: 'TL', TOP: 'T' };
const flash_display_StageQuality = { HIGH: 'high', MEDIUM: 'medium', LOW: 'low', BEST: 'best' };

// ------------------------------------------------------------------ Stage
function flash_display_Stage() {
  flash_display_DisplayObjectContainer.call(this);
  this.stageWidth = 700;
  this.stageHeight = 545;
  this.frameRate = 25;
  this.scaleMode = 'showAll';
  this.align = '';
  this.quality = 'high';
  this.$focus = null;
  this.$name = 'stage';
}
$class(flash_display_Stage, flash_display_DisplayObjectContainer, 'flash.display.Stage');
$accessor(flash_display_Stage.prototype, 'focus', {
  get() { return this.$focus; },
  set(v) {
    if (this.$focus === v) return;
    const old = this.$focus;
    this.$focus = v;
    if (old && old.$onBlur) old.$onBlur();
    if (old) old.dispatchEvent(new flash_events_FocusEvent('focusOut'));
    if (v) v.dispatchEvent(new flash_events_FocusEvent('focusIn'));
  },
});
$accessor(flash_display_Stage.prototype, 'height', { get() { return this.stageHeight; }, set(v) {} });
$accessor(flash_display_Stage.prototype, 'width', { get() { return this.stageWidth; }, set(v) {} });

// ------------------------------------------------------------------ hit testing helpers
let $hitCtx = null;
function $getHitCtx() {
  if (!$hitCtx) {
    const c = document.createElement('canvas');
    c.width = c.height = 1;
    $hitCtx = c.getContext('2d');
  }
  return $hitCtx;
}
const $path2dCache = new WeakMap();
function $pathOf(entry) {
  let p = $path2dCache.get(entry);
  if (!p) {
    p = new Path2D(entry.p);
    $path2dCache.set(entry, p);
  }
  return p;
}
function $hitShapeDef(def, x, y, m) {
  const p = $apply($inv(m), x, y);
  const r = def.r;
  if (p[0] < r[0] || p[0] > r[2] || p[1] < r[1] || p[1] > r[3]) return false;
  const ctx = $getHitCtx();
  for (const e of def.d) {
    const path = $pathOf(e);
    if (e.f) {
      if (ctx.isPointInPath(path, p[0], p[1], 'evenodd')) return true;
    } else if (e.l) {
      ctx.lineWidth = Math.max(e.l.w, 1);
      if (ctx.isPointInStroke(path, p[0], p[1])) return true;
    }
  }
  return false;
}
function $hitGraphics(g, x, y, m) {
  if (!g.$bounds) return false;
  const p = $apply($inv(m), x, y);
  const b = g.$bounds;
  if (p[0] < b[0] || p[0] > b[2] || p[1] < b[1] || p[1] > b[3]) return false;
  const ctx = $getHitCtx();
  for (const c of g.$all()) {
    if (c.fill) {
      if (ctx.isPointInPath(c.path, p[0], p[1], 'nonzero')) return true;
    } else if (c.line) {
      ctx.lineWidth = Math.max(c.line.w, 1);
      if (ctx.isPointInStroke(c.path, p[0], p[1])) return true;
    }
  }
  return false;
}
// Does obj (with parent global matrix pm) have visible content at x,y?
function $hitContent(obj, x, y, pm, ignoreVisible) {
  if (!ignoreVisible && !obj.$visible) return false;
  const m = $mul(obj.$m, pm);
  if (obj.$mask && !$hitContent(obj.$mask, x, y, obj.$mask.$parent ? obj.$mask.$parent.$globalMatrix() : pm, true)) return false;
  if (obj.$hitSelf(x, y, m)) return true;
  const ch = obj instanceof flash_display_SimpleButton ? [obj.$states.hit || obj.$states.up].filter(Boolean) : obj.$children;
  if (ch) {
    for (let i = ch.length - 1; i >= 0; i--) {
      const c = ch[i];
      if (c.$maskOf || c.$isClipMask) continue;
      if (!$clipAllows(obj, i, x, y, m)) continue;
      if ($hitContent(c, x, y, m, false)) return true;
    }
  }
  return false;
}
// timeline clip-depth masks: child i of container must be inside any mask that covers its depth
function $clipAllows(container, i, x, y, m) {
  if (!container.$hasClips) return true;
  const ch = container.$children;
  const c = ch[i];
  if (c.$depth === null) return true;
  for (let k = 0; k < i; k++) {
    const mk = ch[k];
    if (mk.$clipDepth && mk.$depth < c.$depth && c.$depth <= mk.$clipDepth) {
      return $hitContent(mk, x, y, m, true);
    }
  }
  return true;
}
// Find the InteractiveObject that should receive mouse events at x,y (Flash/AVM2 rules).
// Returns the target, $PROPAGATE (something was hit but its owner isn't mouseEnabled, so the
// nearest enabled ancestor receives it unless a lower sibling claims the hit) or null (miss).
const $PROPAGATE = { propagate: true };
function $findTarget(obj, x, y, pm) {
  const r = $pick(obj, x, y, pm);
  return r === $PROPAGATE ? null : r;
}
function $pick(obj, x, y, pm) {
  if (!obj.$visible || obj.$maskOf || obj.$isClipMask) return null;
  const m = $mul(obj.$m, pm);
  if (obj.$mask && !$hitContent(obj.$mask, x, y, obj.$mask.$parent ? obj.$mask.$parent.$globalMatrix() : pm, true)) return null;
  if (obj instanceof flash_display_SimpleButton) {
    const hs = obj.$states.hit || obj.$states.up;
    if (hs && $hitContent(hs, x, y, m, true)) return obj.mouseEnabled ? obj : $PROPAGATE;
    return null;
  }
  if (obj instanceof flash_text_TextField) {
    if (!obj.$hitSelf(x, y, m)) return null;
    return obj.mouseEnabled ? obj : $PROPAGATE;
  }
  if (!obj.$children) {
    // non-interactive leaf (Shape, Bitmap, ...)
    return obj.$hitSelf(x, y, m) ? $PROPAGATE : null;
  }
  const self = obj.mouseEnabled ? obj : $PROPAGATE;
  if (obj.hitArea) {
    const ha = obj.hitArea;
    return $hitContent(ha, x, y, ha.$parent ? ha.$parent.$globalMatrix() : m, true) ? self : null;
  }
  if (!obj.mouseChildren) {
    return $hitContent(obj, x, y, pm, false) ? self : null;
  }
  let propagate = false;
  const ch = obj.$children;
  for (let i = ch.length - 1; i >= 0; i--) {
    const c = ch[i];
    if (!c.$visible || c.$maskOf || c.$isClipMask) continue;
    if (!$clipAllows(obj, i, x, y, m)) continue;
    if (c instanceof flash_display_InteractiveObject) {
      const t = $pick(c, x, y, m);
      if (t === $PROPAGATE) propagate = true;
      else if (t) return t;
    } else if ($hitContent(c, x, y, m, false)) {
      if (obj.mouseEnabled) return obj;
      propagate = true;
    }
  }
  if (propagate) return self;
  if (obj.$hitSelf(x, y, m)) return self;
  return null;
}
