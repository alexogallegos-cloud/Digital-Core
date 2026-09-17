create procedure "informix".abono(pempresa   char(3),
                                      psucursal  char(4),
                                      pusuario   char(8),
                                      ptransacc  char(4),
                                      ptransuc   char(4),
                                      pfolio_suc char(16),
                                      pcuenta    char(20),
                                      pdocto     integer,
                                      pmto_tot   money(14,2),
                                      pmto_firme money(14,2),
                                      pmto_sbc   money(14,2),
                                      pmto_rem   money(14,2),
                                      pdias_ret  smallint,
                                      pdivisa    char(2))
   returning char(5);

   define vcodret char(5);
   define vsqlerr integer;
   define vsuccta char(4);
   define vproducto char(4);
   define vgencom,vcobracom,vvaldoc,vnat,vstatus,vaceptab char(1);
   define vmotivo  char(2);
   define vmoneda char(2);
   define vmontotran,vsdo_actual,vimpsbg,
          vtotal_sbc,vdepinic money(14,2);
   define vfecha_hoy,vfecha_prox date;
   define vhora datetime hour to fraction(3);
   define vusuario char(8);
   define vtasa_aplicada decimal(9,6);
   define vmarca_ret char(1);
   define vdepinicial,vmtominape,vdepminini money(14,2);
   define vacepta_depositos,vper_depositos char(1);
   define vdiasultdep,vdiasdep smallint;
   define vfecultmov,vfecultdep,vfecultret date;
   define vtranpagint,vtranusoccc,vtranusosbg,vtranabocol char(4);
   define preferencia char(30);
   define vfecha_operacion date;

   set isolation to cursor stability;
   set lock mode to wait 10;

   let vusuario = user;
   let preferencia = "";
   let vfecha_operacion = today;

   if vusuario = "cs2" then
      commit work;
      begin work;
   end if;

   let preferencia = " ";
   let vcodret = "000";
   let vtasa_aplicada = 0;
   let vgencom = 0;
   let vcobracom = "0";


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
       if vusuario = "cs2" then
          rollback work;
          begin work;
       end if;
       return vcodret;
      end if
   end exception;

-- Valida la informacion de entrada
if psucursal  = "" or
   pusuario   = "" or
   ptransacc  = "" or
   pfolio_suc = "" or
   pcuenta    = "" or
   pmto_tot   = 0     or
   pmto_firme < 0     or
   pmto_sbc   < 0     or
   pmto_rem   < 0     or
   pdias_ret  < 0 then
   let vcodret = 110;
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
 end if;

set isolation to dirty read;
select ejecutivo into vusuario
   from bdinteg:si_ejecut
   where ejecutivo = pusuario;
if vusuario <> pusuario or vusuario is null then
   let vcodret = "106";
   if vusuario = "cs2" then
       rollback work;
       begin work;
   end if;
   return vcodret;
end if

-- Valida la suma de los montos
let vmontotran = pmto_firme + pmto_sbc + pmto_rem;
if vmontotran != pmto_tot or pmto_tot =0 then
   let vcodret = "420";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if;

-- Valida exista la transaccion
set isolation to dirty read;
select naturaleza,valida_docto,dias_ret
   into vnat,vvaldoc,pdias_ret
   from bdinteg:si_transacc
   where empresa = pempresa and numero = ptransacc;
if vnat is null then
   let vcodret = "552";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if;
if vnat != "A" then
   let vcodret = "552";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if;
if pdias_ret is null then
   let pdias_ret = 0;
end if;

select fecha_hoy,prox_fecha into vfecha_hoy,vfecha_prox
   from sc_fechas where empresa = pempresa;

-- Valida exista la cuenta
select status_cta into vstatus
   from sc_maechq
   where empresa = pempresa and cuenta = pcuenta;
if vstatus is null then
   let vcodret = "100";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if
if vstatus = "2" then
   let vcodret = "200";
   if vusuario = "cs2" then
      rollback work;
      begin work;
   end if;
   return vcodret;
end if

-- Extrae los datos de la cuenta de cheques
set isolation to dirty read;
foreach abono_cursor for
   select status_cta,motivo,sucursal,producto,sdo_actual,marca_ret,
          fec_ult_mov,fecultdep,fecultret,imp_chq_sbg+imp_sbg_ccc
      into vstatus,vmotivo,vsuccta,vproducto,vsdo_actual,vmarca_ret,
          vfecultmov,vfecultdep,vfecultret,vimpsbg
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta

   set isolation to dirty read;
   select divisa,acepta_depositos,mtominape,
          per_depositos[1,1],per_depositos[3,5]
      into vmoneda,vacepta_depositos,vmtominape,
          vper_depositos,vdiasdep
      from sc_producto
      where empresa = pempresa and producto = vproducto;
   if vmoneda!= pdivisa then
      let vcodret="951";
      if vusuario = "cs2" then
         rollback work;
         begin work;
      end if;
      return vcodret;
   end if;

   if vmarca_ret = "0" then   -- deposito inicial
      let vdepinicial = vsdo_actual + pmto_tot;
      if vdepinicial > vmtominape then
         if vacepta_depositos = "N" then
            let vcodret="956";
            if vusuario = "cs2" then
               rollback work;
               begin work;
            end if;
            return vcodret;
         end if;
      end if
      if vdepinicial >= vmtominape then
         let vmarca_ret = "1";
      end if;
   else
      if vacepta_depositos = "N" then
         let vcodret="956";
         if vusuario = "cs2" then
            rollback work;
            begin work;
         end if;
         return vcodret;
      else
         let vdiasultdep = vfecha_hoy - vfecultdep;
         if vdiasultdep < vdiasdep then
            let vcodret="956";
            if vusuario = "cs2" then
               rollback work;
               begin work;
            end if;
            return vcodret;
         end if;
      end if;
   end if

   if vstatus = 3 then
        set isolation to dirty read;
        select abono into vaceptab
           from sc_bloqueo where codigo = vmotivo;
        if vaceptab = "N" then
           let vcodret = "301";
           if vusuario = "cs2" then
             rollback work;
             begin work;
           end if;
           return vcodret;
        end if;
   end if;

   let vhora = current hour to fraction;
   select 1 into vgencom
      from sc_transcomis
      where empresa = pempresa and transacc = ptransacc;
   if vgencom is null then
      let vgencom = 0;
      let vcobracom = "0";
   end if

   if pmto_sbc > 0 then
      select sum(monto) into vtotal_sbc
         from sc_docret
         where empresa = pempresa and cuenta = pcuenta and
               folio_suc = pfolio_suc and fecha_alta = vfecha_hoy and
               siglas = "SC";
      if vtotal_sbc <> pmto_sbc then
         let vcodret="401";
         if vusuario = "cs2" then
            rollback work;
            begin work;
         end if;
         return vcodret;
      end if;
   end if;

   insert into sc_movdia
      values(0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,
             vhora,ptransacc,vsuccta,vproducto,pempresa,pcuenta,"",0,
             pmto_tot,pmto_firme,pmto_sbc,pmto_rem,pdias_ret,"","",
             vsdo_actual,ptransuc,preferencia,vtasa_aplicada,"","","",vfecha_operacion);

   -- Actualizacion al Maestro de Cheques
   update sc_maechq
      set fec_ult_mov = vfecha_hoy,
          num_abonos_mes = num_abonos_mes + 1,
          imp_abonos_mes = imp_abonos_mes + pmto_tot,
          sdo_actual = sdo_actual + pmto_tot,
	  sdo_retenido = sdo_retenido + pmto_sbc,
	  saldo_sbc = saldo_sbc + pmto_sbc,
          marca_ret = vmarca_ret,
          fecultdep = vfecha_hoy
      where empresa = pempresa and cuenta = pcuenta;

   -- Genera comision por transaccion
   if vgencom = "1" then
      call gencomtran(pempresa,pcuenta,ptransacc,pmto_tot,pfolio_suc,
                      psucursal,pusuario)
           returning vcodret;
      let vcobracom = "1";
   end if

   select valor into vtranpagint
      from sc_param
      where empresa = pempresa and codparam = "tranpagint";

   select valor into vtranusoccc
      from sc_param
      where empresa = pempresa and codparam = "tranusoccc";

   select valor into vtranabocol
      from sc_param
      where empresa = pempresa and codparam = "tranabocol";

   select valor into vtranusosbg
      from sc_param
      where empresa = pempresa and codparam = "tranusosbg";
{
   -- Cobra comisiones pendientes
   if ptransacc = vtranpagint or ptransacc = vtranabocol or
      ptransacc = vtranusoccc or ptransacc = vtranusosbg then
      let vcobracom = "0";
   else
      if vimpsbg > 0 then
         let vcobracom = "1";
      end if
      if vcobracom = "0" then
         select unique 1 into vcobracom
            from sc_detcomis
            where empresa = pempresa and cuenta = pcuenta and estado_com = "P";
         if vcobracom is null then
            let vcobracom = "0";
         else
            let vcobracom = "1";
         end if
      end if
   end if
   if vcobracom = "1" then
      call cobintcomsbg(pempresa,pcuenta,pfolio_suc,pusuario,psucursal)
           returning vcodret;
   end if
}
end foreach;

if vusuario = "cs2" then
   if vcodret = "000" then
      commit work;
   else
      rollback work;
   end if
   begin work;
end if;

return vcodret;

end;

end procedure;