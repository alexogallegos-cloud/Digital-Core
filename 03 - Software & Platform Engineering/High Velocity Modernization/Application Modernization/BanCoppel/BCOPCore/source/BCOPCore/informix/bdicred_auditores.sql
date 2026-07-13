CREATE PROCEDURE "informix".auditores()
   RETURNING CHAR(4)  ,
             CHAR(20) ,
             CHAR(2)  ;

   DEFINE NumCredito      CHAR(20);
   DEFINE NumProducto     CHAR(4);
   DEFINE StatusCred      VARCHAR(2);
   DEFINE FechaApertura   DATE;
   DEFINE FechaVencim     DATE;
   DEFINE Descuadre       CHAR(2);
   DEFINE SdoInteres      MONEY(8,2);
   DEFINE SdoExigInt      MONEY(8,2);
   DEFINE SdoNoExig       MONEY(8,2);
   DEFINE SdoMoratorio    MONEY(8,2);
   DEFINE SdoCapital      MONEY(8,2);
   DEFINE SdoCapInsoluto  MONEy(8,2);
   DEFINE MontoVencido    MONEY(8,2);
   DEFINE MtoVencTrasp    MONEY(8,2);
   DEFINE MontoFinanciado MONEY(8,2);
   DEFINE MOntoReservado  MONEY(8,2);
   DEFINE SdoAcumIntPer   MONEY(8,2);
   DEFINE MontoOtorgado   MONEY(8,2);
   DEFINE MtoVencInt      MONEY(8,2);
   DEFINE MtoVencTraInt   MONEY(8,2);

   DEFINE StatusCuota     CHAR(1);
   DEFINE MontoCuota      MONEY(8,2);
   DEFINE SaldoCuota      MONEY(8,2);
   DEFINE MontoRealPag    MONEY(8,2);
   DEFINE MontoMoratorio  MONEY(8,2);

   DEFINE wCapInsoluto    MONEY(8,2);
   DEFINE wMtoVencTRasp   MONEY(8,2);
   DEFINE wMontoVencido   MONEY(8,2);
   DEFINE wSdoCapital     MONEY(8,2);

   DEFINE wSdoInteres     MONEY(8,2);
   DEFINE wSdoNoExig      Money(8,2);
   DEFINE wMtoVencInt     MONEY(8,2);
   DEFINE wMtoVencTraInt  MONEY(8,2);

   DEFINE wMoraCap        MONEY(8,2);
   DEFINE wMoraDet        MONEY(8,2);

   --SET DEBUG FILE TO "Auditores.out";


   LET MtoVencTraInt = 0;
   LET Descuadre = '0';

   FOREACH
      SELECT
         a.num_credito,
         a.num_producto,
         a.status_cred,
         a.fecha_apertura,
         a.fecha_vencim,
         b.sdo_intereses,
         b.sdo_exig_int,
         b.sdo_no_exig,
         b.sdo_moratorio,
         b.sdo_capital,
         b.sdo_cap_insoluto,
         b.monto_vencido,
         b.mto_venc_trasp,
         b.monto_financiado,
         b.monto_reservado,
         b.sdo_acum_intper,
         b.monto_otorgado,
         b.mto_venc_int,
         b.mto_venc_tra_int
      INTO
         NumCredito,
         NumProducto,
         StatusCred,
         FechaApertura,
         FechaVencim,
         SdoInteres,
         SdoExigInt,
         SdoNoExig,
         SdoMoratorio,
         SdoCapital,
         SdoCapInsoluto,
         MontoVencido,
         MtoVencTrasp,
         MontoFinanciado,
         Montoreservado,
         SdoAcumIntPer,
         MontoOtorgado,
         MtoVencInt,
         MtoVencTraInt

      FROM
         sd_maecred a,
         sd_maesdos b
      WHERE
         b.num_credito = a.num_credito
      --and a.num_credito = '100000787410001'
      ORDER BY
         a.num_producto,
         a.num_credito

      LET Descuadre = '0';
      IF (SdoCapInsoluto <> SdoCapital + MontoVencido + MtoVencTrasp) THEN
         LET Descuadre = '1';
      END IF;

      IF (SdoExigInt <> MtoVencInt + MtovencTraInt) THEN
         LET Descuadre = '2';
      END IF;

      IF (NumProducto = '410') THEN
         IF (SdoInteres <> SdoNoExig) THEN
            LET Descuadre = '3';
         END IF;
      END IF;

      IF (NumProducto <> '410') THEN
         LET wCapInsoluto = 0;
         LET wMtoVencTrasp = 0;
         LET wMontoVencido = 0;
         LET wSdoCapital = 0;
         FOREACH
            SELECT
               status_cuota,
               SUM(monto_cuota),
               SUM(saldo_cuota),
               SUM(monto_real_pag),
               SUM(monto_moratorio)
            INTO
               StatusCuota,
               MontoCuota,
               SaldoCuota,
               MontoRealPag,
               MontoMoratorio
            FROM
               sd_pagocapit
            WHERE
               num_credito = NumCredito
            GROUP BY
               status_cuota
            LET wCapInsoluto = wCapInsoluto + SaldoCuota - MontoRealPag;
            IF(StatusCuota = '2') THEN
               LET wMtoVencTrasp = SaldoCuota - MontoRealPag;
            END IF;
            IF(StatusCuota = '7') THEN
               LET wMontoVencido = SaldoCuota - MontoRealPag;
            END IF;
            IF (StatusCuota = '1') THEN
               LET wSdoCapital = SaldoCuota - MontoRealPag;
            END IF;

         END FOREACH;
         IF (WCapInsoluto <> SdoCapInsoluto) THEN
            Let Descuadre = '4';
         END IF;
         IF (wMontoVencido <> MontoVencido) THEN
            LET Descuadre = '5';
         END IF;
         IF (wMtoVencTrasp <> MtovencTrasp) THEN
            LET Descuadre = '6';
         END IF;
         IF (wSdoCapital <> SdoCapital) THEN
            LET Descuadre = 7;
         END IF;


         LET wSdoInteres = 0;
         LET wSdoNoExig = 0;
         LET wMtoVencInt = 0;
         LET wMtoVencTraInt = 0;
         FOREACH
            SELECT
               status_cuota,
               SUM(monto_cuota),
               SUM(monto_real_pag)
            INTO
               StatusCuota,
               MontoCuota,
               MontoRealPag
            FROM
               sd_paginter
            WHERE
               num_credito = NumCredito
            GROUP BY
               status_cuota
            LET wSdoInteres = wSdoInteres + MontoCuota - MontoRealPag;
            IF(StatusCuota = '2') THEN
               LET wMtoVencTraInt = MontoCuota - MontoRealPag;
            END IF;
            IF(StatusCuota = '7') THEN
               LET wMtoVencInt  = MontoCuota - MontoRealPag;
            END IF;
            IF (StatusCuota = '1') THEN
               LET wSdoNoExig = MontoCuota - MontoRealPag;
            END IF;

         END FOREACH;
         IF (WSdoInteres<> SdoInteres) THEN
            Let Descuadre = '8';
         END IF;
         IF (wMtoVencTraInt <> MtoVencTraInt) THEN
            LET Descuadre = '9';
         END IF;
         IF (wMtoVencInt <> MtoVencInt) THEN
            LET Descuadre = '10';
         END IF;
         IF (wSdoNoExig <> SdoNoExig) THEN
            LET Descuadre = 11;
         END IF;

      END IF;


      IF (descuadre <> '0' AND Descuadre <> 8) THEN
         RETURN NumProducto, NumCredito, Descuadre WITH RESUME;
         INSERT INTO X VALUES
            (NumProducto,
            NumCredito,
            Descuadre);
      END IF;
   END FOREACH;


END PROCEDURE;