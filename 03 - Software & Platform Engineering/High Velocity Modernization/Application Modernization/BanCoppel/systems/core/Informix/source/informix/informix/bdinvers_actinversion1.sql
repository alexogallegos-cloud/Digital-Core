create procedure "informix".actinversion1()
    returning char(5);
define vcuenta char(20);
define vcodret char(5);
define vtasa,vtasa_act decimal(9,6);
define vplazo,vplazo_act smallint;
define vcapital,vintxpag_nvo,vinteres,visr money(14,2);
define vpago_act,vcobraisr char(1);
define vvencim_nvo,vvencim_act,vultpago_act,valta_act date;
define vdias smallint;
define vfecha_hoy date;



let vcodret = "000";

foreach
   select cuenta,tasa,plazo,vencim_nvo,intxpag_nvo
      into vcuenta,vtasa,vplazo,vvencim_nvo,vintxpag_nvo
      from inv30122004
      where capital_act > 0
   select capital, cobraisr
      into vcapital, vcobraisr
      from sv_maeinv
      where cuenta = vcuenta and status_cta in("1","3");
   let vinteres = vcapital * vtasa / 365 / 100 * vplazo;
   if vcobraisr = "S" then
      let visr = vinteres * 0.17;
   else
      let visr = 0;
   end if
   update sv_maeinv
      set fecha_venc = vvencim_nvo,
          plazo = vplazo,
          tasa = vtasa,
          intereses = vinteres,
          isr = visr
      where cuenta = vcuenta and status_cta in("1","3");
   update sv_maeinstrucc
      set fecha_venc = vvencim_nvo,
          importe = vintxpag_nvo
      where cuenta = vcuenta and cap_int = "I";
end foreach;
return vcodret;
end procedure;