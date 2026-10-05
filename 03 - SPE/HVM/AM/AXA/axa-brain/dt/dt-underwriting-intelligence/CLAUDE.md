# dt-underwriting-intelligence — Digital Twin · Inteligencia de Suscripción
> DT de MÁXIMA PRIORIDAD — fuente: 541 pasos de proceso + 33 pain points en brain.db
> Cubre el proceso completo de suscripción de riesgos de daños comerciales en AXA México.

---

## PROPÓSITO

Responde: **¿Cómo se toma la decisión de suscripción hoy, en qué sistemas vive, dónde falla, y cuál es el camino de transformación?**

Este DT es el núcleo de inteligencia de negocio del programa. Tiene la mayor densidad de datos
verificados en el brain (541 pasos cross-LoB, 33 pain points con 5 dimensiones de causa raíz,
mapeo ETB D6 completo).

---

## SISTEMAS INVOLUCRADOS (HOY)

| Sistema | Rol en suscripción | Estado |
|---------|--------------------|--------|
| Vector | Workflow de folios — registro, seguimiento, control de expedientes | CONFIRMED-NAME |
| HSD (Excel) | Cálculo técnico — tarificación, cúmulos, condiciones especiales | GAP CRÍTICO — no es sistema |
| SINCO | Búsqueda de cuentas, antecedentes, conductos | CONFIRMED-NAME |
| ERN | Modelación catastrófica (PML, sísmica, hidro) | CONFIRMED-NAME |
| SAFAC | Registro de colocaciones de reaseguro facultativo | CONFIRMED-NAME |
| General Daños | Emisión de la póliza una vez aprobada la suscripción | CONFIRMED-NAME |
| Power BI | Consulta de siniestralidad histórica por póliza/vigencia | CONFIRMED-NAME |
| Monitor | Consulta / reporte (rol exacto por confirmar) | PARTIAL |

---

## ESTRUCTURA DE CAPAS

```
dt-underwriting-intelligence/
├── CLAUDE.md              ← este archivo
├── as-is.md               ← HOY: proceso detallado con sistemas y roles
├── gaps.md                ← GAP: pain points aplicables + capacidades ETB faltantes
├── to-be.md               ← MAÑANA: escenarios de transformación (3 alternativas)
└── process-map.md         ← mapa de proceso L1→L4 generado desde brain.db
```

---

## CAPAS DE CONOCIMIENTO

### HOY (maturity=HOY)
- 541 pasos de proceso en 7 LoBs: Property, Ramos Técnicos, RC, Marítimo, Aviación, Obras Arte, Líneas Financieras
- Fases: Preparación → Evaluación del Riesgo → Modelación Catastrófica → Definición Cotización → Negociación
- Sistemas reales: Vector + HSD (Excel) + SINCO + ERN + SAFAC + General Daños + Power BI
- Roles: Suscriptor, Coordinador, Dirección Técnica, Actuario

### GAP (el problema central)
- **HSD como herramienta crítica sin integración**: cálculo técnico en Excel manual, captura ubicación por ubicación, sin conexión con Vector ni ERN
- **ERN → HSD manual**: resultados de modelación catastrófica se trasladan a mano al Excel
- **SAFAC estructura lineal**: sin carga masiva de capas ni reaseguradores
- **General Daños recaptura manual**: condiciones aprobadas se reteclean desde el slip

### MAÑANA (maturity=MAÑANA)
Tres escenarios (desarrollar en to-be.md):
1. **Automatización incremental**: conectar Vector + HSD digitalizado + ERN (quick win — 6-12 meses)
2. **Plataforma integrada**: sustituir HSD por motor de suscripción digital integrado (12-24 meses)
3. **Underwriting Intelligence**: AI-assisted risk scoring con datos históricos Power BI (18-36 meses)

---

## QUERIES CLAVE AL BRAIN

```sql
-- Pain points críticos de suscripción
SELECT cat_c1, descripcion, lob_property, lob_ramos_tecnicos
FROM pain_points WHERE lob_suscripcion=1 ORDER BY cat_c1;

-- Pasos manuales sin sistema
SELECT COUNT(*) FROM process_steps WHERE sistemas_slugs='' OR sistemas_slugs IS NULL;

-- Capacidades ETB D6 no cubiertas
SELECT cap_id, name FROM etb_capabilities WHERE domain_l1 LIKE '%Underwriting%';
```

---

## ACTUALIZACIÓN

Fuente primaria: `axa-brain.db` (tablas `process_steps`, `pain_points`, `etb_capabilities`).
Actualizar cuando lleguen nuevas fuentes de datos del cliente (entrevistas, nuevos excels).

---

*Última actualización: 2026-09-03 · v1.0 · Scaffold con datos reales del brain*