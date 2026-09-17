create procedure "informix".devotrobco(pempresa char(3),
                         psucursal char(4),
                         pusuario char(8),
                         ptransacc char(4),
                         pfolio char(16),
                         pcuenta char(20),
                         pnro_docto integer,
                         pcausa_dev char(2),
                         pimporte money(14,2),
                         pbanco char(4),
			 pmoneda char(2))
returning char(5);

define vcodret char(5);
define vfecha_hoy date;
define vstatus_cta char(1);
define vproducto,vtrancapchq,vtrancancta,vtrancanprov char(4);
define vsqlerr integer;
define vtotcanc,vsdo_retenido,vintprov,vsdodisp,vmontoret money(14,2);
define vreferencia char(40);
define vsuccta char(4);
define vplaza char(3);
define vcapital money(14,2);
define vmensaje char(50);
define vsolbcos integer;
define vcta_cheques,vnum_cte char(20);
define vsecuencia smallint;
define vsistema char(2);
define vbanco smallint;



let vcodret = "000";

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
	 let vcodret = vsqlerr;
	 return vcodret;
      end if;
   end exception;

if psucursal = " " or pusuario = " " or pfolio = " " or pcuenta = " " or
   pimporte = 0 or pbanco = " " then
   let vcodret = "110";
   return vcodret;
end if;

select fecha_hoy into vfecha_hoy
   from sv_fechas
   where empresa = pempresa;

---- Valida que Exista la Cuenta
select status_cta,sucursal,plaza,cod_instrum,capital,secuencia
   into vstatus_cta,vsuccta,vplaza,vproducto,vcapital,vsecuencia
   from sv_maeinv
   where empresa = pempresa and cuenta = pcuenta and status_cta <> "4";

if vstatus_cta is null then
   let vcodret = "100";
   return vcodret;
end if;

---- Valida que la Cuenta no Este Cancelada
if vstatus_cta = "2" then
   let vcodret = "200";
   return vcodret;
end if;

--- Libera el documento, si es que esta retenido
let vbanco = pbanco;
foreach
   select referencia into vreferencia
      from bdicheq:sc_docret_sbc     --MOHA
      where empresa = pempresa and cuenta = pcuenta and
            banco = vbanco and
            num_chq = pnro_docto and
            monto_ori = pimporte and
            cancelado <> "S"
   call bdicheq:diasretcta(pempresa,pcuenta,pimporte,pnro_docto,
                           pbanco, pusuario) returning vcodret;
   exit foreach;
end foreach

insert into sv_movdia
   values(pempresa,0,pfolio,vplaza,psucursal,pusuario,vfecha_hoy,
          current hour to fraction(3),ptransacc,vsuccta,pcuenta,
          vsecuencia,vproducto,0,pimporte,pimporte,0,0," ",vcapital,"0000");

update sv_maeinstrucc
   set importe = importe - pimporte
   where cuenta = pcuenta and cap_int = "C";

select sdo_retenido,sdo_mes_ant,num_cte
   into vsdo_retenido,vintprov,vnum_cte
   from sv_maeinv
   where empresa = pempresa and cuenta = pcuenta and secuencia = vsecuencia;

if vsdo_retenido = 0 then
   select valor into vtrancancta
      from sv_param
      where empresa = pempresa and codparam = "trancancta";
   select valor into vtrancanprov
      from sv_param
      where empresa = pempresa and codparam = "trancanprov";
   select importe,cta_cheques,sistema
      into vtotcanc,vcta_cheques,vsistema
      from sv_maeinstrucc
      where empresa = pempresa and cuenta = pcuenta and cap_int = "C" and
            aplicado = "N";
   if vtotcanc is null then
      let vtotcanc = 0;
   end if
   if vtotcanc > 0 then
      let vreferencia = "CANCELACION DE CERTIFICADO " || pcuenta ||
                        " POR DEVOLUCION DE CHEQUE";
      select valor into vtrancapchq
         from sv_param
         where empresa = pempresa and codparam = "trancapchq";
      if vsistema = "01" then
         call abono_ref(pempresa,psucursal,pusuario,vtrancapchq,"0000",
              pfolio,vcta_cheques,0,vtotcanc,vtotcanc,0,0,0,pmoneda,
              vreferencia) returning vcodret;
      end if
      if vcodret <> "000" or vsistema <> "01" then
         call bdibanco:sbsp_graba_solchq(pempresa,vnum_cte,pusuario,
              vtotcanc,pcuenta) returning vcodret,vmensaje,vsolbcos;
      end if
      insert into sv_movdia
         values(pempresa,0,pfolio,vplaza,psucursal,pusuario,vfecha_hoy,
            current hour to fraction(3),vtrancancta,vsuccta,pcuenta,
            vsecuencia,vproducto,0,vtotcanc,vtotcanc,0,0," ",vcapital,"0000");
   end if
   if vintprov > 0 then
      insert into sv_movdia
         values(pempresa,0,pfolio,vplaza,psucursal,pusuario,vfecha_hoy,
            current hour to fraction(3),vtrancanprov,vsuccta,pcuenta,
            vsecuencia,vproducto,0,vintprov,vintprov,0,0," ",vcapital,"0000");
   end if
   -- Actualiza el Maestro de Inversiones
   update sv_maeinv
      set status_cta   = "2",
          fec_cancelac = vfecha_hoy,
          modificado   = pusuario,
          fecha_mod    = vfecha_hoy
      where empresa = pempresa and cuenta = pcuenta and
            secuencia = vsecuencia;
end if
return vcodret;
end
end procedure;