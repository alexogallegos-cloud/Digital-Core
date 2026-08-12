CREATE PROCEDURE "informix".spgrabarcifracontrol (p_dFechaQuincena DATE, p_iTipoCifraCtrl SMALLINT, p_mMonto MONEY(18,2))
RETURNING CHAR(5) AS retorno;

	DEFINE sql_err 				INTEGER;
	DEFINE v_sCodRet			CHAR(5);	

	 --****************************************************************
	 --SET DEBUG FILE TO "/tmp/prisma/spgrabarcifracontrol.out";     --* 
	 --TRACE ON;                                            		--*
	--****************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				INSERT INTO bdirech:rec_errores(descripcion) VALUES ('sgcc'||sql_err);
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00001';		
		
		--Si algun parametro es nulo o el tipo de cifra de control es distinto a 1, 2, 3 Y 4
		IF NVL(p_dFechaQuincena, '') = '' OR NVL(p_mMonto,'') = '' OR NVL(p_iTipoCifraCtrl,'') = '' OR p_iTipoCifraCtrl NOT IN (1,2,3,4) THEN
			RETURN v_sCodRet;
		END IF;	
			
		IF p_iTipoCifraCtrl = 1 THEN --CIFRA CALCULADA
			IF EXISTS (SELECT 1 FROM bdirech:rec_cifrascontrol WHERE fechaquincena = p_dFechaQuincena) THEN
				UPDATE bdirech:rec_cifrascontrol SET cifracalculada = p_mMonto WHERE fechaquincena = p_dFechaQuincena;
			ELSE
				INSERT INTO bdirech:rec_cifrascontrol (fechaquincena, cifracalculada, cifraenviada, cifraaplicada, cifranoaplicada) 
				VALUES(p_dFechaQuincena, p_mMonto, 0.00, 0.00, 0.00);
			END IF
			LET v_sCodRet = '00000';
			
		ELIF p_iTipoCifraCtrl = 2 THEN --CIFRA ENVIADA
			UPDATE bdirech:rec_cifrascontrol SET cifraenviada = p_mMonto WHERE fechaquincena = p_dFechaQuincena;
			LET v_sCodRet = '00000';
			
		ELIF p_iTipoCifraCtrl = 3 THEN --CIFRA APLICADA
			UPDATE bdirech:rec_cifrascontrol SET cifraaplicada = p_mMonto WHERE fechaquincena = p_dFechaQuincena;			
			LET v_sCodRet = '00000';
			
		ELSE --CIFRA NO APLICADA
			UPDATE bdirech:rec_cifrascontrol SET cifranoaplicada = p_mMonto WHERE fechaquincena = p_dFechaQuincena;
			LET v_sCodRet = '00000';
			
		END IF
		RETURN v_sCodRet;
	END;
END PROCEDURE 
