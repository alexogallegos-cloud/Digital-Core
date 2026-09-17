create procedure "informix".vencimiento_cap(pempresa char(3))
       returning char(5);
   define global vgfecha_hoy   date         default " ";
   define global vgprox_fecha  date         default " ";
   define global vgusuario char(8)          default " ";
   define global vgpri_hab_mes date         default " ";
   define global vgult_hab_mes date         default " ";
   define global vgtranabotrasp char(4)     default " ";

   define vcodret char(5);
   define vsqlerr integer;
   define vtrancarcap char(4);
   define vsdo_disp,vsdo_cong,vsdo_retenido money(14,2);
   define vexiste char(1);
   define vultpagocap date;
   define vfolio_suc char(16);
   define vhora datetime hour to fraction;
   define vhoraw char(15);
   define vfecpagocap datetime month to day;
   define vcuenta,vnum_cte,vcuentadep char(20);
   define vsucursal char(4);
   define vstatus_cta char(1);
   define vpaga_capital char(1);
   define vsistema,vinstrucc,vtp_moneda char(2);
   define vtranretcap,vproducto char(4);
   define vsdo_actual money(14,2);
   define vfecha_pago date;
   define vmensaje char(60);
   define vsolbcos integer;
   define vnum_tarjeta char(16);
   define vmaxsec smallint;


   let vcodret = "000";

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

   foreach
      select mc.cuenta,mc.num_cte,mc.sucursal,status_cta,pr.paga_capital,
             divisa,mc.producto,sdo_actual,sdo_cong,sdo_retenido,
             mc.ultpagocap,fecpagocap
         into vcuenta,vnum_cte,vsucursal,vstatus_cta,vpaga_capital,
             vtp_moneda,vproducto,vsdo_actual,vsdo_cong,vsdo_retenido,
             vultpagocap,vfecpagocap
         from sc_maechq mc,sc_maenoc mn,sc_producto pr
         where mc.empresa = pempresa and status_cta = "1"
               and mc.empresa = mn.empresa and mc.cuenta = mn.cuenta
               and pr.empresa = mc.empresa and pr.producto = mc.producto

      if vpaga_capital is null then
         let vpaga_capital = "N";
      end if

      if vfecpagocap = "" or vfecpagocap is null then
         let vfecha_pago = "";
      else
         let vfecha_pago = mdy(month(vfecpagocap),day(vfecpagocap),
                               year(vgfecha_hoy));
         if vfecha_pago <= vultpagocap then
            let vfecha_pago = vfecha_pago + 1 units year;
         end if
      end if

      if vpaga_capital = "S" and vsdo_retenido = 0 and
         vfecha_pago >= vgfecha_hoy and vfecha_pago < vgprox_fecha then
         if vsdo_actual > 0 then
            select instrucc,sistema,cuentadep
               into vinstrucc,vsistema,vcuentadep
               from sc_maeinstrucc
               where empresa = pempresa and cuenta = vcuenta and
                     capint = "C";
            if vinstrucc is null then
               let vinstrucc = "03";
               insert into sc_maeinstrucc
                  values(pempresa,vcuenta,"C","03","12","","N");
            end if
            if vinstrucc <> "01" then
               let vhora = current hour to fraction;
               let vhoraw = vhora;
               let vhoraw = vhoraw[1,2] || vhoraw[4,5] || vhoraw[7,8] ||
                            vhoraw[10,11];
               let vfolio_suc = vgusuario || vhoraw[1,8];
               select trans_cap into vtrancarcap
                  from sc_instrucc
                  where empresa = pempresa and instrucc = vinstrucc;
               if vsistema = "01" and vcuentadep <> "" then
                  select max(secuencia) into vmaxsec
                     from sc_tarjeta
                     where empresa = pempresa and cuenta = vcuentadep and
                           tipo_tarjeta = "T";
                  select num_tarjeta into vnum_tarjeta
                     from sc_tarjeta
                     where empresa = pempresa and cuenta = vcuentadep and
                           secuencia = vmaxsec;
                  insert into sc_movdia
                     values (0,vfolio_suc,vsucursal,vgusuario,vgfecha_hoy,
                     vgfecha_hoy,vhora,vgtranabotrasp,vsucursal,vproducto,
                     pempresa,vcuentadep, "",0,vsdo_actual,vsdo_actual,0,
                     0,0,"","1",vsdo_actual,"0000"," ",0,vnum_tarjeta,"","");
               else
                  call bdibanco:sbsp_graba_solchq(pempresa,vnum_cte,vgusuario,
                                                  vsdo_actual,vcuenta)
                       returning vcodret,vmensaje,vsolbcos;
                  if vcodret = "00000" then
                     let vcodret = "000";
                  end if
               end if
               update sc_maeinstrucc
                  set aplicado = "S"
                  where empresa = pempresa and cuenta = vcuenta and
                        capint = "C";
               insert into sc_movdia
                  values (0,vfolio_suc,vsucursal,vgusuario,vgfecha_hoy,
                     vgfecha_hoy,vhora,vtrancarcap,vsucursal,vproducto,
                     pempresa,vcuenta, "",0,vsdo_actual,vsdo_actual,0,0,
                     0,"","1",vsdo_actual,"0000"," ",0,vnum_tarjeta,"","");
               update sc_maechq
                  set (num_cgos_mes,imp_cgos_mes,sdo_actual) =
                      (num_cgos_mes + 1,imp_cgos_mes + vsdo_actual,
                       sdo_actual - vsdo_actual)
                  where empresa = pempresa and cuenta = vcuenta;
            end if
         end if
      end if
   end foreach
   return vcodret;
end
end procedure;