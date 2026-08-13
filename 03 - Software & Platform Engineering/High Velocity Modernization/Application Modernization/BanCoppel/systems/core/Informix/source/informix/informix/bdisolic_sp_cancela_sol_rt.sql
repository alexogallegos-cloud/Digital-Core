CREATE PROCEDURE "informix".sp_cancela_sol_rt()
		RETURNING CHAR(5) AS codret;


DEFINE cCodRet CHAR(6);
DEFINE cNum_solicitud    	CHAR(20);
DEFINE iSqlErr INTEGER;

LET cNum_solicitud = '';
LET iSqlErr = 0;
LET cCodRet='000000';



--SET DEBUG FILE TO "/home/sysifx/JesusTASF/sp_respaldo_ss_autorizacion.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END EXCEPTION;


	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
	FOREACH 
		SELECT s.num_solicitud INTO cNum_solicitud
		FROM bdisolic: "informix".ss_solicitudes AS s JOIN ss_solic_rt AS r ON s.num_solicitud = r.num_solicitud
		WHERE s.status_solicitud = 'RT' OR s.status_solicitud = '' OR s.status_solicitud IS NULL 
		
		UPDATE bdisolic: "informix".ss_solicitudes SET status_solicitud = 'CN' WHERE num_solicitud = cNum_solicitud;
		
		EXECUTE PROCEDURE bdisolic: "informix".sp_actualiza_status_sol('001', "SISTEMA", cNum_solicitud, "CN","","Cancelacion por evaluaciÃ³n automÃ¡tica") INTO cCodRet;
	END FOREACH;
	
	RETURN cCodRet;
END;
END PROCEDURE
