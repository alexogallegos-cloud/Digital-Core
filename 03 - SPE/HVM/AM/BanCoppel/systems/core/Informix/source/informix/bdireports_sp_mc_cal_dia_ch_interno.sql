CREATE PROCEDURE "informix".sp_mc_cal_dia_ch_interno(dFecha DATE,cTrimestre CHAR(5), 
                                             iMes INTEGER, iClaveTarjeta SMALLINT)
       RETURNING CHAR (5), CHAR(500);

/*
#############################################################################%
#   Autor: L. Montserrat León Amador                                         %
#   Fecha: 02/10/2017                                                        %
#   Modificación: Se crea clon de spl sp_mc_cal_dia_ch para realizar         %
#				  ejecuciones por separado correspondientes a los            %
#    			  productos: Platino y Oro.                                  %
#    			                                                             %
#    			  Dónde iClaveTarjeta = 9 corresponderá al producto Platino, %
#    			  y iClaveTarjeta = 10 corresponderá al producto Oro.        %
#############################################################################%
*/

--MANEJO DE ERRORES
DEFINE iSqlErr                    INTEGER;
DEFINE cVarDataErr                CHAR(500);
DEFINE cVarDataErr1               CHAR(100);
DEFINE cVarDataErr9               CHAR(100);
DEFINE cVarDataErr10              CHAR(100);
DEFINE cVarDataErr11              CHAR(100);
DEFINE cVarDataErr12              CHAR(100);
DEFINE cVarDataErr13              CHAR(100);
DEFINE cVarDataErr14              CHAR(100);
DEFINE cVarDataErr15              CHAR(100);
DEFINE cVarDataErr16              CHAR(100);
DEFINE cVarDataErr17              CHAR(100);

DEFINE cCodret                    CHAR(5);

--GENERALES
DEFINE cNumProducto               CHAR(4);
DEFINE cCodFila                   CHAR(3);
DEFINE cNombreArc                 CHAR(24);
DEFINE cFecha1                    CHAR(50);
DEFINE cFecha2                    CHAR(50);
DEFINE vAnio                      CHAR(02);

DEFINE dFechaAtmInicio            DATETIME YEAR TO FRACTION (5);
DEFINE dFechaAtmInicio1           DATETIME YEAR TO FRACTION (3);

DEFINE dFechaAtmFin               DATETIME YEAR TO FRACTION (5);
DEFINE dFechaAtmFin1              DATETIME YEAR TO FRACTION (3);

DEFINE dFechaInicio               DATETIME YEAR TO FRACTION (5);
DEFINE dFechaFin                  DATETIME YEAR TO FRACTION (5);

DEFINE CtipoCompra                VARCHAR(60);
DEFINE CtipoTransaccion           VARCHAR(60);
DEFINE CtipoDevolucion            VARCHAR(60);
DEFINE cEstatus                   CHAR(01);


--COMPRAS NACIONALES
DEFINE V_tot_compras_o_pos        INTEGER;
DEFINE V_monto_compras_o_pos      MONEY(16,2);
DEFINE V_tot_compras_o_pos2       INTEGER;
DEFINE V_monto_compras_o_pos2     MONEY(16,2);

--COMPRAS INTERNACIONALES
DEFINE V_tot_compras_internal     INTEGER;
DEFINE V_monto_compras_internal   MONEY(16,2);
DEFINE V_tot_compras_internal2    INTEGER;
DEFINE V_monto_compras_internal2  MONEY(16,2);

--TRANSACCIONES DE EFECTIVO EN ATM's
DEFINE V_tot_tran_efe_atm         INTEGER;
DEFINE V_monto_tran_efe_atm       MONEY(16,2);
DEFINE V_tot_tran_efe_atm2        INTEGER;
DEFINE V_monto_tran_efe_atm2      MONEY(16,2);

--TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES EN OTROS BANCOS
DEFINE V_tot_tran_efe_atm_np      INTEGER;
DEFINE V_monto_tran_efe_atm_np    MONEY(16,2);
DEFINE V_tot_tran_efe_atm_np2     INTEGER;
DEFINE V_monto_tran_efe_atm_np2   MONEY(16,2);

--TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES FUERA DE SU PAÍS
DEFINE V_tot_tran_efe_atm_in      INTEGER;
DEFINE V_monto_tran_efe_atm_in    MONEY(16,2);
DEFINE V_tot_tran_efe_atm_in2     INTEGER;
DEFINE V_monto_tran_efe_atm_in2   MONEY(16,2);

--DEVOLUCIONES EN COMPRAS DE MIS TARJETAHABIENTES DENTRO DEL PAÍS
DEFINE V_tot_dev_nal              INTEGER;
DEFINE V_monto_dev_nal            MONEY(16,2);
DEFINE V_tot_dev_nal2             INTEGER;
DEFINE V_monto_dev_nal2           MONEY(16,2);

--DEVOLUCIONES EN COMPRAS DE MIS TARJETAHABIENTES FUERA DEL PAÍS
DEFINE V_tot_dev_internal         INTEGER;
DEFINE V_monto_dev_internal       MONEY(16,2);
DEFINE V_tot_dev_internal2        INTEGER;
DEFINE V_monto_dev_internal2      MONEY(16,2);

--TRANSACCIONES DE ADQUIRENCIA NACIONAL
DEFINE V_tot_adq_nal              INTEGER;
DEFINE V_monto_adq_nal            MONEY(16,2);
DEFINE V_tot_adq_nal2             INTEGER;
DEFINE V_monto_adq_nal2           MONEY(16,2);

--TRANSACCIONES DE ADQUIRENCIA INTERNACIONAL
DEFINE V_tot_adq_internal         INTEGER;
DEFINE V_monto_adq_internal       MONEY(16,2);
DEFINE V_tot_adq_internal2        INTEGER;
DEFINE V_monto_adq_internal2      MONEY(16,2);

--TIPO DE PRODUCTO DE LA TABLA PARAMETRO
DEFINE Vtipo                      CHAR(01);

--DIAS PENDIENTES DE EJECUTAR
DEFINE cDiasPendientes            SMALLINT;

--DIAS PENDIENTES
DEFINE Vtotal_diasP               SMALLINT;
DEFINE Vflag                      SMALLINT;

--NOMBRE DE TABLA
DEFINE Vnom_tabla                 VARCHAR(20);

--VALIDACION DE EXISTENCIA DE DATOS
DEFINE Vhay_datos                 INTEGER;

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO
DEFINE Vbin 					  CHAR(6); 
--DEFINE Vclavetarjeta 			  SMALLINT;

ON EXCEPTION SET iSqlErr

   --SET DEBUG FILE TO "/home/sysdecli/sp_mc_cal_dia_ch_interno.err";
   IF iSqlErr <> 0 THEN
      LET cVarDataErr = cVarDataErr||'ERROR NO CONTROLADO (' || iSqlErr || ').';
      LET cCodret='-1';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
              VALUES ('sp_mc_cal_dia_ch',iMes,dFecha,'', 0 ,cVarDataErr);
      RETURN cCodret, cVarDataErr;
   END IF;

END EXCEPTION;

--SET DEBUG FILE TO "sp_mc_cal_dia_ch_interno.out";
--TRACE ON;
--SET DEBUG FILE TO "/tmp/mfinis/sp_mc_cal_dia_ch_interno.out";
--TRACE ON;

--- VARIABLES COMPRAS NACIONALES ---
LET V_tot_compras_o_pos = 0;
LET V_monto_compras_o_pos = 0.00;
LET V_tot_compras_o_pos2 = 0;
LET V_monto_compras_o_pos2 = 0.00;

--- VARIABLES COMPRAS INTERNACIONALES ---
LET V_tot_compras_internal = 0;
LET V_monto_compras_internal = 0.00;
LET V_tot_compras_internal2 = 0;
LET V_monto_compras_internal2 = 0.00;

--- VARIABLES TRANSACCIONES DE EFECTIVO EN ATM's ---
LET V_tot_tran_efe_atm = 0;
LET V_monto_tran_efe_atm = 0;
LET V_tot_tran_efe_atm2 = 0;
LET V_monto_tran_efe_atm2 = 0;

--- VARIABLES TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES EN OTROS BANCOS ---
LET V_tot_tran_efe_atm_np = 0;
LET V_monto_tran_efe_atm_np = 0.00;
LET V_tot_tran_efe_atm_np2 = 0;
LET V_monto_tran_efe_atm_np2 = 0.00;

--- VARIABLES TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES FUERA DE SU PAÍS ---
LET V_tot_tran_efe_atm_in = 0;
LET V_monto_tran_efe_atm_in = 0.00;
LET V_tot_tran_efe_atm_in2 = 0;
LET V_monto_tran_efe_atm_in2 = 0.00;

--- VARIABLES DEVOLUCIONES EN COMPRAS DE MIS TARJETAHABIENTES DENTRO DEL PAÍS ---
LET V_tot_dev_nal = 0;
LET V_monto_dev_nal = 0.00;
LET V_tot_dev_nal2 = 0;
LET V_monto_dev_nal2 = 0.00;

--- VARIABLES DEVOLUCIONES EN COMPRAS DE MIS TARJETAHABIENTES FUERA DEL PAÍS ---
LET V_tot_dev_internal = 0;
LET V_monto_dev_internal = 0.00;
LET V_tot_dev_internal2 = 0;
LET V_monto_dev_internal2 = 0.00;

--- VARIABLES TRANSACCIONES DE ADQUIRENCIA NACIONAL
LET V_tot_adq_nal = 0;
LET V_monto_adq_nal = 0.00;

-- VARIABLES TRANSACCIONES DE ADQUIRENCIA INTERNACIONAL
LET V_tot_adq_internal = 0;
LET V_monto_adq_internal = 0.00;

LET cCodret = '00000';
LET cVarDataErr = '';
LET cVarDataErr1 = '';
LET cVarDataErr9 = '';
LET cVarDataErr10 = '';
LET cVarDataErr11 = '';
LET cVarDataErr12 = '';
LET cVarDataErr13 = '';
LET cVarDataErr13 = '';
LET cVarDataErr14 = '';
LET cVarDataErr15 = '';
LET cVarDataErr16 = '';
LET cVarDataErr17 = '';

LET cNombreArc = '';
LET CtipoCompra = '';
LET Vtipo = '';
LET cDiasPendientes = 0;
LET cEstatus = '';

LET cFecha1 = YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha-1), 2, '0') || '-' ||
              LPAD ( DAY (dFecha-1), 2, '0') || ' 00:00:00.0';

LET dFechaAtmInicio = CAST (cFecha1 AS DATETIME year to fraction(5));
LET dFechaAtmInicio1 = CAST (cFecha1 AS DATETIME year to fraction(3));

LET dFechaInicio = CAST (cFecha1 AS DATETIME year to fraction(5));

LET cFecha2 = YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
              LPAD ( DAY (dFecha), 2, '0') || ' 23:59:59.0';

LET dFechaAtmFin = CAST (cFecha2 AS DATETIME year to fraction(5));
LET dFechaAtmFin1 = CAST (cFecha2 AS DATETIME year to fraction(3));

LET dFechaFin = CAST (cFecha2 AS DATETIME year to fraction(5));
LET vAnio = cFecha1[3,4];

LET Vtotal_diasP = 0;
LET Vflag = 0;

LET Vnom_tabla = '';
LET Vhay_datos = 0;

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO
--LET Vclavetarjeta = 9;

----------------------------------------
--- ACTIVIDAD DE TARJETAS DE CRÉDITO ---
----------------------------------------

--- SELECCION DEL PRODUCTO DE LA TABLA DE PARAMETROS ---
--- NOTA: PARA TODOS LOS CONCEPTOS SE QUEDA EL MISMO  NUM_PRODUCTO ---

SET ISOLATION TO DIRTY READ;
SELECT valor
  INTO cNumProducto
  FROM bdireports:rpt_mc_param
 WHERE tipo = 'C'
   AND marca = 'MC'
   AND id_param = (CASE WHEN iClaveTarjeta = 9 THEN 2 WHEN iClaveTarjeta = 10 THEN 4 END);

------------------------------------
--- CONSULTA EL TIPO DE PRODUCTO ---
------------------------------------
--- DONDE EL BIN 554948 HACE REFERENCIA A TARJETAS DE CRÉDITO PLATINO Y 510148 A LAS TARJETAS DE CRÉDITO ORO ---

SET ISOLATION TO DIRTY READ;
SELECT bin
INTO Vbin
FROM intercard:tipotarjeta
WHERE clave_tipotarjeta = iClaveTarjeta;

---------------------------
--- COMPRAS NACIONALES  ---
---------------------------

LET cCodFila = 'CNC';
LET CtipoCompra = 'COMPRAS NACIONALES EN OTROS POS';

   LET cNombreArc  = 'BCPLVNC_'||LPAD(DAY(dFecha),2,'0')||
                      LPAD(MONTH(dFecha),2,'0')||YEAR(dFecha)||'.txt';


   --- TRANSACCIONES DE COMPRAS DE MIS TARJETAHABIENTES ---
   ---- DENTRO DEL PAÍS EN OTROS POS ---
   SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), SUM((Monto325::MONEY)/100)
     INTO V_tot_compras_o_pos, V_monto_compras_o_pos
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND movreversado = 'F'
      AND movconciliado = 'V'
      AND ban_bin = 'MCR'
	  AND left(numtarjeta,6)=Vbin
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru where numtarjeta is not null)
      AND secuencia_extendida IN (SELECT secuenciaextendida
                                    FROM intercard:movimientohistorico
                                   WHERE fechahorainauth >= dFechaAtmInicio
                                     AND fechahorainauth <= dFechaAtmFin
                                     AND prodind = '02'
                                     AND codigoiso = '00'
                                     AND esnacional = 'V'
                                     AND trancajeropropio = 'F'
                                     AND transaccionorigen = '1234'
                                     AND formato <> '0420'
                                     AND codtran = '00');

   --# VALIDACION PARA SABER SI HAY DIAS PENDIENTES DEL CALCULO DIARIO #--
   SELECT COUNT(*)
     INTO Vtotal_diasP
     FROM bdireports:rpt_param_reportevisa
    WHERE ultimo_mes = iMes
      AND ultima_actualizacion = dFecha
      AND ultimo_error[1,5] = '00009'
      AND dias_pendientes = 1;

   ---# VALIDACIÓN DE ARCHIVO EXISTENTE PERO CONTENIDO CERO #---
   IF V_tot_compras_o_pos = 0 AND V_monto_compras_o_pos = 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00009';
      LET cVarDataErr9 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;

   IF V_tot_compras_o_pos <> 0 AND V_monto_compras_o_pos <> 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00000';
      LET cVarDataErr9 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'||
                          trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;

   ---ACT. DE TABLA DE PARAMETROS PARA QUITAR LOS DIAS PENDIENTES --
   IF Vflag = 1 THEN
         UPDATE bdireports:rpt_param_reportevisa
            SET dias_pendientes = 0,
                estatus_actualizacion= 'C',
                ultimo_error = cCodret||cVarDataErr9
          WHERE nom_tabla = 'sp_mc_cal_dia_c'
            AND ultimo_mes = iMes
            AND ultima_actualizacion = dFecha
            AND ultimo_error[1,5] = '00009';
   END IF;

   --- ACTUALIZACION DEL REGISTRO CON LOS DATOS LEIDOS DE LA HISTÓRICA ---
   IF V_monto_compras_o_pos IS NULL THEN
      LET V_monto_compras_o_pos = 0.00;
   END IF;
   
   --- VALIDACIÓN DE TOTALES CUANDO LA SECUENCIA EXTENDIDA AÚN NO ---
   --- SE ENCUENTRA EN MOVIMIENTO HISTÓRICO ---
   SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), NVL(SUM((Monto325::MONEY)/100),0)
     INTO V_tot_compras_o_pos2, V_monto_compras_o_pos2
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND movreversado = 'F'
      AND movconciliado = 'V'
      AND ban_bin = 'MCR'
	  AND left(numtarjeta,6)=Vbin
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru where numtarjeta is not null);

   IF V_tot_compras_o_pos2 > V_tot_compras_o_pos THEN 
      LET V_tot_compras_o_pos = V_tot_compras_o_pos2;
      LET V_monto_compras_o_pos = V_monto_compras_o_pos2;
   END IF;
      
   --- SÓLO SE ACTUALIZAN TOTALES CUANDO SEAN DIFERENTES DE CERO ---
      IF V_monto_compras_o_pos <> 0 THEN
      UPDATE bdireports:rpt_mc_vol_dia
         SET total_compras = V_tot_compras_o_pos,
             monto_compras = V_monto_compras_o_pos
       WHERE num_producto = cNumProducto
         AND trimestre = ctrimestre
         AND id_col = cCodFila
         AND mes = iMes
         AND fecha_reg = dFecha;
      LET cCodret = '00009';
      LET cVarDataErr9 = '.ACTUALIZA DATO: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'.';
   END IF;


-------------------------------
--- COMPRAS INTERNACIONALES ---
-------------------------------
LET cCodFila = 'CIC';
LET CtipoCompra = 'COMPRAS INTERNACIONALES CREDITO';

LET cNombreArc  = 'BCPLMCC_'||LPAD(DAY(dFecha),2,'0')||
                   LPAD(MONTH(dFecha),2,'0')||YEAR(dFecha)||'.txt';

   --- TRANSACCIONES DE COMPRAS DE MIS TARJETAHABIENTES FUERA DEL PAÍS ---
   SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), SUM((monto325::MONEY)/100)
     INTO V_tot_compras_internal, V_monto_compras_internal
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND ban_bin = 'MCR'
      AND movreversado = 'F'
      AND movconciliado = 'V'
	  AND left(numtarjeta,6)=Vbin
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru where numtarjeta is not null)
      AND secuencia_extendida IN (SELECT secuenciaextendida
                                    FROM intercard:movimientohistorico
                                   WHERE fechahorainauth >= dFechaAtmInicio
                                     AND fechahorainauth <= dFechaAtmFin
                                     AND prodind = '02'
                                     AND codigoiso = '00'
                                     AND esnacional = 'F'
                                     AND trancajeropropio = 'F'
                                     AND transaccionorigen = '1234'
                                     AND formato <> '0420'
                                     AND codtran = '00');

   --# VALIDACION PARA SABER SI HAY DIAS PENDIENTES DEL CALCULO DIARIO #--
   SELECT COUNT(*)
     INTO Vtotal_diasP
     FROM bdireports:rpt_param_reportevisa
    WHERE ultimo_mes = iMes
      AND ultima_actualizacion = dFecha
      AND ultimo_error[1,5] = '00010'
      AND dias_pendientes = 1;

   ---# VALIDACIÓN DE ARCHIVO EXISTENTE PERO CONTENIDO CERO #---
   IF V_tot_compras_internal = 0 AND V_monto_compras_internal = 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00010';
      LET cVarDataErr10 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      IF Vtotal_diasP = 0 THEN
         LET cDiasPendientes = 0;
         LET cEstatus = 'C';
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus,
                        cDiasPendientes, cCodret||cVarDataErr10);
      ELSE
      ---ACT. DE TABLA DE PARAMETROS PARA QUITAR LOS DIAS PENDIENTES --
         UPDATE bdireports:rpt_param_reportevisa
            SET dias_pendientes = 0,
                estatus_actualizacion= 'C',
                ultimo_error = cCodret||cVarDataErr10
          WHERE nom_tabla = 'sp_mc_cal_dia_c'
            AND ultimo_mes = iMes
            AND ultima_actualizacion = dFecha
            AND ultimo_error[1,5] = '00010';
      END IF;
   END IF;

   ---# VALIDACIÓN DE ARCHIVO INEXISTENTE #---
   IF V_monto_compras_internal IS NULL THEN
      LET Vflag = 0;
      LET cCodret = '00010';
      IF Vtotal_diasP = 0 THEN
         LET cVarDataErr10 = '.ARCHIVO INEXISTENTE: '|| trim(cCodFila)|| ','||
                             trim(cNumProducto)||','|| dFecha ||'. ';
         LET cDiasPendientes = 1;
         LET cEstatus = 'P';
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus, cDiasPendientes,
                       cCodret||cVarDataErr10);
       END IF;
   END IF;


   --- ACTUALIZACION DEL REGISTRO CON LOS DATOS LEÍDOS DE LA HISTÓRICA ---
   IF V_monto_compras_internal IS NULL THEN
      LET  V_monto_compras_internal = 0.00;
   END IF;
   
   --- VALIDACIÓN DE TOTALES CUANDO LA SECUENCIA EXTENDIDA AÚN NO ---
   --- SE ENCUENTRA EN MOVIMIENTO HISTÓRICO ---
   SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), NVL(SUM((monto325::MONEY)/100),0)
     INTO V_tot_compras_internal2, V_monto_compras_internal2
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND ban_bin = 'MCR'
      AND movreversado = 'F'
      AND movconciliado = 'V'
	  AND left(numtarjeta,6)=Vbin
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru where numtarjeta is not null);
   
   IF V_tot_compras_internal2 > V_tot_compras_internal THEN
      LET V_tot_compras_internal = V_tot_compras_internal2;
      LET V_monto_compras_internal = V_monto_compras_internal2;
   END IF;
   
   --- SÓLO SE ACTUALIZAN TOTALES CUANDO SEAN DIFERENTES DE CERO ---
   IF V_monto_compras_internal <> 0 THEN
      UPDATE bdireports:rpt_mc_vol_dia
         SET total_compras = V_tot_compras_internal,
             monto_compras = V_monto_compras_internal
       WHERE num_producto = cNumProducto
         AND trimestre = ctrimestre
         AND id_col = cCodFila
         AND mes = iMes
         AND fecha_reg = dFecha;
      LET cCodret = '00010';
      LET cVarDataErr10 = '.ACTUALIZA DATO: '|| trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   END IF;

/*
--- TRANSACCIONES DE EFECTIVO EN ATM's ---
------------------------------------------------------------------------
--- TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES EN MIS BANCOS ---
------------------------------------------------------------------------
LET cCodFila = 'TEC';
LET CtipoTransaccion = 'ATM TRANSACCION EFECTIVO PROPIO';

   LET cNombreArc  = 'BCPL_ATMC_'||LPAD(DAY(dFecha-1),2,'0')||
                      LPAD(MONTH(dFecha-1),2,'0')||
                      ---YEAR(dFecha)||'.txt';
                      vAnio||'.txt';

   SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), SUM((monto325::MONEY)/100)
     INTO V_tot_tran_efe_atm, V_monto_tran_efe_atm
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND ban_bin = 'MCR'
      AND movreversado = 'F'
      AND movconciliado = 'V'
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru)
      AND secuencia_extendida IN (SELECT secuenciaextendida
                                    FROM intercard:movimientohistorico
                                   WHERE fechahorainauth >= dFechaAtmInicio
                                     AND fechahorainauth <= dFechaAtmFin
                                     AND prodind = '01'
                                     AND codigoiso = '00'
                                     AND esnacional = 'V'
                                     AND trancajeropropio = 'V'
                                     AND transaccionorigen = '1234'
                                     AND formato <> '0420'
                                     AND codtran = '01');


   --# VALIDACION PARA SABER SI HAY DIAS PENDIENTES DEL CALCULO DIARIO #--
   SELECT COUNT(*)
     INTO Vtotal_diasP
     FROM bdireports:rpt_param_reportevisa
    WHERE ultimo_mes = iMes
      AND ultima_actualizacion = dFecha
      AND ultimo_error[1,5] = '00011'
      AND dias_pendientes = 1;

   ---# VALIDACIÓN DE ARCHIVO EXISTENTE PERO CONTENIDO CERO #---
   IF V_tot_tran_efe_atm = 0 AND V_monto_tran_efe_atm = 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00011';
      LET cVarDataErr11 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      IF Vtotal_diasP = 0 THEN
         LET cDiasPendientes = 0;
         LET cEstatus = 'C';
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus, cDiasPendientes,
                        cCodret||cVarDataErr11);
      ELSE
      ---ACT. DE TABLA DE PARAMETROS PARA QUITAR LOS DIAS PENDIENTES --
         UPDATE bdireports:rpt_param_reportevisa
            SET dias_pendientes = 0,
                estatus_actualizacion= 'C',
                ultimo_error = cCodret||cVarDataErr11
          WHERE nom_tabla = 'sp_mc_cal_dia_c'
            AND ultimo_mes = iMes
            AND ultima_actualizacion = dFecha
            AND ultimo_error[1,5] = '00011';
      END IF;
   END IF;

   ---# VALIDACIÓN DE ARCHIVO INEXISTENTE #---
   IF V_monto_tran_efe_atm IS NULL THEN
      LET Vflag = 0;
      LET cCodret = '00011';
      LET cVarDataErr11= '.ARCHIVO INEXISTENTE: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      IF Vtotal_diasP = 0 THEN
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus, cDiasPendientes,
                       cCodret||cVarDataErr11);
      END IF;
   END IF;

   --- ACTUALIZACION DEL REGISTRO CON LOS DATOS LEÍDOS DE LA HISTÓRICA ---
   IF V_monto_tran_efe_atm IS NULL THEN
     LET V_monto_tran_efe_atm = 0.00;
   END IF;
   
--   --- VALIDACIÓN DE TOTALES CUANDO LA SECUENCIA EXTENDIDA AÚN NO ---
--   --- SE ENCUENTRA EN MOVIMIENTO HISTÓRICO ---
--   SET ISOLATION TO DIRTY READ;
--   SELECT COUNT(consecutivo), NVL(SUM((monto325::MONEY)/100),0)
--     INTO V_tot_tran_efe_atm2, V_monto_tran_efe_atm2
--     FROM bditarjeta:td_movimientos_conciliacion_his
--    WHERE nombrearchivo = cNombreArc
--      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
--      AND ban_bin = 'MCR'
--      AND movreversado = 'F'
--      AND movconciliado = 'V'
--      AND numtarjeta NOT IN (SELECT numtarjeta
--                               FROM bdireports:rpt_mc_tar_pru);
-- 
--   IF V_tot_tran_efe_atm2 > V_tot_tran_efe_atm THEN
--      LET V_tot_tran_efe_atm = V_tot_tran_efe_atm2;
--      LET V_monto_tran_efe_atm = V_monto_tran_efe_atm2;
--   END IF;
 
   --- SÓLO SE ACTUALIZAN TOTALES CUANDO SEAN DIFERENTES DE CERO ---
   IF V_monto_tran_efe_atm <> 0 THEN
      UPDATE bdireports:rpt_mc_vol_dia
         SET total_transacciones = V_tot_tran_efe_atm,
             monto_transacciones = V_monto_tran_efe_atm
       WHERE num_producto = cNumProducto
         AND trimestre = ctrimestre
         AND id_col = cCodFila
         AND mes = iMes
         AND fecha_reg = dFecha;
      LET cCodret = '00011';
      LET cVarDataErr11 = '.ACTUALIZA DATO: '|| trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'.';
   END IF;

--------------------------------------------------------------------------
--- TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES EN OTROS BANCOS ---
--------------------------------------------------------------------------
LET cCodFila = 'TEC';
LET CtipoTransaccion = 'ATM TRANSACCION EFECTIVO NO PROPIO';

   LET cNombreArc  = 'BCPL_ATMC_'||LPAD(DAY(dFecha-1),2,'0')||
                      LPAD(MONTH(dFecha-1),2,'0')||
                      ---YEAR(dFecha)||'.txt';
                      vAnio||'.txt';

  SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), SUM((monto325::MONEY)/100)
     INTO V_tot_tran_efe_atm_np, V_monto_tran_efe_atm_np
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND ban_bin = 'MCR'
      AND movreversado = 'F'
      AND movconciliado = 'V'
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru)
      AND secuencia_extendida IN (SELECT secuenciaextendida
                                    FROM intercard:movimientohistorico
                                   WHERE fechahorainauth >= dFechaAtmInicio
                                     AND fechahorainauth <= dFechaAtmFin
                                     AND prodind = '01'
                                     AND codigoiso = '00'
                                     AND esnacional = 'V'
                                     AND trancajeropropio = 'F'
                                     AND transaccionorigen = '1234'
                                     AND formato <> '0420'
                                     AND codtran = '01');

   --# VALIDACION PARA SABER SI HAY DIAS PENDIENTES DEL CALCULO DIARIO #--
   SELECT COUNT(*)
     INTO Vtotal_diasP
     FROM bdireports:rpt_param_reportevisa
    WHERE ultimo_mes = iMes
      AND ultima_actualizacion = dFecha
      AND ultimo_error[1,5] = '00012'
      AND dias_pendientes = 1;

   ---# VALIDACIÓN DE ARCHIVO EXISTENTE PERO CONTENIDO CERO #---
   IF V_tot_tran_efe_atm_np = 0 AND V_monto_tran_efe_atm_np = 0.00 THEN
      LET cCodret = '00012';
      LET cVarDataErr12 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      IF Vtotal_diasP = 0 THEN
         LET cDiasPendientes = 0;
         LET cEstatus = 'C';
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus,
                        cDiasPendientes ,cCodret||cVarDataErr12);
      ELSE
      ---ACT. DE TABLA DE PARAMETROS PARA QUITAR LOS DIAS PENDIENTES --
         UPDATE bdireports:rpt_param_reportevisa
            SET dias_pendientes = 0,
                estatus_actualizacion= 'C',
                ultimo_error = cCodret||cVarDataErr12
          WHERE nom_tabla = 'sp_mc_cal_dia_c'
            AND ultimo_mes = iMes
            AND ultima_actualizacion = dFecha
            AND ultimo_error[1,5] = '00012';
      END IF;
   END IF;

   ---# VALIDACIÓN DE ARCHIVO INEXISTENTE #---
   IF V_monto_tran_efe_atm_np IS NULL THEN
      LET Vflag = 0;
      LET cCodret = '00012';
      LET cVarDataErr12= '.ARCHIVO INEXISTENTE: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      IF Vtotal_diasP = 0 THEN
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus,
                        cDiasPendientes ,cCodret||cVarDataErr12);
      END IF;
   END IF;

   --- ACTUALIZACION DEL REGISTRO CON LOS DATOS LEÍDOS DE LA HISTÓRICA ---
   IF V_monto_tran_efe_atm_np IS NULL THEN
     LET  V_monto_tran_efe_atm_np = 0.00;
   END IF;
   
--   --- VALIDACIÓN DE TOTALES CUANDO LA SECUENCIA EXTENDIDA AÚN NO ---
--   --- SE ENCUENTRA EN MOVIMIENTO HISTÓRICO ---
--   SET ISOLATION TO DIRTY READ;
--   SELECT COUNT(consecutivo), NVL(SUM((monto325::MONEY)/100),0)
--     INTO V_tot_tran_efe_atm_np2, V_monto_tran_efe_atm_np2
--     FROM bditarjeta:td_movimientos_conciliacion_his
--    WHERE nombrearchivo = cNombreArc
--      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
--      AND ban_bin = 'MCR'
--      AND movreversado = 'F'
--      AND movconciliado = 'V'
--      AND numtarjeta NOT IN (SELECT numtarjeta
--                               FROM bdireports:rpt_mc_tar_pru);
--   
--   IF V_tot_tran_efe_atm_np2 > V_tot_tran_efe_atm_np THEN
--      LET V_tot_tran_efe_atm_np = V_tot_tran_efe_atm_np2;
--      LET V_monto_tran_efe_atm_np = V_monto_tran_efe_atm_np2;
--   END IF;
   
   --- SÓLO SE ACTUALIZAN TOTALES CUANDO SEAN DIFERENTES DE CERO ---
   IF V_monto_tran_efe_atm_np <> 0 THEN
      UPDATE bdireports:rpt_mc_vol_dia
         SET total_transacciones = V_tot_tran_efe_atm_np,
             monto_transacciones = V_monto_tran_efe_atm_np
       WHERE num_producto = cNumProducto
         AND trimestre = ctrimestre
         AND id_col = cCodFila
         AND mes = iMes
         AND fecha_reg = dFecha
         AND tipo_transaccion = cTipoTransaccion;
      LET cCodret = '00012';
      LET cVarDataErr12 = '.ACTUALIZA DATO: '|| trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'.';
   END IF;

---------------------------------------------------------------------------
--- TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES FUERA DE SU PAÍS ---
---------------------------------------------------------------------------
LET cCodFila = 'TEC';
LET CtipoTransaccion = 'ATM TRANSACCION EFECTIVO INTERNACIONAL';


   LET cNombreArc  = 'BCPL_ATMC_'||LPAD(DAY(dFecha-1),2,'0')||
                      LPAD(MONTH(dFecha-1),2,'0')||
                      ---YEAR(dFecha)||'.txt';
                      vAnio||'.txt';

   SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), SUM((monto325::MONEY)/100)
     INTO V_tot_tran_efe_atm_in, V_monto_tran_efe_atm_in
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND tipo_conciliacion IN (50,51,53,56)
      AND ban_bin = 'MCR'
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru)
      AND secuencia_extendida IN (SELECT secuenciaextendida
                                    FROM intercard:movimientohistorico
                                   WHERE fechahorainauth >= dFechaAtmInicio
                                     AND fechahorainauth <= dFechaAtmFin
                                     AND prodind = '01'
                                     AND codigoiso = '00'
                                     AND esnacional = 'F'
                                     AND trancajeropropio = 'F'
                                     AND transaccionorigen = '1234'
                                     AND formato <> '0420'
                                     AND codtran = '01');

   --# VALIDACION PARA SABER SI HAY DIAS PENDIENTES DEL CALCULO DIARIO #--
   SELECT COUNT(*)
     INTO Vtotal_diasP
     FROM bdireports:rpt_param_reportevisa
    WHERE ultimo_mes = iMes
      AND ultima_actualizacion = dFecha
      AND ultimo_error[1,5] = '00013'
      AND dias_pendientes = 1;

   ---# VALIDACIÓN DE ARCHIVO EXISTENTE PERO CONTENIDO CERO #---
   IF V_tot_tran_efe_atm_in = 0 AND V_monto_tran_efe_atm_in = 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00013';
      LET cVarDataErr13 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      IF Vtotal_diasP = 0 THEN
         LET cDiasPendientes = 0;
         LET cEstatus = 'C';
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus, cDiasPendientes,
                        cCodret||cVarDataErr13);
      ELSE
      ---ACT. DE TABLA DE PARAMETROS PARA QUITAR LOS DIAS PENDIENTES --
         UPDATE bdireports:rpt_param_reportevisa
            SET dias_pendientes = 0,
                estatus_actualizacion= 'C',
                ultimo_error = cCodret||cVarDataErr13
          WHERE nom_tabla = 'sp_mc_cal_dia_c'
            AND ultimo_mes = iMes
            AND ultima_actualizacion = dFecha
            AND ultimo_error[1,5] = '00013';
      END IF;
   END IF;

   ---# VALIDACIÓN DE ARCHIVO INEXISTENTE #---
   IF V_monto_tran_efe_atm_in IS NULL THEN
      LET Vflag = 0;
      LET cCodret = '00013';
      IF Vtotal_diasP = 0 THEN
         LET cVarDataErr13 = '.ARCHIVO INEXISTENTE: '|| trim(cCodFila)|| ','||
                             trim(cNumProducto)||','|| dFecha ||'. ';
         LET cDiasPendientes = 1;
         LET cEstatus = 'P';
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus, cDiasPendientes,
                        cCodret||cVarDataErr13);
      END IF;
   END IF;

   --- ACTUALIZACION DEL REGISTRO CON LOS DATOS LEÍDOS DE LA HISTÓRICA ---
   IF V_monto_tran_efe_atm_in IS NULL THEN
     LET  V_monto_tran_efe_atm_in = 0.00;
   END IF;

--   --- VALIDACIÓN DE TOTALES CUANDO LA SECUENCIA EXTENDIDA AÚN NO ---
--   --- SE ENCUENTRA EN MOVIMIENTO HISTÓRICO ---
--   SET ISOLATION TO DIRTY READ;
--   SELECT COUNT(consecutivo), NVL(SUM((monto325::MONEY)/100),0)
--     INTO V_tot_tran_efe_atm_in2, V_monto_tran_efe_atm_in2
--     FROM bditarjeta:td_movimientos_conciliacion_his
--    WHERE nombrearchivo = cNombreArc
--      AND tipo_conciliacion IN (50,51,53,56)
--      AND ban_bin = 'MCR'
--      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
--      AND numtarjeta NOT IN (SELECT numtarjeta
--                               FROM bdireports:rpt_mc_tar_pru);
--   
--   IF V_tot_tran_efe_atm_in2 > V_tot_tran_efe_atm_in THEN
--      LET V_tot_tran_efe_atm_in = V_tot_tran_efe_atm_in2;
--      LET V_monto_tran_efe_atm_in = V_monto_tran_efe_atm_in2;
--   END IF;
    
   --- SÓLO SE ACTUALIZAN TOTALES CUANDO SEAN DIFERENTES DE CERO ---
   IF V_monto_tran_efe_atm_in <> 0 THEN
      UPDATE bdireports:rpt_mc_vol_dia
         SET total_transacciones = V_tot_tran_efe_atm_in,
             monto_transacciones = V_monto_tran_efe_atm_in
       WHERE num_producto = cNumProducto
         AND trimestre = ctrimestre
         AND id_col = cCodFila
         AND mes = iMes
         AND fecha_reg = dFecha
         AND tipo_transaccion = cTipoTransaccion;
      LET cCodret = '00013';
      LET cVarDataErr13 = '.ACTUALIZA DATO: '|| trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'.';
   END IF;
*/

--- TRANSACCIONES DE DEVOLUCIÓN ---
-----------------------------------------------------------------------
--- DEVOLUCIONES EN COMPRAS DE MIS TARJETAHABIENTES DENTRO DEL PAÍS ---
-----------------------------------------------------------------------

--LET cNumProducto = '7000';
LET cCodFila = 'DNC';
LET CtipoTransaccion = 'DEVOLUCION NACIONAL CREDITO';

   LET cNombreArc  = 'BCPLVNC_'||LPAD(DAY(dFecha),2,'0')||
                      LPAD(MONTH(dFecha),2,'0')||YEAR(dFecha)||'.txt';

   SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), SUM((monto325::MONEY)/100)
     INTO V_tot_dev_nal, V_monto_dev_nal
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND ban_bin = 'MCR'
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND movreversado = 'F'
      AND movconciliado = 'V'
      AND tipotransaccion325 = '21'
	  AND left(numtarjeta,6)=Vbin
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru where numtarjeta is not null)
      AND secuencia_extendida IN (SELECT secuenciaextendida
                                    FROM intercard:movimientohistorico
                                   WHERE fechahorainauth >= dFechaAtmInicio
                                     AND fechahorainauth <= dFechaAtmFin
                                     AND prodind = '02'
                                     AND codigoiso = '00'
                                     AND esnacional = 'V'
                                     AND transaccionorigen = '1234'
                                     AND formato <> '0420'
                                     AND codtran = '00');

   --# VALIDACION PARA SABER SI HAY DIAS PENDIENTES DEL CALCULO DIARIO #--
   SELECT COUNT(*)
     INTO Vtotal_diasP
     FROM bdireports:rpt_param_reportevisa
    WHERE ultimo_mes = iMes
      AND ultima_actualizacion = dFecha
      AND ultimo_error[1,5] = '00014'
      AND dias_pendientes = 1;

   ---# VALIDACIÓN DE ARCHIVO EXISTENTE PERO CONTENIDO CERO #---
   IF V_tot_dev_nal = 0 AND V_monto_dev_nal = 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00014';
      LET cVarDataErr14 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      IF Vtotal_diasP = 0 THEN
         LET cDiasPendientes = 0;
         LET cEstatus = 'C';
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus,
                        cDiasPendientes, cCodret||cVarDataErr14);
      ELSE
         UPDATE bdireports:rpt_param_reportevisa
            SET dias_pendientes = 0,
                estatus_actualizacion= 'C',
                ultimo_error = cCodret||cVarDataErr14
          WHERE nom_tabla = 'sp_mc_cal_dia_c'
            AND ultimo_mes = iMes
            AND ultima_actualizacion = dFecha
            AND ultimo_error[1,5] = '00014';
      END IF;
   END IF;

   ---# VALIDACIÓN DE ARCHIVO INEXISTENTE #---
   IF V_monto_dev_nal IS NULL THEN
      LET Vflag = 0;
      LET cCodret = '00014';
      LET cVarDataErr14 = '.ARCHIVO INEXISTENTE: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      IF Vtotal_diasP = 0 THEN
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus,
                        cDiasPendientes, cCodret||cVarDataErr14);
      END IF;
   END IF;

   --- ACTUALIZACION DEL REGISTRO CON LOS DATOS LEÍDOS DE LA HISTÓRICA ---
   IF V_monto_dev_nal IS NULL THEN
     LET  V_monto_dev_nal = 0.00;
   END IF;
   
   --- VALIDACIÓN DE TOTALES CUANDO LA SECUENCIA EXTENDIDA AÚN NO ---
   --- SE ENCUENTRA EN MOVIMIENTO HISTÓRICO ---
   SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), NVL(SUM((monto325::MONEY)/100),0)
     INTO V_tot_dev_nal2, V_monto_dev_nal2
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND ban_bin = 'MCR'
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND movreversado = 'F'
      AND movconciliado = 'V'
      AND tipotransaccion325 = '21'
	  AND left(numtarjeta,6)=Vbin
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru where numtarjeta is not null);
   
   IF V_tot_dev_nal2 > V_tot_dev_nal THEN
      LET V_tot_dev_nal = V_tot_dev_nal2;
      LET V_monto_dev_nal = V_monto_dev_nal2;
   END IF;
   
   --- SÓLO SE ACTUALIZAN TOTALES CUANDO SEAN DIFERENTES DE CERO ---
   IF V_monto_dev_nal <> 0 THEN
      UPDATE bdireports:rpt_mc_vol_dia
         SET total_devolucion = V_tot_dev_nal,
             monto_devolucion = V_monto_dev_nal
       WHERE num_producto = cNumProducto
         AND trimestre = ctrimestre
         AND id_col = cCodFila
         AND mes = iMes
         AND fecha_reg = dFecha;
      LET cCodret = '00014';
      LET cVarDataErr14 = '.ACTUALIZA DATO: '|| trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'.';
   END IF;


-----------------------------------------------------------------------
--- DEVOLUCIONES EN COMPRAS DE MIS TARJETAHABIENTES FUERA DEL PAÍS ---
-----------------------------------------------------------------------
LET cCodFila = 'DIC';
LET CtipoTransaccion = 'DEVOLUCION INTERNACIONAL CREDITO';


   LET cNombreArc  = 'BCPLMCC_'||LPAD(DAY(dFecha),2,'0')||
                      LPAD(MONTH(dFecha),2,'0')||YEAR(dFecha)||'.txt';

   SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), SUM((monto325::MONEY)/100)
     INTO V_tot_dev_internal, V_monto_dev_internal
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND ban_bin = 'MCR'
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND movreversado = 'F'
      AND movconciliado = 'V'
      AND tipotransaccion325 = '21'
	  AND left(numtarjeta,6)=Vbin
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru where numtarjeta is not null)
      AND secuencia_extendida IN (SELECT secuenciaextendida
                                    FROM intercard:movimientohistorico
                                   WHERE fechahorainauth >= dFechaAtmInicio
                                     AND fechahorainauth <= dFechaAtmFin
                                     AND prodind = '02'
                                     AND codigoiso = '00'
                                     AND esnacional = 'F'
                                     AND transaccionorigen = '1234'
                                     AND formato <> '0420'
                                     AND codtran = '00');


   --# VALIDACION PARA SABER SI HAY DIAS PENDIENTES DEL CALCULO DIARIO #--
   SELECT COUNT(*)
     INTO Vtotal_diasP
     FROM bdireports:rpt_param_reportevisa
    WHERE ultimo_mes = iMes
      AND ultima_actualizacion = dFecha
      AND ultimo_error[1,5] = '00015'
      AND dias_pendientes = 1;

   ---# VALIDACIÓN DE ARCHIVO EXISTENTE PERO CONTENIDO CERO #---
   IF V_tot_dev_internal = 0 AND V_monto_dev_internal = 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00015';
      LET cVarDataErr15 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      IF Vtotal_diasP = 0 THEN
         LET cDiasPendientes = 0;
         LET cEstatus = 'C';
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus, cDiasPendientes ,cCodret||cVarDataErr15);
      ELSE
         UPDATE bdireports:rpt_param_reportevisa
            SET dias_pendientes = 0,
                estatus_actualizacion= 'C',
                ultimo_error = cCodret||cVarDataErr15
          WHERE nom_tabla = 'sp_mc_cal_dia_c'
            AND ultimo_mes = iMes
            AND ultima_actualizacion = dFecha
            AND ultimo_error[1,5] = '00015';
      END IF;
   END IF;

   ---# VALIDACIÓN DE ARCHIVO INEXISTENTE #---
   IF V_monto_dev_internal IS NULL THEN
      LET Vflag = 0;
      LET cCodret = '00015';
      LET cVarDataErr15 = '.ARCHIVO INEXISTENTE: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
      LET cDiasPendientes = 1;
      LET cEstatus = 'P';
      IF Vtotal_diasP = 0 THEN
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_ch',iMes,dFecha,cEstatus,
                        cDiasPendientes ,cCodret||cVarDataErr15);
      END IF;
   END IF;

   --- ACTUALIZACION DEL REGISTRO CON LOS DATOS LEÍDOS DE LA HISTÓRICA ---
   IF V_monto_dev_internal IS NULL THEN
      LET V_monto_dev_internal = 0.00;
   END IF;
   
   --- VALIDACIÓN DE TOTALES CUANDO LA SECUENCIA EXTENDIDA AÚN NO ---
   --- SE ENCUENTRA EN MOVIMIENTO HISTÓRICO ---   
      SET ISOLATION TO DIRTY READ;
   SELECT COUNT(consecutivo), NVL(SUM((monto325::MONEY)/100),0)
     INTO V_tot_dev_internal2, V_monto_dev_internal2
     FROM bditarjeta:td_movimientos_conciliacion_his
    WHERE nombrearchivo = cNombreArc
      AND ban_bin = 'MCR'
      AND fechacarga BETWEEN dFechaAtmInicio1 AND dFechaAtmFin1
      AND movreversado = 'F'
      AND movconciliado = 'V'
      AND tipotransaccion325 = '21'
	  AND left(numtarjeta,6)=Vbin
      AND numtarjeta NOT IN (SELECT numtarjeta
                               FROM bdireports:rpt_mc_tar_pru where numtarjeta is not null);
   
   IF V_tot_dev_internal2 > V_tot_dev_internal THEN
      LET V_tot_dev_internal = V_tot_dev_internal2;
      LET V_monto_dev_internal = V_monto_dev_internal2;
   END IF;
   
   --- SÓLO SE ACTUALIZAN TOTALES CUANDO SEAN DIFERENTES DE CERO ---
   IF V_monto_dev_internal <> 0 THEN
      UPDATE bdireports:rpt_mc_vol_dia
         SET total_devolucion = V_tot_dev_internal,
             monto_devolucion = V_monto_dev_internal
       WHERE num_producto = cNumProducto
         AND trimestre = ctrimestre
         AND id_col = cCodFila
         AND mes = iMes
         AND fecha_reg = dFecha;
      LET cCodret = '00015';
      LET cVarDataErr15 = '.ACTUALIZA DATO: '|| trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'.';
   END IF;

LET cVarDataErr = trim(cVarDataErr1)||trim(cVarDataErr9)||
                  trim(cVarDataErr10)||trim(cVarDataErr11)||
                  trim(cVarDataErr12)||trim(cVarDataErr13)||
                  trim(cVarDataErr14)||trim(cVarDataErr15)||
                  trim(cVarDataErr16)||trim(cVarDataErr17);

RETURN cCodRet,cVarDataErr;

END PROCEDURE;