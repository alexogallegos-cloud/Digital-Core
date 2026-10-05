# ADR-EB-003 — Federación via SQLite ATTACH (vs API runtime entre brains)

**Estado**: APROBADO
**Fecha**: 2026-09-29
**Autores**: alejandro.gallegos@accenture.com
**Contexto**: Arquitectura de agregación de múltiples brains de sistemas individuales en el bank-brain

---

## Contexto

Un cliente con múltiples sistemas legacy (ej. BanCoppel con Informix + AppMóvil + Unity) necesita una vista consolidada de capabilities, gaps y dependencias cross-sistema. La pregunta es: ¿cómo agrega el bank-brain los datos de los N brains individuales?

Dos opciones principales:
- **API runtime**: bank-brain.py llama a `brain.py` de cada sistema en tiempo de ejecución
- **SQLite ATTACH**: bank-brain.db abre los brain.db individuales directamente con `ATTACH DATABASE`

---

## Decisión

**SQLite ATTACH DATABASE** es el mecanismo canónico de federación del bank-brain.

```sql
-- En bank-brain.py, al conectar:
ATTACH 'systems/core/informix/digital-brain/brain.db' AS informix;
ATTACH 'systems/channels/appmovil/digital-brain/brain.db' AS appmovil;
ATTACH 'systems/core/unity/digital-brain/brain.db' AS unity;

-- Consulta federada:
SELECT 'informix' AS sistema, id, l3_name, coverage_status FROM informix.capabilities
UNION ALL
SELECT 'appmovil', id, l3_name, coverage_status FROM appmovil.capabilities
UNION ALL
SELECT 'unity', id, l3_name, coverage_status FROM unity.capabilities;
```

> **[ENMIENDA 2026-10-05]** El ejemplo original consultaba `etb_l3`, tabla que
> ADR-EB-006 retiró en favor de `capabilities` con columna `ontology`, porque en
> el estate conviven cuatro ontologías incompatibles. Quedó corregido contra el
> schema vigente: un ejemplo canónico que no corre es tan dañino como una regla
> falsa, porque se copia tal cual.

---

## Razones

1. **Cero latencia de red**: ATTACH es I/O de disco local — las queries cross-brain son tan rápidas como queries en un solo brain.
2. **Sin protocolo de API**: no hay serialización/deserialización JSON, no hay gestión de versiones de API, no hay endpoints que mantener.
3. **SQL completo cross-brain**: se pueden hacer JOINs entre tablas de sistemas distintos — algo imposible con API runtime sin materializar los datos.
4. **Consistencia transaccional**: las lecturas de múltiples brains en una misma query son atómicas — no hay riesgo de leer estados intermedios.
5. **Agregar un sistema = una línea**: `ATTACH 'nuevo-sistema/brain.db' AS nuevo` — no hay nuevo endpoint, no hay configuración adicional.
6. **Alineado con ADR-EB-001**: ATTACH es una feature nativa de SQLite — refuerza la apuesta por SQLite como motor canónico.

---

## Consecuencias

- **Todos los brain.db deben estar en el mismo filesystem** (o accesibles por ruta local) al momento de ejecutar el bank-brain. Para equipos remotos, se comparte la carpeta del proyecto.
- **El bank-brain no es un servicio**: es un script Python que se ejecuta localmente. No hay server del bank-brain que levantar.
- **Actualizar un brain individual requiere re-ejecutar el bank-brain**: si se rebuilda el brain de Informix, el bank-brain automáticamente refleja los cambios en la próxima conexión (ATTACH abre el archivo en el estado actual).
- **Límite de ATTACH en SQLite**: máximo 10 bases de datos simultáneas por conexión. Para clientes con > 10 sistemas, usar múltiples conexiones o un bank-brain por cluster de sistemas.

---

## Alternativas rechazadas

| Alternativa | Por qué se rechazó |
|-------------|-------------------|
| API runtime (brain.py HTTP) | Latencia de red, gestión de endpoints, no permite JOINs cross-sistema, complejidad operativa desproporcionada. |
| ETL a una base centralizada | Crea un tercer artefacto que sincronizar — introduce lag y riesgo de inconsistencia. |
| GraphQL federation | Overkill — los brains son herramientas de análisis interno, no APIs públicas. |

---

*ADR-EB-003 · Enterprise Brain · Digital Core · Accenture México · 2026-09-29*
