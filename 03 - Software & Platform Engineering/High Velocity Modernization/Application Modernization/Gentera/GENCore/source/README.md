# GENCore / source

Directorio para exports directos del sistema SAP de Gentera.

## Qué va aquí

| Tipo de archivo | Origen | Cuándo se carga |
|---|---|---|
| Código ABAP por programa (`ZPROG.abap`) | SE38 → Download · o RFC_READ_REPORT bulk | Etapa 0 — después de inventario TADIR |
| Export DDIC Z-tables (`dd02l-ztables.csv`) | SE16 / SQVI sobre DD02L / DD03L | Etapa 0 |
| Export TADIR (`tadir-custom.csv`) | SE16 sobre TADIR filtrado Z/Y | Etapa 0 — primer entregable |
| Export TRDIR (`trdir-custom.csv`) | SE16 sobre TRDIR filtrado Z/Y | Etapa 0 |
| BADí implementations (`sxc-exit-active.csv`) | SE16 sobre SXC_EXIT | Etapa 0 |
| Transport history (`e070-e071.csv`) | SE16 sobre E070+E071 | Etapa 0 |
| ATC / SCI report (`atc-report.xml` o `.xlsx`) | ATC — adaptation check S/4HANA | Si disponible antes de Etapa 0 |
| SAP Readiness Check output | SAP Download Center / cliente | Si disponible |

## Estructura de carpetas observada (del primer export)

```
source/
├── CLASS/      ← clases ABAP (.abap)
├── PROG/       ← programas ejecutables (.abap)  [pendiente]
├── FUGR/       ← function groups (.abap)         [pendiente]
└── ...         ← otros tipos de objeto
```

## Namespace del cliente: `/CBB/` (Compartamos Banco)

**IMPORTANTE:** el código de Gentera NO usa prefijos Z/Y — usa namespace(s) registrado(s). El inventario TADIR debe filtrar por:
```abap
WHERE obj_name LIKE 'Z%' OR obj_name LIKE 'Y%'
   OR obj_name LIKE '/CBB/%'   -- namespace principal: Compartamos Banco
   OR obj_name LIKE '/CBCR/%'  -- segundo namespace detectado (confirmar propietario con Basis)
```

> **NOTA 2026-07-16:** el segundo namespace `/CBCR/` fue detectado en el primer archivo ABAP (`/CBCR/CM_ZVAL` referenciado como clase de mensaje). Puede ser un namespace de partner/add-on. Confirmar con el equipo Basis si es código propio de Gentera.

## Convención de nombres de archivo

`{NOMBRE-OBJETO}.abap` dentro de la subcarpeta del tipo de objeto.

Ejemplo: `source/CLASS/_CBB_CL_DB_TVARVC.abap` (nombre de clase con `/` reemplazado por `_` en el filesystem)

## Confidencialidad

El código ABAP de customizaciones Z es propiedad del cliente (Gentera). No subir a repositorios públicos. Confirmar acuerdo de confidencialidad antes de cargar código fuente.