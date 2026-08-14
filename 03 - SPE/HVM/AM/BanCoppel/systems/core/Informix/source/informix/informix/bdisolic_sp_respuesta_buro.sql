CREATE PROCEDURE "informix".sp_respuesta_buro(pNumCliente char(20), pNumSolicitud char(20),pNumSolicitud2 char(20))
RETURNING CHAR(6) as retorno,
		  CHAR(1) as respuesta;
		  

DEFINE iSqlErr			INTEGER;
DEFINE nrows            CHAR(6);
DEFINE statusSolicitud  INTEGER;
DEFINE statusSolicitud2 INTEGER;
DEFINE bStatus			  CHAR(2);
DEFINE bStatus2			  CHAR(2);
DEFINE bValidaStatus2   CHAR(1);

LET iSqlErr        	 = 0;
LET nrows          	 = '000000';
LET statusSolicitud  = 0;
LET statusSolicitud2 = 0;
LET bValidaStatus2	 = '0';
LET bStatus 		 = '';
LET bStatus2 		 = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			RETURN iSqlErr,bValidaStatus2;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/JoseLuis/529/sp_respuesta_buro.out";
	--TRACE ON;
	
	IF pNumCliente = '' OR pNumSolicitud = '' THEN
		RETURN nrows,bValidaStatus2;
	END IF;
	

	IF pNumSolicitud <> "" AND pNumSolicitud2 <> "" THEN
	
		SELECT status_solicitud,(CASE when status_solicitud NOT IN('BC','EC') then (case when status_solicitud = 'RT' then 1 else 2 end) else 0 end) as Status
		INTO bStatus,statusSolicitud
		FROM bdisolic:"informix".ss_solicitudes 
		WHERE num_solicitud = pNumSolicitud;    				
		
		SELECT status_solicitud,(CASE when status_solicitud NOT IN('BC','EC') then (case when status_solicitud = 'RT' then 1 else 2 end) else 0 end) as Status
		INTO bStatus2, statusSolicitud2
		FROM bdisolic:"informix".ss_solicitudes 
		WHERE num_solicitud = pNumSolicitud2;    
			
		IF statusSolicitud  = 0 THEN
			IF  statusSolicitud2 = 0 THEN
				LET bValidaStatus2 = '0';
			ELIF statusSolicitud2 = 1 THEN				
				LET bValidaStatus2 = '0';
			ELIF statusSolicitud2 = 2 THEN
				LET bValidaStatus2 = '2';
			END IF
		ELIF statusSolicitud = 1 THEN					
			IF  statusSolicitud2 = 0 THEN
				LET bValidaStatus2 = '0';
			ELIF statusSolicitud2 = 1 THEN				
				LET bValidaStatus2 = '1';
			ELIF statusSolicitud2 = 2 THEN
				LET bValidaStatus2 = '2';
			END IF
		ELIF statusSolicitud = 2 THEN
			LET bValidaStatus2 = '2';
		END IF
		
		
					
	ELSE
	
		SELECT status_solicitud,(CASE when status_solicitud NOT IN('BC','EC') then (case when status_solicitud = 'RT' then 1 else 2 end) else 0 end) as Status
		INTO bStatus, bValidaStatus2
		FROM bdisolic:"informix".ss_solicitudes 
		WHERE num_solicitud = pNumSolicitud;    
		LET statusSolicitud  = bValidaStatus2::INTEGER;
		
	END IF
	IF statusSolicitud = 1 THEN
		IF (SELECT estatus FROM bdisolic:"informix".ss_prospecteo_solicitudes 
			WHERE num_solicitud = pNumSolicitud
			AND numcte = pNumCliente
			AND empresa = '001') = 'A' THEN
			
			UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
			SET estatus = 'C',status_solicitud = bStatus
			WHERE num_solicitud = pNumSolicitud
			AND numcte = pNumCliente
			AND empresa = '001'; 
			
		END IF
	end if
	
	IF statusSolicitud2 = 1 THEN
		IF (SELECT estatus FROM bdisolic:"informix".ss_prospecteo_solicitudes 
			WHERE num_solicitud = pNumSolicitud2
			AND numcte = pNumCliente
			AND empresa = '001') = 'A' THEN
			
			UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
			SET estatus = 'C',status_solicitud = bStatus2
			WHERE num_solicitud = pNumSolicitud2
			AND numcte = pNumCliente
			AND empresa = '001';
			
		END IF
	END IF
		


	RETURN nrows, bValidaStatus2;


END
END PROCEDURE
