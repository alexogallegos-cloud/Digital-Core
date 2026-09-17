CREATE PROCEDURE "informix".retsdo_h(dempresa char(3),dccmayor char(10),dccsub char(10), 
		dccsubsub char(10),dccssubsub char(10),dccsssubsub char(10), 
		dsector char(10),dciudad char(3),dsucursal char(4), 
		dmoneda char(2),dnaturaleza char(1),dnro_auxiliar char(12), 
		dfecha_valida date,dmonto money(18,2),tabonos money(18,2), 
		tcargos money(18,2),tsaldo money(18,2),tnum_cargos integer, 
		tnum_abonos integer,tnat_cta char(1),tauxiliar char(1), 
		pfecha_hoy date,v_espergan char(1))

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
--   define v_espergan        char(1);

--   LET v_espergan = "N";

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

--   if ((month(dfecha_valida) = v_mc1) OR
--       (month(dfecha_valida) = v_mc2)) and
--            dccmayor    = v_perganmay and
--            dccsub      = v_pergansub and
--            dccsubsub   = v_perganss and
--            dccssubsub  = v_pergansss and
--            dccsssubsub = v_perganssss and
--            dsector     = v_pergansect THEN
--      LET v_espergan = "S";
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
--   end if

   -- prepara variables a insertar en co_histsdodias
   let hempresa    = dempresa;
   let hccmayor    = dccmayor;
   let hccsub      = dccsub;
   let hccsubsub   = dccsubsub;
   let hccssubsub  = dccssubsub;
   let hccsssubsub = dccsssubsub;
   let hsector     = dsector;
   let hciudad     = dciudad;
   let hsucursal   = dsucursal;
   let hmoneda     = dmoneda;

   -- valores para mes_dia = fecha_valida (solo primer registro)
   let hcargos_dia       = tcargos;
   let habonos_dia       = tabonos;
   let hnro_cargos_dia   = tnum_cargos;
   let hnro_abonos_dia   = tnum_abonos;
   let hdias_proyectado  = 0;
   let hsaldo_inicio_dia = 0;

   -- prepara limites del ciclo para insertar o actualizar en co_histsdodias
   -- considerando hasta el mes anterior a la fecha de proceso (fecha_hoy)
   -- para cuentas de ingreso y gto ret. a ejerc. ant. solo actualiza fecha
   -- los registros con fecha = fecha_valida

   let v_fin_act = vpri_dia_mes -1 units day;

   let hmes_dia = dfecha_valida;

   -- insertar registros que falten para la cuenta desde "fecha_valida"
   let v_num_dias = 0;
   while hmes_dia <= v_fin_act
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

      let lv_rowid = " ";
      select rowid
      into lv_rowid
      from co_histsdodias
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
            mes_dia    = hmes_dia;

      if lv_rowid is null or lv_rowid = " " then
         if (hmes_dia > dfecha_valida) AND
            ((dccmayor >= v_ctaingini AND
              dccmayor <= v_ctaingfin) OR
             (dccmayor >= v_ctagtoini AND
              dccmayor <= v_ctagtofin)) AND
            ((month(dfecha_valida) = v_mc1) OR
             (month(dfecha_valida) = v_mc2)) AND (v_espergan = "N") THEN
	       insert
	       into co_histsdodias
	       values (dempresa,hccmayor,hccsub,hccsubsub,
		       hccssubsub,hccsssubsub,hsector,hciudad,
		       hsucursal,hmoneda,hmes_dia,
		       hcargos_dia,habonos_dia,hnro_cargos_dia,
		       hnro_abonos_dia,hdias_proyectado,
		       hdias_acumulado,hsaldo_acumulado,
		       hsaldo_inicio_dia,hsaldo_fin_de_dia);
         else
              if dccmayor=v_perganmay and
                 dccsub=v_pergansub and
                 dccsubsub=v_perganss and
                 dccssubsub=v_pergansss and
                 dccsssubsub=v_perganssss and
                 dsector=v_pergansect then
              else
                 if (hmes_dia = dfecha_valida) THEN
	               insert
	               into co_histsdodias
	               values (dempresa,hccmayor,hccsub,hccsubsub,
	                       hccssubsub,hccsssubsub,hsector,hciudad,
	                       hsucursal,hmoneda,hmes_dia,
	                       hcargos_dia,habonos_dia,hnro_cargos_dia,
	                       hnro_abonos_dia,hdias_proyectado,
	                       hdias_acumulado,hsaldo_acumulado,
	                       hsaldo_inicio_dia,hsaldo_fin_de_dia);
                 else
	               insert
	               into co_histsdodias
	               values (dempresa,hccmayor,hccsub,hccsubsub,
	                       hccssubsub,hccsssubsub,hsector,hciudad,
	                       hsucursal,hmoneda,hmes_dia,
	                       hcargos_dia,habonos_dia,hnro_cargos_dia,
	                       hnro_abonos_dia,hdias_proyectado,
	                       hdias_acumulado,hsaldo_acumulado,
	                       hsaldo_inicio_dia,hsaldo_fin_de_dia);
              	 end if
            end if
         end if
      else
         -- el registro es de perdidas y ganancias y de fecha_posterior al ejercicio
         -- anterior
         if dccmayor=v_perganmay and
            dccsub=v_pergansub and
            dccsubsub=v_perganss and
            dccssubsub=v_pergansss and
            dccsssubsub=v_perganssss and
            dsector=v_pergansect and v_espergan = "S" THEN
            if hmes_dia > dfecha_valida THEN
               -- es perdidas y ganancias y la fecha es posterior al ejercicio anterior
               update co_histsdodias
               set saldo_inicio_dia = saldo_inicio_dia + tsaldo,
	           saldo_fin_de_dia = saldo_fin_de_dia + tsaldo,
	           saldo_acumulado  = saldo_acumulado + tsaldo *
	           acumdias (mes_dia, hmes_dia)
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
	             mes_dia    = hmes_dia;
            end if

         else
            -- el registro es de resultados y fecha = fecha_valida solo afecta
            -- saldos al ejercicio anterior
            if hmes_dia = dfecha_valida THEN
               if ((dccmayor >= v_ctaingini AND
                    dccmayor <= v_ctaingfin) OR
                   (dccmayor >= v_ctagtoini AND
                    dccmayor <= v_ctagtofin)) AND
                  ((month(dfecha_valida) = v_mc1) OR
                   (month(dfecha_valida) = v_mc2)) AND v_espergan = "N" THEN
                  -- no se afecta saldo_inicio_dia
	          update co_histsdodias
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
		        moneda     = dmoneda and
		        mes_dia    = hmes_dia;
               else
                  -- no se afecta saldo_inicio_dia
	          update co_histsdodias
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
		        moneda     = dmoneda and
		        mes_dia    = hmes_dia;
               end if
            else
               if ((dccmayor >= v_ctaingini AND
                    dccmayor <= v_ctaingfin) OR
                   (dccmayor >= v_ctagtoini AND
                    dccmayor <= v_ctagtofin)) AND
                  ((month(dfecha_valida) = v_mc1) OR
                   (month(dfecha_valida) = v_mc2)) AND v_espergan = "N" THEN
                  update co_histsdodias
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
	                moneda     = dmoneda and
	                mes_dia    = hmes_dia;
               else
                  update co_histsdodias
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
	                moneda     = dmoneda and
	                mes_dia    = hmes_dia;
               end if
            end if
         end if
      end if

      let hmes_dia = hmes_dia + 1 units day;
   end while

end procedure;