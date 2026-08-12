#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ola-d-enrich.py — Ola D: enriquece definiciones con evidencia del código AS-IS
Ejecuta: python generators/ola-d-enrich.py

Fuente: cuerpo de los SPs más llamados por término (fan_in).
NO usa regulación externa — la definición sale del código.
"""

import re, shutil, sqlite3, sys
from pathlib import Path
from datetime import datetime

sys.stdout.reconfigure(encoding="utf-8")

BASE     = Path(__file__).parent.parent
VOCAB_PY = BASE / "generators" / "sp_vocab.py"
BRAIN_DB = BASE / "digital-brain" / "brain.db"

# ── Definiciones enriquecidas (cat, significado, est) ─────────────────────────
# Fuente del significado: lectura directa del SP más llamado por término.
ENRICH = {
    "consulta": (
        "ACCION",
        "consulta / proyecta estado de entidad; sp_consulta_saldos_general (bdicred, fi=435) "
        "devuelve 47 campos del snapshot financiero de un crédito (cap vig/trans/vdo, int, IVA, "
        "comisiones, línea disponible, bloqueos) usando DIRTY READ",
        "conf",
    ),
    "valida": (
        "ACCION",
        "valida acceso o condición antes de proceder; sp_valida_perfil_usuario (bdinteg, fi=388) "
        "consulta si_perfil_ejecut para perfiles 602/707/109/2001 y determina qué reporte "
        "muestra el ejecutivo; patrón: NVL check → tabla referencia → código+mensaje+bandera",
        "conf",
    ),
    "actualiza": (
        "ACCION",
        "actualiza campo de estado en registro existente; sp_dicta_actualizastatusalerta "
        "(bdinteg, fi=270) escribe veredicto del analista de fraudes (status_alerta + "
        "analista_fraudes) en si_bitacora_comparaciones; verifica sqlerrd2≠0 para detectar "
        "fila no afectada",
        "conf",
    ),
    "genera": (
        "ACCION",
        "genera artefacto de salida; sp_generararchivo_rst (bdicnweb, fi=345) descarga tablas "
        "a .txt en /RESPALDOSNEW/archivosRST/ vía SYSTEM+dbaccess (patrón RST de unload); "
        "sp_generafolionomina (bdicheq, fi=253) emite folios secuenciales de nómina",
        "conf",
    ),
    "cred": (
        "ENTIDAD",
        "crédito — productos financieros de préstamo en bdicred; familia dominante: consulta al "
        "Buró de Crédito para solicitudes de línea (sp_mon_buro_conssolcredlincred2, fi=325) "
        "con paginación, segmento/etiqueta y asignación a analista via SQL dinámico (5000 chars)",
        "conf",
    ),
    "spei": (
        "PREFIJO",
        "familia SPEI — pagos interbancarios certificados Banxico; sp_cons_spei_aud (bdinteg, "
        "fi=122) audita transacciones por rango de fecha devolviendo folio+monto+referencia "
        "con paginación (skip/límite); bdispei contiene recepción de errores CoDi y devoluciones",
        "conf",
    ),
    "inserta": (
        "ACCION",
        "inserta registro nuevo en tabla; sp_inserta_bitacora_cob (bdicobranza, fi=406) escribe "
        "en cb_bitacora con 3 tipos de ejecución: 01=inicio de proceso, 02=estado intermedio, "
        "03=fin; obtiene timestamp UTC de sysmaster:sysshmvals",
        "conf",
    ),
    "depura": (
        "ACCION",
        "depura / purga registros expirados de tabla operativa; patrón observado en bdicred: "
        "FOREACH+DELETE+COMMIT por fila con contador iCuentasaDepurar, UPDATE STATISTICS al "
        "cierre; controla ventana horaria via sd_param cod_param=119 y soporta reinicio",
        "conf",
    ),
    "dicta": (
        "ENTIDAD",
        "subsistema de dictaminación antifraude en bdinteg (sp_dicta_*, fi≥270); gestiona "
        "veredictos de comparación biométrica en si_bitacora_comparaciones y alertas activas "
        "en si_bitacora_alerta_tmp; el analista_fraudes asigna status_alerta tras revisar la huella",
        "conf",
    ),
    "estatus": (
        "ENTIDAD",
        "estado de un objeto de negocio; en bdicred: estatus_cred (activo/bloqueado/vencido), "
        "en bdinteg: status_alerta (veredicto antifraude en si_bitacora_comparaciones), "
        "en bdicnweb: estatus de solicitud y proceso; valor siempre CHAR(1-2) codificado",
        "conf",
    ),
}

# ── Backup sp_vocab.py ───────────────────────────────────────────────────────
ts     = datetime.now().strftime("%Y%m%d_%H%M%S")
backup = VOCAB_PY.with_suffix(f".bak_{ts}.py")
shutil.copy2(VOCAB_PY, backup)
print(f"Backup: {backup.name}")

# ── Editar sp_vocab.py: reemplaza la entrada completa ──────────────────────
text = VOCAB_PY.read_text(encoding="utf-8")

enriched = []
skipped  = []

for token, (cat, sig, est) in ENRICH.items():
    new_entry = f'"{token}": ("{cat}", "{sig}", "{est}")'
    # Match the existing entry (any current meaning)
    pat = (
        r'"' + re.escape(token) + r'"\s*:\s*\("[^"]*",\s*"[^"]*",\s*"[^"]*"\s*\)'
    )
    new_text, n = re.subn(pat, new_entry, text)
    if n > 0:
        enriched.append(token)
        text = new_text
    else:
        skipped.append(token)

VOCAB_PY.write_text(text, encoding="utf-8")
print(f"\nsp_vocab.py: {len(enriched)} términos enriquecidos")
if skipped:
    print(f"  No encontrados ({len(skipped)}): {', '.join(skipped)}")

# ── Verificar sintaxis ────────────────────────────────────────────────────────
import ast
try:
    ast.parse(VOCAB_PY.read_text(encoding="utf-8"))
    print("  Sintaxis Python OK")
except SyntaxError as e:
    print(f"[ERROR] Sintaxis rota: {e}")
    shutil.copy2(backup, VOCAB_PY)
    print("Backup restaurado.")
    sys.exit(1)

# ── Actualizar brain.db: meaning ──────────────────────────────────────────────
conn = sqlite3.connect(BRAIN_DB)
cur  = conn.cursor()

updated_db = []
for token, (cat, sig, est) in ENRICH.items():
    row = cur.execute("SELECT term FROM terms WHERE term=?", (token,)).fetchone()
    if row:
        cur.execute("UPDATE terms SET meaning=? WHERE term=?", (sig, token))
        updated_db.append(token)

conn.commit()
conn.close()
print(f"\nbrain.db: {len(updated_db)} términos actualizados (meaning)")

# ── Resumen ────────────────────────────────────────────────────────────────────
print(f"""
─────────────────────────────────────────
Ola D completada
  sp_vocab.py enriquecidos : {len(enriched)}
  brain.db actualizados    : {len(updated_db)}
  Backup                   : {backup.name}

Evidencia de código aplicada:
  consulta  → sp_consulta_saldos_general   (bdicred, fi=435)
  valida    → sp_valida_perfil_usuario     (bdinteg, fi=388)
  actualiza → sp_dicta_actualizastatusalerta (bdinteg, fi=270)
  genera    → sp_generararchivo_rst         (bdicnweb, fi=345)
  cred      → sp_mon_buro_conssolcredlincred2 (bdicred, fi=325)
  spei      → sp_cons_spei_aud             (bdinteg, fi=122)
  inserta   → sp_inserta_bitacora_cob      (bdicobranza, fi=406)
  depura    → patrón FOREACH+DELETE bdicred
  dicta     → sp_dicta_actualizastatusalerta (bdinteg, fi=270)
  estatus   → si_bitacora_comparaciones + sd_indicador_cred_hist

Próximos pasos:
  1. cd generators && python build-vocab-inventory.py
  2. python build-vocab-report-v2.py
─────────────────────────────────────────""")
