// Boot: load the converted assets, then start the original game code (ss.app.Main).
'use strict';

const $ASSET_BASE = 'assets/';
const $EMBEDDED_FILES = [
  'ss.app.GlobalUI_UI_JSON',
  'ss.app.process.GetLocalDataProcess__d',
  'ss.game.components.ui.HUDRenderer_HUDXML',
];

function $showError(e) {
  const box = document.getElementById('error');
  if (!box) return;
  box.style.display = 'block';
  const msg = (e && (e.stack || e.message)) || String(e);
  box.textContent += (box.textContent ? '\n\n' : '') + msg;
}

async function $boot() {
  const bar = document.getElementById('bar');
  const status = document.getElementById('status');
  const setProgress = (f) => { bar.style.width = Math.round(f * 100) + '%'; };
  try {
    status.textContent = 'Loading data…';
    if (document.fonts) document.fonts.load('20px SweatshopVAG').catch(() => {});
    await Promise.all($EMBEDDED_FILES.map((name) => fetch($ASSET_BASE + name + '.txt').then((r) => {
      if (!r.ok) throw new Error('Could not load ' + name + ' (' + r.status + ')');
      return r.text();
    }).then((t) => { $embedded[name] = t; })));

    status.textContent = 'Loading graphics and sound…';
    const jsons = await Promise.all($LIBRARY_NAMES.map((name) => fetch($ASSET_BASE + name + '.json').then((r) => {
      if (!r.ok) throw new Error('Could not load ' + name + '.json (' + r.status + ')');
      return r.json();
    })));
    const libs = jsons.map((json, i) => new $Library($LIBRARY_NAMES[i], json, $ASSET_BASE));
    const total = libs.reduce((n, l) => n + l.mediaCount(), 0) || 1;
    let done = 0;
    await Promise.all(libs.map((l) => l.loadMedia(() => setProgress(++done / total))));
    setProgress(1);
  } catch (e) {
    status.textContent = 'Loading failed.';
    if (location.protocol === 'file:') {
      status.textContent = 'Loading failed: the game must be opened through a web server (see README).';
    }
    $showError(e);
    return;
  }

  // Browsers only allow sound after the first click, so ask for one before starting.
  status.textContent = '';
  const start = document.getElementById('start');
  start.style.display = 'block';
  await new Promise((resolve) => start.addEventListener('click', resolve, { once: true }));
  await $audio.resume();
  document.getElementById('loader').style.display = 'none';
  $startGame();
}

function $startGame() {
  const canvas = document.getElementById('stage');
  const stage = new flash_display_Stage();
  $player.stage = stage;
  try {
    const main = new ss_app_Main();
    stage.addChild(main);
  } catch (e) {
    $showError(e);
    throw e;
  }
  $startPlayer(canvas, stage);
  canvas.focus();
}

window.addEventListener('error', (e) => $showError(e.error || e.message));
window.addEventListener('DOMContentLoaded', $boot);
