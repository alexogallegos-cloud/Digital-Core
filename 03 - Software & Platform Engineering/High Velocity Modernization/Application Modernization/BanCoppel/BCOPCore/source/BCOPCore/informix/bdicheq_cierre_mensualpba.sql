create procedure "informix".cierre_mensualpba(pempresa char(3),
                                           pdias smallint,
					   pcuenta char(20))
       returning char(5);

   define global vgfecha_hoy      date         default " ";
   define global vgfecha_pago     date         default " ";
   define global vgusuario        char(8)      default " ";
   define global vgpri_hab_mes    date         default " ";
   define global vgult_hab_mes    date         default " ";
   define global vgcuenta         char(20)     default " ";
   define global vgsucursal       char(4)      default " ";
   define global vgsdo_actual     money(14,2)  default 0;
   define global vgacum_sdo_pos   money(14,2)  default 0;
   define global vgdia_sdo_pos    smallint     default 0;
   define global vgproducto       char(4)      default " ";
   define global vgstatus_cta     char(1)      default " ";
   define global vgpaga_interes   char(1)      default " ";
   define global vgmto_pag_int    money(14,2)  default 0;
   define global vgtasa           char(8)      default " ";
   define global vgsobretasa      decimal(9,6) default 0;
   define global vgtp_moneda      char(2)      default " ";
   define global vges_fisica      char(1)      default " ";
   define global vgexento_isr     char(1)      default " ";
   define global vgtipo_dias_calc char(1)      default " ";
   define global vgpago_interes   char(1)      default " ";
   define global vgtipo_anio_calc char(1)      default " ";
   define global vgnum_cte        char(20)     default " ";
   define global vgfecha_alta     date         default "";
   DEFINE GLOBAL vgTasaVar        CHAR(1)      DEFAULT "";
   DEFINE GLOBAL vgFechaProc      DATE         DEFAULT "";
   DEFINE GLOBAL vgacum_sdo_int   MONEY(14,2)  DEFAULT 0;
   DEFINE GLOBAL vgProdCreciente CHAR(4) DEFAULT " ";
   DEFINE GLOBAL vgint_acum      DECIMAL(14,2) DEFAULT 0;
   DEFINE GLOBAL vgsdo_disp      DECIMAL(14,2) DEFAULT 0;


   define vsdo_prom,
	  vsdo_cong,
	  vsdo_retenido   money(14,2);
   define vcodret         char(5);
   define vsqlerr         integer;
   define vregproc        smallint;
   define vfecha          datetime year to month;
   define vsecuencia      smallint;
   define vcobraisr,
	  vexiste,
	  vclase_cta      char(1);
   define viva            decimal(9,6);
   define vultpagoint     date;
   define vfolio_suc      char(16);
   define vhora           datetime hour to fraction;
   define vhoraw          char(15);
   define vcom_pendiente,
	  vacum_ccc,
	  vacum_rem,
	  vacum_sbc,
	  vmonto_dev      money(14,2);
   define vchq_exp_mes,
	  vdias_ccc,
	  vchq_dev        smallint;
   define vcta_en_legal   char(1);
   define vnum_cgos_mes,
	  vnum_abonos_mes integer;
   define vfecpagoint     datetime month to day;
   define vcobrasegf      char(1);
   define vcuenta         char(20);
   define vstatus_cta     char(1);
   DEFINE isam_err        SMALLINT;
   DEFINE error_info      CHAR(40);

   let vcodret = "000";



begin
   on exception set vsqlerr, isam_err, error_info
      SET DEBUG FILE TO "cierremensual.err";
      TRACE ON;

      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

   select count(*) into vregproc from sc_maechq
      where empresa = pempresa and status_cta in("9","8");

   let vfecha = vgfecha_hoy;
   let vsecuencia = month(vgfecha_hoy);

   {if vregproc = 0 or vregproc is null then
      delete from sc_isr
         where empresa = pempresa and cuenta = pcuenta
         and secuencia = vsecuencia;
      delete from sc_salpro
         where empresa = pempresa and cuenta = pcuenta
         and fecha = vfecha;
   end if}

   --foreach

      select mc.cuenta,       mc.num_cte,       mc.sucursal,
	     acum_sdo_pos,    dia_sdo_pos,      status_cta,       
	     pr.paga_interes, tasa,             sobretasa,   
	     divisa,          es_fisica,        exento_isr,
             tipo_dias_calc,  pago_interes,     tipo_anio_calc, 
	     mto_pag_int,     mc.producto,      dias_ccc, 
             acum_ccc,        sdo_actual,       sdo_cong,
             sdo_retenido,    acum_sbc,         acum_rem,
             chq_exp_mes,     chq_dev,          num_cgos_mes,
	     num_abonos_mes,  mc.ultpagoint,    clase_cta, 
             cta_en_legal,    monto_dev,        mc.cobraisr,
	     fecpagoint,      mn.fecha_alta,    pr.paga_dividendo,
	     mc.fecha_proceso, acum_sdo_int,    int_acum
        into vgcuenta,        vgnum_cte,        vgsucursal,
	     vgacum_sdo_pos,  vgdia_sdo_pos,    vgstatus_cta,
	     vgpaga_interes,  vgtasa,           vgsobretasa,
             vgtp_moneda,     vges_fisica,      vgexento_isr,
	     vgtipo_dias_calc,vgpago_interes,   vgtipo_anio_calc,
	     vgmto_pag_int,   vgproducto,       vdias_ccc,
	     vacum_ccc,       vgsdo_actual,     vsdo_cong,
             vsdo_retenido,   vacum_sbc,        vacum_rem,
	     vchq_exp_mes,    vchq_dev,         vnum_cgos_mes,
	     vnum_abonos_mes, vultpagoint,      vclase_cta,
             vcta_en_legal,   vmonto_dev,       vcobraisr,
	     vfecpagoint,     vgfecha_alta,     vgTasaVar,
	     vgFechaProc,     vgacum_sdo_int,   vgint_acum
        from sc_maechq mc, sc_maenoc mn, sc_producto pr,
             bdinteg:si_cliente cl,bdinteg:si_tipper tp
       where mc.empresa = pempresa 
	 and mc.cuenta = pcuenta
         and status_cta not in("0","2","8","9")
         and mc.empresa = mn.empresa 
	 and mc.cuenta = mn.cuenta
         and pr.empresa = mc.empresa 
	 and pr.producto = mc.producto
         and cl.numcte = mc.num_cte 
	 and tp.tpo_persona = cl.tpo_persona;

      if vcobraisr <> "" then
         if vcobraisr = "S" then
            let vgexento_isr = "N";
         else
            let vgexento_isr = "S";
         end if
      end if

      if vgpaga_interes is null then
         let vgpaga_interes = "N";
      end if

      if vgmto_pag_int is null then
         let vgmto_pag_int = 0;
      end if

      if vfecpagoint = "" or vfecpagoint is null then
         let vgfecha_pago = "";
      else
         let vgfecha_pago = mdy(month(vfecpagoint),day(vfecpagoint),
                                year(vgfecha_hoy));
         if vgfecha_pago <= vultpagoint then
            let vgfecha_pago = vgfecha_pago + 1 units year;
         end if
      end if

      let vgsdo_disp = vgsdo_actual - vsdo_cong - vsdo_retenido;
      let vgdia_sdo_pos = vgdia_sdo_pos + pdias;
      if vgdia_sdo_pos > 0 then
         let vsdo_prom = (vgacum_sdo_pos + vgsdo_actual * pdias) /
                          vgdia_sdo_pos;
         let vgacum_sdo_pos = vgacum_sdo_pos + vgsdo_actual * pdias;
      else
         let vsdo_prom = 0;
      end if

      if vgpaga_interes = "S" then
         call calcula_int(pempresa,pdias,vsdo_prom) returning vcodret;
	 IF vcodret <> "000" THEN
         	return vcodret;
	END IF
      end if

      if vgsdo_disp < 0 then
         let vgsdo_disp = 0;
      end if

      -- Cobro de comisiones a las cuentas que no son de cortesia

      if vclase_cta = "1" then
         select iva into viva
            from bdinteg:si_sucursales
            where empresa = pempresa and sucursal = vgsucursal;
         if viva is null then
            let viva = 0;
         end if

         let vhora = current hour to fraction;
         let vhoraw = vhora;
         let vhoraw = vhoraw[1,2] || vhoraw[4,5] || vhoraw[7,8] ||
                      vhoraw[10,11];
         let vfolio_suc = vgusuario || vhoraw[1,8];

         -- Genera Comisiones por aniversario
         call gencomanv(pempresa,vgcuenta) returning vcodret;
	   if vcodret <> "000" THEN
		return vcodret;
	   end if

         -- Genera Comisiones mensuales

         call gencommes(pempresa,vgcuenta) returning vcodret;
	   if vcodret <> "000" THEN
		return vcodret;
	   end if

         select sdo_actual-sdo_cong-sdo_retenido, com_pendiente
            into vgsdo_disp, vcom_pendiente
            from sc_maechq
            where empresa = pempresa and cuenta = vgcuenta;
         if vcom_pendiente > 0 and vgsdo_disp > 0 then
            call cobintcomsbg(pempresa,vgcuenta,vfolio_suc,vgusuario,
                              vgsucursal) returning vcodret;

  	      if vcodret <> "000" THEN
		    return vcodret;
		end if

            select sdo_actual-sdo_cong-sdo_retenido into vgsdo_disp
               from sc_maechq
               where empresa = pempresa and cuenta = vgcuenta;
         end if
      end if

      let vgsdo_actual = vgsdo_disp;

      -- Actualiza Saldos Promedios
      LET pempresa = pempresa;
      LET vgcuenta = vgcuenta;
      LET vfecha = vfecha;
{     UPDATE sc_salpro
	 SET (sucursal, producto,acum_sobr, dias_sob, acum_ccc,
              dias_ccc, acum_rem, acum_sbc, legal,
              cant_car, cant_abo, num_dev, impor_dev,
              adicionado, fecha_alta, modificado, fecha_mod) =
	     (vgsucursal,vgproducto,vacum_ccc,vdias_ccc,vacum_ccc,
              vdias_ccc,vacum_rem,vacum_sbc,vcta_en_legal,
              vnum_cgos_mes,vnum_abonos_mes,vchq_dev,
              vmonto_dev,vgusuario,vgfecha_hoy,"","")
	WHERE empresa = pempresa
	  AND cuenta = vgcuenta
	  AND fecha = vfecha;

      insert into sc_salpro
         values(pempresa,vgcuenta,vfecha,vgsucursal,vgproducto,vgacum_sdo_pos,
   	        vgdia_sdo_pos,vacum_ccc,vdias_ccc,vacum_ccc,
   	        vdias_ccc,vacum_rem,vacum_sbc,vcta_en_legal,
   	        vnum_cgos_mes,vnum_abonos_mes,vchq_dev,
   	        vmonto_dev,vgusuario,vgfecha_hoy,"",""); 


      update sc_maenoc
         set (dia_sdo_pos,acum_sdo_pos) = (vgdia_sdo_pos,vgacum_sdo_pos)
         where empresa = pempresa and cuenta = vgcuenta;}

      if vgstatus_cta = "1" then
         update sc_maechq set status_cta = "9"
            where empresa = pempresa and cuenta = vgcuenta;
      else
         update sc_maechq set status_cta = "8"
            where empresa = pempresa and cuenta = vgcuenta;
      end if

--   end foreach



--   foreach
--      select cuenta,status_cta
--         into vcuenta,vstatus_cta
--         from sc_maechq
--      if vstatus_cta = "9" then
         update sc_maechq
            set status_cta = "1"
            where empresa = pempresa
            and   cuenta = vgcuenta
            and   status_cta = "9";
--      elif vstatus_cta = "8" then
         update sc_maechq
            set status_cta = "3"
            where empresa = pempresa
            and   cuenta = vgcuenta
            and   status_cta = "8";
--      end if
--   end foreach



   {select valor into vcobrasegf
      from sc_param
      where empresa = pempresa and codparam = "cobrasegf";

   if vcobrasegf = "S" then
      call segurofun(pempresa) returning vcodret;
	if vcodret <> "000" THEN
		return vcodret;
	end if
   end if}

       update sc_tarjeta
          set disp_mes = 0
       where empresa = pempresa
       and   cuenta  = vgcuenta;


   return vcodret;

end

end procedure;