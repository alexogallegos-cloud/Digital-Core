CREATE PROCEDURE "informix".cons_sdos1_web(pempresa CHAR(3),
                            pcuenta  CHAR(20),
                            ptarjeta CHAR(16))

RETURNING CHAR(5),	-- Codigo de Retorno
	  CHAR(20),	-- Numero de Credito
 	  CHAR(20),	-- Numero de Tarjeta
 	  CHAR(20),	-- Numero de Cliente
	  DECIMAL(14,2),-- Saldo Deudor
	  CHAR(60), 	-- Nombre Cliente
          DECIMAL(14,2),-- Pago Minimo
	  CHAR(10),	-- Fecha de Corte
	  CHAR(10),	-- Fecha Limite Pago
          DECIMAL(14,2),-- Saldo Disponible
	  DECIMAL(14,2), -- Saldo Retenido
          DECIMAL(14,2), -- Interes Moratorio
          DECIMAL(14,2); --  Iva Interes Moratorio

   DEFINE vCodRet             CHAR(5);
   DEFINE sql_err             INTEGER;
   DEFINE vNumCte             CHAR(20);
   DEFINE vNombreCte          CHAR(60);
   DEFINE vSdoDisponible      DECIMAL(14,2);
   DEFINE vPagoMin	          DECIMAL(14,2);
   DEFINE vFechaCorte         CHAR(10);
   DEFINE vFechaPago          CHAR(10);
   DEFINE vDisponible         DECIMAL(14,2);
   DEFINE vSdoRetenido        DECIMAL(14,2);
   define vSucursal           char(4);
   define vPorcIva            decimal(14,2);
   define vMoraConIva         decimal(14,2);
   DEFINE vIntMora            decimal(14,2);
   DEFINE vIvaIntMora       decimal(14,2);
--Jom ini agregar intereses vencido
   DEFINE vinteresvencido decimal(14,2);
   DEFINE vivacredito decimal(14,2);
   DEFINE vinteresmes decimal(14,2);
--   DEFINE vivames decimal(14,2);
   define vstatuscred char (02);
--Jom fin agregar intereses vencido

--- Inicializa Variables de Salida
    LET vCodRet        = "00000";
    LET vSdoDisponible = 0;
    LET vNumCte        = " ";
    LET vNombreCte     = " ";
    LET vPagoMin       = 0;
    LET vFechaCorte    = "";
    LET vFechaPago     = "";
    LET vDisponible    = 0;
    LET vSdoRetenido   = 0;
    Let vSucursal      = '0000';
    Let vPorcIva       = 0;
    Let vMoraConIva    = 0;
    LET vIntMora = 0;
    LET vIvaIntMora = 0;
--Jom ini agregar intereses vencido
    LET vinteresvencido = 0;
    LET vivacredito = 0;
    LET vinteresmes = 0;
--    LET vivames = 0;
    let vstatuscred = '';
--Jom fin agregar intereses vencido

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
         RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
             vNombreCte, vPagoMin, vFechaCorte, vFechaPago, vDisponible,
	     vSdoRetenido,vIntMora,vIvaIntMora;
      END IF;
   END EXCEPTION;

   --SET DEBUG FILE TO "/tmp/consdo1.out";
   --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
   
IF SUBSTR(NVL(pcuenta,''),1,2) =  '78' THEN


	SELECT  numcte
	INTO  vNumCte
	FROM sd_maecred
	WHERE empresa = pempresa
	AND num_credito = pcuenta;

ELSE

   IF pcuenta IS NULL OR LENGTH(pcuenta) = 0 THEN

   -- Valida que la tarjeta este activa
	SELECT num_credito, numcte
	  INTO pcuenta , vNumCte
	  FROM sd_tarjeta
	 WHERE empresa = pempresa
	   AND num_tarjeta = ptarjeta
	   AND status_tar = "A";

    IF pcuenta IS NULL THEN
-- valida ultima tarjeta cancelada
        SELECT num_credito, numcte
        INTO pcuenta , vNumCte
        from bdicred:sd_tarjeta
       where empresa = pempresa
         and num_tarjeta = ptarjeta
         and status_tar = "C"
         and tipo_tarjeta != 'A'
         and secuencia = (
             select max(secuencia)
               from bdicred:sd_tarjeta
              where empresa = pempresa
                and num_tarjeta = ptarjeta
                and tipo_tarjeta != 'A'
                and status_tar = "C");
    end if;

	IF pcuenta IS NULL THEN
	   LET vCodRet ="00100";
           RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
                  vNombreCte, vPagoMin, vFechaCorte, vFechaPago,
		  vDisponible, vSdoRetenido,vIntMora,vIvaIntMora;
	END IF;

   ELSE
	SELECT num_tarjeta, numcte
	  INTO ptarjeta, vNumCte
	  FROM bdicred:sd_tarjeta sd
      JOIN intercard:tarjeta tar ON sd.num_tarjeta = tar.numtarjeta
	WHERE sd.empresa = pempresa
	  AND sd.num_credito = pcuenta
	  AND sd.tipo_tarjeta = "T"
	  AND sd.status_tar = "A"
     AND tar.codstatustarjeta = 'ACT';
									  
    IF ptarjeta IS NULL THEN
-- valida ultima tarjeta cancelada
	  SELECT num_tarjeta, numcte
	    INTO ptarjeta, vNumCte
        from bdicred:sd_tarjeta
       where empresa = pempresa
         AND num_credito = pcuenta
         AND tipo_tarjeta = "T"
         AND status_tar = "C"
         and secuencia = (
             select max(secuencia)
               from bdicred:sd_tarjeta
              where empresa = pempresa
                AND num_credito = pcuenta
                AND tipo_tarjeta = "T"
                and status_tar = "C");
    end if;

	IF ptarjeta IS NULL THEN
	   LET vCodRet ="00008";
           RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
                  vNombreCte, vPagoMin, vFechaCorte, vFechaPago,
		  vDisponible, vSdoRetenido,vIntMora,vIvaIntMora;
	END IF
   END IF
END IF
   SELECT TRIM(NVL(razon_social, ' ')) ||
          TRIM(nombre1) || " " ||
          TRIM(NVL(nombre2, ' ')) || " " ||
          TRIM(apell_paterno) || " " ||
          TRIM(apell_materno)
     INTO vNombreCte
     FROM bdinteg:si_cliente
    WHERE numcte = vNumCte;

   SELECT (c.sdo_cap_insoluto + c.sdo_retenido),
	  monto_financiado,
          f.fecha_hoy, e.prox_fecha_pago,
	  monto_otorgado - (sdo_cap_insoluto + sdo_retenido),
	  sdo_retenido, sucursal,
--jom ini se agrega interes vencido
      status_cred,
      int_tra_no_exig Interes_vencido,
      nvl((SELECT SUM(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status in ('2','7','6')),0) iva_interes,
      nvl((SELECT SUM(interes_debe - interes_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status = '1'),0) interes_mes
--     ,nvl((SELECT SUM(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status = '1'),0) iva_mes
--jom ini se agrega interes vencido
     INTO vSdoDisponible, vPagoMin, vFechaCorte, vFechaPago,
	  vDisponible, vSdoRetenido, vSucursal,
      vstatuscred,
      vinteresvencido, vivacredito, vinteresmes --, vivames
     FROM sd_maecred b, sd_maesdos c, sd_maecredanexo e,
	  sd_fechas f
    WHERE b.empresa = pempresa
      AND b.num_credito = pcuenta
      AND c.empresa = b.empresa
      AND c.num_credito = b.num_credito
      AND e.empresa = b.empresa
      AND e.num_credito = b.num_credito
      AND f.empresa = b.empresa;

-- cartera vendida
      if ( vstatuscred = 'CV' ) then
	   LET vCodRet ="00015";
           RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
                  vNombreCte, vPagoMin, vFechaCorte, vFechaPago,
		  vDisponible, vSdoRetenido,vIntMora,vIvaIntMora;
      END IF;

--  credito cancelado
      IF ( vstatuscred = 'FF' ) then
	   LET vCodRet ="00279";
           RETURN vCodRet,'','','',0,
                  '', 0, date(1), date(1),
		  0, 0,0,0;
      END IF;

      SELECT iva INTO vPorcIva
        FROM bdinteg:si_sucursales
       WHERE empresa = pempresa
   	     AND sucursal = vSucursal;

-- jom ini se agregan los intereses vencidos al saldo  y al pago minimo
     if ( vstatuscred IN ('BT','E2','E3') and NVL(vinteresvencido,0) > 0 ) then
         let vPagoMin = vPagoMin + vinteresvencido + vivacredito;
         let vSdoDisponible = vSdoDisponible + vinteresvencido + vivacredito;

         if ( vinteresvencido > 0 ) then
            let vPagoMin = vPagoMin - vinteresmes;
            let vSdoDisponible = vSdoDisponible - vinteresmes;
         end if;
     end if;

-- jom fin se agregan los intereses vencidos al saldo  y al pago minimo

{ Se comentariza para desgloce de moratorios

      SELECT (sum(nvl(mora_provi_ordi,0)) + sum(nvl(mora_provi_cope,0))) *
	     (1 + nvl(vPorcIva,0)) as mora
      INTO vMoraConIva
      FROM bdicred:sd_amortiza_credito
      WHERE empresa = pempresa
      AND num_credito = pcuenta;

      IF vMoraConIva < 0 THEN
        LET vMoraConIva = 0;
      END IF;

      LET vPagoMin = vPagoMin + vMoraConIva;
}

     SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) + Sum(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag))
     INTO vIntMora
     FROM sd_amortiza_credito
     WHERE  empresa = pempresa
     AND num_credito = pcuenta
     AND capital_status IN ("2","7","6");
--     AND (mora_sdo_ordi - mora_sdo_ordi_pag) + (mora_sdo_cope - mora_sdo_cope_pag) > 0 ;

      IF  vIntMora IS NULL OR  vIntMora < 0 THEN
            LET vIntMora = 0;
      END IF;

     SELECT SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * vPorcIva)-mora_iva_pagado)
     INTO vIvaIntMora
     FROM sd_amortiza_credito
     WHERE  num_credito = pcuenta
     AND empresa = pempresa
     AND capital_status IN ("2","7","6")
     AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * vPorcIva)) > 0;

     IF  vIvaIntMora  IS NULL OR  vIvaIntMora < 0 THEN
            LET vIvaIntMora = 0;
     END IF;

-- jom ini se agregan los moratorios al saldo
    let vSdoDisponible = vSdoDisponible + vIntMora + vIvaIntMora;
-- jom fin se agregan los moratorios al saldo

    RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
           vNombreCte, vPagoMin, vFechaCorte, vFechaPago, vDisponible,
	   vSdoRetenido,vIntMora,vIvaIntMora;

END
END PROCEDURE
DOCUMENT
'Consulta de Saldos y Pago minimo en plataforma',
'AUTOR : Antonio Ruiz Mtz',
'FECHA : 04/Septiembre/2007',
'VERSION: 1.00.000',
'BD    : BDICRED',
'--------------------------',
'DSB 12/04/2011',
'ModificÃÂ³: Josue Zepeda',
'Se valido para que no muestre tarjetas cuando sea adicional y cancelada.',
'--------------------------',
'FECHA: 05/03/2024',
'Modificacion: Victor Vazquez',
'Se agrega validacion para solo mostrar la tarjeta activa que exista en intercard y bdicred',
'--------------------------';

CREATE PROCEDURE "informix".sp_consulta_vencido_bancoppel(pNumCliente CHAR(9), pTipoCliente CHAR(1), gen1 CHAR(50), gen2 CHAR(50), gen3 CHAR(50))
	RETURNING 	CHAR(6) AS CodigoRetorno, 
				CHAR(50) AS MensajeRetorno, 
				CHAR(9) AS NumCliente, 
				CHAR(1) AS IdVencido, 
				CHAR(1) AS IdSaturacion;

	DEFINE iSqlErr           	INTEGER;
    DEFINE iIsamErr          	INTEGER;
	DEFINE resultadoVencido 	DECIMAL(10,2);
	DEFINE cSaturacion 			DECIMAL(10,2);
	
	DEFINE cCodRet           	CHAR(6);
	DEFINE cErrorInfo        	CHAR(50);
	DEFINE cMensajeRet       	CHAR(50);
	DEFINE sNumeroCliente 		CHAR (15);
	DEFINE sIdVencido			INTEGER;
	DEFINE sIdSaturacion		INTEGER;
		
	DEFINE vSaldo				DECIMAL(10,2);
	DEFINE vLineaCredito		DECIMAL(10,2);
	DEFINE vPagoMinimoTotal		DECIMAL(10,2);
	DEFINE vMontoVencidoTotal	DECIMAL(10,2);
	DEFINE vLineaCreditoTotal 	DECIMAL(10,2);
	DEFINE vSaldoTotal			DECIMAL(10,2);
	DEFINE vNumCred				CHAR(15);
	DEFINE vMontoVencido 		DECIMAL(10,2);
	DEFINE vNumProd				CHAR(4);
	
	--Variables pago_minimo
	DEFINE cEmpresa          	CHAR(3);
	
	--Variables de retorno pago_minimo
	DEFINE vvcodigo_retorno 				CHAR(6);
	DEFINE vvmensaje_retorno				CHAR(80);
	DEFINE dMontoFinanciado  				DECIMAL(18,2);
	DEFINE dIntVdo           				DECIMAL(18,2);
	DEFINE dIntMoratorio     				DECIMAL(18,2);
	DEFINE dIvaIntVdo        				DECIMAL(18,2);
	DEFINE dPagosVdos						DECIMAL(18,2);
	DEFINE dIvaIntMoratorio  				DECIMAL(18,2);
	DEFINE dIntMes 							DECIMAL(18,2);
	DEFINE dIvaIntMes 						DECIMAL(18,2);
	DEFINE dIntVig 							DECIMAL(18,2);
	DEFINE dIvaIntVig 						DECIMAL(18,2);
	
	DEFINE dPagoMinimo       	DECIMAL(18,2);
	DEFINE vNoReg				INTEGER;

	LET vPagoMinimoTotal		= 0;
	LET resultadoVencido 		= 0;
	LET cSaturacion				= 0;
	LET vSaldo 					= 0;
	LET vLineaCredito 			= 0;
	LET iSqlErr             	= 0;
	LET iIsamErr             	= 0;
	
	LET cCodRet					= '00000';
	LET cErrorInfo           	= '';
	LET cMensajeRet				= 'CONSULTA EXITOSA';
	LET sIdVencido				= null;
	LET sIdSaturacion			= null;
	LET sNumeroCliente			= '';
	LET vMontoVencidoTotal		= 0;
	LET vLineaCreditoTotal 		= 0;
	LET vSaldoTotal				= 0;
	LET vNumCred 				= '';
	LET vMontoVencido 			= 0;
	LET cEmpresa             	= '001';
	LET vvcodigo_retorno 		= '';
	LET vvmensaje_retorno		= '';
	LET dMontoFinanciado  		= 0;
	LET dIntVdo           		= 0;
	LET dIntMoratorio         	= 0;
	LET dIvaIntVdo        		= 0;
	LET dPagosVdos				= 0;
	LET dIvaIntMoratorio  		= 0;
	LET dIntMes 				= 0;
	LET dIvaIntMes 				= 0;
	LET dIntVig 				= 0;
	LET dIvaIntVig 				= 0;
	LET dPagoMinimo           	= 0;
	LET vNoReg					= 0;
	LET vNumProd				= '';


	BEGIN	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	    	IF iSqlErr != 0 THEN
	      		LET cCodRet = iSqlErr;
	      		LET cMensajeRet = iIsamErr||' - '||cErrorInfo ;
	      		RETURN cCodRet, cMensajeRet, sNumeroCliente, sIdVencido, sIdSaturacion;
	    	END IF;
	 	END EXCEPTION;
		
		--SET debug file to '/informix/sp_consulta_vencido_bancoppel.out';
		--trace on;
		

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF (pNumCliente = '' OR pTipoCliente = '')THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'FALTAN PARAMETROS';
			RETURN cCodRet, cMensajeRet, sNumeroCliente, sIdVencido, sIdSaturacion;
		END IF;
		
		IF pTipoCliente = '1' THEN
			--CONSULTA PARA OBTENER NUMERO DE CLIENTE BANCOPPEL
			SELECT numcte_banco INTO sNumeroCliente FROM bdinteg:"informix".si_relacion_ctebcplcpl where cliente = pNumCliente;
		ELSE
			LET sNumeroCliente = pNumCliente;
		END IF;
		
		IF (NVL(sNumeroCliente, '') = '')THEN
			LET cCodRet = '00002';
			LET cMensajeRet = 'NO SE ENCONTRO NO. DE CLIENTE';
			RETURN cCodRet, cMensajeRet, sNumeroCliente, sIdVencido, sIdSaturacion;
		END IF;
		
		---CONSULTA PARA TDC---
		FOREACH WITH HOLD 
				SELECT num_credito INTO vNumCred 
				FROM bdicred:informix.sd_maecred 
				WHERE numcte = sNumeroCliente AND  
				status_cred IN ('E1', 'E2','E3')
				
			SELECT monto_vencido, 
				   monto_otorgado, 
				   NVL(sdo_cap_insoluto,0)
			INTO vMontoVencido,
				 vLineaCredito,
				 vSaldo
			FROM bdicred:informix.sd_maesdos
			WHERE num_credito = vNumCred;
			
			--------------------------------PAGO MINIMO TDC-----------------------------------------
			
			EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(cEmpresa, vNumCred)
			INTO vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio,dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
			
			IF vvcodigo_retorno != '000000' THEN
				LET cCodRet = SUBSTR(vvcodigo_retorno,2);
				LET cMensajeRet = vvmensaje_retorno;
				RETURN cCodRet, cMensajeRet, '', sIdVencido, sIdSaturacion;
			END IF;
			
			---------------------------------------------------------------------------------------
			LET vPagoMinimoTotal = vPagoMinimoTotal + dPagoMinimo;
			LET vMontoVencidoTotal = vMontoVencidoTotal + vMontoVencido;
			LET vLineaCreditoTotal = vLineaCreditoTotal + vLineaCredito;
			LET vSaldoTotal = vSaldoTotal + vSaldo;
			LET vNoReg = vNoReg + 1;
		END FOREACH;
		----------------------------------------

		
		---CONSULTA PRESTAMOS Y REESTRUCTURAS---
		FOREACH WITH HOLD
				SELECT num_credito ,
						num_producto
				INTO vNumCred,
						vNumProd
				FROM bdicred:informix.sd_maecredcrd 
				WHERE numcte = sNumeroCliente AND 
				status_cred IN ('E1', 'E2','E3') 
				
				IF vNumProd = '6800' THEN
					SELECT 	md.monto_vencido, 
							pd.monto_linea, 
							NVL(md.sdo_cap_insoluto,0),
							NVL(md.monto_financiado,0)
					INTO vMontoVencido,
						vLineaCredito,
						vSaldo,
						dMontoFinanciado
					FROM 'informix'.sd_maesdoscrd md,
						 'informix'.sd_linea_prestamo pd
					WHERE md.num_credito = vNumCred AND
						md.num_credito = pd.num_credito;
				ELSE
					SELECT monto_vencido, 
						   monto_otorgado, 
							NVL(sdo_cap_insoluto,0),
							NVL(monto_financiado,0)
					INTO vMontoVencido,
						vLineaCredito,
						vSaldo,
						dMontoFinanciado
					FROM bdicred:informix.sd_maesdoscrd 
					WHERE num_credito = vNumCred;
				END IF;	
		
				--------------------------------PAGO MINIMO PRESTAMOS Y RESTRUCTURAS-----------------------------------------
				EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(cEmpresa, vNumCred)
				INTO vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio,dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
				
				
				IF vvcodigo_retorno != '000000' THEN
					LET cCodRet = SUBSTR(vvcodigo_retorno,2);
					LET cMensajeRet = vvmensaje_retorno;
					RETURN cCodRet, cMensajeRet, '', sIdVencido, sIdSaturacion;
				END IF;
			-----------------------------------------------------------------------------
			
				LET vPagoMinimoTotal = vPagoMinimoTotal + dPagoMinimo;
				LET vMontoVencidoTotal = vMontoVencidoTotal + vMontoVencido;
				LET vLineaCreditoTotal = vLineaCreditoTotal + vLineaCredito;
				LET vSaldoTotal = vSaldoTotal + vSaldo;
				LET vNoReg = vNoReg + 1;
		END FOREACH;
		-------------------------------
		
		
		IF vNoReg > 0 THEN
			
			IF NVL(vMontoVencidoTotal,0) <> 0 AND NVL(vPagoMinimoTotal,0) <> 0 THEN
				LET resultadoVencido = vMontoVencidoTotal / vPagoMinimoTotal;
			ELSE
				LET sIdVencido = 0;
			END IF;
			
			IF NVL(vSaldoTotal,0) <> 0 AND NVL(vLineaCreditoTotal,0) <> 0 THEN
				LET cSaturacion = (vSaldoTotal / vLineaCreditoTotal) * 100.0;
			ELSE
				LET sIdSaturacion = 0 ;
			END IF;
			
			IF sIdVencido IS NULL THEN
				SELECT 
						id 
				INTO 
					sIdVencido 
				FROM 'informix'.sd_param_vencido_saturacion 
				WHERE tipo_id = 'Vencido' AND
					resultadoVencido BETWEEN rango_ini AND rango_fin;
			END IF;

			IF sIdSaturacion IS NULL THEN
				SELECT {+INDEX('informix'.sd_param_vencido_saturacion sd_param_vencido_saturacion_tipo_id_idx)}  
						id
				INTO 
					sIdSaturacion
				FROM 'informix'.sd_param_vencido_saturacion 
				WHERE tipo_id = 'Saturacion' AND
					cSaturacion BETWEEN rango_ini AND rango_fin;
			END IF;
			
			IF sIdSaturacion IS NULL OR sIdVencido IS NULL THEN
				LET cCodRet = '00004';
				LET cMensajeRet = 'ID DE SATURACION O VENCIDO NO DEFINIDO';
			END IF;
		ELSE 
			LET cCodRet = '00003';
			LET cMensajeRet = 'CTE SIN NUMEROS DE CREDITO';
		END IF;
		
		RETURN cCodRet, cMensajeRet, sNumeroCliente, sIdVencido, sIdSaturacion;
  
	END;
END PROCEDURE
DOCUMENT
'PROYECTO: RQM 09 652 MODIFICACION RESTRICCION DE VENTA A CREDITO A CLIENTES CON VENCIDO BANCOPPEL',
'DESCRIPCION: CONSULTAR EL VENCIDO BANCOPPEL Y SATURACION DEL CLIENTE.',
'AUTOR: KEVIN GALVEZ PARRA',
'BD: BDICRED',
'FECHA: 30/01/2024',
'SOLICITA: GERMAN REYNAGA MURUA';

CREATE PROCEDURE "informix".consultmovscre_tipo_bpi(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro SMALLINT)
   RETURNING CHAR(5),DATE,CHAR(23),CHAR(40),CHAR(1),MONEY(14,2),MONEY(14,2),CHAR(4),CHAR(1), CHAR(40), MONEY(14,2);

    -----------------------------------------------------------------------------------------------------------------------
    --SE CLONA SPL: Berenice Noriega
    --Fecha: 16/MAYO/2019
    --Solicita: Alejandro Vazquez
    --Actividad: Se regresa parametros extras que indica si es titular o adicional el movimiento asi como la terminacion
    --Se renombra spl de consultmovscre_bpi a consultmovscre_tipo_bpi   
    --Proximo a liberar 
    --Se ajusta para no traer movimientos de cargos pagos fijos
    -----------------------------------------------------------------------------------------------------------------------

   DEFINE cDescripcion     CHAR(40);
   DEFINE vfecha        DATE;
   DEFINE vmonto        MONEY(14,2);
   DEFINE vserial       INTEGER;
   DEFINE vReferencia    CHAR(23);
   DEFINE vRefTotal CHAR(100);
   DEFINE vReferencia23  CHAR(23);
   DEFINE vcodret       CHAR(5);
   DEFINE vsqlerr       INTEGER;
   DEFINE vnaturaleza   CHAR(1);
   DEFINE vSdoDeudor    DECIMAL(14,2);
   DEFINE vRfcComer     CHAR(15);
   DEFINE vTrans     CHAR(4);
   DEFINE vTarjeta   CHAR(20);
   DEFINE vTerminacion CHAR(4);
   DEFINE vTipo         CHAR(1);
   DEFINE cFolioSuc		CHAR(16);
   DEFINE cDescripcionMovdescpos	CHAR(50);
   
   DEFINE vNumPagoFijo CHAR(12);
   DEFINE vCapitalInsoluto DECIMAL(14,2);
   DEFINE cPeriodo CHAR(40);
   DEFINE cDescripcionCapital   MONEY(14,2);
   DEFINE vReferencia2    CHAR(40);
   DEFINE cDescripcionTransfun     CHAR(40);

   LET vcodret = "000";
   LET cDescripcion = " ";
   LET vfecha = '01/01/1900';
   LET vmonto = 0;
   LET vSdoDeudor = 0;
   LET vnaturaleza = '';
   LET vReferencia = '';
   LET vReferencia23 = '';
   LET vserial = 0;
   LET vsqlerr = 0;
   LET vRfcComer = '';
   LET vTrans = '';
   LET vTarjeta ='';
   LET vTerminacion ='';
   LET vTipo ='';
   LET cFolioSuc =	"";
   LET cDescripcionMovdescpos =	"";
   
   LET vNumPagoFijo = "";
   LET vCapitalInsoluto = 0;
   LET cPeriodo = "";
   LET cDescripcionCapital = 0;
   LET vReferencia2 = '';
   LET cDescripcionTransfun = '';
   
   BEGIN
      ON EXCEPTION SET vsqlerr
         IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor,vTerminacion,vTipo, cPeriodo, cDescripcionCapital;
         END IF
      END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

      SELECT a.sdo_cap_insoluto
      INTO vSdoDeudor
      FROM sd_maesdos a, sd_maecredanexo b, sd_fechas c
      WHERE a.empresa = pempresa
      AND a.num_credito= pcuenta
      AND b.empresa = a.empresa
      AND b.num_credito = a.num_credito
      AND c.empresa = a.empresa;

      IF vSdoDeudor IS NULL THEN
         LET vSdoDeudor = 0;
         LET vcodret = "100";
         RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor, vTerminacion, vTipo, cPeriodo, cDescripcionCapital;
      END IF;

     -- Extrae los movimientos del rango de fechas especificado
     FOREACH
       (
        SELECT SKIP pRegistro FIRST 10
            a.secuencia, fecha_mov,
            CASE WHEN NVL(TRIM(a.referencia),'') = ''
            THEN c.transacc
              ELSE TRIM(a.referencia) END
              CASE,
            b.descripcion, naturaleza, monto, a.referencia23, a.rfc_comer, b.numero, d.num_tarjeta, d.tipo_tarjeta, a.folio_suc, c.descripcion
            INTO vserial,vfecha,vRefTotal,cDescripcion,vnaturaleza,vmonto, vReferencia23, vRfcComer, vTrans, vTarjeta, vTipo, cFolioSuc,cDescripcionTransfun
             FROM sd_movdia a
                JOIN sd_transfun c ON (a.codigo_fun = c.codigo_fun and a.codigo_ref = c.codigo_ref)
                JOIN bdinteg:si_transacc b ON (c.transacc = b.numero)
                LEFT OUTER JOIN sd_tarjeta d ON (a.nro_tarjeta=d.num_tarjeta)
             WHERE a.empresa = pempresa
             AND a.num_credito = pcuenta
             AND b.sistema = "06"
             AND b.se_emite_edocta = "S"
             AND a.reversado = "N"
			 AND b.numero NOT IN ('4200','4245','4220') --Filtro de movimientos pagos fijos
             AND fecha_mov between pFechaInicial and pFechaFinal

        UNION ALL
        SELECT a.secuencia, fecha_mov,
            CASE WHEN NVL(TRIM(a.referencia),'') = ''
              THEN c.transacc
            ELSE TRIM(a.referencia) END CASE,
            b.descripcion, naturaleza, monto, a.referencia23, a.rfc_comer, b.numero, d.num_tarjeta, d.tipo_tarjeta, a.folio_suc, c.descripcion
             FROM sd_movhis a
                JOIN sd_transfun c ON (a.codigo_fun = c.codigo_fun and a.codigo_ref = c.codigo_ref)
                JOIN bdinteg:si_transacc b ON (c.transacc = b.numero)
                LEFT OUTER JOIN sd_tarjeta d ON (a.nro_tarjeta=d.num_tarjeta)
             WHERE a.empresa = pempresa
             AND a.num_credito = pcuenta
             AND b.sistema = "06"
             AND b.se_emite_edocta = "S"
             AND a.reversado = "N"
			 AND b.numero NOT IN ('4200','4245','4220') --Filtro de movimientos pagos fijos
             AND fecha_mov between pFechaInicial and pFechaFinal
         )

          ORDER BY d.tipo_tarjeta DESC, d.num_tarjeta ASC, fecha_mov DESC, secuencia DESC

         IF vnaturaleza = "C" THEN
		 
            LET vmonto = (vmonto*(-1));
			
         END IF;

         IF (vTrans = '6801' or vTrans = '6830') THEN

                LET cDescripcion = TRIM(SUBSTRING(vRefTotal FROM 16));
                LET vReferencia = NVL(TRIM(vReferencia23),'');
				
                IF cDescripcion[1,8] = "intercar" THEN
				
                        LET cDescripcion = TRIM(SUBSTRING(cDescripcion FROM 16));
						
                END IF;
				
                LET cDescripcion = TRIM(cDescripcion) || " " || NVL(TRIM(vRfcComer),'');
        ELSE
            LET vReferencia = TRIM(vRefTotal);
        END IF;

        IF (vTrans = '6813' or vTrans = '6830') THEN

                SELECT NVL(TRIM(nomcomercio325),'')  INTO cDescripcionMovdescpos FROM bdicred:sd_movdescpos WHERE num_credito = pCuenta AND folio_suc = cFolioSuc ;

                IF cDescripcionMovdescpos  <> '' THEN 
				
                        LET cDescripcion = TRIM(cDescripcionMovdescpos) || " " || TRIM(cFolioSuc);
						
                END IF;

        END IF;
                
        IF (vTarjeta='' or vTarjeta is null) THEN
            LET vTipo='S';
            LET vTerminacion='';
        ELSE 
            LET vTarjeta = NVL(TRIM(vTarjeta),'');
            LET vTerminacion = SUBSTR(vTarjeta,13,4); 
        END IF;
		
		LET cPeriodo = '';
		LET cDescripcionCapital = 0;
		
         RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor, vTerminacion, vTipo, cPeriodo, cDescripcionCapital WITH RESUME;
     END FOREACH;
END
END PROCEDURE;