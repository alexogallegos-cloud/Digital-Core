CREATE PROCEDURE "informix".sp_co_ins_ctas_nom(p_ccmayor CHAR(4),p_ccsub CHAR(2),p_ccsubsub CHAR(2),p_ccssubsub CHAR(2),p_ccsssubsub CHAR(2),p_sector CHAR(2), p_descripcion CHAR(60))
	RETURNING	CHAR(6), VARCHAR(255);

DEFINE cVarDataErr					VARCHAR(64);
DEFINE iSqlErr						INTEGER;
DEFINE iSamErr						INTEGER;
DEFINE cod_ret						CHAR(5);
DEFINE v_mensaje					VARCHAR(255);

    ON EXCEPTION
		SET iSqlErr, iSamErr, cVarDataErr
		IF iSqlErr <> 0 THEN
			LET cod_ret = iSqlErr;
			RETURN cod_ret, iSamErr || ' ' ||cVarDataErr;
			END IF
	END EXCEPTION;

SET LOCK MODE TO WAIT 3;

    LET v_mensaje = "PROCESO EXITOSO";

    INSERT INTO co_ctas_internom VALUES ('001',p_ccmayor,p_ccsub,p_ccsubsub,p_ccssubsub,p_ccsssubsub,p_sector, p_descripcion);

    LET cod_ret = '000';

    RETURN cod_ret, v_mensaje;

END PROCEDURE;