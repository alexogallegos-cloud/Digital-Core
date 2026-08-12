CREATE PROCEDURE "informix".sp_credito_coppel_para_todos_web(pEmpresa VARCHAR(3), pNumcte VARCHAR(20), pNumCredito VARCHAR(20),
														pProducto VARCHAR(4), pSolicito VARCHAR(1), pOpcion SMALLINT)
	RETURNING 	CHAR(5) 	AS cCodRet;

DEFINE sql_err 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cFactorTecho CHAR(1);

LET sql_err = 0;
LET cCodRet = "00000";
LET cFactorTecho = "";


BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN NVL(cCodRet, '');
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_administra_tarjetas_ppass.out";
	--TRACE ON;
	
	IF pOpcion = 1 AND TRIM(pEmpresa) <> "" AND TRIM(pNumcte) <> "" THEN
	
		SELECT LIMIT 1 factor_techo
		INTO cFactorTecho
		FROM bdisolic:"informix".ss_solicitudes ss
		WHERE empresa= pEmpresa
		AND numcte = pNumcte
		AND status_solicitud IN("EA","EE","AT","OA","OS","BC","ST","CE","LC","MC","EC", "PA","IN","CC","PC")
		AND num_producto = "6500" GROUP BY factor_techo,fecha_hora;
		
	IF 	NVL(cFactorTecho,'') = "0" THEN
		LET cCodRet = "00000";
	ELSE
		LET cCodRet = "00001";
	END IF;
		
	ELIF pOpcion = 2 AND TRIM(pNumCredito) <> "" AND TRIM(pProducto) <> "" AND TRIM(pNumcte) <> "" THEN
		UPDATE bdisolic: "informix".ss_solicitudes
			SET factor_techo = pSolicito
		WHERE num_solicitud = TRIM(pNumCredito) AND num_producto = TRIM(pProducto) AND numcte = TRIM(pNumcte);
	ELIF pOpcion = 3 AND TRIM(pNumCredito) <> "" THEN
		DELETE FROM bdisolic: "informix".ss_refpersonales where num_solicitud = TRIM(pNumCredito);
	ELSE
		LET cCodRet = "00001";
	END IF;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 AND cCodRet = "00000" THEN
		LET cCodRet = "00002";
	END IF;
	
	RETURN NVL(cCodRet, '');
END;
END PROCEDURE
