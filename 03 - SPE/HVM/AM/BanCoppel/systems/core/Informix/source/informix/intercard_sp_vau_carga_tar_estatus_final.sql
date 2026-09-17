CREATE PROCEDURE "informix".sp_vau_carga_tar_estatus_final()
    RETURNING CHAR (5) as rCODIGO_RETORNO, CHAR(120) as rMENSAJE_RESPUESTA;
           
	DEFINE vCODIGO_RETORNO 			CHAR(5);
    DEFINE vMENSAJE_RETORNO 		CHAR(120);
    DEFINE RUTA 					VARCHAR(80);   
    DEFINE CONTADOR_TRANSACCIONES 	SMALLINT;    
    DEFINE NOMBRE_UNL_ARCHIVO 		VARCHAR(33);
    DEFINE SCRIPT_EJECUCION 		VARCHAR(34);
    DEFINE ACTUALIZAR_ESTAD_VAU 	VARCHAR(40);
    DEFINE PREFIJO_ARCHIVO 			VARCHAR(13);
    DEFINE ARCHIVO_REG_TARJ_VAU 	VARCHAR(33);
    DEFINE ARCHIVO_ERR_TARJ_VAU 	VARCHAR(33);
	DEFINE SQLERR 					INTEGER;
    DEFINE ISAM_ERR 				INTEGER;
    DEFINE ERROR_INFO 				VARCHAR(80);
    DEFINE vExecuteSQL 				LVARCHAR(5000);
     
    LET vCODIGO_RETORNO = '';
    LET vMENSAJE_RETORNO = '';
    LET RUTA='/RESPALDOSNEW/';
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    LET vExecuteSQL = '';
    LET CONTADOR_TRANSACCIONES = 1000;    
    LET NOMBRE_UNL_ARCHIVO = '';
    LET ARCHIVO_REG_TARJ_VAU = '';
    LET ARCHIVO_ERR_TARJ_VAU = '';
    LET PREFIJO_ARCHIVO = 'vau_';
    
    --SET DEBUG FILE TO RUTA||"debug_sp_vau_obtener_tarjetas.out";
    --TRACE ON;
    BEGIN 		

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA||"excep_sp_vau_obtener_tarjetas.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;

        
        LET NOMBRE_UNL_ARCHIVO = PREFIJO_ARCHIVO||'unload_tarjetas_final.unl';
        LET SCRIPT_EJECUCION = PREFIJO_ARCHIVO||'ejec_tarjetas_final.sql';
        LET ACTUALIZAR_ESTAD_VAU = PREFIJO_ARCHIVO||'ejec_upd_sts_final.sql';
        LET ARCHIVO_REG_TARJ_VAU = PREFIJO_ARCHIVO||'reg_tarjetas_final.txt';
        LET ARCHIVO_ERR_TARJ_VAU = PREFIJO_ARCHIVO||'err_tarjetas_final.log';
		
		TRUNCATE TABLE "informix".tbl_vau_tar_estatus_final DROP STORAGE;
        
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
        '   SET LOCK MODE TO WAIT 3; '||
        '       UNLOAD TO '||RUTA||NOMBRE_UNL_ARCHIVO||
        '   SELECT numtarjeta, codstatustarjeta, numcliente, fechaexp, numtarjetasustituta, fechaasignacion '||        
        '    FROM intercard:\"informix\".tbl_info_tarjetas_vau' ||
        " WHERE codstatustarjeta IN ('CAN', 'DES', 'EXT', 'ROB', 'FAL', 'DAN') "||        
         '" >'||RUTA||SCRIPT_EJECUCION;            
        SYSTEM vExecuteSQL;         
		
        --descargo la informaciÃ³n en un unl
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA||NOMBRE_UNL_ARCHIVO|| "' DELIMITER '|' "|| '6'||
                          "; INSERT INTO tbl_vau_tar_estatus_final;"||'"'||' > '||RUTA||ARCHIVO_REG_TARJ_VAU;
        SYSTEM vExecuteSQL;
        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||RUTA||ARCHIVO_REG_TARJ_VAU||" -l "||RUTA||ARCHIVO_ERR_TARJ_VAU||" -n "||CONTADOR_TRANSACCIONES||" -r";
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' echo UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_vau_tar_estatus_final > '||RUTA||ACTUALIZAR_ESTAD_VAU;
        SYSTEM vExecuteSQL;    
         
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA||ACTUALIZAR_ESTAD_VAU;
        SYSTEM vExecuteSQL;
       
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f ' ||RUTA||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
        
		LET vCODIGO_RETORNO = '00000';
		LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
		
	END
END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 04 de octubre del 2021',
'Kenya Itzel Alonso Sanchez',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Obtener las tarjetas con estatus final para reportarlas y crear el archivo de Visa Account Updater (VAU)'
;

CREATE PROCEDURE "informix".sp_carga_inicial_vau()
RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	--DefiniciÃ³n de variables
	DEFINE vCodigoRetorno				CHAR(5);
	DEFINE vMensaje 					CHAR(160);
	DEFINE vCodigoRetornoArchivo		CHAR(5);
	DEFINE vMensajeArchivo				CHAR(160);
	DEFINE vContador					VARCHAR(50);
	DEFINE RUTA							VARCHAR(50);
	DEFINE vNumtarjeta          		VARCHAR(16);
	DEFINE vFechaexp          			VARCHAR(4);
    DEFINE vNumtarjetasustituta			VARCHAR(16);
	DEFINE vFechaexpsustita   			VARCHAR(4);
	DEFINE vCodstatustarjeta			CHAR(3);
	DEFINE vNumcte						VARCHAR(13);
	DEFINE vCodigoArchivo				CHAR(1);
	DEFINE vCommit  					VARCHAR(50);
	DEFINE vConteoRegistros 			INTEGER;
	DEFINE vIniciaTransaccion   		CHAR(1);
	DEFINE vExecuteSQL		    		LVARCHAR(1000);
	DEFINE SQLERR 						INTEGER;
    DEFINE ISAM_ERR 					INTEGER;
    DEFINE ERROR_INFO 					VARCHAR(80);
	
	--InicializaciÃ³n de variables
	LET vCodigoRetorno = '';
	LET vMensaje = '';
    LET vCodigoRetornoArchivo='';	
    LET vMensajeArchivo='';
	LET vContador ='0';
	LET RUTA = '/RESPALDOSNEW/';
	LET vNumtarjeta ='';      
	LET vFechaexp ='';    	
	LET vNumtarjetasustituta = '';	
	LET vFechaexpsustita =''; 
	LET vCodstatustarjeta ='';
	LET vNumcte ='';
	LET vConteoRegistros = 0;
	LET vCommit = '';
	LET vIniciaTransaccion = '';
	
	LET vExecuteSQL	='';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/vau_debug_carga_inicial.out";
	--TRACE ON;

	BEGIN
	
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
				SET DEBUG FILE TO RUTA || "vau_carga_inicial.err.out" WITH APPEND;
				TRACE ON;
				
				IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
					COMMIT WORK;
				END IF
				
				 				
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO ||' '||vMensaje;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(*) 
			INTO vContador
		FROM "informix".tbl_info_tarjetas_vau;
			
		IF(vContador = '0')THEN
			LET vCodigoRetorno = '00001';
			LET vMensaje = 'No hay registros de tarjetas';
			RETURN vCodigoRetorno, vMensaje;
		END IF
		
	    --Obtiene el nÃºmero afectaciones para realizar los commits 
		SELECT valores
			INTO vCommit
		FROM "informix".tbl_inter_parametros
		WHERE empresa = '001' 
		AND cond_busqueda = 'Commits_vau';
		
		LET vIniciaTransaccion = 'F';
		
		--Tarjetas con estatus final y que no tienen tarjeta sustituta
		FOREACH tarjetas WITH HOLD FOR
			
			SELECT numtarjeta, fechaexp 
				INTO vNumtarjeta, vFechaexp
			FROM "informix".tbl_info_tarjetas_vau 
			WHERE codstatustarjeta IN ('CAN','ROB','DES','EXT','FAL','DAN') 
			AND numtarjetasustituta IS NULL
			
			IF (vIniciaTransaccion = 'F') THEN 
                BEGIN WORK;
                LET vIniciaTransaccion = 'V';
            END IF;
			
						
			INSERT INTO "informix".tbl_tarjetas_vau_final (empresa, numtarjeta, fechaexp, numtarjetasustituta, fechaexpsustituta, identificadorvau, filerdetalle)
						VALUES( '001', vNumtarjeta, vFechaexp, NULL, NULL,'C', NULL);

			LET vConteoRegistros = vConteoRegistros + 1;
			
			IF (vConteoRegistros >= vCommit) THEN
				COMMIT WORK;
				LET vConteoRegistros = 0;
				LET vIniciaTransaccion = 'F';
            	CONTINUE FOREACH;
			END IF
			
			
		END FOREACH
		
		--Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
		IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
			COMMIT WORK;
		END IF
		
		--Inicializan variables
		LET vConteoRegistros = 0;
		LET vIniciaTransaccion = 'F';
		
		--Tarjetas estatus final con tarjeta sustituta con estatus final
		FOREACH tar_status_final WITH HOLD FOR
						
			SELECT P2.numtarjeta, P2.fechaexp, P2.numtarjetasustituta
				INTO vNumtarjeta, vFechaexp, vNumtarjetasustituta
			FROM tbl_vau_tar_estatus_final P2
			WHERE P2.codstatustarjeta IN ('CAN','ROB','DES','EXT','FAL','DAN')
			AND P2.numtarjetasustituta NOT IN
				(SELECT numtarjeta 
					FROM tbl_vau_tar_activas P3 
					WHERE P3.codstatustarjeta IN ('ACT','BLT', 'BLO')
					AND P3.numtarjetasustituta IS NULL
			    )
					
			--Obtiene la fecha de expiraciÃ³n de la tarjeta sustituta
			SELECT fechaexp 
				INTO vFechaexpsustita
			FROM "informix".tbl_info_tarjetas_vau
			WHERE numtarjeta = vNumtarjetasustituta;
			
			IF (vIniciaTransaccion = 'F') THEN 
                BEGIN WORK;
                LET vIniciaTransaccion = 'V';
            END IF;
			
			INSERT INTO "informix".tbl_tarjetas_vau_final (empresa, numtarjeta, fechaexp, numtarjetasustituta, fechaexpsustituta, identificadorvau, filerdetalle)
				VALUES( '001', vNumtarjeta, vFechaexp, vNumtarjetasustituta, vFechaexpsustita,'C',NULL);
			
			LET vConteoRegistros = vConteoRegistros + 1;
			
			IF (vConteoRegistros >= vCommit) THEN
				COMMIT WORK;
				LET vConteoRegistros = 0;
				LET vIniciaTransaccion = 'F';
            	CONTINUE FOREACH;
			END IF
				
			
		END FOREACH
		--Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
		IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
			COMMIT WORK;
		END IF
		
		--Inicializan variables
		LET vConteoRegistros = 0;
		LET vIniciaTransaccion = 'F';
	
		
		--Tarjetas con estatus final y con sustituta con estatus activa
		FOREACH tar_activa WITH HOLD FOR
			SELECT P2.numtarjeta, P2.fechaexp, P2.numtarjetasustituta
				INTO vNumtarjeta, vFechaexp, vNumtarjetasustituta
			FROM tbl_vau_tar_estatus_final P2
			WHERE P2.numtarjetasustituta IN
				(SELECT numtarjeta 
					FROM tbl_vau_tar_activas P3 
					WHERE P3.codstatustarjeta IN ('ACT','BLO','BLT') 
					AND P3.numtarjetasustituta IS NULL)
					
			--Obtiene fecha de expiraciÃ³n de la tarjeta sustituta
			SELECT fechaexp 
				INTO vFechaexpsustita
			FROM "informix".tbl_info_tarjetas_vau
			WHERE numtarjeta = vNumtarjetasustituta;
			
			IF (vIniciaTransaccion = 'F') THEN 
                BEGIN WORK;
                LET vIniciaTransaccion = 'V';
            END IF;
			
			INSERT INTO "informix".tbl_tarjetas_vau_final(empresa, numtarjeta, fechaexp, numtarjetasustituta, fechaexpsustituta, identificadorvau, filerdetalle)
				VALUES('001', vNumtarjeta, vFechaexp, vNumtarjetasustituta, vFechaexpsustita,'A', NULL);
			
			LET vConteoRegistros = vConteoRegistros + 1;
			
			IF (vConteoRegistros >= vCommit) THEN
				COMMIT WORK;
				LET vConteoRegistros = 0;
				LET vIniciaTransaccion = 'F';
            	CONTINUE FOREACH;
			END IF
		END FOREACH
		
		--Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
		IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
			COMMIT WORK;
		END IF
		
		--ActualizaciÃ³n de estadÃ­sticas
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".tbl_tarjetas_vau_final;
		
		--Ejecuta sp para generar archivos con la informaciÃ³n
		EXECUTE PROCEDURE "informix".sp_rpt_vau()
		INTO vCodigoRetornoArchivo, vMensajeArchivo;
		
		--Valida que los archivos se hayan generado de forma correcta
		IF(vCodigoRetornoArchivo <> '00000')THEN
			LET vCodigoRetorno = vCodigoRetornoArchivo;
			LET vMensaje = 'Error al generar archivos';
			RETURN vCodigoRetorno, vMensaje;
		END IF
		
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
		RETURN vCodigoRetorno, vMensaje;
	END
END PROCEDURE
DOCUMENT
'CoordinaciÃ³n de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I',
'Autor: Kenya Itzel Alonso Sanchez',
'Fecha de creacion: 19 de octubre del 2021',
'Base de datos: intercard',
'RQM 10 1425 - ImplementaciÃ³n Herramienta VAU',
'DescripciÃ³n: SPL que genera reporte inicial de tarjetas con estatus final para VAU.'
;

CREATE PROCEDURE "informix".sp_camp_obtener_movs_transacc( pTipoReporte VARCHAR(2), pFechaBusqInicial DATETIME YEAR TO FRACTION(5), pFechaBusqFinal DATETIME YEAR TO FRACTION(5))
    RETURNING VARCHAR (5) as rCODIGO_RETORNO, VARCHAR(150) as rMENSAJE_RESPUESTA;
    
    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(150);
    
	DEFINE CODIGO_RETORNO VARCHAR(5);
    DEFINE MENSAJE_RETORNO VARCHAR(150);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(30);
    DEFINE MOVS_TARJ_PRESENTE VARCHAR(2);
    DEFINE MOVS_TARJ_NO_PRESENTE VARCHAR(2);
	DEFINE PROCESO_INICIAL CHAR(1);    
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;    
    DEFINE NOMBRE_UNL_ARCHIVO VARCHAR(33);
    DEFINE SCRIPT_EJECUCION VARCHAR(34);
    DEFINE PREFIJO_ARCHIVO VARCHAR(8);
    DEFINE NOMBRE_ARCHIVO_REG_CAM VARCHAR(33);
    DEFINE NOMBRE_ARCHIVO_ERR_CAM VARCHAR(33);
    DEFINE NOMBRE_TIPO_TRANSACC VARCHAR(3);
    DEFINE TIPO_TRANSACC_T_PRESENTE VARCHAR(3);
    DEFINE TIPO_TRANSACC_TN_PRESENTE VARCHAR(3);
    DEFINE vExecuteSQL LVARCHAR(5000);    
    DEFINE vCondicionesTipoMov VARCHAR(250);
    
    DEFINE vtNumTarjeta VARCHAR(16);
    DEFINE vtFechaExp VARCHAR(4);
    DEFINE vtNumCliente VARCHAR(16);
    DEFINE vtCardType VARCHAR(1);
    DEFINE vtPinOffline VARCHAR(1);
    DEFINE vtCodEstatusTarjeta VARCHAR(3);
    DEFINE vtMonto DECIMAL(19,2);
    DEFINE vTotalRegistros INTEGER;
    DEFINE vIniciaTransaccion CHAR(1);
    DEFINE vConteoRegistros INTEGER;    
    
    LET SQLERR = '';
    LET ISAM_ERR ='';
    LET ERROR_INFO = '';
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'Inicia el proceso.';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET PROCESO_INICIAL = 'I';
    LET vExecuteSQL = '';
    LET CONTADOR_TRANSACCIONES = 1000;
    LET MOVS_TARJ_PRESENTE = '01';
    LET MOVS_TARJ_NO_PRESENTE = '02';
    LET NOMBRE_TIPO_TRANSACC = '';
    LET TIPO_TRANSACC_T_PRESENTE = 'TP';
    LET TIPO_TRANSACC_TN_PRESENTE = 'TNP';
    
    LET NOMBRE_UNL_ARCHIVO = '';
    LET NOMBRE_ARCHIVO_REG_CAM = '';
    LET NOMBRE_ARCHIVO_ERR_CAM = '';
    LET PREFIJO_ARCHIVO = 'sct_cmp_';

    LET vtNumTarjeta = '';
    LET vtFechaExp = '';
    LET vtNumCliente = '';
    LET vtCardType = '';
    LET vtPinOffline = '';
    LET vtCodEstatusTarjeta = '';
    LET vtMonto = '';
    LET vTotalRegistros = 0;
    LET vIniciaTransaccion = 'F';
    LET vConteoRegistros = 0;
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "debug_sp_camp_obtener_movs_transacc.out";
    --TRACE ON;        
	
    BEGIN 		

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excepcion_sp_camp_obtener_movs_transacc.err.out";
            TRACE ON;
            
            IF ((vConteoRegistros > 0) OR (vIniciaTransaccion = 'V')) THEN
                COMMIT WORK;
                LET vConteoRegistros = 0;
                LET vIniciaTransaccion = 'F';
            END IF;
        
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
            
        END EXCEPTION;
        
        --Construccion de condiciones de busqueda por tipo de transaccion
       
        IF ( pTipoReporte NOT IN ( MOVS_TARJ_PRESENTE, MOVS_TARJ_NO_PRESENTE ) ) THEN
            LET CODIGO_RETORNO = '00001';
            LET MENSAJE_RETORNO = 'Tipo de Transaccionalidad no Válida.';
            RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
        END IF
        
        IF ( pTipoReporte = MOVS_TARJ_PRESENTE ) THEN
            LET NOMBRE_TIPO_TRANSACC = TIPO_TRANSACC_T_PRESENTE;
            LET NOMBRE_UNL_ARCHIVO = PREFIJO_ARCHIVO||'movs_tarj_pre.unl';
            LET SCRIPT_EJECUCION = PREFIJO_ARCHIVO||'ejec_movs_tjt_pre.sql';
            LET NOMBRE_ARCHIVO_REG_CAM = PREFIJO_ARCHIVO||'reg_camp_movs_tjt.txt';
            LET NOMBRE_ARCHIVO_ERR_CAM = PREFIJO_ARCHIVO||'err_camp_movs_tjt.log';
            ---El metodo de captura indica que es usado el CHIP
            LET vCondicionesTipoMov = " AND metodocaptura = '05' AND b.pin_offline <> 1 ";
            
        ELIF ( pTipoReporte = MOVS_TARJ_NO_PRESENTE ) THEN
            LET NOMBRE_TIPO_TRANSACC = TIPO_TRANSACC_TN_PRESENTE;
            LET NOMBRE_UNL_ARCHIVO = PREFIJO_ARCHIVO||'movs_tarj_no_pre.unl';
            LET SCRIPT_EJECUCION = PREFIJO_ARCHIVO||'ejec_movs_tjt_no_pre.sql';
            LET NOMBRE_ARCHIVO_REG_CAM = PREFIJO_ARCHIVO||'reg_camp_movs_tjt_np.txt';
            LET NOMBRE_ARCHIVO_ERR_CAM = PREFIJO_ARCHIVO||'err_camp_movs_tjt_np.log';
            ---El metodo de captura indica que es hecha por Internet (digitadas), 81 e-commerce con MC
            LET vCondicionesTipoMov = " AND metodocaptura IN ('01','81', '10') " ||
                "   AND tipotransaccionposdigitada IS NOT NULL ";
        END IF

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        ----Construccion de los scripts
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO||
        ' SELECT a.numtarjeta, c.fechaexp, c.numcliente, b.card_type, b.pin_offline, c.codstatustarjeta, SUM(a.monto) as monto '  ||
        '   FROM intercard:movimientohistorico a  '  ||
        ' INNER JOIN intercard:hsmcard b '  ||
        ' ON (a.numtarjeta = b.card_no)  '  ||
        ' INNER JOIN intercard:tarjeta c '  ||
        ' ON (a.numtarjeta = c.numtarjeta) '  ||
        ' WHERE fechahorainauth  BETWEEN '''||pFechaBusqInicial||''' AND '''||pFechaBusqFinal||''' '||
        '  AND formato = \"0200\" ' ||
        '  AND prodind = \"02\" ' ||
        '     AND movreversado = \"F\" '||
        '  AND movconciliado = \"V\" '||
            '   AND transaccionorigen = \"1234\"  '||
            '  AND c.codstatustarjeta IN (\"ACT\", \"BLO\", \"BLT\") '||vCondicionesTipoMov||
            ' GROUP BY 1,  2, 3, 4, 5, 6' ||
            
            '  UNION '||
            
        ' SELECT a.numtarjeta, c.fechaexp, c.numcliente, b.card_type, b.pin_offline, c.codstatustarjeta, SUM(a.monto) as monto '  ||
        '   FROM intercard:movimiento a  '  ||
        ' INNER JOIN intercard:hsmcard b '  ||
        ' ON (a.numtarjeta = b.card_no)  '  ||
        ' INNER JOIN intercard:tarjeta c '  ||
        ' ON (a.numtarjeta = c.numtarjeta) '  ||
        ' WHERE fechahorainauth  BETWEEN '''||pFechaBusqInicial||''' AND '''||pFechaBusqFinal||''' '||
        '  AND formato = \"0200\" ' ||
        '  AND prodind = \"02\" ' ||
        'AND movreversado = \"F\" '||
            'AND movconciliado = \"V\" '||vCondicionesTipoMov||
             '   AND transaccionorigen = \"1234\"  '||
            'AND c.codstatustarjeta IN (\"ACT\", \"BLO\", \"BLT\") '||
            ' GROUP BY 1,  2, 3, 4, 5, 6 ' ||
         '" >'||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL; 
        
        TRUNCATE TABLE intercard:tbl_campania_movs_tipo_transacc DROP STORAGE;

        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO|| "' delimiter '|' "|| '7'||                          
                          "; INSERT INTO tbl_campania_movs_tipo_transacc" || ";"||'"'||' > '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_REG_CAM;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_REG_CAM||" -l "||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_ERR_CAM||" -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;        

        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;

        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_campania_movs_tipo_transacc;

        FOREACH curTarjetas WITH HOLD FOR
            
            SELECT t_numtarjeta, t_fechaexp, t_num_cliente, t_card_type, t_pin_offline, t_codstatustarjeta, SUM(t_monto) as t_monto
                INTO vtNumTarjeta, vtFechaExp, vtNumCliente, vtCardType, vtPinOffline, vtCodEstatusTarjeta, vtMonto
            FROM intercard:"informix".tbl_campania_movs_tipo_transacc
                WHERE t_codstatustarjeta IN ("ACT", "BLO", "BLT")
            GROUP BY 1, 2, 3, 4, 5, 6
                ORDER BY t_numtarjeta

            SELECT COUNT(*)
                INTO vTotalRegistros
            FROM intercard:"informix".tbl_campania_notif_tarjeta_ctes
                WHERE numtarjeta = vtNumTarjeta
                    AND fechaexp = vtFechaExp
                AND num_cliente = vtNumCliente
                    AND tipo_transacc_carga = NOMBRE_TIPO_TRANSACC;
 
            IF (vIniciaTransaccion = 'F') THEN 
                BEGIN WORK;
                LET vIniciaTransaccion = 'V';
            END IF;
            
            ---Registrar la información porque no existe el dato
            IF ( vTotalRegistros = 0 ) THEN
            
                INSERT INTO intercard:"informix".tbl_campania_notif_tarjeta_ctes(numtarjeta, fechaexp, num_cliente, tipo_tarjeta_carga, pin_offline_carga, codestatus_tarjeta_carga, tipo_transacc_carga, fecha_registro, monto, num_registro_sms, num_registro_correo_elec, tipo_tarjeta_proc, pin_offline_proc, codestatus_tarjeta_proc, estatus_proceso, desc_plantilla, fecha_proceso)
                    VALUES(vtNumTarjeta, vtFechaExp, vtNumCliente, vtCardType, vtPinOffline, vtCodEstatusTarjeta, NOMBRE_TIPO_TRANSACC, CURRENT, vtMonto, 0, 0, NULL, NULL, NULL, PROCESO_INICIAL, NULL, NULL);
            ELSE
            
                UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                    SET monto = monto + vtMonto
                WHERE numtarjeta = vtNumTarjeta
                    AND fechaexp = vtFechaExp
                AND num_cliente = vtNumCliente
                    AND tipo_transacc_carga = NOMBRE_TIPO_TRANSACC;
            END IF
            
            LET vConteoRegistros = vConteoRegistros + 1;
            
            IF (vConteoRegistros >= 1000) THEN
                COMMIT WORK;
                LET vConteoRegistros = 0;
                LET vIniciaTransaccion = 'F';
                CONTINUE FOREACH;
            END IF;
            
        END FOREACH
        
        IF ((vConteoRegistros > 0) OR (vIniciaTransaccion = 'V')) THEN
            COMMIT WORK;
            LET vConteoRegistros = 0;
            LET vIniciaTransaccion = 'F';
        END IF;        

        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_campania_notif_tarjeta_ctes;        

        LET CODIGO_RETORNO = '00000';
        LET MENSAJE_RETORNO = 'Fin del proceso exitoso.';
    
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO;	
		
	END
END PROCEDURE
DOCUMENT
'#1 ',
'Base de datos: intercard',
'Autor: Armando Garcia Ortiz',
'Creacion: 10 de julio del 2020',
'Descripcion: Obtener la transaccionalidad de movimientos con tarjeta presente (01) y tarjeta no presente (02)',
'considerando al cliente y la tecnologia de su tarjeta (tipo A, B o C) que no tenga su pin offline activado.',
'Este componente es ejecutado por los jobs:',
'843_01_CMP_CARGA_TAR_TP_PRO',
'   843_02_CMP_CARGA_TAR_TNP_PRO',
'Fecha de modificación: 13 de agosto del 2021',
'#2 ',
'Modificación: 01 de octubre del 2021',
'Se cambia la implementación para considerar los registros duplicados y registrar correctamente la información.',
'Adicionalmente, se añaden las líneas del código para hacer commit cada 1000 afectaciones.',
'#3 ',
'Modificación: 11 de octubre del 2021',
'Se agrega el valor predeterminado F en la variable vIniciaTransaccion para que permita la apertura de transaccionalidad',
'#4',
'Modificación: 11 de marzo del 2022',
'Es eliminada la condicion pin_offline <> 1 en tabla de movimiento y movimientohistorico para TNP'
;

CREATE PROCEDURE "informix".sp_msi_validar_archivo_prod( pRutaArchivo VARCHAR(100), pNombreProceso VARCHAR(15), pPrefijoArchivo VARCHAR(15))
    RETURNING VARCHAR (5) as rCodigoRetorno, VARCHAR(150) as rMensajeRetorno, VARCHAR(250) as rNombreArchivo;

    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(150);
    
    DEFINE vCODIGO_RETORNO VARCHAR(5);
    DEFINE vMENSAJE_RETORNO VARCHAR(250);
    DEFINE RUTA_ORIGEN VARCHAR(80);
    DEFINE vExecuteSQL LVARCHAR (450);
    DEFINE vIndicadorProceso CHAR(1);
    DEFINE vPrefijoArchivo VARCHAR(15);

    DEFINE vRutaDestino VARCHAR(100);
    DEFINE vNombreArchivo VARCHAR(100);
    DEFINE vExisteArchivo CHAR(1);
    DEFINE vNumeroLineas INTEGER;
            
            
    LET SQLERR = '';
    LET ISAM_ERR = '';
    LET ERROR_INFO = '';
    
    LET vCODIGO_RETORNO = '00000';
    LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vExecuteSQL = '';
    LET vIndicadorProceso = '0';
    LET vRutaDestino = '';
    LET vNombreArchivo = '';
    LET vExisteArchivo = 'N'; --S = sí / N = no
    LET vNumeroLineas = 0;
    LET vPrefijoArchivo = pPrefijoArchivo;

    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_msi_validar_archivo_prod.out";
    --TRACE ON;

    BEGIN 

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO

            SET DEBUG FILE TO RUTA_ORIGEN || "excep_sp_msi_validar_archivo_prod.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current||' '||'vIndicadorProceso =>'||vIndicadorProceso;
            END IF;
            
           RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO, vNombreArchivo;
        
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        LET vIndicadorProceso = '1';
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = 'echo "echo \"'||vPrefijoArchivo||'\" > '||pRutaArchivo||pNombreProceso||'_prefijo_archivo.txt " > ' ||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = 'echo "ls '||pRutaArchivo||' | grep -i '||vPrefijoArchivo||' > '||pRutaArchivo||pNombreProceso||'_contenedor_archivo.txt " >> ' ||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "existe_archivo=\"N\" ">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "nom_archivo=\"0\" ">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "lineas_archivo=\"0\" ">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "if  [[ -f \"'||pRutaArchivo||pNombreProceso||'_contenedor_archivo.txt\" '||
        '   && -s \"'||pRutaArchivo||pNombreProceso||'_contenedor_archivo.txt\" ]]  ">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "then">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "existe_archivo=\"S\" ">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "nom_archivo=\`head -1 '||pRutaArchivo||pNombreProceso||'_contenedor_archivo.txt'||
            '  | tail -1 | awk  \"{print \$1}\"  \` ">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "prefijo_archivo=\`head -1 '||pRutaArchivo||pNombreProceso||'_prefijo_archivo.txt '||
            '   | tail -1 | awk  \"{print \$1}\"  \` ">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "lineas_archivo=\`sed \"/^$/d\" '||pRutaArchivo||'\$nom_archivo '||
            '   | cat '||pRutaArchivo||'\$nom_archivo | wc -l \` ">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "else" >> ' ||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = ' echo "prefijo_archivo=\`head -1 '||pRutaArchivo||pNombreProceso||'_prefijo_archivo.txt '||
            '   | tail -1 | awk  \"{print \$1}\"  \` ">> '  ||pRutaArchivo||'pro_validar_archivos.sh'; 
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "fi" >> ' ||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "dbaccess intercard -<<EOF ##2>>/dev/null " >> ' ||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "UPDATE \"informix\".tbl_catalogo_archivos_procesar " >> ' ||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "SET archivo_disponible = \"\$existe_archivo\", '||
        '   nombre_archivo = \"\$nom_archivo\", '||
        '   numero_lineas = \"\$lineas_archivo\" " >> '||
        ' ' ||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "WHERE prefijo_archivo = \"\$prefijo_archivo\";  " >> ' ||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "EOF" >> ' ||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = 'chmod 777 '||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = ''; 
        LET vExecuteSQL = 'sh '||pRutaArchivo||'pro_validar_archivos.sh';
        SYSTEM vExecuteSQL;


        SELECT ruta_destino, nombre_archivo, archivo_disponible,numero_lineas 
                INTO vRutaDestino, vNombreArchivo, vExisteArchivo, vNumeroLineas
        FROM intercard:tbl_catalogo_archivos_procesar
            WHERE empresa = '001' 
                AND nombre_proceso = pNombreProceso
                    AND prefijo_archivo = vPrefijoArchivo;
            
        IF ( vExisteArchivo = 'N' ) THEN
            LET vCODIGO_RETORNO = '00001';
            LET vMENSAJE_RETORNO = 'El archivo no esta en la ruta:' || vRutaDestino;
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO, vNombreArchivo;
        END IF
            
        IF ( vNumeroLineas = '0' ) THEN
            LET vCODIGO_RETORNO = '00002';
            LET vMENSAJE_RETORNO = 'El archivo está vacío.';
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO, vNombreArchivo;
        END IF

        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO, vNombreArchivo;

    END
END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 15 de febrero del 2022',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Componente para crear un shell y validar la existencia o',
' el procesamiento del archivo de afiliaciones (entregado por productos)'
;

CREATE PROCEDURE "informix".sp_intercard_info_ctes_por_notif( pNumCliente VARCHAR(20), pNombreCompleto CHAR(1)) 

    RETURNING VARCHAR(5) AS rCodigoRetorno, VARCHAR (80) as rMensajeRetorno, VARCHAR(20) as rNumeroCliente,
        VARCHAR(26) as rPrimerNombre, VARCHAR(26) as rSegundoNombre, VARCHAR(26) as rPrimerApellido, VARCHAR(26) as rSegundoApellido,
        VARCHAR(13) as rNumTelefono, VARCHAR(100) as rCorreoElect;    

    DEFINE SQL_ERR   INTEGER;
    DEFINE ISAM_ERR   INTEGER;
    DEFINE ERROR_INFO  CHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(30);
    
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRetorno VARCHAR(80);
    
    DEFINE vCteRegistrado SMALLINT;
    
    DEFINE vNumeroCliente VARCHAR(20);
    DEFINE vNumeroTarjeta VARCHAR(16);
    DEFINE vPlantilla VARCHAR(12);
    DEFINE vContrato VARCHAR(10);
    
    DEFINE vTerminacionTarjeta CHAR(4);
    DEFINE vPrimerNombre VARCHAR(26);
    DEFINE vSegundoNombre VARCHAR(26);    
    DEFINE vApellidoPaterno VARCHAR(26);
    DEFINE vApellidoMaterno VARCHAR(26);    
    DEFINE vNumTelefono VARCHAR(13);
    DEFINE vCorreoElect VARCHAR(100);
    DEFINE vNumCliente CHAR(80);
    DEFINE vFechaSistema  DATETIME YEAR TO FRACTION(5);    
    DEFINE VALIDAR_SI CHAR(1);
    DEFINE VALIDAR_NO CHAR(1);
    
    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
    
    LET vCodigoRetorno = '00000';
    LET vMensajeRetorno = 'Inicio de ejecucion';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';          
        
    LET vNumeroCliente = TRIM(pNumCliente);    
    LET vCorreoElect = '0';
    
    LET vCteRegistrado = 0;
    LET vPlantilla = NULL;
    LET vContrato = '';
    LET vNumTelefono = '0';    
    LET vPrimerNombre = '0';
    LET vSegundoNombre = '0';    
    LET vApellidoPaterno = '0';
    LET vApellidoMaterno = '0';
    LET vNumCliente = '';
    LET vFechaSistema  = sysdate;    
    LET VALIDAR_SI = 'S';
    LET VALIDAR_NO = 'N';
    
    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_intercard_info_ctes.out";
    --TRACE ON;    
	
	BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excep_sp_intercard_info_ctes.err" WITH APPEND;
            TRACE ON;
            
            IF ( SQL_ERR <> 0 ) THEN
                LET vCodigoRetorno = SQL_ERR;
                LET vMensajeRetorno = ERROR_INFO;                
                    RETURN vCodigoRetorno, vMensajeRetorno, NVL(vNumeroCliente, '0'),  
                            NVL(vPrimerNombre, '0'), NVL(vSegundoNombre, '0'), NVL(vApellidoPaterno, '0'), 
                                NVL(vApellidoMaterno, '0'), NVL(vNumTelefono, '0'), NVL(vCorreoElect, '0');
            END IF
			
        END EXCEPTION

        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;        
        
        
        IF ( ( pNombreCompleto <> VALIDAR_NO AND pNombreCompleto <> VALIDAR_SI) OR              
              ( pNumCliente IS NULL OR pNumCliente = '') ) THEN
              
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Parametros incorrectos sp_intercard_info_ctes_por_notif';           
            RETURN vCodigoRetorno, vMensajeRetorno, NVL(vNumeroCliente, '0'),  
                    NVL(vPrimerNombre, '0'), NVL(vSegundoNombre, '0'), NVL(vApellidoPaterno, '0'), NVL(vApellidoMaterno, '0'), 
                        NVL(vNumTelefono, '0'), NVL(vCorreoElect, '0');
        
        END IF
        
        SELECT telefono as num_telefono
            INTO vNumTelefono
        FROM bdinteg:"informix".si_telefonos_actual	
            WHERE numcte = vNumeroCliente
                AND tipo_tel = '2'
                    AND status_tel = 'A';

        SELECT correo_elec as correo_elec
            INTO vCorreoElect
            FROM bdinteg:"informix".si_correos
        WHERE numcte = vNumeroCliente
            AND tipo_correo = '1'
                AND status_correo = 'A';
                 
         SELECT nombre1, nombre2, apell_paterno, apell_materno
            INTO vPrimerNombre, vSegundoNombre, vApellidoPaterno, vApellidoMaterno
        FROM bdinteg:"informix".si_cliente
            WHERE numcte = vNumeroCliente;
            
        IF (  ( vNumTelefono IS NULL OR vNumTelefono == '' OR LENGTH(TRIM(vNumTelefono))  = 0) AND 
                (vCorreoElect IS NULL OR vCorreoElect == '' OR LENGTH(TRIM(vCorreoElect)) = 0) ) THEN
            
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Sin informacion del cliente';
            LET vNumTelefono = '0';
            LET vCorreoElect = '0';
            RETURN vCodigoRetorno, vMensajeRetorno, NVL(vNumeroCliente, '0'),  
                    NVL(vPrimerNombre, '0'), NVL(vSegundoNombre, '0'), NVL(vApellidoPaterno, '0'), NVL(vApellidoMaterno, '0'), 
                        NVL(vNumTelefono, '0'), NVL(vCorreoElect, '0');
            
        END IF        
        
        --Si la longitud del nombre1 es menor a 3 se utiliza el nombre 2.
        --Implementacion para enviar mensaje personalizado en Latinia.
        IF ( pNombreCompleto == VALIDAR_NO ) THEN
        
            LET vPrimerNombre = TRIM(vPrimerNombre);        
            IF ( LENGTH ( TRIM(vPrimerNombre)) < 3 ) THEN
                LET vPrimerNombre = TRIM(vSegundoNombre);
                LET vSegundoNombre = NULL;
            END IF 
        END IF
        
        LET vCodigoRetorno = '00000';
        LET vMensajeRetorno = 'Informacion obtenida correctamente.';

        RETURN vCodigoRetorno, vMensajeRetorno, NVL(vNumeroCliente, '0'),  
            NVL(vPrimerNombre, '0'), NVL(vSegundoNombre, '0'), NVL(vApellidoPaterno, '0'), NVL(vApellidoMaterno, '0'), NVL(vNumTelefono, '0'), NVL(vCorreoElect, '0');
            
	END
				
END PROCEDURE
DOCUMENT
'Autor: Armando Garcia Ortiz',
'Base de datos: intercard',
'Fecha de creación: 27 de enero del 2021',
'Objetivo: Obtener la informacion del cliente, telefono movil, correo electronico',
'para utilizar los valores en el envio de mensajes hacia Latinia mediante mensajes de texto o correo electronico',
'#2',
'Fecha de modificacion: 07 de marzo del 2022',
'Modificacion: La consulta del nombre de cliente se debe ejecutar aunque no tenga teléfono o correo electrónico asociado',
'y de cualquier manera regresa 00001 si no tiene datos asociados.'
;

CREATE PROCEDURE "informix".sp_rpt_vau()
    
    RETURNING CHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO;

    DEFINE CODIGO_RETORNO 			CHAR(6);
    DEFINE MENSAJE_RETORNO 			VARCHAR(80);        
    DEFINE vTotalRegistros 			INTEGER;
    DEFINE vTotalInterna 			INTEGER;
    DEFINE vRegistrosMaxPorArchivo 	INTEGER;
    DEFINE vExecuteSQL 				CHAR(1150);
    DEFINE vContadorArchivos 		VARCHAR(05);
    DEFINE vNumInicioRegistros	 	INTEGER;    
    DEFINE vNombreScript 			CHAR(30);   
    DEFINE vFechaDia 				DATE;   
    DEFINE vsYear 					VARCHAR(02);   
    DEFINE vsMes 					VARCHAR(02);   
    DEFINE vsDia 					VARCHAR(02);   
    DEFINE vsNumeroArchivo			VARCHAR(05);   
    DEFINE vsNumeroArchivo_2		VARCHAR(05);   
    DEFINE vsRelleno				VARCHAR(54);   
    DEFINE vsRellenoD				VARCHAR(21);   
    DEFINE vsRellenoT				VARCHAR(56);   
    


    DEFINE RUTA_ORIGEN 				VARCHAR(30);
    DEFINE RUTA_UNLOAD 				VARCHAR(30);
    DEFINE TipoPlantilla 			VARCHAR(50);
    DEFINE HEADER		 			VARCHAR(30);
    DEFINE TRAILER		 			VARCHAR(20);
	DEFINE vTotalRegistrosTrailer	VARCHAR(09);
	DEFINE TipoPlantilla_2 			VARCHAR(50);
	DEFINE vsFechaArchivo 			VARCHAR(06);
    
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET vTotalRegistros = 0;
    LET vTotalInterna = 0;
    LET vRegistrosMaxPorArchivo = 1;
    LET vContadorArchivos = '1';
    LET vNumInicioRegistros = 0;
    LET vNombreScript = 'script_rpt_vau_archivos.sql';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET RUTA_UNLOAD = '/RESPALDOSNEW/';
    LET TipoPlantilla = 'REP_VAU_INICIAL';
	LET vFechaDia = CURRENT;
	LET vsYear = '';
	LET vsMes = '';
	LET vsDia = '';
	LET vsNumeroArchivo = '';
	LET vsNumeroArchivo_2 = '';
	LET vsRelleno = '';
	LET vsRellenoD = '';
	LET vsRellenoT = '';
	LET HEADER = 'header.unl';
	LET TRAILER = 'total_tarjetas';
	LET vTotalRegistrosTrailer = '';
	LET TipoPlantilla_2 = '739119-1234.aup.prod.iu7.BCPL_'; -- 
    LET vsFechaArchivo = ''; 

	
    BEGIN    
    
        --SET DEBUG FILE TO RUTA_ORIGEN||"sp_rpt_vau_archivos.out";
        --TRACE ON;    
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		SELECT COUNT(*) conteo_total 
			INTO vTotalRegistros
		FROM tbl_tarjetas_vau_final;
    
        --Obtener el NUMERO MAXIMO DE REGISTROS POR ARCHIVO. 
        --vRegistrosMaxPorArchivo: Valor inicial del requerimiento 200 (29.junio)
        --- bl_inter_parametros

		SELECT valores
			INTO vRegistrosMaxPorArchivo
			FROM tbl_inter_parametros
			WHERE empresa = '001'
		AND cond_busqueda ='rtp_vau_archivo';
        
	
		SELECT valores
			INTO vContadorArchivos
			FROM tbl_inter_parametros
			WHERE empresa = '001'
		AND cond_busqueda ='contador_vau_archivo';
		
		IF ( vContadorArchivos = '99999' ) THEN

		UPDATE tbl_inter_parametros SET valores = '1' WHERE empresa = '001' AND cond_busqueda ='contador_vau_archivo';
		
		LET vContadorArchivos = '1';

		ELSE

		LET vContadorArchivos = vContadorArchivos;

		END IF;
		
		
        -- en el total de registros con el valor cero (0)
        IF (vTotalRegistros = 0) THEN
		
			LET CODIGO_RETORNO  = '00000';
			LET MENSAJE_RETORNO = 'PROCESO EXITOSO, SIN REGISTROS';

            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
            
        END IF;       
        
		IF ( (SELECT COUNT(*) FROM intercard:systables WHERE tabname = 'tmp_trailer_vau') = 1 ) THEN

		TRUNCATE TABLE tmp_trailer_vau DROP STORAGE;


		END IF;
		
		LET vsYear = SUBSTR(vFechaDia,9,2);
		LET vsMes = SUBSTR(vFechaDia,1,2);
		LET vsDia = SUBSTR(vFechaDia,4,2);
		
		LET vsFechaArchivo = vsDia||vsMes||vsYear;
		
        --La consulta tiene mas de un registro | Creacion de los 'n' archivos resultantes
		
        IF (vTotalRegistros >  0) THEN            
           
            WHILE (vTotalRegistros > 0 ) LOOP
                

                
                LET vTotalInterna = vTotalRegistros - vRegistrosMaxPorArchivo; 

                IF (vTotalInterna <= 0) THEN
                    LET vTotalInterna = vTotalRegistros;
                ELIF (vTotalInterna > 0) THEN
                    LET vTotalInterna = vRegistrosMaxPorArchivo;
                END IF;
				
				LET vsNumeroArchivo = LPAD(vContadorArchivos, 5, 0);
				LET vsNumeroArchivo_2 = LPAD(vContadorArchivos, 5, 0);
				LET vsRelleno = TRIM(vsRelleno);

				LET vsRellenoT = TRIM(vsRellenoT);
				LET vsRelleno = LPAD(NVL(vsRelleno,' '), 54,' ');
				LET vsRellenoD = LPAD(NVL(vsRellenoD,' '), 21,' ');
				LET vsRellenoT = LPAD(NVL(vsRellenoT,' '), 56,' ');

				--- Se realiza Header
              
				LET vExecuteSQL = ''; 	   
				LET vExecuteSQL = 'echo "015022'||vsMes||vsDia||vsYear||vsNumeroArchivo||vsRelleno||'" > '||RUTA_UNLOAD||TipoPlantilla_2||vsFechaArchivo||'_'||vsNumeroArchivo_2;
				system vExecuteSQL;
                
                --Consulta utilizada para ir paginando los registros en cada archivo iniciando
                --del registro 0 hasta la base de la variable vRegistrosMaxPorArchivo en cada ciclo.
                ---SELECT SKIP '||vNumInicioRegistros||' FIRST  vRegistrosMaxPorArchivo                
                
                LET vExecuteSQL = '';
                LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
								  'UNLOAD TO "'||RUTA_UNLOAD||TipoPlantilla||'"_'||vsNumeroArchivo_2||'.unl '||
								  'SELECT SKIP '||vNumInicioRegistros||' FIRST '||vRegistrosMaxPorArchivo||
								  ' \"1\",RPAD(NVL(numtarjeta,\" \"),19,\" \"),RPAD(NVL(fechaexp,\" \"),4,\" \"),'||
								  ' RPAD(NVL(numtarjetasustituta,\" \"),19,\" \"), RPAD(NVL(fechaexpsustituta,\" \"),4,\" \"),'||
								  ' RPAD(NVL(identificadorvau,\" \"),1,\" \"),'||'LPAD(NVL(filerdetalle,\" \"),23,\" \") AS relleno'||
								  ' FROM intercard:tbl_tarjetas_vau_final'||
								  ';">'||RUTA_UNLOAD||vNombreScript; 
                SYSTEM vExecuteSQL;
				

                LET vExecuteSQL ='';
                LET vExecuteSQL= 'dbaccess intercard '||RUTA_UNLOAD||vNombreScript;
                SYSTEM vExecuteSQL;
				
				--- GeneraciÃ³n de Trailer -- INICIO
				---Paso #1
                LET vExecuteSQL ='';
                LET vExecuteSQL = 'wc -l '||RUTA_UNLOAD||TipoPlantilla||'_'||vsNumeroArchivo_2||'.unl '|| 
								  '>'||RUTA_UNLOAD||TRAILER||'.txt';
                SYSTEM vExecuteSQL;
                
				---Paso #2
                LET vExecuteSQL ='';
                LET vExecuteSQL = "sed 's/^ *//' "||RUTA_UNLOAD||TRAILER||".txt > "||RUTA_UNLOAD||TRAILER||"_T.txt";
                SYSTEM vExecuteSQL;
				
                ---Se corta por columnas para pegarlos posteriormente con separaciÃ³n de pipes
                LET vExecuteSQL ='';
                LET vExecuteSQL ='cut -d " " -f1 '||RUTA_UNLOAD||TRAILER||'_T.txt  > '||RUTA_UNLOAD||'vau_num_registros.txt';
                SYSTEM vExecuteSQL;
                
                LET vExecuteSQL ='';
                LET vExecuteSQL ='cut -d " " -f2 '||RUTA_UNLOAD||TRAILER||'_T.txt  > '||RUTA_UNLOAD||'vau_nombre_archivo.txt';
                SYSTEM vExecuteSQL;
                
                --Campo "falso" pero permite eliminar el escaneo secuencial.
                LET vExecuteSQL ='';
                LET vExecuteSQL ='echo "001" > '||RUTA_UNLOAD||'vau_empresa.txt';
                SYSTEM vExecuteSQL;
                
                --Se genera el archivo con columnas separadas con pipes
                LET vExecuteSQL ='';
                LET vExecuteSQL ='paste -d "|" ' ||RUTA_UNLOAD||'vau_empresa.txt  ' ||RUTA_UNLOAD||'vau_num_registros.txt  ' ||RUTA_UNLOAD||'vau_nombre_archivo.txt   > ' ||RUTA_UNLOAD||TRAILER||'_T.txt';
                SYSTEM vExecuteSQL;
                
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| RUTA_UNLOAD||TRAILER||'_T.txt' || "' delimiter '|' "|| '3'||
							"; insert into tmp_trailer_vau" || ";"||'"'||' > '||RUTA_UNLOAD||'carga_trailer_vau.txt';
					SYSTEM vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d intercard -c "||RUTA_UNLOAD||"carga_trailer_vau.txt -l "||RUTA_UNLOAD||"err_carga.log -n 1000 -r";
				SYSTEM vExecuteSQL;
				
				SELECT total_registros 
					INTO vTotalRegistrosTrailer
				FROM tmp_trailer_vau
                    WHERE empresa = '001';
				
				LET vTotalRegistrosTrailer = LPAD(vTotalRegistrosTrailer,9,0);
				
				
                --- GeneraciÃ³n de Trailer -- FIN
				

            
                --Eliminacion de pipe de cada registro.
                LET vExecuteSQL ='';
                LET vExecuteSQL = "sed 's/|//g' "||RUTA_UNLOAD||TipoPlantilla||"_"||vsNumeroArchivo_2||".unl >> "||RUTA_UNLOAD||TipoPlantilla_2||vsFechaArchivo||'_'||vsNumeroArchivo_2;
                SYSTEM vExecuteSQL;
				
				-- Se Coloca Trailer
				
				LET vExecuteSQL = ''; 	   
				LET vExecuteSQL = 'echo "915022'||vTotalRegistrosTrailer||vsRellenoT||'" >> '||RUTA_UNLOAD||TipoPlantilla_2||vsFechaArchivo||'_'||vsNumeroArchivo_2;
				system vExecuteSQL;
				
			
				--- Eliminacion de Archivos

				LET vExecuteSQL = '';
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||vNombreScript;
                SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||'carga_trailer_vau.txt';
                SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||'err_carga.log';
                SYSTEM vExecuteSQL;
                
                LET vExecuteSQL = '';
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||'vau_*';
                SYSTEM vExecuteSQL;

				LET vExecuteSQL = ''; 
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||TipoPlantilla||'_'||vsNumeroArchivo_2||'.unl';
                SYSTEM vExecuteSQL;

				LET vExecuteSQL = ''; 
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||TRAILER||".txt";
                SYSTEM vExecuteSQL;
				
				LET vExecuteSQL = ''; 
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||TRAILER||"_T.txt";
                SYSTEM vExecuteSQL;

                
                --El numero vRegistrosMaxPorArchivo es la base de registros por archivo
                LET vNumInicioRegistros = vNumInicioRegistros + vRegistrosMaxPorArchivo;
                
                
                --Se realiza una suma de la variable vNumInicioRegistros (cero) mas vRegistrosMaxPorArchivo
                --Para que en ciclo 2 el SKIP comience en el resultado de vNumInicioRegistros
				
				LET vContadorArchivos = vContadorArchivos::INTEGER + 1;
				UPDATE tbl_inter_parametros SET valores = vContadorArchivos WHERE empresa = '001' AND cond_busqueda ='contador_vau_archivo';
               
               --Se actualiza la variable de registros faltantes por ingresar en el archivo.
                LET vTotalRegistros = vTotalRegistros - vTotalInterna;
				
			   -- TRUNCATE de la tabla de trailer
			   TRUNCATE TABLE tmp_trailer_vau DROP STORAGE;
			   
            END LOOP;
            
        END IF;       
       
        RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
    
    END
    
END PROCEDURE;