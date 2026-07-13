CREATE PROCEDURE "informix".pase_cam_pba(pempresa char(3))
   RETURNING CHAR(5);

   DEFINE cod_ret          CHAR(5);
   DEFINE v_statuschq,
          vcancelachq,
          vmca             CHAR(1);
   DEFINE vtipo_docto,
          v_moneda,
          v_tipo           CHAR(2);
   DEFINE vsuc_usuario,
          vsuc_cta,
          vproducto,
          vsucursal        CHAR(4);
   define vcodigo_bco,
          v_plaza,
          vcodigo_causa    CHAR(3);
   DEFINE vcausa_dev       CHAR(5);
   DEFINE vtransacc,
          tran,
          vnum_remesa      CHAR(4);
   DEFINE vusuario         CHAR(8);
   DEFINE vcuenta,
          vcuenta_aux      CHAR(20);
   DEFINE v_no_cheque      CHAR(10);
   DEFINE v_stts           CHAR(28);
   DEFINE vimporte,
          v_comision,
          v_iva,
          v_total_com      MONEY(14,2);
   DEFINE vsecuencia       INTEGER;
   DEFINE vnum_cheq        CHAR(10);   -- NCB 6/Ene/97
   DEFINE vnum_serial,
          sql_err,
          vfolio,
          v_rowid          INTEGER;
   DEFINE vfecha date;
   DEFINE v_fech_hor,
          vw_fech_hor       DATETIME YEAR TO SECOND;
   DEFINE vt_moneda_docto   CHAR(2);
   DEFINE vt_mto_divisa     money(14,2);
   DEFINE v_fecha           DATETIME YEAR TO DAY;
   DEFINE v_fecha_hora      CHAR(19);
   DEFINE vcodigo_mn        CHAR(2);
   DEFINE vmoneda           CHAR(2);
   DEFINE vsistrans         CHAR(2);
   DEFINE vsischeq          CHAR(2);
   DEFINE FOLIO1,FOLIO2     INTEGER;
   DEFINE FOLIOX            CHAR(16);
   DEFINE FOLIOC            CHAR(5);
   DEFINE hora              DATETIME HOUR TO FRACTION;
   DEFINE vplaza            CHAR(3);
   define vnum_tarjeta      char(16);
   define vmaxsec           smallint;

   -- Inicializa variables
   LET cod_ret       = "000";
   LET vcausa_dev    = " ";
   LET vtransacc     = "000";
   LET vfolio        = 0;
   LET vsecuencia    = 0;
   LET v_fech_hor    = " ";
   LET v_tipo        = " ";

  
   BEGIN
      ON EXCEPTION SET sql_err
         IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
         END IF
      END EXCEPTION;

   SELECT codigo_mn INTO vcodigo_mn
      FROM bdinteg:si_param where empresa = pempresa;
   SELECT fecha_hoy INTO vfecha FROM sc_fechas where empresa = pempresa;

   LET v_fecha      = vfecha;
   LET v_fecha_hora = v_fecha || " " || current hour to second;
   LET v_fech_hor   = v_fecha_hora;
   SELECT sistema INTO vsistrans FROM bdinteg:si_sistema
      WHERE siglas = "ST";

   SELECT sistema INTO vsischeq FROM bdinteg:si_sistema
      WHERE siglas = "SC";

-- Lee el movimiento del detalle de camara por cada banco
FOREACH devoluc WITH HOLD FOR
   SELECT sucursal,usuario,codigo_bco,num_remesa,secuencia,numero_cta,
          numero_cheque,importe,tipo_docto,causa_dev,mca_aplic,rowid,
          moneda
          INTO vsucursal,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
          vcuenta,vnum_cheq,vimporte,vtipo_docto,vcausa_dev,vmca,v_rowid,
          vmoneda
   FROM sc_detcam
   WHERE empresa = pempresa and mca_aplic = "0"
   ORDER BY numero_cta,importe

   SELECT plaza INTO vplaza FROM bdinteg:si_sucursales
      WHERE empresa = pempresa and sucursal = vsucursal;

   LET cod_ret   = "000";
   LET vfolio    = vfolio+1;
   LET vsuc_cta  = " ";
   LET vproducto = " ";
   LET FOLIOX = vsucursal||vusuario||vfolio;

   -- VerIFica sea valida la secuencia del movimiento
   IF vsecuencia IS NULL THEN
      LET cod_ret = "099";
      UPDATE sc_detcam
         SET (mca_aplic) = ("1")
         WHERE rowid = v_rowid;
   END IF

   -- VerIFica el movimiento no haya sido aplicado anteriormente
   IF vmca = "1" THEN
      LET cod_ret = "909";
      CONTINUE FOREACH;
   END IF

   -- VerIFica el tipo del documento
   IF vtipo_docto = "01" THEN                 -- Cheque Propio      (CP)
      LET v_tipo = "CP";
      LET vtransacc = "0231";
      select estado into v_statuschq
         from sc_contch
         where empresa = pempresa and cuenta = vcuenta and numero = vnum_cheq;
      if v_statuschq is null then
         select estado into v_statuschq
            from sc_histch
            where empresa = pempresa and cuenta = vcuenta and
                  numero = vnum_cheq;
         if v_statuschq = "C" then
            LET v_tipo = "CC";
            LET vtipo_docto = "03";
            LET vtransacc = "0000";
         end if
      else
         if v_statuschq = "C" then
            LET v_tipo = "CC";
            LET vtipo_docto = "03";
            LET vtransacc = "0000";
         end if

      end if
   ELSE
     IF vtipo_docto = "03" THEN               -- Cheque CertIFicado (CC)
        LET v_tipo = "CC";
        LET vtransacc = "0000";
     ELSE
       IF vtipo_docto = "04" THEN               -- Giro Bancario      (GB)
          LET v_tipo = "GB";
          LET vtransacc = "0000";
       ELSE
         IF vtipo_docto = "05" THEN               -- Cheque de Caja     (CJ)
            LET v_tipo = "CJ";
            LET vtransacc = "0000";
         ELSE
            LET v_tipo = '  ';
            LET vtransacc = '0000';
         END IF;
       END IF;
     END IF;
   END IF;

   IF v_tipo = "CP" THEN                         -- Cheque Propio
      SELECT sucursal INTO vsuc_usuario
         FROM bdinteg:si_ejecut
         WHERE ejecutivo = vusuario;
      SELECT sucursal,producto,cuenta,plaza
         INTO vsuc_cta,vproducto,vcuenta_aux,v_plaza
         FROM sc_maechq
         WHERE empresa = pempresa and cuenta = vcuenta;
      IF vproducto IS NULL THEN
         LET vcausa_dev = "02";
         LET cod_ret = "100";
      END IF
      SELECT divisa INTO v_moneda
         FROM sc_producto
         WHERE empresa = pempresa and producto = vproducto;

      -- Valida que exista la cuenta en Maestro de Cheques
      IF vcuenta_aux IS NULL THEN
         LET vcausa_dev = "02";
         LET cod_ret = "100";
      END IF;
      select max(secuencia) into vmaxsec
         from sc_tarjeta
         where empresa = pempresa and cuenta = pcuenta and
               tipo_tarjeta = "T";

      select num_tarjeta into vnum_tarjeta
          from sc_tarjeta
          where empresa = pempresa and cuenta = pcuenta and
                secuencia = vmaxsec;

      -- Valida si el documento fue rechazado por el area operativa de camara
      IF vcausa_dev IS NOT NULL  AND vcausa_dev <> " "
         and vcausa_dev <> "000" AND vcausa_dev <> "00"  AND
         vcausa_dev <> "0"  THEN
         INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
                   vcuenta,vsucursal,vproducto,vnum_cheq,vimporte,vcausa_dev,
                   vmoneda,"A");
         LET hora = current hour to fraction;
         INSERT INTO sc_movdia
         VALUES(0,FOLIOX,vsucursal,vusuario,vfecha,vfecha,hora,"3313",
                vsuc_cta,vproducto,pempresa,vcuenta," ",vnum_cheq,vimporte,
                vimporte,0,0,0," "," ",0," ",vnum_tarjeta,"");
         UPDATE sc_detcam
            SET mca_aplic = "1"
            WHERE rowid = v_rowid;
         UPDATE sc_histcamara
            SET motivo_dev = vcausa_dev
            WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                  nro_cheque = vnum_cheq AND
                  propias = "1";
      ELSE
         IF cod_ret = "000" and vtransacc = "0231" THEN
            call cargon_ref(pempresa,vsucursal,vusuario,vtransacc,
                    "0000", FOLIOX,vcuenta,vnum_cheq,vimporte,v_moneda,
                    "",vnum_tarjeta,"")
                 returning cod_ret,tran;
         END IF;
         IF cod_ret != "000" THEN
            LET  vcodigo_causa  = NULL;
            SELECT codigo INTO vcodigo_causa
               FROM bdinteg:si_coddevcam
               WHERE cod_ret_rel     = cod_ret
                     and sistema_rel = vsischeq;
            IF vcodigo_causa IS NOT NULL OR vcodigo_causa != "" then
               LET vcausa_dev = vcodigo_causa;
            END IF;
            INSERT INTO sc_devcam
               VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
                      vcuenta,vsucursal,vproducto,vnum_cheq,vimporte,
                      vcausa_dev,vmoneda,"A");
            LET hora = current hour to fraction;
            INSERT INTO sc_movdia
               VALUES(0,FOLIOX,vsucursal,vusuario,vfecha,vfecha,hora,
                      "3313",vsuc_cta,vproducto,pempresa,vcuenta," ",
                      vnum_cheq,vimporte,vimporte,0,0,0," "," ",0," ",
                      vnum_tarjeta,"");
            UPDATE sc_histcamara
               SET motivo_dev = vcausa_dev
               WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                     nro_cheque = vnum_cheq AND
                     propias = "1";
         END IF;
      END IF;
   END IF                                        -- Cheque Propio

   IF v_tipo = "CC" THEN                         -- Cheque CertIFicado
      SELECT moneda INTO vt_moneda_docto FROM bditrans:st_maetrans
         WHERE empresa = pempresa and tipo_docto = "03" and
               num_docto = vnum_cheq and
               num_cargo_cta = vcuenta;
      IF vt_moneda_docto != vcodigo_mn THEN
         LET vt_mto_divisa = vimporte;
      ELSE
         LET vt_mto_divisa = 0;
      END IF
      IF vcausa_dev is not null and vcausa_dev <> " " and vcausa_dev <> "00"
         and vcausa_dev <> "000" and vcausa_dev <> "0" THEN
         INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,
             vusuario,v_fech_hor,"7",vt_moneda_docto,"03",vnum_cheq,
             FOLIOX,vcuenta) returning cod_ret;
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,
             vusuario,v_fech_hor,"8",vt_moneda_docto,"03",vnum_cheq,
             FOLIOX,vcuenta) returning cod_ret;
         UPDATE sc_histcamara
            SET motivo_dev = vcausa_dev
            WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                  nro_cheque = vnum_cheq AND
                  propias = "1";
      ELSE
         call bditrans:cert_pag2(pempresa,"CMRA",vsucursal,
                 vusuario, v_fech_hor,vfolio, vcuenta,vnum_cheq,vimporte,
                 vt_mto_divisa,vt_moneda_docto," ",0,vimporte) returning cod_ret;
         IF cod_ret != "000" THEN
            SELECT codigo INTO vcausa_dev
               FROM bdinteg:si_coddevcam
               WHERE cod_ret_rel = cod_ret and sistema_rel = vsistrans;
            IF vcausa_dev IS NULL THEN
               LET vcausa_dev = cod_ret;
            END IF;
            INSERT INTO sc_devcam
               VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
                      vcuenta,vsucursal," ",vnum_cheq,vimporte,vcausa_dev,
                      vmoneda,"A");
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,
               vusuario,v_fech_hor,"7",vt_moneda_docto,"03",vnum_cheq,
               FOLIOX,vcuenta) returning cod_ret;
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,
               vusuario,v_fech_hor,"8",vt_moneda_docto,"03",vnum_cheq,
               FOLIOX,vcuenta) returning cod_ret;
            UPDATE sc_histcamara
               SET motivo_dev = vcausa_dev
               WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                     nro_cheque = vnum_cheq AND
                     propias = "1";
            SELECT cancela INTO vcancelachq
               FROM sc_devolu
               WHERE codigo = vcausa_dev;
            IF vcancelachq = "S" THEN
               call bditrans:cert_pag2(pempresa,"CANC",
                  vsucursal,vusuario,v_fech_hor,vfolio,vcuenta,vnum_cheq,
                  vimporte,vt_mto_divisa,vt_moneda_docto," ",0,vimporte)
                  returning cod_ret;
            END IF
         END IF
      END IF
   END IF                                        -- Cheque CertIFicado

   IF v_tipo = "GB" THEN                         -- Giro Bancario
      SELECT moneda INTO vt_moneda_docto FROM bditrans:st_maetrans
         WHERE empresa = pempresa and tipo_docto = "04" and
               num_docto = vnum_cheq;
      IF vt_moneda_docto != vcodigo_mn THEN
         LET vt_mto_divisa = vimporte;
      ELSE
         LET vt_mto_divisa = 0;
      END IF
      IF vcausa_dev is not null and vcausa_dev <> " " and
         vcausa_dev <> "00"  and vcausa_dev <> "000"  and vcausa_dev <> "0" THEN
         INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,
            vusuario,v_fech_hor,"7",vt_moneda_docto,"04",vnum_cheq,
            FOLIOX,"") returning cod_ret;
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,
            vusuario,v_fech_hor,"8",vt_moneda_docto,"04",vnum_cheq,
            FOLIOX,"") returning cod_ret;
      ELSE
         call bditrans:girbanc(pempresa,"CMRA",vtipo_docto,
            vusuario, v_fech_hor,"0",vsucursal," ",vnum_cheq,
            vt_moneda_docto,vt_mto_divisa,vimporte,
            0,0,0," ",0," ",0,0," "," "," "," "," "," "," "," ")
            returning cod_ret,v_no_cheque,v_comision,v_iva,v_total_com,
                     v_stts,vw_fech_hor;
         IF cod_ret != "000" THEN
            SELECT codigo INTO vcausa_dev
               FROM bdinteg:si_coddevcam
               WHERE cod_ret_rel = cod_ret and sistema_rel = vsistrans;
            IF vcausa_dev IS NULL THEN
               LET vcausa_dev = cod_ret;
            END IF;
            INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,
               vusuario,v_fech_hor,"7",vt_moneda_docto,"04",vnum_cheq,
               FOLIOX,"") returning cod_ret;
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,
               vusuario,v_fech_hor,"8",vt_moneda_docto,"04",vnum_cheq,
               FOLIOX,"") returning cod_ret;
         END IF
      END IF
   END IF                                        -- Giro Bancario

   IF v_tipo = "CJ" THEN                         -- Cheque de Caja
      SELECT moneda INTO vt_moneda_docto FROM bditrans:st_maetrans
         WHERE empresa = pempresa and tipo_docto = "05" and
               num_docto = vnum_cheq;
      IF vt_moneda_docto != vcodigo_mn THEN
         LET vt_mto_divisa = vimporte;
      ELSE
         LET vt_mto_divisa = 0;
      END IF
      IF vcausa_dev is not null and vcausa_dev <> " " and vcausa_dev <> "00"
         and vcausa_dev <> "000" and vcausa_dev <> "0" THEN
         INSERT INTO sc_devcam
            VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,vusuario,
               v_fech_hor, "7",vt_moneda_docto,"05",vnum_cheq,FOLIOX,"")
               returning cod_ret;
         call bditrans:stmovdia(pempresa,vplaza,vsucursal,vusuario,
               v_fech_hor, "8",vt_moneda_docto,"05",vnum_cheq,FOLIOX,"")
               returning cod_ret;
         UPDATE sc_histcamara
            SET motivo_dev = vcausa_dev
            WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                  nro_cheque = vnum_cheq AND
                  propias = "1";
      ELSE
         call bditrans:chqcaj(pempresa,"CMRA",vtipo_docto,vusuario,
              v_fech_hor,
              "0","0",vsucursal," ",vnum_cheq,vt_moneda_docto,vt_mto_divisa,
              vimporte,0,0,0," ",0," ",0,0," "," "," "," ")
              returning v_comision,v_iva,v_total_com,v_stts,vw_fech_hor,
                   cod_ret,v_no_cheque;
         IF cod_ret != "000" THEN
            SELECT codigo INTO vcausa_dev
               FROM bdinteg:si_coddevcam
               WHERE cod_ret_rel = cod_ret and sistema_rel = vsistrans;
            IF vcausa_dev IS NULL THEN
               LET vcausa_dev = cod_ret;
            END IF;
            INSERT INTO sc_devcam
               VALUES(pempresa,vusuario,vcodigo_bco,vnum_remesa,vsecuencia,
                   vcuenta,
                   vsucursal," ",vnum_cheq,vimporte,vcausa_dev,vmoneda,"A");
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,vusuario,
                v_fech_hor, "7",vt_moneda_docto,"05",vnum_cheq,FOLIOX,"")
                returning cod_ret;
            call bditrans:stmovdia(pempresa,vplaza,vsucursal,vusuario,
                v_fech_hor,"8",vt_moneda_docto,"05",vnum_cheq,FOLIOX,"")
                returning cod_ret;
            UPDATE sc_histcamara
              SET motivo_dev = vcausa_dev
              WHERE empresa = pempresa and nro_cuenta = vcuenta AND
                    nro_cheque = vnum_cheq AND
                    propias = "1";

            SELECT cancela INTO vcancelachq
               FROM sc_devolu
               WHERE codigo = vcausa_dev;
            IF vcancelachq = "S" THEN
               call bditrans:chqcaj(pempresa,"CANC",vtipo_docto,
                     vusuario,v_fech_hor,"0","0",vsucursal," ",vnum_cheq,
                     vt_moneda_docto,vt_mto_divisa,
                     vimporte,0,0,0," ",0," ",0,0," "," "," "," ")
                     returning v_comision,v_iva,v_total_com,v_stts,vw_fech_hor,
                          cod_ret,v_no_cheque;
            END IF
         END IF
      END IF
   END IF                                        -- Cheque de Caja
   -- Actualiza marca de movimiento aplicado en el detalle de camara
   UPDATE sc_detcam
      SET mca_aplic = "1",
          tipo_docto = vtipo_docto,
          causa_dev =  vcausa_dev
      WHERE rowid = v_rowid;

   INSERT INTO sc_valpase
      VALUES(pempresa,v_tipo,vcuenta,cod_ret);
   LET cod_ret   = "000";
END FOREACH

RETURN cod_ret;
END
END PROCEDURE;