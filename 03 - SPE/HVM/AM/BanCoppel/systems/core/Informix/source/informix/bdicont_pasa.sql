CREATE PROCEDURE "informix".pasa()

define vempresa char(3);
define vcuenta_ext char(9);
define vexterna_10 char(10);
define vdesc_cta_ext char(40);
define vtipo_cta char(2);
define vgrupo   char(5);
define vccmayor,vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector char(10);
define vmoneda char(2);
define vciudad, vsucursal char(3);
define vmonedatxt char(3);
define vmonedatxt1 char(3);
define vsif char(10);
define vuso char(5);

foreach
  select empresa,cuenta_ext,desc_cuenta_ext,tipo_cta,grupo,
         ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, ciudad,
         sucursal, moneda
  into   vempresa, vcuenta_ext, vdesc_cta_ext, vtipo_cta, vgrupo,
         vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub,
         vsector, vciudad, vsucursal, vmoneda
  from co_mapeo_cuentas

  let vmonedatxt1 = " ";

  if vmoneda = "01" then
     let vmonedatxt1 = "MXN";
  else
     if vmoneda = "02" then
        let vmonedatxt1 = "USD";
     end if
  end if

  select unique externa_10, monedatxt, sif, uso
  into   vexterna_10, vmonedatxt, vsif, vuso
  from   co_mapbal
  where  empresa = vempresa
  and    externa = vcuenta_ext
  and    mayor   = vccmayor
  and    sub     = vccsub
  and    subs    = vccsubsub
  and    subss   = vccssubsub
  and    subsss  = vccsssubsub
  and    monedatxt = vmonedatxt1;

  if vcuenta_ext is null or vcuenta_ext = " " then
      let vexterna_10 = "no mapbal";
  end if
  insert into co_mapeo_nuevo
  values (vempresa, vcuenta_ext, vexterna_10, vdesc_cta_ext, vtipo_cta, vgrupo,
         vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub,
         vsector, vciudad, vsucursal, vmoneda, vmonedatxt, vsif, vuso);
end foreach;
end procedure;