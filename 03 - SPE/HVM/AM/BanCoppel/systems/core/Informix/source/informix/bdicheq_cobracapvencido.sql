CREATE PROCEDURE "informix".cobracapvencido(e_fcuota DATE)
   RETURNING CHAR(5);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_TpPago        SMALLINT    DEFAULT 0;

   DEFINE GLOBAL g_MontoVencido  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MtoVencTrasp  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_CapVencCob    MONEY(14,2) DEFAULT 0;
   DEFINE gLOBAL g_MontoReservado MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;

   DEFINE vFechaCuota            LIKE sd_pagocapit.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vSaldoCuota            LIKE sd_pagocapit.saldo_cuota;
   DEFINE vMontoRealPag          LIKE sd_pagocapit.monto_real_pag;
   DEFINE vAdeudoCuota           LIKE sd_pagocapit.monto_real_pag;
   DEFINE vStatusCuota           LIKE sd_pagocapit.status_cuota;
   DEFINE vCobro7                LIKE sd_pagocapit.monto_cuota;
   DEFINE vCobro2                LIKE sd_pagocapit.monto_cuota;
   DEFINE vCapCobrado            LIKE sd_pagocapit.monto_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vStatus                LIKE sd_pagocapit.status_cuota;

   DEFINE vMinistrado            LIKE sd_pagocapit.monto_cuota;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraCapVencido.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;




   LET vCobro7 = 0;
   LET vCobro2 = 0;
   LET vCapCobrado = 0;
   LET CodRet = "000";
   LET vMinistrado = 0;

   IF (g_ManejaLinea <> 'S') THEN
      FOREACH
         SELECT fecha_cuota, cuota_rec, saldo_cuota, monto_real_pag,
                (saldo_cuota - monto_real_pag), status_cuota
           INTO vFechaCuota, vCuotaRec, vSaldoCuota, vMontorealPag,
                vAdeudoCuota, vStatusCuota
           FROM sd_pagocapit
          WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND status_cuota IN ('2', '7')
          ORDER BY fecha_cuota

	IF g_TpPago = "2" AND vFechaCuota <> e_fcuota THEN
		CONTINUE FOREACH;
	END IF

         LET vStatus = vStatusCuota;
         IF(g_Remanente > 0) THEN
            IF (g_Remanente >= vAdeudoCuota) THEN
               LET g_Remanente = g_Remanente - vAdeudoCuota;
               LET vCuotaRec = vStatusCuota;
               LET vStatusCuota = '5';
            ELSE
               LET vAdeudoCuota = g_Remanente;
               LET g_Remanente = 0;
            END IF;
            IF(vStatus = '7') THEN
               LET vCobro7 = vCobro7 + vAdeudoCuota;
            ELSE
               LET vCobro2 = vCobro2 + vAdeudoCuota;
            END IF;
            LET vCapCobrado = vCapCobrado + vAdeudoCuota;
            UPDATE
               sd_pagocapit
            SET
               monto_real_pag = monto_real_pag + vAdeudoCuota,
               cuota_rec = vCuotaRec,
               fecha_pago = g_Fecha,
               status_cuota = vStatusCuota
            WHERE
               fecha_cuota = vfechaCuota
            AND
               num_credito = g_NumCredito
            AND
               empresa = g_Empresa;
         ELSE
            EXIT FOREACH;
         END IF;
      END FOREACH;
   ELSE
      IF (g_MontoVencido > 0 AND g_Remanente > 0) THEN
         IF (g_Remanente >= g_MontoVencido) THEN
            LET g_Remanente = g_Remanente - g_MontoVencido;
            LET vCobro7 = vCobro7 + g_MontoVencido;
	    LET g_MontoVencido = 0;
         ELSE
            LET g_MontoVencido = g_MontoVencido - g_Remanente;
	    LET vCobro7 = vCobro7 + g_Remanente;
            LET g_Remanente = 0;
         END IF;
         LET vCapCobrado = vCapCobrado + vCobro7;
      END IF;
      IF (g_MtoVencTrasp > 0 AND g_Remanente > 0) THEN
         IF (g_Remanente >= g_MtoVencTrasp) THEN
            LET g_Remanente = g_Remanente - g_MtoVencTrasp;
            LET vCobro2 = vCobro2 + g_MtoVencTrasp;
	    LET g_MtoVencTrasp = 0;
         ELSE
            LET g_MtoVencTrasp = g_MtoVencTrasp - g_Remanente; 
	    LET vCobro2 = vCobro2 + g_Remanente;
            LET g_Remanente = 0;
         END IF;
         --LET vCobro2 = vCobro2 + g_MtoVencTrasp;
         LET vCapCobrado = vCapCobrado + vCobro2;
      END IF;
      LET vMinistrado = vCobro7 + vCobro2;

      IF g_MontoVencido = 0 AND vCobro7 > 0 THEN
	UPDATE sd_amortiza_credito 
	   SET capital_status = "5",
	       capital_pagado = capital_debe
         WHERE empresa = g_Empresa
           AND num_credito = g_NumCredito
	   AND capital_status = "7"
	   AND capital_debe = (capital_pagado + vCobro7);
      END IF

      IF g_MtoVencTrasp = 0 AND vCobro2 > 0 THEN
	UPDATE sd_amortiza_credito 
	   SET capital_status = "5",
	       capital_pagado = capital_debe
         WHERE empresa = g_Empresa
           AND num_credito = g_NumCredito
	   AND capital_status IN ("2","7");
      END IF

      
   END IF;

   IF (vCapCobrado > 0) THEN
      IF (g_ManejaLinea = 'S') THEN
         UPDATE sd_maesdos
            SET monto_vencido    = monto_vencido - vCobro7,
                mto_venc_trasp = mto_venc_trasp - vCobro2,
                sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                mto_ministra_cap = mto_ministra_cap - vMinistrado,
                abonos_mes_cap  = abonos_mes_cap + vCapCobrado
          WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito;
	--LET g_MontoFinanciado = g_MontoFinanciado - vCapCobrado;
      ELSE
         UPDATE sd_maesdos
         SET
            monto_vencido    = monto_vencido - vCobro7,
            mto_venc_trasp = mto_venc_trasp - vCobro2,
            sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado
         WHERE
            empresa = g_Empresa
         AND
            num_credito = g_NumCredito;

      END IF;

      IF (vCobro7 > 0) THEN
         LET vReferencia = 7;   --Capital vencido no traspasado
         CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                     g_CodigoFun, g_Fecha, vCobro7, g_Folio,
                     g_Sucursal, g_Divisa, g_Transacc) RETURNING
                     CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
            RETURN CodRet;
         ELSE
            LET CodRet = "000";
         END IF;
      END IF;
      IF (vCobro2 > 0) THEN
         LET vReferencia = 8;   --Capital vencido traspasado
         CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                     g_CodigoFun, g_Fecha, vCobro2, g_Folio,
                     g_Sucursal, g_Divisa, g_Transacc) RETURNING
                     CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
            RETURN CodRet;
         ELSE
            LET CodRet = "000";
         END IF;
      END IF;
      LET g_CapVencCob = g_CapVencCob + vCapCobrado;
   END IF;

   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital vencido, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobracapvigente(e_fcuota DATE)
   RETURNING CHAR(5);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL g_CapVig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_CapVigCob     MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MontoReservado  MONEY(14,2) DEFAULT 0;

   DEFINE vFechaCuota            LIKE sd_pagocapit.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vSaldoCuota            LIKE sd_pagocapit.saldo_cuota;
   DEFINE vMontoRealPag          LIKE sd_pagocapit.monto_real_pag;
   DEFINE vAdeudoCuota           LIKE sd_pagocapit.monto_cuota;
   DEFINE vStatusCuota           LIKE sd_pagocapit.status_cuota;
   DEFINE vCobro1                LIKE sd_pagocapit.monto_cuota;
   DEFINE CapCobrado             LIKE sd_pagocapit.monto_cuota;
   DEFINE vStatus                LIKE sd_pagocapit.status_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vPagMinCap             MONEY(14,2);
   DEFINE vMtoMinistraCap        MONEY(14,2);

   DEFINE vCobro0                LIKE sd_pagocapit.monto_cuota;


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraCapVigente.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;



   LET CodRet = '000';
   LET vCObro1 = 0;
   LET vCobro0 = 0;

   LET vMtoMinistraCap = 0;
   IF (g_ManejaLinea <> 'S') THEN
      SELECT fecha_cuota, cuota_rec, saldo_cuota, monto_real_pag,
             (saldo_cuota - monto_real_pag), status_cuota
        INTO vFechaCuota, vCuotaRec, vSaldoCuota, vMontoRealPag,
             vAdeudoCuota, vStatusCuota
        FROM sd_pagocapit
       WHERE empresa = g_Empresa
         AND num_credito = g_NumCredito
         AND fecha_cuota = e_fcuota;

      IF(vStatusCuota <> '1') THEN
         RETURN CodRet;
      END IF;
      LET vStatus = vStatusCuota;
      IF (g_Remanente >= vAdeudoCuota) THEN
         LET g_Remanente = g_Remanente - vAdeudoCuota;
         LET vCuotaRec = vStatusCuota;
         LET vStatusCuota = '5';
      ELSE
         LET vAdeudoCuota = g_Remanente;
         LET g_Remanente = 0;
      END IF;
      LET vCobro1 = vCobro1 + vAdeudoCuota;
      LET vCobro0 = vCobro1;

      UPDATE
         sd_pagocapit
      SET
         monto_real_pag = monto_real_pag + vAdeudoCuota,
         fecha_pago     = g_fecha,
         status_cuota   = vStatusCuota
      WHERE
         empresa     = g_empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFechaCuota;

      UPDATE
         sd_maesdos
      SET
         sdo_capital        = sdo_capital - vCobro1 ,
         sdo_cap_insoluto   = sdo_cap_insoluto - vCobro1
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito;


      -------------------------------
      --      TARJETA              --
      -------------------------------
   ELSE

      IF (g_Remanente > 0 AND g_CapVig > 0) THEN
         IF (g_Remanente >= g_CapVig) THEN
            Let g_Remanente = g_Remanente - g_CapVig;
            LET vCobro0 = g_CapVig;
	    LET g_CapVig = 0;
         ELSE
            LET vCobro0 = g_Remanente;
            LET g_Remanente = 0;
         END IF;

         LET vCobro1 = vCobro1 + vCobro0;
      END IF

      UPDATE sd_maesdos
         SET sdo_capital        = sdo_capital - vCobro0 ,
             sdo_cap_insoluto   = sdo_cap_insoluto - vCobro0,
             mto_ministra_cap   = mto_ministra_cap - vCobro0,
             abonos_mes_cap     = abonos_mes_cap + vCobro0
       WHERE empresa = g_Empresa
         AND num_credito = g_NumCredito;

   END IF;

   IF (vCobro0 > 0) THEN
      LET vReferencia = 10;   --Capital Vigente
      CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  g_CodigoFun, g_Fecha, vCobro1, g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc) RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;
   END IF;
   LET g_CapVigCob = g_CapVigCob + vCobro0;

   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital vigente, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'VERSION: 1.00.000',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobraintvencido(e_fcuota DATE)
      RETURNING CHAR(5);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_TpPago        SMALLINT    DEFAULT 0;

   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_IntVencCob    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoVencInt    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoVencTraInt MONEY(14,2) DEFAULT 0;
   --DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;

   DEFINE vFechaCuota            LIKE sd_paginter.fecha_cuota;
   DEFINE vIntVenc               LIKE sd_paginter.monto_cuota;
   DEFINE vCuotaRec              LIKE sd_paginter.cuota_rec;
   DEFINE vMontoCuota            LIKE sd_paginter.monto_cuota;
   DEFINE vMontoRealPag          LIKE sd_paginter.monto_real_pag;
   DEFINE vMontoFinanc           LIKE sd_paginter.monto_financiado;
   DEFINE vStatusCuota           LIKE sd_paginter.status_cuota;
   DEFINE vIntCob                LIKE sd_paginter.monto_cuota;
   DEFINE vIntFinan              LIKE sd_paginter.monto_cuota;
   DEFINE vIntCob7               LIKE sd_paginter.monto_cuota;
   DEFINE vIntCob2               LIKE sd_paginter.monto_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vStatus                LIKE sd_paginter.status_cuota;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIntVencido.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;



   LET vIntCob   = 0;
   LET vIntFinan = 0;
   LET vIntCob7  = 0;
   LET vIntCob2  = 0;
   LET CodRet    = '000';
   LET vIntVenc  = 0;

   --IF (g_ManejaLinea <> 'S') THEN
   FOREACH
         SELECT fecha_cuota, interes_status_ant, --cuota_rec 
                 interes_debe, interes_pagado,
                 (interes_debe - interes_pagado), --monto_financiado,
                 interes_status
                 
         --SELECT fecha_cuota, cuota_rec, monto_cuota, monto_real_pag,
         --       (monto_cuota - monto_real_pag), monto_financiado, status_cuota
           INTO vFechaCuota, vCuotaRec, 
                 vMontoCuota, vMontoRealPag, vIntVenc,
                --vMontoFinanc, 
                 vStatusCuota
           FROM sd_amortiza_credito --sd_paginter
          WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND interes_status in ('2', '7') --status_cuota IN ('2', '7')
            AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
          ORDER BY fecha_cuota

        IF g_TpPago = "2" AND vFechaCuota <> e_fcuota THEN
            CONTINUE FOREACH;
	END IF

        LET vStatus = vStatusCuota;

        IF (g_Remanente > 0) THEN
            IF (g_Remanente >= vIntVenc) THEN
                LET g_Remanente = g_Remanente - vIntVenc;
                --IF (vStatusCuota = '7') THEN
                --   LET vIntCob7 = vIntCob7 + vIntVenc;
                --ELSE
                --   LET vIntCob2 = vIntCob2 + vIntVenc;
                --END IF;
                if g_ManejaLinea <> 'S' then
                     LET vCuotaRec = vStatusCuota;
                     LET vStatusCuota = '5';
                end if;
            ELSE
                LET vIntVenc = g_Remanente;
                LET g_Remanente = 0;
               --IF (vStatusCuota = '7') THEN
               --   LET vIntCob7 = vIntCob7 + vIntVenc;
               --ELSE
               --   LET vIntCob2 = vIntCob2 + vIntVenc;
               --END IF;
            END IF;
            ---INSERTAR AQUI LAS LINEAS COMENTADAS INMEDIATO ARRIBA
            IF (vStatusCuota = '7') THEN
                LET vIntCob7 = vIntCob7 + vIntVenc;
            ELSE
                LET vIntCob2 = vIntCob2 + vIntVenc;
            END IF;

            UPDATE
                sd_amortiza_credito  --sd_paginter
            SET
               interes_status_ant = vCuotaRec,
               interes_pagado     = interes_pagado + vIntVenc,  --monto_real_pag = vIntVenc,
               interes_status     = vStatusCuota,               --status_cuota       = vStatusCuota,
               --fecha_pag = g_fecha
               interes_fecha_pago = g_fecha
            WHERE
               empresa = g_empresa
            AND
               num_credito = g_NumCredito
            AND
               fecha_cuota = vFechaCuota;
       --     LET g_IntVencCob = g_IntVencCob + vIntVenc;   --OJO YA ESTABA COMENTADA
         END IF;
         IF (g_Remanente = 0) THEN
            EXIT FOREACH;
         END IF;
   END FOREACH;

   --ELSE
	-- *****************************
	-- *         TARJETA           *
	-- *****************************

    /*
      IF (g_SdoVencInt > 0 AND g_Remanente > 0) THEN
         IF (g_Remanente >= g_SdoVencInt) THEN
            LET g_Remanente = g_Remanente - g_SdoVencInt;
            LET vIntVenc = vIntVenc + g_SdoVencInt;
         ELSE
            LET g_SdoVencInt = g_Remanente;
            LET g_Remanente = 0;
            LET vIntVenc = vIntVenc + g_SdoVencInt;
         END IF;
         LET vIntCob7 = g_SdoVencInt;
      END IF;
      IF (g_SdoVencTraInt > 0 AND g_Remanente > 0) THEN
         IF (g_Remanente >= g_SdoVencTraInt) THEN
            LET g_Remanente = g_Remanente - g_SdoVencTraInt;
            LET vIntVenc = vIntVenc + g_SdoVencTraInt;
         ELSE
            LET g_SdoVencTraInt = g_Remanente;
            LET g_Remanente = 0;
            LET vIntVenc = vIntVenc + g_SdoVencTraInt;
         END IF;
         LET vIntCob2 = vIntCob2 + g_SdoVencTraInt;
      END IF;
   END IF;
*/
   UPDATE
      sd_maesdos
   SET
      sdo_exig_int = sdo_exig_int - vIntCob7 - vIntCob2,
      --monto_financiado = monto_financiado - vIntCob7 - vIntCob2,
      mto_venc_int = mto_venc_int - vIntCob7,
      mto_venc_tra_int = mto_venc_tra_int - vIntCob2
   WHERE empresa = g_Empresa
   AND num_credito = g_NumCredito;

   --LET g_MontoFinanciado = g_MontoFinanciado - (vIntCob2 + vIntCob7);

   IF (vIntCob7 > 0) THEN
      LET vReferencia = 3;   --Interes vencido no traspasado
      CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  g_CodigoFun, g_Fecha, vIntCob7, g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc) RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;
   END IF;

   IF (vIntCob2 > 0) THEN

      LET vReferencia = 5;   -- Interes Vencido Traspasado
      CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  g_CodigoFun, g_Fecha, vIntCob2, g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc) RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;
   END IF;
   LET g_IntVencCob = g_IntVencCob + (vIntCob7 + vIntCob2);
   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de intereses vencidos, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobraivaint(e_fcuota DATE)
   RETURNING CHAR(5);

   DEFINE CodRet              CHAR(5);
   DEFINE Mensaje             CHAR(80);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nRows               SMALLINT;

   DEFINE GLOBAL g_Empresa          CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito       CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Impuesto         MONEY(14,2) DEFAULT 0;
--   DEFINE GLOBAL g_Seguro           MONEY(14,2) DEFAULT 0;
--   DEFINE GLOBAL g_Comision         MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha            DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal         CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa           CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc         CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_TpPago           SMALLINT    DEFAULT 0;
--   DEFINE GLOBAL g_MontoFinanciado  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_StCred           CHAR(2)     DEFAULT ' ';

   DEFINE GLOBAL g_CodigoFun        CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio            CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_Iva              MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MoraIva          MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IvaCte	    DECIMAL(9,6) DEFAULT 0;

   DEFINE wCodRefMora               SMALLINT;
   DEFINE wCodComis                 CHAR(4);
   DEFINE wNumCredito               CHAR(20);
   DEFINE wMontoCom                 MONEY(14,2);
   DEFINE wFechaPago                DATE;
   DEFINE wmCom                     MONEY(14,2);
   DEFINE wmPag                     MONEY(14,2);
   DEFINE wEstadoCom                CHAR(1);
   DEFINE wTpCom                    CHAR(1);

   DEFINE vFechaCuota            LIKE sd_amortiza_credito.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vIvadebe               LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaPagado             LIKE sd_amortiza_credito.iva_pagado;
   DEFINE vIvaAdeudo             LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaStatus             LIKE sd_amortiza_credito.iva_status;
   DEFINE vMoraIvaDebe           LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaPagado         LIKE sd_amortiza_credito.mora_iva_pagado;
   DEFINE vMoraIvaAdeudo         LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaStatus         LIKE sd_amortiza_credito.mora_iva_status;
   DEFINE vIvaBase		 DECIMAL(9,6);

   DEFINE vCodFunIva             CHAR(3);

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIva.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

   --SET DEBUG FILE TO "CobraIva.out";
   --TRACE ON;

   LET CodRet     = "000";
   LET vCodFunIva = "340";

   -- *****************************
   -- Extrae Iva Base del Sistema *
   -- *****************************
   SELECT valor INTO vIvaBase 
     FROM bdinteg:si_param
    WHERE empresa = g_Empresa
      AND cod_param = 47;


   IF vIvaBase <> g_IvaCte THEN
     LET wCodRefMora = 26 ;
   ELSE
     LET wCodRefMora = 25 ;
   END IF


   -- *************************************
   -- Calcula Iva de Intereses Moratorios *
   -- *************************************
   FOREACH
      SELECT fecha_cuota, mora_provi_ordi + mora_provi_cope
        INTO vFechaCuota, vMoraIvaDebe
        FROM sd_amortiza_credito
       WHERE num_credito = g_NumCredito
         AND empresa =  g_empresa
         AND (mora_provi_ordi + mora_provi_cope) > 0
       ORDER BY 1

        IF g_TpPago = "2" THEN
            IF e_fcuota <> vFechaCuota THEN
		CONTINUE FOREACH;
            END IF
        END IF;

	LET vMoraIvaDebe = vMoraIvaDebe * g_IvaCte;

        UPDATE sd_amortiza_credito
           SET mora_sdo_ordi = mora_sdo_ordi + mora_provi_ordi,
               mora_sdo_cope = mora_sdo_ordi + mora_provi_cope,
               mora_provi_cope = 0,
               mora_provi_ordi = 0,
               mora_iva_debe = mora_iva_debe + vMoraIvaDebe
       WHERE num_credito = g_NumCredito
         AND empresa =  g_empresa
         AND fecha_cuota = vFechaCuota;

   END FOREACH

   UPDATE sd_maesdos SET sdo_contab_mora = 0,
	                 sdo_moratorio = sdo_contab_mora 
    WHERE num_credito = g_NumCredito
      AND empresa =  g_empresa;

    FOREACH
        SELECT fecha_cuota, (mora_iva_debe - mora_iva_pagado)
          INTO vFechaCuota, vMoraIvaDebe
          FROM sd_amortiza_credito a
         WHERE a.empresa   = g_empresa
           AND a.num_credito = g_NumCredito
           AND capital_status IN ("2","7")
	   AND (mora_iva_debe - mora_iva_pagado) > 0
         ORDER BY fecha_cuota


        IF g_TpPago = "2" THEN
            IF e_fcuota <> vFechaCuota THEN
		CONTINUE FOREACH;
            END IF
        END IF;

        IF (g_Remanente > 0) THEN
                IF g_Remanente >= vMoraIvaDebe then
                    LET g_Remanente    = g_Remanente - vMoraIvaDebe;
                ELSE
                    LET vMoraIvaDebe = g_Remanente;
                    LET g_Remanente    = 0;
                END IF;

                UPDATE sd_amortiza_credito
                SET mora_iva_pagado     = mora_iva_pagado + vMoraIvaDebe,
                    mora_iva_fecha_pago = g_fecha
                WHERE empresa     = g_empresa
                and   num_credito = g_NumCredito
                and   fecha_cuota = vFechaCuota;

                LET g_MoraIva = g_MoraIva + vMoraIvaDebe;  

                CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,wCodrefMora,
                        vCodFunIva, g_Fecha, vMoraIvaDebe, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc) RETURNING
                           CodRet, Mensaje;
                IF (CodRet <> "00000") THEN
                   RETURN CodRet;
                ELSE
                  LET Codret = "000";
                END IF;
            END IF;

            {IF g_Remanente > 0 and vIvaStatus <> '5' then
                IF (g_Remanente >= vIvaAdeudo) THEN
                    LET g_Remanente = g_Remanente - vIvaAdeudo;
                    LET vIvaStatus = '5';
                ELSE
                    LET vIvaAdeudo  = g_Remanente;
                    LET g_Remanente = 0;
                END IF;

                UPDATE sd_amortiza_credito
                SET 
                    iva_pagado     = iva_pagado + vIvaAdeudo,
                    iva_status     = vIvaStatus,
                    iva_fecha_pago = g_fecha
                WHERE
                     empresa     = g_empresa
                and num_credito = g_NumCredito
                and fecha_cuota = vFechaCuota;


                LET g_Iva = g_Iva + vIvaAdeudo;  
                LET wCodigoRef = 2 ; 
                CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto, wCodigoref,
                             g_CodigoFun, g_Fecha, vIvaAdeudo, g_Folio,
                             g_Sucursal, g_Divisa, g_Transacc) RETURNING
                              CodRet, Mensaje;
                IF (CodRet <> "00000") THEN
                    RETURN CodRet;
                ELSE
                    LET Codret = "000";
                END IF;
            END IF;}


    END FOREACH;
    RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procfedimiento para el cobro de comisiones, lo primero que ',
'cobra es el seguro, posteriormente el resto de comisiones que ',
'tengan que cobrarse, es llamada por Principal',
'Se modifica para que realice tambien el cobro por cuota',
'AUTOR : Raul Mendoza D nes',
'MOD   : Axel',
'FECHA : 17/Octubre/2003',
'FEC MOD 10/Enero/2004',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobramoratorios(e_fcuota DATE)
   RETURNING CHAR(5);

   DEFINE CodRet              CHAR(5);
   DEFINE Mensaje             CHAR(80);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nRows               SMALLINT;

   DEFINE GLOBAL g_Empresa      CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito   CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto  CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha        DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa       CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun    CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio        CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_TpPago       SMALLINT    DEFAULT 0;
   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_Moratorio    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntMoraCob   MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ManejaLinea  CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_SdoMoratorio MONEY(14,2) DEFAULT 0;

   DEFINE vPerContMora          CHAR(1);
   DEFINE vFechaCuota           DATE;
   DEFINE vProviMoraOrdi        LIKE sd_detmora.provi_mora_ordi;
   DEFINE vProviMoraCope        LIKE sd_detmora.provi_mora_cope;
   DEFINE vSdoMoraOrdi          LIKE sd_detmora.sdo_mora_ordi;
   DEFINE vSdoMoraCope          LIKE sd_detmora.sdo_mora_cope;
   DEFINE vMontoMora            LIKE sd_detmora.sdo_acum_mes_mora;
   DEFINE vCodigoRef            SMALLINT;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraMoratorios.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;


   SELECT valor
   INTO vPerContMora
   FROM sd_param
   WHERE empresa = g_Empresa
   AND cod_param = '17';

   LET CodRet = "000";
   LET vCodigoRef = 2;
   LET vMontoMora = 0;
   LET g_Moratorio = 0;


      FOREACH
         SELECT fecha_cuota, mora_sdo_ordi - mora_sdo_ordi_pag, 
			     mora_sdo_cope - mora_sdo_cope_pag
           INTO vFechaCuota, vSdoMoraOrdi, vSdoMoraCope
           FROM sd_amortiza_credito
          WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND ( mora_sdo_ordi - mora_sdo_ordi_pag) + 
		( mora_sdo_cope - mora_sdo_cope_pag) > 0

	 IF g_TpPago = "2" AND vFechaCuota <> e_fcuota THEN
		CONTINUE FOREACH;
	 END IF

         IF(g_Remanente > 0) THEN
            IF(g_Remanente >= vSdoMoraCope) THEN
               LET g_Remanente   = g_Remanente - vSdoMoraCope;
               LET vMontoMora    = vMontoMora + vSdoMoraCope;
            ELSE
               LET vSdoMoraCope  = vSdoMoraCope - g_Remanente;
               LET vMontoMora    = vMontoMora + g_Remanente;
            END IF;
            IF(g_Remanente >= vSdoMoraOrdi) THEN
               LET g_Remanente   = g_Remanente - vSdoMoraOrdi;
               LET vMontoMora    = vMontoMora + vSdoMoraOrdi;
            ELSE
               LET vSdoMoraOrdi  = vSdoMoraOrdi - g_Remanente;
               LET vMontoMora    = vMontoMora + g_Remanente;
               LET g_Remanente   = 0;
            END IF;


            UPDATE sd_amortiza_credito
               SET mora_sdo_ordi_pag = mora_sdo_ordi_pag + vSdoMoraOrdi,
                   mora_sdo_cope_pag = mora_sdo_cope_pag + vSdoMoraCope
             WHERE empresa = g_Empresa
               AND num_credito = g_NumCredito
               AND fecha_cuota = vFechaCuota;
            LET g_Moratorio = g_Moratorio + vMontoMora;
	    LET vSdoMoraOrdi = 0;
	    LET vSdoMoraCope = 0;
	   -- Genera Movimiento de Recuperacion de Mora
	   CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,
        	       g_CodigoFun, g_Fecha, vMontoMora, g_Folio,
	               g_Sucursal, g_Divisa, g_Transacc) RETURNING
        	       CodRet, Mensaje;

	   -- Genera Movmiento de Provision Mora
	   CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,1,
        	       "607", g_Fecha, vMontoMora, g_Folio,
               		g_Sucursal, g_Divisa, g_Transacc) RETURNING
	               CodRet, Mensaje;
            LET vMontoMora  = 0;


         END IF
      END FOREACH;

   -- Actualiza sd_maesdos
   LET g_Moratorio = g_Moratorio;
   UPDATE sd_maesdos
      SET sdo_moratorio = sdo_moratorio - g_Moratorio
    WHERE empresa = g_Empresa
      AND num_credito = g_NumCredito;

   LET g_IntMoraCob = g_IntMoraCob + g_Moratorio;
   LET g_Moratorio = 0;
   IF (CodRet <> "00000") THEN
      RETURN CodRet;
   ELSE
      LET CodRet = "000";
   END IF;
   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de intereses moratorios, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".monthadd(d DATE, i INTEGER)
     RETURNING DATE;

     DEFINE d1 DATE;
     DEFINE rv DATE;
     DEFINE rv2 DATE;

     LET d1 = MDY(MONTH(d), 1, YEAR(d)); -- First day of given month
     LET rv2 = EXTEND(d1, YEAR TO DAY) + i UNITS MONTH; -- Add i months
     LET rv = rv2 + (d - d1); -- Add the days back
     IF MONTH(rv) != MONTH(rv2) THEN -- If the month changed
     LET rv = rv - DAY(rv); -- Subtract the number of days
     -- to get last day of prior month
     END IF;
     RETURN rv;
END PROCEDURE;