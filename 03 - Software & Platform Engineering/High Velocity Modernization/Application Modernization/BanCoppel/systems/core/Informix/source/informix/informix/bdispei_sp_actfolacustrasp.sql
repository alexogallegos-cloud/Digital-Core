CREATE PROCEDURE "informix".sp_actfolacustrasp(pintFolioServidor INTEGER, pintFolioTraspaso INTEGER)
RETURNING CHAR(5);

DEFINE codret 			CHAR(5);
DEFINE sql_err 			INTEGER;
DEFINE vdtFechaOp		DATE;
DEFINE vintPkTraspaso	INTEGER;

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

	SELECT intPkTraspaso INTO vintpkTraspaso
	FROM tblTraspaso
	WHERE intfoliosolicitud = pintFolioTraspaso
	AND dtFechaOp = vdtFechaOp
	AND chrEstatusEnvio = "S";
	
	IF vintpkTraspaso IS NULL THEN
		LET codret = '001'; --El folio del traspaso no existe en la base de datos
		RETURN codret;
	END IF;
	
	--Actualiza el folio de acuse del traspaso
	UPDATE tblTraspaso SET
		intfolioAcuse = pintFolioServidor,
		chrEstatusEnvio = 'E'
	WHERE intpktraspaso = vintpktraspaso;
	
	RETURN codret;
	
END

END PROCEDURE;