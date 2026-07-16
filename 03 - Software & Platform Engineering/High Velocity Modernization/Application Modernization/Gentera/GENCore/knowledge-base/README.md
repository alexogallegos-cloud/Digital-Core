# GENCore / knowledge-base

Knowledge base por módulo SAP — se popula al completar la Etapa 0 del Specialist SAP ABAP.

## Estructura esperada (post-Etapa 0)

Las subcarpetas se crean una vez que el inventario TADIR revela los módulos activos y la distribución de objetos Z:

```
knowledge-base/
├── FI-ContabilidadFinanciera/    ← Z-programs FI · Z-tables FI · BADIs FI activos
├── CO-Controlling/               ← Z-programs CO · Z-tables CO
├── SD-CreditoVentas/             ← Z-programs SD · ciclos de crédito · cobranza
├── MM-ComprasInventarios/        ← Z-programs MM
├── HR-RecursosHumanos/           ← Z-programs HCM · nómina · gestión promotores
├── BATCH-ProcesosNocturno/       ← Z-reports batch · jobs de cierre
├── INTERFACES-RFCExterno/        ← Z-FMs con DESTINATION · IDocs · BAPIs custom
└── REGULATORIO-CNBV/             ← Z-programs regulatorios CNBV · CONDUSEF
```

## Qué va en cada subcarpeta de módulo

- Lista de programas Z del módulo (del inventario TADIR/TRDIR)
- Lista de Z-tables del módulo (del inventario DD02L)
- BADís activos del módulo (de SXC_EXIT)
- Reglas de negocio extraídas (Etapa 3)
- Artefactos del Gemelo Cognitivo: vocabulario · almas · biografía por módulo

## Estado actual

Pendiente de Etapa 0 — directorio creado como placeholder.