create procedure "informix".actminimo(pempresa char(3))
returning char(5);


define vcodret         char(5);
define vnum_credito    char(20);
define vsqlerr         Integer;
DEFINE vBegin          CHAR(1);
DEFINE vMtoPag         DECIMAL(14,2);
DEFINE vMtoPag1        DECIMAL(14,2);
DEFINE vCapInsoluto    DECIMAL(14,2);
DEFINE vSdo    DECIMAL(14,2);
DEFINE vMtoVencido     DECIMAL(14,2);
DEFINE MtoVencTrasp    DECIMAL(14,2);
DEFINE MontoFinanciado DECIMAL(14,2);
DEFINE SdoTrab4        DECIMAL(14,2);
DEFINE vMaxMinimo      DECIMAL(14,2);

-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      IF vBegin = "S" THEN
         ROLLBACK WORK;
      END IF;
      RETURN vcodret;
   END IF;
END EXCEPTION;

 -- set debug file to "actminimo.out";
 -- trace on;



  LET vBegin          = "?";
  let vnum_credito    = "";
  let vcodret         = "000";
  let vMtoPag         = 0;
  let vMtoPag1        = 0;
  let vCapInsoluto    = 0;
  let MtoVencTrasp    = 0;
  let vMtoVencido     = 0;
  let MontoFinanciado = 0;
  let SdoTrab4        = 0;
  let vMaxMinimo      = 0;
let vSdo    = 0;


--Creditos Vigentes


FOREACH WITH HOLD


  SELECT num_credito,sdo_cap_insoluto  INTO vnum_credito,vSdo FROM sd_maesdos WHERE empresa = '001' 
--and
--         num_credito in ('600000005089','600000005246','600000005329')

  SELECT sum(monto) INTO vMtoPag FROM sd_movhis b
  WHERE  b.empresa = pempresa and b.num_credito = vnum_credito and  fecha_mov >= '05/21/2008'  and fecha_mov <= '06/20/2008' and
         codigo_fun  in ('033','334') and codigo_ref in (7,8,9,10,901) and reversado = 'N';

  SELECT sum(monto) INTO vMtoPag1 FROM sd_movdia b
  WHERE  b.empresa = pempresa and b.num_credito = vnum_credito and  fecha_mov = '06/21/2008'  and
         codigo_fun  in ('033','334') and codigo_ref in (7,8,9,10,901)  and reversado = 'N';

  SELECT sdo_cap_insoluto,monto_vencido,mto_venc_trasp INTO vCapInsoluto,vMtoVencido,MtoVencTrasp FROM sd_maesdoshist
  WHERE fecha ='05/20/2008' and empresa = '001'  and num_credito = vnum_credito;

  IF vMtoPag Is Null THEN
    LET vMtoPag = 0;
  END IF;
  IF vMtoPag1 Is Null THEN
    LET vMtoPag1 = 0;
  END IF;

 BEGIN WORK;
  LET vBegin = "S";

   IF vMtoPag >= vCapInsoluto   THEN
      IF vSdo <= 0 THEN
         Let SdoTrab4 = 0;
         Let MontoFinanciado = SdoTrab4 - vMtoPag1;
      ELSE
         IF vSdo <= 40.00 THEN
           Let SdoTrab4 = vSdo;
         ELSE
           LET SdoTrab4 = round((vSdo / 10)-0);
           IF SdoTrab4 < 40 THEN
              Let SdoTrab4 = 40;
           END IF;
         END IF;
         Let SdoTrab4 = SdoTrab4 ;
         Let MontoFinanciado = SdoTrab4 - vMtoPag1;
      END IF;
       UPDATE sd_amortiza_credito SET capital_mto_cuota  = MontoFinanciado,
                                      capital_debe       = MontoFinanciado,
                                      capital_pagado      = vMtoPag1
       WHERE empresa = '001' and num_credito = vnum_credito and fecha_cuota = '06/20/2008';

       UPDATE sd_maesdoshist set monto_financiado = SdoTrab4,
                                         sdo_trab4 = SdoTrab4,
                                 mto_fin_vig_trasp= 1
       WHERE fecha = '06/20/2008' and empresa = '001' and num_credito = vnum_credito;

       UPDATE sd_maesdos set   monto_financiado = MontoFinanciado,
                                      sdo_trab4 = SdoTrab4
       WHERE empresa = '001' and num_credito = vnum_credito;

  END IF;
   IF vSdo <= 0 THEN
       UPDATE sd_amortiza_credito SET capital_mto_cuota  = 0,
                                      capital_debe       = 0,
                                      capital_pagado      = 0
       WHERE empresa = '001' and num_credito = vnum_credito and fecha_cuota = '06/20/2008';

       UPDATE sd_maesdoshist set monto_financiado = 0,
                                         sdo_trab4 = 0,
                                 mto_fin_vig_trasp= 1
       WHERE fecha = '06/20/2008' and empresa = '001' and num_credito = vnum_credito;

       UPDATE sd_maesdos set   monto_financiado = 0 - vMtoPag1,
                                      sdo_trab4 = 0
       WHERE empresa = '001' and num_credito = vnum_credito;

  END IF;
  COMMIT WORK;
  LET vBegin ="N";
end foreach
return vcodret;

end
end procedure
;