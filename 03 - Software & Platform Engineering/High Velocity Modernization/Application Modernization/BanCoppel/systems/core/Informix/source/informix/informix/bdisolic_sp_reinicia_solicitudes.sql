CREATE PROCEDURE "informix".sp_reinicia_solicitudes ( pEmpresa CHAR(3))	
RETURNING CHAR(5);       -- Codigo de Retorno
		  

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMen_ret CHAR(80);
DEFINE p_cod_ret CHAR(6);
DEFINE iMotivoOs  INTEGER;

DEFINE iSecuencia INTEGER;
DEFINE cNumSol CHAR(20);
DEFINE dtFechaSol DATE;
DEFINE VARsituacionespecial char(1);
DEFINE VARcausasituacionespecial smallint;
DEFINE VARsituacionespecialrespuesta char(1);
DEFINE VARcausasituacionespecialrespuesta smallint;


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMen_ret     = "Proceso Exitoso";

LET iSecuencia = 0;
LET cNumSol = "";
LET dtFechaSol = DATE(1);
LET p_cod_ret     = "000000";
LET iMotivoOs     = 0;
LET VARsituacionespecial = '';
LET VARcausasituacionespecial = 0;
LET VARsituacionespecialrespuesta = '';
LET VARcausasituacionespecialrespuesta = 0;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/sp_reinicia_solicitudes.out';
	--TRACE ON;

			SELECT secuencia,a.num_solicitud
--				INTO iSecuencia, cNumSol
			FROM ss_osclientesupervisar a,  
                 ss_solicitudes b,
                 ss_solicitud_os c
			WHERE clave  in ('R')  and creditojoven ='R'
			and  fechasolicitud >= mdy('06','01','2016')
			and a.num_solicitud = b.num_solicitud 
            and a.num_solicitud = c.num_solicitud
            and a.secuencia = c.secuenciaos
			and b.status_solicitud ='OS'
            and c.status = 'P'
            and c.fecha_solicitud <> today
            and a.num_solicitud not in
            (select num_solicitud from bdisolic:ss_solicitud_os
            where num_solicitud in
            (SELECT a.num_solicitud
			FROM ss_osclientesupervisar a, 
                 ss_solicitudes b,
                 ss_solicitud_os c
			WHERE clave  in ('R')  and creditojoven ='R'
			and  fechasolicitud >= mdy('06','01','2016')
			and a.num_solicitud = b.num_solicitud 
            and a.num_solicitud = c.num_solicitud
            and a.secuencia = c.secuenciaos
			and b.status_solicitud ='OS'
            and c.status = 'P'
            and c.fecha_solicitud <> today)
            and fecha_solicitud = today)
			into temp paso_sol1 with no log;
			
			create index inx_paso_sol1 on paso_sol1(secuencia,num_solicitud);
			
			update statistics high for table paso_sol1;
			


	FOREACH WITH HOLD
		
			SELECT secuencia,num_solicitud
				INTO iSecuencia, cNumSol
				from paso_sol1
            
				--56413
				
				FOREACH WITH HOLD 
					SELECT  a.num_solicitud , motivo_os, situacionespecial,causasituacionespecial,situacionespecialrespuesta,causasituacionespecialrespuesta 
						INTO cNumSol , iMotivoOs, VARsituacionespecial ,VARcausasituacionespecial , VARsituacionespecialrespuesta , VARcausasituacionespecialrespuesta
					FROM ss_solicitud_os a ,  ss_solicitudes b
					WHERE secuenciaos = iSecuencia
					And a.empresa =pEmpresa
					and a.num_solicitud = b.num_solicitud 
					and b.status_solicitud ='OS'
                    and fecha_solicitud <> today
                    and a.num_solicitud in
                    (SELECT NUM_SOLICITUD from bdisolic:ss_solicitudes where numcte in
                     (select NUMCTE from bdisolic:SS_SOLICITUDES where num_solicitud = cNumSol))
					 
			   IF EXISTS (SELECT num_solicitud from bdisolic:ss_autorizacion 
			               WHERE empresa = '001' and num_solicitud = cNumSol and status_solicitud = 'EE' AND fecha_insert = TODAY) THEN
					CONTINUE FOREACH;
			   END IF;
				
				BEGIN WORK;
				UPDATE ss_solicitud_os 
				SET status  ='C'
				WHERE num_solicitud =cNumSol
				AND secuenciaos = iSecuencia;
				
				EXECUTE PROCEDURE "informix".sp_actualiza_status_sol 
				('001', 'sistema',cNumSol, 'EE', '', 'Solicitud Enviada a Orden de Supervisión' )
				INTO p_cod_ret;
				
				INSERT INTO "informix".ss_solicitud_os
				(empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, motivo_os)
				VALUES
				(pEmpresa, cNumSol, TODAY, "S", "sistema", VARsituacionespecial ,VARcausasituacionespecial , VARsituacionespecialrespuesta , VARcausasituacionespecialrespuesta, iMotivoOs);
				COMMIT WORK;
			END FOREACH 
			
	END FOREACH;	
	
		
					
		RETURN cCodRet ;
END
END PROCEDURE
