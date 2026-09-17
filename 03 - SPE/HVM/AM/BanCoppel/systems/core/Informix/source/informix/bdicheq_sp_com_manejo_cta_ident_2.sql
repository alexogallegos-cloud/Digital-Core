CREATE PROCEDURE "informix".sp_com_manejo_cta_ident_2()
    RETURNING CHAR(5), VARCHAR(80);
-- *****************************************************************************
-- Version          1.0.0
-- Objetivo:        Toma un cliente y analiza sus cuentas para
--                   decidir si se le cobrara la "Comision por Manejo de
--                   Cuenta", las cuentas que deben pagar son guardadas en la
--                   tabla sc_com_manejo_ctas_a_cobrar.
-- Creado por:      Joel Martinez
-- Fecha:           Septiembre - 2024
-- *****************************************************************************
    
    DEFINE vNumHilo                 SMALLINT;
    DEFINE vCodRet                  CHAR(5);
    DEFINE vErrorInfo               VARCHAR(80);
    DEFINE vIsamErr                 SMALLINT;
    DEFINE vSQLErr                  INTEGER;
    DEFINE vEmpresa                 CHAR(3);
    DEFINE vFechaInicial            DATE;
    DEFINE vFechaFinal              DATE;
    DEFINE vAnioMes                 CHAR(6);
    DEFINE vSdoPromMinGral          INTEGER;
    DEFINE vSdoPromMin2500          INTEGER;
    DEFINE vUltimoCteHiloAnterior   CHAR(20);
    DEFINE vUltimoCteHiloActual     CHAR(20);
    DEFINE vFechConMovHis           DATE;
    DEFINE vUltimoCteProcesado      CHAR(20);
    DEFINE vFechaHoraFinIniciador   DATETIME YEAR TO FRACTION(3);
    DEFINE vFechaHoraIni            DATETIME YEAR TO FRACTION(3);
    DEFINE vStatusPrevio            VARCHAR(10);
    DEFINE vStatusIniciador         VARCHAR(10);
    DEFINE vIndice                  SMALLINT;
    DEFINE vConfStatus              VARCHAR(60);
    DEFINE vConfProductos           VARCHAR(60);
    DEFINE vCharAux                 CHAR(1);
    DEFINE vStringAux               VARCHAR(4);
    DEFINE vExisteTMP               SMALLINT;
    DEFINE vExisteTMP2              SMALLINT;
    DEFINE vExisteTMP3              SMALLINT;
    DEFINE vExisteTMP4              SMALLINT;
    DEFINE vContCtasInsertadas      INTEGER;
    DEFINE vNumCte                  CHAR(20);
    DEFINE vCuenta                  CHAR(20);
    DEFINE vSucursal                CHAR(4);
    DEFINE vCantCtasProcesadas      INTEGER;
    DEFINE vCantCtasIdentificadas   INTEGER;
    DEFINE vCantCtasInversion       SMALLINT;
    DEFINE vCantCtasPagare          SMALLINT;
    DEFINE vCantMovHis              SMALLINT;
    DEFINE vCantMovHisOld           SMALLINT;
    DEFINE cCantMovCred             SMALLINT;
    DEFINE vParamMontCargo          MONEY(14,2);
    DEFINE vArchivoSQL              CHAR(50);
    DEFINE vSQL                     CHAR(350);
    
    LET vNumHilo                = 2;
    LET vCodRet                 = "00000";
    LET vEmpresa                = "001";
    LET vErrorInfo              = '';
    LET vIsamErr                = 0;
    LET vSQLErr                 = 0; 
    LET vFechaInicial           = '';
    LET vFechaFinal             = '';
    LET vAnioMes                = '';
    LET vSdoPromMinGral         = 0;
    LET vSdoPromMin2500         = 0;
    LET vUltimoCteHiloAnterior  = '';
    LET vUltimoCteHiloActual    = ''; 
    LET vFechConMovHis          = '';
    LET vUltimoCteProcesado     = '';
    LET vFechaHoraFinIniciador  = '';
    LET vFechaHoraIni           = '';
    LET vStatusPrevio           = '';
    LET vStatusIniciador        = '';
    LET vIndice                 = 0;
    LET vConfStatus             = '';
    LET vConfProductos          = '';
    LET vCharAux                = '';
    LET vStringAux              = '';
    LET vExisteTMP              = 0;
    LET vExisteTMP2             = 0;
    LET vExisteTMP3             = 0;
    LET vExisteTMP4             = 0;
    LET vContCtasInsertadas     = 0;
    LET vNumCte                 = '';
    LET vCuenta                 = '';
    LET vSucursal               = '';
    LET vCantCtasProcesadas     = 0;
    LET vCantCtasIdentificadas  = 0; 
    LET vCantCtasInversion      = 0;
    LET vCantCtasPagare         = 0;
    LET vCantMovHis             = 0;
    LET vCantMovHisOld          = 0;
    LET cCantMovCred            = 0;
    LET vParamMontCargo         = 150.00;
    LET vArchivoSQL             = "/resplogifx/conciliachq/updatebitacora" || vNumHilo ||".sql";
    LET vSQL                    = '';

    BEGIN
    ON EXCEPTION SET vSQLErr, vIsamErr, vErrorInfo
        IF  vSQLErr != 0 THEN
            SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_2.err';
            TRACE ON;
            LET vCodRet     = vSQLErr;
            LET vIsamErr    = vIsamErr;
            LET vErrorInfo   = vErrorInfo;
            LET vNumCte     = vNumCte;
            LET vCuenta     = vCuenta;
        
            IF vExisteTMP = 1 THEN
                DROP TABLE tmp_conf_status;
                DROP TABLE tmp_conf_productos; 
            END IF;
        
            IF vExisteTMP2 = 1 THEN
                DROP TABLE tmp_ctas_total;
                DROP TABLE tmp_ctas_cte;
            END IF;
        
            IF vExisteTMP3 = 1 THEN
                DROP TABLE tmp_ctes_exentos;
            END IF;

            IF vExisteTMP4 = 1 THEN
                DROP TABLE tmp_ctes_sin_sdo_prom;
            END IF;
        
            IF vContCtasInsertadas > 0 THEN
                ROLLBACK;
            END IF;
        
            RETURN vCodRet, vErrorInfo;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_2.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
    
    /**************************************************************************/
    /*                         CONSULTA DE PARAMETROS                         */
    /**************************************************************************/
    -- El periodo a procesar, sera del primero al ultimo dia del mes anterior
    SELECT DATE( pri_dia_mes - 1 UNITS MONTH ),
    DATE( pri_dia_mes - 1 UNITS DAY )
    INTO vFechaInicial, vFechaFinal
    FROM sc_fechas
    WHERE  empresa = vEmpresa;
    
    -- Extrae aÃ±o y mes que se procesara
    LET vAnioMes = TO_CHAR(vFechaInicial,"%Y%m");

    -- Saldo promedio minimo general
    SELECT valor 
    INTO vSdoPromMinGral
    FROM sc_param
    WHERE codparam = "sdoprom";

    -- Saldo promedio minimo para producto 2500
    SELECT valor 
    INTO vSdoPromMin2500
    FROM sc_param
    WHERE codparam = "sdoprom_2500";
    
    -- Obtiene el ultimo cliente del hilo anterior, para iniciar despues de el
    SELECT valor 
    INTO vUltimoCteHiloAnterior
    FROM sc_param 
    WHERE codparam = "UltCteIdentComMC" || ( vNumHilo - 1 );
    
    -- Obtiene el ultimo cte que atendera este hilo
    SELECT valor 
    INTO vUltimoCteHiloActual
    FROM sc_param 
    WHERE codparam = "UltCteIdentComMC" || vNumHilo;

    -- Fecha de concentrado de la tabla sc_movhis_old
    SELECT TO_DATE(valor, '%m/%d/%Y')
    INTO vFechConMovHis
    FROM sc_param 
    WHERE codparam = "fechcon_movhis";
    
    -- Se obtienen los status de las cuentas a considerar
    SELECT valor
    INTO vConfStatus
    FROM sc_param
    WHERE codparam = "IdenComMCStatus";
    
    -- Se obtienen los productos de las cuentas a considerar
    SELECT valor
    INTO vConfProductos
    FROM sc_param
    WHERE codparam = "IdenComMCProductos";
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
        IF vCharAux IN ( '1', '2', '3', '5', '6', '7', '8', '9' ) THEN
            INSERT INTO tmp_conf_status ( status ) 
                VALUES ( vCharAux );
        END IF;
    END FOR;
    
    -- Ciclo que extrae los productos y los inserta en la tabla temporal
    FOR vIndice = 1 TO LENGTH( vConfProductos )
        LET vCharAux = SUBSTR( vConfProductos, vIndice, 1 );
        IF vCharAux IN ( '1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
            LET vStringAux = vStringAux || vCharAux;
            IF LENGTH( vStringAux ) > 3 THEN
                INSERT INTO tmp_conf_productos ( producto ) 
                    VALUES ( vStringAux );    
                LET vStringAux = '';
            END IF;
        ELSE
            LET vStringAux = '';
        END IF;
    END FOR;
    /**************************************************************************/
    /*    [FIN] GUARDA STATUS Y PRODUCTOS CONFIGURADOS EN TABLAS TEMPORALES   */
    /**************************************************************************/

    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Revisa que la ultima ejecucion del proceso iniciador haya concluido
    FOREACH 
        SELECT FIRST 1 status, fecha_hora_fin
        INTO vStatusIniciador, vFechaHoraFinIniciador
        FROM sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes
        AND etapa = 'INICIA IDENTIFICACION'
        ORDER BY fecha_hora_fin DESC
    END FOREACH;

    IF  vStatusIniciador <> 'FINALIZADO' THEN
        -- Error, el proceso iniciador no ha finalizado
        DROP TABLE tmp_conf_status;
        DROP TABLE tmp_conf_productos;
        LET vCodRet = "00002";
        LET vErrorInfo = "Error: El proceso iniciador no ha finalizado";
        RETURN vCodRet, vErrorInfo;
    END IF;

    -- Revisa si hay una ejecucion previa de este hilo
    FOREACH
        SELECT FIRST 1 status, fecha_hora_ini 
        INTO vStatusPrevio, vFechaHoraIni
        FROM sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes
        AND etapa = 'IDENTIFICACION'
        AND hilo = vNumHilo
        AND fecha_hora_ini > vFechaHoraFinIniciador
        ORDER BY fecha_hora_ini DESC
    END FOREACH;

    IF vStatusPrevio = 'FINALIZADO' THEN 
        -- Se cancela todo, el proceso ya se ha finalizado previamente
        DROP TABLE tmp_conf_status;
        DROP TABLE tmp_conf_productos;
        LET vCodRet = "00003";
        LET vErrorInfo = "Este hilo ya ha finalizado en una ejecucion previa";
        RETURN vCodRet, vErrorInfo;
    END IF;

    IF vStatusPrevio = 'EN PROCESO' THEN 
        -- Retoma donde se quedo la ejecucion previa inconclusa
        SELECT MAX( cliente )
        INTO vUltimoCteProcesado
        FROM sc_com_manejo_ctas_a_cobrar
        WHERE cliente > vUltimoCteHiloAnterior
        AND cliente <= vUltimoCteHiloActual;

    ELSE
        -- Registra el inicio de la nueva ejecucion
        LET vFechaHoraIni = CURRENT;

        INSERT INTO sc_bitacora_com_manejo_cta (aniomes, etapa, hilo, status, fecha_hora_ini)
            VALUES (vAnioMes, 'IDENTIFICACION', vNumHilo, 'EN PROCESO', vFechaHoraIni);
    END IF;
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/

    /**************************************************************************/
    /*                           PROCESO PRINCIPAL                            */
    /**************************************************************************/
    -- Se valida si ya hay clientes procesados
    IF vUltimoCteProcesado IS NULL OR vUltimoCteProcesado == '' THEN
        -- No se ha procesado ni un cliente, se inicia despues del hilo anterior
        LET vUltimoCteProcesado = vUltimoCteHiloAnterior;
    END IF;

    -- Obtiene las cuentas que procesara este hilo
    SELECT chq.num_cte, chq.cuenta, chq.producto, chq.sucursal, 
    ( sdo.capvigacum / sdo.diacum ) AS sdo_prom
    FROM sc_maechq AS chq
    INNER JOIN tmp_conf_status AS c_stat ON chq.status_cta = c_stat.status
    INNER JOIN tmp_conf_productos AS c_prod ON chq.producto = c_prod.producto
    INNER JOIN sc_maenoc AS noc ON chq.num_cte > vUltimoCteProcesado
    AND chq.num_cte <= vUltimoCteHiloActual AND noc.fecha_alta < vFechaInicial
    AND chq.cuenta = noc.cuenta
    LEFT JOIN sc_sdodiarioc AS sdo ON sdo.aniomes = vAnioMes AND chq.cuenta = sdo.cuenta
    WHERE chq.empresa = vEmpresa
    INTO TEMP tmp_ctas_total WITH NO LOG;

    -- Tabla temporal para guardar las cuentas de un cliente siendo evaluado
    CREATE TEMP TABLE tmp_ctas_cte (
        cuenta CHAR(20),
        sucursal CHAR(4)) WITH NO LOG;
    LET vExisteTMP2 = 1;

    CREATE INDEX idx_tmp_ctas_total ON tmp_ctas_total( num_cte ) 
        USING BTREE;
    CREATE INDEX idx_tmp_ctas_total2 ON tmp_ctas_total( producto, sdo_prom ) 
        USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas_total;

    DROP TABLE tmp_conf_status;
    DROP TABLE tmp_conf_productos;
    LET vExisteTMP = 0;

    -- Si es la primer ejecucion, se guarda cuantas cuentas procesa este hilo
    IF vStatusPrevio = '' THEN
        SELECT COUNT(*)
        INTO vCantCtasProcesadas
        FROM tmp_ctas_total;

        UPDATE sc_bitacora_com_manejo_cta 
        SET cuentas_procesadas = vCantCtasProcesadas
        WHERE aniomes = vAnioMes
        AND etapa = 'IDENTIFICACION'
        AND hilo = vNumHilo
        AND status = 'EN PROCESO'
        AND fecha_hora_ini = vFechaHoraIni;
    END IF;

    -- Tabla temporal que guarda los clientes que exentan por saldo promedio
    CREATE TEMP TABLE tmp_ctes_exentos (
        num_cte CHAR(20)) WITH NO LOG;
    CREATE INDEX idx_tmp_ctes_exentos ON tmp_ctes_exentos( num_cte );
    LET vExisteTMP3 = 1;

    /* EXENCION POR CUMPLIR CON SALDO PROMEDIO MINIMO */
    INSERT INTO tmp_ctes_exentos ( num_cte )
    SELECT num_cte
    FROM tmp_ctas_total 
    WHERE producto <> "2500" 
    AND sdo_prom >= vSdoPromMinGral;

    INSERT INTO tmp_ctes_exentos ( num_cte )
    SELECT num_cte
    FROM tmp_ctas_total 
    WHERE producto = "2500" 
    AND  sdo_prom >= vSdoPromMin2500;
            
    SELECT DISTINCT( num_cte )
    FROM tmp_ctas_total AS ctas
    WHERE NOT EXISTS(SELECT 1 
                    FROM tmp_ctes_exentos AS exentos 
                    WHERE ctas.num_cte = exentos.num_cte)
    INTO TEMP tmp_ctes_sin_sdo_prom WITH NO LOG;
    LET vExisteTMP4 = 1;
    CREATE INDEX idx_tmp_ctes_sin_sdo_prom ON tmp_ctes_sin_sdo_prom( num_cte );
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_sin_sdo_prom;
    /* [FIN] EXENCION POR CUMPLIR CON SALDO PROMEDIO MINIMO */

    DROP TABLE tmp_ctes_exentos;
    LET vExisteTMP3 = 0;

    -- Ciclo principal que procesa las cuentas
    FOREACH WITH HOLD
        SELECT num_cte
        INTO vNumCte
        FROM tmp_ctes_sin_sdo_prom
        ORDER BY num_cte ASC
        
        DELETE FROM tmp_ctas_cte;

        /*   EXENCION POR CUENTA INVERSION CRECIENTE   */
        SELECT COUNT(*)
        INTO vCantCtasInversion
        FROM sc_maechq AS chq 
        WHERE chq.num_cte = vNumCte
        AND chq.producto = "1100"
        AND chq.status_cta = '1';
                    
        IF vCantCtasInversion > 0 THEN 
            -- si entra aqui, es porque este cte exento, se salta al siguiente
            CONTINUE FOREACH;
        END IF;

        /*         EXENCION POR CUENTA PAGARE      */     
        SELECT COUNT(*)
        INTO vCantCtasPagare
        FROM bdinvers:sv_maeinv AS inv 
        WHERE inv.num_cte = vNumCte
        AND inv.cod_instrum = "3000"
        AND inv.status_cta = '1';
        
        IF vCantCtasPagare > 0 THEN
            -- si entra aqui, es porque este cte exento, se salta al siguiente
            CONTINUE FOREACH;
        END IF;
    
        /*     EXENCION POR MOVIMIENTO DE PORTABILIDAD DE NOMINA     */
        FOREACH WITH HOLD
            SELECT cuenta, sucursal
            INTO vCuenta, vSucursal
            FROM tmp_ctas_total
            WHERE num_cte = vNumCte

            SELECT COUNT(*) 
            INTO vCantMovHis
            FROM sc_movhis AS mov
            WHERE mov.empresa  = vEmpresa
            AND mov.cuenta = vCuenta
            AND mov.fech_alt BETWEEN vFechaInicial AND vFechaFinal
            AND mov.cancelad <> 'S'
            AND mov.transacc = "0273"
            AND mov.referencia LIKE "%NNNN%";
            
           IF vCantMovHis > 0 THEN
                -- si entra aqui es porque la cuenta exento
                -- se exentan todas las ctas del cte
                DELETE FROM tmp_ctas_cte;
                EXIT FOREACH;

           END IF;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            IF vFechaInicial < vFechConMovHis THEN
                SELECT COUNT(*)
                INTO vCantMovHisOld
                FROM sc_movhis_old AS mov 
                WHERE mov.empresa  = vEmpresa
                AND mov.cuenta = vCuenta
                AND mov.fech_alt BETWEEN vFechaInicial  AND vFechaFinal
                AND mov.cancelad <> 'S'
                AND mov.transacc = "0273"
                AND mov.referencia LIKE "%NNNN%";
                        
                IF vCantMovHisOld > 0 THEN
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    DELETE FROM tmp_ctas_cte;
                    EXIT FOREACH;
                END IF;
            END IF;
            /*  [FIN] EXENCION POR MOVIMIENTO DE PORTABILIDAD DE NOMINA   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            INSERT INTO tmp_ctas_cte (cuenta, sucursal )
                VALUES ( vCuenta, vSucursal );
        END FOREACH;

        /*     EXENCION POR CARGO RECURRENTE     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc = '1141' and monto_tot >= vParamMontCargo
            Having count(*) > 1;
            
            If vCantMovHis >= 2 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc = '1141' and monto_tot >= vParamMontCargo
                Having count(*) > 1;
                        
                If vCantMovHisOld >= 2 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR CARGO RECURRENTE   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        /*     EXENCION POR PRESTAMO PERSONAL BANCOPPEL     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc = '0548';
            
            If vCantMovHis > 0 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc = '0548';
                        
                If vCantMovHisOld > 0 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR PRESTAMO PERSONAL BANCOPPEL   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        /*     EXENCION POR PRESTAMO PERSONAL COPPEL     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc in('0253', '1667');
            
            If vCantMovHis > 0 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc in('0253', '1667');
                        
                If vCantMovHisOld > 0 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR PRESTAMO PERSONAL COPPEL   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;
        
        -- Si llega a este punto, significa que ninguna cta del cte ha exentado
        -- por lo que se guardan en la tabla sc_com_manejo_ctas_a_cobrar
        FOREACH WITH HOLD
            SELECT cuenta, sucursal
            INTO vCuenta, vSucursal
            FROM tmp_ctas_cte
            Group By cuenta, sucursal

            IF vContCtasInsertadas = 0 THEN
                BEGIN WORK;
            END IF;

            LET vContCtasInsertadas = vContCtasInsertadas + 1;

            INSERT INTO sc_com_manejo_ctas_a_cobrar ( cliente, cuenta, sucursal )
                VALUES ( vNumCte, vCuenta, vSucursal );        
        END FOREACH;

        IF vContCtasInsertadas >= 5000 THEN
            LET vContCtasInsertadas = 0;
            COMMIT WORK;
        END IF; 
        
    END FOREACH;

    -- Se valida si hay inserts pendientes de commits
    IF vContCtasInsertadas > 0 THEN
        LET vContCtasInsertadas = 0;
        COMMIT WORK;
    END IF;

    /**************************************************************************/
    /*                       [FIN] PROCESO PRINCIPAL                          */
    /**************************************************************************/
    
    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Obtiene la cantidad de cuentas identificadas
    SELECT COUNT(*)
    INTO vCantCtasIdentificadas
    FROM sc_com_manejo_ctas_a_cobrar
    WHERE cliente > vUltimoCteHiloAnterior AND cliente <= vUltimoCteHiloActual;
     
    LET vSQL = 'echo "UPDATE sc_bitacora_com_manejo_cta' ||
                ' SET fecha_hora_fin = CURRENT,' ||
                ' status = ''FINALIZADO'',' ||
                ' cuentas_identificadas = ' || vCantCtasIdentificadas ||
                ' WHERE aniomes = ''' || vAnioMes || '''' ||
                ' AND etapa = ''IDENTIFICACION''' ||
                ' AND hilo = ' || vNumHilo ||
                ' AND status = ''EN PROCESO''' ||
                ' AND fecha_hora_ini = ''' || vFechaHoraIni || '''' ||
                ';" > '|| vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "chmod 777 " || vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "dbaccess bdicheq " || vArchivoSQL;
    SYSTEM vSQL;

    -- Actualiza el registro de totales
    UPDATE sc_bitacora_com_manejo_cta
        SET cuentas_identificadas = 
            ( cuentas_identificadas + vCantCtasIdentificadas )::INTEGER
         WHERE aniomes = vAnioMes
         AND etapa = 'TOTALES';
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/
    DROP TABLE tmp_ctas_total;
    DROP TABLE tmp_ctas_cte;
    DROP TABLE tmp_ctes_sin_sdo_prom;
        
    RETURN vCodRet, vErrorInfo;
    END
END PROCEDURE;