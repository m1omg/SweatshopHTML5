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
