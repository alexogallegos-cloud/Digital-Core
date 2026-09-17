CREATE PROCEDURE "informix".sp_depura_os()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumSOL     VARCHAR(20,1);
DEFINE vNumSOLAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumSOL     = '';
LET vNumSOLAux  = '';

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO 'sp_depura_sd_movhis2.out';
--    TRACE ON;

    SELECT num_credito
      INTO vNumSOLAux
      FROM bdicred:"informix".sd_param_movhis_dep
     where proceso = 7;

    IF vNumSOLAux IS NULL THEN 
       LET vNumSOLAux = ""; 
       INSERT INTO bdicred:"informix".sd_param_movhis_dep VALUES(7,'');
    END IF;


    FOREACH WITH HOLD

       SELECT TRIM(num_solicitud)
           INTO vNumSOL 
           FROM bdisolic:"informix".ss_solicitudes
          WHERE empresa = '001' 
            AND status_solicitud = 'CN'
            AND num_solicitud > vNumSOLAux
       ORDER BY num_solicitud ASC

        BEGIN WORK;

            insert into bdisolic:"informix".ss_solicitud_os_old
            select * from bdisolic:"informix".ss_solicitud_os
            where num_solicitud = vNumSOL;

            DELETE FROM bdisolic:"informix".ss_solicitud_os
            where num_solicitud = vNumSOL;

            insert into bdisolic:"informix".ss_osclientesupervisar_old
            select * from bdisolic:"informix".ss_osclientesupervisar
            where num_solicitud = vNumSOL;

            DELETE FROM bdisolic:"informix".ss_osclientesupervisar
            where num_solicitud = vNumSOL;

            UPDATE bdicred:"informix".sd_param_movhis_dep
               SET num_credito = vNumSOL
             where proceso = 7;

        COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;