CREATE PROCEDURE "informix".sp_cnc_retiro_sin_tarjeta()
    RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (250) AS rvMensajeRespuesta;


	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);        
	DEFINE CODIGO				 CHAR (6);
	DEFINE vMensajeRespuesta VARCHAR (250);
	DEFINE vsOriginalEncontrado  CHAR (5);
	DEFINE vsErrorActividad 	 CHAR (250);        
	DEFINE vsnombrearchivo			VARCHAR(30);
	DEFINE vsArchivo_origen			VARCHAR(3);
	DEFINE vdfecha_proceso     		VARCHAR(10);
	DEFINE vdfecha_arch_ini    		VARCHAR(10);
	DEFINE vdfecha_arch_fin    		VARCHAR(10);
	DEFINE vsfecha_archivo    		VARCHAR(10);
	DEFINE vsFecha_Inicio			DATETIME YEAR TO FRACTION (3);
	DEFINE vsFecha_Fin	 			DATETIME YEAR TO FRACTION (3);
	DEFINE vExecuteSQL 				LVARCHAR(2000);
	DEFINE vsconsecutivo			INT;
	DEFINE vs_td_nombrearchivo		VARCHAR(30);
	DEFINE vsotp					VARCHAR(16);
	DEFINE vsban_bin				VARCHAR(3);
	DEFINE vsnumcuenta				CHAR(20);	
	DEFINE vssecuencia_ext_archivo	CHAR(16);
	DEFINE vsnumtarjeta				CHAR(16);
	DEFINE vssecuencia325			CHAR(7);
	DEFINE vsbin					CHAR(6);
	DEFINE vs_mov_reversado			CHAR(1);
	DEFINE vstipotransaccion325		CHAR(15);
	DEFINE vs_mov_numtarjeta		CHAR(16);
	DEFINE vmMonto325				MONEY;
	DEFINE vsMovconciliado			CHAR(1);
	DEFINE viTipo_Conciliacion		INT;
	DEFINE vsDesc_Conciliacion		CHAR(60);
	DEFINE vs_mov_secuencia         CHAR(7);
	DEFINE vs_mov_montointercard    MONEY;
	DEFINE vs_mov_infreceptor       CHAR(40); 
	DEFINE vs_mov_idterminal        CHAR(16);
	DEFINE vs_mov_metodocaptura     CHAR(2);
	DEFINE vs_mov_folio_mov         CHAR(16);
	DEFINE vs_mov_fechahorainauth   DATETIME YEAR TO FRACTION (5);	
	DEFINE vstpotarjeta char(1);
	DEFINE vsprefijo char(10);	
	DEFINE vNombreArchivo CHAR(30);
	DEFINE vArchivoOrigen CHAR(3);
	DEFINE vFechaArchivo DATE;
	DEFINE vFechaProceso DATE;
        
    DEFINE PREFIJO_SCRIPT VARCHAR(6);
    DEFINE vEnTransaccion CHAR(1);
    DEFINE vContadorIteracion INTEGER;
    DEFINE MAX_CONTADOR_TRANSACCIONES SMALLINT;
    DEFINE RUTA_UNLOAD VARCHAR(50);
    DEFINE vIndicadorProceso CHAR(1);
    
    ---------------------------
    --Inicializando variables--
    ---------------------------		

    LET SQL_ERR         			= 0;
    LET ISAM_ERR        			= 0;
            
    LET CODIGO						= '00000';
    LET vMensajeRespuesta = 'PROCESO EXITOSO';
    LET vsOriginalEncontrado		= '00000';
    LET vsErrorActividad 			= '';
    LET vsnombrearchivo				= '';
    LET vsArchivo_origen			= '';
    LET vdfecha_proceso				= '';
    LET vdfecha_arch_ini			= '';
    LET vdfecha_arch_fin			= '';
    LET vsfecha_archivo				= '';
    LET vsFecha_Inicio 				= CURRENT;
    LET vsFecha_Fin  				= CURRENT;
    LET vExecuteSQL  				= '';
            
    LET vsconsecutivo				= 0;	
    LET vs_td_nombrearchivo				= '';	
    LET vsotp						= '';	
    LET vsban_bin					= '';	
    LET vsnumcuenta					= '';	
    LET vssecuencia_ext_archivo		= '';
    LET vsnumtarjeta				= '';
    LET vssecuencia325				= '';
    LET vs_mov_reversado		  	= '';
    LET vstipotransaccion325		= '';
    LET vmMonto325					= 0.00;
    LET vsMovconciliado				= '';
    LET viTipo_Conciliacion			= 0;
    LET vsDesc_Conciliacion			= '';
    
    
    LET vs_mov_secuencia          	= '';
    LET vs_mov_montointercard     	= 0.00;
    LET vs_mov_infreceptor        	= '';
    LET vs_mov_idterminal         	= '';
    LET vs_mov_metodocaptura      	= '';
    LET vs_mov_folio_mov          	= '';
    LET vs_mov_numtarjeta          	= '';
    LET vs_mov_fechahorainauth    	= CURRENT;
    LET vsbin					  	= '';
    LET vstpotarjeta			  	= '';
    LET vsprefijo				  	= '';

    ---td archivos de conciliacion
    LET vNombreArchivo = '';
    LET vArchivoOrigen  = '';
    LET vFechaArchivo  = '';
    LET vFechaProceso  = '';
    LET PREFIJO_SCRIPT ='c_rst_';
    LET vEnTransaccion = 'F';
    LET vContadorIteracion = 0;        
    LET MAX_CONTADOR_TRANSACCIONES = 1000;
    LET RUTA_UNLOAD = '/RESPALDOSNEW/';    
    LET vIndicadorProceso = '0';
    
    BEGIN
		
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            SET DEBUG FILE TO RUTA_UNLOAD||"exception_sp_cnc_retiro_sin_tarjeta.err.out" WITH APPEND;
            TRACE ON;
            
            IF ((vContadorIteracion > 0) OR (vEnTransaccion = 'V')) THEN
                UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".tbl_txn_retiro_sin_tarjeta;
                COMMIT WORK;
                LET vEnTransaccion = 'F';
                LET vContadorIteracion = 0;
            END IF
            
            LET CODIGO = SQL_ERR;
            LET vMensajeRespuesta = ISAM_ERR||' '||ERROR_INFO||' '||current||' '||'vIndProceso =>'||vIndicadorProceso||' '||vsconsecutivo||' '||vsnumtarjeta;

            RETURN CODIGO, vMensajeRespuesta;

        END EXCEPTION;

        --SET DEBUG FILE TO RUTA_UNLOAD||'debug_sp_cnc_retiro_sin_tarjeta.out';
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        --Inicializar tablas
        IF ( (SELECT COUNT(*) FROM bditarjeta:systables WHERE tabname = 'td_archivos_rst') = 1 ) THEN

            TRUNCATE TABLE bditarjeta:"informix".td_archivos_rst DROP STORAGE;
            TRUNCATE TABLE bditarjeta:"informix".tbl_txn_retiro_sin_tarjeta DROP STORAGE;
            TRUNCATE TABLE bditarjeta:"informix".tbl_txn_rst_rev DROP STORAGE;

        END IF
        

        FOREACH  curBusqArchivo WITH HOLD FOR
        
            SELECT {+AVOID_FULL (bditarjeta:td_archivos_conciliacion)} 
                nombrearchivo, archivo_origen, fecha_archivo, fecha_proceso
                    INTO vNombreArchivo, vArchivoOrigen, vFechaArchivo, vFechaProceso
            FROM bditarjeta:"informix".td_archivos_conciliacion
                WHERE fecha_proceso = today
                    AND archivo_origen ='IST'
            ORDER BY nombrearchivo
            
            INSERT INTO bditarjeta:"informix".td_archivos_rst( nombrearchivo, archivo_origen, fecha_archivo, fecha_proceso, status, cnc_status )
                VALUES( vNombreArchivo, 'IST', vFechaArchivo, vFechaProceso, 'P', 'P');

        END FOREACH
           
        LET vIndicadorProceso = '1';
        
        --Paso 1. Buscar los archivos insertados            
        FOREACH  cursBuscarArch WITH HOLD FOR
            
            SELECT {+AVOID_FULL (bditarjeta:td_archivos_rst)}  
                nombrearchivo, archivo_origen, 
                    fecha_proceso , fecha_archivo                        
                INTO vsnombrearchivo, vsArchivo_origen, 
                        vFechaProceso, vFechaArchivo                            
            FROM bditarjeta:"informix".td_archivos_rst
                WHERE status = 'P'
                    AND cnc_status = 'P'
            ORDER BY nombrearchivo
           
            LET vdfecha_proceso = TO_CHAR(vFechaProceso,'%Y-%m-%d');
            LET vdfecha_arch_ini = TO_CHAR(vFechaArchivo,'%Y-%m-%d');
            LET vdfecha_arch_fin = TO_CHAR( (vFechaArchivo) - 1,'%Y-%m-%d');
            LET vsfecha_archivo = vFechaArchivo;
              
            LET vsnombrearchivo = TRIM(vsnombrearchivo);
            
            LET vsFecha_Inicio = vdfecha_proceso || ' 00:00:00.000';
            LET vsFecha_Fin    = vdfecha_proceso || ' 23:59:59.999';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
            '  SET LOCK MODE TO WAIT 3; '||
            '  UNLOAD TO '||RUTA_UNLOAD||PREFIJO_SCRIPT||'txn_td_mov_rst.unl'||
            ' SELECT consecutivo, nombrearchivo, archivo_origen, fechacarga, numtarjeta as otp,\"\"      '||
            " as numtarjeta, ban_bin, secuencia325 as secuencia325, monto325, numcuenta,"||
            ' tipotransaccion325, movrev325, conciliacion, secuencia, secuencia_extendida, montointercard, fechatransaccion,'||
            ' infreceptor, idterminal, metodocaptura, movconciliado, movreversado, tipo_mov, folio_mov, tipo_conciliacion,'||
            ' desc_conciliacion,secuencia_ext_archivo,'||"'F'"||
                        ' FROM bditarjeta:td_movimientos_conciliacion '||
                        ' WHERE nombrearchivo = ' ||"'"||vsnombrearchivo||"'"||
                        ' AND fechacarga BETWEEN '||"'"|| vsFecha_Inicio||"'"||' AND '||"'"|| vsFecha_Fin ||"'"||
                        ' AND tipotransaccion325 = \"RST_DEB  MAESTR\"'||
                        ' AND movrev325 != \"R\"'||
                        ' AND iso323 = \"00\"'||
                        ';" >'||RUTA_UNLOAD||PREFIJO_SCRIPT||'txn_mov_rst.sql';
            SYSTEM vExecuteSQL;
				
                
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'dbaccess bditarjeta '||RUTA_UNLOAD||PREFIJO_SCRIPT||'txn_mov_rst.sql';
            SYSTEM vExecuteSQL;            
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "echo "||'"'|| "file '"|| RUTA_UNLOAD ||
                    PREFIJO_SCRIPT||'txn_td_mov_rst.unl' || "' delimiter '|' "|| '28'||
                        "; insert into tbl_txn_retiro_sin_tarjeta" || ";"||'"'||' > '||RUTA_UNLOAD||PREFIJO_SCRIPT||'carga_td_mov_rst.txt';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '2';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "dbload -d bditarjeta -c "||RUTA_UNLOAD||PREFIJO_SCRIPT||"carga_td_mov_rst.txt -l "||RUTA_UNLOAD||PREFIJO_SCRIPT||"err_carga_rst.log -n 1000 -r ";
            SYSTEM vExecuteSQL;
            			
			-------------------------------------
			---  Reversos
			-------------------------------------
            
			LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
            ' SET LOCK MODE TO WAIT 3; '||
            ' UNLOAD TO '||RUTA_UNLOAD||PREFIJO_SCRIPT||'txn_td_mov_rst_rev.unl'||
            ' SELECT nombrearchivo, archivo_origen, fechacarga, numtarjeta as otp,'||
            ' secuencia325 , monto325, numcuenta, movrev325,  secuencia, secuencia_extendida, montointercard,'||
            ' fechatransaccion,movreversado,secuencia_ext_archivo'||
                        ' FROM bditarjeta:td_movimientos_conciliacion '||
                        ' WHERE nombrearchivo = ' ||"'"||vsnombrearchivo||"'"||
                        ' AND fechacarga BETWEEN '||"'"|| vsFecha_Inicio||"'"||' AND '||"'"|| vsFecha_Fin ||"'"||
                        ' AND tipotransaccion325 = \"RST_DEB  MAESTR\"'||
                        ' AND movrev325 = \"R\"'||
                        ' AND iso323 = \"00\"'||
                        ';" >'||RUTA_UNLOAD||PREFIJO_SCRIPT||'txn_mov_rst_rev.sql';
            SYSTEM vExecuteSQL;
				
                
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'dbaccess bditarjeta '||RUTA_UNLOAD||PREFIJO_SCRIPT||'txn_mov_rst_rev.sql';
            SYSTEM vExecuteSQL;            
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "echo "||'"'|| "file '"|| RUTA_UNLOAD ||
                    PREFIJO_SCRIPT||'txn_td_mov_rst_rev.unl' || "' delimiter '|' "|| '14'||
                        "; insert into tbl_txn_rst_rev" || ";"||'"'||' > '||RUTA_UNLOAD||PREFIJO_SCRIPT||'carga_td_mov_rst_rev.txt';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '2';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "dbload -d bditarjeta -c "||RUTA_UNLOAD||PREFIJO_SCRIPT||"carga_td_mov_rst_rev.txt -l "||RUTA_UNLOAD||PREFIJO_SCRIPT||"err_carga_rst_rev.log -n 1000 -r ";
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'rm -f '||RUTA_UNLOAD||PREFIJO_SCRIPT||'*';
            SYSTEM vExecuteSQL;
			
			/* SE ELIMINAN LOS REVERSOS DE tmp_paso_stat */
				
				
            DELETE FROM tbl_txn_retiro_sin_tarjeta rst
                WHERE (rst.secuencia_extendida IN(SELECT rv.secuencia_extendida FROM tbl_txn_rst_rev rv)
                AND rst.numcuenta IN (SELECT rv.numcuenta FROM tbl_txn_rst_rev rv)
            );
				
                
            FOREACH curAct_Tarjeta WITH HOLD FOR 
                    
                SELECT 
                    {+AVOID_FULL (bditarjeta:tbl_txn_retiro_sin_tarjeta)}
                    consecutivo, nombrearchivo, a.otp, ban_bin, a.numcuenta, 
                        secuencia_ext_archivo, secuencia325, tipotransaccion325, monto325, b.numtarjeta
                    INTO vsconsecutivo, vs_td_nombrearchivo, vsotp, vsban_bin, vsnumcuenta,
                        vssecuencia_ext_archivo, vssecuencia325, vstipotransaccion325, vmMonto325, vsnumtarjeta
                FROM bditarjeta:"informix".tbl_txn_retiro_sin_tarjeta a 
                    INNER JOIN intercard:"informix".mov_codigos_retiro_sin_tarjeta b
                    ON (a.secuencia_ext_archivo = b.secuenciaextendida)
                WHERE a.actualizado =  'F'                
                    AND a.numcuenta = b.numcuenta
                ORDER BY a.consecutivo
                
                IF (vEnTransaccion = 'F') THEN
                    BEGIN WORK;
                    LET vEnTransaccion = 'V';
                END IF
                        
                LET vs_td_nombrearchivo = TRIM(vs_td_nombrearchivo);
                LET vssecuencia325 = '1'||vssecuencia325;
                              
                IF ( vsotp = '0000000000000000') THEN
                
                    UPDATE bditarjeta:tbl_txn_retiro_sin_tarjeta
                        SET numtarjeta = '',
                            actualizado = 'P'
                    WHERE otp = vsotp
                        AND consecutivo = vsconsecutivo
                            AND nombrearchivo = vs_td_nombrearchivo
                        AND secuencia_ext_archivo = vssecuencia_ext_archivo;
                    
                    LET vsnumtarjeta = ''; -- inicializado para evitar el siguiente IF

                END IF
                
                LET vIndicadorProceso = '3';
                
                IF (vsnumtarjeta <> '' AND vsotp <> '0000000000000000') THEN

                    SELECT secuencia, monto, infreceptor, idterminal, metodocaptura, 
                            secuenciaextendida as folio_mov, fechahorainauth, movreversado, numtarjeta
                        INTO vs_mov_secuencia, vs_mov_montointercard, vs_mov_infreceptor, vs_mov_idterminal, vs_mov_metodocaptura,
                                vs_mov_folio_mov, vs_mov_fechahorainauth, vs_mov_reversado, vs_mov_numtarjeta
                    FROM intercard:"informix".movimiento 
                        WHERE secuenciaextendida = vssecuencia_ext_archivo                         
                    AND numtarjeta = vsnumtarjeta
                        AND secuencia = vssecuencia325;
							
                    LET vsbin = SUBSTR (vsnumtarjeta,1,6);                    
                    LET vs_mov_numtarjeta = TRIM(vs_mov_numtarjeta);
                            
                    --Esto aplica si el bin no es Bancoppel
                    IF ( vsbin = '' ) THEN
                        LET vsban_bin = 'BNI';                        
                    END IF
                    
                    SELECT ban_bin
                        INTO vsban_bin
                    FROM intercard:bines_desc_cnc 
                        WHERE bin = vsbin;
                    
                    UPDATE intercard:"informix".conciliacion_atm_stat06
                        SET compania = vsban_bin
                    WHERE numtarjeta = vsotp  --- el valor correcto es la OTP (RST) y no el numero de tarjeta previamente almacenado
                        AND archivoorigen = 'IST'
                    AND nombrearchivo = vs_td_nombrearchivo
                        AND secuenciaextendida = vssecuencia_ext_archivo;                    
                    
                    IF ( (vs_mov_numtarjeta IS NULL) OR ( vs_mov_numtarjeta = '') ) THEN                        
                        --NO EXISTE EL MOVIMIENTO ORIGINAL                            
                        LET vsOriginalEncontrado = '00400';
                        LET vsErrorActividad = 'NO EXISTE EL MOVIMIENTO INTERCARD';
                    ELSE    
                        LET vsOriginalEncontrado = '00000';
                        LET vsErrorActividad = 'EXISTE EL MOVIMIENTO INTERCARD';
                    END IF
                    
                    IF (vsOriginalEncontrado <> '00000') THEN
							
                        --RST ATM NO ENCONTRADO EN INTERCARD
                        LET viTipo_Conciliacion = 66;
                        
                    ELIF (vs_mov_reversado = 'V') THEN
                        
                        --RST ATM MOVIMIENTO ORIGINAL REVERSADO
                        LET viTipo_Conciliacion = 64;
                
                    ELIF ((vstipotransaccion325 MATCHES('RST_*')) AND (vmMonto325 <> vs_mov_montointercard)) THEN
                        
                        --RST ATM CONCILIADA CON DIFERENCIA DE MONTOS
                        LET viTipo_Conciliacion = 65; 
                        LET vsMovconciliado = 'V'; 

                    ELIF ((vstipotransaccion325 MATCHES('RST_*')) AND (vmMonto325 = vs_mov_montointercard)) THEN
                        
                        --ATM CONCILIADA CORRECTA (MONTOS IGUALES)
                        LET viTipo_Conciliacion = 63; 
                        LET vsMovconciliado = 'V';								

                    ELSE --ERROR
                    
                        --MOV NO CONCUERDA CON NINGUN TIPO
                        LET viTipo_Conciliacion = 0; 

                    END IF
                    
                        
                END IF
                
                LET vIndicadorProceso = '4';
                
                SELECT Desc_Conciliacion 
                    INTO vsDesc_Conciliacion 
                FROM BdiTarjeta:"informix".td_Tipo_Conciliacion 
                    WHERE Tipo_Conciliacion = viTipo_Conciliacion;
                        
                UPDATE td_movimientos_conciliacion
                    SET secuencia = vs_mov_secuencia,
                        secuencia_extendida = vssecuencia_ext_archivo,
                        montointercard = vs_mov_montointercard,
                        infreceptor = vs_mov_infreceptor,
                        idterminal = vs_mov_idterminal,
                        folio_mov = 'i'||vs_mov_folio_mov,
                        fechatransaccion = vs_mov_fechahorainauth,
                        metodocaptura = vs_mov_metodocaptura,
                        ban_bin = vsban_bin,
                        movreversado = vs_mov_reversado,
                        tipo_conciliacion = viTipo_Conciliacion,
                        desc_conciliacion = vsDesc_Conciliacion,
                        movconciliado = vsMovconciliado
                WHERE consecutivo = vsconsecutivo
                    AND nombrearchivo = vs_td_nombrearchivo 
                AND secuencia_ext_archivo = vssecuencia_ext_archivo;
                
                -- se actualiza en la tabla bditarjeta:td_movimientos_conciliacion y en intercard:movimiento los campos de movconciliado 
                UPDATE intercard:"informix".movimiento
                    SET movconciliado = vsMovconciliado
                WHERE secuenciaextendida = vssecuencia_ext_archivo
                    AND numtarjeta = vsnumtarjeta
                        AND secuencia = vssecuencia325;
                
                UPDATE bditarjeta:tbl_txn_retiro_sin_tarjeta
                    SET numtarjeta = vsnumtarjeta,
                            actualizado = 'V'
                WHERE otp = vsotp
                    AND consecutivo = vsconsecutivo
                        AND nombrearchivo = vs_td_nombrearchivo
                    AND secuencia_ext_archivo = vssecuencia_ext_archivo;
                
                LET vContadorIteracion = vContadorIteracion + 5; ---5 actualizaciones cuando es verdadero el IF

                IF (vContadorIteracion >= MAX_CONTADOR_TRANSACCIONES) THEN
                    COMMIT WORK;
                    LET vEnTransaccion = 'F';
                    LET vContadorIteracion = 0;
                    CONTINUE FOREACH;
                END IF 
                
                LET vsnumtarjeta = '';
                LET vsotp = '';
                LET vs_td_nombrearchivo = '';
                LET vssecuencia_ext_archivo = '';
                LET vssecuencia325 = '';
                
            END FOREACH
                
            IF ((vContadorIteracion > 0) OR (vEnTransaccion = 'V')) THEN
                UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".tbl_txn_retiro_sin_tarjeta;
                COMMIT WORK;
                LET vEnTransaccion = 'F';
                LET vContadorIteracion = 0;
            END IF
                
            --Generacion del reporte y archivo generado.
             EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_mov_ist_cap_rst( vdfecha_arch_ini, vdfecha_arch_fin,vdfecha_proceso,vsNombreArchivo,vsfecha_archivo)
                INTO CODIGO, vMensajeRespuesta;
            
            IF (CODIGO = '00000') THEN
            
                --Finalizar la conciliacion administrativa de RST
                UPDATE bditarjeta:"informix".td_archivos_conciliacion
                    SET fecha_hora_gen_conadmin = current, conadmin = 'V'
                WHERE archivo_origen = 'IST'
                    AND nombrearchivo = vsNombreArchivo;

                UPDATE td_archivos_rst
                    SET status = 'T',
                        cnc_status = 'T'
                WHERE nombrearchivo = vsnombrearchivo;
            
            ELSE
            
                LET CODIGO = '00001';
                LET vMensajeRespuesta = ' FALLO CNC MOV_IST_ADMIN| Archivo: ' || vsnombrearchivo;
            
            END IF
                
        END FOREACH ----Fin de Iteracion cursBuscarArch
			
		
        RETURN CODIGO, vMensajeRespuesta;
            
		END
		
	END PROCEDURE
DOCUMENT
'Base de datos: bditarjeta',
'Fecha de modificacion: 05 de abril del 2021',
'ImplementaciÃÂ³n de crear el archivo de excepciÃÂ³n en caso de algÃÂºn error.',
'OptimizaciÃÂ³n de consultas y ejecuciÃÂ³n de estadisticas en las tablas.',
'Descripcion: Ejecucion del proceso de conciliacion de transacciones realizadas con retiro sin tarjeta',
'Este SP sp_cnc_retiro_sin_tarjeta es el principal y es ejecutado por el job 884_CNC_RST_ATM_PRO',
'#2',
'Fecha de modificacion: 23 de abril del 2021',
'Mejoras en el codigo para disminuir el tiempo de ejecucion.',
'se agrega la condicion de numero de tarjeta en el update de la tabla conciliacion_atm_stat06',
'para mejorar el desempeÃÂ±o',
'#3',
'Fecha de modificacion: 01 de junio del 2022',
'Mejoras en el codigo para disminuir el tiempo de ejecucion.',
'Se actualiza el campo conadmin y la fecha de termino de conciliacion administrativa.'
;

CREATE PROCEDURE "informix".sp_concreing_colaborapp (psCve_Usuario VARCHAR(10) , piHorario INTEGER, pFecha_Proceso DATE )

		RETURNING VARCHAR (5)   AS vsCodRet, VARCHAR (150) AS MENSAJE_RPTA;

			-- CONTROL DE ERRORES
		    DEFINE  SQL_ERR              INTEGER;
			DEFINE  ISAM_ERR             INTEGER;
			DEFINE  ERROR_INFO           VARCHAR(80);
			DEFINE  vsCodRet2 						VARCHAR(5);
			--CONTROL GENERAL
			DEFINE vsCodRet				 CHAR (5); 
			DEFINE MENSAJE_RPTA			 CHAR (80);
			DEFINE vdFechaProceso		 DATE;
			DEFINE vdFechaFin			 DATETIME YEAR TO FRACTION (5);
			DEFINE vsFechaArchivo		 CHAR (10);
			DEFINE vsNombreArchivo		 VARCHAR (30);
			DEFINE vsProceso			 CHAR (01);
			DEFINE vsFechaHr_calc1   	 CHAR (10);
			DEFINE vsFechaHr_calc2   	 CHAR (10);
			DEFINE vsFechaHorainAuthini	 CHAR (10);
			DEFINE vsFechaHorainAuthfin	 CHAR (10);
			DEFINE vsRuta_destino        VARCHAR(80);
			DEFINE vsql					 CHAR(1150);
			DEFINE vExecuteSQL 			 LVARCHAR(1500);
		    DEFINE vtransac_margen       VARCHAR(4);
	 	    DEFINE vtransac_ahorro       VARCHAR(4);
			DEFINE vsNomArch_base        VARCHAR(8);
			DEFINE vsNomArch_coppel      VARCHAR(35);
			DEFINE vtransacc             CHAR(4);
			DEFINE vfolio_cap            VARCHAR(16);
			DEFINE vfecha_consumo_calc   CHAR(6);
			DEFINE vfecha_consumo        VARCHAR(10);
			DEFINE vfecha_consumo2       DATE;
			DEFINE vfech_oper            DATE; 
			DEFINE vfech_alt             DATE;
			DEFINE vcuenta               CHAR(20);
			DEFINE vmonto                DECIMAL(19,4);
			DEFINE vmonto_tot            DECIMAL(19,4);
			DEFINE vcancelad             CHAR(1);
			DEFINE vok_movhis            CHAR(1);
			DEFINE vok_dep_cap           CHAR(1);
			DEFINE vcount                INTEGER;
			DEFINE vdDiaHora	         DATETIME YEAR TO FRACTION(5);
		    DEFINE vsArchivo_Origen 	 VARCHAR (3);
			DEFINE vdtFecha_Archivo 	 DATE;
			DEFINE vpaso                 INTEGER;	
			DEFINE vusuario	             VARCHAR(20);
		    DEFINE vsucursal             VARCHAR(4);
			DEFINE vfolio_suc            VARCHAR(16); 
		    DEFINE vreferencia           VARCHAR(30); 
			DEFINE vtipo_txn             CHAR(2);
			DEFINE vcolaborador          CHAR(9); 
			--historico
			DEFINE vnombrearchivo VARCHAR(30);
			DEFINE vcuenta2 VARCHAR(20); 
			DEFINE vmonto_deposito  MONEY;
			DEFINE vmonto_tot2      MONEY; 
			DEFINE vtransacc2       CHAR(04);
			DEFINE vtipo_txn2       CHAR(02);
			DEFINE vforma_pago      CHAR(02);
			DEFINE vsucursal2        CHAR(04); 
			DEFINE vfecha_consumo_calc2 DATE; 
			DEFINE vfech_oper2    VARCHAR(10);
			DEFINE vfech_alt2     VARCHAR(10);  
			DEFINE vfolio_cap2    VARCHAR(16); 
			DEFINE vfolio_suc2    VARCHAR(16);  
			DEFINE vreferencia_txn VARCHAR (24); 
			DEFINE vreferencia_chq VARCHAR(30);
			DEFINE vcolaborador2   CHAR(9);
			DEFINE vestatus2       CHAR(1);
			
	BEGIN	
		
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
				
			SET DEBUG FILE TO vsRuta_destino || "exep_sp_concregin_colaborapp.err.out" WITH APPEND;
			TRACE ON;
			
			IF (SQL_ERR <> '0')  THEN 
				
		     LET vsCodRet      = SQL_ERR;
		     LET MENSAJE_RPTA  = ISAM_ERR||' '||ERROR_INFO||' '||current||' '||'indicador proceso =>'||vpaso; 
		  
		    EXECUTE PROCEDURE BdiTarjeta:"informix".sp_guardabitacora_colaborapp (2, '(' || SQL_ERR || ') ' || MENSAJE_RPTA, psCve_usuario)  
		  	INTO vsCodRet2;
			  
		    UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_colaborapp
			    SET 
				 fecha_hora_gen_conadmin     = vdDiaHora, 
			     fecha_hora_fin_concilia_reg =  (SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) FROM SysMaster:"informix".Sysshmvals) , 
				 ConAdmin = 'F'              
				 WHERE nombrearchivo IN  (SELECT nombrearchivo FROM tb_archivos_cap);
		  
		        LET vsCodRet = '00013';
			    LET MENSAJE_RPTA = 'ERROR EN CONCILIACION ADMIN PASO (' || vpaso || ')';
 	  
		     RETURN vsCodRet, MENSAJE_RPTA;
			END IF;
		  
		END EXCEPTION;
		
			--SET DEBUG FILE TO "/RESPALDOSNEW/__argoz/colaborapp/log/debug_sp_concreing_colaborapp.out";
			---TRACE ON;
		
			--INICIALIZACION DE VARIABLES  
			
			LET vsCodRet			   	= '00000';
			LET vsCodRet2               = '00000';
			LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
			LET vdFechaProceso			= CURRENT;
			LET vdFechaFin				= CURRENT;
			LET vsFechaArchivo			= '';
			LET vsNombreArchivo			= '';
			LET vsProceso				= '';
			LET vsFechaHr_calc1          = ''; 
			LET vsFechaHr_calc2          = ''; 
			LET vsFechaHorainAuthini	= '';
			LET vsFechaHorainAuthfin	= '';
			LET vsRuta_destino          = '/RESPALDOSNEW/';
			LET vsql					='';
			LET vExecuteSQL				='';
			
		    LET vsNombreArchivo = '';
		    LET vtransacc = '';
		    LET vfolio_cap = '';
		    LET vfecha_consumo = '';
		    LET vfecha_consumo2 = '';
		    LET vfecha_consumo_calc = '';
		    LET vfech_oper = '';
			LET vfech_alt = '';
		    LET vcuenta = '';
		    LET vmonto = '';
		    LET vmonto_tot = '';
		    LET vcancelad = '';
		    LET vok_movhis   = '';
		    LET vok_dep_cap  = '';
			LET vusuario     = '';
			LET vsucursal    = '';
			LET vfolio_suc   = '';
			LET vreferencia  = ''; 
			LET vtipo_txn    ='';
			LET vcolaborador = '';
			
		    LET vtransac_margen  = '';
		    LET vtransac_ahorro  = '';
			LET vsNomArch_base   = 'conciCAP';
			LET vsNomArch_coppel = '';
			LET vcount           =  0; 
			LET vdDiaHora        = CURRENT;
			LET vsArchivo_Origen = '';
			LET vdtFecha_Archivo = '';
			LET vpaso            =  0;

		    --historico
			LET vnombrearchivo = ''; 
			LET vcuenta2       = ''; 
			LET vmonto_deposito = '';
			LET vmonto_tot2      = ''; 
			LET vtransacc2        = ''; 
			LET vtipo_txn2        = ''; 
			LET vforma_pago        = ''; 
			LET vsucursal2         = ''; 
			LET vfecha_consumo_calc2  = ''; 
			LET vfech_oper2     = ''; 
			LET vfech_alt2     = '';  
			LET vfolio_cap2     = ''; 
			LET vfolio_suc2     = '';  
			LET vreferencia_txn  = ''; 
			LET vreferencia_chq  = ''; 
			LET vcolaborador2    = ''; 
			LET vestatus2        = ''; 
			
			
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;	
 
                    ------------- temporales 
			          DROP TABLE IF EXISTS tb_full_cap_movhis;
				      DROP TABLE IF EXISTS tb_full_cap_movhis_2;
					  DROP TABLE IF EXISTS tb_archivos_cap;
					  DROP TABLE IF EXISTS tmp_paso_folio_back;
					  DROP TABLE IF EXISTS tt_fechas_consumo;
					  
			        ---tablas fisicas
					TRUNCATE TABLE tmp_paso_mov_vs_cap DROP STORAGE;
					TRUNCATE TABLE tmp_paso_movhis_cnc_cap DROP STORAGE;

			IF ( (SELECT COUNT(*) FROM bditarjeta:td_archivos_conciliacion_colaborapp 	
					WHERE archivo_origen = 'CAP' AND num_registros325 > 0
					AND conadmin = ''
					AND Carga = 'V'
				    AND transferencia = 'V'
					AND Proceso = 'T' 	
					AND Fecha_Proceso = pFecha_Proceso)
					= 0 ) THEN
 
					LET vsCodRet = '00011';
					LET MENSAJE_RPTA = 'NO SE ENCONTRO REGISTROS PARA CONCILIAR EN ARCHIVO';
					  ----------------------------------------------------------------------------------------------------------------
		              -- Generacion de archivo conciCAP  
			           LET vsNomArch_coppel = 'conciCAP'||  LPAD(DAY(vdFechaProceso),'2',0) ||  LPAD(MONTH(vdFechaProceso),'2',0)  ||  YEAR(vdFechaProceso) || '.txt'; 
		               
                       insert into tmp_paso_mov_vs_cap (nombrearchivo,sucursal, folio_cap, fecha_consumo_calc, monto_deposito, colaborador, forma_pago ,estatus) 
                       values  ('','0000','0000000000000000', '01/01/1900','0', 0, '00', 0) ;
					   -----------------------------------------------------------------------------------------------------------------
					  --Elimina reportes anteriores
	                   let vExecuteSQL = '';
                       let vExecuteSQL ='rm -f '||vsRuta_destino||vsNomArch_base||'*';
                       system vExecuteSQL;
					
					  LET vExecuteSQL = '';
				      LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO '||vsRuta_destino||vsNomArch_coppel||'  '||
					  ' SELECT   sucursal, folio_cap,fecha_consumo_calc,SUBSTR(monto_deposito::VARCHAR(16),2,16),colaborador, 0 as comision, 0 as iva, forma_pago as tipo_oper, estatus  '||
					  ' FROM    bditarjeta:tmp_paso_mov_vs_cap ;" >'||vsRuta_destino||'script_concil_colaborapp.sql';
				      SYSTEM vExecuteSQL; 
					  
					  				---Asignacion de permisos del archivo .sql
		              let vExecuteSQL ='';			
		              let vExecuteSQL= 'chmod 777 ' ||vsRuta_destino||'script_concil_colaborapp.sql';
		              system vExecuteSQL;
		              ---- Generacion de log para observar errores a detalle en caso de presentarse uno 
		              let vExecuteSQL = '';
                      let vExecuteSQL = 'dbaccess bditarjeta '||vsRuta_destino||'script_concil_colaborapp.sql'||' 2> error_dbaccess_cap2.log';
                      system vExecuteSQL;					
				      	
				      --eliminacion de archivos
		               let vExecuteSQL = '';
                       let vExecuteSQL ='rm -f '||vsRuta_destino||'script_concil_colaborapp.sql';
                       system vExecuteSQL;	
					   
					       --ACTUALIZA LA HORA DE FIN DE LA CONCILIACION DE LOS REGISTROS
						 	UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_colaborapp
								SET 
								   fecha_hora_gen_conadmin     = vdDiaHora, 
								   fecha_hora_fin_concilia_reg =  (SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) FROM SysMaster:"informix".Sysshmvals) , 
								   ConAdmin = 'V'
								   --ConAdmin = DECODE(vsCodRet, '00000', 'V', 'F')              
								  WHERE   Fecha_Proceso = pFecha_Proceso
								   AND    archivo_origen = 'CAP'
								   AND    conadmin = '' 
				                   AND    Carga = 'V' 
								   AND    transferencia = 'V'
                                   AND    Proceso = 'T' 	
					               AND    num_registros325 = 0;
		              ----------------------------------------------------------------------------------------------------------------
					  RETURN vsCodRet, MENSAJE_RPTA;
				          
			END IF;

		            ---obtiene el numero transaccional de cheques 
		            select valor into vtransac_margen  from  "informix".td_param_conciliacion_colaborapp  where codigo = '351';
			        select valor into vtransac_ahorro  from  "informix".td_param_conciliacion_colaborapp  where codigo = '352';
	 
			        LET vpaso = 1; 

                    SELECT  distinct  nombrearchivo 
				  	FROM bditarjeta:td_archivos_conciliacion_colaborapp
					WHERE  Fecha_Proceso = pFecha_Proceso
					AND  archivo_origen = 'CAP'
					AND conadmin = '' 
				    AND Carga = 'V'
				    AND transferencia = 'V'
                    AND Proceso = 'T' 	
					AND num_registros325 > 0  
                    INTO temp tb_archivos_cap WITH NO LOG;
 
                    LET vpaso = 2; 
						
                    CREATE TEMP TABLE tt_fechas_consumo ( 
                        f_consumo     	CHAR(6),
                        f_consumo_calc	DATE
                        );
                        
                    INSERT INTO tt_fechas_consumo (f_consumo, f_consumo_calc)
                    SELECT 
                     distinct NVL((fecha_consumo),'0') as f_consumo,  '01/01/2021' as f_consumo_calc
                    FROM bditarjeta:conciliacion_depositos_colaborapp
                    WHERE nombrearchivo IN  (SELECT nombrearchivo FROM tb_archivos_cap);
                        
                        
					FOREACH  cursor_fecha WITH HOLD FOR  	
						 
                         Select f_consumo
						        into vsFechaHr_calc1
						 from   tt_fechas_consumo 
						 
                         
						LET vsFechaHr_calc2 = LPAD((SUBSTR(vsFechaHr_calc1,3,2)),2,'0') ||'/'|| 
						                     LPAD((SUBSTR(vsFechaHr_calc1,1,2)),2,'0') ||'/'||
							                 LPAD((SUBSTR(vsFechaHr_calc1,5,2)),4,'20'); 
										
                       LET vsFechaHr_calc2  =  DATE(vsFechaHr_calc2);
                       LET	vsFechaHr_calc2 = vsFechaHr_calc2;
										
                       UPDATE tt_fechas_consumo  set f_consumo_calc =  vsFechaHr_calc2 WHERE f_consumo = vsFechaHr_calc1;				 
						
                        
					END FOREACH;  
						
					    SELECT 
                        NVL(MIN(f_consumo_calc),'0'),
					    NVL(MAX(f_consumo_calc),'0')  
					    INTO vsFechaHorainAuthini,vsFechaHorainAuthfin   
					    FROM tt_fechas_consumo; 
						
						LET vsFechaHorainAuthini = DATE(vsFechaHorainAuthini) - 1;
                        LET vsFechaHorainAuthfin = DATE(vsFechaHorainAuthfin) + 1; 
                        
		        -----------------------------------------------------------------------------------------------------------------
			     -- SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA DE MOVIMIENTO HISTORICOS 
				 LET vpaso =3; 
                
               
                
				FOREACH  cursor_his WITH HOLD FOR 
				
			        SELECT cuenta,monto_tot,transacc,fech_oper,usuario,fech_alt,sucursal,folio_suc,referencia,cancelad 
					INTO  vcuenta,vmonto_tot,vtransacc, vfech_oper, vusuario, vfech_alt,vsucursal, vfolio_suc,vreferencia,vcancelad
					FROM bdicheq:sc_movhis 
			        WHERE  empresa = '001'
					AND (fech_alt BETWEEN  vsFechaHorainAuthini AND vsFechaHorainAuthfin) 
				    AND (transacc BETWEEN vtransac_margen  AND vtransac_ahorro)
					AND   cancelad <> 'S'
					AND Cuenta IS NOT NULL
					--AND sucursal = '5006'  
 
				    insert into "informix".tmp_paso_movhis_cnc_cap (cuenta,monto_tot,transacc,fech_oper,usuario,fech_alt,sucursal,folio_suc,referencia,cancelad) 
                    values  (vcuenta,vmonto_tot,vtransacc,vfech_oper,vusuario,vfech_alt,vsucursal,vfolio_suc,vreferencia,vcancelad);
					
				END FOREACH; 
				 
                
                 
				  LET vpaso = 4; 
				 --SE GENERA/CONSULTA TABLA CON LOS REGISTROS DE LA TABLA DEL ARCHIVO DE LA CNC  
				      DROP TABLE IF EXISTS tb_full_cap_movhis;
				        SELECT  
				        cnc.nombrearchivo, 
						NVL(his.cuenta,'0') as cuenta,
						cnc.importe_total,
						NVL(his.monto_tot,0) as monto_tot,
						NVL(his.transacc,'0000') as transacc,
						cnc.tipo_txn,cnc.forma_pago, 
						NVL(his.sucursal,'0000') as sucursal,
						cnc.fecha_consumo,
						'' as fecha_consumo_calc,
						NVL(his.fech_oper,'01/01/1900') as fech_oper,
						NVL(his.fech_alt,'01/01/1900') as fech_alt,
						cnc.folio, 
						NVL(his.folio_suc,'0') as folio_suc,
						cnc.referencia_txn,
						NVL(his.referencia,'0') as referencia,
						NVL(his.usuario,'0') as usuario,
						cnc.colaborador,
						NVL(his.cancelad,'0') as cancelad
					    FROM bditarjeta:conciliacion_depositos_colaborapp cnc
					    FULL  OUTER  JOIN    tmp_paso_movhis_cnc_cap his  
					    ON   cnc.folio = his.folio_suc
						WHERE nombrearchivo IN  (SELECT nombrearchivo FROM tb_archivos_cap) 
						INTO temp tb_full_cap_movhis WITH NO LOG ;
		           
				       DROP TABLE IF EXISTS tb_full_cap_movhis_2;
				       SELECT *,
				       	CASE 
				       		WHEN (folio_suc IS NULL) or( folio_suc = '0') then 'F'
				       		ELSE 'V'
				       	END  ok_movhis,
                       
				       	CASE  
				       		 		WHEN (folio IS NULL) or( folio = '0') then 'F'
				       		ELSE 'V'
				       	END ok_dep_cap, 
				       	
				       	'0' as estatus
                       
				       	FROM tb_full_cap_movhis
				        INTO temp tb_full_cap_movhis_2 WITH NO LOG ;
			 
			           -- TBL DE PASO  FINAL
			         	INSERT INTO tmp_paso_mov_vs_cap   
			         	SELECT  * FROM tb_full_cap_movhis_2; 
						
			           --Validación final de estatus de la transaccion 
				       LET vsNombreArchivo = '';
				       LET vtransacc = '';
				       LET vfolio_cap = '';
				       LET vfecha_consumo = '';
				       LET vfecha_consumo2 = '';
				       LET vfecha_consumo_calc = '';
				       LET vfech_oper = '';
				       LET vcuenta = '';
				       LET vmonto = '';
				       LET vmonto_tot = '';
				       LET vcancelad = '';
				       LET vok_movhis = '';
				       LET vok_dep_cap = '';
				       
				       LET vpaso = 5; 
                    
                   
					 -----------------
					  FOREACH cursor_fechas FOR
					  
					  	 SELECT   nombrearchivo,   transacc,   folio_cap,  fecha_consumo     ,  cuenta,monto_deposito 
				         INTO   vsNombreArchivo, vtransacc, vfolio_cap, vfecha_consumo_calc  ,  vcuenta, vmonto
					     FROM bditarjeta:tmp_paso_mov_vs_cap
				     	WHERE  estatus = 0
					  
					  	 LET  vfecha_consumo2 = LPAD((SUBSTR(vfecha_consumo_calc,3,2)),2,'0') ||'/'||
                                                LPAD((SUBSTR(vfecha_consumo_calc,1,2)),2,'0') ||'/'||
                                                LPAD((SUBSTR(vfecha_consumo_calc,5,2)),4,'20'); 
										  
					       LET vfecha_consumo2 = DATE(vfecha_consumo2);	
                           LET	vfecha_consumo2 = vfecha_consumo2;							   
					  
					  
					     UPDATE bditarjeta:tmp_paso_mov_vs_cap set fecha_consumo_calc = vfecha_consumo2
					        where  nombrearchivo  = vsNombreArchivo and fecha_consumo = vfecha_consumo_calc
					        and folio_cap = vfolio_cap and cuenta =vcuenta
					        and transacc = vtransacc and monto_deposito = vmonto
							and estatus = 0; 
					  
					   END FOREACH;
					   -----------------
					   	 --Genera tabla temporal para obtener transacciones con mismos folios de fechas pasadas 
  					 /* SELECT 
                      distinct folio,tipo_txn, importe_total,forma_pago, fecha_consumo,colaborador
					  FROM bditarjeta:conciliacion_depositos_colaborapp
					  WHERE nombrearchivo NOT IN  (SELECT nombrearchivo FROM tb_archivos_cap)
					  AND   folio IN ( Select folio_cap FROM tmp_paso_mov_vs_cap ) 
					  INTO temp tmp_paso_folio_back WITH NO LOG;*/
					   
					   SELECT 
                      distinct folio_cap,tipo_txn, monto_deposito,forma_pago, fecha_consumo_calc,colaborador
					  FROM intercard:conciliacion_dep_colaborapp
					  WHERE --nombrearchivo NOT IN  (SELECT nombrearchivo FROM tb_archivos_cap) AND 
					        folio_cap IN ( Select folio_cap FROM tmp_paso_mov_vs_cap ) 
					  AND   estatus = '1'
					  INTO temp tmp_paso_folio_back WITH NO LOG;
					   
                     -----------------
                    
				FOREACH cursor_admin FOR
                			
					 SELECT   nombrearchivo,   transacc,   folio_cap,fecha_consumo,   fecha_consumo_calc,  fech_alt,  cuenta,   monto_deposito,cancelad, ok_movhis ,ok_dep_cap,monto_tot,tipo_txn,colaborador
				       INTO   vsNombreArchivo, vtransacc, vfolio_cap,vfecha_consumo,  vfecha_consumo2,  vfech_oper,  vcuenta, vmonto, vcancelad,vok_movhis,vok_dep_cap,vmonto_tot,vtipo_txn,vcolaborador
					FROM bditarjeta:tmp_paso_mov_vs_cap
					WHERE  estatus = 0
 
					IF 	 (vfecha_consumo2  = vfech_oper) AND ( vfech_oper <> '01/01/1900')	THEN 

	                    IF  ( vok_movhis = 'V' and vok_dep_cap = 'V' and vmonto = vmonto_tot)  then 
		 
					        UPDATE bditarjeta:tmp_paso_mov_vs_cap set estatus = '1' --conciliado
					        where  nombrearchivo  = vsNombreArchivo and  fecha_consumo_calc = vfecha_consumo2  
					        and folio_cap = vfolio_cap and cuenta =vcuenta
					        and transacc = vtransacc and monto_deposito = vmonto; 
											 
							 select count(*) INTO vcount from tmp_paso_folio_back 
							 where folio_cap = vfolio_cap 
							 and fecha_consumo_calc = vfecha_consumo2 
							 AND monto_deposito = vmonto
							 and tipo_txn = vtipo_txn
							 and colaborador = vcolaborador;
				 
						    IF vcount >= 1 then

							   UPDATE bditarjeta:tmp_paso_mov_vs_cap set estatus = '3' --duplicado
					           where  nombrearchivo  = vsNombreArchivo and  fecha_consumo_calc = vfecha_consumo2 
					           and folio_cap = vfolio_cap and cuenta =vcuenta
					           and transacc = vtransacc and monto_deposito = vmonto ;
							   
							END IF;   
							
						 ELSE 
								     UPDATE bditarjeta:tmp_paso_mov_vs_cap set estatus = '2' --No encontrado
 					                 where  nombrearchivo  = vsNombreArchivo and  fecha_consumo_calc = vfecha_consumo2 
					                 and folio_cap = vfolio_cap and cuenta =vcuenta
					                 and transacc = vtransacc and monto_deposito = vmonto; 
							
						END IF;					  
					  
                    ELSE
					
					     UPDATE bditarjeta:tmp_paso_mov_vs_cap set estatus = '2'
 					           where  nombrearchivo  = vsNombreArchivo 
							   and    fecha_consumo_calc = vfecha_consumo2 
					           and    folio_cap = vfolio_cap 
					           and    monto_deposito = vmonto; 
					END IF;  
					  
				 END FOREACH;

				 LET vpaso = 6; 
				 
                 
				 FOREACH  cursor_final WITH HOLD FOR 
				 
				 SELECT    
				           nombrearchivo,cuenta,monto_deposito,monto_tot,transacc,tipo_txn,forma_pago,sucursal,fecha_consumo_calc,fech_oper ,fech_alt,  folio_cap, folio_suc,referencia_txn, referencia_chq, colaborador,estatus    
				   INTO    vnombrearchivo,vcuenta2,vmonto_deposito,vmonto_tot2,vtransacc2,vtipo_txn2,vforma_pago,vsucursal2,vfecha_consumo_calc2,vfech_oper2 ,vfech_alt2, vfolio_cap2, vfolio_suc2, vreferencia_txn, vreferencia_chq, vcolaborador2,vestatus2 
				  FROM    bditarjeta:tmp_paso_mov_vs_cap 
				 
				 INSERT INTO intercard:conciliacion_dep_colaborapp  
				 values (vnombrearchivo,vcuenta2,vmonto_deposito,vmonto_tot2,vtransacc2,vtipo_txn2,vforma_pago,vsucursal2,vfecha_consumo_calc2,vfech_oper2 ,vfech_alt2, vfolio_cap2, vfolio_suc2, vreferencia_txn, vreferencia_chq, vcolaborador2,vestatus2 ); 
				 
				 END FOREACH; 
				 ------
			   LET vsNomArch_coppel = 'conciCAP'||  LPAD(DAY(vdFechaProceso),'2',0) ||  LPAD(MONTH(vdFechaProceso),'2',0)  ||  YEAR(vdFechaProceso) || '.txt'; 
		       -----------------------------------------------------------------------------------------------------------------
		       --Elimina reportes anteriores
	            let vExecuteSQL = '';
                let vExecuteSQL ='rm -f '||vsRuta_destino||vsNomArch_base||'*';
                system vExecuteSQL;
		        -----------------------------------------------------------------------------------------------------------------
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO '||vsRuta_destino||vsNomArch_coppel||'  '||
					' SELECT   DISTINCT NVL(sucursal,''"'||'0000'||'"''),folio_cap,fecha_consumo_calc,SUBSTR(monto_tot::VARCHAR(16),2,16), colaborador, 0 as comision, 0 as iva, forma_pago as tipo_oper, estatus  '||
					' FROM    bditarjeta:tmp_paso_mov_vs_cap order by fecha_consumo_calc,folio_cap ;" >'||vsRuta_destino||'script_concil_colaborapp.sql';
				SYSTEM vExecuteSQL; 
		  			
				---Asignacion de permisos del archivo .sql
		         let vExecuteSQL ='';			
		         let vExecuteSQL= 'chmod 777 ' ||vsRuta_destino||'script_concil_colaborapp.sql';
		         system vExecuteSQL;
		         ---- Generacion de log para observar errores a detalle en caso de presentarse uno 
		         let vExecuteSQL = '';
                 let vExecuteSQL = 'dbaccess bditarjeta '||vsRuta_destino||'script_concil_colaborapp.sql'||' 2> error_dbaccess_cap2.log';
                 system vExecuteSQL;					
					
				 --eliminacion de archivos
		          let vExecuteSQL = '';
                  let vExecuteSQL ='rm -f '||vsRuta_destino||'script_concil_colaborapp.sql';
                  system vExecuteSQL;	
	 
				-- Tablas Fisicas Temporales 
				/*
				TRUNCATE TABLE tmp_paso_mov_vs_cap DROP STORAGE;
	 
			   --Tablas temporales  			
				DROP TABLE IF EXISTS tb_full_cap_movhis;
				DROP TABLE IF EXISTS tb_full_cap_movhis_2;
				DROP TABLE IF EXISTS tb_archivos_cap;
				DROP TABLE IF EXISTS tmp_paso_folio_back; 
				*/ 
				LET vpaso = 7; 
                ---------------------------
				IF vpaso = 7 then 

				            --ACTUALIZA LA HORA DE FIN DE LA CONCILIACION DE LOS REGISTROS
						 	UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_colaborapp
								SET 
								   fecha_hora_gen_conadmin     = vdDiaHora, 
								   fecha_hora_fin_concilia_reg =  (SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) FROM SysMaster:"informix".Sysshmvals) , 
								   ConAdmin = DECODE(vsCodRet, '00000', 'V', 'F')              
								   WHERE nombrearchivo IN  (SELECT nombrearchivo FROM tb_archivos_cap);
					
					ELSE 
					
					    LET vsCodRet = '00012';
						LET MENSAJE_RPTA = 'ERROR EN CONCILIACION ADMIN PASO (' || vpaso || ')';
					    RETURN vsCodRet, MENSAJE_RPTA;
	            END IF;					
		        ---------------------------

		RETURN vsCodRet, MENSAJE_RPTA;
	END
END PROCEDURE;