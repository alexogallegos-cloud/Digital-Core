#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
build-brain.py - Digital Brain de SDLC Reinvent (Banamex).

Construye sdlc-brain.db desde las fuentes del proyecto:
  - PoV SDLC Reinvent v3.3 (oct-2026)      -> fuente autoritativa de la propuesta
  - Narrativa de valor del consejo          -> mandato que SDLC Reinvent ejecuta
  - Modelo de partnership Banamex-Accenture -> las cinco areas y el esquema comercial
  - deal-states de iniciativas vecinas      -> contexto adyacente, no parte de la propuesta
  - lab-brain.db e brain.db del core        -> federacion por referencia

Regla dura: lo que no esta en una fuente se modela como brecha o decision abierta,
nunca se inventa. Los nombres de personas del cliente no entran al brain.

Uso:  PYTHONUTF8=1 python build-brain.py
"""
import sqlite3
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent
DB = BASE / "sdlc-brain.db"

# Brains federados por referencia. Nunca se copia su corpus.
LAB_BRAIN = BASE.parents[1] / "laboratorio-aceleracion" / "digital-brain" / "lab-brain.db"
CORE_BRAIN = BASE.parents[2] / "systems" / "core" / "unisys" / "digital-brain" / "brain.db"


# --------------------------------------------------------------------------
# Esquema
# --------------------------------------------------------------------------

SCHEMA = """
-- ---------- Capa 0: mandato y partnership ----------
CREATE TABLE narrativa_consejo (
    id          TEXT PRIMARY KEY,
    pilar       TEXT,
    bloque      TEXT,
    compromiso  TEXT NOT NULL,
    vinculo     TEXT,
    ancla_sdlc  INTEGER DEFAULT 0
);

CREATE TABLE partnership_areas (
    id              TEXT PRIMARY KEY,
    area            TEXT NOT NULL,
    que_cubre       TEXT,
    iniciativa_lab  TEXT,
    es_este_proyecto INTEGER DEFAULT 0
);

CREATE TABLE partnership_modelo (
    id          TEXT PRIMARY KEY,
    elemento    TEXT NOT NULL,
    descripcion TEXT,
    implicacion TEXT
);

-- ---------- Capa 1: el ciclo de entrega ----------
CREATE TABLE etapas (
    id           TEXT PRIMARY KEY,
    orden        INTEGER NOT NULL,
    nombre       TEXT NOT NULL,
    proposito    TEXT,
    estado_dato  TEXT,
    insumos      TEXT,
    actividades  TEXT,
    resultados   TEXT,
    herramientas TEXT
);

CREATE TABLE controles_asis (
    id            TEXT PRIMARY KEY,
    nombre        TEXT NOT NULL,
    etapa         TEXT NOT NULL,
    aparece_como  TEXT,
    origen        TEXT,
    sobrevive_separacion TEXT
);

CREATE TABLE herramientas_asis (
    id        TEXT PRIMARY KEY,
    nombre    TEXT NOT NULL,
    etapas    TEXT,
    categoria TEXT,
    duenio    TEXT,
    riesgo    TEXT
);

CREATE TABLE friccion (
    id          TEXT PRIMARY KEY,
    etapa       TEXT NOT NULL,
    tipo        TEXT,
    descripcion TEXT NOT NULL,
    origen      TEXT,
    evidencia   TEXT,
    estado      TEXT
);

CREATE TABLE diagnostico (
    id         TEXT PRIMARY KEY,
    hallazgo   TEXT NOT NULL,
    valor      TEXT,
    fuente     TEXT,
    estado     TEXT
);

CREATE TABLE metricas (
    id          TEXT PRIMARY KEY,
    familia     TEXT NOT NULL,
    nombre      TEXT NOT NULL,
    unidad      TEXT,
    que_mide    TEXT,
    origen      TEXT,
    linea_base  TEXT,
    meta        TEXT,
    estado      TEXT
);

-- ---------- Capa 2: la propuesta ----------
CREATE TABLE gates (
    id         TEXT PRIMARY KEY,
    orden      INTEGER,
    nombre     TEXT NOT NULL,
    entregables TEXT,
    quien_decide TEXT
);

CREATE TABLE rutas (
    id          TEXT PRIMARY KEY,
    nombre      TEXT NOT NULL,
    pregunta    TEXT,
    horizonte   TEXT,
    robustez    TEXT
);

CREATE TABLE fases (
    id          TEXT PRIMARY KEY,
    orden       INTEGER,
    nombre      TEXT NOT NULL,
    semanas     TEXT,
    que_produce TEXT,
    criterio    TEXT
);

CREATE TABLE entregables (
    id        TEXT PRIMARY KEY,
    fase      TEXT,
    nombre    TEXT NOT NULL,
    que_cambia TEXT,
    valor     TEXT,
    estado    TEXT
);

-- ---------- Capa 3: toolchain ----------
CREATE TABLE herramientas (
    id              TEXT PRIMARY KEY,
    categoria       TEXT NOT NULL,
    herramienta     TEXT NOT NULL,
    rol_en_el_ciclo TEXT,
    estado          TEXT,
    origen          TEXT
);

CREATE TABLE contradicciones (
    id             TEXT PRIMARY KEY,
    tema           TEXT NOT NULL,
    posicion_a     TEXT,
    fuente_a       TEXT,
    posicion_b     TEXT,
    fuente_b       TEXT,
    por_que_importa TEXT,
    impacto        TEXT,
    quien_resuelve TEXT,
    estado         TEXT
);

-- ---------- Capa 4: programa y vecindario ----------
CREATE TABLE componentes (
    id               TEXT PRIMARY KEY,
    nombre           TEXT NOT NULL,
    que_aporta       TEXT,
    offering         TEXT,
    stage            TEXT,
    vehiculo         TEXT,
    economia         TEXT,
    deadline         TEXT,
    estado           TEXT,
    fuente           TEXT
);

CREATE TABLE iniciativas_vecinas (
    id          TEXT PRIMARY KEY,
    nombre      TEXT NOT NULL,
    offering    TEXT,
    stage       TEXT,
    economia    TEXT,
    que_comparte TEXT,
    por_que_importa TEXT,
    fuente      TEXT
);

CREATE TABLE dependencias (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    de_componente TEXT NOT NULL,
    a_componente  TEXT NOT NULL,
    tipo         TEXT,
    por_que      TEXT
);

CREATE TABLE hitos (
    id            TEXT PRIMARY KEY,
    fecha         TEXT,
    hito          TEXT NOT NULL,
    componente    TEXT,
    tipo          TEXT,
    consecuencia  TEXT,
    estado        TEXT
);

-- ---------- Capa 5: razonamiento ----------
CREATE TABLE palancas (
    id            TEXT PRIMARY KEY,
    nombre        TEXT NOT NULL,
    friccion      TEXT,
    metrica       TEXT,
    componente    TEXT,
    precondicion  TEXT,
    evidencia_requerida TEXT,
    riesgo_sin_precondicion TEXT,
    horizonte     TEXT,
    estado        TEXT
);

CREATE TABLE guardrails (
    id         TEXT PRIMARY KEY,
    regla      TEXT NOT NULL,
    fundamento TEXT,
    fuente     TEXT,
    severidad  TEXT
);

CREATE TABLE escenarios (
    id             TEXT PRIMARY KEY,
    nombre         TEXT NOT NULL,
    descripcion    TEXT,
    precondiciones TEXT,
    consecuencia   TEXT,
    veredicto      TEXT
);

-- ---------- Capa 6: gobierno y federacion ----------
CREATE TABLE brechas (
    id             TEXT PRIMARY KEY,
    brecha         TEXT NOT NULL,
    impacto        TEXT,
    quien_resuelve TEXT,
    bloquea        TEXT,
    estado         TEXT
);

CREATE TABLE decisiones_abiertas (
    id           TEXT PRIMARY KEY,
    decision     TEXT NOT NULL,
    opciones     TEXT,
    quien_decide TEXT,
    consecuencia TEXT,
    estado       TEXT
);

CREATE TABLE casos_uso_ia (
    id         TEXT PRIMARY KEY,
    etapa_sdlc TEXT NOT NULL,
    caso       TEXT NOT NULL,
    nivel      TEXT,
    requiere   TEXT,
    entra_en   TEXT
);

CREATE TABLE laminas (
    id          TEXT PRIMARY KEY,
    numero      INTEGER,
    titulo      TEXT NOT NULL,
    veredicto   TEXT,
    problema    TEXT,
    que_salvar  TEXT,
    movimiento  TEXT
);

CREATE TABLE objeciones (
    id              TEXT PRIMARY KEY,
    objecion        TEXT NOT NULL,
    quien           TEXT,
    evidencia       TEXT,
    causa_raiz      TEXT,
    contra_movimiento TEXT,
    estado          TEXT
);

CREATE TABLE interno (
    id              TEXT PRIMARY KEY,
    dato            TEXT NOT NULL,
    valor           TEXT,
    confidencialidad TEXT,
    fuente          TEXT
);

CREATE TABLE fuentes (
    id            TEXT PRIMARY KEY,
    tipo          TEXT,
    ruta          TEXT,
    que_aporta    TEXT,
    fecha         TEXT,
    confiabilidad TEXT
);

CREATE TABLE brains_federados (
    id         TEXT PRIMARY KEY,
    nombre     TEXT NOT NULL,
    ruta       TEXT,
    que_aporta TEXT,
    regla      TEXT,
    disponible INTEGER
);

CREATE TABLE stats (
    clave TEXT PRIMARY KEY,
    valor INTEGER
);

-- Capa 7: a quien le vendemos, contra quien competimos y con que doctrina

CREATE TABLE interlocutor (
    id              TEXT PRIMARY KEY,
    periodo         TEXT NOT NULL,
    hecho           TEXT NOT NULL,
    por_que_importa TEXT,
    fuente          TEXT
);

CREATE TABLE citas_interlocutor (
    id          TEXT PRIMARY KEY,
    fecha       TEXT NOT NULL,
    donde       TEXT,
    cita        TEXT NOT NULL,
    que_implica TEXT,
    vigencia    TEXT
);

CREATE TABLE benchmark (
    id          TEXT PRIMARY KEY,
    banco       TEXT NOT NULL,
    dimension   TEXT NOT NULL,
    dato        TEXT NOT NULL,
    fecha_dato  TEXT,
    confianza   TEXT,
    uso_en_sala TEXT
);

CREATE TABLE pov_casa (
    id        TEXT PRIMARY KEY,
    lamina    INTEGER,
    elemento  TEXT NOT NULL,
    contenido TEXT NOT NULL,
    aporta    TEXT,
    cuidado   TEXT
);

CREATE TABLE bolsas_tiempo (
    id              TEXT PRIMARY KEY,
    bolsa           TEXT NOT NULL,
    dueno_hoy       TEXT,
    evidencia       TEXT,
    fecha_evidencia TEXT,
    calidad         TEXT
);

CREATE TABLE alcance_excluido (
    id               TEXT PRIMARY KEY,
    frente           TEXT NOT NULL,
    decision         TEXT NOT NULL,
    por_que          TEXT,
    que_conservamos  TEXT
);

CREATE TABLE dts (
    id             TEXT PRIMARY KEY,
    slug           TEXT NOT NULL,
    nombre         TEXT NOT NULL,
    categoria      TEXT,
    componente     TEXT,
    pregunta       TEXT NOT NULL,
    palancas       TEXT,
    mide           TEXT,
    mueve          TEXT,
    smes           TEXT,
    para_active    TEXT,
    estado         TEXT
);
"""


# --------------------------------------------------------------------------
# Capa 0: mandato del consejo y modelo de partnership
# --------------------------------------------------------------------------

# Narrativa de valor de la estrategia de salida de la TSA, presentada al consejo
# hace dos anios. Es el mandato del que cuelga SDLC Reinvent.
NARRATIVA = [
    ("NC-01", "2 Simplify and modernize the technology", "Simplify the technology",
     "Improved time-to-market and developer productivity through new operating model and pervasive automation",
     "Es el renglon exacto que SDLC Reinvent ejecuta. El consejo ya aprobo este compromiso: la propuesta no abre un tema nuevo, instrumenta uno comprometido", 1),
    ("NC-02", "2 Simplify and modernize the technology", "Simplify the technology",
     "Right-size technology solutions for a local and independent financial group",
     "Justifica que el SDLC sea propio y no heredado del grupo", 0),
    ("NC-03", "2 Simplify and modernize the technology", "Simplify the technology",
     "Simplify the interoperability layer",
     "Conecta con la iniciativa vecina de gobierno de APIs", 0),
    ("NC-04", "2 Simplify and modernize the technology", "Modernize the technology",
     "Modernize Banamex systems of record. Gradually exit Tandem and Unisys",
     "Es la modernizacion del core, primera area del partnership. El brain del core federado cubre los sistemas Unisys", 0),
    ("NC-05", "2 Simplify and modernize the technology", "Modernize the technology",
     "Externalize infrastructure and enable cloud as a target state",
     "La nube como estado objetivo es la precondicion de los minimos tecnicos del SDLC", 0),
    ("NC-06", "2 Simplify and modernize the technology", "Modernize the technology",
     "Maintain flat expense while offsetting volume increase",
     "Restriccion economica dura: la eficiencia del ciclo tiene que pagarse sola, no sumarse al gasto", 0),
    ("NC-07", "3 Enable the local and independent bank", "Drive out tech dependencies with Citi",
     "Build local capabilities to exit dependencies with Citibank, leverage TSA exits to simplify Banamex y maintain a mature cybersecurity function",
     "Son la tercera y la quinta area del partnership, salida de TSAs y ciberseguridad", 0),
    ("NC-08", "1 Expand clients and deepen relationships", "Digitize Banamex y capitalize on data insights",
     "Universal onboarding, expansion de canales digitales, vista 360 del cliente y el One Brain del modelo de datos",
     "Es la banca del futuro, cuarta area del partnership. El One Brain es del banco, no es este Digital Brain", 0),
    ("NC-09", "Transversal", "Banda inferior",
     "Leverage Gen AI for customer servicing and developer productivity",
     "Segunda aparicion de la productividad del desarrollador a nivel consejo, ahora ligada a GenAI. Respalda la capa de IA de la propuesta", 1),
]

PARTNERSHIP_AREAS = [
    ("PA-01", "Modernizacion de Core Bancario",
     "Salida gradual de Tandem y Unisys y modernizacion de los sistemas de registro", "INI-01", 0),
    ("PA-02", "NextGen SDLC",
     "Transformacion del ciclo de entrega de software del banco", "INI-04", 1),
    ("PA-03", "TSA exits no comenzados",
     "Salida de los servicios heredados bajo acuerdo de transicion que aun no arrancan", "INI-02", 0),
    ("PA-04", "Banca del futuro",
     "Nuevos productos digitales, por ejemplo aplicacion de seguros y wealth management", "INI-03", 0),
    ("PA-05", "Ciberseguridad",
     "Mantener una funcion de ciberseguridad madura al salir de la dependencia del grupo", "Sin iniciativa en el laboratorio", 0),
]

PARTNERSHIP_MODELO = [
    ("PM-01", "Objetivo",
     "Acercar las mejores capacidades de Accenture, humanas y de activos, y generar capacidades en Banamex",
     "La transferencia de capacidad es parte del objetivo, no un extra. El SDLC tiene que quedar operable por el banco"),
    ("PM-02", "Laboratorio agil",
     "Aislar la transformacion del dia a dia, probar componentes nuevos, transferir el codigo una vez desarrollado, preparar entornos finales sin riesgo y tener un punto unico de acceso",
     "Es el Laboratorio de Aceleracion, ya contratado por el Anexo B. El piloto de la Fase 2 cabe ahi sin vehiculo nuevo"),
    ("PM-03", "Fuerza de trabajo de transformacion",
     "Equipo externo que permite movilizar a los mejores recursos de Accenture",
     "Explica por que la estimacion interna mezcla perfiles base con expertos puntuales"),
    ("PM-04", "Modelo comercial con riesgo compartido",
     "Esquema de skin in the game sobre KPIs de negocio y co-inversion en areas aisladas sin desarrollo existente",
     "No se puede firmar riesgo compartido sobre KPIs que nadie ha medido. La Fase 1 es precondicion comercial del partnership, no solo tecnica"),
    ("PM-05", "Activos de Accenture",
     "Apalancar los activos propios para acelerar, con el Digital Brain nombrado de forma explicita",
     "Este brain es uno de los activos citados en la lamina. Conviene que lo que muestre sea defendible"),
    ("PM-06", "Capacidades humanas",
     "Generar capacidades humanas para Banamex",
     "Conecta con el acelerador de upskilling del catalogo, hoy marcado como a validar"),
]


# --------------------------------------------------------------------------
# Capa 1: el ciclo de entrega
# --------------------------------------------------------------------------

# Marco de trabajo del brain. La propuesta modela el ciclo del banco en 6 etapas
# actuales y 8 etapas objetivo; ese modelo vive en gates, rutas y fases.
ETAPAS = [
    ("E01", 1, "Gestion de la Demanda",
     "De la peticion de negocio a la iniciativa aprobada", "SIN MEDIR",
     "Informacion general de iniciativa; Categoria de Inversion; Cuestionario de Cumplimiento; Cuestionario de Privacidad de Datos; Cuestionario Mandatorio de Negocio y Tecnologia; Estimacion Inicial",
     "Crear solicitud de identificador; Revisar solicitud; Crear estimacion; Evaluacion de alcance y estimacion; Aprobar o rechazar la solicitud",
     "Iniciativa aprobada",
     "PTS; Confluence"),
    ("E02", 2, "Iniciacion",
     "De la iniciativa aprobada al backlog inicial y el plan de trabajo", "SIN MEDIR",
     "Epicas; User Stories de alto nivel; Plan de Remediacion solo para MRA sin mapear; Arranque del programa o proyecto",
     "Documentacion de requerimientos iniciales y User Stories; Identificacion de sistemas impactados; Punto de control 1 con TISO; Aprobacion IEP; Definir modelo de gobierno; Identificar riesgos potenciales; Identificar requerimientos de nueva infraestructura",
     "Involucramiento de TISO; Plan de trabajo con estimacion inicial; Backlog inicial",
     "Jira; PTS; Confluence; Risk Review Platform"),
    ("E03", 3, "Planeacion de la Ejecucion",
     "Del backlog inicial al diseno validado y listo para construir", "SIN MEDIR",
     "Documento de Alcance; Permiso para Disenar; Permiso para Construir; Plan de Pruebas de Tecnologia; Atestacion CART; Export Compliance; Analisis de Causa Raiz para MRA sin mapear; Criterios de exito e indicadores para MRA sin mapear",
     "Plan de trabajo detallado; Definir requerimientos y disenos; Refinamiento a User Stories detalladas; Atestacion y aprobacion de seguridad de la informacion; Identificar cambios materiales; Validacion de impactos de arquitectura; Evaluar elegibilidad de pruebas de desempenio",
     "Validacion de pruebas; Liberacion a Produccion de forma iterativa",
     "Jira; PTS; Confluence; Risk Review Platform; Reviews@Citi; Architecture Center"),
    ("E04", 4, "Ejecucion",
     "Del diseno validado a la liberacion en produccion", "SIN MEDIR",
     "Backlog del sprint; Aprobacion de Seguridad de la Informacion; Atestacion de permiso para desplegar; Aprobacion CART; Atestacion transfronteriza; Aprobacion de inteligencia artificial y aprendizaje automatico; Reporte de Salida de Pruebas; Aprobacion de Implementacion; Numero de Control de Cambio",
     "Desarrollo de software y pruebas unitarias; Pruebas de integracion, aceptacion de usuario, regresion, no impacto y desempenio; Evaluacion de vulnerabilidades; Validacion con Soporte de Produccion; Documentacion de Solicitudes de Cambio con plan de despliegue y estrategia de reversa; Cumplir con los artefactos del ciclo",
     "Liberacion a Produccion; Gestion de Incidentes; Validacion con Negocio y Tecnologia",
     "Jira; PTS; Confluence; Risk Review Platform; Reviews@Citi; Architecture Center; ServiceNow"),
    ("E05", 5, "Post Implementacion",
     "De la liberacion al cierre formal del proyecto", "SIN MEDIR",
     "Resultados y acciones de la Revision Post Implementacion; Aprobacion de Cierre; Aprobacion de Aceptacion de criterios para MRA sin mapear",
     "Documentar lecciones aprendidas; Documentar retroalimentacion del cliente de forma opcional; Validar entregables completos y actualizados; Confirmar Factores Criticos de Exito; Cerrar riesgos e incidencias; Bitacora de acciones; Cerrar User Stories y Solicitudes de Cambio",
     "Proyecto o programa completado",
     "Jira; PTS; Confluence; Risk Review Platform; ServiceNow"),
    ("E06", 6, "Monitoreo y Control",
     "Administrar el avance. NO DECLARA NINGUN RESULTADO: la casilla esta vacia en el levantamiento", "SIN MEDIR",
     "Incidencias; Riesgos",
     "Mantener el calendario; Mantener el estatus; Comunicacion; Mantener la lista del equipo; Gestionar riesgos; Gestionar incidencias; Criterios Criticos de Exito e Indicadores aprobados",
     "Ninguno declarado",
     "Ninguna declarada"),
]

# Puntos de control nombrados en el levantamiento de 2025. La columna origen marca
# cuales pertenecen al regimen de la matriz y por tanto no sobreviven la separacion.
CONTROLES = [
    ("CA-01", "Cuestionario de Cumplimiento", "E01", "INSUMO", "Por confirmar", "PROBABLE, se reemplaza por regimen CNBV"),
    ("CA-02", "Cuestionario de Privacidad de Datos", "E01", "INSUMO", "Por confirmar", "PROBABLE"),
    ("CA-03", "Cuestionario Mandatorio de Negocio y Tecnologia", "E01", "INSUMO", "Por confirmar", "PROBABLE"),
    ("CA-04", "Aprobar o rechazar la solicitud", "E01", "ACTIVIDAD", "Banco", "SI"),
    ("CA-05", "Punto de control 1 con TISO", "E02", "ACTIVIDAD", "Nomenclatura de la matriz", "A CONFIRMAR"),
    ("CA-06", "Aprobacion IEP", "E02", "ACTIVIDAD", "Nomenclatura de la matriz", "A CONFIRMAR"),
    ("CA-07", "Permiso para Disenar", "E03", "INSUMO", "Por confirmar", "A CONFIRMAR"),
    ("CA-08", "Permiso para Construir", "E03", "INSUMO", "Por confirmar", "A CONFIRMAR"),
    ("CA-09", "Atestacion CART", "E03", "INSUMO", "Por confirmar", "A CONFIRMAR. OJO: CART aparece dos veces en el ciclo, aqui y en CA-13"),
    ("CA-10", "Export Compliance", "E03", "INSUMO", "Regimen estadounidense de la matriz", "NO, control de banco global"),
    ("CA-11", "Atestacion y aprobacion de seguridad de la informacion", "E03", "ACTIVIDAD", "Por confirmar", "SI"),
    ("CA-12", "Aprobacion de Seguridad de la Informacion", "E04", "INSUMO", "Por confirmar", "SI"),
    ("CA-13", "Aprobacion CART", "E04", "INSUMO", "Por confirmar", "A CONFIRMAR. Duplicidad potencial con CA-09"),
    ("CA-14", "Atestacion de permiso para desplegar", "E04", "INSUMO", "Por confirmar", "A CONFIRMAR"),
    ("CA-15", "Atestacion transfronteriza", "E04", "INSUMO", "Regimen de banco global", "NO, pierde sentido en un banco local"),
    ("CA-16", "Aprobacion de inteligencia artificial y aprendizaje automatico", "E04", "INSUMO", "Por confirmar", "SI, y probablemente crece"),
    ("CA-17", "Aprobacion de Implementacion", "E04", "INSUMO", "Por confirmar", "SI"),
    ("CA-18", "Numero de Control de Cambio", "E04", "INSUMO", "Banco", "SI"),
    ("CA-19", "Aprobacion de Cierre", "E05", "INSUMO", "Por confirmar", "SI"),
    ("CA-20", "Aprobacion de Aceptacion de criterios para MRA sin mapear", "E05", "INSUMO", "Regimen regulatorio de la matriz", "NO, los MRA son del supervisor de la matriz"),
    ("CA-21", "Criterios Criticos de Exito e Indicadores aprobados", "E06", "ACTIVIDAD", "Banco", "SI"),
]

# Las siete herramientas del levantamiento. Ninguna es de ingenieria: no hay control
# de versiones, ni integracion continua, ni automatizacion de pruebas.
HERR_ASIS = [
    ("HA-01", "PTS", "E01; E02; E03; E04; E05", "Gestion de portafolio", "Por confirmar", "A CONFIRMAR si es plataforma de la matriz"),
    ("HA-02", "Confluence", "E01; E02; E03; E04; E05", "Documentacion", "Banco", "Bajo"),
    ("HA-03", "Jira", "E02; E03; E04; E05", "Gestion de trabajo", "Banco", "Bajo. Es la fuente primaria para la medicion de tres semanas"),
    ("HA-04", "Risk Review Platform", "E02; E03; E04; E05", "Riesgo y cumplimiento", "Por confirmar", "A CONFIRMAR"),
    ("HA-05", "Reviews@Citi", "E03; E04", "Gobierno de revisiones", "MATRIZ, lleva el nombre en el nombre", "ALTO. Desaparece con la separacion y los controles que viven ahi hay que reconstruirlos"),
    ("HA-06", "Architecture Center", "E03; E04", "Gobierno de arquitectura", "Por confirmar", "A CONFIRMAR"),
    ("HA-07", "ServiceNow", "E04; E05", "Gestion de servicio y cambio", "Banco", "Bajo. Hay un vehiculo propio en curso"),
]

# estado OBSERVADA: respaldada por el levantamiento del SDLC o por el diagnostico.
# estado HIPOTESIS: patron sectorial, todavia no observado en Banamex.
FRICCION = [
    ("FR-01", "E01", "Medicion",
     "Hay diagnostico pero no linea base medida: las cifras disponibles vienen del assessment de Accenture, no de la telemetria del banco",
     "PoV v3.3, lamina de medicion, y lab-brain brecha 5 de INI-04",
     "La propuesta dice textualmente que ninguna metrica lleva meta hasta tener linea base, y pone el levantamiento en la Fase 1", "OBSERVADA"),
    ("FR-02", "E03", "Acuerdo tecnico",
     "El repositorio y el motor de integracion de destino no estan decididos, y tres documentos de Accenture asumen cosas distintas",
     "Supuestos BST-S1-002 y BST-S1-003, supuesto CICD-S1-005 y herramientas ilustrativas del PoV",
     "Contradicciones CT-01 y CT-02", "OBSERVADA"),
    ("FR-03", "E06", "Ambientes y datos",
     "No hay manera de probar contra el core sin tocar el core real, y el core real esta fuera de alcance por contrato",
     "Anexo B del Laboratorio de Aceleracion", "El Anexo excluye de forma explicita la conexion con el core real", "OBSERVADA"),
    ("FR-04", "E10", "Ventana de despliegue",
     "El congelamiento de diciembre de 2026 comprime la ventana util de despliegue del ultimo trimestre",
     "deal-state Backstage, supuesto BST-S1-007", "Supuesto marcado como dato de cliente confirmado", "OBSERVADA"),
    ("FR-05", "E07", "Dependencia externa",
     "Cloud Readiness y el Landing Zone estan frenados por dependencias y controles del grupo, y la Zona D no llega antes de 2027",
     "CLAUDE.md del Laboratorio de Aceleracion", "Razon de existencia del laboratorio", "OBSERVADA"),
    ("FR-06", "E02", "Contratos",
     "Los contratos de interfaz del core no estan redactados, de modo que el refinamiento no puede cerrar criterios de integracion",
     "Anexo B, construccion del core emulado", "El Anexo pide contratos y esquemas proporcionados por el cliente", "OBSERVADA"),
    ("FR-07", "E01", "Arranque",
     "Levantar un proyecto nuevo exige recorrer equipos de plataforma, seguridad e identidad uno por uno",
     "Patron sectorial en banca mexicana, no observado aun en Banamex", "", "HIPOTESIS"),
    ("FR-08", "E04", "Espera",
     "La revision de cambios espera a revisores concentrados en pocas personas por dominio",
     "Patron sectorial, consistente con la concentracion de autoria que muestra el brain del core", "", "HIPOTESIS"),
    ("FR-09", "E06", "Retrabajo",
     "La regresion no esta automatizada, de modo que se repite de forma manual en cada entrega",
     "PoV v3.3, lamina de por que ahora", "Brechas en CI/CD y pruebas automatizadas, del assessment de Accenture", "OBSERVADA"),
    ("FR-10", "E09", "Aprobacion",
     "El ciclo exige alrededor de 16 aprobaciones, permisos y atestaciones secuenciales por iniciativa",
     "PoV v3.3, levantamiento del SDLC actual de octubre de 2025", "Diagnostico DG-02, no exhaustivo", "OBSERVADA"),
    ("FR-11", "E11", "Senal",
     "La senal de produccion no regresa a la demanda, de modo que el retrabajo se descubre en la siguiente entrega",
     "Patron sectorial en banca mexicana, no observado aun en Banamex", "", "HIPOTESIS"),
    ("FR-12", "E05", "Variabilidad",
     "No hay integracion continua establecida, de modo que la evidencia de entrega no es comparable entre equipos",
     "PoV v3.3, lamina de por que ahora", "Brechas en CI/CD, del assessment de Accenture", "OBSERVADA"),
    ("FR-13", "E01", "Embudo",
     "La planeacion es anual y mas de 250 iniciativas compiten en el mismo embudo, de modo que se solicitan 1,337 features y se aprueban cerca de 500",
     "PoV v3.3, lamina de por que ahora", "Diagnostico DG-03 y DG-09, a presentar como rigidez de la planeacion, no como critica a la priorizacion", "OBSERVADA"),
    ("FR-14", "E02", "Doble planeacion",
     "El modelo de transicion planea dos veces lo mismo, una en la planeacion de la ejecucion y otra en la del sprint",
     "PoV v3.3, notas del triage de metodo", "Frase de la propuesta: no quitamos la planeacion, evitamos planear dos veces lo mismo", "OBSERVADA"),
]

# Cifras del diagnostico de Accenture. NO son linea base medida: la propuesta las
# marca como no exhaustivas y a validar en la Fase 1.
DIAGNOSTICO = [
    ("DG-01", "Historias que tardan mas de doce meses en llegar a produccion", "Cerca del 20 por ciento",
     "Diagnostico de TI de Accenture, a confirmar contra el tablero de KPIs del CAL", "NO EXHAUSTIVO, A VALIDAR EN FASE 1"),
    ("DG-02", "Aprobaciones, permisos y atestaciones secuenciales por iniciativa", "Alrededor de 16, mas tres cuestionarios",
     "Levantamiento del SDLC actual, octubre de 2025", "NO EXHAUSTIVO Y CON UN ANIO DE ANTIGUEDAD. Sostiene el titular de la propuesta"),
    ("DG-03", "Features solicitados contra aprobados en un ciclo anual", "1,337 solicitados y cerca de 500 aprobados",
     "Diagnostico de TI de Accenture", "NO EXHAUSTIVO, A VALIDAR EN FASE 1"),
    ("DG-04", "Madurez del modelo operativo de TI", "2.3 de 4, nivel Emergente",
     "Assessment de madurez de Accenture", "NO EXHAUSTIVO, A VALIDAR EN FASE 1"),
    ("DG-05", "Insumos del SDLC actual", "31",
     "Levantamiento del SDLC actual, octubre de 2025", "NO EXHAUSTIVO Y CON UN ANIO DE ANTIGUEDAD"),
    ("DG-06", "Actividades del SDLC actual", "39, de las cuales 27 se simplifican, consolidan, anticipan o automatizan",
     "Levantamiento del SDLC actual, octubre de 2025", "NO EXHAUSTIVO Y CON UN ANIO DE ANTIGUEDAD"),
    ("DG-07", "Herramientas del SDLC actual", "7",
     "Levantamiento del SDLC actual, octubre de 2025", "NO EXHAUSTIVO Y CON UN ANIO DE ANTIGUEDAD"),
    ("DG-08", "Elementos del SDLC actual clasificados uno por uno", "92 en total, de los cuales 49 cambian de forma",
     "Analisis de simplificacion del PoV v3.3", "PRELIMINAR, A VALIDAR CON BANAMEX"),
    ("DG-09", "Iniciativas que compiten en el mismo embudo de planeacion anual", "Mas de 250",
     "Diagnostico de TI de Accenture", "NO EXHAUSTIVO, A VALIDAR EN FASE 1"),
    ("DG-10", "Posicion de Banamex en el modelo de madurez frente a sus pares", "Emergente, contra Transformando de dos pares y Optimizado de un tercero",
     "Benchmark de fuentes publicas del anexo A4", "PUBLICO PARA LOS PARES, ASSESSMENT PROPIO PARA BANAMEX"),
]

# Las metricas son las que la propuesta comprometio, ni una mas.
METRICAS = [
    ("M-DES-01", "Desempeno", "Lead time de punta a punta", "dias",
     "Dias desde la aprobacion del requerimiento hasta produccion", "Diagnostico de TI",
     None, None, "SIN LINEA BASE"),
    ("M-DES-02", "Desempeno", "Aprobaciones", "dias y porcentaje",
     "Tiempo de espera en gates y porcentaje de iniciativas detenidas por riesgos no mitigados", "Lean",
     None, None, "SIN LINEA BASE"),
    ("M-DES-03", "Desempeno", "Predictibilidad", "porcentaje",
     "Entregas en fecha y alcance comprometidos en G2, y milestones completados segun el plan original", "Portafolio",
     None, None, "SIN LINEA BASE"),
    ("M-DES-04", "Desempeno", "Frecuencia de despliegue", "liberaciones por periodo",
     "Liberaciones a produccion por periodo", "DORA",
     None, None, "SIN LINEA BASE, MEDIBLE AL CIERRE DEL PILOTO"),
    ("M-DES-05", "Desempeno", "Tasa de fallas en cambios", "porcentaje",
     "Liberaciones que causan un incidente o un rollback", "DORA",
     None, None, "SIN LINEA BASE"),
    ("M-CTL-01", "Control", "Evidencia completa en el gate", "porcentaje",
     "Liberaciones que llegan al gate con toda su evidencia", "Stage Gate Control Framework",
     None, "100 por ciento, si no, no pasa", "UMBRAL DESDE EL INICIO"),
    ("M-CTL-02", "Control", "Vulnerabilidades criticas en produccion", "conteo",
     "Vulnerabilidades criticas que llegan a produccion", "Seguridad de aplicaciones",
     None, "Cero tolerancia", "UMBRAL DESDE EL INICIO"),
    ("M-CTL-03", "Control", "Tasa de retrabajo", "porcentaje",
     "Despliegues no planeados para corregir algo", "DORA",
     None, "No sube contra la linea base", "UMBRAL DESDE EL INICIO"),
    ("M-CTL-04", "Control", "Excepciones y hallazgos", "conteo",
     "Excepciones y hallazgos de control y de auditoria", "Riesgo y cumplimiento",
     None, "No suben contra la linea base", "UMBRAL DESDE EL INICIO"),
    ("M-ADO-01", "Adopcion", "Happiness, satisfaccion", "indice",
     "Satisfaccion de equipos y stakeholders, por encuesta pulso", "Marco HEART",
     None, None, "SE MIDE EN EL PILOTO"),
    ("M-ADO-02", "Adopcion", "Engagement, uso", "porcentaje",
     "Porcentaje del trabajo registrado en el flujo", "Marco HEART",
     None, None, "SE MIDE EN EL PILOTO"),
    ("M-ADO-03", "Adopcion", "Adoption, adopcion", "porcentaje",
     "Iniciativas que entran por el nuevo modelo y pasan por el triage", "Marco HEART",
     None, None, "SE MIDE EN EL PILOTO"),
    ("M-ADO-04", "Adopcion", "Retention, permanencia", "conteo",
     "Equipos que no reutilizan el modelo anterior tras el piloto", "Marco HEART",
     None, None, "SE MIDE EN EL PILOTO"),
    ("M-ADO-05", "Adopcion", "Task success, exito", "porcentaje",
     "Gates aprobados a la primera", "Marco HEART",
     None, None, "SE MIDE EN EL PILOTO"),
]


# --------------------------------------------------------------------------
# Capa 2: la propuesta
# --------------------------------------------------------------------------

GATES = [
    ("G1", 1, "Aprobacion de la iniciativa",
     "Caso de valor, prioridad en portafolio y presupuesto",
     "Comite de portafolio, con seguridad participando"),
    ("G2", 2, "Listo para construir",
     "Arquitectura y diseno aprobados, modelado de amenazas, plan de releases y acuerdo de capacidad",
     "Arquitectura y seguridad"),
    ("G3", 3, "Listo para produccion",
     "Reportes de pruebas integrales y de aceptacion, pentest, rollback y autorizacion del cambio",
     "Riesgo, cumplimiento y gestion del cambio"),
    ("G4", 4, "Cierre y transicion",
     "Hypercare cumplido, acuerdos de nivel de servicio y documentacion operativa",
     "Negocio y operacion"),
]

RUTAS = [
    ("RT-01", "Incidente critico", "Falla en produccion que afecta clientes u operacion",
     "Horas, con camino rapido", "Minima, solo lo indispensable"),
    ("RT-02", "Cambio menor", "Ajuste simple en una sola aplicacion, sin tocar arquitectura",
     "Dias, con camino rapido si urge", "Ligera"),
    ("RT-03", "Iniciativa de backlog", "Se resuelve dentro de un producto existente",
     "Semanas", "Media"),
    ("RT-04", "Transformacion", "No se resuelve dentro de un producto existente",
     "Meses", "Completa"),
]

FASES = [
    ("F1", 1, "Validacion y refinamiento", "Semanas 1 a 4",
     "Recorrido con la PMO, talleres de validacion por area, SDLC refinado version 1 y levantamiento de la linea base",
     "Go del piloto: SDLC version 1, equipo y aplicacion definidos, accesos y ambientes confirmados, linea base y umbrales acordados"),
    ("F2", 2, "Piloto y calibracion en vivo", "Semanas 5 a 8",
     "Un equipo real recorre los cuatro gates y libera un incremento real por el nuevo pipeline, con medicion semanal contra la linea base",
     "Doble: el desempeno mejora contra la linea base y ningun indicador de control se cruza. Una sin la otra no cuenta"),
]

ENTREGABLES = [
    # valor ALTO PERMANENTE: queda operando en el banco despues del proyecto
    # valor ALTO OPERATIVO : se usa todos los dias desde el primer dia
    # valor MEDIO          : sirve a una persona o a un momento
    # valor DOCUMENTO      : se archiva, por bueno que sea
    ("EN-01", "F3", "Linea base y tablero de medicion",
     "El banco pasa de no saber cuanto tarda un cambio a verlo cada semana con datos de sus propias herramientas",
     "ALTO PERMANENTE",
     "Es el unico entregable que sobrevive al proyecto y es la llave de la Etapa 2 segun su propia hoja de ruta. Tambien es la precondicion del esquema de riesgo compartido"),
    ("EN-02", "F1", "Cuestionario unico de triage",
     "Cada solicitud nueva se clasifica al entrar, con metodo y ruta asignados, en lugar de recorrer el camino completo por defecto",
     "ALTO OPERATIVO",
     "Instrumento de uso diario, no pide permiso a nadie ni infraestructura. Se puede empezar a usar la semana siguiente"),
    ("EN-03", "F1", "Paquete de evidencia obligatorio por gate",
     "Se acaba la discusion caso por caso de que hace falta para pasar un gate, porque esta acordado de antemano con riesgo y cumplimiento",
     "ALTO OPERATIVO",
     "Es el entregable que de verdad recorta la espera. Su valor depende de que riesgo y cumplimiento lo firmen, no de que nosotros lo escribamos"),
    ("EN-04", "F2", "MVP tecnico del equipo piloto",
     "Un equipo que hoy libera agrupado pasa a tener pipeline, regresion automatizada y ambientes propios",
     "ALTO PERMANENTE",
     "ESTABA EN LA v3.3 Y SE CAYO DE LA VERSION NUEVA. Es capacidad instalada e irreversible, el entregable que mas justifica el precio"),
    ("EN-05", "F2", "Equipo habilitado para operar en sprints",
     "El primer equipo del banco opera sobre la nueva base tecnica sin acompaniamiento",
     "ALTO PERMANENTE",
     "ESTABA EN LA v3.3 Y SE CAYO DE LA VERSION NUEVA. Es la prueba viva de que el modelo funciona en su casa"),
    ("EN-06", "F1", "Patrones de solucion con talla y rigor",
     "El backlog real se clasifica y se ve que proporcion del volumen recorre mas camino del que su riesgo justifica",
     "ALTO OPERATIVO",
     "Alto solo si viene con el conteo de solicitudes por patron. Sin volumen es una taxonomia"),
    ("EN-07", "F3", "Caso de valor",
     "El patrocinador puede pedir presupuesto con numeros propios en lugar de supuestos",
     "MEDIO",
     "Es el entregable politico y hace falta, pero depende por completo de la linea base. Sin ella es otro caso de valor con supuestos, que es justo lo que el cliente ya rechazo"),
    ("EN-08", "F3", "Hoja de ruta con etapas de madurez",
     "El patrocinador tiene con que defender la inversion hacia arriba y el banco ve el orden de las etapas",
     "MEDIO",
     "Sirve a una persona y a un momento. Vale, pero no es por lo que un banco paga"),
    ("EN-09", "F2", "Reporte de desempeno y cumplimiento del piloto",
     "Habilita la decision de escalar o parar",
     "MEDIO",
     "Su valor es la decision que desbloquea, no el reporte"),
    ("EN-10", "F1", "SDLC refinado, version beta",
     "El banco tiene su metodo documentado con etapas, actividades y criterios de transicion",
     "DOCUMENTO",
     "El banco ya tiene proceso documentado. Su problema no es la falta de documento sino las 16 aprobaciones, y un documento no quita ninguna"),
    ("EN-11", "F2", "SDLC refinado, version final",
     "El mismo documento anterior, ajustado con lo que aprendio el piloto",
     "DOCUMENTO",
     "Es la version 2 del EN-10 contada como entregable aparte. Infla la lista sin agregar valor"),
    ("EN-12", "F1", "Roles y RACI, incluido el gerente de proyecto",
     "Queda escrito quien hace que en cada etapa y gate",
     "DOCUMENTO",
     "Un RACI es el artefacto mas facil de archivar que existe. Solo vale si el cambio de rol del gerente de proyecto viene acordado con la organizacion"),
    ("EN-13", "F3", "Plan detallado de habilitacion de la Etapa 1",
     "Queda escrito como se publica, se capacita y se despliega el modelo por area",
     "DOCUMENTO",
     "Es un plan de un plan. Cabe dentro de la hoja de ruta"),
]


# --------------------------------------------------------------------------
# Capa 3: toolchain
# --------------------------------------------------------------------------

# estado VIGENTE: herramienta del SDLC actual del banco.
# estado ILUSTRATIVA: la propone el PoV, se define en la Fase 1.
# estado VECINA: viene de una iniciativa adyacente, no de esta propuesta.
HERRAMIENTAS = [
    ("HE-01", "Gestion de la demanda", "Wave", "Registro y seguimiento de la demanda y del portafolio",
     "VIGENTE", "Levantamiento del SDLC actual, octubre de 2025"),
    ("HE-02", "Gestion del trabajo", "Jira", "Historias, backlog y sprints",
     "VIGENTE", "Levantamiento del SDLC actual, octubre de 2025"),
    ("HE-03", "Documentacion", "Confluence", "Artefactos del ciclo",
     "VIGENTE", "Levantamiento del SDLC actual, octubre de 2025"),
    ("HE-04", "Riesgo y cumplimiento", "Risk Review Platform", "Revisiones de riesgo y atestaciones",
     "VIGENTE", "Levantamiento del SDLC actual, octubre de 2025"),
    ("HE-05", "Arquitectura", "Architecture Center", "Revision y validacion de arquitectura",
     "VIGENTE", "Levantamiento del SDLC actual, octubre de 2025"),
    ("HE-06", "Revisiones heredadas", "Reviews, heredada del grupo", "Revisiones heredadas del grupo",
     "VIGENTE", "Levantamiento del SDLC actual, octubre de 2025"),
    ("HE-07", "Gestion de servicio", "ServiceNow", "Incidentes, solicitudes y cambios",
     "VIGENTE", "Levantamiento del SDLC actual, octubre de 2025"),
    ("HE-08", "Riesgo y cumplimiento", "ServiceNow IRM", "Controles como registro, no como documento",
     "ILUSTRATIVA", "PoV v3.3, a definir en la Fase 1"),
    ("HE-09", "Arquitectura", "LeanIX", "Inventario de aplicaciones y dependencias",
     "ILUSTRATIVA", "PoV v3.3, a definir en la Fase 1"),
    ("HE-10", "Observabilidad", "Dynatrace", "Observabilidad de la liberacion y del servicio",
     "ILUSTRATIVA", "PoV v3.3, a definir en la Fase 1"),
    ("HE-11", "Repositorio de codigo", "GitHub", "Repositorio y revision de cambios",
     "ILUSTRATIVA", "PoV v3.3, a definir en la Fase 1"),
    ("HE-12", "Asistencia de agentes", "GitHub Copilot", "Asistencia en construccion",
     "ILUSTRATIVA", "PoV v3.3, a definir en la Fase 1"),
    ("HE-13", "Calidad de codigo", "SonarQube", "Calidad y deuda tecnica en el pipeline",
     "ILUSTRATIVA", "PoV v3.3, a definir en la Fase 1"),
    ("HE-14", "Seguridad de aplicaciones", "Snyk", "Vulnerabilidades en el pipeline",
     "ILUSTRATIVA", "PoV v3.3, a definir en la Fase 1"),
    ("HE-15", "Pruebas", "Playwright", "Regresion automatizada",
     "ILUSTRATIVA", "PoV v3.3, a definir en la Fase 1"),
    ("HE-16", "Medicion", "Tablero de desempeno y cumplimiento", "Linea base y seguimiento semanal",
     "ILUSTRATIVA", "PoV v3.3, entregable EN-06"),
    ("HE-17", "Repositorio de codigo", "GitLab o Bitbucket", "Repositorio supuesto por la iniciativa del portal",
     "VECINA", "deal-state Backstage, supuesto BST-S1-002"),
    ("HE-18", "Integracion continua", "Jenkins o Tekton", "Motor de integracion supuesto por la iniciativa del portal",
     "VECINA", "deal-state Backstage, supuesto BST-S1-003"),
    ("HE-19", "Repositorio de codigo", "GitHub Enterprise", "Repositorio supuesto por el diseno corporativo",
     "VECINA", "deal-state CICD Design, supuesto CICD-S1-005"),
    ("HE-20", "Integracion continua", "GitHub Actions", "Motor de integracion del diseno corporativo",
     "VECINA", "deal-state CICD Design"),
    ("HE-21", "Portal de desarrollador", "Backstage", "Catalogo y plantillas de arranque",
     "VECINA", "Propuesta BDP IDP v3"),
    ("HE-22", "Plataforma de contenedores", "OpenShift en sitio", "Donde corre el software del banco",
     "VECINA", "deal-state Backstage y diseno ROP de CICD"),
    ("HE-23", "Gestion de APIs", "Apigee, de OPDK a X", "Puerta de APIs, hoy en version local",
     "VECINA", "deal-state Apigee X"),
]

CONTRADICCIONES = [
    ("CT-01", "Repositorio de codigo de destino",
     "GitLab o Bitbucket, marcado como dato de cliente confirmado",
     "deal-state Backstage, supuesto BST-S1-002",
     "GitHub Enterprise segun el diseno corporativo, y GitHub como herramienta ilustrativa del PoV",
     "deal-state CICD Design, supuesto CICD-S1-005, y PoV v3.3",
     "Tres documentos de Accenture frente al mismo banco asumen cosas distintas. La Fase 1 de SDLC Reinvent es el foro natural para cerrarlo, porque ahi se define el toolchain objetivo",
     "ALTO", "Banamex, area de ingenieria de plataforma, en la Fase 1", "ABIERTA"),
    ("CT-02", "Motor de integracion continua",
     "Jenkins o Tekton, marcado como dato de cliente confirmado",
     "deal-state Backstage, supuesto BST-S1-003",
     "GitHub Actions sobre OpenShift segun el diseno corporativo",
     "deal-state CICD Design y PoV v3.3",
     "Las plantillas de arranque del portal generan definiciones de pipeline. Dos motores distintos significan dos juegos de plantillas o una apuesta a cual sobrevive",
     "ALTO", "Banamex, area de ingenieria de plataforma, en la Fase 1", "ABIERTA"),
    ("CT-03", "Donde se ejecuta el ciclo",
     "OpenShift en sitio para las aplicaciones y AWS Mexico Central para el laboratorio",
     "deal-state Backstage y Anexo B",
     "Google Cloud para la puerta de APIs, y la nube como estado objetivo segun el consejo",
     "deal-state Apigee X y narrativa del consejo NC-05",
     "No es contradiccion sino tres destinos simultaneos. Obliga a que las plantillas y la evidencia de compuerta sean portables, y a decidir donde vive la telemetria de la linea base",
     "MEDIO", "Conjunta", "ABIERTA"),
    ("CT-04", "Donde vive el flujo de cambio",
     "El PoV integra la autorizacion del cambio en G3 y conserva la herramienta de gestion de servicio",
     "PoV v3.3, anexo de trazabilidad de controles",
     "El MVP del portal deja las integraciones con gestion de servicio y del trabajo para fases posteriores",
     "deal-state Backstage, supuesto BST-S1-009",
     "Si el portal llega antes que el SDLC refinado, el banco tendra un catalogo que no toca la parte del ciclo donde se acumula la espera",
     "MEDIO", "Conjunta", "ABIERTA"),
]


# --------------------------------------------------------------------------
# Capa 4: programa y vecindario
# --------------------------------------------------------------------------

COMPONENTES = [
    ("C-00", "Propuesta SDLC Reinvent",
     "Ocho semanas en dos fases: validar y refinar el SDLC con los equipos, y calibrarlo en vivo con un equipo piloto",
     "03 S&PE", "PoV v3.3 presentado y devuelto con objeciones",
     "Por definir, dentro del modelo de partnership",
     "No se presento costo al cliente, y aun asi la objeto por cara. Cifras internas en la tabla interno",
     "", "RECHAZADA EN SU FORMA ACTUAL: poco aterrizada y muy cara. Requiere reencuadre antes de volver",
     "source/docs/Banamex_SDLC_Reinvent_PoV_for_Discussion_v3_3.pptx"),
    ("C-05", "Laboratorio de Aceleracion",
     "Laboratorio agil del partnership. Aisla la transformacion del dia a dia y es donde cabe el piloto sin vehiculo contractual nuevo",
     "03 S&PE", "Setup en curso bajo el Anexo B",
     "Anexo B del Contrato Maestro 2022.021519",
     "Dentro del servicio mensual del laboratorio",
     "2026-11-11", "Entregables 1 y 2 con fecha dura",
     "projects/laboratorio-aceleracion/, lab-brain.db"),
    ("C-06", "Linea base y telemetria del ciclo",
     "Mide el ciclo actual de punta a punta. Sin esto no hay caso de negocio ni riesgo compartido posible",
     "03 S&PE", "Cubierta por la Fase 1 de la propuesta",
     "Depende de que la PMO confirme el enfoque",
     "Dentro de la Fase 1",
     "", "DEJA DE SER HUERFANA SI LA PMO CONFIRMA, hoy sigue sin arrancar",
     "PoV v3.3, Fase 1, entregable EN-06"),
]

INICIATIVAS_VECINAS = [
    ("V-01", "Portal de desarrollador", "03 S&PE", "S1",
     "1.4 a 2.0 millones de dolares segun la linea base del pipeline FY27",
     "Catalogo, plantillas de arranque y documentacion tecnica. Toca las etapas de demanda, refinamiento y desarrollo",
     "Su MVP vence el 27 de noviembre de 2026 y sus plantillas se enganchan al repositorio y al motor que SDLC Reinvent definiria en la Fase 1",
     "Solutioning/Proposals - Clients/Banamex/Backstage/deal-state-banamex-backstage.md"),
    ("V-02", "Plataforma de integracion y despliegue corporativa", "03 S&PE", "S1",
     "Sin calcular",
     "Pipeline estandar y evidencia comparable entre equipos",
     "Es la pieza tecnica que vuelve ejecutable la automatizacion de evidencia que el PoV promete en G3",
     "Solutioning/Proposals - Clients/Banamex/deal-state-banamex-cicd.md"),
    ("V-03", "Gobierno de APIs", "03 S&PE", "S2B",
     "180 a 227 mil dolares de valor total de contrato",
     "Contrato de API versionado y puerta unica de entrada",
     "Responde al compromiso del consejo de simplificar la capa de interoperabilidad",
     "Solutioning/Proposals - Clients/Banamex/Apigee X/deal-state-banamex-apigee-x.md"),
    ("V-04", "Gestion de servicio y del cambio", "07 AMS", "S2B",
     "173.2 millones de pesos a 36 meses",
     "Normaliza el flujo de cambio, que es donde se acumula la espera entre aceptacion y despliegue",
     "La herramienta de gestion de servicio es la fuente del tiempo de espera de la ventana de cambio, dato que la linea base necesita",
     "Solutioning/Proposals - Clients/Banamex/deal-state-0012553407.md"),
]

DEPENDENCIAS = [
    ("C-00", "C-06", "De medicion",
     "La Fase 1 levanta la linea base. Sin ella, la Fase 2 no tiene contra que comparar y el criterio de exito del piloto no se puede evaluar"),
    ("C-00", "C-05", "De vehiculo",
     "El piloto cabe en el laboratorio ya contratado, lo que evita abrir un vehiculo nuevo para la Fase 2"),
    ("C-00", "V-02", "Tecnica",
     "La evidencia automatizada en G3 necesita un pipeline que la genere. Hoy esa pieza vive en otra iniciativa"),
    ("C-06", "V-04", "De dato",
     "La herramienta de gestion de servicio es la fuente del tiempo de espera de la ventana de cambio"),
    ("C-05", "C-00", "De patron",
     "Las compuertas G0 a G4 del laboratorio son el antecedente del modelo de cuatro gates de la propuesta"),
    ("V-01", "C-00", "De secuencia",
     "Si el portal llega antes que el SDLC refinado, sus plantillas apuntan a un toolchain que la Fase 1 todavia no ha decidido"),
]

HITOS = [
    ("H-00", "", "Reencuadre de la propuesta y regreso al cliente",
     "C-00", "Siguiente paso real, despues de las objeciones",
     "Sin reencuadre, volver con el mismo documento repite las dos objeciones", "SIN FECHA, BLOQUEADO POR OB-01 Y OB-02"),
    ("H-01", "2026-11-11", "Entregables 1 y 2 del Anexo B del laboratorio",
     "C-05", "Fecha dura contractual",
     "Pena convencional de nivel A, 3 por ciento del monto mensual por evento", "PENDIENTE"),
    ("H-02", "2026-11-27", "MVP del portal de desarrollador en aceptacion",
     "V-01", "Fecha dura de una iniciativa vecina",
     "Se pierde la ventana antes del congelamiento y el MVP se corre a 2027", "PENDIENTE"),
    ("H-03", "2026-12-01", "Inicio del congelamiento de diciembre de 2026",
     "V-01", "Restriccion operativa",
     "Nada entra a produccion hasta que se levante el congelamiento", "PENDIENTE"),
    ("H-04", "2027-01-01", "Zona D no disponible antes de 2027",
     "C-05", "Dependencia externa",
     "Todo lo que dependa de la Zona D se pospone, por eso existe el laboratorio", "PENDIENTE"),
    ("H-05", "2029-10-11", "Fin de vigencia del Anexo B del laboratorio",
     "C-05", "Frontera contractual",
     "El modelo de referencia tiene que haber salido del laboratorio antes de esta fecha", "PENDIENTE"),
]


# --------------------------------------------------------------------------
# Capa 5: razonamiento
# --------------------------------------------------------------------------

PALANCAS = [
    ("PAL-00", "Linea base y telemetria del ciclo",
     "FR-01", "M-DES-01,M-DES-02,M-DES-03,M-DES-04,M-DES-05", "C-06",
     "Acceso de lectura a las herramientas del ciclo y acuerdo de umbrales con riesgo y cumplimiento",
     "Serie de al menos ocho semanas por equipo, no un promedio puntual",
     "Ninguna otra palanca puede acreditar su efecto, y el esquema de riesgo compartido del partnership queda sin base",
     "Fase 1, cuatro semanas", "PRECONDICION DE TODAS"),
    ("PAL-01", "Triage de dos dimensiones",
     "FR-13,FR-14", "M-DES-03,M-ADO-03", "C-00",
     "Cuestionario unico de triage acordado y arbol de decision validado con la PMO",
     "Porcentaje de iniciativas que entran por el triage y predictibilidad por ruta",
     "Se mantiene la planeacion anual con mas de 250 iniciativas en el mismo embudo",
     "Fase 1", "EN LA PROPUESTA"),
    ("PAL-02", "Consolidacion de decisiones en cuatro gates",
     "FR-10", "M-DES-02,M-CTL-01", "C-00",
     "Mapeo de controles a gates validado con riesgo y cumplimiento",
     "Tiempo de espera en gates antes y despues, con evidencia completa en el gate",
     "Se automatiza la generacion de evidencia que nadie acepta como valida, y la espera no baja",
     "Fase 1 y Fase 2", "EN LA PROPUESTA"),
    ("PAL-03", "Minimos tecnicos: integracion continua, pruebas automatizadas y ambientes",
     "FR-09,FR-12", "M-DES-04,M-DES-05,M-CTL-03", "C-00",
     "Equipo piloto definido con accesos y ambientes confirmados",
     "Frecuencia de despliegue y tasa de fallas antes y despues, sobre el mismo equipo",
     "El equipo sigue liberando agrupado y la liberacion continua no llega",
     "Fase 2, MVP tecnico", "EN LA PROPUESTA"),
    ("PAL-04", "Core emulado y datos sinteticos",
     "FR-03,FR-06", "M-DES-01,M-CTL-03", "C-05",
     "Contratos de interfaz, esquemas de mensaje y reglas de negocio aprobados por el banco",
     "Proporcion de pruebas que dejan de esperar un ambiente del core",
     "Se construye un core emulado que no se parece al real y la prueba no significa nada",
     "Un trimestre", "HABILITABLE, el brain del core ya tiene reglas extraidas del codigo"),
    ("PAL-05", "Asistencia de agentes en las ocho etapas",
     "FR-08,FR-09", "M-ADO-02,M-ADO-05,M-CTL-02", "C-00",
     "Piloto medido, contrato de no entrenamiento sobre el codigo y revision humana en los cuatro gates",
     "Comparacion contra un equipo de control, y deteccion real de defectos por las pruebas generadas",
     "Velocidad ilusoria. La investigacion de referencia muestra relacion negativa con la estabilidad cuando las practicas son inmaduras",
     "Fase 2 y escalamiento", "EN LA PROPUESTA, CON GUARDRAILS"),
    ("PAL-06", "Monitoreo y control transversal automatizado",
     "FR-11", "M-DES-03,M-CTL-04", "C-00",
     "Tablero alimentado por las herramientas del ciclo, no por reportes manuales",
     "Reduccion del esfuerzo de reporte y trazabilidad de riesgos e issues",
     "El gerente de proyecto sigue documentando en lugar de habilitar resultados",
     "Fase 1 y Fase 2", "EN LA PROPUESTA"),
    ("PAL-07", "Catalogo y autoservicio del desarrollador",
     "FR-07", "M-DES-01,M-ADO-02", "V-01",
     "Decision de repositorio y motor de integracion, que hoy esta abierta",
     "Tiempo de arranque de un proyecto antes y despues",
     "Las plantillas quedan apuntando a un toolchain que la Fase 1 puede cambiar",
     "Un trimestre", "EN UNA INICIATIVA VECINA, BLOQUEADA POR CT-01 Y CT-02"),
]

GUARDRAILS = [
    ("GR-01", "Ninguna metrica lleva meta antes de tener linea base",
     "Es la regla que la propia propuesta fijo: las metas se acuerdan con Banamex despues de la Fase 1, con datos propios. Tambien protege el esquema de riesgo compartido del partnership",
     "PoV v3.3, lamina de medicion, y Frictionless SDLC", "ALTA"),
    ("GR-02", "La IA arma la evidencia y el humano decide en los cuatro gates",
     "Las decisiones y el cumplimiento siguen en manos de las personas. Sin esto, alucinacion en logica financiera o en control de seguridad",
     "PoV v3.3, lamina de IA en el SDLC", "ALTA"),
    ("GR-03", "El codigo del banco no sale a un modelo en servicio sin contrato de no entrenamiento",
     "El Anexo B establece que los entregables son propiedad exclusiva de Banamex y que Accenture no puede reutilizarlos ni entrenar modelos con ellos",
     "Anexo B y Frictionless SDLC", "CONTRACTUAL"),
    ("GR-04", "Ningun control regulatorio se elimina: se consolida, se anticipa, se automatiza o se activa segun el riesgo",
     "Es la promesa central de la lamina de simplificacion y lo que el anexo de trazabilidad demuestra control por control",
     "PoV v3.3, anexo A2", "ALTA"),
    ("GR-05", "Una prueba generada que pasa no es evidencia de que sirva",
     "Un agente puede generar pruebas tautologicas que nunca fallan. Se valida inyectando defectos conocidos",
     "PoV v3.3 y Frictionless SDLC", "ALTA"),
    ("GR-06", "El exito del piloto es doble y no se negocia",
     "El desempeno mejora contra la linea base y ningun indicador de control se cruza. Una sin la otra no cuenta",
     "PoV v3.3, lamina de enfoque de ejecucion", "ALTA"),
    ("GR-07", "No entran nombres ni cargos de personas del cliente al brain ni a los artefactos compartibles",
     "Los artefactos salen del perimetro. Los interlocutores se registran como rol",
     "Regla del ecosistema", "ALTA"),
    ("GR-08", "El catalogo de aceleradores y la estimacion interna no se comparten con el cliente",
     "Las laminas 21 y 22 del PoV estan marcadas de forma explicita como no compartir. La tabla interno guarda ese material",
     "PoV v3.3", "ALTA"),
    ("GR-09", "No se muestra equipo ni costo hasta que el cliente confirme el enfoque",
     "Es el diseno del cierre de la propuesta: primero la sesion con la PMO, despues la estimacion, que parte de lo confirmado y no de supuestos",
     "PoV v3.3, lamina de siguientes pasos", "ALTA"),
    ("GR-11", "En esta cuenta la palabra arquetipo ya esta ocupada: aqui se dice patron de solucion",
     "En el Laboratorio de Aceleracion un arquetipo es una plantilla de ambiente provisionable, con cupo por talla y true-up trimestral en el Anexo B, es decir con consecuencia economica. Usar la misma palabra para un patron de entrega en el mismo cliente provoca confusion contractual. Ademas patron de solucion es el termino que el banco ya usa, lo que suma credibilidad en lugar de restarla",
     "lab-brain.db tabla arquetipos y nota al pie de la lamina 09 del PoV", "ALTA"),
    ("GR-10", "Este entorno no se llama sandbox",
     "Se le dice Laboratorio de Aceleracion, Innovation Lab o Entorno de Habilitacion de Ideas",
     "Guardrail de naming del Laboratorio de Aceleracion", "MEDIA"),
]

ESCENARIOS = [
    ("ESC-A", "Las ocho semanas propuestas",
     "Cuatro semanas de validacion y refinamiento con la PMO y los equipos, y cuatro de piloto con un equipo real que recorre los cuatro gates",
     "La PMO confirma el enfoque, y para el Go del piloto hacen falta equipo y aplicacion definidos, accesos y ambientes confirmados, y umbrales acordados",
     "Produce la primera evidencia propia del banco y convierte el caso de negocio en algo defendible",
     "ES LO QUE SE PRESENTO Y EL CLIENTE LO DEVOLVIO: poco aterrizada y muy cara"),
    ("ESC-E", "Reencuadre con datos propios y primer incremento acotado",
     "Volver con una ruta concreta sobre una aplicacion real, construida con lo que los brains ya saben del banco, y un primer compromiso mucho menor que las ocho semanas",
     "Elegir la aplicacion y el equipo con lo que ya hay en el brain del core y en el del laboratorio, sin pedirle al banco un levantamiento previo",
     "Responde a las dos objeciones a la vez: aterriza porque usa datos del propio banco, y baja el precio porque el primer compromiso es un incremento, no un programa",
     "RECOMENDADO COMO SIGUIENTE MOVIMIENTO"),
    ("ESC-B", "Escalar a mas equipos por olas",
     "Despliegue por dominio con metrica por ola y criterio de paro, con el playbook del piloto",
     "Piloto cerrado con el criterio doble cumplido, y decision de repositorio y motor de integracion",
     "Escala con evidencia por ola y permite detener la ola que no mueve la metrica",
     "VIABLE DESPUES DEL PILOTO"),
    ("ESC-C", "Comprometer KPIs de negocio sin linea base",
     "Firmar el esquema de riesgo compartido del partnership antes de que la Fase 1 mida el ciclo",
     "Ninguna que se pueda cumplir hoy",
     "Accenture asume riesgo sobre un punto de partida que nadie conoce, y la discusion de si mejoro o no se vuelve irresoluble",
     "REQUIERE ROMPER EL CRISTAL Y UN DUENO DEL RIESGO"),
    ("ESC-D", "Esperar a que exista la Zona D",
     "No mover el ciclo hasta que el Landing Zone del banco este disponible",
     "Ninguna, es la opcion de no hacer nada",
     "Se pierde la ventana del laboratorio, que ya esta contratado y corriendo, y el banco llega a 2027 sin linea base y sin modelo de referencia",
     "NO RECOMENDADO, el laboratorio existe precisamente para no esperar"),
]


# --------------------------------------------------------------------------
# Capa 6: gobierno y federacion
# --------------------------------------------------------------------------

BRECHAS = [
    ("BR-01", "No existe linea base medida del ciclo: hay diagnostico de Accenture, no telemetria del banco",
     "Sin linea base no hay caso de negocio, no hay metas y no hay riesgo compartido posible",
     "Conjunta, es el objeto de la Fase 1", "PAL-00 y con ella todas las demas", "CUBIERTA POR LA PROPUESTA"),
    ("BR-02", "La PMO no ha confirmado el enfoque, de modo que la estimacion no se entrega",
     "Es el unico paso que separa la propuesta de su arranque",
     "Banamex", "C-00 y todo el programa", "ABIERTA"),
    ("BR-03", "No se conoce el inventario de equipos de desarrollo ni su distribucion por dominio",
     "Sin inventario no se puede elegir el equipo del piloto ni dimensionar el escalamiento",
     "Banamex", "Fase 1 y ESC-B", "DATO-REQUERIDO"),
    ("BR-04", "No hay telemetria accesible del pipeline ni del repositorio actuales",
     "Las metricas de desempeno quedan sin fuente automatica y el levantamiento se vuelve manual",
     "Banamex", "PAL-00", "DATO-REQUERIDO"),
    ("BR-05", "No esta confirmada la politica de cambio del banco ni la duracion real de su ventana",
     "La espera de la ventana es candidata a ser el tiempo dominante del ciclo y no esta cuantificada",
     "Banamex", "PAL-02", "DATO-REQUERIDO"),
    ("BR-06", "No hay vehiculo contractual para SDLC Reinvent fuera del laboratorio",
     "El Anexo B cubre el reporte mensual de actividades del ciclo dentro del laboratorio, no la transformacion del banco",
     "Conjunta, dentro del modelo de partnership", "C-00", "ABIERTA"),
    ("BR-07", "Los contratos de interfaz y los esquemas de mensaje del core no estan redactados",
     "El core emulado no se puede construir sin ellos, y con ellos se habilita PAL-04",
     "Banamex, con propuesta de Accenture derivada del brain del core", "PAL-04", "DATO-REQUERIDO"),
    ("BR-08", "Cinco de las cifras del diagnostico son no exhaustivas y estan por validar",
     "Son la base del argumento de entrada de la propuesta. Si una se cae en la Fase 1, el argumento se debilita frente al cliente",
     "Conjunta, en la Fase 1", "El argumento de por que ahora", "DATO-REQUERIDO"),
    ("BR-10", "El mapa del SDLC actual tiene un anio: se levanto en octubre de 2025 y se presento en octubre de 2026",
     "Es el punto de partida de toda la propuesta y el cliente vive ese proceso todos los dias, asi que nota de inmediato lo que ya cambio. De ahi cuelgan los cuatro conteos que sostienen el argumento, incluido el titular de pasar de alrededor de 16 decisiones a 4 gates",
     "Conjunta, es un refresco de medio dia con la PMO", "OB-01, el titular de la propuesta y DG-02, DG-05, DG-06, DG-07", "ABIERTA"),
    ("BR-11", "No sabemos cuanto simplifico el banco por su cuenta en el ultimo anio",
     "La propia lamina reconoce que Banamex ya avanzo con su SDLC de transicion. Si parte de la simplificacion ya ocurrio, el valor que reclamamos se reduce y corremos el riesgo de cobrar por algo que el cliente ya hizo",
     "Banamex", "El tamano del premio y la credibilidad del titular", "DATO-REQUERIDO"),
    ("BR-09", "Tres aceleradores del catalogo estan marcados como a validar y hay posible traslape entre ellos",
     "Se ofrecen como respaldo de la propuesta sin documentacion detallada",
     "Accenture", "La credibilidad del anexo de aceleradores", "ABIERTA"),
]

DECISIONES = [
    ("D-01", "Repositorio de codigo de destino del banco",
     "Permanecer en el repositorio actual o migrar al que propone el diseno corporativo",
     "Banamex, area de ingenieria de plataforma",
     "Define a que repositorio se enganchan el catalogo y las plantillas de la iniciativa vecina del portal", "ABIERTA"),
    ("D-02", "Motor de integracion continua de destino",
     "Permanecer en el motor actual o adoptar el del diseno corporativo",
     "Banamex, area de ingenieria de plataforma",
     "Define que definiciones de pipeline generan las plantillas y como se automatiza la evidencia de G3", "ABIERTA"),
    ("D-03", "Papel del laboratorio en la transformacion",
     "Piloto acotado del modelo, o plataforma desde la que se despliega al resto del banco",
     "Conjunta",
     "Cambia el dimensionamiento del programa y el vehiculo contractual que se necesita", "ABIERTA"),
    ("D-04", "Vehiculo contractual de SDLC Reinvent",
     "Orden de servicio sobre el Contrato Maestro, control de cambio al Anexo B, o un instrumento propio del partnership",
     "Conjunta",
     "Hoy no hay instrumento que cubra la transformacion del ciclo fuera del laboratorio", "ABIERTA"),
    ("D-05", "Alojamiento del modelo que asiste el ciclo",
     "Servicio gestionado con contrato de no entrenamiento, o modelo autoalojado en infraestructura del banco",
     "Conjunta, con revision de seguridad",
     "La clausula de propiedad intelectual del Anexo B y el marco regulatorio condicionan la opcion", "ABIERTA"),
    ("D-06", "Equipo y aplicacion del piloto",
     "Un equipo con entrega frecuente, o uno con mayor friccion y mas que ganar",
     "Conjunta",
     "Determina si la evidencia del piloto es extrapolable al resto del banco", "ABIERTA"),
    ("D-07", "Secuencia entre la linea base y el esquema de riesgo compartido",
     "Firmar el skin in the game despues de la Fase 1, o acordar antes el metodo de medicion y fijar las metas despues",
     "Conjunta, con la parte comercial",
     "La propuesta prohibe fijar metas sin linea base y el partnership pide KPIs de negocio. La segunda opcion es la unica que respeta ambas", "ABIERTA"),
    ("D-09", "Como se responde a las dos objeciones del cliente",
     "Reencuadrar con datos propios y un primer incremento acotado, bajar el alcance manteniendo el documento, o insistir con el mismo material y mas explicacion",
     "Accenture, con la parte comercial",
     "Volver con el mismo documento repite las objeciones. La primera opcion es la unica que ataca las dos a la vez", "ABIERTA"),
    ("D-10", "Quien paga la linea base",
     "Dentro del primer incremento como parte del trabajo, absorbida por Accenture como inversion del partnership, o pospuesta y sustituida por una medicion ligera",
     "Conjunta, con la parte comercial",
     "El cliente objeto el precio y lo primero que se le cobraba era medir. El esquema de riesgo compartido no puede firmarse sin esa medicion", "ABIERTA"),
    ("D-08", "Alternativa de piloto si el banco no quiere el MVP tecnico",
     "MVP tecnico de un equipo, o un equipo especifico con alcance y objetivo definidos para validar la cascada en la practica",
     "Banamex",
     "Cambia el equipo de la Fase 2 y la estimacion interna en nueve semanas-persona", "ABIERTA"),
]

# Los 27 casos de uso de IA en el ciclo, rescatados de la lamina 06 y limpiados de
# marca: ningun activo de Accenture aparece aqui. La herramienta se elige con el
# banco; lo que este catalogo fija es que hace la IA, con cuanta autonomia, que
# tiene que existir antes y en que etapa de la hoja de ruta entra.
#
# nivel: APOYO A DECISION prepara y el humano decide
#        ASISTIDA         genera borradores para revision
#        AGENTE           ejecuta con supervision
CASOS_IA = [
    ("UC-01", "Demanda", "Completar el triage a partir de la solicitud", "APOYO A DECISION",
     "Cuestionario unico de triage acordado", "Etapa 1"),
    ("UC-02", "Demanda", "Proponer metodo y ruta", "APOYO A DECISION",
     "Arbol de decision validado con la PMO", "Etapa 1"),
    ("UC-03", "Demanda", "Estimar por analogia con iniciativas pasadas", "APOYO A DECISION",
     "Historico de iniciativas con esfuerzo real, hoy no disponible", "Etapa 3"),
    ("UC-04", "Iniciacion", "Redactar historias de alto nivel", "ASISTIDA",
     "Plantilla de historia y criterios de calidad acordados", "Etapa 1"),
    ("UC-05", "Iniciacion", "Extraer los requisitos regulatorios aplicables", "ASISTIDA",
     "Corpus regulatorio del banco accesible y vigente", "Etapa 1"),
    ("UC-06", "Iniciacion", "Identificar las aplicaciones impactadas", "ASISTIDA",
     "Inventario de aplicaciones y dependencias con calidad suficiente", "Etapa 2"),
    ("UC-07", "Planeacion", "Refinar el backlog con criterios de aceptacion", "ASISTIDA",
     "Definicion de terminado acordada por equipo", "Etapa 1"),
    ("UC-08", "Planeacion", "Proponer la estrategia de pruebas segun la ruta", "ASISTIDA",
     "Matriz de rutas y gates definida", "Etapa 1"),
    ("UC-09", "Diseno", "Generar diseno de alto y bajo nivel", "ASISTIDA",
     "Estandares de arquitectura del banco en formato consultable", "Etapa 2"),
    ("UC-10", "Diseno", "Modelar amenazas", "ASISTIDA",
     "Catalogo de amenazas y controles del banco", "Etapa 2"),
    ("UC-11", "Diseno", "Analizar el impacto de cambios", "ASISTIDA",
     "Trazabilidad entre codigo, servicios y aplicaciones", "Etapa 2"),
    ("UC-12", "Construccion", "Codificar historias", "AGENTE",
     "Repositorio decidido, estandares de codigo y revision humana obligatoria", "Etapa 2"),
    ("UC-13", "Construccion", "Revisar los cambios propuestos", "AGENTE",
     "Integracion continua en el equipo", "Etapa 2"),
    ("UC-14", "Construccion", "Corregir vulnerabilidades detectadas", "AGENTE",
     "Analisis de seguridad corriendo en el pipeline", "Etapa 3"),
    ("UC-15", "Pruebas y seguridad", "Generar casos de prueba", "ASISTIDA",
     "Criterios de aceptacion escritos, es lo unico que pide", "Etapa 1"),
    ("UC-16", "Pruebas y seguridad", "Generar datos de prueba sinteticos", "AGENTE",
     "Politica de datos sinteticos y de enmascaramiento", "Etapa 2"),
    ("UC-17", "Pruebas y seguridad", "Priorizar la regresion", "AGENTE",
     "Suite de regresion automatizada y historico de fallas", "Etapa 2"),
    ("UC-18", "Pruebas y seguridad", "Redactar el reporte de salida de pruebas", "ASISTIDA",
     "Resultados de ejecucion accesibles desde el pipeline", "Etapa 2"),
    ("UC-19", "Liberacion", "Generar el plan de despliegue", "AGENTE",
     "Despliegue automatizado y ambientes equivalentes", "Etapa 2"),
    ("UC-20", "Liberacion", "Generar el plan de rollback", "AGENTE",
     "Despliegue automatizado y versionado de artefactos", "Etapa 2"),
    ("UC-21", "Liberacion", "Verificar el servicio despues de liberar", "AGENTE",
     "Observabilidad con senales por servicio", "Etapa 3"),
    ("UC-22", "Post-implementacion", "Extraer lecciones de la entrega", "ASISTIDA",
     "Registro de la entrega en las herramientas del ciclo", "Etapa 1"),
    ("UC-23", "Post-implementacion", "Comparar el valor real contra el caso de negocio", "ASISTIDA",
     "Caso de valor registrado en G1 y datos de produccion", "Etapa 2"),
    ("UC-24", "Post-implementacion", "Cerrar historias, riesgos e issues", "AGENTE",
     "Criterios de cierre definidos por tipo", "Etapa 2"),
    ("UC-25", "Transversal", "Vigilar retrasos y riesgos en todo el ciclo", "AGENTE",
     "Tablero alimentado por las herramientas, no por reportes manuales", "Etapa 3"),
    ("UC-26", "Transversal", "Detectar gates estancados", "AGENTE",
     "Gates instrumentados con marca de tiempo", "Etapa 3"),
    ("UC-27", "Transversal", "Detectar evidencia faltante antes del gate", "APOYO A DECISION",
     "Paquete de evidencia obligatorio definido por gate", "Etapa 1"),
]

# Revision lamina por lamina del PoV. Es el plan de reencuadre.
LAMINAS = [
    ("LAM-01", 1, "Por que ahora",
     "REHACER",
     "Las cuatro cifras no cargan el mismo peso. La mas grande, 1,337 contra 500, prueba que la demanda excede la capacidad, no que el ciclo frene, y un lector financiero la voltea. El 2.3 de 4 es una calificacion nuestra sobre ellos. Los referentes invitan a comprar copilotos en lugar de un ciclo. No hay una sola cifra en pesos ni en capacidad, y el consejo se comprometio a gasto plano",
     "El formato de cuatro cifras grandes funciona. El problema son las cifras, no el molde",
     "Sustituir al menos dos cifras por datos extraidos de sus propios sistemas y agregar una economica o de capacidad liberada"),
    ("LAM-02", 2, "La propuesta",
     "REHACER",
     "El subtitulo confiesa la objecion al decir que partimos de un framework prescriptivo que sera validado despues. Las seis siglas de gobierno sugieren mas proceso, no menos. La casilla de experiencia en Banamex no tiene un solo proyecto ni fecha. Lo unico concreto, de alrededor de 16 decisiones a 4 gates, esta en tipografia chica en la tercera columna",
     "La frase de 16 decisiones a 4 gates es la mas fuerte del documento",
     "Voltear la lamina: titular con el delta, mostrar un requerimiento real recorriendo el modelo y mandar las cuatro fuentes y las siglas al anexo"),
    ("LAM-03", 3, "El SDLC actual",
     "REFRESCAR, NO TIRAR",
     "El mapa se levanto en octubre de 2025 y se presento un anio despues. Es el unico contenido especifico de Banamex y esta viejo. La banda superior admite que el banco ya avanzo mientras el mapa de abajo es de antes de ese avance. De esa foto cuelgan los cuatro conteos que sostienen el titular",
     "Es la unica lamina que habla en el idioma del cliente, con los nombres de sus propios artefactos. Eso demuestra conocimiento real de su proceso",
     "Refrescarlo con la PMO en sesion de trabajo, no entregarlo refrescado. Medio dia, corrige la objecion mas cara y deja el mapa co-escrito con el cliente"),
    ("LAM-04", 4, "SDLC Reinvent, el modelo objetivo",
     "SUSTITUIR",
     "Promete menos pasos y muestra ocho columnas con mas de cuarenta cajas, dos columnas mas que el mapa actual: el ojo cuenta cajas y ve mas, no menos. El control proporcional al riesgo, que es la mitad del titulo, solo aparece como una linea roja y un recuadro punteado. Los numeritos de mapeo contestan una objecion que el cliente aun no hizo. No hay tiempo, no hay dinero y no hay un ejemplo real",
     "La banda transversal de monitoreo y control, y sobre todo los hitos financieros: pre-aprobacion de presupuesto, pago a proveedor contra UAT y capitalizacion por entrega. Es lo unico del deck que toca dinero y esta escondido como codigo de color",
     "Sustituir por el mismo requerimiento recorriendo los dos caminos, con tiempos y aprobaciones contadas. El modelo de ocho etapas se deduce del carril de abajo sin explicarlo"),
    ("LAM-11", 11, "Calendario",
     "REDECIDIR EL TAMANIO ANTES DE REDIBUJAR",
     "El cliente dijo que era cara y la version nueva crecio: de dos fases y ocho semanas comprometidas a tres fases y nueve semanas, mas una de preparacion. Ademas la Fase 3 corre de la semana 1 a la 9, en paralelo con las otras dos, asi que no es una fase sino una tercera corriente, y su barra pinta trabajo desde la semana 1 cuando sus actividades ocurren de la 7 a la 9. Siete colores sin sistema, unos marcan fase y otros marcan tipo de trabajo. Los rombos de hito no coinciden con la fila de hitos y dos rombos del mismo color significan cosas distintas. Y no hay una sola fila de lo que tiene que poner el banco",
     "La idea de cerrar con entregables antes de la pausa de fin de anio y de arrancar la habilitacion en enero de 2027, que amarra con la hoja de ruta de madurez",
     "Primero decidir el compromiso mas pequenio que sea creible, idealmente las cuatro semanas de validacion con una decision de seguir o parar al final, y despues dibujarlo con dos corrientes, un color por corriente, hitos con fecha y una fila explicita de lo que necesitamos de Banamex"),
    ("LAM-09", 9, "Triage 2, la robustez",
     "CONSERVAR LA COLUMNA IZQUIERDA, TIRAR LA MATRIZ",
     "La matriz codifica al menos cuatro cosas a la vez sobre la misma reticula: que etapas recorre, con que profundidad las recorre, el rigor de cada gate y el nivel de cumplimiento, con pildoras de cuatro rellenos distintos y cuarenta y ocho puntos por leer. Es el mismo exceso de la lamina de simplificacion. Y otra vez compiten dos taxonomias: seis arquetipos a la izquierda contra cuatro rutas a la derecha, sin que el mapeo entre ellas este dibujado",
     "Los seis arquetipos con su talla y su nivel, las dos reglas de escalamiento, que son concretas y verificables, y sobre todo la nota al pie que dice que estos arquetipos son lo que en Banamex ya se llama patrones de solucion",
     "Dejar la columna izquierda como lamina completa, subir la nota de patrones de solucion al titulo, sustituir la matriz por dos ejemplos de recorrido, y pedirle a la PMO el conteo de solicitudes del ultimo trimestre por patron. Sin volumen es una taxonomia; con volumen es un caso de negocio"),
    ("LAM-08", 8, "Triage 1, el metodo",
     "REHACER, TIENE UN ERROR CONCEPTUAL",
     "Dice lo mismo dos veces en dos lenguajes: la columna izquierda organiza por tipo de financiamiento y el arbol por preguntas, y las dos taxonomias no se alinean, tres bloques contra cuatro resultados. Peor, hay dos cosas distintas llamadas Hibrido: una es financiamiento compartido con un equipo de capacidad y la otra es una carencia tecnica. El arbol cambia la orientacion de las ramas entre niveles, de modo que el ojo se pierde. El titulo suena a reproche, le dice al banco que su forma de trabajar la decide Finanzas. Las reglas en amarillo son letra de contratacion metida en medio del argumento, y la caja de lo que el arbol no cambia contesta objeciones que nadie hizo",
     "La idea de fondo es excelente y cabe en una linea: lo que se aprueba es lo que queda fijo. Si se aprueba un alcance, manda el alcance; si se aprueba una capacidad, manda la capacidad",
     "Una sola pregunta decide el metodo. Las otras dos no deciden metodo, preparan: una detecta dependencia con un equipo de capacidad y otra detecta falta de minimos tecnicos. El llamado hibrido de MVP tecnico no es un metodo sino una obra de habilitacion que se financia como proyecto acotado, que es exactamente lo que hace el piloto. Separarlos elimina la ambiguedad y conecta con la hoja de ruta"),
    ("LAM-07", 7, "Simplificacion, lean no es soft",
     "PARTIR EN DOS: UN MENSAJE AL FRENTE Y EL MAPA AL ANEXO",
     "Seis codigos simultaneos sobre 92 objetos de texto pequenio, y dos de esos codigos son tipograficos, tachado y punteado, de modo que hay dos gramaticas encima de la misma reticula. La leyenda vive al pie y es la unica llave, asi que hay que bajar, memorizar seis significados y volver. El color esta invertido: los 43 que se mantienen, que son lo menos interesante, van en blanco, y lo que importa compite entre cinco colores saturados. El titulo promete menos pasos y la imagen muestra los mismos 92 elementos, asi que la tesis no se puede verificar mirando. Y los tachados sobre controles del cliente contradicen el subtitulo: decimos que ningun control regulatorio se elimina y mostramos tachones sobre sus controles",
     "El analisis elemento por elemento es trabajo real y es la prueba de que no estamos siendo blandos. La fila de como se demuestra, con los cuatro indicadores de control, es la respuesta al miedo que la propia lamina genera",
     "Al frente, un solo mensaje: 92 elementos, 43 se mantienen y 49 cambian de forma, con tres controles que el cliente reconozca mostrando donde queda cada uno. El mapa coloreado completo pasa al anexo y se ofrece como documento de trabajo para la sesion con riesgo y cumplimiento, que es donde la exhaustividad si es una virtud"),
    ("LAM-06", 6, "IA en el SDLC",
     "REHACER SIN MARCA",
     "La fila de aceleradores convierte la lamina en catalogo de productos de Accenture, ocho en ocho etapas del ciclo del banco. A un cliente cuyo mandato de consejo es construir capacidades locales para salir de una dependencia, eso se lee como cambiar de dependencia. Ademas invita a una comparacion de compra contra la fila de mercado que esta justo debajo, y nombra al menos un activo que el catalogo interno marca como por validar",
     "El trabajo de identificar los casos de uso etapa por etapa, el gradiente honesto de autonomia y las dos reglas de gobierno: la IA arma la evidencia y el humano decide, y la IA genera las pruebas pero la ejecucion sigue siendo deterministica y auditable",
     "Quitar la fila de aceleradores y sustituirla por que tiene que existir para habilitar cada caso y en que etapa de la hoja de ruta entra. Los 27 casos quedan en la tabla casos_uso_ia, sin marca"),
    ("LAM-05", 5, "Hoja de ruta de madurez",
     "FUNCIONA, ES LA PLANTILLA DEL RESTO",
     "Lo unico por apretar: solo la Etapa 1 tiene fecha, de modo que no hay respuesta si preguntan por el horizonte de las siguientes. La caja Aspiracional es la mas brillante de la lamina y esta vacia de contenido. La fila de aceleradores nombra activos que el catalogo interno marca como a validar, y hay que poder enseniarlos si preguntan. Y el pie sigue cargando el 2.3 de 4",
     "Todo. Ubica al cliente en el mapa, pone la unica fecha concreta del documento, acota lo vendido a la Etapa 1 y encadena cada etapa con la siguiente. La fila de que habilita la siguiente convierte la linea base en llave de la etapa 2 en lugar de costo administrativo",
     "Promoverla al frente del deck y usar su logica, ubicar, acotar y encadenar, para rehacer LAM-01 y LAM-04. Si lo que se vende es la Etapa 1, el modelo objetivo completo no deberia estar en la lamina principal"),
]

# Lo que el cliente respondio al presentarle el PoV. Es el estado real del deal.
OBJECIONES = [
    ("OB-01", "Poco aterrizada", "Banamex, al presentar el PoV",
     "El cuerpo del documento, sin notas del orador, lleva 35 marcas de provisionalidad repartidas en 13 de sus 22 laminas: siete ilustrativo, trece a validar, cuatro preliminar, cuatro no exhaustivo, tres a definir, dos por acordar y dos estimado",
     "El documento ofrece un metodo, no una respuesta. Lo unico especifico de Banamex es el mapa del SDLC actual, que se levanto en octubre de 2025 y se presento un anio despues sin refrescar, marcado como no exhaustivo y a validar. Todo lo demas, las rutas, los umbrales, las herramientas y los criterios, se promete para la Fase 1",
     "Llevar datos propios del banco en lugar de promesas de levantarlos. El brain del core ya tiene 1,583 reglas extraidas de su codigo, 152 programas y 26 capacidades; el brain del laboratorio tiene las compuertas y el stack. Con eso se puede mostrar una ruta real sobre una aplicacion real en lugar de un marco generico",
     "ABIERTA"),
    ("OB-02", "Muy cara", "Banamex, al presentar el PoV",
     "La propuesta no muestra equipo ni costo: la lamina de siguientes pasos dice de forma explicita que la estimacion se entrega despues de que el cliente confirme el enfoque",
     "El cliente puso precio por su cuenta a partir de la forma del pedido: ocho semanas, dos fases, talleres por area, un piloto con MVP tecnico y un equipo que se intuye grande. Tambien pesa que lo primero que se cobra es medir, no entregar, y que el consejo ya fijo mantener el gasto plano mientras crece el volumen",
     "Reducir el primer compromiso a un incremento que se pague solo, y usar el esquema de riesgo compartido que el propio partnership propone. La tension a resolver es que el riesgo compartido necesita la linea base, y la linea base es justo lo que el cliente no quiere pagar",
     "ABIERTA"),
]

# Material marcado de forma explicita como no compartible con el cliente.
INTERNO = [
    ("IN-01", "Estimacion base del esfuerzo", "Entre 30 y 32 semanas-persona, con semana cero incluida",
     "NO COMPARTIR CON EL CLIENTE", "PoV v3.3, lamina 22"),
    ("IN-02", "Esfuerzo adicional si el piloto es el MVP tecnico", "Nueve semanas-persona mas",
     "NO COMPARTIR CON EL CLIENTE", "PoV v3.3, lamina 22"),
    ("IN-03", "Diferencia entre lo comprometido y lo estimado", "La v3.3 comprometia ocho semanas y estimaba nueve. La version nueva ya compromete nueve semanas con el banco mas una de preparacion, de modo que el colchon interno desaparecio y el alcance crecio justo despues de que el cliente objeto el precio",
     "NO COMPARTIR CON EL CLIENTE. Revisar: la lamina interna de estimacion quedo desalineada con el deck vigente", "PoV v3.3 lamina 22 frente a la lamina 11 de la version nueva"),
    ("IN-04", "Equipo base", "Gobierno de la cuenta al 10 por ciento, lider de SDLC y procesos, especialista de gobierno riesgo y cumplimiento, analista de medicion y datos, y expertos puntuales",
     "NO COMPARTIR CON EL CLIENTE", "PoV v3.3, lamina 22"),
    ("IN-05", "Equipo opcional del MVP tecnico", "Ingeniero de DevOps y ingeniero de automatizacion de pruebas, solo si el piloto es el MVP tecnico",
     "NO COMPARTIR CON EL CLIENTE", "PoV v3.3, lamina 22"),
    ("IN-06", "Catalogo de aceleradores", "Dieciocho aceleradores de Accenture, de los cuales cinco estan marcados como a validar",
     "NO COMPARTIR CON EL CLIENTE", "PoV v3.3, lamina 21"),
    ("IN-07", "Dato descartado a proposito", "La cifra publica de reducir a la mitad el tiempo de desarrollo es de otro banco, no de Banamex, y no debe usarse",
     "NO COMPARTIR CON EL CLIENTE", "PoV v3.3, notas del anexo de benchmark"),
]

FUENTES = [
    ("FU-01", "propuesta", "source/docs/Banamex_SDLC_Reinvent_PoV_for_Discussion_v3_3.pptx",
     "Fuente autoritativa de la propuesta: etapas, gates, rutas, triage, fases, entregables, medicion y aceleradores",
     "2026-10", "ALTA, es lo que se presento"),
    ("FU-02", "mandato", "Narrativa de valor de la estrategia de salida de la TSA, presentada al consejo",
     "El compromiso de time to market y productividad del desarrollador del que cuelga SDLC Reinvent",
     "2024", "ALTA, aprobada por el consejo"),
    ("FU-03", "partnership", "Modelo de colaboracion Banamex y Accenture",
     "Las cinco areas, el laboratorio como vehiculo y el esquema de riesgo compartido",
     "2026", "ALTA"),
    ("FU-04", "diagnostico", "Diagnostico de TI, assessment de madurez y levantamiento del SDLC actual",
     "Las cifras del argumento de entrada, todas no exhaustivas",
     "2025-10", "MEDIA, no exhaustivo y a validar en la Fase 1"),
    ("FU-05", "deal-state", "Solutioning/Proposals - Clients/Banamex/, cuatro iniciativas vecinas",
     "Contexto adyacente y el conflicto de toolchain",
     "2026-07", "ALTA para su propio alcance, ajena a esta propuesta"),
    ("FU-06", "brain", "projects/laboratorio-aceleracion/digital-brain/lab-brain.db",
     "INI-04, compuertas del ciclo de referencia, stack y brechas del laboratorio",
     "2026-10-19", "ALTA"),
    ("FU-07", "brain", "systems/core/unisys/digital-brain/brain.db",
     "Reglas de negocio del core y cadencia historica de cambio",
     "2026-10-15", "ALTA"),
    ("FU-08", "agente", "Digital Core/03 - SPE/Frictionless SDLC/CLAUDE.md",
     "Guardrails, antipatrones y principio rector del sub-offering",
     "2026-05-28", "ALTA"),
]

BRAINS = [
    ("BF-01", "Laboratorio de Aceleracion", str(LAB_BRAIN),
     "INI-04, compuertas del ciclo de referencia, stack y brechas",
     "Federado por referencia. Aqui no se duplica su corpus", 0),
    ("BF-02", "Core Unisys ClearPath", str(CORE_BRAIN),
     "Reglas de negocio del core, inventario de programas y cadencia historica de cambio",
     "Federado por referencia y solo en agregado. No se copian nombres de personas", 0),
]


# --------------------------------------------------------------------------
# Construccion
# --------------------------------------------------------------------------

# --------------------------------------------------------------------------
# Capa 7: el interlocutor, el benchmark local, la doctrina de casa
# Levantada el 2026-10-28. Todo de fuente publica con fecha.
# --------------------------------------------------------------------------

# Trayectoria de Francisco Leyva. Cambia por completo que se le puede vender.
INTERLOCUTOR = [
    ("FL-01", "1990",
     "Se gradua de ingeniero en Sistemas en la Universidad Iberoamericana y entra a Tecnosys. Como lider de proyecto instala en Bancomer el modulo de hipotecas y credito automotriz de Altamira",
     "Lleva 35 anios alrededor de cores bancarios. Instalo el mismo core que decadas despues seguiria corriendo en BBVA Mexico",
     "IT Masters Mag 2020-12-16"),
    ("FL-02", "1993 a 1994", "Trabaja en Argentina con Andersen Consulting",
     "Primer paso en consultoria", "IT Masters Mag 2020-12-16"),
    ("FL-03", "1997 a 2003", "Trabaja en Accenture entre Buenos Aires y Madrid. Seis anios",
     "ES EX ACCENTURE. Sabe como se arma, se estima y se precia una propuesta nuestra. Explica con precision quirurgica el reproche de poco aterrizada y muy cara",
     "IT Masters Mag 2020-12-16"),
    ("FL-04", "2003", "BBVA lo contrata en Madrid como director de la plataforma de Banking",
     "Entra a BBVA por la via tecnica, no por la de negocio", "IT Masters Mag 2020-12-16"),
    ("FL-05", "2004 a 2005", "Director de sistemas de Pensiones y Seguros America, en Chile",
     "Primera responsabilidad regional", "IT Masters Mag 2020-12-16"),
    ("FL-06", "2006", "Vuelve a Madrid a dirigir la fabrica de software y despues el diseno y desarrollo de productos y servicios",
     "Dirigio una fabrica de software. No hay que explicarle que es una cadena de entrega",
     "IT Masters Mag 2020-12-16"),
    ("FL-07", "2010", "Nombrado director de Sistemas de BBVA Mexico",
     "Conoce el mercado de talento de ingenieria mexicano desde adentro", "IT Masters Mag 2020-12-16"),
    ("FL-08", "2013", "Su responsabilidad se amplia a tecnologia, operaciones, transformacion, datos y seguridad",
     "Mismo perimetro que tiene hoy en Banamex", "IT Masters Mag 2020-12-16"),
    ("FL-09", "2015", "Con Hugo Najera adopta Agile y Scrum. Pasan a lanzamientos trimestrales en todos los canales",
     "Llego a liberacion trimestral en un banco mexicano hace once anios. Ese es el piso de su expectativa",
     "IT Masters Mag 2020-12-16"),
    ("FL-10", "2020-12-16", "Recibe el premio IT Master del anio",
     "Es la entrevista de la que salen casi todas sus frases sobre como piensa", "IT Masters Mag"),
    ("FL-11", "2022-01-14", "Dirige la nueva area global de Software de BBVA, con mas de 16,000 personas entre internas y externas",
     "Dirigio una organizacion de software mas del doble de grande que la de Sistemas de Banamex",
     "CIO Espania 2022-01-14"),
    ("FL-12", "2024-10-19", "Citigroup anuncia su contratacion. Bloomberg reporta que supervisó una transformacion de software impulsada por mas de 15,000 ingenieros. Mision declarada: dirigir los cambios en la arquitectura tecnologica antes de la oferta publica",
     "En ese momento la oferta publica era para finales de 2025. Hoy se perfila a 1T27: el calendario se movio dos anios debajo de el",
     "El Financiero y Bloomberg 2024-10-19"),
    ("FL-13", "2024-11-04", "Toma el cargo en Banamex. Reporta a Manuel Romo",
     "Inicio del reloj de su gestion", "El Financiero y Bloomberg 2024-10-19"),
    ("FL-14", "2025-01-06", "Describe en Expansion el plan a seis anios por 1,700 millones de dolares",
     "Nueve semanas despues de llegar ya tenia plan publico. El plan va hoy en el anio dos de seis",
     "Expansion 2025-01-06 y 2025-01-09"),
    ("FL-15", "2025-04-24", "Ultima entrevista publica conocida",
     "Dieciocho meses de silencio publico. Todo lo que creemos saber de su agenda viene de antes de Chico Pardo",
     "IT Masters Mag 2025-04-24"),
]

# Sus propias frases, con fecha. Son el guion de la propuesta.
CITAS = [
    ("CI-01", "2020-12-16", "IT Masters Mag, como CIO de BBVA Mexico",
     "Un tercero no conoce mejor tu negocio que tu mismo",
     "Su tesis de capacidad propia tiene 25 anios y un caso de exito propio: reinternalizo operaciones y bajo un proceso de aclaraciones de 30 dias a resolucion inmediata. Proponerle mas dependencia externa es proponerle lo contrario de su biografia",
     "VIGENTE, lo repitio en 2025 en Banamex"),
    ("CI-02", "2020-12-16", "IT Masters Mag",
     "corrimos la carrera sin cambiar la rueda del coche",
     "Describia acelerar la entrega sin tocar el core. Es literalmente el problema que tiene hoy en Banamex. Ya sabe que se puede: lo que no tiene es tiempo ni organizacion",
     "VIGENTE como analogia"),
    ("CI-03", "2020-12-16", "IT Masters Mag",
     "La tecnologia es un medio, no un fin",
     "No le interesa una propuesta cuyo centro de gravedad sea una herramienta", "VIGENTE"),
    ("CI-04", "2020-12-16", "IT Masters Mag",
     "La banca es un negocio muy anacronico. Esta en peligro de muerte",
     "Tiene urgencia estructural, no solo de calendario", "VIGENTE"),
    ("CI-05", "2020-12-16", "IT Masters Mag",
     "Hemos conseguido trabajar de manera sincrona; eso es Agile",
     "Define el metodo por el resultado, no por la ceremonia. Cualquier lamina de ritual lo pierde", "VIGENTE"),
    ("CI-06", "2022-01-14", "CIO Espania, sobre globalizar componentes en BBVA",
     "globalizar estos componentes en todos los paises nos llevaria ocho anios en condiciones normales. Con estos avances queremos hacerlo en cuatro",
     "Contexto: cada pais de BBVA construia sus componentes por separado y la meta era volverlos compartidos. No fijo fecha de termino: fijo cuanto costaria al ritmo normal y por cuanto queria ganarle. Razona en factores de compresion contra una linea base, no en absolutos. CONSECUENCIA: una promesa absoluta del tipo le bajamos el tiempo a seis semanas no se apoya en nada y la va a ver de inmediato. Su metodo exige un denominador. El pone el factor, nosotros ponemos el denominador: por eso la medicion va primero",
     "VIGENTE como forma de pensar"),
    ("CI-07", "2022-01-14", "CIO Espania",
     "una mayor reutilizacion de los componentes que construimos para entregar soluciones de forma mas rapida y eficiente",
     "Su modelo mental es consolidar y reutilizar para acelerar", "VIGENTE"),
    ("CI-08", "2025-04-24", "IT Masters Mag, ya en Banamex",
     "Hoy dependemos demasiado de terceros",
     "Es la agenda de reducir contratacion externa, dicha en Banamex y consistente con CI-01",
     "A CONFIRMAR, tiene 18 meses"),
    ("CI-09", "2025-04-24", "IT Masters Mag",
     "Prefiero los despliegues en periodos cortos. Los proyectos grandes, de varios anios, suelen desviarse",
     "No compra un programa de tres fases con trece entregables", "A CONFIRMAR, tiene 18 meses"),
    ("CI-10", "2025-04-24", "IT Masters Mag",
     "No se cuestionan las inversiones. Son recursos generosos, pero tambien con una exigencia clara de orden y prioridades",
     "La objecion de muy cara no era de precio sino de prioridad. OJO: es anterior a Chico Pardo y la disciplina de gasto bajo un consejo que prepara oferta publica puede ser mas dura hoy",
     "A CONFIRMAR, cambio el dueno despues"),
    ("CI-11", "2025-04-24", "IT Masters Mag",
     "Las transformaciones que valen la pena se construyen ladrillo a ladrillo",
     "Define el formato que acepta: un ladrillo pequenio, visible y con fecha corta", "A CONFIRMAR, tiene 18 meses"),
    ("CI-12", "2025-04-24", "IT Masters Mag",
     "necesitamos estar listos, y eso pasa por estar listos tecnologicamente",
     "Liga la oferta publica con la preparacion tecnologica. El ciclo de entrega es prerrequisito, no eficiencia interna",
     "A CONFIRMAR, tiene 18 meses"),
]

# Lo que ya logro en BBVA. Fija el estandar contra el que medira lo que propongamos.
BENCH = [
    ("BM-01", "BBVA", "Resultado propio de Leyva",
     "La red de 13,000 cajeros paso de 8 por ciento de indisponibilidad a menos de 1 por ciento",
     "2020", "Autorreportado", "Demuestra que entrega numeros duros, no narrativa"),
    ("BM-02", "BBVA", "Resultado propio de Leyva",
     "Reinternalizo operaciones tercerizadas. Un proceso de aclaraciones de hasta 30 dias paso a resolverse en el momento",
     "2020", "Autorreportado", "Es el precedente con cifra de la tesis de capacidad propia"),
    ("BM-03", "BBVA", "Cadencia",
     "Lanzamientos trimestrales en todos los canales desde 2015", "2015", "Autorreportado",
     "Es el piso de su expectativa, hace once anios"),
    ("BM-04", "BBVA", "Legado sin gran corte",
     "En 2020 el 28 por ciento de las transacciones corria fuera del legado, conectado por capa de servicios",
     "2020", "Autorreportado", "Ya convivio anios con 72 por ciento en legado. Sabe que el gran corte no es necesario"),
    ("BM-05", "BBVA", "Organizacion de software",
     "Area global de Software con mas de 16,000 personas internas y externas. 1,300 desarrolladores en el proyecto de globalizacion",
     "2022-01-14", "Prensa", "Dirigio algo mas del doble de Sistemas de Banamex"),
    ("BM-06", "BBVA", "Plataforma",
     "GloMo con mas de 300 interfaces globales reutilizadas por pais. Nacio en Mexico como pais ancla",
     "2022-01-14", "Prensa", "La consolidacion es lo que despues habilito todo lo demas"),
    ("BM-07", "BBVA", "Resultado de ciclo",
     "En la aplicacion movil global los plazos del ciclo de desarrollo de producto se redujeron a la mitad con equipos agiles",
     "2022", "Autorreportado", "Unico dato concreto de ciclo que publica BBVA"),
    ("BM-08", "BBVA", "Inteligencia artificial",
     "15,000 licencias de asistente de codigo, 70 por ciento de sus desarrolladores, mas de 100,000 repositorios en plataforma global unica",
     "2026-05-28", "Comunicado", "El beneficio vino de la consolidacion previa, no del asistente. Banamex no la tiene"),
    ("BM-09", "BBVA", "Talento",
     "Sumo unas 10,100 personas de tecnologia y datos en tres anios, con meta cercana a 20,000 profesionales tecnologicos. Mexico es su mayor plantilla con 47,745 empleados",
     "2025 a 2026", "Prensa", "Crecio y recompuso perfiles en vez de recortar"),
    ("BM-10", "Santander", "Core en nube",
     "Migro el core de Mexico a Gravity en noviembre de 2025, tercero despues de Chile y Espania. Meta de grandes geografias a fines de 2026",
     "2025-11", "Comunicado", "YA ESTA HECHO. Cuatro anios de ventaja de calendario sobre Banamex"),
    ("BM-11", "Santander", "Inversion",
     "Alrededor de 2,000 millones de dolares entre 2026 y 2028 en Mexico, principalmente plataformas tecnologicas y digitalizacion",
     "2026", "Declaracion del director general", "Por anio gasta mas del doble que Banamex"),
    ("BM-12", "Santander", "Tiempo de salida",
     "Afirma que el lanzamiento de nuevas funcionalidades paso de semanas a horas. Comunicados anteriores decian de dias a horas",
     "2025", "Autorreportado, cuestionado", "Citar junto con el analisis independiente que cuestiona la validacion"),
    ("BM-13", "Santander", "Costo humano de consolidar",
     "El 17 de septiembre de 2026 abrio conversaciones de recorte en sus filiales tecnologicas en Espania por duplicidades tras fusionarlas. Entre 10,750 y 13,000 personas en las dos sociedades",
     "2026-09-17", "Prensa", "Es el precedente real de la factura humana. Mejor nombrarlo nosotros"),
    ("BM-14", "Banorte", "Modelo de desarrollo",
     "90 por ciento de los desarrollos son agiles, con casi 3 millones de horas persona al anio, equivalentes a unas 1,300 personas programando a diario",
     "2021-04-29", "Declaracion, cinco anios de antiguedad", "Vara de densidad contra las 7,000 de Sistemas. No son categorias identicas, no presentarlas como si lo fueran"),
    ("BM-15", "Banorte", "Legado",
     "El core Altamira corre en mainframe como libro de registro. Sacaron las reglas de negocio a una capa de servicios con interfaces",
     "2021-04-29", "Declaracion", "Tercer caso local de modernizar sin apagar el core"),
    ("BM-16", "Banorte", "Velocidad real de un banco mexicano",
     "Las ventas por canales digitales pasaron de 7 por ciento en 2019 a 29 por ciento en 2026",
     "2026-07", "Reporte", "Siete anios. Es el contraargumento honesto a cualquier promesa de transformacion en nueve semanas"),
    ("BM-17", "Banorte", "Infraestructura",
     "Movio el centro de datos principal a Queretaro y modernizo el mainframe, con 50 por ciento menos tiempo de respuesta en transacciones digitales",
     "2026", "Autorreportado con socio", "Prueba que se mueve con inversion sostenida"),
]

# El Punto de Vista de casa sobre ciclo con IA.
POV = [
    ("PV-01", 3, "Diagnostico",
     "Handoffs, aprobaciones y esperas entre fases agregan de 10 a 20 dias a cada ciclo. Son invisibles en los reportes de velocidad de los sprints",
     "Respaldo de firma para el argumento central: el tiempo se va en esperas, no en tecleo",
     "Describe un ciclo generico de 7 fases, 8 a 12 semanas y 8 a 12 personas. NO es Banamex. Presentarlo como hipotesis a confirmar"),
    ("PV-02", 4, "Tesis",
     "El modelo tiene que cambiar, no solo la herramienta. El desarrollo acelerado por IA expone todos los cuellos de botella humanos",
     "Coincide con DORA: la IA amplifica el sistema de ingenieria que ya existe", None),
    ("PV-03", 5, "Marco",
     "Tres pilares simultaneos: herramientas y plataforma es el motor, ingenieria de contexto es la diferenciacion, modelo de operacion es el habilitador",
     "Ordena la conversacion y pone el modelo de operacion como condicion, no como consecuencia", None),
    ("PV-04", 5, "Modelo de operacion",
     "Pods de 3 a 5 personas contra 8 a 12 en la actualidad. Cambio de mentalidad de codificador a orquestador",
     "ES EL NUMERO DE LA PIRAMIDE que pide el director de operaciones: menos gente, mas tecnica", None),
    ("PV-05", 8, "Gobernanza por puntuacion",
     "Motor que puntua cada cambio en 8 dimensiones, complejidad, riesgo, regulatorio, urgencia, alineamiento, impacto, reversibilidad y confianza de la IA, y lo enruta a ejecucion automatica, revision acelerada con 2 horas de acuerdo de servicio, revision estandar o revision elevada",
     "Es el mecanismo para quitar gestores sin quitar controles. Unica via legal bajo Circular Unica",
     "La cifra de mas de 80 por ciento sin revision humana es del PoV, no medida en Banamex"),
    ("PV-06", 8, "Principio",
     "No todo cambio merece una reunion. Solo aquellos que exigen criterio",
     "Frase lista para la sala de un director de operaciones", None),
    ("PV-07", 9, "Desarrollo dirigido por especificacion",
     "Comprime el ciclo de 8 a 12 semanas a entre 3 y 5 dias, con un unico punto de decision humana antes de escribir codigo",
     "Es la palanca de mayor compresion declarada", "Cifras genericas"),
    ("PV-08", 10, "Ingenieria de arnes",
     "Cuatro elementos alrededor del agente: contexto, alcance, herramientas y lazo de validacion",
     "Define como se opera con agentes sin perder control",
     "Dosificar. Abrir con autonomia agentica ante quien rechazo una propuesta por abstracta es repetir el error"),
    ("PV-09", 12, "Primera accion recomendada",
     "Establece el baseline de las metricas actuales, incluido tiempo de espera por ciclo. Formaliza esos numeros antes de cualquier adopcion de herramientas de IA",
     "Convierte nuestra peticion de tres semanas en doctrina de firma, no en capricho", None),
    ("PV-10", 13, "Camino",
     "Fase 1 Pathfinder meses 1 a 3 con un equipo y un producto de punta a punta, linea base acordada, sin reorganizacion. Fase 2 Aceleracion meses 4 a 9 con 3 a 5 equipos. Fase 3 Multiplicacion desde el mes 10",
     "Es textualmente ladrillo a ladrillo, el formato que el interlocutor dijo que compra",
     "La meta de duplicar productividad en fase 1 NO se compromete sin linea base"),
    ("PV-11", 13, "Umbral honesto",
     "Tasa de aceptacion de IA de 35 por ciento o mas requerida en la fase 1",
     "Citarlo junto con el estudio METR, donde expertos aceptaron menos del 44 por ciento y aun asi tardaron mas. Es lo que nos distingue de quien promete milagros", None),
]

# Las seis bolsas donde se va el tiempo de salida, con la evidencia que tenemos de cada una.
BOLSAS = [
    ("BT-01", "Espera en la cola de priorizacion anual", "Gobierno de portafolio",
     "1,337 solicitudes contra 500 aprobadas. Reencuadrado: no es reproche a la priorizacion, es medicion de cola",
     "2025-10", "Levantamiento caduco, un anio"),
    ("BT-02", "Espera en aprobaciones y comites", "El rediseno de proceso ya en marcha",
     "Unos dos meses de aprobacion presupuestal para una iniciativa que los directivos ya habian decidido. Dato de primera mano. OJO: mide aprobacion del gasto, no aprobacion tecnica de una liberacion",
     "2026-07-13", "PROPIA Y RECIENTE, la mejor que tenemos"),
    ("BT-03", "Espera por ambientes y datos de prueba", "Origen",
     "Capital One reporta que construir un ambiente de desarrollo paso de tres meses a minutos al cerrar su migracion",
     "2020", "Externa, seis anios"),
    ("BT-04", "Pruebas de regresion ejecutadas a mano", "Por confirmar con el banco",
     "Sin evidencia. El levantamiento sugiere control documental manual",
     "2025-10", "DATO-REQUERIDO"),
    ("BT-05", "Ventana de cambio y periodos de congelamiento", "Operacion y riesgo",
     "Sin evidencia propia", None, "DATO-REQUERIDO"),
    ("BT-06", "Construccion del software", "Los equipos de desarrollo",
     "Es la unica bolsa que aceleran los asistentes de codigo y suele ser la mas pequenia de las seis",
     "2025", "Externa, DORA y METR"),
]

# Decision de alcance del 2026-10-28: que frentes quedan fuera de la narrativa.
ALCANCE = [
    ("AX-01", "ServiceNow", "EXCLUIDO",
     "Arrastrarlo ensucia la conversacion de ciclo de entrega. Su deal state no registra movimiento despues de julio de 2026",
     "Nada"),
    ("AX-02", "CI/CD Design", "EXCLUIDO",
     "Mismo criterio. Ademas es fuente de la contradiccion de herramientas CT-01 y CT-02, que no conviene abrir en la primera sesion",
     "La contradiccion de herramientas como riesgo interno, no como tema de sala"),
    ("AX-03", "Apigee X", "EXCLUIDO COMO VEHICULO",
     "No es parte de la narrativa de ciclo de entrega",
     "SI conservamos la evidencia: los dos meses de aprobacion presupuestal y el registro de que Leyva y Alvaro Ruiz deciden juntos y antes de que llegue el proveedor"),
    ("AX-04", "Backstage", "ADYACENCIA CONDICIONAL",
     "Un portal de desarrollador si es parte del ciclo, pero entra solo si el banco lo trae a la mesa",
     "La propuesta v3 y el alcance, por si el banco lo reactiva"),
    ("AX-05", "Origen, antes Laboratorio de Aceleracion", "DENTRO",
     "No es un vehiculo comercial por negociar sino una capacidad contratada por Anexo B",
     "Habilitador de la bolsa de ambientes y datos de prueba. OJO: vigente desde 2026-10-12 y con fecha dura el 2026-11-11, todavia no acredita su primer hito"),
]

# --------------------------------------------------------------------------
# Capa 13: roster de Digital Twins. Detalle en dt/cobertura-dt.md
# --------------------------------------------------------------------------

DTS = [
    ("DT-01", "dt-process-architect", "Arquitecto de Procesos de Entrega", "A", "Procesos",
     "Donde espera el trabajo entre una etapa y la siguiente, y quien lo tiene detenido",
     "", "", "M-DES-01",
     "Business Process & Journey; IT Operating Model; ITSM; Release Management",
     "Mapa de las nueve etapas con traspasos y esperas, reconciliando las dos versiones del documento de 2025",
     "SCAFFOLD, PUEDE AVANZAR HOY"),
    ("DT-02", "dt-spec-steward", "Custodio de la Especificacion", "A", "Artefactos",
     "Esta especificacion alcanza para que alguien que no estuvo en la conversacion construya lo correcto",
     "", "", "M-ADO-05",
     "Spec-Driven Development y sus cuatro especialistas; Enterprise Architecture; Intelligent Digital Brain",
     "Constitucion instanciada en forma verificable por maquina",
     "SCAFFOLD"),
    ("DT-03", "dt-platform-engineer", "Ingeniero de Plataforma de Entrega", "A", "Tecnologia",
     "Puede un cambio salir hoy sin que una persona toque el camino",
     "PAL-03,PAL-04,PAL-07", "", "M-DES-04,M-DES-05,M-CTL-02,M-ADO-02",
     "Software Engineering; Platform Engineering; Quality Engineering con TDM y TEM; Cybersecurity; Cloud AWS",
     "Cierre de las decisiones D-01 y D-02 de toolchain. Hasta entonces bloqueado por diseno",
     "SCAFFOLD, BLOQUEADO POR CT-01 Y CT-02"),
    ("DT-04", "dt-workforce-architect", "Arquitecto de la Plantilla de Ingenieria", "A", "Talento",
     "Que forma tiene el equipo que entrega asi, y en que se parece al que hay",
     "", "", "",
     "Change Enablement; SI & AD Effort Estimator; Program Effort Estimator",
     "Inventario de equipos de desarrollo por dominio, que es DATO-REQUERIDO del banco",
     "SCAFFOLD, SIN METRICA EN EL CATALOGO"),
    ("DT-05", "dt-governance-officer", "Oficial de Gobierno del Ciclo", "A", "Gobierno",
     "Quien decide esto, con que criterio, y por cuanto tiempo vale esa decision",
     "PAL-02", "", "M-DES-02",
     "IT Operating Model; ITSM GRC; Release Management; SIAM & Vendor Governance",
     "Mapeo de los veintiun controles a cuatro compuertas, validado con riesgo y cumplimiento",
     "SCAFFOLD"),
    ("DT-06", "dt-demand-router", "Enrutador de la Demanda", "B", "Procesos y Gobierno",
     "Por que ruta debe entrar este trabajo, y cuanto espera antes de que alguien lo toque",
     "PAL-01", "", "M-DES-03,M-ADO-03",
     "IT Operating Model; Value Led; Program Management",
     "Diseno de las etapas uno y dos, que hoy no existe en ningun documento",
     "SCAFFOLD"),
    ("DT-07", "dt-baseline-engineer", "Ingeniero de Linea Base y Telemetria", "B", "Gobierno y Tecnologia",
     "Cuanto tarda hoy un cambio en llegar a produccion, y con que dispersion",
     "PAL-00,PAL-06",
     "M-DES-01,M-DES-02,M-DES-03,M-DES-04,M-DES-05,M-CTL-01,M-CTL-02,M-CTL-03,M-CTL-04", "M-DES-01",
     "Observability; OpenTelemetry; Process Mining & Automation; Data & ML",
     "Acceso de lectura a la telemetria del repositorio y del pipeline. Brecha mas barata y precondicion de todas",
     "SCAFFOLD, BRECHA RAIZ"),
    ("DT-08", "dt-regulatory-assurance", "Responsable de Aseguramiento Regulatorio", "B", "Gobierno y Artefactos",
     "El auditor interno y el supervisor aceptan esta evidencia sin que nadie la transcriba",
     "", "", "M-CTL-01,M-CTL-04",
     "CNBV; Banxico; CONDUSEF; ITSM GRC; Cybersecurity; Industry Banking; DORA solo si aplica el grupo",
     "Respuesta del banco sobre que forma de evidencia acepta auditoria interna",
     "SCAFFOLD, RIESGO MAS CARO DEL PROGRAMA"),
    ("DT-09", "dt-engineering-method-lead", "Lider del Metodo de Ingenieria", "C", "Transversal",
     "En que etapa del metodo esta este equipo, y que le falta para la siguiente",
     "PAL-05", "", "M-CTL-03",
     "Agentic AI Engineering; Spec-Driven Development; MLOps & Model Lifecycle; Quality Engineering",
     "Criterio explicito de paso entre las tres etapas",
     "SCAFFOLD, PUEDE AVANZAR HOY"),
    ("DT-10", "dt-adoption-lead", "Lider de Adopcion", "C", "Talento y Procesos",
     "Por que un equipo usaria esto en vez del camino que ya conoce",
     "", "M-ADO-01,M-ADO-02,M-ADO-03,M-ADO-04,M-ADO-05", "M-ADO-01,M-ADO-04",
     "Change Enablement; Value Led",
     "Equipo piloto definido y su diagnostico de arquetipo",
     "SCAFFOLD"),
    ("DT-11", "dt-value-case-owner", "Dueno del Caso de Valor y el Tiempo de Salida", "C", "Transversal",
     "Que podemos comprometer hoy con la evidencia que tenemos, y que no",
     "", "", "",
     "Value Led; SI & AD Effort Estimator",
     "La linea base. Sin ella su respuesta a todo es la misma",
     "SCAFFOLD"),
    ("DT-12", "dt-evidence-auditor", "Auditor de Evidencia de la Propuesta", "C", "Sobre lo que escribimos",
     "Esta afirmacion tiene fuente, fecha y nivel de confianza declarados",
     "", "", "",
     "Ontology Validator; Semantic Architecture",
     "Nada externo. Puede empezar hoy por la tabla de frescura del estudio de innovacion",
     "SCAFFOLD, PUEDE AVANZAR HOY"),
]


def build():
    if DB.exists():
        DB.unlink()
    conn = sqlite3.connect(DB)
    conn.executescript(SCHEMA)

    conn.executemany("INSERT INTO narrativa_consejo VALUES (?,?,?,?,?,?)", NARRATIVA)
    conn.executemany("INSERT INTO partnership_areas VALUES (?,?,?,?,?)", PARTNERSHIP_AREAS)
    conn.executemany("INSERT INTO partnership_modelo VALUES (?,?,?,?)", PARTNERSHIP_MODELO)
    conn.executemany("INSERT INTO etapas VALUES (?,?,?,?,?,?,?,?,?)", ETAPAS)
    conn.executemany("INSERT INTO controles_asis VALUES (?,?,?,?,?,?)", CONTROLES)
    conn.executemany("INSERT INTO herramientas_asis VALUES (?,?,?,?,?,?)", HERR_ASIS)
    conn.executemany("INSERT INTO friccion VALUES (?,?,?,?,?,?,?)", FRICCION)
    conn.executemany("INSERT INTO diagnostico VALUES (?,?,?,?,?)", DIAGNOSTICO)
    conn.executemany("INSERT INTO metricas VALUES (?,?,?,?,?,?,?,?,?)", METRICAS)
    conn.executemany("INSERT INTO gates VALUES (?,?,?,?,?)", GATES)
    conn.executemany("INSERT INTO rutas VALUES (?,?,?,?,?)", RUTAS)
    conn.executemany("INSERT INTO fases VALUES (?,?,?,?,?,?)", FASES)
    conn.executemany("INSERT INTO entregables VALUES (?,?,?,?,?,?)", ENTREGABLES)
    conn.executemany("INSERT INTO herramientas VALUES (?,?,?,?,?,?)", HERRAMIENTAS)
    conn.executemany("INSERT INTO contradicciones VALUES (?,?,?,?,?,?,?,?,?,?)", CONTRADICCIONES)
    conn.executemany("INSERT INTO componentes VALUES (?,?,?,?,?,?,?,?,?,?)", COMPONENTES)
    conn.executemany("INSERT INTO iniciativas_vecinas VALUES (?,?,?,?,?,?,?,?)", INICIATIVAS_VECINAS)
    conn.executemany(
        "INSERT INTO dependencias (de_componente, a_componente, tipo, por_que) VALUES (?,?,?,?)",
        DEPENDENCIAS,
    )
    conn.executemany("INSERT INTO hitos VALUES (?,?,?,?,?,?,?)", HITOS)
    conn.executemany("INSERT INTO palancas VALUES (?,?,?,?,?,?,?,?,?,?)", PALANCAS)
    conn.executemany("INSERT INTO guardrails VALUES (?,?,?,?,?)", GUARDRAILS)
    conn.executemany("INSERT INTO escenarios VALUES (?,?,?,?,?,?)", ESCENARIOS)
    conn.executemany("INSERT INTO brechas VALUES (?,?,?,?,?,?)", BRECHAS)
    conn.executemany("INSERT INTO decisiones_abiertas VALUES (?,?,?,?,?,?)", DECISIONES)
    conn.executemany("INSERT INTO casos_uso_ia VALUES (?,?,?,?,?,?)", CASOS_IA)
    conn.executemany("INSERT INTO laminas VALUES (?,?,?,?,?,?,?)", LAMINAS)
    conn.executemany("INSERT INTO objeciones VALUES (?,?,?,?,?,?,?)", OBJECIONES)
    conn.executemany("INSERT INTO interno VALUES (?,?,?,?,?)", INTERNO)
    conn.executemany("INSERT INTO fuentes VALUES (?,?,?,?,?,?)", FUENTES)

    conn.executemany("INSERT INTO interlocutor VALUES (?,?,?,?,?)", INTERLOCUTOR)
    conn.executemany("INSERT INTO citas_interlocutor VALUES (?,?,?,?,?,?)", CITAS)
    conn.executemany("INSERT INTO benchmark VALUES (?,?,?,?,?,?,?)", BENCH)
    conn.executemany("INSERT INTO pov_casa VALUES (?,?,?,?,?,?)", POV)
    conn.executemany("INSERT INTO bolsas_tiempo VALUES (?,?,?,?,?,?)", BOLSAS)
    conn.executemany("INSERT INTO alcance_excluido VALUES (?,?,?,?,?)", ALCANCE)
    conn.executemany("INSERT INTO dts VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", DTS)

    brains = [(b[0], b[1], b[2], b[3], b[4], 1 if Path(b[2]).exists() else 0) for b in BRAINS]
    conn.executemany("INSERT INTO brains_federados VALUES (?,?,?,?,?,?)", brains)

    stats = {
        "narrativa_consejo": len(NARRATIVA),
        "partnership_areas": len(PARTNERSHIP_AREAS),
        "etapas": len(ETAPAS),
        "controles_asis": len(CONTROLES),
        "controles_que_no_sobreviven": sum(1 for c in CONTROLES if c[5].startswith("NO")),
        "controles_a_confirmar": sum(1 for c in CONTROLES if "CONFIRMAR" in c[5]),
        "herramientas_asis": len(HERR_ASIS),
        "herramientas_asis_riesgo_alto": sum(1 for h in HERR_ASIS if h[5].startswith("ALTO")),
        "friccion": len(FRICCION),
        "friccion_observada": sum(1 for f in FRICCION if f[6] == "OBSERVADA"),
        "friccion_hipotesis": sum(1 for f in FRICCION if f[6] == "HIPOTESIS"),
        "diagnostico": len(DIAGNOSTICO),
        "diagnostico_por_validar": sum(1 for d in DIAGNOSTICO if "VALIDAR" in (d[4] or "")),
        "metricas": len(METRICAS),
        "metricas_con_linea_base": sum(1 for m in METRICAS if m[6] is not None),
        "gates": len(GATES),
        "rutas": len(RUTAS),
        "fases": len(FASES),
        "entregables": len(ENTREGABLES),
        "entregables_de_alto_valor": sum(1 for e in ENTREGABLES if e[4].startswith("ALTO")),
        "entregables_que_son_documento": sum(1 for e in ENTREGABLES if e[4] == "DOCUMENTO"),
        "herramientas": len(HERRAMIENTAS),
        "herramientas_vigentes": sum(1 for h in HERRAMIENTAS if h[4] == "VIGENTE"),
        "herramientas_ilustrativas": sum(1 for h in HERRAMIENTAS if h[4] == "ILUSTRATIVA"),
        "contradicciones_abiertas": sum(1 for c in CONTRADICCIONES if c[9] == "ABIERTA"),
        "componentes": len(COMPONENTES),
        "iniciativas_vecinas": len(INICIATIVAS_VECINAS),
        "dependencias": len(DEPENDENCIAS),
        "hitos": len(HITOS),
        "palancas": len(PALANCAS),
        "guardrails": len(GUARDRAILS),
        "escenarios": len(ESCENARIOS),
        "brechas": len(BRECHAS),
        "brechas_dato_requerido": sum(1 for b in BRECHAS if b[5] == "DATO-REQUERIDO"),
        "decisiones_abiertas": len(DECISIONES),
        "objeciones_abiertas": sum(1 for o in OBJECIONES if o[6] == "ABIERTA"),
        "casos_uso_ia": len(CASOS_IA),
        "casos_uso_etapa_1": sum(1 for c in CASOS_IA if c[5] == "Etapa 1"),
        "laminas_revisadas": len(LAMINAS),
        "laminas_a_sustituir": sum(1 for l in LAMINAS if l[3] == "SUSTITUIR"),
        "interno_no_compartible": len(INTERNO),
        "fuentes": len(FUENTES),
        "interlocutor_hitos": len(INTERLOCUTOR),
        "citas_interlocutor": len(CITAS),
        "citas_vigentes": sum(1 for c in CITAS if c[5].startswith("VIGENTE")),
        "citas_a_confirmar": sum(1 for c in CITAS if c[5].startswith("A CONFIRMAR")),
        "benchmark_datos": len(BENCH),
        "benchmark_bancos": len({b[1] for b in BENCH}),
        "pov_casa_elementos": len(POV),
        "pov_con_cuidado": sum(1 for p in POV if p[5]),
        "bolsas_tiempo": len(BOLSAS),
        "bolsas_con_evidencia_propia": sum(1 for b in BOLSAS if b[5] and "PROPIA" in b[5]),
        "bolsas_dato_requerido": sum(1 for b in BOLSAS if b[5] == "DATO-REQUERIDO"),
        "frentes_excluidos": sum(1 for a in ALCANCE if a[2].startswith("EXCLUIDO")),
        "dts": len(DTS),
        "dts_que_pueden_avanzar_hoy": sum(1 for d in DTS if "PUEDE AVANZAR HOY" in d[11]),
        "dts_sin_palanca": sum(1 for d in DTS if not d[6]),
        "palancas_con_dueno": len({p for d in DTS for p in d[6].split(",") if p}),
        "brains_federados_disponibles": sum(b[5] for b in brains),
    }
    conn.executemany("INSERT INTO stats VALUES (?,?)", sorted(stats.items()))

    conn.commit()
    conn.close()

    print(f"sdlc-brain.db construido en {DB}")
    for k, v in sorted(stats.items()):
        print(f"  {k:34} {v}")
    for b in brains:
        estado = "disponible" if b[5] else "NO ENCONTRADO"
        print(f"  brain federado: {b[1]:32} {estado}")


if __name__ == "__main__":
    try:
        build()
    except Exception as exc:  # pragma: no cover
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
