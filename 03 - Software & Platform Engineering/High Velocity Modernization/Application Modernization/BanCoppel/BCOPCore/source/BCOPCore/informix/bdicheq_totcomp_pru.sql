create procedure "informix".totcomp_pru(pempresa char(3),
                                    pusuario char(8),
                                    psucursal char(4),
                                    pnum_total smallint)
        returning char(5),char(2),money(16,2),money(16,2),money(16,2),
        money(16,2),char(40),integer,integer,integer,integer;

define v_monto_cargo,v_monto_firme,v_monto_sbc,v_monto_rem money(16,2);
define v_movto_cargo,v_movto_firme,v_movto_sbc,v_movto_rem integer;
define v_descripcion char(40);
define v_contador smallint;
define v_fecha date;
define v_row integer;
define v_codret char(5);
define v_producto char(4);
define v_ciclo smallint;
define v_moneda char(2);
define v_cal_int_chq char(1);
define sql_err integer;
define vsuc_user char(4);

set isolation to dirty read;

let v_contador=0;
let v_ciclo=0;
let v_moneda=0;
let v_monto_cargo=0;
let v_monto_firme=0;
let v_monto_sbc=0;
let v_monto_rem=0;
let v_movto_cargo=0;
let v_movto_firme=0;
let v_movto_sbc=0;
let v_movto_rem=0;
let v_descripcion = " ";
let v_codret="000";
let vsuc_user = "";



begin
   on exception set sql_err
      if sql_err <> 0 then
         let v_codret = sql_err;
         return v_codret,v_moneda,v_monto_cargo,v_monto_firme,
               v_monto_sbc,v_monto_rem,v_descripcion,v_movto_cargo,
               v_movto_firme,v_movto_sbc,v_movto_rem with resume;
      end if
   end exception;

   select sucursal into vsuc_user from bdinteg:si_ejecut
    where ejecutivo =  pusuario 
      and empresa = pempresa;

   select fecha_hoy into v_fecha from sc_fechas where empresa = pempresa;

   delete from sc_totcomp where empresa = pempresa and usuario=pusuario;

   foreach
      select count(*),sum(monto_tot),divisa into v_movto_cargo,
             v_monto_cargo,v_moneda
         from sc_movdia md,sc_maechq mc,sc_producto pr,bdinteg:si_transacc tr
         where md.empresa = pempresa and usuario = pusuario and
               cancelad <> "S" and
               mc.empresa = md.empresa and mc.cuenta = md.cuenta and
               pr.empresa = md.empresa and pr.producto = md.producto and
               tr.empresa = md.empresa and tr.numero = transacc and
               tr.naturaleza = "C" and tr.realizada_por = "1" and
               md.sucursal = psucursal
         group by divisa
         insert into sc_totcomp
            values(pempresa,pusuario,v_moneda,v_monto_cargo,0,0,0,
                   v_movto_cargo,0,0,0);
   end foreach;

   foreach
      select count(*),sum(monto_tot - en_sbc),divisa into
             v_movto_firme,v_monto_firme,v_moneda
         from sc_movdia md,sc_maechq mc,sc_producto pr,bdinteg:si_transacc tr
         where md.empresa = pempresa and usuario = pusuario and
               cancelad <> "S" and monto_tot <> en_sbc and 
               mc.empresa = md.empresa and mc.cuenta = md.cuenta and
               pr.empresa = md.empresa and pr.producto = md.producto and
               tr.empresa = md.empresa and tr.numero = transacc and
               tr.naturaleza = "A" and tr.realizada_por = "1" and
               md.sucursal = psucursal
         group by divisa
      select rowid into v_row
         from sc_totcomp
         where empresa = pempresa and usuario = pusuario and moneda = v_moneda;
      if v_row is not null then
         update sc_totcomp
            set(monto_firme,movto_firme) = (monto_firme + v_monto_firme,
                                            movto_firme + v_movto_firme)
            where rowid = v_row;
      else
         insert into sc_totcomp
            values(pempresa,pusuario,v_moneda,0,v_monto_firme,0,0,
                   0,v_movto_firme,0,0);
      end if;
   end foreach;

   foreach
      select count(*),sum(en_sbc),divisa into
             v_movto_sbc,v_monto_sbc,v_moneda
         from sc_movdia md,sc_maechq mc,sc_producto pr,bdinteg:si_transacc tr
         where md.empresa = pempresa and usuario = pusuario and
               cancelad <> "S" and en_sbc > 0 and 
               mc.empresa = md.empresa and mc.cuenta = md.cuenta and
               pr.empresa = md.empresa and pr.producto = md.producto and
               tr.empresa = md.empresa and tr.numero = transacc and
               tr.naturaleza = "A" and tr.realizada_por = "1" and
               md.sucursal = psucursal
         group by divisa
      select rowid into v_row
         from sc_totcomp
         where empresa = pempresa and usuario = pusuario and
               moneda = v_moneda;
      if v_row is not null then
         update sc_totcomp
            set(monto_sbc,movto_sbc)=(v_monto_sbc,v_movto_sbc)
            where rowid=v_row;
      else
         insert into sc_totcomp
            values(pempresa,pusuario,v_moneda,0,0,v_monto_sbc,0,
                   0,0,v_movto_sbc,0);
      end if;
   end foreach;

   let v_monto_cargo=0;
   let v_monto_firme=0;
   let v_monto_sbc=0;
   let v_monto_rem=0;
   let v_movto_cargo=0;
   let v_movto_firme=0;
   let v_movto_sbc=0;
   let v_movto_rem=0;
   let v_moneda="00";
   let v_codret="000";

   foreach
      select moneda,monto_cargo,monto_firme,monto_sbc,monto_rem,
             descripcion,movto_cargo,movto_firme,movto_sbc,movto_rem
         into v_moneda,v_monto_cargo,v_monto_firme,v_monto_sbc,
             v_monto_rem,v_descripcion,v_movto_cargo,v_movto_firme,
             v_movto_sbc,v_movto_rem
         from sc_totcomp tc,bdinteg:si_divisas di
         where tc.empresa = pempresa and usuario = pusuario and
               di.empresa = tc.empresa and di.divisa = moneda
         order by moneda
      let v_ciclo=v_ciclo+1;
      if v_ciclo<=pnum_total then
         continue foreach;
      end if
      return v_codret,v_moneda,v_monto_cargo,v_monto_firme,
             v_monto_sbc,v_monto_rem,v_descripcion,v_movto_cargo,
             v_movto_firme,v_movto_sbc,v_movto_rem with resume;
      let v_contador=v_contador+1;
   end foreach;
end
end procedure;