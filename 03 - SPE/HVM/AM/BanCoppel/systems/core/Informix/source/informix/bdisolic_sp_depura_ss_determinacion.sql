CREATE PROCEDURE "informix".sp_depura_ss_determinacion()
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
    DEFINE vsecuencia char(20) ;
    DEFINE vnumtarjeta varchar(16);
    DEFINE vfechalocaltransaccion varchar(4);
    DEFINE vhoralocaltransaccion varchar(6);

---------------------------
--Inicializando variables--
---------------------------
        --SET DEBUG FILE TO "/tmp/ura_si_bitsmstelsms_bpi.out"; --Se genera log en un archivo .out
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

           SELECT num_solicitud INTO vsecuencia
           FROM "informix".pivote17y18 where numero=0

           IF vcontador1 = -1 THEN
                LET vcontador1 = 0;
                BEGIN WORK;
           END IF;

           DELETE FROM "informix".ss_revision_determinacion
           WHERE num_solicitud= vsecuencia and empresa='001';

           UPDATE "informix".pivote17y18 set numero =1 where num_solicitud= vsecuencia;

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