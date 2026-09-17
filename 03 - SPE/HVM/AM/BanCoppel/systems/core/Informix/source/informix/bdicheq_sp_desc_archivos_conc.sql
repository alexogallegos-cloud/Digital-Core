CREATE PROCEDURE "informix".sp_desc_archivos_conc(pEmpresa CHAR(3), pFechaInicio DATE, pFechaFin DATE)
RETURNING CHAR(5);
    
    
    DEFINE vcodret                  CHAR(5);
	DEFINE vfechafin                DATE;
    DEFINE vsqlerr 					INTEGER;
	DEFINE vfecha1					CHAR(8);
	DEFINE vfecha2					CHAR(2);
    DEFINE vcSql                    CHAR(600);
	DEFINE vcStmt                   CHAR(250);
	DEFINE vruta_descarga           CHAR(60);
	
	
    LET vcodret   = "00000";                                                                                  
	LET vsqlerr   = 0; 
	LET vfecha1   = "";
	LET vfecha2   = "";
	LET vcSql     = "";
	LET vcStmt    = "";
	LET vruta_descarga = '';
	
    
    
     --SET DEBUG FILE TO "/tmp/sp_desc_archivos_conc.out";
     --TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/tmp/sp_desc_archivos_conc.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pEmpresa IS NULL OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
        LET vcodret = '001';
        RETURN vcodret;
    END IF; 
    
	SELECT valor
      INTO vruta_descarga
      FROM sc_param
      WHERE empresa = pEmpresa
		AND codparam = 'RutaDescargaFED';
	

	LET vfecha1 = TO_CHAR(pFechaFin, '%d%m%Y');
	LET vfecha2 = SUBSTR(pFechaInicio,4,2);
	    
    -- // GENERA EL ARCHIVO DE LA TABLA sc_encabezado_edocta_factelect
    LET vcSql = '';
    LET vcSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'con_captacion_'||vfecha2||'-'||vfecha1||'.txt'||
                '  SELECT num_cuenta,fechafinal,substr(mensajeproducto,0,4),rfc FROM sc_encabezado_edocta_factelect_old WHERE fechafinal BETWEEN '''|| pFechaInicio ||''' AND '''|| pFechaFin ||'''" > '|| TRIM(vruta_descarga) ||'descarga_con.sql';
    SYSTEM vcSql;
	
    
    LET vcStmt = '';
    
	LET vcStmt = 'dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/descarga_con.sql'; 
    SYSTEM vcStmt;
    
    	
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;