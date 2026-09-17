create procedure "informix".act_amocuota(pempresa char(3))
returning char(5);



DEFINE vcodret       char(5);
DEFINE vsqlerr       smallint;
DEFINE vNumCredito   char(20);
DEFINE vSdoNoExig    decimal(14,2);
DEFINE vIva          decimal(14,2);
DEFINE vMtoVencido   decimal(14,2);
DEFINE vMtoFinanciado decimal(14,2);
DEFINE vMtoPagado     decimal(14,2);
DEFINE vStatus       char(1);





-- CONTROL DE ERRORES
BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr != 0 THEN
         LET vcodret=vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

-- set debug file to "act_amocuota.out";
-- trace on;

   let vcodret       = "000";
   let vNumCredito   = '';
   let  vSdoNoExig   = 0;
   let  vIva         = 0;
   let  vMtoVencido  = 0;
   let vStatus       = '';
   let vMtoFinanciado= 0;
   let vMtoPagado    = 0;


  -- Credito Transitorios



   FOREACH WITH HOLD
         select a.num_credito, b.monto_financiado, (a.monto_financiado - b.monto_financiado), b.monto_vencido
         into vNumCredito,vMtoFinanciado,vMtoPagado,vMtoVencido
         from bdicred:sd_maesdoshist a,
              bdicred:sd_maesdos b
         where a.empresa = b.empresa
          and a.num_credito = b.num_credito
          and a.monto_vencido = b.monto_vencido
          and a.monto_vencido > 0
          and (a.monto_financiado - b.monto_financiado) < a.monto_vencido
          and b.monto_financiado > 0
          and a.monto_financiado <> b.monto_financiado
          and a.fecha = '06/20/2008'

	  begin work; 

          UPDATE sd_amortiza_credito SET capital_pagado = vMtoPagado
          WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '05/20/2008';


          UPDATE sd_amortiza_credito SET capital_status     = '5',
                                         capital_pagado     = capital_debe
          WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '04/20/2008';

          UPDATE sd_maesdos set sdo_capital   = sdo_capital + vMtoPagado,
                                monto_vencido = monto_vencido - vMtoPagado
          WHERE empresa = pempresa and num_credito = vNumCredito;

	 commit work; 


 END FOREACH;

   FOREACH WITH HOLD
         select a.num_credito, b.monto_financiado, (a.monto_financiado - b.monto_financiado), b.monto_vencido
         into vNumCredito,vMtoFinanciado,vMtoPagado,vMtoVencido
         from bdicred:sd_maesdoshist a,
              bdicred:sd_maesdos b
         where a.empresa = b.empresa
          and a.num_credito = b.num_credito
          and a.monto_vencido = b.monto_vencido
          and a.monto_vencido > 0 and (((a.monto_financiado - b.monto_financiado) >=a.monto_vencido
          and b.monto_financiado > 0) OR  b.monto_financiado  <= 0)
          and a.monto_financiado <> b.monto_financiado
          and a.fecha =  '06/20/2008'


  	  begin work; 
 

           UPDATE sd_amortiza_credito SET capital_status     = '5',
                                         capital_status_ant = '7',
                                         capital_pagado     = capital_debe
          WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '05/20/2008';


          UPDATE sd_amortiza_credito SET capital_status     = '5',
                                         capital_pagado     = capital_debe
          WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '04/20/2008';


          UPDATE sd_maesdos set sdo_capital   = sdo_capital + monto_vencido,
                                monto_vencido = 0
          WHERE empresa = pempresa and num_credito = vNumCredito;

          UPDATE sd_maecred set status_cred = 'AA'
          WHERE empresa = pempresa and num_credito = vNumCredito;

          UPDATE sd_maecredanexo set fecha_vencto = Null
          WHERE empresa = pempresa and num_credito = vNumCredito;

 	  commit work; 


 END FOREACH;

  -- Creditos Vigentes
   FOREACH WITH HOLD

           SELECT a.num_credito INTO vNumCredito
                  from bdicred:sd_maecred a
                  where empresa = '001'
                 and (select count(*) from bdicred:sd_amortiza_credito 
                      where a.empresa = empresa 
                        and a.num_credito = num_credito 
                        and capital_status = '1' 
                        and fecha_cuota < '06/20/2008') > 0
                      and status_cred = 'AA'

          begin work;

          UPDATE sd_amortiza_credito SET capital_status     = '5',
                                         capital_status_ant = '1'
          WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '05/20/2008';

 	  commit work;


   END FOREACH;

--** Vencidos
   FOREACH WITH HOLD

           SELECT a.num_credito INTO vNumCredito
                  from bdicred:sd_maecred a
                  where empresa = '001'
                 and (select count(*) from bdicred:sd_amortiza_credito 
                      where a.empresa = empresa 
                        and a.num_credito = num_credito 
                        and capital_status = '1' 
                        and fecha_cuota < '06/20/2008') > 0
                      and status_cred = 'BT'

   	  begin work;


          UPDATE sd_amortiza_credito SET capital_status = '2',
                                         capital_status_ant = ''
          WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '05/20/2008';


	  commit work;

  END FOREACH;


  return vcodret;
END
END PROCEDURE
;