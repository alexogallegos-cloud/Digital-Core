# -*- coding: utf-8 -*-
"""
panorama_data.py — Datos AS-IS de MONEX recabados por investigacion publica.
Fuente de: catalogo de productos (~64), landscape de pagos, correlacion producto-riel,
holdings, hechos corporativos, fortalezas y gaps.
Cargado por build-monex-brain.py en las tablas del brain. El brain es la fuente de verdad.
"""

# --- Holdings (hallazgo estructural: dos holdings separados desde 2017) ---
HOLDINGS = [
    ("GFM", "Grupo Financiero Monex",
     "Banco Monex; Monex Casa de Bolsa; Monex Operadora de Fondos; Fiduciario",
     "Grupo financiero regulado en Mexico. Banca, casa de bolsa, fondos y fiduciario."),
    ("MNI", "MNI Holding",
     "Monex Europe; Monex Global; Monex USA; Monex Canada; MonFX; Tempus",
     "Holding separado del Grupo Financiero desde diciembre 2017. Brazos internacionales de FX y pagos."),
]

# --- Hechos corporativos (escala AS-IS) ---
COMPANY_FACTS = [
    ("Clientes activos (grupo)", "73,000+", "2026", "monexglobal.com/about-monex"),
    ("Operaciones FX al ano", "~1.7 millones", "2026", "monexglobal.com/about-monex"),
    ("Volumen FX anual", "~198,000 millones USD", "2026", "monexglobal.com/about-monex"),
    ("Activos totales (grupo)", "~16.1 mil millones USD", "2024", "Monex S.A.P.I. 4T24"),
    ("Ingreso operativo (S.A.P.I.)", "15,730 millones MXN (+19% YoY)", "2024", "Monex S.A.P.I. 4T24"),
    ("ROE", "23.8%", "2024", "Monex S.A.P.I. 4T24"),
    ("Empleados", "~2,816", "2024", "Monex S.A.P.I. 4T24"),
    ("Paises con presencia", "7 (MX, US, CA, UK, ES, NL, SG)", "2026", "monexglobal.com/about-monex"),
    ("Mezcla ingreso Banco Monex", "FX y pagos 43.8%; FX internacional 23.2%; banca tradicional 14.4%", "2024", "HR Ratings 2024"),
]

# --- Rieles de pago (columnas de la matriz ejecutiva) ---
# rail_id, nombre corto, alcance, participacion, nota, fuente
PAYMENT_RAILS = [
    ("SPEI",    "SPEI",              "Domestico MXN",      "Directo",   "Participante directo, codigo de banco 112 (BMONEX), emite CEP", "Banxico"),
    ("SPID",    "SPID",              "Domestico USD",      "Directo",   "Participante directo USD interbancario en Mexico", "Banxico / docs Monex"),
    ("CODI",    "CoDi",              "Cobro digital MXN",  "Directo",   "Cobros digitales sobre SPEI; ofrecido para cobranza", "monex.com.mx"),
    ("DOM",     "Domiciliacion",     "Debito directo MXN", "Directo",   "Cargo automatico y cobro recurrente", "monex.com.mx"),
    ("INT",     "Interno",           "Traspaso en libros", "N/A",       "Traspaso entre cuentas Monex (multidivisa)", "monex.com.mx"),
    ("CIESAT",  "CIE / SAT",         "Servicios e impuestos MXN", "Directo", "Pago de servicios por convenio CIE y de impuestos SAT/DPA", "monex.com.mx"),
    ("SWIFT",   "SWIFT",             "Cross-border",       "Directo",   "Miembro directo, BIC MONXMXMM", "theswiftcodes.com"),
    ("CLS",     "CLS",               "Liquidacion PvP FX", "Directo",   "Miembro de liquidacion desde 2018; third-party 2020; CLSNet 2025", "cls-group.com"),
    ("SEPA",    "SEPA",              "EUR (EU)",           "Indirecto", "Via banco patrocinador (Monex Europe/Espana)", "monexeurope.eu"),
    ("UK",      "UK (FPS/Bacs/CHAPS)","GBP (UK)",          "Indirecto", "Via credit institution en Londres (Monex Europe)", "monexglobal.com"),
    ("US",      "US (ACH/Fedwire)",  "USD (US)",           "Indirecto", "Via corresponsal (Monex USA es MSB, no banco)", "monexusa.com"),
    ("INDEVAL", "Indeval",           "Valores (DVP)",      "Directo",   "Liquidacion de valores DVP; pata de efectivo por SPEI", "Casa de Bolsa"),
]

# --- Familias de producto (filas de la matriz ejecutiva) ---
# family_id, nombre, bloque
PRODUCT_FAMILIES = [
    ("F01", "Cuentas y depositos",       "no-mercados"),
    ("F02", "Cash management y pagos",   "no-mercados"),
    ("F03", "Credito y financiamiento",  "no-mercados"),
    ("F04", "Factoraje",                 "no-mercados"),
    ("F05", "Comercio exterior",         "no-mercados"),
    ("F06", "Fiduciario",                "no-mercados"),
    ("F07", "Inversion bancaria",        "no-mercados"),
    ("F08", "Casa de bolsa y valores",   "no-mercados"),
    ("F09", "Wealth y banca privada",    "no-mercados"),
    ("F10", "Fondos de inversion",       "no-mercados"),
    ("F11", "Spot y forwards FX",        "mercados"),
    ("F12", "NDF",                       "mercados"),
    ("F13", "Swaps",                     "mercados"),
    ("F14", "Opciones",                  "mercados"),
    ("F15", "Coberturas",                "mercados"),
    ("F16", "Tesoreria y multimoneda",   "mercados"),
    ("F17", "Notas estructuradas",       "mercados"),
]

# --- Correlacion familia -> rieles (matriz ejecutiva) ---
FAMILY_RAILS = {
    "F01": ["SPEI", "SPID", "SWIFT", "INT"],
    "F02": ["SPEI", "SPID", "SWIFT", "CODI", "DOM", "CIESAT"],
    "F03": ["SPEI", "DOM", "SWIFT"],
    "F04": ["SPEI", "SWIFT"],
    "F05": ["SWIFT"],
    "F06": ["SPEI", "SWIFT", "INDEVAL"],
    "F07": ["SPEI", "INT", "SWIFT"],
    "F08": ["SPEI", "INDEVAL", "SWIFT"],
    "F09": ["SPEI", "INDEVAL"],
    "F10": ["SPEI", "INT", "INDEVAL"],
    "F11": ["SWIFT", "CLS", "SPEI", "SEPA", "UK", "US"],
    "F12": ["SWIFT"],
    "F13": ["SWIFT", "CLS", "SPEI"],
    "F14": ["SWIFT", "CLS", "SPEI"],
    "F15": ["SWIFT", "CLS", "SPEI"],
    "F16": ["SWIFT", "SEPA", "UK", "US", "SPEI"],
    "F17": ["SPEI", "SWIFT"],
}

# --- Catalogo de productos (~64) ---
# id, nombre_es, nombre_en, holding, entidad, bloque, family_id, segmento, descripcion, liquidacion, evidencia
PRODUCTS = [
    # F01 Cuentas y depositos
    ("PRD-001", "Monex ONE", "Personal digital account", "GFM", "Banco Monex", "no-mercados", "F01", "Individual",
     "Cuenta personal 100% digital para personas que pagan o reciben del extranjero.", "SPEI (MXN); SPID/SWIFT cross-border", "I"),
    ("PRD-002", "Cuenta Multidivisa Monex ONE", "Multi-currency digital account", "GFM", "Banco Monex", "no-mercados", "F01", "Corporativo / PyME",
     "Saldos y FX en hasta 7 divisas, sin saldo minimo, 100% digital.", "Deposito por SPEI, SPID y SWIFT; pago 1x1 o masivo", "V"),
    ("PRD-003", "Cuenta de cheques", "Checking account", "GFM", "Banco Monex", "no-mercados", "F01", "Corporativo / individual",
     "Cuentas de cheques en pesos.", "SPEI; camara de compensacion", "I"),
    ("PRD-004", "CEDES", "Term deposit certificate", "GFM", "Banco Monex", "no-mercados", "F01", "Corporativo / individual",
     "Deposito a plazo con tasa fija, protegido por IPAB hasta 400k UDIs.", "Principal por traspaso interno/SPEI; interes por SPEI", "V"),
    # F02 Cash management y pagos
    ("PRD-005", "Pagos y Transferencias", "Payments and transfers", "GFM", "Banco Monex", "no-mercados", "F02", "Corporativo / PyME",
     "Pagos domesticos e internacionales, uno por uno o masivos, mancomunados.", "SPEI, SPID, SWIFT y pagos masivos", "V"),
    ("PRD-006", "Cobranza Referenciada", "Referenced collections", "GFM", "Banco Monex", "no-mercados", "F02", "Corporativo / PyME",
     "CLABEs unicas para autoconciliacion de cobros 24/7.", "SPEI, SPID y SWIFT entrante conciliado por referencia", "V"),
    ("PRD-007", "Nomina y Domiciliacion", "Payroll and direct debit", "GFM", "Banco Monex", "no-mercados", "F02", "Corporativo",
     "Dispersion de nomina y cobro recurrente por debito directo.", "Nomina por SPEI masivo; cobro por domiciliacion", "V"),
    # F03 Credito
    ("PRD-008", "Credito Simple", "Term loan", "GFM", "Banco Monex", "no-mercados", "F03", "Corporativo / PyME",
     "Credito estructurado de disposicion unica.", "Dispersion por SPEI; amortizacion SPEI/domiciliacion", "I"),
    ("PRD-009", "Credito Revolvente Empresarial", "Revolving line", "GFM", "Banco Monex", "no-mercados", "F03", "Corporativo / PyME",
     "Linea revolvente de capital de trabajo.", "Disposiciones y pagos por SPEI", "V"),
    ("PRD-010", "Credito Agropecuario", "Agricultural credit", "GFM", "Banco Monex", "no-mercados", "F03", "Agro corporativo / PyME",
     "Financiamiento sectorial agropecuario.", "Dispersion por SPEI", "I"),
    ("PRD-015", "Arrendamiento", "Leasing", "GFM", "Banco Monex", "no-mercados", "F03", "Corporativo / PyME",
     "Arrendamiento puro y modalidades flexibles.", "Fondeo por SPEI; rentas por domiciliacion/SPEI", "I"),
    ("PRD-016", "Credito de Comercio Exterior", "Foreign-trade finance", "GFM", "Banco Monex", "no-mercados", "F03", "Corporativo importador/exportador",
     "Financiamiento ligado a comercio exterior apalancando la franquicia FX.", "Disposiciones cross-border por SWIFT", "I"),
    ("PRD-017", "Credito Estructurado / fuente de pago", "Structured credit", "GFM", "Banco Monex", "no-mercados", "F03", "Gran corporativo",
     "Credito estructurado respaldado por fideicomiso fuente de pago.", "Flujos por SPEI; fuente segregada en fideicomiso", "I"),
    # F04 Factoraje
    ("PRD-011", "Factoraje con recurso", "Factoring with recourse", "GFM", "Banco Monex", "no-mercados", "F04", "Corporativo / PyME",
     "Liquidez inmediata contra cuentas por cobrar.", "Anticipo por SPEI", "V"),
    ("PRD-012", "Factoraje sin recurso", "Factoring without recourse", "GFM", "Banco Monex", "no-mercados", "F04", "Corporativo / PyME",
     "Factoraje con proteccion de credito.", "Anticipo por SPEI", "V"),
    ("PRD-013", "Factoraje a proveedores", "Reverse factoring", "GFM", "Banco Monex", "no-mercados", "F04", "Corporativo",
     "Pago anticipado a proveedores (reverse factoring).", "Pago a proveedores por SPEI", "V"),
    ("PRD-014", "Factoraje internacional", "International factoring", "GFM", "Banco Monex", "no-mercados", "F04", "Corporativo",
     "Factoraje de operaciones de comercio exterior.", "Liquidacion cross-border por SWIFT", "V"),
    # F05 Comercio exterior
    ("PRD-018", "Cartas de Credito Comerciales", "Commercial letters of credit", "GFM", "Banco Monex", "no-mercados", "F05", "Corporativo importador/exportador",
     "LC de importacion y exportacion bajo estandar UCP.", "Emision/aviso por SWIFT MT700 y liquidacion documentaria", "V"),
    ("PRD-019", "Cartas de Credito Stand-by y Garantias", "Standby LC and guarantees", "GFM", "Banco Monex", "no-mercados", "F05", "Corporativo",
     "Garantia bancaria para obligaciones contractuales y licitaciones (ISP98/URDG).", "SWIFT MT760; al ejercer, pago por SWIFT", "V"),
    ("PRD-020", "Cobranza Documentaria", "Documentary collection", "GFM", "Banco Monex", "no-mercados", "F05", "Corporativo importador/exportador",
     "Manejo bancario de documentos comerciales.", "SWIFT MT400 y liquidacion por corresponsal", "V"),
    # F06 Fiduciario
    ("PRD-021", "Fideicomiso de Administracion", "Administration trust", "GFM", "Fiduciario", "no-mercados", "F06", "Corporativo / FI",
     "Custodia y administracion de activos y derechos.", "Aportaciones y distribuciones por SPEI (MXN) / SWIFT (FX)", "V"),
    ("PRD-022", "Fideicomiso de Inversion", "Investment trust", "GFM", "Fiduciario", "no-mercados", "F06", "Corporativo / FI",
     "Activos invertidos en renta fija o variable.", "Efectivo por SPEI; valores por Indeval", "V"),
    ("PRD-023", "Fideicomiso de Garantia / Fuente de Pago", "Guarantee / source-of-payment trust", "GFM", "Fiduciario", "no-mercados", "F06", "Corporativo",
     "Segrega patrimonio para garantizar o pagar a acreedores.", "Servicio de deuda enrutado por SPEI", "V"),
    ("PRD-024", "Fideicomiso Financiero / Estructurado", "Financial / structured trust", "GFM", "Fiduciario", "no-mercados", "F06", "Gran corporativo",
     "Vehiculo para finanzas estructuradas.", "SPEI / SWIFT", "V"),
    ("PRD-025", "Fideicomiso Inmobiliario", "Real-estate trust", "GFM", "Fiduciario", "no-mercados", "F06", "Desarrolladores",
     "Desarrollo y tenencia inmobiliaria.", "Disposiciones por SPEI a desarrolladores", "V"),
    ("PRD-026", "Fideicomiso de Infraestructura", "Infrastructure trust", "GFM", "Fiduciario", "no-mercados", "F06", "Corporativo",
     "Fideicomisos de proyectos de infraestructura.", "SPEI", "V"),
    ("PRD-027", "Fideicomiso de Zona Restringida", "Restricted-zone trust", "GFM", "Fiduciario", "no-mercados", "F06", "Extranjeros",
     "Tenencia de propiedad para extranjeros en zona restringida.", "SPEI", "V"),
    # F07 Inversion bancaria
    ("PRD-028", "Notas Estructuradas (Banco)", "Structured notes (bank)", "GFM", "Banco Monex", "no-mercados", "F07", "Corporativo / HNW / individual",
     "Notas ligadas a capital con proteccion parcial o total. Embeben derivado.", "Suscripcion por traspaso interno/SPEI", "V"),
    ("PRD-029", "Plan de Pensiones", "Corporate pension plan", "GFM", "Banco Monex", "no-mercados", "F07", "Corporativo",
     "Plan de pensiones patrocinado por el empleador.", "Aportaciones por SPEI/nomina", "I"),
    ("PRD-030", "Esquemas de Ahorro", "Institutional savings", "GFM", "Banco Monex", "no-mercados", "F07", "Corporativo",
     "Ahorro institucional gestionado para empleados.", "Aportaciones por nomina/SPEI", "V"),
    # F08 Casa de bolsa y valores
    ("PRD-031", "Contrato de Intermediacion Bursatil", "Brokerage account", "GFM", "Casa de Bolsa", "no-mercados", "F08", "Individual / institucional",
     "Cuenta maestra para operar valores.", "Fondeo por SPEI; posiciones por Indeval", "V"),
    ("PRD-032", "Acciones nacionales", "Mexican equities", "GFM", "Casa de Bolsa", "no-mercados", "F08", "Individual / institucional",
     "Compraventa de acciones listadas en BMV.", "Indeval DVP; efectivo por SPEI", "I"),
    ("PRD-033", "Acciones internacionales (SIC)", "International equities", "GFM", "Casa de Bolsa", "no-mercados", "F08", "Individual / institucional",
     "Acciones de US/EU via SIC.", "Custodia y liquidacion cross-border; fondeo SPEI/SWIFT", "V"),
    ("PRD-034", "Renta Fija y Mercado de Dinero", "Fixed income and money market", "GFM", "Casa de Bolsa", "no-mercados", "F08", "Individual / institucional",
     "Cetes, Bonos M, Udibonos, deuda corporativa y gubernamental.", "Indeval DVP; efectivo por SPEI", "V"),
    ("PRD-035", "Reporto", "Repo", "GFM", "Casa de Bolsa", "no-mercados", "F08", "Institucional / corporativo",
     "Operaciones de reporto (principal fuente de fondeo de la casa de bolsa).", "Indeval; efectivo por SPEI", "V"),
    ("PRD-036", "ETFs", "ETFs", "GFM", "Casa de Bolsa", "no-mercados", "F08", "Individual / institucional",
     "ETFs de indice incluyendo via SIC.", "Indeval/SIC; efectivo por SPEI", "V"),
    ("PRD-037", "Custodia de Valores", "Securities custody", "GFM", "Casa de Bolsa", "no-mercados", "F08", "Institucional / corporativo / HNW",
     "Guarda y administracion de valores del cliente.", "Corporate actions y dividendos por SPEI", "V"),
    # F09 Wealth
    ("PRD-038", "Banca Privada / Gestion Patrimonial", "Private banking / wealth mgmt", "GFM", "Casa de Bolsa", "no-mercados", "F09", "HNW",
     "Proceso patrimonial end-to-end (diagnostico, estrategia, ejecucion, rebalanceo).", "Operaciones subyacentes por SPEI/Indeval", "V"),
    ("PRD-039", "Asesoria Privada", "Private advisory", "GFM", "Casa de Bolsa", "no-mercados", "F09", "HNW / persona moral",
     "Estrategia diversificada gestionada por expertos.", "SPEI/Indeval", "V"),
    ("PRD-040", "Asset Management", "Portfolio management", "GFM", "Casa de Bolsa", "no-mercados", "F09", "HNW / institucional",
     "Gestion discrecional de portafolios.", "SPEI/Indeval", "V"),
    ("PRD-041", "Plan Personal para el Retiro (PPR)", "Personal retirement plan", "GFM", "Casa de Bolsa", "no-mercados", "F09", "Individual",
     "Cuenta de retiro deducible bajo Art.151 LISR.", "Aportaciones por SPEI/domiciliacion", "V"),
    # F10 Fondos
    ("PRD-042", "Fondos de Deuda", "Debt funds", "GFM", "Operadora de Fondos", "no-mercados", "F10", "Retail a institucional",
     "~6 fondos de deuda gubernamental y corporativa.", "Suscripcion/reembolso por SPEI/traspaso interno", "V"),
    ("PRD-043", "Fondos de Renta Variable", "Equity funds", "GFM", "Operadora de Fondos", "no-mercados", "F10", "Retail a institucional",
     "~12 fondos de renta variable incluyendo ESG y ciclo de vida.", "SPEI/traspaso interno; valores por Indeval", "V"),
    # F11 Spot y forwards FX
    ("PRD-044", "Spot FX", "Spot FX", "GFM/MNI", "Banco Monex / Monex Global", "mercados", "F11", "Todos",
     "Compraventa de divisas a precio de mercado en 60-130 pares.", "Pago cross-border por SWIFT; PvP via CLS si el par es elegible; pata MXN por SPEI", "V"),
    ("PRD-045", "Ordenes de mercado", "Market orders (limit/stop/OCO)", "GFM/MNI", "Monex Global", "mercados", "F11", "Todos",
     "El desk ejecuta automatico a un tipo de cambio objetivo (limit, stop-loss, OCO).", "Al disparar ejecuta spot o forward y liquida como tal", "V"),
    ("PRD-046", "Forward outright", "Outright forward", "GFM/MNI", "Banco Monex / Monex Global", "mercados", "F11", "Corporativo / FI",
     "Fija hoy un tipo de cambio para una fecha futura unica; entregable.", "Al vencimiento, intercambio de dos patas por SWIFT (CLS PvP si elegible)", "V"),
    ("PRD-047", "Forward con ventana / flexible", "Window / flexible forward", "GFM/MNI", "Monex Global", "mercados", "F11", "Corporativo",
     "Tipo fijo con disposicion flexible dentro de una ventana.", "Cada disposicion liquida como spot (SWIFT/SPEI)", "V"),
    # F12 NDF
    ("PRD-048", "Non-Deliverable Forward (NDF)", "Non-deliverable forward", "GFM/MNI", "Monex Europe Markets", "mercados", "F12", "Corporativo / fondos / FI",
     "Forward liquidado en efectivo para divisas restringidas o emergentes.", "Sin intercambio de principal; un solo pago neto en USD por SWIFT; sin CLS", "V"),
    # F13 Swaps
    ("PRD-049", "FX swap", "FX swap", "GFM/MNI", "Banco Monex / Monex Global", "mercados", "F13", "Corporativo / FI",
     "Spot mas forward inverso para ajustar fechas de liquidacion o liquidez.", "Dos liquidaciones (near y far), cada una por SWIFT/SPEI (CLS PvP si elegible)", "V"),
    ("PRD-050", "Cross-currency swap", "Cross-currency swap", "GFM", "Banco Monex / Casa de Bolsa", "mercados", "F13", "Gran corporativo",
     "Intercambio de principal e intereses en dos divisas para cubrir deuda extranjera.", "Serie de liquidaciones SWIFT a lo largo de la vida", "V"),
    ("PRD-051", "Swap de tasa de interes", "Interest-rate swap", "GFM", "Banco Monex / Casa de Bolsa", "mercados", "F13", "Gran corporativo",
     "Intercambia tasa fija por flotante para cubrir costo financiero.", "Liquidacion neta de intereses en una divisa (SPEI para MXN o SWIFT); sin principal", "V"),
    # F14 Opciones
    ("PRD-052", "Opciones vanilla FX", "Vanilla FX options", "GFM/MNI", "Banco Monex / Monex Global", "mercados", "F14", "Corporativo / fondos / FI",
     "Derecho (no obligacion) de comprar o vender divisa a un strike; se paga prima.", "Prima por SWIFT/SPEI; si se ejerce dispara liquidacion spot (CLS PvP si elegible)", "V"),
    ("PRD-053", "Opciones exoticas / estructuradas", "Exotic / structured FX options", "GFM/MNI", "Monex Global", "mercados", "F14", "Corporativo / fondos / FI",
     "Estructuras multi-pata a la medida (participating forward, collar, risk-reversal, KI/KO, accumulator).", "Serie de fechas de liquidacion, cada una entrega (SWIFT) o liquida neto", "V"),
    ("PRD-054", "TARF", "Target accrual redemption forward", "GFM/MNI", "Monex Global", "mercados", "F14", "Corporativo / fondos",
     "Forward estructurado con tasas mejoradas hasta que un objetivo se acumula.", "Serie de liquidaciones entregables por SWIFT; knock-out al alcanzar objetivo", "V"),
    ("PRD-055", "Opciones de tasa (cap / floor)", "Interest-rate options", "GFM", "Casa de Bolsa", "mercados", "F14", "Gran corporativo",
     "Piso o techo de tasa para proteger rendimiento minimo o costo maximo.", "Prima por adelantado; pago neto en el dinero por SPEI/SWIFT", "V"),
    # F15 Coberturas
    ("PRD-056", "Cobertura de riesgo cambiario", "FX risk-hedging program", "GFM/MNI", "Banco Monex / Monex Global", "mercados", "F15", "Corporativo / mid-market",
     "Asesoria mas ejecucion que agrupa forwards y opciones para cubrir exposicion FX.", "Cada componente liquida segun forward u opcion", "V"),
    ("PRD-057", "Cobertura de riesgo de tasa", "IR risk-hedging program", "GFM", "Banco Monex / Casa de Bolsa", "mercados", "F15", "Gran corporativo",
     "Cobertura de exposicion a tasa via swaps, opciones y CCS.", "Liquidaciones netas periodicas segun instrumento", "V"),
    ("PRD-058", "Cobertura bespoke / dinamica", "Bespoke / dynamic hedging", "MNI", "Monex Europe Markets", "mercados", "F15", "Multinacionales / fondos / institucional",
     "Estrategias de cobertura a la medida y dinamicas segun politica de tesoreria.", "Liquida segun instrumentos; rebalanceo genera spot/forward incrementales", "V"),
    # F16 Tesoreria y multimoneda
    ("PRD-059", "Cuentas multimoneda / Virtual IBAN", "Multi-currency / virtual IBAN accounts", "GFM/MNI", "Monex Global / Banco Monex", "mercados", "F16", "Corporativo / PyME / FI",
     "Mantener y cobrar fondos en 30-130 divisas; herramienta de tesoreria y cobranza.", "Endpoint de liquidacion: recibe por SWIFT/rieles locales; fondea FX y pagos salientes", "V"),
    ("PRD-060", "Lineas de credito de margen", "Margin credit lines", "GFM/MNI", "Monex Global / Banco Monex", "mercados", "F16", "Corporativo / fondos / institucional",
     "Credito o margen para operar forwards y derivados sin colateral total por adelantado.", "Margin calls y colateral liquidados por SPEI/SWIFT", "V"),
    ("PRD-062", "Estrategias de sobrante de tesoreria", "Treasury surplus / yield strategies", "GFM/MNI", "Monex Global / Casa de Bolsa", "mercados", "F16", "Tesoreria corporativa",
     "Productos y estrategias para optimizar el retorno de saldos multimoneda ociosos.", "Segun el instrumento subyacente; fondea desde y a la cuenta multimoneda", "V"),
    # F17 Notas estructuradas (mercados)
    ("PRD-061", "Notas Estructuradas (Casa de Bolsa)", "Structured notes (brokerage)", "GFM", "Casa de Bolsa / Banca Privada", "mercados", "F17", "Corporativo / HNW / individual",
     "Notas de rendimiento ligadas a FX (USD/MXN, EUR/USD, EUR/MXN); Monex lider en LATAM.", "Suscripcion por traspaso interno/SPEI; al vencimiento principal mas retorno por SPEI/SWIFT", "V"),
    # Asesoria (bundled, sin liquidacion) — se listan pero no tienen riel
    ("PRD-063", "Analisis Economico, Cambiario y Bursatil", "Market research and intelligence", "GFM/MNI", "Grupo (equipo Janneth Quiroz)", "mercados", "F16", "Todos (bundled)",
     "Analisis diario de FX y mercados de un equipo ranqueado por Bloomberg.", "Sin liquidacion (servicio informativo)", "V"),
    ("PRD-064", "Administrador de cuenta dedicado", "Dedicated dealer and advisory", "GFM/MNI", "Monex Global", "mercados", "F16", "Corporativo / institucional",
     "Dealer nombrado que da guia de estrategia cambiaria.", "Sin liquidacion (servicio de relacion)", "V"),
]

# --- Fortalezas AS-IS ---
ASIS_STRENGTHS = [
    ("CLS conectado y a fondo", "Banco Monex es miembro de liquidacion CLS desde 2018, primer proveedor latinoamericano de acceso third-party (2020) y en vivo en CLSNet (2025). Es fortaleza, no gap."),
    ("Participacion directa en rieles core", "SPEI, SPID y SWIFT son participacion directa; BIC propio MONXMXMM y codigo de banco 112."),
    ("Franquicia FX lider", "~1.7M operaciones FX al ano y ~198,000 millones USD; negocio internacional del 23% del ingreso del banco."),
    ("Backbone de integracion definido", "MuleSoft Anypoint confirmado como backbone de integracion."),
    ("Portafolio amplio", "~64 productos comerciales en 17 familias, de cash management y comercio exterior a derivados estructurados."),
]

# --- Gaps AS-IS reales ---
ASIS_GAPS = [
    ("ISO 20022 readiness desconocido", "No hay evidencia publica del programa CBPR+ ni de la migracion MT a MX de Monex; sujeto a la migracion como tenedor de BIC y miembro CLS."),
    ("Sin Golden Record ni MDM", "No existe modelo de datos maestro canonico; gap critico confirmado, prerequisito de varias iniciativas Apolo."),
    ("STP desconocido", "El nivel real de straight-through processing del motor legacy no esta documentado."),
    ("Fragmentacion entre holdings y geografias", "El motor de pagos vive fragmentado entre Grupo Financiero Monex y MNI Holding y entre paises; el RFP busca un core comun con adaptadores locales."),
    ("24/7 no disenado", "Disponibilidad continua no es un atributo de diseno del legacy; SPEI ya exige 24/7."),
    ("Tecnologia tercerizada", "La infraestructura de Banco Monex esta tercerizada en Monterrey; el vendor de core o motor de pagos no es publico."),
]

# --- Taxonomia ETB Banking de procesos de pago (L1 Dominio, L2 Subdominio, L3 Capacidad, L4 Proceso) ---
# L1 constante: Dominio 3 - Product & Service. Fuente autoritativa: SME Industry Banking ETB V5.0.
# L4 Proceso derivado de las PAG macro-capabilities del RFP y la arquitectura de referencia de pagos.
# Filas: (subdominio_id, subdominio, l3_id, l3_capacidad, l4_proceso, mapeo_monex)
ETB_PAYMENTS_TAXONOMY = [
    # --- L2 3.4 Payments ---
    ("3.4", "Payments", "3.4.1", "Payments Pre-Processing Management", "Validacion estructural del mensaje", "PAG-3; R-F05"),
    ("3.4", "Payments", "3.4.1", "Payments Pre-Processing Management", "Validacion de cliente y cuenta", "PAG-3; R-F05"),
    ("3.4", "Payments", "3.4.1", "Payments Pre-Processing Management", "Validacion de beneficiario y banco", "PAG-3; R-F05"),
    ("3.4", "Payments", "3.4.1", "Payments Pre-Processing Management", "Verificacion de fondos y fecha valor", "PAG-3; R-F05"),
    ("3.4", "Payments", "3.4.1", "Payments Pre-Processing Management", "Enriquecimiento ISO 20022", "PAG-3; R-F05"),
    ("3.4", "Payments", "3.4.1", "Payments Pre-Processing Management", "Screening de sanciones y PLD/FT", "PAG-4; R-F06, R-R03"),
    ("3.4", "Payments", "3.4.1", "Payments Pre-Processing Management", "Deteccion de duplicados", "PAG-4; R-F08"),
    ("3.4", "Payments", "3.4.2", "Payment Acquisition Management", "Captura multi-canal (API, H2H, archivo, portal, Treasury, FX)", "PAG-2; R-F02"),
    ("3.4", "Payments", "3.4.2", "Payment Acquisition Management", "Normalizacion a modelo canonico comun", "PAG-2; P-05"),
    ("3.4", "Payments", "3.4.2", "Payment Acquisition Management", "Autorizacion maker-checker multi-nivel y SoD", "PAG-4; R-F04"),
    ("3.4", "Payments", "3.4.2", "Payment Acquisition Management", "Gestion de beneficiarios y programacion de pagos", "PAG-2; R-F02"),
    ("3.4", "Payments", "3.4.3", "Core Payment Processing", "Orquestacion del workflow de pago", "PAG-5; R-F07"),
    ("3.4", "Payments", "3.4.3", "Core Payment Processing", "Enrutamiento por costo, riesgo, liquidez y SLA", "PAG-5; R-F07"),
    ("3.4", "Payments", "3.4.3", "Core Payment Processing", "Procesamiento individual, por lote y en tiempo real", "PAG-2; R-F03"),
    ("3.4", "Payments", "3.4.3", "Core Payment Processing", "Idempotencia y fallback seguro de ruta", "PAG-5; R-F08"),
    ("3.4", "Payments", "3.4.4", "Payment Clearing & Settlement", "Generacion de mensajeria nativa del riel", "PAG-6; R-F09"),
    ("3.4", "Payments", "3.4.4", "Payment Clearing & Settlement", "Transmision y captura de ACK/NACK y estatus", "PAG-6; R-F09"),
    ("3.4", "Payments", "3.4.4", "Payment Clearing & Settlement", "Liquidacion PvP en CLS", "PAG-6; fortaleza MONEX"),
    ("3.4", "Payments", "3.4.4", "Payment Clearing & Settlement", "Gestion de liquidez intraday y cierre (cut-off)", "PAG-6; PAG-5"),
    ("3.4", "Payments", "3.4.5", "Payment Network Integration", "Adaptador SPEI/SPID (Banxico)", "PAG-7; riel MX"),
    ("3.4", "Payments", "3.4.5", "Payment Network Integration", "Conectividad SWIFT/CBPR+ con UETR", "PAG-7; R-F10"),
    ("3.4", "Payments", "3.4.5", "Payment Network Integration", "Adaptadores de rieles internacionales (SEPA, ACH, Fedwire, FPS)", "PAG-7; R-F10"),
    ("3.4", "Payments", "3.4.5", "Payment Network Integration", "Banca corresponsal, cargos OUR/SHA/BEN e integracion FX", "PAG-7; R-F11"),
    ("3.4", "Payments", "3.4.6", "Post Payment Processing", "Manejo de excepciones y reparacion", "PAG-8"),
    ("3.4", "Payments", "3.4.6", "Post Payment Processing", "Devoluciones, recalls y reversiones", "PAG-8"),
    ("3.4", "Payments", "3.4.6", "Post Payment Processing", "Ajustes y gestion de estatus desconocido", "PAG-8"),
    ("3.4", "Payments", "3.4.7", "Payment Support Services", "Consulta de estatus de pago", "PAG-10; AI-02"),
    ("3.4", "Payments", "3.4.7", "Payment Support Services", "Resolucion de disputas y atencion de consultas", "PAG-8"),
    ("3.4", "Payments", "3.4.7", "Payment Support Services", "Copiloto operativo asistido por IA", "AI-02"),
    ("3.4", "Payments", "3.4.8", "Payments Operations Management", "Monitoreo end-to-end en tiempo real", "PAG-10; R-N09"),
    ("3.4", "Payments", "3.4.8", "Payments Operations Management", "Conciliacion y contabilidad (nostro/vostro, GL)", "PAG-9"),
    ("3.4", "Payments", "3.4.8", "Payments Operations Management", "Reporting regulatorio (DIOR, CNBV/Banxico)", "PAG-10; R-R01"),
    ("3.4", "Payments", "3.4.8", "Payments Operations Management", "Auditoria y evidencia inmutable", "R-N12, R-R04"),
    # --- L2 3.6 Trade Finance Management ---
    ("3.6", "Trade Finance Management", "3.6.1", "Trade Finance Issuance", "Emision de carta de credito comercial (SWIFT MT700)", "producto MONEX"),
    ("3.6", "Trade Finance Management", "3.6.1", "Trade Finance Issuance", "Emision de stand-by y garantias (SWIFT MT760)", "producto MONEX"),
    ("3.6", "Trade Finance Management", "3.6.2", "Trade Finance Document Management", "Recepcion y validacion de documentos comerciales", "producto MONEX"),
    ("3.6", "Trade Finance Management", "3.6.2", "Trade Finance Document Management", "Cotejo documentario bajo estandar UCP", "producto MONEX"),
    ("3.6", "Trade Finance Management", "3.6.3", "Trade Finance Instrument Management", "Ciclo de vida del instrumento (emision a cierre)", "producto MONEX"),
    ("3.6", "Trade Finance Management", "3.6.3", "Trade Finance Instrument Management", "Enmiendas, prorrogas y liquidacion del instrumento", "producto MONEX"),
    ("3.6", "Trade Finance Management", "3.6.4", "Trade Verification Management", "Verificacion de contrapartes y detalles comerciales", "PAG-4"),
    ("3.6", "Trade Finance Management", "3.6.4", "Trade Verification Management", "Screening AML y sanciones del comercio", "PAG-4; R-R03"),
    ("3.6", "Trade Finance Management", "3.6.5", "Trade Finance Fees Management", "Calculo y aplicacion de comisiones y cargos", "producto MONEX"),
    ("3.6", "Trade Finance Management", "3.6.6", "Trade Finance Association Management", "Vinculacion con credito, cliente y otros objetos", "producto MONEX"),
]

# --- Preguntas abiertas para Rafa (Design Authority) ---
OPEN_QUESTIONS = [
    ("Alcance de dos holdings", "El RFP cubre Mexico, USA, UK y Espana, cruzando Grupo Financiero Monex y MNI Holding. Es un programa a nivel Monex Global sobre las dos estructuras legales, o hay ambiguedad de scope entre entidades con cores distintos?"),
    ("Estado real de ISO 20022", "Cual es el estado del programa CBPR+ y la migracion MT a MX de Monex hoy?"),
    ("Vendor confirmado", "Cual plataforma acompana a Accenture como SI en la propuesta conjunta?"),
    ("STP y volumen por producto", "Cual es el STP real del legacy y la mezcla de volumen por producto y por riel?"),
    ("Motor legacy exacto", "Que motor de pagos se reemplaza exactamente y en cual entidad legal reside?"),
]
