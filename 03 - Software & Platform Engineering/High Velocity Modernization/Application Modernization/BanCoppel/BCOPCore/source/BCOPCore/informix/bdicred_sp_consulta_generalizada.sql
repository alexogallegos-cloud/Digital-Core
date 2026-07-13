CREATE PROCEDURE "informix".sp_consulta_generalizada(
				pempresa CHAR(3),
				pcuenta  CHAR(20))
				
RETURNING CHAR(5),      -- Codigo de Retorno
		DECIMAL(14,2),  -- Saldo Insoluto
		DECIMAL(14,2),  -- Moratorio
		DECIMAL(14,2),	-- Iva de Moratorios 
		DECIMAL(14,2), 	-- Interes Vencido 
		DECIMAL(14,2),	-- Iva de Interes Vencido 
        DECIMAL(14,2);  -- Total Liquidacion
		  
-- Roque Enrique Solis Campañ¡­- 10  DE  DE 2008
-- OBTIENE EL SALDO INSOLUTO, MORATORIO, IVA DE MORATORIO, INTERES VENCIDO,
-- IVA DE INTERES VENCIDO PARA LA CONSULTA GENERALIZADA DE CREDITO

--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************

DEFINE scod_ret             CHAR(5);
DEFINE vsqlerr              INTEGER;
DEFINE s_empresa            CHAR(3);
DEFINE s_cuenta             CHAR(20);
DEFINE s_sucursal             CHAR(4);
DEFINE s_tarjeta              CHAR(16);
DEFINE d_saldoInsoluto        DECIMAL(14,2);
DEFINE d_moratorio            DECIMAL(14,2);
DEFINE d_ivaMoratorio         DECIMAL(14,2);
DEFINE d_intersVenc           DECIMAL(14,2);
DEFINE d_ivaIntVenc           DECIMAL(14,2);
DEFINE d_ivaIntVencAux        DECIMAL(14,2);
DEFINE vPorcIva               DECIMAL(14,2);
DEFINE d_totalLiquidacion	  DECIMAL(14,2);
DEFINE c_StatusCred           CHAR (02);
DEFINE d_InteresMes           DECIMAL(14,2);
DEFINE d_IvaMes               DECIMAL(14,2);
DEFINE d_interesVencidoFinal  DECIMAL(14,2);


-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************

LET scod_ret               = "000";
LET vsqlerr                = 0;
LET s_empresa              =" ";
LET s_sucursal             =" ";
LET s_cuenta               =" ";
LET s_tarjeta              =" ";
LET d_saldoInsoluto        =0;
LET d_moratorio            =0;
LET d_ivaMoratorio         =0;
LET d_intersVenc           =0;
LET d_ivaIntVenc           =0;
LET d_ivaIntVencAux        =0;
LET vPorcIva               =0;
LET d_totalLiquidacion     =0;
LET c_StatusCred           ='';
LET d_InteresMes           =0;
LET d_IvaMes               =0;
LET d_interesVencidoFinal  =0;


-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, d_saldoInsoluto, d_moratorio, d_ivaMoratorio,
	  d_intersVenc, d_ivaIntVenc, d_totalLiquidacion ;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_consulta_generalizada.out";
--TRACE ON;


-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************

LET s_empresa=pempresa;
LET s_cuenta=pcuenta;

SELECT 
b.sucursal,             -- Sucursal
b.status_cred,          -- Status del Credito
c.sdo_cap_insoluto,     -- Saldo Insoluto
c.int_tra_no_exig       -- Interes Vencido
INTO s_sucursal, c_StatusCred, d_saldoInsoluto, d_intersVenc
FROM bdicred:sd_maecred b, bdicred:sd_maesdos c
WHERE b.empresa = s_empresa
AND b.num_credito = s_cuenta
AND c.empresa = b.empresa
AND c.num_credito = b.num_credito;

    ----Se obtiene Iva de la Sucursal ----
    SELECT iva INTO vPorcIva
    FROM bdinteg:si_sucursales 
    WHERE empresa = s_empresa 
    AND sucursal = s_sucursal;
    --------------------------------------

    ----Se Calcula el Interes Moratorio-----------------------------------
    SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) +
            SUM(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag))
     INTO d_moratorio
     FROM sd_amortiza_credito
     WHERE  empresa = s_empresa
     AND num_credito = s_cuenta
     AND capital_status IN ("2","7","6");
     
    IF  d_moratorio IS NULL OR  d_moratorio < 0 THEN
           LET d_moratorio = 0;
    END IF;
    ----------------------------------------------------------------------

     -----Se Calcula el Iva de Interes Moratorio --------------------------
     SELECT SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * 
	 vPorcIva)-mora_iva_pagado)
     INTO d_ivaMoratorio
     FROM sd_amortiza_credito
     WHERE  num_credito = s_cuenta
     AND empresa = s_empresa
     AND capital_status IN ("2","7","6")
     AND (mora_iva_debe - mora_iva_pagado + 
	 ((mora_provi_ordi+mora_provi_cope) * vPorcIva)) > 0;

     IF  d_ivaMoratorio  IS NULL OR  d_ivaMoratorio < 0 THEN
            LET d_ivaMoratorio = 0;
     END IF;
     ------------------------------------------------------------------------

    ---------Se Calcula el Iva de Interes Vencido-----------
	SELECT nvl(SUM(iva_debe - iva_pagado),0) 
	INTO d_ivaIntVenc
	FROM bdicred:sd_amortiza_credito
	WHERE empresa = s_empresa 
    AND num_credito = s_cuenta
	AND capital_status IN ('2','7','5','6') ;

    SELECT nvl(SUM(b.interes_debe - b.interes_pagado),0) 
    INTO d_InteresMes
    FROM bdicred:sd_amortiza_credito b
    WHERE b.empresa = s_empresa
    AND b.num_credito = s_cuenta 
    AND capital_status = '1';

    SELECT nvl(SUM(b.iva_debe - b.iva_pagado),0)
    INTO d_IvaMes
    FROM bdicred:sd_amortiza_credito b
    WHERE b.empresa = s_empresa
    AND b.num_credito = s_cuenta  
    AND capital_status = '1';
 --   (BT or (E2 or E3) and act >=2)

      IF (d_intersVenc > 0) THEN --Creditos Vencido
         LET d_intersVenc = d_intersVenc - d_InteresMes;
         LET d_ivaIntVenc = d_ivaIntVenc - d_IvaMes;
      ELSE
          LET d_intersVenc= 0;
          LET d_ivaIntVenc= 0;
      END IF;

    --------------------------------------------------------

    --------- Se Calcula el Total por Liquidar ----------------------------------------------------------
      LET d_totalLiquidacion = d_saldoInsoluto + d_moratorio + d_ivaMoratorio + d_intersVenc + d_ivaIntVenc;
    -----------------------------------------------------------------------------------------------------

    RETURN scod_ret, d_saldoInsoluto ,d_moratorio , d_ivaMoratorio ,
	  d_intersVenc, d_ivaIntVenc, d_totalLiquidacion
	WITH RESUME;

    
END;
END PROCEDURE;