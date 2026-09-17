CREATE PROCEDURE "informix".calporcentaje(e_fcuota DATE,
                                          e_Mora   INTEGER,
                                          e_Int    INTEGER)
   RETURNING CHAR(5),MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2);

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
   DEFINE GLOBAL g_Fecha            DATE        DEFAULT '';
   DEFINE GLOBAL g_Folio            CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal         CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa           CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc         CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_IvaCte           DECIMAL(9,6) DEFAULT 0;
   DEFINE GLOBAL g_CodigoFun        CHAR(3)     DEFAULT ' ';
   DEFINE dIvaIntMoratorio     DECIMAL(18,2);
   DEFINE dIntMoratorio_d	 DECIMAL(18,2);
   DEFINE vFechaCuota            LIKE sd_amortiza_credito.fecha_cuota;
   DEFINE vMoraDebe              LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaDebe           LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraTotDebe           LIKE sd_amortiza_credito.mora_iva_debe;
---CAS
   DEFINE vMoraPor               DECIMAL(9,6);
   DEFINE vIvaPor                DECIMAL(9,6);
   DEFINE vIntPor                DECIMAL(9,6);
   DEFINE vIvaIntPor             DECIMAL(9,6);
---CAS

 --  DEFINE vMoraPor               LIKE sd_amortiza_credito.mora_iva_debe;
 --  DEFINE vIvaPor                LIKE sd_amortiza_credito.mora_iva_debe;
 --  DEFINE vIntPor                LIKE sd_amortiza_credito.mora_iva_debe;
 --  DEFINE vIvaIntPor             LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraPag               LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vIvaPag                LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraDebeIva           LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vIntPag                LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vIvaiIntPag            LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vIntVenc               LIKE sd_paginter.monto_cuota;
   DEFINE vIvaVenc               LIKE sd_paginter.monto_cuota;
   DEFINE vIntTotDebe            LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vStatusCuota           LIKE sd_paginter.status_cuota;
   DEFINE vCodFunIva             CHAR(3);
   DEFINE wCodRefMora            SMALLINT;
   DEFINE vIvaBase               DECIMAL(9,6);
   DEFINE vCodigoRef             SMALLINT;
   DEFINE vReferencia            SMALLINT;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIva.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet,vIvaPag,vMorapag,vIvaiIntPag,vIntPag;
   END EXCEPTION;

   --SET DEBUG FILE TO "calprocentaje.out";
   --TRACE ON;

   LET CodRet       = "000";
   LET vCodFunIva   = "340";
   LET vCodigoRef   = 2;
   LET vMoraDebe    = 0;
   LET vMoraIvaDebe = 0;
   LET vMoraTotDebe = 0;
   LET vMoraPor     = 0;
   LET vIvaPor      = 0;
   LET vMoraPag     = 0;
   LET vIvaPag      = 0;
   LET vIntVenc     = 0;
   LET vIvaVenc     = 0;
   LET vIntTotDebe  = 0;
   LET vIvaIntPor   = 0;
   LET vIntPor      = 0;
   LET vIvaiIntPag  = 0;
   LET vIntPag      = 0;
   LET vFechaCuota  = '';
   LET vStatusCuota  = '';
   LET vIvaBase      = 0;
   LET vMoraDebeIva  = 0;
   LET g_Remanente   = g_Remanente;
   LET dIvaIntMoratorio         = 0;
   LET dIntMoratorio_d       = 0;	
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


   -- ***************************************************
   -- Calcula Porcentaje DE Iva Y Mora  de Intereses    *
   -- ***************************************************
  IF e_Mora = 1 THEN
  
      SELECT SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))
--             sum(mora_iva_debe - mora_iva_pagado)
      INTO   vMoraDebe
-- , vMoraIvaDebe
      FROM sd_amortiza_credito
      WHERE empresa =  g_empresa
        AND num_credito = g_NumCredito
        --AND capital_status in ('2','7');
        AND capital_status in ('2','7','6'); --Se agrega nuevo estatus para IFRS
        --and mora_status = 1
        --AND (mora_provi_ordi + mora_provi_cope+mora_sdo_ordi+mora_sdo_cope-mora_sdo_ordi_pag-mora_sdo_cope_pag) > 0;

		
		FOREACH
  			SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* vIvaBase ))
  			INTO dIntMoratorio_d
  			FROM sd_amortiza_credito a
  			WHERE a.empresa   = g_empresa
  			AND a.num_credito = g_NumCredito
  			--AND capital_status IN ("2","7")
         AND capital_status in ('2','7','6') --Se agrega nuevo estatus para IFRS
  
  			LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;
  
  		END FOREACH;
		
		
		
	-- LET  vMoraIvaDebe = vMoraDebe * vIvaBase;
	 LET  vMoraIvaDebe =dIvaIntMoratorio;
     LET  vMoraTotDebe = vMoraDebe + vMoraIvaDebe;
     IF vMoraTotDebe > g_Remanente  THEN
        LET vMoraPor = vMoraDebe    / vMoraTotDebe;
        LET vMorapag = round(vMoraPor * g_Remanente,2);
        LET vIvaPag  = g_Remanente - vMorapag;
--        LET vIvaPor  = vMoraIvaDebe / vMoraTotDebe;
--        LET vIvaPag  = vIvaPor * g_Remanente;
--        LET vMorapag = vMoraPor * g_Remanente;
--        let g_Remanente = vMorapag;
     END IF;
  END IF;

   -- ***************************************************
   -- Calcula Porcentaje De Interes                     *
   -- ***************************************************
  IF e_Int  = 2 THEN
     SELECT sum((interes_debe - interes_pagado)),
            sum((iva_debe - iva_pagado))
     INTO  vIntVenc,vIvaVenc
     FROM sd_amortiza_credito
     WHERE empresa = g_Empresa
       AND num_credito = g_NumCredito
       AND interes_status in ('3')
       --AND capital_status in ('2','7')
       AND capital_status in ('2','7','6') --Se agrega nuevo estatus para IFRS
       AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0;


     LET  vIntTotDebe = vIntVenc + vIvaVenc;
     IF vIntTotDebe > g_Remanente  THEN
        LET vIntPor     = vIntVenc  / vIntTotDebe;
        LET vIntPag     = round(vIntPor    * g_Remanente,2);
        LET vIvaiIntPag = g_Remanente - vIntPag;
--        LET vIvaIntPor  = vIvaVenc / vIntTotDebe;
--        LET vIvaiIntPag = vIvaIntPor * g_Remanente;
--        LET vIntPag     = vIntPor    * g_Remanente;
    END IF;
 END IF;
      RETURN CodRet,vIvaPag,vMorapag,vIvaiIntPag,vIntPag;

END PROCEDURE;