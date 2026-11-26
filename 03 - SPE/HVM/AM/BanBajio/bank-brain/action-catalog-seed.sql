-- =============================================================================
-- action-catalog-seed.sql — El catálogo canónico de casos de uso agénticos
--
-- Cierra B38 y B39 con un solo artefacto, porque son dos preguntas sobre el
-- mismo objeto: B38 pregunta qué hace la capa agéntica, B39 con cuánta
-- autonomía. Mientras los casos de uso vivieron en prosa, B38 no tenía
-- artefacto verificable y su propia regla lo contradecía: dice que cada caso se
-- ancla a una sub-capacidad ITOM "y no a una lista suelta de ideas".
--
-- Estas filas son la lista exigible, no exhaustiva: un brain concreto añade las
-- suyas. Lo que no puede es ejecutar una acción que no esté aquí, porque
-- `evalua_accion` la niega por falta de autorización (Regla B39).
--
-- Dos cosas a rebindear al instanciar en un cliente:
--   1. `accountable_role` trae el nombre del rol canónico. En un brain real
--      apunta al id de `stakeholders` de esa organización.
--   2. `tool` trae la categoría de herramienta. En un brain real trae el
--      producto que el cliente opera (ServiceNow, Jira, Remedy).
--
-- El mapa de los casos de uso es el IT Operating Model (B23 y B38): por eso
-- `itom_domain` es obligatorio en la práctica aunque el DDL lo permita nulo.
-- =============================================================================

-- Technology Operations — hemisferio Run
INSERT OR REPLACE INTO action_catalog
 (id, tier, action_type, itom_domain, description, authorized_level,
  never_below_a3, accountable_role, tool, creates_only, authorized_by) VALUES
('ACT-rca-documentar', 'gold', 'Documentar un RCA', 'Technology Operations',
 'Redacta la causa raíz con su evidencia. Sale silver y el humano la promueve (B37).',
 'A1', 0, 'Problem Manager', 'ITSM', 1, 'Change Manager'),
('ACT-runbook-generar', 'gold', 'Generar o mantener un runbook', 'Technology Operations',
 'Escribe el runbook de diagnóstico a partir del call graph y los hallazgos.',
 'A1', 0, 'Problem Manager', 'repositorio de runbooks', 1, 'Change Manager'),
('ACT-ticket-abrir', 'gold', 'Abrir ticket en ITSM', 'Technology Operations',
 'Levanta un ticket con campos preestablecidos. Crea por la puerta de entrada de la herramienta, no modifica su registro (B38).',
 'A2', 0, 'Incident Manager', 'ITSM', 1, 'Change Manager'),
('ACT-capacidad-pronostico', 'gold', 'Pronóstico de capacidad', 'Technology Operations',
 'Proyecta el umbral y su ventana de riesgo a partir de las mediciones.',
 'A1', 0, 'Capacity and Availability Manager', 'observabilidad', 1, 'Change Manager'),
('ACT-runbook-ejecutar-prod', 'gold', 'Ejecutar runbook de remediación en producción',
 'Technology Operations',
 'Corre la remediación contra producción. Cambio en producción: nunca baja de A3, porque lo que haga durante la ventana queda hecho.',
 'A3', 1, 'Change Manager', 'automatización de operación', 0, 'Change Manager'),

-- Product / Service Delivery — hemisferio Change
('ACT-definicion-funcional', 'gold', 'Escribir definición funcional', 'Product / Service Delivery',
 'Redacta la definición a partir de reglas, procesos y regulación con su nivel de certeza.',
 'A1', 0, 'Product Owner', 'gestión de backlog', 1, 'Change Manager'),
('ACT-codigo-pr', 'gold', 'Generar código como pull request', 'Product / Service Delivery',
 'Entrega el cambio como PR. El merge es otra acción y es A3.',
 'A1', 0, 'Service Readiness Manager', 'repositorio', 1, 'Change Manager'),
('ACT-casos-prueba-alta', 'gold', 'Dar de alta casos de prueba', 'Product / Service Delivery',
 'Crea los casos en la herramienta de automatización. Identificados desde DISCOVER, no al final.',
 'A2', 0, 'Service Readiness Manager', 'automatización de pruebas', 1, 'Change Manager'),
('ACT-release-produccion', 'gold', 'Merge o release a producción', 'Product / Service Delivery',
 'Promueve a producción. Cambio en producción: nunca baja de A3, porque lo que opere con esa versión queda operado.',
 'A3', 1, 'Change Manager', 'CI/CD', 0, 'Change Manager'),

-- Information and Analytics — ambos hemisferios
('ACT-calidad-datos-reporte', 'gold', 'Reporte de calidad de datos', 'Information and Analytics',
 'Mide la calidad y el linaje contra el catálogo declarado.',
 'A1', 0, 'Information Architect', 'catálogo de datos', 1, 'Change Manager'),
('ACT-calidad-datos-adjuntar', 'gold', 'Adjuntar hallazgo de calidad al catálogo',
 'Information and Analytics',
 'Deja el hallazgo como evidencia en el registro. No sustituye el dato del catálogo (B38).',
 'A2', 0, 'Information Architect', 'catálogo de datos', 1, 'Change Manager'),
('ACT-catalogo-reclasificar', 'gold', 'Enriquecer o reclasificar el registro del catálogo',
 'Information and Analytics',
 'Modifica el registro que el catálogo custodia como verdad: por eso es A3 y lo ejecuta su dueño.',
 'A3', 0, 'Information Architect', 'catálogo de datos', 0, 'Change Manager'),

-- IT Management — ambos hemisferios
('ACT-brecha-regulatoria', 'gold', 'Reporte de brecha regulatoria', 'IT Management',
 'Traza la obligación hasta el código que la cumple, o hasta su ausencia.',
 'A1', 0, 'IT Risk Manager', 'GRC', 1, 'Change Manager'),
('ACT-notificar-risk-owner', 'gold', 'Notificar a risk owner', 'IT Management',
 'Avisa por el canal configurado. Notificar no es decidir.',
 'A2', 0, 'IT Risk Manager', 'canal de notificación', 1, 'Change Manager'),
('ACT-escalar-regulatorio', 'gold', 'Escalar hallazgo con consecuencia regulatoria', 'IT Management',
 'Escala formalmente. Consecuencia regulatoria directa ante el supervisor: nunca baja de A3.',
 'A3', 1, 'IT Risk Manager', 'GRC', 1, 'Change Manager'),

-- Customer and Ecosystem Engagement — ambos hemisferios
('ACT-demanda-a-requerimiento', 'gold', 'Traducir demanda de negocio a requerimiento',
 'Customer and Ecosystem Engagement',
 'Convierte la demanda en requerimiento con su impacto en KPIs.',
 'A1', 0, 'Demand Manager', 'gestión de demanda', 1, 'Change Manager'),

-- IT Strategy — hemisferio Change
('ACT-portafolio-7r', 'gold', 'Racionalizar portafolio con decisión 7R', 'IT Strategy',
 'Propone el destino 7R por aplicación contra la cadena de valor. La decisión es del arquitecto.',
 'A1', 0, 'Domain Architect', 'repositorio de arquitectura', 1, 'Change Manager'),

-- Los dos tipos de aprobacion permanente que no caen en un dominio ITOM operativo
('ACT-decommission', 'gold', 'Decommission de un sistema', 'Technology Operations',
 'Apagar la memoria de un sistema no se deshace: lo borrado no vuelve. Nunca baja de A3 (B39, B44).',
 'A3', 1, 'Change Manager', 'CMDB', 0, 'Change Manager'),
('ACT-config-seguridad', 'gold', 'Cambio de configuración de seguridad', 'IT Management',
 'Toca el perímetro o el control de acceso: nunca baja de A3.',
 'A3', 1, 'IT Risk Manager', 'gestión de seguridad', 0, 'Change Manager'),
('ACT-impacto-financiero', 'gold', 'Acción con impacto financiero directo al cliente',
 'IT Management',
 'Mueve dinero o cobra al cliente: nunca baja de A3, porque un cargo hecho ya le llegó.',
 'A3', 1, 'Business Support Owner', 'core de negocio', 0, 'Change Manager');
