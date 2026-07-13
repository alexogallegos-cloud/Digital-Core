create procedure "informix".benef_2( pempresa char(3),
              pcuenta        char(20),
              nombre         char(40),
              parentesco     char(10),
              porcentaje     smallint,
              psecuencia     smallint) returning char(5);

define cod_ret     char(5);
define longitud    smallint;
define sql_err, 
       isam_err    integer;
define v_long_cta  CHAR(2);

 
begin
   on exception set sql_err, isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;
   let cod_ret="000";
   if pcuenta is null or
      psecuencia is null or
        nombre is null or
        porcentaje is null then
        let cod_ret="110";
        return cod_ret;
   end if

   if psecuencia = 1 then  
      delete from sc_beneficiario
      where empresa = pempresa and cuenta = pcuenta ;
   end if;

   insert into sc_beneficiario 
      values(pempresa,pcuenta, psecuencia, nombre, parentesco, porcentaje);
   return cod_ret;
end;
end procedure;