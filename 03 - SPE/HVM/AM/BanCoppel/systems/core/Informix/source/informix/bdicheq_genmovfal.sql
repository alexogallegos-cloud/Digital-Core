create procedure "informix".genmovfal(pempresa char(3))

define vsqlerr integer;
define vfechor datetime hour to fraction (3);
define vnumser integer;
define vfecalt date;
define vnumtra char(4);
define vcuenta char(20);
define vmonto  money(14,2);
define vedocta char(1);
define vsdocta money(14,2);
define vreferencia char(40);
define vfolio_suc char(16);

let vsqlerr = 0;
let vfechor = current hour to fraction(3);

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         return ;
      end if
   end exception;


   foreach
      select num_serial,fech_alt,transacc,cuenta,
         monto_tot,edo_cta,sdo_cuenta,referencia,folio_suc
         into vnumser,vfecalt,vnumtra,vcuenta,vmonto,
              vedocta,vsdocta,vreferencia,vfolio_suc
         from sc_movmes md, sc_producto pr
         where md.empresa = pempresa and md.empresa = pr.empresa and
               md.producto = pr.producto and maneja_libreta = "S"
               --and cancelad <> "S"
         order by num_serial
      let vfechor = vfechor + interval(.001) fraction to fraction;
      insert into sc_movfal
         values(vfecalt,vfechor,vnumtra,pempresa,vcuenta,0,
	        vmonto,vreferencia,vedocta,vsdocta,vfolio_suc);
   end foreach
end
end procedure;