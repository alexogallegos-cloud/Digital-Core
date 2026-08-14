create procedure "informix".con_canc_pba(pempresa char(3),
                                     pcuenta char(20))

returning char(5),money(14,2),decimal(9,6),money(14,2),money(14,2),
          money(14,2),money(14,2),char(3),char(2),money(14,2);

define vband,vstatus_cta,vfisica,vexento_isr char(1);
define vcalcint,vpag_int_canc,vpagint char(1);
define vtipper char(2);
define vcodret char(5);
define vsuccta char(4);
define vtasa char(8);
define vproducto char(4);
define vmoneda char(2);
define vnumcte char(20);
define vcuenta char(20);
define viva,vvalor_tasa decimal(9,6);
define vacum_sdo_int,vsdo_actual,vsdo_retenido,vsdo_cong,vmtopag,
       vsdo_t1,vsdo_prom,vtot_int,visr,vintacum,vtot_canc money(14,2);
define vbasedias,vdias,vnumreg,vdias_acum_int,vdiascancta integer;
define vsqlerr integer;
define vultpagocap,vfecvenccap,vfechalta,vfecha_hoy date;
define vfecpagoint datetime month to day;
define vcobraisr char(1);
define vcomcancta money(14,2);
define vcomision char(4);
define vforma_aplica char(1);
define vmonto_aplica money(14,2);
define vfactor_aplica decimal(9,6);
define vtipo_anio_calc,vrangos char(1);
define vrango_min money(14,2);
define vrango_max money(14,2);
define vcodigo_param char(2);
define vejecuta_spl char(1);
define voperador char(1);
define vnombrespl char(20);
define vvalorspl money(14,2);
define vcalcula_com char(1);
define vmonto_com money(14,2);


let vsdo_prom = 0;
let vvalor_tasa = 0;
let vsdo_actual = 0;
let vtot_int = 0;
let visr = 0;
let vtot_canc = 0;
let vcodret = "000";
let vmoneda = " ";
let vsuccta = " ";
let vcomcancta = 0;

begin
on exception set vsqlerr
   if vsqlerr <> 0 then
      let vcodret = vsqlerr;
      return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
          visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
   end if;
end exception;

-- Extrae datos de la cuenta de cheques
select sc_maechq.cuenta,sucursal,sc_maechq.producto,
        num_cte,dias_acum_int,acum_sdo_int,sdo_actual,status_cta,
        sdo_retenido,sdo_cong,divisa,fecha_alta,int_acum,saldo_sbc,
        cobraisr,dias_canc_cta,fecpagoint,ultpagocap
   into vcuenta,vsuccta,vproducto,vnumcte,vdias_acum_int,vacum_sdo_int,
        vsdo_actual,vstatus_cta,vsdo_retenido,vsdo_cong,vmoneda,
        vfechalta,vintacum,vsdo_t1,vcobraisr,vdiascancta,vfecpagoint,
        vultpagocap
   from sc_maechq,sc_maenoc,sc_producto
   where sc_maechq.empresa = pempresa and
         sc_maechq.cuenta = pcuenta and
         sc_maenoc.empresa = sc_maechq.empresa and
         sc_maenoc.cuenta = sc_maechq.cuenta and
         sc_maechq.empresa = sc_producto.empresa and
         sc_maechq.producto = sc_producto.producto;

if vcuenta is null then
   let vcodret = "100";
   return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
          visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
end if

--- Verifica que la cuenta no este cancelada
   if vstatus_cta = "2" then
      let vcodret = "200";
      return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
             visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
   end if;

--- Verifica que la cuenta no este bloqueada
   if vstatus_cta = "3" then
      let vcodret = "303";
      return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
             visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
   end if;

--- Verifica que la cuenta no tenga saldo congelado o retenido
   if vsdo_cong != 0 or vsdo_retenido != 0 then
      let vcodret = "305";
      return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
             visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
   end if;

--- Verifica que la cuenta no tenga saldo en t+1
    if vsdo_t1 <> 0 and vsdo_t1 is not null then
      let vcodret = "305";
      return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
             visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
   end if;

--- Verifica que la cuenta no este relacionada en Inversiones
   let vnumreg = 0;
   let vband = "0";
   select "1" into vband from bdinteg:si_sistema
      where siglas = "SV";
   if vband = "1" then
      select count(*) into vnumreg
         from bdinvers:sv_maeinstrucc mi,bdinvers:sv_maeinv ma
         where mi.empresa = pempresa and
               mi.cta_cheques = pcuenta and sistema = "01" and
               ma.empresa = mi.empresa and ma.cuenta = mi.cuenta and
               status_cta in("1","3");
      if vnumreg > 0 then
         let vcodret = 160;
         return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
                visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
      end if
   end if

--- Verifica que la cuenta no este relacionada en Credito
   let vnumreg = 0;
   let vband = "0";
   select "1" into vband from bdinteg:si_sistema
      where siglas = "SD";
   if vband = "1" then
      select count(*) into vnumreg
         from bdicred:sd_ctascarg cc,bdicred:sd_maecred mc
         where cc.empresa = pempresa and num_cta = pcuenta and
               tipo_cta = "2" and mc.num_credito = cc.num_credito and
               status_cred <> "5";
      if vnumreg > 0 then
         let vcodret = 161;
         return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
                visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
      end if
   end if

-- Determina Fecha
   select fecha_hoy into vfecha_hoy
      from sc_fechas
      where empresa = pempresa;

-- Determina si el Producto paga intereses
   select paga_interes,mto_pag_int,tasa,tipo_dias_calc,tipo_anio_calc
         into vpagint,vmtopag,vtasa,vcalcint,vtipo_anio_calc
         from sc_producto
         where empresa = pempresa and producto = vproducto;

   if vtipo_anio_calc = "1" then
      let vbasedias = 360;
   else
      let vbasedias = 365;
   end if

   select valor into vpag_int_canc
      from sc_param
      where empresa = pempresa and codparam = "pagintcancta";

-- Determina el Saldo Promedio de la cuenta
   if vdias_acum_int > 0 then
      let vsdo_prom = vacum_sdo_int / vdias_acum_int;
   else
      let vsdo_prom = 0;
   end if

-- Determina el tipo de persona
   select tpo_persona into vtipper
      from bdinteg:si_cliente where numcte = vnumcte;
   select es_fisica,exento_isr into vfisica,vexento_isr
      from bdinteg:si_tipper where tpo_persona = vtipper;
   if vfisica = "S" then
      let vtipper = "F ";
   else
      let vtipper = "M ";
   end if

   if vcobraisr <> "" then
      if vcobraisr = "S" then
         let vexento_isr = "N";
      else
         let vexento_isr = "S";
      end if
   end if

   if vpag_int_canc = "S" and vpagint = "S" then
      let vtot_int = 0;
      let visr = 0;
      if vcalcint = "M" then
         if vsdo_prom >= vmtopag then
            call calc_tasa(vtasa,vtipper,vsdo_prom)
                 returning vcodret,vvalor_tasa;
            if vcodret = "000" then
               let vtot_int = vacum_sdo_int * vvalor_tasa / 100 / vbasedias;
            end if
         end if
      end if
      if vsdo_prom >= vmtopag then
         let vtot_int = vintacum + vtot_int;
      else
         let vtot_int = 0;
      end if
      -- Verificar si retiene ISR
      if vexento_isr = "N" and vtot_int > 0 then
         call calc_isr(pcuenta,vfecha_hoy,vvalor_tasa,vtot_int,
              vsdo_prom,vdias_acum_int,vfisica) returning vcodret,visr;
      end if
   end if

   --- Valida si cobra comision  en cancelacion anticipada
   let vdias = vfecha_hoy - vfechalta;
   let vsdo_actual = vsdo_actual + vtot_int - visr;
   if vfecpagoint = "" or vfecpagoint is null then
      let vfecvenccap = "";
   else
      let vfecvenccap = mdy(month(vultpagocap),day(vultpagocap),
                            year(vfecha_hoy));
      if vfecvenccap <= vultpagocap then
         let vfecvenccap = vfecvenccap + 1 units year;
      end if
   end if

   if vdias <= vdiascancta or vfecvenccap > vfecha_hoy  then
      foreach
         select pc.comision,forma_aplica,monto_aplica,factor_aplica,rangos,
                rango_min,rango_max,campo,operador
            into vcomision,vforma_aplica,vmonto_aplica,vfactor_aplica,vrangos,
                vrango_min,vrango_max,vcodigo_param,voperador
            from sc_prodcomis pc, sc_comisiones co
            where pc.empresa = pempresa and pc.producto = vproducto and
                  pc.empresa = co.empresa and pc.comision = co.comision and
                  forma_cargo = "06"
         select ejecuta_spl,nombrespl into vejecuta_spl,vnombrespl
            from sc_paramcomis
            where empresa = pempresa and codigo_param = vcodigo_param and
                  tipo_param = "D";
         if vejecuta_spl = "S" then
            call vnombrespl(pempresa,pcuenta) returning vcodret,vvalorspl;
            if vcodret <> "000" then
               return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
                      visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
            end if
         else
            let vvalorspl = 1;
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
            let vcomcancta = vcomcancta + vmonto_com;
         end if
      end foreach
      if vsdo_actual < vcomcancta then
         let vcomcancta = vsdo_actual;
      end if
   end if
   let vtot_canc = vsdo_actual + vtot_int - visr - vcomcancta;
   return vcodret,vsdo_prom,vvalor_tasa,vsdo_actual,vtot_int,
          visr,vtot_canc,vsuccta,vmoneda,vcomcancta;
end
end procedure;