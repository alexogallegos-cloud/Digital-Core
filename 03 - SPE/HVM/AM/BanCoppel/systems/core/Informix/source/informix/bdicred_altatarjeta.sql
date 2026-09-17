CREATE PROCEDURE "informix".altatarjeta
	(pEmpresa	CHAR(3),
	 pTpMov         CHAR(1),
	 pNumCredito    CHAR(20),
	 pProdTarjeta   CHAR(4),
	 pNumCte	CHAR(20),
	 pTarjeta       CHAR(20),
	 pTarjetaAnt    CHAR(20),
	 pExpiracion    DATE,
	 pTipoTarjeta   CHAR(1),
	 pNombre	CHAR(26))

   RETURNING CHAR(5);      -- Codigo de Retorno

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE v_status            CHAR(2);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;



  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret  = "000";
   LET v_status = "??";

  -- **************************************************************************
  -- *                      PROGRAMA PRINCIPAL                                *
  -- **************************************************************************

  SELECT status_cred INTO v_status
    FROM sd_maecred
   WHERE empresa = pEmpresa
     AND num_credito = pNumCredito;

  IF v_status IS NULL THEN
	LET cod_ret = "100";
	RETURN cod_ret;
  END IF

  IF v_status = "BT" THEN
	LET cod_ret = "999";
	RETURN cod_ret;
  END IF
   
  IF pTpMov = "A" THEN -- Alta
	INSERT INTO sd_tarjeta
	 (empresa, num_tarjeta, numcte, prodtarjeta, num_credito,
	  expiracion, tipo_tarjeta, nombre, status_tar)
	VALUES
	 (pEmpresa, pTarjeta, pNumCte, pProdTarjeta, pNumCredito,
	  pExpiracion, pTipoTarjeta, pNombre, "A");

  ELIF pTpMov = "R" OR pTpMov = "P" THEN -- Renovacion y Reposicion

	UPDATE sd_tarjeta SET status_tar ="C"
	 WHERE empresa = pEmpresa
	   AND num_tarjeta = pTarjetaAnt;

	INSERT INTO sd_tarjeta
	 (empresa, num_tarjeta, numcte, prodtarjeta, num_credito,
	  expiracion, tipo_tarjeta, nombre, status_tar)
	VALUES
	 (pEmpresa, pTarjeta, pNumCte, pProdTarjeta, pNumCredito,
	  pExpiracion, pTipoTarjeta, pNombre, "A");

  ELIF pTpMov = "C" THEN -- Cancelacion
	UPDATE sd_tarjeta SET status_tar ="C"
	 WHERE empresa = pEmpresa
	   AND num_tarjeta = pTarjetaAnt;
  END IF

   RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Esta funcion realiza la administracion de los status de la T.C.       ',
'AUTOR : Antonio Ruiz Mtz',
'FECHA : 4/1/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

CREATE PROCEDURE "informix".nvia_monitorsol(o_empresa   CHAR(3),
				 o_numsol   CHAR(20),
				 o_ejecutivo CHAR(8))


RETURNING CHAR(5);      -- Codigo de Retorno

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(3);
DEFINE vsqlerr      INTEGER;
DEFINE v_status     CHAR(2);
DEFINE v_hoy	    DATE;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_status     = "??";
SELECT fecha_hoy INTO v_hoy FROM bdinteg:sd_fechas;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	SELECT status_solicitud INTO v_status
	  FROM ss_solicitudes 
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	IF v_status = "AP" THEN
		LET scod_ret = "001";
		RETURN scod_ret;
	END IF
	
	UPDATE ss_solcitiudes SET status_solicitud = "AN"
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	INSERT INTO ss_autorizacion
	 (empresa, ejecutivo_auto, num_solciitud, status_solicitud,
	  comentario, fecha_entrada, fecha_salida)
	VALUES
	 (o_empresa, o_ejecutivo, o_numsol, "AN", 
	  "Anulada por peticion del Cliente", v_hoy, v_hoy);


    RETURN scod_ret;
                  
END

END PROCEDURE
;