create procedure "informix".actinvmac()
       returning char(5);

define vcodret char(5);
define vcuenta char(20);
define vinteres money(14,2);
define vimporte money(14,2);

let vcodret = "000";

foreach
   select a.cuenta,intereses,importe
      into vcuenta,vinteres,vimporte
      from sv_maeinv a, sv_maeinstrucc b
      where status_cta <> "4" and a.cuenta = b.cuenta and
            cap_int = "I"
   if vimporte > vinteres then
      update sv_maeinstrucc
         set importe = vimporte - vinteres
         where cuenta = vcuenta and cap_int = "I";
   end if
end foreach
return vcodret;
end procedure
;