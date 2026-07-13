CREATE PROCEDURE "informix".sp_depura_sd_movhis_3()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE vStatusCred  CHAR(02);
DEFINE vcantidad    INTEGER;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET vStatusCred  = '';
LET vcantidad    = 0;


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO '/INFORMIXDUMP/sp_depura_sd_movhis2.out';
--    TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     WHERE proceso = 4;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(4,'');
    END IF;

    FOREACH WITH HOLD
       SELECT TRIM(num_credito)
         INTO vNumCred
         FROM bdicred:sd_maecred_vendida
        WHERE empresa = '001'
          AND fecha <  mdy('07','01','2013')
          AND num_credito > vNumCredAux
       ORDER BY num_credito ASC

       SELECT status_cred
         INTO vStatusCred
         FROM bdicred:sd_maecred
        WHERE empresa = '001'
          AND num_credito = vNumCred;

       LET vcantidad = 0;

       IF NVL(vStatusCred,"") = 'CV' THEN
           SELECT count(*)
             INTO vcantidad
             FROM bdicred:sd_movhis
            WHERE empresa = '001'
              AND num_credito = vNumCred;
       END IF;

       IF NVL(vStatusCred,"") = 'CV' and vcantidad > 0 THEN
            BEGIN WORK;
                insert into bdicred:sd_movhis_new
                select * from bdicred:sd_movhis
                where empresa = '001'
                and num_credito = vNumCred;

                DELETE FROM "informix".sd_movhis
                where empresa = '001'
                  and num_credito = vNumCred;

                UPDATE "informix".sd_param_movhis_dep
                   SET num_credito = vNumCred
                 where proceso = 4;

            COMMIT WORK;  
       ELSE
            BEGIN WORK;
                UPDATE "informix".sd_param_movhis_dep
                   SET num_credito = vNumCred
                 where proceso = 4;
            COMMIT WORK;  

       END IF;
            
    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;