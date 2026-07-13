CREATE PROCEDURE "informix".sp_replicainformacionvisacredito_20084(dFecha1 DATETIME year to fraction(5),dFecha2 DATETIME year to fraction(5),cTrimestre cHAR(5),iMes INTEGER)

returning
char (3),
char(50);

--##################################################################################################
--### Creado por: Jorge Nuñez                                                                     ##
--##  Fecha: 08/07/2008                                                                           ##
--##  Descripcion: Replica informacion de credito mensualmente para el reporte trimestral de visa ##
--##   DESARROLLO                                                                                           ##
--##################################################################################################



DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE cVarDataErr      CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cNumProducto     CHAR(4);
DEFINE cTransacc_suc    CHAR(4);
DEFINE dTotalDisp       DECIMAL;
DEFINE mSaldoDisp   MONEY(14,2);
DEFINE dNumDispATM2      DECIMAL;
DEFINE mSaldoDispATM2    MONEY(14,2);
DEFINE dNumDispATMtotal      DECIMAL;
DEFINE mSaldoDispATMtotal    MONEY(14,2);
DEFINE dNumDispATM1      DECIMAL;
DEFINE mSaldoDispATM1    MONEY(14,2);
DEFINE iMes1            INTEGER;
DEFINE iAnio 	          INTEGER;
DEFINE dNumComprasNac1   DECIMAL;
DEFINE mSaldoComprasNac1 MONEY(14,2);
DEFINE dNumComprasNac2   DECIMAL;
DEFINE mSaldoComprasNac2 MONEY(14,2);
DEFINE dNumComprasNactotal   DECIMAL;
DEFINE mSaldoComprasNactotal MONEY(14,2);
DEFINE dNumDispATMint1   DECIMAL;
DEFINE mMontoDispATM1    MONEY(14,2);
DEFINE dNumDispATMint2   DECIMAL;
DEFINE mMontoDispATM2   MONEY(14,2);
DEFINE dNumDispATMintTotal   DECIMAL;
DEFINE mMontoDispATMtotal    MONEY(14,2);
DEFINE dNumComprasEI1    DECIMAL;
DEFINE mSaldoComprasEI1  MONEY(14,2);
DEFINE dNumComprasEI2    DECIMAL;
DEFINE mSaldoComprasEI2  MONEY(14,2);
DEFINE dNumComprasEItotal    DECIMAL;
DEFINE mSaldoComprasEItotal  MONEY(14,2);
DEFINE dNumCuentasCredito DECIMAL;
DEFINE dNumTarjActPOS   DECIMAL;
DEFINE dNumTarjetas     DECIMAL;
DEFINE dNumeroAprobadas1 DECIMAL;
DEFINE dNumeroNoAprobadas1 DECIMAL;
DEFINE dNumeroAprobadas2 DECIMAL;
DEFINE dNumeroNoAprobadas2 DECIMAL;
DEFINE dNumeroAprobadasTotal DECIMAL;
DEFINE dNumeroNoAprobadasTotal DECIMAL;
DEFINE dFechaIn         DATETIME year to fraction(5);
DEFINE dFechaFin         DATETIME year to fraction(5);
DEFINE cCodFila          CHAR(3);
DEFINE cFecha1           CHAR(50);
DEFINE cFecha2           CHAR(50);
DEFINE dNumeroEdoCuenta  DECIMAL;
DEFINE dLimiteCredito    MONEY(14,2);
DEFINE mCargoPorFin1     MONEY(14,2);
DEFINE mCargoPorFin2     MONEY(14,2);
DEFINE mCargoPorFinTotal MONEY(14,2);
DEFINE mCargoOtros1      MONEY(14,2);
DEFINE mCargoOtros2      MONEY(14,2);
DEFINE mCargoOtros3      MONEY(14,2);
DEFINE mCargoOtrosTotal  MONEY(14,2);
DEFINE mDebitosMisc1     MONEY(14,2);
DEFINE mDebitosMisc2     MONEY(14,2);
DEFINE mDebitosMisc3     MONEY(14,2);
DEFINE mDebitosMisc4     MONEY(14,2);
DEFINE mDebitosMiscTotal MONEY(14,2);
DEFINE mPagos1           MONEY(14,2);
DEFINE mPagos2           MONEY(14,2);
DEFINE mPagos3           MONEY(14,2);
DEFINE mPagosTotal       MONEY(14,2);
DEFINE cProd             CHAR(2);
DEFINE cNacional         CHAR(1);
DEFINE iMesFecha         INTEGER;
DEFINE dTotal            DECIMAL;
DEFINE dSaldo            DECIMAL;
DEFINE mCredOtros        MONEY(14,2);

DEFINE dNumctas_men30       DECIMAL;
DEFINE dSdonumctas_men30    DECIMAL;
DEFINE dNumctas_may30       DECIMAL;
DEFINE dSdonumctas_may30    DECIMAL;
DEFINE dNumctas_may60       DECIMAL;
DEFINE dSdonumctas_may60    DECIMAL;
DEFINE dNumctas_may90       DECIMAL;
DEFINE dSdonumctas_may90    DECIMAL;
DEFINE dNumctas_may120      DECIMAL;
DEFINE dSdonumctas_may120   DECIMAL;
DEFINE iPeriodos			INTEGER;
DEFINE mDebitosMisc5        MONEY(14,2);
DEFINE dNumeroEdoCuenta1  	DECIMAL;
DEFINE dNumeroEdoCuenta2  	DECIMAL;
DEFINE dNumeroEdoCuenta3  	DECIMAL;
DEFINE cFechaEdoCta_t       CHAR(10);
DEFINE cFechaEdoCta         DATETIME year to fraction(5);


  ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
  END EXCEPTION;

-- Set debug file to "/tmp/sp_replicainformacionvisacredito.out";

-- trace on;

LET cCodret = '000';
LET cVarDataErr = '';
LET iAnio = YEAR(dFecha1);
LET dNumComprasNac1 = 0;
LET mSaldoComprasNac1 = 0;
LET dNumDispATM1 = 0;
LET mSaldoDispATM1 = 0;
LET dNumComprasEI1 = 0;
LET mSaldoComprasEI1 = 0;
LET dNumDispATMint1 = 0;
LET mMontoDispATM1 = 0;
LET dNumComprasNac2 = 0;
LET mSaldoComprasNac2= 0;
LET dNumDispATM2 = 0;
LET mSaldoDispATM2 = 0;
LET dNumComprasEI2 = 0;
LET mSaldoComprasEI2 = 0;
LET dNumDispATMint2 = 0;
LET mMontoDispATM2 = 0;
LET dNumComprasNactotal = 0;
LET mSaldoComprasNactotal = 0;
LET dNumDispATMtotal = 0;
LET mSaldoDispATMtotal = 0;
LET dNumComprasEItotal = 0;
LET mSaldoComprasEItotal = 0;
LET dNumDispATMintTotal = 0;
LET mMontoDispATMtotal = 0;

LET dNumctas_men30       = 0;
LET dSdonumctas_men30    = 0;
LET dNumctas_may30       = 0;
LET dSdonumctas_may30    = 0;
LET dNumctas_may60       = 0;
LET dSdonumctas_may60    = 0;
LET dNumctas_may90       = 0;
LET dSdonumctas_may90    = 0;
LET dNumctas_may120      = 0;
LET dSdonumctas_may120   = 0;
LET iPeriodos			 = 0;
LET cNumProducto = '6001';
----------------------------------------------------------------------------------------------------------------------------------------------------------------



--Esta informacion solo se corre si es final de trimestre



IF iMes = 3 OR iMes = 6 OR iMes = 9 OR iMes = 12 THEN


	LET iMes1 = iMes - 2;
	LET cFecha1 = YEAR(dFecha1) || '-' || iMes1 || '-' || '01' || ' 00:00:00.0';
	LET dFechaIn = CAST (cFecha1 AS DATETIME year to fraction(5));
	LET dFechaFin = dFecha2 - Interval(1) day to day;
	LET cFecha2 = YEAR(dFecha1) || '-' || iMes || '-' || DAY(dFechaFin) || ' 23:59:59.0';
	LET dFechaFin = CAST (cFecha2 AS DATETIME year to fraction(5));

--Numero de Cuentas

	SELECT COUNT (NUM_CREDITO)
	INTO dNumCuentasCredito
	FROM BDICRED:SD_TARJETA
       WHERE STATUS_TAR = 'A' AND TIPO_TARJETA = 'T';

--Tarjetas con actividad en POS

	SELECT COUNT (tar.Numtarjeta)
	INTO dNumTarjActPOS
	FROM intercard:tarjeta as tar
	LEFT OUTER JOIN intercard:movimientohistorico AS mov ON tar.Numtarjeta = mov.NumTarjeta
        WHERE mov.Numtarjeta LIKE '426807%' AND mov.ProdInd = '02' -- POS
        AND mov.fechahorainauth >= dFechaIn AND  mov.fechahorainauth <= dFechaFin;

		IF dNumTarjActPOS IS NULL THEN
		LET dNumTarjActPOS = 0;
	END IF

--Numero de tarjetas

    SELECT COUNT (Numtarjeta)
	INTO dNumTarjetas
	FROM intercard:Tarjeta
    WHERE Numtarjeta LIKE '426807%' AND codstatustarjeta = 'ACT';

		
--Numero de transacciones NO aprobadas

	SELECT COUNT (Secuencia)
	INTO dNumeroNoAprobadas1
	FROM intercard:movimiento
	WHERE Numtarjeta LIKE '426807%'
	AND fechahorainauth >= dFechaIn AND fechahorainauth <= dFechaFin AND codigoiso <> '00';
    
    IF dNumeroNoAprobadas1 IS NULL THEN
		LET dNumeroNoAprobadas1 = 0;
	END IF

	SELECT COUNT (Secuencia)
	INTO dNumeroNoAprobadas2
	FROM intercard:movimientohistorico
	WHERE Numtarjeta LIKE '426807%'
	AND fechahorainauth >= dFechaIn AND fechahorainauth <= dFechaFin AND codigoiso <> '00';

    IF dNumeroNoAprobadas2 IS NULL THEN
		LET dNumeroNoAprobadas2 = 0;
	END IF

	LET dNumeroNoAprobadasTotal = dNumeroNoAprobadas1 + dNumeroNoAprobadas2;

	IF dNumeroNoAprobadasTotal IS NULL THEN
		LET dNumeroNoAprobadasTotal = 0;
	END IF

--Estados de cuenta

	LET dFechaIn = CAST(dFechaIn as DATE);
	LET dFechaFin = CAST(dFechaFin as DATE);
	LET cFechaEdoCta_t = iAnio || '-' || iMes1 || '-' || '20';
    LET cFechaEdoCta = CAST (cFechaEdoCta_t AS DATE);
 
	SELECT COUNT(*)
	INTO dNumeroEdoCuenta1
	FROM bdicred:sd_pie_edocta
	WHERE fecha_emision = cFechaEdoCta ;

   	 IF dNumeroEdoCuenta1 IS NULL THEN
		LET dNumeroEdoCuenta1 = 0;
	END IF

    LET cFechaEdoCta_t = iAnio || '-' || iMes1 + 1 || '-' || '20';
    LET cFechaEdoCta = CAST (cFechaEdoCta_t AS DATE);

	SELECT COUNT(*)

	INTO dNumeroEdoCuenta2
	FROM bdicred:sd_pie_edocta
	WHERE fecha_emision = cFechaEdoCta;
    
	IF dNumeroEdoCuenta2 IS NULL THEN
		LET dNumeroEdoCuenta2 = 0;
	END IF
	
    LET cFechaEdoCta_t = iAnio || '-' || iMes1 + 2 || '-' || '20';
    LET cFechaEdoCta = CAST (cFechaEdoCta_t AS DATE);

	SELECT COUNT(*)
	INTO dNumeroEdoCuenta3
	FROM bdicred:sd_pie_edocta
	WHERE fecha_emision = cFechaEdoCta;

	IF dNumeroEdoCuenta3 IS NULL THEN
		LET dNumeroEdoCuenta3 = 0;
	END IF
	
	LET dNumeroEdoCuenta = dNumeroEdoCuenta1 + dNumeroEdoCuenta2 + dNumeroEdoCuenta3;

	
	IF dNumeroEdoCuenta IS NULL THEN
		LET dNumeroEdoCuenta = 0;
	END IF


--Limite de credito total



	SELECT SUM(monto_otorgado)
	INTO dLimiteCredito
	FROM bdicred:sd_maesdoscont a,
     	     bdicred:sd_maecredcont b
	WHERE monto_otorgado > 0
  	AND a.empresa = b.empresa
  	AND a.num_credito = b.num_credito
  	AND b.status_cred <> 'CV'
  	AND a.fecha = dFechaFin
  	AND b.fecha = dFechaFin;
	IF dLimiteCredito IS NULL THEN
		LET dLimiteCredito = 0;
	END IF



--Cargos por financiamiento

	SELECT SUM(monto)
	INTO mCargoPorFin1
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '605'  AND codigo_ref IN ('2','125','127')
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mCargoPorFin1 IS NULL THEN
		LET mCargoPorFin1 = 0;
	END IF

	SELECT SUM(monto)
	INTO mCargoPorFin2
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '605'  AND codigo_ref IN ('3','126','128')
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mCargoPorFin2 IS NULL THEN
		LET mCargoPorFin2 = 0;
	END IF

	LET mCargoPorFinTotal = mCargoPorFin1 + mCargoPorFin2;

	IF mCargoPorFinTotal IS NULL THEN
		LET mCargoPorFinTotal = 0;
	END IF



--Cargos por pagos en atraso y otros

	SELECT SUM(monto)
	INTO mCargoOtros1
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '033'  AND codigo_ref = '2'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mCargoOtros1 IS NULL THEN
		LET mCargoOtros1 = 0;
	END IF 

	SELECT SUM(monto)
	INTO mCargoOtros2
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '334' AND codigo_ref = '2'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mCargoOtros2 IS NULL THEN
		LET mCargoOtros2 = 0;
	END IF 

	SELECT SUM(monto)
	INTO mCargoOtros3
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '340' AND codigo_ref = '25'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mCargoOtros3 IS NULL THEN
		LET mCargoOtros3 = 0;
	END IF 

	LET mCargoOtrosTotal = mCargoOtros1 + mCargoOtros2 + mCargoOtros3;

	IF mCargoOtrosTotal IS NULL THEN
		LET mCargoOtrosTotal = 0;
	END IF 



--Debitos Miscelaneos

	SELECT SUM(monto)
	INTO mDebitosMisc1
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '339' AND codigo_ref = '1'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mDebitosMisc1 IS NULL THEN
		LET mDebitosMisc1 = 0;
	END IF

	SELECT SUM(monto)
	INTO mDebitosMisc2
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '339' AND codigo_ref IN ('3','993','994','995','996')
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mDebitosMisc2 IS NULL THEN
		LET mDebitosMisc2 = 0;
	END IF

	SELECT SUM(monto)
	INTO mDebitosMisc3
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '339' AND codigo_ref = '50'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mDebitosMisc3 IS NULL THEN
		LET mDebitosMisc3 = 0;
	END IF

	SELECT SUM(monto)
	INTO mDebitosMisc4
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '340' AND codigo_ref = '1'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mDebitosMisc4 IS NULL THEN
		LET mDebitosMisc4 = 0;
	END IF

	SELECT SUM(monto)
	INTO mDebitosMisc5
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '340' AND codigo_ref = '2'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;
	
    IF mDebitosMisc5 IS NULL THEN
		LET mDebitosMisc5 = 0;
	END IF

	LET mDebitosMiscTotal = mDebitosMisc1 + mDebitosMisc2 + mDebitosMisc3 + mDebitosMisc4 + mDebitosMisc5;

	IF mDebitosMiscTotal IS NULL THEN
		LET mDebitosMiscTotal = 0;
	END IF
 


--Pagos Recibidos

	SELECT SUM(monto)
	INTO mPagos1
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '033' AND codigo_ref = '1'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mPagos1 IS NULL THEN
		LET mPagos1 = 0;
	END IF

	SELECT SUM(monto)
	INTO mPagos2
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '334' AND codigo_ref = '1'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mPagos2 IS NULL THEN
		LET mPagos2 = 0;
	END IF

	SELECT SUM(monto)
	INTO mPagos3
	FROM bdicred:sd_movhis mh, bdicred: sd_maecred mc
	WHERE mh.empresa = mc.empresa
	AND mh.num_credito = mc.num_credito
	AND codigo_fun = '342' AND codigo_ref = '1'
	AND fecha_mov >= dFechaIn AND fecha_mov <= dFechaFin
	AND reversado = 'N' AND mc.cod_caract_2 matches 'BC*'
	AND mh.num_producto = mc.num_producto
	GROUP BY codigo_fun, codigo_ref;

    IF mPagos3 IS NULL THEN
		LET mPagos3 = 0;
	END IF

	LET mPagosTotal = mPagos1 + mPagos2 +mPagos3;

	IF mPagosTotal IS NULL THEN
		LET mPagosTotal = 0;
	END IF

	
	--Manuel Osuna V.
	
	SELECT sum(sdo_cap_insoluto)
	INTO mCredOtros  
	FROM bdicred:sd_maecred mae,bdicred:sd_maesdos_vendida ven
	WHERE mae.empresa = '001' and num_producto = '6001'
	AND ven.empresa = '001'
	AND mae.num_credito = ven.num_credito 
	AND mae.status_cred = 'CV';
	

   
---	Obtener numero y saldos de las cuentas cuentas corrientes morosas
	SELECT NVL(num_periodos,0),SUM(CASE WHEN sdo_cap_insoluto < 0 THEN 0 ELSE sdo_cap_insoluto END), COUNT(*)
	INTO iPeriodos,dNumctas_men30, dSdonumctas_men30
	FROM  bdicred: sd_maesdoscont a
	LEFT OUTER JOIN bdicred: sd_histvalcon b ON (a.empresa = b.empresa AND a.num_credito = b.num_credito AND fecha_alta = dFechaFin)
	WHERE fecha = dFechaFin AND  num_periodos = 0
	GROUP BY 1;

	SELECT NVL(num_periodos,0), SUM(CASE WHEN sdo_cap_insoluto < 0 THEN 0 ELSE sdo_cap_insoluto END), COUNT(*)
	INTO iPeriodos, dNumctas_may30, dSdonumctas_may30
	FROM  bdicred: sd_maesdoscont a
	LEFT OUTER JOIN bdicred: sd_histvalcon b ON (a.empresa = b.empresa AND a.num_credito = b.num_credito AND fecha_alta = dFechaFin)
	WHERE fecha = dFechaFin AND  num_periodos = 1
	GROUP BY 1;

	SELECT NVL(num_periodos,0), SUM(CASE WHEN sdo_cap_insoluto < 0 THEN 0 ELSE sdo_cap_insoluto END), COUNT(*)
	INTO iPeriodos, dNumctas_may60, dSdonumctas_may60
	FROM  bdicred: sd_maesdoscont a
	LEFT OUTER JOIN bdicred: sd_histvalcon b ON (a.empresa = b.empresa AND a.num_credito = b.num_credito AND fecha_alta = dFechaFin)
	WHERE fecha = dFechaFin AND  num_periodos = 2
	GROUP BY 1;

	SELECT NVL(num_periodos,0), SUM(CASE WHEN sdo_cap_insoluto < 0 THEN 0 ELSE sdo_cap_insoluto END), COUNT(*)
	INTO iPeriodos, dNumctas_may90, dSdonumctas_may90
	FROM  bdicred: sd_maesdoscont a
	LEFT OUTER JOIN bdicred: sd_histvalcon b ON (a.empresa = b.empresa AND a.num_credito = b.num_credito AND fecha_alta = dFechaFin)
	WHERE fecha = dFechaFin AND  num_periodos = 3
	GROUP BY 1;

	-- se deja el periodo 5 copmo fijo para saldos de las cuentas cuentas corrientes morosas con 4  mas periodos  -- casanova edeza hector
	SELECT 5, SUM(CASE WHEN sdo_cap_insoluto < 0 THEN 0 ELSE sdo_cap_insoluto END), COUNT(*)
	INTO iPeriodos, dNumctas_may120, dSdonumctas_may120
	FROM  bdicred: sd_maesdoscont a
	LEFT OUTER JOIN bdicred: sd_histvalcon b ON (a.empresa = b.empresa AND a.num_credito = b.num_credito AND fecha_alta = dFechaFin)
	WHERE fecha = dFechaFin AND  num_periodos >= 4
	GROUP BY 1;
	
		
	

--Guarda en la base de datos

	INSERT INTO bdireports:rpt_creditoclasica
	(
		ide_producto,
		tipo_producto,
		trimestre,
		car_fin,
		car_pagatra,
		deb_mis,
		per_credctas,
		per_credbru,
		mon_reccred,
		per_fractas,
		per_frabru,
		mon_recfra,
		pag_recidos,
		vau_cred,
		otros_cred,
		num_ctasinter,
		num_ctasrest,
		num_tar,
		est_ctasenviados,
		est_ctasfina,
		numctas_men30,
		sdonumctas_men30,
		numctas_may30,
		sdonumctas_may30,
		numctas_may60,
		sdonumctas_may60,
		numctas_may90,
		sdonumctas_may90,
		numctas_may120,
		sdonumctas_may120,
		numctas_ptovta,
		numtran_noapro,
		num_refe,
		limcred_tot,
		cuota_anual,
		visami_com,
		visami_uni
	)
	VALUES
	(
		cNumProducto,
		'C',
		cTrimestre,
		mCargoPorFinTotal,
		mCargoOtrosTotal,
		mDebitosMiscTotal,
		0,
		0,
		0,
		0,
		0,
		0,
		mPagosTotal,
		0,
		mCredOtros,
		dNumCuentasCredito,
		0,
		dNumTarjetas,
		dNumeroEdoCuenta,
		0,
		dSdonumctas_men30,
		dNumctas_men30,
		dSdonumctas_may30,
		dNumctas_may30,
		dSdonumctas_may60,
		dNumctas_may60,
		dSdonumctas_may90,
		dNumctas_may90,
		dSdonumctas_may120,
		dNumctas_may120,
		dNumTarjActPOS,
		dNumeroNoAprobadasTotal,
		0,
		dLimiteCredito,
		0,
		0,
		0
	);

END IF



RETURN cCodRet,cVarDataErr;



END PROCEDURE;