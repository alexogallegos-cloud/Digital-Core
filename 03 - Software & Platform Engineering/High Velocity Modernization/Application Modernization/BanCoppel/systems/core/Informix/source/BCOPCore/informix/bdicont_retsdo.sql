CREATE PROCEDURE "informix".retsdo(dempresa char(3),dccmayor char(10),dccsub char(10),
                  dccsubsub char(10),dccssubsub char(10),dccsssubsub char(10),
                  dsector char(10),dciudad char(3),dsucursal char(4),
                  dmoneda char(2),dnaturaleza char(1),dnro_auxiliar char(12),
                  dfecha_valida date,dmonto money(18,2),tabonos money(18,2),
                  tcargos money(18,2),tsaldo money(18,2),tnum_cargos integer,
                  tnum_abonos integer,tnat_cta char(1),tauxiliar char(1),
                  pfecha_hoy date)

define sccmayor,
       sccsub,
       sccsubsub,
       sccssubsub,
       sccsssubsub,
       ssector           char(10);
define smoneda           char(2);
define sciudad           char(3);
define ssucursal         char(4);
define s_empresa         char(3);
define smes_dia          date;
define scargos_dia,
       sabonos_dia       money(18,2);
define snro_cargos_dia   smallint;
define snro_abonos_dia   smallint;
define sdias_proyectado  smallint;
define sdias_acumulado   smallint;
define ssaldo_acumulado  money(18,2);
define ssaldo_inicio_dia money(18,2);
define ssaldo_fin_de_dia money(18,2);

define v_ini_act         date;
define v_fin_act         date;
define v_mes_dia         date;
define v_fecha           date;
define v_num_dias        smallint;
define lv_fec_fin        date;
define lv_saldo_inicio,
       lv_saldo_fin,
       lv_sdo_acumulado,
       lv_1,lv_2,lv_3    money(18,2);

 
let v_num_dias = 0;
   --- *** ACTUALIZAR SALDOS DIARIOS CO_SDODIAS ***

   -- obtiene el primer dia en "co_sdodias" con la cuenta especifica desde la
   -- "fecha_valida"
   select min(mes_dia)
   into v_mes_dia
   from co_sdodias
   where empresa    = dempresa and
         ccmayor    = dccmayor and
         ccsub      = dccsub and
         ccsubsub   = dccsubsub and
         ccssubsub  = dccssubsub and
         ccsssubsub = dccsssubsub and
         sector     = dsector and
         ciudad     = dciudad and
         sucursal   = dsucursal and
         moneda     = dmoneda and
         mes_dia   >= dfecha_valida;

   -- *** INSERTAR LOS REGISTROS FALTANTES DESDE LA FECHA DEL MOVIMIENTO ***

   -- prepara variables a insertar en co_sdodias
   let sccmayor    = dccmayor;
   let sccsub      = dccsub;
   let sccsubsub   = dccsubsub;
   let sccssubsub  = dccssubsub;
   let sccsssubsub = dccsssubsub;
   let ssector     = dsector;
   let sciudad     = dciudad;
   let ssucursal   = dsucursal;
   let smoneda     = dmoneda;

   -- valores para mes_dia = fecha_valida (solo primer registro)
   let scargos_dia       = tcargos;
   let sabonos_dia       = tabonos;
   let snro_cargos_dia   = tnum_cargos;
   let snro_abonos_dia   = tnum_abonos;
   let sdias_proyectado  = 0;
   let ssaldo_inicio_dia = 0;


   -- prepara limites del ciclo para insertar en co_sdodias
   -- considerando hasta un dia antes de la fecha de proceso (fecha_hoy)
   let v_ini_act = dfecha_valida;
   if v_mes_dia is null or v_mes_dia = " " then
      let v_fin_act = pfecha_hoy ;
   else
      let v_fin_act = v_mes_dia - 1 units day;
   end if

   let smes_dia = v_ini_act ;

   -- insertar registros que falten para la cuenta desde "fecha_valida"
   while smes_dia <= v_fin_act

      let sdias_acumulado = day (smes_dia);
      let ssaldo_fin_de_dia = tsaldo;

      if month(smes_dia) = month (dfecha_valida) then
         let v_num_dias = day(smes_dia) - day(dfecha_valida) + 1;
      else
         let v_num_dias = sdias_acumulado;
      end if
      let ssaldo_acumulado = tsaldo * v_num_dias;

      if smes_dia > dfecha_valida then
         let scargos_dia = 0;
         let sabonos_dia = 0;
         let snro_cargos_dia = 0;
         let snro_abonos_dia = 0;
         let ssaldo_inicio_dia = tsaldo;
      end if

      if month (smes_dia) = month (pfecha_hoy) then
         insert into co_sdodias values (dempresa,sccmayor,sccsub,sccsubsub,
                                        sccssubsub,sccsssubsub,ssector,sciudad,
                                        ssucursal,smoneda,smes_dia,
                                        scargos_dia,sabonos_dia,snro_cargos_dia,
                                        snro_abonos_dia,sdias_proyectado,
                                        sdias_acumulado,ssaldo_acumulado,
                                        ssaldo_inicio_dia,ssaldo_fin_de_dia);
      end if

      let smes_dia = smes_dia + 1 units day;
   end while

   if v_mes_dia is not null then    -- (existen registros para actualizar)

      -- *** ACTUALIZAR EL REGISTRO CON LA FECHA DEL MOVIMIENTO ***

      if v_mes_dia = dfecha_valida then
         -- no se afecta saldo_inicio_dia
         update co_sdodias
            set nro_cargos_dia   = nro_cargos_dia + tnum_cargos,
                cargos_dia       = cargos_dia + tcargos,
                nro_abonos_dia   = nro_abonos_dia + tnum_abonos,
                abonos_dia       = abonos_dia + tabonos,
                saldo_acumulado  = saldo_acumulado + tsaldo,
                dias_acumulado   = day(mes_dia),
                saldo_fin_de_dia = saldo_fin_de_dia + tsaldo
          where empresa    = dempresa and
                ccmayor    = dccmayor and
                ccsub      = dccsub and
                ccsubsub   = dccsubsub and
                ccssubsub  = dccssubsub and
                ccsssubsub = dccsssubsub and
                sector     = dsector and
                ciudad     = dciudad and
                sucursal   = dsucursal and
                moneda     = dmoneda and
                mes_dia    = v_mes_dia;
      end if
      -- *** ACTUALIZAR LOS REGISTROS CON FECHA MAYOR A LA DEL MOVIMIENTO ***

      if v_mes_dia = dfecha_valida then
         let v_ini_act = v_mes_dia + 1 units day;
      else
         let v_ini_act = v_mes_dia;
      end if
      let v_fin_act = pfecha_hoy;

      update co_sdodias
         set saldo_inicio_dia = saldo_inicio_dia + tsaldo,
             saldo_fin_de_dia = saldo_fin_de_dia + tsaldo,
             dias_acumulado   = day(mes_dia),
             saldo_acumulado  = saldo_acumulado + tsaldo *
                                acumdias (mes_dia, dfecha_valida)
       where empresa    = dempresa and
             ccmayor    = dccmayor and
             ccsub      = dccsub and
             ccsubsub   = dccsubsub and
             ccssubsub  = dccssubsub and
             ccsssubsub = dccsssubsub and
             sector     = dsector and
             ciudad     = dciudad and
             sucursal   = dsucursal and
             moneda     = dmoneda and
             mes_dia    between v_ini_act and v_fin_act;
   end if -- (existen registros para actualizar)
return;
end procedure;