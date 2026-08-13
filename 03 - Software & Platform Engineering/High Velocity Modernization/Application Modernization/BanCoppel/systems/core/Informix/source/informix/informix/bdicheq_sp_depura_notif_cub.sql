CREATE PROCEDURE "informix".sp_depura_notif_cub(v_fecha_insert datetime year to fraction(3),v_fecha_insert2 datetime year to fraction(3))
--CREATE PROCEDURE "informix".sp_depura_notif_cub()
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

    DEFINE v_sucursal varchar(4);
    DEFINE v_numcte varchar(20);
    DEFINE v_cuenta varchar(20);
    DEFINE v_num_tarjeta varchar(16);
    DEFINE v_folio_suc varchar(16) ;
    --DEFINE v_fecha_insert2 datetime year to fraction(3) ;

---------------------------
--Inicializando variables--
---------------------------
        --SET DEBUG FILE TO "/triad/mbucio/traceSalida.out"; --Se genera log en un archivo .out
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
                LET v_sucursal = '';
                LET v_numcte = '';
                LET v_cuenta = '';
                LET v_num_tarjeta = '';
                LET v_folio_suc = '';
        --LET v_fecha_insert2 = v_fecha_insert;


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


---sucursal,numcte,cuenta,num_tarjeta,folio_suc,

                        FOREACH WITH HOLD

                        SELECT sucursal,numcte,cuenta,num_tarjeta,folio_suc INTO v_sucursal,v_numcte,v_cuenta,v_num_tarjeta,v_folio_suc
            FROM "informix".pivote_notif_cub where numero =0 and fecha_insert between v_fecha_insert and v_fecha_insert2

                        IF vcontador1 = -1 THEN
                                LET vcontador1 = 0;
                                BEGIN WORK;
                        END IF;

            DELETE FROM "informix".sc_notif_cub_vent
            --WHERE sucursal= v_sucursal AND
            --      numcte = v_numcte AND
            --      cuenta = v_cuenta AND
            --      num_tarjeta = v_num_tarjeta AND
            --      folio_suc = v_folio_suc AND
            --     fecha_insert = v_fecha_insert;
            WHERE  fecha_insert between v_fecha_insert and v_fecha_insert2;

            UPDATE "informix".pivote_notif_cub set numero =1
            where sucursal= v_sucursal AND
                   numcte = v_numcte AND
                   cuenta = v_cuenta AND
                   num_tarjeta = v_num_tarjeta AND
                   folio_suc = v_folio_suc AND
                   fecha_insert between v_fecha_insert and v_fecha_insert2;

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