CREATE PROCEDURE "informix".retsdomes(dempresa char(3),dccmayor char(10),dccsub char(10),
                  dccsubsub char(10),dccssubsub char(10),dccsssubsub char(10),
                  dsector char(10),dciudad char(3),dsucursal char(4),
                  dmoneda char(2),dnaturaleza char(1),dnro_auxiliar char(12),
                  dfecha_valida date,dmonto money(18,2),tabonos money(18,2),
                  tcargos money(18,2),tsaldo money(18,2),tnum_cargos integer,
                  tnum_abonos integer,tnat_cta char(1),tauxiliar char(1),
                  pfecha_hoy date,v_espergan char(1)) --JLG

   define sccmayor,
          sccsub,
          sccsubsub,
          sccssubsub,
          sccsssubsub,
          ssector           char(10);
   define smoneda           char(2);
   define sciudad           char(3);
   define ssucursal         char(4);
   define sempresa          char(3);
   define sano_mes          datetime year to month;
   define scargos_mes,
          sabonos_mes       money(18,2);
   define snro_cargos_mes   smallint;
   define snro_abonos_mes   smallint;
   define sdias_proyectado  smallint;
   define sdias_acumulado   smallint;
   define ssaldo_acumulado  money(18,2);
   define ssaldo_inicio_mes money(18,2);
   define ssaldo_fin_de_mes money(18,2);

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

   define v_ini_act	    datetime year to month;
   define v_fin_act	    datetime year to month;
   define v_ano_mes	    datetime year to month;
   define v_fecha           date;
   define v_num_mes	    smallint;
   define lv_cuanto         integer;
   define lv_rowid          integer;
   define v_anio            char(4);
   define v_meso            char(2);
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

   if tnat_cta = "D" then
      let tsaldo = tcargos - tabonos;
   else
      let tsaldo = tabonos - tcargos;
   end if

   --- *** ACTUALIZAR SALDOS MENSUALES co_sdomes ***

   if ((month(dfecha_valida) = v_mc1) OR
       (month(dfecha_valida) = v_mc2)) and
            dccmayor    = v_perganmay and
            dccsub      = v_pergansub and
            dccsubsub   = v_perganss and
            dccssubsub  = v_pergansss and
            dccsssubsub = v_perganssss and
            dsector     = v_pergansect AND v_espergan = "S" THEN
      LET dfecha_valida = dfecha_valida + 1 units month;
   end if

   -- *** INSERTAR LOS REGISTROS FALTANTES DESDE EL MES DEL MOVIMIENTO ***

   -- prepara variables a insertar en co_sdomes
   let sempresa    = dempresa;
   let sccmayor    = dccmayor;
   let sccsub      = dccsub;
   let sccsubsub   = dccsubsub;
   let sccssubsub  = dccssubsub;
   let sccsssubsub = dccsssubsub;
   let ssector     = dsector;
   let sciudad     = dciudad;
   let ssucursal   = dsucursal;
   let smoneda     = dmoneda;

   -- valores para ano_mes = fecha_valida (solo primer registro)
   let scargos_mes       = tcargos;
   let sabonos_mes       = tabonos;
   let snro_cargos_mes   = tnum_cargos;
   let snro_abonos_mes   = tnum_abonos;
   let sdias_proyectado  = 0;
   let ssaldo_inicio_mes = 0;
   let ssaldo_acumulado = (diasmes (year(dfecha_valida),
       month(dfecha_valida)) - day (dfecha_valida) + 1) * tsaldo;

   -- prepara limites del ciclo para insertar en co_sdomes
   -- considerando hasta el mes anterior a la fecha de proceso (fecha_hoy)
   -- para cuentas de ingreso y gto ret. a ejerc. ant. solo actualiza fecha
   -- valida

      let v_ini_act = extend (dfecha_valida, year to month);

      let vpri_dia_mes = vpri_dia_mes -1 units day;
      let v_fin_act = extend(vpri_dia_mes, year to month);

      let sano_mes = v_ini_act;

   -- insertar registros que falten para la cuenta desde "fecha_valida"
   let v_num_mes = 0;
   while sano_mes <= v_fin_act
      let v_num_mes = v_num_mes + 1;
      let sdias_acumulado = diasmes (year(sano_mes), month(sano_mes));
      let ssaldo_fin_de_mes = tsaldo;

      if sano_mes > extend (dfecha_valida, year to month) then
	 let scargos_mes       = 0;
	 let sabonos_mes       = 0;
	 let snro_cargos_mes   = 0;
	 let snro_abonos_mes   = 0;
	 let ssaldo_inicio_mes = tsaldo;
         let ssaldo_acumulado  = tsaldo * sdias_acumulado;
      end if

      let lv_rowid = " ";

      select rowid
      into lv_rowid
      from co_sdomes
      where
          empresa    = dempresa and
          ccmayor    = dccmayor and
          ccsub      = dccsub and
          ccsubsub   = dccsubsub and
          ccssubsub  = dccssubsub and
          ccsssubsub = dccsssubsub and
          sector     = dsector and
          ciudad     = dciudad and
          sucursal   = dsucursal and
          moneda     = dmoneda and
          ano_mes    = sano_mes;

      if lv_rowid is null or lv_rowid = " " then
         if (sano_mes > extend (dfecha_valida, year to month)) AND
            ((dccmayor >= v_ctaingini AND
              dccmayor <= v_ctaingfin) OR
             (dccmayor >= v_ctagtoini AND
              dccmayor <= v_ctagtofin)) AND
            ((month(dfecha_valida) = v_mc1) OR
             (month(dfecha_valida) = v_mc1)) AND (v_espergan = "N") THEN
         else
            insert
            into co_sdomes
            values (dempresa,sccmayor,sccsub,sccsubsub,sccssubsub,sccsssubsub,
                    ssector,sciudad,ssucursal,smoneda,sano_mes,scargos_mes,sabonos_mes,
                    snro_cargos_mes,snro_abonos_mes,sdias_proyectado,
                    sdias_acumulado,ssaldo_acumulado,ssaldo_inicio_mes,
                    ssaldo_fin_de_mes);
         end if
      else
         -- el registro es de perdidas y ganancias y de fecha_posterior al ejercicio
         -- anterior
         if v_espergan = "S" THEN
            if sano_mes > extend (dfecha_valida, year to month) THEN

             -- es perdidas y ganancias y la fecha es posterior al ejercicio anterior

               update co_sdomes
               set saldo_inicio_mes = saldo_inicio_mes + tsaldo,
	       saldo_fin_de_mes = saldo_fin_de_mes + tsaldo,
	       saldo_acumulado  = saldo_acumulado  + tsaldo *
		                  diasmes(year(ano_mes), month(ano_mes))
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
	             ano_mes    = sano_mes;
            end if

         else
            -- el registro es de resultados y fecha = fecha_valida solo afecta
            -- saldos al ejercicio anterior
            if sano_mes = extend (dfecha_valida,year to month) THEN
               if ((dccmayor >= v_ctaingini AND
                    dccmayor <= v_ctaingfin) OR
                   (dccmayor >= v_ctagtoini AND
                    dccmayor <= v_ctagtofin)) AND
                  ((month(dfecha_valida) = v_mc1) OR
                   (month(dfecha_valida) = v_mc1)) AND v_espergan = "N" THEN
                  -- no se afecta saldo_inicio_dia
                  update co_sdomes
                  set nro_cargos_mes  = nro_cargos_mes + tnum_cargos,
                     cargos_mes       = cargos_mes + tcargos,
                     nro_abonos_mes   = nro_abonos_mes + tnum_abonos,
                     abonos_mes       = abonos_mes + tabonos,
                     saldo_acumulado  = saldo_acumulado +
                                        (diasmes (year(dfecha_valida),
                                         month(dfecha_valida)) -
                                         day (dfecha_valida) + 1) * tsaldo,
                     saldo_fin_de_mes = saldo_fin_de_mes + tsaldo
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
		        ano_mes    = sano_mes;

                else
                   -- no se afecta saldo_inicio_mes
	           update co_sdomes
                   set nro_cargos_mes  = nro_cargos_mes + tnum_cargos,
                      cargos_mes       = cargos_mes + tcargos,
                      nro_abonos_mes   = nro_abonos_mes + tnum_abonos,
                      abonos_mes       = abonos_mes + tabonos,
                      saldo_acumulado  = saldo_acumulado +
                                         (diasmes (year(dfecha_valida),
                                          month(dfecha_valida)) -
                                          day (dfecha_valida) + 1) * tsaldo,
                      saldo_fin_de_mes = saldo_fin_de_mes + tsaldo
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
		   ano_mes    = sano_mes;
               end if
            else
               if ((dccmayor >= v_ctaingini AND
                    dccmayor <= v_ctaingfin) OR
                   (dccmayor >= v_ctagtoini AND
                    dccmayor <= v_ctagtofin)) AND
                  ((month(dfecha_valida) = v_mc1) OR
                   (month(dfecha_valida) = v_mc1)) AND v_espergan = "N" THEN
               else
                  update co_sdomes
   	          set saldo_inicio_mes = saldo_inicio_mes + tsaldo,
	              saldo_fin_de_mes = saldo_fin_de_mes + tsaldo,
	              saldo_acumulado  = saldo_acumulado  + tsaldo *
			   	         diasmes(year(ano_mes), month(ano_mes))
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
	                ano_mes    = sano_mes;
               end if
            end if
         end if
      end if

      let sano_mes = sano_mes + 1 units month;
   end while

end procedure;