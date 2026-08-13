create procedure "informix".ins_propios_det(
                       pempresa         char(3),
                       pcvebanco        char(3),
                       pnumcuenta       char(20),
                       pnumcheque       char(7),
                       pmonto           decimal(14,2),
                       pbandamag        char(40),
                       pcompensacion    char(3),
                       ptransaccion     char(2),
                       pcodseguridad    char(3),
                       pfechahoracap    char(25),
                       pdigverpre       char(1),
                       pdigverinter     char(1),
                       puser_insert     char(8),
                       pfecha_insert    char(10),
                       pfecha_orig      char(10),
                       pes_atrazado     char(1)
                       )
                       RETURNING char(5);

   DEFINE v_codret char(5);
   DEFINE v_fechapre char(10);
   DEFINE sql_err,isam_err int;



   -- v1    versión inicial

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";

--set debug file to "/tmp/ins_propio.out";
--trace on;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF      pempresa        is null or
            pcvebanco       is null or
            pnumcuenta      is null or
            pnumcheque      is null or
            pmonto          is null or
            pbandamag       is null or
            pcompensacion   is null or
            ptransaccion    is null or
            pcodseguridad   is null or
            pdigverpre      is null or
            pdigverinter    is null or
            puser_insert    is null or
            pfecha_insert   is null or
            pes_atrazado    is null THEN

       -- datos de entrada incompletos

       LET v_codret = 110;
       RETURN v_codret;
    END IF;


BEGIN

   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;



-- insertar registro en cce_cheques_det


    insert into cce_cheques_det (empresa,cvebanco,numcuenta,numcheque,
            fechapresenta,monto,bandamag,compensacion,transaccion,
            codseguridad,fechahoracap,digverpre,digverinter,presentado,
            usuario_alta,fecha_alta)
        values (pempresa,pcvebanco,pnumcuenta,pnumcheque,
            pfecha_insert,pmonto,pbandamag,pcompensacion,
            ptransaccion,pcodseguridad,current,
            pdigverpre,pdigverinter,"0",puser_insert,
            pfecha_insert);


END;

RETURN v_codret;

END PROCEDURE;