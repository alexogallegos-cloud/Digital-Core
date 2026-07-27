# Catálogo de Reglas de Arquitectura — S500 ALGOL · WFL · INC · DASDL
**Versión:** 1.0 — 2026-07-17
**Componentes:** 15 ALGOL · 3 WFL · 5 INC · 7 DASDL
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Estrategia:** ALGOL → RETAIN+ENCAPSULATE · WFL → Reemplazar orquestador · INC/DASDL → Migrar modelo target
**Numeración:** RN-S500-881 a RN-S500-910 (30 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S500-881 — Propósito y estrategia de migración: L045_TELETON

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-881 |
| **Nombre** | Propósito y estrategia de migración: L045_TELETON |
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
| **Programa ejecutor** | S500_SOURCE_L045_TELETON |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de control de autorizaciones del proceso Teletón. Serializa el acceso concurrente a las autorizaciones mediante `EVENT E_USO_AUT` (`PROCURE`/`LIBERATE`) y valida contra un arreglo `AUTORIZACION[0:4]`, además de detectar si el archivo de log está en uso con `DCKEYIN`. Estrategia RETAIN+ENCAPSULATE: preservar la lógica de validación de autorización y exponerla como servicio idempotente; sustituir el candado de evento MCP por un lock distribuido o transacción del motor target.

**Fórmula/pseudocódigo:**
```
INTEGER PROCEDURE VALIDAAUT(COPIA, AUTORIZ):
  PROCURE(E_USO_AUT)                 // sección crítica
  FOR i:=1..4: IF AUTORIZACION[i]=AUTORIZ THEN encontrado
  LIBERATE(E_USO_AUT)                // EPILOG
INTEGER PROCEDURE FILEINUSE(archivo): DCKEYIN -> "IN USE"
```

**Vocabulario en la fórmula:** AUTORIZACION · E_USO_AUT · FILEINUSE · DCKEYIN · COPIA

**Excepciones:**
- El `EVENT` MCP no tiene equivalente directo en la plataforma target; requiere lock distribuido o serialización a nivel de agregado.
- `DCKEYIN` (comando de sistema MCP) debe reemplazarse por chequeo de bloqueo de recurso nativo del target.

**Estado validación:** Verificado fuente

---

## RN-S500-882 — Propósito y estrategia de migración: L019_SALDOS

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-882 |
| **Nombre** | Propósito y estrategia de migración: L019_SALDOS |
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
| **Programa ejecutor** | S500_SOURCE_L019_SALDOS (control S500L020SALDOS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de saldos que opera bajo un patrón de control de links: `S500L020SALDOS` controla el ciclo de vida de los links de la librería `S500L019SALDOS`. Usa la librería utilitaria `LIBLJ` (DESPLIEGA) para mensajería operativa. Estrategia RETAIN+ENCAPSULATE: conservar el algoritmo de cálculo/consulta de saldos como servicio de dominio de "Saldos", desacoplando el mecanismo MCP de librerías enlazadas (LINKLIBRARY) hacia invocación de servicio explícita.

**Fórmula/pseudocódigo:**
```
LIBRARY LIBLJ(TITLE="(S000)S000/UTILITY/DESPLIEGA/OBJ/LIB")
PROCEDURE LJ(CONTADOR, MENSAJE)     // mensajería
// S500L020SALDOS controla links -> S500L019SALDOS (consulta de saldos)
```

**Vocabulario en la fórmula:** SALDOS · LIBLJ · LJ · CONTADOR · MENSAJE · LINK

**Excepciones:**
- El acoplamiento por LINKLIBRARY entre L019 y L020 debe rediseñarse como contrato de servicio versionado.
- La utilería DESPLIEGA (LIBLJ) es infraestructura MCP; migrar a logging/observabilidad estándar del target.

**Estado validación:** Verificado fuente

---

## RN-S500-883 — Propósito y estrategia de migración: L046_REVOCA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-883 |
| **Nombre** | Propósito y estrategia de migración: L046_REVOCA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_SOURCE_L046_REVOCA |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL responsable de la lógica de revocación (reverso) de operaciones de captación y tarjetas. Encapsula el patrón de compensación de una transacción ya aplicada. Estrategia RETAIN+ENCAPSULATE: conservar la regla de reverso como caso de uso de dominio "Revocación", exponerlo como comando compensatorio idempotente y trazable, garantizando exactamente-una-vez sobre la transacción original.

**Fórmula/pseudocódigo:**
```
// contrato del servicio de reverso
REVOCA(operacion_original, motivo):
  validar estado(operacion_original) = APLICADA
  generar movimiento compensatorio (signo inverso)
  marcar operacion_original = REVOCADA
```

**Vocabulario en la fórmula:** REVOCA · operacion_original · movimiento_compensatorio · motivo

**Excepciones:**
- La compensación debe ser idempotente para evitar doble reverso ante reintentos.
- Requiere consistencia transaccional con el módulo de saldos (RN-S500-882).

**Estado validación:** Stub arquitectural

---

## RN-S500-884 — Propósito y estrategia de migración: L030_TIEMPOS

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-884 |
| **Nombre** | Propósito y estrategia de migración: L030_TIEMPOS |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [MCP-ESPECÍFICO] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_SOURCE_L030_TIEMPOS |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de control de tiempos y ventanas operativas del sistema S500 (temporización de procesos batch/línea, time-outs, calendario de proceso). Estrategia RETAIN+ENCAPSULATE: extraer la política de ventanas y horarios a configuración declarativa (scheduler del target) y encapsular los cálculos de tiempo/vigencia como servicio de calendario, eliminando dependencias de reloj y calendario propietarios del MCP.

**Fórmula/pseudocódigo:**
```
// política de ventana operativa (declarativa en target)
DENTRO_DE_VENTANA(proceso, ahora):
  return ventana(proceso).inicio <= ahora <= ventana(proceso).fin
TIME_OUT_DEF = 60 s   // parametrizable
```

**Vocabulario en la fórmula:** TIEMPOS · TIME_OUT · VENTANA · calendario · vigencia

**Excepciones:**
- Las funciones de calendario MCP (THECALENDAR/LOCSUP) deben mapearse a librería de fechas del target.
- Los time-outs hard-coded deben externalizarse a configuración.

**Estado validación:** Stub arquitectural

---

## RN-S500-885 — Propósito y estrategia de migración: L039_ACCESOBD04

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-885 |
| **Nombre** | Propósito y estrategia de migración: L039_ACCESOBD04 |
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
| **Programa ejecutor** | S500_SOURCE_L039_ACCESOBD04 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de acceso a la base de datos DMSII de tarjetas (BD04). Actúa como capa de acceso a datos (DAL) que abstrae operaciones DMSII sobre el data set de tarjetas. Estrategia RETAIN+ENCAPSULATE: preservar los patrones de acceso (claves, sets, invocaciones) y reimplementar la DAL contra el modelo target (repositorio por agregado "Tarjeta"), manteniendo el contrato de operaciones pero sustituyendo DMSII por el motor destino.

**Fórmula/pseudocódigo:**
```
// contrato de la capa de acceso a BD04 Tarjetas
FIND / STORE / DELETE (S500BD04TARJETAS, clave)
// DMSII sets -> índices/claves del repositorio target
```

**Vocabulario en la fórmula:** ACCESOBD04 · S500BD04TARJETAS · DMSII · FIND · STORE · SET

**Excepciones:**
- Los verbos DMSII (FIND/LOCK/STORE) requieren mapeo semántico exacto a transacciones del target.
- El bloqueo optimista/pesimista de DMSII debe replicarse en la estrategia de concurrencia destino.

**Estado validación:** Verificado fuente

---

## RN-S500-886 — Propósito y estrategia de migración: L050

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-886 |
| **Nombre** | Propósito y estrategia de migración: L050 |
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
| **Programa ejecutor** | S500_SOURCE_L050 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de servicios de soporte del núcleo S500 (asociada al flujo de activación de medios / acceso a datos, invocada desde P050). Estrategia RETAIN+ENCAPSULATE: identificar el conjunto de procedimientos expuestos, conservar su lógica de dominio y exponerlos como servicio con contrato explícito; retirar el acoplamiento por librería MCP compartida.

**Fórmula/pseudocódigo:**
```
// librería de servicios; contrato a inventariar procedimiento por procedimiento
PROCEDURE <servicio>(<args>) -> <resultado>
```

**Vocabulario en la fórmula:** L050 · servicio · procedimiento · activa_medios

**Excepciones:**
- Requiere inventario detallado de procedimientos exportados antes de definir el contrato final.
- Confianza media: propósito inferido por nombre y contexto de invocación (P050).

**Estado validación:** Stub arquitectural

---

## RN-S500-887 — Propósito y estrategia de migración: L035_MAPLI

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-887 |
| **Nombre** | Propósito y estrategia de migración: L035_MAPLI |
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
| **Programa ejecutor** | S500_SOURCE_L035_MAPLI (INC MAPLI_WOR/MAPLI_PRO |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL del subsistema MAPLI (administración de mapas/pantallas y su persistencia en la BD MAPLI). Vincula las estructuras WORKING (MAPLI_WOR) y PROCEDIMIENTOS (MAPLI_PRO) con el data set MAPLI. Estrategia RETAIN+ENCAPSULATE: separar la lógica de presentación/mapeo de pantallas del acceso a datos; encapsular MAPLI como servicio de configuración de UI y migrar su esquema (DASDL MAPLI) al modelo target.

**Fórmula/pseudocódigo:**
```
// subsistema de mapas de pantalla
MAPLI_WOR (working) + MAPLI_PRO (lógica) -> S500 DASDL MAPLI
CARGA_MAPA(id_pantalla) -> definición_mapa
```

**Vocabulario en la fórmula:** MAPLI · MAPLI_WOR · MAPLI_PRO · mapa · pantalla

**Excepciones:**
- El acoplamiento pantalla-datos debe descomponerse (BFF/UI config vs. dominio).
- Depende de la migración conjunta del esquema DASDL MAPLI (RN-S500-908).

**Estado validación:** Verificado fuente

---

## RN-S500-888 — Propósito y estrategia de migración: L081

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-888 |
| **Nombre** | Propósito y estrategia de migración: L081 |
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
| **Programa ejecutor** | S500_SOURCE_L081 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de servicios del núcleo S500 (par funcional con L080). Estrategia RETAIN+ENCAPSULATE: inventariar procedimientos exportados, conservar la lógica de dominio y publicar contrato de servicio; retirar dependencia de librería MCP compartida y consolidar con L080 si hay solapamiento funcional.

**Fórmula/pseudocódigo:**
```
// librería de servicios del núcleo; contrato a inventariar
PROCEDURE <servicio>(<args>) -> <resultado>
```

**Vocabulario en la fórmula:** L081 · servicio · procedimiento · núcleo

**Excepciones:**
- Evaluar consolidación con L080 (RN-S500-889) para reducir superficie.
- Confianza media: propósito inferido por nombre y capa (9.1.1).

**Estado validación:** Stub arquitectural

---

## RN-S500-889 — Propósito y estrategia de migración: L080

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-889 |
| **Nombre** | Propósito y estrategia de migración: L080 |
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
| **Programa ejecutor** | S500_SOURCE_L080 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de servicios del núcleo S500 (par funcional con L081). Estrategia RETAIN+ENCAPSULATE: conservar la lógica de dominio, definir contrato explícito y evaluar consolidación con L081; migrar acceso a datos subyacente al motor target.

**Fórmula/pseudocódigo:**
```
// librería de servicios del núcleo; contrato a inventariar
PROCEDURE <servicio>(<args>) -> <resultado>
```

**Vocabulario en la fórmula:** L080 · servicio · procedimiento · núcleo

**Excepciones:**
- Evaluar consolidación con L081 (RN-S500-888).
- Confianza media: propósito inferido por nombre y capa (9.1.1).

**Estado validación:** Stub arquitectural

---

## RN-S500-890 — Propósito y estrategia de migración: L040_LIGAS

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-890 |
| **Nombre** | Propósito y estrategia de migración: L040_LIGAS |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_SOURCE_L040_LIGAS |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL que administra "ligas" (enlaces/relaciones) entre entidades del sistema (por ejemplo cuenta ↔ contrato ↔ tarjeta). Estrategia RETAIN+ENCAPSULATE: modelar explícitamente las relaciones como asociaciones de dominio en el modelo target y encapsular la lógica de resolución de ligas como servicio de grafo de relaciones.

**Fórmula/pseudocódigo:**
```
// resolución de relaciones entre entidades
RESUELVE_LIGA(entidad_origen) -> [entidades_relacionadas]
```

**Vocabulario en la fórmula:** LIGAS · entidad · relación · enlace

**Excepciones:**
- Las ligas implícitas (por convención de claves) deben materializarse como relaciones explícitas.
- Confianza media: propósito inferido por nombre y capa (9.1.1).

**Estado validación:** Stub arquitectural

---

## RN-S500-891 — Propósito y estrategia de migración: L070

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-891 |
| **Nombre** | Propósito y estrategia de migración: L070 |
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
| **Programa ejecutor** | S500_SOURCE_L070 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de servicios del núcleo S500 (capa de acceso/utilería). Estrategia RETAIN+ENCAPSULATE: inventariar procedimientos exportados, preservar la lógica de dominio y publicar contrato de servicio versionado, sustituyendo el acceso DMSII por el motor target.

**Fórmula/pseudocódigo:**
```
// librería de servicios; contrato a inventariar
PROCEDURE <servicio>(<args>) -> <resultado>
```

**Vocabulario en la fórmula:** L070 · servicio · procedimiento · núcleo

**Excepciones:**
- Requiere inventario de procedimientos exportados antes del contrato final.
- Confianza media: propósito inferido por nombre y capa (9.1.1).

**Estado validación:** Stub arquitectural

---

## RN-S500-892 — Propósito y estrategia de migración: L060_CONSULFOR

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-892 |
| **Nombre** | Propósito y estrategia de migración: L060_CONSULFOR |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_SOURCE_L060_CONSULFOR |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de "consulta de formatos" (CONSULFOR): resuelve consultas de información/formato para presentación al usuario o downstream. Estrategia RETAIN+ENCAPSULATE: aislar la lógica de consulta (solo lectura) como servicio de query dedicado (CQRS lado lectura), separándola de los flujos de escritura y mapeándola a proyecciones del modelo target.

**Fórmula/pseudocódigo:**
```
// servicio de consulta (solo lectura)
CONSULFOR(criterio, formato) -> resultado_formateado
```

**Vocabulario en la fórmula:** CONSULFOR · consulta · formato · criterio

**Excepciones:**
- Al ser solo lectura, es candidata a proyección/réplica optimizada (patrón CQRS).
- No debe introducir efectos colaterales de escritura en la migración.

**Estado validación:** Verificado fuente

---

## RN-S500-893 — Propósito y estrategia de migración: L010_CONTROL

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-893 |
| **Nombre** | Propósito y estrategia de migración: L010_CONTROL |
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
| **Programa ejecutor** | S500_SOURCE_L010_CONTROL (INC L010) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL de control central del sistema S500: administra parámetros, banderas de control y estado global del sistema (capa 10.1.1). Es transversal a los flujos de aplicación (P010). Estrategia RETAIN+ENCAPSULATE: externalizar la parametría a un store de configuración (feature flags/config service) y encapsular las reglas de control como servicio de políticas, eliminando el estado global compartido por librería MCP.

**Fórmula/pseudocódigo:**
```
// control central / parametría
LEE_PARAMETRO(clave) -> valor
EVALUA_CONTROL(bandera) -> permitido/denegado
```

**Vocabulario en la fórmula:** CONTROL · parámetro · bandera · política · L010

**Excepciones:**
- El estado global compartido debe rediseñarse para evitar acoplamiento sistémico.
- Cambios de parámetro requieren gobierno (auditoría/versionado) en el target.

**Estado validación:** Verificado fuente

---

## RN-S500-894 — Propósito y estrategia de migración: L093_ASINCRONA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-894 |
| **Nombre** | Propósito y estrategia de migración: L093_ASINCRONA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [ARQUITECTURA-RESILIENCIA] [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_SOURCE_L093_ASINCRONA (par de L091) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL del subsistema asíncrono S500 (variante de L091): gestiona mensajes en memoria con vencimiento (VENCE/OLVIDA), reenvío y estadísticas de uso, implementando un buzón de mensajería con time-out y persistencia en log. Estrategia RETAIN+ENCAPSULATE: sustituir el buffer en memoria propietario por una cola de mensajes gestionada (broker) con TTL, dead-letter y reintentos nativos, preservando la semántica de vencimiento y rebote.

**Fórmula/pseudocódigo:**
```
// buzón asíncrono con vencimiento
INSERTA(folio, msg): VENCE[i]=ahora+HORAS_VENCE; OLVIDA[i]=ahora
VENCIDOS: WHERE VENCE[i] < ahora -> reenviar/descartar (dead-letter)
TIME_OUT_DEF = 60 s
```

**Vocabulario en la fórmula:** ASINCRONA · VENCE · OLVIDA · folio · TIME_OUT · rebote

**Excepciones:**
- El arreglo en memoria (MEM[0:N]) y `EVENT` MCP deben migrar a broker con TTL/DLQ.
- La persistencia por archivo LOG se reemplaza por almacenamiento durable del broker.

**Estado validación:** Verificado fuente

---

## RN-S500-895 — Propósito y estrategia de migración: L091_ASINCRONA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-895 |
| **Nombre** | Propósito y estrategia de migración: L091_ASINCRONA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [ARQUITECTURA-RESILIENCIA] [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_SOURCE_L091_ASINCRONA (par de L093) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Librería ALGOL núcleo del subsistema asíncrono S500. Mantiene el vector de búsqueda de folios `MEM[0:N]` (2016 entradas), tiempos de vencimiento (`VENCE`), inserción original (`OLVIDA`), longitudes (`SZ`), estadísticas (`STS`) y control de envíos/vueltas. Implementa un buzón de mensajería asíncrona con time-out y bitmap de resumen para búsqueda rápida. Estrategia RETAIN+ENCAPSULATE: reemplazar el buffer circular en memoria por una cola de mensajes gestionada (broker con partición por folio), preservando semántica de vencimiento, reenvío y estadísticas.

**Fórmula/pseudocódigo:**
```
// núcleo del buzón asíncrono
MEM[0:2015] : vector de folios
SUMM(x) = RESUMEN[x DIV 48].[x MOD 48:1]   // bitmap de presencia
UN_DIA = 86400 s ; TIME_OUT_DEF = 60 s
ENVIA si (LIMITE alcanzado) OR (mensaje vencido)
```

**Vocabulario en la fórmula:** ASINCRONA · MEM · RESUMEN · VENCE · OLVIDA · folio · LIMITE

**Excepciones:**
- El bitmap `RESUMEN` (búsqueda O(1)) se sustituye por índice del broker/almacén.
- Los contadores `STS` (estadísticas) deben exponerse como métricas de observabilidad.

**Estado validación:** Verificado fuente

---

## RN-S500-896 — Propósito y estrategia de migración: WFL_LOTE

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-896 |
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
| **Programa ejecutor** | S500_WFL_LOTE (BEGIN JOB S500/WFL/LINEA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Work Flow Language que orquesta el arranque diario del sistema S500 (línea/lote): declara versiones, recibe un `STRING PARAMETRO` y lanza en secuencia los objetos de aplicación (P010 aplicación, P014 consultor, P015 dispersador, P038 monitor, P050 activa medios, P080 cuenta ordenante, etc.). Estrategia REEMPLAZAR ORQUESTADOR: el WFL no se migra literalmente; se reemplaza por un orquestador del target (scheduler/workflow engine, p. ej. Airflow/Step Functions/Control-M) que modele el DAG de arranque, dependencias y parámetros de forma declarativa.

**Fórmula/pseudocódigo:**
```
JOB S500/WFL/LINEA (PARAMETRO):
  RUN P010 (aplicación) ; RUN P014 (consultor) ; RUN P015 (dispersador)
  RUN P038 (monitor)    ; RUN P050 (activa medios) ; RUN P080 (ordenante)
  // dependencias y orden -> DAG declarativo en el target
```

**Vocabulario en la fórmula:** WFL · JOB · PARAMETRO · P010 · P038 · P050 · orquestación

**Excepciones:**
- La lógica de reintentos/abort del WFL debe mapearse a políticas del orquestador target.
- Los parámetros por STRING deben tipificarse en la definición del workflow destino.

**Estado validación:** Verificado fuente

---

## RN-S500-897 — Propósito y estrategia de migración: WFL_REORG_GARBAGE_S500BD04TARJETAS

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-897 |
| **Nombre** | Propósito y estrategia de migración: WFL_REORG_GARBAGE_S500BD04TARJETAS |
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
| **Programa ejecutor** | S500_WFL_REORG_GARBAGE_S500BD04TARJETAS |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WFL de reorganización/garbage collection del data set DMSII de tarjetas (BD04): recupera espacio y reorganiza estructuras físicas. Estrategia REEMPLAZAR ORQUESTADOR: en el target la reorganización física de DMSII no existe como tal; se sustituye por tareas de mantenimiento nativas del motor destino (VACUUM/rebuild de índices/compactación) programadas por el orquestador, o se elimina si el motor gestiona el espacio automáticamente.

**Fórmula/pseudocódigo:**
```
JOB REORG_GARBAGE(S500BD04TARJETAS):
  reorganizar estructura física DMSII + liberar garbage
  // target: mantenimiento nativo (VACUUM / REINDEX) o innecesario
```

**Vocabulario en la fórmula:** REORG · GARBAGE · S500BD04TARJETAS · DMSII · mantenimiento

**Excepciones:**
- Tarea específica de DMSII; probablemente obsoleta en el motor target (evaluar retiro).
- Debe coordinarse con ventanas de indisponibilidad (RN-S500-884).

**Estado validación:** Verificado fuente

---

## RN-S500-898 — Propósito y estrategia de migración: WFL_REORG_GARBAGE_S500BD01CAPTACION

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-898 |
| **Nombre** | Propósito y estrategia de migración: WFL_REORG_GARBAGE_S500BD01CAPTACION |
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
| **Programa ejecutor** | S500_WFL_REORG_GARBAGE_S500BD01CAPTACION |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** WFL de reorganización/garbage collection del data set DMSII de captación (BD01). Equivalente a RN-S500-897 pero sobre la base de captación (cuentas, contratos, movimientos del día). Estrategia REEMPLAZAR ORQUESTADOR: sustituir por mantenimiento nativo del motor target orquestado, o retirar si el motor gestiona espacio automáticamente. Nota del fuente: la reorganización de BD01 opera ON-LINE, lo que impone requisitos de mantenimiento sin downtime en el target.

**Fórmula/pseudocódigo:**
```
JOB REORG_GARBAGE(S500BD01CAPTACION):   // ON-LINE
  reorganizar estructura física DMSII + liberar garbage
  // target: mantenimiento online nativo o innecesario
```

**Vocabulario en la fórmula:** REORG · GARBAGE · S500BD01CAPTACION · DMSII · ON-LINE

**Excepciones:**
- Requisito de mantenimiento ON-LINE (sin downtime) al elegir motor y estrategia target.
- Coordinar con reorg de estructuras nuevas (MAKERCHEK, PANTASUC) referidas en el DASDL.

**Estado validación:** Verificado fuente

---

## RN-S500-899 — Propósito y estrategia de migración: INC_PRO

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-899 |
| **Nombre** | Propósito y estrategia de migración: INC_PRO |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_INC_PRO |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Copybook (INCLUDE) de PROCEDIMIENTOS compartidos del sistema S500: define rutinas reutilizables incluidas en múltiples programas. Estrategia MIGRAR MODELO TARGET: el copybook no es un artefacto ejecutable independiente; su contenido debe consolidarse en una librería/módulo compartido del target (funciones comunes), eliminando la duplicación por inclusión textual y versionando la dependencia como paquete.

**Fórmula/pseudocódigo:**
```
// include textual de procedimientos comunes
INCLUDE PRO -> {PROCEDURE comunes}
// target: módulo/paquete compartido versionado
```

**Vocabulario en la fórmula:** INC · PRO · PROCEDURE · include · módulo compartido

**Excepciones:**
- La inclusión textual copia estado/definiciones; verificar colisiones al modularizar.
- Debe versionarse como dependencia explícita en el target.

**Estado validación:** Verificado fuente

---

## RN-S500-900 — Propósito y estrategia de migración: INC_WOR

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-900 |
| **Nombre** | Propósito y estrategia de migración: INC_WOR |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_INC_WOR |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Copybook (INCLUDE) de WORKING-STORAGE compartido del sistema S500: define estructuras de datos de trabajo (variables, buffers, áreas de intercambio) reutilizadas por múltiples programas. Estrategia MIGRAR MODELO TARGET: mapear las estructuras a DTOs/tipos del modelo destino; separar datos de dominio de datos técnicos de trabajo, y eliminar el estado compartido implícito que introduce la inclusión textual.

**Fórmula/pseudocódigo:**
```
// include textual de working-storage
INCLUDE WOR -> {01 WS-... estructuras de trabajo}
// target: DTOs/tipos por contexto
```

**Vocabulario en la fórmula:** INC · WOR · WORKING-STORAGE · WS · DTO

**Excepciones:**
- Las áreas de trabajo compartidas pueden ocultar acoplamiento entre programas.
- Distinguir estructuras de dominio vs. técnicas al mapear al target.

**Estado validación:** Verificado fuente

---

## RN-S500-901 — Propósito y estrategia de migración: INC_MAPLI_WOR

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-901 |
| **Nombre** | Propósito y estrategia de migración: INC_MAPLI_WOR |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_INC_MAPLI_WOR |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Copybook (INCLUDE) del working-storage del subsistema MAPLI: define las áreas de datos de entrada/salida de las máscaras/pantallas (p. ej. `WS-DATA-IN-SCREEN`, campos por pantalla como 50002 depósitos/retiros). Estrategia MIGRAR MODELO TARGET: transformar las definiciones de pantalla (PIC, REDEFINES) en esquemas de formulario/DTO del front target, preservando las validaciones de formato de entrada (longitudes, tipos, redefiniciones).

**Fórmula/pseudocódigo:**
```
// áreas de entrada de máscaras
01 WS-DATA-IN-SCREEN
   02 WS-IN-50002-DEPOS-Y-RET
      03 WSI-02-CVE-TRAN  PIC 9(004)  // validación de formato
// target: esquema de formulario/DTO validado
```

**Vocabulario en la fórmula:** MAPLI_WOR · WS-DATA-IN-SCREEN · PIC · REDEFINES · pantalla

**Excepciones:**
- Las cláusulas PIC/REDEFINES codifican validaciones que deben preservarse explícitamente.
- Depende de la migración de L035_MAPLI (RN-S500-887) y del esquema DASDL MAPLI.

**Estado validación:** Verificado fuente

---

## RN-S500-902 — Propósito y estrategia de migración: INC_MAPLI_PRO

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-902 |
| **Nombre** | Propósito y estrategia de migración: INC_MAPLI_PRO |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_INC_MAPLI_PRO |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Copybook (INCLUDE) con la lógica/procedimientos del subsistema MAPLI: rutinas de carga, validación y despliegue de máscaras de pantalla. Estrategia MIGRAR MODELO TARGET: consolidar la lógica de presentación en un módulo de UI/BFF del target, separando la orquestación de pantalla del acceso a datos MAPLI y de las reglas de dominio.

**Fórmula/pseudocódigo:**
```
// procedimientos de pantalla
INCLUDE MAPLI_PRO -> {CARGA_MASCARA, VALIDA_MASCARA, DESPLIEGA}
// target: componente UI/BFF
```

**Vocabulario en la fórmula:** MAPLI_PRO · máscara · CARGA · VALIDA · DESPLIEGA

**Excepciones:**
- Separar presentación de dominio para evitar arrastrar lógica de negocio a la UI.
- Depende del par MAPLI_WOR (RN-S500-901) y de L035_MAPLI (RN-S500-887).

**Estado validación:** Verificado fuente

---

## RN-S500-903 — Propósito y estrategia de migración: INC_L010

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-903 |
| **Nombre** | Propósito y estrategia de migración: INC_L010 |
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
| **Programa ejecutor** | S500_INC_L010 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Copybook (INCLUDE) de las estructuras/definiciones de control asociadas a L010_CONTROL: parámetros, banderas y constantes del sistema incluidas por los programas del núcleo. Estrategia MIGRAR MODELO TARGET: externalizar estas definiciones a un esquema de configuración compartido (config service/feature flags) y a constantes tipadas del target, evitando su propagación por inclusión textual.

**Fórmula/pseudocódigo:**
```
// include de definiciones de control
INCLUDE L010 -> {parámetros, banderas, constantes de sistema}
// target: config schema + constantes tipadas
```

**Vocabulario en la fórmula:** L010 · control · parámetro · bandera · constante

**Excepciones:**
- Debe versionarse junto con L010_CONTROL (RN-S500-893) para mantener coherencia.
- Evitar duplicación de constantes entre copybook y librería al modularizar.

**Estado validación:** Verificado fuente

---

## RN-S500-904 — Propósito y estrategia de migración: DASDL_CAPTACION

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-904 |
| **Nombre** | Propósito y estrategia de migración: DASDL_CAPTACION |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_DASDL_CAPTACION (S500BD01CAPTACION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** DASDL (Data And Structure Definition Language) del esquema físico de captación S500BD01CAPTACION (DMSII, SSR 62.0, owner BANAMEX). Define los data sets del corazón transaccional: contratos, control, movimientos del día (MOVDIA), pagos pendientes, cuentas CPE, maker-checker y pantallas por sucursal. Estrategia MIGRAR MODELO TARGET: traducir cada data set DMSII a tablas/agregados del modelo destino, preservando claves, sets (índices) y relaciones; mapear tipos DMSII a tipos del motor target y rediseñar la reorganización online como mantenimiento nativo.

**Fórmula/pseudocódigo:**
```
DATABASE S500BD01CAPTACION (STRUCTURE 01):
  DATA SET S500B03CONTRATOS, S500B02CONTROL, S500B07MOVDIA,
           S500B25PGOSPENDPE, S500B39CTASCPE, S500B56MAKERCHEK,
           S500B57PANTASUC
  // DMSII sets -> índices/claves target ; DUMPSTAMP -> versionado
```

**Vocabulario en la fórmula:** DASDL · S500BD01CAPTACION · DATA SET · MOVDIA · CONTRATOS · SET

**Excepciones:**
- Al modificar POPULATION de un data set debe liberarse P104 (dependencia hard-code): rediseñar tal acoplamiento en el target.
- La reorganización es ON-LINE; el motor target debe soportar cambios de esquema sin downtime.
- El data set MAKERCHEK implica flujo de doble autorización a preservar.

**Estado validación:** Verificado fuente

---

## RN-S500-905 — Propósito y estrategia de migración: DASDL_TARJETAS

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-905 |
| **Nombre** | Propósito y estrategia de migración: DASDL_TARJETAS |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_DASDL_TARJETAS (S500BD04TARJETAS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** DASDL del esquema físico de tarjetas S500BD04TARJETAS (DMSII). Define los data sets y sets de acceso del dominio de tarjetas (plásticos, intercambio, cargos). Estrategia MIGRAR MODELO TARGET: traducir a agregado "Tarjeta" con sus tablas/índices en el motor destino, alineando el mapeo con la capa de acceso L039_ACCESOBD04 (RN-S500-885) y con el WFL de reorg BD04 (RN-S500-897).

**Fórmula/pseudocódigo:**
```
DATABASE S500BD04TARJETAS:
  DATA SET tarjetas + sets (claves de acceso)
  // DMSII -> tablas/índices target del agregado Tarjeta
```

**Vocabulario en la fórmula:** DASDL · S500BD04TARJETAS · DATA SET · tarjeta · SET

**Excepciones:**
- Debe migrarse en conjunto con la DAL L039 (RN-S500-885) para preservar contratos de acceso.
- La reorganización física (RN-S500-897) es específica de DMSII; evaluar retiro en el target.

**Estado validación:** Verificado fuente

---

## RN-S500-906 — Propósito y estrategia de migración: DASDL_AUXILIAR

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-906 |
| **Nombre** | Propósito y estrategia de migración: DASDL_AUXILIAR |
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
| **Programa ejecutor** | S500_DASDL_AUXILIAR |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** DASDL del esquema físico auxiliar del sistema S500: data sets de apoyo (tablas paramétricas, catálogos, estructuras temporales o de soporte). Estrategia MIGRAR MODELO TARGET: clasificar cada data set auxiliar como catálogo/referencia o dato técnico, y mapearlo a tablas de referencia o cachés del target; candidatos a consolidación o retiro según su uso real.

**Fórmula/pseudocódigo:**
```
DATABASE S500 AUXILIAR:
  DATA SET auxiliares (catálogos / soporte)
  // target: tablas de referencia / cachés ; evaluar retiro
```

**Vocabulario en la fórmula:** DASDL · AUXILIAR · catálogo · referencia · DATA SET

**Excepciones:**
- Confianza media: contenido específico a inventariar data set por data set.
- Algunos auxiliares pueden ser obsoletos; validar uso antes de migrar.

**Estado validación:** Stub arquitectural

---

## RN-S500-907 — Propósito y estrategia de migración: DASDL_TELETON

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-907 |
| **Nombre** | Propósito y estrategia de migración: DASDL_TELETON |
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
| **Programa ejecutor** | S500_DASDL_TELETON |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** DASDL del esquema físico del proceso Teletón (recaudación/donativos): data sets de autorizaciones, donativos y control del evento. Estrategia MIGRAR MODELO TARGET: mapear a agregado "Recaudación/Donativo" del target, alineado con la librería de autorizaciones L045_TELETON (RN-S500-881), preservando la relación autorización ↔ donativo.

**Fórmula/pseudocódigo:**
```
DATABASE S500 TELETON:
  DATA SET donativos, autorizaciones, control_evento
  // target: agregado Recaudación/Donativo
```

**Vocabulario en la fórmula:** DASDL · TELETON · donativo · autorización · recaudación

**Excepciones:**
- Migrar junto con L045_TELETON (RN-S500-881) para preservar el flujo de autorización.
- Confianza media: estructura interna a inventariar.

**Estado validación:** Stub arquitectural

---

## RN-S500-908 — Propósito y estrategia de migración: DASDL_MAPLI

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-908 |
| **Nombre** | Propósito y estrategia de migración: DASDL_MAPLI |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_DASDL_MAPLI |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** DASDL del esquema físico MAPLI: persistencia de definiciones de mapas/pantallas del sistema de captación. Estrategia MIGRAR MODELO TARGET: convertir el catálogo de pantallas en configuración declarativa (metadata de formularios) del front target, separándola del motor DMSII; candidata a store de configuración en lugar de tabla transaccional.

**Fórmula/pseudocódigo:**
```
DATABASE S500 MAPLI:
  DATA SET definiciones_de_mapa (por id_pantalla)
  // target: config store de formularios / metadata UI
```

**Vocabulario en la fórmula:** DASDL · MAPLI · mapa · pantalla · definición

**Excepciones:**
- Migrar con L035_MAPLI (RN-S500-887) y copybooks MAPLI (RN-S500-901/902).
- Al ser metadata de UI, considerar store de configuración en vez de BD transaccional.

**Estado validación:** Verificado fuente

---

## RN-S500-909 — Propósito y estrategia de migración: DASDL_ATRIBUCTA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-909 |
| **Nombre** | Propósito y estrategia de migración: DASDL_ATRIBUCTA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [REGLA-BANCARIA-MX] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | S500_DASDL_ATRIBUCTA |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** DASDL del esquema físico de atributos de cuenta (ATRIBUCTA): características, banderas y clasificaciones asociadas a las cuentas de captación. Estrategia MIGRAR MODELO TARGET: incorporar los atributos como propiedades del agregado "Cuenta" en el modelo destino, evaluando cuáles son atributos de negocio (regulatorios/producto) versus técnicos, y normalizando catálogos de clasificación.

**Fórmula/pseudocódigo:**
```
DATABASE S500 ATRIBUCTA:
  DATA SET atributos_de_cuenta (banderas, clasificaciones)
  // target: propiedades del agregado Cuenta + catálogos
```

**Vocabulario en la fórmula:** DASDL · ATRIBUCTA · atributo · cuenta · clasificación

**Excepciones:**
- Distinguir atributos regulatorios/producto de banderas técnicas al mapear.
- Confianza media: catálogo de atributos a inventariar.

**Estado validación:** Stub arquitectural

---

## RN-S500-910 — Propósito y estrategia de migración: DASDL_MSGAAPLI

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-910 |
| **Nombre** | Propósito y estrategia de migración: DASDL_MSGAAPLI |
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
| **Programa ejecutor** | S500_DASDL_MSGAAPLI |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** DASDL del esquema físico de mensajes de aplicación (MSGAAPLI): catálogo de mensajes/textos que la aplicación despliega al usuario (errores, avisos, confirmaciones). Estrategia MIGRAR MODELO TARGET: externalizar como catálogo de mensajes/i18n (resource bundle o tabla de textos), desacoplado del código y de DMSII, permitiendo gestión centralizada y multilenguaje.

**Fórmula/pseudocódigo:**
```
DATABASE S500 MSGAAPLI:
  DATA SET mensajes (id_mensaje -> texto)
  // target: catálogo de mensajes / i18n resource bundle
```

**Vocabulario en la fórmula:** DASDL · MSGAAPLI · mensaje · texto · catálogo

**Excepciones:**
- Es data de configuración/presentación; no requiere BD transaccional en el target.
- Confianza media: estructura y códigos de mensaje a inventariar.

**Estado validación:** Stub arquitectural
