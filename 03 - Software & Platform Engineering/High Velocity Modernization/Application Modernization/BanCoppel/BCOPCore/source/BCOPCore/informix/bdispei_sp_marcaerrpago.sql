CREATE PROCEDURE "informix".sp_marcaerrpago(pintFolioPago INTEGER, pintFolioServidor INTEGER, psiCodError SMALLINT)
RETURNING CHAR(5), VARCHAR(100);

DEFINE codret 		CHAR(5);
DEFINE sql_err 		INTEGER;
DEFINE intCantidad 	INTEGER;
DEFINE chrFolioErr	CHAR(18);
DEFINE DescError 	VARCHAR(100);
DEFINE intFolioErr	INTEGER;

LET CODRET = '000';
LET DescError = '';

BEGIN
	ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
	     LET codret = sql_err;
	     RETURN codret, DescError;
	  END IF
	END EXCEPTION;

	SELECT count(*) INTO intCantidad
	FROM tblPago
	WHERE intFolioPago = pintFolioPago
        AND chrSentidopago = 'N';
	
	IF intCantidad = 0 THEN
		LET codret = '002'; --El folio del pago no existe en la base de datos
		RETURN codret, DescError;
	END IF;
	
	--Inserta en bitacora de errores el folio recibido y estatus
	UPDATE tblpago SET
		chrEstatusEnvio = 'R'
	WHERE intFolioPago= pintFolioPago
        AND chrSentidopago = 'N';

	EXECUTE PROCEDURE sp_obtsigfolioop('TBLERRCOM') INTO codret, intFolioErr;
	
	--Genera el folio para el error registrado en bitacora
	LET chrFolioErr = to_char(CURRENT, '%d%m%Y%H%M%S') || LPAD(intFolioErr, 4, '0');

	INSERT INTO tblErrCom(chrFolioErrCom, intFolio, intFolioservidor, dtFechaop, sicoderror)
		VALUES (intFolioErr, pintFolioPago, pintFolioServidor, CURRENT, psiCodError);
		
	RETURN codret, DescError;
	
END

END PROCEDURE;