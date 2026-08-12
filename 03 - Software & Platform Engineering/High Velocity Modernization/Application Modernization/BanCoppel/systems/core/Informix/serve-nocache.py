#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Servidor HTTP local con headers no-cache — para que el navegador siempre
sirva la última versión de los HTML regenerados (evita ver versiones cacheadas).
Uso: python serve-nocache.py  → http://localhost:8080/"""
import functools, os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class NoCacheHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

if __name__ == "__main__":
    handler = functools.partial(NoCacheHandler, directory=DIRECTORY)
    print(f"Sirviendo {DIRECTORY} en http://localhost:8080/ (no-cache)")
    ThreadingHTTPServer(("", 8080), handler).serve_forever()