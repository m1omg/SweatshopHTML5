// Improvements over the original game (everything else in this folder is a 1:1 port).
// Kept in this separate file so the translated original code stays untouched.
'use strict';

// Address shared by the "Post to Facebook" / "Post to Twitter" buttons. Leave empty for
// automatic: the game's own address when it is hosted on the web, otherwise (when playing
// from your own computer) the Wikipedia article about the game.
const $SHARE_URL = '';
const $SHARE_FALLBACK_URL = 'https://en.wikipedia.org/wiki/Sweatshop_(video_game)';

// ------------------------------------------------------------------ 1. Skip button from the first play
// The original only offered "Skip" for story dialogs of levels you had already played
// (Game.user.hasReadLevel). Treat every level as read; the flag is used for nothing else.
Object.defineProperty(ss_game_data_User.prototype, 'hasReadLevel', {
  configurable: true,
  get() { return true; },
  set(v) { /* ignored */ },
});

// ------------------------------------------------------------------ 2. Sharing on today's Facebook
function $shareUrl() {
  if ($SHARE_URL) return $SHARE_URL;
  const h = location.hostname;
  const local = location.protocol === 'file:' || h === 'localhost' || h.endsWith('.local') || h === '[::1]' ||
    /^(127\.|10\.|0\.0\.0\.0$|192\.168\.|172\.(1[6-9]|2\d|3[01])\.)/.test(h);
  return local ? $SHARE_FALLBACK_URL : location.origin + location.pathname;
}

function $isTouchDevice() {
  return !!(window.matchMedia && matchMedia('(pointer: coarse)').matches);
}

function $copyText(text) {
  if (navigator.clipboard && window.isSecureContext) {
    return navigator.clipboard.writeText(text).then(() => true, () => $copyTextFallback(text));
  }
  return Promise.resolve($copyTextFallback(text));
}
function $copyTextFallback(text) {
  const ta = document.createElement('textarea');
  ta.value = text;
  ta.style.position = 'fixed';
  ta.style.opacity = '0';
  document.body.appendChild(ta);
  ta.select();
  let ok = false;
  try { ok = document.execCommand('copy'); } catch (e) { ok = false; }
  ta.remove();
  return ok;
}

let $toastTimer = 0;
function $toast(message) {
  let el = document.getElementById('toast');
  if (!el) {
    el = document.createElement('div');
    el.id = 'toast';
    document.body.appendChild(el);
  }
  el.textContent = message;
  el.classList.add('show');
  clearTimeout($toastTimer);
  $toastTimer = setTimeout(() => el.classList.remove('show'), 6000);
}

ss_remote_Social.prototype.share = function (shareable, target) {
  this._currentShareable = shareable;
  const url = $shareUrl();
  if (target == ss_remote_Social.FACEBOOK) {
    const text = (shareable && shareable.facebookCopy) || 'I\'m playing Sweatshop!';
    if ($isTouchDevice() && navigator.share) {
      // phones / tablets: the system share sheet, which offers the Facebook app
      navigator.share({ title: 'Sweatshop', text, url }).catch(() => {});
    } else {
      // Facebook no longer lets websites pre-fill the post text, so put it on the clipboard
      // and open Facebook's share dialog for the link.
      const win = window.open('https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(url),
        'sweatshop_facebook', 'width=640,height=560');
      $copyText(text).then((ok) => {
        if (!win) $toast('Your browser blocked the Facebook window – please allow pop-ups for this page and try again.');
        else if (ok) $toast('Your message is copied – paste it (Ctrl+V) into the Facebook post: "' + text + '"');
        else $toast('Add your message to the Facebook post: "' + text + '"');
      });
    }
  } else if (target == ss_remote_Social.TWITTER && shareable && shareable.twitterCopy) {
    // the original short link (bit.ly/playss) pointed at the long gone playsweatshop.com
    const text = shareable.twitterCopy.replace(/https?:\/\/bit\.ly\/playss/, url);
    const withUrl = text.indexOf(url) >= 0 ? text : text + ' ' + url;
    window.open('https://twitter.com/intent/tweet?text=' + encodeURIComponent(withUrl), '_blank', 'noopener');
  }
  setTimeout(() => this.dispatchEvent(new org_fatlib_events_CustomEvent(flash_events_Event.COMPLETE, {})), 0);
};

// ------------------------------------------------------------------ 3. Seven save slots
// The original save menu has three slots. Show seven: the extra rows (and their "erase?"
// confirmations) are copies of the original ones, and all rows are drawn at 53% size in one
// column filling the same panel. Saves stay where they were: slot n is still entry n of the
// "sweatshop" shared object.
const $SAVE_SLOTS = 7;

function $sevenSlotRows(page) {
  if (page.slot7) return;
  const copy = (mc) => mc.$sym.lib.createCharacter(mc.$sym.id);
  const s = 0.53;
  for (let n = 1; n <= $SAVE_SLOTS; n++) {
    let row = page['slot' + n], confirm = page['confirm' + n];
    if (!row) {
      row = page['slot' + n] = page.addChild(copy(page.slot1));
      row.name = 'slot' + n;
      confirm = page['confirm' + n] = page.addChild(copy(page.confirm1));
      confirm.name = 'confirm' + n;
    }
    // (page coordinates; a row is about 337 x 47 at full size and the originals are 57 apart,
    // its confirmation sits by its trash can)
    row.x = 104;
    row.y = 7 + (n - 1) * 57 * s;
    row.scaleX = row.scaleY = s;
    confirm.x = row.x + 297.75 * s;
    confirm.y = row.y + 25.4 * s;
    confirm.scaleX = confirm.scaleY = s;
  }
  for (let n = 1; n <= $SAVE_SLOTS; n++) page.addChild(page['confirm' + n]); // above every row
}

ss_app_screens_title_SlotsScreen.prototype.handleAdded = function () {
  $sevenSlotRows(this.mc);
  for (let n = 1; n <= $SAVE_SLOTS; n++) {
    this.mc['confirm' + n].visible = false;
    const row = this.mc['slot' + n];
    row.num.text = n + '.';
    row.num.mouseEnabled = row.num.tabEnabled = false;
    row.username.mouseEnabled = row.username.tabEnabled = false;
    const info = this.slotsManager.getInfo(n);
    row.username.text = info ? info.username : ss_app_App.instance.text.getText('title.slots.new');
    row.trash.visible = !!info;
  }
  this.slotsManager.isNewGame = false;
  this.mc.addEventListener(flash_events_MouseEvent.CLICK, $b(this, 'onClick$SlotsScreen'));
};

const $slotsClick = ss_app_screens_title_SlotsScreen.prototype.onClick$SlotsScreen;
ss_app_screens_title_SlotsScreen.prototype.onClick$SlotsScreen = function (e) {
  // (the original only knows slot1-slot3)
  const m = e.target.parent && /^slot(\d+)$/.exec(e.target.parent.name);
  if (m) this._selectedSlot = +m[1];
  return $slotsClick.call(this, e);
};

function $slotButtons(page, on) {
  for (let n = 1; n <= $SAVE_SLOTS; n++) {
    const row = page['slot' + n];
    if (row) row.mouseChildren = row.mouseEnabled = row.tabChildren = row.tabEnabled = on;
  }
}
ss_app_screens_title_SlotsScreen.prototype.disableButtons = function () { $slotButtons(this.mc, false); };
ss_app_screens_title_SlotsScreen.prototype.enableButtons = function () { $slotButtons(this.mc, true); };

ss_app_screens_TitleScreen.prototype.refreshSlotInfo = function () {
  for (let n = 1; n <= $SAVE_SLOTS; n++) {
    const data = ss_app_App.instance.cookies.getSlotData(n);
    let info = null;
    if (data) {
      info = new ss_data_Session();
      info.loadFromObject(data);
    }
    this._slots.setInfo(n, info);
  }
};

// ------------------------------------------------------------------ 4. Save files
// "Export" (under the game) downloads every save slot as a small file; "Import" loads the saves
// from such a file into the same slots - to keep a backup, or to move saves to another device
// or between the online and the local copy. Other slots are left alone.
const $SAVE_KEY = 'so_sweatshop';

function $storedSaves() {
  try {
    return JSON.parse(localStorage.getItem($SAVE_KEY) || '{}') || {};
  } catch (e) {
    return {};
  }
}
// the filled slots of saved data, e.g. [1, 5]
function $filledSlots(data) {
  const out = [];
  for (let n = 1; n <= $SAVE_SLOTS; n++) {
    const s = data[n];
    if (s && typeof s === 'object' && s.levels && typeof s.levels === 'object') out.push(n);
  }
  return out;
}
const $plural = (n, word) => n + ' ' + word + (n === 1 ? '' : 's');

function $exportSaves() {
  $flushSharedObjects();
  const data = $storedSaves();
  const slots = $filledSlots(data);
  if (!slots.length) {
    $toast('There are no saves to export yet.');
    return;
  }
  const file = { game: 'Sweatshop', kind: 'saves', version: 1, exported: new Date().toISOString(), data };
  const a = document.createElement('a');
  a.href = URL.createObjectURL(new Blob([JSON.stringify(file)], { type: 'application/json' }));
  a.download = 'sweatshop-saves-' + new Date().toISOString().slice(0, 10) + '.json';
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 60000);
  $toast('Exported ' + $plural(slots.length, 'save') + ' (slot ' + slots.join(', ') + ') to ' + a.download);
}

function $importSaves(fileObj) {
  const reader = new FileReader();
  reader.onload = () => {
    let saves = null;
    try {
      const f = JSON.parse(reader.result);
      if (f && f.kind === 'saves' && f.data && typeof f.data === 'object') saves = f.data;
    } catch (e) { /* not a save file */ }
    const slots = saves ? $filledSlots(saves) : [];
    if (!slots.length) {
      $toast('That file has no Sweatshop saves in it.');
      return;
    }
    const current = $storedSaves();
    const replaced = slots.filter((n) => current[n]);
    if (!confirm('Load ' + $plural(slots.length, 'save') + ' from the file into slot ' + slots.join(', ') + '?' +
      (replaced.length ? '\n\nThis replaces the save' + (replaced.length > 1 ? 's' : '') + ' now in slot ' + replaced.join(', ') + '.' : '') +
      '\n\nThe game restarts to load them.')) return;
    for (const n of slots) current[n] = saves[n];
    const json = JSON.stringify(current);
    try {
      localStorage.setItem($SAVE_KEY, json);
    } catch (e) {
      $toast('Could not store the saves: ' + e.message);
      return;
    }
    // keep the running game from writing its older copy back before the restart
    const so = flash_net_SharedObject.$cache.sweatshop;
    if (so) {
      so.data = current;
      so.$saved = json;
    }
    try { sessionStorage.setItem('sweatshop-imported', String(slots.length)); } catch (e) { /* no message then */ }
    location.reload();
  };
  reader.readAsText(fileObj);
}

(function () {
  const exportBtn = document.getElementById('export-saves');
  const importBtn = document.getElementById('import-saves');
  const fileInput = document.getElementById('import-file');
  if (!exportBtn) return;
  // (buttons don't keep the keyboard focus: Space and P belong to the game)
  const backToGame = () => { if ($player.canvas) $player.canvas.focus(); };
  exportBtn.addEventListener('click', () => { $exportSaves(); backToGame(); });
  importBtn.addEventListener('click', () => { fileInput.click(); backToGame(); });
  fileInput.addEventListener('change', () => {
    if (fileInput.files[0]) $importSaves(fileInput.files[0]);
    fileInput.value = '';
  });
  try {
    const n = sessionStorage.getItem('sweatshop-imported');
    if (n) {
      sessionStorage.removeItem('sweatshop-imported');
      $toast('Loaded ' + $plural(+n, 'save') + ' from the file – press Play to pick a slot.');
    }
  } catch (e) { /* storage unavailable */ }
})();
