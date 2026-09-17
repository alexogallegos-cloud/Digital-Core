CREATE PROCEDURE "informix".sp_app_getorderstoreprocess (pcUsuario CHAR(15),
	pRegs_recup INTEGER,
	pFecha_peticion CHAR(8),
	pHora_peticion CHAR(6))

--Datos a regresar
RETURNING 	CHAR(12) AS numremesa,
            CHAR(5) AS channelId,
            CHAR(8) AS fec_proceso,
            CHAR(6) AS hora_proceso,
            CHAR (5) AS codret;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(5);
DEFINE cCod_retorno 	CHAR(5); -- del procedimiento sp_insertaerrorws
DEFINE cCodigo		 	CHAR(4);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cRemesa			CHAR(12);
DEFINE cCadena_ent		CHAR(100);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE iIntentos 		INTEGER;
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE iContadorIntentosenvio INTEGER;
DEFINE iIntentosenvio   INTEGER;
DEFINE cChannelId       CHAR(4);

	--SET DEBUG FILE TO '/informix/EPG/sp_app_confirmorder.out';
	--TRACE ON;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err ='00000';
LET cCodigo ='';
LET cCod_retorno ='';	-- del procedimiento sp_insertaerrorws
LET cRemesa ='';
LET cNombre_preceso ='sp_app_getorderstoreprocess';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = NVL(pRegs_recup,0) || '|' || TRIM(NVL(pFecha_peticion,'NULL')) || '|' || TRIM(NVL(pHora_peticion,'NULL'));
LET cDescr_mensaje ='';
LET iIntentos =0;
LET iContadorIntentosenvio = 0;
LET iIntentosenvio = 0;
LET cChannelId = '';


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_app_confirmorder.out";                                           
--TRACE ON; 
	BEGIN
	-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr,iIsamError
			IF iSqlErr <> 0 THEN
				LET cCod_err = iSqlErr;			
				LET cDescr_mensaje = 'ERROR DE INFORMIX.';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
				INTO cCod_retorno;
				
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err;
			END IF;
		END EXCEPTION;
		
		--Se inserta el registro del proceso en curso
		--INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		--VALUES(cNombre_preceso,pFecha_peticion,pHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);

		LET pcUsuario  =  pcUsuario;
			
		IF NVL(pRegs_recup,0) > 0 THEN
			--OBTIENE EL NUMERO DE INTENTOS PERMITIDOS.
			SELECT valor
			INTO iIntentos
			FROM bdisac:"informix".sac_param
			WHERE empresa = '001'
			AND cod_param = '87109';
	
			FOREACH
				SELECT LIMIT pRegs_recup UniqueReferenceNumber,Code, intentos_envio, channelid
				INTO cRemesa,cCodigo,iIntentosenvio,cChannelId
				FROM bdisac:"informix".sac_app_getorder
				WHERE (estatus_getorder = '13')
				AND intentos_envio <= NVL(iIntentos,0)
			    AND UniqueReferenceNumber <>  ''
				--AND channelid = cChannelId
				ORDER BY fecha_insert desc

                UPDATE bdisac:"informix".sac_app_getorder SET estatus_getorder = '14' WHERE UniqueReferenceNumber = cRemesa 
				and estatus_getorder = '13'
				AND intentos_envio <= NVL(iIntentos,0);
				
                --Contador de intentos de confirmacion EPG 26/10/2020
                LET iContadorIntentosenvio = iIntentosenvio + 1;
                UPDATE bdisac:"informix".sac_app_getorder  SET intentos_envio = iContadorIntentosenvio WHERE UniqueReferenceNumber = cRemesa;
                LET iContadorIntentosenvio = 0;
                
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err WITH RESUME;
			END FOREACH
			--NO SE ENCONTRO INFORMACION.
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '1100';
				LET cDescr_mensaje ='NO SE ENCONTRO INFORMACION EN SAC_APP_GETORDER';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
					INTO cCod_retorno;
				
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err;	
			END IF;
			
			SELECT opcode_ds 
			INTO cDescr_mensaje
			FROM bdisac:"informix".sac_app_cat_mensajes
			WHERE agent_trans_type_code = 'PAYI'
			AND opcode = LPAD(cCodigo,4,'0');
			
			
			--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			--INTO cCod_retorno;
			
		ELSE
			LET cCod_err = '1100';
			LET cDescr_mensaje ='EL PARAMETRO PREGS_RECUP VIENE VACIO CON VALOR 0.';
		END IF
		
		IF cCod_err::INTEGER <> 0 THEN
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			INTO cCod_retorno;
			
			RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,lpad(cCod_err,5,'0');
		END IF
	END
END PROCEDURE;