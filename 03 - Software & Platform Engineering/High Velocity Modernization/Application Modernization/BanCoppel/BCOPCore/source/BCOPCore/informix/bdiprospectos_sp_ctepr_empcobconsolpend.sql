CREATE PROCEDURE "informix".sp_ctepr_empcobconsolpend(pNumempcob CHAR (8), pFecha DATE)

RETURNING
	CHAR (6) AS cCodRet,
	INTEGER  AS iPendientes;

	DEFINE cCodRet			CHAR(6);
	DEFINE iSqlErr 		  	INTEGER;
	DEFINE dFechaHoy   		DATE;
	DEFINE iPendientes		INTEGER;
	DEFINE iEntregada		INTEGER;
	DEFINE iCapturada		INTEGER;
	DEFINE iRechazada		INTEGER;
		
	LET cCodRet		 		= '000000';
	LET iSqlErr 			= 0;
	LET dFechaHoy     		= DATE(1);
	LET iPendientes			= 0;
	LET iEntregada			= 0;
	LET iCapturada			= 0;
	LET iRechazada			= 0;
	
	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,iPendientes;	
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/respaldosbd/Pedro/1468/sp_ctepr_empcobconsolpend.out';
		--TRACE ON;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;  		
		
		-- VALIDACION DE PARAMETROS
		IF NVL(pNumempcob,'') ='' OR NVL(pFecha,'') ='' THEN 
			LET cCodRet = '000001';
			RETURN cCodRet,iPendientes;
		END IF;

		-- OBTENER FECHA HOY
		SELECT fecha_hoy INTO dFechaHoy	
		FROM bdinteg:'informix'.si_fechas;

		-- VALIDAR FECHA QUE NO SEA MAYOR A LA FECHA HOY
		IF pFecha > dFechaHoy THEN 
			LET cCodRet = '000002';
			RETURN cCodRet,iPendientes;
		END IF;

		-- CONSULTA SOLICITUDES PENDIENTES POR EMPLEADO DE COBRANZA POR FECHA
		SELECT sol_entregadas,sol_capturadas,sol_rechazadas 
		INTO iEntregada,iCapturada,iRechazada
		FROM 'informix'.pr_monitorconcilia 
		WHERE fecha_solmasivas = pFecha
		AND empleado_cob = pNumempcob;

		--VALIDA SI ENCONTRO REGISTROS
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000003';
			RETURN cCodRet,iPendientes;
		END IF;
		
		LET iPendientes = iEntregada-iCapturada-iRechazada;
		
		--VALIDA SI AUN TIENE SOLICITUDES PENDIENTES
		IF NVL(iPendientes,0) = 0 THEN
			LET cCodRet = '000004';
			RETURN cCodRet,iPendientes;
		END IF;
		
		RETURN cCodRet,iPendientes;
			
	END;
END PROCEDURE
