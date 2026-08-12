CREATE PROCEDURE "informix".sp_genera_reportebiometriadup()
RETURNING CHAR(6), CHAR(100);

	--DEFINICION DE VARIABLES
	DEFINE cCodret      CHAR(6);
	DEFINE iSqlerr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cErrorInfo   CHAR(100);
	DEFINE cDescripcion CHAR(100);

	
	--DEFINICION DE VARIABLES REPORTE
	DEFINE cSQL             CHAR(2204);
	DEFINE cSQL1            CHAR(100);
	DEFINE cSQL2            CHAR(2004);
    DEFINE cSQL3            CHAR(100);
	DEFINE cRepositorio     CHAR(100);
	DEFINE cQueryTemp        CHAR(50);
	DEFINE cArch            CHAR(50);    
    DEFINE cFechaArchivo    CHAR(8);	
    DEFINE dFechaHoy	    DATE;
	
    --INICIALIZACION DE VARIABLES
	LET cCodret         = '00000';
	LET iSqlerr         = 0;
    LET iIsamErr        = 0;
    LET cErrorInfo    = '';
	LET cDescripcion    = '';

    --INICIALIZACION DE VARIABLES REPORTE
    LET cSQL 		    = '';
    LET cSQL1 		    = '';
    LET cSQL2 		    = '';
	LET cSQL3 		    = '';
    LET cRepositorio   = '';
	LET cQueryTemp	    = 'biometria_duplicada.sql';
	LET cArch		    = '';    
    LET cFechaArchivo   = '';	
    LET dFechaHoy	    = DATE(1);

	--SET DEBUG FILE TO '/home/sysifx/SopPorSuc/sp_genera_reportebiometriadup.out';
	--TRACE ON;
	
	BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
            IF iSqlErr != 0 THEN
                LET cCodret = iSqlErr;
                LET cDescripcion = cErrorInfo;
                RETURN TRIM(cCodret), TRIM(cDescripcion);
            END IF;
        END EXCEPTION;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy INTO dFechaHoy
        FROM bdinteg:"informix".si_fechas
        WHERE empresa = '001';
		
        --Consulta de parametro de ruta del reporte
        SELECT valor INTO cRepositorio
        FROM bdinteg:"informix".si_param 
        WHERE cod_param = '505' AND empresa = '001';
				
        LET cFechaArchivo = TO_CHAR(dFechaHoy,'%d%m%Y');
        LET cArch = 'BiometriaDuplicada' || TRIM(cFechaArchivo) || '.xls';		
        
        --SE DESCARGA LA INFORMACION DE REPORTE DE DEPURACION DEL SISTEMA
        LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRepositorio) ||TRIM(cArch)|| ' DELIMITER ' || ''',''';

        LET cSQL2 = "SELECT 'FECHA', 'CLIENTE', 'NOMBRE', 'PROMOTOR ALTA NUEVA', 'MATCH BIOMETRIA FACIAL', 'NOMBRE', 'PROMOTOR ALTA MATCH' FROM systables WHERE tabid = 1 "
            ||  "UNION ALL SELECT * FROM ( "
            ||      "SELECT TO_CHAR(sit.fchalta,'%d/%m/%Y') AS Fecha, sit.numcte AS Cliente, "            
            ||          "(TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno) || ' ' || TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2)) AS Nombre_completo, "
            ||          "ros.usuario AS Promotor_Alta_Nueva, "
            ||          "numcte_match AS Match_Biometria_Facial, "            
            ||          "(TRIM(cte2.apell_paterno) || ' ' || TRIM(cte2.apell_materno) || ' ' || TRIM(cte2.nombre1) || ' ' || TRIM(cte2.nombre2)) AS Nombre_coincidencia, "
            ||          "ros2.usuario AS Promotor_Alta_Match "
            ||      "FROM bdisitesp:'informix'.se_ctessitespcte AS sit "
	        ||          "INNER JOIN bdinteg:'informix'.si_cliente AS cte ON cte.numcte = sit.numcte "
            ||          "INNER JOIN bdirostros@coppelimg_tcp:'informix'.si_cte_rostro AS ros ON ros.numcte = sit.numcte AND ros.estado = 'A' AND ros.secuencia = 1 "
            ||          "INNER JOIN bdinteg:'informix'.si_rostro_linea AS rl ON rl.numcte = sit.numcte AND rl.match_result = 1 "
            ||          "INNER JOIN bdinteg:'informix'.si_rostro_linea_result AS rls ON rls.ticket = rl.ticket "
            ||          "INNER JOIN bdinteg:'informix'.si_cliente AS cte2 ON cte2.numcte = rls.numcte_match "
            ||          "INNER JOIN bdirostros@coppelimg_tcp:'informix'.si_cte_rostro AS ros2 ON ros2.numcte = rls.numcte_match AND ros2.estado = 'A' AND ros2.secuencia = 1 "
            ||      "WHERE sit.situacion = 'R' AND sit.causa = '2' AND TO_CHAR(sit.fchalta,'%Y-%m-%d') = TRIM('" || TO_CHAR(dFechaHoy,'%Y-%m-%d') || "') "
            ||      "ORDER BY sit.numcte"
            ||  ")";
                    
        LET cSQL3 = ' " > '|| TRIM(cRepositorio) || TRIM(cQueryTemp);
        
        LET cSQL = TRIM(cSQL1) || ' ' ||TRIM(cSQL2) || TRIM(cSQL3);
        
        --Verifica que no este vacia la consulta.
        IF ( cSQL <> '' ) THEN        
            --Elimina los xls de BiometriaDuplicada    
            SYSTEM 'rm -f ' || TRIM(cRepositorio) || 'BiometriaDuplicada*.xls';
            SYSTEM cSQL;
            --Permiso para la creacion de archivo.
            LET cSQL = '' ;
            LET cSQL = 'chmod 666 ' || TRIM(cRepositorio) || TRIM(cQueryTemp) ;
            SYSTEM cSQL ;

            LET cSQL = '' ;
            LET cSQL = 'dbaccess bdisitesp < ' || TRIM(cRepositorio) || TRIM(cQueryTemp) ;
            SYSTEM cSQL ;

            --Borra el archivo de control.
            LET cSQL = '' ;
            LET cSQL = 'rm ' || TRIM(cRepositorio) || TRIM(cQueryTemp);
            SYSTEM cSQL;
        ELSE
            --No fue posible generar el archivo.
            LET cCodret = '00002';
            LET cDescripcion = 'No fue posible generar el archivo';
        END IF ;				
            
        IF TRIM(cCodret) = '00000' THEN 
            LET cDescripcion = 'Registros Procesados Correctamente.'; 
        END IF
        RETURN cCodret, cDescripcion;
	END;
END PROCEDURE
