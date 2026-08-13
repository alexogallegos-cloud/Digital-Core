create procedure "informix".actbancos()
       returning char(5);

define vcodret char(5);
define vcuenta char(20);
define vmonto money(14,2);
define vintdia money(14,2);
define vtransacc char(4);
define vnumcte char(9);
define vnumsolbco smallint;
define vctachq char(20);

let vcodret = "000";

foreach
   select cuenta,monto_tot,transacc
      into vcuenta,vmonto,vtransacc
      from sv_movdia
       where transacc in("0503")  and
             cuenta not in ("10001693704744","20002106304610")
   select numero_solicitud into vnumsolbco
      from bdibanco:sb_solscredito
      where numero_solcredito = vcuenta;
   update bdibanco:sb_cheques
      set importe_cheque = vmonto
      where numero_solicitud = vnumsolbco;
end foreach
return vcodret;
end procedure;