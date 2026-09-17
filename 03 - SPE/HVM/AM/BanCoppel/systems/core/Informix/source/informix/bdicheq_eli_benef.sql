create procedure "informix".eli_benef(pempresa char(3),
                                      pcuenta  char(20))

       returning char(5);
define cod_ret char(5);
define longitud, v_long_cta smallint;
define sql_err, isam_err integer;

begin
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
        let cod_ret = "999";
        return cod_ret;
      end if;
   end exception;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret = "000";


   begin
      delete from sc_beneficiario
      where empresa = pempresa and  cuenta = pcuenta;
   end
   return cod_ret;
end
end procedure;