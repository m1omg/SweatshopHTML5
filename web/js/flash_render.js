// Asset libraries (converted SWF symbol data) and the Canvas2D renderer.
'use strict';

// ------------------------------------------------------------------ fonts
const $fontsByName = {}; // name -> [font,...] sorted by glyph count desc

function $Font(lib, id, def) {
  this.lib = lib;
  this.id = id;
  this.name = def.name;
  this.bold = def.bold;
  this.italic = def.italic;
  this.def = def;
  this.map = new Map();
  def.codes.forEach((c, i) => this.map.set(c, i));
  this.paths = new Array(def.codes.length);
  this.ascent = def.ascent !== undefined ? def.ascent : 0.8;
  this.descent = def.descent !== undefined ? def.descent : 0.2;
  this.leading = def.leading || 0;
}
$Font.prototype.glyphPath = function (i) {
  let p = this.paths[i];
  if (!p) {
    p = this.paths[i] = new Path2D(this.def.glyphs[i] || '');
  }
  return p;
};
$Font.prototype.advance = function (i) {
  return this.def.adv ? this.def.adv[i] / 1 : 0.5;
};
function $registerFont(f) {
  const list = $fontsByName[f.name] || ($fontsByName[f.name] = []);
  list.push(f);
  list.sort((a, b) => b.def.codes.length - a.def.codes.length);
}
// Find a glyph for char code in a font (falling back to other fonts with the same name)
function $findGlyph(font, code) {
  if (font) {
    const i = font.map.get(code);
    if (i !== undefined) return [font, i];
    const list = $fontsByName[font.name];
    if (list) {
      for (const f of list) {
        const j = f.map.get(code);
        if (j !== undefined && f.bold === font.bold) return [f, j];
      }
      for (const f of list) {
        const j = f.map.get(code);
        if (j !== undefined) return [f, j];
      }
    }
  }
  return null;
}
function $fontByName(name, bold, preferLib) {
  if (preferLib) {
    for (const f of preferLib.fonts.values()) if (f.name === name && f.bold === !!bold) return f;
    for (const f of preferLib.fonts.values()) if (f.name === name) return f;
  }
  const list = $fontsByName[name];
  if (list && list.length) {
    for (const f of list) if (f.bold === !!bold) return f;
    return list[0];
  }
  return null;
}

// ------------------------------------------------------------------ library
const $libraries = {};

function $Library(name, json, base) {
  this.name = name;
  this.json = json;
  this.base = base;
  this.chars = json.chars;
  this.classes = json.classes;
  this.images = {};
  this.sounds = {};
  this.fonts = new Map();
  this.timelines = new Map();
  this.states = new Map();
  this.bitmapDatas = new Map();
  this.stopsByClass = json.stops || {};
  this.stopsById = {};
  for (const cls in this.stopsByClass) {
    const id = this.classes[cls];
    if (id !== undefined) this.stopsById[id] = new Set(this.stopsByClass[cls]);
  }
  for (const id in this.chars) {
    const c = this.chars[id];
    if (c.t === 'font') {
      const f = new $Font(this, id, c);
      this.fonts.set(String(id), f);
      $registerFont(f);
    }
  }
  $libraries[name] = this;
}

$Library.load = async function (name, base, onProgress) {
  const res = await fetch(base + name + '.json');
  const json = await res.json();
  const lib = new $Library(name, json, base);
  await lib.loadMedia(onProgress);
  return lib;
};

$Library.prototype.mediaCount = function () {
  return Object.keys(this.json.img).length + Object.keys(this.json.snd).length;
};

$Library.prototype.loadMedia = function (onProgress) {
  const jobs = [];
  for (const id in this.json.img) {
    const file = this.json.img[id];
    jobs.push(new Promise((resolve) => {
      const img = new Image();
      img.onload = () => {
        this.images[id] = img;
        if (onProgress) onProgress();
        resolve();
      };
      img.onerror = () => {
        console.warn('image failed', this.name, file);
        if (onProgress) onProgress();
        resolve();
      };
      img.src = this.base + this.name + '/' + file;
    }));
  }
  // Long music tracks are decoded when first played; everything else up front.
  const eager = this.name !== 'Music';
  for (const id in this.json.snd) {
    const file = this.json.snd[id];
    jobs.push($audio.loadAsset(this.base + this.name + '/' + file).then((asset) => {
      this.sounds[id] = asset;
      return eager ? $audio.decode(asset) : null;
    }).catch((e) => console.warn('sound failed', this.name, file, e)).then(() => {
      if (onProgress) onProgress();
    }));
  }
  return Promise.all(jobs);
};

$Library.prototype.hasClass = function (cls) {
  return this.classes[cls] !== undefined;
};

$Library.prototype.timelineInfo = function (id) {
  id = String(id);
  let t = this.timelines.get(id);
  if (!t) {
    const def = this.chars[id];
    const labelList = [];
    if (def.lb) for (const k in def.lb) labelList.push({ name: k, frame: def.lb[k] });
    labelList.sort((a, b) => a.frame - b.frame);
    let sounds = null;
    def.f.forEach((ops, i) => {
      for (const op of ops) {
        if (op[0] === 's' && !op[2]) {
          if (!sounds) sounds = {};
          (sounds[i + 1] || (sounds[i + 1] = [])).push(op[1]);
        }
      }
    });
    t = { lib: this, id, def, labelList, stops: this.stopsById[id] || null, sounds };
    this.timelines.set(id, t);
  }
  return t;
};

// Display list state of every frame of a sprite: Map(depth -> record)
$Library.prototype.frameStates = function (id) {
  id = String(id);
  let st = this.states.get(id);
  if (st) return st;
  const def = this.chars[id];
  st = [];
  let cur = new Map();
  const n = Math.max(def.n || 1, def.f.length, 1);
  for (let i = 0; i < n; i++) {
    const ops = def.f[i] || [];
    if (ops.length) {
      cur = new Map(cur);
      for (const op of ops) {
        if (op[0] === 'p') {
          const p = op[1];
          const old = cur.get(p.dp);
          let rec;
          if (p.mv && old) {
            rec = Object.assign({}, old);
            if (p.id !== undefined && p.id !== old.id) {
              rec.id = p.id;
              rec.pf = i + 1;
            }
          } else {
            if (p.id === undefined) continue;
            rec = { id: p.id, pf: i + 1 };
          }
          if (p.m) rec.m = p.m;
          if (p.cx) rec.cx = p.cx;
          if (p.ra !== undefined) rec.ra = p.ra;
          if (p.nm) rec.nm = p.nm;
          if (p.clip) rec.clip = p.clip;
          if (p.fl) rec.fl = p.fl;
          if (p.bl !== undefined) rec.bl = p.bl;
          if (p.vis !== undefined) rec.vis = p.vis;
          cur.set(p.dp, rec);
        } else if (op[0] === 'r') {
          cur.delete(op[1]);
        }
      }
      // keep depth ordering
      cur = new Map([...cur.entries()].sort((a, b) => a[0] - b[0]));
    }
    st.push(cur);
  }
  this.states.set(id, st);
  return st;
};

$Library.prototype.bitmapData = function (id) {
  id = String(id);
  let b = this.bitmapDatas.get(id);
  if (!b) {
    const img = this.images[id];
    if (!img) return null;
    b = new flash_display_BitmapData(img.naturalWidth, img.naturalHeight, true, 0);
    b.$ctx.drawImage(img, 0, 0);
    b.$img = img;
    this.bitmapDatas.set(id, b);
  }
  return b;
};

$Library.prototype.createCharacter = function (id) {
  id = String(id);
  const def = this.chars[id];
  if (!def) return null;
  switch (def.t) {
    case 'shape': return new $SymbolShape(this, def);
    case 'morph': return new $MorphShape(this, def);
    case 'sprite': {
      $pendingSymbol = { lib: this, id };
      const mc = new flash_display_MovieClip();
      $pendingSymbol = null;
      return mc;
    }
    case 'text': return flash_text_TextField.$fromDef(this, def);
    case 'stext': return new $StaticText(this, def);
    case 'button': return new flash_display_SimpleButton(this, def);
    case 'video': return new $Video(this, id, def);
    case 'bitmap': {
      const bmd = this.bitmapData(id);
      return new flash_display_Bitmap(bmd);
    }
    default: return null;
  }
};

// Create an instance of a linked class (e.g. "HUDSymbol")
$Library.prototype.instantiate = function (cls) {
  const id = this.classes[cls];
  if (id === undefined) throw new Error('no such symbol as ' + cls + ' in ' + this.name);
  const def = this.chars[id];
  if (def.t === 'bitmap') return this.bitmapData(id).clone();
  return this.createCharacter(id);
};

$Library.prototype.soundBuffer = function (cls) {
  const id = this.classes[cls];
  if (id === undefined) return null;
  return this.sounds[id] || null;
};

$Library.prototype.playTimelineSound = function (id) {
  const asset = this.sounds[id];
  if (asset) new flash_media_Sound(asset).play();
};

// ------------------------------------------------------------------ color helpers
function $cssColor(c, cx) {
  let r = c[0], g = c[1], b = c[2], a = c[3];
  if (cx) {
    r = r * cx[0] + cx[4];
    g = g * cx[1] + cx[5];
    b = b * cx[2] + cx[6];
    a = a * cx[3] + cx[7];
  }
  r = r < 0 ? 0 : r > 255 ? 255 : r | 0;
  g = g < 0 ? 0 : g > 255 ? 255 : g | 0;
  b = b < 0 ? 0 : b > 255 ? 255 : b | 0;
  a = a < 0 ? 0 : a > 255 ? 255 : a;
  return 'rgba(' + r + ',' + g + ',' + b + ',' + (a / 255).toFixed(3) + ')';
}
function $cxIsIdentity(cx) {
  return !cx || (cx[0] === 1 && cx[1] === 1 && cx[2] === 1 && cx[3] === 1 && !cx[4] && !cx[5] && !cx[6] && !cx[7]);
}
function $cxAlphaOnly(cx) {
  return cx[0] === 1 && cx[1] === 1 && cx[2] === 1 && !cx[4] && !cx[5] && !cx[6] && !cx[7];
}
const $recolorCache = new WeakMap();
// Apply a colour transform to an image / canvas; cached per source and transform
function $recolor(src, cx, owner) {
  const key = cx.map((v) => Math.round(v * 100)).join(',');
  let m = $recolorCache.get(owner || src);
  if (!m) { m = new Map(); $recolorCache.set(owner || src, m); }
  const ver = owner && owner.$version !== undefined ? owner.$version : 0;
  let e = m.get(key);
  if (e && e.ver === ver) return e.canvas;
  const w = src.naturalWidth || src.width, h = src.naturalHeight || src.height;
  const c = (e && e.canvas) || document.createElement('canvas');
  c.width = w; c.height = h;
  const ctx = c.getContext('2d');
  ctx.clearRect(0, 0, w, h);
  ctx.drawImage(src, 0, 0);
  const id = ctx.getImageData(0, 0, w, h);
  const d = id.data;
  for (let i = 0; i < d.length; i += 4) {
    d[i] = d[i] * cx[0] + cx[4];
    d[i + 1] = d[i + 1] * cx[1] + cx[5];
    d[i + 2] = d[i + 2] * cx[2] + cx[6];
    d[i + 3] = d[i + 3] * cx[3] + cx[7];
  }
  ctx.putImageData(id, 0, 0);
  if (m.size > 16) m.clear();
  m.set(key, { ver, canvas: c });
  return c;
}

// ------------------------------------------------------------------ renderer
const $gradCache = new WeakMap();
const $gradPathCache = new WeakMap();
const $layerPool = [];
let $cacheEnabled = true;
// Bitmap-cache bookkeeping: a memory budget (Chrome blanks the page for a moment when a page
// holds too much canvas memory) and an epoch bumped when the browser discards canvases.
const $cachedObjs = new Set();
let $cacheEpoch = 0;
function $newCanvas(w, h) {
  const c = document.createElement('canvas');
  c.width = w;
  c.height = h;
  c.addEventListener('contextlost', () => { $cacheEpoch++; });
  return c;
}
function $freeCanvas(c) {
  if (!c) return;
  c.width = 0;
  c.height = 0;
}
function $mainPixels() {
  return $player.canvas ? Math.max(1, $player.canvas.width * $player.canvas.height) : 1000000;
}
function $dropCache(obj) {
  const c = obj.$cache;
  obj.$cache = null;
  $cachedObjs.delete(obj);
  if (c && c.canvas) $freeCanvas(c.canvas);
}
function $enforceCacheBudget(newObj) {
  const budgetPx = Math.max(4000000, 5 * $mainPixels());
  const frame = $player.frameCount;
  let total = 0;
  for (const o of $cachedObjs) {
    if (!o.$cache || !o.$cache.canvas) { $cachedObjs.delete(o); continue; }
    // bitmaps of things not drawn for a few seconds are freed
    if (o !== newObj && frame - o.$cache.lastUsed > 75) { $dropCache(o); continue; }
    total += o.$cache.canvas.width * o.$cache.canvas.height;
  }
  // (filtered / layer-blended objects are always kept: they need the bitmap anyway, and
  // re-applying their filters every frame is far more expensive than the memory)
  if (total > budgetPx && newObj.$cache && !newObj.$filters && newObj.$blend !== 'layer') {
    // budget full: don't keep this one (its bitmap is still drawn this frame by the caller,
    // then recycled); it is drawn directly from now on - no evict / rebuild cycles
    newObj.$cache = null;
    $cachedObjs.delete(newObj);
    newObj.$noCacheUntil = frame + 1500;
  }
}

function $Renderer(ctx, scale, offX = 0, offY = 0) {
  this.ctx = ctx;
  this.S = scale;
  this.ox = offX;
  this.oy = offY;
}

(function (P) {
  P.setT = function (m) {
    const S = this.S;
    this.ctx.setTransform(m[0] * S, m[1] * S, m[2] * S, m[3] * S, m[4] * S + this.ox, m[5] * S + this.oy);
  };

  // isRoot: render obj with matrix pm as-is (used for BitmapData.draw and layer building).
  // noFx: skip obj's own filters / blend mode / mask (they are applied by renderComposite).
  P.renderObject = function (obj, pm, pcx, isRoot, noFx) {
    if (!isRoot) {
      if (!obj.$visible || obj.$maskOf || obj.$isClipMask) return;
    }
    const m = isRoot ? pm : $mul(obj.$m, pm);
    const cx = isRoot ? (pcx || null) : $cxMul(obj.$cx, pcx);
    if (cx && cx[3] <= 0 && cx[7] <= 0) return;
    let blendOp = null;
    if (!noFx) {
      const hasFilters = obj.$filters && obj.$filters.length;
      const blend = obj.$blend;
      const special = blend && blend !== 'normal' && blend !== 'layer';
      const layerAlpha = blend === 'layer' && cx && cx[3] < 0.999;
      // Bitmaps (cacheAsBitmap, or the flattened group of a faded "layer") are only worth it
      // for content that stays unchanged: objects that were just created or changed are drawn
      // directly until they have been stable for a few frames.
      let cab = obj.cacheAsBitmap && !isRoot && $cacheEnabled;
      let group = layerAlpha;
      if (cab) {
        // simple objects (a single shape, a rain drop...) are cheaper to draw than to cache
        if (obj.$costChg !== obj.$chg) {
          obj.$costChg = obj.$chg;
          obj.$cost = $drawCost(obj, 60);
        }
        if (obj.$cost < 6) cab = false;
      }
      if (cab || group) {
        if (obj.$seenChg !== obj.$chg) {
          obj.$seenChg = obj.$chg;
          obj.$stableSince = $player.frameCount;
        }
        if ($player.frameCount - obj.$stableSince < 3 && !obj.$cache) cab = group = false;
      }
      // blend modes (overlay, screen...) are applied while drawing, without an offscreen bitmap
      if (special) blendOp = $COMPOSITE[blend] || null;
      if (hasFilters || cab || group) {
        // objects that animate every frame skip the offscreen bitmap (see renderComposite)
        const direct = !hasFilters && obj.$noCacheUntil > $player.frameCount;
        const keepIt = !isRoot && $cacheEnabled && !(obj.$noCacheUntil > $player.frameCount);
        if (!direct && this.renderComposite(obj, m, cx, keepIt)) return;
      }
    }
    const ctx = this.ctx;
    let clipped = false;
    if (obj.$mask && !noFx) clipped = this.clipToMask(obj.$mask);
    if (blendOp) {
      ctx.save();
      ctx.globalCompositeOperation = blendOp;
    }
    obj.$draw(this, m, cx);
    const ch = obj.$children;
    if (ch && ch.length) {
      if (obj.$hasClips) this.renderClippedChildren(obj, m, cx);
      else for (let i = 0; i < ch.length; i++) this.renderObject(ch[i], m, cx, false);
    }
    if (blendOp) ctx.restore();
    if (clipped) ctx.restore();
  };

  P.clipToMask = function (mk) {
    const ctx = this.ctx;
    const mm = mk.$parent ? mk.$globalMatrix() : mk.$m;
    const path = new Path2D();
    this.collectClip(mk, mm, path, true);
    ctx.save();
    ctx.setTransform(this.S, 0, 0, this.S, this.ox, this.oy);
    ctx.clip(path, 'nonzero');
    return true;
  };

  P.renderClippedChildren = function (obj, m, cx) {
    const ctx = this.ctx;
    const ch = obj.$children.slice();
    let activeClip = 0; // clip depth limit
    for (let i = 0; i < ch.length; i++) {
      const c = ch[i];
      if (activeClip && (c.$depth === null || c.$depth > activeClip)) {
        ctx.restore();
        activeClip = 0;
      }
      if (c.$isClipMask) {
        if (activeClip) { ctx.restore(); activeClip = 0; }
        const path = new Path2D();
        this.collectClip(c, $mul(c.$m, m), path, true);
        ctx.save();
        ctx.setTransform(this.S, 0, 0, this.S, this.ox, this.oy);
        ctx.clip(path, 'nonzero');
        activeClip = c.$clipDepth;
        continue;
      }
      this.renderObject(c, m, cx, false);
    }
    if (activeClip) ctx.restore();
  };

  // Accumulate the fill area of obj (global matrix m) into path (in stage coordinates)
  P.collectClip = function (obj, m, path, isRoot) {
    if (!isRoot && !obj.$visible && !obj.$isClipMask) return;
    const dm = new DOMMatrix([m[0], m[1], m[2], m[3], m[4], m[5]]);
    if (obj instanceof $SymbolShape || obj instanceof $MorphShape) {
      const def = obj instanceof $MorphShape ? obj.$shapeDef() : obj.$def;
      for (const e of def.d) if (e.f) path.addPath($pathOf(e), dm);
    } else if (obj.$graphics) {
      for (const c of obj.$graphics.$all()) if (c.fill) path.addPath(c.path, dm);
    } else if (obj instanceof flash_display_Bitmap || obj instanceof flash_text_TextField || obj instanceof $StaticText) {
      const b = obj.$contentBounds([1, 0, 0, 1, 0, 0]);
      if (b) {
        const r = new Path2D();
        r.rect(b[0], b[1], b[2] - b[0], b[3] - b[1]);
        path.addPath(r, dm);
      }
    }
    if (obj.$children) {
      for (const c of obj.$children) {
        if (c.$maskOf) continue;
        this.collectClip(c, $mul(c.$m, m), path, false);
      }
    }
  };

  P.fillStyleFor = function (lib, f, cx, entry, m) {
    // returns {style, gm} ; gm: extra matrix (gradient space) requiring path transformation
    if (f.c) return { style: $cssColor(f.c, cx) };
    if (f.g) {
      let cache = $gradCache.get(f);
      const key = cx ? cx.join(',') : '';
      if (!cache || cache.key !== key) {
        const ctx = this.ctx;
        let g;
        if (f.g === 'l') g = ctx.createLinearGradient(-819.2, 0, 819.2, 0);
        else g = ctx.createRadialGradient((f.fp || 0) * 819.2, 0, 0, 0, 0, 819.2);
        for (const s of f.s) {
          g.addColorStop(Math.min(1, Math.max(0, s[0] / 255)), $cssColor([s[1], s[2], s[3], s[4]], cx));
        }
        cache = { key, g };
        $gradCache.set(f, cache);
      }
      return { style: cache.g, gm: f.m };
    }
    if (f.b !== undefined || f.bmd) {
      let src;
      let owner;
      if (f.bmd) { src = f.bmd.$source(); owner = f.bmd; } else {
        src = lib.images[f.b];
        owner = src;
      }
      if (!src) return { style: 'rgba(0,0,0,0)' };
      if (cx && !$cxIsIdentity(cx) && !$cxAlphaOnly(cx)) src = $recolor(src, cx, owner);
      const pat = this.ctx.createPattern(src, f.rep === false ? 'no-repeat' : 'repeat');
      pat.setTransform(new DOMMatrix(f.m));
      return { style: pat, alpha: cx && $cxAlphaOnly(cx) ? cx[3] : 1, smooth: f.sm !== false };
    }
    return { style: 'rgba(0,0,0,0)' };
  };

  P.fillEntry = function (lib, f, path, m, cx, entryKey, rule) {
    const ctx = this.ctx;
    const st = this.fillStyleFor(lib, f, cx, entryKey, m);
    if (st.gm) {
      let gp = $gradPathCache.get(entryKey);
      if (!gp) {
        gp = new Path2D();
        const inv = $inv(st.gm);
        gp.addPath(path, new DOMMatrix(inv));
        $gradPathCache.set(entryKey, gp);
      }
      this.setT($mul(st.gm, m));
      ctx.fillStyle = st.style;
      ctx.fill(gp, rule);
      return;
    }
    this.setT(m);
    if (st.alpha !== undefined && st.alpha !== 1) ctx.globalAlpha = st.alpha;
    if (st.smooth !== undefined) ctx.imageSmoothingEnabled = st.smooth;
    ctx.fillStyle = st.style;
    ctx.fill(path, rule);
    if (st.alpha !== undefined && st.alpha !== 1) ctx.globalAlpha = 1;
    if (st.smooth !== undefined) ctx.imageSmoothingEnabled = true;
  };

  P.strokeEntry = function (l, path, m, cx) {
    const ctx = this.ctx;
    this.setT(m);
    const det = Math.sqrt(Math.abs(m[0] * m[3] - m[1] * m[2])) * this.S;
    const minW = det > 0 ? 1 / det : 1;
    ctx.lineWidth = l.ns ? Math.max(l.w, 1) / (det || 1) : Math.max(l.w, minW);
    ctx.strokeStyle = $cssColor(l.c, cx);
    ctx.lineCap = l.cap === 1 ? 'butt' : l.cap === 2 ? 'square' : 'round';
    ctx.lineJoin = l.j === 1 ? 'bevel' : l.j === 2 ? 'miter' : 'round';
    if (l.j === 2) ctx.miterLimit = l.ml || 3;
    ctx.stroke(path);
  };

  P.drawShapeDef = function (lib, def, m, cx) {
    for (const e of def.d) {
      const path = $pathOf(e);
      if (e.f) this.fillEntry(lib, e.f, path, m, cx, e, 'evenodd');
      else if (e.l) this.strokeEntry(e.l, path, m, cx);
    }
  };

  P.drawGraphics = function (g, m, cx) {
    for (const c of g.$all()) {
      if (c.fill) this.fillEntry(null, c.fill, c.path, m, cx, c, 'nonzero');
      else if (c.line) this.strokeEntry(c.line, c.path, m, cx);
    }
  };

  P.drawBitmap = function (bmd, m, cx, smoothing) {
    const ctx = this.ctx;
    let src = bmd.$source();
    let alpha = 1;
    if (cx && !$cxIsIdentity(cx)) {
      if ($cxAlphaOnly(cx)) alpha = cx[3];
      else src = $recolor(src, cx, bmd);
    }
    this.setT(m);
    // Bitmap.smoothing=false means nearest-neighbour scaling in Flash (e.g. the tile highlight
    // maps are tiny bitmaps scaled up 35x). Only the stage zoom itself is smoothed.
    const objScale = Math.max(Math.abs(m[0]) + Math.abs(m[1]), Math.abs(m[2]) + Math.abs(m[3]));
    ctx.imageSmoothingEnabled = !!smoothing || (objScale < 1.5 && (this.S !== 1 || Math.abs(objScale - 1) > 0.01));
    if (alpha !== 1) ctx.globalAlpha = alpha;
    ctx.drawImage(src, 0, 0);
    if (alpha !== 1) ctx.globalAlpha = 1;
    ctx.imageSmoothingEnabled = true;
  };

  P.drawGlyph = function (font, gi, x, y, size, m, color, cx) {
    const ctx = this.ctx;
    const s = size / 1000;
    this.setT($mul([s, 0, 0, s, x, y], m));
    ctx.fillStyle = $cssColor(color, cx);
    ctx.fill(font.glyphPath(gi), 'nonzero');
  };

  P.drawStaticText = function (lib, def, m, cx) {
    const tm = $mul(def.m, m);
    for (const rec of def.recs) {
      const font = lib.fonts.get(String(rec.font));
      if (!font) continue;
      for (const g of rec.g) this.drawGlyph(font, g[0], g[1], rec.y, rec.size, tm, rec.c, cx);
    }
  };

  // Render obj into an offscreen bitmap, apply its filters and composite it with its blend
  // mode. With useCache the bitmap is kept (like Flash's cacheAsBitmap) and reused until
  // something inside obj changes or it is scaled / rotated / recoloured.
  P.renderComposite = function (obj, m, cx, useCache) {
    const S = this.S;
    const filters = obj.$filters && obj.$filters.length ? obj.$filters : null;
    const rawBlend = obj.$blend && obj.$blend !== 'normal' ? obj.$blend : null;
    const blend = rawBlend && rawBlend !== 'layer' ? rawBlend : null;
    // Colour transforms of a filtered (or layer-blended) object apply to the finished bitmap,
    // e.g. fading an object also fades its drop shadow. Alpha-only transforms are applied when
    // drawing; other transforms recolour the bitmap.
    let contentCx = cx;
    let postCx = null;
    let alpha = 1;
    if (filters || rawBlend === 'layer') {
      contentCx = null;
      if (cx && !$cxIsIdentity(cx)) {
        if ($cxAlphaOnly(cx)) alpha = Math.max(0, Math.min(1, cx[3]));
        else postCx = cx;
      }
    }
    const key = $cacheEpoch + '|' + S + '|' + m[0].toFixed(4) + ',' + m[1].toFixed(4) + ',' + m[2].toFixed(4) + ',' + m[3].toFixed(4) +
      '|' + (contentCx ? contentCx.map((v) => v.toFixed(3)).join(',') : '') + '|' + (postCx ? postCx.map((v) => v.toFixed(3)).join(',') : '');
    let c = obj.$cache;
    const fresh = useCache && c && c.key === key && c.seq >= obj.$chg && c.filters === obj.$filters;
    if (!fresh) {
      if (useCache && c && $player.frameCount - c.frame <= 2) {
        // rebuilt again almost immediately: this object animates, so stop caching it for a while
        obj.$thrash = (obj.$thrash || 0) + 1;
        if (obj.$thrash > 3 && !filters) {
          obj.$noCacheUntil = $player.frameCount + 75;
          obj.$thrash = 0;
          $dropCache(obj);
          return false;
        }
      } else if (useCache) {
        obj.$thrash = 0;
      }
      c = this.buildComposite(obj, m, contentCx, key, filters, useCache, useCache && c && c.canvas ? c.canvas : null, postCx);
      if (!c) {
        if (useCache) obj.$cache = { empty: true, key, seq: $seq, filters: obj.$filters, frame: $player.frameCount };
        return true;
      }
      obj.$cache = useCache ? c : null;
      if (useCache) {
        c.lastUsed = $player.frameCount;
        $cachedObjs.add(obj);
        // a big bitmap of a simple object costs more memory than it saves drawing time (the
        // count stops once the object is complex enough, so busy backgrounds stay cached)
        const area = c.w * c.h;
        if (!filters && !rawBlend && obj.$cost !== undefined && area > obj.$cost * 60000 &&
            $drawCost(obj, Math.ceil(area / 60000) + 1) * 60000 < area) {
          obj.$cache = null;
          $cachedObjs.delete(obj);
          obj.$noCacheUntil = $player.frameCount + 1500;
        } else {
          $enforceCacheBudget(obj);
        }
      }
    }
    if (c.empty) return true;
    if (useCache) c.lastUsed = $player.frameCount;
    const ctx = this.ctx;
    ctx.save();
    if (obj.$mask) this.clipToMask(obj.$mask);
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    if (blend) ctx.globalCompositeOperation = $COMPOSITE[blend] || 'source-over';
    if (alpha !== 1) ctx.globalAlpha = alpha;
    const dx = Math.round((m[4] - c.tx) * S), dy = Math.round((m[5] - c.ty) * S);
    ctx.drawImage(c.canvas, 0, 0, c.w, c.h, c.gx + dx + this.ox, c.gy + dy + this.oy, c.w, c.h);
    ctx.restore();
    if (obj.$cache !== c) $releaseLayer(c.canvas);
    return true;
  };

  P.buildComposite = function (obj, m, cx, key, filters, keep, reuse, postCx) {
    const S = this.S;
    const seq = $seq;
    const b = obj.$bounds(m);
    if (!b) return null;
    let pad = 0;
    if (filters) {
      for (const f of filters) pad += $filterPad(f);
      pad += 2;
    }
    // device-space rectangle independent of this renderer's offset
    const gx = Math.floor((b[0] - pad) * S), gy = Math.floor((b[1] - pad) * S);
    const w = Math.ceil((b[2] + pad) * S) - gx, h = Math.ceil((b[3] + pad) * S) - gy;
    if (w <= 0 || h <= 0 || w * h > 4096 * 4096) return null;
    let img = $getLayer(w, h);
    const lctx = img.getContext('2d');
    lctx.setTransform(1, 0, 0, 1, 0, 0);
    lctx.clearRect(0, 0, w, h);
    new $Renderer(lctx, S, -gx, -gy).renderObject(obj, m, cx, true, true);
    if (filters) {
      for (const f of filters) {
        const next = $applyFilter(f, img, w, h, S);
        if (next !== img) {
          $releaseLayer(img);
          img = next;
        }
      }
    }
    if (postCx) $colorTransformCanvas(img, w, h, postCx);
    // the result: kept by the object when caching, otherwise a pooled canvas
    let out = img;
    if (keep) {
      // reuse the object's previous bitmap; grow it if needed instead of allocating a new canvas
      out = reuse || $takePooled(w, h) || $newCanvas(w, h);
      if (out.width < w || out.height < h) {
        out.width = Math.max(out.width, w);
        out.height = Math.max(out.height, h);
      }
      const octx = out.getContext('2d');
      octx.setTransform(1, 0, 0, 1, 0, 0);
      octx.clearRect(0, 0, w, h);
      octx.drawImage(img, 0, 0, w, h, 0, 0, w, h);
      $releaseLayer(img);
    }
    return { canvas: out, gx, gy, w, h, tx: m[4], ty: m[5], key, seq, filters: obj.$filters, frame: $player.frameCount };
  };
})($Renderer.prototype);

const $COMPOSITE = {
  multiply: 'multiply', screen: 'screen', lighten: 'lighten', darken: 'darken', difference: 'difference',
  add: 'lighter', subtract: 'difference', invert: 'difference', overlay: 'overlay', hardlight: 'hard-light',
  erase: 'destination-out', alpha: 'destination-in',
};

function $getLayer(w, h) {
  for (let i = 0; i < $layerPool.length; i++) {
    const c = $layerPool[i];
    if (c.width >= w && c.height >= h) {
      $layerPool.splice(i, 1);
      return c;
    }
  }
  // nothing fits: enlarge a pooled canvas rather than allocating another one
  const c = $layerPool.length ? $layerPool.pop() : $newCanvas(64, 64);
  c.width = Math.max(c.width, w, 64);
  c.height = Math.max(c.height, h, 64);
  return c;
}
function $releaseLayer(c) {
  if (!c || $layerPool.indexOf(c) >= 0) return;
  let px = 0;
  for (const p of $layerPool) px += p.width * p.height;
  // keep a few scratch canvases around, free the rest right away
  if ($layerPool.length < 8 && px + c.width * c.height <= 2 * $mainPixels()) $layerPool.push(c);
  else $freeCanvas(c);
}
// a pooled canvas that already fits, or null
// number of drawing primitives in a subtree (stops counting at limit)
function $drawCost(o, limit) {
  let n = 0;
  (function walk(x) {
    if (n >= limit || !x.$visible) return;
    if (x instanceof $SymbolShape || x instanceof $MorphShape) n += Math.max(1, Math.ceil(x.$def.d.length / 4));
    else if (x instanceof $StaticText || x instanceof flash_text_TextField || x instanceof flash_display_Bitmap) n += 2;
    else if (x.$graphics && x.$graphics.$cmds.length) n += 1;
    if (x.$children) for (let i = 0; i < x.$children.length && n < limit; i++) walk(x.$children[i]);
  })(o);
  return n;
}
function $takePooled(w, h) {
  for (let i = 0; i < $layerPool.length; i++) {
    const c = $layerPool[i];
    if (c.width >= w && c.height >= h) {
      $layerPool.splice(i, 1);
      return c;
    }
  }
  return null;
}
let $cmCanvas = null;
function $applyColorMatrix(src, w, h, mtx) {
  if (!$cmCanvas) $cmCanvas = document.createElement('canvas');
  const c = $cmCanvas;
  if (c.width < w || c.height < h) { c.width = Math.max(c.width, w); c.height = Math.max(c.height, h); }
  const ctx = c.getContext('2d', { willReadFrequently: true });
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, c.width, c.height);
  ctx.drawImage(src, 0, 0, w, h, 0, 0, w, h);
  const id = ctx.getImageData(0, 0, w, h);
  const d = id.data;
  const M = mtx;
  for (let i = 0; i < d.length; i += 4) {
    const r = d[i], g = d[i + 1], b = d[i + 2], a = d[i + 3];
    if (!a) continue;
    d[i] = M[0] * r + M[1] * g + M[2] * b + M[3] * a + M[4];
    d[i + 1] = M[5] * r + M[6] * g + M[7] * b + M[8] * a + M[9];
    d[i + 2] = M[10] * r + M[11] * g + M[12] * b + M[13] * a + M[14];
    d[i + 3] = M[15] * r + M[16] * g + M[17] * b + M[18] * a + M[19];
  }
  ctx.putImageData(id, 0, 0);
  return c;
}

// ------------------------------------------------------------------ filters
// Flash blurs with `quality` passes of a box filter of width blurX; approximate it with a
// Gaussian of the same variance.
function $blurSigma(f) {
  const q = Math.max(1, f.quality || 1);
  const bw = Math.max(1, ((f.blurX || 0) + (f.blurY || 0)) / 2);
  return Math.sqrt(q * (bw * bw - 1) / 12);
}
function $filterPad(f) {
  if (f.blurX === undefined) return 0;
  return Math.ceil($blurSigma(f) * 3 + Math.abs(f.distance || 0));
}
function $tmpCanvas(w, h) {
  const c = $getLayer(w, h);
  const ctx = c.getContext('2d');
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.globalAlpha = 1;
  ctx.globalCompositeOperation = 'source-over';
  if ('filter' in ctx) ctx.filter = 'none';
  ctx.clearRect(0, 0, c.width, c.height);
  return c;
}
function $rgbaCss(color, alpha) {
  return 'rgba(' + ((color >> 16) & 255) + ',' + ((color >> 8) & 255) + ',' + (color & 255) + ',' + Math.max(0, Math.min(1, alpha)) + ')';
}
// Draw only the (blurred, offset, coloured) shadow of src into ctx. As in Flash, the shadow's
// alpha is min(1, blurredAlpha * strength) * alpha, computed on the pixels.
function $drawShadow(ctx, src, w, h, color, alpha, sigma, dx, dy, strength) {
  const OFF = 50000;
  const st = strength === undefined ? 1 : strength;
  const t = $tmpCanvas(w, h);
  const tctx = t.getContext('2d');
  tctx.shadowColor = $rgbaCss(color, 1);
  tctx.shadowBlur = Math.max(0, sigma * 2);
  tctx.shadowOffsetX = OFF + dx;
  tctx.shadowOffsetY = dy;
  tctx.drawImage(src, 0, 0, w, h, -OFF, 0, w, h);
  tctx.shadowColor = 'rgba(0,0,0,0)';
  tctx.shadowBlur = 0;
  tctx.shadowOffsetX = tctx.shadowOffsetY = 0;
  const k = st * alpha;
  if (Math.abs(k - 1) > 0.004) {
    const id = tctx.getImageData(0, 0, w, h);
    const d = id.data;
    for (let i = 3; i < d.length; i += 4) {
      const a = d[i] * k;
      d[i] = a > 255 ? 255 : a;
    }
    tctx.putImageData(id, 0, 0);
  }
  ctx.drawImage(t, 0, 0, w, h, 0, 0, w, h);
  $releaseLayer(t);
}
// Returns a canvas (possibly src itself) holding src with filter f applied.
function $applyFilter(f, src, w, h, S) {
  if (f instanceof flash_filters_ColorMatrixFilter) {
    const out = $tmpCanvas(w, h);
    out.getContext('2d').drawImage($applyColorMatrix(src, w, h, f.matrix), 0, 0, w, h, 0, 0, w, h);
    return out;
  }
  if (f instanceof flash_filters_BlurFilter) {
    const out = $tmpCanvas(w, h);
    const ctx = out.getContext('2d');
    if ('filter' in ctx) ctx.filter = 'blur(' + ($blurSigma(f) * S).toFixed(2) + 'px)';
    ctx.drawImage(src, 0, 0, w, h, 0, 0, w, h);
    if ('filter' in ctx) ctx.filter = 'none';
    return out;
  }
  const isGlow = f instanceof flash_filters_GlowFilter;
  const isDs = f instanceof flash_filters_DropShadowFilter;
  const isBevel = f instanceof flash_filters_BevelFilter;
  if (!isGlow && !isDs && !isBevel) return src;
  const sigma = $blurSigma(f) * S;
  const dist = isGlow ? 0 : (f.distance || 0) * S;
  const ang = (f.angle || 0) * $DEG;
  const dx = Math.cos(ang) * dist, dy = Math.sin(ang) * dist;
  const out = $tmpCanvas(w, h);
  const ctx = out.getContext('2d');
  const inner = isBevel ? f.type !== 'outer' : !!f.inner;
  if (!inner) {
    $drawShadow(ctx, src, w, h, f.color, f.alpha, sigma, dx, dy, f.strength);
    if (!f.knockout && !f.hideObject) ctx.drawImage(src, 0, 0, w, h, 0, 0, w, h);
    return out;
  }
  // inner shadow / glow / bevel: the shadow of the inverted shape, kept inside the shape
  const inv = $tmpCanvas(w, h);
  const ictx = inv.getContext('2d');
  ictx.fillStyle = '#000';
  ictx.fillRect(0, 0, w, h);
  ictx.globalCompositeOperation = 'destination-out';
  ictx.drawImage(src, 0, 0, w, h, 0, 0, w, h);
  ictx.globalCompositeOperation = 'source-over';
  const sh = $tmpCanvas(w, h);
  const sctx = sh.getContext('2d');
  if (isBevel) {
    $drawShadow(sctx, inv, w, h, f.shadowColor, f.shadowAlpha, sigma, dx, dy, f.strength);
    $drawShadow(sctx, inv, w, h, f.highlightColor, f.highlightAlpha, sigma, -dx, -dy, f.strength);
  } else {
    $drawShadow(sctx, inv, w, h, f.color, f.alpha, sigma, dx, dy, f.strength);
  }
  ctx.drawImage(src, 0, 0, w, h, 0, 0, w, h);
  ctx.globalCompositeOperation = f.knockout ? 'source-in' : 'source-atop';
  ctx.drawImage(sh, 0, 0, w, h, 0, 0, w, h);
  ctx.globalCompositeOperation = 'source-over';
  $releaseLayer(inv);
  $releaseLayer(sh);
  return out;
}

// Apply a colour transform to the pixels of a canvas in place.
function $colorTransformCanvas(c, w, h, cx) {
  const ctx = c.getContext('2d');
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  const id = ctx.getImageData(0, 0, w, h);
  const d = id.data;
  for (let i = 0; i < d.length; i += 4) {
    const a = d[i + 3];
    if (!a && cx[7] <= 0) continue;
    d[i] = d[i] * cx[0] + cx[4];
    d[i + 1] = d[i + 1] * cx[1] + cx[5];
    d[i + 2] = d[i + 2] * cx[2] + cx[6];
    d[i + 3] = a * cx[3] + cx[7];
  }
  ctx.putImageData(id, 0, 0);
}
