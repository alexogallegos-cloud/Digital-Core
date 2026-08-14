CREATE PROCEDURE "informix".sp_reinicia_os ( pEmpresa CHAR(3))	
RETURNING CHAR(5);       -- Codigo de Retorno
		  

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMen_ret CHAR(80);


DEFINE iSecuencia INTEGER;
DEFINE cNumSol CHAR(20);
DEFINE dtFechaSol DATE;





LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMen_ret     = "Proceso Exitoso";

LET iSecuencia = 0;
LET cNumSol = "";
LET dtFechaSol = DATE(1);



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN cCodRet ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/sp_reinicia_os.out';
	--TRACE ON;


	FOREACH WITH HOLD
		SELECT secuencia, num_solicitud, fechasolicitud
			INTO iSecuencia, cNumSol, dtFechaSol
		FROM "informix".ss_osclientesupervisar 
		WHERE secuencia >= 1000000 and clave not in ('A','R') 
		and num_solicitud not in 
		(SELECT num_solicitud FROM "informix".ss_osclientesupervisar 
		WHERE secuencia >= 1000000 and secuencia <= 8999999 
		and fechasolicitud >= mdy('06','01','2016'))
		and empresa = pEmpresa

		
		BEGIN;
			UPDATE "informix".ss_osclientesupervisar
			SET clave ='R',creditojoven ='R'
			WHERE empresa =pEmpresa 
			and num_solicitud= cNumSol
			AND secuencia = iSecuencia
			AND fechasolicitud = dtFechaSol;
		COMMIT;
		

	END FOREACH;
	
	FOREACH WITH HOLD
	
		SELECT secuencia, num_solicitud, fechasolicitud
			INTO iSecuencia, cNumSol, dtFechaSol
		FROM "informix".ss_osclientesupervisar		
		WHERE secuencia >= 1000000 and clave in ('D') 
		and num_solicitud in (SELECT num_solicitud FROM "informix".ss_osclientesupervisar 
		WHERE secuencia >= 1000000 and secuencia <= 8999999 
		and fechasolicitud >= mdy('06','01','2016'))
		and empresa = pEmpresa

		
		BEGIN;
			UPDATE "informix".ss_osclientesupervisar
			SET clave ='R',creditojoven ='R'
			WHERE empresa =pEmpresa 
			and num_solicitud= cNumSol
			AND secuencia = iSecuencia
			AND fechasolicitud = dtFechaSol;
		COMMIT;
	END FOREACH	
	
	
		
					
		RETURN cCodRet ;
END
END PROCEDURE
