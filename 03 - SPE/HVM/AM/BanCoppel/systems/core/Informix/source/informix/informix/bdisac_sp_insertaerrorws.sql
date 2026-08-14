CREATE PROCEDURE "informix".sp_insertaerrorws(iTipo INTEGER, pProceso CHAR(30), pCodRet CHAR(5), pDescError CHAR(50), 
                                              pSqlErr CHAR(6),   pIsamErr CHAR(6), pCadena_ent CHAR (100),
											  pUsuario CHAR (8),  pFechaPeticion CHAR (8), pHoraPeticion CHAR (6) )
	RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 		   INTEGER;
DEFINE cCodRet 		   CHAR(5);
DEFINE cHoraInsert	   CHAR(6);
DEFINE cFechaInsert    CHAR(8);
--DEFINE dFechaInsert    DATE;
DEFINE iIsamErr        INTEGER;

--Set debug file to '/respaldosbd/jasmin/sp_insertaerrorws.out';
--TRACE ON; 


--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cHoraInsert     = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
--LET dFechaInsert    = CURRENT::DATE;
LET cFechaInsert    = pFechaPeticion;
LET iIsamErr        = 0;



BEGIN
	ON EXCEPTION
		SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;		
			INSERT INTO bdisac:"informix".sac_ws_errores (proceso,  cod_ret, desc_error, sql_err, isam_err, cadena_ent, user_insert, fecha_insert, hora_insert)
									VALUES (pProceso, pCodRet, '', iSqlErr, iIsamErr, pCadena_ent, pUsuario, CURRENT, cHoraInsert );
		
			UPDATE  bdisac:"informix".sac_ws_procesos
			SET cod_ret = pCodRet
			WHERE proceso = pProceso
			AND fecha_proceso = pFechaPeticion
			AND hora_proceso = pHoraPeticion
			AND user_insert = pUsuario
			AND estatus = 0;
		
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF iTipo = 1 THEN
		INSERT INTO bdisac:"informix".sac_ws_errores (proceso,  cod_ret, desc_error, sql_err, isam_err, cadena_ent, user_insert, fecha_insert, hora_insert)
									VALUES (pProceso, pCodRet, pDescError, pSqlErr, pIsamErr, pCadena_ent, pUsuario, CURRENT, cHoraInsert );
		
		UPDATE  bdisac:"informix".sac_ws_procesos
		SET cod_ret = pCodRet, estatus = 2 -- ERROR
		WHERE proceso = pProceso
		AND fecha_proceso = cFechaInsert
		AND hora_proceso = pHoraPeticion
		AND user_insert = pUsuario
		AND estatus = 0;
	ELSE
	    UPDATE  bdisac:"informix".sac_ws_procesos
		SET cod_ret = pCodRet, estatus = 1
		WHERE proceso = pProceso
		AND fecha_proceso = cFechaInsert
		AND hora_proceso = pHoraPeticion
		AND user_insert = pUsuario
		AND estatus = 0;
    END IF;	
	
	RETURN cCodRet;

END;

END PROCEDURE

DOCUMENT
'DESCRIPCION: procedimiento para insertar los errores ocasionados en el proceso de abono a cuenta automatico de BTS',
'AUTOR : Jasmin Soto',
'FECHA : 01/11/2012',
'VERSION: 1.0',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_valida_session(pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd 				CHAR(6),
											  pcUsuario 				CHAR(8),
											  pcPassword 				CHAR(8),
											  pcIp_origen 			CHAR(15),
											  pcSession_id 			CHAR(30))
											
        RETURNING
		CHAR (4) AS cRetCode,
		CHAR (256) AS cErDescription;		


--DECLARACION DE VARIABLES
DEFINE iSqlErr  		 INTEGER;
DEFINE cPCodRet 		 CHAR(5);
DEFINE cReturnCode 		 CHAR (4);
DEFINE cErrorDescription CHAR (100);
DEFINE cCodRet 			 CHAR(4);
	
DEFINE dtFecha_dia		DATE;
DEFINE vcEmpresa        CHAR(3);
DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_preceso	CHAR(17);
DEFINE cOpcode			CHAR(5);
DEFINE dFechaNueva 	 	CHAR(10);
DEFINE cDia         	CHAR(2);
DEFINE cMes         	CHAR(2);
DEFINE cAnio        	CHAR(4);

--INICIALIZACION DE VARIABLES
LET dtFecha_dia   = CURRENT::DATE;		
LET cAgent_cd ='';
LET cUsuario ='';
LET cPassword ='';
LET cIp_origeN ='';
LET cId_sesion_act ='';	
LET dFechaNueva   = DATE(1);

LET iSqlErr = 0;
LET cReturnCode = '0000';
LET cCodRet = '0000';
LET cOpcode = '0000';
LET cErrorDescription = 'Consulta exitosa';

--SET DEBUG FILE TO '/informix/manuel/sp_valida_session.out';
--TRACE ON;	

	BEGIN
   
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cOpcode = cCodRet;
			LET cErrorDescription='Codigo no registrado en catalogo.';

		RETURN trim(cOpcode), trim(cErrorDescription);
		
        END IF;
    END EXCEPTION;
	
	
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
	
    LET pcusuario=trim(pcusuario); 
	IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = pcusuario AND activa = 'S' ) THEN
	
		SELECT agent_cd,usuario,password,ip_origen,id_sesion_act::CHAR(30)
		INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
		FROM bdisac:"informix".sac_ws_clientes 
		WHERE agent_cd = pcAgent_cd AND usuario = pcusuario and  fecha_insert = dtFecha_dia;
		
		IF cAgent_cd = pcAgent_cd THEN
			IF cUsuario = pcUsuario   THEN
				IF cPassword = pcPassword THEN
					IF cIp_origen = pcIp_origen THEN
						IF cId_sesion_act = pcSession_id THEN
						--	IF length(pcSystemDate)>1 THEN
						--		LET cDia=SUBSTR(pcSystemDate,1,2);
						--		LET cMes=SUBSTR(pcSystemDate,3,2);
						--		LET cAnio=SUBSTR(pcSystemDate,5,4);
						--		LET dFechaNueva = mdy(cMes,cDia,cAnio);
					--		ELSE
						--		LET cReturnCode = '9996';
						--		LET cErrorDescription = "Consulta no exitosa. Fecha inválida. pcSystemDate>1";
					--		END IF;
						ELSE
							LET cReturnCode = '9975';
							LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
						END IF;
					ELSE
						LET cReturnCode = '9976';
						LET cErrorDescription = "Error autenticación. IP origen inválida ";
					END IF;
				ELSE
					LET cReturnCode = '9979';
					LET cErrorDescription = " Error autenticación. Password no existe.";
				END IF;
			ELSE
			    LET cReturnCode = '9980';
				LET cErrorDescription = 'Error autenticación. Usuario no existe';
			END IF;
		ELSE
			LET cReturnCode = '9998';
			LET cErrorDescription = "Autenticación fallida. Código de agente inválido.";
		END IF;
    ELSE
		LET cReturnCode ='9982';
		LET cErrorDescription = " Consulta no exitosa. Transacción no definida.";
	END IF;
	
	RETURN trim(cReturnCode), trim(cErrorDescription);
	
	END;
END PROCEDURE;