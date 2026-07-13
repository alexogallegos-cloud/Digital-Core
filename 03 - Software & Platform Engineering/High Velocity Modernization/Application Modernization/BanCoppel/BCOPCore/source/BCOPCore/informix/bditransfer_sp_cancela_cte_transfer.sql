CREATE PROCEDURE "informix".sp_cancela_cte_transfer(pcAgent_trans_type_code 	CHAR(10),
													pcAgent_cd 					CHAR(6),
													pcUsuario 					CHAR(8),
													pcPassword 					CHAR(8),
													pcIp_origen 				CHAR(15),
													pcSession_id 				CHAR(30),
													pcServiceName 				CHAR(128),
													pcNumCelular 				CHAR(12),											
													pcRfc 						CHAR(13),
													pcNumcta					CHAR(20))
RETURNING CHAR(4) AS CodRetorno,
		  CHAR(200) AS Mensaje; 

/*DEFINICION DE VARIABLES */
DEFINE vsCodRetorno       	CHAR (4);
DEFINE vsMensaje          	CHAR(200);
DEFINE sql_err            	SMALLINT;
DEFINE isam_err           	SMALLINT;
DEFINE error_info         	CHAR(40);
DEFINE vsrfc				CHAR(13);
DEFINE vsNumCelular			CHAR(12);
DEFINE vsNumcta				CHAR(10);
DEFINE vcodretTemp			CHAR(4);
DEFINE vsNumCelular2        CHAR(10);

/*MANEJO DEL ERROR*/
       ON EXCEPTION
		SET sql_err, isam_err, error_info 
		 
           IF sql_err <> 0 THEN
            LET vsCodRetorno=sql_err;

            RETURN vsCodRetorno, vsMensaje;
           END IF;
       END EXCEPTION;

/* FIN DE DEFINICION DE VARIABLES*/
LET vsCodRetorno    = '0000';
LET vsMensaje       = 'CONSULTA EXITOSA';
LET sql_err         = 0;   
LET isam_err        = 0;  
LET error_info      ='';
LET vsrfc           = pcRfc;
LET vsNumCelular    = pcNumCelular;
LET vsNumCelular2 	= '';
LET vsNumcta        = pcNumcta;
LET vcodretTemp		='0000';

BEGIN
		--log
		--SET DEBUG FILE TO '/informix/ragomez/sp_cancela_cte_transfer.out';
		--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

     	--Se inserta el registro del proceso en curso
	--INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	--VALUES(cNombre_proceso,pcFecha_peticion,pcHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);

	
	--------------VALIDACIÃN DE PARAMETROS-------------------------
		IF 	NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?' OR NVL(pcAgent_trans_type_code,'?')= '?' 
			OR NVL(pcPassword,'?')= '?' OR NVL(pcIp_origen,'?')= '?' OR NVL(pcSession_id,'?')= '?' OR NVL(pcServiceName,'?')= '?'
			OR NVL(pcNumcta,'?')='?' OR NVL(pcRfc,'?')='?' OR NVL(pcNumCelular,'?')='?' THEN
			LET vsCodRetorno ='0001';
			LET vsMensaje='FALTAN PARAMETROS';
			--ERROR EN PARAMETROS
			
		ELSE
		
			EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcServiceName)
			INTO vcodretTemp,vsMensaje;
			
			IF vcodretTemp <> '0000' THEN
			
				LET vsCodRetorno = vcodretTemp;
              --  LET vsMensaje = vsMensaje;
				--ERROR EN SPL SP_VALIDA_SESSION
			ELSE
			
			--CANCELACION DE CUENTA TRANSFER---
			-----VALIDACION DE PARAMETROS------
			
				/*IF  NVL(pcNumcta,'')= '' OR NVL(pcRfc,'')= '' OR NVL(pcNumCelular,'')='' THEN
					LET vsCodRetorno ='0002';
					LET vsMensaje='FALTAN PARAMETROS DE CANCELACION.';*/

											
				--ELSE	
				
				LET vsNumCelular2 = substr(vsNumCelular, 3,10);
				
						IF LENGTH(pcRfc) = 13 THEN
							
							IF LENGTH(vsNumCelular2) = 10 THEN
							
								IF EXISTS (SELECT cuenta_tf FROM tf_maecte WHERE status_cta = '1' AND cuenta_tf = pcNumcta AND telefono = vsNumCelular2 AND rfc = vsrfc) THEN
								
									UPDATE {+INDEX(bditransfer:"informix".tf_maecte "idx_cancelacte")} "informix".tf_maecte 
									SET status_cta = '3'
									WHERE rfc = pcRfc AND cuenta_tf = pcNumcta AND telefono = vsNumCelular2;
									
									IF EXISTS (SELECT telefono FROM bdicheq:"informix".sc_cuenta_telefono WHERE es_transfer = 'S' AND telefono = vsNumCelular2)THEN
									
										DELETE FROM bdicheq:"informix".sc_cuenta_telefono WHERE es_transfer = 'S' AND telefono = vsNumCelular2;
										
									END IF;
									
										LET vsCodRetorno = '0000';
										LET vsMensaje ='CANCELACION EXITOSA.';
								
								ELSE
								
								LET vsCodRetorno ='0005';
								LET vsMensaje='EL CLIENTE NO EXISTE';
								
								END IF;
							
							ELSE
							
								LET vsCodRetorno ='0004';
								LET vsMensaje='TELEFONO INCORRECTO';
								
							END IF;
						
						ELSE
							LET vsCodRetorno ='0003';
							LET vsMensaje='RFC INCORRECTO';
						END IF;
																
				--END IF;
				
			END IF;
		END IF;
		
	RETURN vsCodRetorno, vsMensaje;

END;
END PROCEDURE;