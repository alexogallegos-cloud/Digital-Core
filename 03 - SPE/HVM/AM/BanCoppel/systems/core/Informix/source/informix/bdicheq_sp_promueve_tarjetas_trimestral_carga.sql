CREATE PROCEDURE "informix".sp_promueve_tarjetas_trimestral_carga()
    
    RETURNING CHAR(5) AS CODIGO_RETORNO, VARCHAR(80) AS MENSAJE_RETORNO;

    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(80);
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
    DEFINE ABREVIATURA_TITULAR CHAR(1);
    DEFINE ABREVIATURA_ADICIONAL CHAR(1);
    DEFINE PREFIJO_SCRIPTS CHAR(8);
    
    DEFINE CUENTA_EFECTIVA_NINIOS CHAR(4);
    DEFINE CUENTA_EFECTIVA_CHEQUES CHAR(4);
    DEFINE CUENTA_EFECTIVA_DIGITAL CHAR(4);
    DEFINE CUENTA_AHORRE_CAMBIO CHAR(4);
    DEFINE CUENTA_EFECTIVA_JOVENES CHAR(4);
    
    DEFINE ESTATUS_CUENTA_ACTIVA CHAR(1);
    DEFINE ESTATUS_CUENTA_BLOQUEADA CHAR(1);
    DEFINE ESTATUS_CUENTA_INACTIVA CHAR(1);
    DEFINE ESTATUS_CUENTA_INFORMADA CHAR(1);

    DEFINE vMaxLimiteMaximo DECIMAL(19,4);    
    DEFINE vExecuteSQL LVARCHAR(8000);
    DEFINE vTotalRegistros INTEGER;
    
    DEFINE  SQL_ERR                 INTEGER;
    DEFINE  ISAM_ERR                INTEGER;
    DEFINE  ERROR_INFO              VARCHAR(100);

	DEFINE vFechaHoy               DATE;
	DEFINE vAnio                   CHAR(4);
	DEFINE vCodProductoTarjeta	    VARCHAR (3);
	DEFINE vCodProductoSegmento    VARCHAR (3);
	DEFINE vAnioMes                VARCHAR(6);
	DEFINE vPeriodo                VARCHAR(6);
	DEFINE vNumRegistrosAfectados  INTEGER;

	DEFINE vMesEjecucion           CHAR(2);
    DEFINE vFlujoEnTransaccion  CHAR(1);	
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;    
    DEFINE vCampoSaldoTrim VARCHAR(20);
    
	LET vMesEjecucion  = '';
    LET CONTADOR_TRANSACCIONES = 1000;
	LET vFlujoEnTransaccion  = '';	

    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET PREFIJO_SCRIPTS = 'segtrim_';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET RUTA_DESTINO = '/resplogifx/';
    LET ABREVIATURA_DEBITO = 'D';
    LET PERMITE_SEGMENTACION_VERDADERO = 'V';
    LET PROCESO_TRIMESTRAL = 'T';
    LET PROCESO_MENSUAL = 'M';
    LET MES_ENERO = '01';
    LET MES_ABRIL = '04';
    LET MES_JULIO = '07';
    LET MES_OCTUBRE = '10';
    LET FALSO = 'F';
    LET VERDADERO ='V';
    LET ABREVIATURA_TITULAR ='T';
    LET ABREVIATURA_ADICIONAL ='A';
    
    LET CUENTA_EFECTIVA_NINIOS = '1500';
    LET CUENTA_EFECTIVA_CHEQUES = '1900';
    LET CUENTA_EFECTIVA_DIGITAL = '2000';
    LET CUENTA_AHORRE_CAMBIO = '2300';
    LET CUENTA_EFECTIVA_JOVENES = '2500';
    LET ESTATUS_CUENTA_ACTIVA = '1';
    LET ESTATUS_CUENTA_BLOQUEADA = '3';
    LET ESTATUS_CUENTA_INACTIVA = '4';
    LET ESTATUS_CUENTA_INFORMADA = '5';    
    LET vMaxLimiteMaximo = '00.0000';
    LET vCodProductoTarjeta = '';
    LET vTotalRegistros = 0;
    LET vNumRegistrosAfectados = 0;
    LET vExecuteSQL = '';
    LET vCampoSaldoTrim = '';
    
    BEGIN
        
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        
            SET DEBUG FILE TO RUTA_ORIGEN || "sp_promueve_tarjetas_trimestral_carga_exception.out";           
            TRACE ON;
            
            IF ((vNumRegistrosAfectados > 0) OR (vFlujoEnTransaccion =  VERDADERO)) THEN                
                LET vFlujoEnTransaccion = FALSO;
                LET vNumRegistrosAfectados = 0;
                
                COMMIT WORK;
            END IF;            
            
            LET CODIGO_RETORNO   = SQL_ERR;
            LET MENSAJE_RETORNO  = error_info   ||   ISAM_ERR;
         
            RETURN CODIGO_RETORNO , MENSAJE_RETORNO;
        END EXCEPTION;
       
        --SET DEBUG FILE TO RUTA_ORIGEN || "sp_promueve_tarjetas_trimestral_carga.out";
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
        
        --Preparacion de una proxima ejecucion limpia.
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
    
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
                
        SELECT fecha_hoy 
            INTO vFechaHoy 
        FROM bdinteg:si_fechas
        --FROM intercard:si_fechas_temp
            WHERE empresa = '001';

        LET vAnio = SUBSTR(vFechaHoy,7,10);
        LET vMesEjecucion = LPAD(MONTH(vFechaHoy), 2, '0');
        LET vAnioMes = vAnio||vMesEjecucion;

        --Reporte trimestral considerado su ejecucion en los siguientes meses.
        
        IF ( (vMesEjecucion  <> MES_ENERO) AND (vMesEjecucion  <> MES_ABRIL) AND (vMesEjecucion  <> MES_JULIO) AND (vMesEjecucion  <> MES_OCTUBRE) ) THEN
            LET CODIGO_RETORNO = '00001';
            LET MENSAJE_RETORNO = 'En el mes '||vMesEjecucion||' no puede ser ejecutado este reporte' ;
            RETURN CODIGO_RETORNO , MENSAJE_RETORNO;
        END IF;
        
        --Con el cambio de anyo debe considerarse el anyo anterior para los saldos trimestrales.
        --Para el uso de anyomes del periodo se consideran los datos obtenidos de la fecha integral.
        IF ( vMesEjecucion = MES_ENERO ) THEN
            LET vAnio = YEAR(today) - 1;
        END IF;
        
        SELECT             
            FIRST 1 periodo
                INTO vPeriodo 
        FROM intercard:sc_promtarjmensual 
        WHERE proceso = PROCESO_TRIMESTRAL
            AND periodo = vAnioMes;

        --dbinfo("sqlca.sqlerrd2") Returns a single integer that provides the number of rows SELECT, INSERT, DELETE, UPDATE...
        LET vNumRegistrosAfectados = dbinfo("sqlca.sqlerrd2");
        
        IF(vNumRegistrosAfectados = 1) THEN
            LET CODIGO_RETORNO = '00002';
            LET MENSAJE_RETORNO  = 'La opcion trimestral del periodo '||vAnioMes||' ya fue ejecutada.';
            RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
        END IF;
        
        DROP TABLE IF EXISTS "informix".tmp_segmentoproducto;
        
        SELECT            
            codproductotarjeta, codproductosegmento, clasifica_producto, 
                MAX(limite_max) AS limite_maximo, MIN (limite_max) AS minimo_limite_max
        FROM intercard:segmentoproducto
        WHERE tipo_producto =  ABREVIATURA_DEBITO
            AND permite_segmentacion = PERMITE_SEGMENTACION_VERDADERO
        GROUP BY codproductotarjeta, codproductosegmento, clasifica_producto
        ORDER BY limite_maximo, codproductotarjeta
            INTO TEMP tmp_segmentoproducto WITH NO LOG;
        
        LET vFlujoEnTransaccion = FALSO;
        
        IF (vFlujoEnTransaccion = FALSO) THEN
            BEGIN WORK;
            LET vFlujoEnTransaccion = VERDADERO;
        END IF;
        
        IF (vMesEjecucion = MES_ENERO) THEN        
            LET vCampoSaldoTrim = 'sdo.cappromtrim4';
        ELIF (vMesEjecucion = MES_ABRIL) THEN        
            LET vCampoSaldoTrim = 'sdo.cappromtrim1';
        ELIF (vMesEjecucion = MES_JULIO) THEN        
            LET vCampoSaldoTrim = 'sdo.cappromtrim2';
        ELIF (vMesEjecucion = MES_OCTUBRE) THEN        
            LET vCampoSaldoTrim = 'sdo.cappromtrim3';
        END IF;
        
        
        --Limpieza de la tabla para nueva carga de informacion.
        --El truncate table no lleva punto y coma al final para que la cadena se almacene en el archivo.
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo TRUNCATE TABLE "informix".tbl_paso_prom_mensual >'||RUTA_ORIGEN||PREFIJO_SCRIPTS||'trun_paso_prom.sql';        
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'trun_paso_prom.sql';
        SYSTEM vExecuteSQL;
                
        LET vExecuteSQL  = '';
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'regs_tarj_trimes.unl ' ||
        ' SELECT DISTINCT tar.numtarjeta, tc.numcuenta, tar.numcliente, tar.codproductotarjeta, ' ||
        "   lte.clave_tipotarjeta, '0' AS saldopromeditrimestral, '0' AS numtrax, seg.codproductotarjeta AS codproductotarjetanuevo, " ||
        '       \"'||PROCESO_TRIMESTRAL||'\" AS proceso, \"'||vAnioMes||'\" AS periodo ' ||
        ' FROM  intercard:tarjeta tar, intercard:tarjetacuenta tc, bdicheq:sc_sdotrimestralc AS sc, intercard:segmentoproducto seg, ' ||
        '   intercard:hsmcard hsm,bdicheq:sc_tarjeta sct,bdicheq:sc_maechq mae,intercard:lote lte, ' ||
		"  (SELECT cuenta FROM bdicheq:sc_sdotrimestralc AS sdo " ||    --Stk 202310
        "                    WHERE   "||vCampoSaldoTrim||" >= (SELECT min(limite_max) FROM intercard:segmentoproducto  WHERE permite_segmentacion = 'V' AND tipo_producto = 'D') " || --Stk 202310
        "              AND  sdo.anio = '"||vAnio||"' ) sc2" || --Stk 202310
        '   WHERE tar.numtarjeta = tc.numtarjeta ' ||
        '   AND   tc.numcuenta  = sc.cuenta ' ||
        '   AND   seg.codproductotarjeta = tar.codproductotarjeta ' ||
        '   AND   hsm.card_no= tar.numtarjeta ' ||
        '   AND   hsm.card_no= sct.num_tarjeta ' ||
        '   AND   sc.cuenta = mae.cuenta ' ||
        '   AND   tar.numerolote=lte.numerolote ' ||    
        "   AND   tar.codstatustarjeta IN ('ACT','BLO') " ||
        "   AND   hsm.service_code IN ('221') " ||
        "   AND   sct.status_tar = 'A' " ||
        "   AND   sct.tipo_tarjeta IN ('"||ABREVIATURA_TITULAR||"','"||ABREVIATURA_ADICIONAL||"')"||
        '     AND mae.status_cta IN(\"'||ESTATUS_CUENTA_ACTIVA||'\",\"'||ESTATUS_CUENTA_BLOQUEADA||'\",\"'||ESTATUS_CUENTA_INACTIVA||'\" ,\"'||ESTATUS_CUENTA_INFORMADA||'\" )'||        
        '   AND   mae.producto  IN (\"'||CUENTA_EFECTIVA_NINIOS||'\",\"'||CUENTA_EFECTIVA_CHEQUES||'\",\"'||CUENTA_EFECTIVA_DIGITAL||'\",\"'||CUENTA_AHORRE_CAMBIO||'\",\"'||CUENTA_EFECTIVA_JOVENES||'\") ' ||        
        "   AND   tar.codproductotarjeta IN (SELECT codproductotarjeta FROM intercard:segmentoproducto WHERE tipo_producto ='D' AND permite_segmentacion ='V') " ||        
        --"   AND   sc.cuenta IN (  " ||  --Stk 202310
        --"              SELECT cuenta FROM bdicheq:sc_sdotrimestralc AS sdo " ||   --Stk 202310 
        --"                    WHERE   "||vCampoSaldoTrim||" >= (SELECT min(limite_max) FROM intercard:segmentoproducto  WHERE permite_segmentacion = 'V' AND tipo_producto = 'D') " || --Stk 202310
        --"              AND  sdo.anio = '"||vAnio||"' ) " || --Stk 202310
		"   AND   sc.cuenta = sc2.cuenta  " || --Stk 202310
        " AND   tar.numtarjeta NOT IN(SELECT numtarjeta FROM intercard:sc_promtarjmensual WHERE proceso IN ('"||PROCESO_TRIMESTRAL||"','"||PROCESO_MENSUAL||"') )"||
        ' "> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_tarj_trimes.sql';
        SYSTEM vExecuteSQL;
 
 
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_tarj_trimes.sql';
        SYSTEM vExecuteSQL;
      
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||
                          'regs_tarj_trimes.unl' || "' delimiter '|' "|| '10'||
                          "; INSERT INTO tbl_paso_prom_mensual" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_tarj_trimes.txt';
        SYSTEM vExecuteSQL;
        
        --Se ejecuta el dbload en intercard porque ahi esta creada la tabla tbl_paso_prom_mensual
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_tarj_trimes.txt -l "||PREFIJO_SCRIPTS||"err_tarj_trimes.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;        
        
        DROP TABLE IF EXISTS "informix".tmp_segmentoproducto;
        
        ---Validar si existe informacion para continuar todo el proceso.        
        SELECT COUNT(*) 
            INTO vTotalRegistros 
        FROM intercard:tbl_paso_prom_mensual 
            WHERE periodo = vAnioMes AND proceso = PROCESO_TRIMESTRAL;
        
        IF(vTotalRegistros = 0 AND vFlujoEnTransaccion = VERDADERO) THEN            
            
            LET vFlujoEnTransaccion = FALSO;        
            LET CODIGO_RETORNO = '00003';
            LET MENSAJE_RETORNO  = 'Sin coincidencias de informacion para el procesamiento';

            --Preparacion de una proxima ejecucion limpia.
            LET vExecuteSQL = '';
            LET vExecuteSQL = ' rm -f '||PREFIJO_SCRIPTS||'*';
            SYSTEM vExecuteSQL;
        
            LET vExecuteSQL = '';
            LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'*';
            SYSTEM vExecuteSQL;
        

                COMMIT WORK;
            
            RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
        END IF;
        
        ---#argoz1 Insercion a la tabla fisica de cambio de producto y validacion de saldo trimestral correspondiente.
            
        LET vExecuteSQL  = '';
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'select_tarj_cta_trim.unl ' ||
            ' SELECT DISTINCT tri.numtarjeta,sdo.cuenta, tri.numcliente, tri.codproductotarjeta,' ||
            "  tri.clave_tipotarjeta, "||vCampoSaldoTrim||", tri.num_transacciones," ||
            '  tri.prox_producto_nuevo, tri.proceso, tri.periodo' ||
            ' FROM intercard:tbl_paso_prom_mensual AS tri, bdicheq:sc_sdotrimestralc as sdo, bdicheq:sc_tarjeta tar' ||        
            '  WHERE tri.numcuenta = sdo.cuenta' ||
            '   AND tri.numcuenta = tar.cuenta' ||        
            '   AND tri.numtarjeta = tar.num_tarjeta' ||        
            '    AND tri.numcliente = tar.numcte' ||
            "    AND  sdo.anio = '"||vAnio||"' " ||
            "   AND tri.numtarjeta NOT IN (SELECT numtarjeta FROM intercard:sc_promtarjmensual WHERE proceso = '"||PROCESO_TRIMESTRAL||"') " ||
            "    AND "||vCampoSaldoTrim||" >= (SELECT min(limite_max) FROM intercard:segmentoproducto  WHERE permite_segmentacion ='V' AND tipo_producto= 'D'); " ||
            ' "> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_tarj_cta_trim.sql';
        SYSTEM vExecuteSQL;    
     
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess bdicheq '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_tarj_cta_trim.sql';
        SYSTEM vExecuteSQL;
    
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||
                          'select_tarj_cta_trim.unl' || "' delimiter '|' "|| '10'||
                          "; INSERT INTO sc_promtarjmensual" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_promtarj_trimes.txt';
        SYSTEM vExecuteSQL;
        
        --Se ejecuta el dbload en intercard porque ahi esta creada la tabla tbl_paso_prom_mensual
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_promtarj_trimes.txt -l "||PREFIJO_SCRIPTS||"err_promtarj_trimes.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;
        
        IF (vFlujoEnTransaccion = VERDADERO) THEN
            COMMIT WORK;
            LET vFlujoEnTransaccion = FALSO;
        END IF;
        
        RETURN 	CODIGO_RETORNO,MENSAJE_RETORNO;  
END 
END PROCEDURE
/*
-- Autor: Armando Garcia [ agarciao@bancoppel.com ]
-- Creado: 16.octubre.2018 13:07pm
-- Base de datos: bdicheq
-- Job: 206_30_19_SEG_PROD_TRIM_CARGA_PRO | No tiene asociado un AFT
-- Descripcion: Proceso de consulta, registro y actualizacion del codigo de producto de tarjeta
-- de acuerdo al saldo trimestral correspondiente anterior al mes de ejecucion    
*/
/*
-- Autor: Softtek 
-- Modificado: 24.octubre.2023 
-- Base de datos: bdicheq
-- Job: 206_30_19_SEG_PROD_TRIM_CARGA_PRO | No tiene asociado un AFT
-- Descripcion: Optimizacion  
*/
;

CREATE PROCEDURE "informix".sp_concilia_pago_credito_coppel_atm()
RETURNING CHAR(5);

    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vFechaHoy            DATE;
        DEFINE vFechaAnt                DATE;
    DEFINE vmonto               MONEY(14,2);
    --DEFINE vmonto_com         MONEY(14,2);
    --DEFINE vmonto_iva         MONEY(14,2);
    --DEFINE vcuantos           INTEGER;
    DEFINE vchar4               CHAR(4);
    DEFINE vdate                DATE;
    DEFINE vmoney               MONEY(14,2);
    DEFINE vcodret              char(5);
    DEFINE vIvaBase             DECIMAL(5,3);
    DEFINE vReferencia          CHAR(40);
    DEFINE vmonto_total         MONEY(14,2);
        DEFINE vfechaproc                       DATE;
        DEFINE vproceso                         CHAR(20);

    LET Sql_Err                         = 0;
    LET Isam_Err                        = 0;
    LET Desc_Err                        = '';
    LET vCodRet1                        = '000';
    LET vCodRet2                        = '';
    LET vCodRet3                        = '';
    LET vFechaHoy                       = '';
        LET vFechaAnt                   = '';
    LET vmonto                          = 0;
    --LET vmonto_com                    = 0;
    --LET vmonto_iva                    = 0;
    LET vReferencia                     = 'PAGO CREDITOS COPPEL ATM';
    LET vmonto_total                    = 0;
        LET vproceso                            = "conpagocrecoppelatm";

    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_concilia_pago_credito_coppel_atm.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_concilia_pago_credito_coppel_atm.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    -- // OBTINENE FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant
      INTO vFechaHoy, vFechaAnt
      FROM sc_fechas
     WHERE empresa = '001';


        -- // VERIFICA CONTROL DE PROCESOS EN CHEQUES
    select fecha
      into vfechaproc
      from sc_contproc
     where empresa = '001'
       and proceso = vproceso;

    if vfechaproc = vFechaHoy then
           let vcodret1 = '000';
       return vcodret1;
    end if;

        LET vFechaAnt = vfechaproc;


    SELECT valor
          INTO vIvaBase
      FROM bdinteg:si_param
     WHERE empresa = '001'
       AND cod_param = 47;

    IF vIvaBase IS NULL THEN
       LET vIvaBase = 0;
    END IF

        SELECT nvl(sum(monto_tot), 0)--, count(*)
          INTO vmonto--, vcuantos
          FROM sc_movdia
         WHERE cuenta = '99000000520'
          AND fech_alt = vFechaHoy
           AND transacc in('0533', '0534')
           AND cancelad <> 'S';

        LET vmonto_total = vmonto;
		
        /*
        LET vmonto_com = vcuantos * 2.49;
        LET vmonto_iva = vmonto_com * vIvaBase;
        LET vmonto_total = vmonto - vmonto_com - vmonto_iva;*/

        /*
        IF vmonto_total > 0 THEN
        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0535', '0000', '92536921231000', '99000000520', 0, vmonto_total, '01', vReferencia, ' ', ' ')
        INTO vcodret, vchar4, vdate, vmoney, vmoney;

        IF vcodret = '000' THEN
            EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0536', '0000', '92536921231000', '12000000017', 0, vmonto_total, vmonto_total, 0, 0, 0, '01', vReferencia, ' ', ' ')
            INTO vcodret;

            IF vcodret = '000' AND vmonto_com > 0 THEN
                                EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0537', '0000', '92536921231000', '99000000520', 0, vmonto_com, '01', vReferencia, ' ', ' ')
                                INTO vcodret, vchar4, vdate, vmoney, vmoney;

                                IF vcodret = '000' AND vmonto_iva > 0 THEN
                                        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0538', '0000', '92536921231000', '99000000520', 0, vmonto_iva, '01', vReferencia, ' ', ' ')
                                        INTO vcodret, vchar4, vdate, vmoney, vmoney;

                                -- // REGISTRA FINALIZACION DEL PROCESO
                                        update sc_contproc
                                        set fecha = vFechaHoy
                                        where empresa = '001'
                                        and proceso = vproceso;

                                END IF;
            END IF;
                END IF;
    END IF;
        */
-- SE MODIFICA ENVIO DE MONTO DE OPERACIONES PAGO DE CREDITO COPPEL EN ATMÂ´S SIN DESCUENTO DE COMISION

        IF vmonto_total > 0 THEN
        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0535', '0000', '92536921231000', '99000000520', 0, vmonto_total, '01', vReferencia, ' ', ' ')
        INTO vcodret, vchar4, vdate, vmoney, vmoney;

        IF vcodret = '000' THEN
            EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0536', '0000', '92536921231000', '12000000017', 0, vmonto_total, vmonto_total, 0, 0, 0, '01', vReferencia, ' ', ' ')
            INTO vcodret;

                                -- // REGISTRA FINALIZACION DEL PROCESO
                                        update sc_contproc
                                        set fecha = vFechaHoy
                                        where empresa = '001'
                                        and proceso = vproceso;

                END IF;
    END IF;

--
-- ****************************************************************************
-- *                 FIN DE PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    END;
    RETURN vCodRet1;

END PROCEDURE;