CREATE PROCEDURE "informix".cons_sdos_bpi(pempresa CHAR(3),
                            pcuenta  CHAR(20),
                            ptarjeta CHAR(16))

RETURNING CHAR(5),	-- Codigo de Retorno
	 	  DECIMAL(14,2),-- Saldo Deudor
          DECIMAL(14,2),-- Pago Minimo
	      CHAR(10),	-- Fecha Limite Pago
          DECIMAL(14,2); -- Saldo Disponible

   -- Realizó: Mauricio León
   -- Actividad: Obtener el saldo de un crédito
   -- Solicitó: Mauricio León
   -- Fecha:  20/10/2008
   -------------------------------------------------------
   -- Modificó: Mauricio León
   -- Actividad: Se agrega instrucción SET ISOLATION
   -- Fecha:  22/06/2009

-- Definición de variables
   DEFINE vCodRet             CHAR(5);
   DEFINE sql_err             INTEGER;
   DEFINE vSdoDisponible      DECIMAL(14,2);
   DEFINE vPagoMin	          DECIMAL(14,2);
   DEFINE vFechaPago          CHAR(10);
   DEFINE vDisponible         DECIMAL(14,2);
   DEFINE vCuenta			  char(12);
--- Inicialización de Variables de Salida
    LET vCodRet        = "000";
    LET vSdoDisponible = 0;
    LET vPagoMin       = 0;
    LET vFechaPago     = "";
    LET vDisponible    = 0;
    LET vCuenta		   = 0;
BEGIN

--SET DEBUG FILE TO "/tmp/consdo_bpi.out";
--TRACE ON;

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
         RETURN vCodRet, vSdoDisponible,
             vPagoMin, vFechaPago, vDisponible;
      END IF;
   END EXCEPTION;

    SET ISOLATION DIRTY READ ;

    IF TRIM(NVL(pcuenta,'')) = '' OR pcuenta IS NULL THEN
        SELECT num_credito INTO vCuenta FROM sd_tarjeta WHERE  num_tarjeta = ptarjeta;		
    ELSE
        LET vCuenta = pcuenta;
    END IF	
	
    SELECT (c.sdo_cap_insoluto + c.sdo_retenido),
              monto_financiado,
              e.prox_fecha_pago,
              monto_otorgado - (sdo_cap_insoluto + sdo_retenido)
         INTO vSdoDisponible, vPagoMin, vFechaPago, vDisponible
         FROM sd_maesdos c, sd_maecredanexo e
         WHERE c.empresa = pempresa
         AND c.num_credito = vCuenta
         AND e.empresa = c.empresa
         AND e.num_credito = c.num_credito;

    RETURN vCodRet, vSdoDisponible, vPagoMin, vFechaPago, vDisponible;
   
END

END PROCEDURE ;