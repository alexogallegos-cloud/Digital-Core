CREATE PROCEDURE "informix".sp_situacionespecialcte_cpl(pSituacion CHAR(3), pCausa VARCHAR(4))

RETURNING
	CHAR(6),
	CHAR(5)

--- DECLARACIONES
DEFINE cCodRet 							CHAR(6);
DEFINE iSqlErr                          INTEGER;
DEFINE iSamErr                          INTEGER;
DEFINE cDesErr                          CHAR(60);
         

DEFINE cIdusituacionEspecial            CHAR(5);
--DEFINE iCausaSituacionEspecial          SMALLINT;


--- INICIALIZACIONES
LET cCodRet = '000000';
LET iSqlErr = 0;
LET iSamErr = 0;
LET cDesErr = '';
LET cIdusituacionEspecial = " ";
--LET iCausaSituacionEspecial = 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr, cDesErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet, NULL;
		END EXCEPTION;

	--	SET DEBUG FILE TO '/tmp/Yadira/sp_situacionesp_out.sql';
	--	TRACE ON;

		IF (NVL(pSituacion,"") = ""  )  OR  (nvl(pCausa,"") = "") THEN
            RETURN '000003', NVL(cIdusituacionEspecial,"");
		ELSE
				
			SELECT NVL(idu_situacion,"") INTO  cIdusituacionEspecial FROM bdinteg:"informix".si_relacionsituacionescausasbcpl_cpl WHERE clv_situacion=TRIM(pSituacion) AND   num_causasituacion= TRIM(pCausa);
			
			IF  NVL(cIdusituacionEspecial,"") =  "" THEN
			
			   RETURN '000004', NVL(cIdusituacionEspecial,"");
			   
			END IF
										
		        RETURN '000000', NVL(cIdusituacionEspecial,"");
		END IF;

		RETURN  cCodRet, NVL(cIdusituacionEspecial,"") ;

	END;
END PROCEDURE
DOCUMENT
"Folio: 1743",
"Autor: 96674555 Carolina Verdugo",
"Fecha: 17/08/2015", 
"Detalle: Se crea procedimiento para consultar la sitacion especial del cliente.",
"Solicita:  Rodolfo Gomez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_ws_afore_cfhue(pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  pNumCte CHAR(20),
											  pMatch CHAR(5))

RETURNING CHAR(5),CHAR(4),CHAR(100),CHAR(8),CHAR(6);

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE vsMensaje        CHAR(200);
DEFINE cCodRet 			CHAR(4);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(255);
DEFINE cDescr_completa_mensaje 	CHAR(80);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE cCadena_ent		CHAR(100);
DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_proceso	CHAR(17);
DEFINE cCod_retorno		CHAR(5);


DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;



--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCodRet = '0000';
LET cOpcode = '0000';
LET cDescr_mensaje = 'Consulta Exitosa.';
LET cDescr_completa_mensaje = 'Consulta Exitosa.';


LET cFecha_proceso = trim(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));

LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
LET cAgent_cd = '';
LET cUsuario = '';
LET cPassword = '';
LET cIp_origen = '';
LET cId_sesion_act = '';
LET cNombre_proceso = 'sp_ws_afore_cfhue';
LET cCod_retorno  = '';
LET cFecha_dia    = '';
LET dtFecha_dia   = CURRENT::DATE;
LET vsMensaje     = '';


BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError,vsMensaje
		--SET DEBUG FILE TO '/tmp/cristo/sp_ws_afore_cfhue.out';
		--TRACE ON;
		IF iSqlErr <> 0 THEN
		
			IF iSqlErr = '-1213' THEN --Se controla error al ingresar una palabra como numero de cliente 
				LET cCodRet = '0001';
				LET cOpcode = cCodRet;
			
				SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
				INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
				FROM bdisac:"informix".sac_ws_catmensajes
				WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;

				IF cOpcode IS NULL THEN
					LET cOpcode = cCodRet;
					LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
					LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
				END IF;
			
			ELSE 
				LET cCodRet = iSqlErr;
				LET cOpcode = cCodRet;

				LET cDescr_mensaje = '';
				LET cDescr_completa_mensaje = '';

			END IF;
			
			INSERT INTO bdinteg:"informix".si_ws_afore_cfhue(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte,match_huella,opcode,descr_message,date_process,time_process,datetimeinsert)
			VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCte,pMatch,cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,current);


			RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso;

		END IF;
	END EXCEPTION;

	--log
	--SET DEBUG FILE TO '/tmp/cristo/sp_ws_afore_cfhue.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;



	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombre_proceso,pcFecha_peticion,pcHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);

	--Se valida que alguno de los parametros de entrada no venga nulo

	IF NVL(pcAgent_trans_type_code, '') = '' OR NVL(pcAgent_cd, '') = '' OR NVL(pcUsuario, '') = '' OR NVL(pcPassword, '') = '' OR NVL(pcIp_origen, '') = '' OR NVL(pcSession_id, '') = '' OR NVL(pcFecha_peticion, '') = '' OR NVL(pcHora_peticion, '') = '' OR NVL(pNumCte, '') = '' OR NVL(pMatch, '') = '' THEN
		LET cCodRet = '9996';

	ELSE
		IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
				   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND  usuario=trim(pcusuario) AND activa = 'S' ) THEN

			--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
			SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
			INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
			FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd and usuario=trim(pcusuario);

            SELECT fecha_hoy
            INTO dtFecha_dia
            FROM bdisac:"informix".sac_fechas
			where empresa = '001';

 			LET cFecha_dia = YEAR(dtFecha_dia) || LPAD(MONTH(dtFecha_dia),2,'0') || LPAD(DAY(dtFecha_dia),2,'0');

			IF cAgent_cd = pcAgent_cd THEN
				IF cUsuario = pcUsuario THEN
					IF cPassword = pcPassword THEN
						IF cIp_origen = pcIp_origen THEN
							IF cId_sesion_act = pcSession_id THEN
									--Se valida que la fecha sea correcta la del servidor
									IF pcFecha_peticion = cFecha_dia THEN
										IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd and fecha_insert = dtFecha_dia and usuario=trim(pcusuario)) THEN
											IF UPPER(TRIM(pMatch)) IN ('FALSE','TRUE') THEN
												IF pNumCte::integer > 0  THEN 
													SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
													INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
													FROM bdisac:"informix".sac_ws_catmensajes
													WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;

													IF cOpcode IS NULL THEN
														LET cOpcode = cCodRet;
														LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
														LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
													END IF;
													
													--INSERT INTO TABLA NUEVA
													--Se inserta el registro con el estado de la conexion hecha, con los datos generados en el proceso en curso, en caso de error de informix.
													INSERT INTO bdinteg:"informix".si_ws_afore_cfhue(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte,match_huella,opcode,descr_message,date_process,time_process,datetimeinsert)
													VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCte,pMatch,cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,current);
												ELSE
													LET cCodRet = '0001';
												END IF;
											ELSE
												LET cCodRet = '0002';
											END IF;
										ELSE
											LET cCodRet = '9975';
										END IF;
									ELSE
										LET cCodRet = '9977';
									END IF;
							ELSE
								LET cCodRet = '9975';
							END IF;
						ELSE
							LET cCodRet = '9976';
						END IF;
					ELSE
						LET cCodRet = '9979';
					END IF;
				ELSE
					LET cCodRet = '9980';
				END IF;
			ELSE
				LET cCodRet = '9998';
			END IF;
		ELSE
			LET cCodRet = '9999';
		END IF;
	END IF;
	
	IF cCodRet <> '0000' THEN	
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cCodRet;
			LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
			LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;
		
		INSERT INTO bdinteg:"informix".si_ws_afore_cfhue(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte,match_huella,opcode,descr_message,date_process,time_process,datetimeinsert)
		VALUES(pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,pNumCte,pMatch,cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,current);
		
		
	END IF;
	
	RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso;
END;
END PROCEDURE;