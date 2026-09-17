CREATE PROCEDURE "informix".sp_camp_proceso_principal_pbajj( pTipoReporte VARCHAR(2), pPeriodo CHAR(1), pNumeroDesfase SMALLINT )
    RETURNING VARCHAR (5) AS rCODIGO_RETORNO, VARCHAR(150) AS rMENSAJE_RESPUESTA, DATE as rFechaIntegralHoy;
	
    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(80);
    
	DEFINE CODIGO_RETORNO VARCHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(150);
    DEFINE RUTA_ORIGEN  VARCHAR(80);   
    
    DEFINE vFechaInicial DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaFinal DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaIntegralHoy DATE;
    DEFINE vFechaHoy DATE;    
    
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RESPUESTA = 'El proceso es ejecutado exitosamente.';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vFechaInicial = '';
    LET vFechaFinal = '';
    LET vFechaHoy = '';
    LET vFechaIntegralHoy = CURRENT;    
    
    BEGIN 

   ---     ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_camp_proceso_principal_"||pTipoReporte||".err.out";
          ---TRACE ON;
            
         ---   IF ( SQLERR <> 0 ) THEN
       ---         LET CODIGO_RETORNO = SQLERR;
          ---      LET MENSAJE_RESPUESTA = ERROR_INFO;                
          ---      RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaIntegralHoy;
          ---  END IF;
            
       --- END EXCEPTION;

        --SET DEBUG FILE TO RUTA_ORIGEN||"debug_sp_camp_proceso_principal.out";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        EXECUTE PROCEDURE "informix".sp_intercard_calcular_periodos( pPeriodo, pNumeroDesfase)
            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaInicial, vFechaFinal, vFechaIntegralHoy;
            
        IF ( CODIGO_RETORNO <> '00000' OR vFechaInicial IS NULL OR vFechaFinal IS NULL OR vFechaIntegralHoy IS NULL) THEN
            LET CODIGO_RETORNO = '00001';
            LET MENSAJE_RESPUESTA = 'Error al obtener el rango de tiempo.';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaIntegralHoy;
        END IF

        EXECUTE PROCEDURE "informix".sp_camp_obtener_movs_transacc( pTipoReporte, vFechaInicial, vFechaFinal)
            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA;
        
        IF ( CODIGO_RETORNO <> '00000') THEN
            LET CODIGO_RETORNO = CODIGO_RETORNO;
            LET MENSAJE_RESPUESTA = 'Error al buscar los movimientos.';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaIntegralHoy;
        END IF

		RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaIntegralHoy;
        
	END
END PROCEDURE
DOCUMENT
'#1 ',
'Base de datos: intercard',
'Autor: Armando Garcia Ortiz',
'Creacion: 10 de julio del 2020',
'Descripcion: Obtener la transaccionalidad de movimientos con tarjeta presente y tarjeta no presente.',
'considerando el rango de fechas de inicio y fin.',
'Los clientes a buscar son con tarjetas de tecnologías: tipo A, B o C, o bien, que no tenga firma electronica activada o cvv dinámico.',
'Este componente es ejecutado por los jobs:',
'843_01_CMP_CARGA_TAR_TP_PRO',
'   843_02_CMP_CARGA_TAR_TNP_PRO',
'Fecha de modificación: 13 de agosto del 2021',
'#2 ',
'Modificación: 27 de septiembre del 2021',
'Se corrige el nombre del archivo creado en el código exception.'
;

CREATE PROCEDURE "informix".sp_ctes_tdd_presente_pbajj( pNumeroMeses VARCHAR(2), pNumMesAnteriorSdo INTEGER )    
    RETURNING VARCHAR(5) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO, 
        DATE as vFechaInicio, DATE as vFechaFinal;

        DEFINE CODIGO_RETORNO VARCHAR(5);
        DEFINE MENSAJE_RETORNO VARCHAR(80);
        DEFINE RUTA_ORIGEN VARCHAR(80);
        DEFINE RUTA_DESTINO VARCHAR(80);
        DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(15);
        DEFINE PREFIJO_SCRIPTS CHAR(8);
        DEFINE CONTADOR_TRANSACCIONES SMALLINT;
        DEFINE RPT_TARJ_PRESENTE VARCHAR(15);
        DEFINE ID_PLANTILLA CHAR(1);
        DEFINE FALSO CHAR(1);
        DEFINE VERDADERO CHAR(1);
        
        DEFINE vFechaInicio DATE;
        DEFINE vFechaFinal DATE;
        DEFINE vSaldoPromedio INTEGER;
        DEFINE vNumeroMeses VARCHAR(2);
        DEFINE vNumMesAnteriorSdo INTEGER; --Numero de meses anterior al mes actual (saldo promedio)
        DEFINE vAnyoMes CHAR(6);
        DEFINE vPrimerMesTrimestral CHAR(2);
        DEFINE vPrimerDiaMes DATE;
        
        DEFINE vCliente CHAR(20);
        DEFINE vNombre1 CHAR(26);
        DEFINE vNombre2 CHAR(26);
        DEFINE vCorreoElect CHAR(100);
        DEFINE vNumRegistrosAfectados  INTEGER;
        DEFINE vFlujoEnTransaccion  CHAR(1);        

        -- Los valores de las plantillas:
        ---       Valor | Plantilla 
        ---         1   | TP_CAPTA
        ---         2   | TNP_CAPTA
        ---         3   | TAG_CAPTA
        ---         4   | ATM_CAPTA
        ---         5   | VENT_CAPTA

    BEGIN
        
        LET CODIGO_RETORNO  = '00000';
        LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
        LET RUTA_ORIGEN = '/resplogifx/';
        LET RUTA_DESTINO = '/resplogifx/';
        LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
        LET RPT_TARJ_PRESENTE = 'TP_CAPTA';
        LET ID_PLANTILLA = '1';
        LET PREFIJO_SCRIPTS = 'reptrim_';
        LET CONTADOR_TRANSACCIONES = 10000;
        LET FALSO = 'F';
        LET VERDADERO ='V';
        
        LET vCliente = NULL;
        LET vNombre1 = NULL;
        LET vNombre2 = NULL;
        LET vCorreoElect = NULL;    
        LET vFlujoEnTransaccion = FALSO;
        LET vFechaInicio = '';
        LET vFechaFinal = ''; 
        LET vSaldoPromedio = 0;
        
        --Variables utilizadas en la creacion de los archivos.
        LET vNumeroMeses = pNumeroMeses;
        LET vNumMesAnteriorSdo = pNumMesAnteriorSdo;
        LET vAnyoMes = '';
        LET vPrimerMesTrimestral = '';
        LET vPrimerDiaMes = '';    
        LET vNumRegistrosAfectados = 0;
        
        --SET DEBUG FILE TO RUTA_ORIGEN||"sp_ctes_tdd_presente.out";
        --TRACE ON;
    
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        DROP TABLE IF EXISTS tmp_info_clientes;
        DROP TABLE IF EXISTS tmp_clientes_promedio;
        
        EXECUTE PROCEDURE intercard:"informix".sp_rpt_trim_obtener_parametros( RUTA_ORIGEN, RPT_TARJ_PRESENTE, pNumeroMeses , pNumMesAnteriorSdo)
            INTO CODIGO_RETORNO, MENSAJE_RETORNO, vPrimerMesTrimestral, vPrimerDiaMes, vFechaInicio, vFechaFinal, vAnyoMes , vSaldoPromedio;
        
        IF (CODIGO_RETORNO <> '00000') THEN        
            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;
        END IF
            
        EXECUTE PROCEDURE intercard:"informix".sp_rpt_trim_consultar_movs(RUTA_ORIGEN, RUTA_DESTINO, RUTA_UNLOAD_RESPALDOS, RPT_TARJ_PRESENTE, ID_PLANTILLA, vFechaInicio, vFechaFinal)
            INTO CODIGO_RETORNO, MENSAJE_RETORNO;

        IF (CODIGO_RETORNO <> '00000') THEN        
            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;
        END IF
        
        --Obtencion de cuentas activas y unicamente relacionadas con tarjetas de los clientes previamente seleccionados
        /*
        Paso 3. TDD Presente
        Obtener a los clientes con un promedio mensual anterior MAYOR A 200
        Considerar que debe evitarse dividir entre dias cero (0) [ AND diacum > 0 ]
        Script lines: 1-3 -- An attempt was made to divide by zero
        */   
        
        SELECT 
            DISTINCT mcheq.cuenta,
            CASE
                WHEN CAST((sdo.capvigacum/sdo.diacum) AS DECIMAL(10,0)) > vSaldoPromedio THEN 'S'
                ELSE 'N'
            END AS cte_promedio
        FROM intercard:tarjetacuenta tarcta
            INNER JOIN bdicheq:sc_maechq mcheq
                ON (mcheq.cuenta = tarcta.numcuenta)
            INNER JOIN bdicheq:sc_sdodiarioc sdo
                ON (tarcta.numcuenta = sdo.cuenta)
        WHERE mcheq.empresa = '001'        
            AND mcheq.num_cte IN (SELECT inf_cliente FROM intercard:info_paso_clientes WHERE inf_plantilla = ID_PLANTILLA)
                AND mcheq.status_cta = 1
            AND sdo.aniomes = vAnyoMes
                AND sdo.diacum > 0        
        INTO TEMP tmp_clientes_promedio WITH NO LOG;
        
        CREATE INDEX "informix".idx_tmp_info_clientes_cte_promedio
            ON informix.tmp_clientes_promedio(cte_promedio) ONLINE;
           
        /*
        Paso 4. TDD Presente
        Los clientes tienen una cuenta activa y un correo valido (validacion por dominio (bdinteg)
        --indice para optimizar la busqueda en maech utilizando los campos: num_cte, status_cta
        */
        
        SELECT
            DISTINCT mcheq.num_cte cliente,
                sicte.nombre1 nombre1, sicte.nombre2 nombre2,
                sicor.correo_elec correo_electronico, mcheq.status_cta
        FROM bdicheq:sc_maechq mcheq, bdinteg:si_cliente sicte, bdinteg:si_correos sicor
            WHERE mcheq.num_cte = sicte.numcte
                AND mcheq.num_cte = sicor.numcte
                AND sicor.tipo_correo = '1'
                AND sicor.status_correo = 'A'
                AND sicor.valido = '1'
                AND sicor.valida_correo = '200'
                AND mcheq.status_cta = '1'
            --Instruccion para obtener unicamente cuentas de clientes con saldo promedio
            AND mcheq.cuenta IN (SELECT cuenta FROM tmp_clientes_promedio WHERE cte_promedio = 'S')
        INTO TEMP tmp_info_clientes WITH NO LOG;

        CREATE INDEX "informix".idx_tmp_info_clientes_status_cta
            ON informix.tmp_info_clientes(status_cta) ONLINE;
            
        FOREACH cursor1 WITH HOLD FOR

                SELECT cliente, nombre1, nombre2, correo_electronico
                    INTO vCliente, vNombre1, vNombre2, vCorreoElect
                FROM intercard:tmp_info_clientes                
                    WHERE status_cta = '1'

                IF (vFlujoEnTransaccion = FALSO) THEN
                    BEGIN WORK;
                    LET vFlujoEnTransaccion = VERDADERO;
                END IF;
                
                INSERT INTO intercard:info_clientes_captacion 
                    VALUES ('001', ID_PLANTILLA, vCliente, vNombre1, vNombre2, vCorreoElect);
                
                LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2") + vNumRegistrosAfectados;
                
                IF (vNumRegistrosAfectados = CONTADOR_TRANSACCIONES) THEN
                    COMMIT WORK;
                    LET vFlujoEnTransaccion = FALSO;
                    LET vNumRegistrosAfectados = 0;
                    CONTINUE FOREACH;
                END IF;
        END FOREACH;    
        
        IF ((vNumRegistrosAfectados > 0) OR (vFlujoEnTransaccion = VERDADERO)) THEN
            COMMIT WORK;
            LET vFlujoEnTransaccion = FALSO;
        END IF;

        EXECUTE PROCEDURE intercard:"informix".sp_rpt_trim_registrar_clientes(RUTA_ORIGEN, RUTA_UNLOAD_RESPALDOS, RPT_TARJ_PRESENTE, ID_PLANTILLA)
            INTO CODIGO_RETORNO, MENSAJE_RETORNO;
            
        IF (CODIGO_RETORNO <> '00000') THEN        
            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;
        END IF
        
        EXECUTE PROCEDURE intercard:"informix".sp_rpt_trim_generar_archivos(RUTA_ORIGEN, RUTA_UNLOAD_RESPALDOS, RPT_TARJ_PRESENTE, ID_PLANTILLA)
            INTO CODIGO_RETORNO, MENSAJE_RETORNO;
        
        IF (CODIGO_RETORNO <> '00000') THEN        
            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;
        END IF
        
        DROP TABLE IF EXISTS tmp_info_clientes;
        DROP TABLE IF EXISTS tmp_clientes_promedio;
        
        RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;

    END
    
END PROCEDURE
/*
-- Autor: [ agarciao@bancoppel.com ]
-- Modificado: 22.enero.2018 09:39:00am
-- Fecha de modificacion: 18.octubre.2019 13:30:00pm
-- Base de datos: intercard
-- Job: 533_00_REPORTE_TRIMESTRAL_CTES_CAPTA_INTERCARD_PRO
-- Descripcion:
-- Plantilla 1: Clientes con compra de tarjeta presente: sp_ctes_tdd_presente
-- Plantilla 2: Clientes con compra de tarjeta no presente: sp_ctes_tdd_no_presente
-- Plantilla 3: Clientes con compra TAG: sp_ctes_tdd_compratag
-- Plantilla 4: Clientes con retiros en cajeros automaticos: sp_ctes_tdd_retiros_atm
-- Plantilla 5: Clientes retiro o consulta de saldo en ventanilla: sp_ctes_tdd_ventanilla
-- Reporte de Conteo: El sp_reporte_trimestral_captacion borra la tabla info_reporte_trimestral
*/
;

CREATE PROCEDURE "informix".sp_depuracion_alertservice()
RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	--DefiniciÃ³n de variables
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE vFechaMin			DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaFinal 			VARCHAR(25);
	DEFINE vFechaPrimerDiaMes	VARCHAR(25);
	DEFINE vTotalRegistros		INTEGER;
	DEFINE vIdregistro 			INTEGER;
	
	DEFINE HORA_MIN_SEG_FINAL	VARCHAR(14);
	DEFINE RUTA					VARCHAR(50);
	DEFINE PREFIJO				VARCHAR(17);
	DEFINE NOMBRE_UNL_ARCHIVO 	VARCHAR(33);
	DEFINE ARCHIVO_UNL_PIV		VARCHAR(33);
    DEFINE SCRIPT_EJECUCION 	VARCHAR(35);
	DEFINE SCRIPT_EJECUCION2 	VARCHAR(35);
	DEFINE SCRIPT_EJECUCION_PIV VARCHAR(35);
	DEFINE SCRIPT_INSERT_EJECUCION_PIV VARCHAR(40);
    DEFINE ARCHIVO_ERR		 	VARCHAR(33);
	DEFINE ARCHIVO_ERR_PIV		VARCHAR(33);
	DEFINE CONTADOR_TRANSACCIONES 	SMALLINT; 
	DEFINE ACTUALIZAR_ESTAD 	VARCHAR(40);	
	DEFINE SCRIPT_DELETE		VARCHAR(35);
	DEFINE ARCHIVO_CONTEOREGISTRO VARCHAR(40);
	
	DEFINE vIdregistro_piv 		INTEGER;
	DEFINE vNumRegistro			INTEGER;
	DEFINE vConteoRegistros 		INTEGER;
	DEFINE vIniciaTransaccion   	CHAR(1);
	
    
	DEFINE vExecuteSQL		    LVARCHAR(1000);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
    DEFINE ERROR_INFO 			VARCHAR(80);
	
	--InicializaciÃ³n de variables
	LET vCodigoRetorno = '';
	LET vMensaje = '';
	LET vFechaPrimerDiaMes ='';
		
	LET HORA_MIN_SEG_FINAL = '23:59:59.99999';
	LET RUTA = '/RESPALDOSNEW/';
	LET PREFIJO='dep_alertservice_';
	LET NOMBRE_UNL_ARCHIVO = PREFIJO||'registros.unl';
	LET ARCHIVO_UNL_PIV = 'unl_his_piv.unl';
	LET SCRIPT_EJECUCION = 'instruccion.sql';	
	LET SCRIPT_EJECUCION2 = 'instruccion2.sql';
	LET SCRIPT_EJECUCION_PIV = 'script_ejecucion_piv.sql';
	LET SCRIPT_INSERT_EJECUCION_PIV = 'script_insert_ejecucion_piv.sql';
	LET ARCHIVO_ERR= 'archivo_err.txt';
	LET ARCHIVO_ERR_PIV = 'archivo_err_piv.txt';
	LET CONTADOR_TRANSACCIONES = 1000;  
	LET ACTUALIZAR_ESTAD = 'actualizar_estadisticas.sql';
	LET SCRIPT_DELETE = 'instruccion_delete.sql';
	LET ARCHIVO_CONTEOREGISTRO = 'conteo_registros.txt';
	
	LET vIdregistro_piv=0;	
	LET vNumRegistro=0;		
	LET vConteoRegistros = 0;
	LET vIniciaTransaccion = '';
	LET vIdregistro = 0;

	LET vExecuteSQL	='';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/dep_alertservice.out";
	--TRACE ON;

	BEGIN
	
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
				SET DEBUG FILE TO RUTA ||PREFIJO||"error.err.out";
				TRACE ON;
				
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		TRUNCATE TABLE "informix".alertservice_piv DROP STORAGE;
		
		
		--Fecha mÃ­nima para depurar
		--Paso1.
		SELECT MIN(idregistro)
			INTO vIdregistro
		FROM alertservice;
		--Paso2.
		SELECT (fechahorareg) 
			INTO vFechaMin		
		FROM "informix".alertservice
		WHERE idregistro = vIdregistro;
		
		--Fecha primer dÃ­a del mes
		SELECT pri_dia_mes
			INTO vFechaPrimerDiaMes
		FROM bdinteg:"informix".si_fechas
		WHERE empresa = '001';
		
		LET vFechaFinal = SUBSTR(vFechaMin, 1, 10)||' '||HORA_MIN_SEG_FINAL;
		LET vFechaPrimerDiaMes = SUBSTR(vFechaPrimerDiaMes,7,4)||'-'||SUBSTR(vFechaPrimerDiaMes,1,2)||'-'||SUBSTR(vFechaPrimerDiaMes,4,2)||' '||'00:00:00.00000';
		
		--Si la fecha mÃ­nima de depuraciÃ³n es mayor al primer dÃ­a del mes no depura la tabla	
		IF (vFechaMin >= vFechaPrimerDiaMes) THEN
			LET vCodigoRetorno = '00001';
			LET vMensaje = 'La tabla se encuentra con registros del mes';
			RETURN vCodigoRetorno, vMensaje;
					
		ELSE 
		
			--Se crea la instrucciÃ³n
			LET vExecuteSQL	= '';
			LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
			'   SET LOCK MODE TO WAIT 3; '||
			'       UNLOAD TO '||RUTA||NOMBRE_UNL_ARCHIVO||
			'   SELECT idregistro, secuenciaext , instanciaaut, idevento, idplantilla,'||
			'          strsql, fechahorareg, fechahoraproc, estatus, retcode,'||
			'          retcodeifx'||        
			'    FROM intercard:\"informix\".alertservice' ||
			" WHERE fechahorareg BETWEEN '"||vFechaMin||"'"||' AND '||"'"||vFechaFinal||"'"||';'||        
			'" >'||RUTA||PREFIJO||SCRIPT_EJECUCION;            
			SYSTEM vExecuteSQL;         
			
		
			--descarga la informaciÃ³n en un unl
			LET vExecuteSQL   = '';
			LET vExecuteSQL   = 'dbaccess intercard '||RUTA||PREFIJO||SCRIPT_EJECUCION;
			SYSTEM vExecuteSQL;
			
			--crea segunda instrucciÃ³n
			LET vExecuteSQL = '';
			LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA||NOMBRE_UNL_ARCHIVO|| "' DELIMITER '|' "||'11'||
							"; INSERT INTO "||'\"informix\".alertservice_hist;'||'"'||' > '||RUTA||PREFIJO||SCRIPT_EJECUCION2;
			SYSTEM vExecuteSQL;
		
			--descarga la informaciÃ³n en la tabla histÃ³rica
			LET vExecuteSQL = '';
			LET vExecuteSQL = "dbload -d intercard -c "||RUTA||PREFIJO||SCRIPT_EJECUCION2||" -l "||RUTA||PREFIJO||ARCHIVO_ERR||" -n "||CONTADOR_TRANSACCIONES||" -r";
			SYSTEM vExecuteSQL;
				

			LET vCodigoRetorno = '00001';
			LET vMensaje = 'HISTORICA';
			
			
			--Se crea la instrucciÃ³n para validar los registros transferidos
			LET vExecuteSQL	= '';
			LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
			'   SET LOCK MODE TO WAIT 3; '||
			'       UNLOAD TO '||RUTA||PREFIJO||ARCHIVO_UNL_PIV||
			"   SELECT '001', idregistro, 'F'"||        
			'    FROM intercard:\"informix\".alertservice_hist' ||
			" WHERE fechahorareg BETWEEN '"||vFechaMin||"'"||' AND '||"'"||vFechaFinal||"'"||';'||        
			'" >'||RUTA||PREFIJO||SCRIPT_EJECUCION_PIV;            
			SYSTEM vExecuteSQL; 
			
			--descarga la informaciÃ³n en un unl
			LET vExecuteSQL   = '';
			LET vExecuteSQL   = 'dbaccess intercard '||RUTA||PREFIJO||SCRIPT_EJECUCION_PIV;
			SYSTEM vExecuteSQL;
			
			--InstrucciÃ³n para insertar en la tabla de paso
			LET vExecuteSQL = '';
			LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA||PREFIJO||ARCHIVO_UNL_PIV|| "' DELIMITER '|' "||'3'||
							"; INSERT INTO "||'\"informix\".alertservice_piv;'||'"'||' > '||RUTA||PREFIJO||SCRIPT_INSERT_EJECUCION_PIV;
			SYSTEM vExecuteSQL;
       
	   
			--descarga la informaciÃ³n en la tabla pivote
			LET vExecuteSQL = '';
			LET vExecuteSQL = "dbload -d intercard -c "||RUTA||PREFIJO||SCRIPT_INSERT_EJECUCION_PIV||" -l "||RUTA||PREFIJO||ARCHIVO_ERR_PIV||" -n "||CONTADOR_TRANSACCIONES||" -r";
			SYSTEM vExecuteSQL;
			
			LET vCodigoRetorno = '00002';
			LET vMensaje = 'TABLA DE PASO';
			
			LET vIniciaTransaccion = 'F';
			
			--eliminar de registros de la tabla en lÃ­nea
			FOREACH registros WITH HOLD FOR
			
				SELECT idregistro
					INTO vIdregistro_piv
				FROM "informix".alertservice_piv
				WHERE empresa = '001'
				
				SELECT COUNT(*)
					INTO vNumRegistro
				FROM "informix".alertservice
				WHERE idregistro = vIdregistro_piv;
				
					
				IF (vIniciaTransaccion = 'F') THEN 
					BEGIN WORK;
					LET vIniciaTransaccion = 'V';
				END IF;
				
				--Si existe registro, borra la informaciÃ³n de la tabla en lÃ­nea
				IF(vNumRegistro = 1) THEN
					
								
					DELETE FROM "informix".alertservice WHERE idregistro = vIdregistro_piv;
					
					UPDATE "informix".alertservice_piv  SET transferido = 'V'
						WHERE idregistro = vIdregistro_piv;
					
					LET vConteoRegistros = vConteoRegistros + 2;
				
				ELSE 
					CONTINUE FOREACH;
				END IF
				
								
				IF (vConteoRegistros >= CONTADOR_TRANSACCIONES) THEN
					COMMIT WORK;
					LET vConteoRegistros = 0;
					LET vIniciaTransaccion = 'F';
					CONTINUE FOREACH;
				END IF
						
			END FOREACH
		
			IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
				COMMIT WORK;
			END IF
			
		END IF
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo UPDATE STATISTICS MEDIUM FOR TABLE intercard:\"informix\".alertservice > '||RUTA||PREFIJO||ACTUALIZAR_ESTAD;
		SYSTEM vExecuteSQL;    
			
		LET vExecuteSQL   = '';
		LET vExecuteSQL   = 'dbaccess intercard '||RUTA||PREFIJO||ACTUALIZAR_ESTAD;
		SYSTEM vExecuteSQL;
		
		LET vConteoRegistros = 0;
		
		--conteo de registros eliminados
		SELECT COUNT(*)
			INTO vConteoRegistros
		FROM intercard:"informix".alertservice_piv
		WHERE empresa = '001' and transferido = 'V';
		
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = "echo '"||vFechaMin||'|'||vFechaFinal||'|'||vConteoRegistros||"'"||' > '||RUTA||ARCHIVO_CONTEOREGISTRO;
        SYSTEM vExecuteSQL;
	
	
	--borrar archivos
		
		 
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f ' ||RUTA||PREFIJO||'*';
        SYSTEM vExecuteSQL;
        
	   LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
		RETURN vCodigoRetorno, vMensaje;
			
	END
END PROCEDURE
DOCUMENT
'CoordinaciÃ³n de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I',
'Autor: Kenya Itzel Alonso Sanchez',
'Fecha de creacion: 24 de marzo del 2022',
'Base de datos: intercard',
'RQI 13 817 - GeneraciÃ³n de procesos de depuraciÃ³n Intercard - bditarjeta',
'DescripciÃ³n: SPL que depura de forma diaria la tabla alertservice'
;

CREATE PROCEDURE "informix".sp_txns_pos_diaria	( pPeriodicidad CHAR(1), pNumeroDesfase SMALLINT )
---ASIGNACION DE NOMBRE A LAS VARIABLRES DE RETORNO
RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO;						 
 
	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	DEFINE  CODIGO_RETORNO2     CHAR(5);
	DEFINE  MENSAJE_RESPUESTA2  CHAR(50);
	DEFINE  vFechaIntegral      DATE;
	
	DEFINE vpri_dia_mes  	   DATE; 
    DEFINE ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
    DEFINE primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
	DEFINE vaniomes       varchar(10);
	DEFINE CONTADOR_TRANSACCIONES SMALLINT;
 
	DEFINE vnumtarjeta    varchar(16);
	DEFINE vinfreceptor   varchar(40);
	DEFINE vesnacional    varchar(1);
 
	DEFINE vidretailer char(19);  
    DEFINE vbin        CHAR(8);  
	DEFINE vafiliacion varchar(15);  
	
	DEFINE TIPO_PLANTILLA 		varchar(20); 		   
    DEFINE RUTA_DESTINO 		varchar(80);
		      
    DEFINE	vsql			    char(1150);
    DEFINE  vConteo             INTEGER;
    DEFINE  vsFlagEnTransaccion VARCHAR(1);
	
    DEFINE vExecuteSQL LVARCHAR(8000);
    DEFINE NOMBRE_ARCHIVO    VARCHAR(50);
	DEFINE SCRIPT_EJECUCION  VARCHAR(30);
	DEFINE SCRIPT_EJECUCION2 VARCHAR(30);
	DEFINE SCRIPT_EJECUCION3  VARCHAR(34);
	DEFINE vIndicadorProceso CHAR(1);  

    --DEFINE  icommit	    INTEGER;
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);  
----------------------------------------------- 
	LET  vFechaIntegral     = ''; 
    LET  CODIGO_RETORNO2    = '';
	LET  MENSAJE_RESPUESTA2 = '';
 
	LET vnumtarjeta         = '';
	LET vinfreceptor        = ''; 
	LET vesnacional         = '';
    LET vidretailer = '';
	LET vbin = '';
    LET vafiliacion = ''; 	
	
    LET RUTA_DESTINO     = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA	 = 'RTX_RESUMEN_';     
 
	LET vConteo  = 0;
    LET vsFlagEnTransaccion = 'F';
    --LET icommit 		  = 0;
	LET vExecuteSQL       = '';
    LET NOMBRE_ARCHIVO    = 'mov_txns_daily_';
    LET SCRIPT_EJECUCION  = 'script_txn_daily.sql';
	LET SCRIPT_EJECUCION2 = 'movs_txns_daily';
	LET SCRIPT_EJECUCION3 = 'script_final_txns_daily.sql';
	LET vIndicadorProceso = '0';
	LET CONTADOR_TRANSACCIONES = 1000;

	
	LET codigo_retorno  = '00000';
    LET mensaje_retorno = 'PROCESO EXITOSO';
	
	
	--SET DEBUG FILE TO RUTA_DESTINO || "sp_txns_pos_diaria.out";
    --TRACE ON;        
		
BEGIN 		

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "excep_sp_txns_pos_diaria.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current||' '||'vIndicadorProceso =>'||vIndicadorProceso;
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;

	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;
		--------------------------------------------------------------------------------------------------------	
	
		 BEGIN;
		   TRUNCATE TABLE "informix".paso_mov_txns  DROP STORAGE;
         COMMIT; 
	
        --------------------------------------------------------------------------------------------------------
		-----------<Obtencion de fechas>-------------------  

		        LET vIndicadorProceso = '1';
		
		           EXECUTE PROCEDURE sp_intercard_calcular_periodos(pPeriodicidad, pNumeroDesfase)  
		           INTO  CODIGO_RETORNO2, MENSAJE_RESPUESTA2, primer_dia_mes_hora, ultimo_dia_mes_hora, vFechaIntegral;
	 
		            SELECT (fecha_hoy-1) INTO  vpri_dia_mes  FROM bdinteg:si_fechas WHERE empresa= '001';  
		            let vaniomes =   LPAD (DAY(vpri_dia_mes),2,"0") ||'_'|| LPAD (MONTH(vpri_dia_mes),2,"0")||'_'|| year(vpri_dia_mes);
                    let vaniomes = vaniomes ;
		    -----------<Fin Obtencion de fechas>------------------- 
          
		         LET vIndicadorProceso = '2';
				-- Elimina el unload anterior
				   --------------------
				    LET vExecuteSQL = '';
                   LET vExecuteSQL = ' rm -f '||RUTA_DESTINO||NOMBRE_ARCHIVO||'*';
                    SYSTEM vExecuteSQL;	 
                   --------------------
                  LET vExecuteSQL	= '';
                   LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO '||RUTA_DESTINO||NOMBRE_ARCHIVO||vaniomes||'.unl '||
									 ' SELECT  '''||vpri_dia_mes||''' as Fecha,   '||  
									 ' numtarjeta,codigoiso,metodocaptura,esnacional,codtran,NVL(idretailer, ''"'||'0'||'"''),infreceptor,tipotransaccionpos,  '||
									 ' tipotransaccionposdigitada,metodoidentificacion,motivo, ''"'||'X'||'"''   as afiliacion,  '||
									 ' ''"'||'X'||'"''  as bin, monto AS monto_total     '||
		                             '  FROM intercard:movimiento mv  '||
				                     '  WHERE mv.fechahorainauth BETWEEN  '''||primer_dia_mes_hora||''' AND  '''||ultimo_dia_mes_hora||''' '|| 
						             '  AND mv.prodind =  ''"'||'02'||'"''   '||  	                                                 
									 '  AND codtran IN  (''"'||'00'||'"'',''"'||'09'||'"'')   '||   
		                             '  AND mv.esnacional IN  (''"'||'V'||'"'',''"'||'F'||'"'')   '||  
                                     '  AND mv.codigoiso IS NOT NULL AND mv.codigoiso !=  (''"'||'null'||'"'')  AND mv.codigoiso <> ''"'||''||'"''    '||  
                                     '  AND formato  =  ''"'||'0200'||'"''    '||   
									 '  AND mv.codreversa   =   ''"'||'0'||'"''     '|| 
									 '  AND mv.movreversado =   ''"'||'F'||'"''     '||   
                                     '  AND mv.metodocaptura IS NOT NULL AND mv.metodocaptura != (''"'||'null'||'"'')   '|| 
								     '  AND mv.transaccionorigen =   ''"'||'1234'||'"''     '||   
                                     '" >'||RUTA_DESTINO||SCRIPT_EJECUCION;
				     SYSTEM vExecuteSQL;
					 
					 LET vIndicadorProceso = '3';
  			        -----------------------------------------------------------------------------------------------------------------	
		            --Asigancion de permisos del archivo .sql
		            let vExecuteSQL ='';			
		            let vExecuteSQL= 'chmod 777 ' ||RUTA_DESTINO||SCRIPT_EJECUCION;
		            system vExecuteSQL;
		            
		            let vExecuteSQL = '';
                    let vExecuteSQL = 'dbaccess intercard '||RUTA_DESTINO||SCRIPT_EJECUCION;
                    system vExecuteSQL;	

					LET vIndicadorProceso = '4';
                    ---------------------------------------------------------------------------------------------------------------            
			        --eliminacion de archivos
		            let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION;  
                    system vExecuteSQL;  
			       -------------------------------------------------------------------------------------------------------------
                    --- Genera dbload para la carga de registros a la tabla  destino
 	                LET vExecuteSQL = '';
                    LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_DESTINO||NOMBRE_ARCHIVO||vaniomes||'.unl' || "' delimiter '|' "|| '15'||                          
                                      "; INSERT INTO paso_mov_txns" || ";"||'"'||' > '||RUTA_DESTINO||SCRIPT_EJECUCION2||'file_mvs.txt';
                    SYSTEM vExecuteSQL; 
                    
					LET vIndicadorProceso = '5';
					
                    LET vExecuteSQL = ''; 
					LET vExecuteSQL = "dbload -d intercard -c "||RUTA_DESTINO||SCRIPT_EJECUCION2||"file_mvs.txt -l "||RUTA_DESTINO||SCRIPT_EJECUCION2||"err_tarj_paso.log -n "||CONTADOR_TRANSACCIONES||" -r";
                    SYSTEM vExecuteSQL;  
			 
       			    --eliminacion de archivos
		            let vExecuteSQL = '';
                    let vExecuteSQL ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION2||"file_mvs.txt";  
                    system vExecuteSQL; 
		           ------------------------------------------------------------------------------------------------------------
		           UPDATE STATISTICS MEDIUM FOR TABLE "informix".paso_mov_txns;           
				   ---------------------------------------------------------------------------------------------------------------- 
				    LET vIndicadorProceso = '6';
		
						       FOREACH  cur_F1_bin WITH HOLD FOR  	
								
		         				             SELECT    numtarjeta,idretailer,infreceptor,esnacional
		         				             INTO      vnumtarjeta ,vidretailer ,vinfreceptor,vesnacional
		         				             FROM paso_mov_txns  
											 WHERE bin = 'X'
											 ORDER BY numtarjeta 
								
								 	    IF (vsFlagEnTransaccion = 'F') THEN
                                           BEGIN WORK;
										   --TRACE 'T0_'|| vConteo;
                                           LET vsFlagEnTransaccion = 'V';
                                        END IF
                                         ----------
								        let vbin  =  substr(vnumtarjeta,1,8); 
								 
								 IF  (
								       (vidretailer = '3260825' OR vidretailer = '7888475' OR vidretailer = '7903733') AND
								       (UPPER(vinfreceptor)  LIKE '%COPPEL%') AND    vesnacional = 'V'
									 ) THEN
 
										LET vafiliacion = '1';  -- "Coppel.com"; 
									   
								 ELIF ( vidretailer   = '1090447' AND  vesnacional = 'V')  THEN  
 
										 LET vafiliacion = '2';  -- "Coppel App" ;
										 
								 ELIF  (
								         (vidretailer <> '3260825' AND vidretailer <> '1090447' AND vidretailer <> '8343798' AND 
										  vidretailer <> '7888475' AND vidretailer <> '7903733'
										  ) AND 
		                                      (UPPER(vinfreceptor) LIKE '%COPPEL%') AND vesnacional = 'V') THEN 
	 
										 LET vafiliacion = '3';  --  "Coppel Tda";
										 ---------------- NEW 
								 ELIF	  vidretailer = '7546881' THEN  LET vafiliacion = '4';  ---"Gate Retail" 
								 
								 ELIF	  vidretailer = '8103383' THEN  LET vafiliacion = '5';  ---"Retail In Motion" 										 
										----------------- 
								 ELSE 		 
										 LET vafiliacion = '6';  --  "Otro";
                                         
							    END IF; 		

     								        -------
										     UPDATE paso_mov_txns 
		                                        SET
												     bin =  vbin,
				                                     afiliacion = vafiliacion
		                                      WHERE  numtarjeta = vnumtarjeta AND 
											         idretailer = vidretailer AND 
													 infreceptor = vinfreceptor AND 
													 esnacional = vesnacional;
												 
													 LET vConteo = vConteo +1;  
													 
												    IF (vConteo >= 1000) THEN    
                                                         COMMIT WORK;
														 --TRACE 'T1_'|| vConteo;
                                                         LET vConteo = 0;
                        								 LET vsFlagEnTransaccion = 'F';                
                                                         CONTINUE FOREACH;
                                                    END IF;
           		 
							END FOREACH; 
					
                                --TRACE 'T2_'|| vConteo;
					
							          IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                                            COMMIT WORK;
                                            LET vsFlagEnTransaccion = 'F';
                                        END IF; 
										
										 UPDATE STATISTICS MEDIUM FOR TABLE "informix".paso_mov_txns;
										 
										 LET vIndicadorProceso = '7';
	         ---------------------------------------------------------------------------------------------------------------     
             ----------------------------------------------------------------------------------------------------------------- 
			   let vsql = '';
		          	let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||TIPO_PLANTILLA||vaniomes||'.txt   '||
		          	           ' SELECT Fecha,bin,codigoiso,metodocaptura,esnacional,codtran,  '||
							   ' CASE WHEN afiliacion = ''"'||'1'||'"''  THEN  ''"'||'Coppel.com'||'"''        '||
							   '      WHEN afiliacion = ''"'||'2'||'"''  THEN  ''"'||'Coppel App'||'"''        '||
							   '      WHEN afiliacion = ''"'||'3'||'"''  THEN  ''"'||'Coppel Tda'||'"''        '||
							   '      WHEN afiliacion = ''"'||'4'||'"''  THEN  ''"'||'Gate Retail'||'"''        '||
							   '      WHEN afiliacion = ''"'||'5'||'"''  THEN  ''"'||'Retail In Motion'||'"''        '||
							   '     ELSE ''"'||'Otro'||'"''  END AS Afiliacion,      '||
							   ' tipotransaccionpos, '||
							   ' tipotransaccionposdigitada, metodoidentificacion, motivo,  '||
							   '  COUNT(*)::integer AS transacciones, sum(nvl(monto_total,0)) AS monto_total     '||
							   ' FROM paso_mov_txns   '||
							   ' group by 1,2,3,4,5,6,7,8,9,10,11 ; ">'||RUTA_DESTINO||SCRIPT_EJECUCION3;
		          	system vsql;
 
		          	-----------------------------------------------------------------------------------------------------------------	
		              ---Asigancion de permisos del archivo .sql
		              let vsql ='';			
		              let vsql= 'chmod 777 ' ||RUTA_DESTINO||SCRIPT_EJECUCION3;
		              system vsql;
		              
		              let vsql = '';
                      let vsql = 'dbaccess intercard '||RUTA_DESTINO||SCRIPT_EJECUCION3;   
                      system vsql;	 
					  
					  LET vIndicadorProceso = '8';
                      ----------------------------------------------------------------------------------------------------------------
		          	--eliminacion de archivos
		              let vsql = '';
                      let vsql ='rm -f '||RUTA_DESTINO||SCRIPT_EJECUCION3; 
                      system vsql;
		              ---------------------------------------------------------------------------------------------------------------            
	                  ------------------------------------------------------------------
 
		    LET CODIGO_RETORNO = '00000';
		    LET  MENSAJE_RETORNO  = 'PROCESO EXITOSO';
		    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
 
END;
END PROCEDURE
---Coordinacion de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I
---Autor: Marcos Gerardo Ayala Ponce
---Fecha de creacion: 02/SEP/2021
---Fecha de modificacion: 31/MAY/2022
---Base de datos: intercard
---Este proceso corresponde al job 986
--  EXECUTE PROCEDURE "informix".sp_txns_pos_diaria('D','1');	
;

CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_iccat_v1(pempresa char(3), pnumcte char(9), pstatus char (3),pNumRegistros SMALLINT)
RETURNING char(9), char(104), char(4), char(40), char(16), char(1), char(3), char(20), char(60), char(1), char(1), char(1);   

DEFINE ccodret char(9);
DEFINE isql_err integer;
DEFINE cvnumcte char (20);

DEFINE cvproducto char(4);
DEFINE cvnombreproducto char(40);

DEFINE cvnomcliente char (104);
DEFINE cvnumtarjeta char (16);
DEFINE cvestatus_tar char (3);
DEFINE cvnumcuenta char (20);
DEFINE cvstatuscuenta char (60);
DEFINE cvtitular char (1);
DEFINE cvradiobuton char(1);
DEFINE cvtipotar char(1);
DEFINE cstatus_tarjeta char(1);

--@comment: Declaracion variables para tabla temporal 
DEFINE cv_trjasig_num_cte char (20);

DEFINE cv_producto char(4);
DEFINE cv_nombre_producto char(40);

DEFINE cv_cta_cuenta char (20);
DEFINE cv_ctast_descripcion char (60);
DEFINE cv_astrj_num_tarjeta char (16);
DEFINE cv_astrj_status_tar char(1);
DEFINE cv_trj_nombre char (104);
DEFINE cv_trj_codstatustarjeta char (3);
DEFINE cv_trj_titular char (1);

LET ccodret = "000000001"; -- NO TIENE TARJETAS 
LET cvnumcte = "";

LET cvproducto = "";
LET cvnombreproducto = "";

LET cvnomcliente = "";
LET cvnumtarjeta = "";
LET cvestatus_tar = "";
LET cvnumcuenta = "";
LET cvstatuscuenta = "";
LET cvtitular = "";
LET cvradiobuton = "T";
LET cvtipotar = '';
LET cstatus_tarjeta = '';

--@comment: Inicializar variables para tabla temporal 
LET cv_trjasig_num_cte = "";

LET cv_producto = "";
LET cv_nombre_producto = "";

LET cv_cta_cuenta = "";
LET cv_ctast_descripcion = "";
LET cv_astrj_num_tarjeta = "";
LET cv_astrj_status_tar = '';
LET cv_trj_nombre = "";
LET cv_trj_codstatustarjeta = "";
LET cv_trj_titular = "";

BEGIN

	ON EXCEPTION SET isql_err
		IF isql_err <> 0 THEN
			let ccodret = isql_err;
			RETURN ccodret, cvnomcliente, cvproducto, cvnombreproducto, cvnumtarjeta, cvtipotar, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cstatus_tarjeta;
		END IF;
	END EXCEPTION;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--SET DEBUG FILE TO '/informix/tmp/sp_consultartarjetas_debcred_iccat.out';
	--TRACE ON;

	--Validar y crear tabla temporal intercard:tmp_tarjetas_debcret_iccat
	--SET ISOLATION TO DIRTY READ;
	/*IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_tarjetas_debcret_iccat' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:"informix".tmp_tarjetas_debcret_iccat;
	END IF;*/
	DROP TABLE IF EXISTS tmp_tarjetas_debcret_iccat;

	CREATE TEMP TABLE tmp_tarjetas_debcret_iccat(
		numcte char(20), 

		producto char(4),
		nombre_producto char(40),

		nombre varchar(104), 
		num_tarjeta char(20),
		codstatustarjeta varchar(3),
		num_cuenta_credito char(20),
		descripcion char(60),
		titular varchar(1),
		habilitado char(1),
		tipo_tarjeta char(1),
		status_tar char(1)
	);

	--Obtener tarjetas de debito de las que el cliente es titular
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.producto, def.nombre, cta.cuenta, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_mae_estatus ctaest, bdicheq:'informix'.sc_tarjeta trjasig, bdicheq:'informix'.sc_producto def, intercard:'informix'.tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.num_cte = pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cta = ctaest.cod_estatus 
		AND cta.cuenta = trjasig.cuenta 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.producto = '2400' --AND trjasig.prodtarjeta = '2400'		
		--AND trjasig.prodtarjeta = def.producto
		AND cta.producto = def.producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, producto, nombre_producto, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'D', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de debito de otros clientes de la que el cliente es adicional
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.producto, def.nombre, cta.cuenta, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_mae_estatus ctaest, bdicheq:'informix'.sc_tarjeta trjasig, bdicheq:'informix'.sc_producto def, intercard:'informix'.tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.num_cte <> pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cta = ctaest.cod_estatus 
		AND cta.cuenta = trjasig.cuenta 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.producto = '2400' --AND trjasig.prodtarjeta = '2400'		
		--AND trjasig.prodtarjeta = def.producto
		AND cta.producto = def.producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, producto, nombre_producto, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'D', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de debito que el cliente ha otorado a otros clientes
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.producto, def.nombre, cta.cuenta, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_mae_estatus ctaest, bdicheq:'informix'.sc_tarjeta trjasig, bdicheq:'informix'.sc_producto def, intercard:'informix'.tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.num_cte = pnumcte AND trjasig.numcte <> pnumcte) 
		AND cta.status_cta = ctaest.cod_estatus 
		AND cta.cuenta = trjasig.cuenta 
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.producto = '2400' --AND trjasig.prodtarjeta = '2400'
		--AND trjasig.prodtarjeta = def.producto
		AND cta.producto = def.producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, producto, nombre_producto, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'D', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de credito de las que el cliente es titular
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.num_producto, def.nombre_prod, cta.num_credito, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicred:"informix".sd_maecred cta, bdicred:"informix".sd_tipocartera ctaest, bdicred:"informix".sd_tarjeta trjasig, bdicred:"informix".sd_definicion def, intercard:"informix".tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.numcte = pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cred = ctaest.status_cred 
		AND cta.num_credito = trjasig.num_credito 
		--AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (6001,7000,8100) --AND trjasig.prodtarjeta IN (6001,7000,8100)
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (7000,8100)
		--AND trjasig.prodtarjeta = def.num_producto 
		AND cta.num_producto = def.num_producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus 

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, producto, nombre_producto, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'C', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de credito de otros clientes de la que el cliente es adicional
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.num_producto, def.nombre_prod, cta.num_credito, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicred:"informix".sd_maecred cta, bdicred:"informix".sd_tipocartera ctaest, bdicred:"informix".sd_tarjeta trjasig, bdicred:"informix".sd_definicion def, intercard:"informix".tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte) 
		AND cta.status_cred = ctaest.status_cred 
		AND cta.num_credito = trjasig.num_credito 
		--AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (6001,7000,8100) --AND trjasig.prodtarjeta IN (6001,7000,8100)
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (7000,8100)
		--AND trjasig.prodtarjeta = def.num_producto 
		AND cta.num_producto = def.num_producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus 

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, producto, nombre_producto, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'C', cv_astrj_status_tar);
	END FOREACH

	--Obtener tarjetas de debito que el cliente ha otorado a otros clientes
	--SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD
		SELECT trjasig.numcte, cta.num_producto, def.nombre_prod, cta.num_credito, ctaest.descripcion, trjasig.num_tarjeta, trjasig.status_tar, trj.nombre, trj.codstatustarjeta, trj.titular 
		INTO cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_cta_cuenta, cv_ctast_descripcion, cv_astrj_num_tarjeta, cv_astrj_status_tar, cv_trj_nombre, cv_trj_codstatustarjeta, cv_trj_titular 
		FROM bdicred:"informix".sd_maecred cta, bdicred:"informix".sd_tipocartera ctaest, bdicred:"informix".sd_tarjeta trjasig, bdicred:"informix".sd_definicion def, intercard:"informix".tarjeta trj 
		WHERE cta.empresa = pempresa AND ctaest.empresa = pempresa AND trjasig.empresa = pempresa 
		AND (cta.numcte = pnumcte AND trjasig.numcte <> pnumcte) 
		AND cta.status_cred = ctaest.status_cred 
		AND cta.num_credito = trjasig.num_credito 
		--AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (6001,7000,8100) --AND trjasig.prodtarjeta IN (6001,7000,8100)
		AND (trjasig.tipo_tarjeta = 'T' OR trjasig.tipo_tarjeta = 'A') AND cta.num_producto IN (7000,8100)
		--AND trjasig.prodtarjeta = def.num_producto 
		AND cta.num_producto = def.num_producto
		AND trj.numtarjeta = trjasig.num_tarjeta AND trj.codstatusasignada = 'SIA' AND trj.codstatustarjeta = pstatus 

		INSERT INTO tmp_tarjetas_debcret_iccat(numcte, producto, nombre_producto, nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar)
		VALUES (cv_trjasig_num_cte, cv_producto, cv_nombre_producto, cv_trj_nombre, cv_astrj_num_tarjeta, cv_trj_codstatustarjeta, cv_cta_cuenta, cv_ctast_descripcion, cv_trj_titular, 'F', 'C', cv_astrj_status_tar);
	END FOREACH

	--Asignar en tabla temporal bandera de tarjeta habilitado/deshabilitado para activaciï¿½n
	UPDATE tmp_tarjetas_debcret_iccat tmp SET tmp.habilitado = 'T' WHERE tmp.numcte = pnumcte AND tmp.titular = 'T';
	UPDATE tmp_tarjetas_debcret_iccat tmp SET tmp.habilitado = 'T' WHERE tmp.numcte = pnumcte AND tmp.titular = 'A';
	--UPDATE intercard:"informix".tmp_tarjetas_debcret_iccat tmp SET tmp.habilitado = 'F' WHERE tmp.numcte <> pnumcte AND tmp.titular = 'T';

	--Retornar todas las tarjetas en la tabla temporal
	SET LOCK MODE TO WAIT 3;
	FOREACH 
		SELECT SKIP pNumRegistros FIRST 10 producto, nombre_producto ,nombre, num_tarjeta, codstatustarjeta, num_cuenta_credito, descripcion, titular, habilitado, tipo_tarjeta, status_tar
		INTO cvproducto, cvnombreproducto, cvnomcliente, cvnumtarjeta, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cvtipotar, cstatus_tarjeta
		FROM tmp_tarjetas_debcret_iccat
		
		LET ccodret = '000000000';
		
		RETURN ccodret, cvnomcliente, cvproducto, cvnombreproducto, cvnumtarjeta, cvtipotar, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cstatus_tarjeta WITH RESUME;
                --DROP TABLE tmp_tarjetas_debcret_iccat;
	END FOREACH;

	IF (ccodret = '000000001') THEN
		RETURN ccodret, cvnomcliente, cvproducto, cvnombreproducto, cvnumtarjeta, cvtipotar, cvestatus_tar, cvnumcuenta, cvstatuscuenta, cvtitular, cvradiobuton, cstatus_tarjeta;
                DROP TABLE tmp_tarjetas_debcret_iccat;
	END IF;

END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	Consulta tarjetas inactivas de dï¿½bito platino y crï¿½dito',
'AUTOR:		Felipe Monzï¿½n Mendoza',
'FECHA : 	26/05/2017',
'BD : 		intercard',

'OBJETIVO: 	Se retorna el campo: status_tar',
'MODIFICï¿½:	Keevyn Adrian Gil Valenzuela',
'FECHA : 	21/08/2017',
'BD : 		intercard',

'OBJETIVO: 	Se modifica codigo para dismunuir costo',
'MODIFICï¿½:	Ruben Antonio Ojeda Milan',
'FECHA : 	19/10/2017',
'BD : 		intercard',

'OBJETIVO: 	Se modifica cï¿½digo para validar producto desde sc_maechq en Dï¿½bito y sd_maecred en Crï¿½dito',
'MODIFICï¿½:	Josï¿½ Luis Polanco B.',
'FECHA : 	31/05/2017',
'BD : 		intercard',

'OBJETIVO: 	Se modifica cï¿½digo para Excluir Tarjetas de Crï¿½dito Clï¿½sica e Inhibir borrado de tabla temporal',
'MODIFICï¿½:	Josï¿½ Luis Polanco B.',
'FECHA : 	18/09/2019',
'BD : 		intercard';

CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_rep_iccat_v1(pempresa CHAR(3), pnumcte CHAR(9), pNumRegistros SMALLINT)
RETURNING char(9),char(104),char(16), char(1), char(50), char(4), char(40), char(20), char(60), char(1), char(3),char(9),char(9);

--@comment: Declaracion variables para responder
DEFINE ccodret char(9);
DEFINE isam_err integer;
DEFINE error_info varchar(104);
DEFINE isql_err integer;
DEFINE cnomcliente char (104);
DEFINE cnumtarjeta char (16);
DEFINE ctipotar char(1);
DEFINE cestatustar char (50);
-------
DEFINE cproductotar char(4);
DEFINE cnombreproductotar char(40);
-------
DEFINE cnumcuenta char (20);
DEFINE cnumcuentaAux char (20);
DEFINE cstatuscuenta char (3);
DeFINE cstatuscuentadesc char (60);
DEFINE ctitular char (1);
DEFINE ccodestatus char (3);
DEFINE cnombre1 char(20);
DEFINE cnombre2 char(20);
DEFINE paterno char(20);
DEFINE materno char(20);
DEFINE cnumCteTitularCuenta char(9);
DEFINE cnumCteTarjeta char(9);
DEFINE iExiste INTEGER;
DEFINE cExisteCta INTEGER;

LET ccodret = "000000000";
LET cnomcliente = "";
LET cnumtarjeta = "";
LET ctipotar = "";
LET cestatustar = "";
----------------------
LET cproductotar = "";
LET cnombreproductotar = "";
--------------
LET cnumcuenta = "";
LET cnumcuentaAux = "";
LET cstatuscuenta = "";
LET cstatuscuentadesc = "";
LET ctitular = "";
LET ccodestatus = "";
LET cnumCteTitularCuenta="";
LET cnumCteTarjeta="";
LET iExiste = 0;
LET cExisteCta = 0;

BEGIN

	ON EXCEPTION SET isql_err,isam_err, error_info
		IF isql_err <> 0 THEN
			LET ccodret = isql_err;
			LET cnomcliente = error_info;
			
			DROP TABLE IF EXISTS tbl_cuentascliente;
			DROP TABLE IF EXISTS tbl_tarjetascliente;
			
			RETURN ccodret,cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnombreproductotar, cnumcuenta, cstatuscuenta, ctitular, ccodestatus,cnumCteTitularCuenta,cnumCteTarjeta;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/tmp/sp_consultartarjetas_debcred_rep_iccat.out';
	--TRACE ON;

	DROP TABLE IF EXISTS tbl_cuentascliente;
	CREATE TEMP TABLE tbl_cuentascliente(
		numcte CHAR(20),
		producto CHAR(4),
		nombre_producto CHAR(40),
		statuscta CHAR(3),
		tipotar CHAR(1),
		cuenta CHAR(20)
	) WITH NO LOG;

	DROP TABLE IF EXISTS tbl_tarjetascliente;
	CREATE TEMP TABLE tbl_tarjetascliente(
		numtarjeta CHAR(20),
		cuenta CHAR(20),
		numcte CHAR(20)
	) WITH NO LOG;

	--Se llena tabla de paso con cuentas de debito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq mae1)}
		cta.num_cte, cta.producto, def.nombre, cta.status_cta, 'D', cta.cuenta
		INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicheq:'informix'.sc_maechq cta, bdicheq:'informix'.sc_producto def 
			WHERE cta.num_cte = pnumcte
			AND cta.producto = '2400' 
			and def.producto = cta.producto

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con cuentas de credito del cliente
	FOREACH WITH HOLD
	        SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)}
			cta.numcte, cta.num_producto, def.nombre_prod, cta.status_cred, 'C', cta.num_credito
			INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicred:'informix'.sd_maecred cta, bdicred:'informix'.sd_definicion def
			WHERE cta.numcte = pnumcte 
			AND cta.num_producto IN ('7000', '8100') 
			and cta.num_producto = def.num_producto

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con tarjetas de debito del cliente y de los clientes que tienen cuentas relacionadas al cliente titulares o adicionales
	FOREACH WITH HOLD
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'D'
	
		FOREACH WITH HOLD SELECT  {+INDEX(bdicheq:'informix'.sc_tarjeta ix_tarjeta4)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.cuenta = cnumcuenta
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				--MODIFICADO GABRIEL
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} 
				cta.num_cte, cta.producto, def.nombre, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta, bdicheq:'informix'.sc_producto def
				WHERE cta.cuenta = cnumcuenta 
				AND cta.producto = '2400' 
				AND cta.producto = def.producto
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

		END FOREACH;
		
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.cuenta
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')
				

				INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
				VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				--MODIFICADO GABRIEL
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} 
				cta.num_cte, cta.producto, def.nombre, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta, bdicheq:'informix'.sc_producto def
				WHERE cta.cuenta = cnumcuenta 
				AND cta.producto = '2400' 
				AND cta.producto = def.producto
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

	END FOREACH;

	FOREACH WITH HOLD 
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'C'
	
		--Se llena tabla de paso con tarjetas de debito del cliente y de los credito que tienen cuentas relacionadas al cliente titulares o adicionales
		FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta pry_tarjeta)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.num_credito = cnumcuenta 
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--MODIFICADO GABRIEL
			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)}
				cta.numcte, cta.num_producto, def.nombre_prod, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta, bdicred:'informix'.sd_definicion def
				WHERE cta.empresa = pempresa AND cta.num_credito = cnumcuenta 
				AND cta.num_producto IN ('7000', '8100') 
				AND cta.num_producto = def.num_producto
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

		END FOREACH;
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.num_credito
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				--MODIFICADO GABRIEL
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} 
				cta.numcte, cta.num_producto, def.nombre_prod, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta, bdicred:'informix'.sd_definicion def
				WHERE cta.empresa = pempresa AND cta.num_credito = cnumcuenta
				AND cta.num_producto IN ('7000', '8100') 
				AND cta.num_producto = def.num_producto
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

	END FOREACH;
	
	
	--Una vez obtenidos los datos anteriores se recorren tarjeta por tarjeta y se obtienen los datos faltantes para regresarlos en el retorno del SPL
	FOREACH WITH HOLD
			SELECT SKIP pNumRegistros FIRST 10
				trjasig.numtarjeta, trjasig.cuenta, trjasig.numcte, cta.numcte, cta.producto, cta.nombre_producto, cta.statuscta, cta.tipotar
			INTO cnumtarjeta, cnumcuenta, cnumCteTarjeta, cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar
			FROM 'informix'.tbl_tarjetascliente trjasig INNER JOIN 'informix'.tbl_cuentascliente cta
			ON cta.cuenta = trjasig.cuenta
			WHERE ((cta.numcte = pnumcte)
			OR (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte))
			ORDER BY cta.tipotar DESC, trjasig.numtarjeta ASC

		SELECT trj.nombre, trj.codstatustarjeta, trj.titular, trj.numtarjeta
		INTO cnomcliente, ccodestatus, ctitular, cnumtarjeta
		FROM 'informix'.tarjeta trj
		WHERE trj.numtarjeta = cnumtarjeta AND trj.codstatusasignada = 'SIA';

		SELECT trjest.codstatustarjeta, trjest.descstatustarjeta
		INTO ccodestatus, cestatustar
		FROM 'informix'.statustarjeta trjest
		WHERE trjest.codstatustarjeta = ccodestatus;

		IF TRIM(ctipotar) = 'D' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicheq:'informix'.sc_mae_estatus ctaest WHERE ctaest.cod_estatus = cstatuscuenta;
		ELIF TRIM(ctipotar) = 'C' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicred:'informix'.sd_tipocartera ctaest WHERE ctaest.status_cred = cstatuscuenta;
		END IF;

		LET cnombre1='';
		LET cnombre2='';
		LET paterno='';
		LET materno='';

		FOREACH
			SELECT FIRST 1 s.nombre1,s.nombre2,s.apaterno,s.amaterno
			INTO cnombre1,cnombre2,paterno,materno
			FROM "informix".solicitudtarjeta s INNER JOIN "informix".detalle_maquila d ON (s.idsolicitud = d.idsolicitud)
			WHERE s.numcuenta = cnumcuenta AND d.numtarjeta = cnumtarjeta
			ORDER BY s.fechasolicitud DESC
		END FOREACH
		--ExtracciÃ³n de nombre de tabla alterna
		IF TRIM(NVL(cnombre1,''))='' AND TRIM(NVL(cnombre2,''))='' THEN
			--SELECT s.nombre1,s.nombre2,s.apaterno,s.amaterno
			--INTO cnombre1,cnombre2,paterno,materno
			SELECT s.nombre1, SUBSTRING( TRIM(s.apaterno) FROM 1 FOR ( 20 - char_length(TRIM(s.nombre1)) ) ) AS apaterno
			INTO cnombre1,paterno
			FROM "informix".solicitudtarjeta s INNER JOIN bdicred:"informix".sd_credito_upgrade cu ON (s.numcliente = cu.numcte AND s.numcuenta = cu.num_credito)
			INNER JOIN intercard:"informix".detalle_maquila de ON (s.idsolicitud = de.idsolicitud AND de.numtarjeta = cnumtarjeta)
			WHERE cu.numero_credito_upgrade = cnumcuenta AND cu.numerotarjeta_upgrade = cnumtarjeta;
			
			--IF char_length(TRIM(NVL(cnombre1,'')))<=1 OR char_length(TRIM(NVL(paterno,'')))<=1 THEN	--Se modifica funcion
			IF LENGTH(TRIM(NVL(cnombre1,'')))<=1 OR LENGTH(TRIM(NVL(paterno,'')))<=1 THEN
				SELECT nombre1, SUBSTRING( TRIM(apell_paterno) FROM 1 FOR ( 20 - char_length(TRIM(nombre1)) ) ) AS apaterno
				INTO cnombre1,paterno
				FROM bdinteg:si_cliente WHERE numcte=pnumcte;
			END IF;
		END IF;
		
		IF TRIM(NVL(cnombre1,''))='' THEN
			LET cnombre1='-';
		END IF;
		IF TRIM(NVL(cnombre2,''))='' THEN
			LET cnombre2='-';
		END IF;
		IF TRIM(NVL(paterno,''))='' THEN
			LET paterno='-';
		END IF;
		IF TRIM(NVL(materno,''))='' THEN
			LET materno='-';
		END IF;
		LET cnomcliente = cnombre1||'|'||cnombre2||'|'||paterno||'|'||materno;

		IF cnumtarjeta IS NOT NULL THEN -- TARJETA != 'SIA'
			RETURN ccodret, cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnombreproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta WITH RESUME;
                        --DROP TABLE IF EXISTS tbl_cuentascliente;
                        --DROP TABLE IF EXISTS tbl_tarjetascliente;
		END IF;

		LET iExiste = iExiste + 1;

	END FOREACH
	
	DROP TABLE IF EXISTS tbl_cuentascliente;
    DROP TABLE IF EXISTS tbl_tarjetascliente;

	--En caso de que el cliente no tenga ninguna tarjeta
	IF iExiste = 0 THEN
		RETURN '000000001', 'No tiene tarjetas', cnumtarjeta, ctipotar, cestatustar, cproductotar, cnombreproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta;
                --DROP TABLE IF EXISTS tbl_cuentascliente;
                --DROP TABLE IF EXISTS tbl_tarjetascliente;
	END IF;

END
END PROCEDURE
;