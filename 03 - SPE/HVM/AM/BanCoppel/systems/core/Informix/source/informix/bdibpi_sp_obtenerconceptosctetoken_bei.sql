CREATE PROCEDURE "informix".sp_obtenerconceptosctetoken_bei(pNumCliente VARCHAR(9))
RETURNING CHAR (5), INT, CHAR(80), CHAR(1);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Obtiene conceptos del cliente
	-- Fecha: 29/08/2011

	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_concepto INT;
	DEFINE iIdUsuario INT;
	DEFINE vDesc_concepto VARCHAR(70);
	DEFINE vResp_concepto VARCHAR(1);
	DEFINE vCadConcepto VARCHAR(80);
	DEFINE iContador INT;

	LET cCod_ret = '00000';
	LET vDesc_concepto = '';
	LET iId_concepto = 0;
	LET vResp_concepto = '';
	LET iIdUsuario = 0;
	LET vCadConcepto = '';
	LET iContador = 0;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, iId_concepto, vDesc_concepto, vResp_concepto;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		SELECT id_usuario INTO iIdUsuario FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		SELECT trim(desc_resp) INTO vCadConcepto FROM bdibpi:"informix".bpi_resp_seguridadpm WHERE id_pregunta = 10 AND id_usuario = iIdUsuario;
		WHILE (LENGTH(vCadConcepto) > 0)
			LET iId_concepto = SUBSTR(vCadConcepto, 1, 2)::INT;
			LET vResp_concepto = SUBSTR(vCadConcepto, 3, 1);
			LET vCadConcepto = SUBSTR(vCadConcepto, 4);

			IF iContador < 9 THEN

				SET LOCK MODE TO WAIT ;
				SET ISOLATION DIRTY READ ;

				SELECT desc_pregunta INTO vDesc_concepto FROM bdibpi:"informix".bpi_cat_preguntaspm WHERE id_pregunta = iId_concepto;
				LET iContador = iContador + 1;

				RETURN cCod_ret, iId_concepto, vDesc_concepto, vResp_concepto WITH RESUME;
			END IF;
		END WHILE;
	END;

END PROCEDURE;