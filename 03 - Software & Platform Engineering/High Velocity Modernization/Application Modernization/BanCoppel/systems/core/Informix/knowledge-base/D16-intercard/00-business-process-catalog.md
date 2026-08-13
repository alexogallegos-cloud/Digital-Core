# D16 · Intercard (Tarjetas) — Catálogo de Procesos de Negocio

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `intercard` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **MEDIO-ALTO**
> **Última actualización:** 2026-08-03

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Industry Banking (tarjetas de débito y crédito retail)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Core Banking Transformation (ACL design y API contracts)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)

> Secciones marcadas `[SME-PENDING]` requieren validación antes de BUILD.

---

## Rol del dominio

`intercard` · Wave 4 · 394 SPs. Gestiona el ciclo de vida de tarjetas de débito y crédito BanCoppel: activación, cancelación, bloqueo, consulta y programas de lealtad (Horas Azules). Es un dominio de **servicio** — sus SPs son invocados desde otros dominios (D03 Crédito, D04 Chequera) y desde el canal de atención ICCAT/BPI. No tiene journeys orquestadores de múltiples dominios; cada SP implementa una capacidad puntual del lifecycle de tarjeta.

**Dependencia regulatoria:** CNBV Circular 14/2017 (plazos notificación cancelación) · Banxico (gestión de plásticos).

---

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg | Rules | LOC |
|----|--------------------|----------------|------|:---:|------:|----:|
| BP-D16-01 | Cancelación de tarjeta | `sp_cancelacion_tarjeta` | Servicio expuesto | ✓ | 0 | 57 |
| BP-D16-02 | Activación de tarjeta ICCAT | `sp_activatarjeta_iccat` | Orquestador | | 0 | 941 |
| BP-D16-03 | Consulta de tarjetas débito/crédito ICCAT | `sp_consultartarjetas_debcred_can_iccat` | Orquestador | | 1 | 1,226 |
| BP-D16-04 | Desbloqueo de tarjeta bloqueada por impago | `sp_limpiatarjeta_bloqueada_iccat` | Orquestador | ✓ | 0 | 898 |
| BP-D16-05 | Enrolamiento batch de clientes | `sp_carga_ctes_enrola` | Batch | | 16 | 1,778 |
| BP-D16-06 | Contacto por vencimiento — crédito | `sp_contacto_vencimiento_credito` | Batch | ✓ | 49 | 1,011 |
| BP-D16-07 | Contacto por vencimiento — débito | `sp_contacto_vencimiento_debito` | Batch | ✓ | 46 | 998 |
| BP-D16-08 | Obtención de TDC para Horas Azules | `sp_horasazules_obtener_tdc_clientes` | Servicio expuesto | | 6 | 1,333 |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas en `04-business-rules.md`.

## Observaciones clave

- **BP-D16-01** (`sp_cancelacion_tarjeta`) tiene fan_in=28 — el más invocado del dominio. Su único caller cross-domain registrado es `bdicred:reversion` (D03 Crédito). Muy pequeño (57 LOC) — probablemente un wrapper de actualización de estado.
- **BP-D16-06 y BP-D16-07** son los más ricos en reglas de negocio (49 y 46 respectivamente) y representan el proceso de cobranza preventiva por vencimiento.
- **BP-D16-05** (`sp_carga_ctes_enrola`) con 1,778 LOC es el SP más largo del dominio — batch de carga masiva.
- Los SPs con sufijo `_iccat` están ligados al canal **ICCAT/BPI** (sistema de atención a sucursales) — dependencia externa crítica para Wave 4.

## `[SME-PENDING]`
- [ ] Frecuencia y ventana de ejecución de los batch (BP-D16-05, 06, 07).
- [ ] Clasificación regulatoria de `sp_cancelacion_tarjeta` ante CNBV (Circular 14/2017 plásticos).
- [ ] Volúmenes de producción de BP-D16-01 (fan_in=28 registrado pero solo 1 caller en sp_calls).

---
*Generado: 2026-08-03 · fuente: brain.db intercard (394 SPs) + análisis estático BCOPBrain*
