CREATE PROCEDURE "informix".firmantes_web(pempresa char(3),pcuenta char(20),psecuencia smallint,pnumcte char(20),papellidos char(30),
pnombre char(30),preg_firma char(1),ptipo_firma char(1),pcombinacion char(120),pparentesco char(2))

returning char(5);

define cod_ret     char(5);
define longitud    smallint;
define vnum_cte    char(20);
define vtipocte    char(1);
define sql_err,
       isam_err    integer;

define v_long_cta  CHAR(2);

let vtipocte ="";
begin

   on exception set sql_err, isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;
   
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   let cod_ret="00000";

   if pcuenta is null or
      psecuencia is null or
        pnumcte is null or
      pparentesco is null  then
        let cod_ret="00110";
        return cod_ret;
   end if

   if psecuencia = 1 then
      delete from sc_firmantes
      where empresa = pempresa and cuenta = pcuenta ;
   end if;

   select num_cte into vnum_cte
   from sc_maechq where cuenta = pcuenta;

   if not vnum_cte is null then
      select tipo_cliente into vtipocte
      from   bdinteg:si_cliente
      where  numcte = vnum_cte;
   end if

   insert into sc_firmantes (empresa,cuenta,secuencia,numcte,apellidos,nombre,reg_firma,tipo_firma,combinacion,parentesco)
                     values (pempresa,pcuenta,psecuencia,pnumcte,papellidos,pnombre,preg_firma,ptipo_firma,pcombinacion,pparentesco);

--   IF Trim(pparentesco) <> "" THEN
      insert into bdinteg:si_cterelacionado
          (empresa,numcte,sistema,cuenta,
          tipo_relacion,parentesco,
          tipo_cliente_ori,user_insert,
          fecha_insert)
      values (pempresa,pnumcte,"SC",pcuenta,
          "02",pparentesco,vtipocte,USER,
           current);
--   END IF;
   
   --Actualiza el Maenoc por las Firmas Registradas
   UPDATE sc_maenoc SET reg_firmas = psecuencia
   WHERE  cuenta = pcuenta;

   return cod_ret;
end;
end procedure;