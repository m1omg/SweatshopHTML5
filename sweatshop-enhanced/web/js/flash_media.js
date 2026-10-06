// Sound playback with the Web Audio API.
'use strict';

// A sound asset from a library: compressed bytes are fetched up front, decoded on demand.
function $SoundAsset(bytes) {
  this.bytes = bytes;
  this.buffer = null;
  this.promise = null;
}

const $audio = {
  ctx: null,
  master: null,
  init() {
    if (this.ctx) return;
    const AC = window.AudioContext || window.webkitAudioContext;
    this.ctx = new AC();
    this.master = this.ctx.createGain();
    this.master.connect(this.ctx.destination);
    const resume = () => {
      if (this.ctx.state === 'suspended') this.ctx.resume();
    };
    ['pointerdown', 'keydown', 'touchstart'].forEach((ev) => window.addEventListener(ev, resume, { capture: true }));
  },
  resume() {
    this.init();
    if (this.ctx.state === 'suspended') return this.ctx.resume();
    return Promise.resolve();
  },
  loadAsset(url) {
    return fetch(url).then((r) => {
      if (!r.ok) throw new Error(r.status + ' ' + url);
      return r.arrayBuffer();
    }).then((ab) => new $SoundAsset(ab));
  },
  decode(asset) {
    this.init();
    if (asset.buffer) return Promise.resolve(asset.buffer);
    if (!asset.promise) {
      // decodeAudioData detaches the ArrayBuffer, so hand it a copy
      const copy = asset.bytes.slice(0);
      asset.promise = new Promise((resolve, reject) => this.ctx.decodeAudioData(copy, resolve, reject)).then((buf) => {
        asset.buffer = buf;
        asset.bytes = null;
        return buf;
      });
      asset.promise.catch((e) => console.warn('audio decode failed', e));
    }
    return asset.promise;
  },
  // returns {src, gain}
  play(buffer, startMs, loops, volume, onComplete) {
    this.init();
    const src = this.ctx.createBufferSource();
    src.buffer = buffer;
    const gain = this.ctx.createGain();
    gain.gain.value = volume;
    src.connect(gain);
    gain.connect(this.master);
    const offset = Math.min(Math.max(0, startMs / 1000), buffer.duration);
    if (loops > 0) {
      src.loop = true;
      src.start(0, offset);
      // Flash plays a sound (loops + 1) times; very large counts mean "forever"
      if (loops < 1000) src.stop(this.ctx.currentTime + buffer.duration * (loops + 1) - offset);
    } else {
      src.start(0, offset);
    }
    src.onended = () => { if (onComplete) onComplete(); };
    return { src, gain };
  },
  setMasterVolume(v) {
    this.init();
    this.master.gain.value = v;
  },
};

function flash_media_SoundTransform(volume = 1, pan = 0) {
  this.volume = volume;
  this.pan = pan;
}
$class(flash_media_SoundTransform, null, 'flash.media.SoundTransform');

function flash_media_SoundChannel() {
  flash_events_EventDispatcher.call(this);
  this.$node = null;
  this.$volume = 1;
  this.$startTime = 0;
  this.$stopped = false;
}
$class(flash_media_SoundChannel, flash_events_EventDispatcher, 'flash.media.SoundChannel');
flash_media_SoundChannel.prototype.stop = function () {
  this.$stopped = true;
  if (this.$node) {
    try {
      this.$node.src.onended = null;
      this.$node.src.stop();
    } catch (e) { /* already stopped */ }
    this.$node = null;
  }
};
$accessor(flash_media_SoundChannel.prototype, 'soundTransform', {
  get() { return new flash_media_SoundTransform(this.$volume); },
  set(t) {
    this.$volume = t ? t.volume : 1;
    if (this.$node) this.$node.gain.gain.value = this.$volume;
  },
});
$accessor(flash_media_SoundChannel.prototype, 'position', {
  get() { return $audio.ctx ? ($audio.ctx.currentTime - this.$startTime) * 1000 : 0; },
});
$accessor(flash_media_SoundChannel.prototype, 'leftPeak', { get() { return 0; } });
$accessor(flash_media_SoundChannel.prototype, 'rightPeak', { get() { return 0; } });

function flash_media_Sound(asset) {
  flash_events_EventDispatcher.call(this);
  this.$asset = asset || null;
}
$class(flash_media_Sound, flash_events_EventDispatcher, 'flash.media.Sound');
flash_media_Sound.prototype.play = function (startTime = 0, loops = 0, transform = null) {
  const ch = new flash_media_SoundChannel();
  ch.$volume = transform ? transform.volume : 1;
  const asset = this.$asset;
  if (!asset) return ch;
  const go = (buf) => {
    if (ch.$stopped || !buf) return;
    ch.$startTime = $audio.ctx.currentTime;
    ch.$node = $audio.play(buf, startTime, loops, ch.$volume, () => {
      if (!ch.$stopped) {
        ch.$stopped = true;
        ch.$node = null;
        ch.dispatchEvent(new flash_events_Event('soundComplete'));
      }
    });
  };
  if (asset.buffer) go(asset.buffer);
  else $audio.decode(asset).then(go, () => {});
  return ch;
};
$accessor(flash_media_Sound.prototype, 'length', {
  get() { return this.$asset && this.$asset.buffer ? this.$asset.buffer.duration * 1000 : 0; },
});

const flash_media_SoundMixer = {
  get soundTransform() { return new flash_media_SoundTransform($audio.master ? $audio.master.gain.value : 1); },
  set soundTransform(t) { $audio.setMasterVolume(t ? t.volume : 1); },
  stopAll() {},
};
