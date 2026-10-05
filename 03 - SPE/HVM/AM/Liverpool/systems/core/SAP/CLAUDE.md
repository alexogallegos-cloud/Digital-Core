# SAP — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · Sub-offering HVM · Offering 03 S&PE
> Specialist activo: [Specialist - SAP ABAP](../../../Fase%200%20-%20Discover/Specialist%20-%20SAP%20ABAP/CLAUDE.md) `[STATE: PROPOSED]`

```
# togaf_type: core
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: enterprise-resource-planning
# bian_domains: []  (N/A — retail, no banking BIAN)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | SAP ECC o S/4HANA (confirmar versión exacta) |
| Lenguaje | ABAP |
| Rol | ERP principal — gestión comercial, finanzas, compras, inventario, HR |
| TOGAF Type | `core` (System of Record de alta criticidad) |
| Dominios retail | R01 Gestión Comercial · R04 Cadena Suministro · R07 Finanzas · R08 RRHH |
| Estado | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Lo Que Sabemos

| Aspecto | Conocido | Por Confirmar |
|---|---|---|
| Producto SAP | ECC 6.0 o S/4HANA | Confirmar versión exacta (SMSY/transaction) |
| Módulos activos | FI, CO, MM, WM, SD, HR (hipótesis retail) | Confirmar lista completa |
| Customizaciones Z/Y | Alta probabilidad de código Z en logística y comercial | Confirmar volumen en Etapa 0 |
| Integración con Oracle | Probable — para LiverpoolCard (finanzas) | Confirmar interfaz SAP-Oracle |
| Integración con Mainframe | Probable — para POS legacy o transacciones | Confirmar |
| Versión destino | S/4HANA (si aún en ECC) | Confirmar en primera reunión |

---

## Estructura del Sistema

```
systems/core/SAP/
├── source/
│   ├── code/     ← exports ABAP (transport requests, TADIR exports)
│   ├── docs/     ← docs técnicos SAP, BASIS documentation
│   └── ops/      ← config operativa, transport routes
├── digital-brain/
│   ├── brain.db           [PENDING]
│   ├── build-brain.py     [PENDING]
│   └── brain.py           [PENDING]
├── knowledge-base/
│   ├── rules/             [PENDING]
│   ├── vocab/             [PENDING]
│   └── ontology/          [PENDING]
├── generators/            [PENDING]
├── dt/                    [PENDING]
├── portal/                [PENDING]
└── CLAUDE.md              ← este archivo
```

---

## Próximos Pasos (Etapa 0)

1. Confirmar versión SAP (ECC 6.0 vs S/4HANA) con Basis de Liverpool.
2. Solicitar exportación TADIR (inventario de objetos Z/Y).
3. Activar Specialist - SAP ABAP para ejecutar Etapa 0.
4. Inventariar módulos activos, cantidad de programas Z, BADís y enhancement spots.

---

*Creado 2026-09-02 · Scaffold · SAP ERP Liverpool — core retail · análisis RE pendiente · SPE-AM-003*