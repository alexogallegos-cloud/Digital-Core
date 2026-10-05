#!/usr/bin/env python3
"""
Liverpool Brain — Carga de Procesos Críticos al brain.
Fuente: source/Procesos Criticos/ (11 PDFs, 43 flujos de negocio)
Tablas: critical_processes, process_systems
"""
import sqlite3
import json
from pathlib import Path

BRAIN_PATH = Path(__file__).parent.parent / "liverpool-brain.db"

# ── Datos extraídos de los 11 PDFs (texto + análisis semántico de descripciones) ──
PROCESSES = [
    # ── Back Office ──────────────────────────────────────────────────────────────
    {
        "process_id": "PC-BO-01",
        "process_name": "Nómina",
        "business_group": "Recursos Humanos y Nómina",
        "category": "Back Office",
        "description": "Nóminas masivas (semanal y mensual) — 13 personas: 2 coordinadores, 8 especialistas",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "BOTH",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 5,
        "systems": [("SAP-HCM", "SAP"), ("Portal Mi Puerto", None)],
    },
    {
        "process_id": "PC-BO-02",
        "process_name": "Portal de autoservicio Mi Puerto",
        "business_group": "Recursos Humanos y Nómina",
        "category": "Back Office",
        "description": "Aportaciones quincenales LVP y SBB, préstamos y retiros, finiquitos y primas de antigüedad",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "BOTH",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 6,
        "systems": [("Portal Mi Puerto", None), ("SAP HCM", "SAP")],
    },
    {
        "process_id": "PC-BO-03",
        "process_name": "RRHH Talento (SuccessFactors)",
        "business_group": "Recursos Humanos y Nómina",
        "category": "Back Office",
        "description": "Ficha de talento y gestión de colaboradores",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "BOTH",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 7,
        "systems": [("SuccessFactors", None)],
    },
    {
        "process_id": "PC-BO-04",
        "process_name": "RRHH Aprendizaje (SuccessFactors LMS)",
        "business_group": "Recursos Humanos y Nómina",
        "category": "Back Office",
        "description": "Gestión de programas de aprendizaje",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "BOTH",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 8,
        "systems": [("SuccessFactors", None)],
    },
    {
        "process_id": "PC-BO-05",
        "process_name": "Desempeño y reclutamiento (SuccessFactors)",
        "business_group": "Recursos Humanos y Nómina",
        "category": "Back Office",
        "description": "Reclutamiento (Aira / LinkedIn) y ciclo de evaluación de desempeño",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "BOTH",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 9,
        "systems": [("SuccessFactors", None), ("Aira", None), ("LinkedIn", None)],
    },
    {
        "process_id": "PC-BO-06",
        "process_name": "Promociones (BW PMR)",
        "business_group": "Recursos Humanos y Nómina",
        "category": "Back Office",
        "description": "Promociones internas de personal",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "BOTH",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 10,
        "systems": [("SAP-BW", "SAP-BW")],
    },
    {
        "process_id": "PC-BO-07",
        "process_name": "Cuentas por pagar (SAP ECC FI)",
        "business_group": "Finanzas y Abastecimiento",
        "category": "Back Office",
        "description": "Generación de facturas electrónicas y proceso de pago",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 11,
        "systems": [("SAP ECC FI", "SAP"), ("Tumbleweed", "Tumbleweed")],
    },
    {
        "process_id": "PC-BO-08",
        "process_name": "Abastecimiento (FI CO - MM)",
        "business_group": "Finanzas y Abastecimiento",
        "category": "Back Office",
        "description": "Alta de materiales Liverpool (SAP ECC) y Suburbia (S/4 HANA), soporte funcional",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-01",
        "brand": "BOTH",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 12,
        "systems": [("SAP ECC MM", "SAP"), ("SAP S/4HANA", "SAP")],
    },
    {
        "process_id": "PC-BO-09",
        "process_name": "Mantenimiento (SAP PM)",
        "business_group": "Activos y Operaciones",
        "category": "Back Office",
        "description": "Gestión de órdenes de mantenimiento",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "BOTH",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 13,
        "systems": [("SAP PM", "SAP")],
    },
    {
        "process_id": "PC-BO-10",
        "process_name": "Gestión Inmobiliaria (SAP S/4 HANA Real Estate)",
        "business_group": "Activos y Operaciones",
        "category": "Back Office",
        "description": "Contratos de arrendamiento (Suburbia)",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "SBB",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 14,
        "systems": [("SAP S/4HANA RE", "SAP")],
    },
    {
        "process_id": "PC-BO-11",
        "process_name": "Estacionamiento",
        "business_group": "Activos y Operaciones",
        "category": "Back Office",
        "description": "Administración de 27 estacionamientos",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_BackOffice_Liverpool.pdf",
        "page_number": 15,
        "systems": [],
    },
    # ── Finanzas ─────────────────────────────────────────────────────────────────
    {
        "process_id": "PC-FIN-01",
        "process_name": "Otorgamiento de crédito (Liverpool)",
        "business_group": "Otorgamiento de Crédito",
        "category": "Finanzas",
        "description": "Procesos Mobile, APM, Manual y Solicitud en línea; validación y entrega de tarjeta; seguimiento de cuentas y créditos otorgados",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-06",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Finanzas_Liverpool.pdf",
        "page_number": 3,
        "systems": [
            ("VPL-Vision-Plus", "VPL-Vision-Plus"),
            ("FICO-TRIAD", "FICO-TRIAD"),
            ("Base24", "Base24"),
            ("Mainframe", "Mainframe"),
        ],
    },
    {
        "process_id": "PC-FIN-02",
        "process_name": "Otorgamiento de crédito y producto NF (Suburbia)",
        "business_group": "Otorgamiento de Crédito",
        "category": "Finanzas",
        "description": "Fábrica de crédito, Tablet, Captura de módulo y Poket; comunicación y promociones; planeación de campaña del tarjetahabiente",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-06",
        "brand": "SBB",
        "source_pdf": "Procesos_Criticos_Finanzas_Liverpool.pdf",
        "page_number": 4,
        "systems": [
            ("VPL-Vision-Plus", "VPL-Vision-Plus"),
            ("FICO-TRIAD", "FICO-TRIAD"),
            ("App Pocket", None),
        ],
    },
    {
        "process_id": "PC-FIN-03",
        "process_name": "Facturación",
        "business_group": "Facturación y Cobranza",
        "category": "Finanzas",
        "description": "Portal de facturación: emisión, complementos de pago, factura global, sustituciones y cancelaciones",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-06",
        "brand": "BOTH",
        "source_pdf": "Procesos_Criticos_Finanzas_Liverpool.pdf",
        "page_number": 5,
        "systems": [("SAP FI", "SAP"), ("Tumbleweed", "Tumbleweed")],
    },
    {
        "process_id": "PC-FIN-04",
        "process_name": "Cobranza",
        "business_group": "Facturación y Cobranza",
        "category": "Finanzas",
        "description": "Flujo de negocio con CyberFinancial: clasificación de cartera, cobranza administrativa y telefónica, moroso M1–M5 y M6–M9",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-06",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Finanzas_Liverpool.pdf",
        "page_number": 6,
        "systems": [
            ("Cyberfinancial", "Cyberfinancial"),
            ("VPL-Vision-Plus", "VPL-Vision-Plus"),
            ("Mainframe", "Mainframe"),
        ],
    },
    {
        "process_id": "PC-FIN-05",
        "process_name": "Gestor de aclaraciones",
        "business_group": "Atención y Aclaraciones",
        "category": "Finanzas",
        "description": "Centro de atención telefónica y tiendas (módulo de crédito): reclamación, dictamen y notificación al cliente",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-06",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Finanzas_Liverpool.pdf",
        "page_number": 7,
        "systems": [("Siebel-CRM", "Siebel-CRM"), ("VPL-Vision-Plus", "VPL-Vision-Plus")],
    },
    # ── Retail ───────────────────────────────────────────────────────────────────
    {
        "process_id": "PC-RET-01",
        "process_name": "Punto de venta (Point of Sale)",
        "business_group": "Piso de Venta",
        "category": "Retail",
        "description": "Venta en piso, devoluciones de compras de marketplace, pago de servicios y apartados",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-03",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Retail_Liverpool.pdf",
        "page_number": 3,
        "systems": [
            ("Base24", "Base24"),
            ("Bridgecore", "Bridgecore"),
            ("SAP ECC", "SAP"),
            ("Sterling-OMS", "Sterling-OMS"),
        ],
    },
    {
        "process_id": "PC-RET-02",
        "process_name": "Control de ingresos (Suburbia)",
        "business_group": "Control de Ingresos",
        "category": "Retail",
        "description": "Control de ingresos en SAP PDTA y auditoría de ventas: validaciones de cifras control y cierre de mes contable",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "SBB",
        "source_pdf": "Procesos_Criticos_Retail_Liverpool.pdf",
        "page_number": 4,
        "systems": [("SAP PDTA", "SAP"), ("SAP FI", "SAP")],
    },
    {
        "process_id": "PC-RET-03",
        "process_name": "Gestión de productos en Web/App (Suburbia)",
        "business_group": "Producto y Canales Digitales",
        "category": "Retail",
        "description": "Propuestas, modificaciones y alta de productos en la web: SAP ECC/S4H, Mirakl, Broker, Step, OMS, ATG y Akamai",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-01",
        "brand": "SBB",
        "source_pdf": "Procesos_Criticos_Retail_Liverpool.pdf",
        "page_number": 5,
        "systems": [
            ("SAP ECC", "SAP"),
            ("SAP S/4HANA", "SAP"),
            ("PIM-STEP", "PIM-STEP"),
            ("ATG-Endeca", "ATG-Endeca"),
            ("Sterling-OMS", "Sterling-OMS"),
            ("Mirakl", None),
            ("Akamai", None),
            ("Broker", None),
        ],
    },
    # ── Ola de Apps ──────────────────────────────────────────────────────────────
    {
        "process_id": "PC-OA-01",
        "process_name": "Control de inventarios",
        "business_group": "Inventarios y Recepción",
        "category": "Ola de Apps",
        "description": "SAP ECC y VCM — programación de conteo, marbetes, captura, validación de diferencias y cierre (20 actividades mapeadas)",
        "activities_count": 20,
        "incidents_count": None,
        "vc_id": "VC-02",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Ola_de_Apps_Liverpool.pdf",
        "page_number": 3,
        "systems": [("SAP ECC", "SAP"), ("VCM", None)],
    },
    {
        "process_id": "PC-OA-02",
        "process_name": "Recepción en tienda",
        "business_group": "Inventarios y Recepción",
        "category": "Ola de Apps",
        "description": "Descarga de manifiesto de SAP, escaneo de tarima y contenedores en VCM, y ubicación en sección (17 actividades mapeadas)",
        "activities_count": 17,
        "incidents_count": None,
        "vc_id": "VC-02",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Ola_de_Apps_Liverpool.pdf",
        "page_number": 4,
        "systems": [("SAP ECC", "SAP"), ("SAP EWM", "SAP"), ("VCM", None)],
    },
    {
        "process_id": "PC-OA-03",
        "process_name": "Consulta de inventarios en bodega de zapatería",
        "business_group": "Inventarios y Recepción",
        "category": "Ola de Apps",
        "description": "SIBO y VCM — carga de existencias, escaneo de SKU, apartado y venta en piso (15 actividades, 3 incidentes)",
        "activities_count": 15,
        "incidents_count": 3,
        "vc_id": "VC-02",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Ola_de_Apps_Liverpool.pdf",
        "page_number": 5,
        "systems": [("SIBO", None), ("VCM", None)],
    },
    {
        "process_id": "PC-OA-04",
        "process_name": "Calificación de mercancías",
        "business_group": "Mercancía y Precios",
        "category": "Ola de Apps",
        "description": "Extracción de calificaciones de barata desde ECC, procesamiento en módulo y calificación en piso (3 actividades mapeadas)",
        "activities_count": 3,
        "incidents_count": None,
        "vc_id": "VC-01",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Ola_de_Apps_Liverpool.pdf",
        "page_number": 6,
        "systems": [("SAP ECC", "SAP"), ("VCM", None)],
    },
    {
        "process_id": "PC-OA-05",
        "process_name": "Cambios de precios",
        "business_group": "Mercancía y Precios",
        "category": "Ola de Apps",
        "description": "Extracción y carga del archivo de cambios, escaneo de SKU, captura en VCM e impresión de etiquetas (6 actividades mapeadas)",
        "activities_count": 6,
        "incidents_count": None,
        "vc_id": "VC-01",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Ola_de_Apps_Liverpool.pdf",
        "page_number": 7,
        "systems": [("SAP ECC", "SAP"), ("VCM", None)],
    },
    {
        "process_id": "PC-OA-06",
        "process_name": "Pantalla única",
        "business_group": "Atención y Servicios al Cliente",
        "category": "Ola de Apps",
        "description": "Atención de primer contacto, validación del cliente y módulo de crédito y tarjetas (26 actividades, 7 incidentes)",
        "activities_count": 26,
        "incidents_count": 7,
        "vc_id": "VC-04",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Ola_de_Apps_Liverpool.pdf",
        "page_number": 8,
        "systems": [
            ("VPL-Vision-Plus", "VPL-Vision-Plus"),
            ("Siebel-CRM", "Siebel-CRM"),
            ("Mainframe", "Mainframe"),
        ],
    },
    {
        "process_id": "PC-OA-07",
        "process_name": "Reparación de relojería, joyería y accesorios finos",
        "business_group": "Atención y Servicios al Cliente",
        "category": "Ola de Apps",
        "description": "Creación de órdenes en VAS: guía de paquetería, proveedor, recepción y cobro (17 actividades, 7 incidentes)",
        "activities_count": 17,
        "incidents_count": 7,
        "vc_id": "VC-04",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Ola_de_Apps_Liverpool.pdf",
        "page_number": 9,
        "systems": [("VAS", None), ("SAP ECC", "SAP")],
    },
    # ── Supply Chain ─────────────────────────────────────────────────────────────
    {
        "process_id": "PC-SC-01",
        "process_name": "Plan Liverpool — Recepción, almacenaje y surtido",
        "business_group": "Almacén y Distribución",
        "category": "Supply Chain",
        "description": "Importación, nacional y marketplace: proceso de recibo, descarga, inspección de calidad, almacenaje y surtido",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-02",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_SupplyChain_Liverpool.pdf",
        "page_number": 3,
        "systems": [("SAP EWM", "SAP"), ("IBM-IIB", "IBM-IIB"), ("Sterling-OMS", "Sterling-OMS")],
    },
    {
        "process_id": "PC-SC-02",
        "process_name": "Proceso logístico TMS",
        "business_group": "Almacén y Distribución",
        "category": "Supply Chain",
        "description": "Optimización y planeación de loads, generación de TUs en SAP EWM, tender a transportistas y recepción en destino",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-02",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_SupplyChain_Liverpool.pdf",
        "page_number": 4,
        "systems": [("SAP EWM", "SAP"), ("SAP TM", "SAP")],
    },
    {
        "process_id": "PC-SC-03",
        "process_name": "Transferencias entre tienda",
        "business_group": "Almacén y Distribución",
        "category": "Supply Chain",
        "description": "Solicitud y autorización de transferencia, armado de contenedor, manifiesto, hoja de ruta y recepción en tienda",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-02",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_SupplyChain_Liverpool.pdf",
        "page_number": 5,
        "systems": [("SAP EWM", "SAP"), ("VCM", None)],
    },
    {
        "process_id": "PC-SC-04",
        "process_name": "Óptica",
        "business_group": "Servicios en Tienda",
        "category": "Supply Chain",
        "description": "Solicitud de óptica: cotización, generación de órdenes, cobro en POS, envío a laboratorio y entrega al cliente",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-04",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_SupplyChain_Liverpool.pdf",
        "page_number": 6,
        "systems": [("SAP ECC", "SAP"), ("Base24", "Base24"), ("Bridgecore", "Bridgecore")],
    },
    {
        "process_id": "PC-SC-05",
        "process_name": "Sastrería",
        "business_group": "Servicios en Tienda",
        "category": "Supply Chain",
        "description": "Solicitud de compostura: alta en módulo de sastrería, folio, asignación a operario y entrega al cliente",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-04",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_SupplyChain_Liverpool.pdf",
        "page_number": 7,
        "systems": [("VCM", None)],
    },
    {
        "process_id": "PC-SC-06",
        "process_name": "Obtención de indicadores y medición de impactos",
        "business_group": "Indicadores",
        "category": "Supply Chain",
        "description": "Análisis causa raíz del incidente, identificación de KPIs, comparación contra baseline y cuantificación de impactos",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-09",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_SupplyChain_Liverpool.pdf",
        "page_number": 8,
        "systems": [("SAP-BW", "SAP-BW"), ("SAP ECC", "SAP")],
    },
    # ── Tiendas Omnicanal ────────────────────────────────────────────────────────
    {
        "process_id": "PC-OC-01",
        "process_name": "Flujo de negocio omnicanal (Liverpool)",
        "business_group": "Flujo Omnicanal",
        "category": "Tiendas Omnicanal",
        "description": "Venta, remisión, surtido en tienda o BOCE, empaque, envío, Click & Collect y entrega al cliente",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-03",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Tiendas_Omnicanal_Liverpool.pdf",
        "page_number": 3,
        "systems": [
            ("Sterling-OMS", "Sterling-OMS"),
            ("ATG-Endeca", "ATG-Endeca"),
            ("Digital-Platform", "Digital-Platform"),
            ("SAP ECC", "SAP"),
        ],
    },
    {
        "process_id": "PC-OC-02",
        "process_name": "Suburbia omnicanal",
        "business_group": "Flujo Omnicanal",
        "category": "Tiendas Omnicanal",
        "description": "Compra, surtido, recibo de material, empaque y almacenaje, y entrega del pedido",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-03",
        "brand": "SBB",
        "source_pdf": "Procesos_Criticos_Tiendas_Omnicanal_Liverpool.pdf",
        "page_number": 4,
        "systems": [
            ("Sterling-OMS", "Sterling-OMS"),
            ("SAP EWM", "SAP"),
            ("Digital-Platform", "Digital-Platform"),
        ],
    },
    {
        "process_id": "PC-OC-03",
        "process_name": "Tiendas omnicanal — Tultitlán",
        "business_group": "Tiendas",
        "category": "Tiendas Omnicanal",
        "description": "Flujo de negocio de tienda: recepción, surtido, empaque, envíos y devoluciones",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-03",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Tiendas_Omnicanal_Liverpool.pdf",
        "page_number": 5,
        "systems": [("Sterling-OMS", "Sterling-OMS"), ("VCM", None), ("SAP EWM", "SAP")],
    },
    {
        "process_id": "PC-OC-04",
        "process_name": "Fulfillment BOCE",
        "business_group": "Centros de Distribución y Fulfillment",
        "category": "Tiendas Omnicanal",
        "description": "Centro de distribución centralizado: liberación de orden, picking, empacado, embarque y entrega a tienda o domicilio",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-02",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Tiendas_Omnicanal_Liverpool.pdf",
        "page_number": 6,
        "systems": [("Sterling-OMS", "Sterling-OMS"), ("SAP EWM", "SAP"), ("Digital-Platform", "Digital-Platform")],
    },
    {
        "process_id": "PC-OC-05",
        "process_name": "Resurtido BOCE",
        "business_group": "Centros de Distribución y Fulfillment",
        "category": "Tiendas Omnicanal",
        "description": "Llegada a BOCE: descarga, escaneo, ubicación, verificación de inventario, picking y embarque a tienda",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-02",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Tiendas_Omnicanal_Liverpool.pdf",
        "page_number": 7,
        "systems": [("SAP EWM", "SAP"), ("VCM", None)],
    },
    {
        "process_id": "PC-OC-06",
        "process_name": "Fulfillment CR (Big ticket y soft line)",
        "business_group": "Centros de Distribución y Fulfillment",
        "category": "Tiendas Omnicanal",
        "description": "Big ticket y soft line: inventario, ruteo, TU de salida, manifiesto, entrega a domicilio y acuse de recibo",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-02",
        "brand": "LIV",
        "source_pdf": "Procesos_Criticos_Tiendas_Omnicanal_Liverpool.pdf",
        "page_number": 8,
        "systems": [("SAP EWM", "SAP"), ("Sterling-OMS", "Sterling-OMS"), ("IBM-IIB", "IBM-IIB")],
    },
    # ── Procesos individuales (PDFs de 1 página) ─────────────────────────────────
    {
        "process_id": "PC-IND-01",
        "process_name": "Hub de pagos (24 billers)",
        "business_group": "Pagos de Servicios",
        "category": "Individual",
        "description": "Orquestación de solicitudes de pago de servicios: flujo en aplicativo móvil y flujo en aplicativo WEB (24 billers activos)",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-06",
        "brand": "LIV",
        "source_pdf": "Hub_de_Pagos_Liverpool.pdf",
        "page_number": 1,
        "systems": [("Digital-Platform", "Digital-Platform"), ("Base24", "Base24"), ("IBM-IIB", "IBM-IIB")],
    },
    {
        "process_id": "PC-IND-02",
        "process_name": "Flujo end to end Exstream (estados de cuenta)",
        "business_group": "Servicios Financieros",
        "category": "Individual",
        "description": "Generación de estados de cuenta (EDC): actualización de banners, diseño, muestras, aprobación y paquete productivo",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-06",
        "brand": "LIV",
        "source_pdf": "Flujo_End_to_End_Exstream_Liverpool.pdf",
        "page_number": 1,
        "systems": [("Exstream", None), ("Mainframe", "Mainframe"), ("VPL-Vision-Plus", "VPL-Vision-Plus")],
    },
    {
        "process_id": "PC-IND-03",
        "process_name": "Préstamos personales (LiverCash / FacilCash)",
        "business_group": "Servicios Financieros",
        "category": "Individual",
        "description": "Solicitud de préstamos personales (App Pocket y PC-Web) y disposición de efectivo en canales digitales vía CLABE SPEI",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-06",
        "brand": "LIV",
        "source_pdf": "Prestamos_Personales_Liverpool.pdf",
        "page_number": 1,
        "systems": [
            ("App Pocket", None),
            ("VPL-Vision-Plus", "VPL-Vision-Plus"),
            ("Mainframe", "Mainframe"),
            ("SPEI", None),
        ],
    },
    {
        "process_id": "PC-IND-04",
        "process_name": "SuccessFactors — Sucesión y Desarrollo 360",
        "business_group": "Recursos Humanos",
        "category": "Individual",
        "description": "Promociones internas, mesa de desarrollo, sucesión y planes de desarrollo interno, y evaluación de desarrollo 360",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-07",
        "brand": "BOTH",
        "source_pdf": "SuccessFactors_Liverpool.pdf",
        "page_number": 1,
        "systems": [("SuccessFactors", None)],
    },
    {
        "process_id": "PC-IND-05",
        "process_name": "Indicadores — Matriz por eslabón",
        "business_group": "Analítica e Indicadores",
        "category": "Individual",
        "description": "Matriz de indicadores por eslabón de la cadena: compra y recepción, distribución, ventas, surtido, entrega y post venta",
        "activities_count": None,
        "incidents_count": None,
        "vc_id": "VC-09",
        "brand": "LIV",
        "source_pdf": "Indicadores_Liverpool.pdf",
        "page_number": 1,
        "systems": [("SAP-BW", "SAP-BW"), ("CDP-GCP", "CDP-GCP")],
    },
]

# ── Sistemas nuevos descubiertos (no están en components) ─────────────────────
NEW_SYSTEMS = [
    {
        "id": "LIV-VCM",
        "name": "VCM — Visibilidad y Control de Mercancías",
        "source_system": "unknown",
        "component_type": "application",
        "domain_id": "R02",
        "description": "App de gestión de piso de tienda: inventarios, recepción, calificación de mercancías, cambios de precios. Usada en 6+ procesos críticos.",
        "togaf_type": "channels",
        "status": "active",
        "seeded_by": "Procesos Críticos (Regla B8)",
    },
    {
        "id": "LIV-SIBO",
        "name": "SIBO — Inventarios Bodega Zapatería",
        "source_system": "unknown",
        "component_type": "application",
        "domain_id": "R02",
        "description": "Sistema de inventarios para bodega de zapatería: carga de existencias, escaneo SKU, apartado y venta en piso.",
        "togaf_type": "channels",
        "status": "active",
        "seeded_by": "Procesos Críticos (Regla B8)",
    },
    {
        "id": "LIV-EXSTREAM",
        "name": "OpenText Exstream — Generación de Estados de Cuenta",
        "source_system": "OpenText",
        "component_type": "application",
        "domain_id": "R03",
        "description": "Generación de estados de cuenta (EDC) para LiverpoolCard: actualización de banners, diseño, muestras, aprobación y paquete productivo.",
        "togaf_type": "processors",
        "status": "active",
        "seeded_by": "Procesos Críticos (Regla B8)",
    },
    {
        "id": "LIV-VAS",
        "name": "VAS — Value Added Services (Relojería y Joyería)",
        "source_system": "unknown",
        "component_type": "application",
        "domain_id": "R05",
        "description": "Sistema de órdenes de servicio de valor agregado: relojería, joyería y accesorios finos. Gestiona guías de paquetería, proveedores y cobro.",
        "togaf_type": "channels",
        "status": "active",
        "seeded_by": "Procesos Críticos (Regla B8)",
    },
    {
        "id": "LIV-APP-POCKET",
        "name": "App Pocket — Préstamos Personales",
        "source_system": "internal",
        "component_type": "application",
        "domain_id": "R03",
        "description": "App móvil para solicitudes de préstamos personales (LiverCash / FacilCash) y disposición de efectivo via CLABE SPEI.",
        "togaf_type": "channels",
        "status": "active",
        "seeded_by": "Procesos Críticos (Regla B8)",
    },
]


def ensure_tables(conn):
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS critical_processes (
            process_id      TEXT PRIMARY KEY,
            process_name    TEXT NOT NULL,
            business_group  TEXT,
            category        TEXT,
            description     TEXT,
            activities_count INTEGER,
            incidents_count  INTEGER,
            vc_id           TEXT,
            brand           TEXT DEFAULT 'LIV',
            source_pdf      TEXT,
            page_number     INTEGER,
            loaded_at       TEXT DEFAULT (date('now'))
        );

        CREATE TABLE IF NOT EXISTS process_systems (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            process_id      TEXT NOT NULL,
            system_name     TEXT NOT NULL,
            component_id    TEXT,
            is_cataloged    INTEGER DEFAULT 0,
            FOREIGN KEY (process_id) REFERENCES critical_processes(process_id)
        );
    """)
    conn.commit()


def load_data(conn):
    # ── Limpiar y recargar ─────────────────────────────────────────────────────
    conn.execute("DELETE FROM process_systems")
    conn.execute("DELETE FROM critical_processes")

    for p in PROCESSES:
        conn.execute("""
            INSERT INTO critical_processes
            (process_id, process_name, business_group, category, description,
             activities_count, incidents_count, vc_id, brand, source_pdf, page_number)
            VALUES (?,?,?,?,?,?,?,?,?,?,?)
        """, (
            p["process_id"], p["process_name"], p["business_group"], p["category"],
            p["description"], p["activities_count"], p["incidents_count"],
            p["vc_id"], p["brand"], p["source_pdf"], p["page_number"],
        ))

        for sys_name, comp_id in p["systems"]:
            # Verificar si el componente está en el catálogo
            is_cataloged = 0
            if comp_id:
                row = conn.execute(
                    "SELECT id FROM components WHERE id = ? OR name LIKE ?",
                    (comp_id, f"%{comp_id}%")
                ).fetchone()
                if row:
                    is_cataloged = 1
                    comp_id = row[0]
                else:
                    comp_id = None
            conn.execute("""
                INSERT INTO process_systems (process_id, system_name, component_id, is_cataloged)
                VALUES (?,?,?,?)
            """, (p["process_id"], sys_name, comp_id, is_cataloged))

    conn.commit()

    # ── Registrar sistemas nuevos descubiertos (Regla B8) ──────────────────────
    for ns in NEW_SYSTEMS:
        existing = conn.execute("SELECT id FROM components WHERE id = ?", (ns["id"],)).fetchone()
        if not existing:
            conn.execute("""
                INSERT INTO components
                (id, name, source_system, component_type, domain_id, description, togaf_type, status, seeded_by)
                VALUES (?,?,?,?,?,?,?,?,?)
            """, (
                ns["id"], ns["name"], ns["source_system"], ns["component_type"],
                ns["domain_id"], ns["description"], ns["togaf_type"], ns["status"],
                ns["seeded_by"],
            ))
        else:
            print(f"  ya existe: {ns['id']} — sin cambios")

    conn.commit()


def print_summary(conn):
    total = conn.execute("SELECT COUNT(*) FROM critical_processes").fetchone()[0]
    by_vc = conn.execute("""
        SELECT vc_id, COUNT(*) as n FROM critical_processes GROUP BY vc_id ORDER BY n DESC
    """).fetchall()
    by_cat = conn.execute("""
        SELECT category, COUNT(*) as n FROM critical_processes GROUP BY category ORDER BY n DESC
    """).fetchall()
    new_sys = conn.execute(
        "SELECT COUNT(*) FROM components WHERE seeded_by LIKE '%Procesos Críticos%'"
    ).fetchone()[0]
    total_ps = conn.execute("SELECT COUNT(*) FROM process_systems").fetchone()[0]

    print(f"critical_processes cargados : {total}")
    print(f"relaciones process_systems  : {total_ps}")
    print(f"sistemas nuevos (Regla B8)  : {new_sys}")
    print()
    print("Distribución por VC:")
    for vc, n in by_vc:
        print(f"  {vc}: {n}")
    print()
    print("Distribución por categoría:")
    for cat, n in by_cat:
        print(f"  {cat}: {n}")


def main():
    conn = sqlite3.connect(BRAIN_PATH)
    conn.row_factory = sqlite3.Row
    ensure_tables(conn)
    load_data(conn)
    print_summary(conn)
    conn.close()


if __name__ == "__main__":
    main()
