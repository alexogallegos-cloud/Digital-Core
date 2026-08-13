# Informix · Lista de Validación SME — Vocabulario

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Para:** sesión HITL con Domain Expert / DBA de BanCoppel · **Generado:** 2026-07-03

Términos del vocabulario **sin evidencia dura** (no confirmados por código, SME ni fuente de negocio), ordenados por **impacto** = frecuencia con que aparecen (cuántos SPs se interpretan mal si la hipótesis es incorrecta).

**Cómo usar:** por cada fila, marca la casilla `¿Correcto?` (☑ si la hipótesis es correcta, ✗ si no) y escribe el significado correcto en la última columna. Al terminar, cada confirmación se agrega a `sp_vocab.py` y el análisis se regenera — subiendo la **certeza dura** del vocabulario (hoy 25%).

Prioridad: **Tier 1** = mayor riesgo (los di por buenos sin verificar, y son muy usados) · **Tier 2** = ambiguos que requieren decisión · **Tier 3** = fragmentos frecuentes aún sin significado.

---

## 🔴 Tier 1 · Convención de alto impacto — *verificar que mi interpretación es correcta*

40 términos · impacto acumulado 2,952 apariciones. Objetos de negocio (entidades/modificadores) que asigné por convención; **suenan bien pero nadie los ha confirmado**. Un error aquí se propaga a muchos SPs. *(Los verbos y prefijos genéricos — `sp`, `cons`, `valida`, `genera` — se consideran inequívocos y no se listan.)*

| # | Término | Hipótesis actual | Cat | Impacto | ¿Correcto? | Significado correcto (si ✗) |
|--:|---|---|---|--:|:--:|---|
| 1 | `totales` | totales | modif | 244 | ☐ | |
| 2 | `reporte` | reporte | entidad | 196 | ☐ | |
| 3 | `cte` | cliente | entidad | 180 | ☐ | |
| 4 | `detalle` | detalle | entidad | 157 | ☐ | |
| 5 | `cat` | catálogo | entidad | 123 | ☐ | |
| 6 | `id` | identificador (de) | entidad | 105 | ☐ | |
| 7 | `cred` | crédito | entidad | 101 | ☐ | |
| 8 | `cta` | cuenta | entidad | 99 | ☐ | |
| 9 | `catalogo` | catálogo | entidad | 97 | ☐ | |
| 10 | `ctas` | cuentas | entidad | 91 | ☐ | |
| 11 | `pago` | pago | entidad | 87 | ☐ | |
| 12 | `web` | canal web | modif | 87 | ☐ | |
| 13 | `caja` | caja / ventanilla | entidad | 84 | ☐ | |
| 14 | `esp` | especial | modif | 77 | ☐ | |
| 15 | `info` | información | entidad | 77 | ☐ | |
| 16 | `tef` | TEF — transferencia electrónica de fondos | entidad | 76 | ☐ | |
| 17 | `comp` | complemento | modif | 72 | ☐ | |
| 18 | `tdc` | tarjeta de crédito (TDC) | entidad | 64 | ☐ | |
| 19 | `datos` | datos | entidad | 54 | ☐ | |
| 20 | `masivo` | masivo | modif | 54 | ☐ | |
| 21 | `por` | por (criterio) | modif | 54 | ☐ | |
| 22 | `pos` | punto de venta (POS) | entidad | 54 | ☐ | |
| 23 | `cheques` | cheques | entidad | 53 | ☐ | |
| 24 | `bitacora` | bitácora | entidad | 50 | ☐ | |
| 25 | `cargo` | cargo / débito | entidad | 48 | ☐ | |
| 26 | `reportes` | reportes | entidad | 47 | ☐ | |
| 27 | `ctes` | clientes | entidad | 46 | ☐ | |
| 28 | `productos` | productos | entidad | 46 | ☐ | |
| 29 | `atms` | cajeros automáticos (ATM) | entidad | 44 | ☐ | |
| 30 | `param` | parámetro | entidad | 44 | ☐ | |
| 31 | `total` | total | modif | 43 | ☐ | |
| 32 | `sms` | SMS | entidad | 39 | ☐ | |
| 33 | `mov` | movimiento | entidad | 38 | ☐ | |
| 34 | `linea` | línea (de crédito) | entidad | 34 | ☐ | |
| 35 | `moral` | persona moral | modif | 32 | ☐ | |
| 36 | `movimientos` | movimientos | entidad | 32 | ☐ | |
| 37 | `xml` | XML | entidad | 32 | ☐ | |
| 38 | `deb` | débito | modif | 31 | ☐ | |
| 39 | `banco` | banco | entidad | 30 | ☐ | |
| 40 | `buro` | Buró de Crédito | entidad | 30 | ☐ | |

---

## 🟠 Tier 2 · Ambiguos / inferidos — *decidir entre lecturas posibles*

40 términos · impacto 2,076. Tienen ≥2 significados plausibles o son abreviaturas sin expandir.

| # | Término | Hipótesis actual | Cat | Impacto | ¿Correcto? | Significado correcto (si ✗) |
|--:|---|---|---|--:|:--:|---|
| 1 | `ope` | operación | acción | 190 | ☐ | |
| 2 | `gen` | genera / general | acción | 128 | ☐ | |
| 3 | `sac` | sistema saldos/cuentas (bdisac) o sufijo | ambiguo | 122 | ☐ | |
| 4 | `con` | consulta | acción | 111 | ☐ | |
| 5 | `cre` | crédito | entidad | 107 | ☐ | |
| 6 | `cap` | ¿captura / captación / capacidad? — por confirmar con el SME | ambiguo | 102 | ☐ | |
| 7 | `ofi` | oficio | entidad | 76 | ☐ | |
| 8 | `cam` | cámara / captura contable | prefijo | 71 | ☐ | |
| 9 | `cp` | código postal | entidad | 69 | ☐ | |
| 10 | `fal` | faltantes / documentación de expediente | prefijo | 69 | ☐ | |
| 11 | `sol` | solicitud | entidad | 68 | ☐ | |
| 12 | `ccl` | CCL — por confirmar con el SME | ambiguo | 67 | ☐ | |
| 13 | `pba` | ¿prueba/PBA? — por confirmar con el SME | ambiguo | 64 | ☐ | |
| 14 | `aum` | aumento | modif | 53 | ☐ | |
| 15 | `arch` | archivo | entidad | 50 | ☐ | |
| 16 | `suc` | sucursal | modif | 46 | ☐ | |
| 17 | `dic` | ¿diciembre / dictamen? — por confirmar con el SME | ambiguo | 45 | ☐ | |
| 18 | `cac` | familia crédito (CAC) | prefijo | 44 | ☐ | |
| 19 | `trans` | ¿transacción / transferencia? — por confirmar con el SME | ambiguo | 44 | ☐ | |
| 20 | `cnsif` | consulta SIF (bus de integración) | prefijo | 42 | ☐ | |
| 21 | `edo` | estado | entidad | 41 | ☐ | |
| 22 | `bts` | beneficiarios (BTS) | entidad | 37 | ☐ | |
| 23 | `soe` | prefijo SOE (bdibei) — por confirmar con el SME | ambiguo | 37 | ☐ | |
| 24 | `prod` | producto | entidad | 33 | ☐ | |
| 25 | `admin` | ¿administración / administrador? — por confirmar con el SME | ambiguo | 32 | ☐ | |
| 26 | `int` | interés | entidad | 32 | ☐ | |
| 27 | `cjunk` | variable temporal (ruido de código, se ignora) | ambiguo | 28 | ☐ | |
| 28 | `desc` | ¿descripción / descuento / descarga? — por confirmar con el SME | ambiguo | 26 | ☐ | |
| 29 | `nom` | nómina | entidad | 25 | ☐ | |
| 30 | `emp` | ¿empresa / empleado? — por confirmar con el SME | ambiguo | 23 | ☐ | |
| 31 | `imp` | ¿importe / impuesto / impresión? — por confirmar con el SME | ambiguo | 22 | ☐ | |
| 32 | `upgrade` | actualiza producto (upgrade) | acción | 22 | ☐ | |
| 33 | `inf` | información | entidad | 21 | ☐ | |
| 34 | `adn` | ADN — por confirmar con el SME | ambiguo | 19 | ☐ | |
| 35 | `oro` | ¿producto Oro / metal? — por confirmar con el SME | ambiguo | 19 | ☐ | |
| 36 | `ris` | ¿riesgo? — por confirmar con el SME | ambiguo | 19 | ☐ | |
| 37 | `cnt` | ¿contador / cuenta contable? — por confirmar con el SME | ambiguo | 18 | ☐ | |
| 38 | `obt` | obtiene | acción | 18 | ☐ | |
| 39 | `ref` | referencia | ambiguo | 18 | ☐ | |
| 40 | `seg` | ¿seguro / seguridad / segundo? — por confirmar con el SME | ambiguo | 18 | ☐ | |

---

## ⚪ Tier 3 · Candidatos sin significado — *nombrar el término*

35 fragmentos frecuentes (filtrado el ruido de segmentación) · impacto 920. Aparecen mucho pero aún no tienen entrada en el vocabulario.

| # | Término | Hipótesis actual | Cat | Impacto | ¿Correcto? | Significado correcto (si ✗) |
|--:|---|---|---|--:|:--:|---|
| 1 | `rep` | (sin significado asignado) | — | 128 | ☐ | |
| 2 | `ini` | (sin significado asignado) | — | 112 | ☐ | |
| 3 | `rem` | (sin significado asignado) | — | 71 | ☐ | |
| 4 | `bio` | (sin significado asignado) | — | 35 | ☐ | |
| 5 | `reg` | (sin significado asignado) | — | 35 | ☐ | |
| 6 | `pro` | (sin significado asignado) | — | 30 | ☐ | |
| 7 | `rev` | (sin significado asignado) | — | 29 | ☐ | |
| 8 | `limite` | (sin significado asignado) | — | 26 | ☐ | |
| 9 | `corte` | (sin significado asignado) | — | 24 | ☐ | |
| 10 | `area` | (sin significado asignado) | — | 24 | ☐ | |
| 11 | `corr` | (sin significado asignado) | — | 21 | ☐ | |
| 12 | `prov` | (sin significado asignado) | — | 21 | ☐ | |
| 13 | `dos` | (sin significado asignado) | — | 20 | ☐ | |
| 14 | `det` | (sin significado asignado) | — | 19 | ☐ | |
| 15 | `tot` | (sin significado asignado) | — | 19 | ☐ | |
| 16 | `situacion` | (sin significado asignado) | — | 19 | ☐ | |
| 17 | `padre` | (sin significado asignado) | — | 18 | ☐ | |
| 18 | `crd` | (sin significado asignado) | — | 17 | ☐ | |
| 19 | `can` | (sin significado asignado) | — | 17 | ☐ | |
| 20 | `skip` | (sin significado asignado) | — | 17 | ☐ | |
| 21 | `funcion` | (sin significado asignado) | — | 17 | ☐ | |
| 22 | `itos` | (sin significado asignado) | — | 15 | ☐ | |
| 23 | `com` | (sin significado asignado) | — | 15 | ☐ | |
| 24 | `colonia` | (sin significado asignado) | — | 15 | ☐ | |
| 25 | `fin` | (sin significado asignado) | — | 15 | ☐ | |
| 26 | `ital` | (sin significado asignado) | — | 15 | ☐ | |
| 27 | `usejecuta` | (sin significado asignado) | — | 15 | ☐ | |
| 28 | `rchivo` | (sin significado asignado) | — | 14 | ☐ | |
| 29 | `sat` | (sin significado asignado) | — | 14 | ☐ | |
| 30 | `insert` | (sin significado asignado) | — | 14 | ☐ | |
| 31 | `mento` | (sin significado asignado) | — | 14 | ☐ | |
| 32 | `dir` | (sin significado asignado) | — | 14 | ☐ | |
| 33 | `user_insert` | (sin significado asignado) | — | 14 | ☐ | |
| 34 | `address` | (sin significado asignado) | — | 14 | ☐ | |
| 35 | `entrada` | (sin significado asignado) | — | 13 | ☐ | |

---

## Cómo se cierra el ciclo

```
1. SME marca ✗ y escribe el significado correcto en este documento
2. Editar sp_vocab.py:  "termino": ("CATEGORIA", "significado confirmado — SME", "conf"),
3. python extract-journeys.py && python mine-source.py && python build-catalog.py
   && python build-vocab-inventory.py && python build-vocab-report.py
4. La certeza dura sube y estos términos pasan a evidencia 🧑 SME
```

**Impacto potencial:** validar estos 115 términos cubre 5,948 apariciones — el grueso del vocabulario de alto uso. Prioriza Tier 1 (máximo riesgo/beneficio).

*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: vocabulary-inventory.json + build-sme-worklist.py*
