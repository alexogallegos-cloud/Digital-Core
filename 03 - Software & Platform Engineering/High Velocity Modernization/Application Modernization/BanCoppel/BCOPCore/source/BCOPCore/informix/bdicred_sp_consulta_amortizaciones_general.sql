CREATE PROCEDURE "informix".sp_consulta_amortizaciones_general(pEmpresa CHAR(3),
                                                                pNumCredito CHAR(20))
RETURNING CHAR(6)        AS Codigo_Retorno,
          CHAR(80)       AS Mensaje_Retorno, 
          DATE           AS Fecha_Cuota, 
          INTEGER        AS Num_Pago,		  
          DECIMAL(18,2)  AS Monto_Capital,
          DECIMAL(18,2)  AS Pagado_Capital, 
          DECIMAL(18,2)  AS Saldo_Capital,
          DECIMAL(18,2)  AS Monto_Interes,
          DECIMAL(18,2)  AS Pagado_Interes,
          DECIMAL(18,2)  AS Saldo_Interes, 
		  DECIMAL(18,2)  AS Monto_mora,
		  DECIMAL(18,2)  AS Pagado_Mora,
          DECIMAL(18,2)  AS Saldo_Moratorio,
          DECIMAL(18,2)  AS Monto_Iva_Mora,
          DECIMAL(18,2)  AS Pagado_iva_Mora,		  
		  DECIMAL(18,2)  AS Saldo_Iva_Mora,
          CHAR(11)       AS Status_Principal,
          DECIMAL(18,2)  AS Saldo_Amortiza;
	
--*******************************************************************************************************
-- Realizo   : Jose Luis Pulido Zepeda
-- Proyecto  : Consulta generalizada de credito
-- Actividad : Realizar la consulta de las amortizaciones que realizo un crédito determinado
-- Fecha     : 22-06-2009

--Autor: Roque Enrique Solis Campaña
--Fecha: 08/10/2009
--Modificación: Se modifico para poder realizar la consulta de disposiciones para prestamos personales
--*******************************************************************************************************

DEFINE cCodRet         CHAR(6);
DEFINE cErrorInfo      CHAR(80);
DEFINE cErrorInfoR     CHAR(80);
DEFINE iSqlerr         INTEGER;
DEFINE sIsamErr        SMALLINT;
DEFINE iRegistros      INTEGER;

DEFINE dtFechaCuota    DATE;
DEFINE iNumPago        INTEGER;
DEFINE dMontoCap       DECIMAL(18,2);
DEFINE dPagadoCap      DECIMAL(18,2);
DEFINE dSaldoCap       DECIMAL(18,2);
DEFINE dMontoint       DECIMAL(18,2);
DEFINE dPagadoint      DECIMAL(18,2);
DEFINE dSaldoint       DECIMAL(18,2);
DEFINE dMontoMora      DECIMAL(18,2);
DEFINE dPagoMora       DECIMAL(18,2);
DEFINE dSaldoMora      DECIMAL(18,2);
DEFINE dMonIvaMora     DECIMAL(18,2);
DEFINE dPagoIvaMora    DECIMAL(18,2);
DEFINE dSldIvaMora     DECIMAL(18,2);
DEFINE cStatus         CHAR(11);
DEFINE dSdoAmortiza    DECIMAL(18,2);
DEFINE cNumCredito     CHAR(20);
DEFINE cCodprod        CHAR(2);

LET cCodRet         = '000000';
LET cErrorInfo      = "";
LET cErrorInfoR     = "OPERACION EXITOSA";
LET iSqlerr         = 0;
LET iRegistros      = 0;

LET dtFechaCuota    = DATE(1);
LET iNumPago        = 0;
LET dMontoCap       = 0;
LET dPagadoCap      = 0;
LET dSaldoCap       = 0;
LET dMontoint       = 0;
LET dPagadoint      = 0;
LET dSaldoint       = 0;
LET dMontoMora      = 0;
LET dPagoMora       = 0;
LET dSaldoMora      = 0;
LET dMonIvaMora     = 0;
LET dPagoIvaMora    = 0;
LET dSldIvaMora     = 0;
LET cStatus         = '';
LET dSdoAmortiza    = 0;
LET cNumCredito     = '';
LET cCodprod        = '';

BEGIN

ON EXCEPTION  SET iSqlerr, sIsamErr, cErrorInfo
	IF iSqlerr <> 0  THEN
		LET  cCodRet  = iSqlerr;
		LET cErrorInfoR = cErrorInfo;
     RETURN cCodRet,cErrorInfoR,NVL(dtFechaCuota,DATE(1)), NVL(iNumPago,0), 
	        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
			NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
			NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
			NVL(cStatus,''),NVL(dSdoAmortiza,0);
	END IF;
END  EXCEPTION

--set debug file to "/tmp/sp_consulta_amortizaciones_general.out";
--trace on;

IF NVL(TRIM(pEmpresa),'')='' OR NVL(TRIM(pNumCredito),'')='' THEN
    LET cCodRet     = '000001';
    LET cErrorInfoR = 'LOS DATOS DE ENTRADA SON INCORRECTOS';
 RETURN cCodRet,cErrorInfoR,NVL(dtFechaCuota,DATE(1)), NVL(iNumPago,0), 
	        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
			NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
			NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
			NVL(cStatus,''),NVL(dSdoAmortiza,0);
END IF;

SET ISOLATION TO dirty READ;


SELECT num_credito,b.cod_prod
  INTO cNumCredito,cCodprod
  FROM bdicred:sd_maecred a,
       bdicred:sd_tipprod b
 WHERE a.num_credito = pNumCredito
   AND a.empresa=pEmpresa
   AND a.empresa=b.empresa 
   AND a.num_producto=b.abrevia_prod;
   
    IF cNumCredito IS NULL OR cCodprod IS NULL THEN
        SELECT num_credito,b.cod_prod
          INTO cNumCredito,cCodprod
          FROM bdicred:sd_maecredcrd a,
               bdicred:sd_tipprod b
         WHERE a.num_credito = pNumCredito
           AND a.empresa=pEmpresa
           AND a.empresa=b.empresa 
           AND a.num_producto=b.abrevia_prod;
        IF cNumCredito IS NULL OR cCodprod IS NULL THEN
           LET cCodRet     = '000001';
           LET cErrorInfoR = 'EL PRODUCTO NO EXISTE FAVOR DE CONFIRMAR';
         RETURN cCodRet,cErrorInfoR,NVL(dtFechaCuota,DATE(1)), NVL(iNumPago,0), 
	        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
			NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
			NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
			NVL(cStatus,''),NVL(dSdoAmortiza,0);
        END IF;
    END IF;

--1 FACTURADA
--3 VIGENTE

IF cCodprod ='T' THEN
		FOREACH
		    SELECT fecha_cuota,
		           capital_debe,
		           capital_pagado,
		           (capital_debe-capital_pagado),
		           interes_debe,
		           interes_pagado,
		           (interes_debe - interes_pagado),
				   (mora_sdo_ordi + mora_sdo_cope),
				   (mora_sdo_ordi_pag + mora_sdo_cope_pag),
				   ((mora_provi_ordi + mora_provi_cope ) + (mora_sdo_ordi - mora_sdo_ordi_pag) + (mora_sdo_cope - mora_sdo_cope_pag)), 
				   (mora_sdo_ordi + mora_sdo_cope) * s.Iva,
				   (mora_sdo_ordi_pag + mora_sdo_cope_pag) * s.Iva,
				   ((mora_provi_ordi + mora_provi_cope ) + (mora_sdo_ordi - mora_sdo_ordi_pag) + (mora_sdo_cope - mora_sdo_cope_pag)) * s.Iva,
		           DECODE(capital_status,1,"VIGENTE",2,"VENCIDA",5,"PAGADA",7,"TRANSITORIA",""),
		           capital_status + interes_status,
				   num_pago
		      INTO dtFechaCuota,
		           dMontoCap,
		           dPagadoCap,
		           dSaldoCap,
		           dMontoint,
		           dPagadoint,
		           dSaldoint,
				   dMontoMora,
				   dPagoMora,
		           dSaldoMora,
				   dMonIvaMora,
				   dPagoIvaMora,
		           dSldIvaMora,
		           cStatus,
		           dSdoAmortiza,
				   iNumPago
		      FROM bdicred:sd_amortiza_credito c 
		INNER JOIN bdicred:sd_maecred m ON m.empresa=c.empresa AND m.num_credito=c.num_credito
		INNER JOIN bdinteg:si_sucursales s ON s.empresa=c.empresa AND s.sucursal=m.sucursal
		     WHERE c.empresa     = pEmpresa 
		       AND c.num_credito = pNumCredito
		  ORDER BY 1 DESC
            
			LET iRegistros = iRegistros + 1;
			
		     RETURN cCodRet,cErrorInfoR,NVL(dtFechaCuota,DATE(1)), NVL(iNumPago,0), 
			        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
					NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
					NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
					NVL(cStatus,''),NVL(dSdoAmortiza,0) WITH RESUME;
		END FOREACH;
END IF;

  
   IF cCodprod  IN ('P','R') THEN 
       FOREACH
	         SELECT fecha_cuota,
		           capital_debe,
		           capital_pagado,
		           (capital_debe-capital_pagado),
		           interes_debe,
		           interes_pagado,
		           (interes_debe - interes_pagado),
				   (mora_sdo_ordi + mora_sdo_cope),
				   (mora_sdo_ordi_pag + mora_sdo_cope_pag),
				   ((mora_provi_ordi + mora_provi_cope) + (mora_sdo_ordi - mora_sdo_ordi_pag) + (mora_sdo_cope - mora_sdo_cope_pag)), 
				   (mora_sdo_ordi + mora_sdo_cope) * s.Iva,
				   (mora_sdo_ordi_pag + mora_sdo_cope_pag) * s.Iva,
				   ((mora_provi_ordi + mora_provi_cope) + (mora_sdo_ordi - mora_sdo_ordi_pag) + (mora_sdo_cope - mora_sdo_cope_pag)) * s.Iva,
		           DECODE(capital_status,1,"VIGENTE",2,"VENCIDA",3,"DEVENGADA",5,"PAGADA",7,"TRANSITORIA",""),
		           capital_status + interes_status,
				   num_pago
		      INTO dtFechaCuota,
		           dMontoCap,
		           dPagadoCap,
		           dSaldoCap,
		           dMontoint,
		           dPagadoint,
		           dSaldoint,
				   dMontoMora,
				   dPagoMora,
		           dSaldoMora,
				   dMonIvaMora,
				   dPagoIvaMora,
		           dSldIvaMora,
		           cStatus,
		           dSdoAmortiza,
				   iNumPago
		      FROM bdicred:sd_amortiza_creditocrd c 
		INNER JOIN bdicred:sd_maecredcrd m ON m.empresa=c.empresa AND m.num_credito=c.num_credito
		INNER JOIN bdinteg:si_sucursales s ON s.empresa=c.empresa AND s.sucursal=m.sucursal
		     WHERE c.empresa     = pEmpresa 
		       AND c.num_credito = pNumCredito
		  ORDER BY 1 DESC
		  
			 LET iRegistros = iRegistros + 1 ;
			 
		     RETURN cCodRet,cErrorInfoR,NVL(dtFechaCuota,DATE(1)), NVL(iNumPago,0), 
			        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
					NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
					NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
					NVL(cStatus,''),NVL(dSdoAmortiza,0) WITH RESUME;
		END FOREACH;

   END IF;
   
   IF iRegistros  = 0 THEN
	  LET cCodRet     = '000002';
	  LET cErrorInfoR = 'NO SE OBTUVIERON RESULTADOS';
	   RETURN cCodRet,cErrorInfoR,NVL(dtFechaCuota,DATE(1)), NVL(iNumPago,0), 
	        NVL(dMontoCap,0),NVL(dPagadoCap,0),NVL(dSaldoCap,0),NVL(dMontoint,0),
			NVL(dPagadoint,0),NVL(dSaldoint,0),NVL(dMontoMora,0),NVL(dPagoMora,0),
			NVL(dSaldoMora,0),NVL(dMonIvaMora,0),NVL(dPagoIvaMora,0),NVL(dSldIvaMora,0),
			NVL(cStatus,''),NVL(dSdoAmortiza,0);
   END IF;
END;
END PROCEDURE;