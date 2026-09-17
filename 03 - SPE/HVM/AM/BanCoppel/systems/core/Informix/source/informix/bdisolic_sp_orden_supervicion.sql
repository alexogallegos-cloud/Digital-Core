CREATE PROCEDURE "informix".sp_orden_supervicion()
	RETURNING  
    CHAR(20)  AS cCodRet,
    CHAR(100) AS cMensajeRet

	-- pFechaIni date,pFechaFin date      --drop procedure sp_Pruebas_Orden_Supervicion;
    ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- 
    -- Declaracion de variables                                     -- Declaracion de variables para la tabla
    DEFINE cCodRet              CHAR(5);                            DEFINE cnumcte 			CHAR(20);
    DEFINE cMensajeRet          CHAR(100);                          DEFINE cnum_solicitud	CHAR(20);
    DEFINE cSql                 CHAR(6000);                         DEFINE ifolio			INTEGER;
    DEFINE cNombre_Archivo      CHAR(35);                           DEFINE df_resp_OS		DATE;
    DEFINE iSqlErr              INTEGER;                            DEFINE csit_esp_OS		CHAR(2);
    DEFINE cErrorInfo           CHAR(80);                           DEFINE scausa_OS		SMALLINT;
	DEFINE pFechaIni			DATE;								DEFINE pFechaFin		DATE;
    ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- 
    -- Asignar valor a las variables                                -- Asignar valor a las variables de la tabla
    LET cCodRet             = '000';                                LET cnumcte 		= '';
	LET iSqlErr             = 0;                                    LET cnum_solicitud	= '';
    LET cMensajeRet         = "PROCESO EXITOSO";                    LET ifolio			= 0;
    LET cErrorInfo         	= "";                                   LET df_resp_OS		= DATE(1);
    LET cSql                = "";                                   LET csit_esp_OS		= '';
	LET scausa_OS			= '';									LET pFechaIni		= DATE(1);
	LET pFechaFin			= DATE(1);
    ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- 
     -- Creo un archivo en caso que ocurra unu error en el sp
       -- SET DEBUG FILE TO "/informix/Janeth_Peinado/Respaldo/Detalle_error_OS.out";
       -- TRACE ON;
    ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- 
BEGIN
        ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
			-- Detecta si hay algun problema en la consulta
			ON EXCEPTION SET iSqlErr
				IF iSqlErr !=0 THEN
					 LET cCodRet = iSqlErr;
					 LET cMensajeRet = cnum_solicitud; -- cErrorInfo;
						truncate table bdisolic:tmp_orden_supervicion;
					RETURN cCodRet,cMensajeRet; 						 
				END IF;
			END EXCEPTION;		
		----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;			
		----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
			truncate table "informix".tmp_orden_supervicion;
		----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
			select fecha_hoy into pFechaFin from bdicred:"informix".sd_fechas where empresa = '001';
			LET pFechaIni = pFechaFin -7;
		----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
         -- VALIDA LOS PARAMETROS DE ENTRADA
            IF  NVL(pFechaIni,"") =  ""  OR  NVL(pFechaFin,"") =  "" THEN
                LET cCodRet = '000001';
                LET cMensajeRet = 'Parametros de entrada incompletos,verifique';
            ELSE                
                ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----				
                -- es para saber si hay secuencia o index en la consulta.
                FOREACH	
				
					select sol.numcte,sol.num_solicitud,folio,fecharespuesta,situacionespecial,causasituacionespecial
					INTO cnumcte,cnum_solicitud,ifolio,df_resp_OS,csit_esp_OS,scausa_OS
					from bdisolic:"informix".ss_osclientesupervisar oscli
					INNER JOIN bdisolic:"informix".ss_solicitudes sol ON (oscli.empresa =sol.empresa AND 
					oscli.num_solicitud = sol.num_solicitud)	
					where oscli.empresa ='001' and oscli.num_solicitud = sol.num_solicitud					
					and fecharespuesta between pFechaIni and pFechaFin
					----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----                    
						-- ASignamos el valor a una tabla fisica para despues ser elimINada
						INSERT INTO bdisolic:tmp_orden_supervicion(numcte,num_solicitud,folio,f_resp_OS,sit_esp_OS,causa_OS)
						values(cnumcte,cnum_solicitud,ifolio,df_resp_OS,csit_esp_OS,scausa_OS);
					----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
				END foreach;
                ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
                -- ASignar el nombre del archivo que debe de cargar.
                 -- RespOS_130101_130107.txt (Nombre del archivo)
                 LET cNombre_Archivo ='RespOS_'||SUBSTRING(pFechaIni FROM 9 FOR 2)||SUBSTRING(pFechaIni FROM 1 FOR 2)||SUBSTRING(pFechaIni FROM 4 FOR 2)||'_'||
                    SUBSTRING(pFechaFin FROM 9 FOR 2)||SUBSTRING(pFechaFin FROM 1 FOR 2)||SUBSTRING(pFechaFin FROM 4 FOR 2)||'.txt';
								
				-- // DESCARGA ARCHIVO  \\10.26.211.78\sisperproc\Alta Unica\semanal
				LET cSql = '';				
				-- Asignamos los nombres de los campos que llevara el archivo el cual se le asigna la carpeta en donde ira
				--- junto con el nombre del archivo original que sera el final.
				let cSql = ' echo "numcte|num_solicitud|folio|f_resp_OS|sit_esp_OS|causa_OS ">/resplogifx/archivoscartera/' || trim(cNombre_Archivo);
				system cSql;
				let cSql = '';
				-- se le asigna el resultado a un archivo extra que sera agregado al archivo final el archivo es orden_supervicion1
				--- el cual se le asigna el resultado final de la consulta.
				let cSql= 	'echo "SET ISOLATION TO DIRTY READ;'||' '||
							'set lock mode to wait 4;'||' '||
							'UNLOAD TO /resplogifx/archivoscartera/orden_supervicion1.unl '||' '||
							'SELECT numcte,num_solicitud,folio,f_resp_OS,sit_esp_OS,causa_OS '||' '||
							'FROM bdisolic:tmp_orden_supervicion order by numcte; " > /resplogifx/archivoscartera/orden_supervicion.sql';
				system cSql;
				LET cSql = '';
				-- Asignamos el unload a un archivo .sql para ser cargado.
				LET cSql = "dbaccess bdisolic /resplogifx/archivoscartera/orden_supervicion.sql"; 
				SYSTEM cSql;
				LET cSql = '';
				-- borramos el archivo de la carpeta.
				let cSql ='rm /resplogifx/archivoscartera/orden_supervicion.sql';
				system cSql;
				LET cSql = '';
				-- Le asignamos el valor al archivo final.
				let cSql = "sed 's/|$//g' /resplogifx/archivoscartera/orden_supervicion1.unl >>/resplogifx/archivoscartera/" || trim(cNombre_Archivo);
				system cSql;
				-- Borramos el archivo que se genero para cargar la informacion del select.
				let cSql ='rm  /resplogifx/archivoscartera/orden_supervicion1.unl';
				system cSql;
				
            END IF;
        ----- ----- ----- -----			
			RETURN cCodRet,cMensajeRet;
               
END;
END PROCEDURE;