CREATE PROCEDURE "informix".sp_rasura_moratorios_quitas(e_fcuota DATE, g_Remanente_cq MONEY(14,2))
   RETURNING CHAR(5);

   DEFINE CodRet              CHAR(5);
   DEFINE Mensaje             CHAR(80);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nRows               SMALLINT;

   DEFINE GLOBAL g_Empresa      CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito   CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto  CHAR(4)     DEFAULT ' ';
   --DEFINE GLOBAL g_Remanente    MONEY(14,2) DEFAULT 0;
   --DEFINE GLOBAL g_Remanente_cq MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL vIndProceso    CHAR(1)     DEFAULT ' '; --RQM 09 459    
   DEFINE GLOBAL g_Fecha        DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa       CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun    CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio        CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_TpPago       SMALLINT    DEFAULT 0;
   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_Moratorio    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntMoraCob   MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ManejaLinea  CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_SdoMoratorio MONEY(14,2) DEFAULT 0;
   DEFINE dSdoMoraOrdi          MONEY(14,2);
   DEFINE dSdoMoraCope          MONEY(14,2);

   DEFINE vPerContMora          CHAR(1);
   DEFINE vFechaCuota           DATE;
   DEFINE vProviMoraOrdi        LIKE sd_detmora.provi_mora_ordi;
   DEFINE vProviMoraCope        LIKE sd_detmora.provi_mora_cope;
   DEFINE vSdoMoraOrdi          LIKE sd_detmora.sdo_mora_ordi;
   DEFINE vSdoMoraCope          LIKE sd_detmora.sdo_mora_cope;
   DEFINE vMontoMora            LIKE sd_detmora.sdo_acum_mes_mora;
   DEFINE vCodigoRef            SMALLINT;

   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vIvadebe               LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaPagado             LIKE sd_amortiza_credito.iva_pagado;
   DEFINE vIvaAdeudo             LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaStatus             LIKE sd_amortiza_credito.iva_status;
   DEFINE vMoraIvaDebe           LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaPagado         LIKE sd_amortiza_credito.mora_iva_pagado;
   DEFINE vMoraIvaAdeudo         LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaStatus         LIKE sd_amortiza_credito.mora_iva_status;
   DEFINE vIvaBase		         DECIMAL(9,6);
   DEFINE GLOBAL g_IvaCte	     DECIMAL(9,6) DEFAULT 0;
   DEFINE GLOBAL csg_int_vdo	 MONEY(18,2) DEFAULT 0.00; --RQM 09 459
   DEFINE GLOBAL csg_int_moratorios		MONEY(18,2) DEFAULT 0.00; --RQM 09 459
   DEFINE GLOBAL csg_iva_int_vdo		MONEY(18,2) DEFAULT 0.00; --RQM 09 459
   DEFINE GLOBAL csg_iva_int_moratorios	MONEY(18,2) DEFAULT 0.00; --RQM 09 459	
   DEFINE GLOBAL g_MoraIva          MONEY(14,2) DEFAULT 0;	
   DEFINE vMoraIvaTran   DECIMAL(18,2);
   DEFINE vMoraTran      DECIMAL(18,2);   
   
	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "CobraMoratorios.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

   --SET DEBUG FILE TO "/home/tmp/MireyaR/cobramoratorios.out";
   --TRACE ON;
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT valor
	INTO vPerContMora
	FROM "informix".sd_param
	WHERE empresa = g_Empresa
	AND cod_param = '17';

	LET CodRet      = "000";
	LET vCodigoRef  = 1;
	LET vMontoMora  = 0;
	LET g_Moratorio = 0;
	LET g_Remanente_cq = g_Remanente_cq;
	LET vMoraIvaTran = 0;
	LET vMoraTran = 0;

	-- *************************************
	-- Calcula Iva de Intereses Moratorios *
	-- *************************************
	FOREACH
		SELECT fecha_cuota, mora_provi_ordi + mora_provi_cope
		INTO vFechaCuota, vMoraIvaDebe
		FROM "informix".sd_amortiza_credito
		WHERE num_credito = g_NumCredito
		AND empresa =  g_empresa
		AND capital_status IN ("2","7","6")
		AND (mora_provi_ordi + mora_provi_cope) > 0
		ORDER BY 1

		LET vMoraIvaDebe = vMoraIvaDebe * g_IvaCte;
		
		UPDATE "informix".sd_amortiza_credito
		SET mora_sdo_ordi = mora_sdo_ordi + mora_provi_ordi,
		mora_sdo_cope = mora_sdo_cope + mora_provi_cope,
		mora_provi_cope = 0,
		mora_provi_ordi = 0,
		mora_iva_debe = mora_iva_debe + vMoraIvaDebe
		WHERE num_credito = g_NumCredito
		AND empresa =  g_empresa
		AND fecha_cuota = vFechaCuota;
	END FOREACH
	
	UPDATE "informix".sd_maesdos SET sdo_contab_mora = 0,
	sdo_moratorio = sdo_moratorio + sdo_contab_mora 
	WHERE num_credito = g_NumCredito AND empresa =  g_empresa;	

	FOREACH
		SELECT fecha_cuota, (mora_iva_debe - mora_iva_pagado)
		INTO vFechaCuota, vMoraIvaDebe
		FROM "informix".sd_amortiza_credito a
		WHERE a.empresa   = g_empresa  AND a.num_credito = g_NumCredito
		AND capital_status IN ("2","7","6")  AND (mora_iva_debe - mora_iva_pagado) > 0
		ORDER BY fecha_cuota
		
		LET vMoraIvaTran = vMoraIvaTran + vMoraIvaDebe; --Para guardar el total del iva moratorio
		IF (g_Remanente_cq > 0) THEN
			IF g_Remanente_cq >= vMoraIvaDebe then
				LET g_Remanente_cq    = g_Remanente_cq - vMoraIvaDebe;
			ELSE
				LET vMoraIvaDebe = g_Remanente_cq;
				LET g_Remanente_cq    = 0;
			END IF;

			UPDATE "informix".sd_amortiza_credito
			SET mora_iva_pagado     = mora_iva_pagado + vMoraIvaDebe,
			mora_iva_fecha_pago = e_fcuota
			WHERE empresa     = g_empresa
			and   num_credito = g_NumCredito
			and   fecha_cuota = vFechaCuota;

			LET g_MoraIva = g_MoraIva + vMoraIvaDebe;
		END IF;	
	END FOREACH	
	
	--**Movimientos Contables IVA INTERES MORATORIO **--
	/*CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'111', e_fcuota, vMoraIvaTran, g_Folio, g_Sucursal, g_Divisa, '8386') 
	RETURNING CodRet, Mensaje;
	IF (CodRet <> "00000") THEN RETURN CodRet;
	ELSE  LET Codret = "000";  END IF;*/	
	
	-----------------------------------------------------
    --Para Rasurar Intereses Moratorios - Condonaciones y Quitas
	-----------------------------------------------------
	FOREACH
		SELECT fecha_cuota, mora_sdo_ordi - mora_sdo_ordi_pag, 
		mora_sdo_cope - mora_sdo_cope_pag
		INTO vFechaCuota, vSdoMoraOrdi, vSdoMoraCope
		FROM "informix".sd_amortiza_credito
		WHERE empresa = g_Empresa
		AND num_credito = g_NumCredito
		AND capital_status in ('2','7','6')
		AND (mora_sdo_ordi - mora_sdo_ordi_pag) + 
		(mora_sdo_cope - mora_sdo_cope_pag) > 0
		ORDER BY 1

		LET dSdoMoraOrdi = vSdoMoraOrdi;
		LET dSdoMoraCope = vSdoMoraCope;
		LET vMoraTran    = vMoraTran + vSdoMoraOrdi + vSdoMoraCope;	

		IF(g_Remanente_cq > 0) THEN
			/*IF(g_Remanente_cq >= vSdoMoraCope) THEN
				LET g_Remanente_cq   = g_Remanente_cq - vSdoMoraCope;
				LET vMontoMora    = vMontoMora + vSdoMoraCope;
			ELSE
				LET vSdoMoraCope  = g_Remanente_cq;
				LET vMontoMora    = vMontoMora + g_Remanente_cq;
				LET g_Remanente_cq   = 0;
			END IF;
			IF(g_Remanente_cq >= vSdoMoraOrdi) THEN
				LET g_Remanente_cq   = g_Remanente_cq - vSdoMoraOrdi;
				LET vMontoMora    = vMontoMora + vSdoMoraOrdi;
			ELSE
				LET vSdoMoraOrdi  = g_Remanente_cq;
				LET vMontoMora    = vMontoMora + g_Remanente_cq;
				LET g_Remanente_cq   = 0;
			END IF;*/


			UPDATE "informix".sd_amortiza_credito
			SET  mora_sdo_ordi_pag = mora_sdo_ordi_pag + vSdoMoraOrdi,
			mora_sdo_cope_pag = mora_sdo_cope_pag + vSdoMoraCope
			WHERE empresa = g_Empresa
			AND num_credito = g_NumCredito
			AND fecha_cuota = vFechaCuota;
			
			LET g_Moratorio = g_Moratorio + vMontoMora;
			--LET g_Moratorio  = 0;
			LET vSdoMoraOrdi = 0;
			LET vSdoMoraCope = 0;
		END IF;
	END FOREACH;
	
	-- Actualiza sd_maesdos
	LET g_Moratorio = g_Moratorio;
	
	UPDATE "informix".sd_maesdos
	SET sdo_moratorio = sdo_moratorio - g_Moratorio
	WHERE empresa = g_Empresa
	AND num_credito = g_NumCredito;
	
	--**Movimientos Contables Condonacion Quitas **--
	/*CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,'111', e_fcuota, vMoraTran, g_Folio, g_Sucursal, g_Divisa, '8385') 
	RETURNING CodRet, Mensaje;
	IF (CodRet <> "00000") THEN RETURN CodRet;
	ELSE  LET Codret = "000";  END IF;*/

	--LET g_IntMoraCob = g_IntMoraCob + g_Moratorio;
	LET g_Moratorio = 0;
	
RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el rasurado de intereses moratorios  para Quitas, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED',
'MODIFICACION: Se contemplan las transacciones 7795 y 7796 para condonacion de intereses moratorios para la TDC.',
'AUTOR : Mireya Gpe Reyes Vargas',
'FECHA : 3/enero/2014',
'FOLIO: 1395 - Condonacion de intereses para TDC,PP y CREDINOMINA .',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_saldos_ap_tdc(pEmpresa  CHAR (3),pNumcte CHAR (20))
  RETURNING CHAR (5), -- Codigo de retorno
            CHAR(40), -- Nombre producto
            CHAR(20), -- Numero credito
            CHAR(20), -- Numero tarjeta
            DECIMAL (14,2), -- 1 = Saldo al Cierre
            DECIMAL (14,2), -- 2 = Pago para no generar intereses
            DECIMAL (14,2), -- 3 = pago minimo al corte
            DECIMAL (14,2); -- 5 = Saldo actual TDC

 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE dSaldoCierre     DECIMAL (14,2);
DEFINE dPagonoInteres   DECIMAL (14,2);
DEFINE dMinimoCorte     DECIMAL (14,2);
DEFINE dSaldoActual     DECIMAL (14,2);
DEFINE nNumeroCredito   char(20);
DEFINE nNumeroTarjeta   char(20);
DEFINE cNombreProducto  char(40);
DEFINE cNumProducto     char(04);
DEFINE nContador        smallint;


LET sSqlErr = 0;
LET cCodRet = '00000';

LET dSaldoCierre    = 0;
LET dPagonoInteres  = 0;
LET dMinimoCorte    = 0;
LET dSaldoActual    = 0;
LET nNumeroCredito  = '';
LET nNumeroTarjeta  = '';
LET cNombreProducto = '';
LET cNumProducto    = '';
LET nContador       = 0;


BEGIN

    ON EXCEPTION SET sSqlErr
        LET cCodRet = sSqlErr;
        RETURN cCodRet, cNombreProducto, nNumeroCredito, nNumeroTarjeta, dSaldoCierre, dPagonoInteres, dMinimoCorte, dSaldoActual;
    END EXCEPTION;
	
	SET LOCK MODE TO wait 3;
	SET ISOLATION TO dirty READ;
	
	
    FOREACH 
        select num_credito, num_producto
          into nNumeroCredito, cNumProducto
          from bdicred:"informix".sd_maecred
         where numcte = pNumcte
           and status_cred in ('AA','BA','BT','E1','E2','E3')
           and num_producto in ('6001','6600','8100','7000','8500')

        let nContador = nContador + 1;

        select num_tarjeta
          into nNumeroTarjeta
          from bdicred:"informix".sd_tarjeta
         where num_credito = nNumeroCredito
           and tipo_tarjeta = 'T'
           and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where num_credito = nNumeroCredito and tipo_tarjeta = 'T');

        select nombre_prod
          into cNombreProducto
          from bdicred:"informix".sd_definicion
         where num_producto = cNumProducto;

         let cNombreProducto = trim(cNombreProducto);

        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,1) into cCodRet, dSaldoCierre;    --                1 = Saldo al Cierre
        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,2) into cCodRet, dPagonoInteres;  --                2 = Pago para no generar intereses
        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,3) into cCodRet, dMinimoCorte;    --                3 = pago minimo al corte
        execute procedure bdicred:sp_consultasaldocortemin(pEmpresa,nNumeroCredito,5) into cCodRet, dSaldoActual;    --                5 = Saldo actual TDC 

        RETURN cCodRet, cNombreProducto, nNumeroCredito, nNumeroTarjeta, dSaldoCierre, dPagonoInteres, dMinimoCorte, dSaldoActual WITH RESUME;
    END FOREACH;

    if (nContador = 0) then
       let cCodRet = '00001'; -- No cuenta con credito activos o asociados
       RETURN cCodRet, cNombreProducto, nNumeroCredito, nNumeroTarjeta, dSaldoCierre, dPagonoInteres, dMinimoCorte, dSaldoActual WITH RESUME;
    end if;

END;
END PROCEDURE;