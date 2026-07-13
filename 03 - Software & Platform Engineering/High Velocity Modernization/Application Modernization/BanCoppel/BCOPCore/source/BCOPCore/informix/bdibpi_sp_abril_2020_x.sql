CREATE PROCEDURE "informix".sp_abril_2020_x()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE cNumCliente  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE vfecha_registro datetime year to second; 

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET cNumCliente  = '';
LET vfecha_registro  = '2020-04-28 10:47:01';

SET ISOLATION to dirty read;
set lock mode to wait 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO '/INFORMIXDUMP/sp_depura_sd_movhis2.out';
--    TRACE ON;

--    SELECT num_cliente
--      INTO cNumCliente
--      FROM "informix".bpi_registros_mib;
--- bpi_registro_bex_abril2020_2 where servicio = 'activo' and fecha_registro >= '2020-04-28 04:30:30' and estatus_servicio =1 ;

    FOREACH WITH HOLD
        select a.num_cliente
              INTO cNumCliente
        from bdibpi:bpi_registros_mib a

        BEGIN WORK;

           select fecha_registro into vfecha_registro from bpi_registro_bex where num_cliente = cNumCliente
                                                                              and servicio = 'activo'
                                                                              and estatus_servicio=1;

          IF vfecha_registro < '' THEN
            insert into bpi_registro_bex_mib2
            select num_cliente from bpi_registro_bex_abril2020_2
            where servicio = 'activo'
            and estatus_servicio =1
            and num_cliente = cNumCliente;
           END IF;


        COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;