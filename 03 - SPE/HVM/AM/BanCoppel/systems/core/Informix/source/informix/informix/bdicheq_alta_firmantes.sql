create procedure "informix".alta_firmantes(pempresa char(3),
                        pcuenta      char(20),
                        psecuencia   smallint,
                        pnombre      char(30),
                        papellidos   char(30),
                        ptipfirma    char(1),
                        pcombinacion char(50))
returning char(5);

define vcodret char(5);
define vnumcte char(20);
define vregfirma char(1);
define sql_err integer;

begin
   on exception set sql_err
      if sql_err <> 0 then
        let vcodret = sql_err;
        return vcodret;
      end if;
   end exception;

   let vcodret = "000";


   if pcuenta = "" or psecuencia = "" or psecuencia = 0 or
      papellidos = "" or papellidos = " " or pnombre = "" or pnombre = " " or
      ptipfirma = "" or ptipfirma = " " then
      let vcodret = "110";
      return vcodret;
   end if;

   select num_cte, reg_firmas into vnumcte, vregfirma
      from sc_maechq mc, sc_maenoc mn
      where mc.empresa = pempresa and mc.cuenta = pcuenta and 
            mc.empresa = mn.empresa and mc.cuenta = mn.cuenta;
   if vnumcte is null then
      let vcodret = "100";
      return vcodret;
   end if
 
   if psecuencia = 1 then
      delete from sc_firmantes
         where empresa = pempresa and cuenta = pcuenta;
   end if

   insert into sc_firmantes
      values(pempresa,pcuenta,psecuencia,vnumcte,papellidos,pnombre,vregfirma,
             ptipfirma, pcombinacion);
   return vcodret;
end
end procedure;