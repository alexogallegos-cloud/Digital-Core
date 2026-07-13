CREATE PROCEDURE "informix".sp_creverso_msw(pcOrigen 	CHAR(4),
											pcCategoria CHAR(2),
											pcConvenio 	CHAR(3),											
											pcUsuario 	CHAR(8),
											pcFolio_suc CHAR(16),
											pcFecha 	CHAR(8),
                                            pcHora 		CHAR (6),
                                            pcsucursal_cpl 	CHAR(4),
                                            pccaja_cpl    CHAR (3),
                                            pcfolio_operacion CHAR(18),
                                            pcreferencia CHAR (40)) 



	RETURNING
		CHAR (5) AS ccodigo,
		CHAR (30) AS cmensaje;
	
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  INTEGER;
	DEFINE cPCodRet CHAR(5);
	DEFINE ccodigo CHAR (5);
	DEFINE cMensaje CHAR (30);
    DEFINE ejec	CHAR(250);
    DEFINE ejec2 CHAR(250);
    DEFINE cNombre_preceso CHAR(30);
    Define cFecha  CHAR(10); 
    Define cHora  CHAR(10); 
    Define cFechaSolitud  CHAR(20); 
    Define vpaso    integer;
			
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET ccodigo = '00000';
	LET cMensaje = '';
    LET ejec='';
    LET ejec2='';
    LET cNombre_preceso="sp_creverso_msw";
    LET cFecha ='';
    LET cHora  = '';
    Let cFechaSolitud = '';


				
--SET DEBUG FILE TO '/informix/andrescrespo/sp_cpagos_activos_msw.out';
--TRACE ON;

    BEGIN



    -- 
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
            LET ccodigo = iSqlErr;
			LET cPCodRet = iSqlErr;
	  	
			
			LET cMensaje='Error en paso: '|| vpaso;
						
            RETURN ccodigo, cMensaje;
        END IF;
    END EXCEPTION;
	
--SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 10;
	let vpaso  = 1;
   IF pcFolio_suc =  '' THEN 
    select folio_suc into pcFolio_suc from  bdisac:sac_movimientos where id_sucursal = 9764 and status_cancelado = 'N' and origen = 'CPL' and sucursal_cpl = pcsucursal_cpl and caja_cpl = pccaja_cpl and  folio_operacion = pcfolio_operacion and referencia1 = pcreferencia;
     
   END IF;

   let vpaso  = 2;
	EXECUTE PROCEDURE bdisac:"informix".sp_reverso_msw(pcOrigen,pcCategoria,pcConvenio,pcUsuario,pcFolio_suc,pcFecha,pcHora)
	into ccodigo,cMensaje;
    let vpaso  = 3;
    LET ejec= 'sp_reverso_msw('||TRIM(pcOrigen)||''','''||TRIM(pcCategoria)||''','''||TRIM(pcConvenio)||''','''||TRIM(pcUsuario)||''','''||TRIM(pcFolio_suc)||''','''||TRIM(pcFecha)||''','''||TRIM(pcHora)||')';
	let vpaso  = 4;
    LET ejec2= 'Respuesta('||TRIM(ccodigo)||''','''||TRIM(cmensaje)||')';

    let vpaso  = 5;
    SELECT today,DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
	INTO cFecha,cHora
	FROM sysmaster:"informix".sysshmvals;

    LET cFechaSolitud = ''||cFecha||' '||cHora||'';

	let vpaso  = 6;																							
	INSERT INTO "informix".hs_btchservicios(fechasolicitud,proceso,parametrossolicitud,respuestasolicitud)
	VALUES(cFechaSolitud,cNombre_preceso,ejec,ejec2);  

	
	RETURN ccodigo, cMensaje;
	
	END;
END PROCEDURE;