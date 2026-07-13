CREATE PROCEDURE "informix".sp_depura_movimientohistorico()
RETURNING CHAR(5),INTEGER;
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
    DEFINE vcodret1         CHAR(5);
    DEFINE error_info           CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vRegistros               INTEGER;
    DEFINE vId                              INTEGER;
    DEFINE vfecha_oper      DATE;
    DEFINE vsecuencia varchar(7) ;
    DEFINE vnumtarjeta varchar(16);
    DEFINE vfechalocaltransaccion varchar(4);
    DEFINE vhoralocaltransaccion varchar(6);

---------------------------
--Inicializando variables--
---------------------------
        --SET DEBUG FILE TO "/informix/ireb/bdibpi/spl/sp_depura_si_bitsmstelsms_bpi.out"; --Se genera log en un archivo .out
        --TRACE ON;

                LET vcodret1        = '00000';
                LET sql_err             = 0;
                LET isam_err        = 0;
                LET vcontador1      = -1;
                LET vcontador2      = 0;
                LET vRegistros      = 0;
                LET vId                         = 0;
                LET vsecuencia      ='';
                LET vnumtarjeta     ='';
                LET vfechalocaltransaccion ='';
                LET vhoralocaltransaccion  ='';


        /*Incia SP*/
BEGIN

                ON EXCEPTION SET sql_err, isam_err
                        IF sql_err <> 0 THEN
                                LET vcodret1 = sql_err;
                                LET vcontador1 = isam_err;
                                RETURN vcodret1, vcontador1;
                        END IF;
                END EXCEPTION;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 4;


                        FOREACH WITH HOLD

                        SELECT secuencia,numtarjeta,fechalocaltransaccion,horalocaltransaccion INTO vsecuencia,vnumtarjeta,vfechalocaltransaccion,vhoralocaltransaccion
            FROM "informix".pivote19  where numero =0

                        IF vcontador1 = -1 THEN
                                LET vcontador1 = 0;
                                BEGIN WORK;
                        END IF;

                        DELETE FROM "informix".movimientohistorico
            WHERE secuencia= vsecuencia AND
                  numtarjeta = vnumtarjeta AND
                  fechalocaltransaccion = vfechalocaltransaccion AND
                  horalocaltransaccion = vhoralocaltransaccion AND
                  fechahorainauth between  '2020-01-01 00:00:00.00000' and '2020-06-30 23:59:59.99999';



            UPDATE "informix".pivote19 set numero =1 where secuencia= vsecuencia AND
                                                           numtarjeta = vnumtarjeta AND
                                                           fechalocaltransaccion = vfechalocaltransaccion AND
                                                           horalocaltransaccion = vhoralocaltransaccion;

                        LET vcontador1 = vcontador1 + 1;
                        LET vcontador2 = vcontador2 + 1;

                         IF vcontador2 >= 1000 THEN
                                LET vcontador2 = 0;
                                COMMIT WORK;
                                BEGIN WORK;
                         END IF;

                        COMMIT WORK;
                        BEGIN WORK;

                        END FOREACH;
                        IF vcontador1 > -1 THEN
                                COMMIT WORK;
                        END IF;

                RETURN vcodret1, vcontador1;
        END;
END PROCEDURE;