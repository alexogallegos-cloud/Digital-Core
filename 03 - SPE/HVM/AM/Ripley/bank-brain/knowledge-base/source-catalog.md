# Catálogo de Fuentes — bank-brain Banco Ripley

> Artefacto de R0 del análisis de la situación. Dueño: `dt-source-steward`.
> Versión 1.0, 2026-10-27. Interim en Markdown mientras `source_catalog` no exista como tabla poblada (ADR-EB-014).

La Regla B31 obliga a que el brain declare su corpus fuente. Este archivo es esa declaración, y su valor principal hoy es mostrar lo corto que es.

---

## Fuentes disponibles

Ninguna está todavía descargada a `source/docs/`. Lo que sigue es el catálogo de lo que se puede obtener sin acceso al cliente, con el nivel que cada tipo de fuente sostiene al cargarse.

| # | Fuente | Qué aporta | Nivel | Estado |
|---|--------|-----------|-------|--------|
| 1 | Recopilación Actualizada de Normas de la CMF para bancos | Obligaciones regulatorias, requisitos de gestión de riesgo operacional, continuidad y ciberseguridad | **gold** | Por descargar |
| 2 | Compendio de Normas Financieras del Banco Central de Chile | Régimen de pagos, encaje, operaciones con el Banco Central | **gold** | Por descargar |
| 3 | Compendio de Normas Contables de la CMF para bancos | Plan de cuentas y reporte regulatorio | **gold** | Por descargar |
| 4 | Estados financieros de Banco Ripley publicados en la CMF | Tamaño del balance, composición de la cartera, provisiones, indicadores de capital | **gold** en lo financiero | Por descargar |
| 5 | Análisis razonado trimestral de Ripley Corp, segmento bancario | Evolución de colocaciones, ingresos y resultado del banco | **gold** en lo financiero | Por descargar. Existe al menos el del primer trimestre de 2026 |
| 6 | Memoria anual de Ripley Corp | Estructura, gobierno, iniciativas declaradas, compromisos | **silver** | Por descargar |
| 7 | Hechos esenciales de Banco Ripley ante la CMF | Eventos materiales, incluidos incidentes operativos relevantes y colocaciones de bonos | **gold** con fecha | Por descargar |
| 8 | Presentación corporativa de Ripley Corp a inversionistas | Lectura propia del negocio por parte del emisor | **silver** | Localizada en el sitio de relación con inversionistas |
| 9 | Informe de desempeño del sistema bancario de la CMF | Línea base del sistema para comparar al banco contra el mercado | **gold** | Por descargar. Hay edición a marzo de 2026 |
| 10 | Modelo Digital Bank 4.0 del asset | Qué debería poder hacer el banco | **silver** | Disponible en `00 - Enterprise Brain/knowledge-base/ontology/banca.md` |
| 11 | IT Operating Model v9.0 | Los 38 procesos contra los que se mide la cara de TI | **silver** | Disponible en `SME/Framework/IT Operating Model/` |

---

## Lo que falta, que es el landscape completo

Ninguna fuente pública describe la tecnología de un banco. Esto es lo que no tenemos y lo que cada ausencia bloquea.

| Lo que falta | A quién se le pide | Qué Digital Twin desbloquea |
|--------------|-------------------|----------------------------|
| Inventario de aplicaciones y mapa de arquitectura | Arquitectura empresarial del banco | `dt-asset-configuration-manager`, `dt-domain-architect` |
| Identificación del core bancario y del procesador de tarjetas, con versión | Arquitectura o CIO del banco | `dt-asset-configuration-manager` |
| Mapa de integraciones e interfaces | Arquitectura de integración del banco | `dt-asset-configuration-manager` |
| Contratos y dependencias de proveedores de tecnología | Compras y vendor management | `dt-supplier-relationship-manager` |
| Métricas de disponibilidad, incidentes y capacidad | Operaciones de TI | `dt-service-operations-lead` |
| Proceso de cambio y de release, con su compromiso de servicio | Gobierno de TI | `dt-change-manager` |
| Presupuesto de TI y su distribución | Finanzas de TI | `dt-demand-manager` |
| Gobierno de datos y catálogo de entidades críticas | Data governance | `dt-information-architect` |
| Código fuente de cualquier sistema | El banco, bajo acuerdo | Las cuatro etapas del gemelo cognitivo, por sistema |

---

## Huecos de conocimiento abiertos

Formato de la Regla B35: pregunta concreta, destinatario con nombre de rol y acción de resolución. Van a `knowledge_gaps` con `gap_type = 'source'` cuando la base exista.

| ID | Pregunta | Destinatario | Acción de resolución | Bloquea |
|----|----------|--------------|---------------------|---------|
| GAP-RIP-001 | ¿Cuál es la capa regulatoria chilena equivalente a `kb-banking-regulacion-mx.md`, construida contra la Recopilación Actualizada de Normas y el Compendio de Normas Financieras? | `SME/Industry/Industry Banking/` | El SME produce la capa Chile y el brain la declara en `ontology_bindings` | **R1 completa, en todos los dominios regulados** |
| GAP-RIP-002 | ¿Cuál es el catálogo de productos de la banca chilena, equivalente a la extensión de 89 productos de banca múltiple de México? | `SME/Industry/Industry Banking/` | Poblar `products` con la taxonomía local y su mapeo a Digital Bank 4.0 | `dt-product-owner` |
| GAP-RIP-003 | ¿Cuál es la fecha efectiva de entrada en vigor del Sistema de Finanzas Abiertas de la Ley Fintec 21.521, y cuál es la norma técnica que lo regula? | Verificación directa en la CMF y el Diario Oficial | Confirmar antes de que entre al brain como gold | `dt-it-risk-manager` |
| GAP-RIP-004 | ¿Cuál es la fecha de entrada en vigencia plena de la Ley 21.719 de protección de datos personales? | Verificación directa en el Diario Oficial | Ídem | `dt-information-architect` |
| GAP-RIP-005 | ¿Cuál es el equivalente chileno del Compendio de Normas Contables para el reporte regulatorio? | `SME/Industry/Industry Banking Accounting/` | Producir la capa contable local | `dt-enterprise-functions-owner` |
| GAP-RIP-006 | ¿Cómo opera el ecosistema de adquirencia de cuatro partes y el régimen de la Ley 20.009 sobre fraude en medios de pago? | `SME/Industry/Industry Payments/` | Producir la capa de pagos Chile | `dt-operations-owner`, `dt-channel-owner` |
| GAP-RIP-007 | ¿Cuál es el core bancario de Banco Ripley y en qué versión corre? | Arquitectura o CIO del banco | Abrir el sistema bajo `../systems/core/` en cuanto haya evidencia (Regla B8) | `dt-asset-configuration-manager` |
| GAP-RIP-008 | ¿Qué procesador de tarjetas usa el banco, propio o tercerizado? | Arquitectura o CIO del banco | Abrir el sistema bajo `../systems/processors/` | `dt-operations-owner` |

Los huecos 001 a 006 se pueden cerrar sin acceso al cliente, porque dependen de los SMEs y de normativa pública. Los huecos 007 y 008 no: requieren al banco. Esa división es la que ordena el plan de trabajo.

---

## Una advertencia sobre la taxonomía de riesgo de equivalencia

El asset clasifica el riesgo financiero de una regla en MONEY, DIV, ROUND, FX y UDI. La última es la unidad de inversión mexicana. Chile indexa en Unidad de Fomento, y la UF no es la UDI: difieren en cálculo, en periodicidad de publicación y en el tipo de contrato donde aparecen.

Esto no se arregla documentándolo. El detector de patrones que asigna el campo `riesgo` tiene UDI en su taxonomía y necesita UF, y ese es un cambio en el código del enriquecedor. Queda registrado aquí porque va a morder en cuanto se extraiga la primera regla de un sistema de este banco, no antes.

---

*Artefacto de R0. Dueño `dt-source-steward`. Accenture México, Digital Core.*
