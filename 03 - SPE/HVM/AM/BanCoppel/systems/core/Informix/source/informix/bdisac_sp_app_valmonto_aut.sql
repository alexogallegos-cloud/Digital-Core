CREATE PROCEDURE "informix".sp_app_valmonto_aut(pNum_confirmacion CHAR(16), pCta_benef CHAR(20), p_sucursal CHAR(4), p_cMontoAPagar CHAR(20), pMonedaOrigen CHAR(3), pMontoOrigen MONEY(14,2))
    
	RETURNING
	CHAR(5)   AS Codigo_Error,
	CHAR(150) AS Desc_Error;
 
    --Definicion de Variables
    DEFINE cCod_err      				CHAR(5);
	DEFINE cDesc_error     				CHAR(150);
	DEFINE vCodRet						CHAR(5);
	DEFINE iSqlErr						INTEGER;
	DEFINE iLen_cta		   				INTEGER;
	DEFINE cNumCte         				CHAR(20);
	DEFINE cFechaNac	   				CHAR(10);
	DEFINE cNombre1		   				CHAR(40);
	DEFINE cNombre2        				CHAR(40);
	DEFINE cApellPat       				CHAR(40);
	DEFINE cApellMat       				CHAR(40);
	DEFINE cRfc							CHAR(13);
	DEFINE cMontoMaxMensual				MONEY(14,2);
	DEFINE iMaxOperaciones          	INTEGER;
	DEFINE cMaxDiario 					MONEY(14,2);
	DEFINE cMaxMesDolar 				MONEY(16,2);
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
	DEFINE iNumMovsNoUSDHist			INTEGER;
	DEFINE iNumOperDia 					INTEGER;
	DEFINE iNumOperMes					INTEGER;
	DEFINE mImpDia						MONEY(16,2);
	DEFINE mImpMes						MONEY(16,2);
	DEFINE mImpMesDolar					MONEY(14,2);
	DEFINE mImpDiaDolar 				MONEY(14,2);
	DEFINE dPri_dia_mes		 			DATE;
	DEFINE cMaxDiarioDolar				MONEY(16,2);
	DEFINE iTotalDiario 				INTEGER;
	DEFINE mTotalMensual				MONEY(16,2);
	DEFINE mTotalDiarioDolar 			MONEY(14,2);
	DEFINE mTotalMensualDolar			MONEY(14,2);
	DEFINE dFechaHoy					DATE;
	
	-- Inicializa variables
    LET cCod_err 						= "00000";
	LET cDesc_error						= '';
	LET iSqlErr 						= 0;
	LET iLen_cta		   				= 0;
	LET cNumCte            				= '';
	LET cFechaNac          				= '';
	LET cNombre1		   				= '';
	LET cNombre2           				= '';
	LET cApellPat          				= '';
	LET cApellMat          				= '';
	LET cRfc							= '';
	LET cMontoMaxMensual				= 0;
	LET iMaxOperaciones         		= 0;
	LET cMaxDiario			    		= 0;
	LET cMaxMesDolar					= 0;
	LET iNumMovsNoUSDHist				= 0;
	LET iNumOperDia 					= 0;
	LET iNumOperMes						= 0;
	LET	mImpDia							= 0.00;
	LET	mImpMes							= 0.00;
	LET mImpMesDolar					= 0;
	LET mImpDiaDolar					= 0;
	LET iTotalDiario					= 0;
	LET mTotalMensual					= 0;
	LET mTotalDiarioDolar 				= 0;
	LET mTotalMensualDolar				= 0;
	LET dFechaHoy						= '';
	LET dPri_dia_mes					= '';
	LET iCuentasListasNegras			= 0;
	
	
	--SET DEBUG FILE TO '/informix/lfp/new/exec_sp_app_valmonto_aut.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
	
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCod_err = iSqlErr;
				LET cDesc_error = "Error al momento de intentar revisar el limite de remesas";
                RETURN cCod_err, cDesc_error;
            END IF;
        END EXCEPTION;
		
		IF NVL(pNum_confirmacion,"") <> "" AND NVL(pCta_benef,"") <> "" AND NVL(p_sucursal,"") <> "" AND NVL(p_cMontoAPagar,"") <> "" AND NVL(pMonedaOrigen,"") <> "" THEN
		
			LET iLen_cta = LENGTH(TRIM(pCta_benef));
				
			IF iLen_cta = 11 THEN
				SELECT cuenta, num_cte
				INTO   pCta_benef, cNumCte
				FROM   bdicheq:"informix".sc_maechq 
				WHERE  empresa = '001'
				AND    cuenta  = pCta_benef;
				
			ELIF iLen_cta = 16 THEN
				SELECT cuenta, numcte
				INTO   pCta_benef, cNumCte
				FROM   bdicheq:"informix".sc_tarjeta 
				WHERE  empresa     = '001'
				AND    num_tarjeta = pCta_benef;
				
			ELIF iLen_cta = 18 THEN
				SELECT cuenta, num_cte
				INTO   pCta_benef, cNumCte
				FROM   bdicheq:"informix".sc_maechq 
				WHERE  cuenta_clabe = pCta_benef;
				
			END IF;
		
			--Obtener el primer dia del mes y la fecha actual de Servicios
			SELECT pri_dia_mes, fecha_hoy 
			INTO   dPri_dia_mes, dFechaHoy
			FROM   bdisac:"informix".sac_fechas;
			
			--Obtener datos del cliente
			SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
			INTO   cNombre1, cNombre2, cApellPat, cApellMat, cRfc
			FROM   bdinteg:"informix".si_cliente 
			WHERE  numcte  = cNumCte
			AND    empresa ='001';
			
			SELECT TO_CHAR(fecha_nac,'%Y%m%d')
			INTO   cFechaNac
			FROM   bdinteg:"informix".si_ctepf  
			WHERE  numcte  = cNumCte 
			AND    empresa ='001';
			
			--Obtengo los valores a no exceder (Limite mensual)
			SELECT pesos, usd, operaciones
			INTO   cMontoMaxMensual, cMaxMesDolar, iMaxOperaciones
			FROM   bdisac:"informix".sac_limite_monto 
			WHERE  abreviatura = 'APP_MES_AUT_'
			AND    status      = 1;

			--Obtengo los valores a no exceder (Limite diario)
			SELECT pesos, usd
			INTO   cMaxDiario, cMaxDiarioDolar
			FROM   bdisac:"informix".sac_limite_monto 
			WHERE  abreviatura = 'APP_DIA_AUT_'
			AND    status      = 1;
			
			
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
				   NVL(SUM(CASE WHEN moneda_origen != 'USD'  AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_no_usd
			INTO   vimporte_pago_dia_usd, vimporte_origen_dia_usd, vcuenta_dia_usd, vimporte_pago_dia_no_usd, vimporte_origen_dia_no_usd, vcuenta_dia_no_usd,
				   vimporte_pago_mes_usd, vimporte_origen_mes_usd, vcuenta_mes_usd, vimporte_pago_mes_no_usd, vimporte_origen_mes_no_usd, vcuenta_mes_no_usd
			FROM   sac_remesas_estadistica
			WHERE  rfc               =  cRfc
			AND    numcategoria      =  '07'
			AND    numconvenio       =  '009'
			AND    fecha_pago       >=  dPri_dia_mes
			AND    fecha_pago       <=  dFechaHoy
			AND    status_cancelado !=  'S'
			AND    origen            =  'A'
			AND    id_sucursal       =  p_sucursal;
			
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
			IF iNumMovsNoUSDHist > 0 OR pMonedaOrigen <> 'USD' THEN
			
				LET mImpDia = vimporte_pago_dia_usd + vimporte_pago_dia_no_usd;
				LET mImpMes = vimporte_pago_mes_usd + vimporte_pago_mes_no_usd;
				
				--Caso de que algun movimiento (incluyendo el de la peticion) sea diferente de dolares
				LET iTotalDiario	= mImpDia + p_cMontoAPagar;
				LET mTotalMensual 	= mImpMes + iTotalDiario;
				
				--1. Limite por numero de transacciones (mensual)
				IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
				
					LET cCod_err    = '1100';
					LET cDesc_error = 'Rebaso el Maximo Numero de operaciones';
					
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion) 
					VALUES (TODAY,cNombre1,cNombre2,cApellPat,cApellMat,cFechaNac,p_sucursal,p_cMontoAPagar,iNumOperMes,(mImpMes + mImpDia),'APP_MES_AUT_OPE',pNum_confirmacion);
					
					RETURN cCod_err, cDesc_error;
					
				--2. Restriccion de listas negras
				ELIF iCuentasListasNegras > 0 THEN
				
					LET cCod_err    = '00006';
					LET cDesc_error = 'Remesa no disponible en Bancoppel';
					
					INSERT INTO  bdisac:"informix".sac_remesaslimitepld_app (fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion) 
					VALUES (TODAY,cNombre1,cNombre2,cApellPat,cApellMat,cFechaNac,p_sucursal,p_cMontoAPagar,iNumOperDia,mImpDia,'APP_LISTA_AUT',pNum_confirmacion);
					
					RETURN cCod_err, cDesc_error;
											
				--3. Limite diario (En pesos)
				ELIF iTotalDiario > cMaxDiario THEN  --valida monto diario
				
					LET cCod_err    = '1100';
					LET cDesc_error = 'Rebaso el Monto Maximo acumulado de abonos al dia';
					
					INSERT INTO  bdisac:"informix".sac_remesaslimitepld_app (fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion) 
					VALUES (TODAY,cNombre1,cNombre2,cApellPat,cApellMat,cFechaNac,p_sucursal,p_cMontoAPagar,iNumOperDia,mImpDia,'APP_DIA_AUT_MN',pNum_confirmacion);
					
					RETURN cCod_err, cDesc_error;
					
				--4. Limite mensual (En pesos)
				ELIF mTotalMensual > cMontoMaxMensual THEN --valida iAcumulado mensual
				
					LET cCod_err    = '1100';
					LET cDesc_error = 'Rebaso el Monto Maximo acumulado de abonos al mes';
					
					INSERT INTO  bdisac:"informix".sac_remesaslimitepld_app (fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion) 
					VALUES (TODAY,cNombre1,cNombre2,cApellPat,cApellMat,cFechaNac,p_sucursal,p_cMontoAPagar,iNumOperMes,(mImpMes + mImpDia),'APP_MES_AUT_MN',pNum_confirmacion);
					
					RETURN cCod_err, cDesc_error;
					
				END IF;
				
			ELSE
			
				LET mImpDiaDolar = vimporte_origen_dia_usd + vimporte_origen_dia_no_usd;
				LET mImpMesDolar = vimporte_origen_mes_usd + vimporte_origen_mes_no_usd;
					
				LET mTotalDiarioDolar 	= mImpDiaDolar + pMontoOrigen;
				LET mTotalMensualDolar 	= mImpMesDolar + mTotalDiarioDolar;
				
				--1. Limite por numero de transacciones (mensual) 
				IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales				
				
					LET cCod_err = '1100';
					LET cDesc_error = 'Rebaso el Maximo Numero de operaciones';
					
					INSERT INTO  bdisac:"informix".sac_remesaslimitepld_app (fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion) 
					VALUES (TODAY,cNombre1,cNombre2,cApellPat,cApellMat,cFechaNac,p_sucursal,pMontoOrigen,iNumOperMes,(mImpMesDolar + mImpDiaDolar),'APP_MES_AUT_OPE',pNum_confirmacion);
					
					RETURN cCod_err, cDesc_error;
					
				--2. Restriccion de listas negras
				ELIF iCuentasListasNegras > 0 THEN
				
					LET cCod_err    = '00006';
					LET cDesc_error = 'Remesa no disponible en Bancoppel';
					
					INSERT INTO  bdisac:"informix".sac_remesaslimitepld_app (fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion) 
					VALUES (TODAY,cNombre1,cNombre2,cApellPat,cApellMat,cFechaNac,p_sucursal,pMontoOrigen,iNumOperDia,mImpDiaDolar,'APP_LISTA_AUT',pNum_confirmacion);
					
					RETURN cCod_err, cDesc_error;
							
				--3. Limite diario (En dolares)
				ELIF mTotalDiarioDolar > cMaxDiarioDolar THEN  --valida monto diario
				
					LET cCod_err    = '1100';
					LET cDesc_error = 'Rebaso el Monto Maximo acumulado de abonos al dia';
					
					INSERT INTO  bdisac:"informix".sac_remesaslimitepld_app (fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion) 
					VALUES (TODAY,cNombre1,cNombre2,cApellPat,cApellMat,cFechaNac,p_sucursal,pMontoOrigen,iNumOperDia,mImpDiaDolar,'APP_DIA_AUT_USD',pNum_confirmacion);
					
					RETURN cCod_err, cDesc_error;
				
				--4. Limite mensual (En dolares)
				ELIF mTotalMensualDolar > cMaxMesDolar THEN --valida iAcumulado mensual
				
					LET cCod_err    = '1100';
					LET cDesc_error = 'Rebaso el Monto Maximo acumulado de abonos al mes';
					
					INSERT INTO  bdisac:"informix".sac_remesaslimitepld_app (fecha,nombre1,nombre2,apellidopaterno,apellidomaterno,fechanacimiento,sucursal,montopagar,numoperaciones,montoacumulado,codigo,numconfirmacion) 
					VALUES (TODAY,cNombre1,cNombre2,cApellPat,cApellMat,cFechaNac,p_sucursal,pMontoOrigen,iNumOperMes,(mImpMesDolar + mImpDiaDolar),'APP_MES_AUT_MN',pNum_confirmacion);
					
					RETURN cCod_err, cDesc_error;
					
				END IF;
				
			END IF;
			
		ELSE
		
			LET cCod_err 	= '1100';
			LET cDesc_error = 'Los parametros enviados son incorrectos';
			
		END IF;
		
		RETURN cCod_err, cDesc_error;
		
	END;
END PROCEDURE;