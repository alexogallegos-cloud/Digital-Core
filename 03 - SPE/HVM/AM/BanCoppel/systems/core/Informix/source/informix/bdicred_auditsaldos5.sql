create procedure "informix".auditsaldos5(pempresa char(3))
returning char(5);


define vcodret         char(5);
define vNumCredito     char(20);
define vsqlerr         Integer;
define vMtoVencido     money(14,2);
define vMtoFinan       money(14,2);
define vCuotas         integer;


-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

  --set debug file to "audita.out";
  --trace on;



  let vcodret         = "000";
  let vNumCredito     = '';
  let vMtoVencido     = 0;
  let vMtoFinan       = 0;
  let vCuotas         = 0;

--Creditos Transitorios


  FOREACH

        SELECT num_credito INTO vNumCredito FROM sd_maecred WHERE empresa = pempresa and status_cred = 'BA' 

       SELECT count(*) INTO vCuotas FROM sd_amortiza_credito  WHERE  empresa = pempresa and
                       num_credito = vNumCredito and capital_status in ('7','2');

       IF vCuotas = 0 THEN
              SELECT monto_vencido, monto_financiado INTO vMtoVencido, vMtoFinan FROM sd_maesdos
              WHERE num_credito = vNumCredito and empresa = pempresa;

              UPDATE sd_amortiza_credito SET   capital_mto_cuota = vMtoFinan - vMtoVencido,
                                               capital_debe      = vMtoFinan - vMtoVencido,
                                               capital_pagado    = 0,
                                               capital_status    = 7
              WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '03/20/2008';

              UPDATE sd_amortiza_credito SET   capital_mto_cuota =  vMtoVencido,
                                               capital_debe      =  vMtoVencido,
                                               capital_pagado    = 0,
                                               capital_status    = 1
              WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '04/20/2008';

        END IF;

  END FOREACH;


  FOREACH

       SELECT count(*),num_credito INTO vCuotas, vNumCredito FROM sd_amortiza_credito  WHERE  empresa = pempresa and
              num_credito  in (SELECT num_credito FROM sd_maecred WHERE empresa = pempresa and
                               status_cred = 'AA') and
              capital_status in ('7','2')
       GROUP BY 2

       IF vCuotas > 0 THEN
              SELECT monto_vencido, monto_financiado INTO vMtoVencido, vMtoFinan FROM sd_maesdos
              WHERE num_credito = vNumCredito and empresa = pempresa;

              UPDATE sd_amortiza_credito SET   capital_status_ant = capital_status,
                                               capital_status = '5'
              WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota !='04/20/2008' and capital_status in ('7','2') ;
              IF vMtoVencido > 0 THEN
                  UPDATE sd_amortiza_credito SET   capital_mto_cuota =  vMtoFinan,
                                                   capital_debe      =  vMtoFinan,
                                                   capital_pagado    = 0,
                                                   capital_status    = 1
                 WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota ='04/20/2008';
              ELSE
                 UPDATE sd_amortiza_credito SET  capital_status    = 5
                 WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota ='04/20/2008';
              END IF;
       END IF;
  END FOREACH;

  FOREACH

       SELECT num_credito INTO  vNumCredito FROM sd_maecred  WHERE  empresa = pempresa and status_cred = 'AA'

       UPDATE sd_maecredanexo set fecha_vencto = ''
       WHERE num_credito = vNumCredito and empresa = pempresa;

  END FOREACH;


  RETURN vcodret;
END
end procedure
;