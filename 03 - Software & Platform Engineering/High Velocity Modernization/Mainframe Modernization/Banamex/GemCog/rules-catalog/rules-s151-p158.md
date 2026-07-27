# Reglas de Negocio — P158 (Generador de Estado de Cuenta S500→S050)
> **Capacidad bancaria:** 6.1.4 Statements · Generación de estado de cuenta captación (MOVSXCONT)
> **Nota QC 2026-07-20:** Reclasificado de T.3.4 → 6.1.4. P158 genera movimientos por contrato para estados de cuenta — función Statement, no batch control. Corrección pendiente en bian-mapping-s151.md (requiere re-run build-traceability.py).
> **Programa fuente:** COBOL_P158.txt · Autor: ING FRANCISCO JAVIER HERNANDEZ GONZALEZ
> **Frecuencia:** cierre-diario
> **Sistemas downstream:** S050 (clientes) · BNE · TESOFE S701 · REPDEVOL · LOG151/LOG151-COMP
> **Rango:** RN-S151-361 a RN-S151-390 (30 reglas)
> **Actualizado:** 2026-07-16
**Indexado:** ✅ 2026-07-17 — correlacionado vocab↔reglas↔capacidad (traceability-matrix.md)

---

## RN-S151-361

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-361 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Sistema 407 es alias de 408, que a su vez es alias de 500 en la lógica de catálogos.
**Estado validación:** Verificado en PROCEDURE DIVISION líneas 9195-9373.

---

## RN-S151-362

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-362 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** MOVSXCONT-087 usa "/S151MOV" en lugar de "/MOV" — path diferente al resto.
**Estado validación:** Verificado en FILE-CONTROL y WKS-TIT-MOVSXCONT* líneas 509-639.

---

## RN-S151-363

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-363 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Movimientos del mismo contrato en distintos SUBNODOS quedan en archivos de salida separados.
**Estado validación:** Verificado en ARCH-ORD sort key estructura y WKS-SORT-REG.

---

## RN-S151-364

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-364 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Sistema 408 (alias de 500) no genera MOVSXCONT-500 a pesar de ser captación — verifica lógica con negocio.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONT-500 línea 509 y condición SIST-PARAM.

---

## RN-S151-365

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-365 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Si NOMPACMOV es SPACES en BD99, el LOG151 se crea en pack default — puede ser incorrecto.
**Estado validación:** Verificado en WKS-TIT-LOG151 líneas 452-460.

---

## RN-S151-366

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-366 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Acceso RANDOM con clave inválida en LOG151-COMP genera error de I/O — debe validarse W77-LOG-KEY antes.
**Estado validación:** Verificado en WKS-TIT-LOG151-COMP líneas 465-473 y FD LOG151-COMP.

---

## RN-S151-367

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-367 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** REPDEVOL abierto pero sin registros escritos produce archivo vacío — no error.
**Estado validación:** Verificado en FILE-CONTROL línea 50 y FD REPDEVOL línea 128.

---

## RN-S151-368

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-368 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Bonificaciones incluidas en el MOVSXCONT principal pero reportadas por separado en MOVBONIFICA — posible doble conteo al reconciliar.
**Estado validación:** Verificado en FILE-CONTROL (SELECT MOVBONIFICA ASSIGN TO PRINTER).

---

## RN-S151-369

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-369 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** NUMCSI ≠ 10 no genera TOTAL — procesos de CSIs secundarios no tienen reporte consolidado.
**Estado validación:** Verificado en líneas 12590-12638.

---

## RN-S151-370

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-370 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Interfaz con sistemas que esperan 6 dígitos de fecha producirá errores de parsing post-Y2K.
**Estado validación:** Verificado en WKS-SORT-REG líneas 694-732.

---

## RN-S151-371

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-371 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Movimientos del mismo contrato en diferentes SUCPROM pueden quedar separados en el sort si SUCPROM varía.
**Estado validación:** Verificado en WKS-LLAVE-ACTUAL/ANTERIOR estructura líneas 749-777.

---

## RN-S151-372

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-372 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Campos SUBC vacíos indican movimiento sin sub-contrato — no intentar lookup con CONT-SUBC=ZEROS.
**Estado validación:** Verificado en WKS-SORT-REG líneas 691-744.

---

## RN-S151-373

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-373 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Referencia S087 con PM=00 puede confundirse con referencia vacía — no filtrar PM=00.
**Estado validación:** Verificado en WKS-SORT-REG líneas 708-710 y WKS-TIT-MOVSXCONT-S087.

---

## RN-S151-374

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-374 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Al migrar, mapear WKS-SORT-HORA-DD como "segundos" no como "días" — validar con muestra de datos.
**Estado validación:** Identificado en WKS-SORT-REG líneas 715-718 — requiere validación con datos reales.

---

## RN-S151-375

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-375 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** FECINI > FECFIN produce estado de cuenta con período invertido — validar orden cronológico.
**Estado validación:** Verificado en Working Storage líneas 408-414.

---

## RN-S151-376

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-376 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Nodo incorrecto en el nombre externo envía el archivo al nodo equivocado — S050 no lo encontrará.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONT líneas 544-556.

---

## RN-S151-377

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-377 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Registro X(581) trunca campos del X(840) principal — S502 solo recibe subconjunto de campos.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONTESOF líneas 562-575.

---

## RN-S151-378

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-378 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** TESOFE tiene ventanas de recepción — envío fuera de ventana puede causar rechazo del archivo.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONTESOF2 líneas 597-610.

---

## RN-S151-379

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-379 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** S050 debe tener lógica de lectura para ambos patrones: "MOV" y "S151MOV" — si solo lee uno, perderá movimientos.
**Estado validación:** Verificado en WKS-TIT-MOVSXCONT-S087 líneas 526-539.

---

## RN-S151-380

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-380 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** CSI incorrecto en la ruta genera un archivo en ubicación equivocada — S500 no encontrará el punteo.
**Estado validación:** Verificado en WKS-TIT-SALS500 líneas 615-622.

---

## RN-S151-381

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-381 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Si P170 no está en CMEMP, P158 puede entrar en espera indefinida — debe configurarse timeout.
**Estado validación:** Verificado en WKS-TIT-INMOV líneas 658-667.

---

## RN-S151-382

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-382 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** WFL con sintaxis incorrecta (PROG name mal formado) produce error de compilación en tiempo de ejecución.
**Estado validación:** Verificado en WKS-LIS-WFL líneas 480-492.

---

## RN-S151-383

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-383 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Productos no listados en el historial pueden no tener lógica diferenciada — usan el flujo genérico.
**Estado validación:** Verificado en comentarios de FILE-CONTROL y Working Storage de P158.

---

## RN-S151-384

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-384 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Si BD99 tiene fecha de control en el futuro, P158 procesará movimientos del futuro — valida FECPRO ≤ hoy.
**Estado validación:** Verificado en líneas 9260-9288.

---

## RN-S151-385

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-385 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** CTA-1(15) con ceros iniciales puede perder ceros al hacer operaciones numéricas — usar como alfanumérico.
**Estado validación:** Verificado en WKS-LLAVE-ACTUAL líneas 749-765.

---

## RN-S151-386

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-386 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** LOGDESC1=0 y LOGDESC2=0 puede indicar sin descriptivos escritos — validar antes del cierre.
**Estado validación:** Verificado en WKS-CIERRA-DESC estructura líneas 855-858.

---

## RN-S151-387

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-387 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Si W77-ENCONTRADO nunca se activa en las 10 iteraciones, usa el último ciclo por default.
**Estado validación:** Verificado en WKS-LIBCONTROL líneas 864-899 y PERFORM 000-006 línea 9276.

---

## RN-S151-388

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-388 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Si W77-MES está fuera de rango 1-12, WKS-TAB-MES referencia memoria fuera del array — riesgo de corrupción.
**Estado validación:** Verificado en WKS-TABLA-MESES líneas 807-811.

---

## RN-S151-389

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-389 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Cualquier referencia a fechas >= 2050 producirá interpretación incorrecta del siglo.
**Estado validación:** Verificado en Working Storage A2K-BASE-YEAR línea 447.

---

## RN-S151-390

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-390 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p158 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Si NUMBASE > 3, la iteración sobre bases accede a memoria fuera de estructura — validar NUMBASE IN (1,2,3).
**Estado validación:** Verificado en WKS-151-DATOS estructura líneas 813-854.
