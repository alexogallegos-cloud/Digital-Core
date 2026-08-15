# Taxonomía de Sub_tipos — BanCoppel Informix
> Generado: 2026-08-14 · Fuente: digital-brain/brain.db · Total reglas: 11571

## Propósito
Este archivo define el vocabulario canónico de `sub_tipo` en el Gemelo Cognitivo de BanCoppel.
Cada regla extraída del código SPL recibe exactamente un sub_tipo que describe su naturaleza técnica.
Los sub_tipos son la capa de clasificación granular dentro de cada `clase`.

## Jerarquía: clase → sub_tipo

### NEGOCIO (9,879 reglas)

| sub_tipo | N | Descripción |
|---|---|---|
| `CÓDIGO_RETORNO` | 2,128 | Validación que eleva excepción con código numérico de error (RAISE EXCEPTION [NNN]). Regla central del modelo de errores BanCoppel. |
| `CÁLCULO_ARITMÉTICO` | 1,803 | Operación matemática sobre variables monetarias o de conteo (suma, resta, multiplicación, división). |
| `VALIDACIÓN_CAMPO` | 1,718 | Verificación de existencia y contenido de parámetros de entrada (IS NULL, = "", comparación simple). Detectada en bloque IF sin RAISE. |
| `EXCEPCIÓN` | 1,585 | Declaración ON EXCEPTION SET o RAISE EXCEPTION sin código estructurado. Incluye manejo genérico de errores SQL. |
| `CONTROL_FLUJO` | 1,330 | Bifurcación condicional (IF/ELSE) que dirige la lógica del SP sin producir excepción ni cálculo directo. |
| `CÁLCULO_PORCENTUAL` | 345 | Cálculo de porcentajes, tasas y factores proporcionales sobre montos. |
| `CÁLCULO_FECHA` | 225 | Aritmética y comparación de fechas: días entre fechas, suma de períodos, cálculo de vencimientos. |
| `CÁLCULO_INVERSIÓN` | 172 | Cálculo de rendimientos, intereses capitalizados y reinversión de fondos de inversión. |
| `CÁLCULO_MONETARIO` | 140 | Operación monetaria de alta precisión sobre saldos, límites y montos de transacción. |
| `CONSTRUCCIÓN_CADENA` | 130 | Concatenación y formateo de strings de negocio (folios, números de referencia, mensajes compuestos). |
| `UMBRAL_SIMPLE` | 125 | Comparación contra valor límite fijo: monto máximo, mínimo, límite de crédito. |
| `CÁLCULO_FISCAL` | 37 | Cálculo de IVA, ISR, retenciones y conceptos fiscales (SAT). |
| `UMBRAL_RANGO` | 36 | Validación de que un valor cae dentro de un rango (entre mínimo y máximo). |
| `UMBRAL_FECHA` | 36 | Comparación contra fechas límite: vigencia, vencimiento, fecha de corte. |
| `UMBRAL_MONTO` | 34 | Umbral específico sobre montos de transacción (SPEI, TEF, efectivo). |
| `CÁLCULO_INTERÉS` | 27 | Cálculo de intereses ordinarios y moratorios sobre créditos. |
| `ASIGNACIÓN_ESTADO` | 6 | Asignación explícita de estatus de cuenta o operación (activo, bloqueado, cancelado, mora). |
| `UMBRAL_PLD` | 2 | Umbral regulatorio PLD/AML: montos de reporte obligatorio a CNBV/UIF. |

### INFRAESTRUCTURA (1,557 reglas)

| sub_tipo | N | Descripción |
|---|---|---|
| `COMANDO_SHELL` | 1,137 | Construcción de comandos del sistema operativo ejecutados vía SYSTEM() en Informix SPL (chmod, dbload, rm, echo). |
| `RUTA_ARCHIVO` | 388 | Asignación de ruta de archivo o directorio del sistema de archivos AIX/Informix. |
| `VARIABLE_CONFIG` | 32 | Asignación de parámetro de configuración: credenciales, nombres de servidor, paths de configuración. |
| `CONSULTA_SQL` | 0 | SQL embebido dentro de cadena de texto para ejecución dinámica. |

### ENSAMBLAJE_REPORTE (99 reglas)

| sub_tipo | N | Descripción |
|---|---|---|
| `CONSTRUCCIÓN_CONSULTA` | 98 | Construcción dinámica de sentencias SQL completas mediante concatenación de fragmentos. |
| `CONFIGURACIÓN_REPORTE` | 1 | Asignación de etiquetas, encabezados o constantes de presentación para reportes. |

### PRESENTACION (36 reglas)

| sub_tipo | N | Descripción |
|---|---|---|
| `FORMATO_FECHA` | 32 | Formateo de fecha para presentación al usuario o para salida de reporte (TO_CHAR, LPAD, concatenación de mes/año). |
| `FORMATO_MENSAJE` | 4 | Construcción de mensajes de texto destinados al usuario final o a canales externos. |

## Reglas de asignación

1. Cada regla tiene exactamente **un** sub_tipo.
2. `CÓDIGO_RETORNO` y `EXCEPCIÓN` son distintos: el primero usa código numérico estructurado `[NNN]`, el segundo es manejo genérico.
3. `VALIDACIÓN_CAMPO` aplica cuando la condición valida parámetros de entrada sin producir RAISE EXCEPTION directa.
4. Los sub_tipos `UMBRAL_*` aplican a reglas NEGOCIO con comparación contra valor límite regulatorio o de negocio.
5. `CONTROL_FLUJO` es el sub_tipo de último recurso para lógica condicional no clasificable en otro sub_tipo.

## Mapa portal → sub_tipo

El portal `rules-catalog-bcop.html` agrupa sub_tipos en 4 categorías de filtro:

| Filtro portal | sub_tipos incluidos |
|---|---|
| FÓRMULA | CÁLCULO_ARITMÉTICO · CÁLCULO_PORCENTUAL · CÁLCULO_FECHA · CÁLCULO_INVERSIÓN · CÁLCULO_MONETARIO · CÁLCULO_FISCAL · CÁLCULO_INTERÉS · CONSTRUCCIÓN_CADENA |
| VALIDACIÓN | CÓDIGO_RETORNO · EXCEPCIÓN · VALIDACIÓN_CAMPO · CONTROL_FLUJO |
| UMBRAL | UMBRAL_SIMPLE · UMBRAL_RANGO · UMBRAL_FECHA · UMBRAL_MONTO · UMBRAL_PLD |
| ESTADO | ASIGNACIÓN_ESTADO |