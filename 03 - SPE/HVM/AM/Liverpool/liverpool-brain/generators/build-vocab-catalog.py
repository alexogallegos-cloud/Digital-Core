"""
build-vocab-catalog.py — Genera el catálogo de vocabulario del Liverpool Brain.

Fuente de vocabulario: extracción manual del corpus completo —
  · 13 DTs (CLAUDE.md)
  · 12 programas ABAP (Módulo Importaciones — ZIM/ZRT)
  · Arquitectura_Liverpool_Dashboard_1.html (20 sistemas)
  · rtb-capabilities.json (232 capacidades RTB v5)

Salida: portal/vocabulary-catalog-liv.html  (auto-contenido, sin dependencias externas)

Uso: python generators/build-vocab-catalog.py
"""
import json, hashlib, base64
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
OUT  = BASE / "portal" / "vocabulary-catalog-liv.html"

def _vid(t: str) -> str:
    h = hashlib.sha1(t.strip().lower().encode("utf-8")).digest()
    return "LIV-" + base64.b32encode(h).decode("ascii").rstrip("=")[:6]

# ─────────────────────────────────────────────────────────────────────────────
# VOCABULARIO CANÓNICO — extraído del corpus Liverpool Brain (SPE-AM-003)
# cat:   SISTEMA | PROCESO | ABAP | SEÑAL | DOMINIO | VENDOR | 7R | MODULO
# est:   conf | inf | gap
# nivel: ALTA | MEDIA | AMBIGUA | CANDIDATO
# fn:    relevancia 1–10
# ─────────────────────────────────────────────────────────────────────────────
TERMS_RAW = [
  # ─── SISTEMAS ──────────────────────────────────────────────────────────────
  dict(term="VPL Vision Plus",     cat="SISTEMA",  mean="Core LiverpoolCard 24×7 — autorizaciones, estados de cuenta, pagos; FIS Global sobre IBM z/OS. SLA regulatorio Banxico implícito.",                              est="conf", nivel="ALTA",      dominio="R03",         sistema="Mainframe",   fn=10),
  dict(term="SOMS",                cat="SISTEMA",  mean="Sterling Order Management System en IBM z/OS — gestión de órdenes de entrega: picking, packing, despacho. Señal crítica: 96.69% de órdenes en estado pendiente.",  est="conf", nivel="ALTA",      dominio="R04",         sistema="Mainframe",   fn=9),
  dict(term="Control-D",           cat="SISTEMA",  mean="BMC Software scheduler batch en z/OS — orquesta jobs nocturnos de cierre, reconciliación y extracción a SAP BW. Único orquestador batch del mainframe.",           est="conf", nivel="ALTA",      dominio="R10",         sistema="Mainframe",   fn=8),
  dict(term="Mainframe Clientes",  cat="SISTEMA",  mean="Subsistema z/OS de contabilidad de clientes — balances, movimientos, cargos; sistema de registro financiero Liverpool. Coexiste con SAP FI sin registro de verdad único.",  est="conf", nivel="ALTA",      dominio="R03",         sistema="Mainframe",   fn=7),
  dict(term="IBM IIB",             cat="SISTEMA",  mean="IBM Integration Bus 10 — bus corporativo central con 15+ sistemas integrados; punto de integración primario. Coexiste con Apigee en despliegue parcial.",            est="conf", nivel="ALTA",      dominio="R10",         sistema="IBM IIB",     fn=9),
  dict(term="Tumbleweed",          cat="SISTEMA",  mean="Broadcom Managed File Transfer — MFT para bancos, SAT y carriers; interfaces regulatorias (SAT, SHCP). Candidato a Retain hasta que sus dependencias migren.",      est="conf", nivel="ALTA",      dominio="R10",         sistema="IBM IIB",     fn=7),
  dict(term="Sterling OMS",        cat="SISTEMA",  mean="IBM Sterling Order Management 10 — OMS omnicanal. Señal crítica: 96.69% de órdenes en estado 'pendiente'; raíz en SOMS z/OS.",                                     est="conf", nivel="ALTA",      dominio="R04",         sistema="Sterling OMS",fn=9),
  dict(term="ATG / Endeca",        cat="SISTEMA",  mean="Oracle Commerce (ATG) + Endeca search — ecommerce AS-IS: liverpool.com.mx y suburbia.com. Destino de Repurchase → commercetools (confirmado nov-2025).",           est="conf", nivel="ALTA",      dominio="R05",         sistema="ATG",         fn=8),
  dict(term="Bridgecore",          cat="SISTEMA",  mean="Gateway POS exclusivo Liverpool — intermedia terminales de tienda con SAP/Mainframe. Exclusivo LIV (no SBB). DATO-REQUERIDO: ¿vendor externo o desarrollo propio?", est="conf", nivel="ALTA",      dominio="R06",         sistema="Bridgecore",  fn=7),
  dict(term="Base24",              cat="SISTEMA",  mean="ACI Worldwide switch transaccional — autorización de pagos: POS, ATM, LiverpoolCard en tienda. Certificación PCI-DSS; candidato a Retain.",                        est="conf", nivel="ALTA",      dominio="R03",         sistema="Base24",       fn=8),
  dict(term="Siebel CRM",          cat="SISTEMA",  mean="Oracle Siebel CRM — gestión de casos Call Center, programa de lealtad. Solo en LIV (no SBB). En mantenimiento extendido Oracle; candidato a Repurchase.",          est="conf", nivel="ALTA",      dominio="R02",         sistema="Siebel",       fn=7),
  dict(term="PIM-STEP",            cat="SISTEMA",  mean="Stibo Systems STEP — Product Information Management para LIV y SBB; catálogo maestro de productos y atributos.",                                                   est="conf", nivel="ALTA",      dominio="R01",         sistema="PIM-STEP",     fn=7),
  dict(term="Oracle PL-SQL",       cat="SISTEMA",  mean="Oracle + PL/SQL — Planning/merchandising: Size Scaling (sizing por talla/tienda) y Allocation (distribución de inventario). Lógica crítica de surtido.",           est="conf", nivel="ALTA",      dominio="R01",         sistema="Oracle",       fn=7),
  dict(term="SAP ECC 6.0",         cat="SISTEMA",  mean="SAP ERP Central Component 6.0 on-premise — ERP Liverpool: inventario MM, ventas SD, finanzas FI/CO, RRHH HCM, WM/EWM. EOL SAP 2027-2030; driver principal de modernización.",  est="conf", nivel="ALTA",      dominio="transversal",  sistema="SAP",         fn=10),
  dict(term="S/4HANA",             cat="SISTEMA",  mean="SAP S/4HANA en Azure — ERP Suburbia post-adquisición. Objetivo de migración para SAP ECC LIV (decisión brownfield/greenfield pendiente).",                          est="conf", nivel="ALTA",      dominio="transversal",  sistema="SAP",         fn=9),
  dict(term="SAP BW Híbrido",      cat="SISTEMA",  mean="SAP Business Warehouse híbrido (on-prem + nube) — reporting ejecutivo Presidencia. DataSources tradicionales se invalidan con migración S/4HANA.",                 est="conf", nivel="ALTA",      dominio="R09",         sistema="SAP BW",      fn=8),
  dict(term="SAP BusinessObjects", cat="SISTEMA",  mean="Capa de reportes y dashboards: Crystal Reports, Lumira. SAP ha anunciado EOL; candidato a Repurchase hacia SAC o Looker (GCP).",                                   est="conf", nivel="ALTA",      dominio="R09",         sistema="SAP BW",      fn=6),
  dict(term="CDP-GCP",             cat="SISTEMA",  mean="Customer Data Platform en GCP — Customer 360 en construcción. Destino de datos de cliente de Siebel. Compartido entre DT de Inteligencia y DT de Plataforma Digital.", est="conf", nivel="ALTA",      dominio="R02",         sistema="CDP",         fn=8),
  dict(term="Apigee",              cat="SISTEMA",  mean="Google Apigee API Gateway — desplegado parcialmente; coexiste con IBM IIB. Target API Gateway único para el landscape Liverpool.",                                  est="conf", nivel="ALTA",      dominio="R10",         sistema="Apigee",       fn=7),
  dict(term="Gestor4PL",           cat="SISTEMA",  mean="App Java/GCP — gestión de proveedores logísticos 4PL: tracking, SLAs, visibilidad de carga. Ya productivo en GCP.",                                                est="conf", nivel="ALTA",      dominio="R04",         sistema="Digital",     fn=7),
  dict(term="App Surtido / XD",    cat="SISTEMA",  mean="App Java/GCP — planeación de surtido por tienda: qué producto va en qué tienda y cuándo. Reemplazó proceso manual. Candidato a integración con S/4HANA.",          est="conf", nivel="ALTA",      dominio="R01",         sistema="Digital",     fn=7),
  dict(term="SAS on GCP",          cat="SISTEMA",  mean="SAS Analytics Platform en GCP — modelos estadísticos: scoring de crédito, demand forecasting. Alimentado por CDP-GCP y datos BW.",                                  est="conf", nivel="ALTA",      dominio="R09",         sistema="CDP",         fn=6),
  dict(term="Cyberfinancial",      cat="SISTEMA",  mean="EQUIFAX / Harman Navigator — plataforma de cobranza SaaS. En migración de v8.4 a v9C; transitional.",                                                              est="conf", nivel="MEDIA",     dominio="R03",         sistema="Base24",       fn=5),
  dict(term="FICO-TRIAD",          cat="SISTEMA",  mean="FICO TRIAD — originación de crédito APM+OM y scoring de riesgo LiverpoolCard. Motor de decisión crediticia.",                                                      est="conf", nivel="ALTA",      dominio="R03",         sistema="Base24",       fn=7),
  dict(term="Card-Wizard",         cat="SISTEMA",  mean="Card Wizard — emisión física de tarjetas LiverpoolCard. Gestiona el ciclo de producción y personalización de la tarjeta.",                                          est="conf", nivel="MEDIA",     dominio="R03",         sistema="Base24",       fn=5),
  dict(term="SAP BW LIV",          cat="SISTEMA",  mean="SAP BW operacional Liverpool — DWH de ventas, inventario y finanzas. Alimentado por DataSources de SAP ECC LIV y archivos flat del mainframe (Control-D).",        est="conf", nivel="ALTA",      dominio="R09",         sistema="SAP BW",      fn=7),
  dict(term="SAP BW PDM",          cat="SISTEMA",  mean="SAP BW de producto — analítica de surtido, precios y márgenes. Alimentado por Oracle PL-SQL vía interfaces custom; candidato a Retire si Oracle PL-SQL se moderniza.", est="conf", nivel="MEDIA",     dominio="R09",         sistema="SAP BW",      fn=5),
  dict(term="BW4 SBB",             cat="SISTEMA",  mean="SAP BW4HANA de Suburbia en Azure — DWH post-adquisición. Instancia separada; parte de los 4 silos analíticos sin vista consolidada.",                              est="conf", nivel="ALTA",      dominio="R09",         sistema="SAP BW",      fn=6),

  # ─── PROCESOS ──────────────────────────────────────────────────────────────
  dict(term="importaciones",          cat="PROCESO", mean="Proceso de aprovisionamiento internacional: PO → proveedor → pre-embarque → pedimento aduanal → recepción. Automatizado via programas ZIM/ZRT en SAP.",          est="conf", nivel="ALTA",  dominio="R04", sistema="SAP",          fn=9),
  dict(term="surtido",                cat="PROCESO", mean="Distribución de producto por tienda: qué SKU va en qué tienda, en qué cantidad y cuándo. Gestionado por App Surtido/XD y Oracle PL-SQL (Size Scaling + Allocation).", est="conf", nivel="ALTA",  dominio="R01", sistema="SAP",          fn=8),
  dict(term="fulfillment",            cat="PROCESO", mean="Proceso de cumplimiento de pedido desde confirmación hasta entrega al cliente: Sterling OMS → SOMS (z/OS) → SAP EWM. Señal: 96.69% en pendiente.",               est="conf", nivel="ALTA",  dominio="R04", sistema="Sterling OMS", fn=9),
  dict(term="picking",                cat="PROCESO", mean="Selección física de producto en almacén para cumplir un pedido — orquestada por SOMS en z/OS a través de SAP EWM.",                                               est="conf", nivel="ALTA",  dominio="R04", sistema="Mainframe",    fn=7),
  dict(term="packing",                cat="PROCESO", mean="Empaque del pedido antes de despacho — parte del flujo fulfillment SOMS; posterior al picking.",                                                                   est="conf", nivel="ALTA",  dominio="R04", sistema="Mainframe",    fn=6),
  dict(term="despacho",               cat="PROCESO", mean="Salida del producto del almacén hacia el cliente o tienda — punto final del fulfillment en SOMS z/OS.",                                                            est="conf", nivel="ALTA",  dominio="R04", sistema="Mainframe",    fn=7),
  dict(term="cierre de caja",         cat="PROCESO", mean="Proceso nocturno de reconciliación de ventas de tienda: Bridgecore → Control-D (batch) → SAP FI → Mainframe Clientes. Proceso diario crítico para ~130 tiendas.", est="conf", nivel="ALTA",  dominio="R06", sistema="Mainframe",    fn=8),
  dict(term="reconciliación",         cat="PROCESO", mean="Cuadre financiero entre sistemas: VPL↔SAP FI, cierre de caja, movimientos de tarjeta. Si divergen, la versión correcta no está documentada.",                     est="conf", nivel="ALTA",  dominio="R07", sistema="Mainframe",    fn=8),
  dict(term="autorización",           cat="PROCESO", mean="Aprobación de pago en tiempo real 24×7 — VPL Vision Plus (LiverpoolCard) y Base24 (Visa/MC/débito). Restricción regulatoria Banxico para ventanas de mantenimiento.", est="conf", nivel="ALTA",  dominio="R03", sistema="Mainframe",    fn=9),
  dict(term="cobranza",               cat="PROCESO", mean="Gestión de cuentas por cobrar LiverpoolCard — estados de cuenta, pago mínimo, interfaces de cobranza; centralizado en VPL Vision Plus.",                           est="conf", nivel="ALTA",  dominio="R03", sistema="Mainframe",    fn=8),
  dict(term="originación de crédito", cat="PROCESO", mean="Evaluación y aprobación de nuevas cuentas LiverpoolCard — FICO-TRIAD APM+OM como motor de decisión crediticia.",                                                  est="conf", nivel="ALTA",  dominio="R03", sistema="Base24",       fn=7),
  dict(term="emisión de tarjeta",     cat="PROCESO", mean="Producción y entrega física de tarjeta LiverpoolCard a cliente — gestionado por Card-Wizard; input de VPL para activación.",                                      est="conf", nivel="ALTA",  dominio="R03", sistema="Base24",       fn=6),
  dict(term="redención",              cat="PROCESO", mean="Canje de puntos Liverpool por beneficios en tienda o en línea — gestionado en Siebel CRM (AS-IS). Candidato a migrar a Salesforce Loyalty Management.",           est="conf", nivel="ALTA",  dominio="R02", sistema="Siebel",       fn=7),
  dict(term="contabilización",        cat="PROCESO", mean="Registro de transacciones en libros contables SAP FI/CO — ventas, pagos, devoluciones, importaciones. Flujo diario desde Bridgecore, ATG y Tumbleweed.",          est="conf", nivel="ALTA",  dominio="R07", sistema="SAP",          fn=8),
  dict(term="pedimento aduanal",      cat="PROCESO", mean="Documento aduanal que acredita pago de impuestos de importación — datos procesados en SAP vía ZRT_PO_REP_EPI_BD; transferencia ECC → POS (oct-2025).",            est="conf", nivel="ALTA",  dominio="R04", sistema="SAP",          fn=7),
  dict(term="pre-embarque",           cat="PROCESO", mean="Aviso del proveedor de que la mercancía está lista para embarcar — step 3 del flujo de importaciones, procesado por ZIMPOC003.",                                   est="conf", nivel="ALTA",  dominio="R04", sistema="SAP",          fn=6),
  dict(term="faltante",               cat="PROCESO", mean="Diferencia negativa entre cantidad pedida y cantidad recibida en importación — detectada y registrada por ZIMPOC007.",                                              est="conf", nivel="ALTA",  dominio="R04", sistema="SAP",          fn=6),
  dict(term="sobrante",               cat="PROCESO", mean="Diferencia positiva entre cantidad recibida y cantidad pedida en importación — detectada y registrada por ZIMPOC007.",                                              est="conf", nivel="ALTA",  dominio="R04", sistema="SAP",          fn=5),
  dict(term="lealtad",                cat="PROCESO", mean="Programa de puntos Liverpool — acumulación por compra, redención, niveles de membresía. AS-IS en Siebel; TO-BE en CDP-GCP. Pendiente extensión a Suburbia.",       est="conf", nivel="ALTA",  dominio="R02", sistema="Siebel",       fn=8),
  dict(term="scoring",                cat="PROCESO", mean="Modelo de evaluación de riesgo crediticio para nuevas solicitudes LiverpoolCard — FICO-TRIAD como motor; SAS on GCP para modelos estadísticos avanzados.",         est="conf", nivel="ALTA",  dominio="R03", sistema="Base24",       fn=7),
  dict(term="demand forecasting",     cat="PROCESO", mean="Proyección de demanda por SKU/tienda — modelo estadístico SAS on GCP; input para planificación de surtido y órdenes de compra.",                                   est="inf",  nivel="MEDIA", dominio="R01", sistema="CDP",          fn=6),
  dict(term="gestión logística 4PL",  cat="PROCESO", mean="Coordinación con proveedores logísticos externos: tracking de carga, SLAs, visibilidad end-to-end — plataforma Gestor4PL en GCP.",                                 est="conf", nivel="ALTA",  dominio="R04", sistema="Digital",      fn=7),
  dict(term="Customer 360",           cat="PROCESO", mean="Vista unificada del cliente: historial de compras, crédito, lealtad, comportamiento digital — objetivo del CDP-GCP en construcción.",                               est="conf", nivel="ALTA",  dominio="R02", sistema="CDP",          fn=8),
  dict(term="planificación de surtido",cat="PROCESO",mean="Proceso de asignación de SKU a tiendas según demanda histórica y forecast — App Surtido/XD + Oracle PL-SQL (Size Scaling + Allocation).",                         est="conf", nivel="ALTA",  dominio="R01", sistema="Digital",      fn=7),
  dict(term="Size Scaling",           cat="PROCESO", mean="Proceso Oracle PL-SQL de asignación de cantidades por talla en surtido de moda — específico de tienda departamental; input de PIM-STEP.",                          est="conf", nivel="ALTA",  dominio="R01", sistema="Oracle",       fn=7),
  dict(term="Allocation",             cat="PROCESO", mean="Proceso Oracle PL-SQL de distribución de inventario entre tiendas — ejecutado tras Size Scaling; determina cuántas unidades van a cada tienda.",                   est="conf", nivel="ALTA",  dominio="R01", sistema="Oracle",       fn=7),
  dict(term="omnicanal",              cat="PROCESO", mean="Modelo de venta y fulfillment que unifica tienda física, ecommerce y app móvil — gestionado por Sterling OMS; señal de 96.69% pendientes indica fricción.",        est="conf", nivel="ALTA",  dominio="R04", sistema="Sterling OMS", fn=8),

  # ─── PROGRAMAS ABAP ────────────────────────────────────────────────────────
  dict(term="ZIMFIC002",          cat="ABAP", mean="Generación de facturas en SAP FI para órdenes de importación — módulo FI; paso final de contabilización del ciclo de importaciones.",                    est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=8),
  dict(term="ZIMPOB010B",         cat="ABAP", mean="Batch de creación de Purchase Orders de importación — genera POs en SAP MM desde solicitud de compra internacional.",                                    est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=8),
  dict(term="ZIMPOC001",          cat="ABAP", mean="Registro de datos del proveedor extranjero en la orden de importación — captura condiciones comerciales y datos de proveedor.",                          est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=7),
  dict(term="ZIMPOC002",          cat="ABAP", mean="Registro de condiciones de embarque: Incoterms, puerto de origen, fecha estimada de salida del proveedor.",                                             est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=7),
  dict(term="ZIMPOC003",          cat="ABAP", mean="Pre-embarque del proveedor — aviso de que la mercancía está lista; step 3 del flujo de importaciones.",                                                 est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=6),
  dict(term="ZIMPOC005",          cat="ABAP", mean="Registro de datos aduanales: agente aduanal, número de pedimento, fracciones arancelarias.",                                                            est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=7),
  dict(term="ZIMPOC007",          cat="ABAP", mean="Recepción de mercancía: registro de diferencias de faltante/sobrante respecto a la PO original.",                                                       est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=7),
  dict(term="ZIMPOC023",          cat="ABAP", mean="Actualización de estado de importación — mantiene trazabilidad del ciclo completo de la PO desde PO hasta recepción.",                                  est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=6),
  dict(term="ZIMPOC024",          cat="ABAP", mean="Cierre administrativo de la orden de importación — finaliza el ciclo en SAP; habilita el proceso de pago al proveedor.",                               est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=6),
  dict(term="ZRTPOC079",          cat="ABAP", mean="Reporte de pedimentos aduanales — versión original; reemplazado por ZRTPOC079N. Mantenido en modo legacy.",                                             est="conf", nivel="MEDIA", dominio="R04", sistema="SAP", fn=5),
  dict(term="ZRTPOC079N",         cat="ABAP", mean="Reporte de pedimentos aduanales — versión activa (abr-2025); extrae datos de SAP ECC para sistema POS. N = new.",                                      est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=7),
  dict(term="ZRT_PO_REP_EPI_BD",  cat="ABAP", mean="Reporte EPI de pedimentos en BD — extrae datos de pedimentos de SAP ECC para transferencia a POS (oct-2025). Uno de los programas más recientes del corpus.", est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=7),

  # ─── SEÑALES ───────────────────────────────────────────────────────────────
  dict(term="96.69% órdenes pendientes",  cat="SEÑAL", mean="El 96.69% de las órdenes en Sterling OMS están en estado 'pendiente' — señal de mayor criticidad del programa Liverpool AM. Raíz en SOMS z/OS.",              est="conf", nivel="ALTA",  dominio="R04",         sistema="Sterling OMS", fn=10),
  dict(term="SAP ECC EOL 2027-2030",      cat="SEÑAL", mean="SAP ha anunciado end-of-life para SAP ECC en 2027-2030 — driver principal de la modernización del ERP Liverpool y Suburbia.",                               est="conf", nivel="ALTA",  dominio="transversal",  sistema="SAP",          fn=9),
  dict(term="DataSources BW invalidos",   cat="SEÑAL", mean="La migración SAP ECC → S/4HANA invalida los DataSources tradicionales de BW — requiere BW Bridge o migración a SAP Analytics Cloud.",                       est="conf", nivel="ALTA",  dominio="R09",         sistema="SAP BW",       fn=8),
  dict(term="Siebel solo en LIV",         cat="SEÑAL", mean="Oracle Siebel CRM opera solo en Liverpool; Suburbia no tiene CRM — brecha competitiva y fragmentación de la experiencia del cliente.",                      est="conf", nivel="ALTA",  dominio="R02",         sistema="Siebel",       fn=7),
  dict(term="Bridgecore exclusivo LIV",   cat="SEÑAL", mean="Bridgecore es el gateway POS solo de Liverpool; Suburbia tiene arquitectura POS diferente — impide unificación del canal físico LIV+SBB.",                  est="conf", nivel="ALTA",  dominio="R06",         sistema="Bridgecore",   fn=7),
  dict(term="commercetools nov-2025",      cat="SEÑAL", mean="Liverpool seleccionó commercetools en noviembre 2025 para 'agentic commerce experiences' — ATG tiene fecha de muerte. Decisión estratégica confirmada.",    est="conf", nivel="ALTA",  dominio="R05",         sistema="ATG",          fn=9),
  dict(term="Apigee coexistiendo con IIB",cat="SEÑAL", mean="Dos capas de integración simultáneas: IBM IIB (AS-IS) y Apigee (target parcial) — riesgo de fragmentación lógica y duplicación de esfuerzo de mantenimiento.", est="conf", nivel="ALTA",  dominio="R10",         sistema="Apigee",       fn=8),
  dict(term="VPL 24×7 Banxico",           cat="SEÑAL", mean="VPL Vision Plus opera 24×7 con restricciones regulatorias Banxico para ventanas de mantenimiento — SLA con implicación regulatoria directa.",               est="conf", nivel="ALTA",  dominio="R03",         sistema="Mainframe",    fn=8),
  dict(term="4 instancias SAP BW",        cat="SEÑAL", mean="Existen 4 instancias BW independientes (Híbrido, LIV, PDM, BW4 SBB) — silos analíticos sin vista consolidada de empresa en tiempo real.",                  est="conf", nivel="ALTA",  dominio="R09",         sistema="SAP BW",       fn=7),
  dict(term="doble landscape SAP",        cat="SEÑAL", mean="Liverpool opera SAP ECC 6.0 (LIV on-prem) y SAP S/4HANA (SBB Azure) simultáneamente — escenario a resolver: brownfield ECC o greenfield S/4 para LIV.",    est="conf", nivel="ALTA",  dominio="transversal",  sistema="SAP",          fn=8),

  # ─── DOMINIOS ──────────────────────────────────────────────────────────────
  dict(term="R01 — Gestión Comercial",             cat="DOMINIO", mean="Planificación y gestión de producto, surtido y mercancía — PIM-STEP, Oracle PL-SQL, SAP MM, App Surtido.",                                                   est="conf", nivel="ALTA", dominio="R01",         sistema="—", fn=7),
  dict(term="R02 — Gestión de Clientes y Lealtad", cat="DOMINIO", mean="CRM, programa de puntos, Customer 360 — Siebel CRM (AS-IS), CDP-GCP (TO-BE), VPL Vision Plus (vista cliente).",                                             est="conf", nivel="ALTA", dominio="R02",         sistema="—", fn=7),
  dict(term="R03 — Servicios Financieros",          cat="DOMINIO", mean="Tarjeta de crédito, financiamiento, cobranza, autorización — VPL, FICO-TRIAD, Base24, Cyberfinancial, Card-Wizard, Mainframe. Regulado por Banxico/CONDUSEF.", est="conf", nivel="ALTA", dominio="R03",         sistema="—", fn=9),
  dict(term="R04 — Cadena de Suministro",           cat="DOMINIO", mean="Importaciones, fulfillment, logística 4PL, almacenes — SAP EWM, Sterling OMS, IBM IIB, Tumbleweed, Gestor4PL. Señal crítica: 96.69% pendientes.",            est="conf", nivel="ALTA", dominio="R04",         sistema="—", fn=9),
  dict(term="R05 — Canales Digitales",              cat="DOMINIO", mean="eCommerce, canales digitales, API — ATG/Endeca (AS-IS) → commercetools (TO-BE), Bridgecore, Apigee. Decisión estratégica nov-2025.",                         est="conf", nivel="ALTA", dominio="R05",         sistema="—", fn=8),
  dict(term="R06 — Operaciones de Tienda",          cat="DOMINIO", mean="Venta en piso, POS, cierre de caja — Bridgecore, Base24, SOMS, Mainframe. ~130 tiendas Liverpool + ~200 Suburbia.",                                          est="conf", nivel="ALTA", dominio="R06",         sistema="—", fn=8),
  dict(term="R07 — Finanzas y Contabilidad",        cat="DOMINIO", mean="Contabilidad general, reporting financiero, tesorería — SAP FI/CO, SAP BW, Tumbleweed (bancos/SAT). Empresa pública BMV: LIVEPOLC.",                        est="conf", nivel="ALTA", dominio="R07",         sistema="—", fn=7),
  dict(term="R08 — Recursos Humanos",               cat="DOMINIO", mean="Nómina, talento, beneficios — SAP HCM. Menor prioridad en el programa de modernización; Retain expected.",                                                   est="conf", nivel="MEDIA",dominio="R08",         sistema="—", fn=4),
  dict(term="R09 — Analítica e Inteligencia",       cat="DOMINIO", mean="Business Intelligence, analytics — SAP BW (4 instancias), CDP-GCP, SAP BusinessObjects, SAS on GCP. Impactado por migración S/4HANA.",                      est="conf", nivel="ALTA", dominio="R09",         sistema="—", fn=7),
  dict(term="R10 — Infraestructura y Plataforma",   cat="DOMINIO", mean="Integración, plataforma, API management — IBM IIB, Apigee, Control-D, Tumbleweed. Decisión de convergencia IIB → Apigee pendiente.",                        est="conf", nivel="ALTA", dominio="R10",         sistema="—", fn=7),

  # ─── VENDORS ───────────────────────────────────────────────────────────────
  dict(term="FIS Global",       cat="VENDOR", mean="Proveedor de VPL Vision Plus — software bancario/financiero. Tiene APIs modernas para VPL (alternativa Encapsulate sin reescribir).",    est="conf", nivel="ALTA", dominio="R03",         sistema="—", fn=8),
  dict(term="IBM",              cat="VENDOR", mean="Proveedor de IBM IIB (Integration Bus), Sterling OMS y plataforma z/OS — múltiples sistemas críticos de Liverpool.",                     est="conf", nivel="ALTA", dominio="transversal",  sistema="—", fn=9),
  dict(term="Oracle",           cat="VENDOR", mean="Proveedor de Siebel CRM, ATG Commerce, Endeca — sistemas en EOL o con hipótesis Repurchase. También Oracle PL-SQL Planning.",           est="conf", nivel="ALTA", dominio="transversal",  sistema="—", fn=8),
  dict(term="SAP",              cat="VENDOR", mean="Proveedor del ERP central (ECC + S/4HANA), BW, BusinessObjects, EWM, HCM — eje tecnológico de Liverpool. Partner estratégico.",         est="conf", nivel="ALTA", dominio="transversal",  sistema="—", fn=10),
  dict(term="ACI Worldwide",    cat="VENDOR", mean="Proveedor de Base24 — switch transaccional PCI-DSS para POS y ATM. Candidato a Retain por costo/riesgo de sustitución.",                est="conf", nivel="ALTA", dominio="R03",         sistema="—", fn=7),
  dict(term="Broadcom",         cat="VENDOR", mean="Proveedor de Tumbleweed MFT — interfaz con bancos, SAT, carriers. Broadcom adquirió CA/Symantec que era el vendor original.",           est="conf", nivel="ALTA", dominio="R10",         sistema="—", fn=6),
  dict(term="Google / GCP",     cat="VENDOR", mean="Plataforma cloud Google Cloud Platform — CDP, Gestor4PL, App Surtido, Apigee, SAS on GCP. Liverpool ya tiene capacidad GCP en producción.", est="conf", nivel="ALTA", dominio="transversal",  sistema="—", fn=8),
  dict(term="FICO",             cat="VENDOR", mean="Proveedor de FICO TRIAD — motor de originación y scoring crediticio LiverpoolCard. Producto maduro con integración directa a VPL.",      est="conf", nivel="ALTA", dominio="R03",         sistema="—", fn=7),
  dict(term="Stibo Systems",    cat="VENDOR", mean="Proveedor de STEP PIM — catálogo maestro de productos y atributos para LIV y SBB.",                                                     est="conf", nivel="ALTA", dominio="R01",         sistema="—", fn=6),
  dict(term="commercetools",    cat="VENDOR", mean="Plataforma ecommerce composable seleccionada nov-2025 — TO-BE para ATG/Endeca. Integración nativa con Salesforce; stack MACH (Microservices, API-first, Cloud-native, Headless).", est="conf", nivel="ALTA", dominio="R05",         sistema="—", fn=9),

  # ─── ESTRATEGIA 7R ─────────────────────────────────────────────────────────
  dict(term="Repurchase",              cat="7R", mean="Reemplazar el sistema por un producto comercial diferente. Aplica a ATG (→ commercetools), Siebel CRM (→ Salesforce/D365), SOMS (→ Sterling cloud o OMS commercetools).",  est="conf", nivel="ALTA", dominio="transversal", sistema="—", fn=8),
  dict(term="Refactor",               cat="7R", mean="Rediseño con cambios de código para mejorar arquitectura sin cambiar plataforma. Aplica a componentes Java/ABAP que deben modernizarse sin reemplazar el sistema.",         est="conf", nivel="ALTA", dominio="transversal", sistema="—", fn=7),
  dict(term="Replatform",             cat="7R", mean="Migración a nueva plataforma (cloud, runtime) con mínimos cambios de código. Aplica a SAP ECC → S/4HANA (brownfield) y a componentes Java hacia cloud-native.",             est="conf", nivel="ALTA", dominio="transversal", sistema="—", fn=7),
  dict(term="Rehost",                 cat="7R", mean="Lift and shift sin cambios de código ni arquitectura. Mínimo valor cloud-native; se usa solo como primer paso táctico urgente.",                                             est="conf", nivel="ALTA", dominio="transversal", sistema="—", fn=6),
  dict(term="Retain",                 cat="7R", mean="Mantener el sistema sin cambios. Aplica a Base24 (PCI-DSS, alto costo de cambio), SAP HCM (baja prioridad), Control-D (hasta que sus dependencias migren).",               est="conf", nivel="ALTA", dominio="transversal", sistema="—", fn=7),
  dict(term="Retire",                 cat="7R", mean="Decommission del sistema. Aplica a SAP BusinessObjects (EOL anunciado), BW PDM (si Oracle PL-SQL se moderniza), ZRTPOC079 (reemplazado por N).",                          est="conf", nivel="ALTA", dominio="transversal", sistema="—", fn=6),
  dict(term="Encapsulate / API-fy",   cat="7R", mean="Exponer el sistema legacy como servicio vía APIs sin reescribir. Aplica a VPL Vision Plus (FIS APIs disponibles), Mainframe (prerequisito para commercetools).",           est="conf", nivel="ALTA", dominio="transversal", sistema="—", fn=8),

  # ─── MÓDULOS SAP ───────────────────────────────────────────────────────────
  dict(term="SAP MM",       cat="MODULO", mean="Materials Management — gestión de materiales, compras, inventario, recepción de mercancía. Base del módulo de importaciones ZIM. Integrado con SAP EWM.",                  est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=8),
  dict(term="SAP SD",       cat="MODULO", mean="Sales and Distribution — ventas, pedidos, facturación, entregas. Integrado con Bridgecore (POS) y Sterling OMS (órdenes online).",                                         est="conf", nivel="ALTA",  dominio="R05", sistema="SAP", fn=7),
  dict(term="SAP FI",       cat="MODULO", mean="Financial Accounting — contabilidad general, cuentas por pagar/cobrar, activos fijos. Receptor de transacciones de todos los canales (Bridgecore, ATG, importaciones).",    est="conf", nivel="ALTA",  dominio="R07", sistema="SAP", fn=8),
  dict(term="SAP CO",       cat="MODULO", mean="Controlling — contabilidad de costos, centros de costo, reporting de gestión. Complemento de SAP FI para gestión financiera interna.",                                     est="conf", nivel="ALTA",  dominio="R07", sistema="SAP", fn=7),
  dict(term="SAP EWM",      cat="MODULO", mean="Extended Warehouse Management — gestión avanzada de almacenes. Integrado con SOMS (z/OS) para operaciones de fulfillment y con SAP MM para recepciones.",                   est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=7),
  dict(term="SAP HCM",      cat="MODULO", mean="Human Capital Management — nómina, recursos humanos, beneficios. Menor prioridad en el programa de modernización; hipótesis Retain.",                                       est="conf", nivel="ALTA",  dominio="R08", sistema="SAP", fn=5),
  dict(term="SAP PM / PMR", cat="MODULO", mean="Plant Maintenance / PMR — mantenimiento de activos de tiendas Liverpool. Módulo confirmado en dashboard AS-IS.",                                                             est="conf", nivel="MEDIA", dominio="R06", sistema="SAP", fn=4),
  dict(term="SAP RE",       cat="MODULO", mean="Real Estate — gestión de contratos de arrendamiento de locales de tiendas Liverpool. Dominio específico de retail con muchas tiendas arrendadas.",                          est="inf",  nivel="MEDIA", dominio="R07", sistema="SAP", fn=4),
  dict(term="ZIM",          cat="MODULO", mean="Prefijo de programas ABAP custom de importaciones Liverpool — Z (customización cliente) + IM (importaciones). ZIMFIC002, ZIMPOC001-007, etc. Corpus completo analizado.", est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=9),
  dict(term="ZRT",          cat="MODULO", mean="Prefijo de programas ABAP custom de reportes de importaciones — Z (customización cliente) + RT (report). ZRTPOC079, ZRTPOC079N.",                                          est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=7),

  # ─── MÓDULOS SAP ADICIONALES (dt-sap-doble-landscape + dt-proceso-importaciones-sap) ───
  dict(term="SAP SRM",      cat="MODULO", mean="Supplier Relationship Management — gestión de proveedores y contratos de compra. Presente en landscape LIV; soporta el ciclo de compras con proveedores nacionales e internacionales.",        est="conf", nivel="MEDIA", dominio="R04", sistema="SAP", fn=5),
  dict(term="SAP F&R",      cat="MODULO", mean="Forecasting & Replenishment — planificación de demanda y reposición automática de inventario. Complementa SAP PMR; alimenta los pedidos de compra de importaciones.",                          est="conf", nivel="MEDIA", dominio="R01", sistema="SAP", fn=5),
  dict(term="SAP PDM/PDTA", cat="MODULO", mean="Product Data Management / PDTA — gestión del ciclo de vida del producto en SAP ECC LIV: datos del artículo, especificaciones técnicas, jerarquías de clasificación.",                          est="conf", nivel="ALTA",  dominio="R01", sistema="SAP", fn=6),
  dict(term="MM-PUR",       cat="MODULO", mean="Módulo SAP de Compras (Purchasing) dentro de Materials Management — corazón del Módulo de Importaciones ZIM: EKKO/EKPO son las tablas de cabecera/posición de POs.",                          est="conf", nivel="ALTA",  dominio="R04", sistema="SAP", fn=8),
  dict(term="FI-AP",        cat="MODULO", mean="Accounts Payable dentro de Financial Accounting — saldos pendientes y pagados a proveedores internacionales (BSIK/BSAK). Paso final del ciclo de importaciones ZIM.",                          est="conf", nivel="ALTA",  dominio="R07", sistema="SAP", fn=7),
  dict(term="LE-SHP",       cat="MODULO", mean="Logistics Execution Shipping — entregas y documentos de entrega (LIKP/LIPS). Registra entregas parciales por pedimento en el Módulo de Importaciones.",                                        est="conf", nivel="MEDIA", dominio="R04", sistema="SAP", fn=5),
  dict(term="SAP GTS",      cat="MODULO", mean="SAP Global Trade Services — módulo estándar S/4HANA para importaciones y pedimentos. Candidato a Repurchase del Módulo ZIM custom (213 tablas Z → estándar). Absorbería cambios SAT automáticamente.", est="inf", nivel="MEDIA", dominio="R04", sistema="SAP", fn=7),

  # ─── ENTIDADES DE NEGOCIO ──────────────────────────────────────────────────
  dict(term="artículo",               cat="ENTIDAD", mean="Unidad básica del catálogo de producto Liverpool — representado como MARA/MARC en SAP ECC, enriquecido en PIM-STEP y publicado en ATG-Endeca y Bridgecore. El artículo es el objeto central del dominio R01.", est="conf", nivel="ALTA",  dominio="R01",        sistema="SAP",     fn=9),
  dict(term="SKU",                    cat="ENTIDAD", mean="Stock Keeping Unit — unidad mínima de inventario: artículo + color + talla. Insumo de Size Scaling (Oracle PL-SQL), OMS (Sterling), EWM y ATG-Endeca. El vocabulario retail más ubicuo.", est="conf", nivel="ALTA",  dominio="R01",        sistema="SAP",     fn=10),
  dict(term="sociedad (SAP)",         cat="ENTIDAD", mean="Entidad legal en el sistema SAP — Liverpool opera 3 sociedades: LIV (Liverpool), SBB (Suburbia) y Sfera Moda Joven (sociedad 150). El Módulo ZIM es multi-sociedad.", est="conf", nivel="ALTA",  dominio="transversal", sistema="SAP",     fn=8),
  dict(term="Sfera Moda Joven",       cat="ENTIDAD", mean="Tercera sociedad del grupo Liverpool (sociedad SAP 150) — identificada en el Módulo de Importaciones ZIM. Adicional a LIV (Liverpool) y SBB (Suburbia).",              est="conf", nivel="MEDIA", dominio="R01",        sistema="SAP",     fn=5),
  dict(term="proveedor internacional",cat="ENTIDAD", mean="Proveedor extranjero de mercancía de importación — registrado en LFA1/LFB1/LFM1 (SAP) y ZIM_LFA1 (extensión Z). Parte central del Módulo de Importaciones.",        est="conf", nivel="ALTA",  dominio="R04",        sistema="SAP",     fn=7),

  # ─── PROCESOS ADICIONALES (omnicanal + catálogo + finanzas) ───────────────
  dict(term="Click & Collect",        cat="PROCESO", mean="BOPIS — Buy Online, Pick Up In Store. Cliente compra en ATG/app y recoge en tienda física. Gestionado por Sterling OMS → SAP EWM → Bridgecore (confirmación).", est="conf", nivel="ALTA",  dominio="R04", sistema="Sterling OMS", fn=8),
  dict(term="Click & Deliver",        cat="PROCESO", mean="Compra digital con entrega a domicilio — ATG/app checkout → Sterling OMS → SAP EWM (CD picking) → carrier (última milla). El flujo omnicanal principal de Liverpool.", est="conf", nivel="ALTA",  dominio="R04", sistema="Sterling OMS", fn=8),
  dict(term="Ship from Store",        cat="PROCESO", mean="Fulfillment desde tienda física como origen — Sterling OMS asigna la tienda como punto de despacho; Bridgecore confirma; carrier recoge en tienda. Optimiza inventario distribuido.", est="conf", nivel="ALTA",  dominio="R04", sistema="Sterling OMS", fn=7),
  dict(term="devolución",             cat="PROCESO", mean="Logística inversa — cliente devuelve producto por cualquier canal. Sterling OMS gestiona el reverse logistics; SAP EWM recibe la mercancía; SAP FI registra el abono.", est="conf", nivel="ALTA",  dominio="R04", sistema="Sterling OMS", fn=7),
  dict(term="disputa / aclaración",   cat="PROCESO", mean="Reclamación del cliente sobre un cargo LiverpoolCard — Gestor de Aclaraciones (Mainframe) + Key Monitor (detección fraude) + Siebel CRM (gestión del caso). Proceso regulado CONDUSEF.", est="conf", nivel="ALTA",  dominio="R03", sistema="Mainframe",    fn=7),
  dict(term="gestión de precios",     cat="PROCESO", mean="Sincronización de precios entre SAP ECC (precio base), ATG-Endeca (precio web) y Bridgecore (precio tienda). Gobernanza de coherencia de precio omnicanal.", est="conf", nivel="ALTA",  dominio="R01", sistema="SAP",          fn=8),
  dict(term="alta de artículo",       cat="PROCESO", mean="Creación de un nuevo producto en el catálogo: PIM-STEP (atributos) → SAP PDM/PDTA → SAP ECC MARA (datos compra/inventario) → publicación ATG + Bridgecore.", est="conf", nivel="ALTA",  dominio="R01", sistema="SAP",          fn=7),
  dict(term="Incoterms",              cat="PROCESO", mean="International Commercial Terms — condiciones de entrega en importaciones: FOB, CIF, EXW, etc. Registrados en la PO (KONV) por ZIMPOC002. Determinan quién asume costos y riesgos del traslado.", est="conf", nivel="ALTA",  dominio="R04", sistema="SAP",          fn=7),
  dict(term="fracción arancelaria",   cat="PROCESO", mean="Código del Sistema Armonizado (SA) que clasifica la mercancía de importación. Determina la tasa de arancel (IGI) aplicable — registrada en el pedimento por el agente aduanal (ZIMPOB010B).", est="conf", nivel="ALTA",  dominio="R04", sistema="SAP",          fn=7),
  dict(term="agente aduanal",         cat="PROCESO", mean="Representante legal ante la Aduana Mexicana — registrado en tabla ZIM_AGAD. Seleccionado por el equipo de importaciones para cada pedimento; lógica de scoring en ZIMPOC024.", est="conf", nivel="ALTA",  dominio="R04", sistema="SAP",          fn=7),
  dict(term="última milla",           cat="PROCESO", mean="Tramo final de entrega al cliente — gestión de carriers (Estafeta, FedEx, SCOL) coordinados por TMS/Tumbleweed. SLA de entrega el factor diferenciador del NPS omnicanal.", est="conf", nivel="ALTA",  dominio="R04", sistema="IBM IIB",       fn=7),

  # ─── ARQUITECTURA (patrones y decisiones estratégicas) ────────────────────
  dict(term="MACH",                   cat="ARQUITECTURA", mean="Microservices, API-first, Cloud-native, Headless — arquitectura de referencia del stack moderno de Liverpool. Commercetools es un producto MACH-certified. Define el TO-BE de eCommerce.", est="conf", nivel="ALTA",  dominio="R05",        sistema="Digital",  fn=9),
  dict(term="composable commerce",    cat="ARQUITECTURA", mean="Modelo de eCommerce basado en APIs y componentes intercambiables (best-of-breed) — opuesto al monolito ATG. Commercetools es la plataforma composable seleccionada por Liverpool.", est="conf", nivel="ALTA",  dominio="R05",        sistema="Digital",  fn=9),
  dict(term="headless commerce",      cat="ARQUITECTURA", mean="Arquitectura donde el frontend (storefront) se desacopla del backend eCommerce mediante APIs. El storefront llama a las APIs de commercetools sin depender de su capa de presentación.", est="conf", nivel="ALTA",  dominio="R05",        sistema="Digital",  fn=8),
  dict(term="agentic commerce",       cat="ARQUITECTURA", mean="Modelo de compra asistido por agentes de IA que actúan en nombre del cliente — objetivo declarado de Liverpool al seleccionar commercetools ('agentic commerce experiences', nov-2025).", est="conf", nivel="ALTA",  dominio="R05",        sistema="Digital",  fn=9),
  dict(term="brownfield (SAP)",       cat="ARQUITECTURA", mean="Estrategia de migración SAP ECC → S/4HANA mediante upgrade in-place — preserva las 213+ tablas Z de customizaciones. Menor riesgo, pero acumula deuda técnica existente.", est="conf", nivel="ALTA",  dominio="transversal", sistema="SAP",      fn=8),
  dict(term="greenfield (SAP)",       cat="ARQUITECTURA", mean="Reimplementación SAP desde cero — tomar el template de Suburbia S/4HANA (SBB) como base para Liverpool LIV. Mayor riesgo de rollout, pero elimina deuda técnica del ECC.", est="conf", nivel="ALTA",  dominio="transversal", sistema="SAP",      fn=8),
  dict(term="Strangler-Fig",          cat="ARQUITECTURA", mean="Patrón de modernización incremental — reemplazar sistema legacy capability por capability mediante una fachada. Aplicado a ATG→commercetools y VPL→APIs FIS. Alternativa al big-bang cutover.", est="conf", nivel="ALTA",  dominio="transversal", sistema="—",       fn=8),
  dict(term="blast radius",           cat="ARQUITECTURA", mean="Alcance de impacto de un cambio en un sistema sobre los demás — concepto clave del DT de Bus de Integración: cualquier migración tiene blast radius que pasa por IBM IIB.", est="conf", nivel="ALTA",  dominio="transversal", sistema="IBM IIB",  fn=7),

  # ─── REGULACIÓN ──────────────────────────────────────────────────────────────
  dict(term="Banxico",                cat="REG", mean="Banco de México — regulador financiero; emite normas para autorizaciones de tarjeta (VPL 24×7) y pagos (SPEI). Circular 14/2017 aplica al stack LiverpoolCard. Restricción en ventanas de mantenimiento VPL.", est="conf", nivel="ALTA",  dominio="R03",         sistema="Mainframe",  fn=9),
  dict(term="CONDUSEF",               cat="REG", mean="Comisión Nacional para la Protección y Defensa de los Usuarios de Servicios Financieros — regula contratos de crédito LiverpoolCard, CETES de referencia y gestión de disputas/aclaraciones.", est="conf", nivel="ALTA",  dominio="R03",         sistema="Mainframe",  fn=8),
  dict(term="SAT",                    cat="REG", mean="Servicio de Administración Tributaria — receptor de pedimentos de importación y de facturación electrónica (CFDI). Tumbleweed transfiere CFDI al SAT; ZRTPOC079N extrae datos de pedimentos ECC.", est="conf", nivel="ALTA",  dominio="R04",         sistema="IBM IIB",    fn=8),
  dict(term="PCI-DSS",                cat="REG", mean="Payment Card Industry Data Security Standard — estándar de seguridad para transmisión de datos de tarjeta. Base24 (ACI Worldwide) está certificado PCI-DSS; Bridgecore en su alcance.", est="conf", nivel="ALTA",  dominio="R03",         sistema="Base24",     fn=8),
  dict(term="Buró de Crédito",        cat="REG", mean="Sociedad de Información Crediticia — consultado en originación LiverpoolCard (FICO TRIAD). Determina el historial crediticio del solicitante antes de aprobar nueva tarjeta.", est="conf", nivel="ALTA",  dominio="R03",         sistema="Base24",     fn=7),
  dict(term="IGI / IVA / IEPS",       cat="REG", mean="Impuesto General de Importación / IVA / IEPS — gravámenes calculados en el pedimento de importación; registrados en tablas ZTASA* del Módulo ZIM. El cambio SAT (14→16 dígitos oct-2025) impacta el cálculo.", est="conf", nivel="ALTA",  dominio="R04",         sistema="SAP",        fn=7),

  # ─── SEÑALES ADICIONALES ─────────────────────────────────────────────────────
  dict(term="213 tablas Z (Importaciones)", cat="SEÑAL", mean="El Módulo de Importaciones ZIM tiene 213 tablas/objetos Z identificados en el código fuente — medida de la deuda técnica acumulada y argumento a favor de Repurchase hacia SAP GTS.", est="conf", nivel="ALTA",  dominio="R04",         sistema="SAP",     fn=8),
  dict(term="multi-sociedad LIV+SBB+Sfera", cat="SEÑAL", mean="El Módulo de Importaciones ZIM opera en 3 sociedades SAP simultáneamente: Liverpool (LIV), Suburbia (SBB) y Sfera Moda Joven (150) — complejidad cross-entity que impacta la estrategia de migración.", est="conf", nivel="ALTA",  dominio="transversal", sistema="SAP",     fn=7),
  dict(term="EWM N5 automatización CD", cat="SEÑAL", mean="Centro de Distribución automatizado con robots Locus, sorters Mecalux y Putwall ATOX — gestionado por SAP EWM. La automatización física hace crítica la disponibilidad de EWM; una migración ECC→S/4 que lo deje fuera afecta el fulfillment.", est="conf", nivel="ALTA",  dominio="R04",         sistema="SAP",     fn=7),
  dict(term="56 servicios SAP (mayor bloque)", cat="SEÑAL", mean="SAP tiene 56 servicios en el inventario del Dashboard — el mayor bloque de cualquier sistema del landscape. Supera al siguiente (R04 con 26). Confirma que SAP es el sistema de mayor alcance.", est="conf", nivel="ALTA",  dominio="transversal", sistema="SAP",     fn=6),
]

# Asignar IDs
terms = []
for i, t in enumerate(TERMS_RAW, 1):
    t = dict(t)
    t["id"] = _vid(t["term"])
    terms.append(t)

# ─────────────────────────────────────────────────────────────────────────────
# ESTADÍSTICAS
# ─────────────────────────────────────────────────────────────────────────────
cats  = {}
nivs  = {}
doms  = {}
for t in terms:
    cats[t["cat"]] = cats.get(t["cat"], 0) + 1
    nivs[t["nivel"]] = nivs.get(t["nivel"], 0) + 1
    doms[t["dominio"]] = doms.get(t["dominio"], 0) + 1

# ─────────────────────────────────────────────────────────────────────────────
# HTML
# ─────────────────────────────────────────────────────────────────────────────
DATA_JSON = json.dumps(terms, ensure_ascii=False)

HTML = r"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Liverpool Brain · Vocabulario</title>
<style>
:root{
  --bg:#0d0408;--bg2:#100608;--panel:#1a0a10;--line:#2e1020;
  --cerise:#E00198;--cerise-d:#b5007a;--sky:#87C3D3;--rose:#DA7AB0;
  --txt:#F8F0F5;--muted:#c4a8bc;--muted2:#9a7d92;
  --alta:#22c55e;--media:#f59e0b;--amb:#ef4444;--cand:#6b7280;
  --cat-sis:#E00198;--cat-pro:#8b5cf6;--cat-abp:#0891b2;--cat-sen:#ef4444;
  --cat-dom:#f59e0b;--cat-ven:#10b981;--cat-7r:#6366f1;--cat-mod:#06b6d4;
  --cat-ent:#f97316;--cat-arq:#a855f7;--cat-reg:#dc2626;
  --glass:rgba(255,255,255,.05);--glassb:rgba(255,255,255,.10);
}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;
  height:100vh;display:flex;flex-direction:column;overflow:hidden}

/* ── AURORA BG ── */
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}
.aurora::before{content:"";position:absolute;border-radius:50%;filter:blur(100px);
  width:55vw;height:55vw;left:-10vw;top:-15vw;
  background:radial-gradient(circle,rgba(224,1,152,.4),transparent 70%);
  animation:f1 24s ease-in-out infinite}
.aurora::after{content:"";position:absolute;border-radius:50%;filter:blur(90px);
  width:45vw;height:45vw;right:-12vw;bottom:-10vw;
  background:radial-gradient(circle,rgba(135,195,211,.25),transparent 70%);
  animation:f2 28s ease-in-out infinite}
@keyframes f1{50%{transform:translate(5vw,6vh) scale(1.1)}}
@keyframes f2{50%{transform:translate(-5vw,8vh) scale(1.08)}}

/* ── HERO ── */
.hero{
  position:relative;overflow:hidden;
  background:linear-gradient(135deg,#0d0408 0%,#200a14 50%,#0d0408 100%);
  border-bottom:1px solid rgba(224,1,152,.2);
  padding-bottom:28px;flex-shrink:0;
}
.hero-grid{
  position:absolute;inset:0;
  background-image:
    linear-gradient(rgba(224,1,152,.07) 1px,transparent 1px),
    linear-gradient(90deg,rgba(224,1,152,.07) 1px,transparent 1px);
  background-size:48px 48px;
  mask-image:linear-gradient(to bottom,transparent,rgba(0,0,0,.5) 40%,rgba(0,0,0,.3) 70%,transparent);
  pointer-events:none;
}
.hero-bar{
  position:relative;z-index:1;
  display:flex;align-items:center;gap:16px;
  padding:14px 28px 16px;
  border-bottom:1px solid rgba(255,255,255,.06);
}
.hero-bar .crumb{font-size:10px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.3)}
.hero-bar .crumb em{color:var(--cerise);font-style:normal}
.hero-bar .pill{
  font-size:9px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;
  padding:3px 8px;border-radius:20px;
  background:rgba(224,1,152,.15);color:var(--cerise);border:1px solid rgba(224,1,152,.3);
}
.hero-body{
  position:relative;z-index:1;
  padding:28px 28px 0;
  display:flex;align-items:flex-end;gap:32px;flex-wrap:wrap;
}
.hero-title{flex:1;min-width:240px}
.hero-label{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--cerise);margin-bottom:8px}
.hero-h1{
  font-size:clamp(26px,4.5vw,44px);font-weight:900;letter-spacing:-.03em;line-height:1.1;
  background:linear-gradient(135deg,#fff 40%,rgba(218,122,176,.8));
  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
}
.hero-sub{margin-top:8px;font-size:12px;color:var(--muted);line-height:1.6;max-width:54ch}
.hero-stats{display:flex;gap:8px;flex-wrap:wrap;align-items:flex-end;padding-bottom:4px}
.stat-block{
  background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);
  border-radius:12px;padding:14px 18px;min-width:100px;
}
.stat-block .sn{
  font-size:30px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;
  background:linear-gradient(135deg,var(--cerise),#f472b6);
  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;line-height:1;
}
.stat-block.sky .sn{background:linear-gradient(135deg,var(--sky),#a5d8e6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
.stat-block .sl{font-size:9px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2);margin-top:4px}

/* ── TOOLBAR ── */
.toolbar{
  display:flex;align-items:center;gap:10px;padding:10px 20px;
  background:rgba(16,6,10,.9);border-bottom:1px solid var(--line);
  flex-wrap:wrap;flex-shrink:0;
}
.search-wrap{position:relative;flex:1;min-width:180px;max-width:340px}
.search-wrap input{
  width:100%;background:rgba(255,255,255,.05);border:1px solid var(--line);
  color:var(--txt);border-radius:8px;padding:6px 10px 6px 32px;
  font-size:12.5px;outline:none;transition:.18s;
}
.search-wrap input:focus{border-color:rgba(224,1,152,.5);box-shadow:0 0 0 2px rgba(224,1,152,.12)}
.search-wrap .icon{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:var(--muted2);font-size:13px;pointer-events:none}
.sel{
  background:rgba(255,255,255,.05);border:1px solid var(--line);color:var(--txt);
  border-radius:8px;padding:6px 10px;font-size:12px;outline:none;cursor:pointer;
  transition:.18s;
}
.sel:focus{border-color:rgba(224,1,152,.5)}
.cat-tabs{display:flex;gap:5px;flex-wrap:wrap}
.tab{
  font-size:10.5px;font-weight:700;letter-spacing:.04em;text-transform:uppercase;
  padding:5px 10px;border-radius:20px;cursor:pointer;border:1px solid transparent;
  transition:.18s;color:var(--muted2);background:transparent;
}
.tab.active,.tab:hover{color:#fff}
.tab[data-cat="TODOS"].active{background:rgba(255,255,255,.12);border-color:rgba(255,255,255,.2)}
.tab[data-cat="SISTEMA"].active  {background:rgba(224,1,152,.2);border-color:var(--cat-sis);color:var(--cat-sis)}
.tab[data-cat="PROCESO"].active  {background:rgba(139,92,246,.2);border-color:var(--cat-pro);color:var(--cat-pro)}
.tab[data-cat="ABAP"].active     {background:rgba(8,145,178,.2);border-color:var(--cat-abp);color:var(--cat-abp)}
.tab[data-cat="SEÑAL"].active    {background:rgba(239,68,68,.2);border-color:var(--cat-sen);color:var(--cat-sen)}
.tab[data-cat="DOMINIO"].active  {background:rgba(245,158,11,.2);border-color:var(--cat-dom);color:var(--cat-dom)}
.tab[data-cat="VENDOR"].active   {background:rgba(16,185,129,.2);border-color:var(--cat-ven);color:var(--cat-ven)}
.tab[data-cat="7R"].active       {background:rgba(99,102,241,.2);border-color:var(--cat-7r);color:var(--cat-7r)}
.tab[data-cat="MODULO"].active   {background:rgba(6,182,212,.2);border-color:var(--cat-mod);color:var(--cat-mod)}
.tab[data-cat="ENTIDAD"].active  {background:rgba(249,115,22,.2);border-color:var(--cat-ent);color:var(--cat-ent)}
.tab[data-cat="ARQUITECTURA"].active{background:rgba(168,85,247,.2);border-color:var(--cat-arq);color:var(--cat-arq)}
.tab[data-cat="REG"].active      {background:rgba(220,38,38,.2);border-color:var(--cat-reg);color:var(--cat-reg)}
.count-badge{
  font-size:9px;font-weight:700;padding:1px 5px;border-radius:10px;
  background:rgba(255,255,255,.1);color:var(--muted);margin-left:2px;
}
.toolbar-right{display:flex;align-items:center;gap:8px;margin-left:auto}
.results-count{font-size:11px;color:var(--muted2)}

/* ── TABLE ── */
.table-wrap{flex:1;overflow:auto;padding:0}
table{width:100%;border-collapse:collapse;font-size:12.5px}
thead{position:sticky;top:0;z-index:5;background:rgba(16,6,10,.97);backdrop-filter:blur(8px)}
thead th{
  padding:8px 12px;text-align:left;font-size:9.5px;font-weight:800;letter-spacing:.1em;
  text-transform:uppercase;color:var(--muted2);border-bottom:1px solid var(--line);
  cursor:pointer;user-select:none;white-space:nowrap;
}
thead th:hover{color:var(--cerise)}
thead th.sorted{color:var(--cerise)}
thead th .arrow{margin-left:4px;opacity:.6;font-size:9px}
tbody tr{border-bottom:1px solid rgba(255,255,255,.04);transition:.15s}
tbody tr:hover{background:rgba(224,1,152,.05)}
tbody td{padding:8px 12px;vertical-align:top}

/* term + mean */
.td-term{width:170px;min-width:130px}
.term-name{font-weight:700;font-size:12.5px;color:var(--txt);line-height:1.3;margin-bottom:3px}
.term-id{font-size:9px;font-family:'SF Mono',Consolas,monospace;color:var(--muted2)}
.td-mean{max-width:420px;color:var(--muted);font-size:12px;line-height:1.55}

/* cat pill */
.cat-pill{
  display:inline-block;font-size:9px;font-weight:800;letter-spacing:.08em;
  text-transform:uppercase;padding:2px 7px;border-radius:20px;border:1px solid transparent;
  white-space:nowrap;
}
.cat-SISTEMA{background:rgba(224,1,152,.15);color:var(--cat-sis);border-color:rgba(224,1,152,.3)}
.cat-PROCESO{background:rgba(139,92,246,.15);color:var(--cat-pro);border-color:rgba(139,92,246,.3)}
.cat-ABAP   {background:rgba(8,145,178,.15);color:var(--cat-abp);border-color:rgba(8,145,178,.3)}
.cat-SEÑAL  {background:rgba(239,68,68,.15);color:var(--cat-sen);border-color:rgba(239,68,68,.3)}
.cat-DOMINIO{background:rgba(245,158,11,.15);color:var(--cat-dom);border-color:rgba(245,158,11,.3)}
.cat-VENDOR {background:rgba(16,185,129,.15);color:var(--cat-ven);border-color:rgba(16,185,129,.3)}
.cat-7R     {background:rgba(99,102,241,.15);color:var(--cat-7r);border-color:rgba(99,102,241,.3)}
.cat-MODULO {background:rgba(6,182,212,.15);color:var(--cat-mod);border-color:rgba(6,182,212,.3)}
.cat-ENTIDAD{background:rgba(249,115,22,.15);color:var(--cat-ent);border-color:rgba(249,115,22,.3)}
.cat-ARQUITECTURA{background:rgba(168,85,247,.15);color:var(--cat-arq);border-color:rgba(168,85,247,.3)}
.cat-REG    {background:rgba(220,38,38,.15);color:var(--cat-reg);border-color:rgba(220,38,38,.3)}

/* nivel dot */
.nivel-dot{display:inline-flex;align-items:center;gap:5px;font-size:10px;font-weight:700;white-space:nowrap}
.dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}
.dot-ALTA    {background:var(--alta)}
.dot-MEDIA   {background:var(--media)}
.dot-AMBIGUA {background:var(--amb)}
.dot-CANDIDATO{background:var(--cand)}
.lbl-ALTA    {color:var(--alta)}
.lbl-MEDIA   {color:var(--media)}
.lbl-AMBIGUA {color:var(--amb)}
.lbl-CANDIDATO{color:var(--cand)}

/* dominio badge */
.dom-badge{
  font-size:9px;font-weight:800;letter-spacing:.06em;
  padding:2px 7px;border-radius:8px;background:rgba(135,195,211,.12);
  color:var(--sky);border:1px solid rgba(135,195,211,.25);white-space:nowrap;
}
/* sistema tag */
.sis-tag{font-size:10px;color:var(--muted2);font-family:'SF Mono',Consolas,monospace}

/* fn bar */
.fn-bar{display:flex;align-items:center;gap:5px}
.fn-track{width:48px;height:5px;background:rgba(255,255,255,.08);border-radius:3px;overflow:hidden}
.fn-fill {height:100%;border-radius:3px;background:linear-gradient(90deg,var(--cerise),#f472b6)}
.fn-num{font-size:10px;font-weight:700;color:var(--muted2);min-width:14px;text-align:right}

/* empty */
.empty{padding:60px 20px;text-align:center;color:var(--muted2);font-size:13px}
</style>
</head>
<body>
<div class="aurora"></div>

<!-- ── HERO ── -->
<div class="hero">
  <div class="hero-grid"></div>
  <div class="hero-bar">
    <img src="Liverpool_logo.png" alt="Liverpool" style="height:30px;width:auto;flex-shrink:0" onerror="this.style.display='none'">
    <span class="crumb">Liverpool Brain <em>· SPE-AM-003</em></span>
    <span class="pill">DISCOVER · Etapa 0</span>
  </div>
  <div class="hero-body">
    <div class="hero-title">
      <div class="hero-label">Vocabulario Empresarial</div>
      <div class="hero-h1">Vocabulario<br>Liverpool</div>
      <div class="hero-sub">Léxico canónico del corpus AS-IS — 13 DTs, 12 programas ABAP (ZIM/ZRT), dashboard de arquitectura y RTB v5. Fuente de verdad para business_name de componentes y reglas.</div>
    </div>
    <div class="hero-stats">
      STATS_PLACEHOLDER
    </div>
  </div>
</div>

<!-- ── TOOLBAR ── -->
<div class="toolbar">
  <div class="search-wrap">
    <span class="icon">🔍</span>
    <input type="text" id="q" placeholder="Buscar término, significado, sistema..." oninput="render()">
  </div>
  <div class="cat-tabs" id="tabs">
    <button class="tab active" data-cat="TODOS" onclick="setTab(this)">Todos <span class="count-badge" id="cnt-TODOS">0</span></button>
    <button class="tab" data-cat="SISTEMA" onclick="setTab(this)">Sistema <span class="count-badge" id="cnt-SISTEMA">0</span></button>
    <button class="tab" data-cat="PROCESO" onclick="setTab(this)">Proceso <span class="count-badge" id="cnt-PROCESO">0</span></button>
    <button class="tab" data-cat="ABAP" onclick="setTab(this)">ABAP <span class="count-badge" id="cnt-ABAP">0</span></button>
    <button class="tab" data-cat="SEÑAL" onclick="setTab(this)">Señal <span class="count-badge" id="cnt-SEÑAL">0</span></button>
    <button class="tab" data-cat="DOMINIO" onclick="setTab(this)">Dominio <span class="count-badge" id="cnt-DOMINIO">0</span></button>
    <button class="tab" data-cat="VENDOR" onclick="setTab(this)">Vendor <span class="count-badge" id="cnt-VENDOR">0</span></button>
    <button class="tab" data-cat="7R" onclick="setTab(this)">7R <span class="count-badge" id="cnt-7R">0</span></button>
    <button class="tab" data-cat="MODULO" onclick="setTab(this)">Módulo <span class="count-badge" id="cnt-MODULO">0</span></button>
    <button class="tab" data-cat="ENTIDAD" onclick="setTab(this)">Entidad <span class="count-badge" id="cnt-ENTIDAD">0</span></button>
    <button class="tab" data-cat="ARQUITECTURA" onclick="setTab(this)">Arquitectura <span class="count-badge" id="cnt-ARQUITECTURA">0</span></button>
    <button class="tab" data-cat="REG" onclick="setTab(this)">Regulación <span class="count-badge" id="cnt-REG">0</span></button>
  </div>
  <div class="toolbar-right">
    <select class="sel" id="selDom" onchange="render()">
      <option value="">Todos los dominios</option>
      <option>R01</option><option>R02</option><option>R03</option>
      <option>R04</option><option>R05</option><option>R06</option>
      <option>R07</option><option>R08</option><option>R09</option>
      <option>R10</option><option>transversal</option>
    </select>
    <select class="sel" id="selNivel" onchange="render()">
      <option value="">Todos los niveles</option>
      <option>ALTA</option><option>MEDIA</option><option>AMBIGUA</option><option>CANDIDATO</option>
    </select>
    <span class="results-count" id="rcnt"></span>
  </div>
</div>

<!-- ── TABLE ── -->
<div class="table-wrap">
  <table>
    <thead>
      <tr>
        <th onclick="sort('term')" id="h-term">Término <span class="arrow" id="a-term"></span></th>
        <th onclick="sort('cat')" id="h-cat">Categoría <span class="arrow" id="a-cat"></span></th>
        <th>Significado</th>
        <th onclick="sort('nivel')" id="h-nivel">Confianza <span class="arrow" id="a-nivel"></span></th>
        <th onclick="sort('dominio')" id="h-dominio">Dominio <span class="arrow" id="a-dominio"></span></th>
        <th onclick="sort('sistema')" id="h-sistema">Sistema <span class="arrow" id="a-sistema"></span></th>
        <th onclick="sort('fn')" id="h-fn" style="width:80px">Rel. <span class="arrow" id="a-fn"></span></th>
      </tr>
    </thead>
    <tbody id="tbody"></tbody>
  </table>
  <div class="empty" id="empty" style="display:none">Sin resultados para los filtros actuales</div>
</div>

<script>
const DATA = DATA_PLACEHOLDER;

let activeCat = 'TODOS';
let sortCol   = 'fn';
let sortDir   = -1;  // -1 desc, 1 asc

// ── conteos ──
const cnts = {};
DATA.forEach(t=>{cnts[t.cat]=(cnts[t.cat]||0)+1});
cnts['TODOS'] = DATA.length;
Object.entries(cnts).forEach(([k,v])=>{
  const el = document.getElementById('cnt-'+k);
  if(el) el.textContent = v;
});

function setTab(btn){
  document.querySelectorAll('.tab').forEach(b=>b.classList.remove('active'));
  btn.classList.add('active');
  activeCat = btn.dataset.cat;
  render();
}

function sort(col){
  if(sortCol===col) sortDir*=-1; else{sortCol=col;sortDir=-1;}
  document.querySelectorAll('thead th').forEach(h=>h.classList.remove('sorted'));
  document.querySelectorAll('.arrow').forEach(a=>a.textContent='');
  const th = document.getElementById('h-'+col);
  const ar = document.getElementById('a-'+col);
  if(th) th.classList.add('sorted');
  if(ar) ar.textContent = sortDir===-1?'↓':'↑';
  render();
}

const NIV_ORD = {ALTA:0,MEDIA:1,AMBIGUA:2,CANDIDATO:3};

function render(){
  const q    = document.getElementById('q').value.toLowerCase().trim();
  const dom  = document.getElementById('selDom').value;
  const niv  = document.getElementById('selNivel').value;

  let rows = DATA.filter(t=>{
    if(activeCat!=='TODOS' && t.cat!==activeCat) return false;
    if(dom && !t.dominio.includes(dom)) return false;
    if(niv && t.nivel!==niv) return false;
    if(q){
      const hay = (t.term+' '+t.mean+' '+t.sistema+' '+t.dominio+' '+t.cat).toLowerCase();
      if(!hay.includes(q)) return false;
    }
    return true;
  });

  rows.sort((a,b)=>{
    let av=a[sortCol], bv=b[sortCol];
    if(sortCol==='nivel'){av=NIV_ORD[a.nivel]??9; bv=NIV_ORD[b.nivel]??9;}
    if(sortCol==='fn'){av=Number(a.fn); bv=Number(b.fn);}
    if(av<bv) return -sortDir;
    if(av>bv) return sortDir;
    return 0;
  });

  document.getElementById('rcnt').textContent = rows.length+' términos';
  const tbody = document.getElementById('tbody');
  const empty = document.getElementById('empty');
  if(!rows.length){tbody.innerHTML='';empty.style.display='block';return;}
  empty.style.display='none';

  tbody.innerHTML = rows.map(t=>{
    const fnPct = Math.round((t.fn/10)*100);
    const catKey = t.cat.replace('Ñ','N'); // safe CSS class
    return `<tr>
      <td class="td-term">
        <div class="term-name">${esc(t.term)}</div>
        <div class="term-id">${esc(t.id)}</div>
      </td>
      <td><span class="cat-pill cat-${esc(t.cat)}">${esc(t.cat)}</span></td>
      <td class="td-mean">${esc(t.mean)}</td>
      <td>
        <span class="nivel-dot">
          <span class="dot dot-${t.nivel}"></span>
          <span class="lbl-${t.nivel}">${t.nivel}</span>
        </span>
      </td>
      <td><span class="dom-badge">${esc(t.dominio)}</span></td>
      <td><span class="sis-tag">${esc(t.sistema)}</span></td>
      <td>
        <div class="fn-bar">
          <div class="fn-track"><div class="fn-fill" style="width:${fnPct}%"></div></div>
          <span class="fn-num">${t.fn}</span>
        </div>
      </td>
    </tr>`;
  }).join('');
}

function esc(s){
  return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// init sort arrow
document.getElementById('a-fn').textContent='↓';
document.getElementById('h-fn').classList.add('sorted');
render();
</script>
</body>
</html>
"""

# ─────────────────────────────────────────────────────────────────────────────
# Stats HTML
# ─────────────────────────────────────────────────────────────────────────────
def _stat(n, label, sky=False):
    cls = "stat-block sky" if sky else "stat-block"
    return f'<div class="{cls}"><div class="sn">{n}</div><div class="sl">{label}</div></div>'

alta_count  = sum(1 for t in terms if t["nivel"] == "ALTA")
abap_count  = sum(1 for t in terms if t["cat"] == "ABAP")

stats_html = (
    _stat(len(terms), "Términos") +
    _stat(len(cats),  "Categorías", sky=True) +
    _stat(alta_count, "Confianza ALTA") +
    _stat(abap_count, "Programas ABAP", sky=True)
)

html_out = (
    HTML
    .replace("STATS_PLACEHOLDER", stats_html)
    .replace("DATA_PLACEHOLDER", DATA_JSON)
)

OUT.write_text(html_out, encoding="utf-8")
print(f"vocabulary-catalog-liv.html escrito · {len(terms)} términos · {len(cats)} categorías")
for k, v in sorted(cats.items()):
    print(f"  {k:10s} {v:3d}")
print(f"  Confianza ALTA: {alta_count} / {len(terms)}")
