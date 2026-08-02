'use strict';
const http = require('http');
const fs   = require('fs');
const path = require('path');
const url  = require('url');

const ROOT_DC  = 'C:\\Users\\alejandro.gallegos\\OneDrive - Accenture\\Documents\\Digital Core';
const ROOT_SOL = 'C:\\Users\\alejandro.gallegos\\OneDrive - Accenture\\Documents\\Solutioning';
const ROOT_SME = 'C:\\Users\\alejandro.gallegos\\OneDrive - Accenture\\Documents\\SME';
const PORT     = 3000;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css':  'text/css; charset=utf-8',
  '.js':   'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png':  'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
  '.gif':  'image/gif', '.svg': 'image/svg+xml', '.ico': 'image/x-icon',
  '.woff': 'font/woff', '.woff2': 'font/woff2', '.ttf': 'font/ttf',
  '.csv':  'text/csv', '.txt': 'text/plain; charset=utf-8',
};

http.createServer((req, res) => {
  const parsed = url.parse(req.url, true);
  let pathname;
  try { pathname = decodeURIComponent(parsed.pathname); } catch { pathname = parsed.pathname; }

  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, DELETE, OPTIONS');
  if (req.method === 'OPTIONS') { res.writeHead(204); res.end(); return; }

  // DELETE /api/file?path=rel[&root=sol]
  if (req.method === 'DELETE' && pathname === '/api/file') {
    let rel;
    try { rel = decodeURIComponent(parsed.query.path || ''); } catch { res.writeHead(400); res.end('Bad path'); return; }
    const rootDir = (parsed.query.root === 'sol') ? ROOT_SOL : (parsed.query.root === 'sme') ? ROOT_SME : ROOT_DC;
    const full    = path.resolve(rootDir, rel);
    if (!full.startsWith(rootDir + path.sep) || !full.endsWith('.html')) {
      res.writeHead(403); res.end('Forbidden'); return;
    }
    fs.unlink(full, err => {
      if (err) { res.writeHead(404); res.end('No encontrado'); }
      else     { res.writeHead(200); res.end('OK'); }
    });
    return;
  }

  // Static files
  // /solutioning/* → ROOT_SOL
  // /sme/*         → ROOT_SME
  // /* → ROOT_DC   (/ → _catalog.html)
  let servRoot, filePath;
  if (pathname.startsWith('/solutioning/')) {
    servRoot = ROOT_SOL;
    filePath = path.join(ROOT_SOL, pathname.slice('/solutioning/'.length));
  } else if (pathname.startsWith('/sme/')) {
    servRoot = ROOT_SME;
    filePath = path.join(ROOT_SME, pathname.slice('/sme/'.length));
  } else {
    servRoot = ROOT_DC;
    filePath = path.join(ROOT_DC, pathname === '/' ? '_catalog.html' : pathname);
  }

  if (!filePath.startsWith(servRoot)) { res.writeHead(403); res.end('Forbidden'); return; }

  fs.stat(filePath, (err, stat) => {
    if (err || !stat.isFile()) { res.writeHead(404, {'Content-Type':'text/plain'}); res.end('404: ' + pathname); return; }
    res.writeHead(200, {
      'Content-Type':  MIME[path.extname(filePath).toLowerCase()] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
    });
    fs.createReadStream(filePath).pipe(res);
  });
}).listen(PORT, '127.0.0.1', () => {
  const ts = new Date().toISOString().slice(0,19).replace('T',' ');
  console.log(`[${ts}] DevServer http://localhost:${PORT}`);
});