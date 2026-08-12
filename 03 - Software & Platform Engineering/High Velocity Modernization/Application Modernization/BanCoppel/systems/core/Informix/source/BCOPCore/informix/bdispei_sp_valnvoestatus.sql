CREATE PROCEDURE "informix".sp_valnvoestatus(pintPkPago INTEGER, pchrNvoEstatus CHAR, pchrTipo CHAR)
RETURNING CHAR(5);

DEFINE codret 				CHAR(5);
DEFINE sql_err 				INTEGER;
DEFINE vintPkPaqueteEnv 	INTEGER;
DEFINE intCesifPago			INTEGER;
DEFINE chrFolioErr			CHAR(18);
DEFINE intFolioErr			INTEGER;
DEFINE vdtFechaOp			DATE;
DEFINE chrEstatusPago		char;
DEFINE intValido			INTEGER;
DEFINE vchrSentido			CHAR(1);

LET CODRET = '000';
LET intValido = 0;
LET chrEstatusPago = '';
let vchrSentido = '';

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

	IF pchrTipo = 'R' OR pchrTipo = 'E' THEN
		--Verifica el estatus actual del pago
		SELECT NVL(chrEstatusEnvio, ''), NVL(chrSentidoPago, '') INTO chrEstatusPago, vchrSentido
		FROM tblPago
		WHERE intPkPago = pintPkPago;
	ELSE
		--Verifica el estatus actual del pago
		SELECT NVL(chrEstatusEnvio, ''), 'T' INTO chrEstatusPago, vchrSentido
		FROM tblTraspaso
		WHERE intPkTraspaso = pintPkPago;
	END IF;


	IF chrEstatusPago is NULL or chrEstatusPago = '' THEN
		RETURN '002'; --El pago no esta registrado en el sistema	
	ELSE
		--Valida si del estatus actual puede pasar al siguiente
		SELECT COUNT(*) INTO intValido
		FROM tblFlujoEstatus 
		WHERE chrCveEstatusAnt = chrEstatusPago
		AND chrCveEstatusNvo = pchrNvoEstatus
		AND chrSentido = vchrSentido;
		
		IF intValido <= 0 THEN
			RETURN '005'; --El pago no esta registrado en el sistema
		END IF;
	END IF
	
	RETURN codret;
	
END

END PROCEDURE;