CREATE PROCEDURE "informix".sp_genera_archivo_afiliacion_comercios()
RETURNING CHAR(5) AS Cod_Retorno;

-- ****************************************************************************
-- Definicion de variables
-- ****************************************************************************

DEFINE v_idproceso        	INT;
DEFINE v_fecha_inicio_mes 	DATE;
DEFINE sDiaP              	CHAR(2);
DEFINE sMesP              	CHAR(2);
DEFINE sAnoP              	CHAR(4);
DEFINE v_hInicio          	CHAR(11);
DEFINE v_fhInicioMes      	VARCHAR(25);
DEFINE v_fecha_fin_mes    	DATE;
DEFINE v_hFin             	CHAR(11);
DEFINE v_fhFinMes         	VARCHAR(25);

DEFINE cCmd1        	    CHAR(1000);
DEFINE pArchDeclarga1	    CHAR(1000);
DEFINE cQuery1        	    CHAR(3000);

DEFINE nombreArchivo        VARCHAR(25);
DEFINE fh_inicioProceso		DATETIME YEAR TO FRACTION(5);
DEFINE fh_finProceso		DATETIME YEAR TO FRACTION(5);
DEFINE vMaxIdProceso        INT;
DEFINE vMinIdProceso        INT;
DEFINE totalRegistros       INT;

DEFINE iSql_err				INT;
DEFINE cCodRet				CHAR(5);


-- ****************************************************************************
-- Inicializa de variables
-- ****************************************************************************

LET v_idproceso 			= 0;
LET v_fecha_inicio_mes 		= '';
LET sDiaP               	= '';
LET sMesP               	= '';
LET sAnoP               	= '';
LET v_hInicio 				= ' 00:00:00.0';
LET v_fhInicioMes 			= '';
LET v_fecha_fin_mes 		= '';
LET v_hFin 					= ' 23:59:59.9';
LET v_fhFinMes 				= '';

LET cCmd1           	    = '';
LET pArchDeclarga1          = '';
LET cQuery1        	        = '';

LET nombreArchivo           = '';
LET fh_inicioProceso		= '';
LET fh_finProceso			= '';
LET vMaxIdProceso           = 0;
LET vMinIdProceso           = 0;
LET totalRegistros          = 0;

LET iSql_err				= 0;
LET cCodRet					= '00000';


-- ****************************************************************************
-- Logica del SP
-- ****************************************************************************

BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
	
        --SET DEBUG FILE TO "/home/c90304940/mroman/prueba_jesus.out";
       -- TRACE ON;
        
        --SE ELIMINA LA INFORMACION DE LA TABLA
		TRUNCATE TABLE "informix".tbl_idproceso_numero_afiliacion DROP STORAGE;
		
		--SE ELIMINA LA INFORMACION DE LA TABLA
        TRUNCATE TABLE "informix".tbl_numero_afiliacion DROP STORAGE;
		
		--SE ELIMINA LA INFORMACION DE LA TABLA
		TRUNCATE TABLE "informix".tbl_movimiento_mes_anterior DROP STORAGE;
								
		--Consulta el primer dia del mes anterior

        LET sDiaP = "01";
         
		IF (MONTH(today )-1 = 0) THEN
		
            LET sMesP = "12";
        
            SELECT year(today ) - 1  INTO sAnoP FROM systables   where tabid=1;
    
		ELSE 
	
		
		    SELECT month(today )-1 INTO sMesP FROM systables   where tabid=1;
		    IF sMesP < 10 THEN
		        LET sMesP = 0 || sMesP;
		    END IF

            SELECT year(today )  INTO sAnoP FROM systables  where tabid=1;
		
		END IF
		
        
        ----Fecha y hora inicio mes anterior---- 
        LET v_fhInicioMes = trim(sAnoP ||'-'|| sMesP || '-' || sDiaP || v_hInicio);
        
        --Consulta el ultimo dia del mes anterior ***";        
        LET v_fecha_fin_mes = add_months(last_day(DATE(today)),-1);
        LET sDiaP = '';
        LET sDiaP = day(v_fecha_fin_mes);
        
        --Fecha y hora fin mes anterior---- ***';
        LET v_fhFinMes = trim(sAnoP ||'-'|| sMesP ||'-'|| sDiaP || v_hFin);
        

        --Consulta el estatus del ultimo idProceso registrado en la tabla bitacora_afiliaciones_comercios
        SELECT idproceso 
            INTO v_idproceso
        FROM "informix".bitacora_afiliaciones_comercios
        WHERE estatus_proceso = 'P'
            AND total_registros = 0;
         
        LET v_idproceso = v_idproceso;      
                
        --Evalua si el valor de la variable v_idproceso es igual 0 o nulo
        IF (v_idproceso = 0 OR v_idproceso IS NULL) THEN
        
		SET ISOLATION TO dirty READ;
             
		BEGIN WORK;
			INSERT INTO "informix".tbl_idproceso_numero_afiliacion (idproceso, numero_afiliacion)
			    SELECT idproceso, trim(numero_afiliacion)
					FROM "informix".afiliaciones_comercios
			    WHERE estatus_comercio = "A" 
			        ORDER BY idproceso;
		COMMIT WORK;
		
			--consulta el valor maximo almacenado en la tabla "informix".tbl_idproceso_numero_afiliacion
			SELECT MAX(idproceso) max_idProceso 
				INTO vMaxIdProceso
			FROM "informix".tbl_idproceso_numero_afiliacion;

			LET vMaxIdProceso = vMaxIdProceso;

			--consulta el valor minimo almacenado en la tabla "informix".tbl_idproceso_numero_afiliacion
			SELECT MIN(idproceso) min_idProceso 
				INTO vMinIdProceso
			FROM "informix".tbl_idproceso_numero_afiliacion;

			
			WHILE (vMinIdProceso <= vMaxIdProceso)  LOOP
        
				SET ISOLATION TO dirty READ;
				
				BEGIN WORK;
                INSERT INTO "informix".tbl_numero_afiliacion(numero_afiliacion)
					SELECT numero_afiliacion
						FROM "informix".tbl_idproceso_numero_afiliacion
					WHERE idproceso = vMinIdProceso;
				COMMIT WORK;

				SET ISOLATION TO dirty READ;
				
				BEGIN WORK;
				INSERT INTO "informix".tbl_movimiento_mes_anterior(fechaTrxn, bin8, codISO, metodoCaptura, esNacional, codTransaccion, numAfiliacion, infoReceptor, tipoTransaccionPos, tipoTransaccionPosdigitada, metodoIdentificacion, motivoRechazo, cantidadTransacciones, montoTotalOperado)
					SELECT -- {+INDEX(intercard:movimiento idx_fechahorainauth)}
						DATE(mv.fechahorainauth) AS fecha,
						SUBSTR (mv.numtarjeta,0,8) AS bin,
						mv.codigoiso, 
						mv.metodocaptura, 
						mv.esnacional,
						mv.codtran,
						mv.idretailer AS Afiliacion,
						mv.infreceptor, 
						mv.tipotransaccionpos, 
						mv.tipotransaccionposdigitada, 
						mv.MetodoIdentificacion, 
						mv.motivo,
						COUNT(*) AS Cantidad, 
						SUM(mv.monto) AS Monto_Total
						FROM intercard:movimiento mv
						WHERE mv.fechahorainauth BETWEEN v_fhInicioMes AND v_fhFinMes     
						AND SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM intercard:bines)
						AND mv.codigoiso IS NOT NULL 
						AND mv.codigoiso != ('null') AND mv.codigoiso <> ' '
						AND mv.prodind = '02'
						AND mv.esnacional IN ('V','F')
						AND mv.formato = '0200'
						AND mv.codtran IN ('00','09')
						AND mv.idretailer IN (SELECT numero_afiliacion FROM "informix".tbl_numero_afiliacion)
						AND mv.codreversa = '0'                            
						AND mv.movreversado = 'F'  
						AND mv.metodocaptura IS NOT NULL 
						AND mv.metodocaptura != ('null')
						AND mv.transaccionorigen = '1234'
						GROUP BY fecha, bin,2,3,4,5,6,7,8,9,10,11,12;
				COMMIT WORK;	
				
				--Se inicializa la variable fh_inicioProceso
				LET fh_inicioProceso = '';
				--Sentencia utilizada para obtener el fecha y hora actual para ser almacenda en la variable fh_inicioProceso
				SELECT DBINFO('utc_to_datetime', sh_curtime) 
					INTO fh_inicioProceso
				FROM sysmaster:"informix".sysshmvals;
				LET fh_inicioProceso = fh_inicioProceso;
				
				--Se hace un insert a la tabla "informix".bitacora_afiliaciones_comercios por cada IdProceso 
				INSERT INTO "informix".bitacora_afiliaciones_comercios(idproceso,fechahora_inicio_proceso,fechahora_fin_proceso,estatus_proceso,total_registros)
                VALUES (vMinIdProceso,fh_inicioProceso,'','P',0);
				
				
				--NOMBRE ARCHIVO
                LET nombreArchivo = '';
                LET nombreArchivo ='ID'||vMinIdProceso||'-'||sMesP||sAnoP;

                --Genera archivo por ID proceso
				LET pArchDeclarga1='"/RESPALDOSNEW/'||TRIM(nombreArchivo)||'.unl" delimiter "|" ';
				LET cCmd1 = 'SELECT fechatrxn, bin8, codISO, metodoCaptura, esNacional, codTransaccion, numAfiliacion, infoReceptor, tipoTransaccionPos, tipoTransaccionPosdigitada, metodoIdentificacion, motivoRechazo, cantidadTransacciones, montoTotalOperado FROM intercard:tbl_movimiento_mes_anterior ORDER BY  numAfiliacion,fechatrxn;';
				LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDeclarga1)||"  "||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
				SYSTEM TRIM(cQuery1);
				
				--CONSULTA QUE OBTIEN EL TOTAL DE REGISTROS EN UN ARCHIVO POR IDPROCESO
                SELECT COUNT(*)
					INTO totalRegistros
                FROM "informix".tbl_movimiento_mes_anterior;
                LET totalRegistros = totalRegistros;
				
				--Se inicializa la variable fh_finProceso
				LET fh_finProceso = '';
				--Sentencia utilizada para obtener el fecha y hora actual para ser almacenda en la variable fh_finProceso
				SELECT DBINFO('utc_to_datetime', sh_curtime) 
					INTO fh_finProceso
				FROM sysmaster:"informix".sysshmvals;
				LET fh_finProceso = fh_finProceso;

                --actualiza tabla "informix".bitacora_afiliaciones_comercios por cada IDproceso
                UPDATE "informix".bitacora_afiliaciones_comercios
					SET  fechahora_fin_proceso = fh_finProceso, estatus_proceso='T', total_registros = totalRegistros
                WHERE idProceso = vMinIdProceso 
					AND estatus_proceso = 'P';

				--SE ELIMINA LA INFORMACION DE LA TABLA
				TRUNCATE TABLE "informix".tbl_movimiento_mes_anterior DROP STORAGE;
                 
                --incrementa valor variable
                LET vMinIdProceso = vMinIdProceso + 1;
                
                --SE ELIMINA LA INFORMACION DE LA TABLA
                TRUNCATE TABLE "informix".tbl_numero_afiliacion DROP STORAGE;

            END LOOP;
      
	    --Evalua si el valor de la variable v_idproceso es diferente a 0
        ELIF (v_idproceso <> 0 ) THEN 
            
		
		    SET ISOLATION TO dirty READ;
            
			BEGIN WORK;
            INSERT INTO "informix".tbl_idproceso_numero_afiliacion (idproceso, numero_afiliacion)
			    SELECT idproceso, trim(numero_afiliacion)
			    FROM intercard:afiliaciones_comercios
			 WHERE estatus_comercio = "A" 
			    AND idproceso >= v_idproceso
                ORDER BY idproceso;
			COMMIT WORK;
			        
			--consulta el valor maximo almacenado en la tabla "informix".tbl_idproceso_numero_afiliacion
			SELECT MAX(idproceso) max_idProceso 
				INTO vMaxIdProceso
			FROM "informix".tbl_idproceso_numero_afiliacion;

			LET vMaxIdProceso = vMaxIdProceso;
        
			--consulta el valor minimo almacenado en la tabla "informix".tbl_idproceso_numero_afiliacion
			SELECT MIN(idproceso) min_idProceso 
				INTO vMinIdProceso
			FROM "informix".tbl_idproceso_numero_afiliacion;
        
			LET vMinIdProceso = vMinIdProceso;


			WHILE (vMinIdProceso <= vMaxIdProceso)  LOOP
        
				SET ISOLATION TO dirty READ;
					
					BEGIN WORK;
                    INSERT INTO "informix".tbl_numero_afiliacion(numero_afiliacion)
						SELECT numero_afiliacion
							FROM "informix".tbl_idproceso_numero_afiliacion
						WHERE idproceso = vMinIdProceso;
					COMMIT WORK;
         
				SET ISOLATION TO dirty READ;
					
					BEGIN WORK;
					INSERT INTO "informix".tbl_movimiento_mes_anterior(fechaTrxn, bin8, codISO, metodoCaptura, esNacional, codTransaccion, numAfiliacion, infoReceptor, tipoTransaccionPos, tipoTransaccionPosdigitada, metodoIdentificacion, motivoRechazo, cantidadTransacciones, montoTotalOperado)
						SELECT -- {+INDEX(intercard:movimiento idx_fechahorainauth)}
							DATE(mv.fechahorainauth) AS fecha,
							SUBSTR (mv.numtarjeta,0,8) AS bin,
							mv.codigoiso, 
							mv.metodocaptura, 
							mv.esnacional,
							mv.codtran,
							mv.idretailer AS Afiliacion,
							mv.infreceptor, 
							mv.tipotransaccionpos, 
							mv.tipotransaccionposdigitada, 
							mv.MetodoIdentificacion, 
							mv.motivo,
							COUNT(*) AS Cantidad, 
							SUM(mv.monto) AS Monto_Total
							FROM intercard:movimiento mv
							WHERE mv.fechahorainauth BETWEEN v_fhInicioMes AND v_fhFinMes   
							AND SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM intercard:bines)
							AND mv.codigoiso IS NOT NULL 
							AND mv.codigoiso != ('null') AND mv.codigoiso <> ' '
							AND mv.prodind = '02'
							AND mv.esnacional IN ('V','F')
							AND mv.formato = '0200'
							AND mv.codtran IN ('00','09')
							AND mv.idretailer IN (SELECT numero_afiliacion FROM "informix".tbl_numero_afiliacion)
							AND mv.codreversa = '0'                            
							AND mv.movreversado = 'F'  
							AND mv.metodocaptura IS NOT NULL 
							AND mv.metodocaptura != ('null')
							AND mv.transaccionorigen = '1234'
							GROUP BY fecha, bin,2,3,4,5,6,7,8,9,10,11,12;
					COMMIT WORK;

				--NOMBRE ARCHIVO

                LET nombreArchivo = '';
                LET nombreArchivo ='ID'||vMinIdProceso||'-'||sMesP||sAnoP;
				
                --Genera archivo por ID proceso
                
				LET pArchDeclarga1='"/RESPALDOSNEW/'||TRIM(nombreArchivo)||'.unl" delimiter "|" ';
				LET cCmd1 = 'SELECT fechatrxn, bin8, codISO, metodoCaptura, esNacional, codTransaccion, numAfiliacion, infoReceptor, tipoTransaccionPos, tipoTransaccionPosdigitada, metodoIdentificacion, motivoRechazo, cantidadTransacciones, montoTotalOperado FROM intercard:tbl_movimiento_mes_anterior ORDER BY  numAfiliacion,fechatrxn;';
				LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDeclarga1)||"  "||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
				SYSTEM TRIM(cQuery1);
				
				
				
				--CONSULTA QUE CUENTA EL TOTAL DE REGISTROS EN UN ARCHIVO POR IDPROCESO
                SELECT COUNT(*)
					INTO totalRegistros
                FROM "informix".tbl_movimiento_mes_anterior;
                
                LET totalRegistros = totalRegistros;
				
				--Se inicializa la variable fh_finProceso
				LET fh_finProceso = '';
				--Sentencia utilizada para obtener el fecha y hora actual para ser almacenda en la variable fh_finProceso
				SELECT DBINFO('utc_to_datetime', sh_curtime) 
					INTO fh_finProceso
				FROM sysmaster:"informix".sysshmvals;
				LET fh_finProceso = fh_finProceso;

                --actualiza tabla "informix".bitacora_afiliaciones_comercios por cada IDproceso
                UPDATE "informix".bitacora_afiliaciones_comercios 
					SET  fechahora_fin_proceso = fh_finProceso, estatus_proceso = 'T', total_registros = totalRegistros
				WHERE idProceso = vMinIdProceso
					AND estatus_proceso = 'P';
			
				--SE ELIMINA LA INFORMACION DE LA TABLA
				TRUNCATE TABLE "informix".tbl_movimiento_mes_anterior DROP STORAGE;
                 
                --incrementa valor variable
                LET vMinIdProceso = vMinIdProceso + 1;
                

                IF(vMinIdProceso <= vMaxIdProceso)THEN
				
					--Se inicializa la variable fh_inicioProceso
					LET fh_inicioProceso = '';
					--Sentencia utilizada para obtener el fecha y hora actual para ser almacenda en la variable fh_inicioProceso
					SELECT DBINFO('utc_to_datetime', sh_curtime) 
						INTO fh_inicioProceso
					FROM sysmaster:"informix".sysshmvals;
					LET fh_inicioProceso = fh_inicioProceso;
					
					--Se hace un insert a la tabla "informix".bitacora_afiliaciones_comercios por cada IdProceso 
					INSERT INTO "informix".bitacora_afiliaciones_comercios(idproceso,fechahora_inicio_proceso,fechahora_fin_proceso,estatus_proceso,total_registros)
					VALUES (vMinIdProceso,fh_inicioProceso,'','P',0);

                END IF;
                
                --SE ELIMINA LA INFORMACION DE LA TABLA
                TRUNCATE TABLE "informix".tbl_numero_afiliacion DROP STORAGE;
                
            END LOOP;
		END IF;
		
	RETURN cCodRet;
	END;
END PROCEDURE;