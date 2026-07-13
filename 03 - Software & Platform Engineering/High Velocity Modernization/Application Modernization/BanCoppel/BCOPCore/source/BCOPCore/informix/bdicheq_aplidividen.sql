create procedure "informix".aplidividen(pempresa char(3),
                                        pejercicio datetime year to month)
       returning char(5);

define vrowid, vsqlerr integer;
define vsucursal char(4);
define vcuenta char(20);
define vcuenta_aho char(20);
define vnumcte char(20);
define vmonto money(14,2);
define vdivisa char(2);
define vstatus char(1);
define vnaturaleza char(1);
define vtipo_aplica char(1);
define vusuario char(8);
define vfolio_suc char(16);
define vcodret char(5);
define vtransacc char(4);
define vreferencia char(40);
define vfecha_hoy date;
define vmensaje char(80);
define vsolbcos char(20);
define vproducto char(4);
define vsdo_cuenta money(14,2);
define vtotreg integer;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if
   end exception;


   let vusuario = USER;
   let vcodret = "000";

   select fecha_hoy into vfecha_hoy
      from sc_fechas
      where empresa = pempresa;

   select tipo_aplica into vtipo_aplica
      from sc_contpagdiv
      where empresa = pempresa and ejercicio = pejercicio;

   if vtipo_aplica = "A" then
      select valor into vtransacc
         from sc_param
         where empresa = pempresa and codparam = "tranpagdivabo";

      if vtransacc is null or vtransacc = " " then
         let vcodret = "550";
         return vcodret;
      end if

      select naturaleza into vnaturaleza
         from bdinteg:si_transacc
         where empresa = pempresa and numero = vtransacc;

      if vnaturaleza is null then
         let vcodret = "550";
         return vcodret;
      end if

      if vnaturaleza <> "A" then
         let vcodret = "552";
         return vcodret;
      end if
   else
      select valor into vtransacc
         from sc_param
         where empresa = pempresa and codparam = "tranpagdivcap";

      if vtransacc is null or vtransacc = " " then
         let vcodret = "550";
         return vcodret;
      end if

      select naturaleza into vnaturaleza
         from bdinteg:si_transacc
         where empresa = pempresa and numero = vtransacc;

      if vnaturaleza is null or vnaturaleza <> "R" then
         let vcodret = "550";
         return vcodret;
      end if
   end if

   select count(*) into vtotreg
      from sc_movpagdiv
      where empresa = pempresa and ejercicio = pejercicio and
            procesado != "S" and fecha_apli <= vfecha_hoy;
   if vtotreg is null or vtotreg <= 0 then
      let vcodret = "910";
      return vcodret;
   end if

   foreach with hold
      select a.rowid,sucursal,a.cuenta,monto,num_cte,producto,sdo_actual
         into vrowid,vsucursal,vcuenta,vmonto,vnumcte,vproducto,vsdo_cuenta
         from sc_movpagdiv a, sc_maechq b
         where a.empresa = pempresa and ejercicio = pejercicio and
               procesado != "S" and fecha_apli <= vfecha_hoy and
               a.empresa = b.empresa and a.cuenta = b.cuenta
      let vcodret = "000";
      let vstatus = " ";
      let vcuenta_aho = vcuenta[1,9]||"300";
      let vdivisa = "";
      select divisa,status_cta into vdivisa,vstatus
         from sc_maechq a, sc_producto b
         where a.empresa = pempresa and cuenta = vcuenta_aho and
               a.empresa = b.empresa and a.producto = b.producto;
      let vfolio_suc = current hour to fraction(3);
      let vfolio_suc = vusuario||vfolio_suc[1,2]||vfolio_suc[4,5]||
                       vfolio_suc[7,8]||vfolio_suc[9,10];
      let vreferencia = "Pago de dividendos del ejercicio "||pejercicio;
      if vtipo_aplica = "A" then
         if vdivisa is null then
            call bdibanco:sbsp_graba_solchq(pempresa,vnumcte,vusuario,
                 vmonto,vcuenta) returning vcodret,vmensaje,vsolbcos;
            if vcodret = "00000" then
               let vcodret = "000";
            end if
         else
            if vstatus = "3" then
               update sc_maechq
                  set status_cta = "1"
                  where empresa = pempresa and cuenta = vcuenta_aho;
            end if
            foreach
               execute procedure abono_ref(pempresa,vsucursal,vusuario,
                    vtransacc,"0000",vfolio_suc,vcuenta_aho,0,vmonto,
                    vmonto,0,0,0,vdivisa,vreferencia) into vcodret
            end foreach
            if vstatus = "3" then
               update sc_maechq
                  set status_cta = "3"
                  where empresa = pempresa and cuenta = vcuenta_aho;
            end if
         end if
      else
         insert into sc_movdia
            values(0,vfolio_suc,vsucursal,vusuario,vfecha_hoy,vfecha_hoy,
                   current hour to fraction(3),vtransacc,vsucursal,
                   vproducto,pempresa,vcuenta," ",0,vmonto,vmonto,0,0,0,
                   " "," ",vsdo_cuenta,"000",vreferencia,0,"","","");
      end if
      if vcodret = "000" then
         update sc_movpagdiv
            set(procesado,codigo_retorno,fecha_proceso) =
               ("S",vcodret,vfecha_hoy)
            where rowid=vrowid;
      else
         update sc_movpagdiv
            set(procesado,codigo_retorno,fecha_proceso) =
               ("N",vcodret,vfecha_hoy)
            where rowid=vrowid;
      end if
   end foreach
   let vcodret = "000";
   return vcodret;
end
end procedure;