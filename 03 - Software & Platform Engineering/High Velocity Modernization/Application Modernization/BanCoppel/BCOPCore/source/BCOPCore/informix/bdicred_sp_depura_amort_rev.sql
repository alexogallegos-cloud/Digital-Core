CREATE PROCEDURE "informix".sp_depura_amort_rev()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vFechaAux    date;
DEFINE vFechaCuota  date;
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE vStatusCred  CHAR(02);
DEFINE vcantidad    INTEGER;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vFechaAux    = date(1);
LET vFechaCuota  = date(1);
LET vStatusCred  = '';
LET vcantidad    = 0;


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/INFORMIXDUMPNEW/sp_depura_sd_movhis2.out';
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT (num_credito)::date
      INTO vFechaAux
      FROM "informix".sd_param_movhis_dep
     WHERE proceso = 17;

    IF vFechaAux IS NULL THEN 
       LET vFechaAux = date(1); 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(17,vFechaAux);
    END IF;

    FOREACH WITH HOLD
       SELECT num_credito, fecha_cuota
         INTO vNumCred, vFechaCuota
         FROM bdicred:sd_amortiza_credito
        WHERE empresa = '001'
          AND fecha_cuota <= vFechaAux

            BEGIN WORK;
                insert into bdicred:sd_amortiza_credito_old
                select * from bdicred:sd_amortiza_credito
                where empresa = '001'
                and num_credito = vNumCred
                and fecha_cuota = vFechaCuota;

                DELETE FROM "informix".sd_amortiza_credito
                where empresa = '001'
                and num_credito = vNumCred
                and fecha_cuota = vFechaCuota;
            COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;