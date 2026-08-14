CREATE PROCEDURE "informix".sp_validadomicilio_sat()
RETURNING CHAR(6) AS cod_ret,
                  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES
DEFINE cod_ret                                  CHAR(6);
DEFINE vmensaje                                 CHAR(80);
DEFINE SQL_ERR                          INTEGER;
DEFINE ISAM_ERR                         INTEGER;
DEFINE ERROR_INFO                       CHAR(80);


DEFINE vejercicio               CHAR(4);
DEFINE vcliente                 CHAR(20);
DEFINE vcuenta                  CHAR(20);
DEFINE vconteo                          INTEGER;


LET vconteo = 0;
BEGIN

          ON EXCEPTION SET SQL_ERR
        IF SQL_ERR <> 0 THEN
            LET cod_ret=SQL_ERR;
            RETURN cod_ret,'ERROR EN EJECUCION';
        END IF;
    END EXCEPTION;

        --SET DEBUG FILE TO '/informix/jarias/sp_validadomicilio_sat.out';
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

        ---Borrado de la tabla de paso
        BEGIN;
                TRUNCATE TABLE "informix".sc_ctesindomicilio;
        COMMIT;


        FOREACH WITH HOLD

                SELECT cuenta, ejercicio, num_cte
        INTO  vcuenta, vejercicio, vcliente
        FROM bdicheq:sc_retenisr  where empresa = '001' and ejercicio= '2021'
                ORDER BY cuenta


                SELECT count(*)
                INTO vconteo
                FROM bdinteg:si_direcciones_actual
                WHERE numcte = vcliente;

                IF vconteo = 0 THEN
                        INSERT INTO "informix".sc_ctesindomicilio(cuenta,ejercicio,cliente)
                        VALUES(vcuenta, vejercicio, vcliente);
                END IF

        END FOREACH;

        LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO';

        RETURN cod_ret, vmensaje;

END;
END PROCEDURE;