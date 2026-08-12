CREATE PROCEDURE "informix".sp_depura_sd_movhis()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cStatus      CHAR(2);

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET cStatus      = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr
	IF iSqlErr != 0 THEN
		LET cCodRet = iSqlErr;		
		RETURN cCodRet;
	END IF;
END EXCEPTION;

--    SET DEBUG FILE TO '/INFORMIXDUMP/sp_depura_sd_movhis.out';
--    TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

SET LOCK MODE TO WAIT 3;
SET ISOLATION COMMITTED READ;

SELECT num_credito
  INTO vNumCredAux
  FROM "informix".sd_param_movhis_dep
 where proceso = 1;

 IF vNumCredAux IS NULL THEN 
   LET vNumCredAux = ""; 
END IF;

FOREACH WITH HOLD
	
	SELECT TRIM(num_solicitud), TRIM(status_solicitud)
	  INTO vNumCred, cStatus
	  FROM bdisolic:"informix".ss_solicitudes
	 WHERE empresa     = '001' 
	   AND num_solicitud > vNumCredAux
	   AND status_solicitud IN ('CN','AN','PC')
       AND fecha_insert < mdy(01,01,2013)
  ORDER BY num_solicitud ASC
  
	BEGIN WORK;
	
	      DELETE FROM bdisolic:"informix".ss_os_errores 
		        WHERE num_solicitud = vNumCred 
				  AND fechaproceso < mdy(01,01,2013);
		  
		  DELETE FROM bdisolic:"informix".ss_osclientesupervisar 
		        WHERE empresa = '001' 
				  AND num_solicitud = vNumCred 
		          AND (clave IN ('A','D','R') OR (clave = '' AND cStatus = 'CN'))
                  AND fecharespuesta < mdy(01,01,2013);
				  
		  DELETE FROM bdisolic:"informix".ss_solicitud_os 
				WHERE empresa = '001'
				  AND num_solicitud = vNumCred
				  AND (status IN ('A','D','R') OR (status = '' AND cStatus = 'CN')) 
				  AND fecha_respuesta < mdy(01,01,2013);
					
		  DELETE FROM bdisolic:"informix".ss_anexosol
			    WHERE empresa = '001'
				  AND num_solicitud = vNumCred
				  AND fecha_insert < mdy(01,01,2013);
				  
		  DELETE FROM bdisolic:"informix".ss_autorizacion_especial
			    WHERE empresa = '001'
				  AND num_solicitud = vNumCred;

          DELETE FROM bdisolic:"informix".ss_autorizacion
                WHERE empresa = '001'
                  AND num_solicitud = vNumCred;
	
		  DELETE FROM bdisolic:"informix".ss_solicitudes
	            WHERE empresa     = '001' 
				  AND num_solicitud = vNumCred
				  AND status_solicitud IN ('CN','AN','PC')
		          AND fecha_insert < mdy(01,01,2013);
	
		  UPDATE "informix".sd_param_movhis_dep SET num_credito = vNumCred WHERE proceso = 1;
	
	COMMIT WORK;

END FOREACH;

RETURN cCodRet;

END
END PROCEDURE;