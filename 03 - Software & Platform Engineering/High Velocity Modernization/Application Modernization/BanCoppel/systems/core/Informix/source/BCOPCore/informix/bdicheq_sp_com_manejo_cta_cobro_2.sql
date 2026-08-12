CREATE PROCEDURE "informix".sp_com_manejo_cta_cobro_2()
    RETURNING CHAR(5), VARCHAR(80);

-- *****************************************************************************
-- Version          1.0.0
-- Objetivo:        Realiza el "Cobro de Comision por Manejo de
--                  Cuenta" de las cuentas previamente guardadas
--                  en la tabla sc_com_manejo_ctas_a_cobrar 
-- Creado por:      Gabriel Torreblanca
-- Fecha:           Septiembre - 2024
-- *****************************************************************************

    DEFINE vNumHilo                     SMALLINT;
    DEFINE vCodRet                      CHAR(5);
    DEFINE vErrorInfo                   VARCHAR(80);
    DEFINE vIsamErr                     SMALLINT;
    DEFINE vSQLErr                      INTEGER;
    DEFINE vEnTransacc                  SMALLINT;
    DEFINE vEmpresa                     CHAR(3);
    DEFINE vFechaCobro                  DATE;
    DEFINE vFechaAux                    DATE;
    DEFINE vAnioMes                     CHAR(6);
    DEFINE vNumTranCom                  CHAR(4);
    DEFINE vNumTranIVA                  CHAR(4);
    DEFINE vMontoCom                    MONEY(14,2);
    DEFINE vPorcentajeIVA               DECIMAL(14,2);
    DEFINE vComisionMasIVA              MONEY(14,2); 
    DEFINE vMontoIVA                    MONEY(14,2);
    DEFINE vUsuario                     CHAR(8);
    DEFINE vHora                        CHAR(12);
    DEFINE vFolio                       CHAR(16);
    DEFINE vDivisa                      CHAR(2);
    DEFINE vUltimaCtaHiloAnterior       CHAR(20);
    DEFINE vUltimaCtaHiloActual         CHAR(20);
    DEFINE vFechaHoraFinIniciador       DATETIME YEAR TO FRACTION(3);
    DEFINE vFechaHoraIni                DATETIME YEAR TO FRACTION(3);
    DEFINE vStatusPrevio                VARCHAR(10);
    DEFINE vStatusIniciador             VARCHAR(10);
    DEFINE vPrimerCtaSinIntentoCobro    CHAR(20);
    DEFINE vCuenta                      CHAR(20);
    DEFINE vCodRetComision              CHAR(5);
    DEFINE vCodRetIVA                   CHAR(5);
    DEFINE vCodRetConSdos               CHAR(5);
    DEFINE vTranRet                     CHAR(4);
    DEFINE vSucursal                    CHAR(4);
    DEFINE vSaldoDisponible             MONEY(14,2);
    DEFINE vCantCtasProcesadas          INTEGER;
    DEFINE vCtasCobradas                INTEGER;
    DEFINE vCobro                       CHAR(1);
    DEFINE vExisteTMP                   SMALLINT;
    DEFINE vArchivoSQL                  CHAR(50);
    DEFINE vSQL                         CHAR(400);

    DEFINE vRet2    CHAR(20);
    DEFINE vRet3    CHAR(20);
    DEFINE vRet4    CHAR(26);
    DEFINE vRet5    CHAR(26);
    DEFINE vRet6    CHAR(26);
    DEFINE vRet7    CHAR(26);
    DEFINE vRet8    CHAR(60);
    DEFINE vRet9    CHAR(1);
    DEFINE vRet11   MONEY(14,2);
    DEFINE vRet12   MONEY(14,2);
    DEFINE vRet13   MONEY(14,2);
    DEFINE vRet14   MONEY(14,2);
    DEFINE vRet15   CHAR(1);
    DEFINE vRet16   CHAR(40);
    DEFINE vRet17   CHAR(40); 
    DEFINE vRet18   MONEY(14,2);
    DEFINE vRet19   MONEY(14,2);
    DEFINE vRet20   MONEY(14,2);
    DEFINE vRet21   CHAR(8);
    DEFINE vRet22   DATE;
    DEFINE vRet23   CHAR(16);
    DEFINE vRet24   CHAR(18);

    LET vNumHilo                    = 2;
    LET vCodRet                     = "00000";
    LET vErrorInfo                  = '';
    LET vIsamErr                    = 0;
    LET vSQLErr                     = '';
    LET vEnTransacc                 = 0;
    LET vEmpresa                    = "001";
    LET vFechaCobro                 = '';
    LET vFechaAux                   = '';
    LET vAnioMes                    = '';
    LET vNumTranCom                 = '';
    LET vNumTranIVA                 = "0260";
    LET vMontoCom                   = 0.00;
    LET vPorcentajeIVA              = 0.00;
    LET vComisionMasIVA             = 0.00;
    LET vMontoIVA                   = 0.00;
    LET vUsuario                    = "informix";
    LET vHora                       = '';
    LET vFolio                      = '';
    LET vDivisa                     = "01";
    LET vUltimaCtaHiloAnterior      = '';
    LET vUltimaCtaHiloActual        = '';
    LET vPrimerCtaSinIntentoCobro   = '';
    LET vFechaHoraFinIniciador      = '';
    LET vFechaHoraIni               = '';
    LET vStatusPrevio               = '';
    LET vStatusIniciador            = '';
    LET vCuenta                     = '';
    LET vCodRetComision             = "000";
    LET vCodRetIVA                  = "000";
    LET vCodRetConSdos              = "000";
    LET vTranRet                    = '';
    LET vSucursal                   = '';
    LET vSaldoDisponible            = 0;
    LET vCantCtasProcesadas         = 0;
    LET vCtasCobradas               = 0;
    LET vCobro                      = '0';
    LET vExisteTMP                  = 0;
    LET vArchivoSQL                 = "/resplogifx/conciliachq/updatebitacora" || vNumHilo ||".sql";
    LET vSQL                        = '';

    LET vRet2   = '';
    LET vRet3   = '';
    LET vRet4   = '';
    LET vRet5   = '';
    LET vRet6   = '';
    LET vRet7   = '';
    LET vRet8   = '';
    LET vRet9   = '';
    LET vRet11  = 0;
    LET vRet12  = 0;
    LET vRet13  = 0;
    LET vRet14  = 0;
    LET vRet15  = "";
    LET vRet16  = '';
    LET vRet17  = "";
    LET vRet18  = 0;
    LET vRet19  = 0;
    LET vRet20  = 0;
    LET vRet21  = "";
    LET vRet22  = "";
    LET vRet23  = '';
    LET vRet24  = "";

BEGIN
    ON EXCEPTION SET vSQLErr, vIsamErr, vErrorInfo
        IF  vSQLErr != 0 THEN
            SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_cobro_2.err';
            TRACE ON;
            LET vCodRet     = vSQLErr;
            LET vIsamErr    = vIsamErr;
            LET vErrorInfo   = vErrorInfo;
            LET vCuenta     = vCuenta;
            IF vEnTransacc == 1 THEN
                ROLLBACK;
            END IF;
            IF vExisteTMP = 1 THEN
                DROP TABLE tmp_ctas_pendientes;
            END IF;
            RETURN vCodRet, vErrorInfo;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_com_manejo_cta_cobro_2.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    /**************************************************************************/
    /*                         CONSULTA DE PARAMETROS                         */
    /**************************************************************************/
    -- Obtiene la fecha de intento de cobro
    SELECT fecha_ant
        INTO vFechaCobro
        FROM "informix".sc_fechas
        WHERE empresa = vEmpresa;

    -- Obtiene el aÃ±o y el mes al que corresponde la comision que se cobra
    LET vFechaAux = DATE( vFechaCobro - 1 UNITS MONTH );
    LET vAnioMes = TO_CHAR(vFechaAux,'%Y%m');

    -- Obtiene el numero de la transaccion
    SELECT valor
        INTO   vNumTranCom
        FROM   "informix".sc_param 
        WHERE  codparam = "trancobcom"
            AND empresa = vEmpresa;

    -- Obtiene el monto de la comision
    SELECT valor
        INTO vMontoCom
        FROM "informix".sc_param
        WHERE codparam = "montocom"
            AND empresa = vEmpresa;

    -- Obtiene el valor porcentual del IVA 
    SELECT valor
        INTO   vPorcentajeIVA
        FROM   bdinteg:"informix".si_param
        WHERE  empresa = vEmpresa
            AND    cod_param = 47;

    -- Calcula el monto del IVA y el total
    LET vMontoIVA = vMontoCom * vPorcentajeIVA;
    LET vComisionMasIVA = vMontoCom + vMontoIVA;

    -- Se genera el folio de cobro
    LET vHora = CURRENT HOUR TO FRACTION;
    LET vFolio = vUsuario||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];

    -- Obtiene la ultima cuenta del hilo anterior, para iniciar despues de el
    SELECT valor
        INTO vUltimaCtaHiloAnterior
        FROM "informix".sc_param
        WHERE empresa = vEmpresa
            AND codparam = 'UltCtaCobroComMC' || ( vNumHilo - 1 );

    -- Obtiene la ultima cuenta que atendera este hilo
    SELECT valor
        INTO vUltimaCtaHiloActual
        FROM "informix".sc_param
        WHERE empresa = vEmpresa
            AND codparam = 'UltCtaCobroComMC' || vNumHilo;

    /**************************************************************************/
    /*                      [FIN] CONSULTA DE PARAMETROS                      */
    /**************************************************************************/

    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Revisa que la ultima ejecucion del proceso iniciador haya concluido
    FOREACH
    SELECT FIRST 1 status, fecha_hora_fin
        INTO vStatusIniciador, vFechaHoraFinIniciador
        FROM "informix".sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes
            AND etapa = 'INICIA COBRANZA'
        ORDER BY fecha_hora_fin DESC
    END FOREACH;

    IF  vStatusIniciador <> 'FINALIZADO' THEN
        -- Error, el proceso iniciador no ha Finalizado
        LET vCodRet     = "00002";
        LET vErrorInfo   = "Error: El proceso iniciador no ha finalizado";
        RETURN vCodRet, vErrorInfo;
    END IF;

    -- Revisa si hay una ejecucion previa de este hilo
    FOREACH
    SELECT FIRST 1 status, fecha_hora_ini
        INTO vStatusPrevio, vFechaHoraIni
        FROM "informix".sc_bitacora_com_manejo_cta
        WHERE aniomes = vAnioMes
            AND etapa = 'COBRANZA'
            AND hilo = vNumHilo
            AND fecha_hora_ini > vFechaHoraFinIniciador
        ORDER BY fecha_hora_ini DESC
    END FOREACH;

    IF vStatusPrevio = 'FINALIZADO' THEN
        -- Se cancela todo, el proceso ya se ha finalizado previamente
        LET vCodRet     = "00003";
        LET vErrorInfo   = "Este hilo ya ha finalizado en una ejecucion previa";
        RETURN vCodRet, vErrorInfo;
    END IF;

    IF vStatusPrevio = 'EN PROCESO' THEN
        -- Busca la primer cuenta de las que aun no se ha intentado cobrar
        SELECT MIN( cuenta )
            INTO vPrimerCtaSinIntentoCobro
            FROM "informix".sc_com_manejo_ctas_a_cobrar 
            WHERE cuenta > vUltimaCtaHiloAnterior
                AND cuenta <= vUltimaCtaHiloActual
                AND fecha_ultimo_intento_cobro < vFechaCobro;
    ELSE
        -- Se registra el inicio de la nueva ejecucion
        LET vFechaHoraIni = CURRENT;

        INSERT INTO "informix".sc_bitacora_com_manejo_cta
            (aniomes, etapa, hilo, status, fecha_hora_ini)
            VALUES (vAnioMes, 'COBRANZA', vNumHilo, 'EN PROCESO', 
                vFechaHoraIni);
    END IF;
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/

    /**************************************************************************/
    /*                           PROCESO PRINCIPAL                            */
    /**************************************************************************/

    -- Si no se ha intentado cobrar a ninguna cuenta
    -- Se inicia despues de donde termina el hilo anterior
    IF vPrimerCtaSinIntentoCobro IS NULL 
        OR vPrimerCtaSinIntentoCobro = '' THEN

        LET vPrimerCtaSinIntentoCobro = vUltimaCtaHiloAnterior;

    END IF;

    SELECT     cuenta, sucursal
        FROM "informix".sc_com_manejo_ctas_a_cobrar 
        WHERE cuenta > vPrimerCtaSinIntentoCobro
            AND cuenta <= vUltimaCtaHiloActual
            AND fecha_ultimo_intento_cobro < vFechaCobro
            AND cobrado = '0'
    INTO TEMP tmp_ctas_pendientes WITH NO LOG;

    LET vExisteTMP = 1;

    CREATE INDEX idx_tmp_ctas_pendientes_2 ON tmp_ctas_pendientes ( cuenta )
        USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas_pendientes;

    -- Si es la primer ejecucion, se guarda cuantas cuentas procesa este hilo
    IF vStatusPrevio = '' THEN
        SELECT COUNT(*)
            INTO vCantCtasProcesadas
            FROM tmp_ctas_pendientes;

        UPDATE "informix".sc_bitacora_com_manejo_cta 
            SET cuentas_procesadas = vCantCtasProcesadas
            WHERE aniomes = vAnioMes
                AND etapa = 'COBRANZA'
                AND hilo = vNumHilo
                AND status = 'EN PROCESO'
                AND fecha_hora_ini = vFechaHoraIni;
    END IF;

    FOREACH WITH HOLD
    SELECT cuenta, sucursal
        INTO vCuenta, vSucursal
        FROM tmp_ctas_pendientes
        ORDER BY cuenta ASC

        BEGIN WORK;
        LET vEnTransacc     = 1;
        LET vCobro          = '0';
        LET vCodRetConSdos  = "000";
        LET vCodRetComision = "000";
        LET vCodRetIVA      = "000";

        -- Se consulta el saldo disponible
        CALL "informix".cons_sdos1 ( vEmpresa, vCuenta, '' )
            RETURNING vCodRetConSdos, vRet2, vRet3, vRet4, vRet5, vRet6, vRet7,
                vRet8, vRet9, vSaldoDisponible, vRet11, vRet12, vRet13,
                vRet14, vRet15, vRet16, vRet17, vRet18, vRet19, vRet20,
                vRet21, vRet22, vRet23, vRet24;

        IF vSaldoDisponible >= vComisionMasIVA THEN

            -- Se realiza el cargo de la comision por manejo de cuenta
            CALL "informix".cargon_ref ( vEmpresa, vSucursal, vUsuario,
                    vNumTranCom, "0000", vFolio, vCuenta, 0, vMontoCom,
                    vDivisa, "", "", "" )
                RETURNING vCodRetComision, vTranRet;

            IF vCodRetComision = '000' THEN
                -- Se realiza el cargo del IVA
                CALL "informix".cargon_ref( vEmpresa, vSucursal, vUsuario, 
                        vNumTranIVA, "0000", vFolio, vCuenta, 0, vMontoIVA,
                        vDivisa, "", "", "")
                    RETURNING vCodRetIVA, vTranRet;

                LET vCobro = '1';
            END IF;

        END IF;

        IF vCodRetComision = '000' AND vCodRetIVA = '000'
            AND vCodRetConSdos = '000' THEN

            UPDATE "informix".sc_com_manejo_ctas_a_cobrar
                    SET cobrado = vCobro,
                        fecha_ultimo_intento_cobro = vFechaCobro
                    WHERE cuenta = vCuenta
                        AND cobrado = '0';

            COMMIT WORK;
            LET vEnTransacc = 0;

        ELSE

            ROLLBACK;
            LET vEnTransacc = 0;
            
            UPDATE "informix".sc_com_manejo_ctas_a_cobrar
                SET fecha_ultimo_intento_cobro = vFechaCobro
                WHERE cuenta = vCuenta;
        END IF;
    END FOREACH;
    /**************************************************************************/
    /*                       [FIN] PROCESO PRINCIPAL                          */
    /**************************************************************************/
    
    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Obtiene a cuantas cuentas se logro cobrar
    SELECT COUNT(*)
        INTO vCtasCobradas
        FROM "informix".sc_com_manejo_ctas_a_cobrar
        WHERE cuenta > vUltimaCtaHiloAnterior
            AND cuenta <= vUltimaCtaHiloActual
            AND fecha_ultimo_intento_cobro = vFechaCobro
            AND cobrado = '1';

    -- REALIZA LA SUMATORIA PARA GUARDAR LOS TOTALES
    UPDATE "informix".sc_bitacora_com_manejo_cta
        SET cuentas_cobradas = (cuentas_cobradas + vCtasCobradas )::INTEGER
            WHERE aniomes = vAnioMes
                AND etapa = 'TOTALES';

    LET vSQL = 'echo "UPDATE informix.sc_bitacora_com_manejo_cta' ||
                ' SET fecha_hora_fin = CURRENT,' ||
                ' status = ''FINALIZADO'',' ||
                ' cuentas_procesadas = ' || vCantCtasProcesadas || ',' ||
                ' cuentas_cobradas = ' || vCtasCobradas ||
                ' WHERE aniomes = ''' || vAnioMes || '''' ||
                ' AND etapa = ''COBRANZA''' ||
                ' AND hilo = ' || vNumHilo ||
                ' AND status = ''EN PROCESO''' ||
                ' AND fecha_hora_ini = ''' || vFechaHoraIni || '''' ||
                ';" > '|| vArchivoSQL ;
    SYSTEM vSQL;
    LET vSQL = "chmod 777 " || vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "dbaccess bdicheq " || vArchivoSQL;
    SYSTEM vSQL;
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/
    DROP TABLE tmp_ctas_pendientes;

    RETURN vCodRet, vErrorInfo;
END
END PROCEDURE;