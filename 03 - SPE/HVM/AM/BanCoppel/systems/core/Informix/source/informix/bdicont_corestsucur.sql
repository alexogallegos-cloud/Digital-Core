CREATE PROCEDURE "informix".corestsucur(p_empresa   CHAR(3),
                                        p_sucursal  CHAR(4))

    RETURNING CHAR(5),CHAR (40);

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(40);
    DEFINE cod_ret          CHAR(5);
    DEFINE tmensaje         CHAR(40);
    DEFINE v_ccmayor        CHAR(10);
    DEFINE v_ccsub          CHAR(10);
    DEFINE v_ccsubsub       CHAR(10);
    DEFINE v_ccssubsub      CHAR(10);
    DEFINE v_ccsssubsub     CHAR(10);
    DEFINE v_sector         CHAR(10);
    DEFINE v_registros      INTEGER;

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cod_ret = sql_err;
        LET tmensaje = error_info;
        SET DEBUG FILE TO "corestsucur.err";
        TRACE sql_err||" * "||isam_err|| " * "||error_info;
        RETURN cod_ret,tmensaje;
    END EXCEPTION;

    --**************************************************
    -- Creado por Fabiola Corrales Tapia 12/Jun/2007 --*
    -- Debug del Procedure                           --*
    --SET DEBUG FILE TO "/tmp/corestsucur.out";      --*
    --TRACE ON;                                      --*
    --**************************************************

    LET cod_ret                   = "000";
    LET tmensaje                  = "PROCESO FINALIZADO CON EXITO";
    LET v_ccmayor                 = "";
    LET v_ccsub                   = "";
    LET v_ccsubsub                = "";
    LET v_ccssubsub               = "";
    LET v_ccsssubsub              = "";
    LET v_sector                  = "";

    FOREACH WITH HOLD
        SELECT DISTINCT
        a.ccmayor,
        a.ccsub,
        a.ccsubsub,
        a.ccssubsub,
        a.ccsssubsub,
        a.sector
        INTO
        v_ccmayor,
        v_ccsub,
        v_ccsubsub,
        v_ccssubsub,
        v_ccsssubsub,
        v_sector
        FROM bdicont:co_cta_ccorig a, bdinteg:si_sucursales b
        WHERE a.empresa = p_empresa AND a.sucursal = b.sucursal AND b.tpo_sucursal = 'S'

        LET v_registros = 0;
        SELECT COUNT(*)
        INTO v_registros
        FROM bdicont:co_cta_ccorig
        WHERE
        ccmayor = v_ccmayor AND
        ccsub = v_ccsub AND
        ccsubsub = v_ccsubsub AND
        ccssubsub = v_ccssubsub AND
        ccsssubsub = v_ccsssubsub AND
        sector = v_sector AND
        sucursal = p_sucursal;

        IF v_registros = 0 THEN
            INSERT INTO bdicont:co_cta_ccorig
            (empresa,
            ccmayor,
            ccsub,
            ccsubsub,
            ccssubsub,
            ccsssubsub,
            sector,
            sucursal)
            VALUES
            (p_empresa,
            v_ccmayor,
            v_ccsub,
            v_ccsubsub,
            v_ccssubsub,
            v_ccsssubsub,
            v_sector,
            p_sucursal);
        ELSE
            LET cod_ret = "000";
            LET tmensaje = "LA SUCURSAL YA ESTA RESTRINGIDA";
        END IF;

    END FOREACH;

    FOREACH WITH HOLD
        SELECT DISTINCT
        a.ccmayor,
        a.ccsub,
        a.ccsubsub,
        a.ccssubsub,
        a.ccsssubsub,
        a.sector
        INTO
        v_ccmayor,
        v_ccsub,
        v_ccsubsub,
        v_ccssubsub,
        v_ccsssubsub,
        v_sector
        FROM bdicont:co_cta_ccdest a, bdinteg:si_sucursales b
        WHERE a.empresa = p_empresa AND a.sucursal = b.sucursal AND b.tpo_sucursal = 'S'

        LET v_registros = 0;
        SELECT COUNT(*)
        INTO v_registros
        FROM bdicont:co_cta_ccdest
        WHERE
        ccmayor = v_ccmayor AND
        ccsub = v_ccsub AND
        ccsubsub = v_ccsubsub AND
        ccssubsub = v_ccssubsub AND
        ccsssubsub = v_ccsssubsub AND
        sector = v_sector AND
        sucursal = p_sucursal;

        IF v_registros = 0 THEN
            INSERT INTO bdicont:co_cta_ccdest
            (empresa,
            ccmayor,
            ccsub,
            ccsubsub,
            ccssubsub,
            ccsssubsub,
            sector,
            sucursal)
            VALUES
            (p_empresa,
            v_ccmayor,
            v_ccsub,
            v_ccsubsub,
            v_ccssubsub,
            v_ccsssubsub,
            v_sector,
            p_sucursal);
        ELSE
            LET cod_ret = "000";
            LET tmensaje = "LA SUCURSAL YA ESTA RESTRINGIDA";
        END IF;

    END FOREACH;



RETURN cod_ret, tmensaje;

END PROCEDURE;