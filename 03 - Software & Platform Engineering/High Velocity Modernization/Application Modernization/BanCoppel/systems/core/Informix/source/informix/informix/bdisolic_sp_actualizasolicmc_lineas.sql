CREATE PROCEDURE "informix".sp_actualizasolicmc_lineas()
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION; 

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cMensajeRet		CHAR(80);
    DEFINE cNumSol			CHAR(20);
    DEFINE dMontoSol1		DECIMAL(18,2);
    DEFINE dMontoSol2		DECIMAL(18,2);
	

	---INICIALIZACIONES
    LET iSqlErr				= 0;
    LET iIsamErr			= 0;
    LET cErrorInfo			= '';
    LET cCodRet				= '000000';
    LET cMensajeRet			= 'Proceso Exitoso';
    LET cNumSol				= '';
    LET dMontoSol1			= 0;
    LET dMontoSol2			= 0;
	

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	---SET DEBUG FILE TO "/informix/jesus/sp_actualizasolicmc_lineas.out";
	---TRACE ON;
	
	FOREACH WITH HOLD
		
		SELECT a.num_solicitud,a.monto_solicitado,c.monto_solicitado
			INTO cNumSol,dMontoSol1,dMontoSol2
		FROM "informix".ss_solicitudes a,"informix".ss_solicitudes_mc c, "informix".ss_solicitud_os d,"informix".ss_os_errores e
		WHERE a.empresa ='001' 
		and a.num_solicitud = c.num_solicitud
		and d.num_solicitud = c.num_solicitud
		and e.num_solicitud = c.num_solicitud
		and d.status='P'
		AND a.status_solicitud =a.status_solicitud	
		AND a.status_solicitud = 'EE'
		AND a.fecha_insert > mdy(7,25,2013) and a.fecha_insert < mdy(9,10,2013)



		IF dMontoSol1 <> dMontoSol2  THEN
				UPDATE "informix".ss_solicitudes
				SET monto_solicitado =dMontoSol2
				WHERE empresa ='001' 
				AND num_solicitud = cNumSol;
		END IF;

		IF NOT EXISTS (SELECT  *   FROM "informix".ss_solicitud_os WHERE num_solicitud = cNumSol and status='S' and fecha_solicitud = TODAY) THEN 
			INSERT INTO "informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
			VALUES("001", cNumSol, TODAY, "S", "SISTEMA", 1);
							
		END IF;
	

	END FOREACH;


	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
