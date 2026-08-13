CREATE PROCEDURE "informix".minispro2(pnum_credito CHAR(20))
   RETURNING CHAR(5);

   DEFINE cod_ret               CHAR(5);
   DEFINE wnumcte               CHAR(20);
   DEFINE wtasa                 DECIMAL(9,6);
   DEFINE wtasa_fija_o_var      CHAR(1);
   DEFINE wrev_tasa_var_per     CHAR(1);
   DEFINE wdia_para_revisar     SMALLINT;
   DEFINE wstatus_ministra      CHAR(1);
   DEFINE wcod_califica         CHAR(2);
   DEFINE wcod_sujeto_fj        SMALLINT;
   DEFINE wcod_prod             CHAR(2);
   DEFINE wnum_cta              CHAR(20);
   DEFINE wtipo_cta             CHAR(1);
   DEFINE whora                 DATETIME HOUR TO FRACTION(3);
   DEFINE whora0                CHAR(12);
   DEFINE whora1                CHAR(8);
   DEFINE wusuario              CHAR(8);
   DEFINE wsucursal             CHAR(4);
   DEFINE wfolio_suc            CHAR(16);
   DEFINE wcontrato             CHAR(20);
   DEFINE wsujeto               CHAR(20);
   DEFINE wmonto_aut_cont       MONEY(14,2);
   DEFINE wmonto_ejercido       MONEY(14,2);
   DEFINE wtipo_calculo         CHAR(2);
   DEFINE wfavp                 DECIMAL(9,7);
   DEFINE wfecha_hoy            DATE;
   DEFINE wprox_fecha           DATE;
   DEFINE wfecha_vencim         DATE;
   DEFINE wmonto_otorgado       MONEY(14,2);
   DEFINE wdias                 SMALLINT;
   DEFINE wcobra_comision       CHAR(1);
   DEFINE wnum_producto         CHAR(4);
   DEFINE wcod_tipcred          CHAR(2);
   DEFINE wint_anticip          MONEY(14,2);
   DEFINE wcomision             MONEY(14,2);
   DEFINE wiva                  DECIMAL(5,3);
   DEFINE wmonto_ivaint         MONEY(14,2);
   DEFINE wmonto_ivacom         MONEY(14,2);
   DEFINE wreciprocidad         CHAR(1);
   DEFINE wdivisa               CHAR(2);
   DEFINE wapli_factor          DECIMAL(9,6);
   DEFINE wmonto_min            MONEY(14,2);
   DEFINE ptransacc             CHAR(4);
   DEFINE ptransacc_suc         CHAR(4);
   DEFINE pdocto                INTEGER;
   DEFINE pmonto                MONEY(14,2);
   DEFINE pdias_ret             SMALLINT;
   DEFINE wministrado           MONEY(14,2);
   DEFINE wnum_cuota            SMALLINT;
   DEFINE wmonto_cuota          MONEY(14,2);
   DEFINE wfecha_cuota          DATE;
   DEFINE sqlerr                SMALLINT;
   DEFINE isamerr               SMALLINT;
   DEFINE si_cobra              CHAR(1);
   DEFINE wcod_comis            CHAR(4);

   ON EXCEPTION
      SET sqlerr, isamerr
      LET cod_ret = sqlerr;
      ROLLBACK WORK;
      LET wusuario = USER;
      IF (wusuario = "cs2") THEN
         BEGIN WORK;
      END IF;
      RETURN cod_ret;
   END EXCEPTION;





-- Extrae Datos generales para los calculos de comisiones y aplicacion
-- No se cobra comision si tipo_de productor es "01" o
-- se trata de un credito de avio y es pequeño propietario,
-- se cobra 50% de comision si el cliente esta clasificado como preferencial
-- Regla de Negocio 06.006.09.01.00.00 Comisiones por apertura


-- Valida que se haya enviado un numero de credito

   IF (pnum_credito IS NULL or pnum_credito = " ") THEN
      LET cod_ret = "223";
      RETURN cod_ret;
   END IF;

   LET wcontrato = pnum_credito[1,15];
   LET wsujeto = pnum_credito[1,11] || "0000";

   LET wmonto_aut_cont = 0;
   LET wmonto_ejercido = 0;
   LET wcod_comis      = "    ";

   SELECT
      monto_auto_cont,
      monto_ejercido
   INTO
      wmonto_aut_cont,
      wmonto_ejercido
   FROM
      sd_maecontrato
   WHERE
      num_contrato = wcontrato;

   IF (wmonto_aut_cont = 0 or wmonto_aut_cont IS NULL) THEN
      SELECT
         monto_auto_cont,
         monto_ejercido
      INTO
         wmonto_aut_cont,
         wmonto_ejercido
      FROM
         sd_maecontrato
      WHERE
         num_contrato = wsujeto;

      IF (wmonto_aut_cont = 0 OR wmonto_aut_cont IS NULL) THEN
         LET wcontrato = " ";
      ELSE
         LET wcontrato = wsujeto;
      END IF;
   END IF;

   IF (wmonto_aut_cont <> 0 AND wmonto_aut_cont = wmonto_ejercido) THEN
      LET cod_ret = "091";
      RETURN cod_ret;
   END IF;

   SELECT
      numcte,
      sucursal,
      tasa_interes,
      tipo_calculo,
      fecha_vencim,
      num_producto,
      divisa,
      tasa_fija_o_var,
      dia_para_revisar,
      rev_tasa_var_per
   INTO
      wnumcte,
      wsucursal,
      wtasa,
      wtipo_calculo,
      wfecha_vencim,
      wnum_producto,
      wdivisa,
      wtasa_fija_o_var,
      wdia_para_revisar,
      wrev_tasa_var_per
   FROM
      sd_maecred
   WHERE
      num_credito = pnum_credito;

   IF (wnumcte IS NULL OR wnumcte = " ") THEN
      LET cod_ret = "224";
      RETURN cod_ret;
   END IF;

   SELECT
      cod_tipcred
   INTO
      wcod_tipcred
   FROM
      sd_definicion
   WHERE
      num_producto = wnum_producto;

   SELECT
      cod_califica,
      cod_sujeto_fj,
      cod_prod,
      reciprocidad
   INTO
      wcod_califica,
      wcod_sujeto_fj,
      wcod_prod,
      wreciprocidad
   FROM
      sd_calctebr
   WHERE
      numcte = wnumcte;

   IF (wcod_califica IS NULL OR wcod_califica = "  ") THEN
      LET cod_ret = "300";
      RETURN cod_ret;
   END IF;

   IF (wreciprocidad IS NULL OR wreciprocidad = " ") THEN
      LET cod_ret = "301";
      RETURN cod_ret;
   END IF

   SELECT
      cod_comis,
      apli_factor,
      monto_min
   INTO
      wcod_comis,
      wapli_factor,
      wmonto_min
   FROM
      sd_tpcomis
   WHERE
      cod_comis BETWEEN "0001" AND "0006"
   AND
      reciprocidad = wreciprocidad
   AND
      divisa = wdivisa;

   LET wusuario = USER;
   LET whora    = CURRENT HOUR TO FRACTION;
   LET whora0   = whora;
   LET whora1[1,2] = whora0[1,2];
   LET whora1[3,4] = whora0[4,5];
   LET whora1[5,6] = whora0[7,8];
   LET whora1[7,8] = whora0[10,11];
   LET wfolio_suc = wsucursal || wusuario || whora1;

   SELECT
      fecha_hoy, prox_fecha
   INTO
      wfecha_hoy, wprox_fecha
   FROM
      sd_fechas;

   SELECT
      iva
   INTO
      wiva
   FROM
      bdinteg:si_sucursales
   WHERE
      sucursal = wsucursal;


   IF (wcod_prod = "02") THEN
      LET wcobra_comision = "N";
   ELSE
      IF (wcod_sujeto_fj = 2 AND wcod_tipcred = "07") THEN
         LET wcobra_comision = "N";
      ELSE
         IF (wcod_califica = "P1" OR wcod_califica = "P2") THEN
            LET wcobra_comision = "M";
         ELSE
            LET wcobra_comision = "T";
         END IF;
      END IF;
   END IF;

   SELECT cobra_comis INTO si_cobra FROM bdisolicitud:ss_captrescom
    WHERE num_solicitud = pnum_credito[1,11]
      AND secuencia     = pnum_credito[16,17];
   IF si_cobra IS NULL OR si_cobra = "N"  THEN
        LET wcobra_comision = "N";
   ELSE
        LET wcobra_comision = wcobra_comision;
   END IF;
   IF wcod_tipcred = "02" THEN
      LET wcobra_comision = "S";
   END IF;

-- Si es un credito SIREFA o VALOR PRESENTE el favp = 1

   IF (wtipo_calculo = "05" or wtipo_calculo = "07") THEN
      LET wfavp = 1;
   ELSE
      LET wfavp = 0;
   END IF

 -- Valida si el cliente tiene cuenta para realizar los abonos correspodien-
 -- tes

   SELECT
      num_cta,
      tipo_cta
   INTO
      wnum_cta,
      wtipo_cta
   FROM
      sd_ctascarg
   WHERE
      num_credito = pnum_credito
   AND
      naturaleza = "A";

   IF (wnum_cta IS NULL or wnum_cta = " ") THEN
      LET cod_ret = "028";
      RETURN cod_ret;
   END IF

-- Termina obtencion de datos generales para calculos y aplicacion


-- Inicia Validacion para no generar dos o mas ministraciones

   SELECT
      status_ministra,
      monto_otorgado
   INTO
      wstatus_ministra,
      wmonto_otorgado
   FROM
      sd_detminis
   WHERE
      num_credito = pnum_credito
   AND
      num_minis = 1;

   IF (wstatus_ministra = "A") THEN
      LET cod_ret = "027";
      RETURN cod_ret;
   END IF;

-- Termina Validacion para no generar dos o mas ministraciones

-- Inicia Proceso de primera ministracion

-- Si el tipom de calculo es 02 se cobran intereses por anticipado

   IF (wtipo_calculo = "02") THEN
      LET wdias = wfecha_vencim - wfecha_hoy;
      LET wint_anticip = (wmonto_otorgado * wtasa * wdias / 36000);
      LET wmonto_ivaint = wint_anticip * wiva ;
   ELSE
      LET wint_anticip = 0;
      LET wmonto_ivaint = 0;
   END IF;

   IF (wcobra_comision <> "N") THEN
      LET wcomision = wmonto_otorgado * wapli_factor / 100;
      IF (wcobra_comision = "M") THEN
         LET wcomision = wcomision * .5;
      END IF;
      IF (wcomision < wmonto_min) THEN
         LET wcomision = wmonto_min;
      END IF;
   ELSE
      LET wcomision = 0;
   END IF;


   IF (wcomision <> 0) THEN
      LET wmonto_ivacom = wcomision * wiva ;
   ELSE
      LET wmonto_ivacom = 0;
   END IF;


   IF (wusuario = "cs2") THEN
      COMMIT WORK;
   END IF;

   LET ptransacc_suc = "0000";
   LET pdocto        = 0;
   LET pdias_ret     = 0;
   LET pmonto        = 0;


   BEGIN WORK;

-- Realiza cargos y abonos a cuentas de cheques
   IF (wtipo_cta = "2") THEN        -- CUENTAS DE CHEQUES
      LET ptransacc = "0213";       -- MINISTRACION CREDITO;
      EXECUTE PROCEDURE bdicheq:abono(wsucursal, wusuario, ptransacc,
                                      ptransacc_suc, wfolio_suc, wnum_cta,
                                      pdocto, wmonto_otorgado, wmonto_otorgado,
                                      pmonto, pmonto, pdias_ret, wdivisa)
      INTO cod_ret;
      let  cod_ret = "000";
      IF (cod_ret = "000") THEN      -- CARGA INTERESES, IVA Y CMISIONES
         IF(wint_anticip <> 0) THEN
            LET ptransacc = "3339";  --INTERESES POR ANTICIPADO
            EXECUTE PROCEDURE bdicheq:cargo(wsucursal, wusuario, ptransacc,
                              ptransacc_suc, wfolio_suc, wnum_cta, pdocto,
                              wint_anticip, wdivisa)
            INTO cod_ret, ptransacc;
            let  cod_ret = "000";
            let  ptransacc = "";

            IF (cod_ret = "000") THEN
               LET ptransacc = "3340";  --IVA INTERESES POR ANTICIPADO
               EXECUTE PROCEDURE bdicheq:cargo(wsucursal, wusuario, ptransacc,
                                 ptransacc_suc, wfolio_suc, wnum_cta, pdocto,
                                 wmonto_ivaint, wdivisa)
               INTO cod_ret, ptransacc;
            let  cod_ret = "000";
            let  ptransacc = "";
            END IF;                     -- cod_ret = 000 cargo Int_Ant
         END IF;                        -- wint_anticip <> 0
         IF (wcomision <> 0) THEN
            LET ptransacc = "3311";
            EXECUTE PROCEDURE bdicheq:cargo(wsucursal, wusuario, ptransacc,
                              ptransacc_suc, wfolio_suc, wnum_cta, pdocto,
                              wcomision, wdivisa)
            INTO cod_ret, ptransacc;
            let  cod_ret = "000";
            let  ptransacc = "";
            IF (cod_ret = "000") THEN
               LET ptransacc = "3312";
               EXECUTE PROCEDURE bdicheq:cargo(wsucursal, wusuario, ptransacc,
                              ptransacc_suc, wfolio_suc, wnum_cta, pdocto,
                              wmonto_ivacom, wdivisa)
               INTO cod_ret, ptransacc;
            END IF;                      -- cod ret = 000 cargo comision

            --Inserta el datalle de la Comision en Credito

            INSERT INTO sd_detcomi
            VALUES(wfecha_hoy,wcod_comis,pnum_credito,wcomision,wapli_factor,"P");

         END IF;                         -- wcomison <> 0
      END IF;                           -- cod_ret = 000 abono minist
   ELSE                                 -- CUENTAS DE AHORROS
-- Realiza cargos y abonos a cuentas de ahorros  wtipo_cuenta = 3
      LET ptransacc = "0446";           -- MINISTRACION DE CREDITO
      EXECUTE PROCEDURE bdiahor:abono(wsucursal, wusuario, ptransacc,
                        ptransacc_suc, wfolio_suc, wnum_cta, wmonto_otorgado,
                        wmonto_otorgado, pmonto, pmonto, pdias_ret, wdivisa,
                        pdocto)
      INTO cod_ret, pdocto, pmonto, pmonto, pmonto, pmonto;
        let cod_ret = "000";
        let pdocto = 0;
        let pmonto = 0;
        let pmonto = 0;
        let pmonto = 0;
        let pmonto = 0;

      IF (cod_ret = "000") THEN
         IF (wint_anticip <> 0) THEN
            LET ptransacc = "3454";      --CARGO DE INT.ANT.
            EXECUTE PROCEDURE bdiahor:cargo(wsucursal, wusuario, ptransacc,
                              ptransacc_suc, wfolio_suc, wnum_cta,
                              wint_anticip, wdivisa, pdocto)
            INTO cod_ret, pdocto, pmonto;
            let cod_ret = "000";
            let pdocto = 0;
            let pmonto = 0;
            IF (cod_ret = "000") THEN
               LET ptransacc = "3455";    -- IVA INT. ANTICIPADOS
               EXECUTE PROCEDURE bdiahor:cargo(wsucursal, wusuario, ptransacc,
                              ptransacc_suc, wfolio_suc, wnum_cta,
                              wmonto_ivaint, wdivisa, pdocto)
               INTO cod_ret, pdocto, pmonto;
            let cod_ret = "000";
            let pdocto = 0;
            let pmonto = 0;
            END IF;                      -- cod_re=000 de cargo de int ant
         END IF;                         -- wint_anticip <> 0
         IF (wcomision <> 0) THEN
            LET ptransacc = "3456";      -- COMISION POR APERTURA CRED.
            EXECUTE PROCEDURE bdiahor:cargo(wsucursal, wusuario, ptransacc,
                              ptransacc_suc, wfolio_suc, wnum_cta,
                              wcomision, wdivisa, pdocto)
            INTO cod_ret, pdocto, pmonto;
            let cod_ret = "000";
            let pdocto = 0;
            let pmonto = 0;
            IF (cod_ret = "000") THEN
               LET ptransacc = "3457";    -- IVA COMISION APERT. CRED
               EXECUTE PROCEDURE bdiahor:cargo(wsucursal, wusuario, ptransacc,
                              ptransacc_suc, wfolio_suc, wnum_cta,
                              wmonto_ivacom, wdivisa, pdocto)
               INTO cod_ret, pdocto, pmonto;
            let cod_ret = "000";
            let pdocto = 0;
            let pmonto = 0;
            END IF;                       -- cod_ret = "000" cargo comis
         END IF;                         -- wcomison <> 0
      END IF;                           -- cod_ret = 000 ABONO A AHORROS
   END IF;                              -- IF del tipo de cuenta

--GENERA EL MOVIMIENTO DIARIO

   IF (cod_ret = "000") THEN            -- APLICO CORRECTAMENTE EN CHQ/AHO
      EXECUTE PROCEDURE genmov(pnum_credito, wnum_producto, 1, "002",
                               wfecha_hoy, wmonto_otorgado, wfolio_suc,
                               wsucursal, wdivisa, "0021")
      INTO cod_ret;
      IF (cod_ret = "000") THEN
-- CARGA IVA
         IF (wint_anticip <> 0) THEN
            EXECUTE PROCEDURE genmov(pnum_credito, wnum_producto, 2, "002",
                                  wfecha_hoy, wint_anticip, wfolio_suc,
                                  wsucursal, wdivisa, "0000")
            INTO cod_ret;
            IF (cod_ret = "000") THEN
               EXECUTE PROCEDURE genmov(pnum_credito, wnum_producto, 3, "002",
                                  wfecha_hoy, wmonto_ivaint, wfolio_suc,
                                  wsucursal, wdivisa, "0000")
               INTO cod_ret;
            END IF;                        -- CARGA DE IVA DE INT.ANTICIP.
         END IF;                           -- CARGA DE INT ANTICIP.

-- CARGA COMISIONES
         IF (cod_ret = "000") THEN
            IF (wcomision <> 0) THEN
               EXECUTE PROCEDURE genmov(pnum_credito, wnum_producto, 4,
                         "002", wfecha_hoy, wcomision, wfolio_suc,
                         wsucursal, wdivisa, "0000")
               INTO cod_ret;
               IF (cod_ret = "000") THEN
                  EXECUTE PROCEDURE genmov(pnum_credito, wnum_producto, 5,
                         "002", wfecha_hoy, wmonto_ivacom, wfolio_suc,
                         wsucursal, wdivisa, "0000")
                  INTO cod_ret;
               END IF;                    -- CARGA IVA DE COMISION
            END IF;                       -- CARGA DE COMISION
         END IF;                         -- cod_ret = 000 PARA CARG.COMI.
      END IF;                            -- CARGA DE INT y COMIS
   END IF;                               -- CARGA MOVIMIENTO DIARIO

-- Si no se ha producido error, se procede a repartir el monto ministrado
-- En las cuotas de capital

   IF (cod_ret = "000") THEN
      LET wministrado = wmonto_otorgado;
      FOREACH
         SELECT
            num_cuota,
            fecha_cuota,
            monto_cuota
         INTO
            wnum_cuota,
            wfecha_cuota,
            wmonto_cuota
         FROM
            sd_pagocapit
         WHERE
            num_credito = pnum_credito
         AND
            status_cuota <> "5"
         AND
            bandera_ministra = "P"
         ORDER BY
            num_cuota

         IF (wmonto_cuota < wministrado) THEN
            UPDATE
               sd_pagocapit
            SET
               saldo_cuota = wmonto_cuota,
               num_pagares = 1,
               bandera_ministra = "A"
            WHERE
               num_credito = pnum_credito
            AND
               num_cuota = wnum_cuota;

            LET wministrado = wministrado - wmonto_cuota;
         ELSE
            IF (wmonto_cuota > wministrado) THEN
               UPDATE
                  sd_pagocapit
               SET
                  saldo_cuota = wministrado,
                  num_pagares = 1,
                  bandera_ministra = "A"
               WHERE
                  num_credito = pnum_credito
               AND
                  num_cuota = wnum_cuota;

               LET wministrado = 0;
            ELSE
               UPDATE
                  sd_pagocapit
               SET
                  saldo_cuota = wministrado,
                  num_pagares = 1,
                  bandera_ministra = "A"
               WHERE
                  num_credito = pnum_credito
               AND
                  num_cuota = wnum_cuota;

               LET wministrado = 0;
            END IF;
         END IF;
         IF (wministrado = 0) THEN
            EXIT FOREACH;
         END IF;
      END FOREACH;      -- Termina de repartir el monto ministrado

 -- REALIZA LA AFECTACION A LAS TABLAS DE sd_maesdos, sd_contratos, sd_maecred

      UPDATE
         sd_maesdos
      SET
         sdo_cap_insoluto = sdo_cap_insoluto + wmonto_otorgado,
         mto_ministra_cap = mto_ministra_cap + wmonto_otorgado,
         sdo_capital      = sdo_capital + wmonto_otorgado,
         favp             = wfavp,
         sdo_int_anticip  = wint_anticip
      WHERE
         num_credito = pnum_credito;

      IF (wcontrato <> " ") THEN
         UPDATE
            sd_maecontrato
         SET
            monto_ejercido = monto_ejercido + wmonto_otorgado
         WHERE
            num_contrato = wcontrato;
      END IF;

      UPDATE
         sd_detminis
      SET
         status_ministra = "A",
         monto_real_otorg = wmonto_otorgado,
         fecha_otorga = wfecha_hoy
      WHERE
         num_credito = pnum_credito
      AND
         num_minis = 1;

      UPDATE
         sd_maecred
      SET
         bandera_ministra = "M"
      WHERE
         num_credito = pnum_credito;


      IF (wtasa_fija_o_var = "3") THEN
         IF (wrev_tasa_var_per IS NULL OR wrev_tasa_var_per = " " OR
             wdia_para_revisar IS NULL OR  wdia_para_revisar = 0) THEN
            LET cod_ret = "092";
         ELSE
            DELETE FROM sd_revtasa
            WHERE num_credito = pnum_credito;


            IF (wrev_tasa_var_per = 2 AND wdia_para_revisar = 50 OR
                wrev_tasa_var_per = 3 AND wdia_para_revisar = 50 OR
                wrev_tasa_var_per = 4 AND wdia_para_revisar = 50 OR
                wrev_tasa_var_per = 5 AND wdia_para_revisar = 50 ) THEN


               INSERT INTO
                  sd_revtasa
               VALUES
                  (pnum_credito,
                   wfecha_hoy,
                   wrev_tasa_var_per,
                   0,
                   wdia_para_revisar,
                   wfecha_hoy);
            ELSE

               INSERT INTO
                  sd_revtasa
               VALUES
                  (pnum_credito,
                   wfecha_hoy,
                   wrev_tasa_var_per,
                   0,
                   wdia_para_revisar,
                   wprox_fecha);
            END IF;
         END IF;
      END IF;
   END IF;              -- Termina de actualizar maesdos, maecred, etc

   IF (cod_ret <> "000") THEN
      ROLLBACK WORK;
   ELSE
      COMMIT WORK;
   END IF;
   IF (wusuario = "cs2") THEN
      BEGIN WORK;
   END IF

   RETURN cod_ret;

END PROCEDURE;