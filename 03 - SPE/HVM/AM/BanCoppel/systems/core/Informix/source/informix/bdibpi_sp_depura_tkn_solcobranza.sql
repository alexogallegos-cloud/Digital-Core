CREATE PROCEDURE "informix".sp_depura_tkn_solcobranza()
	RETURNING CHAR(5);

	--************************************************************************************************************************************************
	--Objetivo: Depurar las solicitudes de la tabla tkn_solcobranza, dejando solo 3 meses de registro
	--Solicitó: Gabriela Aguilar
	--Fecha: 2016-03-14
	--BD:bdibpi
	--************************************************************************************************************************************************

	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iDiasVigencia INTEGER;

	LET cCod_ret = '00000';
	LET iDiasVigencia = 90;

	--SET DEBUG FILE TO '/informix/gaby/';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;


		DELETE  FROM bdibpi:"informix".tkn_solcobranza WHERE f_solicitud < CURRENT YEAR TO SECOND - iDiasVigencia UNITS DAY;
		RETURN cCod_ret;
	END;
END PROCEDURE;