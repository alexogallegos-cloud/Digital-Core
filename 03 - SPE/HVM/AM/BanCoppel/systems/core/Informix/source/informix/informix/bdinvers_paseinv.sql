CREATE PROCEDURE "informix".paseinv(pempresa char(3))
       returning char(5);

DEFINE vcodret char(5);
DEFINE GLOBAL vfecha_hoy DATE DEFAULT TODAY;
DEFINE vsqlerr integer;
DEFINE vsucopero      char(4);
DEFINE vproducto      char(4);
DEFINE vmoneda        char(2);
DEFINE vtransacc      char(4);
DEFINE vmonto_tot     money(14,2);
DEFINE vexento_isr    char(1);
DEFINE vsector        char(10);
DEFINE vvaloriza      char(1);
DEFINE vcancelad      char(1);
DEFINE vtasa_bruta    decimal(9,6);
DEFINE vsobretasa     decimal(9,6);
DEFINE vsuc_cuen      char(4);
DEFINE wabreviatura   char(20);
DEFINE wdescripcion   char(30);
DEFINE vfechaproc     date;
DEFINE vporcentaje decimal(9,6);
DEFINE vtpcambval  decimal(14,6);
DEFINE vmonto1, vmonto2 money(14,2);
DEFINE vdivisa_cambio char(2);
DEFINE vcodigo_mn char(2);
DEFINE vtransacc_t1,vtranprovint char(4);
DEFINE vcobraisr char(1);
DEFINE vcuenta char(20);
DEFINE vplaza char(3);

-- Inicializa variables
let vcodret       = "000";



begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         UPDATE bdinteg:sx_contproc
            SET status_proc = 'C',
                hora_fin    = CURRENT,
                codret      = vcodret
          WHERE empresa = pEmpresa
            AND proceso  = 'PaseInv'
            AND fecha    = vfecha_hoy;

         return vcodret;
      end if;
   end exception;
   
	--set debug file to "paseinv.out";
	--trace on;
	
	set isolation to dirty read;
    set lock mode to wait 3;	

-- Asigna la fecha de hoy

select fecha_hoy into vfecha_hoy
   from sv_fechas
   where empresa = pempresa;

-- Verifica se haya efectuado el cierre
select fecha into vfechaproc
   from sv_contproc
   where empresa = pempresa and proceso = "cierreinv";
if vfechaproc <> vfecha_hoy then
   let vcodret = "962";
   return vcodret;
end if

-- Verifica no se haya efectuado el pase contable
select fecha into vfechaproc
   from sv_contproc
   where empresa = pempresa and proceso = "pase";
if vfechaproc = vfecha_hoy then
   UPDATE bdinteg:sx_contproc
      SET status_proc = 'I',
          hora_fin    = CURRENT,
          codret      = vcodret
    WHERE empresa = pEmpresa
      AND proceso  = 'PaseInv'
      AND fecha    = vfecha_hoy;
else
   INSERT INTO bdinteg:sx_contproc
    (empresa, proceso, fecha, sistema, status_proc,
     ejecutivo, hora_ini, hora_fin, codret)
   VALUES
    (pEmpresa, 'PaseInv', vfecha_hoy, '03', 'I',
     USER, CURRENT, NULL, '000');
end if

delete from sv_contab where empresa = pempresa;
delete from aux_auditerr;
delete from aux_contab;
DELETE from sv_suspenso where fecha_valida = vfecha_hoy;

-- Extrae tasa base para el calculo de tasa exenta y param de T+1
select valor into vdivisa_cambio
   from bdinteg:si_param
   where empresa = pempresa and descripcion = "divisa cambio";

select valor into vcodigo_mn
   from bdinteg:si_param
   where empresa = pempresa and descripcion = "codigo mn";

select trans_prov into vtranprovint
   from sv_instrum
   where empresa = pempresa
   group by 1;


--Extrae tipo de cambio valorizado
{select precio_venta into vtpcambval
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
end if}
LET vtpcambval =1;
foreach
     select md.sucursal,md.cod_instrum,moneda,transacc,
            monto_tot,exento_isr,cl.sector,
            valoriza,cancelad,tasa,sobretasa,suc_cuen,
            tr.abreviatura, mv.cobraisr,md.cuenta,md.plaza
        into vsucopero,vproducto,vmoneda,vtransacc,vmonto_tot,
            vexento_isr,vsector,vvaloriza,vcancelad,vtasa_bruta,
            vsobretasa,vsuc_cuen,wabreviatura,vcobraisr,vcuenta,vplaza
        from sv_movhis md,sv_maeinv mv,sv_instrum pr,
            bdinteg:si_transacc tr,bdinteg:si_cliente cl,bdinteg:si_tipper tp
        where md.empresa = pempresa and md.fech_alt = vfecha_hoy and
            md.cancelad <> "S" and mv.empresa = md.empresa and
            mv.cuenta = md.cuenta and mv.secuencia = md.secuencia and
            pr.empresa = md.empresa and pr.cod_instrum = md.cod_instrum and
            tr.empresa = md.empresa and md.transacc = tr.numero and
            mv.num_cte = cl.numcte and
            cl.tpo_persona = tp.tpo_persona and
            tr.se_contabiliza = "S" and
			tr.sistema = "03"

     if vcobraisr <> "" then
        if vcobraisr = "S" then
           let vexento_isr = "N";
        else
           let vexento_isr = "S";
        end if
     end if

     let wdescripcion = " ";

     -- Verifica si es Transaccion de provision de Interes
     if vtransacc = vtranprovint then
        let vtasa_bruta = vtasa_bruta + vsobretasa;
        -- Verifica si la tasa a pagar es MAYOR a la tasa base
        if vmoneda = vcodigo_mn then
           call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,
                   vmoneda,vtransacc,vsector,vcancelad,
		   vsuc_cuen,wdescripcion,vcuenta,vplaza) returning vcodret;
	   IF vcodret <> "000" THEN
	      RETURN vcodret;
	   END IF
           continue foreach;
        end if
	if vmoneda != vcodigo_mn and vvaloriza = "S" then
	   call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,
                   vmoneda,vtransacc,vsector,vcancelad,
		   vsuc_cuen,wdescripcion,vcuenta,vplaza) returning vcodret;
	   IF vcodret <> "000" THEN
	      RETURN vcodret;
	   END IF
           let vmonto2 = vmonto_tot * vtpcambval;
	   call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,
                   vcodigo_mn,vtransacc,vsector,vcancelad,
		   vsuc_cuen, wdescripcion,vcuenta,vplaza) returning vcodret;
	   IF vcodret <> "000" THEN
	      RETURN vcodret;
	   END IF
           continue foreach;
	end if
     end if

     -- Verifica si es movimiento valorizado
     if vmoneda <> vcodigo_mn and vvaloriza = "S"  then
        let vmonto2 = vmonto_tot * vtpcambval;
	call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,
             vcodigo_mn,vtransacc,vsector,vcancelad,
	     vsuc_cuen,wdescripcion,vcuenta,vplaza) returning vcodret;
	   IF vcodret <> "000" THEN
	      RETURN vcodret;
	   END IF
        continue foreach;
     end if
     call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,
          vmoneda,vtransacc,vsector,vcancelad,
          vsuc_cuen,wdescripcion,vcuenta,vplaza) returning vcodret;
	   IF vcodret <> "000" THEN
	      RETURN vcodret;
	   END IF
  end foreach
  insert into sv_contab
      select empresa,secuencia,sucursal,succta,ccmayor,ccsub,ccsubsub,
	 ccssubsub,ccsssubsub,sector,auxiliar,tot_cargo,
	 tot_abono,moneda,descripcion from aux_contab;
  -- Auditor contable
  call auditor(pempresa) returning vcodret;
  if vcodret = "000" then
     call pasecont(pempresa,vfecha_hoy,vfecha_hoy,'') returning vcodret;
	 
     if vcodret = "000" then
        update sv_contproc
           set fecha = vfecha_hoy
           where empresa = pempresa and proceso = "pase";

         UPDATE bdinteg:sx_contproc
            SET status_proc = 'F',
                hora_fin    = CURRENT,
                codret      = vcodret
          WHERE empresa = pEmpresa
            AND proceso  = 'PaseInv'
            AND fecha    = vfecha_hoy;

    end if
  end if
  
   if vcodret = "000" then
		CALL "informix".sp_integra_suspenso ('001','03',vfecha_hoy) RETURNING vcodret;
   end if
   
  return vcodret;
end
end procedure;