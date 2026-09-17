CREATE PROCEDURE "informix".sp_abril_2020()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE cNumCliente  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE vfecha_registro datetime year to second; 
DEFINE vtransaccion         integer;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET cNumCliente  = '';
LET vfecha_registro  = '2020-04-28 10:47:01';
LET vtransaccion = 0;

SET ISOLATION to dirty read;
set lock mode to wait 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    ON EXCEPTION IN (-239)
        let vtransaccion = 1;
    END EXCEPTION WITH RESUME;


    SET DEBUG FILE TO '/tmp/bitacoraBex.out';
    TRACE ON;

--    SELECT num_cliente
--      INTO cNumCliente
--      FROM "informix".bpi_registros_mib;
--- bpi_registro_bex_abril2020_2 where servicio = 'activo' and fecha_registro >= '2020-04-28 04:30:30' and estatus_servicio =1 ;

    FOREACH WITH HOLD
        select a.num_cliente
              INTO cNumCliente
        from bdibpi:bpi_registros_mib a

        BEGIN WORK;

            --insert into bpi_registros_mib2
            --select num_cliente from bpi_registro_bex  
            --where servicio = 'activo' and fecha_registro >= '2020-04-28 10:47:00' 
            --and estatus_servicio =1
            --and num_cliente = cNumCliente;

            --insert into bpi_registros_mib3
            --select num_cliente from bpi_registro_bex
            --where servicio = 'activo' and fecha_registro <= '2020-04-28 10:46:59'
            --and estatus_servicio =1
            --and num_cliente = cNumCliente;

           select fecha_registro into vfecha_registro from bpi_registro_bex where num_cliente = cNumCliente
                                                                              and servicio = 'activo'
                                                                              and estatus_servicio=1;


            update bpi_registro_bex set estatus_servicio=2 where num_cliente = cNumCliente
                                                             and estatus_servicio =1 
                                                             --and servicio = 'activo' 
                                                             and fecha_registro <= '2020-04-28 04:30:30';

            update bpi_registro_bex set servicio ='inactivo' where num_cliente = cNumCliente
                                                             and estatus_servicio=2
                                                             and servicio = 'activo'
                                                             and fecha_registro <= '2020-04-28 04:30:30';

          IF vfecha_registro < '2020-04-28 10:47:00' THEN
            insert into bpi_registro_bex
            select * from bpi_registro_bex_abril2020_2
            where servicio = 'activo'
            and estatus_servicio =1
            and num_cliente = cNumCliente;
           END IF;


        COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;