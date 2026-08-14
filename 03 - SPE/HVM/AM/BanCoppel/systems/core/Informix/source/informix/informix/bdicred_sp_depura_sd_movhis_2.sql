CREATE PROCEDURE "informix".sp_depura_sd_movhis_2()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE fFecha       DATE;
DEFINE vFechaD		DATE; --Mejora

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET fFecha       = date(1);
LET vFechaD      = date(1); --Mejora

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
     where proceso = 5;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(5,'');
    END IF;

    select fecha_insert
      into fFecha
    from bdicred:sd_param
    where empresa = '001'
    and cod_param = '800'; 

   /* FOREACH WITH HOLD

       SELECT TRIM(num_credito)
           INTO vNumCred 
           FROM bdicred:"informix".sd_maecred
          WHERE num_credito > vNumCredAux
       ORDER BY num_credito ASC */

        	FOREACH WITH HOLD
			
				select num_credito, fecha_mov into vNumCred, vFechaD
				from bdicred:"informix".sd_movhis
				where empresa = '001'
				and fecha_mov < fFecha
				ORDER BY fecha_mov ASC
				
				BEGIN WORK;
				
				insert into bdicred:sd_movhis_new_2021
				select * from bdicred:sd_movhis
				where empresa = '001'
				and fecha_mov = vFechaD
				and num_credito = vNumCred;
				
				DELETE FROM "informix".sd_movhis
				where empresa = '001'
				and fecha_mov = vFechaD
				and num_credito = vNumCred;
				
				COMMIT WORK;  
				
			END FOREACH;

     /*       UPDATE "informix".sd_param_movhis_dep
               SET num_credito = vNumCred
             where proceso = 5;

    END FOREACH;*/

    RETURN cCodRet;

    END
END PROCEDURE;