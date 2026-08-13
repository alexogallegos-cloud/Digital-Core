CREATE PROCEDURE "informix".sp_ctepr_consctemasivo( pNumcte_pros CHAR(20))
RETURNING CHAR(5) AS CodRet,
		  CHAR(2) AS status_cte_pros,
		  CHAR(1) AS tipo_cliente,
		  CHAR(1) AS envio_parametrico;


	-- DECLARACION DE VARIABLES
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlerr				INTEGER;
	DEFINE cStatus				CHAR(2);
	DEFINE cTp_cte				CHAR(1);
	DEFINE cEnvio_parametrico	CHAR(1);


	-- INICIALIZA VARIABLES
	LET cCodRet 			= '00000';
	LET iSqlerr				= 0;
	LET cStatus				= '';
	LET cTp_cte				= '';
	LET cEnvio_parametrico  = '';

	BEGIN

		ON EXCEPTION SET iSqlerr
			IF iSqlerr != 0 THEN
				LET cCodret = iSqlerr;
				RETURN cCodret,NVL(cStatus,''),NVL(cTp_cte,''),NVL(cEnvio_parametrico,'');
			END IF;
		END EXCEPTION;

		--- SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1468/sp_ctepr_consctemasivo.out';
		--- TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- VALIDACION DE PARAMETROS --
		-- SE VERIFICA QUE LOS PARAMETROS NO LLEGUEN VACIO
		IF NVL(pNumcte_pros,"") = "" THEN
			LET cCodRet = '00001';
			RETURN cCodret,NVL(cStatus,''),NVL(cTp_cte,''),NVL(cEnvio_parametrico,'');
		END IF;

		--BUSCA EL CLIENTE CON EL RFC PARA OBTENER EL NUMERO DE CLIENTE PROSPECTO Y ESTATUS
		SELECT a.status_numcte_pros,a.tipo_cliente, a.envio_parametrico
		INTO cStatus,cTp_cte, cEnvio_parametrico
		FROM "informix".pr_cliente a
		INNER JOIN "informix".pr_autorizacion b on (b.num_solicitud = a.numcte_pros and b.status_solicitud = a.status_numcte_pros)
		WHERE a.numcte_pros = TRIM(pNumcte_pros)
		AND b.fecha_salida IS NULL;

		--VALIDA SI ENCONTRO INFORMACION
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodret = '00002';
		END IF;
		RETURN cCodret,NVL(cStatus,''),NVL(cTp_cte,''),NVL(cEnvio_parametrico,'');

	END;
END PROCEDURE
