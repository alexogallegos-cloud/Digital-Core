CREATE PROCEDURE "informix".sp_obtenerdialaborable(p_sEmpresa CHAR(3), p_dFecha DATE)
	RETURNING  CHAR(6) AS CodRet, DATE AS Dia;

	DEFINE v_inumdiahab INTEGER;
	DEFINE v_dfecha DATE;
	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(6);

--***********************************************************
-- Creado por Marcos Cuevas    27/feb/2009               --*
-- Debug del Procedure                                    --*
-- SET DEBUG FILE TO "/tmp/sp_ObtenerDiaLaborable.out";--*
-- TRACE ON;                                              --*
--***********************************************************

BEGIN

ON EXCEPTION
	SET iSqlErr
	IF iSqlErr <> 0 THEN
		LET vCodRet = iSqlErr;
		RETURN vCodRet,'01-01-1900';
	END IF;
END EXCEPTION;

	LET vCodRet = '000000';
	LET v_inumdiahab = 0;
	LET v_dfecha = p_dFecha;

	IF (p_sEmpresa is NULL) OR (p_sEmpresa = '') THEN
		LET vCodRet = '000001';
		LET v_dfecha = '01-01-1900';
	END IF;

	IF (p_dFecha is NULL) OR (p_dFecha = '') THEN
		LET vCodRet = '000001';
		LET v_dfecha = '01-01-1900';
	END IF;

	IF (vCodRet = '000000') THEN
		WHILE (v_inumdiahab = 0)
			IF NOT EXISTS (SELECT fecha FROM bdinteg:si_feriado WHERE fecha = v_dFecha AND laborable = 'N' AND empresa = p_sEmpresa) THEN
				LET v_inumdiahab = v_inumdiahab + 1;
			ELSE
				LET v_dfecha = v_dFecha + 1 UNITS DAY;
			END IF
		END WHILE;
	END IF;

	RETURN vCodRet,v_dfecha;
END
END PROCEDURE;