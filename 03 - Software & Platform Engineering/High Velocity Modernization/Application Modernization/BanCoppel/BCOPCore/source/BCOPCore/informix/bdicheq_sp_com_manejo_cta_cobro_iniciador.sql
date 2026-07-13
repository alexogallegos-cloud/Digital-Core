CREATE PROCEDURE "informix".sp_com_manejo_cta_cobro_iniciador()
    RETURNING CHAR(5), VARCHAR(80);
-- *****************************************************************************
-- Version          1.0.0
-- Objetivo:        Guardar en la tabla sc_param, la cuenta con la que finaliza
--                  cada hilo su parte del proceso de "Cobro de Comision por 
--                  Manejo de Cuenta"
-- Creado por:      Joel Martinez
-- Fecha:           Septiembre - 2024
-- *****************************************************************************

    DEFINE vCodRet              CHAR(5);
    DEFINE vErrorInfo           VARCHAR(80);
    DEFINE vIsamErr             SMALLINT;
    DEFINE vSQLErr              INTEGER;
    DEFINE vFechaCobro          DATE;
    DEFINE vFechaAux            DATE;
    DEFINE vAnioMes             CHAR(6);
    DEFINE vCtasTotal           INTEGER;
    DEFINE vCantHilos           SMALLINT;
    DEFINE vCtasPorHilo         INTEGER;
    DEFINE vNumHilo             SMALLINT;
    DEFINE vUltimaCtaHilo       CHAR(20);
    DEFINE vFechaHoraIni        DATETIME YEAR TO FRACTION(3);
    DEFINE vArchivoSQL          CHAR(50);
    DEFINE vSQL                 CHAR(300);
    DEFINE vEmpresa             CHAR(3);
   
    LET vCodRet             = '00000';
    LET vErrorInfo          = '';
    LET vIsamErr            = 0;
    LET vSQLErr             = 0;
    LET vFechaCobro         = '';
    LET vFechaAux           = '';
    LET vAnioMes            = '';
    LET vCtasTotal          = 0;
    LET vCantHilos          = 5;
    LET vCtasPorHilo        = 0;
    LET vNumHilo            = 1;
    LET vUltimaCtaHilo      = '';
    LET vFechaHoraIni       = '';
    LET vArchivoSQL         = "/resplogifx/conciliachq/updatebitacora.sql";
    LET vSQL                = '';
    LET vEmpresa            = '001';

    BEGIN
    ON EXCEPTION SET vSQLErr, vIsamErr, vErrorInfo
        IF  vSQLErr != 0 THEN
            SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_cobro_iniciador.err';
            TRACE ON;
            LET vCodRet     = vSQLErr;
            LET vIsamErr    = vIsamErr;
            LET vErrorInfo  = vErrorInfo;
            RETURN vCodRet, vErrorInfo;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_cobro_iniciador.out';
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
    LET vAnioMes = TO_CHAR( vFechaAux, '%Y%m' );
    /**************************************************************************/
    /*                      [FIN] CONSULTA DE PARAMETROS                      */
    /**************************************************************************/

    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    LET vFechaHoraIni = CURRENT;

    -- Cancela las ejecuciones de cobranza previas inconclusas
    UPDATE "informix".sc_bitacora_com_manejo_cta
        SET fecha_hora_fin = CURRENT,
            status = 'CANCELADO'
        WHERE aniomes = vAnioMes
            AND etapa IN ( 'INICIO COBRANZA', 'COBRANZA' )
            AND status = 'EN PROCESO';

    -- Registra el inicio de la nueva ejecucion de cobro
    INSERT INTO sc_bitacora_com_manejo_cta
        (aniomes, etapa, status, fecha_hora_ini)
        VALUES (vAnioMes, 'INICIA COBRANZA', 'EN PROCESO', vFechaHoraIni);

    -- Elimina registros de ejecuciones viejas
    DELETE FROM "informix".sc_bitacora_com_manejo_cta
        WHERE fecha_hora_ini < DATE( CURRENT - 60 UNITS DAY)
            AND etapa <> 'TOTALES'; -- solo se conservan los totales

    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/

    /**************************************************************************/
    /*           PROCESO PRINCIPAL: DIVISION DE CARGA DE TRABAJO              */
    /**************************************************************************/
    UPDATE STATISTICS MEDIUM FOR TABLE sc_com_manejo_ctas_a_cobrar;
    
    -- Se calcula la cantidad de cuentas que atendera cada hilo
    SELECT COUNT(*)
        INTO vCtasTotal
        FROM "informix".sc_com_manejo_ctas_a_cobrar
        WHERE cobrado = '0'
            AND fecha_ultimo_intento_cobro < vFechaCobro;

    LET vCtasPorHilo = FLOOR( vCtasTotal / vCantHilos );

    -- Se obtiene la ultima cuenta que debe procesar cada hilo
    -- excepto para el ultimo hilo, ese termina con lal ultima cuenta de la tabla
    WHILE vNumHilo < vCantHilos

        FOREACH
            SELECT SKIP vCtasPorHilo FIRST 1 cuenta
                INTO vUltimaCtaHilo 
                FROM "informix".sc_com_manejo_ctas_a_cobrar
                WHERE cuenta >= vUltimaCtaHilo
                    AND cobrado = '0'
                    AND fecha_ultimo_intento_cobro < vFechaCobro
                ORDER BY cuenta ASC
        END FOREACH;

        -- Cada ultima cuenta debe guardarse en la sc_param
        UPDATE "informix".sc_param
            SET valor = vUltimaCtaHilo 
            WHERE codparam = 'UltCtaCobroComMC' || vNumHilo;

        LET vNumHilo = vNumHilo + 1;

    END WHILE;
    
    -- Para asegurar que el ultimo hilo procese la cuenta con el numero mas alto
    -- lo obtenemos fuera del ciclo
    SELECT NVL(MAX(cuenta), "")
        INTO vUltimaCtaHilo
        FROM "informix".sc_com_manejo_ctas_a_cobrar
        WHERE cobrado = '0'
            AND fecha_ultimo_intento_cobro < vFechaCobro;
        
    UPDATE "informix".sc_param
            SET valor = vUltimaCtaHilo 
            WHERE codparam = 'UltCtaCobroComMC' || vNumHilo;
    /**************************************************************************/
    /*                       [FIN] PROCESO PRINCIPAL                          */
    /**************************************************************************/
    
    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    LET vSQL = 'echo "UPDATE informix.sc_bitacora_com_manejo_cta ' ||
                ' SET fecha_hora_fin = CURRENT, ' ||
                ' status = ''FINALIZADO'' ' ||
                ' WHERE aniomes = ''' || vAnioMes || ''' ' ||
                ' AND etapa = ''INICIA COBRANZA'' ' ||
                ' AND status = ''EN PROCESO'' ' ||
                ' AND fecha_hora_ini = ''' || vFechaHoraIni || ''' ' ||
                ';" > '|| vArchivoSQL ;
    SYSTEM vSQL;
    LET vSQL = "chmod 777 " || vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "dbaccess bdicheq " || vArchivoSQL;
    SYSTEM vSQL;
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/
   
    RETURN vCodRet, vErrorInfo;
END
END PROCEDURE;