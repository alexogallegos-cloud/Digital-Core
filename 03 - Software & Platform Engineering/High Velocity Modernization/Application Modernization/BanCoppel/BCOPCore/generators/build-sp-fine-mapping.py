#!/usr/bin/env python3
"""
build-sp-fine-mapping.py — BCOPCore SP Fine-Grained Capability Mapping v1.0

Asigna a cada SP la capacidad ETB L3 más específica dentro de su dominio,
usando keyword scoring sobre (sp.name + sp.biz).

Output:
  brain.db / sps.primary_l3            — L3 ID del SP (o NULL si transversal/ambiguo)
  brain.db / sps.primary_l3_confidence — score normalizado (0.0-1.0)
  brain.db / etb_l3.sp_fine_n          — SPs con primary_l3 = este L3
  portal/data/capability-sp-mapping.json — actualizado con conteos finos
"""
import sqlite3, json, re, sys
from collections import defaultdict

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BCOP = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore")
DB       = f"{BCOP}/digital-brain/brain.db"
OUT_JSON = f"{BCOP}/portal/data/capability-sp-mapping.json"

# ─── Vocabulario de keywords por capacidad ETB L3 ────────────────────────────
# Substrings que deben aparecer en el nombre o biz del SP.
# Peso nombre = 2.0, peso biz = 1.0
# Se usa substring matching (cubre morfología española).
KEYWORDS: dict[str, list[str]] = {
    # ── Canal Digital (D01) ──────────────────────────────────────
    '1.1.1': ['internet', 'banca_internet', 'bpi', 'web', 'portal'],
    '1.1.2': ['movil', 'mobile', 'app', 'celular', 'push'],
    '1.1.5': ['ivr', 'call_center', 'telefon', 'atencion_tel', 'voz'],
    '1.4.1': ['sesion', 'canal', 'login', 'token_canal'],
    # 7.1.2 / 7.1.4 compartidos — ver abajo

    # ── Integración (D02) ────────────────────────────────────────
    '5.3.5': ['cumplimiento', 'politica', 'normativ', 'regulat'],
    '7.1.1': ['alta_clien', 'registro_clien', 'nuevo_clien', 'onboard', 'crea_clien',
              'inserta_clien', 'graba_clien'],
    '7.1.3': ['preferencia', 'dato_contact', 'actualiz_dato', 'configurac'],
    # 7.1.4 shared

    # ── Créditos (D03) ───────────────────────────────────────────
    '3.1.4': ['elegib', 'oferta_cred', 'precalif', 'promocion', 'preaprobad', 'aplica_prod',
              'producto_elegib', 'califica_prod'],
    '3.3.1': ['solicitud', 'aprobac', 'autorizac_cred', 'comite', 'estructur',
              'alta_cred', 'nuevo_cred', 'crea_cred', 'graba_cred', 'inserta_cred'],
    '3.3.2': ['disposicion', 'dispersa', 'ministr', 'origina', 'apertura_cred',
              'desembolso', 'ministrac'],
    '3.3.3': ['cancel', 'cierre_cred', 'liquida', 'termina_cred', 'finiquito',
              'saldo_cero', 'cierra_cred'],
    '3.3.4': ['pago', 'saldo', 'frecpago', 'renov', 'reestructur', 'prorroga',
              'estado_cta', 'consulta_pago', 'abono', 'servicios_cred', 'consulta_saldo'],
    '3.3.6': ['cartera', 'mora', 'vencid', 'cobr', 'recuperac',
              'castigo', 'reserva', 'portafolio', 'cobranza'],
    '5.9.1': ['parametro_riesgo', 'politica_cred', 'regla_cred', 'score_param'],
    '5.9.2': ['buro', 'calificac', 'score', 'evaluac_riesgo', 'nivel_riesgo',
              'monburo', 'mon_buro', 'consulta_buro', 'riesgo_cred'],

    # ── Cheques / Cuentas (D04) ──────────────────────────────────
    '3.15.2': ['interes', 'comision', 'calcula_cargo', 'tarifa_cta', 'tasa_cta'],
    '3.16.1': ['limite', 'saldo_max', 'tope', 'disposicion_max', 'linea_cred_cta'],
    '3.2.1':  ['apertura_cta', 'solicitud_cta', 'inicio_cta', 'nueva_cta'],
    '3.2.2':  ['formaliz', 'firma_contrato', 'contrato_cta', 'apertura_formal'],
    '3.2.3':  ['alta_cta', 'crea_cta', 'producto_ahorro', 'graba_cta'],
    '3.2.4':  ['retiro', 'deposito', 'cargo', 'abono', 'transacc', 'nomi', 'nomina',
               'aplica', 'aplica_pago', 'app_aplica', 'bts_aplica', 'msw_aplica'],
    '3.4.3':  ['pago', 'transferencia', 'proceso_pago', 'cargo_pago'],
    '3.5.1':  ['tarjeta', 'emision', 'entrega_tarj', 'plastico', 'emite_tarj'],
    '3.5.2':  ['autorizac_tarj', 'autoriza_trans', 'verif_tarj', 'autorizatarj'],

    # ── Saldos y Cuentas (D05) ───────────────────────────────────
    '3.17.2': ['liquidez', 'tesoreria', 'fondeo', 'disponible', 'remesa', 'cambio'],
    '3.17.8': ['saldo', 'movimiento', 'estado', 'reporte', 'consulta', 'consultar'],
    # 3.2.4: 'aplica', 'pago', 'cargo', 'abono', 'retiro' — añadidos a la entrada de D04

    # ── Solicitudes (D06) ────────────────────────────────────────
    # 3.1.4, 3.2.1, 3.2.2, 3.3.1 shared from D03/D04
    '7.1.6': ['necesidad_clien', 'perfil_clien', 'evaluac_clien', 'datos_financ'],

    # ── Aclaraciones (D07) ───────────────────────────────────────
    '3.18.1': ['aclarac', 'disputa', 'reclamac', 'queja', 'controversia',
               'inserta_aclar', 'graba_aclar', 'consulta_aclar'],
    '3.5.7':  ['contracargo', 'devolucion_cargo', 'reverso_cargo', 'chargeback'],
    '4.5.1':  ['condusef', 'denuncia', 'cumplimiento_reg', 'regulat_aclar'],

    # ── SPEI (D08) ───────────────────────────────────────────────
    '3.4.1':  ['preproceso', 'pre_proceso', 'valida_orden', 'validatransf',
               'valida_spei', 'pre_valid'],
    '3.4.2':  ['recepcion', 'recibe', 'captura_orden', 'rec_orden', 'recerror',
               'recdev', 'recext', 'recorden'],
    # 3.4.3 shared (aplica, proceso, core payment)
    '3.4.4':  ['compensa', 'liquida_spei', 'siac', 'clearing', 'liquidac_spei'],
    '3.4.5':  ['banxico', 'interbancario', 'red_spei', 'spei_red'],
    '3.4.6':  ['notific_pago', 'confirma_pago', 'post_spei', 'estado_spei'],
    '3.4.7':  ['reverso_spei', 'devolucion_spei', 'soporte_spei', 'consultar_pp',
               'consulta_spei', 'consultar_spei'],
    '3.4.8':  ['lote_spei', 'batch_spei', 'monitoreo_spei', 'cola_spei',
               'oper_spei', 'proceso_batch'],
    '7.4.1':  ['codi', 'cobro_digital', 'fintech', 'api_pago'],

    # ── Mensajería (D09) ─────────────────────────────────────────
    '2.7.1':  ['crea_mensaje', 'genera_mensaje', 'nuevo_mensaje'],
    '2.7.3':  ['plantilla', 'formato_msg', 'diseno_msg'],
    '7.3.3':  ['notificac', 'alerta', 'establece_cont'],
    '7.3.4':  ['info_interact', 'seguimiento', 'historial_msg'],

    # ── Sucursales (D10) ─────────────────────────────────────────
    '1.2.1':  ['sucursal', 'caja_suc', 'ventanilla', 'cajero_suc'],
    '1.2.2':  ['atm', 'pos', 'cajero_auto', 'kiosko', 'terminal'],
    '3.17.10':['efectivo', 'arqueo', 'cierre_caja', 'deposito_efect'],
    '3.17.9': ['buzon', 'deposito_noche', 'caja_noche'],

    # ── Cobranza (D11) ───────────────────────────────────────────
    # 3.3.4 Credit Servicing reusado (saldo, pago, renov)
    '5.9.4':  ['control', 'limite', 'marca', 'mitigac', 'parametro_cobr', 'marca_cta',
               'cilocconsulta', 'ciloc'],
    '5.9.5':  ['alerta', 'situacion', 'mora', 'incumpl', 'cartera_venc', 'evento',
               'cilocloca', 'cilocgenera'],

    # ── Contabilidad (D12) ───────────────────────────────────────
    '3.17.11':['conciliacion', 'cuadre', 'diferencia', 'reconcil', 'cam_', 'compensac',
               'cam_asigna', 'cam_carga', 'cam_dev', 'cam_firma', 'cam_monitor',
               'conscheq', 'cheq'],
    '5.4.1':  ['cont_catalogo', 'cont_catalog', 'mayor', 'cuenta_contable', 'cont_empresa',
               'cont_producto', 'cont_carga', 'catalogo_cont', 'asiento'],
    '5.4.2':  ['resultado', 'utilidad', 'balance', 'performance'],
    '5.4.4':  ['proyeccion', 'presupuesto', 'forecast'],
    '5.4.5':  ['impuesto', 'sat', 'isr', 'iva', 'retencion', 'fiscal', 'sorteo_sat'],
    '5.4.8':  ['posicion', 'saldo_diario', 'divisa', 'cont_divisa', 'cont_saldo',
               'datosdia', 'datos_dia'],

    # ── TEF (D13) — mismos patrones que SPEI ────────────────────
    # keywords 3.4.1-3.4.8 ya definidas arriba, aplican igual

    # ── BEI (D14) ────────────────────────────────────────────────
    # keywords 7.1.1-7.1.4 ya definidas arriba

    # ── LIDE / PLD (D15) ─────────────────────────────────────────
    '5.10.4': ['monitoreo', 'auditoria', 'supervision', 'bitacora', 'ope_bitacora',
               'mindstelefono'],
    '5.10.6': ['reporte', 'ope_consulta', 'ope_carga', 'informe', 'uif', 'xml_reg',
               'cargainfo', 'ope_'],
    '5.8.1':  ['pld', 'lide', 'lavado', 'aml', 'listanegra', 'lista_negra',
               'busqueda_cte', 'sustituirse', 'eliminarse', 'marcarse',
               'insertasite', 'bf_', 'coincidencia'],
    '5.8.2':  ['fraude', 'deteccion', 'alerta_fraude', 'riesgo_op', 'bf_aplicar'],

    # ── Tarjetas (D16) ───────────────────────────────────────────
    '3.15.1': ['politica', 'procedimiento', 'parametro', 'regla'],
    '3.15.2': ['interes', 'comision', 'tasa', 'calculo_cargo'],
    '3.16.1': ['limite', 'credito_disp', 'saldo_limite'],
    # 3.4.3 shared (cargo, pago, transacc)

    # ── SAC / D05 — ampliar señales ──────────────────────────────
    # 3.17.8 Balance & reporting
    # 3.2.4  Deposit Account Servicing (aplica_pago, abono, cargo)

    # ── Shared across domains ────────────────────────────────────
    '7.1.2':  ['autenticac', 'nip', 'password', 'firma', 'biometri',
               'identificac', 'verifica', 'token', 'clave', 'acceso_cte'],
    '7.1.4':  ['bloqueo', 'desbloqueo', 'sesion', 'permiso', 'perfil_acceso'],
}

# Capabilities que corresponden a SPs transversales dentro de cada dominio
# (pago core, saldo, cargo, abono — presentes en casi todos los dominios de cuentas/pagos)
CROSS_CAPS = {'3.4.3', '3.2.4'}

# SPs que se marcan como cross-domain por rol → no asignar primary_l3
CROSS_ROLES = frozenset({'cross_domain_primitive', 'shared_service'})


def tokenize(text: str) -> str:
    """Normaliza texto: minúsculas, sustituye _ por espacio, elimina acentos básicos."""
    text = (text or '').lower()
    text = text.replace('_', ' ').replace('-', ' ')
    # remover prefijo sp al inicio de palabras
    text = re.sub(r'\bsp\b', '', text)
    return text


def score_sp(name: str, biz: str, keywords: list[str]) -> float:
    """Suma ponderada: 2 si keyword en name, 1 si en biz."""
    if not keywords:
        return 0.0
    name_t = tokenize(name)
    biz_t  = tokenize(biz)
    s = 0.0
    for kw in keywords:
        kw_n = tokenize(kw)
        if kw_n in name_t:
            s += 2.0
        elif kw_n in biz_t:
            s += 1.0
    return s


def main():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    cur  = conn.cursor()

    # ── Añadir columnas a sps si no existen ────────────────────────────────
    existing_cols = {r[1] for r in cur.execute("PRAGMA table_info(sps)").fetchall()}
    for col, typ in [('primary_l3','TEXT'), ('primary_l3_confidence','REAL')]:
        if col not in existing_cols:
            cur.execute(f"ALTER TABLE sps ADD COLUMN {col} {typ}")
            print(f"  + sps.{col} añadida")

    # ── Añadir etb_l3.sp_fine_n si no existe ───────────────────────────────
    l3_cols = {r[1] for r in cur.execute("PRAGMA table_info(etb_l3)").fetchall()}
    if 'sp_fine_n' not in l3_cols:
        cur.execute("ALTER TABLE etb_l3 ADD COLUMN sp_fine_n INTEGER DEFAULT 0")
        print("  + etb_l3.sp_fine_n añadida")

    # ── Cargar capacidades por dominio ─────────────────────────────────────
    domain_caps: dict[str, list[str]] = defaultdict(list)
    for row in cur.execute("SELECT domain_id, l3_id FROM domain_capabilities").fetchall():
        domain_caps[row['domain_id']].append(row['l3_id'])

    # ── Procesar todos los SPs con dominio D01-D16 ─────────────────────────
    sps = cur.execute("""
        SELECT id, name, biz, sp_role, domain
        FROM sps WHERE domain IS NOT NULL AND domain != ''
    """).fetchall()

    fine_n     = 0
    cross_n    = 0
    ambig_n    = 0
    no_domain_n= 0

    l3_fine_count: dict[str, int] = defaultdict(int)
    updates = []

    for sp in sps:
        sp_id   = sp['id']
        name    = sp['name'] or ''
        biz     = sp['biz']  or ''
        role    = sp['sp_role'] or ''
        domain  = sp['domain']

        # Cross-domain primitives / shared services → no primary assignment
        if role in CROSS_ROLES:
            updates.append((None, None, sp_id))
            cross_n += 1
            continue

        candidates = domain_caps.get(domain, [])
        if not candidates:
            updates.append((None, None, sp_id))
            no_domain_n += 1
            continue

        if len(candidates) == 1:
            # Solo una capacidad en el dominio → asignación directa con confianza alta
            l3_id = candidates[0]
            updates.append((l3_id, 1.0, sp_id))
            l3_fine_count[l3_id] += 1
            fine_n += 1
            continue

        # Puntuar contra cada capacidad candidata
        scores: list[tuple[float, str]] = []
        for l3_id in candidates:
            kws = KEYWORDS.get(l3_id, [])
            s   = score_sp(name, biz, kws)
            scores.append((s, l3_id))

        scores.sort(reverse=True)
        best_score, best_l3 = scores[0]
        second_score = scores[1][0] if len(scores) > 1 else 0.0

        if best_score == 0.0:
            # Sin señal → ambiguo, sin primary
            updates.append((None, None, sp_id))
            ambig_n += 1
            continue

        # Confianza = fracción del score del ganador sobre la suma total
        total = sum(s for s, _ in scores)
        confidence = best_score / total if total > 0 else 0.0

        # Umbral mínimo de confianza para asignar primary
        if confidence < 0.35:
            updates.append((None, None, sp_id))
            ambig_n += 1
            continue

        updates.append((best_l3, round(confidence, 4), sp_id))
        l3_fine_count[best_l3] += 1
        fine_n += 1

    # ── Aplicar updates ────────────────────────────────────────────────────
    cur.executemany(
        "UPDATE sps SET primary_l3=?, primary_l3_confidence=? WHERE id=?",
        updates
    )

    # ── Actualizar etb_l3.sp_fine_n ───────────────────────────────────────
    cur.execute("UPDATE etb_l3 SET sp_fine_n=0")
    for l3_id, n in l3_fine_count.items():
        cur.execute("UPDATE etb_l3 SET sp_fine_n=? WHERE id=?", (n, l3_id))

    conn.commit()
    print(f"\n=== Resultados ===")
    print(f"  Fine-grained asignados  : {fine_n:>6,}  ({fine_n/len(sps)*100:.1f}%)")
    print(f"  Cross/shared (sin asig) : {cross_n:>6,}  ({cross_n/len(sps)*100:.1f}%)")
    print(f"  Ambiguos (sin asig)     : {ambig_n:>6,}  ({ambig_n/len(sps)*100:.1f}%)")

    # ── Distribución por L3 ───────────────────────────────────────────────
    print(f"\n  Top 20 capacidades por SPs fine asignados:")
    top = sorted(l3_fine_count.items(), key=lambda x: -x[1])[:20]
    for l3_id, n in top:
        meta = cur.execute("SELECT name FROM etb_l3 WHERE id=?", (l3_id,)).fetchone()
        name_str = meta['name'] if meta else '?'
        print(f"    {l3_id:<10} {name_str:<45} {n:>5} SPs")

    # ── Actualizar JSON ───────────────────────────────────────────────────
    print(f"\nActualizando {OUT_JSON}...")
    try:
        with open(OUT_JSON, encoding='utf-8') as f:
            cap_map = json.load(f)

        for l3_id, n in l3_fine_count.items():
            if l3_id in cap_map.get('capabilities', {}):
                cap_map['capabilities'][l3_id]['sp_fine_n'] = n

        # También poblar key_sps_fine: top 10 SPs con primary_l3 = este L3
        for l3_id in cap_map.get('capabilities', {}):
            fine_sps = cur.execute("""
                SELECT id, name, biz, sp_role, is_soul, fan_in, fan_out
                FROM sps WHERE primary_l3=?
                ORDER BY
                  CASE sp_role
                    WHEN 'esb_exposed' THEN 0 WHEN 'entry_point' THEN 1
                    WHEN 'super_orchestrator' THEN 2 WHEN 'orchestrator' THEN 3
                    ELSE 5 END,
                  is_soul DESC, fan_in DESC
                LIMIT 10
            """, (l3_id,)).fetchall()
            cap_map['capabilities'][l3_id]['key_sps_fine'] = [
                {'id': r['id'], 'name': r['name'], 'biz': r['biz'] or '',
                 'role': r['sp_role'] or '', 'is_soul': bool(r['is_soul']),
                 'fan_in': r['fan_in'] or 0} for r in fine_sps
            ]

        # Actualizar domain_l3_map con sp_fine_n
        for domain, caps in cap_map.get('domain_l3_map', {}).items():
            for cap in caps:
                l3_id = cap['l3_id']
                cap['sp_fine_n'] = l3_fine_count.get(l3_id, 0)

        with open(OUT_JSON, 'w', encoding='utf-8') as f:
            json.dump(cap_map, f, ensure_ascii=False, indent=2)
        print(f"JSON actualizado.")
    except Exception as e:
        print(f"  WARN: no se pudo actualizar JSON: {e}")

    conn.close()


if __name__ == '__main__':
    main()
