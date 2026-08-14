CREATE PROCEDURE "informix".sp_status_solicitudes
	(pEmpresa 				CHAR(3), 
	pNumeroCliente 			CHAR(20), 
	pNumSolicitudCoppel  	CHAR(20), 
	pNumSolicitudBanco  	CHAR(20), 
	pNumSolicitudPrestamo	CHAR(20))
	
    RETURNING	CHAR(5)  AS cCodRet, 
				CHAR(2)  AS cStatusSolicitud, 
				CHAR(30) AS cStatus, 
				CHAR(3)  AS cCausa, 
				CHAR(2)  AS cCodeStatus;
	
	-- ****************************************************************************
    -- *                        DEFINICION DE VARIABLES                           *
    -- ****************************************************************************
    
    DEFINE iSqlErr 				INTEGER;
    DEFINE cCodRet 				CHAR(5);
    DEFINE cStatusSolicitud		CHAR(2);
    DEFINE cStatus 				CHAR(30);
    DEFINE cCausa 				CHAR(3);
    DEFINE cCodeStatus 			CHAR(2);
    DEFINE iStatusProgreso 		INTEGER;
    DEFINE iStatusRechazo 		INTEGER;
    DEFINE iStatusAutorizada	INTEGER;
	
	-- ****************************************************************************
    -- *                        ASIGNACION DE VARIABLES                           *
    -- ****************************************************************************
    
    LET cStatusSolicitud	= "";  
    LET cCodRet 			= "00000";
    LET cStatus 			= "";
    LET cCausa 				= "";
    LET cCodeStatus 		= "SR";
    LET iStatusProgreso 	= 0;
    LET iStatusRechazo 		= 0;
    LET iStatusAutorizada 	= 0;
    
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    RETURN  cCodRet, cStatusSolicitud, cStatus, cCausa, cCodeStatus;
            END IF;
        END EXCEPTION;
        
        -- SET DEBUG FILE TO "/home/sysifx/sp_status_solicitudes.out";
        -- TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		-- ****************************************************************************
        -- *                        PROGRAMA PRINCIPAL                                *
        -- ****************************************************************************
        
			--Consulta los estatus de las solicitudes de credito en ss_solicitudes
            FOREACH
                SELECT      status_solicitud
                    INTO    cStatusSolicitud
                    FROM    bdisolic:"informix".ss_solicitudes
                    WHERE   num_solicitud = pNumSolicitudCoppel 
                    OR      num_solicitud = pNumSolicitudBanco 
                    OR      num_solicitud = pNumSolicitudPrestamo
                    AND     numcte = pNumeroCliente

                IF cStatusSolicitud IN ('BC','CC','EC','EE','OS','CE','OA','LC','MC','PC','EA','RA','ST','IN') THEN
                    LET iStatusProgreso = 1;
                ELIF cStatusSolicitud IN('RT','CM','CN','RP','AN') THEN
                    LET iStatusRechazo = 1;
                ELIF cStatusSolicitud IN('PA','AT','AP') THEN
                    LET iStatusAutorizada = 1;
                END IF;
                               
            END FOREACH
			
			--Consulta los estatus de las solicitudes de credito en ss_autorizacion
            FOREACH
                SELECT causa_solicitud 
                    INTO    cCausa
                    FROM    bdisolic:"informix".ss_autorizacion
                    WHERE   status_solicitud = cStatusSolicitud 
                    AND     num_solicitud = pNumSolicitudCoppel 
                    OR      num_solicitud = pNumSolicitudBanco 
                    OR      num_solicitud = pNumSolicitudPrestamo
             END FOREACH
            
			--Realiza la comparacion para obtener el estatus priopitario de las solicitudes
            IF iStatusAutorizada = 1 THEN
                LET cStatus = "Solicitud Autorizada"; 
                LET cCodeStatus = "SA";
            ELIF iStatusProgreso = 1 THEN
                LET cStatus = "Solicitud en Progreso"; 
                LET cCodeStatus = "SP";
            ELIF iStatusRechazo = 1 THEN
                LET cStatus = "Solicitud Rechazada/Cancelada"; 
                LET cCodeStatus = "SR";
            END IF
            
            RETURN cCodRet, NVL(cStatusSolicitud, ''), NVL(cStatus,''), NVL(cCausa, '') , NVL(cCodeStatus, 'SR');
    END  
  
END PROCEDURE
