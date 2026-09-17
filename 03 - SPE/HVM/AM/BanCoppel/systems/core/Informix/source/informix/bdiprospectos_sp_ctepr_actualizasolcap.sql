CREATE PROCEDURE "informix".sp_ctepr_actualizasolcap(pEjecutivo CHAR(8),pFecha DATE,pModalidad CHAR(1))
													-- MODALIDAD 0 ES PARA AGREGAR SOLICITUDES CAPTURADAS
													-- MODALIDAD 1 ES PARA AGREGAR SOLICITUDES RECHAZADAS
RETURNING CHAR(6) AS CodRet;

	-- DECLARACION DE VARIABLES
	DEFINE cCodRet 			CHAR(6);
	DEFINE iSqlerr			INTEGER;
	DEFINE iSol_entregadas	INTEGER;
	DEFINE iSol_capturadas	INTEGER;
	DEFINE iSol_rechazadas	INTEGER;
	DEFINE iSol_pendientes	INTEGER;

	-- INICIALIZA VARIABLES
	LET cCodRet = '000000';
	LET iSol_entregadas = 0;
	LET iSol_capturadas = 0;
	LET iSol_rechazadas = 0;
	LET iSol_pendientes = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlerr
			IF iSqlerr != 0 THEN
				LET cCodret = iSqlerr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/dbexportb/marioolivo/sp_ctepr_actualizasolcap.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDACION DE PARAMETROS --
		IF NVL(pEjecutivo,'') = '' OR NVL(pFecha,'') = '' OR pModalidad NOT IN ('0','1') THEN 
		-- SE VERIFICA QUE LOS PARAMETROS NO LLEGUEN VACIO
			LET cCodRet = '00001';
			RETURN cCodRet;
		END IF;

		-- CONSULTAR LA TABLA PR_MONITORCONCILIA Y EXTRAER LOS DATOS SOLICITUDES ENTREGADAS, SOLICITUDES CAPTURADA
		-- Y SOLICITUDES RECHAZADAS. SI NO HAY DATOS ERROR 000002
		SELECT sol_entregadas, sol_capturadas, sol_rechazadas
		INTO iSol_entregadas, iSol_capturadas, iSol_rechazadas		
		FROM "informix".pr_monitorconcilia
		WHERE fecha_solmasivas = pFecha
		AND empleado_cob = TRIM(pEjecutivo);
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodret = '000002';
			RETURN cCodRet;
		END IF;
		
		-- REALIZAMOS LA VALIDACION DE SOLICITUDES PENDIENTES
		-- SOL_PENDIENTES = (SOLICITUDES ENTREGADAS) - (SOLICITUDES CAPTURADAS) - (SOLICITUDES RECHAZADAS)
		-- SI SOL_PENDIENTES ES = 0 SERA EL ERROR 000003
		-- SI SOL_PENDIENTES ES > 0 ENTONCES ACTUALIZAR EL CAMPO DE SOL_CAPTURADAS: SOL_CAPTURADAS =  SOL_CAPTURADAS + 1 
		LET iSol_pendientes = iSol_entregadas - iSol_capturadas - iSol_rechazadas; 
		
		IF iSol_pendientes = 0 THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		IF pModalidad = '0' THEN
			
			IF iSol_pendientes > 0 THEN
				LET iSol_capturadas = iSol_capturadas + 1;
			END IF;
				
			-- REALIZAR EL UPDATE A LA TABLA PR_MONITORCONCILIA DONDE SEA EL NUMERO DE EMPLEADO_COB CON EL PARAMETRO DE ENTRADA
			-- Y LA FECHA_SOLMASIVAS IGUAL AL PARAMETRO DE ENTRADA. SI NO SE REALIZA EL UPDATE SERA EL ERROR 000004
			UPDATE "informix".pr_monitorconcilia 
			SET sol_capturadas =  iSol_capturadas
			WHERE fecha_solmasivas = pFecha
			AND empleado_cob = TRIM(pEjecutivo);
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodret = '000004';
			END IF;
			

		ELSE --MODALIDAD 1 INCREMENTAR LAS SOLICITUDES RECHAZADAS.
			IF iSol_pendientes > 0 THEN
				LET iSol_rechazadas = iSol_rechazadas + 1;
			END IF;
				
			-- REALIZAR EL UPDATE A LA TABLA PR_MONITORCONCILIA DONDE SEA EL NUMERO DE EMPLEADO_COB CON EL PARAMETRO DE ENTRADA
			-- Y LA FECHA_SOLMASIVAS IGUAL AL PARAMETRO DE ENTRADA. SI NO SE REALIZA EL UPDATE SERA EL ERROR 000004
			UPDATE "informix".pr_monitorconcilia 
			SET Sol_rechazadas =  iSol_rechazadas
			WHERE fecha_solmasivas = pFecha
			AND empleado_cob = TRIM(pEjecutivo);
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodret = '000004';
			END IF;
		END IF;
		
		RETURN cCodret;

	END;
END PROCEDURE
