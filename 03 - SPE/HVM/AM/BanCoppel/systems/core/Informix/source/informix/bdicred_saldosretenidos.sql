CREATE PROCEDURE "informix".saldosretenidos(pActualiza CHAR(1))
RETURNING CHAR(20),MONEY,MONEY,MONEY;

--cuenta,saldo retenido,saldo retenido detalle,diferencia

	DEFINE v_cuenta CHAR(20);
	DEFINE v_empresa CHAR(3);
	DEFINE v_saldo	MONEY;
	DEFINE v_saldo_det MONEY;

BEGIN

	FOREACH SELECT num_credito,sdo_retenido,empresa
		INTO v_cuenta,v_saldo,v_empresa
		FROM bdicred:sd_maesdos

	SELECT SUM(monto)
	INTO v_saldo_det 
	FROM  bdicred:sd_maeretenido 
	WHERE num_credito = v_cuenta
	AND empresa = v_empresa
	AND estatus = 'P';
	
	IF NVL(v_saldo_det,0) <> NVL(v_saldo,0) THEN
		IF pActualiza = '1' THEN
			UPDATE bdicred:sd_maesdos
			SET sdo_retenido = v_saldo_det
			WHERE num_credito =v_cuenta
			AND empresa = v_empresa;
		END IF
	
		RETURN v_cuenta,
		       v_saldo,
 		       v_saldo_det,
		       v_saldo-v_saldo_det
		       WITH RESUME;
	END IF


	END FOREACH;


END;

END PROCEDURE
;