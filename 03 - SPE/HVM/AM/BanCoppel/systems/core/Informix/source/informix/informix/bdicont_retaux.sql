CREATE PROCEDURE "informix".retaux(dempresa char(3),dccmayor char(10),dccsub char(10),
              dccsubsub char(10),dccssubsub char(10),dccsssubsub char(10),
              dsector char(10),dciudad char(3),dsucursal char(4),
              dmoneda char(2),dnaturaleza char(1),dnro_auxiliar char(12),
              dfecha_valida date,dmonto money(18,2),tabonos money(18,2),
              tcargos money(18,2),tsaldo money(18,2),tnum_cargos integer,
              tnum_abonos integer,tnat_cta char(1),tauxiliar char(1),
              pfecha_hoy date)

define accmayor,
       accsub,
       accsubsub,
       accssubsub,
       accsssubsub,
       asector           char(10);
define amoneda           char(2);
define aciudad           char(3);
define asucursal         char(4);
define a_empresa         char(3);
define aauxiliar        char(12);
define ames_dia          date;
define acargos_dia,
       aabonos_dia       money(18,2);
define anro_cargos_dia   smallint;
define anro_abonos_dia   smallint;
define adias_proyectado  smallint;
define adias_acumulados  smallint;
define asaldo_acumulado  money(18,2);
define asaldo_inicio_dia money(18,2);
define asaldo_fin_de_dia money(18,2);

define v_ini_act         date;
define v_fin_act         date;
define v_mes_dia         date;
define v_fecha           date;
define v_num_dias        smallint;


-- ****************************************************************************
-- Inicia proceso de actualizacion de saldos diarios de auxiliares.
-- ****************************************************************************

let v_num_dias = 0;
   -- obtiene el primer dia en "co_diasaux" con la cuenta especifica desde la
   -- "fecha_valida"
   select min(mes_dia)
   into v_mes_dia
   from co_diasaux
   where empresa    = dempresa and
         ccmayor    = dccmayor and
         ccsub      = dccsub and
         ccsubsub   = dccsubsub and
         ccssubsub  = dccssubsub and
         ccsssubsub = dccsssubsub and
         sector     = dsector and
         ciudad     = dciudad and
         sucursal   = dsucursal and
         auxiliar   = dnro_auxiliar and
         moneda     = dmoneda and
         mes_dia   >= dfecha_valida;

   -- *** INSERTAR LOS REGISTROS FALTANTES DESDE LA FECHA DEL MOVIMIENTO ***

   -- prepara variables a insertar en co_diasaux
   let accmayor    = dccmayor;
   let accsub      = dccsub;
   let accsubsub   = dccsubsub;
   let accssubsub  = dccssubsub;
   let accsssubsub = dccsssubsub;
   let asector     = dsector;
   let aciudad     = dciudad;
   let asucursal   = dsucursal;
   let aauxiliar   = dnro_auxiliar;
   let amoneda     = dmoneda;

   -- valores para mes_dia = fecha_valida (solo primer registro)
   let acargos_dia = tcargos;
   let aabonos_dia = tabonos;
   let anro_cargos_dia = tnum_cargos;
   let anro_abonos_dia = tnum_abonos;
   let adias_proyectado = 0;
   let asaldo_inicio_dia = 0;

   -- prepara limites del ciclo para insertar en co_diasaux
   -- considerando hasta un dia antes de la fecha de proceso (fecha_hoy)
   let v_ini_act = dfecha_valida;
   if v_mes_dia is null then
      let v_fin_act = pfecha_hoy;
   else
      let v_fin_act = v_mes_dia - 1 units day;
   end if

   let ames_dia = v_ini_act;

   -- insertar registros que falten para la cuenta desde "fecha_valida"
   while ames_dia <= v_fin_act
      --let v_num_dias = v_num_dias + 1;
      let adias_acumulados = day (ames_dia);
      let asaldo_fin_de_dia = tsaldo;

      if month(ames_dia) = month(dfecha_valida) then
         let v_num_dias = day(ames_dia) - day(dfecha_valida) + 1;
      else
         let v_num_dias = adias_acumulados;
      end if
      let asaldo_acumulado = tsaldo * v_num_dias;

      if ames_dia > dfecha_valida then
         let acargos_dia = 0;
         let aabonos_dia = 0;
         let anro_cargos_dia = 0;
         let anro_abonos_dia = 0;
         let asaldo_inicio_dia = tsaldo;
      end if

      if month (pfecha_hoy) = month (ames_dia) then
         insert into co_diasaux values (dempresa,accmayor,accsub,accsubsub,
                                        accssubsub,accsssubsub,asector,aciudad,
                                        asucursal,aauxiliar,amoneda,ames_dia,
                                        acargos_dia,aabonos_dia,anro_cargos_dia,
                                        anro_abonos_dia,adias_proyectado,
                                        adias_acumulados,asaldo_acumulado,
                                        asaldo_inicio_dia,asaldo_fin_de_dia);
      end if

      let ames_dia = ames_dia + 1 units day;
   end while

   if v_mes_dia is not null then    -- (existen registros para actualizar)

      -- *** ACTUALIZAR EL REGISTRO CON LA FECHA DEL MOVIMIENTO ***

      if v_mes_dia = dfecha_valida then
         -- no se afecta saldo_inicio_dia
         update co_diasaux
            set nro_cargos_dia   = nro_cargos_dia + tnum_cargos,
                cargos_dia       = cargos_dia + tcargos,
                nro_abonos_dia   = nro_abonos_dia + tnum_abonos,
                abonos_dia       = abonos_dia + tabonos,
                saldo_acumulado  = saldo_acumulado + tsaldo,
                dias_acumulados  = day(mes_dia),
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
                auxiliar   = dnro_auxiliar and
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

      update co_diasaux
         set saldo_inicio_dia = saldo_inicio_dia + tsaldo,
             saldo_fin_de_dia = saldo_fin_de_dia + tsaldo,
             dias_acumulados  = day(mes_dia),
             saldo_acumulado  = saldo_acumulado + tsaldo *
                                acumdias (mes_dia, dfecha_valida)
         where empresa  = dempresa and
             ccmayor    = dccmayor and
             ccsub      = dccsub and
             ccsubsub   = dccsubsub and
             ccssubsub  = dccssubsub and
             ccsssubsub = dccsssubsub and
             sector     = dsector and
             ciudad     = dciudad and
             sucursal   = dsucursal and
             auxiliar   = dnro_auxiliar and
             moneda     = dmoneda and
             mes_dia    between v_ini_act and v_fin_act;

   end if -- (existen registros para actualizar)
end procedure;