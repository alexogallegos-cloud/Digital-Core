# dt-inteligencia-mercado — Digital Twin · AXA México
> Inteligencia de mercado, contexto del cliente y tendencias del sector asegurador.
> Alimenta el cerebro federado con el "por qué" detrás del landscape tecnológico.

---

## PROPÓSITO

Este Digital Twin construye y mantiene el contexto estratégico externo de AXA México:
noticias, resultados financieros, posicionamiento competitivo, expectativas del mercado
y señales de cambio regulatorio. Es el equivalente al `dt-inteligencia-cliente` de Liverpool.

**Audiencia**: Cerebro Federado (`axa-brain`) · Architects · Account Team

---

## DIMENSIONES DE ANÁLISIS

### 1. Posición de Mercado

Métricas de posicionamiento de AXA México en el mercado asegurador nacional.

| Métrica | Frecuencia de actualización | Fuente |
|---------|----------------------------|--------|
| Participación de mercado (primas emitidas) | Trimestral | CNSF Boletín Estadístico |
| Ranking por ramo P&C | Trimestral | CNSF |
| Prima directa total | Mensual / Trimestral | CNSF / Reportes AXA |
| Siniestralidad sector vs AXA | Trimestral | CNSF |
| Número de pólizas vigentes | Anual | Reporte Anual AXA |

### 2. Resultados Financieros AXA México

| Indicador | Descripción |
|-----------|-------------|
| Prima directa emitida | Total primas escritas en el período |
| Prima devengada | Prima correspondiente al período de riesgo |
| Siniestralidad neta | Siniestros pagados / prima devengada |
| Índice combinado | (Siniestros + gastos) / prima devengada |
| Resultado técnico | Utilidad del negocio asegurador |
| ROE | Retorno sobre capital |

### 3. Noticias y Eventos Relevantes

Registro vivo de noticias que afectan a AXA México o al mercado asegurador P&C:
- Cambios de liderazgo en AXA México / AXA Group
- Lanzamiento de nuevos productos o líneas de negocio
- Alianzas estratégicas y partnerships tecnológicos
- Resultados financieros públicos (reportes anuales, comunicados)
- Litigios, multas o sanciones CNSF / CONDUSEF
- Iniciativas de sostenibilidad y ESG

### 4. Panorama Competitivo

| Competidor | Fortaleza en Commercial Lines P&C | Tendencia |
|------------|-----------------------------------|-----------|
| GNP Seguros | Liderazgo en grandes riesgos | Estable |
| Seguros BBVA | Respaldo bancario · distribución | Creciendo |
| HDI Seguros | Engineering y transporte | Especialista |
| Allianz México | Líneas financieras · D&O | Creciendo |
| Zurich México | RC y flotas corporativas | Estable |
| Mapfre | Distribución masiva · autos | Estable |

### 5. Tendencias del Sector P&C México

- **Digitalización del agente**: portales de autoservicio, emisión digital
- **Parametric Insurance**: seguros indexados para agricultura, catástrofes
- **InsurTech**: competencia de startups en comercialización digital
- **Riesgo climático**: impacto en pricing de property (huracanes, inundaciones)
- **Ciber-seguros**: crecimiento acelerado en Commercial Lines
- **IFRS 17**: adaptación contable con impacto en sistemas core
- **Solvencia C**: evolución del marco de capital en México

### 6. Marco Regulatorio — Señales de Cambio

| Iniciativa | Organismo | Estado | Impacto en AXA |
|------------|-----------|--------|----------------|
| IFRS 17 implementación | CNSF / CINIF | En curso | Alto — sistemas actuariales y contables |
| Solvencia C revisión | CNSF | Evaluación | Alto — capital y reservas |
| Regulación InsurTech | CNSF | En consulta | Medio — canales digitales |
| Ciberseguridad sectorial | CNSF | Borrador | Alto — infraestructura tecnológica |
| Inclusión financiera seguros | SHCP / CNSF | En curso | Medio — productos masivos |

### 7. Expectativas y Crecimiento

| Indicador | Proyección | Fuente |
|-----------|-----------|--------|
| Crecimiento primas P&C México | +8-12% nominal anual (2025-2027) | AMIS / AXCO |
| Penetración de seguros / PIB | 2.1% → 2.5% hacia 2030 | OCDE / CNSF |
| Crecimiento Commercial Lines | Superior al mercado por ciclo favorable | AXA Group outlook |
| Inversión tech en seguros MX | Acelerando post-COVID | Capgemini WIR 2025 |

---

## ESTRUCTURA DE ARCHIVOS

```
dt-inteligencia-mercado/
├── CLAUDE.md                          ← este archivo
├── market-intelligence.md             ← documento vivo de inteligencia
├── competitive-landscape.md           ← análisis competitivo actualizado
├── regulatory-signals.md              ← señales regulatorias con impacto
├── financial-results.md               ← resultados financieros AXA México
└── sources/
    ├── cnsf-estadisticas/             ← datos CNSF descargados
    ├── axa-reportes/                  ← reportes anuales AXA México / AXA Group
    ├── noticias/                      ← recortes y resúmenes de noticias
    └── analistas/                     ← reportes de analistas / Capgemini / AXCO
```

---

## PIPELINE DE ACTUALIZACIÓN

```bash
# Actualización manual (agente lee fuentes y actualiza los MD)
# 1. Descargar boletín estadístico CNSF trimestral → sources/cnsf-estadisticas/
# 2. Revisar noticias AXA México (Google News, El Economista, Forbes MX)
# 3. Actualizar market-intelligence.md con hallazgos
# 4. Ejecutar seed-market-intel.py para cargar al brain
python seed-market-intel.py
```

---

## CÓMO ALIMENTA AL axa-brain

Los datos de este DT se cargan a `axa-brain.db` con `maturity = 'HOY'` (hechos verificados)
o `maturity = 'MAÑANA'` (señales/expectativas). La tabla destino es `market_intel`:

```sql
CREATE TABLE market_intel (
    id          INTEGER PRIMARY KEY,
    category    TEXT,  -- 'posicion' | 'financiero' | 'noticia' | 'regulatorio' | 'tendencia'
    date        TEXT,
    title       TEXT,
    body        TEXT,
    source      TEXT,
    maturity    TEXT DEFAULT 'HOY'
);
```

---

*Última actualización: 2026-09-03 · v1.0 · Scaffold inicial*