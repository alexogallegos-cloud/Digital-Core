CREATE PROCEDURE "informix".spcalcularcifracontrol (p_dFechaQuincena DATE, p_iTipoCifraCtrl SMALLINT)
RETURNING CHAR(5) AS retorno, MONEY(18,2) AS suma;

	DEFINE sql_err 				INTEGER;
	DEFINE v_sCodRet			CHAR(5);
	DEFINE v_mCifraControl		MONEY(10);
	DEFINE v_sEstatus			CHAR(2);
	DEFINE v_iErrores			INTEGER;
	
	 --****************************************************************
	 --SET DEBUG FILE TO "/tmp/prisma/spcalcularcifracontrol.out";     --* 
	 --TRACE ON;                                            		--*
	--****************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				INSERT INTO bdirech:rec_errores(descripcion) VALUES ('sccc'||sql_err);
				RETURN v_sCodRet,0.00;
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00001';
		LET v_mCifraControl = 0.00;
		
		--si algun parametro es nulo o el tipo de cifra de control es distinto a 1 y 2
		IF NVL(p_dFechaQuincena, '') = '' OR NVL(p_iTipoCifraCtrl,'') = '' OR p_iTipoCifraCtrl NOT IN (1,2) THEN
			RETURN v_sCodRet, v_mCifraControl;
		END IF;	
			
		IF p_iTipoCifraCtrl = 1 THEN --DESCUENTO CALCULADO
			--valida proceso de CÁLCULO DE DESCUENTO
			EXECUTE PROCEDURE bdirech:spvalidarprocesos (p_dFechaQuincena, 3) INTO v_sCodRet, v_sEstatus, v_iErrores;	
			--se ejecutó correctamente el proceso de calculo de descuento con la fecha de la quincena sin errores.
			IF v_sEstatus = '1' AND v_iErrores = 0 THEN
				LET v_sCodRet = '00000';
				SELECT NVL(SUM(desccalculado),0.00) INTO v_mCifraControl FROM bdirech:rec_descquincena;
				
			ELSE
				LET v_sCodRet = '00002';
			END IF
			
		ELIF p_iTipoCifraCtrl = 2 THEN --DESCUENTO APLICADO
			--valida proceso de TRANSFERENCIA DE ARCHIVOS
			EXECUTE PROCEDURE bdirech:spvalidarprocesos (p_dFechaQuincena, 4) INTO v_sCodRet, v_sEstatus, v_iErrores;	
			--se ejecutó correctamente el proceso de transferencia de archivos con la fecha de la quincena sin errores.
			IF v_sEstatus = '1' AND v_iErrores = 0 THEN
				LET v_sCodRet = '00000';
				SELECT NVL(SUM(descaplicado),0.00) INTO v_mCifraControl FROM bdirech:rec_descquincena;
				
			ELSE
				LET v_sCodRet = '00002';
			END IF		
		END IF
		RETURN v_sCodRet, v_mCifraControl;
	END;
END PROCEDURE 
