CREATE PROCEDURE "informix".sp_validamontos(pEmpresa CHAR(3),pNombre1 CHAR(40),pNombre2 CHAR(40),pApellidoPaterno CHAR(40),pApellidoMaterno CHAR(40),pFechaNacimiento CHAR(8),pFechaHoy CHAR(10),pMontoAPagar CHAR(20),pSucursal CHAR(4),pMoneda CHAR(20),pMontoDolares CHAR(20),pRemesadora CHAR(3),pNum_confirmacion CHAR(20),pRfc CHAR(13), pPri_dia_mes DATE)

	RETURNING 
	CHAR(6) AS CodRet; --Codigo de retorno   

	 --DEFINICION DE VARIABLES--
    DEFINE sql_err      					INTEGER;
    DEFINE cCodRet      					CHAR(5);
	DEFINE dFechaHoy						DATE;
	DEFINE mMontoMaxPesos					MONEY(16,2);
	DEFINE mMontoMaxDolar					MONEY(16,2);
	DEFINE mSumaTotalRemesedora				MONEY(16,2);
	DEFINE iTotalNumOperRemesas				INTEGER;
	DEFINE cNombreTabla             		CHAR(24);
	DEFINE cQuery                   		CHAR(500);
	DEFINE iNumMovsNoUSDTodas				INTEGER;
	
	DEFINE vimporte_pago_dia_usd_bts    	MONEY(16,2);
	DEFINE vimporte_origen_dia_usd_bts  	MONEY(16,2);
	DEFINE vcuenta_dia_usd_bts				INTEGER;
	DEFINE vimporte_pago_dia_no_usd_bts    	MONEY(16,2);
	DEFINE vimporte_origen_dia_no_usd_bts	MONEY(16,2);
	DEFINE vcuenta_dia_no_usd_bts			INTEGER;
	DEFINE vimporte_pago_mes_usd_bts    	MONEY(16,2);
	DEFINE vimporte_origen_mes_usd_bts  	MONEY(16,2);
	DEFINE vcuenta_mes_usd_bts				INTEGER;
	DEFINE vimporte_pago_mes_no_usd_bts    	MONEY(16,2);
	DEFINE vimporte_origen_mes_no_usd_bts	MONEY(16,2);
	DEFINE vcuenta_mes_no_usd_bts			INTEGER;
	DEFINE vimporte_pago_dia_usd_wu    		MONEY(16,2);
	DEFINE vimporte_origen_dia_usd_wu  		MONEY(16,2);
	DEFINE vcuenta_dia_usd_wu				INTEGER;
	DEFINE vimporte_pago_dia_no_usd_wu    	MONEY(16,2);
	DEFINE vimporte_origen_dia_no_usd_wu	MONEY(16,2);
	DEFINE vcuenta_dia_no_usd_wu			INTEGER;
	DEFINE vimporte_pago_mes_usd_wu    		MONEY(16,2);
	DEFINE vimporte_origen_mes_usd_wu  		MONEY(16,2);
	DEFINE vcuenta_mes_usd_wu				INTEGER;
	DEFINE vimporte_pago_mes_no_usd_wu    	MONEY(16,2);
	DEFINE vimporte_origen_mes_no_usd_wu	MONEY(16,2);
	DEFINE vcuenta_mes_no_usd_wu			INTEGER;
	DEFINE vimporte_pago_dia_usd_app    	MONEY(16,2);
	DEFINE vimporte_origen_dia_usd_app  	MONEY(16,2);
	DEFINE vcuenta_dia_usd_app				INTEGER;
	DEFINE vimporte_pago_dia_no_usd_app    	MONEY(16,2);
	DEFINE vimporte_origen_dia_no_usd_app	MONEY(16,2);
	DEFINE vcuenta_dia_no_usd_app			INTEGER;
	DEFINE vimporte_pago_mes_usd_app    	MONEY(16,2);
	DEFINE vimporte_origen_mes_usd_app  	MONEY(16,2);
	DEFINE vcuenta_mes_usd_app				INTEGER;
	DEFINE vimporte_pago_mes_no_usd_app    	MONEY(16,2);
	DEFINE vimporte_origen_mes_no_usd_app	MONEY(16,2);
	DEFINE vcuenta_mes_no_usd_app			INTEGER;
	
	--INICIALIZACION DE VARIABLES--
    LET sql_err 							= 0;
    LET cCodRet 							= '00000';
	LET dFechaHoy  							= '';
	LET mMontoMaxPesos						= 0.00;
	LET mMontoMaxDolar						= 0.00;
	LET mSumaTotalRemesedora 				= 0.00;
	LET iTotalNumOperRemesas    			= 0;
	LET iNumMovsNoUSDTodas					= 0;
	LET cNombreTabla						= '';
	LET cQuery                  			= '';
	
	--SET DEBUG FILE TO '/informix/lfp/RQM11072/sp_validamontos.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Valida Parametros 
		IF NVL(pEmpresa,'') = '' OR NVL(pNombre1,'') = '' OR NVL(pApellidoPaterno,'') = '' OR NVL(pFechaNacimiento,'') = '' OR NVL(pFechaHoy,'')='' OR NVL(pMontoAPagar,'')=''
		OR NVL(pRfc,'') = '' OR NVL(pPri_dia_mes,'') = '' THEN
			LET cCodRet = '00003'; --Faltan parametros
			RETURN cCodRet;
		END IF;
		
		--Se validara el monto mensual acumulado en todas las remesadoras con operaciones en ventanilla(BTS, WU y APP), en moneda dolar o pesos.
		SELECT pesos, usd
		INTO mMontoMaxPesos,mMontoMaxDolar
		FROM "informix".sac_limite_monto 
		WHERE abreviatura='TODAS_' AND status = 1;
		
		LET dFechaHoy  = MDY(SUBSTRING (pFechaHoy FROM 5 FOR 2),SUBSTRING (pFechaHoy FROM 7 FOR 2),SUBSTRING (pFechaHoy FROM 1 FOR 4));
		
		SELECT NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy AND numconvenio = '004' THEN importe_pago ELSE 0 END),0) importe_pago_dia_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy AND numconvenio = '004' THEN importe_origen ELSE 0 END),0) importe_origen_dia_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy AND numconvenio = '004' THEN 1 ELSE 0 END),0) cuenta_dia_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy AND numconvenio = '004' THEN importe_pago ELSE 0 END),0) importe_pago_dia_no_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy AND numconvenio = '004' THEN importe_origen ELSE 0 END),0) importe_origen_dia_no_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy AND numconvenio = '004' THEN 1 ELSE 0 END),0) cuenta_dia_no_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND numconvenio = '004' THEN importe_pago ELSE 0 END),0) importe_pago_mes_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND numconvenio = '004' THEN importe_origen ELSE 0 END),0) importe_origen_mes_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND numconvenio = '004' THEN 1 ELSE 0 END),0) cuenta_mes_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy AND numconvenio = '004' THEN importe_pago ELSE 0 END),0) importe_pago_mes_no_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy AND numconvenio = '004' THEN importe_origen ELSE 0 END),0) importe_origen_mes_no_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy AND numconvenio = '004' THEN 1 ELSE 0 END),0) cuenta_mes_no_usd_bts,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN importe_pago ELSE 0 END),0) importe_pago_dia_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN importe_origen ELSE 0 END),0) importe_origen_dia_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN 1 ELSE 0 END),0) cuenta_dia_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN importe_pago ELSE 0 END),0) importe_pago_dia_no_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN importe_origen ELSE 0 END),0) importe_origen_dia_no_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN 1 ELSE 0 END),0) cuenta_dia_no_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN importe_pago ELSE 0 END),0) importe_pago_mes_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN importe_origen ELSE 0 END),0) importe_origen_mes_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN 1 ELSE 0 END),0) cuenta_mes_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN importe_pago ELSE 0 END),0) importe_pago_mes_no_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN importe_origen ELSE 0 END),0) importe_origen_mes_no_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy AND (numconvenio = '006' OR numconvenio = '007' OR numconvenio = '008') THEN 1 ELSE 0 END),0) cuenta_mes_no_usd_wu,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy AND numconvenio = '009' THEN importe_pago ELSE 0 END),0) importe_pago_dia_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy AND numconvenio = '009' THEN importe_origen ELSE 0 END),0) importe_origen_dia_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy AND numconvenio = '009' THEN 1 ELSE 0 END),0) cuenta_dia_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy AND numconvenio = '009' THEN importe_pago ELSE 0 END),0) importe_pago_dia_no_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy AND numconvenio = '009' THEN importe_origen ELSE 0 END),0) importe_origen_dia_no_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy AND numconvenio = '009' THEN 1 ELSE 0 END),0) cuenta_dia_no_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND numconvenio = '009' THEN importe_pago ELSE 0 END),0) importe_pago_mes_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND numconvenio = '009' THEN importe_origen ELSE 0 END),0) importe_origen_mes_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND numconvenio = '009' THEN 1 ELSE 0 END),0) cuenta_mes_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy AND numconvenio = '009' THEN importe_pago ELSE 0 END),0) importe_pago_mes_no_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy AND numconvenio = '009' THEN importe_origen ELSE 0 END),0) importe_origen_mes_no_usd_app,
			   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy AND numconvenio = '009' THEN 1 ELSE 0 END),0) cuenta_mes_no_usd_app
		INTO   vimporte_pago_dia_usd_bts, vimporte_origen_dia_usd_bts, vcuenta_dia_usd_bts, vimporte_pago_dia_no_usd_bts, vimporte_origen_dia_no_usd_bts, vcuenta_dia_no_usd_bts,
		       vimporte_pago_mes_usd_bts, vimporte_origen_mes_usd_bts, vcuenta_mes_usd_bts, vimporte_pago_mes_no_usd_bts, vimporte_origen_mes_no_usd_bts, vcuenta_mes_no_usd_bts,
			   vimporte_pago_dia_usd_wu, vimporte_origen_dia_usd_wu, vcuenta_dia_usd_wu, vimporte_pago_dia_no_usd_wu, vimporte_origen_dia_no_usd_wu, vcuenta_dia_no_usd_wu,
		       vimporte_pago_mes_usd_wu, vimporte_origen_mes_usd_wu, vcuenta_mes_usd_wu, vimporte_pago_mes_no_usd_wu, vimporte_origen_mes_no_usd_wu, vcuenta_mes_no_usd_wu,
			   vimporte_pago_dia_usd_app, vimporte_origen_dia_usd_app, vcuenta_dia_usd_app, vimporte_pago_dia_no_usd_app, vimporte_origen_dia_no_usd_app, vcuenta_dia_no_usd_app,
		       vimporte_pago_mes_usd_app, vimporte_origen_mes_usd_app, vcuenta_mes_usd_app, vimporte_pago_mes_no_usd_app, vimporte_origen_mes_no_usd_app, vcuenta_mes_no_usd_app
		FROM   sac_remesas_estadistica
		WHERE  rfc               =  pRfc
		AND    fecha_pago       >=  pPri_dia_mes
		AND    fecha_pago       <=  dFechaHoy
		AND    status_cancelado !=  'S'
		AND    origen            =  'V';
		
		--Sumatoria total
		LET iNumMovsNoUSDTodas   = 	vcuenta_mes_no_usd_bts + vcuenta_dia_no_usd_bts +
									vcuenta_mes_no_usd_wu  + vcuenta_dia_no_usd_wu  +
									vcuenta_mes_no_usd_app + vcuenta_dia_no_usd_app;
								 
		LET iTotalNumOperRemesas = 	vcuenta_dia_usd_bts + vcuenta_dia_no_usd_bts + vcuenta_mes_usd_bts + vcuenta_mes_no_usd_bts +
									vcuenta_dia_usd_wu  + vcuenta_dia_no_usd_wu  + vcuenta_mes_usd_wu  + vcuenta_mes_no_usd_wu  +
									vcuenta_dia_usd_app + vcuenta_dia_no_usd_app + vcuenta_mes_usd_app + vcuenta_mes_no_usd_app;
		
		--Reviso cual es la tabla dependiendo de la remesadora que vamos a evaluar
		LET pRemesadora = UPPER(pRemesadora);
		
		IF pRemesadora = 'WU' THEN
			LET cNombreTabla='sac_remesaslimitepld_wu';
		ELIF pRemesadora ='BTS' THEN
			LET cNombreTabla='sac_remesaslimitepld_bts';
		ELIF pRemesadora ='APP' THEN
			LET cNombreTabla='sac_remesaslimitepld_app';
		END IF;

		IF iNumMovsNoUSDTodas > 0 OR pMoneda != 'USD' THEN ---Se evalua en pesos
			--SUMAR todas las remesadoras con montos mensuales en pesos
			LET mSumaTotalRemesedora = 	vimporte_pago_mes_no_usd_bts + vimporte_pago_dia_no_usd_bts + vimporte_pago_mes_usd_bts + vimporte_pago_dia_usd_bts + 
										vimporte_pago_mes_no_usd_wu  + vimporte_pago_dia_no_usd_wu  + vimporte_pago_mes_usd_wu  + vimporte_pago_dia_usd_wu  +
										vimporte_pago_mes_no_usd_app + vimporte_pago_dia_no_usd_app + vimporte_pago_mes_usd_app + vimporte_pago_dia_usd_app +
										CAST(pMontoAPagar AS MONEY(16,2));
			IF mSumaTotalRemesedora > mMontoMaxPesos THEN
				LET cCodRet =   '00002';
				LET cQuery ='INSERT INTO'||'"'||'informix'||'"'||'.'||cNombreTabla||'(fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion)VALUES('||'"'||TODAY||'"'||','||'"'||TRIM(pNombre1)||'"'||','||'"'||TRIM(pNombre2)||'"'||','||'"'||TRIM(pApellidoPaterno)||'"'||','||'"'||TRIM(pApellidoMaterno)||'"'||','||'"'||pFechaNacimiento||'"'||','||'"'||pSucursal||'"'||','||'"'||TRIM(pMontoAPagar)||'"'||','||'"'||iTotalNumOperRemesas||'"'||','||'"'||mSumaTotalRemesedora||'"'||','||'"'||TRIM(pRemesadora)||'_TODAS_MN'||'"'||','||'"'||TRIM(pNum_confirmacion)||'"'||');';
				EXECUTE IMMEDIATE cQuery;
			END IF;
		ELSE
			--SUMAR todas las remesadoras con montos mensuales en dolares
			LET mSumaTotalRemesedora = 	vimporte_origen_mes_no_usd_bts + vimporte_origen_dia_no_usd_bts + vimporte_origen_mes_usd_bts + vimporte_origen_dia_usd_bts + 
										vimporte_origen_mes_no_usd_wu  + vimporte_origen_dia_no_usd_wu  + vimporte_origen_mes_usd_wu  + vimporte_origen_dia_usd_wu  +
										vimporte_origen_mes_no_usd_app + vimporte_origen_dia_no_usd_app + vimporte_origen_mes_usd_app + vimporte_origen_dia_usd_app +
										CAST(pMontoDolares AS MONEY(16,2));
			IF mSumaTotalRemesedora > mMontoMaxDolar THEN
				LET cCodRet =   '00001';
				Let cQuery ='INSERT INTO'||'"'||'informix'||'"'||'.'||cNombreTabla||'(fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion)VALUES('||'"'||TODAY||'"'||','||'"'||TRIM(pNombre1)||'"'||','||'"'||TRIM(pNombre2)||'"'||','||'"'||TRIM(pApellidoPaterno)||'"'||','||'"'||TRIM(pApellidoMaterno)||'"'||','||'"'||pFechaNacimiento||'"'||','||'"'||pSucursal||'"'||','||'"'||TRIM(pMontoDolares)||'"'||','||'"'||iTotalNumOperRemesas||'"'||','||'"'||mSumaTotalRemesedora||'"'||','||'"'||TRIM(pRemesadora)||'_TODAS_USD'||'"'||','||'"'||TRIM(pNum_confirmacion)||'"'||');';
				EXECUTE IMMEDIATE cQuery;
			END IF;
		END IF;
RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro G Jimenez Guzman',
'FOLIO: 222',
'DESCRIPCION: valida el monto total de todas las remesedoras, en pesos y en dolar segun la moneda origen',
'FECHA: 20/05/2017',
'SUSTENTO: Se definio con Jaime Gonzalez y Eduardo Pineda Guzman',
'RQI ',
'BD:BDISAC';

CREATE PROCEDURE "informix".sp_validamontoremesawu(p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40),  p_cApellidoPaterno CHAR(40),p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(10), p_cEstado CHAR(2),p_mMontoAPagar CHAR(20), p_cSucursal CHAR(4),p_moneda CHAR(3),cMontoDolares Money(16,2),pNum_confirmacion CHAR(16))

RETURNING CHAR(5) AS cod_ret;

    --Definicion de Variables
    DEFINE cCodRet      				CHAR(5);
	DEFINE vCodRet						CHAR(5);
	DEFINE iSqlErr						INTEGER;
	DEFINE mImpDia						MONEY(16,2); -- FOLIO: 1508 --12/11/2015	
	DEFINE mImpMes						MONEY(16,2); -- FOLIO: 1508 --12/11/2015	
	DEFINE cEstado                 		CHAR(2);		
	DEFINE mMontoMaxMensual				MONEY(16,2); -- FOLIO: 1508 -- 02/11/2015
	DEFINE dPri_dia_mes					DATE; 	    -- FOLIO: 1508 -- 02/11/2015
	DEFINE mTotalDiario					MONEY(16,2);	
	DEFINE mTotalMensual				MONEY(16,2);
	DEFINE iNumOperMes					INTEGER;
	DEFINE iNumOperDia					INTEGER;
	DEFINE cMaxDiario 					MONEY(16,2);
	DEFINE cMaxDiarioDolar				MONEY(16,2);
	DEFINE cMaxMesDolar 				MONEY(16,2);
	DEFINE iMaxOperaciones          	INTEGER;
	DEFINE cMaxSuc						MONEY(16,2);
	DEFINE cMaxSucDolar					MONEY(16,2);
	DEFINE cMaxEdo						MONEY(16,2);
	DEFINE cMaxEdoDolar 				MONEY(16,2);
	DEFINE mImpMesDolar					MONEY(14,2);
	DEFINE mImpDiaDolar 				MONEY(14,2);
	define mTotalDiarioDolar 			MONEY(14,2);
	define mTotalMensualDolar 			MONEY(14,2);
	DEFINE iNumMovsNoUSDHist			INTEGER;
	DEFINE iNumMovsNoUSD				INTEGER;
	DEFINE cFechaNacimiento				CHAR(10);
	DEFINE cFechaHoy					CHAR(10);
	DEFINE cSPCodRet 					CHAR(5); 
	DEFINE iMensaje 					CHAR(50);
	DEFINE cid_ptf	 					CHAR(5); 
	DEFINE ccve_pais 					CHAR(3);
	DEFINE cnompais 					CHAR(20);
	DEFINE ccalle 						VARCHAR(100); 
	DEFINE cnum_ext 					VARCHAR(6); 
	DEFINE cnum_int 					VARCHAR(5); 
	DEFINE ccve_col 					CHAR(8);
	DEFINE cnomcol 						VARCHAR(100);
	DEFINE ccve_mun 					CHAR(3);
	DEFINE cnommunicipio 				VARCHAR(60);
	DEFINE ccve_localidad 				CHAR(14);
	DEFINE cnomlocalidad 				VARCHAR(60);
	DEFINE ccp 							CHAR(5); 
	DEFINE ccve_ciudad 					CHAR(3);
	DEFINE cnomciudad 					VARCHAR(60);
	DEFINE ccve_estado 					CHAR(2); 
	DEFINE cnomestado 					VARCHAR(30);
	DEFINE ctel1 						VARCHAR(14); 
	DEFINE ctel2 						VARCHAR(14);
	DEFINE ctipo 						VARCHAR(5);
	DEFINE dFechaHoy					DATE;
	DEFINE cRfc							CHAR(13);
	DEFINE cNombres						CHAR(85);
	DEFINE dFechaNac					DATE;
	DEFINE vimporte_pago_dia_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_usd  	MONEY(16,2);
	DEFINE vcuenta_dia_usd				INTEGER;
	DEFINE vimporte_pago_dia_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_no_usd	MONEY(16,2);
	DEFINE vcuenta_dia_no_usd			INTEGER;
	DEFINE vimporte_pago_mes_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_usd  	MONEY(16,2);
	DEFINE vcuenta_mes_usd				INTEGER;
	DEFINE vimporte_pago_mes_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_no_usd	MONEY(16,2);
	DEFINE vcuenta_mes_no_usd			INTEGER;
	DEFINE iCuentasListasNegras			INTEGER;
	
	-- Inicializa variables
    LET cCodRet 						= "00000";
	LET iSqlErr	 						= 0;
	LET	mImpDia							= 0.00;
	LET	mImpMes							= 0.00;
	LET cEstado                     	= "";
	LET mMontoMaxMensual				= 0.00;
	LET dPri_dia_mes					= DATE(1);	
	LET	mTotalDiario					= 0.00;	
	LET mTotalMensual					= 0.00;
	LET iNumOperMes						= 0;
	LET iNumOperDia						= 0;
	LET cMaxDiario						= 0;
	LET cMaxDiarioDolar 				= 0;
	LET cMaxMesDolar 			    	= 0;
	LET iMaxOperaciones					= 0;
	LET cMaxSuc                     	= 0;
	LET cMaxSucDolar                	= 0;
	LET cMaxEdo							= 0;
	LET cMaxEdoDolar 					= 0;
	LET mImpMesDolar					= 0;
	LET mImpDiaDolar					= 0;
	let mTotalDiarioDolar           	= 0;
	let mTotalMensualDolar          	= 0;
	LET iNumMovsNoUSDHist				= 0;
	LET iNumMovsNoUSD					= 0;
	LET cFechaNacimiento				= '';
	LET cFechaHoy						= '';
	LET cMontoDolares					= cMontoDolares / 100.00;
	LET cSPCodRet 						= '00000';
	LET iMensaje 						= '';
	LET cid_ptf 						= '';
	LET ccve_pais 						= '';
	LET cnompais 						= '';
	LET ccalle 							= '';
	LET cnum_ext 						= ''; 
	LET cnum_int 						= '';
	LET ccve_col 						= '';
	LET cnomcol 						= '';
	LET ccve_mun 						= '';
	LET cnommunicipio 					= '';
	LET ccve_localidad 					= '';
	LET cnomlocalidad 					= '';
	LET ccp 							= '';
	LET ccve_ciudad 					= '';
	LET cnomciudad 						= '';
	LET ccve_estado 					= ''; 
	LET cnomestado 						= '';
	LET ctel1 							= '';
	LET ctel2 							= '';
	LET ctipo 							= '';
	LET dFechaHoy						= '';
	LET cRfc							= '';
	LET cNombres						= '';
	LET dFechaNac						= '';
	LET iCuentasListasNegras			= 0;


	
	--SET DEBUG FILE TO "/informix/lfp/new/exec_sp_validamontoremesawu_a_quedar.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		IF NVL(p_cEmpresa,"") <> "" AND NVL(p_cNombre1,"") <> "" AND NVL(p_cApellidoPaterno,"") <> "" AND NVL(p_cFechaNacimiento,"") <> "" AND NVL(p_cFechaHoy,"") <> "" AND NVL(p_cEstado,"") <> "" AND NVL(p_mMontoAPagar,"") <> "" THEN
		
			--LET cFechaNacimiento = SUBSTRING (p_cFechaNacimiento FROM 5 FOR 4)||SUBSTRING (p_cFechaNacimiento FROM 3 FOR 2)||SUBSTRING (p_cFechaNacimiento FROM 1 FOR 2);
			--LET cFechaHoy = SUBSTRING(p_cFechaHoy FROM 5 FOR 4)||SUBSTRING(p_cFechaHoy FROM 3 FOR 2)||SUBSTRING(p_cFechaHoy FROM 1 FOR 2);
			
			--LET cFechaNacimiento = SUBSTRING (p_cFechaNacimiento FROM 1 FOR 2)||SUBSTRING (p_cFechaNacimiento FROM 3 FOR 2)||SUBSTRING (p_cFechaNacimiento FROM 5 FOR 4);
			--LET cFechaHoy = SUBSTRING(p_cFechaHoy FROM 1 FOR 2)||SUBSTRING(p_cFechaHoy FROM 3 FOR 2)||SUBSTRING(p_cFechaHoy FROM 5 FOR 4);
			
			LET cFechaNacimiento = SUBSTRING (p_cFechaNacimiento FROM 5 FOR 4)||SUBSTRING (p_cFechaNacimiento FROM 3 FOR 2)||SUBSTRING(p_cFechaNacimiento FROM 1 FOR 2);
			--LET cFechaHoy_test = SUBSTRING(p_cFechaHoy FROM 1 FOR 4)||SUBSTRING(p_cFechaHoy FROM 6 FOR 2)||SUBSTRING(p_cFechaHoy FROM 9 FOR 2);
			LET cFechaHoy = SUBSTRING (p_cFechaHoy FROM 5 FOR 4)||SUBSTRING (p_cFechaHoy FROM 3 FOR 2)||SUBSTRING(p_cFechaHoy FROM 1 FOR 2);
			
			SELECT PESOS,USD
			INTO cMaxDiario,cMaxDiarioDolar
			FROM "informix".sac_limite_monto
			WHERE abreviatura = 'WU_DIA_'
			AND status = 1;

			--maximo de operaciones mensuales y limite en pesos y dolares
			SELECT PESOS,USD,operaciones
			INTO mMontoMaxMensual,cMaxMesDolar,iMaxOperaciones 
			FROM "informix".sac_limite_monto
			WHERE abreviatura = 'WU_MES_'
			AND status = 1;
			
			--Maximo por sucursal
			SELECT pesos,usd 
			INTO cMaxSuc,cMaxSucDolar
			FROM "informix".sac_limite_suc 
			WHERE abreviatura = 'WU_DIA_' 
			AND sucursal = p_cSucursal 
			AND status = 1;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_consucursales(p_cSucursal) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
			IF cSPCodRet != '00000' THEN
				LET cCodRet = "00002";
				RETURN cCodRet;
			ELSE
				LET cEstado = ccve_estado;						
			END IF;	
			
			-- maximo por estado
			SELECT PESOS,USD 
			INTO cMaxEdo, cMaxEdoDolar
			FROM "informix".sac_limite_edo
			WHERE abreviatura = 'WU_DIA_'			
			AND status = 1
			AND estado = cEstado;
			

			SELECT pri_dia_mes
			INTO dPri_dia_mes
			FROM bdinteg:"informix".si_fechas;
			
			LET cNombres  = TRIM(p_cNombre1) || " " || TRIM(p_cNombre2);
			LET dFechaNac = MDY(SUBSTRING(p_cFechaNacimiento FROM 3 FOR 2) ,SUBSTRING(p_cFechaNacimiento FROM 1 FOR 2) ,SUBSTRING(p_cFechaNacimiento FROM 5 FOR 4));
			
			--Calculo el RFC del beneficiario
			EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(p_cApellidoPaterno, p_cApellidoMaterno, cNombres, dFechaNac)
			INTO vCodRet, cRfc;
			
			LET dFechaHoy = MDY(SUBSTRING(p_cFechaHoy FROM 3 FOR 2), SUBSTRING(p_cFechaHoy FROM 1 FOR 2), SUBSTRING(p_cFechaHoy FROM 5 FOR 4));
			
			--Obtengo cifras pagadas durante el mes para el beneficiario
			SELECT NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_no_usd
			INTO   vimporte_pago_dia_usd, vimporte_origen_dia_usd, vcuenta_dia_usd, vimporte_pago_dia_no_usd, vimporte_origen_dia_no_usd, vcuenta_dia_no_usd,
			       vimporte_pago_mes_usd, vimporte_origen_mes_usd, vcuenta_mes_usd, vimporte_pago_mes_no_usd, vimporte_origen_mes_no_usd, vcuenta_mes_no_usd
			FROM   sac_remesas_estadistica
			WHERE  rfc               =  cRfc
			AND    numcategoria      =  '07'
			AND    numconvenio       IN ('006', '007', '008')
			AND    fecha_pago       >=  dPri_dia_mes
			AND    fecha_pago       <=  dFechaHoy
			AND    status_cancelado !=  'S'
			AND    origen            = 'V';
			
			--Determino el numero de movimientos hechos en moneda distinta de dolares
			LET iNumMovsNoUSDHist = vcuenta_dia_no_usd + vcuenta_mes_no_usd;
			
			--Determino el numero de operaciones del mes
			LET iNumOperMes	= vcuenta_dia_usd + vcuenta_dia_no_usd + vcuenta_mes_usd + vcuenta_mes_no_usd;
			
			--Determino el numero de operaciones del dia
			LET iNumOperDia = vcuenta_dia_usd + vcuenta_dia_no_usd;
			
			--Reviso si esta en listas negras
			SELECT COUNT(*)
			INTO   iCuentasListasNegras
			FROM   bdiauditor:"informix".tbl_listainterna
			WHERE  rfc = cRfc;
				
			--Determino casuistica para evaluar si existen cobros hechos en moneda diferente de dolar
			IF iNumMovsNoUSDHist > 0 OR p_moneda <> 'USD' THEN
			
				LET mImpDia = vimporte_pago_dia_usd + vimporte_pago_dia_no_usd;
				LET mImpMes = vimporte_pago_mes_usd + vimporte_pago_mes_no_usd;
			
				--Caso de que algun movimiento (incluyendo el de la peticion) sea diferente de dolares
				LET mTotalDiario  = mImpDia + CAST(p_mMontoAPagar AS MONEY(14,2));
				LET mTotalMensual = mImpMes + mTotalDiario;

				--1. Limite por numero de transacciones (mensual) p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40), p_cApellidoPaterno CHAR(40), p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(8) , p_cMontoAPagar CHAR(20),p_cSucursal  CHAR(4),p_moneda CHAR(3),cMontoDolares Money(16,2),pNum_confirmacion
				IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
					LET cCodRet= '00157';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperMes, (mImpMes + mImpDia), 'WU_MES_OPE',pNum_confirmacion);
						
					--2. Limite diario por sucursal (17,500 pesos / 800 dolares)
				ELIF cMaxSuc > 0 AND (mTotalDiario > cMaxSuc) THEN  --valida monto diario por sucursal
					LET cCodRet= '00158';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperDia, mImpDia, 'WU_DIA_SUC_MN',pNum_confirmacion);				
					
					--3. Limite por estado (17,500 pesos / 800 dolares)
				ELIF cMaxEdo > 0 AND (mTotalDiario > cMaxEdo) THEN  --valida monto diario por sucursal
					LET cCodRet= '00159';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperDia,mImpDia, 'WU_DIA_EDO_MN',pNum_confirmacion);
					
					--4. Restriccion de listas negras	 p_cApellidoPaterno CHAR(40), p_cApellidoMaterno CHAR(40), p_cFechaNacimiento PENDIENTE COMENTARIO
				ELIF iCuentasListasNegras > 0 THEN
					LET cCodRet= '00160';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY,  p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperDia, mImpDia, 'WU_LISTA',pNum_confirmacion);				
											
					--5. Limite diario (33,000 pesos / 800 dolares)
				ELIF mTotalDiario > cMaxDiario THEN  --valida monto diario					
					LET cCodRet= '00161';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY,  p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperDia, mImpDia, 'WU_DIA_MN',pNum_confirmacion);				
					
					--6. Limite mensual (66,000 pesos / 1,500 dolares)
				ELIF mTotalMensual > mMontoMaxMensual THEN --valida acumulado mensual
					LET cCodRet= '00162';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY,  p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperMes, (mImpMes + mImpDia), 'WU_MES_MN',pNum_confirmacion);
					
				END IF;
			ELSE
			
				LET mImpDiaDolar = vimporte_origen_dia_usd + vimporte_origen_dia_no_usd;
				LET mImpMesDolar = vimporte_origen_mes_usd + vimporte_origen_mes_no_usd;
			
				LET mTotalDiarioDolar    = mImpDiaDolar + cMontoDolares;
				LET mTotalMensualDolar = mImpMesDolar + mTotalDiarioDolar;

				--1. Limite por numero de transacciones (mensual) p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40), p_cApellidoPaterno CHAR(40), p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(8) , p_cMontoAPagar CHAR(20),p_cSucursal  CHAR(4),p_moneda CHAR(3),cMontoDolares Money(16,2),pNum_confirmacion
				IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales				
					LET cCodRet= '00164';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperMes, (mImpMesDolar + mImpDiaDolar), 'WU_MES_OPE',pNum_confirmacion);									

					--2. Limite diario por sucursal (17,500 pesos / 800 dolares)
				ELIF cMaxSucDolar > 0 AND (mTotalDiarioDolar > cMaxSucDolar) THEN  --valida monto diario por sucursal
						LET cCodRet= '00165';
						INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY,p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'WU_DIA_SUC_USD',pNum_confirmacion);				
					
					--3. Limite por estado (17,500 pesos / 800 dolares)
				ELIF cMaxEdoDolar > 0 AND (mTotalDiarioDolar > cMaxEdoDolar) THEN  --valida monto diario por sucursal
					LET cCodRet= '00166';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'WU_DIA_EDO_USD',pNum_confirmacion);	
					
					--4. Restriccion de listas negras
				ELIF iCuentasListasNegras > 0 THEN
					LET cCodRet= '00160';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'WU_LISTA',pNum_confirmacion);				
							
					--5. Limite diario (33,000 pesos / 800 dolares)
				ELIF mTotalDiarioDolar > cMaxDiarioDolar THEN  --valida monto diario					
					LET cCodRet= '00167';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'WU_DIA_USD',pNum_confirmacion);				
				
					--6. Limite mensual (66,000 pesos / 1,500 dolares)
				ELIF mTotalMensualDolar > cMaxMesDolar THEN --valida acumulado mensual
					LET cCodRet= '00168';
					INSERT INTO "informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal,cMontoDolares, iNumOperMes, (mImpMesDolar + mImpDiaDolar), 'WU_MES_USD',pNum_confirmacion);
				
				End IF;		

			END IF;

			IF cCodRet = '00000' THEN						
				EXECUTE PROCEDURE bdisac:"informix".sp_validamontos(p_cEmpresa,p_cNombre1,p_cNombre2,p_cApellidoPaterno,p_cApellidoMaterno,cFechaNacimiento,cFechaHoy,p_mMontoAPagar,p_cSucursal,p_moneda,cMontoDolares,'WU',pNum_confirmacion,cRfc,dPri_dia_mes)
				INTO cCodRet;
				
				IF cCodRet = '00001' THEN  --Se excedio en dolares
					LET cCodRet = '00169';
				END IF;
				
				IF cCodRet = '00002' THEN  --Se excedio en pesos
					LET cCodRet = '00163';
				END IF;
			END IF;

		ELSE   
		   LET cCodRet = "00170";
		   RETURN cCodRet;
		END IF;					
		
		RETURN cCodRet;		
	END;
END PROCEDURE;