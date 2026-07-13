CREATE PROCEDURE "informix".sp_marcaerrpaq(intFolio INTEGER, siEstado SMALLINT)
RETURNING CHAR(5);

DEFINE codret 		CHAR(5);
DEFINE sql_err 		INTEGER;
DEFINE intCantidad 	INTEGER;
DEFINE intPkPaq		INTEGER;
DEFINE vdtFechaOp	DATE;

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

	SELECT intpkpaqueteenv INTO intPkPaq
	FROM tblPaqueteEnv
	WHERE intFolioPaquete = intFolio
	AND dtFechaOp = vdtFechaOp	
        AND chrSentidoPago = 'E'
        AND chrEstatus = "S";
	
        IF intPkPaq IS NULL THEN
		LET codret = '001'; --El folio no existe en la base de datos
		RETURN codret;
	END IF;
	
        UPDATE tblpaqueteenv
        SET chrEstatus = "R"
	WHERE intpkPaqueteEnv = intPkPaq;

	--Marca como no enviados "N" los pagos reportados con error.
	UPDATE tblPago
	SET chrestatusenvio = "C"
	WHERE intpkpaqueteenv = intPkPaq;

	--Inserta en bitacora de errores el folio recibido y estatus
	RETURN codret;
	
END

END PROCEDURE;