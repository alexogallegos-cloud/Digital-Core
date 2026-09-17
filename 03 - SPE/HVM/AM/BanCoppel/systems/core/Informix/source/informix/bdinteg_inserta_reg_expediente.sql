CREATE PROCEDURE "informix".inserta_reg_expediente(
                       pempresa     char(3),
                       pcliente     char(20),
                       pcuenta      char(20),
                       pproducto    char(4),
                       pcod_docto   char(4),
                       psecuencia   smallint,
                       pprod_nombre char(40),
                       pdescrip2    char(30),
                       puser_insert char(8))
                       RETURNING    char(5);


   DEFINE sql_err,isam_err int;

   DEFINE v_tempo char(1);
   DEFINE v_codret char(5);
   DEFINE v_fecha date;
   DEFINE v_inst char(50);
   DEFINE v_inst2 char(50);


-- v1.1 validacion adicional para que no se dupliquen lalo oct09
-- v1   version inicial


-- Inicializa variables


   LET v_codret    = "000";
   LET v_fecha     = today;


--SET DEBUG FILE TO "/tmp/inserta_reg_expediente.out";
--TRACE ON;
BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;





-- Valida la informacion de entrada


    IF  pempresa        is null or
        pcliente        is null or
        pcuenta         is null or
        pproducto       is null or
        pcod_docto      is null or
        psecuencia      is null or
        pprod_nombre    is null or
        puser_insert    is null THEN

       -- datos de entrada incompletos

       LET v_codret = 110;
       RETURN v_codret;
    END IF;


   select trim(valor)||'dg_expediente' into v_inst from dg_params where cod_param=5;
   let v_inst2=trim(v_inst);
    -- validar duplicado
    select  "1"
    into    v_tempo
    from    v_inst2
    where   empresa     = pempresa
    and     cliente     = pcliente
    and     cuenta      = pcuenta
    and     producto    = pproducto
    and     cod_docto   = pcod_docto
    and     secuencia   = psecuencia;

    IF dbinfo("sqlca.sqlerrd2") <> 0 then
            -- ya existe, salir
            RETURN v_codret;
    END IF


    -- insertar registro en dg_expediente


    insert into v_inst2
                (empresa,cliente,cuenta,
                producto,cod_docto,secuencia,prod_nombre,descrip2,
                usuario_alta,fecha_alta)
    values      (pempresa,pcliente,pcuenta,pproducto,pcod_docto,
                psecuencia,pprod_nombre,pdescrip2,puser_insert,
                v_fecha);

END;

RETURN v_codret;

END PROCEDURE;