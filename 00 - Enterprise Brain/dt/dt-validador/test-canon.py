# -*- coding: utf-8 -*-
"""Suite de inyeccion de defectos para validate-canon.py.

Un verificador que no puede dar negativo no verifica nada. Esta suite inyecta
un defecto de cada clase en una copia del asset y comprueba que el validador
lo detecte, y que con el asset limpio no invente ninguno.
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ASSET = Path(sys.argv[1]).resolve()
tmp = Path(tempfile.mkdtemp())
shutil.copytree(ASSET, tmp / "a", ignore=shutil.ignore_patterns("__pycache__", "*.db"))
B = tmp / "a"
V = B / "dt" / "dt-validador" / "validate-canon.py"


def corre(dim=None):
    cmd = [sys.executable, str(V)] + (["--dim", dim] if dim else []) + ["--summary"]
    return subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").returncode


pruebas = []


def caso(nombre, dim, esperado, mutar=None, archivo=None, contenido=None):
    original = None
    if mutar and archivo:
        original = archivo.read_text(encoding="utf-8")
        archivo.write_text(mutar(original), encoding="utf-8")
    elif archivo and contenido:
        archivo.write_text(contenido, encoding="utf-8")
    got = corre(dim)
    if original is not None:
        archivo.write_text(original, encoding="utf-8")
    elif archivo and contenido:
        archivo.unlink()
    pruebas.append((nombre, got, esperado))


caso("asset limpio", None, 0)
caso("cifra de dimensiones mal", "cifras", 1,
     mutar=lambda t: t.replace("9 dimensiones", "3 dimensiones", 1),
     archivo=B / "quality-gates-enterprise-brain.md")
caso("rango de DoD incompleto", "cifras", 1,
     mutar=lambda t: t.replace("DoD-EB-01 a DoD-EB-12", "DoD-EB-01 a DoD-EB-09", 1),
     archivo=B / "CLAUDE.md")
caso("cifra del CORE mal", "cifras", 1,
     mutar=lambda t: t.replace("15 tablas del CORE", "12 tablas del CORE", 1),
     archivo=B / "knowledge-base" / "brain-rules.md")
caso("SQL contra columna inexistente", "sql", 1,
     archivo=B / "knowledge-base" / "_t1.md", contenido="`SELECT nope FROM capabilities`\n")
caso("tabla retirada en codigo", "retirados", 1,
     archivo=B / "templates" / "_t2.py", contenido="q = 'SELECT x FROM souls'\n")
caso("DDL transcrito", "ddl", 1,
     archivo=B / "knowledge-base" / "_t3.md",
     contenido="```sql\nCREATE TABLE inventada (\n  id TEXT\n)\n```\n")
caso("ruta inexistente", "referencias", 1,
     archivo=B / "knowledge-base" / "_t4.md", contenido="ver `templates/no-existe.py`\n")
caso("guarda vuelta vacua", "guardas", 1,
     mutar=lambda t: t.replace("for tabla, n in sorted(self.counts.items()):",
                               "for tabla, n in sorted({}.items()):", 1),
     archivo=B / "templates" / "build-brain.py")
caso("todo restaurado", None, 0)

print("SUITE DE INYECCION DE DEFECTOS")
print("=" * 58)
ok = True
for nombre, got, esperado in pruebas:
    bien = got == esperado
    ok &= bien
    print(f"  {nombre:32s} exit {got} (esp. {esperado})  {'OK' if bien else 'FALLA'}")
print()
print("RESULTADO:", "el validador detecta los 8 defectos y no inventa ninguno"
      if ok else "HAY FALLAS")
shutil.rmtree(tmp, ignore_errors=True)
sys.exit(0 if ok else 1)
