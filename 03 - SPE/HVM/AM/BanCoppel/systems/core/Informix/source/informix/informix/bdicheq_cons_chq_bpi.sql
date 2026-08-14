CREATE PROCEDURE "informix".cons_chq_bpi(pempresa CHAR(3),
                                         pnum_cte CHAR(20),
                                         pmoneda CHAR(2),
                                         pRegistro SMALLINT )
RETURNING CHAR(5), CHAR(20), CHAR(20);

    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    DEFINE cod_ret       CHAR(5);
    DEFINE v_cuenta      CHAR(20);
    DEFINE v_numtarjeta  CHAR(20);
    DEFINE v_producto    CHAR(4);
    DEFINE sql_err       INTEGER;
    DEFINE vRegistros    INTEGER;
    DEFINE  iCont        INTEGER;

    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    LET cod_ret       = "000";
    LET v_cuenta      = " ";
    LET v_numtarjeta  = " ";
    LET v_producto    = " ";
    LET iCont    = 0;
    LET vRegistros    = 0;

    --set debug file to "cons_chq_bpi.out";
    --trace on;

    BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, v_cuenta, v_numtarjeta;
        END IF
    END EXCEPTION;

    IF ( pempresa = '' OR pempresa IS NULL OR pnum_cte = '' OR pnum_cte IS NULL OR pmoneda = '' OR pmoneda IS NULL OR pRegistro = '' OR pRegistro IS NULL ) THEN
        LET cod_ret = 100; --Parametros no validos.
        RETURN cod_ret, v_cuenta, v_numtarjeta;
    END IF

    SET ISOLATION DIRTY READ;

    FOREACH
        SELECT {index+(bdicheq:sc_maechq maecheques)} SKIP pRegistro FIRST 10 cuenta,'0000000000000000'
          INTO v_cuenta, v_numtarjeta
          FROM bdicheq:sc_maechq
         WHERE num_cte = pnum_cte 
           AND status_cta NOT IN('2','6','7')
         ORDER BY cuenta

        LET iCont = iCont + 1;
        
        RETURN cod_ret, v_cuenta, v_numtarjeta WITH RESUME;
    END FOREACH;

    IF ( iCont = 0 AND pRegistro = 0 ) THEN
        LET cod_ret = 101; -- Cliente No tiene cuentas
        RETURN cod_ret, v_cuenta, v_numtarjeta;
    END IF
    
    END
    
END PROCEDURE;