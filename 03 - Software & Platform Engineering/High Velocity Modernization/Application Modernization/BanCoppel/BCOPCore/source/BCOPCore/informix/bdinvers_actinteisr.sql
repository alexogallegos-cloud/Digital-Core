create procedure "informix".actinteisr()
       returning char(5);

define vcodret char(5);
define vinteres, visr money(14,2);
define vcuenta char(20);
define vfecha_alta, vfecha_hoy date;
define vdias,vplazo smallint;

let vcodret = "000";
let vfecha_hoy = "11/24/2006";

foreach
   select cuenta,capital*tasa/100/360*plazo,capital*0.5/100/360*plazo,
      fecha_alta,plazo
      into vcuenta,vinteres,visr,vfecha_alta,vplazo
      from sv_maeinv
   update sv_maeinv
      set intereses = vinteres,
          isr = visr
      where cuenta = vcuenta;
   update sv_maeinstrucc
      set importe = vinteres
      where cuenta = vcuenta and fecha_venc < "11/24/2006" and
            cap_int = "I";
   let vdias = vfecha_hoy - vfecha_alta;
   update sv_maeinstrucc
      set importe = vinteres/vplazo*vdias
      where cuenta = vcuenta and fecha_venc >= "11/24/2006" and
            cap_int = "I";
end foreach
return vcodret;
end procedure
;