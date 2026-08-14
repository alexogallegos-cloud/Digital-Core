CREATE PROCEDURE "informix".calporcentaje_condonacionquitas(e_fcuota DATE,
                                          e_Mora   INTEGER,
                                          e_Int    INTEGER,
										  mRemanente_cq MONEY(18,2))
										  
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
   --DEFINE GLOBAL g_Remanente        MONEY(14,2) DEFAULT 0;
   --DEFINE GLOBAL g_Remanente        DECIMAL(18,2) DEFAULT 0;
--   DEFINE GLOBAL vIndProceso        CHAR(1)     DEFAULT ' '; --RQM 09 459
   DEFINE GLOBAL g_Fecha            DATE        DEFAULT '';
   DEFINE GLOBAL g_Folio            CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal         CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa           CHAR(2)     DEFAULT ' ';
--   DEFINE GLOBAL g_TRansacc         CHAR(4)     DEFAULT ' ';
--   DEFINE GLOBAL g_IvaCte           DECIMAL(9,6) DEFAULT 0;
--   DEFINE GLOBAL g_CodigoFun        CHAR(3)     DEFAULT ' ';
   DEFINE dIvaIntMoratorio          DECIMAL(18,2);
   DEFINE dIntMoratorio_d	        DECIMAL(18,2);
   DEFINE vFechaCuota               LIKE sd_amortiza_credito.fecha_cuota;
   DEFINE vMoraDebe                 LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaDebe              LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraTotDebe              LIKE sd_amortiza_credito.mora_iva_debe;

   DEFINE vIvaMora    LIKE sd_amortiza_credito.mora_iva_debe; 
   DEFINE vMontoMora  LIKE sd_amortiza_credito.mora_iva_debe; 
   DEFINE vIntVdo     LIKE sd_amortiza_credito.mora_iva_debe; 
   DEFINE vIvaiIntVdo LIKE sd_amortiza_credito.mora_iva_debe;
 
   
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
   --DEFINE pAdeudoMoraInt         MONEY(18,2);
   --DEFINE dFactorMoraCope        MONEY(18,2);
   --DEFINE pMoraCope              MONEY(18,2);
   --DEFINE dPagoMoraCope          MONEY(18,2);
   --DEFINE dPagoMoraOrdi          MONEY(18,2);
   --DEFINE pAdeudoIva             MONEY(18,2);
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIva.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet,vIvaMora,vMontoMora,vIvaiIntVdo,vIntVdo;
   END EXCEPTION;

   --SET DEBUG FILE TO "calprocentaje.out";
   --TRACE ON;

   LET CodRet       = "000";
   LET vCodFunIva   = "340";
   LET vCodigoRef   = 1;
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
--   LET g_Remanente_cq   = g_Remanente_cq;
   LET dIvaIntMoratorio         = 0;
   LET dIntMoratorio_d       = 0;
   --LET pAdeudoMoraInt   = 0;
   --LET pMoraCope        = 0;
   --LET dPagoMoraCope    = 0;
   --LET dPagoMoraOrdi    = 0;
   --LET pAdeudoIva       = 0;
   LET vMontoMora   = 0;
   LET vIvaMora     = 0;      
   LET vIntVdo      = 0;
   LET vIvaiIntVdo	= 0;
    -- *****************************
   -- Extrae Iva Base del Sistema *
   -- *****************************
   SELECT valor INTO vIvaBase
     FROM bdinteg:si_param
    WHERE empresa = g_Empresa
      AND cod_param = 47;


    /*IF vIvaBase <> g_IvaCte THEN
     LET wCodRefMora = 26 ;
    ELSE
     LET wCodRefMora = 25 ;
    END IF*/

   -- ***************************************************
   -- Calcula Porcentaje DE Iva Y Mora  de Intereses    *
   -- ***************************************************
	IF e_Mora = 1 THEN

		SELECT SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))
		INTO   vMoraDebe
		FROM sd_amortiza_credito
		WHERE empresa =  g_empresa
		AND num_credito = g_NumCredito
		AND capital_status in ('2','7','6');
			
			FOREACH
				SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* vIvaBase ))
				INTO dIntMoratorio_d
				FROM sd_amortiza_credito a
				WHERE a.empresa   = g_empresa
				AND a.num_credito = g_NumCredito
				AND capital_status IN ("2","7","6")

				LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;

			END FOREACH;
							
		 /*LET  vMoraIvaDebe = round(dIvaIntMoratorio,2);
		 LET  vMoraTotDebe = round(vMoraDebe + vMoraIvaDebe,2);
		 LET  pAdeudoMoraInt = round(vMoraIvaDebe + vMoraDebe,2);*/

		 LET  vMoraIvaDebe = dIvaIntMoratorio;
		 LET  vMoraTotDebe = vMoraDebe + vMoraIvaDebe;
		 --LET  pAdeudoMoraInt = vMoraIvaDebe + vMoraDebe;

		 
		--Calcula la diferencia
		--IF vMoraTotDebe > g_Remanente_cq  THEN	 --AND pAdeudoMoraInt > 0
			/*LET vMoraPor = round(vMoraDebe  / vMoraTotDebe,2);
			LET vMorapag = round(vMoraPor * g_Remanente_cq,2);
			LET vIvaPag  = round(g_Remanente_cq - vMorapag,2);*/
			LET vMoraPor = vMoraDebe  / vMoraTotDebe;
			LET vMorapag = round(mRemanente_cq * vMoraPor,2);
			LET vIvaPag  = mRemanente_cq - vMorapag;				
		/*ELSE
			LET vMorapag = vMoraTotDebe;
			LET vIvaPag = pAdeudoIva;
		END IF;	*/

		LET vIvaMora = vIvaPag;
		LET vMontoMora = vMorapag;

		--**Movimientos Contables IVA INTERES MORATORIO **--
		/*IF vIndProceso = 'Q' THEN  --Quita
			CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'136', g_Fecha, vIvaMora, g_Folio, g_Sucursal, g_Divisa, '8390') 
			RETURNING CodRet, Mensaje;
				IF (CodRet <> "00000") THEN	
					SELECT descripcion INTO Mensaje FROM bdinteg:"informix".si_codret
					WHERE sistema = g_sistema AND codigo_retorno = CodRet;
					RETURN CodRet, vIvaiIntVdo,vIntVdo,vIvaMora,vMontoMora;				
				END IF;		
			CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'135', g_Fecha, vMontoMora, g_Folio, g_Sucursal, g_Divisa, '8389') 
			RETURNING CodRet, Mensaje;
				IF (CodRet <> "00000") THEN	
					SELECT descripcion INTO Mensaje FROM bdinteg:"informix".si_codret
					WHERE sistema = g_sistema AND codigo_retorno = CodRet;
					RETURN CodRet, vIvaiIntVdo,vIntVdo,vIvaMora,vMontoMora;				
				END IF;				
		ELIF vIndProceso = 'C' THEN --Condonacion
			CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'132', g_Fecha, vIvaMora, g_Folio,	g_Sucursal, g_Divisa, '8386') 
			RETURNING CodRet, Mensaje;
				IF (CodRet <> "00000") THEN	
					SELECT descripcion INTO Mensaje FROM bdinteg:"informix".si_codret
					WHERE sistema = g_sistema AND codigo_retorno = CodRet;
					RETURN CodRet, vIvaiIntVdo,vIntVdo,vIvaMora,vMontoMora;				
				END IF;		
			CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'131', g_Fecha, vMontoMora, g_Folio, g_Sucursal, g_Divisa, '8385') 
			RETURNING CodRet, Mensaje;
				IF (CodRet <> "00000") THEN	
					SELECT descripcion INTO Mensaje FROM bdinteg:"informix".si_codret
					WHERE sistema = g_sistema AND codigo_retorno = CodRet;
					RETURN CodRet, vIvaiIntVdo,vIntVdo,vIvaMora,vMontoMora;				
				END IF;
		END IF;*/		

		/*IF  vMoraTotDebe > 0 THEN
		   LET dFactorMoraCope = (pMoraCope / pAdeudoMoraInt);
		   LET dPagoMoraCope   = round(vMorapag * dFactorMoraCope,2);
		   LET dPagoMoraOrdi   = vMorapag - dPagoMoraCope;
		   LET vMorapag    = 0;
		END IF;*/
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
		   AND capital_status in ('2','7','6')
		   AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0;

		 ----------------------------	      
		 
		 LET  vIntTotDebe = round(vIntVenc + vIvaVenc,2);
		 --LET  g_Remanente_cq = round(g_Remanente_cq - vIntTotDebe,2);
		 --LET  pAdeudoVencInt = vMoraIvaDebe + vMoraDebe;

		 --IF vIntTotDebe > g_Remanente_cq AND vIntTotDebe > 0 THEN --RQM 09 459
			LET vIntPor     = vIntVenc  / vIntTotDebe;
			LET vIntPag     = round(vIntPor * mRemanente_cq,2);
			LET vIvaiIntPag = mRemanente_cq - vIntPag;
		 /*ELSE
			LET vIntPag = vIntVenc;
			LET vIvaiIntPag = pAdeudoIva;
		 END IF;*/
		 
			LET vIntVdo = vIntPag;
			LET vIvaiIntVdo = vIvaiIntPag;
			
		--**Movimientos Contables Condonacion Quitas **--
		--Transaccion Interes Vencido
/*		CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,1,'137', g_Fecha, vIntVenc, g_Folio, g_Sucursal, g_Divisa, '8391') RETURNING CodRet, Mensaje;
		IF (CodRet <> "00000") THEN RETURN CodRet,vIvaMora,vMontoMora,vIvaiIntVdo,vIntVdo;
		ELSE LET CodRet = "000"; END IF;	
		-------------------------
		--Transaccion Interes Moratorio	
		CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,1,'138', g_Fecha, vIvaVenc, g_Folio, g_Sucursal, g_Divisa, '8392') RETURNING CodRet, Mensaje;
		IF (CodRet <> "00000") THEN RETURN CodRet,vIvaMora,vMontoMora,vIvaiIntVdo,vIntVdo;
		ELSE LET CodRet = "000"; END IF;*/
	
	END IF;	
      RETURN CodRet,vIvaMora,vMontoMora,vIvaiIntVdo,vIntVdo;

END PROCEDURE;