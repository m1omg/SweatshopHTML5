# Sweatshop – HTML5 port

**Sweatshop** (2011) was made by **Littleloud** for **Channel 4 Education**.
All credit for the game, its design, art, writing, music and code goes to its original
creators. This folder only contains a port of their Flash game (`sweatshop.swf`) so that it
can still be played in a modern browser – natively, without Flash or any Flash emulator.

## Playing

**Online:** <https://m1omg.github.io/SweatshopHTML5/> (the enhanced copy from
`sweatshop-enhanced/`) or <https://m1omg.github.io/SweatshopHTML5/original/> (this 1:1 port).

To play from your own computer you need Python 3 (already installed on most Linux systems)
and any modern browser.

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
* Sharing to Twitter opens a tweet in a new tab; the Facebook app and the analytics the
  original used no longer exist, so those parts do nothing.
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
