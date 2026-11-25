#!/usr/bin/env python3
"""
build-java-analysis.py — métricas de calidad Java del canal AppMovil
BanCoppel Application Modernization · SPE-AM-001

Alimenta el artefacto dt/dt-java-analysis/analisis-calidad-appmovil.md con las
cifras medidas del fuente, para que dejen de escribirse a mano.

Mide, por repositorio de source/code/:
  - versión de Java y de Spring Boot (properties, con fallback al <parent>)
  - generación tecnológica derivada de ambas
  - librerías propietarias BanCoppel
  - datastores declarados en el pom
  - archivos Java de producción y de prueba

Uso:
  python build-java-analysis.py [--source <ruta>] [--json <ruta>] [--verbose]

La identidad del componente es el nombre del repositorio, no el artifactId del
pom: 41 repos declaran un artifactId distinto del suyo y 36 lo duplican entre
repos (ver CLAUDE.md del sistema).
"""

import argparse
import json
import re
import sys
import xml.etree.ElementTree as ET
from collections import Counter, defaultdict
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).parent
SOURCE_DIR = SCRIPT_DIR.parent / "source" / "code"
JSON_OUT   = SCRIPT_DIR.parent / "portal" / "data" / "java-analysis.json"

NS = {"mvn": "http://maven.apache.org/POM/4.0.0"}
M  = "{http://maven.apache.org/POM/4.0.0}"

# Librerías propietarias BanCoppel: no tienen equivalente OSS directo, así que
# cada una es deuda técnica sistémica del canal.
PROPIETARIAS = [
    "msach-u-aop-commons",
    "msach-u-platform-cryptography",
    "msach-u-redis-actions",
    "msaim-u-log-application",
]

# El patrón tiene que ser amplio: 14 repos no declaran el starter sino el driver
# por groupId (org.mongodb) o la librería interna de queryable encryption, y
# contarlos de menos desalineaba esta medición con la del brain.
DATASTORES = {
    "mongodb":  ("mongo",),
    "informix": ("informix",),
    # msach-u-redis-actions es la abstracción de Redis del canal: depender de
    # ella es usar Redis, aunque el repo no declare el starter ni el driver.
    "redis":    ("data-redis", "jedis", "lettuce", "redis-actions"),
    "feign":    ("openfeign",),
}

# Toda dependencia BanCoppel sigue el patrón msa{dominio}-u-{función}: son las
# librerías internas del canal, el sustrato que ninguna migración hereda gratis.
RE_INTERNA = re.compile(r"\bmsa[a-z]{2}-u-[a-z0-9\-]+")


def _txt(el):
    return el.text.strip() if el is not None and el.text else None


def parse_pom(pom: Path) -> dict:
    """Extrae del pom las versiones y dependencias que clasifican el repo."""
    info = {
        "artifact_id": None,
        "java": None,
        "spring_boot": None,
        "parent": None,
        "propietarias": [],
        "datastores": [],
        "internas": [],
        "error": None,
    }
    try:
        root = ET.parse(pom).getroot()
    except Exception as e:                      # pom corrupto o truncado
        info["error"] = str(e)
        return info

    # El namespace se lee del root y no de una constante: hay poms que lo
    # declaran con https, y con el valor fijo todas las búsquedas daban None.
    uri = root.tag[1:root.tag.index("}")] if root.tag.startswith("{") else ""
    NS = {"mvn": uri} if uri else {}
    M  = f"{{{uri}}}" if uri else ""

    def find(path):
        return root.find(path, NS) if NS else root.find(path.replace("mvn:", ""))

    info["artifact_id"] = _txt(find("mvn:artifactId"))

    # Java: properties primero; si no está, se queda en None y se reporta aparte.
    props = find("mvn:properties")
    if props is not None:
        for child in props:
            tag = child.tag.replace(M, "")
            if tag in ("java.version", "maven.compiler.release",
                       "maven.compiler.source", "maven.compiler.target"):
                if child.text and child.text.strip():
                    info["java"] = child.text.strip()
                    break
        sb = props.find("mvn:spring-boot.version", NS) if NS else props.find("spring-boot.version")
        if sb is None:
            sb = props.find("mvn:spring.boot.version", NS) if NS else props.find("spring.boot.version")
        info["spring_boot"] = _txt(sb)

    # Spring Boot: el <parent> es la fuente más confiable cuando existe.
    parent = find("mvn:parent")
    if parent is not None:
        pa = _txt(parent.find("mvn:artifactId", NS) if NS else parent.find("artifactId"))
        pv = _txt(parent.find("mvn:version", NS) if NS else parent.find("version"))
        info["parent"] = pa
        if pa and "spring-boot-starter-parent" in pa and pv:
            info["spring_boot"] = pv

    raw = ET.tostring(root, encoding="unicode").lower()
    info["propietarias"] = [p for p in PROPIETARIAS if p in raw]
    info["datastores"]   = [k for k, pats in DATASTORES.items()
                            if any(p in raw for p in pats)]
    info["internas"]     = sorted(set(RE_INTERNA.findall(raw)))
    return info


def rama(version: str) -> str:
    """Normaliza 3.3.3 -> 3.3.x  (para agrupar por rama de soporte)."""
    if not version:
        return "sin dato"
    m = re.match(r"(\d+)\.(\d+)", version)
    return f"{m.group(1)}.{m.group(2)}.x" if m else version


def generacion(java: str, sb: str) -> str:
    """
    Clasifica el repo por generación tecnológica. Es el insumo de la decisión 7R:
    lo que define la urgencia es el EOL, no la antigüedad nominal.
    """
    jm = re.match(r"(?:1\.)?(\d+)", java or "")
    jv = int(jm.group(1)) if jm else None
    sm = re.match(r"(\d+)", sb or "")
    sv = int(sm.group(1)) if sm else None

    if jv is None and sv is None:
        return "sin dato"
    if (jv is not None and jv <= 8) or (sv is not None and sv < 3):
        return "legacy"
    if jv is None:
        return "sin dato"
    if jv >= 25:
        return "modern-25"
    if jv >= 21:
        return "modern-21"
    if jv >= 17:
        return "modern-17"
    return "legacy"


def contar_java(repo: Path) -> tuple:
    """
    Archivos .java de producción y de prueba, sin mirar dentro de .git.

    La prueba se reconoce por estar bajo src/test/, no por llevar "test" en
    algún tramo de la ruta: hay paquetes de producción que se llaman así.
    """
    main = test = 0
    for f in repo.rglob("*.java"):
        rel = f.relative_to(repo)
        if ".git" in rel.parts:
            continue
        if rel.parts[:2] == ("src", "test"):
            test += 1
        else:
            main += 1
    return main, test


def analizar(source_dir: Path, verbose: bool) -> dict:
    repos = []
    for pom in sorted(source_dir.glob("*/pom.xml")):
        d = pom.parent
        info = parse_pom(pom)
        main, test = contar_java(d)
        r = {
            "repo": d.name,
            "artifact_id": info["artifact_id"],
            "java": info["java"],
            "spring_boot": info["spring_boot"],
            "rama_sb": rama(info["spring_boot"]),
            "generacion": generacion(info["java"], info["spring_boot"]),
            "propietarias": info["propietarias"],
            "internas": info["internas"],
            "datastores": info["datastores"],
            "java_main": main,
            "java_test": test,
            "pom_error": info["error"],
        }
        repos.append(r)
        if verbose:
            print(f"  {r['repo']:62} java={r['java'] or '?':>4} "
                  f"sb={r['spring_boot'] or '?':>8} {r['generacion']}")

    # Cascarones: carpeta clonada sin pom, es decir repo sin código Maven.
    cascarones = sorted(
        d.name for d in source_dir.iterdir()
        if d.is_dir() and not (d / "pom.xml").exists()
    )

    return {"repos": repos, "cascarones": cascarones}


def resumen(data: dict):
    repos = data["repos"]
    n = len(repos)
    gen = Counter(r["generacion"] for r in repos)
    ramas = Counter(r["rama_sb"] for r in repos)
    ds = Counter()
    for r in repos:
        for d in r["datastores"]:
            ds[d] += 1
    prop = Counter()
    for r in repos:
        for p in r["propietarias"]:
            prop[p] += 1

    main = sum(r["java_main"] for r in repos)
    test = sum(r["java_test"] for r in repos)

    print()
    print("=" * 62)
    print(f"  AppMovil — análisis Java sobre {n} repos con pom.xml")
    print("=" * 62)
    print(f"  Archivos Java de producción : {main:,}")
    print(f"  Archivos Java de prueba     : {test:,}")
    print(f"  Ratio prueba/producción     : {test / main * 100:.1f}%" if main else "")
    print(f"  Cascarones sin pom          : {len(data['cascarones'])} "
          f"({', '.join(data['cascarones']) or 'ninguno'})")
    print()
    print("  Generación tecnológica:")
    for g in ("legacy", "modern-17", "modern-21", "modern-25", "sin dato"):
        if gen.get(g):
            print(f"    {g:12} {gen[g]:>4}  ({gen[g]/n*100:.1f}%)")
    print()
    print("  Rama de Spring Boot:")
    for r_, c in sorted(ramas.items()):
        print(f"    {r_:12} {c:>4}")
    print()
    print("  Datastores declarados en el pom:")
    for k, c in ds.most_common():
        print(f"    {k:12} {c:>4}  ({c/n*100:.1f}%)")
    print()
    print("  Librerías propietarias BanCoppel:")
    for k, c in prop.most_common():
        print(f"    {k:34} {c:>4}  ({c/n*100:.1f}%)")

    internas = Counter()
    for r in repos:
        for i in r["internas"]:
            internas[i] += 1
    print()
    print(f"  Librerías internas BanCoppel detectadas: {len(internas)} distintas")
    for k, c in internas.most_common():
        marca = "" if k in PROPIETARIAS else "   <- fuera del catálogo del DT"
        print(f"    {k:40} {c:>4}{marca}")

    sin_test = [r["repo"] for r in repos if r["java_test"] == 0]
    print()
    print(f"  Repos sin un solo archivo de prueba: {len(sin_test)}")
    errores = [r["repo"] for r in repos if r["pom_error"]]
    if errores:
        print(f"  Poms ilegibles: {len(errores)} -> {errores}")
    print("=" * 62)


def main():
    ap = argparse.ArgumentParser(description="Métricas de calidad Java — AppMovil")
    ap.add_argument("--source", type=Path, default=SOURCE_DIR)
    ap.add_argument("--json",   type=Path, default=JSON_OUT)
    ap.add_argument("--verbose", "-v", action="store_true")
    args = ap.parse_args()

    if not args.source.exists():
        print(f"ERROR: fuente no encontrado: {args.source}")
        return 1

    data = analizar(args.source, args.verbose)
    resumen(data)

    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(data, ensure_ascii=False, indent=2),
                         encoding="utf-8")
    print(f"\nJSON: {args.json} ({len(data['repos'])} repos)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
