# D13 · Transferencias Electrónicas de Fondos (TEF) — Catálogo de Procesos de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- SME — Core Banking Transformation (`Delivery - SME/Core Banking Transformation/`)
- SME — DBA IBM Informix (`Delivery - SME/DBA IBM Informix/`)
- SME Regulatorio — CNBV (`SME/Regulatory/CNBV/`) — SPEI, transferencias interbancarias
- SME Regulatorio — CONDUSEF (`SME/Regulatory/CONDUSEF/`) — reclamaciones de transferencias

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert de BanCoppel antes de pasar a BUILD.
---

## Rol del dominio

`bditef` es la base de datos que sostiene las **Transferencias Electrónicas de Fondos** de BanCoppel. Opera el ciclo completo de vida de una transferencia: registro, validación de horario hábil, envío al sistema externo TEF/CECOBAN, procesamiento de archivos de cámara (formatos 10, 60, 61, 62, 63), recepción, devoluciones y reversos. Tiene dependencia funcional alta con `bdicheq` (cheques) y se considera hermano técnico de D08-bdispei (SPEI).

**139 SPs** en el dominio: 68 en el callgraph activo y 71 aislados (riesgo de funcionalidad no mapeada).

---

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D13-01 | Registro de operación TEF (envío) | `sp_tef_grabaoperacion` | Orquestador | CNBV |
| BP-D13-02 | Registro de operación TEF (canal legacy) | `sp_grabaoperaciontef` | Orquestador | CNBV |
| BP-D13-03 | Reverso de operación TEF | `sp_tef_reversoperacion` | Orquestador | CNBV · CONDUSEF |
| BP-D13-04 | Presentación de cheques en cámara (generador) | `sp_tef_presentador_g` | Orquestador | CNBV |
| BP-D13-05 | Presentación de cheques en cámara (receptor) | `sp_tef_presentador_r` | Orquestador | CNBV |
| BP-D13-06 | Recepción de archivos de cámara (generador) | `sp_tef_receptor_g` | Orquestador | CNBV |
| BP-D13-07 | Recepción de archivos de cámara (receptor) | `sp_tef_receptor_r` | Orquestador | CNBV |
| BP-D13-08 | Procesamiento de archivo cámara formato 10 | `sp_tef_procesararchivo10` | Batch | CNBV |
| BP-D13-09 | Procesamiento de archivo cámara formato 60 | `sp_tef_procesararchivo60` | Batch | CNBV |
| BP-D13-10 | Procesamiento de archivo cámara formato 61 | `sp_tef_procesararchivo61` | Batch | CNBV |
| BP-D13-11 | Procesamiento de archivo cámara formato 62 | `sp_tef_procesararchivo62` | Batch | CNBV |
| BP-D13-12 | Procesamiento de archivo cámara formato 63 | `sp_tef_procesararchivo63` | Batch | CNBV |
| BP-D13-13 | Generación de archivo cámara formato 60 | `sp_tef_generararchivo60` | Batch | CNBV |
| BP-D13-14 | Generación de archivo cámara formato 62 | `sp_tef_generararchivo62` | Batch | CNBV |
| BP-D13-15 | Generación de archivo cámara formato 63 | `sp_tef_generararchivo63` | Batch | CNBV |
| BP-D13-16 | Validación de horario hábil TEF | `sp_tef_validahorario` | Servicio | CNBV |
| BP-D13-17 | Validación de recepción de archivos | `sp_tef_validarecepcion` | Servicio | CNBV |
| BP-D13-18 | Validación de datos de transferencia | `sp_tef_valida_datos` | Servicio | CNBV |
| BP-D13-19 | Consulta de operaciones TEF | `sp_consultarepop_tef` | Servicio |  |
| BP-D13-20 | Consulta de información TEF | `sp_obtenerinformaciontef` | Servicio |  |
| BP-D13-21 | Abono en cuenta (integración cheques) | `abono_cta` | Servicio |  |
| BP-D13-22 | Cargo en cuenta (integración cheques) | `cargo_cta` | Servicio |  |
| BP-D13-23 | Consulta de cheques devueltos Coppel | `cons_dev_coppel` | Servicio |  |
| BP-D13-24 | Consulta de cheques presentados | `cons_presenta` | Servicio |  |
| BP-D13-25 | Consulta devolvuciones externas TEF | `sp_consdevext_tef` | Servicio | CNBV |
| BP-D13-26 | Revisión de operaciones TEF | `sp_revoperacionestef` | Servicio |  |
| BP-D13-27 | Generación de lista negra TEF | `sp_tef_generareplistnegra` | Batch |  |
| BP-D13-28 | Movimiento de registros a histórico | `sp_tef_moverregistroshist` | Batch |  |
| BP-D13-29 | Actualización de estado SICAM | `sp_tef_act_rep_sicam` | Batch | CNBV |
| BP-D13-30 | Validación de imagen de cheque | `sp_validaimagencheque` | Servicio |  |

> Detalle de cadenas de llamadas en `01-journey.md`. Reglas y fórmulas en `04-business-rules.md`. Los 71 SPs aislados no incluidos en este catálogo son candidatos a procesos batch o utilitarios de mantenimiento — requieren análisis adicional.

---

## Agrupación funcional por capacidad BIAN

| Capacidad BIAN | Procesos BP-D13-xx |
|----------------|-------------------|
| Funds Transfer (FT001) — iniciación | BP-D13-01, BP-D13-02, BP-D13-18 |
| Funds Transfer (FT001) — reverso | BP-D13-03 |
| Payment Execution (PE002) — cámara | BP-D13-04 a BP-D13-15 |
| Payment Execution (PE002) — horario | BP-D13-16, BP-D13-17 |
| Account Management (AM003) — integración | BP-D13-21, BP-D13-22 |
| Payment Order (PO004) — consultas | BP-D13-19, BP-D13-20, BP-D13-25, BP-D13-26 |

---

## `[SME-PENDING]`

- [ ] Nombre de negocio oficial de cada proceso (nomenclatura BanCoppel).
- [ ] Frecuencia operativa y criticidad (transacciones/día por proceso).
- [ ] Horario de corte de operaciones TEF con CECOBAN.
- [ ] Confirmación de cuáles SPs aislados son activos en producción vs. código muerto.

---
*Generado por análisis de sp-specs-bditef.md · Etapa 3 · fuente: callgraph + grounding pass*
