CREATE PROCEDURE "informix".sp_marcacancpago(pintFolioPaquete INTEGER, pintFolioPago INTEGER, 
	pintFolioServCanc INTEGER)	
RETURNING CHAR(5);

DEFINE codret 				CHAR(5);
DEFINE sql_err 				INTEGER;
DEFINE vintPkPaqueteEnv 	INTEGER;
DEFINE intCesifPago			INTEGER;
DEFINE chrFolioErr			CHAR(18);
DEFINE intFolioErr			INTEGER;
DEFINE vdtFechaOp			DATE;

LET CODRET = '000';

BEGIN
	ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
	     LET codret = sql_err;
	     RETURN codret;
	  END IF
	END EXCEPTION;

	SELECT to_date(vchrValor, '%d/%m/%Y') INTO vdtFechaOp
	FROM tblParametros
	WHERE vchrCveParametro = 'FECHA_OPERACION';

	SELECT intPkPaqueteEnv INTO vintPkPaqueteEnv
	FROM tblPaqueteEnv
	WHERE intFolioPaquete = pintFolioPaquete
	AND dtFechaOp = vdtFechaOp
    AND chrSentidoPago = 'E';
	
	IF vintPkPaqueteEnv IS NULL THEN
		LET codret = '001'; --El folio del paquete no existe en la base de datos
		RETURN codret;
	END IF;
	
	--Inserta en bitacora de errores el folio recibido y estatus
	UPDATE tblpago SET
		chrEstatusEnvio = 'C',
		intFolioServCanc = pintFolioServCanc,
		dtmHoraCancela = CURRENT
	WHERE intPkPaqueteEnv = vintPkPaqueteEnv
	AND intFolioPago = pintFolioPago;
	
	RETURN codret;
	
END

END PROCEDURE;