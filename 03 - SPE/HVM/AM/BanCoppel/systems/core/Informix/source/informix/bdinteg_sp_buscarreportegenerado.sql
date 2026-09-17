CREATE PROCEDURE "informix".sp_buscarreportegenerado(p_sNombreArch CHAR(60), p_sEmpresa CHAR(3))						
RETURNING	INTEGER AS numRegistros;
	
	DEFINE v_iNumReg INTEGER;
	DEFINE iSqlErr INTEGER;

	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 18/12/2008
	--busca en repgenerado la existencia de algun reporte con el nombre del archivo expecificado
	--regresa 0 si no existe, 1 si existe, -1 si existio un error
	--SET DEBUG FILE TO "/tmp/sif/sp_buscarReporteGenerado.out";
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_iNumReg = -1;
				RETURN v_iNumReg;
			END IF;
		END EXCEPTION;	
		
		SELECT COUNT(*) INTO v_iNumReg
		FROM bdinteg:si_repgenerado
		WHERE empresa = p_sEmpresa
		AND UPPER(TRIM(nombre_arch)) = NVL(UPPER(TRIM(p_sNombreArch)),UPPER(TRIM(nombre_arch)));
				
		RETURN v_iNumReg;		
	END;
END PROCEDURE;