CREATE PROCEDURE "informix".act_cuota_periodo(pFecha   DATE) 
RETURNING CHAR(5);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret      CHAR(5);
   DEFINE sql_err      SMALLINT;
   DEFINE isam_err     SMALLINT;
   DEFINE error_info   CHAR(40);
   DEFINE vFecha       DATE;
   DEFINE vCapital     DECIMAL(14,2);
   DEFINE vStCap       CHAR(1);
   DEFINE vStCapAnt    CHAR(1);
   DEFINE vInteres     DECIMAL(14,2);
   DEFINE vStInt       CHAR(1);
   DEFINE vStIntAnt    CHAR(1);
   DEFINE vIvaInt      DECIMAL(14,2);
   DEFINE vStIvaInt    CHAR(1);
   DEFINE vStIvaIntAnt CHAR(1);
   DEFINE vMora        DECIMAL(14,2);
   DEFINE vStMora      CHAR(1);
   DEFINE vIvaMora     DECIMAL(14,2);
   DEFINE vStIvaMora   CHAR(1);
   DEFINE vMensaje     VARCHAR(100);
   DEFINE nrows	       SMALLINT;

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;


  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret      = "000";
   LET vFecha	  = "";
   LET vMensaje     = "";
   LET vCapital     = 0;
   LET vStCap       = "";
   LET vStCapAnt    = "";
   LET vInteres     = 0;
   LET vStInt       = "";
   LET vStIntAnt    = "";
   LET vIvaInt      = 0;
   LET vStIvaInt    = "";
   LET vStIvaIntAnt = "";
   LET vMora        = 0;
   LET vStMora	  = "";
   LET vIvaMora     = 0;
   LET vStIvaMora   = "";

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	
	  LET vFecha = pFecha - 1 UNITS MONTH;

        SELECT (capital_debe - capital_pagado), capital_status,
               (interes_debe - interes_pagado), interes_status, 
               (iva_debe - iva_pagado), iva_status,
               ((mora_sdo_ordi + mora_sdo_cope) -
               (mora_sdo_ordi_pag + mora_sdo_cope_pag)), mora_status,
               (mora_iva_debe - mora_iva_pagado), mora_iva_status
	    INTO vCapital, vStCap, vInteres, vStInt, vIvaInt, vStIvaInt,
	         vMora, vStMora, vIvaMora, vStIvaMora
	    FROM amortiza
	   WHERE fecha_cuota = vFecha
	     AND capital_status = "1"; 

	LET nrows = dbinfo("sqlca.sqlerrd2");   
	IF(nrows = 0) THEN
		RETURN cod_ret;
	END IF

	IF vCapital <= 0 AND vStCap = "1" THEN
		LET vStCapAnt = vStCap;
		LET vStCap = "5";
	END IF
		
	IF vInteres <= 0 AND vStInt = "1" THEN
		LET vStIntAnt = vStInt;
		LET vStInt = "5";
	END IF

	IF vIvaInt <= 0 AND vStIvaInt = "1" THEN
		LET vStIvaInt = "5";
	END IF

	IF vMora <= 0 AND vStMora = "1" THEN
		LET vStMora = "5";
	END IF

	IF vIvaMora <= 0 AND vStIvaMora = "1" THEN
		LET vStIvaMora = "5";
	END IF

	UPDATE amortiza
	   SET capital_status = vStCap,
		 capital_status_ant = vStCapAnt,
		 interes_status = vStInt,
		 interes_status_ant = vStIntAnt,
		 iva_status = vStIvaInt,
		 mora_status = vStMora,
		 mora_iva_status = vStIvaMora
	 WHERE fecha_cuota = vFecha;
		

END
	RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Procedimiento para la actualizacion de la cuota exigible ',
'al dia de corte',
'AUTOR : Antonio Ruiz Mtz',
'FECHA : 08/Mayo/2007',
'BD    : BDICRED' 
;

CREATE PROCEDURE "informix".afecta_amortizacion(pEmpresa CHAR(3),
				  pCredito CHAR(20),
				  pMonto   DECIMAL(14,2),
				  pTipo    CHAR(1))
RETURNING CHAR(5);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vMtoPaso	      DECIMAL(14,2);
   DEFINE vMtoDif 	      DECIMAL(14,2);
   DEFINE vInsoluto           DECIMAL(14,2);
   DEFINE vFecha	      DATE;
   DEFINE vCuotas	      SMALLINT;

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;


  SET LOCK MODE TO WAIT 10;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vMtoPaso	  = 0; 
   LET vMtoDif 	  = 0;
   LET vInsoluto  = 0;
   LET vCuotas    = 0;
   LET vFecha	  = "";

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	-- **************************************************
	-- Si pTIpo = 1 Carga al credito el valor de pMonto *
	-- Si pTipo = 0 Abono al Credito el valor de pMonto *
	-- **************************************************

	-- Determina Cuota Vigente
	SELECT MIN(fecha_cuota)
	  INTO vFecha
	  FROM sd_amortiza_credito
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND capital_status = "1"
	   AND interes_debe = 0;


	IF pTipo = "1" THEN
		UPDATE sd_amortiza_credito
		   SET capital_mto_cuota = capital_mto_cuota + pMonto,
		       capital_debe = capital_debe + pMonto
		 WHERE empresa = pEmpresa
		   AND num_credito = pCredito
		   AND fecha_cuota = vFecha;
	ELSE
		UPDATE sd_amortiza_credito
		   SET capital_mto_cuota = capital_mto_cuota - pMonto,
		       capital_debe = capital_debe - pMonto
		 WHERE empresa = pEmpresa
		   AND num_credito = pCredito
		   AND fecha_cuota = vFecha;
	END IF


END
	RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Procedimiento para el incremento o decremento de las disposiciones',
'realizadas en el periodo',
'AUTOR : Antonio Ruiz Mtz',
'FECHA : 08/Mayo/2007',
'BD    : BDICRED' 
;

CREATE PROCEDURE "informix".consasigcred(pEmpresa char(3), pNumeroCredito char(20), pNumeroCliente char(20))
--Datos a Regresar--
RETURNING
char(5), --Codigo de Retorno
char(20); --Numero de Tarjeta

--Definicion de Variables
DEFINE vCodRet char(5);
DEFINE vNumeroTarjeta char(20);
DEFINE vCantReg smallint ;
DEFINE vNumCte char(20);

--Inicialización de Variables

LET vCodRet = "00000";
LET vNumeroTarjeta = "";
LET vCantReg = 0;

IF EXISTS (SELECT numcte FROM bdicred:sd_tarjeta where numcte = pNumeroCliente AND num_credito = pNumeroCredito) THEN


        SELECT DISTINCT
                num_tarjeta

        INTO
                vNumeroTarjeta
        FROM
                bdicred:sd_tarjeta AS sd_tar
        WHERE
                sd_tar.empresa = pEmpresa AND
                sd_tar.num_credito = pNumeroCredito AND
                sd_tar.numcte = pNumeroCliente AND
                sd_tar.secuencia = (SELECT MAX(sd_tar.secuencia) FROM bdicred:sd_tarjeta AS sd_tar WHERE sd_tar.empresa = pEmpresa AND sd_tar.num_credito = pNumeroCredito AND sd_tar.numcte = pNumeroCliente);

ELSE
        LET vCodRet = "262";
        LET vNumeroTarjeta = "";


END IF;
        RETURN vCodRet, vNumeroTarjeta;
END PROCEDURE
;