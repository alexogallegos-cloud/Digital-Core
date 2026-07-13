create procedure "informix".recuperamov()
       returning char(5);

define vcodret char(5);
define vempresa char(3);
define vsucursal char(3);
define vusuario char(8);
define vtransacc char(4);
define vtransuc char(4);
define vfolsuc char(16);
define vcuenta char(20);
define vcheque integer;
define vmonto money(14,2);
define vdivisa char(2);
define vreferencia char(40);
define vnum_serial integer;
define vnaturaleza char(1);
define vdias_ret smallint;
define vtranret char(4);
define vsaldo,vretiro money(14,2);
define vfechahoy date;

let vcodret = "000";
let vdivisa = "01";

foreach
   select num_serial,empresa,sucursal,usuario,transacc,transacc_suc,
          folio_suc,cuenta,num_cheq,monto_tot,referencia,dias_ret
      into vnum_serial,vempresa,vsucursal,vusuario,vtransacc,vtransuc,
           vfolsuc,vcuenta,vcheque,vmonto,vreferencia,vdias_ret
      from movdia
      where usuario <> "luisahv7" and cancelad <> "S"
   select naturaleza into vnaturaleza
      from bdinteg:si_transacc
      where numero = vtransacc;
   if vnaturaleza = "C" then
      call cargo_ref(vempresa,vsucursal,vusuario,vtransacc,vtransuc,
                     vfolsuc,vcuenta,vcheque,vmonto,vdivisa,vreferencia)
           returning vcodret,vtranret,vfechahoy,vsaldo,vretiro;
      insert into bitacora
         values(vcuenta,vfolsuc,vcodret);
   end if
   if vnaturaleza = "A" then
      call abono_ref(vempresa,vsucursal,vusuario,vtransacc,vtransuc,
                     vfolsuc,vcuenta,vcheque,vmonto,vmonto,0,0,
                     vdias_ret,vdivisa,vreferencia)
           returning vcodret;
      insert into bitacora
         values(vcuenta,vfolsuc,vcodret);
   end if
end foreach
return vcodret;
end procedure;