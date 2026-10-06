#!/usr/bin/env python3
"""Rebuild the HTML5 port from the original sweatshop.swf.

    python3 tools/build.py

Steps:
  1. get JPEXS FFDec (Flash decompiler; downloaded into tools/ffdec/ unless $FFDEC is set)
  2. decompile the ActionScript sources into decompiled/scripts/
  3. convert the art, sound, video and data into web/assets/        (tools/build_assets.py)
  4. translate the ActionScript game code into web/js/game.js       (tools/as3tojs.py)

Requirements: Python 3, Java 11+ and ffmpeg (with libx264) on PATH. This is only needed to
*rebuild* the port - the finished game in web/ runs on its own.
"""
import io
import os
import subprocess
import sys
import urllib.request
import zipfile

TOOLS = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(TOOLS)
SWF = os.path.join(ROOT, 'sweatshop.swf')
FFDEC_VERSION = '26.3.0'


def find_ffdec():
    if os.environ.get('FFDEC'):
        return os.environ['FFDEC']
    jar = os.path.join(TOOLS, 'ffdec', 'ffdec.jar')
    if not os.path.exists(jar):
        url = ('https://github.com/jindrapetrik/jpexs-decompiler/releases/download/version%s/ffdec_%s.zip'
               % (FFDEC_VERSION, FFDEC_VERSION))
        print('downloading JPEXS FFDec', FFDEC_VERSION, '...')
        data = urllib.request.urlopen(url).read()
        zipfile.ZipFile(io.BytesIO(data)).extractall(os.path.join(TOOLS, 'ffdec'))
    return jar


def main():
    if not os.path.exists(SWF):
        sys.exit('sweatshop.swf not found next to the tools/ folder')
    ffdec = find_ffdec()
    env = dict(os.environ, FFDEC=ffdec, WORK=os.environ.get('WORK', os.path.join(ROOT, 'build')))

    scripts = os.path.join(ROOT, 'decompiled', 'scripts')
    if not os.path.isdir(scripts):
        print('decompiling ActionScript ...')
        subprocess.run(['java', '-jar', ffdec, '-export', 'script', os.path.join(ROOT, 'decompiled'), SWF],
                       check=True, stdout=subprocess.DEVNULL)

    print('converting assets ...')
    subprocess.run([sys.executable, os.path.join(TOOLS, 'build_assets.py')], check=True, env=env)

    print('translating game code ...')
    subprocess.run([sys.executable, os.path.join(TOOLS, 'as3tojs.py'), scripts,
                    os.path.join(ROOT, 'web', 'js', 'game.js')], check=True)
    print('done - run "python3 play.py" to play')


if __name__ == '__main__':
    main()
