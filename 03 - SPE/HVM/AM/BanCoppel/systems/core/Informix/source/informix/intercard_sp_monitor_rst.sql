CREATE PROCEDURE "informix".sp_monitor_rst()
RETURNING CHAR(5) AS rCodigoRetorno, CHAR(160) AS mensaje, DATETIME YEAR TO FRACTION(3) AS fechaInicial, DATETIME YEAR TO FRACTION(3) AS fechaFinal;
    
    DEFINE vDescripcion	            VARCHAR(20);
    DEFINE vCodigoiso	            VARCHAR(2);
    DEFINE vMotivo 		            VARCHAR(70);
    DEFINE vTotalRST     	        SMALLINT;
    DEFINE vTotalMov     	        SMALLINT;
    DEFINE vEstatusOTP              CHAR(1);
    DEFINE vTotalTransaccionesRST   SMALLINT;
    DEFINE vTotalTransaccionesMov   SMALLINT;
    DEFINE vFechaInicial			DATETIME YEAR TO FRACTION(3);
    DEFINE RUTA						VARCHAR(100);
    --DEFINE NOMBRE_ARCHIVO			VARCHAR(35);
    DEFINE SCRIPT_EJECUCION1		VARCHAR(35);
    DEFINE SCRIPT_EJECUCION2		VARCHAR(35);
    DEFINE ARCHIVO_RST				VARCHAR(35);
    DEFINE ARCHIVO_INTERCARD		VARCHAR(35);
    DEFINE vExecuteSQL				LVARCHAR(1000);
    DEFINE SQLERR 					INTEGER;
    DEFINE ISAM_ERR 				INTEGER;
    DEFINE ERROR_INFO 				VARCHAR(80);
    DEFINE vCodigoRetorno           CHAR(5);
    DEFINE vMensaje		            CHAR(160);
	DEFINE vPrefijo                 VARCHAR(5);
    DEFINE vFechaFinal              DATETIME YEAR TO FRACTION(3);
	DEFINE vCommit  				INTEGER;
	DEFINE vConteoRegistros 		INTEGER;
	DEFINE vIniciaTransaccion   	CHAR(1);
	

    LET vDescripcion = '';
    LET vMotivo = '';
    LET vTotalRST = 0;
    LET vTotalMov = 0;
    LET vFechaInicial = current;
    LET vCodigoiso = '';
    LET vEstatusOTP = '';
    LET vTotalTransaccionesRST= 0;
    LET vTotalTransaccionesMov= 0;

    LET RUTA = '/RESPALDOSNEW/';
    --LET NOMBRE_ARCHIVO = 'Monitor_txn_rst.txt';
    LET ARCHIVO_RST = 'registros_claves_retiro.unl ';
    LET ARCHIVO_INTERCARD = 'registros_movimiento.unl ';
    LET SCRIPT_EJECUCION1 = 'ejec_script_clavesretiro.sql';
    LET SCRIPT_EJECUCION2 = 'ejec_script_movimiento.sql';
    LET vExecuteSQL = '';

    LET vCodigoRetorno = '';
    LET vMensaje = '';
	
	LET vCommit = 10;
    LET vConteoRegistros = 0;
    LET vIniciaTransaccion='';
	
	LET vPrefijo = 'mrst_';
    LET vFechaFinal = current;
    
    
    --SET DEBUG FILE TO RUTA||vPrefijo||"monitor_rst.out";
	--TRACE ON;    
		
	BEGIN 
    
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
				SET DEBUG FILE TO RUTA || "excepcion_sp_monitor_rst.err.out";
				TRACE ON;
				
												
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO;                
					RETURN vCodigoRetorno, vMensaje, vFechaInicial, vFechaFinal;
				END IF;
				
		END EXCEPTION;
		
		
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		TRUNCATE TABLE intercard:"informix".tbl_monitor_rst DROP STORAGE;
		TRUNCATE TABLE intercard:"informix".tbl_monitor_rst_movimiento DROP STORAGE;
		
		--Obtiene la fecha
		SELECT CURRENT - 30 UNITS MINUTE
			INTO vFechaInicial
		FROM bdinteg:"informix".si_fechas
		WHERE empresa = '001';
		
		
		SELECT count(*)
				INTO vTotalTransaccionesRST
		FROM bdirst:"informix".claves_retiro
			WHERE cr_alta_fecha BETWEEN vFechaInicial AND CURRENT;
			
		SELECT count(*)
				INTO vTotalTransaccionesMov
		FROM intercard:"informix".movimiento
			WHERE fechahorainauth BETWEEN vFechaInicial AND CURRENT
			AND tipoctadestino = '71'
			AND codtran = '01'
			AND prodind = '01'
			AND movreversado = 'F'
			AND formato = '0200';
					
			
		LET vIniciaTransaccion = 'F';
		
		IF (vTotalTransaccionesRST > 0) THEN
			FOREACH monitorRST WITH HOLD FOR
				
				SELECT a.cr_status, b.cat_descripcion_status,count(*)
					INTO vEstatusOTP, vDescripcion, vTotalRST
				FROM bdirst:"informix".claves_retiro a 
				INNER JOIN bdirst:"informix".cat_status b
				ON( a.cr_status = b.cat_cod_status)
					WHERE cr_alta_fecha BETWEEN vFechaInicial AND CURRENT
				GROUP BY a.cr_status, b.cat_descripcion_status
				
				IF (vIniciaTransaccion = 'F') THEN 
					BEGIN WORK;
					LET vIniciaTransaccion = 'V';
				END IF;
				
				INSERT INTO intercard:"informix".tbl_monitor_rst
					VALUES (vEstatusOTP,vDescripcion, vTotalRST);
					
				LET vConteoRegistros = vConteoRegistros + 1;
				
				IF (vConteoRegistros >= vCommit) THEN
					COMMIT WORK;
					LET vConteoRegistros = 0;
					LET vIniciaTransaccion = 'F';
					CONTINUE FOREACH;
				END IF
				
		END FOREACH
			
		ELSE 
			
			INSERT INTO intercard:"informix".tbl_monitor_rst
				VALUES ("-", "No hay trancciones de retiro sin tarjeta",0);
			
			LET vConteoRegistros = vConteoRegistros + 1;
        
			IF (vConteoRegistros >= vCommit) THEN
				COMMIT WORK;
				LET vConteoRegistros = 0;
				LET vIniciaTransaccion = 'F';
				
			END IF
		
		END IF			
		
		IF(vConteoRegistros = 0 OR vIniciaTransaccion = 'V')THEN --Se cambia validacion para que cuando no encuentre registros termine la transaccion y no devuelva un error -255
			COMMIT WORK;
		END IF
			
		LET vIniciaTransaccion = 'F';
			
		IF (vTotalTransaccionesMov > 0 ) THEN
			FOREACH movimiento WITH HOLD FOR
			 
				SELECT codigoiso, motivo, count(*)
					INTO vCodigoiso, vMotivo, vTotalMov
				FROM intercard:"informix".movimiento
					WHERE fechahorainauth BETWEEN vFechaInicial AND CURRENT
					AND tipoctadestino = '71'
					AND codtran = '01'
					AND prodind = '01'
					AND movreversado = 'F'
					AND formato = '0200'
				GROUP BY codigoiso, motivo
				IF (vCodigoiso = '00') THEN
					
					IF (vIniciaTransaccion = 'F') THEN 
						BEGIN WORK;
						LET vIniciaTransaccion = 'V';
					END IF;
				
										
					INSERT INTO intercard:"informix".tbl_monitor_rst_movimiento
						VALUES (vCodigoiso, "Transaccion aprobada", vTotalMov);
						
					LET vConteoRegistros = vConteoRegistros + 1;
					
					IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
						COMMIT WORK;
					END IF
			
					
					ELSE
						IF (vIniciaTransaccion = 'F') THEN 
							BEGIN WORK;
							LET vIniciaTransaccion = 'V';
						END IF;
						
						INSERT INTO intercard:"informix".tbl_monitor_rst_movimiento
							VALUES (vCodigoiso, vMotivo, vTotalMov);
						
						LET vConteoRegistros = vConteoRegistros + 1;
						
						IF (vConteoRegistros >= vCommit) THEN
							COMMIT WORK;
							LET vConteoRegistros = 0;
							LET vIniciaTransaccion = 'F';
							CONTINUE FOREACH;
						END IF
				END IF
					
					
			END FOREACH
		ELSE
				IF (vIniciaTransaccion = 'F') THEN 
						BEGIN WORK;
						LET vIniciaTransaccion = 'V';
				END IF;
			
				INSERT INTO intercard:"informix".tbl_monitor_rst_movimiento
					VALUES ("-", "No hay transacciones de retiro sin tarjeta", 0);
				
				LET vConteoRegistros = vConteoRegistros + 1;
						
				IF (vConteoRegistros >= vCommit) THEN
					COMMIT WORK;
					LET vConteoRegistros = 0;
					LET vIniciaTransaccion = 'F';
						
				END IF
				
				IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
					COMMIT WORK;
				END IF
			
		
		END IF
		
		
		--GeneraciÃÂ³n de archivo
				
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA||vPrefijo||ARCHIVO_RST||
		'SELECT * FROM intercard:"informix".tbl_monitor_rst;" >'||RUTA||vPrefijo||SCRIPT_EJECUCION1;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA||vPrefijo||ARCHIVO_INTERCARD||
		'SELECT * FROM intercard:"informix".tbl_monitor_rst_movimiento;" >'||RUTA||vPrefijo||SCRIPT_EJECUCION2;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard '||RUTA||vPrefijo||SCRIPT_EJECUCION1;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard '||RUTA||vPrefijo||SCRIPT_EJECUCION2;
		SYSTEM vExecuteSQL;
			
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm -f '||RUTA||vPrefijo||SCRIPT_EJECUCION1;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm -f '||RUTA||vPrefijo||SCRIPT_EJECUCION2;
		SYSTEM vExecuteSQL;
		
				
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
		RETURN vCodigoRetorno, vMensaje,vFechaInicial, vFechaFinal;
			
	END
	
END PROCEDURE
DOCUMENT
'Autor: Kenya Itzel Alonso Sanchez',
'Objetivo: Monitor de transacciones de retiro sin tarjeta',
'Fecha de CreaciÃÂ³n: 18/04/2021',
'Fecha ÃÂºltima modificaciÃÂ³n: 12/04/2022'
;

CREATE PROCEDURE "informix".sp_consultatarjetabin_pba(pEmpresa CHAR(3), pLote INTEGER, pTarjetaini CHAR(16), pTarjetafin CHAR(16))
RETURNING CHAR(5) AS codigo_retorno,CHAR(1) AS tipo;

	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipo CHAR(1);
	DEFINE cBin CHAR(6);
	DEFINE iNumeroLote1 INTEGER;
	DEFINE iNumeroLote2 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipo = '';
	LET cBin = '';
	LET iNumeroLote1 = 0;
	LET iNumeroLote2 = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr		
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));
			END IF;			
		END EXCEPTION; 	

		 -- SET DEBUG FILE TO "/respaldosbd/mario/trace.sql";
		 -- TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pLote,'')) = '' OR TRIM(NVL(pTarjetaini,'')) = '' OR TRIM(NVL(pTarjetafin,'')) = ''  THEN		
			LET cCodRet = '00001';
		ELSE				
			SELECT numerolote INTO iNumeroLote1
			FROM intercard:"informix".lote
			WHERE numerolote = pLote;
			
			SELECT DISTINCT(numerolote) INTO iNumeroLote2
			FROM intercard:"informix".tarjeta 
			WHERE numtarjeta >= pTarjetaini AND numtarjeta <= pTarjetafin;
			
			IF iNumeroLote1 = iNumeroLote2 THEN
			
				LET cBin = SUBSTR(pTarjetaini,1,6);
				
				SELECT creditodebito INTO cTipo FROM intercard:"informix".bines WHERE bin = cBin;
				
				IF TRIM(NVL(cTipo,'')) = '' THEN			
					LET cCodRet = '00003';
				END IF;			
				
			ELSE
				LET cCodRet = '00002';
			END IF;
				
		END IF;		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));		
	END;
END PROCEDURE
DOCUMENT
'Autor: 95142134 Mario Gallardo',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 29-11-2016',
'ModificaciÃ³n: Se crea procedimiento para validar bines de tarjetas',
'Sustento: 144_1_1_1_11_12_1_1_5_.pdf',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

CREATE PROCEDURE "informix".sp_consultatarjetabin_pba1(pEmpresa CHAR(3), pLote INTEGER, pTarjetaini CHAR(16), pTarjetafin CHAR(16))
RETURNING CHAR(5) AS codigo_retorno,CHAR(1) AS tipo;

	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipo CHAR(1);
	DEFINE cBin CHAR(6);
	DEFINE iNumeroLote1 INTEGER;
	DEFINE iNumeroLote2 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipo = '';
	LET cBin = '';
	LET iNumeroLote1 = 0;
	LET iNumeroLote2 = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr		
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));
			END IF;			
		END EXCEPTION; 	

		 -- SET DEBUG FILE TO "/respaldosbd/mario/trace.sql";
		 -- TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pLote,'')) = '' OR TRIM(NVL(pTarjetaini,'')) = '' OR TRIM(NVL(pTarjetafin,'')) = ''  THEN		
			LET cCodRet = '00001';
		ELSE				
			SELECT numerolote INTO iNumeroLote1
			FROM intercard:"informix".lote
			WHERE numerolote = pLote;
			
			SELECT DISTINCT(numerolote) INTO iNumeroLote2
			FROM intercard:"informix".tarjeta_20240205 
			WHERE numtarjeta >= pTarjetaini AND numtarjeta <= pTarjetafin;
			
			IF iNumeroLote1 = iNumeroLote2 THEN
			
				LET cBin = SUBSTR(pTarjetaini,1,6);
				
				SELECT creditodebito INTO cTipo FROM intercard:"informix".bines WHERE bin = cBin;
				
				IF TRIM(NVL(cTipo,'')) = '' THEN			
					LET cCodRet = '00003';
				END IF;			
				
			ELSE
				LET cCodRet = '00002';
			END IF;
				
		END IF;		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));		
	END;
END PROCEDURE
DOCUMENT
'Autor: 95142134 Mario Gallardo',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 29-11-2016',
'ModificaciÃ³n: Se crea procedimiento para validar bines de tarjetas',
'Sustento: 144_1_1_1_11_12_1_1_5_.pdf',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

CREATE PROCEDURE "informix".sp_consultatarjetabin_pba2(pEmpresa CHAR(3), pLote INTEGER, pTarjetaini CHAR(16), pTarjetafin CHAR(16))
RETURNING CHAR(5) AS codigo_retorno,CHAR(1) AS tipo;

	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipo CHAR(1);
	DEFINE cBin CHAR(6);
	DEFINE iNumeroLote1 INTEGER;
	DEFINE iNumeroLote2 INTEGER;
	DEFINE str1 CHAR(50);
define vfecha_hoy       char(8);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipo = '';
	LET cBin = '';
	LET iNumeroLote1 = 0;
	LET iNumeroLote2 = 0;
	LET str1 = '';
let vfecha_hoy          = "";
	
	BEGIN

		ON EXCEPTION SET iSqlErr		
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));
			END IF;			
		END EXCEPTION; 	

		  SET DEBUG FILE TO "trace_pba1.out";
		  TRACE ON;

		SET ISOLATION TO DIRTY READ;
SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d")  INTO vfecha_hoy
   from sysmaster:sysshmvals;

		IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pLote,'')) = '' OR TRIM(NVL(pTarjetaini,'')) = '' OR TRIM(NVL(pTarjetafin,'')) = ''  THEN		
			LET cCodRet = '00001';
		ELSE				
			SELECT numerolote INTO iNumeroLote1
			FROM intercard:"informix".lote
			WHERE numerolote = pLote;
			
SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d")  INTO vfecha_hoy
   from sysmaster:sysshmvals;

			SELECT DISTINCT(numerolote) INTO iNumeroLote2
			FROM intercard:"informix".tarjeta 
			WHERE numtarjeta >= pTarjetaini AND numtarjeta <= pTarjetafin;
			

			IF iNumeroLote1 = iNumeroLote2 THEN
			
				LET cBin = SUBSTR(pTarjetaini,1,6);
				
SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d")  INTO vfecha_hoy
   from sysmaster:sysshmvals;

				SELECT creditodebito INTO cTipo FROM intercard:"informix".bines WHERE bin = cBin;
				
SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d")  INTO vfecha_hoy
   from sysmaster:sysshmvals;

				IF TRIM(NVL(cTipo,'')) = '' THEN			
					LET cCodRet = '00003';
				END IF;			
				
			ELSE
				LET cCodRet = '00002';
			END IF;
				
		END IF;		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));		
	END;
END PROCEDURE
DOCUMENT
'Autor: 95142134 Mario Gallardo',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 29-11-2016',
'ModificaciÃ³n: Se crea procedimiento para validar bines de tarjetas',
'Sustento: 144_1_1_1_11_12_1_1_5_.pdf',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

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