CREATE PROCEDURE "informix".sp_obtiene_antadcatrespws(pCodigoRespuesta	Char(5), pNumTrama INTEGER)
   RETURNING CHAR(5) as cCodRet, CHAR(60) as cConseptoRespuesta;
      
-- DeclaraciÃ³n de variables 
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cConseptoRespuesta	CHAR(60);

	LET cCodRet				= '00000';
	LET iSqlErr				= 0;
	LET cConseptoRespuesta	= '';
					
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cConseptoRespuesta;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/noe/sp_obtiene_antadcatrespws.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		  
    IF NVL (pCodigoRespuesta, '') = '' THEN
			 LET cCodRet = '00001';
	ELSE
		SELECT concepto INTO cConseptoRespuesta FROM bdisac:"informix".sac_antad_catrespws where clave= pCodigoRespuesta and num_trama = pNumTrama;
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
		ELSE 
			LET cCodRet = '00000';
		END IF;
	END IF;
	
	RETURN cCodRet, NVL(cConseptoRespuesta, '');
		
END;
END PROCEDURE
DOCUMENT
'AUTOR : 93440138 - Noe Medina',
'DESCRIPCION: SP regresa el concepto de el codigo de respuesta a consultar de bdisac: sac_antad_catrespws.',
'FOLIO:',
'FECHA : 07/05/2018',
'VERSION: 20180507.1203',	
'BD: bdisac',
'-------------------------';

CREATE PROCEDURE "informix".sp_valida_dv_selecciones
(
	  pNumRef CHAR (20)
)
RETURNING CHAR(5) AS cod_ret;

DEFINE cCod_ret         CHAR(5);
DEFINE iSqlErr          INTEGER;
DEFINE vDigitoVerif		INTEGER;
DEFINE vPosicion		INTEGER;
DEFINE vSuma 			INTEGER;
DEFINE vResultado 		INTEGER;
DEFINE vUnidad 			INTEGER;
DEFINE vSumaStr			CHAR(3);
DEFINE vMultiplo		INTEGER;
DEFINE vDigito			INTEGER;
DEFINE vDigitoStr		CHAR(2);

LET cCod_ret    	= '00000';
LET iSqlErr     	= 0;
LET vDigitoVerif 	= 0;
LET vResultado		= 0;
LET vSuma 			= 0;
LET vUnidad			= 0;
LET vSumaStr 		= '';
LET vMultiplo		= 2;
LET vDigito			= 0;
LET vDigitoStr		= '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				
				IF iSqlErr='-1213' THEN
					LET cCod_ret = '00004';
				ELSE
					LET cCod_ret = iSqlErr;
				END IF
				
				RETURN cCod_ret;	
			END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		--Validar que el largo de la referencia no sea menor a 20
		IF LEN(pNumRef) < 20 THEN
			LET cCod_ret = '00002';
			RETURN cCod_ret;	
		END IF;
		
		--SET DEBUG FILE TO '/informix/Aaron/sp_valida_dv_selecciones.out';
		--TRACE ON;
		
		--Validar que la referencia no venga en 0's
		IF pNumRef = '00000000000000000000' THEN
			LET cCod_ret = '00003';
			RETURN cCod_ret;
		END IF;
		
		--Respaldamos el digito verificador de la referencia
		LET vDigitoVerif = (CAST(SUBSTR(pNumRef,20,1) AS INTEGER));
		
		--Generamos la referencia con el digito verificador en 0
		LET pNumRef = SUBSTR(pNumRef,1,19) || '0';
		
		--Generar la suma considerando el digito verificador como 0
		FOR vPosicion=1 TO 20 LOOP
			--LET vDigito = 14;
			LET vDigito = CAST(SUBSTR(pNumRef, vPosicion,1) AS INTEGER) * vMultiplo;
			
			IF vDigito > 9 THEN
				LET vDigitoStr = CAST(vDigito AS CHAR(2));
				LET vDigito = CAST(SUBSTR(vDigitoStr,1,1)AS INTEGER) + CAST(SUBSTR(vDigitoStr,2,1)AS INTEGER);
			END IF;
			
			LET vSuma = vSuma + vDigito;
			
			IF vMultiplo = 2 THEN
				LET vMultiplo = 1;
			ELSE
				LET vMultiplo = 2;
			END IF;
			
		END LOOP;
		
		--Generamos la suma en cadena
		LET vSumaStr = CAST(vSuma AS INTEGER);
		
		--Obtenemos la unidad de la suma
		LET vUnidad = CAST(SUBSTR(vSumaStr,LEN(vSumaStr),1)AS INTEGER);
		
		--A 10 le restamos la unidad del resultado de la suma
		LET vResultado = 10 - vUnidad;

		--Validamos que el digito verificador sea igual al resultado
		IF vResultado <> vDigitoVerif THEN
			LET cCod_ret = '00109';
			RETURN cCod_ret;
		END IF;

		RETURN cCod_ret;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Aaron Lopez Ruiz',
'FOLIO: ',
'DESCRIPCION: Valida el digito verificador de la referencia de SELECCIONES',
'FECHA: 18/09/2018',
'VERSION: 1.0',
'BD:Bdisac';

CREATE PROCEDURE "informix".sp_app_valmonto_aut(pNum_confirmacion CHAR(16), pCta_benef CHAR(20), p_sucursal CHAR(4), p_cMontoAPagar CHAR(20), pMonedaOrigen CHAR(3), pMontoOrigen MONEY(14,2), pNumCte CHAR(20))
    
	RETURNING
	CHAR(5)   AS Codigo_Error,
	CHAR(150) AS Desc_Error;
 
    --Definicion de Variables
    DEFINE cCod_err      				CHAR(5);
	DEFINE cDesc_error     				CHAR(150);
	DEFINE vCodRet						CHAR(5);
	DEFINE iSqlErr						INTEGER;
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
	DEFINE vimporte_pago				MONEY(16,2);
	DEFINE vimporte_origen				MONEY(16,2);
	DEFINE vmoneda_origen				VARCHAR(3);
	DEFINE vfecha_pago					DATE;
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
	
	
	--SET DEBUG FILE TO '/informix/lfp/temp/exec_sp_app_valmonto_aut_v2.out';
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
		
		IF  NVL(pNum_confirmacion,"") <> "" AND NVL(pCta_benef,"") <> "" AND NVL(p_sucursal,"") <> "" AND NVL(p_cMontoAPagar,"") <> ""
		AND NVL(pMonedaOrigen,"") <> "" AND NVL(pNumCte,"") <> "" THEN
		
			--Obtener el primer dia del mes y la fecha actual de Servicios
			SELECT pri_dia_mes, fecha_hoy 
			INTO   dPri_dia_mes, dFechaHoy
			FROM   bdisac:"informix".sac_fechas;
			
			--Obtener datos del cliente
			SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
			INTO   cNombre1, cNombre2, cApellPat, cApellMat, cRfc
			FROM   bdinteg:"informix".si_cliente 
			WHERE  numcte  = pNumCte
			AND    empresa ='001';
			
			SELECT TO_CHAR(fecha_nac,'%Y%m%d')
			INTO   cFechaNac
			FROM   bdinteg:"informix".si_ctepf  
			WHERE  numcte  = pNumCte 
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
			
			--Inicializaciones
			LET vimporte_pago_dia_usd   = 0;	LET vimporte_pago_dia_no_usd   = 0;		LET vimporte_pago_mes_usd   = 0;	LET vimporte_pago_mes_no_usd   = 0;
			LET vimporte_origen_dia_usd = 0;	LET vimporte_origen_dia_no_usd = 0;		LET vimporte_origen_mes_usd = 0;	LET vimporte_origen_mes_no_usd = 0;
			LET vcuenta_dia_usd         = 0; 	LET vcuenta_dia_no_usd         = 0;		LET vcuenta_mes_usd         = 0;	LET vcuenta_mes_no_usd         = 0;
			
			--Obtengo cifras pagadas durante el mes para el beneficiario
			FOREACH
				SELECT importe_pago, importe_origen, moneda_origen, fecha_pago
				INTO   vimporte_pago, vimporte_origen, vmoneda_origen, vfecha_pago
				FROM   sac_remesas_estadistica
				WHERE  rfc               =  cRfc
				AND    numcategoria      =  '07'
				AND    numconvenio       =  '009'
				AND    fecha_pago       >=  dPri_dia_mes
				AND    fecha_pago       <=  dFechaHoy
				AND    status_cancelado !=  'S'
				AND    origen            IN ('A', 'C')
				
					--Quito nulos
					IF vimporte_pago   IS NULL THEN LET vimporte_pago = 0;   END IF;
					IF vimporte_origen IS NULL THEN LET vimporte_origen = 0; END IF;
					
					--Asigno segun sea el caso
					IF vmoneda_origen = 'USD' AND vfecha_pago = dFechaHoy THEN
						LET vimporte_pago_dia_usd   = vimporte_pago_dia_usd + vimporte_pago;
						LET vimporte_origen_dia_usd = vimporte_origen_dia_usd + vimporte_origen;
						LET vcuenta_dia_usd         = vcuenta_dia_usd + 1; 
					END IF;
					IF vmoneda_origen != 'USD' AND vfecha_pago = dFechaHoy THEN
						LET vimporte_pago_dia_no_usd   = vimporte_pago_dia_no_usd + vimporte_pago;
						LET vimporte_origen_dia_no_usd = vimporte_origen_dia_no_usd + vimporte_origen;
						LET vcuenta_dia_no_usd         = vcuenta_dia_no_usd + 1;
					END IF;
					IF vmoneda_origen = 'USD' AND vfecha_pago != dFechaHoy THEN
						LET vimporte_pago_mes_usd   = vimporte_pago_mes_usd + vimporte_pago;
						LET vimporte_origen_mes_usd = vimporte_origen_mes_usd + vimporte_origen;
						LET vcuenta_mes_usd         = vcuenta_mes_usd + 1;
					END IF;
					IF vmoneda_origen != 'USD' AND vfecha_pago != dFechaHoy THEN
						LET vimporte_pago_mes_no_usd   = vimporte_pago_mes_no_usd + vimporte_pago;
						LET vimporte_origen_mes_no_usd = vimporte_origen_mes_no_usd + vimporte_origen;
						LET vcuenta_mes_no_usd         = vcuenta_mes_no_usd + 1;
					END IF;
				
			END FOREACH;
			
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