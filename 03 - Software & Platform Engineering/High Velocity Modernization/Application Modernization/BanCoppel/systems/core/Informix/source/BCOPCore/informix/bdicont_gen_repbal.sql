CREATE PROCEDURE "informix".gen_repbal(p_val char(2),p_ext char(2),
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
define w_fecha1       date;
define w_fecha2       date;
define lv_ano_mes datetime year to month;
define lv_ano_mes1 datetime year to month;
define v_ano            char(4);
define v_mes           char(2);
define c_promedio_anual       money(18,2);
define mes_ant                int;

define p_dFecha                date;

define vcod_ret         VARCHAR(10); 
define vmensaje         VARCHAR(255); 


--set debug file to "/tmp/gen_repbal_concu.out";
--trace on;

let c_sucursal="";
let p_dFecha = w_fecha;
let vcod_ret = '00000'; 
let vmensaje = '';



select fecha_hoy
into lv_fechac
from co_fechas
where empresa = v_empresa;

SET LOCK MODE TO WAIT;

begin

delete from co_balanza
where usuario = v_usuario;

   -- BALANZA ANUALIZADA
   if p_ext = "AN" then
      let v_ano = year(w_fecha);
      let v_mes = month(w_fecha);
      LET w_fecha1 = mdy(01,01,v_ano);
      foreach
         select co_histsdodias.empresa,co_histsdodias.ccmayor,
                co_histsdodias.ccsub,
                co_histsdodias.ccsubsub,co_histsdodias.ccssubsub,
                co_histsdodias.ccsssubsub,co_histsdodias.sector,
                --co_histsdodias.ciudad,
                co_histsdodias.moneda,
                sum(cargos_dia),sum(abonos_dia),sum(saldo_inicio_dia),
                sum(saldo_fin_de_dia),naturaleza_cta
         into   c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                --c_ciudad,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_histsdodias,bdinteg:si_catalog
         where co_histsdodias.empresa = bdinteg:si_catalog.empresa
         and co_histsdodias.empresa = v_empresa
         and bdinteg:si_catalog.empresa = v_empresa
         and co_histsdodias.ccmayor = bdinteg:si_catalog.ccmayor
         and co_histsdodias.ccsub = bdinteg:si_catalog.ccsub
         and co_histsdodias.ccsubsub = bdinteg:si_catalog.ccsubsub
         and co_histsdodias.ccssubsub = bdinteg:si_catalog.ccssubsub
         and co_histsdodias.ccsssubsub = bdinteg:si_catalog.ccsssubsub
         and co_histsdodias.sector = bdinteg:si_catalog.sector
         and co_histsdodias.mes_dia between w_fecha1 and w_fecha
         --and co_histsdodias.moneda = v_moneda
         GROUP BY 1,2,3,4,5,6,7,8,13

         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,"",
                 c_sucursal,c_moneda,lv_fechac,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,0,v_usuario);
      end foreach
   end if

   -- BALANZA PREVIA
   if p_ext = "PR" then
      EXECUTE PROCEDURE gen_balprev(v_empresa,lv_fechac,v_usuario);
      EXECUTE PROCEDURE ctas_nuevas(v_empresa,lv_fechac,v_usuario);
   end if

   -- BALANZA DIARIA MISMO MES A FECHA HOY
   if p_ext = "DM" then
      let lv_mes_dia = w_fecha;
      foreach
         select co_sdodias.empresa,co_sdodias.ccmayor,co_sdodias.ccsub,
                co_sdodias.ccsubsub,co_sdodias.ccssubsub,
                co_sdodias.ccsssubsub,co_sdodias.sector,
                --co__sdodias.ciudad,
                co_sdodias.moneda,
                sum(cargos_dia),sum(abonos_dia),sum(saldo_inicio_dia),
                sum(saldo_fin_de_dia),naturaleza_cta
         into
                c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                --c_ciudad,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_sdodias,bdinteg:si_catalog
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
         --and co_sdodias.moneda = v_moneda
         --GROUP BY 1,2,3,4,5,6,7,8,9,14
         GROUP BY 1,2,3,4,5,6,7,8,13

         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,
                 --c_ciudad,
                 "",c_sucursal,c_moneda,w_fecha,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,0,v_usuario);
      end foreach
   end if

   -- BALANZA DIARIA CONSOLIDADA MONEDA NACIONAL
	IF p_ext = "DM"  THEN
		IF v_moneda = '01' THEN
			EXECUTE PROCEDURE bdicont:sp_generarbalanzadiariaconsolidadamn(p_dFecha) INTO vcod_ret,vmensaje;
		END IF
	END IF
	-- BALANZA DIARIA CONSOLIDADA MONEDA EXTRANJERA
	IF p_ext = "DM"  THEN
		IF v_moneda = '02' THEN
			EXECUTE PROCEDURE bdicont:sp_generarbalanzadiariaconsolidadamx(p_dFecha) INTO vcod_ret,vmensaje;
		END IF
	END IF

   -- BALANZA DIARIA DE OTRO MES AL DE LA FECHA DE HOY
   if p_ext = "DO" then
      foreach
         select co_histsdodias.empresa,co_histsdodias.ccmayor,
                co_histsdodias.ccsub,
                co_histsdodias.ccsubsub,co_histsdodias.ccssubsub,
                co_histsdodias.ccsssubsub,co_histsdodias.sector,
                --co_histsdodias.ciudad,
                co_histsdodias.moneda,
                sum(cargos_dia),sum(abonos_dia),sum(saldo_inicio_dia),
                sum(saldo_fin_de_dia),naturaleza_cta
         into   c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                --c_ciudad,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_histsdodias,bdinteg:si_catalog
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
         --and co_histsdodias.moneda = v_moneda
         --GROUP BY 1,2,3,4,5,6,7,8,9,14
         GROUP BY 1,2,3,4,5,6,7,8,13

         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,
                 --c_ciudad,
                 "",
                 c_sucursal,c_moneda,w_fecha,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,0,v_usuario);
      end foreach
   end if

   -- BALANZA MENSUAL
   if p_ext = "MA" then
      let lv_mes_dia = w_fecha;
      let lv_ano_mes = extend(lv_mes_dia,year to month);
      foreach
         select co_sdomes.empresa,co_sdomes.ccmayor,co_sdomes.ccsub,
                co_sdomes.ccsubsub,co_sdomes.ccssubsub,
                co_sdomes.ccsssubsub,co_sdomes.sector,
                --co_sdomes.ciudad,
                co_sdomes.moneda,
                sum(cargos_mes),sum(abonos_mes),sum(saldo_inicio_mes),
                sum(saldo_fin_de_mes),naturaleza_cta
         into
                c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                --c_ciudad,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_sdomes,bdinteg:si_catalog
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
         --and co_sdomes.moneda = v_moneda
         GROUP BY 1,2,3,4,5,6,7,8,13

         insert into co_balanza
         values (c_empresa,c_ccmayor,c_ccsub,
                 c_ccsubsub,c_ccssubsub,
                 c_ccsssubsub,c_sector,"",
                 "",c_moneda,w_fecha,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,0,v_usuario);
      end foreach
   end if

   -- BALANZA MENSUAL CONSOLIDADA MONEDA NACIONAL
	IF p_ext = "MA"  THEN
		IF v_moneda = '01' THEN
			EXECUTE PROCEDURE bdicont:sp_generarbalanzamensualconsolidadamn(p_dFecha) INTO vcod_ret,vmensaje ;
		END IF
	END IF
	-- BALANZA MENSUAL CONSOLIDADA MONEDA EXTRANJERA
	IF p_ext = "MA"  THEN
		IF v_moneda = '02' THEN
			EXECUTE PROCEDURE bdicont:sp_generarbalanzamensualconsolidadamx(p_dFecha) INTO vcod_ret,vmensaje ;
		END IF
	END IF

   -- BALANZA PROMEDIO DEL MISMO MES
   if p_ext = "PM" then
      let c_promedio_anual = 0;
      foreach
         select co_sdodias.empresa,co_sdodias.ccmayor,co_sdodias.ccsub,
                co_sdodias.ccsubsub,co_sdodias.ccssubsub,
                co_sdodias.ccsssubsub,co_sdodias.sector,
                --co_sdodias.ciudad,
                co_sdodias.moneda,
                0,nvl(sum(saldo_fin_de_dia),0),
                nvl(sum(saldo_acumulado/dias_acumulado),0),
                0,naturaleza_cta
         into
                c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                --c_ciudad,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_sdodias,bdinteg:si_catalog
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
         --and co_sdodias.moneda = v_moneda
         GROUP BY 1,2,3,4,5,6,7,8,13

	 let mes_ant = month(w_fecha) - 1;

         --LET w_fecha1 = mdy(mes_ant,day(w_fecha),year(w_fecha));
         let c_ccmayor=c_ccmayor;
         let c_ccsub=c_ccsub;
         let c_ccsubsub=c_ccsubsub;
         let c_ccssubsub=c_ccssubsub;
         let c_ccsssubsub=c_ccsssubsub;
         let c_sector=c_sector;

         select nvl(sum(saldo_fin_de_mes),0),
                nvl(sum(saldo_acumulado/dias_acumulado),0)
         into   c_cargos_dia,
                c_saldo_actual
         from co_sdomes,bdinteg:si_catalog
         where co_sdomes.empresa = bdinteg:si_catalog.empresa
         and co_sdomes.empresa = v_empresa
         and bdinteg:si_catalog.empresa = v_empresa
         and co_sdomes.ccmayor = bdinteg:si_catalog.ccmayor
         and co_sdomes.ccsub = bdinteg:si_catalog.ccsub
         and co_sdomes.ccsubsub = bdinteg:si_catalog.ccsubsub
         and co_sdomes.ccssubsub = bdinteg:si_catalog.ccssubsub
         and co_sdomes.ccsssubsub = bdinteg:si_catalog.ccsssubsub
         and co_sdomes.sector = bdinteg:si_catalog.sector
         and co_sdomes.ccmayor = c_ccmayor
         and co_sdomes.ccsub = c_ccsub
         and co_sdomes.ccsubsub = c_ccsubsub
         and co_sdomes.ccssubsub = c_ccssubsub
         and co_sdomes.ccsssubsub = c_ccsssubsub
         and co_sdomes.sector = c_sector
         and year(co_sdomes.ano_mes) = year(w_fecha)
         and month(co_sdomes.ano_mes) = mes_ant
         and co_sdomes.moneda = c_moneda;

         {if month(w_fecha)=1 then
            let w_fecha1 = w_fecha;
         end if
         if month(w_fecha)=2 then
            let w_fecha1 = w_fecha - 1 units month;
         end if
         if month(w_fecha)=3 then
            let w_fecha1 = w_fecha - 2 units month;
         end if
         if month(w_fecha)=4 then
            let w_fecha1 = w_fecha - 3 units month;
         end if
         if month(w_fecha)=5 then
            let w_fecha1 = w_fecha - 4 units month;
         end if
         if month(w_fecha)=6 then
            let w_fecha1 = w_fecha - 5 units month;
         end if
	 if month(w_fecha)=7 then
            let w_fecha1 = w_fecha - 6 units month;
         end if
         if month(w_fecha)=8 then
            let w_fecha1 = w_fecha - 7 units month;
         end if
         if month(w_fecha)=9 then
            let w_fecha1 = w_fecha - 8 units month;
         end if
         if month(w_fecha)=10 then
            let w_fecha1 = w_fecha - 9 units month;
         end if
         if month(w_fecha)=11 then
            let w_fecha1 = w_fecha - 10 units month;
         end if
         if month(w_fecha)=12 then
            let w_fecha1 = w_fecha - 11 units month;
         end if}

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
                 c_ccsssubsub,c_sector,"",
                 "",c_moneda,w_fecha,
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
                co_histsdodias.moneda,
                0,nvl(sum(saldo_fin_de_dia),0),
                nvl(sum(saldo_acumulado/dias_acumulado),0),
                0,naturaleza_cta
         into
                c_empresa,c_ccmayor,c_ccsub,c_ccsubsub,c_ccssubsub,
                c_ccsssubsub,c_sector,
                --c_ciudad,
                c_moneda,
                c_cargos_dia,c_abonos_dia,c_saldo_anterior,
                c_saldo_actual,c_naturaleza_cta
         from co_histsdodias,bdinteg:si_catalog
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
         --and co_histsdodias.moneda = v_moneda
         GROUP BY 1,2,3,4,5,6,7,8,13

	 let mes_ant = month(w_fecha) - 1;

         --LET w_fecha1 = mdy(mes_ant,day(w_fecha),year(w_fecha));

        --LET w_fecha1 = mdy(mes_ant,day(w_fecha),year(w_fecha));
        let c_ccmayor=c_ccmayor;
        let c_ccsub=c_ccsub;
        let c_ccsubsub=c_ccsubsub;
        let c_ccssubsub=c_ccssubsub;
        let c_ccsssubsub=c_ccsssubsub;
        let c_sector=c_sector;

         select nvl(sum(saldo_fin_de_mes),0),
                nvl(sum(saldo_acumulado/dias_acumulado),0)
         into   c_cargos_dia,
                c_saldo_actual
         from co_sdomes,bdinteg:si_catalog
         where co_sdomes.empresa = bdinteg:si_catalog.empresa
         and co_sdomes.empresa = v_empresa
         and bdinteg:si_catalog.empresa = v_empresa
         and co_sdomes.ccmayor = bdinteg:si_catalog.ccmayor
         and co_sdomes.ccsub = bdinteg:si_catalog.ccsub
         and co_sdomes.ccsubsub = bdinteg:si_catalog.ccsubsub
         and co_sdomes.ccssubsub = bdinteg:si_catalog.ccssubsub
         and co_sdomes.ccsssubsub = bdinteg:si_catalog.ccsssubsub
         and co_sdomes.sector = bdinteg:si_catalog.sector
         and co_sdomes.ccmayor = c_ccmayor
         and co_sdomes.ccsub = c_ccsub
         and co_sdomes.ccsubsub = c_ccsubsub
         and co_sdomes.ccssubsub = c_ccssubsub
         and co_sdomes.ccsssubsub = c_ccsssubsub
         and co_sdomes.sector = c_sector
         and year(co_sdomes.ano_mes) = year(w_fecha)
         and month(co_sdomes.ano_mes) = mes_ant
         and co_sdomes.moneda = c_moneda;


         {if month(w_fecha)=1 then
            let w_fecha1 = w_fecha;
         end if
         if month(w_fecha)=2 then
            let w_fecha1 = w_fecha - 1 units month;
         end if
         if month(w_fecha)=3 then
            let w_fecha1 = w_fecha - 2 units month;
         end if
         if month(w_fecha)=4 then
            let w_fecha1 = w_fecha - 3 units month;
         end if
         if month(w_fecha)=5 then
            let w_fecha1 = w_fecha - 4 units month;
         end if
         if month(w_fecha)=6 then
            let w_fecha1 = w_fecha - 5 units month;
         end if
	 if month(w_fecha)=7 then
            let w_fecha1 = w_fecha - 6 units month;
         end if
         if month(w_fecha)=8 then
            let w_fecha1 = w_fecha - 7 units month;
         end if
         if month(w_fecha)=9 then
            let w_fecha1 = w_fecha - 8 units month;
         end if
         if month(w_fecha)=10 then
            let w_fecha1 = w_fecha - 9 units month;
         end if
         if month(w_fecha)=11 then
            let w_fecha1 = w_fecha - 10 units month;
         end if
         if month(w_fecha)=12 then
            let w_fecha1 = w_fecha - 11 units month;
         end if}

         let lv_mes_dia = '01/01/'||year(w_fecha);
         let lv_ano_mes1 = extend(lv_mes_dia,year to month);
         --let lv_mes_dia = w_fecha1;
         let lv_mes_dia = w_fecha;
         let lv_ano_mes = extend(lv_mes_dia,year to month);

         --SELECT nvl(sum(saldo_acumulado/month(ano_mes)),0)
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
                 c_ccsssubsub,c_sector,"",
                 "",c_moneda,w_fecha,
                 c_saldo_anterior,c_cargos_dia,
                 c_abonos_dia,c_saldo_actual,"D"," "," "," "," ",0,c_promedio_anual,v_usuario);
      end foreach
   end if
   EXECUTE PROCEDURE gen_totalbalanza(v_empresa,p_val,w_fecha,v_moneda,v_usuario);
end;
end procedure;