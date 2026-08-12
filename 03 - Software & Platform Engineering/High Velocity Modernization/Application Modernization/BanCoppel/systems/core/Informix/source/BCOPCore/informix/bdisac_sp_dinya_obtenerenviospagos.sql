CREATE PROCEDURE "informix".sp_dinya_obtenerenviospagos
	(pConvenio CHAR(3),
	pImporte1 CHAR (16),
	pImporte2 CHAR (16),
	pSucursal_Origen CHAR(4),
	pNombre1_rem CHAR(26),
	pNombre2_rem CHAR(26),
	pApellido1_rem CHAR(26),
	pApellido2_rem CHAR(26),
	pFechaEnvio1 DATE,
	pFechaEnvio2 DATE,
	pNombre1_ben CHAR(26),
	pNombre2_ben CHAR(26),
	pApellido1_ben CHAR(26),
	pApellido2_ben CHAR(26))
RETURNING  CHAR(5),CHAR(12),DATE,CHAR(4),CHAR(26),CHAR(26),CHAR(26),CHAR(26),MONEY (16,2),CHAR(20);

DEFINE cCodRet 			CHAR(5);
DEFINE dFechaEnvio 		DATE;
DEFINE cSucursalOrigen 	CHAR(4);
DEFINE cNombre1Rem 		CHAR(26);
DEFINE cNombre2Rem 		CHAR(26);
DEFINE cApellido1Rem 	CHAR(26);
DEFINE cApellido2Rem 	CHAR(26);
DEFINE mImporteEnviado 	MONEY (16,2);
DEFINE cStatus 			CHAR(20);
DEFINE cNoControl		CHAR(12);
DEFINE iSqlErr			INTEGER;
DEFINE isam_error		INTEGER;
DEFINE cMensaje			CHAR(50);
DEFINE dfechoy			DATE;

BEGIN

	ON EXCEPTION SET iSqlErr,isam_error,cMensaje
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (iSqlErr,isam_error,cMensaje,'sp_DinYa_ObtenerEnviosPagos',dfechoy,CURRENT );
			RETURN cCodRet,cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus;
		END IF;
	END EXCEPTION;

--SET DEBUG FILE TO "/tmp/Antonio/sp_DinYa_ObtenerEnviosPagos.out";
--TRACE ON;

 LET cCodRet 			= '00000';
 LET dFechaEnvio 		= '';
 LET cSucursalOrigen 	= '';
 LET cNombre1Rem 		= '';
 LET cNombre2Rem 		= '';
 LET cApellido1Rem 		= '';
 LET cApellido2Rem 		= '';
 LET mImporteEnviado 	= '0.00';
 LET cStatus 			= '';
 LET cNoControl			= '';
 LET cMensaje			= '';
 LET dfechoy			= '';
 LET iSqlErr			= 0;
 LET isam_error			= 0;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;



 IF pConvenio = '' THEN
	LET pConvenio = '001';
 END IF;

 SELECT fecha_hoy INTO dfechoy FROM bdisac:sac_fechas;

 IF pImporte1 = '0.00' AND pImporte2 = '0.00' OR pImporte1 = '' AND pImporte2 = '' THEN
	FOREACH WITH HOLD
		SELECT  DISTINCT(LPAD(envio.no_control,12,'0')),envio.fecha_envio,envio.suc_origen,envio.pri_nom_rem,envio.seg_nom_rem,envio.apell_pat_rem,envio.apell_mat_rem,envio.importe_envio,est.descripcion
		INTO cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus
		FROM sac_enviosdineroya envio,
		OUTER sac_movimientos mov,
		OUTER sac_movimientoshistorial his,
			  sac_estatus est
		WHERE envio.no_control = mov.referencia1
				AND envio.no_control = his.referencia1
				AND (his.numconvenio = pConvenio AND mov.numconvenio = pConvenio)
				AND envio.fecha_envio >= 	pFechaEnvio1
				AND envio.fecha_envio <= 	pFechaEnvio2
				AND envio.estatus = est.estatus
				AND envio.suc_origen = CASE WHEN pSucursal_Origen = "" THEN envio.suc_origen  ELSE pSucursal_Origen END
				AND envio.pri_nom_rem = CASE WHEN pNombre1_rem = "" THEN envio.pri_nom_rem  ELSE pNombre1_rem END
				AND envio.seg_nom_rem = CASE WHEN pNombre2_rem = "" THEN envio.seg_nom_rem  ELSE pNombre2_rem END
				AND envio.apell_pat_rem = CASE WHEN pApellido1_rem = "" THEN envio.apell_pat_rem  ELSE pApellido1_rem END
				AND envio.apell_mat_rem = CASE WHEN pApellido2_rem = "" THEN envio.apell_mat_rem  ELSE pApellido2_rem END
				AND envio.pri_nom_ben = CASE WHEN pNombre1_ben = "" THEN envio.pri_nom_ben  ELSE pNombre1_ben END
				AND envio.seg_nom_ben = CASE WHEN pNombre2_ben = "" THEN envio.seg_nom_ben  ELSE pNombre2_ben END
				AND envio.apell_pat_ben = CASE WHEN pApellido1_ben = "" THEN envio.apell_pat_ben  ELSE pApellido1_ben END
				AND envio.apell_mat_ben = CASE WHEN pApellido2_ben = "" THEN envio.apell_mat_ben  ELSE pApellido2_ben END

		UNION ALL

		SELECT  DISTINCT(LPAD(envio.no_control,12,'0')),envio.fecha_envio,envio.suc_origen,envio.pri_nom_rem,envio.seg_nom_rem,envio.apell_pat_rem,envio.apell_mat_rem,envio.importe_envio,est.descripcion
		FROM sac_enviosdineroyahis envio,
		OUTER sac_movimientos mov,
		OUTER sac_movimientoshistorial his,
		      sac_estatus est
		WHERE envio.no_control = mov.referencia1
				AND envio.no_control = his.referencia1
				AND (his.numconvenio = pConvenio AND mov.numconvenio = pConvenio)
				AND  envio.fecha_envio >= 	pFechaEnvio1
				AND envio.fecha_envio <= 	pFechaEnvio2
				AND envio.estatus = est.estatus
				AND envio.suc_origen = CASE WHEN pSucursal_Origen = "" THEN envio.suc_origen  ELSE pSucursal_Origen END
				AND envio.pri_nom_rem = CASE WHEN pNombre1_rem = "" THEN envio.pri_nom_rem  ELSE pNombre1_rem END
				AND envio.seg_nom_rem = CASE WHEN pNombre2_rem = "" THEN envio.seg_nom_rem  ELSE pNombre2_rem END
				AND envio.apell_pat_rem = CASE WHEN pApellido1_rem = "" THEN envio.apell_pat_rem  ELSE pApellido1_rem END
				AND envio.apell_mat_rem = CASE WHEN pApellido2_rem = "" THEN envio.apell_mat_rem  ELSE pApellido2_rem END
				AND envio.pri_nom_ben = CASE WHEN pNombre1_ben = "" THEN envio.pri_nom_ben  ELSE pNombre1_ben END
				AND envio.seg_nom_ben = CASE WHEN pNombre2_ben = "" THEN envio.seg_nom_ben  ELSE pNombre2_ben END
				AND envio.apell_pat_ben = CASE WHEN pApellido1_ben = "" THEN envio.apell_pat_ben  ELSE pApellido1_ben END
				AND envio.apell_mat_ben = CASE WHEN pApellido2_ben = "" THEN envio.apell_mat_ben  ELSE pApellido2_ben END

		RETURN cCodRet,cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus WITH RESUME;
	 END FOREACH;
 ELSE
	FOREACH WITH HOLD
		SELECT  DISTINCT(LPAD(envio.no_control,12,'0')),envio.fecha_envio,envio.suc_origen,envio.pri_nom_rem,envio.seg_nom_rem,envio.apell_pat_rem,envio.apell_mat_rem,envio.importe_envio,est.descripcion
		INTO cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus
		FROM sac_enviosdineroya envio,
		OUTER sac_movimientos mov,
		OUTER sac_movimientoshistorial his,
		      sac_estatus est
		WHERE envio.no_control = mov.referencia1
				AND envio.no_control = his.referencia1
				AND (his.numconvenio = pConvenio AND mov.numconvenio = pConvenio)
				AND  envio.fecha_envio >= 	pFechaEnvio1
				AND envio.fecha_envio <= 	pFechaEnvio2
				AND envio.importe_envio >= pImporte1
			    AND envio.importe_envio <=  pImporte2
				AND envio.estatus = est.estatus
				AND envio.suc_origen = CASE WHEN pSucursal_Origen = "" THEN envio.suc_origen  ELSE pSucursal_Origen END
				AND envio.pri_nom_rem = CASE WHEN pNombre1_rem = "" THEN envio.pri_nom_rem  ELSE pNombre1_rem END
				AND envio.seg_nom_rem = CASE WHEN pNombre2_rem = "" THEN envio.seg_nom_rem  ELSE pNombre2_rem END
				AND envio.apell_pat_rem = CASE WHEN pApellido1_rem = "" THEN envio.apell_pat_rem  ELSE pApellido1_rem END
				AND envio.apell_mat_rem = CASE WHEN pApellido2_rem = "" THEN envio.apell_mat_rem  ELSE pApellido2_rem END
				AND envio.pri_nom_ben = CASE WHEN pNombre1_ben = "" THEN envio.pri_nom_ben  ELSE pNombre1_ben END
				AND envio.seg_nom_ben = CASE WHEN pNombre2_ben = "" THEN envio.seg_nom_ben  ELSE pNombre2_ben END
				AND envio.apell_pat_ben = CASE WHEN pApellido1_ben = "" THEN envio.apell_pat_ben  ELSE pApellido1_ben END
				AND envio.apell_mat_ben = CASE WHEN pApellido2_ben = "" THEN envio.apell_mat_ben  ELSE pApellido2_ben END

		UNION ALL

		SELECT  DISTINCT(LPAD(envio.no_control,12,'0')),envio.fecha_envio,envio.suc_origen,envio.pri_nom_rem,envio.seg_nom_rem,envio.apell_pat_rem,envio.apell_mat_rem,envio.importe_envio,est.descripcion
		FROM sac_enviosdineroyahis envio,
		OUTER sac_movimientos mov,
		OUTER sac_movimientoshistorial his,
		      sac_estatus est
		WHERE envio.no_control = mov.referencia1
				AND envio.no_control = his.referencia1
				AND envio.importe_envio >= pImporte1
			    AND envio.importe_envio <=  pImporte2
				AND (his.numconvenio = pConvenio AND mov.numconvenio = pConvenio)
				AND  envio.fecha_envio >= 	pFechaEnvio1
				AND envio.fecha_envio <= 	pFechaEnvio2
				AND envio.estatus = est.estatus
				AND envio.suc_origen = CASE WHEN pSucursal_Origen = "" THEN envio.suc_origen  ELSE pSucursal_Origen END
				AND envio.pri_nom_rem = CASE WHEN pNombre1_rem = "" THEN envio.pri_nom_rem  ELSE pNombre1_rem END
				AND envio.seg_nom_rem = CASE WHEN pNombre2_rem = "" THEN envio.seg_nom_rem  ELSE pNombre2_rem END
				AND envio.apell_pat_rem = CASE WHEN pApellido1_rem = "" THEN envio.apell_pat_rem  ELSE pApellido1_rem END
				AND envio.apell_mat_rem = CASE WHEN pApellido2_rem = "" THEN envio.apell_mat_rem  ELSE pApellido2_rem END
				AND envio.pri_nom_ben = CASE WHEN pNombre1_ben = "" THEN envio.pri_nom_ben  ELSE pNombre1_ben END
				AND envio.seg_nom_ben = CASE WHEN pNombre2_ben = "" THEN envio.seg_nom_ben  ELSE pNombre2_ben END
				AND envio.apell_pat_ben = CASE WHEN pApellido1_ben = "" THEN envio.apell_pat_ben  ELSE pApellido1_ben END
				AND envio.apell_mat_ben = CASE WHEN pApellido2_ben = "" THEN envio.apell_mat_ben  ELSE pApellido2_ben END

		RETURN cCodRet,cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus WITH RESUME;
	 END FOREACH;
 END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta los envios del convenio 001',
'AUTOR: Antonio Bastidas',
'FECHA: 11 de Noviembre de 2009',
'MODIFICO: Armando Mercado',
'DESCRIPCION: Se modifica para que en lugar de regresar el codigo del estatus regresara la descripcion del estatus',
'BD: BDISAC',
'VERSION: 20100428.1851';

CREATE PROCEDURE "informix".sp_app_valmonto(pEmpresa CHAR(3), pNombre1 CHAR(40), pNombre2 CHAR(40), pApellPat CHAR(40), pApellMat CHAR(40), pFechaNac CHAR(8), pFechaHoy CHAR(10), pMontoPaga CHAR(20),pSucursal CHAR(4),p_moneda CHAR(3),cMontoDolares Money(16,2),pNum_confirmacion CHAR(16))

	RETURNING 
	CHAR(6) AS CodRet;
	
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err      				INTEGER;
    DEFINE cCodRet      				CHAR(6);
	DEFINE vCodRet						CHAR(5);
	DEFINE cAnio						CHAR(4);
	DEFINE cDia							CHAR(2);
	DEFINE cMes             			CHAR(2);
	DEFINE cAnioFecHoy					CHAR(4);
	DEFINE dTotalMensual				DECIMAL(16,2);
	DEFINE dPri_dia_mes					DATE;	
	DEFINE cMaxDiario					DECIMAL(16,2);
	DEFINE cMaxMes						DECIMAL(16,2);
	DEFINE iMaxOperaciones				INTEGER;
	DEFINE cMaxSuc	        			MONEY(16,2); 
	DEFINE dTotalDiario					DECIMAL(8,2);
	DEFINE iCont						INTEGER;
	DEFINE iNumOperDia					INTEGER;	
	DEFINE iNumOperMes					INTEGER;
	DEFINE cImpDia						DECIMAL(16,2);
	DEFINE cImpMes						DECIMAL(16,2);
	DEFINE dMaxDiarioDolar  			DECIMAL(16,2); --222
	DEFINE dImpPagoDolar 				DECIMAL(16,2);
	DEFINE dImpPagoMesDolar 			DECIMAL(16,2);
	DEFINE dMaxMesDolar 				DECIMAL(16,2);
	DEFINE mMaxSucDolar	    			MONEY(16,2);
	DEFINE mMaxEdo						MONEY(16,2);
	DEFINE mMaxEdoDolar	    			MONEY(16,2);
	DEFINE cNumEdo						CHAR(5);
	DEFINE dImpDiaDolar 				DECIMAL(16,2);
	DEFINE mImpMesDolar 				MONEY(16,2);
	DEFINE iNumMovsNoUSDHist			INTEGER;
	DEFINE iNumMovsNoUSD				INTEGER;
	DEFINE cFechaHoy					CHAR(10);
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
	DEFINE iRfc_val						INTEGER;
	DEFINE cUsr							CHAR(4);
	LET iCuentasListasNegras			= 0;
	
	--INICIALIZACION DE VARIABLES--
    LET sql_err 						= 0;
    LET cCodRet 						= '000000';
	LET cAnio							= '';
	LET cDia							= '';
	LET cMes            				= '';
	LET cAnioFecHoy						= '';
	LET dTotalMensual     				= 0.00;
	LET dPri_dia_mes					= '';	
	LET cMaxDiario						= 0.00;
	LET cMaxMes							= 0.00;
	LET iMaxOperaciones 				= 0;
	LET cMaxSuc         				= 0.00;
	LET dTotalDiario       				= 0.00;
	LET iCont							= 1;
	LET iNumOperDia						= 0;	
	LET iNumOperMes						= 0;
	LET cImpDia							= 0.00;
	LET cImpMes							= 0.00;
	LET dMaxDiarioDolar 				= 0.00;
	LET dImpPagoDolar 					= 0.00;
	LET dImpPagoMesDolar				= 0.00;
	LET dMaxMesDolar 					=0.00;
	LET mMaxSucDolar    				= 0.00;
	LET mMaxEdo							=0.00;
	LET mMaxEdoDolar					=0.00;
	LET cNumEdo 						='';
	LET dImpDiaDolar 					= 0.00;
	let mImpMesDolar 					= 0.00;
	LET iNumMovsNoUSDHist				= 0;
	LET iNumMovsNoUSD					= 0;
	LET cFechaHoy       				= '';
	LET dFechaHoy						= '';
	LET cRfc							= '';
	LET cNombres						= '';
	LET dFechaNac						= '';
	LET iRfc_val						= 0;
	LET cUsr							= '';
	
	--SET DEBUG FILE TO '/informix/RPT/prueba_sp_val_monto.out';
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
		IF NVL(pEmpresa,'') = '' OR NVL(pNombre1,'') = '' OR NVL(pApellPat,'') = '' OR NVL(pFechaNac,'') = '' OR NVL(pFechaHoy,'')='' OR NVL(pMontoPaga,'')='' THEN
			LET cCodRet =   '00170'; --Faltan parametros
			RETURN cCodRet;
		END IF;
		
	-- validar los primeros 4 caracteres correspondan al anio es decir que sea mayor al anio 1900 hasta el anio actual, aaaammdd.
		LET cAnio = SUBSTR(pFechaNac,1,4);
		LET cDia = SUBSTR(pFechaNac,7,2);
		LET cMes = SUBSTR(pFechaNac,5,2);
			
			--PRODUCTIVO
			IF YEAR(pFechaHoy)<= YEAR(CURRENT) THEN
				LET cAnioFecHoy= YEAR(pFechaHoy); --Anio actual
			END IF;
		
			--PRUEBAS 
			--IF YEAR(pFechaHoy)<= YEAR(CURRENT) THEN
				--LET cAnioFecHoy=  SUBSTR(pFechaHoy,7,10); --Anio actual
				--LET cAnioFecHoy=  SUBSTR(pFechaHoy,5,4); --Anio actual
			--END IF; 
			
			IF cAnio BETWEEN 1900 AND cAnioFecHoy AND cMes BETWEEN 01 AND 12 AND cDia BETWEEN 01 AND 31 THEN
			LET cFechaHoy = SUBSTRING(pFechaHoy FROM 5 FOR 4)||SUBSTRING(pFechaHoy FROM 1 FOR 2)||SUBSTRING(pFechaHoy FROM 3 FOR 2);
			SELECT pri_dia_mes 
			INTO dPri_dia_mes
			FROM "informix".sac_fechas;
					
					
				LET cNombres  = TRIM(pNombre1) || " " || TRIM(pNombre2);
				LET dFechaNac = MDY(SUBSTRING(pFechaNac FROM 5 FOR 2) ,SUBSTRING(pFechaNac FROM 7 FOR 2) ,SUBSTRING(pFechaNac FROM 1 FOR 4));
				--Calculo el RFC del beneficiario
				EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(pApellPat, pApellMat, cNombres, dFechaNac)
				INTO vCodRet, cRfc;
				
				SELECT COUNT(*) INTO iRfc_val FROM bdinteg:"informix".si_cliente WHERE rfc = cRfc;
				
				IF iRfc_val = 0 THEN --Separamos los limites de los clientes y de los usuarios
					--Limites por usuario
					
					SELECT PESOS,USD 
					INTO cMaxDiario,dMaxDiarioDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_DIA_'
					AND status = 1;
					
					SELECT PESOS,USD 
					INTO cMaxMes,dMaxMesDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_MES_'
					AND status = 1;
					
					SELECT operaciones 
					INTO iMaxOperaciones
					FROM "informix".sac_limite_monto
					where abreviatura = 'APP_MES_'
					and status = 1;
					
					SELECT pesos,usd 
					INTO cMaxSuc,mMaxSucDolar
					FROM "informix".sac_limite_suc_usuario 
					WHERE abreviatura = 'APP_DIA_' 
					AND sucursal = pSucursal --(buscar la suc
					AND status = 1;
					
					--limite por estado
					SELECT estado
					INTO cNumEdo
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = pSucursal;
					
					SELECT PESOS,USD 
					INTO mMaxEdo, mMaxEdoDolar
					FROM "informix".sac_limite_edo_usuario 
					WHERE abreviatura = 'APP_DIA_'
					AND estado = cNumEdo
					AND status = 1;
					
					LET cUsr = '_USR';
					
				ELIF iRfc_val >= 1 THEN --EPG 25032025
					--Limites por cliente
				
					SELECT PESOS,USD 
					INTO cMaxDiario,dMaxDiarioDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_DIA_'
					AND status = 1;
				
					SELECT PESOS,USD 
					INTO cMaxMes,dMaxMesDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_MES_'
					AND status = 1;
				
					SELECT operaciones 
					INTO iMaxOperaciones
					FROM "informix".sac_limite_monto
					where abreviatura = 'APP_MES_'
					and status = 1;						
				
					SELECT pesos,usd 
					INTO cMaxSuc,mMaxSucDolar
					FROM "informix".sac_limite_suc 
					WHERE abreviatura = 'APP_DIA_' 
					AND sucursal = pSucursal --(buscar la sucursal en donde se esta realizando la remesa) 
					AND status = 1;
					
					--limite por estado
					SELECT estado
					INTO cNumEdo
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = pSucursal;
					
					SELECT PESOS,USD 
					INTO mMaxEdo, mMaxEdoDolar
					FROM "informix".sac_limite_edo
					WHERE abreviatura = 'APP_DIA_'
					AND estado = cNumEdo
					AND status = 1;
					
				END IF; --Fin validacion de limites por ususario y cliente
				
				IF cMaxSuc IS NULL OR cMaxSuc = '' THEN
					LET cMaxSuc = 0;
				END IF;
				
				IF mMaxSucDolar IS NULL OR mMaxSucDolar = '' THEN
					LET mMaxSucDolar = 0;
				END IF;
				
				LET dFechaHoy = TODAY;
				
				
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
				AND    numconvenio       IN ('009')
				AND    fecha_pago       >=  dPri_dia_mes
				AND    fecha_pago       <=  dFechaHoy
				AND    status_cancelado !=  'S'
				AND    origen            in ('V','T');
				
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
				
				--222 si existe por lo menos uno distintio de USD OBTENEMOS LOS VALORES EN PESOS
				IF iNumMovsNoUSDHist > 0 OR p_moneda <> 'USD' THEN
				
					LET cImpDia	= vimporte_pago_dia_usd + vimporte_pago_dia_no_usd;
					LET cImpMes	= vimporte_pago_mes_usd + vimporte_pago_mes_no_usd;
				
					--Caso de que algun movimiento (incluyendo el de la peticion) sea diferente de dolares
					LET dTotalDiario  = cImpDia + pMontoPaga;
					LET dTotalMensual = cImpMes + dTotalDiario;
					
					--1. Limite por nÃ?Â?Ã?Âºmero de transacciones (mensual)
					IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
						LET cCodRet= '000157';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperMes, cImpMes + cImpDia, 'APP_MES_OPE' || cUsr,pNum_confirmacion);
				
						--2. Limite diario por sucursal pesos
					ELIF cMaxSuc > 0 AND (dTotalDiario > cMaxSuc) THEN  --valida monto diario por sucursal
						LET cCodRet= '000158';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_DIA_SUC_MN' || cUsr,pNum_confirmacion);		
				
						--3. Limite por estado pesos
					ELIF mMaxEdo > 0 AND (dTotalDiario > mMaxEdo) THEN  --valida monto diario por 
						LET cCodRet= '000159';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_DIA_EDO_MN' || cUsr,pNum_confirmacion);		
					
						--4. Restriccion de listas negras
					ELIF iCuentasListasNegras > 0 THEN
						LET cCodRet= '000160';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_LISTA' || cUsr,pNum_confirmacion);			
				
						--5. Limite diario pesos
					ELIF dTotalDiario > cMaxDiario THEN  --valida monto diario					
						LET cCodRet= '000161';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_DIA_MN' || cUsr,pNum_confirmacion);			
				
						--6. LiÃ?Â­mite mensual  pesos
					ELIF dTotalMensual > cMaxMes THEN --valida acumulado mensual
						LET cCodRet= '000162';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperMes, cImpMes + cImpDia, 'APP_MES_MN' || cUsr,pNum_confirmacion);					
					END IF;				
				ELSE
					
					LET dImpDiaDolar = vimporte_origen_dia_usd + vimporte_origen_dia_no_usd;
					LET mImpMesDolar = vimporte_origen_mes_usd + vimporte_origen_mes_no_usd;
															
					LET dImpPagoDolar = dImpDiaDolar + cMontoDolares;
					LET dImpPagoMesDolar = mImpMesDolar + dImpPagoDolar;
					
					IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
						LET cCodRet= '000164';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperMes, mImpMesDolar + dImpDiaDolar, 'APP_MES_OPE' || cUsr,pNum_confirmacion);
						
						--2. LiÃ?Â­mite diario por sucursal dolares
					ELIF mMaxSucDolar > 0 AND (dImpPagoDolar > mMaxSucDolar) THEN  --valida monto diario por sucursal
						LET cCodRet= '000165';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_DIA_SUC_USD' || cUsr,pNum_confirmacion);		
				
						--3. Limite por estado dolares
					ELIF mMaxEdoDolar > 0 AND (dImpPagoDolar > mMaxEdoDolar) THEN  --valida monto diario por sucursal
						LET cCodRet= '000166';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_DIA_EDO_USD' || cUsr,pNum_confirmacion);	
					
						--4. Restriccion de listas negras
					ELIF iCuentasListasNegras > 0 THEN
						LET cCodRet= '000160';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_LISTA' || cUsr,pNum_confirmacion);
										
						--5. Limite diario dolares
					ELIF dImpPagoDolar > dMaxDiarioDolar THEN  --valida monto diario					
						LET cCodRet= '000167';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_DIA_USD' || cUsr,pNum_confirmacion);			
				
						--6. LiÃ?Â­mite mensual dolares
					ELIF dImpPagoMesDolar > dMaxMesDolar THEN --valida acumulado mensual
						LET cCodRet= '000168';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperMes,mImpMesDolar + dImpDiaDolar, 'APP_MES_USD' || cUsr,pNum_confirmacion);
						
					End if;
				
				END if;
				----7. LiÃ?Â­mite acumulado en todas las remesas
				IF cCodRet = '000000' THEN						
					EXECUTE PROCEDURE bdisac:"informix".sp_validamontos(pEmpresa,pNombre1,pNombre2,pApellPat,pApellMat,pFechaNac,cFechaHoy,pMontoPaga,pSucursal,p_moneda,cMontoDolares,'APP' || cUsr,pNum_confirmacion,cRfc,dPri_dia_mes)
					INTO cCodRet;
					
					IF cCodRet = '00001' THEN  --Se excedio en dolares
						LET cCodRet = '000169';
					END IF;
					
					IF cCodRet = '00002' THEN  --Se excedio en pesos
						LET cCodRet = '000163';
					END IF;
				END IF;	
						
			ELSE 
				LET cCodRet= '000170';
			END IF;
		RETURN cCodRet;
		
	END 
END PROCEDURE
DOCUMENT
'Obtiene el monto diario y mensual para cobros Appriza',
'AUTOR : Pedro G Jimenez Guzman',
'FECHA : 13-abril-2016',
'BD    : BDISAC',
'Se agrega nueva validacion de dolares y agregan nuevas a pesos',
'AUTOR : Viridiana Paredes Romero',
'FECHA : 29-05-2017',
'BD    : BDISAC',
'Se agrega nueva validacion para los RFC duplicados',
'AUTOR : Eduardo Pineda Guzman',
'FECHA : 25-03-2025',
'BD    : BDISAC';

CREATE PROCEDURE "informix".sp_consulta_cardif_nuevolm(pNumcte CHAR(20), pAsegurado_Nombre1 CHAR(26), pAsegurado_Nombre2 CHAR(26), pAsegurado_Apell_Pat CHAR(26), pAsegurado_Apell_Mat CHAR(26), pAsegurado_FechaNac DATE)

RETURNING
CHAR(5)	    AS  cCodRet,
CHAR(20)    AS  cNumcte,
CHAR(26)    AS  cNombre1,
CHAR(26)    AS  cNombre2,
CHAR(26)    AS  cApell_paterno,
CHAR(26)    AS  cApell_materno,
CHAR(13)    AS  cRfc,
CHAR(2)	    AS	cEstado,
CHAR(3)	    AS  cCiudad,
CHAR(11)    AS  cColonia,
CHAR(11)    AS  cCalle,
CHAR(10)    AS  cNumExt,
CHAR(10)    AS  cNumInt,
CHAR(5)	    AS  cCP,
CHAR(13)    AS  cCelular,
CHAR(100)   AS  cCorreo, 
CHAR(1)	    AS  cFlagSeguro,
CHAR(50)    AS  cNumPoliza,
CHAR(1024)	AS  cTramaMigrantesBD,
DATE 		AS  cFechaNacimiento

--Variables de retorno
DEFINE cCodRet			 CHAR(5);
DEFINE cNumcte           CHAR(20);
DEFINE cNombre1          CHAR(26);
DEFINE cNombre2          CHAR(26);
DEFINE cApell_paterno    CHAR(26);
DEFINE cApell_materno    CHAR(26);
DEFINE cRfc              CHAR(13);
DEFINE cEstado           CHAR(2);  
DEFINE cCiudad           CHAR(3);  
DEFINE cColonia          CHAR(11);
DEFINE cCalle            CHAR(11);
DEFINE cNumExt           CHAR(10);
DEFINE cNumInt           CHAR(10);
DEFINE cCP               CHAR(5);  
DEFINE cCelular          CHAR(13);
DEFINE cCorreo           CHAR(100);
DEFINE cFlagSeguro       CHAR(1);  
DEFINE cNumPoliza        CHAR(50);
DEFINE cTramaMigrantesBD CHAR(1024);
DEFINE cFechaNacimiento  DATE ;

--Variables internas
DEFINE iExisteCte 	 INTEGER;
DEFINE iExisteCteRem INTEGER;
DEFINE iSqlErr       INTEGER; 
DEFINE iIsamErr    	 INTEGER; 
DEFINE cInfoErr 	 CHAR(10); 
DEFINE cCodRetRfc	 CHAR(5);
DEFINE cTramaMigrantesAux CHAR(1024);
DEFINE iSecDireccion INTEGER;
DEFINE cStatuConv	 CHAR(1);
DEFINE cNombresAseg	 CHAR(70);
DEFINE iSegActivos   INTEGER;
DEFINE cEstatusMig	 CHAR(2);

DEFINE v_Conteo		INTEGER;

--SET DEBUG FILE TO "/informix/HMLG/sp_consulta_cardif.out";
--TRACE ON;	

--Asignacion de valores default
LET cCodRet			  = "00000";
LET cNumcte           = "";
LET cNombre1          = "";
LET cNombre2          = "";
LET cApell_paterno    = "";
LET cApell_materno    = "";
LET cRfc              = "";
LET cEstado           = "";
LET cCiudad           = "";
LET cColonia          = "";
LET cCalle            = "";
LET cNumExt           = "";
LET cNumInt           = "";
LET cCP               = "";
LET cCelular          = "";
LET cCorreo           = ""; 
LET cFlagSeguro       = "0";
LET cNumPoliza        = "";
LET cTramaMigrantesBD = "";
LET cNombresAseg	  = "";
LET iSegActivos		  = 0;

LET iExisteCte		  = 0;
LET iExisteCteRem	  = 0;
LET cTramaMigrantesAux= "";
LET cFechaNacimiento  ="";

LET v_Conteo		  = 0;


--SET DEBUG FILE TO "/informix/MarcoR/CARDIF/BDISAC/SP/TRACE/sp_consulta_cardif.out";
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,cFlagSeguro,cNumPoliza,cTramaMigrantesBD,cFechaNacimiento; 
		END IF;
	END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Valida que algunos de los dos tipo de busqueda cumpla con los campos minimos
	IF (TRIM(pNumcte) = "") THEN
		IF (TRIM(pAsegurado_Nombre1) = "" OR TRIM(pAsegurado_Apell_Pat) = "" OR pAsegurado_FechaNac IS NULL) THEN
			LET cCodRet= "00001"; --alguno de los dos metodos de busqueda le faltan datos.
			RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,cFlagSeguro,cNumPoliza,cTramaMigrantesBD,cFechaNacimiento;
		END IF;
	END IF;
	
	--Se valida que el servicio este activo
	SELECT statusconvenio 
	INTO cStatuConv
	FROM bdisac:"informix".sac_convenios
	WHERE numcategoria = "09" and numconvenio = "023";
	
	IF TRIM(cStatuConv) = "I" THEN
		LET cFlagSeguro = "9";
		LET cCodRet = "128";
		RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,cFlagSeguro,cNumPoliza,cTramaMigrantesBD,cFechaNacimiento;
	END IF;
	
	IF TRIM(pNumcte) = "" THEN
		
		LET cNombresAseg = TRIM(pAsegurado_Nombre1)||' '||TRIM(pAsegurado_Nombre2);
		LET pAsegurado_Apell_Pat = TRIM(pAsegurado_Apell_Pat);
		LET pAsegurado_Apell_Mat = TRIM(pAsegurado_Apell_Mat);
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_calcularrfc(pAsegurado_Apell_Pat,pAsegurado_Apell_Mat,cNombresAseg,pAsegurado_FechaNac) INTO cCodRetRfc, cRfc;
		
		IF NVL(cCodRetRfc,"") <> "00000" THEN
			LET cCodRet = cCodRetRfc;
		ELSE
			SELECT cte.numcte, count(cte.numcte), count(rem.numcte)
			INTO pNumcte, iExisteCte, iExisteCteRem
			FROM bdinteg:"informix".si_cliente cte LEFT JOIN
			bdisac:"informix".sac_cte_remesas rem ON rem.numcte = cte.numcte
			WHERE cte.rfc = cRfc
			GROUP BY cte.numcte;
		END IF;
	END IF;
	
	LET cNumcte = pNumcte;
	
	SELECT COUNT(cte.numcte), COUNT(rem.numcte)
	INTO iExisteCte, iExisteCteRem
	FROM bdinteg:"informix".si_cliente cte LEFT JOIN
	bdisac:"informix".sac_cte_remesas rem ON rem.numcte = cte.numcte
	WHERE cte.numcte = pNumcte;
	
	IF iExisteCte = 0 THEN
		LET cCodRet = "00002";
	ELIF iExisteCteRem = 0 THEN
		LET cCodRet = "00003";
	END IF;
	
	IF TRIM(cCodRet) = "00000" THEN
		
		/*Se aÃÂ±ade UPDATE para no mostrar operaciones inconclusas por time out de proveredor para cliente especifico */
			
			LET iExisteCte = 0;
			
			SELECT COUNT(*) 
			INTO iExisteCte
			FROM bdisac:"informix".sac_cardif_migrante
			WHERE numcte = pNumcte
			AND estatus = 1
			AND folio_suc IS NULL
			AND num_certificado = ''
			AND num_poliza = '';
			
			IF iExisteCte <> 0 THEN
				UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 5, observ_siniestro = 'Cambio estatus 1 a 5 Operacion Inconclusa Oper'
				WHERE numcte = pNumcte
				AND estatus = 1
				AND folio_suc IS NULL
				AND num_certificado = ''
				AND num_poliza = '';
			END IF;	
			
		/*-------*/
		
	
		SELECT MAX(secuencia) INTO iSecDireccion 
		FROM bdinteg:"informix".si_direcciones_actual WHERE numcte= pNumcte AND tipo_dir = 1;
		
		SELECT cte.nombre1,cte.nombre2,cte.apell_paterno,cte.apell_materno,cte.rfc,dir.estado,dir.ciudad,dir.numerocolonia,dir.numerocalle,dir.numeroextcalle,dir.numerointcalle,dir.cod_postal
		INTO cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP
		FROM bdinteg:"informix".si_cliente cte
		INNER JOIN bdisac:"informix".sac_cte_remesas rem ON rem.numcte = cte.numcte 
		INNER JOIN bdinteg:"informix".si_direcciones_actual dir ON dir.numcte = cte.numcte AND dir.tipo_dir = 1 AND dir.secuencia = iSecDireccion
		WHERE numcte = pNumcte;
		
		IF NVL(cEstado,"") = "" OR NVL(cCiudad,"") = "" OR NVL(cColonia,"") = "" OR NVL(cCalle,"") = "" OR NVL(cNumExt,"") = "" OR NVL(cCP,"") = "" THEN
			LET cCodRet = "00005";
		ELSE
			SELECT telefono INTO cCelular FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumcte AND tel.tipo_tel = 2 AND tel.status_tel = "A";
			SELECT fecha_nac INTO cFechaNacimiento FROM bdinteg:"informix".si_ctepf WHERE numcte = pNumcte;
		
		END IF;
	
		SELECT COUNT(numcte), trim(num_certificado) || "|" || trim(num_poliza)
		INTO cFlagSeguro, cNumPoliza
		FROM bdisac:"informix".sac_cardif_contratante
		WHERE numcte = pNumcte
		GROUP BY num_certificado,num_poliza;
		
		IF cFlagSeguro <> "0" THEN
			SELECT celular, correo
			INTO cCelular, cCorreo
			FROM bdisac:"informix".sac_cardif_contratante
			WHERE numcte = pNumcte;
			LET cFlagSeguro = 1;
		ELSE
			SELECT correo_elec 
			INTO cCorreo
			FROM bdinteg:"informix".si_correos 
			WHERE empresa='001' AND tipo_correo=1 AND status_correo='A' AND numcte=pNumcte AND secuencia=(SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE empresa='001' AND tipo_correo=1 AND numcte=pNumcte AND status_correo='A');
		END IF;
			
		IF cFlagSeguro <> "0" THEN
			
			FOREACH WITH HOLD
				SELECT TRIM(num_certificado) || "|" || TRIM(num_poliza) || "|" || TRIM(estatus) || "|" || TRIM(nombre1) || "|" || TRIM(nombre2) || "|" || 
				TRIM(apell_paterno) || "|" || TRIM(apell_materno) || "|" || TRIM(tipo_plan) || "|" || TRIM(TO_CHAR(fecha_alta,"%d/%m/%Y")) || "|" || 
				TRIM(TO_CHAR(fecha_vencimiento,"%d/%m/%Y")) || "|" || "" || "|" || TRIM(parentesco), TRIM(estatus)
				INTO cTramaMigrantesAux, cEstatusMig
				FROM bdisac:"informix".sac_cardif_migrante WHERE numcte = pNumcte AND estatus IN ("1","2")
				
				LET cTramaMigrantesBD = TRIM(cTramaMigrantesBD) || TRIM(cTramaMigrantesAux) || ">>";
				
				IF (TRIM(cEstatusMig) = "1") OR (TRIM(cEstatusMig) = "2") THEN
					LET iSegActivos = iSegActivos + 1;
				END IF;
				
			END FOREACH;
			
			IF iSegActivos = 0 THEN
				LET cFlagSeguro = 0;
				LET cNumPoliza = "";
			END IF;
		END IF;
	END IF;
	RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,NVL(cFlagSeguro,"0"),NVL(cNumPoliza,""),cTramaMigrantesBD,cFechaNacimiento;
END;
END PROCEDURE;