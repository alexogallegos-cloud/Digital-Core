CREATE PROCEDURE "informix".retaux_h(dempresa char(3),dccmayor char(10),dccsub char(10),
                  dccsubsub char(10),dccssubsub char(10),dccsssubsub char(10),
                  dsector char(10),dciudad char(3),dsucursal char(4),
                  dmoneda char(2),dnaturaleza char(1),dnro_auxiliar char(12),
                  dfecha_valida date,dmonto money(18,2),tabonos money(18,2),
                  tcargos money(18,2),tsaldo money(18,2),tnum_cargos integer,
                  tnum_abonos integer,tnat_cta char(1),tauxiliar char(1),
                  pfecha_hoy date)

   define hccmayor,
          hccsub,
          hccsubsub,
          hccssubsub,
          hccsssubsub,
          hsector           char(10);
   define hmoneda           char(2);
   define hciudad           char(3);
   define hsucursal         char(4);
   define hempresa          char(3);
   define hauxiliar         char(12);
   define hmes_dia          date;
   define hcargos_dia,
          habonos_dia       money(18,2);
   define hnro_cargos_dia   smallint;
   define hnro_abonos_dia   smallint;
   define hdias_proyectado  smallint;
   define hdias_acumulado   smallint;
   define hsaldo_acumulado  money(18,2);
   define hsaldo_inicio_dia money(18,2);
   define hsaldo_fin_de_dia money(18,2);

   define v_ini_act    date;
   define v_fin_act    date;
   define v_mes_dia    date;
   define v_fecha      date;
   define v_num_dias   smallint;
   define v_meses      smallint;
   define v_fechar     char(10);
   define lv_rowid     integer;

   define v_mc1             char(2);
   define v_mc2             char(2);
   define v_ctaingini       char(10);
   define v_ctaingfin       char(10);
   define v_ctagtoini       char(10);
   define v_ctagtofin       char(10);
   define v_perganmay       char(10);
   define v_pergansub       char(10);
   define v_perganss        char(10);
   define v_pergansss       char(10);
   define v_perganssss      char(10);
   define v_pergansect      char(10);
   define vpri_dia_mes      date;

   SELECT pri_dia_mes
   INTO   vpri_dia_mes
   FROM   co_fechas
   WHERE  empresa = dempresa;

   SELECT mescierre1,   mescierre2,    cta_ing_inic,  cta_ing_final,
          cta_gto_inic, cta_gto_final, per_gan_mayor, per_gan_sub,
          per_gan_ss,   per_gan_sss,   per_gan_ssss,  per_gan_sect
   INTO   v_mc1,        v_mc2,         v_ctaingini,   v_ctaingfin,
          v_ctagtoini,  v_ctagtofin,   v_perganmay,   v_pergansub,
          v_perganss,   v_pergansss,   v_perganssss,  v_pergansect
   FROM co_param
   WHERE empresa = dempresa;

   if ((month(dfecha_valida) = v_mc1) OR
       (month(dfecha_valida) = v_mc2)) and
            dccmayor    = v_perganmay and
            dccsub      = v_pergansub and
            dccsubsub   = v_perganss and
            dccssubsub  = v_pergansss and
            dccsssubsub = v_perganssss and
            dsector     = v_pergansect THEN
      select naturaleza_cta
      into tnat_cta
      from bdinteg:si_catalog
      where
         empresa    = dempresa and
         ccmayor    = dccmayor and
         ccsub      = dccsub and
         ccsubsub   = dccsubsub and
         ccssubsub  = dccssubsub and
         ccsssubsub = dccsssubsub and
         sector     = dsector;
      let tsaldo = 0;
      if tnat_cta = "D" then
         let tsaldo = tcargos - tabonos;
      else
         let tsaldo = tabonos - tcargos;
      end if
   end if

   --- *** ACTUALIZAR SALDOS DIARIOS co_histdiasaux ***

   -- obtiene el primer dia en "co_histdiasaux" con la cta especifica desde la
   -- "fecha_valida"
   select min(mes_dia)
   into v_mes_dia
   from co_histdiasaux
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

   if ((month(dfecha_valida) = v_mc1) OR
       (month(dfecha_valida) = v_mc2)) and
           dccmayor    = v_perganmay and
           dccsub      = v_pergansub and
           dccsubsub   = v_perganss and
           dccssubsub  = v_pergansss and
           dccsssubsub = v_perganssss and
           dsector     = v_pergansect THEN
      let v_ini_act  = dfecha_valida + 1 UNITS MONTH;
      let v_fechar = v_ini_act;
      let v_fechar = v_fechar[1,2]||"/01/"||v_fechar[7,10];
      let v_ini_act = v_fechar;
   else
      let v_ini_act = dfecha_valida;
   end if
   -- *** INSERTAR LOS REGISTROS FALTANTES DESDE LA FECHA DEL MOVIMIENTO ***

   -- prepara variables a insertar en co_histdiasaux
   let hempresa    = dempresa;
   let hccmayor    = dccmayor;
   let hccsub      = dccsub;
   let hccsubsub   = dccsubsub;
   let hccssubsub  = dccssubsub;
   let hccsssubsub = dccsssubsub;
   let hsector     = dsector;
   let hciudad     = dciudad;
   let hsucursal   = dsucursal;
   let hauxiliar   = dnro_auxiliar;
   let hmoneda     = dmoneda;

   -- valores para mes_dia = fecha_valida (solo primer registro)
   let hcargos_dia       = tcargos;
   let habonos_dia       = tabonos;
   let hnro_cargos_dia   = tnum_cargos;
   let hnro_abonos_dia   = tnum_abonos;
   let hdias_proyectado  = 0;
   let hsaldo_inicio_dia = 0;

   -- prepara limites del ciclo para insertar en co_histdiasaux
   -- considerando hasta el mes anterior a la fecha de proceso (fecha_hoy)
   -- para cuentas de ingreso y gto ret. a ejerc. ant. solo actualiza fecha
   -- valida
   if ((dccmayor >= v_ctaingini AND
        dccmayor <= v_ctaingfin) OR
       (dccmayor >= v_ctagtoini AND
        dccmayor <= v_ctagtofin)) AND
      ((month(dfecha_valida) = v_mc1) OR
       (month(dfecha_valida) = v_mc2)) then
      let v_fin_act = dfecha_valida;
   else
      if v_mes_dia is null then
         let v_fin_act = vpri_dia_mes -1 units day;
      else
         let v_fin_act = v_mes_dia - 1 units day;
      end if
   end if
   let hmes_dia = v_ini_act;

   -- insertar registros que falten para la cuenta desde "fecha_valida"
   let v_num_dias = 0;
   while hmes_dia <= v_fin_act
      let v_meses = month(hmes_dia);
      let v_num_dias = v_num_dias + 1;
      let hdias_acumulado = day (hmes_dia);
      let hsaldo_fin_de_dia = tsaldo;

      if year(hmes_dia) = year(dfecha_valida) and
         month(hmes_dia) = month(dfecha_valida) then
         let v_num_dias = day(hmes_dia) - day(dfecha_valida) + 1;
      else
         let v_num_dias = hdias_acumulado;
      end if
      let hsaldo_acumulado = tsaldo * v_num_dias;

      if hmes_dia > dfecha_valida then
	 let hcargos_dia = 0;
	 let habonos_dia = 0;
	 let hnro_cargos_dia = 0;
	 let hnro_abonos_dia = 0;
	 let hsaldo_inicio_dia = tsaldo;
      end if
      if hmes_dia < pfecha_hoy then
         let lv_rowid = " ";
         select rowid
         into lv_rowid
         from co_histdiasaux
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
               mes_dia    = hmes_dia;

         if lv_rowid is null or lv_rowid = " " then
            insert
            into co_histdiasaux
            values (dempresa,hccmayor,hccsub,hccsubsub,
                    hccssubsub,hccsssubsub,hsector,hciudad,
                    hsucursal,hauxiliar,hmoneda,hmes_dia,
                    hcargos_dia,habonos_dia,hnro_cargos_dia,
                    hnro_abonos_dia,hdias_proyectado,
                    hdias_acumulado,hsaldo_acumulado,
                    hsaldo_inicio_dia,hsaldo_fin_de_dia);
         end if
      end if

      let hmes_dia = hmes_dia + 1 units day;
   end while

   if v_mes_dia is not null then    -- (existen registros para actualizar)

      -- *** ACTUALIZAR EL REGISTRO CON LA FECHA DEL MOVIMIENTO ***
      if ((month(dfecha_valida) = v_mc1) OR
          (month(dfecha_valida) = v_mc2)) and
            dccmayor    = v_perganmay and
            dccsub      = v_pergansub and
            dccsubsub   = v_perganss and
            dccssubsub  = v_pergansss and
            dccsssubsub = v_perganssss and
            dsector     = v_pergansect THEN
      else
         if v_mes_dia = dfecha_valida then
	 -- no se afecta saldo_inicio_dia
	    update co_histdiasaux
	       set nro_cargos_dia   = nro_cargos_dia + tnum_cargos,
		   cargos_dia       = cargos_dia + tcargos,
		   nro_abonos_dia   = nro_abonos_dia + tnum_abonos,
		   abonos_dia       = abonos_dia + tabonos,
		   saldo_acumulado  = saldo_acumulado + tsaldo,
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
      end if
      -- *** ACTUALIZAR LOS REGISTROS CON FECHA MAYOR A LA DEL MOVIMIENTO ***

      if v_mes_dia = dfecha_valida then
	 let v_ini_act = v_mes_dia + 1 UNITS DAY;
      else
	 let v_ini_act = v_mes_dia;
      end if
      if ((month(dfecha_valida) = v_mc1) OR
          (month(dfecha_valida) = v_mc2)) and
            dccmayor    = v_perganmay and
            dccsub      = v_pergansub and
            dccsubsub   = v_perganss and
            dccssubsub  = v_pergansss and
            dccsssubsub = v_perganssss and
            dsector     = v_pergansect THEN
         let v_ini_act  = dfecha_valida + 1 UNITS MONTH;
         let v_fechar = v_ini_act;
         let v_fechar = v_fechar[1,2]||"/01/"||v_fechar[7,10];
         let v_ini_act = v_fechar;
      end if

      -- para cuentas de ingreso y gto ret. a ejerc. ant. solo actualiza fecha
      -- valida
      if ((dccmayor >= v_ctaingini AND
                   dccmayor <= v_ctaingfin) OR
                  (dccmayor >= v_ctagtoini AND
                   dccmayor <= v_ctagtofin)) AND
                   ((month(dfecha_valida) = v_mc1) OR
                   (month(dfecha_valida) = v_mc1)) THEN
         let v_fin_act = v_ini_act;
      else
         let v_fin_act = pfecha_hoy;
      end if
      let v_num_dias = day (dfecha_valida);
      update co_histdiasaux
	 set saldo_inicio_dia = saldo_inicio_dia + tsaldo,
	     saldo_fin_de_dia = saldo_fin_de_dia + tsaldo,
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
             auxiliar   = dnro_auxiliar and
	     moneda     = dmoneda and
	     mes_dia    between v_ini_act and v_fin_act;

   end if -- (existen registros para actualizar)

end procedure;