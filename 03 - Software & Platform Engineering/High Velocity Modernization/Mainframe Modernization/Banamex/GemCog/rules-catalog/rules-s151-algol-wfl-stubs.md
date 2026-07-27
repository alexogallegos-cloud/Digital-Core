# Catálogo de Reglas de Arquitectura — S151 ALGOL · WFL
**Versión:** 1.0 — 2026-07-17
**Componentes:** 11 ALGOL · 3 WFL
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Estrategia:** ALGOL → RETAIN+ENCAPSULATE · WFL → Reemplazar orquestador
**Numeración:** RN-S151-1150 a RN-S151-1163 (14 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S151-1150 — Propósito y estrategia de migración: L001

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1150 |
| **Nombre** | Propósito y estrategia de migración: L001 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_L001 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL base del sistema S151 (Movimientos Contables): abre la base de control `S151BD99CONTROL`, enlaza la utilería de despliegue `LIBLJ` y la librería de calendario `CALE` (THECALENDAR/LOCSUP). Provee acceso a datos y servicios transversales de fechas/mensajería. Estrategia RETAIN+ENCAPSULATE: conservar la lógica de acceso a control y publicarla como servicio de dominio, sustituyendo el enlace por librería MCP (SHAREDBYRUNUNIT) por invocación de servicio y las utilerías de calendario/despliegue por librerías estándar del target.

**Fórmula/pseudocódigo:**
```
DATABASE S151BD99CONTROL
LIBRARY LIBLJ (DESPLIEGA) ; LIBRARY CALE (THECALENDAR/LOCSUP)
// acceso a control + servicios de fecha/mensajería
```

**Vocabulario en la fórmula:** L001 · S151BD99CONTROL · LIBLJ · CALE · THECALENDAR

**Excepciones:**
- El modo SHAREDBYRUNUNIT implica estado por run-unit; rediseñar como servicio sin estado compartido.
- Las utilerías de calendario (LOCSUP) deben mapearse a librería de fechas del target.

**Estado validación:** Verificado fuente

---

## RN-S151-1151 — Propósito y estrategia de migración: L006

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1151 |
| **Nombre** | Propósito y estrategia de migración: L006 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_L006 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de servicios de acceso a datos del sistema S151. Abstrae operaciones DMSII sobre las bases de movimientos contables y saldos. Estrategia RETAIN+ENCAPSULATE: inventariar procedimientos exportados, preservar la lógica de acceso y publicarla como capa de repositorio del target, sustituyendo DMSII por el motor destino con mapeo de verbos y claves.

**Fórmula/pseudocódigo:**
```
// capa de acceso a datos S151
PROCEDURE <acceso>(clave) -> registro   // FIND/STORE DMSII
```

**Vocabulario en la fórmula:** L006 · DMSII · FIND · STORE · repositorio

**Excepciones:**
- Requiere inventario de procedimientos exportados antes del contrato final.
- Confianza media: propósito inferido por nombre y capa (9.1.1).

**Estado validación:** Stub arquitectural

---

## RN-S151-1152 — Propósito y estrategia de migración: L009

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1152 |
| **Nombre** | Propósito y estrategia de migración: L009 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_L009 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de servicios de acceso/soporte a datos del sistema S151. Estrategia RETAIN+ENCAPSULATE: preservar la lógica de acceso, publicar contrato de repositorio y migrar el acceso DMSII al motor target manteniendo semántica de claves y sets.

**Fórmula/pseudocódigo:**
```
// capa de acceso a datos S151
PROCEDURE <acceso>(clave) -> registro
```

**Vocabulario en la fórmula:** L009 · DMSII · acceso · repositorio

**Excepciones:**
- Requiere inventario de procedimientos exportados.
- Confianza media: propósito inferido por nombre y capa (9.1.1).

**Estado validación:** Stub arquitectural

---

## RN-S151-1153 — Propósito y estrategia de migración: L010

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1153 |
| **Nombre** | Propósito y estrategia de migración: L010 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_L010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de acceso a datos del sistema S151 (par de la familia L006/L009/L011/L012). Estrategia RETAIN+ENCAPSULATE: consolidar la familia de librerías de acceso en una capa de repositorio coherente del target, evitando duplicación de patrones DMSII y unificando el contrato de datos.

**Fórmula/pseudocódigo:**
```
// capa de acceso a datos S151 (familia L006..L012)
PROCEDURE <acceso>(clave) -> registro
```

**Vocabulario en la fórmula:** L010 · DMSII · acceso · repositorio

**Excepciones:**
- Evaluar consolidación con L006/L009/L011/L012 para reducir superficie.
- Confianza media: propósito inferido por nombre y capa (9.1.1).

**Estado validación:** Stub arquitectural

---

## RN-S151-1154 — Propósito y estrategia de migración: L011

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1154 |
| **Nombre** | Propósito y estrategia de migración: L011 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_L011 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de acceso a datos del sistema S151 (familia L006..L012). Estrategia RETAIN+ENCAPSULATE: preservar la lógica de acceso y unificar con la familia de repositorios del target; mapear verbos DMSII y estrategia de concurrencia al motor destino.

**Fórmula/pseudocódigo:**
```
// capa de acceso a datos S151
PROCEDURE <acceso>(clave) -> registro
```

**Vocabulario en la fórmula:** L011 · DMSII · acceso · repositorio

**Excepciones:**
- Evaluar consolidación con el resto de la familia de acceso.
- Confianza media: propósito inferido por nombre y capa (9.1.1).

**Estado validación:** Stub arquitectural

---

## RN-S151-1155 — Propósito y estrategia de migración: L012

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1155 |
| **Nombre** | Propósito y estrategia de migración: L012 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_L012 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de acceso a datos del sistema S151 (familia L006..L012). Estrategia RETAIN+ENCAPSULATE: conservar la lógica de acceso, publicar contrato de repositorio y consolidar con la familia; sustituir DMSII por el motor target.

**Fórmula/pseudocódigo:**
```
// capa de acceso a datos S151
PROCEDURE <acceso>(clave) -> registro
```

**Vocabulario en la fórmula:** L012 · DMSII · acceso · repositorio

**Excepciones:**
- Cierra la familia de librerías de acceso L006..L012; unificar contrato.
- Confianza media: propósito inferido por nombre y capa (9.1.1).

**Estado validación:** Stub arquitectural

---

## RN-S151-1156 — Propósito y estrategia de migración: L194

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1156 |
| **Nombre** | Propósito y estrategia de migración: L194 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_L194 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de utilería de sistema de archivos: `REMUEVE_ARCHIVOS(DIR, FECHA)` recorre un directorio y elimina archivos por criterio de fecha (housekeeping/retención). Usa acceso a disco con `FILE (KIND=DISK, DEPENDENTSPECS)`. Estrategia RETAIN+ENCAPSULATE: preservar la política de retención (qué se borra y cuándo) como configuración declarativa, y reemplazar el acceso al sistema de archivos MCP por un servicio de gestión de artefactos/objetos del target (lifecycle policies de almacenamiento).

**Fórmula/pseudocódigo:**
```
INTEGER PROCEDURE REMUEVE_ARCHIVOS(DIR, FECHA):
  FOR archivo IN DIR:
     IF fecha(archivo) < FECHA THEN remover(archivo)
// target: lifecycle/retention policy del object store
```

**Vocabulario en la fórmula:** L194 · REMUEVE_ARCHIVOS · DIR · FECHA · retención

**Excepciones:**
- El acceso directo al file system MCP no es portable; usar políticas de lifecycle del target.
- La política de retención debe externalizarse (cumplimiento/auditoría de borrado).

**Estado validación:** Verificado fuente

---

## RN-S151-1157 — Propósito y estrategia de migración: P000

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1157 |
| **Nombre** | Propósito y estrategia de migración: P000 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_P000 (INCLUDE S151/CRONOS2K) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Programa ALGOL de control de fechas y "prelínea automática" del sistema S151: determina la fecha de proceso y prepara el arranque en línea, usando el include `CRONOS2K` (manejo de siglo/año base a2k). Estrategia RETAIN+ENCAPSULATE: extraer la política de fecha de proceso y prelínea a un servicio de calendario/proceso del target, eliminando la lógica de ventana de siglo (Y2K a2k) y reemplazándola por tipos de fecha nativos.

**Fórmula/pseudocódigo:**
```
PROCEDURE PROGRAM(PA):   // control de fechas + prelínea
  a2k_base_year=50 ; siglo = (yy < base) ? 20 : 19
  determinar fecha_proceso -> habilitar prelínea automática
```

**Vocabulario en la fórmula:** P000 · CRONOS2K · a2k_base_year · fecha_proceso · prelínea

**Excepciones:**
- La lógica de ventana de siglo (CRONOS2K) es deuda Y2K; reemplazar por fechas nativas.
- La "prelínea automática" es control de arranque; mapear al orquestador (RN-S151-1162).

**Estado validación:** Verificado fuente

---

## RN-S151-1158 — Propósito y estrategia de migración: P007

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1158 |
| **Nombre** | Propósito y estrategia de migración: P007 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_P007 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Programa ALGOL de soporte del sistema S151 (proceso auxiliar del núcleo de movimientos contables). Estrategia RETAIN+ENCAPSULATE: identificar la responsabilidad concreta del programa, preservar la lógica de dominio y encapsularla como caso de uso/servicio del target, desacoplando el acceso a datos DMSII.

**Fórmula/pseudocódigo:**
```
// proceso ALGOL de soporte S151; responsabilidad a confirmar
PROGRAM P007 -> {lógica de proceso}
```

**Vocabulario en la fórmula:** P007 · proceso · S151 · movimientos

**Excepciones:**
- Confianza media: requiere lectura completa del fuente para fijar responsabilidad.
- Desacoplar acceso DMSII de la lógica de negocio al encapsular.

**Estado validación:** Stub arquitectural

---

## RN-S151-1159 — Propósito y estrategia de migración: P012

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1159 |
| **Nombre** | Propósito y estrategia de migración: P012 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_P012 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Programa ALGOL de soporte del sistema S151 (proceso auxiliar del núcleo). Estrategia RETAIN+ENCAPSULATE: confirmar responsabilidad, preservar la lógica de dominio y exponerla como servicio/caso de uso del target, sustituyendo el acceso DMSII por el motor destino.

**Fórmula/pseudocódigo:**
```
// proceso ALGOL de soporte S151; responsabilidad a confirmar
PROGRAM P012 -> {lógica de proceso}
```

**Vocabulario en la fórmula:** P012 · proceso · S151 · movimientos

**Excepciones:**
- Confianza media: requiere lectura completa del fuente para fijar responsabilidad.
- Desacoplar acceso DMSII de la lógica de negocio al encapsular.

**Estado validación:** Stub arquitectural

---

## RN-S151-1160 — Propósito y estrategia de migración: P810

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1160 |
| **Nombre** | Propósito y estrategia de migración: P810 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_ALGOL_P810 (STSTOTALES |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Programa ALGOL `STSTOTALES`: cada cierto tiempo carga sistemas y conceptos en la base S151, consulta MOVDIA por fecha de proceso y genera un reporte tipo consulta por sucursal, caja, banco y moneda, enviándolo en línea a Splunk por cada concepto y con los totales finales. Optimizado (GAEC 251008) para reducir consultas y CPU. Estrategia RETAIN+ENCAPSULATE: preservar la lógica de agregación (totales por dimensión) como servicio de reporting/telemetría y reemplazar el envío directo a Splunk por un pipeline de observabilidad estándar (exportador de métricas/eventos) del target.

**Fórmula/pseudocódigo:**
```
LOOP cada intervalo:
  cargar sistemas + conceptos ; consultar MOVDIA(fecha_proceso)
  agregar por (sucursal, caja, banco, moneda)
  enviar_a_splunk(registro por concepto) ; enviar totales
```

**Vocabulario en la fórmula:** P810 · STSTOTALES · MOVDIA · Splunk · sucursal · concepto

**Excepciones:**
- El envío directo a Splunk acopla la app con la herramienta; usar capa de exportación desacoplada.
- La agregación por dimensiones debe preservarse exactamente para consistencia del reporte.

**Estado validación:** Verificado fuente

---

## RN-S151-1161 — Propósito y estrategia de migración: WFL_LOTE

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1161 |
| **Nombre** | Propósito y estrategia de migración: WFL_LOTE |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_WFL_LOTE (BEGIN JOB S151/WFL/LOTE) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Work Flow Language que orquesta el proceso batch (LOTE) del sistema S151 de movimientos contables: declara familia de disco (`CMEMP`), versiones de WFL y programas, recibe `STRING PARAMETRO` y ejecuta la secuencia de programas del cierre/proceso por lote (incluye validaciones específicas como el corresponsal P602). Estrategia REEMPLAZAR ORQUESTADOR: no migrar el WFL literalmente; modelar el flujo batch como DAG en el orquestador del target con dependencias, parámetros tipados y políticas de reintento/abort.

**Fórmula/pseudocódigo:**
```
JOB S151/WFL/LOTE (PARAMETRO):
  FAMILY DISK = CMEMP
  RUN <programas de proceso por lote> (incl. validación P602)
  // -> DAG declarativo en el orquestador target
```

**Vocabulario en la fórmula:** WFL · LOTE · JOB · PARAMETRO · CMEMP · P602

**Excepciones:**
- Las versiones diferenciadas VDM/regionales (RELVDM.RELREG) deben gestionarse por configuración.
- La lógica de abort/reintento del WFL se mapea a políticas del orquestador target.

**Estado validación:** Verificado fuente

---

## RN-S151-1162 — Propósito y estrategia de migración: WFL_LINEA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1162 |
| **Nombre** | Propósito y estrategia de migración: WFL_LINEA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_WFL_LINEA (BEGIN JOB S151/WFL/LINEA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Work Flow Language que orquesta el arranque del sistema S151 en línea: levanta los objetos/programas que atienden la operación en línea de movimientos contables, coordinado con el control de fechas y prelínea automática (P000). Estrategia REEMPLAZAR ORQUESTADOR: sustituir por definición de arranque/servicio del target (workflow de bootstrap o despliegue de servicios always-on), externalizando parámetros y dependencias de secuencia.

**Fórmula/pseudocódigo:**
```
JOB S151/WFL/LINEA (PARAMETRO):
  determinar fecha_proceso (via P000)
  RUN <programas en línea del S151>
  // -> bootstrap/orquestación de servicios en el target
```

**Vocabulario en la fórmula:** WFL · LINEA · JOB · prelínea · fecha_proceso · P000

**Excepciones:**
- El arranque en línea puede convertirse en servicios always-on en el target (no job batch).
- Depende del control de fechas P000 (RN-S151-1157).

**Estado validación:** Verificado fuente

---

## RN-S151-1163 — Propósito y estrategia de migración: WFL_SPLUNK

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-1163 |
| **Nombre** | Propósito y estrategia de migración: WFL_SPLUNK |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [ARQUITECTURA-DISTRIBUIDA] [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S151_WFL_SPLUNK (BEGIN JOB S151/WFL/SPLUNK) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Work Flow Language que orquesta el envío de información del S151 a Splunk: dispara el flujo de generación y transmisión de reportes/totales (coordinado con P810 STSTOTALES) hacia la plataforma de observabilidad. Estrategia REEMPLAZAR ORQUESTADOR: sustituir el job WFL por un pipeline de telemetría nativo del target (agente/exportador de logs y métricas), desacoplando el sistema de negocio del transporte a Splunk y permitiendo backpressure/reintentos gestionados.

**Fórmula/pseudocódigo:**
```
JOB S151/WFL/SPLUNK (PARAMETRO):
  invoca P810 (STSTOTALES) -> genera registros de totales
  transmite a Splunk (en línea)
  // -> pipeline de observabilidad gestionado en el target
```

**Vocabulario en la fórmula:** WFL · SPLUNK · P810 · STSTOTALES · telemetría · totales

**Excepciones:**
- El transporte a Splunk debe desacoplarse del negocio (exportador/agente del target).
- Coordinar con P810 (RN-S151-1160) para no duplicar la lógica de agregación.

**Estado validación:** Verificado fuente
