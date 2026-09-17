CREATE PROCEDURE "informix".ctas_nuevascc(pempresa char(3),w_fecha date,
v_usuario CHAR(10))
define nuempresa         char(3);
define nuccmayor         char(10);
define nuccsub           char(10);
define nuccsubsub        char(10);
define nuccssubsub       char(10);
define nuccsssubsub      char(10);
define nusector          char(10);
define nuciudad          char(3);
define nusucursal        char(4);
define numoneda          char(2);
define nunat_cta         char(1);

define w_pri_hab_mes,w_fecha_ant     date;
define w_cargos_dia,w_abonos_dia,w_debito_dia_ant,w_credito_dia_ant,
       w_saldo_inicio_dia, w_saldo_fin_de_dia money(18,2);

define w_cargoscor_dia,w_abonoscor_dia,w_debcor_dia_ant,
       w_credcor_dia_ant money(18,2);

define lv_cuantos        int;

DEFINE v_plaza           CHAR(3);
DEFINE v_regional        CHAR(3);

LET v_plaza         = "";
LET v_regional      = "";

select pri_hab_mes,fecha_ant
into   w_pri_hab_mes,w_fecha_ant
from   co_fechas
where  empresa= pempresa;

foreach
   select distinct d.empresa, d.ccmayor, d.ccsub, d.ccsubsub, d.ccssubsub,
          d.ccsssubsub, d.sector, d.ciudad, d.sucursal, d.moneda, naturaleza_cta
   into   nuempresa,nuccmayor,nuccsub,nuccsubsub,nuccssubsub,
          nuccsssubsub,nusector,nuciudad,nusucursal,numoneda,nunat_cta
   from co_detpol d,bdinteg:si_catalog c
   where d.empresa    = c.empresa
   and   d.empresa    = pempresa
   and   c.empresa    = pempresa
   and   d.ccmayor    = c.ccmayor
   and   d.ccsub      = c.ccsub
   and   d.ccsubsub   = c.ccsubsub
   and   d.ccssubsub  = c.ccssubsub
   and   d.ccsssubsub = c.ccsssubsub
   and   d.sector     = c.sector

   SELECT plaza
   INTO v_plaza
   FROM bdinteg:si_sucursales
   WHERE empresa = pempresa
     AND sucursal = trim(nusucursal);

   SELECT regional
   INTO v_regional
   FROM bdinteg:si_plazas
   WHERE empresa = pempresa
     AND plaza = trim(v_plaza);

   LET nuciudad = v_regional;
	 
   let lv_cuantos = 0;

   select count(*)
   into lv_cuantos
   from co_sdodias
   where empresa      = nuempresa
     and ccmayor      = nuccmayor
     and ccsub        = nuccsub
     and ccsubsub     = nuccsubsub
     and ccssubsub    = nuccssubsub
     and ccsssubsub   = nuccsssubsub
     and sector       = nusector
     --and ciudad       = nuciudad
     and sucursal     = nusucursal
     and moneda       = numoneda
     and mes_dia      = w_fecha;

   if lv_cuantos = 0 then
      select sum(monto) into w_cargos_dia
      from co_detpol
      where empresa      = nuempresa
      and   ccmayor      = nuccmayor
      and   ccsub        = nuccsub
      and   ccsubsub     = nuccsubsub
      and   ccssubsub    = nuccssubsub
      and   ccsssubsub   = nuccsssubsub
      and   sector       = nusector
      --and   ciudad       = nuciudad
      and   sucursal     = nusucursal
      and   moneda       = numoneda
      and   naturaleza   = "D"
      and   fecha_valida = w_fecha;

      if w_cargos_dia is null then
         let w_cargos_dia = 0;
      end if

      select sum(monto) into w_abonos_dia
      from co_detpol
      where empresa      = nuempresa
      and   ccmayor      = nuccmayor
      and   ccsub        = nuccsub
      and   ccsubsub     = nuccsubsub
      and   ccssubsub    = nuccssubsub
      and   ccsssubsub   = nuccsssubsub
      and   sector       = nusector
      --and   ciudad       = nuciudad
      and   sucursal     = nusucursal
      and   moneda       = numoneda
      and   naturaleza   = "C"
      and   fecha_valida = w_fecha;

      if w_abonos_dia is null then
         let w_abonos_dia = 0;
      end if

      select sum(monto) into w_debito_dia_ant
      from co_detpol
      where empresa      = nuempresa
      and   ccmayor      = nuccmayor
      and   ccsub        = nuccsub
      and   ccsubsub     = nuccsubsub
      and   ccssubsub    = nuccssubsub
      and   ccsssubsub   = nuccsssubsub
      and   sector       = nusector
      --and   ciudad       = nuciudad
      and   sucursal     = nusucursal
      and   moneda       = numoneda
      and   naturaleza   = "D"
      and   fecha_valida < w_fecha;

      if w_debito_dia_ant is null then
         let w_debito_dia_ant = 0;
      end if

      select sum(monto) into w_credito_dia_ant
      from co_detpol
      where empresa      = nuempresa
      and   ccmayor      = nuccmayor
      and   ccsub        = nuccsub
      and   ccsubsub     = nuccsubsub
      and   ccssubsub    = nuccssubsub
      and   ccsssubsub   = nuccsssubsub
      and   sector       = nusector
      --and   ciudad       = nuciudad
      and   sucursal     = nusucursal
      and   moneda       = numoneda
      and   naturaleza   = "C"
      and   fecha_valida < w_fecha;

      if w_credito_dia_ant is null then
         let w_credito_dia_ant = 0;
      end if

      -- Calcula saldos
      if nunat_cta = "D" then
         let w_saldo_inicio_dia = 0 + w_debito_dia_ant - w_credito_dia_ant;
         let w_saldo_fin_de_dia = w_cargos_dia - w_abonos_dia;
      end if

      if nunat_cta = "A" then
         let w_saldo_inicio_dia = 0 - w_debito_dia_ant + w_credito_dia_ant;
         let w_saldo_fin_de_dia = (- w_cargos_dia + w_abonos_dia);
      end if
      if w_saldo_inicio_dia = 0 and w_cargos_dia = 0
         and w_abonos_dia = 0 and w_saldo_fin_de_dia = 0 then
      else
         insert into co_balanza
         values (nuempresa,nuccmayor,nuccsub,
                 nuccsubsub,nuccssubsub,
                 nuccsssubsub,nusector,nuciudad,
                 nusucursal,numoneda,w_fecha,
                 w_saldo_inicio_dia,w_cargos_dia,
                 w_abonos_dia,w_saldo_fin_de_dia,"D"," "," "," "," ",0,0,v_usuario);
      end if
   end if
end foreach
end procedure;