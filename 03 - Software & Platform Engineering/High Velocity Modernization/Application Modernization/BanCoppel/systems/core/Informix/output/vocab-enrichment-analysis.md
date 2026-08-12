# Análisis de Enriquecimiento del Vocabulario BCOPCore

> **Proyecto**: SPE-AM-001 — BanCoppel Application Modernization  
> **Fecha**: 2026-08-04  
> **Vocabulario analizado**: 706 tokens (543 conf · 150 inf · 13 gap)

---

## Resumen ejecutivo

| Dimensión | Total |
|-----------|------:|
| Términos con potencial upgrade inf→conf | **80** |
| Términos inf que permanecen con evidencia moderada | 58 |
| Términos ambiguos que requieren validación SME | 2 |
| Términos candidatos a eliminar (0 evidencia) | 23 |
| Pares abreviación-forma larga detectados | 154 |
| Pares sinónimos detectados | 10 |
| Pares con overlap semántico | 635 |
| Términos sin scope asignado | 127 |
| Tokens frecuentes faltantes (freq > 20) | 2 |
| Tokens faltantes secundarios (freq 10-20) | 20 |
| Definiciones con oportunidad de enriquecimiento | 20 |

---

## Sección 1 — Candidatos a upgrade (inf/gap → conf)

Los siguientes **80** términos tienen alta evidencia en el knowledge base (SPs, reglas,
journeys o almas) y pueden elevarse de `inf`/`gap` a `conf` en la próxima revisión del SME.

### UPGRADE_CANDIDATE

| Token | Cat | Est | SPs | Reglas | Journeys | Alma | Dominios | Significado actual |
|-------|-----|-----|----:|-------:|---------:|------|----------|--------------------|
| `ope` | ACCION | inf | 189 | 8 | 0 |  | D01, D03, D10, D12… | operación |
| `sw` | ENTIDAD | gap | 100 | 0 | 0 |  | D01, D02 | sw — SoftWare/Switch (subsistema sp_sw_ro_* — bdicnweb) |
| `ro` | ENTIDAD | gap | 99 | 0 | 0 |  | D01 | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) |
| `ofi` | ENTIDAD | inf | 98 | 6 | 0 |  | D01, D02, D03, D08… | oficio |
| `gen` | ACCION | inf | 97 | 8 | 2 |  | D02, D03, D04, D06… | genera / general |
| `cg` | ENTIDAD | gap | 85 | 3 | 0 |  | D01, D10 | cg — Canal/Cuenta General (subsistema sp_cg_* — bdicnweb) |
| `cjunk` | AMBIGUO | gap | 61 | 34 | 9 | ★ | D01, D02, D03, D06 | variable temporal (ruido de código, se ignora) |
| `cac` | PREFIJO | inf | 57 | 13 | 1 |  | D01, D02, D03, D06 | familia crédito (CAC) |
| `rem` | ENTIDAD | inf | 55 | 14 | 0 |  | D01, D05 | remesa (forma corta) |
| `sd` | ENTIDAD | inf | 49 | 7 | 0 |  | D03, D04 | sd — saldo disponible (abreviación en código de crédito) |
| `obt` | ACCION | inf | 47 | 4 | 0 |  | D02, D03, D04, D08… | obtiene |
| `con` | ACCION | inf | 46 | 3 | 4 |  | D01, D03, D04, D05… | consulta |
| `cp` | ENTIDAD | inf | 45 | 0 | 0 |  | D01, D02, D05, D06… | código postal |
| `sol` | ENTIDAD | inf | 43 | 0 | 0 |  | D02, D03, D06, D16 | solicitud |
| `aut` | ACCION | inf | 41 | 0 | 0 |  | D01, D02, D03, D05… | autorización |
| `fc` | ENTIDAD | gap | 36 | 3 | 0 |  | D01 | fc — Fuentes Combinadas (subsistema sp_fc_*; biométricos — bdicnweb) |
| `cc` | ENTIDAD | inf | 35 | 0 | 0 |  | D01, D04 | cc — cuenta corriente (sp_*_cc_* — bdicnweb) |
| `cre` | ENTIDAD | inf | 35 | 0 | 0 |  | D01, D03, D07 | crédito |
| `os` | ENTIDAD | inf | 35 | 3 | 1 |  | D02, D03, D06 | OS — Originación de Solicitudes / subsistema de ofertas (sp_os_*, sp_c |
| `iccat` | ENTIDAD | inf | 34 | 3 | 2 |  | D02, D03, D16 | ICCAT — canal de atención al cliente en BPI; gestiona solicitudes de e |
| `ss` | ENTIDAD | gap | 32 | 0 | 0 |  | D01, D02, D03, D06… | ss — subsistema / canal de monitoreo (abreviación — envia_monitorsol_* |
| `bym` | ENTIDAD | inf | 31 | 0 | 6 |  | D01, D02, D10 | Billetes y Monedas (efectivo en sucursal — evidencia: 'piezas' + 'deno |
| `crd` | ENTIDAD | inf | 31 | 6 | 0 |  | D02, D03, D07, D11 | crédito (abreviación) |
| `sps` | PREFIJO | inf | 31 | 0 | 7 |  | D02, D08, D14 | sps — prefijo alternativo de SP en bdibei (posiblemente 'stored proced |
| `ref` | AMBIGUO | inf | 30 | 21 | 5 | ★ | D01, D02, D03, D04… | referencia |
| `ins` | ACCION | inf | 29 | 0 | 0 |  | D02, D03, D04, D06… | insertar |
| `aud` | ENTIDAD | inf | 28 | 0 | 0 |  | D01, D02, D03, D07 | auditoría |
| `corrige` | ACCION | inf | 27 | 5 | 0 |  | D03, D04, D06, D12… | corrige — acción de corrección de datos (bdicred:sp_corrige_*) |
| `prod` | ENTIDAD | inf | 27 | 66 | 13 |  | D01, D02, D03, D04… | producto |
| `dinya` | ENTIDAD | inf | 26 | 24 | 0 |  | D01, D05 | DINYA — sistema/plataforma de remesas domésticas en sucursal; retorna  |
| `domi` | ENTIDAD | inf | 25 | 16 | 0 |  | D02, D05, D08, D13 | domiciliación |
| `suc` | MODIF | inf | 24 | 2 | 0 |  | D01, D02, D03, D04… | sucursal |
| `upgrade` | ACCION | inf | 24 | 0 | 0 |  | D01, D02, D03 | actualiza producto (upgrade) |
| `his` | MODIF | inf | 23 | 2 | 0 |  | D02, D03, D04, D07… | histórico |
| `exp` | MODIF | inf | 22 | 4 | 1 |  | D01, D02, D03, D04… | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_exp: gener |
| `reg` | ACCION | inf | 22 | 0 | 0 |  | D02, D03, D04, D11… | registro |
| `arch` | ENTIDAD | inf | 20 | 43 | 7 |  | D03, D04, D05, D11… | archivo |
| `auto` | MODIF | inf | 20 | 7 | 2 |  | D03, D04, D16 | automático (proceso automático / batch — sp_*_auto) |
| `mib` | ENTIDAD | inf | 20 | 0 | 0 |  | D02, D03, D04, D06… | MIB — módulo/canal de integración para cheques y tarjeta (cargo_ref_mi |
| `sdos` | ENTIDAD | inf | 20 | 0 | 0 |  | D03, D04, D11, D12 | saldos (abreviación) |
| `sif` | ENTIDAD | inf | 19 | 0 | 1 |  | D02, D03, D04, D13… | SIF — canal de estado de cuenta (aclaraciones_edocta_sif, detalle_edoc |
| `cal` | ENTIDAD | inf | 18 | 0 | 0 |  | D02, D03, D04, D06… | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_tradicion — op |
| `chq` | ENTIDAD | inf | 18 | 0 | 0 |  | D01, D02, D04 | cheque (abreviación — bdicheq) |
| `cnt` | ENTIDAD | inf | 18 | 0 | 0 |  | D01, D06 | CNT — módulo de convenios y control de descuentos de nómina de emplead |
| `arr` | ENTIDAD | inf | 17 | 1 | 0 |  | D03, D04 | ARR — producto de ahorro/inversión recurrente (CLABE, interés acumulad |
| `cpl` | ENTIDAD | inf | 17 | 0 | 0 |  | D02, D04, D05, D06 | CPL — segmento o producto de cliente (sp_dictamina_ctes_cpl, sp_afore_ |
| `ftc` | ENTIDAD | inf | 17 | 0 | 0 |  | D15 | FTC — módulo de configuración de transferencia de archivos (SFTP/FTP I |
| `int` | ENTIDAD | inf | 17 | 41 | 0 |  | D03, D04, D05, D06 | interés |
| `synmotor` | ENTIDAD | inf | 17 | 0 | 0 |  | D16 | SynMotor — motor de procesamiento de Syndein (empresa externa fintech) |
| `det` | ENTIDAD | inf | 16 | 0 | 0 |  | D03, D04, D12, D13… | detalle |
| `mueve` | ACCION | inf | 16 | 0 | 0 |  | D03, D07 | mueve / traslada (verbo complemento de mover) |
| `proac` | ENTIDAD | inf | 16 | 3 | 0 |  | D04 | PROAC — producto de cuenta de ahorro con inscripción y ciclo anual (sp |
| `respalda` | ACCION | inf | 16 | 0 | 0 |  | D02, D03, D04, D06… | respalda / garantiza — aval o garantía de crédito (respalda_creditocrd |
| `rev` | ACCION | inf | 16 | 0 | 0 |  | D02, D03, D04, D05… | reversión (abreviación de reversa/reverso) |
| `adm` | ACCION | inf | 15 | 0 | 0 |  | D01, D02 | administración/administrar (abreviación de admin) |
| `dicta` | ENTIDAD | inf | 15 | 6 | 4 |  | D02 | dicta — dictamen / subsistema de dictaminación (sp_dicta_* — bdinteg f |
| `borra` | ACCION | inf | 14 | 0 | 0 |  | D01, D02, D03, D04… | borra / elimina registros (borramovs_movhis, borramovscfd*) |
| `calif` | ENTIDAD | inf | 14 | 29 | 8 |  | D03 | calificación |
| `cam` | PREFIJO | inf | 14 | 5 | 2 |  | D04, D12, D13 | cámara / captura contable |
| `credisoluciones` | ENTIDAD | inf | 14 | 0 | 0 |  | D03 | CrediSoluciones — producto/segmento de crédito BanCoppel (sp_carga_cte |
| `ics` | ENTIDAD | inf | 14 | 2 | 0 |  | D03 | ICS — sistema de cuotas/mensualidades de crédito (sp_ics_cuotas, sp_ic |
| `movs` | ENTIDAD | inf | 14 | 0 | 0 |  | D04, D07, D15, D16 | movimientos (abreviación) |
| `tels` | ENTIDAD | inf | 14 | 0 | 0 |  | D02, D13 | teléfonos (plural) |
| `upd` | ACCION | inf | 14 | 0 | 0 |  | D02, D04, D07, D08… | actualiza (update) |
| `ccl` | ENTIDAD | inf | 13 | 24 | 0 |  | D01 | módulo de Cédulas de Captación e inversión — pagaré, ISR, saldos diari |
| `chi` | ENTIDAD | inf | 13 | 0 | 0 |  | D03, D09 | CHI — formato/protocolo de consulta al Buró de Crédito (bdiburo/bdicre |
| `nom` | ENTIDAD | inf | 13 | 3 | 2 |  | D03, D04, D06, D12… | nómina |
| `bex` | ENTIDAD | inf | 12 | 8 | 2 |  | D02, D03, D04, D08 | BEX — canal o plataforma de Banca Por Internet (bdibpi); gestiona sesi |
| `dv` | ENTIDAD | inf | 12 | 0 | 0 |  | D05 | dv — divisa (abreviación — bdisac) |
| `edo` | ENTIDAD | inf | 12 | 0 | 0 |  | D01, D03, D04, D10 | estado |
| `indicador` | ENTIDAD | inf | 12 | 3 | 0 |  | D03, D04 | indicador — marcador de estado o condición (sp_ambientar_indicador_*,  |
| `tar` | ENTIDAD | inf | 12 | 0 | 0 |  | D03, D04, D16 | Tarjeta (abreviación — bdicheq/bdicred: cons_cta_o_tar, mover_his_tar, |
| `clon` | ENTIDAD | inf | 11 | 0 | 0 |  | D03, D14, D15, D16 | [polisemia] Clon de SP (réplica funcional para variante de entorno o c |
| `cnr` | ENTIDAD | inf | 11 | 19 | 0 |  | D03, D11 | CNR — tipo o formato de consulta al Buró de Crédito para personas físi |
| `dep` | ENTIDAD | inf | 11 | 0 | 0 |  | D03, D04, D10, D16 | depósito |
| `generar` | ACCION | inf | 11 | 2 | 6 |  | D02, D03, D04, D09… | generar (infinitivo — sp_generarbalanza*) |
| `bccc` | ENTIDAD | inf | 10 | 0 | 0 |  | D01 | BCCC — formato o protocolo de consulta al Buró de Crédito (bdiburo:sp_ |
| `evc` | ENTIDAD | inf | 10 | 0 | 0 |  | D01 | EVC — Evaluación/Cartera a Quebrantar (write-off de cartera vencida; s |
| `mon` | PREFIJO | inf | 8 | 3 | 1 |  | D03, D10 | monitor / módulo |
| `inv` | ENTIDAD | inf | 5 | 3 | 1 |  | D04, D07, D09 | inv — inversión (abreviación — calsdoinvcrec, cierrechqinvcrec) |

### STAYS_INF — Evidencia moderada (sin cambio recomendado aún)

| Token | Cat | SPs | Reglas | Journeys | Significado actual |
|-------|-----|----:|-------:|---------:|--------------------|
| `msj` | ENTIDAD | 9 | 0 | 0 | mensaje — abreviación corta de mnsj (sp_validacion_msj) |
| `respaldo` | ENTIDAD | 9 | 0 | 0 | respaldo / garantía de crédito (aval) |
| `concreing` | ENTIDAD | 8 | 0 | 0 | Conciliación de Reingresos — proceso de conciliación de tarjetas reing |
| `gdf` | ENTIDAD | 8 | 0 | 0 | gdf — código geográfico / Gobierno CDMX (abreviación — bdisac) |
| `stat06` | ENTIDAD | 8 | 0 | 0 | Stat06 — tipo/código de archivo de carga en procesamiento de tarjetas  |
| `sv` | ENTIDAD | 8 | 0 | 0 | sv — supervisión/servicio (abreviación — bdiaclaracion) |
| `ejecuta` | ACCION | 6 | 2 | 0 | ejecuta (verbo — proceso / operación) |
| `sbc` | ENTIDAD | 6 | 0 | 0 | saldo básico de cuenta (SBC) |
| `cnc` | ENTIDAD | 5 | 0 | 0 | CNC — sistema de configuración de planes fijos de Tarjetas Coppel (pla |
| `reevaluacion` | ACCION | 5 | 0 | 0 | reevaluación de crédito |
| `parametrico` | ENTIDAD | 4 | 0 | 0 | paramétrico — parametrización de modelos (envío paramétrico) |
| `tbl` | ENTIDAD | 4 | 0 | 0 | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) |
| `venc` | ENTIDAD | 4 | 15 | 1 | vencimiento |
| `aumento` | MODIF | 3 | 0 | 0 | aumento |
| `estado` | ENTIDAD | 3 | 14 | 1 | estado (entidad federativa / estatus) |
| `mayor` | ENTIDAD | 3 | 0 | 0 | mayor contable |
| `monitoreo` | ENTIDAD | 3 | 0 | 0 | monitoreo — proceso de vigilancia/seguimiento operativo |
| `pasa` | ACCION | 3 | 6 | 0 | pasa / mueve (verbo — pasamovshist* — archiva movimientos a histórico) |
| `rst` | ENTIDAD | 3 | 0 | 1 | rst — formato RST (sp_generararchivo_rst fan_in=345 — NO_VERIFICABLE) |
| `bym3` | ENTIDAD | 2 | 0 | 2 | Billetes y Monedas (v3) |
| `digi` | ACCION | 2 | 19 | 10 | digitalización |
| `inf` | ENTIDAD | 2 | 0 | 0 | información |
| `maquila` | ENTIDAD | 2 | 0 | 0 | maquila — proceso de externalización de solicitudes TDC |
| `mover` | ACCION | 2 | 0 | 0 | mueve / archiva (operación de paso a histórico) |
| `proc` | ENTIDAD | 2 | 7 | 0 | proceso |
| `ultimas` | MODIF | 2 | 3 | 1 | últimas |
| `6dig` | MODIF | 1 | 0 | 0 | OTP/token de 6 dígitos — autenticación fuerte SMS |
| `b3` | MODIF | 1 | 0 | 0 | sufijo de versión de SP (Bloque/Build 3) — patrón Informix: no existe  |
| `bloq` | ACCION | 1 | 16 | 10 | bloqueo |
| `bym2` | ENTIDAD | 1 | 0 | 1 | Billetes y Monedas (v2) |
| `ckpt` | MODIF | 1 | 0 | 0 | checkpoint — evento de checkpointing del motor Informix |
| `fus` | ACCION | 1 | 0 | 0 | fusión de cuentas |
| `fus2` | AMBIGUO | 1 | 0 | 0 | fusión v2 |
| `innovattia` | ENTIDAD | 1 | 0 | 0 | Innovattia — proveedor externo de notificaciones SMS/email para BanCop |
| `invalido` | MODIF | 1 | 1 | 0 | inválido — dato o estado no válido |
| `liq` | ENTIDAD | 1 | 0 | 0 | liquidación (abreviación — sp_marcaliqpago, spei_recliquidacion) |
| `oxo` | ENTIDAD | 1 | 0 | 0 | OXXO (abreviación — spei_entordenespago_oxo) |
| `rcda` | ENTIDAD | 1 | 0 | 0 | RCDA — producto de captación/ahorro (apertura, incremento de saldo, ac |
| `recompensa` | ENTIDAD | 1 | 0 | 0 | recompensa / cashback (Coppel Max) |
| `trae` | ACCION | 1 | 2 | 0 | trae / recupera (verbo — sp_*_trae — bdisuc) |
| `valid` | ACCION | 1 | 24 | 4 | valida |
| `acceso` | ENTIDAD | 0 | 0 | 3 | acceso |
| `ciloc` | PREFIJO | 0 | 8 | 8 | consulta local de cobranza |
| `conciliachq` | ACCION | 0 | 15 | 0 | conciliación de cheques |
| `desb` | ACCION | 0 | 13 | 6 | desbloqueo |
| `disper` | ENTIDAD | 0 | 42 | 0 | disper — dispersión (abreviación — sp_dispercionnomina_*) |
| `ejecutar` | ACCION | 0 | 1 | 0 | ejecutar (infinitivo) |
| `forma` | ACCION | 0 | 13 | 11 | construye / arma |
| `genrep` | ACCION | 0 | 9 | 1 | genera reporte (abreviación genrep) |
| `notifi` | ACCION | 0 | 5 | 3 | notifica |
| `politica` | ENTIDAD | 0 | 0 | 1 | política de crédito |
| `realiza` | ACCION | 0 | 3 | 1 | realiza / ejecuta una operación SPEI |
| `regordenctecte` | ACCION | 0 | 8 | 2 | Regresa Orden Cuenta a Cuenta — operación de transferencia/orden entre |
| `remanente` | MODIF | 0 | 1 | 0 | remanente |
| `solin` | ENTIDAD | 0 | 3 | 1 | solicitud de crédito |
| `sub` | MODIF | 0 | 0 | 4 | sub- |
| `traspas` | ACCION | 0 | 10 | 2 | traspaso |
| `venio` | ENTIDAD | 0 | 4 | 0 | convenio |

### NEEDS_SME — Ambiguos, requieren validación

| Token | Cat | Est | SPs | Significado actual |
|-------|-----|-----|----:|--------------------|
| `regex` | ENTIDAD | gap | 1 | regex — motor de expresiones regulares Informix SPL (infraestructura bdinteg — 8 |
| `ivasart61` | REG | gap | 0 | IVA sobre operaciones del Art. 61 LIC (alcance fiscal por confirmar con el SME) |

### REMOVE_CANDIDATE — Sin evidencia en el knowledge base

| Token | Cat | Est | Significado actual |
|-------|-----|-----|--------------------|
| `apell` | ENTIDAD | inf | apellido |
| `aum` | MODIF | inf | aumento |
| `b4` | MODIF | inf | sufijo de versión de SP (Bloque/Build 4) |
| `b5` | MODIF | inf | sufijo de versión de SP (Bloque/Build 5) |
| `balp` | ENTIDAD | gap | balp — balance preventivo / balanza preventiva (gen_balprev*) |
| `cns` | ACCION | inf | consulta |
| `conciliadora` | ENTIDAD | inf | conciliadora |
| `consolidada` | MODIF | inf | consolidada / consolidado — cifras consolidadas (balanza diaria/mensual consolid |
| `ctb` | ENTIDAD | inf | ctb — contabilidad (abreviación interfaz — sp_ctbcpl_* D11↔D12) |
| `ctemoral` | ENTIDAD | inf | ctemoral — cuenta temporal (sp_guarda*ctemoral — bdicnweb) |
| `debcred` | ENTIDAD | inf | débito/crédito (movimiento) |
| `digver` | ENTIDAD | inf | dígito verificador (abreviación — digverclabe NO_VERIFICABLE) |
| `edocuenta` | ENTIDAD | inf | Estado de Cuenta (variante ortográfica de edocta — bdicheq/bdisolic:sp_*edocuent |
| `enavipro` | ENTIDAD | inf | ENAVIPRO — tipo de mensaje SPEI (Envío de Aviso en Proceso / Banxico) |
| `exec` | ACCION | inf | exec — ejecuta / execute (abreviación — execmuestraedocta, executaedocta) |
| `firme` | MODIF | inf | monto firme |
| `lin` | ENTIDAD | inf | línea (de crédito) |
| `msjafore` | ENTIDAD | inf | mensaje AFORE |
| `obtenerctas` | ACCION | inf | obtener cuentas (bdicheq:sp_obtenerctas_*) |
| `paq` | ENTIDAD | inf | paquete — paquete de pago SPEI (bloque/lote de órdenes de transferencia) |
| `proyeccion` | ENTIDAD | inf | proyección de cartera / saldo |
| `quebr` | ACCION | inf | quebranto — write-off de cartera vencida (bdicred) |
| `speich` | ENTIDAD | gap | SPEI-CH — tipo de movimiento SPEI de compensación/cheque (actualizamovspeich, pa |

---

## Sección 2 — Pares sinónimos y duplicados detectados

Se detectaron **799** pares con relación semántica significativa.

### Pares abreviación-forma larga (ABBREVIATION_PAIR)

| Abreviación | Forma larga | Cat | Nota |
|-------------|-------------|-----|------|
| `acl` (familia aclaraciones) | `aclaraciones` (aclaraciones (proceso de disputas/reclam) | PREFIJO | Categorías diferentes — revisar |
| `act` (actualiza) | `actualiza` (actualiza) | ACCION | Consolidar si mismo scope |
| `adm` (administración/administrar (abreviación ) | `admtoken` (AdmToken — módulo de administración de t) | ACCION | Categorías diferentes — revisar |
| `apell` (apellido) | `apellido` (apellido) | ENTIDAD | Consolidar si mismo scope |
| `aplica` (aplica / ejecuta) | `aplicar` (aplica / ejecuta) | ACCION | Consolidar si mismo scope |
| `arch` (archivo) | `archivo` (archivo) | ENTIDAD | Consolidar si mismo scope |
| `aud` (auditoría) | `auditoria` (auditoría) | ENTIDAD | Consolidar si mismo scope |
| `aum` (aumento) | `aumento` (aumento) | MODIF | Consolidar si mismo scope |
| `aum` (aumento) | `aumlincred` (Aumento de Línea de Crédito — proceso de) | MODIF | Categorías diferentes — revisar |
| `benef` (beneficiario) | `beneficiario` (beneficiario (receptor del pago SPEI)) | ENTIDAD | Consolidar si mismo scope |
| `buro` (Buró de Crédito) | `burofisicas` (Buró Personas Físicas — consulta al Buró) | ENTIDAD | Consolidar si mismo scope |
| `bym` (Billetes y Monedas (efectivo en sucursal) | `bym2` (Billetes y Monedas (v2)) | ENTIDAD | Consolidar si mismo scope |
| `bym` (Billetes y Monedas (efectivo en sucursal) | `bym3` (Billetes y Monedas (v3)) | ENTIDAD | Consolidar si mismo scope |
| `calcula` (calcula (verbo activo — spei_calculointe) | `calcular` (calcula (infinitivo)) | ACCION | Consolidar si mismo scope |
| `camp` (Campaña — campaña de cobranza o crédito ) | `campana` (campaña) | ENTIDAD | Consolidar si mismo scope |
| `cancela` (cancela) | `cancelacion` (cancela) | ACCION | Consolidar si mismo scope |
| `cant` (cantidad) | `cantidad` (cantidad) | ENTIDAD | Consolidar si mismo scope |
| `cat` (catálogo) | `catalogo` (catálogo) | ENTIDAD | Consolidar si mismo scope |
| `cat` (catálogo) | `catdenominacion` (catálogo de denominaciones) | ENTIDAD | Consolidar si mismo scope |
| `cc` (cc — cuenta corriente (sp_*_cc_* — bdicn) | `cce` (CCE — Cámara de Compensación Electrónica) | ENTIDAD | Consolidar si mismo scope |
| `cc` (cc — cuenta corriente (sp_*_cc_* — bdicn) | `ccl` (módulo de Cédulas de Captación e inversi) | ENTIDAD | Consolidar si mismo scope |
| `cheq` (cheque) | `cheque` (cheque) | ENTIDAD | Consolidar si mismo scope |
| `clave` (clave) | `claverastreo` (clave de rastreo SPEI (hasta 30 posicion) | ENTIDAD | Consolidar si mismo scope |
| `cob` (cob — cobranza (abreviación de dominio —) | `cobranza` (cobranza) | ENTIDAD | Consolidar si mismo scope |
| `cod` (código) | `codigo` (código) | ENTIDAD | Consolidar si mismo scope |
| `com` (Comisión bancaria — cobro de comisión so) | `comision` (comisión (CONDUSEF — debe estar en RECO)) | ENTIDAD | Categorías diferentes — revisar |
| `com` (Comisión bancaria — cobro de comisión so) | `compac` (Compromisos de Pago en Cobranza — acuerd) | ENTIDAD | Consolidar si mismo scope |
| `com` (Comisión bancaria — cobro de comisión so) | `compromiso` (compromiso de pago — promesa formal de l) | ENTIDAD | Consolidar si mismo scope |
| `con` (consulta) | `cons` (consulta) | ACCION | Consolidar si mismo scope |
| `con` (consulta) | `consreporte` (consulta reporte) | ACCION | Consolidar si mismo scope |
| `con` (consulta) | `consreportes` (consulta reportes) | ACCION | Consolidar si mismo scope |
| `con` (consulta) | `consulta` (consulta / lee) | ACCION | Consolidar si mismo scope |
| `con` (consulta) | `consuta` (consulta [typo]) | ACCION | Consolidar si mismo scope |
| `concilia` (conciliación) | `conciliachq` (conciliación de cheques) | ACCION | Consolidar si mismo scope |
| `concilia` (conciliación) | `conciliacion` (conciliación) | ACCION | Consolidar si mismo scope |
| `cons` (consulta) | `consreporte` (consulta reporte) | ACCION | Consolidar si mismo scope |
| `cons` (consulta) | `consreportes` (consulta reportes) | ACCION | Consolidar si mismo scope |
| `cons` (consulta) | `consulta` (consulta / lee) | ACCION | Consolidar si mismo scope |
| `cons` (consulta) | `consuta` (consulta [typo]) | ACCION | Consolidar si mismo scope |
| `consreporte` (consulta reporte) | `consreportes` (consulta reportes) | ACCION | Consolidar si mismo scope |
| `corresp` (Corresponsal — corresponsal bancario; re) | `corresponsal` (corresponsal) | ENTIDAD | Consolidar si mismo scope |
| `cre` (crédito) | `cred` (crédito) | ENTIDAD | Consolidar si mismo scope |
| `cre` (crédito) | `credito` (crédito) | ENTIDAD | Consolidar si mismo scope |
| `cred` (crédito) | `credito` (crédito) | ENTIDAD | Consolidar si mismo scope |
| `cta` (cuenta) | `ctaclabe` (cuenta CLABE) | ENTIDAD | Consolidar si mismo scope |
| `cta` (cuenta) | `ctamec` (Cuenta Mecánica — tipo de cuenta de cheq) | ENTIDAD | Consolidar si mismo scope |
| `cta` (cuenta) | `ctanvl2` (Cuenta Nivel 2 (CNBV Circular Única de B) | ENTIDAD | Consolidar si mismo scope |
| `cte` (cliente) | `ctefisico` (Cliente Físico — persona física (tp_pers) | ENTIDAD | Consolidar si mismo scope |
| `cte` (cliente) | `ctepr` (Cliente Prospecto — cliente potencial aú) | ENTIDAD | Consolidar si mismo scope |
| `deb` (débito) | `debcred` (débito/crédito (movimiento)) | MODIF | Categorías diferentes — revisar |
| `deb` (débito) | `debito` (débito) | MODIF | Categorías diferentes — revisar |
| `decodifica` (decodifica) | `decodificar` (decodifica) | ACCION | Consolidar si mismo scope |
| `det` (detalle) | `detalle` (detalle) | ENTIDAD | Consolidar si mismo scope |
| `dicta` (dicta — dictamen / subsistema de dictami) | `dictamen` (dictamen) | ENTIDAD | Consolidar si mismo scope |
| `digi` (digitalización) | `digitalizacion` (digitalización de documentos) | ACCION | Categorías diferentes — revisar |
| `disper` (disper — dispersión (abreviación — sp_di) | `dispersion` (dispersión — dispersión de nómina (sp_di) | ENTIDAD | Consolidar si mismo scope |
| `domi` (domiciliación) | `domiciliacion` (domiciliación) | ENTIDAD | Consolidar si mismo scope |
| `dotacion` (dotación de efectivo (a cajero/sucursal)) | `dotaciones` (dotaciones de efectivo) | ENTIDAD | Consolidar si mismo scope |
| `edo` (estado) | `edocta` (Estado de Cuenta — documento periódico d) | ENTIDAD | Consolidar si mismo scope |
| `edo` (estado) | `edoctacrd` (Estado de Cuenta Crédito — documento de ) | ENTIDAD | Consolidar si mismo scope |
| `edo` (estado) | `edocuenta` (Estado de Cuenta (variante ortográfica d) | ENTIDAD | Consolidar si mismo scope |
| `edocta` (Estado de Cuenta — documento periódico d) | `edoctacrd` (Estado de Cuenta Crédito — documento de ) | ENTIDAD | Consolidar si mismo scope |
| `emp` (Empresa — empleadora del cliente; vincul) | `empresa` (empresa (entidad bancaria)) | ENTIDAD | Consolidar si mismo scope |
| `estatus` (estatus) | `estatussolic` (estatus de solicitud) | ENTIDAD | Consolidar si mismo scope |
| `fecha` (fecha) | `fechaconsulta` (fecha de consulta) | ENTIDAD | Consolidar si mismo scope |
| `fecha` (fecha) | `fechafin` (fecha fin) | ENTIDAD | Consolidar si mismo scope |
| `fecha` (fecha) | `fechafinal` (fecha final) | ENTIDAD | Consolidar si mismo scope |
| `fecha` (fecha) | `fechainicial` (fecha inicial) | ENTIDAD | Consolidar si mismo scope |
| `fecha` (fecha) | `fechainicio` (fecha inicio) | ENTIDAD | Consolidar si mismo scope |
| `fechafin` (fecha fin) | `fechafinal` (fecha final) | ENTIDAD | Consolidar si mismo scope |
| `fus` (fusión de cuentas) | `fus2` (fusión v2) | ACCION | Categorías diferentes — revisar |
| `fus` (fusión de cuentas) | `fusion` (fusiona cuentas) | ACCION | Consolidar si mismo scope |
| `gen` (genera / general) | `genera` (genera / produce) | ACCION | Consolidar si mismo scope |
| `gen` (genera / general) | `generaredoctaeje` (Genera Estado de Cuenta Ejecutivo — proc) | ACCION | Consolidar si mismo scope |
| `gen` (genera / general) | `genrep` (genera reporte (abreviación genrep)) | ACCION | Consolidar si mismo scope |
| `genera` (genera / produce) | `generaredoctaeje` (Genera Estado de Cuenta Ejecutivo — proc) | ACCION | Consolidar si mismo scope |
| `hipoteca` (crédito hipotecario (digital, desde 2025) | `hipotecario` (crédito hipotecario) | ENTIDAD | Consolidar si mismo scope |
| `his` (histórico) | `hist` (histórico/historial) | MODIF | Consolidar si mismo scope |
| `his` (histórico) | `historico` (histórico) | MODIF | Consolidar si mismo scope |
| `hist` (histórico/historial) | `historico` (histórico) | MODIF | Consolidar si mismo scope |
| `idfuncion` (id de funcionalidad) | `idfuncionc` (id de funcionalidad) | ENTIDAD | Consolidar si mismo scope |
| `inf` (información) | `info` (información) | ENTIDAD | Consolidar si mismo scope |
| `inicializa` (inicializa) | `inicializar` (inicializa) | ACCION | Consolidar si mismo scope |
| `int` (interés) | `interes` (interés) | ENTIDAD | Consolidar si mismo scope |
| `inv` (inv — inversión (abreviación — calsdoinv) | `invalido` (inválido — dato o estado no válido) | ENTIDAD | Categorías diferentes — revisar |
| `inv` (inv — inversión (abreviación — calsdoinv) | `inversion` (inversión (pagaré / plazo)) | ENTIDAD | Consolidar si mismo scope |
| `iva` (IVA (impuesto — SAT)) | `ivasart61` (IVA sobre operaciones del Art. 61 LIC (a) | REG | Consolidar si mismo scope |
| `lin` (línea (de crédito)) | `lincred` (línea de crédito) | ENTIDAD | Consolidar si mismo scope |
| `lin` (línea (de crédito)) | `linea` (línea (de crédito)) | ENTIDAD | Consolidar si mismo scope |
| `liq` (liquidación (abreviación — sp_marcaliqpa) | `liquidacion` (liquidación) | ENTIDAD | Consolidar si mismo scope |
| `mesa` (Mesa de Control — equipo de revisión y a) | `mesas` (Mesas de Control — equipo de revisión y ) | ENTIDAD | Consolidar si mismo scope |
| `mnsj` (mensajería / notificaciones (dominio bdi) | `mnsjr` (mensajería registrada / tabla de transac) | PREFIJO | Consolidar si mismo scope |
| `mon` (monitor / módulo) | `monitor` (monitor) | PREFIJO | Categorías diferentes — revisar |
| `mon` (monitor / módulo) | `monitorsol` (Monitor de Solicitudes — sistema de moni) | PREFIJO | Categorías diferentes — revisar |
| `monitor` (monitor) | `monitorsol` (Monitor de Solicitudes — sistema de moni) | ENTIDAD | Consolidar si mismo scope |
| `mov` (movimiento) | `movimiento` (movimiento) | ENTIDAD | Consolidar si mismo scope |
| `mov` (movimiento) | `movto` (movimiento) | ENTIDAD | Consolidar si mismo scope |
| `msj` (mensaje — abreviación corta de mnsj (sp_) | `msjafore` (mensaje AFORE) | ENTIDAD | Consolidar si mismo scope |
| `nom` (nómina) | `nomina` (nómina) | ENTIDAD | Consolidar si mismo scope |
| `nombre` (nombre) | `nombreref` (nombre de referencia) | ENTIDAD | Consolidar si mismo scope |
| `notifi` (notifica) | `notifica` (notifica) | ACCION | Consolidar si mismo scope |
| `num` (número (de)) | `numcliente` (número de cliente) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numcred` (número de crédito) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numcredito` (número de crédito) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numcte` (número de cliente) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numcuenta` (número de cuenta) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numempleado` (número de empleado) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numerocliente` (número de cliente) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numproducto` (número de producto) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numsol` (número de solicitud) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numsolicitud` (número de solicitud) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numsucursal` (número de sucursal) | ENTIDAD | Consolidar si mismo scope |
| `num` (número (de)) | `numtarjeta` (número de tarjeta) | ENTIDAD | Consolidar si mismo scope |
| `numcred` (número de crédito) | `numcredito` (número de crédito) | ENTIDAD | Consolidar si mismo scope |
| `numsol` (número de solicitud) | `numsolicitud` (número de solicitud) | ENTIDAD | Consolidar si mismo scope |
| `obt` (obtiene) | `obten` (obtiene / recupera) | ACCION | Consolidar si mismo scope |
| `obt` (obtiene) | `obtener` (obtiene / recupera) | ACCION | Consolidar si mismo scope |
| `obt` (obtiene) | `obtiene` (obtiene / recupera) | ACCION | Consolidar si mismo scope |
| `obten` (obtiene / recupera) | `obtener` (obtiene / recupera) | ACCION | Consolidar si mismo scope |
| `ofi` (oficio) | `oficio` (oficio (requerimiento judicial/autoridad) | ENTIDAD | Consolidar si mismo scope |
| `ope` (operación) | `operacion` (operación) | ACCION | Consolidar si mismo scope |
| `ord` (ordenante / orden (SPEI)) | `ordenante` (ordenante (pagador que emite la orden SP) | ENTIDAD | Consolidar si mismo scope |
| `orden` (orden) | `ordenpago` (orden de pago) | ENTIDAD | Consolidar si mismo scope |
| `param` (parámetro) | `parametro` (parámetro) | ENTIDAD | Consolidar si mismo scope |
| `pase` (pase contable (registra/traslada a póliz) | `pasecheq` (pase de cheque (a compensación/conciliac) | ACCION | Consolidar si mismo scope |
| `pase` (pase contable (registra/traslada a póliz) | `pasecont` (realiza el pase contable (registro a pól) | ACCION | Consolidar si mismo scope |
| `pieza` (pieza de efectivo (billete/moneda)) | `piezas` (piezas de efectivo (billetes y monedas)) | ENTIDAD | Consolidar si mismo scope |
| `portab` (portabilidad — portabilidad de nómina (s) | `portabilidad` (portabilidad (de nómina o número)) | ENTIDAD | Consolidar si mismo scope |
| `proc` (proceso) | `proceso` (proceso) | ENTIDAD | Consolidar si mismo scope |
| `prod` (producto) | `producto` (producto) | ENTIDAD | Consolidar si mismo scope |
| `ref` (referencia) | `referencia` (referencia) | AMBIGUO | Categorías diferentes — revisar |
| `reg` (registro) | `registro` (registro) | ACCION | Categorías diferentes — revisar |
| `rem` (remesa (forma corta)) | `remesa` (remesa (Western Union / MoneyGram)) | ENTIDAD | Consolidar si mismo scope |
| `rep` (reporte) | `repipab` (Reporte IPAB — reporte regulatorio de se) | ACCION | Categorías diferentes — revisar |
| `rep` (reporte) | `reporte` (reporte) | ACCION | Categorías diferentes — revisar |
| `rev` (reversión (abreviación de reversa/revers) | `reversa` (Reversión — anula/revierte una operación) | ACCION | Consolidar si mismo scope |
| `ro` (ro — Rol Operativo (subsistema sp_sw_ro_) | `rol` (rol / perfil) | ENTIDAD | Consolidar si mismo scope |
| `sd` (sd — saldo disponible (abreviación en có) | `sdo` (saldo) | ENTIDAD | Consolidar si mismo scope |
| `sd` (sd — saldo disponible (abreviación en có) | `sdodisp` (saldo disponible) | ENTIDAD | Consolidar si mismo scope |
| `sdo` (saldo) | `sdodisp` (saldo disponible) | ENTIDAD | Consolidar si mismo scope |
| `sol` (solicitud) | `solic` (solicitud) | ENTIDAD | Consolidar si mismo scope |
| `sol` (solicitud) | `solicitud` (solicitud) | ENTIDAD | Consolidar si mismo scope |
| `sol` (solicitud) | `solin` (solicitud de crédito) | ENTIDAD | Consolidar si mismo scope |
| `solic` (solicitud) | `solicitud` (solicitud) | ENTIDAD | Consolidar si mismo scope |
| `spei` (familia SPEI (pagos interbancarios)) | `speich` (SPEI-CH — tipo de movimiento SPEI de com) | PREFIJO | Categorías diferentes — revisar |
| `suc` (sucursal) | `sucursal` (sucursal) | MODIF | Categorías diferentes — revisar |
| `tar` (Tarjeta (abreviación — bdicheq/bdicred: ) | `tarjeta` (tarjeta) | ENTIDAD | Consolidar si mismo scope |
| `tc` (tc — Tarjeta de Crédito (abreviación en ) | `tco` (TCO — Tarjetas Coppel / TCoppel (product) | ENTIDAD | Consolidar si mismo scope |
| `tel` (teléfono) | `telefono` (teléfono) | ENTIDAD | Consolidar si mismo scope |
| `tp` (tipo) | `tpcalculo` (tipo de cálculo) | MODIF | Categorías diferentes — revisar |
| `transacc` (código de transacción) | `transaccion` (transacción) | ENTIDAD | Consolidar si mismo scope |
| `traspas` (traspaso) | `traspaso` (traspaso entre cuentas) | ACCION | Consolidar si mismo scope |
| `valid` (valida) | `valida` (valida) | ACCION | Consolidar si mismo scope |
| `venc` (vencimiento) | `vencimiento` (vencimiento) | ENTIDAD | Consolidar si mismo scope |

### Pares sinónimos (SYNONYM_PAIR)

| Token A | Token B | Cat | Jaccard | Significado A | Significado B |
|---------|---------|-----|---------|---------------|---------------|
| `b3` | `b4` | MODIF/MODIF | ≥0.75 | sufijo de versión de SP (Bloque/Build 3) — pa | sufijo de versión de SP (Bloque/Build 4) |
| `b3` | `b5` | MODIF/MODIF | ≥0.75 | sufijo de versión de SP (Bloque/Build 3) — pa | sufijo de versión de SP (Bloque/Build 5) |
| `b4` | `b5` | MODIF/MODIF | ≥0.75 | sufijo de versión de SP (Bloque/Build 4) | sufijo de versión de SP (Bloque/Build 5) |
| `bym2` | `bym3` | ENTIDAD/ENTIDAD | ≥0.75 | Billetes y Monedas (v2) | Billetes y Monedas (v3) |
| `digito` | `digver` | ENTIDAD/ENTIDAD | ≥0.75 | dígito verificador | dígito verificador (abreviación — digverclabe |
| `movil` | `mvl` | MODIF/MODIF | ≥0.75 | canal móvil | canal móvil |
| `numcliente` | `numcte` | ENTIDAD/ENTIDAD | ≥0.75 | número de cliente | número de cliente |
| `numcliente` | `numerocliente` | ENTIDAD/ENTIDAD | ≥0.75 | número de cliente | número de cliente |
| `numcte` | `numerocliente` | ENTIDAD/ENTIDAD | ≥0.75 | número de cliente | número de cliente |
| `tc` | `tdc` | ENTIDAD/ENTIDAD | ≥0.75 | tc — Tarjeta de Crédito (abreviación en solic | tarjeta de crédito (TDC) |

### Pares con overlap semántico (OVERLAP)

| Token A | Token B | Relación | Significado A | Significado B |
|---------|---------|----------|---------------|---------------|
| `acceso` | `iccat` | 'iccat' aparece en def de 'acceso' | acceso | ICCAT — canal de atención al cliente en BPI;  |
| `acceso` | `medioacceso` | 'medioacceso' aparece en def de 'acceso' | acceso | medio de acceso |
| `acl` | `aclaracion` | 'acl' aparece en def de 'aclaracion' | familia aclaraciones | aclaración bancaria — proceso de disputa o re |
| `aclaracion` | `aclaraciones` | 'aclaraciones' aparece en def de 'aclaracion' | aclaración bancaria — proceso de disputa o re | aclaraciones (proceso de disputas/reclamacion |
| `aclaracion` | `cliente` | 'aclaracion' aparece en def de 'cliente' | aclaración bancaria — proceso de disputa o re | cliente |
| `aclaracion` | `edoctacrd` | 'edoctacrd' aparece en def de 'aclaracion' | aclaración bancaria — proceso de disputa o re | Estado de Cuenta Crédito — documento de movim |
| `aclaracion` | `proc` | 'aclaracion' aparece en def de 'proc' | aclaración bancaria — proceso de disputa o re | proceso |
| `aclaracion` | `proceso` | 'aclaracion' aparece en def de 'proceso' | aclaración bancaria — proceso de disputa o re | proceso |
| `aclaraciones` | `edoctacrd` | 'edoctacrd' aparece en def de 'aclaraciones' | aclaraciones (proceso de disputas/reclamacion | Estado de Cuenta Crédito — documento de movim |
| `activa` | `activar` | 'activar' aparece en def de 'activa' | activa | activar |
| `activa` | `inactiv` | 'inactiv' aparece en def de 'activa' | activa | inactiva |
| `activa` | `inactivas` | 'inactivas' aparece en def de 'activa' | activa | inactivas (art.61) |
| `actualiza` | `upd` | 'upd' aparece en def de 'actualiza' | actualiza | actualiza (update) |
| `actualiza` | `upgrade` | 'upgrade' aparece en def de 'actualiza' | actualiza | actualiza producto (upgrade) |
| `acuerdo` | `cliente` | 'acuerdo' aparece en def de 'cliente' | acuerdo de pago — convenio de cobranza con el | cliente |
| `acuerdo` | `cobra` | 'acuerdo' aparece en def de 'cobra' | acuerdo de pago — convenio de cobranza con el | cobra / aplica cobro / genera cargo |
| `acuerdo` | `cobranza` | 'acuerdo' aparece en def de 'cobranza' | acuerdo de pago — convenio de cobranza con el | cobranza |
| `acuerdo` | `compac` | 'compac' aparece en def de 'acuerdo' | acuerdo de pago — convenio de cobranza con el | Compromisos de Pago en Cobranza — acuerdos/co |
| `acuerdo` | `convenio` | 'acuerdo' aparece en def de 'convenio' | acuerdo de pago — convenio de cobranza con el | convenio (nómina/empresarial) |
| `acuerdo` | `pago` | 'acuerdo' aparece en def de 'pago' | acuerdo de pago — convenio de cobranza con el | pago |
| `acuerdo` | `venio` | 'acuerdo' aparece en def de 'venio' | acuerdo de pago — convenio de cobranza con el | convenio |
| `adm` | `admin` | 'adm' aparece en def de 'admin' | administración/administrar (abreviación de ad | Administrador — rol de usuario con privilegio |
| `admin` | `admtoken` | 'admtoken' aparece en def de 'admin' | Administrador — rol de usuario con privilegio | AdmToken — módulo de administración de tokens |
| `admin` | `sat` | 'sat' aparece en def de 'admin' | Administrador — rol de usuario con privilegio | SAT — Servicio de Administración Tributaria ( |
| `admin` | `usuario` | 'admin' aparece en def de 'usuario' | Administrador — rol de usuario con privilegio | usuario |
| `admtoken` | `moral` | 'admtoken' aparece en def de 'moral' | AdmToken — módulo de administración de tokens | persona moral |
| `admtoken` | `token` | 'admtoken' aparece en def de 'token' | AdmToken — módulo de administración de tokens | token (autenticación) |
| `adn` | `auto` | 'adn' aparece en def de 'auto' | Adelanto de Nómina — producto de crédito al c | automático (proceso automático / batch — sp_* |
| `adn` | `cons` | 'adn' aparece en def de 'cons' | Adelanto de Nómina — producto de crédito al c | consulta |
| `adn` | `desc` | 'adn' aparece en def de 'desc' | Adelanto de Nómina — producto de crédito al c | [polisemia] Descripción (sp_desc_ret: devuelv |
| `adn` | `prod` | 'adn' aparece en def de 'prod' | Adelanto de Nómina — producto de crédito al c | producto |
| `adn` | `producto` | 'adn' aparece en def de 'producto' | Adelanto de Nómina — producto de crédito al c | producto |
| `afore` | `msjafore` | 'msjafore' aparece en def de 'afore' | AFORE (Afore Coppel — 2ª mayor de México, ~14 | mensaje AFORE |
| `alerta` | `alertas` | 'alertas' aparece en def de 'alerta' | alerta | alertas |
| `alta` | `faltantes` | 'faltantes' aparece en def de 'alta' | da de alta / registra | faltantes |
| `app` | `canal` | 'app' aparece en def de 'canal' | canal app | canal (de distribución) |
| `arch` | `archivos` | 'archivos' aparece en def de 'arch' | archivo | archivos |
| `arch` | `archsdos` | 'archsdos' aparece en def de 'arch' | archivo | Archivos de Saldos — comentario explícito: 'G |
| `arch` | `ftc` | 'ftc' aparece en def de 'arch' | archivo | FTC — módulo de configuración de transferenci |
| `arch` | `layout` | 'layout' aparece en def de 'arch' | archivo | layout — formato de archivo de intercambio in |

_... y 595 pares adicionales no mostrados._

---

## Sección 3 — Scope enrichment propuesto

Hay **127** términos con `scope='—'` (no asignado) en brain.db.
El scope propuesto se deriva de los dominios (D01-D16) donde aparecen los SPs que usan ese token.

| Token | Cat | SPs | Scope propuesto | Dominios principales |
|-------|-----|----:|-----------------|----------------------|
| `sp` | PREFIJO | 9183 | TRANSVERSAL | D01(2183), D02(1778), D03(1185) |
| `cnsif` | ENTIDAD | 143 | DOMAIN-CLUSTER (D01:Canal Digital Web, D02:Integración y Auth) | D02(119), D01(24) |
| `mc` | ENTIDAD | 102 | TRANSVERSAL | D01(61), D06(19), D16(8) |
| `sw` | ENTIDAD | 100 | DOMAIN-CLUSTER (D01:Canal Digital Web, D02:Integración y Auth) | D01(99), D02(1) |
| `ro` | ENTIDAD | 99 | DOMAIN-SPECIFIC (D01 — Canal Digital Web) | D01(99) |
| `cg` | ENTIDAD | 85 | DOMAIN-CLUSTER (D01:Canal Digital Web, D10:Sucursales) | D01(84), D10(1) |
| `pp` | ENTIDAD | 85 | TRANSVERSAL | D03(41), D01(21), D06(9) |
| `cjunk` | AMBIGUO | 61 | TRANSVERSAL | D06(41), D02(15), D03(3) |
| `sd` | ENTIDAD | 49 | DOMAIN-CLUSTER (D03:Créditos, D04:Cheques / Cuentas) | D03(40), D04(9) |
| `cp` | ENTIDAD | 45 | TRANSVERSAL | D01(39), D02(2), D05(2) |
| `tc` | ENTIDAD | 39 | TRANSVERSAL | D03(20), D06(11), D11(3) |
| `fc` | ENTIDAD | 36 | DOMAIN-SPECIFIC (D01 — Canal Digital Web) | D01(36) |
| `cc` | ENTIDAD | 35 | DOMAIN-CLUSTER (D01:Canal Digital Web, D04:Cheques / Cuentas) | D01(33), D04(2) |
| `os` | ENTIDAD | 35 | DOMAIN-CLUSTER (D02:Integración y Auth, D03:Créditos, D06:Solicitudes) | D06(32), D02(2), D03(1) |
| `ss` | ENTIDAD | 32 | TRANSVERSAL | D06(25), D03(3), D02(2) |
| `wu` | ENTIDAD | 30 | DOMAIN-SPECIFIC (D05 — Saldos y Cuentas) | D05(30) |
| `corrige` | ACCION | 27 | TRANSVERSAL | D04(12), D03(12), D06(1) |
| `dinya` | ENTIDAD | 26 | DOMAIN-CLUSTER (D01:Canal Digital Web, D05:Saldos y Cuentas) | D05(25), D01(1) |
| `estadisticas` | ENTIDAD | 22 | TRANSVERSAL | D05(16), D02(3), D03(2) |
| `synmotor` | ENTIDAD | 17 | DOMAIN-SPECIFIC (D16 — Tarjetas) | D16(17) |
| `ctamec` | ENTIDAD | 16 | DOMAIN-CLUSTER (D02:Integración y Auth, D04:Cheques / Cuentas) | D04(15), D02(1) |
| `mueve` | ACCION | 16 | DOMAIN-CLUSTER (D03:Créditos, D07:Aclaraciones) | D03(14), D07(2) |
| `credisoluciones` | ENTIDAD | 14 | DOMAIN-SPECIFIC (D03 — Créditos) | D03(14) |
| `dv` | ENTIDAD | 12 | DOMAIN-SPECIFIC (D05 — Saldos y Cuentas) | D05(12) |
| `generaredoctaeje` | ACCION | 12 | DOMAIN-SPECIFIC (D04 — Cheques / Cuentas) | D04(12) |
| `ctefisico` | ENTIDAD | 11 | DOMAIN-SPECIFIC (D02 — Integración y Auth) | D02(11) |
| `depuracion` | ACCION | 9 | TRANSVERSAL | D05(3), D16(3), D02(2) |
| `inicializa` | ACCION | 9 | TRANSVERSAL | D06(3), D04(2), D03(1) |
| `sv` | ENTIDAD | 8 | DOMAIN-CLUSTER (D02:Integración y Auth, D03:Créditos, D07:Aclaraciones) | D07(5), D02(2), D03(1) |
| `supervision` | ENTIDAD | 6 | DOMAIN-CLUSTER (D03:Créditos, D06:Solicitudes) | D06(4), D03(2) |
| `suscriptores` | ACCION | 6 | DOMAIN-CLUSTER (D02:Integración y Auth, D09:Mensajería) | D09(5), D02(1) |
| `inactivas` | MODIF | 5 | DOMAIN-CLUSTER (D03:Créditos, D04:Cheques / Cuentas) | D03(3), D04(2) |
| `reevaluacion` | ACCION | 5 | DOMAIN-SPECIFIC (D06 — Solicitudes) | D06(5) |
| `coas` | ENTIDAD | 4 | DOMAIN-SPECIFIC (D08 — SPEI) | D08(4) |
| `reinicia` | ACCION | 4 | DOMAIN-CLUSTER (D06:Solicitudes, D07:Aclaraciones, D08:SPEI) | D06(2), D08(1), D07(1) |
| `split` | ACCION | 4 | DOMAIN-CLUSTER (D01:Canal Digital Web, D02:Integración y Auth) | D02(3), D01(1) |
| `autenticacion` | ENTIDAD | 2 | DOMAIN-CLUSTER (D08:SPEI, D14:BEI) | D08(1), D14(1) |
| `bym3` | ENTIDAD | 2 | DOMAIN-SPECIFIC (D10 — Sucursales) | D10(2) |
| `id` | ENTIDAD | 2 | DOMAIN-CLUSTER (D02:Integración y Auth, D14:BEI) | D02(1), D14(1) |
| `reproceso` | ACCION | 2 | DOMAIN-SPECIFIC (D03 — Créditos) | D03(2) |
| `6dig` | MODIF | 1 | DOMAIN-SPECIFIC (D09 — Mensajería) | D09(1) |
| `b3` | MODIF | 1 | DOMAIN-SPECIFIC (D12 — Contabilidad) | D12(1) |
| `bym2` | ENTIDAD | 1 | DOMAIN-SPECIFIC (D10 — Sucursales) | D10(1) |
| `ckpt` | MODIF | 1 | DOMAIN-SPECIFIC (D09 — Mensajería) | D09(1) |
| `consreportes` | ACCION | 1 | DOMAIN-SPECIFIC (D01 — Canal Digital Web) | D01(1) |
| `desbloquea` | ACCION | 1 | DOMAIN-SPECIFIC (D02 — Integración y Auth) | D02(1) |
| `fn` | PREFIJO | 1 | DOMAIN-SPECIFIC (D11 — Cobranza) | D11(1) |
| `fus2` | AMBIGUO | 1 | DOMAIN-SPECIFIC (D02 — Integración y Auth) | D02(1) |
| `inicializar` | ACCION | 1 | DOMAIN-SPECIFIC (D04 — Cheques / Cuentas) | D04(1) |
| `innovattia` | ENTIDAD | 1 | DOMAIN-SPECIFIC (D09 — Mensajería) | D09(1) |
| `mvl` | MODIF | 1 | DOMAIN-SPECIFIC (D09 — Mensajería) | D09(1) |
| `oxo` | ENTIDAD | 1 | DOMAIN-SPECIFIC (D08 — SPEI) | D08(1) |
| `rcda` | ENTIDAD | 1 | DOMAIN-SPECIFIC (D02 — Integración y Auth) | D02(1) |
| `telefonico` | MODIF | 1 | DOMAIN-SPECIFIC (D07 — Aclaraciones) | D07(1) |
| `trae` | ACCION | 1 | DOMAIN-SPECIFIC (D06 — Solicitudes) | D06(1) |
| `visual` | MODIF | 1 | DOMAIN-SPECIFIC (D12 — Contabilidad) | D12(1) |
| `activa` | ? | 0 | —SIN-EVIDENCIA— | — |
| `admtoken` | ? | 0 | —SIN-EVIDENCIA— | — |
| `archsdos` | ? | 0 | —SIN-EVIDENCIA— | — |
| `asiento` | ENTIDAD | 0 | —SIN-EVIDENCIA— | — |

_... y 67 términos adicionales no mostrados._

---

## Sección 4 — Tokens frecuentes faltantes en vocabulario

Análisis de 7,723 tokens únicos extraídos de 10,967 nombres de SPs.
Solo **2** tokens con frecuencia > 20 no están en el vocabulario, lo que confirma
la alta cobertura del vocabulario actual tras los grounding passes D01-D16.

### Candidatos primarios (freq > 20)

| Rank | Token | Frecuencia | Categoría sugerida | Nota |
|-----:|-------|----------:|---------------------|------|
| 1 | `exp1` | 25 | MODIF (versión) | Variante versionada de `exp` |
| 2 | `oper` | 24 | ACCION | Token corto — verificar si es abreviación conocida |

### Candidatos secundarios (freq 10-20) — top 20 de 54

Tokens de frecuencia moderada que pueden ser candidatos para futuras expansiones del vocabulario.

| Rank | Token | Frecuencia | Categoría sugerida | Nota |
|-----:|-------|----------:|---------------------|------|
| 1 | `tabla` | 20 | MODIF |  |
| 2 | `manc` | 19 | ENTIDAD? | Token corto — verificar si es abreviación |
| 3 | `user` | 19 | ACCION | Token corto — verificar si es abreviación |
| 4 | `val` | 18 | ENTIDAD? | Token corto — verificar si es abreviación |
| 5 | `extrae` | 17 | ENTIDAD? |  |
| 6 | `proyecta` | 17 | ENTIDAD? |  |
| 7 | `calc` | 16 | ENTIDAD? | Token corto — verificar si es abreviación |
| 8 | `pba1` | 16 | MODIF (versión) | Variante versionada de `pba` |
| 9 | `get` | 16 | ENTIDAD? | Token corto — verificar si es abreviación |
| 10 | `prueba` | 15 | ENTIDAD? |  |
| 11 | `insertar` | 15 | ACCION | Infinitivo sin registrar |
| 12 | `guardar` | 15 | ACCION | Infinitivo sin registrar |
| 13 | `tmp` | 13 | ENTIDAD? | Token corto — verificar si es abreviación |
| 14 | `generainf` | 13 | ENTIDAD? |  |
| 15 | `perfis` | 13 | ENTIDAD? |  |
| 16 | `mod` | 13 | ENTIDAD? | Token corto — verificar si es abreviación |
| 17 | `sin` | 13 | ENTIDAD? | Token corto — verificar si es abreviación |
| 18 | `actualizar` | 13 | ACCION | Infinitivo sin registrar |
| 19 | `bei2` | 13 | MODIF (versión) | Variante versionada de `bei` |
| 20 | `guardarespuesta` | 13 | ENTIDAD? |  |

---

## Sección 5 — Definiciones con oportunidad de enriquecimiento

Top 20 términos de alta frecuencia cuya definición puede enriquecerse con contexto de journeys
y/o regulatorio extraído del knowledge base.

### 1. `consulta` — consulta / lee

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 359
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, CONDUSEF, CONDUSEF; CNBV, CONDUSEF; IPAB, SAT, SAT; CONDUSEF; CNBV, TESOFE
- **Contexto de journeys**:
  - _consulta fechas · Art. 61 LIC_
  - _consulta información, reporte y detalle_
  - _consulta dicta â€” dictamen, clientes y dictamen_

### 2. `totales` — totales

- **Categoría**: MODIF | **Estado**: conf | **Frecuencia en SPs**: 240
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV
- **Contexto de journeys**:
  - _consulta reportes cuentas inactivas (totales) · Art. 61 LIC_
  - _consulta datos, piezas de efectivo y Billetes y Monedas (totales)_

### 3. `cons` — consulta

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 195
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, CONDUSEF, CONDUSEF; CNBV, CONDUSEF; IPAB, SAT, SAT; CONDUSEF; CNBV, TESOFE
- **Contexto de journeys**:
  - _consulta cÃ©dulas usuarios y mÃ³dulo de CÃ©dulas de CaptaciÃ³n e inversiÃ³n â€” pagarÃ©, ISR, saldos_
  - _consulta reportes cuentas inactivas · Art. 61 LIC_
  - _consulta reportes cuentas inactivas (totales) · Art. 61 LIC_

### 4. `ope` — operación

- **Categoría**: ACCION | **Estado**: inf | **Frecuencia en SPs**: 189
- **Oportunidades**: confirmar-estado

### 5. `actualiza` — actualiza

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 162
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, CONDUSEF
- **Contexto de journeys**:
  - _actualiza dicta â€” dictamen, estatus y alerta_
  - _actualiza folio_
  - _actualiza SOE â€” Soporte Operativo EmpresaNet; confirmado por SME y estatus_

### 6. `valida` — valida

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 148
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, CONDUSEF, SAT, TESOFE
- **Contexto de journeys**:
  - _valida perfil de usuario y usuario_
  - _valida nÃ³mina, beneficiario y Bancomer Transfer Services â€” canal de transferencias BBVA; base de _
  - _valida remesa, Bancomer Transfer Services â€” canal de transferencias BBVA; base de datos propia bdi_

### 7. `cnsif` — CNSIF — sistema de confirmación de ejecutivo (sp_cnsif_confi

- **Categoría**: ENTIDAD | **Estado**: conf | **Frecuencia en SPs**: 143
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV
- **Contexto de journeys**:
  - _consulta producto de cliente CNSIF â€” sistema de confirmaciÃ³n de ejecutivo_

### 8. `reporte` — reporte

- **Categoría**: ENTIDAD | **Estado**: conf | **Frecuencia en SPs**: 122
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, CONDUSEF, SAT; CNBV
- **Contexto de journeys**:
  - _consulta reportes cuentas inactivas · Art. 61 LIC_
  - _consulta reportes cuentas inactivas (totales) · Art. 61 LIC_
  - _consulta información, reporte y detalle_

### 9. `ofi` — oficio

- **Categoría**: ENTIDAD | **Estado**: inf | **Frecuencia en SPs**: 98
- **Oportunidades**: confirmar-estado

### 10. `gen` — genera / general

- **Categoría**: ACCION | **Estado**: inf | **Frecuencia en SPs**: 97
- **Oportunidades**: confirmar-estado

### 11. `depura` — depura / limpia

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 88
- **Oportunidades**: contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV

### 12. `spei` — familia SPEI (pagos interbancarios)

- **Categoría**: PREFIJO | **Estado**: conf | **Frecuencia en SPs**: 85
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: Banxico, Banxico; Banxico, CNBV; Banxico
- **Contexto de journeys**:
  - _aplica orden de pago_
  - _recibe cancelación_
  - _recibe devolución_

### 13. `cred` — crédito

- **Categoría**: ENTIDAD | **Estado**: conf | **Frecuencia en SPs**: 84
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, CONDUSEF
- **Contexto de journeys**:
  - _consulta Buró de Crédito, solicitud, crédito y línea de crédito_
  - _consulta crédito (por fallecimiento)_
  - _traspaso entre cuentas cuentas, crédito y Sistema Operativo Central_

### 14. `genera` — genera / produce

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 81
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, CONDUSEF, SAT; CNBV
- **Contexto de journeys**:
  - _consulta saldos (general)_
  - _genera fecha de pago de reestructura (de baja)_
  - _generar alertas y cliente_

### 15. `obtiene` — obtiene / recupera

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 79
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, CONDUSEF
- **Contexto de journeys**:
  - _obtiene imágenes y cliente (últimas)_
  - _obtiene parámetro_
  - _obtiene información y identificación (canal app)_

### 16. `inserta` — inserta / registra

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 72
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, CONDUSEF, SAT
- **Contexto de journeys**:
  - _inserta sub-producto_
  - _inserta productos_
  - _inserta bitÃ¡cora y cob â€” cobranza_

### 17. `busca` — busca / localiza

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 69
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CONDUSEF
- **Contexto de journeys**:
  - _busca fal â€” fallo/disputa, beneficiarios y cuenta_
  - _busca fal â€” fallo/disputa y documentos (faltantes)_
  - _busca fal â€” fallo/disputa, pagarÃ©s y cliente_

### 18. `carga` — carga / ingresa

- **Categoría**: ACCION | **Estado**: conf | **Frecuencia en SPs**: 68
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, SAT
- **Contexto de journeys**:
  - _carga movimiento (sufijo de versión de SP)_
  - _carga manual (sufijo de versión de SP)_
  - _carga SOE â€” Soporte Operativo EmpresaNet; confirmado por SME, cuenta y token_

### 19. `status` — estatus

- **Categoría**: ENTIDAD | **Estado**: conf | **Frecuencia en SPs**: 63
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV, TESOFE
- **Contexto de journeys**:
  - _actualiza dicta â€” dictamen, estatus y alerta_
  - _consulta catálogo, estatus y Billetes y Monedas_
  - _cambio, estatus, token y BEI â€” Banca En Internet; canal digital principal de BanCoppel; base de da_

### 20. `cjunk` — variable temporal (ruido de código, se ignora)

- **Categoría**: AMBIGUO | **Estado**: gap | **Frecuencia en SPs**: 61
- **Oportunidades**: contexto-journey, contexto-regulatorio
- **Reguladores relevantes detectados**: CNBV
- **Contexto de journeys**:
  - _determina lÃ­nea de crÃ©dito y tc â€” Tarjeta de CrÃ©dito_
  - _califica scoring crediticio_
  - _califica scoring crediticio_

---

_Generado por `generators/analyze-vocab-enrichment.py` · SPE-AM-001 · 2026-08-04_