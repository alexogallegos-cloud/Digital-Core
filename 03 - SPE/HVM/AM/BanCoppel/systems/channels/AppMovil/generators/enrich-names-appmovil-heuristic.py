#!/usr/bin/env python3
"""
enrich-names-appmovil-heuristic.py — Enriquecimiento heurístico de business_name · AppMovil
BanCoppel Application Modernization · SPE-AM-001

Cubre sin agentes:
  ANOTACIÓN    (1501) — @NotNull/@NotEmpty/@NotBlank + campo + contexto de clase
  CONFIGURACIÓN (406) — clave de properties + valor
  UMBRAL         (92) — @Max/@DecimalMin en Java + hystrix/timeout en props
  CÓDIGO_ERROR    (8) — error code en properties

NO cubre (requiere scatter-gather con lectura de fuente):
  VALIDACIÓN  (774) — guard clauses / throw, necesitan contexto del método

Salida:
  knowledge-base/rules/name-overrides-appmovil-heuristic.json
  (mismo formato que name-overrides-ai.json de Informix)

Aplicación al brain:
  python digital-brain/build-brain.py  (rebuild completo)
"""

import json
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).parent.parent
RULES_PATH = BASE / "portal" / "data" / "rules-data.json"
OVERRIDES_OUT = BASE / "knowledge-base" / "rules" / "name-overrides-appmovil-heuristic.json"

# ── Compound map: campo completo (lowercase) → español correcto ──────────────
# Prioridad sobre TOKEN_MAP; evita problemas de orden idiomático inglés→español.

COMPOUND_MAP = {
    # cliente
    "customernumber": "número de cliente",
    "customerid": "identificador de cliente",
    "customername": "nombre de cliente",
    "customernames": "nombres del cliente",
    "customeremail": "correo electrónico del cliente",
    "origincustomernumber": "número de cliente de origen",
    # cuenta
    "accountnumber": "número de cuenta",
    "accountname": "nombre de cuenta",
    "accountkey": "clave de cuenta",
    "originaccount": "cuenta de origen",
    "destinationaccount": "cuenta de destino",
    "originaccountnumber": "número de cuenta de origen",
    "destinationaccountnumber": "número de cuenta de destino",
    "associatedaccount": "cuenta asociada",
    "debitaccountnumbers": "números de cuenta de débito",
    "creditcardaccountnumbers": "números de cuenta de tarjeta de crédito",
    "loanaccountnumbers": "números de cuenta de préstamo",
    "investmentaccountnumbers": "números de cuenta de inversión",
    "promissorynotesaccountnumbers": "números de cuenta de pagaré",
    "accountsendbeneficiary": "beneficiarios para envío entre cuentas",
    # tarjeta
    "cardnumber": "número de tarjeta",
    "cardstatus": "estado de la tarjeta",
    "creditcardnumber": "número de tarjeta de crédito",
    "destinationcreditcardnumber": "número de tarjeta de crédito destino",
    # celular
    "cellphonenumber": "número de celular",
    # crédito / préstamo
    "creditnumber": "número de crédito",
    # empresa
    "companynumber": "número de empresa",
    "companyname": "nombre de empresa",
    # sucursal
    "invoicebranch": "sucursal de facturación",
    "virtualbranch": "sucursal virtual",
    "foliosuc": "folio de sucursal",
    # tipo
    "paymenttype": "tipo de pago",
    "operationtype": "tipo de operación",
    "currencytype": "tipo de moneda",
    "balancetype": "tipo de saldo",
    "producttype": "tipo de producto",
    # fecha / nacimiento
    "birthdate": "fecha de nacimiento",
    "birthentity": "lugar de nacimiento",
    # nombre completo
    "lastname": "apellido",
    "firstname": "nombre de pila",
    # registros / páginas
    "requestedpage": "página solicitada",
    "requesteddays": "días solicitados",
    "requestedrecordsnumber": "número de registros solicitados",
    "registrationstatus": "estado de registro",
    "passwordconfirm": "confirmación de contraseña",
    # producto
    "productnumber": "número de producto",
    "applicationnumber": "número de solicitud",
    "transactionnumber": "número de transacción",
    # monto / devolución
    "returnamount": "monto de devolución",
    "totalamount": "monto total",
    "amountall": "monto total",
    # origen / destino / pagador
    "sourceaccount": "cuenta de origen",
    "sourcechannel": "canal de origen",
    "sourcecustomer": "cliente de origen",
    "payeraccount": "cuenta del pagador",
    "payeraccounttype": "tipo de cuenta del pagador",
    # código
    "uniquepopulationregistrycode": "CURP",
    "populationregistrycode": "código de registro de población",
    # cuenta corriente
    "currentaccount": "cuenta corriente",
    "savingsaccount": "cuenta de ahorro",
    # otros
    "accountbalance": "saldo de cuenta",
    "dischargedate": "fecha de descuento",
    "registerdevice": "registro de dispositivo",
    "sourcechannel": "canal de origen",
}

# ── Token map: camelCase tokens → español ───────────────────────────────────

TOKEN_MAP = {
    # identidad
    "customer": "cliente",
    "customers": "clientes",
    "id": "identificador",
    "uuid": "identificador único",
    "name": "nombre",
    "names": "nombres",
    "lastname": "apellido",
    "last": "apellido",
    "firstname": "nombre",
    "first": "primer",
    "gender": "género",
    "birthdate": "fecha de nacimiento",
    "birth": "nacimiento",
    "entity": "entidad",
    "birthentity": "lugar de nacimiento",
    "email": "correo electrónico",
    "phone": "teléfono",
    "cellphone": "teléfono celular",
    "cell": "celular",
    "password": "contraseña",
    "confirm": "confirmación",
    "passwordconfirm": "confirmación de contraseña",
    "registrationstatus": "estado de registro",
    "registration": "registro",
    "status": "estado",
    "alias": "alias",
    # números financieros clave
    "account": "cuenta",
    "accounts": "cuentas",
    "accountnumber": "número de cuenta",
    "accountname": "nombre de cuenta",
    "accountkey": "clave de cuenta",
    "originaccount": "cuenta de origen",
    "destinationaccount": "cuenta de destino",
    "originaccountnumber": "número de cuenta de origen",
    "destinationaccountnumber": "número de cuenta de destino",
    "associatedaccount": "cuenta asociada",
    "number": "número",
    "numbers": "números",
    "credit": "crédito",
    "creditnumber": "número de crédito",
    "creditcard": "tarjeta de crédito",
    "creditcardnumber": "número de tarjeta de crédito",
    "destinationcreditcardnumber": "número de tarjeta de crédito destino",
    "debit": "débito",
    "card": "tarjeta",
    "cardnumber": "número de tarjeta",
    "cardstatus": "estado de tarjeta",
    "loan": "préstamo",
    "investment": "inversión",
    "promissory": "pagaré",
    "note": "pagaré",
    "notes": "pagarés",
    "clabe": "CLABE",
    "amount": "monto",
    "balance": "saldo",
    "principal": "monto principal",
    "currency": "moneda",
    "currencytype": "tipo de moneda",
    # pagos / transferencias
    "payment": "pago",
    "transfer": "transferencia",
    "interbank": "interbancaria",
    "intrabank": "intrabancaria",
    "remittance": "remesa",
    "spei": "SPEI",
    "codi": "CoDi",
    "service": "servicio",
    "services": "servicios",
    # organización
    "company": "empresa",
    "companyname": "nombre de empresa",
    "companynumber": "número de empresa",
    "branch": "sucursal",
    "invoicebranch": "sucursal de facturación",
    "foliosuc": "folio de sucursal",
    "virtual": "virtual",
    "virtualbranch": "sucursal virtual",
    # solicitudes / tipos
    "type": "tipo",
    "paymenttype": "tipo de pago",
    "operationtype": "tipo de operación",
    "currencytype": "tipo de moneda",
    "balancetype": "tipo de saldo",
    "producttype": "tipo de producto",
    # paginación / registros
    "requestedpage": "página solicitada",
    "requested": "solicitado",
    "page": "página",
    "records": "registros",
    "requestedrecordsnumber": "número de registros solicitados",
    "requestednumber": "número solicitado",
    "requesteddays": "días solicitados",
    "days": "días",
    # códigos y folio
    "code": "código",
    "folio": "folio",
    "transactionnumber": "número de transacción",
    "applicationnumber": "número de solicitud",
    "transaction": "transacción",
    "operation": "operación",
    # regulatorio
    "uniquepopulationregistrycode": "CURP",
    "curp": "CURP",
    "rfc": "RFC",
    "populationregistrycode": "código de registro de población",
    "nip": "NIP",
    "otp": "OTP",
    "channel": "canal",
    "response": "respuesta",
    # device
    "manufacture": "fabricante",
    "manufacturer": "fabricante",
    "model": "modelo",
    "device": "dispositivo",
    "version": "versión",
    # misc
    "origin": "origen",
    "destination": "destino",
    "concept": "concepto",
    "description": "descripción",
    "date": "fecha",
    "key": "clave",
    "token": "token",
    "customerId": "identificador de cliente",
    "customernames": "nombres del cliente",
    "customername": "nombre del cliente",
    "customeremail": "correo del cliente",
    "originCustomerNumber": "número de cliente de origen",
    "origincustomernumber": "número de cliente de origen",
    # tokens adicionales
    "payer": "pagador",
    "return": "devolución",
    "discharge": "descuento",
    "register": "registro",
    "beneficiary": "beneficiario",
    "source": "origen",
    "send": "envío",
    "close": "cierre",
    "open": "apertura",
    "apply": "aplicación",
    "confirm": "confirmación",
    "total": "total",
    "available": "disponible",
    "active": "activo",
    "inactive": "inactivo",
    "new": "nuevo",
    "update": "actualización",
    "save": "guardado",
    "get": "obtención",
    "limit": "límite",
    "max": "máximo",
    "min": "mínimo",
    "all": "total",
    "list": "lista",
    "detail": "detalle",
    "details": "detalles",
    "summary": "resumen",
    "info": "información",
    "data": "datos",
    "number": "número",
    "numbers": "números",
}

# ── Annotation → descripción de restricción ──────────────────────────────────

ANNOT_CONSTRAINT = {
    "@NotNull":       "es obligatorio",
    "@NotEmpty":      "no puede estar vacío",
    "@NotBlank":      "no puede estar en blanco",
    "@Max":           "tiene valor máximo",
    "@Min":           "tiene valor mínimo",
    "@DecimalMin":    "tiene valor mínimo",
    "@DecimalMax":    "tiene valor máximo",
    "@Size":          "tiene restricción de tamaño",
    "@Pattern":       "debe cumplir un patrón de formato",
    "@Email":         "debe ser un correo electrónico válido",
    "@Valid":         "debe superar validación de estructura",
    "@Positive":      "debe ser un valor positivo",
    "@NotNegative":   "no puede ser negativo",
    "@Range":         "tiene rango permitido",
}

# ── Sufijos de clase a ignorar ────────────────────────────────────────────────

CLASS_SUFFIXES_SKIP = {
    "Request", "Response", "Model", "Dto", "VO", "Bean",
    "Entity", "Info", "Data", "Object", "Form",
    "Feign", "Client", "Service", "Business", "Component",
    "Impl", "Helper", "Util", "Manager", "Handler",
}

# ── MSA domain keywords → español ────────────────────────────────────────────

MSA_TOKEN_MAP = {
    "codi": "CoDi",
    "spei": "SPEI",
    "transfer": "transferencia",
    "intrabank": "intrabancaria",
    "interbank": "interbancaria",
    "payment": "pago",
    "payments": "pagos",
    "card": "tarjeta",
    "credit": "crédito",
    "deposit": "depósito",
    "deposits": "depósitos",
    "account": "cuenta",
    "opening": "apertura",
    "investment": "inversión",
    "promissory": "pagaré",
    "level": "nivel",
    "digital": "digital",
    "customer": "cliente",
    "identity": "identidad",
    "validation": "validación",
    "data": "datos",
    "session": "sesión",
    "management": "gestión",
    "security": "seguridad",
    "otp": "OTP",
    "remittance": "remesas",
    "services": "servicios",
    "servicing": "operaciones",
    "loan": "crédito",
    "movements": "movimientos",
    "transactions": "transacciones",
    "register": "registro",
    "registration": "registro",
    "repayment": "devolución",
    "return": "devolución",
    "returns": "devoluciones",
    "two": "dos",
    "three": "tres",
    "apply": "aplicar",
    "application": "aplicación",
    "agreement": "acuerdo",
    "configuration": "configuración",
    "frequency": "frecuencia",
    "frequent": "frecuente",
    "atm": "cajero",
    "portfolios": "portafolios",
    "portfolio": "portafolio",
    "products": "productos",
    "product": "producto",
    "inquiry": "consulta",
    "balance": "saldo",
    "detail": "detalle",
    "details": "detalles",
}

# ── Helpers ──────────────────────────────────────────────────────────────────

def split_camel(name):
    """'debitAccountNumbers' → ['debit', 'Account', 'Numbers']"""
    return re.sub(r"([A-Z])", r" \1", name).strip().split()


def field_to_es(field_name):
    """Convierte nombre de campo camelCase a descripción en español."""
    lower = field_name.lower()
    # 1. Compound map — máxima prioridad (evita problemas de orden idiomático)
    if lower in COMPOUND_MAP:
        return COMPOUND_MAP[lower]
    # 2. Token map directo
    if lower in TOKEN_MAP:
        return TOKEN_MAP[lower]
    # 3. Partir en palabras y traducir token a token
    words = split_camel(field_name)
    parts = []
    i = 0
    while i < len(words):
        # Intentar match de 3 palabras juntas
        if i + 2 < len(words):
            three = (words[i] + words[i + 1] + words[i + 2]).lower()
            if three in COMPOUND_MAP:
                parts.append(COMPOUND_MAP[three])
                i += 3
                continue
        # Intentar match de 2 palabras juntas
        if i + 1 < len(words):
            two = (words[i] + words[i + 1]).lower()
            if two in COMPOUND_MAP:
                parts.append(COMPOUND_MAP[two])
                i += 2
                continue
            if two in TOKEN_MAP:
                parts.append(TOKEN_MAP[two])
                i += 2
                continue
        token = TOKEN_MAP.get(words[i].lower(), words[i].lower())
        parts.append(token)
        i += 1
    return " ".join(parts)


def class_to_context(cls_name):
    """'OpenCustomerAccountRequest' → 'apertura de cuenta de cliente'"""
    # Quitar sufijos comunes
    for sfx in sorted(CLASS_SUFFIXES_SKIP, key=len, reverse=True):
        if cls_name.endswith(sfx):
            cls_name = cls_name[: -len(sfx)]
            break
    if not cls_name:
        return ""
    words = split_camel(cls_name)
    parts = []
    for w in words:
        parts.append(MSA_TOKEN_MAP.get(w.lower(), w.lower()))
    return " ".join(parts)


def msa_to_context(msa):
    """'msach-b-business-codi-transactions' → 'transacciones CoDi'"""
    # Quitar prefijo msaXX-X-{domain|business}-
    m = re.match(r"msa\w\w-\w-(?:business|domain|security|channel|processing|servicing)-(.+)", msa)
    slug = m.group(1) if m else msa
    tokens = re.split(r"[-_]", slug)
    parts = []
    for t in tokens:
        parts.append(MSA_TOKEN_MAP.get(t.lower(), t.lower()))
    return " ".join(parts)


def extract_annotation(code):
    """Retorna la anotación principal del fragmento de código."""
    m = re.match(r"(@\w+)", code.strip())
    return m.group(1) if m else "@NotNull"


def extract_field(code):
    """Retorna el nombre del campo Java del fragmento."""
    # Patrón: ... private|protected [Type] fieldName; (soporta List<@Valid Type>)
    m = re.search(r"(?:private|protected)\s+[\w<>@\[\],\s]+?\s+(\w+)\s*[;,]", code)
    return m.group(1) if m else ""


# ── Nombrador ANOTACIÓN ───────────────────────────────────────────────────────

def name_annotation(rule):
    code = rule.get("code", "")
    sp = rule.get("sp", "")
    parts = sp.split(":")
    cls = parts[1] if len(parts) > 1 else ""

    annot = extract_annotation(code)
    field = extract_field(code)
    if not field:
        return None

    field_es = field_to_es(field)
    constraint = ANNOT_CONSTRAINT.get(annot, "tiene restricción de validación")
    ctx = class_to_context(cls)

    # Concordancia gramatical: plurales (campo original en inglés termina en 's')
    is_plural = field.endswith("s") and not field.endswith("ss")
    if is_plural:
        constraint = (constraint
                      .replace("es obligatorio", "son obligatorios")
                      .replace("no puede estar vacío", "no pueden estar vacíos")
                      .replace("no puede estar en blanco", "no pueden estar en blanco")
                      .replace("tiene restricción de tamaño", "tienen restricción de tamaño")
                      .replace("debe superar validación de estructura", "deben superar validación de estructura"))

    name = f"{field_es.capitalize()} {constraint}"
    if ctx:
        name += f" ({ctx})"
    return name


# ── Nombrador UMBRAL Java ─────────────────────────────────────────────────────

def name_umbral_java(rule):
    code = rule.get("code", "")
    annot = extract_annotation(code)
    field = extract_field(code)
    field_es = field_to_es(field) if field else "campo"
    constraint = ANNOT_CONSTRAINT.get(annot, "tiene restricción de rango")
    name = f"{field_es.capitalize()} {constraint}"
    return name


# ── Nombrador de PROPERTIES (CONFIGURACIÓN + UMBRAL props + CÓDIGO_ERROR) ─────

def name_property(rule):
    code = rule.get("code", "")
    sp = rule.get("sp", "")
    msa = sp.split(":")[0]

    # split key = value  o  key : value
    m = re.match(r"^([\w.\-]+)\s*[=:]\s*(.*)$", code.strip())
    if not m:
        return None
    key = m.group(1).strip()
    value = m.group(2).strip()

    # Hystrix timeouts
    if "hystrix" in key and "timeout" in key.lower():
        try:
            ms = int(re.sub(r"\D", "", value))
            secs = ms // 1000
            return f"Timeout de Hystrix: {ms:,} ms ({secs} s)"
        except ValueError:
            return f"Timeout de Hystrix: {value}"

    # Timeouts genéricos
    if re.search(r"timeout", key, re.I) and "hystrix" not in key:
        try:
            ms = int(re.sub(r"\D", "", value))
            label = "asíncrono" if "async" in key else "del API"
            return f"Timeout {label}: {ms:,} ms"
        except ValueError:
            return f"Timeout: {value}"

    # Ribbon timeouts
    if "ribbon" in key and ("read" in key.lower() or "connect" in key.lower()):
        label = "de lectura" if "read" in key.lower() else "de conexión"
        try:
            ms = int(re.sub(r"\D", "", value))
            return f"Timeout Ribbon {label}: {ms:,} ms"
        except ValueError:
            return f"Timeout Ribbon {label}: {value}"

    # Headers de validación
    if "validate.headers" in key:
        if "validateMessagesVersion" in key or "messagesVersion" in key:
            return f"Headers requeridos para validación de versión de mensaje: {value}"
        if "generalHeaders" in key:
            return f"Headers HTTP generales requeridos: {value}"
        return f"Headers HTTP requeridos para validación: {value}"

    if "errorResolver.validate.headers" in key or "errorResolver.headers" in key:
        return f"Headers validados para resolución de errores: {value}"

    # Constantes de API
    if "constants.api.codes" in key:
        code_key = key.split(".")[-1].upper()
        return f"Código de respuesta {code_key}: {value}"

    if "constants.api.namespace" in key:
        return f"Namespace del API: {value}"

    if "constants.api.timeout" in key:
        label_key = key.split(".")[-1]
        label = "asíncrono" if "async" in label_key.lower() else label_key
        try:
            ms = int(re.sub(r"\D", "", value))
            return f"Timeout {label}: {ms:,} ms"
        except ValueError:
            return f"Timeout {label}: {value}"

    if re.match(r"constants\.api\.", key):
        prop = key.replace("constants.api.", "").replace(".", " ").replace("-", " ")
        return f"Configuración API — {prop}: {value}"

    # Eureka / descubrimiento de servicios
    if "eureka" in key.lower():
        return f"Configuración Eureka — {key.split('.')[-1]}: {value}"

    # Feign client
    if "feign" in key.lower():
        return f"Configuración Feign Client — {key.split('.')[-1]}: {value}"

    # Spring datasource
    if "spring.datasource" in key:
        prop = key.replace("spring.datasource.", "")
        return f"Datasource — {prop}: {value}"

    # Logging
    if "logging.level" in key:
        pkg = key.replace("logging.level.", "")
        return f"Nivel de logging para {pkg}: {value}"

    # Management / actuator
    if "management." in key:
        return f"Configuración de monitoreo — {key.split('.')[-1]}: {value}"

    # CoDi / SPEI / pagos
    if any(k in key.lower() for k in ["spei", "codi", "cecoban"]):
        return f"Configuración SPEI/CoDi — {key.split('.')[-1]}: {value}"

    # Error codes: constants.{system}.codes.*
    if re.match(r"constants\.\w+\.codes\.", key):
        code_label = key.split(".")[-1].upper()
        return f"Código de error {code_label}: {value}"

    # Genérico: limpiar la clave y armar descripción
    prop_human = re.sub(r"[.\-_]", " ", key).strip()
    if len(value) > 80:
        value = value[:77] + "..."
    return f"Configuración: {prop_human} = {value}"


# ── Dispatcher ────────────────────────────────────────────────────────────────

TIPO_ANOT = "ANOTACI\xd3N"   # ANOTACIÓN
TIPO_CONF = "CONFIGURACI\xd3N"  # CONFIGURACIÓN
TIPO_VALID = "VALIDACI\xd3N"  # VALIDACIÓN
TIPO_UMBRAL = "UMBRAL"
TIPO_CERR = "C\xd3DIGO_ERROR"  # CÓDIGO_ERROR


def enrich_rule(rule):
    tipo = rule.get("tipo", "")
    sf = rule.get("source_file", "")

    if tipo == TIPO_ANOT:
        return name_annotation(rule)

    if tipo == TIPO_CONF:
        return name_property(rule)

    if tipo == TIPO_CERR:
        return name_property(rule)

    if tipo == TIPO_UMBRAL:
        if sf.endswith(".java"):
            return name_umbral_java(rule)
        else:
            return name_property(rule)

    # VALIDACIÓN → skip (scatter-gather)
    return None


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    rules = json.loads(RULES_PATH.read_text(encoding="utf-8"))

    overrides = {}
    stats = {
        "total": len(rules),
        "enriched": 0,
        "skipped_validacion": 0,
        "failed": 0,
    }
    tipo_counts = {}

    for rule in rules:
        rule_id = rule.get("id", "")
        tipo = rule.get("tipo", "")

        name = enrich_rule(rule)

        if name is None:
            if tipo == TIPO_VALID:
                stats["skipped_validacion"] += 1
            else:
                stats["failed"] += 1
            continue

        if not name.strip():
            stats["failed"] += 1
            continue

        overrides[rule_id] = name
        stats["enriched"] += 1
        tipo_counts[tipo] = tipo_counts.get(tipo, 0) + 1

    # Guardar overrides
    OVERRIDES_OUT.parent.mkdir(parents=True, exist_ok=True)
    OVERRIDES_OUT.write_text(
        json.dumps(overrides, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    print(f"=== Enriquecimiento heurístico AppMovil ===")
    print(f"Total reglas : {stats['total']:,}")
    print(f"Enriquecidas : {stats['enriched']:,}")
    print(f"VALIDACIÓN   : {stats['skipped_validacion']:,} (scatter-gather pendiente)")
    print(f"Fallidas     : {stats['failed']:,}")
    print()
    print("Por tipo:")
    for t, n in sorted(tipo_counts.items()):
        print(f"  {t:20s} : {n:,}")
    print()
    print(f"Overrides guardados en: {OVERRIDES_OUT}")


if __name__ == "__main__":
    main()