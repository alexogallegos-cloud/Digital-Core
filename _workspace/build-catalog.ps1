# build-catalog.ps1 — genera _catalog.html con raices de navegacion + archivos standalone
# Escanea Digital Core, Solutioning y SME
param([int]$Port = 3000)

$ROOT     = "C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core"
$ROOT_SOL = "C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Solutioning"
$ROOT_SME = "C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\SME"
$EXCLUDE  = @('.claude','node_modules','infra','.git','_workspace','.terraform','src','data')
$EXCL_SOL = $EXCLUDE + @('trash')
$EXCL_SME = $EXCLUDE
$OUTPUT   = Join-Path $ROOT "_catalog.html"

# ─── helpers ────────────────────────────────────────────────────────────────

function Get-HtmlTitle($fullPath) {
  $head = Get-Content -LiteralPath $fullPath -TotalCount 30 -Encoding UTF8 -ErrorAction SilentlyContinue
  $m = [regex]::Match($head -join ' ', '<title[^>]*>(.*?)</title>', 'IgnoreCase')
  if ($m.Success) {
    $t = $m.Groups[1].Value.Trim() `
      -replace '&amp;','&' -replace '&lt;','<' -replace '&gt;','>' `
      -replace '&#39;',"'" -replace '&quot;','"'
    if ($t -and $t.Length -lt 120) { return $t }
  }
  return $null
}

function Get-HtmlFiles($root, $excludeDirs) {
  Get-ChildItem -Path $root -Filter "*.html" -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
      $rel   = $_.FullName.Substring($root.Length + 1)
      $parts = $rel -split '\\'
      $skip  = $false
      foreach ($p in $parts) {
        if ($excludeDirs -contains $p -or $p.StartsWith('.')) { $skip = $true; break }
      }
      !$skip -and $_.Name -ne "_catalog.html"
    }
}

function Select-NavRoots($allFiles, $root) {
  $navRootDirs = @{}
  $allFiles | Where-Object { $_.Name -match '^index' } | ForEach-Object {
    $navRootDirs[$_.DirectoryName] = $true
  }
  $allFiles | Where-Object {
    $file = $_
    if ($file.Name -match '^index') { return $true }
    $dir = $file.DirectoryName
    $isSub = $false
    while ($dir.Length -gt $root.Length) {
      if ($navRootDirs.ContainsKey($dir)) { $isSub = $true; break }
      $parent = Split-Path $dir -Parent
      if ($parent -eq $dir) { break }
      $dir = $parent
    }
    -not $isSub
  } | Sort-Object FullName
}

# ─── brand detection ────────────────────────────────────────────────────────

$SOL_CLIENT_BRAND = @{
  'BanCoppel'        = 'bancoppel'
  'Banamex'          = 'banamex'
  'BBVA'             = 'bbva'
  'Scotia'           = 'scotiabank'
  'KOF'              = 'kof'
  'Gentera'          = 'gentera'
  'Coppel'           = 'coppel'
  'MONEX'            = 'monex'
  'Coca Cola'        = 'coca'
  'TALG'             = 'toyota'
  'Actinver'         = 'actinver'
  'Arca Continental' = 'arca'
  'Posadas'          = 'posadas'
  'Liverpool'        = 'liverpool'
  'Mapfre'           = 'mapfre'
  'Miniso'           = 'miniso'
  'Viva Aerobus'     = 'vivaaerobus'
  'Volaris'          = 'volaris'
  'Hospital ABC'     = 'hospitalabc'
  'Innova Sport'     = 'innovasport'
  'HDI'              = 'hdi'
}

function Get-BrandDC($rel) {
  if     ($rel -match 'BanCoppel|BCOP') { return 'bancoppel'  }
  elseif ($rel -match 'Banamex|GemCog') { return 'banamex'    }
  elseif ($rel -match 'BBVA')           { return 'bbva'       }
  elseif ($rel -match 'Scotiabank')     { return 'scotiabank' }
  elseif ($rel -match 'Gentera')        { return 'gentera'    }
  elseif ($rel -match 'Coppel')         { return 'coppel'     }
  elseif ($rel -match 'Monex')          { return 'monex'      }
  elseif ($rel -match 'Coca')           { return 'coca'       }
  elseif ($rel -match 'TALG|Toyota')    { return 'toyota'     }
  elseif ($rel -match 'KOF')            { return 'kof'        }
  elseif ($rel -match 'CryoInfra')      { return 'cryoinfra'  }
  return 'accenture'
}

function Get-BrandSOL($parts, $rel) {
  if ($parts[0] -eq 'Proposals - Clients' -and $parts.Count -gt 1) {
    $b = $SOL_CLIENT_BRAND[$parts[1]]
    if ($b) { return $b }
  }
  if     ($rel -match 'Banamex')    { return 'banamex'    }
  elseif ($rel -match 'BanCoppel')  { return 'bancoppel'  }
  elseif ($rel -match 'BBVA')       { return 'bbva'       }
  elseif ($rel -match 'Scotiabank') { return 'scotiabank' }
  elseif ($rel -match 'Liverpool')  { return 'liverpool'  }
  return 'accenture'
}

function Get-BrandSME($rel) {
  if ($rel -match 'Liverpool') { return 'liverpool' }
  return 'accenture'
}

# ─── item builder ────────────────────────────────────────────────────────────

function New-CatalogItems($files, $rootPath, $urlPrefix, $rootTag) {
  $files | ForEach-Object {
    $rel   = $_.FullName.Substring($rootPath.Length + 1)
    $parts = $rel -split '\\'

    $group = if ($rootTag -eq 'sol') {
      if ($parts[0] -eq 'Proposals - Clients' -and $parts.Count -gt 1) { $parts[1] }
      elseif ($parts[0] -match 'Solutioning - Sales Process')           { 'Sales Process' }
      elseif ($parts[0] -match 'Solutioning - Solution Architect')      { 'Solution Architect' }
      elseif ($parts.Count -gt 1)                                        { $parts[0] }
      else                                                                { 'Root' }
    } else {
      if ($parts.Count -gt 1) { $parts[0] } else { 'Root' }
    }

    $raw      = Get-HtmlTitle $_.FullName
    $fallback = if ($_.Name -eq 'index.html') {
      $parts[-2] -replace '-',' ' -replace '_',' '
    } else { $_.Name -replace '\.html$','' }
    $title = if ($raw) { $raw } else { $fallback }

    $ctx = if ($parts.Count -gt 2) {
      $mid = $parts[1..($parts.Count - 2)]
      if ($mid.Count -gt 3) { '.../' + ($mid[($mid.Count-3)..($mid.Count-1)] -join '/') }
      else { $mid -join ' / ' }
    } else { '' }

    $urlPath = ($parts | ForEach-Object { [System.Uri]::EscapeDataString($_) }) -join '/'
    $url     = "http://localhost:$Port/$urlPrefix$urlPath"

    $brand = switch ($rootTag) {
      'sol'   { Get-BrandSOL $parts $rel }
      'sme'   { Get-BrandSME $rel }
      default { Get-BrandDC $rel }
    }

    [ordered]@{
      title    = $title
      file     = $_.Name
      group    = $group
      path     = $ctx
      rel      = ($rel -replace '\\','/')
      url      = $url
      brand    = $brand
      root     = $rootTag
      modified = $_.LastWriteTime.ToString("yyyy-MM-dd")
      created  = $_.CreationTime.ToString("yyyy-MM-dd")
      kb       = [int]($_.Length / 1KB)
    }
  }
}

# ─── scan ────────────────────────────────────────────────────────────────────

$allDC  = Get-HtmlFiles $ROOT     $EXCLUDE
$allSOL = Get-HtmlFiles $ROOT_SOL $EXCL_SOL
$allSME = Get-HtmlFiles $ROOT_SME $EXCL_SME

$filesDC  = Select-NavRoots $allDC  $ROOT
$filesSOL = Select-NavRoots $allSOL $ROOT_SOL
$filesSME = Select-NavRoots $allSME $ROOT_SME

$rawDC  = @(New-CatalogItems $filesDC  $ROOT     ''             'dc')
$rawSOL = @(New-CatalogItems $filesSOL $ROOT_SOL 'solutioning/' 'sol')
$rawSME = @(New-CatalogItems $filesSME $ROOT_SME 'sme/'         'sme')

$idx = 0
$items = (@($rawDC) + @($rawSOL) + @($rawSME)) | ForEach-Object {
  $_['idx'] = $idx++
  $_
}

# ─── output ──────────────────────────────────────────────────────────────────

$json  = ($items | ConvertTo-Json -Compress -Depth 3)
$ts    = Get-Date -Format "yyyy-MM-dd HH:mm"
$count = $filesDC.Count + $filesSOL.Count + $filesSME.Count
$total = $allDC.Count + $allSOL.Count + $allSME.Count

$head = @'
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Digital Core — Workspace Catalog</title>
<style>
:root{--purple:#6B21A8;--ink:#1A1A2E;--bg:#f5f5f5;--card:#fff;--line:#E0E0E0;--txt:#1A1A1A;--muted:#666666}
*{box-sizing:border-box}
body{margin:0;font-family:'Segoe UI',Roboto,Arial,sans-serif;background:var(--bg);color:var(--txt);font-size:15px;line-height:1.55}
header{background:var(--ink);color:#fff;padding:20px 36px;display:flex;align-items:center;gap:18px;border-bottom:3px solid var(--purple)}
.htitle{border-left:1px solid rgba(255,255,255,.3);padding-left:18px}
.htitle h1{margin:0;font-size:19px;font-weight:600}
.htitle p{margin:2px 0 0;font-size:11.5px;opacity:.7}
.bar{max-width:1100px;margin:0 auto;padding:20px 28px 0;display:flex;align-items:center;gap:14px;flex-wrap:wrap}
#q{flex:1;min-width:220px;padding:9px 14px;border:1px solid var(--line);border-radius:6px;font-size:14px;outline:none;transition:.15s}
#q:focus{border-color:var(--purple);box-shadow:0 0 0 3px rgba(107,33,168,.12)}
.filters{display:flex;gap:6px;flex-wrap:wrap}
.fchip{padding:5px 12px;border:1px solid var(--line);border-radius:20px;font-size:12px;cursor:pointer;background:#fff;transition:.15s;white-space:nowrap}
.fchip.active{background:var(--purple);color:#fff;border-color:var(--purple)}
.meta{font-size:12.5px;color:var(--muted);white-space:nowrap}
.meta b{color:var(--purple)}

/* Recents */
.recents-wrap{max-width:1100px;margin:18px auto 0;padding:0 28px}
.recents-row{display:grid;grid-template-columns:1fr 1fr;gap:22px}
@media(max-width:680px){.recents-row{grid-template-columns:1fr}}
.recents-label{font-size:10.5px;text-transform:uppercase;letter-spacing:.7px;color:var(--purple);font-weight:700;margin-bottom:9px;display:flex;align-items:center;gap:6px}
.recents-label svg{opacity:.7}
.mini-grid{display:flex;flex-wrap:wrap;gap:7px}
.mini-card{display:flex;align-items:center;gap:8px;padding:7px 10px;background:var(--card);border:1px solid var(--line);border-left:3px solid;border-radius:6px;cursor:pointer;transition:.15s;max-width:260px;min-width:140px}
.mini-card:hover{box-shadow:0 3px 8px rgba(0,0,0,.1);transform:translateY(-1px)}
.mini-body{min-width:0;flex:1}
.mini-title{font-size:12px;font-weight:500;color:var(--ink);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.mini-file{font-size:9.5px;color:var(--muted);font-family:Consolas,monospace;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.recents-empty{font-size:12px;color:var(--muted);font-style:italic;margin:0;padding:6px 0}

/* Logo box */
.logo-box{display:flex;align-items:center;justify-content:center;border-radius:8px;border:1px solid var(--line);background:#fff;overflow:hidden;flex-shrink:0}
.logo-box img{object-fit:contain;display:block}

/* Group nav */
.groupnav{position:sticky;top:0;z-index:50;background:var(--bg);border-bottom:1px solid var(--line);box-shadow:0 1px 4px rgba(0,0,0,.06)}
.groupnav-inner{max-width:1100px;margin:0 auto;padding:7px 28px;display:flex;flex-wrap:wrap;gap:5px;overflow-x:auto}
.gnav-chip{padding:3px 11px;border:1px solid var(--line);border-radius:14px;font-size:11.5px;cursor:pointer;background:#fff;text-decoration:none;color:var(--ink);white-space:nowrap;transition:.12s}
.gnav-chip:hover{background:var(--purple);color:#fff;border-color:var(--purple)}

/* Main catalog */
main{max-width:1100px;margin:0 auto;padding:22px 28px 60px}
h2{font-size:11px;text-transform:uppercase;letter-spacing:.7px;color:var(--purple);margin:28px 0 10px;border-bottom:1px solid var(--line);padding-bottom:5px;display:flex;align-items:center;gap:8px}
.cnt{font-size:10.5px;font-weight:400;color:var(--muted);text-transform:none;letter-spacing:0}
.grid{display:grid;gap:10px;grid-template-columns:repeat(auto-fill,minmax(320px,1fr))}
.card{background:var(--card);border:1px solid var(--line);border-left:4px solid var(--purple);border-radius:8px;cursor:pointer;display:flex;flex-direction:column;position:relative;transition:box-shadow .15s,transform .15s}
.card:hover{transform:translateY(-2px);box-shadow:0 6px 18px rgba(0,0,0,.1)}
.card-top{flex:1;display:flex;align-items:flex-start;gap:12px;padding:14px 44px 10px 14px}
.clogo{flex-shrink:0;margin-top:1px}
.cbody{flex:1;min-width:0}
.ctitle{font-size:14px;font-weight:600;color:var(--ink);line-height:1.35;margin-bottom:3px}
.cfile{font-size:10px;color:var(--muted);font-family:Consolas,monospace;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-bottom:5px}
.cpath{font-size:11.5px;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.card-footer{display:flex;gap:12px;padding:7px 14px 11px;border-top:1px solid var(--line);font-size:10.5px;color:var(--muted);flex-wrap:wrap}
.card-footer span{white-space:nowrap}
.tag{display:inline-block;font-size:9.5px;font-weight:700;padding:1px 6px;border-radius:10px;margin-right:5px;vertical-align:middle;position:relative;top:-1px;background:#e8d5ff;color:var(--purple)}
.del-btn{position:absolute;top:10px;right:10px;width:26px;height:26px;border:none;border-radius:5px;background:transparent;color:#aaa;cursor:pointer;display:flex;align-items:center;justify-content:center;opacity:0;transition:opacity .15s,background .15s,color .15s;padding:0;z-index:2}
.card:hover .del-btn{opacity:1}
.del-btn:hover{background:#ffe5e5;color:#c00}
.del-confirm{display:none;background:#fff5f5;border-top:1px solid #fcc;padding:10px 14px;font-size:12.5px;color:#b00;gap:10px;align-items:center;flex-wrap:wrap;z-index:3}
.del-confirm.show{display:flex}
.del-confirm span{flex:1;min-width:0}
.del-confirm b{word-break:break-all}
.dc-btns{display:flex;gap:8px;flex-shrink:0}
.del-yes{background:#c00;color:#fff;border:none;border-radius:4px;padding:4px 14px;cursor:pointer;font-size:12px;font-weight:600}
.del-yes:hover{background:#a00}
.del-no{background:#fff;border:1px solid #ccc;border-radius:4px;padding:4px 12px;cursor:pointer;font-size:12px}
footer{text-align:center;color:var(--muted);font-size:11.5px;padding:18px;border-top:1px solid var(--line)}
</style>
</head>
<body>
<header>
  <svg width="32" height="32" viewBox="0 0 32 32" fill="none"><rect width="32" height="32" rx="6" fill="#6B21A8"/><text x="17" y="23" text-anchor="middle" font-family="Arial" font-size="20" font-weight="900" fill="white">&gt;</text></svg>
  <div class="htitle"><h1>Workspace Catalog</h1><p>Digital Core &middot; Solutioning &middot; SME &mdash; portales y archivos independientes</p></div>
</header>
<div class="bar">
  <input type="search" id="q" placeholder="Buscar por nombre, cliente, carpeta...">
  <div class="filters" id="filters"></div>
  <span class="meta" id="meta">cargando...</span>
</div>
<div class="recents-wrap" id="recents"></div>
<div class="groupnav" id="groupnav" style="display:none"><div class="groupnav-inner" id="groupnav-inner"></div></div>
<main id="catalog"></main>
<footer>Digital Core &middot; Solutioning &middot; SME &middot; Accenture &middot; uso interno &middot; generado
'@

$tail = @'
</footer>
<script>
const FILES=
'@

$tail2 = @'
;

const BRANDS = {
  bancoppel:  { bg:'#122FB1', tx:'#F0D224', lbl:'BC',   border:'#122FB1' },
  banamex:    { bg:'#CC0A1E', tx:'#FFFFFF', lbl:'BAX',  border:'#CC0A1E' },
  bbva:       { bg:'#004481', tx:'#48BDDE', lbl:'BBVA', border:'#004481' },
  scotiabank: { bg:'#EC111A', tx:'#FFFFFF', lbl:'SC',   border:'#EC111A' },
  gentera:    { bg:'#E87722', tx:'#FFFFFF', lbl:'GT',   border:'#E87722' },
  coppel:     { bg:'#0052A5', tx:'#FFD100', lbl:'CP',   border:'#0052A5' },
  monex:      { bg:'#005A8B', tx:'#FFFFFF', lbl:'MX',   border:'#005A8B' },
  coca:       { bg:'#F40009', tx:'#FFFFFF', lbl:'CC',   border:'#F40009' },
  toyota:     { bg:'#EB0A1E', tx:'#FFFFFF', lbl:'TY',   border:'#EB0A1E' },
  kof:        { bg:'#E31837', tx:'#FFFFFF', lbl:'KOF',  border:'#E31837' },
  cryoinfra:  { bg:'#0D6EFD', tx:'#FFFFFF', lbl:'CRY',  border:'#0D6EFD' },
  actinver:   { bg:'#005B2F', tx:'#FFFFFF', lbl:'ATV',  border:'#005B2F' },
  arca:       { bg:'#1B3A6B', tx:'#FFFFFF', lbl:'ARC',  border:'#1B3A6B' },
  posadas:    { bg:'#8B6914', tx:'#FFFFFF', lbl:'POS',  border:'#8B6914' },
  liverpool:  { bg:'#6B1A1A', tx:'#FFFFFF', lbl:'LVP',  border:'#6B1A1A' },
  mapfre:     { bg:'#DA0F16', tx:'#FFFFFF', lbl:'MF',   border:'#DA0F16' },
  miniso:     { bg:'#CC0033', tx:'#FFFFFF', lbl:'MNS',  border:'#CC0033' },
  vivaaerobus:{ bg:'#FF4713', tx:'#FFFFFF', lbl:'VA',   border:'#FF4713' },
  volaris:    { bg:'#F5A800', tx:'#1A1A1A', lbl:'VOL',  border:'#F5A800' },
  hospitalabc:{ bg:'#0062B1', tx:'#FFFFFF', lbl:'ABC',  border:'#0062B1' },
  innovasport:{ bg:'#00843D', tx:'#FFFFFF', lbl:'IS',   border:'#00843D' },
  hdi:        { bg:'#0057A8', tx:'#FFD700', lbl:'HDI',  border:'#0057A8' },
  accenture:  { bg:'#A100FF', tx:'#FFFFFF', lbl:'>',    border:'#A100FF' },
};

const LOGO_IMGS = {
  accenture:  '/solutioning/Design%20-%20Studio/logos/Accenture_logo_hd.png',
  banamex:    '/solutioning/Design%20-%20Studio/logos/Banamex-logo.png',
  bancoppel:  '/solutioning/Design%20-%20Studio/logos/BanCoppel_logo.png',
  bbva:       '/solutioning/Design%20-%20Studio/logos/BBVA-logo.png',
  coppel:     '/solutioning/Design%20-%20Studio/logos/Coppel_logo.png',
  gentera:    '/solutioning/Design%20-%20Studio/logos/Gentera-logo.png',
  mapfre:     '/solutioning/Design%20-%20Studio/logos/Mapfre-logo.png',
  monex:      '/solutioning/Design%20-%20Studio/logos/Monex_logo.png',
  scotiabank: '/solutioning/Design%20-%20Studio/logos/Scotiabank_logo.png',
  toyota:     '/solutioning/Design%20-%20Studio/logos/TALG-logo.png',
};

function logoEl(brand, size) {
  const b   = BRANDS[brand] || BRANDS.accenture;
  const W   = size || 38;
  const img = LOGO_IMGS[brand];
  if (img) {
    const p = Math.round(W * 0.1);
    return '<div class="logo-box" style="width:'+W+'px;height:'+W+'px;padding:'+p+'px">'
      + '<img src="'+img+'" alt="'+brand+'" style="max-width:'+(W-p*2)+'px;max-height:'+(W-p*2)+'px">'
      + '</div>';
  }
  const R   = Math.round(W * 0.21);
  const lbl = b.lbl;
  const fs  = lbl.length >= 4 ? W*0.224 : lbl.length === 3 ? W*0.276 : lbl.length === 2 ? W*0.342 : W*0.5;
  return '<svg width="'+W+'" height="'+W+'" viewBox="0 0 '+W+' '+W+'" fill="none">'
    + '<rect width="'+W+'" height="'+W+'" rx="'+R+'" fill="'+b.bg+'"/>'
    + '<text x="'+W/2+'" y="'+W/2+'" text-anchor="middle" dominant-baseline="central"'
    + ' font-family="Arial,Helvetica,sans-serif" font-size="'+fs.toFixed(1)+'" font-weight="800" fill="'+b.tx+'">'+lbl+'</text>'
    + '</svg>';
}

function slugify(s) { return s.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,''); }

const catalog   = document.getElementById('catalog');
const recentsEl = document.getElementById('recents');
const metaEl    = document.getElementById('meta');
const qEl       = document.getElementById('q');
const filtersEl = document.getElementById('filters');

// ── filter chips ─────────────────────────────────────────────────────────────
const CHIPS = [
  { id:'all', label:'Todos' },
  { id:'dc',  label:'Digital Core' },
  { id:'sol', label:'Solutioning' },
  { id:'sme', label:'SME' },
];
let activeChip = 'all';
CHIPS.forEach(c => {
  const btn = document.createElement('button');
  btn.className = 'fchip' + (c.id === activeChip ? ' active' : '');
  btn.textContent = c.label;
  btn.onclick = () => {
    activeChip = c.id;
    filtersEl.querySelectorAll('.fchip').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    render(qEl.value);
  };
  filtersEl.appendChild(btn);
});

// ── recently-opened (localStorage) ───────────────────────────────────────────
const LS_KEY = 'catalog_recents_v1';
function getRecents() {
  try { return JSON.parse(localStorage.getItem(LS_KEY) || '[]'); } catch { return []; }
}
function saveRecent(idx) {
  const r = getRecents().filter(x => x.idx !== idx);
  r.unshift({ idx, ts: Date.now() });
  try { localStorage.setItem(LS_KEY, JSON.stringify(r.slice(0, 12))); } catch {}
}

// ── recently-created (computed once from FILES) ───────────────────────────────
const newestFiles = [...FILES]
  .sort((a, b) => b.created.localeCompare(a.created) || b.modified.localeCompare(a.modified))
  .slice(0, 8);

// ── mini card ─────────────────────────────────────────────────────────────────
function miniCard(x) {
  const b = BRANDS[x.brand] || BRANDS.accenture;
  return '<div class="mini-card" onclick="cardClick('+x.idx+',event)" style="border-left-color:'+b.border+'">'
    + logoEl(x.brand, 24)
    + '<div class="mini-body">'
    +   '<div class="mini-title">'+x.title+'</div>'
    +   '<div class="mini-file">'+x.file+'</div>'
    + '</div>'
    + '</div>';
}

const ICON_NEW  = '<svg width="13" height="13" viewBox="0 0 13 13" fill="none"><path d="M6.5 1v11M1 6.5h11" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>';
const ICON_OPEN = '<svg width="13" height="13" viewBox="0 0 13 13" fill="none"><circle cx="6.5" cy="6.5" r="5" stroke="currentColor" stroke-width="1.4"/><path d="M6.5 4v3l2 1.2" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg>';

function renderRecents() {
  const openedRaw   = getRecents();
  const openedItems = openedRaw.map(r => FILES[r.idx]).filter(Boolean).slice(0, 8);

  let html = '<div class="recents-row">';

  html += '<div><div class="recents-label">' + ICON_NEW + ' Recien creados</div>'
       +  '<div class="mini-grid">';
  newestFiles.forEach(x => { html += miniCard(x); });
  html += '</div></div>';

  html += '<div><div class="recents-label">' + ICON_OPEN + ' Recien abiertos</div>'
       +  '<div class="mini-grid">';
  if (openedItems.length) {
    openedItems.forEach(x => { html += miniCard(x); });
  } else {
    html += '<p class="recents-empty">Aun no hay historial &mdash; haz clic en una ficha para empezar.</p>';
  }
  html += '</div></div>';

  html += '</div>';
  recentsEl.innerHTML = html;
}

// ── utils ─────────────────────────────────────────────────────────────────────
function isPortal(f) { return /^index/i.test(f.file); }
function fmt(kb)     { return kb >= 1024 ? (kb/1024).toFixed(1)+' MB' : kb+' KB'; }

const TRASH = '<svg width="14" height="14" viewBox="0 0 14 14" fill="none">'
  + '<path d="M2.5 3.5h9M5 3.5V2.5a.5.5 0 01.5-.5h3a.5.5 0 01.5.5v1M5.5 3.5v7a.5.5 0 00.5.5h2a.5.5 0 00.5-.5v-7" stroke="currentColor" stroke-width="1.25" stroke-linecap="round"/>'
  + '<path d="M6 5.5v4M8 5.5v4" stroke="currentColor" stroke-width="1.1" stroke-linecap="round"/>'
  + '</svg>';

// ── card interactions ─────────────────────────────────────────────────────────
function cardClick(idx, e) {
  if (e.target.closest('.del-btn, .del-confirm')) return;
  saveRecent(idx);
  renderRecents();
  window.open(FILES[idx].url, '_blank');
}
function askDel(idx, e) {
  e.stopPropagation();
  document.getElementById('dc-'+idx).classList.add('show');
}
function cancelDel(idx, e) {
  e.stopPropagation();
  document.getElementById('dc-'+idx).classList.remove('show');
}
async function doDel(idx, e) {
  e.stopPropagation();
  const x = FILES[idx];
  try {
    const r = await fetch('/api/file?path=' + encodeURIComponent(x.rel) + '&root=' + (x.root || 'dc'), { method:'DELETE' });
    if (r.ok) {
      const card = document.querySelector('[data-idx="'+idx+'"]');
      card.style.transition = 'opacity .25s, transform .25s';
      card.style.opacity = '0';
      card.style.transform = 'scale(.96)';
      setTimeout(() => {
        card.remove();
        const b = document.querySelector('#meta b');
        b.textContent = parseInt(b.textContent) - 1;
      }, 260);
    } else {
      alert('Error al borrar: ' + await r.text());
    }
  } catch(err) {
    alert('Error de conexion: ' + err.message);
  }
}

// ── main render ───────────────────────────────────────────────────────────────
function render(filter) {
  const f = filter.toLowerCase().trim();
  const visible = FILES.filter(x => {
    if (activeChip !== 'all' && x.root !== activeChip) return false;
    return !f || x.title.toLowerCase().includes(f) || x.path.toLowerCase().includes(f)
              || x.group.toLowerCase().includes(f)  || x.file.toLowerCase().includes(f);
  });
  const groups = {};
  visible.forEach(x => { if (!groups[x.group]) groups[x.group] = []; groups[x.group].push(x); });

  metaEl.innerHTML = '<b>' + visible.length + '</b> entradas';
  const sortedGroups = Object.keys(groups).sort();

  // Group nav bar
  const gnav = document.getElementById('groupnav');
  const gnavInner = document.getElementById('groupnav-inner');
  if (sortedGroups.length) {
    gnavInner.innerHTML = sortedGroups.map(g =>
      '<a class="gnav-chip" href="#grp-'+slugify(g)+'">'+g+'</a>'
    ).join('');
    gnav.style.display = '';
  } else { gnav.style.display = 'none'; }

  let html = '';
  if (!sortedGroups.length) {
    html = '<p style="color:var(--muted);font-size:13.5px;padding:18px 0">Sin resultados.</p>';
  }
  sortedGroups.forEach(g => {
    html += '<h2 id="grp-'+slugify(g)+'">' + g + '<span class="cnt">(' + groups[g].length + ')</span></h2><div class="grid">';
    groups[g].forEach(x => {
      const b    = BRANDS[x.brand] || BRANDS.accenture;
      const ptag = isPortal(x) ? '<span class="tag">portal</span>' : '';
      html += '<div class="card" data-idx="'+x.idx+'" onclick="cardClick('+x.idx+',event)" style="border-left-color:'+b.border+'">'
        + '<div class="card-top">'
        +   '<div class="clogo">'+logoEl(x.brand, 38)+'</div>'
        +   '<div class="cbody">'
        +     '<div class="ctitle">'+ptag+x.title+'</div>'
        +     '<div class="cfile">'+x.file+'</div>'
        +     '<div class="cpath" title="'+x.path+'">'+( x.path || 'raiz' )+'</div>'
        +   '</div>'
        + '</div>'
        + '<div class="card-footer">'
        +   '<span>mod '+x.modified+'</span>'
        +   '<span>creado '+x.created+'</span>'
        +   '<span>'+fmt(x.kb)+'</span>'
        + '</div>'
        + '<button class="del-btn" onclick="askDel('+x.idx+',event)" title="Borrar del disco">'+TRASH+'</button>'
        + '<div class="del-confirm" id="dc-'+x.idx+'">'
        +   '<span>Borrar permanentemente <b>'+x.file+'</b>?</span>'
        +   '<div class="dc-btns">'
        +     '<button class="del-yes" onclick="doDel('+x.idx+',event)">Borrar</button>'
        +     '<button class="del-no"  onclick="cancelDel('+x.idx+',event)">Cancelar</button>'
        +   '</div>'
        + '</div>'
        + '</div>';
    });
    html += '</div>';
  });
  catalog.innerHTML = html;
}

renderRecents();
qEl.addEventListener('input', () => render(qEl.value));
render('');
</script>
</body>
</html>
'@

$full = $head + $ts + $tail + $json + $tail2
[System.IO.File]::WriteAllText($OUTPUT, $full, [System.Text.Encoding]::UTF8)
Write-Host "Catalogo generado: $count entradas (DC: $($filesDC.Count) + SOL: $($filesSOL.Count) + SME: $($filesSME.Count)) de $total archivos totales"