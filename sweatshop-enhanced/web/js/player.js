// The "player": owns the stage, runs frames, renders to the canvas and turns DOM input
// into Flash-style mouse / keyboard events.
'use strict';

const $mouse = { x: 0, y: 0, down: false };

const $player = {
  stage: null,
  canvas: null,
  ctx: null,
  scale: 1,
  hover: null,
  downTarget: null,
  input: null, // DOM <input> used while a TextField is being edited
  editing: null,
  frameCount: 0,
  errors: 0,
};

function $startPlayer(canvas, stage) {
  $player.canvas = canvas;
  $player.ctx = canvas.getContext('2d');
  $player.stage = stage;
  $resizeCanvas();
  window.addEventListener('resize', $resizeCanvas);
  $installInput(canvas);
  // If the browser discards the canvas (low graphics memory, GPU reset), drop every cached
  // bitmap - their contents are gone too - and redraw right away when it comes back.
  canvas.addEventListener('contextlost', (e) => { e.preventDefault(); $cacheEpoch++; });
  canvas.addEventListener('contextrestored', () => {
    $cacheEpoch++;
    for (const o of Array.from($cachedObjs)) $dropCache(o);
    $layerPool.length = 0;
    $render();
  });
  let next = performance.now();
  function loop(now) {
    requestAnimationFrame(loop);
    try {
      $tickTimers(now);
    } catch (e) {
      $reportError(e);
    }
    const interval = 1000 / ($player.stage.frameRate || 25);
    if (now >= next) {
      next += interval;
      if (now - next > 250) next = now + interval; // fell behind (tab was hidden): don't fast-forward
      $doFrame();
      $render();
      $pauseHiddenVideos();
    }
  }
  requestAnimationFrame(loop);
}

function $reportError(e) {
  $player.errors++;
  console.error(e);
  if ($player.errors <= 3 && typeof $showError === 'function') $showError(e);
}

function $collectClips(o, out) {
  if (o instanceof flash_display_MovieClip) out.push(o);
  const ch = o.$children;
  if (ch) for (let i = 0; i < ch.length; i++) $collectClips(ch[i], out);
}

function $doFrame() {
  $player.frameCount++;
  const stage = $player.stage;
  // 1. advance the timelines of every movie clip on the display list
  const clips = [];
  $collectClips(stage, clips);
  for (const mc of clips) {
    try {
      mc.$advance();
    } catch (e) {
      $reportError(e);
    }
  }
  // 2. enterFrame is broadcast to every listener, on or off the display list
  for (const o of Array.from($enterFrameListeners)) {
    if (!o.$listeners || !o.$listeners.enterFrame || !o.$listeners.enterFrame.length) continue;
    try {
      o.dispatchEvent(new flash_events_Event('enterFrame'));
    } catch (e) {
      $reportError(e);
    }
  }
  // 3. things may have moved under a stationary mouse pointer
  if ($player.frameCount % 3 === 0) $updateHover(null);
  if ($player.editing) $positionInput();
}

function $render() {
  $renderCount++;
  const ctx = $player.ctx;
  const c = $player.canvas;
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.globalAlpha = 1;
  ctx.globalCompositeOperation = 'source-over';
  ctx.fillStyle = '#000';
  ctx.fillRect(0, 0, c.width, c.height);
  const r = new $Renderer(ctx, $player.scale);
  try {
    r.renderObject($player.stage, $ID, null, false);
  } catch (e) {
    $reportError(e);
    ctx.restore();
  }
}

function $resizeCanvas() {
  const c = $player.canvas;
  const W = $player.stage.stageWidth, H = $player.stage.stageHeight;
  const wrap = c.parentElement;
  const availW = wrap.clientWidth, availH = wrap.clientHeight;
  // ?scale=N renders at a fixed scale in the top-left corner (used for pixel comparisons)
  const fixed = parseFloat($flags.scale);
  const s = fixed > 0 ? fixed : Math.max(0.1, Math.min(availW / W, availH / H));
  if (fixed > 0) document.body.classList.add('fixed-scale');
  const cssW = Math.floor(W * s), cssH = Math.floor(H * s);
  const dpr = window.devicePixelRatio || 1;
  c.style.width = cssW + 'px';
  c.style.height = cssH + 'px';
  c.width = Math.round(cssW * dpr);
  c.height = Math.round(cssH * dpr);
  $player.scale = c.width / W;
  if ($player.editing) $positionInput();
  if ($player.frameCount) $render();
}

// ------------------------------------------------------------------ mouse
function $stagePoint(e) {
  const r = $player.canvas.getBoundingClientRect();
  return [(e.clientX - r.left) / r.width * $player.stage.stageWidth, (e.clientY - r.top) / r.height * $player.stage.stageHeight];
}

function $ancestors(o) {
  const out = [];
  while (o) { out.push(o); o = o.$parent; }
  return out;
}

function $mouseEvent(type, target, bubbles = true, related = null) {
  const e = new flash_events_MouseEvent(type, bubbles);
  e.stageX = $mouse.x;
  e.stageY = $mouse.y;
  e.buttonDown = $mouse.down;
  e.relatedObject = related;
  try {
    const p = target.globalToLocal(new flash_geom_Point($mouse.x, $mouse.y));
    e.localX = p.x;
    e.localY = p.y;
  } catch (err) { /* ignore */ }
  try {
    target.dispatchEvent(e);
  } catch (err) {
    $reportError(err);
  }
}

function $findMouseTarget() {
  const stage = $player.stage;
  let t = null;
  try {
    t = $findTarget(stage, $mouse.x, $mouse.y, $ID);
  } catch (e) {
    $reportError(e);
  }
  return t || stage;
}

function $buttonState(btn) {
  if (!(btn instanceof flash_display_SimpleButton)) return;
  if (!btn.enabled) { btn.$setVisualState('up'); return; }
  const over = $player.hover === btn;
  if (over && $mouse.down && $player.downTarget === btn) btn.$setVisualState('down');
  else if (over && !$mouse.down) btn.$setVisualState('over');
  else if (over && $player.downTarget === btn) btn.$setVisualState('down');
  else btn.$setVisualState('up');
}

function $updateHover(domEvent) {
  const t = $findMouseTarget();
  const old = $player.hover;
  if (t !== old) {
    $player.hover = t;
    const oldChain = old ? $ancestors(old) : [];
    const newChain = $ancestors(t);
    if (old) {
      $mouseEvent('mouseOut', old, true, t);
      for (const o of oldChain) if (!newChain.includes(o)) $mouseEvent('rollOut', o, false, t);
      $buttonState(old);
    }
    $mouseEvent('mouseOver', t, true, old);
    for (let i = newChain.length - 1; i >= 0; i--) {
      const o = newChain[i];
      if (!oldChain.includes(o)) $mouseEvent('rollOver', o, false, old);
    }
    $buttonState(t);
  }
  // hand cursor
  let cursor = 'default';
  for (const o of $ancestors(t)) {
    if (o instanceof flash_display_SimpleButton && o.useHandCursor && o.enabled) { cursor = 'pointer'; break; }
    if (o instanceof flash_display_Sprite && o.buttonMode && o.useHandCursor) { cursor = 'pointer'; break; }
  }
  if (t instanceof flash_text_TextField && t.type === 'input') cursor = 'text';
  if ($player.canvas.style.cursor !== cursor) $player.canvas.style.cursor = cursor;
  return t;
}

function $installInput(canvas) {
  canvas.addEventListener('pointermove', (e) => {
    [$mouse.x, $mouse.y] = $stagePoint(e);
    const t = $updateHover(e);
    $mouseEvent('mouseMove', t, true);
  });
  canvas.addEventListener('pointerdown', (e) => {
    if (e.button !== 0) return;
    e.preventDefault();
    canvas.focus();
    try { canvas.setPointerCapture(e.pointerId); } catch (err) { /* ignore */ }
    [$mouse.x, $mouse.y] = $stagePoint(e);
    $mouse.down = true;
    const t = $updateHover(e);
    $player.downTarget = t;
    if (t instanceof flash_text_TextField && t.type === 'input') {
      $player.stage.focus = t;
    } else if ($player.editing) {
      $endEdit();
    }
    $mouseEvent('mouseDown', t, true);
    $buttonState(t);
  });
  const up = (e) => {
    if (!$mouse.down) return;
    [$mouse.x, $mouse.y] = $stagePoint(e);
    $mouse.down = false;
    const t = $updateHover(e);
    $mouseEvent('mouseUp', t, true);
    const down = $player.downTarget;
    $player.downTarget = null;
    if (t === down) $mouseEvent('click', t, true);
    $buttonState(t);
    if (down && down !== t) $buttonState(down);
  };
  canvas.addEventListener('pointerup', up);
  canvas.addEventListener('pointercancel', up);
  canvas.addEventListener('pointerleave', () => {
    if ($mouse.down) return;
    const old = $player.hover;
    if (old && old !== $player.stage) {
      $player.hover = $player.stage;
      $mouseEvent('mouseOut', old, true, null);
      for (const o of $ancestors(old)) if (o !== $player.stage) $mouseEvent('rollOut', o, false, null);
      $buttonState(old);
    }
    $player.stage.dispatchEvent(new flash_events_Event('mouseLeave'));
  });
  canvas.addEventListener('contextmenu', (e) => e.preventDefault());

  // keyboard
  const keyEvent = (type, e) => {
    if ($player.editing && document.activeElement === $player.input) return; // typing into a text field
    const ke = new flash_events_KeyboardEvent(type, true, false, e.key && e.key.length === 1 ? e.key.charCodeAt(0) : 0, $keyCode(e));
    ke.shiftKey = e.shiftKey;
    ke.ctrlKey = e.ctrlKey;
    ke.altKey = e.altKey;
    const target = $player.stage.focus && $player.stage.focus.stage ? $player.stage.focus : $player.stage;
    try {
      target.dispatchEvent(ke);
    } catch (err) {
      $reportError(err);
    }
    if ([32, 37, 38, 39, 40, 8].includes(ke.keyCode)) e.preventDefault();
  };
  window.addEventListener('keydown', (e) => keyEvent('keyDown', e));
  window.addEventListener('keyup', (e) => keyEvent('keyUp', e));
  window.addEventListener('blur', () => {
    $player.stage.dispatchEvent(new flash_events_Event('deactivate'));
  });
  window.addEventListener('focus', () => {
    $player.stage.dispatchEvent(new flash_events_Event('activate'));
  });
}

function $keyCode(e) {
  if (e.keyCode) return e.keyCode;
  const map = { ArrowLeft: 37, ArrowUp: 38, ArrowRight: 39, ArrowDown: 40, Enter: 13, Escape: 27, ' ': 32, Backspace: 8 };
  if (map[e.key] !== undefined) return map[e.key];
  return e.key && e.key.length === 1 ? e.key.toUpperCase().charCodeAt(0) : 0;
}

// ------------------------------------------------------------------ text input (TextField.type == "input")
// AS3 TextField.restrict: characters allowed in the field ("A-Z0-9", "^" starts an exclusion list)
function $restrictRegex(restrict) {
  if (!restrict) return null;
  let allow = '';
  let deny = '';
  let neg = false;
  for (let i = 0; i < restrict.length; i++) {
    let c = restrict[i];
    let piece;
    if (c === '\\' && i + 1 < restrict.length) {
      piece = '\\' + restrict[++i];
    } else if (c === '^') {
      neg = !neg;
      continue;
    } else if (c === '-' && i > 0 && i + 1 < restrict.length) {
      piece = '-';
    } else {
      piece = c.replace(/[[\]\\^-]/g, '\\$&');
    }
    if (neg) deny += piece; else allow += piece;
  }
  let allowRe = null, denyRe = null;
  try {
    if (allow) allowRe = new RegExp('^[' + allow + ']$');
    if (deny) denyRe = new RegExp('^[' + deny + ']$');
  } catch (e) {
    return null;
  }
  return { test: (ch) => (!allowRe || allowRe.test(ch)) && !(denyRe && denyRe.test(ch)) };
}

function $beginEdit(tf) {
  if ($player.editing === tf) return;
  if ($player.editing) $endEdit();
  let input = $player.input;
  if (!input) {
    input = $player.input = document.createElement('input');
    input.type = 'text';
    input.autocomplete = 'off';
    input.spellcheck = false;
    input.className = 'flash-input';
    document.body.appendChild(input);
    input.addEventListener('input', () => {
      const tf2 = $player.editing;
      if (!tf2) return;
      const re = $restrictRegex(tf2.restrict);
      let v = input.value;
      if (re) v = Array.from(v).filter((ch) => re.test(ch)).join('');
      if (tf2.maxChars > 0 && v.length > tf2.maxChars) v = v.slice(0, tf2.maxChars);
      if (v !== input.value) input.value = v;
      tf2.text = v;
      try {
        tf2.dispatchEvent(new flash_events_TextEvent('textInput', true, false, v));
        tf2.dispatchEvent(new flash_events_Event('change', true));
      } catch (err) {
        $reportError(err);
      }
    });
    input.addEventListener('keydown', (e) => {
      const tf2 = $player.editing;
      if (!tf2) return;
      if (e.key === 'Enter' || e.key === 'Escape') {
        const ke = new flash_events_KeyboardEvent('keyDown', true, false, 0, e.key === 'Enter' ? 13 : 27);
        try { tf2.dispatchEvent(ke); } catch (err) { $reportError(err); }
        if (e.key === 'Escape') $endEdit();
        e.preventDefault();
      }
    });
    input.addEventListener('blur', () => {
      setTimeout(() => {
        if ($player.editing && document.activeElement !== input) $endEdit();
      }, 0);
    });
  }
  $player.editing = tf;
  tf.$editing = true;
  $touch(tf);
  input.value = tf.text;
  input.maxLength = tf.maxChars > 0 ? tf.maxChars : 524288;
  input.style.display = 'block';
  $positionInput();
  setTimeout(() => { input.focus(); input.setSelectionRange(input.value.length, input.value.length); }, 0);
}

function $endEdit() {
  const tf = $player.editing;
  if (!tf) return;
  tf.$editing = false;
  $player.editing = null;
  $touch(tf);
  if ($player.input) {
    $player.input.style.display = 'none';
    $player.input.blur();
  }
  if ($player.stage.$focus === tf) $player.stage.$focus = null;
  try { tf.dispatchEvent(new flash_events_FocusEvent('focusOut')); } catch (err) { $reportError(err); }
}

function $positionInput() {
  const tf = $player.editing;
  const input = $player.input;
  if (!tf || !input) return;
  if (!tf.stage || !tf.$visible) {
    $endEdit();
    return;
  }
  const b = tf.getBounds(null);
  const r = $player.canvas.getBoundingClientRect();
  const k = r.width / $player.stage.stageWidth;
  const fmt = (tf.$paras[0] && tf.$paras[0].runs[0]) ? tf.$paras[0].runs[0].fmt : tf.$fmt;
  const m = tf.$globalMatrix();
  const sy = Math.sqrt(m[2] * m[2] + m[3] * m[3]);
  input.style.left = (r.left + window.scrollX + b.x * k) + 'px';
  input.style.top = (r.top + window.scrollY + b.y * k) + 'px';
  input.style.width = Math.max(20, b.width * k) + 'px';
  input.style.height = Math.max(10, b.height * k) + 'px';
  input.style.fontSize = ((fmt.size || 12) * sy * k) + 'px';
  input.style.fontFamily = $cssFontFamily(fmt.font);
  input.style.fontWeight = fmt.bold ? 'bold' : 'normal';
  const c = fmt.color || 0;
  input.style.color = '#' + ('000000' + (c >>> 0).toString(16)).slice(-6);
  input.style.textAlign = (tf.$paras[0] && tf.$paras[0].align) || fmt.align || 'left';
}

// Stage.focus = textField starts editing it (NameScreen does this)
(function () {
  const desc = Object.getOwnPropertyDescriptor(flash_display_Stage.prototype, 'focus');
  Object.defineProperty(flash_display_Stage.prototype, 'focus', {
    configurable: true,
    get: desc.get,
    set(v) {
      desc.set.call(this, v);
      if (v instanceof flash_text_TextField && v.type === 'input') $beginEdit(v);
      else if ($player.editing && v !== $player.editing) $endEdit();
    },
  });
})();
