CREATE PROCEDURE "informix".sp_confenviopaq(pintPkPaquete INTEGER, pintFolioPaquete INTEGER, pmnyMontoPaq DECIMAL(19,2), pintCantPagos INTEGER)
RETURNING CHAR(5);

DEFINE codret 		CHAR(5);
DEFINE sql_err 		INTEGER;
DEFINE vintpkpaq 	INTEGER;
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
	
	--Actualiza la fecha de envio y los datos del monto y total de pagos
	UPDATE tblPaqueteEnv SET
		mnyMonto = pmnyMontoPaq,
		intNumPagos = pintCantPagos,
		dtmFechaEnvio = CURRENT, chrEstatus = 'S',
		intfoliopaquete = pintFolioPaquete
	WHERE intpkpaqueteenv = pintPkPaquete
        AND chrSentidoPago = 'E'
	AND dtFechaOp = vdtFechaOp;

	{SELECT intpkpaqueteenv INTO vintpkpaq
	FROM tblPaqueteEnv
	WHERE intFolioPaquete = pintFolioPaquete
        AND chrSentidoPago = 'E'
	AND dtFechaOp = vdtFechaOp;}

	UPDATE tblpago SET
		chrestatusenvio = 'S'
	WHERE intpkpaqueteenv = pintPkPaquete;
		
	RETURN codret;
	
END

END PROCEDURE;