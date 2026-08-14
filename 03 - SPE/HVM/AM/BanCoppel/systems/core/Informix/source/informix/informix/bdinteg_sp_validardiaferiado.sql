CREATE PROCEDURE "informix".sp_validardiaferiado(p_sEmpresa CHAR(3), p_dFecha DATE)
RETURNING CHAR(5) AS CodigoRetorno, DATE AS DiaFeriado, CHAR(30) AS DescDiaFeriado, CHAR(1) AS LaborableSN;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sCodRet		CHAR(5);
	
	DEFINE v_dFecha			DATE;
	DEFINE v_sDescripcion	CHAR(30);
	DEFINE v_sLaborable		CHAR(1);

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet, '', '', '';
			END IF;
		END EXCEPTION;

	   --set debug file to "/tmp/sp_validardiaferiado.out";
	    --trace on;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF NVL(p_sEmpresa, '') = '' OR NVL(p_dFecha, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet, '', '', '';
		END IF;	 

		SELECT fecha, descripcion, laborable INTO v_dFecha, v_sDescripcion, v_sLaborable FROM bdinteg:si_feriado 
		WHERE empresa = p_sEmpresa AND fecha = p_dFecha;
		
		IF v_dFecha IS NULL THEN
			LET v_sCodRet = '00000';			
			RETURN v_sCodRet, '', '', '';
		ELSE
			LET v_sCodRet = '00002';
			RETURN v_sCodRet, v_dFecha, v_sDescripcion, v_sLaborable;
		END IF		
	END
END PROCEDURE;