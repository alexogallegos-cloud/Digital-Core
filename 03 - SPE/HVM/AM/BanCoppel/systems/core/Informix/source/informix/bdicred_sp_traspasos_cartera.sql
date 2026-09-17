CREATE PROCEDURE "informix".sp_traspasos_cartera(eEmpresa CHAR(3),
                                                 eNumCred     CHAR(20),
			                         eNumProducto CHAR(4),
				                 eFolio       CHAR(16),
				                 eSucursal    CHAR(4),
				                 eDivisa      CHAR(2),
                                                 ePlaza       CHAR(3))

  RETURNING CHAR(3)      ,    --CodRet
            CHAR(1)     ,    --TrasHoy
            DATe         ,    --FechaCota
            DECIMAL(14,2),    --Mto. Vencido
            MONEY(14,2)  ,    --Cap.Vig.No Vencido
            MONEY(14,2)  ;    --Monto Venc. Exig

   --** Variables Globales

   DEFINE GLOBAL FechaHoy      DATE          DEFAULT NULL;
   DEFINE GLOBAL FechaAnt      DATE          DEFAULT NULL;
   DEFINE GLOBAL ProxFecha     DATE          DEFAULT NULL;
   DEFINE GLOBAL PriDiaMes     DATE          DEFAULT NULL;
   DEFINE GLOBAL PriHabMes     DATE          DEFAULT NULL;
   DEFINE GLOBAL UltDiaMes     DATE          DEFAULT NULL;
   DEFINE GLOBAL UltHabMes     DATE          DEFAULT NULL;
   DEFINE GLOBAL FecPagFira    DATE          DEFAULT NULL;
   DEFINE GLOBAL vFechaVenc    DATE          DEFAULT " ";
   DEFINE GLOBAL DiasProvMa    SMALLINT      DEFAULT 0;
   DEFINE GLOBAL DiasProvMaFm  SMALLINT      DEFAULT 0;
   DEFINE GLOBAL DiasProvPm    SMALLINT      DEFAULT 0;
   DEFINE GLOBAL DiasCalc      SMALLINT      DEFAULT 0;
   DEFINE GLOBAL DiasTraspIC   SMALLINT      DEFAULT 0;
   DEFINE GLOBAL vDiasTrasp    SMALLINT      DEFAULT 0;
   DEFINE GLOBAL DiasAcumMora  SMALLINT      DEFAULT 0;
   DEFINE GLOBAL StatusCred    CHAR(2)       DEFAULT '';
   DEFINE GLOBAL CapTrasNoVenc DECIMAL(14,2) DEFAULT 0;
   DEFINE GLOBAL IntTraNoExig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL MtoVencTraInt       MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL MtoVencTrasp       MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL SdoExigInt    MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL SdoNoExig     MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL SdoCapital    MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL MontoVencido  MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL MtoVencInt    MONEY(14,2)   DEFAULT 0;
   DEFINE  vMtoIntVenc    MONEY(14,2);
   DEFINE  TrasHoy        CHAR(1);
   DEFINE  VencTrasp      MONEY(14,2);
   DEFINE CodRet              CHAR(5);
   DEFINE error_info          CHAR(40);
   DEFINE Transacc            CHAR(4);
   DEFINE rLog		      SMALLINT;
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE vFechaCuota	      DATE;
   DEFINE vMtoVencido         DECIMAL(14,2);
   DEFINE vMensaje            VARCHAR(200,1);
   DEFINE Mensaje             VARCHAR(200,1);
   DEFINE vCapVigente         DECIMAL(14,2);
   DEFINE VMontoVencido       MONEY(14,2);
   DEFINE vProvParaTraspaso   DECIMAL(14,2);
   DEFINE vIvaSuc             CHAR(5);
   DEFINE vcuotaint         MONEY(14,2);
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
   END EXCEPTION WITH RESUME;

  --Asignacion De Variables

   LET CodRet            = '000';
   LET vFechaCuota       = '';
   LET vMtoVencido       = 0;
   LET vMensaje          = '';
   LET Mensaje           = '';
   LET Transacc          ='0000';
   LET rLog	         = 0;
   LET vCapVigente       = 0;
   LET vDiasTrasp        = vDiasTrasp;
   LET DiasAcumMora      = DiasAcumMora;
   LET VMontoVencido     = 0;
   LET vProvParaTraspaso = 0;
   LET  TrasHoy          = 'N';
   LET  VencTrasp        = 0;
   LET  vFechaCuota      = NULL;
   LET  vMtoIntVenc      = 0;
   LET  vMontoVencido     = 0;
   
-- OBTIENE I.V.A DEL SD_PARAM
   SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
   WHERE cod_param = "12"
   AND empresa = eEmpresa;


   select nvl(monto_vencido,0),nvl(provision_normal ,0)
   into vMontoVencido,  vProvParaTraspaso
   FROM sd_maesdoscrd
   WHERE empresa     = eEmpresa AND
         num_credito = eNumCred;

   if vMontoVencido is null then let vMontoVencido = 0; end if;             
   SELECT fecha_cuota, NVL((capital_debe - capital_pagado),0),
      NVL((interes_debe - interes_pagado),0)
     INTO vFechaCuota, vMtoVencido,vcuotaint
     FROM sd_amortiza_creditocrd
    WHERE empresa    = eEmpresa  AND
          num_credito    = eNumCred  AND
          fecha_cuota    = FechaHoy  AND
          capital_debe <> capital_pagado;

   IF vMtoVencido IS NULL THEN
         LET vMtoVencido = 0;
         LET vMontoVencido = 0;
   END IF

   -- Traspaso De Cartera Vigente  a Transitoria

   IF (vMtoVencido > 0  OR vcuotaint > 0 )AND StatusCred in('AA','BA')    THEN
            LET vMensaje     = "Traspaso a Transitorio ";
            LET vFechaVenc   = vFechaCuota;
            LET StatusCred   ="BA";
            LET TrasHoy      = "S";
            LET SdoExigInt   = SdoExigInt + SdoNoExig ;
            LET MontoVencido = MontoVencido + vMtoVencido;
            LET SdoCapital   = SdoCapital - vMtoVencido;

                           -- Mov. Contable De Capital Vigente A Transitorio
            CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,3,
                              '602', FechaHoy, vMtoVencido , eFolio,
                              eSucursal, eDivisa, '0000',ePlaza)
            RETURNING CodRet, vMensaje;

            IF (CodRet <> "00000") THEN
                 ROLLBACK WORK;
                 LET vMensaje = TRIM(vMensaje) || " (GENMOV)";
                 CALL log_cierre (eEmpresa, eNumCred, CodRet, FechaHoy, vMensaje)
                 RETURNING rLog;
                 IF rLog > 0 THEN
                        RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,CapTrasNoVenc ,MtoVencTraInt;
                 END IF
            ELSE
                 LET CodRet = "000";
            END IF
                                  -- Mov. Contables De Interes Vigente A Transitorio
            IF SdoNoExig >  0 and vcuotaint > 0 Then
                   CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,4,
                                     '605', FechaHoy, SdoNoExig , eFolio,
                                     eSucursal, eDivisa, '0000',ePlaza)
                   RETURNING CodRet, vMensaje;
                   IF (CodRet <> "00000") THEN
                        ROLLBACK WORK;
                        LET vMensaje = 'Traspaso De Interes Vigente a Transitorio';
                        LET vMensaje = TRIM(vMensaje) || " (GENMOV)";
                        CALL log_cierre (eEmpresa, eNumCred, CodRet, FechaHoy, vMensaje)
                        RETURNING rLog;
                        IF rLog > 0 THEN
                           RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,CapTrasNoVenc ,MtoVencTraInt;
		        END IF
                  ELSE
                        LET CodRet = "000";
                  END IF;
                  LET  SdoNoExig = 0;  

             END IF
             IF vProvParaTraspaso > 0 THEN
                   --Provision de Interes Vigente
                  CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,3,
                       '606', FechaHoy, vProvParaTraspaso , eFolio,
                       eSucursal, eDivisa, '0000',ePlaza)
                  RETURNING CodRet, vMensaje;
                  --Iva de Provision Vigente
                  CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,24,
                                    '222', FechaHoy, vProvParaTraspaso * vIvaSuc , eFolio,
                                    eSucursal, eDivisa, '0000',ePlaza)
                  RETURNING CodRet, vMensaje;
                  IF (CodRet <> "00000") THEN
                        ROLLBACK WORK;
                        LET vMensaje = 'Traspaso De Interes Vigente a Transitorio';
                        LET vMensaje = TRIM(vMensaje) || " (GENMOV)";
                        CALL log_cierre (eEmpresa, eNumCred, CodRet, FechaHoy, vMensaje)
                        RETURNING rLog;
                        IF rLog > 0 THEN
                           RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,CapTrasNoVenc ,MtoVencTraInt;
		        END IF
                 ELSE
                        LET CodRet = "000";
                 END IF;
             END IF;

             UPDATE sd_maecredcrd set status_cred = StatusCred
             WHERE empresa = eEmpresa
               AND num_credito = eNumCred;

             UPDATE sd_amortiza_creditocrd SET capital_status = "7"
             WHERE empresa = eEmpresa        AND
                   num_credito = eNumCred    AND
                   fecha_cuota = vFechaCuota AND
                   capital_debe <> capital_pagado;

             UPDATE sd_amortiza_creditocrd SET interes_status = '7'
             WHERE empresa = eEmpresa        AND
                   num_credito = eNumCred    AND
                   fecha_cuota = vFechaCuota AND
                   interes_debe <> interes_pagado;
           
       -- Traspaso De Cartera Transitorio A Vencido

   ELIF DiasAcumMora >= vDiasTrasp  and StatusCred not in('VP','BT') THEN
        LET vMtoVencido = 0;
        SELECT sum(capital_debe - capital_pagado)
        INTO vCapVigente
        FROM sd_amortiza_creditocrd
        WHERE empresa = eEmpresa AND
              num_credito = eNumCred AND
              fecha_cuota >= FechaHoy AND
              capital_status = "1"    AND
              capital_debe <> capital_pagado;

        IF vCapVigente Is Null THEN LET vCapVigente = 0; END IF;
        IF SdoNoExig   Is Null THEN LET SdoNoExig   = 0; END IF;
        LET CapTrasNoVenc = 0;
        LET StatusCred    = 'BT';
        LET TrasHoy       = "S";
        LET MtovencTrasp  = MtovencTrasp + vMtoVencido;
        LET MtoVencTraInt = SdoExigInt   + SdoNoExig;
        LET MtoVencTrasp  = MontoVencido + vMtoVencido;
        LET VencTrasp     = MtoVencTrasp;
        LET CapTrasNoVenc =  vCapVigente;
        LET SdoExigInt    = SdoExigInt ;
        LET SdoNoExig     = SdoNoExig;
        LET MontoVencido  = MontoVencido;

        --**Mov. Contables De Interes Transitorio A Vencido
        IF SdoExigInt > 0 THEN
           CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,1,
                '603', FechaHoy, SdoExigInt , eFolio,
                eSucursal, eDivisa, '0000',ePlaza)
           RETURNING CodRet, vMensaje;
           IF (CodRet <> "00000") THEN
	       ROLLBACK WORK;
               LET vMensaje = TRIM(vMensaje)||" Vigente a Vencido(GENMOV)";
               CALL log_cierre (eEmpresa, eNumCred, CodRet, FechaHoy, vMensaje)
               RETURNING rLog;
               IF rLog > 0 THEN
                  RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,CapTrasNoVenc ,MtoVencTraInt;
	       END IF
           ELSE
              LET CodRet = "000";
           END IF;

        END IF;
        --**Mov. Contables De Interes Vigente A Vencido **--
        IF SdoNoExig > 0 and StatusCred <> 'VP' THEN
           CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,3,
                '604', FechaHoy, SdoNoExig , eFolio,
                eSucursal, eDivisa, '0000',ePlaza)
           RETURNING CodRet, vMensaje;
           IF (CodRet <> "00000") THEN
              ROLLBACK WORK;
              LET vMensaje = TRIM(vMensaje)||" Vigente a Vencido(GENMOV)";
              CALL log_cierre (eEmpresa, eNumCred, CodRet, FechaHoy, vMensaje)
              RETURNING rLog;
              IF rLog > 0 THEN
                 RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,CapTrasNoVenc ,MtoVencTraInt;
              END IF
           ELSE
              LET CodRet = "000";
           END IF;
        END IF;
        --**Mov. Contables De Capital Transitorio A Vencido
        IF MontoVencido > 0 THEN
           CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,4,
                '601', FechaHoy, MontoVencido,eFolio,
                eSucursal, eDivisa, '0000',ePlaza)
           RETURNING CodRet, vMensaje;
           IF (CodRet <> "00000") THEN
	      ROLLBACK WORK;
              LET vMensaje = TRIM(vMensaje)||" Vigente a Vencido(GENMOV)";
              CALL log_cierre (eEmpresa, eNumCred, CodRet, FechaHoy, vMensaje)
              RETURNING rLog;
              IF rLog > 0 THEN
                 RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,CapTrasNoVenc ,MtoVencTraInt;
	      END IF
           ELSE
              LET CodRet = "000";
           END IF;
        END IF;
        --**Mov. Contables De Capital Vigente A Vencido
        IF vCapVigente > 0 THEN
           CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,2,
                '602', FechaHoy, vCapVigente,eFolio,
                eSucursal, eDivisa, '0000',ePlaza)
                RETURNING CodRet, vMensaje;
           IF (CodRet <> "00000") THEN
	      ROLLBACK WORK;
              LET vMensaje = TRIM(vMensaje)||" Vigente a Vencido(GENMOV)";
              CALL log_cierre (eEmpresa, eNumCred, CodRet, FechaHoy, vMensaje)
              RETURNING rLog;
              IF rLog > 0 THEN
                 RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,CapTrasNoVenc ,MtoVencTraInt;
	      END IF
           ELSE
              LET CodRet = "000";
           END IF;
        END IF;
        UPDATE sd_maecredcrd set status_cred = StatusCred
        WHERE num_credito = eNumCred;

        UPDATE sd_amortiza_creditocrd
        SET interes_status = DECODE(interes_status,"7","2","1","3",'5','5'),
            interes_status_ant = interes_status ,
            capital_status = DECODE(capital_status,"7","2","1","3",'5','5'),
            capital_status_ant = capital_status
        WHERE empresa     = eEmpresa
        AND num_credito = eNumCred ;
     --** Traspado De Cap. Vencido No Exigible a Exigible

  ELIF StatusCred in ('VP','BT') THEN
       SELECT fecha_cuota, NVL((capital_debe - capital_pagado),0),
              NVL((interes_debe - interes_pagado),0)
       INTO vFechaCuota, vMtoVencido,vMtoIntVenc
       FROM sd_amortiza_creditocrd
       WHERE empresa    = eEmpresa  AND
             num_credito    = eNumCred  AND
             fecha_cuota    = FechaHoy  AND
             capital_status in('2','3');

       IF vMtoVencido IS NULL THEN
          LET vMtoVencido = 0;
       END IF

       IF vFechaCuota = FechaHoy THEN

          IF vProvParaTraspaso > 0 THEN
             CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,2,
                       '606', FechaHoy, vProvParaTraspaso , eFolio,
                       eSucursal, eDivisa, '0000',ePlaza)
             RETURNING CodRet, vMensaje;
             LET MtoVencTraInt = MtoVencTraInt + vMtoIntVenc;
             LET IntTraNoExig = 0;
             --Provisiona el IVA
             CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,25,
                       '222', FechaHoy, vProvParaTraspaso * vIvaSuc , eFolio,
                       eSucursal, eDivisa, '0000',ePlaza)
             RETURNING CodRet, vMensaje;
          END IF;
       END IF;
       IF vMtoIntVenc > 0 THEN
          LET MtoVencTraInt = vMtoIntVenc; --MtoVencTraInt + vMtoIntVenc;
          LET IntTraNoExig = 0;
       END IF;

       IF vMtoVencido > 0 THEN
          LET TrasHoy       = "S";
          LET MtoVencTrasp  = MtoVencTrasp + vMtoVencido;
          LET CapTrasNoVenc = CapTrasNoVenc - vMtoVencido;
          let vMontoVencido = 0;
          --LET vMtoVencido   = 0;
          CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,4,
               '601', FechaHoy, vMtoVencido,eFolio,
               eSucursal, eDivisa, '0000',ePlaza)
          RETURNING CodRet, vMensaje;
          IF (CodRet <> "00000") THEN
             ROLLBACK WORK;
             LET vMensaje = TRIM(vMensaje)||"Cap. Venc. No Exig.A Exig. ";
             CALL log_cierre (eEmpresa, eNumCred, CodRet, FechaHoy, vMensaje)
             RETURNING rLog;
             IF rLog > 0 THEN
                RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,
                       CapTrasNoVenc ,MtoVencTraInt;
             END IF
          ELSE
             -- Traspaso de Interes Vencido
             IF MtoVencTraInt > 0 and StatusCred <> 'VP' THEN
                -- Checar la Transaccion de Intereses Traspasos
                CALL genmovcierre_movdia(eEmpresa, eNumCred, eNumProducto,3,
                  '604', FechaHoy, MtoVencTraInt,eFolio,
                  eSucursal, eDivisa, '0000',ePlaza)
                RETURNING CodRet, vMensaje;
                if (cODrET <> "00000") THEN
                   ROLLBACK WORK;
                   LET vMensaje = TRIM(vMensaje)||"Cap. Venc. No Exig.A Exig. ";
                   CALL log_cierre (eEmpresa, eNumCred, CodRet, FechaHoy, vMensaje)
                   RETURNING rLog;
                   IF rLog > 0 THEN
                     RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,
                          CapTrasNoVenc ,MtoVencTraInt;
                   END IF;
                END IF
             END IF;

             -- Aqui le Le Busco el estado de la Cuota Correspondiente
             UPDATE sd_amortiza_creditocrd
             SET interes_status = DECODE(interes_status,"7","2","3","2","5","5"),
                 capital_status = DECODE(capital_status,"7","2","3","2","5","5")
             --UPDATE sd_amortiza_creditocrd SET capital_status = '2', MEL 23092009
            --                                  interes_status = '2'
             WHERE empresa = eEmpresa    AND
                   num_credito = eNumCred    AND
                   fecha_cuota = vFechaCuota AND
                   capital_debe <> capital_pagado;
             LET CodRet = "000";
          END IF;
       END IF;
  END IF

  RETURN CodRet,TrasHoy, vFechaCuota,vMtoVencido,CapTrasNoVenc ,MtoVencTraInt;

END PROCEDURE ;