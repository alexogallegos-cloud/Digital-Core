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