# -*- coding: utf-8 -*-
"""Suite de inyección de defectos para validate-canon.py.

Un verificador que no puede dar negativo no verifica nada. Esta suite inyecta
un defecto de cada clase en una copia del asset y comprueba que el validador lo
detecte, y que con el asset limpio no invente ninguno.

Si agregas una dimensión al validador, agrega aquí el caso que la hace fallar.
Una dimensión sin caso de prueba no está verificada: solo está escrita.

Uso:
    python test-canon.py <ruta-del-asset>

Exit: 0 si todos los casos se comportan como se espera, 1 si alguno falla.
"""
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ASSET = Path(sys.argv[1]).resolve()
tmp = Path(tempfile.mkdtemp())
shutil.copytree(ASSET, tmp / "a", ignore=shutil.ignore_patterns("__pycache__", "*.db"))
B = tmp / "a"
V = B / "dt" / "dt-brain-auditor" / "validate-canon.py"

RETROCESO = chr(8)  # 0x08; escribirlo como escape lo rompe al pasar por shells


def corre(dim=None):
    cmd = [sys.executable, str(V)] + (["--dim", dim] if dim else []) + ["--summary"]
    return subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").returncode


pruebas = []


def caso(nombre, dim, esperado, mutar=None, archivo=None, contenido=None):
    original = None
    if mutar and archivo:
        original = archivo.read_text(encoding="utf-8")
        archivo.write_text(mutar(original), encoding="utf-8")
    elif archivo and contenido is not None:
        archivo.write_text(contenido, encoding="utf-8")
    got = corre(dim)
    if original is not None:
        archivo.write_text(original, encoding="utf-8")
    elif archivo and contenido is not None:
        archivo.unlink()
    pruebas.append((nombre, got, esperado))


caso("asset limpio", None, 0)

caso("cifra de dimensiones mal", "cifras", 1,
     # Se deriva igual que la del CORE: con "9" a mano, el caso dejo de
     # inyectar nada el dia que el validador paso a 10 dimensiones, y la
     # suite fallo por la razon equivocada.
     mutar=lambda t: re.sub(r"\b\d{1,2}(?= dimensiones)", "3", t, count=1),
     archivo=B / "quality-gates-enterprise-brain.md")

caso("cifra de dimensiones escrita con letra", "cifras", 1,
     # Una cifra en letra se queda vieja igual que una en digitos. El deck del
     # asset dijo "nueve dimensiones" tres semanas despues de que fueran diez,
     # y el validador solo miraba digitos.
     mutar=lambda t: t.replace("Brain Auditor, diez dimensiones",
                               "Brain Auditor, siete dimensiones", 1),
     archivo=B / "portal" / "enterprise-brain-deck.html")

caso("CORE nombrado al reves", "cifras", 1,
     # "CORE: N tablas obligatorias" escapaba al patron viejo, que solo sabia
     # leer "N tablas del CORE".
     mutar=lambda t: re.sub(r"CORE: \d{1,2} tablas obligatorias",
                            "CORE: 7 tablas obligatorias", t, count=1),
     archivo=B / "portal" / "digital-brain-schema.html")

caso("el diagrama deja de dibujar una tabla", "cifras", 1,
     mutar=lambda t: t.replace(
         '<div class="tname">driver_links</div>',
         '<div class="tname">driver_linkz</div>', 1),
     archivo=B / "portal" / "digital-brain-schema.html")

caso("rango de DoD incompleto", "cifras", 1,
     mutar=lambda t: t.replace("DoD-EB-01 a DoD-EB-12", "DoD-EB-01 a DoD-EB-09", 1),
     archivo=B / "CLAUDE.md")

caso("cifra del CORE mal", "cifras", 1,
     # Se deriva la cifra en vez de escribirla: con "15" a mano, el caso dejó de
     # inyectar nada el día que el CORE pasó a 17 y la suite falló en silencio.
     mutar=lambda t: re.sub(r"\b\d{1,2}(?= tablas del CORE)", "7", t, count=1),
     archivo=B / "canon" / "brain-rules.md")

caso("conteo de reglas desfasado", "cifras", 1,
     mutar=lambda t: t.replace("45 reglas viven", "40 reglas viven", 1),
     archivo=B / "source" / "README.md")

caso("SQL contra columna inexistente", "sql", 1,
     archivo=B / "knowledge-base" / "_t1.md",
     contenido="`SELECT nope FROM capabilities`\n")

caso("tabla retirada en codigo", "retirados", 1,
     archivo=B / "templates" / "_t2.py",
     contenido="q = 'SELECT x FROM souls'\n")

caso("DDL transcrito", "ddl", 1,
     archivo=B / "knowledge-base" / "_t3.md",
     contenido="```sql\nCREATE TABLE inventada (\n  id TEXT\n)\n```\n")

caso("ruta inexistente", "referencias", 1,
     archivo=B / "knowledge-base" / "_t4.md",
     contenido="ver `templates/no-existe.py`\n")

caso("guarda vuelta vacua", "guardas", 1,
     mutar=lambda t: t.replace("for tabla, n in sorted(self.counts.items()):",
                               "for tabla, n in sorted({}.items()):", 1),
     archivo=B / "templates" / "build-brain.py")

caso("byte de retroceso en un patron", "escapes", 1,
     archivo=B / "templates" / "_t5.py",
     contenido="patron = '" + RETROCESO + "lit'\n")

caso("todo restaurado", None, 0)

print("SUITE DE INYECCION DE DEFECTOS")
print("=" * 60)
ok = True
for nombre, got, esperado in pruebas:
    bien = got == esperado
    ok &= bien
    print(f"  {nombre:34s} exit {got} (esp. {esperado})  {'OK' if bien else 'FALLA'}")
print()
n_def = len([p for p in pruebas if p[2] == 1])
print("RESULTADO:",
      f"el validador detecta los {n_def} defectos y no inventa ninguno" if ok
      else "HAY FALLAS")
shutil.rmtree(tmp, ignore_errors=True)
sys.exit(0 if ok else 1)
