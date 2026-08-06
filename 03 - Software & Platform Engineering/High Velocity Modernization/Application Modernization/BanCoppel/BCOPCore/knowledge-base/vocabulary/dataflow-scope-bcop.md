# BCOPCore - Scope del Vocabulario (10 tipos)

> **Corpus:** 3,738 SPs analizados  
> **Identificadores:** AIN=21,360  AOUT=103,950  BDR=15,067  BDW=4,247  LOC=83,391  LC=5,914  CUR=192  EXC=921

## Distribucion por tipo de scope

| Tipo | N | Descripcion |
|------|--:|-------------|
| **PERSISTE-BD** | 103 | El BC que escribe es el OWNER. Contrato de datos del microservicio. |
| **LECTURA-BD** | 14 | Consume datos ajenos. Patron de query en el target. |
| **INTERFAZ-IN** | 24 | Parametro de entrada. Define el request contract. |
| **INTERFAZ-OUT** | 157 | Variable de RETURN. Define el response contract. |
| **EFIMERA-CALCULO** | 5 | Variable local aritmetica. Aqui vive la regla de negocio. |
| **EFIMERA** | 63 | Variable local auxiliar. Detalle de implementacion. |
| **EXCEPCION** | 1 | Variable de error. Define el error model del microservicio. |
| **MIXTO** | 245 | Multiples roles. Requiere analisis de desambiguacion. |
| — (sin senal) | 115 | No aparece en ningun SP del corpus |

---

## BD — escritura — PERSISTE-BD (103 terminos)

El BC que escribe es el OWNER. Contrato de datos del microservicio.

| Termino | Significado | BDR | BDW | API |
|---------|-------------|----:|----:|----:|
| `sac` | Servicios de Atención al Cliente — subsistema de atención en sucursal (ventanilla, domiciliación, abonos ATM, remesas WU); base de datos propia bdisac: con tabla sac_movimientoshistorial; confirmado por SME (2026-08-02) | 666 | 171 | 44 |
| `crd` | crédito (abreviación) | 820 | 181 | 15 |
| `bitacora` | bitácora | 278 | 277 | 6 |
| `sdos` | saldos (abreviación) | 383 | 86 | 6 |
| `detalle` | detalle | 224 | 135 | 57 |
| `solicitudes` | solicitudes (plural) | 264 | 136 | 34 |
| `acl` | familia aclaraciones | 229 | 64 | 28 |
| `cce` | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — sistema de compensación interbancaria de cheques; SPs: sp_cce_consultar_cheques40/46, chequespresentados (bdicheq) | 192 | 96 | 8 |
| `tef` | TEF — transferencia electrónica de fondos | 124 | 72 | 56 |
| `movhis` | Movimientos Históricos — tabla/proceso de historial de movimientos (bdicheq:arrmovhis, borra_movhis; bdicred:carga_movhis_edoctacrd) | 247 | 7 | 0 |
| `tbl` | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | 170 | 80 | 5 |
| `telefonos` | teléfonos | 212 | 21 | 0 |
| `ctes` | clientes | 128 | 45 | 24 |
| `direcciones` | direcciones | 148 | 21 | 19 |
| `his` | histórico | 69 | 56 | 16 |
| `indicador` | indicador — marcador de estado o condición (sp_ambientar_indicador_*, sp_actualiza_indicadorcred) | 91 | 31 | 35 |
| `ics` | ICS — sistema de cuotas/mensualidades de crédito (sp_ics_cuotas, sp_ics_compara_secuencias, sp_ics_genera_control — bdicred) | 10 | 148 | 2 |
| `admin` | Administrador — rol de usuario con privilegios administrativos (pIdAdmin INTEGER en bdibei/bdibpi); también administración de tasas y procesos | 47 | 51 | 56 |
| `clientes` | clientes (plural) | 110 | 48 | 4 |
| `bts` | Bancomer Transfer Services — canal de transferencias BBVA; base de datos propia bdibts; confirmado por SME (2026-08-02) | 71 | 30 | 27 |

---

## BD — lectura — LECTURA-BD (14 terminos)

Consume datos ajenos. Patron de query en el target.

| Termino | Significado | BDR | BDW | API |
|---------|-------------|----:|----:|----:|
| `empresas` | empresas (nómina empresarial) | 69 | 0 | 5 |
| `circulo` | Círculo de Crédito — buró de crédito para personas físicas (México) | 18 | 0 | 4 |
| `divisas` | divisas | 12 | 0 | 0 |
| `conciliachq` | conciliación de cheques | 6 | 0 | 0 |
| `factelect` | Factura Electrónica / CFDI | 5 | 0 | 0 |
| `concreing` | Conciliación de Reingresos — proceso de conciliación de tarjetas reingresadas (bditarjeta:sp_concreing_*; gestiona archivos ATM, usuarios, horarios, parámetros) | 3 | 0 | 0 |
| `acuerdo` | acuerdo de pago — convenio de cobranza con el cliente (sp_grabacompromisosacuerdos) | 3 | 0 | 0 |
| `corresponsal` | corresponsal | 2 | 0 | 0 |
| `mesas` | Mesas de Control — equipo de revisión y autorización de solicitudes de crédito (plural de Mesa de Control) | 2 | 0 | 0 |
| `ctemoral` | ctemoral — cuenta temporal (sp_guarda*ctemoral — bdicnweb) | 2 | 0 | 0 |
| `combo` | combo / lista desplegable (control de UI en app) | 1 | 0 | 0 |
| `alertas` | alertas | 1 | 0 | 0 |
| `ordenes` | órdenes | 1 | 0 | 0 |
| `stat06` | Stat06 — tipo/código de archivo de carga en procesamiento de tarjetas Coppel (bditarjeta:sp_cnc_cga_stat06; parámetros: ruta, nombre archivo, sistema, layout) | 1 | 0 | 0 |

---

## API entrada — INTERFAZ-IN (24 terminos)

Parametro de entrada. Define el request contract.

| Termino | Significado | AIN | AOUT | BD |
|---------|-------------|----:|-----:|---:|
| `usuario` | usuario | 2518 | 825 | 90 |
| `idfuncion` | id de funcionalidad | 2128 | 37 | 0 |
| `fechafin` | fecha fin | 295 | 38 | 0 |
| `consulta` | consulta / lee | 111 | 31 | 96 |
| `fechainicio` | fecha inicio | 182 | 48 | 0 |
| `puntos` | puntos (recompensas) | 84 | 52 | 8 |
| `fechainicial` | fecha inicial | 94 | 7 | 0 |
| `fechafinal` | fecha final | 99 | 7 | 0 |
| `ejecucion` | ejecución (de proceso) | 92 | 24 | 0 |
| `descarga` | descarga | 102 | 33 | 0 |
| `opcion` | opción | 58 | 39 | 6 |
| `busqueda` | búsqueda | 55 | 15 | 3 |
| `fechaconsulta` | fecha de consulta | 28 | 13 | 0 |
| `titulo` | título | 36 | 0 | 0 |
| `traspas` | traspaso | 16 | 0 | 14 |
| `parametrico` | paramétrico — parametrización de modelos (envío paramétrico) | 5 | 0 | 21 |
| `claverastreo` | clave de rastreo SPEI (hasta 30 posiciones alfanuméricas, Banxico) | 13 | 11 | 0 |
| `remesadora` | remesadora (envío de remesas) | 11 | 0 | 15 |
| `nombreref` | nombre de referencia | 16 | 0 | 0 |
| `gdf` | gdf — código geográfico / Gobierno CDMX (abreviación — bdisac) | 8 | 0 | 11 |

---

## API salida — INTERFAZ-OUT (157 terminos)

Variable de RETURN. Define el response contract.

| Termino | Significado | AIN | AOUT | BD |
|---------|-------------|----:|-----:|---:|
| `cod` | código | 365 | 19802 | 52 |
| `nombre` | nombre | 375 | 4601 | 11 |
| `desc` | [polisemia] Descripción (sp_desc_ret: devuelve descripción del código de retorno) | Descarga (sp_desc_archivos_cfdi/conc: descarga archivos CFDI y conciliación) | 59 | 2650 | 67 |
| `sucursal` | sucursal | 453 | 2036 | 355 |
| `cuenta` | cuenta | 324 | 2592 | 122 |
| `mensaje` | mensaje | 21 | 2414 | 25 |
| `cliente` | cliente | 139 | 970 | 627 |
| `descripcion` | descripción | 44 | 1470 | 0 |
| `producto` | producto | 162 | 1015 | 212 |
| `tarjeta` | tarjeta | 81 | 429 | 555 |
| `codigo` | código | 86 | 855 | 9 |
| `fechas` | fechas | 7 | 280 | 702 |
| `param` | parámetro | 34 | 104 | 825 |
| `solicitud` | solicitud | 81 | 468 | 262 |
| `cve` | clave (cve) | 97 | 701 | 1 |
| `cantidad` | cantidad | 159 | 685 | 0 |
| `clave` | clave | 70 | 701 | 11 |
| `operacion` | operación | 117 | 564 | 12 |
| `motivo` | motivo / causa | 47 | 551 | 17 |
| `cat` | catálogo | 8 | 233 | 522 |

---

## Efimera calculo — EFIMERA-CALCULO (5 terminos)

Variable local aritmetica. Aqui vive la regla de negocio.

| Termino | Significado | LC (calculo) | LOC | Trans |
|---------|-------------|-------------:|----:|------:|
| `generar` | generar (infinitivo — sp_generarbalanza*) | 2 | 2 | 1 |
| `pasa` | pasa / mueve (verbo — pasamovshist* — archiva movimientos a histórico) | 2 | 2 | 0 |
| `dicta` | dicta — dictamen / subsistema de dictaminación (sp_dicta_* — bdinteg fan_in=268+) | 2 | 1 | 0 |
| `calcular` | calcula (infinitivo) | 1 | 0 | 0 |
| `proyeccion` | proyección de cartera / saldo | 1 | 0 | 0 |

---

## Efimera — EFIMERA (63 terminos)

Variable local auxiliar. Detalle de implementacion.

| Termino | Significado | Total |
|---------|-------------|------:|
| `cap` | Captación — cuentas de ahorro/depósito; evidencia: sp_cap_genrepcancelacioncuentascaptacion, nCtaCap, recalculagat1200 (GAT = Ganancia Anual Total regulado por Banxico) | 2121 |
| `mes` | mes | 1591 |
| `venc` | vencimiento | 1316 |
| `cre` | crédito | 1226 |
| `hoy` | de hoy / fecha actual | 978 |
| `max` | máximo | 817 |
| `info` | información | 719 |
| `pagos` | pagos (plural) | 411 |
| `ccl` | módulo de Cédulas de Captación e inversión — pagaré, ISR, saldos diarios, inversión auto-creciente (bdicnweb:sp_ccl_*) | 359 |
| `cpl` | CPL — segmento o producto de cliente (sp_dictamina_ctes_cpl, sp_afore_ctes_cpl, sp_situacionespecialcte_cpl — bdinteg) | 262 |
| `situacion` | situación | 220 |
| `valida` | valida | 216 |
| `correo` | correo electrónico | 213 |
| `deb` | débito | 181 |
| `lin` | línea (de crédito) | 178 |
| `gral` | general | 177 |
| `numcred` | número de crédito | 171 |
| `arr` | ARR — producto de ahorro/inversión recurrente (CLABE, interés acumulado, inversión creciente, pago de interés — bdicheq:arr_*) | 152 |
| `realiza` | realiza / ejecuta una operación SPEI | 142 |
| `spei` | familia SPEI (pagos interbancarios) | 123 |

---

## Excepcion — EXCEPCION (1 terminos)

Variable de error. Define el error model del microservicio.

| Termino | Significado | Total |
|---------|-------------|------:|
| `graba` | graba / almacena | 23 |

---

## Mixto — MIXTO (245 terminos)

Multiples roles. Requiere analisis de desambiguacion.

| Termino | Significado | Total |
|---------|-------------|------:|
| `fecha` | fecha | 11476 |
| `num` | número (de) | 7850 |
| `tipo` | tipo de | 4538 |
| `status` | estatus | 4382 |
| `total` | total | 4144 |
| `monto` | monto | 3991 |
| `registros` | registros | 3698 |
| `int` | interés | 3573 |
| `nom` | nómina | 3185 |
| `cte` | cliente | 3080 |
| `pago` | pago | 2949 |
| `cta` | cuenta | 2874 |
| `folio` | folio | 2618 |
| `error` | error | 2493 |
| `act` | actualiza | 2454 |
| `iva` | IVA (impuesto — SAT) | 2304 |
| `cred` | crédito | 2286 |
| `numcte` | número de cliente | 2156 |
| `sdo` | saldo | 2155 |
| `empresa` | empresa (entidad bancaria) | 2112 |

---

## Uso en la arquitectura target

| Scope | Implicacion en el microservicio target |
|-------|----------------------------------------|
| PERSISTE-BD    | El bounded context que escribe este dato es el OWNER. Va en el esquema del microservicio. |
| LECTURA-BD     | El microservicio lee datos de otro BC. Candidato a query via API del BC owner, no schema propio. |
| INTERFAZ-IN    | Entra en el request DTO. Debe tener un nombre canonico en el target (target_term). |
| INTERFAZ-OUT   | Sale en el response DTO. Idem — nombre canonico requerido. |
| BATCH          | Proceso offline — candidato a job separado (Lambda / Cloud Run Job) con su propio schema. |
| CURSOR         | Implementacion — no necesita superficie en el API contract. |
| EFIMERA-CALCULO| Regla de negocio interna. Preservar la formula (golden master). No en el contrato. |
| EFIMERA        | Detalle de implementacion — puede reescribirse libremente en el target. |
| EXCEPCION      | Error model del microservicio. Debe mapearse a HTTP status + ProblemDetail RFC 9457. |
| MIXTO          | Analizar por contexto de SP. Posible necesidad de desambiguacion en el modelo de dominio. |

*Generado por extract-dataflow.py v2 - 10 tipos de scope*