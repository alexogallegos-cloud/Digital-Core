create procedure "informix".valctaeje(pempresa char(3),
                                      pctarel char(20))
       returning char(5), char(20), char(1);

   define vcodret char(5);
   define vcuenta char(20);
   define vstatus char(1);

   let vcodret = "000";


   select cuenta, status_cta into vcuenta, vstatus
      from sc_maechq
      where empresa = pempresa and cuenta_rel = pctarel;
   if vcuenta is null then
      let vcodret = "100";
   end if;
   return vcodret, vcuenta, vstatus;
end procedure;