CREATE PROCEDURE "informix".sp_actualizaide_31052013( pcEmpresa  CHAR(3) )
RETURNING CHAR(5)  AS vcCodret1,
          CHAR(5)  AS vcCodret2,
          CHAR(50) AS vcCodret3,
          INTEGER  AS viContador1;
    
    DEFINE vcCodret1    CHAR(5);
    DEFINE vcCodret2    CHAR(5);
    DEFINE vcCodret3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE viContador1  INTEGER;
    DEFINE viContCommit INTEGER;
    DEFINE vComienza    SMALLINT;
    DEFINE viTransacc   SMALLINT;
    DEFINE vcCuenta     CHAR(20);
    DEFINE vdMonto      MONEY(16,2);
    DEFINE vcRefer      CHAR(20);
    
    LET vcCodret1    = '000';
    LET vcCodret2    = '000';
    LET vcCodret3    = 'PROCESO FINALIZADO CORRECTAMENTE';
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET viContador1  = 0;
    LET viContCommit = 0;
    LET vComienza    = -1;
    LET viTransacc   = 0;
    LET vcCuenta     = '';
    LET vdMonto      = 0.00;
    LET vcRefer      = '';
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualizaide_31052013.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodret1 = viSqlErr;
            LET vcCodret2 = viIsamErr;
            LET vcCodret3 = vcDescErr;
            IF viTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodret1, vcCodret2, vcCodret3, viContador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualizaide_31052013.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT det.cuenta_ret, det.imp_recaudado, det.ref_ret
          INTO vcCuenta, vdMonto, vcRefer
          FROM bdicheq:sc_movhis mov,
               bdilide:sl_detlide det
         WHERE mov.empresa = '001'
           AND mov.cuenta >= '10000000000'
           AND mov.fech_alt = '06/01/2013'
           AND mov.transacc = '3280'
           AND mov.cancelad <> 'S'
           ANd mov.folio_suc = 'inform0217213280'
           AND det.cuenta_ret = mov.cuenta
           AND det.fecha_ret = '05/31/2013'
           AND det.imp_recaudado = mov.monto_tot
        
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET viTransacc = 1;
        END IF;
         
        UPDATE bdilide:sl_detlide
           SET fecha_ret = '06/01/2013'
         WHERE cuenta_ret = vcCuenta
           AND fecha_ret = '05/31/2013'
           AND imp_recaudado = vdMonto
           AND ref_ret = vcRefer;
        
        LET viContador1 = viContador1 + 1;
        LET viContCommit = viContCommit + 1;
        
        IF viContCommit >= 1000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET viContCommit = 0;
        END IF;
        
        LET vcCuenta = '';
        LET vdMonto  = 0.00;
        LET vcRefer  = '';
    END FOREACH;
    
    IF viTransacc = 1 THEN
        LET viTransacc = 0;
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vcCodret1, vcCodret2, vcCodret3, viContador1;

END PROCEDURE;