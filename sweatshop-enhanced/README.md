# Sweatshop – HTML5 port (enhanced copy)

This is a copy of the 1:1 port (`../sweatshop`) with two improvements, both kept in
`web/js/enhancements.js` so the translated original game code is untouched:

1. **Skip button from the first play.** The original only let you skip a level's story
   dialog once you had played that level before; here "Skip" is always offered. Skipping
   only hides the dialog – the tutorial steps and events in it still happen.
2. **Sharing works with today's Facebook.** "Post to Facebook" (on the CV screen's stats and
   trophies) opens Facebook's current share dialog. Facebook no longer lets websites pre-fill
   the post's text, so the game's message (e.g. *"I reached the rank of Sweatshop Saviour…"*)
   is copied to the clipboard – just paste it into the post. On phones and tablets the
   system share sheet opens instead, so you can pick the Facebook app. "Post to Twitter" now
   links to a working address instead of the original, long dead short link.

   The shared link is the game's own address when it is hosted on a website, or the
   [Wikipedia article about the game](https://en.wikipedia.org/wiki/Sweatshop_(video_game))
   when you play from your own computer. To share a different address, set `$SHARE_URL` at
   the top of `web/js/enhancements.js`. When the game is hosted, link previews use
   `web/share.jpg` (for Facebook, change the `og:image` tag in `web/index.html` to the full
   `https://…/share.jpg` address).

**Sweatshop** (2011) was made by **Littleloud** for **Channel 4 Education**.
All credit for the game, its design, art, writing, music and code goes to its original
creators. This folder only contains a port of their Flash game (`sweatshop.swf`) so that it
can still be played in a modern browser – natively, without Flash or any Flash emulator.

## Playing

You need Python 3 (already installed on most Linux systems) and any modern browser.

```
python3 play.py
```

This starts a small local web server and opens the game at <http://127.0.0.1:8000/>.
Press Ctrl+C in the terminal to stop it. (Browsers refuse to load the game's files when
`web/index.html` is opened directly from disk, which is why a server is needed. Any static
web server pointed at the `web/` folder works too, so the folder can also be uploaded to a
website as-is.)

* Saved games are kept in the browser's local storage (one per browser/profile), just like
  the original kept them in Flash cookies.
* Keyboard: **Space** toggles belt speed, **P** pauses – as in the original.
* The analytics the original used no longer exist, so that part does nothing.
* Optional URL parameters: `?level=N` jumps straight into level N (the original developers'
  single-level mode), `?debug=1` prints the game's internal log to the browser console,
  `?fps=1` shows the frame rate and how long drawing a frame takes (top left corner).

## How the port works

Nothing from Flash runs at play time. The original SWF was taken apart and every piece was
converted into something a browser understands natively:

| Original (inside the SWF)              | Port                                                        |
|----------------------------------------|-------------------------------------------------------------|
| ActionScript 3 game code (~200 classes)| translated to JavaScript → `web/js/game.js`                 |
| Vector art, animations, buttons, fonts | JSON shape/timeline data drawn with Canvas 2D → `web/assets/*.json` |
| Bitmaps                                | PNG / JPEG                                                  |
| Music and sound effects                | MP3, played with the Web Audio API                          |
| Intro movie (VP6 Flash video)          | H.264 MP4                                                   |
| Level data, story scripts              | the original JSON/XML, unchanged                            |

`web/js/` contains a small purpose-written runtime that provides just the parts of the
Flash API that this game uses (display list, timelines, text, events, sound, filters…):

* `runtime.js` – language helpers needed by the translated ActionScript
* `flash_core.js`, `flash_display.js`, `flash_text.js`, `flash_media.js`, `xml.js` – the API
* `flash_render.js` – loading the converted assets and drawing them on a `<canvas>`
* `patches.js` – hand-written replacements for the few bits that couldn't be translated
  automatically (E4X XML, object-keyed dictionaries, embedded assets, defunct web services)
* `player.js`, `main.js` – frame loop, mouse/keyboard input and start-up

The rendering was checked screen by screen against the original running in a reference Flash
player, and all 30 levels were run through automated play-tests.

## Rebuilding from the SWF (optional)

Everything in `web/` was generated from `sweatshop.swf` and can be regenerated with

```
python3 tools/build.py
```

This needs Java 11+ and ffmpeg (with libx264). It downloads the
[JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler) into
`tools/ffdec/`, writes the decompiled ActionScript to `decompiled/scripts/`, converts the
assets (`tools/build_assets.py`, `tools/swf2json.py`) and translates the code
(`tools/as3tojs.py`). Intermediate files go to `build/`, which can be deleted afterwards.

The decompiled ActionScript in `decompiled/` is kept for reference.
