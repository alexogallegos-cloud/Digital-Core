CREATE PROCEDURE "informix".sp_selmoneda(p_sEmpresa CHAR(3))
	
    RETURNING CHAR(5) AS codigo, 
            CHAR(2) AS divisa, 
            CHAR(4) AS sigla, 
            CHAR(3) AS cve_intl, 
            CHAR(3) AS cve_oficial, 
            CHAR(3) AS empresa, 
            CHAR(30) AS descripcion;		 
		  
	--DEFINICION DE VARIABLES
	DEFINE vCodret 				CHAR(5);
	DEFINE iSqlErr          	INTEGER;
	DEFINE v_sclavemoneda		CHAR(3);
	DEFINE v_snombremoneda		CHAR(40);
	DEFINE v_ssigla				CHAR(4);		
	DEFINE v_scve_intl			CHAR(3);
	DEFINE v_scve_oficial		CHAR(3);
	DEFINE v_sempresa			CHAR(3);
	
	--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--CREADO POR: VLADIMIR FÉLIX GÁLVEZ 8/JULIO/2009
	--Sp que obtiene las monedas de la tabla si_divisas
	--DEBUG DEL PROCEDURE
	--SET DEBUG FILE TO "/tmp/sp_consultarcatmonedas.out";
	--TRACE ON;
	--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	BEGIN
		ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCodret = iSqlErr;
                RETURN vCodret,'','','','','','';
            END IF;
        END EXCEPTION;
		
		IF (p_sEmpresa = '' OR p_sEmpresa IS NULL) THEN
			LET vCodret = '001';
			RETURN vCodret,'','','','','','';
		END IF;
		
		LET vCodret = '000';
		
		FOREACH
			SELECT divisa, sigla, cve_intl, cve_oficial, empresa, descripcion
			INTO v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa, v_snombremoneda
			FROM bdinteg:"informix".si_divisas
			WHERE empresa = p_sEmpresa
                AND divisa = divisa
			ORDER BY divisa

			RETURN vCodret, v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa, v_snombremoneda WITH RESUME;
			
		END FOREACH;
	END;
END PROCEDURE;