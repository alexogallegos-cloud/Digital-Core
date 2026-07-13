CREATE PROCEDURE "informix".gen_repbalreg(p_val char(2),p_ext char(2),
                            w_fecha date,v_empresa char(3),v_moneda char(2),v_usuario char(10))
define c_empresa              char(3);
define c_ccmayor              char(10);
define c_ccsub                char(10);
define c_ccsubsub             char(10);
define c_ccssubsub            char(10);
define c_ccsssubsub           char(10);
define c_sector               char(10);
define c_ciudad               char(3);
define c_sucursal             char(4);
define c_moneda               char(2);
define c_cargos_dia           money(18,2);
define c_abonos_dia           money(18,2);
define c_saldo_anterior       money(18,2);
define c_saldo_actual         money(18,2);
define c_naturaleza_cta       char(1);
define lv_fechac date;
define lv_mes_dia date;
define lv_mes_dia1 date;
define lv_ano_mes 	      datetime year to month;
define lv_ano_mes1 	      datetime year to month;

define w_fecha1       	      date;
define w_fecha2       	      date;
define v_ano                  char(4);
define v_mes                  char(2);
define c_promedio_anual       money(18,2);
define mes_ant                int;

DEFINE v_plaza                CHAR(3);
DEFINE v_regional             CHAR(3);

LET v_plaza         = "";
LET v_regional      = "";

select fecha_hoy
into lv_fechac
from co_fechas
where empresa = v_empresa;

let lv_fechac = w_fecha;
let lv_mes_dia = w_fecha;
--let lv_mes_dia1=w_fecha1;

SET LOCK MODE TO WAIT;

BEGIN

delete from co_balanza
where usuario = v_usuario;

   -- BALANZA ANUALIZADA
   if p_ext = "AN" then
      foreach
         select co_histsdodias.empresa,co_histsdodias.ccmayor,
                co_histsdodias.ccsub,
                co_histsdodias.ccsubsub,co_histsdodias.ccssubsub,
                co_histsdodias.ccsssubsub,co_histsdodias.sector,
                --co_histsdodias.ciudad,
                bdinteg:si_plazas.regional,
                --co_histsdodias.sucursal,
                co_histsdodias.moneda,
                sum(cargos_dia),sum(abonos_dia),sum(saldo_inicio_dia),
                sum(saldo_fin_de_dia),naturaleza_cta
         into   c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                c_ciudad,
                --c_sucursal,
                c_moneda,c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_histsdodias,bdinteg:si_catalog,bdinteg:si_sucursales,bdinteg:si_plazas
         where co_histsdodias.empresa = bdinteg:si_catalog.empresa
         and co_histsdodias.empresa = v_empresa
         and bdinteg:si_catalog.empresa = v_empresa
         and co_histsdodias.ccmayor = bdinteg:si_catalog.ccmayor
         and co_histsdodias.ccsub = bdinteg:si_catalog.ccsub
         and co_histsdodias.ccsubsub = bdinteg:si_catalog.ccsubsub
         and co_histsdodias.ccssubsub = bdinteg:si_catalog.ccssubsub
         and co_histsdodias.ccsssubsub = bdinteg:si_catalog.ccsssubsub
         and co_histsdodias.sector = bdinteg:si_catalog.sector
         and co_histsdodias.mes_dia = w_fecha
         and co_histsdodias.empresa = bdinteg:si_sucursales.empresa
         and co_histsdodias.sucursal = bdinteg:si_sucursales.sucursal
         and co_histsdodias.empresa = bdinteg:si_plazas.empresa
         and bdinteg:si_sucursales.plaza = bdinteg:si_plazas.plaza
         GROUP BY 1,8,2,3,4,5,6,7,9,14
	 ORDER BY 1,2,3,4,5,6,7,8,9,14

	 {SELECT plaza
	 INTO v_plaza
	 FROM bdinteg:si_sucursales
	 WHERE empresa = v_empresa
	  AND sucursal = trim(c_sucursal);

	 SELECT regional
	 INTO v_regional
	 FROM bdinteg:si_plazas
	 WHERE empresa = v_empresa
	  AND plaza = trim(v_plaza);

	 LET c_ciudad = v_regional;}
	 
         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,c_ciudad,
                 --c_sucursal,
                 "",c_moneda,lv_fechac,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,0,v_usuario);
      end foreach
   end if

   -- BALANZA PREVIA
   if p_ext = "PR" then
      EXECUTE PROCEDURE gen_balprevreg(v_empresa,lv_fechac,v_usuario);
      EXECUTE PROCEDURE ctas_nuevasreg(v_empresa,lv_fechac,v_usuario);
   end if

   -- BALANZA DIARIA MISMO MES A FECHA HOY
   if p_ext = "DM" then
      foreach
         select co_sdodias.empresa,co_sdodias.ccmayor,co_sdodias.ccsub,
                co_sdodias.ccsubsub,co_sdodias.ccssubsub,
                co_sdodias.ccsssubsub,co_sdodias.sector,
                --co_sdodias.ciudad,
                bdinteg:si_plazas.regional,
                --co_sdodias.sucursal,
                co_sdodias.moneda,
                sum(cargos_dia),sum(abonos_dia),sum(saldo_inicio_dia),
                sum(saldo_fin_de_dia),naturaleza_cta
         into
                c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                c_ciudad,
                --c_sucursal,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_sdodias,bdinteg:si_catalog,bdinteg:si_sucursales,bdinteg:si_plazas
         where co_sdodias.empresa = bdinteg:si_catalog.empresa
         and co_sdodias.empresa = v_empresa
         and bdinteg:si_catalog.empresa = v_empresa
         and co_sdodias.ccmayor = bdinteg:si_catalog.ccmayor
         and co_sdodias.ccsub = bdinteg:si_catalog.ccsub
         and co_sdodias.ccsubsub = bdinteg:si_catalog.ccsubsub
         and co_sdodias.ccssubsub = bdinteg:si_catalog.ccssubsub
         and co_sdodias.ccsssubsub = bdinteg:si_catalog.ccsssubsub
         and co_sdodias.sector = bdinteg:si_catalog.sector
         and co_sdodias.mes_dia = w_fecha
         and co_sdodias.empresa = bdinteg:si_sucursales.empresa
         and co_sdodias.sucursal = bdinteg:si_sucursales.sucursal
         and co_sdodias.empresa = bdinteg:si_plazas.empresa
         and bdinteg:si_sucursales.plaza = bdinteg:si_plazas.plaza
         GROUP BY 1,8,2,3,4,5,6,7,9,14
	 ORDER BY 1,2,3,4,5,6,7,8,9,14

	 {SELECT plaza
	 INTO v_plaza
	 FROM bdinteg:si_sucursales
	 WHERE empresa = v_empresa
	  AND sucursal = trim(c_sucursal);

	 SELECT regional
	 INTO v_regional
	 FROM bdinteg:si_plazas
	 WHERE empresa = v_empresa
	  AND plaza = trim(v_plaza);

	 LET c_ciudad = v_regional;}
	 
         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,c_ciudad,
                 --c_sucursal,
                 "",c_moneda,lv_fechac,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,0,v_usuario);
      end foreach
   end if

   -- BALANZA DIARIA DE OTRO MES AL DE LA FECHA DE HOY
   if p_ext = "DO" then
      foreach
         select co_histsdodias.empresa,co_histsdodias.ccmayor,
                co_histsdodias.ccsub,
                co_histsdodias.ccsubsub,co_histsdodias.ccssubsub,
                co_histsdodias.ccsssubsub,co_histsdodias.sector,
                --co_histsdodias.ciudad,
                bdinteg:si_plazas.regional,
                --co_histsdodias.sucursal,
                co_histsdodias.moneda,
                sum(cargos_dia),sum(abonos_dia),sum(saldo_inicio_dia),
                sum(saldo_fin_de_dia),naturaleza_cta
         into   c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                c_ciudad,
                --c_sucursal,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_histsdodias,bdinteg:si_catalog,bdinteg:si_sucursales,bdinteg:si_plazas
         where co_histsdodias.empresa = bdinteg:si_catalog.empresa
         and co_histsdodias.empresa = v_empresa
         and bdinteg:si_catalog.empresa = v_empresa
         and co_histsdodias.ccmayor = bdinteg:si_catalog.ccmayor
         and co_histsdodias.ccsub = bdinteg:si_catalog.ccsub
         and co_histsdodias.ccsubsub = bdinteg:si_catalog.ccsubsub
         and co_histsdodias.ccssubsub = bdinteg:si_catalog.ccssubsub
         and co_histsdodias.ccsssubsub = bdinteg:si_catalog.ccsssubsub
         and co_histsdodias.sector = bdinteg:si_catalog.sector
         and co_histsdodias.mes_dia = w_fecha
         and co_histsdodias.empresa = bdinteg:si_sucursales.empresa
         and co_histsdodias.sucursal = bdinteg:si_sucursales.sucursal
         and co_histsdodias.empresa = bdinteg:si_plazas.empresa
         and bdinteg:si_sucursales.plaza = bdinteg:si_plazas.plaza
         GROUP BY 1,8,2,3,4,5,6,7,9,14
	 ORDER BY 1,2,3,4,5,6,7,8,9,14

	 {SELECT plaza
	 INTO v_plaza
	 FROM bdinteg:si_sucursales
	 WHERE empresa = v_empresa
	  AND sucursal = trim(c_sucursal);

	 SELECT regional
	 INTO v_regional
	 FROM bdinteg:si_plazas
	 WHERE empresa = v_empresa
	  AND plaza = trim(v_plaza);

	 LET c_ciudad = v_regional;}
	 
         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,c_ciudad,
                 --c_sucursal,
                 "",c_moneda,lv_fechac,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,0,v_usuario);
      end foreach
   end if

   -- BALANZA MENSUAL
   if p_ext = "MA" then
      let lv_mes_dia = w_fecha;
      --let lv_mes_dia1 = w_fecha1;
      let lv_ano_mes = extend(lv_mes_dia,year to month);
      --let lv_ano_mes1 = extend(lv_mes_dia1,year to month);
      foreach
         select co_sdomes.empresa,co_sdomes.ccmayor,co_sdomes.ccsub,
                co_sdomes.ccsubsub,co_sdomes.ccssubsub,
                co_sdomes.ccsssubsub,co_sdomes.sector,
                --co_sdomes.ciudad,
                bdinteg:si_plazas.regional,
                --co_sdomes.sucursal,
                co_sdomes.moneda,
                sum(cargos_mes),sum(abonos_mes),sum(saldo_inicio_mes),
                sum(saldo_fin_de_mes),naturaleza_cta
         into
                c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                c_ciudad,
                --c_sucursal,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_sdomes,bdinteg:si_catalog,bdinteg:si_sucursales,bdinteg:si_plazas
         where co_sdomes.empresa = bdinteg:si_catalog.empresa
         and co_sdomes.empresa = v_empresa
         and bdinteg:si_catalog.empresa = v_empresa
         and co_sdomes.ccmayor = bdinteg:si_catalog.ccmayor
         and co_sdomes.ccsub = bdinteg:si_catalog.ccsub
         and co_sdomes.ccsubsub = bdinteg:si_catalog.ccsubsub
         and co_sdomes.ccssubsub = bdinteg:si_catalog.ccssubsub
         and co_sdomes.ccsssubsub = bdinteg:si_catalog.ccsssubsub
         and co_sdomes.sector = bdinteg:si_catalog.sector
         and co_sdomes.ano_mes = lv_ano_mes
         and co_sdomes.empresa = bdinteg:si_sucursales.empresa
         and co_sdomes.sucursal = bdinteg:si_sucursales.sucursal
         and co_sdomes.empresa = bdinteg:si_plazas.empresa
         and bdinteg:si_sucursales.plaza = bdinteg:si_plazas.plaza
         GROUP BY 1,8,2,3,4,5,6,7,9,14
	 ORDER BY 1,2,3,4,5,6,7,8,9,14

	 {SELECT plaza
	 INTO v_plaza
	 FROM bdinteg:si_sucursales
	 WHERE empresa = v_empresa
	  AND sucursal = trim(c_sucursal);

	 SELECT regional
	 INTO v_regional
	 FROM bdinteg:si_plazas
	 WHERE empresa = v_empresa
	  AND plaza = trim(v_plaza);

	 LET c_ciudad = v_regional;}
	 
         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,c_ciudad,
                 --c_sucursal,
                 "",c_moneda,lv_fechac,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,0,v_usuario);
      end foreach
   end if

   -- BALANZA PROMEDIO DEL MISMO MES
   if p_ext = "PM" then
      foreach
         select co_sdodias.empresa,co_sdodias.ccmayor,co_sdodias.ccsub,
                co_sdodias.ccsubsub,co_sdodias.ccssubsub,
                co_sdodias.ccsssubsub,co_sdodias.sector,
                --co_sdodias.ciudad,
                bdinteg:si_plazas.regional,
                --co_sdodias.sucursal,
                co_sdodias.moneda,
                sum(dias_acumulado),sum(saldo_acumulado),
                sum(saldo_acumulado/day(w_fecha)),
                0,naturaleza_cta
         into
                c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                c_ciudad,
                --c_sucursal,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_sdodias,bdinteg:si_catalog,bdinteg:si_sucursales,bdinteg:si_plazas
         where co_sdodias.empresa = bdinteg:si_catalog.empresa
         and co_sdodias.empresa = v_empresa
         and bdinteg:si_catalog.empresa = v_empresa
         and co_sdodias.ccmayor = bdinteg:si_catalog.ccmayor
         and co_sdodias.ccsub = bdinteg:si_catalog.ccsub
         and co_sdodias.ccsubsub = bdinteg:si_catalog.ccsubsub
         and co_sdodias.ccssubsub = bdinteg:si_catalog.ccssubsub
         and co_sdodias.ccsssubsub = bdinteg:si_catalog.ccsssubsub
         and co_sdodias.sector = bdinteg:si_catalog.sector
         and co_sdodias.mes_dia = w_fecha
         and co_sdodias.empresa = bdinteg:si_sucursales.empresa
         and co_sdodias.sucursal = bdinteg:si_sucursales.sucursal
         and co_sdodias.empresa = bdinteg:si_plazas.empresa
         and bdinteg:si_sucursales.plaza = bdinteg:si_plazas.plaza
         GROUP BY 1,8,2,3,4,5,6,7,9,14
         ORDER BY 1,2,3,4,5,6,7,8,9,14

	 {SELECT plaza
	 INTO v_plaza
	 FROM bdinteg:si_sucursales
	 WHERE empresa = v_empresa
	  AND sucursal = trim(c_sucursal);

	 SELECT regional
	 INTO v_regional
	 FROM bdinteg:si_plazas
	 WHERE empresa = v_empresa
	  AND plaza = trim(v_plaza);

	 LET c_ciudad = v_regional;}
	 
         let lv_mes_dia = '01/01/'||year(w_fecha);
         let lv_ano_mes1 = extend(lv_mes_dia,year to month);
         --let lv_mes_dia = w_fecha1;
         let lv_mes_dia = w_fecha - 1 units month;
         let lv_ano_mes = extend(lv_mes_dia,year to month);

         SELECT nvl(sum(saldo_acumulado/dias_acumulado),0)
         INTO  c_promedio_anual
         FROM co_sdomes
         WHERE co_sdomes.empresa = c_empresa
         and co_sdomes.ccmayor = c_ccmayor
         and co_sdomes.ccsub = c_ccsub
         and co_sdomes.ccsubsub = c_ccsubsub
         and co_sdomes.ccssubsub = c_ccssubsub
         and co_sdomes.ccsssubsub = c_ccsssubsub
         and co_sdomes.sector = c_sector
         and co_sdomes.ano_mes >= lv_ano_mes1
         and co_sdomes.ano_mes <= lv_ano_mes;

	 LET c_promedio_anual=c_promedio_anual/month(lv_ano_mes);

         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,c_ciudad,
                 --c_sucursal,
                 "",c_moneda,lv_fechac,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,c_promedio_anual,v_usuario);
      end foreach
   end if

   -- BALANZA PROMEDIO DE OTRO MES AL DE LA FECHA DE HOY
   if p_ext = "PO" then
      foreach
         select co_histsdodias.empresa,co_histsdodias.ccmayor,
                co_histsdodias.ccsub,
                co_histsdodias.ccsubsub,co_histsdodias.ccssubsub,
                co_histsdodias.ccsssubsub,co_histsdodias.sector,
                --co_histsdodias.ciudad,
                bdinteg:si_plazas.regional,
                --co_histsdodias.sucursal,
                co_histsdodias.moneda,
                sum(dias_acumulado),sum(saldo_acumulado),
                sum(saldo_acumulado/day(w_fecha)),
                0,naturaleza_cta
         into
                c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                c_ciudad,
                --c_sucursal,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_histsdodias,bdinteg:si_catalog,bdinteg:si_sucursales,bdinteg:si_plazas
         where co_histsdodias.empresa = bdinteg:si_catalog.empresa
         and co_histsdodias.empresa = v_empresa
         and bdinteg:si_catalog.empresa = v_empresa
         and co_histsdodias.ccmayor = bdinteg:si_catalog.ccmayor
         and co_histsdodias.ccsub = bdinteg:si_catalog.ccsub
         and co_histsdodias.ccsubsub = bdinteg:si_catalog.ccsubsub
         and co_histsdodias.ccssubsub = bdinteg:si_catalog.ccssubsub
         and co_histsdodias.ccsssubsub = bdinteg:si_catalog.ccsssubsub
         and co_histsdodias.sector = bdinteg:si_catalog.sector
         and co_histsdodias.mes_dia = w_fecha
         and co_histsdodias.empresa = bdinteg:si_sucursales.empresa
         and co_histsdodias.sucursal = bdinteg:si_sucursales.sucursal
         and co_histsdodias.empresa = bdinteg:si_plazas.empresa
         and bdinteg:si_sucursales.plaza = bdinteg:si_plazas.plaza
         GROUP BY 1,8,2,3,4,5,6,7,9,14
         ORDER BY 1,2,3,4,5,6,7,8,9,14

	 {SELECT plaza
	 INTO v_plaza
	 FROM bdinteg:si_sucursales
	 WHERE empresa = v_empresa
	  AND sucursal = trim(c_sucursal);

	 SELECT regional
	 INTO v_regional
	 FROM bdinteg:si_plazas
	 WHERE empresa = v_empresa
	  AND plaza = trim(v_plaza);

	 LET c_ciudad = v_regional;}
	 
         let lv_mes_dia = '01/01/'||year(w_fecha);
         let lv_ano_mes1 = extend(lv_mes_dia,year to month);
         --let lv_mes_dia = w_fecha1;
         let lv_mes_dia = w_fecha;
         let lv_ano_mes = extend(lv_mes_dia,year to month);

         SELECT nvl(sum(saldo_acumulado/dias_acumulado),0)
         INTO  c_promedio_anual
         FROM co_sdomes
         WHERE co_sdomes.empresa = c_empresa
         and co_sdomes.ccmayor = c_ccmayor
         and co_sdomes.ccsub = c_ccsub
         and co_sdomes.ccsubsub = c_ccsubsub
         and co_sdomes.ccssubsub = c_ccssubsub
         and co_sdomes.ccsssubsub = c_ccsssubsub
         and co_sdomes.sector = c_sector
         and co_sdomes.ano_mes >= lv_ano_mes1
         and co_sdomes.ano_mes <= lv_ano_mes;

	 LET c_promedio_anual=c_promedio_anual/(month(lv_ano_mes));

         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,c_ciudad,
                 --c_sucursal,
                 "",c_moneda,lv_fechac,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,c_promedio_anual,v_usuario);
      end foreach
   end if
   EXECUTE PROCEDURE gen_totalbalanza(v_empresa,p_val,w_fecha,v_moneda,v_usuario);
END;
end procedure;