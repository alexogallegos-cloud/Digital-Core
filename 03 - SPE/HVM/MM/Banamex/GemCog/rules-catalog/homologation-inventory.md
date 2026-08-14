# Inventario de Homologación — rules-catalog/ (Ola 1)
> Estado AS-IS de los 33 archivos de reglas antes de aplicar el schema canónico.
> Base: greps de discriminadores de formato + program-registry-s500/s151 + conteo de encabezados `RN-`.
> Creado: 2026-07-24 · gobernado por swarm/dt-knowledge-curator.

---

## 1. Totales

| Métrica | Valor |
|---------|-------|
| Archivos de reglas | 33 (12 S500 · 21 S151) |
| Reglas (encabezados `## / ### RN-`) | **1,550** (558 S500 · 992 S151) |
| Variantes de schema conviviendo | 3 |
| Archivos sin campo `Capacidad bancaria` | 5 (requieren inyección de bian_ref desde registry) |
| Archivos con campo `Identificador` | 19 · con `Sistema` | 14 |

---

## 2. Lookup programa → BC-ID (llaveado por sistema)

La fuente de verdad del lookup son los dos registries; no se duplica aquí. Reglas de uso:

- **Llave compuesta `(sistema, programa)`** — no solo programa.
- **Colisión conocida:** `P109` → S500 = **BC-05** (Depósitos, BAJA) · S151 = **BC-13** (Finance GL). También `P108`, `P130`, `P131`, `P178`, `P199`, `P120`, `P050`, `P052` existen en ambos sistemas con rol distinto.
- **Inyección por regla, no por archivo** — un archivo multi-programa (ej. `movimientos.md`, 20 programas) reparte varios BC-ID.
- Fuentes: [program-registry-s500.md](program-registry-s500.md) (77 prog) · [program-registry-s151.md](program-registry-s151.md) (75 prog).
- **Programas en registry no cubiertos por reglas** o **reglas cuyo programa no está en registry** → gap de Ola 1, se listan en §5.

---

## 3. Inventario por archivo

Leyenda de esfuerzo mecánico (Ola 3):
- **MEC** — remap directo de campos + inyección BC-ID (tiene Identificador + Capacidad bancaria).
- **MEC+REF** — remap + inyección de BC-ID **y** bian_ref desde registry (falta Capacidad bancaria o usa campo `Sistema`).

Leyenda de enriquecimiento (Ola 4):
- **SRC** — contiene programas BAJA / descripción genérica / evidencia `~aprox` → re-lectura de fuente por dt-mainframe-analyst.
- **SME** — rationale o reclasificación BC-ID pendiente de SME.

### S500 (12 archivos · 558 reglas)

| Archivo | Reglas | ID-field | Cap.bancaria | Mecánico | Enriquec. |
|---------|--------|----------|--------------|----------|-----------|
| rules-s500.md | 78 | Sistema | sí (mixto) | MEC+REF | SRC (P655 · mezcla interna Base reg/Regulador) |
| rules-s500-deposits-a.md | 42 | Identificador | sí | MEC | SRC (P170/P127/P115 BAJA) |
| rules-s500-deposits-b-interest.md | 70 | Identificador | sí | MEC | SRC (P107/P117/P168 BAJA) |
| rules-s500-payments-statements.md | 60 | Identificador | sí | MEC | SRC (P155/P176/P174/P161/P179 BAJA) |
| rules-s500-financial-servicing.md | 54 | Identificador | sí | MEC | SME (P105/P180/P120/P102 pendiente SME) |
| rules-s500-reconciliation.md | 56 | Identificador | sí | MEC | SRC (P190/P055/P200/P188 BAJA) |
| rules-s500-p020-p142-p144.md | 45 | Identificador | sí | MEC | — (ALTA) |
| rules-s500-p010-p110.md | 44 | Identificador | sí | MEC | SRC (P110 MEDIA) |
| rules-s500-p130.md | 29 | Identificador | sí | MEC | — (ALTA) |
| rules-s500-s151registra-p103fraude.md | 30 | Identificador | sí | MEC | — (ALTA) |
| rules-s500-p310.md | 20 | Identificador | sí | MEC | SRC (P310 MEDIA) |
| rules-s500-algol-wfl-stubs.md | 30 | Identificador | sí | MEC | arquitectura (RETAIN — no BC negocio) |

### S151 (21 archivos · 992 reglas)

| Archivo | Reglas | ID-field | Cap.bancaria | Mecánico | Enriquec. |
|---------|--------|----------|--------------|----------|-----------|
| rules-s151.md | 40 | Sistema | **no** | MEC+REF | SRC (P109 evidencia ~aprox → línea exacta) |
| rules-s151-movimientos.md | 190 | Identificador | sí | MEC | SRC+SME (19 prog, muchos BAJA: P001/P011-017/P025/P071/P073/P090) |
| rules-s151-contabilidad-a.md | 73 | Identificador | sí | MEC | SRC (P167/P169/P172/P177 BAJA) |
| rules-s151-contabilidad-b.md | 71 | Identificador | sí | MEC | SRC (P168/P171/P170/P194-197 BAJA) |
| rules-s151-p199-p600.md | 70 | Sistema | sí | MEC+REF | — (ALTA RPT) |
| rules-s151-p108-p150.md | 60 | Sistema | sí | MEC+REF | — (ALTA) |
| rules-s151-l002r3-r4-r5.md | 57 | Sistema | sí | MEC+REF | arquitectura (BC-04 ACL — no BC negocio) |
| rules-s151-p655-p670-p671-p680-p690.md | 42 | Identificador | sí | MEC | SRC (P655 DEFECTO-PROD) |
| rules-s151-p130-p131.md | 42 | Identificador | sí | MEC | — (ALTA CFR) |
| rules-s151-p050-p052.md | 40 | Sistema | sí | MEC+REF | — (ALTA HLD) |
| rules-s151-p602-p606-p620-p630.md | 40 | Identificador | sí | MEC | — (ALTA) |
| rules-s151-p312-p330-p360.md | 37 | Sistema | sí | MEC+REF | — (ALTA BC-09, ya BC-tagged) |
| rules-s151-dasdl.md | 35 | Sistema | **no** | MEC+REF | — (esquemas DMSII) |
| rules-s151-p010.md | 32 | Sistema | sí | MEC+REF | — (ALTA gateway) |
| rules-s151-p151.md | 30 | Sistema | **no** | MEC+REF | — (ALTA CITI) |
| rules-s151-p158.md | 30 | Sistema | **no** | MEC+REF | — (ALTA STA) |
| rules-s151-l030.md | 25 | Identificador | sí | MEC | arquitectura (librería) |
| rules-s151-p021-p120.md | 24 | Sistema | sí | MEC+REF | — (ALTA) |
| rules-s151-p112.md | 20 | Sistema | **no** | MEC+REF | — (ALTA punteo) |
| rules-s151-p178-p138.md | 20 | Sistema | sí | MEC+REF | — (ALTA) |
| rules-s151-algol-wfl-stubs.md | 14 | Identificador | sí | MEC | arquitectura (RETAIN) |

---

## 4. Resumen de esfuerzo

| Bucket | Archivos | Reglas aprox |
|--------|----------|--------------|
| MEC (remap directo) | 18 | ~880 |
| MEC+REF (remap + inyección bian_ref) | 15 | ~670 |
| Enriquecimiento SRC (re-lectura fuente) | ~14 archivos | subconjunto de reglas BAJA |
| Enriquecimiento SME (rationale/reclasificación) | 2 (s500-financial-servicing, s151-movimientos) | programas 6.6.1 + BAJA S151 |
| Arquitectura (no BC negocio, RETAIN/ACL) | 4 (algol-wfl-stubs ×2, l002, l030) | ~126 |

**Los 5 archivos sin `Capacidad bancaria`** (bian_ref 100% desde registry): rules-s151.md, p112, p151, p158, dasdl.

---

## 5. Gaps de Ola 1 a resolver antes de Ola 3

1. **Cruce completo programa↔registry**: verificar que cada programa citado en los 33 archivos existe en el registry de su sistema. Programas huérfanos (regla sin BC-ID derivable) → `Consulta SME Mainframe Migration`.
2. **Colisiones de nombre** (P109, P108, P130…): el script debe resolver por el `Sistema` de cada archivo/regla, no por nombre.
3. **rules-s500.md mezcla interna** Base regulatoria + Regulador → normalizar ambos a Regulador.
4. **Programas 6.6.1 (BC-05\*)** en financial-servicing: 5 pendientes de SME (P105/P180/P120/P102/P046) — no bloquean el remap mecánico, sí el veredicto.

---

## 6. Orden recomendado de ejecución (Ola 3, por lotes)

| Lote | Archivos | Razón |
|------|----------|-------|
| L1 (piloto script) | rules-s151.md | ya tiene RN-S151-034 validado; valida MEC+REF y colisión P109 |
| L2 | S500 ALTA (p020-p142-p144, p130, s151registra, p010-p110) | menor riesgo, valida MEC |
| L3 | S151 BC-tagged ALTA (p312-p330-p360, p130-p131, p050-p052, p108-p150, p199-p600) | MEC+REF sobre ALTA |
| L4 | S151 sin Cap.bancaria (p112, p151, p158, dasdl) | MEC+REF puro desde registry |
| L5 | BAJA-heavy (movimientos, contabilidad-a/b, S500 deposits/payments/reconciliation) | requieren SRC en paralelo |
| L6 | arquitectura (algol-wfl-stubs, l002, l030) | schema reducido, sin BC negocio |

Cada lote: correr script → `build-traceability.py` → revisar diff → commit.

---

*Ola 1 · Inventario · Creado 2026-07-24 · Siguiente: Ola 2 (actualizar parsers + script de homologación + dry-run)*
