CREATE PROCEDURE "informix".sp_conciliacion_mc_vs_oxxo (psCve_Usuario VARCHAR(10) , piHorario INTEGER)
    RETURNING VARCHAR (5) as CODIGO, VARCHAR (150) as MENSAJE_RPTA;

    DEFINE SQL_ERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(80);

    DEFINE CODIGO CHAR (6);
    DEFINE MENSAJE_RPTA CHAR (80);
    DEFINE vdFechaInicio DATETIME YEAR TO FRACTION (5);
    DEFINE vdFechaFin DATETIME YEAR TO FRACTION (5);

    DEFINE vsFechaHorainAuthini	 CHAR (10);
    DEFINE vsFechaHorainAuthfin	 CHAR (10);
    DEFINE vsFechaArchivo		 CHAR (10);
    DEFINE vFechaReporte	    VARCHAR(8);
    DEFINE vsNombreArchivo		 VARCHAR (30);
    DEFINE vsProceso			 CHAR (01);
    DEFINE vsFechaHorainAuth	 CHAR (10);
    DEFINE vsConAdmin			 CHAR (01);
    DEFINE RUTA_DESTINO 		 VARCHAR(80);
    DEFINE vNombreArchivo		 VARCHAR(30);   
    DEFINE vPrefijo		 VARCHAR(10);   
    DEFINE vExecuteSQL 			 LVARCHAR(1500);
    DEFINE vIniciarTransaccion VARCHAR (1);    
    DEFINE vConteoAfectacion INTEGER;
    DEFINE vConteoRegistros INTEGER;
    DEFINE vNumMaxAfectacion SMALLINT;
    
    --------------Variables segundo foreach
    DEFINE	vIdProcesador	VARCHAR(5);
    DEFINE	vSecuencia	VARCHAR(7);
    DEFINE	vAutorizacion	CHAR(7);
    DEFINE	vMvAdmNumTarjeta	VARCHAR(16);
    DEFINE	vMcoNumTarjeta	VARCHAR(16);
    DEFINE	vNumCuenta	VARCHAR(13);
    DEFINE	vMontoMov	DECIMAL(21,4);
    DEFINE	vMontoTxn	DECIMAL(21,4);
    DEFINE	vMvSecuenciaExtendida	CHAR(16);
    DEFINE	vSecExtendidaArchivo	CHAR(15);
    DEFINE	vMontorealrevfzda	DECIMAL(21,4);
    DEFINE	vCodReversa	VARCHAR(1);
    DEFINE	vTipoTxn	CHAR(4);
    DEFINE	vProdind	VARCHAR(2);
    DEFINE	vFormato	VARCHAR(4);
    DEFINE	vCodtran	VARCHAR(2);
    DEFINE	vMetodoCaptura	VARCHAR(2);
    DEFINE	vIdTerminal	VARCHAR(16);
    DEFINE	vInfreceptor	VARCHAR(40);
    DEFINE	vEsNacional	VARCHAR(1);
    DEFINE	vPais	VARCHAR(2);
    DEFINE	vFechahorainauth	DATETIME YEAR TO FRACTION(5);
    DEFINE	vFechaConciliacion	DATETIME YEAR TO FRACTION(5);
    DEFINE	vFechaTxn	VARCHAR(10);
    DEFINE	vHoraTxn	CHAR(8);
    DEFINE	vFnNumtarjeta	VARCHAR(16);
    DEFINE	vTblMov	CHAR(1); 
    DEFINE	vTblMco	CHAR(1);
    
    -----------Variables complementarias cursorMCO_vs_ADMIN        
    DEFINE vAdmProducto VARCHAR(1);
    DEFINE vFinalNumTarjeta VARCHAR(16);
    DEFINE vTblMovHis VARCHAR(1);
    DEFINE vResultadoFinal VARCHAR(20);
    DEFINE vFnSecuenciaExtendida VARCHAR(20);
    DEFINE vFnProducto VARCHAR(10);
    DEFINE vAdmNumTarjeta VARCHAR(16);
    DEFINE vMontoCheqCred DECIMAL(16,2);
    DEFINE vExisteArchivo SMALLINT;    
    DEFINE vFolioSucMC VARCHAR(16); 
    DEFINE vIdReceptor VARCHAR(2);
    DEFINE vIndicadorProceso VARCHAR(2);
    DEFINE vDiaFechaComision VARCHAR(2);
    DEFINE vMesFechaComision VARCHAR(2);
    DEFINE vAnioFechaComision VARCHAR(4);
    DEFINE vExisteComision CHAR(1);
    
    LET CODIGO					= '00000';
    LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
    LET vdFechaInicio			= CURRENT;
    LET vdFechaFin				= CURRENT;
    LET vNumMaxAfectacion = 250;
    
    LET vsFechaHorainAuthini	= '';
    LET vsFechaHorainAuthfin	= '';
    LET vsFechaArchivo			= '';
    LET vFechaReporte		= '';
    LET vsNombreArchivo			= '';
    LET vsProceso				= '';
    LET vsFechaHorainAuth		= '';
    LET vsConAdmin				= '';
    LET RUTA_DESTINO	 		= '/resplogifx/';
    LET vNombreArchivo	 		= 'REP_MCO_VS_MOV_';
    LET vPrefijo ='rpt_cmc_';
    LET vExecuteSQL				='';
    LET vIniciarTransaccion = 'F';
    LET vConteoAfectacion = 0;
    LET vConteoRegistros = 0;
    LET vNumMaxAfectacion = 0;
    
    LET	vIdProcesador	='';
    LET	vSecuencia	='';
    LET	vAutorizacion	='';
    LET	vMvAdmNumTarjeta	='';
    LET	vMcoNumTarjeta	='';
    LET	vNumCuenta	='';
    LET	vMontoMov	='';
    LET	vMontoTxn	='';
    LET	vMvSecuenciaExtendida	='';
    LET	vSecExtendidaArchivo	='';
    LET	vMontorealrevfzda	='';
    LET	vCodReversa	='';
    LET	vTipoTxn	='';
    LET	vProdind	='';
    LET	vFormato	='';
    LET	vCodtran	='';
    LET	vMetodoCaptura	='';
    LET	vIdTerminal	='';
    LET	vInfreceptor	='';
    LET	vEsNacional	='';
    LET	vPais	='';
    LET	vFechahorainauth	='';
    LET	vFechaConciliacion	='';
    LET	vFechaTxn	='';
    LET	vHoraTxn	='';
    LET	vFnNumtarjeta	='';
    LET	vTblMov	='';
    LET	vTblMco	='';

-----------Variables complementarias cursorMCO_vs_ADMIN
    LET vAdmProducto = '';
    LET vFinalNumTarjeta = '';
    LET vTblMovHis = '';
    LET vResultadoFinal = '';
    LET vFnSecuenciaExtendida = '';
    LET vFnProducto = '';
    LET vAdmNumTarjeta = '';
    LET vMontoCheqCred = '';
    LET vFolioSucMC = '';
    LET vIdReceptor = '';
    LET vIndicadorProceso = '0';
    LET vDiaFechaComision = '';
    LET vMesFechaComision = '';
    LET vAnioFechaComision = '';
    LET vExisteComision = '0';
    
    --SET DEBUG FILE TO "/RESPALDOSNEW/__argoz/mc_reporte_671/logs/debug_sp_reporte_cnc_mastercard.out";
    --TRACE ON;

    BEGIN
        
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO||"exc_sp_cnc_mc_versus_oxxo.out" WITH APPEND;
            TRACE ON;
            
            IF ( ( vConteoAfectacion > 0 ) OR ( vIniciarTransaccion = 'V' ) ) THEN
                COMMIT WORK;
            END IF
            
            LET CODIGO    = SQL_ERR;
            LET MENSAJE_RPTA  = ERROR_INFO||'Indicador =>'||vIndicadorProceso;

            RETURN CODIGO, MENSAJE_RPTA;

        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        SELECT COUNT(*) 
            INTO vExisteArchivo
        FROM bditarjeta:"informix".td_archivos_conciliacion_mc
            WHERE conadmin = '';                
            
        IF ( vExisteArchivo = 0 ) THEN
            LET CODIGO = '00001';
            LET MENSAJE_RPTA = 'NO SE ENCONTRO ARCHIVO PARA SER CONCILIADO';
            RETURN CODIGO, MENSAJE_RPTA;
        END IF
        
        
        --Tabla 1. movimientos de transaccionalidad
        TRUNCATE TABLE bditarjeta:"informix".tmp_paso_movimiento_cnc_mc DROP STORAGE;
        
        --Tabla 2. conciliacion mc oxxo
        TRUNCATE TABLE bditarjeta:"informix".tmp_paso_cnc_mco DROP STORAGE;
        
        --Tabla 3. Búsqueda y registro de información de cuentas con comision cobrada.
        TRUNCATE TABLE bditarjeta:"informix".tbl_mco_paso_comisiones_corresp_mc DROP STORAGE; ---nueva tabla de comisiones
                
        --Tabla 4. Informacion relacionada de tabla 1 y tabla 2
        TRUNCATE TABLE bditarjeta:"informix".tmp_paso_mov_vs_mco DROP STORAGE;
        
        --Tabla 5. Busqueda de informacion en tabla conciliacion admin
        TRUNCATE TABLE bditarjeta:"informix".tmp_admin_mc DROP STORAGE;
        
        --Tabla 6. Informacion relacionada de tabla 4 y tabla 5
        TRUNCATE TABLE bditarjeta:"informix".tbl_mco_mov_previo_admin DROP STORAGE;

        --Tabla 6. Información relacionada de tabla 4 y 5
        TRUNCATE TABLE bditarjeta:"informix".tbl_mco_mov_admin_t DROP STORAGE;
        
        FOREACH iterarGenerarArchivo WITH HOLD FOR
        
            SELECT nombrearchivo, TO_CHAR((fecha_archivo)-1, '%Y-%m-%d'), 
                        TO_CHAR((fecha_archivo), '%Y-%m-%d'), TO_CHAR((fecha_archivo), '%d%m%Y'),
                    fecha_archivo, proceso, conadmin
                INTO vsNombreArchivo, vsFechaHorainAuthini, vsFechaHorainAuthfin, vFechaReporte,
                    vsFechaArchivo, vsProceso, vsConAdmin
            FROM bditarjeta:"informix".td_archivos_conciliacion_mc
                WHERE archivo_origen = 'MCO'
                    AND proceso ='T'
                AND conadmin = ''

            LET vdFechaInicio = vsFechaHorainAuthini || ' 00:00:00.0';
            LET vdFechaFin = vsFechaHorainAuthfin || ' 00:00:00.0';

            LET vDiaFechaComision  = SUBSTR(vsFechaHorainAuthini, 9, 2 );
            LET vMesFechaComision  = SUBSTR(vsFechaHorainAuthini, 6, 2);
            LET vAnioFechaComision = SUBSTR(vsFechaHorainAuthini, 1, 4);
            
            LET vIndicadorProceso = '1';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
            '       UNLOAD TO '||RUTA_DESTINO||vPrefijo||'mco_movimiento.unl'||
            ' SELECT secuencia, numtarjeta, monto, secuenciaextendida, montorealrevfzda, codreversa, prodind, formato,'||
            '  codtran, metodocaptura, idterminal, infreceptor, esnacional, pais, fechahorainauth, idreceptor, '||
            '   CASE '||
            '    WHEN idreceptor = \"02\" THEN SUBSTR(infreceptor, 17, 6)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2) '||
            '    WHEN idreceptor = \"03\" THEN SUBSTR(idterminal, 1, 5)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2) '||
            '   END folio_suc_mov '||
            ' FROM intercard:movimiento '||
            ' WHERE fechahorainauth BETWEEN '||"'"|| vdFechaInicio||"'"||' AND '||"'"|| vdFechaFin ||"'"||
            ' AND prodind = \"02\"		 	AND '||
            ' formato = \"0200\"  	 	 	AND '||
            ' codigoiso = \"00\"  	 	 	AND '||
            ' codtran = \"28\" 		 	 	AND '||
            ' transaccionorigen = \"2345\" 	AND '|| 
            ' codreversa = 0    	 	 	AND '||
            ' movreversado = \"F\" 	 	 	    '||
            ';" >'||RUTA_DESTINO||vPrefijo||'mov_cnc_mc.sql';
            SYSTEM vExecuteSQL;

            LET vIndicadorProceso = '2';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'dbaccess intercard '||RUTA_DESTINO||vPrefijo||'mov_cnc_mc.sql';
            SYSTEM vExecuteSQL;

            LET vIndicadorProceso = '3';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA_DESTINO||vPrefijo||'mco_movimiento.unl' || "' DELIMITER '|' "|| '17'||
            "; INSERT INTO tmp_paso_movimiento_cnc_mc" || ";"||'"'||' > '||RUTA_DESTINO||vPrefijo||'carga_mov_mc.txt';
            SYSTEM vExecuteSQL;

            LET vIndicadorProceso = '4';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "dbload -d bditarjeta -c "||RUTA_DESTINO||vPrefijo||"carga_mov_mc.txt -l "||RUTA_DESTINO||vPrefijo||"err_carga.log -n 1000 -k";
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '5';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
            '   UNLOAD TO '||RUTA_DESTINO||vPrefijo||'unload_mco.unl'||
                ' SELECT {+AVOID_FULL (intercard:conciliacion_mc_oxxo)} '||
                ' \"1\" ||autorizacion as autorizacion_mc, num_tarjeta, numcuenta, monto_txn, tipo_txn,'||
                ' fecha_conciliacion, fecha_txn, hora_txn, sec_extendida_archivo, id_procesador'||
                ' FROM intercard:conciliacion_mc_oxxo '||
                ' WHERE nombrearchivo = ' ||"'"||vsNombreArchivo||"'"||
                ' AND SUBSTR (num_tarjeta,0,6) IN  (' ||
                ' SELECT bin '||
                ' FROM intercard:bines'||
                ' WHERE creditodebito IN (\"C\", \"D\"))'||
                ' AND cod_respuesta =\"00\"'||
                ' AND tipo_txn = \"FREC\" '||
                ';" >'||RUTA_DESTINO||vPrefijo||'cnc_mc_oxxo.sql';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '6';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'dbaccess intercard '||RUTA_DESTINO||vPrefijo||'cnc_mc_oxxo.sql';
            SYSTEM vExecuteSQL;

            LET vIndicadorProceso = '7';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_DESTINO||vPrefijo|| 'unload_mco.unl' || "' DELIMITER '|' "|| '10'||
                "; INSERT INTO tmp_paso_cnc_mco" || ";"||'"'||' > '||RUTA_DESTINO||vPrefijo||'cga_mco.txt';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '8';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "dbload -d bditarjeta -c "||RUTA_DESTINO||vPrefijo||"cga_mco.txt -l "||RUTA_DESTINO||vPrefijo||"err_carga.log -n 1000 -k";
            SYSTEM vExecuteSQL;

            LET vIndicadorProceso = '9';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||
            '   UNLOAD TO '||RUTA_DESTINO||vPrefijo||'unload_comisiones_mc.unl'||
            ' SELECT folio_suc, sucursal, transacc, empresa, cuenta, '||
            '   CASE '||
            '     WHEN transacc = \"0507\" THEN \"02\" '||
            '     WHEN transacc = \"0529\" THEN \"03\" '||
            '   END id_corresponsal '||
            ' FROM bdicheq:sc_movhis '||
            ' WHERE empresa = \"001\" ' ||
            ' AND fech_alt = MDY('||vMesFechaComision||','||vDiaFechaComision||','||vAnioFechaComision||') ' ||
            ' AND cancelad <> \"S\" '||
            ' AND transacc IN (\"0507\", \"0529\") '||
            ';" >'||RUTA_DESTINO||vPrefijo||'ejec_comisiones_mc.sql';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '10';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'dbaccess bditarjeta '||RUTA_DESTINO||vPrefijo||'ejec_comisiones_mc.sql';
            SYSTEM vExecuteSQL;

            LET vIndicadorProceso = '11';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA_DESTINO||vPrefijo|| 'unload_comisiones_mc.unl' || "' DELIMITER '|' "|| '6'||
            "; INSERT INTO tbl_mco_paso_comisiones_corresp_mc" || ";"||'"'||' > '||RUTA_DESTINO||vPrefijo||'archivo_carga_comisiones.txt';
            SYSTEM vExecuteSQL;

            LET vIndicadorProceso = '12';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "dbload -d bditarjeta -c "||RUTA_DESTINO||vPrefijo||"archivo_carga_comisiones.txt -l "||RUTA_DESTINO||vPrefijo||"error_carga_comisiones.log -n 1000 -k";
            SYSTEM vExecuteSQL;

            UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".tmp_paso_cnc_mco;
            UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".tmp_paso_movimiento_cnc_mc;
            
            LET vIniciarTransaccion = 'F';
            LET vConteoAfectacion = 0;
            
            FOREACH cursorMCO_vs_MOV WITH HOLD FOR
                    
                SELECT 
                    c.id_procesador, d.secuencia, c.autorizacion, d.numtarjeta, 
                        c.num_tarjeta, c.numcuenta, d.montomov, c.monto_txn, d.secuenciaextendida,
                            c.sec_extendida_archivo, d.montorealrevfzda, d.codreversa, c.tipo_txn, d.prodind,
                        d.formato, d.codtran, d.metodocaptura, d.idterminal, d.infreceptor, d.esnacional, 
                            d.pais, d.fechahorainauth,c.fecha_conciliacion,
                        c.fecha_txn, c.hora_txn, d.idreceptor, d.folio_suc_mov
                    INTO
                        vIdProcesador, vSecuencia, vAutorizacion, vMvAdmNumTarjeta,
                            vMcoNumTarjeta, vNumCuenta, vMontoMov, vMontoTxn, vMvSecuenciaExtendida,
                        vSecExtendidaArchivo, vMontorealrevfzda, vCodReversa, vTipoTxn, vProdind, 
                            vFormato, vCodtran, vMetodoCaptura, vIdTerminal, vInfreceptor, vEsNacional, 
                                vPais, vFechahorainauth, vFechaConciliacion, 
                        vFechaTxn, vHoraTxn, vIdReceptor, vFolioSucMC
                    FROM bditarjeta:"informix".tmp_paso_cnc_mco c
                        FULL OUTER JOIN bditarjeta:"informix".tmp_paso_movimiento_cnc_mc d 
                            ON(  c.num_tarjeta = d.numtarjeta )
                        AND c.autorizacion = d.secuencia
                            ---AND d.formato = '0200' AND  d.codtran = '28' AND d.metodocaptura = '01'  ---estas condiciones prolonga mucho el tiempo de la consulta
                    ORDER BY  d.secuencia, d.numtarjeta
                    
                    LET vFnNumtarjeta = vMvAdmNumTarjeta;
                    LET vTblMov = 'V';
                    LET vTblMco = 'V';
                    
                    IF ( vMvAdmNumTarjeta IS NULL ) THEN
                        LET vFnNumtarjeta = vMcoNumTarjeta;
                        ---guardar el valor del campo mco_numtarjeta
                    END IF
                    
                    IF ( vSecuencia IS NULL ) THEN
                        LET vTblMov = 'F';
                        ---guardar el valor 'F'
                    END IF 
                    
                    IF ( vAutorizacion IS NULL ) THEN
                        LET vTblMco = 'F';
                        ---guardar el valor 'F'
                    END IF 

                    IF (vIniciarTransaccion = 'F') THEN 
                        BEGIN WORK;
                        LET vIniciarTransaccion = 'V';
                    END IF
                    
                    ---insertar los valores en la tabla tmp_paso_mov_vs_mco
                    INSERT INTO bditarjeta:"informix".tmp_paso_mov_vs_mco (
                        id_procesador, mv_secuencia, mco_autorizacion, mv_numtarjeta, mco_numtarjeta, 
                            mco_numcuenta, mv_montomov, mco_monto, mv_secuenciaextendida, 
                        mco_sec_extendida_archivo, mv_montorealrevfzda, mv_codreversa, mco_tipo_txn, mv_prodind, mv_formato, 
                            mv_codtran, mv_metodocaptura, mv_idterminal, mv_infreceptor, mv_esnacional, mv_pais, mv_fechahorainauth, 
                        mco_fechaconciliacion, mco_fecha_txn, mco_hora_txn, fn_numtarjeta, tbl_mov, tbl_mco, idreceptor, folio_suc_mov
                    )
                    VALUES ( 
                        vIdProcesador, vSecuencia, vAutorizacion, vMvAdmNumTarjeta, vMcoNumTarjeta, 
                            vNumCuenta, vMontoMov, vMontoTxn, vMvSecuenciaExtendida,
                        vSecExtendidaArchivo, vMontorealrevfzda, vCodReversa, vTipoTxn, vProdind, vFormato, 
                            vCodtran, vMetodoCaptura, vIdTerminal, vInfreceptor, vEsNacional, vPais, vFechahorainauth, 
                        vFechaConciliacion, vFechaTxn, vHoraTxn, vFnNumtarjeta, vTblMov, vTblMco, vIdReceptor, vFolioSucMC
                        );

 
                    LET vConteoRegistros = vConteoRegistros + 1;
                    IF ( vConteoAfectacion >= vNumMaxAfectacion ) THEN
                        COMMIT WORK;
                        LET vIniciarTransaccion = 'F';
                        LET vConteoAfectacion = 0;
                        CONTINUE FOREACH;
                    END IF

            END FOREACH

            IF ( ( vConteoAfectacion > 0 ) OR ( vIniciarTransaccion = 'V' ) ) THEN
                COMMIT WORK;                    
            END IF
            
            LET vIniciarTransaccion = 'F';
            LET vConteoAfectacion = 0;
                
            LET vIndicadorProceso = '13';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
            ' UNLOAD TO '||RUTA_DESTINO||vPrefijo||'admin_mco.unl'||
            ' SELECT nomarchivo325, tarjeta, cuenta, montosif, producto, folio325 '||
            ' FROM intercard:conciliacion_admin_mc '||
            ' WHERE nomarchivo325 = ' ||"'"||vsNombreArchivo||"'"||
            ' AND estatus != \"S\" '||
            ' ;" >'||RUTA_DESTINO||vPrefijo||'mco_admin_cnc.sql';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '14';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'dbaccess intercard '||RUTA_DESTINO||vPrefijo||'mco_admin_cnc.sql';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '15';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_DESTINO||vPrefijo||'admin_mco.unl' || "' DELIMITER '|' "|| '6'||
                        "; insert into tmp_admin_mc" || ";"||'"'||' > '||RUTA_DESTINO||vPrefijo||'carga_mco_admin.txt';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '16';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "dbload -d bditarjeta -c "||RUTA_DESTINO||vPrefijo||"carga_mco_admin.txt -l "||RUTA_DESTINO||vPrefijo||"err_carga.log -n 1000 -k";
            SYSTEM vExecuteSQL;
                
            UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".tmp_admin_mc;
            UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".tmp_paso_mov_vs_mco;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'rm -f '||RUTA_DESTINO||vPrefijo||'*';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '17';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
            '   UNLOAD TO '||RUTA_DESTINO||vPrefijo||'movs_pre_admin.unl'||
            '  SELECT a.id_procesador, a.mv_secuencia, a.mco_autorizacion, a.fn_numtarjeta, a.mco_numcuenta, a.mv_montomov, '||
            '  a.mco_monto, a.mv_secuenciaextendida, a.mco_sec_extendida_archivo, a.mv_montorealrevfzda, a.mv_codreversa, a.mco_tipo_txn, '||
            '  a.mv_prodind, a.mv_formato, a.mv_codtran, a.mv_metodocaptura, a.mv_idterminal, a.mv_infreceptor, a.mv_esnacional, '||
            '  a.mv_pais, a.mv_fechahorainauth, a.mco_fechaconciliacion, a.mco_fecha_txn, a.mco_hora_txn, '||
            '  a.tbl_mov, a.tbl_mco, a.idreceptor, b.producto, b.tarjeta, b.monto_cheq_cred, b.folio_suc_mc '||
            ' FROM bditarjeta:\"informix\".tmp_paso_mov_vs_mco a '||
            ' INNER JOIN bditarjeta:\"informix\".tmp_admin_mc b '||
            ' ON ( a.fn_numtarjeta = b.tarjeta ) '||
            ' AND a.mco_numcuenta = b.cuenta '||
            ' ;" >'||RUTA_DESTINO||vPrefijo||'cnc_pre_admin.sql';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '18';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'dbaccess bditarjeta '||RUTA_DESTINO||vPrefijo||'cnc_pre_admin.sql';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '19';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA_DESTINO||vPrefijo||'movs_pre_admin.unl' || "' DELIMITER '|' "|| '31'||
                        "; insert into tbl_mco_mov_previo_admin" || ";"||'"'||' > '||RUTA_DESTINO||vPrefijo||'carga_pre_admin.txt';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '20';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "dbload -d bditarjeta -c "||RUTA_DESTINO||vPrefijo||"carga_pre_admin.txt -l "||RUTA_DESTINO||vPrefijo||"err_carga.log -n 1000 -k";
            SYSTEM vExecuteSQL;
            
            LET vIniciarTransaccion = 'F';
            LET vConteoAfectacion = 0;
    
            UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".tbl_mco_mov_previo_admin;
            
            FOREACH cursorMCO_vs_ADMIN WITH HOLD FOR
                
                SELECT DISTINCT a.id_procesador, a.mv_secuencia, a.mco_autorizacion, a.fn_numtarjeta, a.mco_numcuenta, a.mv_montomov,
                    a.mco_monto, a.mv_secuenciaextendida, a.mco_sec_extendida_archivo, a.mv_montorealrevfzda, a.mv_codreversa, a.mco_tipo_txn,
                        a.mv_prodind, a.mv_formato, a.mv_codtran, a.mv_metodocaptura, a.mv_idterminal, a.mv_infreceptor, a.mv_esnacional,
                    a.mv_pais, a.mv_fechahorainauth, a.mco_fechaconciliacion, a.mco_fecha_txn, a.mco_hora_txn,
                        a.tbl_mov, a.tbl_mco, a.idreceptor, a.producto, a.tarjeta, a.monto_cheq_cred, a.folio_suc_mc
                    INTO
                        vIdProcesador,  vSecuencia,  vAutorizacion, vFnNumtarjeta,  vNumCuenta,  vMontoMov,  
                            vMontoTxn,  vMvSecuenciaExtendida,  vSecExtendidaArchivo,  vMontorealrevfzda,  vCodReversa,  vTipoTxn,  
                        vProdind,  vFormato,  vCodtran,  vMetodoCaptura, vIdTerminal, vInfreceptor, vEsNacional, vPais, vFechahorainauth, 
                            vFechaConciliacion,  vFechaTxn, vHoraTxn, vTblMov,  vTblMco, vIdReceptor, vAdmProducto, vAdmNumTarjeta, vMontoCheqCred, vFolioSucMC
                FROM bditarjeta:"informix".tbl_mco_mov_previo_admin a
                    WHERE a.mv_formato = '0200' AND a.mv_codtran = '28'
                
                LET vTblMovHis = 'V';
                IF ( vFnNumtarjeta IS NULL ) THEN
                    LET vFnNumtarjeta = vAdmNumTarjeta;
                END IF
                IF ( vAdmNumTarjeta IS NULL ) THEN 
                    LET vTblMovHis = 'F';
                
                END IF 

                LET vResultadoFinal = 'OK';
                IF (  (vTblMco = 'V' AND vTblMovHis = 'F' AND vTblMov = 'F') OR  (vTblMco = 'F' ) ) THEN
                    LET vResultadoFinal = 'NO CONCILIADO';
                END IF
    
                IF ( vMvSecuenciaExtendida IS NULL ) THEN 
                    LET vMvSecuenciaExtendida = vSecExtendidaArchivo;
                END IF 
                    
                IF ( vAdmProducto IS NULL ) THEN
                    SELECT creditodebito
                        INTO vAdmProducto
                    FROM intercard:bines 
                        WHERE bin = SUBSTR(vFnNumtarjeta,1,6);
                END IF                    
                    
                IF ( vIniciarTransaccion = 'F' ) THEN 
                    BEGIN WORK;
                    LET vIniciarTransaccion = 'V';
                END IF
                
                INSERT INTO bditarjeta:"informix".tbl_mco_mov_admin_t (
                    identificador, id_procesador, mv_secuencia, mco_autorizacion, final_numtarjeta, mco_numcuenta, 
                        mv_montomov, mco_monto, monto_cheq_cred, fn_secuenciaextendida, sec_extendida_archivo, 
                    mv_montorealrevfzda, mv_codreversa, mco_tipo_txn, mv_prodind, mv_formato, mv_codtran, 
                        mv_metodocaptura, mv_idterminal, mv_infreceptor, mv_esnacional,
                    mv_pais, mv_fechahorainauth, mco_fechaconciliacion, mco_fecha_txn, 
                        mco_hora_txn, fn_producto, tbl_mov, tbl_mco, tbl_movhis, resultado_final, idreceptor, folio_suc_mc
                    )
                VALUES ( 0, vIdProcesador, vSecuencia, vAutorizacion, vFnNumtarjeta, vNumCuenta, 
                        vMontoMov, vMontoTxn, vMontoCheqCred, vMvSecuenciaExtendida, vSecExtendidaArchivo, 
                    vMontorealrevfzda, vCodReversa, vTipoTxn, vProdind, vFormato, vCodtran, 
                        vMetodoCaptura, vIdTerminal, vInfreceptor, vEsNacional, 
                    vPais, vFechahorainauth, vFechaConciliacion,  vFechaTxn, 
                        vHoraTxn, vAdmProducto, vTblMov,  vTblMco, vTblMovHis, vResultadoFinal, vIdReceptor, vFolioSucMC
                        );
                    
                LET vConteoRegistros = vConteoRegistros + 1;
                IF ( vConteoAfectacion >= vNumMaxAfectacion ) THEN
                    COMMIT WORK;
                    LET vIniciarTransaccion = 'F';
                    LET vConteoAfectacion = 0;
                    CONTINUE FOREACH;
                END IF
                    
                        
            END FOREACH
                
            IF ( ( vConteoAfectacion > 0 ) OR ( vIniciarTransaccion = 'V' ) ) THEN
                COMMIT WORK;
            END IF
            
            SELECT a.final_numtarjeta, a.fn_secuenciaextendida
                FROM bditarjeta:tbl_mco_mov_admin_t a
            INNER JOIN intercard:mco_conciliacion_aplicativos b
                ON ( a.final_numtarjeta = b.numtarjeta )
                    AND a.fn_secuenciaextendida = b.secuenciaextendida
            INTO temp tb_duplicados_cnc_mc WITH NO LOG;


            DELETE FROM bditarjeta:tbl_mco_mov_admin_t 
                WHERE ( 
                    final_numtarjeta IN ( 
                        SELECT final_numtarjeta FROM tb_duplicados_cnc_mc
                        )   
                AND fn_secuenciaextendida IN ( 
                        SELECT fn_secuenciaextendida FROM tb_duplicados_cnc_mc
                        )
                AND mv_codtran = '28'
            );

            UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:"informix".tbl_mco_mov_admin_t;
            
            LET vIniciarTransaccion = 'F';
            LET vConteoAfectacion = 0;
        
            FOREACH cursorAdmin WITH HOLD FOR
                
                SELECT DISTINCT id_procesador, mv_secuencia, mco_autorizacion, final_numtarjeta, 
                    mco_numcuenta, mv_montomov, mco_monto, monto_cheq_cred, fn_secuenciaextendida, 
                        mv_montorealrevfzda, mv_codreversa, mco_tipo_txn, mv_prodind, mv_formato, 
                    mv_codtran, mv_metodocaptura, mv_idterminal, mv_infreceptor, mv_esnacional,
                        mv_pais, mv_fechahorainauth, mco_fechaconciliacion, mco_fecha_txn,
                    mco_hora_txn, fn_producto, tbl_mov, tbl_mco, tbl_movhis, resultado_final, idreceptor, folio_suc_mc
                    
                    INTO vIdProcesador, vSecuencia, vAutorizacion, vFnNumtarjeta, 
                            vNumCuenta,  vMontoMov, vMontoTxn, vMontoCheqCred, vMvSecuenciaExtendida,
                        vMontorealrevfzda,  vCodReversa, vTipoTxn, vProdind, vFormato,
                            vCodtran,  vMetodoCaptura, vIdTerminal, vInfreceptor, vEsNacional,
                         vPais, vFechahorainauth,  vFechaConciliacion,  vFechaTxn,  
                         vHoraTxn, vAdmProducto, vTblMov,  vTblMco, vTblMovHis, vResultadoFinal, vIdReceptor, vFolioSucMC
                FROM bditarjeta:"informix".tbl_mco_mov_admin_t
                    WHERE mv_codtran = '28'
                
                IF ( vIniciarTransaccion = 'F' ) THEN 
                    BEGIN WORK;
                    LET vIniciarTransaccion = 'V';
                END IF
                
                LET vExisteComision = '0';
                
                SELECT  COUNT(*)
                    INTO vExisteComision
                    FROM bditarjeta:"informix".tbl_mco_paso_comisiones_corresp_mc 
                WHERE empresa = '001' 
                    AND folio_suc = vFolioSucMC ---vFolioSucMC '050OER0322063919' 
                AND cuenta = vNumCuenta;   ----'10017844356'
                
                IF ( vExisteComision > '0' ) THEN
                    LET vExisteComision = '1';
                END IF 

                INSERT INTO intercard:"informix".mco_conciliacion_aplicativos 
                    ( fecha_archivo, id_procesador, secuencia, autorizacion, numtarjeta, numcuenta, montomov,
                        monto_mco, monto_cheq_cred, secuenciaextendida, montorealrevfzda, codreversa, tipo_txn, 
                            prodind, formato, codtran, metodocaptura, idterminal, infreceptor, esnacional, pais,
                        fechahorainauth, fechaconciliacion, fecha, hora, producto, tbl_mov, tbl_mco, 
                        tbl_movhis, resultado_final, idreceptor, cobro_comision 
                    )
                VALUES 
                    ( vsFechaArchivo, vIdProcesador, vSecuencia, vAutorizacion, vFnNumtarjeta, vNumCuenta,  vMontoMov, 
                        vMontoTxn, vMontoCheqCred, vMvSecuenciaExtendida, vMontorealrevfzda, vCodReversa, vTipoTxn, 
                            vProdind, vFormato, vCodtran, vMetodoCaptura, vIdTerminal, vInfreceptor, vEsNacional, vPais, 
                        vFechahorainauth,  vFechaConciliacion,  vFechaTxn, vHoraTxn, vAdmProducto, vTblMov,  vTblMco, 
                        vTblMovHis, vResultadoFinal, vIdReceptor, DECODE(vExisteComision, '0', 'N', '1', 'S')
                        
                    );

                LET vConteoRegistros = vConteoRegistros + 1;
                IF ( vConteoAfectacion >= vNumMaxAfectacion ) THEN
                    COMMIT WORK;
                    LET vIniciarTransaccion = 'F';
                    LET vConteoAfectacion = 0;
                    CONTINUE FOREACH;
                END IF
          
          
            END FOREACH
            
            IF ( ( vConteoAfectacion > 0 ) OR ( vIniciarTransaccion = 'V' ) ) THEN
                COMMIT WORK;
            END IF

            UPDATE bditarjeta:"informix".td_archivos_conciliacion_mc
                SET fecha_hora_gen_conadmin = current, conadmin = 'V'
            WHERE fecha_archivo = vsFechaArchivo
                AND archivo_origen = 'MCO'            
            AND proceso = 'T'
                AND nombrearchivo = vsNombreArchivo;
                
                
            LET vIndicadorProceso = '21';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "id_procesador|numtarjeta|NumCuenta|Fecha|Hora|Monto_mov|monto_mco|monto_cheq_cred|secuencia_mov|autorizacion_mco|'||
                            'secuenciaextendida|producto|tbl_mov|tbl_mco|tbl_movhis|resultado_final|comision adicional" > '||
                        RUTA_DESTINO||vNombreArchivo||vFechaReporte||'.unl';
            SYSTEM vExecuteSQL;
        
            LET vIndicadorProceso = '22';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; ' ||
               ' UNLOAD TO ' ||RUTA_DESTINO||vPrefijo||vNombreArchivo||vFechaReporte||'_01.unl'||               
               ' SELECT id_procesador, numtarjeta, numcuenta, SUBSTR(fecha, 4,2)||\"/\"||SUBSTR(fecha,1,2)||\"/\"||SUBSTR(fecha,7,4), '||
               '        hora, montomov, monto_mco, monto_cheq_cred, secuencia,'||
               '    autorizacion, secuenciaextendida, producto, tbl_mov, tbl_mco, tbl_movhis, resultado_final, cobro_comision '||
               ' FROM intercard:mco_conciliacion_aplicativos '||
               '     WHERE fecha_archivo = ' ||"'"||vsFechaArchivo||"'"||
               ' ORDER BY 5, 2' ||
               ';">'||RUTA_DESTINO||vPrefijo||vNombreArchivo||vFechaReporte||'.sql';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '23';
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'chmod 777 ' ||RUTA_DESTINO||vPrefijo||vNombreArchivo||vFechaReporte||'.sql';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '24';
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'dbaccess intercard ' ||RUTA_DESTINO||vPrefijo||vNombreArchivo||vFechaReporte||'.sql';
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '25';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "sed 's/|$//g' "||RUTA_DESTINO||vPrefijo||vNombreArchivo||vFechaReporte||"_01.unl >>"||RUTA_DESTINO||vNombreArchivo||
                       vFechaReporte||".unl";
            SYSTEM vExecuteSQL;
            
            LET vIndicadorProceso = '26';
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'rm -f '||RUTA_DESTINO||vPrefijo||'*';
            SYSTEM vExecuteSQL;


        END FOREACH
			
		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE
DOCUMENT
'Base de datos: bditarjeta',
'Proyecto: Conciliación Corresponsalía - Mastercard',
'#2',
'Fecha de modificacion: 10.enero.2022',
'Descripcion: Generación del reporte final de transaccionalidad previamente conciliada',
'Se realizan mejoras para disminuir bloqueo de tablas, commit por cada 1000 afectaciones.',
'Este componentes es ejecutado por el job 671_CNC_MCO_OXXO_PRO',
'los parametros no son utilizados pero son indispensables por la programación previa del job',
'EXECUTE PROCEDURE "informix".sp_conciliacion_mc_vs_oxxo("sysconau","1");',
'#3',
'Fecha de modificacion: 10.enero.2022',
'Se elimina una condicion de busqueda para obtener los registros y generar el archivo',
'Adicionalmente se actualiza la fecha de actualizacion fecha_hora_gen_conadmin ',
'#4',
'Fecha de modificacion: 19.mayo.2022',
'Se añade la actualización de verdadero cuando finalice el proceso y el campo afectado es conadmin',
'#5',
'Fecha de modificacion: 23.mayo.2022',
'Nueva implementacion en la consulta para extraer los movimientos de comision en la tabla sc_movhis'
;

CREATE PROCEDURE "informix".sp_idmovhis_cnc(dfechafin date)
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	define  vdfechafin       date;	
	define  vFechaFinal      datetime year to fraction(3);
	
   	--  Variables para control de contadores
	define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	define  vconsecutivo		integer;
	define 	varchivoorigen  	CHAR(3);
    define 	vfechacarga      	DATETIME YEAR to FRACTION(3);
    define 	vnombrearchivo   	CHAR(23);
			
	--SET DEBUG FILE TO "/home/c90306398/Pase_Historico_sp_idmovhis_cnc/deltdmovhis.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

--************************************************************
-- Creado por Ricardo ResÃ©ndiz Martinez 
-- fecha : Nov/2012
-- Funcion: Borrado de registros de tablas productivas   
--************************************************************
	
	let     vconsecutivo = 0;
	let 	varchivoorigen = '';
    let 	vfechacarga = current;
    let 	vnombrearchivo = '';
	let		vFechaFinal = TO_DATE((TO_CHAR((dfechafin), '%Y/%m/%d') || ' 23:59:59'), "%Y/%m/%d %H:%M:%S");
	
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	
	
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';

	set isolation to dirty read;
		foreach with hold
				    
			select 	consecutivo, nombrearchivo, archivo_origen, fechacarga 
					into vconsecutivo, vnombrearchivo, varchivoorigen, vfechacarga 
			from bditarjeta:td_movimientos_conciliacion
				where fechacarga <= vFechaFinal
			
			if(vsflagentransaccion = 'F') then
				begin work;
                let vsflagentransaccion = 'V';
            end if;
			
			--  Inserta datos en la tabla historica
		insert into bditarjeta:td_movimientos_conciliacion_his(consecutivo,nombrearchivo,archivo_origen,fechacarga,integridad,integridad_error,numtarjeta,ban_bin,secuencia325,
			   monto325,montocashback325,montosurcharge325,numcuenta,estransfer,idcomercio325,nomcomercio325,tipotransaccion325,referencia23_325,
			   rfc325,divisa325,monto_divisa325,iso323, movrev325,conciliacion,secuencia,secuencia_extendida,codgironeg,montointercard,montocashback,fechatransaccion,
			   infreceptor,idterminal,metodocaptura,movconciliado,movreversado,tipo_mov,folio_mov,fechaconcilia,tipo_conciliacion,
			   desc_conciliacion,b_aplica,aplicacion,transaccion_aplica,bandera_proceso,cod_retorno,fechaaplica,cve_usuario,finalizado,secuencia_ext_archivo,txn_code,indicador_fastfounds,
			   ref_num_fastfounds,diferimiento_promo,parcialiacion_promo,tipo_plan_promo)
		select consecutivo,nombrearchivo,archivo_origen,fechacarga,integridad,integridad_error,numtarjeta,ban_bin,secuencia325,
			   monto325,montocashback325,montosurcharge325,numcuenta, estransfer, idcomercio325,nomcomercio325,tipotransaccion325,referencia23_325,
			   rfc325,divisa325,monto_divisa325,iso323, movrev325,conciliacion,secuencia,secuencia_extendida,codgironeg,montointercard,montocashback,fechatransaccion,
			   infreceptor,idterminal,metodocaptura,movconciliado,movreversado,tipo_mov,folio_mov,fechaconcilia,tipo_conciliacion,
			   desc_conciliacion,b_aplica,aplicacion,transaccion_aplica,bandera_proceso,cod_retorno,fechaaplica,cve_usuario,finalizado,secuencia_ext_archivo,txn_code,indicador_fastfounds,
			   ref_num_fastfounds,diferimiento_promo,parcialiacion_promo,tipo_plan_promo
		from bditarjeta:td_movimientos_conciliacion	  
		where 		consecutivo = vconsecutivo   		and
					nombrearchivo = vnombrearchivo 		and 
					archivo_origen = varchivoorigen 	and 
					fechacarga = vfechacarga;				
			
			--  Borra registro de la Tabla de Movimientos	
			delete from bditarjeta:td_movimientos_conciliacion 
			where 	consecutivo = vconsecutivo   and
					nombrearchivo = vnombrearchivo and 
					archivo_origen = varchivoorigen and 
					fechacarga = vfechacarga;
				
			let vicontadorregistros = vicontadorregistros + 1;
			let vicontadorregistros2 = vicontadorregistros2 + 1;

			if (vicontadorregistros2 = 100000) then 
				update statistics medium for table bditarjeta:td_movimientos_conciliacion;           
				let vicontadorregistros2 = 0;
			end if;

			if (vicontadorregistros = 1000) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table bditarjeta:td_movimientos_conciliacion;      
				let vsflagentransaccion = 'F';
		end if;
		
	--END IF;
	
	RETURN 	P_COD_RET,P_MENSAJE;

	--END IF;

END;

END PROCEDURE
DOCUMENT
'AUTOR: Ricardo ReseÃ©ndiz Martinez',
'Proyecto: Integracion de Conciliacion de Archivos MasterCard',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se le agrego el campo ban_bin para el proceso de trasferencia de datos historicos',
'Fecha: 2014/03/07',
'Version: 20140307.1625',
'BD: BdiTarjeta',
'',
'Modifico: Ricardo ReseÃ©ndiz Martinez',
'Proyecto: IntegraciÃ³n del campo estransfer bandera',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega al proceso el campo es transfer para que el proceso identifique este nuevo campo',
'Fecha: 2014/09/07',
'Version: 20140307.1625',
'BD: BdiTarjeta',
'',
'Modifico: Ricardo ReseÃ©ndiz Martinez',
'Proyecto: RQM 06 384 Proceso de ConciliaciÃ³n de Transacciones Forzadas',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega al proceso nuevos campos para el proceso de validacion de transacciones forzadas',
'Fecha: 2015/07/06',
'Version: 20150706.1900',
'BD: BdiTarjeta',
'Modifico: Cristian Ariel Meza Martinez',
'Proyecto: RQI 32 516 ActualizaciÃ³n campos pase histÃ³rico sp_idmovhis_cnc',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agregan al proceso historico campos faltantes de la tabla historica',
'Fecha: 2025/01/28',
'BD: BdiTarjeta',
'Modifico: LGMR',
'Proyecto: RQI 34 062 - ModificaciÃ³n componentes bditarjeta_sp_idmovhis',
'Solicito: ERS',
'Descripcion: Se agregan datos faltantes de la tabla',
'Fecha: 2025/03/11',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consif
(
	pusuario 				CHAR(9),
	parchivo_origen 		CHAR(3),
	pfecha 					DATE,
	psistema 				CHAR,
	ptran_car 				CHAR(4),
	ptran_lib 				CHAR(4),
	ptran_for 				CHAR(4),
	ptran_abo 				CHAR(4),
	ptran_Extra 			CHAR(4),
	ptran_Extra1 			CHAR (16), --- Transacción de liberación de money gram  ** POSIBLE CAMBIO A 16
	ptipo_conciliacion 		INTEGER,
	pnumtarjeta 			CHAR(16),
	pnumcuenta 				CHAR(20),
	ptipotransaccion325 	CHAR(2),
	pfolio_mov 				CHAR(16),
	pmonto325 				money(16,2),
	pmontoCashBack325 		money(16,2), --- Para el monto de cashback
	pmoneda325 				CHAR(2),
	pnomcomercio325 		CHAR(30),
	prfc325 				CHAR(15),
	preferencia23_325 		CHAR(23),
	pdivisa325 				CHAR(3),
	pmonto_divisa325 		money(16,2),
	pidterminal 			CHAR(16),
	ptipo_mov 				CHAR,
	pconsecutivo 			INTEGER,
	pnombrearchivo 			CHAR(23),
	psecuenciaextendida 	char(15), 
	pestransfer 			char (1),
	pfechaopetransfer 		char(6),
	pidcomercio 			char(9),
	pcuenta 				char(20)
)
RETURNING VARCHAR(6),VARCHAR(80),INTEGER,CHAR(4),INTEGER, VARCHAR(1);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  P_BANDERA        VARCHAR(1);
DEFINE  vtransacion      CHAR(4);
DEFINE  vsistema_aplica  CHAR;
DEFINE  vtransaparencia  VARCHAR(40);
DEFINE  vformaaplica     CHAR;
DEFINE  vid_proceso      INTEGER;
DEFINE vsNuevaSecuencia  VARCHAR(6);
DEFINE vFech_param  	 DATE;
DEFINE vBin              CHAR(6);
DEFINE vBin8             CHAR(8);

-- Para CashBack
DEFINE  vstransaccashback    CHAR(4);
DEFINE  vsTransCarCashBack   CHAR(4);
DEFINE  vsTransLibCashBack   CHAR(4);
DEFINE  vsTransAboCashBack	 CHAR(4);
DEFINE	vsTransForCashBack   CHAR(4);

-- Para Transfer
DEFINE vsmonto325  			char(12);
DEFINE viconcaracteres1 	integer;
DEFINE vsmontocashback325  	char(12);
DEFINE viconcaracteres2 	integer;
DEFINE vssecuencia 			char(6);
DEFINE a					integer;


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE,vid_proceso,vtransacion, ptipo_conciliacion, P_BANDERA;
   END EXCEPTION;

--*****************************************************************
-- APLICACION DE SALDOS                                         --*
-- Creado por: Manuel Osuna Valencia                            --*
-- Fecha: 20/07/2011                                            --*
-- Funcion: Recibe Registros para Aplicar Saldo  a los   		--*
-- clientes (cargo o abono) en lntegral 						--*
--*****************************************************************
-- Modificado por: Manuel Osuna Valencia                        --*
-- Fecha: 05/10/2011                                            --*
-- Funcion: Se modifico para que contabilizara el numero y saldo--*
-- de cargos o abanos que realizara por cada archivo            --*
--*****************************************************************
-- Modificado por: Manuel Osuna Valencia                        --*
-- Fecha: 17/10/2011                                            --*
-- Funcion: Se modifico para especificar bien el campo en el que--*
-- se estara sumarizando los cargos o abanos que realizara      --*
-- por cada archivo                                             --*
--*****************************************************************
-- Modificado por: Manuel Osuna Valencia                        --*
-- Fecha: 27/03/2012                                            --*
-- Funcion: Se modifico parametro de entrada fecha para que el  --*
-- proceso actualizará, fecha y hora, asi como tambien en el    --*
-- proceso cuando el sistema sea Credito y el tipo de conciliacion
-- sea igual a 1 o 10 la forma aplica sería igual a "B"         --*
--*****************************************************************
--*****************************************************************
-- Modificado por: Arturo Méndez Cárdenas                       --*
-- Fecha: 17/04/2012                                            --*
-- Funcion: Se modifico para que se ejecute el SP conciliadebito--*
-- solo cuando el tipo de conciliacion sea igual a 11 ó 14		--*
--*****************************************************************
-- Modificado por: CASANOVA EDEZA HECTOR JUAN                   --*
-- Fecha: 19/04/2012                                            --*
-- Funcion: SE MODIFICO LA LOGICA PARA LA APLICACION DE LAS     --*
-- DEVOLUCIONES, PARA QUE PERMITA APLICAR TODAS LAS TRANSACCIONES --* 
-- MENOS LOS ABONOS/DEVOLUCIONES CON TIPO_CONCILIACION  10 O 12 --*
--*****************************************************************
-- Modificado por: CASANOVA EDEZA HECTOR JUAN                   --*
-- Fecha: 01/10/2012                                            --*
-- Funcion: SE MODIFICA LA LOGICA PARA PERMITIR LAS 			--*
-- TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM) Y 		--*
-- REALIZAR EL ABONO CON LA TRANSACCION CORRESPONDIENTE.		--*
--*****************************************************************

	--SET DEBUG FILE TO "/RESPALDOSNEW/LGMR/bditarjeta/trace_sp_concreing_consif.out"; 
	--TRACE ON;

	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'PROCESO EXITOSO';

	LET vid_proceso = '7';
	LET P_BANDERA = '';

	LET vsistema_aplica = psistema;
	LET vformaaplica = '';
	LET vtransaparencia = '';

	LET vtransacion = '';
   
	LET vsNuevaSecuencia = '';
    LET vFech_param = " ";
    LET vBin = '';
	LET vBin8 = '';
	
	--Para CashBack
	LET vstransaccashback = '';
	LET vsTransCarCashBack = '';
	LET vsTransLibCashBack= '';
	LET vsTransAboCashBack = '';
	LET	vsTransForCashBack = '';

--   PARA DEFINICION DE TRANSACCIONES DE CASH back	
	LET vsTransCarCashBack = TRIM(SUBSTR(ptran_Extra1,1,4));
	LET vsTransLibCashBack = TRIM(SUBSTR(ptran_Extra1,5,4));
	LET	vsTransForCashBack = TRIM(SUBSTR(ptran_Extra1,9,4));
	LET vsTransAboCashBack = TRIM(SUBSTR(ptran_Extra1,13,4));
	
-- Para ciclo de conversion de monto para transfer
	let vsmonto325 = '';
	let viconcaracteres1 = 0;
	let vsmontocashback325 = '';
	let viconcaracteres2 = 0;
	let vssecuencia = '';
	let a = 0; -- Controlador 
	
        
     -- // OBTENGO PARAMETROS
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT FIRST 1 fecha_hoy - 10 UNITS DAY
	INTO vFech_param
	FROM bdinteg:si_fechas
	WHERE empresa = '001';

	IF (NOT((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('10','12','25','47')))) THEN 
	--SE APLICAN LOS ABONOS QUE NO TENGAN ESTATUS DEV. CONCILIADA(12) NI DEV. NO APLICADA(10)
				-- SET LOCK MODE TO WAIT 3;
				/*SET ISOLATION TO DIRTY READ; Se quita ya se tienen el dato desde la obtencion del resgitro 
				--OBTIENE EL NUMERO DE CUENTA RELACIONADO A LA TARJETA
				SELECT FIRST 1 NumCuenta
				INTO pnumcuenta
				FROM Intercard:tarjetacuenta
				WHERE numtarjeta = pnumtarjeta;*/
			if pestransfer <> 'V' then 
				IF (ptipo_conciliacion IN (1,2,3,4,5) ) THEN 
					LET vtransacion  =  ptran_car ;

				ELIF (ptipo_conciliacion IN (8,13)) THEN 
					LET vtransacion  =  ptran_for ;

				ELIF (ptipo_conciliacion IN (10,11, 14)) THEN 
					LET vtransacion  =  ptran_abo ;
				
				ELIF (ptipo_conciliacion IN (20,21,22,23,24,36,41,42,43,37,38,39,40,44,45,46)) THEN
					LET vtransacion = ptran_car;
					LET vstransaccashback = vsTransCarCashBack; --vsTransCarCashBack
				
				ELIF (ptipo_conciliacion IN (28,31,33)) THEN
					LET vtransacion  =  ptran_for ;
					LET	vstransaccashback = vsTransForCashBack;  -- vsTransForCashBack
				
				ELIF (ptipo_conciliacion IN ( 48,49)) THEN
					LET vtransacion  =  ptran_abo;
					LET vstransaccashback = vsTransAboCashBack; -- vsTransAboCashBack

				ELIF ( ptipo_conciliacion == 0 AND ptipotransaccion325 == 20) THEN --PNC y VIC (MONEYGRAM)

					LET vtransacion  = CASE WHEN (parchivo_origen = 'PNC') THEN ptran_abo /*PNC*/ 
											WHEN (parchivo_origen = 'VID') THEN ptran_Extra /*VID*/
											ELSE ptran_abo /*DEFAULT*/ END;
					
					LET ptipo_mov = 'A'; -- ABONOS [A]
					
					--SET LOCK MODE TO WAIT 3;
					--SET ISOLATION TO DIRTY READ;
					--OBTIENE UNA SECUENACIA DE AUTORIZACION PARA TRANSACCIONES QUE NO PASAN POR EL AUTORIZADOR
					EXECUTE PROCEDURE Intercard:sp_GetSecuencia (CASE WHEN (parchivo_origen = 'PNC') THEN 22 /*PNC*/ 
																				 WHEN (parchivo_origen = 'VID') THEN 23 /*VID*/
																				 ELSE 22 /*DEFAULT*/ END ) 
					INTO vsNuevaSecuencia; -- GENERA UNA SECUENCIA
					
					--GENERA EL FOLIO_MOV PARA EL PNC [iMMDD3secuencia]
					LET pfolio_mov = 'i' || REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 5), '/', '' ) || REPLACE (SUBSTRING (CURRENT FROM 12 FOR 6), ':', '' ) || '3' || LPAD ( TRIM ( vsNuevaSecuencia ), 6, '0' );
					
					--SET LOCK MODE TO WAIT 3;
					--SET ISOLATION TO DIRTY READ;
					--ACTUALIZA EL NUMERO DE CUENTA DE LOS REGISTROS QUE NO LO TIENEN (POS)
					--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
					UPDATE BdiTarjeta:Td_Movimientos_Conciliacion
					SET --NumCuenta = pnumcuenta, Se quita la actualización dato que el dato qya existe en la tabla en cuestion -- Transfer
							Tipo_Mov = ptipo_mov, -- ABONOS [A]
							Folio_Mov = pfolio_mov -- FOLIO PARTICULAR PARA PNC
					WHERE consecutivo = pconsecutivo  
					AND nombrearchivo = pnombrearchivo ;
					
					
				ELSE --NINGUN CASO CONCUERDA
					LET vtransacion = '';
					LET psistema = '';
				END IF;
			else				
				IF (ptipo_conciliacion IN (1,2,3,4,5) ) THEN 
					LET vtransacion  =  ptran_lib ;

				ELIF (ptipo_conciliacion IN (8,13)) THEN 
					LET vtransacion  =  ptran_for ;

				ELIF (ptipo_conciliacion IN (10,11, 14)) THEN 
					LET vtransacion  =  ptran_abo ;
				
				ELIF (ptipo_conciliacion IN (20,21,22,23,24,36,41,42,43,37,38,39,40,44,45,46)) THEN
					LET vtransacion = ptran_lib;
					LET vstransaccashback = vsTransCarCashBack; --vsTransCarCashBack
				
				ELIF (ptipo_conciliacion IN (28,31,33)) THEN
					LET vtransacion  =  ptran_for ;
					LET	vstransaccashback = vsTransForCashBack;  -- vsTransForCashBack
				
				ELIF (ptipo_conciliacion IN ( 48,49)) THEN
					LET vtransacion  =  ptran_abo;
					LET vstransaccashback = vsTransAboCashBack; -- vsTransAboCashBack

				ELIF ( ptipo_conciliacion == 0 AND ptipotransaccion325 == 20) THEN --PNC y VIC (MONEYGRAM)

					LET vtransacion  = CASE WHEN (parchivo_origen = 'PNC') THEN ptran_abo /*PNC*/ 
											WHEN (parchivo_origen = 'VID') THEN ptran_Extra /*VID*/
											ELSE ptran_abo /*DEFAULT*/ END;
					
					LET ptipo_mov = 'A'; -- ABONOS [A]
					
					--SET LOCK MODE TO WAIT 3;
					--SET ISOLATION TO DIRTY READ;
					--OBTIENE UNA SECUENACIA DE AUTORIZACION PARA TRANSACCIONES QUE NO PASAN POR EL AUTORIZADOR
					EXECUTE PROCEDURE Intercard:sp_GetSecuencia (CASE WHEN (parchivo_origen = 'PNC') THEN 22 /*PNC*/ 
																				 WHEN (parchivo_origen = 'VID') THEN 23 /*VID*/
																				 ELSE 22 /*DEFAULT*/ END ) 
					INTO vsNuevaSecuencia; -- GENERA UNA SECUENCIA
					
					--GENERA EL FOLIO_MOV PARA EL PNC [iMMDD3secuencia]
					LET pfolio_mov = 'i' || REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 5), '/', '' ) || REPLACE (SUBSTRING (CURRENT FROM 12 FOR 6), ':', '' ) || '3' || LPAD ( TRIM ( vsNuevaSecuencia ), 6, '0' );
					
					--SET LOCK MODE TO WAIT 3;
					--SET ISOLATION TO DIRTY READ;
					--ACTUALIZA EL NUMERO DE CUENTA DE LOS REGISTROS QUE NO LO TIENEN (POS)
					--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
					UPDATE BdiTarjeta:Td_Movimientos_Conciliacion
					SET --NumCuenta = pnumcuenta, Se quita la actualización dato que el dato qya existe en la tabla en cuestion -- Transfer
							Tipo_Mov = ptipo_mov, -- ABONOS [A]
							Folio_Mov = pfolio_mov -- FOLIO PARTICULAR PARA PNC
					WHERE consecutivo = pconsecutivo 
					AND nombrearchivo = pnombrearchivo;
					
					
				ELSE --NINGUN CASO CONCUERDA
					LET vtransacion = '';
					LET psistema = '';
				END IF;
			end if
				

		--ASEGURA EL BLOQUE TRANSACCION, ANTES DE ABONO_REF Y CARGO_REF
			COMMIT WORK;   -- Para pruebas se comenta 
			BEGIN WORK;
		
		IF ((vtransacion <> '') AND (psistema <> '')) THEN
		
			IF (psistema == "D" ) THEN
			--insert into bditarjeta:td_conciliadebito values ('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',prfc325,preferencia23_325);
				--SET ISOLATION TO DIRTY READ;
				--SET LOCK MODE TO WAIT 3;
				   
				  
				IF (parchivo_origen == 'TCD') THEN --AGREGA COPPEL AL NOMBRE DE COMERCIO PARA LOS ARCHIVOS TCC Y TCD
					LET pnomcomercio325 = 'COPPEL ' || TRIM(pnomcomercio325);
				END IF
				
				-- AQUI SE MODIFICARÁ (EJECUTAR sp CUANDO TIPO_CONCILIACION IN(11,14), 
				-- Y VALIDAR EL RESULTADO(SI ES 15 PONER EL ERROR INESPERADO))
				-- ########## Para partir el proceso y mandarlo directo o por proceso actual TRANSFER  ####################################################
				if ( pestransfer = 'V') then 
					-- ########  Proceso para convertir monto de compra a char  ########
					LET vsmonto325 = CAST(pmonto325 as CHAR(13));
					LET vsmonto325 = REPLACE(REPLACE(vsmonto325,'$',''),'.',''); 
					LET viconcaracteres1 = Length(vsmonto325);
						FOR  a = viconcaracteres1  TO 11 STEP 1
								LET vsmonto325 = '0'||vsmonto325;
						END FOR;
					-- ######## Proceso para convertir monto de cahs back a char #######
					if pmontoCashBack325 > 0 then 
						LET vsmontocashback325 = CAST(pmontoCashBack325 as CHAR(13));
						LET vsmontocashback325 = REPLACE(REPLACE(vsmontocashback325,'$',''),'.',''); 
						LET viconcaracteres2 = Length(vsmonto325);
						FOR  a = viconcaracteres2  TO 11 STEP 1
							LET vsmontocashback325 = '0'||vsmonto325;
						END FOR;
					end if;
					
					if (pmonto325 > 0) and  (pmontoCashBack325 = 0) then -- Transacción de solo compra
						if ptipo_mov = 'A' then 
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsMonto325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;
								
						elif ptipo_mov = 'C' then
							execute procedure Bdicheq:sp_transfer_regtrxconciliacion(
																							pfolio_mov, -- Folio suc del registro
																							'9290', -- Numero de la sucursal
																							pusuario, 
																							vtransacion, 
																							pcuenta, 
																							pmonto325, 
																							pnomcomercio325, 
																							pnumtarjeta)INTO P_COD_RET;
																							
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsMonto325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;
						end if;
					Elif (pmonto325 = 0) and  (pmontoCashBack325 > 0) then -- Transacción CashAdvance
						if ptipo_mov = 'A' then 
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsmontocashback325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;
						elif ptipo_mov = 'C' then
							execute procedure bdicheq:sp_transfer_regtrxconciliacion(	pfolio_mov, -- Folio suc del registro
																							'9290', -- Numero de la sucursal
																							pusuario, 
																							vstransaccashback, 
																							pcuenta, 
																							pmontoCashBack325, 
																							pnomcomercio325, 
																							pnumtarjeta)INTO P_COD_RET;
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vstransaccashback, ptipotransaccion325,	psecuenciaextendida, 
																			vsmontocashback325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;
						end if;					
					Elif (pmonto325 > 0) and  (pmontoCashBack325 > 0) then 	-- Transacción de compra con CashBack		
						IF ptipo_mov = 'A' then 
							-- Para la compra
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsMonto325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;						
							-- Para el Cash back
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vstransaccashback, ptipotransaccion325,	psecuenciaextendida, 
																			vsmontocashback325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;

						elif ptipo_mov = 'C' then
							-- Para la compra
							execute procedure Bdicheq:sp_transfer_regtrxconciliacion(	pfolio_mov, -- Folio suc del registro
																							'9290', -- Numero de la sucursal
																							pusuario, 
																							vtransacion, 
																							pcuenta, 
																							pmonto325, 
																							pnomcomercio325, 
																							pnumtarjeta)INTO P_COD_RET;
							-- Para el Cash back
							execute procedure Bdicheq:sp_transfer_regtrxconciliacion(	pfolio_mov, -- Folio suc del registro
																							'9290', -- Numero de la sucursal
																							pusuario, 
																							vstransaccashback, 
																							pcuenta, 
																							pmontoCashBack325, 
																							pnomcomercio325, 
																							pnumtarjeta)INTO P_COD_RET;
							-- Para la compra
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsMonto325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;						
							-- Para el Cash back
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vstransaccashback, ptipotransaccion325,	psecuenciaextendida, 
																			vsmontocashback325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;

						end if;					
					End if;
				else  ---  ##############################   PROCESO ACTUAL DE CONCILIACION   ######################################
				
					IF (pmonto325 > 0) and  (pmontoCashBack325 = 0) then -- Transacción de solo compra
							EXECUTE PROCEDURE bdicheq:conciliadebito(
																	'001',  			-- Numero de la empresa
																	pnumtarjeta,		-- Numero de tarjeta
																	'9290',				-- Numero de la sucursal
																	pusuario,			-- Usuario que ejecuta 
																	ptipo_mov,			-- TIpo de movimiento C ó A
																	vtransacion,		-- Numero de transacción de compra
																	pfolio_mov,			-- Folio suc del registro
																	pmonto325,			-- Monto de la compra
																	pmoneda325,			-- Id de la moneda
																	pnomcomercio325,	-- Nombre del comercio 325
																	'000000000000000',	--
																	prfc325,			-- RFC del comercio 325
																	preferencia23_325	-- Referencia 23-325
																) INTO P_COD_RET,P_BANDERA;
					Elif (pmonto325 = 0) and  (pmontoCashBack325 > 0) then -- Transacción CashAdvance
							EXECUTE PROCEDURE bdicheq:conciliadebito(
																	'001',  			-- Numero de la empresa
																	pnumtarjeta,		-- Numero de tarjeta
																	'9290',				-- Numero de la sucursal
																	pusuario,			-- Usuario que ejecuta 
																	ptipo_mov,			-- TIpo de movimiento C ó A
																	vstransaccashback,		-- Numero de transacción de compra
																	pfolio_mov,			-- Folio suc del registro
																	pmonto325,			-- Monto de la compra
																	pmontoCashBack325,			-- Id de la moneda
																	pnomcomercio325,	-- Nombre del comercio 325
																	'000000000000000',	--
																	prfc325,			-- RFC del comercio 325
																	preferencia23_325	-- Referencia 23-325
																) INTO P_COD_RET,P_BANDERA;
					Elif (pmonto325 > 0) and  (pmontoCashBack325 > 0) then 	-- Transacción de compra con CashBack		
							EXECUTE PROCEDURE bdicheq:conciliadebito(
																	'001',  			-- Numero de la empresa
																	pnumtarjeta,		-- Numero de tarjeta
																	'9290',				-- Numero de la sucursal
																	pusuario,			-- Usuario que ejecuta 
																	ptipo_mov,			-- TIpo de movimiento C ó A
																	vtransacion,		-- Numero de transacción de compra
																	pfolio_mov,			-- Folio suc del registro
																	pmonto325,			-- Monto de la compra
																	pmoneda325,			-- Id de la moneda
																	pnomcomercio325,	-- Nombre del comercio 325
																	'000000000000000',	--
																	prfc325,			-- RFC del comercio 325
																	preferencia23_325	-- Referencia 23-325
																) INTO P_COD_RET,P_BANDERA;
							EXECUTE PROCEDURE bdicheq:conciliadebito(
																	'001',  			-- Numero de la empresa
																	pnumtarjeta,		-- Numero de tarjeta
																	'9290',				-- Numero de la sucursal
																	pusuario,			-- Usuario que ejecuta 
																	ptipo_mov,			-- TIpo de movimiento C ó A
																	vstransaccashback,	-- Numero de transacción de cash back
																	pfolio_mov,			-- Folio suc del registro
																	pmontoCashBack325,	-- Monto de la compra
																	pmoneda325,			-- Id de la moneda
																	pnomcomercio325,	-- Nombre del comercio 325
																	'000000000000000',	--
																	prfc325,			-- RFC del comercio 325
																	preferencia23_325	-- Referencia 23-325
																) INTO P_COD_RET,P_BANDERA;
					End if;
				end if;			
				
				IF (parchivo_origen == 'VND') THEN
					LET vtransaparencia  = TRIM(prfc325) || ' ' || TRIM(pnomcomercio325) ||' ' || SUBSTR(NVL(pfolio_mov,''),11,6);
				ELIF (parchivo_origen == 'VID') THEN
					LET vtransaparencia  = TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6)|| ' ' || pmonto_divisa325 || ' ' || pdivisa325;
				ELIF (parchivo_origen == 'MCD') THEN
					LET vtransaparencia  = TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6)|| ' ' || pmonto_divisa325 || ' ' || pdivisa325;
				ELIF (parchivo_origen == 'TCD') THEN
					--i123120311794341
					LET vtransaparencia  = TRIM(prfc325) || ' ' || TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6);
					
				ELIF (parchivo_origen == 'TMD') THEN

					LET vtransaparencia  = pidterminal;

				END IF;

				IF (TRIM(vtransaparencia) <> '') THEN 
					IF (P_BANDERA == 'C') THEN
						
						--REGISTRA LA REFERENCIA DE LA OPERACION EN MOVHIS
                        IF (parchivo_origen == 'TMD') THEN
                            
							
							UPDATE --{+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
                            bdicheq:sc_movhis  
                            SET  referencia = TRIM(NVL(referencia,'')) || vtransaparencia 
                            --WHERE empresa = '001' and cuenta = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
                            WHERE fech_alt >= vFech_param
                            AND transacc = vtransacion
                            AND empresa = '001'
					        AND cuenta = TRIM(pnumcuenta)					        
					        AND cancelad <> "S"					        
					        AND folio_suc = TRIM(pfolio_mov);
								
                        ELSE						
						
						    UPDATE --{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                            bdicheq:sc_movdia  
                            SET  referencia = TRIM(NVL(referencia,'')) || vtransaparencia 
                            WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
							
                        END IF;
						
						
		
					ELIF (P_BANDERA == 'A') THEN
						
						
						--REGISTRA LA REFERENCIA DE LA OPERACION EN MOVDIA
						UPDATE ---{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                        bdicheq:sc_movdia 
                        SET  referencia = referencia || vtransaparencia 
                        WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);

					END IF;
				END IF;
				
				--ACTUALIZA EL REGISTRO COMO APLICADO
				--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
				UPDATE bditarjeta:td_movimientos_conciliacion 
                SET  aplicacion = 'V',transaccion_aplica = vtransacion,bandera_proceso = 'C',cod_retorno = '000',fechaaplica = current, cve_usuario = pusuario 
                WHERE consecutivo = pconsecutivo AND nombrearchivo = pnombrearchivo ;
				
				IF ( ptipo_conciliacion IN (8,13) ) THEN

					UPDATE --{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                    bdicheq:sc_movdia  
                    SET  referencia = preferencia23_325  
                    WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
					
				ELIF ( ptipo_conciliacion = 0) THEN  --   Para agregar referencia para Money Gram
				
					UPDATE --{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                    bdicheq:sc_movdia  
                    SET  referencia = SUBSTR(NVL(preferencia23_325,''),15,9) 
                    WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
				
				-- Se separa Para poner la ley de transparanecia cuando son devoluciones del dia 
				
				ELIF ( ptipo_conciliacion = 11) and (parchivo_origen in ('VID', 'VND', 'MCD') )  THEN

					UPDATE --{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                    bdicheq:sc_movdia  
                    SET  referencia = TRIM(NVL(referencia,'')) || vtransaparencia
                    WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
		
				END IF;

				IF (P_COD_RET <> '000') THEN

					--ACTUALIZA EL ESTATUS DE LA APLICACION  
					--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
					UPDATE bditarjeta:td_movimientos_conciliacion  
							SET tipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE tipo_conciliacion END), 
							aplicacion = 'F',transaccion_aplica = vtransacion,bandera_proceso = 'E',fechaaplica = current, cve_usuario = pusuario,cod_retorno = P_COD_RET 
						WHERE consecutivo = pconsecutivo  
					AND nombrearchivo = pnombrearchivo;
					
					LET ptipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE ptipo_conciliacion END);
					
				END IF;

		ELIF (psistema == 'C' ) THEN

				--IF ( ptipo_conciliacion == 1  ) THEN
				IF ( ptipo_conciliacion IN (1,2,3,4,5)) THEN 
					LET vformaaplica  =  "B" ;   -- Cuando los datos corresponden completamente 
				--ELIF ( ptipo_conciliacion IN (2,3,4,5,11,14)) THEN 
				ELIF ( ptipo_conciliacion IN (13)) THEN 
					LET vformaaplica  =  "X" ; --Cuando hay diferencias en los montos del 325 a los de Intercard
				ELIF ( ptipo_conciliacion IN (0,8,11,14)) THEN 
					LET vformaaplica  =  "A" ; -- Cuando Hay que aplicar forzados los movimientos 
				END IF;
				
				-- La '6' no se clasifica ya que no debe paras a aplicacion por ser un movimiento que se detecto como previa mente conciliado
				-- La '7' no se clasifica por hacer referencia a una operacion reversada donde el campo formato es igual a 0420
				-- La '9' no se clasifica ya que al estar rechazado el movimiento original no procede su conciliacion para la aplicacion
				-- La '10' no se aplica la devolucion ya que al no cuprir todos los requisitos solamente habre de clasificarse por inprocedencia
				-- La '12' no se clasifica ya que al ser una devolucion que no aplica por errores de integridad
				-- La '13' no se clasifica por hacer referencia a una operacion reversada donde el campo formato es igual a 0220
				-- Lo 15 no se clasifica por estar marcada como error 
				-- La 16 no se aplica por ser de una cartera vendida 

				--insert into bditarjeta:td_conciliatc values ('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',vformaaplica,prfc325,preferencia23_325);
				
				IF (parchivo_origen == 'TCC') THEN --AGREGA COPPEL AL NOMBRE DE COMERCIO PARA LOS ARCHIVOS TCC Y TCD
					LET pnomcomercio325 = 'COPPEL ' || TRIM(pnomcomercio325);
				END IF
			
	/*INICIA VALIDACIÓN BIN SMART VISTA */
	
				IF (parchivo_origen == "VNC") OR (parchivo_origen == "VIC") OR (parchivo_origen == "PNC") THEN
				
					--Validación del bin de UNITY
					LET vBin8 = SUBSTR(pnumtarjeta,1,8);
					
					IF (vBin8 = '42680711') THEN
						LET P_COD_RET = '000';
						LET P_BANDERA =  vformaaplica;
						
				--ACTUALIZA EL REGISTRO COMO APLICADO
						
				UPDATE bditarjeta:td_movimientos_conciliacion  
				SET  aplicacion = 'V', transaccion_aplica = vtransacion, bandera_proceso = 'C', cod_retorno = '000', 
				fechaaplica = current, cve_usuario = pusuario  
				WHERE consecutivo = pconsecutivo  
				AND nombrearchivo = pnombrearchivo;	
								
					ELSE
					
						EXECUTE PROCEDURE bdicred:conciliatc('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',vformaaplica,prfc325,preferencia23_325) INTO P_COD_RET,P_BANDERA;				  
					
					END IF ;
				ELSE
						
				
	/*TERMINA VALIDACIÓN BIN SMART VISTA */			
				

                --Validación del bin de Tarjeta de Crédito Coppel Mastercard
                LET vBin = SUBSTR(pnumtarjeta,1,6);
                
                --validación de Tarjeta de Crédito Coppel - Mastercard 
                IF ( vBin = '514014' ) OR (vBin8 = '42680711') THEN  ---- SE AÑADE BIN SMART
                    LET P_COD_RET = '000';
                    LET P_BANDERA =  vformaaplica;
                ELSE
                
                    EXECUTE PROCEDURE bdicred:conciliatc('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',vformaaplica,prfc325,preferencia23_325) INTO P_COD_RET,P_BANDERA;
               
                 END IF ;
				
			END IF;
                
				IF (parchivo_origen == "VNC") THEN
					LET vtransaparencia  = TRIM(prfc325) || ' ' || TRIM(pnomcomercio325);
				ELIF (parchivo_origen == "VIC") THEN
					LET vtransaparencia  = pmonto_divisa325 || ' ' || pdivisa325;
				ELIF (parchivo_origen == "MCC") THEN
					LET vtransaparencia  = pmonto_divisa325 || ' ' || pdivisa325;
				ELIF (parchivo_origen == 'TCC') THEN
					--i123120311794341
					LET vtransaparencia  = TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6);
					
				ELIF (parchivo_origen == "TMC") THEN

					LET vtransaparencia  = pidterminal;

				END IF;

				IF (TRIM(vtransaparencia) <> '') THEN 
					IF (P_BANDERA == "C") THEN
						--REGISTRA LA REFERENCIA DE LA OPERACION EN MOVHIS
						IF(parchivo_origen == 'TMC') THEN
						
                            UPDATE --{+INDEX(bdicred:sd_movhis inx_movhis4)}
                            bdicred:sd_movhis  
                            SET  referencia = TRIM(referencia) || vtransaparencia 
                            WHERE empresa = '001' and fecha_mov is not null and
                            num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
							
                        ELSE
						
                            UPDATE --{+INDEX(bdicred:sd_movdia mov3)}
                            bdicred:sd_movdia 
                            SET  referencia = referencia || vtransaparencia 
                            WHERE empresa = '001' and num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
							
						END IF;
						
					
					ELIF (P_BANDERA == "A") THEN
						
						UPDATE --{+INDEX(bdicred:sd_movdia mov3)}
                        bdicred:sd_movdia 
                        SET  referencia = referencia || vtransaparencia 
                        WHERE empresa = '001' and num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
						
					END IF;
				END IF;

				--ACTUALIZA EL REGISTRO COMO APLICADO
				--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
				UPDATE bditarjeta:td_movimientos_conciliacion  
                    SET  aplicacion = 'V', transaccion_aplica = vtransacion, 
                            bandera_proceso = 'C', cod_retorno = '000', 
                         fechaaplica = current, cve_usuario = pusuario  
                WHERE consecutivo = pconsecutivo  
                    AND nombrearchivo = pnombrearchivo;				
				
				--   Para aplicar ley de transparencia a los registros de devolucion
				IF ( ptipo_conciliacion == 11 ) and (parchivo_origen IN ('VIC', 'VNC','MCC'))  THEN
						
						UPDATE --{+INDEX(bdicred:sd_movdia mov3)}
                        bdicred:sd_movdia 
                        SET  referencia = referencia || vtransaparencia 
                        WHERE empresa = '001' and num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);

				END IF;	 
				
				IF (P_COD_RET <> "000") THEN
					
					--ACTUALIZA EL ESTATUS DE LA APLICACION
					--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
					UPDATE bditarjeta:td_movimientos_conciliacion  
							SET tipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE tipo_conciliacion END), 
							aplicacion = 'F',
							transaccion_aplica = vtransacion,
							bandera_proceso = 'E',
							fechaaplica = current,
							cve_usuario = pusuario,
							cod_retorno = P_COD_RET 
						WHERE consecutivo = pconsecutivo  
						AND nombrearchivo = pnombrearchivo;
						
					LET ptipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE ptipo_conciliacion END);

				END IF;

			END IF;
		   
		   -- Se modifica suma para integrar montos CashBack )
			IF ((P_COD_RET == '000') AND (ptipo_mov == 'C')) THEN --INCREMENTA EL NUMERO DE CARGOS APLICADOS
			
				UPDATE bditarjeta:td_archivos_conciliacion SET num_cargo = num_cargo + 1, monto_cargo = monto_cargo + (pmonto325 + pmontoCashBack325)  WHERE nombrearchivo = pnombrearchivo;
				
			ELIF ((P_COD_RET == '000') AND (ptipo_mov == 'A')) THEN --INCREMENTA EL NUMERO DE ABONOS APLICADOS
			
				UPDATE bditarjeta:td_archivos_conciliacion SET num_abono = num_abono + 1,monto_abono = monto_abono + (pmonto325 + pmontoCashBack325) WHERE nombrearchivo = pnombrearchivo;
				
			END IF;	
			
		ELSE --TRANSACCIONES QUE NO SE PROCESAN (CARGO O ABONO) 
			-- NO REALIZA EL PROCESO DE APLICACION Y ESTABLECE EL REGISTRO COMO FINALIZADO DE PROCESAR
			LET P_COD_RET = '00000'; 
		END IF;
	ELSE -- DEVOLUCIONES QUE NO APLICAN
		-- NO REALIZA EL PROCESO DE APLICACION Y ESTABLECE EL REGISTRO COMO FINALIZADO DE PROCESAR
		LET P_COD_RET = '00000'; 
	END IF;

	
   RETURN LPAD(TRIM(P_COD_RET), 5, '0'),P_MENSAJE,vid_proceso,vtransacion, ptipo_conciliacion, P_BANDERA;
   
END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICO LA LOGICA PARA LA APLICACION DE LAS DEVOLUCIONES, PARA QUE PERMITA APLICAR TODAS LAS TRANSACCIONES MENOS LOS ABONOS/DEVOLUCIONES CON TIPO_CONCILIACION  10 O 12.',
'Fecha: 2012/04/19',
'Version: 20120419.1756',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion -DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA QUE NO PERMITA PROCESAR LAS OPERACIONES DE TIPOS NO RELACIONADOS CON EL PROCESO DE CARGO Y ABONO.',
'Fecha: 2012/05/21',
'Version: 20120521.1547',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL PARAMETRO PARA MANDAR LA TRANSACCION DE CARGO.',
'Fecha: 2012/07/31',
'Version: 20120731.1214',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA ASIGNAR LOS VALORES REQUERIDOS (TIPO_MOV Y CUENTA) A LOS REGISTROS DE PNC PARA SU APLICACION.',
'Fecha: 2012/08/10',
'Version: 20120810.1051',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA LOGICA PARA GENERAR EL FOLIO_MOV PARA LOS REGISTROS PNC.',
'Fecha: 2012/08/13',
'Version: 20120813.1641',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA ASIGNAR LA LEY DE TRANSPARENCIA PARA LOS REGISTROS DE TIENDAS COPPEL.',
'Fecha: 2012/09/19',
'Version: 20120919.1730',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA OBTENER EL NUMERO DE CUENTA PARA TODOS LOS REGISTROS.',
'Fecha: 2012/09/20',
'Version: 20120920.1755',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA GENERAR CAMPO DE TRANSPARENCIA PARA LOS REGISTROS DE VND Y VNC.',
'Fecha: 2012/09/26',
'Version: 20120926.1031',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA PERMITIR LAS TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM) Y REALIZAR EL ABONO CON LA TRANSACCION CORRESPONDIENTE.',
'Fecha: 2012/10/01',
'Version: 20121001.1059',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: HOMOLOGACION DE CODIGO - INDICES',
'Fecha: 2012/10/12',
'Version: 20121012.1030',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto:  RQI 13 284 Aplicación Ley de transparencia para registros de devoluciones forzadas',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Actualizacion de Ley de transparencia para la devoluciones forzadas',
'Fecha: 2013/02/11',
'Version: 20130205.1600',
'BD: Bditarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto:  Integración de transacciones CashBack en proceso de conciliacion',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego ciclo para validar aplicación de trasacciones en tres esenarios y formeteo de cadena para las tres transacciones ',
'Fecha: 2013/08/06',
'Version: 20130806.1500',
'BD: Bditarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto:  Integracion de Ley de transparencia para MASTER CARD ',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agregaron los filtros pertinentes ',
'Fecha: 2014/04/04',
'Version: 20140404.1840',
'BD: Bditarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: RQI 13 276 Transfer',
'Solicito: Jose Luis Puebla Salinas ',
'Descripcion: Se comenta codigo para la recuperacion de cuenta para no repetir procesos y se integra proceso para registro si la operacion es transfer',
'Fecha: 2014/08/28',
'Version: 20140828.1300',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: RQI 13 276 Transfer',
'Solicito: Jose Luis Puebla Salinas ',
'Descripcion: Se aplica proceso para identificar las transacciones en el caso de operaciones que sean de Transfer',
'Fecha: 2014/10/08',
'Version: 20141008.1400',
'BD: BdiTarjeta',
'',
'MODIFICACION: CATIT - Christopher Jose Leyva Castro',
'Proyecto: RQI 32 492 Mejora conciliación automática primera parte 2024',
'Solicito: Gerencia de Producción ',
'Descripcion: Se realiza optimización a nivel sintaxis para aprovechar algunas llaves primarias',
'Fecha: 2024/10/22',
'BD: BdiTarjeta',
'MODIFICACION: CATIT - Luis Gerardo Martínez Rangel',
'Proyecto: Exclusión BIN SMARTVISTA de la conciliación ',
'Solicito: José Jaimes Ortiz ',
'Descripcion: Se realiza liberación para la esxclusión del BIN DE SMARTVISTA 42680711 y su aplicación sea en V ',
'Fecha: 2025/09/26',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_bf_extrae_tbl_mov (psFechaInicio VARCHAR(10) , psFechaFin VARCHAR(10))

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				 CHAR (6);
			DEFINE MENSAJE_RPTA			 CHAR (80);
			DEFINE vdFechaInicio		 DATETIME YEAR TO FRACTION (5);
			DEFINE vdFechaFin			 DATETIME YEAR TO FRACTION (5);
			DEFINE RUTA_DESTINO 		 VARCHAR(80);
			DEFINE TIPO_PLANTILLA		 VARCHAR(30);
			DEFINE vsql					 CHAR(1150);
			DEFINE vExecuteSQL 			 LVARCHAR(1500);

	BEGIN	
		
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
				
		  LET CODIGO    = SQL_ERR;
		  LET MENSAJE_RPTA  = ERROR_INFO;
		  
		  RETURN CODIGO, MENSAJE_RPTA;
		  
		END EXCEPTION;
		
			--SET DEBUG FILE TO "/RESPALDOSNEW/Buen_Fin/bf2023_mov_debug.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vdFechaInicio			= CURRENT;
				LET vdFechaFin				= CURRENT;
				LET RUTA_DESTINO	 		= '/RESPALDOSNEW/';
				LET TIPO_PLANTILLA	 		= '';
				LET vsql					= '';
				LET vExecuteSQL				= '';

				
			--SET ISOLATION TO dirty READ;
			--SET LOCK MODE TO WAIT 3;	
	
				/* Se da formato de fechahorainauth como se encuentra en movimiento*/
			
			LET vdFechaInicio = psFechaInicio || ' 00:00:00.00000';
			LET vdFechaFin 	  = psFechaFin || ' 23:59:59.99999';
							
				/* SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA DE MOVIMIENTO */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "UNLOAD TO '||RUTA_DESTINO||'bf_movimiento.unl'||
		                          ' SELECT secuencia,numtarjeta,NVL (monto ,0 ) AS monto ,secuenciaextendida,fechahorainauth,referencia,prodind,codigoiso,'||
		                          ' movreversado,esnacional,movconciliado,formato,transaccionorigen,NVL (tipotransaccionposdigitada ,\"\" ) AS tipotransaccionposdigitada '||
		                          ' FROM Intercard:movimiento '||
		                          ' WHERE fechahorainauth BETWEEN '||"'"|| vdFechaInicio||"'"||' AND '||"'"|| vdFechaFin ||"'"||
		                          ' AND prodind = \"02\"		 		 	'||
		                          ' AND formato = \"0200\"  	 	 	 	'||
		                          ' AND codigoiso = \"00\"  	 	 	 	'||
		                          ' AND esnacional = \"V\" 		 	 	'||
		                          ' AND transaccionorigen = \"1234\" 	 	'||
		                          ' AND movreversado = \"F\"				'||							
		                          ' AND movconciliado IN (\"P\",\"V\")	'||
		                          ' AND monto >= 250	'||
								  'AND SUBSTRING(numtarjeta FROM 1 FOR 8) IN (SELECT bin FROM bditarjeta:bines_buenfin WHERE participa = \"V\") '||
		                          'AND pcc <> \"02\" '|| --Se excluyen cargos recurrentes
		                          ';" >'|| 
		        RUTA_DESTINO||'bf_mov.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess intercard  '||RUTA_DESTINO||'bf_mov.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| RUTA_DESTINO ||
								  'bf_movimiento.unl' || "' delimiter '|' "|| '14'||
									"; insert into tbl_bf_movimientos_sorteo" || ";"||'"'||' > carga_movimientos.txt';
				SYSTEM vExecuteSQL;
				
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c carga_movimientos.txt -l err_carga_mov.log -n 5000 -r";
				SYSTEM vExecuteSQL;			
				

				---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f '||RUTA_DESTINO||'bf_movimiento.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f '||RUTA_DESTINO||'bf_mov.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_movimientos.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;

		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE;