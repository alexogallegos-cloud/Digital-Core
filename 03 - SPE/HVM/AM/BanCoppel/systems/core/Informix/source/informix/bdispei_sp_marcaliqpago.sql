CREATE PROCEDURE "informix".sp_marcaliqpago(pintFolioPago INTEGER, pintFolioPaquete INTEGER, pintFolioCargo INTEGER, pintCesifBenef INTEGER)
RETURNING CHAR(5), money(19,2);

DEFINE codret 		CHAR(5);
DEFINE sql_err 		INTEGER;
DEFINE intCantidad 	INTEGER;
DEFINE intCesifPago	INTEGER;
DEFINE vintPkPaqueteEnv INTEGER;
DEFINE chrFolioErr	CHAR(18);
DEFINE mnyMonto		money(19,2);
DEFINE intFolioErr	INTEGER;
DEFINE vdtFechaOp	DATE;

LET CODRET = '000';
LET mnyMonto = 0;


--SET LOCK MODE TO WAIT 5;

--SET DEBUG FILE TO "/home/informix/tmp/marcapagoliq.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
	     LET codret = sql_err;
	     RETURN codret, mnyMonto;
	  END IF
	END EXCEPTION;

	SELECT to_date(vchrValor, '%d/%m/%Y') INTO vdtFechaOp
	FROM tblParametros
	WHERE vchrCveParametro = 'FECHA_OPERACION';
	
	SELECT intPkPaqueteEnv INTO vintPkPaqueteEnv
	FROM tblPaqueteEnv
	WHERE intFolioPaquete = pintFolioPaquete
	AND cveCesifbcodest = pintCesifBenef
	AND dtFechaOp = vdtFechaOp
	AND chrSentidoPago = 'E';	
	
	IF vintPkPaqueteEnv IS NULL THEN
		LET codret = '001'; --El folio del paquete no existe en la base de datos
		RETURN codret, mnyMonto;
	END IF;	

	SELECT count(*) INTO intCantidad
	FROM tblPago
	WHERE intfoliopago = pintFolioPago
	AND intpkpaqueteenv = vintPkPaqueteEnv
	AND dtFechaValor = vdtFechaOp;	
	
	IF intCantidad = 0 THEN
		LET codret = '002'; --El folio del pago no existe en la base de datos
	    RETURN codret, mnyMonto;
	END IF;
	
	--Verifica que la institucion beneficiario del pago recibido corresponde.
	SELECT cvecesifbcodest, mnyImporte INTO intCesifPago, mnyMonto
	FROM tblPago
	WHERE intfoliopago = pintFolioPago
	AND intpkpaqueteenv = vintPkPaqueteEnv	
	AND dtFechaValor = vdtFechaOp;	

	IF intCesifPago <> pintCesifBenef THEN
		LET codret = '003'; --La clave cesif del beneficiario recibida no correspondte con la del pago enviado.
	    RETURN codret, mnyMonto;
	END IF;	
	
	--Inserta en bitacora de errores el folio recibido y estatus
	UPDATE tblpago SET
		chrEstatusEnvio = 'L',
		intFolioCargo = pintFolioCargo,
		dtmHoraCargo = CURRENT
	WHERE intFolioPago = pintFolioPago
	AND intpkpaqueteenv = vintPkPaqueteEnv	
	AND dtFechaValor = vdtFechaOp;
	
	RETURN codret, mnyMonto;
	
END

END PROCEDURE;