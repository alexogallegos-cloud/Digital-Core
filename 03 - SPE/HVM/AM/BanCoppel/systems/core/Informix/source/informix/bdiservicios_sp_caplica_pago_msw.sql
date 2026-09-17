CREATE PROCEDURE "informix".sp_caplica_pago_msw(pcORIGEN 		CHAR(4),			
												pcTRANSACCION 	CHAR(5),
												pcCATEGORIA 	CHAR(2),
												pcCONVENIO 		CHAR(3),
												pcSUCURSAL 		CHAR(4),
												pcCAJERO 		CHAR(8), 
												pcCAJA 			CHAR(3), 
												pcFECHA 		CHAR(8),
												pcHORA 			CHAR(6), 
												pcFOLIO_OPERACION CHAR(18),
												pcREFERENCIA_1 	CHAR(40),
												pcREFERENCIA_2 	CHAR(40),
												pcREFERENCIA_3 	CHAR(40),
												pcREFERENCIA_4 	CHAR(40),
												pcIMPORTE 		CHAR(10), 
												pcFORMA_PAGO 	CHAR(1))
										
	RETURNING
		CHAR (5) AS 	ccodigo,
		CHAR (30) AS 	cmensaje,
		CHAR (16) AS 	FOLIO_SUC;

		

	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  INTEGER;
	DEFINE cPCodRet CHAR(5);
	DEFINE ccodigo CHAR(5);
	DEFINE cmensaje CHAR(30);
	DEFINE CFOLIO_SUC CHAR(16);
    DEFINE ejec	CHAR(250);
    DEFINE ejec2	CHAR(250);
    DEFINE cNombre_preceso 		CHAR(30);
    Define cFecha  CHAR(10); 
    Define cHora  CHAR(10); 
    Define cFechaSolitud  CHAR(20); 
	
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET ccodigo = '00000';
	LET cmensaje = '';
	LET CFOLIO_SUC ='';
    LET ejec='';
    LET ejec2='';
    LET cNombre_preceso="sp_aplica_pago_msw";
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
						
            RETURN ccodigo, cmensaje,CFOLIO_SUC;
        END IF;
    END EXCEPTION;
	
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

	 
	EXECUTE PROCEDURE bdisac:"informix".sp_aplica_pago_msw(pcORIGEN,pcTRANSACCION,pcCATEGORIA,pcCONVENIO,pcSUCURSAL,
	pcCAJERO,pcCAJA,pcFECHA,pcHORA,pcFOLIO_OPERACION,pcREFERENCIA_1,pcREFERENCIA_2,pcREFERENCIA_3,pcREFERENCIA_4,pcIMPORTE,pcFORMA_PAGO)
	into ccodigo,cmensaje,CFOLIO_SUC;
	
	LET ejec= 'sp_aplica_pago_msw('''||TRIM(pcORIGEN)||''','''||TRIM(pcTRANSACCION)||''','''||TRIM(pcCATEGORIA)||''','''||TRIM(pcCONVENIO)||''','''||TRIM(pcSUCURSAL)||''','''||TRIM(pcCAJERO)||''','''||TRIM(pcCAJA)||''','''||TRIM(pcFECHA)||''','''||TRIM(pcHORA)||''','''||TRIM(pcFOLIO_OPERACION)||''','''||TRIM(pcREFERENCIA_1)||''','''||TRIM(pcREFERENCIA_2)||''','''||TRIM(pcREFERENCIA_3)||''','''||TRIM(pcREFERENCIA_4)||''','''||TRIM(pcIMPORTE)||''','''||TRIM(pcFORMA_PAGO)||''')';
	LET ejec2= 'Respuesta('''||TRIM(ccodigo)||''','''||TRIM(cmensaje)||''','''||TRIM(nvl(CFOLIO_SUC,''))||')';
	
   

    SELECT today,DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
	INTO cFecha,cHora
	FROM sysmaster:"informix".sysshmvals;

    LET cFechaSolitud = ''||cFecha||' '||cHora||'';
																								
	INSERT INTO "informix".hs_btchservicios(fechasolicitud,proceso,parametrossolicitud,respuestasolicitud)
	VALUES(cFechaSolitud,cNombre_preceso,ejec,ejec2);  
																									
	RETURN ccodigo,cmensaje,CFOLIO_SUC;
	
	END;
END PROCEDURE
