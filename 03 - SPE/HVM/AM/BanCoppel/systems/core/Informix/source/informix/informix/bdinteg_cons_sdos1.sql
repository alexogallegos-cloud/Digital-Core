CREATE PROCEDURE "informix".cons_sdos1(pempresa CHAR(3),
                            pcuenta  CHAR(20),
                            ptarjeta CHAR(16))

RETURNING CHAR(5),	-- Codigo de Retorno
	  CHAR(20),	-- Numero de Credito
 	  CHAR(20),	-- Numero de Tarjeta
 	  CHAR(20),	-- Numero de Cliente
	  DECIMAL(14,2),-- Saldo Disponible
	  CHAR(60);	-- Nombre Cliente

   DEFINE vCodRet             CHAR(5);
   DEFINE sql_err             INTEGER;
   DEFINE vNumCte             CHAR(20);
   DEFINE vNombreCte          CHAR(60);
   DEFINE vSdoDisponible      DECIMAL(14,2);



--- Inicializa Variables de Salida
    LET vCodRet        = "000";
    LET vSdoDisponible = 0;
    LET vNumCte        = " ";
    LET vNombreCte     = " ";
BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
         RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
             vNombreCte;
      END IF;
   END EXCEPTION;

   IF pcuenta IS NULL OR LENGTH(pcuenta) = 0 THEN
	SELECT num_credito INTO pcuenta 
	  FROM sd_tarjeta
	 WHERE empresa = pempresa
	   AND num_tarjeta = ptarjeta
	   AND tipo_tarjeta = "T";
	IF pcuenta IS NULL THEN
	   LET vCodRet ="008";
           RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
                  vNombreCte;
	END IF
   ELSE
	SELECT num_tarjeta INTO ptarjeta
	  FROM sd_tarjeta
	 WHERE empresa = pempresa
	   AND num_credito = pcuenta
	   AND tipo_tarjeta ="T";
	IF ptarjeta IS NULL THEN
	   LET vCodRet ="008";
           RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
                  vNombreCte;
	END IF
   END IF


   SELECT a.num_credito, a.num_tarjeta, b.numcte,
	  c.monto_otorgado - (c.sdo_cap_insoluto + c.sdo_retenido),
	  TRIM(NVL(d.razon_social, ' ')) ||
	  TRIM(d.nombre1) || " " ||
	  TRIM(NVL(d.nombre2, ' ')) || " " ||
	  TRIM(d.apell_paterno) || " " ||
	  TRIM(d.apell_materno)
     INTO pcuenta, ptarjeta, vNumCte, vSdoDisponible, vNombreCte
     FROM sd_tarjeta a, sd_maecred b, sd_maesdos c, 
	  bdinteg:si_cliente d 
    WHERE a.empresa = pempresa
      AND a.num_credito = pcuenta
      AND a.tipo_tarjeta = "T"
      AND b.empresa = a.empresa
      AND b.num_credito = pcuenta
      AND c.empresa = b.empresa
      AND c.num_credito = b.num_credito
      AND d.numcte = b.numcte; 
         
        
    RETURN vCodRet, pcuenta, ptarjeta, vNumCte, vSdoDisponible,
           vNombreCte; 
END
END PROCEDURE;