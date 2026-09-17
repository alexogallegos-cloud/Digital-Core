create procedure "informix".conffal(pempresa char(3),
                                    pcuenta char(20),
                                    pconf char(1))
   returning char(5);

   define cod_ret char(5);
   define sql_err integer;
   let cod_ret      = "000";

begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if
   end exception;

    if pcuenta is null
      or pconf is null then
        let cod_ret = "100";
        return cod_ret;
    end if

    if pconf = "S" then
       update sc_movdia
          set edo_cta="I"
          where empresa = pempresa and cuenta = pcuenta and edo_cta <> "I";
       update sc_movfal
          set status_imp="I"
          where empresa = pempresa and cuenta = pcuenta and status_imp <> "I";
   end if
   return cod_ret;
end
end procedure;