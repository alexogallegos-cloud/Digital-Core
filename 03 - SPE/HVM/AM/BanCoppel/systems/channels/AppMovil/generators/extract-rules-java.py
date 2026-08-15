#!/usr/bin/env python3
"""
extract-rules-java.py — Extractor de reglas de negocio · AppMovil Canal Móvil
BanCoppel Application Modernization · SPE-AM-001

Metodología: espejo de extract-rules-v2.py (Informix SPL) adaptado a Java/Spring Boot.
  - Toda regla ancla en código fuente real (repo + clase + línea)
  - El vocabulario del brain.db amplifica la detección de términos financieros
  - Clasificación regulatoria por patrones de keyword
  - Carga en brain.db::rules con el mismo schema que Informix
  - Catálogo generado DESDE brain.db (--catalog), nunca a mano

Tipos de regla extraídos:
  VALIDACIÓN   — guard clauses: throw / if…throw en clases de negocio
  UMBRAL       — @Min/@Max/@DecimalMin/@DecimalMax/@Size en DTOs con campo financiero
  ANOTACIÓN    — @NotNull/@NotBlank/@NotEmpty en campos de dominio financiero
  CONFIGURACIÓN— valores operativos clave en application*.properties
  CÓDIGO_ERROR — mapeo excepción → código de error en properties/ErrorResolver

ID canónico: BR-AM-{msa_abbr}-{line}
  msa_abbr   : slug funcional del MSA (análogo a sp_short en Informix)
               ej. codi-tra (msach-b-business-codi-transactions)
                   codi-pay (msapy-d-domain-codi-payment)
                   sess-man (msacm-p-security-session-management)
  line       : número de línea en el archivo fuente

Uso:
  python extract-rules-java.py [--source <ruta>] [--db <ruta>] [--catalog] [--verbose]
"""

import sqlite3
import os
import re
import sys
import json
import argparse
from pathlib import Path
from datetime import datetime, timezone

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).parent
SOURCE_DIR = SCRIPT_DIR.parent / "source" / "code"
DB_PATH    = SCRIPT_DIR.parent / "digital-brain" / "brain.db"
VERSION    = "1.0.0"
TS_NOW     = datetime.now(timezone.utc).isoformat()

# ── Mapas de dominio (espejo de build-brain.py) ──────────────────────────────

DOMAIN_MAP = {
    "ch": "Canal / Channel Infrastructure",
    "cm": "Customer Management",
    "cr": "Credit",
    "dp": "Deposit & Transfer",
    "im": "Infrastructure Messaging",
    "lo": "Lending / Loans",
    "mg": "Messaging",
    "py": "Payments",
    "sr": "Services / ATM",
    "xd": "Cross-domain",
}

def domain_from_repo(repo_name: str) -> str:
    """Extrae el prefijo de dominio del nombre del repo (msach- → ch)."""
    m = re.match(r"msa([a-z]{2})-", repo_name)
    return m.group(1) if m else "xd"

def msa_abbr(repo_name: str) -> str:
    """
    Slug funcional del MSA — análogo a {sp_short} en el ID de Informix.
    msach-b-business-codi-transactions     → codi-tra
    msapy-d-domain-codi-payment            → codi-pay
    msacm-p-security-session-management   → sess-man
    msach-d-business-frequent-accounts     → freq-acc
    msach-d-business-credit-accounts-movements → cred-mov
    """
    clean = re.sub(r"^msa[a-z]{2}-[a-z]-", "", repo_name)
    clean = re.sub(
        r"^(business|domain|service|platform|security|orchestration|serv|"
        r"utility|middleware|integration|b|d|p|o|s|m|u|i)-", "", clean
    )
    parts = clean.split("-")
    if len(parts) == 1:
        return parts[0][:8]
    elif len(parts) == 2:
        return f"{parts[0][:4]}-{parts[1][:3]}"
    else:
        return f"{parts[0][:4]}-{parts[-1][:3]}"

# ── Términos financieros base (análogo a FIN_PAT en Informix) ────────────────

FIN_BASE = (
    r"amount|ammount|monto|saldo|importe|comision|interes|tasa|cuota|capital|"
    r"cargos?|abono|credito|debito|transferencia|pago|prestamo|inversion|"
    r"rendimiento|mora|balance|fondos|cuenta|limite|spei|codi|iva|isr|"
    r"beneficiario|clabe|cuenta|tarjeta|pin|cvv|nip|contrato"
)
FIN_PAT_BASE = re.compile(FIN_BASE, re.I)

def build_fin_pat(vocab_terms: list) -> re.Pattern:
    """Amplifica FIN_PAT con términos financieros del vocabulario (≥4 chars, ALTA/MEDIA)."""
    extra = [
        re.escape(t.lower())
        for t in vocab_terms
        if len(t) >= 4 and not re.search(r"[.*/+\-]", t)
    ]
    combined = FIN_BASE + ("|" + "|".join(extra) if extra else "")
    return re.compile(combined, re.I)

# ── Clasificación regulatoria ─────────────────────────────────────────────────

REG_PATTERNS = [
    (re.compile(r"\bspei\b|\bsiac\b|\bclabe\b|\bsp_regordenctecte\b", re.I),
     "Banxico SPEI", "Circular 14/2017 Banxico SPEI"),
    (re.compile(r"\bcodi\b|\bqr\b.*pago|\bpago\b.*\bqr\b", re.I),
     "Banxico CoDi", "Circular 14/2017 Banxico CoDi"),
    (re.compile(r"\bpci[\s_-]?dss\b|\bcryptograph|\bcvv\b|\bnip\b|\bpin\b", re.I),
     "PCI-DSS", "PCI-DSS v4.0 Datos de tarjeta"),
    (re.compile(r"\bcnbv\b|\bbanca\s+electr[oó]nica\b|\bcanal\s+(bex|wallet)\b", re.I),
     "CNBV Banca Electrónica", "Circular 14/2003 CNBV Banca Electrónica"),
    (re.compile(r"\bmtu\b|\bl[ií]mite\s+transacci[oó]n\b|\bmonto\s+m[áa]ximo\b", re.I),
     "Banxico MTU", "Banxico Límite MTU CoDi"),
    (re.compile(r"\bconductsaf\b|\bconducts[ae]\b|\bcondusef\b", re.I),
     "CONDUSEF", "Ley de Protección y Defensa al Usuario CONDUSEF"),
]

def clasificar_reg(text: str) -> str:
    """Devuelve 'Regulador — Norma' o '' si no aplica."""
    results = []
    for pat, reg, norma in REG_PATTERNS:
        if pat.search(text):
            results.append(f"{reg} — {norma}")
    return "; ".join(results)

# ── Riesgos de equivalencia ───────────────────────────────────────────────────

def detect_riesgo(text: str) -> str:
    """Detecta riesgos de equivalencia al migrar del canal."""
    risks = []
    if re.search(r"\bBigDecimal\b", text):
        risks.append("BigDecimal→double conversión: riesgo de redondeo financiero")
    if re.search(r"hystrix.*timeout|timeoutInMilliseconds|connection.timeout", text, re.I):
        risks.append("Timeout: valor hardcoded en properties; target debe respetar mismo valor")
    if re.search(r"\bcargo_ref\b|\babono_ref\b", text, re.I):
        risks.append("SP crítico cargo_ref/abono_ref: semántica contable; requiere equivalencia funcional")
    return "; ".join(risks) if risks else ""

# ── Clase/naturaleza de la regla ─────────────────────────────────────────────

def asigna_clase(tipo: str, context: str) -> str:
    if tipo in ("VALIDACIÓN", "UMBRAL", "ANOTACIÓN"):
        if re.search(FIN_BASE, context, re.I):
            return "NEGOCIO"
        return "INFRAESTRUCTURA"
    if tipo == "CONFIGURACIÓN":
        return "NEGOCIO" if re.search(FIN_BASE, context, re.I) else "INFRAESTRUCTURA"
    if tipo == "CÓDIGO_ERROR":
        return "NEGOCIO"
    return "INFRAESTRUCTURA"

# ── Vocabulario para síntesis funcional ──────────────────────────────────────

# Fragmentos de field names camelCase → término en español de negocio
# Se aplica palabra por palabra tras dividir camelCase
_FIELD_TERMS: dict = {
    # Montos y valores financieros
    "amount": "monto", "ammount": "monto",
    "balance": "saldo", "saldo": "saldo",
    "importe": "importe", "capital": "capital",
    "cuota": "cuota", "comision": "comisión",
    "tasa": "tasa", "interes": "interés",
    "mora": "mora", "rendimiento": "rendimiento",
    "deuda": "deuda", "cargo": "cargo",
    # Cuentas
    "account": "cuenta", "accounts": "cuentas",
    "cuenta": "cuenta", "cuentas": "cuentas",
    "debit": "débito", "credit": "crédito",
    "savings": "ahorro", "checking": "cheques",
    "number": "número", "numbers": "números",
    # Identificadores
    "clabe": "CLABE", "rfc": "RFC", "curp": "CURP",
    "id": "identificador", "folio": "folio",
    "reference": "referencia", "uuid": "UUID",
    "token": "token", "code": "código",
    # Personas y entidades
    "beneficiary": "beneficiario", "beneficiaries": "beneficiarios",
    "customer": "cliente", "clients": "clientes",
    "name": "nombre", "lastname": "apellido",
    "company": "empresa", "branch": "sucursal",
    "email": "correo electrónico",
    # Operaciones
    "payment": "pago", "transfer": "transferencia",
    "withdrawal": "retiro", "deposit": "depósito",
    "loan": "préstamo", "salary": "nómina",
    "advance": "anticipo", "investment": "inversión",
    "invest": "inversión", "promissory": "pagaré",
    "envelope": "sobre digital", "amortization": "amortización",
    "agreement": "contrato",
    "open": "apertura", "opening": "apertura",
    "activate": "activación", "confirm": "confirmación",
    "register": "registro", "request": "solicitud",
    "validate": "validación", "validation": "validación",
    "send": "envío", "receive": "recepción",
    "cancel": "cancelación", "reversion": "reversión",
    "operation": "operación", "operations": "operaciones",
    "transaction": "transacción", "transactions": "transacciones",
    "movement": "movimiento", "movements": "movimientos",
    "detail": "detalle", "details": "detalles",
    "summary": "resumen", "offer": "oferta",
    # Canales y dispositivos
    "channel": "canal", "device": "dispositivo",
    "phone": "teléfono", "cellphone": "teléfono",
    "interbank": "interbancario", "intrabank": "intrabancario",
    "card": "tarjeta", "cards": "tarjetas",
    "cardless": "sin tarjeta",
    "atm": "cajero automático",
    "frequent": "frecuente",
    "direct": "directo",
    # Regulatorios y seguridad
    "spei": "SPEI", "codi": "CoDi",
    "nip": "NIP", "pin": "PIN", "cvv": "CVV",
    "otp": "OTP", "biometric": "biométrico",
    "enrollment": "enrolamiento",
    "session": "sesión", "auth": "autenticación",
    "black": "lista", "list": "lista",
    "unusual": "inusual",
    # Datos de persona
    "birthdate": "fecha de nacimiento", "date": "fecha",
    "address": "dirección", "street": "calle",
    "neighborhood": "colonia", "neighborhoodcode": "código de colonia",
    "city": "ciudad", "zip": "código postal",
    "type": "tipo", "status": "estatus",
    # Crédito
    "limit": "límite", "available": "disponible",
    "kit": "kit", "delivery": "entrega",
    "upgrade": "mejora de producto", "level": "nivel",
    "captureline": "línea de captura",
    "debit": "domiciliación",
    # Mensajería
    "messaging": "mensajería", "notification": "notificación",
    "push": "notificación push",
    # Datos bancarios
    "catalog": "catálogo", "banks": "bancos", "bank": "banco",
    "intercard": "intercard",
    "proposition": "propuesta", "offer": "oferta",
}

# Excepción Java → consecuencia funcional de negocio en español
_EXC_MEANING: dict = {
    "BadRequestException":            "solicitud inválida",
    "UnauthorizedException":          "acceso no autorizado",
    "ExecuteSplException":            "error al ejecutar procedimiento en core bancario",
    "TimeoutException":               "tiempo de espera excedido",
    "DownstreamException":            "servicio externo no disponible",
    "DatabaseTimeoutException":       "tiempo de espera en base de datos",
    "ExecuteSplTimeoutException":     "tiempo de espera en core bancario",
    "DataNotFoundException":          "información no encontrada",
    "NoResourceFoundException":       "recurso no encontrado",
    "NotValidHeadersException":       "cabeceras de canal inválidas",
    "CheckHeadersException":          "validación de cabeceras del canal fallida",
    "ConstraintViolationException":   "restricción de negocio no cumplida",
    "MethodArgumentNotValidException":"parámetros de operación inválidos",
    "MicroserviceClientException":    "error en microservicio dependiente",
    "CircuitBreakerException":        "circuit breaker activo",
}

# Fragmento del nombre de MSA → contexto de negocio en español
_MSA_CTX: dict = {
    "codi":        "CoDi",
    "spei":        "SPEI",
    "interbank":   "transferencia interbancaria",
    "intrabank":   "transferencia intrabancaria",
    "transfer":    "transferencia",
    "payment":     "pago",
    "card":        "tarjeta",
    "cardless":    "retiro sin tarjeta",
    "loan":        "préstamo",
    "salary":      "anticipo de nómina",
    "deposit":     "cuenta de depósito",
    "credit":      "crédito",
    "invest":      "inversión",
    "promissory":  "pagaré",
    "envelope":    "sobre digital",
    "benefici":    "beneficiario",
    "enrollment":  "enrolamiento",
    "session":     "sesión del cliente",
    "atm":         "cajero automático",
    "frequent":    "cuentas frecuentes",
    "debit":       "domiciliación",
    "amortiz":     "amortización",
    "agreement":   "contrato",
    "cvv":         "CVV dinámico",
    "otp":         "OTP",
    "customer":    "datos del cliente",
    "biometric":   "identidad biométrica",
    "black":       "listas negras",
    "unusual":     "operaciones inusuales",
    "remittance":  "remesa",
    "captureline": "línea de captura",
    "services":    "pago de servicios",
    "opening":     "apertura de cuenta",
    "activation":  "activación de tarjeta",
    "upgrade":     "mejora de producto",
}


def _split_camel(s: str) -> list:
    """Divide camelCase / PascalCase en lista de palabras en minúsculas."""
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", s)
    s = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1 \2", s)
    return [w.lower() for w in s.split() if w]


def _field_to_es(field: str) -> str:
    """
    Traduce un nombre de campo camelCase a descripción en español de negocio.
    Intenta bigramas antes de palabras sueltas para capturar 'accountNumber',
    'debitAccount', 'companyNumber', etc.
    """
    words = _split_camel(field)
    result = []
    i = 0
    while i < len(words):
        if i + 1 < len(words):
            bigram = words[i] + words[i + 1]
            if bigram in _FIELD_TERMS:
                result.append(_FIELD_TERMS[bigram])
                i += 2
                continue
        result.append(_FIELD_TERMS.get(words[i], words[i]))
        i += 1
    return " ".join(result) if result else field


def _msa_ctx(repo: str) -> str:
    """Extrae el contexto de negocio del nombre del repositorio MSA."""
    # Quita prefijo msa??-?-{layer}-
    clean = re.sub(
        r"^msa[a-z]{2}-[a-z]-"
        r"(?:business|domain|security|platform|service|serv|"
        r"utility|orchestration|middleware|integration|b|d|p|o|s|m|u|i)-?",
        "", repo,
    )
    parts = clean.split("-")
    for part in parts:
        for key, label in _MSA_CTX.items():
            if part.startswith(key):
                return label
    return ""


# ── Descripción funcional de la regla (síntesis en extracción, sin LLM) ──────

def gen_descripcion(
    tipo: str, sub_tipo: str, code: str, ctx: str = "", repo: str = ""
) -> str:
    """
    Genera una descripción funcional de negocio en el momento de la extracción.
    Usa vocabulario de dominio, traducción de camelCase y contexto del MSA para
    producir texto legible sin depender de LLM.

    business_name sigue siendo null (ADR-SPE-AM-010 — síntesis LLM posterior).
    """
    s = (code or "").strip()
    c = (ctx or s)
    biz = _msa_ctx(repo)

    # ── VALIDACIÓN ────────────────────────────────────────────────────────────
    if tipo == "VALIDACIÓN":
        exc = sub_tipo or ""
        # Lookup case-insensitive para cubrir variantes (TimeoutException / TimeOutException)
        meaning = next(
            (v for k, v in _EXC_MEANING.items() if k.lower() == exc.lower()),
            re.sub(r"([a-z])([A-Z])", r"\1 \2",
                   re.sub(r"Exception$|Error$", "", exc)).lower().strip() or exc
        )
        # Buscar condición if(...) antes del throw en el contexto
        cond_m = re.search(
            r"if\s*\((.{5,120}?)\)\s*(?:\{[^}]{0,80}\})?\s*throw",
            c, re.DOTALL
        )
        if cond_m:
            cond = re.sub(r"\s+", " ", cond_m.group(1)).strip()
            # Limpiar ruido técnico de la condición
            cond = re.sub(r"\b[A-Z][a-zA-Z0-9_]+\.", "", cond)   # ClassName.
            cond = re.sub(r"\(\([^)]+\)\s*", "", cond)           # casts
            cond = re.sub(r"StringUtils\.|Objects\.|CollectionUtils\.", "", cond)
            cond = cond.strip()[:80]
            if cond:
                return f"{meaning.capitalize()} — condición: {cond}"
        if biz:
            return f"{meaning.capitalize()} en operación de {biz}"
        return meaning.capitalize()

    # ── UMBRAL ────────────────────────────────────────────────────────────────
    elif tipo == "UMBRAL":
        # Timeouts vienen de properties: tratar por separado
        if sub_tipo == "TIMEOUT_OPERATIVO":
            val_m = re.search(r"=\s*([0-9]+)\s*$", s, re.M)
            val = val_m.group(1) if val_m else ""
            op = biz or "operación"
            return f"Tiempo de espera máximo para {op}: {val} ms" if val \
                else f"Tiempo de espera máximo para {op}"

        ann_label = {
            "MIN": "mínimo", "MAX": "máximo",
            "DECIMALMIN": "mínimo", "DECIMALMAX": "máximo",
            "SIZE": "tamaño máximo",
        }.get((sub_tipo or "").upper(), "límite")

        val_m = (
            re.search(r'"([0-9]+(?:\.[0-9]+)?)"', s) or
            re.search(r"value\s*=\s*([0-9]+(?:\.[0-9]+)?)", s, re.I) or
            re.search(r"\(\s*([0-9]+(?:\.[0-9]+)?)\s*[,)]", s) or
            re.search(r"=\s*([0-9]+(?:\.[0-9]+)?)\s*$", s, re.M)
        )
        val = val_m.group(1) if val_m else ""

        field_m = (
            re.search(r"(?:private|public|protected)\s+\S+\s+(\w+)\s*;", s) or
            re.search(r"\bBigDecimal\b\s+(\w+)\b", s) or
            re.search(r"\bString\b\s+(\w+)\s*;", s) or
            re.search(r"(\w+)\s*;", s)
        )
        field_raw = field_m.group(1) if field_m else ""
        field_es  = _field_to_es(field_raw) if field_raw else ""

        if field_es and val:
            return f"Valor {ann_label} de {field_es}: {val}"
        elif field_es:
            return f"Valor {ann_label} para {field_es}"
        elif biz:
            return f"Límite {ann_label} en {biz}"
        return f"Umbral {ann_label} en DTO"

    # ── ANOTACIÓN ─────────────────────────────────────────────────────────────
    elif tipo == "ANOTACIÓN":
        field_m = (
            re.search(r"(?:private|public|protected)\s+\S+\s+(\w+)\s*;", s) or
            re.search(r"(\w+)\s*;", s)
        )
        raw = field_m.group(1) if field_m else ""
        field_es = _field_to_es(raw) if raw else ""

        if field_es and biz:
            return f"{field_es.capitalize()} obligatorio para {biz}"
        elif field_es:
            return f"{field_es.capitalize()} obligatorio en la solicitud"
        return "Campo obligatorio en solicitud"

    # ── CONFIGURACIÓN ─────────────────────────────────────────────────────────
    elif tipo == "CONFIGURACIÓN":
        eq = s.find("=")
        if eq <= 0:
            return f"Configuración: {s[:70]}"
        key = s[:eq].strip()
        val = s[eq + 1:].strip()

        if sub_tipo == "SP_REFERENCIA":
            # Extraer nombre del SP:
            # "bdicred:spcobrocredito"          → spcobrocredito
            # "{call bdicred:sp_xxx(?,?,?)}"     → sp_xxx
            # "{CALL bdicred:informix.sp_xxx(?)}"→ sp_xxx
            sp_clean = re.sub(r"^\{CALL\s+|^\{call\s+", "", val, flags=re.I).strip()
            sp_clean = re.sub(r"\(.*", "", sp_clean).strip()  # quitar parámetros
            # db:sp_name o db:informix.sp_name
            m_sp = re.search(r"(?:informix\.)?(\w+)\s*$", sp_clean, re.I)
            sp_name = m_sp.group(1) if m_sp else sp_clean[:40]
            return f"Procedimiento Informix invocado: {sp_name}"

        if sub_tipo == "CANAL_VÁLIDO":
            return f"Canales de acceso permitidos al MSA: {val[:60]}"

        if sub_tipo == "TIMEOUT_OPERATIVO":
            parts = key.split(".")
            op = parts[-2] if len(parts) >= 2 else biz or "operación"
            return f"Tiempo de espera máximo para {op}: {val} ms"

        if sub_tipo == "PARÁMETRO_PAGO":
            parts = key.split(".")
            op = _field_to_es(parts[-1]) if parts else key
            return f"Parámetro de pago — {op}: {val[:50]}"

        if sub_tipo == "CONEXIÓN_BD":
            # Extraer nombre de BD del JDBC URL
            db_m = re.search(r"informix/(\w+)", val, re.I) or \
                   re.search(r"databaseName=(\w+)", val, re.I)
            db_name = db_m.group(1) if db_m else "Informix"
            return f"Conexión JDBC al core bancario: {db_name}"

        # PARÁMETRO_OPERATIVO genérico
        parts = key.split(".")
        key_short = ".".join(parts[-3:]) if len(parts) > 3 else key
        return f"Parámetro operativo del canal: {key_short} = {val[:40]}"

    # ── CÓDIGO_ERROR ──────────────────────────────────────────────────────────
    elif tipo == "CÓDIGO_ERROR":
        eq = s.find("=")
        if eq > 0:
            key = s[:eq].strip()
            val = s[eq + 1:].strip()[:60]
            parts = key.split(".")
            # constants.api.codes.{operacion}.{variante}  →  operacion (variante)
            # constants.api.codes.sp                      →  sp
            op_idx = next((i for i, p in enumerate(parts) if p == "codes"), None)
            if op_idx is not None and op_idx + 1 < len(parts):
                op_raw  = parts[op_idx + 1]
                variant = parts[op_idx + 2] if op_idx + 2 < len(parts) else ""
                op_es   = _field_to_es(op_raw)
                label   = f"{op_es} / {variant}" if variant else op_es
            else:
                label = _field_to_es(parts[-1]) or key
            return f"Códigos de respuesta Informix — {label}: {val}"
        return f"Código de error: {s[:60]}"

    return s[:80]


# ── Patrones de extracción Java ───────────────────────────────────────────────

# Excepciones de negocio (excluye NPE / ClassCast / puras infra)
BIZ_EXCEPTIONS = re.compile(
    r"ExecuteSplException|TimeoutException|BadRequestException|"
    r"UnauthorizedException|DownstreamException|DatabaseTimeoutException|"
    r"ExecuteSplTimeoutException|NotValidHeadersException|CheckHeadersException|"
    r"ConstraintViolationException|MethodArgumentNotValidException|"
    r"DataNotFoundException|NoResourceFoundException|"
    r"MicroserviceClientException|CircuitBreakerException",
    re.I
)

# Patrón guard clause: if/assert + throw o solo throw
RE_GUARD = re.compile(
    r"(?:(?:if\s*\(.{0,120}?\)\s*(?:\{[^}]{0,60}\})?\s*)?throw\s+new\s+"
    r"([A-Za-z][A-Za-z0-9_]*(?:Exception|Error))\s*\()",
    re.DOTALL
)

# Patrón @Min / @Max / @DecimalMin / @DecimalMax
RE_UMBRAL = re.compile(
    r"@(Min|Max|DecimalMin|DecimalMax|Size)\s*\(\s*(?:value\s*=\s*)?([^)]+)\)",
    re.I
)

# Patrón @NotNull / @NotBlank / @NotEmpty
RE_ANNT = re.compile(
    r"@(NotNull|NotBlank|NotEmpty|Valid|Validated)\s*(?:\([^)]*\))?\s*\n\s*"
    r"(?:(?:private|public|protected)\s+)?(?:\S+\s+)(\w+);",
    re.DOTALL
)

# Properties: claves de negocio (SP references, codes, operational params)
# Excluye infra pura: logging, swagger, actuator, jpa, hikari, feign, hystrix-infra, server.port
PROP_BIZ_KEYS = re.compile(
    r"constants\.api\.(name|codes|type|payment|status|pindbenef|comission|"
    r"reversion|headers\.validate|headers\.required|validate\.channels?|"
    r"limit|mtu|channel|timeout(?:Error)?)[\.\w]*"
    r"|validate\.headers"
    r"|hystrix\.command\.default\.execution\.isolation\.thread\.timeoutInMilliseconds"
    r"|spring\.datasource\.url",
    re.I
)

# ── Carga de vocabulario desde brain.db ───────────────────────────────────────

def load_vocab(db_path: Path) -> list:
    """Carga términos financieros de alta/media confianza del brain.db."""
    if not db_path.exists():
        return []
    try:
        con = sqlite3.connect(str(db_path))
        # Intentar tabla terms (build-brain.py)
        try:
            rows = con.execute(
                "SELECT term FROM terms WHERE confidence IN ('ALTA','MEDIA') LIMIT 2000"
            ).fetchall()
            return [r[0] for r in rows]
        except Exception:
            pass
        # Fallback: tabla vocabulary
        try:
            rows = con.execute(
                "SELECT term FROM vocabulary LIMIT 2000"
            ).fetchall()
            return [r[0] for r in rows]
        except Exception:
            return []
    except Exception:
        return []
    finally:
        try:
            con.close()
        except Exception:
            pass

# ── Inicialización de la tabla rules en brain.db ──────────────────────────────

DDL_RULES = """
CREATE TABLE IF NOT EXISTS rules (
    id               TEXT PRIMARY KEY,
    tipo             TEXT NOT NULL,
    sp               TEXT,
    db               TEXT,
    domain           TEXT,
    line             INTEGER,
    code             TEXT,
    reg              TEXT,
    riesgo           TEXT,
    business_name    TEXT,
    clase            TEXT,
    sub_tipo         TEXT,
    source_file      TEXT,
    descripcion_regla TEXT,
    extracted_at     TEXT DEFAULT (datetime('now'))
);
"""

DDL_RULE_LOG = """
CREATE TABLE IF NOT EXISTS rule_enrichment_log (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    rule_id    TEXT,
    swarm      TEXT,
    field      TEXT,
    old_value  TEXT,
    new_value  TEXT,
    timestamp  TEXT,
    confidence TEXT,
    method     TEXT,
    notes      TEXT
);
"""

def init_rules_table(con: sqlite3.Connection):
    con.executescript(DDL_RULES + DDL_RULE_LOG)
    # Migración: agregar columna si el brain.db ya existe sin ella
    try:
        con.execute("ALTER TABLE rules ADD COLUMN descripcion_regla TEXT")
        con.commit()
    except sqlite3.OperationalError:
        pass  # ya existe
    con.commit()

# ── Extracción de archivos Java ───────────────────────────────────────────────

def extract_from_java(java_file: Path, repo: str, fin_pat: re.Pattern, verbose: bool) -> list:
    """Extrae reglas de negocio de un archivo .java."""
    rules = []
    try:
        text = java_file.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return rules

    # Omitir archivos de test
    if "/test/" in str(java_file).replace("\\", "/"):
        return rules

    # Clase Java
    cls_match = re.search(r"(?:public\s+(?:class|interface|enum|record))\s+(\w+)", text)
    class_name = cls_match.group(1) if cls_match else java_file.stem
    lines = text.split("\n")
    domain = domain_from_repo(repo)
    domain_name = DOMAIN_MAP.get(domain, "Cross-domain")
    sp_ref = f"{repo}:{class_name}"

    # Solo procesar archivos con señales de negocio (pre-filtro rápido)
    pre_filter = ("throw new", "@NotNull", "@Min", "@Max", "@DecimalMin",
                  "@Size", "BigDecimal", "Exception", "@NotEmpty", "@NotBlank")
    if not any(pf.lower() in text.lower() for pf in pre_filter):
        return rules

    seen = set()

    # ── VALIDACIÓN: guard clauses (throw new XxxException) ───────────────────
    for i, line in enumerate(lines, 1):
        s = line.strip()
        if not s or s.startswith("//") or s.startswith("*"):
            continue
        m = re.search(r"throw\s+new\s+([A-Za-z][A-Za-z0-9_]*(?:Exception|Error))\s*\(", s)
        if not m:
            continue
        exc_name = m.group(1)
        if not BIZ_EXCEPTIONS.search(exc_name):
            continue
        # Contexto: líneas alrededor para detectar regulación y fin terms
        ctx_start = max(0, i - 6)
        ctx = "\n".join(lines[ctx_start:i + 2])
        reg  = clasificar_reg(ctx + " " + class_name + " " + repo)
        rsk  = detect_riesgo(ctx)
        key  = (class_name, exc_name, i)
        if key in seen:
            continue
        seen.add(key)
        code_frag = s[:180]
        rid = f"BR-AM-{msa_abbr(repo)}-{i}"
        rules.append({
            "id": rid, "tipo": "VALIDACIÓN",
            "sp": sp_ref, "db": domain,
            "domain": domain_name, "line": i,
            "code": code_frag, "reg": reg, "riesgo": rsk,
            "business_name": None,
            "clase": asigna_clase("VALIDACIÓN", ctx),
            "sub_tipo": exc_name,
            "source_file": str(java_file.relative_to(SOURCE_DIR.parent.parent.parent)),
            "descripcion_regla": gen_descripcion("VALIDACIÓN", exc_name, code_frag, ctx, repo),
        })

    # ── UMBRAL: @Min / @Max / @DecimalMin / @DecimalMax / @Size ──────────────
    for i, line in enumerate(lines, 1):
        s = line.strip()
        m = RE_UMBRAL.search(s)
        if not m:
            continue
        # Extraer el campo que anota (siguiente línea con declaración)
        field_line = lines[i] if i < len(lines) else ""
        field_m = re.search(r"(\w+)\s*;?\s*$", field_line.strip())
        field_name = field_m.group(1) if field_m else "?"
        # Solo incluir si campo es de dominio financiero
        if not fin_pat.search(field_name + " " + s):
            continue
        ctx = line + "\n" + field_line
        reg = clasificar_reg(ctx + " " + class_name + " " + repo)
        rsk = detect_riesgo(ctx)
        key = (class_name, "UMBRAL", m.group(1), i)
        if key in seen:
            continue
        seen.add(key)
        code_frag = (s + " " + field_line.strip())[:180]
        sub_t_umbral = m.group(1).upper()
        rid = f"BR-AM-{msa_abbr(repo)}-{i}"
        rules.append({
            "id": rid, "tipo": "UMBRAL",
            "sp": sp_ref, "db": domain,
            "domain": domain_name, "line": i,
            "code": code_frag, "reg": reg, "riesgo": rsk,
            "business_name": None,
            "clase": "NEGOCIO",
            "sub_tipo": sub_t_umbral,
            "source_file": str(java_file.relative_to(SOURCE_DIR.parent.parent.parent)),
            "descripcion_regla": gen_descripcion("UMBRAL", sub_t_umbral, code_frag, "", repo),
        })

    # ── ANOTACIÓN: @NotNull / @NotBlank / @NotEmpty en campos financieros ────
    for i, line in enumerate(lines, 1):
        s = line.strip()
        if not re.match(r"@(NotNull|NotBlank|NotEmpty)\b", s):
            continue
        # Buscar el campo en las siguientes 3 líneas
        for j in range(i, min(i + 4, len(lines))):
            field_line = lines[j].strip()
            fd = re.search(r"(?:private|public|protected)?\s+\S+\s+(\w+)\s*;", field_line)
            if fd:
                field_name = fd.group(1)
                if fin_pat.search(field_name):
                    ctx = "\n".join(lines[max(0, i-2):j+2])
                    reg = clasificar_reg(ctx + " " + class_name + " " + repo)
                    key = (class_name, "ANNT", field_name, i)
                    if key not in seen:
                        seen.add(key)
                        code_frag = (s + " " + field_line)[:180]
                        rid = f"BR-AM-{msa_abbr(repo)}-{i}"
                        rules.append({
                            "id": rid, "tipo": "ANOTACIÓN",
                            "sp": sp_ref, "db": domain,
                            "domain": domain_name, "line": i,
                            "code": code_frag, "reg": reg, "riesgo": "",
                            "business_name": None,
                            "clase": "NEGOCIO",
                            "sub_tipo": "CAMPO_OBLIGATORIO",
                            "source_file": str(java_file.relative_to(SOURCE_DIR.parent.parent.parent)),
                            "descripcion_regla": gen_descripcion("ANOTACIÓN", "CAMPO_OBLIGATORIO", code_frag, "", repo),
                        })
                break

    if verbose and rules:
        print(f"    {java_file.name}: {len(rules)} reglas")
    return rules


# ── Extracción de properties ──────────────────────────────────────────────────

def extract_from_properties(prop_file: Path, repo: str, verbose: bool) -> list:
    """Extrae reglas CONFIGURACIÓN / CÓDIGO_ERROR de application*.properties."""
    rules = []
    try:
        text = prop_file.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return rules

    lines = text.split("\n")
    domain = domain_from_repo(repo)
    domain_name = DOMAIN_MAP.get(domain, "Cross-domain")
    sp_ref = f"{repo}:properties"
    seen = set()

    for i, raw in enumerate(lines, 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        m_kv = re.match(r"([^=:]+)\s*[=:]\s*(.+)", line)
        if not m_kv:
            continue
        key_full = m_kv.group(1).strip()
        val      = m_kv.group(2).strip()

        # Filtrar: solo claves de negocio
        if not PROP_BIZ_KEYS.search(key_full):
            continue

        # Deduplicar por clave (un repo puede tener varios profiles)
        if key_full in seen:
            continue
        seen.add(key_full)

        reg  = clasificar_reg(key_full + " " + val + " " + repo)
        rsk  = detect_riesgo(key_full + " " + val)
        ctx  = line

        # Sub-tipo por clave
        if re.search(r"\.name\.sp|\.sp[a-z]+", key_full, re.I):
            sub_tipo = "SP_REFERENCIA"
            tipo_r   = "CONFIGURACIÓN"
        elif re.search(r"\.codes\.", key_full, re.I):
            sub_tipo = "CÓDIGOS_RETORNO_INFORMIX"
            tipo_r   = "CÓDIGO_ERROR"
        elif re.search(r"timeout", key_full, re.I):
            sub_tipo = "TIMEOUT_OPERATIVO"
            tipo_r   = "UMBRAL"
        elif re.search(r"spring\.datasource\.url", key_full, re.I):
            sub_tipo = "CONEXIÓN_BD"
            tipo_r   = "CONFIGURACIÓN"
        elif re.search(r"validate\.channels?|valid\.channels?|constants\.api\.type", key_full, re.I):
            sub_tipo = "CANAL_VÁLIDO"
            tipo_r   = "CONFIGURACIÓN"
        elif re.search(r"comission|pago|reversion|pindbenef", key_full, re.I):
            sub_tipo = "PARÁMETRO_PAGO"
            tipo_r   = "CONFIGURACIÓN"
        else:
            sub_tipo = "PARÁMETRO_OPERATIVO"
            tipo_r   = "CONFIGURACIÓN"

        rid = f"BR-AM-{msa_abbr(repo)}-prop-{i}"
        rules.append({
            "id": rid, "tipo": tipo_r,
            "sp": sp_ref, "db": domain,
            "domain": domain_name, "line": i,
            "code": ctx[:180], "reg": reg, "riesgo": rsk,
            "business_name": None,
            "clase": asigna_clase(tipo_r, ctx),
            "sub_tipo": sub_tipo,
            "source_file": str(prop_file.relative_to(SOURCE_DIR.parent.parent.parent)),
            "descripcion_regla": gen_descripcion(tipo_r, sub_tipo, ctx[:180], "", repo),
        })

    if verbose and rules:
        print(f"    {prop_file.name}: {len(rules)} reglas")
    return rules


# ── Persistencia en brain.db ──────────────────────────────────────────────────

def load_into_brain(rules: list, db_path: Path, verbose: bool):
    """Carga las reglas en brain.db::rules (UPSERT por id)."""
    con = sqlite3.connect(str(db_path))
    init_rules_table(con)

    inserted = updated = 0
    for r in rules:
        existing = con.execute(
            "SELECT id FROM rules WHERE id = ?", (r["id"],)
        ).fetchone()
        if existing:
            con.execute("""
                UPDATE rules SET tipo=?,sp=?,db=?,domain=?,line=?,code=?,reg=?,
                riesgo=?,clase=?,sub_tipo=?,source_file=?,descripcion_regla=?,
                extracted_at=?
                WHERE id=?
            """, (r["tipo"], r["sp"], r["db"], r["domain"], r["line"],
                  r["code"], r["reg"], r["riesgo"], r["clase"],
                  r["sub_tipo"], r["source_file"],
                  r.get("descripcion_regla"), TS_NOW, r["id"]))
            updated += 1
        else:
            con.execute("""
                INSERT INTO rules
                (id,tipo,sp,db,domain,line,code,reg,riesgo,business_name,
                 clase,sub_tipo,source_file,descripcion_regla,extracted_at)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
            """, (r["id"], r["tipo"], r["sp"], r["db"], r["domain"],
                  r["line"], r["code"], r["reg"], r["riesgo"],
                  r["business_name"], r["clase"], r["sub_tipo"],
                  r["source_file"], r.get("descripcion_regla"), TS_NOW))
            inserted += 1

    con.commit()
    con.close()
    print(f"  brain.db::rules → {inserted} insertadas, {updated} actualizadas")


# ── Generación del catálogo Markdown ─────────────────────────────────────────

TIPO_ORDER = ["VALIDACIÓN", "UMBRAL", "CÓDIGO_ERROR", "CONFIGURACIÓN", "ANOTACIÓN"]

def render_catalog(db_path: Path, out_path: Path):
    """Genera catalogo-reglas-appmovil.md desde brain.db::rules."""
    con = sqlite3.connect(str(db_path))
    rows = con.execute("""
        SELECT id, tipo, sp, domain, line, code, reg, riesgo, business_name,
               clase, sub_tipo, source_file, descripcion_regla
        FROM rules
        ORDER BY
            CASE tipo
                WHEN 'VALIDACIÓN'   THEN 1
                WHEN 'UMBRAL'       THEN 2
                WHEN 'CÓDIGO_ERROR' THEN 3
                WHEN 'CONFIGURACIÓN'THEN 4
                WHEN 'ANOTACIÓN'    THEN 5
                ELSE 6
            END,
            domain, sp, line
    """).fetchall()
    totals = con.execute("""
        SELECT tipo, COUNT(*) FROM rules GROUP BY tipo ORDER BY COUNT(*) DESC
    """).fetchall()
    by_reg = con.execute("""
        SELECT COUNT(*) FROM rules WHERE reg != '' AND reg IS NOT NULL
    """).fetchone()[0]
    con.close()

    now_str = datetime.now().strftime("%Y-%m-%d")
    lines = [
        f"# Catálogo de Reglas de Negocio — AppMovil Canal Móvil BanCoppel",
        f"> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`",
        f"> **Generado**: {now_str} desde `brain.db::rules` por `extract-rules-java.py v{VERSION}`",
        f"> **Total reglas**: {len(rows)} · Con clasificación regulatoria: {by_reg}",
        f">",
        f"> **ADR-SPE-AM-009**: ID canónico `BR-AM-{{msa_abbr}}-{{line}}` — anclado a fuente. msa_abbr = slug funcional del MSA (ej. `codi-pay`, `sess-man`, `freq-acc`).",
        f"> **ADR-SPE-AM-010**: `business_name = null` pendiente de síntesis LLM (swarm de enriquecimiento).",
        "",
        "---",
        "",
        "## Resumen por Tipo",
        "",
        "| Tipo | Reglas |",
        "|------|--------|",
    ]
    for tipo, cnt in totals:
        lines.append(f"| {tipo} | {cnt} |")

    lines += [
        "",
        "---",
        "",
    ]

    # Agrupar por tipo
    from collections import defaultdict
    by_tipo = defaultdict(list)
    for row in rows:
        by_tipo[row[1]].append(row)

    TIPO_DESC = {
        "VALIDACIÓN":    "Guard clauses — excepciones de negocio lanzadas en servicios",
        "UMBRAL":        "Límites operativos — anotaciones `@Min/@Max/@DecimalMin/@Size` en DTOs",
        "CÓDIGO_ERROR":  "Catálogo de errores — mapeo excepción → código operativo en properties",
        "CONFIGURACIÓN": "Parámetros operativos — claves de negocio en `application*.properties`",
        "ANOTACIÓN":     "Campos obligatorios — `@NotNull/@NotBlank/@NotEmpty` en DTOs financieros",
    }

    for tipo in (TIPO_ORDER + [t for t in by_tipo if t not in TIPO_ORDER]):
        if tipo not in by_tipo:
            continue
        group = by_tipo[tipo]
        lines += [
            f"## {tipo} ({len(group)} reglas)",
            "",
            f"_{TIPO_DESC.get(tipo, tipo)}_",
            "",
            "| ID | Descripción de regla | Clase | Dominio | SP / Clase | Línea | Regulación | Sub-tipo |",
            "|----|----------------------|-------|---------|------------|-------|------------|----------|",
        ]
        for row in group:
            rid, _, sp, domain, line, code, reg, riesgo, bname, clase, sub_tipo, src, desc = row
            desc_md = (desc or "").replace("|", "&#124;")[:90]
            reg_md  = (reg or "—").replace("|", "&#124;")[:60]
            sp_md   = (sp or "—").replace("|", "&#124;")[:40]
            lines.append(
                f"| {rid} | {desc_md or '—'} | {clase or '—'} | {domain or '—'} | {sp_md} "
                f"| {line or '—'} | {reg_md} | {sub_tipo or '—'} |"
            )
        lines.append("")

    lines += [
        "---",
        "",
        "## Notas de Migración",
        "",
        "### Riesgos de Equivalencia Detectados",
        "",
        "| ID | Riesgo |",
        "|----|--------|",
    ]
    for row in rows:
        if row[7]:  # riesgo
            rid = row[0]
            rsk = row[7].replace("|", "&#124;")[:120]
            lines.append(f"| {rid} | {rsk} |")

    lines += [
        "",
        "---",
        "",
        "## Pendiente — Enriquecimiento business_name (ADR-SPE-AM-010)",
        "",
        "Todas las reglas tienen `business_name = null`. El swarm de enriquecimiento LLM debe:",
        "1. Leer cada regla desde `brain.db::rules`",
        "2. Sintetizar el `business_name` en español de negocio (no código técnico)",
        "3. Registrar cada cambio en `rule_enrichment_log` con `method='llm-synthesis'`",
        "4. Gate de calidad: `COUNT(*) WHERE business_name IS NULL = 0` antes de entregar el catálogo",
        "",
        f"*Generado por `generators/extract-rules-java.py` · {now_str} · v{VERSION}*",
        f"*Ancla metodológica: extract-rules-v2.py (Informix) + ADR-SPE-AM-009 + ADR-SPE-AM-010*",
    ]

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"  Catálogo escrito: {out_path}")


# ── Pipeline principal ────────────────────────────────────────────────────────

def run(source_dir: Path, db_path: Path, gen_catalog: bool, gen_json: bool, verbose: bool):
    if not source_dir.exists():
        print(f"ERROR: directorio de código fuente no encontrado: {source_dir}")
        sys.exit(1)
    if not db_path.exists():
        print(f"ERROR: brain.db no encontrado: {db_path}")
        sys.exit(1)

    # Cargar vocabulario
    print("  Cargando vocabulario del brain.db...")
    vocab = load_vocab(db_path)
    fin_pat = build_fin_pat(vocab)
    print(f"  FIN_PAT: {len(vocab)} términos de vocabulario amplificados")

    all_rules = []
    repos = sorted([d for d in source_dir.iterdir() if d.is_dir()])
    print(f"  Escaneando {len(repos)} repositorios en {source_dir}...")

    for repo_dir in repos:
        repo = repo_dir.name
        if not repo.startswith("msa"):
            continue

        repo_rules = []

        # Java files (solo src/main/java — excluir tests)
        for java_file in repo_dir.rglob("*.java"):
            if "src/test" in str(java_file).replace("\\", "/"):
                continue
            rules_j = extract_from_java(java_file, repo, fin_pat, verbose)
            repo_rules.extend(rules_j)

        # Properties files
        for prop_file in repo_dir.rglob("application*.properties"):
            rules_p = extract_from_properties(prop_file, repo, verbose)
            repo_rules.extend(rules_p)

        # También revisar config/*.properties
        for prop_file in repo_dir.rglob("*.properties"):
            if prop_file.name.startswith("application"):
                continue  # ya procesado arriba
            if any(kw in str(prop_file).replace("\\", "/") for kw in ["/test/", "/resources/"]):
                rules_p = extract_from_properties(prop_file, repo, verbose)
                repo_rules.extend(rules_p)

        if repo_rules:
            print(f"  {repo}: {len(repo_rules)} reglas")
        all_rules.extend(repo_rules)

    print(f"\n  Total extraído: {len(all_rules)} reglas")

    # Deduplicar por ID
    seen_ids = {}
    deduped = []
    for r in all_rules:
        if r["id"] not in seen_ids:
            seen_ids[r["id"]] = True
            deduped.append(r)
        else:
            # Sufijo numérico para IDs duplicados (mismo archivo, diferente tipo)
            base = r["id"]
            suffix = 1
            while f"{base}-{suffix}" in seen_ids:
                suffix += 1
            new_id = f"{base}-{suffix}"
            seen_ids[new_id] = True
            r["id"] = new_id
            deduped.append(r)

    print(f"  Deduplicado: {len(deduped)} reglas únicas")

    # Estadísticas por tipo
    from collections import Counter
    for tipo, cnt in Counter(r["tipo"] for r in deduped).most_common():
        print(f"    {tipo}: {cnt}")

    # Cargar en brain.db
    print(f"\n  Cargando en {db_path}...")
    load_into_brain(deduped, db_path, verbose)

    # Generar catálogo
    if gen_catalog:
        catalog_path = db_path.parent.parent / "dt" / "dt-reglas" / "catalogo-reglas-appmovil.md"
        print(f"\n  Generando catálogo desde brain.db...")
        render_catalog(db_path, catalog_path)

    print(f"\n  Extracción completa. {len(deduped)} reglas en brain.db::rules")
    print(f"  Siguiente paso: swarm de enriquecimiento LLM → business_name (ADR-SPE-AM-010)")

    if gen_json:
        json_path = db_path.parent.parent / "portal" / "data" / "rules-data.json"
        export_json(db_path, json_path)


def export_json(db_path: Path, out_path: Path):
    """Exporta brain.db::rules a JSON para el portal HTML (incluye descripcion_regla)."""
    con = sqlite3.connect(str(db_path))
    con.row_factory = sqlite3.Row
    rows = con.execute("""
        SELECT id, tipo, sp, db, domain, line, code, reg, riesgo,
               business_name, clase, sub_tipo, source_file, descripcion_regla
        FROM rules ORDER BY tipo, domain, sp, line
    """).fetchall()
    con.close()
    data = [dict(r) for r in rows]
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"  JSON exportado: {out_path} ({len(data)} reglas)")


def main():
    parser = argparse.ArgumentParser(description="Extractor de reglas Java — AppMovil")
    parser.add_argument("--source",      type=Path, default=SOURCE_DIR, help="Directorio source/code")
    parser.add_argument("--db",          type=Path, default=DB_PATH,    help="Ruta al brain.db")
    parser.add_argument("--catalog",     action="store_true", help="Generar catalogo-reglas-appmovil.md")
    parser.add_argument("--export-json", action="store_true", help="Exportar portal/data/rules-data.json")
    parser.add_argument("--verbose",     action="store_true", help="Output detallado por archivo")
    args = parser.parse_args()
    run(args.source, args.db, args.catalog, args.export_json, args.verbose)


if __name__ == "__main__":
    main()