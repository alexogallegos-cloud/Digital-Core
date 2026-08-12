CREATE PROCEDURE "informix".sp_capintafecha_ipab_esp( pCuenta CHAR(20), pFecha DATE )
RETURNING  CHAR(10), DECIMAL(14,2), DECIMAL(14,2);

    DEFINE cCodret      CHAR(5);
    DEFINE cCodret2     CHAR(5);
    DEFINE cCodret3     CHAR(50);
    DEFINE cSQL_ERR     INTEGER;
    DEFINE cISAM_ERR    INTEGER;
    DEFINE cDESC_ERR    CHAR(50);
    DEFINE vCapital     DECIMAL(14,2);
    DEFINE vInteres     DECIMAL(14,2);

    LET cCodret   = '000';
    LET cCodret2  = '';
    LET cCodret3  = '';
    LET cSQL_ERR  = 0;
    LET cISAM_ERR = 0;
    LET cDESC_ERR = '';
    LET vCapital  = 0.00;
    LET vInteres  = 0.00;

    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_capintafecha_ipab_esp.out';
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET cSQL_ERR, cISAM_ERR, cDESC_ERR
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_capintafecha_ipab_esp.err';
        TRACE ON;
        LET cCodret = cSQL_ERR;
        LET cCodret2 = cISAM_ERR;
        LET cCodret3 = cDESC_ERR;
        RETURN cCodret, vCapital, vInteres;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT saldook, saldo_act_int
      INTO vCapital, vInteres
      FROM bdinteg:tab_ipab_pba_pums
     WHERE cuenta = pCuenta
       AND fecha = pFecha;
    
    IF vCapital is null OR vInteres is null THEN
        -- // CUENTA NO EXISTE EN FECHA
        LET cCodret = '100'; 
        LET vCapital = 0.00;
        LET vInteres = 0.00;
    END IF;

    RETURN cCodret, vCapital, vInteres;

    END;

END PROCEDURE;