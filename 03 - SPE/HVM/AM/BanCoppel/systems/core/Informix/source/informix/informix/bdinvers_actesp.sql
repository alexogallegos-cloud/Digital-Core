create procedure "informix".actesp()
       returning char(5);

define vcodret char(5);
define vcuenta char(20);
define vmonto money(14,2);
define vintdia money(14,2);
define vtransacc char(4);
define vnumcte char(9);
define vnumsolbco smallint;
define vctachq char(20);
define vfecha_alta date;

let vcodret = "000";

foreach
   select a.cuenta,capital*tasa/365/100,fecha_alta
      into vcuenta,vintdia,vfecha_alta
      from sv_maeinv a, sv_maeinstrucc b
      where a.cuenta = b.cuenta and fec_ult_mov < "/11/15/2004"
            and cap_int = "I"
            and status_cta in(1,3)
   if vintdia is null then
      let vintdia = 0;
   end if
   if vfecha_alta < "11/01/2004" then
      let vintdia = vintdia * 2;
   end if
   update sv_maeinstrucc
      set importe = importe + vintdia
      where cuenta = vcuenta and cap_int = "I";
end foreach
return vcodret;
end procedure;