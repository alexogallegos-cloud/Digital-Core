CREATE PROCEDURE "informix".devcamp(pempresa   char(3),
                                    psucursal  char(4),
                                    pusuario   char(8),
                                    pbanco     char(3),
                                    psecuencia integer,
                                    pcuenta    char(20),
                                    pcheque    char(10),
                                    pcausa_dev char(2),
                                    pimporte   money(14,2),
                                    pmoneda    char(2))
   RETURNING CHAR(5);


   DEFINE vcodret          CHAR(5);
   DEFINE vstatchq,
          vcancelachq,
          vaplicam         CHAR(1);
   DEFINE vtipo_docto,
          vcausa_dev,
          vmoneda          CHAR(2);
   DEFINE vsuccta          char(4);
   define vproducto,
          vplaza           CHAR(3);
   DEFINE vstatus          CHAR(28);
   DEFINE vimporte,
          vcomision,
          viva,
          vtotal_com       MONEY(14,2);
   DEFINE sql_err,
          vrowid           INTEGER;
   DEFINE vfecha, vfecha_ant date;
   DEFINE vfech_hor,
          vw_fech_hor      DATETIME YEAR TO SECOND;
   DEFINE vnum_remesa      CHAR(4);
   DEFINE vcheque          CHAR(8);
   DEFINE vunidades_divisa money(14,2);
   DEFINE v_fecha          DATETIME YEAR TO DAY;
   DEFINE v_fecha_hora     CHAR(19);
   DEFINE vcodigo_mn       CHAR(2);
   DEFINE vfolio           CHAR(16);
   DEFINE vhora            DATETIME HOUR TO FRACTION;
   DEFINE vhora_char       CHAR(12);
   define vnum_tarjeta     char(16);
   define vmaxsec smallint;
   DEFINE vfecha_operacion DATE;

   -- Inicializa variables
   LET vcodret      = "000";
   LET vfecha_operacion = TODAY;

  
   BEGIN
      ON EXCEPTION SET sql_err
         IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            RETURN vcodret;
         END IF
      END EXCEPTION;
	  
	--set debug file to "/informix/moha/devcamp.out";
	--trace on;

   SELECT valor INTO vcodigo_mn
      FROM bdinteg:si_param
      where empresa = pempresa and descripcion = "codigo mn";

   SELECT fecha_hoy, fecha_ant INTO vfecha, vfecha_ant
      FROM sc_fechas where empresa = pempresa;

   LET v_fecha      = vfecha;
   LET v_fecha_hora = v_fecha || " " || current hour to second;
   LET vfech_hor    = v_fecha_hora;
   LET vhora        = current hour to fraction;
   LET vhora_char   = vhora;
   LET vcodret      = "000";
   LET vfolio       = pusuario||vhora_char[1,2]||vhora_char[4,5]||
                      vhora_char[7,8]||vhora_char[10,11];

   SELECT importe,tipo_docto,causa_dev,mca_aplic,rowid,moneda,num_remesa
          INTO vimporte,vtipo_docto,vcausa_dev,vaplicam,vrowid,
               vmoneda,vnum_remesa
      FROM sc_detcam
      WHERE empresa = pempresa and numero_cta = pcuenta AND
            numero_cheque = pcheque AND
            codigo_bco = pbanco AND secuencia = psecuencia;

   IF vimporte IS NULL THEN
      LET vcodret = "910";
      RETURN vcodret;
   END IF

   IF vcausa_dev <> " " AND vcausa_dev <> "00"
      AND vcausa_dev <> "0" THEN
      LET vcodret = "911";
      RETURN vcodret;
   END IF

   IF vmoneda <> pmoneda  THEN
      LET vcodret = "905";
      RETURN vcodret;
   END IF

   IF vimporte <> pimporte  THEN
      LET vcodret = "611";
      RETURN vcodret;
   END IF

   -- VerIFica el tipo del documento
   IF vtipo_docto = "01" THEN
      select estado into vstatchq
         from sc_contch
         where empresa = pempresa and cuenta = pcuenta and numero = pcheque;
      if vstatchq is null then
         select estado into vstatchq
            from sc_histch
            where empresa = pempresa and cuenta = pcuenta and numero = pcheque;
         if vstatchq = "C" then
            LET vtipo_docto = "03";
         end if
      else
         if vstatchq = "C" then
            LET vtipo_docto = "03";
         end if
      end if
   END IF;

   IF vtipo_docto = "01" THEN                         -- Cheque Propio
      IF vaplicam = "1" THEN
         SELECT sucursal,producto INTO vsuccta,vproducto
            FROM sc_maechq
            WHERE empresa = pempresa and cuenta = pcuenta;
         select max(secuencia) into vmaxsec
            from sc_tarjeta
            where empresa = pempresa and cuenta = pcuenta and
                  tipo_tarjeta = "T";

         select num_tarjeta into vnum_tarjeta
            from sc_tarjeta
            where empresa = pempresa and cuenta = pcuenta and
                  secuencia = vmaxsec;
         FOREACH
            EXECUTE PROCEDURE abono_ref(pempresa,psucursal,pusuario,"0331",
                 "0000",vfolio,pcuenta,pcheque,vimporte,vimporte,0,0,0,vmoneda,
                 "",vnum_tarjeta,"")
                 INTO vcodret
         END FOREACH
         IF vcodret = "000" THEN
            INSERT INTO sc_devcam
               VALUES(pempresa,pusuario,pbanco,vnum_remesa,psecuencia,pcuenta,
                      psucursal,vproducto,pcheque,vimporte,pcausa_dev,
                      vmoneda,"M");
            INSERT INTO sc_movdia
               VALUES(0,vfolio,psucursal,pusuario,vfecha,vfecha,vhora,
                      "3313",vsuccta,vproducto,pempresa,pcuenta," ",pcheque,
                      vimporte,vimporte,0,0,0," "," ",0," ",vnum_tarjeta,"",vnum_tarjeta,"","",vfecha_operacion);
            UPDATE sc_contch
               SET estado = " "
               WHERE empresa = pempresa and cuenta = pcuenta and
                     numero = pcheque;
            UPDATE sc_histch
               SET estado = " "
               WHERE empresa = pempresa and cuenta = pcuenta and
                     numero = pcheque;
            UPDATE sc_histcamara
               SET motivo_dev = pcausa_dev
               WHERE empresa = pempresa and nro_cuenta = pcuenta AND
                     nro_cheque = pcheque AND
                     fecha_trans = vfecha_ant AND
                     secuencia = psecuencia AND
                     propias = "1";
         ELSE
            RETURN vcodret;
         END IF;
      END IF;
   END IF

   IF vmoneda != vcodigo_mn THEN
      LET vunidades_divisa = vimporte;
   ELSE
      LET vunidades_divisa = 0;
   END IF

   SELECT plaza INTO vplaza
      FROM bdinteg:si_sucursales
      WHERE empresa = pempresa and sucursal = psucursal;

   IF vtipo_docto = "03" THEN                      -- Cheque CertIFicado
      IF vaplicam = "1" THEN
         DELETE FROM bditrans:st_movdia
            WHERE tipo_docto = vtipo_docto AND num_docto = pcheque AND
                  num_cargo_cta = pcuenta AND tipo_movto = "6";
         UPDATE bditrans:st_maetrans
            SET (sucursal_pagadora, cajero_paga, mto_efec_abono,
                 mto_efec_a_div, mto_efec_a_val, num_abono_cta,
                 mto_abono_cta, status_docto, fecha_hora_pago) =
                (" ", " ", 0, 0, 0, " ", 0, "1", " ")
            WHERE tipo_docto = vtipo_docto AND num_docto = pcheque AND
                  num_cargo_cta = pcuenta;
         INSERT INTO sc_devcam
            VALUES(pempresa,pusuario,pbanco,vnum_remesa,psecuencia,pcuenta,
                   psucursal," ",pcheque,vimporte,pcausa_dev,vmoneda,"M");
         UPDATE sc_histcamara
            SET motivo_dev = pcausa_dev
            WHERE empresa = pempresa and nro_cuenta = pcuenta AND
                  nro_cheque = pcheque AND
                  fecha_trans = vfecha_ant AND
                  secuencia = psecuencia AND
                  propias = "1";
         FOREACH
            EXECUTE PROCEDURE bditrans:stmovdia(vplaza,psucursal,pusuario,
               vfech_hor,"7",vmoneda,vtipo_docto,pcheque,vfolio,pcuenta)
               INTO vcodret
         END FOREACH
         FOREACH
            EXECUTE PROCEDURE bditrans:stmovdia(vplaza,psucursal,pusuario,
               vfech_hor,"8",vmoneda,vtipo_docto,pcheque,vfolio,pcuenta)
               INTO vcodret
         END FOREACH
         SELECT cancela INTO vcancelachq
            FROM sc_devolu
            WHERE codigo = pcausa_dev;
         IF vcancelachq = "S" THEN
            FOREACH
               EXECUTE PROCEDURE bditrans:cert_pag2("CANC",psucursal,
                  pusuario,vfech_hor,vfolio, pcuenta,pcheque,vimporte,
                  vunidades_divisa,vmoneda," ",0,vimporte)
                  INTO vcodret
            END FOREACH
         END IF
      END IF
   END IF

   IF vtipo_docto = "05" THEN                         -- Cheque de Caja
      IF vaplicam = "1" THEN
         DELETE FROM bditrans:st_movdia
            WHERE tipo_docto = vtipo_docto AND num_docto = pcheque AND
                  tipo_movto = "6";
         UPDATE bditrans:st_maetrans
            SET (sucursal_pagadora, cajero_paga, mto_pagado_mn,
                 status_docto, fecha_hora_pago) =
                (" ", " ", 0, "1", " ")
            WHERE tipo_docto = vtipo_docto AND num_docto = pcheque;
         INSERT INTO sc_devcam
            VALUES(pempresa,pusuario,pbanco,vnum_remesa,psecuencia,pcuenta,
                   psucursal," ",pcheque,vimporte,pcausa_dev,vmoneda,"M");
         UPDATE sc_histcamara
            SET motivo_dev = pcausa_dev
            WHERE empresa = pempresa and nro_cuenta = pcuenta AND
                  nro_cheque = pcheque AND
                  fecha_trans = vfecha_ant AND
                  secuencia = psecuencia AND
                  propias = "1";
         FOREACH
            EXECUTE PROCEDURE bditrans:stmovdia(vplaza,psucursal,pusuario,
               vfech_hor,"7",vmoneda,vtipo_docto,pcheque,vfolio,pcuenta)
               INTO vcodret
         END FOREACH
         FOREACH
            EXECUTE PROCEDURE bditrans:stmovdia(vplaza,psucursal,pusuario,
               vfech_hor,"8",vmoneda,vtipo_docto,pcheque,vfolio,pcuenta)
               INTO vcodret
         END FOREACH
         SELECT cancela INTO vcancelachq
            FROM sc_devolu
            WHERE codigo = pcausa_dev;
         IF vcancelachq = "S" THEN
            FOREACH
               EXECUTE PROCEDURE bditrans:chqcaj("CANC",vtipo_docto,
                  pusuario,vfech_hor,vfolio,vplaza,psucursal," ",
                  pcheque,vmoneda,vunidades_divisa,vimporte,0,0,0,
                  " ",0," ",0,0," "," "," "," ")
                  INTO vcomision,viva,vtotal_com,vstatus,vw_fech_hor,
                       vcodret,vcheque
            END FOREACH
         END IF
      END IF
   END IF                                        -- Cheque de Caja

   UPDATE sc_detcam
      SET causa_dev = pcausa_dev
      WHERE rowid = vrowid;

   RETURN vcodret;
END
END PROCEDURE;