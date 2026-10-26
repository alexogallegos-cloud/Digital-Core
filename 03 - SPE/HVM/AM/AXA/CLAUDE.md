# AXA México — Digital Brain
> Insurance P&C Commercial Lines · Run & Change

---

## QUÉ ES ESTE PROYECTO

Digital Brain para AXA México — ecosistema de conocimiento vivo del estado de los sistemas de
tecnología que soportan el negocio de Seguros de Daños (Property & Casualty) en Líneas Comerciales.

**Cliente**: AXA México (AXA Seguros S.A. de C.V.)
**Regulador**: Comisión Nacional de Seguros y Fianzas (CNSF)
**Marco regulatorio**: Circular Única de Seguros y Fianzas · Solvencia C · IFRS 17 · CONDUSEF
**Geografía**: México
**ETB de referencia**: Insurance Property & Casualty — Commercial Lines

---

## ESTRUCTURA DEL DIGITAL BRAIN

| Componente | Ubicación | Rol |
|------------|-----------|-----|
| Cerebro Federado | `axa-brain/` | Agrega todos los system-level brains |
| Sistemas — Run | `systems/{categoría}/{sistema}/` | Brain por sistema, estado actual (TOGAF baseline) |
| Proyectos — Change | `projects/{workstream}/` | Brain por workstream de transformación |
| Design Studio | `design-studio/` | Paleta AXA, logos, templates HTML |

---

## LANDSCAPE DE SISTEMAS

> **Fuente única de verdad**: `axa-brain/knowledge-base/landscape/landscape-axa-v2.json`.
> Se genera con `axa-brain/generators/build-landscape-v2.py` y carga `axa-brain.db`.
> No duplicar el inventario aquí: este archivo apunta al registro, no lo copia.

El registro v2.0 tiene **88 sistemas** con procedencia verificable por sistema, derivados de
tres fuentes: el PDF TOGAF (Fases A a H), el Excel de Competitive Discovery de Suscripción
Daños y la tabla de landscape de la v2.0 de este archivo.

| Categoría | Sistemas | Qué agrupa |
|-----------|----------|------------|
| `core` | 7 | Administración de pólizas y siniestros, un core distinto por línea |
| `processors` | 15 | Suscripción, reaseguro, modelación de riesgo y capa agéntica |
| `channels` | 19 | Portales B2C y B2B, apps móviles y canales internos |
| `integration` | 14 | Bus, gateway, perímetro, contenedores y pasarelas de pago |
| `data` | 11 | Golden record, Oracle por línea, plataforma de datos y BI |
| `compliance` | 22 | Regulatorio, finanzas, identidad, Azure y corporativos |

Estados del registro: 49 CONFIRMED, 24 PARTIAL, 4 SHADOW-IT, 4 DEPRECATED, 3 IN-MIGRATION,
2 SCAFFOLD, 1 PILOT, 1 DIVESTED.

Además del inventario, el brain tiene **36 componentes** (subelementos nombrados dentro de un
sistema, como los seis agentes de la capa agéntica o los cinco cores de Salud) y **53
dependencias cross-sistema**: 39 declaradas en el TOGAF con cita de página y 14 derivadas
empíricamente de la coocurrencia de sistemas en los pasos del Discovery.

### Consultar el landscape

```bash
cd axa-brain
python build-axa-brain.py --status          # resumen por categoría
python -c "import sqlite3;[print(r) for r in sqlite3.connect('axa-brain.db').execute(  \"select system_a,system_b,evidence from cross_dependencies where criticality='critical'\")]"
```

---

## CORRECCIONES DE LA v2.0

La sincronización del landscape contra las fuentes corrigió cuatro atribuciones que estaban
equivocadas en la v2.0 de este archivo:

| Punto | Decía la v2.0 | Dice la fuente |
|-------|---------------|----------------|
| Core de Autos | Visual Time gestiona pólizas de Autos | Visual Time es solo de Salud. Las pólizas, productos y tarifas de Autos viven en Oracle DB. Guidewire cubre únicamente siniestros (TOGAF p5, p7 y p11) |
| Core de Salud | Visual Time | Visual Time acompañado de GMM 2000, GMCol, GMI e ISES (TOGAF p5 y p7) |
| Siniestros de Daños | Por confirmar, sin sistema identificado | Se capturan en SED y General Daños sobre Oracle DB Daños. No hay core de siniestros dedicado (TOGAF p7) |
| Scope del brain | Excluía Salud y AXA Partners | El landscape multilínea cubre Vida, Salud, Daños y Autos, más los canales B2B. Solo AXA XL queda fuera |

### Hallazgos nuevos relevantes

- **Shadow IT con cuatro hojas de cálculo que operan como sistema**: HSD, P&L, Tarifa RC y
  Security List. El cálculo técnico de suscripción de Daños no vive en ningún motor.
- **Mitec y BBVA** como pasarela de pagos online de axa.mx y My AXA, externa y sin
  observabilidad unificada en Azure Sentinel.
- **SecureGPT** como pasarela corporativa de modelos, ya usada en el proceso de suscripción.
- **Datapower es hoy el bus principal**, no solo un gateway. Mulesoft es el bus canónico TO BE
  y ambos coexisten sin criterio formal de ruteo.
- **AXA IM** salió del perímetro: adquirida por BNP Paribas en diciembre de 2024, opera como
  BNPP AM México desde enero de 2026.
- La lámina de compliance del TOGAF cita **Solvencia II, RGPD y DGSFP**, que son el marco
  europeo y el regulador español. Para México aplica CNSF, Solvencia C, CONDUSEF y LFPDPPP.
  Probable plantilla heredada de otra entidad del Grupo AXA, a validar con el cliente.

### Pendientes de confirmación con el cliente

- Rol exacto de **Monitor**: herramienta de reporte a CNSF o solo monitoreo de cartera.
- Alcance de los sistemas nombrados sin detalle en el mapa TOGAF: SAM Suite, EB Portal,
  Billing & Collections, Tesorería, Centro de Notificaciones, Maestro Clientes, Maestro
  Distribuidores, Comisiones, Genesys, Salesforce y WSO2.
- Rol de **CIRCAM**, **InfoGral**, **Pegaso** y **Cotizador de Suscripción**, mencionados en el
  Discovery sin descripción suficiente.
- No se identificó sistema para cumplimiento CNSF ni para cálculo de reservas y solvencia.

---

## RUN vs CHANGE

- **Run** (`systems/`): sistemas en operación. Cada sistema tiene su propio `digital-brain/` con extracción de código fuente, reglas de negocio, vocabulario y Digital Twins temáticos. Son el estado AS-IS verificado.
- **Change** (`projects/`): workstreams de transformación activos. Cada proyecto tiene su propio brain y DTs de proyecto. Son iniciativas que modifican el estado de `systems/`.

---

## CADENA DE HERENCIA

```
Digital Core/CLAUDE.md
└── Digital Core/AGENTES-UNIVERSAL-RULES-DC.md
    └── 03 - SPE/HVM/AM/AXA/CLAUDE.md            ← este archivo
        └── axa-brain/CLAUDE.md                   ← cerebro federado
            └── systems/{cat}/{sys}/CLAUDE.md      ← brains por sistema
                └── projects/{ws}/CLAUDE.md        ← brains por proyecto
```

---

## DESIGN STUDIO

Paleta AXA, logos y templates HTML en `design-studio/`. Todos los portales HTML del proyecto
deben referenciar `design-studio/templates/axa-theme.css` para estilos consistentes.

Colores AXA: `#00008F` (azul primario) · `#FF1721` (rojo acento) · `#FFFFFF` · `#F5F5F5`

---

*Última actualización: 2026-10-19 · v2.1 · El landscape deja de vivir en este archivo y pasa al registro canónico `landscape-axa-v2.json`, cargado en el brain: 88 sistemas, 36 componentes y 53 dependencias cross-sistema con procedencia por fuente. Corrige la atribución de Visual Time, el core de Autos, los siniestros de Daños y el scope del brain.*