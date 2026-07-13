CREATE PROCEDURE "informix".sp_depura_si_refclientes()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE vNumCte      VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE fFecha       DATE;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET vNumCte      = '';
LET fFecha       = date(1);

-- SET ISOLATION TO COMMITTED READ LAST COMMITTED;

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
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     where proceso = 11;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(11,'');
    END IF;

	select empresa, num_solicitud, numcte
	 from bdisolic:ss_solicitudes 
	where status_solicitud in ('CN','RT') 
	  AND fecha_insert <= mdy('12','31','2018')
	  AND num_solicitud > vNumCredAux 
	  into temp paso1 with no log;
	  
	create unique index inx_paso1 on paso1(num_solicitud, numcte);
	update statistics medium for table paso1;


    FOREACH WITH HOLD
       SELECT a.num_solicitud, a.numcte
	       INTO vNumCred, vNumCte
           FROM paso1 a,
                bdinteg:si_refclientes b
          WHERE a.empresa = b.empresa
            and a.numcte = b.numcte
            and a.num_solicitud = b.num_solicitud
		  group by 1,2
		  order by 1

        BEGIN WORK;

            insert into bdinteg:si_refclientes_0819
            select * from bdinteg:si_refclientes
            where empresa = '001'
            and num_solicitud = vNumCred
            and numcte = vNumCte;

            delete from bdinteg:si_refclientes
            where empresa = '001'
            and num_solicitud = vNumCred
            and numcte = vNumCte;

            UPDATE "informix".sd_param_movhis_dep
               SET num_credito = vNumCred
             where proceso = 11;

        COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;