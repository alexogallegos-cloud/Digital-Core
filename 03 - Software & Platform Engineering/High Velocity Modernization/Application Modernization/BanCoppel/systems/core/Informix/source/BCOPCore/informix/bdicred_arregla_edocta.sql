CREATE PROCEDURE "informix".arregla_edocta()
     RETURNING CHAR(5);

--// ***************************************************************************
--// Actualiza registros de transparencia
--// ***************************************************************************

--//Definicion de variables
DEFINE vnumcredito  CHAR(20);
DEFINE vmonto       DECIMAL(14,2);
DEFINE vmonto2      DECIMAL(14,2);
DEFINE vcodigoref   INTEGER;
DEFINE vchrcodret   CHAR(5);
DEFINE vintcodret   INTEGER;
DEFINE vetiqueta    CHAR(50);
DEFINE v_cl_cobra     VARCHAR(60,1);


LET vnumcredito = '';
LET vchrcodret = '';
LET vetiqueta = '';
LET vmonto = 0.0;
LET vmonto2 = 0.0;
LET vcodigoref = 0;
LET vintcodret = 0;
LET v_cl_cobra ='';

BEGIN
    ON EXCEPTION SET vintcodret
    	IF vintcodret <> 0 THEN
           rollback work;
    	   LET vchrcodret = vintcodret;
           RETURN vchrcodret;
    	END IF;
    END EXCEPTION;

    --//DEBUG FLAG
--    SET debug file to "/tmp/actedocta.out";
--    TRACE ON;

    --//Actualiza etiquetas de moratorios
--    FOREACH WITH HOLD
--        select num_credito , monto, codigo_ref 
--          into vnumcredito , vmonto, vcodigoref 
--          from bdicred:sd_movhisedocta 
--         where empresa = '001' 
--           and ( usuario = 'BC426807' or usuario = 'BI426807') 
--           and ((codigo_fun = '340' and codigo_ref =  25)  or (codigo_fun = '033' and codigo_ref =  2))
--
--           begin work;
--
--           if (vcodigoref = 25) then
--               let vetiqueta = 'IVA DE INT MORA';
--           else
--               let vetiqueta = 'INTERESES MORATORIOS';
--           end if;
--
--           UPDATE bdicred:sd_detalle_edocta
--              set concepto = vetiqueta
--            where fecha_emision = mdy('10','20','2008')
--              and num_credito = vnumcredito
--              and cargos > 0 
--              and (concepto =  'BONIF. COMISION' or concepto = 'BONIF. IVA COMIS.')
--              and cargos = vmonto;
--
--           commit work;
--    END FOREACH

    --//Actualiza saldo promedio
  --  FOREACH WITH HOLD
  --      select a.num_credito, round((a.interes_tc*360)/(31*.5923),2)
  --        into vnumcredito, vmonto
  --        from bdicred:sd_encabezado2_edocta a,
  --             bdicred:sd_pie_edocta b 
  --       where a.fecha_emision = mdy('11','20','2008')
  --         and a.fecha_emision = b.fecha_emision 
  --         and a.num_credito   = b.num_credito
  --         and interes_tc > 0

  --         if (vmonto > 0) then
  --             begin work;
  --                  update bdicred:sd_pie_edocta 
  --                     set saldo_promedio = vmonto 
  --                   where fecha_emision = mdy('11','20','2008')
  --                     and num_credito = vnumcredito;
  --             commit work;
  --         end if;

  --  END FOREACH

    --//Actualiza interes vencido
    FOREACH WITH HOLD
        select num_credito, nvl((select sum(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito 
                                   where empresa = '001' and a.num_credito = num_credito 
                                   and fecha_cuota < mdy('02','20','2009') 
                                   and (interes_debe - interes_pagado) > 0),0)
        into vnumcredito, vmonto2
        from bdicred:sd_encabezado2_edocta a
        where --empresa = '001' 
         -- and a.empresa = b.empresa
         -- and a.num_credito = b.num_credito
           fecha_emision = mdy('02','20','2009')
        --  and a.num_credito = c.num_credito
      --    and int_tra_no_exig > 0
      --    and status_cred in ('BA','AA')
          and interes_ven_tc > 0 
          and iva_interes_ven_tc <= 0

          begin work;
              update bdicred:sd_encabezado2_edocta 
                set sdo_pagar = sdo_pagar - iva_interes_ven_tc  + vmonto2,
                    --interes_ven_tc = vmonto, 
                    iva_interes_ven_tc = vmonto2
               where fecha_emision = mdy('02','20','2009')
                 and num_credito = vnumcredito;
          commit work;
      
    END FOREACH;

--    FOREACH WITH HOLD
--        select num_credito
--        into vnumcredito
--        from bdicred:sd_encabezado2_edocta a
--        where --empresa = '001' 
         -- and a.empresa = b.empresa
         -- and a.num_credito = b.num_credito
--           fecha_emision = mdy('02','20','2009')
        --  and a.num_credito = c.num_credito
      --    and int_tra_no_exig > 0
      --    and status_cred in ('BA','AA')
--          and interes_ven_tc > 0 
--          and iva_interes_ven_tc <= 0

--          begin work;
--              update bdicred:sd_encabezado2_edocta 
--                set sdo_pagar = sdo_pagar - interes_ven_tc,
--                    interes_ven_tc = 0
--               where fecha_emision = mdy('02','20','2009')
--                 and num_credito = vnumcredito;
--          commit work;
--      
--    END FOREACH;

 --//Actualiza los vencidos en la clave de cobranza
--    FOREACH WITH HOLD
--            select num_credito,substr(cl_cobra,1,54)||'V' 
--            into vnumcredito,v_cl_cobra
--            from bdicred:sd_encabezado_edocta 
--            where fecha_emision = mdy('01','20','2009')
--            and substr(cl_cobra,1,2) = '04'
--            and substr(cl_cobra,55,1)  = '2'
--
--          begin work;
--              update bdicred:sd_encabezado_edocta  
--                set cl_cobra = v_cl_cobra
--               where fecha_emision = mdy('01','20','2009')
--                 and num_credito = vnumcredito;
--          commit work;
--      
--    END FOREACH;
--    --//Entrega el codigo de retorno 
--    RETURN "0000";


END;
END PROCEDURE;