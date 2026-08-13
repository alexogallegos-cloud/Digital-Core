CREATE PROCEDURE "informix".sp_actfolioacuse(pintFolioServidor INTEGER, pintFolioPaquete INTEGER)
RETURNING CHAR(5);

DEFINE codret 			CHAR(5);
DEFINE sql_err 			INTEGER;
DEFINE vdtFechaOp		DATE;
DEFINE vintPkPaqueteEnv INTEGER;

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
        AND chrSentidoPago = 'E'
        AND chrEstatus = "S";
	
	IF vintPkPaqueteEnv IS NULL THEN
		LET codret = '001'; --El folio del paquete no existe en la base de datos
		RETURN codret;
	END IF;
	
	--Actualiza el folio de acuse en el paquete
	UPDATE tblPaqueteEnv SET
		intfolioAcuse = pintFolioServidor,
                chrEstatus = 'E'
	WHERE intPkPaqueteEnv = vintPkPaqueteEnv;
	
	--Actualiza el estatus de los pagos enviados en el paquete
    UPDATE tblPago SET 
		chrEstatusEnvio = 'E'
	WHERE intPkPaqueteEnv = vintPkPaqueteEnv;
	
	RETURN codret;
	
END

END PROCEDURE;