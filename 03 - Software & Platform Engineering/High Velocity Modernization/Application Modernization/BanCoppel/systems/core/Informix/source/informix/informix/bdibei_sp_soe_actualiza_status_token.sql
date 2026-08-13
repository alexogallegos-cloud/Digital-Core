CREATE PROCEDURE "informix".sp_soe_actualiza_status_token(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(9), pEstatus CHAR(4), 
												pNumSerieToken VARCHAR(10), pCIdUsuario INTEGER)
		
	RETURNING 
			CHAR(5) AS v_cod_ret,
			VARCHAR(50) AS vMensajeErr;
		
		DEFINE iExiste		SMALLINT;
		DEFINE v_cod_ret    CHAR(5);
		DEFINE vMensajeErr	VARCHAR(50);
		DEFINE iSamErr      INTEGER;
		DEFINE iSqlErr      INTEGER;
		
		LET iExiste		=0;	
		LET v_cod_ret	='00000';
		LET vMensajeErr = '';
												
	BEGIN
		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
				LET v_cod_ret = iSqlErr;
				LET vMensajeErr= 'ERROR INTERNO EN BASE DE DATOS';
			END IF;			
			RETURN v_cod_ret,vMensajeErr;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_actualiza_status_token.out';
		--TRACE ON;

		IF pIdUsuario = '' OR pIdFuncion = '' THEN
			LET v_cod_ret = '00003';
			RETURN v_cod_ret,NULL;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO v_cod_ret;
		IF v_cod_ret <> '00000' THEN
			RETURN v_cod_ret,vMensajeErr;
		END IF;
	
		IF pNumCliente = '' OR pEstatus = '' OR pNumSerieToken = '' OR pCIdUsuario = '' THEN
			LET v_cod_ret = '00003';
			LET vMensajeErr= 'PARAMETROS INCORRECTOS';
			RETURN v_cod_ret,vMensajeErr; 
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3; 
		
		SELECT COUNT(*)
		INTO iExiste
		FROM bdibei:"informix".bei_token a, bdibei:"informix".bei_usuario b
		WHERE a.num_cliente = pNumCliente AND a.id_usuario = pCIdUsuario
			AND b.num_cliente = a.num_cliente AND b.id_usuario = a.id_usuario;
																	
		IF iExiste = 0 THEN
			LET v_cod_ret = '00189';
			LET vMensajeErr= 'TOKEN RECIBIDO.';
			RETURN v_cod_ret,vMensajeErr; 
		END IF;
		
		IF pEstatus = '160' THEN
			UPDATE bdibei:"informix".bei_token
			   SET id_status_token = '140',
			       f_status = CURRENT
			 WHERE id_usuario = pCIdUsuario
			   AND num_cliente = pNumCliente
               AND ns_token = pNumSerieToken;
			
			LET vMensajeErr= pEstatus;							
			RETURN v_cod_ret, vMensajeErr;
		ELSE
			UPDATE bdibei:"informix".bei_token
			   SET id_status_token = pEstatus,
			       f_status = CURRENT
			 WHERE id_usuario = pCIdUsuario
			   AND num_cliente = pNumCliente
               AND ns_token = pNumSerieToken;
			
			LET vMensajeErr = pEstatus;							
			RETURN v_cod_ret, vMensajeErr;
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 26/09/2013",
"DESCRIPCION: Actualiza el estatus del tokenm para SOE en SOC";

CREATE PROCEDURE "informix".sp_soe_autentica_cliente(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodEmail CHAR(8), pAutenticar CHAR(1))
	RETURNING CHAR(5) AS codret, INTEGER AS regs_afectados;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegs SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegs;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_autentica_cliente.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodEmail = '' OR pAutenticar = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		IF pAutenticar NOT IN('0', '1') THEN
			LET cCodRet = '00049';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		IF pAutenticar = '0' THEN
			LET pAutenticar = 'f';
		ELIF pAutenticar = '1' THEN
			LET pAutenticar = 't';
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		UPDATE bdibei:"informix".soe_codigo_email
		SET usu_autenticado = pAutenticar
		WHERE codigo_email = pCodEmail;
		
		LET iNoRegs = dbinfo('sqlca.sqlerrd2');
		
		RETURN cCodRet, iNoRegs;
	
	END;
	
END PROCEDURE;