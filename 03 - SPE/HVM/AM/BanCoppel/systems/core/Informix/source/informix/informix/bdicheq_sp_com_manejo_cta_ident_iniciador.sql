CREATE PROCEDURE "informix".sp_com_manejo_cta_ident_iniciador()
    RETURNING CHAR(5), VARCHAR(80);
-- *****************************************************************************
-- Version          1.0.0
-- Objetivo:        Guardar en la tabla sc_param, el cliente con el que finaliza
--                   su parte cada hilo del proceso de "Identificacion de Cuentas
--                   para el Cobro de Comision por Manejo de Cuenta"
-- Creado por:      Joel Martinez
-- Fecha:           Septiembre - 2024
-- *****************************************************************************

    DEFINE vCodRet              CHAR(5);
    DEFINE vErrorInfo           VARCHAR(80);
    DEFINE vIsamErr             SMALLINT;
    DEFINE vSQLErr              INTEGER;
    DEFINE vEmpresa             CHAR(3);
    DEFINE vFechaInicial        DATE;
    DEFINE vFechaFinal          DATE;
    DEFINE vAnioMes             CHAR(6);
    DEFINE vIndice              SMALLINT;
    DEFINE vConfStatus          VARCHAR(60);
    DEFINE vConfProductos       VARCHAR(60);
    DEFINE vCantConfStatus      SMALLINT;
    DEFINE vCantConfProductos   SMALLINT;
    DEFINE vCharAux             CHAR(1);
    DEFINE vStringAux           VARCHAR(4);
    DEFINE vExisteTMP           SMALLINT;
    DEFINE vExisteTMP2          SMALLINT;
    DEFINE vCtasTotal           INTEGER;
    DEFINE vCantHilos           SMALLINT;
    DEFINE vCtasPorHilo         INTEGER;
    DEFINE vNumHilo             SMALLINT;
    DEFINE vUltimoCteHilo       CHAR(20);
    DEFINE vFechaHoraIni        DATETIME YEAR TO FRACTION(3);
    DEFINE vArchivoSQL          CHAR(50);
    DEFINE vSQL                 CHAR(300);
   
    LET vCodRet             = '00000';
    LET vErrorInfo          = '';
    LET vIsamErr            = 0;
    LET vSQLErr             = 0; 
    LET vEmpresa            = '001';
    LET vFechaInicial       = '';
    LET vFechaFinal         = '';
    LET vAnioMes            = '';
    LET vIndice             = 0;
    LET vConfStatus         = '';
    LET vConfProductos      = '';
    LET vCantConfStatus     = 0;
    LET vCantConfProductos  = 0;
    LET vCharAux            = '';
    LET vStringAux          = '';
    LET vExisteTMP          = 0;
    LET vExisteTMP2         = 0;
    LET vCtasTotal          = 0;
    LET vCantHilos          = 5;
    LET vCtasPorHilo        = 0;
    LET vNumHilo            = 1;
    LET vUltimoCteHilo      = '';
    LET vFechaHoraIni       = '';
    LET vArchivoSQL         = "/resplogifx/conciliachq/updatebitacora.sql";
    LET vSQL                = '';

    BEGIN
    ON EXCEPTION SET vSQLErr, vIsamErr, vErrorInfo
        IF  vSQLErr != 0 THEN
            SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_iniciador.err';
            TRACE ON;
            LET vCodRet     = vSQLErr;
            LET vIsamErr    = vIsamErr;
            LET vErrorInfo   = vErrorInfo;
        
            IF vExisteTMP = 1 THEN
                DROP TABLE tmp_conf_status;
                DROP TABLE tmp_conf_productos;
            END IF;
            
            IF vExisteTMP2 = 1 THEN
                DROP TABLE tmp_ctas_total;
            END IF;
        
            RETURN vCodRet, vErrorInfo;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_iniciador.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
    
    /**************************************************************************/
    /*                         CONSULTA DE PARAMETROS                         */
    /**************************************************************************/
    -- La fecha inicial a procesar es el primer dia del mes anterior
    -- Solo se consideraran cuentas creadas antes de la fecha inicial
    SELECT DATE( pri_dia_mes - 1 UNITS MONTH ), DATE( pri_dia_mes - 1 UNITS DAY )
    INTO vFechaInicial, vFechaFinal
    FROM sc_fechas
    WHERE empresa = vEmpresa;

    -- Extrae aÃ±o y mes que se procesara
    LET vAnioMes = TO_CHAR(vFechaInicial,'%Y%m');
    
    -- Se obtienen los status de las cuentas a considerar
    SELECT valor
    INTO vConfStatus
    FROM sc_param
    WHERE codparam = 'IdenComMCStatus';
    
    -- Se obtienen los productos de las cuentas a considerar
    SELECT valor
    INTO vConfProductos
    FROM sc_param
    WHERE codparam = 'IdenComMCProductos';
    /**************************************************************************/
    /*                      [FIN] CONSULTA DE PARAMETROS                      */
    /**************************************************************************/

    /**************************************************************************/
    /*     GUARDA STATUS Y PRODUCTOS CONFIGURADOS EN TABLAS TEMPORALES        */
    /**************************************************************************/
    CREATE TEMP TABLE tmp_conf_status (
        status CHAR(1)) WITH NO LOG; 

    CREATE TEMP TABLE tmp_conf_productos (
        producto CHAR(4)) WITH NO LOG;
    
    LET vExisteTMP = 1;

    -- Ciclo que extrae los status y los inserta en la tabla temporal
    FOR vIndice = 1 TO LENGTH( vConfStatus )
        LET vCharAux = SUBSTR( vConfStatus, vIndice, 1 );
        -- NOTA: el proceso no esta preparado para atender cuentas de status 4
        -- por lo que se excluye de las posibles opciones
        IF vCharAux IN ( '1', '2', '3', '5', '6','7', '8', '9' ) THEN
            INSERT INTO tmp_conf_status ( status ) 
                VALUES ( vCharAux );
        END IF;
    END FOR;

    -- Ciclo que extrae los productos y los inserta en la tabla temporal
    FOR vIndice = 1 TO LENGTH ( vConfProductos )
        LET vCharAux = SUBSTR( vConfProductos, vIndice, 1 );
        IF vCharAux IN ( '1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
            LET vStringAux = vStringAux || vCharAux;
            IF LENGTH ( vStringAux ) > 3 THEN
                INSERT INTO tmp_conf_productos ( producto ) 
                    VALUES ( vStringAux );    
                LET vStringAux = '';
            END IF;
        ELSE
            LET vStringAux = '';
        END IF;
    END FOR;

    -- Se valida que la configuracion de status y productos tenga datos
    SELECT COUNT(*)
    INTO vCantConfStatus
    FROM tmp_conf_status;
    
    SELECT COUNT(*)
    INTO vCantConfProductos
    FROM tmp_conf_productos;
    
    IF vCantConfStatus == 0 THEN
        LET vErrorInfo   = "Error: No se detecto la configuracion de status";
    END IF;
    
    IF vCantConfProductos == 0 THEN
        LET vErrorInfo   = "Error: No se detecto la configuracion de productos";
    END IF;

    IF vErrorInfo <> '' THEN
        DROP TABLE tmp_conf_status;
        DROP TABLE tmp_conf_productos;
        LET vCodRet = "00001";
        RETURN vCodRet, vErrorInfo;
    END IF;

    /**************************************************************************/
    /*    [FIN] GUARDA STATUS Y PRODUCTOS CONFIGURADOS EN TABLAS TEMPORALES   */
    /**************************************************************************/
    
    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    --  Cancela las ejecuciones de identificacion previas inconclusas
    UPDATE sc_bitacora_com_manejo_cta
    SET fecha_hora_fin = CURRENT,
    status = 'CANCELADO'
    WHERE aniomes = vAnioMes
    AND etapa IN ( 'INICIA IDENTIFICACION', 'IDENTIFICACION' )
    AND status = 'EN PROCESO';

    LET vFechaHoraIni = CURRENT;

    -- Registra la nueva ejecucion
    INSERT INTO sc_bitacora_com_manejo_cta (aniomes, etapa, status, fecha_hora_ini)
        VALUES (vAnioMes, 'INICIA IDENTIFICACION', 'EN PROCESO', vFechaHoraIni);

    -- Se crea o actualiza registro de totales del aniomes procesado
    IF NOT EXISTS (  SELECT 1 FROM sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes AND etapa = 'TOTALES' ) THEN

        INSERT INTO sc_bitacora_com_manejo_cta (aniomes, etapa, hilo, status, cuentas_procesadas, 
            cuentas_identificadas,  cuentas_cobradas)
            VALUES (vAnioMes, 'TOTALES', '', '', '0', '0', '0');
    ELSE
        UPDATE sc_bitacora_com_manejo_cta
        SET cuentas_procesadas = '0',
        cuentas_identificadas = '0',
        cuentas_cobradas = '0'
        WHERE aniomes = vAnioMes
        AND etapa = 'TOTALES';
    END IF;
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/

    /**************************************************************************/
    /*           PROCESO PRINCIPAL: DIVISION DE CARGA DE TRABAJO              */
    /**************************************************************************/
    TRUNCATE TABLE sc_com_manejo_ctas_a_cobrar;
    Truncate Table movs_cred_com_cta;

    -- Universo movimientos de credito
    Insert Into movs_cred_com_cta
    Select num_credito, fecha_mov, reversado, transacc_suc
    From bdicred:sd_movhis
    Where empresa = vEmpresa and reversado <> 'S' and transacc_suc in('9770', '4272')
    and fecha_mov Between vFechaInicial and vFechaFinal;
    
    -- Extrae las cuentas a procesar
    SELECT chq.num_cte
    FROM sc_maechq AS chq INNER JOIN tmp_conf_status AS c_stat ON chq.status_cta = c_stat.status
    INNER JOIN tmp_conf_productos AS c_prod ON chq.producto = c_prod.producto
    INNER JOIN sc_maenoc AS noc ON chq.cuenta = noc.cuenta
    WHERE noc.fecha_alta < vFechaInicial
    INTO TEMP tmp_ctas_total WITH NO LOG;

    LET vExisteTMP2 = 1;

    CREATE INDEX idx_tmp_ctas_total ON tmp_ctas_total( num_cte ) USING BTREE;

    -- Ya no se necesitan las tablas tmp de configuracion
    DROP TABLE tmp_conf_status;
    DROP TABLE tmp_conf_productos;
    LET vExisteTMP   = 0;
    
    -- Se calcula la cantidad de cuentas que atendera cada hilo
    SELECT COUNT(*)
    INTO vCtasTotal
    FROM tmp_ctas_total;

    LET vCtasPorHilo = FLOOR( vCtasTotal / vCantHilos );

    -- Se obtiene el ultimo cliente que debe procesar cada hilo
    -- excepto para el ultimo hilo, ese termina con el ultimo cte de la tabla
    WHILE vNumHilo < vCantHilos
        
        FOREACH
        SELECT SKIP vCtasPorHilo FIRST 1 num_cte
            INTO vUltimoCteHilo 
            FROM tmp_ctas_total
            WHERE num_cte >= vUltimoCteHilo
            ORDER BY num_cte ASC
        END FOREACH;

        -- Cada ultimo cliente debe guardarse en la sc_param
        UPDATE sc_param 
            SET valor = vUltimoCteHilo 
            WHERE codparam = 'UltCteIdentComMC'||vNumHilo;
        
        LET vNumHilo = vNumHilo + 1;
    END WHILE;
    /**************************************************************************/
    /*                       [FIN] PROCESO PRINCIPAL                          */
    /**************************************************************************/
    
    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Actualiza el status de 'EN PROCESO' a 'FINALIZADO'
    LET vSQL = 'echo "UPDATE sc_bitacora_com_manejo_cta' ||
                ' SET fecha_hora_fin = CURRENT,' ||
                ' status = ''FINALIZADO'' ' ||
                ' WHERE aniomes = ''' || vAnioMes || '''' ||
                ' AND etapa = ''INICIA IDENTIFICACION''' ||
                ' AND status = ''EN PROCESO''' ||
                ' AND fecha_hora_ini = ''' || vFechaHoraIni || '''' ||
                ';" > '|| vArchivoSQL ;
    SYSTEM vSQL;
    LET vSQL = "chmod 777 " || vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "dbaccess bdicheq " || vArchivoSQL;
    SYSTEM vSQL;
    
    -- Coloca el total de cuentas a procesar en el registro de totales
    UPDATE sc_bitacora_com_manejo_cta
        SET cuentas_procesadas = vCtasTotal
         WHERE aniomes = vAnioMes
         AND etapa = 'TOTALES';
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/
    DROP TABLE tmp_ctas_total;
      
    RETURN vCodRet, vErrorInfo;
    END
END PROCEDURE;