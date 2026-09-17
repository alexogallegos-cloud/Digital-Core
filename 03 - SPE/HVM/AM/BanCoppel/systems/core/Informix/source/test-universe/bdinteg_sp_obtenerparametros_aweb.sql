CREATE PROCEDURE "informix".sp_obtenerparametros_aweb(p_iCodParam INTEGER, p_sEmpresa CHAR(3))
	RETURNING	CHAR(5)  AS retorno,
				CHAR(50) AS descripcion,
				CHAR(100) AS valor;

	DEFINE v_codret     CHAR(5);
	DEFINE v_sDescripcion 	CHAR(50);
	DEFINE v_sValor			CHAR(100);
	LET v_codret    = "00000";
	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 17/12/2008
	--SET DEBUG FILE TO "/tmp/sp_obtenerParametros.out";
	--TRACE ON;
	--------------------------------------------------------------------------

 
       SET ISOLATION TO DIRTY READ;
       SET LOCK MODE TO WAIT 3;

	BEGIN
		FOREACH
			SELECT descripcion, valor
			INTO v_sDescripcion, v_sValor
			FROM bdinteg:si_param
			WHERE cod_param = NVL(p_iCodParam,cod_param)
                        AND empresa = p_sEmpresa

			RETURN v_codret, v_sDescripcion, v_sValor WITH RESUME;
		END FOREACH
	END
END PROCEDURE;