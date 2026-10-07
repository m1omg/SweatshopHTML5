// Minimal re-implementation of the parts of the Flash Player API used by Sweatshop.
// Events, geometry, utilities.
'use strict';

// ------------------------------------------------------------------ events
function flash_events_Event(type, bubbles = false, cancelable = false) {
  this.type = type;
  this.bubbles = bubbles;
  this.cancelable = cancelable;
  this.target = null;
  this.currentTarget = null;
  this.eventPhase = 2;
  this.$stop = false;
  this.$stopNow = false;
  this.$prevented = false;
}
$class(flash_events_Event, null, 'flash.events.Event');
Object.assign(flash_events_Event, {
  ENTER_FRAME: 'enterFrame', EXIT_FRAME: 'exitFrame', ADDED_TO_STAGE: 'addedToStage', REMOVED_FROM_STAGE: 'removedFromStage',
  ADDED: 'added', REMOVED: 'removed', COMPLETE: 'complete', CHANGE: 'change', INIT: 'init', OPEN: 'open',
  CLOSE: 'close', RESIZE: 'resize', SOUND_COMPLETE: 'soundComplete', ACTIVATE: 'activate', DEACTIVATE: 'deactivate',
  SELECT: 'select', CANCEL: 'cancel', RENDER: 'render', MOUSE_LEAVE: 'mouseLeave', TAB_CHILDREN_CHANGE: 'tabChildrenChange',
});
flash_events_Event.prototype.clone = function () {
  return new this.constructor(this.type, this.bubbles, this.cancelable);
};
flash_events_Event.prototype.stopPropagation = function () { this.$stop = true; };
flash_events_Event.prototype.stopImmediatePropagation = function () { this.$stop = true; this.$stopNow = true; };
flash_events_Event.prototype.preventDefault = function () { this.$prevented = true; };
flash_events_Event.prototype.isDefaultPrevented = function () { return this.$prevented; };
flash_events_Event.prototype.toString = function () { return '[Event type="' + this.type + '"]'; };

function flash_events_MouseEvent(type, bubbles = true, cancelable = false, localX = 0, localY = 0) {
  flash_events_Event.call(this, type, bubbles, cancelable);
  this.localX = localX;
  this.localY = localY;
  this.stageX = 0;
  this.stageY = 0;
  this.shiftKey = false;
  this.ctrlKey = false;
  this.altKey = false;
  this.buttonDown = false;
  this.delta = 0;
  this.relatedObject = null;
}
$class(flash_events_MouseEvent, flash_events_Event, 'flash.events.MouseEvent');
Object.assign(flash_events_MouseEvent, {
  CLICK: 'click', MOUSE_DOWN: 'mouseDown', MOUSE_UP: 'mouseUp', MOUSE_MOVE: 'mouseMove', MOUSE_OVER: 'mouseOver',
  MOUSE_OUT: 'mouseOut', ROLL_OVER: 'rollOver', ROLL_OUT: 'rollOut', MOUSE_WHEEL: 'mouseWheel', DOUBLE_CLICK: 'doubleClick',
});
flash_events_MouseEvent.prototype.updateAfterEvent = function () {};
flash_events_MouseEvent.prototype.clone = function () {
  const e = new flash_events_MouseEvent(this.type, this.bubbles, this.cancelable, this.localX, this.localY);
  e.stageX = this.stageX; e.stageY = this.stageY;
  return e;
};

function flash_events_KeyboardEvent(type, bubbles = true, cancelable = false, charCode = 0, keyCode = 0) {
  flash_events_Event.call(this, type, bubbles, cancelable);
  this.charCode = charCode;
  this.keyCode = keyCode;
  this.shiftKey = false;
  this.ctrlKey = false;
  this.altKey = false;
}
$class(flash_events_KeyboardEvent, flash_events_Event, 'flash.events.KeyboardEvent');
flash_events_KeyboardEvent.KEY_DOWN = 'keyDown';
flash_events_KeyboardEvent.KEY_UP = 'keyUp';

function flash_events_TimerEvent(type, bubbles = false, cancelable = false) {
  flash_events_Event.call(this, type, bubbles, cancelable);
}
$class(flash_events_TimerEvent, flash_events_Event, 'flash.events.TimerEvent');
flash_events_TimerEvent.TIMER = 'timer';
flash_events_TimerEvent.TIMER_COMPLETE = 'timerComplete';

function flash_events_TextEvent(type, bubbles = false, cancelable = false, text = '') {
  flash_events_Event.call(this, type, bubbles, cancelable);
  this.text = text;
}
$class(flash_events_TextEvent, flash_events_Event, 'flash.events.TextEvent');
flash_events_TextEvent.TEXT_INPUT = 'textInput';
flash_events_TextEvent.LINK = 'link';

function flash_events_FocusEvent(type, bubbles = true, cancelable = false) {
  flash_events_Event.call(this, type, bubbles, cancelable);
}
$class(flash_events_FocusEvent, flash_events_Event, 'flash.events.FocusEvent');
flash_events_FocusEvent.FOCUS_IN = 'focusIn';
flash_events_FocusEvent.FOCUS_OUT = 'focusOut';

function flash_events_IOErrorEvent(type, bubbles = false, cancelable = false, text = '') {
  flash_events_Event.call(this, type, bubbles, cancelable);
  this.text = text;
}
$class(flash_events_IOErrorEvent, flash_events_Event, 'flash.events.IOErrorEvent');
flash_events_IOErrorEvent.IO_ERROR = 'ioError';

function flash_events_ProgressEvent(type, bubbles = false, cancelable = false, loaded = 0, total = 0) {
  flash_events_Event.call(this, type, bubbles, cancelable);
  this.bytesLoaded = loaded;
  this.bytesTotal = total;
}
$class(flash_events_ProgressEvent, flash_events_Event, 'flash.events.ProgressEvent');
flash_events_ProgressEvent.PROGRESS = 'progress';

function flash_events_IEventDispatcher() {}
$interface(flash_events_IEventDispatcher, 'flash.events.IEventDispatcher', []);

function flash_events_EventDispatcher() {
  this.$listeners = null;
}
$class(flash_events_EventDispatcher, null, 'flash.events.EventDispatcher', [flash_events_IEventDispatcher]);

// Global registry of objects listening to ENTER_FRAME (Flash broadcasts this to every listener).
const $enterFrameListeners = new Set();

flash_events_EventDispatcher.prototype.addEventListener = function (type, fn, useCapture = false, priority = 0) {
  if (typeof fn !== 'function') return;
  if (!this.$listeners) this.$listeners = {};
  const key = useCapture ? '$c_' + type : type;
  let list = this.$listeners[key];
  if (!list) list = this.$listeners[key] = [];
  for (const l of list) if (l.fn === fn) return;
  list.push({ fn, priority });
  if (priority) list.sort((a, b) => b.priority - a.priority);
  if (type === 'enterFrame' || type === 'exitFrame') $enterFrameListeners.add(this);
};

flash_events_EventDispatcher.prototype.removeEventListener = function (type, fn, useCapture = false) {
  if (!this.$listeners) return;
  const key = useCapture ? '$c_' + type : type;
  const list = this.$listeners[key];
  if (!list) return;
  for (let i = 0; i < list.length; i++) {
    if (list[i].fn === fn) {
      // copy-on-write so dispatch in progress is unaffected
      this.$listeners[key] = list.slice(0, i).concat(list.slice(i + 1));
      break;
    }
  }
  if ((type === 'enterFrame' || type === 'exitFrame') && !(this.$listeners.enterFrame && this.$listeners.enterFrame.length) &&
      !(this.$listeners.exitFrame && this.$listeners.exitFrame.length)) {
    $enterFrameListeners.delete(this);
  }
};

flash_events_EventDispatcher.prototype.hasEventListener = function (type) {
  return !!(this.$listeners && ((this.$listeners[type] && this.$listeners[type].length) ||
    (this.$listeners['$c_' + type] && this.$listeners['$c_' + type].length)));
};
flash_events_EventDispatcher.prototype.willTrigger = function (type) {
  let o = this;
  while (o) {
    if (o.hasEventListener && o.hasEventListener(type)) return true;
    o = o.$parent;
  }
  return false;
};

flash_events_EventDispatcher.prototype.$invoke = function (e, capture) {
  if (!this.$listeners) return;
  const list = this.$listeners[capture ? '$c_' + e.type : e.type];
  if (!list || !list.length) return;
  e.currentTarget = this;
  for (const l of list) {
    l.fn.call(null, e);
    if (e.$stopNow) break;
  }
};

flash_events_EventDispatcher.prototype.dispatchEvent = function (e) {
  if (e.target) {
    // re-dispatching an event: Flash clones it
    e = e.clone();
  }
  e.target = this;
  if (e.bubbles || this.$parent) {
    // build propagation path for display objects
    const path = [];
    let p = this.$parent;
    while (p) { path.push(p); p = p.$parent; }
    if (path.length) {
      e.eventPhase = 1;
      for (let i = path.length - 1; i >= 0; i--) {
        path[i].$invoke(e, true);
        if (e.$stop) return !e.$prevented;
      }
    }
    e.eventPhase = 2;
    this.$invoke(e, false);
    if (e.$stop) return !e.$prevented;
    if (e.bubbles) {
      e.eventPhase = 3;
      for (const o of path) {
        o.$invoke(e, false);
        if (e.$stop) break;
      }
    }
  } else {
    e.eventPhase = 2;
    this.$invoke(e, false);
  }
  return !e.$prevented;
};
flash_events_EventDispatcher.prototype.toString = function () {
  return '[object ' + (this.constructor.$fq || 'Object').split('.').pop() + ']';
};

// ------------------------------------------------------------------ errors
function flash_errors_IllegalOperationError(message = '') {
  const e = new Error(message);
  e.name = 'IllegalOperationError';
  return e;
}
flash_errors_IllegalOperationError.$fq = 'flash.errors.IllegalOperationError';

// ------------------------------------------------------------------ geometry
function flash_geom_Point(x = 0, y = 0) {
  this.x = x;
  this.y = y;
}
$class(flash_geom_Point, null, 'flash.geom.Point');
$accessor(flash_geom_Point.prototype, 'length', { get() { return Math.sqrt(this.x * this.x + this.y * this.y); } });
flash_geom_Point.prototype.add = function (p) { return new flash_geom_Point(this.x + p.x, this.y + p.y); };
flash_geom_Point.prototype.subtract = function (p) { return new flash_geom_Point(this.x - p.x, this.y - p.y); };
flash_geom_Point.prototype.clone = function () { return new flash_geom_Point(this.x, this.y); };
flash_geom_Point.prototype.equals = function (p) { return p && p.x === this.x && p.y === this.y; };
flash_geom_Point.prototype.normalize = function (len) {
  const l = this.length;
  if (l > 0) { this.x = this.x / l * len; this.y = this.y / l * len; }
};
flash_geom_Point.prototype.offset = function (dx, dy) { this.x += dx; this.y += dy; };
flash_geom_Point.prototype.setTo = function (x, y) { this.x = x; this.y = y; };
flash_geom_Point.prototype.toString = function () { return '(x=' + this.x + ', y=' + this.y + ')'; };
flash_geom_Point.distance = function (a, b) { return Math.sqrt((a.x - b.x) ** 2 + (a.y - b.y) ** 2); };
flash_geom_Point.interpolate = function (a, b, f) {
  return new flash_geom_Point(b.x + (a.x - b.x) * f, b.y + (a.y - b.y) * f);
};
flash_geom_Point.polar = function (len, ang) { return new flash_geom_Point(len * Math.cos(ang), len * Math.sin(ang)); };

function flash_geom_Rectangle(x = 0, y = 0, width = 0, height = 0) {
  this.x = x;
  this.y = y;
  this.width = width;
  this.height = height;
}
$class(flash_geom_Rectangle, null, 'flash.geom.Rectangle');
(function (P) {
  $accessor(P, 'left', { get() { return this.x; }, set(v) { this.width += this.x - v; this.x = v; } });
  $accessor(P, 'right', { get() { return this.x + this.width; }, set(v) { this.width = v - this.x; } });
  $accessor(P, 'top', { get() { return this.y; }, set(v) { this.height += this.y - v; this.y = v; } });
  $accessor(P, 'bottom', { get() { return this.y + this.height; }, set(v) { this.height = v - this.y; } });
  $accessor(P, 'topLeft', { get() { return new flash_geom_Point(this.x, this.y); } });
  $accessor(P, 'bottomRight', { get() { return new flash_geom_Point(this.x + this.width, this.y + this.height); } });
  $accessor(P, 'size', { get() { return new flash_geom_Point(this.width, this.height); } });
  P.contains = function (x, y) { return x >= this.x && x < this.x + this.width && y >= this.y && y < this.y + this.height; };
  P.containsPoint = function (p) { return this.contains(p.x, p.y); };
  P.containsRect = function (r) {
    return r.x >= this.x && r.y >= this.y && r.x + r.width <= this.x + this.width && r.y + r.height <= this.y + this.height;
  };
  P.clone = function () { return new flash_geom_Rectangle(this.x, this.y, this.width, this.height); };
  P.isEmpty = function () { return this.width <= 0 || this.height <= 0; };
  P.setEmpty = function () { this.x = this.y = this.width = this.height = 0; };
  P.intersects = function (r) {
    return !(r.x >= this.x + this.width || r.x + r.width <= this.x || r.y >= this.y + this.height || r.y + r.height <= this.y);
  };
  P.intersection = function (r) {
    const x0 = Math.max(this.x, r.x), y0 = Math.max(this.y, r.y);
    const x1 = Math.min(this.x + this.width, r.x + r.width), y1 = Math.min(this.y + this.height, r.y + r.height);
    if (x1 <= x0 || y1 <= y0) return new flash_geom_Rectangle();
    return new flash_geom_Rectangle(x0, y0, x1 - x0, y1 - y0);
  };
  P.union = function (r) {
    if (this.isEmpty()) return r.clone();
    if (r.isEmpty()) return this.clone();
    const x0 = Math.min(this.x, r.x), y0 = Math.min(this.y, r.y);
    const x1 = Math.max(this.x + this.width, r.x + r.width), y1 = Math.max(this.y + this.height, r.y + r.height);
    return new flash_geom_Rectangle(x0, y0, x1 - x0, y1 - y0);
  };
  P.offset = function (dx, dy) { this.x += dx; this.y += dy; };
  P.inflate = function (dx, dy) { this.x -= dx; this.y -= dy; this.width += 2 * dx; this.height += 2 * dy; };
  P.equals = function (r) { return r.x === this.x && r.y === this.y && r.width === this.width && r.height === this.height; };
  P.toString = function () { return '(x=' + this.x + ', y=' + this.y + ', w=' + this.width + ', h=' + this.height + ')'; };
})(flash_geom_Rectangle.prototype);

function flash_geom_Matrix(a = 1, b = 0, c = 0, d = 1, tx = 0, ty = 0) {
  this.a = a; this.b = b; this.c = c; this.d = d; this.tx = tx; this.ty = ty;
}
$class(flash_geom_Matrix, null, 'flash.geom.Matrix');
(function (P) {
  P.clone = function () { return new flash_geom_Matrix(this.a, this.b, this.c, this.d, this.tx, this.ty); };
  P.identity = function () { this.a = 1; this.b = 0; this.c = 0; this.d = 1; this.tx = 0; this.ty = 0; };
  P.translate = function (x, y) { this.tx += x; this.ty += y; };
  P.scale = function (sx, sy) {
    this.a *= sx; this.b *= sy; this.c *= sx; this.d *= sy; this.tx *= sx; this.ty *= sy;
  };
  P.rotate = function (r) {
    const cos = Math.cos(r), sin = Math.sin(r);
    const a = this.a, b = this.b, c = this.c, d = this.d, tx = this.tx, ty = this.ty;
    this.a = a * cos - b * sin; this.b = a * sin + b * cos;
    this.c = c * cos - d * sin; this.d = c * sin + d * cos;
    this.tx = tx * cos - ty * sin; this.ty = tx * sin + ty * cos;
  };
  // this = this * m  (apply this, then m)
  P.concat = function (m) {
    const a = this.a * m.a + this.b * m.c;
    const b = this.a * m.b + this.b * m.d;
    const c = this.c * m.a + this.d * m.c;
    const d = this.c * m.b + this.d * m.d;
    const tx = this.tx * m.a + this.ty * m.c + m.tx;
    const ty = this.tx * m.b + this.ty * m.d + m.ty;
    this.a = a; this.b = b; this.c = c; this.d = d; this.tx = tx; this.ty = ty;
  };
  P.invert = function () {
    const det = this.a * this.d - this.b * this.c;
    if (!det) { this.identity(); return; }
    const a = this.d / det, b = -this.b / det, c = -this.c / det, d = this.a / det;
    const tx = -(a * this.tx + c * this.ty), ty = -(b * this.tx + d * this.ty);
    this.a = a; this.b = b; this.c = c; this.d = d; this.tx = tx; this.ty = ty;
  };
  P.transformPoint = function (p) {
    return new flash_geom_Point(this.a * p.x + this.c * p.y + this.tx, this.b * p.x + this.d * p.y + this.ty);
  };
  P.deltaTransformPoint = function (p) {
    return new flash_geom_Point(this.a * p.x + this.c * p.y, this.b * p.x + this.d * p.y);
  };
  P.createBox = function (sx, sy, rot = 0, tx = 0, ty = 0) {
    const cos = Math.cos(rot), sin = Math.sin(rot);
    this.a = cos * sx; this.b = sin * sy; this.c = -sin * sx; this.d = cos * sy; this.tx = tx; this.ty = ty;
  };
  P.createGradientBox = function (w, h, rot = 0, tx = 0, ty = 0) {
    this.createBox(w / 1638.4, h / 1638.4, rot, tx + w / 2, ty + h / 2);
  };
  P.toString = function () {
    return '(a=' + this.a + ', b=' + this.b + ', c=' + this.c + ', d=' + this.d + ', tx=' + this.tx + ', ty=' + this.ty + ')';
  };
})(flash_geom_Matrix.prototype);

function flash_geom_ColorTransform(rm = 1, gm = 1, bm = 1, am = 1, ro = 0, go = 0, bo = 0, ao = 0) {
  this.redMultiplier = rm; this.greenMultiplier = gm; this.blueMultiplier = bm; this.alphaMultiplier = am;
  this.redOffset = ro; this.greenOffset = go; this.blueOffset = bo; this.alphaOffset = ao;
}
$class(flash_geom_ColorTransform, null, 'flash.geom.ColorTransform');
$accessor(flash_geom_ColorTransform.prototype, 'color', {
  get() { return (this.redOffset << 16) | (this.greenOffset << 8) | this.blueOffset; },
  set(c) {
    this.redMultiplier = this.greenMultiplier = this.blueMultiplier = 0;
    this.redOffset = (c >> 16) & 255; this.greenOffset = (c >> 8) & 255; this.blueOffset = c & 255;
  },
});
flash_geom_ColorTransform.prototype.concat = function (o) {
  this.redOffset += this.redMultiplier * o.redOffset;
  this.greenOffset += this.greenMultiplier * o.greenOffset;
  this.blueOffset += this.blueMultiplier * o.blueOffset;
  this.alphaOffset += this.alphaMultiplier * o.alphaOffset;
  this.redMultiplier *= o.redMultiplier; this.greenMultiplier *= o.greenMultiplier;
  this.blueMultiplier *= o.blueMultiplier; this.alphaMultiplier *= o.alphaMultiplier;
};
flash_geom_ColorTransform.prototype.$toArray = function () {
  return [this.redMultiplier, this.greenMultiplier, this.blueMultiplier, this.alphaMultiplier,
    this.redOffset, this.greenOffset, this.blueOffset, this.alphaOffset];
};
flash_geom_ColorTransform.$fromArray = function (a) {
  return new flash_geom_ColorTransform(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);
};

// display.transform accessor object
function flash_geom_Transform(obj) {
  this.$obj = obj;
}
$class(flash_geom_Transform, null, 'flash.geom.Transform');
$accessor(flash_geom_Transform.prototype, 'colorTransform', {
  get() { return flash_geom_ColorTransform.$fromArray(this.$obj.$cx || [1, 1, 1, 1, 0, 0, 0, 0]); },
  set(ct) { this.$obj.$setColorTransform(ct ? ct.$toArray() : null); },
});
$accessor(flash_geom_Transform.prototype, 'matrix', {
  get() { const m = this.$obj.$getMatrix(); return new flash_geom_Matrix(m[0], m[1], m[2], m[3], m[4], m[5]); },
  set(m) { this.$obj.$setMatrix([m.a, m.b, m.c, m.d, m.tx, m.ty]); },
});
$accessor(flash_geom_Transform.prototype, 'concatenatedMatrix', {
  get() { const m = this.$obj.$globalMatrix(); return new flash_geom_Matrix(m[0], m[1], m[2], m[3], m[4], m[5]); },
});

// ------------------------------------------------------------------ filters (data only, rendered by flash_display)
function flash_filters_GlowFilter(color = 0xff0000, alpha = 1, blurX = 6, blurY = 6, strength = 2, quality = 1, inner = false, knockout = false) {
  Object.assign(this, { color, alpha, blurX, blurY, strength, quality, inner, knockout });
}
$class(flash_filters_GlowFilter, null, 'flash.filters.GlowFilter');
flash_filters_GlowFilter.prototype.clone = function () { return Object.assign(new flash_filters_GlowFilter(), this); };

function flash_filters_DropShadowFilter(distance = 4, angle = 45, color = 0, alpha = 1, blurX = 4, blurY = 4, strength = 1, quality = 1, inner = false, knockout = false, hideObject = false) {
  Object.assign(this, { distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject });
}
$class(flash_filters_DropShadowFilter, null, 'flash.filters.DropShadowFilter');

function flash_filters_BevelFilter(distance = 4, angle = 45, highlightColor = 0xffffff, highlightAlpha = 1, shadowColor = 0,
  shadowAlpha = 1, blurX = 4, blurY = 4, strength = 1, quality = 1, type = 'inner', knockout = false) {
  Object.assign(this, { distance, angle, highlightColor, highlightAlpha, shadowColor, shadowAlpha, blurX, blurY, strength, quality, type, knockout });
}
$class(flash_filters_BevelFilter, null, 'flash.filters.BevelFilter');

function flash_filters_BlurFilter(blurX = 4, blurY = 4, quality = 1) {
  Object.assign(this, { blurX, blurY, quality });
}
$class(flash_filters_BlurFilter, null, 'flash.filters.BlurFilter');

function flash_filters_ColorMatrixFilter(matrix = null) {
  this.matrix = matrix || [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
}
$class(flash_filters_ColorMatrixFilter, null, 'flash.filters.ColorMatrixFilter');

// ------------------------------------------------------------------ utils
const $startTime = performance.now();
function flash_utils_getTimer() {
  return Math.floor(performance.now() - $startTime);
}

function flash_utils_Dictionary(weak) {
  this.$map = new Map();
}
$class(flash_utils_Dictionary, null, 'flash.utils.Dictionary');
flash_utils_Dictionary.prototype.get = function (k) { return this.$map.get(k); };
flash_utils_Dictionary.prototype.set = function (k, v) { this.$map.set(k, v); };
flash_utils_Dictionary.prototype.delete = function (k) { this.$map.delete(k); };
flash_utils_Dictionary.prototype.keys = function () { return Array.from(this.$map.keys()); };

// Timers are driven by the main loop (see $tickTimers) so that they pause with the page.
const $timers = new Set();
function flash_utils_Timer(delay, repeatCount = 0) {
  flash_events_EventDispatcher.call(this);
  this.delay = delay;
  this.repeatCount = repeatCount;
  this.currentCount = 0;
  this.running = false;
  this.$next = 0;
}
$class(flash_utils_Timer, flash_events_EventDispatcher, 'flash.utils.Timer');
flash_utils_Timer.prototype.start = function () {
  if (this.running) return;
  this.running = true;
  this.$next = performance.now() + Math.max(this.delay, 1);
  $timers.add(this);
};
flash_utils_Timer.prototype.stop = function () {
  this.running = false;
  $timers.delete(this);
};
flash_utils_Timer.prototype.reset = function () {
  this.stop();
  this.currentCount = 0;
};
function $tickTimers(now) {
  for (const t of Array.from($timers)) {
    let n = 0;
    while (t.running && now >= t.$next && n < 4) {
      n++;
      t.currentCount++;
      t.$next += Math.max(t.delay, 1);
      t.dispatchEvent(new flash_events_TimerEvent('timer'));
      if (t.repeatCount && t.currentCount >= t.repeatCount) {
        t.stop();
        t.dispatchEvent(new flash_events_TimerEvent('timerComplete'));
      }
    }
    if (t.running && now >= t.$next) t.$next = now + Math.max(t.delay, 1); // drop backlog
  }
}

function flash_utils_ByteArray() {
  this.$data = '';
  this.position = 0;
}
$class(flash_utils_ByteArray, null, 'flash.utils.ByteArray');
flash_utils_ByteArray.prototype.toString = function () { return this.$data; };
flash_utils_ByteArray.prototype.readUTFBytes = function (n) {
  const s = this.$data.substr(this.position, n);
  this.position += n;
  return s;
};
$accessor(flash_utils_ByteArray.prototype, 'length', { get() { return this.$data.length; } });
$accessor(flash_utils_ByteArray.prototype, 'bytesAvailable', { get() { return this.$data.length - this.position; } });

function flash_utils_describeType() { return null; }
function flash_utils_getDefinitionByName(name) {
  const c = window[name.replace(/[.:]+/g, '_')];
  if (!c) throw new Error('Definition ' + name + ' not found');
  return c;
}
function flash_utils_getQualifiedClassName(v) {
  if (v == null) return 'null';
  const c = typeof v === 'function' ? v : v.constructor;
  return (c && c.$fq) ? c.$fq.replace(/\.(\w+)$/, '::$1') : 'Object';
}
function flash_utils_setTimeout(fn, delay, ...args) { return setTimeout(() => fn(...args), delay); }
function flash_utils_clearTimeout(id) { clearTimeout(id); }

function mx_core_ByteArrayAsset() {
  flash_utils_ByteArray.call(this);
}
$class(mx_core_ByteArrayAsset, flash_utils_ByteArray, 'mx.core.ByteArrayAsset');

// ------------------------------------------------------------------ net / system
function flash_net_URLRequest(url = null) {
  this.url = url;
  this.method = 'GET';
  this.data = null;
}
$class(flash_net_URLRequest, null, 'flash.net.URLRequest');

function flash_net_URLVariables() {}
$class(flash_net_URLVariables, null, 'flash.net.URLVariables');
const flash_net_URLRequestMethod = { GET: 'GET', POST: 'POST' };

function flash_net_URLLoader(req) {
  flash_events_EventDispatcher.call(this);
  this.data = null;
  if (req) this.load(req);
}
$class(flash_net_URLLoader, flash_events_EventDispatcher, 'flash.net.URLLoader');
flash_net_URLLoader.prototype.load = function (req) {
  fetch(req.url).then((r) => r.text()).then((t) => {
    this.data = t;
    this.dispatchEvent(new flash_events_Event('complete'));
  }).catch(() => this.dispatchEvent(new flash_events_IOErrorEvent('ioError')));
};
flash_net_URLLoader.prototype.close = function () {};

function flash_net_navigateToURL(req, target = '_blank') {
  if (req && req.url) window.open(req.url, target || '_blank', 'noopener');
}

function flash_net_SharedObject(name) {
  this.$name = name;
  let data = {};
  try {
    const raw = localStorage.getItem('so_' + name);
    if (raw) data = JSON.parse(raw) || {};
    this.$saved = raw;
  } catch (e) { /* storage unavailable */ }
  this.data = data;
}
$class(flash_net_SharedObject, null, 'flash.net.SharedObject');
flash_net_SharedObject.$cache = {};
flash_net_SharedObject.getLocal = function (name) {
  if (!flash_net_SharedObject.$cache[name]) flash_net_SharedObject.$cache[name] = new flash_net_SharedObject(name);
  return flash_net_SharedObject.$cache[name];
};
flash_net_SharedObject.prototype.flush = function () {
  try {
    const json = JSON.stringify(this.data);
    if (json !== this.$saved) {
      localStorage.setItem('so_' + this.$name, json);
      this.$saved = json;
    }
  } catch (e) { console.warn('could not save', e); }
  return 'flushed';
};
// Flash Player writes shared objects to disk when the movie unloads even without flush();
// emulate that (the game relies on it when erasing a save slot).
function $flushSharedObjects() {
  for (const k in flash_net_SharedObject.$cache) flash_net_SharedObject.$cache[k].flush();
}
window.addEventListener('pagehide', $flushSharedObjects);
document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'hidden') $flushSharedObjects(); });
setInterval($flushSharedObjects, 3000);
// Ask Chromium-based browsers to keep the saves even when the device runs short of storage (they
// decide silently; Firefox would ask the user with a pop-up, so it isn't asked).
if (navigator.userAgentData && navigator.storage && navigator.storage.persist) navigator.storage.persist().catch(() => {});
flash_net_SharedObject.prototype.clear = function () {
  this.data = {};
  try { localStorage.removeItem('so_' + this.$name); } catch (e) { /* ignore */ }
};
$accessor(flash_net_SharedObject.prototype, 'size', { get() { return JSON.stringify(this.data).length; } });

const flash_system_Security = { allowDomain() {}, allowInsecureDomain() {}, loadPolicyFile() {}, sandboxType: 'remote' };
const flash_system_Capabilities = { playerType: 'PlugIn', version: 'WEB 10,0,0,0', os: navigator.platform, language: 'en' };
const flash_external_ExternalInterface = { available: false, call() { return null; }, addCallback() {} };

const flash_ui_Keyboard = {
  LEFT: 37, UP: 38, RIGHT: 39, DOWN: 40, SPACE: 32, ENTER: 13, ESCAPE: 27, BACKSPACE: 8, DELETE: 46, SHIFT: 16, CONTROL: 17, TAB: 9,
  P: 80,
};
function flash_ui_ContextMenu() { this.customItems = []; this.builtInItems = {}; }
flash_ui_ContextMenu.prototype.hideBuiltInItems = function () {};
function flash_ui_ContextMenuItem(caption) { flash_events_EventDispatcher.call(this); this.caption = caption; }
$class(flash_ui_ContextMenuItem, flash_events_EventDispatcher, 'flash.ui.ContextMenuItem');
const flash_ui_Mouse = { hide() {}, show() {} };

// JSON (com.adobe.serialization.json.JSON)
const com_adobe_serialization_json_JSON = {
  encode(o) { return JSON.stringify(o); },
  decode(s) { return JSON.parse(s); },
};

// Package-level functions are sometimes referenced through wildcard imports (import flash.utils.*)
const getQualifiedClassName = flash_utils_getQualifiedClassName;
const getQualifiedSuperclassName = (v) => {
  const c = typeof v === 'function' ? v : v && v.constructor;
  return c && c.$parent ? flash_utils_getQualifiedClassName(c.$parent) : 'Object';
};
const describeType = flash_utils_describeType;
const getDefinitionByName = flash_utils_getDefinitionByName;
const getTimer = flash_utils_getTimer;
const navigateToURL = flash_net_navigateToURL;
