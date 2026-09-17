CREATE PROCEDURE "informix".sp_generadevpago(p_intpkpago integer, p_intcvecausadev integer, p_vchrMotivoDev varchar(255))
RETURNING char(5);

DEFINE v_codret char(5);
DEFINE sql_err 	integer;
DEFINE v_intpkdev integer;
DEFINE v_intpkpago integer;
DEFINE v_intfoliodev integer;
DEFINE vdtFechaOp date;

BEGIN
	--Manejo de excepciones 
	ON EXCEPTION SET sql_err
	 	IF sql_err <> 0 THEN
	       LET v_codret = sql_err;	   
		   RETURN v_codret;
		END IF;
    END EXCEPTION;

	LET v_codret = "000";

	SELECT to_date(vchrValor, '%d/%m/%Y') INTO vdtFechaOp
	FROM tblParametros
	WHERE vchrCveParametro = 'FECHA_OPERACION';	

	--Verifica que el pago exista
	SELECT intpkpago INTO v_intpkpago
	FROM tblpago 
	WHERE tblpago.intpkpago = p_intpkpago
	AND dtFechaValor = vdtFechaOp;
	
	--Genera la devolucion
	--Obtiene el siguiente pk del pago
	EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO v_codret, v_intpkdev;
	IF v_codret != 0 THEN
		--Entrega error 
		RETURN v_codret;
	END IF;
	
	--Obtiene el siguiente folio de la devolucion
	EXECUTE PROCEDURE sp_obtsigfolioop('FOLIO_DEVOLUCION') INTO v_codret, v_intfoliodev;
	IF v_codret != 0 THEN
		--Entrega error 
		RETURN v_codret;
	END IF;
	
	--Inserta la devolucion.
	INSERT INTO tblPago (intPkPago, cvecesifbcoord, cvecesifbcodest, intcvetipopago, mnyImporte, chrestatusenvio, 
		dtfechavalor, dtfechacaptura, vchrClaveRastreo, sintlongcverastreo, intcvecausadev, txtcde, chrTopologia, vchrcverastreoorig, vchrcverastreodev, vchrMotivodev ) 
		SELECT v_intpkdev, cvecesifbcodest, cvecesifbcoord, 0, mnyImporte, "T", dtfechavalor, CURRENT, vchrClaveRastreo, sintlongcverastreo,
		p_intcvecausadev, txtCDE, chrTopologia, vchrClaveRastreo, "BSIDEV" || v_intfoliodev, p_vchrMotivoDev
		FROM tblPago WHERE intpkpago = p_intpkpago;

	--Marca el pago recibido como Devuelto.
	UPDATE bdiSPEI:tblPago
  	SET intcvecausadev=p_intcvecausadev,
      chrEstatusEnvio="D"
  	WHERE intpkpago=p_intpkpago;							  

        RETURN v_codret;

END

END PROCEDURE
;