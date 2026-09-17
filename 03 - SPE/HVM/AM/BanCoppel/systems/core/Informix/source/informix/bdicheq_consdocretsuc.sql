create procedure "informix".consdocretsuc(pempresa char(3),
                                          pplaza_comp char(03))
   returning char(5), char(4), integer, money(14,2);

   define vcodret     char(5);
   define vmonto      money(14,2);
   define vconta      integer;
   define vplaza      char(3);
   define vsucursal   char(4);
   define vsqlerr     integer;

   let vcodret = "000";
   let vmonto = 0;
   let vconta = 0;
   let vplaza = " ";
   let vsucursal = " ";

   begin
      on exception set vsqlerr
         if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret, vsucursal, vconta, vmonto;
         end if
      end exception;

   foreach
      select p.sucursal, count(*), sum(monto)
         into vsucursal, vconta, vmonto
         from sc_plazasuc p, outer sc_docret d
         where p.empresa = pempresa and p.plaza_comp = pplaza_comp and 
               d.empresa = p.empresa and cancelado <> "S" and 
               dias_ret <= 1 and d.sucursal = p.sucursal 
         group by 1
         order by 1
      if vmonto is null then
         let vmonto = 0;
         let vconta = 0;
      end if
      return vcodret, vsucursal, vconta, vmonto with resume;
   end foreach;
end
end procedure;