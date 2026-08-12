CREATE PROCEDURE "informix".cobracapvencidocrd(e_fcuota DATE)
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
   --DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_StCred          CHAR(2)       DEFAULT ' ';
   DEFINE GLOBAL vCtaPagoVenc      INTEGER       DEFAULT 0;
   DEFINE GLOBAL g_NumCte          CHAR(20)      DEFAULT ' ';
   DEFINE GLOBAL g_Cubre_Cuota     CHAR(1)       DEFAULT ' ';
   DEFINE GLOBAL g_MontoAjuste     MONEY(14,2)   DEFAULT 0;

   DEFINE g_MontoAjusteacum7     MONEY(14,2);
   DEFINE g_MontoAjusteacum2     MONEY(14,2);
   DEFINE g_MontoAjusteacum3     MONEY(14,2);

   DEFINE vFechaCuota            LIKE sd_amortiza_creditocrd.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_amortiza_creditocrd.tipo_cuota;
   DEFINE vSaldoCuota            LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vMontoRealPag          LIKE sd_amortiza_creditocrd.capital_pagado;
   DEFINE vAdeudoCuota           LIKE sd_amortiza_creditocrd.capital_pagado;
   DEFINE vStatusCuota           LIKE sd_amortiza_creditocrd.capital_status;
   DEFINE vCobro7                LIKE sd_amortiza_creditocrd.capital_pagado;
   DEFINE vCobro2                LIKE sd_amortiza_creditocrd.capital_pagado;
   DEFINE vCobro3                LIKE sd_amortiza_creditocrd.capital_pagado;
   DEFINE vCapCobrado            LIKE sd_amortiza_creditocrd.capital_pagado;
   DEFINE vReferencia            SMALLINT;
   define vstatusajuste            LIKE sd_amortiza_creditocrd.capital_pagado;
   DEFINE vStatus                LIKE sd_amortiza_creditocrd.capital_status;

   DEFINE vMinistrado            LIKE sd_amortiza_creditocrd.capital_pagado;
   DEFINE vMToTrasp              LIKE sd_amortiza_creditocrd.capital_pagado;
   DEFINE vBandera               CHAR(1);
   define vfechaaux              date;
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraCapVencido.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;


   LET vCobro7      = 0;
   LET vCobro2      = 0;
   LET vCobro3      = 0;
   LET vCapCobrado  = 0;
   LET CodRet       = "000";
   LET vMinistrado  = 0;
   LET vCtaPagoVenc = 0;
   LET vMToTrasp   = 0;
   LET vBandera     = '';
   let g_MontoAjusteacum2 =0;
   let g_MontoAjusteacum7 =0;
   let g_MontoAjusteacum3 =0;
   --IF (g_ManejaLinea <> '1') THEN
      IF  g_Cubre_Cuota = "1"  then
          let vfechaaux = null;
          select min(fecha_cuota) into vfechaaux
            FROM sd_amortiza_creditocrd
            WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND fecha_cuota > e_fcuota;
          if vfechaaux is null then
            let g_Cubre_Cuota = "0";
          end if
      end if
      FOREACH
         SELECT fecha_cuota, capital_status_ant, --cuota_rec,
                 capital_debe, capital_pagado,
                 capital_debe - capital_pagado, capital_status,
                 (capital_mto_cuota - interes_debe - iva_debe - capital_debe) 
           INTO vFechaCuota, vCuotaRec,
                 vSaldoCuota, vMontorealPag,
                 vAdeudoCuota, vStatusCuota,vMtoTrasp
           FROM sd_amortiza_creditocrd
          WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND fecha_cuota = e_fcuota
            AND capital_status IN ('2', '7','3')

         IF g_Remanente = 0 THEN
            EXIT FOREACH;
         END IF;
 	 IF g_TpPago in("3","2") AND vFechaCuota <> e_fcuota THEN
	      CONTINUE FOREACH;
	 END IF
         LET g_MontoAjuste = 0;
         IF  g_Cubre_Cuota = "1" AND vMtoTrasp < 0 then --si es Asi debe de Saldar la Cuota MEL
             LET g_MontoAjuste =   vMtoTrasp * (-1);
         END IF;
         IF (g_Remanente  >= (vAdeudoCuota - g_MontoAjuste)) THEN
            let vAdeudoCuota = vAdeudoCuota - g_MontoAjuste;
         else
            let vAdeudoCuota = vAdeudoCuota ;
            let g_MontoAjuste = 0;
         end if
         LET vStatus = vStatusCuota;
         IF(g_Remanente > 0) THEN
            IF (g_Remanente  >= vAdeudoCuota) THEN
               LET g_Remanente = g_Remanente - vAdeudoCuota;
               LET vCuotaRec = vStatusCuota;
               LET vStatusCuota = '5';
            ELSE
               LET vAdeudoCuota = g_Remanente;
               LET vCuotaRec = vStatusCuota;
               LET g_Remanente = 0;
            END IF;
            IF(vStatus = '7') THEN
               LET vCobro7 = vCobro7 + vAdeudoCuota+ g_MontoAjuste;
               let g_MontoAjusteacum7 = g_MontoAjusteacum7 + g_MontoAjuste;
            ELIF(vStatus = '2') THEN
               LET vCobro2 = vCobro2 + vAdeudoCuota+ g_MontoAjuste;
               -- Si cobra Vencido se Apaga el Ajuste
               let g_MontoAjusteacum2 = g_MontoAjusteacum2 + g_MontoAjuste;
          --     LET g_Cubre_Cuota = "0";
            ELIF(vStatus = '3') THEN
               let g_MontoAjusteacum3 = g_MontoAjusteacum3 + g_MontoAjuste;
               LET vCobro3 = vCobro3 + vAdeudoCuota+ g_MontoAjuste;
            END IF;
            LET vCapCobrado = vCapCobrado + vAdeudoCuota;

               -- Si hay Ajuste se lo Pasa a la Ultima Cuota
            IF g_MontoAjuste > 0 THEN
                  UPDATE sd_amortiza_creditocrd SET capital_pagado     = capital_pagado + vAdeudoCuota,
                                                    capital_fecha_pago = g_Fecha,
                                                    capital_status     = vStatusCuota,
                                                    capital_status_ant = vCuotaRec,
                                                    mora_bonificado    = mora_bonificado + g_MontoAjuste, -- Aqui Ajusta
                                                    capital_debe       = capital_debe - g_MontoAjuste -- Aqui Ajusta
                  WHERE fecha_cuota = vFechaCuota
                   AND empresa = g_Empresa
                   AND num_credito = g_NumCredito;


                  SELECT max(fecha_cuota) INTO vfechaCuota
                  FROM   sd_amortiza_creditocrd
                  WHERE empresa       = g_Empresa
                   AND   num_credito  = g_NumCredito
                   AND   capital_status  != '5';

                  LET g_MontoAjuste = g_MontoAjuste;
                  LET vfechaCuota = vfechaCuota;
                  UPDATE sd_amortiza_creditocrd SET capital_debe = capital_debe + g_MontoAjuste
                   WHERE fecha_cuota = vfechaCuota
                    AND empresa     = g_Empresa
                    AND num_credito = g_NumCredito;
             ELSE
                  UPDATE sd_amortiza_creditocrd SET capital_pagado = capital_pagado + vAdeudoCuota,
                                                    capital_fecha_pago = g_Fecha,
                                                    capital_status = vStatusCuota,
                                                    capital_status_ant = vCuotaRec
                   WHERE fecha_cuota = vfechaCuota
                    AND empresa      = g_Empresa
                    AND num_credito  = g_NumCredito;
             END IF;
               
      if vAdeudoCuota > 0 and vCuotaRec = "7" then  
         LET vReferencia = 2;
         CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                     '222', g_Fecha, vAdeudoCuota, g_Folio,
                     g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                     CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
            RETURN CodRet;
         ELSE
            LET CodRet = "000";
         END IF;
      END IF;
      if vAdeudoCuota > 0 and vCuotaRec = "2" then   
         LET vReferencia = 9;   --Capital vencido traspasado
         CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                     g_CodigoFun, g_Fecha, vAdeudoCuota, g_Folio,
                     g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                     CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
            RETURN CodRet;
         ELSE
            LET CodRet = "000";
         END IF;
      END IF;
      if vAdeudoCuota > 0 and vCuotaRec = "3" then   
         LET vReferencia = 36;   --Capital vencido traspasado
         CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                     g_CodigoFun, g_Fecha, vAdeudoCuota, g_Folio,
                     g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                     CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
            RETURN CodRet;
         ELSE
            LET CodRet = "000";
         END IF;
     END IF;                        
          ELSE
            EXIT FOREACH;
         END IF;
      END FOREACH;
     LET vCobro7      = vCobro7;
     LET vCobro2      = vCobro2;
     LET vCobro3      = vCobro3;
     let g_MontoAjusteacum7 = g_MontoAjusteacum7 ;
     let g_MontoAjusteacum2 = g_MontoAjusteacum2 ;
     let g_MontoAjusteacum3 = g_MontoAjusteacum3 ;
     LET vCapCobrado  = vCapCobrado;
    IF (vCapCobrado > 0) THEN
           IF (g_ManejaLinea = '1') THEN
                 UPDATE sd_maesdoscrd SET monto_vencido  = monto_vencido - vCobro7 ,
                                          mto_venc_trasp = mto_venc_trasp - vCobro2,
                                          cap_tras_no_venci = cap_tras_no_venci - vCobro3 ,
                                          sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                                          abonos_mes_cap  = abonos_mes_cap + vCapCobrado
                 WHERE empresa = g_Empresa
                  AND num_credito = g_NumCredito;
          ELSE
               IF g_StCred = 'BA' THEN
                   UPDATE sd_maesdoscrd SET monto_vencido     = monto_vencido - vCobro7 ,
                                           sdo_cap_insoluto  = sdo_cap_insoluto - vCapCobrado  - g_MontoAjuste
                   WHERE empresa   = g_Empresa
                    AND num_credito = g_NumCredito;
               ELIF g_StCred = 'BT' THEN
                   UPDATE sd_maesdoscrd SET mto_venc_trasp    = mto_venc_trasp - vCobro2 ,
                                            sdo_cap_insoluto   =  sdo_cap_insoluto - vCapCobrado - g_MontoAjuste
                   WHERE empresa = g_Empresa
                    AND num_credito = g_NumCredito;
               ELIF g_StCred = 'VP' THEN
                  UPDATE sd_maesdoscrd SET cap_tras_no_venci = cap_tras_no_venci - vCobro3,
                                            mto_venc_trasp    = mto_venc_trasp - vCobro2,
                                            sdo_cap_insoluto   =  sdo_cap_insoluto - vCapCobrado -g_MontoAjuste
                   WHERE empresa = g_Empresa
                    AND num_credito = g_NumCredito;
               END IF;
          END IF;
     END IF;
     let g_MontoAjuste = g_MontoAjusteacum7 +g_MontoAjusteacum2+g_MontoAjusteacum3;
     if g_MontoAjuste > 0 then
                  LET g_MontoAjuste = g_MontoAjuste;
             SELECT max(fecha_cuota) INTO vfechaCuota
                  FROM   sd_amortiza_creditocrd
                  WHERE empresa       = g_Empresa
                   AND   num_credito  = g_NumCredito
                   AND   capital_status  != '5';
             SELECT capital_status INTO vstatusajuste
                  FROM   sd_amortiza_creditocrd
                  WHERE empresa       = g_Empresa
                   AND   num_credito  = g_NumCredito
                   AND   fecha_cuota  = vfechacuota;
     
              IF vstatusajuste = '7' THEN
                   UPDATE sd_maesdoscrd SET monto_vencido     = monto_vencido + g_MontoAjuste,
                                           sdo_cap_insoluto = sdo_cap_insoluto + g_MontoAjuste
                   WHERE empresa   = g_Empresa
                    AND num_credito = g_NumCredito;
               ELIF vstatusajuste = '2' THEN
                   UPDATE sd_maesdoscrd SET mto_venc_trasp    = mto_venc_trasp + g_MontoAjuste,
                                           sdo_cap_insoluto = sdo_cap_insoluto + g_MontoAjuste
                   WHERE empresa = g_Empresa
                    AND num_credito = g_NumCredito;
               ELIF vstatusajuste = '3' THEN
                  LET g_MontoAjuste = g_MontoAjuste;
                  UPDATE sd_maesdoscrd SET cap_tras_no_venci = cap_tras_no_venci + g_MontoAjuste,
                                           sdo_cap_insoluto  = sdo_cap_insoluto + g_MontoAjuste
                   WHERE empresa = g_Empresa
                    AND num_credito = g_NumCredito;
               ELIF vstatusajuste = '1' THEN
                  UPDATE sd_maesdoscrd SET sdo_capital = sdo_capital + g_MontoAjuste,
                                           sdo_cap_insoluto = sdo_cap_insoluto + g_MontoAjuste
                   WHERE empresa = g_Empresa
                    AND num_credito = g_NumCredito;     
               END IF;
      END IF;
      IF vBandera = 'S' THEN
       LET vCobro2 = vCapCobrado;
         LET vCobro7 = 0;
      END IF;
      LET g_CapVencCob = g_CapVencCob + vCapCobrado;

   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital vencido, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobracapvigentecrd(e_fcuota DATE)
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
   DEFINE GLOBAL g_StCred        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCte          CHAR(20)      DEFAULT ' ';
   DEFINE GLOBAL g_Cubre_Cuota     CHAR(1)       DEFAULT ' ';
   DEFINE GLOBAL g_MontoAjuste     MONEY(14,2)   DEFAULT 0;


   --DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MontoReservado  MONEY(14,2) DEFAULT 0;

   DEFINE vFechaCuota            LIKE sd_amortiza_creditocrd.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_amortiza_creditocrd.tipo_cuota;
   DEFINE vSaldoCuota            LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vMontoRealPag          LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vAdeudoCuota           LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vStatusCuota           LIKE sd_amortiza_creditocrd.capital_status;
   DEFINE vCobro1                LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE CapCobrado             LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vStatus                LIKE sd_amortiza_creditocrd.capital_status;
   DEFINE vReferencia            SMALLINT;
   DEFINE vPagMinCap             MONEY(14,2);
   DEFINE vMtoMinistraCap        MONEY(14,2);
   DEFINE vCobro0                LIKE sd_amortiza_creditocrd.capital_debe;
   define vfechaaux               date;

   ON EXCEPTION SET sql_err, isam_err, error_info
      --SET DEBUG FILE TO "CobraCapVigente.err";
      --TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;



   LET CodRet = '000';
   LET vCobro1 = 0;
   LET vCobro0 = 0;
   LET vfechaCuota = '';
   IF  g_Cubre_Cuota = "1"  then
          let vfechaaux = null;
          select min(fecha_cuota) into vfechaaux
            FROM sd_amortiza_creditocrd
            WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND fecha_cuota > e_fcuota;
          if vfechaaux is null then
            let g_Cubre_Cuota = "0";
          end if
      end if

   LET vMtoMinistraCap = 0;
      SELECT fecha_cuota, capital_status_ant,
              capital_debe, capital_pagado,
              (capital_debe - capital_pagado), capital_status,
              (capital_mto_cuota - interes_debe - iva_debe - capital_debe) 
        INTO vFechaCuota, vCuotaRec,
              vSaldoCuota, vMontoRealPag,
              vAdeudoCuota, vStatusCuota,vMtoMinistraCap
        FROM sd_amortiza_creditocrd
       WHERE empresa = g_Empresa
         AND num_credito = g_NumCredito
         AND fecha_cuota = e_fcuota;

      let vCuotaRec = vStatusCuota;
      LET g_Cubre_Cuota = g_Cubre_Cuota;
      LET g_MontoAjuste = 0;
      IF  g_Cubre_Cuota = "1" AND vMtoMinistraCap < 0 THEN -- Si es Asi debe de Saldar la Cuota MEL
          LET g_MontoAjuste = vMtoMinistraCap * (-1);
       --  LET g_Cubre_Cuota = 0;
      END IF;
      let vAdeudoCuota = vAdeudoCuota - g_MontoAjuste;
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

      IF g_MontoAjuste > 0 THEN
         UPDATE sd_amortiza_creditocrd SET capital_debe       = capital_debe - g_MontoAjuste,
                                           capital_pagado     = capital_pagado + vAdeudoCuota,
                                           capital_fecha_pago = g_fecha,
                                           capital_status     = vStatusCuota,
                                           capital_status_ant = vCuotaRec,
                                           mora_bonificado    = mora_bonificado + g_MontoAjuste -- Aqui Ajusta
         WHERE empresa     = g_empresa
           AND num_credito = g_NumCredito
           AND empresa     = g_Empresa
           AND fecha_cuota = e_fcuota;
         SELECT max(fecha_cuota) INTO vfechaCuota
           FROM   sd_amortiza_creditocrd
           WHERE empresa = g_Empresa
           AND   num_credito = g_NumCredito
           AND   capital_status  != '5';
         LET g_MontoAjuste = g_MontoAjuste;
         LET vfechaCuota = vfechaCuota;
         UPDATE sd_amortiza_creditocrd SET capital_debe = capital_debe + g_MontoAjuste
         WHERE fecha_cuota = vfechaCuota
           AND num_credito = g_NumCredito
           AND empresa     = g_Empresa;           
      ELSE
         UPDATE sd_amortiza_creditocrd SET capital_pagado     = capital_pagado + vAdeudoCuota,
                                           capital_fecha_pago = g_fecha,
                                           capital_status     = vStatusCuota,
                                           capital_status_ant = vCuotaRec
         WHERE empresa     = g_empresa
           AND num_credito = g_NumCredito
           AND empresa     = g_Empresa
           AND fecha_cuota = e_fcuota;
      END IF;
      UPDATE sd_maesdoscrd SET sdo_capital        = sdo_capital - vAdeudoCuota ,
                                  sdo_cap_insoluto   = sdo_cap_insoluto - vAdeudoCuota,
                                  abonos_mes_cap     = abonos_mes_cap + vAdeudoCuota
         WHERE empresa = g_Empresa
           AND num_credito = g_NumCredito;
    
   IF (vAdeudoCuota > 0) THEN
      IF g_StCred = 'VP' THEN
          LET vReferencia = 16;   --Capital Vigente En Pago Sostenido
          CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                      g_CodigoFun, g_Fecha, vAdeudoCuota, g_Folio,
                      g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                     CodRet, Mensaje;
      ELSE
          LET vReferencia = 11;   --Capital Vigente
          CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                      '222', g_Fecha, vAdeudoCuota, g_Folio,
                      g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                      CodRet, Mensaje;
      END IF;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;

      END IF
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;


   LET g_CapVigCob = g_CapVigCob + vCobro1;

   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital vigente, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobracomisionescrd(e_tpcom  CHAR(2),
				 e_fcuota DATE)
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
   DEFINE GLOBAL g_Impuesto     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Seguro       MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Comision     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha        DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa       CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_TpPago       SMALLINT    DEFAULT 0;
   --DEFINE GLOBAL g_MontoFinanciado       MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_StCred        CHAR(2) DEFAULT ' ';

   DEFINE GLOBAL g_CodigoFun    CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio        CHAR(16)    DEFAULT ' ';

   DEFINE wCodigoRef            SMALLINT;
   DEFINE wCodComis             CHAR(4);
   DEFINE wNumCredito           CHAR(20);
   DEFINE wMontoCom             MONEY(14,2);
   DEFINE wFechaPago            DATE;
   DEFINE wmCom                 MONEY(14,2);
   DEFINE wmPag                 MONEY(14,2);
   DEFINE wEstadoCom            CHAR(1);
   DEFINE wTpCom		CHAR(1);

   ON EXCEPTION SET sql_err, isam_err, error_info
      --SET DEBUG FILE TO "/pisa/sofagro/pisa_ftes/jl/credito/CobraComisiones.err";
     --TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;



   LET CodRet = "000";
      --SET DEBUG FILE TO "/pisa/sofagro/pisa_ftes/jl/credito/CobraComisiones.err";
     -- trace on;
      Let g_Remanente = g_Remanente;

   FOREACH
      SELECT a.cod_comis, c.num_credito, c.monto_com, c.monto_pag,
             c.monto_com - c.monto_pag, c.fecha_alta, c.estado_com ,
	     a.comi_o_seg
        INTO wCodComis, wNumCredito, wmCom, wmPag, wMontoCom, wFechaPago,
             wEstadoCom, wTpCom
        FROM sd_tpcomis a, sd_detcomi c
       WHERE a.empresa     = g_empresa
    --     AND a.comi_o_seg   = e_tpcom
         AND c.empresa     = a.empresa
         AND c.cod_comis   = a.cod_comis
         AND c.num_credito = g_NumCredito
         AND c.estado_com  = 'A'
    --   ORDER BY 1


      IF e_tpcom = "2" AND g_TpPago = "2" THEN
	   IF e_fcuota <> wFechaPago THEN
		CONTINUE FOREACH;
      Let g_Remanente = g_Remanente;
	   END IF;
      END IF;


      IF (g_Remanente > 0) THEN
         IF (g_Remanente >= wMontoCom) THEN
            LET g_Remanente = g_Remanente - wMontoCom;
         ELSE
            LET wMontoCom = g_Remanente;
            LET g_Remanente = 0;
         END IF;
         IF (e_tpcom = "2") THEN
            LET wCodigoRef = wCodComis;
            CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,wCodigoref,
                        g_CodigoFun, g_Fecha, wMontoCom, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                           CodRet, Mensaje;
            IF(CodRet <> "00000") THEN
               RETURN CodRet;
            ELSE
               LET g_Seguro = g_Seguro + wMontoCom;
	      -- UPDATE sd_escrow SET saldo = saldo + wMontoCom
--		WHERE empresa = g_Empresa
	--	  AND num_credito = g_NumCredito
		--  AND cod_comis = wCodComis;
               LET Codret = "000";
            END IF;
         ELSE
            LET wCodigoRef = wCodComis;
            CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto, wCodigoref,
              	        g_CodigoFun, g_Fecha, wMontoCom, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc,'','')
	    RETURNING CodRet, Mensaje;
            IF(CodRet <> "00000") THEN
               RETURN CodRet;
            ELSE
               LET CodRet = "000";
	       IF wTpCom = "1" THEN
                 LET g_Comision = g_Comision + wMontoCom;
	       ELIF wTpCom = "4" THEN
		 LET g_Impuesto = g_Impuesto + wMontoCom;
	       END IF
	    END IF
         END IF;

         IF (wmCom = wmPag + wMontoCom) THEN
            LET wEstadoCom = 'P';
         END IF;

         UPDATE sd_detcomi
            SET monto_pag = monto_pag + wMontoCom,
                fecha_pago = g_Fecha,
                estado_com = wEstadoCom
          WHERE empresa = g_empresa
            AND cod_comis = wCodComis
            AND num_credito = wNumCredito
            AND fecha_alta = wFechaPago;


	  --LET g_MontoFinanciado = g_MontoFinanciado - wMontoCom;
          let wMontoCom = wMontoCom;
          IF g_StCred = "AA" THEN
              UPDATE sd_maesdoscrd
                 SET sdo_cap_insoluto = sdo_cap_insoluto - wMontoCom,
                     sdo_capital = sdo_capital - wMontoCom --,
		     --monto_financiado = monto_financiado - wMontoCom
               WHERE num_credito = wNumCredito
                 AND empresa = g_empresa;
       	  ELIF g_StCred = "BA" THEN
              UPDATE sd_maesdoscrd
       	         SET sdo_cap_insoluto = sdo_cap_insoluto - wMontoCom,
               	     monto_vencido = monto_vencido - wMontoCom --,
		     --monto_financiado = monto_financiado - wMontoCom
               WHERE num_credito = wNumCredito
       	         AND empresa = g_empresa;
          ELSE
       	      UPDATE sd_maesdoscrd
                 SET sdo_cap_insoluto = sdo_cap_insoluto - wMontoCom,
       	             mto_venc_trasp = mto_venc_trasp - wMontoCom --,
		     --monto_financiado = monto_financiado - wMontoCom
               WHERE num_credito = wNumCredito
       	         AND empresa = g_empresa;
          END IF

      END IF;


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

CREATE PROCEDURE "informix".cobraintvencidocrd(e_fcuota DATE)

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
    DEFINE GLOBAL g_StCred       CHAR(2)       DEFAULT ' ';

   DEFINE vFechaCuota            LIKE sd_amortiza_creditocrd.fecha_cuota;
   DEFINE vIntVenc               LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vCuotaRec              LIKE sd_amortiza_creditocrd.tipo_cuota;
   DEFINE vMontoCuota            LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vMontoRealPag          LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vMontoFinanc           LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vStatusCuota           LIKE sd_amortiza_creditocrd.tipo_cuota;
   DEFINE vIntCob                LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vIntFinan              LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vIntCob7               LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vIntCob2               LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vIntCob3               LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vIntCtaOrd             LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vIvaIntCtaOrd          LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vStatus                LIKE sd_amortiza_creditocrd.tipo_cuota;
   DEFINE vIntProv               LIKE sd_amortiza_creditocrd.capital_mto_cuota;
   DEFINE vIntProvOrd            LIKE sd_amortiza_creditocrd.capital_mto_cuota;

   DEFINE iva_status            CHAR(2);
   DEFINE iva_status_ant        CHAR(2);
   DEFINE vIvaSuc               char(5);
   DEFINE vIvaPag               MONEY(14,2);
   DEFINE vIvaTotPag            MONEY(14,2);
   DEFINE vIvaTotPag2           MONEY(14,2);
   DEFINE vIvaTotPag3           MONEY(14,2);



   ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "CobraIntVencido.err";
        TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;



   LET vIntCob        = 0;
   LET vIntFinan      = 0;
   LET vIntCob7       = 0;
   LET vIntCob2       = 0;
   LET CodRet         = '000';
   LET vIntVenc       = 0;
   LET vIvaSuc        = '';
   LET vIvaPag        = 0;
   LET iva_status     = '';
   LET iva_status_ant = '';
   LET vIntProv       = 0;
   LET vIntProvOrd    = 0;
   LET vIvaTotPag     = 0;
   LET vIvaTotPag2    = 0;
   LET vIntCtaOrd     = 0;
   LET vIvaIntCtaOrd  = 0;
   LET vIntCob3       = 0 ;
   LET vIvaTotPag3    = 0 ;




  IF g_fecha <= '12/31/2009' THEN

      SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
      WHERE  cod_param = "92"
       AND    empresa = g_Empresa;
  ELSE
      SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
      WHERE  cod_param = "12"
       AND    empresa = g_Empresa;
  END IF;




   --IF (g_ManejaLinea <> '1') THEN
   FOREACH
         SELECT fecha_cuota, interes_status_ant, --cuota_rec
                 interes_debe, interes_pagado,
                 (interes_debe - interes_pagado), --monto_financiado,
                 interes_status
           INTO vFechaCuota, vCuotaRec,
                 vMontoCuota, vMontoRealPag, vIntVenc,
                 vStatusCuota
           FROM sd_amortiza_creditocrd
          WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND interes_status in ('2', '7','3')
            AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
            AND fecha_cuota = e_fcuota
          ORDER BY fecha_cuota

          LET vIvaPag   = vIntVenc * vIvaSuc;
          IF g_Remanente > vIntVenc + vIvaPag THEN
                  LET vIvaPag   = vIvaPag ;
          ELSE
                  LET vIntVenc    = g_Remanente  / (1 + vIvaSuc);
                  LET vIvaPag     = vIntVenc  * vIvaSuc;
                  LET g_Remanente = vIntVenc + vIvaPag ;
                  LET vIntProv    = vIntVenc;
          END IF;


        IF g_TpPago in( "2","3") THEN
            CONTINUE FOREACH;
	END IF

        LET vStatus = vStatusCuota;

       IF (g_Remanente > 0) THEN
              IF (g_Remanente >= vIntVenc +  vIvaPag) THEN
                   LET g_Remanente = g_Remanente - vIntVenc - vIvaPag;
                   IF (vStatusCuota = '7') THEN
                        LET vIntCob7   = vIntCob7 + vIntVenc ;
                        LET vIvaTotPag = vIvaTotPag + vIvaPag;
                   ELIF (vStatusCuota = '2') THEN
                        LET vIntCob2    = vIntCob2 + vIntVenc ;
                        LET vIvaTotPag2 = vIvaTotPag2 + vIvaPag;
                   ELIF (vStatusCuota = '3') THEN
                        LET vIntCob3    = vIntCob3 + vIntVenc  ;
                        LET vIvaTotPag3 = vIvaTotPag3 + vIvaPag;
                   END IF;
                   IF (vMontoCuota-vMontoRealPag) = vIntVenc  AND vIntVenc > 0THEN
                      LET vCuotaRec = vStatusCuota;
                      LET vStatusCuota = '5';
                      LET vFechaCuota = vFechaCuota;
                      LET iva_status     = '5';
                      LET iva_status_ant = '1';
                   ELSE
                       LET iva_status     = '1';
                   END IF;
              ELSE
                   LET g_Remanente = g_Remanente - vIntVenc - vIvaPag;
                   LET iva_status     = '1';
                   LET iva_status_ant = '0';
                   LET vIntVenc = g_Remanente;
                   LET g_Remanente = 0;
                   IF (vStatusCuota = '7') THEN
                       LET vIntCob7 = vIntCob7 + vIntVenc ;
                   ELIF (vStatusCuota = '2') THEN
                       LET vIntCob2 = vIntCob2 + vIntVenc ;
                   ELIF (vStatusCuota = '3') THEN
                       LET vIntCob3 = vIntCob3 + vIntVenc ;
                   END IF;
              END IF;


            -- Cobra Interes No Vencido
            IF vIntCob3 > 0 then
               UPDATE sd_maesdoscrd set provision_normal = provision_normal - (vIntCob3 + vIntCob7)
               WHERE   empresa = g_empresa AND num_credito = g_NumCredito;
               -- Le pone Cero si es Negativa por la Provision del Fin de Mes MEL
               UPDATE sd_maesdoscrd set provision_normal = 0
               WHERE   empresa = g_empresa AND num_credito = g_NumCredito
               AND      provision_normal < 0;
            END IF;

            UPDATE
                sd_amortiza_creditocrd
            SET
               interes_status_ant = vCuotaRec,
               interes_pagado     = interes_pagado + vIntVenc,
               interes_status     = vStatusCuota,
               interes_fecha_pago = g_fecha,
               iva_debe           = iva_debe + vIvaPag,
               iva_pagado         = iva_pagado + vIvaPag,
               iva_status         = iva_status,
               iva_status_ant     = iva_status_ant,
               iva_fecha_pago     = e_fcuota

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

   LET vIntCob7 = vIntCob7;
   LET vIntCob2 = vIntCob2;
   LET vIntCtaOrd = vIntCtaOrd;
   LET vIntCob3 = vIntCob3;

   IF g_StCred = 'VP' THEN
      UPDATE
         sd_maesdoscrd
      SET
        sdo_exig_int = sdo_exig_int - vIntCob7  ,
        int_tra_no_exig = int_tra_no_exig - vIntCob3,
        mto_venc_tra_int = mto_venc_tra_int - vIntCob2
      WHERE empresa = g_Empresa
      AND num_credito = g_NumCredito;
  ELSE
     IF g_StCred <> 'BT' THEN
        UPDATE
           sd_maesdoscrd
        SET
          sdo_exig_int = sdo_exig_int - vIntCob7 ,
          -- mto_venc_int = mto_venc_int - vIntCob7,
          mto_venc_tra_int = mto_venc_tra_int - vIntCob2,
          int_tra_no_exig  = int_tra_no_exig - vIntCob3
       WHERE empresa = g_Empresa
       AND num_credito = g_NumCredito;
     ELSE
        UPDATE
          sd_maesdoscrd
        SET
           mto_venc_int = mto_venc_int - vIntCob7,
           mto_venc_tra_int = mto_venc_tra_int - vIntCob2
        WHERE empresa = g_Empresa
        AND num_credito = g_NumCredito;
     END IF;
  END IF;

   --LET g_MontoFinanciado = g_MontoFinanciado - (vIntCob2 + vIntCob7);

   IF (vIntCob7 > 0) THEN
      LET vReferencia = 31;   --Interes vencido no traspasado
      CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  '222', g_Fecha, vIntCob7, g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;


  END IF;

   IF (vIntCob2 > 0) THEN
      LET vReferencia = 30;  -- Interes Vencido Traspasado
      CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  g_CodigoFun, g_Fecha, vIntCob2, g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;


   END IF;

   IF (vIntCob3 > 0) THEN
      LET vReferencia = 30; -- Interes Vencido Ctas. Orden
      CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  g_CodigoFun, g_Fecha, vIntCob3, g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;


   END IF;

 IF (vIntCob7 > 0) THEN
      LET vReferencia = 54;   --Iva vencido no traspasado
      CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  '222', g_Fecha, vIvaTotPag , g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;
   END IF;

   IF (vIntCob2 > 0) THEN
      LET vReferencia = 45;   -- Iva Vencido Traspasado
      CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  --g_CodigoFun, g_Fecha, vIvaPag, g_Folio,
                  g_CodigoFun, g_Fecha, vIvaTotPag2, g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;
   END IF;
   IF (vIntCob3 > 0) THEN
      LET vReferencia = 45;   -- Iva Vencido Traspasado Ctas. Orden
      CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  g_CodigoFun, g_Fecha, vIvaTotPag3, g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;
   END IF;

   LET g_IntVencCob = g_IntVencCob + (vIntCob7 + vIntCob2 + vIntCob3 + vIvaPag);
   RETURN CodRet;


END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de intereses vencidos, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobraintvigentecrd(e_fcuota DATE)

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
   --DEFINE GLOBAL g_MontoFinanciado     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL g_SdoIntAnticip MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntAntDev  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntTraNoExig  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoTrab4      MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntereses  MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_IntVig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoAcumMesInt MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ProvisionNorm MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntVigCob     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL gTipoCalculo   CHAR(2)     DEFAULT "";
   DEFINE GLOBAL g_StCred          CHAR(2)  DEFAULT ' ';


   DEFINE vFechaCuota            LIKE sd_amortiza_creditocrd.fecha_cuota;
   DEFINE vIntVig                LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vIntProv               LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vCuotaRec              LIKE sd_amortiza_creditocrd.tipo_cuota;
   DEFINE vMontoCuota            LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vMontoRealPag          LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vMtoIntSdo             LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vMontoFinanciado       LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vStatusCuota           LIKE sd_amortiza_creditocrd.tipo_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vCodigoFun             CHAR(3);
   DEFINE vSdoACumMesInt         MONEY(14,2);
   DEFINE vProvisionNorm         MONEY(14,2);
   DEFINE vProvision             MONEY(14,2);
   DEFINE vPagMinInt             MONEY(14,2);
   DEFINE vAbonos                MONEY(14,2);
   DEFINE vIvaSuc                char(5);
   DEFINE vIvaPag                MONEY(14,2);
   DEFINE iva_status            CHAR(2);
   DEFINE iva_status_ant        CHAR(2);
   DEFINE vIntDevengado         DECIMAL(14,2);


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIntVigente.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

   LET CodRet         = "000";
   LET vCodigoFun     = "034";   --Utilizada para realizar la provision
   LET vSdoAcumMesInt = 0;
   LET vAbonos        = 0;
   LET vProvisionNorm = 0;
   LET vPagMinInt     = 0; --g_IntTraNoExig + g_SdoTrab4;
   LET vIvaSuc    = '';
   LET vIvaPag        = 0;
   LET iva_status     = '';
   LET iva_status_ant = '';
   LET vIntProv       = 0;
   LET vMtoIntSdo     = 0;
   LET vIntDevengado  = 0;


  
  IF g_Fecha <='12/31/2009' THEN

      SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
      WHERE  cod_param = "92"
       AND    empresa = g_Empresa;
  ELSE
      SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
      WHERE  cod_param = "12"
       AND    empresa = g_Empresa;
  END IF;


      SELECT nvl(provision_normal,0) INTO vIntDevengado fROM sd_maesdoscrd
       where num_credito = g_NumCredito;

      SELECT
         fecha_cuota, interes_status_ant,
         interes_debe, interes_pagado, (interes_debe -  interes_pagado),
         interes_status
       INTO
          vFechaCuota, vCuotaRec,
          vMontoCuota, vMontorealPag, vIntVig,
          vStatusCuota
      FROM
         sd_amortiza_creditocrd
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
	fecha_cuota = e_fcuota;


     --** Calcula Iva De Interes **--

     LET vIvaPag   = vIntVig * vIvaSuc;
     IF g_Remanente > vIntVig + vIvaPag THEN
         LET vIvaPag   = vIvaPag ;
      ELSE
         LET vIntVig   = g_Remanente  / (1 + vIvaSuc);
         LET vIvaPag   = vIntVig  * vIvaSuc;
         LET g_Remanente = vIntVig + vIvaPag ;
         LET vIntProv    = vIntVig;
         LEt g_Remanente = g_Remanente - vIntVig - vIvaPag;
     END IF;

      IF (vStatusCuota NOT IN ('1','3')) THEN
         RETURN CodRet;
      END IF;

      IF (g_Remanente >= vIntVig + vIvaPag) THEN
         LET g_Remanente = g_Remanente - vIntVig - vIvaPag;
         IF (vMontoCuota-vMontorealPag) = vIntVig  AND vIntVig  > 0 THEN
            LET vCuotaRec = vStatusCuota;
            LET vStatusCuota   = '5';
            LET iva_status     = '5';
            LET iva_status_ant = '1';
         ELSE
            LET iva_status     = '1';
         END IF;
      ELSE
         LET iva_status     = '1';
         LET iva_status_ant = '0';
         IF (vMontoCuota-vMontorealPag) = vIntVig THEN
            LET vStatusCuota   = '5';
            LET iva_status     = '5';
            LET iva_status_ant = '1';
         END IF;
         LET g_Remanente = 0;
      END IF;

      IF (vIntVig > 0) THEN
         IF g_StCred  <> 'VP' THEN
               LET vReferencia = 28;   --Pago de Intereses
               CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                           '222', g_Fecha, vIntVig, g_Folio,
                           g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                           CodRet, Mensaje;
               IF (CodRet <> "00000") THEN
                    RETURN CodRet;
               ELSE
                   LET CodRet = "000";
               END IF;

               LET vReferencia = 47;   --Pago De Iva Interes Vigente
               CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                           '222', g_Fecha, vIvaPag, g_Folio,
                           g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                          CodRet, Mensaje;
               IF (CodRet <> "00000") THEN
                   RETURN CodRet;
               ELSE
                  LET CodRet = "000";
               END IF;

               IF vIntDevengado > 0 THEN
                   LET vReferencia = 3;   --Provision de Intereses Vigentes 
                   CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                               "606", g_Fecha, vIntDevengado, g_Folio,
                               g_Sucursal, g_Divisa, g_Transacc,'','')
	           RETURNING CodRet, Mensaje;
                   IF (CodRet <> "00000") THEN
                     RETURN CodRet;
                   ELSE
                     LET CodRet = "000";
                  END IF;

                  LET vReferencia = 24;   --Iva De Provision De Interes Vigente
                  CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                             '222', g_Fecha, vIntDevengado, g_Folio,
                             g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                            CodRet, Mensaje;
                  IF (CodRet <> "00000") THEN
                     RETURN CodRet;
                  ELSE
                    LET CodRet = "000";
                  END IF;
              END IF;
        ELSE
              LET vReferencia = 17;   --Pago de Intereses En Pago Sostenido
              CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                          g_CodigoFun, g_Fecha, vIntVig, g_Folio,
                          g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                          CodRet, Mensaje;
              IF (CodRet <> "00000") THEN
                 RETURN CodRet;
              ELSE
                LET CodRet = "000";
             END IF;

             LET vReferencia = 27;   --Pago De Iva Interes Vigente En Pago Sostenido
             CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                        '340', g_Fecha, vIvaPag, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                        CodRet, Mensaje;
             IF (CodRet <> "00000") THEN
                 RETURN CodRet;
             ELSE
                LET CodRet = "000";
             END IF;

       END IF;
    END IF;

      LET g_Empresa = g_Empresa;
      LET g_NumCredito = g_NumCredito;
      LET e_fcuota = e_fcuota;

      UPDATE sd_amortiza_creditocrd
         SET interes_pagado = interes_pagado + vIntVig,
             interes_fecha_pago = g_fecha,
             interes_status   = vStatusCuota,
             interes_status_ant = vCuotaRec,
             iva_debe           = iva_debe + vIvaPag,
             iva_pagado         = iva_pagado + vIvaPag,
             iva_status         = iva_status,
             iva_status_ant     = iva_status_ant,
             iva_fecha_pago     = g_fecha
      WHERE empresa = g_Empresa
      AND num_credito = g_NumCredito
      AND fecha_cuota = e_fcuota;

    If (vStatusCuota = '5' and vCuotaRec in ('1','5')) or vStatusCuota = '1' then
       SELECT sdo_no_exig INTO vMtoIntSdo FROM sd_maesdoscrd
        WHERE empresa     = g_Empresa
          AND num_credito = g_NumCredito;
        --IF vMtoIntSdo < vIntVig THEN
        LET vIntVig = vIntVig;
        IF  vIntVig > vMtoIntSdo THEN
          UPDATE sd_maesdoscrd
           SET sdo_no_exig      = 0,
               provision_normal = 0
           WHERE empresa = g_Empresa
           AND num_credito = g_NumCredito;
        ELSE
        UPDATE sd_maesdoscrd
        SET sdo_no_exig      = sdo_no_exig - vIntVig,
               provision_normal = 0
        WHERE empresa = g_Empresa
          AND num_credito = g_NumCredito;
        END IF;
    Elif (vStatusCuota = '5' and vCuotaRec = '3') or vStatusCuota = '3' then
        UPDATE sd_maesdoscrd
        SET int_tra_no_exig      = int_tra_no_exig - vIntVig
        WHERE empresa = g_Empresa
          AND num_credito = g_NumCredito;
    End if;


    LET g_IntVigCob = g_IntVigCob + vIntVig;
    RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital vencido, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobramoratorioscrd(e_fcuota DATE)
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
   DEFINE vProviMoraOrdi        LIKE sd_amortiza_creditocrd.mora_provi_ordi;
   DEFINE vProviMoraCope        LIKE sd_amortiza_creditocrd.mora_provi_cope;
   DEFINE vSdoMoraOrdi          LIKE sd_amortiza_creditocrd.mora_sdo_ordi;
   DEFINE vSdoMoraCope          LIKE sd_amortiza_creditocrd.mora_sdo_cope;
   DEFINE vMontoMora            LIKE sd_amortiza_creditocrd.mora_sdo_cope;
   DEFINE vCodigoRef            SMALLINT;
   DEFINE vIntVenc               LIKE sd_amortiza_creditocrd.capital_debe;

       DEFINE vIntProv               LIKE sd_amortiza_creditocrd.capital_debe;

    DEFINE vIvaSuc                char(5);
   DEFINE vIvaPag                MONEY(14,2);



   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraMoratorios.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

--  SET DEBUG FILE TO "/tmp/cobramoratorios.out";
--  TRACE ON;



   SELECT valor
   INTO vPerContMora
   FROM sd_param
   WHERE empresa = g_Empresa
   AND cod_param = '17';

   LET CodRet      = "000";
   LET vCodigoRef  = 2;
   LET vMontoMora  = 0;
   LET g_Moratorio = 0;
   LET g_Remanente = g_Remanente;
   LET vIvaPag  = 0;


    SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
    WHERE cod_param = "12"
     AND empresa = g_Empresa;




      FOREACH
         SELECT fecha_cuota, (mora_provi_ordi + mora_sdo_ordi) - mora_sdo_ordi_pag,
			     (mora_provi_cope + mora_sdo_cope) - mora_sdo_cope_pag
           INTO vFechaCuota, vSdoMoraOrdi, vSdoMoraCope
           FROM sd_amortiza_creditocrd
          WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND (( mora_sdo_ordi - mora_sdo_ordi_pag) +
		( mora_sdo_cope - mora_sdo_cope_pag) > 0
             OR (mora_provi_ordi + mora_provi_cope) > 0)
	 ORDER BY 1

         LET vIvaPag   = (vSdoMoraOrdi + vSdoMoraCope)  * vIvaSuc;
         IF g_Remanente > (vSdoMoraCope + vSdoMoraOrdi + vIvaPag) THEN
           LET vIvaPag   = vIvaPag ;
        ELSE
           LET vIntVenc    = (vSdoMoraOrdi + vSdoMoraCope);
           LET vIntVenc    = g_Remanente  / (1 + vIvaSuc);
           LET vIvaPag     = g_Remanente - vIntVenc;
           LET vIntProv    = vIntVenc;
       END IF;
         LET g_Remanente = g_Remanente -  vIvaPag;

	 IF g_TpPago = "2" AND vFechaCuota <> e_fcuota THEN
		CONTINUE FOREACH;
	 END IF

         IF(g_Remanente > 0) THEN
            IF(g_Remanente >= vSdoMoraCope) THEN
               LET g_Remanente   = g_Remanente - vSdoMoraCope;
               LET vMontoMora    = vMontoMora + vSdoMoraCope;
            ELSE
               LET vSdoMoraCope  = g_Remanente;
               LET vMontoMora    = vMontoMora + g_Remanente;
               LET g_Remanente   = 0;
            END IF;
            IF(g_Remanente >= vSdoMoraOrdi) THEN
               LET g_Remanente   = g_Remanente - vSdoMoraOrdi;
               LET vMontoMora    = vMontoMora + vSdoMoraOrdi;
            ELSE
               LET vSdoMoraOrdi  = g_Remanente;
               LET vMontoMora    = vMontoMora + g_Remanente;
               LET g_Remanente   = 0;
            END IF;


            UPDATE sd_amortiza_creditocrd
               SET mora_sdo_ordi_pag = mora_sdo_ordi_pag + vSdoMoraOrdi,
                   mora_sdo_cope_pag = mora_sdo_cope_pag + vSdoMoraCope,
                   mora_iva_debe     = mora_iva_debe + vIvaPag,
                   mora_iva_pagado   = mora_iva_pagado + vIvaPag,
                   mora_iva_fecha_pago = e_fcuota,
                   mora_iva_status     = 5
             WHERE empresa = g_Empresa
               AND num_credito = g_NumCredito
               AND fecha_cuota = vFechaCuota;
            LET g_Moratorio = g_Moratorio + vMontoMora;
            LET vSdoMoraOrdi = 0;
            LET vSdoMoraCope = 0;
	   -- Genera Movimiento de Recuperacion de Mora
           IF vMontoMora > 0 THEN
	   CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,
        	       g_CodigoFun, g_Fecha, vMontoMora, g_Folio,
	               g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
        	       CodRet, Mensaje;

	   -- Genera Movmiento de Provision Mora
	   CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,1,
        	       "607", g_Fecha, vMontoMora, g_Folio,
               		g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
	               CodRet, Mensaje;
            LET vMontoMora  = 0;
	   -- Genera Movmiento de Iva
	   CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,25,
        	       "340", g_Fecha, vIvaPag, g_Folio,
               		g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
	               CodRet, Mensaje;
            LET vMontoMora  = 0;
          END IF;


         END IF
      END FOREACH;

   -- Actualiza sd_maesdos
   LET g_Moratorio = g_Moratorio;
   let g_SdoMoratorio = g_SdoMoratorio - g_Moratorio;
   UPDATE sd_maesdoscrd
      SET sdo_moratorio = sdo_moratorio - g_Moratorio
    WHERE empresa = g_Empresa
      AND num_credito = g_NumCredito;

   LET g_IntMoraCob = g_IntMoraCob + g_Moratorio + vIvaPag;
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

CREATE PROCEDURE "informix".cobraintviganticipcrd(e_fcuota    DATE,

                                               eEmpresa    CHAR(3),
                                               eNumCredito CHAR(20),
                                               ePago       DECIMAL(14,2))
   RETURNING CHAR(5),
             MONEY(14,2);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_SdoRetenido     MONEY(14,2)   DEFAULT 0;


   DEFINE vFechaCuota            LIKE sd_amortiza_creditocrd.fecha_cuota;
   DEFINE vIntVig                LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vIntProv               LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vCuotaRec              LIKE sd_amortiza_creditocrd.tipo_cuota;
   DEFINE vMontoCuota            LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vMontoRealPag          LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vMtoIntSdo             LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vMontoFinanciado       LIKE sd_amortiza_creditocrd.capital_debe;
   DEFINE vStatusCuota           LIKE sd_amortiza_creditocrd.tipo_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vCodigoFun             CHAR(3);
   DEFINE vSdoACumMesInt         MONEY(14,2);
   DEFINE vProvisionNorm         MONEY(14,2);
   DEFINE vProvision             MONEY(14,2);
   DEFINE vPagMinInt             MONEY(14,2);
   DEFINE vAbonos                MONEY(14,2);
   DEFINE vIvaSuc                char(5);
   DEFINE vIvaPag                MONEY(14,2);
   DEFINE iva_status            CHAR(2);
   DEFINE iva_status_ant        CHAR(2);
   DEFINE vIntDevengado         DECIMAL(14,2);
   DEFINE vStatusCred            CHAR(2);
   DEFINE vNumProducto           CHAR(4);
   DEFINE vSucursal              CHAR(4);
   DEFINE vDivisa                CHAR(2);
   DEFINE vRemanente             MONEY(14,2);
   DEFINE vFecha                 DATE;
   DEFINE vTipoCalculo           CHAR(2);




   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIntVigente.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet,vRemanente;
   END EXCEPTION;

   LET CodRet         = "000";
   --LET vCodigoFun     = "034";   --Utilizada para realizar la provision
   LET vCodigoFun      = '033';
   LET vSdoAcumMesInt = 0;
   LET vAbonos        = 0;
   LET vProvisionNorm = 0;
   LET vPagMinInt     = 0; --g_IntTraNoExig + g_SdoTrab4;
   LET vIvaSuc    = '';
   LET vIvaPag        = 0;
   LET iva_status     = '';
   LET iva_status_ant = '';
   LET vIntProv       = 0;
   LET vMtoIntSdo     = 0;
   LET vIntDevengado  = 0;
   LET vRemanente     = ePago;


 
  IF e_fcuota <='12/17/2009' THEN

      SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
      WHERE  cod_param = "92"
       AND    empresa = g_Empresa;
  ELSE
      SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
      WHERE  cod_param = "12"
       AND    empresa = g_Empresa;
  END IF;


      SELECT provision_normal INTO vIntDevengado fROM sd_maesdoscrd where num_credito = eNumCredito;
      SELECT fecha_hoy  INTO vFecha FROM sd_fechas WHERE empresa = eEmpresa;
      SELECT status_cred,num_producto,sucursal,divisa,tipo_calculo   INTO vStatusCred,vNumProducto,vSucursal,vDivisa,vTipoCalculo
      FROM sd_maecredcrd WHERE empresa = eEmpresa and num_credito = eNumCredito;


      SELECT
         fecha_cuota, interes_status_ant,
         interes_debe, interes_pagado, (interes_debe -  interes_pagado),
         interes_status
       INTO
          vFechaCuota, vCuotaRec,
          vMontoCuota, vMontorealPag, vIntVig,
          vStatusCuota
      FROM
         sd_amortiza_creditocrd
      WHERE
         empresa = eEmpresa
      AND
         num_credito = eNumCredito
      AND
	fecha_cuota = e_fcuota;


     --** Calcula Iva De Interes **--

  --   IF g_StCred  <> 'VP' THEN
  --      Select sdo_no_exig  into vIntProv from sd_maesdoscrd  where empresa = eEmpresa and num_credito = eNumCredito;
  --   ELSE
  --      LET vIntProv = vMontoCuota;
 --    END IF;
{
     if vIntVig > vIntProv then
        let vIntVig = vIntProv;
     end if
}
     LET vIvaPag   = vIntVig * vIvaSuc;
     IF vRemanente > vIntVig + vIvaPag THEN
         LET vIvaPag   = vIvaPag ;
      ELSE
         LET vIntVig   = vRemanente  / (1 + vIvaSuc);
         LET vIvaPag   = vIntVig  * vIvaSuc;
         LET vRemanente = vIntVig + vIvaPag ;
         LET vIntProv    = vIntVig;
         LEt vRemanente = vRemanente - vIntVig - vIvaPag;
     END IF;

      IF (vStatusCuota NOT IN ('1','3')) THEN
         RETURN CodRet,vRemanente;
      END IF;

      IF (vRemanente >= vIntVig + vIvaPag) THEN
         LET vRemanente = vRemanente - vIntVig - vIvaPag;
             LET vCuotaRec = vStatusCuota;
             LET vStatusCuota   = '5';
             LET iva_status     = '5';
             LET iva_status_ant = '1';
      ELSE
        -- LET vRemanente = vRemanente - vIvaPag;
         LET iva_status     = '1';
         LET iva_status_ant = '0';
     --    LET vIntVig = vRemanente;
         LET vRemanente = 0;
      END IF;

      IF (vIntVig > 0) THEN
         IF vStatusCred  <> 'VP' THEN
               LET vReferencia = 9;   --Pago de Intereses
               CALL GenMovcrd(eEmpresa, eNumCredito, vNumProducto,vReferencia,
                           vCodigoFun, vFecha, vIntVig, g_Folio,
                           vSucursal, vDivisa, '0000', '','') RETURNING
                           CodRet, Mensaje;
               IF (CodRet <> "00000") THEN
                    RETURN CodRet,vRemanente;
               ELSE
                   LET CodRet = "000";
               END IF;

               LET vReferencia = 20;   --Pago De Iva Interes Vigente
               CALL GenMovcrd(eEmpresa, eNumCredito, vNumProducto,vReferencia,
                           '340', vFecha, vIvaPag, g_Folio,
                           vSucursal, vDivisa, '0000', '', '') RETURNING
                          CodRet, Mensaje;
               IF (CodRet <> "00000") THEN
                   RETURN CodRet,vRemanente;
               ELSE
                  LET CodRet = "000";
               END IF;

	      IF vTipoCalculo in ('05', "02",'01') THEN
                   LET vReferencia = 1;   --Provision de Intereses Vigentes
                   IF vIntVig > vIntDevengado THEN
                        CALL GenMovcrd(eEmpresa, eNumCredito, vNumProducto,vReferencia,
                                    "606", vFecha, vIntDevengado, g_Folio,
                                    vSucursal, vDivisa, '0000', '', '')
	                RETURNING CodRet, Mensaje;
                        IF (CodRet <> "00000") THEN
                          RETURN CodRet,vRemanente;
                        ELSE
                          LET CodRet = "000";
                        END IF;
                        UPDATE sd_maesdoscrd set provision_normal = 0
                        Where eEmpresa = eEmpresa and num_credito = eNumCredito;
                    ELSE
                        CALL GenMovcrd(eEmpresa, eNumCredito, vNumProducto,vReferencia,
                                    "606", vFecha, vIntVig, g_Folio,
                                    vSucursal, vDivisa, '0000', '', '')
	                RETURNING CodRet, Mensaje;
                        IF (CodRet <> "00000") THEN
                          RETURN CodRet,vRemanente;
                        ELSE
                          LET CodRet = "000";
                        END IF;
                         UPDATE sd_maesdoscrd set provision_normal = provision_normal - vIntVig
                         Where eEmpresa = eEmpresa and num_credito = eNumCredito;
                    END IF;
	      END IF
        ELSE
              LET vReferencia = 17;   --Pago de Intereses En Pago Sostenido
              CALL GenMovcrd(eEmpresa, eNumCredito, vNumProducto,vReferencia,
                          vCodigoFun, vFecha, vIntVig, g_Folio,
                          vSucursal, vDivisa, '0000', '','') RETURNING
                          CodRet, Mensaje;
              IF (CodRet <> "00000") THEN
                 RETURN CodRet,vRemanente;
              ELSE
                LET CodRet = "000";
             END IF;

             LET vReferencia = 27;   --Pago De Iva Interes Vigente En Pago Sostenido
             CALL GenMovcrd(eEmpresa, eNumCredito, vNumProducto,vReferencia,
                        '340', vFecha, vIvaPag, g_Folio,
                        vSucursal, vDivisa, '0000', '', '') RETURNING
                        CodRet, Mensaje;
             IF (CodRet <> "00000") THEN
                 RETURN CodRet,vRemanente;
             ELSE
                LET CodRet = "000";
             END IF;

	     IF vTipoCalculo in ('05', "02",'01') THEN
                  LET vReferencia = 12;   --Provision de Intereses Vigentes En Pago Sostenido
                  CALL GenMovcrd(eEmpresa, eNumCredito, vNumProducto,vReferencia,
                              "606", vFecha, vIntVig, g_Folio,
                              vSucursal, vDivisa, '0000', '', '')
	          RETURNING CodRet, Mensaje;
                  IF (CodRet <> "00000") THEN
                      RETURN CodRet,vRemanente;
                  ELSE
                      LET CodRet = "000";
                  END IF;
	    END IF
       END IF;
    END IF;
    IF  g_SdoRetenido > 0 THEN  --** Genere Mov. Retension De Interes 
          LET vReferencia = 16;   --Provision de Intereses Vigentes En Pago Sostenido
          CALL GenMovcrd(eEmpresa, eNumCredito, vNumProducto,vReferencia,
                      "033", vFecha, g_SdoRetenido, g_Folio,
                      vSucursal, vDivisa, '0000', '', '')
         RETURNING CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
              RETURN CodRet,vRemanente;
         ELSE
             LET CodRet = "000";
         END IF;
    END IF;

      LET eEmpresa = eEmpresa;
      LET eNumCredito = eNumCredito;
      LET e_fcuota = e_fcuota;

      UPDATE sd_amortiza_creditocrd
         SET interes_pagado = interes_pagado + vIntVig,
             interes_fecha_pago = vFecha,
             interes_status   = vStatusCuota,
             interes_status_ant = vCuotaRec,
             iva_debe           = iva_debe + vIvaPag,
             iva_pagado         = iva_pagado + vIvaPag,
             iva_status         = iva_status,
             iva_status_ant     = iva_status_ant,
             iva_fecha_pago     = vFecha
      WHERE empresa = eEmpresa
      AND num_credito = eNumCredito
      AND fecha_cuota = e_fcuota;

    If (vStatusCuota = '5' and vCuotaRec = '1') or vStatusCuota = '1' then
       SELECT sdo_no_exig INTO vMtoIntSdo FROM sd_maesdoscrd
        WHERE empresa     = eEmpresa
          AND num_credito = eNumCredito;
        --IF vMtoIntSdo < vIntVig THEN
        IF  vIntVig > vMtoIntSdo THEN
          UPDATE sd_maesdoscrd
           SET sdo_no_exig      = 0
           WHERE empresa = eEmpresa
           AND num_credito = eNumCredito;
        ELSE
        UPDATE sd_maesdoscrd
        SET sdo_no_exig      = sdo_no_exig - vIntVig
        WHERE empresa = eEmpresa
          AND num_credito = eNumCredito;
        END IF;
    Elif (vStatusCuota = '5' and vCuotaRec = '3') or vStatusCuota = '3' then
        UPDATE sd_maesdoscrd
        SET int_tra_no_exig      = int_tra_no_exig - vIntVig
        WHERE empresa = eEmpresa
          AND num_credito = eNumCredito;
    End if;


    --LET g_IntVigCob = g_IntVigCob + vIntVig;
    RETURN CodRet,vRemanente;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital vencido, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".principalcrd(p_Empresa  CHAR(3),   --- PROD
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT,
                           p_Monto                  MONEY(14,2),
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  LIKE sd_movdia.Folio_Suc,
                           p_Transacc               LIKE sd_movdia.Transacc_Suc)
   RETURNING CHAR(5),     -- Codigo de Retorno
	     MONEY(14,2), -- Remanente
             MONEY(14,2), -- Interes Moratorio Cobrado
             MONEY(14,2), -- Interes Vencido Cobrado
             MONEY(14,2), -- Capital Vencido Cobrado
             MONEY(14,2), -- Interes Vigente Cobrado
             MONEY(14,2), -- Capital Vigente Cobrado
             MONEY(14,2), -- Impuesto Cobrado
             MONEY(14,2), -- Comisiones Cobradas
             MONEY(14,2)  -- Seguro Cobrado
           --** -----------------------------------------------------------------  **
           -- Ejecuta el pago de acurdo al parametro de tp_pago en donde :
           --    1  Aplica Cascada Normal
           --    2  Aplica por Cuota
           --    3  Aplica Solo Capital
           --    Si el producto maneja linea el tipo de pago siempre sera 1 y se insertara
           --    una cuota ficticia para que el proceso tenga un flujo natural
           --** -----------------------------------------------------------------  **

                     --** Variables Globales **--

   DEFINE GLOBAL g_Sistema         CHAR(2)       DEFAULT '06';
   DEFINE GLOBAL g_Empresa         CHAR(3)       DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito      CHAR(20)      DEFAULT ' ';
   DEFINE GLOBAL g_Usuario         CHAR(8)       DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal        CHAR(4)       DEFAULT ' ';
   DEFINE GLOBAL g_Folio           CHAR(16)      DEFAULT ' ';
   DEFINE GLOBAL g_Transacc        CHAR(4)       DEFAULT ' ';
   DEFINE GLOBAL g_Provision       CHAR(1)       DEFAULT 'S';
   DEFINE GLOBAL g_NumProducto     CHAR(4)       DEFAULT ' ';
   DEFINE GLOBAL g_NumCte          CHAR(20)      DEFAULT ' ';
   DEFINE GLOBAL g_Divisa          CHAR(2)       DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea     CHAR(1)       DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun       CHAR(3)       DEFAULT ' ';
   DEFINE GLOBAL g_PagoAdic        CHAR(1)       DEFAULT ' ';
   DEFINE GLOBAL gTipoCalculo      CHAR(2)       DEFAULT "";
   DEFINE GLOBAL g_StCred	   CHAR(2)       DEFAULT ' ';
   DEFINE GLOBAL g_Fecha           DATE          DEFAULT '';
   DEFINE GLOBAL g_FechaProxPago   DATE          DEFAULT '';
   DEFINE GLOBAL g_TpPago          SMALLINT      DEFAULT 0;
   DEFINE GLOBAL g_SdoMoratorio    MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_Monto           MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_Moratorio       MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_IntMora         MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_IntVenc         MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_CapVenc         MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_IntVig          MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_CapVig          MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_SdoVencInt      MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_SdoVencTraInt   MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_MontoVencido    MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_MtoVencTrasp    MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_SdoCapInsoluto  MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_MtoCapitalizado MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_MontoReservado  MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_SdoIntAnticip   MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_SdoIntAntDev    MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_IntTraNoExig    MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_SdoTrab4        MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_SdoIntereses    MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_SdoAcumMesInt   MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_ProvisionNorm   MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_Remanente       MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_IntMoraCob      MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_IntVencCob      MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_CapVencCob      MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_IntVigCob       MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_CapVigCob       MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_Impuesto        MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_Comision        MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_Seguro          MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_Iva             MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_MoraIva         MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_IvaCte          DECIMAL(9,6)  DEFAULT 0;
   DEFINE GLOBAL vPrecioRealAnt    DECIMAL(14,6) DEFAULT 0;
   DEFINE GLOBAL g_PagSostenido    INTEGER       DEFAULT 0;
   DEFINE GLOBAL vCtaPagoVenc      INTEGER       DEFAULT 0;
   DEFINE GLOBAL vPagAnticipado    SMALLINT      DEFAULT 0;
   DEFINE GLOBAL g_SdoRetenido     MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_DiasAcumMora    INTEGER       DEFAULT 0;
   DEFINE GLOBAL g_MontoAjuste     MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL g_Cubre_Cuota     CHAR(1)       DEFAULT ' ';

   -- Variables para la Bonificacion
   DEFINE vDiasTot       SMALLINT;
   DEFINE vDias          SMALLINT;
   DEFINE vTrabajo       DECIMAL(12,2);
   DEFINE vFecha_Aper    DATE;
   DEFINE vBofInt        DECIMAL(14,2);
   DEFINE vBofIva        DECIMAL(14,2);
   DEFINE vMontoMensual  DECIMAL(14,2);
   DEFINE v_adeudo  DECIMAL(14,2);
   DEFINE v_adeudoint  DECIMAL(14,2);
   DEFINE v_adeudocont  DECIMAL(14,2);

                        --** Variables Locales **--

   DEFINE nRows                 SMALLINT;
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE vReferencia           SMALLINT;
   DEFINE vdiasmora             SMALLINT;
   DEFINE vPagSigCuota          CHAR(1);
   DEFINE v_forma_pago          CHAR(1);
   DEFINE error_info            CHAR(40);
   DEFINE CodRet                CHAR(5);
   DEFINE Mensaje               CHAR(80);
   DEFINE wBegin                CHAR(1);
   DEFINE ax_tranliq		CHAR(4);
   DEFINE vBanRenovac           CHAR(1);   ---Tipo Reestructura (Pago Sostenido)
   DEFINE vBandera              CHAR(1);
   DEFINE ax_status		CHAR(1);
   DEFINE vPagoSigCuota         CHAR(1);
   DEFINE vIvaBase              CHAR(5);
   DEFINE vCuenta               CHAR(20);
   DEFINE vCodTipCred           CHAR(2);
   DEFINE vStatus               CHAR(2);
   DEFINE vOrigCred             CHAR(3);
   DEFINE vTotPag               MONEY(14,2);
   DEFINE vCapital              MONEY(14,2);
   DEFINE v_capvenc             MONEY(14,2);
   DEFINE vCapVenDespPag        MONEY(14,2);
   DEFINE vCapNoTras		MONEY(14,2);
   DEFINE vCapRalSdo 	        MONEY(14,2);
   DEFINE vMontoCuotas          MONEY(14,2);
   DEFINE vIvaPag               MONEY(14,2);
   DEFINE vMoraPag              MONEY(14,2);
   DEFINE vIntPag               MONEY(14,2);
   DEFINE vIvaIntPag            MONEY(14,2);
   DEFINE vCapSigCuota          MONEY(14,2);
   DEFINE vIntSigCuota          MONEY(14,2);
   DEFINE vCapRestruct          MONEY(14,2);
   DEFINE vMtoPagado            MONEY(14,2);
   DEFINE vSdoCapDebe           MONEY(14,2);
   DEFINE TasaIntm              DECIMAL(9,6);
   DEFINE vSdoRetenido	  	DECIMAL(14,2);
   DEFINE vIva			DECIMAL(14,2);
   DEFINE vSdoDeudor            DECIMAL(14,2);
   DEFINE vDisponible           DECIMAL(14,2);
   DEFINE vIntIva               DECIMAL(14,2);
   DEFINE vMoraIva              DECIMAL(14,2);
   DEFINE vcapvig               DECIMAL(14,2);
   DEFINE vPagoMin              DECIMAL(14,2);
   DEFINE vRetenido             DECIMAL(14,2);
   DEFINE vBonifCapital         DECIMAL(14,2);
   DEFINE vBonifIva             DECIMAL(14,2);
   DEFINE vAdeudoPendiente      DECIMAL(14,2);
   DEFINE vMtoCuota             DECIMAL(14,2);
   DEFINE vpagao                decimal(14,2);
   DEFINE vDifAmortiza          DECIMAL(14,2);

   DEFINE vFechaCorte           DATE;
   DEFINE vfcuota		DATE;
   DEFINE vFechaPago            DATE;
   DEFINE vFecAmortiza          DATE;
   DEFINE v_fcuota		DATE;
   DEFINE vFechaHoy             DATE;
   DEFINE v_fcuotaVP            DATE;
   DEFINE vFecCuota             DATE;
   DEFINE vUltHabMes            DATE;
   DEFINE vFecSig               DATE;
   DEFINE vFecPago              DATE;
   DEFINE vPlazo                INTEGER;
   DEFINE vCred                 SMALLINT;
   DEFINE vCapStaSos            CHAR(1);

   DEFINE vStatusCap            CHAR(1);
   DEFINE vStatusInt            CHAR(1);



   ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "Principal.err";
        TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      LET Mensaje = error_info;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
	     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
   END EXCEPTION;

  ON EXCEPTION IN (-535)
      LET wBegin = "S";
     -- ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

--   if p_NumCredito = "610013502006" then
--     SET DEBUG FILE TO "/tmp/principalcrd006.out";
--     TRACE ON;
--   end if
--   if p_NumCredito = "610012927527" then
--     SET DEBUG FILE TO "/tmp/principalcrd527.out";
--    TRACE ON;
--   end if
   LET wBegin = "N";
   BEGIN WORK;
            LET CodRet = "000";
            SELECT descripcion INTO Mensaje
            FROM bdinteg:si_codret
            WHERE sistema = g_sistema
               AND codigo_retorno = CodRet;


           IF (p_Folio = ' ' OR p_Folio IS NULL) THEN
                 LET g_Folio   = ConstruyeFolio();
                 SELECT
                  SUBSTR(USER,1,4)||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
                  SUBSTR(CURRENT,12,2)||substr(current,15,2) ||SUBSTR(current,18,2)
                INTO g_Folio
                FROM dual;
           ELSE
                 LET g_Folio       = p_Folio;
           END IF;

           LET g_empresa       = p_empresa;
           LET g_NumCredito    = p_NumCredito;
           LET g_TpPago        = 1; --p_TpPago;
           LET g_Monto         = p_Monto;
           LET g_Usuario       = p_Usuario;
           LET g_Sucursal      = p_Sucursal;
           LET g_Transacc      = p_Transacc;
           LET g_Seguro        = 0;
           LET vTotPAg         = 0;
           LET p_TpPago        = 1;
           LET g_Moratorio     = 0;
           LET g_Remanente     = g_Monto;
           LET CodRet          = "000";
           LET Mensaje	       = '';
           LET g_IntVencCob    = 0;
           LET g_CapVencCob    = 0;
           LET g_IntVigCob     = 0;
           LET g_CapVigCob     = 0;
           LET g_Seguro        = 0;
           LET g_Comision      = 0;
           LET g_IntMoraCob    = 0;
           LET vSdoRetenido    = 0;
           LET vIva            = 0;
           LET vCapNoTras      = 0;
           LET vIvaPag         = 0;
           LET vMoraPag        = 0;
           LET vIntPag         = 0;
           LET vIvaIntPag      = 0;
           LET vFechaHoy       = '';
           LET v_forma_pago    = '' ;
           LET vCapSigCuota    = 0;
           LET vIntSigCuota    = 0;
           LET vPagSigCuota    = '';
           LET gTipoCalculo    = '';
           LET vFecSig 	       = '';
           LET vPagoSigCuota   = '';
           LET vIvaBase        = '';
           LET v_fcuotaVP      = '';
           LET vCuenta         = '';
           LET vSdoCapDebe     = 0;
           LET vStatus         = '';
           LET vCapRestruct    = 0;
           LET vfcuota         = '';

           LET vSdodeudor      = 0;
           LET vPagoMin        = 0;
           LET vRetenido       = 0;
           LET vFechaCorte     = '';
           LET vDisponible     = 0;
           LET vIntIva         = 0;
           LET vMoraIva        = 0;
           LET vFechaPago      = '';
           LET vcapvig         = 0;
           LET vBanRenovac     = '';
           LET vFecAmortiza    = '';
           LET vCapVenDespPag  = 0;
           LET vCapRalSdo      = 0;
           LET vBandera        = 'N';
           LET vOrigCred       = '';
           LET vBonifCapital   = 0;
           LET vBonifIva       = 0;
           LET vPlazo          = 0;
           LET vDias           = 0;
           LET vDiasTot        = 0;
           LET vTrabajo        = 0;
           LET vFecha_Aper     = "";
           LET vBofInt         = 0;
           LET vBofIva         = 0;
           LET vCred           = 0;
           LET vMontoMensual   = 0;
           LET vCapStaSos      = '';
           LET vStatusCap      = '';
           LET vStatusInt      = '';
           LET vMtoCuota       = 0;
           LET vMontoCuotas    = 0;
           LET vDifAmortiza    = 0;
           LET vAdeudoPendiente= 0;
           LET vFecPago         = '';


	   SELECT
                  b.sdo_moratorio + b.sdo_exig_int + b.sdo_cap_insoluto + b.sdo_no_exig + b.mto_venc_tra_int + mto_venc_int +
                  b.int_tra_no_exig , b.sdo_moratorio + b.sdo_exig_int + b.sdo_no_exig + b.mto_venc_tra_int + mto_venc_int +
                  b.int_tra_no_exig , b.sdo_retenido,c.fecha_hoy,b.monto_otorgado - b.mto_ministra_cap,d.iva,
                  b.int_tra_no_exig + b.sdo_exig_int + b.sdo_no_exig + b.mto_venc_tra_int + mto_venc_int,
                  b.sdo_moratorio
           INTO
                 vSdodeudor,vPagoMin,vRetenido,vFechaCorte,vDisponible,
                 vIva,vIntIva,vMoraIva
           FROM
                 sd_maecredcrd a, sd_maesdoscrd b, sd_fechas c , bdinteg:si_sucursales d
           WHERE a.empresa          = p_Empresa
                    AND a.num_credito      = p_NumCredito
                    AND a.bandera_ministra = 'M'
                    AND b.empresa          = a.empresa
                    AND b.num_credito      = a.num_credito
                    AND a.sucursal         = d.sucursal
                    AND c.empresa          = a.empresa;

           IF vSdodeudor IS NULL or vSdodeudor < 0 THEN
              LET CodRet = "997";
              RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
                     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
           END IF;


           SELECT min(fecha_cuota) into vFechaPago
           FROM sd_amortiza_creditocrd
           WHERE empresa = p_Empresa
                     and num_credito = p_NumCredito
            and (capital_status <> "5" or interes_status <> "5");

                    --** Calcula Iva De Mora E Interes
           LET vIntIva  = vIntIva * vIva;
           LET vMoraIva = vMoraIva * vIva;

           IF vFechaPago IS NULL THEN
               Let vPagoMin = 0;
               Let vFechaPago = "";
               let vcapvig = 0;
           ELSE
               select capital_debe - capital_pagado,capital_mto_cuota,
                capital_pagado + interes_pagado + iva_pagado
               into   vcapvig, vMontoMensual,vpagao
               from sd_amortiza_creditocrd
                where empresa = p_Empresa
                   and num_credito = p_NumCredito
                   and fecha_cuota = vFechaPago;
              if vpagao > 0 then
                let vMontoMensual = vMontoMensual - vpagao;
              end if
           END IF
           -- Si Cubre el Monto pasamos la Variable al Plande Pagos
           IF p_Monto >= vMontoMensual THEN
              LET g_Cubre_Cuota = "1";
           ELSE
              LET g_Cubre_Cuota = "0";
           END IF;

           IF vRetenido > 0 then
              let vPagoMin = vPagoMin - vRetenido + vcapvig;
              let vSdoDeudor = vSdoDeudor - vRetenido;
           end if
           if vPagoMin < 0 then
              let vPagoMin = 0;
           end if
           if vSdoDeudor < 0 then
              let vSdoDeudor = 0;
           end if
           LET vSdoDeudor = vSdoDeudor + vIntIva + vMoraIva;

           --- Valida que el monto a pagar no sobrepase a lo que debe
           IF vSdoDeudor < p_Monto AND p_Monto - vSdoDeudor > .01 THEN
              let CodRet = "3";
              RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
              g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
              g_Comision, g_Seguro;
          end if;

                                   --** Valor De Iva Por Region **--

           SELECT TRIM(valor) INTO vIvaBase FROM bdinteg:si_param
           WHERE cod_param = '47' and empresa = g_Empresa;

           IF vIvaBase Is Null Or vIvaBase = '' THEN
             LET CodRet = '997';
             RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
                      g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
           END IF;


           SELECT TRIM(valor) INTO ax_tranliq FROM sd_param
           WHERE cod_param = "70"
             AND empresa = g_Empresa;


                     --** Obtiene Los Valores Generales Para El Proceso **--

          SELECT a.num_producto    , a.numcte          , a.divisa         , b.sdo_intereses   ,
                 b.sdo_int_anticip , b.sdo_int_ant_dev , b.int_tra_no_exig, b.sdo_trab4       ,
                 b.sdo_moratorio   , b.sdo_exig_int    , b.monto_vencido + b.mto_venc_trasp   ,
                 b.monto_vencido   , b.mto_venc_trasp  , b.sdo_no_exig    , b.sdo_capital     ,
                 b.monto_financiado, b.monto_reservado , b.mto_venc_int   , b.mto_venc_tra_int,
                 b.sdo_acum_mes_int, b.provision_normal, b.sdo_cap_insoluto,b.mto_capitalizado ,
                 c.fecha_hoy       , d.maneja_linea    , "2"               , status_cred       ,
                 d.cod_tipcred        , b.sdo_retenido    , a.fecha_vencim    , a.tipo_calculo    ,
                 d.pago_adic_sig_cuota, a.pagos_sostenidos,cap_tras_no_venci  , a.bandera_renovac,
                 dias_acum_mora       , a.origen          , a.plazo        ,a.fecha_apertura
          INTO
                 g_NumProducto     , g_NumCte          , g_Divisa          , g_SdoIntereses        ,
                 g_SdoIntAnticip   , g_SdoIntAntDev    , g_IntTraNoExig    , g_SdoTrab4            ,
                 g_SdoMoratorio    , g_IntVenc         , g_CapVenc         , g_MontoVencido        ,
                 g_MtoVencTrasp    , g_IntVig          , g_CapVig          , g_MontoFinanciado     ,
                 g_MontoReservado  , g_SdoVencInt      , g_SdoVencTraInt   , g_SdoAcumMesInt       ,
                 g_ProvisionNorm   , g_SdoCapInsoluto  , g_MtoCapitalizado , g_Fecha, g_ManejaLinea,
                 g_PagoAdic        , g_StCred          , vCodTipCred       , vSdoRetenido          ,
                 --g_FechaProxPago   , gTipoCalculo      , vPagoSigCuota     , g_PagSostenido        ,
                 g_FechaProxPago   , gTipoCalculo      , vPagAnticipado     , g_PagSostenido        ,
                 vCapNoTras        , vBanRenovac       ,g_DiasAcumMora     , vOrigCred             ,
                 vPlazo            , vFecha_Aper
           FROM
                 sd_maecredcrd a, sd_maesdoscrd b, sd_fechas c, sd_definicioncrd d
          WHERE a.empresa          = g_Empresa
            AND a.num_credito      = g_NumCredito
            AND a.bandera_ministra = 'M'
            AND b.empresa          = a.empresa
            AND b.num_credito      = a.num_credito
            AND c.empresa          = a.empresa
            AND d.empresa          = a.empresa
            AND d.num_producto     = a.num_producto;

          LET nrows = dbinfo("sqlca.sqlerrd2");
          IF (nrows = 0) THEN
               LET CodRet = "008";
               SELECT descripcion
               INTO Mensaje
               FROM bdinteg:si_codret
               WHERE sistema = g_sistema
                 AND codigo_retorno = CodRet;
               ROLLBACK WORK;
               IF (wBegin = "S") THEN
                  BEGIN WORK;
               END IF;
               RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
                      g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
          END IF;

          IF g_StCred <> "CC" THEN
              LET g_CodigoFun  = '222';
          ELSE
              LET g_CodigoFun  = '222';
          END IF

          IF p_Transacc not in ('0600','0606') THEN
              LET vMtoPagado      = p_Monto  ;
          ELSE
             LET vMtoPagado      = p_Monto + vSdoRetenido ;
          END IF;
                                --** Rutina De SBC **--
          IF p_Transacc = "6814" THEN
             SELECT fecha_hoy - 15 UNITS DAY    INTO vFechaHoy
             FROM bdinteg:si_fechas WHERE empresa = p_Empresa;
             SELECT forma_pago INTO v_forma_pago
             FROM bditarjeta:td_conpospnc
             WHERE folio_mov = p_Folio AND
                   fecha    >= vFechaHoy ;
             IF v_forma_pago = "1" then
                LET g_CodigoFun = '335';
             ELSE
                LET g_CodigoFun = '334';
             END IF
          END IF

              --** Determina Si Genera Provision A Fin De Mes **--

          SELECT ult_hab_mes INTO  vUltHabMes FROM sd_fechas WHERE empresa =  p_Empresa;
          IF g_Fecha = vUltHabMes THEN
             LET g_Provision = 'N' ;
          END IF;

                       --**Inicia Respaldo de Tablas de Reversion **--


          CALL respalda_creditocrd(p_Empresa, p_NumCredito,p_Usuario ) RETURNING CodRet;
          IF (CodRet <> "000") THEN
             SELECT descripcion INTO Mensaje FROM bdinteg:si_codret
             WHERE empresa        = g_Empresa AND codigo_retorno = p_CodRet;
             ROLLBACK WORK;
             IF (wBegin = "S") THEN
                BEGIN WORK;
             END IF;
             RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
                    g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
          END IF;

          LET vBofInt = 0;
          LET vBofIva = 0;


          IF g_StCred = 'VP' THEN


                 SELECT NVL(sum(capital_debe - capital_pagado),0) +
                        NVL(sum(interes_debe - interes_pagado),0) +
                        NVL(round(sum(interes_debe - interes_pagado)* vIva,2),0)
                 INTO vAdeudoPendiente
                 FROM Sd_amortiza_creditocrd
                 WHERE empresa     = g_Empresa
                   AND num_credito = g_NumCredito
                   AND fecha_cuota < g_Fecha ;
   
 
		 SELECT min(fecha_cuota) INTO v_fcuota
                 FROM sd_amortiza_creditocrd
                 WHERE empresa     = g_Empresa
                   AND num_credito = g_NumCredito
                   AND capital_status  = "3";
                 SELECT sum(capital_debe - capital_pagado) +
                        sum(interes_debe - interes_pagado) +
                        round(sum(interes_debe - interes_pagado)* vIva,2)
                 INTO vMtoCuota
                 FROM sd_amortiza_creditocrd
                 WHERE empresa     = g_Empresa
                   AND num_credito = g_NumCredito
                   AND fecha_cuota = v_fcuota ;

                 LET vMtoCuota = round(vMtoCuota,2);

                 SELECT capital_mto_cuota
                 INTO vMontoCuotas
                 FROM sd_amortiza_creditocrd
                 WHERE empresa     = g_Empresa
                   AND num_credito = g_NumCredito
                   AND fecha_cuota = v_fcuota ;
                  LET vMtoCuota = vMtoCuota + g_SdoMoratorio;
                  IF vMtoCuota > vMontoCuotas THEN
                      LET vDifAmortiza = vMtoCuota - vMontoCuotas;
                      let vMtoCuota = vMontoCuotas;
                  END IF;
                  IF g_Fecha = v_fcuota  AND  p_Monto >= (vMtoCuota  + vAdeudoPendiente) THEN
                      LET g_PagSostenido = g_PagSostenido + 1;
                      UPDATE sd_maecredcrd SET pagos_sostenidos = pagos_sostenidos + 1
                      WHERE empresa    = g_Empresa
                      AND num_credito = g_NumCredito;
                   ELSE
                      IF g_PagSostenido <> '3' THEN
                         LET g_PagSostenido = 0;
                         UPDATE sd_maecredcrd SET pagos_sostenidos = g_PagSostenido
                         WHERE empresa    = g_Empresa
                          AND num_credito = g_NumCredito;
                      END IF;
                  END IF;

             { SELECT sum(capital_mto_cuota -(capital_debe + (interes_debe * (1+vIva))))
                  INTO v_adeudo
                   FROM   sd_amortiza_creditocrd
                   WHERE  empresa = g_empresa
                   AND    num_credito = g_NumCredito
                   AND    fecha_cuota <= g_Fecha
                   and    capital_status <> '5';

              select sum(capital_debe - capital_pagado +
                 ((interes_debe - interes_pagado)*(1+vIva))) into v_adeudoint
         	         from sd_amortiza_creditocrd
         	         WHERE  empresa = g_empresa
                   AND    num_credito = g_NumCredito
                   AND    fecha_cuota <= g_Fecha
                   and capital_status <> '5';
		         if v_adeudoint is null then let v_adeudoint = 0; end if;
		         if v_adeudo is null then let v_adeudo = 0; end if;
              if v_adeudo < 0  then
		                  let v_adeudo = v_adeudo * (-1);
		                  let v_adeudoint = v_adeudoint - v_adeudo;
                  else
                      let v_adeudoint = v_adeudoint;
                  end if
                  SELECT count(*)
                  INTO v_adeudocont
                   FROM   sd_amortiza_creditocrd
                   WHERE  empresa = g_empresa
                   AND    num_credito = g_NumCredito
                   AND    fecha_cuota <= g_Fecha
                   and    capital_status <> '5';
                  let v_adeudo = trunc((p_monto/vMontoCuotas),0);
                  if p_Monto >= v_adeudoint  and (v_adeudo >= 2 or v_adeudocont >= 2 ) then
                      if v_adeudo < v_adeudocont then
                         let v_adeudo = v_adeudocont;
                      end if
                      let g_PagSostenido = g_PagSostenido + (v_adeudo - 1);
                      UPDATE sd_maecredcrd SET pagos_sostenidos = pagos_sostenidos + (v_adeudo -1)
                      WHERE empresa    = g_Empresa
                      AND num_credito = g_NumCredito;
                 end if }
          END IF;



          --** Ejecuacion De Pago De Acuerdo A La Cascasda **--
                   --** Cobro De Cuotas Vencidas **--

         IF g_TpPago = "1" OR g_TpPago = "2" THEN
            FOREACH
                 SELECT fecha_cuota,capital_status,interes_status
                 INTO   v_fcuota, vStatusCap, vStatusInt
                 FROM sd_amortiza_creditocrd
                 WHERE empresa = g_Empresa
                   AND num_credito = g_NumCredito
                   AND capital_status  IN ("7", "2","3")
                 ORDER BY fecha_cuota asc

	             --** Realiza el cobro de Intereses Moratorios **--
                 IF (g_SdoMoratorio > 0 AND g_Remanente > 0) THEN
                      CALL cobramoratorioscrd(v_fcuota) RETURNING CodRet;
                      IF(CodRet <> "000") THEN
                        ROLLBACK WORK;
                        IF (wBegin = "S") THEN
                           BEGIN WORK;
                        END IF;
	                SELECT descripcion INTO Mensaje
	                FROM bdinteg:si_codret
	                WHERE sistema = g_sistema
	                  AND codigo_retorno = CodRet;
                        RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
	                g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
	                g_Comision, g_Seguro;
	             END IF;
	         END IF;

                 -- ** Cobra primero el Capital para cubrir lo del INteres Devengado **--
                 IF vStatusInt = '5' and vStatusCap <> '5' THEN -- Esto es por si la cuota de Interes Ya pago
                    IF (g_CapVenc > 0 AND g_Remanente > 0) or( vCapNoTras > 0) THEN
                       CALL cobracapvencidocrd (v_fcuota) RETURNING CodRet;
                       IF(CodRet <> "000") THEN
                          ROLLBACK WORK;
                          IF (wBegin = "S") THEN
                             BEGIN WORK;
                          END IF;
                          SELECT descripcion INTO Mensaje
                          FROM bdinteg:si_codret
                          WHERE sistema = g_sistema
                          AND codigo_retorno = CodRet;
                          RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                                 g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                                 g_Comision, g_Seguro;
                       END IF;
                    END IF;
                 END IF;

	                       --** Realiza el cobro de Intereses Vencidos Cuotas 7 y 2 **--

                     --IF ((g_IntVenc + g_IntTraNoExig) > 0 AND g_Remanente > 0) THEN
                     IF ((g_IntVenc + g_IntTraNoExig +  g_SdoVencInt  + g_SdoVencTraInt) > 0 AND g_Remanente > 0) THEN
                          CALL cobraintvencidocrd(v_fcuota) RETURNING CodRet;
                          IF(CodRet <> "000") THEN
                                 ROLLBACK WORK;
	                         IF (wBegin = "S") THEN
                                     BEGIN WORK;
	                         END IF;
	                         SELECT descripcion INTO Mensaje
	                         FROM bdinteg:si_codret
	                         WHERE sistema = g_sistema
	                           AND codigo_retorno = CodRet;
      		                 RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
			                g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
			                g_Comision, g_Seguro;
	                  END IF;
	               END IF;
	                        --** Realiza el cobro de Capital Vencidos Cuotas 7 y 2 **--

                       -- IF (g_CapVenc > 0 AND g_Remanente > 0) or( vCapNoTras > 0) THEN MEL
                       IF (g_CapVenc > 0 AND g_Remanente > 0) or( vCapNoTras > 0) AND v_fcuota  <= g_Fecha THEN
                           CALL cobracapvencidocrd (v_fcuota) RETURNING CodRet;
                           IF(CodRet <> "000") THEN
                              ROLLBACK WORK;
                              IF (wBegin = "S") THEN
                                BEGIN WORK;
                              END IF;
                              SELECT descripcion INTO Mensaje
                              FROM bdinteg:si_codret
                              WHERE sistema = g_sistema
                               AND codigo_retorno = CodRet;
                              RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                                     g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                                     g_Comision, g_Seguro;
                           END IF;
                       END IF;


                       IF g_Remanente = 0 THEN
                          EXIT FOREACH;
                       ELSE
                          IF g_Remanente >= g_MontoReservado AND   v_fcuota > g_Fecha THEN -- Es Anticipado
                             CALL sp_menos_plazocrd(p_Empresa, p_NumCredito, g_Remanente) --RETURNING CodRet,g_Remanente;
                                  RETURNING CodRet, g_Remanente;
                             LET vfcuota = v_fcuota;
                             LET g_SdoRetenido = g_SdoRetenido;
                           END IF;

                       END IF;
               END FOREACH
         --  END IF ; --** IF De  g_SdoMoratorio


                     --** Traspasa Cap Vencido No Exigible a Vigente **--
           IF vBanRenovac ='S' THEN    --** Es reestructura Entra A Sostenido
              IF g_PagSostenido >= 3 THEN
                  SELECT mto_venc_tra_int,mto_venc_int,cap_tras_no_venci
                  INTO g_SdoVencTraInt,g_Intvenc,vcapnotras
                  FROM sd_maesdoscrd
                  WHERE  empresa = g_Empresa
                    AND num_credito = g_NumCredito;
                  IF g_MtoVencTrasp = 0 AND  g_StCred in ('VP', "BT") THEN
                       IF vCapNoTras > 0 THEN
                          LET g_PagSostenido = 0;
                          LET g_StCred       = 'AA';
                          LET g_IntTraNoExig = 0;
                          UPDATE sd_maecredcrd SET status_cred      = g_StCred,
                                                   bandera_renovac  = 'N',
                                                   pagos_sostenidos = 0
                          WHERE empresa = g_empresa
                            AND num_credito = g_NumCredito;


                          UPDATE sd_amortiza_creditocrd set interes_status     = '1',
                                                            capital_status     = '1' ,
                                                            capital_status_ant = '2',
                                                            interes_status_ant  = '3'
                          WHERE capital_status in( '2' ,'3')
                            AND capital_debe <> capital_pagado
                            AND num_credito = g_NumCredito;

                         LET vCapNoTras     = vcapnotras;
                         LET g_CapVig       = vcapnotras;
                         LET g_MtoVencTrasp = 0;

                         CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,5          , '601'   ,
                                     g_Fecha  , vCapNoTras  , g_Folio      , g_Sucursal, g_Divisa, g_Transacc,'','')
                         RETURNING CodRet, Mensaje;
                         IF (CodRet <> "00000") THEN
                             LET  CodRet = CodRet;
                         ELSE
                            LET CodRet = "000";
                         END IF;
                         LET g_IntVig       = 1;
                         LET vCapNoTras     = g_CapVig;
                         UPDATE sd_maesdoscrd SET sdo_capital       = vCapNoTras,
                                                  cap_tras_no_venci = 0,
                                                  dias_acum_mora    = 0,
                                                  sdo_moratorio     = 0,
                                                  sdo_no_exig       = g_IntTraNoExig,
                                                  int_tra_no_exig   = 0
                         WHERE empresa     = g_Empresa
                           AND num_credito = g_NumCredito;
                       END IF;    --If MtoCapTras
                  END IF;         --If g_MtoVencTrasp
              END IF;                --if g_PagSostenido
           END IF;     --** IF vBanRenovac




                                 --** Cobro De Cuotas Vigentes **--

           FOREACH
                     SELECT fecha_cuota INTO v_fcuota
		     FROM sd_amortiza_creditocrd
                     WHERE empresa = g_Empresa
                       AND num_credito = g_NumCredito
		       AND (capital_status in( "1" ,'2','3') or interes_status = '1')
		     ORDER BY 1

	                           --** Realiza el Cobro de Seguros **--
                    IF g_Remanente > 0 THEN
                           CALL cobracomisionescrd("2", v_fcuota) RETURNING CodRet;
                           IF(CodRet <> "000") THEN
                              ROLLBACK WORK;
                              IF (wBegin = "S") THEN
                                  BEGIN WORK;
                              END IF;
                              SELECT descripcion INTO Mensaje
                              FROM bdinteg:si_codret
                              WHERE sistema = g_sistema
                               AND codigo_retorno = CodRet;
                              RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                                     g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                                     g_Comision, g_Seguro;
                          END IF;
                    END IF

                               --** Realiza Cobro De Interes Vigente **--
                    LET g_IntVig    = g_IntVig ;
                    LET g_Remanente = g_Remanente;
                    IF (g_IntVig > 0 AND g_Remanente > 0 )  THEN
                           CALL cobraintvigentecrd (v_fcuota) RETURNING CodRet;
	                   IF(CodRet <> "000") THEN
                               ROLLBACK WORK;
	                       IF (wBegin = "S") THEN
                                   BEGIN WORK;
	                       END IF;
	                       SELECT descripcion INTO Mensaje
	                       FROM bdinteg:si_codret
	                       WHERE sistema = g_sistema
	                         AND codigo_retorno = CodRet;
                                RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                                       g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                                       g_Comision, g_Seguro;
	                   END IF;
	           END IF;
                   LET g_Remanente = g_Remanente;
                               --** Realiza Cobro De Capital Vigente **--

                   IF (g_CapVig > 0 AND g_Remanente > 0) THEN
                         CALL cobracapvigentecrd (v_fcuota) RETURNING CodRet;
                         IF(CodRet <> "000") THEN
                             --ROLLBACK WORK;
                            IF (wBegin = "S") THEN
                               --BEGIN WORK;
                            END IF;
                            SELECT descripcion INTO Mensaje
                            FROM bdinteg:si_codret
                            WHERE sistema = g_sistema
                              AND codigo_retorno = CodRet;
                            RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                                   g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                                   g_Comision, g_Seguro;
                         END IF;
                   END IF;

                   IF g_Remanente = 0 THEN
                      EXIT FOREACH;
                    END IF
                   IF g_Remanente > 0 AND g_ManejaLinea = "1" THEN
                      EXIT FOREACH;
                   END IF
                       IF g_Remanente > 0 THEN
                         LET vCapRestruct = g_Remanente;
                         LET vfcuota = v_fcuota;
                         LET g_SdoRetenido = g_SdoRetenido;
                         IF vPagAnticipado = 1 THEN
                           IF g_CapVig >0 THEN
                              CALL sp_menos_plazocrd(p_Empresa, p_NumCredito, g_Remanente) --RETURNING CodRet,g_Remanente;
                                   RETURNING CodRet, g_Remanente;
                              LET vfcuota = v_fcuota;
                              LET g_SdoRetenido = g_SdoRetenido;
                           ELSE
                              CALL sp_menos_cuotacrd(p_Empresa, p_NumCredito, g_Remanente) --RETURNING CodRet,g_Remanente;
                                   RETURNING CodRet, g_Remanente;
                           END IF;
                          END IF;
                       END IF;
           END FOREACH  --** Foreach Vigente
        END IF  --** IF Tipo Pago

               --** Modificacion Al Terminar El Pago **--
        SELECT sdo_cap_insoluto, (monto_vencido + mto_venc_trasp) INTO vCapital, v_capvenc
        FROM sd_maesdoscrd
        WHERE empresa = g_empresa
           AND num_credito = g_NumCredito;

        -- Credito con saldoo Cero es Credito Saldado Firma Antonio Oropeza
        IF (vCapital = 0) THEN
            UPDATE sd_maecredcrd SET status_cred = 'FF'
            WHERE empresa = g_empresa
            AND num_credito = g_NumCredito;
            LET g_StCred = "FF";
            LET vBandera = 'S';
        END IF



    IF (g_ManejaLinea <> '1') THEN
            IF (vCapital = 0) THEN
                  UPDATE sd_maecredcrd SET status_cred = 'FF'
                  WHERE empresa = g_empresa
                    AND num_credito = g_NumCredito;
            ELSE
                  IF g_StCred <> "CC" THEN
                        IF vBanRenovac = 'S' THEN
                             IF v_capvenc = 0 AND g_StCred  not in ("AA",'VP') THEN
                                  IF g_DiasAcumMora >= 90 THEN
                                      UPDATE sd_maecredcrd SET status_cred      = 'VP',             --Cambio De Estatus
                                                               pagos_sostenidos = g_PagSostenido + 1
                                      WHERE empresa = g_empresa
                                        AND num_credito = g_NumCredito;
                                  END IF
                                  UPDATE sd_maesdoscrd SET dias_acum_mora = 0
                                  WHERE num_credito = g_NumCredito
                                    AND empresa = g_Empresa;
                             ELSE
                                  IF g_StCred = 'VP'  THEN
                                           IF  g_PagSostenido >= 3 THEN
                                                   SELECT mto_venc_tra_int,mto_venc_int,cap_tras_no_venci
                                                  INTO g_SdoVencTraInt,g_Intvenc,vcapnotras
                                                  FROM sd_maesdoscrd
                                                  WHERE empresa = g_Empresa
                                                   AND  num_credito = g_NumCredito;

                                                  UPDATE sd_maecredcrd SET status_cred     = 'AA',
                                                                           bandera_renovac = 'N',
                                                                           pagos_sostenidos = 0
                                                  WHERE empresa     = g_empresa
                                                    AND num_credito = g_NumCredito;

                                                  UPDATE sd_amortiza_creditocrd set interes_status     = '1',
                                                                                    capital_status     = '1' ,
                                                                                    capital_status_ant = '2',
                                                                                    interes_status_ant = '3'
                                                  WHERE capital_status in('3', '2')
                                                    AND capital_debe <> capital_pagado
                                                    and interes_debe <> interes_pagado
                                                    AND num_credito = g_NumCredito;
                                                 UPDATE sd_amortiza_creditocrd set  capital_status     = '1' ,
                                                                                    capital_status_ant = '2'
                                                  WHERE capital_status in('3', '2')
                                                    AND capital_debe <> capital_pagado
                                                    AND interes_debe = interes_pagado
                                                    AND num_credito = g_NumCredito;
                                                    CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto,5          , '601'   ,
                                                                g_Fecha  , vCapNoTras  , g_Folio      , g_Sucursal, g_Divisa, g_Transacc,'','')
                                                    RETURNING CodRet, Mensaje;
                                                    IF (CodRet <> "00000") THEN
                                                        LET  CodRet = CodRet;
                                                    ELSE
                                                       LET CodRet = "000";
                                                    END IF;
                                                   UPDATE sd_maesdoscrd SET sdo_capital       = vCapNoTras,
                                                                            cap_tras_no_venci = 0,
                                                                            dias_acum_mora    = 0,
                                                                            sdo_moratorio     = 0,
                                                                            sdo_no_exig       = g_IntTraNoExig,
                                                                            int_tra_no_exig   = 0
                                                  WHERE empresa     = g_Empresa
                                                    AND num_credito = g_NumCredito;

                                           END IF;
                                  END IF;
                             END IF;
                        ELSE   --** vBanRenovac
                            IF v_capvenc <= 0 AND g_StCred <> "AA" THEN
                                     IF vBandera = 'N'THEN
                                          UPDATE sd_maecredcrd SET status_cred = 'AA'
                                          WHERE empresa = g_Empresa AND num_credito = g_NumCredito;
                                     END IF;

                                     UPDATE sd_maesdoscrd SET dias_acum_mora = 0
                                     WHERE num_credito = g_NumCredito AND empresa = g_Empresa;

                                     UPDATE sd_amortiza_creditocrd SET capital_status ="5"
                                      WHERE num_credito = g_NumCredito
                                         AND empresa = g_Empresa
                                         AND capital_status IN ("2","7");
                              END IF;
                        END IF  --** IF vBanRenovac
                  END IF
            END IF
      END IF;


         LET  g_IntMoraCob = g_IntMoraCob;
         LET  g_IntVencCob = g_IntVencCob;
         LET  g_CapVencCob = g_CapVencCob;
         LET  g_IntVigCob  = g_IntVigCob;
         LET  g_CapVigCob  = g_CapVigCob;
         LET  g_Impuesto   = g_Impuesto;
         LET  g_Comision   = g_Comision;
         LET  g_Seguro     = g_Seguro;
         LET  g_Iva        = g_Iva;
         LET  g_MoraIva    = g_MoraIva;
LET vTotPag =  g_IntMoraCob + g_IntVencCob + g_CapVencCob + g_IntVigCob +
                        g_CapVigCob  + g_Impuesto   + g_Comision   + g_Seguro    +
                        g_Iva        + g_MoraIva;


         UPDATE sd_maesdoscrd
            set  mto_ministra_cap = 0
         Where empresa = g_Empresa
           and num_credito = g_NumCredito;

         IF (vTotPag > 0) or (p_Monto > 0) THEN
              LET vReferencia = 1;   -- Total del Pago
              CALL genmovcrd(g_Empresa, g_NumCredito, g_NumProducto, vReferencia,
                          g_CodigoFun, g_Fecha, vMtoPagado, g_Folio,          --vtotpag
                          g_Sucursal, g_Divisa, g_Transacc,'','') RETURNING
                          CodRet, Mensaje;
              IF (CodRet <> "00000") THEN
                  LET  CodRet = CodRet;
              ELSE
                  LET CodRet = "000";
              END IF;

              UPDATE sd_maecredanexocrd SET fecha_ult_pago = g_Fecha
              WHERE empresa = g_Empresa
                AND num_credito = g_NumCredito;
          END IF;
          let v_fcuota = NULL;

          SELECT min(fecha_cuota) INTO v_fcuota
            FROM sd_amortiza_creditocrd
            WHERE empresa = g_Empresa
            AND num_credito = g_NumCredito
            AND capital_status  IN ("7");
          if v_fcuota is null or v_fcuota = "" then
          else
              let vdiasmora = g_Fecha - v_fcuota;
select dias_acum_mora into vReferencia
              from sd_maesdoscrd
              Where empresa = g_Empresa
              and num_credito = g_NumCredito;
              if vReferencia > vdiasmora then
                 update sd_maesdoscrd set dias_acum_mora = vdiasmora
                 Where empresa = g_Empresa
                 and num_credito = g_NumCredito;
              end if
          end if

	let CodRet='000';

          IF(CodRet <> "000") THEN
              ROLLBACK WORK;
          ELSE
             COMMIT WORK;
          END IF;

          IF (wBegin = "S") THEN
             BEGIN WORK;
          END IF;

          SELECT descripcion INTO Mensaje
          FROM bdinteg:si_codret
          WHERE sistema = g_sistema
            AND codigo_retorno = CodRet;



           RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
                  g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
                  g_Comision, g_Seguro ;
END PROCEDURE
DOCUMENT
'Programa de Recuperacion de credito',
'Puede ser llamado desde el ofi, centrales o',
'FECHA : 17/Octubre/2003',
'VERSION: 1.00.000',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_mueve_movdiarees(pEmpresa char(3))
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    define pmovtos      integer;
    DEFINE vrowid       integer;
--    DEFINE pfecha	date;    

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      LET cMensaje="Error informix";
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   let vrowid       = 0;
   LET cMensaje="Proceso Exitoso";
   LET cCodRet='000';
   let pmovtos = 0;

-- SET DEBUG FILE TO "/pisa/cas/sp_mueve_movdia.out";
-- TRACE ON;

   LET cCodRet='000';
   set isolation to dirty read;
   set lock mode to wait 3;

--set pdqpriority 15;

   FOREACH cursor_borra WITH HOLD FOR
        select secuencia
         into vrowid
         from bdicred:sd_movdia
        where empresa = pEmpresa
        and num_credito matches '610*'
	and fecha_mov<>today

           BEGIN WORK;
              insert into bdicred:sd_movhiscrd
              select * from bdicred:sd_movdia where secuencia = vrowid;

              DELETE FROM bdicred:sd_movdia WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
        
   END FOREACH;


   FOREACH cursor_borra WITH HOLD FOR
        select secuencia
         into vrowid
         from bdicred:sd_movdia
        where empresa = pEmpresa
        and num_credito matches '610*'
	and fecha_mov=today

           BEGIN WORK;
              insert into bdicred:sd_movdiacrd
              select * from bdicred:sd_movdia where secuencia = vrowid;

              DELETE FROM bdicred:sd_movdia WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
        
   END FOREACH;

  END;
 RETURN cCodRet,cMensaje;

END PROCEDURE;