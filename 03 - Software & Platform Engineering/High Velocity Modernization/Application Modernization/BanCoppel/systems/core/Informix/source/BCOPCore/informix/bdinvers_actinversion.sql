create procedure "informix".actinversion()
    returning char(5);
define vcuenta char(20);
define vcodret char(5);
define vtasa,vtasa_act decimal(9,6);
define vplazo,vplazo_act smallint;
define vcapital,vintxpag_nvo money(14,2);
define vpago_act char(1);
define vvencim_nvo,vvencim_act,vultpago_act,valta_act date;
define vdias smallint;
define vfecha_hoy date;



let vcodret = "000";

select fecha_hoy into vfecha_hoy
   from sv_fechas;

foreach
   select cuenta,tasa,plazo
      into vcuenta,vtasa,vplazo
      from inv30122004
   select capital,tasa,plazo,per_acred_int,fecha_venc,
          fec_ult_mov,fecha_alta
      into vcapital,vtasa_act,vplazo_act,vpago_act,vvencim_act,
           vultpago_act,valta_act
      from sv_maeinv
      where cuenta = vcuenta and status_cta in("1","3");
   let vvencim_nvo = valta_act + vplazo;
   let vdias = vfecha_hoy - vultpago_act;
   let vintxpag_nvo = vcapital * vtasa / 365 / 100 * vdias;
   update inv30122004
      set capital_act = vcapital,
          tasa_act = vtasa_act,
          plazo_act = vplazo_act,
          pago_act = vpago_act,
          vencim_act = vvencim_act,
          ultpago = vultpago_act,
          alta_act = valta_act,
          vencim_nvo = vvencim_nvo,
          intxpag_nvo = vintxpag_nvo
      where cuenta = vcuenta;
end foreach;
return vcodret;
end procedure;