# DT — Integraciones R4 (Inventario)
> Digital Twin del inventario de integraciones del Programa Unity R4.
> Fuente primaria: `Inventario de Integraciones_HUs_ R4_v1.0.xlsx` (Accenture, agosto 2026)
> Última actualización: 2026-08-20 · v1.0.0

---

## Resumen

| Campo | Valor |
|-------|-------|
| Total integraciones | 18 |
| Tracks cubiertos | APP (4), CAT (7), SmartVista (7) |
| Tipo API | 15 |
| Tipo Batch | 2 |
| Tipo Evento | 1 |
| Estado Nueva | 9 |
| Estado Modificar | 9 |

> **Importante:** Este inventario cubre solo las integraciones identificadas en las sesiones de análisis de HUs.
> **No cubre** integraciones del track APOLO (17 DTMs catalogados en `dt-apolo.md`), ni del track SIWEB.
> Los 17 DTMs de Apolo son la fuente canónica para las integraciones de onboarding digital.

---

## Integraciones por Track

### Track APP — 4 integraciones

Todas API REST, tiempo real. 3 modificaciones de APIs existentes + 1 nueva (notificación CES).

| ID | HU | Nombre | Sistema Origen | Sistema Destino | Tipo | Estado | Complejidad | Existe Hoy |
|----|-----|--------|---------------|----------------|------|--------|-------------|-----------|
| IAPP01 | SMART-3962 | CAMBIOS detalle TDC `Rec_retrieveCreditCardStatement` | APP | SMARTVISTA | API | Modificar | Media | Sí |
| IAPP02 | SMART-4183 | Pago TDC `Rec_executeCardPaymentTransaction` | SMARTVISTA | APP | API | Modificar | Alta | Sí |
| IAPP03 | SMART-4176 | Consulta movimientos `Rec_RetrieveAccountTransaction` | SMARTVISTA | APP | API | Modificar | Media | Sí |
| IAPP05 | SMART-4105 | Notificación activación Tarjeta Digital | APP | CES | API | Nueva | Media | No |

> IAPP04 no existe en el inventario fuente — posible gap de numeración. Confirmar con Nova Solution Systems.

---

### Track CAT — 7 integraciones

6 APIs REST + 1 Evento. 6 nuevas + 1 modificación. CAT aún **no tiene proveedor contratado** (RISK-UNITY-R27).

| ID | HU | Nombre | Sistema Origen | Sistema Destino | Tipo | Estado | Complejidad | Existe Hoy |
|----|-----|--------|---------------|----------------|------|--------|-------------|-----------|
| ICAT01 | HDU-CAT-R4-01 | Consulta de clientes SmartVista | IVR | SMARTVISTA | API | Nueva | Media | No |
| ICAT02 | HDU-CAT-R4-01 | Consulta cliente por cuenta SmartVista | IVR | SMARTVISTA | API | Nueva | Media | No |
| ICAT03 | HDU-CAT-R4-02 | Canalizar al cliente SmartVista con ejecutivo | IVR - Robot | IVR - CC | Evento | Modificar | Baja | Sí |
| ICAT04 | HDU-CAT-R4-08 | Consulta saldos y movimientos SmartVista por IVR | IVR | SMARTVISTA | API | Nueva | Alta | No |
| ICAT05 | HDU-CAT-R4-05 | Bloqueo de tarjeta SmartVista por CAT | ICCAT | SMARTVISTA | API | Nueva | Media | No |
| ICAT06 | HDU-CAT-R4-06 | Desbloqueo de tarjeta SmartVista por CAT | ICCAT | SMARTVISTA | API | Nueva | Media | No |
| ICAT07 | HDU-CAT-R4-11 | Consultar productos y estatus de tarjetas SmartVista | ICCAT | SMARTVISTA | API | Nueva | Media | No |

> **Bloqueo:** CAT sin proveedor contratado. Si el proveedor no firma antes del 2026-08-31, las 6 integraciones
> nuevas de CAT quedan sin responsable técnico. Ver RISK-UNITY-R27.

---

### Track SmartVista — 7 integraciones

5 APIs + 2 Batch. 2 nuevas + 5 modificaciones. Las 2 Batch son la interfaz de maquila (archivos PGP diarios).

| ID | HU | Nombre | Sistema Origen | Sistema Destino | Tipo | Estado | Complejidad | Existe Hoy |
|----|-----|--------|---------------|----------------|------|--------|-------------|-----------|
| ISV01 | HDU-SMART-R4-06 | Interfaz temporal de maquila #6 (descarga nube → on-premise) | AWS | OLTP-Informix | Batch | Nueva | Baja | No |
| ISV02 | HDU-SMART-R4-06 | AFT — Transferencia archivo maquila | OLTP-Informix | Connect Direct | Batch | Modificar | Baja | Sí |
| ISV03 | HDU-SMART-R4-08 | Consulta de lotes (por sucursal y lote) | SIWEB | SMARTVISTA | API | Modificar | Baja | Sí |
| ISV04 | HDU-SMART-R4-10 | Visualización nombres normativos de comisiones — SIWEB | SMARTVISTA | SIWEB | API | Modificar | Media | Sí |
| ISV05 | HDU-SMART-R4-10 | Visualización nombres normativos de comisiones — APP | SMARTVISTA | APP | API | Modificar | Media | Sí |
| ISV06 | HDU-SMART-R4-19 | GetDPP — Selección de transacciones (DPP) | SMARTVISTA | SIWEB | API | Nueva | Media | No |
| ISV07 | HDU-SMART-R4-19 | Clearing Operation — Pago Anticipado | SMARTVISTA | SIWEB | API | Modificar | Media | Sí |

> **Nota maquila:** ISV01 e ISV02 corresponden a la interfaz temporal de generación de archivos para
> maquiladores de plástico (HDU-SMART-R4-06). ISV01 es la descarga desde AWS S3 al on-premise;
> ISV02 es la transferencia vía Connect Direct ya existente. El canal Maquila (OCG/Cargen) no tenía
> integraciones digitales — solo batch diario.

---

## Gaps de Cobertura

| Gap | Track | Descripción |
|-----|-------|-------------|
| APOLO no incluido | Apolo | Los 17 DTMs de Apolo (onboarding digital) no están en este inventario. Ver `dt-apolo.md` |
| SIWEB no incluido | SIWEB | Solo 2 de las 5 HUs SIWEB generan integraciones (ISV03, ISV04). Las otras 3 SIWEB HUs no tienen integración registrada |
| Cobranza no incluida | Cobranza Direccionada | Las 37-50 User Stories de Cobranza no tienen inventario de integraciones R4 |
| IAPP04 faltante | APP | El ID IAPP04 no aparece en el inventario. Posible supresión o reclasificación |

---

## Mapa de Sistemas Integrados

```
APP ──────────────────► SMARTVISTA   (IAPP01, IAPP03 retorno, IAPP02 retorno)
APP ──────────────────► CES          (IAPP05 notificación)
SMARTVISTA ──────────► APP           (ISV05 comisiones)
SMARTVISTA ──────────► SIWEB         (ISV04 comisiones, ISV06 DPP, ISV07 Clearing)
SIWEB ───────────────► SMARTVISTA    (ISV03 lotes)
IVR ─────────────────► SMARTVISTA    (ICAT01, ICAT02, ICAT04)
IVR-Robot ───────────► IVR-CC        (ICAT03 enrutamiento)
ICCAT ───────────────► SMARTVISTA    (ICAT05 bloqueo, ICAT06 desbloqueo, ICAT07 consulta)
AWS ─────────────────► OLTP-Informix (ISV01 maquila batch)
OLTP-Informix ───────► Connect Direct (ISV02 AFT batch)
```

> El sistema central de todas las integraciones R4 es **SMARTVISTA** (10 de 18 integraciones).
> Informix aparece como origen/destino solo en las integraciones de maquila (Batch, EOD).

---

## Pendientes

- [ ] Validar IAPP04 faltante con Nova Solution Systems
- [ ] Inventariar integraciones de Cobranza Direccionada (no están en v1.0)
- [ ] Confirmar sistemas detrás de "CES" (IAPP05 destino) — ¿CES = CES BanCoppel o servicio externo?
- [ ] Validar SIWEB: de 5 HUs solo 2 generan integraciones — ¿las otras 3 son solo configuración?
- [ ] Actualizar inventario cuando CAT tenga proveedor contratado (hoy: sin responsable técnico)

---

*Creado: 2026-08-20 · v1.0.0 · Fuente: `Inventario de Integraciones_HUs_ R4_v1.0.xlsx`*
