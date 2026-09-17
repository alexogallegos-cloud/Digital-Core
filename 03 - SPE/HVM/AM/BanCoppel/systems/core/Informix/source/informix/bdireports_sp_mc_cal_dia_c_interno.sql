CREATE PROCEDURE "informix".sp_mc_cal_dia_c_interno(dFecha DATE, cTrimestre CHAR(5),
                                            iMes SMALLINT, iClaveTarjeta SMALLINT)
       RETURNING CHAR (5), CHAR(500);

/*
#############################################################################%
#                                                                            %
# Modificación: Se modifica SPL para ejecutar calculos diarios Platino y Oro %
#																			 %
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
DEFINE cFecha3                    CHAR(50);
DEFINE cFecha4                    CHAR(50);
DEFINE vAnio                      CHAR(02);
DEFINE cMesAntC                   CHAR(02);
DEFINE cMesAnt                    SMALLINT;
DEFINE iMes_adq                   SMALLINT;
DEFINE cTri                       CHAR(01);
DEFINE cTrim_Adq                  CHAR(05);
DEFINE FechaConciliacion1         CHAR(50);
DEFINE FechaConciliacion2		  CHAR(50);
DEFINE Fecha_Inicio        		  CHAR(50);
DEFINE Fecha_Final                CHAR(50);
DEFINE FechaMovimientoHist1	      CHAR(50);
DEFINE FechaMovimientoHist2       CHAR(50);
DEFINE cFecha1ATM                 CHAR(50);
DEFINE cFecha2ATM                 CHAR(50);
DEFINE FechaATM1				  CHAR(50);
DEFINE FechaATM2				  CHAR(50);
DEFINE FechaAdqInicio			  CHAR(50);
DEFINE FechaAdqFinal			  CHAR(50);
DEFINE Mes_Actual                 SMALLINT;
DEFINE cFecha1Ventas		      CHAR(50);
DEFINE cFecha2Ventas		      CHAR(50);
DEFINE cFechaVentasInicio		  CHAR(50);
DEFINE cFechaVentasFinal          CHAR(50);
DEFINE cFechaDev1				  CHAR(50);
DEFINE cFechaDev2				  CHAR(50);
DEFINE dFechaDev_Inicio           CHAR(50);
DEFINE dFechaDev_Final            CHAR(50);



DEFINE dFechaAtmInicio            DATETIME YEAR TO FRACTION (5);
DEFINE dFechaAtmInicio1           DATETIME YEAR TO FRACTION (3);
DEFINE dFechaAtmInicio2           DATETIME YEAR TO FRACTION (5);

DEFINE dFechaAtmFin               DATETIME YEAR TO FRACTION (5);
DEFINE dFechaAtmFin1              DATETIME YEAR TO FRACTION (3);
DEFINE dFechaAtmFin2              DATETIME YEAR TO FRACTION (5);

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
DEFINE V_monto_compras_internal2   MONEY(16,2);

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

DEFINE num_transacciones INTEGER;
DEFINE monto_transacciones_nopropio MONEY(16,2);

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
DEFINE V_totG_adq_nal             INTEGER;
DEFINE V_montoG_adq_nal           MONEY(16,2);
DEFINE V_totR_adq_nal             INTEGER;
DEFINE V_montoR_adq_nal           MONEY(16,2);
DEFINE V_totP_adq_nal             INTEGER;
DEFINE V_montoP_adq_nal           MONEY(16,2);

--TRANSACCIONES DE ADQUIRENCIA INTERNACIONAL
DEFINE V_tot_adq_internal         INTEGER;
DEFINE V_monto_adq_internal       MONEY(16,2);
DEFINE V_totG_adq_internal        INTEGER;
DEFINE V_montoG_adq_internal      MONEY(16,2);
DEFINE V_totR_adq_internal        INTEGER;
DEFINE V_montoR_adq_internal      MONEY(16,2);
DEFINE V_totP_adq_internal        INTEGER;
DEFINE V_montoP_adq_internal      MONEY(16,2);

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

   SET DEBUG FILE TO "/respaldos/sp_mc_cal_dia_c_interno.err";
   
--TRACE ON;
   IF iSqlErr <> 0 THEN
      LET cVarDataErr = cVarDataErr||'ERROR NO CONTROLADO (' || iSqlErr || ').';
      LET cCodret='-1';
      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,
                                                    ultimo_error)
              VALUES ('sp_mc_cal_dia_c',iMes,dFecha,'', 0 ,cVarDataErr);
      RETURN cCodret, cVarDataErr;
   END IF;

END EXCEPTION;

--SET DEBUG FILE TO "/ifxsif01/ilopez/Pruebas_SP/sp_mc_cal_dia_c_interno.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


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
LET V_totG_adq_nal = 0;
LET V_montoG_adq_nal = 0.00;
LET V_totR_adq_nal = 0;
LET V_montoR_adq_nal = 0.00;
LET V_totP_adq_nal = 0;
LET V_montoP_adq_nal = 0.00;

-- VARIABLES TRANSACCIONES DE ADQUIRENCIA INTERNACIONAL
LET V_tot_adq_internal = 0;
LET V_monto_adq_internal = 0.00;
LET V_totG_adq_internal = 0;
LET V_montoG_adq_internal = 0.00;
LET V_totR_adq_internal = 0;
LET V_montoR_adq_internal = 0.00;
LET V_totP_adq_internal = 0;
LET V_montoP_adq_internal = 0.00;

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

LET Mes_Actual=MONTH(dFecha);

--REGRESO 1 AÑO SI EL MES SON 1 O 2
IF Mes_Actual= 1 OR Mes_Actual=2 THEN

LET cFecha1 = YEAR(dFecha-1) || '-' || LPAD ( MONTH(dFecha-1), 2, '0') || '-' ||
              LPAD (DAY (dFecha), 2, '0') || ' 00:00:00.00000';

		ELSE 
		      LET cFecha1 = YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha-1), 2, '0') || '-' ||
              LPAD (DAY (dFecha), 2, '0') || ' 00:00:00.00000';

END IF;			  
LET cFecha2 = YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
				LPAD ( DAY (dFecha), 2, '0') || ' 23:59:59.00000';
			  
			  
			  
LET cFecha3 = YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
				LPAD (DAY (dFecha), 2, '0') || ' 00:00:00.00000';
			  
--FECHAS ATM'S NACIONAL_NO_PROPIOS  E INTERNACIONAL_NO_PROPIOS
LET dFechaAtmInicio = CAST (cFecha1 AS DATETIME year to fraction(5));
LET dFechaAtmInicio1= CAST (cFecha3 AS DATETIME year to fraction(5));

		
LET FechaAdqInicio=YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
                   LPAD (DAY (dFecha), 2, '0') || ' 00:00:00.00000';
			  
			  
LET FechaAdqFinal=YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
				  LPAD (DAY (dFecha), 2, '0') || ' 23:59:59.00000';			  
			  

LET dFechaAtmFin = CAST (cFecha2 AS DATETIME year to fraction(5));
LET dFechaAtmFin1 = CAST (cFecha2 AS DATETIME year to fraction(5));


--FECHAS PARA ATM'S NACIONAL_PROPIO
LET cFecha1ATM= YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
              LPAD (DAY (dFecha), 2, '0') || ' 00:00:00.00000';

			  
			  
LET cFecha2ATM=YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
              LPAD (DAY (dFecha), 2, '0') || ' 23:59:59.00000';


--FECHAS VENTAS NACIONAL E INTERNACIONAL
--FECHA_INICIAL
LET cFecha1Ventas=YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
                   LPAD (DAY (dFecha), 2, '0') || ' 00:00:00.00000';
				 
LET cFechaVentasInicio=CAST (cFecha1Ventas AS DATETIME year to fraction(5));

--FECHA_FINAL

LET cFecha2Ventas=YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
                   LPAD (DAY (dFecha), 2, '0') || ' 23:59:59.00000';
				 
LET cFechaVentasFinal=CAST (cFecha2Ventas AS DATETIME year to fraction(5));
		 
	

---FECHAS DE DEVOLUCIÓN
--NACIONAL E INTERNACIONAL
LET cFechaDev1=YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
              LPAD (DAY (dFecha), 2, '0') || ' 00:00:00.00000';

LET dFechaDev_Inicio=CAST (cFechaDev1 AS DATETIME year to fraction(5));


LET cFechaDev2=YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' ||
              LPAD (DAY (dFecha), 2, '0') || ' 23:59:59.00000';

			  
LET dFechaDev_Final=CAST (cFechaDev2 AS DATETIME year to fraction(5));
			  
	
			  
LET Vanio = cTrimestre[3,4];

LET Vtotal_diasP = 0;
LET Vflag = 0;

LET Vnom_tabla = '';
LET Vhay_datos = 0;

----------------------------------------
--- ACTIVIDAD DE TARJETAS DE CRÉDITO ---
----------------------------------------

--- SELECCION DEL PRODUCTO DE LA TABLA DE PARAMETROS ---
--- NOTA: PARA TODOS LOS CONCEPTOS SE QUEDA EL MISMO  NUM_PRODUCTO ---

--SET ISOLATION TO DIRTY READ;
SELECT valor
  INTO cNumProducto
  FROM bdireports:rpt_mc_param
 WHERE tipo = 'C'
   AND marca = 'MC'
   AND id_param = (CASE WHEN iClaveTarjeta = 9 THEN 2 WHEN iClaveTarjeta = 10 THEN 4 END);

------------------------------------
--- CONSULTA EL TIPO DE PRODUCTO ---
------------------------------------
--- DONDE EL BIN 554948 HACE REFERENCIA A TARJETAS DE CRÉDITO PLATINO(7000) Y 510148 A LAS TARJETAS DE CRÉDITO ORO(8100) ---
--SET ISOLATION TO DIRTY READ;
SELECT bin
INTO Vbin
FROM intercard:tipotarjeta
WHERE clave_tipotarjeta = iClaveTarjeta;

---------------------------
--- COMPRAS NACIONALES  ---
---------------------------

LET cCodFila = 'CNC';
LET CtipoCompra = 'COMPRAS NACIONALES EN OTROS POS';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_dia
                  WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha) THEN
	
	
	/* Ventas Nacionales Crédito MasterCard 7000 PLATINO */
		--set isolation to dirty read;
		SELECT COUNT(consecutivo), SUM((Monto325::MONEY)/100)
		INTO V_tot_compras_o_pos, V_monto_compras_o_pos
		FROM bditarjeta:td_movimientos_conciliacion
		WHERE  fechaconcilia BETWEEN cFechaVentasInicio   
		AND  cFechaVentasFinal
		AND archivo_origen  = 'VNC'
		AND movreversado IN ('F','V')
		AND movconciliado = 'V'
		AND integridad ='V'
		AND tipotransaccion325 = '01'
		AND aplicacion = 'V'
		AND left(numtarjeta,6)=Vbin;
	
	LET  Fecha_Inicio=cFechaVentasInicio;
	LET  Fecha_Final=cFechaVentasFinal;
	
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
      IF Vtotal_diasP = 0 THEN
         LET cDiasPendientes = 0;
         LET cEstatus = 'C';
         INSERT INTO bdireports:rpt_param_reportevisa ( nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha, cEstatus,
                        cDiasPendientes, cCodret||cVarDataErr9);
      ELSE
      ---ACT. DE TABLA DE PARAMETROS PARA QUITAR LOS DIAS PENDIENTES --
         UPDATE bdireports:rpt_param_reportevisa
            SET dias_pendientes = 0,
                estatus_actualizacion= 'C',
                ultimo_error = cCodret||cVarDataErr9
          WHERE nom_tabla = 'sp_mc_cal_dia_c'
            AND ultimo_mes = iMes
            AND ultima_actualizacion = dFecha
            AND ultimo_error[1,5] = '00009';
      END IF;
   END IF;

   ---# VALIDACIÓN DE ARCHIVO INEXISTENTE #---
   IF V_monto_compras_o_pos IS NULL THEN
      ---LET Vflag = 0;
      LET Vflag = 1;
      ---IF Vtotal_diasP = 0 THEN
         LET cCodret = '00009';
         LET cVarDataErr9 = '.ARCHIVO INEXISTENTE: '|| trim(cCodFila)|| ','||
                             trim(cNumProducto)||','|| dFecha ||'. ';
         LET cDiasPendientes = 1;
         LET cEstatus = 'P';
         INSERT INTO bdireports:rpt_param_reportevisa ( nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha, cEstatus,
                      cDiasPendientes ,cCodret||cVarDataErr9);
      ---END IF;
   END IF;


   IF V_tot_compras_o_pos <> 0 AND V_monto_compras_o_pos <> 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00000';
      LET cVarDataErr9 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'||
                          trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;


   --Inserta en la base de datos SOLO SI el archivo existe --
      IF V_monto_compras_o_pos IS NULL THEN
         LET V_monto_compras_o_pos = 0.00;
      END IF;
  
 
      INSERT INTO bdireports:rpt_mc_vol_dia(num_producto,trimestre,id_col,mes,
                                            fecha_reg, total_compras,
                                            monto_compras, tipo_compras,
                                            total_transacciones,
                                            monto_transacciones,
                                            tipo_transaccion, total_devolucion,
                                            monto_devolucion, tipo_devolucion)
        VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
                V_tot_compras_o_pos, V_monto_compras_o_pos, CtipoCompra,
                0, 0, 0, 0, 0, 0);
   
ELSE
   LET cCodret = '00009';
   LET cEstatus = 'C';
   LET cVarDataErr9 = '.DATOS DUPLICADOS: '|| trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'. ';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,ultimo_error)
          VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, 0 ,
                   cCodret||cVarDataErr9);
END IF;

-----------------------------------------
--- COMPRAS INTERNACIONALES CRÉDITO -----
-----------------------------------------
LET cCodFila = 'CIC';
LET CtipoCompra = 'COMPRAS INTERNACIONALES CREDITO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_dia
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha) THEN	
	
	/* Ventas Internacionales Crédito MasterCard 7000 PLATINO*/ 
		--set isolation to dirty read;
		SELECT COUNT(consecutivo), SUM((Monto325::MONEY)/100)
		INTO V_tot_compras_internal, V_monto_compras_internal
		FROM bditarjeta:td_movimientos_conciliacion
		WHERE  fechaconcilia BETWEEN cFechaVentasInicio  
		AND  cFechaVentasFinal  
		AND archivo_origen  = 'MCC'
		AND movreversado IN ('F','V')
		AND movconciliado = 'V'
		AND integridad ='V'
		AND tipotransaccion325 = '01'
		AND aplicacion = 'V'
		AND left(numtarjeta,6)=Vbin;
		
	LET  Fecha_Inicio=cFechaVentasInicio;
	LET  Fecha_Final=cFechaVentasFinal;
						 
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
              VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, cDiasPendientes,
                        cCodret||cVarDataErr10);
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
      ---IF Vtotal_diasP = 0 THEN
         LET cVarDataErr10 = '.ARCHIVO INEXISTENTE: '|| trim(cCodFila)|| ','||
                             trim(cNumProducto)||','|| dFecha ||'. ';
         LET cDiasPendientes = 1;
         LET cEstatus = 'P';
         INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                       ultima_actualizacion,
                                                       estatus_actualizacion,
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, cDiasPendientes,
                       cCodret||cVarDataErr10);
   
   END IF;


   IF V_tot_compras_internal <> 0 AND V_monto_compras_internal <> 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00000';
      LET cVarDataErr10 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'||
                           trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;


      IF V_monto_compras_internal IS NULL THEN
         LET V_monto_compras_internal = 0.00;
      END IF;
   
  
  
      INSERT INTO bdireports:rpt_mc_vol_dia(num_producto, trimestre, id_col,
                                            mes,
                                            fecha_reg, total_compras,
                                            monto_compras,
                                            tipo_compras, total_transacciones,
                                            monto_transacciones,
                                            tipo_transaccion,
                                            total_devolucion, monto_devolucion,
                                            tipo_devolucion)
       VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
               V_tot_compras_internal, V_monto_compras_internal,
               CtipoCompra, 0, 0, 0, 0, 0, 0);
 
ELSE
   LET cCodret = '00010';
   LET cEstatus = 'C';
   LET cVarDataErr10 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,ultimo_error)
        VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, 0,
                 cCodret||cVarDataErr10);
END IF;


--- TRANSACCIONES DE EFECTIVO EN ATM's ---
------------------------------------------------------------------------
--- TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES EN MIS BANCOS ---
------------------------------------------------------------------------
LET cCodFila = 'TEC';
LET cTipoTransaccion = 'ATM TRANSACCION EFECTIVO PROPIO';

IF NOT EXISTS (  SELECT num_producto
                  FROM bdireports:rpt_mc_vol_dia
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha
				   AND tipo_transaccion = cTipoTransaccion) THEN
				   
					--SET ISOLATION TO DIRTY READ;
					select count(consecutivo),SUM(monto)
					into V_tot_tran_efe_atm , V_monto_tran_efe_atm
						from bditarjeta:td_txns_atms_exitosas
						where fechahoramov between cFecha1ATM
						and cFecha2ATM
						and tipotran='MM'
						and marca='M'
						and esnacional='V'
						and trancajeropropio = 'V'
						and codtran='01'
						and creditodebito='C' 
						and LEFT(numtarjetamovi,6)=Vbin
						and numtarjetamovi NOT IN(SELECT numtarjeta
											FROM bdireports:rpt_mc_tar_pru where numtarjeta is not null);
					
	LET FechaATM1=cFecha1ATM;
	LET FechaATM2=cFecha2ATM;
	
   --# VALIDACION PARA SABER SI HAY DIAS PENDIENTES DEL CALCULO DIARIO #--
   SELECT COUNT(*)
     INTO Vtotal_diasP
     FROM bdireports:rpt_param_reportevisa
    WHERE ultimo_mes = iMes
      AND ultima_actualizacion = dFecha
      AND ultimo_error[1,5] = '00011'
      AND dias_pendientes = 1;

   ---# VALIDACIÓN DE CONTENIDO CERO #---
   IF V_tot_tran_efe_atm = 0 AND V_monto_tran_efe_atm = 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00011';
      LET cVarDataErr11 = '.DATOS EN CEROS: '|| trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
  
   END IF;

   IF V_tot_tran_efe_atm <> 0 AND V_monto_tran_efe_atm <> 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00000';
      LET cVarDataErr11 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'||
                          trim(cCodFila)|| ','||
                          trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;


      IF V_monto_tran_efe_atm IS NULL THEN
         LET V_monto_tran_efe_atm = 0.00;
      END IF;
   
      INSERT INTO bdireports:rpt_mc_vol_dia(num_producto,trimestre,id_col,
                                            mes,fecha_reg,
                                            total_compras, monto_compras,
                                            tipo_compras,
                                            total_transacciones,
                                            monto_transacciones,
                                            tipo_transaccion, total_devolucion,
                                            monto_devolucion, tipo_devolucion)
           VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha, 0, 0, 0,
                   V_tot_tran_efe_atm, V_monto_tran_efe_atm, CtipoTransaccion,
                   0, 0, 0);
   --END IF;
ELSE
   LET cCodret = '00011';
   LET cEstatus = 'C';
   LET cVarDataErr11 = '.DATOS DUPLICADOS: '||
                        trim(cCodFila)|| ','||trim(cNumProducto)|| ','||
                        dFecha ||'. ';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,ultimo_error)
        VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, 0,
                 cCodret||cVarDataErr11);
END IF;

--------------------------------------------------------------------------
--- TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES EN OTROS BANCOS ---
--------------------------------------------------------------------------
LET cCodFila = 'TEC';
LET CtipoTransaccion = 'ATM TRANSACCION EFECTIVO NO PROPIO';


IF NOT EXISTS (  SELECT num_producto
                  FROM bdireports:rpt_mc_vol_dia
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha
                   AND tipo_transaccion = cTipoTransaccion) THEN
								
						LET cNombreArc  = 'BCPLVNC_'||LPAD(DAY(dFecha),2,'0')||
									LPAD(MONTH(dFecha),2,'0')||YEAR(dFecha)||'.txt';
	
	LET dFechaAtmInicio=dFechaAtmInicio -1 UNITS MONTH;
	
					--SET ISOLATION TO DIRTY READ;
					SELECT 
						{+index(bditarjeta:td_movimientos_conciliacion idx_movimientos_conciliacion5)}
						COUNT(consecutivo),SUM(montointercard)
						into V_tot_tran_efe_atm_np, V_monto_tran_efe_atm_np
						FROM bditarjeta:td_movimientos_conciliacion
						WHERE fechatransaccion  BETWEEN dFechaAtmInicio1
						AND dFechaAtmFin1
						AND ban_bin = 'MCR'
						AND movreversado = 'F'
						AND movconciliado IN('V','F')
						AND tipo_conciliacion IN (50,51,53,56)
						AND left(numtarjeta,6)=Vbin
						AND numtarjeta NOT IN (SELECT numtarjeta
							FROM bdireports:rpt_mc_tar_pru)
								AND secuencia_extendida IN (SELECT secuenciaextendida
								FROM intercard:movimiento
								WHERE fechahorainauth between dFechaAtmInicio
								AND dFechaAtmFin
								AND prodind = '01'
								AND codigoiso = '00'
								AND esnacional = 'V'
								AND trancajeropropio = 'F'
								AND transaccionorigen = '1234'
								AND formato <> '0420'
								AND codtran = '01');

								
	LET FechaConciliacion1=dFechaAtmInicio1;
	LET FechaConciliacion2=dFechaAtmFin1;
	LET FechaMovimientoHist1=dFechaAtmInicio;
	LET FechaMovimientoHist2=dFechaAtmFin;
	LET num_transacciones=V_tot_tran_efe_atm_np;
	LET monto_transacciones_nopropio=V_monto_tran_efe_atm_np;	
					
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
  
   END IF;

   IF V_tot_tran_efe_atm_np <> 0 AND V_monto_tran_efe_atm_np <> 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00000';
      LET cVarDataErr12 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'|| trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;

   --Inserta en la base de datos

      IF V_monto_tran_efe_atm_np IS NULL THEN
         LET V_monto_tran_efe_atm_np = 0.00;
      END IF;

 
      INSERT INTO bdireports:rpt_mc_vol_dia(num_producto,trimestre,id_col,mes,
                                            fecha_reg,
                                            total_compras, monto_compras,
                                            tipo_compras,
                                            total_transacciones,
                                            monto_transacciones,
                                            tipo_transaccion, total_devolucion,
                                            monto_devolucion, tipo_devolucion)
             VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha, 0, 0, 0,
                     V_tot_tran_efe_atm_np, V_monto_tran_efe_atm_np,
                     CtipoTransaccion, 0, 0, 0);
 
ELSE
   LET cCodret = '00012';
   LET cEstatus = 'C';
   LET cVarDataErr12 = '.DATOS DUPLICADOS: '||
                      trim(cCodFila)|| ','||trim(cNumProducto) ||','|| dFecha ||'. ';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,ultimo_error)
        VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, 0 ,cCodret||cVarDataErr12);
END IF;

---------------------------------------------------------------------------
--- TRANSACCIONES DE EFECTIVO EN ATM's DE MIS CLIENTES FUERA DE SU PAÍS ---
---------------------------------------------------------------------------
LET cCodFila = 'TEC';
LET CtipoTransaccion = 'ATM TRANSACCION EFECTIVO INTERNACIONAL';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_dia
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND tipo_transaccion = CtipoTransaccion
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

				   
				   LET dFechaAtmInicio=dFechaAtmInicio -1 UNITS MONTH;
				   
				   --SET ISOLATION TO DIRTY READ;
					SELECT {+index(bditarjeta:td_movimientos_conciliacion idx_movimientos_conciliacion5)}
					COUNT(consecutivo),SUM(montointercard)
						INTO V_tot_tran_efe_atm_in,V_monto_tran_efe_atm_in 
						FROM bditarjeta:td_movimientos_conciliacion
						WHERE fechatransaccion  BETWEEN dFechaAtmInicio1
						AND dFechaAtmFin1
						AND ban_bin = 'MCR'
						AND movreversado = 'F'
						AND movconciliado IN('V','F')
						AND tipo_conciliacion IN (50,51,53,56)
						AND left(numtarjeta,6)=Vbin
						AND numtarjeta NOT IN (SELECT numtarjeta
							FROM bdireports:rpt_mc_tar_pru)
								AND secuencia_extendida IN (SELECT secuenciaextendida
								FROM intercard:movimiento
								WHERE fechahorainauth between dFechaAtmInicio
								AND dFechaAtmFin
								AND prodind = '01'
								AND codigoiso = '00'
								AND esnacional = 'F'
								AND trancajeropropio = 'F'
								AND transaccionorigen = '1234'
								AND formato <> '0420'
								AND codtran = '01');
					
					
	LET FechaATM1=cFecha1ATM;
	LET FechaATM2=cFecha2ATM;
					
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
              VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, cDiasPendientes,
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


   IF V_tot_tran_efe_atm_in <> 0 AND V_monto_tran_efe_atm_in <> 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00000';
      LET cVarDataErr13 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'||
                           trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;


      IF V_monto_tran_efe_atm_in IS NULL THEN
         LET V_monto_tran_efe_atm_in = 0.00;
      END IF;
 

      INSERT INTO bdireports:rpt_mc_vol_dia(num_producto,trimestre,id_col,
                                            mes,fecha_reg,
                                            total_compras, monto_compras,
                                            tipo_compras,
                                            total_transacciones,
                                            monto_transacciones,
                                            tipo_transaccion, total_devolucion,
                                            monto_devolucion, tipo_devolucion)
           VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha, 0, 0, 0,
                   V_tot_tran_efe_atm_in, V_monto_tran_efe_atm_in,
                   CtipoTransaccion, 0, 0, 0);
   --END IF;
ELSE
   LET cCodret = '00013';
   LET cEstatus = 'C';
   LET cVarDataErr13 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'. ';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,ultimo_error)
        VALUES ( 'sp_mc_cal_dia_c', iMes, dFecha, cEstatus, 0,
                  cCodret||cVarDataErr13);
END IF;


--- TRANSACCIONES DE DEVOLUCIÓN ---
-----------------------------------------------------------------------
--- DEVOLUCIONES EN COMPRAS DE MIS TARJETAHABIENTES DENTRO DEL PAÍS ---
-----------------------------------------------------------------------

LET cCodFila = 'DNC';
LET CtipoTransaccion = 'DEVOLUCION NACIONAL CREDITO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_dia
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND tipo_devolucion = CtipoTransaccion
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN
									 
							 
		--set isolation to dirty read;		
		SELECT COUNT(consecutivo), SUM((Monto325::MONEY)/100)
		INTO V_tot_dev_nal, V_monto_dev_nal
		FROM bditarjeta:td_movimientos_conciliacion
		WHERE  fechaconcilia BETWEEN  dFechaDev_Inicio
		AND dFechaDev_Final 
		AND archivo_origen  = 'VNC'
		AND movreversado IN ('F','V')
		AND integridad ='V'
		AND tipotransaccion325 = '21'
		AND aplicacion = 'V'
		AND left(numtarjeta,6)=Vbin;
	
	LET  Fecha_Inicio=dFechaDev_Inicio;
	LET  Fecha_Final=dFechaDev_Inicio;
									 
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
              VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, cDiasPendientes,
                        cCodret||cVarDataErr14);
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
              VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, cDiasPendientes,
                       cCodret||cVarDataErr14);
      END IF;
   END IF;

   IF  V_tot_dev_nal <> 0 AND V_monto_dev_nal <> 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00000';
      LET cVarDataErr14 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'||
                           trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;

      IF V_monto_dev_nal IS NULL THEN
         LET V_monto_dev_nal = 0.00;
      END IF;
	  
	   INSERT INTO bdireports:rpt_mc_vol_dia(num_producto, trimestre, id_col,mes,
                                            fecha_reg,
                                            total_compras, monto_compras,
                                            tipo_compras,
                                            total_transacciones,
                                            monto_transacciones,
                                            tipo_transaccion, total_devolucion,
                                            monto_devolucion, tipo_devolucion)
           VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha, 0, 0,
                   0, 0, 0, 0,
                   V_tot_dev_nal, V_monto_dev_nal, CtipoTransaccion);

ELSE
   LET cCodret = '00014';
   LET cEstatus = 'C';
   LET cVarDataErr14 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,ultimo_error)
        VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, 0,
                  cCodret||cVarDataErr14);
END IF;

-----------------------------------------------------------------------
--- DEVOLUCIONES EN COMPRAS DE MIS TARJETAHABIENTES FUERA DEL PAÍS ---
-----------------------------------------------------------------------
LET cCodFila = 'DIC';
LET CtipoTransaccion = 'DEVOLUCION INTERNACIONAL CREDITO';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_dia
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha
                   AND tipo_devolucion = CtipoTransaccion) THEN

									 
			--set isolation to dirty read;
				SELECT COUNT(consecutivo), SUM((Monto325::MONEY)/100)
				INTO V_tot_dev_internal,V_monto_dev_internal
				FROM bditarjeta:td_movimientos_conciliacion
				WHERE  fechaconcilia BETWEEN dFechaDev_Inicio
				AND dFechaDev_Final
				AND archivo_origen  = 'MCC'
				AND movreversado IN ('F','V')
				AND integridad ='V'
				AND tipotransaccion325 = '21'
				AND aplicacion = 'V'
				AND left(numtarjeta,6)=Vbin;

									 
	LET  Fecha_Inicio=dFechaDev_Inicio;
	LET  Fecha_Final=dFechaDev_Inicio;							 
	
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
                                                       dias_pendientes,
                                                       ultimo_error)
              VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, cDiasPendientes,
                        cCodret||cVarDataErr15);
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
              VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, cDiasPendientes,
                        cCodret||cVarDataErr15);
      END IF;
   END IF;

   IF  V_tot_dev_internal <> 0 AND V_monto_dev_internal <> 0.00 THEN
      LET Vflag = 1;
      LET cCodret = '00000';
      LET cVarDataErr15 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'||
                           trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;

      IF V_monto_dev_internal IS NULL THEN
         LET V_monto_dev_internal = 0.00;
      END IF;
 
      INSERT INTO bdireports:rpt_mc_vol_dia(num_producto,trimestre,id_col,
                                            mes, fecha_reg,
                                            total_compras, monto_compras,
                                            tipo_compras,
                                            total_transacciones,
                                            monto_transacciones,
                                            tipo_transaccion,total_devolucion,
                                            monto_devolucion, tipo_devolucion)
          VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha, 0, 0, 0,
                  0, 0, 0, V_tot_dev_internal, V_monto_dev_internal,
                  CtipoTransaccion);
 
ELSE
   LET cCodret = '00015';
   LET cEstatus = 'C';
   LET cVarDataErr15 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,ultimo_error)
      VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, 0 ,cCodret||cVarDataErr15);
END IF;

IF iClaveTarjeta = 9 THEN
----------------------------
----------------------------
--- ADQUIRENTE NACIONAL  ---
----------------------------
----------------------------
LET cCodFila = 'ADN';
LET CNumProducto = '9999';
LET CtipoTransaccion = 'ATM ADQUIRENTE NACIONAL';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_dia
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

	  
	  --- OBTENCIÓN DEL TOTAL GENERAL DE ADQUIRENCIA NACIONAL ---
		--SET ISOLATION TO DIRTY READ;
			SELECT COUNT(*), NVL(SUM(MONTO),0)
			INTO V_totG_adq_nal, V_montoG_adq_nal
			FROM intercard:conciliacion_atm_stat06
			WHERE fechaconciliacion between  FechaAdqInicio
			AND FechaAdqFinal
			AND archivoorigen='TMO'
			AND left(numtarjeta,6) NOT IN(Select bin 
			from intercard:bines
			where bin is not null )
			AND emisor NOT IN ('VISA','MDS')
			AND codigoiso in ('00','01')
			AND descripcion like '%RETIRO%'
			AND indicadordereversa='';
		  
	  
	  --SET ISOLATION TO DIRTY READ;
        SELECT COUNT(*), NVL(SUM(MONTO),0)
		INTO V_totR_adq_nal, V_montoR_adq_nal
		FROM intercard:conciliacion_atm_stat06
		WHERE fechaconciliacion between  FechaAdqInicio
		AND FechaAdqFinal
		AND archivoorigen='TMO'
		AND left(numtarjeta,6) NOT IN(Select bin 
		from intercard:bines
		where bin is not null )
		AND emisor NOT IN ('VISA','MDS')
		AND codigoiso in ('00','01')
		AND descripcion like '%RETIRO%'
		AND indicadordereversa LIKE '%REVERSAL%';
			  

   LET V_totR_adq_nal = V_totR_adq_nal * 2;
   LET V_montoR_adq_nal = V_montoR_adq_nal * 2;

  -- OBTENCIÓN DE REVERSOS PARCIALES DE ADQUIRENCIA NACIONAL ---
   --SET ISOLATION TO DIRTY READ;
   SELECT COUNT(*), NVL(SUM(MONTO),0)
     INTO V_totP_adq_nal, V_montoP_adq_nal
     FROM intercard:conciliacion_atm_stat06
	 WHERE fechaconciliacion between  FechaAdqInicio
	 AND FechaAdqFinal
	 AND archivoorigen='TMO'
     AND left(numtarjeta,6) NOT IN(Select bin 
	 from intercard:bines
	 where bin is not null )
	 AND emisor NOT IN ('VISA','MDS')
	 AND codigoiso in ('00','01')
	 AND descripcion like '%RETIRO%'
	 AND indicadordereversa LIKE 'REVERSAL%P%';

   LET V_montoP_adq_nal = V_montoP_adq_nal * 2;

   LET V_tot_adq_nal = V_totG_adq_nal - V_totR_adq_nal - V_totP_adq_nal;
   LET V_monto_adq_nal = V_montoG_adq_nal - V_montoR_adq_nal - V_montoP_adq_nal;

   IF V_tot_adq_nal <> 0 AND V_monto_adq_nal <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr16 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'||
                           trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;


   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_dia(num_producto,trimestre,id_col,
                                         mes,fecha_reg,
                                         total_compras, monto_compras,
                                         tipo_compras,
                                         total_transacciones,
                                         monto_transacciones, tipo_transaccion,
                                         total_devolucion, monto_devolucion,
                                         tipo_devolucion)
        VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha, 0, 0, 0,
                V_tot_adq_nal, V_monto_adq_nal, cTipoTransaccion, 0, 0, 0);
ELSE
   LET cCodret = '00016';
   LET cEstatus = 'C';
   LET cVarDataErr16 = '.DATOS DUPLICADOS :'||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, 0,
                 cCodret||cVarDataErr16);
END IF;

---------------------------------
---------------------------------
--- ADQUIRENTE INTERNACIONAL  ---
---------------------------------
---------------------------------

LET cCodFila = 'ADI';
LET CNumProducto = '9999';
LET cTipoTransaccion = 'ATM ADQUIRENTE INTERNACIONAL';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_vol_dia
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

	  
	--SET ISOLATION TO DIRTY READ;
	SELECT COUNT(*), NVL(SUM(MONTO),0)
	INTO V_totG_adq_internal, V_montoG_adq_internal
   FROM intercard:conciliacion_atm_stat06
   WHERE fechaconciliacion BETWEEN FechaAdqInicio 
   AND FechaAdqFinal
   AND  archivoorigen='TMO'
   AND emisor ='MDS'
   AND codigoiso in ('00','01')
   AND descripcion like '%RETIRO%'
   AND indicadordereversa='';

		
		
	--SET ISOLATION TO DIRTY READ;
	    SELECT COUNT(*), NVL(SUM(MONTO),0) 
		INTO V_totR_adq_internal, V_montoR_adq_internal
		FROM intercard:conciliacion_atm_stat06
		WHERE fechaconciliacion between  FechaAdqInicio
		AND FechaAdqFinal
		AND archivoorigen='TMO'
		AND emisor='MDS'
		AND descripcion like '%RETIRO%'
		AND indicadordereversa LIKE '%REVERSAL%'
		AND codigoiso in ('00','01');
	  
	  	  
   LET V_totR_adq_internal =  V_totR_adq_internal * 2;
   LET V_montoR_adq_internal = V_montoR_adq_internal * 2;


  -- OBTENCIÓN DE REVERSOS PARCIALES DE ADQUIRENCIA INTERNACIONAL ---
   --SET ISOLATION TO DIRTY READ;
   SELECT COUNT(*), NVL(SUM(MONTO),0)
     INTO V_totP_adq_internal, V_montoP_adq_internal
     FROM intercard:conciliacion_atm_stat06
	WHERE fechaconciliacion BETWEEN  FechaAdqInicio
	AND  FechaAdqFinal
	AND archivoorigen='TMO'
	AND emisor='MDS'
	AND descripcion like '%RETIRO%'
	AND indicadordereversa LIKE 'REVERSAL%P%'
	AND codigoiso in ('00','01');
	  	  

   LET V_montoP_adq_internal = V_montoP_adq_internal * 2;

   LET V_tot_adq_internal = V_totG_adq_internal-V_totR_adq_internal-V_totP_adq_internal;

   LET V_monto_adq_internal =V_montoG_adq_internal-V_montoR_adq_internal-V_montoP_adq_internal;

   IF V_tot_adq_internal <> 0 AND V_monto_adq_internal <> 0.00 THEN
      LET cCodret = '00000';
      LET cVarDataErr17 = 'REGISTRO EXITOSO EN rpt_mc_vol_dia.'||
                           trim(cCodFila)|| ','||
                           trim(cNumProducto)||','|| dFecha ||'. ';
   END IF;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_vol_dia(num_producto,trimestre,id_col,mes,
                                         fecha_reg,
                                         total_compras, monto_compras,
                                         tipo_compras,
                                         total_transacciones,
                                         monto_transacciones, tipo_transaccion,
                                         total_devolucion, monto_devolucion,
                                         tipo_devolucion)
        VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha, 0, 0, 0,
                V_tot_adq_internal, V_monto_adq_internal, cTipoTransaccion,
                0, 0, 0);
ELSE
   LET cCodret = '00017';
   LET cEstatus = 'C';
   LET cVarDataErr17 = '.DATOS DUPLICADOS:'||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes, ultimo_error)
        VALUES ( 'sp_mc_cal_dia_c',iMes,dFecha,cEstatus, 0,
                 cCodret||cVarDataErr17);
END IF;
END IF;

LET cVarDataErr = trim(cVarDataErr1)||trim(cVarDataErr9)||
                  trim(cVarDataErr10)||trim(cVarDataErr11)||
                  trim(cVarDataErr12)||trim(cVarDataErr13)||
                  trim(cVarDataErr14)||trim(cVarDataErr15)||
                  trim(cVarDataErr16)||trim(cVarDataErr17);

RETURN cCodRet,cVarDataErr;

END PROCEDURE;