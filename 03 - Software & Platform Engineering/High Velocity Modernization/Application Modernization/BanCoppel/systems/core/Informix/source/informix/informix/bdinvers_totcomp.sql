create procedure "informix".totcomp(pempresa char(3),
                                    pusuario char(8),
                                    psucursal char(4),
                                    pnum_total smallint)

	returning char(5),char(2),money(16,2),money(16,2),
	money(16,2),money(16,2),char(40),integer,integer,integer,integer;


   define v_monto_cargo,v_monto_cero,v_monto_firme,v_monto_sbc money(16,2);
   define v_movto_cargo,v_movto_rem, v_movto_firme,v_movto_sbc integer;
   define v_descripcion char(40);
   define v_contador smallint;
   define v_fecha date;
   define v_row integer;
   define w_sucursal char(4);
   define w_plaza char(3);
   define v_codret char(5);
   define sql_err,isam_err integer;
   define v_producto char(4);
   define v_ciclo smallint;
   define v_moneda char(2);
   let v_contador=0;
   let v_ciclo=0;
   let v_moneda=0;
   let v_monto_cero = 0;
   let v_monto_cargo=0;
   let v_monto_firme=0;
   let v_monto_sbc=0;
   let v_movto_cargo=0;
   let v_movto_firme=0;
   let v_movto_sbc=0;
   let v_movto_rem = 0;
   let v_descripcion = " ";



   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            return v_codret,v_moneda,v_monto_cargo,v_monto_firme,
                   v_monto_sbc,v_monto_cero,v_descripcion,v_movto_cargo,
		   v_movto_firme,v_movto_sbc,v_movto_rem;
         end if;
      end exception;
	  set isolation to dirty read;
      set lock mode to wait 3;
   -- ****************************************************************************
   select fecha_hoy into v_fecha
      from sv_fechas
      where empresa = pempresa;
   delete from sv_totcomp
      where empresa = pempresa and usuario=pusuario;
   foreach
      select count(*),sum(monto_tot),moneda into
             v_movto_cargo,v_monto_cargo,v_moneda
         from sv_movdia md,bdinteg:si_transacc tr,sv_instrum pr
   	 where md.empresa = pempresa and usuario = pusuario and
               cancelad <> "S" and
               tr.empresa = md.empresa and tr.numero = md.transacc and
               tr.naturaleza = "C" and tr.realizada_por = "1" and tr.sistema = "03" and
               pr.empresa = md.empresa and pr.cod_instrum = md.cod_instrum and
               md.sucursal = psucursal
   	 group by moneda

      insert into sv_totcomp values(pempresa,pusuario,v_moneda,
                                    v_monto_cargo,0,0,v_movto_cargo,0,0);
   end foreach;
   foreach
      select count(*),sum(monto_tot - en_sbc),moneda
         into v_movto_firme,v_monto_firme,v_moneda
         from sv_movdia md,bdinteg:si_transacc tr,sv_instrum pr
   	 where md.empresa = pempresa and usuario = pusuario and
               cancelad <> "S" and monto_tot <> en_sbc and
               tr.empresa = md.empresa and tr.numero = md.transacc and
               tr.naturaleza = "A" and tr.realizada_por = "1" and tr.sistema = "03" and
               pr.empresa = md.empresa and pr.cod_instrum = md.cod_instrum and 
               md.sucursal = psucursal
   	 group by moneda
      select rowid into v_row
         from sv_totcomp
         where empresa = pempresa and usuario = pusuario and moneda = v_moneda;
      if v_row is not null then
   	 update sv_totcomp
            set(monto_firme,movto_firme) = (v_monto_firme,v_movto_firme)
   	    where rowid=v_row;
      else
   	 insert into sv_totcomp
   	    values(pempresa,pusuario,v_moneda,0,v_monto_firme,0,
	           0,v_movto_firme,0);
      end if;
   end foreach;

   foreach
      select count(*),sum(en_sbc),moneda
         into v_movto_sbc,v_monto_sbc,v_moneda
         from sv_movdia md,bdinteg:si_transacc tr,sv_instrum pr
   	 where md.empresa = pempresa and usuario = pusuario and
               cancelad <> "S" and en_sbc > 0 and
               tr.empresa = md.empresa and tr.numero = md.transacc and
               tr.naturaleza = "A" and tr.realizada_por = "1" and tr.sistema = "03" and
               pr.empresa = md.empresa and pr.cod_instrum = md.cod_instrum and
               md.sucursal = psucursal
   	 group by moneda
      select rowid into v_row
         from sv_totcomp
         where empresa = pempresa and usuario = pusuario and moneda = v_moneda;
      if v_row is not null then
   	 update sv_totcomp
            set(monto_sbc,movto_sbc) = (v_monto_sbc,v_movto_sbc)
   	    where rowid=v_row;
      else
   	 insert into sv_totcomp
   	    values(pempresa,pusuario,v_moneda,0,0,v_monto_sbc,
	           0,0,v_movto_sbc,0);
      end if;
   end foreach;

   let v_monto_cargo=0;
   let v_monto_firme=0;
   let v_monto_sbc=0;
   let v_movto_cargo=0;
   let v_movto_firme=0;
   let v_movto_sbc=0;
   let v_moneda="00";
   let v_codret="000";
   -- Extrae sucursal y plaza
   select sucursal into w_sucursal from bdinteg:si_ejecut
   where ejecutivo = pusuario;

   select plaza into w_plaza from bdinteg:si_sucursales
      where empresa = pempresa and sucursal = w_sucursal;
   foreach
      select moneda,monto_cargo,monto_firme,monto_sbc,descripcion,
             movto_cargo,movto_firme,movto_sbc
         into v_moneda,v_monto_cargo,v_monto_firme,v_monto_sbc,
              v_descripcion,v_movto_cargo,v_movto_firme,v_movto_sbc
         from sv_totcomp tc,bdinteg:si_divisas di
         where tc.empresa = pempresa and usuario = pusuario and
               di.empresa = tc.empresa and di.divisa = moneda
         order by moneda
      let v_ciclo=v_ciclo+1;
      if v_ciclo<=pnum_total then
         continue foreach;
      end if
      return v_codret,v_moneda,v_monto_cargo,v_monto_firme,
      v_monto_sbc,v_monto_cero,v_descripcion,v_movto_cargo,v_movto_firme,
      v_movto_sbc,v_movto_rem  with resume;
      let v_contador=v_contador+1;
   end foreach;
   end;    --fin del on exception
end procedure;