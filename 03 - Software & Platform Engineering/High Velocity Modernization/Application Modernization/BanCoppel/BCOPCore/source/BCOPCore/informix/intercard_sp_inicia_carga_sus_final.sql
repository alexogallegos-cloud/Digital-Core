CREATE PROCEDURE "informix".sp_inicia_carga_sus_final()
RETURNING CHAR(5) AS Cod_Retorno;

-- ****************************************************************************
-- Definicion de variables
-- ****************************************************************************
DEFINE v_fecha    	                DATE;
DEFINE vNumtarjeta          		VARCHAR(19);
DEFINE vNumcliente					VARCHAR(13);
DEFINE v2Numtarjeta					VARCHAR(19);
DEFINE vFechaexp          			VARCHAR(4);
DEFINE v2Fechaexp					VARCHAR(4);
DEFINE vIniciaTransaccion   		CHAR(1);
DEFINE vConteoRegistros 			INTEGER;
DEFINE vCommit  					VARCHAR(50);
DEFINE vNumtarjetasustituta			VARCHAR(19);
DEFINE v2Numtarjetasustituta		VARCHAR(19);
DEFINE vFechaexpsustita   			VARCHAR(4);
DEFINE identificadorabu				CHAR(1);
DEFINE sDiaP              			CHAR(2);
DEFINE sMesP              			CHAR(2);
DEFINE sAnoP              			CHAR(4);
DEFINE vCodstatustarjeta			VARCHAR(3);
DEFINE v2Codstatustarjeta			VARCHAR(3);
DEFINE vIca			  				VARCHAR(11);
DEFINE vFechaasignacion				DATETIME YEAR TO FRACTION(5);
DEFINE v2fechaasignacion			DATETIME YEAR TO FRACTION(5);
DEFINE vFechaultmodif				DATETIME YEAR TO FRACTION(5);
DEFINE v2fechaultmodif				DATETIME YEAR TO FRACTION(5);
DEFINE nombreArchivo        		VARCHAR(50);
DEFINE identiFica					VARCHAR(1);
DEFINE vCodproductotarjeta			VARCHAR(3);
DEFINE v2Codproductotarjeta			VARCHAR(3);
DEFINE pArchDeclarga1	    		CHAR(1000);
DEFINE cCmd1        	    		CHAR(1500);
DEFINE cQuery1        	    		CHAR(3000);
DEFINE vsRelleno3					VARCHAR(3);
DEFINE vsRelleno4					VARCHAR(4);
DEFINE vsRelleno19					VARCHAR(19);
DEFINE vsRelleno16					VARCHAR(16);
DEFINE vsRelleno11			   		VARCHAR(11);
DEFINE vConteo						INTEGER;
DEFINE vMarca						VARCHAR(2);
DEFINE v2Marca	 					VARCHAR(2);
DEFINE FECHNUEXP					VARCHAR(4);
DEFINE MMEXP						VARCHAR(4);
DEFINE YYEXP						VARCHAR(4);
DEFINE FECHNUEXP2					VARCHAR(4);
DEFINE MMEXP2						VARCHAR(4);
DEFINE YYEXP2						VARCHAR(4);
DEFINE bin1							VARCHAR(8);
DEFINE bin2							VARCHAR(8);
DEFINE iSql_err				        INT;
DEFINE cCodRet				        CHAR(5);






-- ****************************************************************************
-- Inicializa de variables
-- ****************************************************************************

LET v_fecha 		            = '';
LET v2Codstatustarjeta			= '';
LET v2Numtarjeta				= '';
LET vMarca                      = '';
LET v2Marca					    = '';
LET vNumcliente                 = '';
LET vsRelleno3                  = '';
LET vsRelleno4                  = '';
LET vsRelleno19                 = '';
LET vsRelleno16                 = '';
LET vsRelleno11                 = '';
LET vCodproductotarjeta         = '';
LET v2Codproductotarjeta        = '';
LET vNumtarjeta 				= ''; 
LET vFechaexp 					= '';  
LET v2Fechaexp					= '';
LET vIniciaTransaccion 			= '';
LET vConteoRegistros 			= 0;
LET vConteo       				= 0;
LET vNumtarjetasustituta 		= '';
LET v2Numtarjetasustituta		= '';
LET vFechaexpsustita 			= ''; 
LET identificadorabu 			= 'C';
LET sDiaP           			= '';
LET sMesP          				= '';
LET sAnoP          				= '';
LET vCodstatustarjeta			= '';
LET vIca						= '13798';
LET vFechaasignacion			= '';
LET v2fechaasignacion			= '';
LET vFechaultmodif				= '';
LET v2fechaultmodif				= '';
LET nombreArchivo        	    = '';
LET identiFica					= 'D';
LET pArchDeclarga1          	= '';
LET cCmd1           	    	= '';
LET cQuery1        	        	= '';
LET FECHNUEXP					= '';
LET MMEXP						= '';
LET YYEXP						= '';
LET FECHNUEXP2					= '';
LET MMEXP2						= '';
LET YYEXP2						= '';
LET bin1						= '';
LET bin2						= '';
LET vMarca						= '';
LET iSql_err				    = 0;
LET cCodRet					    = '00000';


	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
			
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
	
        --SET DEBUG FILE TO "/home/c90304940/mroman/prueba.out";
       -- TRACE ON;
	
		--Borra el contenido de la tabla
	    TRUNCATE TABLE "informix".tbl_info_tarjetas_abu;
	    
	    
	    	 --Inicializan variables
		LET vConteoRegistros = 0;
		LET vIniciaTransaccion = 'F';

	    
        FOREACH tarjetas WITH HOLD FOR 
                 -- Obtiene tarjetas del dia
                 SELECT numtarjeta, codstatustarjeta, codproductotarjeta,numcliente, fechaexp, numtarjetasustituta, fechaasignacion, fechaultmodif
                    INTO vNumtarjeta, vCodstatustarjeta, vCodproductotarjeta,vNumcliente, vFechaexp, vNumtarjetasustituta, vFechaasignacion, vFechaultmodif
                 FROM intercard:"informix".tarjeta 
                    WHERE fechaultmodif >= TO_DATE('"'||YEAR(TODAY -1)||'-'||CASE WHEN MONTH(TODAY -1)< 10 THEN 0 || MONTH(TODAY -1) ELSE TO_CHAR(MONTH(TODAY -1)) END||'-'||CASE WHEN DAY(TODAY -1)< 10 THEN 0 || DAY(TODAY -1) ELSE TO_CHAR(DAY(TODAY -1)) END||' 00:00:00"','"%Y-%m-%d %H:%M:%S"')
				      AND fechaultmodif <= TO_DATE('"'||YEAR(TODAY -1)||'-'||CASE WHEN MONTH(TODAY -1)< 10 THEN 0 || MONTH(TODAY -1) ELSE TO_CHAR(MONTH(TODAY -1)) END||'-'||CASE WHEN DAY(TODAY -1)< 10 THEN 0 || DAY(TODAY -1) ELSE TO_CHAR(DAY(TODAY -1)) END||' 23:59:59"','"%Y-%m-%d %H:%M:%S"')
				 
				 
				 -- Obtiene marca   
                 SELECT marca 
                    INTO vMarca
                 FROM bines 
                    WHERE bin = SUBSTRING(vNumtarjeta FROM 1 FOR 6);
                  
                IF (vIniciaTransaccion = 'F') THEN 
                    SET ISOLATION TO dirty READ;
                    BEGIN WORK;
                    LET vIniciaTransaccion = 'V';
                END IF;					
    
                INSERT INTO "informix".tbl_info_tarjetas_abu (numtarjeta, codstatustarjeta, codproductotarjeta, numcliente, fechaexp, numtarjetasustituta, fechaasignacion, fechaultmodif, marca)
                    VALUES(vNumtarjeta, vCodstatustarjeta, vCodproductotarjeta, vNumcliente, vFechaexp, vNumtarjetasustituta, vFechaasignacion, vFechaultmodif, vMarca);
                    
                LET vConteoRegistros = vConteoRegistros + 1;

                IF (vConteoRegistros > 0) THEN
                    SET ISOLATION TO dirty READ;
                    COMMIT WORK;
                    LET vConteoRegistros = 0;
                    LET vIniciaTransaccion = 'F';
                    CONTINUE FOREACH;
                END IF

        END FOREACH
        --Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
            
        IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
           SET ISOLATION TO dirty READ;
           COMMIT WORK;
        END IF
                
        SELECT COUNT(*) 
            INTO vConteo
        FROM tbl_info_tarjetas_abu;
                
        IF (vConteo = 0) THEN
            LET cCodRet = '00002';
            RETURN cCodRet;
        END IF;
                
        LET vConteo = 0;
                
        --Inicializan variables
        LET vConteoRegistros = 0;
        LET vIniciaTransaccion = 'F';
 
    --*****************************************************************************************************************************************--

        LET vsRelleno3 = LPAD(NVL(vsRelleno4,' '), 3,' ');
        LET vsRelleno19 = LPAD(NVL(vsRelleno19,' '), 19,' ');
        LET vsRelleno11 = LPAD(NVL(vsRelleno11,' '), 11,' ');
        LET vsRelleno4 = LPAD(NVL(vsRelleno11,' '), 4,' ');
        LET vsRelleno16 = LPAD(NVL(vsRelleno19,' '), 16,' ');
            
        TRUNCATE TABLE "informix".tbl_abu_tar_activas;
            
    
        -- 1.-  TARJETAS ACTIVAS
            
        FOREACH tarjetas WITH HOLD FOR

            SELECT numtarjeta, codstatustarjeta, fechaexp, numtarjetasustituta, fechaasignacion, fechaultmodif, codproductotarjeta, marca		
                INTO vNumtarjeta, vCodstatustarjeta, vFechaexp, vNumtarjetasustituta, vFechaasignacion, vFechaultmodif, vCodproductotarjeta, vMarca   
            FROM intercard:"informix".tbl_info_tarjetas_abu 
                WHERE codstatustarjeta IN ('ACT', 'BLO', 'BLT') 

            IF (vIniciaTransaccion = 'F') THEN 
                SET ISOLATION TO dirty READ;
                BEGIN WORK;
                LET vIniciaTransaccion = 'V';
            END IF;					

            INSERT INTO "informix".tbl_abu_tar_activas (identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, numtarjetasustituta,relleno3_2, fechaexpsustituta, identificadorabu, codstatustarjeta, fechaasignacion, fechaultmodif, relleno11, codproductotarjeta,marca)
            VALUES("D", LPAD(vIca,11,'0'), vNumtarjeta, vsRelleno3, vFechaexp, vsRelleno16, vNumtarjetasustituta, vsRelleno3, NVL(vFechaexpsustita,'0000'), "I", vCodstatustarjeta, vFechaasignacion, vFechaultmodif, vsRelleno11, vCodproductotarjeta, vMarca);
                
            LET vConteoRegistros = vConteoRegistros + 1;
              
            IF (vConteoRegistros > 0) THEN
            
                SET ISOLATION TO dirty READ;
                COMMIT WORK;
                LET vConteoRegistros = 0;
                LET vIniciaTransaccion = 'F';
                CONTINUE FOREACH;
            END IF
                
        END FOREACH
                
        --Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
        IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
            SET ISOLATION TO dirty READ;
            COMMIT WORK;
        END IF
                
                
        --Inicializan variables
        LET vConteoRegistros = 0;
        LET vIniciaTransaccion = 'F';
                
                
    --********************************************************************************************************************--

        TRUNCATE TABLE "informix".tbl_abu_tar_bitacora;
        
        TRUNCATE TABLE "informix".tbl_abu_add;
            
            
            
        -- 2.- Tarjetas con estatus final y que no tienen tarjeta sustituta CUENTA CERRADA*
            
        LET vsRelleno3 = LPAD(NVL(vsRelleno4,' '), 3,' ');
        LET vsRelleno19 = LPAD(NVL(vsRelleno19,' '), 19,' ');
        LET vsRelleno11 = LPAD(NVL(vsRelleno11,' '), 11,' ');
        
        LET vsRelleno4 = LPAD(NVL(vsRelleno11,' '), 4,' ');
        LET vsRelleno16 = LPAD(NVL(vsRelleno19,' '), 16,' ');
            
            
            
        FOREACH tarjetas WITH HOLD FOR
                
            SELECT  numtarjeta, fechaexp, codstatustarjeta, fechaasignacion, fechaultmodif, marca
                INTO vNumtarjeta, vFechaexp, vCodstatustarjeta, vFechaasignacion, vFechaultmodif, vMarca
            FROM "informix".tbl_info_tarjetas_abu 
                WHERE codstatustarjeta IN ('CAN','ROB','DES','EXT','FAL','DAN') 
                    AND numtarjetasustituta IS NULL
                
                
            LET MMEXP= SUBSTRING(vFechaexp FROM 3 FOR 4);
            LET YYEXP= SUBSTRING(vFechaexp FROM 1 FOR 2);   
            LET FECHNUEXP = MMEXP||YYEXP;

            IF (vIniciaTransaccion = 'F') THEN 
                SET ISOLATION TO dirty READ;
                BEGIN WORK;
                LET vIniciaTransaccion = 'V';
            END IF;
 
            INSERT INTO "informix".tbl_abu_tar_bitacora (identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, codstatustarjeta, fechaasignacion,relleno11, fechaultmodif, marca)
            VALUES("D", LPAD(vIca,11,'0'), vNumtarjeta, vsRelleno3, FECHNUEXP, vsRelleno16, vsRelleno3, '0000','C', vCodstatustarjeta,vFechaasignacion,vsRelleno11, vFechaultmodif, vMarca);
                        
            LET vConteoRegistros = vConteoRegistros + 1;
                
            IF (vConteoRegistros > 0) THEN
                SET ISOLATION TO dirty READ;
                COMMIT WORK;
                LET vConteoRegistros = 0;
                LET vIniciaTransaccion = 'F';
                CONTINUE FOREACH;
            END IF
                
        END FOREACH
                
        --Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
        IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
            SET ISOLATION TO dirty READ;
            COMMIT WORK;
        END IF
        
        --inserta un registro para la cabecera inicial.
            
        INSERT INTO "informix".tbl_abu_add (identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16,relleno3_2, fechaexpsustituta, identificadorabu, codstatustarjeta, fechaasignacion,relleno11)  
        VALUES("H", LPAD(vIca,11,'0'), vsRelleno16, vsRelleno3, vsRelleno4, vsRelleno16, vsRelleno3, vsRelleno4, "C", NULL, NULL, vsRelleno11);

        SELECT COUNT(*) conteo_total
            INTO vConteo
        FROM tbl_abu_tar_bitacora 
            WHERE marca = 'VS';
		
		
            
        IF(vConteo > 0) THEN
            --NOMBRE ARCHIVO
            LET nombreArchivo = '';
            LET nombreArchivo ='R274_5CERRADA_VISA_';
            --genera archivo
            LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
            LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                        'UNION ALL SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "VS";';
            LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
            SYSTEM TRIM(cQuery1);
        END IF;
        
        
        SELECT COUNT(*) conteo_total
            INTO vConteo
        FROM tbl_abu_tar_bitacora 
            WHERE marca = 'MC';

        IF(vConteo > 0) THEN

        --NOMBRE ARCHIVO
            LET nombreArchivo = '';
            LET nombreArchivo ='R274_5CERRADA_MASTER_';
            --genera archivo
            LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
            LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                        'UNION ALL SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "MC";';
            LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
            SYSTEM TRIM(cQuery1);

         END IF;
        
            
            --Inicializan variables
        LET vConteoRegistros = 0;
        LET vIniciaTransaccion = 'F';

        TRUNCATE TABLE "informix".tbl_abu_tar_bitacora;
        
        TRUNCATE TABLE "informix".tbl_abu_add;
            
            
    -- 3.- NUEVA CUENTA
            
            
        LET vsRelleno3 = LPAD(NVL(vsRelleno4,' '), 3,' ');
        LET vsRelleno19 = LPAD(NVL(vsRelleno19,' '), 19,' ');
        LET vsRelleno11 = LPAD(NVL(vsRelleno11,' '), 11,' ');
        
        LET vsRelleno4 = LPAD(NVL(vsRelleno11,' '), 4,' ');
        LET vsRelleno16 = LPAD(NVL(vsRelleno19,' '), 16,' ');
        
        FOREACH tarjetas WITH HOLD FOR

            SELECT numtarjeta, codstatustarjeta, fechaexp, numtarjetasustituta, fechaasignacion, fechaultmodif, marca
                INTO vNumtarjeta, vCodstatustarjeta, vFechaexp, vNumtarjetasustituta, vFechaasignacion, vFechaultmodif, vMarca
            FROM tbl_abu_tar_activas 
                WHERE  codstatustarjeta IN ('ACT', 'BLO', 'BLT')
                    AND numtarjeta NOT IN 
                        (SELECT numtarjetasustituta FROM tbl_info_tarjetas_abu WHERE numtarjetasustituta IS NOT NULL)  
                    AND fechaasignacion >= TO_DATE('"'||YEAR(TODAY -1)||'-'||CASE WHEN MONTH(TODAY -1)< 10 THEN 0 || MONTH(TODAY -1) ELSE TO_CHAR(MONTH(TODAY -1)) END||'-'||CASE WHEN DAY(TODAY -1)< 10 THEN 0 || DAY(TODAY -1) ELSE TO_CHAR(DAY(TODAY -1)) END||' 00:00:00"','"%Y-%m-%d %H:%M:%S"')
				    AND fechaasignacion <= TO_DATE('"'||YEAR(TODAY -1)||'-'||CASE WHEN MONTH(TODAY -1)< 10 THEN 0 || MONTH(TODAY -1) ELSE TO_CHAR(MONTH(TODAY -1)) END||'-'||CASE WHEN DAY(TODAY -1)< 10 THEN 0 || DAY(TODAY -1) ELSE TO_CHAR(DAY(TODAY -1)) END||' 23:59:59"','"%Y-%m-%d %H:%M:%S"')
				 
        
            LET MMEXP= SUBSTRING(vFechaexp FROM 3 FOR 4);                 
            LET YYEXP= SUBSTRING(vFechaexp FROM 1 FOR 2);
            LET FECHNUEXP = MMEXP||YYEXP;
            

            IF (vIniciaTransaccion = 'F') THEN 
                SET ISOLATION TO dirty READ;
                BEGIN WORK;
                LET vIniciaTransaccion = 'V';
            END IF;
          
            INSERT INTO "informix".tbl_abu_tar_bitacora (identificador, numIca, relleno16, relleno3, fechaexp, numtarjetasustituta,relleno3_2, fechaexpsustituta, identificadorabu,codstatustarjeta, fechaasignacion, relleno11, fechaultmodif, marca)
                VALUES("D", LPAD(vIca,11,'0'), vsRelleno16, vsRelleno3, '0000', vNumtarjeta, vsRelleno3, FECHNUEXP, 'N', vCodstatustarjeta, vFechaasignacion, vsRelleno11, vFechaultmodif, vMarca);
 
                
            LET vConteoRegistros = vConteoRegistros + 1;
            
            IF (vConteoRegistros >= 0) THEN
            
                SET ISOLATION TO dirty READ;
            
                COMMIT WORK;
                LET vConteoRegistros = 0;
                LET vIniciaTransaccion = 'F';
                 CONTINUE FOREACH;
            END IF
            
            
        END FOREACH
        
            
        --Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
        IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V') THEN
            SET ISOLATION TO dirty READ;
            COMMIT WORK;
        END IF
            
            
        --inserta un registro para la cabecera inicial.
        
        INSERT INTO "informix".tbl_abu_add (identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16,relleno3_2, fechaexpsustituta, identificadorabu, codstatustarjeta, fechaasignacion,relleno11)
            
        VALUES("H", LPAD(vIca,11,'0'), vsRelleno16, vsRelleno3, vsRelleno4, vsRelleno16, vsRelleno3, vsRelleno4, "N", NULL, NULL, vsRelleno11);
        
         SELECT COUNT(*) conteo_total
            INTO vConteo
         FROM tbl_abu_tar_bitacora 
            WHERE marca = 'VS';
            
        IF(vConteo > 0) THEN
        --NOMBRE ARCHIVO

            LET nombreArchivo = '';
            LET nombreArchivo ='R274_1NUEVA_VISA_';
            --genera archivo
            LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
            LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                        'UNION ALL SELECT identificador, numIca, relleno16, relleno3, fechaexp, numtarjetasustituta, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "VS";';
            LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
            SYSTEM TRIM(cQuery1);
      
        END IF;
            
        SELECT COUNT(*) conteo_total
            INTO vConteo
        FROM tbl_abu_tar_bitacora 
            WHERE marca = 'MC';
            
            
            
        IF(vConteo > 0) THEN
            --NOMBRE ARCHIVO
            LET nombreArchivo = '';
            LET nombreArchivo ='R274_1NUEVA_MASTER_';
            --genera archivo
            LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
            LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                        'UNION ALL SELECT identificador, numIca, relleno16, relleno3, fechaexp, numtarjetasustituta, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "MC";';
            LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
            SYSTEM TRIM(cQuery1);
                
        END IF;
        --Inicializan variables
        LET vConteoRegistros = 0;
        LET vIniciaTransaccion = 'F';

        TRUNCATE TABLE "informix".tbl_abu_tar_bitacora;
        
        TRUNCATE TABLE "informix".tbl_abu_add;
        
        LET vIniciaTransaccion = 'F';
        
        LET vsRelleno3 = LPAD(NVL(vsRelleno4,' '), 3,' ');
        LET vsRelleno19 = LPAD(NVL(vsRelleno19,' '), 19,' ');
        LET vsRelleno11 = LPAD(NVL(vsRelleno11,' '), 11,' ');
        
        LET vsRelleno4 = LPAD(NVL(vsRelleno11,' '), 4,' ');
        LET vsRelleno16 = LPAD(NVL(vsRelleno19,' '), 16,' ');
            
            
            
    -- 4.- TARJETA DE REEMPLAZO
            
            
        FOREACH tarjetas WITH HOLD FOR
            SELECT abu.numtarjeta, abu.codstatustarjeta, abu.codproductotarjeta, abu.fechaexp, abu.numtarjetasustituta, abu.fechaasignacion, abu.fechaultmodif, abu.marca, act.numtarjeta , act.codstatustarjeta, act.fechaexp,  act.numtarjetasustituta, act.fechaasignacion, act.fechaultmodif, act.codproductotarjeta,act.marca	
                INTO vNumtarjeta, vCodstatustarjeta, vCodproductotarjeta, vFechaexp,vNumtarjetasustituta,vFechaasignacion,vFechaultmodif, vMarca, v2Numtarjeta, v2Codstatustarjeta, v2Fechaexp,v2Numtarjetasustituta, v2fechaasignacion, v2fechaultmodif, v2Codproductotarjeta, v2Marca	
            FROM tbl_info_tarjetas_abu abu
                INNER JOIN  tbl_info_tarjetas_abu act ON act.numtarjeta = abu.numtarjetasustituta
                    WHERE abu.codproductotarjeta=act.codproductotarjeta
                        AND abu.marca = act.marca
                        
            LET MMEXP= SUBSTRING(vFechaexp FROM 3 FOR 4);
            LET YYEXP= SUBSTRING(vFechaexp FROM 1 FOR 2);
            LET FECHNUEXP = MMEXP||YYEXP;
            LET MMEXP2= SUBSTRING(v2Fechaexp FROM 3 FOR 4);
            LET YYEXP2= SUBSTRING(v2Fechaexp FROM 1 FOR 2);
            LET FECHNUEXP2 = MMEXP2||YYEXP2;
            
            IF (vIniciaTransaccion = 'F') THEN                
                SET ISOLATION TO dirty READ;
                BEGIN WORK;
                LET vIniciaTransaccion = 'V';
            END IF;
                    
        
            INSERT INTO "informix".tbl_abu_tar_bitacora (identificador, numIca, numtarjeta, relleno3, fechaexp, numtarjetasustituta, relleno3_2, fechaexpsustituta, identificadorabu,codstatustarjeta, fechaasignacion,relleno11, marca)
            VALUES("D", LPAD(vIca,11,'0'), vNumtarjeta, vsRelleno3, FECHNUEXP, vNumtarjetasustituta, vsRelleno3,  NVL(FECHNUEXP2,'0000'),'R',vCodstatustarjeta, vFechaasignacion, vsRelleno11, vMarca);

            LET vConteoRegistros = vConteoRegistros + 1;
            
            IF (vConteoRegistros >= 0) THEN
                SET ISOLATION TO dirty READ;
                COMMIT WORK;
                LET vConteoRegistros = 0;
                LET vIniciaTransaccion = 'F';
                CONTINUE FOREACH;
            END IF
                
                
        END FOREACH
        
        --Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
        IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
        
            SET ISOLATION TO dirty READ;
            COMMIT WORK;
        END IF
        --inserta un registro para la cabecera inicial.
            
        INSERT INTO "informix".tbl_abu_add (identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16,relleno3_2, fechaexpsustituta, identificadorabu, codstatustarjeta, fechaasignacion,relleno11)
        VALUES("H", LPAD(vIca,11,'0'), vsRelleno16, vsRelleno3, vsRelleno4, vsRelleno16, vsRelleno3, vsRelleno4, "R", NULL, NULL, vsRelleno11);
                
        SELECT COUNT(*) conteo_total
            INTO vConteo
        FROM tbl_abu_tar_bitacora 
            WHERE marca = 'VS';
        
        IF(vConteo > 0) THEN
        
        --NOMBRE ARCHIVO

            LET nombreArchivo = '';
            LET nombreArchivo ='R274_2REEMPLAZO_VISA_';
            
    
            --genera archivo
            
            LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
    
            LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                        'UNION ALL SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, numtarjetasustituta,relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "VS";';	
            LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
            SYSTEM TRIM(cQuery1);
        END IF;
            
        
            
            
            
            select COUNT(*) conteo_total
            into vConteo
            from tbl_abu_tar_bitacora WHERE marca = 'MC';
            
            
            
            IF(vConteo > 0) THEN
            
            --NOMBRE ARCHIVO
    
                    LET nombreArchivo = '';
                    LET nombreArchivo ='R274_2REEMPLAZO_MASTER_';
                    
                    --genera archivo
                    
                    LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
        
                    LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                                'UNION ALL SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, numtarjetasustituta,relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "MC";';	
                    LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
                    SYSTEM TRIM(cQuery1);
            END IF;
                    
                    
                    
                    
            
            
    
            --Inicializan variables
            LET vConteoRegistros = 0;
            LET vIniciaTransaccion = 'F';
            
            
            
            
            
            
            TRUNCATE TABLE "informix".tbl_abu_tar_bitacora;
            
            TRUNCATE TABLE "informix".tbl_abu_add;
            
            
            LET vsRelleno3 = LPAD(NVL(vsRelleno4,' '), 3,' ');
            LET vsRelleno19 = LPAD(NVL(vsRelleno19,' '), 19,' ');
            LET vsRelleno11 = LPAD(NVL(vsRelleno11,' '), 11,' ');
            
            LET vsRelleno4 = LPAD(NVL(vsRelleno11,' '), 4,' ');
            LET vsRelleno16 = LPAD(NVL(vsRelleno19,' '), 16,' ');
            
            
            
    -- 5.- CAMBIO DE CARTERA
            
            
            FOREACH tarjetas WITH HOLD FOR
    
                
                SELECT abu.numtarjeta, abu.codstatustarjeta, abu.fechaexp, abu.numtarjetasustituta, abu.fechaasignacion, abu.fechaultmodif, abu.marca, act.marca, act.numtarjeta, act.codstatustarjeta, act.fechaexp, act.numtarjetasustituta, act.fechaasignacion, act.fechaultmodif
                INTO vNumtarjeta, vCodstatustarjeta,vFechaexp,vNumtarjetasustituta,vFechaasignacion,vFechaultmodif, vMarca, v2Marca, v2Numtarjeta, v2Codstatustarjeta, v2Fechaexp,v2Numtarjetasustituta, v2fechaasignacion, v2fechaultmodif
                    
                FROM tbl_info_tarjetas_abu abu
                inner join tbl_info_tarjetas_abu act on act.numtarjeta = abu.numtarjetasustituta
            
                where abu.marca = act.marca and abu.codproductotarjeta <> act.codproductotarjeta
                            
                                    
                        LET MMEXP= SUBSTRING(vFechaexp FROM 3 FOR 4);
                        LET YYEXP= SUBSTRING(vFechaexp FROM 1 FOR 2);
                        LET FECHNUEXP = MMEXP||YYEXP;					
    
                        LET MMEXP2= SUBSTRING(v2Fechaexp FROM 3 FOR 4);
                        LET YYEXP2= SUBSTRING(v2Fechaexp FROM 1 FOR 2);
                        
                        LET FECHNUEXP2 = MMEXP2||YYEXP2;
                        
                                        
                        
                        LET bin1 = TRIM(SUBSTRING(vNumtarjeta FROM 1 FOR 8));
                        LET bin2 = TRIM(SUBSTRING(v2Numtarjeta FROM 1 FOR 8));
                        
                        
                        
                            
                            IF (vIniciaTransaccion = 'F') THEN 
                            SET ISOLATION TO dirty READ;
                                BEGIN WORK;
                                    LET vIniciaTransaccion = 'V';
                            END IF;
                            
                            
    
                
                INSERT INTO "informix".tbl_abu_tar_bitacora (identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, numtarjetasustituta, fechaexpsustituta, identificadorabu,codstatustarjeta, fechaasignacion, relleno11, codstatustarjeta2, marca)
                    VALUES("D", LPAD(vIca,11,'0'), vNumtarjeta, vsRelleno3, FECHNUEXP, vsRelleno16, vsRelleno3, vNumtarjetasustituta, NVL(FECHNUEXP2,'0000'),'P',vCodstatustarjeta, vFechaasignacion, vsRelleno11, v2Codstatustarjeta, vMarca);
                    
                
                
            
                
                LET vConteoRegistros = vConteoRegistros + 1;
                
                IF (vConteoRegistros >= 0) THEN
                SET ISOLATION TO dirty READ;
                        COMMIT WORK;
                            LET vConteoRegistros = 0;
                            LET vIniciaTransaccion = 'F';
                    CONTINUE FOREACH;
                END IF
                
                
            END FOREACH
            
            --Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
            IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
                SET ISOLATION TO dirty READ;
                COMMIT WORK;
            END IF
            
        --inserta un registro para la cabecera inicial.
            
            INSERT INTO "informix".tbl_abu_add (identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16,relleno3_2, fechaexpsustituta, identificadorabu, codstatustarjeta, fechaasignacion,relleno11)
                
            VALUES("H", LPAD(vIca,11,'0'), vsRelleno16, vsRelleno3, vsRelleno4, vsRelleno16, vsRelleno3, vsRelleno4, "P", NULL, NULL, vsRelleno11);
                
                
            select COUNT(*) conteo_total
            into vConteo
            from tbl_abu_tar_bitacora WHERE marca = 'VS';
            
            
            
            IF(vConteo > 0) THEN
            
            --NOMBRE ARCHIVO
    
                    LET nombreArchivo = '';
                    LET nombreArchivo ='R274_4CARTERA_VISA_';
                
    
                    --genera archivo
                    
                    LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
        
                    LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                                'UNION ALL SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, numtarjetasustituta, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "VS";';	
                    LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
                    SYSTEM TRIM(cQuery1);
            END IF;
                
            SELECT COUNT(*) conteo_total
                INTO vConteo
            FROM tbl_abu_tar_bitacora 
                WHERE marca = 'MC';
            
            
            
            IF(vConteo > 0) THEN
            
            --NOMBRE ARCHIVO
    
                    LET nombreArchivo = '';
                    LET nombreArchivo ='R274_4CARTERA_MASTER_';
                    
    
                    --genera archivo
                    
                    LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
        
                    LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                                'UNION ALL SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, numtarjetasustituta, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "MC";';	
                    LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
                    SYSTEM TRIM(cQuery1);
            END IF;
            
            
            
            
            --Inicializan variables
            LET vConteoRegistros = 0;
            LET vIniciaTransaccion = 'F';
            
            
            
            
            
            
            TRUNCATE TABLE "informix".tbl_abu_tar_bitacora;
            
            TRUNCATE TABLE "informix".tbl_abu_add;
            
            
            LET vsRelleno3 = LPAD(NVL(vsRelleno4,' '), 3,' ');
            LET vsRelleno19 = LPAD(NVL(vsRelleno19,' '), 19,' ');
            LET vsRelleno11 = LPAD(NVL(vsRelleno11,' '), 11,' ');
            
            LET vsRelleno4 = LPAD(NVL(vsRelleno11,' '), 4,' ');
            LET vsRelleno16 = LPAD(NVL(vsRelleno19,' '), 16,' ');
            
            
            
    -- 6.- CAMBIO DE MARCA
            
            
            FOREACH tarjetas WITH HOLD FOR

                SELECT abu.numtarjeta, abu.codstatustarjeta, abu.fechaexp, abu.numtarjetasustituta, abu.fechaasignacion, abu.fechaultmodif, abu.marca, act.numtarjeta, act.codstatustarjeta, act.fechaexp, act.numtarjetasustituta, act.fechaasignacion, act.fechaultmodif, act.marca
                    INTO vNumtarjeta, vCodstatustarjeta, vFechaexp, vNumtarjetasustituta, vFechaasignacion, vFechaultmodif, vMarca, v2Numtarjeta, v2Codstatustarjeta, v2Fechaexp, v2Numtarjetasustituta, v2fechaasignacion, v2fechaultmodif, v2Marca
                FROM tbl_info_tarjetas_abu abu
                INNER JOIN  tbl_info_tarjetas_abu act ON act.numtarjeta = abu.numtarjetasustituta
                    WHERE abu.marca <> act.marca 
                
                LET MMEXP= SUBSTRING(vFechaexp FROM 3 FOR 4);
                LET YYEXP= SUBSTRING(vFechaexp FROM 1 FOR 2);
                LET FECHNUEXP = MMEXP||YYEXP;		

                        
                LET MMEXP2= SUBSTRING(v2Fechaexp FROM 3 FOR 4);
                LET YYEXP2= SUBSTRING(v2Fechaexp FROM 1 FOR 2);
                
                LET FECHNUEXP2 = MMEXP2||YYEXP2;
 
                IF (vIniciaTransaccion = 'F') THEN  
                    SET ISOLATION TO dirty READ;
                    BEGIN WORK;
                    LET vIniciaTransaccion = 'V';
                END IF;
     
                INSERT INTO "informix".tbl_abu_tar_bitacora (identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, numtarjetasustituta, fechaexpsustituta, identificadorabu,codstatustarjeta, fechaasignacion, relleno11, codstatustarjeta2, marca)
                    VALUES("D", LPAD(vIca,11,'0'), vNumtarjeta, vsRelleno3, FECHNUEXP, vsRelleno16, vsRelleno3, vNumtarjetasustituta, NVL(FECHNUEXP2,'0000'),'B',vCodstatustarjeta, vFechaasignacion, vsRelleno11, v2Codstatustarjeta, vMarca);
                    
                LET vConteoRegistros = vConteoRegistros + 1;
                
                IF (vConteoRegistros >= 0) THEN
                SET ISOLATION TO dirty READ;
                        COMMIT WORK;
                            LET vConteoRegistros = 0;
                            LET vIniciaTransaccion = 'F';
                    CONTINUE FOREACH;
                END IF
                
                
            END FOREACH
            
            
            --Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
            IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
                SET ISOLATION TO dirty READ;
                COMMIT WORK;
            END IF
            
        --inserta un registro para la cabecera inicial.
            
            INSERT INTO "informix".tbl_abu_add (identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16,relleno3_2, fechaexpsustituta, identificadorabu, codstatustarjeta, fechaasignacion,relleno11)
                VALUES("H", LPAD(vIca,11,'0'), vsRelleno16, vsRelleno3, vsRelleno4, vsRelleno16, vsRelleno3, vsRelleno4, "B", NULL, NULL, vsRelleno11);
                
            SELECT COUNT(*) conteo_total
                INTO vConteo
            FROM tbl_abu_tar_bitacora 
                WHERE marca = 'VS';
            
            
            
            IF(vConteo > 0) THEN
            
            --NOMBRE ARCHIVO
    
                    LET nombreArchivo = '';
                    LET nombreArchivo ='R274_3MARCA_VISA_';
                    
    
                    --genera archivo
                    
                    LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
        
                    LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                                'UNION ALL SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, numtarjetasustituta, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "VS";';	
                    LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
                    SYSTEM TRIM(cQuery1);
            END IF;
            
            SELECT COUNT(*) conteo_total
                INTO vConteo
            FROM tbl_abu_tar_bitacora 
                WHERE marca = 'MC';
            
            
            
            IF(vConteo > 0) THEN
            
            --NOMBRE ARCHIVO
    
                    LET nombreArchivo = '';
                    LET nombreArchivo ='R274_3MARCA_MASTER_';
                    
    
                    --genera archivo
                    
                    LET pArchDeclarga1='"/RESPALDOSNEW/abu/abu_files_out/'||TRIM(nombreArchivo)||'.unl" ';
        
                    LET cCmd1 = 'SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, relleno16, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_add ' ||
                                'UNION ALL SELECT identificador, numIca, numtarjeta, relleno3, fechaexp, numtarjetasustituta, relleno3_2, fechaexpsustituta, identificadorabu, relleno11 FROM tbl_abu_tar_bitacora WHERE marca = "MC";';	
                    LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||(pArchDeclarga1)||"  "||(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
                    SYSTEM TRIM(cQuery1);
            END IF;
      
        RETURN cCodRet;	
            
    END
END PROCEDURE
;