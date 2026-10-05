# Contrato JSON — transpilación COBOL/ALGOL/WFL → Java 21 · Spring Boot 3

Un archivo por componente: `knowledge-base/transpilacion/{SISTEMA}_{PROGRAMA}.json` (UTF-8, sin BOM).
El generador `generators/build-cobol-java.py` lo convierte en `portal/cobol-java/{SISTEMA}_{PROGRAMA}.html`.
El inventario de entrada es `knowledge-base/transpilacion/_inventario.json` (sistema, programa, arquetipo, fuente, reglas del brain).

## Estructura

```json
{
  "slug": "S500_P420",
  "sistema": "S500",
  "programa": "P420",
  "nombre": "Concentrador de Saldos de Tarjeta",
  "funcion": "Una línea: qué hace y cuándo corre (batch nocturno, en línea, librería invocada por…)",
  "resumen": "2 a 4 oraciones en prosa: qué entra, qué hace, qué sale. Basado en el fuente, no en suposiciones.",
  "arquetipo": "A1",
  "lenguaje_origen": "COBOL85 | ALGOL | WFL | DASDL",
  "target": "Java 21 · Spring Boot 3 · Spring Batch",
  "paquete_java": "mx.banamex.s500.tarjetas.saldos",
  "secciones": [
    {
      "titulo": "Estructura de datos — WS-REGTB (90 bytes)",
      "origen": {"archivo": "P420.cbl", "contexto": "WORKING-STORAGE"},
      "java":   {"archivo": "CardBalanceRecord.java", "contexto": "record · sealed interface"},
      "segmentos": [
        {
          "id": "s1",
          "titulo": "Registro con 3 vistas REDEFINES → sealed interface",
          "linea_ini": 333,
          "linea_fin": 349,
          "origen_codigo": "       01 WS-REGTB-HEADER.\n          02 WS-TB-TIPO-REG   PIC 9.\n...",
          "java_codigo": "public sealed interface CardBalanceRecord\n    permits HeaderRecord, DetailRecord, TrailerRecord {}",
          "racional": "Por qué esta traducción. HTML permitido: <b>, <code>, <br>.",
          "reglas": ["RN-S500-764"],
          "riesgo": "Opcional. Ej.: COMP-3 sin ROUNDED trunca; en Java usar RoundingMode.DOWN."
        }
      ]
    }
  ],
  "riesgos": [{"titulo": "Trailer sin validar", "detalle": "La validación de conteo está comentada en las líneas 1201-1210…"}],
  "pendientes_revision": ["Confirmar con SME si el prefijo S001 de cheques sigue vigente"],
  "estado": "BORRADOR IA · pendiente revisión SME",
  "generado": "2026-10-01"
}
```

## Reglas obligatorias

1. **`origen_codigo` es copia literal del fuente.** Copia las líneas tal como están en el archivo, quitando solo el número de secuencia de las columnas 1-6 y los espacios al final; omite líneas vacías. `linea_ini` y `linea_fin` usan la numeración lógica que muestran `Read` y `Grep` (los fuentes S500 terminan en CR CR LF; no cuentes doble). Puedes omitir líneas intermedias para quedarte con lo relevante, siempre en el orden del fuente: el generador ubica cada línea, calcula el rango real e inserta un marcador visible "⋯ N líneas omitidas" o "⋯ continúa en la línea N". Los segmentos con líneas que no existen en el fuente se marcan en rojo.
2. **Nunca inventes IDs de regla.** `reglas` solo puede contener IDs que existan en `reglas_brain` del inventario (tabla `rules` de brain.db). Si un segmento no corresponde a ninguna regla, deja la lista vacía.
3. **Cobertura:** entre 2 y 4 secciones y entre 6 y 12 segmentos por componente. Elige lo representativo: estructura de datos principal, control del ciclo principal, las reglas de negocio con más peso (cálculos, validaciones, decisiones), E/S a DMSII o archivos, y manejo de errores. No es una transpilación completa; es la demostración de los patrones del componente.
4. **Java realista y consistente con el arquetipo** (ver `arq-tobe.html`): A1 Concentrador → Spring Batch con `MultiResourceItemReader`; A2 Validador-Actualizador → `ItemProcessor` + JPA + `@Transactional`; A3 Reporteador → JasperReports + `ClassifierCompositeItemWriter`; A4 Intercambiador → Spring Integration / Kafka / adaptadores ISO 20022; A5 Orquestador (WFL) → Spring Batch `Flow` / `JobExecutionDecider` / Spring Cloud Data Flow; A6 Distribuidor → `Classifier` + `PartitionedStep`; L Librería → clase `@Component`/`@Service` reusable con la misma interfaz que exponía la librería.
5. **Aritmética financiera:** `PIC 9(n)V99` y `COMP-3` → `BigDecimal` con la escala del PIC. COBOL sin `ROUNDED` **trunca** → `RoundingMode.DOWN`; con `ROUNDED` → `RoundingMode.HALF_UP`. Nunca `double`/`float` para importes. Números de cuenta → `String` (preservan ceros).
6. **Fechas:** formatos AAMMDD/DDMMAA/julianos y pivotes Y2K se traducen a `LocalDate` con el pivote explícito en el código.
7. **Hardcodes** (sucursal, prefijos de ruta, códigos de sistema) → propiedad en `application.yml` y mencionarlo en el racional.
8. **Prosa humana** en `resumen`, `racional`, `riesgos`: oraciones completas, sin flechas decorativas, sin emojis, empezando con mayúscula. Español.
9. **Honestidad:** si algo no se entiende del fuente, dilo en `pendientes_revision`; no adivines comportamiento.
10. Ids de segmento `s1..sN` únicos dentro del archivo, en orden de aparición.
