CREATE PROCEDURE "informix".sp_depura_bitacora_token_digitalcard()
    RETURNING CHAR(5) AS Cod_Retorno;

DEFINE nombreArchivo        		VARCHAR(50);
DEFINE primerDiaMes              	CHAR(2);
DEFINE mes                      	CHAR(2);
DEFINE anio                       	CHAR(4);
DEFINE horaInicio          	        CHAR(11);
DEFINE fechaInicioMes      	        VARCHAR(25);
DEFINE fechaInicioMesDelete      	VARCHAR(25);
DEFINE iSql_err				        INT;
DEFINE codigo_retorno				CHAR(5);
DEFINE conteo                       INT;
DEFINE filePath                     CHAR(1000);
DEFINE query        	    		CHAR(1500);
DEFINE executeQuery        	        CHAR(5000);
    
LET nombreArchivo                    = '';
LET primerDiaMes                     = '';
LET mes                              = '';
LET anio                             = '';
LET horaInicio 				         = ' 00:00:00.0';
LET fechaInicioMes 			         = '';
LET fechaInicioMesDelete 			 = '';
LET iSql_err				         = 0;
LET codigo_retorno					 = '00000';
LET conteo                           = 0;
LET query           	    	     = '';
LET executeQuery        	         = '';
LET filePath                         = '';


    BEGIN
    
    	ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET codigo_retorno = iSql_err;
				RETURN codigo_retorno;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/c90313380/sp_depura_bitacora_token_digitalcard.out";
        --TRACE ON;
		
        --Consulta el primer dia del mes 
        LET primerDiaMes = "01";         
		
        
        SELECT MONTH(TODAY)
            INTO mes 
        FROM systables   
            WHERE tabid=1;
                
        IF mes < 10 THEN
            LET mes = 0 || mes;
        END IF

        SELECT YEAR(TODAY)  
            INTO anio 
        FROM systables 
            WHERE tabid=1;
	
		
        ----Fecha y hora inicio mes anterior---- 
        LET fechaInicioMes = trim(anio ||'-'|| mes || '-' || primerDiaMes || horaInicio);
        LET fechaInicioMesDelete = fechaInicioMes;
        
        SELECT COUNT(*)
           INTO conteo
        FROM bitacora_token_digitalcard
            WHERE fecha_insert < fechaInicioMes;
            
        IF conteo = 0 THEN
            LET codigo_retorno = "00002";
        ELSE
            LET nombreArchivo ='Respaldo_bitacora_token_digitalcard_' || anio|| mes || primerDiaMes ;
            LET filePath='"/RESPALDOSNEW/Tokenizacion/file_temp/'|| nombreArchivo ||'.unl" ';

            LET query = 'SELECT * FROM bitacora_token_digitalcard WHERE fecha_insert < '||'"'|| fechaInicioMes ||'"';           
            LET executeQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(filePath)||"  "||(query)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
            SYSTEM TRIM(executeQuery);
            
           DELETE FROM bitacora_token_digitalcard
             WHERE fecha_insert < fechaInicioMesDelete;

        END IF
        RETURN codigo_retorno;	
    END;

END PROCEDURE;