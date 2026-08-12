# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Código Muerto y Candidatos a Eliminación

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Advertencia regulatoria sobre la eliminación de código en bdilide

> **`[COMPLIANCE-SIGN-OFF-REQUIRED]`** — En el dominio PLD, la decisión de NO migrar un SP al target requiere sign-off explícito del Área de Cumplimiento de BanCoppel. Un SP aparentemente "muerto" puede ser parte de un proceso regulatorio que se ejecuta anualmente o bajo demanda por auditoría. La ausencia de ejecución reciente en logs NO es suficiente evidencia para descartar un SP en este dominio.

## Criterios de clasificación de código muerto

| Categoría | Criterio | Acción recomendada |
|-----------|---------|-------------------|
| `MUERTO-CONFIRMADO` | SP sin callers en callgraph Y sin ejecución en logs de producción (últimos 24 meses) Y validado por Cumplimiento como no regulatorio | Excluir del scope de migración — documentar en ADR |
| `MUERTO-PROBABLE` | SP sin callers en callgraph Y sin evidencia de ejecución reciente | Validar con Cumplimiento antes de excluir |
| `ACTIVO-AISLADO` | SP sin callers en callgraph pero con evidencia de ejecución por proceso externo (cron, scheduler) | Migrar — el caller es externo al callgraph analizado |
| `PBA-ACTIVO` | SP con sufijo `_pba` con evidencia de ejecución en producción | Migrar y renombrar |
| `PBA-SOLO-PRUEBAS` | SP con sufijo `_pba` sin evidencia de ejecución en producción | Evaluar exclusión con Cumplimiento |

## Candidatos identificados

### Candidatos `MUERTO-PROBABLE` — requieren validación de Cumplimiento

| SP | Indicadores | `[DATO-REQUERIDO]` |
|----|------------|-------------------|
| `sp_actualizaide_31052013` | Nombre contiene fecha `31052013` (31 mayo 2013) — puede ser un SP de migración puntual ya ejecutado | Verificar en logs si tuvo ejecución después de 2013 |
| `sp_actualizarfclide_pba` | Sufijo `_pba` — variante de pruebas de `sp_actualizarfclide` | Confirmar si está activo en producción |
| `sp_actualizarfclide_pba` (y otros `_pba`) | 16 SPs estimados con sufijo `_pba` | Auditar todos los `_pba` para determinar cuáles son de producción |

### SPs con fecha en el nombre (versiones históricas)

El patrón `nombre_DDMMAAAA` es una convención histórica de BanCoppel para registrar versiones de SPs sin sistema de control de versiones. Estos SPs son candidatos a código muerto pero requieren confirmación:

| Patrón | Ejemplo identificado | Acción recomendada |
|--------|---------------------|-------------------|
| `sp_*_DDMMAAAA` | `sp_actualizaide_31052013` | Verificar si fue reemplazado por una versión sin fecha; confirmar con DBA |

## Tamaño estimado de código muerto en bdilide

| Categoría | SPs estimados | LOC estimados |
|-----------|:------------:|:-------------:|
| `PBA-SOLO-PRUEBAS` (confirmados) | ~16 | ~2,000 |
| Versiones históricas con fecha en nombre | ~5 | ~700 |
| SPs aislados de bajo riesgo (utilidades) | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| **Total candidatos (optimista)** | **~21** | **~2,700** |

> Esta estimación es conservadora. La posición de partida para bdilide debe ser "migrar todo hasta que Cumplimiento autorice la exclusión", dado el riesgo regulatorio.

## Proceso de aprobación para excluir código

```
1. Specialist SPL Analysis → identifica candidato → documenta en este archivo
2. DBA IBM Informix → confirma ausencia en logs de producción (últimos 24 meses)
3. Domain Expert BanCoppel → valida ausencia de uso operacional
4. Área de Cumplimiento BanCoppel → sign-off regulatorio
5. QA Lead → documenta en golden master que la funcionalidad NO debe existir en el target
6. Registrar en ADR: adr/XXX-exclusion-sp-{nombre}.md
```

## `[SME-PENDING]`

- [ ] DBA IBM Informix: verificar en `sysprocexecution` (si existe) o en logs de AIX la última fecha de ejecución de cada SP candidato.
- [ ] Área de Cumplimiento: revisar todos los SPs con sufijo `_pba` para determinar su rol.
- [ ] Confirmar si `sp_actualizaide_31052013` fue reemplazado por otra versión o si sigue siendo el SP activo.
- [ ] Generar el listado completo de los 96 SPs aislados con su última fecha de modificación (`syscolumns.created`).

---
*Generado: análisis estático bdilide · 2026-08-03*
