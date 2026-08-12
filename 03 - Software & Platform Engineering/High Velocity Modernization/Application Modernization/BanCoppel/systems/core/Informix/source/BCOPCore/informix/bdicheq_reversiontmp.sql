CREATE PROCEDURE "informix".reversiontmp(pempresa  char(3),
                                      psucursal char(4),
                                      pusuario  char(8),
                                      pfolio    char(16),
                                      ptiporev  char(1))

   RETURNING char(5);

   DEFINE sql_err             integer;
   DEFINE isam_err            integer;
   DEFINE cod_ret             char(5);
   DEFINE contador            smallint;
   DEFINE wcompend            money(14,2);
   DEFINE wtiptran            char(2);
   DEFINE wnum_serial         integer;
   DEFINE wtransacc           char(4);
   DEFINE wcuenta             char(20);
   DEFINE wmonto_tot          money(14,2);
   DEFINE wmonto_tot1         money(14,2);
   DEFINE montoaux            money(14,2);
   DEFINE wfirme              money(14,2);
   DEFINE wen_sbc             money(14,2);
   DEFINE wremesas            money(14,2);
   DEFINE wdias_ret           smallint;
   DEFINE wnum_cheq           integer;
   DEFINE wimp_sbg_ccc        money(14,2);
   DEFINE wimp_chq_sbg        money(14,2);
   DEFINE wimp_int_ccc        money(14,2);
   DEFINE wimp_int_sbg        money(14,2);
   DEFINE wchq_exp_mes        smallint;
   DEFINE wnaturaleza         char(1);
   DEFINE wvalida_docto       char(1);
   DEFINE wtipo               char(1);
   DEFINE wsaldo_cuenta       money(14,2);
   DEFINE wsdo_actual         money(14,2);
   DEFINE wsdo_retenido       money(14,2);
   DEFINE wsdo_cong           money(14,2);
   DEFINE wmontoaux           money(14,2);
   DEFINE wlim_chq_sbc        money(14,2);
   DEFINE wimp_chq_sbc        money(14,2);
   DEFINE wlim_chq_rem        money(14,2);
   DEFINE wimp_chq_rem        money(14,2);
   DEFINE wreferencia         char(40);
   DEFINE wstatus_envio       char(1);
   DEFINE wrowid              integer;
   DEFINE wfechoy             date;
   DEFINE pfolio1             char(16);
   DEFINE wtpcheque           char(2);
   DEFINE wfechahora          datetime hour to fraction(3);
   DEFINE vtranusoccc         char(4);
   DEFINE vtrancancta         char(4);
   DEFINE vtranintccc         char(4);
   DEFINE vtranusosbg         char(4);
   DEFINE vtranintsbg         char(4);
   DEFINE wcomision           char(4);
   DEFINE wsuc_cuen           char(4);
   DEFINE wproducto           char(4);
   define vnum_tarjeta        char(16);
   define vmaxsec             smallint;
   DEFINE vProdCrec           CHAR(4);

   LET sql_err = 0;
   LET cod_ret = "000";


   BEGIN WORK;
   BEGIN
      ON EXCEPTION
         SET sql_err, isam_err
         IF (sql_err <> 0) THEN
            SET DEBUG FILE TO "reversionch.err";
            TRACE sql_err || " * " || isam_err;
            LET cod_ret = sql_err;
            ROLLBACK WORK;
            RETURN cod_ret;
         END IF;
      END EXCEPTION;

      SELECT fecha_hoy into wfechoy
         FROM sc_fechas where empresa = pempresa;

      SELECT TRIM(valor)
        INTO vProdCrec
        FROM sc_param
       WHERE empresa = pempresa
         AND codparam ="PRODCREC";


      SELECT COUNT(*) INTO contador
         FROM sc_movdia m, bdinteg:si_transacc t
         WHERE m.empresa = pempresa and folio_suc = pfolio and
               m.empresa = t.empresa and m.transacc = t.numero and
               reversable = "S" and cancelad <> "S";

      IF (contador = 0) THEN
         SELECT COUNT(*) INTO contador
            FROM  sc_docret
            WHERE empresa = pempresa and folio_suc = pfolio and
                  fecha_alta = wfechoy;
         IF (contador = 0) THEN
            RETURN cod_ret;
         ELSE
            update sc_docret
               set cancelado = "S"
               WHERE empresa = pempresa and folio_suc = pfolio and
                     fecha_alta = wfechoy;
            RETURN cod_ret;
         end if
      end if

      select valor into vtrancancta
         from sc_param
         where empresa = pempresa and codparam = "trancancta";

      select valor into vtranusoccc
         from sc_param
         where empresa = pempresa and codparam = "tranusoccc";

      select valor into vtranintccc
         from sc_param
         where empresa = pempresa and codparam = "tranintccc";

      select valor into vtranusosbg
         from sc_param
         where empresa = pempresa and codparam = "tranusosbg";

      select valor into vtranintsbg
         from sc_param
         where empresa = pempresa and codparam = "tranintsbg";

      FOREACH
         select num_serial,transacc,cuenta,monto_tot,firme,en_sbc,remesas,
                md.dias_ret,num_cheq,naturaleza,valida_docto,tr.tipo_tran,
                referencia,suc_cuen,producto
            into wnum_serial,wtransacc,wcuenta,wmonto_tot,wfirme,wen_sbc,
                 wremesas,wdias_ret,wnum_cheq,wnaturaleza,wvalida_docto,
                 wtiptran,wreferencia,wsuc_cuen,wproducto
            FROM sc_movdia md, bdinteg:si_transacc tr
            WHERE md.empresa = pempresa and folio_suc = pfolio
                  AND cancelad <> "S" and reversable = "S"
                  AND md.empresa = tr.empresa and numero = transacc
            ORDER BY naturaleza desc
         select max(secuencia) into vmaxsec
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  tipo_tarjeta = "T";
         select num_tarjeta into vnum_tarjeta
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  secuencia = vmaxsec;
         LET wimp_sbg_ccc = 0;
         LET wimp_chq_sbg = 0;
         LET wimp_int_ccc = 0;
         LET wimp_int_sbg = 0;
         LET wchq_exp_mes = 0;
         let wcompend = 0;

         IF wtiptran = "01" THEN
            LET wchq_exp_mes  = 1;
         ELIF wtransacc = vtranusoccc THEN
            LET wimp_sbg_ccc = wmonto_tot;
         ELIF wtransacc = vtranusosbg THEN
            LET wimp_chq_sbg = wmonto_tot;
         ELIF wtransacc = vtranintccc THEN
            LET wimp_int_ccc = wmonto_tot;
         ELIF wtransacc = vtranintsbg THEN
            LET wimp_int_sbg = wmonto_tot;
         ELIF wtiptran = "05" THEN
            LET wcompend = wmonto_tot;
            let wcomision = trim(wreferencia);
         END IF;
         select sdo_actual into wsdo_actual
            from sc_maechq
            where empresa = pempresa and cuenta = wcuenta;

         IF wnaturaleza = "C" THEN
            UPDATE sc_maechq
               SET sdo_actual = sdo_actual + wmonto_tot,
                   imp_cgos_mes = imp_cgos_mes - wmonto_tot,
                   num_cgos_mes = num_cgos_mes - 1,
                   chq_exp_mes = chq_exp_mes - wchq_exp_mes,
                   imp_sbg_ccc = imp_sbg_ccc + wimp_sbg_ccc,
                   imp_int_ccc = imp_int_ccc + wimp_int_ccc,
                   imp_chq_sbg = imp_chq_sbg + wimp_chq_sbg,
                   imp_int_sbg = imp_int_sbg + wimp_int_sbg,
                   com_pendiente = com_pendiente + wcompend
               WHERE empresa = pempresa and cuenta = wcuenta;
            if wtransacc = vtrancancta then
               update sc_maechq
                  set status_cta = "1",
                      fec_cancelac = "",
                      motivo = " "
                  WHERE empresa = pempresa and cuenta = wcuenta;
            end if
            if wtiptran = "05" then
               update sc_detcomis
                  set pago_com = pago_com - wmonto_tot,
                      estado_com = "P"
                  where empresa = pempresa and cuenta = wcuenta and
                        comision = wcomision and fecult_pago = wfechoy;
            end if;
            if ptiporev = "A" then
               delete from sc_movdia
                  where num_serial = wnum_serial;
            else
               UPDATE sc_movdia
                  SET cancelad = "S"
                  WHERE num_serial = wnum_serial;
               INSERT INTO sc_movdia
                  VALUES(0,pfolio,psucursal,pusuario,wfechoy,wfechoy,
                      current hour to fraction(3),wtransacc,wsuc_cuen,
                      wproducto,pempresa,wcuenta," ",wnum_cheq,
                      wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                      "REV",0,vnum_tarjeta,"");
            end if
            IF wtiptran = "01" THEN
               UPDATE sc_contch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
               UPDATE sc_histch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
            END IF;
         ELSE
            IF (wnaturaleza = "A") THEN
               LET wsaldo_cuenta       = 0;
               LET wsdo_actual         = 0;
               LET wsdo_retenido       = 0;
               LET wsdo_cong           = 0;

               SELECT sdo_actual - sdo_retenido - sdo_cong,sdo_actual,
                      sdo_retenido,sdo_cong
                  INTO wsaldo_cuenta,wsdo_actual,wsdo_retenido,wsdo_cong
                  FROM sc_maechq
                  WHERE empresa = pempresa and cuenta = wcuenta;

               IF wsaldo_cuenta < wfirme THEN
                  LET cod_ret = "413";
                  RETURN cod_ret;
               END IF;
               UPDATE sc_maechq
                  SET sdo_actual = sdo_actual - wmonto_tot,
                      sdo_retenido= sdo_retenido - wen_sbc,
                      imp_sbg_ccc = imp_sbg_ccc - wimp_sbg_ccc,
                      imp_chq_sbg = imp_chq_sbg - wimp_chq_sbg,
                      num_abonos_mes = num_abonos_mes - 1,
                      imp_abonos_mes = imp_abonos_mes - wmonto_tot
                  WHERE  empresa = pempresa and cuenta = wcuenta;
               if wen_sbc > 0 then
                  update sc_docret
                     set cancelado = "S"
                     where empresa = pempresa and cuenta = wcuenta
                           and folio_suc = pfolio
                           and fecha_alta = wfechoy;
               end if;

	       IF vProdCrec = wproducto THEN
		 UPDATE sc_maechq
		    SET marca_ret = "0"
		  WHERE empresa = pempresa
		    AND cuenta = wcuenta;
	       END IF

               IF (cod_ret = "000") THEN
                  if ptiporev = "A" then
                     delete from sc_movdia
                        where num_serial = wnum_serial;
                  else
                     UPDATE sc_movdia
                        SET cancelad = "S"
                        WHERE num_serial = wnum_serial;
                     INSERT INTO sc_movdia
                        VALUES(0,pfolio,psucursal,pusuario,wfechoy,wfechoy,
                           current hour to fraction(3),wtransacc,wsuc_cuen,
                           wproducto,pempresa,wcuenta," ",wnum_cheq,
                           wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                           "REV",0,vnum_tarjeta,"");
                  end if
               END IF;
            END IF;
         END IF;
      END FOREACH;

   COMMIT WORK;
   END;
   RETURN cod_ret;
END PROCEDURE;