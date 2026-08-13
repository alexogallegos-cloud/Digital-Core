CREATE PROCEDURE "informix".sp_cancel_prestamoflex()
RETURNING
CHAR (06),
VARCHAR(80);

------------------------------------------------------------------------------------

---- DECLARACION DE VARIABLES
DEFINE vEmpresa 		CHAR(3);
DEFINE vNumCte 			CHAR(20);
DEFINE vNumCredito  	CHAR(20);
DEFINE vSucursal		CHAR(4);
DEFINE vCelular			CHAR(13);
DEFINE vFechaUltMod 	DATE;
DEFINE vFechaI 			DATE;
DEFINE vFechaV 			DATE;
DEFINE vFechaHoy		DATE;
DEFINE vNumProducto		CHAR(4);
DEFINE vFechaA			DATE;
DEFINE vFechaVencCred  	DATE;
DEFINE vTotalEnv		INTEGER;
DEFINE vTotalCanc       INTEGER;
DEFINE vTotalCancAA     INTEGER;
DEFINE vStatus			CHAR(2);
DEFINE vStatusol		CHAR(2);
DEFINE cErrorInfo   	VARCHAR(255,1);
DEFINE cCodRet      	CHAR(6);
DEFINE cCodRet2         CHAR(6);

DEFINE SQL_ERR			INTEGER;
DEFINE ISAM_ERR			INTEGER;
DEFINE ERROR_INFO		VARCHAR(80);
DEFINE P_COD_RET		VARCHAR(6);
DEFINE COD_RET			VARCHAR(6);
DEFINE SCOD_RET		    VARCHAR(6);
DEFINE P_MENSAJE		VARCHAR(80);
DEFINE vprocesoina		CHAR(4);
DEFINE vprocesovig		CHAR(4);
DEFINE cMensaje			CHAR(80);
DEFINE cSql				CHAR(2000);

DEFINE v_empresa        CHAR(4);
DEFINE vSecCred         SMALLINT;
DEFINE vFechaOtorga     DATE;
DEFINE vFechaCancela    DATE;
DEFINE vFechaAperI      DATE;
DEFINE vFechaIna        DATE;
DEFINE vFechaAperV		DATE;
DEFINE vMontoDisp       DECIMAL(18,2);
DEFINE vLineaDisp       DECIMAL(18,2);
DEFINE vCancelVig       INTEGER;
DEFINE vCancelIna       INTEGER;
DEFINE wBegin           CHAR(1);
DEFINE pEjecutivo       VARCHAR(8);
DEFINE cNumeroFolio 	CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE vCancelPf        CHAR(1);
DEFINE vFechaUltPf      DATE;
---INICIALIZACIONES DE VARIABLES}
LET vEmpresa			= '001';
LET vNumCte				= '';
LET vNumCredito 		= '';
LET vCelular			= '';
LET vFechaUltMod		= '';
LET vFechaI				= '';
LET vFechaV             = '';
LET vFechaHoy    		= '';
LET vNumProducto		= '';
LET vFechaA				= 0;
LET vTotalEnv			= 0;
LET vTotalCanc			= 0;
LET vStatus				= '';
LET vStatusol			= '';
LET vFechaOtorga        = '';
LET vFechaCancela          = '';
LET vFechaVencCred      = '';
LET vSecCred            = 0;
LET vTotalCancAA        = 0;

LET SQL_ERR				= 0;
LET ISAM_ERR			= 0;
LET ERROR_INFO			= '';
LET P_COD_RET			= '';
LET COD_RET				= '';
LET SCOD_RET            = '';
LET P_MENSAJE			= 'PROCESO EXITOSO';
LET vprocesoina			= '0100';
LET vprocesovig         = '0101';
LET cMensaje			= '';
LET cSql				= '';
LET v_empresa           = '001';
LET vMontoDisp          = 0; 
LET vLineaDisp          = 0;
LET vCancelVig          = '';
LET vCancelIna          = '';
LET pEjecutivo          = 'informix';
LET cErrorInfo      	= '';
LET cCodRet         	= '';
LET cCodRet2            = '';
LET cNumeroFolio 		= '';  -- FOLIO PARA REGISTRAR EL ABONO
LET vCancelPf           = '';
LET vFechaUltPf         = '';

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		IF SQL_ERR != 0 THEN 
			LET P_COD_RET = SQL_ERR;
			LET P_MENSAJE = 'Error al ejecutar el proceso. ';
			RETURN P_COD_RET,P_MENSAJE;
			
			IF vprocesoina = '0100' OR vprocesovig = '0101' THEN 
				CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesoina, P_COD_RET, cMensaje, '02') RETURNING SCOD_RET;
			ELSE
				CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesovig, P_COD_RET, cMensaje, '02') RETURNING SCOD_RET;		 
			END IF;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
	END EXCEPTION;
   
	--SET debug FILE TO "/respaldos/krgb/presdig/sp_cancel_prestamoflex.out";
	--TRACE ON;
  
  	SET LOCK MODE TO wait 3;
    SET ISOLATION TO dirty READ;
  
    LET cMensaje = 'PROCESO INICIALIZADO CANCELACION INACTIVIDAD PRESTAMOFLEX';
    CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesoina, P_COD_RET, cMensaje, '01') RETURNING SCOD_RET;
    IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;
	
 	IF SCOD_RET != '000000' THEN
		let P_COD_RET = SCOD_RET;
		let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF; 

	SELECT TRIM(valor) INTO  vCancelIna
	FROM bdicred:"informix".sd_param						
	WHERE empresa  = v_empresa AND cod_param = '068'; --Parametro de Cancelacion de Inactividad	
	
	SELECT fecha_hoy INTO vFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;
	EXECUTE PROCEDURE bdicred:monthadd(vFechaHoy, - vCancelIna) INTO vFechaI;	   
	
	FOREACH WITH HOLD
	----------         
		--Cancelacion por Inactividad (1 ano)   	 	
		SELECT {+AVOID_FULL(bdicred:"informix".sd_linea_prestamo)} pres.num_credito, crd.numcte, crd.status_cred, crd.sucursal, pres.sec_credito, pres.fecha_otorga, crd.fecha_vencim, pres.fecha_cancela, pres.fecha_ult_mod, 
			pres.monto_linea, pres.linea_disponible , pres.cancel_pf, pres.fecha_ult_pf 
		INTO vNumCredito,  vNumCte, vStatus, vSucursal, vSecCred, vFechaOtorga, vFechaVencCred, vFechaCancela, vFechaUltMod, vMontoDisp, vLineaDisp, vCancelPf, vFechaUltPf 
		FROM bdicred:"informix".sd_linea_prestamo pres
		JOIN bdicred:"informix".sd_maecredcrd crd ON (pres.num_credito = crd.num_credito)		
																				   
		WHERE  pres.cancel_pf IS NULL AND pres.monto_linea = pres.linea_disponible AND pres.fecha_ult_mod::DATE <= vFechaI
		
		TRUNCATE TABLE "informix".sd_cancel_pf; 
		
		INSERT INTO bdicred:sd_cancel_pf (num_credito, numcte, status_cred, sucursal, sec_credito, fecha_otorga, fecha_vencim, fecha_cancela, fecha_ult_mod, monto_linea, linea_disponible , cancel_pf, fecha_ult_pf)
		VALUES (vNumCredito,  vNumCte, vStatus, vSucursal, vSecCred, vFechaOtorga, vFechaVencCred, vFechaCancela, vFechaUltMod, vMontoDisp, vLineaDisp, vCancelPf, vFechaUltPf);

		BEGIN WORK; 
		
		--SELECT NVL(telefono,'') INTO vCelular FROM bdinteg:"informix".si_telefonos tel WHERE numcte = vNumCte AND tel.verificado = 'V' AND tel.status_tel = 'A' AND tel.tipo_tel = 2;
		SELECT NVL(telefono,'') INTO vCelular FROM bdinteg:"informix".si_telefonos_actual tel WHERE numcte = vNumCte AND tel.status_tel = 'A' AND tel.tipo_tel = 2;
		
			IF vStatus IN ('AA','E1') AND vSecCred = 0 THEN --Caso en que no se tenga ninguna disposicion
											
				-- SE GENERA EL FOLIO
				LET pEjecutivo = 'informix';
				CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet2, cNumeroFolio; 

				IF cCodRet2::integer  <> 0 THEN
					LET cCodRet = "000003";  --Error en sp_generafolionomina
				ELSE				
					-- SE GENERA MOVIMIENTO DE RECUPERACION LINEA PRESTAMO DIGITAL
					EXECUTE PROCEDURE bdicred:genmovcrd(v_empresa,vNumCredito, '6800', 2, '002', vFechaHoy, vMontoDisp, cNumeroFolio, vSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) INTO cCodRet, cErrorInfo;

					IF cCodRet::integer  <> 0 THEN
						LET cCodRet = "000004"; --Error en genmovcrd							 	
					ELSE		
						UPDATE "informix".sd_maecredcrd SET status_cred = "FF", fecha_vencim = vFechaHoy WHERE empresa = v_empresa AND num_credito = vNumCredito;
						UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = vFechaHoy, cancel_pf = '1', fecha_ult_pf = vFechaHoy WHERE num_credito = vNumCredito;	
						IF vCelular IS NOT NULL OR vCelular <> ''  THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2', 'CRED_SMS', 'PPF_SMS_CN', '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', vCelular, 0, 0, 0, 0, 0, current, current) INTO SCOD_RET;
						END IF;					
					END IF;						
				END IF;		
				
				LET vTotalCanc = vTotalCanc + 1;				
							
			ELIF vStatus = 'FF'  THEN	--Caso en que se tenga alguna disposicion     
							
				-- SE GENERA EL FOLIO
				LET pEjecutivo = 'informix';
				CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet2, cNumeroFolio; 

				IF cCodRet2::integer  <> 0 THEN
					LET cCodRet = "000003";  --Error en sp_generafolionomina
				ELSE
					-- SE GENERA MOVIMIENTO DE RECUPERACION LINEA PRESTAMO DIGITAL
					EXECUTE PROCEDURE bdicred:genmovcrd(v_empresa,vNumCredito, '6800', 2, '002', vFechaHoy, vMontoDisp, cNumeroFolio, vSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) INTO cCodRet, cErrorInfo;					
					
					IF cCodRet::integer  <> 0 THEN
						LET cCodRet = "000004"; --Error en genmovcrd
					ELSE
						UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = vFechaHoy, cancel_pf = '1', fecha_ult_pf = vFechaVencCred WHERE num_credito = vNumCredito;
						IF vCelular IS NOT NULL OR vCelular <> ''  THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2', 'CRED_SMS', 'PPF_SMS_CN', '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', vCelular, 0, 0, 0, 0, 0, current, current) INTO SCOD_RET;				
						END IF;					
					END IF;					
				END IF;		
				
				LET vTotalCanc = vTotalCanc + 1;
			
			END IF;	
		
		COMMIT WORK;	
			
	END FOREACH 
	
		--Muestra en bitacora el total de registros procesados
		LET cMensaje = 'Total de Creditos a Cancelar por Inactividad: ' || vTotalEnv;
		CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesoina, P_COD_RET, TRIM(cMensaje), '02') RETURNING SCOD_RET;
		IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;
		
		IF SCOD_RET != '000000' THEN
			LET P_COD_RET = SCOD_RET;
			LET P_MENSAJE  = 'Error en el llamado a la insercion en bitacora.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
		
		--Muestra en bitacora el total de registros cancelados
		LET cMensaje = 'Total de Creditos Cancelados por Inactividad: ' || vTotalCanc;
		CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesoina, P_COD_RET, TRIM(cMensaje), '02') RETURNING SCOD_RET;
		IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;
		
		IF SCOD_RET != '000000' THEN
			LET P_COD_RET = SCOD_RET;
			LET P_MENSAJE  = 'Error en el llamado a la insercion en bitacora.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		LET cMensaje = 'PROCESO FINALIZADO CANCELACION INACTIVIDAD PRESTAMO FLEX';
		CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesoina, P_COD_RET, cMensaje, '03') RETURNING SCOD_RET;
		IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;

		IF SCOD_RET != '000000' THEN
			LET P_COD_RET = SCOD_RET;
			LET P_MENSAJE  = 'Error en el llamado a la insercion en bitacora.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		--------------------
		--Cancelacion por Vigencia (3 anos) 
		
		LET cMensaje = 'PROCESO INICIALIZADO CANCELACION VIGENCIA PRESTAMO FLEX';
		CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesovig, P_COD_RET, cMensaje, '01') RETURNING SCOD_RET;
		IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;
		
		IF SCOD_RET != '000000' THEN
			let P_COD_RET = SCOD_RET;
			let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
		
		SELECT TRIM(valor)  INTO  vCancelVig
		FROM bdicred:"informix".sd_param 						
		WHERE empresa  = v_empresa AND cod_param = '067'; --Parametro de Cancelacion de Vigencia
			
		LET vTotalEnv = 0;
		LET vTotalCanc = 0;
		
		SELECT fecha_hoy INTO vFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;
		EXECUTE PROCEDURE bdicred:monthadd(vFechaHoy, - vCancelVig) INTO vFechaV;
		 
		
		FOREACH WITH HOLD 

			---------- 	
			SELECT {+AVOID_FULL(bdicred:"informix".sd_linea_prestamo)} pres.num_credito, crd.numcte, crd.status_cred, crd.sucursal, pres.sec_credito, pres.fecha_otorga, crd.fecha_vencim, pres.fecha_cancela, pres.fecha_ult_mod, 
			pres.monto_linea, pres.linea_disponible , pres.cancel_pf, pres.fecha_ult_pf 
			INTO vNumCredito,  vNumCte, vStatus, vSucursal, vSecCred, vFechaOtorga, vFechaVencCred, vFechaCancela, vFechaUltMod, vMontoDisp, vLineaDisp, vCancelPf, vFechaUltPf 
			FROM bdicred:"informix".sd_linea_prestamo pres
			JOIN bdicred:"informix".sd_maecredcrd crd ON (pres.num_credito = crd.num_credito)			
			WHERE pres.fecha_otorga <= vFechaV AND pres.fecha_ult_pf IS NULL
			
			TRUNCATE TABLE "informix".sd_cancel_pf;
		
			INSERT INTO bdicred:sd_cancel_pf (num_credito, numcte, status_cred, sucursal, sec_credito, fecha_otorga, fecha_vencim, fecha_cancela, fecha_ult_mod, monto_linea, linea_disponible , cancel_pf, fecha_ult_pf)
			VALUES   (vNumCredito,  vNumCte, vStatus, vSucursal, vSecCred, vFechaOtorga, vFechaVencCred, vFechaCancela, vFechaUltMod, vMontoDisp, vLineaDisp, vCancelPf, vFechaUltPf);
		
			BEGIN WORK;
			
			--SELECT NVL(telefono,'') INTO vCelular FROM bdinteg:"informix".si_telefonos tel WHERE numcte = vNumCte AND tel.verificado = 'V' AND tel.status_tel = 'A' AND tel.tipo_tel = 2;
			SELECT NVL(telefono,'') INTO vCelular FROM bdinteg:"informix".si_telefonos_actual tel WHERE numcte = vNumCte AND tel.status_tel = 'A' AND tel.tipo_tel = 2;

				IF  vStatus = 'FF' AND vLineaDisp = vMontoDisp   THEN --En caso de contar con disposiciones, pero no tiene disposicion vigente				
									
					-- SE GENERA EL FOLIO
					LET pEjecutivo = 'informix';
					CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet2, cNumeroFolio; 

					IF cCodRet2::integer  <> 0 THEN
						LET cCodRet = "000003";  --Error en sp_generafolionomina
					ELSE
						-- SE GENERA MOVIMIENTO DE RECUPERACION LINEA PRESTAMO DIGITAL
						EXECUTE PROCEDURE bdicred:genmovcrd(v_empresa,vNumCredito, '6800', 2, '002', vFechaHoy, vMontoDisp, cNumeroFolio, vSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) INTO cCodRet, cErrorInfo;

						IF cCodRet::integer  <> 0 THEN
							LET cCodRet = "000004"; --Error en genmovcrd	
						ELSE
						  IF vCancelPf = '1'  THEN --En caso de realizar alguna disposicion y se encuentra liquidada
							UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_ult_pf = vFechaVencCred WHERE num_credito = vNumCredito;
						  ELSE 
    						UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = vFechaHoy, cancel_pf = '1', fecha_ult_pf = vFechaVencCred WHERE num_credito = vNumCredito;
						  END IF;
						  IF vCelular IS NOT NULL OR vCelular <> ''  THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2', 'CRED_SMS', 'PPF_SMS_CN', '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', vCelular, 0, 0, 0, 0, 0, current, current) INTO SCOD_RET;
						  END IF;	
						END IF;							
					END IF;		
					
					LET vTotalCanc = vTotalCanc + 1;			
				
				ELIF vStatus IN ('AA','BA','BT','E1','E2','E3') AND vLineaDisp <> vMontoDisp AND vFechaCancela IS NULL THEN --Cuenta con disposicion activa (no se encuentra liquidada, para estar liberada estaria en FF) 
				
					--EN CASO DE QUE fecha_ult_pf IS NULL se mandaria mensaje
					UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = vFechaHoy, cancel_pf = '1' WHERE num_credito = vNumCredito;
					IF vCelular IS NOT NULL OR vCelular <> ''  THEN
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2', 'CRED_SMS', 'PPF_SMS_CND', '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', vCelular, 0, 0, 0, 0, 0, current, current) INTO SCOD_RET;

					END IF;
					LET vTotalCancAA = vTotalCancAA + 1;							
				END IF;
				
			COMMIT WORK;
								
		END FOREACH 
	
	--Muestra en bitacora el total de registros procesados
	LET cMensaje = 'Total de Creditos a Cancelar por Vigencia: ' || vTotalEnv;
	CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesovig, P_COD_RET, TRIM(cMensaje), '02') RETURNING SCOD_RET;
	IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;
	
	IF SCOD_RET != '000000' THEN
		LET P_COD_RET = SCOD_RET;
		LET P_MENSAJE  = 'Error en el llamado a la insercion en bitacora.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;
	
	--Muestra en bitacora el total de registros cancelados
	LET cMensaje = 'Total de Creditos Cancelados por Vigencia: ' || vTotalCanc;
	CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesovig, P_COD_RET, TRIM(cMensaje), '02') RETURNING SCOD_RET;
	IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;
	
	IF SCOD_RET != '000000' THEN
		LET P_COD_RET = SCOD_RET;
		LET P_MENSAJE  = 'Error en el llamado a la insercion en bitacora.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;
	
	LET cMensaje = 'Total de Creditos Cancelados por Vigencia con Disposicion Activa: ' || vTotalCancAA;
	CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesovig, P_COD_RET, TRIM(cMensaje), '02') RETURNING SCOD_RET;
	IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF;
	
	IF SCOD_RET != '000000' THEN
		LET P_COD_RET = SCOD_RET;
		LET P_MENSAJE  = 'Error en el llamado a la insercion en bitacora.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;

	LET cMensaje = 'PROCESO FINALIZADO CANCELACION VIGENCIA PRESTAMO FLEX';
	CALL bdicred:"informix".sp_inserta_bitacora('001', vprocesovig, P_COD_RET, cMensaje, '03') RETURNING SCOD_RET;
	IF SCOD_RET = '000000' THEN LET COD_RET = '00000'; END IF; 

	IF SCOD_RET != '000000' THEN
		LET P_COD_RET = SCOD_RET;
		LET P_MENSAJE  = 'Error en el llamado a la insercion en bitacora.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;	 
	
	--------------------
    RETURN COD_RET,P_MENSAJE;

END;
END PROCEDURE;