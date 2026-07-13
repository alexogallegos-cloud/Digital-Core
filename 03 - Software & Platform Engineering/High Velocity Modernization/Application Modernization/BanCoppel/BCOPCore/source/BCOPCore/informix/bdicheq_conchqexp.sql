create procedure "informix".conchqexp(pempresa char(3),
                                      pcuenta char(20))
       returning char(5),smallint;

define vcodret char(5);
define vchq_exp_mes smallint;


   let vcodret = "000";

   select chq_exp_mes into vchq_exp_mes
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta;
   return vcodret,vchq_exp_mes;
end procedure;