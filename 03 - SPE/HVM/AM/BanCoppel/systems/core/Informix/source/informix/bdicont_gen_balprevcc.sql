CREATE PROCEDURE "informix".gen_balprevcc(pempresa char(3), w_fecha date,v_usuario char(10))

define sdempresa            char(3);
define sdccmayor            char(10);
define sdccsub              char(10);
define sdccsubsub           char(10);
define sdccssubsub          char(10);
define sdccsssubsub         char(10);
define sdsector             char(10);
define sdciudad             char(3);
define sdsucursal           char(4);
define sdmoneda             char(2);
define sdcargos_dia         money(18,2);
define sdabonos_dia         money(18,2);
define sdsaldo_inicio_dia   money(18,2);
define sdsaldo_fin_de_dia   money(18,2);
define sdnaturaleza_cta     char(1);
define sdnombre_cta         char(40);
define v_numregs            int;

define w_pri_hab_mes        date;
define w_cargos_dia,
       w_abonos_dia,
       w_debito_dia_ant,
       w_credito_dia_ant    money(18,2);
define w_cargoscor_dia,
       w_abonoscor_dia,
       w_debcor_dia_ant     money(18,2);
define w_credcor_dia_ant    money(18,2);
define v_nomsuc             char(40);

DEFINE v_plaza              CHAR(3);
DEFINE v_regional           CHAR(3);

LET v_plaza         = "";
LET v_regional      = "";

select pri_hab_mes
into w_pri_hab_mes
from co_fechas
where empresa = pempresa;

{select nrows
into   v_numregs
from   systables
where  tabname = "co_sdodias";}

select count(*) into v_numregs
from co_sdodias;

if v_numregs > 0 then
   foreach
      select co_sdodias.empresa,co_sdodias.ccmayor,co_sdodias.ccsub,
      co_sdodias.ccsubsub,co_sdodias.ccssubsub,co_sdodias.ccsssubsub,
      co_sdodias.sector,
      --co_sdodias.ciudad,
      co_sdodias.sucursal,co_sdodias.moneda,
      cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia,naturaleza_cta,nombre
      into   sdempresa,sdccmayor,sdccsub,sdccsubsub,sdccssubsub,sdccsssubsub,
             sdsector,
             --sdciudad,
             sdsucursal,sdmoneda,sdcargos_dia,sdabonos_dia,
             sdsaldo_inicio_dia,sdsaldo_fin_de_dia,sdnaturaleza_cta,sdnombre_cta
      from co_sdodias,bdinteg:si_catalog
      where co_sdodias.empresa = bdinteg:si_catalog.empresa
      and co_sdodias.empresa = pempresa
      and bdinteg:si_catalog.empresa = pempresa
      and co_sdodias.ccmayor = bdinteg:si_catalog.ccmayor
      and co_sdodias.ccsub = bdinteg:si_catalog.ccsub
      and co_sdodias.ccsubsub = bdinteg:si_catalog.ccsubsub
      and co_sdodias.ccssubsub = bdinteg:si_catalog.ccssubsub
      and co_sdodias.ccsssubsub = bdinteg:si_catalog.ccsssubsub
      and co_sdodias.sector = bdinteg:si_catalog.sector
      and co_sdodias.mes_dia = w_fecha

      SELECT plaza
      INTO v_plaza
      FROM bdinteg:si_sucursales
      WHERE empresa = v_empresa
        AND sucursal = trim(c_sucursal);

      SELECT regional
      INTO v_regional
      FROM bdinteg:si_plazas
      WHERE empresa = v_empresa
        AND plaza = trim(v_plaza);

      LET sdciudad = v_regional;
	 
      let w_cargos_dia = 0;
      let w_abonos_dia = 0;
      let w_debito_dia_ant = 0;
      let w_credito_dia_ant = 0;

      select sum(monto) into w_cargos_dia
      from co_detpol
      where empresa      = sdempresa
      and   ccmayor      = sdccmayor
      and   ccsub        = sdccsub
      and   ccsubsub     = sdccsubsub
      and   ccssubsub    = sdccssubsub
      and   ccsssubsub   = sdccsssubsub
      and   sector       = sdsector
      and   ciudad       = sdciudad
      and   sucursal     = sdsucursal
      and   moneda       = sdmoneda
      and   naturaleza   = "D"
      and   fecha_captura = w_fecha
      and   fecha_valida = w_fecha;

      if w_cargos_dia is null then
         let w_cargos_dia = 0;
      end if

      select sum(monto) into w_abonos_dia
      from co_detpol
      where empresa      = sdempresa
      and   ccmayor      = sdccmayor
      and   ccsub        = sdccsub
      and   ccsubsub     = sdccsubsub
      and   ccssubsub    = sdccssubsub
      and   ccsssubsub   = sdccsssubsub
      and   sector       = sdsector
      and   ciudad       = sdciudad
      and   sucursal     = sdsucursal
      and   moneda       = sdmoneda
      and   naturaleza   = "C"
      and   fecha_captura = w_fecha
      and fecha_valida = w_fecha;

      if w_abonos_dia is null then
         let w_abonos_dia = 0;
      end if

      select sum(monto) into w_debito_dia_ant
      from co_detpol
      where empresa      = sdempresa
      and   ccmayor      = sdccmayor
      and   ccsub        = sdccsub
      and   ccsubsub     = sdccsubsub
      and   ccssubsub    = sdccssubsub
      and   ccsssubsub   = sdccsssubsub
      and   sector       = sdsector
      and   ciudad       = sdciudad
      and   sucursal     = sdsucursal
      and   moneda       = sdmoneda
      and   naturaleza   = "D"
      and   fecha_valida < w_fecha
      and   fecha_captura = w_fecha;

      if w_debito_dia_ant is null then
         let w_debito_dia_ant = 0;
      end if

      select sum(monto) into w_credito_dia_ant
      from co_detpol
      where empresa      = sdempresa
      and   ccmayor      = sdccmayor
      and   ccsub        = sdccsub
      and   ccsubsub     = sdccsubsub
      and   ccssubsub    = sdccssubsub
      and   ccsssubsub   = sdccsssubsub
      and   sector       = sdsector
      and   ciudad       = sdciudad
      and   sucursal     = sdsucursal
      and   moneda       = sdmoneda
      and   naturaleza   = "C"
      and   fecha_valida < w_fecha
      and   fecha_captura = w_fecha;

      if w_credito_dia_ant is null then
         let w_credito_dia_ant = 0;
      end if

      -- Calcula saldos
      let sdcargos_dia = w_cargos_dia;
      let sdabonos_dia = w_abonos_dia;
      if sdnaturaleza_cta = "D" then
         let sdsaldo_inicio_dia = sdsaldo_fin_de_dia +
                                  w_debito_dia_ant - w_credito_dia_ant;
         let sdsaldo_fin_de_dia = sdsaldo_inicio_dia +
                                  w_cargos_dia - w_abonos_dia;
      end if

      if sdnaturaleza_cta = "A" then
         let sdsaldo_inicio_dia = sdsaldo_fin_de_dia -
                                  w_debito_dia_ant + w_credito_dia_ant;
         let sdsaldo_fin_de_dia = sdsaldo_inicio_dia -
                                  w_cargos_dia + w_abonos_dia;
      end if

      select nombre
      into   v_nomsuc
      from bdinteg:si_sucursales
      where empresa = sdempresa
      and   sucursal = sdsucursal;

      if sdsaldo_inicio_dia = 0 and sdcargos_dia = 0
         and sdabonos_dia = 0 and sdsaldo_fin_de_dia = 0 then
      else
         insert into co_balanza
         values (sdempresa,sdccmayor,sdccsub,sdccsubsub,sdccssubsub,
                 sdccsssubsub,sdsector,sdciudad,sdsucursal,sdmoneda,
                 w_fecha,sdsaldo_inicio_dia,sdcargos_dia,
                 sdabonos_dia,sdsaldo_fin_de_dia,"D",sdnaturaleza_cta,
                 sdnombre_cta,v_nomsuc," ",0,0,v_usuario);
      end if
   end foreach
{lse
   foreach
      select distinct co_detpol.empresa,co_detpol.ccmayor,co_detpol.ccsub,
      co_detpol.ccsubsub,co_detpol.ccssubsub,co_detpol.ccsssubsub,
      co_detpol.sector,co_detpol.ciudad,co_detpol.sucursal,co_detpol.moneda,
      0,0,0,0,naturaleza_cta,nombre
      into   sdempresa,sdccmayor,sdccsub,sdccsubsub,sdccssubsub,sdccsssubsub,
             sdsector,sdciudad,sdsucursal,sdmoneda,sdcargos_dia,sdabonos_dia,
             sdsaldo_inicio_dia,sdsaldo_fin_de_dia,sdnaturaleza_cta,sdnombre_cta
      from co_detpol,bdinteg:si_catalog
      where co_detpol.empresa = bdinteg:si_catalog.empresa
      and co_detpol.empresa = pempresa
      and bdinteg:si_catalog.empresa = pempresa
      and co_detpol.ccmayor = bdinteg:si_catalog.ccmayor
      and co_detpol.ccsub = bdinteg:si_catalog.ccsub
      and co_detpol.ccsubsub = bdinteg:si_catalog.ccsubsub
      and co_detpol.ccssubsub = bdinteg:si_catalog.ccssubsub
      and co_detpol.ccsssubsub = bdinteg:si_catalog.ccsssubsub
      and co_detpol.sector = bdinteg:si_catalog.sector
      and co_detpol.fecha_captura = w_fecha

      let w_cargos_dia = 0;
      let w_abonos_dia = 0;
      let w_debito_dia_ant = 0;
      let w_credito_dia_ant = 0;

      select sum(monto) into w_cargos_dia
      from co_detpol
      where empresa      = sdempresa
      and   ccmayor      = sdccmayor
      and   ccsub        = sdccsub
      and   ccsubsub     = sdccsubsub
      and   ccssubsub    = sdccssubsub
      and   ccsssubsub   = sdccsssubsub
      and   sector       = sdsector
      and   ciudad       = sdciudad
      and   sucursal     = sdsucursal
      and   moneda       = sdmoneda
      and   naturaleza   = "D"
      and   fecha_captura = w_fecha
      and   fecha_valida = w_fecha;

      if w_cargos_dia is null then
         let w_cargos_dia = 0;
      end if

      select sum(monto) into w_abonos_dia
      from co_detpol
      where empresa      = sdempresa
      and   ccmayor      = sdccmayor
      and   ccsub        = sdccsub
      and   ccsubsub     = sdccsubsub
      and   ccssubsub    = sdccssubsub
      and   ccsssubsub   = sdccsssubsub
      and   sector       = sdsector
      and   ciudad       = sdciudad
      and   sucursal     = sdsucursal
      and   moneda       = sdmoneda
      and   naturaleza   = "C"
      and   fecha_captura = w_fecha
      and fecha_valida = w_fecha;

      if w_abonos_dia is null then
         let w_abonos_dia = 0;
      end if

      select sum(monto) into w_debito_dia_ant
      from co_detpol
      where empresa      = sdempresa
      and   ccmayor      = sdccmayor
      and   ccsub        = sdccsub
      and   ccsubsub     = sdccsubsub
      and   ccssubsub    = sdccssubsub
      and   ccsssubsub   = sdccsssubsub
      and   sector       = sdsector
      and   ciudad       = sdciudad
      and   sucursal     = sdsucursal
      and   moneda       = sdmoneda
      and   naturaleza   = "D"
      and   fecha_valida < w_fecha
      and   fecha_captura = w_fecha;

      if w_debito_dia_ant is null then
         let w_debito_dia_ant = 0;
      end if

      select sum(monto) into w_credito_dia_ant
      from co_detpol
      where empresa      = sdempresa
      and   ccmayor      = sdccmayor
      and   ccsub        = sdccsub
      and   ccsubsub     = sdccsubsub
      and   ccssubsub    = sdccssubsub
      and   ccsssubsub   = sdccsssubsub
      and   sector       = sdsector
      and   ciudad       = sdciudad
      and   sucursal     = sdsucursal
      and   moneda       = sdmoneda
      and   naturaleza   = "C"
      and   fecha_valida < w_fecha
      and   fecha_captura = w_fecha;

      if w_credito_dia_ant is null then
         let w_credito_dia_ant = 0;
      end if

      -- Calcula saldos
      let sdcargos_dia = w_cargos_dia;
      let sdabonos_dia = w_abonos_dia;
      if sdnaturaleza_cta = "D" then
         let sdsaldo_inicio_dia = sdsaldo_fin_de_dia +
                                  w_debito_dia_ant - w_credito_dia_ant;
         let sdsaldo_fin_de_dia = sdsaldo_inicio_dia +
                                  w_cargos_dia - w_abonos_dia;
      end if

      if sdnaturaleza_cta = "A" then
         let sdsaldo_inicio_dia = sdsaldo_fin_de_dia -
                                  w_debito_dia_ant + w_credito_dia_ant;
         let sdsaldo_fin_de_dia = sdsaldo_inicio_dia -
                                  w_cargos_dia + w_abonos_dia;
      end if

      select nombre
      into   v_nomsuc
      from bdinteg:si_sucursales
      where empresa = sdempresa
      and   sucursal = sdsucursal;

      if sdsaldo_inicio_dia = 0 and sdcargos_dia = 0
         and sdabonos_dia = 0 and sdsaldo_fin_de_dia = 0 then
      else
         insert into co_balanza
         values (sdempresa,sdccmayor,sdccsub,sdccsubsub,sdccssubsub,
                 sdccsssubsub,sdsector,sdciudad,sdsucursal,sdmoneda,
                 w_fecha,sdsaldo_inicio_dia,sdcargos_dia,
                 sdabonos_dia,sdsaldo_fin_de_dia,"D",sdnaturaleza_cta,
                 sdnombre_cta,v_nomsuc," ",0);
      end if
   end foreach}
end if
end procedure;