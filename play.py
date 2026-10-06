#!/usr/bin/env python3
"""Serve the HTML5 port of Sweatshop locally and open it in the default browser.

Usage:  python3 play.py [port] [--no-browser]        (default port 8000)

Browsers refuse to load the game's data files from file:// URLs, so the game has to be
served over http - this script does exactly that, using only the Python standard library.
"""
import functools
import http.server
import os
import sys
import threading
import webbrowser

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'web')


class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = dict(http.server.SimpleHTTPRequestHandler.extensions_map, **{
        '.js': 'text/javascript', '.json': 'application/json', '.mp3': 'audio/mpeg', '.mp4': 'video/mp4',
        '.txt': 'text/plain; charset=utf-8',
    })

    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache')
        super().end_headers()

    def log_message(self, fmt, *args):
        pass


def main():
    ports = [a for a in sys.argv[1:] if a.isdigit()]
    port = int(ports[0]) if ports else 8000
    handler = functools.partial(Handler, directory=ROOT)
    server = http.server.ThreadingHTTPServer(('127.0.0.1', port), handler)
    url = 'http://127.0.0.1:%d/' % port
    print('Sweatshop is running at %s  (press Ctrl+C to stop)' % url)
    if '--no-browser' not in sys.argv:
        threading.Timer(0.5, lambda: webbrowser.open(url)).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    main()
