CREATE PROCEDURE "informix".actualiza_ctasnoproc( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), INTEGER;
       
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE vcTrxAbierta SMALLINT;
    DEFINE viContador   INTEGER;
    DEFINE vdFechaHoy   DATE;
    DEFINE vcCuenta     CHAR(20);
    
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET vcCodRet     = '000';
    LET vcCodRet2    = '000';
    LET vcCodRet3    = '';
    LET vcTrxAbierta = 0;
    LET viContador   = 0;
    LET vdFechaHoy   = '';
    LET vcCuenta     = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/actualiza_ctasnoproc.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/actualiza_ctasnoproc.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF vcTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet, vcCodRet2, viContador;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcCuenta
          FROM sc_valcierre
         WHERE empresa = pEmpresa
           AND cuenta >= '10000000000'
           
        BEGIN WORK;
        LET vcTrxAbierta = 1;
           
        UPDATE sc_maechq
           SET fecha_proceso = vdFechaHoy,
               sdo_dia_ant = sdo_actual
         WHERE empresa = pEmpresa
           AND cuenta = vcCuenta;
           
        IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
            ROLLBACK WORK;
            LET vcTrxAbierta = 0;
        ELSE
            COMMIT WORK;
            LET vcTrxAbierta = 0;
        END IF;
           
        LET viContador = viContador + 1;
    END FOREACH;
    
    RETURN vcCodRet, vcCodRet2, viContador;
    
    END;
    
END PROCEDURE;