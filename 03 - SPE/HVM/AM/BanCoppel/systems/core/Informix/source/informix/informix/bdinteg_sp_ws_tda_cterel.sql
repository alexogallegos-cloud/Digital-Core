CREATE PROCEDURE "informix".sp_ws_tda_cterel( pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  pNumCteCoppel CHAR(20))
RETURNING
	CHAR(5) as ccCodRetorno,
	CHAR(4) as cCodRet,
	char(100) as mensaje,
	CHAR(8) as cFecha_proceso,
	CHAR(6) as cHora_proceso,
	CHAR(20) as cNumCte;
			
--variables de retorno
	DEFINE ccCodRetorno 	CHAR(5);
	DEFINE cCodRet			CHAR(8);
	DEFINE mensaje			CHAR(120);
	DEFINE cFecha_proceso 	CHAR(8);
	DEFINE cHora_proceso 	CHAR(6);
	DEFINE cNumCte			CHAR(20);
	DEFINE cOpcode 			CHAR(4);
	DEFINE cDescr_completa_mensaje 	CHAR(80);
	DEFINE cNombre_proceso	CHAR(17);
	DEFINE cCadena_ent		CHAR(100);

	
	--DEFINE cReturnCode CHAR (5);
	
	--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE iIsamError 		INTEGER;
	
--variables del proceso
	DEFINE	vdiv 			INTEGER;


	---INICIALIZAR DE VARIABLES
	LET ccCodRetorno  = '00000';
	LET cCodRet = '0000';
	LET mensaje = 'Consulta Exitosa';
	LET cFecha_proceso = trim(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));
	LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET cOpcode = '0000';
	LET cDescr_completa_mensaje = 'Consulta Exitosa.';
	LET cNombre_proceso='sp_ws_coppel_huellas';
	LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
	LET cNumCte = '';
	  
	LET iIsamError = 0;

	--SET DEBUG FILE TO '/tmp/cristo/sp_ws_tda_cterel.out';
	--TRACE ON;	
	   
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			IF iSqlErr = '-1213' THEN

				LET cCodRet = '0001';
				LET cOpcode = cCodRet;
		
				SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
				INTO cOpcode,mensaje,cDescr_completa_mensaje
				FROM bdisac:"informix".sac_ws_catmensajes
				WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, LPAD(cCodRet,5,'0'), mensaje, '', '', cCadena_ent, pcUsuario,pcFecha_peticion,pcHora_peticion)
				INTO ccCodRetorno;
				
				IF cOpcode IS NULL THEN
					LET cOpcode = cCodRet;
					LET mensaje = 'Codigo no registrado en catalogo.';
					LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
				END IF;
			ELSE
			
				LET cCodRet = iSqlErr;
				LET cOpcode = cCodRet;
				LET mensaje = '';
				LET cDescr_completa_mensaje = '';
				
				--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario,pcFecha_peticion,pcHora_peticion)
				INTO ccCodRetorno;
				
			END IF;	
			
			INSERT INTO bdinteg:"informix".si_ws_tda_cterel(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,cte_coppel,opcode,descr_message,date_process,time_process,numcte,datetimeinsert)
		VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCteCoppel,cCodRet,mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),current); 
			
			RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,'');
			
		END IF;
	END EXCEPTION;


	--------VALIDACIÓN DE PARAMETROS-------------------------
	
	
	IF  NVL(pcAgent_cd,'?')='?'  OR NVL(pcAgent_trans_type_code,'?')<>'TDA_CTEREL' OR NVL(pcUsuario,'?')= '?' 
		OR NVL(pcPassword,'?')= '?'	OR NVL(pcFecha_peticion,'?')= '?' OR NVL(pcHora_peticion,'?')= '?' 
		OR NVL(pcIp_origen,'')='' OR NVL(pcSession_id,'')=''
		OR NVL(pNumCteCoppel,'?')= '?' THEN
	
		
		LET cCodRet ='9996';

		INSERT INTO bdinteg:"informix".si_ws_tda_cterel(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,cte_coppel,opcode,descr_message,date_process,time_process,numcte,datetimeinsert)
		VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCteCoppel,cCodRet,mensaje,cFecha_proceso,cHora_proceso,cNumCte,current); 
		
	ELSE
	
		EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id) 
		INTO cCodRet, mensaje;
			
		IF cCodRet = '0000' THEN 
			
			--Aqui Va toda la magia, por el momento solo se asigna 043856590 para el cascaron dummy
			--LET cNumCte = '043856590';
			select first 1 numcte_banco
			into  cNumCte
			from  si_relacion_ctebcplcpl where cliente = pNumCteCoppel;
			
		END IF

	END IF;

	IF cCodRet <> '0000' THEN			
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,mensaje,cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cCodRet;
			LET mensaje = 'Codigo no registrado en catalogo.';
			LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;
	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso,cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,pcFecha_peticion,pcHora_peticion)
		INTO ccCodRetorno;
		
	END IF;

	INSERT INTO bdinteg:"informix".si_ws_tda_cterel(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,cte_coppel,opcode,descr_message,date_process,time_process,numcte,datetimeinsert)
		VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCteCoppel,cCodRet,mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),current); 

	RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,'');

END
END PROCEDURE;