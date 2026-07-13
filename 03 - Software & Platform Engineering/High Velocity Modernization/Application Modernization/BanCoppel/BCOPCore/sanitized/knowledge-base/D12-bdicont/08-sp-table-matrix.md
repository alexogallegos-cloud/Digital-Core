# D12 · Contabilidad — Matriz SP × Tabla (READ / WRITE)

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert LegacyCore (validación funcional)
- Cybersecurity (riesgos PII, regulación CNBV/LFPDPPP)
- QA Lead — Equivalencia Funcional (estrategia de pruebas) ← NUEVO
- Cloud Architect AWS Banking (arquitectura target) ← NUEVO
> [SME-PENDING] = requiere sesión de validación antes de Etapa 2.
---

## Importancia para Etapa 2 (Data RE)

Esta matriz determina:
1. **Ownership de datos**: qué SP (y por ende qué microservicio target) es dueño de cada tabla
2. **Tablas compartidas**: múltiples SPs escriben → punto de contención → candidatas a patrón CQRS
3. **Prioridad CDC**: tablas con más escritores priorizan la configuración de Debezium / DMS
4. **Scope de migración**: tablas que solo leen SPs de código muerto pueden excluirse del scope

> 🔄 = SP usa `EXECUTE PROCEDURE` con variable — puede leer/escribir tablas adicionales no detectadas estáticamente.

## Resumen de tablas propias de `bdicont`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `co_fechas` | Transaccional | 22 | 0 | 🟢 Solo lectura |
| `co_sdodias` | Transaccional | 16 | 5 | 🟠 5 SPs escriben |
| `co_detpol` | Transaccional | 14 | 5 | 🟠 5 SPs escriben |
| `co_balanza` | Transaccional | 4 | 9 | 🔴 9 SPs escriben |
| `co_cierre_cif` | Transaccional | 10 | 3 | 🟠 3 SPs escriben |
| `tmp_historico` | Histórico / Archivado | 6 | 6 | 🔴 6 SPs escriben |
| `STATISTICS` | Transaccional | 0 | 12 | 🔴 12 SPs escriben |
| `co_diasaux` | Transaccional | 6 | 5 | 🟠 5 SPs escriben |
| `co_param` | Catálogo / Config | 10 | 0 | 🟢 Solo lectura |
| `co_poliza` | Transaccional | 5 | 4 | 🟠 4 SPs escriben |
| `co_histsdodias` | Histórico / Archivado | 5 | 3 | 🟠 3 SPs escriben |
| `co_movdia` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `co_contproc` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `tmp_parametros` | Catálogo / Config | 0 | 6 | 🔴 6 SPs escriben |
| `co_tabmovdia` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `co_balprev` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `co_histdiasaux` | Histórico / Archivado | 2 | 3 | 🟠 3 SPs escriben |
| `co_movtos` | Transaccional | 4 | 0 | 🟢 Solo lectura |
| `co_libmadet` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `co_sdomes` | Transaccional | 3 | 1 | 🟠 1 SPs escriben |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA LegacyCore.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `act_encab_ant` | 59 | 0 | `co_detpol` | `co_poliza` |
| `act_hist` | 109 | 0 | `bdicont:systables`  ⚠️ext, `co_cierre_cif`, `co_fechas`, `co_mensual` | `STATISTICS`, `co_historico_tmp` |
| `act_histsdos` | 223 | 0 | `bdicont:systables`  ⚠️ext, `co_cierre_cif`, `co_diasaux`, `co_fechas`, `co_sdodias` | `STATISTICS`, `co_histdiasaux`, `co_histsdodias_tmp` |
| `act_mens` | 68 | 0 | `co_cierre_cif`, `co_diario`, `co_fechas` | `co_historico`, `co_mensual` |
| `act_sdodias` | 110 | 0 | `co_cierre_cif`, `co_diario`, `co_diasaux`, `co_sdodias` | `co_diasaux`, `co_sdodias` |
| `act_sdom` | 176 | 0 | `co_cierre_cif`, `co_fechas`, `co_sdodias` | `STATISTICS`, `co_sdomes` |
| `act_sdomux` | 178 | 0 | `co_cierre_cif`, `co_diasaux`, `co_fechas` | `STATISTICS`, `co_mesaux` |
| `actualizarpasesuc` | 45 | 0 | — | `bdicont:co_clv_pasesuc`  ⚠️ext |
| `acumdias` | 11 | 0 | — | — |
| `auditapase_ant` | 349 | 0 | `bdicont:co_ctrlpoliza`  ⚠️ext, `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_regional`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `co_auditpase`, `co_auxiliar` | `bdicont:co_auxiliar`  ⚠️ext, `bdicont:co_ctrlpoliza`  ⚠️ext, `co_auditpase`, `co_detpol` |
| `auxiliares2` | 516 | 0 | `bdicont:co_diasaux`  ⚠️ext, `bdicont:co_fechas`  ⚠️ext, `bdicont:co_histdiasaux`  ⚠️ext, `bdicont:co_historico`  ⚠️ext, `bdicont:co_mensual`  ⚠️ext, `bdinteg:si_catalog`  ⚠️ext | `bdicont:co_diasaux`  ⚠️ext, `bdicont:co_histdiasaux`  ⚠️ext, `co_histdiasaux` |
| `auxiliares3` | 516 | 0 | `bdicont:co_diasaux`  ⚠️ext, `bdicont:co_fechas`  ⚠️ext, `bdicont:co_histdiasaux`  ⚠️ext, `bdicont:co_historico`  ⚠️ext, `bdicont:co_mensual`  ⚠️ext, `bdinteg:si_catalog`  ⚠️ext | `bdicont:co_diasaux`  ⚠️ext, `bdicont:co_histdiasaux`  ⚠️ext, `co_histdiasaux` |
| `cancela_resultados` | 988 | 0 | `bdicont:co_ctrlpoliza`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `co_cance`, `co_contproc` | `bdicont:co_ctrlpoliza`  ⚠️ext, `bdicont:co_poliza`  ⚠️ext, `co_cance`, `co_contproc` |
| `carga_diaria` | 256 | 0 | `bdicont:co_poliza`  ⚠️ext, `bdinteg:si_catalog`  ⚠️ext, `co_contproc`, `co_detpol`, `co_mapeo_cte`, `co_mapeo_divisas` | `bdicont:co_poliza`  ⚠️ext, `co_contproc`, `co_detpol`, `co_movdia` |
| `cierre` | 444 | 0 | `bdinteg:si_catalog`  ⚠️ext, `co_cierre_cif`, `co_diario`, `co_fechas`, `co_param`, `co_sdodias` | `STATISTICS`, `co_canret`, `co_diasaux`, `co_sdodias` |
| `cierre_diario` | 127 | 0 | — | — |
| `cierre_mensual` | 209 | 0 | — | — |
| `contcie2` | 169 | 0 | `co_canret`, `co_cierre_cif`, `co_fechas`, `co_param` | `co_canret`, `co_cierre_cif` |
| `corestsucur` | 144 | 0 | `bdicont:co_cta_ccdest`  ⚠️ext, `bdicont:co_cta_ccorig`  ⚠️ext | `bdicont:co_cta_ccdest`  ⚠️ext, `bdicont:co_cta_ccorig`  ⚠️ext |
| `corrige_saldos` | 239 | 0 | `bdicont:co_fechas`  ⚠️ext, `bdicont:co_histsdodias`  ⚠️ext, `bdinteg:si_catalog`  ⚠️ext | `bdicont:co_histsdodias`  ⚠️ext, `co_histsdodias` |
| `ctas_nuevas` | 161 | 0 | `co_detpol`, `co_fechas`, `co_sdodias` | `co_balanza` |
| `ctas_nuevascc` | 160 | 0 | `bdinteg:si_plazas`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `co_detpol`, `co_fechas`, `co_sdodias` | `co_balanza` |
| `ctasgiradas` | 337 | 0 | `co_diasaux`, `co_fechas`, `co_histdiasaux`, `co_histsdodias`, `co_sdodias` | `co_ctasob` |
| `cuentacontable` | 87 | 0 | `bdinteg:si_catalog`  ⚠️ext | — |
| `del_co_historico` | 28 | 0 | `bdicont:co_historico`  ⚠️ext | `bdicont:co_historico`  ⚠️ext |
| `del_co_histsdodias` | 25 | 0 | `bdicont:co_histsdodias`  ⚠️ext | `bdicont:co_histsdodias`  ⚠️ext |
| `depura_ctas` | 42 | 0 | `co_cierre_cif`, `co_diasaux`, `co_fechas`, `co_sdodias` | `co_diasaux`, `co_sdodias` |
| `detmauxcon` | 231 | 0 | `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_divisas`  ⚠️ext, `co_auxiliar`, `co_detmadet`, `co_detmaenca`, `co_fechas` | `co_detmadet`, `co_detmaenca` |
| `detmauxsuc` | 235 | 0 | `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_divisas`  ⚠️ext, `co_auxiliar`, `co_detmadet`, `co_detmaenca`, `co_fechas` | `co_detmadet`, `co_detmaenca` |
| `diasmes` | 17 | 0 | — | — |
| `difmes` | 11 | 0 | — | — |
| `factor_nat` | 10 | 0 | — | — |
| `filtrasuc` | 9 | 0 | — | — |
| `gen_balprev` | 291 | 0 | `bdinteg:si_catalog`  ⚠️ext, `co_detpol`, `co_fechas`, `co_sdodias`, `systables` | `co_balanza` |
| `gen_balprevcc` | 313 | 0 | `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_plazas`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `co_detpol`, `co_fechas`, `co_sdodias` | `co_balanza` |
| `gen_balprevreg` | 317 | 0 | `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_plazas`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `co_detpol`, `co_fechas`, `co_sdodias` | `co_balanza` |
| `gen_encab` | 41 | 0 | `co_detpol` | `co_poliza` |
| `gen_repbal` | 497 | 0 | `bdinteg:si_catalog`  ⚠️ext, `co_balanza`, `co_fechas`, `co_histsdodias`, `co_sdodias`, `co_sdomes` | `co_balanza` |
| `gen_repbalccpba` | 504 | 0 | `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_plazas`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `co_balanza`, `co_fechas`, `co_histsdodias` | `co_balanza` |
| `gen_repbalreg` | 441 | 0 | `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_plazas`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `co_balanza`, `co_fechas`, `co_histsdodias` | `co_balanza` |
| `gen_totalbalanza` | 1169 | 0 | `balan`, `bdinteg:si_catalog`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdirepaut:sp_preciocontable`  ⚠️ext, `co_balanza`, `co_param` | `co_balanza` |
| `gen_totaliz` | 1132 | 0 | `co_balprev`, `co_param` | `co_balprev` |
| `gen_totalizvar` | 859 | 0 | `co_balprev`, `co_paramcta` | `co_balprev` |
| `genpoliza` | 103 | 0 | `bdicont:co_mensual`  ⚠️ext, `co_ctrlpoliza`, `pol_comp`, `tmp_natori_c`, `tmp_natori_d` | `bdicont:co_detpol`  ⚠️ext, `co_ctrlpoliza`, `pol_comp`, `tmp_natori_c` |
| `grabarpasesuc` | 55 | 0 | `bdicont:co_clv_pasesuc`  ⚠️ext | `bdicont:co_clv_pasesuc`  ⚠️ext |
| `inicializa` | 379 | 0 | `bdicont:co_fechas`  ⚠️ext, `bdicont:co_histdiasaux`  ⚠️ext, `bdicont:co_historico`  ⚠️ext, `bdicont:co_histsdodias`  ⚠️ext, `bdicont:co_param`  ⚠️ext, `bdicont:co_sdomes`  ⚠️ext | `bdicont:co_contproc_inicializa`  ⚠️ext, `bdicont:co_histdiasaux`  ⚠️ext, `bdicont:co_historico`  ⚠️ext, `bdicont:co_histsdodias`  ⚠️ext |
| `ins_act_hist` | 61 | 0 | `co_historico_tmp` | `co_historico` |
| `ins_act_histsdos` | 58 | 0 | `co_histsdodias_tmp` | `co_histsdodias` |
| `inserta_estatus_cierre` | 26 | 0 | `bdinteg:si_ejecut`  ⚠️ext | `co_cierre_cif` |
| `inserta_estatus_cierre_notran` | 24 | 0 | `bdinteg:si_ejecut`  ⚠️ext | `co_cierre_cif` |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`STATISTICS`**: escrita por `libromayor_diariosaux`, `libromayor_historicos`, `act_sdom`, `act_histsdos`, `cierre` ... y 7 más
- **`co_balanza`**: escrita por `ctas_nuevascc`, `ctas_nuevas`, `gen_balprevreg`, `gen_totalbalanza`, `gen_balprevcc` ... y 4 más
- **`bdicont:tmp_saldos`**: escrita por `libromayaux_historicos`, `libromayor_historicos`, `libromayor_diarios`, `libromayaux_diarios`, `libromayor_historicosaux` ... y 1 más
- **`tmp_historico`**: escrita por `libromayaux_historicos`, `libromayor_historicos`, `libromayor_diarios`, `libromayaux_diarios`, `libromayor_historicosaux` ... y 1 más
- **`bdicont:tmp_saldosfinales`**: escrita por `libromayaux_historicos`, `libromayor_historicos`, `libromayor_diarios`, `libromayaux_diarios`, `libromayor_historicosaux` ... y 1 más

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `STATISTICS` | `libromayor_diariosaux`, `libromayor_historicos`, `act_sdom` | 🔴 PRIMERA |
| `co_balanza` | `ctas_nuevascc`, `ctas_nuevas`, `gen_balprevreg` | 🔴 PRIMERA |
| `tmp_historico` | `libromayaux_historicos`, `libromayor_historicos`, `libromayor_diarios` | 🔴 PRIMERA |
| `tmp_parametros` | `libromayaux_historicos`, `libromayor_historicos`, `libromayor_diarios` | 🔴 PRIMERA |
| `co_diasaux` | `depura_ctas`, `cierre`, `inicializa` | 🔴 PRIMERA |
| `co_sdodias` | `depura_ctas`, `cierre`, `inicializa` | 🔴 PRIMERA |
| `co_detpol` | `carga_diaria`, `auditapase_ant`, `pase_movtos` | 🔴 PRIMERA |
| `co_poliza` | `gen_encab`, `act_encab_ant`, `pase_movtos` | 🟠 SEGUNDA |

## Tablas externas accedidas (cross-DB)

- `bdicont:` (R+W) — desde `libromayaux_historicos`, `libromayor_historicos`, `libromayor_diarios`
- `bdicont:co_auxiliar` (R+W) — desde `auditapase_ant`
- `bdicont:co_clv_pasesuc` (R+W) — desde `grabarpasesuc`, `actualizarpasesuc`
- `bdicont:co_contproc_inicializa` (R+W) — desde `inicializa`
- `bdicont:co_cta_ccdest` (R+W) — desde `corestsucur`
- `bdicont:co_cta_ccorig` (R+W) — desde `corestsucur`
- `bdicont:co_ctrlpoliza` (R+W) — desde `auditapase_ant`, `cancela_resultados`
- `bdicont:co_detpol` (R+W) — desde `genpoliza`, `pasecont`
- `bdinteg:` (R) — desde `libromayaux_diarios`, `libromayaux_historicos`
- `bdinteg:si_catalog` (R) — desde `detmauxsuc`, `gen_balprevreg`, `gen_balprevcc`
- `bdinteg:si_divisas` (R) — desde `detmauxsuc`, `detmauxcon`, `libmaycon`
- `bdinteg:si_ejecut` (R) — desde `inserta_estatus_cierre_notran`, `pasecont`, `inserta_estatus_cierre`
- `bdinteg:si_histdiv` (R) — desde `llenareport`
- `bdinteg:si_param` (R) — desde `pasecont`
- `bdinteg:si_plazas` (R) — desde `ctas_nuevascc`, `gen_balprevreg`, `pasecont`
- `bdinteg:si_regional` (R) — desde `auditapase_ant`
- `bdirepaut:sp_preciocontable` (R) — desde `gen_totalbalanza`
- `sysmaster:systabnames` (R) — desde `libromayaux_old`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicont_*.sql (análisis estático de 70 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*
