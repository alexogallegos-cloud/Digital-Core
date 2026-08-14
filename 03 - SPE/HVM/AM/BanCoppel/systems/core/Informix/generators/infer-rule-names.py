#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
infer-rule-names.py — Inferencia semántica de nombres de reglas de negocio Informix.

Fuentes de conocimiento embebidas:
  · Vocabulario Informix (mean + bc_name + cat) — léxico de variables SPL
  · DT Industry Banking — patrones financieros: tasa, mora, IVA, ISR, reservas CNBV,
                           base 365/360, GAT, CAT, cartera vencida, scoring
  · DT Industry Banking Accounting — patrones contables: póliza, asiento, mayor, cédula
  · DT DBA IBM Informix — semántica de funciones: TRUNC, ROUND, MONEY, TODAY, MOD, NVL

Algoritmo por regla:
  1. Extraer LHS del LET/SET (la variable que se calcula → buscar en vocab → mean)
  2. Extraer RHS y detectar patrones financieros/contables
  3. Identificar el término de vocab más relevante (bc != Transversal)
  4. Para VALIDACIÓN: extraer código de error o condición de excepción
  5. Aplicar plantilla por tipo (FÓRMULA/VALIDACIÓN/UMBRAL/ESTADO)
  6. Comentario del dev como guía secundaria — solo si inferencia débil Y comentario coherente
  7. Fallback: derivar del nombre del SP

Input:  portal/data/business-rules-v3.json
        knowledge-base/vocabulary-inventory.json
Output: portal/data/business-rules-v3.json (business_name actualizado)

Cambios v1.5.0 (2026-08-07):
  · RE_BARE — captura asignaciones DESNUDAS 'var = expr' (sin let/set): +1,900 FÓRMULA
    obtienen LHS real (antes caían a tokenización del SP).
  · VALIDACIÓN con sujeto del SP — V-err/V-raise pasan de "código de error NNNN"
    a "Validación de {sujeto} — error NNNN" (2,165 reglas enriquecidas).
  · split_sp_compound — mínimo de match 4 chars + whitelist _SAFE3 de 3-char
    distintivos; elimina roturas mid-word (respaldo→'resultado paldo').
  · ABBREV Layer B+ — tokens frecuentes de corpus (tarjeta, cancelación, cheque,
    cargo, aclaración, conciliación, transacción, movimientos, etc.).
  · Métrica honesta: reporta fuente real por rama (antes medía estructura de código
    y sobre-reportaba 59% fallback; real ≈ 8%).

SPE-AM-001 · DT-Reglas v1.5.0
"""
import json, re, io, sys
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")

# ── 1. Vocabulario ─────────────────────────────────────────────────────────────
inv = json.load(open(BASE + "knowledge-base/vocabulary-inventory.json", encoding="utf-8"))
VOCAB = {}
for section in ("atomos", "compuestos"):
    for item in inv.get(section, []):
        VOCAB[item["term"]] = item

# ── 1b. Tipos declarados (DEFINE) — mapa {db_sp: {var: tipo}} evidence-based ─────
# Fuente: extract-var-types.py sobre source/informix/*.sql (2.9M declaraciones).
# Se usa para la señal MONEY→riesgo de equivalencia. Índice case-insensitive.
try:
    _vt_raw = json.load(open(BASE + "knowledge-base/vocabulary/variable-types.json", encoding="utf-8"))
    VARTYPES = {k.lower(): v for k, v in _vt_raw.items()}
except Exception:
    VARTYPES = {}

# ── 2. DT DBA IBM Informix — abreviaciones de variables SPL ───────────────────
# Variables de trabajo comunes en Informix SPL: v_xxx, p_xxx (param), w_xxx (work), etc.
_VAR_PREFIX = re.compile(r'^[vpwlosnibckmfh]_(?:tmp_)?', re.I)

# Expansión de abreviaciones bancarias (DT Industry Banking + DBA Informix)
ABBREV = {
    # Saldos y montos
    'sdo': 'saldo', 'sdos': 'saldos', 'mto': 'monto', 'mnt': 'monto', 'imp': 'importe',
    'mon': 'monto', 'amt': 'importe', 'cant': 'cantidad', 'tot': 'total',
    'dif': 'diferencia', 'promedio': 'promedio', 'prom': 'promedio', 'min': 'mínimo', 'max': 'máximo',
    'sdodisp': 'saldo disponible', 'sdovenc': 'saldo vencido',
    'sdocap': 'saldo de capital', 'sdoint': 'saldo de interés',
    'saldo': 'saldo', 'saldo1': 'saldo principal', 'saldo2': 'saldo secundario',
    'dsaldo': 'saldo diferencial', 'dsaldo1': 'saldo diferencial 1',
    'saldoact': 'saldo actual', 'saldodis': 'saldo disponible',
    'saldovenc': 'saldo vencido', 'saldocap': 'saldo de capital',
    # Intereses y tasas (Industry Banking)
    'integracion': 'integración', 'integraciones': 'integración',
    'int': 'interés', 'interes': 'interés', 'intereses': 'intereses',
    'tasa': 'tasa de interés', 'tasaint': 'tasa de interés',
    'intord': 'interés ordinario', 'intmor': 'interés moratorio',
    'int_ord': 'interés ordinario', 'int_mor': 'interés moratorio',
    'tasa_ord': 'tasa ordinaria', 'tasa_mor': 'tasa moratoria',
    'tasafija': 'tasa fija', 'tasavar': 'tasa variable', 'tasaref': 'tasa de referencia',
    'tasaanual': 'tasa anual', 'tasadiaria': 'tasa diaria',
    'capitali': 'capitalización de interés', 'capint': 'capitalización de interés',
    # Crédito y cartera
    'cred': 'crédito', 'credito': 'crédito', 'creditos': 'créditos',
    'cap': 'capital', 'capital': 'capital', 'plazo': 'plazo',
    'amort': 'amortización', 'amor': 'amortización',
    'venc': 'vencido', 'vencido': 'vencido', 'diasatr': 'días de atraso',
    'dias_atr': 'días de atraso', 'diaspago': 'días de pago',
    'lincred': 'línea de crédito', 'cartera': 'cartera',
    'cobranza': 'cobranza', 'mora': 'mora',
    'diasplazo': 'días de plazo', 'plazonum': 'plazo en días',
    'parcial': 'pago parcial', 'liquidacion': 'liquidación', 'liqd': 'liquidación',
    # Frecuencia y período
    'frec': 'frecuencia', 'frecpago': 'frecuencia de pago',
    'periodo': 'período', 'periodos': 'períodos',
    'mensual': 'mensual', 'quincenal': 'quincenal', 'semanal': 'semanal',
    'bimestral': 'bimestral', 'trimestral': 'trimestral',
    # Cobros y pagos
    'pago': 'pago', 'pagos': 'pagos', 'abono': 'abono', 'cargo': 'cargo',
    'pagmin': 'pago mínimo', 'pag_min': 'pago mínimo', 'pago_min': 'pago mínimo',
    'comis': 'comisión', 'comision': 'comisión', 'com': 'comisión',
    'iva': 'IVA', 'isr': 'ISR', 'ret': 'retención',
    'impmora': 'importe de mora', 'impiva': 'importe de IVA',
    'impcomis': 'importe de comisión', 'impint': 'importe de interés',
    # Contabilidad (Industry Banking Accounting)
    'pol': 'póliza', 'poliza': 'póliza',
    'asiento': 'asiento contable', 'mayor': 'libro mayor',
    'cedula': 'cédula contable', 'cont': 'contable',
    'ctacont': 'cuenta contable', 'cuentacont': 'cuenta contable',
    # Retornos y códigos (DBA Informix)
    'codret': 'código de retorno', 'codretorno': 'código de retorno',
    'codretno': 'código de retorno', 'cod_ret': 'código de retorno',
    'return': 'resultado', 'resultado': 'resultado', 'res': 'resultado',
    'codstatus': 'código de estado', 'coderror': 'código de error',
    # Cuentas y clientes
    'cta': 'cuenta', 'ctas': 'cuentas', 'cuenta': 'cuenta',
    'cte': 'cliente', 'ctes': 'clientes', 'cliente': 'cliente',
    'numcte': 'número de cliente', 'numcredito': 'número de crédito',
    'numpago': 'número de pago', 'numctrl': 'número de control',
    'numdoc': 'número de documento', 'numop': 'número de operación',
    'suc': 'sucursal', 'prod': 'producto', 'moneda': 'moneda',
    # Catálogos y referencia
    'cod': 'código', 'ref': 'referencia', 'desc': 'descripción',
    'est': 'estatus', 'stat': 'estatus', 'num': 'número',
    'fec': 'fecha', 'fech': 'fecha', 'sql': '',
    # SQL/DML keywords (no aportan semántica de negocio)
    'insert': '', 'update': '', 'delete': '', 'select': '',
    'into': '', 'from': '', 'where': '', 'set': '', 'get': '',
    'load': 'carga', 'unload': 'descarga', 'fetch': '',
    # Indicadores CNBV
    'cat': 'CAT', 'gat': 'GAT', 'tir': 'TIR', 'van': 'VAN',
    'prov': 'provisión', 'reserva': 'reserva preventiva',
    'calificacion': 'calificación CNBV', 'calif': 'calificación',
    # Canales y productos
    'bpi': 'banca por internet', 'atm': 'cajero automático',
    'tdc': 'tarjeta de crédito', 'tdd': 'tarjeta de débito',
    'spei': 'SPEI', 'tef': 'TEF', 'codi': 'CoDi',
    # Cobranza y campañas
    'camp': 'campaña', 'campania': 'campaña',
    'envio': 'envío', 'enviar': 'envío',
    'ctas': 'cuentas', 'ctaspzo': 'cuentas por plazo',
    'ctasrev': 'cuentas en revisión', 'ctascanceladas': 'cuentas canceladas',
    'pzo': 'plazo', 'zona': 'zona',
    'afectacion': 'afectación', 'afect': 'afectación',
    'operacion': 'operación', 'operaciones': 'operaciones',
    'dotacion': 'dotación', 'dotaciones': 'dotaciones',
    'archivo': 'archivo', 'archivos': 'archivos',
    'solicitud': 'solicitud', 'aceptacion': 'aceptación',
    'masiva': 'masiva', 'masivo': 'masivo',
    'calcula': 'cálculo', 'calcul': 'cálculo',
    'reac': 'reactivación', 'reactiv': 'reactivación',
    'cobro': 'cobro', 'cobros': 'cobros',
    'vencidos': 'vencidos', 'atrasos': 'atrasos',
    # Operaciones
    'ope': 'operación', 'oper': 'operación',
    'cons': 'consulta', 'consult': 'consulta',
    'act': 'actualización', 'actua': 'actualización',
    'gen': 'generación', 'genera': 'generación',
    'rep': 'reporte', 'repor': 'reporte',
    'proc': 'proceso', 'proce': 'proceso',
    'guarda': 'guardar', 'guard': 'guardar',
    'meta': 'meta', 'metas': 'metas',
    'captacion': 'captación',
    # Clientes y cuentas
    'cte': 'cliente', 'ctes': 'clientes',
    'afil': 'afiliado', 'afilia': 'afiliado',
    'tipcte': 'tipo de cliente', 'tipcred': 'tipo de crédito',
    # Dominios técnicos de BD (prefijos de BDI)
    'bdisac': 'crédito activo', 'bdicred': 'crédito',
    'bdicob': 'cobranza', 'bdipag': 'pagos',
    'bdisuc': 'sucursales', 'bditarj': 'tarjetas',
    'bdicheq': 'cheques', 'bditrans': 'transferencias',
    # AML/PLD
    'rfc': 'RFC', 'ine': 'INE', 'pld': 'PLD',
    'fatca': 'FATCA', 'inactiv': 'cuenta inactiva',
    # Acciones de SP (prefijos de nombres de SP)
    'dskrg': 'descarga', 'dskrga': 'descarga',
    'rpt': 'reporte', 'rprt': 'reporte',
    'calc': 'cálculo', 'calcu': 'cálculo',
    'comp': 'complemento', 'compl': 'complemento',
    'ainfo': 'información',
    'inf': 'información',
    # Temporalidad en nombres de SP
    'anio': 'año', 'anios': 'años', 'dias': 'días', 'dia': 'día',
    'meses': 'meses', 'mes': 'mes',
    # Palabras completas frecuentes en SP names
    'inform': 'información', 'informa': 'información',
    'actas': 'actas', 'operativa': 'operativa',
    'inactividad': 'inactividad',
    # Layer B+ — tokens frecuentes de SP-name detectados en corpus analysis (2026-08-07)
    # NOTA: solo entradas ≥4 chars o combinaciones distintivas — evita mid-word en split_sp_compound.
    'tarj': 'tarjeta', 'tarjc': 'tarjeta de crédito',
    'canc': 'cancelación', 'cancela': 'cancelación', 'cancelacion': 'cancelación',
    'venta': 'venta', 'ventas': 'ventas',
    'incr': 'incremento', 'incremento': 'incremento',
    'gravable': 'gravable',
    'concil': 'conciliación', 'concilia': 'conciliación', 'conciliacion': 'conciliación',
    'corrige': 'corrección', 'correccion': 'corrección',
    'cierre': 'cierre', 'cierres': 'cierres',
    'anticipado': 'anticipado', 'anticip': 'anticipo',
    'sesion': 'sesión', 'session': 'sesión',
    'biometria': 'biometría', 'identificar': 'identificación',
    'aproximacion': 'aproximación', 'manejo': 'manejo',
    'tablatemp': 'tabla temporal',
    'riesgo': 'riesgo', 'balanza': 'balanza', 'oyp': 'órdenes y pagos',
    'chq': 'cheque', 'chqc': 'cheque', 'crg': 'cargo', 'crgo': 'cargo',
    'upd': 'actualización',
    'geninf': 'generación de información', 'geninsumos': 'generación de insumos',
    'transacc': 'transacción', 'transac': 'transacción', 'movs': 'movimientos',
    'devol': 'devolución', 'reverso': 'reverso',
    # Guards de forma larga: ganan el greedy longest-first sobre entradas cortas
    # preexistentes ('dia','prov') que rompían palabras (diario→'día'+rioacl).
    'diario': 'diario', 'diaria': 'diaria', 'diarios': 'diarios',
    'provision': 'provisión', 'aprovisionamiento': 'aprovisionamiento',
    'historico': 'histórico', 'historica': 'histórica',
    # Dominio Aclaraciones (muy frecuente en corpus) — guards largos evitan romper 'aclaraciones'
    'acl': 'aclaración', 'aclara': 'aclaración', 'aclaracion': 'aclaración',
    'aclaraciones': 'aclaraciones', 'aclaracions': 'aclaraciones',
    # Corresponsalía, tarjeta de crédito, UDIs — gaps observados 2026-08-07
    'corresp': 'corresponsal', 'corresponsal': 'corresponsal',
    'pagotdc': 'pago de tarjeta de crédito', 'pagotc': 'pago de tarjeta de crédito',
    'udi': 'UDI', 'udis': 'UDIS',
    'otro': 'otro', 'banco': 'banco', 'otrobanco': 'otro banco',
    'cargocta': 'cargo a cuenta', 'abonocta': 'abono a cuenta',
    # Layer B+ ronda 2 (2026-08-07) — evidence-based vs dominio/source.
    # Los de 3 chars (aux/rem/cel/art/sac/cub) NO van en _SAFE3: solo match exacto de token.
    'domi': 'domiciliación', 'domiciliacion': 'domiciliación',   # verificado: D21 Domiciliación
    'aux': 'auxiliar',
    'numint': 'número interior', 'numext': 'número exterior',
    'numintcalle': 'número interior de calle', 'numintrabajo': 'número interior de trabajo',
    'domicilio': 'domicilio', 'calle': 'calle', 'trabajo': 'trabajo',
    'acum': 'acumulado', 'porc': 'porcentaje', 'cel': 'celular',
    'rem': 'remesa', 'remesa': 'remesa', 'remesas': 'remesas',
    'depuracion': 'depuración', 'atms': 'cajeros automáticos',
    'archsdos': 'archivo de saldos',
    # v-prefijo sin underscore (LHS de asignación desnuda): vmonto→monto
    'vmonto': 'monto', 'vsdo': 'saldo', 'vsaldo': 'saldo', 'vtasa': 'tasa de interés',
    'vfecha': 'fecha', 'vimporte': 'importe', 'vcodret': 'código de retorno',
    # Acrónimos regulatorios / fiscales (mantener mayúsculas)
    'ipab': 'IPAB', 'cub': 'CUB', 'ltosf': 'LTOSF', 'lisr': 'LISR',
    'sac': 'SAC', 'art': 'artículo', 'tesofe': 'TESOFE',
    # Layer B+ ronda 3 (2026-08-07) — barrida completa top-130 del corpus
    'edo': 'estado', 'edocta': 'estado de cuenta', 'eje': 'ejecutivo',
    'transfer': 'transferencia', 'transferencia': 'transferencia',
    'fisico': 'físico', 'fisica': 'física', 'ctefisico': 'cliente físico',
    'ctemovil': 'cliente móvil', 'movil': 'móvil',
    'disp': 'disponible', 'afore': 'AFORE', 'sat': 'SAT',
    'proyec': 'proyección', 'proy': 'proyección', 'proyeccion': 'proyección',
    'factelect': 'factura electrónica', 'factura': 'factura', 'electronica': 'electrónica',
    'faltsob': 'faltante o sobrante', 'faltante': 'faltante', 'sobrante': 'sobrante',
    'ofi': 'oficina', 'oficina': 'oficina', 'pag': 'pago', 'ordi': 'ordinario', 'ini': 'inicio',
    'genrep': 'generación de reporte', 'burofisicas': 'buró de personas físicas',
    # Buró de Crédito / Círculo de Crédito — validado por SME Industry Banking 2026-08-07
    # bccc = módulo conjunto BC+CC (sp_bccc_*); bc/cc sin prefijo son ambiguos en este corpus
    'bccc': 'Buró de Crédito y Círculo de Crédito',
    'intdiario': 'interés diario', 'intgrav': 'interés gravable', 'baseisr': 'base de ISR',
    'pagares': 'pagarés', 'pagare': 'pagaré', 'renueva': 'renovación',
    'conhuella': 'con huella biométrica',
    # Stems para el strip de prefijo de tipo (v/w): 'vmonto'→strip v→'monto'
    'monto': 'monto', 'valor': 'valor', 'importe': 'importe', 'fecha': 'fecha',
    'saldo': 'saldo', 'resultado': 'resultado', 'tasa': 'tasa de interés',
    # Layer B+ ronda 4 (2026-08-07) — barrida
    'cre': 'crédito', 'crd': 'crédito', 'cheq': 'cheque',
    'soldocta': 'saldo de cuenta', 'circulocredito': 'Círculo de Crédito',
    'niv': 'nivel', 'adm': 'administración', 'admin': 'administrador',
    'movtos': 'movimientos', 'amovtos': 'movimientos', 'aud': 'auditoría',
    'pend': 'pendiente', 'pendientes': 'pendientes',
    'dispersion': 'dispersión', 'dispercion': 'dispersión',
    'bex': 'BEX', 'traspasados': 'traspasados',
    'ingreso': 'ingreso', 'ingresos': 'ingresos', 'ingresomensual': 'ingreso mensual',
    'fpago': 'fecha de pago', 'solicitud': 'solicitud', 'idsolicitud': 'ID de solicitud',
    'token': 'token', 'sucursal': 'sucursal', 'cancelartoken': 'cancelación de token',
    'cnom': 'nombre', 'nomarchivo': 'nombre de archivo', 'nombrearchivo': 'nombre de archivo',
    'nomarch': 'nombre de archivo', 'nomcliente': 'nombre del cliente',
    # 'tri' → trimestre: VALIDADO por evidencia (fórmula usa fecha 31-mar = fin de Q1)
    'tri': 'trimestre', 'trim': 'trimestre',
    # Compuestos CamelCase de fecha (evidencia: cFechCortMesSig, cFechCortInmAnt)
    'cort': 'corte', 'sig': 'siguiente', 'inm': 'inmediato', 'ant': 'anterior',
    'numero': 'número', 'semana': 'semana',
    'pais': 'país', 'nacionalidad': 'nacionalidad',
    'paisnacionalidad': 'país de nacionalidad', 'idpaisnacionalidad': 'país de nacionalidad',
    'lin': 'línea', 'total': 'total', 'linprom': 'línea promedio',
    # Barrida bulk (2026-08-07) — sub-fragmentos LHS reales del corpus (top-40)
    'favor': 'a favor', 'factor': 'factor', 'cargos': 'cargos', 'adeudo': 'adeudo',
    'suma': 'suma', 'moratorio': 'moratorio', 'acumulado': 'acumulado', 'porcentaje': 'porcentaje',
    'costo': 'costo', 'real': 'real', 'otros': 'otros', 'fin': 'fin', 'debe': 'debe',
    'grav': 'gravable', 'cong': 'congelado', 'civ': 'civil', 'nvo': 'nuevo', 'req': 'requerido',
    'saldocifra': 'saldo de control', 'edociv': 'estado civil',
    # sbg=Saldo Base Generador: validado por fórmula (interés=imp_sbg×tasa/360×días) + término estándar MX
    'sbg': 'saldo base generador', 'impsbg': 'importe base generador',
    # cope=Coppel: validado vs portafolio (producto "Grupo Coppel"/"Crédito Coppel";
    # columnas mora_*_cope en sd_amortiza_credito = porción Coppel del crédito)
    'cope': 'Coppel',
    # Productos confirmados en el portafolio público BanCoppel
    'invcrec': 'inversión creciente', 'inversioncreciente': 'inversión creciente',
    'creciente': 'creciente', 'pagare': 'pagaré',
    # Top variables en UMBRAL/FÓRMULA fallback — validadas en corpus 2026-08-07
    'diasinact': 'días inactivo', 'idiasinact': 'días inactivo',
    'catfinal': 'categoría final',
    'cuotasvenc': 'cuotas vencidas',
    'pagopropuesto': 'pago propuesto',
    'nom': 'nombre',          # vnomtabla → 'nombre tabla'
    'nomtabla': 'nombre de tabla',
    'mny': 'monto',           # vmnysdoprom → 'monto saldo promedio' (pendiente validación DBA)
    'contintento': 'contador de intentos',
    'nobeneficiarios': 'número de beneficiarios',
    'saldomorhist': 'saldo mora histórico',
    'consumo': 'consumo', 'cartconsumo': 'cartera de consumo',
    'califcartconsumo': 'calificación de cartera de consumo',
    'extcartconsumo': 'extracción de cartera de consumo', 'enc': 'encabezado',
    # Confirmados por código fuente 2026-08-07 (string literal en sp_bccc_*):
    # 'FUNCIONALIDAD: MONITOR DE LA SITUACIÓN DE LOS ENVÍOS A BC Y CC'
    'bc': 'Buró de Crédito', 'cc': 'Círculo de Crédito',
    # bdisuc: catdenominacion_bym / piezas_bym / dictamen_bym → denominaciones y piezas físicas de efectivo
    'bym': 'billetes y monedas',
    # inv/ctamec/cnsif/cope/par/mib/cjunk/tes/fin/esp/ant: AMBIGUOS — pendientes de source/SME (no adivinar)
}

# Extensión para humanización de expresiones (variables CamelCase sin prefijo _)
ABBREV_EXPR = {**ABBREV,
    'calc': 'calculado', 'dias': 'días', 'dia': 'día',
    'anio': 'año', 'aniobase': 'año base',
    'suj': 'sujeto', 'por': 'porcentaje',
    'grav': 'gravable', 'gravable': 'gravable',
    'imp': 'importe', 'base': 'base',
}

# ── Notación húngara SPL — prefijo de 1 letra que se limpia del NOMBRE ────────
# Convención BanCoppel (knowledge-base/vocabulary/notacion-hungara-spl.md):
#   scope (ruido claro): v=variable · w=work · p=parámetro · g=global · l=local
#   1 letra AMBIGUA: c/s/m/i/n/d/b — puede ser tipo (money/date/char…), semántica
#     (c=cálculo, según observación del usuario) o inicial de palabra. Para el NOMBRE
#     da igual: quitarla y quedarse con el cuerpo produce el término correcto
#     ('cinteres'→'interés'; el template ya antepone "Cálculo de").
# El strip es CONDICIONAL (solo si el resto resuelve a negocio), así 'cuenta'/'saldo'/
# 'venta'/'credito' quedan intactos. El significado autoritativo del prefijo de tipo
# se verifica en source (no se asume) — ver §caveats del artefacto de KB.
# 'a' incluida: validada contra DEFINE (2026-08-07) — NO predice tipo (a+saldo da
# MONEY/DATE/CHAR/INT mixto), es scope/semántica; segura de quitar para el nombre
# porque el guard condicional deja intactas abono/apertura/ajuste/ahorro/activo.
_HUNGARIAN_PREFIX = frozenset('vwpglscmindba')
def _strip_hungarian(s: str) -> str:
    # Prueba quitar 1 o 2 letras de prefijo (scope+tipo: 'vg','vm'…), condicional
    # a que el resto resuelva a negocio (así 'venta'/'credito' no se tocan).
    for k in (1, 2):
        if len(s) >= 4 + (k - 1) and all(s[j] in _HUNGARIAN_PREFIX for j in range(k)):
            rest = s[k:]
            if (ABBREV.get(rest)) or (VOCAB.get(rest, {}).get('mean')):
                return rest
    return s

def humanize_var(var: str) -> str:
    """Convierte nombre de variable SPL a español legible."""
    s = _VAR_PREFIX.sub('', var).lower()
    s = re.sub(r'\d{3,}$', '', s)          # sufijo numérico largo = ruido (cint1257→cint)
    # Match directo ANTES del strip húngaro: 'cope'→'Coppel' debe ganar sobre strip→'ope'
    if s in ABBREV:
        return ABBREV[s]
    _vd = VOCAB.get(s, {})
    if _vd.get('mean') and _vd['mean'] != s:
        return _vd['mean']
    s = _strip_hungarian(s)
    if s in ABBREV:
        return ABBREV[s]
    v = VOCAB.get(s, {})
    if v.get('mean') and v['mean'] != s:
        return v['mean']
    # Descomponer por underscores; match directo ANTES del strip húngaro (cope→Coppel gana);
    # token glued sin match → descomponer con split_sp_compound (como expand_sp_tokens).
    expanded = []
    for p0 in s.replace('_', ' ').split():
        d = ABBREV.get(p0)
        p = p0
        if not d:
            p = _strip_hungarian(p0)
            d = ABBREV.get(p)
        if d:
            expanded.append(d)
        elif len(p) > 5 and not VOCAB.get(p, {}).get('mean'):
            expanded.extend(split_sp_compound(p))
        elif p:
            expanded.append(p)
    expanded = [e for e in expanded if e]  # elimina expansiones vacías (palabras SQL)
    result = ' '.join(expanded) if expanded else s
    # Descartar si el resultado es un token largo sin underscores (variable no descomponible)
    if '_' not in s and len(result) > 18 and result == s:
        return ''
    # Limitar si queda demasiado largo
    return result if len(result) <= 50 else s

def vocab_mean(term: str) -> str:
    """Retorna el significado del término del vocabulario."""
    v = VOCAB.get(term, {})
    mn = v.get('mean', '') or ''
    if mn and mn != term:
        return mn
    return humanize_var(term)

# ── Humanización de expresiones SPL ──────────────────────────────────────────
_CAMEL_EXPR = re.compile(r'[A-Z][a-z0-9]+|[A-Z]+(?=[A-Z][a-z]|$)|[a-z][a-z0-9]*')
_EXPR_VAR   = re.compile(r'\b[a-zA-Z][a-zA-Z0-9_]+\b')
_SQL_KW = frozenset({
    'let','set','return','if','then','else','end','call','null','true','false',
    'and','or','not','is','in','select','from','where','into','values','begin',
    'round','trunc','money','nvl','today','extend','mod','abs','substr',
    'trim','upper','lower','foreach','define','execute','procedure','function',
    'like','between','case','when','having','group','order','by',
})
# Prefijos de función/procedimiento — ruido de nombre (fnNumeroSemana → 'número de semana')
_FN_PREFIX = frozenset({'fn', 'sp', 'usp', 'fun', 'func'})

def humanize_var_expr(var: str) -> str:
    """Como humanize_var pero maneja CamelCase sin prefijo-underscore (vIsrCalc, iDias)."""
    s = _VAR_PREFIX.sub('', var)
    # Quitar prefijo de tipo de un solo carácter antes de mayúscula (vIsrCalc→IsrCalc, iDias→Dias)
    s = re.sub(r'^[a-z](?=[A-Z])', '', s)
    s_lo = _strip_hungarian(s.lower())   # scope prefix sin underscore (vmonto→monto)

    if s_lo in ABBREV_EXPR and ABBREV_EXPR[s_lo]:
        return ABBREV_EXPR[s_lo]
    v = VOCAB.get(s_lo, {})
    if v.get('mean') and v['mean'] != s_lo:
        return v['mean']

    # Parte por '_' Y por CamelCase (el código conserva mayúsculas: FechCortMesSig → Fech/Cort/Mes/Sig)
    parts = []
    for rp in s.split('_'):
        parts.extend(_CAMEL_EXPR.findall(rp) or [rp])
    expanded = []
    for p in parts:
        p_lo = p.lower()
        if len(p_lo) <= 1:
            continue
        if p_lo in _FN_PREFIX:          # prefijo de función/proc (ruido): fn, sp, usp
            continue
        if p_lo in ABBREV_EXPR and ABBREV_EXPR[p_lo]:
            expanded.append(ABBREV_EXPR[p_lo])
        else:
            vp = VOCAB.get(p_lo, {})
            if vp.get('mean') and vp['mean'] != p_lo:
                expanded.append(vp['mean'])
            elif len(p_lo) > 5:
                expanded.extend(split_sp_compound(p_lo))   # glued CamelCase (aimpcomcte→importe comisión cliente)
            elif len(p_lo) > 2:
                expanded.append(p_lo)

    if expanded:
        r = ' '.join(expanded)
        if r.lower() != var.lower():
            return r
    return var

def humanize_expr(code: str) -> str:
    """Traduce nombres de variable SPL a vocabulario de negocio en una expresión."""
    if not code or len(code) > 400:
        return code

    def _tok(m):
        v = m.group(0)
        if v.lower() in _SQL_KW or len(v) <= 2:
            return v
        h = humanize_var_expr(v)
        return h if h and h != v else v

    result = _EXPR_VAR.sub(_tok, code)
    # * → × (multiplicación) pero no *= ni **
    result = re.sub(r'(?<![*<>!])\*(?![*=])', ' × ', result)
    result = re.sub(r'\s+', ' ', result).strip()
    return result

# Abreviaciones de 3 chars SEGURAS dentro de palabras glued (no son subcadena de
# palabras españolas comunes). Las demás 3-char (res/dif/min/ine/com/ret/int...)
# rompían palabras (respaldo→'resultado paldo') y solo se usan por match exacto de token.
_SAFE3 = frozenset({'iva','isr','cat','gat','tir','van','rfc','pld',
                    'tef','atm','tdc','tdd','chq','crg','upd','bpi'})

def _abbrev_at(s: str, i: int, maxlen: int, allow3: bool = False):
    """Busca en s[i:] el match ABBREV más largo (≥4 chars, o 3 si SAFE3 / allow3)."""
    for length in range(min(maxlen, len(s) - i), 3, -1):   # ≥4 chars
        exp = ABBREV.get(s[i:i + length], '')
        if exp:
            return length, exp
    seg3 = s[i:i + 3]                                        # 3 chars: seguro, o agresivo
    if ABBREV.get(seg3) and (allow3 or seg3 in _SAFE3):
        return 3, ABBREV[seg3]
    return 0, None

# ── Descomposición greedy de tokens de SP sin guion bajo ─────────────────────
def _split_pass(s: str, allow3: bool):
    """Un pase greedy left-to-right. Retorna (fragmentos, chars_basura_no_resueltos)."""
    result = []
    garbage = 0
    i, n = 0, len(s)
    while i < n:
        if s[i].isdigit():
            j = i + 1
            while j < n and s[j].isdigit():
                j += 1
            result.append(s[i:j]); i = j; continue
        best_len, best_exp = _abbrev_at(s, i, 20, allow3)
        if best_len > 0:
            result.append(best_exp); i += best_len
        else:
            j = i + 1
            while j < n and not s[j].isdigit():
                if _abbrev_at(s, j, 15, allow3)[0]:
                    break
                j += 1
            leftover = s[i:j]
            if leftover and len(leftover) > 2:
                exp = ABBREV.get(leftover)   # re-expandir sobrante ('cta'→'cuenta')
                if exp:
                    result.append(exp)
                else:
                    result.append(leftover); garbage += len(leftover)
            else:
                garbage += len(leftover)     # sobrante corto (1-2 chars) = basura menor
            i = j
    return [r for r in result if r], garbage

def split_sp_compound(word: str) -> list:
    """Descompone un token glued en dos niveles.

    1) Conservador: abreviaciones ≥4 chars + set SAFE3 de 3-char distintivas. Si el
       sobrante domina (>40%) el token era una palabra real (respaldo→res+paldo) → entero.
    2) Agresivo (solo si el conservador no descompuso): permite TODAS las 3-char, pero
       acepta SOLO si tila casi perfecto (basura ≤1). Rescata concatenaciones puras de
       abreviaciones ('aimpcomcte'→importe+comisión+cliente) sin romper palabras reales.
    """
    s = word.lower()
    res, garb = _split_pass(s, allow3=False)
    if len(res) > 1 and garb > 0.4 * len(s):
        res = [s]
    if len(res) <= 1 and (not res or res[0] == s):
        res2, garb2 = _split_pass(s, allow3=True)
        if len(res2) > 1 and garb2 <= 1:
            return res2
    return res

def expand_sp_tokens(sp_full: str) -> list:
    """Tokeniza el nombre del SP y expande cada token vía ABBREV/greedy.
       Reutilizado por el fallback SP (paso I) y por el sujeto de VALIDACIÓN."""
    sp = sp_full.split(':')[-1] if ':' in sp_full else sp_full
    sp = re.sub(r'^(sp_|arr_|bdi_)', '', sp, flags=re.I)
    raw_words = sp.replace('_', ' ').split()
    expanded = []
    for w in raw_words[:5]:
        w_lo = w.lower()
        # Ignora fechas embebidas (28102009, 180810) — ruido de versionado legacy
        if re.match(r'^\d{6,8}$', w_lo):
            continue
        direct = ABBREV.get(w_lo, '')      # directo ANTES del strip (cope→Coppel gana sobre strip→ope)
        if not direct:
            w_lo = _strip_hungarian(w_lo)  # quita prefijo húngaro (vsdo→saldo)
            direct = ABBREV.get(w_lo, '')
        if direct:
            expanded.append(direct)
        elif len(w_lo) > 5:
            # Token glued (>5 chars) sin match directo → descomponer ('pagotdc'→'pago'+'tarjeta de crédito')
            expanded.extend(split_sp_compound(w_lo))
        elif len(w_lo) > 2:
            expanded.append(w_lo)
    return [e for e in expanded if e]

# ── 3. DT Industry Banking — patrones de fórmulas financieras ────────────────
# (pri = prioridad, mayor = más específico/relevante)
FIN_PATTERNS = [
    # Indicadores CNBV obligatorios
    (re.compile(r'\bgat\b', re.I), 'GAT (Ganancia Anual Total)', 10),
    (re.compile(r'\bcat\b', re.I), 'CAT (Costo Anual Total)', 10),
    # Base de cálculo de interés (CNBV: CUB B-5)
    (re.compile(r'/\s*365\b'), 'base 365 días', 10),
    (re.compile(r'/\s*360\b'), 'base 360 días (año comercial)', 10),
    (re.compile(r'/\s*30\b'), 'base mensual 30 días', 8),
    # Tipos de interés
    (re.compile(r'\bint_ord\b|\btasa_ord\b|\bintord\b'), 'interés ordinario', 9),
    (re.compile(r'\bint_mor\b|\btasa_mor\b|\bintmor\b'), 'interés moratorio', 9),
    # Impuestos
    (re.compile(r'\biva\b', re.I), 'IVA', 9),
    (re.compile(r'\bisr\b', re.I), 'retención ISR', 9),
    # Mora y vencido
    (re.compile(r'\bmora\b', re.I), 'cargo por mora', 9),
    (re.compile(r'\bvencid\b', re.I), 'cartera vencida', 9),
    (re.compile(r'\bdias_atr\b|\bdiasatr\b', re.I), 'días de atraso', 8),
    # Reservas CNBV
    (re.compile(r'\breserva\b|\bpreventi\b|\bprovision\b', re.I), 'reserva preventiva CNBV', 9),
    (re.compile(r'\bcalificacion\b|\bcalif\b', re.I), 'calificación de cartera CNBV', 9),
    # Pagos y amortización
    (re.compile(r'\bpago_min\b|\bpagmin\b|\bpag_min\b', re.I), 'pago mínimo', 8),
    (re.compile(r'\bamortiz\b', re.I), 'amortización', 8),
    (re.compile(r'\bcomision\b|\bcomis\b', re.I), 'comisión', 8),
    # DT Industry Banking Accounting — contabilidad
    (re.compile(r'\bpoliza\b|\bpóliza\b', re.I), 'póliza contable', 7),
    (re.compile(r'\basiento\b', re.I), 'asiento contable', 7),
    (re.compile(r'\bmayor\b', re.I), 'libro mayor', 7),
    (re.compile(r'\bcedula\b|\bcédula\b', re.I), 'cédula contable', 7),
    # Riesgo / PLD
    (re.compile(r'\bpld\b', re.I), 'PLD (prevención lavado)', 7),
    (re.compile(r'\bfatca\b', re.I), 'FATCA', 7),
    (re.compile(r'\bburo\b|\bburó\b', re.I), 'buró de crédito', 7),
    (re.compile(r'\bscoring\b', re.I), 'score crediticio', 7),
    # Operaciones de conjunto SQL
    (re.compile(r'\bselect\s+count\b|\bcount\s*\(\s*\*', re.I), 'conteo de registros', 6),
    (re.compile(r'\bsum\s*\(', re.I), 'suma acumulada', 5),
    # Tipo de cambio / FX
    (re.compile(r'\btipo_?cambio\b|\btipocambio\b|\btc_cambio\b|\bval_?cambio\b', re.I), 'tipo de cambio', 8),
    (re.compile(r'\b(monto|saldo)_?usd\b|\busd_[a-z]', re.I), 'monto en dólares', 7),
    # Saldo promedio (CUB B-5)
    (re.compile(r'\bsaldo_?prom(edio)?\b|\bsdoprom\b|\bsdo_prom\b', re.I), 'saldo promedio', 8),
    # Umbral regulatorio PLD/FATCA
    (re.compile(r'>=\s*10[,.]?000\b'), 'umbral USD 10,000 (PLD/FATCA)', 9),
    # Tasa de interés de referencia (TIIE, CETES, etc.)
    (re.compile(r'\btasa_?int\b|\btasaint\b|\btasa_?ref\b|\btiie\b', re.I), 'tasa de interés de referencia', 8),
    # Saldo de crédito
    (re.compile(r'\bsaldo_?capital\b|\bsdocap\b|\bsdo_?capital\b', re.I), 'saldo capital', 8),
]

# DT DBA IBM Informix — semántica de funciones Informix
INFORMIX_FUNCS = {
    re.compile(r'\bround\s*\(', re.I):   'con redondeo',
    re.compile(r'\btrunc\s*\(', re.I):   'con truncamiento',
    re.compile(r'\bmoney\s*\(', re.I):   'tipo MONEY',
    re.compile(r'\bmod\s*\(', re.I):     'módulo',
    re.compile(r'\babs\s*\(', re.I):     'valor absoluto',
    re.compile(r'\btoday\b', re.I):      'fecha del sistema',
    re.compile(r'\bextend\s*\(', re.I):  'conversión de fecha',
    re.compile(r'\bnvl\s*\(', re.I):     'nulo por defecto',
    re.compile(r'\bsubstr\s*\(', re.I):  'subcadena',
    re.compile(r'\bto_char\s*\(', re.I):    'formato de texto',
    re.compile(r'\bto_date\s*\(', re.I):    'conversión a fecha',
    re.compile(r'\biif\s*\(|\bdecode\s*\(', re.I): 'evaluación condicional',
}

# ── 4. Regex de extracción de código ─────────────────────────────────────────
RE_LET   = re.compile(r'\blet\s+([a-z_][a-z0-9_]*)\s*=\s*(.{1,200})', re.I)
RE_SET   = re.compile(r'\bset\s+([a-z_][a-z0-9_]*)\s*=\s*(.{1,200})', re.I)
RE_RAISE = re.compile(r'\braise\s+exception\b', re.I)
RE_CODRET = re.compile(
    r'(?:codret|v_codret|pcod_ret|cod_ret|cCodRet)\s*=\s*[\'"]([A-Z0-9]{3,})[\'"]|'
    r'\breturn\s+[\'"]?([0-9]{3,8})[\'"]?',
    re.I
)
RE_IF_COND = re.compile(r'\bif\s+(.{5,80}?)\s+then\b', re.I)
# Asignaciones de comandos shell/SQL embebidos (sin let/set keyword).
# El patrón captura CUALQUIER variable cuyo nombre termine en 'sql' (vsql, csql,
# vsSQL, vs_sql...), o de la familia cadena/ejecuta/cmd/comando/sentencia, cuyo
# RHS es una cadena — típico de scripts batch que construyen sed/dbaccess/unload.
RE_SHELL  = re.compile(
    r'(?:[a-z_]*sql\d*|[a-z_]*shell|[a-z_]*stmt\d*|ejecuta\w*|c?cadena\d*|ccad|ccons\d*|cmd\w*|comando|sentencia)'
    r'\s*=\s*[\'"](.{5,300})',
    re.I
)
# Asignación aritmética/lógica DESNUDA (sin let/set): 'sVar = expr'
# Anclada al inicio del código para no capturar comparaciones dentro de IF/WHERE.
# Guarda [^=<>!] tras '=' para excluir ==, >=, <=, !=, <>.
RE_BARE = re.compile(r'^\s*([a-z_][a-z0-9_]{2,})\s*=\s*([^=<>!].{1,200})', re.I)

TIPO_VERB = {
    'FÓRMULA':    'Cálculo de',
    'VALIDACIÓN': 'Validación de',
    'UMBRAL':     'Límite de',
    'ESTADO':     'Estado de',
}

# ── 5. Detección de comentario útil ──────────────────────────────────────────
_GARB  = re.compile(r'\|---|">|</|https?://|\*{5,}', re.I)
_CODE_F = re.compile(
    r'\b(round|trunc|pow|nvl|isnull|substr|mod|abs|'
    r'ltrim|rtrim|trim|upper|lower|initcap|lpad|rpad|decode|'
    r'coalesce|ifnull)\s*\(',
    re.I
)

_PIPELINE_TAG = re.compile(
    r'^(fórmula:|formula:|cálculo con|calculo con|concentrada$|'
    r'n/a$|na$|null$|ninguna$|sin comentario|ipcb\s|temporal_|'
    r'ppf_|arr_|bdi_|sp_\w|spl\s|'
    # Comandos Unix shell
    r'rm\s|cp\s|mv\s|chmod\s|mkdir|grep\s|awk\s|sed\s|echo\s|cat\s|ls\s|gzip\s|'
    # SQL Informix embebido en variables (operaciones batch)
    r'unload\s+to\s|load\s+from\s|set\s+isolation\s|dbaccess\s|dbload\s|dbexport\s|'
    # Rutas Unix absolutas
    r'/[a-z]+/|'
    # Rechazar "Cálculo/Proceso/Validación de [token_único_técnico]" sin espacio en el token
    r'(cálculo|calculo|proceso|validación|validacion|proceso\sde)\s+de\s+[a-z][a-z0-9]{3,}$)',
    re.I
)

def classify_shell_cmd(cmd_str: str) -> str:
    """Clasifica una operación shell/SQL embebida en un nombre de negocio semántico."""
    s = cmd_str.upper().strip()
    if re.search(r'\bUNLOAD\s+TO\b', s):          return 'Descarga de datos'
    if re.search(r'\bLOAD\s+FROM\b', s):           return 'Carga de datos'
    if re.search(r'\bINSERT\s+INTO\b', s):         return 'Inserción de datos'
    if re.search(r'\bDELETE\s+FROM\b', s):         return 'Eliminación de registros'
    if re.search(r'\bUPDATE\b.*\bSET\b', s, re.S): return 'Actualización de datos'
    if re.search(r'\bSELECT\s+COUNT\b', s):        return 'Conteo de registros'
    if re.search(r'\bSELECT\b', s):                return 'Consulta de datos'
    if re.search(r'\bDBACCESS\b|\bDBLOAD\b|\bDBEXPORT\b', s): return 'Ejecución de script SQL'
    if re.search(r'\bRM\b|\bDEL\b', s):            return 'Eliminación de archivo'
    if re.search(r'\bGZIP\b|\bZIP\b|\bTAR\b', s): return 'Compresión de archivo'
    if re.search(r'\bCHMOD\b|\bCHOWN\b', s):      return 'Configuración de permisos'
    if re.search(r"\bSED\b|\bAWK\b|\bGREP\b", s): return 'Transformación de datos'
    if re.search(r'\bECHO\b', s):                  return 'Escritura de log'
    if re.search(r'\bEJECUTA\w*\b|\.SH\b|\.KSH\b|/BIN/', s): return 'Ejecución de proceso externo'
    return 'Proceso operacional'

def clean_comment(text: str) -> str:
    """Devuelve comentario del dev limpio, o '' si parece código o tag de pipeline."""
    if not text: return ''
    if _GARB.search(text): return ''
    if text.startswith("'"): return ''
    if text.startswith('(') and '_' in text: return ''
    if _CODE_F.search(text): return ''
    # Strip marcadores de comentario más amplio (SPL usa #, > y otros prefijos)
    text = re.sub(r'^([#@>]\s*|//\s*|-\*\s*|--?\s*|\*{1,4}\s*)', '', text).strip()
    text = re.sub(r'\s*\*+\s*$', '', text).strip()
    # Strip colon trailing (labels/headers, no descripciones)
    text = text.rstrip(':').strip()
    if not text: return ''
    # Rechaza metadatos de desarrollo: autoría, versión, fechas de cambio
    if re.match(r'^(autor|autores?|modifico|modificó|modificado|fecha|version|versión|rev\.?|revision|creado|actualiz|cambio|change|por:)\s*[:\-]?', text, re.I):
        return ''
    # Rechaza patrones "nombre apellido DD/MM/YYYY" o "nombre(inicio) fecha" — bitácoras SPL
    if re.search(r'\b\d{1,2}/\d{1,2}/\d{4}\b', text):
        return ''
    if re.search(r'\b\d{4}-\d{2}-\d{2}\b', text) and len(text) < 60:
        return ''
    # Rechaza marcadores de versión inline en SPL: (inicio), (fin), (modificacion)
    if re.search(r'\((inicio|fin|inicio\s+\d|fin\s+\d|modificacion|modificación|mod\.?|corrección|correccion)\)', text, re.I):
        return ''
    # Rechaza asignaciones de variables: v_nombre = ... o #var = ...
    if re.match(r'^[a-z_][a-z0-9_]+\s*=', text, re.I):
        return ''
    # Rechaza fragmentos de cláusula SQL y sentencias DML
    if re.match(r'^(and|or|where|join|on|from|not)\s+[a-z_(]', text, re.I):
        return ''
    if re.match(r'^(select|insert|update|delete|merge|create|drop|alter|execute|exec)\b', text, re.I):
        return ''
    # Rechaza expresión incompleta que termina con = o , (fragmento de condición)
    if re.search(r'[=,]\s*$', text):
        return ''
    # Rechaza listas de parámetros técnicos (≥3 comas → lista de campos API/SQL)
    if text.count(',') >= 3:
        return ''
    # Rechaza texto que describe un cambio en código ("se modifico la longitud", "se corrigió el campo")
    if re.search(r'\bse\s+(modifico|modificó|corrigió|corrijo|cambió|cambio|eliminó|elimino|agregó|agrego)\b', text, re.I):
        return ''
    # Rechaza nombres de archivos (.sql, .txt, .log, .sh, .py, .cfg, .unl, etc.)
    if re.search(r'\.(sql|txt|log|sh|py|cfg|xml|json|csv|xls|bak|unl|dat|ctl)$', text, re.I):
        return ''
    # Rechaza fragmentos que EMPIEZAN con un nombre de archivo (aunque tengan cola: "batch.unl >")
    if re.match(r'^\S+\.(sql|txt|log|sh|py|cfg|xml|json|csv|xls|bak|unl|dat|ctl)\b', text, re.I):
        return ''
    # Rechaza patrones sed/regex embebidos ("s/||/| |/g", "S/\\//g")
    if re.match(r'^s/.*/.*/[a-z]*\s*$', text, re.I):
        return ''
    # Rechaza fragmentos con redirección shell colgante (terminan en > o <)
    if re.search(r'[<>]\s*$', text):
        return ''
    # Rechaza rutas de archivo absolutas o relativas
    if re.match(r'^(file\s+)?[/\\]', text, re.I) or re.match(r'^file\s+\S+\.(unl|sql|dat|txt)', text, re.I):
        return ''
    # Rechaza tags estructurales del pipeline o referencias a SP/archivos internos
    if _PIPELINE_TAG.match(text): return ''
    # Rechaza plantillas auto-generadas de vocabulario: "Calcula X (verbo — Y)" o "X sobre X (verbo"
    if re.search(r'\(verbo\s*[—\-]|\(sustantivo\s*[—\-]|\(término\s*[—\-]', text, re.I): return ''
    # Rechaza si >50% de caracteres son no-alfabéticos (variable name)
    alpha = sum(c.isalpha() for c in text)
    if alpha < len(text) * 0.45: return ''
    # Rechaza si es una sola palabra técnica corta (sin espacio, no es español útil)
    if ' ' not in text and len(text) < 12 and not any(c in text for c in 'áéíóúñü'):
        return ''
    if len(text) > 65:
        text = text[:65].rsplit(' ', 1)[0] + '…'
    return text[0].upper() + text[1:]

def is_descriptive(text: str) -> bool:
    """True si el texto parece una descripción en español (no código)."""
    if not text or len(text) < 6: return False
    words = text.split()
    alpha_words = sum(1 for w in words if re.match(r'^[a-záéíóúñA-ZÁÉÍÓÚÑ]+$', w))
    return alpha_words / max(len(words), 1) >= 0.55

# ── 6. Función principal de inferencia ───────────────────────────────────────
def infer_name(rule: dict) -> str:
    tipo     = rule.get('tipo', '') or ''
    code     = (rule.get('code', '') or '').strip()
    vrefs    = rule.get('vocab_refs', []) or []
    expl     = rule.get('explicacion', '') or ''
    sp_full  = rule.get('sp', '') or ''
    bc_name  = rule.get('bc_name', '') or ''    # best BC from extraction

    code_lo  = code.lower()

    # ─ A. Extrae LHS de asignación LET/SET o DESNUDA ────────────────────────
    lhs_var = rhs_expr = ''
    _bare = False
    m = RE_LET.search(code) or RE_SET.search(code)
    if m:
        lhs_var  = m.group(1).strip()
        rhs_expr = m.group(2).strip().lower()
    else:
        mb = RE_BARE.match(code)
        if mb:
            lhs_var  = mb.group(1).strip()
            rhs_expr = mb.group(2).strip().lower()
            _bare = True

    # LHS de asignación desnuda suele ser CamelCase (mMontoChequeUsd) → humanizador de expresión
    lhs_mean = (humanize_var_expr(lhs_var) if _bare else humanize_var(lhs_var)) if lhs_var else ''
    # Descartar si lhs_mean resuelve a token técnico sin valor semántico
    _TECH_TOKENS = {'sql', 'csql', 'tmp', 'temp', 'aux', 'flag', 'var', 'val',
                    'buf', 'buff', 'str', 'num', '', 'i', 'j', 'k', 'x', 'y',
                    'stmt', 'cmd', 'msg'}
    # Rechaza definición-frase de VOCAB (';'/'sp_') o token técnico. Antes se rechazaba
    # también len>35, pero eso mataba significados buenos con paréntesis aclaratorio
    # ("saldo retenido (fondos en retención)"). Ahora: strip del paréntesis y umbral alto.
    if '(' in lhs_mean and len(lhs_mean) > 40:
        lhs_mean = lhs_mean.split('(')[0].strip()   # "saldo retenido (…)" → "saldo retenido"
    if (lhs_mean.lower() in _TECH_TOKENS or lhs_mean.lower() == lhs_var.lower()
            or ';' in lhs_mean or 'sp_' in lhs_mean.lower() or len(lhs_mean) > 55):
        # definición-frase de VOCAB o token técnico → no sirve como nombre
        lhs_mean = ''

    # ─ B. Detecta patrones financieros y contables en código ────────────────
    target = rhs_expr or code_lo
    fin_tags = []
    for pat, label, pri in sorted(FIN_PATTERNS, key=lambda x: -x[2]):
        if pat.search(target):
            fin_tags.append((pri, label))
    top_fins = [lbl for _, lbl in sorted(set(fin_tags), reverse=True)[:2]]

    func_tags = [lbl for pat, lbl in INFORMIX_FUNCS.items() if pat.search(code_lo)]

    # ─ B.5 Detecta operación shell/batch embebida ────────────────────────────
    _shell_op = ''
    _sh_m = RE_SHELL.search(code)
    if _sh_m:
        _shell_op = classify_shell_cmd(_sh_m.group(1))

    # ─ C. Término primario del vocabulario ──────────────────────────────────
    pri_term = pri_mean = ''
    # Primera pasada: términos con BC real (no Transversal)
    for t in vrefs:
        v   = VOCAB.get(t, {})
        bc  = v.get('bc_name', '') or ''
        cat = v.get('cat', '') or ''
        mn  = v.get('mean', '') or ''
        if bc in ('Transversal', '') or cat == 'PREFIJO':
            continue
        if mn and mn != t:
            pri_term, pri_mean = t, mn
            break
    # Segunda pasada: cualquier término con significado (incluye Transversal)
    if not pri_mean:
        for t in vrefs:
            v   = VOCAB.get(t, {})
            cat = v.get('cat', '') or ''
            mn  = v.get('mean', '') or ''
            if cat == 'PREFIJO': continue
            if mn and mn != t and len(mn) > 3:
                pri_term, pri_mean = t, mn
                break

    # ─ D. Código de error para VALIDACIÓN (excluir success codes) ──────────────
    err_code = ''
    em = RE_CODRET.search(code)
    if em:
        raw_code = (em.group(1) or em.group(2) or '').strip()
        # Excluir códigos de éxito/OK (0, 00, 000..., vacío)
        if raw_code and not re.match(r'^0+$', raw_code):
            err_code = raw_code

    # ─ E. Condición IF para VALIDACIÓN sin error code ───────────────────────
    if_cond = ''
    ic = RE_IF_COND.search(code)
    if ic:
        raw = ic.group(1).strip().lower()
        # Mapear variables a significado
        toks = re.findall(r'[a-z_][a-z0-9_]*', raw)
        cond_parts = []
        for tok in toks[:4]:
            if tok in ('null','is','not','and','or','then','if'): continue
            mn = humanize_var(tok)
            if mn and mn != tok and len(mn) > 2:
                cond_parts.append(mn)
        if_cond = ' · '.join(dict.fromkeys(cond_parts))  # dedup ordered

    # ─ F. Construye nombre por tipo ─────────────────────────────────────────
    name = ''
    src  = ''  # INSTRUMENTACIÓN: fuente real del nombre
    _name_from_vocab_only = False  # True si el nombre viene SOLO de pri_mean sin señal de código

    if tipo == 'FÓRMULA':
        if _shell_op:
            # Operación shell/batch: el verbo de negocio viene del comando, el sujeto del vocab
            if pri_mean:
                name = f"{_shell_op} — {pri_mean}"; src = 'F-shell+vocab'
            # else: name queda vacío → step I añadirá contexto del SP
        elif lhs_mean:
            name = f"Cálculo de {lhs_mean}"; src = 'F-lhs'
            if top_fins:
                name += f" — {top_fins[0]}"
                if len(top_fins) > 1:
                    name += f", {top_fins[1]}"
        elif top_fins:
            name = top_fins[0]; src = 'F-fin'
            if pri_mean:
                name += f" de {pri_mean}"
        elif pri_mean:
            name = f"Cálculo de {pri_mean}"; src = 'F-vocab'
            _name_from_vocab_only = True  # solo vocab, sin señal de código
        # Append Informix function detail
        if name and func_tags and func_tags[0] not in name:
            name += f" ({func_tags[0]})"
            if src == 'F-vocab': src = 'F-vocab+func'
            _name_from_vocab_only = False  # hay señal de código (función Informix)

    elif tipo == 'VALIDACIÓN':
        # Sujeto derivado del nombre del SP para dar contexto cuando no hay vocab
        _v_subj = ' '.join(expand_sp_tokens(sp_full)[:4])
        if pri_mean and err_code:
            name = f"Validación de {pri_mean} — error {err_code}"; src = 'V-vocab+err'
        elif pri_mean:
            name = f"Validación de {pri_mean}"; src = 'V-vocab'
            if if_cond:
                name += f": {if_cond}"
        elif err_code:
            if _v_subj:
                name = f"Validación de {_v_subj} — error {err_code}"; src = 'V-sp+err'
            else:
                name = f"Validación: código de error {err_code}"; src = 'V-err'
        elif RE_RAISE.search(code):
            if _v_subj:
                name = f"Validación de {_v_subj} — excepción de negocio"; src = 'V-sp+raise'
            else:
                name = f"Validación: excepción de negocio"; src = 'V-raise'
                if if_cond:
                    name += f" — {if_cond}"
        elif if_cond:
            name = f"Validación: {if_cond}"; src = 'V-cond'
        elif re.search(r'\breturn\s+["\']0+["\']', code, re.I):
            name = f"Retorno exitoso — {_v_subj}" if _v_subj else "Retorno exitoso"; src = 'V-exit'

    elif tipo == 'UMBRAL':
        if lhs_mean:
            name = f"Límite de {lhs_mean}"; src = 'U-lhs'
            if top_fins:
                name += f" — {top_fins[0]}"
        elif top_fins:
            # Patrón financiero en la condición (umbral USD 10k PLD/FATCA, base 360…)
            name = top_fins[0]; src = 'U-fin'
            if pri_mean:
                name += f" — {pri_mean}"
            elif if_cond:
                name += f": {if_cond}"
        elif pri_mean:
            name = f"Límite de {pri_mean}"; src = 'U-vocab'
        elif if_cond:
            name = f"Umbral: {if_cond}"; src = 'U-cond'

    elif tipo == 'ESTADO':
        if pri_mean:
            name = f"Estado de {pri_mean}"; src = 'E-vocab'
            if if_cond:
                name += f": {if_cond}"
        elif lhs_mean:
            name = f"Estado de {lhs_mean}"; src = 'E-lhs'

    # ─ G. Descripción regulatoria — solo para fórmulas financieras reales ──────
    # Si el código es un comando shell/SQL (vsql='echo...', cCadena='dbload...'),
    # la descripción reg es la misma para TODOS los SPs del mismo dominio → no usar.
    # Solo usar reg_desc cuando el código es una fórmula aritmética/lógica real.
    reg_list = rule.get('reg') or []
    reg_desc = ''
    for entry in reg_list:
        if isinstance(entry, (list, tuple)) and len(entry) >= 2:
            d = str(entry[1]).strip()
            if len(d) > 20 and (' ' in d) and ('—' in d or '→' in d or len(d) > 40):
                reg_desc = d
                break

    if reg_desc and not name:
        # Detectar si el código es una asignación a variable de comando shell/SQL
        _is_shell = bool(
            re.search(r'\b(vsql|csql|cSQL|cCadena|cCad)\s*=', code, re.I) or
            (rhs_expr and re.match(r'[\'"]', rhs_expr.strip()))
        )
        if not _is_shell:
            name = reg_desc; src = 'G-reg'

    # ─ H. Comentario del dev como guía secundaria ────────────────────────────
    comment = clean_comment(expl)

    if not name and comment:
        # Sin inferencia: usar comentario
        name = comment; src = 'H-comment'
    elif name and comment and is_descriptive(comment):
        # Inferencia débil (solo tipo + verb, sin semántica real) → preferir comentario
        if len(name) < 20 and len(comment) > len(name):
            detail = ''
            if top_fins:
                detail = f" — {top_fins[0]}"
            name = comment + detail; src = 'H-comment-override'

    # ─ I. Fallback: derivar del SP ───────────────────────────────────────────

    # ─ [SP fallback — continuación de I] ────────────────────────────────────
    # También corre cuando el nombre es solo vocab genérico (sin señal de código)
    # o cuando hay una operación shell/batch que aporta verbo más específico
    if not name or _name_from_vocab_only or _shell_op:
        expanded = expand_sp_tokens(sp_full)

        # Detectar verbo de acción en el primer componente expandido
        _SP_VERBS = {
            'envio','enviar','genera','generar','consulta','busca','procesa',
            'carga','descarga','actua','actualiza','elimina','borra','guarda',
            'inserta','modifica','valida','verifica','calcula','obtiene',
            'registra','emite','cancela','reversa','liquida','cierra','abre',
            'reporte', 'cálculo',
        }
        first_exp = expanded[0] if expanded else ''
        if _shell_op:
            # Operación shell/batch: usar la operación como verbo + tokens SP como sujeto
            subject = ' '.join(expanded[:4]) if expanded else ''
            sp_name = f"{_shell_op} — {subject}" if subject else _shell_op
        elif first_exp.lower() in _SP_VERBS and len(expanded) > 1:
            rest = ' '.join(expanded[1:])
            sp_name = f"{first_exp.capitalize()} de {rest}"
        else:
            verb = TIPO_VERB.get(tipo, 'Proceso de')
            sp_name = f"{verb} {' '.join(expanded)}"

        # Override vocab-only name SOLO si el SP aporta un verbo de acción específico
        if not name or first_exp.lower() in _SP_VERBS or _shell_op:
            _prev = src
            name = sp_name
            if _shell_op:
                src = 'I-shell-sp'
            elif _prev in ('', 'F-vocab', 'F-vocab+func'):
                src = 'I-sp' if first_exp.lower() not in _SP_VERBS else 'I-sp-verb'
            else:
                src = 'I-sp-override'

    # ─ J. Capitalizar y truncar ──────────────────────────────────────────────
    name = name.strip()
    # Colapsar palabras repetidas consecutivas ("interés interés" → "interés")
    name = re.sub(r'\b(\w+)(\s+\1\b)+', r'\1', name, flags=re.I | re.U)
    if name:
        name = name[0].upper() + name[1:]
    # Descripciones regulatorias (contienen — o →) permiten hasta 90 chars
    limit = 90 if ('—' in name or '→' in name) else 75
    if len(name) > limit:
        cut = name[:limit].rsplit(' ', 1)[0]
        name = cut + '…'

    if not src: src = 'NONE'
    return name, src

def money_risk(rule) -> str:
    """Señal de tipo declarado (variable-types.json): si el LHS calculado es MONEY y
       hay aritmética (* o /), la migración Informix MONEY→target arriesga redondeo."""
    key = f"{rule.get('db','') or ''}_{rule.get('sp','') or ''}".lower()
    vmap = VARTYPES.get(key)
    if not vmap:
        return ''
    code = (rule.get('code') or '').strip()
    mm = RE_LET.search(code) or RE_SET.search(code) or RE_BARE.match(code)
    if not mm:
        return ''
    if vmap.get(mm.group(1).lower()) == 'MONEY' and re.search(r'[*/]', code):
        return 'MONEY — importe monetario; validar redondeo/truncamiento en migración'
    return ''

def business_explanation(rule, human_expr: str) -> str:
    """Explicación de negocio en una línea. Cascada: comentario dev limpio →
       descripción regulatoria → sintetizado (human_expr + señal de tipo)."""
    # 1. Comentario del dev limpio (la intención de quien lo escribió) — la mejor fuente
    c = clean_comment(rule.get('explicacion', '') or '')
    if c and len(c) >= 10 and ' ' in c:
        return c
    # 2. Descripción regulatoria embebida
    for entry in (rule.get('reg') or []):
        if isinstance(entry, (list, tuple)) and len(entry) >= 2:
            dsc = str(entry[1]).strip()
            if len(dsc) > 20 and ' ' in dsc:
                return dsc
    # 3. Sintetizado
    tipo  = rule.get('tipo', '') or ''
    he    = (human_expr or '').strip()
    money = any('MONEY' in x for x in (rule.get('riesgo') or []))
    if tipo == 'FÓRMULA':
        if 3 < len(he) <= 65 and any(op in he for op in ('×', '/', '+', '-', '%')):
            return f"Calcula {he}" + (' — importe monetario' if money else '')
        return 'Cálculo de un importe monetario del crédito/cuenta.' if money else 'Cálculo derivado de la lógica del procedimiento.'
    if tipo == 'VALIDACIÓN':
        return 'Validación que condiciona el flujo: si no se cumple, corta la operación.'
    if tipo == 'UMBRAL':
        return 'Umbral/límite que restringe la operación (compara contra una cota).'
    if tipo == 'ESTADO':
        return 'Determina o transiciona el estado de un objeto de negocio.'
    return ''

# ── 7. Main ───────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    from collections import Counter
    data  = json.load(open(BASE + "portal/data/business-rules-v3.json", encoding="utf-8"))
    rules = data["rules"]
    N = len(rules)

    # Fuentes que representan fallback a tokenización del nombre del SP (sin señal semántica)
    FALLBACK_SRCS = {'I-sp', 'I-sp-verb', 'I-sp-override', 'NONE'}
    src_counter = Counter()

    n_money = 0
    for r in rules:
        name, src = infer_name(r)
        r['business_name'] = name
        r['src'] = src
        src_counter[src] += 1
        # Humanizar expresión SPL con vocabulario de negocio
        code = (r.get('code', '') or '').strip()
        r['human_expr'] = humanize_expr(code) if code else ''
        # Señal MONEY (tipo declarado) → riesgo de equivalencia por redondeo
        mr = money_risk(r)
        if mr:
            rg = r.get('riesgo') or []
            if mr not in rg:
                rg.append(mr)
            r['riesgo'] = rg
            n_money += 1
        # Explicación de negocio (cascada comentario→regulatorio→sintetizado)
        r['expl_negocio'] = business_explanation(r, r['human_expr'])

    real = sum(c for s, c in src_counter.items() if s not in FALLBACK_SRCS)
    fb   = N - real

    json.dump(data, open(BASE + "portal/data/business-rules-v3.json", "w", encoding="utf-8"),
              ensure_ascii=False, separators=(",", ":"))

    print(f"Reglas procesadas: {N:,}\n")
    print("── Fuente del nombre (métrica real por rama de inferencia) ──")
    for s, c in src_counter.most_common():
        flag = '  ← fallback SP' if s in FALLBACK_SRCS else ''
        print(f"  {s:20} {c:6,}  {c/N*100:5.1f}%{flag}")
    print()
    print(f"  Nombre semántico real : {real:6,}  ({real/N*100:.1f}%)")
    print(f"  Fallback tokeniza SP  : {fb:6,}  ({fb/N*100:.1f}%)")
    print(f"  Riesgo MONEY (tipo DEFINE): {n_money:,}  reglas monetarias marcadas para revisión de redondeo")
    print()
    print(f"Saved: {BASE}portal/data/business-rules-v3.json")
