# BanCoppel — Arquitectura AS-IS (Iniciativa Unity)
## Base de conocimiento COMPLETA del proyecto + guía de regeneración del diagrama

> **Propósito.** Documento único de traspaso para un nuevo proyecto de Claude. Sintetiza **toda** la información disponible del proyecto AS-IS de BanCoppel y contiene lo necesario para **regenerar e iterar** el diagrama `BanCoppel_Arquitectura_AS-IS.svg`. Secciones: contexto · fuentes · validación de cobertura · **notas de validación cruzada** · **inventario completo (129 apps)** · **modelo de capacidades N3 (214)** · **mapeo capacidad↔app v4** · **mini-core SOC (710 func.)** · **catálogo de 86 SUD** · reglas de dominio · entregables · layout · **catálogo de interacciones** · pendientes · **regeneración + script completo (Anexo A)**.

> ✅ **Documento autocontenido.** No requiere cargar ningún otro archivo del proyecto: incluye el inventario completo, el modelo de capacidades, el mini-core SOC, las **fichas técnicas sintetizadas de los 86 SUD** (§9), las **26 transcripciones de diagramas de arquitectura** (§9-bis) y el script generador (Anexo A). Los nombres de los archivos fuente se citan solo como trazabilidad de origen.


---

## 1. Contexto y rol

- **Programa Unity:** nueva plataforma bancaria (módulos **Transact, Apolo, SmartVista**) hacia la que migra el legado. Iniciativas: Tarjeta de Crédito, Cuenta Efectiva Digital (programas **N4**), Captación y Colocación.
- **Entregable:** *Blue Print de Arquitectura*. Este diagrama es la **Arquitectura AS-IS** del legado, construida **según la plantilla del ejemplo** `Example_ASIS_Architecure_Apliction.pdf`, **NO** según la visión TO-BE de Unity.
- **Rol interlocutor:** Arquitecto de Integración (banca, Originación/Onboarding). Respuestas técnicas, español.
- **Principios:** basado en evidencia (citar SUD/sección), inferencias marcadas `[INFERENCIA]`, marcos BIAN/TOGAF/ArchiMate, sin fabricación.
- **Stack legado núcleo:** **SIF** (Sistema Integral Financiero, Grupo PISA) sobre **IBM Informix**; **Syndein InterAct** (middleware transaccional); **IBM IIB/ACE (BUS)** (ESB). OLTP en Informix (`bdinteg`,`bdicheq`,`bdisac`,`bdispei`); apps modernas en PostgreSQL/Mongo/Oracle/DB2.

## 2. Fuentes del proyecto

| Artefacto | Contenido | Rol |
|---|---|---|
| **Anexo 5** (`MasTipo_Anexo_5…xlsx`) | 129 aplicaciones (ID, nombre, flag Core, tipo, funciones, grupo). Hoja `Base`: datos desde **fila 3**, **columna A vacía**, IDs `float(str(id).strip())`, filtrar `id<=0`. | **Normalización** de nombres/IDs; flag **Core estructural**. |
| **86 SUD** (`.docx` = texto/Markdown UTF-8) | System Understanding Documents por sistema. | **Fuente primaria** AS-IS. |
| **EXT_Modelo_Base…v2_1.xlsx** | Capacidades: 214 N3 en 6 dominios N1. | Marco de capacidades. |
| **Funcionalidades_SOC.xlsx** | 710 funciones en 15 módulos SOC. | Detalle mini-core. |
| **BanCoppel_Mapeo_Capacidades_N3_Aplicaciones_ASIS_v4.xlsx** | Mapeo capacidad×app (334 filas), Rol, Sistema primario, auditoría. | Cobertura AS-IS. |
| **…Corpus…LIGERO.md** | Notas de validación cruzada + 26 transcripciones de diagramas + resumen de 351 docs. | Evidencia consolidada. |
| **CMDB_V2_2.xlsx**, diagramas/esquemas PDF | Infraestructura/topología. | Complemento. |

## 3. Validación de cobertura de interacciones (barrido sobre 88 SUD)

El core es la base transaccional; casi todos los dominios lo consumen:

| Mecanismo / entidad | # SUD |
|---|---|
| Referencian el núcleo (Informix/Interact/BUS) | **87 / 88** |
| Informix / OLTP / SPL | **80** |
| Interact (Syndein) | 68 |
| ISO 8583 / Visa / MC / eGlobal / PROSA | 72 |
| IBM BUS / WAS | 29 |
| SPEI / Banxico / CoDi | 34 |
| Remesadoras (BTS/Appriza/WU/Orlandi/Vigo) | 27 |
| Buró / Círculo | 16 |
| RENAPO / INE | 13 |
| CECOBAN | 3 |
| PostgreSQL / Oracle / DB2 | 31 / 8 / 9 |

**Diseño:** CORE como pilar central con *fan-in* desde todos los dominios; se representan todos los **tipos** de interacción a nivel dominio (no cada endpoint punto a punto).

## 4. Notas de validación cruzada (del corpus LIGERO) — LEER PRIMERO

> Complementos, contradicciones y trampas detectadas al contrastar fichas contra diagramas. Es la sección más importante para no repetir errores.

▚ NOTAS DE VALIDACIÓN CRUZADA (revisión de completitud y contradicciones)
# Resultado de una segunda pasada sobre los 383 documentos no excluidos,
# contrastando el texto de las fichas/procesos contra las transcripciones de
# diagramas. Objetivo: garantizar que la información es completa y señalar
# complementos y contradicciones ANTES de usar este corpus para generar el
# mapa de capacidades y el diagrama de aplicaciones.

## ✅ Cobertura
- Los 351 documentos de texto, las 3 plantillas Tenant y los 29 diagramas están incluidos.
- 3 imágenes (Evaluación_de_Soluciones_de_Crédito.png, ..._CréditoSucursal.png,
  Origincación_de_Crédito.png) son duplicados idénticos de otras ya transcritas; se documentan
  por referencia, no se perdió información.
- Ningún sistema nombrado en las fichas quedó ausente del corpus.

## ➕ COMPLEMENTOS (sistemas reales del legado que NO tienen diagrama propio; van sólo como texto)
Estos deben incluirse en el diagrama de aplicaciones aunque no aparezcan en las transcripciones gráficas:
- **Orión**: sistema de crédito comercial legado (Visual C++.NET). Crea el "legado" del cliente
  (BCP_Alta_de_Cliente). Aplicación core de originación/gestión de crédito. RELEVANTE para TDC.
- **Latinia**: motor de notificaciones (SMS/push) al cliente. Habilitador transversal de canales
  (App, TDC, activaciones). Aparece en múltiples flujos de la App.
- **Interact Router**: enrutador de consultas a servicios externos (RENAPO, INE, huellas). Pieza de
  integración de originación/onboarding. Complementa al "Interfaz de servicios Coppel".
- **INCODE**: proveedor externo de biometría/verificación de identidad para originación DIGITAL (DUD).
  Clave para las iniciativas de cuenta digital N4/N2 y TDC digital.
- **VOICES**: sistema asociado a Dictamen Unificado / cobranza (aparece en el journey de Dictamen).
- **SICCs**: sistema consultado en evaluación de crédito y Dictamen Unificado.
- **Motor de Rostros** (WS Biometric) y **Motor de Huellas** (WS Huellas / wshuellasBancoAU):
  biometría facial y dactilar. El de huellas SÍ tiene diagrama; el de rostros NO (sólo ficha).
- **SAFRE**: sistema externo del proceso de Afore (origen de los archivos de pago; complementa la
  transcripción de "Pagos de la Afore").
- **SAM / SIBUC / AUDI**: sistemas Banxico usados por Caja General (autenticación de moneda, bancos
  usuarios y corresponsales, administración de usuarios). Complementan la operación de efectivo.
- **GCD** (Gestor de Cobranza Domiciliaria): motor de domiciliación.
- **SPEI Central** y **SPEI Enlace Financiero**: dos componentes SPEI distintos (además del diagrama
  general de SPEI). "Enlace Financiero" conecta con Core Bancario (Informix).
- **WUPUS / Orlandi Vigo**: componentes del pago de remesas Western Union (complementan remesas).
- **Token Digital**, **CoDi**, **Motor de Pago de Servicios**: componentes del Portal de Internet /
  Banca por Internet.

## ⚙️ HERRAMIENTAS ITSM (NO son capacidades de negocio — no mapear como aplicaciones de negocio)
- **CORIMA** e **InvGate**: son la mesa de servicio / gestión de tickets de soporte (ITSM). Aparecen
  con altísima frecuencia en las fichas porque documentan el soporte, NO porque sean sistemas de
  negocio. NO deben mapearse a capacidades de negocio ni al portafolio funcional del core.

## ⚠️ CONTRADICCIONES Y MATICES DETECTADOS
1. **Caja General vs SPL (contradicción ya conocida, ahora con evidencia precisa)**:
   - La ficha `BP_Z_Curve_Caja_General.pdf` declara sus sistemas como **SOC/Módulo caja general +
     SIF + SIWEB + SAM/SIBUC/AUDI**. NO la clasifica como core SPL, sino como MÓDULO de SOC.
   - El core SPL aparece en una ficha SEPARADA: `BP_Z_Curve_Integral_Módulo_Central_SPL.pdf`
     ("Integral Módulo Central" + SIF).
   - ~25 documentos SOC describen "SOC (Módulo de Caja General)".
   - ➜ DECISIÓN BLOQUEADA (mantener Caja General como core banking SPL) CONTRADICE lo que dicen las
     fichas. La decisión se respeta por indicación del arquitecto, pero el otro proyecto NO debe
     "auto-corregir" reclasificando Caja General como SOC: es una decisión consciente, no un error.
2. **OFI — expansión del nombre**:
   - En 4 documentos OFI = "**Oficina Financiera Integral**" (coincide con la decisión registrada).
   - En 1 documento aislado (`SUC_Envío_de_órdenes_de_pago.pdf`) aparece como "Oficina Financiera
     **Central**". Es un typo del corpus, NO una reclasificación. OFI sigue siendo canal/originación.
   - En las fichas OFI se desglosa en **OFI Tradicional** y **OFI Web (SIWEB)**: son dos frentes del
     mismo canal (sucursal tradicional vs web). Ninguno es core.
3. **Core bancario = Informix (consistente)**: 6 fichas declaran "Core Bancario (Informix)". No hay
   contradicción con la decisión de core en Informix/SPL. Las IPs de core (10.36.197.51 MTY /
   10.36.193.51 CLN) sólo aparecen en diagramas, no en fichas → fuentes complementarias, sin conflicto.

## 🎯 CONSOLIDADO ÚTIL — Sistemas de ORIGINACIÓN DE TDC (relevante para iniciativas Unity)
Las fichas de Solicitud/Originación TDC coinciden en este stack:
  OFI Tradicional, OFI Web, Interfaz de servicios Coppel, Consulta INE, Consulta RENAPO,
  Consulta Buró, Motor de evaluación de crédito, IST/Switch ATMs, Dictamen Unificado,
  Alta Móvil, Monitor Web. (Para TDC digital añadir: DUD, INCODE, Motor de Rostros/Huellas.)
La gestión/autorización de TDC usa: InterAct IST SW Autorizador, Switch InterCard MasterCard,
  Core Bancario (Informix), Sistema Operativo Oxxo (corresponsalía).


## 5. Inventario completo de aplicaciones (Anexo 5 — 129 apps)

Total **129** · Core=Sí **31**. Tipos: Aplicación de Canal=12, Aplicación de Negocio=24, Motor / Servicio=31, Monitoreo / Herramienta=4, Proceso Batch / Interfaz=14, Producto de Terceros / SaaS=15, Módulo del Core=14, Core Bancario=6, Reporte / Regulatorio=7, Fuera de alcance=2.

| ID | Core | Nombre | Corto | Tipo | #Func | Grupo | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | No | Portal de Internet (Banca Por Internet) | BPI | Aplicación de Canal | 45 | Aplicación con acce… | Portal privado para Banca por internet, operaciones bancarias para personas fisica |
| 2 | No | Administrador de token (CAS) | Admon Token | Aplicación de Negocio | 4 | Aplicación con acce… | Sistema de control y administración de dispositivos de autentificacion RSA (Token) Operación interna para inv… |
| 3 | No | Empresa Net | Empresa Net | Aplicación de Canal | 25 | Aplicación con acce… | Portal privado para Banca por internet, operaciones bancarias para personas morales |
| 4 | No | CAT (01-800) Centro de atencion Telefonica | CAT | Aplicación de Canal | 26 | Aplicación con acce… | Aplicación para operadores del CAT, corresponde a identificación de clientes y soporte de operaciones especif… |
| 5 | No | Intranet | Intranet | Aplicación de Negocio | 44 | Aplicación sin acce… | Aplicación web para publicacion de informes y sistemas internos a personal de BanCoppel Esta es la Versión 1 … |
| 6 | No | Portal Publico BanCoppel.com | Portal Web | Aplicación de Negocio | 77 | Aplicación sin acce… | Pagina publica en internet de BanCoppel, www.bancoppel.com Operación de mantenimiento de publicaciones para m… |
| 7 | No | Autentificación de token RSA/Gemalto | WS-AMY | Motor / Servicio | 3 | Aplicación con acce… | Sistema de control de autentificación por OTP correspondientes a dos tipos de Token (RSA/Gemalto) por parte d… |
| 8 | No | Autentificación de Token RSA | WS-RSA | Motor / Servicio | 3 | Aplicación sin acce… | Sistema de control de autentificación por OTP correspondientes a Token fisicos de RSA por parte de  clientes … |
| 9 | No | Monitor de Operaciones BPI | Monitor BPI | Monitoreo / Herramienta | 2 | Aplicación sin acce… | Sistema de monitoreo de operaciones de Banca por internet para personas fiiscas |
| 10 | No | OpenBanking | OpenBanking | Motor / Servicio | 3 | Aplicación sin acce… | Sistema de publicación de API publicas, control de usuarios y peticiones Sitio informativo del proceso para c… |
| 11 | No | Interact Switch (Autorizador) | Autorizador | Aplicación de Canal | 8 | Aplicación con acce… | Aplicación para la aprobación de transacciones POS y ATM's terceros con el Swicth transaccional Eglobal Inter… |
| 12 | Sí | MAC WEB | Mac Web | Aplicación de Negocio | 7 | Aplicación Nativa d… | Generación de maquila de tarjetas emisor BanCoppel por medio de binarios y procesos batch SPL en informix Mod… |
| 13 | Sí | Conciliación Automática ATM / POS | Conciliación Auto… | Proceso Batch / Interfaz | 3 | Aplicación Nativa d… | Concilación de Transacciones POS , ATM's y Corresponsalia |
| 14 | No | Kibana Monitor Transaccional | Kibana Monitor Tr… | Producto de Terceros / … | 1 | Aplicación sin acce… | Esta aplicación no es del banco, se contrata un servicio que ofrece Eglobal por medio de una aplicación WEB N… |
| 15 | No | Interact Router (21) | Interact Router | Motor / Servicio | 6 | Aplicación con acce… | Midelwere para conectar diferentes interfaces del banco, Coppel u aplicaciones que ncesitan ejecutar un SPL e… |
| 16 | Sí | Puntos Compromiso (SPLs) | MAC (SPL) | Módulo del Core | 1 | Aplicación con acce… | Es un modulo del SOC para extraer pagos vencidos e información de tarjetabientes La información sale de DB in… |
| 17 | No | Corresponsalía OXXO | Corresponsalía OX… | Aplicación de Canal | 1 | Aplicación con acce… | Canal por el cual de puede depositar y hacer pagos  por medio de un corresponsal como Oxxo o Seven-9 |
| 18 | No | IST SW (swithc) ATM's Propios | IST o ATM's | Aplicación de Canal | 20 | Aplicación sin acce… | Apliación para gestionar la red de cajeros propios Switch para transacciones en cajeros para Tarjetas propias… |
| 19 | No | Carga de ATM | Carga de ATM | Proceso Batch / Interfaz | 6 | Aplicación sin acce… | Menú en Payton para el envio de carga configuraciones a los ATM's de red propia Las instrucciones del IST  (s… |
| 20 | No | GUI | GUI IST | Monitoreo / Herramienta | 3 | Aplicación sin acce… | Interfas grafica para configurar el IST SW ATM's Propios |
| 21 | No | Netxms Monitor ATM | Netxms | Monitoreo / Herramienta | 4 | Aplicación sin acce… | Monitor de la aplicación IST SW ATM's Propios, si hay algún problema de saturación del sistema o problemas co… |
| 22 | No | VCAS | VCAS | Proceso Batch / Interfaz | 2 | Aplicación con acce… | Proceso bacth de SPL de informix para mandar altas o actualización de tarjetas para sistema de Vcas de VISA  … |
| 23 | Sí | Clientes | Gestor Central | Motor / Servicio | 1 | Aplicación Nativa d… | Servicio para comparación de huellas de clientes y empleados |
| 24 | Sí | Sistema Operativo Central (SOC) | SOC | Core Bancario | 30 | Aplicación con acce… | Sistema con grupos de funcionalidades utilizadas por las diferentes áreas de negocio y operativas de coorpora… |
| 25 | Sí | Domiciliacion (SPLs) | DOMI (SPLs) | Módulo del Core | 1 | Aplicación con acce… | Pagos domiciliados de Tarjeta Coppel Es una interfaz de sucursal, por contrl M (batch) Hay un projecto para m… |
| 26 | No | Pago de TDC de Otros Bancos | Disperción de pag… | Proceso Batch / Interfaz | 2 | Aplicación con acce… | Pago de TDC de Otros Bancos Dispersión de pago a otros bancos |
| 27 | No | Transferencia Electrónica de Fondos (TEF) | TEF | Proceso Batch / Interfaz | 1 | Aplicación con acce… | Transferencia Electrónica de Fondos Envio de dinero entre bancos, operado por Cecoban, de 24 a 48 en reflejar… |
| 28 | No | Consulta INE (Bus INE 4.0) | Bus INE 4.0 | Motor / Servicio | 1 | Aplicación sin acce… | Bus INE 4.0 |
| 29 | No | Consulta INE | Consulta INE | Motor / Servicio | 2 | Aplicación con acce… | Validación del cliente ante el INE |
| 30 | No | Latinia | Latinia | Motor / Servicio | 3 | Aplicación con acce… | Envio de notificaciones SMS, Correo, Push Consulta al Informix para validar si envia o no notificaciones |
| 31 | No | Derechos ARCO | Derechos ARCO | Aplicación de Negocio | 1 | Aplicación con acce… | Aplicación heredada con poco detalle. Vive en la Intranet. Módulo que captura y consulta las solicitudes de D… |
| 32 | No | Motor de Rostros | Motor de Rostros | Motor / Servicio | 4 | Aplicación con acce… | Servicio de comnparación de rostros del cliente Para identificar posibles casos de suplantación de identidad |
| 33 | No | Motor de Huellas | Motor de Huellas | Motor / Servicio | 3 | Aplicación con acce… | Servicio de comparacion de huellas del cliente |
| 34 | No | Audisoft | Audisoft | Producto de Terceros / … | 4 | Aplicación sin acce… | Sistema web cuyo objetivo es la administración y gestión de información relacionadas a las auditorias llevada… |
| 35 | No | Aclaraciones | Aclaraciones | Aplicación de Negocio | 4 | Aplicación con acce… | Sistema web cuyo objetivo es el ingreso de aclaraciones por movimientos no reconocidos de productos internos … |
| 36 | No | Unilogic (Risk Logic) | Risk logic | Producto de Terceros / … | 1 | Aplicación sin acce… | Sistema de riesgos |
| 37 | No | Motor de Pago de Servicios | Motor de Pago de … | Motor / Servicio | 3 | Aplicación con acce… | Servicios que se pueden pagar DISH - Pago de Servicio de TV Satelital Tiempo Aire - Recarga de Tiempo Aire AN… |
| 38 | No | Homologación-Servicios | Homologación-Serv… | Motor / Servicio | 2 | Aplicación con acce… | Homologación de Servicios  - Pago de Servicios en Ventanilla Servicios compartidos entre banco y Coppel Algun… |
| 39 | No | Pagos Programados | Pagos Programados | Proceso Batch / Interfaz | 6 | Aplicación con acce… | Dispersión de Pagos Programados de cuentas efactivas a TDC |
| 40 | No | Pagos de la Afore | Pagos de la Afore | Proceso Batch / Interfaz | 2 | Aplicación con acce… | Dispersion de pagos AFORE |
| 41 | Sí | Ordenes de Pago Nacionales | Ordenes de Pago N… | Módulo del Core | 3 | Aplicación con acce… | Envios de dinero nacionales |
| 42 | No | Motor de Pago de Remesas BTS | Motor de Pago de … | Motor / Servicio | 6 | Aplicación con acce… | Cobro de remesas BTS (Proveedor) |
| 43 | Sí | BD Usuarios de Remesas | BD Usuarios de Re… | Módulo del Core | 2 | Aplicación con acce… | Enrolamiento de usuarios para cobrar remesas El SiWEB tienen la pantalla para la captura de datos |
| 44 | No | Pago de Remesas Appriza | Pago de Remesas A… | Motor / Servicio | 1 | Aplicación con acce… | Cobro de remesas Appriza pay |
| 45 | No | Pago de Remesas WU/Orlandi/Vigo | Pago de Remesas | Motor / Servicio | 1 | Aplicación con acce… | Cobro de remesas WU/Orlandi/Vigo |
| 46 | No | Dictamen Unificado | Dictamen Unificado | Motor / Servicio | 1 | Aplicación con acce… | Obtención de productos online |
| 47 | No | RPA (Robots) | RPA | Proceso Batch / Interfaz | 2 | Aplicación con acce… | Automatización de procesos roboticos |
| 48 | No | Seguros de Repatriación | Seguros de Repatr… | Aplicación de Negocio | 1 | Aplicación con acce… | Protege a los clientes que envían remesas del extranejero en caso de fallecimiento del asegurado migrante en … |
| 49 | No | Homologación-Remesas | Homologación-Reme… | Motor / Servicio | 2 | Aplicación con acce… | Pagos de remesas Appriza Pay, BTS, WU/VG/OV otros canales |
| 50 | No | Consulta Cuentas y clientes (Coppel/ Ecomerce… | Consulta Cuentas … | Motor / Servicio | 2 | Aplicación con acce… | Consulta de cuentas validas de los clientes |
| 51 | No | Motores de Consumo de WS (RENAPO) | Motores de Consum… | Motor / Servicio | 8 | Aplicación con acce… | Motores de servicios Renapo. Aplicación con acceso al Core par conulta de configuración en el Informix |
| 52 | No | BancoppelSMS | BancoppelSMS | Motor / Servicio | 5 | Aplicación sin acce… | Servicio expuesto para mensajes SMS de dos vias |
| 53 | No | BancoppelWS | BancoppelWS | Motor / Servicio | 4 | Aplicación con acce… | Servicio de consulta de datos y tarjetas de clientes BanCoppel |
| 54 | No | Consulta Renapo | Consulta Renapo | Motor / Servicio | 2 | Aplicación sin acce… | Servicio de consulta Renapo |
| 55 | No | Strikeiron | Strikeiron | Motor / Servicio | 6 | Aplicación con acce… | Aplicación para validar correos electronicos. |
| 56 | Sí | Prevención de Fraudes (SPL) | PayTrue Solutions… | Producto de Terceros / … | 1 | consulta | Es la suite completa de soluciones orientadas a controlar el fraude desde una perspectiva emisor y adquirente… |
| 57 | No | Bus IBM | BUS IBM | Motor / Servicio | 6 | Aplicación con acce… | Los servicios desarrollados con la tecnología IBM Integration Bus tienen la finalidad de  conectar aplicacion… |
| 58 | No | Oficina Financiera Integral (OFI) | OFI | Aplicación de Canal | 12 | Aplicación con acce… | Sistema tradicional de operaciones a promotoria en sucursales |
| 59 | No | Interfaces servicios Coppel | Interfaces Coppel | Motor / Servicio | 4 | Aplicación con acce… | Son mensajes SOA para el envio de información hacia coppel para la evaluación de clientes y solicitudes. Cana… |
| 60 | No | SIWEB | SIWEB | Aplicación de Canal | 10 | Aplicación con acce… | Sistema para operaciones en ventanilla en sucursales Sistema para operaciones postventa en sucursales |
| 61 | Sí | Motor de Evaluación de Crédito | Motor de Evaluaci… | Módulo del Core | 6 | Aplicación con acce… | Sistema para evaluar las solicitudes de crédito Del lado de Operaciones (Solo SPL) La administración se hace … |
| 62 | No | App BanCoppel Móvil | APP BanCoppel | Aplicación de Canal | 20 | Aplicación con acce… | Aplicativo Móvil para Clientes de BanCoppel en el que se puede realizar Transacciones SPEI, CoDI, Pago de Ser… |
| 63 | Sí | Cobranza (SPL) | Campañas cobranza… | Core Bancario | 12 | Aplicación Nativa d… | Se tienen diferentes SPLs  para la atención de la cobranza, principalmente atención de reportes Generación de… |
| 64 | Sí | Créditos Revolventes (SPL Centrales) | Crédito Revolvent… | Core Bancario | 7 | Aplicación Nativa d… | Diferentes SPL para atención de crédito Revolvente Ejecución en linea y procesomiento batch Funcionalidad inv… |
| 65 | Sí | Créditos a Plazo  (SPL Centrales) | Crédito Plazo (SP… | Core Bancario | 7 | Aplicación Nativa d… | Diferentes SPL para atención de crédito Plazo (No Revolvente) Ejecución en linea y procesomiento batch Funcio… |
| 66 | Sí | Órdenes de Supervisión  (SPL Centrales) | Órdenes de Superv… | Core Bancario | 5 | Aplicación Nativa d… | Diferentes SPL para atención de Ordenes desupervisión Cuando se requiere visita domiciliaria a casos que requ… |
| 67 | No | SICC´s | SICC´s | Motor / Servicio | 1 | Aplicación con acce… | Consultas en linea, autenticación de  Buró y Circulo de Crédito. Demonio de Buro / Demonio Circulo |
| 68 | No | Crédito Comercial (Orión) | Orión SFI | Aplicación de Negocio | 10 | Aplicación con acce… | Gestión y seguimiento de crédito Empresarial Sistema financiero integral para administración y operacion de l… |
| 69 | No | Crédito Coparticipativo Infonavit (Hipotecari… | Hipotecario | Aplicación de Negocio | 2 | Aplicación con acce… | Seguimiento crédito Hipotecario de lo gestionado por el proveedor Hito Adquisicion de cartera de proceso de m… |
| 70 | No | Inets (servicios para Coppel) | Inets | Proceso Batch / Interfaz | 1 | Sin acceso al core | Ejecuta las Interfases para  intercambio de información y su actualización con Coppel Es la ejecución de (cli… |
| 71 | No | SPEI Enlace Financiero | SPEI | Aplicación de Canal | 8 | Aplicación con acce… | Sistema de transferencias interbancarias (BANCO DE MEXICO) Aplicativo Web en el que el area de medios de pago… |
| 72 | No | Indeval Enlace Financiero | INDEVAL | Aplicación de Negocio | 2 | Aplicación sin acce… | Sistema para el intercambio de valores en Banxico Custodio para el intercambio de valores en Banxico |
| 73 | No | Aladdin | Aladdin | Producto de Terceros / … | 1 | Aplicación sin acce… | Front Office para carga de operacioens en la tesoreria JNPL Se requiere un enlace dedicado para conectarse |
| 74 | No | ION Trading | ION Trading | Producto de Terceros / … | 1 | Aplicación sin acce… | back office para el seguimiento de las operacione de la tesoreria |
| 75 | Sí | Contabilidad | Contabilidad | Core Bancario | 1 | Aplicación con acce… | Es la aplicación del core contable la cual esta en Informix v14 y utiliza un front End de SIF en visual Basic… |
| 76 | No | BancoN RH | BancoN | Aplicación de Negocio | 3 | Sin acceso al core | Aplicativo de escritorio (cliente-servidor) Para la revision de la gestión de la Nomina. Alta de pensiones al… |
| 77 | Sí | Conciliaciones Operativo / Contables (Java+SP… | Cuentas Enlace | Proceso Batch / Interfaz | 1 | Aplicación Nativa d… | Sistema de conciliacion de cuentas enlace de la Operación de sucursales vs Central  Conciliación de operacion… |
| 78 | Sí | Administración de Faltantes y Daños a Inmuebl… | Faltantes | Aplicación de Negocio | 1 | Aplicación con acce… | Módulo del SOC (plataforma web) desarrollado en java y atendido por el proveedor TASF. Descuendo de los falta… |
| 79 | No | Facturación Electrónica CFDI  (Interfactura /… | Timbrado | Producto de Terceros / … | 1 | Solo consulta | Son plataformas que permiten hacer la certificacion fiscal digital en factura, constancias, recibos electroni… |
| 80 | No | Gastos Banco | Gastos Banco | Aplicación de Negocio | 1 | Aplicación con acce… | Aplicativo de escritorio (cliente-servidor) desarrollado en visual basic y c# Para gestionar las polizas cont… |
| 81 | No | Framework Administración | Vacaciones | Aplicación de Negocio | 3 | Sin acceso al core | Framework desarrollado en yiiframework que actualmente se accede a través de la intranet 2. Se accede tambien… |
| 82 | No | Universidad Virtual | Universidad Virtu… | Producto de Terceros / … | 1 | Sin acceso al core | Plataforma interactiva oncloud de código abierto (LMS Moodle) en infraestructura del proveedor Capacitaciones… |
| 83 | No | Pensiones alimenticias RH | Pensiones aliment… | Aplicación de Negocio | 1 | Sin acceso al core | Aplicativo de escritorio (cliente-servidor) desarrollado en C++. (Es lo mismo que BancoN) Modulo de BancoN |
| 84 | Sí | Captación | Captación | Módulo del Core | 8 | Aplicación Nativa d… | Cuentas de cheques |
| 85 | Sí | Inversiones (SPL) | Inversiones (SPL) | Módulo del Core | 6 | Aplicación Nativa d… | Calculo de pagaré |
| 86 | Sí | Canal Corresponsales Tiendas Coppel | Corresponsales Co… | Módulo del Core | 1 | Aplicación con acce… | Stored procedures de canal de corresponsales de Coppel |
| 87 | Sí | Canal Transferencias Préstamos Coppel | Prestamos Coppel | Módulo del Core | 1 | Aplicación con acce… | Stored procedures prestamos coppel |
| 88 | Sí | Cheques (SPL) | Cheques | Módulo del Core | 8 | Aplicación con acce… | Camara de compensación electronica |
| 89 | No | IVR | IVR | Aplicación de Canal | 3 | Aplicación con acce… | Canal por cual el cliente por via telefonica resuelve operaciones |
| 90 | No | Dynamics Cuentas por pagar y Presupuestos | Dynamics 365 | Producto de Terceros / … | 1 | Aplicación con acce… | En este aplicativo se realiza la gestión de presupuestos y el proceso de validación de XML de las facturas de… |
| 91 | No | Replicación de Empleados (INET) | Replicadores | Proceso Batch / Interfaz | 3 | Aplicación con acce… | Aplicativos desarrollados en diferentes lenguajes de programación que se encargan de la réplica de informació… |
| 92 | No | Monitor Web Interfaces Coppel | Monitor de interf… | Monitoreo / Herramienta | 1 | Sin acceso al core | Visualizador WEB de logs de los aplicativos replicadores, demonios, bash y SOA. |
| 93 | No | Replicadores Coppel / Bancoppel | Replicadores | Proceso Batch / Interfaz | 1 | Aplicación con acce… | Aplicativos desarrollados en diferentes lenguajes de programación que se encargan de la réplica de informació… |
| 94 | Sí? | Indicadores de Gestión Evaluación Objetiva | E-objetiva | Reporte / Regulatorio | 2 | Aplicación Nativa d… | Archivos Inidicadores de Evaluacion Objetiva Empleados y Sucursales |
| 95 | No | Data WareHouse | DWH | Proceso Batch / Interfaz | 1 | Aplicación con acce… | JOBS(ETLS). Operación Diaria, Captación, Crédito, Atms, POS, Remesas, inversiones, solicitudes, Ecommerce, Co… |
| 96 | Sí | Reportes Autoridades (Reportes Manuales) (SPL) | Reportes Regulato… | Reporte / Regulatorio | 1 | Aplicación Nativa d… | Automatizaciones para la extración de información para los Reportes de Autoridades |
| 97 | Sí | Reporte de VISA (SIF) (SPL) | Reporte de VISA (… | Reporte / Regulatorio | 1 | Aplicación Nativa d… | Modulo Reporte Regulatorio VISA Este es un repote regulatorio que estaria incluido arriba |
| 98 | Sí | Caja General (SPL) | Monitor de operac… | Módulo del Core | 6 | Aplicación con acce… | Monitor de operaciones (Muestra las operaciones de las sucursales , concentraciones, dotaciones, etc..) Modul… |
| 99 | No | Nasa Control de Expedientes de Proveedores | Provek | Producto de Terceros / … | 2 | Sin acceso al core | Para control de proveedores de grupo copppel |
| 100 | Sí | Formato IPAB (SPL) | IPAB (SPL) | Reporte / Regulatorio | 1 | Solo consulta | Genera información detallada de productos de forma anual para la autoridad IPAB |
| 101 | No | MEDALLIA | Medallia | Proceso Batch / Interfaz | 5 | Aplicación con acce… | JOBS - Archivos ATMS, Promotoria y Ventanilla  Envio de Encuestas de satisfaccion a usuarios que ocupan los 3… |
| 102 | No | REFLEXIS | Reflexis | Reporte / Regulatorio | 1 | Aplicación con acce… | JOBS(ETLS) KPIS Seguimiento_ISA_Empleado, Canal y Sucursales 2 reportes de KPIs de sucursales y empleados ban… |
| 103 | Sí | Prevención de Lavado de Dinero | MINDS | Producto de Terceros / … | 3 | Aplicación Nativa d… | Cargas de a MINDS para detactar alertas y patrones que explota el usuario SQL Y SPS Atendido por el proveedor… |
| 104 | No | Autenticador BC/CC | Autenticador BC/CC | Motor / Servicio | 1 | Aplicación con acce… | Servicio utilizado para la autenticación de clientes en solicitudes de crédito ante Buro de crédito o Círculo… |
| 105 | No | CAT Predictivo | CAT Predictivo | Motor / Servicio | 2 | Aplicación con acce… | Web services, primario y DRP Lo consume el CAT Coppel para cobranza telefonica |
| 106 | No | Rational | Rational | Producto de Terceros / … | 7 | Sin acceso al core | La solución Rational para Collaborative Lifecycle Management (CLM) ofrece integraciones de las aplicaciones C… |
| 107 | No | Prometeo - OnBase (Gestor Documental) | OnBase | Producto de Terceros / … | 9 | Aplicación sin acce… | Eficientar y digitalizar el proceso de originación de créditos a personas morales por medio de una plataforma… |
| 108 | No | Arrendadora - Sitio Web ACO | Arrendadora | Aplicación de Negocio | 1 | Aplicación sin acce… | El Sitio Web de Arrendadora Coppel, está diseñado para que potenciales clientes puedan conocer la amplia ofer… |
| 108 | No | Arrendadora - Acendes | Acendes | Aplicación de Negocio | 1 | Aplicación sin acce… | El sistema Acendes es un Saas que habilita un proceso E2E de arrendamiento puro que permite a negocio adminis… |
| 108 | No | Arrendadora - Acumatica | Acumatica | Aplicación de Negocio | 1 | Aplicación sin acce… | Acumatica ERP es sistema Saas de planificación de recursos empresariales (ERP) el cual ayuda a optimizar las … |
| 108 | No | Arrendadora - Sfleet | Sfleet | Aplicación de Negocio | 1 | Aplicación sin acce… | El servicio SFleet es un Saas que está diseñado para gestionar de forma integral las operaciones de flotas ve… |
| 108 | No | Arrendadora - doc2sign ACO | doc2sign ACO | Aplicación de Negocio | 1 | Aplicación sin acce… | La plataforma Doc2sign es un Saas que permite crear, enviar, firmar y gestionar documentos de forma digital c… |
| 108 | No | Arrendadora - doc2sign Banco | doc2sign Banco | Aplicación de Negocio | 1 | Aplicación sin acce… | La plataforma Doc2sign es un Saas que permite crear, enviar, firmar y gestionar documentos de forma digital c… |
| 109 | No | Credit Risk | Credit Risk | Aplicación de Negocio | 1 | Aplicación sin acce… | CreditRisk opera como una plataforma integral de análisis de riesgo, incluyendo: Crédito PyME y Empresarial: … |
| 110 | No | Ares - Veritran - Veribank | Ares (Veribank - … | Producto de Terceros / … | 1 | TBC | Portal web para los clientes personas morales que cuentan con cuentas ejes empresariales donde pueden realiza… |
| 111 | Sí | Administración ATM's (SPL) | Administración AT… | Módulo del Core | 3 | N/A | No es una aplicacion independiente es un Grupo de SPLs |
| 112 | No | Cajas de Abono | Cajas de Abono | Fuera de alcance | 4 | TBC | Es de Coppel |
| 113 | No | Alta Móvil | AMS | Aplicación de Canal | 6 | Aplicación con acce… | APK para levantamiento de solicitudes de crédito se mantiene como respaldo Ya evoluciona a DUD (Dictamen Unif… |
| 114 | No | Firma Autografa Digital (FAD) | Firma Autografa D… | Motor / Servicio | 1 | Aplicación sin acce… | Firma autografa digital Ya esta en Baja |
| 115 | No | Motores de Consumo de WS(INE) | Motores de Consum… | Motor / Servicio | 6 | Aplicación con acce… | motores de servicios Ine Y renapo. Esta en proceso de Baja |
| 116 | No | Calificación de Cartera / Reportes Regulatori… | Bajaware | Reporte / Regulatorio | 1 | Aplicación sin acce… | Reporteria regulatoria de empresarial (Orión) En proceso de Baja - Decomiso Fecha 1er Bimestre 2027 Los serid… |
| 117 | No | TRIAD | TRIAD | Motor / Servicio | 1 | Aplicación con acce… | Gestor de estrategias de cobranza Baja en marzo 2026 |
| 118 | Sí | Integral (modulo central) (SPL) | Captación | Módulo del Core | 10 | Aplicación Nativa d… | Stored procedures del sistema de central para cuentas de captación Baja la funcionalidad se migro al SOC |
| 119 | Sí | LIDE (SPL) | Regulatorios | Módulo del Core | 2 | Aplicación Nativa d… | Baja  La funcionalidad se migro a Risk Logic |
| 120 | Sí | Reporte de MasterCard (SOC I) | SOC I | Reporte / Regulatorio | 1 | Aplicación Nativa d… | Decomisado por el usuario |
| 121 | No | Reporte de Cierre Diario para Oficinas Admini… | Reporte de Cierre… | Fuera de alcance | 1 | Aplicación con acce… | (Ya no se ocupa) En Desuso |
| 122 | No | Sistema de Cobranza iCS | Sistema de Cobran… | Aplicación de Negocio | 4 | Aplicación sin acce… | Gestion de Cobranza En tramites para darla de baja ( En septiembre 2026 aprox) |
| 123 | No | Arrendamiento de inmuebles (Conta Oracle ) IF… | IFRS | Aplicación de Negocio | 1 | Aplicación con acce… | Sistema para hacer la integracion de la depresion del arredamiento de los bienes inmuebles arrendados de banc… |
| 124 | No | Fiduciario | Sistema Fiduciario | Producto de Terceros / … | 6 | Aplicación sin acce… | El propósito es automatizar las actividades relacionadas con la administración de los Fideicomisos de Adminis… |


## 6. Modelo de capacidades de negocio (214 N3 en 6 dominios N1)

Fuente `EXT_Modelo_Base…v2_1.xlsx` (referencia UNITY). Estructura N1 › N2 › (conteo N3):

- **Mercado y clientes** (N3=11)
  - Segmentos de clientes: 6
  - Inteligencia y conocimiento del cliente: 5
- **Distribución y canales** (N3=19)
  - Canales: 12
  - Experiencia y servicio al cliente: 7
- **Integracion y orquestacion de procesos** (N3=13)
  - Gestion de APIs y orquestacion de servicios: 4
  - Mensajeria y acceso a datos: 4
  - Gestion de transacciones y estado: 4
  - Interoperabilidad con sistemas legados: 1
- **Portafolio de productos** (N3=8)
  - Productos: 8
- **Capacidades de negocio** (N3=148)
  - Clase de producto: depósitos: 9
  - Gestión de cuentas: 17
  - Gestión documental: 4
  - Marketing: 9
  - Proceso de cuenta: 9
  - Ventas: 8
  - Servicios de inversión: 2
  - Gestión de la información del cliente: 12
  - Reportes y análisis: 7
  - Data Analytics y procesamiento de datos: 4
  - Gestión de comunicaciones: 2
  - Servicios facturables: 10
  - Transacciones: 20
  - Estado de cuenta: 6
  - Gestión de productos: 12
  - Gestion de tarjetas: 5
  - Originacion y gestion de credito: 7
  - Gestion de cobranza y reclamos: 5
- **Capacidades de soporte** (N3=15)
  - Technology Management (Gestion de Tecnologia): 7
  - Enterprise Supporting Function (Funciones de Soporte al Negocio): 8

Cobertura AS-IS (v4): **180/214** capacidades N3 con cobertura ≥ Marginal (**84.1%**); 34 Nula. La brecha mayor está en *Integración y orquestación* (microservicios/eventos = Nula; solo IBM BUS e InterAct dan cobertura real).

## 7. Mapeo capacidad N3 ↔ aplicación AS-IS (v4)

- **334 filas** capacidad×aplicación; **93** aplicaciones legadas (Anexo 5) referenciadas; **48** capacidades con sistema primario marcado.
- Escala de cobertura: **Total / Parcial / Marginal / Nula** (grado funcional).
- Columnas de desambiguación de co-cobertura: **Rol** (Motor/Decisión, System of Record, Orquestador, Canal, Formalización, Contribuyente) y **Sistema primario (S/N)** (ancla sin la cual la capacidad no existe funcionalmente).
- Distribución de filas por cobertura: Total 92 · Parcial 175 · Marginal 33 · (Nula 34 a nivel capacidad).
- Distribución por Rol: System of Record 98 · Canal 82 · Contribuyente 71 · Motor/Decisión 23 · Orquestador 18 · Formalización 8.
- Hoja de auditoría *Cambios (re-análisis)*: correcciones con estado antes/después y cita de evidencia (la más relevante: la frontera **OFI/SIWEB**, que afectó 74 procesos de sucursal).

## 8. Mini-core SOC (15 módulos · 710 funciones)

Fuente `Funcionalidades_SOC.xlsx`:

| Módulo | Funciones |
|---|---|
| MOD001 CONSULTAS | 49 |
| MOD002 SEGURIDAD | 15 |
| MOD003 OPERACIONES | 130 |
| MOD004 DÉBITO | 47 |
| MOD005 CLIENTES | 37 |
| MOD006 CREDITO | 71 |
| MOD007 CAJA GENERAL | 30 |
| MOD008 CONCILIACIONES | 46 |
| MOD009 CONTABILIDAD | 2 |
| MOD010 ATM | 11 |
| MOD011 CONSULTAS | 5 |
| MOD012 RST | 5 |
| MOD013 FALTANTES | 10 |
| MOD200 GESTOR DE SOLICITUDES | 11 |
| (sin módulo/OPERACIONES) | 241 |


## 9. Fichas técnicas sintetizadas de los 86 SUD (fuente primaria AS-IS embebida)

Cada ficha: **Objetivo · Tecnologías · Arquitectura/Integración · Bases de datos · Interfaces**, extraída del SUD correspondiente. Suficiente para fundamentar dominios, stacks e integraciones sin abrir los `.docx`.


### 1- Prevencion de Lavado de Dinero V1 0
*(SUD: `Bancoppel_SUD_1-_Prevencion_de_Lavado_de_Dinero_V1_0.docx`)*  
- **Objetivo:** El aplicativo para Prevención de Lavado de Dinero (PLD) se emplea para evitar que fondos obtenidos de actividades ilegales sean introducidos dentro de BanCoppel para legitimar ganancias ilícitas.
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- *Tecnologías:*
- *AIX*
- *Windows*
- *Informix*
- *Microsoft SQL Server*
- *Ctrl-M*
- *SFTP*
- *MINDS*
- *Herramientas:*
- *Aqua Data Studio*
- *Microsoft SQL Server Management Studio*
- *WinSCP*
- *Putty*
- *Open Office 4, (hoja de cálculo)*
- *Notepad++*
- *Filezilla*
- *Conexión a Escritorio Remoto*
- *Drawio*
- *Moba*
- **Arquitectura / Integración:** - *MINDS*
- *Se muestra el diagrama de proceso para la carga de información.*
- *Listas Negras*
- *Al ser mantenimiento mediante instrucciones SQL no hay un diagrama de arquitectura.*
- *Procesos especiales (a petición)*
- *Al ser consultas de información a la medida de las necesidades del negocio no hay un diagrama funcional.*
- **Bases de datos:** Tablas: No se cuenta con el listado completo ya que se puede acceder a prácticamente todas las tablas del banco por la naturaleza de los reportes On Demand.
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Condor controla y da mantenimiento a MINDS; el manual referenciado incluye las pantallas utilizadas.*

### 1-Motor de Pago de Remesas BTS V1 0
*(SUD: `Bancoppel_SUD_1-Motor_de_Pago_de_Remesas_BTS_V1_0.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 8
- **Tecnologías:** *Lenguaje: Java 8*
*Plataforma de desarrollo: Spring boot*
- **Arquitectura / Integración:** La arquitectura está divida en 2 partes: Operaciones por Ventanilla y Operaciones de Cobro de Remesa a Cuenta en Automático
1. ARQUITECTURA PARA OPERACIONES POR VENTANILLA…
El servicio actualmente activo está en MTY (el DRP está en CLN)…
- El motor de Remesas BTS tiene alcance en los servidores JBoss
- El motor recibe peticiones del BUS (servidores balanceados) en Json, toma dicha petición y la transforma en una petición XML a la remesadora BTS
- BTS responde con un XML mismo que recibe el Motor de Remesas BTS y con ello hace la respuesta en JSon al BUS que nos invocó.
- En consultas desde SIWEB, el BUS se comunica con Informix para obtener datos del cliente y realizar validaciones de si existe, si está en lista negra, entre otros
- El motor de remesas BTS se comunica…
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Base de Datos / Links asociados /
/ --- / --- / --- / --- /
/ bitacorabtstransqryi / Registro de consultas de remesas / Postgres / /
/ bitacorabtstranspayi / Registro de pagos de remesas / Postgres / /
/ bitacorabtstransrevi / Registro de cancelaciones de remesas / Postgres / /
/ tbl_ws_parametros / Parámetros…
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### 11 Homologación Remesas V1 0
*(SUD: `Bancoppel_SUD_11_Homologación_Remesas_V1_0.docx`)*  
- **Objetivo:** El motor de Homologación de Remesas se contempla como una aplicación concentradora de transacciones que procesa las peticiones de pago de remesas que provienen a través de dos canales principales: Las cajas de abono de Coppel y la aplicación móvil (BEX) con la mínima información requerida.
- **Tecnologías:** (Información pendiente)
- Linux RedHat
- Redhat JBoss Web Service
- IHS (IBM HTTP Server)
- PostgreSQL
- Informix
- **Arquitectura / Integración:** *Imagen 1, Diagrama de componentes de infraestructura y flujos de la información del motor Homologación de Remesas.*
Detalle del flujo de la arquitectura: El motor de Homologación de Remesas comprende los nodos enumerados dentro del gráfico desde el nodo número 4 hasta el nodo número 11. El motor o Web Service (nodos 4 y 5) exponen sus servicios sólo a través de la red interna del banco. Estos nodos son quienes identifican y deciden (a través de una consulta de parámetros en la base de datos PostgreSQL representada en el nodo 10), a cuál remesadora corresponde la transacción antes de comunicarse con el BUS en el nodo 7. La solicitud de pago de una remesa iniciada desde cualquier canal (Nodos 1 y 2) pasando por todo el flujo hasta llegar a los Web Services de las…
- **Bases de datos:** PostgreSQL: remesasweb
- Producción Monterrey: 10.27.204.130:5432
- DRP Culiacán: 10.27.28.143.5432
- Desarrollo: (información pendiente)
Informix: bdisac
- Producción Monterrey: 10.36.193.51
- DRP Culiacán: 10.36.197.51
- Desarrollo: (información pendiente)
- **Interfaces:** No aplica, el motor de Homologación de Remesas funciona como un proceso de *backend* sin intervención directa con usuarios u operadores. (Los documentos Documento de análisis Coppel y Documento de análisis Usuario presentan detalle sobre las interfaces del medio Cajas de Abono Coppel)

### 11 Tranferencia Electrónica de FondosTEF Ola4
*(SUD: `Bancoppel_SUD_11_Tranferencia_Electrónica_de_FondosTEF_Ola4.docx`)*  
- **Objetivo:** La Transferencia Electrónica de Fondos o TEF es un proceso que permite el envío y recepción de fondos entre un emisor y un receptor pudiendo ser entre distintos bancos a través de un número de referencia.
- **Tecnologías:** - Motor de Base de Datos Informix
- **Arquitectura / Integración:** / / /
/ --- / --- /
/ Imagen 1: Diagrama del flujo de la Fase de Presentación / Imagen 2: Diagrama del flujo de la Fase de Receptor /
Fase de Presentación
Esta fase del proceso consiste en la generación de un archivo en código 60 que contiene los datos de instrucción de abono a otros bancos. El archivo es procesado diariamente y en días hábiles mediante un JOB en la malla de Control M a las 18:30 horas (Horario de CDMX) que lo envía a CECOBAN.
JOBs en la Malla de Control M: Operados por el área de G producción ([gproduccion@bancoppel.com](mailto:gproduccion@bancoppel.com)), son las tareas programadas en una recurrencia específica descritas en el punto *Lista de JOBs* que internamente ejecutan
- Shell Script que en cascada llama a 
- SPL principal relacionado que es…
- **Bases de datos:** Bases de datos:
El proceso de TEF cuenta sólo con una sola Base de Datos: *bditef*. Puede complementar información con las bases de Datos bdicheq y bdicred que no pertenecen directamente al proceso TEF.
Tablas: 
/ INSTANCIA / BASE DE DATOS / TABLA / DESCRIPCIÓN /
/ --- / --- / --- / --- /
/ coppel_shm / bditef / tef_cat_devoluciones / Catálogo de los…
- **Interfaces:** No aplica para el proceso TEF

### 12 Seguros de repatriacion
*(SUD: `Bancoppel_SUD-12_Seguros_de_repatriacion.docx`)*  
- **Objetivo:** Ofrecer el producto Seguro Paisano Protegido. Es un seguro que protege a los clientes que envían remesas desde Estados Unidos o Canadá. Protege al contratante en México y al ser querido en el extranjero en caso de enfermedad o fallecimiento, incluyendo la repatriación funeraria, así como el pago de una prima en caso del fallecimiento del asegurado migrante o contratante. El servicio es operado por Cardif México seguros de Vida S. A. de C. V.
Este seguro es ofrecido al cliente cuando se cobran las remesas.
La…
- **Tecnologías:** El Equipo 1.5 tiene la tarea de filtrar y atender errores y mensajes de la plataforma para evitar escalaciones innecesarias al Nivel 2. Ejemplos incluyen manejar bloqueos de cuentas de usuario en la banca en línea canalizando las solicitudes a los equipos correspondientes, como CAD, para su resolución. El Equipo 1.5…
- **Arquitectura / Integración:** El código fuente se almacena en GitLab, que funciona como el sistema de control de versiones. El acceso a GitLab o al código fuente requiere coordinación con el área de control de cambios. Las modificaciones al código fuente implican fusionar o crear ramas para garantizar que la operación esté actualizada. No se han realizado cambios en la interfaz de guardia desde su lanzamiento, excepto por ajustes de configuración.
La lógica de la aplicación reside principalmente en el nivel web de oficina, no en el nivel de sucursal. El manejo de datos incluye interacciones directas con la base de datos, específicamente…
- **Bases de datos:** Se utiliza la base de datos PostgreSQL para mantener registros propios del aplicativo.
Se utiliza la base de datos de Informix para obtener información para la póliza y enviarla al proveedor de seguros (Cardif).
(Véase punto 9)
Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ BDCARDIF.BDCARDIF / /…

### 13 Credito Coparticipativo Infonavit  Hipotecario  20250402
*(SUD: `Bancoppel_SUD_13_Credito_Coparticipativo_Infonavit__Hipotecario__20250402.docx`)*  
- **Objetivo:** No se trata de una aplicación sino de un conjunto de procesos almacenados en Informix (SPL) que realizan la administración de créditos de coparticipación Infonavit. El producto de crédito coparticipado Infonavit ya no se oferta, por lo que ya no hay originación de nuevos créditos. Esta funcionalidad se limita a la administración de los créditos restantes.
- **Tecnologías:** Manejador de Base de datos: Informix 
SQL para Store Procedures
Para el acceso a las bases de datos, así como a los SPLs, se sugiere la aplicación Aqua Data Studio, sin embargo, se puede utilizar cualquier software que sirva para hacer tareas de administración, diseño y consulta de bases de datos.
La lectura de SPLs se puede realizar con cualquier editor de texto.
En el caso de la conexión por FTP se sugiere…
- **Arquitectura / Integración:** El proceso inicia con la transferencia de archivos del proveedor HITO a Bancoppel, lo hace mediante conexión SFTP (Puerto 22) desde la URL: [ftp1.hito.com.mx](ftp://ftp1.hito.com.mx)
Pasa por el Servidor proxy
Posteriormente llega al servidor donde se ejecutan las tareas ANSIBLE. 
La función de LATINIA es el envío de notificaciones de manera interna vía correo electrónico al usuario cada vez que terminan ciertos procesamientos que le permiten identificar al usuario si el procesamiento fue correcto o no.
Del servidor central se mandan llamar servicios o información (comunicación) de los servidores de PLD, Buró de crédito y contabilidad
Finalmente, en el servidor central es donde se realiza todo el procesamiento. Los SPLs viven en CTRL-M y son ejecutados desde ahí para…
- **Bases de datos:** Bases de datos utilizadas 
/ Nombre de Base de Datos / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ Bdicont / Contabilidad / Servidor de contabilidad / [Tablas de la BD bdicont](https://docs.google.com/spreadsheets/d/1iluHlvauWX_BFIqae2jA_yBp-cZp1XIV/edit?usp=drive_link&ouid=117296802954104352934&rtpof=true&sd=true) /
/…
- **Interfaces:** A continuación, se detallan los archivos relacionados con la administración de créditos coparticipativos Infonavit:
/ Área / CRE - Crédito /
/ --- / --- /
/ Ruta origen (HITO) / /resplogifx/hipotecario_infonavit/sics /
/ Ruta destino (Bancoppel) / /resplogifx/hipotecario_infonavit/sics /
/ Nombre del archivo / chi_cre_layout_sics_aaaammdd.txt /
/ Descripción / Archivo de insumo entregado por Hito para la generación de cinta de buró /
/ Transmitido en JOB / 905_AFT_CHI_CRE_LAYOUT_SICS_PRO /
/ Área / OPE – Operaciones /
/ --- / --- /
/ Ruta origen (HITO) / /resplogifx/hipotecario_infonavit/operaciones /
/ Ruta…

### 2-Pago de Remesas WU Orlandi Vigo V1 0
*(SUD: `Bancoppel_SUD_2-Pago_de_Remesas_WU_Orlandi_Vigo_V1_0.docx`)*  
- **Objetivo:** *En términos generales el cobro de remesas se divide en 2 partes: *
- *El front, donde se capturan los datos de las remesas. Son aplicativos como: SIWEB, app bancoppel móvil, cajas de abono -ventanilla de coppel*
- *El motor de remesas que es la interacción de banco con el proveedor *
*El fin u objetivo es que el cliente pueda cobrar remesas.*
- **Tecnologías:** *Lenguaje: Java 8*
*Plataforma de desarrollo: Spring boot*
- **Arquitectura / Integración:** *Actualmente, las operaciones están habilitadas en los servidores de MTY. *
*Su arquitectura es la siguiente:*
*La arquitectura de CLN es la siguiente:*
- El alcance del aplicativo es en el JBoss (que es donde está el motor de WU).
- El F5 es un firewall para poder filtrar lo de SIWEB.
- El IHS es un balanceador para dirigir a cada uno de los JBoss
- Servidores AIX son los balanceados por el IHS. 
- El área Operativo AIX es la hace cambios en ellos como agregar servidores al balanceo.
- En postgres se tienen los logs de todo lo que entra y sale en el motor (sea JSON del BUS -en JSON - o de las remesadoras -en XML-).
- Cuando se hace una consulta o pago de remesa se hace operación de guardado de datos. 
- En el Motor se exponen un web services, se llega con una…
- **Bases de datos:** *URL de consola para deploy en QA: *[*http://10.26.215.253:9990/console/*](http://10.26.215.253:9990/console/)* *
*USR QA: managerjboss*
*URL WU en QA: *
*https://wugateway2pi.westernunion.com/HeartBeat*
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### 24 Sistema de cobranza iCS V1 0
*(SUD: `Bancoppel_SUD_24_Sistema_de_cobranza_iCS_V1_0.docx`)*  
- **Objetivo:** Sistema de cobranza que permite manejar y administrar la cartera activa completa del banco, permite segmentar y aplicar estrategias dicha cartera. Permite la asignación de los créditos para los canales internos CAT o externos (Despachos) y realizar gestión a los clientes que estén dentro de las lógicas de cobranza mediante el CAT o cobranza domiciliaria, así como también permite parametrizar la gestión de la cobranza definiendo los límites que sean requeridos.
- **Tecnologías:** - Apache HTTP Server 2.4.54
- Tomcat 9.0.65
- JAVA
- Oracle 19c
- Genesys Engage / Navegador embebido Chromium
- **Arquitectura / Integración:** La información de los créditos que utiliza la aplicación de Cobranza iCS contenida en cuatro archivos o layout, provienen desde los sistemas del Banco y son depositados en una carpeta compartida para esta función en específico mediante un proceso en Control M en la malla que se ejecuta entre la 1:00AM y las 3:00AM. La información se extrae por diferencial de manera diaria (días del 1 al 6) y de esta manera la aplicación procesa la información de los usuarios nuevos, usuarios que realizaron pagos o cuales presentaron algún cambio en su respectivo saldo. El día 7 (lunes por la noche), se realiza una carga completa de todos los clientes y su estado actual para evitar la inactivación de estos dentro de la aplicación de Cobranza iCS (Esto debido a una parametrización…
- **Bases de datos:** Bases de datos:
Nombre de la base de datos en el servidor Oracle: icspdb
Esquemas:
- cobra
- cobra1
- collectoruser
- connectuser
- consultuser
- custom
Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ people / Tabla maestra con la información de los deudores / Información de los deudores / n/a /
/…
- **Interfaces:** Nombre: Sitio WEB aplicación Cobranza iCS, Producción.
Propósito: Aplicación Cobranza iCS
Ubicación: https://ics.bancoppel.com/iCSAuth/fsc/Login.xhtml
Descripción: Ofrece los servicios de la aplicación de Cobranza iCS a los agentes de cobranza y usuarios que administran o parametrizan la aplicación a través de una interfaz WEB dentro de la red interna de BanCoppel. 
Nombre: Sitio WEB aplicación Cobranza iCS, Desarrollo.
Propósito: Aplicación Cobranza iCS Desarrollo
Ubicación: https://ics-test.bancoppel.com
Descripción: Ofrece los servicios del ambiente de desarrollo de la aplicación de Cobranza iCS. 
Nombre:…

### 26 Risk Logic V1 0
*(SUD: `Bancoppel_SUD_26_Risk_Logic_V1_0.docx`)*  
- **Objetivo:** Sistema de administración de riesgos, aplicación institucional y automatizador de procesos que integra información para generar reportes regulatorios y normativos. Los principales usuarios de estos reportes son el área de riesgos y sus diferentes gerencias, Empresarial, Operacional, Mercado de Liquidez, Reservas y Consumo.
Las gerencias que más trabajan con la aplicación de Risk Logic son Mercado de Liquidez, Reservas y Consumo.
- **Tecnologías:** - JBoss
- Motor de cálculo R 4.2.3
- Java (servlets, jsp)
- HTML
- Javascript
- Motor de base de datos PostgreSQL
- **Arquitectura / Integración:** La aplicación de Risk Logic, sólo está expuesta dentro de la red interna del Banco y el ingreso a la misma es a través de autenticación propia de usuario y contraseña.
Sistema cliente servidor que consta de dos servidores: el servidor de aplicaciones y el servidor de bases de datos; la configuración de la arquitectura actual para esta aplicación no cuenta con alta disponibilidad. La aplicación no se considera una aplicación de alta recurrencia, sin embargo, el proveedor Unilogic señala que, aun no siendo un sistema transaccional, pueden existir archivos de gran tamaño que representan un nivel importante de carga y procesamiento para los servidores.
La información entre los servidores de la aplicación no está cifrada y la aplicación se muestra a través del protocolo…
- **Bases de datos:** Instancias de base de datos en PostgreSQL:
Se maneja sólo un esquema (riesgos), por base de datos. Las comunicaciones hacia la base de datos se realizan por el puerto 5433.
- risklogic: (Riesgos) (Esquema riesgos)
- risklogic_grc: (GRC) (Esquema riesgos)
- risklogic_datamart: (Datamart) (Esquema riesgos)
Convenciones de nomenclatura para los prefijos:
-…
- **Interfaces:** Nombre: Piplatam
Propósito: Obtener información de los precios de los instrumentos financieros
Ubicación: piplatam.com
Descripción: La herramienta consulta información de los precios de los instrumentos financieros de forma externa al sitio piplatam.com a través de una conexión SFTP y el puerto 23. La información que se consulta tiene el formato de Excel. La información consultada desde esta entidad externa se registra en la tabla ar_mdo_vector (Instancia: riesgos).
Nombre: Sitio WEB aplicación RiskLogic
Propósito: Aplicación Risk Logic
Ubicación: http://10.27.28.72:8080/RiskLogic/m/SignIn
Descripción: Ofrece…

### 3-Gestor Central Clientes
*(SUD: `Bancoppel_SUD_3-Gestor_Central_Clientes.docx`)*  
- **Objetivo:** *Es un servicio que permite la validación de huellas para clientes y empleados, la principal responsabilidad en este servicio es mantenerlo en línea para que pueda validar las huellas de los clientes y colaboradores.*
- **Tecnologías:** *Se utiliza BUS, MongoDB, PostgreSQL, INFOMIX, Node.js *
- **Arquitectura / Integración:** *La petición inicia desde OFI Tradicional o SIWEB donde a través de lectores de huella digital se necesita la autentificación de clientes y Empleados. Ahí se envía una petición para conocer si este cliente o empleado existe en los registros dentro de la base de datos en bdinteg, Si los datos enviados hacen match con los datos registrados se procede con el acceso al sistema. *
- **Bases de datos:** *Dueño del servicio no utiliza tablas en Base de datos, SP’s debido a que su principal función es el monitoreo del servicio para detectar que se encuentre online.*
Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
- **Interfaces:** *No aplica, comenta el coordinador que su función es mantener el aplicativo activo únicamente.*

### 4 Domicilizacion 20250623
*(SUD: `Bancoppel_SUD_4_Domicilizacion_20250623.docx`)*  
- **Objetivo:** No se trata de una aplicación sino de un conjunto de procesos almacenados en Informix (SPL) que realizan la domiciliación. Esta funcionalidad se limita a Domiciliación.
- **Tecnologías:** Manejador de Base de datos: Informix 
Store Procedures de SQL
Para el acceso a las bases de datos, así como a los SPLs, se sugiere la aplicación Aqua Data Studio que sirve para hacer tareas de administración, diseño y consulta de bases de datos.
La lectura de SPLs se puede realizar con el editor de texto Notepad++.
Para la conexión a los servidores se utiliza la herramienta de Putty es una aplicación de software…
- **Bases de datos:** Al ser un conjunto de procesos y no una aplicación no aplica resumen del ambiente técnico / modelo de datos de la aplicación.

### 5-Alta Movil
*(SUD: `Bancoppel_SUD_5-Alta_Movil.docx`)*  
- **Objetivo:** *Es una aplicación móvil que realiza solicitudes que permiten ofertar productos BanCoppel tales como préstamos personales, tarjetas de crédito BanCoppel, departamental Coppel desde la facilidad de los dispositivos móviles del personal de cobranza Coppel.*
- **Tecnologías:** *BUS, JAVA, Informix*
- **Arquitectura / Integración:** En la siguiente imagen se muestra información de los servidores de aplicación utilizados para la aplicación móvil.
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ INFORMIX: bdinteg: si_solicitud_movil / Se guarda la solicitud del cliente / Se utiliza como consulta de información / N/A /
/ INFORMIX: bdinteg: si_direcciones / Contiene todas las direcciones de los clientes / Se utiliza como consulta y registro de…
- **Interfaces:** *Login – El propósito de esta interfaz es permitir el acceso a la aplicación móvil con credenciales que debe tener el colaborador.*
*La siguiente interfaz muestra el menú principal que permite dar de alta una solicitud, y a su vez le da la opción de capturar la INE del cliente tal como se muestra en la imagen.*
* *
*En la siguiente interfaz una vez tomada la fotografía del INE se procede con una validación del cliente en la cual se pregunta si es cliente Coppel, en caso de que seleccione la opción NO, se procederá a llenar un formulario para poder dar de alta un cliente capturando sus datos personales.*
*Al…

### 7 Pagos Programados 20250623
*(SUD: `Bancoppel_SUD_7_Pagos_Programados_20250623.docx`)*  
- **Objetivo:** No se trata de una aplicación sino de un conjunto de procesos almacenados en Informix (SPL) que realizan los Pagos Programados. Esta funcionalidad se limita solo a Pagos Programados.
- **Tecnologías:** Manejador de Base de datos: Informix 
Store Procedures de SQL
Para el acceso a las bases de datos, así como a los SPLs, se sugiere la aplicación Aqua Data Studio que sirve para hacer tareas de administración, diseño y consulta de bases de datos.
La lectura de SPLs se puede realizar con el editor de texto Notepad++.
Para la conexión a los servidores se utiliza la herramienta de Putty es una aplicación de software…
- **Bases de datos:** Al ser un conjunto de procesos y no una aplicación no aplica resumen del ambiente técnico / modelo de datos de la aplicación.

### 9 Pago TDC otros bancos 20250410
*(SUD: `Bancoppel_SUD_9_Pago_TDC_otros_bancos_20250410.docx`)*  
- **Objetivo:** No es una aplicación, sino un conjunto de procesos (SPLs) por medio de los cuales se realiza el pago de TDC de otros bancos desde una tarjeta de débito Bancoppel o Cuenta efectiva Bancoppel.
- **Tecnologías:** Manejador de Base de datos: Informix 
Para el acceso a las bases de datos, así como a los SPLs, se sugiere la aplicación Aqua Data Studio, sin embargo, se puede utilizar cualquier software que sirva para hacer tareas de administración, diseño y consulta de bases de datos.
La lectura de SPLs se puede realizar con cualquier editor de texto.
- **Arquitectura / Integración:** Al ser un conjunto de procesos y no una aplicación no aplica resumen de arquitectura de la aplicación.
- **Bases de datos:** Base de datos: bdiprog
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ pp_pagoprog / Tabla principal de pagos programados detalle / / [Campos pp_pagoprog y pp_pagospend](https://docs.google.com/spreadsheets/d/1XBP1xYlTKzX-jcJnwpydOVYLOlS5gAK-/edit?usp=drive_link&ouid=117296802954104352934&rtpof=true&sd=true)…
- **Interfaces:** N/A. Se genera un archivo para eGlobal y SPEI, sin embargo, el proceso de pago de TDC otros bancos no es responsable de la generación o administración del archivo por lo que no se tiene el dato de dónde se guarda.

### Aclaraciones v1 2
*(SUD: `Aclaraciones_SUD_v1_2.docx`)*  
- **Objetivo:** El objetivo de la aplicación del sistema de aclaraciones en BanCoppel es gestionar y resolver de manera eficiente cualquier inconveniente que surja con las transacciones realizadas por los clientes, asegurando la continuidad operativa y la integridad de los datos en todos los entornos (desarrollo, pruebas, producción y recuperación ante desastres).
- **Tecnologías:** La arquitectura del sistema consta de bases de datos, servidores y otros componentes necesarios para la funcionalidad del sistema. Se proporcionan dos diagramas: uno para el sistema de aclaraciones para usuarios de sucursales y corporativos, y otro para el sistema CAT, que sirve como una versión alternativa para los…
- **Arquitectura / Integración:** *5.1 * *Tecnologías usadas*
La aplicación corre bajo una suite hecha en Java 8, con framework Seam para sucursal/corporativo, Hibernate 3.0.5 para la obtención de información y ZK para el CAT; y para el despliegue dentro de un servidor de JBoss 7.2.0 con un compilado en formato WAR. Dicha aplicación es en versión web, utilizando únicamente Internet explorer 8, debido a temas de compatibilidad de las versiones usadas para el desarrollo, por lo cual también va sujeta a sólo para sistemas Windows que tengan habilitado este navegador, siendo windows 7 el recomendado. Todas estas configuraciones y tecnologías…
- **Bases de datos:** El sistema interactúa con múltiples bases de datos y entornos para gestionar y procesar información. Las bases de datos clave incluyen:
- Instancia OLTP: Contiene las bases de datos principales de banca utilizadas para recuperar información relacionada con los usuarios. Esta base de datos está separada del entorno de staging.
- Instancia Staging: Todo lo…
- **Interfaces:** El equipo cuenta con capturas de pantalla tanto del sistema sucursal como del CAT para explicar el flujo de alta de aclaraciones de forma gráfica:
- Flujo Alta de aclaración en sucursal: [Pantallas Flujo Alta Aclaracion.pdf](https://drive.google.com/file/d/1mZAYb7X7NerzR8WzaIshltjWzCgxpHwc/view?usp=drive_link)
- Flujo de alta de aclaración en CAT: [CAT_InterUsr_002_PlantillaGeneral.pdf](https://drive.google.com/file/d/18Yq1-p3ik42bUgnWYgWBcvyZioTh82Db/view?usp=drive_link)

### Administracion de Tarjetas
*(SUD: `Bancoppel_SUD_Administracion_de_Tarjetas.docx`)*  
- **Objetivo:** La aplicación web MAC sirve como la plataforma principal, incorporando funcionalidades para la gestión de tarjetas y el inventario de tarjetas.
La aplicación web de tarjetas MAC opera únicamente a nivel de base de datos y no se comunica con otros sistemas, como sucursales o aplicaciones de terceros. Se utiliza para visualizar información en catálogos, consultar flujos específicos y realizar modificaciones relacionadas con el inventario de tarjetas, la detección de fraudes y las tablas de configuración para…
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*El objetivo de los proyectos en el diagrama de proyectos …*
*Añadir imágenes aquí (los links deberán ser añadidos al final de este SUD)*
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### Administracion de Tarjetas Inventario Tarjetas
*(SUD: `Bancoppel_SUD_Administracion_de_Tarjetas_Inventario_Tarjetas.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 7
- **Tecnologías:** El entorno de producción se encuentra en Monterrey, mientras que el entorno de DRP está en Culiacán. Los entornos adicionales incluyen pruebas, validación y desarrollo. El entorno de desarrollo utiliza JBoss con la dirección IP 10.26.215.168. El sistema INTERACT opera en la dirección IP 10.27.22.145, y tanto Interact…
- **Arquitectura / Integración:** El proceso de maquila de tarjetas parte de la premisa de procesar las solicitudes que se encuentran registradas en la OLTP, las cuales pueden ser generadas de forma manual, programada o automática según el canal o flujo que las detone, de esta manera se realizan las validaciones necesarias de la información contenida en cada una de ellas, con la finalidad de generar los datos necesarios que
definen y permiten crear una tarjeta, los cuales permiten originar los archivos necesarios dado cada tipo de tarjeta con un determinado layout dependiendo de la marca de la tarjeta ( VISA / MasterCard ), después a partir de datos clave de cada tarjeta, la herramienta de seguridad HSM THALES 10K y el programa de seguridad PGP se generarán los códigos de seguridad de cada tarjeta y…
- **Bases de datos:** Tablas: 
/ Documentos / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ Anexo 2 v4_SynInterCardWeb_MAC / Documentación Macweb – Maquila de Tarjetas / Dentro del documento se encuentran las BD y las tablas que integran el MacWeb y la Maquila de Tarjetas / [Anexo 2 - Formato de Aplicación Maquila de Tarjetas…
- **Interfaces:** *MacWeb, Front del Inventario de Tarjetas, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### Administración de Faltantes y Daños a Inmuebles  SPL
*(SUD: `Bancoppel_SUD_Administración_de_Faltantes_y_Daños_a_Inmuebles__SPL_.docx`)*  
- **Objetivo:** *Aplicación diseñada para gestionar deducciones de nómina, faltantes de empleados e incidentes de daños a la propiedad, con integración a sistemas internos y externos del banco.*
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
*El SOC II pude ejecutarse sobre Windows 7 y 8, con un navegador Internet Explorer 11 y Microsoft EDGE, cuenta ahora con la tecnología de:*
- *LinuxRedHat7.2,*
- *JDK(JavaDevelopmentKit)8,*
- *ServidordeAplicacionesJbossEAP7.0,*
- *Informix12.10–COREBancario,*
- *Postgres9.4.11,*
- *FrameworkZK8,*
- *FrameworkAtmosphere.*
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*La recuperación de la información se realiza utilizando Interact como medio de comunicación hacia Informix.En Postgres se concentra todo lo relacionado a la arquitectura del SOC:*
- *CatálogodeErrores.*
- *ListadodeMódulosySubMódulos.*
- *URL’sdecadaFuncionalidad.*
- *ParámetrosGenerales.*
- *Paginados.*
- *Exportados.*
*Adicional se pueden mencionar que la aplicación cuenta con los siguientes puntos:*
- *Control del máximo de funcionalidades abiertas por usuario.*
- *Estandarización y Control de Mensajes de Error con el formato Código/Descripción.*
- *Armado de menús de forma dinámica de acuerdo a los permisos con los que cuente el Usuario logeado en SOC.*
- *Uso de Huella Digital para inicio de Sesión y para confirmación de…
- **Bases de datos:** *Se puede obtener de los SPs proporcionados están en proceso.*
Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*
*Pendiente sesiones con TASF para obtener la lista de servicios.*

### Aladdin
*(SUD: `Bancoppel_SUD_Aladdin.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 7
- **Tecnologías:** Servidor: Contenedores Docker (Azure)
Aplicación cliente: Java (jnlp)
- **Arquitectura / Integración:** La aplicación está alojada en la nube de Azure y opera dentro de contenedores Docker. Tiene capacidades de escalabilidad que dependen del contrato y las solicitudes de los usuarios.
La arquitectura incluye una región principal de Aladdin y una región secundaria, que opera como una configuración espejo. El sistema está basado en la nube, asegurando una replicación continua. La conectividad se establece utilizando MPLS entre la Región 1 y la Región 2, con opciones adicionales de conectividad disponibles. La plataforma opera con soporte global las 24 horas, los 7 días de la semana. La gestión de incidentes implica activar el Plan de Recuperación ante Desastres (DRP) en el sitio alternativo, lo cual es transparente para los usuarios
La aplicación de escritorio funciona…
- **Bases de datos:** La aplicación está alojada completamente fuera de la infraestructura de Bancoppel y es gestionada por BlackRock.
- **Interfaces:** La mayor parte de las interfaces se establecen con ION Trading, a través de la generación e intercambio de archivos que se hacen en distintos horarios a lo largo del día.

### AMS OLA 3 BD Usuarios de Remesas
*(SUD: `AMS_OLA_3_SUD_BD_Usuarios_de_Remesas.docx`)*  
- **Objetivo:** Comprensión del uso de Accesos y permisos y detección de cualquier acceso adicional 4

### AMS-OLA 2-22-GUI
*(SUD: `Bancoppel_SUD_AMS-OLA_2-22-GUI.docx`)*  
- **Objetivo:** El propósito principal de la aplicación IST/GUI es actuar como la interfaz gráfica de usuario para administrar IST/Switch. Esta herramienta permite gestionar configuraciones críticas relacionadas con los módulos, grupos, unidades y aspectos de seguridad que conforman la solución.
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- **Arquitectura / Integración:** El diagrama ilustra la arquitectura del sistema IST/Switch en su función como switch transaccional, mostrando la interacción entre componentes clave que garantizan el flujo seguro y eficiente de transacciones en los cajeros automáticos. Este diseño incluye diferentes módulos y capas que permiten administrar, procesar y asegurar operaciones financieras dentro del ecosistema de BanCoppel. A continuación, se describe su estructura:
Componentes Principales del Diagrama
- Cajeros Automáticos (ATM):
 Representados en el lado izquierdo del diagrama, los ATM's son los puntos de inicio para las transacciones. Están conectados a través de redes seguras al sistema central para realizar operaciones como consultas de saldo, retiros y depósitos.
- Switch Transaccional IST/Switch:
…
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### AMS-OLA 2-23-Netxms Monitor ATM
*(SUD: `Bancoppel_SUD_AMS-OLA_2-23-Netxms_Monitor_ATM.docx`)*  
- **Objetivo:** El propósito de NetXMS en el contexto de IST/Switch es garantizar el correcto funcionamiento y la disponibilidad continua de este switch transaccional, que gestiona las operaciones de los cajeros automáticos (ATM). Su objetivo principal es proporcionar una solución proactiva para supervisar la infraestructura técnica y los servicios relacionados con el procesamiento de transacciones, asegurando que cualquier incidente que pueda impactar las operaciones sea detectado de forma temprana para minimizar…
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- **Arquitectura / Integración:** El diagrama presentado representa la arquitectura del sistema IST/Switch enfocado exclusivamente en el monitoreo y supervisión de su infraestructura. NetXMS, como herramienta de monitoreo, actúa como el núcleo central encargado de observar y analizar en tiempo real el estado de los diferentes componentes del sistema para garantizar la estabilidad y rendimiento del entorno técnico.
Componentes Principales del Diagrama
- Firewall (Protección Perimetral):
 Resguardan las conexiones hacia y desde los servidores, asegurando que solo tráfico autorizado interactúe con la infraestructura monitoreada.
- Agente NetXMS:
 Implementado en cada centro de datos, recopila métricas esenciales del hardware, software y red. Estos datos incluyen indicadores como el uso de CPU, memoria,…
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### BancoppelSMS
*(SUD: `Bancoppel_SUD_BancoppelSMS.docx`)*  
- **Objetivo:** *Mensajería sms para confirmar/rechazar por parte del usuario, también hace el registro de los mensajes para cuestiones de auditoría.*
- **Tecnologías:** - *Java EE (JAX-WS), Apache Tomcat 6 (HTTPS).*
- *Informix OLTP vía InterAct (CODBC/ICA).*
- *Innovatia (HTTP/SOAP), Internal BEX (API/WS), Latinia (BD/WS).*
- **Arquitectura / Integración:** - *Servicio SOAP “BancoppelSMS” en Tomcat.*
- *Enrutamiento: “ACEPTO/NO ACEPTO” → BEXSMSClient; otros → sp_validacion_msj (InterAct/Informix).*
- *Logs locales para auditoría y diagnóstico.*
- **Bases de datos:** - Informix Central OLTP sp_validacion_msj
- **Interfaces:** - *Innovatia (HTTP/SOAP)*
- *InterAct/Informix (conexión propietaria)*
- * Internal BEX (API/WS) *
- *Latinia (BD/WS SOAP).*

### Caja General  SPL
*(SUD: `Bancoppel_SUD_Caja_General__SPL_.docx`)*  
- **Objetivo:** *2.1. Mantenimiento de cajeros automáticos y validación de saldo cero* *5*

### CanalCorresponsalesTiendasCoppel
*(SUD: `Bancoppel_SUD_CanalCorresponsalesTiendasCoppel.docx`)*  
- **Objetivo:** Realizar operaciones bancarias por medio de las cajas de abono que se encuentran dentro de las tiendas de Coppel.
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- *Informix*
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*El objetivo de los proyectos en el diagrama de proyectos …*
*Añadir imágenes aquí (los links deberán ser añadidos al final de este SUD)*
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ bdicred:sd_tarjeta / Se guarda información de tarjetas de crédito / / /
/ bdicheq: "informix".sc_param / / / /
/ bdicheq:sc_fechas / / / /
/ bdicheq:sc_tarjeta / Se guarda información de tarjetas de debito / / /
/ bdinteg:si_fechas / Guarda la fecha de…
- **Interfaces:** *Si ya existiera documentación, proveer links*
*Items a relevar*
*Nombre Reporte*
*Descripción / Propósito*
*Generado por*
*Usuario Destino*
*Complejidad (Alta, Media, Baja)*
*Criticidad (Alta, Media, Baja)*

### CC BC
*(SUD: `Bancoppel_SUD_CC_BC.docx`)*  
- **Objetivo:** El proceso de originación de créditos implica gestionar los flujos de trabajo desde las solicitudes hasta convertirlas en créditos. Los autenticadores BC y CC son un componente menor del flujo de trabajo de las solicitudes. Otros componentes incluyen el motor de evaluación, que se encarga del proceso de calificación de las solicitudes de crédito, y el SICs, que gestiona el resto del flujo de trabajo de originación. Estos flujos de trabajo son fundamentales para la operación. 
Los canales de originación incluyen…
- **Tecnologías:** Informix
PostrgreSql
Java
Linux
Jboss
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*El objetivo de los proyectos en el diagrama de proyectos …*
*Añadir imágenes aquí (los links deberán ser añadidos al final de este SUD)*
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
Se anexa…
- **Interfaces:** / Instancia / Nombre / IP /
/ --- / --- / --- /
/ coppel_shm / bdiburo.bdisolic,bdicred, bdinteg / 10.36.197.51 /
/ coppel_shm / bdiburo.bdisolic,bdicred, bdinteg / 10.36.193.51 /
/ coppel_shm / bdiburo.bdisolic,bdicred, bdinteg / 10.27.22.176 /

### Cheques  SPL
*(SUD: `Bancoppel_SUD_Cheques__SPL_.docx`)*  
- **Objetivo:** Descripción: 
La funcionalidad es de Captación es el dinero que se capta en el banco
Es el back de muchas funcionalidades del banco y aplicativos que captan dinero. 
Las funcionalidades tienen que ver con movimientos, cuentas, intereses, comisiones, etc.
Captación se trata de funcionalidad Back End con sus reglas de negocio
Se tiene acceso a la DB de réplica de modo consulta, no se tienen permisos a ninguno de los servidores.
Criticidad: Alta
Complejidad: Alta
Lenguaje de programación: Informix, se tienen SPL's…
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*
*SOC*
*IVR*
*WhatsApp*
*Banca por Internet, entre otros*

### Cobranza  SPL
*(SUD: `Cobranza__SPL__SUD.docx`)*  
- **Objetivo:** Pasos para la Ejecución de Trabajos y Procesamiento de Archivos: 7
- **Tecnologías:** / Ambiente / Hostname / IP / SO / Carpetas compartidas /
/ --- / --- / --- / --- / --- /
/ Desarrollo / DCCDEV18 / 10.27.22.189 / AIX / NA /
/ Maqueta / TSTMAQ06 / 10.26.163.23 / AIX / NA /
/ OLTP(Réplica) / DCMSIF01/DCCSIF01 / 10.36.193.51 / AIX / /desinforenc/ /home/syscobra/ /resplogifx/ /respaldos/ /RESPALDOSNEW/…
- **Bases de datos:** Tablas: 
Servidor OLTP
La información de las tablas en este servidor se pueden ver en el siguiente documento:
[sysedocta_Matriz_de_Permisos_BD_oltp.xls](https://docs.google.com/spreadsheets/d/16yypgVxDh3tu1ltq2Ul5rZ_Ra1l3e7YX/edit?gid=1958680280#gid=1958680280)
Servidor PLD
La información de las tablas en este servidor se pueden ver en el siguiente…

### Command Center Control-M entregable para cliente 20250429 1
*(SUD: `Bancoppel_SUD_Command_Center_Control-M_entregable_para_cliente_20250429_1.docx`)*  
- **Objetivo:** Control-M es una herramienta clave para la gestión y automatización de los procesos críticos dentro del ecosistema tecnológico de BanCoppel. Su propósito principal es la programación, ejecución y monitoreo de flujos de trabajo que involucran múltiples plataformas y aplicaciones, asegurando la continuidad operativa y la eficiencia en la gestión de tareas diarias. 
Entre sus funcionalidades destacan: 
- Programación y ejecución de procesos críticos: Facilita la orquestación de tareas operativas como conciliaciones,…
- **Tecnologías:** Herramientas y Tecnologías Empleadas:
- Control-M: Utilizado para la gestión y monitoreo de procesos.
- Servidor Primario OLTP: Para la revisión de filesystems y ejecución de scripts.
- CFDI: Para el timbrado y monitoreo de facturas electrónicas.
- Sistemas de Intercambio de Archivos(Winscp/ConnectDirect)
- Bases de Datos: Para respaldos y gestión de datos.
- Ansible Tower: Para la creación y planificación de…
- **Arquitectura / Integración:** Control-M tiene la capacidad de cambiar conexiones de servidores y gestionar capas gráficas en diferentes ubicaciones, como Monterrey y Culiacán. Junto con el sistema Orion, se maneja el cierre de créditos empresariales a través de una aplicación separada de Counter Element.
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ OLTP / / Informix / /
/ Imagenes / / Informix / /
/ Contabilidad / / Informix / /
/ Paytrue / / Informix / /
/ ATM / / Informix / /
/ DAT01 / / Informix / /
/ PLD01 / / Informix / /
/ PLD02 / / Informix / /
/ LATINA / / Informix / /

### Command Center Control-M entregable para cliente 20250429 1  1
*(SUD: `Bancoppel_SUD_Command_Center_Control-M_entregable_para_cliente_20250429_1__1_.docx`)*  
- **Objetivo:** Control-M es una herramienta clave para la gestión y automatización de los procesos críticos dentro del ecosistema tecnológico de BanCoppel. Su propósito principal es la programación, ejecución y monitoreo de flujos de trabajo que involucran múltiples plataformas y aplicaciones, asegurando la continuidad operativa y la eficiencia en la gestión de tareas diarias. 
Entre sus funcionalidades destacan: 
- Programación y ejecución de procesos críticos: Facilita la orquestación de tareas operativas como conciliaciones,…
- **Tecnologías:** Herramientas y Tecnologías Empleadas:
- Control-M: Utilizado para la gestión y monitoreo de procesos.
- Servidor Primario OLTP: Para la revisión de filesystems y ejecución de scripts.
- CFDI: Para el timbrado y monitoreo de facturas electrónicas.
- Sistemas de Intercambio de Archivos: Entre Coppel y BanCoppel, Afore, y otros.
- Bases de Datos: Para respaldos y gestión de datos.
- Ansible Tower: Para la creación y…
- **Arquitectura / Integración:** Control-M tiene la capacidad de cambiar conexiones de servidores y gestionar capas gráficas en diferentes ubicaciones, como Monterrey y Culiacán. Junto con el sistema Orion, se maneja el cierre de créditos empresariales a través de una aplicación separada de Counter Element.
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ OLTP / / Informix / /
/ Imagenes / / Informix / /
/ Contabilidad / / Informix / /
/ Paytrue / / Informix / /
/ ATM / / Informix / /
/ DAT01 / / Informix / /
/ PLD01 / / Informix / /
/ PLD02 / / Informix / /
/ LATINA / / Informix / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### Command Center Entregable para cliente
*(SUD: `Bancoppel_SUD_Command_Center_Entregable_para_cliente.docx`)*  
- **Objetivo:** El Command Center de BanCoppel tiene como objetivo ser el núcleo centralizado de monitoreo y control de los servicios tecnológicos, operativos y financieros de la institución. Su función principal es asegurar la disponibilidad continua, la estabilidad operativa y el rendimiento óptimo de los sistemas críticos del banco mediante un monitoreo proactivo, en tiempo real y 24/7.
Dentro de sus responsabilidades se encuentra la observación constante de herramientas de monitoreo, como Dynatrace, ElasticSearch, Nagios,…
- **Tecnologías:** El Command Center no utiliza tecnologías propias ni desarrollo interno; su operación se basa en el uso de diversas herramientas de monitoreo ya implementadas en la organización. Estas herramientas permiten la supervisión de aplicaciones, servicios, bases de datos, infraestructura, enlaces críticos y procesos financieros.
Las herramientas utilizadas incluyen:
- Dynatrace: Monitoreo de servicios, bases de datos y…
- **Arquitectura / Integración:** Actualmente, el Command Center de BanCoppel no dispone de una arquitectura de aplicación centralizada o unificada, ya que su operación no se basa en una plataforma propia o sistema desarrollado a medida. En su lugar, funciona como un punto de convergencia operativo que integra y coordina múltiples herramientas especializadas, cada una con su propia arquitectura independiente, interfaz de acceso y lógica de funcionamiento.
Las herramientas utilizadas, como Dynatrace, Monitor Web (Interfaces), Consolas Interact, Elastic Search, Monitor de Enlaces Críticos, Monitoreo del Demonio Buró y Círculo de Crédito, entre otras, están desplegadas sobre diversas infraestructuras distribuidas y son accedidas directamente por los ingenieros a través de navegadores web u otras…
- **Bases de datos:** NO APLICA
Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** Los ingenieros del Command Center realizan monitoreo y validaciones periódicas sobre múltiples portales y servicios, con el fin de asegurar la disponibilidad de plataformas internas, externas y de terceros. Las actividades se clasifican en función del tipo de validación: disponibilidad general, pruebas operativas, monitoreo de alertas, o validaciones funcionales.
1. Validaciones operativas completas (funcionales y de notificación)
Portal BanCoppel Web (Banca por Internet)
🔗…

### Conciliación Automatica ATM  POS ereynosos Spanish-Mexico V 0 0
*(SUD: `Conciliación_Automatica_ATM__POS_ereynosos_Spanish-Mexico_V_0_0.docx`)*  
- **Objetivo:** Conciliación Automática ATM POS_ereynosos
System Understanding Document

### Consulta Renapo 20250716
*(SUD: `Bancoppel_SUD_Consulta_Renapo_20250716.docx`)*  
- **Objetivo:** Es un servicio intermedio que se encarga de conocer y comprobar la identidad de los clientes y de las sucursales cuando estos realizan una solicitud de alta de clientes a través del OFI.
- **Tecnologías:** / SoapUI /
/ --- /
/ Aqua Data Studio /
/ Java /
/ Putty /
- **Arquitectura / Integración:** Se realiza una petición desde sucursal para el registro de un cliente la cual es validada por el interact la cual la clasifica y es procesada por un motor el cual se encarga de consumir el servicio de consulta renapo , una vez dentro de este aplicativo se ejecuta un proceso que se encarga de generar un archivo xml para poder enviar una solicitud a través de un proxy a la institución de Renapo para poder validar la información del cliente.

### Contabilidad
*(SUD: `Bancoppel_SUD_Contabilidad.docx`)*  
- **Objetivo:** *Ejecución de balanza mensual.*
- **Tecnologías:** *interacción con equipo de BD, programas AIX, programas AQUA, ++, visual studio.*
- **Arquitectura / Integración:** *Revisar documentación sig. enlace.*
[https://drive.google.com/drive/folders/1PJFGhF6SZSujlAtd6hEBhxjdpYh4tqBY?usp=drive_link](https://drive.google.com/drive/folders/1PJFGhF6SZSujlAtd6hEBhxjdpYh4tqBY?usp=drive_link)
- **Bases de datos:** Tablas: 
/ Nombre de BD / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ Bdicont, Bdinteg, Bdinvers / Consulta de la tabla en la bd de datos (Replica de producción / / /
- **Interfaces:** *Concentrado de bd registradas presentada en el doc:*
[*https://drive.google.com/drive/folders/1v-YDITNOVVPXnyQvPuGri8tf887RyaHw?usp=drive_link*](https://drive.google.com/drive/folders/1v-YDITNOVVPXnyQvPuGri8tf887RyaHw?usp=drive_link)

### Contenedores
*(SUD: `Bancoppel_SUD_Contenedores.docx`)*  
- **Objetivo:** [2. Descripción de la Aplicación y Funcionalidades](about:blank)5

### Corresponsalia OXXO
*(SUD: `Bancoppel_SUD_Corresponsalia_OXXO.docx`)*  
- **Objetivo:** Contar con una herramienta que valide todas las reglas de negocio en transacciones POS (MasterCard ) dentro del aplicativo.
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- **Arquitectura / Integración:** *Recibe una transacción en ISO 8583 y realiza diferentes validaciones respecto al intercambio para la comprobación del cargo.*
Diagrama de flujo de la Aplicación
- **Bases de datos:** Tablas: 
/ Esquema / Tabla / Descripción / Campo / Tipo / Parámetros /
/ --- / --- / --- / --- / --- / --- /
/ intercard / tarjeta / Número de tarjeta / numtarjeta / varchar / 16 /
/ intercard / tarjeta / Código de estatus de tarjeta / codstatustarjeta / varchar / 3 /
/ intercard / tarjeta / Código producto tarjeta / codproductotarjeta / varchar / 3 /
/…
- **Interfaces:** Nombre Reporte: Inventario_InterActRtrSW_Octubre2024
Descripción: Inventario de Componentes
Generado por: Bancoppel Gerencia de Mantenimiento 1 – Coordinación de Tarjetas
Usuario Destino: Bancoppel - Gerencia de Mantenimiento 1 – Coordinación de Tarjetas
Complejidad: Media
Criticidad:…

### Crédito Comecial Orión
*(SUD: `Crédito_Comecial_Orión_SUD.docx`)*  
- **Objetivo:** 4.1. Infraestructura del servidor y segmentación de bases de datos 16
- **Interfaces:** El sistema Orion clasifica a las personas en tres tipos: personas físicas, personas físicas con actividades empresariales y personas morales. Operativamente, solo se utilizan dos tipos. Todas las operaciones se reflejan a nivel contable y deben integrarse diariamente. Para la apertura de líneas de crédito, el tipo de persona determina la cuenta asignada. Por ejemplo, una línea de crédito de 1,000,000 para el producto cuatro resulta en un flujo de efectivo potencial de 1,000,000, que se refleja…

### Crédito Comercial  Orión  ggguadarrama Spanish-Mexico V 0 2
*(SUD: `Crédito_Comercial__Orión__ggguadarrama_Spanish-Mexico_V_0_2.docx`)*  
- **Objetivo:** Los temas compartidos incluyen la segmentación de datos, validación, encriptación y manejo eficiente a través de múltiples tablas de bases de datos y servidores. Los procesos clave implican la generación de estados de cuenta, el procesamiento de transacciones, la gestión de cuentas vencidas y los ajustes de líneas de crédito, con servicios web predictivos que proporcionan información en tiempo real sobre saldos y…
- **Tecnologías:** Favor de proveer un breve resumen / Detalle de las configuraciones técnicas.
- **Bases de datos:** Favor de proveer un breve resumen / Detalle de las configuraciones técnicas.
- **Interfaces:** Si ya existiera documentación, proveer links
Items a relevar
Nombre Reporte
Descripción / Propósito
Generado por
Usuario Destino
Complejidad (Alta, Media, Baja)
Criticidad (Alta, Media, Baja)

### Créditos Revolventes y Créditos a Plazo - Actualizado
*(SUD: `Créditos_Revolventes_y_Créditos_a_Plazo_SUD_-_Actualizado.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 11

### DatawareHouse Reflexis 20250627
*(SUD: `Bancoppel_SUD_DatawareHouse_Reflexis_20250627.docx`)*  
- **Objetivo:** El DataWarehouse recolecta y analiza datos de diferentes fuentes, proporcionando información histórica para áreas del negocio como Captación, Créditos, ATM, Geolocalización, Pronósticos, Riesgo y Normatividad, facilitando así el análisis y la toma de decisiones.
- **Tecnologías:** / Proceso / Tecnología /
/ --- / --- /
/ ETL / *IBM InfoSphere DataStage* /
/ / *IBM InfoSphere Director* /
/ Fuentes de Información / INFORMIX – CORE BANCARIO /
/ / MONGO DB /
/ / POSTGRESQL /
/ / SQL /
/ DWH DB / NETEZZA /
- **Arquitectura / Integración:** El Data Warehouse se alimenta mediante procesos ETL desarrollados en Infosphere, integrando múltiples fuentes de información y consolidándose dentro de los modelos de datos del Data Warehouse.
*…*
- **Bases de datos:** Tablas: 
Se adjuntan archivos Excel con las tablas de las capas del DataWarehouse proporcionadas por el equipo correspondiente.
- **Interfaces:** Se listan diferentes procesos con su periodicidad de Ejecución
/ # / Proceso / Periodicidad /
/ --- / --- / --- /
/ 1 / Captación / Diario / mensual /
/ 2 / Colocación de crédito / Diario / mensual /
/ 3 / POS / Diario /
/ 4 / REFLEXIS / Diario /
/ 5 / Geolocalización (Diario) / Diario /
/ 6 / Omnicanal (Diario) / Diario /
/ 7 / Pronósticos (es parte de Reflexis) / Semanal /
/ 8 / Regulatorios Cifras Crédito Débito / A Petición /
/ 9 / Saldos Importantes / Mensual /
/ 10 / Pagarés / Diario / mensual /
/ 11 / i2Analyze / Diario /
/ 12 / Alta Cajeros (depende de Medalia) / A Petición /
/ 13 / Nómina banco / /
/…

### DB2
*(SUD: `Bancoppel_SUD_DB2.docx`)*  
- **Objetivo:** El objetivo principal de un administrador de bases de datos (DBA) de DB2 LUW (Linux, Unix, Windows) es garantizar el rendimiento, la disponibilidad, la seguridad y la integridad de las bases de datos que administra. Sus responsabilidades clave incluyen:
- Gestión del Rendimiento:
- Optimizar consultas SQL y estructuras de bases de datos para mejorar el rendimiento.
- Monitorear el uso de recursos como CPU, memoria y almacenamiento.
- Mantenimiento y Administración:
- Realizar tareas de mantenimiento como…
- **Tecnologías:** Sistema Operativo: AIX y Linux
Middleware: DB2, WAS, IBM BUS, IHS
Replicación: DB2 HADR
Monitoreo: Dynatrace, Bash Scripting
Ticketing: InvGate (Corima)
Gestión de cambios: Rational
Virtualización: OpenShift
Hardware: Power, Power HA

### Derecho ARCO
*(SUD: `Bancoppel_SUD_Derecho_ARCO.docx`)*  
- **Objetivo:** *El módulo Derecho Arco tiene el objetivo de capturar y consultar las solicitudes de Derecho Arco, emitidas por los clientes.*
- **Tecnologías:** *La misma usada en la aplicación INTRANET*
- **Arquitectura / Integración:** *La misma usada en la aplicación INTRANET*
- **Bases de datos:** *Dentro del servidor base de datos de la intranet: arco*
- **Interfaces:** *Los mismos usados en la aplicación INTRANET*

### Dynamics365 Cuentas por Pagar
*(SUD: `Bancoppel_SUD_Dynamics365_Cuentas_por_Pagar.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 7
- **Tecnologías:** Las tecnologías usadas para Producción son:
- Microsoft 365 Cloud
- Servidor Jboss
- Base de datos SQL Informix
Las tecnologías usadas para Desarrollo:
- **Arquitectura / Integración:** Como se muestra en el diagrama la infraestructura en producción está dividida en 2 bases de datos, Culiacán y Monterrey.
Para Culiacán:
- Empieza por el dominio: [DynamicsBancoppel.com](http://dynamicsbancoppel.com) 
- Se tiene una ip homologada con los siguientes datos dominio: [d1cxp.bancoppel.com](http://d1cxp.bancoppel.com), ip: 187.141.134.163
- En el tercer punto viaja por un firewall llamado Akamai por el puerto 443, el firewall encripta la ip homologada.
- Después pasa por el balanceador F5 también por el puerto 443 y esta es su ip: 10.30.26.200
- Dmz contiene el jboss de dynamics JbossMdynamics365CLN y su ip es :10.30.10.41, por el puerto 8443 
- Por último paso llega a la base de datos de Culiacan Informix la ip es: 10.36.193.81 por puerto 12525
Para…
- **Bases de datos:** DB: dbicont
Tablas:
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ co_fechas / / solo para UAT / /
/ co_param / / solo para UAT / /
/ co_poliza / / solo para UAT / /
/ co_integracion / / solo para UAT / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*
Ambiente Productivo: d1cxp.bancoppel.com
Ambiente UAT: dtestcxp.bancoppel.com

### Facturación Electrónica CFDI  Interfactura   Detecno
*(SUD: `Bancoppel_SUD_Facturación_Electrónica_CFDI__Interfactura___Detecno_.docx`)*  
- **Objetivo:** *2.1. Resumen de las plataformas Detecno e Interfactura y sus funcionalidades* *6*

### IBM BUS 20250425
*(SUD: `Bancoppel_SUD_IBM_BUS_20250425.docx`)*  
- **Objetivo:** *<Propósito principal de la aplicación>*
El objetivo principal del IBM Bus es funcionar como el canal centralizado de integración dentro del banco, permitiendo que todos los sistemas —desde canales digitales y notificaciones hasta el core bancario— se comuniquen de manera desacoplada. Según Mario, el Bus actúa como un middleware ligero que recibe, transforma y enruta cada mensaje, garantizando que la información fluya de forma consistente y monitorizada entre aplicaciones heterogéneas.
Además, con esta solución…
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
*Tecnologías del Aplicativo (IBM Bus):*
- *IBM Integration Bus (IIB)*
- *IBM MQ (canales MQ)*
- *Protocolos SOAP y REST*
- *Formatos XML, JSON y mappings XSLT y XSD*
- *Consola de administración web del Bus*
- *Dashboards de trazabilidad y monitoreo (end-to-end)*
*Tecnologías del Desarrollador/Operador:*
- *IBM Integration Toolkit (Eclipse-based IDE)*
- *IBM MQ Explorer y…
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*El objetivo de los proyectos en el diagrama de proyectos …*
*Añadir imágenes aquí (los links deberán ser añadidos al final de este SUD)*
Resumen de Arquitectura del IBM Bus
La solución de IBM Integration Bus se compone de múltiples instancias del Bus desplegadas en alta disponibilidad dentro de la red privada del banco. Cada nodo del Bus ejecuta uno o más “contextos de ejecución” (service contexts), responsables de procesar flujos de mensajes entrantes y salientes. 
Todos los mensajes SOAP, REST, MQ y JSON pasan por estos contextos, donde se aplican transformaciones (XSLT y mapeos) y validaciones de negocio antes de ser enrutados al destino correspondiente.
Sobre la capa de integración, cada instancia del Bus se realiza la…
- **Bases de datos:** Solo cuenta con conexión a la base de datos central: 10.36.197.51, instancia de imágenes: 10.36.197.82, y huellasemps: 10.28.216.132, realizando el consumo de alrededor de 1700 SPL, distribuidos en las siguientes: 
Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ bdiaclaracion / / Informix / /
/…
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*
[*https://docs.google.com/spreadsheets/d/18VIUXyruPGGY_oathwavcFA8ADKqYDr9/edit?usp=sharing&ouid=112837398349194221395&rtpof=true&sd=true*](https://docs.google.com/spreadsheets/d/18VIUXyruPGGY_oathwavcFA8ADKqYDr9/edit?usp=sharing&ouid=112837398349194221395&rtpof=true&sd=true)

### ICCAT
*(SUD: `Bancoppel_SUD_ICCAT.docx`)*  
- **Objetivo:** El sistema ICCAT es una herramienta utilizada para brindar servicio vía telefónica a través de un operador de banco, tercero o intermediario en el cual el cliente puede realizar cierta cantidad de operaciones relacionadas a sus tarjetas o productos de BanCoppel.
- **Tecnologías:** 1.- Se ejecuta el servicio de cancelación de tarjetas, enviando un mensaje de éxito.
2.- Un paso adicional requiere ejecutar un SP para finalizar la cancelación.
3.- Se envía una notificación al completar el proceso.
Las funcionalidades relacionadas con tarjetas utilizan transacciones específicas gestionadas por…
- **Arquitectura / Integración:** La arquitectura del sistema para las aplicaciones en el área de gestión 3 está diseñada para interactuar con la base de datos Informix a través de un servicio intermediario llamado INTERACT. No se permiten conexiones directas a Informix. INTERACT funciona como un mediador y se establece como una fuente de datos. Las aplicaciones en Java se conectan a INTERACT, que opera mediante transferencias de cadenas de texto.
INTERACT procesa las cadenas de texto enviadas por la aplicación. Estas cadenas pueden ser utilizadas para ejecutar procedimientos almacenados (SPS). INTERACT identifica el SP, se conecta a la base de datos central, ejecuta el SP y devuelve la respuesta por el mismo canal. No se ejecutan consultas; solo se admiten SPS.
Para las transacciones relacionadas con…
- **Bases de datos:** Nota: Dado que el sistema contiene una gran cantidad de tablas, se han integrado algunas de ellas en el siguiente formato. Asimismo, se adjunta un archivo en Excel que incluye todas las tablas existentes gestionadas por el…
- **Interfaces:** Se comparte imagen relacionada a las interfaces que opera el sistema ICCAT

### Indeval Enlace Financiero
*(SUD: `Bancoppel_SUD_Indeval_Enlace_Financiero.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 7
- **Tecnologías:** Aplicación: Java, JBoss Application Server 
Manejador de base de datos: PostgresSQL
- **Arquitectura / Integración:** Indeval funciona como intermediario entre las contrapartes, procesando transacciones como ventas y compras. Por ejemplo, el Participante 1 (por ejemplo, BanCoppel) vende acciones al Participante 2 (por ejemplo, Banorte). Indeval actúa como la institución depositaria de valores, reteniendo fondos de ambos participantes y transfiriéndolos entre cuentas.
Indeval gestiona la transferencia de dinero y activos entre los participantes. Todas las solicitudes se procesan a través de servicios web encriptados. El enlace financiero envía servicios web al adaptador, que a su vez reenvía las solicitudes a Indeval. Un cambio reciente implicó convertir la comunicación de HTTP a HTTPS. Estos servicios están integrados dentro del adaptador y se envían a Indeval.
Seguridad de TI…
- **Interfaces:** El intercambio de archivos ocurre a nivel intermedio, con la comunicación facilitada a través de Ion Trading. Archivos, como datos de cuentas en formato XML, se cargan manualmente o mediante XML para mayor eficiencia. El proceso de carga no está automatizado y requiere la acción del usuario para completarse.
El proceso implica intervención manual para el manejo de datos y el procesamiento de transacciones. Los usuarios descargan datos de Ion Trading, los integran en Indeval, los cargan y luego inician el flujo de trabajo en Indeval. La funcionalidad de la aplicación requiere validación y acción humana para…

### Integral modulo central 20250425
*(SUD: `Bancoppel_SUD_Integral_modulo_central_20250425.docx`)*  
- **Objetivo:** *<Propósito principal de la aplicación>*
El objetivo del sistema CIF es gestionar y actualizar las tasas de manera eficiente y precisa, asegurando la continuidad operativa de procesos críticos como aperturas de cuentas y pagos de intereses, mientras se minimizan riesgos legales y operativos asociados a errores en las actualizaciones.
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
*Lenguaje de Programación:*
*Visual Basic: El código fuente de las funcionalidades del sistema SIF está escrito en este lenguaje. Es una tecnología antigua que se utilizaba ampliamente para desarrollar aplicaciones de escritorio.*
*Interfaz de Usuario:*
*Archivo .exe: La interfaz del sistema se accede a través de un archivo ejecutable (.exe), lo que indica que es una…
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*El objetivo de los proyectos en el diagrama de proyectos …*
*Añadir imágenes aquí (los links deberán ser añadidos al final de este SUD)*
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ si_tasavlor / Tasa por rangos / / /
/ si_fechavalor / Tasa fija / / /
/ si_tiptasa / Es para el tipo de tasa / / /
/ si_histrango / Es una copia histórica de los datos de si_tasavlor. / / /
/ si_tasavlor / utiliza si_tiptasa para validar que una tasa…
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre qué aplicaciones interactúa*

### Interact Router 20250429
*(SUD: `Bancoppel_SUD_Interact_Router_20250429.docx`)*  
- **Objetivo:** *Proporcionar una infraestructura cliente-servidor que permita establecer un mecanismo de interacción en línea y en tiempo real entre aplicaciones distribuidas en diferentes infraestructuras de cómputo. Así mismo permitir el envío y recepción de mensajes de programa a programa, ruteando los mensajes entre los clientes y los servidores de manera automática*
- **Tecnologías:** *Las herramientas y tecnologías empleadas para el funcionamiento del Interact Router, son las siguientes:*
- *Glibc*
- *OpenSSL*
- *JDk de Java 1.8*
- *Cliente Informix*
*El detalle de estas tecnologías se encuentra en la sección “Software Requerido” en ese mismo documento.*
- **Arquitectura / Integración:** *Interact Router funciona principalmente como un servidor en la mayoría de las aplicaciones, facilitando la comunicación cliente-servidor. El cliente se conecta al servidor, envía transacciones, y el Interact Router las dirige a un sistema o base de datos de destino. *
*El Interact Router procesa la información entrante interpretando la cadena recibida y la dirige sin realizar procesamiento adicional.*
*La base de datos asociada con el Interact Router suele ser Informix, aunque su uso depende de la aplicación que se conecte a Interact. *
*Las transacciones llevan parámetros que identifican su destino, ya sea una base de datos o un sistema destino, y la interacción se realiza en función de estos parámetros. Interact Router opera como un sistema de mensajería de…
- **Bases de datos:** *El listado de tablas que utiliza el aplicativo se encuentra en la sección “Inventario de Tablas” de este documento*
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
*El aplicativo también utiliza una serie de stored procedures para su funcionamiento, el listado…
- **Interfaces:** *El aplicativo al ser una solución middleware no cuenta con interfaces.*

### Interact SW Autorizador
*(SUD: `Bancoppel_SUD_Interact_SW_Autorizador.docx`)*  
- **Objetivo:** Contar con una herramienta que valide todas las reglas de negocio en transacciones POS dentro del aplicativo.
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- **Arquitectura / Integración:** *Recibe una transacción en ISO 8583 y realiza diferentes validaciones respecto al intercambio para la comprobación del cargo.*
Diagrama de flujo de la Aplicación
[^c1]
- **Bases de datos:** / 10.26.162.24 / Producción / Informix /
/ --- / --- / --- /
/ 10.36.193.64 / Réplica de producción / Informix /
/ 10.27.22.145 / Desarrollo / Informix /
Tablas: 
/ Esquema / Tabla / Descripción / Campo / Tipo / Parámetros /
/ --- / --- / --- / --- / --- / --- /
/ intercard / tarjeta / Número de tarjeta / numtarjeta / varchar / 16 /
/ intercard / tarjeta /…
- **Interfaces:** Nombre Reporte: [Inventario_InterActRtrSW_Octubre2024.xlsx](https://ts.accenture.com/:x:/r/sites/TransicinAMSBanCoppelOla2/Shared%20Documents/AMS%20Ola%202/Documentaci%C3%B3n%20N2/Documentos%20Generales/8-Interact%20SW%20Autorizador/Inventario_InterActRtrSW_Octubre2024.xlsx?d=w93f6a764c4b44f87aacfd07f5799504e&csf=1&web=1&e=jauoyJ)
Descripción: Inventario de Componentes
Generado por: Bancoppel Gerencia de Mantenimiento 1 – Coordinación de Tarjetas
Usuario Destino: Bancoppel - Gerencia de Mantenimiento 1 – Coordinación de Tarjetas
Complejidad:…

### Inversiones
*(SUD: `Bancoppel_SUD_Inversiones.docx`)*  
- **Objetivo:** Proporcionar la lógica de negocio al producto de captación de crédito de Inversión creciente.
- **Tecnologías:** El aplicativo consiste de un conjunto de SPLs que hacen los cálculos del producto inversión creciente.
- **Arquitectura / Integración:** El producto se administra por medio de SIWEB y cuya lógica de negocio se encuentra programada en SPLs para el cálculo de intereses, apertura, provisionamiento y cierre.
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ sc_maechq / Tabla principal cuentas / / /
/ sc_maenoc / Tabla para cuentas de inversión / / /
/ sc_tasa_variable / Tabla con la información de provisionamiento de intereses mensual de cada inversión / / /
/ sc_tasa_varhist / Histórico de tasa variable /…
- **Interfaces:** bdicheq Base de datos cuentas de cheques en informix.

### ION Trading
*(SUD: `Bancoppel_SUD_ION_Trading.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 7
- **Tecnologías:** Aplicación: Progress
Manejador de base de datos: Oracle
- **Arquitectura / Integración:** El entorno de producción utiliza el servidor de aplicaciones conectado a las bases de datos. La aplicación Ion requiere una base de datos PROGRESS, pero los requisitos regulatorios exigen una base de datos SQL. Se establece una conexión desde la base de datos SQL, específicamente Oracle, utilizando un intermediario que traduce los datos entre sistemas. El entorno de producción está ubicado en Monterrey, mientras que el entorno DRP se encuentra en Culiacán.
Las transacciones que se capturan en Aladdin se comparten a través de un SFTP como paquetes de archivos XML llamados nuggets. Cada paquete puede incluir desde una hasta veinte transacciones. La comunicación entre Aladdin e Ion Trading se realiza a través de un servidor SFTP intermediario, conocido como BlackRock…
- **Bases de datos:** El servidor de aplicaciones opera en Windows, el servidor de pasos funciona en Linux, y el servidor de base de datos está basado en AIX, alojando Oracle.
Los registros de compilación son generados por el área del servidor y se envían a través del proceso de control de cambios durante los lanzamientos
- **Interfaces:** Las transacciones que se capturan en Aladdin se comparten a través de un SFTP como paquetes de archivos XML llamados nuggets. Cada paquete puede incluir desde una hasta veinte transacciones. La comunicación entre Aladdin e Ion Trading se realiza a través de un servidor SFTP intermediario, conocido como BlackRock Paso. Este servidor actúa como un puente, permitiendo el flujo de transacciones entre las dos aplicaciones.
Otro proveedor, PIP, suministra precios diarios y vectores para instrumentos de tesorería, los cuales se descargan del servidor del proveedor y se cargan en Ion.
- La mayor parte de las interfaces…

### IPAB Formato Regulatorio
*(SUD: `Bancoppel_SUD_IPAB_Formato_Regulatorio.docx`)*  
- **Objetivo:** *El SOC (Sistema Operativo Central) cuenta con dos funcionalidades del IPAB (Instituto de Protección al Ahorro Bancario), que es la automatización del marcaje de las causales de revisión y exclusión para efectos del IPAB, es decir, cuenta con la capacidad de realizar la Generación de reportes Marcaje IPAB y la Marcación IPAB.*
*Así mismo, la aplicación asigna etiquetas a cuentas y clientes basándose en causas, exclusión y revisión por parte del IPAB. Permite que los clientes sean eliminados del módulo cuando…
- **Tecnologías:** *El SOC II puede ejecutarse sobre Windows 7 y 8, con un navegador Internet Explorer 11 y Microsoft EDGE, cuenta ahora con la tecnología de:*
- *Linux RedHat 7.2,*
- *JDK(Java Development Kit)8,*
- *Servidor de Aplicaciones Jboss EAP 7.0,*
- *Informix 12.10–CORE Bancario,*
- *Postgres 9.4.11,*
- *Framework ZK8,*
- *Framework Atmosphere.*
- *Java*
- **Arquitectura / Integración:** *La recuperación de la información se realiza utilizando Interact como medio de comunicación hacia Informix. En Postgres se concentra todo lo relacionado a la arquitectura del SOC:*
- *Catálogo de Errores.*
- *Listado de Módulos y SubMódulos.*
- *URL’s de cada Funcionalidad.*
- *Parámetros Generales.*
- *Paginados.*
- *Exportados.*
*Adicional se pueden mencionar que la aplicación cuenta con los siguientes puntos:*
- *Control del máximo de funcionalidades abiertas por usuario.*
- *Estandarización y Control de Mensajes de Error con el formato Código/Descripción.*
- *Armado de menús de forma dinámica de acuerdo a los permisos con los que cuente el Usuario logueado en SOC.*
- *Uso de Huella Digital para inicio de Sesión y para confirmación de algunos procesos.*
-…
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ bdinteg:si_cliente / Módulo Integral / Nos encontramos a la espera de la respuesta de BanCoppel / /
/ bdinteg:si_ctepf / Módulo Integral / Nos encontramos a la espera de la respuesta de BanCoppel / /
/ bdinteg:si_excluidosipb / Módulo Integral / Nos…
- **Interfaces:** *El propósito de esta interfaz es permitir el acceso a las funcionalidades IPAB para poder realizar la Generación de reportes Marcaje IPAB y el Marcaje de Causales de Exclusión y Revisión que se encuentra dentro del SOC.*

### Kibana Monitor
*(SUD: `Bancoppel_SUD_Kibana_Monitor.docx`)*  
- **Objetivo:** *Kibana es un front-end al cual se accede desde Internet mediante un navegador web 1 . Permite monitorear las transacciones del cliente en NRT (Near Real Time), es decir, con aproximadamente 1-3 minutos de diferencia respecto a la Línea.*
- **Tecnologías:** *El acceso a la herramienta Kibana será ingresando a la URL que fue compartida por eGlobal*
- **Arquitectura / Integración:** *La aplicación es de un proveedor y solo se usa para monitorear porcentajes de transacciones y declinaciones. Toda la infraestructura de la aplicaciones está de su lado, Bancoppel solo es usuario. *
- **Bases de datos:** N/A
Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /

### KT OLA4 AutenticacionDeTokenRSA
*(SUD: `Bancoppel_SUD_KT_OLA4_AutenticacionDeTokenRSA.docx`)*  
- **Objetivo:** La aplicación Autenticación de Token RSA proporciona autenticación segura mediante tokens físicos y digitales para operaciones bancarias en línea y corporativas. Su objetivo principal es validar usuarios y tokens a través de un servicio web conectado a la consola RSA, garantizando seguridad mediante encriptación y certificados.
- **Tecnologías:** Sistema operativo Red Hat 8, JBoss 7.2, Java 1.8. Se planea actualización a JBoss 8 y Java 21. Encriptación AES-256, estructura SOAP, certificados digitales.
- **Arquitectura / Integración:** La arquitectura incluye un servicio web RSA desplegado en JBoss, conectado a consolas RSA. Utiliza archivos WAR, configuraciones en carpetas RSA Resources, y certificados para conexión segura.

### MDL
*(SUD: `Bancoppel_SUD_MDL.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 7
- **Tecnologías:** *Se hace uso de Herramientas de análisis de entornos basados en Java, MQ Explorer para gestión de colas, GenWizard , Dynatrace y Nagios Para monitoreo*
- **Arquitectura / Integración:** *Ibm WebSphere MQ*
*IBM WebSphere Aplication Server*
*IBM Integration Bus*

### Monitor de Operaciones BPI
*(SUD: `Bancoppel_SUD_Monitor_de_Operaciones_BPI.docx`)*  
- **Objetivo:** *Monitoreo de las transacciones de banca por internet, a partir de un portal web, la finalidad de Monitor de Operaciones BPI es proporcionar una herramienta de análisis de casos para la operación de BPI así como revisión de peticiones anormales.*
*.*
- **Tecnologías:** - *Java (aplicación empaquetada como MonitorRest.jar, estilo Spring Boot).*
- *Servidor de apps/host: Linux (RHEL 8.6), entorno JBoss/Java.*
- *Base de datos: PostgreSQL.*
- *Notificaciones: correo (plantilla EmailTemplate.html).*
- **Arquitectura / Integración:** - *Aplicación web accesible bajo http://<host>:9082/Monitor/ con módulos de consulta y administración.*
- *Servicios REST/Controladores consultan PostgreSQL según filtros de usuario.*
- *Parámetros operativos configurables desde el propio módulo de Configuraciones y archivo configDB.properties.*
- **Bases de datos:** - PostgreSQL: apertura_web en 10.27.204.221:5432.
- **Interfaces:** - *Base de datos PostgreSQL (lectura/consulta).*
- *SMTP/Correo (plantilla EmailTemplate.html, parámetros en Configuraciones).*

### Motor de Pago de Remesas Appriza Pay 20250811
*(SUD: `Bancoppel_SUD_Motor_de_Pago_de_Remesas_Appriza_Pay_20250811.docx`)*  
- **Objetivo:** El objetivo principal de la aplicación es automatizar y gestionar eficientemente las tareas programadas relacionadas con el servicio de pago de remesas. Esto incluye la migración de información entre sistemas, la generación de reportes operativos y regulatorios, la actualización de estatus de remesas retenidas, así como la ejecución de procesos de liberación y conciliación de remesas. Estas funcionalidades permiten mantener la integridad operativa del sistema, asegurar la trazabilidad de las transacciones y…
- **Tecnologías:** Las tecnologías usadas son las siguientes:
- Shell scripting
- Informix SQL (Stored procedures)
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** / Proceso / SP / Base de datos / Link /
/ --- / --- / --- / --- /
/ 244_BTS_MOVSPASO_PRO / sac_bts_movspaso / bdisac / /
/ 316_CONCILIACION_TOTAL_CONVENIO_PRO / sp_insertaconciliaciontotalporconvenio / bdisac / /
/ 361_REMESAS_BTS_SISTEMA_PLD_PRO / sp_remesasbts_pld / bdisac / /
/ 363_REMESAS_WU_SISTEMA_PLD_PRO / sp_remesaswu_pld / bdisac / /
/ 364_ODP_SISTEMA_PLD_PRO / sp_odp_pld / bdisac / /
/ 375_REPORTE_WU_REMESAS_NO_CONCILIADAS_PRO / sp_sac_insertaremesasnoconciliadaswu / bdisac / /
/ 398_REPORTE_MOVTOBTS_PRO / sp_repormovhistbts / bdisac / /
/…

### Motor de Pago de Servicios v1 0
*(SUD: `Motor_de_Pago_de_Servicios_SUD_v1_0.docx`)*  
- **Objetivo:** / Versión del documento: / 0.1 /
/ --- / --- /
/ Fecha de documentación: / 12 de agosto de 2025 /
- **Tecnologías:** La aplicación corre bajo una suite hecha en Java 7, y en el caso de los motores que son desplegados en servidores JBoss y Tomcat..
Con respecto a la Base de datos, utilizan una base de datos relacional hecha en Informix para las bases de datos que tengan que ver con el core bancario y PostgreSQL para el tema de las remesas. 
Todo esto está montado en servidores Linux, con distribución Debian 7, 8 y 10, y Red Hat…
- **Arquitectura / Integración:** La sección de Dish está alojada en el servidor. La IP principal de Dish en Monterrey es 102.62.164.6 (para más información ver tabla 1 de la sección 3).
La dirección IP mencionada forma parte de la infraestructura localizada en Monterrey y no está asociada directamente con el servidor dedicado de Dish. En cuanto al proceso de las transacciones relacionadas con los pagos del servicio de Dish, este sigue una serie de pasos específicos. Primero, el cliente realiza el pago en el mostrador de la sucursal correspondiente. Una vez efectuado, la información del pago se transmite al servidor dedicado de Dish, donde se identifica mediante los motores especializados que Dish tiene implementados para este propósito. Posteriormente, la transacción se registra en la base de datos…
- **Bases de datos:** La base de datos utilizada principalmente es la BDISAC, que se enfoca al control de acceso. La base de datos incluye tablas para movimientos, específicamente “sacmovimientos” que contiene los movimientos de pagos de hoy. Los movimientos históricos se almacenan en una tabla separada, cubriendo datos desde el día…
- **Interfaces:** Aunque los diferentes motores son invocados a través de sucursal, banca por internet y aplicación móvil, no se maneja directamente dichas interfaces, lo cual no aplica directamente dentro del apartado de motores.

### Motor Evaluacion de Crédito
*(SUD: `Bancoppel_SUD_Motor_Evaluacion_de_Crédito.docx`)*  
- **Objetivo:** El aplicativo se trata de las Evaluaciones de Solicitudes de Crédito realizadas por ciertos aplicativos. 
Antecedentes:
Antes del motor[^0] había un proceso de solicitudes de Evaluaciones de Crédito dentro del Core Bancario, el cual implementaba las reglas de negocio mediante SPLs.
Ahora, con la implementación del motor (BRM), invocado por medio de un web service, se están brincando varios de esos flujos y las dictaminaciones de los estatus de las solicitudes de crédito se están yendo hacia este nuevo motor. 
Es…
- **Tecnologías:** - Informix (SPLs)
- Software Requerido:
/ Nombre del software / Versión /
/ --- / --- /
/ SOAP UI / 5.2.1 /
/ POSTMAN / 11.53 /
/ UltraVNC Viewer* / 1.2.2.3 /
/ WinSCP / 5.7.5 /
/ Aqua Data Studio / 4.7.2 /
/ NotePad++ / 8.5.5 /
/ Putty / 0.77 /
*es para acceder de manera gráfica en el servidor, se comenta que es gratuito.
- **Arquitectura / Integración:** La ejecución de BRM depende de dónde se haga el llamado, la mayoría de peticiones vienen del Canal 1 (tienda) y Canal 4 (DUD). Las “reevaluciones” son de Mesa de Control y provienen del aplicativo SOC.
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción /
/ --- / --- /
/ bdisolic:ss_solicitudes / Tabla de solicitudes, tabla maestra que contiene el estatus de las solicitudes /
/ bdisolic:ss_status_sol / Tabla de catálogo de las solicitudes existentes /
/ bdisolic:ss_canales_solic / Tabla de catálogo de canales existentes /
/ bdisolic:ss_enviossolicitudesmotor /…
- **Interfaces:** Se comenta que para este aplicativo no se usan EndPoints. Hay un web service que no llevamos, solo se comenta que existe por conocimiento general. Este WS no nos invoca directamente a nuestros SPLs, sino que invoca a otro WS intermedio (el cual tampoco somos propietarios) e invoca finalmente a nuestros SPLs 
Existe otro WS de BRM, cuando hay incidencias nos reúnen tanto a nosotros (como responsables de los flujos de Originación) como a Coppel (como responsables del WS BRM) y ahí se determina quien atiende con base en la afectación.[^3]

### Motor Huellas
*(SUD: `Motor_Huellas_SUD.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 118
- **Tecnologías:** *Aqua data, SoapUI, putty, notpad, winscp, hoja de calculo*
- **Arquitectura / Integración:** *No disponible.*
- **Bases de datos:** *Las bases de datos son:*
- *Bdinteg*
/ *Tablas* / *Store procedures* /
/ --- / --- /
/ si_huella_linea / sp_consultahuelladeclinea /
/ si_huella_linea_resultado / sp_consultatickethuelladec_or /
/ si_huella_linea_dec / sp_generahuellalinea /
/ si_huella_linea_dec_result / sp_generahuellalinea_chl /
/ si_huella_linea_hist / sp_generahuellalinea_outbound…
- **Interfaces:** *Solo aplica para base de datos, ya existe inventario y se encuentra en la siguiente dirección: *
[https://docs.google.com/spreadsheets/d/1c8h-4f8MGyovXXmxAxkDu7l1H0AHD_cN/edit?pli=1&gid=1048237299#gid=1048237299](https://docs.google.com/spreadsheets/d/1c8h-4f8MGyovXXmxAxkDu7l1H0AHD_cN/edit?pli=1&gid=1048237299#gid=1048237299)
*[Pestaña control de Accesos]*

### Motor Rostros
*(SUD: `Motor_Rostros_SUD.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 66
- **Tecnologías:** *Aqua data, SoapUI, putty, notpad, winscp, hoja de calculo*
- **Arquitectura / Integración:** *No disponible.*
- **Bases de datos:** *Las bases de datos son:*
- *Bdinteg*
/ *Tablas* / *Store procedures* /
/ --- / --- /
/ si_rostro_linea / sp_guardar_rostro_cte /
/ si_rostro_linea_result / sp_guardar_rostro_cte_TRACE /
/ si_rostro_linea_hist / sp_consultarostroslinea_pa /
/ si_rostro_linea_result_hist / sp_estatusrostrolineaenvio /
/ si_rostro_linea / sp_estatusrostrolinearespuesta /
/ /…
- **Interfaces:** *Solo aplica para base de datos, ya existe inventario y se encuentra en la siguiente dirección: *
[https://docs.google.com/spreadsheets/d/1c8h-4f8MGyovXXmxAxkDu7l1H0AHD_cN/edit?pli=1&gid=1048237299#gid=1048237299](https://docs.google.com/spreadsheets/d/1c8h-4f8MGyovXXmxAxkDu7l1H0AHD_cN/edit?pli=1&gid=1048237299#gid=1048237299)
*[Pestaña control de Accesos]*

### Motores de Consumo de WS
*(SUD: `Motores_de_Consumo_de_WS_SUD.docx`)*  
- **Objetivo:** 2.2. Propiedades de conexión del motor y entorno de prueba 14
- **Tecnologías:** Diagrama INE
Diagrama Renapo
- **Bases de datos:** Diagrama INE
Diagrama Renapo
- **Interfaces:** Tablas de BD:
- mc_codigoretorno
- mc_estadistica
- mc_estadistica_proc
- mc_iac_trans_campos
- mc_iac_transaccion
- mc_operaciones
- mc_parametros
- mc_sp_central
- mc_sp_central_campos
- mc_web_service

### OFI
*(SUD: `Bancoppel_SUD_OFI.docx`)*  
- **Objetivo:** OFI (Gerencia de Mantenimientos II) su función principal es alta de clientes nuevos como ofertar productos de captación y crédito. Para obtener crédito de Coppel y BanCoppel.
Adicional, incluye: Mantenimiento de huellas, impresión de contratos, consulta de cliente, consulta de expediente.
Productos Impactados: Préstamo Personal, TDC, TDD, Prestamos Coppel, Club de Protección. Tarjeta departamental.
Criticidad: Alta. Actualmente es uno de los sistemas más estables pero que requiere mantenimientos, es de los más…
- **Tecnologías:** Las IPs son las siguientes:
OLTP Productiva: 10.36.197.51 MTY
OLTP Replica: 10.36.193.51 CLN
DB de Imágenes Productiva: 10.36.197.82 MTY
DB de Imágenes Replica: 10.36.193.82 CLN
Servidores Interact de datos de centrales (OLTP) - PRODUCCION
- 10.36.197.155 
- 10.36.197.135 
- 10.36.197.136 
- 10.36.197.91
Servidores…
- **Arquitectura / Integración:** Los clientes ejecutan la aplicación en cada sucursal, a su vez en cada sucursal cuenta con una base de datos PostgreSQL, esta DB no NO es compartida entre sucursales.
El objetivo de la DB de PostgreSQL es contar con información que se obtiene de la OLTP de una manera expedita. Esto de la siguiente manera:
- Cuando se obtiene información del cliente, se consulta primero el servidor de PostgreSQL, si no se tienen los datos (que es la primera consulta) pasa al paso siguiente (si existe información del cliente, de aquí la toma),
- El aplicativo busca los datos del cliente en Informix (OLTP), la respuesta se devuelve al cliente y además se insertan en PostgreSQL.
- En una llamada subsecuente del cliente a la OLTP, primero se valida si se tiene la información en PostgreSQL…
- **Bases de datos:** Algunas tablas relevantes son…
- **Interfaces:** *Se invocan Web services siguientes…*
/ Empresa / Código / Producción / Desarrollo / Comentarios /
/ --- / --- / --- / --- / --- /
/ 1 / API_VERIFICA_CTE / http://10.30.14.14:7803/v1/huellas/clientes / http://10.27.27.20:7816/v1/huellas/clientes/ / RUTA DE API PARA VERIFICACION DE CLIENTES /
/ 1 / API_VERIFICA_EMP / http://10.30.14.14:7803/v1/huellas/empleados / http://10.27.27.20:7816/v1/huellas/empleados/ / RUTA DE API PARA VERIFICACION DE EMPLEADOS /
/ 1 / SW_INE_40_ENDPOINT / http://10.27.31.14:7841/bancoppel/INE / http://10.27.22.190:7807/bancoppel/INE / EndPoint SW INE 4.0 /
/ 1 / SW_INE_FACIAL /…

### Ola3 8 Pago de la afore 20250604
*(SUD: `Bancoppel_SUD_Ola3_8_Pago_de_la_afore_20250604.docx`)*  
- **Objetivo:** No es una aplicación, es una funcionalidad, en donde Afore Coppel envía un archivo con las cuentas y montos que se deben abonar a los beneficiarios. Lo anterior se hace mediante un conjunto de procesos almacenados (SPLs) los cuales realizan de forma automática el pago a las cuentas indicadas.
- **Tecnologías:** Manejador de Base de datos: Informix 
Para el acceso a las bases de datos, así como a los SPLs, se sugiere la aplicación Aqua Data Studio, sin embargo, se puede utilizar cualquier software que sirva para hacer tareas de administración, diseño y consulta de bases de datos.
La lectura de SPLs se puede realizar con cualquier editor de texto.
- **Arquitectura / Integración:** Al ser un conjunto de procesos y no una aplicación, no existe una arquitectura de la aplicación.
- **Bases de datos:** Base de datos: bdiprog
/ Nombre de tabla / Descripción /
/ --- / --- /
/ pp_arch_afore / Contiene el nombre de archivo existente, o cargado, tipo de archivo, fecha en que se generó, fecha en que se procesó, estado, usuario y fecha de inserción /
/ pp_encabezado / Contiene nombre del archivo, tipo de registro y la información del encabezado del archivo /
/…
- **Interfaces:** A continuación, se nombran los archivos que participan en la funcionalidad de pagos de la Afore.
/ Nombre archivo / Propósito / Ubicación /
/ --- / --- / --- /
/ PAGOSDDMMAAAA.OBACOPPEL.01 / Archivo que contiene los pagos de la afore que deben realizarse a otros bancos / Home/sysafore /
/ PAGOSDDMMAAAA.ACOPPEL.01 / Archivo que contiene los pagos de la afore que deben realizarse a Bancoppel / Home/sysafore /
/ CONTOBDDMMAAAA.BCOPPEL.01 / Archivo de respuesta sobre los pagos de la afore que debían realizarse a otros bancos / Home/sysafore /
/ CONTDDMMAAAA.BCOPPEL.01 / Archivo de respuesta sobre los pagos de la…

### OpenBanking
*(SUD: `Bancoppel_SUD_OpenBanking.docx`)*  
- **Objetivo:** *La funcionalidad de este portal está dedicada a la exposición de API por parte de BanCoppel.*
*BanCoppel expone API para que los desarrolladores puedan hacer consumo de estas, para poder*
*realizar pruebas y comprueben la funcionalidad en sus desarrollos. Exponer servicios por medio de APIs de forma pública para cumplir con lineamientos de la CNBV. *
- **Tecnologías:** - *Java 17, Spring Boot, Apache Camel 3.x (algunas piezas legacy Camel/Hystrix).*
- *Resilience4j (Camel Resilience4J); Actuator.*
- *OpenShift 4; JKube para contenedores; ConfigMap para configuración.*
- *3scale API Management; SSO.*
- *Transformaciones de modelos con dependencia nola-lija-d-atm-transformations.*
- **Arquitectura / Integración:** *Capa Exposición (slce-sdfu-p-cnvb-atm) sirve GET/HEAD de atms desde caché y valida actualización.*
*Capa Datos (slcd-sdfu-o-atm-network-operations) consume backend, transforma y llena caché.*
*Servicios BPI Enrollment y Customer Session exponen endpoints POST protegidos por 3scale/SSO y orquestan llamadas a BEX.*
*Resiliencia configurada por servicio (circuit breakers, timeouts, pools).*
- **Bases de datos:** / Nombre de tabla / host / Port / Protocolo / Servidor /
/ --- / --- / --- / --- / --- /
/ Servidor BD Postgres dev / 10.27.207.114 / 5432 / TCP / Postgres /
/ Servidor BD Postgres uat / 10.26.169.29 / 5432 / TCP / Postgres /
/ Servidor BD Postgres drp / 10.30.18.16 / 5432 / TCP / Postgres /
/ Servidor BD Postgres drp / 10.30.16.16 / 5432 / TCP / Postgres…
- **Interfaces:** *3scale/SSO (autenticación y control).*
*Backends BEX/msach-* (enrollment, OTP, ATM data).*

### Ordenes de Pago Nacionales 20250609
*(SUD: `Bancoppel_SUD_Ordenes_de_Pago_Nacionales_20250609.docx`)*  
- **Objetivo:** El propósito de la aplicación es facilitar el envío y recepción de dinero entre sucursales bancarias, permitiendo a los clientes realizar órdenes de pago que puedan ser cobradas por un beneficiario designado. Las órdenes de pago pueden ser generadas desde SIWEB, o desde la Banca Empresarial. Además, la aplicación permite la cancelación de órdenes de pago en la sucursal de origen, asegurando un proceso seguro y eficiente para la transferencia de fondos. 
El sistema se mantiene estable, con incidentes raros, y…
- **Tecnologías:** Base de datos Informix
Servidores AIX
- **Arquitectura / Integración:** La arquitectura de la aplicación consiste en una interfaz web de front-end para la captura de datos y un back-end que opera basado en SPLs. Los datos capturados en el front-end pasan por un bus y un firewall antes de llegar a la base de datos. La interfaz de front-end se trata como una caja negra, enviando solicitudes al back-end para su ejecución.
La arquitectura de la base de datos incluye un núcleo ubicado en Monterrey y una réplica en Culiacán. Las operaciones realizadas en Monterrey se sincronizan con la réplica en Culiacán. En escenarios de contingencia o en operaciones bancarias específicas, la configuración operativa cambia, haciendo de Culiacán el sitio principal y de Monterrey el respaldo. Esta convergencia asegura la funcionalidad continua, ya que todos los…
- **Bases de datos:** La base de datos bdisac funciona como la principal donde se almacena toda la información relacionada con los servicios. Rastrea los envíos, actualizando su estado de la siguiente manera: estado 1 cuando se generan, estado 2 cuando se cobran y estado 4 cuando se cancelan. Consolida datos de movimientos, incluyendo montos de pago, detalles de sucursales,…
- **Interfaces:** No aplica para esta aplicación

### PLATAFORMA ARRENDADORA
*(SUD: `Bancoppel_SUD_PLATAFORMA_ARRENDADORA.docx`)*  
- **Objetivo:** El sitio web de Arrendadora Coppel alojado en infraestructura de AWS fue migrado a la nueva infraestructura de Google Cloud Platform (GCP), en esta migración se desactiva cualquier interacción con servicios, servidores y bases de datos, lo único que queda es una página estática con información de la Arrendadora.
Por el momento la infraestructura actual de Arrendadora Coppel no cuenta con bases de datos activas, dado que actualmente el portal web pasó a ser una página estática.
 
ACUMATICA
Acumatica garantiza la…

### Portal Publico BanCoppel
*(SUD: `Bancoppel_SUD_Portal_Publico_BanCoppel.docx`)*  
- **Objetivo:** Es una página web informativa sobre los productos y servicios que ofrece BanCoppel a todo el público en general, con el objetivo de informar al cliente sobre lo que ofrece cada apartado proporcionando información actualizada sobre condiciones y términos, así como las indicaciones para ser acreedor a un producto de banco, adicional ofrece simuladores para calcular una inversión creciente o un pagaré a el plazo que el usuario más le convenga, también cuenta con servicio de geolocalización para ubicar cajeros y…
- **Tecnologías:** - Frontend: HTML, CSS, JavaScript, React (para portal empresarial) 
- Backend: Apache 2.4, PHP 7.02 
- Base de Datos: PostgreSQL 
- Servidor Web: Apache HTTP Server 
- Sistema Operativo: Red Hat Linux 
- Autenticación: Jboss (para servicios de validación) 
- Balanceador: F5 
- Seguridad: WAF Imperva
Rutas de Código y repositorios:
No se tiene un versionador
- **Arquitectura / Integración:** El portal está estructurado en tres componentes principales:
- Sección Principal: Página de inicio con información general
- Micrositios: Sitios especializados por producto/campaña
- Portal Empresarial: Sección dedicada para empresas 
La arquitectura sigue un modelo de tres capas:
- Presentación: Frontend web accesible públicamente
- Aplicación: Servidores Apache con lógica de negocio en PHP
- Datos: Bases de datos PostgreSQL para catálogos y documentos
- **Bases de datos:** Servidores de aplicación:
- Desarrollo
- IP: 10.26.211.118 (ReingBPIADCdMX)- Desarrollo y pruebas internas 
- Puerto principal: 80
- Publicación de imágenes para diferentes micrositios: 8100, 8900
Servidor Apache Web 2.4 con PHP
- QA/UAT
- IP: 10.30.30.106 (ReingBPIADCdMX2) - Validación externa antes de producción 
-…
- **Interfaces:** / Nombre / Propósito / Ubicación / Descripción /
/ --- / --- / --- / --- /
/ Servicio BECOs / Consulta la tabla de corresponsales / JBoss / Valida solicitudes y consulta BD /
/ API Google Maps / Servicio de Geolocalización / Externa / Localización sucursales y cajeros /
/ Latinia / Gestión notificaciones / Externa / URLs para SMS y emails /
/ Medallia / Encuestas satisfacción / Externa / Scripts JavaScript para encuestas /
/ WhatsApp API / Atención al cliente / Externa / Bot para consultas automatizadas /

### Prevencion de Fraudes
*(SUD: `Bancoppel_SUD_Prevencion_de_Fraudes.docx`)*  
- **Objetivo:** *Proteger al banco y a sus clientes de actividades fraudulentas en tiempo real*
- **Tecnologías:** *Aqua Data Studio (Informix)*
*Putty*
*Escritorio remoto Windows*
*PayTrue*
*Switch Console*
*Workstation*
*Corima*
*Rational*
*Mantis*
*Notepad++*
- **Bases de datos:** Tablas: 
Y todas las tablas de OLTP Replica por el tipo de aplicativo
- **Interfaces:** *Documentacion: https://drive.google.com/drive/folders/1qbMaABHow_e8HgWmVR17lyrPcacQyrrg*

### PROMETEO V1 1
*(SUD: `Bancoppel_SUD_PROMETEO_V1_1.docx`)*  
- **Objetivo:** La aplicación está diseñada para automatizar y asegurar el procesamiento de documentos y la gestión de usuarios y cuentas en entornos empresariales complejos, mediante flujos de trabajo estructurados, validación de datos y configuraciones técnicas robustas. Su propósito es optimizar la eficiencia operativa, reducir errores y garantizar la seguridad en la administración de información crítica, apoyándose en tecnologías como OnBase, Unity, Informix, APIs REST y SOA.
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*El objetivo de los proyectos en el diagrama de proyectos …*
*Añadir imágenes aquí (los links deberán ser añadidos al final de este SUD)*
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### PUNTOS COMPROMISO 001
*(SUD: `Bancoppel_SUD_PUNTOS_COMPROMISO_001.docx`)*  
- **Objetivo:** *El sistema SOC (sistema operativo central) es la aplicación la cual está dividida en 15 módulos y estos módulos se subdividen en un total de 710 funcionalidades entre las cuales destaca la de PUNTOS COMPROMISO.*
*El sistema SOC integra interacciones entre navegador, dispositivo cliente y sistema operativo a través de middleware, facilitando la comunicación con los sistemas centrales de banca.*
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
*Para el desarrollo y ejecución del aplicativo se utilizarán las siguientes tecnologías:*
- *Servidor Linux RedHat 7.2.*
- *Servidor de Aplicaciones JBoss 7.2 EAP.*
- *Máquina Virtual Java JDK 1.8.0_121.*
- *Navegadores Microsoft Edge Chromium y Chrome.*
- *ZK Framework 8.0.5 y Framework Atmosphere.*
- *Informix 12.0 - CORE Bancario*
- *Postgres 9.4.11*
- *Componente de…
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*La arquitectura del sistema incluye dos métodos de comunicación con el núcleo bancario, facilitados a través de INTERACT. El servidor JBoss se comunica con INTERACT mediante una DLL llamada Interapi. Los parámetros que se pasan a la clase Interapi especifican el procedimiento almacenado (SP) que se ejecutará, los parámetros de entrada y las respuestas esperadas de la base de datos. La solicitud fluye a través de INTERACT, llega a la base de datos y regresa mediante un canal de comunicación bidireccional al servidor de aplicaciones, donde la funcionalidad muestra los resultados.*
- **Bases de datos:** Spl´s de base de datos Para la funcionalidad de puntos compromiso: 
/ Base de datos / Nombre SPL / Pantalla / Comentarios /
/ --- / --- / --- / --- /
/ bdicnweb / sp_verificastatusconsrepuntoscompromiso / Modal / Verificación del estatus de la generación del reporte. /
/ bdicnweb / sp_verificastatusconspuntoscompromiso / Modal / Valida estatus. /
/…
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### Reporte VISA Trimestral
*(SUD: `Bancoppel_SUD_Reporte_VISA_Trimestral.docx`)*  
- **Objetivo:** *<Propósito principal de la aplicación>*
Generar y actualizar información relacionada con reportes trimestrales de tarjetas Visa, tanto de crédito como de débito, basándose en fechas de corte, archivos conciliados y reglas de negocio específicas.
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- *Control-M*
- *Informix*
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*El objetivo de los proyectos en el diagrama de proyectos …*
*Añadir imágenes aquí (los links deberán ser añadidos al final de este SUD)*
Un store procedure es disparado por un Job de control M el cual tiene un job predecesor y si ese job no se ejecuta de manera correcta el flujo se vera interrumpido.
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ rpt_param_reportevisa / / / /
/ rpt_miembroprincipal / / / /
/ rpt_volumetria / / / /
/ rpt_param_reportevisa / / / /
/ rpt_visaelectron / / / /
/ rpt_volumetria_diaria / / / /
/ si_fechas / / / /
/ td_archivos_conciliacion / / / /
/…
- **Interfaces:** *Si ya existiera documentación, proveer links*
*Items a relevar*
*Nombre Reporte*
*Descripción / Propósito*
*Generado por*
*Usuario Destino*
*Complejidad (Alta, Media, Baja)*
*Criticidad (Alta, Media, Baja)*
*La interfaz con el usuario (SIF)*
*Cotrol M*

### Risklogic Regulatorios AMS
*(SUD: `Bancoppel_SUD_Risklogic_Regulatorios_AMS.docx`)*  
- **Objetivo:** El aplicativo Risklogic Regulatorios se encarga de la generación de Reportes Regulatorios de forma automatizada, esto es para terminar con la generación manual de los reportes, estos se envían a la autoridad. El aplicativo integra varios informes que se generan de forma mensual y trimestral, esto por petición del usuario.
- **Tecnologías:** - Jboss
- Motor de base de datos Informix
- Java (servlets, jsp)
- Javascript
- HTML
- **Arquitectura / Integración:** La arquitectura incluye múltiples servidores: un servidor de correo electrónico, un repositorio (NAS), un servidor de aplicaciones (Jboss), bases de datos propietarias de Informix, servidores MongoDB y Postgres.
El servidor de aplicaciones Jboss se utiliza como un túnel para conectarse al servidor de base de datos. No se tiene acceso directo al servidor de base de datos; en su lugar, la conexión se establece utilizando una cuenta de usuario en el servidor Informix, que luego salta al usuario del sistema de la base de datos del aplicativo (sysrisklogicifx). Este servidor está registrado con la dirección IP 10.36.200.198 y opera en un sistema operativo Linux, versión 7. Los permisos están restringidos, por temas de seguridad.
El servidor de aplicaciones mantiene un…
- **Bases de datos:** Tablas: 
Para consultar la lista de las tablas, revisar el siguiente documento en la pestaña…
- **Interfaces:** / Servidor / Propósito / Ubicación / Descripción /
/ --- / --- / --- / --- /
/ Aplicaciones / Generar Reportes Regulatorios / [http://10.28.217.124:8080/RiskLogic/m/SignIn](http://10.28.217.124:8080/RiskLogic/m/SignIn) / Se encarga de generar de forma automatizada los reportes regulatorios que se requieren de forma mensual y/o trimestralmente, esto a petición del usuario. /

### RPA Robots
*(SUD: `Bancoppel_SUD_RPA_Robots_.docx`)*  
- **Objetivo:** La aplicación Blue Prism es una herramienta diseñada para el desarrollo, mantenimiento y mejora de robots utilizados en procesos robóticos automatizados. El área de RPA se asegura de que la infraestructura que respalda a estos robots opere al 100% de eficiencia tanto en los entornos de desarrollo como en los de producción y DRP.
- **Tecnologías:** *BluePrism*
*Outlook*
*Paquetería Office (excel principalmente)*
- **Arquitectura / Integración:** *Actualmente, en RPA, existen tres entornos: desarrollo, producción y DRP. El entorno de desarrollo se utiliza para realizar desarrollos, mantenimientos o mejoras y realizar las pruebas correspondientes que requieren automatización. El entorno de producción se usa para implementar robots que ejecuten los procesos automatizados. La programación de los procesos en producción depende de los acuerdos con los usuarios, la criticidad del proceso y el volumen. Por ejemplo, el proceso de aclaraciones, por la volumetría y SLA de atención establecida por el área de negocio, se ejecuta cada 15 minutos. El robot revisa la plataforma de aclaraciones cada 15 minutos para identificar casos disponibles para su procesamiento.*
- **Bases de datos:** Tablas:…
- **Interfaces:** - Blue Prism:
- Propósito: Automatización de procesos robóticos.
- Ubicación: Servidores de aplicaciones y runtimes/servidores de ejecución.
- Descripción de cómo funciona:
- Conexión a través de puertos 8199 y 8181.
- Validación de conexión mediante el App Server.
- Interacción: Con servidores de datos y aplicaciones como SOC.
- SOC:
- Propósito: Configuración y gestión de entornos.
- Ubicación: Servidores de aplicaciones.
- Descripción de cómo funciona:
- Instalación del cliente SOC para acceso.
- Configuración de perfiles y funcionalidades a nivel de base de datos.
- Interacción: Con bases de datos y…

### SOC
*(SUD: `Bancoppel_SUD_SOC.docx`)*  
- **Objetivo:** *El objetivo de la aplicación es integrar un mini-corebancario con distintas funcionalidades bajo una misma arquitectura funcional y técnica y bajo el mismo estándar de desarrollo. Esta aplicación está dividida en 15 módulos y estos módulos se subdividen en un total de 710 funcionalidades (al momento de la creación de este documento).*
*CARACTERISTICAS GENERALES DE LA APLICACIÓN.*
*La arquitectura y diseño del sistema SOC priorizan la consistencia, escalabilidad, seguridad y modularidad en todas las…
- **Tecnologías:** *Para el desarrollo y ejecución del aplicativo se utilizarán las siguientes tecnologías:*
- *Servidor Linux RedHat 7.2.*
- *Servidor de Aplicaciones JBoss 7.2 EAP.*
- *Máquina Virtual Java JDK 1.8.0_121.*
- *Navegadores Microsoft Edge Chromium y Chrome.*
- *ZK Framework 8.0.5 y Framework Atmosphere.*
- *Informix 12.0 - CORE Bancario*
- *Postgres 9.4.11*
- *Componente de Huella Digital proporcionado por BanCoppel.*
- **Arquitectura / Integración:** *La arquitectura del sistema incluye dos métodos de comunicación con el núcleo bancario, facilitados a través de INTERACT. El servidor JBoss se comunica con INTERACT mediante una DLL llamada Interapi. Los parámetros que se pasan a la clase Interapi especifican el procedimiento almacenado (SP) que se ejecutará, los parámetros de entrada y las respuestas esperadas de la base de datos. La solicitud fluye a través de INTERACT, llega a la base de datos y regresa mediante un canal de comunicación bidireccional al servidor de aplicaciones, donde la funcionalidad muestra los resultados. *
* *
*INTERACT tiene una limitación de 10 KB para las respuestas, que depende del tamaño del registro o marco devuelto por la ejecución del SP. Por ejemplo, si un SP devuelve 216 caracteres,…
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### SPEI Enlace Financiero N2
*(SUD: `Bancoppel_SUD_SPEI_Enlace_Financiero_N2.docx`)*  
- **Objetivo:** / # / Fecha / Temas Cubiertos / Presentes /
/ --- / --- / --- / --- /
/ / / / /
/ / 02-Abr-25 / Arquitectura •Arquitectura de la aplicación •Diagrama de arquitectura •Piezas que conforman la arquitectura •Funcionamiento general de la arquitectura Infraestructura •Diagrama de infraestructura •Infraestructura de plataforma contingente •Mantenimientos a la infraestructura / Accenture: Javier Gutiérrez Bancoppel:…
- **Tecnologías:** / No. / Herramienta  / Descripción Herramienta  / Ambiente  / Tipo de acceso  /
/ --- / --- / --- / --- / --- /
/ 1  / BBDD Informix  / Base de datos del Core bancario de Bancoppel  / DESARROLLO  Consideraciones:  Se requiere VoBo de OSI  Una vez que OSI da el VoBo se solicita el usuario y accesos al equipo de BD Distribuidas / Lectura/Escritura /
/ 2  / WeBlogic / Servidores involucrados incluyen los servidores de…
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ tblpago / Tabla ubicada en la instancia bancopel_tcp de la base de datos bdispei IP 10.26.163.22 / Esta tabla es utilizada en certificaciones de CoDi y DiMo ya que almacena los envíos. / [Matriz de Base de Datos y…

### Strikeiron 20250425 3
*(SUD: `Bancoppel_SUD_Strikeiron_20250425_3.docx`)*  
- **Objetivo:** La función principal de la aplicación es la validación de correos electrónicos. Envía los datos de los correos electrónicos a un proveedor externo Strikeiron para su validación y devuelve los resultados. El proceso de validación no ocurre dentro del código de la aplicación, sino que depende del proveedor externo.
- **Tecnologías:** El aplicativo no cuenta con un modelo de base de datos, actualiza OLTP directamente.
- **Arquitectura / Integración:** La aplicación es un archivo JAR en Java desplegado en un servidor. El servidor está alojado en Bancoppel y se conecta a un servidor de base de datos, también alojado en Bancoppel. Existe una conexión adicional con el servidor en la nube del proveedor externo, que se encarga de la validación de correos y devuelve los resultados a Bancoppel. La arquitectura consta del servidor de aplicaciones, el servidor de base de datos y el servidor del proveedor.
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ sp_obtienecorreos / Sp principal del aplicativo / / /
/ informix.si_correos / Tabla con los correos a validar / / /
/ / / / /
/ / / / /
- **Interfaces:** sp_obtienecorreos
 Sp principal, recupera los correos y actualiza su validez.
 Criticidad media
 Complejidad media
clienteStrikeServidor.jar
 Envía los correos a validación y actualiza su estatus en la base de datos.
 Criticidad media
 Complejidad media.

### SUD- SICC
*(SUD: `SUD-_SICC.docx`)*  
- **Objetivo:** El SIC[^c1] es un sistema crítico para la operación de Grupo Coppel, encargado de dar soporte y continuidad a todo el proceso de originación de créditos. La principal función es generar y proporcionar la información necesaria para evaluar una solicitud de crédito, donde se incluye la creación de la solicitud, la precalificación de la solicitud, la consulta al historial crediticio de las SIC y la evaluación Coppel.[^c2]
Para cumplir este propósito, el SIC integra consultas a los dos sistemas de información…
- **Tecnologías:** El Sistema de Información Crediticia de Coppel (SIC) opera sobre una infraestructura mixta que integra bases de datos corporativas, herramientas de administración, clientes de conexión remota y utilidades de desarrollo, asegurando la correcta gestión y soporte del flujo de originación de créditos.
1. Bases de Datos y Motores de Procesamiento
- Informix: Base de datos central donde reside la lógica de negocio,…
- **Arquitectura / Integración:** El Sistema de Información Crediticia implementa una arquitectura distribuida y cerrada a la red corporativa, diseñada para recibir solicitudes de crédito desde varios canales de entrada (Autosolicitudes, OneClick, Sucursal y, cuando aplica, Empresarial), centralizarlas en un servidor de aplicación y procesarlas con lógica de negocio alojada principalmente en Informix. La decisión y/o la respuesta de evaluación se alimenta con consultas en línea a los dos organismos de información crediticia (Buró de Crédito y Círculo de Crédito) a través de demonios Java especializados, y se apoya en PostgreSQL para parámetros y datos auxiliares.
La solución contempla alta disponibilidad mediante pares Productivo/Réplica para el servidor de aplicación y para las bases de datos…
- **Bases de datos:** - coppel_shm
- bdiburo
- bdisolic
- bdicred
- bdinteg
Tablas: 
Debido a la cantidad de tablas se agrega como documento adjunto.
- **Interfaces:** Inventario de bases de datos se agrega como documento adjunto.

### Template AIX 20250430
*(SUD: `Bancoppel_SUD_Template_AIX_20250430.docx`)*  
- **Objetivo:** El objetivo principal del sistema operativo es poner los recursos del hardware a disposición de las aplicaciones que se ejecuten en su entorno. La tarea del administrador es mantener el funcionamiento del sistema operativo, garantizando la estabilidad y el rendimiento del mismo, proveyendo los recursos requeridos por las aplicaciones.
- **Tecnologías:** [IBM Power Modelo E880c](https://docs.google.com/document/d/1eQGvP_wZnnwt7E26UqEO8zKwpto-esoePvk11Zq-bV8/edit?pli=1#heading=h.asf30mnbw9nc)
 [Power System S924](https://docs.google.com/document/d/1eQGvP_wZnnwt7E26UqEO8zKwpto-esoePvk11Zq-bV8/edit?pli=1#heading=h.nyuu86fg33zz)
 [Pure Application System](https://docs.google.com/document/d/1eQGvP_wZnnwt7E26UqEO8zKwpto-esoePvk11Zq-bV8/edit?pli=1#heading=h.dcsg62lkpzev)
…
- **Arquitectura / Integración:** Dependiendo de la aplicación que cada sistema ejecute, existen dos tipos de server: los autónomos, o *standalone*, que operan de forma individual, y los nodos de cluster, o *cluster nodes HACMP*, que operan en forma conjunta, coordinada y compartiendo recursos para asegurar alta disponibilidad.
- **Bases de datos:** *Favor de proveer un breve resumen / Detalle de las configuraciones técnicas.*
La configuración de los equipos Centrales que se encuentran en los servidores Power E880C, incluye un modelo de virtualización que tiene como objetivo reducir la complejidad del manejo de distintos sistemas operativos en los equipos…
- **Interfaces:** Este documento contiene detalles de la infraestructura tecnológica*: *[*V. Infraestructura Tecnológica ARGA_2 05042024_Vfinal V2*](https://docs.google.com/document/d/1eQGvP_wZnnwt7E26UqEO8zKwpto-esoePvk11Zq-bV8/edit?pli=1&tab=t.0#heading=h.814nmjdghjcf)

### Template BancoppelWS
*(SUD: `Bancoppel_SUD_Template_BancoppelWS.docx`)*  
- **Objetivo:** *<Propósito principal de la aplicación>*
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*El objetivo de los proyectos en el diagrama de proyectos …*
*Añadir imágenes aquí (los links deberán ser añadidos al final de este SUD)*
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ BCPL_LOGIN sp_ws_login AFORE_CTES sp_ws_afore_nomcte BCPL_CNTAR sp_ws_afore_cntar BCPL_CFHUE sp_ws_afore_cfhue BCPL_CTES sp_ws_afore_ctes CON_HUELLA sp_ws_coppel_huellas TDA_CTEREL sp_ws_tda_cterel TDA_HUELLA sp_ws_tda_huella BCPL_ACLTA sp_ws_coppel_ta…
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### Template entregable Administrador de token  CAS
*(SUD: `Bancoppel_SUD_Template_entregable_Administrador_de_token__CAS_.docx`)*  
- **Objetivo:** ¿Qué es el Administrador de Tokens (CAS)?
El *Administrador de Tokens* es una aplicación interna utilizada para gestionar y enviar dispositivos físicos de seguridad llamados “tokens” a clientes empresariales. Estos tokens permiten realizar operaciones seguras en plataformas bancarias en línea.
Aunque en el pasado también se utilizaban tokens físicos para clientes individuales (Personas Físicas), desde 2021 se han reemplazado por soluciones digitales. Hoy en día, esta herramienta opera exclusivamente para personas…
- **Tecnologías:** El sistema Administrador de Token CAS es una aplicación institucional diseñada para gestionar la generación, asignación y envío de tokens físicos a clientes empresariales. Su construcción se apoya en un conjunto de tecnologías robustas y estandarizadas para entornos corporativos:
- Lenguaje de programación:
 Utiliza Java 1.8 como lenguaje base, con planes de actualización a Java 21 para aprovechar nuevas…
- **Arquitectura / Integración:** La arquitectura del sistema es modular, segura y diseñada para procesar grandes volúmenes de solicitudes de tokens, particularmente en contextos empresariales. Su estructura comprende:
Despliegue de la aplicación:
 El archivo principal de la aplicación (.WAR) está instalado dentro de JBoss. Todos los componentes operan de manera distribuida: funciones de consulta, validación, generación de guías, y asignación de tokens se ejecutan de forma separada, lo que permite escalabilidad.
Entornos operativos diferenciados:
 Hay entornos independientes para desarrollo, producción, pruebas y recuperación ante desastres (DRP), cada uno con IPs y servidores específicos.
Interacción con la base de datos:
 Las operaciones del sistema se realizan contra la base Informix mediante…
- **Bases de datos:** Este apartado presenta las bases de datos que participan en el funcionamiento del sistema *Administrador de Token CAS*, especificando sus funciones operativas, tipo de información que manejan y su relación con los distintos entornos de ejecución. La segmentación por base permite asegurar la trazabilidad de las solicitudes, el control del inventario de…
- **Interfaces:** El sistema incluye diversas interfaces que permiten interactuar con las funcionalidades del aplicativo, distribuidas en menús, pestañas y vistas operativas:
- Pantalla de inicio y navegación principal
 Acceso al sistema, vista general, cambio entre personas físicas y morales
- Sección de solicitudes
 Búsqueda por estado, número de solicitud, cliente, sucursal, rango de fechas
- Sección de alertas
 (Actualmente no activa para solicitudes individuales)
- Sección de control de paquetes
 Detalles de guías, conteo de tokens, entregas, devoluciones, estado logístico
- Sección de inventario
 Gestión por lotes, estado…

### TRIAD
*(SUD: `Bancoppel_TRIAD.docx`)*  
- **Objetivo:** Generar estrategias de cobranza, automatizar la adherencia y establecer el riesgo de crédito mediante la segmentación de la población de clientes en grupos homogéneos para tratamiento específico.
- **Tecnologías:** *Herramientas y tecnologías empleadas.*
- Herramientas de la solución TRIAD
- Cobol batch (“programa llamador” para segmentación): Job batch que procesa el layout diario y aplica las reglas de segmentación en Triad.
- Informix Staging (SPs y preprocesamiento): Base de datos de staging donde se ejecutan stored procedures para limpiar y preparar datos antes del layout.
- Control-M (orquestación de layout y…
- **Arquitectura / Integración:** La arquitectura de la solución TRIAD en BanCoppel está diseñada para integrar procesos analíticos y operativos que permiten evaluar el riesgo crediticio y definir estrategias de cobranza a nivel cliente. El flujo de información se encuentra dividido en dos componentes principales:
- Procesamiento Interno en Staging
Utilizando Stored Procedures en Informix, se extrae información desde la base de datos OLTP mediante sinónimos federados. Estos procesos son orquestados por Control-M, que activa la ejecución paralela de SPs que transforman y cargan datos en cinco tablas intermedias. Finalmente, un sexto SP consolida esta información en un archivo plano con formato de layout, el cual es enviado vía SFTP al servidor FICO TRIAD para su posterior uso.
- Procesamiento en el…
- **Bases de datos:** https://docs.google.com/spreadsheets/d/1INY2xsAg9vFiCw-oqVocPzc-VuVEs9kW/edit?usp=drive_link&ouid=103858764662889670363&rtpof=true&sd=true
Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ sd_param / bdicred / OLTP / /
/ sd_fechas / bdicred / OLTP / /
/ sd_maecredcrd / bdicred / OLTP / /
/…
- **Interfaces:** https://drive.google.com/drive/folders/1b5FfbN1faOGpKTol5DM4N5U1Tra6zYc7?usp=drive_link

### Universidad Virtual BanCoppel
*(SUD: `Bancoppel_SUD_Universidad_Virtual_BanCoppel.docx`)*  
- **Objetivo:** Otras áreas del Cliente en que nos relacionamos para Operar / Desarrollar 7
- **Tecnologías:** NA. (Es del proveedor)
- **Bases de datos:** NA
Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Si ya existiera documentación, proveer links*
*Items a relevar*
*Nombre Reporte*
*Descripción / Propósito*
*Generado por*
*Usuario Destino*
*Complejidad (Alta, Media, Baja)*
*Criticidad (Alta, Media, Baja)*

### VCAS 20250601
*(SUD: `Bancoppel_SUD_VCAS_20250601.docx`)*  
- **Objetivo:** VCAS es un servicio de autenticación desarrollado por Visa para mejorar la seguridad de las transacciones en línea. Su función principal es almacenar y gestionar la información de los titulares de tarjetas, permitiendo validar compras a través de modelos de riesgo y scoring. En base a ello generar una evaluación de riesgo que determine la autenticación de compras en línea mediante códigos OTP (One-Time Passwords), reduciendo así fraudes y asegurando la confiabilidad de las operaciones.
Proceso y Conceptos de…
- **Tecnologías:** 1. Informix (BD OLTP)
- Rol: Motor de base de datos relacional donde se almacenan temporalmente los archivos de entrada y salida del proceso VCAS.
- Ventaja: Informix es ideal para entornos transaccionales por su estabilidad, eficiencia en consultas complejas y compatibilidad con sistemas críticos en tiempo real.
2. Control-M (Orquestador de procesos)
- Rol: Automatiza y programa la ejecución secuencial de scripts…
- **Arquitectura / Integración:** Resumen Ejecutivo
El proceso VCAS Productivo está diseñado para gestionar la transmisión segura y automatizada de información de tarjetas entre sistemas internos y un proveedor externo de validación (VISA). Se compone de tres fases principales: extracción y envío de datos, recepción de resultados y generación del reporte final, orquestadas mediante tareas programadas y mecanismos de transferencia segura.
1. Extracción y Envío de Datos hacia VISA
- Controlador de procesos (Servidor Control-M):
Ejecuta tareas automatizadas que recolectan información de tarjetas usadas en emisiones o renovaciones recientes. Estas tareas generan archivos con los detalles requeridos por VISA.
- Servidor de Base de Datos (OLTP):
Recibe y almacena temporalmente los archivos en una carpeta…
- **Bases de datos:** Tablas: 
/ Nombre de tabla / Descripción / Observaciones / Links asociados /
/ --- / --- / --- / --- /
/ / / / /
/ / / / /
/ / / / /
/ / / / /
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*

### Órdenes de Supervisión  SPL Centrales
*(SUD: `Bancoppel_SUD_Órdenes_de_Supervisión__SPL_Centrales_.docx`)*  
- **Objetivo:** *Generar Ordenes de Supervisión las cuales se generan después de una solicitud de crédito desde el aplicativo Alta Única, que requieren verificación de domicilio del cliente prospecto.*
- **Tecnologías:** *Control M*
*Informix*
*Linux*
*Monitoreo BanCoppel-Coppel*
- **Arquitectura / Integración:** *Visión general de la arquitectura.*
*El objetivo de los proyectos en el diagrama de proyectos …*
*Añadir imágenes aquí (los links deberán ser añadidos al final de este SUD)*
El aplicativo OS se especifica por su nombre, ubicación de instalación y las versiones sobre las que está construido. Incluye detalles sobre el tipo de licencias utilizadas, ya sean de pago o de código abierto, y si existe soporte disponible para la licencia. Se documenta el número de licencias de la aplicación, junto con el código fuente si está disponible. Se requiere el registro de control de software para la aplicación, incluyendo su tecnología y recursos. Se proporcionan detalles de control de acceso, especificando los servidores involucrados, como los entornos de desarrollo, QA y…
- **Bases de datos:** https://drive.google.com/file/d/11Gwpn6ofIZE1OlKl30v1D_HysDEihGbV/view?usp=drive_link
- **Interfaces:** *Nombre, Propósito, ubicación, Descripción de cómo funciona, entre que aplicaciones interactúa*


## 9-bis. Transcripciones de diagramas de arquitectura (26)

Transcripción textual de los diagramas del legado (fuente principal para el diagrama N1/N2 y sus integraciones), embebida del corpus.

```text
▚ TRANSCRIPCIÓN DE DIAGRAMAS DE ARQUITECTURA (imágenes PNG/JPG → texto)

# Nota: estas descripciones fueron transcritas por inspección visual de los
# diagramas originales. Reemplazan a las imágenes para efectos de construir
# el diagrama de aplicaciones N1/N2 e integraciones. Donde la resolución del
# original impidió leer texto interno, se indica explícitamente "[detalle no
# legible en el original]" y sólo se transcribe la estructura macro.
# Las IPs se conservan como evidencia de topología; NO son un inventario CMDB.

## 🖼️ Sucursales.jpg — Topología On-Premise BanCoppel MTY (VISTA CENTRAL DE INTEGRACIÓN)
Es la vista de referencia de la integración del legado on-premise. Flujo:
- Canales: "Tienda Coppel 1 … Tienda Coppel N", cada una con Ejecutivos Bancarios usando **SIWEB**.
- Conectividad: **MPLS** desde las tiendas hacia el datacenter corporativo.
- Zona pública: **Firewall F5**.
- Zona privada (capa de aplicación): **IBM IHS Standard** (2 instancias) como front, que distribuyen a **8× IBM WebSphere Application Server (AS)**.
- Los WebSphere AS convergen a **IBM DB2** (primer DB2).
- Luego **IBM Standard** (2 instancias, capa de mensajería) alimentan a **4× IBM Integration Bus (IIB)**.
- Los IIB convergen a un segundo **IBM DB2** y salen por **AWS Transfer Family (SFTP)**.
- Zona privada destino: **OLTP**, **IMAGENES**, **2× PostgreSQL**, y **6× API**.
INTEGRACIONES CLAVE: SIWEB→MPLS→F5→IHS→WebSphere→DB2→IIB→DB2→AWS SFTP→(OLTP/PostgreSQL/APIs).
Middleware central del legado = **IBM IHS + IBM WebSphere + IBM Integration Bus + IBM DB2**; puente a nube = **AWS Transfer Family SFTP**.

## 🖼️ IBM_BUS.png — Bus de integración central (mismo patrón que Sucursales)
- Front **IBM IHS Standard** (2 instancias) → **4× IBM Integration Bus** → **IBM DB2** → **AWS Transfer Family (SFTP)**.
- Zona privada: **OLTP**, **IMAGENES**, **2× PostgreSQL**, **6× API**.
Confirma que IIB + DB2 son el hub de integración; la salida a la zona de datos moderna (PostgreSQL/APIs) se hace vía SFTP gestionado en AWS.

## 🖼️ Arquitectura_Autenticador_BC_y_CC.png — Autenticador BanCoppel/Círculo Crédito (2 vistas)
Vista izquierda (Autenticador + módulos):
- Servidor **PRODUCTIVO 10.28.219.25 / RÉPLICA 10.28.217.36** con módulos apilados: **Autenticador**, **Personas Morales**, **Servicio en Línea**, **Demonio**.
- BD: **Postgres** (PROD 10.28.218.95 / Réplica 10.28.216.104) e **Informix** (PROD 10.36.197.51 / Réplica 10.36.193.51).
- Consumidores por puerto: Autosolicitudes (Pto 8080), Empresarial (8080), One clic (8080), Sucursal.
- Salida a **Buró de Crédito 128.9.55.100** por puertos 40000/7080/8443/25000/25100.
Vista derecha (variante Círculo de Crédito):
- Servidor **PRODUCTIVO 10.28.219.28 / RÉPLICA 10.28.217.39**, módulos **Autenticador** + **Demonio**.
- BD: Postgres (PROD 10.28.218.96) e Informix (PROD 10.36.197.51 / Réplica 10.36.193.51), con réplicas de Desarrollo.
- Salida a **Círculo de Crédito 173.17.1.14** por puertos 25000, 30000/31000.
INTEGRACIÓN: Autenticador consulta a **Buró de Crédito** y a **Círculo de Crédito** (dos bureaus externos); persiste en Postgres+Informix.

## 🖼️ Arquitectura_Autenticador_BC_y_CC_2.png — Autenticador (vista de red DMZ/balanceo)
- Canales: dispositivos (PC, móvil, laptop) → **Internet** → **Landing Page Coppel** / **Servidor Coppel**.
- **Proxy Inverso Balanceador BanCoppel** en MTY (10.27.204.x) y CLN (10.27.28.198).
- Bloques funcionales replicados MTY/CLN: **Validación Correo y Teléfono**, **Oferta de productos**, **Inyección Alta Única**, **Consulta a SIC** (cada uno con 2 nodos, ej. 10.27.204.194/195 …).
- **Consulta a Buró/Círculo de crédito**: http://autenticadorbc.banco.int:8080
- BD: **Informix OLTP** MTY 10.36.197.51 / CLN 10.36.193.51, cada una detrás de un **IBM BUS** (MTY 10.27.31.14 / CLN 10.27.30.28).
INTEGRACIÓN: canal→proxy balanceador→módulos (validación/oferta/alta/SIC)→IBM BUS→Informix; consulta externa a bureaus.

## 🖼️ Arquitectura_Autenticador_de_BC_y_CC.png — Combinación de las dos vistas anteriores
Reúne en un solo lienzo la vista de módulos (Autenticador/Personas Morales/Servicio en Línea/Demonio con Postgres+Informix y bureaus) y la vista de red DMZ con proxies balanceadores e IBM BUS. Sin información nueva respecto a las dos anteriores.

## 🖼️ Arquitectura_Evaluación_de_Soluciones_de_Crédito_en_Sucursal.png — Evaluación de crédito en sucursal (OFI)
(Idéntico en Arquitectura_Evaluación_de_Soluciones_de_Crédito.png y Arquitectura_Evaluación_de_Soluciones_de_CréditoSucursal.png)
- Canal interno: **OFI** (PC) → **RED INTERNA** (recuadro amarillo).
- RED INTERNA contiene: **Informix 10.36.197.51** (DB2 icon), **INET consultamotorevaluacioncredto**, **demonioparametrico** (10.26.214.190).
- Canal externo: **INTERNET** → *.ocp1.bancoppel.com → **IMPERVA** (WAF).
- DMZ (recuadro verde OpenShift): **F5** 189.254.168.108 "Serv. balanceo *.ocp1.bancoppel.com" (Balanceo Nodos Infra Externos) → **F5** 10.30.16.9 "Serv. Balanceo Consola" + "Serv. balanceo *.ocp01.ocpprod.bcpl.int".
- **Red Interna OpenShift** → **Motor de Evaluación**.
- Consola OpenShift: console-openshift-console.apps.ocp01.ocpprod.bcpl.int
- Integración externa a **BRM COPPEL** (Red Coppel).
INTEGRACIÓN: OFI→(Informix + INET motor + demonio)→OpenShift Motor de Evaluación; entrada web vía Imperva+F5; consulta a BRM Coppel.

## 🖼️ Arquitectura_Evaluación_de_Solicitud_de_Crédito_en_Web.png — Evaluación de crédito en canal Web (arquitectura híbrida GCP + on-prem)
Capa nube (dominio https://*.web.bancoppel.com):
- **GCP**: **HTTPS Load Balancer**, **Cloud Run** (frontends: "Solicitud de Crédito", "Página Cliente Coppel"), **Serverless VPC Access**, **Cloud Armor**, **Cloud Logging**, **Cloud VM**, monitoreo **Dynatrace**.
- VPN de salida: **FortiGate 3200** (10.48.X.X), TLS 1.3.
Capa on-premise ("Red Interna"):
- **Proxy 10.33.109.3** y clusters **Cluster MTY DRP / Cluster CLN** sobre **Kubernetes/Docker/Rancher/Java/Red Hat Enterprise Linux 8.7**.
- Grupo **"Servicios Solicitud de Crédito"** (microservicios azules sobre Debian/Ubuntu buildpacks) y grupo **"Servicios de Coppel.com"** (microservicios amarillos). [Nombres individuales de microservicios: parcialmente legibles; patrón "ecommerce…", "api-…"].
- BD: **PostgreSQL Server** (CLN 10.44.1.167 / MTY 10.30.96.13, pto 5432).
- Bloques `<api>` externos vía HTTPS/TLS.
- Zona OpenShift on-prem (F5 + Balanceo Nodos Infra Master/Externos) → **Motor de Evaluación de Crédito**; consola console.apps.ocp01.ocoproc.bcol.int.
- **IBM BUS** integrando módulos (Validación correo y teléfono, Oferta Productos, Consulta SIC, etc.).
INTEGRACIÓN: Web(GCP Cloud Run)→FortiGate VPN→on-prem (microservicios K8s + PostgreSQL)→IBM BUS→OpenShift Motor de Evaluación. Es la arquitectura MÁS moderna del corpus (GCP + contenedores).

## 🖼️ Arquitectura_Motor_de_Evaluación_de_Crédito.png — Motor de Evaluación (vista infra)
- Canal: **SOC II** (PC), CLN 10.27.28.22 / MTY 10.26.214.230.
- RED INTERNA: **2× Informix** (MTY 10.36.197.51 / CLN 10.36.193.51).
- Externo: INTERNET→*.ocp1.bancoppel.com→**IMPERVA**→DMZ (**F5** 189.254.168.108)→**F5** 10.30.16.9→**Red Interna OpenShift**→**Motor de Evaluación**.
- Diagrama de secuencia asociado (SOC II ↔ Informix ↔ OpenShift ↔ Motor de Evaluación) con SPs de cambio de estatus por producto (Motor TDC Visa).

## 🖼️ Flujo_Motor_de_Evaluación.png — Flujo BPMN "Motor de Evaluación - Mesa de Control" (3 swimlanes)
Swimlane **Canal Originación**: Cliente→SOC II→lista de solicitudes→selección→funciones (Cambio de Estatus / Verificación Cliente BCP-CPL / Datos de Solicitud). Ejecuta SPs bdicnweb: sp_grabarcambiostatussolicitudmc, sp_revaluasolicitudmc. Subproceso "Consumo Motor": sp_consultadatos_motor_mc → Generación de JSON → **Consumo Motor de Evaluación** → sp_registradatos_motor (replica en BDCRED).
Swimlane **CORE / Informix**: SPs bdicnweb/bdicsic (sp_mc_graccambiostatus, sp_mc_revaluasol), banderas pBanderaMotor / cBanderaMC, ramas "Producto Motor TDC" vs "Evaluación tradicional de Solicitud".
Swimlane **OpenShift**: **Motor de Evaluación** = Evaluación de Solicitud → Cálculo y Evaluación de Respuestas SIC's → Ejecución de modelo de negocio para cálculo de scoring → Cálculo de capacidad de pago del cliente → Emisión de resultado de Evaluación.
INTEGRACIÓN LÓGICA: Canal(SOC II)→CORE Informix(SPs)→OpenShift(motor scoring/SIC/capacidad de pago); resultado se replica a BDCRED.

## 🖼️ Arquitectura_Motor_de_huellas.png — Motor de huellas (biometría dactilar)
- **Servidor Python Biometría Dactilar (10 huellas)** 10.28.216.198.
- **WsHuella** 10.28.216.142 (servicio web de resultados).
- **IBM bus** (registra resultados de comparación en BD).
- **BD Informix (coppel_shm)**: tablas ci_cte_huella_enc / ci_cte_huella_dec (templates de 10 huellas).
- **Interact mgr.banco.int** (almacena templates).
- **Repositorio Imágenes SFTP** 10.27.31.21 (imágenes de huellas de sucursales no piloto).
- **Servidor Primario Sucursal** + **Equipo Sucursal OFI/Promotoría/Caja** (captura WSQ, EO1901).
- **Motor de comparación Coppel** (Centro de datos Coppel) devuelve ticket de comparación.
INTEGRACIÓN: Sucursal(captura WSQ)→SFTP→Servidor Python biometría→IBM bus→Informix(coppel_shm)+Interact; comparación contra Motor Coppel; resultado vía WsHuella.

## 🖼️ Arquitectura_Inversiones.png — Inversiones (Aladdin/BlackRock + ION Trading)
- Externo (VPN MPLS): **BLACK ROCK** (COPPEL_BLACKROCK.COM_WEB_SERVER, Red Hat, pto 22, 199.242.7.2) y **PROVEEDOR** (FTP_COPPEL_BLACKROCK.COM_FTP_SITE, 199.242.7.3).
- RED CORPORATIVA BANCOPPEL:
  - **SRV_BLACKROCK_PASO_MTY** (Red Hat Enterprise Linux 8.6, pto 22, 10.28.217.12, Crones).
  - **SRV_ION_TRADING_MTY** (Windows Server 2019, pto 445, 10.28.216.210, APP: ION TRADING).
  - **SRV_ION_TRADING_BD_MTY** (AIX 7200, pto 10800, 10.36.197.52, SQL Server 2019 / PROGRESS; BD SQL mdbase / BD PROGRESS sh_mdbase).
- **TESORERÍA**: Front Office ↔ Back Office (puertos 443/5000), conexiones Aladdin (azul) e ION Trading (rojo).
INTEGRACIÓN: Tesorería→ION Trading (Windows) + Aladdin/BlackRock (Red Hat, vía VPN MPLS y FTP); BD en AIX (SQL Server + Progress).

## 🖼️ Arquitectura_Inversiones_2.png — Conectividad de red Inversiones ↔ INDEVAL
- **Bancoppel CDMX**: servidores PFI Físico / BD Físico (10.27.203.x), DMZ Producción (Vlan 750), DMZ Desarrollo (Vlan 7501), DMZ Usuarios CDMX (Vlan 752), firewall, switches.
- **INDEVAL**: routers (D32-0705-0539/0541 E1), **Server Portal Dali** http://10.100.192.3 y http://10.100.192.57:9005/dali (usuario tlp02083). Portal interno Indeval 10.36.192.188 (NAT 10.101.178.245), segmento 10.102.178.0/24.
- **Bancoppel CLN**: Cisco ASR1002-HX (10.43.239.2), DMZ Usuarios Cln (Vlan 1448).
- Interconexión vía **MPLS BANCOPPEL** (enlaces 300 Mbps y 600 Mbps).
INTEGRACIÓN: Inversiones (PFI/Dali) se conecta a **INDEVAL** vía MPLS; portal Dali es el acceso a Indeval.

## 🖼️ Arquitectura_Pagos_de_la_Afore.png — Pago de la Afore (batch por archivo)
Flujo: **Afore Coppel** genera archivo de pagos → **Servidor Bancoppel** → **BD: bdiprog** (tablas pp_arch_afore, pp_encabezado, pp_detalle, pp_sumario, pp_status_afore) → **SPs realizan los pagos** → **BanCoppel genera archivo de respuesta** → Servidor Bancoppel → regresa a Afore.
BD Informix: MTY productiva 10.36.197.51 / CLN réplica 10.36.193.51.
INTEGRACIÓN: intercambio de archivos Afore↔Bancoppel; lógica de pago en SPs sobre Informix (bdiprog).

## 🖼️ Arquitectura_Pago_de_TDC_otros_bancos.png — Pago TDC otros bancos (batch CTRL-M)
Flujo: App / Portal Web (Pago TDC otros bancos) → **bdiprog** → **CTRL-M** (jobs EJECUTAPAGOSPROGRAMADOS_PRO a las 6:00 y 19:00) → escribe en BDs Informix: **bdiprog, bdinteg, bdicheq, bdisac, bdimnsj, bdicred, bdispei**.
BD Informix: MTY 10.36.197.51 / CLN réplica 10.36.193.51 (30 min de desfase).
INTEGRACIÓN: orquestación batch vía **Control-M**; múltiples BDs Informix por dominio (SPEI=bdispei, cheques=bdicheq, crédito=bdicred, etc.).

## 🖼️ Arquitectura_Solicitud_SPEI.png — SPEI (2 vistas: red segmentada y PROD Pisa)
- Externo: **Banxico** con **SPEI** y **CoDi**, conectados por **VPN** vía MPLS (MPLS0/MPLS1/PTP1/PTP0).
- Dominio spei.banco.int, **firewall/Balanceador**, **ACL**, zona **DMZ**.
- Adaptadores: **ADAPTER (A)**, **ADAPTER (B)**, **ADAPTER CoDi**, sobre **PostgreSQL (A)** (xx.xx.xx.50) y **PostgreSQL (B)** (xx.xx.xx.53).
- **CORE** (xx.xx.xx.201) y **BUS** (Fw Net BanCoppel).
- Vista PROD Pisa detalla SPs internos del CORE: sp_repuestaxxx, sp_apbcombxxx, abono_ref, Pagos enviados / Pagos recibidos.
- Canales: Browser, App (BPI/APP), Sucursales (SERV SUC 1..N).
Cifrado: HTTPS TLS 1.2/1.3, certificados p12, RSAES-OAEP SHA512, mensajes AES 512.
INTEGRACIÓN: Banxico(SPEI/CoDi)→VPN→Adapters→CORE/BUS→PostgreSQL; canales App/Browser/Sucursal.

## 🖼️ Arquitectura_VCAS.png — VCAS (Verified by Visa / Cardinal Commerce)
Flujos batch orquestados por **Control-M (dcmsif01 MTY)**:
- SPs 698_SP_TARJ_DET_VCAS_PRO / 1132_SP_TARJ_DET_VCAS_EXT → **OLTP Informix 10.36.197.51 (MTY)** (ruta /RESPALDOSNEW/VCAS_resultados) → **Ansible VCAS1H** → SFTP **sftp://prodftp1.cardinalcommerce.com:22** (/Outcoming/).
- Entrada: SFTP cardinalcommerce (/Incoming/) → **Ansible VCAS_RESULTADO** → OLTP Informix (/VCAS_reporte/Resultado).
- SPs 1167_SP_GEN_REPORTE_VCAS_PRO → OLTP → **nascountry.banco.int** (/fraudes/FRAUDES/VCAS).
INTEGRACIÓN: intercambio SFTP con **Cardinal Commerce** (VbV); orquestación Control-M + Ansible; persistencia en Informix OLTP.

## 🖼️ Arquitectura_de_Cobro_de_Remesas.png — Cobro de remesas (homologación MTY/CLN)
Dos sitios (Monterrey y Culiacán), misma estructura:
- Canales: **Cajas de Abono Coppel**, **BEX** (app).
- **JBoss** "Homologación de remesas HA" (MTY 10.26.216.53/8443, 10.26.216.52/8443; CLN 10.30.10.7/8443, 10.30.10.6/8443).
- **IHS** (MTY 10.27.31.14:7808 con nodos 10.27.31.13/10/24/23; CLN 10.27.30.28:7808).
- **JBoss "Remesas WEB HA"** y **"Remesas WEB"** → firewall → nube **Remesas**.
- BD: **Informix OLTP** (MTY 10.36.193.51 / CLN 10.36.197.51) y **Postgres** (MTY 10.27.204.130/5432, CLN 10.27.28.143/5432).
INTEGRACIÓN: canal(Cajas/BEX)→JBoss homologación→IHS→JBoss Remesas WEB→proveedor Remesas; persistencia Informix+Postgres.

## 🖼️ Arquitectura_Cobro_de_Remesas_en_Ventanilla.png — Remesas ventanilla (BTS y Western Union)
Tres bloques:
- **BTS Monterrey**: SIWEB→F5→IHS (15.27.31.14:7801)→JBoss "Remesas WEB BTS HA" (10.26.216.30/8443) y "Remesas WEB BTS" (10.26.216.32/8443)→ nube **BTS** (https://secure.globalplatform.ws/gpx/gpts/transactionservice.asmx). BD Informix OLTP 10.36.193.51, Postgres 10.27.204.130/5432.
- **BTS Ventanilla Culiacán**: mismo patrón (IHS 10.27.30.28:7801, JBoss 10.36.176.113/8443 y 10.36.176.110/8443)→BTS. Informix 10.36.197.51, Postgres 10.27.28.143/5432.
- **Western Union Culiacán**: SIWEB→F5→IHS (10.27.30.28:7808)→JBoss "Remesas WEB Western Union HA/WU" (10.36.176.114/8443, 10.36.176.111/8443)→ nube **Western Union** (eugateway2.westernunion.net, IPs 66.218.182.5 Reston:443 / 66.218.172.6 Chicago:443). Informix 10.36.197.51, Postgres 10.27.28.143/5432.
INTEGRACIÓN: SIWEB→F5→IHS→JBoss→proveedores externos (BTS GlobalPlatform / Western Union); persistencia Informix+Postgres.

## 🖼️ Arquitectura_de_Envío_de_Remesas.png — Envío de remesas (Appriza Pay)
- Nube **Appriza Pay** como destino.
- **Servicios Automáticos** y **Servicios Ventanilla** sobre **BUS Integration IBM**, con **Bitácoras** y **OLTP**; Red de sucursales.
- Flujos de SPs: GetOrder / ConfirmOrder / sp_app_getorder / sp_app_recorder / sp_app_confirmorder / sp_app_recuperapayment / sp_app_confirmpayment (con sleeps y reintentos).
- **Consulta cuentas BTS Monterrey**: RecuperaAccount 10.26.216.40, Postgres 10.27.204.130/5432, Informix OLTP 10.36.193.51, IHS 10.27.31.14:7801, nodos 10.27.31.13/10/24/23; https://…/BancoppelXAccount/TransactionAccount.
INTEGRACIÓN: canal→IBM BUS→Servicios (auto/ventanilla)→Appriza Pay; consulta de cuentas BTS; SPs de orquestación de pago.

## 🖼️ Arquitectura_Corresponsalia_OXXO.png — Corresponsalía OXXO / 7-Eleven (InterAct MasterCard)
- Diagrama de red: sitios primario **Monterrey NL** y secundario **Culiacán Sinaloa**, corresponsales **OXXO** y **7-Eleven** conectados por **MPLS** a **Antenas/Switch Interact**.
- Capas de arquitectura "InterAct MasterCard": OXXO/7-Eleven→**Switch MasterCard**→(BanCoppel) **Autorizador InterAct switch** + **Autorizador SW MC**→**BD Central**→**InterCard**.
INTEGRACIÓN: corresponsales→Switch MasterCard→Autorizador InterAct/SW MC→BD Central/InterCard. **InterAct Switch** es el autorizador de medios de pago.

## 🖼️ Arquitectura_Corresponsalia_OXXO_2.png — Corresponsalía OXXO (flujo de datos ISO 8583)
- Swimlanes: **Cliente**, **Comercio**, **Switch Interact MC**, **BanCoppel**, **Core Bancario**, **InterAct MC**.
- Flujo: Cliente presenta tarjeta→Comercio captura→intercambio de información **ISO 8583** (En Línea) entre Switch↔BanCoppel↔Core Bancario→autorización→respuesta.
- Modelo de datos InterCard: tabla **intercard:tarjeta** (numtarjeta, codstatustarjeta, acummensdepositonac) y **intercard:movimiento** (secuencia, numtarjeta, fechalocaltransaccion, horalocaltransaccion, metododidentificación).
INTEGRACIÓN: protocolo **ISO 8583** en línea entre Switch InterAct, BanCoppel y Core; modelo de datos InterCard.

## 🖼️ Arquitectura_Conciliación_Automática.png — Conciliación Automática (2 vistas)
Vista "Diagrama de Infraestructura de Red": Administrador→**SOC**→**Servidor Web**→**BD OLTP Informix 12 (AIX)**; Administrador→**Control M**→**Procesos Batch / Jobs Conciliación automática**→**Buzones Win** (Connect Direct, eGlobal, PROSA, Bancoppel, Coppel).
Vista "Capas de Arquitectura": Capa cliente (Administrador/Usuario, SOC, Control M)→Capa Presentación (Servidor Web, Jobs Conciliación)→Capa Datos (BD OLTP Informix 12 AIX)→Capa Servicio de Negocios (Buzones Win → Connect Direct/eGlobal/PROSA/Bancoppel/Coppel).
INTEGRACIÓN: Control-M orquesta jobs de conciliación sobre Informix; salida a buzones (Connect Direct) hacia eGlobal/PROSA.

## 🖼️ Arquitectura_Conciliaciones_OperativoContable.png — Conciliación operativo-contable (topología)
Flujo por columnas: **SOC** (10.26.214.230) → **cnsifwebSOC** PostgreSQL (10.26.214.31:5436, réplica 10.29.213.33:5436) → **od_bcpl DB2** (10.27.31.11, réplica DRP 10.27.30.22) → **Contabilidad SQL** (10.36.193.81, réplica 10.27.30.22).
INTEGRACIÓN: SOC→PostgreSQL(cnsifweb)→DB2(od_bcpl)→SQL Server(Contabilidad); cadena de conciliación operativa→contable.

## 🖼️ Mapeo_Infra_Conciliaciones_Operativ.png — Tabla de infraestructura de conciliaciones
| Servidor | Base de Datos | IP Monterrey | IP Culiacán |
| Servidor BD DB2 | od_bcpl | 10.27.31.11:50000 | 10.27.30.22:50000 |
| Servidor BD Postgres | AuditoriaSucursales | 10.28.216.131:5432 | 10.28.216.130:5432 |
| Servidor Aplicación SOC | — | 10.26.214.230 | 10.27.28.22 |
| Servidor BD Contabilidad | Contabilidad | 10.36.197.81:12525 | 10.36.193.81:12525 |
| Servidor BD Postgres SOC | cnsifweb | 10.26.214.31:5436 | 10.26.213.33:5436 |
INTEGRACIÓN: inventario de nodos de datos de la conciliación (DB2 od_bcpl, Postgres AuditoriaSucursales, SQL Contabilidad, Postgres cnsifweb).

## 🖼️ Arquitectura_Dictamen_Unificado.png — Dictamen Unificado (arquitectura "Ventas Digitales")
Es la **misma macro-arquitectura "Ventas Digitales"** que Originación de Crédito: canales digitales (BPI/App) arriba, bloque central "Arquitectura VENTAS DIGITALES" con Google Cloud (Cloud Run frontends), stack de seguridad (Cloud Armor + WAF), microservicios en clusters, motor de evaluación/dictamen a la derecha, y una zona inferior naranja con detalle de servicios/IPs. [El texto interno NO es legible a la resolución del original: sólo se transcribe la estructura macro.]
INTEGRACIÓN (macro): canal digital→GCP(Cloud Run)+seguridad→microservicios→Motor de Dictamen/Evaluación; consulta a bureaus y core.

## 🖼️ Arquitectura_Originación_de_Crédito.png y Arquitectura_Origincación_de_Crédito.png — Originación de Crédito ("Ventas Digitales")
Idénticas entre sí y a Dictamen Unificado en estructura macro (arquitectura "Ventas Digitales" con GCP Cloud Run + seguridad + microservicios + motor de evaluación + zona de servicios inferior). [Detalle interno no legible a la resolución del original.] Ver la transcripción legible equivalente en **Arquitectura_Evaluación_de_Solicitud_de_Crédito_en_Web.png**, que documenta el mismo patrón GCP+on-prem con texto legible.

---
```

## 10. Reglas de dominio críticas (respetar al iterar)

- **OFI (ID 58):** originación/alta en sucursal (cliente pesado VB6); registro de cliente y contratación de productos de depósito/crédito. **NO** es efectivo. Banda de **canales físicos/sucursal**. Nombre = *Oficina Financiera Integral* (el "Central" de 1 doc es typo). Se desglosa en OFI Tradicional y OFI Web (SIWEB); ninguno es core.
- **SIWEB (ID 60, OFI_WEB):** operación web de cajero/ventanilla (Angular/WebSphere): caja, depósitos, retiros, remesas, cierre de día, conciliación nocturna.
- **Vías válidas al CORE (solo 3):** (1) conexión directa a BD (ODBC/JDBC/SPL), (2) **InterAct** (router Syndein), (3) **IBM BUS** (IIB/ACE). Informix **NO** recibe REST/SOAP/ISO 8583/SFTP directo; terminan en middleware.
- **Homónimo "BUS":** distinguir **IBM IIB/ACE** (ESB: SOAP/REST/MQ) de la **mensajería InterAct** (tramas posicionales TCP/ISO 8583). No confundir.
- **Batch a Informix:** "SFTP→Informix" es incorrecto. SFTP entrega a **buzón**; job **Control-M** carga por conexión directa. Tipo: *Acceso directo a DB (carga batch/Control-M)*.
- **Canal↔canal directo** (OFI↔SIWEB) no es normal → probable falso positivo; validar con SUD.
- **Caja General:** las fichas la declaran como **MÓDULO de SOC** (+SIF+SIWEB+SAM/SIBUC/AUDI), no como core SPL; el SPL está en "Integral Módulo Central". Por **decisión del arquitecto** se mantiene como core banking SPL — **no auto-corregir**.
- **CORIMA / InvGate:** herramientas ITSM (mesa de servicio), NO sistemas de negocio; no mapear a capacidades.
- **Source-first:** toda afirmación cita documento primario o se marca `[INFERENCIA]`; distinguir cobertura por Anexo 5 (sin SUD) de evidencia documental directa. Nomenclatura anclada a Anexo 5; flag Core = columna Core.

**Complementos sin diagrama propio (incluir igualmente):** Orión, Latinia, Interact Router, INCODE, VOICES, SICCs, Motor de Rostros/Huellas, SAFRE, SAM/SIBUC/AUDI, GCD (domiciliación), SPEI Central vs SPEI Enlace Financiero, WUPUS/Orlandi Vigo, Token Digital/CoDi, Motor de Pago de Servicios.

**Stack de originación de TDC (relevante Unity):** OFI Tradicional, OFI Web, Interfaz de servicios Coppel, Consulta INE/RENAPO/Buró, Motor de evaluación de crédito, IST/Switch ATMs, Dictamen Unificado, Alta Móvil, Monitor Web. TDC digital añade DUD, INCODE, Motor de Rostros/Huellas. Autorización TDC: InterAct IST SW Autorizador, Switch InterCard MasterCard, Core (Informix), Sistema Operativo OXXO.

## 11. Entregables ya producidos en el proyecto

- **Inventario AS-IS** (`Inventario_AS-IS_Unity_BanCoppel.xlsx`): SUD→app normalizada, BU, dominio, stack, BD, integraciones; cobertura del catálogo (semáforo).
- **Mapeo capacidades N3 × aplicaciones v4** (334 filas; Rol + Sistema primario; hoja de auditoría de 41 correcciones).
- **Concordancia APO** (Anexo 5 × estrategia APO: Invertir/Innovar, Migrar/Transformar, Tolerar/Mantener, Eliminar/Deprecar; 69 emparejadas, 9 sin concordancia).
- **Análisis de complejidad funcional** (124 apps: Muy Alta 14 · Alta 39 · Media 42 · Baja 29).
- **Diagrama AS-IS de aplicaciones** (este SVG/PNG + generador), glosario canónico y draw.io del core legado.


## 12. Estructura del diagrama (layout de 5 zonas)

Encabezado+leyenda › **Canales** (banda) › **Capa de Integración** (banda) › **sección media 5 columnas** [S1 soporte | B1 negocio | **CORE** | B2 negocio | S2 soporte] › **Externos** (banda).

Geometría (constantes del script): `S1w=300`, gap 70, `B1w=336`, **gap 150** (core↔dominio, para que la flecha y su etiqueta no se tapen), `COw=600`, **gap 150**, `B2w=336`, gap 70, `S2w=300`. Lienzo ≈ **2372×1646 px**. Soporte/transversal a los costados; el CORE es pilar central con *fan-in* de todos los dominios.

## 13. Contenido por bloque (chips normalizados)

- **Canales — Digitales:** App BanCoppel Móvil · Banca por Internet (BPI) · Portal Público · OFI · Empresa Net *
- **Canales — Físicos/Corresponsalías:** SIWEB · Corresponsales Tiendas Coppel · Corresponsalía OXXO · ATM/IST Switch · GUI (Switch)
- **Canales — Atención:** CAT/ICCAT · IVR · BancoppelSMS · Aclaraciones · Latinia (notif.)
- **Integración:** IBM BUS (ESB) · Interact (Syndein) · WAS/MDL (WebSphere) · BancoppelWS · Strikeiron
- **CORE — Apps núcleo:** SOC (~710 func.) · Integral/CIF · Cheques/Captación · Caja General · Inversiones · Créditos Revolventes · Créditos a Plazo · Puntos Compromiso · Domiciliación (SPL) · Pagos Programados (SPL) · Pago TDC otros bancos (SPL) · Pago de la Afore (SPL)
- **CORE — Persistencia:** Informix OLTP (bdinteg/bdicheq/bdisac/bdispei) · PostgreSQL · Oracle · DB2 · MongoDB
- **B1 — Crédito y Originación:** Motor de Evaluación de Crédito · SICC · Autenticador BC · Autenticador CC · Alta Móvil · Crédito Comercial (Orión) · Coparticipativo Infonavit · Órdenes de Supervisión
- **B1 — Cobranza:** Sistema de Cobranza iCS · Cobranza (SPL) · TRIAD
- **B1 — PLD/Fraude/Riesgo:** Prevención de Lavado (PLD) · Prevención de Fraudes · Risk Logic · Kibana Monitor · Monitor de Operaciones BPI
- **B1 — Contabilidad/Regulatorio:** Contabilidad · Dynamics CxP · Facturación CFDI · Formato IPAB · Risklogic Regulatorios
- **B1 — Documental/ARCO:** Prometeo (Gestor Documental) · Derechos ARCO
- **B2 — Pagos y Transferencias:** TEF · SPEI Enlace Financiero · Órdenes de Pago Nacionales · Motor de Pago de Servicios · Pago TDC otros bancos · Pago de la Afore
- **B2 — Remesas:** Motor BTS · Appriza Pay · WU/Orlandi/Vigo · Homologación-Remesas · BD Usuarios Remesas · Seguros de Repatriación
- **B2 — Tarjetas/ATM/POS:** Administración de Tarjetas (MAC) · Inventario de Tarjetas · Interact SW Autorizador · VCAS · Conciliación ATM/POS · Reporte VISA (SIF)
- **B2 — Identidad/Biometría:** Motor de Huellas · Motor de Rostros · Gestor Central de Huellas (⚠ provisional) · ConsultaRenapo · Motores de Consumo WS · Token RSA · Administrador de Token (CAS) · Token Digital/Gemalto
- **B2 — Tesorería/Inversiones:** Aladdin (BlackRock) · ION Trading · Indeval Enlace Financiero
- **S1 — Orquestación/Monitoreo/Operación:** Control-M/Command Center · RPA (Robots) · NetXMS Monitor ATM · Kibana
- **S1 — Datos y Analítica:** Data WareHouse · REFLEXIS
- **S2 — Infraestructura/Plataforma/OpenBanking:** AIX/Power · DB2 · Contenedores (OpenShift) · OpenBanking (3scale)
- **S2 — Administración/RH:** Faltantes y Daños a Inmuebles · Universidad Virtual · Plataforma Arrendadora
- **Externos:** Buró · Interfactura/PACs · Innovatia (SMS) · Banxico SPEI/CoDi · RENAPO/INE · Círculo · Genesys · Subitus · Remesadoras · BlackRock · Coppel · Azure DevOps/Jira · Logify · CECOBAN · Visa/MC/eGlobal/PROSA


## 14. Catálogo de interacciones (edges): tipo · protocolo · naturaleza · dirección

Naturaleza→estilo: **síncrono=sólida**, **archivos/batch=punteada**; **doble flecha=bidireccional**.

**Backbone:** Canales Digitales↔Integración (HTTPS·REST/SOAP/JSON, sync, bi) · Canales Físicos↔Integración (Interact/Syndein·tramas, sync, bi) · Atención↔Integración (SOAP·SMS, sync, bi) · Integración↔CORE (SPLs·ODBC/CODBC, sync, bi).

**Fan-in CORE (izq B1):** Crédito (WS/BRM·SPL bdisolic/bdicred, sync, bi) · Cobranza (réplica OLTP·archivos, **batch**, bi) · PLD (lee OLTP/BD SPEI, sync, bi) · Contabilidad (réplicas·SPL contable, **batch**, bi) · Documental/ARCO (Informix·solicitudes, sync, bi).

**Fan-in CORE (der B2):** Pagos (SPL bdispei/bdisac, sync, bi) · Remesas (SPL+cuentas·Interact, sync, bi) · Tarjetas (Informix OLTP·autorizador, sync, bi) · Identidad (bdinteg·Interact huellas, sync, bi) · Tesorería (posiciones·contable, **batch**, bi).

**Soporte↔Integración:** Orquestación (Control-M·batch/monitoreo, **batch**, bi) · Datos y Analítica (réplica Informix→DWH, **batch**, **uni**) · Infra/OpenBanking (hosting·APIs 3scale, sync, bi) · Admin/RH (Informix·Interact, sync, bi).

**Dominios↔Externos:** Crédito→Buró (SIC online·archivos, sync) · Cobranza→Círculo (claves obs.·archivos, **batch**) · Contabilidad→Interfactura (CFDI·VPN/AES-256, sync) · Pagos→Banxico (SPEI/CoDi·TLS1.2·MPLS/VPN, sync) · Pagos/CORE→CECOBAN (archivos Cód.60-63·SFTP, **batch**) · Remesas→Remesadoras (WS·JSON↔XML, sync) · Tarjetas→Visa/MC/eGlobal (ISO 8583, sync) · Identidad→RENAPO/INE (SOAP/WS, sync) · Tesorería→BlackRock (archivos batch, **batch**). Todas bidireccionales salvo indicación.

## 15. Puntos abiertos / pendientes de validación

- **Gestor Central de Huellas** (⚠): el SUD "Clientes (Gestor central)" documenta un WS de autenticación por huella para OFI/SIWEB, no un maestro de clientes. Posible gap del verdadero maestro.
- **Empresa Net — tokens:** inconsistencia RSA físico vs. token digital/Gemalto.
- **IDs 84 y 88** apuntan al mismo SUD de Cheques (posible duplicación).
- Conteos técnicos conservadores en ~41 apps sin SUD dedicado; 9 apps de APO sin concordancia de inventario.
- Pendiente visual opcional: **agrupar los rieles externos de la derecha** en un solo riel rotulado; compactar el espacio central-inferior bajo el core.


## 16. Cómo regenerar el diagrama

1. Guardar el **Anexo A** como `generar_asis.py` y ejecutar `python3 generar_asis.py` → escribe el SVG (se renderiza nativo en la interfaz; es editable/escalable).
2. **Auto-QA sin red** (no hay `cairosvg` ni binario `rsvg-convert`; sí `libcairo.so.2` + `librsvg-2.so.2`): rasterizar por **ctypes** (helper abajo). Los marcadores usan `fill="context-stroke"` (la punta hereda el color de cada flecha).

```python
# render.py — uso: python3 render.py in.svg out.png  (sin red)
import ctypes,re,sys
cairo=ctypes.CDLL("libcairo.so.2"); rsvg=ctypes.CDLL("librsvg-2.so.2")
for n,r,a in [("cairo_image_surface_create",ctypes.c_void_p,[ctypes.c_int]*3),("cairo_create",ctypes.c_void_p,[ctypes.c_void_p]),("cairo_set_source_rgb",None,[ctypes.c_void_p]+[ctypes.c_double]*3),("cairo_paint",None,[ctypes.c_void_p]),("cairo_surface_write_to_png",None,[ctypes.c_void_p,ctypes.c_char_p])]:
    f=getattr(cairo,n); f.restype=r; f.argtypes=a
svg=open(sys.argv[1]).read(); W=int(re.search(r'width="(\d+)"',svg).group(1)); H=int(re.search(r'height="(\d+)"',svg).group(1))
s=cairo.cairo_image_surface_create(0,W,H); cr=cairo.cairo_create(s); cairo.cairo_set_source_rgb(cr,1,1,1); cairo.cairo_paint(cr)
rsvg.rsvg_handle_new_from_data.restype=ctypes.c_void_p; rsvg.rsvg_handle_new_from_data.argtypes=[ctypes.c_char_p,ctypes.c_size_t,ctypes.c_void_p]
d=svg.encode(); err=ctypes.c_void_p(0); h=rsvg.rsvg_handle_new_from_data(d,len(d),ctypes.byref(err))
class R(ctypes.Structure):_fields_=[("x",ctypes.c_double),("y",ctypes.c_double),("w",ctypes.c_double),("h",ctypes.c_double)]
vp=R(0,0,W,H); rsvg.rsvg_handle_render_document.restype=ctypes.c_bool
rsvg.rsvg_handle_render_document.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.POINTER(R),ctypes.c_void_p]
rsvg.rsvg_handle_render_document(h,cr,ctypes.byref(vp),ctypes.byref(err)); cairo.cairo_surface_write_to_png(s,sys.argv[2].encode())
```

**Mapa de edición (dónde tocar para iterar):** apps → listas en `col(...)`, `apps_chips`, `data_chips`, `ext`; interacciones → listas `L`/`R` (fan-in), `sup_arrow(...)`, `to_ext(...)`; naturaleza → `"sync"`/`"batch"`; dirección → `bidir=`; caja provisional → sufijo `§`; separaciones → constantes de geometría y `ext_gap`.

## 17. Historial de decisiones

- v1–v3: portafolio en rejilla; se detectó core subrepresentado (solo 2 flechas).
- v4: 5 zonas, **core pilar central** con fan-in de todos los dominios; soporte a los costados; **estilos por naturaleza** y **bidireccionales**; mayor espaciado; validación 87/88.
- Ajustes finales: etiquetas de fan-in **sobre** la línea + huecos 150 px; **core compactado** a su contenido; **Datos y Analítica** y **Administración/RH** reruteadas por huecos entre columnas (antes apuntaban a vacío / etiqueta sobre caja).


---

## Anexo A — Script generador completo (`generar_asis.py`)

```python
# -*- coding: utf-8 -*-
"""
Generador del diagrama BanCoppel_Arquitectura_AS-IS.svg
Regenera el SVG a partir de los datos declarados abajo (dominios, aplicaciones,
interacciones). Editar las listas/edges para iterar. No requiere red.
Salida: /mnt/user-data/outputs/BanCoppel_Arquitectura_AS-IS.svg
"""
from html import escape

MARGIN=30
FONT="'Helvetica Neue', Helvetica, Arial, sans-serif"
svg=[]
def rrect(x,y,w,h,r,fill,stroke,sw=1,dash=None):
    d=f' stroke-dasharray="{dash}"' if dash else ''
    return f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{r}" ry="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>'
def text(x,y,s,size=12,fill="#1F2937",weight="normal",anchor="start",italic=False):
    st=' font-style="italic"' if italic else ''
    return f'<text x="{x:.1f}" y="{y:.1f}" font-family="{FONT}" font-size="{size}" fill="{fill}" font-weight="{weight}" text-anchor="{anchor}"{st}>{escape(s)}</text>'

ST={
 "default": dict(hdr="#1F3864", body="#F4F7FB", border="#C3CFDE", chip="#FFFFFF", chipb="#AEBACA", chiptxt="#1F2937"),
 "channel": dict(hdr="#5B3A86", body="#EEE9F6", border="#B6A7D6", chip="#FFFFFF", chipb="#B6A7D6", chiptxt="#2A2140"),
 "core":    dict(hdr="#385723", body="#E8F2DC", border="#6E9E40", chip="#FFFFFF", chipb="#86A95E", chiptxt="#23340F"),
 "integ":   dict(hdr="#1F4E79", body="#DCEAF7", border="#3A7BBF", chip="#C5DCF1", chipb="#3A7BBF", chiptxt="#10314F"),
 "support": dict(hdr="#5A4636", body="#F3EEE8", border="#C3AE96", chip="#FFFFFF", chipb="#C3AE96", chiptxt="#3A2C1E"),
 "external":dict(hdr="#843C0C", body="#FBE7D6", border="#CB6A20", chip="#FFFFFF", chipb="#CB6A20", chiptxt="#3F1E07"),
}
PEND=dict(chip="#FFF2CC", chipb="#BF9000")
CHIP_H=27; VGAP=7; HGAP=8; PAD=11; HDR_H=25; GROUP_GAP=26
BOX={}
def group_h(n,cols):
    rows=(n+cols-1)//cols
    return HDR_H+PAD+rows*CHIP_H+(rows-1)*VGAP+PAD
def draw_group(x,y,w,title,chips,style="default",cols=2,subtitle=None,record=True):
    s=ST[style]; h=group_h(len(chips),cols)
    svg.append(rrect(x,y,w,h,7,s["body"],s["border"],1.4))
    svg.append(rrect(x,y,w,HDR_H,7,s["hdr"],s["hdr"])); svg.append(rrect(x,y+HDR_H-7,w,7,0,s["hdr"],s["hdr"]))
    svg.append(text(x+10,y+17,title,12,"#FFFFFF","bold"))
    if subtitle: svg.append(text(x+w-9,y+16.5,subtitle,9.3,"#DCE6F2","normal","end"))
    cw=(w-2*PAD-(cols-1)*HGAP)/cols; cy=y+HDR_H+PAD
    for i,c in enumerate(chips):
        col=i%cols; row=i//cols; cx=x+PAD+col*(cw+HGAP); yy=cy+row*(CHIP_H+VGAP)
        pend=c.endswith("§"); label=c[:-1] if pend else c
        cf=PEND["chip"] if pend else s["chip"]; cb=PEND["chipb"] if pend else s["chipb"]
        svg.append(rrect(cx,yy,cw,CHIP_H,5,cf,cb,1.2,"4 3" if pend else None))
        fs=11
        if len(label)>int(cw/6.4): fs=10
        if len(label)>int(cw/5.7): fs=9.2
        svg.append(text(cx+cw/2,yy+CHIP_H/2+3.8,("⚠ " if pend else "")+label,fs,s["chiptxt"],"bold" if pend else "normal","middle"))
    if record: BOX[title]=(x,y,w,h)
    return h
def arrow(pts,color="#52627A",wd=1.7,dash=None,bidir=False):
    d=f' stroke-dasharray="{dash}"' if dash else ''
    p=" ".join(f"{x:.1f},{y:.1f}" for x,y in pts)
    ms=' marker-start="url(#aS)"' if bidir else ''
    return f'<polyline points="{p}" fill="none" stroke="{color}" stroke-width="{wd}"{d} marker-end="url(#aE)"{ms}/>'
def alabel(x,y,txt,color="#33455F",size=9,fill="#FFFFFF",border="#C8D2DF"):
    w=len(txt)*size*0.55+12; h=size+8
    return rrect(x-w/2,y-h/2,w,h,4,fill,border,1)+text(x,y+size*0.35,txt,size,color,"normal","middle")

# ===== column geometry (5 zonas) =====
S1x=MARGIN;            S1w=300
B1x=S1x+S1w+70;        B1w=336
COx=B1x+B1w+150;       COw=600
B2x=COx+COw+150;       B2w=336
S2x=B2x+B2w+70;        S2w=300
W=S2x+S2w+MARGIN; usable=W-2*MARGIN

# ===== header + leyenda =====
svg.append(text(MARGIN,42,"BanCoppel — Arquitectura AS-IS (Plataforma Legado)",25,"#16243F","bold"))
svg.append(text(MARGIN,66,"Mapa de aplicaciones e interacciones por dominio · Iniciativa Unity · Fuente: SUD + catálogo AMS-IMS · El core (Informix OLTP) es la base transaccional: 80 de 88 SUD lo consumen.",12.3,"#5A6B82"))
lx=W-MARGIN-640; ly=20
svg.append(rrect(lx-12,ly-2,652,74,6,"#F7F9FC","#D5DEEA",1))
for i,(c,t) in enumerate([("#385723","Núcleo / Captación"),("#1F4E79","Capa de integración"),("#5B3A86","Canales"),
                          ("#5A4636","Soporte / transversal"),("#1F3864","Dominios de negocio"),("#843C0C","Proveedores externos")]):
    cc=i%3; rr=i//3; ex=lx+cc*212; ey=ly+6+rr*19
    svg.append(rrect(ex,ey,15,11,3,c,c)); svg.append(text(ex+21,ey+9.5,t,9.6,"#33455F"))
ey2=ly+50
svg.append(f'<line x1="{lx}" y1="{ey2}" x2="{lx+34}" y2="{ey2}" stroke="#52627A" stroke-width="2"/>'); svg.append(text(lx+40,ey2+3.5,"Síncrono / tiempo real",9.4,"#33455F"))
svg.append(f'<line x1="{lx+212}" y1="{ey2}" x2="{lx+246}" y2="{ey2}" stroke="#52627A" stroke-width="2" stroke-dasharray="6 4"/>'); svg.append(text(lx+252,ey2+3.5,"Archivos / batch",9.4,"#33455F"))
svg.append(f'<line x1="{lx+424}" y1="{ey2}" x2="{lx+458}" y2="{ey2}" stroke="#52627A" stroke-width="2" marker-start="url(#aS)" marker-end="url(#aE)"/>'); svg.append(text(lx+464,ey2+3.5,"Bidireccional",9.4,"#33455F"))

# ===== canales =====
ch_y=98; g3=(usable-2*20)/3
hc=[draw_group(MARGIN+i*(g3+20),ch_y,g3,t,ch,"channel",2) for i,(t,ch) in enumerate([
   ("Canales Digitales",["App BanCoppel Móvil","Banca por Internet (BPI)","Portal Público","OFI","Empresa Net *"]),
   ("Canales Físicos y Corresponsalías",["SIWEB","Corresponsales Tiendas Coppel","Corresponsalía OXXO","ATM / IST Switch","GUI (Switch)"]),
   ("Atención a Clientes",["CAT / ICCAT","IVR","BancoppelSMS","Aclaraciones","Latinia (notif.)"])])]
chh=max(hc)

# ===== integración =====
ig_y=ch_y+chh+62
draw_group(MARGIN,ig_y,usable,"Capa de Integración / Middleware",
   ["IBM BUS (ESB)","Interact (Syndein)","WAS / MDL (WebSphere)","BancoppelWS","Strikeiron"],"integ",5,
   subtitle="Hub de mensajería y orquestación de servicios")
igh=group_h(5,5)
for cx,lbl in ((MARGIN+g3/2,"HTTPS · REST/SOAP/JSON"),(MARGIN+g3+20+g3/2,"Interact/Syndein · tramas"),(MARGIN+2*(g3+20)+g3/2,"SOAP · SMS")):
    svg.append(arrow([(cx,ch_y+chh),(cx,ig_y)],"#7C6AA0",2.0,bidir=True)); svg.append(alabel(cx,(ch_y+chh+ig_y)/2,lbl,"#4A3A66"))

# ===== columnas medias =====
mt=ig_y+igh+78
def col(x,w,groups):
    y=mt
    for t,ch,stl in groups: y+=draw_group(x,y,w,t,ch,stl,2)+GROUP_GAP
    return y-GROUP_GAP
b1=col(B1x,B1w,[
   ("Crédito y Originación",["Motor de Evaluación de Crédito","SICC","Autenticador BC","Autenticador CC","Alta Móvil","Crédito Comercial (Orión)","Coparticipativo Infonavit","Órdenes de Supervisión"],"default"),
   ("Cobranza",["Sistema de Cobranza iCS","Cobranza (SPL)","TRIAD"],"default"),
   ("PLD, Fraude y Riesgo",["Prevención de Lavado (PLD)","Prevención de Fraudes","Risk Logic","Kibana Monitor","Monitor de Operaciones BPI"],"default"),
   ("Contabilidad, Finanzas y Regulatorio",["Contabilidad","Dynamics CxP","Facturación CFDI","Formato IPAB","Risklogic Regulatorios"],"default"),
   ("Gestión Documental / ARCO",["Prometeo (Gestor Documental)","Derechos ARCO"],"default")])
b2=col(B2x,B2w,[
   ("Pagos y Transferencias",["TEF","SPEI Enlace Financiero","Órdenes de Pago Nacionales","Motor de Pago de Servicios","Pago TDC otros bancos","Pago de la Afore"],"default"),
   ("Remesas",["Motor BTS","Appriza Pay","WU / Orlandi / Vigo","Homologación-Remesas","BD Usuarios Remesas","Seguros de Repatriación"],"default"),
   ("Tarjetas, ATM y POS",["Administración de Tarjetas (MAC)","Inventario de Tarjetas","Interact SW Autorizador","VCAS","Conciliación ATM/POS","Reporte VISA (SIF)"],"default"),
   ("Identidad, Biometría y Autenticación",["Motor de Huellas","Motor de Rostros","Gestor Central de Huellas§","ConsultaRenapo","Motores de Consumo WS","Token RSA","Administrador de Token (CAS)","Token Digital / Gemalto"],"default"),
   ("Tesorería, Inversiones y Mercado",["Aladdin (BlackRock)","ION Trading","Indeval Enlace Financiero"],"default")])
s1=col(S1x,S1w,[
   ("Orquestación, Monitoreo y Operación",["Control-M / Command Center","RPA (Robots)","NetXMS Monitor ATM","Kibana"],"support"),
   ("Datos y Analítica",["Data WareHouse","REFLEXIS"],"support")])
s2=col(S2x,S2w,[
   ("Infraestructura, Plataforma y Open Banking",["AIX / Power","DB2","Contenedores (OpenShift)","OpenBanking (3scale)"],"support"),
   ("Administración, RH y Soporte",["Faltantes y Daños a Inmuebles","Universidad Virtual","Plataforma Arrendadora"],"support")])
mb=max(b1,b2,s1,s2)

# ===== CORE (altura = contenido) =====
def inner(x,y,w,title,chips,cols=2):
    h=group_h(len(chips),cols)
    svg.append(rrect(x,y,w,h,6,"#FFFFFF","#9CBE78",1.2)); svg.append(text(x+8,y+15,title,10.5,"#2C4A18","bold"))
    cw=(w-2*9-(cols-1)*HGAP)/cols; cy=y+20
    for i,c in enumerate(chips):
        cc=i%cols; rr=i//cols; cx=x+9+cc*(cw+HGAP); yy=cy+rr*(CHIP_H+VGAP)
        svg.append(rrect(cx,yy,cw,CHIP_H,5,"#FFFFFF","#86A95E",1.1))
        fs=10.5 if len(c)<=int(cw/6.0) else 9.4
        svg.append(text(cx+cw/2,yy+CHIP_H/2+3.8,c,fs,"#23340F","normal","middle"))
    return h+20
apps_chips=["SOC (mini-core, ~710 func.)","Integral / CIF (tasas)","Cheques / Captación","Caja General",
    "Inversiones","Créditos Revolventes","Créditos a Plazo","Puntos Compromiso",
    "Domiciliación (SPL)","Pagos Programados (SPL)","Pago TDC otros bancos (SPL)","Pago de la Afore (SPL)"]
data_chips=["Informix OLTP (bdinteg/bdicheq/bdisac/bdispei)","PostgreSQL","Oracle","DB2","MongoDB"]
h_apps=group_h(len(apps_chips),2)+20; hd=group_h(len(data_chips),2)+20
core_h=HDR_H+14+h_apps+14+hd+58
s=ST["core"]
svg.append(rrect(COx,mt,COw,core_h,9,s["body"],s["border"],1.8))
svg.append(rrect(COx,mt,COw,HDR_H,9,s["hdr"],s["hdr"])); svg.append(rrect(COx,mt+HDR_H-7,COw,7,0,s["hdr"],s["hdr"]))
svg.append(text(COx+12,mt+17,"CORE BANCARIO Y CAPTACIÓN — Núcleo transaccional",12.5,"#FFFFFF","bold"))
svg.append(text(COx+COw-10,mt+16.5,"Informix OLTP",9.5,"#D8E8C8","normal","end"))
BOX["__CORE__"]=(COx,mt,COw,core_h)
ix=COx+16; iw=COw-32; iy=mt+HDR_H+14
inner(ix,iy,iw,"Aplicaciones y procesos núcleo",apps_chips)
dy=iy+h_apps+14; inner(ix,dy,iw,"Persistencia de datos",data_chips)
svg.append(text(COx+COw/2,dy+hd+30,"Núcleo transaccional — todas las operaciones de canales",9.6,"#5C7A3E","normal","middle",True))
svg.append(text(COx+COw/2,dy+hd+44,"y dominios persisten aquí",9.6,"#5C7A3E","normal","middle",True))

# integración -> core
ccx=COx+COw/2
svg.append(arrow([(ccx,ig_y+igh),(ccx,mt)],"#385723",2.8,bidir=True)); svg.append(alabel(ccx,(ig_y+igh+mt)/2,"SPLs sobre Informix · ODBC / CODBC","#2C4A18"))

# fan-in dominios <-> core (entradas distribuidas, etiqueta sobre la línea)
def fanin(title, side, label, nature, i, n):
    x,y,w,h=BOX[title]; cyy=y+h/2; cx0,cy0,cw0,ch0=BOX["__CORE__"]
    ey=cy0+42+i*(ch0-84)/(n-1); dash=None if nature=="sync" else "6 4"
    if side=="L": sx=x+w; tx=cx0; midx=sx+34+i*16
    else:         sx=x;   tx=cx0+cw0; midx=sx-34-i*16
    pts=[(sx,cyy),(tx,cyy)] if abs(cyy-ey)<3 else [(sx,cyy),(midx,cyy),(midx,ey),(tx,ey)]
    svg.append(arrow(pts,"#3F6D2E",1.8,dash,bidir=True))
    lx=(sx+tx)/2 if abs(cyy-ey)<3 else (sx+midx)/2
    svg.append(alabel(lx,cyy-13,label,"#2C4A18",8.6,"#F2F8EC","#9CBE78"))
L=[("Crédito y Originación","WS/BRM · SPL (bdisolic/bdicred)","sync"),("Cobranza","réplica OLTP · archivos","batch"),
   ("PLD, Fraude y Riesgo","lee OLTP / BD SPEI","sync"),("Contabilidad, Finanzas y Regulatorio","réplicas · SPL contable","batch"),
   ("Gestión Documental / ARCO","Informix · solicitudes","sync")]
for i,(t,l,n) in enumerate(L): fanin(t,"L",l,n,i,len(L))
R=[("Pagos y Transferencias","SPL (bdispei/bdisac)","sync"),("Remesas","SPL + cuentas · Interact","sync"),
   ("Tarjetas, ATM y POS","Informix OLTP · autorizador","sync"),("Identidad, Biometría y Autenticación","bdinteg · Interact (huellas)","sync"),
   ("Tesorería, Inversiones y Mercado","posiciones · contable","batch")]
for i,(t,l,n) in enumerate(R): fanin(t,"R",l,n,i,len(R))

# soporte -> integración (up / gapR / gapL)
def sup_arrow(title,label,nature,route,bidir=True):
    x,y,w,h=BOX[title]; dash=None if nature=="sync" else "6 4"; cx=x+w/2; iby=ig_y+igh
    if route=="up": pts=[(cx,y),(cx,iby)]; lx=cx; ly=(y+iby)/2
    elif route=="gapR":
        lane=(S1x+S1w+B1x)/2; pts=[(x+w,y+18),(lane,y+18),(lane,iby)]; lx=lane; ly=(iby+mt)/2
    else:
        lane=(B2x+B2w+S2x)/2; pts=[(x,y+18),(lane,y+18),(lane,iby)]; lx=lane; ly=(iby+mt)/2
    svg.append(arrow(pts,"#7A634C",1.7,dash,bidir=bidir)); svg.append(alabel(lx,ly,label,"#4A3A2A",8.7,"#F5F0EA","#C3AE96"))
sup_arrow("Orquestación, Monitoreo y Operación","Control-M · batch / monitoreo","batch","up")
sup_arrow("Datos y Analítica","réplica Informix → DWH","batch","gapR",bidir=False)
sup_arrow("Infraestructura, Plataforma y Open Banking","hosting · APIs 3scale","sync","up")
sup_arrow("Administración, RH y Soporte","Informix · Interact","sync","gapL")

# ===== externos =====
ext_gap=180; ex_y=mb+ext_gap
ext=["Buró de Crédito","Interfactura / PACs","Innovatia (SMS)","Banxico — SPEI / CoDi","RENAPO / INE",
     "Círculo de Crédito","Genesys Engage","Subitus (capacitación)","Remesadoras (BTS/Appriza/WU)","BlackRock (Aladdin)",
     "Coppel (tiendas/cajas)","Azure DevOps / Jira","Logify (paquetería)","CECOBAN — archivos","Visa / MC / eGlobal / PROSA"]
draw_group(MARGIN,ex_y,usable,"Entidades y Proveedores Externos",ext,"external",5,subtitle="Conectividad vía Capa de Integración y canales dedicados")
exh=group_h(len(ext),5); EXT=(MARGIN,usable,5)
def echip(idx):
    x,w,cols=EXT; cw=(w-2*PAD-(cols-1)*HGAP)/cols; c=idx%cols; r=idx//cols
    return x+PAD+c*(cw+HGAP)+cw/2+(r-1)*16
def to_ext(src,side,lane,idx,label,nature,sub=0,bidir=True):
    x,y,w,h=BOX[src]; tx=echip(idx); ymid=mb+24+sub; dash=None if nature=="sync" else "6 4"
    sx=x if side=="L" else x+w; ey=y+h-14
    pts=[(sx,ey),(lane,ey),(lane,ymid),(tx,ymid),(tx,ex_y)]
    svg.append(arrow(pts,"#9A6A2B",1.6,dash,bidir=bidir)); svg.append(alabel((lane+tx)/2,ymid,label,"#6B4310",8.7,"#FFF6EA","#C58B3C"))
gapB1L=(S1x+S1w+B1x)/2; gapB2R=(B2x+B2w+S2x)/2
to_ext("Crédito y Originación","L",gapB1L-10,0,"SIC online · archivos","sync",0)
to_ext("Cobranza","L",gapB1L,5,"claves obs. · archivos","batch",30)
to_ext("Contabilidad, Finanzas y Regulatorio","L",gapB1L+10,1,"CFDI · VPN / AES-256","sync",60)
to_ext("Pagos y Transferencias","R",gapB2R-20,3,"SPEI/CoDi · TLS1.2 · MPLS/VPN","sync",0)
to_ext("Pagos y Transferencias","R",gapB2R-12,13,"archivos Cód.60-63 · SFTP","batch",30)
to_ext("Remesas","R",gapB2R-4,8,"WS · JSON ↔ XML","sync",60)
to_ext("Tarjetas, ATM y POS","R",gapB2R+4,14,"ISO 8583","sync",90)
to_ext("Identidad, Biometría y Autenticación","R",gapB2R+12,4,"SOAP / WS","sync",120)
to_ext("Tesorería, Inversiones y Mercado","R",gapB2R+20,9,"archivos batch","batch",150)

fn_y=ex_y+exh+22
svg.append(text(MARGIN,fn_y,"* Empresa Net coexiste en DMZ con Portal Público y BPI (bancoppel.com) tras F5.   ⚠ Caja provisional pendiente de validar con SME.",10.3,"#6B7A90","normal","start",True))
svg.append(text(MARGIN,fn_y+16,"Validación: 87/88 SUD referencian el núcleo (Informix/Interact/BUS); 80 ejecutan SPL sobre Informix. Línea sólida = síncrono; punteada = archivos/batch; doble flecha = bidireccional.",10.3,"#6B7A90","normal","start",True))
H=fn_y+34
defs=('<defs>'
 '<marker id="aE" markerWidth="9" markerHeight="9" refX="6.6" refY="3.2" orient="auto"><path d="M0,0 L7,3.2 L0,6.4 Z" fill="context-stroke"/></marker>'
 '<marker id="aS" markerWidth="9" markerHeight="9" refX="0.4" refY="3.2" orient="auto"><path d="M7,0 L0,3.2 L7,6.4 Z" fill="context-stroke"/></marker>'
 '<linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FBFCFE"/><stop offset="1" stop-color="#EEF2F7"/></linearGradient></defs>')
out=[f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">',defs,
     rrect(0,0,W,H,0,"url(#bg)","url(#bg)"),
     f'<line x1="{MARGIN}" y1="80" x2="{W-MARGIN}" y2="80" stroke="#D5DEEA" stroke-width="1.3"/>']+svg+['</svg>']
open("/mnt/user-data/outputs/BanCoppel_Arquitectura_AS-IS.svg","w",encoding="utf-8").write("\n".join(out))
print("OK",W,H)
```