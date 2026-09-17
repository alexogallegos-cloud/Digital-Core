CREATE PROCEDURE "informix".calcula_meses_fin_pagomin_base(o_empresa CHAR(3),
                                                                                          o_producto CHAR(4),
                                                                                          o_saldo_no_exigible DECIMAL (18,2),
                                              o_monto_financiado DECIMAL (18,2),
                                              o_tasa DECIMAL (9,4),
                                              o_iva DECIMAL(9,4),
                                              o_fecha_calculo date,
                                                                                          o_factor      SMALLINT)

        RETURNING CHAR(5),
              INTEGER ,
                          DECIMAL (18,2) ;

        -- *********************************************************************
        -- *                        DEFINICION DE VARIABLES                    *
        -- *********************************************************************
        DEFINE scod_ret                 CHAR(5);
        DEFINE p_cod_ret                CHAR(6);
        DEFINE vsqlerr                  INTEGER;
        DEFINE wfecha_hoy               DATE;
    DEFINE vFactorPagoMin           SMALLINT;
    DEFINE TopeMinimo               DECIMAL(14,2);
    DEFINE vFactorPagoMinLinC       DECIMAL (4,4);
    DEFINE wmeses_fin               INTEGER;
    DEFINE wbandera                 SMALLINT;
    DEFINE MontoFinanciado          DECIMAL(14,2);
    DEFINE wfinincimainto           DECIMAL(14,2);
    DEFINE wdias                    SMALLINT;
    DEFINE vFactorPorcentual        DECIMAL(18,2);
        DEFINE interes_iva                              DECIMAL(18,2);

        -- ****************************************************************************
        -- *                        ASIGNACION DE VARIABLES                           *
        -- ****************************************************************************

    --SET DEBUG FILE TO "/home/c90035619/RQM_10_1674/Homologados_R_R_L_A_V/PLD/calcula_meses_fin.out";
    --TRACE ON;

        LET scod_ret                = "00000";
        LET p_cod_ret               = "000000";
        LET vsqlerr                 = 0;
        LET wfecha_hoy             = DATE(1);
    LET vFactorPagoMin           = 0;
    LET TopeMinimo               = 0;
    LET vFactorPagoMinLinC       = 0;
    LET wmeses_fin               = 0;
    LET wbandera                 = 0;
    LET MontoFinanciado          = 0;
    LET wfinincimainto           = 0;
    LET wdias                    = 0;
    LET vFactorPorcentual        = 0;
        LET interes_iva                          = 0;

        -- ****************************************************************************
        -- *                        CONTROL DE ERRORES                                *
        -- ****************************************************************************

        BEGIN
                ON EXCEPTION SET vsqlerr
                   IF vsqlerr != 0 THEN
                          LET scod_ret=vsqlerr;
                          RETURN scod_ret, 0, 0;
                   END IF;
                END EXCEPTION;

        -- ****************************************************************************
        -- *                        PROGRAMA PRINCIPAL                                *
        -- ****************************************************************************

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

        IF (o_saldo_no_exigible <= 0) THEN
            RETURN scod_ret, 0, 0;
        END IF;

        SELECT factor_pago_min::SMALLINT, mto_pago_min::DECIMAL, fact_pag_min_lc
          INTO vFactorPagoMin, TopeMinimo, vFactorPagoMinLinC
          FROM bdicred:sd_definicion
         WHERE empresa = o_empresa
           and num_producto = o_producto;

        IF ( o_saldo_no_exigible <= TopeMinimo * o_factor) THEN
            RETURN scod_ret, 1, 0;
        END IF;

                --LET MontoFinanciado = ROUND((o_saldo_no_exigible * vFactorPorcentual), -0);
                LET MontoFinanciado = o_monto_financiado;

                --- REALIZA LA OPERACION: PAGO MINIMO * MESES
                LET MontoFinanciado = MontoFinanciado * o_factor;

                IF ( o_saldo_no_exigible <= MontoFinanciado) THEN
            RETURN scod_ret, 1, 0;
        END IF;

        WHILE wbandera = 0
            LET wmeses_fin = wmeses_fin + 1;

            IF ( MontoFinanciado < 0 ) THEN
                LET MontoFinanciado = 0;
            ELIF ( o_saldo_no_exigible < TopeMinimo ) THEN
                IF ( o_saldo_no_exigible ) <= 0 THEN
                    LET MontoFinanciado = 0;
                ELSE
                    LET MontoFinanciado = o_saldo_no_exigible;
                END IF;
            ELIF ( MontoFinanciado < TopeMinimo ) THEN
                LET MontoFinanciado = TopeMinimo;
            END IF

            IF ( o_saldo_no_exigible <= MontoFinanciado ) THEN
                LET MontoFinanciado = o_saldo_no_exigible;
                IF MontoFinanciado < 0 THEN
                    LET MontoFinanciado = 0;
                END IF;
            END IF;

            IF ( Round(MontoFinanciado,-1) - MontoFinanciado < 0 ) THEN
                LET MontoFinanciado = Round(MontoFinanciado,-1) + 10;
            ELSE
                LET MontoFinanciado = Round(MontoFinanciado,-1);
            END IF;


            IF ( MontoFinanciado > o_saldo_no_exigible ) THEN
                LET MontoFinanciado = o_saldo_no_exigible;
            END IF;

                        IF wmeses_fin < 299 THEN

                                LET wmeses_fin = wmeses_fin;

                                LET wdias = monthadd(o_fecha_calculo,wmeses_fin) - monthadd(o_fecha_calculo,wmeses_fin - 1);

                                -- Calcula financiamiento
                                LET wfinincimainto = ((o_saldo_no_exigible * o_tasa / 360 * wdias) * (1 + o_iva));

                                LET o_saldo_no_exigible = o_saldo_no_exigible - MontoFinanciado + wfinincimainto;
                                LET interes_iva = interes_iva + (o_saldo_no_exigible * o_tasa / 360 * wdias);

                                IF ( o_saldo_no_exigible <= MontoFinanciado ) THEN
                                        LET wmeses_fin = wmeses_fin + 1;
                                        LET wbandera = 1;
                                END IF;
                        END IF;

                        IF wmeses_fin = 299 THEN
                                        LET wmeses_fin = 299;
                                        LET wdias = monthadd(o_fecha_calculo,wmeses_fin) - monthadd(o_fecha_calculo,wmeses_fin - 1);

                                        --LET wfinincimainto = ((o_saldo_no_exigible * o_tasa / 360 * wdias) * (1 + o_iva));
                                        LET wfinincimainto = ((o_saldo_no_exigible * o_tasa / 360 * wdias) * (1 + o_iva)); --(wmeses_fin * o_monto_financiado);
                                        LET interes_iva = interes_iva + (o_saldo_no_exigible * o_tasa / 360 * wdias);
                                        EXIT WHILE;
                        END IF;

        END WHILE;


        RETURN scod_ret, wmeses_fin, interes_iva;
    END;
END PROCEDURE;