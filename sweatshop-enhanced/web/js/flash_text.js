// TextField / TextFormat rendered with the embedded font outlines from the SWFs.
'use strict';

function flash_text_TextFormat(font = null, size = null, color = null, bold = null, italic = null, underline = null,
  url = null, target = null, align = null, leftMargin = null, rightMargin = null, indent = null, leading = null) {
  this.font = font; this.size = size; this.color = color; this.bold = bold; this.italic = italic;
  this.underline = underline; this.url = url; this.target = target; this.align = align;
  this.leftMargin = leftMargin; this.rightMargin = rightMargin; this.indent = indent; this.leading = leading;
  this.letterSpacing = null; this.kerning = null;
}
$class(flash_text_TextFormat, null, 'flash.text.TextFormat');
flash_text_TextFormat.$KEYS = ['font', 'size', 'color', 'bold', 'italic', 'underline', 'url', 'align', 'leftMargin',
  'rightMargin', 'indent', 'leading', 'letterSpacing'];
function $fmtMerge(base, over) {
  const r = Object.assign({}, base);
  for (const k of flash_text_TextFormat.$KEYS) {
    if (over[k] !== null && over[k] !== undefined) r[k] = over[k];
  }
  return r;
}

const flash_text_TextFieldAutoSize = { LEFT: 'left', RIGHT: 'right', CENTER: 'center', NONE: 'none' };
const flash_text_TextFieldType = { INPUT: 'input', DYNAMIC: 'dynamic' };
const flash_text_AntiAliasType = { ADVANCED: 'advanced', NORMAL: 'normal' };

let $measureCtx = null;
function $measure(css, ch) {
  if (!$measureCtx) $measureCtx = document.createElement('canvas').getContext('2d');
  $measureCtx.font = css;
  return $measureCtx.measureText(ch).width;
}

function flash_text_TextField() {
  flash_display_InteractiveObject.call(this);
  this.$rect = [0, 0, 100, 100];
  this.$lib = null;
  this.$fontRef = null; // $Font of the definition
  this.$paras = [{ align: null, runs: [] }];
  this.$fmt = { font: 'Times New Roman', size: 12, color: 0, bold: false, italic: false, underline: false, align: 'left',
    leftMargin: 0, rightMargin: 0, indent: 0, leading: 0, letterSpacing: 0 };
  this.$autoSize = 'none';
  this.$wordWrap = false;
  this.multiline = false;
  this.embedFonts = false;
  this.$type = 'dynamic';
  this.selectable = true;
  this.border = false;
  this.borderColor = 0;
  this.background = false;
  this.backgroundColor = 0xffffff;
  this.maxChars = 0;
  this.restrict = null;
  this.displayAsPassword = false;
  this.antiAliasType = 'normal';
  this.gridFitType = 'pixel';
  this.sharpness = 0;
  this.thickness = 0;
  this.condenseWhite = false;
  this.scrollV = 1;
  this.scrollH = 0;
  this.mouseWheelEnabled = true;
  this.$layout = null;
  this.tabEnabled = true;
}
$class(flash_text_TextField, flash_display_InteractiveObject, 'flash.text.TextField');

flash_text_TextField.$fromDef = function (lib, def) {
  const tf = new flash_text_TextField();
  tf.$lib = lib;
  tf.$rect = def.r.slice();
  tf.$fontRef = def.font !== undefined ? lib.fonts.get(String(def.font)) || null : null;
  const c = def.color || [0, 0, 0, 255];
  tf.$fmt = {
    font: tf.$fontRef ? tf.$fontRef.name : 'Times New Roman',
    size: def.size || 12,
    color: (c[0] << 16) | (c[1] << 8) | c[2],
    bold: tf.$fontRef ? tf.$fontRef.bold : false,
    italic: false,
    underline: false,
    align: def.align || 'left',
    leftMargin: def.ml || 0,
    rightMargin: def.mr || 0,
    indent: def.indent || 0,
    leading: def.leading || 0,
    letterSpacing: 0,
  };
  tf.$wordWrap = !!def.wrap;
  tf.multiline = !!def.multi;
  tf.embedFonts = !!def.outl;
  tf.selectable = !def.nosel;
  tf.$type = def.ro ? 'dynamic' : 'input';
  tf.border = !!def.border;
  tf.displayAsPassword = !!def.pw;
  tf.maxChars = def.max || 0;
  tf.$autoSize = def.auto ? 'left' : 'none';
  if (def.text !== undefined) {
    if (def.html) {
      tf.$setHtml(def.text);
      // the field's default format is the format of its initial text
      const first = tf.$paras[0] && tf.$paras[0].runs[0];
      if (first) {
        tf.$fmt = Object.assign({}, first.fmt);
        if (tf.$paras[0].align) tf.$fmt.align = tf.$paras[0].align;
      }
    } else {
      tf.$setPlain(def.text);
    }
  }
  return tf;
};

(function (P) {
  P.$dirty = function () {
    this.$layout = null;
    this.$fmtVersion = (this.$fmtVersion || 0) + 1;
    $touch(this);
    if (this.$autoSize !== 'none') this.$applyAutoSize();
  };
  P.$setPlain = function (s) {
    s = s == null ? '' : String(s);
    const parts = s.split(/\r\n|\r|\n/);
    this.$paras = parts.map((t) => ({ align: null, runs: t ? [{ text: t, fmt: Object.assign({}, this.$fmt) }] : [], fmt: Object.assign({}, this.$fmt) }));
    this.$dirty();
  };
  P.$setHtml = function (html) {
    html = html == null ? '' : String(html);
    const doc = new DOMParser().parseFromString('<body>' + html.replace(/<\/?textformat[^>]*>/gi, '') + '</body>', 'text/html');
    const paras = [];
    let cur = { align: null, runs: [], fmt: Object.assign({}, this.$fmt) };
    paras.push(cur);
    const self = this;
    function newPara(align, fmt) {
      if (cur.runs.length === 0 && !cur.used) {
        cur.align = align;
        cur.fmt = fmt;
        cur.used = true;
        return;
      }
      cur = { align, runs: [], fmt, used: true };
      paras.push(cur);
    }
    function walk(node, fmt) {
      for (const n of Array.from(node.childNodes)) {
        if (n.nodeType === 3) {
          let t = n.nodeValue;
          if (self.condenseWhite) t = t.replace(/\s+/g, ' ');
          const pieces = t.split(/\r\n|\r|\n/);
          pieces.forEach((pc, i) => {
            if (i > 0) newPara(cur.align, fmt);
            if (pc) cur.runs.push({ text: pc, fmt });
          });
          continue;
        }
        if (n.nodeType !== 1) continue;
        const tag = n.tagName.toLowerCase();
        let f = fmt;
        if (tag === 'p') {
          f = Object.assign({}, fmt);
          const al = n.getAttribute('align');
          if (al) f.align = al.toLowerCase();
          newPara(al ? al.toLowerCase() : null, f);
          cur.used = true;
          walk(n, f);
          // following content starts a new paragraph
          cur.closed = true;
          cur = { align: null, runs: [], fmt: Object.assign({}, self.$fmt) };
          paras.push(cur);
          continue;
        }
        if (tag === 'br') {
          newPara(cur.align, fmt);
          continue;
        }
        f = Object.assign({}, fmt);
        if (tag === 'font') {
          if (n.hasAttribute('face')) f.font = n.getAttribute('face');
          if (n.hasAttribute('size')) {
            const sz = n.getAttribute('size');
            if (/^[+-]/.test(sz)) f.size = fmt.size + parseFloat(sz); else f.size = parseFloat(sz);
          }
          if (n.hasAttribute('color')) f.color = parseInt(n.getAttribute('color').replace('#', ''), 16) || 0;
          if (n.hasAttribute('letterspacing')) f.letterSpacing = parseFloat(n.getAttribute('letterspacing')) || 0;
        } else if (tag === 'b') f.bold = true;
        else if (tag === 'i') f.italic = true;
        else if (tag === 'u') f.underline = true;
        else if (tag === 'a') f.url = n.getAttribute('href');
        walk(n, f);
      }
    }
    walk(doc.body, Object.assign({}, this.$fmt));
    // drop trailing empty paragraph created after a closing </p>
    while (paras.length > 1 && paras[paras.length - 1].runs.length === 0 && !paras[paras.length - 1].used) paras.pop();
    this.$paras = paras;
    this.$dirty();
  };
  P.$plainText = function () {
    return this.$paras.map((p) => p.runs.map((r) => r.text).join('')).join('\r');
  };
  // Setting the same value again (the HUD does this every frame) changes nothing.
  $accessor(P, 'text', {
    get() { return this.$plainText(); },
    set(v) {
      v = v == null ? '' : String(v);
      if (this.$lastSet === 't' + v && this.$lastFmt === this.$fmtVersion) return;
      this.$setPlain(v);
      this.$lastSet = 't' + v;
      this.$lastFmt = this.$fmtVersion;
    },
  });
  $accessor(P, 'htmlText', {
    get() {
      return this.$paras.map((p) => '<P ALIGN="' + (p.align || this.$fmt.align || 'left').toUpperCase() + '">' +
        p.runs.map((r) => '<FONT FACE="' + r.fmt.font + '" SIZE="' + r.fmt.size + '" COLOR="#' +
          ('000000' + (r.fmt.color >>> 0).toString(16)).slice(-6).toUpperCase() + '">' +
          r.text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;') + '</FONT>').join('') + '</P>').join('');
    },
    set(v) {
      v = v == null ? '' : String(v);
      if (this.$lastSet === 'h' + v && this.$lastFmt === this.$fmtVersion) return;
      this.$setHtml(v);
      this.$lastSet = 'h' + v;
      this.$lastFmt = this.$fmtVersion;
    },
  });
  P.appendText = function (s) { this.$setPlain(this.$plainText() + s); };
  P.replaceText = function (b, e, s) { const t = this.$plainText(); this.$setPlain(t.slice(0, b) + s + t.slice(e)); };
  $accessor(P, 'length', { get() { return this.$plainText().length; } });
  $accessor(P, 'textColor', {
    get() { return this.$fmt.color; },
    set(c) {
      this.$fmt.color = c;
      for (const p of this.$paras) for (const r of p.runs) r.fmt = Object.assign({}, r.fmt, { color: c });
      this.$layout = null;
      $touch(this);
    },
  });
  $accessor(P, 'defaultTextFormat', {
    get() {
      const f = new flash_text_TextFormat();
      Object.assign(f, this.$fmt);
      return f;
    },
    set(f) { this.$fmt = $fmtMerge(this.$fmt, f); this.$fmtVersion = (this.$fmtVersion || 0) + 1; },
  });
  P.setTextFormat = function (f, begin = -1, end = -1) {
    let pos = 0;
    const all = begin < 0;
    for (const p of this.$paras) {
      if (f.align && (all || (pos <= begin && begin <= pos + 1))) p.align = f.align;
      const newRuns = [];
      for (const r of p.runs) {
        const s = pos, e = pos + r.text.length;
        const b0 = all ? s : Math.max(s, begin), e0 = all ? e : Math.min(e, end < 0 ? begin + 1 : end);
        if (b0 >= e0) { newRuns.push(r); pos = e; continue; }
        if (b0 > s) newRuns.push({ text: r.text.slice(0, b0 - s), fmt: r.fmt });
        newRuns.push({ text: r.text.slice(b0 - s, e0 - s), fmt: $fmtMerge(r.fmt, f) });
        if (e0 < e) newRuns.push({ text: r.text.slice(e0 - s), fmt: r.fmt });
        pos = e;
      }
      p.runs = newRuns;
      if (p.fmt) p.fmt = $fmtMerge(p.fmt, f);
      pos += 1;
    }
    this.$dirty();
  };
  P.getTextFormat = function () {
    const f = new flash_text_TextFormat();
    const r = this.$paras[0] && this.$paras[0].runs[0];
    Object.assign(f, r ? r.fmt : this.$fmt);
    if (this.$paras[0] && this.$paras[0].align) f.align = this.$paras[0].align;
    return f;
  };
  $accessor(P, 'autoSize', {
    get() { return this.$autoSize; },
    set(v) { this.$autoSize = v || 'none'; this.$dirty(); },
  });
  $accessor(P, 'wordWrap', {
    get() { return this.$wordWrap; },
    set(v) { this.$wordWrap = !!v; this.$dirty(); },
  });
  $accessor(P, 'type', {
    get() { return this.$type; },
    set(v) { this.$type = v; },
  });
  $accessor(P, 'width', {
    get() { return (this.$rect[2] - this.$rect[0]) * Math.abs(this.$sx); },
    set(v) { this.$rect[2] = this.$rect[0] + v / (Math.abs(this.$sx) || 1); this.$dirty(); },
  });
  $accessor(P, 'height', {
    get() { return (this.$rect[3] - this.$rect[1]) * Math.abs(this.$sy); },
    set(v) { this.$rect[3] = this.$rect[1] + v / (Math.abs(this.$sy) || 1); this.$dirty(); },
  });
  $accessor(P, 'textWidth', { get() { return this.$getLayout().width; } });
  $accessor(P, 'textHeight', { get() { return this.$getLayout().height; } });
  $accessor(P, 'numLines', { get() { return this.$getLayout().lines.length; } });
  $accessor(P, 'maxScrollV', { get() { return 1; } });
  $accessor(P, 'bottomScrollV', { get() { return this.numLines; } });
  $accessor(P, 'caretIndex', { get() { return this.length; } });
  P.setSelection = function () {};
  P.getLineMetrics = function (i) {
    const l = this.$getLayout().lines[i];
    return l ? { x: l.x, width: l.width, height: l.height, ascent: l.ascent, descent: l.descent, leading: l.leading } : null;
  };
  P.getLineText = function (i) {
    const l = this.$getLayout().lines[i];
    return l ? l.glyphs.map((g) => g.ch).join('') : '';
  };

  P.$applyAutoSize = function () {
    const L = this.$getLayout();
    const r = this.$rect;
    if (!this.$wordWrap) {
      const w = L.width + 4;
      const oldW = r[2] - r[0];
      if (this.$autoSize === 'left') r[2] = r[0] + w;
      else if (this.$autoSize === 'right') { r[0] = r[2] - w; }
      else if (this.$autoSize === 'center') { const c = r[0] + oldW / 2; r[0] = c - w / 2; r[2] = c + w / 2; }
      if (oldW !== w) this.$layout = null;
    }
    r[3] = r[1] + L.height + 4;
  };

  P.$resolveFont = function (fmt) {
    let f = null;
    if (this.$fontRef && this.$fontRef.name === fmt.font && this.$fontRef.bold === !!fmt.bold) f = this.$fontRef;
    if (!f && this.embedFonts) f = $fontByName(fmt.font, fmt.bold, this.$lib);
    if (!f && this.$fontRef && this.embedFonts) f = this.$fontRef;
    return f;
  };

  // Layout text into lines of positioned glyphs
  P.$getLayout = function () {
    if (this.$layout) return this.$layout;
    const r = this.$rect;
    const fieldW = r[2] - r[0];
    const lines = [];
    let maxW = 0;
    let y = 0;
    for (const para of this.$paras) {
      const pfmt = para.fmt || this.$fmt;
      const align = para.align || (para.runs[0] && para.runs[0].fmt.align) || pfmt.align || 'left';
      // build glyph list for paragraph
      const glyphs = [];
      for (const run of para.runs) {
        const fmt = run.fmt;
        const font = this.$resolveFont(fmt);
        const size = fmt.size || 12;
        const ls = fmt.letterSpacing || 0;
        let text = run.text;
        if (this.displayAsPassword) text = text.replace(/./g, '*');
        for (const ch of text) {
          const code = ch.codePointAt(0);
          let g = null;
          if (font) g = $findGlyph(font, code);
          if (g) {
            glyphs.push({ ch, font: g[0], gi: g[1], size, adv: g[0].advance(g[1]) * size + ls, color: fmt.color, fmt });
          } else {
            const css = (fmt.italic ? 'italic ' : '') + (fmt.bold ? 'bold ' : '') + size + 'px ' + $cssFontFamily(fmt.font);
            const adv = (this.embedFonts && font) ? (ch === ' ' ? size * 0.25 : 0) : $measure(css, ch);
            glyphs.push({ ch, font: null, css: (this.embedFonts && font) ? null : css, size, adv: adv + ls, color: fmt.color, fmt });
          }
        }
      }
      const metricsFont = (glyphs.find((g) => g.font) || {}).font || this.$resolveFont(pfmt);
      const baseSize = glyphs.length ? Math.max(...glyphs.map((g) => g.size)) : (pfmt.size || 12);
      const asc = (metricsFont ? metricsFont.ascent : 0.9) * baseSize;
      const desc = (metricsFont ? metricsFont.descent : 0.25) * baseSize;
      const leading = pfmt.leading || 0;
      const avail = fieldW - 4 - (pfmt.leftMargin || 0) - (pfmt.rightMargin || 0);
      // word wrap
      let lineStart = 0;
      const pushLine = (from, to) => {
        // trim trailing spaces width for alignment
        const gl = glyphs.slice(from, to);
        let w = 0;
        for (const g of gl) { g.x = w; w += g.adv; }
        let tw = w;
        for (let k = gl.length - 1; k >= 0 && gl[k].ch === ' '; k--) tw -= gl[k].adv;
        const lsLast = gl.length ? (gl[gl.length - 1].fmt.letterSpacing || 0) : 0;
        tw -= lsLast;
        lines.push({ glyphs: gl, width: Math.max(0, tw), ascent: asc, descent: desc, leading, y, align,
          lm: pfmt.leftMargin || 0, rm: pfmt.rightMargin || 0, height: asc + desc + leading });
        if (tw > maxW) maxW = tw;
        y += asc + desc + leading;
      };
      if (!glyphs.length) {
        pushLine(0, 0);
        continue;
      }
      if (this.$wordWrap) {
        let w = 0;
        let lastBreak = -1;
        for (let i = lineStart; i < glyphs.length; i++) {
          const g = glyphs[i];
          if (g.ch === ' ' || g.ch === '-') lastBreak = i;
          w += g.adv;
          if (w > avail && i > lineStart && g.ch !== ' ') {
            let brk = lastBreak >= lineStart ? lastBreak + 1 : i;
            if (brk <= lineStart) brk = i;
            pushLine(lineStart, brk);
            lineStart = brk;
            // skip leading spaces
            w = 0;
            for (let k = lineStart; k <= i; k++) w += glyphs[k].adv;
            lastBreak = -1;
          }
        }
        pushLine(lineStart, glyphs.length);
      } else {
        pushLine(0, glyphs.length);
      }
    }
    const last = lines[lines.length - 1];
    const height = last ? y - last.leading : 0;
    this.$layout = { lines, width: maxW, height };
    return this.$layout;
  };

  P.$contentBounds = function (m) { return $boundsOf(this.$rect, m); };
  P.$hitSelf = function (x, y, m) {
    const p = $apply($inv(m), x, y);
    const r = this.$rect;
    return p[0] >= r[0] && p[0] <= r[2] && p[1] >= r[1] && p[1] <= r[3];
  };
  P.$draw = function (rd, m, cx) {
    const L = this.$getLayout();
    const ctx = rd.ctx;
    const r = this.$rect;
    if (this.background || this.border) {
      rd.setT(m);
      if (this.background) {
        const c = this.backgroundColor;
        ctx.fillStyle = $cssColor([(c >> 16) & 255, (c >> 8) & 255, c & 255, 255], cx);
        ctx.fillRect(r[0], r[1], r[2] - r[0], r[3] - r[1]);
      }
      if (this.border) {
        const c = this.borderColor;
        ctx.strokeStyle = $cssColor([(c >> 16) & 255, (c >> 8) & 255, c & 255, 255], cx);
        ctx.lineWidth = 1;
        ctx.strokeRect(r[0] + 0.5, r[1] + 0.5, r[2] - r[0] - 1, r[3] - r[1] - 1);
      }
    }
    if (this.$editing) return; // DOM input overlay shows the text
    const fieldW = r[2] - r[0];
    ctx.save();
    rd.setT(m);
    ctx.beginPath();
    ctx.rect(r[0], r[1], r[2] - r[0], r[3] - r[1]);
    ctx.clip();
    for (const line of L.lines) {
      let x0 = r[0] + 2 + line.lm;
      const avail = fieldW - 4 - line.lm - line.rm;
      if (line.align === 'center') x0 += (avail - line.width) / 2;
      else if (line.align === 'right') x0 += avail - line.width;
      const base = r[1] + 2 + line.y + line.ascent;
      if (base - line.ascent > r[3] + 2) break;
      for (const g of line.glyphs) {
        const color = [(g.color >> 16) & 255, (g.color >> 8) & 255, g.color & 255, 255];
        if (g.font) {
          rd.drawGlyph(g.font, g.gi, x0 + g.x, base, g.size, m, color, cx);
        } else if (g.css && g.ch !== ' ') {
          rd.setT(m);
          ctx.font = g.css;
          ctx.fillStyle = $cssColor(color, cx);
          ctx.textBaseline = 'alphabetic';
          ctx.fillText(g.ch, x0 + g.x, base);
        }
      }
    }
    ctx.restore();
  };
})(flash_text_TextField.prototype);

function $cssFontFamily(name) {
  if (!name || name === '_sans') return 'Arial, Helvetica, sans-serif';
  if (/vag/i.test(name)) return '"SweatshopVAG", "VAG Rounded", "Arial Rounded MT Bold", Arial, sans-serif';
  if (name === '_serif' || /times/i.test(name)) return '"Times New Roman", serif';
  if (name === '_typewriter') return 'monospace';
  return '"' + name + '", Arial, sans-serif';
}
