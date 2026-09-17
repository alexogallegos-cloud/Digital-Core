CREATE PROCEDURE "informix".sp_obten_estatus_canales_sms(
								pEstatusAcl				INTEGER,
								pEstatusCorpGral		INTEGER,
								pEstatusCorpAnalisis	INTEGER)

	RETURNING
		CHAR(5)							AS cod_ret,
		CHAR(50)						AS desc_estatus_canales,
		CHAR(50)						AS desc_estatus_sms,
		SMALLINT 						AS concatena_dictamen,
		INTEGER 						AS id_etapa_canales,
        CHAR(20)						AS desc_etapa_canales;

	--Variables--
	DEFINE sql_err 							INTEGER;
	DEFINE v_cod_ret 						CHAR(5);
	
	DEFINE v_id_estatus_aclaracion			INTEGER;
	DEFINE v_id_estatus_corp_analisis		INTEGER;
	DEFINE v_id_estatus_corp_general		INTEGER;
	DEFINE v_concatena_dictamen				SMALLINT;
	DEFINE v_estatus_canales				CHAR(50);
	DEFINE v_estatus_sms				CHAR(50);
	DEFINE v_id_etapa_canales				INTEGER;
	DEFINE v_desc_etapa_canales				CHAR(20);
	
	
	DEFINE contador			INTEGER;
	LET contador			= 0;
	
	LET v_cod_ret 						= '00000';
	LET sql_err 						= NULL;
	
	LET v_id_estatus_aclaracion			= NULL;
	LET v_id_estatus_corp_analisis		= NULL;
	LET v_id_estatus_corp_general		= NULL;
	LET v_concatena_dictamen			= NULL;
	LET v_estatus_canales					= NULL;
	LET v_estatus_sms					= NULL;
	LET v_id_etapa_canales					= NULL;
	LET v_desc_etapa_canales				= NULL;
	
	--SET DEBUG FILE TO "/informix/Paty/RQM665/estatus_canales_sms.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret, v_estatus_canales, v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
				
		    END IF;
		END EXCEPTION;
		
		IF (pEstatusAcl IS NULL) THEN
			RETURN '00001', v_estatus_canales, v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales; --El estatus de la AclaraciÃ³n no puede ser Nulo
		END IF;
		
		--Se realiza la consulta por los parÃ¡metros de invocaciÃ³n del SP
		SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
				ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
			INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
				v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
		FROM acl_estatus_canales ecan
			INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
			LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
			LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
		WHERE pky_estatus_aclaracion = pEstatusAcl
			AND ecg.pky_estatus_corporativo = pEstatusCorpGral
			AND eca.pky_estatus_corporativo = pEstatusCorpAnalisis;
		
		--En caso que la consulta no devuelva resultados se valida si se tiene algÃºn comodÃ­n con un estatus de anÃ¡lisis
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
					ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
				INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
					v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
				LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
				LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
			WHERE pky_estatus_aclaracion = pEstatusAcl
				AND ecg.pky_estatus_corporativo IS NULL 
				AND eca.pky_estatus_corporativo = pEstatusCorpAnalisis;
		END IF;
		
		--En caso que la consulta no devuelva resultados se valida si se tiene algÃºn comodÃ­n con un estatus de corporativo
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, eca.pky_estatus_corporativo, ecg.pky_estatus_corporativo, ecan.descripcion, ecan.concatena_dictamen,
					ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
				INTO v_id_estatus_aclaracion, v_id_estatus_corp_analisis, v_id_estatus_corp_general, v_estatus_canales, v_concatena_dictamen,
					v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
				LEFT OUTER JOIN acl_estatus_corporativo ecg ON ecg.fky_tipo_estatus = 1 AND ecg.nombre = ecan.nombre_estatus_corp_general 
				LEFT OUTER JOIN acl_estatus_corporativo eca ON eca.fky_tipo_estatus = 2 AND eca.nombre = ecan.nombre_estatus_corp_analisis 
			WHERE pky_estatus_aclaracion = pEstatusAcl
				AND ecg.pky_estatus_corporativo = pEstatusCorpGral
				AND eca.pky_estatus_corporativo IS NULL;
		END IF;
		
		--En caso que la consulta no devuelva resultados se valida si existe el registro para el estatus de la aclaraciÃ³n
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, ecan.descripcion, ecan.concatena_dictamen, ecan.id_etapa_canales, ecan.descripcion_etapa_canales, ecan.descripcion_sms
				INTO v_id_estatus_aclaracion, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales, v_estatus_sms
			FROM acl_estatus_canales ecan
				INNER JOIN acl_estatus_aclaracion ea ON ea.nombre = ecan.nombre_estatus_aclaracion 
			WHERE pky_estatus_aclaracion = pEstatusAcl 
				AND ecan.nombre_estatus_corp_general IS NULL 
				AND ecan.nombre_estatus_corp_analisis IS NULL;
		END IF;
		
		--En caso que la consulta no devuelva resultados se mostrarÃ¡ el valor del Estatus de la aclaraciÃ³n
		IF v_estatus_canales IS NULL THEN
			SELECT ea.pky_estatus_aclaracion, ea.descripcion, 0
				INTO v_id_estatus_aclaracion, v_estatus_canales, v_concatena_dictamen
			FROM acl_estatus_aclaracion ea 
			WHERE pky_estatus_aclaracion = pEstatusAcl;
			
			--Se asignan los valores de la "Etapa" considerando el estatus de la AclaraciÃ³n
			IF v_id_estatus_aclaracion = 1 THEN
				LET v_id_etapa_canales = 1;
				LET v_desc_etapa_canales = 'ALTA';
			ELIF v_id_estatus_aclaracion = 2 THEN
				LET v_id_etapa_canales = 2;
				LET v_desc_etapa_canales = 'ANÃLISIS';
			ELIF v_id_estatus_aclaracion BETWEEN 3 AND 5 THEN
				LET v_id_etapa_canales = 3;
				LET v_desc_etapa_canales = 'DICTAMEN';
			ELSE
				LET v_id_etapa_canales = 0;
				LET v_desc_etapa_canales = 'NO DEFINIDO';
			END IF;
		END IF;
		
		IF v_estatus_canales IS NULL THEN
			LET v_cod_ret = '00002'; --El estatus de la AclaraciÃ³n no existe
		END IF;
		
		RETURN v_cod_ret, v_estatus_canales, v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
			
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Enero/2020',
'Requerimiento	:	RQM 18 145',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_aclaracion_sms(
                        pFolioCsuac CHAR(30),pCel CHAR(10), pnumCliente CHAR(20))
		
		RETURNING
		CHAR(5)				AS cod_ret;
		/*
		CHAR(10)			AS folio_csuac,
		MONEY				AS montoreclamado,
		MONEY				AS montoprocedente,
		CHAR(50)			AS estatus_canales,
		CHAR(15)			AS telefono_dudas,
		SMALLINT			AS procede,
		INTEGER				AS fky_estatus_aclaracion,
		INTEGER				AS fky_estatus_corp_analisis,
		INTEGER				AS fky_estatus_corp_general,
		CHAR(10)			AS num_cliente;
        */

		/*Definicion de Variables*/
		
		DEFINE sql_err 				INTEGER;
		DEFINE autentica            INTEGER;
	    DEFINE v_cod_ret 			CHAR(5);
		DEFINE v_cod_ret_reg_eve	CHAR(5);
		DEFINE v_folio_csuac    	CHAR(10); 
		DEFINE v_montoreclamado		MONEY;
	    DEFINE v_montoprocedente	MONEY;
		DEFINE v_estatus_canales    CHAR(50); 
		DEFINE v_estatus_sms        CHAR(50); 
		DEFINE v_telefono_dudas     CHAR(15);
		DEFINE v_procede		    SMALLINT;
		DEFINE v_fky_estatus_aclaracion  	INTEGER;
		DEFINE v_fky_estatus_corp_analisis 	INTEGER;
		DEFINE v_fky_estatus_corp_general 	INTEGER;	
		
		DEFINE v_desc_estatus_canales    CHAR(50);			
		DEFINE v_concatena_dictamen 	 SMALLINT;
	    DEFINE v_id_etapa_canales        SMALLINT;
        DEFINE v_desc_etapa_canales 	 CHAR(20);
		DEFINE v_num_cliente	         CHAR(10);
		DEFINE v_fecha_consulta	        DATETIME YEAR TO FRACTION(5);
		
		/*Inicializacion de Variables*/
		
		LET v_cod_ret   		= "00000";
		LET sql_err 			=	0;
		LET autentica 			=	0;
		LET v_folio_csuac   	= NULL;
		LET v_montoreclamado	= NULL;
	    LET v_montoprocedente	= NULL;
		LET v_estatus_canales   = NULL;
        LET v_estatus_sms       = NULL;
		LET v_telefono_dudas    = ''; 
		LET v_procede		    = NULL;
		LET v_fky_estatus_aclaracion  	= NULL;
		LET v_fky_estatus_corp_analisis = NULL;
		LET v_fky_estatus_corp_general 	= NULL;
		LET v_num_cliente	            = NULL;
		LET v_desc_estatus_canales      = NULL;		
		LET v_concatena_dictamen 		= NULL;
	    LET v_id_etapa_canales       	= NULL;
        LET v_desc_etapa_canales 		= NULL;	
		LET v_cod_ret_reg_eve 			= "00000";
		LET v_fecha_consulta			=NULL;
		
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
			
		--SET DEBUG FILE TO "/informix/Paty/RQM665/sp_consulta_aclaracion_sms.out";
		--TRACE ON;
		
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				
				--RETURN v_cod_ret, v_folio_csuac, v_montoreclamado, v_montoprocedente, v_estatus_canales, v_telefono_dudas, v_procede,v_fky_estatus_aclaracion,
				--v_fky_estatus_corp_analisis,v_fky_estatus_corp_general;
				
			END IF;
		END EXCEPTION;
				
	LET pFolioCsuac= pFolioCsuac;			
	
    --Validar Telefono 
	IF pnumCliente IS NOT NULL AND TRIM(pnumCliente) <> '' AND pFolioCsuac IS NOT NULL AND TRIM(pFolioCsuac) <> '' AND pCel IS NOT NULL AND TRIM(pCel) <> '' 

	THEN  
	
	SELECT folio_csuac,importereclamado,montoprocedente,procede,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,num_cliente
	INTO  v_folio_csuac,v_montoreclamado,v_montoprocedente,v_procede,v_fky_estatus_aclaracion,v_fky_estatus_corp_analisis,v_fky_estatus_corp_general,v_num_cliente
	FROM "informix".acl_aclaracion WHERE folio_csuac IN (pFolioCsuac);
 	
	SELECT COUNT(*) INTO autentica FROM "informix".acl_aclaracion WHERE folio_csuac = pFolioCsuac AND num_cliente= pnumCliente;
		
	--SELECT COUNT(*) INTO autentica FROM bdinteg:"informix".si_telefonos_actual WHERE numcte= v_num_cliente AND telefono = pCel AND tipo_tel = '2' AND status_tel = 'A';
	
	IF  autentica > 0  THEN
	 /* Insertar en tabla */
	INSERT INTO "informix".acl_bitacora_sms(folio, num_cliente, num_telefono, envio_exitoso, fecha_consulta) 
    VALUES(pFolioCsuac, pnumCliente, pCel, 1, current);
	
	
	--Se obtiene estatus---
	CALL "informix".sp_obten_estatus_canales_sms(v_fky_estatus_aclaracion, v_fky_estatus_corp_general, v_fky_estatus_corp_analisis)
			RETURNING  v_cod_ret,v_estatus_canales,v_estatus_sms, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
			
	
		IF v_concatena_dictamen = 1 THEN
			IF v_procede = 1 THEN
				LET v_estatus_sms = TRIM(v_estatus_sms) || ' - Procedente';
				LET v_montoreclamado = v_montoprocedente;
			ELIF v_procede = 0 THEN
				LET v_estatus_sms = TRIM(v_estatus_sms) || ' - No procedente';
			END IF;
		END IF;
		
			
		LET v_montoreclamado = NVL(v_montoreclamado,0);
		LET v_montoprocedente = NVL(v_montoprocedente,0);
		
	
	/* se envia a llamar el SP de registra evento si existe el status de la aclaracion*/		
	       
        IF  v_estatus_sms IS NOT NULL THEN 	   
		  
		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST','000000000','','','1',v_folio_csuac,'','','',v_estatus_sms,'','','','','','',pCel,1,v_montoreclamado,v_montoprocedente,0,0,current,'') RETURNING v_cod_ret_reg_eve;	
	
        ELSE 
		
		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST_ERR','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,current,'') RETURNING v_cod_ret_reg_eve;	
		
	    END IF;
				
		ELIF autentica = 0 OR v_cod_ret_reg_eve != '00000' THEN 
		
		/*Actualiza bitacora a no se envio*/
		LET v_cod_ret_reg_eve = '00001';

		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST_ERR','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,current,'') RETURNING v_cod_ret_reg_eve;	

		INSERT INTO "informix".acl_bitacora_sms(folio, num_cliente, num_telefono, envio_exitoso, fecha_consulta) 
		VALUES(pFolioCsuac, pnumCliente, pCel, 0, current);

		END IF;
		
	ELSE	
	
	    LET v_cod_ret_reg_eve = '00003';
	
		CALL bdimnsj:sp_registra_evento('2','ACL_SMS','ACL_EST_ERR','000000000','','','1','','','','','','','','','','','',pCel,1,0,0,0,0,current,'') RETURNING v_cod_ret_reg_eve;	

		INSERT INTO "informix".acl_bitacora_sms(folio, num_cliente, num_telefono, envio_exitoso, fecha_consulta) 
		VALUES(pFolioCsuac, pnumCliente, pCel, 3, current);
		

		END IF; 
    	LET v_cod_ret = v_cod_ret_reg_eve;
				
		RETURN v_cod_ret;
	END;
END PROCEDURE;