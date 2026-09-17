CREATE PROCEDURE "informix".sp_promueve_tarjetas_mensual()
    RETURNING CHAR(5) as CODIGO_RETORNO, VARCHAR(100) as MENSAJE_RESPUESTA;
     
    DEFINE SQL_ERR                 INTEGER;
    DEFINE ISAM_ERR                INTEGER;
    DEFINE ERROR_INFO              VARCHAR(100);
	DEFINE vFechaHoy               DATE;
	DEFINE vCodProductoTarjeta     CHAR (3);
	DEFINE vCodProductoSegmento    CHAR (3);
	DEFINE vMaxNumTrxMensual       INTEGER;
	DEFINE vMinNumTrxMensual       INTEGER;
	DEFINE vPeriodo                VARCHAR(6);
	DEFINE vProductoTarjeta        VARCHAR(3);
	DEFINE vNumTarjeta             VARCHAR(16);
	DEFINE nrows                   SMALLINT;
    DEFINE vFlujoEnTransaccion     CHAR(1);

    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(100);
    DEFINE RUTA_ORIGEN  VARCHAR(80);
    DEFINE RUTA_DESTINO VARCHAR(80);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(15);
    DEFINE ABREVIATURA_DEBITO CHAR(1);
    DEFINE PERMITE_SEGMENTACION_VERDADERO CHAR(1);
    DEFINE PROCESO_TRIMESTRAL CHAR(1);
    DEFINE PROCESO_MENSUAL CHAR(1);
    DEFINE MES_ENERO CHAR(2);
    DEFINE MES_ABRIL CHAR(2);
    DEFINE MES_JULIO CHAR(2);
    DEFINE MES_OCTUBRE CHAR(2);
    DEFINE FALSO CHAR(1);
    DEFINE VERDADERO CHAR(1);
    DEFINE CUENTA_EFECTIVA_NINIOS CHAR(4);
    DEFINE CUENTA_EFECTIVA_CHEQUES CHAR(4);
    DEFINE CUENTA_EFECTIVA_DIGITAL CHAR(4);
    DEFINE CUENTA_AHORRE_CAMBIO CHAR(4);
    DEFINE CUENTA_EFECTIVA_JOVENES CHAR(4);
    DEFINE ESTATUS_CUENTA_ACTIVA CHAR(1);
    DEFINE ESTATUS_CUENTA_BLOQUEADA CHAR(1);
    DEFINE ESTATUS_CUENTA_INACTIVA CHAR(1);
    DEFINE ESTATUS_CUENTA_INFORMADA CHAR(1);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;
    DEFINE PREFIJO_SCRIPTS CHAR(7);
    DEFINE vNumRegistrosAfectados  INTEGER;
    DEFINE vAnyoMes                CHAR(6);
    DEFINE vExecuteSQL LVARCHAR(4000);
    DEFINE vMesEjecucion           CHAR(2);
    DEFINE vAnio                   CHAR(4);
    DEFINE vFechaInicio DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaFinal DATETIME YEAR TO FRACTION(5);

    
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RESPUESTA = '';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET RUTA_DESTINO = '/resplogifx/';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET ABREVIATURA_DEBITO = 'D';
    LET PERMITE_SEGMENTACION_VERDADERO = 'V';
    LET PROCESO_TRIMESTRAL = 'T';
    LET PROCESO_MENSUAL = 'M';
    LET FALSO = 'F';
    LET VERDADERO ='V';
    LET CONTADOR_TRANSACCIONES = 10000; -- Softtek
    LET CUENTA_EFECTIVA_NINIOS = '1500';
    LET CUENTA_EFECTIVA_CHEQUES = '1900';
    LET CUENTA_EFECTIVA_DIGITAL = '2000';
    LET CUENTA_AHORRE_CAMBIO = '2300';
    LET CUENTA_EFECTIVA_JOVENES = '2500';
    LET ESTATUS_CUENTA_ACTIVA = '1';
    LET ESTATUS_CUENTA_BLOQUEADA = '3';
    LET ESTATUS_CUENTA_INACTIVA = '4';
    LET ESTATUS_CUENTA_INFORMADA = '5';
    LET PREFIJO_SCRIPTS = 'segmes_';
    LET vNumRegistrosAfectados = 0;
    LET vFlujoEnTransaccion = FALSO;
    LET vExecuteSQL = '';
    LET vMesEjecucion  = '';
    LET vAnio = ''; 
    LET vFechaInicio = '';
    LET vFechaFinal = '';
    LET vAnyoMes = '';

    
    BEGIN
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_promueve_tarjetas_mensual.err.out";
            TRACE ON;
            
            IF ((vNumRegistrosAfectados > 0) OR (vFlujoEnTransaccion = VERDADERO)) THEN
                COMMIT WORK;
                LET vFlujoEnTransaccion = FALSO;
            END IF;
            
            --Preparacion de una proxima ejecucion limpia.
            LET vExecuteSQL = '';
            LET vExecuteSQL = ' rm -f '||PREFIJO_SCRIPTS||'*';
            SYSTEM vExecuteSQL; -- JRGC1 SYSTEM instruccion para ejecutar
        
            LET vExecuteSQL = '';
            LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'*';
            SYSTEM vExecuteSQL;
        
            LET CODIGO_RETORNO    = SQL_ERR;
            LET MENSAJE_RESPUESTA  = error_info;

            RETURN 	CODIGO_RETORNO,MENSAJE_RESPUESTA;

        END EXCEPTION;
       
        --SET DEBUG FILE TO RUTA_ORIGEN || "sp_promueve_tarjetas_mensual.out";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ; --JRGC1 nivel de aislamiento lee datos que aun no se han confirmado
        SET LOCK MODE TO WAIT 3; ---JRGC1 tiempo de espera en que se libera un proceso 

         --- JRGC1 se obtienen las fechas de hoy, inicio y final 
        SELECT fecha_hoy, EXTEND(pri_dia_mes) - 1 units MONTH, EXTEND(pri_dia_mes)
            INTO vFechaHoy, vFechaInicio, vFechaFinal
        FROM bdinteg:si_fechas
            WHERE empresa = '001';
                
        LET vAnio = SUBSTR(vFechaHoy,7,10);
        LET vMesEjecucion = LPAD(MONTH(vFechaHoy), 2, '0');
        LET vAnyoMes = vAnio||vMesEjecucion;

        SELECT FIRST 1 periodo   ---- JRGC1 se obtienen el periodo por periodo(mes) y proceso 
            INTO vPeriodo 
        FROM intercard:sc_promtarjmensual 
            WHERE periodo = vAnyoMes 
                AND proceso = PROCESO_MENSUAL;
        
        LET nrows = dbinfo("sqlca.sqlerrd2"); --JRGC1 recupera informaciÃ³n de la BD
        IF(nrows = 1) THEN
            LET CODIGO_RETORNO = '00001';
            LET  MENSAJE_RESPUESTA  = 'Ya se ejecuto la opcion mensual del periodo '||vAnyoMes||' ';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;
        END IF;

        
        --Limpieza de la tabla para nueva carga de informacion.   JRGC1 limpia las tablas
        LET vExecuteSQL = '';
        LET vExecuteSQL  = 'echo TRUNCATE TABLE "informix".tbl_paso_prom_mensual >'||RUTA_ORIGEN||PREFIJO_SCRIPTS||'trun_paso_prom.sql ';            
        SYSTEM vExecuteSQL; 
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'trun_paso_prom.sql';
        SYSTEM vExecuteSQL;
        
        
        --CONSIDERAR QUE el dbload debe ejecutarse en: dbaccess bdicheq  JRGC1 se utiliza el unload para escribir en un archivo
        LET vExecuteSQL  = '';
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'regs_movs.unl ' ||
        ' SELECT mv.numtarjeta, tc.numcuenta, tar.numcliente, tar.codproductotarjeta, ' ||
        '       lte.clave_tipotarjeta, \"0\" AS saldopromeditrimestral, ' ||
        '       COUNT(*) AS numtrax, seg.codproductotarjeta as codproductotarjetanuevo, ' ||
        '       \"'||PROCESO_MENSUAL||'\" AS proceso, \"'||vAnyoMes||'\" AS periodo ' ||
        ' FROM intercard:movimiento mv, intercard:tarjetacuenta tc, intercard:tarjeta tar, ' ||
        '   intercard:hsmcard hsm, bdicheq:sc_tarjeta sct, bdicheq:sc_maechq mae, ' ||
        '   intercard:segmentoproducto seg, intercard:lote lte  ' ||
        ' WHERE mv.fechahorainauth BETWEEN \"'||vFechaInicio||'\"   AND \"'||vFechaFinal||'\" ' ||
        '    AND mv.numtarjeta = tc.numtarjeta ' ||
        '    AND tc.numtarjeta = tar.numtarjeta ' ||
        '     AND tar.numtarjeta = mv.numtarjeta  ' ||
        '     AND mv.numtarjeta = sct.num_tarjeta  ' ||
        '     AND hsm.card_no = tar.numtarjeta  ' ||
        '     AND sct.cuenta = tc.numcuenta  ' ||
        '     AND tc.numcuenta = mae.cuenta ' ||
        '     AND mae.cuenta = sct.cuenta  ' ||
        '     AND seg.codproductotarjeta = tar.codproductotarjeta ' ||
        ' AND tar.numerolote = lte.numerolote ' ||
        ' AND tar.codproductotarjeta IN (SELECT codproductotarjeta FROM intercard:segmentoproducto WHERE tipo_producto =\"D\" AND permite_segmentacion =\"V\") ' ||
        ' AND mv.prodind IN (\"02\") ' ||
        ' AND mv.esnacional IN (\"V\",\"F\") ' ||
        ' AND mv.formato IN (\"0200\",\"0220\") ' ||
        ' AND mv.metodocaptura IN (\"01\",\"05\",\"90\",\"81\") ' ||
        ' AND mv.movconciliado=\"V\"    ' ||
        ' AND mv.codigoiso IS NOT NULL  ' ||
        ' AND mv.codigoiso =\"00\" '   ||
        ' AND tar.codstatustarjeta IN (\"ACT\" ,\"BLO\" ) ' ||
        '     AND sct.status_tar =\"A\"  ' ||
        '     AND sct.tipo_tarjeta IN (\"T\" ,\"A\" ) ' ||
        '     AND mae.status_cta IN(\"'||ESTATUS_CUENTA_ACTIVA||'\",\"'||ESTATUS_CUENTA_BLOQUEADA||'\",\"'||ESTATUS_CUENTA_INACTIVA||'\" ,\"'||ESTATUS_CUENTA_INFORMADA||'\" )'||
        '     AND mae.producto  IN (SELECT producto FROM bdicheq:sc_producto ' ||
        '         WHERE producto IN (\"'||CUENTA_EFECTIVA_NINIOS||'\",\"'||CUENTA_EFECTIVA_CHEQUES||'\" ,\"'||CUENTA_EFECTIVA_DIGITAL||'\",\"'||CUENTA_AHORRE_CAMBIO||'\",\"'||CUENTA_EFECTIVA_JOVENES||'\")) ' ||
        '     AND seg.tipo_producto =\"D\" ' ||
        '     AND service_code IN (\"221\" ) ' ||
        ' AND tar.numtarjeta NOT IN(SELECT numtarjeta FROM intercard:sc_promtarjmensual) ' ||
        ' GROUP BY 1,2,3,4,5,6,8 ' ||
        ' HAVING count(*) >= ' ||
        '  (SELECT MIN (no_txn_min_mensual) FROM intercard:segmentoproducto '||
        '    WHERE permite_segmentacion =\"V\"  AND tipo_producto= \"D\"); ' ||
        ' "> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_reg_movs.sql';     ----JRGC1 se guarda en archivo 'script_reg_movs.sql'
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess bdicheq '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_reg_movs.sql'; -- JRGC1 se ejecuta el script creado
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||
                          'regs_movs.unl' || "' delimiter '|' "|| '10'||
                          "; INSERT INTO tbl_paso_prom_mensual" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_reg_movim.txt';
        SYSTEM vExecuteSQL; --JRGC1 inserta en tabla temporal informaciÃ³n del unload 
        
        --Se ejecuta el dbload en intercard porque ahi esta creada la tabla tbl_paso_prom_mensual
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_reg_movim.txt -l "||PREFIJO_SCRIPTS||"err_carga.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;  --- JRGC1 carga informaciÃ³n en tabla con el dbload 

        ----Obtencion de movimientos historicos  JRGC1 se obtienen mas datos con el unload
        LET vExecuteSQL  = '';
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'registros_movimiento_hist.unl ' ||
        ' SELECT mv.numtarjeta, tc.numcuenta, tar.numcliente, tar.codproductotarjeta, ' ||
        '       lte.clave_tipotarjeta, \"0\" AS saldopromeditrimestral, ' ||
        '       COUNT(*) AS numtrax, seg.codproductotarjeta AS codproductotarjetanuevo, ' ||
        '       \"'||PROCESO_MENSUAL||'\" as proceso, \"'||vAnyoMes||'\" as periodo ' ||
        ' FROM intercard:movimientohistorico mv, intercard:tarjetacuenta tc, intercard:tarjeta tar, ' ||
        '   intercard:hsmcard hsm, bdicheq:sc_tarjeta sct, bdicheq:sc_maechq mae, ' ||
        '   intercard:segmentoproducto seg, intercard:lote lte  ' ||
        ' WHERE mv.fechahorainauth BETWEEN \"'||vFechaInicio||'\"   AND \"'||vFechaFinal||'\" ' ||
        '    AND mv.numtarjeta = tc.numtarjeta ' ||
        '    AND tc.numtarjeta = tar.numtarjeta ' ||
        '     AND tar.numtarjeta = mv.numtarjeta  ' ||
        '     AND mv.numtarjeta = sct.num_tarjeta  ' ||
        '     AND hsm.card_no = tar.numtarjeta  ' ||
        '     AND sct.cuenta = tc.numcuenta  ' ||
        '     AND tc.numcuenta = mae.cuenta ' ||
        '     AND mae.cuenta = sct.cuenta  ' ||
        '     AND seg.codproductotarjeta = tar.codproductotarjeta ' ||
        ' AND tar.numerolote = lte.numerolote ' ||
        ' AND tar.codproductotarjeta IN (SELECT codproductotarjeta FROM intercard:segmentoproducto WHERE tipo_producto =\"D\" AND permite_segmentacion =\"V\") ' ||
        ' AND mv.prodind IN (\"02\") ' ||
        ' AND mv.esnacional IN (\"V\",\"F\") ' ||
        ' AND mv.formato IN (\"0200\",\"0220\") ' ||
        ' AND mv.metodocaptura IN (\"01\",\"05\",\"90\",\"81\") ' ||
        ' AND mv.movconciliado=\"V\"    ' ||
        ' AND mv.codigoiso IS NOT NULL   ' ||
        ' AND mv.codigoiso =\"00\" ' ||
        ' AND tar.codstatustarjeta IN (\"ACT\" ,\"BLO\" ) ' ||
        '     AND sct.status_tar =\"A\"  ' ||
        '     AND sct.tipo_tarjeta IN (\"T\" ,\"A\" ) ' ||
        '     AND mae.status_cta IN(\"'||ESTATUS_CUENTA_ACTIVA||'\",\"'||ESTATUS_CUENTA_BLOQUEADA||'\",\"'||ESTATUS_CUENTA_INACTIVA||'\" ,\"'||ESTATUS_CUENTA_INFORMADA||'\" )'||
        '     AND mae.producto  IN (SELECT producto FROM bdicheq:sc_producto ' ||
        '         WHERE producto IN (\"'||CUENTA_EFECTIVA_NINIOS||'\",\"'||CUENTA_EFECTIVA_CHEQUES||'\" ,\"'||CUENTA_EFECTIVA_DIGITAL||'\",\"'||CUENTA_AHORRE_CAMBIO||'\",\"'||CUENTA_EFECTIVA_JOVENES||'\")) ' ||
        '     AND seg.tipo_producto =\"D\" ' ||
        '     AND service_code IN (\"221\" ) ' ||
        ' AND tar.numtarjeta NOT IN(SELECT numtarjeta FROM intercard:sc_promtarjmensual) ' ||
        ' GROUP BY 1,2,3,4,5,6,8 ' ||
        ' HAVING count(*) >= ' ||
        '  (SELECT MIN (no_txn_min_mensual) FROM intercard:segmentoproducto '||
        '    WHERE permite_segmentacion =\"V\"  AND tipo_producto= \"D\"); ' ||
        ' "> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_reg_movs_hist.sql'; -- JRGC1 se crea script con movimientos historicos
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess bdicheq '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_reg_movs_hist.sql';
        SYSTEM vExecuteSQL;  --JRGC1 se ejecuta el script creado script_reg_movs_hist.sql

        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||
                'registros_movimiento_hist.unl' || "' delimiter '|' "|| '10'||
                        "; INSERT INTO tbl_paso_prom_mensual" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_regs_movhist.txt';
        SYSTEM vExecuteSQL; -- JRGC1 se cargan los datos en tabla temporal del archivo .unl y se crea archivo txt file_regs_movhist.txt
        
        --Se ejecuta el dbload en intercard porque ahi esta creada la tabla tbl_paso_prom_mensual
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_regs_movhist.txt -l "||PREFIJO_SCRIPTS||"err_carga_hist.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL; -- JRGC1 se  cargan datos a tambla temporal 

        LET vExecuteSQL  = ''; --JRGC1 se realiza la extraccion de tabla temporal y se guarda en archivo reg_agrup_tbl_mensual.unl
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'reg_agrup_tbl_mensual.unl ' ||
            ' SELECT numtarjeta, numcuenta, numcliente, codproductotarjeta, clave_tipotarjeta, ' ||
            '       saldopromeditrimestral, SUM (num_transacciones) as num_transacciones, ' ||
            '       prox_producto_nuevo, proceso, periodo ' ||
            ' FROM intercard:tbl_paso_prom_mensual ' ||
            ' GROUP BY 1,2,3,4,5,6,8,9,10; ' ||
        ' "> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_group_mensual.sql';
        SYSTEM vExecuteSQL;
             
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_group_mensual.sql';
        SYSTEM vExecuteSQL; --JRGC1 se ejecuta archivo script_group_mensual.sql

        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||
                'reg_agrup_tbl_mensual.unl' || "' delimiter '|' "|| '10'||
                        "; INSERT INTO sc_promtarjmensual" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'f_regis_promtjt_mes.txt';
        SYSTEM vExecuteSQL; -- JRGC1 se inserta en tabla temporal sc_promtarjmensual del archiv f_regis_promtjt_mes.txt
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"f_regis_promtjt_mes.txt -l "||PREFIJO_SCRIPTS||"err_carga_reg.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL; -- JRGC1 se ejecuta el archivo f_regis_promtjt_mes.txt 

        LET vFlujoEnTransaccion = FALSO;
        LET vCodProductoTarjeta ='';
        LET vMaxNumTrxMensual ='';
		
		-- Se comenta ya que la sentencia FOR es redunte con el FOREACH 2023
        --FOREACH cursor1 WITH HOLD FOR  -- JRGC1  se obtienen datos con un cursor 
		FOREACH WITH HOLD
            SELECT codproductotarjeta, no_txn_min_mensual
                INTO vCodProductoTarjeta, vMaxNumTrxMensual
            FROM   intercard:segmentoproducto
                WHERE  permite_segmentacion = 'V'
                    AND tipo_producto= 'D'
            ORDER BY codproductotarjeta
                 
            IF (vFlujoEnTransaccion = FALSO) THEN
                BEGIN WORK;
                LET vFlujoEnTransaccion = VERDADERO;
            END IF;

            --Proceso de depuracion de tabla de paso    JRGC1 se depura tabla de paso la pregunta es porque si es de paso no se hace un truncate
            --Se realiza aqui la eliminacion para borrar por producto 
            --y confirmar que por cada 1000 afectaciones sea ejecutado el commit dentro de un bloque.
            DELETE intercard:tbl_paso_prom_mensual
                WHERE codproductotarjeta = vCodProductoTarjeta;
     
            LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2") + vNumRegistrosAfectados;

            DELETE intercard:sc_promtarjmensual
                WHERE numtarjeta IN (
                    SELECT numtarjeta
                        FROM intercard:sc_promtarjmensual
                    WHERE codproductotarjeta = vCodProductoTarjeta
                        AND numtrax < vMaxNumTrxMensual
                    AND proceso = PROCESO_MENSUAL
                    );

            LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2") + vNumRegistrosAfectados;
            
            IF (vNumRegistrosAfectados >= CONTADOR_TRANSACCIONES) THEN
                COMMIT WORK;
                LET vFlujoEnTransaccion = FALSO;
                CONTINUE FOREACH;
            END IF;

        END FOREACH;

        IF ((vNumRegistrosAfectados > 0) OR (vFlujoEnTransaccion = VERDADERO)) THEN
            COMMIT WORK;
            LET vFlujoEnTransaccion = FALSO;
        END IF;
         

        LET vCodProductoTarjeta = '';
        LET vMaxNumTrxMensual = '';
        LET vNumRegistrosAfectados = 0;
		
		-- Se comenta ya que la sentencia FOR es redunte con el FOREACH 2023
        --FOREACH cursor2 WITH HOLD FOR
		FOREACH WITH HOLD
            SELECT codproductotarjeta, codproductosegmento, MAX(no_txn_min_mensual), MIN (no_txn_min_mensual)
                INTO vCodProductoTarjeta, vCodProductoSegmento, vMaxNumTrxMensual, vMinNumTrxMensual
            FROM  intercard:segmentoproducto
            WHERE permite_segmentacion = 'V'
                AND tipo_producto = 'D'
            GROUP BY 1, 2
            ORDER BY codproductotarjeta

            IF (vFlujoEnTransaccion = FALSO) THEN
                BEGIN WORK;
                LET vFlujoEnTransaccion = VERDADERO;
            END IF;

            UPDATE intercard:tarjeta 
                SET codproductotarjeta = vCodProductoSegmento
            WHERE 
                numtarjeta IN ( 
                    SELECT sc.numtarjeta 
                        FROM intercard:sc_promtarjmensual sc, intercard:tarjeta tar
                    WHERE sc.codproductotarjeta = vCodProductoTarjeta 
                        AND numtrax >= vMaxNumTrxMensual
                        AND sc.numtarjeta = tar.numtarjeta 
                        AND sc.periodo = vAnyoMes
                        AND tar.codstatustarjeta IN ('ACT','BLO')
                        AND proceso = PROCESO_MENSUAL
                        );

            LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2") + vNumRegistrosAfectados;

            IF (vNumRegistrosAfectados >= CONTADOR_TRANSACCIONES) THEN
                COMMIT WORK;
                LET vFlujoEnTransaccion = FALSO;
                CONTINUE FOREACH;
            END IF;

        END FOREACH;

        IF ((vNumRegistrosAfectados > 0) OR (vFlujoEnTransaccion = VERDADERO)) THEN
            COMMIT WORK;
            LET vFlujoEnTransaccion = FALSO;
        END IF;

        LET vFlujoEnTransaccion = FALSO;
        LET vNumRegistrosAfectados = 0;
        
        -----Actualizacion del campo nuevo producto-tarjeta
		-- Se comenta ya que la sentencia FOR es redunte con el FOREACH 2023
		-- FOREACH cursor3 WITH HOLD FOR
        FOREACH WITH HOLD

            SELECT tar.numtarjeta, tar.codproductotarjeta
                INTO vNumTarjeta,vProductoTarjeta
            FROM intercard:tarjeta tar,intercard:sc_promtarjmensual sc
                WHERE tar.numtarjeta = sc.numtarjeta
                    AND  sc.periodo = vAnyoMes
            
            IF (vFlujoEnTransaccion = FALSO) THEN
                BEGIN WORK;
                LET vFlujoEnTransaccion = VERDADERO;
            END IF;

            UPDATE intercard:sc_promtarjmensual
                SET codproductotarjetanuevo = vProductoTarjeta
            WHERE numtarjeta IN (
                SELECT sc.numtarjeta
                    FROM intercard:sc_promtarjmensual sc, intercard:tarjeta tar
                WHERE sc.numtarjeta = tar.numtarjeta
                    AND tar.numtarjeta = vNumTarjeta
                    AND sc.periodo= vAnyoMes
                    AND proceso = PROCESO_MENSUAL
                );

            LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2") + vNumRegistrosAfectados;

            IF (vNumRegistrosAfectados >= CONTADOR_TRANSACCIONES) THEN
                COMMIT WORK;
                LET vFlujoEnTransaccion = FALSO;
                CONTINUE FOREACH;
            END IF;

        END FOREACH;

        IF ((vNumRegistrosAfectados > 0) OR (vFlujoEnTransaccion = VERDADERO)) THEN
            COMMIT WORK;
            LET vFlujoEnTransaccion = FALSO;
        END IF;

        ---Creacion del archivo
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' echo "UNLOAD TO '||RUTA_ORIGEN||'cambioproducto'||vAnyoMes||'.txt'||
                    '  SELECT numtarjeta, numcuenta, numcliente, codproductotarjeta, '||
                    '         clave_tipotarjeta, numtrax, codproductotarjetanuevo, proceso, periodo ' ||
                    '   FROM intercard:sc_promtarjmensual WHERE periodo = '''||vAnyoMes||''' ' ||
                    '       AND  proceso = ''"'||PROCESO_MENSUAL||'"'' '||
                    '  ORDER BY numtarjeta;">'||RUTA_ORIGEN||PREFIJO_SCRIPTS||'crear_reporte.sql';
        SYSTEM vExecuteSQL;
        

        LET vExecuteSQL = '';
        LET vExecuteSQL= ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'crear_reporte.sql';
        SYSTEM vExecuteSQL;

        --Borrado de todos los archivos generados en el proceso        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;

        --- Se borran los registros para la siguiente ejecucion 
        BEGIN;
			-- SOFTEK Ajuste para reducir el tiempo de ejecuciÃ³n del procedimiento
            DELETE FROM intercard:tbl_paso_prom_mensual;
            -- TRUNCATE TABLE intercard:tbl_paso_prom_mensual;   
        COMMIT;
                    
        LET CODIGO_RETORNO = '00000';
        LET MENSAJE_RESPUESTA = 'PROCESO EXITOSO' ;

        RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;
    END
END PROCEDURE
/*
#1. Fecha de modificacion 15 de agosto del 2018
Proceso para actualizar un nuevo codigo de producto de tarjeta de acuerdo al numero de 
transacciones efectuadas en el mes anterior.
Se ejecuta mediante el job pro_206_8_8_seg_prod_men.sh

#2. Fecha de modificacion 16 de octubre del 2018
Se elimina el punto y coma de la lÃ­nea 152 para crear correctamente el archivo del truncate
Se ejecuta mediante el job pro_206_8_8_seg_prod_men.sh

#3. 
Fecha de modificacion: septiembre 2023
Modificado: Softtek / A.Canseco 09.2023
Motivo: Optimizacion
Detalle: Se actualizaron las palabras reservadas a un solo formato (mayuscula), se cambio
una condicion
*/
;

create procedure "informix".fechas_comp( pempresa char(3) )
returning char(5);
    
    define vsqlerr              integer;
    define visamerr             integer;
    define vdescerr             char(50);
    define vcodret              char(5);
    define vcodret2             char(5);
    define vcodret3             char(50);
    
    define vcodret_ctasdesc     char(5);
    define vcodret_ctasdesc2    char(5);
    define vcodret_ctasdesc3    char(5);
    define vcodret_ctasdesc4    integer;
    define vcodret_ctasdesc5    integer;
    define vcodret_ctasefecn    char(5);
    define vcodret_ctasefecj    char(5);
    define vcodret_invsincta    char(5);
    define vcodret_invsincta2   char(60);
    define vcodret_invconcta    char(5);
    define vcodret_invconcta2   char(60);
    define vcodret_pagconcta    char(5);
    define vcodret_pagconcta2   char(60);
    define vcodret_desbivr      char(5);
    define vfecha_hoy           date;
    define vpri_hab_mes         date;
    define vfecha_ant           date;
    
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = '';
    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vcodret_ctasdesc   = '';
    let vcodret_ctasdesc2  = '';
    let vcodret_ctasdesc3  = '';
    let vcodret_ctasdesc4  = 0;
    let vcodret_ctasdesc5  = 0;
    let vcodret_ctasefecn  = '';
    let vcodret_ctasefecj  = '';
    let vcodret_invsincta  = '';
    let vcodret_invsincta2 = '';
    let vcodret_invconcta  = '';
    let vcodret_invconcta2 = '';
    let vcodret_pagconcta  = '';
    let vcodret_pagconcta2 = '';
    let vcodret_desbivr    = '';
    let vfecha_hoy   = '';
    let vpri_hab_mes = '';
    let vfecha_ant   = '';
    
    --set debug file to "/resplogifx/conciliachq/fechas_comp_chq_exp.out";
    --trace on;
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/fechas_comp_chq.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 5;
    
    -- // OBTIENE FECHAS DEL SISTEMA DE CAPTACION
    select {+index(sc_fechas idx_fechas1)} 
           fecha_hoy, pri_hab_mes, fecha_ant
      into vfecha_hoy, vpri_hab_mes, vfecha_ant
      from sc_fechas 
     where empresa = pempresa;
     
    -- // TABLA PARA LA CONCILIACION DE SALDOS E INTERESES DE CAPTACION
    if exists( select dbsname, tabname from sysmaster:systabnames where partnum > 0 and tabname = 'conciliachq') then
        drop table bdicheq:"informix".conciliachq;        
    end if;
    
    create table bdicheq:"informix".conciliachq
      (
        fecha                   date,           
        cuenta                  char(20),
        producto                char(4),        
        num_cte                 char(20),
        genero                  char(1),
        sucursal                char(4),        
        ejecutivo               char(8),
        capital_anterior        money(18,2),    
        movs_cargo              money(18,2),
        movs_abono              money(18,2),    
        capital_calculado       money(18,2),
        capital_actual          money(18,2),
        diferencia_capital      money(18,2),
        interes_anterior        money(18,2),    
        movs_cargo_interes      money(18,2),
        movs_abono_interes      money(18,2),    
        interes_calculado       money(18,2),
      interes_actual          money(18,2),    
      diferencia_interes      money(18,2)
      ) 
    fragment by round robin in dbssc_sdodiarioc01, dbssc_sdodiarioc02, dbssc_sdodiarioc03
    extent size 512000 next size 51200 lock mode row;
    
    create index "informix".idx_conciliachq_cta on bdicheq:"informix".conciliachq(cuenta) in db_lide online;
    create index "informix".idx_conciliachq_prod on bdicheq:"informix".conciliachq(producto) in db_lide online;
	create index "informix".idx_conciliachq_cte on bdicheq:"informix".conciliachq(num_cte) in db_lide online;
    create index "informix".idx_conciliachq_sdo on bdicheq:"informix".conciliachq(capital_actual) in db_lide online;
    update statistics medium for table conciliachq;
    
    -- // TABLA DE DIFERENCIAS PARA LA CONCILIACION DE SALDOS E INTERESES DE CAPTACION
    if exists( select dbsname, tabname from sysmaster:systabnames where partnum > 0 and tabname = 'conciliachq_dif') then
        drop table bdicheq:"informix".conciliachq_dif;
    end if
    
    create table bdicheq:"informix".conciliachq_dif
      (
        fecha                   date,           
        cuenta                  char(20),
        producto                char(4),        
        num_cte                 char(20),
        genero                  char(1),
        sucursal                char(4),        
        ejecutivo               char(8),
        capital_anterior        money(18,2),    
        movs_cargo              money(18,2),
        movs_abono              money(18,2),    
        capital_calculado       money(18,2),
        capital_actual          money(18,2),
        diferencia_capital      money(18,2),
        interes_anterior        money(18,2),    
        movs_cargo_interes      money(18,2),
        movs_abono_interes      money(18,2),    
        interes_calculado       money(18,2),
        interes_actual          money(18,2),    
        diferencia_interes      money(18,2)
      ) 
    extent size 8000 next size 800 lock mode row;
    
    create index "informix".idx_conciliachq_dif on bdicheq:"informix".conciliachq_dif(cuenta) in dbs_idxinteg online;
    update statistics medium for table conciliachq_dif;
    
    --// INICIALIZA TABLA DE ACUMULADOS PARA CUENTAS NIVEL 2
	
    if vfecha_hoy = vpri_hab_mes then
        truncate table sc_acummesctanvl2;
    end if;
    
    -- // PROCESO PARA VERIFICAR NUMERO DE DIAS DE CUENTAS DESCONCENTRADAS
    --- call sp_verifctasdesconcentradas(pempresa) 
    --- returning vcodret_ctasdesc, vcodret_ctasdesc2, vcodret_ctasdesc3, vcodret_ctasdesc4, vcodret_ctasdesc5;
       
    -- // PROCESO PARA BLOQUEAR O CANCELAR CUENTAS EFECTIVAS NIÑOS CON MAYORIA DE EDAD
    call sp_valmayoedadctaefecnos() 
    returning vcodret_ctasefecn;
    
    -- // PROCESO PARA BLOQUEAR O CANCELAR CUENTAS EFECTIVAS JOVENES CON MAYORIA DE EDAD
    call sp_valmayoedadctaefecjovenes() 
    returning vcodret_ctasefecj;
    
    -- // PROCESO PARA REPORTE DE INVERSIONES CRECIENTES SIN CUENTA EJE CON MAS DE 3 AÑOS
    call sp_rptainvcrecsincta3anios() 
    returning vcodret_invsincta, vcodret_invsincta2;
    
    -- // PROCESO PARA REPORTE DE INVERSIONES CRECIENTES CON MAS DE 3 AÑOS
    call sp_rptainvcrecconcta3anios() 
    returning vcodret_invconcta, vcodret_invconcta2;
    
    -- // PROCESO PARA REPORTE DE INVERSIONES CRECIENTES CON MAS DE 3 AÑOS
    call sp_rptapagares3anios() 
    returning vcodret_pagconcta, vcodret_pagconcta2;
    
    -- // PROCESO PARA DESBLOQUEO DE CLIENTES IVR
    execute procedure bdivr:"informix".ivr_desbloq_ctes()
    into vcodret_desbivr;
    
    set lock mode to not wait;
    
    return vcodret;
    
    end;
    
end procedure;