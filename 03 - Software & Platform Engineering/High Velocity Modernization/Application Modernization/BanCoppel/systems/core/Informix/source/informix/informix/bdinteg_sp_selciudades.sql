CREATE PROCEDURE "informix".sp_selciudades(p_sEmpresa CHAR(3))
                
    RETURNING CHAR(5) as codigo, CHAR(3) as claveregion, CHAR(40) as nombreregion;
		    
	--DEFINICION DE VARIABLES
	DEFINE vCodret 				CHAR(5);
	DEFINE iSqlErr          	INTEGER;
	DEFINE v_sclaveregion		CHAR(3);
	DEFINE v_snombreregion		CHAR(40);
	
	--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--CREADO POR: VLADIMIR FÉLIX GÁLVEZ 8/JULIO/2009
	--Sp que obtiene las ciudades de la tabla si_regiones
	--DEBUG DEL PROCEDURE
	--SET DEBUG FILE TO "/tmp/sp_consultarcatciudades.out";
	--TRACE ON;
	--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	BEGIN
		ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCodret = iSqlErr;
                RETURN vCodret,'','';
            END IF;
        END EXCEPTION;
		
		IF (p_sEmpresa = '' OR p_sEmpresa IS NULL) THEN
			LET vCodret = '001';
			RETURN vCodret,'','';
		END IF;
		
		LET vCodret = '000';
		
		FOREACH
			SELECT regional, nombre
			INTO v_sclaveregion, v_snombreregion
			FROM bdinteg:"informix".si_regional
			WHERE regional = regional
                AND empresa = p_sEmpresa
			ORDER BY regional
			
			RETURN vCodret, v_sclaveregion, v_snombreregion WITH RESUME;
			
		END FOREACH;
	END;
END PROCEDURE;