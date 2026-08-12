create procedure "informix".dias_retesp(pempresa char(3),
                                     pcuenta  char(20),
                                     pimporte money(14,2))
       returning char(5);
define vcuenta,vcta_cheques,vnum_cte char (20);
define vreferencia char(40);
define vdias_ret smallint;
define sql_err,vrowid integer;
define vcodret char (5);
define vplaza char(3);
define vsuccta,vsucursal char(4);
define vusuario char(8);
define vfecha_alta,vfechoy date;
define vfecha date;
define vcancelado char(1);
define vproducto,vtrandepsbc,vtranret,vtranlibsbc,vtransuc,
       vtrancancta,vtrancanprov,vtrancapchq char(4);
define vsdo_actual,vmonto,vimpliberar,vimpmaxlib,vsdo_retenido,
       vcapital,vsdodisp,vmontoret,vtotcanc,vintprov money(14,2);
define vfolsuc char(16);
define vdocto,vsolbcos integer;
define horax datetime hour to fraction(3);
define vcero smallint;
define vsecuencia,vdias_ori,vdifdias smallint;
define vexiste,vabierto,vstatus char(1);
define vmoneda,vsiglas,vsistema char(2);
define vmensaje char(80);
define vfecha_operacion date;

let vabierto = "0";
let vtransuc = "0000";
let vdocto   = 0;
let vcodret  = "000";
let vcero    = 0;
let vfecha_operacion = TODAY;

begin
   on exception set sql_err
      if sql_err <> 0 then
         let vcodret = sql_err;
         if vabierto = "1" then
            rollback work;
         end if;
         return vcodret;
      end if;
   end exception;

   select fecha_hoy into vfecha from sc_fechas where empresa = pempresa;

   select ejecutivo into vusuario
      from bdinteg:si_ejecut
      where ejecutivo = user;

   select valor into vtranlibsbc
      from sc_param
      where empresa = pempresa and codparam = "tranlibsbc";

let vabierto = "1";
foreach
   select rowid,cuenta,dias_ret,monto,folio_suc,cancelado,
          referencia,sucursal,num_chq,dias_ori,transacc,siglas
      into vrowid,vcuenta,vdias_ret,vmonto,vfolsuc,vcancelado,
           vreferencia,vsucursal,vdocto,vdias_ori,vtrandepsbc,vsiglas
      from sc_docret
      where empresa = pempresa and cancelado <> "S" and fecha_alta < vfecha
            and cuenta = pcuenta and monto = pimporte
      order by cuenta,dias_ret asc
      let vimpliberar = vmonto;
      let vstatus = "S";
      if vsiglas = "SC" then
         select mc.sucursal,mc.producto,sdo_actual
            into vsuccta,vproducto,vsdo_actual
            from sc_maechq mc,sc_producto pr
            where mc.empresa = pempresa and mc.cuenta = vcuenta
                  and pr.empresa = mc.empresa and pr.producto = mc.producto;
         insert into sc_movdia
            values(0,vfolsuc,vsucursal,vusuario,vfecha,vfecha,
            current hour to fraction(3),vtranlibsbc,vsuccta,vproducto,
                pempresa,vcuenta," ",vdocto,vimpliberar,vimpliberar,vcero,
                vcero,vcero," "," ",vsdo_actual,vtransuc,vreferencia,vcero,"","","",vfecha_operacion);
         update sc_maechq
         set sdo_retenido = sdo_retenido - vimpliberar
            where empresa = pempresa and cuenta = vcuenta;
      else
         select mv.sucursal,mv.cod_instrum,capital,plaza,secuencia,
                sdo_retenido,sdo_mes_ant,num_cte,moneda,capital
            into vsuccta,vproducto,vsdo_actual,vplaza,vsecuencia,
                vsdo_retenido,vintprov,vnum_cte,vmoneda,vcapital
            from bdinvers:sv_maeinv mv,bdinvers:sv_instrum pr
            where mv.empresa = pempresa and mv.cuenta = vcuenta and
                  pr.empresa = mv.empresa and
                  pr.cod_instrum = mv.cod_instrum and status_cta <> "4";
         insert into bdinvers:sv_movdia
            values(pempresa,0,vfolsuc,vplaza,vsucursal,vusuario,vfecha,
             current hour to fraction(3),vtranlibsbc,vsuccta,vcuenta,
                   vsecuencia,
                   vproducto,vcero,vimpliberar,vimpliberar,vcero,vcero," ",
                   vsdo_actual,vtransuc);
         update bdinvers:sv_maeinv
            set sdo_retenido = sdo_retenido - vimpliberar
            where empresa = pempresa and cuenta = vcuenta and
                  secuencia = vsecuencia;
         if vsdo_retenido = vimpliberar then
            select valor into vtrancancta
               from bdinvers:sv_param
               where empresa = pempresa and codparam = "trancancta";
            select valor into vtrancanprov
               from bdinvers:sv_param
               where empresa = pempresa and codparam = "trancanprov";
            select importe,cta_cheques,sistema
               into vtotcanc,vcta_cheques,vsistema
               from bdinvers:sv_maeinstrucc
               where empresa = pempresa and cuenta = vcuenta and
                     cap_int = "C" and  aplicado = "N";
            if vtotcanc is null then
               let vtotcanc = 0;
            end if
            if vtotcanc > 0 then
               let vreferencia = "CANCELACION DE CERTIFICADO " || vcuenta ||
                                 " POR DEVOLUCION DE CHEQUE";
              select valor into vtrancapchq
                  from bdinvers:sv_param
                  where empresa = pempresa and codparam = "trancapchq";
               if vsistema = "01" then
                  call abono_ref(pempresa,vsucursal,vusuario,vtrancapchq,
                       "0000",vfolsuc,vcta_cheques,0,vtotcanc,vtotcanc,0,0,
                       0,vmoneda,vreferencia) returning vcodret;
               end if
               if vcodret <> "000" or vsistema <> "01" then
                  call bdibanco:sbsp_graba_solchq(pempresa,vnum_cte,vusuario,
                       vtotcanc,vcuenta) returning vcodret,vmensaje,vsolbcos;
               end if
               insert into bdinvers:sv_movdia
                  values(pempresa,0,vfolsuc,vplaza,vsucursal,vusuario,
                         vfecha,current hour to fraction(3),vtrancancta,
                         vsuccta,vcuenta,
                         vsecuencia,
                         vproducto,0,vtotcanc,vtotcanc,0,0,
                         " ",vcapital,"0000");
            end if
            if vintprov > 0 then
               insert into bdinvers:sv_movdia
                  values(pempresa,0,vfolsuc,vplaza,vsucursal,vusuario,
                         vfecha,current hour to fraction(3),vtrancanprov,
                         vsuccta,vcuenta,
                         vsecuencia,
                         vproducto,0,vintprov,vintprov,0,0,
                         " ",vcapital,"0000");
            end if
            -- Actualiza el Maestro de Inversiones
            update bdinvers:sv_maeinv
               set status_cta   = "2",
                   fec_cancelac = vfecha,
                   modificado   = vusuario,
                   fecha_mod    = vfecha
               where empresa = pempresa and cuenta = vcuenta and
                     secuencia = vsecuencia;
         end if
      end if
      update sc_docret
         set cancelado = vstatus,
             monto = monto - vimpliberar
         where rowid = vrowid;
      exit foreach;
end foreach
return vcodret;
end
end procedure;