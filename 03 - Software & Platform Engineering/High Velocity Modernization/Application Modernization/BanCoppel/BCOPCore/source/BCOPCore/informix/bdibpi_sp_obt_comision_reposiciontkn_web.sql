CREATE PROCEDURE "informix".sp_obt_comision_reposiciontkn_web(pCveComision CHAR(3))
	RETURNING char(5), money(14,2);

----------------------------------------------------------------------------------------------------------------------------------------
-- Realizo: Manuel Ramos Figueroa
-- Actividad: Obtiene la comision por Reposocion de Token desde Portal BPI.
-- Solicito: Walber Castro
-- Fecha de Solicitud: 23/12/2013
----------------------------------------------------------------------------------------------------------------------------------------

	DEFINE cCodret   char(5);
	DEFINE cComision  money(14,2);
	DEFINE sql_err   integer;

	LET cCodret = '00000';
	LET cComision = 0;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodret = sql_err;
				RETURN cCodret, cComision;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "sp_obt_comision_reposicionTkn.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT valor
		INTO cComision
		FROM bdibpi:"informix".tkn_parametros
		WHERE id_param = pCveComision;

		RETURN cCodret, NVL(cComision,0);
	END;
END PROCEDURE;