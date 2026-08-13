CREATE PROCEDURE "informix".sp_depura_sd_movhis_4(pNumCredIni char(20), pNumCredFin char(20))
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO '/INFORMIXDUMP/sp_depura_sd_movhis2.out';
--    TRACE ON;

    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     where proceso = 5;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       --INSERT INTO "informix".sd_param_movhis_dep VALUES(5,'');
    END IF;

    FOREACH WITH HOLD

       SELECT TRIM(num_credito)
           INTO vNumCred 
           FROM bdicred:"informix".sd_maecred
          WHERE empresa     = '001' 
            AND num_credito > 	pNumCredIni and num_credito <= pNumCredFin	
			and fecha_apertura <  mdy('01','01','2013')
       ORDER BY num_credito ASC

        BEGIN WORK;

            insert into bdicred:sd_movhis_new
            select * from bdicred:sd_movhis
            where empresa = '001'
            and fecha_mov < mdy('01','01','2013')
            and num_credito = vNumCred;
            --and referencia is null;

            DELETE FROM "informix".sd_movhis
            where empresa = '001'
            and fecha_mov < mdy('01','01','2013')
            and num_credito = vNumCred;
            --and referencia is null;

            --UPDATE "informix".sd_param_movhis_dep
              -- SET num_credito = vNumCred
             --where proceso = 5;

        COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;