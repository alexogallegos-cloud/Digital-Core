# TAM — Modernización y Migración de Sistemas Legados · México · FY27
> Investigación de mercado para la práctica S&PE · Base: research secundario público (jul 2026)
> Owner: alejandro.gallegos@accenture.com · Moneda: USD

---

## Advertencia de método (leer primero)

**No existe un estudio público que reporte directamente "el TAM de modernización + migración de legados en México".** Las firmas de research (Grand View, Mordor, MarketsandMarkets, Straits, Credence) publican el mercado *global* o *LATAM* y, en el mejor caso, la participación de México en un segmento.

Por lo tanto, el número de México está **triangulado**: se deriva cruzando (a) mercados globales de cada segmento, (b) la participación conocida de LATAM y de México, y (c) el mercado mexicano de IT services / digital transformation como techo de sanidad. Cada supuesto está marcado. **No es un estudio bottom-up de México** — es una estimación defendible para dimensionar la práctica, no una cifra auditada.

---

## 1. Headline — el número para llevar a management

| Métrica | Estimación 2025 | Proyección 2030 | CAGR |
|---------|-----------------|-----------------|------|
| **TAM México — Modernización + Migración de legados** | **~$1.5B – $2.5B USD** (mid ~$2.0B) | **~$3.0B – $4.5B USD** | **~13–15%** |

Esto es la suma de tres segmentos que se solapan parcialmente: **application modernization**, **mainframe/core modernization** y **cloud migration de sistemas existentes**. El rango refleja qué tan amplia se traza la frontera (ver §4).

---

## 2. Anchors de mercado usados (fuentes públicas)

### Mercados globales

| Segmento | Tamaño 2025 | Proyección | CAGR | Fuente |
|----------|-------------|-----------|------|--------|
| Application Modernization Services | $20.5B – $22.7B | $51B (2031) · $81B (2034) | 14.6% – 16.5% | MarketsandMarkets · Polaris · SNS |
| Legacy Modernization (agregado) | $25B – $30B | $66B – $90B (2031–34) | ~12–15% | Consenso 5 firmas (vía Keyhole) |
| Mainframe Modernization | $8.2B – $8.5B | $13.34B (2030) | ~9.7% | MarketsandMarkets · Straits · DataBridge |
| Cloud Migration Services | $20.67B (2025) | — | ~20%+ | Grand View · GM Insights |

### Mercado LATAM

| Segmento | Dato | Fuente |
|----------|------|--------|
| Application Modernization LATAM | Crece ~12–16% CAGR · Brasil + México a la cabeza | MarketsandMarkets · SNS |
| Cloud Migration LATAM | 7.4% del mercado global (2024) · CAGR 27.4% (2025–30) | Grand View |
| Digital Transformation LATAM | $102.21B (2025) → $364.30B (2034) · CAGR 15.17% | IMARC |
| Mainframe Modernization LATAM | Brasil ~45% · **México ~30%** de la participación regional | Credence Research |

### Mercado México (techos de sanidad)

| Segmento | Dato | Fuente |
|----------|------|--------|
| IT Services México (amplio) | $48.4B (2025) → $100.8B (2033) · CAGR 9.3% | Grand View |
| IT Services México (estrecho) | $16.16B (2025) → $20.04B (2030) · CAGR 4.4% | Statista |
| ICT México | $69.99B (2025) · $78.69B (2026) → $129.5B (2031) | Mordor |
| **Digital Transformation México** | **$39.98B (2025) → $88.33B (2030) · CAGR 17.2%** | Mordor |
| Posición regional | **2° de LATAM** ($28B en 2022) detrás de Brasil ($45B) | Statista |

---

## 3. Cómo se deriva el número de México (4 rutas)

Se calcula por cuatro caminos independientes y se busca dónde convergen.

**Ruta A — Top-down desde application modernization global**
Global $22B × ~7% LATAM (proxy del share de cloud migration) = ~$1.5B LATAM × 30% México = **~$450M** (solo app modernization services puro).

**Ruta B — Top-down desde IT Services México**
$48.4B IT services × ~30% (application/SI services) × ~20% (slice de modernización + migración) = **~$2.9B** (definición amplia).
Con el IT services estrecho ($16.16B): × 30% × 25% = **~$1.2B**.

**Ruta C — Desde Digital Transformation México**
$39.98B DX × ~8–12% (porción destinada a core modernization + migración) = **~$3.2B – $4.8B** (cota superior, incluye gasto adyacente).

**Ruta D — Mainframe/core específico**
Global mainframe $8.4B × ~6% LATAM = ~$500M LATAM × 30% México = **~$150M** (solo mainframe/core puro).

**Convergencia**: las rutas A y D acotan el piso (segmentos "puros"); B y C acotan el techo (definiciones amplias con integración y servicios adyacentes). El punto medio defendible se ubica en **$1.5B – $2.5B**, con ~$2.0B como número de trabajo.

---

## 4. Segmentación del TAM México (mid-case ~$2.0B)

| Segmento | TAM México 2025 (est.) | Peso | Dónde se concentra |
|----------|------------------------|------|--------------------|
| Application Modernization (monolitos, replatforming, refactor) | ~$0.8B – $1.1B | ~45% | Banca digital · retail e-commerce · seguros |
| Cloud Migration de sistemas existentes | ~$0.5B – $0.8B | ~30% | Todas las industrias · el de mayor CAGR (~20–27%) |
| Mainframe / Core Modernization | ~$0.3B – $0.5B | ~20% | Banca (cores, mainframe) · gobierno · aerolíneas (PSS) |
| Integración / API-fication de legados | ~$0.1B – $0.2B | ~5% | Open banking · omnicanalidad retail |

**Nota de solapamiento**: estos segmentos no son mutuamente excluyentes — un proyecto de core banking puede contar como mainframe modernization + cloud migration a la vez. Por eso el TAM total no es la suma aritmética simple sino el rango consolidado de §1.

---

## 5. Drivers específicos de México (por qué crece 13–15%, no el 9% del IT services general)

1. **Banca sobre deuda técnica de décadas** — cores y mainframes obsoletos; regulación CNBV/Banxico tensando; open banking forzando API-fication. *Los bancos MX están acelerando modernización de core en 2025–26.*
2. **Grupos europeos bajo DORA** — Santander y Sabadell arrastran obligación de resiliencia operativa digital → refuerza el caso de modernización.
3. **Fintech como presión competitiva** — lanzan en semanas lo que el banco tradicional tarda meses; obliga a modernizar el SDLC, no solo el core.
4. **E-commerce como canal estratégico** — retail (Liverpool, Coppel, Walmart, FEMSA/OXXO) migrando de sistemas de soporte a software como producto diferenciador.
5. **Nearshoring** — México como hub de delivery para Norteamérica infla la demanda de capacidad de ingeniería.
6. **Cloud migration con el CAGR más alto** (~20–27% LATAM) — el segmento que más rápido crece dentro del TAM.

---

## 6. Del TAM al SOM — qué significa para la práctica S&PE

Framing TAM → SAM → SOM para calibrar los targets del Account Plan FY27:

| Nivel | Definición | Estimación 2025 |
|-------|-----------|-----------------|
| **TAM** | Todo el gasto en modernización + migración de legados en México | **~$2.0B** (rango $1.5–2.5B) |
| **SAM** (serviceable) | Segmento enterprise/regulado donde S&PE juega — banca, retail grande, seguros, industrial, aerolíneas (~las industrias de las 19 cuentas) | **~$0.8B – $1.2B** (~40–50% del TAM, concentrado en gran empresa) |
| **SOM** (obtainable) | Participación realista de Accenture dado el competitive set (IBM, Cognizant, Globant, TCS, fábricas nearshore, equipos in-house) | **~$80M – $180M/año** (~8–15% del SAM) |

El SOM de ~$80–180M/año es el marco contra el cual los targets agregados de las 19 cuentas en [practice-summary-fy27.md](practice-summary-fy27.md) deben sanity-checkearse. Si el pipeline sumado de modernización/migración excede materialmente ese rango, hay que revisar los supuestos de win rate o de share.

---

## 6.1 El mercado de SERVICIOS de modernización aplicativa — "empresas como Accenture"

> Esta sección responde la pregunta específica: *¿cuál es el mercado para firmas de servicios como Accenture, en modernización aplicativa?* Es un corte **más estrecho y más preciso** que el TAM amplio de §1.

**Aclaración clave**: cuando las firmas de research reportan el *"Application Modernization Services Market"* (~$22.67B – $26.43B global en 2025), **ya se refieren al mercado de servicios** — el gasto que va a integradores/consultoras. Los fabricantes de herramientas (el software de modernización) se reportan aparte. Es decir, ese mercado *es* el de "empresas como Accenture".

### El mercado global de servicios de modernización aplicativa

| Métrica | Valor | Fuente |
|---------|-------|--------|
| Tamaño global 2025 | **$22.67B – $26.43B** | MarketsandMarkets · Fortune BI |
| Proyección 2031/2034 | $51.45B (2031) · $92.08B (2034) | MarketsandMarkets · Fortune BI |
| CAGR | **14.6% – 16.3%** | Consenso |
| App Dev & Modernization como % del software consulting global | **24.7%** | Market.us |

### Concentración competitiva — quiénes son "empresas como Accenture"

Los **top 9 integradores globales — IBM, Accenture, Capgemini, TCS, Wipro, Infosys, HCLTech, Cognizant, DXC — capturan ~52–55% del revenue global** del mercado. Los top 5 concentran 45–50%. Es un mercado dominado por GSIs de escala, apalancados en relaciones existentes, alianzas con hyperscalers y tooling de modernización asistida por AI.

**Competitive set en México** (con quién compite S&PE por estos deals):
IBM · TCS · Infosys · Cognizant · Capgemini · Wipro · HCLTech · NTT DATA · Deloitte · DXC · **Globant** (fuerte en LATAM) · fábricas nearshore locales · equipos in-house del cliente.

### El corte México — el número que importa

| Paso | Cálculo | Resultado |
|------|---------|-----------|
| Mercado global servicios modernización aplicativa 2025 | — | ~$22.67B – $26.43B |
| × Participación **LATAM = 5%** (dato real del split regional*) | | ~$1.13B – $1.32B LATAM |
| × Participación México en LATAM (~25–32%) | | **~$300M – $450M** |

> *Split regional del mercado de servicios de modernización aplicativa: Norteamérica 38% · Asia-Pacífico 35% · Europa 15% · Medio Oriente/África 7% · **LATAM 5%**.

**Mercado de servicios de modernización aplicativa en México (2025): ~$300M – $450M USD** (mid ~$375M), creciendo a **~14–16% CAGR** hacia **~$650M – $900M para 2030–31**.

### Del mercado de servicios al share obtenible de Accenture

| Nivel | Definición | Estimación 2025/año |
|-------|-----------|---------------------|
| **Mercado de servicios (México)** | Todo el gasto en servicios de modernización aplicativa | **~$300M – $450M** |
| **Sandbox Tier-1 GSI** | La porción enterprise/regulada donde compiten los grandes integradores (concentración >55% en clientes bancarios/grandes) | **~$180M – $270M** |
| **Obtenible Accenture** | Share realista como líder Tier-1 (~12–20% del sandbox) | **~$25M – $55M/año** |

**Cómo leer esto vs. §6**: el SOM de §6 (~$80–180M/año) cubre el bucket **amplio** de modernización + migración + mainframe + cloud migration. Este corte (~$25–55M/año) es **solo modernización aplicativa pura**. La diferencia es la definición de alcance — no una contradicción. Para el Account Plan, usar el corte estrecho cuando la conversación con el cliente sea específicamente de *app modernization*, y el amplio cuando incluya migración a cloud y core/mainframe.

### Anchor de sanidad — mercado de System Integration México

El mercado de **System Integration en México** vale **$8.95B (2024) → $19.99B (2033), CAGR 9.34%** (Renub). Dentro del IT services mexicano, **IT consulting & implementation = 28%** del mercado (2024). La modernización aplicativa es un subconjunto de esta bolsa de SI/consulting — lo que confirma que un mercado de servicios de ~$300–450M para app modernization es consistente (≈4–5% del SI market, proporción razonable).

---

## 7. Cómo afilar este número (si se requiere rigor de propuesta)

Este documento sirve para dimensionar la práctica. Para un business case formal o un board deck, afilar con:

- **CIO dialogues** de las cuentas del Account Plan — el pipeline bottom-up real de las 19 cuentas es mejor señal que cualquier top-down.
- **Accenture internal market sizing** (Research/Strategy MX) — si existe una cifra interna calibrada, sustituye a esta triangulación.
- **Reportes pagados** con corte México: MarketsandMarkets Application Modernization (geo split) y Credence LATAM Mainframe Modernization tienen el detalle regional detrás del paywall.
- **Banxico/CNBV** — gasto tecnológico reportado del sector bancario como proxy del sub-TAM de banca (el más grande).

---

## 8. Fuentes

- [Grand View — Mexico IT Services Market Outlook 2026-2033](https://www.grandviewresearch.com/horizon/outlook/it-services-market/mexico)
- [Mordor — Mexico Digital Transformation Market](https://www.mordorintelligence.com/industry-reports/mexico-digital-transformation-market)
- [Mordor — Mexico ICT Market](https://www.mordorintelligence.com/industry-reports/mexico-ict-market)
- [Statista — IT Services Mexico](https://www.statista.com/outlook/tmo/it-services/mexico)
- [Statista — Latin America IT market value by country](https://www.statista.com/statistics/1288401/latin-america-it-market-value-by-country/)
- [MarketsandMarkets — Application Modernization Services Market](https://www.marketsandmarkets.com/Market-Reports/application-modernization-services-market-149625724.html)
- [Polaris — Application Modernization Services Market](https://www.polarismarketresearch.com/industry-analysis/application-modernization-services-market)
- [SNS Insider — Application Modernization Services Market](https://www.snsinsider.com/reports/application-modernization-services-market-3459)
- [MarketsandMarkets — Mainframe Modernization Market](https://www.marketsandmarkets.com/Market-Reports/mainframe-modernization-market-52477.html)
- [Straits Research — Mainframe Modernization Market](https://straitsresearch.com/report/mainframe-modernization-market)
- [Credence Research — Latin America Mainframe Modernization Services Market](https://www.credenceresearch.com/report/latin-america-mainframe-modernization-services-market)
- [Grand View — Cloud Migration Services (Latin America)](https://www.grandviewresearch.com/horizon/outlook/cloud-migration-services-market/latin-america)
- [IMARC — Latin America Digital Transformation Market](https://www.imarcgroup.com/latin-america-digital-transformation-market)
- [Keyhole Software — Legacy Modernization Trends 2026](https://keyholesoftware.com/legacy-modernization-trends/)
- [Mexico Business News — Mexican Banks Accelerate Core System Modernization](https://mexicobusiness.news/tech/news/mexican-banks-accelerate-core-system-modernization-2026)
- [MarketsandMarkets — Application Modernization Services worth $51.45B by 2031](https://www.marketsandmarkets.com/PressReleases/application-modernization-services.asp)
- [MarketsandMarkets — Top Companies in Application Modernization Services](https://www.marketsandmarkets.com/ResearchInsight/application-modernization-services-market.asp)
- [MarketsandMarkets — Top Companies in System Integration Services](https://www.marketsandmarkets.com/ResearchInsight/system-integration-services-market.asp)
- [Fortune Business Insights — Application Modernization Services Market](https://www.fortunebusinessinsights.com/application-modernization-services-market-111580)
- [Renub Research — Mexico System Integration Market Forecast 2025-2033](https://www.renub.com/mexico-system-integration-market-p.php)
- [Market.us — Software Consulting Market (ADM 24.7% share)](https://market.us/report/software-consulting-market/)
- [Statista — IT Consulting & Implementation Mexico](https://www.statista.com/outlook/tmo/it-services/it-consulting-implementation/mexico)

---

*Creado: 2026-07-07 · Triangulación de research secundario · Refresh sugerido: cada 6 meses o al recibir cifra interna ACN*