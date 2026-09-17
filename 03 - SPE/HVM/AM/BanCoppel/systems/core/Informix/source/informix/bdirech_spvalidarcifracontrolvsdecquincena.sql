CREATE PROCEDURE "informix".spvalidarcifracontrolvsdecquincena (p_dFechaQuincena DATE, p_iTipoCifraCtrl SMALLINT)
RETURNING CHAR(5) AS retorno, MONEY(18,2) AS diferencia;

	DEFINE sql_err 				INTEGER;
	DEFINE v_sCodRet			CHAR(5);
	DEFINE v_mDiferencia		MONEY(18,2);
	DEFINE v_mCifraCalculada	MONEY(18,2);
	DEFINE v_mCifraEnviada		MONEY(18,2);
	DEFINE v_mCifraaplicada		MONEY(18,2);
	DEFINE v_mCifraaplicadadescquincena		MONEY(18,2);
	DEFINE v_mCifraNoAplicada	MONEY(18,2);
	 --****************************************************************
	 --SET DEBUG FILE TO "/tmp/prisma/spvalidarcifracontrol.out";   --* 
	 --TRACE ON;                                            		--*
	--****************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				INSERT INTO bdirech:rec_errores(descripcion) VALUES ('scccvsquincena'||sql_err);
				RETURN v_sCodRet,0.00;
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00001';
		LET v_mDiferencia = 0.00;
		
		--si algun parametro es nulo o el tipo de cifra de control es distinto a 1 y 2
		IF NVL(p_dFechaQuincena, '') = ''  THEN --OR NVL(p_iTipoCifraCtrl,'') = '' OR p_iTipoCifraCtrl NOT IN (1,2)
			RETURN v_sCodRet, v_mDiferencia;
		END IF;	
		
		SELECT cifraaplicada
		INTO v_mCifraaplicada
		FROM bdirech:rec_cifrascontrol WHERE fechaquincena = p_dFechaQuincena;

        select sum(descaplicado)
        into v_mCifraaplicadadescquincena
        from rec_descquincena;
		
		--Existe el monto de la cifra control de la fecha quincena.
		IF NOT v_mCifraaplicada IS NULL or v_mCifraaplicadadescquincena IS NULL THEN
            LET v_mDiferencia = v_mCifraaplicada - v_mCifraaplicadadescquincena;           
                LET v_sCodRet = '00000';
		ELSE
			LET v_sCodRet = '00002';
		END IF;
		
		RETURN v_sCodRet, v_mDiferencia;
	END;
END PROCEDURE;