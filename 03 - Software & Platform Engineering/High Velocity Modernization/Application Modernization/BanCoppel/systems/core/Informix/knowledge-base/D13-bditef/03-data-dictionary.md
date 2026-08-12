# D13 · Transferencias Electrónicas de Fondos (TEF) — Diccionario de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — DBA IBM Informix (tipos nativos, restricciones, índices)
- Data Architect (mapeo de tipos a PostgreSQL / Aurora)

> Columnas marcadas `[DATO-REQUERIDO]` provienen de inferencia del código. Requieren confirmación contra el DDL de producción con el DBA IBM Informix.
---

## Convenciones de tipos en IBM Informix IDS 14.10

| Tipo Informix | Equivalente PostgreSQL | Observación |
|---------------|----------------------|-------------|
| `char(n)` | `char(n)` o `varchar(n)` | Informix rellena con espacios; PostgreSQL no por defecto |
| `integer` | `integer` | Idéntico |
| `decimal(p,s)` | `numeric(p,s)` | Riesgo de redondeo — revisar `15-type-mapping.md` |
| `money` | `numeric(16,2)` | `money` de Informix incluye símbolo de moneda en algunos modos |
| `date` | `date` | Formato de entrada Informix: `%m/%d/%Y` — requiere conversión |
| `datetime` | `timestamp` | Precisión variable en Informix (YEAR TO SECOND, YEAR TO FRACTION) |
| `serial` | `serial` / `bigserial` | Auto-incremental |

---

## Parámetros de SPs clave — vocabulario verificado en código

### Parámetros de entrada comunes (recurrentes en múltiples SPs)

| Nombre del parámetro | Tipo | Significado verificado | Observación |
|---------------------|------|----------------------|-------------|
| `pempresa` | `char(3)` | Código de empresa BanCoppel | Clave de partición lógica del multiempresa |
| `pcuenta` / `pnumcuenta` | `char(20)` | Número de cuenta de cheques | 20 dígitos, alineado a derecha con ceros |
| `pimporte` | `decimal(16,2)` | Importe de la operación | En pesos MXN; `[DATO-REQUERIDO]` validar manejo de divisas |
| `pmoneda` | `char(2)` | Código de moneda | `MN` = Moneda Nacional; catálogo `[DATO-REQUERIDO]` |
| `pusuario` | `char(8)` | Identificador de usuario operador | Trazabilidad de auditoría |
| `pfecha_hoy` / `pfechaofi` | `date` | Fecha de operación / fecha oficial | Formato `MM/DD/YYYY` en entrada SPL |
| `pcvebanco` / `pbancodestino` | `char(3)` | Clave del banco destino CECOBAN | Catálogo CECOBAN 3 dígitos |
| `pnrocheque` | `integer` | Número de cheque | Entero; 0 cuando no aplica cheque físico |
| `pnomarch` | `char(30)` | Nombre de archivo de cámara | Convención de nombre CECOBAN |

---

### Códigos de retorno estándar del dominio

| Código (`char(5)`) | Significado | Contexto |
|-------------------|-------------|---------|
| `00000` | Operación exitosa | Todos los SPs |
| `00001` | Registro no encontrado | Consultas sin resultado |
| `00400` | Error de validación de datos de entrada | Validaciones de negocio |
| `09999` | Error interno no categorizado | Errores no esperados |
| `[DATO-REQUERIDO]` | Códigos de error específicos TEF | Requiere análisis con DBA |

---

### Variables internas clave de SPs de cargo/abono

| Variable | Tipo | Significado | SP origen |
|----------|------|-------------|-----------|
| `vcodret` | `char(5)` | Código de retorno local | `cargo_cta`, `abono_cta` |
| `vmsg` | `char(35)` | Mensaje descriptivo del resultado | `cargo_cta`, `abono_cta` |
| `vfecha` | `date` | Fecha calculada de operación | `cal_fecha_pre_fh` y derivados |
| `vsdodisp` | `money` | Saldo disponible en la cuenta | `cargo_cta` |
| `vmotdevol` | `char(2)` | Motivo de devolución CECOBAN | `cargo_cta` — valor `"09"` = cuenta bloqueada |
| `vstatchq` | `char(1)` | Estado del cheque en cámara | `"N"` = no pagado, `"M"` = pagado por cámara |
| `vfolio` | `char(16)` | Folio único de la operación | `cargo_cta` L548: `pusuario || hora || substr(pcuenta)` |
| `v_esferiado` | `char(1)` | Indicador de día feriado | `cal_fecha_pre_fh`, `cal_habil_ant` |
| `v_habil_ant` | `date` | Fecha hábil anterior calculada | `cal_habil_ant` |

---

### Vocabulario de dominio — tokens verificados en código

| Token | Categoría | Significado verificado | Evidencia |
|-------|-----------|----------------------|-----------|
| `tef` | DOMINIO | Transferencia Electrónica de Fondos | Nombre de dominio, múltiples SPs |
| `cce` | SISTEMA | Cámara de Compensación Electrónica | Tablas `cce_*`, SPs `sp_cce_*` |
| `cecoban` | SISTEMA EXTERNO | Centro de Compensación Bancaria (interoperabilidad interbancaria) | Contexto de negocio CNBV |
| `abono` | ENTIDAD | Acreditamiento en cuenta (crédito) | `abono_cta`, `abono_ref` |
| `cargo` | ENTIDAD | Débito en cuenta | `cargo_cta`, `cargo_ref` |
| `dev` / `devo` | ACCIÓN | Devolución de cheque o transferencia | `cons_dev_coppel`, `sp_consdevext_tef` |
| `habil` | ATRIBUTO | Día hábil bancario operativo | `cal_habil_ant`, `sp_validadiahabiltef` |
| `feriado` | ENTIDAD | Día feriado (catálogo `si_feriado`) | `cal_fecha_pre_fh` |
| `presentador` | ROL | BanCoppel como presentador en cámara | `sp_tef_presentador_g/r` |
| `receptor` | ROL | BanCoppel como receptor en cámara | `sp_tef_receptor_g/r` |
| `folio` | IDENTIFICADOR | Número único de operación TEF | `cargo_cta`, `tef_operaciones` |
| `sicam` | SISTEMA | Sistema de cámara interno | `sp_tef_act_rep_sicam` |
| `cam` | ABREV | Cámara de compensación | Múltiples SPs y tablas |
| `pba` | MODIF | Variante PBA (canal o producto específico) | `cons_dev_coppel_pba`, `sp_obtienecheques…_pba` |
| `web` | MODIF | Canal web | `cal_fecha_pre_fh_web`, `cons_dev_suc_web` |
| `sif` | SISTEMA | Sistema de información financiera | `sp_tef_rep_lib_sif`, `sp_obtbines_sif` |
| `list_negra` | CONCEPTO | Lista de cuentas restringidas para TEF | `sp_tef_generareplistnegra` |

---

## Mapeo de tipos críticos a target PostgreSQL

| Campo | Tipo Informix | Tipo target | Riesgo | Acción requerida |
|-------|--------------|-------------|--------|-----------------|
| `pimporte` | `decimal(16,2)` | `numeric(16,2)` | MEDIO | Verificar manejo de ROUND vs TRUNC en fórmulas de IVA |
| `vsdodisp` | `money` | `numeric(16,2)` | ALTO | `money` Informix puede incluir símbolo; requiere limpieza |
| `vfolio` | `char(16)` | `varchar(16)` | BAJO | Revisar padding de espacios |
| `pfecha` | `date` | `date` | MEDIO | Formato entrada `%m/%d/%Y` → requiere conversión explícita |
| `pnumcuenta` | `char(20)` | `varchar(20)` | BAJO | Validar trailing spaces en comparaciones |

> Ver detalle completo en `15-type-mapping.md`.

---

## `[SME-PENDING]`

- [ ] DDL completo del esquema `bditef` (columnas, tipos, constraints, índices).
- [ ] Catálogo de códigos de moneda (`pmoneda`) válidos.
- [ ] Catálogo de bancos CECOBAN (`pcvebanco`) vigente.
- [ ] Catálogo de motivos de devolución CECOBAN (`vmotdevol`).
- [ ] Significado exacto de `?_pre_fh` y `?ret` — tokens sin grounding en el vocab.

---
*Generado por análisis de parámetros y variables en sp-specs-bditef.md*
