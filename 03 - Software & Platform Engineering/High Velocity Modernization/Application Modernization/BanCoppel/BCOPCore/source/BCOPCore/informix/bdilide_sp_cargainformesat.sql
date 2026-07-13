CREATE PROCEDURE "informix".sp_cargainformesat()
RETURNING CHAR(6), CHAR(60);

    -- DEFINICIONES
    DEFINE cCodRet         		CHAR(6);
    DEFINE cCodRet2        		CHAR(6);
    DEFINE iSql_Err         	INTEGER;
    DEFINE cMensajeRetorno  	CHAR(60);
    DEFINE cFechaHoy       		CHAR(8);
    DEFINE dFechaHoy2      		DATE;
    DEFINE cNombreArchivo  		CHAR(20);
    DEFINE cNombreArchivoCtrl  	CHAR(20);
    DEFINE cSQL            		CHAR(350);
    DEFINE cDirectorio     		CHAR(50);
    DEFINE cCASFIM         		CHAR(20);	
    DEFINE iRegs           		INTEGER;

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        IF cCodRet = '-668' THEN
            LET cCodRet = '002';
            LET cMensajeRetorno ='No se encuentra archivo para cargar';
        END IF;		
        RETURN TRIM(cCodRet),TRIM(cMensajeRetorno);
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- INICIALIZACIONES
    LET cCodRet         	= '000';
    LET cCodRet2        	= '000';
    LET iSql_Err        	= 0;
    LET cMensajeRetorno 	= 'Se cargo correctamente';
    LET cFechaHoy       	= '';
    LET dFechaHoy2       	= '';
    LET cNombreArchivo  	= '';	
    LET cNombreArchivoCtrl	= '';	
    LET cSQL            	= ''; 
    LET cDirectorio     	= '';
    LET cCASFIM      		= '';
    LET iRegs           	= 0;

    -- SET DEBUG FILE TO "/home/sysifx/vlv/sp_cargainformesat.out";
    -- TRACE ON;

    BEGIN

    SELECT fecha_hoy, SUBSTRING (fecha_hoy FROM 7 FOR 4) ||''|| SUBSTRING (fecha_hoy FROM 1 FOR 2)||''|| SUBSTRING (fecha_hoy FROM 4 FOR 2)
      INTO dFechaHoy2,cFechaHoy 
      FROM Bdicheq:"informix".sc_fechas
     WHERE empresa = '001';

    SELECT COUNT(proceso) 
      INTO iRegs  
      FROM Bdilide:"informix".sl_procesos 
     WHERE proceso = 'CargaInforme_Sat'  
       AND fecha_insert = dFechaHoy2;

    IF iRegs = 1 THEN
        LET cCodRet = '004';
        LET cMensajeRetorno = 'Ya se corrio el proceso el dia de hoy';
        RETURN TRIM(cCodRet),TRIM(cMensajeRetorno);
    END IF;

    SELECT TRIM(valor)
      INTO cCASFIM 
      FROM Bdilide:"informix".sl_parametros 
     WHERE cve_param = '04' 
       AND desc_valor = 'CASFIM';	

    -- // Se generan los nombre de los archivos.
    LET cNombreArchivo = 'IF'||TRIM(cCASFIM)||cFechaHoy;  
    LET cNombreArchivoCtrl = 'MT'||TRIM(cCASFIM)||cFechaHoy;          

    DELETE FROM Bdilide:"informix".sl_archivoconsulta;
    DELETE FROM Bdilide:"informix".sl_archivocontrol;

    --Se saca el directorio donde de va cargar el archivo.		
    SELECT TRIM(desc_valor) 
      INTO cDirectorio 	
      FROM Bdilide:"informix".sl_parametros 	
     WHERE cve_param = '23' 
       AND valor = '04';

    --Borra la ultima linea del archivo para poder cargarse ---------------------------------------------------------------------------------------------
    LET cSQL = "sed -e 's/EOF$//g' "||TRIM(cDirectorio)||TRIM(cNombreArchivo)||" > "||TRIM(cDirectorio)||TRIM(cNombreArchivo)||'N';
    SYSTEM cSQL;
    -----------------------------------------------------------------------------------------------------------------------------------------------------

    --Carga el archivo de Respuesta a la tabla temporal.
    LET cSQL = '';
    LET cSQL = 'echo "LOAD FROM '||TRIM(cDirectorio)||TRIM(cNombreArchivo)||'N'||' INSERT INTO Bdilide:"informix".sl_archivoconsulta" > '||TRIM(cDirectorio)||'query.sql';
    SYSTEM cSQL;

    --Se ejecuta el archivo generado anteriormente.
    LET cSQL = '';
    LET cSQL = "dbaccess Bdilide "||TRIM(cDirectorio)||"query.sql ";
    SYSTEM cSQL;

    --Borra el Archivo Generado para carga de registros
    LET cSQL = "rm -rf "||TRIM(cDirectorio)||""|| TRIM(cNombreArchivo)||'N';
    SYSTEM cSQL;  

    IF NOT EXISTS(SELECT rfc FROM Bdilide:"informix".sl_archivoconsulta) THEN
        LET cCodRet = '001';
        LET cMensajeRetorno = 'El archivo de informe no contiene registros.';
        RETURN TRIM(cCodRet),TRIM(cMensajeRetorno);
    END IF;

    --Borra la ultima linea del archivo para poder cargarse ---------------------------------------------------------------------------------------------
    LET cSQL = "sed -e 's/EOF$//g' "||TRIM(cDirectorio)||TRIM(cNombreArchivoCtrl)||" > "||TRIM(cDirectorio)||TRIM(cNombreArchivoCtrl)||'N';
    SYSTEM cSQL;
    -----------------------------------------------------------------------------------------------------------------------------------------------------    

    --Carga el archivo de control a la tabla temporal.
    LET cSQL = '';
    LET cSQL = 'echo "LOAD FROM '||TRIM(cDirectorio)||TRIM(cNombreArchivoCtrl)||'N'||' INSERT INTO Bdilide:"informix".sl_archivocontrol" > '||TRIM(cDirectorio)||'queryCtrl.sql';
    SYSTEM cSQL;

    --Se ejecuta el archivo generado anteriormente.
    LET cSQL = '';
    LET cSQL = "dbaccess Bdilide "||TRIM(cDirectorio)||"queryCtrl.sql ";
    SYSTEM cSQL;

    --Borra el Archivo Generado para carga de registros
    LET cSQL = "rm -rf "||TRIM(cDirectorio)||""|| TRIM(cNombreArchivoCtrl)||'N';
    SYSTEM cSQL;    

    IF NOT EXISTS(SELECT CASFIN FROM Bdilide:"informix".sl_archivocontrol) THEN
        LET cCodRet = '003';
        LET cMensajeRetorno = 'El archivo de Control no contiene registros.';
        RETURN TRIM(cCodRet),TRIM(cMensajeRetorno);
    END IF;

    --Una vez Cargado el archivo se agrega un registro de control de ejecuciones.
    INSERT INTO Bdilide:"informix".sl_procesos(proceso,fech_proceso,status,user_insert,fecha_insert)
    VALUES ('CargaInforme_Sat',dFechaHoy2,'1','informix',dFechaHoy2);

    --Se manda llamar la validacion del archivo cargado
    EXECUTE PROCEDURE Bdilide:"informix".sp_validaarchivoinforme(cNombreArchivo)
    INTO cCodRet2,cMensajeRetorno;

    IF cCodRet2 = '001' THEN
        LET cCodRet = '005';
        LET cMensajeRetorno = 'Archivo no cumple con la validacion';
    ELIF cCodRet2 = '002' THEN
        LET cCodRet = '006';
        LET cMensajeRetorno = 'No se encuentra el RFC en la tabla';
    ELIF cCodRet2::INT < 0 THEN		
        LET cCodRet = '666';
        LET cMensajeRetorno = 'Error no controlado en la Validacion';			
        RETURN TRIM(cCodRet),TRIM(cMensajeRetorno);
    END IF;	

    IF cCodRet::INT >= 0 THEN
        LET cCodRet = '000';
        LET cMensajeRetorno = 'Se cargo correctamente'; 
        RETURN TRIM(cCodRet),TRIM(cMensajeRetorno);
    END IF

    END;
    
END PROCEDURE

