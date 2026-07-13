CREATE PROCEDURE "informix".sp_omologa_tdc_can()
	RETURNING VARCHAR (5) AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;


	/* DEFINICION DE VARIABLES */
	
	DEFINE vTotreg_1  				INTEGER;
	DEFINE vtarjeta_1 				VARCHAR(16);
	DEFINE vtarjeta_2 				VARCHAR(16);
	DEFINE vtarjeta_3 				VARCHAR(16);
	DEFINE vtarjeta_4 				VARCHAR(16);
	DEFINE vCodigoRetorno			CHAR(5);
	DEFINE vMensaje 				CHAR(160);
	DEFINE ERROR_INFO 				VARCHAR(80);
	DEFINE ISAM_ERR 				INTEGER;
	DEFINE SQLERR 					INTEGER;
	DEFINE vnumTrnx					INTEGER;
	DEFINE vnumTrnx1				INTEGER;
	DEFINE vnumTrnx2				INTEGER;
	DEFINE conf_arch1				INTEGER;
	DEFINE conf_arch2				INTEGER;
	
	DEFINE RUTA_UNLOAD 				VARCHAR(30);
	DEFINE vNombreScript 			CHAR(100);
	DEFINE NomdownRet1 				VARCHAR(100);
	DEFINE NomdownRet2 				VARCHAR(100);
	DEFINE NomdownRet3 				VARCHAR(100);
	DEFINE NomdownRet				VARCHAR(100);
	DEFINE v_sql         			CHAR(250);
	
	DEFINE vDia						VARCHAR(2);
	DEFINE vMes						VARCHAR(2);
	DEFINE vAnio					VARCHAR(4);
	
	DEFINE val_dup					VARCHAR(16);
	DEFINE val_uno					INTEGER;


	/* INICIALIZACION DE VARIABLES */
	
	LET vTotreg_1 = 0;
	LET vtarjeta_1 = "";
	LET vtarjeta_2 = "";
	LET vtarjeta_3 = "";
	LET vtarjeta_4 = "";
	LET ERROR_INFO ='';
	LET ISAM_ERR = 0;
	LET SQLERR = 0;
	LET vCodigoRetorno = '';
	LET vnumTrnx = 0;
	LET vnumTrnx1 = 0;
	LET vnumTrnx2 = 0;
	LET conf_arch1 = 0;
	LET conf_arch2 = 0;
	
	LET RUTA_UNLOAD = '/RESPALDOSNEW/';
	LET vNombreScript = 'aux.sql';
	LET NomdownRet = '';
	LET v_sql = '';
	
	LET vDia ='';
	LET vMes = '';
	LET vAnio= '';
	
	LET  NomdownRet1 = '';
    LET  NomdownRet2 = '';
	LET  NomdownRet3 = ''; 
	
	LET val_dup = '';
	LET val_uno = 0;
	
	BEGIN
		
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
			
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO||' '||vMensaje;                
				END IF;
				RETURN vCodigoRetorno, vMensaje;
		END EXCEPTION;
		
			--SET DEBUG FILE TO  "/home/c90296115/sp_omologa_tdc_can.out";
			--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		TRUNCATE TABLE estatus_diferentes_tdc;
		
			--Obtiene el nombre del archivo
		LET vDia = LPAD(DAY(CURRENT),2,'0');  
		LET vMes = LPAD(MONTH(CURRENT),2,'0');
		LET vAnio = year(CURRENT);
		
	-----------------------------------------------Obtiene las tarjetas en estaus final del dÃÂ­a de ayer
	
		SELECT tarjeta FROM bitacoracambiosstatustarjeta 
		WHERE fechahora >=  TODAY -1
		AND codstatustarjetanvo in ('CAN', 'DES', 'EXT', 'ROB', 'FAL', 'DAN')
		INTO TEMP ev_tars WITH NO LOG;
		
		CREATE INDEX "informix".idx_tDDyTDC_eFin ON ev_tars(tarjeta) ONLINE;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".ev_tars; 
		
		
		-----Consulta el total de tranasacciones
				SELECT COUNT(*) 
				INTO vnumTrnx
				FROM ev_tars;
		
		-----Valida si hay transacciones comienza el proceso de lo contrario termina el bloque 1
		IF (vnumTrnx > 0)THEN 
		
		---------------------------------------------------Valida que no esten 2 veces en tarjeta cuenta
		FOREACH WITH HOLD 
		
		SELECT tarjeta 
		INTO val_dup
		FROM ev_tars
		
		SELECT count(*) 
		INTO val_uno
		FROM tarjetacuenta
		WHERE numtarjeta in (val_dup);
		
		IF(val_uno >= 2)THEN 
		DELETE FROM ev_tars WHERE tarjeta in (val_uno);
		INSERT INTO intercard:tarcuenta_dupli(numtar, fecha_found) VALUES(val_dup,CURRENT);
		END IF;
		
		END FOREACH;
		
	------------------------------------------------------------------------------------------->Valida en credito
		SELECT tarjeta FROM ev_tars 
		WHERE tarjeta in (SELECT  num_tarjeta
		FROM bdicred:sd_tarjeta 
		WHERE status_tar in ('A','I'))
		INTO TEMP uno WITH NO LOG;
		
		CREATE INDEX "informix".idx_valCred ON uno (tarjeta) ONLINE;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".uno;

		SELECT COUNT(*) 
		INTO vnumTrnx1
		FROM uno;
		
		IF (vnumTrnx1 > 0)THEN 
				
			BEGIN WORK;
				----------UPDATE Y COMMIT
				FOREACH WITH HOLD 
				
				SELECT tarjeta
				INTO vtarjeta_1
				FROM uno
				
				Update bdicred:sd_tarjeta set status_tar  = 'C' where  num_tarjeta  in (vtarjeta_1);
				
				INSERT INTO intercard:estatus_diferentes_tdc(numtar) 
				VALUES(vtarjeta_1);
				
				LET vTotreg_1 = vTotreg_1 + 1;
				
				IF(vTotreg_1 >= 100 OR vTotreg_1 = vnumTrnx1) THEN  
					LET vTotreg_1 = 0;
					COMMIT;
					BEGIN WORK;
				END IF;
				END FOREACH;
			COMMIT;
		
		LET NomdownRet = '1-A-I_bdicred_CAN_interact-'||vDia||vMes||vAnio;
						
		LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;'||
					'UNLOAD TO '||RUTA_UNLOAD||TRIM(NomdownRet)||'.unl '||
					'SELECT * FROM estatus_diferentes_tdc;">'
					||RUTA_UNLOAD||vNombreScript; 
								  
		System v_sql;
						
		LET v_sql = '';
		------------EJECUTA Descarga
		LET v_sql = 'dbaccess intercard '||RUTA_UNLOAD||vNombreScript; 
		System v_sql; 	
		
		-- BORRADO DE SCRIPTS GENERADOS EN EL PROCESO
		LET v_sql = '';
		LET v_sql = 'rm '||RUTA_UNLOAD||vNombreScript;
		System v_sql;				
				
			---LET vMensaje = 'Bloque 1';
		
		TRUNCATE TABLE estatus_diferentes_tdc;	
		
		LET vTotreg_1 = 0;
		
		LET conf_arch1 = 1;
		
		END IF;
		------------------------------------------------------------------------------------------>Valida Cheques
		SELECT tarjeta  FROM ev_tars
		WHERE tarjeta in (SELECT  num_tarjeta
		FROM bdicheq:sc_tarjeta 
		WHERE status_tar in ('A','I'))
		INTO TEMP dos WITH NO LOG;
		
		CREATE INDEX "informix".idx_deb ON dos(tarjeta) ONLINE;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".dos; 
		
		SELECT COUNT(*) 
		INTO vnumTrnx2
		FROM dos;
		
		IF (vnumTrnx2 > 0)THEN 
		
				BEGIN WORK;
				----------UPDATE Y COMMIT
				FOREACH WITH HOLD 
				
				SELECT tarjeta
				INTO vtarjeta_2
				FROM dos
				
				Update bdicheq:sc_tarjeta set status_tar  = 'C' where  num_tarjeta  in (vtarjeta_2);
				
				INSERT INTO intercard:estatus_diferentes_tdc(numtar) 
				VALUES(vtarjeta_2);
				
				LET vTotreg_1 = vTotreg_1 + 1;
				
				IF(vTotreg_1 >= 100 OR vTotreg_1 = vnumTrnx2) THEN  
					LET vTotreg_1 = 0;
				COMMIT;
					BEGIN WORK;
				END IF;
				END FOREACH;
			COMMIT;
		--LET vMensaje = 'Bloque 2';
		
		LET NomdownRet1 = '2-A-I_bdicheq_CAN_interact'||vDia||vMes||vAnio;
						
		LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;'||
					'UNLOAD TO '||RUTA_UNLOAD||TRIM(NomdownRet1)||'.unl '||
					'SELECT * FROM estatus_diferentes_tdc;">'
					||RUTA_UNLOAD||vNombreScript; 
								  
		System v_sql;
						
		LET v_sql = '';
		------------EJECUTA Descarga
		LET v_sql = 'dbaccess intercard '||RUTA_UNLOAD||vNombreScript; 
		System v_sql; 	
		
		-- BORRADO DE SCRIPTS GENERADOS EN EL PROCESO
		LET v_sql = '';
		LET v_sql = 'rm '||RUTA_UNLOAD||vNombreScript;
		System v_sql;
		
			TRUNCATE TABLE estatus_diferentes_tdc;
			
			LET conf_arch2 = 1;
		END IF;
	END IF;		
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso '||'archivos generados: '|| conf_arch1+conf_arch2;			
		RETURN vCodigoRetorno,vMensaje;
		
	END
END PROCEDURE
DOCUMENT
'Coordinacion de Operaciones y Servidores distribuidos LV 1 | Gerencia Mantenimiento I',
'Autor: Miguel Angel Lopez Galvan',
'RQI - 34 028',
'28 de mayo de 2024',
'Version    1.00.00.00',
'RQI - 34 033 - OPT al SP: sp_omologa_tdc_can validacion tarjeta_cuenta ',
'04 de julio de 2024',
'VersiÃÂ³n    1.00.00.01';

CREATE PROCEDURE "informix".sp_msi_principal()
    RETURNING VARCHAR(5) AS rCodigoRetorno, VARCHAR(250) AS rMensajeRetorno;

    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(150);
    
    DEFINE vCODIGO_RETORNO VARCHAR(5);
    DEFINE vMENSAJE_RETORNO VARCHAR(250);
    DEFINE RUTA_ORIGEN VARCHAR(50);
    DEFINE vIndicadorProceso CHAR(1);
    DEFINE vPrefijoArchivo VARCHAR(15); 
    DEFINE vRutaArchivo VARCHAR(100);
    DEFINE vNombreProceso VARCHAR(15);
    DEFINE vNombreArchivo VARCHAR(100);
    DEFINE vExisteArchivo CHAR(1);
    DEFINE vNumeroLineas INTEGER;
    DEFINE vTotalRegistros INTEGER;
    
    LET SQLERR = '';
    LET ISAM_ERR = '';
    LET ERROR_INFO = '';
    
    LET vCODIGO_RETORNO = '00000';
    LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vIndicadorProceso = '0';
    LET vPrefijoArchivo = '';
    LET vRutaArchivo = '';
    LET vNombreArchivo = '';
    LET vNombreProceso = '';
    LET vExisteArchivo = '';
    LET vNumeroLineas = '';
    LET vTotalRegistros = 0;
    
    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_msi_principal.out";
    --TRACE ON;

    BEGIN 

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO

            --SET DEBUG FILE TO RUTA_ORIGEN || "excep_sp_msi_principal.err.out" WITH APPEND;
            --TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||CURRENT||' '||'vIndicadorProceso =>'||vIndicadorProceso;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
            
			RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;

		END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        SELECT nombre_proceso, prefijo_archivo, ruta_destino
            INTO vNombreProceso, vPrefijoArchivo, vRutaArchivo
        FROM intercard:tbl_catalogo_archivos_procesar
        WHERE empresa = '001' 
			AND nombre_proceso = 'msi';

        IF ( vRutaArchivo IS NULL OR vNombreProceso IS NULL OR vPrefijoArchivo IS NULL ) THEN
            LET vCODIGO_RETORNO = '00001';            
            LET vMENSAJE_RETORNO = 'Falta la informaciÃ³n del y ruta del proceso.';
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
        END IF;
        
        EXECUTE PROCEDURE intercard:"informix".sp_msi_validar_archivo_prod( vRutaArchivo, vNombreProceso, vPrefijoArchivo )
            INTO vCODIGO_RETORNO, vMENSAJE_RETORNO, vNombreArchivo;

        IF ( vCODIGO_RETORNO <> '00000') THEN
            --ARCHIVO NO TRANSFERIDO O VACIO
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO||'SP_2';
        END IF;
        
        EXECUTE PROCEDURE intercard:"informix".sp_msi_dbload_archivos ( vRutaArchivo, vNombreProceso, vNombreArchivo )
            INTO vCODIGO_RETORNO, vMENSAJE_RETORNO;

        IF ( vCODIGO_RETORNO <> '00000') THEN
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO||'SP_3';
        END IF;
        
        SELECT numero_lineas
            INTO vNumeroLineas
        FROM intercard:"informix".tbl_catalogo_archivos_procesar 
            WHERE nombre_proceso ='msi';
        
        SELECT COUNT(*)
            INTO vTotalRegistros
        FROM tbl_paso_msi_info_comercios_afiliados;
        
        IF ( vNumeroLineas <> vTotalRegistros ) THEN
        
			LET vCODIGO_RETORNO = '00001';
            --ESTE ARCHIVO ES CREADO EN EL PROCEDIMIENTO ALMACENADO: sp_msi_dbload_archivos
            LET vMENSAJE_RETORNO = 'Error Carga InformaciÃ³n. Consultar: error_ejecucion_'||vNombreProceso||'.log';
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
        
		ELSE 
		
			-- 13/08/2024: SE AGREGA EL SP sp_msi_modifica_registros PARA AGREGAR, ACTUALIZAR O ELIMINAR LOS REGISTROS DE LA TABLA tbl_msi_info_comercios_afiliados
			EXECUTE PROCEDURE intercard:"informix".sp_msi_modifica_registros()
				INTO vCODIGO_RETORNO, vMENSAJE_RETORNO;
				
			IF ( vCODIGO_RETORNO <> '00000') THEN
				RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO||'SP_4';
			END IF;
		
		END IF;
		
        EXECUTE PROCEDURE intercard:"informix".sp_msi_generar_archivo( vRutaArchivo, vNombreArchivo )
            INTO vCODIGO_RETORNO, vMENSAJE_RETORNO;
            
        IF ( vCODIGO_RETORNO <> '00000') THEN
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO||'SP_5';
        END IF;
        
        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
		
	  TRUNCATE TABLE "informix".tbl_paso_msi_info_comercios_afiliados;

    END
END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 13 de Agosto del 2024',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Componente principal para generar el archivo E17 para las afiliaciones de comercios participantes de meses sin intereses (MSI)';

CREATE PROCEDURE "informix".sp_msi_dbload_archivos(pRutaArchivo VARCHAR(80), pNombreProceso VARCHAR(15), pNombreArchivo VARCHAR(50))
	RETURNING VARCHAR (5) AS rCodigoRetorno, VARCHAR(250) AS rMensajeRespuesta;

    DEFINE SQLERR INTEGER;
	DEFINE ISAM_ERR INTEGER;
	DEFINE ERROR_INFO VARCHAR(250);    
    DEFINE vCODIGO_RETORNO VARCHAR(5);
    DEFINE vMENSAJE_RETORNO VARCHAR(250);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;
    DEFINE RUTA_ORIGEN VARCHAR(100);
    DEFINE vExecuteSQL LVARCHAR(1000);
    DEFINE vNombreTablaCarga VARCHAR(90);
	DEFINE vTablaCargaE17 VARCHAR(90);
	DEFINE vNombreTablaCargaArchivo VARCHAR(90);
    DEFINE vCaracterDelimitador CHAR(1);    
    DEFINE vNomCarga_DBLOAD VARCHAR(20);
    DEFINE vNomError_DBLOAD VARCHAR(20);
    DEFINE vNomError_Ejecucion VARCHAR(16);
    DEFINE vNombreArchivo VARCHAR(50);
    DEFINE vNombreCompScript LVARCHAR(450); --suma de pRutaArchivo + vNomCarga_DBLOAD + pNombreArchivo
    DEFINE vNombreCompTXT VARCHAR(120);
    DEFINE vNombreCompLog VARCHAR(120);
    DEFINE vNombreEjecucionLog VARCHAR(120);
    DEFINE vNombreArchivoLog VARCHAR(120);
    
	LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    LET vCODIGO_RETORNO = '';
    LET vMENSAJE_RETORNO = '';
    LET CONTADOR_TRANSACCIONES = 1000;
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vExecuteSQL = '';    
	LET vNombreTablaCarga = '';
	LET vTablaCargaE17 = '';
	LET vNombreTablaCargaArchivo = '';
    LET vCaracterDelimitador = '';
	LET vNomCarga_DBLOAD = 'dbload_carga_';
	LET vNomError_DBLOAD = 'dbload_error_';
	LET vNomError_Ejecucion = 'error_ejecucion_';
    
    LET vNombreCompScript = TRIM(pRutaArchivo)||vNomCarga_DBLOAD||LOWER(pNombreProceso)||'.sql';
	LET vNombreCompTXT = TRIM(pRutaArchivo)||vNomCarga_DBLOAD||LOWER(pNombreProceso)||'.txt';
	LET vNombreCompLog = TRIM(pRutaArchivo)||vNomError_DBLOAD||LOWER(pNombreProceso)||'.log';
	LET vNombreEjecucionLog = TRIM(pRutaArchivo)||vNomError_Ejecucion||LOWER(pNombreProceso)||'.log';
	LET vNombreArchivoLog = vNomError_Ejecucion||LOWER(pNombreProceso)||'.log';
    
    LET vNombreArchivo = pNombreArchivo;
   
    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_msi_dbload_archivos.out";
    --TRACE ON;

	BEGIN
        
	 
		
	ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            --SET DEBUG FILE TO RUTA_ORIGEN || "excep_sp_msi_dbload_archivos.err.out" WITH APPEND;
            --TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vMENSAJE_RETORNO = 'Archivo '||vNombreArchivo||' Proceso '||vCODIGO_RETORNO||' SQL_ERR '||SQLERR||' '||'Leer archivo '||vNombreArchivoLog||' '||CURRENT;
                LET vCODIGO_RETORNO = SQLERR;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
	END EXCEPTION
      
	  --TRUNCATE TABLE tbl_generacion_msi_arch_e17;
	  
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        LET vCaracterDelimitador = '|';
		--13/02/2024: SE CAMBIA EL NOMBRE DE LA TABLA PARA CARGAR LA INFORMACION
        LET vNombreTablaCarga = 'tbl_paso_msi_info_comercios_afiliados';
        LET vNomCarga_DBLOAD = 'dbload_carga_';
        LET vNomError_DBLOAD = 'dbload_error_';
		
		--LET vNombreTablaCargaArchivo = 'tbl_generacion_msi_arch_e17';
        
        LET vCODIGO_RETORNO = '00001';
        LET vMENSAJE_RETORNO = 'Inicializar tabla para guardar informacion.';

        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo TRUNCATE TABLE intercard:'||vNombreTablaCarga||' DROP STORAGE  > '|| vNombreCompScript;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'dbaccess intercard '||vNombreCompScript;
        SYSTEM vExecuteSQL;
		
        LET vExecuteSQL = '';
        LET vExecuteSQL = "rm -f "||vNombreCompScript;
        SYSTEM vExecuteSQL;
        
        LET vCODIGO_RETORNO = '00002';
        LET vMENSAJE_RETORNO = 'Crear archivo para leer la informacion y generar script.';

        LET vCODIGO_RETORNO = '00003';
        LET vMENSAJE_RETORNO = 'Eliminacion de filas sin informacion ingresada.';
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = "  sed '/#/ d' " ||pRutaArchivo||vNombreArchivo|| " > "||pRutaArchivo||vNombreArchivo||'_tmp.log';
        SYSTEM vExecuteSQL;
		
		--ESTA INSTRUCCION INTENTA AGREGAR UN SALTO DE LINEA AL ARCHIVO (INCOMPLETO)
		/*
        LET vExecuteSQL = '';
        LET vExecuteSQL = "  sed -i '$s/$/\n/' " ||pRutaArchivo||vNombreArchivo|| " > "||pRutaArchivo||vNombreArchivo||'_tmp.log';
        SYSTEM vExecuteSQL;
        */
		
        LET vCODIGO_RETORNO = '00004';
        LET vMENSAJE_RETORNO = 'Renombrar archivo temporal a archivo final.';
		
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'mv '||pRutaArchivo||vNombreArchivo||'_tmp.log '||pRutaArchivo||vNombreArchivo;
        SYSTEM vExecuteSQL;

        LET vCODIGO_RETORNO = '00005';
        LET vMENSAJE_RETORNO = 'Creacion de archivo sql para registrar informacion.';
		
		--13/02/2024: SE SUSTITUYE EL NOMBRE DE LA TABLA POR LA VARIABLE vNombreTablaCarga PARA REALIZAR EL INSERT EN LA TABLA DE PASO
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "FILE '||pRutaArchivo||vNombreArchivo||' DELIMITER '||"'"||vCaracterDelimitador||"'"||'20;'||
        '       INSERT INTO '||vNombreTablaCarga||';" > '||vNombreCompTXT;
        SYSTEM vExecuteSQL;
        
        LET vCODIGO_RETORNO = '00006';
        LET vMENSAJE_RETORNO = 'Ejecucion del archivo anterior';
		
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||vNombreCompTXT||" -l "||vNombreCompLog||" -n "||CONTADOR_TRANSACCIONES||" -r > "||vNombreEjecucionLog;
        SYSTEM vExecuteSQL;
        
        LET vCODIGO_RETORNO = '00007';
        LET vMENSAJE_RETORNO = 'Eliminar archivos de scripts de carga - ejecucion';
        
         LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f '||vNombreCompTXT ||' '||vNombreCompLog;
        SYSTEM vExecuteSQL;
    
        LET vCODIGO_RETORNO = '00000';
        LET vMENSAJE_RETORNO = 'Generacion Archivo E17: '||pNombreArchivo;
		
        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;   
        
		
		
		
    END

END PROCEDURE
DOCUMENT
'#1',
'Base de datos: intercard',
'Fecha de creacion: 15 de febrero del 2022',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Guarda la informacion del archivo entregado por el Area de Alianzas y',
' posteriormente sea proceso para generar el archivo E17 ',
'#2',
'Fecha de modificacion: 01 de agosto del 2022',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Se actualizan las columnas creadas en la tabla tbl_msi_info_comercios_afiliados para considerar',
'los dos nuevos campos (bin_participante y cuenta_clabe)',
'#3',
'Fecha de modificacion: 13 de Agosto del 2024',
'Autor: Cristian Ariel Meza Martinez',
'CoordinaciÃ³n de AdministraciÃ³n de Tarjetas e Interfaces Transaccionales - CATIT',
'Descripcion: Se modifica la logica del proceso, agregando la tabla de paso tbl_paso_msi_info_comercios_afiliados ',
'para la carga de informacion.';

CREATE PROCEDURE "informix".sp_msi_modifica_registros()
	RETURNING VARCHAR(5) AS rCODIGO_RETORNO, VARCHAR(250) AS rMENSAJE_RESPUESTA;
	
	--VARIABLES DE CONTROL DE EXCEPCIONES
	DEFINE SQLERR INTEGER;
	DEFINE ISAM_ERR INTEGER;
	DEFINE ERROR_INFO VARCHAR(250);    

	--VARIABLES DE RETORNO
    DEFINE vCODIGO_RETORNO VARCHAR(5);
    DEFINE vMENSAJE_RETORNO VARCHAR(250);

	--VARIABLE DE RUTA
    DEFINE RUTA_ORIGEN VARCHAR(100);
	
	--VARIABLES DE CAMPOS DE TABLA DE PASO
	DEFINE vNum_serial_comercio			INTEGER;
	DEFINE vIdentificador_registro      VARCHAR(1);
	DEFINE vClave_promocion        	    VARCHAR(10);
	DEFINE vClave_afiliacion       	    VARCHAR(8); 
	DEFINE vFecha_inicio_prom      	    VARCHAR(10);
	DEFINE vFecha_termino_prom     	    VARCHAR(10);
	DEFINE vMov_promocion          	    VARCHAR(2); 
	DEFINE vCve_tipo_promocion     	    VARCHAR(2); 
	DEFINE vNum_meses_dif_compra		VARCHAR(2); 
	DEFINE vNum_meses_a_cobrar     	    VARCHAR(2); 
	DEFINE vPcte_sobretasa         	    VARCHAR(4); 
	DEFINE vMonto_minimo           	   	VARCHAR(9); 
	DEFINE vId_institucion         	    VARCHAR(6); 
	DEFINE vCuenta_cheques         	    VARCHAR(8); 
	DEFINE vRespuesta_promo        	    VARCHAR(2); 
	DEFINE vIva_promocion          	   	VARCHAR(4); 
	DEFINE vBin_participante       	    VARCHAR(8);
	DEFINE vCuenta_clabe           	    VARCHAR(18);
	DEFINE vEspacio_relleno        	    VARCHAR(26);
	DEFINE vFin_archivo            	    VARCHAR(1);
	DEFINE iContador_pay                INTEGER;
	DEFINE vconteo_antes                INTEGER;
	DEFINE vTotal                       INTEGER;
	DEFINE vAlta                        INTEGER;
	DEFINE vBaja                        INTEGER;
	DEFINE vMod                         INTEGER; 
	DEFINE vNp_alta 					INTEGER;
	DEFINE vNp_baja						INTEGER;
	DEFINE vNp_modificacion             INTEGER;
	
	
	LET vBaja                           = 0;
	LET vAlta                           = 0;
	LET vMod                            = 0;
	LET vNp_alta						= 0;
	LET vNp_baja                        = 0;
	LET vNp_modificacion                = 0;
    LET vconteo_antes                   = 0;
	LET vTotal                          = 0;
    LET iContador_pay                   = 0;
	LET SQLERR 							= '';
	LET ISAM_ERR 						= '';
	LET ERROR_INFO 						= '';
	
	LET vCODIGO_RETORNO					= '00000';
    LET vMENSAJE_RETORNO 				= 'Proceso exitoso.';
	
	LET RUTA_ORIGEN 					= '/RESPALDOSNEW/';
	
	LET vNum_serial_comercio			=0;
	LET vIdentificador_registro			='';
	LET vClave_promocion				='';
	LET vClave_afiliacion				=''; 
	LET vFecha_inicio_prom				=''; 
	LET vFecha_termino_prom				='';
	LET vMov_promocion					='';
	LET vCve_tipo_promocion				=''; 
	LET vNum_meses_dif_compra			=''; 
	LET vNum_meses_a_cobrar				=''; 
	LET vPcte_sobretasa					=''; 
	LET vMonto_minimo					=''; 
	LET vId_institucion					=''; 
	LET vCuenta_cheques					=''; 
	LET vRespuesta_promo				=''; 
	LET vIva_promocion					=''; 
	LET vBin_participante				=''; 
	LET vCuenta_clabe					=''; 
	LET vEspacio_relleno				='';
	LET vFin_archivo					='';
	
    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_msi_modifica_registros.out";
    --TRACE ON;

	BEGIN
	
	    ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO

			--SET DEBUG FILE TO RUTA_ORIGEN || "excep_sp_msi_modifica_registros.err.out" WITH APPEND;
			--TRACE ON;
			
			IF ( SQLERR <> 0 ) THEN
				LET vCODIGO_RETORNO = SQLERR;
				LET vMENSAJE_RETORNO = ISAM_ERR || ' ' || ERROR_INFO || ' ' || CURRENT;
			END IF;
         
         RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
        
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--SE PUEDE UTILIZAR ESTA VALIDACION EN CASO DE QUE REQUIERAN PONER PARAMETROS AL SP
		
/* 		--SE VALIDA SI LOS PARAMETROS SE ENCUENTRAN NULOS O VACIOS
		IF ( pNombreProceso IS NULL OR pNombreProceso = '' OR pNombreArchivo IS NULL OR pNombreArchivo = '') THEN
            LET vCODIGO_RETORNO = '00001';            
            LET vMENSAJE_RETORNO = 'El parametro pNombreProceso o pNombreArchivo se encuentra nulo o sin informacion.';
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
        END IF; */
				
		--CICLO PARA MODIFICAR LOS REGISTROS DE ACUERDO AL ESTATUS DE LA TABLA DE PASO
		
		BEGIN WORK;
		
		 SELECT NVL(COUNT(*),0) INTO vconteo_antes FROM intercard:tbl_msi_info_comercios_afiliados;
		
		UPDATE "informix".MSI_CONTROL_REG_E17
		SET numero_afiliaciones = 0;
		 
		FOREACH WITH HOLD
		
			--SE OBTIENEN LOS MOVIMIENTOS DE LA TABLA DE PASO
			SELECT num_serial_comercio,identificador_registro,clave_promocion,clave_afiliacion,fecha_inicio_prom,fecha_termino_prom,mov_promocion,cve_tipo_promocion,num_meses_dif_compra,num_meses_a_cobrar,pcte_sobretasa,monto_minimo,id_institucion,cuenta_cheques,respuesta_promo,iva_promocion,bin_participante,cuenta_clabe,espacio_relleno,fin_archivo
				INTO vNum_serial_comercio,vIdentificador_registro,vClave_promocion,vClave_afiliacion,vFecha_inicio_prom,vFecha_termino_prom,vMov_promocion,vCve_tipo_promocion,vNum_meses_dif_compra,vNum_meses_a_cobrar,vPcte_sobretasa,vMonto_minimo,vId_institucion,vCuenta_cheques,vRespuesta_promo,vIva_promocion,vBin_participante,vCuenta_clabe,vEspacio_relleno,vFin_archivo
			FROM "informix".tbl_paso_msi_info_comercios_afiliados
		
		
			--MOVIMIENTO DE BAJA
			IF  ( vMov_promocion = '00' ) THEN
							
				IF EXISTS ( 
				
					SELECT clave_promocion 
					FROM tbl_msi_info_comercios_afiliados 
					WHERE identificador_registro = vIdentificador_registro
					AND clave_promocion = vClave_promocion
					AND clave_afiliacion = vClave_afiliacion
					AND cuenta_clabe = vCuenta_clabe
					)  THEN
					
				
				DELETE FROM "informix".tbl_msi_info_comercios_afiliados
				WHERE identificador_registro = vIdentificador_registro
					AND clave_promocion = vClave_promocion
					AND clave_afiliacion = vClave_afiliacion
					AND cuenta_clabe = vCuenta_clabe;
					
				ELSE 
			 
					LET vNp_baja  = vNp_baja + 1 ;
					
					DELETE FROM "informix".tbl_paso_msi_info_comercios_afiliados
					WHERE identificador_registro = vIdentificador_registro
					AND clave_promocion = vClave_promocion
					AND clave_afiliacion = vClave_afiliacion
					AND cuenta_clabe = vCuenta_clabe;
					
				 
					
					
				
					
				END IF;
	        
				
			 --MOVIMIENTO DE ALTA	
			 ELIF ( vMov_promocion = '01' ) THEN 
			
				IF ( NOT EXISTS ( 
					SELECT clave_promocion 
					FROM tbl_msi_info_comercios_afiliados 
					WHERE identificador_registro = vIdentificador_registro
					AND clave_promocion = vClave_promocion
					AND clave_afiliacion = vClave_afiliacion
					AND cuenta_clabe = vCuenta_clabe
					) ) THEN
			
					INSERT INTO "informix".tbl_msi_info_comercios_afiliados (num_serial_comercio,identificador_registro,clave_promocion,clave_afiliacion,fecha_inicio_prom,fecha_termino_prom,mov_promocion,cve_tipo_promocion,num_meses_dif_compra,num_meses_a_cobrar,pcte_sobretasa,monto_minimo,id_institucion,cuenta_cheques,respuesta_promo,iva_promocion,bin_participante,cuenta_clabe,espacio_relleno,fin_archivo)
					VALUES(vNum_serial_comercio,vIdentificador_registro,vClave_promocion,vClave_afiliacion,vFecha_inicio_prom,vFecha_termino_prom,vMov_promocion,vCve_tipo_promocion,vNum_meses_dif_compra,vNum_meses_a_cobrar,vPcte_sobretasa,vMonto_minimo,vId_institucion,vCuenta_cheques,vRespuesta_promo,vIva_promocion,vBin_participante,vCuenta_clabe,vEspacio_relleno,vFin_archivo);
			
				
				ELSE 
						 
					LET vNp_alta  = vNp_alta + 1 ;
					
					DELETE FROM "informix".tbl_paso_msi_info_comercios_afiliados
					WHERE identificador_registro = vIdentificador_registro
					AND clave_promocion = vClave_promocion
					AND clave_afiliacion = vClave_afiliacion
					AND cuenta_clabe = vCuenta_clabe;
						
						
					
						
				END IF;
				
			 --MOVIMIENTO DE MODIFICACION
			 ELIF ( vMov_promocion = '02' ) THEN 
			 
			 IF EXISTS ( 
				
					SELECT clave_promocion 
					FROM tbl_msi_info_comercios_afiliados 
					WHERE identificador_registro = vIdentificador_registro
					AND clave_promocion = vClave_promocion
					AND clave_afiliacion = vClave_afiliacion
					AND cuenta_clabe = vCuenta_clabe
					)  THEN
					
			 ----Agregar Commite cada 1000
				UPDATE "informix".tbl_msi_info_comercios_afiliados
				SET mov_promocion = '02',
					fecha_inicio_prom = vFecha_inicio_prom,
					fecha_termino_prom = vFecha_termino_prom,
					mov_promocion = vMov_promocion,
					cve_tipo_promocion = vCve_tipo_promocion,
					num_meses_dif_compra = vNum_meses_dif_compra,
					num_meses_a_cobrar = vNum_meses_a_cobrar,
					pcte_sobretasa = vPcte_sobretasa,
					monto_minimo = vMonto_minimo,
					id_institucion = vId_institucion,
					cuenta_cheques = vCuenta_cheques,
					respuesta_promo = vRespuesta_promo,
					iva_promocion = vIva_promocion,
					bin_participante = vBin_participante,
					cuenta_clabe = vCuenta_clabe,
					espacio_relleno = vEspacio_relleno,
					fin_archivo = vFin_archivo
				 WHERE identificador_registro = vIdentificador_registro
					AND clave_promocion = vClave_promocion
					AND clave_afiliacion = vClave_afiliacion
					AND cuenta_clabe = vCuenta_clabe;
				
				ELSE  
				
					LET vNp_modificacion = vNp_modificacion + 1 ;
					
					DELETE FROM "informix".tbl_paso_msi_info_comercios_afiliados
					WHERE identificador_registro = vIdentificador_registro
					AND clave_promocion = vClave_promocion
					AND clave_afiliacion = vClave_afiliacion
					AND cuenta_clabe = vCuenta_clabe;
					END IF;	
			
			END IF;
			
			LET iContador_pay = iContador_pay + 1;
				
			IF iContador_pay = 1000 THEN
				COMMIT;
        
				LET iContador_pay = 0;
        
				UPDATE STATISTICS MEDIUM FOR TABLE "informix".tbl_msi_info_comercios_afiliados;
				BEGIN WORK;
				
				
			END IF;
			
		END FOREACH;
		
		COMMIT;

		
	    select NVL (count(*) , 0 ) into vBaja from "informix".tbl_paso_msi_info_comercios_afiliados where mov_promocion ='00'
		AND identificador_registro = 'D';
		
	    select NVL (count(*) , 0 ) into vTotal from "informix".tbl_msi_info_comercios_afiliados;
		
		select NVL (count(*) , 0 ) into vAlta from "informix".tbl_paso_msi_info_comercios_afiliados where mov_promocion ='01'
		AND identificador_registro = 'D';
		
		select NVL (count(*), 0) into vMod from "informix".tbl_paso_msi_info_comercios_afiliados where mov_promocion ='02'
		AND identificador_registro = 'D';
		
		UPDATE "informix".MSI_CONTROL_REG_E17 
		set numero_afiliaciones = vAlta
		WHERE accion = 'alta';
		
		UPDATE "informix".MSI_CONTROL_REG_E17 
		set numero_afiliaciones = vTotal
		WHERE accion = 'total';
		
		UPDATE "informix".MSI_CONTROL_REG_E17 
		set numero_afiliaciones = vMod
		WHERE accion = 'modificacion';
		
		UPDATE "informix".MSI_CONTROL_REG_E17 
		set numero_afiliaciones = vBaja
		WHERE accion = 'baja';
		
		UPDATE "informix".MSI_CONTROL_REG_E17 
		set numero_afiliaciones = vNp_alta
		WHERE accion = 'np_alta';
		
		UPDATE "informix".MSI_CONTROL_REG_E17 
		set numero_afiliaciones = vNp_baja
		WHERE accion = 'np_baja';
		
		UPDATE "informix".MSI_CONTROL_REG_E17 
		set numero_afiliaciones = vNp_modificacion
		WHERE accion = 'np_modificacion';
		
		
		
		
		RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
	
	END
	
END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 13 de febrero del 2024',
'Autor: Humberto Daniel Reza Teran',
'CoordinaciÃ³n de AdministraciÃ³n de Tarjetas e Interfaces Transaccionales - CATIT',
'Descripcion: Procedimiento Almacenado que modifica los registros de la tabla tbl_msi_info_comercios_afiliados ',
'de acuerdo a los nuevos movimientos que se encuentran en la tabla de paso tbl_paso_msi_info_comercios_afiliados.';

CREATE PROCEDURE "informix".sp_msi_generar_archivo( pRutaArchivo VARCHAR (80), pNombreArchivo VARCHAR (50) )
    RETURNING VARCHAR (5) as rCODIGO_RETORNO, VARCHAR(150) as rMENSAJE_RESPUESTA;
    
    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(150);
    
    DEFINE vCODIGO_RETORNO VARCHAR(5);
    DEFINE vMENSAJE_RETORNO VARCHAR(150);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(40);
    
    DEFINE vRellenoPiePagina VARCHAR(150);
    DEFINE NOMBRE_UNL_ARCHIVO VARCHAR(15);
    DEFINE SCRIPT_EJECUCION VARCHAR(30);
    DEFINE vExecuteSQL LVARCHAR(2500);
    DEFINE vTotalRegistros VARCHAR(15);
    DEFINE vIndicadorProceso CHAR(1);

    DEFINE vRellenoEncabezado VARCHAR(120);
    DEFINE vFechaActualEncabezado VARCHAR(8);
    DEFINE vFechaActualNomArch VARCHAR(8);
    DEFINE vEmisorBancoppel VARCHAR(7);
    DEFINE vSwitchEglobal VARCHAR(7);
    DEFINE vNumVentana SMALLINT;
    DEFINE vPrefijoArchivo VARCHAR(15);
    DEFINE vNumCharVentana VARCHAR(2);
    DEFINE vNombreArchivoE17 VARCHAR(25);
        
    LET SQLERR = '';
    LET ISAM_ERR ='';
    LET ERROR_INFO = '';
    LET vCODIGO_RETORNO = '00000';
    LET vMENSAJE_RETORNO = 'Inicia el proceso.';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    
    LET vRellenoPiePagina = '';
    LET NOMBRE_UNL_ARCHIVO = 'archivo_e17.txt';
    LET SCRIPT_EJECUCION = 'msi_ejec_info_comercios.sql';
    LET vExecuteSQL = '';
    LET vTotalRegistros = 0;
    LET vIndicadorProceso = '0';
    LET vNombreArchivoE17 = '';
    LET vRellenoEncabezado = '';
    LET vFechaActualEncabezado = '';
    LET vFechaActualNomArch = '';
    LET vEmisorBancoppel = '';
    LET vSwitchEglobal = '';
    LET vNumVentana = 0;
    
    LET vPrefijoArchivo = '';
    LET vNumCharVentana = '' ;
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "debug_sp_msi_generar_archivo.out";
    --TRACE ON;

    BEGIN 		

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excepcion_sp_msi_generar_archivo.err.out" WITH APPEND;
            --TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||'sp_msi_generar_archivo'||' '||current||' '||'vIndicadorProceso =>'||vIndicadorProceso;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
            
        END EXCEPTION;
        
		
        --Construccion del encabezado
        LET vRellenoEncabezado = LPAD(vRellenoEncabezado, 107,' ');
        LET vFechaActualEncabezado = TO_CHAR(today, '%Y%m')||LPAD(DAY(today), '2', '0');
        LET vFechaActualNomArch = LPAD(DAY(today), '2', '0')||TO_CHAR(today, '%m%Y');
        LET vEmisorBancoppel = RPAD('EMISOR',7,' ');
        LET vSwitchEglobal = LPAD('EGLOBAL',7,' ');

        ---Preparación para determinar la ventana
        SELECT num_ventana 
            INTO vNumVentana
        FROM intercard:"informix".tbl_msi_archivos_generados
            WHERE fecha_proceso = today;
        
        IF( vNumVentana IS NULL OR vNumVentana = 0) THEN
            INSERT INTO intercard:"informix".tbl_msi_archivos_generados (num_serial_archivo, prefijo_archivo, fecha_proceso, num_ventana)
                VALUES (0, 'E17M210137', today, 1);
        ELSE
            LET vNumVentana = vNumVentana + 1;
            UPDATE intercard:"informix".tbl_msi_archivos_generados 
                SET num_ventana = vNumVentana
            WHERE fecha_proceso = today;
        END IF        
        
        SELECT prefijo_archivo, num_ventana 
            INTO vPrefijoArchivo, vNumCharVentana
        FROM intercard:tbl_msi_archivos_generados 
            WHERE fecha_proceso = today;        

        LET vIndicadorProceso = '1';
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "H'||vFechaActualEncabezado||vNumCharVentana||vEmisorBancoppel||vSwitchEglobal||vRellenoEncabezado||'.'||'">'||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO;
        SYSTEM vExecuteSQL; 
        
        LET vNumCharVentana = LPAD(vNumCharVentana, 2,'0');
        
        LET vIndicadorProceso = '2';        
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||'informacion_msi.txt'||
        '   SELECT identificador_registro, LPAD(clave_promocion, 10, 0), LPAD(clave_afiliacion, 8, 0), fecha_inicio_prom, fecha_termino_prom, mov_promocion, '||
        '     cve_tipo_promocion, num_meses_dif_compra, num_meses_a_cobrar, pcte_sobretasa, LPAD( NVL(monto_minimo, \" \"), 8, \"0\") as monto_minimo, '||
        '       id_institucion, LPAD( NVL(cuenta_cheques, \" \"), 8, \"0\"), LPAD( NVL(respuesta_promo, \" \"), 2, \" \"), iva_promocion, '||
        '       bin_participante, LPAD( NVL(cuenta_clabe,\" \"),18,\" \") as cuenta_clabe, '||  ----18 espacios
        '     LPAD( NVL(espacio_relleno,\" \"),26,\" \"), fin_archivo'  ||
        '   FROM intercard:tbl_paso_msi_info_comercios_afiliados '||
        '    WHERE identificador_registro = \"D\" '||
         '" >'||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;            
        SYSTEM vExecuteSQL; 
        
        LET vIndicadorProceso = '3';
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;

        LET vIndicadorProceso = '4';
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = "sed -e 's/\|//g' "||RUTA_UNLOAD_RESPALDOS||'informacion_msi.txt >> ' ||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO;
        SYSTEM vExecuteSQL;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        SELECT COUNT(*)
            INTO vTotalRegistros
        FROM intercard:tbl_paso_msi_info_comercios_afiliados
            WHERE identificador_registro = 'D';        

        LET vTotalRegistros = LPAD(vTotalRegistros,10,'0');
        LET vRellenoPiePagina = LPAD(vRellenoPiePagina, 120,' ');
        
        LET vIndicadorProceso = '5';
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "T'||vTotalRegistros||vRellenoPiePagina||'.'||'">>'||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO;
        SYSTEM vExecuteSQL;
        
        ---Valor asignado de forma arbitraria solo para validar que la generación del archivo fue creado exitosamente.
        LET vCODIGO_RETORNO = '00005';
        
        LET vNombreArchivoE17 = vPrefijoArchivo||vFechaActualNomArch||vNumCharVentana;
        
        --Renombrar el archivo conforme a la nomenclatura formalizada y posteriormente ser entregado a Eglobal
        LET vIndicadorProceso = '6';
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'mv '||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO||'  '||RUTA_UNLOAD_RESPALDOS||vNombreArchivoE17;
        SYSTEM vExecuteSQL;

        LET vIndicadorProceso = '7';
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'gzip -c '||pRutaArchivo||pNombreArchivo||' > '||pRutaArchivo||'arch_msi_procesado_'||vFechaActualNomArch||'.gz';
        SYSTEM vExecuteSQL;

        LET vIndicadorProceso = '8';
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'rm -f '||pRutaArchivo||pNombreArchivo;
        SYSTEM vExecuteSQL;
        
        LET vCODIGO_RETORNO = '00000';
        LET vMENSAJE_RETORNO = 'Generacion exitosa del archivo: '||  vNombreArchivoE17;

        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
		
	END
END PROCEDURE
DOCUMENT
'#1',
'Base de datos: intercard',
'Fecha de creacion: 15 de febrero del 2022',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Genera el formato especificado y denominado E17 para ser entregado a Eglobal',
'#2',
'Fecha de modificacion: 01 de agosto del 2022',
'Armando Garcia Ortiz',
'Descripcion: Se agregan los dos nuevos campos considerados en el diseño del archivo E17 (bin_participante y cuenta_clabe)',
'Fecha de modificacion: 13 de agosto del 2024',
'Cristian Ariel Meza Martinez',
'Descripcion: Se cambia la tabla de base por la de paso que es donde se llenara el archivo E17'
;

CREATE PROCEDURE "informix".sp_tokenizacion_cardoperation(pissuer_id CHAR(10), pcard_id CHAR(48), px_correlation_id CHAR(64), p_operationid CHAR(64),
															p_operation  CHAR(10), pdigitalcard_ids LVARCHAR, pstatus CHAR(11))
	RETURNING  CHAR(5) AS codretorno,  CHAR(150) AS descodretorno ;
	
--Definicion de Variables
DEFINE isqlerr 	   					INTEGER;
DEFINE codigoRetorno    			CHAR (5);
DEFINE desCodRetorno 				CHAR (120);
DEFINE outNumTarjeta				CHAR(19);
DEFINE outIdEstatus					INTEGER;
DEFINE outNumTarjetaTokenizada		CHAR(19);
DEFINE outProces 					CHAR(10);
DEFINE outStatus					INTEGER;
DEFINE inFechaToken 				DATETIME YEAR TO FRACTION;
DEFINE inTokenizada					CHAR(1);

--Inicializacion de Variables
LET isqlerr 						= 0;
LET codigoRetorno 					= '00000';
LET desCodRetorno 					= 'Consulta Exitosa.';
LET outNumTarjeta					= '';
LET outNumTarjetaTokenizada			= '';
LET outProces 						= '';
LET outStatus						= 0;
LET inFechaToken					= NULL;
LET inTokenizada 					= '0';


	BEGIN
		
		ON EXCEPTION SET isqlerr
			IF isqlerr <> 0 THEN		
				LET codigoRetorno = isqlerr;
				LET desCodRetorno = 'Error No Controlado al invocar SP sp_tokenizacion_consultatarjeta. Validar.';
			END IF;
			RETURN codigoRetorno, desCodRetorno;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
		
		--SET DEBUG FILE TO '/home/c90313380/sp_tokenizacion_cardoperation.log';
	    --TRACE ON;	
		
	--Obtiene numero de tarjeta con el card_id	
		SELECT numtarjeta
			INTO outNumTarjeta
		FROM tokenizacion_cardid 
			WHERE card_id = pcard_id;
			
		IF outNumTarjeta IS NULL OR outNumTarjeta = '' THEN
			LET codigoRetorno = '00400';
			LET desCodRetorno =  'No se encontro numero de tarjeta con card_id';
			RETURN codigoRetorno, desCodRetorno;
		END IF
		
	--Obtiene id_estatus
		SELECT id_estatus 
			INTO outIdEstatus
		FROM "informix".tarjeta_estatus_tokenizacion 
			WHERE estatus = pstatus;
			
		IF outIdEstatus IS NULL OR outIdEstatus = '' THEN
			LET codigoRetorno = '00400';
			LET desCodRetorno =  'No se encontro id de estatus';
			RETURN codigoRetorno, desCodRetorno;
		END IF

	--Busca en tarjeta tokenizadas
		SELECT numtarjeta, operacion, status 
			INTO outNumTarjetaTokenizada, outProces , outStatus
		FROM tarjetas_tokenizadas
			WHERE numtarjeta = outNumTarjeta;
			
		IF outNumTarjetaTokenizada IS NULL OR outNumTarjetaTokenizada = ' ' THEN
			IF pstatus = 'FAILED' OR pstatus = 'PENDING' THEN		
				LET	inTokenizada = '0';
				
			ELIF pstatus = 'SUCCESSFUL' THEN	
				LET	inTokenizada = '1';
				LET	inFechaToken = CURRENT;					
			END IF
			
			INSERT INTO tarjetas_tokenizadas(numtarjeta, operacion, status, tokenizada, fecha_tokenizacion, fecha_del_token, fecha_susp_token, fecha_insert) 
			VALUES(outNumTarjeta,p_operation, outIdEstatus, inTokenizada, CURRENT, inFechaToken, NULL, CURRENT );
		ELSE
			IF pstatus = 'SUCCESSFUL' THEN
				LET	inTokenizada = '1';
				LET	inFechaToken = CURRENT;	
			END IF
			
			UPDATE tarjetas_tokenizadas 
				SET operacion = p_operation, 
					status = outIdEstatus,  
					tokenizada = inTokenizada,
					fecha_tokenizacion = inFechaToken
				WHERE numtarjeta = outNumTarjetaTokenizada;
		END IF
		
		INSERT INTO "informix".bitacora_token_cardoperation(issuer_id, card_id, x_correlation_id, operation_id, operation, digital_cardids, status, cod_retorno , des_codret, fecha_insert)
		VALUES(pissuer_id, pcard_id,  px_correlation_id, p_operationid, p_operation , pdigitalcard_ids, pstatus, codigoRetorno, desCodRetorno, CURRENT);
			
		RETURN codigoRetorno, desCodRetorno;
		
	END
END PROCEDURE;