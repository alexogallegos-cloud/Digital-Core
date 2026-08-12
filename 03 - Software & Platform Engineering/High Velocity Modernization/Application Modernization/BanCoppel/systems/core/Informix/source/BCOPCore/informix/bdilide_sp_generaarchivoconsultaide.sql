CREATE PROCEDURE "informix".sp_generaarchivoconsultaide()
RETURNING CHAR(6), CHAR(60);

    -- DEFINICIONES
    DEFINE cCodRet         		CHAR(6);
    DEFINE iSql_Err         	INTEGER;
    DEFINE iVeces          		INTEGER;
    DEFINE iRegs           		INTEGER;
    DEFINE cNumCte         		CHAR(20);
    DEFINE cRfc            		CHAR(12);
    DEFINE cDirectorio     		CHAR(50);
    DEFINE dFechaHoy       		DATE;
    DEFINE cFechaHoy2      		CHAR(8);
    DEFINE cSQL            		CHAR(250);
    DEFINE cMensajeRetorno  	CHAR(60);
    DEFINE cNombreArchivo  		CHAR(20);
    DEFINE cNombreArchivoCtrl  	CHAR(20);
    DEFINE cUsuario        		CHAR(20);
    DEFINE cCASFIM         		CHAR(20);
    DEFINE iRfc            		INTEGER;
    DEFINE vexiste              INTEGER;

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        RETURN TRIM(cCodRet),'';
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- INICIALIZACIONES
    LET cCodRet        		= '000';
    LET iSql_Err        	= 0;
    LET cNumCte        		= '';
    LET cRfc           		= '';
    LET cSQL           		= '';
    LET cDirectorio    		= '';
    LET cMensajeRetorno		= '';	
    LET cNombreArchivo 		= '';
    LET cNombreArchivoCtrl 	= '';
    LET cUsuario       		= '';
    LET cCASFIM        		= '';
    LET iRfc           		= 0;
    LET iRegs          		= 0;
    LET iVeces         		= 0;
    LET cFechaHoy2     		= '';
    LET dFechaHoy     		= '';
    LET vexiste             = 0;

    --- SET DEBUG FILE TO '/home/sysifx/vlv/sp_generaarchivoconsultaide.out";
    --- TRACE ON;

    BEGIN

    SELECT fecha_hoy 		
      INTO dFechaHoy     	
      FROM Bdicheq:"informix".sc_fechas;  
      
    SELECT COUNT(proceso) 	
      INTO iRegs 			
      FROM Bdilide:"informix".sl_procesos 	
     WHERE proceso = 'archivo_sat' 	
       AND fecha_insert = dFechaHoy;
       
    SELECT TRIM(valor) 		
      INTO iVeces 		
      FROM Bdilide:"informix".sl_parametros 	
     WHERE cve_param = '17' 			
       AND desc_valor = 'NUM_DE_VEC_GEN_CON_EXT';
       
    SELECT TRIM(desc_valor) 
      INTO cDirectorio 	
      FROM Bdilide:"informix".sl_parametros 	
     WHERE cve_param = '23' 			
       AND valor = '04';
       
    SELECT TRIM(valor) 		
      INTO cCASFIM  		
      FROM Bdilide:"informix".sl_parametros 	
     WHERE cve_param = '04' 			
       AND desc_valor = 'CASFIM';	

    IF (dFechaHoy IS NULL OR dFechaHoy = '') OR (iVeces IS NULL OR iVeces = '') OR (cDirectorio IS NULL OR cDirectorio = '') OR (cCASFIM IS NULL OR cCASFIM = '') THEN
        LET cCodRet = '001';
        LET cMensajeRetorno = 'Error en los parametros';
        RETURN TRIM(cCodRet),TRIM(cMensajeRetorno);
    END IF;		

    IF iRegs IS NULL THEN
        LET iRegs = 0;
    END IF 

    DELETE FROM Bdilide:"informix".sl_archivoconsulta;
    DELETE FROM Bdilide:"informix".sl_archivocontrol;

    IF  iRegs >= iVeces THEN
        LET cCodRet = '002';			
        LET cMensajeRetorno = 'Sobrepasa el maximo permitido de veces por Dia.';
        RETURN TRIM(cCodRet),TRIM(cMensajeRetorno);
    END IF;

    SELECT COUNT(*)
      INTO vexiste
      FROM Bdilide:"informix".sl_consat 
     WHERE estado = 'P';

    IF vexiste > 0 THEN
    --- IF EXISTS(SELECT rfc FROM Bdilide:"informix".sl_consat WHERE estado = 'P') THEN

        INSERT INTO Bdilide:"informix".sl_archivoconsulta(RFC,Estado)
        SELECT rfc, '0' 
          FROM Bdilide:"informix".sl_consat 
         WHERE estado = 'P';

        LET cFechaHoy2 = SUBSTRING(dFechaHoy FROM 7 FOR 4) || SUBSTRING(dFechaHoy FROM 1 FOR 2) || SUBSTRING(dFechaHoy FROM 4 FOR 2);

        IF iRegs > 0 THEN
            LET iRegs = iRegs - 1;
        END IF;

        -- // Se Genera el Nombre del Archivo.
        LET cNombreArchivo = 'FC'||iRegs||TRIM(cCASFIM)||cFechaHoy2;          	

        -- // Crea el Archivo de Consulta y le da Contenido al Archivo query.sql						
        LET cNombreArchivo = TRIM(cNombreArchivo);

        LET cSQL = 'echo "UNLOAD TO '||TRIM(cDirectorio)||cNombreArchivo||' '||
        'SELECT RFC, Estado FROM Bdilide:"informix".sl_archivoconsulta; " > '||TRIM(cDirectorio)||'query.sql';
        SYSTEM cSQL;

        LET cSQL = '';
        LET cSQL = "dbaccess Bdilide "||TRIM(cDirectorio)||"query.sql ";
        SYSTEM cSQL;

        -- // Agrega un ultimo renglon de fin de archivo
        LET cSQL = "echo 'EOF' >> "||TRIM(cDirectorio)||TRIM(cNombreArchivo)||"";
        SYSTEM cSQL;

        LET cCodRet = '000';       
        RETURN TRIM(cCodRet),TRIM(cNombreArchivo) WITH RESUME;

        -- Se Genera Archivo De Control.
        LET cNombreArchivoCtrl ='FT'||iRegs||TRIM(cCASFIM)||cFechaHoy2;      

        SELECT COUNT(rfc) 
          INTO iRfc 
          FROM Bdilide:"informix".sl_consat 
         WHERE estado = 'P';

        -- Se cargan los registros en la tabla para despues pasarse al archivo.
        INSERT INTO Bdilide:"informix".sl_archivocontrol(CASFIN,FECHA,Num_Reg)
        VALUES (cCASFIM,cFechaHoy2,iRfc);

        LET cNombreArchivoCtrl = TRIM(cNombreArchivoCtrl);

        LET  cSQL = '';
        LET  cSQL = 'echo "UNLOAD TO '||TRIM(cDirectorio)||cNombreArchivoCtrl||' '||
                    'SELECT CASFIN,FECHA,Num_Reg FROM Bdilide:"informix".sl_archivocontrol; " > '||TRIM(cDirectorio)||'queryCtrl.sql';
        SYSTEM cSQL;

        LET cSQL = '';
        LET cSQL = "dbaccess Bdilide "||TRIM(cDirectorio)||"queryCtrl.sql ";
        SYSTEM cSQL;

        -- // Agrega un ultimo renglon de fin de archivo
        LET cSQL = "echo 'EOF' >> "||TRIM(cDirectorio)||TRIM(cNombreArchivoCtrl)||"";
        SYSTEM cSQL;

        -- // Una vez generado el archivo se agrega un registro.
        INSERT INTO  Bdilide:"informix".sl_procesos(proceso,fech_proceso,status,user_insert,fecha_insert)
        VALUES ('archivo_sat',dFechaHoy,'1','informix',dFechaHoy);

        -- // Una ves generado el archivo se actualiza en la sl_consat.
        UPDATE Bdilide:"informix".sl_consat 
           SET estado = 'E', 
               nombre_arch = cNombreArchivo 
         WHERE estado = 'P';

        -- // Fin del Procedimiento.
        LET cCodRet = '000';
        RETURN TRIM(cCodRet),TRIM(cNombreArchivoCtrl);
    ELSE
        LET cCodRet = '004';			
        LET cMensajeRetorno = 'No existe registro en la Bdilide:sl_consat.';
        RETURN TRIM(cCodRet),TRIM(cMensajeRetorno);
    END IF;

    END;
    
END PROCEDURE
