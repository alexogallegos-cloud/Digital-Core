CREATE PROCEDURE "informix".sp_desc_archivos_cfdi(pEmpresa CHAR(3), pFecha DATE)
RETURNING CHAR(5);
    
    
    DEFINE vcodret                  CHAR(5);
	DEFINE vfechafin                DATE;
    DEFINE vsqlerr 					INTEGER;
	DEFINE vfecha1					CHAR(8);
    DEFINE vcSql                    CHAR(600);
	DEFINE vcStmt                   CHAR(250);
	DEFINE vruta_descarga           CHAR(60);
	
	
    LET vcodret   = "00000";
	LET vfechafin = pFecha + 4 UNITS DAY;                                                                                          
	LET vsqlerr   = 0; 
	LET vfecha1   = "";
	LET vcSql     = "";
	LET vcStmt    = "";
	LET vruta_descarga = '';
	  
     --SET DEBUG FILE TO "/tmp/sp_desc_archivos_cfdi.out";
     --TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/tmp/sp_desc_archivos_cfdi.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pEmpresa IS NULL OR pFecha IS NULL THEN
        LET vcodret = '001';
        RETURN vcodret;
    END IF; 
    
	SELECT valor
      INTO vruta_descarga
      FROM sc_param
      WHERE empresa = pEmpresa
		AND codparam = 'RutaDescargaFED';
		   
	
	LET vfecha1 = TO_CHAR(pFecha, '%m%d%Y');
	    
    -- // GENERA EL ARCHIVO DE LA TABLA sc_encabezado_edocta_factelect
    LET vcSql = '';
    LET vcSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_encabezado_edocta_'||vfecha1||'.txt'||
               ' SELECT * FROM sc_encabezado_edocta_factelect WHERE fechafinal = '''|| pFecha ||''' ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'descarga_fed.sql';
    SYSTEM vcSql;
	
    
    LET vcStmt = '';
    LET vcStmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/descarga_fed.sql"; -- Produccion
	--LET vcStmt = 'dbaccess bdicheq /respaldos/resplogifx/conciliachq/edoctacfd/descarga_fed.sql'; -- desarrollo
    SYSTEM vcStmt;
    
    -- // GENERA EL ARCHIVO DE LA TABLA sc_encabezado2_edocta_factelect
    LET vcSql = '';
    LET vcSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_encabezado2_edocta_'||vfecha1||'.txt'||
               ' SELECT * FROM sc_encabezado2_edocta_factelect WHERE fecha_emision BETWEEN '''|| pFecha ||''' AND '''|| vfechafin ||''' AND num_cuenta IN(SELECT num_cuenta FROM sc_encabezado_edocta_factelect WHERE fechafinal = '''|| pFecha ||''') ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'descarga_fed.sql';
    SYSTEM vcSql;
    
    LET vcStmt = '';
    LET vcStmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/descarga_fed.sql"; -- Produccion
	--LET vcStmt = 'dbaccess bdicheq /respaldos/resplogifx/conciliachq/edoctacfd/descarga_fed.sql'; -- desarrollo	
    SYSTEM vcStmt;
    
    -- // GENERA EL ARCHIVO DE LA TABLA sc_detalle_edocta_factelect
    LET vcSql = '';
    LET vcSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_detalle_edocta_'||vfecha1||'.txt'||
               ' SELECT * FROM sc_detalle_edocta_factelect WHERE fecha_emision BETWEEN '''|| pFecha ||''' AND '''|| vfechafin ||''' AND num_cuenta IN(SELECT num_cuenta FROM sc_encabezado_edocta_factelect WHERE fechafinal = '''|| pFecha ||''') ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'descarga_fed.sql';
    SYSTEM vcSql;
    
    LET vcStmt = '';
    LET vcStmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/descarga_fed.sql"; -- Produccion
	--LET vcStmt = 'dbaccess bdicheq /respaldos/resplogifx/conciliachq/edoctacfd/descarga_fed.sql'; -- desarrollo
    SYSTEM vcStmt;
    
    -- // GENERA EL ARCHIVO DE LA TABLA sc_piepagina_edocta_factelect
    LET vcSql = '';
    LET vcSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_piepagina_edocta_'||vfecha1||'.txt'||
               ' SELECT * FROM sc_piepagina_edocta_factelect WHERE fecha_emision BETWEEN '''|| pFecha ||''' AND '''|| vfechafin ||''' AND num_cuenta IN(SELECT num_cuenta FROM sc_encabezado_edocta_factelect WHERE fechafinal = '''|| pFecha ||''') ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'descarga_fed.sql';
    SYSTEM vcSql;
    
    LET vcStmt = '';
    LET vcStmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/descarga_fed.sql"; -- Produccion
	--LET vcStmt = 'dbaccess bdicheq /respaldos/resplogifx/conciliachq/edoctacfd/descarga_fed.sql'; -- desarrollo
    SYSTEM vcStmt;
    
    -- // GENERA EL ARCHIVO DE LA TABLA sc_mensajes_edocta_factelect
    LET vcSql = '';
    LET vcSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_mensajes_edocta_'||vfecha1||'.txt'||
               ' SELECT * FROM sc_mensajes_edocta_factelect WHERE fecha_emision BETWEEN '''|| pFecha ||''' AND '''|| vfechafin ||''' AND num_cuenta IN(SELECT num_cuenta FROM sc_encabezado_edocta_factelect WHERE fechafinal = '''|| pFecha ||''') ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'descarga_fed.sql';
    SYSTEM vcSql;
    
    LET vcStmt = '';
    LET vcStmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/descarga_fed.sql"; -- Produccion
    --LET vcStmt = 'dbaccess bdicheq /respaldos/resplogifx/conciliachq/edoctacfd/descarga_fed.sql'; -- desarrollo
	SYSTEM vcStmt;
    
    -- // GENERA EL ARCHIVO DE LA TABLA sc_grafica_fe
    LET vcSql = '';
    LET vcSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_grafica_edocta_'||vfecha1||'.txt'||
               ' SELECT * FROM sc_grafica_fe WHERE fecha_emision BETWEEN '''|| pFecha ||''' AND '''|| vfechafin ||''' AND num_cuenta IN(SELECT num_cuenta FROM sc_encabezado_edocta_factelect WHERE fechafinal = '''|| pFecha ||''') ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'descarga_fed.sql';
    SYSTEM vcSql;
    
    LET vcStmt = '';
    LET vcStmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/descarga_fed.sql"; -- Produccion
    --LET vcStmt = 'dbaccess bdicheq /respaldos/resplogifx/conciliachq/edoctacfd/descarga_fed.sql'; -- desarrollo
	SYSTEM vcStmt;
    
    -- // GENERA EL ARCHIVO DE LA TABLA sc_aclaraciones_edocta_factelect
    LET vcSql = '';
    LET vcSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_aclaraciones_edocta_'||vfecha1||'.txt'||
               ' SELECT * FROM sc_aclaraciones_edocta_factelect WHERE fecha_emision = '''|| pFecha ||''' ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'descarga_fed.sql';
    SYSTEM vcSql;
    
    LET vcStmt = '';
    LET vcStmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/descarga_fed.sql"; -- Produccion
	--LET vcStmt = 'dbaccess bdicheq /respaldos/resplogifx/conciliachq/edoctacfd/descarga_fed.sql'; -- desarrollo
    SYSTEM vcStmt;
	
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;