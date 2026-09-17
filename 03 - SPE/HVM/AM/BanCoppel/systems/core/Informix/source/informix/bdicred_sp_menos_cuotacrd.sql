CREATE PROCEDURE "informix".sp_menos_cuotacrd(p_Empresa     CHAR(3),
                                           p_NumCredito  CHAR(20),
                                           p_Monto       MONEY(14,2))

   RETURNING CHAR(5),     -- Codigo de Retorno
             CHAR(40); -- Remanente

   DEFINE GLOBAL g_SdoRetenido     MONEY(14,2)   DEFAULT 0;
   DEFINE GLOBAL vSucursal          CHAR(4)      DEFAULT ' ';
   DEFINE GLOBAL vDivisa            CHAR(2)      DEFAULT ' ';
   DEFINE GLOBAL vNumProducto      CHAR(4)      DEFAULT ' ';
   DEFINE GLOBAL g_Folio           CHAR(16)      DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;



   DEFINE  CodRet            CHAR(5);
   DEFINE  v_fcuota          DATE;
   DEFINE  vMtoPagado        MONEY(14,2);
   DEFINE  vMensaje          CHAR(40);
   DEFINE  vFecha            DATE;
   DEFINE  vMtoInteres       MONEY(14,2);
   DEFINE  vNumPag           INTEGER;
   DEFINE   vStatus           CHAR(1);

--   SET DEBUG FILE TO "/tmp/menoscuota.out";
--   TRACE ON;

   LET CodRet     = "000";
   LET vMensaje   = '';
   LET vFecha     = '';
   LET vNumPag    = 0;
   LET vStatus    = '';



   SELECT fecha_hoy INTO vFecha FROM sd_fechas WHERE empresa = p_Empresa;

   SELECT min(fecha_cuota) INTO v_fcuota FROM sd_amortiza_creditocrd
   WHERE empresa = p_Empresa and num_credito = p_NumCredito and
         capital_status  = 1;

   SELECT sum(capital_debe - capital_pagado) INTO  vMtoPagado FROM sd_amortiza_creditocrd
   WHERE empresa = p_Empresa and num_credito = p_NumCredito and
         capital_status  = 1 and fecha_cuota = v_fcuota;

   --CALL CobraCapVigentecrd (v_fcuota) RETURNING CodRet;   --**Pago Prox. Cuota A Vencer
--   CALL CobraCapVigAnticipcrd(v_fcuota,p_Empresa,p_NumCredito,vRemanente) RETURNING CodRet,vRemanente;

   IF g_Remanente > 0 THEN
         FOREACH WITH HOLD
               SELECT fecha_cuota,interes_debe,interes_status_ant  INTO v_fcuota,vMtoInteres,vStatus FROM sd_amortiza_creditocrd
               WHERE empresa = p_Empresa and num_credito = p_NumCredito and
                     capital_status  = 1 and fecha_cuota >= vFecha
               Order by fecha_cuota
               IF vNumPag = 0  and vMtoInteres > 0  and vStatus = '1' THEN
                  CALL CobraIntVigAnticipcrd(v_fcuota,p_Empresa,p_NumCredito,g_Remanente) RETURNING CodRet,g_Remanente;
                   IF CodRet <> '000' THEn
                     Return CodRet,g_Remanente;
                  ELSe
                    Let vNumPag  = vNumPag + 1;
                    UPDATE sd_amortiza_creditocrd set interes_debe = interes_debe + g_SdoRetenido,
                                                   interes_status = '1',
                                                   interes_status_ant = '5'
                    WHERE num_credito = p_Numcredito and empresa = p_Empresa and fecha_cuota = v_fcuota;
                    UPDATE sd_maesdoscrd set sdo_no_exig      = sdo_no_exig + g_SdoRetenido,
                                          provision_normal = provision_normal + g_SdoRetenido
                    WHERE num_credito = p_Numcredito and empresa = p_Empresa ;
                  END IF;
               ELSe
                   LET vNumPag = 2;
               END IF;
         END FOREACH;
     END IF;

{
   IF g_Remanente > 0 THEN
            update sd_maesdoscrd set sdo_capital      = sdo_capital - g_Remanente,
                                  sdo_cap_insoluto = sdo_cap_insoluto - g_Remanente,
                                  abonos_mes_cap   = abonos_mes_cap + g_Remanente
            where empresa = p_empresa and num_credito = p_NumCredito;
           CALL sp_reestruc_pagocrd(p_Empresa,p_NumCredito,vFecha,'01','S') RETURNING CodRet,vMensaje;

           CALL GenMov(p_empresa, p_NumCredito, vNumProducto,17,
                      '033', vFecha, vRemanente, g_Folio,
                      vSucursal, vDivisa, '0000')
            RETURNING CodRet, vMensaje;
            LET g_Remanente = 0;
   END IF;
}
END PROCEDURE
;