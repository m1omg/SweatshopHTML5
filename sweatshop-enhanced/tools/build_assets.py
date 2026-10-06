#!/usr/bin/env python3
"""Build web/assets from the original sweatshop.swf.

Requires: Java + JPEXS FFDec (ffdec.jar path via FFDEC env var), Python 3, ffmpeg (with libx264).

Steps:
  1. export embedded binary data (inner asset SWFs, JSON data) from sweatshop.swf
  2. for every asset SWF: convert vector data to JSON (swf2json.py),
     export bitmaps + sounds with FFDec, collect frame scripts (all stop()).
"""
import glob
import json
import os
import re
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
import swf2json  # noqa

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
SRC = os.path.join(ROOT, 'sweatshop.swf')
OUT = os.path.join(ROOT, 'web', 'assets')
WORK = os.environ.get('WORK', os.path.join(ROOT, 'build'))
FFDEC = os.environ.get('FFDEC', os.path.join(ROOT, 'tools', 'ffdec', 'ffdec.jar'))


def ffdec(*args):
    subprocess.run(['java', '-jar', FFDEC] + list(args), check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def predecode_tiles(path):
    """Belt layouts are zlib+base64 compressed (custom alphabet); decode them here so
    the browser port doesn't need a synchronous inflate implementation."""
    import base64
    import zlib
    data = json.load(open(path, encoding='utf-8'))
    tr = str.maketrans('()_', '+/=')
    for lv in data['levels'].values():
        belt = (lv.get('map') or {}).get('belt')
        if isinstance(belt, dict) and isinstance(belt.get('tiles'), str) and not belt['tiles'].startswith('RAW:'):
            raw = zlib.decompress(base64.b64decode(belt['tiles'].translate(tr))).decode('utf-8')
            belt['tiles'] = 'RAW:' + raw
    with open(path, 'w', encoding='utf-8') as fh:
        json.dump(data, fh, ensure_ascii=False, separators=(',', ':'))


def stream_mp3(swf_path):
    """Concatenate the MP3 data of all streaming-sound blocks (SoundStreamBlock tags)."""
    import struct
    import zlib
    raw = open(swf_path, 'rb').read()
    body = zlib.decompress(raw[8:]) if raw[:3] == b'CWS' else raw[8:]
    nbits = body[0] >> 3
    pos = (5 + 4 * nbits + 7) // 8 + 4
    out = bytearray()
    fmt = {}

    def walk(pos, end):
        while pos < end:
            h = struct.unpack_from('<H', body, pos)[0]
            pos += 2
            code, ln = h >> 6, h & 0x3f
            if ln == 0x3f:
                ln = struct.unpack_from('<I', body, pos)[0]
                pos += 4
            if code == 39:
                walk(pos + 4, pos + ln)
            elif code in (18, 45):
                fmt['compression'] = body[pos + 1] >> 4
            elif code == 19 and fmt.get('compression') == 2:
                out.extend(body[pos + 4:pos + ln])  # skip SampleCount + SeekSamples
            pos += ln
            if code == 0:
                break

    walk(pos, len(body))
    return bytes(out)


def build_videos(swf_path, data, wd, od):
    """Embedded FLV video (VP6) -> MP4 (H.264/AAC) with the streamed soundtrack muxed in."""
    vids = {}
    ids = [k for k, v in data['chars'].items() if v['t'] == 'video']
    if not ids:
        return vids
    mdir = os.path.join(wd, 'movies')
    if not glob.glob(os.path.join(mdir, '**', '*.flv'), recursive=True):
        ffdec('-export', 'movie', mdir, swf_path)
    audio = stream_mp3(swf_path)
    apath = os.path.join(wd, 'stream.mp3')
    if audio:
        with open(apath, 'wb') as fh:
            fh.write(audio)
    for cid in ids:
        flv = glob.glob(os.path.join(mdir, '**', cid + '.flv'), recursive=True)[0]
        dst = 'v' + cid + '.mp4'
        cmd = ['ffmpeg', '-y', '-loglevel', 'error', '-i', flv]
        if audio:
            cmd += ['-i', apath, '-c:a', 'aac', '-b:a', '128k']
        # yuv420p needs even dimensions: pad (the runtime only draws the original w x h area)
        cmd += ['-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2',
                '-c:v', 'libx264', '-preset', 'slow', '-crf', '20', '-pix_fmt', 'yuv420p',
                '-movflags', '+faststart', os.path.join(od, dst)]
        subprocess.run(cmd, check=True)
        vids[cid] = dst
    return vids


def export_input_font(swf_path, wd):
    """The game's text is drawn from glyph outlines, but the name-entry box is an HTML <input>:
    give it the game's own font (VAG Rounded, embedded in UI.swf) as a WOFF file."""
    fdir = os.path.join(wd, 'fonts')
    if not glob.glob(os.path.join(fdir, '*.woff')):
        ffdec('-format', 'font:woff', '-export', 'font', fdir, swf_path)
    for f in glob.glob(os.path.join(fdir, '*.woff')):
        if 'VAGRounded' in os.path.basename(f):
            os.makedirs(os.path.join(OUT, 'fonts'), exist_ok=True)
            shutil.copy(f, os.path.join(OUT, 'fonts', 'VAGRounded.woff'))
            return


def main():
    os.makedirs(WORK, exist_ok=True)
    os.makedirs(OUT, exist_ok=True)
    top = os.path.join(WORK, 'top')
    if not os.path.isdir(os.path.join(top, 'binaryData')):
        ffdec('-export', 'binaryData,image,font', top, SRC)
    swfs = {}
    for f in glob.glob(os.path.join(top, 'binaryData', '*.bin')):
        base = os.path.basename(f)[:-4]
        name = re.sub(r'^\d+_', '', base)
        with open(f, 'rb') as fh:
            head = fh.read(3)
        if head in (b'CWS', b'FWS'):
            name = name.replace('ss.resources.ResourceIndex_', '')
            if name != 'Console':  # developer debug console, not used by the port
                swfs[name] = f
        else:
            # JSON / XML data
            dst = os.path.join(OUT, name + '.txt')
            shutil.copy(f, dst)
            if name.endswith('GetLocalDataProcess__d'):
                predecode_tiles(dst)
    swfs['main'] = SRC
    for name, path in sorted(swfs.items()):
        print('converting', name)
        data = swf2json.convert(path)
        wd = os.path.join(WORK, name)
        if not os.path.isdir(wd):
            ffdec('-export', 'image,sound,script', wd, path)
        od = os.path.join(OUT, name)
        os.makedirs(od, exist_ok=True)
        imgs = {}
        for f in glob.glob(os.path.join(wd, 'images', '*')):
            fn = os.path.basename(f)
            m = re.match(r'^(\d+)', fn)
            if not m:
                continue
            ext = os.path.splitext(fn)[1]
            dst = m.group(1) + ext
            shutil.copy(f, os.path.join(od, dst))
            imgs[m.group(1)] = dst
        snds = {}
        for f in glob.glob(os.path.join(wd, 'sounds', '*')):
            fn = os.path.basename(f)
            m = re.match(r'^(\d+)_', fn)
            if not m:
                continue
            ext = os.path.splitext(fn)[1]
            dst = 's' + m.group(1) + ext
            if ext == '.wav':
                dst = 's' + m.group(1) + '.mp3'
                subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', f, '-b:a', '128k',
                                os.path.join(od, dst)], check=True)
            else:
                shutil.copy(f, os.path.join(od, dst))
            snds[m.group(1)] = dst
        stops = {}
        for f in glob.glob(os.path.join(wd, 'scripts', '**', '*.as'), recursive=True):
            src = open(f, encoding='utf-8').read()
            m = re.search(r'class (\w+) extends', src)
            pk = re.search(r'package ([\w.]+)', src)
            if not m:
                continue
            cls = (pk.group(1) + '.' if pk else '') + m.group(1)
            frames = []
            for call in re.findall(r'addFrameScript\(([^;]*)\);', src):
                parts = [p.strip() for p in call.split(',')]
                for k in range(0, len(parts), 2):
                    fn = parts[k + 1].replace('this.', '')
                    body = re.search(r'function %s\(\)[^{]*\{(.*?)\n\s*\}' % fn, src, re.S)
                    if body and body.group(1).strip() == 'stop();':
                        frames.append(int(parts[k]) + 1)
                    else:
                        print('  non-trivial frame script', cls, fn)
            if frames:
                stops[cls] = frames
        data['vid'] = build_videos(path, data, wd, od)
        if name == 'UI':
            export_input_font(path, wd)
        data['img'] = imgs
        data['snd'] = snds
        data['stops'] = stops
        with open(os.path.join(OUT, name + '.json'), 'w') as fh:
            json.dump(data, fh, separators=(',', ':'))


if __name__ == '__main__':
    main()
