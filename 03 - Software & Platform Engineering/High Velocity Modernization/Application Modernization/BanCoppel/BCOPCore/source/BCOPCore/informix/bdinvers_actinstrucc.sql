create procedure "informix".actinstrucc()
       returning char(5);

   define vcodret char(5);
   define vsqlerr integer;
   define vcuenta char(20);
   define vcta_cheques char(20);
   define vcap_int,vexiste char(1);



   let vcodret  = "000";

   foreach
      select cuenta,cap_int into vcuenta,vcap_int
         from sv_maeinstrucc
         where inst_vento = "01"
      if vcuenta[1,1] = "1" then
         let vcta_cheques = vcuenta[1,9]||"300";
      else
         let vcta_cheques = vcuenta[1,9]||"301";
      end if
      select 1 into vexiste
         from bdicheq:sc_maechq
         where cuenta = vcta_cheques;
      if vexiste = "1" then
         update sv_maeinstrucc
            set sistema = "01",
                cta_cheques = vcta_cheques
            where cuenta = vcuenta and cap_int = vcap_int;
      else
         update sv_maeinstrucc
            set inst_vento = "03",
                sistema = "12",
                cta_cheques = " "
            where cuenta = vcuenta and cap_int = vcap_int;
      end if
   end foreach
return vcodret;
end procedure;