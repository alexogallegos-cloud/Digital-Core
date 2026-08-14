CREATE PROCEDURE "informix".sp_reconsultastatushuellalineaatrasadas()

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) 	AS CodigoRetorno,
	CHAR(43) 	AS TramaSalida,
	CHAR(1)		AS EstatusConsulta;

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 		INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE cCadena			CHAR(43);	
	DEFINE cEstatusConsulta	CHAR(1);
	DEFINE cNumCte			CHAR(20);
	DEFINE dFechaConsulta	DATE;
	
	DEFINE iCantidad		INTEGER;
	DEFINE sCont			SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET iSql_err			= 0;
	LET cCodRet				= '00000';
	LET cCadena				= "";
	LET cEstatusConsulta	= "";
	LET iCantidad			= 0;
	LET sCont				= 0;
	LET cNumCte				= '';
	LET dFechaConsulta		= DATE(1);

	--SET DEBUG FILE TO "/tmp/Victor/sp_reconsultastatushuellalineaatrasadas.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
			
				RETURN  cCodRet, cCadena,cEstatusConsulta;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--Obtiene la cantidad de huellas a enviar por ejecucion
		SELECT valor ::INT INTO iCantidad FROM si_param WHERE cod_param = 347;
		
		IF iCantidad IS NULL THEN
			LET iCantidad = 10;
		END IF;
		
		FOREACH
			--Buscar las huellas que no se han enviado de dias anteriores
			--status_consulta: 0 SIN ENVIAR, 3 ERROR, 9 PENDIENTE
			SELECT LIMIT iCantidad {+AVOID_FULL("informix".tmp_si_huella_linea)} TRIM(numcte) ||"|"|| TRIM(secuencia)||"|"||TRIM(sucursal)
			||"|"||TRIM(ip), status_consulta,numcte, fecha_consulta
			INTO cCadena, cEstatusConsulta,cNumCte,dFechaConsulta
			FROM bdinteg:"informix".tmp_si_huella_linea
			WHERE status_consulta IN ('3','9','0')
			AND fecha_insert < CURRENT - 1 UNITS DAY 
			AND (CASE WHEN NVL(ticket, '') = '' THEN 0 ELSE ticket::INT END) <= 0 
			ORDER BY status_consulta 
			
			--Se ingresa actualizaciÃ³n de registros enviados al demonio de huellas atrasadas
			UPDATE {+AVOID_FULL("informix".tmp_si_huella_linea)} "informix".tmp_si_huella_linea SET status_consulta='1' WHERE numcte=cNumCte AND fecha_consulta=dFechaConsulta AND status_consulta=cEstatusConsulta;
			
			IF cCadena IS NOT NULL THEN
				RETURN cCodRet, TRIM(cCadena), cEstatusConsulta WITH RESUME;
			END IF;
			
		END FOREACH;

	END
END PROCEDURE;