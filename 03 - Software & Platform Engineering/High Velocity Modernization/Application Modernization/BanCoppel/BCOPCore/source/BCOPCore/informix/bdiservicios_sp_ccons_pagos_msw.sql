CREATE PROCEDURE "informix".sp_ccons_pagos_msw(	pcOrigen 			CHAR(4),
												pcUsuario 			CHAR(8),
												pcCategoria 		CHAR(2),
												pcConvenio 			CHAR(3),
												pcFolio_suc 		CHAR(16),
												pcFolio_operacion 	CHAR(18),
												pcsucursal 			CHAR(4), 
												pccaja 				CHAR(3), 
												pcFecha 			CHAR(8), 
												pcHora				CHAR(6)) 
	RETURNING
		CHAR (5) AS ccodigo,
		CHAR (30) AS cMensaje,
		CHAR (5) AS cStatus,
		CHAR (16) AS cfolio_suc,
		CHAR (10) AS cImporte;
	
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  	INTEGER;
	DEFINE cPCodRet 	CHAR(5);
	DEFINE ccodigo 		CHAR(5);
	DEFINE cMensaje 	CHAR(30);
	DEFINE cfolio_suc 	CHAR(16);
	DEFINE cImporte 	CHAR(20);	
	DEFINE cStatus		char(5);
    DEFINE ejec	CHAR(250);
    DEFINE ejec2	CHAR(250);
    DEFINE cNombre_preceso 		CHAR(30);
    Define cFecha  CHAR(10); 
    Define cHora  CHAR(10); 
    Define cFechaSolitud  CHAR(20); 
	
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET ccodigo = '00000';
	LET cMensaje = '';
	LET cfolio_suc = '';
	LET cImporte = '';	
	LET cStatus='';
    LET ejec='';
    LET ejec2='';
    LET cNombre_preceso="sp_ccons_pagos_msw";
    LET cFecha ='';
    LET cHora  = '';
    Let cFechaSolitud = '';
	
--SET DEBUG FILE TO '/informix/cristo/sp_cpagos_activos_msw.out';
--TRACE ON;

    BEGIN
    -- 
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
            LET ccodigo = '500';
			LET cPCodRet = iSqlErr;
	  	
			
			LET cMensaje='Error desconocido';
		
            RETURN ccodigo, cMensaje,cStatus,cfolio_suc,cImporte;
        END IF;
    END EXCEPTION;
	
--SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 10;
	
	EXECUTE PROCEDURE bdisac:"informix".sp_cons_pagos_msw(pcOrigen,pcUsuario,pcCategoria,pcConvenio,pcFolio_suc,pcFolio_operacion,pcsucursal,pccaja,pcFecha,pcHora)
	into ccodigo,cMensaje,cStatus,cfolio_suc,cImporte;

    LET ejec= 'sp_cons_pagos_msw('''||TRIM(pcORIGEN)||''','''||TRIM(pcUsuario)||''','''||TRIM(pcCATEGORIA)||''','''||TRIM(pcCONVENIO)||''','''||TRIM(pcFolio_suc)||''','''||TRIM(pcFolio_operacion)||''','''||TRIM(pcsucursal)||''','''||TRIM(pccaja)||''','''||TRIM(pcFecha)||''','''||TRIM(pcHora)||''')';
	LET ejec2= 'Respuesta('''||TRIM(ccodigo)||''','''||TRIM(cmensaje)||''','''||TRIM(cStatus)||''','''||TRIM(cfolio_suc)||''','''||TRIM(cImporte)||''')';
				
    SELECT today,DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
	INTO cFecha,cHora
	FROM sysmaster:"informix".sysshmvals;

    LET cFechaSolitud = ''||cFecha||' '||cHora||'';

																				
	INSERT INTO "informix".hs_btchservicios(fechasolicitud,proceso,parametrossolicitud,respuestasolicitud)
	VALUES(cFechaSolitud,cNombre_preceso,ejec,ejec2);  
	


    RETURN ccodigo, cMensaje,cStatus,cfolio_suc,cImporte;
	
	END;
END PROCEDURE
