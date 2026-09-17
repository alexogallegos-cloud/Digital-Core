create procedure "informix".consdatos(pnum_credito char(20))
       returning char(5),     --- codigo de retorno
                 char(40),    --- calle
                 char(40),    --- colonia
                 char(40),    --- ciudad
                 char(20),    --- telefono
                 char(20),    --- telefono Oficina
                 money(14,2), --- moratorios
                 money(14,2), --- pago a capital
                 money(14,2), --- pago a interes
                 char(60),    --- cobrador
                 date,        --- Promesa de Pago
                 char(60),    --- Ultima gestion
                 char(10),    --- clasificacion del credito
                 date,        --- fecha primer abono
                 money(10,2), --- importe cuota
                 date,        --- fecha ultimo abono
                 money(10,2), --- importe ultima cuota
                 money(14,2), --- importe de comision
                 char(10),    --- semanas de atraso
                 char(80),    --- cliente
                 money(14,2), --- capital
                 money(14,2), --- total de interes
                 char(40),    --- sucursal
                 char(20),    --- status
                 smallint,    --- plazo
                 date,        --- fecha de apertura
                 date,        --- fecha de vencimiento
                 money(14,2), --- importe de atraso
                 money(14,2), --- saldo de moratorios
                 date,        --- fecha de ultimo pago
                 date,        --- fecha hoy
                 money(14,2), --- saldo de Total Credito
                 money(14,2), --- saldo Actual del Crédito
                 money(14,2), --- Monto del ultimo Pago
                 money(14,2), --- Monto del Credito sin Mora
                 money(14,2); --- Monto Pago requerido

define vcodret char(5);
define vsqlerr integer;
define vcalle char(40);
define vcolonia char(40);
define vciudad char(40);
define vtelefono char(20);
define vteloficina char(20);
define vmoratorios money(14,2);
define vsdo_moratorio money(14,2);
define vpagocap money(14,2);
define vpagoint money(14,2);
define vcobrador char(60);
define vfecultges date;
define vultges    char(60);
define vclasifcte char(10);
define vprimabono date;
define vmonto_cuota money(10,2);
define vultabono date;
define vult_cuota money(10,2);
define vcomision money(14,2);
define vatraso char(10);
define vnumcte char(20);
define vplazo smallint;
define vstatus_cred char(2);
define vfecha_apertura date;
define vfecha_hoy date;
define vcliente char(80);
define vcapital money(14,2);
define vinteres money(14,2);
define vsucursal char(40);
define vstatus char(20);
define vvencim date;
define vsdo_atraso money(14,2);
define vpgo_req money(14,2);
define vsdo_total money(14,2);
define vsdo_actual money(14,2);
define vfecult_pago date;
define vmtoult_pago money(14,2);
define vsdo_cred money(14,2);

begin
   on exception
      set vsqlerr
      let vcodret = vsqlerr;
      return vcodret,vcalle,vcolonia,vciudad,vtelefono,vteloficina,
             vmoratorios,vpagocap,
             vpagoint,vcobrador,vfecultges,vultges,vclasifcte,
             vprimabono,vmonto_cuota,vultabono,vult_cuota,vcomision,
             vatraso,vcliente,vcapital,vinteres,vsucursal,vstatus,vplazo,
             vfecha_apertura,vvencim,vsdo_atraso,vsdo_moratorio,vfecult_pago,
             vfecha_hoy,vsdo_total,vsdo_actual,vmtoult_pago,vsdo_cred,
             vpgo_req;
   end exception;

   let vcodret = "000";
   let vcalle = " ";
   let vcolonia = " ";
   let vciudad = " ";
   let vtelefono = " ";
   let vteloficina = " ";
   let vmoratorios = 0;
   let vpagocap = 0;
   let vpagoint = 0;
   let vcobrador = " ";
   let vclasifcte = " ";
   let vprimabono = " ";
   let vmonto_cuota = 0;
   let vultabono = " ";
   let vult_cuota = " ";
   let vcomision = 0;
   let vatraso = " ";
   let vcliente = " ";
   let vcapital = 0;
   let vinteres = 0;
   let vsucursal = " ";
   let vstatus = " ";
   let vplazo = 0;
   let vfecha_apertura = "";
   let vvencim = "";
   let vsdo_atraso = 0;
   let vsdo_moratorio = 0;
   let vsdo_total = 0;
   let vsdo_actual = 0;
   let vmtoult_pago = 0;
   let vsdo_cred = 0;
   let vpgo_req = 0;
   let vfecult_pago = " ";
   let vfecultges = " ";
   let vultges = " ";
   let vfecha_hoy = " ";



   select numcte,plazo,status_cred,fecha_apertura,fecha_vencim,
          sucursal,monto_otorgado,sdo_global_int,sdo_moratorio
      into vnumcte,vplazo,vstatus_cred,vfecha_apertura,vvencim,
           vsucursal,vcapital,vinteres,vsdo_moratorio
      from sd_maecred a, sd_maesdos b
      where a.num_credito = pnum_credito and
            a.num_credito = b.num_credito;

   select sucursal||" "||nombre into vsucursal
      from bdinteg:si_sucursales
      where sucursal = vsucursal;

   select trim(nvl(nombre1,""))||" "||trim(nvl(nombre2,""))||" "||
          trim(nvl(apell_paterno,""))||" "||trim(nvl(apell_materno,""))
      into vcliente
      from bdinteg:si_cliente
      where numcte = vnumcte;

   select descripcion into vstatus
      from sd_tipocartera
      where status_cred = vstatus_cred;

   select di.calle, di.colonia, es.nombre||di.cod_postal,
          di.telefono1||" "||di.telefono2,ing.telefono
      into vcalle,vcolonia,vciudad,vtelefono,vteloficina
      from bdinteg:si_direcciones di,bdinteg:si_estados es,
           bdinteg:si_ingresos ing
      where di.numcte = vnumcte and di.secuencia = 1 and
            ing.numcte = vnumcte and ing.sec_ingreso = 1 and
            di.pais = es.pais and di.estado = es.estado;

    select tc.descripcion
       into vclasifcte
       from sd_tipocartera as tc ,
            sd_maecred mc
       where mc.num_credito = pnum_credito and
             mc.bandera_fi_fo = tc.status_cred;

    --select max(bi.fecha_gestion),ej.nombre
    --   into vfecultges,vcobrador
    --   from sd_maecred mc,bdicobranza:cb_hisgestion bi,
    --        bdinteg:si_ejecut ej, bdicobranza:cb_cobranza cb
    --   where mc.num_credito = pnum_credito and
    --         bi.num_credito = mc.num_credito and
    --         cb.num_credito = mc.num_credito and
    --         ej.ejecutivo   = cb.ejecutivo and
    --         bi.id_accion = 1 and status_cob in("A","P")
    --   group by 2;
    select max(prox_gestion)
       into vfecultges
       from bdicobranza:cb_hisgestion
       where num_credito = pnum_credito and
             id_accion = 1;
    select ej.nombre
       into vcobrador
       from bdinteg:si_ejecut ej, bdicobranza:cb_cobranza cb
       where cb.num_credito = pnum_credito and
             ej.ejecutivo   = cb.ejecutivo and
             status_cob in("A","P") ;
  -- vultges


    select nvl(sum(monto),0)
       into vmoratorios
       from sd_movdia
       where num_credito = pnum_credito and
             codigo_fun = '033' and codigo_ref = 2;
    let vmoratorios = vsdo_moratorio + nvl(vmoratorios,0);

    select nvl(sum(monto_real_pag),0)
       into vpagocap
       from sd_pagocapit
       where num_credito = pnum_credito;

    select nvl(sum(monto_real_pag),0)
       into vpagoint
       from sd_paginter
       where num_credito = pnum_credito;

    select min(fecha_cuota)
       into vprimabono
       from sd_pagocapit 
       where num_credito = pnum_credito;

    select pc.monto_cuota + pi.monto_cuota
       into vmonto_cuota
       from sd_pagocapit pc, sd_paginter pi
       where pc.num_credito = pnum_credito and
             pc.num_credito = pi.num_credito and
             pc.fecha_cuota = vprimabono and
             pc.fecha_cuota = pi.fecha_cuota;

    select max(fecha_cuota)
       into vultabono
       from sd_pagocapit
       where num_credito = pnum_credito;

    select pc.monto_cuota + pi.monto_cuota
       into vult_cuota
       from sd_pagocapit pc, sd_paginter pi
       where pc.num_credito = pnum_credito and
             pc.num_credito = pi.num_credito and
             pc.fecha_cuota = vultabono and
             pc.fecha_cuota = pi.fecha_cuota;

    select max(fecha_mov)
       into vfecult_pago
       from sd_movdia mv
       where mv.num_credito = pnum_credito and
             mv.codigo_fun = '033' and mv.codigo_ref = 1 and
             mv.reversado <> "S";

    select max(monto)
       into vmtoult_pago
       from sd_movdia mv
       where mv.num_credito = pnum_credito and
             mv.codigo_fun = '033' and mv.codigo_ref = 1
             and mv.fecha_mov = vfecult_pago and mv.reversado <> "S";

    select nvl(sum(monto_com),0)
       into vcomision
       from sd_detcomi
       where num_credito = pnum_credito;

    select fecha_hoy into vfecha_hoy
       from sd_fechas;

    if vstatus_cred <> "FF" then
       select count(*),sum(pc.monto_cuota - pc.monto_real_pag +
              pi.monto_cuota - pi.monto_real_pag)
          into vatraso, vsdo_atraso
          from sd_pagocapit pc, sd_paginter pi
          where pc.num_credito = pnum_credito and
                pc.status_cuota <> "5" and
                pc.fecha_cuota < vfecha_hoy and
                pc.num_credito = pi.num_credito and
                pc.fecha_cuota = pi.fecha_cuota;
    else
       let vatraso = 0;
       let vsdo_atraso = 0;
    end if

    let vcliente = trim(vcliente);
    --Calcula el Saldo del Crédito sin Mora
    let vsdo_cred = vcapital + vinteres;
    --Calcula el Saldo Total del Crédito
    let vsdo_total = vcapital + vinteres + vmoratorios;
    --Calcula el Saldo Actual del Crédito
    let vsdo_actual = vsdo_total - (vpagocap + vpagoint);
    -- Calcula Pago Requerido
    let vpgo_req = vsdo_moratorio + vsdo_atraso;

    return vcodret,vcalle,vcolonia,vciudad,vtelefono,vteloficina,
             vmoratorios,vpagocap,
             vpagoint,vcobrador,vfecultges,vultges,vclasifcte,
             vprimabono,vmonto_cuota,vultabono,vult_cuota,vcomision,
             vatraso,vcliente,vcapital,vinteres,vsucursal,vstatus,vplazo,
             vfecha_apertura,vvencim,vsdo_atraso,vsdo_moratorio,vfecult_pago,
             vfecha_hoy,vsdo_total,vsdo_actual,vmtoult_pago,vsdo_cred,
             vpgo_req;
end
end procedure;