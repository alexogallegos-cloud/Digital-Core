CREATE PROCEDURE "informix".sp_depura_maehis_bd(paniomes char(6))
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6);
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  char(20);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE fFecha       DATE;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET fFecha       = date(1);

set isolation to dirty read;
set lock mode to wait 10;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/tmp/sp_depura_sd_movhis2.out';
    --TRACE ON;

    --SELECT cuenta
    --  INTO vNumCredAux
    --  FROM bdicheq:"informix".sc_maehis_dep;
      --where proceso != 8;

    FOREACH WITH HOLD

       SELECT cuenta
          INTO vNumCred
          FROM bdicheq:"informix".sc_maehis_factelect_new
          WHERE aniomes =paniomes
     --     and cuenta = vNumCredAux

        BEGIN WORK;

            DELETE FROM bdicheq:sc_maehis_factelect_new
            where aniomes =paniomes
            and cuenta = vNumCred;

            --UPDATE bdicheq:"informix".sc_maehis_dep
            --   set proceso = 8
            --   where cuenta = vNumCred;

        COMMIT WORK;

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE
;