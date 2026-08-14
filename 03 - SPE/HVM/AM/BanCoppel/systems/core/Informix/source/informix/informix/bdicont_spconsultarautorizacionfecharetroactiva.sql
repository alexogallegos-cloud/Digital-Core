CREATE PROCEDURE "informix".spconsultarautorizacionfecharetroactiva( p_sEmpresa CHAR (3), p_sClaveAutorizacion CHAR(6), p_dFechaCaptura DATE,
p_dFechaInicial DATE, p_dFechaFinal DATE, p_sUsuarioAutoriza CHAR (8), p_sUsuarioSolicita CHAR(8))

       RETURNING CHAR (5) AS codret, CHAR(8) AS empresa, DATE AS fecha_captura, DATE AS fecha_inicial, DATE AS fecha_final, CHAR(8) AS usuario_autoriza, 
				CHAR(8) AS usuario_solicita, CHAR(6) AS clave_autorizacion, CHAR(1) AS estatus_uso, MONEY(18,2) AS importe;

	
	DEFINE v_sEmpresa			CHAR(3);
	DEFINE v_dFechaCaptura 		DATE;
	DEFINE v_dFechaInicial 		DATE;
	DEFINE v_dFechaFinal		DATE;
	DEFINE v_sUsuarioAutoriza	CHAR(8);
	DEFINE v_sUsuarioSolicita  	CHAR(8);
	DEFINE v_sClaveAutorizacion	CHAR(6);
	DEFINE v_sEstatusUso		CHAR(1);
	DEFINE v_mImporte			MONEY(18,2);
	DEFINE v_sConfirma			CHAR(5);
	DEFINE iSqlErr	   			INTEGER;
	DEFINE v_sCodRet			CHAR (5);		

	LET v_sCodRet = '00000';
 
 	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'','','','','','','','','';
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/tmp/spConsultarAutorizacionFechaRetroactiva.out";                                                                                               
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'') = '' THEN
			LET v_sCodRet ='00001';
			RETURN v_sCodRet,'','','', '','','','','','';
		END IF;
		
		IF NVL(p_sClaveAutorizacion,'') = '' THEN
			LET p_sClaveAutorizacion = NULL;			
		END IF;
		
		IF NVL(p_dFechaCaptura, '') = '' THEN
			LET p_dFechaCaptura = NULL;			
		END IF;
		
		IF NVL(p_dFechaInicial, '') = '' THEN
			LET p_dFechaInicial = NULL;			
		END IF;
		
		IF NVL(p_dFechaFinal, '') = '' THEN
			LET p_dFechaFinal = NULL;			
		END IF;
		
		IF NVL(p_sUsuarioAutoriza, '') = '' THEN
			LET p_sUsuarioAutoriza = NULL;
		END IF;
		
		IF NVL(p_sUsuarioSolicita, '') = '' THEN
			LET p_sUsuarioSolicita = NULL;
		END IF;
	
		--OBTIENE LOS DATOS DEL USUARIO.
		FOREACH
			SELECT empresa, fecha_captura, fecha_inicial, fecha_final, usuario_autoriza, usuario_solicita, 
			clave_autorizacion, estatus_uso, importe 
			INTO v_sEmpresa, v_dFechaCaptura, v_dFechaInicial, v_dFechaFinal, v_sUsuarioAutoriza, v_sUsuarioSolicita,
			v_sClaveAutorizacion, v_sEstatusUso, v_mImporte
			FROM bdicont:co_clv_retroact 
			WHERE fecha_captura = NVL(p_dFechaCaptura, fecha_captura)
		      AND fecha_final = NVL(p_dFechaFinal,fecha_final) 
		      AND fecha_inicial = NVL(p_dFechaInicial, fecha_inicial)
			  AND usuario_autoriza = NVL(p_sUsuarioAutoriza,usuario_autoriza) 
              AND usuario_solicita = NVL(p_sUsuarioSolicita, usuario_solicita) 
			  AND clave_autorizacion = NVL (p_sClaveAutorizacion, clave_autorizacion)

			RETURN v_sCodRet, v_sEmpresa, v_dFechaCaptura, v_dFechaInicial, v_dFechaFinal, v_sUsuarioAutoriza, v_sUsuarioSolicita,
			v_sClaveAutorizacion, v_sEstatusUso, v_mImporte WITH RESUME;
			
		END FOREACH;
		
	END
END PROCEDURE;