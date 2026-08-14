# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Journeys y Cadenas de Llamadas

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Contexto de journeys en bdilide

`bdilide` presenta un patrón atípico: de 101 SPs analizados, solo 5 aparecen en el callgraph del sistema (conectados a journeys de otros dominios). Los 96 SPs restantes son aislados y operan como procesos batch autónomos o como lógica de mantenimiento interna al dominio PLD. Esto refleja la naturaleza del motor PLD: la mayoría de su lógica se ejecuta en modo batch nocturno o por disparadores regulatorios, no en el flujo transaccional en línea.

## SPs presentes en el callgraph (5 SPs conectados)

| ID | SP | Dominio llamante | Contexto del call |
|----|----|-----------------|--------------------|
| JRN-D15-01 | `[DATO-REQUERIDO]` | D01-bdicnweb (canal digital) | Verificación LIDE en onboarding de cliente |
| JRN-D15-02 | `[DATO-REQUERIDO]` | D02-bdinteg (integración) | Verificación LIDE en autenticación |
| JRN-D15-03 | `[DATO-REQUERIDO]` | D03-bdicred (crédito) | Consulta LIDE previa al otorgamiento de crédito |
| JRN-D15-04 | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| JRN-D15-05 | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |

> `[DATO-REQUERIDO]` — Los nombres exactos de los 5 SPs presentes en el callgraph deben extraerse del archivo `callgraph-data.json` del proyecto Informix. Solicitar al DBA IBM Informix o al Specialist de análisis estático.

## Journey J15-01: Ejecutor Diario PLD (proceso batch nocturno)

```
[Scheduler / Cron AIX]
        │
        ▼
  ejecutor_diario(pFechaProceso, pCve_Usuario)
        │
        ├── UPDATE si_fechas (bdinteg) ← cross-DB: actualiza fecha de proceso
        ├── UPDATE sd_fechas (bdicred) ← cross-DB: sincroniza fecha crédito
        ├── UPDATE sc_fechas (bdicheq) ← cross-DB: sincroniza fecha cheques
        ├── INSERT sc_movdia (bdicheq) ← cross-DB: registra movimiento del día
        ├── SELECT sc_movhis (bdicheq) ← cross-DB: consulta historial
        ├── SELECT sd_movhis (bdicred) ← cross-DB: consulta historial crédito
        └── INSERT sd_movdia (bdicred) ← cross-DB: registra movimiento diario crédito
```

**Nota regulatoria:** el ejecutor diario sincroniza fechas de proceso entre dominios. Un fallo en este proceso puede desincronizar los registros PLD entre `bdilide`, `bdicheq` y `bdicred`, generando inconsistencias en los reportes regulatorios. `[COMPLIANCE-SIGN-OFF-REQUIRED]`

## Journey J15-02: Acumulación de Operaciones PLD

```
[Disparador batch (fin del día hábil)]
        │
        ▼
  sp_acumulacionoperaciones(pEmpresa, pFechaProceso, pCve_Usuario, pFechaultimodia)
        │
        ├── SELECT si_fechas (bdinteg)      ← obtiene fecha de proceso vigente
        ├── SELECT/DELETE sl_retlide        ← limpia retenciones anteriores del período
        ├── INSERT sl_procesos              ← registra inicio del proceso
        ├── SELECT sl_parametros            ← lee umbrales PLD (monto límite, porcentaje)
        ├── SELECT sl_movefec               ← lee movimientos del período
        ├── SELECT si_cliente (bdinteg)     ← obtiene datos del cliente para análisis
        ├── [FÓRMULA PLD]
        │     vmImpGrabar = vmImpTotIde - vmMontLimite
        │     vmMontoRecaudar = vmImpGrabar * viPorcaRecau
        │     vmMontoRecaudar = ROUND(vmMontoRecaudar - 0.01)  ← ajuste de redondeo
        ├── INSERT sl_retlide               ← graba acumulación para reporte
        ├── UPDATE sl_movefec               ← actualiza status del movimiento
        ├── UPDATE sl_procesos              ← registra fin del proceso
        └── INSERT sx_contproc (bdinteg)    ← notifica control de procesos integración
```

**Riesgo de equivalencia:** la fórmula `ROUND(vmMontoRecaudar - 0.01)` es un ajuste histórico explícito en el código (comentario original: "para solucionar lo del redondeo"). Este comportamiento **debe reproducirse exactamente** en el target. `[COMPLIANCE-SIGN-OFF-REQUIRED]`

## Journey J15-03: Proceso SAT — Carga y Resultado

```
[Disparador regulatorio (mensual/bajo demanda)]
        │
        ▼
  sp_cargainformesat() → sp_validaarchivoinforme()
        │
        ├── SELECT sc_fechas (bdicheq)
        ├── SELECT/INSERT/DELETE sl_procesos
        ├── SELECT sl_parametros
        ├── SELECT/DELETE/INSERT sl_archivoconsulta
        ├── SELECT/DELETE/INSERT sl_archivocontrol
        └── CALL sp_validaarchivoinforme()

        ▼ (siguiente etapa)
  sp_cargaresultadosat() → sp_validaarchivoresultado()
        │
        └── [misma estructura que cargainformesat]

        ▼ (actualización de registros)
  sp_actualizainformesat(pRFC) → UPDATE sl_exentos
  sp_actualizaresultadosat(pRFC) → UPDATE/INSERT sl_exentos, sl_exentostemp, sl_consat
```

**Nota regulatoria:** este journey gestiona el intercambio de archivos con el SAT para el régimen de Impuesto a los Depósitos en Efectivo (IDE) y la consulta de exentos. El formato de archivo es estricto y definido por el SAT. Cualquier cambio en el target debe preservar el formato exacto. `[COMPLIANCE-SIGN-OFF-REQUIRED]`

## Journey J15-04: Actualización de RFC en LIDE

```
  sp_actualizarfclide(cNumCte, cRfcAnt, cRfcActual, cAnioMes1, cAnioMes2)
        │
        ├── SELECT sl_movefec    ← verifica movimientos del cliente
        ├── SELECT sl_retlide    ← verifica retenciones LIDE
        ├── SELECT sl_detlide    ← verifica detalle LIDE
        ├── SELECT sl_constancias← verifica constancias emitidas
        ├── SELECT sl_consat     ← verifica consultas SAT previas
        └── SELECT sl_exentos    ← verifica si el cliente es exento
```

## SPs aislados — clasificación preliminar

Los 96 SPs aislados se clasifican en las siguientes categorías funcionales. `[DATO-REQUERIDO]` — clasificación pendiente de validación por el Área de Cumplimiento:

| Categoría | SPs estimados | Ejemplos |
|-----------|:-------------:|---------|
| Reportes regulatorios (CNBV/SHCP) | ~20 | SPs con `reporte`, `informe` en el nombre |
| Carga/descarga de archivos SAT | ~15 | SPs con `carga`, `archsat`, `consat` |
| Mantenimiento de lista LIDE | ~15 | SPs con `lide`, `detlide`, `retlide` |
| Consultas Buró de Crédito | ~5 | `borramovs_movefechis` y similares |
| Utilidades y validaciones | ~25 | SPs con `valida`, `checa` |
| Versiones PBA (pruebas) | ~16 | SPs con sufijo `_pba` |

## `[SME-PENDING]`

- [ ] Identificar los 5 SPs exactos del callgraph con sus dominios llamantes.
- [ ] Documentar el orquestador externo del `ejecutor_diario` (cron AIX o tabla de programación).
- [ ] Validar si los SPs `_pba` son versiones activas en producción o solo para pruebas.
- [ ] Documentar la cadena de llamadas completa de los reportes regulatorios CNBV/SHCP.

---
*Generado: análisis estático bdilide + sp-specs-bdilide.md · 2026-08-03*
