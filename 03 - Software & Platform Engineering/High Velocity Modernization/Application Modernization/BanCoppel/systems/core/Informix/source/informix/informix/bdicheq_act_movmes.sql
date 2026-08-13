create procedure "informix".act_movmes(pempresa char(3))

define cod_ret char (5);
define sql_err integer;
define fech_hor_w datetime hour to fraction (5);
define vnum_serial integer;
define vfolio_suc char(16);
define vsucursal char(4);
define vusuario char(8);
define vfech_alt date;
define vfech_val date;
define vhora_mov datetime hour to fraction(3);
define vtransacc char(4);
define vsuc_cuen char(4);
define vproducto char(4);
define vcuenta char(20);
define vcausa_dev char(2);
define vnum_cheq integer;
define vmonto_tot money(14,2);
define vfirme money(14,2);
define ven_sbc money(14,2);
define vremesas money(14,2);
define vdias_ret smallint;
define vcancelad char(1);
define vedo_cta char(1);
define vsdo_cuenta money(14,2);
define vtransacc_suc char(4);
define vreferencia char(40);
define vtasa_aplicada decimal(9,6);
define vfech_hor datetime hour to fraction(3);
define vnum_tarjeta char(16);
define vusuautoriza char(8);

begin
   on exception set sql_err
      if sql_err <> 0 then
         return;
      end if;
   end exception;

   let fech_hor_w = current hour to fraction(5);
   foreach
      select * into
         vnum_serial,vfolio_suc,vsucursal,vusuario,
         vfech_alt,vfech_val,vhora_mov,vtransacc,
         vsuc_cuen,vproducto,vcuenta,vcausa_dev,vnum_cheq,
         vmonto_tot,vfirme,ven_sbc,vremesas,vdias_ret,
         vcancelad,vedo_cta,vsdo_cuenta,vtransacc_suc,
         vreferencia,vtasa_aplicada,vnum_tarjeta,vusuautoriza
         from sc_movdia
         where empresa = pempresa
         order by num_serial
      let fech_hor_w = fech_hor_w +
                       interval (.001) fraction to fraction;
      insert into sc_movmes
         values(vnum_serial,vfolio_suc,vsucursal,vusuario,
         vfech_alt,vfech_val,vhora_mov,vtransacc,
         vsuc_cuen,vproducto,pempresa,vcuenta,vcausa_dev,vnum_cheq,
         vmonto_tot,vfirme,ven_sbc,vremesas,vdias_ret,
         vcancelad,vedo_cta,vsdo_cuenta,vtransacc_suc,
         vreferencia,vtasa_aplicada,fech_hor_w,vnum_tarjeta,vusuautoriza);
      continue foreach;
   end foreach;
   return;
end
end procedure;