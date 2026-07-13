CREATE PROCEDURE "informix".sp_conslotepend(pSucursal CHAR(4), pEmpresa CHAR(3))

RETURNING CHAR(5), CHAR(4), CHAR(1), INTEGER, INTEGER, INTEGER, CHAR(1), DATE;

	-- Autor: Manuel Ramos Figueroa
	-- Actividad: Consulta los envios de lotes de tarjetas por sucursal.
	-- Fecha de Solicitud: 05/11/2012

	DEFINE iSqlErr, iIsamErr	INTEGER;
	DEFINE cCodRetorno			CHAR(5);
	DEFINE cSucursal			CHAR(4);
	DEFINE cTipoTarjeta			CHAR(1);
    DEFINE iNumEnvio			INTEGER;
	DEFINE iRangoIni			INTEGER;
	DEFINE iRangoFin			INTEGER;
    DEFINE cStatus				CHAR(1);
	DEFINE dFechaSurtido		DATE;
	DEFINE cAux					CHAR(4);
	DEFINE cAux2				CHAR(4);
	DEFINE iTotalN				INTEGER;
	DEFINE iTotalR				INTEGER;

    LET cCodRetorno		= "00000";
	LET cSucursal		= "";
	LET cTipoTarjeta	= "";
    LET iNumEnvio		= 0;
	LET iRangoIni		= 0;
	LET iRangoFin		= 0;
    LET cStatus			= "";
	LET dFechaSurtido	= "";
	LET cAux			= "";
	LET cAux2			= "";
	LET iTotalN			= 0;
	LET iTotalR			= 0;

   --SET DEBUG FILE TO "/informix/lflores/sp_conslotepend.out";
   --TRACE ON;

    BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRetorno = iSqlErr;
				RETURN cCodRetorno, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT LIMIT 1 cvesucursal INTO cAux FROM bditarjcop:"informix".enviostarcop WHERE empresa = pEmpresa AND cvesucursal = pSucursal;
		SELECT LIMIT 1 cvesucursal INTO cAux2 FROM bditarjcop:"informix".envioshisttarcop WHERE empresa = pEmpresa AND cvesucursal = pSucursal;

		IF (cAux <> "" OR cAux2 <> "") THEN			
			FOREACH
				SELECT cvesucursal, tipotarjeta, numenvio, rangoini, rangofin, enviodisponible, fechasurt 
				INTO cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido 
				FROM bditarjcop:"informix".enviostarcop 
				WHERE empresa = pEmpresa 
				AND cvesucursal = pSucursal
				AND enviodisponible <> ''
				
				UNION ALL
				
				SELECT cvesucursal, tipotarjeta, numenvio, rangoini, rangofin, enviodisponible, fechasurt 
				FROM bditarjcop:"informix".envioshisttarcop 
				WHERE empresa = pEmpresa 
				AND cvesucursal = pSucursal 
				AND enviodisponible <> ''
				ORDER BY numenvio DESC, tipotarjeta

				IF (cTipoTarjeta == "N") THEN
					LET iTotalN = iTotalN + 1;
					IF iTotalN > 5 THEN
						CONTINUE FOREACH;
					END IF;
				ELIF (cTipoTarjeta == "R") THEN
					LET iTotalR = iTotalR + 1;
					IF iTotalR > 5 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;

				RETURN cCodRetorno, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido WITH RESUME;
			END FOREACH;
		ELSE
			--No existe la sucursal
			LET cCodRetorno = "00001";
			RETURN cCodRetorno, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido;
		END IF;
    END;
END PROCEDURE;