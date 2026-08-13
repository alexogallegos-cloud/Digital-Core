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