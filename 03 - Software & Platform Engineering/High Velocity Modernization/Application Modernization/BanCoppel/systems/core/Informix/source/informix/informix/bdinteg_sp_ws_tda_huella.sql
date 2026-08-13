CREATE PROCEDURE "informix".sp_ws_tda_huella( pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  pNumCte CHAR(20))
RETURNING
	CHAR(5) as ccCodRetorno,
	CHAR(4) as cCodRet,
	char(100) as mensaje,
	CHAR(8) as cFecha_proceso,
	CHAR(6) as cHora_proceso,
	CHAR(20) as cNumCte,
	CHAR(20) as cNumCte_cop,
	CHAR as cSecuencia,
	CHAR as cEstado,
	CHAR(10) as cUsuario,
	CHAR(5) as cSucursal,
	CHAR as cSexo,
	CHAR(8) as cFecha_movto,
	CHAR(942) as cDMapa,
	CHAR(942) as cIMapa;
			
--variables de retorno
	DEFINE ccCodRetorno 	CHAR(5);
	DEFINE cCodRet			CHAR(8);
	DEFINE mensaje			CHAR(120);
	DEFINE cFecha_proceso 	CHAR(8);
	DEFINE cHora_proceso 	CHAR(6);
	DEFINE cNumCte			CHAR(20);
	DEFINE cNumCte_cop		CHAR(20);
	DEFINE cSecuencia       CHAR;
	DEFINE cEstado		    CHAR;
	DEFINE cUsuario	 		CHAR;
	DEFINE cSucursal		CHAR(5);
	DEFINE cSexo			CHAR;
	DEFINE cFecha_movto 	CHAR(8);
	DEFINE cDMapa			CHAR(942);	
	DEFINE cIMapa			CHAR(942);
	DEFINE cHuella			CHAR(1);
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
	LET  cNumCte	= '';
	LET cNumCte_cop	= '';
	LET cSecuencia	= '';
	LET cEstado		= '';
	LET cUsuario	= '';
	LET cSucursal	= '';
	LET cSexo		= '';
	LET cFecha_movto = '';
	LET cDMapa		= '';
	LET cIMapa		= '';
	LET cHuella	= '';
	  
	LET iIsamError = 0;

	--SET DEBUG FILE TO '/tmp/cristo/sp_ws_tda_huella.out';
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
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, LPAD(cCodRet,5,'0'), mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
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
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
				INTO ccCodRetorno;
				
			END IF;	
			
			INSERT INTO bdinteg:"informix".si_ws_tda_huella(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte_request,opcode,descr_message,date_process,time_process,numcte,dmapa,imapa,datetimeinsert)
			VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCte,cCodRet,mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),cHuella,cHuella,current);
			
			--RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),'','';
			RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),'','','','','','','','','';
		END IF;
	END EXCEPTION;


	--------VALIDACIÃ??N DE PARAMETROS-------------------------
	
	
	IF  NVL(pcAgent_cd,'?')= '?' OR NVL(pcAgent_trans_type_code,'?')<> 'TDA_HUELLA' OR NVL(pcUsuario,'?')= '?'
		OR NVL(pcPassword,'?')= '?'	OR NVL(pcFecha_peticion,'?')= '?' OR NVL(pcHora_peticion,'?')= '?' 
		OR NVL(pcIp_origen,'')='' OR NVL(pcSession_id,'')=''
		OR NVL(pNumCte,'?')= '?' THEN
		
		LET cCodRet ='9996';
	
	ELSE
	
		EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id) 
		INTO cCodRet, mensaje;
			
		IF cCodRet = '0000' THEN 
						
			SELECT first 1  numcte,ref_coppel,secuencia,status_huella,dmapa,imapa,sexo, YEAR(fecha_alta_huella)||LPAD(MONTH(fecha_alta_huella),'2',0)||LPAD(DAY(fecha_alta_huella),'2',0),empleado,sucursal 
			into   cNumCte,cNumCte_cop,cSecuencia,cEstado,cDMapa,cIMapa,cSexo,cFecha_movto,cUsuario,cSucursal--01/18/2017
			FROM  si_huella_linea
			where numcte = pNumCte;
			
			if cDMapa <> '' and cIMapa <> ''then

				LET  cHuella	= 'V';
			else 
				LET  cHuella	= 'F';
			end if
			
			
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
	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso,cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
		INTO ccCodRetorno;
		
	END IF;

	INSERT INTO bdinteg:"informix".si_ws_tda_huella(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte_request,opcode,descr_message,date_process,time_process,numcte,dmapa,imapa,datetimeinsert)
	VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCte,cCodRet,mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),cHuella,cHuella,current); 
			
	RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),NVL(cNumCte_cop,''),NVL(cSecuencia,''),NVL(cEstado,''),NVL(cUsuario,''),NVL(cSucursal,''),NVL(cSexo,''),NVL(cFecha_movto,''),NVL(cDMapa,''),NVL(cIMapa,'');
	

	
END
END PROCEDURE;