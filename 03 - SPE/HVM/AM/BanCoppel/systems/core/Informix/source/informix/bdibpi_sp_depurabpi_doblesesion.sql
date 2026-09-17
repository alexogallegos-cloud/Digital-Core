CREATE PROCEDURE "informix".sp_depurabpi_doblesesion()
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
    DEFINE vid_registro integer ;
    DEFINE vfecha datetime year to second;
    DEFINE vfecha2 datetime year to second;
    DEFINE vnumcliente varchar(20) ;
    DEFINE vusuario varchar(20);
    DEFINE csql_err INTEGER;
    DEFINE cCadena                          CHAR (800);


---------------------------
--Inicializando variables--
---------------------------
        --SET DEBUG FILE TO "/RESPALDOSNEW/sp_depura_si_bitsmstelsms_bpi.out"; --Se genera log en un archivo .out
        --TRACE ON;

        LET vcodret1        = '00000';
        LET sql_err             = 0;
        LET isam_err        = 0;
        LET vcontador1      = -1;
        LET vcontador2      = 0;
        LET vRegistros      = 0;
        LET vId                         = 0;
        LET csql_err = "100";
        LET vsecuencia      ='';
        LET vnumtarjeta     ='';
        LET vfechalocaltransaccion ='';
        LET vhoralocaltransaccion  ='';
        LET vid_registro ='';
        LET vfecha ='';
        LET vfecha2 ='';
        LET cCadena       = '';

BEGIN

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 4;

        FOREACH WITH HOLD

         --SELECT id_registro, numcliente, usuario
         SELECT id_registro
          --INTO vid_registro, vnumcliente, vusuario
          INTO vid_registro
          from povite_doblesesion where status=0

                 IF vcontador1 = -1 THEN
                    LET vcontador1 = 0;
                    BEGIN WORK;
                 END IF;

            INSERT INTO bpi_doblesesion_historica
            select * from bpi_doblesesion
            where id_registro=vid_registro;
              --and numcliente= vnumcliente
              --and usuario = vusuario;
              --and fecha=vfecha;


            DELETE FROM "informix".bpi_doblesesion
            WHERE id_registro=vid_registro;
            --  and numcliente= vnumcliente
            --  and usuario = vusuario
            --  and fecha=vfecha;

            UPDATE "informix".povite_doblesesion set status =1
            where id_registro= vid_registro;
            --and numcliente= vnumcliente
            --and usuario = vusuario
            --and fecha=vfecha;

                        LET vcontador1 = vcontador1 + 1;
                        LET vcontador2 = vcontador2 + 1;

                         IF vcontador2 >= 2 THEN
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

        --DROP TABLE povite_doblesesion;

                RETURN vcodret1, vcontador1;
        END;
END PROCEDURE;