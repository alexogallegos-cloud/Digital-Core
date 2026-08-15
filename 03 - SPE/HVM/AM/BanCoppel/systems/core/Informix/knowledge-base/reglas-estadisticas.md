# Resumen Estadístico — Gemelo Cognitivo BanCoppel Informix
> Generado: 2026-08-14 · digital-brain/brain.db

## Dimensiones del corpus

| Métrica | Valor |
|---|---|
| Total reglas extraídas | 11,571 |
| Stored Procedures únicos | 4,073 |
| Bases de datos cubiertas | 49 |
| Nombres de negocio únicos | 3,573 |
| Reglas con referencia regulatoria | 2,444 |
| Reglas con nivel de riesgo | 11,571 |

## Distribución por clase

| Clase | Reglas | % |
|---|---|---|
| NEGOCIO | 9,854 | 85.2% |
| INFRAESTRUCTURA | 1,557 | 13.5% |
| ENSAMBLAJE_REPORTE | 99 | 0.9% |
| PRESENTACION | 61 | 0.5% |

## Distribución por sub_tipo

| sub_tipo | Reglas |
|---|---|
| `CÓDIGO_RETORNO` | 2,128 |
| `CÁLCULO_ARITMÉTICO` | 1,803 |
| `VALIDACIÓN_CAMPO` | 1,718 |
| `EXCEPCIÓN` | 1,585 |
| `CONTROL_FLUJO` | 1,330 |
| `COMANDO_SHELL` | 1,137 |
| `RUTA_ARCHIVO` | 388 |
| `CÁLCULO_PORCENTUAL` | 345 |
| `CÁLCULO_FECHA` | 225 |
| `CÁLCULO_INVERSIÓN` | 172 |
| `CÁLCULO_MONETARIO` | 140 |
| `CONSTRUCCIÓN_CADENA` | 130 |
| `UMBRAL_SIMPLE` | 125 |
| `CONSTRUCCIÓN_CONSULTA` | 98 |
| `CÁLCULO_FISCAL` | 37 |
| `UMBRAL_RANGO` | 36 |
| `UMBRAL_FECHA` | 36 |
| `UMBRAL_MONTO` | 34 |
| `VARIABLE_CONFIG` | 32 |
| `FORMATO_FECHA` | 32 |
| `CÁLCULO_INTERÉS` | 27 |
| `ASIGNACIÓN_ESTADO` | 6 |
| `FORMATO_MENSAJE` | 4 |
| `UMBRAL_PLD` | 2 |
| `CONFIGURACIÓN_REPORTE` | 1 |

## Bases de datos más ricas en reglas de negocio

| Base de datos | Reglas NEGOCIO |
|---|---|
| `bdicred` | 1,544 |
| `bdicnweb` | 1,237 |
| `bdicheq` | 1,080 |
| `bdidigital` | 921 |
| `bdmis` | 836 |
| `bdiprospectos` | 520 |
| `bdinteg` | 508 |
| `bdirech` | 465 |
| `bdireports` | 425 |
| `bdiresp` | 265 |
| `bdirepaut` | 244 |
| `bdisolic` | 234 |
| `bdinvers` | 136 |
| `bdisac` | 135 |
| `bdiprog` | 110 |

## Cobertura regulatoria

- **CNBV**: 1,424 reglas
- **CONDUSEF**: 478 reglas
- **CONDUSEF; CNBV**: 114 reglas
- **IPAB**: 114 reglas
- **SAT; CNBV**: 97 reglas
- **Banxico**: 45 reglas
- **CNBV; IPAB**: 42 reglas
- **SAT; IPAB**: 38 reglas
- **SAT**: 27 reglas
- **TESOFE**: 20 reglas

## Historial de enriquecimiento

| Swarm | Alcance | Resultado |
|---|---|---|
| Swarm 1 (15 señales) | 6,067 reglas NEGOCIO | 84.4% → HIGH coherencia |
| Swarm 2 (4 agentes) | bdicheq/bdicnweb/bdicred/bdinteg | 733 MEDIUM→HIGH |
| Swarm 3 (2 agentes) | dominios periféricos | 67 enrichments |
| Swarm G1-G2 | 205 nombres con prefijo SPL | corrección semántica |
| Swarm H | 51 patrones [CODE] ELSE | corrección semántica |
| Swarm I | 49 patrones Retorna/condición cruda | corrección semántica |
| Swarm J | 1,018 condiciones SPL → español | traducción automática |
| Sub_tipos | 5,504 reglas sin clasificar | taxonomía completa 25 sub_tipos |
| Swarm K | 2,128 reglas CÓDIGO_RETORNO | enriquecimiento semántico con contexto de SP y convención de código — 4,747 grupos únicos |

## Tablas de parametrización en brain.db (nuevas)

| Tabla | Filas | Propósito |
|---|---|---|
| `codret_dictionary` | 329 | Diccionario de convenciones: código de retorno → categoría + descripción canónica en español |
| `rule_enrichment_log` | 2,128+ | Provenance completo de cada enriquecimiento: swarm, campo, valor anterior, nuevo, confianza, método |

### Distribución codret_dictionary por convención

| Convención | Códigos | Descripción |
|---|---|---|
| `PARAM_MISSING` | 67 | Parámetro obligatorio no proporcionado |
| `BUSINESS_RULE` | 77 | Regla de negocio no cumplida |
| `NOT_FOUND` | 42 | Registro no localizado |
| `PARAM_EMPTY` | 18 | Parámetro vacío o en blanco |
| `SYSTEM_ERROR` | 16 | Error de sistema o excepción |
| `OK` | 2 | Éxito (`1001`, `0`) |
| `SENTINEL` | 2 | Señal centinela (`11111`, `10010`) |
| `UNKNOWN` | 105 | Sin clasificar (códigos con poca evidencia) |

### Fuente del conocimiento en codret_dictionary

| Fuente | Códigos | Confianza típica |
|---|---|---|
| `extracted_comment` | 122 | 0.80–0.90 |
| `manual` / `manual+comment` | 32 | 0.90–0.99 |
| `pattern_inference` | 175 | 0.55–0.75 |

### Fórmula canónica de business_name (Swarm K)

```
[Verbo de operación] de [sujeto de negocio] [resultado]: [condición específica]
```

Ejemplos:
- "Transacción de cargo y débito/crédito rechazada por regla de negocio: fondos insuficientes débito"
- "Consulta de periodo y ingreso interrumpida: no existe el tipo de ingreso de aclaración"
- "Registro de inserta log fallida: la operación no afectó ningún registro"

### Fuentes de condición por prioridad

1. **inline_comment** (0.90): comentario `--` en el código fuente del SP
2. **condition_pattern** (0.80): patrón extraído del SPL (`IS NULL`, `!= ""`, etc.)
3. **bn_existing** (0.75): business_name anterior si era descriptivo
4. **bn_fallback** (0.55): business_name anterior si es parcialmente útil