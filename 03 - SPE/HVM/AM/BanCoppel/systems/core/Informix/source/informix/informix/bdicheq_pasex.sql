create procedure "informix".pasex(pempresa char(3),
                                         pfecha date)
       returning char(5);

define vcodret char(5);
define vfecha_hoy date;
define vsqlerr integer;
define vregopero      char(3);
define vproducto      char(4);
define vmoneda        char(2);
define vtransacc      char(4);
define vmonto_tot     money(14,2);
define vexento_isr    char(1);
define vsector        char(2);
define vvaloriza      char(1);
define vcancelad      char(1);
define vtasa_bruta    decimal(9,6);
define vsobretasa     decimal(9,6);
define vsuc_cuen      char(3);
define wapell_paterno char(15);
define wapell_materno char(15);
define wnombre1       char(15);
define wnombre2       char(15);
define wrazon_social  char(40);
define wabreviatura   char(20);
define wdescripcion   char(30);
define vfechaproc     date;
define vporcentaje decimal(9,6);
define vtpcambval  decimal(14,6);
define vmonto1, vmonto2 money(14,2);
define vdivisa_cambio char(2);
define vtasa_base_isr_pf decimal(9,6);
define vcodigo_mn char(2);
define vtransacc_t1,vtranprovint char(4);
define vcobraisr char(1);

-- Inicializa variables
let vcodret       = "000";


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

let vfecha_hoy = pfecha;

delete from sc_contab;
delete from aux_auditerr;
delete from aux_contab;

-- Extrae tasa base para el calculo de tasa exenta y param de T+1
select valor into vdivisa_cambio
   from bdinteg:si_param
   where empresa = pempresa and descripcion = "divisa cambio";

select valor into vtasa_base_isr_pf
   from bdinteg:si_param
   where empresa = pempresa and descripcion = "tasa base isr pf";

select valor into vcodigo_mn
   from bdinteg:si_param
   where empresa = pempresa and descripcion = "codigo mn";

select valor into vtransacc_t1
   from sc_param
   where empresa = pempresa and codparam = "tranlibsbc";

select valor into vtranprovint
   from sc_param
   where empresa = pempresa and codparam = "tranprov";

--Extrae tipo de cambio valorizado
select precio_venta into vtpcambval
   from bdinteg:si_tpcambio
   where empresa = pempresa and divisa = vdivisa_cambio and
         fecha_tpcambio = vfecha_hoy and
         clase_tpcambio = "O";
if vtpcambval is null then
   select precio_venta into vtpcambval
      from bdinteg:si_histdiv
      where empresa = pempresa and divisa = vdivisa_cambio and
            fecha_tc = vfecha_hoy
            and clase_tpcambio = "O";
   if vtpcambval is null then
      let vtpcambval = 1;
   end if
end if

foreach
   select regional,md.producto,divisa,transacc,
          monto_tot,exento_isr, cl.sector,
          tr.valoriza,cancelad,tasa_bruta,
          ac.sobretasa, mc.sucursal,
          apell_paterno,apell_materno,nombre1,nombre2,
          razon_social,abreviatura,mc.cobraisr
       into vregopero,vproducto,vmoneda,vtransacc,vmonto_tot,
          vexento_isr,vsector,vvaloriza,vcancelad,vtasa_bruta,
          vsobretasa,vsuc_cuen,wapell_paterno,wapell_materno,
          wnombre1,wnombre2,wrazon_social,wabreviatura,vcobraisr
     from sc_movhis md,sc_maechq mc,outer sc_auxcont ac,sc_producto pr,
	  bdinteg:si_transacc tr, bdinteg:si_cliente cl,
          bdinteg:si_tipper tp,bdinteg:si_sucursales su,bdinteg:si_plazas pl
     where md.empresa = pempresa and md.fech_alt = vfecha_hoy and
          mc.empresa = md.empresa and mc.cuenta = md.cuenta and
          ac.empresa = md.empresa and ac.cuenta = md.cuenta and
	  pr.empresa = md.empresa and pr.producto = md.producto and
          tr.empresa = md.empresa and tr.numero = md.transacc and
          cl.numcte = mc.num_cte and tp.tpo_persona = cl.tpo_persona and
          su.empresa = md.empresa and su.sucursal = md.sucursal and
	  pl.empresa = md.empresa and pl.plaza = su.plaza and
	  md.cancelad <> "S" and
          transacc not in(vtransacc_t1,"0231","0232","3313","3314") and
	  tr.se_contabiliza = "S" and
	  md.fech_alt = pfecha
          and md.transacc = "0207"
     union all
     select md.sucursal,ma.producto,divisa,transacc,monto_tot,"N",
	    cl.sector,tr.valoriza,md.cancelad,0,0,ma.sucursal,
            cl.apell_paterno,cl.apell_materno,cl.nombre1,cl.nombre2,
            cl.razon_social,tr.abreviatura,ma.cobraisr
	from sc_movhis md,sc_maechq ma,bdinteg:si_sucursales su,
	     sc_producto pr,bdinteg:si_cliente cl,
             bdinteg:si_transacc tr
        where md.empresa = pempresa and md.fech_alt = vfecha_hoy and
              ma.empresa = md.empresa and ma.cuenta = md.cuenta and
              su.empresa = md.empresa and su.sucursal = ma.sucursal and
	      pr.empresa = md.empresa and pr.producto = md.producto and
	      numcte = num_cte and
              tr.empresa = md.empresa and tr.numero = md.transacc and
              transacc in(vtransacc_t1,"0231","0232","3313","3314") and
              tr.se_contabiliza = "S" and
	      md.fech_alt = pfecha
              and md.transacc="0207"
     order by 12,2,4

    let vtransacc = vtransacc;
    let vcancelad = vcancelad;

     let wdescripcion = " ";
     if (wrazon_social = " " OR wrazon_social IS NULL) then
        let wdescripcion = wapell_paterno[1,5]||" "||
                           wapell_materno[1,1]||" "||
                           wnombre1[1,5]||" "||wabreviatura[1,15];
     else
        let wdescripcion = wrazon_social[1,14]||" "||wabreviatura;
     end if;

     if vcobraisr <> "" then
        if vcobraisr = "S" then
           let vexento_isr = "N";
        else
           let vexento_isr = "S";
        end if
     end if

     -- Verifica si es Transaccion de provision de Interes
     if vtransacc = vtranprovint then
        let vtasa_bruta = vtasa_bruta + vsobretasa;
        -- Verifica si la tasa a pagar es MAYOR a la tasa base
        if vtasa_bruta > vtasa_base_isr_pf then
           -- Si no se trata de exento de ISR
           if vexento_isr = "N" then
	      if vmoneda = vcodigo_mn then
	         let vporcentaje = vtasa_base_isr_pf*100/vtasa_bruta;
	         let vmonto1 = vmonto_tot * vporcentaje / 100;
	         let vmonto2 = vmonto_tot - vmonto1;
	         call extrae_cont(pempresa,1,vmonto1,vregopero,vproducto,
                      vmoneda,vtransacc,vsector,vcancelad,
		      vsuc_cuen,wdescripcion) returning vcodret;
	         call extrae_cont(pempresa,2,vmonto2,vregopero,vproducto,
                      vmoneda,vtransacc,vsector,vcancelad,
		      vsuc_cuen,wdescripcion) returning vcodret;
                 continue foreach;
	      end if
	      if vmoneda != vcodigo_mn and vvaloriza = "S" then
	         call extrae_cont(pempresa,1,vmonto_tot,vregopero,vproducto,
                      vmoneda,vtransacc,vsector,vcancelad,
		      vsuc_cuen, wdescripcion) returning vcodret;
	         let vporcentaje = vtasa_base_isr_pf*100/vtasa_bruta;
	         let vmonto1 = vmonto_tot * vporcentaje / 100;
	         let vmonto2 = vmonto_tot - vmonto1;
                 let vmonto1 = vmonto1 * vtpcambval;
	         call extrae_cont(pempresa,3,vmonto1,vregopero,vproducto,
                      vmoneda,vtransacc,vsector,vcancelad,
		      vsuc_cuen,wdescripcion) returning vcodret;
                 let vmonto2 = vmonto2 * vtpcambval;
	         call extrae_cont(pempresa,4,vmonto2,vregopero,vproducto,
                      vcodigo_mn,vtransacc,vsector,
                      vcancelad,vsuc_cuen,wdescripcion) returning vcodret;
                 continue foreach;
	      end if
           else -- exento de ISR y tasa bruta > tasa base
	      if vmoneda = vcodigo_mn then
	         call extrae_cont(pempresa,2,vmonto_tot,vregopero,vproducto,
                      vmoneda,vtransacc,vsector,vcancelad,
		      vsuc_cuen, wdescripcion) returning vcodret;
                 continue foreach;
	      end if
	      if vmoneda != vcodigo_mn and vvaloriza = "S" then
	         call extrae_cont(pempresa,1,vmonto_tot,vregopero,vproducto,
                      vmoneda,vtransacc,vsector,vcancelad,
		      vsuc_cuen, wdescripcion) returning vcodret;
                 let vmonto2 = vmonto_tot * vtpcambval;
	         call extrae_cont(pempresa,3,vmonto2,vregopero,vproducto,
                      vcodigo_mn,vtransacc,vsector,
                      vcancelad,vsuc_cuen,wdescripcion) returning vcodret;
                 continue foreach;
	      end if
	   end if
        else
           if vmoneda = vcodigo_mn then
	      call extrae_cont(pempresa,1,vmonto_tot,vregopero,vproducto,
                   vmoneda,vtransacc,vsector,vcancelad,
		   vsuc_cuen,wdescripcion) returning vcodret;
	      continue foreach;
	   end if
	   if vmoneda != vcodigo_mn and vvaloriza = "S" then
	      call extrae_cont(pempresa,1,vmonto_tot,vregopero,vproducto,
                   vmoneda,vtransacc,vsector,vcancelad,
		   vsuc_cuen,wdescripcion) returning vcodret;
              let vmonto2 = vmonto_tot * vtpcambval;
	      call extrae_cont(pempresa,3,vmonto2,vregopero,vproducto,
                   vcodigo_mn,vtransacc,vsector,vcancelad,
		   vsuc_cuen, wdescripcion) returning vcodret;
                   continue foreach;
	   end if
        end if
     end if

     -- Verifica si es movimiento valorizado
     if vmoneda <> vcodigo_mn and vvaloriza = "S"  then
        let vmonto2 = vmonto_tot * vtpcambval;
	call extrae_cont(pempresa,3,vmonto2,vregopero,vproducto,
             vcodigo_mn,vtransacc,vsector,vcancelad,
	     vsuc_cuen,wdescripcion) returning vcodret;
     end if
     if vtransacc <> "0231" and vtransacc <> "0232" and
        vtransacc <> "3313" and vtransacc <> "3314" and
        vtransacc <> vtransacc_t1 then
        call extrae_cont(pempresa,1,vmonto_tot,vregopero,vproducto,
             vmoneda,vtransacc,vsector,vcancelad,
	     vsuc_cuen,wdescripcion)  returning vcodret;
     end if
     --- Contabiliza Camara,231,232,3246
     if vtransacc = "0231" or vtransacc = "0232" or
        vtransacc = "3313" or vtransacc = "3314" or
        vtransacc = vtransacc_t1 then
        call extrae_cont(pempresa,1,vmonto_tot,vregopero,vproducto,
             vmoneda,vtransacc,vsector,vcancelad,
	     vregopero,wdescripcion)  returning vcodret;
        if vtransacc = vtransacc_t1 then
           call extrae_cont(pempresa,2,vmonto_tot,vregopero,vproducto,
                vmoneda,vtransacc,vsector,vcancelad,
		vregopero,wdescripcion) returning vcodret;
        end if
     end if
  end foreach
  insert into sc_contab
      select secuencia,sucursal,empresa,ccmayor,ccsub,ccsubsub,
	 ccssubsub,ccsssubsub,sector,auxiliar,tot_cargo,
	 tot_abono,moneda,descripcion from aux_contab;
  -- Auditor contable
  call auditor(pempresa) returning vcodret;
  if vcodret = "000" then
     call pasecont(pempresa,vfecha_hoy) returning vcodret;
     if vcodret = "000" then
--        update sc_contproc
--           set fecha = vfecha_hoy
--           where empresa = pempresa and proceso = "pase";
     end if
  end if
  return vcodret;
end
end procedure;