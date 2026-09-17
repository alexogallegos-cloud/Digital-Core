CREATE PROCEDURE "informix".cierre(pempresa char(3),pfecha_hoy date)
RETURNING char(5);

   DEFINE sql_err INTEGER;

   DEFINE cod_ret          char(5);
   DEFINE vccmayor,
          vccsub,
          vccsubsub,
          vccssubsub,
          vccsssubsub,
          vsector           char(10);
   DEFINE vmoneda           char(2);
   DEFINE vciudad           char(3);
   DEFINE vsucursal         char(4);
   DEFINE v_empresa         char(3);
   DEFINE vmes_dia          date;
   DEFINE v_ano             char(4);
   DEFINE vcargos_dia,
          vabonos_dia       money(18,2);
   DEFINE vnro_cargos_dia   smallint;
   DEFINE vnro_abonos_dia   smallint;
   DEFINE vdias_proyectado  smallint;
   DEFINE vdias_acumulado   smallint;
   DEFINE vsaldo_acumulado  money(18,2);
   DEFINE vsaldo_inicio_dia money(18,2);
   DEFINE vsaldo_fin_de_dia money(18,2);
   DEFINE vabonos           money(18,2);
   DEFINE vcargos           money(18,2);
   DEFINE vnum_abonos       integer;
   DEFINE vnum_cargos       integer;
   DEFINE v_sql             char(500);
   DEFINE v_natcta          char(1);
   DEFINE v_fecha           char(8);
   DEFINE v_pridiames,
          v_ultdiames,
          v_prihabmes,
          v_ulthabmes,
          v_fechant,
          v_proxfecha       date;
   DEFINE dempresa,
          dciudad,
          dsucursal         char(4);
   DEFINE dccmayor,
          dccsub,
          dccsubsub,
          dccssubsub,
          dccsssubsub,
          dsector           char(10);
   DEFINE dmoneda           char(2);
   DEFINE dnaturaleza       char(1);
   DEFINE dnro_auxiliar     char(12);
   DEFINE dfecha_valida     date;
   DEFINE dmonto            money(18,2);

   DEFINE w_dia_hoy         smallint;

   DEFINE tabonos           money(18,2);
   DEFINE tcargos           money(18,2);
   DEFINE tsaldo            money(18,2);
   DEFINE tnum_cargos       smallint;
   DEFINE tnum_abonos       smallint;
   DEFINE tnat_cta          char(1);
   DEFINE tauxiliar         char(1);

   DEFINE mabonos,
          mcargos,
          msaldo            money(18,2);
   DEFINE mnum_cargos,
          mnum_abonos       integer;

   DEFINE v_mc1             char(2);
   DEFINE v_mc2             char(2);
   DEFINE v_ctaingini       char(10);
   DEFINE v_ctaingfin       char(10);
   DEFINE v_ctagtoini       char(10);
   DEFINE v_ctagtofin       char(10);
   DEFINE v_perganmay       char(10);
   DEFINE v_pergansub       char(10);
   DEFINE v_perganss        char(10);
   DEFINE v_pergansss       char(10);
   DEFINE v_perganssss      char(10);
   DEFINE v_pergansect      char(10);
   DEFINE v_canret          char(15);
   DEFINE lv_cuantos_C      smallint;
   DEFINE lv_cuantos_D      smallint;
   DEFINE v_cero            smallint;
   DEFINE v_blanco          char(1);
   DEFINE v_hay             smallint;
   DEFINE v_espergan        char(1);
   DEFINE pfecha_hoy1       date;
   DEFINE vexiste           integer;

	ON EXCEPTION SET sql_err 
        LET cod_ret = sql_err;
        RETURN cod_ret;
     END EXCEPTION;
	
   LET v_cero = 0;
   LET v_blanco = " ";
   LET v_ano = year(pfecha_hoy);
   LET cod_ret = "153";
   LET vexiste = 1;

    IF EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
				                    WHERE cierre_fecha = pfecha_hoy
                                      AND descripcion_cierre="CIERRE"
									  AND codigo_retorno = '000') THEN
   
		LET cod_ret = "999";
		RETURN cod_ret;
	END IF

   SELECT pri_hab_mes,ult_hab_mes,fecha_ant,prox_fecha ,pri_dia_mes,ult_dia_mes
   INTO   v_prihabmes,v_ulthabmes,v_fechant,v_proxfecha,v_pridiames,v_ultdiames
   FROM   co_fechas
   WHERE  empresa = pempresa;

   LET w_dia_hoy = day(pfecha_hoy);

   SELECT mescierre1,   mescierre2,    cta_ing_inic,  cta_ing_final,
          cta_gto_inic, cta_gto_final, per_gan_mayor, per_gan_sub,
          per_gan_ss,   per_gan_sss,   per_gan_ssss,  per_gan_sect
   INTO   v_mc1,        v_mc2,         v_ctaingini,   v_ctaingfin,
          v_ctagtoini,  v_ctagtofin,   v_perganmay,   v_pergansub,
          v_perganss,   v_pergansss,   v_perganssss,  v_pergansect
   FROM co_param
   WHERE empresa = pempresa;

   IF month(pfecha_hoy) >= "01" AND month(pfecha_hoy) <= v_mc1 THEN
      LET v_fecha = v_mc1||"01"||v_ano;
   END IF
   IF month(pfecha_hoy) > v_mc1 AND month(pfecha_hoy) <= v_mc2 THEN
      LET v_fecha = v_mc2||"01"||v_ano;
   END IF

   SELECT d.empresa   , d.ccmayor, d.ccsub , d.ccsubsub, d.ccssubsub,
         d.ccsssubsub, d.sector , d.ciudad, filtrasuc (sucursal, region_suc)
         sucursal    , d.moneda , d.naturaleza, d.nro_auxiliar , d.fecha_valida,
         sum(d.monto) monto
   FROM   co_diario d, bdinteg:si_catalog c
   WHERE  d.empresa    = pempresa AND
          d.ccmayor    = c.ccmayor AND
          d.ccsub      = c.ccsub AND
          d.ccsubsub   = c.ccsubsub AND
          d.ccssubsub  = c.ccssubsub AND
          d.ccsssubsub = c.ccsssubsub AND
          d.sector     = c.sector AND
          c.empresa    = pempresa
   GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
   INTO TEMP movtos WITH NO LOG;

   CREATE inDEX idx_movtos ON movtos
      (empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
       sector, ciudad, sucursal, moneda);

   UPDATE STATISTICS MEDIUM FOR TABLE movtos (empresa, ccmayor, 
	   ccsub, ccsubsub, ccssubsub, ccsssubsub,
       sector, ciudad, sucursal, moneda);

   FOREACH
      SELECT c.*, i.naturaleza_cta, i.auxiliar
      INTO   v_empresa, vccmayor, vccsub, vccsubsub, vccssubsub,
             vccsssubsub,vsector,vciudad,vsucursal,vmoneda,vmes_dia,vcargos_dia,
             vabonos_dia,vnro_cargos_dia,vnro_abonos_dia,vdias_proyectado,
             vdias_acumulado,vsaldo_acumulado,vsaldo_inicio_dia,vsaldo_fin_de_dia,
             tnat_cta,tauxiliar
      FROM  co_sdodias c, bdinteg:si_catalog i
      WHERE c.empresa    = pempresa AND
            c.ccmayor    = i.ccmayor AND
            c.ccsub      = i.ccsub AND
            c.ccsubsub   = i.ccsubsub AND
            c.ccssubsub  = i.ccssubsub AND
            c.ccsssubsub = i.ccsssubsub AND
            c.sector     = i.sector AND
            i.empresa    = pempresa AND
            c.mes_dia    = pfecha_hoy
      FOREACH
         SELECT empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
                sector, ciudad, sucursal, moneda, naturaleza, nro_auxiliar,
                fecha_valida, monto
         INTO   dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,dccsssubsub,
                dsector,dciudad,dsucursal,dmoneda,dnaturaleza,dnro_auxiliar,
                dfecha_valida,dmonto
         FROM movtos
         WHERE empresa    = pempresa
           AND ccmayor    = vccmayor
           AND ccsub      = vccsub
           AND ccsubsub   = vccsubsub
           AND ccssubsub  = vccssubsub
           AND ccsssubsub = vccsssubsub
           AND sector     = vsector
           AND ciudad     = vciudad
           AND sucursal   = vsucursal
           AND moneda     = vmoneda

         SELECT COUNT(*)
         INTO lv_cuantos_C
         FROM co_diario
         WHERE empresa    = pempresa
           AND ccmayor    = vccmayor
           AND ccsub      = vccsub
           AND ccsubsub   = vccsubsub
           AND ccssubsub  = vccssubsub
           AND ccsssubsub = vccsssubsub
           AND sector     = vsector
           AND ciudad     = vciudad
           AND sucursal   = vsucursal
           AND moneda     = vmoneda
           AND naturaleza = "C";

        SELECT COUNT(*)
         INTO lv_cuantos_D
         FROM co_diario
         WHERE empresa    = pempresa
           AND ccmayor    = vccmayor
           AND ccsub      = vccsub
           AND ccsubsub   = vccsubsub
           AND ccssubsub  = vccssubsub
           AND ccsssubsub = vccsssubsub
           AND sector     = vsector
           AND ciudad     = vciudad
           AND sucursal   = vsucursal
           AND moneda     = vmoneda
           AND naturaleza = "D";


        IF dnaturaleza = "C" THEN    -- Credito Abono
            LET tabonos = dmonto;
            LET tcargos = 0;
            LET tnum_abonos = lv_cuantos_C;
            LET tnum_cargos = 0;
         ELSE
            LET tabonos = 0;
            LET tcargos = dmonto;
            LET tnum_abonos = 0;
            LET tnum_cargos = lv_cuantos_D;
         END IF

         SELECT naturaleza_cta
         INTO   tnat_cta
         FROM bdinteg:si_catalog
         WHERE empresa  = v_empresa AND
         ccmayor    = dccmayor AND
         ccsub      = dccsub AND
         ccsubsub   = dccsubsub AND
         ccssubsub  = dccssubsub AND
         ccsssubsub = dccsssubsub AND
         sector     = dsector;

         IF tnat_cta = "D" THEN
            LET tsaldo = tcargos - tabonos;
         ELSE
            LET tsaldo = tabonos - tcargos;
         END IF

         LET msaldo = tsaldo;
         LET mabonos = tabonos;
         LET mcargos = tcargos;
         LET mnum_abonos = tnum_abonos;
         LET mnum_cargos = tnum_cargos;

         LET v_espergan = "N";

           -- VerIFicar si el movimiento es retroactivo
         IF dfecha_valida < pfecha_hoy THEN
            -- Movimiento retroactivo al mismo mes
            IF month(pfecha_hoy) = month(dfecha_valida) THEN
               -- VerIFica si la cuenta maneja auxiliar
               IF tauxiliar = "S" THEN
                  EXECUTE PROCEDURE
                  retaux (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                          dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                          dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                          tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                          tnat_cta,tauxiliar,pfecha_hoy);
               END IF

               EXECUTE PROCEDURE
               retsdo (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                       dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                       dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                       tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                       tnat_cta,tauxiliar,pfecha_hoy);
            ELSE
               LET mabonos = 0;
               LET mcargos = 0;
               LET mnum_abonos = 0;
               LET mnum_cargos = 0;

               IF ((dccmayor >= v_ctaingini AND dccmayor <= v_ctaingfin) OR (dccmayor >= v_ctagtoini AND dccmayor <= v_ctagtofin)) AND
                   ((month(dfecha_valida) = v_mc1) OR (month(dfecha_valida) = v_mc2)) OR v_espergan = "R" THEN -- Retroactivo a per y gan SEL

                  IF dnaturaleza = "D" THEN
                     INSERT INTO co_canret
                     VALUES(dempresa,dfecha_valida,dccmayor,dccsub,dccsubsub,
                            dccssubsub,dccsssubsub,dsector,dciudad,
                            dsucursal,dmoneda,dnro_auxiliar,pfecha_hoy,
                            dmonto,v_cero);
                  ELSE
                     INSERT INTO co_canret
                     VALUES(dempresa,dfecha_valida,dccmayor,dccsub,dccsubsub,
                            dccssubsub,dccsssubsub,dsector,dciudad,
                            dsucursal,dmoneda,dnro_auxiliar,pfecha_hoy,
                            v_cero,dmonto);
                  END IF

                  IF tauxiliar = "S" THEN
                     EXECUTE PROCEDURE
                     retauxmes(dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                               dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                               dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                               tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                               tnat_cta,tauxiliar,pfecha_hoy);
                     EXECUTE PROCEDURE
                     retaux_h (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                               dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                               dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                               tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                               tnat_cta,tauxiliar,pfecha_hoy);
                  END IF

                  EXECUTE PROCEDURE
                  retsdomes (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                             dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                             dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                             tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                             tnat_cta,tauxiliar,pfecha_hoy,v_espergan); --JLG
                  EXECUTE PROCEDURE
                  retsdo_h (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                            dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                            dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                            tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                            tnat_cta,tauxiliar,pfecha_hoy,v_espergan);

                  LET dccmayor    = v_perganmay;
                  LET dccsub      = v_pergansub;
                  LET dccsubsub   = v_perganss;
                  LET dccssubsub  = v_pergansss;
                  LET dccsssubsub = v_perganssss;
                  LET dsector     = v_pergansect;

                  LET v_espergan = "S"; -- result a per/gan sig ejercicio SEL

                  SELECT naturaleza_cta
                  INTO   tnat_cta
                  FROM bdinteg:si_catalog
                  WHERE empresa  = v_empresa AND
                  ccmayor    = dccmayor AND
                  ccsub      = dccsub AND
                  ccsubsub   = dccsubsub AND
                  ccssubsub  = dccssubsub AND
                  ccsssubsub = dccsssubsub AND
                  sector     = dsector;

                  IF tnat_cta = "D" THEN
                     LET tsaldo = tcargos - tabonos;
                  ELSE
                     LET tsaldo = tabonos - tcargos;
                  END IF

                  EXECUTE PROCEDURE
                  retsdo (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                          dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                          dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                          tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                          tnat_cta,tauxiliar,pfecha_hoy);
                  EXECUTE PROCEDURE
                  retsdomes (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                             dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                             dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                             tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                             tnat_cta,tauxiliar,pfecha_hoy,v_espergan); --JLG
                  EXECUTE PROCEDURE
                  retsdo_h (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                            dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                            dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                            tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                            tnat_cta,tauxiliar,pfecha_hoy,v_espergan);

               ELSE -- Si no Retroactivo a per y gan SEL
                  -- VerIFica si la cuenta maneja auxiliar
                  IF tauxiliar = "S" THEN
                     EXECUTE PROCEDURE
                     retaux (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                             dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                             dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                             tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                             tnat_cta,tauxiliar,pfecha_hoy);
                     EXECUTE PROCEDURE
                     retauxmes (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                                dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                                dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                                tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                                tnat_cta,tauxiliar,pfecha_hoy);
                     EXECUTE PROCEDURE
                     retaux_h (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                               dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                               dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                               tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                               tnat_cta,tauxiliar,pfecha_hoy);
                  END IF

                  EXECUTE PROCEDURE
                  retsdo (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                          dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                          dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                          tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                          tnat_cta,tauxiliar,pfecha_hoy);
                  EXECUTE PROCEDURE
                  retsdomes (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                             dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                             dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                             tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                             tnat_cta,tauxiliar,pfecha_hoy,v_espergan); --JLG
                  EXECUTE PROCEDURE
                  retsdo_h (dempresa,dccmayor,dccsub,dccsubsub,dccssubsub,
                            dccsssubsub,dsector,dciudad,dsucursal,dmoneda,
                            dnaturaleza,dnro_auxiliar,dfecha_valida,dmonto,
                            tabonos,tcargos,tsaldo,tnum_cargos,tnum_abonos,
                            tnat_cta,tauxiliar,pfecha_hoy,v_espergan);

               END IF
            END IF

            LET vabonos = tabonos;
            LET vcargos = tcargos;
            LET vnum_abonos = tnum_abonos;
            LET vnum_cargos = tnum_cargos;

            LET tabonos = 0;
            LET tcargos = 0;
            LET tnum_abonos = 0;
            LET tnum_cargos = 0;

         END IF -- si el movimiento es retroactivo

         IF dfecha_valida = pfecha_hoy THEN
            UPDATE co_sdodias
            SET cargos_dia = cargos_dia + tcargos,
                abonos_dia = abonos_dia + tabonos,
                nro_cargos_dia = tnum_cargos,
                nro_abonos_dia = tnum_abonos,
                saldo_acumulado = saldo_acumulado + (tsaldo *
                                  acumdias(pfecha_hoy, dfecha_valida)),
                saldo_fin_de_dia = saldo_fin_de_dia + tsaldo,
                dias_acumulado   = w_dia_hoy
            WHERE empresa = v_empresa
               AND ccmayor    = dccmayor
               AND ccsub      = dccsub
               AND ccsubsub   = dccsubsub
               AND ccssubsub  = dccssubsub
               AND ccsssubsub = dccsssubsub
               AND sector     = dsector
               AND ciudad     = dciudad
               AND sucursal   = dsucursal
               AND moneda     = dmoneda
               AND mes_dia    = pfecha_hoy;

            IF tauxiliar = "S" THEN
               UPDATE co_diasaux
                   SET
                   cargos_dia = cargos_dia + tcargos,
                   abonos_dia = abonos_dia + tabonos,
                   nro_cargos_dia = tnum_cargos,
                   nro_abonos_dia = tnum_abonos,
                   saldo_acumulado = saldo_acumulado + (tsaldo *
                                     acumdias(pfecha_hoy, dfecha_valida)),
                   saldo_fin_de_dia = saldo_fin_de_dia + tsaldo,
                   dias_acumulados  = w_dia_hoy
               WHERE empresa    = v_empresa
                  AND ccmayor    = dccmayor
                  AND ccsub      = dccsub
                  AND ccsubsub   = dccsubsub
                  AND ccssubsub  = dccssubsub
                  AND ccsssubsub = dccsssubsub
                  AND sector     = dsector
                  AND ciudad     = dciudad
                  AND sucursal   = dsucursal
                  AND auxiliar   = dnro_auxiliar
                  AND moneda     = dmoneda
                  AND mes_dia    = pfecha_hoy;
            END IF
         END IF
      END FOREACH;
   END FOREACH;

   LET cod_ret = "000";

RETURN cod_ret;
END PROCEDURE;