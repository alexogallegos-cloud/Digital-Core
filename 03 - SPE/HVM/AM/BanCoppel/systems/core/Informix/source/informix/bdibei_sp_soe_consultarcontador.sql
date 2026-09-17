CREATE PROCEDURE "informix".sp_soe_consultarcontador(pIdUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING
			CHAR(5) AS v_cod_ret,
			CHAR(50) AS vMensajeErr,
			INTEGER AS iContinuo;
			
			DEFINE v_cod_ret            CHAR(5);	
			DEFINE vMensajeErr			VARCHAR(50);
			DEFINE iSqlErr              INTEGER;
			DEFINE iSamErr              INTEGER;
			DEFINE iContinuo			INTEGER;
			DEFINE iCont				INTEGER;
			DEFINE i					INTEGER;
			
			LET v_cod_ret 	= '00000';
			LET vMensajeErr = '';
			LET	iContinuo	=0;
			LET iCont		=0;
			LET i = 0;
			
	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
				LET v_cod_ret = iSqlErr;
				LET vMensajeErr= 'ERROR INTERNO EN BASE DE DATOS';
			END IF;			
			RETURN v_cod_ret,vMensajeErr,iContinuo;
		END EXCEPTION;		
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_consultarcontador.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' THEN
			LET v_cod_ret = '00003';
			RETURN v_cod_ret,NULL,iContinuo;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO v_cod_ret;
		IF v_cod_ret <> '00000' THEN
			RETURN v_cod_ret,vMensajeErr,iContinuo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT valor::INTEGER 
		INTO iContinuo 
		FROM bdibei:"informix".soe_parametros 
		WHERE parametro='folio_comentarios';
	
		IF(iContinuo > 9999999)THEN
			LET iContinuo=0;
		END IF
		
		LET iCont=iContinuo + 1;
		
		UPDATE bdibei:"informix".soe_parametros 
		SET (valor, f_modificacion) = (TRIM(iCont::CHAR(50)), current) 
		WHERE parametro ='folio_comentarios';
	
		RETURN v_cod_ret,vMensajeErr,iContinuo;
	
	END;

END PROCEDURE;