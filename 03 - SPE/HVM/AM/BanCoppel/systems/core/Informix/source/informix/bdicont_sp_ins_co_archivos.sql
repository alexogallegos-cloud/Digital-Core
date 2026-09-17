CREATE PROCEDURE "informix".sp_ins_co_archivos(p_archivo VARCHAR(100), p_fecha DATE)
	RETURNING	CHAR(6), VARCHAR(255);

DEFINE cVarDataErr					VARCHAR(64);
DEFINE iSqlErr						INTEGER;
DEFINE iSamErr						INTEGER;
DEFINE cod_ret						CHAR(5);
DEFINE v_mensaje					VARCHAR(255);

-- SET DEBUG FILE TO "/informix/TESO/sp_ins_co_archivos.out";  
-- TRACE ON;  
-- CC 23/03/2010 

    ON EXCEPTION
		SET iSqlErr, iSamErr, cVarDataErr
		IF iSqlErr <> 0 THEN
			LET cod_ret = iSqlErr;
			RETURN cod_ret, iSamErr || ' ' ||cVarDataErr;
			END IF
	END EXCEPTION;

SET LOCK MODE TO WAIT 3;

    LET v_mensaje = "PROCESO EXITOSO";

    INSERT INTO co_archivos VALUES (p_archivo,p_fecha);

    LET cod_ret = '000';

    RETURN cod_ret, v_mensaje;

END PROCEDURE;