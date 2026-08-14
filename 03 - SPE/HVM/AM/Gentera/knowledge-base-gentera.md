# Knowledge Base — Gentera

> Contexto verificado del cliente para el proyecto SPE-AM-002 · Application Modernization · SAP ABAP RE

---

## Perfil del Cliente

| Campo | Valor |
|---|---|
| Razón social holding | Gentera, S.A.B. de C.V. |
| Subsidiaria principal | Compartamos Banco, S.A. |
| Subsidiarias internacionales | Compartamos Financiera S.A. (Perú) · AgroAmérica (Guatemala) |
| Sector | Servicios financieros — microfinanzas / inclusión financiera |
| Modelo de negocio | Crédito grupal (metodología Grameen adaptada) · crédito individual · crédito mujer · microseguros |
| Clientes objetivo | Población de bajos ingresos y base de pirámide — zonas urbanas, semiurbanas y rurales de México |
| Regulación MX | CNBV (banco múltiple) · Banxico · CONDUSEF · SAT |
| Regulación PE | SBS (Superintendencia de Banca, Seguros y AFP) |
| Regulación GT | SIB (Superintendencia de Bancos Guatemala) |
| Monedas | MXN · PEN · GTQ |
| Bolsa | BMV (Bolsa Mexicana de Valores) — ticker: GENTERA * |

---

## Contexto Operativo (relevante para RE)

| Aspecto | Detalle |
|---|---|
| Volumen de cartera | Decenas de miles de grupos solidarios · millones de cuentas individuales |
| Ciclos de crédito | Crédito grupal con ciclos semanales/quincenales/mensuales — alta frecuencia de transacciones de cobranza |
| Procesos de campo | Promotores colectan pagos en reuniones de grupo → sistema central los registra (online o batch diferido) |
| Comisiones | Catálogo de comisiones regulado por CONDUSEF (circular única de bancos) — probablemente Z-code en SAP |
| Cierre de cartera | Proceso de cierre de ciclo de crédito → liquidación → disposición siguiente ciclo |
| Procesos regulatorios | Reportería CNBV (R01C · R04C · R10C · otros) · TESOFE · IPAB |

---

## Hipótesis de Landscape SAP (confirmar en Etapa 0)

| Módulo | Uso probable | Densidad Z esperada |
|---|---|---|
| FI (Financial Accounting) | GL · cuentas por cobrar/pagar · cierre contable | Media — adaptan reglas contables MX |
| CO (Controlling) | Centros de costo · análisis de rentabilidad | Baja |
| SD (Sales & Distribution) | Gestión de créditos como "productos" · condiciones de pago | Alta — modelo de ciclos de crédito es muy custom |
| MM (Materials Mgmt) | Compras · proveedores · activos fijos | Baja |
| HCM (HR) | Nómina · gestión de promotores en campo | Media |
| FI-CA (Contract Accounting) | Si lo tienen: gestión de contratos de crédito masivo | Alta — FI-CA suele tener mucha customización en microfinanzas |
| FS-CD (Collections) | Si lo tienen: cobranza | Alta |
| BW/BI | Reportería regulatoria CNBV | Media |

---

## Hallazgos del Primer Archivo ABAP (2026-07-16)

Del análisis de `/CBB/CL_DB_TVARVC` (`source/CLASS/_CBB_CL_DB_TVARVC.abap`):

| Hallazgo | Detalle | Impacto RE |
|---|---|---|
| **Namespace registrado `/CBB/`** | Compartamos Banco tiene namespace SAP formal, no Z/Y | Inventario TADIR debe incluir `/CBB/%` además de Z/Y |
| **Segundo namespace `/CBCR/`** | Mensaje de clase `/CBCR/CM_ZVAL` detectado en el mismo archivo — namespace diferente | TADIR query debe incluir también `'/CBCR/%'`; puede ser namespace de un componente/partner |
| **Contexto IFRS** | Message class `/CBB/MSG_IFRS_CN` — IFRS 9 probable | `[REGLA-REGULATORIA]` — alta sensibilidad contable |
| **Developer: GBELTRAN** (Gabriel Alejandro Beltran Reyes) | Fecha 02.05.2022 · OTs `BSDK925874 / BSDK926605` | Capa 2 · implementador externo con sistema de tickets propio |
| **Patrón feature flag sobre TVARVC** | `IS_EVENT_ACTIVE` → controla activación de procesos de negocio | Tabla `TVARVC` es crítica para entender qué procesos están activos |
| **Framework propio de excepciones** | `/CBB/CX_DB_NOT_FOUND` · `/CBB/CL_EXCEPTION_HELPER` | Existe una capa de infraestructura `/CBB/` de bajo nivel |
| **Organización por tipo** en `source/` | Carpeta `CLASS/` para clases — sugiere export organizado de ABAPGit o herramienta similar | Convención de carpetas ya establecida |

---

## Lo Que NO Sabemos (confirmar en primeras reuniones)

- [ ] Versión SAP exacta (ECC 6.0 EhP7 / S/4HANA 202x)
- [ ] Base de datos subyacente (Oracle · HANA · MaxDB)
- [ ] Objetivo declarado de modernización (migrar a S/4HANA vs. reemplazar módulos vs. otro)
- [ ] Existe SAP para operaciones de Perú y Guatemala o son sistemas separados
- [ ] Número aproximado de objetos Z (si ya hicieron algún assessment)
- [ ] Existe resultado de SAP Readiness Check o ATC adaptation check previo
- [ ] Proveedor SAP incumbente (SAP Services · IBM · Accenture · boutique)
- [ ] Deadline o driver de negocio (fin de contrato de mantenimiento · auditoría · expansión de servicios)

---

*Última actualización: 2026-07-16 · v0.1 · Creación inicial con información pública verificable. Actualizar con datos del cliente a partir de primera reunión.*