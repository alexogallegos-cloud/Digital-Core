# Agenda Digital y Tecnológica — BanCoppel / Grupo Coppel

> **DT**: dt-inteligencia-cliente · `SPE-AM-001`
> **Última actualización**: 2026-09-02
> **Estado**: Parcialmente poblado con contexto del engagement — requiere enriquecimiento con investigación web

---

## Proyectos Tecnológicos Conocidos

| Proyecto | Descripción | Estado | Sistema(s) involucrado(s) | Fuente | Fecha |
|----------|-------------|--------|--------------------------|--------|-------|
| Modernización Core Bancario (Unity) | Migración de Informix IDS 14.10 (AIX/POWER) a Temenos Transact | Activo — en ejecución (SPE-AM-001) | Informix → Transact; SmartVista/BPC; App Móvil; Apolo; SIWEB; CAT | Engagement interno | 2026-09 |
| Adopción Temenos (plataforma central) | BanCoppel adoptó la plataforma central de Temenos para escalar y ofrecer servicios digitales accesibles. Anunciado julio 2023. | Anunciado jul 2023 / En implementación | Temenos Core Platform | fintechexpert.mx | 2026-09-02 |
| Modernización tarjetas SmartVista BPC | BanCoppel seleccionó BPC para modernizar emisión de tarjetas con SmartVista — emisión instantánea y arquitectura de pagos más ágil | Anunciado 2026 | SmartVista (BPC Banking Technologies) | fintechexpert.mx | 2026-09-02 |
| Inversión tech Grupo Coppel 2026 | Grupo Coppel invertirá 14,300 MXN millones en 2026; 31% destinado a modernización tecnológica (coppel.com digital, IA en logística, servicios BanCoppel) | Anunciado 2026 | fortunaypoder.com | https://fortunaypoder.com/corporativos/coppel-invertira-14300-mdp-en-2026-para-mas-tiendas-y-tecnologia-digital | 2026-09-02 |
| Plataforma Apolo (Originación Digital) | Motor de originación digital de crédito — canal digital | En producción (TO-BE parcial) | Apolo, SmartVista | Engagement interno | 2026-09 |
| App Móvil BanCoppel | Aplicación Android/iOS para clientes — banca móvil | En producción + iteración activa | App Móvil (canal digital) | Engagement interno | 2026-09 |
| CoDi / SPEI | Pagos digitales interbancarios, integración con SPEI | En producción | Informix D08 (SPEI), CoDi | Engagement interno | 2026-09 |
| Modernización Informix (Exodus / AWS) | Evaluación de lift&shift a AWS — análisis de cartera (11,391 SPs vs 7,480 Exodus) | En evaluación / pausado | Informix, AWS ProServe | Engagement interno | 2026-09 |

---

## Alianzas y Partnerships Tecnológicos

| Partner | Tipo de relación | Área | Fuente | Fecha |
|---------|-----------------|------|--------|-------|
| Temenos | Vendor de plataforma core bancario (Transact) + plataforma central adoptada (jul 2023) | Core banking TO-BE | fintechexpert.mx + engagement | 2026-09-02 |
| BPC Banking Technologies (SmartVista) | Procesador de tarjetas y pagos AS-IS | Card processing, POS | Engagement interno | 2026-09 |
| IBM | Infraestructura AIX/POWER para Informix + posible cloud/servicios | Infraestructura | Engagement interno | 2026-09 |
| [AWS] | Evaluación de migración cloud (Exodus) | Cloud | Engagement interno | 2026-09 |
| EY | Implementación Temenos Transact (Unity) | Core banking modernization | Engagement interno — COMPETIDOR | 2026-09 |
| Accenture | Application Modernization — análisis Informix + delivery SPE-AM-001 | Modernización completa | Este engagement | 2026-09 |

---

## Stack Tecnológico AS-IS (Conocido del Engagement)

| Componente | Tecnología | Versión / Detalle | Rol |
|------------|-----------|-------------------|-----|
| Core bancario | IBM Informix IDS | 14.10 sobre AIX/POWER | Sistema de registro principal (SoR) |
| Procesador tarjetas | BPC Banking Technologies SmartVista | — | Procesamiento de tarjetas TDC/débito |
| App Móvil | Android + iOS | — | Canal digital banca móvil |
| Originación digital | Apolo (Java) | — | Motor de crédito digital |
| Banca por internet | SIWEB | — | Canal web |
| Facturación / CAT | CAT | — | Canal / facturación |
| Orquestación batch | ControlM | — | Scheduler de procesos batch |
| Integración | MuleSoft / ESB | — | Capa de integración |
| MDM / datos | Atlas (GCP) | — | Master Data Management en GCP |
| ETL | DataStage | — | Pipeline de datos |
| Conectividad | e-Global, Connect Direct | — | Transferencias bancarias y corresponsalía |
| Conectividad SPEI | Banxico SPEI | — | Pagos electrónicos interbancarios |

---

## Agenda de Investigación (Fuentes Públicas Pendientes)

Los siguientes temas requieren investigación web para enriquecer este archivo con datos públicos:

- [ ] Licitaciones y RFPs públicos de Grupo Coppel / BanCoppel (Compranet si es entidad pública; prensa tech si empresa privada)
- [ ] Comunicados de alianzas tecnológicas (Temenos, IBM, AWS, GCP press releases)
- [ ] Premios / reconocimientos en tecnología financiera (Fintech Awards MX, Efma, etc.)
- [ ] Posicionamiento en informes de analistas (Celent, IDC, Gartner — si hay cobertura)
- [ ] Iniciativas de inclusión financiera con componente tecnológico (programas CNBV, SHCP, Banxico)
- [ ] Contrataciones tech recientes (señales de LinkedIn — perfiles de arquitectos, ingenieros cloud, etc.)
- [ ] Noticias de inversión tecnológica o presupuesto IT conocido públicamente

---

*Seed parcial 2026-09-02 · Datos del engagement son conocimiento interno — pendiente enriquecimiento con fuentes públicas verificables · dt-inteligencia-cliente*