CREATE PROCEDURE "informix".sp_monsol_consultacausas(pStatus CHAR(2))
RETURNING
	CHAR(5) AS COD_RET,
	CHAR(2) AS STATUS,
	VARCHAR(40) AS DESC_STA,
	CHAR(3) AS CAUSA,
	VARCHAR(100) AS DESC_CAUSA; 

	---DECLARACIONES
    DEFINE cCodRet            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE cStatus				CHAR(2);
	DEFINE vcDescStatus			VARCHAR(40);
	DEFINE cCausa				CHAR(3);
	DEFINE vcDescCausa			VARCHAR(100);
	
	
	---INICIALIZACIONES
	LET cCodRet = '00000';
	LET cStatus				= "";
	LET cCausa				= "";
	LET vcDescStatus			= "";
	LET vcDescCausa			= "";
	

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
        END IF;
		
        RETURN cCodRet, NULL, NULL, NULL, NULL;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	---SET DEBUG FILE TO "/tmp/has/sp_monsol_consultacausas.out";
	---TRACE ON;

	IF pStatus IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet, NULL, NULL, NULL, NULL;
	END IF
	
	IF pStatus = "" THEN
		FOREACH
			SELECT status_solicitud, descripcion, "", ""
			  INTO cStatus, vcDescStatus, cCausa, vcDescCausa 
			  FROM bdisolic:"informix".ss_status_sol 		
			ORDER BY status_solicitud
			
			RETURN cCodRet, cStatus, vcDescStatus, cCausa, vcDescCausa WITH RESUME;
		END FOREACH
	ELIF pStatus = "#"THEN
        
            FOREACH
                SELECT t2.status_solicitud, t2.causa_solicitud, t2.causa_solicitud ||' ' || t2.descripcion
                  INTO cStatus, cCausa, vcDescCausa
                  FROM bdisolic:"informix".ss_causas_sol t2
              
                RETURN cCodRet, cStatus, vcDescStatus, cCausa, vcDescCausa WITH RESUME;
            END FOREACH
      ELSE      
            FOREACH 
                SELECT status_solicitud, "", causa_solicitud, causa_solicitud || ' ' || descripcion
                  INTO cStatus, vcDescStatus, cCausa, vcDescCausa
                  FROM bdisolic:"informix".ss_causas_sol
				WHERE status_solicitud = TRIM(pStatus)

                RETURN cCodRet, cStatus, vcDescStatus, cCausa, vcDescCausa WITH RESUME;
            END FOREACH
	END IF
END;

END PROCEDURE
