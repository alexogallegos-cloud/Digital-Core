CREATE PROCEDURE "informix".sp_obtenertiposreq(p_sTipoReq CHAR(1), p_sEmpresa CHAR(3))
	RETURNING	CHAR(1) AS tipo,
				CHAR(30) AS descripcion;
				
	DEFINE v_sTipo				CHAR(1);
	DEFINE v_sDescripcion		CHAR(30);

	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 17/12/2008
	--SET DEBUG FILE TO "/tmp/sif/sp_obtenerTiposReq.out";
	--TRACE ON;
	--------------------------------------------------------------------------	
	
	BEGIN		
		IF p_sTipoReq = '' THEN
			LET p_sTipoReq = NULL;
		END IF
		FOREACH
			SELECT tipo, descripcion
			INTO v_sTipo, v_sDescripcion
			FROM bdinteg:si_tiporeq
			WHERE empresa = p_sEmpresa
			AND UPPER(tipo) = NVL(UPPER(p_sTipoReq),UPPER(tipo))
			
			RETURN v_sTipo, v_sDescripcion WITH RESUME;
		END FOREACH
	END
END PROCEDURE;