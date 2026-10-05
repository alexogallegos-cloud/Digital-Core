# Knowledge Base — Santander México
> Base de conocimiento estructurado del ecosistema tecnológico y de negocio.
> Fuentes: públicas confirmadas + análisis de mercado. Enriquecer con documentación real del cliente.

---

## PERFIL DE NEGOCIO

| Campo | Valor |
|-------|-------|
| Razón social | Banco Santander México, S.A., Institución de Banca Múltiple, Grupo Financiero Santander México |
| Grupo | Banco Santander, S.A. (Madrid · IBEX 35) |
| Sede México | CDMX (Santa Fe · Torre Santander) |
| Fundación MX | 1992 (adquisición Banca Serfin 2000) |
| Clientes | ~17M (retail + pyme + empresas) |
| Activos | ~$1.5T MXN (Top 5 banca México) |
| Red física | ~1,300 sucursales · ~7,000 cajeros ATM |
| Empleados | ~18,000 (estimado) |
| Ticker | BSMX (BMV + NYSE ADR) |
| Rating | Fitch: BBB+ · Moody's: Baa1 |

---

## CONTEXTO ESTRATÉGICO

### Posición competitiva (2026)

| Banco | Posición | Activos |
|-------|----------|---------|
| BBVA México | #1 | ~$2.4T MXN |
| Banorte | #2 | ~$2.0T MXN |
| Citibanamex | #3 | ~$1.8T MXN |
| HSBC México | #4 | ~$1.6T MXN |
| **Santander México** | **#5** | **~$1.5T MXN** |
| Scotiabank | #6 | ~$0.9T MXN |

### Segmentos de negocio

| Segmento | Productos clave |
|----------|----------------|
| Retail (personas físicas) | Cuenta Santander · Santander Light · Tarjeta Zero · Hipoteca · Nómina |
| Pyme | Cuenta Pyme · Terminal Santander · Crédito Pyme |
| Empresas (corporativo) | Santander Cash · FX · Derivados · Financiamiento estructurado |
| Wealth & Private | Santander Private Banking · Fondos de inversión |
| Digital | SuperMóvil · One Pay · Santander Online |

---

## INICIATIVAS DIGITALES CONOCIDAS (PÚBLICAS)

| Iniciativa | Descripción | Fuente |
|------------|-------------|--------|
| SuperMóvil | App principal iOS + Android — >5M descargas | App Store / Play Store |
| One Pay | Pagos digitales · SPEI / DiMo / pago de servicios | Comunicados Santander MX |
| Open Banking | APIs abiertas · sandbox para fintechs (CNBV) | Sitio corporativo |
| Openbank | Neobanco del grupo Santander — lanzado MX 2023 | Comunicados grupo |
| Santander X | Ecosistema de innovación y emprendimiento | Comunicados corporativos |
| Global AI Partnership | Microsoft Azure OpenAI para banca | Anuncios globales Santander 2024 |

---

## STACK TECNOLÓGICO — HIPÓTESIS Y CONFIRMADO

> `[C]` = Confirmado con fuente pública · `[H]` = Hipótesis por patrón de mercado / analogía grupo

| Capa | Sistema / Tecnología | Estado |
|------|----------------------|--------|
| Cloud | Microsoft Azure (partnership estratégico global) | `[C]` |
| Cloud AI | Azure OpenAI / AI Foundry (anuncio grupo 2024) | `[C]` |
| Identidad | Azure AD / Entra ID (grupo global) | `[H]` |
| App móvil | SuperMóvil (iOS Swift + Android Kotlin o React Native) | `[C]` nombre |
| Web | Santander Online — stack web moderno (Angular probable) | `[C]` nombre |
| CRM | Salesforce (Santander grupo usa globalmente) | `[H]` |
| ITSM | ServiceNow (común en grupos bancarios globales) | `[H]` |
| HR/Finanzas | SAP (probable ECC o S/4HANA para consolidación grupo) | `[H]` |
| Monitoring | Dynatrace o Azure Monitor | `[H]` |
| Pagos regulados | Banxico SPEI / DiMo / CoDi | `[C]` |
| Card clearing | PROSA (cámara compensación MX) | `[C]` sector |
| SWIFT | SWIFT Alliance (mensajería internacional ISO 20022) | `[C]` sector |
| Core banking | Desconocido — investigar en discovery | `[H]` existencia |

---

## REGULACIÓN — PUNTOS CLAVE

### CNBV — Circular Única de Bancos

| Reporte | Periodicidad | Criticidad |
|---------|-------------|------------|
| R01A — Balance General | Mensual | Alta |
| R04A — Cartera de crédito | Mensual | Alta |
| R10A — Captación | Mensual | Alta |
| R17A — Derivados | Mensual | Alta |
| Coeficiente de Cobertura de Liquidez (CCL) | Diario | Crítica |
| Índice de Capitalización (ICAP) | Mensual | Crítica |
| SIPRES — registro de prestadores de servicios financieros | Continuo | Alta |

### Banxico

| Marco | Descripción |
|-------|-------------|
| SPEI | Sistema de Pagos Electrónicos Interbancarios — liquidación bruta en tiempo real |
| DiMo | Dinero Móvil — pagos P2P con número de teléfono |
| CoDi | Cobro Digital — QR y CLABE para comercios |
| CECOBAN | Cámara de Compensación Electrónica Nacional — domiciliación, cheques |
| Reglas de conducta | Cargos por servicios, políticas de transparencia |

### UIF / PLD

| Marco | Descripción |
|-------|-------------|
| LFPIORPI | Ley Federal para la Prevención e Identificación de Operaciones con Recursos de Procedencia Ilícita |
| Reportes UIF | ROS (operaciones sospechosas) · ROI (operaciones inusuales) · Aviso 24h |
| GAFI/FATF | 40 Recomendaciones — grupo Santander ES bajo directiva europea |

---

## VOCABULARIO EMPRESARIAL — SEMILLAS INICIALES

| Término español | Inglés (EN) | Dominio | Scope | Notas |
|-----------------|------------|---------|-------|-------|
| Cuenta de depósito | Deposit account | productos | enterprise | Cuentas a la vista retail |
| Tarjeta de débito | Debit card | pagos | enterprise | Asociada a cuenta de depósito |
| Tarjeta de crédito | Credit card | productos | enterprise | Línea de crédito revolvente |
| Crédito hipotecario | Mortgage loan | crédito | enterprise | UDI o pesos, garantía inmobiliaria |
| Crédito de nómina | Payroll loan | crédito | enterprise | Descuento automático sobre nómina |
| Transferencia SPEI | SPEI transfer | pagos | enterprise | Liquidación bruta tiempo real Banxico |
| Domiciliación | Direct debit | pagos | enterprise | Cargo recurrente autorizado CECOBAN |
| Operación inusual | Unusual transaction | compliance | enterprise | Reporte UIF — señal PLD |
| Índice de Capitalización | Capital Adequacy Ratio | riesgo | enterprise | ICAP — Basilea III via CNBV |
| Cartera vencida | Non-performing loans | crédito | enterprise | NPL — > 90 días vencido |
| Cliente | Customer | clientes | enterprise | Persona física o moral |
| Contrato | Contract / Account | productos | enterprise | Relación contractual cliente-banco |
| Sucursal | Branch | canales | enterprise | Punto de servicio físico |
| Cajero automático | ATM | canales | enterprise | Automated Teller Machine |
| Aplicación móvil | Mobile app | canales | enterprise | SuperMóvil |
| Límite de crédito | Credit limit | crédito | enterprise | Monto máximo autorizado |

---

## COMPETIDORES Y BENCHMARKS

| Banco | Fortaleza digital | Referencia para gap analysis |
|-------|-------------------|------------------------------|
| BBVA México | Mejor app banca MX (J.D. Power 2024) · Open Platform · Nayón cloud native | Referencia líder digital |
| Banorte | Banorte Móvil · Rappi Card · nativa MX | Referencia banca nacional |
| Nu México | App-only · UX líder fintechs · 8M+ clientes | Referencia challenger digital |
| Citibanamex | Modernización Unisys · Citi global stack | Referencia modernización mainframe |

---

## DATOS DE ESCALA (ESTIMADOS — PÚBLICO)

| Métrica | Estimado | Fuente |
|---------|----------|--------|
| Transacciones SPEI / mes | ~50M | Estimado por cuota de mercado Banxico |
| Usuarios SuperMóvil activos | ~8M | Estimado por base clientes digitales |
| Transacciones tarjeta / mes | ~120M | Estimado cuota de mercado PROSA |
| Volumen cajeros ATM / mes | ~30M operaciones | Estimado red propia |
| Uptime SLA canales digitales | ≥ 99.9% | Estándar CNBV |

---

*Última actualización: 2026-09-17 · v1.0 · Base inicial de conocimiento público. Enriquecer con documentación real al iniciar discovery.*
