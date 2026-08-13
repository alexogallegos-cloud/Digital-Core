create procedure "informix".gencommes(pempresa char(3),
                                      pcuenta char(20))
       returning char(5);

define vsqlerr integer;
define vcodret char(5);
define vult_hab_mes,vfecha_hoy date;
define vcomision char(4);
define vforma_aplica char(1);
define vmonto_aplica money(14,2);
define vfactor_aplica decimal(9,6);
define vrangos char(1);
define vrango_min money(14,2);
define vrango_max money(14,2);
define vcodigo_param char(2);
define vejecuta_spl char(1);
define voperador char(1);
define vnombrespl char(20);
define vvalorspl money(14,2);
define vcalcula_com char(1);
define vmonto_com money(14,2);
define vcuenta char(20);
define vproducto char(4);



begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

   let vcodret = "000";
   select {+INDEX(sc_fechas idx_fechas1)} fecha_hoy,ult_hab_mes
      into vfecha_hoy,vult_hab_mes
      from sc_fechas where empresa = pempresa;

   if vfecha_hoy <> vult_hab_mes then
      return vcodret;
   end if

            SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;

   foreach
      select {+INDEX(sc_prodcomis idx_prodcomis), +INDEX(sc_comisiones idx_comision1)} pc.comision,forma_aplica,monto_aplica,factor_aplica,rangos,
             rango_min,rango_max,campo,producto,operador
         into vcomision,vforma_aplica,vmonto_aplica,vfactor_aplica,vrangos,
              vrango_min,vrango_max,vcodigo_param,vproducto,voperador
         from sc_comisiones co, sc_prodcomis pc
         where co.empresa = pempresa and forma_cargo = "03" and
               pc.empresa = co.empresa and pc.comision = co.comision

      select ejecuta_spl,nombrespl
         into vejecuta_spl,vnombrespl
         from sc_paramcomis
         where empresa = pempresa and codigo_param = vcodigo_param and
               tipo_param = "D";

      foreach
         select mc.cuenta,sdo_actual into vcuenta,vvalorspl
            from sc_maechq mc
            where mc.empresa = pempresa and mc.cuenta = pcuenta and
                  mc.producto = vproducto
         if vejecuta_spl = "S" then
            ---call vnombrespl(pempresa,vcuenta) returning vcodret,vvalorspl;
            if vcodret <> "000" then
               return vcodret;
            end if
         end if
         if vrangos = "S" then
            if vvalorspl >= vrango_min and vvalorspl <= vrango_max then
               let vcalcula_com = "1";
               if voperador = "*" then
                  let vvalorspl = vvalorspl - vrango_min + 1;
               end if
            else
               let vcalcula_com = "0";
            end if
         else
            let vcalcula_com = "1";
         end if
         if vcalcula_com = "1" then
            if vforma_aplica = "1" then -- comision por monto
               if voperador = "*" then
                  let vmonto_com = vmonto_aplica * vvalorspl;
               else
                  let vmonto_com = vmonto_aplica;
               end if
            else -- comision por porcentaje
               let vmonto_com = vvalorspl * vfactor_aplica / 100;
            end if
            if vmonto_com > 0 then
               insert into sc_detcomis
                  values(pempresa,vcuenta,vcomision,vmonto_com,
                         0,vfecha_hoy,"","P"," ");
               update sc_maechq
                  set com_pendiente = com_pendiente + vmonto_com
                  where empresa = pempresa and cuenta = vcuenta;
            end if
         end if
      end foreach
   end foreach

  return vcodret;
end
end procedure
DOCUMENT
"Genera comisiones mensuales",
"Realizado Por Procesamiento Interactivo",
"Ver 1.0 10/Marzo/2003";

create procedure "informix".histsbg(pempresa char(3),
                                    pcuenta  char(20))
       returning char(5);

define v_cta_en_legal,sw char(1);
define w_cant_dias_sbg,v_motivo char(2);
define v_sucursal char(4);
define vd_transacc,v_tipo_sbg char(4);
define v_tasa_int_ccc,v_tasa_int_sbg,vt_tasa_sbg char(8);
define v_num_cte like sc_maechq.num_cte;
define v_lim_sbg_ccc,v_imp_sbg_ccc,v_imp_chq_sbg,v_imp_chq_ccc,
       v_imp_int_ccc,v_imp_int_sbg,v_acum_ccc,v_cargo,v_abono,
       vd_monto_tot,v_int_sbg_dia,v_int_sbg_sigmes,v_dispon_sbg money(14,2);
define v_dias_ccc,w_cant_dias,w_cant_dias_sig smallint;
define v_sobretasa_ccc,v_sobretasa decimal(9,6);
define vf_fecha_hoy,vf_prox_fecha,vf_pri_dia_mes,vf_ult_dia_mes,
       v_pridiasigmes,vf_ult_hab_mes,ult_fech_sbg date;
define w_tipo_per char(1);
define w_tp_persona char(2);
define vcodret char(5);
define w_retroactivo char(1);
define w_mes_hoy,w_mes_sig,w_ano_hoy,w_ano_sig smallint;
define sql_err, w_rowid integer;
define wtasa_dia,wtasa_sigmes,w_tasacont,w_tasa decimal(9,3);
define vprodu char(4);
define vw_tasa_sbg_pf, vw_tasa_sbg_pm char(8);
define vw_tasa_ccc_pf, vw_tasa_ccc_pm char(8);
define vtranusoccc,vtranintccc,vtranpagoccc,vtranusosbg,
       vtranintsbg,vtranpagosbg char(4);

let vcodret = "000";
let sw = 0;
let w_retroactivo = 0;



begin
   on exception set sql_err
      if sql_err <> 0 then
         let vcodret = sql_err;
         return vcodret;
      end if;
   end exception;

set isolation to dirty read;

   select fecha_hoy,prox_fecha,pri_dia_mes,
          ult_dia_mes,ult_hab_mes
      into vf_fecha_hoy,vf_prox_fecha,vf_pri_dia_mes,
           vf_ult_dia_mes,vf_ult_hab_mes
      from sc_fechas where empresa = pempresa;

   select valor into vtranusoccc
      from sc_param
      where empresa = pempresa and codparam = "tranusoccc";

   select valor into vtranintccc
      from sc_param
      where empresa = pempresa and codparam = "tranintccc";

   select valor into vtranpagoccc
      from sc_param
      where empresa = pempresa and codparam = "tranpagoccc";

   select valor into vtranusosbg
      from sc_param
      where empresa = pempresa and codparam = "tranusosbg";

   select valor into vtranintsbg
      from sc_param
      where empresa = pempresa and codparam = "tranintsbg";

   select valor into vtranpagosbg
      from sc_param
      where empresa = pempresa and codparam = "tranpagosbg";

   select num_cte, imp_sbg_ccc,imp_int_ccc,tasa_int_ccc, sobretasa_ccc,
          dias_ccc,acum_ccc,motivo,sucursal,lim_sbg_ccc,
          imp_chq_sbg,imp_int_sbg,producto
      into v_num_cte,v_imp_sbg_ccc,v_imp_int_ccc,v_tasa_int_ccc,
          v_sobretasa_ccc,v_dias_ccc,v_acum_ccc,v_motivo,v_sucursal,
          v_lim_sbg_ccc,v_imp_chq_sbg,v_imp_int_sbg,vprodu
      from sc_maechq, sc_maenoc
      where sc_maechq.empresa = pempresa and sc_maechq.cuenta = pcuenta and
            sc_maenoc.empresa = sc_maechq.empresa and 
            sc_maenoc.cuenta = sc_maechq.cuenta;

   if v_num_cte is null then
      let vcodret = "100";
      return vcodret;
   end if

   select tasa_ccc,tasa_sbg,sobretasa
      into vw_tasa_ccc_pf,vw_tasa_sbg_pf,v_sobretasa
      from sc_producto
      where empresa = pempresa and producto = vprodu;

   if v_tasa_int_ccc is null  or v_tasa_int_ccc = " " then
      let v_tasa_int_ccc = vw_tasa_ccc_pf;
      let v_sobretasa_ccc = v_sobretasa;
   end if
   let v_tasa_int_sbg = vw_tasa_sbg_pf;

   if v_sobretasa_ccc is null then
      let v_sobretasa_ccc = 0;
   end if

   select tpo_persona into w_tp_persona
      from bdinteg:si_cliente
      where numcte = v_num_cte;

   if w_tp_persona is null then
      let vcodret = "104";
      return vcodret;
   end if
   select es_fisica into w_tipo_per
      from bdinteg:si_tipper
      where tpo_persona = w_tp_persona;
   if w_tipo_per is null then
      let vcodret = "104";
      return vcodret;
   end if
   if w_tipo_per = "S" then
      let w_tipo_per = "F";
   else
      let w_tipo_per = "M";
   end if

   if vf_fecha_hoy = vf_ult_hab_mes then
      let sw = "1";
      let w_cant_dias_sig = day(vf_prox_fecha) -1;
      let w_cant_dias = vf_ult_dia_mes - vf_fecha_hoy + 1;
   else
      let w_cant_dias = vf_prox_fecha - vf_fecha_hoy;
   end if
   let w_ano_sig = year(vf_prox_fecha);
   let w_mes_sig = month(vf_prox_fecha);
   let w_ano_hoy = year(vf_fecha_hoy);
   let w_mes_hoy = month(vf_fecha_hoy);

   let w_cant_dias_sbg = w_cant_dias ;
   if v_motivo = "06" then
      let v_cta_en_legal = "S";
   else
      let v_cta_en_legal = "N";
   end if

   foreach
       select transacc,monto_tot into vd_transacc,vd_monto_tot
          from sc_movdia
          where empresa = pempresa and cuenta = pcuenta and cancelad != "S" and
                (transacc = vtranintccc or transacc = vtranpagoccc or
                 transacc = vtranusoccc or transacc = vtranusosbg or
                 transacc = vtranintsbg or transacc = vtranpagosbg)
       if vd_transacc = vtranintccc or vd_transacc = vtranintsbg then
          call inthist(pempresa,pcuenta,vd_monto_tot) returning vcodret;
       else
          if vd_transacc = vtranpagoccc or vd_transacc = vtranusoccc then
             let v_tipo_sbg = "1305";
          else
             let v_tipo_sbg = "1505";
          end if
          if vd_transacc = vtranusoccc or vd_transacc = vtranusosbg then
             let v_cargo = vd_monto_tot;
             let v_abono = 0;
          else
             let v_abono = vd_monto_tot;
             let v_cargo = 0;
          end if
          select rowid into w_rowid
             from sc_histsbg
             where empresa = pempresa and cuenta = pcuenta and 
                   fecha_sbg = vf_fecha_hoy and
                    tipo_linea = v_tipo_sbg;
          if w_rowid is null then
             if v_tipo_sbg = "1305" then
                insert into sc_histsbg
                   values (pempresa,v_sucursal,pcuenta,vf_fecha_hoy,v_tipo_sbg,
                   v_cta_en_legal,v_lim_sbg_ccc,v_num_cte, v_imp_sbg_ccc,
                   v_cargo,v_abono,0,0,0,0,0,"0",w_retroactivo);
             else
                insert into sc_histsbg
                   values (pempresa,v_sucursal,pcuenta,vf_fecha_hoy,v_tipo_sbg,
                   v_cta_en_legal,0,v_num_cte, v_imp_chq_sbg,
                   v_cargo,v_abono,0,0,0,0,0,"0",w_retroactivo);
             end if
          else
             update sc_histsbg
                set cargos = cargos + v_cargo,
                    abonos = abonos + v_abono,
                    sdo_disp_dia_ant = sdo_disp_dia_ant - v_cargo + v_abono,
                    retroactivo = w_retroactivo
                where rowid = w_rowid;
          end if
       end if
   end foreach;

   --- Valida si tiene Sobregiro en C.C.C.
   if  v_imp_sbg_ccc > 0  then
       let v_tipo_sbg = "1305";
       let v_dispon_sbg = v_lim_sbg_ccc - v_imp_sbg_ccc;
       let v_acum_ccc = v_acum_ccc + (v_imp_sbg_ccc * w_cant_dias);
       let v_dias_ccc = v_dias_ccc + w_cant_dias;
       --- Si es fin de mes incrementa su acumulado por los dias
       --- inhabiles del siguiente mes
       if sw = "1" and w_cant_dias_sig > 0 then
          let v_acum_ccc = v_acum_ccc + v_imp_sbg_ccc * w_cant_dias_sig;
          let v_dias_ccc = v_dias_ccc + w_cant_dias_sig;
       end if
       --- Extrae tasa a aplicar para el cobro de intereses de C.C.C.
       call ext_tasa(pempresa,v_tasa_int_ccc,w_tipo_per, w_ano_hoy,w_mes_hoy,
                     v_imp_sbg_ccc) returning vcodret,w_tasa;
       if vcodret != "000" then
          return vcodret;
       end if
       let wtasa_dia = w_tasa + v_sobretasa_ccc;
       --- Calcula intereses por utilizar C.C.C.
       let v_int_sbg_dia = (((v_imp_sbg_ccc * (wtasa_dia /100))/360) *
                           w_cant_dias);
       let v_imp_int_ccc = v_imp_int_ccc + v_int_sbg_dia;
       --- Si es fin de mes Extrae tasa a aplicar del siguiente mes
       if sw = "1" and w_cant_dias_sig > 0 then
          call ext_tasa(pempresa,v_tasa_int_ccc,w_tipo_per,w_ano_sig,w_mes_sig,
                        v_imp_sbg_ccc) returning vcodret,w_tasa;
          if vcodret != "000" then
             return vcodret;
          end if
          let wtasa_sigmes = w_tasa + v_sobretasa_ccc;
          let v_int_sbg_sigmes = (((v_imp_sbg_ccc*(wtasa_sigmes /100))/360)*
                                 w_cant_dias_sig);
          let v_imp_int_ccc = v_imp_int_ccc + v_int_sbg_sigmes;
       end if
       select max(fecha_sbg) into  ult_fech_sbg
          from  sc_histsbg
          where empresa = pempresa and cuenta = pcuenta and 
                tipo_linea = v_tipo_sbg;
       --- Si no existe en historico lo crea
       if ult_fech_sbg is null then
          insert into sc_histsbg
             values (pempresa,v_sucursal,pcuenta,vf_fecha_hoy,v_tipo_sbg,
             v_cta_en_legal, v_lim_sbg_ccc, v_num_cte,0,0,0,
             v_imp_sbg_ccc, v_dispon_sbg,0,
             v_int_sbg_dia,wtasa_dia,w_cant_dias_sbg,w_retroactivo);
       else
          select rowid,tasa into w_rowid,w_tasacont
             from sc_histsbg
             where empresa = pempresa and cuenta = pcuenta and
                   fecha_sbg = ult_fech_sbg and
                   tipo_linea = v_tipo_sbg;
          --- Si no existe en historico o cambio la tasa o
          --- es primer dia del mes y es habil
          if w_rowid is null or (w_tasacont != wtasa_dia and
             vf_fecha_hoy != ult_fech_sbg) or
             (vf_fecha_hoy = vf_pri_dia_mes and
              vf_fecha_hoy != ult_fech_sbg) then
             insert into sc_histsbg
                values (pempresa,v_sucursal, pcuenta,vf_fecha_hoy,v_tipo_sbg,
                   v_cta_en_legal, v_lim_sbg_ccc, v_num_cte,0,0,0,
                   v_imp_sbg_ccc, v_dispon_sbg,0,v_int_sbg_dia,
                   wtasa_dia,w_cant_dias_sbg,w_retroactivo);
          else
             update sc_histsbg
                set (int_dia) = (0),
                    (int_acum) = (int_acum + v_int_sbg_dia),
                    (sdo_disponible) = (v_dispon_sbg),
                    (sdo_actual) = (v_imp_sbg_ccc),
                    (tasa) = (wtasa_dia),
                    (dias) = (dias + w_cant_dias_sbg),
                    (retroactivo)=(w_retroactivo)
                where rowid = w_rowid;
          end if
       end if
       if sw = "1" and w_cant_dias_sig > 0 then
          let v_pridiasigmes = vf_prox_fecha - 1 units day;
          insert into sc_histsbg
             values (pempresa,v_sucursal, pcuenta,v_pridiasigmes,v_tipo_sbg,
             v_cta_en_legal,v_lim_sbg_ccc, v_num_cte,0,0,0,
             v_imp_sbg_ccc, v_dispon_sbg,0,v_int_sbg_sigmes,
             wtasa_sigmes,w_cant_dias_sig," ");
       end if
   end if;

   --- Valida si tiene Sobregiro no autorizado
   if  v_imp_chq_sbg > 0  then
       let v_tipo_sbg = "1505";
       let v_dispon_sbg = 0;
       let v_acum_ccc = v_acum_ccc + (v_imp_chq_sbg * w_cant_dias);
       let v_dias_ccc = v_dias_ccc + w_cant_dias;
       --- Si es fin de mes incrementa su acumulado por los dias
       --- inhabiles del siguiente mes
       if sw = "1" and w_cant_dias_sig > 0 then
          let v_acum_ccc = v_acum_ccc + v_imp_chq_sbg * w_cant_dias_sig;
          let v_dias_ccc = v_dias_ccc + w_cant_dias_sig;
       end if
       --- Extrae tasa a aplicar para el cobro de intereses de Sobregiro
       call ext_tasa(pempresa,v_tasa_int_sbg,w_tipo_per,w_ano_hoy,w_mes_hoy,
                     v_imp_chq_sbg) returning vcodret,w_tasa;
       if vcodret != "000" then
          return vcodret;
       end if
       let wtasa_dia = w_tasa;
       --- Calcula intereses por utilizar Sobregiro no autorizado
       let v_int_sbg_dia = (((v_imp_chq_sbg * (wtasa_dia /100))/360) *
                           w_cant_dias);
       let v_imp_int_sbg = v_imp_int_sbg + v_int_sbg_dia;
       --- Si es fin de mes Extrae tasa a aplicar del siguiente mes
       if sw = "1" and w_cant_dias_sig > 0 then
          call ext_tasa(pempresa,v_tasa_int_sbg,w_tipo_per,w_ano_sig,w_mes_sig,
                        v_imp_chq_sbg) returning vcodret,w_tasa;
          if vcodret != "000" then
             return vcodret;
          end if
          let wtasa_sigmes = w_tasa;
          let v_int_sbg_sigmes = (((v_imp_chq_sbg*(wtasa_sigmes /100))/360)*
                                 w_cant_dias_sig);
          let v_imp_int_sbg = v_imp_int_sbg + v_int_sbg_sigmes;
       end if
       select max(fecha_sbg) into  ult_fech_sbg
          from  sc_histsbg
          where empresa = pempresa and cuenta = pcuenta and 
                tipo_linea = v_tipo_sbg;
       --- Si no existe en historico lo crea
       if ult_fech_sbg is null then
          insert into sc_histsbg
             values (pempresa,v_sucursal,pcuenta,vf_fecha_hoy,v_tipo_sbg,
             v_cta_en_legal, 0, v_num_cte,0,0,0,
             v_imp_chq_sbg, v_dispon_sbg,0,
             v_int_sbg_dia,wtasa_dia,w_cant_dias_sbg,w_retroactivo);
       else
          select rowid,tasa into w_rowid,w_tasacont
             from sc_histsbg
             where empresa = pempresa and cuenta = pcuenta and 
                   fecha_sbg = ult_fech_sbg and
                   tipo_linea = v_tipo_sbg;
          --- Si no existe en historico o cambio la tasa o
          --- es primer dia del mes y es habil
          if w_rowid is null or (w_tasacont != wtasa_dia and
             vf_fecha_hoy != ult_fech_sbg) or
             (vf_fecha_hoy = vf_pri_dia_mes and
              vf_fecha_hoy != ult_fech_sbg) then
             insert into sc_histsbg
                values (pempresa,v_sucursal, pcuenta,vf_fecha_hoy,v_tipo_sbg,
                   v_cta_en_legal, 0, v_num_cte,0,0,0,
                   v_imp_chq_sbg, v_dispon_sbg,0,v_int_sbg_dia,
                   wtasa_dia,w_cant_dias_sbg,w_retroactivo);
          else
             update sc_histsbg
                set (int_dia) = (0),
                    (int_acum) = (int_acum + v_int_sbg_dia),
                    (sdo_disponible) = (v_dispon_sbg),
                    (sdo_actual) = (v_imp_chq_sbg),
                    (tasa) = (wtasa_dia),
                    (dias) = (dias + w_cant_dias_sbg),
                    (retroactivo)=(w_retroactivo)
                where rowid = w_rowid;
          end if
       end if
       --- Si es fin de mes y existen dias inhabiles del sig. mes
       --- crea interes por Sig. mes con acumulado de dias AMP 28/10/94
       if sw = "1" and w_cant_dias_sig > 0 then
          let v_pridiasigmes = vf_prox_fecha - 1 units day;
          insert into sc_histsbg
             values (pempresa,v_sucursal, pcuenta,v_pridiasigmes,v_tipo_sbg,
             v_cta_en_legal, 0, v_num_cte,0,0,0,
             v_imp_chq_sbg, v_dispon_sbg,0,v_int_sbg_sigmes,
             wtasa_sigmes,w_cant_dias_sig," ");
       end if
    end if;

    --- Actualiza Maestro de Cheques
    update sc_maechq
       set (imp_int_ccc) = (v_imp_int_ccc),
           (imp_int_sbg) = (v_imp_int_sbg)
       where empresa = pempresa and cuenta = pcuenta;
    update sc_maenoc
       set (acum_ccc) = (v_acum_ccc),
           (dias_ccc) = (v_dias_ccc)
       where empresa = pempresa and cuenta = pcuenta;
return vcodret;
end
end procedure;