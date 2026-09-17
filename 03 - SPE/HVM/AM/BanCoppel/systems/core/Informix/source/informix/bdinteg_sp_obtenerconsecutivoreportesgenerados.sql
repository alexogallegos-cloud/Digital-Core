CREATE PROCEDURE "informix".sp_obtenerconsecutivoreportesgenerados(p_dFechaReporte DATE, p_sTipoReq CHAR(1), p_sTipoRep CHAR(1),
 p_sEmpresa CHAR(3), p_sNombreArchivo char(60)) 
	RETURNING INTEGER AS consecutivo;
				
	DEFINE v_iConsecutivo INTEGER;					

	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 17/12/2008
	--SET DEBUG FILE TO "/tmp/sp_obtenerConsecutivoReportesGenerados.out";
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN		 
		IF p_sTipoReq = '' THEN
			LET p_sTipoReq = NULL;
		END IF
		SELECT MAX(consecutivo) INTO v_iConsecutivo 
		FROM bdinteg:si_repgenerado
		WHERE empresa = p_sEmpresa 
		AND fecha_rep = p_dFechaReporte 
		AND UPPER(tipo_rep) = UPPER(p_sTipoRep)
		AND	UPPER(tipo_req) = UPPER(NVL(p_sTipoReq,tipo_req));
		--AND UPPER(trim(nombre_arch)) = UPPER(NVL(p_sNombreArchivo, trim(nombre_arch)));
			
		LET v_iConsecutivo = NVL(v_iConsecutivo, 0);
		RETURN v_iConsecutivo + 1;
	END
END PROCEDURE;