# -*- coding: utf-8 -*-
"""
build-landscape-v2.py
Registro canónico del landscape AXA México v2.0.

Sincroniza el brain con el landscape real descubierto en las tres fuentes
autoritativas del proyecto. Sustituye el registro v1.0 de 16 sistemas scaffold.

Fuentes y código de procedencia:
  TOGAF-pN   -> source/arquitectura_TOGAF_accenture_v19.pdf, página N
  DISCOVERY  -> source/2608_Suscripción_..._Competitive Discovery Suscripción Daños.xlsx
  CLAUDE-2.0 -> tabla de landscape en AXA/CLAUDE.md v2.0

Uso:
    python generators/build-landscape-v2.py            # escribe JSON y carga el brain
    python generators/build-landscape-v2.py --dry-run  # solo valida, no escribe
"""

import json
import os
import sqlite3
import sys
from collections import Counter
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "axa-brain.db")
JSON_DIR = os.path.join(BASE_DIR, "knowledge-base", "landscape")
JSON_PATH = os.path.join(JSON_DIR, "landscape-axa-v2.json")

LANDSCAPE_VERSION = "2.0"

# ──────────────────────────────────────────────────────────────────────
# SISTEMAS
# (slug, display_name, real_name, category, lob, status, source, note)
#
# status:
#   CONFIRMED       Nombre real y rol verificados en fuente
#   PARTIAL         Existe y está nombrado, rol o alcance por confirmar
#   SCAFFOLD        Se presume por estructura, sin evidencia de nombre real
#   SHADOW-IT       Hoja de cálculo o herramienta ofimática que opera como sistema
#   IN-MIGRATION    En transición hacia un destino definido
#   DEPRECATED      En decommission o sustituido
#   DIVESTED        Fuera del perímetro por desinversión
#   PILOT           Piloto activo, no productivo
# ──────────────────────────────────────────────────────────────────────
SYSTEMS = [
    # ── core: administración de pólizas y siniestros por línea ────────
    ("policy-admin-danos", "Policy Admin Daños", "General Daños y SED", "core", "Daños", "CONFIRMED", "TOGAF-p5,p7;DISCOVERY",
     "Sistema de emisión de pólizas de Daños. Captura condiciones aprobadas, genera la póliza y gestiona endosos"),
    ("policy-admin-autos", "Policy Admin Autos", "Oracle DB Autos", "core", "Autos", "CONFIRMED", "TOGAF-p5,p7,p11",
     "Gestión de pólizas, productos y tarifas de Autos sobre Oracle DB. Patrón dual con Guidewire, que solo cubre siniestros"),
    ("policy-admin-salud", "Policy Admin Salud", "Visual Time, GMM 2000, GMCol, GMI e ISES", "core", "Salud", "CONFIRMED", "TOGAF-p5,p7,p11",
     "Visual Time es el core SaaS de Salud, acompañado de los cores GMM 2000, GMCol, GMI e ISES"),
    ("policy-admin-vida", "Policy Admin Vida", "Progress/COBOL", "core", "Vida", "CONFIRMED", "TOGAF-p5,p7",
     "Core de Vida AS IS, monolítico legacy. Pólizas, productos, tarifas, tomadores e historial. Aislado del golden record"),
    ("claims-autos", "Claims Autos", "Guidewire Claims", "core", "Autos", "CONFIRMED", "TOGAF-p5,p7,p10,p11",
     "Core SaaS de siniestros de Autos. Integración directa con Audatex, Shift Technology y FIS Payments"),
    ("claims-danos", "Claims Daños", "SED y General Daños sobre Oracle DB Daños", "core", "Daños", "PARTIAL", "TOGAF-p5,p7",
     "Siniestros, liquidación y peritación de Daños se capturan en SED y General Daños. No hay core de siniestros dedicado"),
    ("claims-salud", "Claims Salud", "SaludWeb, SIGAME, DictaMedic, Qantev y RedPres", "core", "Salud", "CONFIRMED", "TOGAF-p5,p7",
     "Autorización, reembolso, prestaciones, dictamen médico y red de prestadores"),

    # ── processors: motores técnicos de suscripción y riesgo ──────────
    ("underwriting-engine", "Underwriting Engine", "Vector", "processors", "Daños", "CONFIRMED", "TOGAF-p5;DISCOVERY",
     "Workflow core de suscripción de Daños. Gestión de folios y casos desde recepción hasta decisión técnica"),
    ("reinsurance", "Reaseguro Facultativo", "SAFAC", "processors", "Daños", "CONFIRMED", "TOGAF-p5;DISCOVERY",
     "Registro de colocaciones, capas y reaseguradores. Solo estructura lineal, sin carga masiva de capas"),
    ("reinsurance-group", "Reaseguro Grupo", "ID Clear", "processors", "Daños", "CONFIRMED", "DISCOVERY",
     "Registro manual de la cesión facultativa para control del Grupo AXA, desglosada por capa y reasegurador"),
    ("reinsurance-accounting", "Contabilidad de Reaseguro", "CIRCAM", "processors", "Daños", "PARTIAL", "DISCOVERY",
     "Sistema contable downstream del reaseguro. Mencionado una vez en el Discovery, alcance por confirmar"),
    ("actuarial-cat", "Modelación Catastrófica", "ERN", "processors", "Daños", "CONFIRMED", "TOGAF-p5;DISCOVERY",
     "Modelación catastrófica. PML, cúmulos y exposición sísmica e hidrometeorológica"),
    ("actuarial-catnet", "Mapeo Nat-Cat", "Catnet", "processors", "Daños", "PARTIAL", "DISCOVERY",
     "Mapeo de peligros naturales por ubicación, usado junto con PUMA en modelación especializada"),
    ("pricing-puma", "Cuota Técnica", "PUMA", "processors", "Daños", "CONFIRMED", "DISCOVERY",
     "Captura del detalle de proyecto y coberturas para obtener una cuota técnica de riesgo en negocios complejos"),
    ("cotizador-suscripcion", "Cotizador de Suscripción", "Cotizador de Suscripción", "processors", "Daños", "PARTIAL", "DISCOVERY",
     "Cotizador usado en la evaluación técnica. Relación con Vector y SED por confirmar"),
    ("fraud-detection", "Detección de Fraude", "Shift Technology", "processors", "Autos", "CONFIRMED", "TOGAF-p6,p10",
     "Detección de fraude con machine learning, ejecutada en paralelo al flujo de siniestros de Autos"),
    ("peritacion", "Peritación", "Audatex", "processors", "Autos", "CONFIRMED", "TOGAF-p10,p11",
     "Peritación y valoración de daños de Autos. Integración directa con Guidewire, con waiver del Architecture Board"),
    ("capa-agentica", "Capa Agéntica", "Orquestador, cuatro agentes especializados y agente generativo", "processors", "Transversal", "PILOT", "TOGAF-p3,p5,p6,p9",
     "Orquestador que coordina validación de acceso, verificación de condiciones, cálculo financiero y validación clínica, más un LLM generativo"),

    # ── processors: shadow IT que opera como sistema ──────────────────
    ("hsd-excel", "Hoja de Suscripción de Daños", "HSD (Excel)", "processors", "Daños", "SHADOW-IT", "DISCOVERY",
     "Cálculo técnico de suscripción en Excel. Sin integración con Vector, ERN ni SAFAC. Gap crítico de automatización"),
    ("pyl-rentabilidad", "Análisis de Rentabilidad", "P&L (Excel)", "processors", "Daños", "SHADOW-IT", "DISCOVERY",
     "Análisis técnico y financiero del riesgo en Excel para negocio comercial o complejo"),
    ("tarifa-rc", "Tarifa de Responsabilidad Civil", "Tarifa RC (Excel)", "processors", "Daños", "SHADOW-IT", "DISCOVERY",
     "Tarificación de Responsabilidad Civil en Excel"),
    ("security-list", "Security List", "Security List (Excel)", "processors", "Daños", "SHADOW-IT", "DISCOVERY",
     "Listado de reaseguradores admitidos y su calificación, mantenido en Excel"),

    # ── channels: canales de distribución y engagement ────────────────
    ("axa-mx", "axa.mx", "axa.mx", "channels", "Transversal", "CONFIRMED", "TOGAF-p2,p3,p5,p6",
     "Portal público. Cotizador, siniestros, buscador de red de prestadores y acceso a My AXA"),
    ("my-axa-web", "My AXA web", "myaxa.com.mx", "channels", "Transversal", "CONFIRMED", "TOGAF-p2,p3,p6",
     "Self-service de tomadores. Consulta y descarga de pólizas, pago online y pólizas colectivas"),
    ("my-axa-app", "My AXA app", "My AXA (iOS y Android)", "channels", "Transversal", "CONFIRMED", "TOGAF-p2,p3,p6,p10",
     "App móvil. Reembolsos, rastreo de ajustador, tarjeta digital, Tu Médico 24h y chat"),
    ("my-axa-webview", "My AXA Webview", "My AXA Webview", "channels", "Transversal", "PARTIAL", "TOGAF-p3",
     "Versión web embebida de la app My AXA"),
    ("axa-keralty", "AXA Keralty", "AXA Keralty (web y app)", "channels", "Salud", "CONFIRMED", "TOGAF-p2,p3,p6",
     "Portal y app de salud. Citas médicas, historial, resultados de laboratorio y clínicas AXA Keralty"),
    ("axa-drive", "AXA Drive", "AXA Drive (iOS y Android)", "channels", "Autos", "CONFIRMED", "TOGAF-p2,p3,p10",
     "Telemática de Autos. Reporte de siniestros online con datos de conducción y descuento por comportamiento"),
    ("portal-distribuidores", "Portal Distribuidores", "distribuidores.axa.com.mx", "channels", "Transversal", "CONFIRMED", "TOGAF-p2,p3,p5,p6",
     "Portal de agentes y promotorías. Cotizadores, trámites, plan de incentivos, cursos y SSO B2B"),
    ("axa-partners", "AXA Partners México", "axapartners.mx", "channels", "Transversal", "CONFIRMED", "TOGAF-p2,p3,p5,p6",
     "Portal B2B de asistencia y reaseguro. Co-creación de productos y API Solutions"),
    ("portal-proveedores", "Portal Proveedores", "axa.mx/proveedores", "channels", "Transversal", "CONFIRMED", "TOGAF-p2,p3,p5,p6",
     "Hospitales, talleres y médicos. Cartas de autorización, facturación, ATC Plus, Jira y RedPres"),
    ("atc-plus", "ATC Plus", "ATC Plus", "channels", "Transversal", "CONFIRMED", "TOGAF-p6,p9",
     "Canal interno de atención al cliente. También es trigger de entrada de la capa agéntica"),
    ("sistema-ventas", "Sistema de Ventas AXA", "Sistema de Ventas AXA (iOS interna)", "channels", "Transversal", "CONFIRMED", "TOGAF-p2,p6",
     "App interna del canal agencial. Cotización y emisión en campo, cartera de clientes del agente"),
    ("socio-axa", "Socio AXA", "Socio AXA (iOS interna)", "channels", "Transversal", "CONFIRMED", "TOGAF-p2,p6",
     "App interna de la red de socios y distribuidores. Gestión de cartera"),
    ("crm", "Cuentas y Antecedentes", "SINCO", "channels", "Daños", "CONFIRMED", "DISCOVERY",
     "Base de cuentas y antecedentes. Búsqueda por razón social y dirección, sin identificador confiable"),
    ("pegaso", "Entrega de Documentos", "Pegaso", "channels", "Daños", "CONFIRMED", "DISCOVERY",
     "Impresión y envío remoto de la póliza o endoso al agente que registró el folio en Vector"),
    ("genesys", "Contact Center", "Genesys", "channels", "Transversal", "PARTIAL", "TOGAF-p3",
     "Plataforma de contact center corporativo. Nombrada en el mapa de sistemas, alcance por confirmar"),
    ("salesforce", "Salesforce", "Salesforce", "channels", "Transversal", "PARTIAL", "TOGAF-p3",
     "Nombrado en el bloque de sistemas corporativos. Alcance y líneas que cubre por confirmar"),
    ("infobip", "Comunicación Multicanal", "Infobip", "channels", "Transversal", "CONFIRMED", "TOGAF-p9",
     "Salida multicanal de la capa agéntica. WhatsApp, llamadas y correo electrónico"),
    ("enterate-danos", "Entérate Daños", "Entérate Daños", "channels", "Daños", "PARTIAL", "DISCOVERY",
     "Canal interno de comunicación y normativa de Daños"),
    ("axa-im", "AXA IM México", "axa-im.com.mx", "channels", "Inversiones", "DIVESTED", "TOGAF-p2,p12",
     "Gestión de activos. AXA IM fue adquirida por BNP Paribas en diciembre de 2024 y opera como BNPP AM México desde enero de 2026"),

    # ── integration: integración, seguridad perimetral y plataforma ───
    ("api-gateway", "API Gateway", "Datapower MPG", "integration", "Transversal", "CONFIRMED", "TOGAF-p3,p6,p8,p11",
     "Bus principal AS IS y gateway de seguridad. OAuth 2.0, TLS 1.2, X509 y timestamp sobre servciosweb.axa.com.mx"),
    ("esb", "Bus Canónico", "Mulesoft Anypoint", "integration", "Transversal", "IN-MIGRATION", "TOGAF-p3,p6,p9,p11",
     "iPaaS en implementación. Bus canónico TO BE, mediación, orquestación y adaptadores a sistemas de negocio"),
    ("perimeter", "Balanceo y SSL", "F5", "integration", "Transversal", "CONFIRMED", "TOGAF-p3,p8,p11",
     "Balanceo de carga y SSL offload"),
    ("waf", "Firewall y Detección", "WAF, IPS e IDS", "integration", "Transversal", "CONFIRMED", "TOGAF-p3,p8",
     "Web Application Firewall, detección de intrusión y listas blancas y negras de IP"),
    ("containers", "Contenedores", "OpenShift", "integration", "Transversal", "CONFIRMED", "TOGAF-p3,p6,p11",
     "Plataforma de contenedores en nube privada"),
    ("app-servers", "Servidores de Aplicación", "Node.js y JBoss", "integration", "Transversal", "CONFIRMED", "TOGAF-p6,p11",
     "Runtime de aplicaciones. Node.js y JBoss como destino TO BE junto con OpenShift"),
    ("payments", "Pagos de Siniestros", "FIS Payments", "integration", "Transversal", "CONFIRMED", "TOGAF-p6,p10,p11",
     "Pasarela de pagos SaaS en patrón híbrido. Pago de indemnizaciones desde Guidewire, directo o vía Mulesoft"),
    ("payments-online", "Pagos Online", "Mitec y BBVA", "integration", "Transversal", "CONFIRMED", "TOGAF-p6,p8,p11",
     "Pasarela de pagos online de axa.mx y My AXA. Externa, sin observabilidad unificada en Azure Sentinel"),
    ("wso2", "WSO2", "WSO2", "integration", "Transversal", "PARTIAL", "TOGAF-p3",
     "Nombrado en el bloque de sistemas corporativos. Relación con Datapower y Mulesoft por confirmar"),
    ("citrix", "Acceso Virtualizado", "Citrix", "integration", "Daños", "CONFIRMED", "DISCOVERY",
     "Capa de acceso virtualizado a SED y General Daños desde el escritorio del suscriptor"),
    ("procurement", "Procurement", "Coupa", "integration", "Transversal", "CONFIRMED", "TOGAF-p3,p10,p11",
     "Procurement SaaS. Talleres homologados y proveedores"),
    ("itsm", "ITSM", "ServiceNow", "integration", "Transversal", "CONFIRMED", "TOGAF-p3,p4,p11",
     "ITSM y CMDB corporativos"),
    ("jira-service-mgmt", "Jira Service Management", "Jira Service Management", "integration", "Transversal", "PARTIAL", "TOGAF-p3",
     "Gestión de solicitudes, usado también en el Portal de Proveedores"),
    ("jfrog", "Artefactos y CI/CD", "JFrog", "integration", "Transversal", "CONFIRMED", "TOGAF-p4,p11",
     "Repositorio de artefactos y CI/CD"),

    # ── data: datos y analítica ───────────────────────────────────────
    ("oracle-golden-record", "Golden Record Corporativo", "Oracle DB corporativo", "data", "Transversal", "CONFIRMED", "TOGAF-p4,p7,p11",
     "Clientes, pólizas master, finanzas y contratos. Prerequisito de la capa agéntica y del perfil único de cliente"),
    ("oracle-danos", "Oracle DB Daños", "Oracle DB (Daños)", "data", "Daños", "CONFIRMED", "TOGAF-p5,p7",
     "Pólizas, productos, tarifas, siniestros y liquidación de Daños"),
    ("oracle-salud", "Oracle DB Salud", "Oracle DB (Salud)", "data", "Salud", "CONFIRMED", "TOGAF-p5,p7",
     "Prestaciones y autorizaciones de Salud"),
    ("oracle-autos", "Oracle DB Autos", "Oracle DB (Autos)", "data", "Autos", "CONFIRMED", "TOGAF-p5,p7",
     "Pólizas, productos y tarifas de Autos"),
    ("analytics", "Analytics y BI", "Power BI", "data", "Transversal", "CONFIRMED", "TOGAF-p4,p11;DISCOVERY",
     "Reporting y dashboards. Siniestralidad histórica, primas y reporting gerencial"),
    ("data-platform-legacy", "Data Hub Legado", "MySQL Data Hub, Pentaho e Informatica", "data", "Transversal", "DEPRECATED", "TOGAF-p4,p7",
     "Staging, mart y DWH en MySQL con ETL Pentaho e Informatica. En decommission hacia Azure, sin fecha definida"),
    ("oracle-edwh", "Enterprise Data Warehouse", "Oracle EDWH", "data", "Transversal", "DEPRECATED", "TOGAF-p4,p7",
     "Enterprise Data Warehouse AS IS, coexistiendo con la Azure Data Platform sin roadmap de decommission"),
    ("mongodb", "Capa Semántica", "MongoDB", "data", "Transversal", "DEPRECATED", "TOGAF-p4,p7",
     "Capa semántica del Data Hub legado"),
    ("data-platform-target", "Azure Data Platform", "Azure ADF, ADL y Databricks", "data", "Transversal", "IN-MIGRATION", "TOGAF-p4,p7,p11",
     "Plataforma de datos TO BE. Ingesta con Data Factory, repositorio en Data Lake y procesamiento con Databricks"),
    ("reporting-cnsf", "Reporting Regulatorio", "Monitor", "data", "Regulatorio", "PARTIAL", "DISCOVERY",
     "Herramienta de consulta y reporte. Si es la herramienta de reporte a CNSF o solo monitoreo de cartera sigue sin confirmar"),
    ("infogral", "InfoGral", "InfoGral", "data", "Daños", "PARTIAL", "DISCOVERY",
     "Fuente de consulta de información general usada en suscripción. Alcance por confirmar"),

    # ── compliance: regulatorio, finanzas, identidad y corporativos ───
    ("finance", "Finanzas", "SAP ECC v8 y FICO", "compliance", "Transversal", "CONFIRMED", "TOGAF-p3,p4,p10,p11",
     "Finanzas y recursos humanos. FICO y consolidación al Grupo AXA. Recibe el pago de indemnizaciones desde FIS"),
    ("iam", "Identidad y Acceso", "One Account, Ping Identity y LISA/Global AD", "compliance", "Transversal", "IN-MIGRATION", "TOGAF-p3,p6,p8",
     "IAM B2C y B2B hacia Azure AD, más IGA global. Migración desde LDAP a LISA y Global AD"),
    ("iam-legacy", "Directorio Local", "Local AD LDAP", "compliance", "Transversal", "DEPRECATED", "TOGAF-p8",
     "Directorio corporativo local con NTLM y Kerberos, sin IGA. Origen de la migración a Global AD"),
    ("iga-sailpoint", "Gobierno de Identidad", "SailPoint", "compliance", "Transversal", "PARTIAL", "TOGAF-p8",
     "IGA global del estado TO BE. Usuarios y recursos"),
    ("pam-cyberark", "Accesos Privilegiados", "One PAM (CyberArk)", "compliance", "Transversal", "PARTIAL", "TOGAF-p8",
     "Gestión de usuarios privilegiados, GPUAD y Crown Jewels"),
    ("cloud-backbone", "Azure Cloud", "Azure", "compliance", "Transversal", "CONFIRMED", "TOGAF-p3,p4,p11",
     "Backbone de infraestructura, datos e IA. Entra ID, APIM, Service Bus, Key Vault, Monitor y Sentinel"),
    ("azure-ai", "Azure AI", "Azure AI Foundry y OpenAI", "compliance", "Transversal", "PARTIAL", "TOGAF-p4,p11,p14",
     "LLM del agente generativo. Pendiente provisionar Foundry y seleccionar modelo base"),
    ("securegpt", "SecureGPT", "SecureGPT", "compliance", "Transversal", "CONFIRMED", "TOGAF-p4;DISCOVERY",
     "Pasarela corporativa de modelos. Claude Haiku 4.5, Gemini 2.5 Flash, GPT-4.1 Nano, GPT-5 Nano y Mistral Small 3.1"),
    ("ecm-ridd", "Gestor Documental", "RIDD y ECM/CMX", "compliance", "Transversal", "CONFIRMED", "TOGAF-p3;DISCOVERY",
     "Expediente electrónico y antecedentes. Consultado en emisión para validar soporte documental"),
    ("firma-digital", "Firma Digital", "Firma Digital", "compliance", "Transversal", "PARTIAL", "TOGAF-p3",
     "Firma electrónica corporativa. Nombrada en el mapa de sistemas"),
    ("sharepoint", "Expediente Compartido", "SharePoint", "compliance", "Daños", "CONFIRMED", "DISCOVERY",
     "Expediente electrónico definitivo del negocio facultativo, conforme a checklist homologado"),
    ("world-check", "Screening de Listas", "World-Check", "compliance", "Transversal", "CONFIRMED", "DISCOVERY",
     "Screening de listas restrictivas y personas políticamente expuestas en el proceso de suscripción"),
    ("billing-collections", "Billing y Collections", "Billing & Collections", "compliance", "Transversal", "PARTIAL", "TOGAF-p3",
     "Facturación y cobranza corporativa. Nombrada en el mapa de sistemas, alcance por confirmar"),
    ("tesoreria", "Tesorería", "Tesorería", "compliance", "Transversal", "PARTIAL", "TOGAF-p3",
     "Sistema de tesorería corporativa"),
    ("comisiones", "Comisiones", "Comisiones", "compliance", "Transversal", "PARTIAL", "TOGAF-p3",
     "Cálculo y liquidación de comisiones del canal de distribución"),
    ("maestro-clientes", "Maestro de Clientes", "Maestro Clientes", "compliance", "Transversal", "PARTIAL", "TOGAF-p3",
     "Maestro corporativo de clientes. Relación con el golden record de Oracle por confirmar"),
    ("maestro-distribuidores", "Maestro de Distribuidores", "Maestro Distribuidores", "compliance", "Transversal", "PARTIAL", "TOGAF-p3",
     "Maestro corporativo de distribuidores y agentes"),
    ("centro-notificaciones", "Centro de Notificaciones", "Centro de Notificaciones", "compliance", "Transversal", "PARTIAL", "TOGAF-p3",
     "Notificaciones corporativas"),
    ("sam-suite", "SAM Suite", "SAM Suite", "compliance", "Transversal", "PARTIAL", "TOGAF-p3",
     "Nombrado en el bloque de sistemas corporativos. Alcance por confirmar"),
    ("eb-portal", "EB Portal", "EB Portal", "compliance", "Transversal", "PARTIAL", "TOGAF-p3",
     "Portal de Employee Benefits. Nombrado en el mapa de sistemas"),
    ("cnsf", "Cumplimiento CNSF", "Por confirmar", "compliance", "Regulatorio", "SCAFFOLD", "CLAUDE-2.0",
     "Cumplimiento CNSF, notas técnicas y reportes periódicos. Sin sistema identificado en las fuentes"),
    ("solvency", "Solvencia", "Por confirmar", "compliance", "Regulatorio", "SCAFFOLD", "CLAUDE-2.0",
     "Cálculo de reservas técnicas y capital mínimo garantizado. Sin sistema identificado en las fuentes"),
]

# ──────────────────────────────────────────────────────────────────────
# COMPONENTES — subelementos nombrados dentro de un sistema
# (id, system, name, type, status, source)
# ──────────────────────────────────────────────────────────────────────
COMPONENTS = [
    ("cmp-azure-entra",      "cloud-backbone", "Azure AD y Entra ID",         "directorio",     "CONFIRMED", "TOGAF-p11"),
    ("cmp-azure-apim",       "cloud-backbone", "APIM",                        "fachada-api",    "CONFIRMED", "TOGAF-p11"),
    ("cmp-azure-servicebus", "cloud-backbone", "Service Bus",                 "mensajeria",     "CONFIRMED", "TOGAF-p11"),
    ("cmp-azure-keyvault",   "cloud-backbone", "Key Vault",                   "secretos",       "CONFIRMED", "TOGAF-p11"),
    ("cmp-azure-monitor",    "cloud-backbone", "Monitor",                     "observabilidad", "CONFIRMED", "TOGAF-p11"),
    ("cmp-azure-sentinel",   "cloud-backbone", "Sentinel",                    "siem",           "CONFIRMED", "TOGAF-p8,p11"),

    ("cmp-adf",              "data-platform-target", "Azure Data Factory",    "etl",            "IN-MIGRATION", "TOGAF-p7,p11"),
    ("cmp-adl",              "data-platform-target", "Azure Data Lake",       "repositorio",    "IN-MIGRATION", "TOGAF-p7,p11"),
    ("cmp-databricks",       "data-platform-target", "Azure Databricks",      "procesamiento",  "IN-MIGRATION", "TOGAF-p7,p11"),

    ("cmp-mysql-dwh",        "data-platform-legacy", "MySQL Staging, Mart y DWH", "dwh",        "DEPRECATED", "TOGAF-p7"),
    ("cmp-pentaho",          "data-platform-legacy", "Pentaho",               "etl",            "DEPRECATED", "TOGAF-p7"),
    ("cmp-informatica",      "data-platform-legacy", "Informatica",           "etl",            "DEPRECATED", "TOGAF-p7"),

    ("cmp-agente-orq",       "capa-agentica", "Agente orquestador",                      "orquestador", "PILOT", "TOGAF-p9"),
    ("cmp-agente-1",         "capa-agentica", "Agente 1, validación de acceso y estado", "agente",      "PILOT", "TOGAF-p9"),
    ("cmp-agente-2",         "capa-agentica", "Agente 2, verificación de condiciones",   "agente",      "PILOT", "TOGAF-p9"),
    ("cmp-agente-3",         "capa-agentica", "Agente 3, cálculo financiero",            "agente",      "PILOT", "TOGAF-p9"),
    ("cmp-agente-4",         "capa-agentica", "Agente 4, validación clínica y técnica",  "agente",      "PILOT", "TOGAF-p9"),
    ("cmp-agente-gen",       "capa-agentica", "Agente generativo LLM",                   "agente",      "PILOT", "TOGAF-p9"),

    ("cmp-visual-time",      "policy-admin-salud", "Visual Time", "core-saas", "CONFIRMED", "TOGAF-p5,p11"),
    ("cmp-gmm2000",          "policy-admin-salud", "GMM 2000",    "core",      "CONFIRMED", "TOGAF-p5,p7"),
    ("cmp-gmcol",            "policy-admin-salud", "GMCol",       "core",      "CONFIRMED", "TOGAF-p5,p7"),
    ("cmp-gmi",              "policy-admin-salud", "GMI",         "core",      "CONFIRMED", "TOGAF-p5,p7"),
    ("cmp-ises",             "policy-admin-salud", "ISES",        "core",      "CONFIRMED", "TOGAF-p5"),

    ("cmp-saludweb",         "claims-salud", "SaludWeb",   "autorizacion",     "CONFIRMED", "TOGAF-p5,p7"),
    ("cmp-sigame",           "claims-salud", "SIGAME",     "autorizacion",     "CONFIRMED", "TOGAF-p5,p7"),
    ("cmp-dictamedic",       "claims-salud", "DictaMedic", "dictamen",         "CONFIRMED", "TOGAF-p5,p7"),
    ("cmp-qantev",           "claims-salud", "Qantev",     "analitica",        "CONFIRMED", "TOGAF-p5,p7"),
    ("cmp-redpres",          "claims-salud", "RedPres",    "red-prestadores",  "CONFIRMED", "TOGAF-p5,p7"),

    ("cmp-one-account",      "iam", "One Account",       "iam-b2c", "CONFIRMED",    "TOGAF-p6,p8"),
    ("cmp-ping",             "iam", "Ping Identity",     "iam-b2b", "CONFIRMED",    "TOGAF-p6,p8"),
    ("cmp-lisa",             "iam", "LISA y Global AD",  "iga",     "IN-MIGRATION", "TOGAF-p6,p8"),

    ("cmp-claude-haiku",     "securegpt", "Claude Haiku 4.5",  "llm", "CONFIRMED", "TOGAF-p4"),
    ("cmp-gemini-flash",     "securegpt", "Gemini 2.5 Flash",  "llm", "CONFIRMED", "TOGAF-p4"),
    ("cmp-gpt41-nano",       "securegpt", "GPT-4.1 Nano",      "llm", "CONFIRMED", "TOGAF-p4"),
    ("cmp-gpt5-nano",        "securegpt", "GPT-5 Nano",        "llm", "CONFIRMED", "TOGAF-p4"),
    ("cmp-mistral-small",    "securegpt", "Mistral Small 3.1", "llm", "CONFIRMED", "TOGAF-p4"),
]

# ──────────────────────────────────────────────────────────────────────
# DEPENDENCIAS CROSS-SISTEMA declaradas en el TOGAF
# (system_a, system_b, dependency_type, direction, evidence, criticality)
#
# direction: a->b unidireccional, a<->b bidireccional
# ──────────────────────────────────────────────────────────────────────
DEPENDENCIES = [
    # Flujo de siniestro de Autos, TOGAF p10 — el único flujo documentado extremo a extremo
    ("my-axa-app", "claims-autos", "integration-direct", "a->b",
     "Apertura de siniestro desde la app. TOGAF p10 paso 1", "high"),
    ("axa-drive", "claims-autos", "integration-direct", "a->b",
     "Reporte de siniestro con telemática. TOGAF p10 paso 1", "medium"),
    ("claims-autos", "fraud-detection", "integration-direct", "a->b",
     "Análisis de fraude con machine learning en paralelo. TOGAF p10 paso 2", "high"),
    ("claims-autos", "peritacion", "integration-direct", "a<->b",
     "Integración directa Guidewire y Audatex, con waiver del Architecture Board. TOGAF p10 paso 3 y p13", "high"),
    ("peritacion", "procurement", "integration-direct", "a->b",
     "Asignación a taller homologado registrado en Coupa. TOGAF p10 paso 4", "medium"),
    ("claims-autos", "payments", "integration-direct", "a->b",
     "Pago de indemnización, directo o vía Mulesoft. Patrón híbrido sin gobierno formal. TOGAF p10 paso 5 y p12", "high"),
    ("payments", "finance", "integration-direct", "a->b",
     "Liquidación contable del pago hacia SAP FICO. TOGAF p10 paso 5", "high"),
    ("claims-autos", "my-axa-app", "integration-direct", "a->b",
     "Confirmación y estado en tiempo real en la app. TOGAF p10 paso 6", "medium"),

    # Perímetro e integración, TOGAF p3, p6, p8
    ("axa-mx", "perimeter", "integration-bus", "a->b",
     "Balanceo y SSL offload de los portales. TOGAF p6 y p8", "medium"),
    ("my-axa-web", "perimeter", "integration-bus", "a->b",
     "Balanceo y SSL offload de los portales. TOGAF p6 y p8", "medium"),
    ("perimeter", "api-gateway", "integration-bus", "a->b",
     "Tráfico del perímetro hacia el gateway OAuth. TOGAF p6 y p8", "high"),
    ("api-gateway", "esb", "migration", "a->b",
     "Datapower es el bus principal AS IS y Mulesoft el bus canónico TO BE. Coexisten como gateways sin criterio formal. TOGAF p3 y p12", "high"),
    ("esb", "policy-admin-danos", "integration-bus", "a->b",
     "Adaptadores de Mulesoft hacia los sistemas de negocio. TOGAF p6 y p9", "medium"),
    ("esb", "claims-autos", "integration-bus", "a->b",
     "Adaptadores de Mulesoft hacia el core de siniestros. TOGAF p6 y p9", "medium"),
    ("esb", "finance", "integration-bus", "a->b",
     "Adaptadores de Mulesoft hacia los sistemas financieros. TOGAF p9", "medium"),
    ("axa-mx", "payments-online", "integration-direct", "a->b",
     "Pasarela Mitec y BBVA para pago online. Externa, sin observabilidad en Sentinel. TOGAF p8 y p12", "high"),
    ("my-axa-web", "payments-online", "integration-direct", "a->b",
     "Pasarela Mitec y BBVA para pago online. TOGAF p8", "medium"),

    # Capa agéntica, TOGAF p9
    ("my-axa-app", "capa-agentica", "trigger", "a->b",
     "Trigger de entrada B2C desde portal o app. TOGAF p9", "medium"),
    ("axa-mx", "capa-agentica", "trigger", "a->b",
     "Trigger de entrada B2C. TOGAF p9", "medium"),
    ("atc-plus", "capa-agentica", "trigger", "a->b",
     "Trigger de atención al cliente. TOGAF p9", "medium"),
    ("axa-keralty", "capa-agentica", "trigger", "a->b",
     "Trigger de salud. TOGAF p9", "medium"),
    ("capa-agentica", "esb", "integration-bus", "a->b",
     "La capa agéntica alcanza los sistemas de negocio por adaptadores de Mulesoft. TOGAF p9", "high"),
    ("capa-agentica", "azure-ai", "integration-direct", "a->b",
     "El agente generativo consume el LLM de Azure AI Foundry. TOGAF p9 y p11", "high"),
    ("capa-agentica", "infobip", "integration-direct", "a->b",
     "Salida multicanal por WhatsApp, llamada y correo. TOGAF p9", "medium"),
    ("capa-agentica", "oracle-golden-record", "gap", "a->b",
     "La capa agéntica depende de un golden record de cliente que no existe unificado. Prerequisito declarado. TOGAF p7, p12 y p14", "critical"),

    # Datos, TOGAF p7 y p12
    ("oracle-golden-record", "oracle-danos", "gap", "a<->b",
     "Sin golden record de cliente unificado entre el Oracle corporativo y el de línea. TOGAF p7 y p12", "critical"),
    ("oracle-golden-record", "oracle-salud", "gap", "a<->b",
     "Sin golden record de cliente unificado entre el Oracle corporativo y el de línea. TOGAF p7 y p12", "critical"),
    ("oracle-golden-record", "oracle-autos", "gap", "a<->b",
     "Sin golden record de cliente unificado entre el Oracle corporativo y el de línea. TOGAF p7 y p12", "critical"),
    ("oracle-golden-record", "policy-admin-vida", "gap", "a<->b",
     "Progress y COBOL queda fuera del golden record. Impide cruzar la identidad de Vida con el resto de líneas. TOGAF p7 y p12", "critical"),
    ("policy-admin-danos", "oracle-danos", "data-flow", "a<->b",
     "SED y General Daños operan sobre Oracle DB Daños. TOGAF p7", "high"),
    ("policy-admin-autos", "oracle-autos", "data-flow", "a<->b",
     "Pólizas, productos y tarifas de Autos viven en Oracle DB Autos. TOGAF p7", "high"),
    ("claims-salud", "oracle-salud", "data-flow", "a<->b",
     "Prestaciones y autorizaciones sobre Oracle DB Salud. TOGAF p7", "high"),
    ("data-platform-legacy", "data-platform-target", "migration", "a->b",
     "Migración del Data Hub legado hacia la Azure Data Platform, sin fecha de decommission. TOGAF p7 y p12", "high"),
    ("oracle-edwh", "data-platform-target", "migration", "a->b",
     "El EDWH coexiste con la plataforma destino sin roadmap. TOGAF p7 y p12", "high"),
    ("data-platform-target", "analytics", "data-flow", "a->b",
     "Power BI como capa de reporting sobre la plataforma destino. TOGAF p7 y p11", "medium"),

    # Identidad, TOGAF p8
    ("iam-legacy", "iam", "migration", "a->b",
     "Migración de LDAP local hacia LISA y Global AD. TOGAF p8 y p14", "high"),
    ("iam", "cloud-backbone", "auth", "a->b",
     "One Account y Ping federan contra Azure AD. TOGAF p8 y p11", "high"),
    ("iam", "iga-sailpoint", "migration", "a->b",
     "SailPoint como IGA global del estado TO BE. TOGAF p8", "medium"),
    ("portal-distribuidores", "iam", "auth", "a->b",
     "SSO B2B de agentes y promotorías. TOGAF p2 y p6", "medium"),
]

# Slugs v1.0 que cambian de nombre en v2.0
SLUG_MIGRATION = {
    "policy-admin": "policy-admin-danos",
    "actuarial": "actuarial-cat",
    "claims": "claims-danos",
    "datawarehouse": "oracle-edwh",
    "event-bus": "esb",
    "digital": "my-axa-web",
    "portal-agentes": "portal-distribuidores",
}

# Sistemas v1.0 que desaparecen: 'billing' no tiene evidencia en ninguna fuente
RETIRED_SLUGS = ["billing"]


def validate():
    """Falla ruidosamente si el registro es incoherente."""
    errors = []
    slugs = [s[0] for s in SYSTEMS]
    dupes = [s for s, n in Counter(slugs).items() if n > 1]
    if dupes:
        errors.append(f"Slugs duplicados: {dupes}")
    known = set(slugs)
    for c in COMPONENTS:
        if c[1] not in known:
            errors.append(f"Componente {c[0]} apunta a sistema inexistente: {c[1]}")
    cids = [c[0] for c in COMPONENTS]
    cdupes = [c for c, n in Counter(cids).items() if n > 1]
    if cdupes:
        errors.append(f"Ids de componente duplicados: {cdupes}")
    for d in DEPENDENCIES:
        for side in (d[0], d[1]):
            if side not in known:
                errors.append(f"Dependencia apunta a sistema inexistente: {side}")
    for old, new in SLUG_MIGRATION.items():
        if new not in known:
            errors.append(f"Migración {old} hacia {new}: destino inexistente")
    if errors:
        for e in errors:
            print(f"  [ERROR] {e}")
        raise SystemExit("[ABORT] El registro no es coherente. No se escribió nada.")
    print(f"  [OK] {len(SYSTEMS)} sistemas, {len(COMPONENTS)} componentes, "
          f"{len(DEPENDENCIES)} dependencias declaradas")


def to_json():
    return {
        "version": LANDSCAPE_VERSION,
        "generated_at": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "client": "AXA Seguros S.A. de C.V.",
        "sources": {
            "TOGAF-pN": "source/arquitectura_TOGAF_accenture_v19.pdf, página N",
            "DISCOVERY": "source/2608_Suscripción_Entregable_Anexo Competitive Discovery Suscripción Daños.xlsx",
            "CLAUDE-2.0": "AXA/CLAUDE.md, tabla de landscape v2.0",
        },
        "systems": [
            dict(zip(("slug", "display_name", "real_name", "category",
                      "lob", "status", "source", "note"), s))
            for s in SYSTEMS
        ],
        "components": [
            dict(zip(("id", "system", "name", "type", "status", "source"), c))
            for c in COMPONENTS
        ],
        "dependencies": [
            dict(zip(("system_a", "system_b", "dependency_type",
                      "direction", "evidence", "criticality"), d))
            for d in DEPENDENCIES
        ],
        "slug_migration": SLUG_MIGRATION,
        "retired_slugs": RETIRED_SLUGS,
    }


def load_db(conn):
    cur = conn.cursor()

    # systems — se reemplaza el registro completo
    cur.execute("DELETE FROM systems")
    for slug, display, real, cat, lob, status, source, note in SYSTEMS:
        brain_path = os.path.join("..", "systems", cat, slug, "digital-brain", "brain.db")
        attached = 1 if os.path.exists(os.path.join(BASE_DIR, brain_path)) else 0
        cur.execute("""
            INSERT INTO systems (slug, display_name, real_name, category, togaf_type,
                                 lob, status, note, brain_path, brain_attached)
            VALUES (?,?,?,?,?,?,?,?,?,?)
        """, (slug, display, real, cat, cat, lob, status,
              f"{note} [fuente: {source}]", brain_path, attached))
    print(f"  [OK] systems: {len(SYSTEMS)} registrados")

    # components
    cur.execute("DELETE FROM components")
    for cid, system, name, ctype, status, source in COMPONENTS:
        cur.execute("""
            INSERT INTO components (id, system, name, type, status, maturity)
            VALUES (?,?,?,?,?,?)
        """, (cid, system, name, ctype, f"{status} [fuente: {source}]", "HOY"))
    print(f"  [OK] components: {len(COMPONENTS)} registrados")

    # cross_dependencies — declaradas en el TOGAF
    cur.execute("DELETE FROM cross_dependencies")
    declared_n = 0
    for a, b, dtype, direction, evidence, crit in DEPENDENCIES:
        cur.execute("""
            INSERT OR REPLACE INTO cross_dependencies
              (id, system_a, system_b, dependency_type, direction, evidence, criticality)
            VALUES (?,?,?,?,?,?,?)
        """, (f"dep-togaf-{declared_n:03d}", a, b, dtype, direction, evidence, crit))
        declared_n += 1

    # cross_dependencies — derivadas empíricamente del Discovery por coocurrencia
    pairs = Counter()
    rows = cur.execute(
        "SELECT sistemas_slugs FROM process_steps "
        "WHERE sistemas_slugs IS NOT NULL AND sistemas_slugs != ''"
    ).fetchall()
    for (raw,) in rows:
        slugs = sorted({SLUG_MIGRATION.get(p.strip(), p.strip())
                        for p in raw.split(";") if p.strip()})
        for i in range(len(slugs)):
            for j in range(i + 1, len(slugs)):
                pairs[(slugs[i], slugs[j])] += 1

    known = {s[0] for s in SYSTEMS}
    declared = {(a, b) for a, b, *_ in DEPENDENCIES} | {(b, a) for a, b, *_ in DEPENDENCIES}
    derived = 0
    for (a, b), count in pairs.most_common():
        if a not in known or b not in known or (a, b) in declared:
            continue
        crit = "high" if count >= 20 else "medium" if count >= 5 else "low"
        cur.execute("""
            INSERT OR REPLACE INTO cross_dependencies
              (id, system_a, system_b, dependency_type, direction, evidence, criticality)
            VALUES (?,?,?,?,?,?,?)
        """, (f"dep-disc-{derived:03d}", a, b, "manual-handoff", "a<->b",
              f"Coocurren en {count} pasos del proceso de suscripción de Daños. Fuente: DISCOVERY",
              crit))
        derived += 1
    print(f"  [OK] cross_dependencies: {declared_n} declaradas en el TOGAF, "
          f"{derived} derivadas del Discovery")

    # migración de slugs en process_steps
    migrated = 0
    rows = cur.execute(
        "SELECT id, sistemas_slugs FROM process_steps "
        "WHERE sistemas_slugs IS NOT NULL AND sistemas_slugs != ''"
    ).fetchall()
    for pid, raw in rows:
        parts = [p.strip() for p in raw.split(";") if p.strip()]
        new = sorted({SLUG_MIGRATION.get(p, p) for p in parts})
        joined = "; ".join(new)
        if joined != raw:
            cur.execute("UPDATE process_steps SET sistemas_slugs=? WHERE id=?", (joined, pid))
            migrated += 1
    print(f"  [OK] process_steps: {migrated} pasos con slugs migrados a v2.0")

    # meta
    cur.executemany("INSERT OR REPLACE INTO brain_meta (key, value) VALUES (?,?)", [
        ("version", "2.0.0"),
        ("landscape_version", LANDSCAPE_VERSION),
        ("built_at", datetime.now().strftime("%Y-%m-%d %H:%M")),
        ("systems_count", str(len(SYSTEMS))),
        ("components_count", str(len(COMPONENTS))),
        ("dependencies_count", str(declared_n + derived)),
        ("source_togaf", "arquitectura_TOGAF_accenture_v19.pdf"),
    ])
    conn.commit()


def main():
    dry = "--dry-run" in sys.argv
    print(f"[LANDSCAPE] AXA v{LANDSCAPE_VERSION}")
    print("[VALIDATE]")
    validate()
    if dry:
        print("[DRY-RUN] Nada escrito.")
        return

    os.makedirs(JSON_DIR, exist_ok=True)
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(to_json(), f, ensure_ascii=False, indent=2)
    print("  [OK] JSON escrito en knowledge-base/landscape/landscape-axa-v2.json")

    conn = sqlite3.connect(DB_PATH)
    print("[LOAD]")
    load_db(conn)

    print("\n[RESUMEN POR CATEGORIA]")
    for cat, total in conn.execute(
        "SELECT category, COUNT(*) FROM systems GROUP BY category ORDER BY category"
    ):
        print(f"  {cat:<14} {total:>3}")
    print("\n[RESUMEN POR STATUS]")
    for st, total in conn.execute(
        "SELECT status, COUNT(*) FROM systems GROUP BY status ORDER BY COUNT(*) DESC"
    ):
        print(f"  {st:<16} {total:>3}")
    conn.close()


if __name__ == "__main__":
    main()
