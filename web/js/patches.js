// Hand-written replacements for the few parts of the original game code that the
// automatic ActionScript -> JavaScript translation can't express (E4X XML literals and
// filters, Dictionary objects keyed by objects, embedded binary assets, and the long
// gone Facebook / Twitter / analytics services).
'use strict';


// ------------------------------------------------------------------ embedded data / assets
// Text payloads embedded in the original SWF; filled in by main.js before the game starts.
const $embedded = {};

function GlobalUI_UI_JSON() {
  mx_core_ByteArrayAsset.call(this);
  this.$data = $embedded['ss.app.GlobalUI_UI_JSON'];
}
$class(GlobalUI_UI_JSON, mx_core_ByteArrayAsset, 'ss.app.GlobalUI_UI_JSON');

function GetLocalDataProcess__d() {
  mx_core_ByteArrayAsset.call(this);
  this.$data = $embedded['ss.app.process.GetLocalDataProcess__d'];
}
$class(GetLocalDataProcess__d, mx_core_ByteArrayAsset, 'ss.app.process.GetLocalDataProcess__d');

function HUDRenderer_HUDXML() {
  mx_core_ByteArrayAsset.call(this);
  this.$data = $embedded['ss.game.components.ui.HUDRenderer_HUDXML'];
}
$class(HUDRenderer_HUDXML, mx_core_ByteArrayAsset, 'ss.game.components.ui.HUDRenderer_HUDXML');

function SplashScreen_Splash() {
  mx_core_BitmapAsset.call(this, $libraries.main.bitmapData(55));
}
$class(SplashScreen_Splash, mx_core_BitmapAsset, 'ss.app.screens.SplashScreen_Splash');

// ResourceIndex: each entry names one of the converted asset libraries in web/assets
const ss_resources_ResourceIndex = {
  HatMakerM: 'HatMakerM', HatMakerF: 'HatMakerF', BagMakerM: 'BagMakerM', BagMakerF: 'BagMakerF',
  ShoeMakerM: 'ShoeMakerM', ShoeMakerF: 'ShoeMakerF', ShirtMakerM: 'ShirtMakerM', ShirtMakerF: 'ShirtMakerF',
  ChildM: 'ChildM', ChildF: 'ChildF', Packer: 'Packer', FireOfficer: 'FireOfficer', Engineer: 'Engineer',
  Superstar: 'Superstar', World1: 'World1', World2: 'World2', World3: 'World3', Items: 'Items',
  Features: 'Features', Belt: 'Belt', Console: 'Console', UI: 'UI', HUD: 'HUD', Clients: 'Clients',
  Credits: 'Credits', Outro: 'Outro', Help: 'Help', Movie: 'Movie', Music: 'Music', SFX: 'SFX',
};
// Libraries the game needs; loaded by main.js before the game starts.
const $LIBRARY_NAMES = Object.values(ss_resources_ResourceIndex).filter((n) => n !== 'Console').concat(['main']);

// ------------------------------------------------------------------ ResourceBank
(function (P) {
  P.addResource = function (name, libName) {
    this._resources[name] = libName;
  };
  P.startLoading = function () {
    // All libraries are preloaded by main.js; report completion asynchronously like the original.
    setTimeout(() => {
      this._hasLoaded = true;
      this.dispatchEvent(new org_fatlib_events_LoadProgressEvent(org_fatlib_events_LoadProgressEvent.LOADED));
    }, 0);
  };
  P.$lib = function (name) {
    const libName = this._resources[name];
    if (!libName) throw new Error('no such resource as ' + name);
    const lib = $libraries[libName];
    if (!lib) throw new Error('resource ' + name + ' not loaded');
    return lib;
  };
  P.instantiateBitmapData = function (name, cls) {
    return this.$lib(name).instantiate(cls);
  };
  P.instantiateSound = function (name, cls) {
    const buf = this.$lib(name).soundBuffer(cls + '.wav');
    if (!buf) {
      console.warn('[ResourceBank] missing sound', name, cls);
      return new flash_media_Sound(null);
    }
    return new flash_media_Sound(buf);
  };
  P.instantiateMovieClip = function (name, cls, cacheAsBitmap = true) {
    const mc = this.$lib(name).instantiate(cls);
    mc.cacheAsBitmap = cacheAsBitmap;
    return mc;
  };
})(org_fatlib_assets_ResourceBank.prototype);

// ------------------------------------------------------------------ Dictionary based helpers
// The originals index a flash.utils.Dictionary by Timer objects; use Map semantics instead.
(function (P) {
  P.create = function (ms, fn, args = null) {
    const cb = new org_fatlib_process_Callback(fn, args);
    const t = new flash_utils_Timer(ms, 1);
    t.addEventListener(flash_events_TimerEvent.TIMER_COMPLETE, $b(this, 'onTimerFinished'));
    this._index.set(t, cb);
    t.start();
  };
  P.cancelAll = function () {
    for (const t of this._index.keys()) this.cancel(t);
  };
  P.destroy = function () {
    for (const t of this._index.keys()) {
      t.stop();
      t.removeEventListener(flash_events_TimerEvent.TIMER_COMPLETE, $b(this, 'onTimerFinished'));
      this._index.delete(t);
    }
  };
  P.cancel = function (t) {
    if (!t || !this._index.get(t)) return;
    t.stop();
    t.removeEventListener(flash_events_TimerEvent.TIMER_COMPLETE, $b(this, 'onTimerFinished'));
    this._index.delete(t);
  };
  P.onTimerFinished = function (e) {
    const t = e.currentTarget;
    const cb = this._index.get(t);
    t.removeEventListener(flash_events_TimerEvent.TIMER_COMPLETE, $b(this, 'onTimerFinished'));
    this._index.delete(t);
    if (cb) cb.execute();
  };
})(org_fatlib_utils_Delay.prototype);

(function (P) {
  P.create = function (ms, fn, args = null) {
    const cb = new org_fatlib_process_Callback(fn, args);
    const t = new PausableTimer(ms, 1);
    t.addEventListener(flash_events_TimerEvent.TIMER_COMPLETE, $b(this, 'onTimerFinished'));
    this._index.set(t, cb);
    t.start();
  };
  P.cancelAll = function () {
    for (const t of this._index.keys()) this.cancel(t);
  };
  P.pause = function () {
    for (const t of this._index.keys()) t.pause();
  };
  P.unpause = function () {
    for (const t of this._index.keys()) t.unpause();
  };
  P.destroy = function () {
    for (const t of this._index.keys()) {
      t.destroy();
      t.removeEventListener(flash_events_TimerEvent.TIMER_COMPLETE, $b(this, 'onTimerFinished'));
      this._index.delete(t);
    }
  };
  P.cancel = function (t) {
    if (!t || !this._index.get(t)) return;
    t.stop();
    t.removeEventListener(flash_events_TimerEvent.TIMER_COMPLETE, $b(this, 'onTimerFinished'));
    this._index.delete(t);
  };
  P.onTimerFinished = function (e) {
    const t = e.currentTarget;
    const cb = this._index.get(t);
    t.removeEventListener(flash_events_TimerEvent.TIMER_COMPLETE, $b(this, 'onTimerFinished'));
    this._index.delete(t);
    if (cb) cb.execute();
  };
})(ss_utils_PausableDelay.prototype);

ss_utils_MouseHandlers.add = function (el, id) {
  if (!ss_utils_MouseHandlers._index) ss_utils_MouseHandlers._index = new Map();
  const index = ss_utils_MouseHandlers._index;
  if (index.get(el)) throw new Error(el.name + ' aleady has mouse handlers!');
  el.mouseEnabled = true;
  el.mouseChildren = false;
  el.useHandCursor = true;
  el.buttonMode = true;
  el.addEventListener(flash_events_MouseEvent.MOUSE_OVER, ss_utils_MouseHandlers.onOver);
  el.addEventListener(flash_events_MouseEvent.MOUSE_OUT, ss_utils_MouseHandlers.onOut);
  el.addEventListener(flash_events_MouseEvent.CLICK, ss_utils_MouseHandlers.onClick);
  index.set(el, id);
};
ss_utils_MouseHandlers.remove = function (el) {
  const index = ss_utils_MouseHandlers._index;
  if (!index || !index.get(el)) throw new Error(el.name + ' doesnt have mouse handlers added!');
  el.removeEventListener(flash_events_MouseEvent.MOUSE_OVER, ss_utils_MouseHandlers.onOver);
  el.removeEventListener(flash_events_MouseEvent.MOUSE_OUT, ss_utils_MouseHandlers.onOut);
  el.removeEventListener(flash_events_MouseEvent.CLICK, ss_utils_MouseHandlers.onClick);
  index.delete(el);
};
ss_utils_MouseHandlers.onOver = function (e) {
  ss_game_Game.messenger.broadcast(ss_game_Messages.DEPLOYABLE_MOUSE_OVER, { id: ss_utils_MouseHandlers._index.get(e.target) });
};
ss_utils_MouseHandlers.onOut = function (e) {
  ss_game_Game.messenger.broadcast(ss_game_Messages.DEPLOYABLE_MOUSE_OUT, { id: ss_utils_MouseHandlers._index.get(e.target) });
};
ss_utils_MouseHandlers.onClick = function (e) {
  ss_game_Game.messenger.broadcast(ss_game_Messages.DEPLOYABLE_CLICKED, { id: ss_utils_MouseHandlers._index.get(e.target) });
};
ss_utils_MouseHandlers.flush = function () {
  const index = ss_utils_MouseHandlers._index;
  if (!index) return;
  for (const k of Array.from(index.keys())) ss_utils_MouseHandlers.remove(k);
};

// ------------------------------------------------------------------ E4X based code
ss_story_StoryEngine.prototype.trigger = function (type, match = null) {
  if (!match) match = {};
  const chunk = this._xml.elements('chunk').toArray().find((c) => c.attr('trigger') == type);
  if (!chunk) return false;
  const attrs = chunk.attributes();
  for (let i = 0; i < attrs.length(); i++) {
    const name = String(attrs[i].name());
    const value = attrs[i].toString();
    if (name != 'trigger') {
      if (!match[name]) {
        org_fatlib_Log.log('[StoryEngine] failed to match <' + name + '="' + value + '"> (no property "' + name + '" found in match object, or value is null)');
        return false;
      }
      if (match[name] != value) {
        org_fatlib_Log.log('[StoryEngine] failed to match <' + name + '="' + value + '"> ( got "' + match[name] + '")');
        return false;
      }
    }
  }
  this._lines = [];
  for (const line of chunk.children().toArray()) {
    if (line.nodeKind() != 'text') this._lines.push(line);
  }
  this.currentChunkType = this.hasNextLine ? type : null;
  return this.hasNextLine;
};

$accessor(ss_data_Level.prototype, 'summary', {
  get() {
    const s = this.storyXML.elements('summary');
    const first = s.length() ? s[0].children()[0] : null;
    let r = first == null ? null : String(first);
    if (!r) r = '[SUMMARY MISSING]';
    return r;
  },
});

ss_game_components_ui_HUDRenderer.prototype.compactHUDXML = function () {
  const units = [
    ['child', 'child_1', 'worker', 'entity.child'],
    ['hat_maker', 'hat_maker_1', 'worker', 'entity.hat_maker'],
    ['shirt_maker', 'shirt_maker_1', 'worker', 'entity.shirt_maker'],
    ['bag_maker', 'bag_maker_1', 'worker', 'entity.bag_maker'],
    ['shoe_maker', 'shoe_maker_1', 'worker', 'entity.shoe_maker'],
    ['packer', 'packer_1', 'worker', 'entity.packer'],
    ['engineer', 'engineer_1', 'officer', 'entity.engineer'],
    ['fire_officer', 'fire_officer_1', 'officer', 'entity.fire_officer'],
    ['superstar', 'superstar_1', 'worker', 'entity.superstar'],
  ];
  const features = [
    ['water', 'cyan'], ['fan', 'yellow'], ['radio', 'orange'],
    ['cola', 'cyan'], ['toilet', 'yellow'], ['sign', 'orange'],
    ['juice', 'cyan'], ['heater', 'yellow'], ['tannoy', 'orange'],
  ];
  const available = [];
  const unavailable = [];
  for (const u of units) (ss_game_Game.level.getAvailibility(u[0]) ? available : unavailable).push(u);
  const icon = (u) => '<icon type="' + u[0] + '" key="' + u[1] + '" category="' + u[2] + '" resname="' + u[3] + '"/>';
  let main = '';
  let special = '';
  available.concat(unavailable).forEach((u, i) => {
    if (i <= 4) main += icon(u); else special += icon(u);
  });
  const feat = features.map((f) => '<icon type="' + f[0] + '" key="' + f[0] + '" category="feature" resname="entity.' + f[0] +
    '" effect="entity.' + f[0] + '.effect" color="' + f[1] + '"/>').join('');
  return new XML('<menu>' + main + '<menu type="_special" resname="hud.special">' + special + '</menu>' +
    '<menu type="_features" resname="hud.features">' + feat + '</menu></menu>');
};

org_fatlib_utils_ClassUtils.getSuperClassName = function (cls) {
  const p = cls && cls.$parent;
  return p && p.$fq ? p.$fq.split('.').pop() : 'Object';
};

// ------------------------------------------------------------------ misc library code
// Belt layouts in the level data were zlib-compressed by the original; tools/build_assets.py
// stores them decoded with a "RAW:" prefix.
ss_utils_Compression.compress = function (s) {
  return 'RAW:' + s;
};
ss_utils_Compression.uncompress = function (s) {
  if (typeof s === 'string' && s.indexOf('RAW:') === 0) return s.slice(4);
  throw new Error('Compressed data must be pre-decoded by tools/build_assets.py');
};

org_fatlib_Log.send = function (level, item) {
  if (!org_fatlib_Log.ALLOW_LOGGING && !$flags.debug) return;
  org_fatlib_Log.dispatcher.dispatchEvent(new org_fatlib_events_CustomEvent(org_fatlib_Log.MESSAGE, { level, content: item }));
  if ($flags.debug) (console[level] || console.log).call(console, item);
};

// ------------------------------------------------------------------ remote services (defunct)
function ss_utils_Console() {}
$class(ss_utils_Console, null, 'ss.utils.Console');

function ss_remote_Tracking() {
  this.omniture = null;
  this.analytics = null;
}
$class(ss_remote_Tracking, null, 'ss.remote.Tracking');
['init', 'gameStart', 'gameWon', 'levelStart', 'levelLost', 'levelWon', 'levelRetried', 'levelRestarted', 'levelQuit',
  'gameContinue', 'screenChanged', 'trophyShared', 'karmaShared', 'trophyWon', 'soundOff', 'soundOn'].forEach((m) => {
  ss_remote_Tracking.prototype[m] = function () {};
});

// Sharing: Twitter is opened in a new tab (like the original); the old Facebook app no
// longer exists, so that option just completes.
function ss_remote_Social() {
  flash_events_EventDispatcher.call(this);
  this._currentShareable = null;
}
$class(ss_remote_Social, flash_events_EventDispatcher, 'ss.remote.Social');
ss_remote_Social.TWITTER = 'TWITTER';
ss_remote_Social.FACEBOOK = 'FACEBOOK';
ss_remote_Social.prototype.init = function () {};
ss_remote_Social.prototype.share = function (shareable, target) {
  this._currentShareable = shareable;
  if (target == ss_remote_Social.TWITTER && shareable && shareable.twitterCopy) {
    const text = encodeURIComponent(shareable.twitterCopy);
    flash_net_navigateToURL(new flash_net_URLRequest('https://twitter.com/intent/tweet?text=' + text), '_blank');
  }
  setTimeout(() => this.dispatchEvent(new org_fatlib_events_CustomEvent(flash_events_Event.COMPLETE, {})), 0);
};
