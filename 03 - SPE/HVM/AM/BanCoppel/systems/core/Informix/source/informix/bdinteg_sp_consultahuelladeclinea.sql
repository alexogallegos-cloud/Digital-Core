CREATE PROCEDURE "informix".sp_consultahuelladeclinea(pStatus CHAR(1))

--DATOS A REGRESAR---
RETURNING
	CHAR(5) 	AS CodRet,             	
	CHAR(20) 	AS NumCte,
	CHAR(1) 	AS Sexo,
	SMALLINT 	AS Secuencia,
	CHAR(15) 	AS Ip,
	CHAR(4) 	AS Sucursal,
	CHAR(20) 	AS FechaEnroll,
	CHAR(1) 	AS TipoMov,
	CHAR(8) 	AS Empleado,
	CHAR(2) 	AS TipoSensor,
	CHAR(1) 	AS Situacion,
	CHAR(20) 	AS Referencia,
	CHAR(20) 	AS FechaCambio,
	CHAR(2) 	AS TipoCliente,
	CHAR(2) 	AS TipoVerificador,
	SMALLINT 	AS HuellasCap;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_consultahuelladeclinea "
Folio.........: 841 - ComparaciÃ³n en linea de 10 huellas.
Autor.........: 90127902 - Carlos VÃ¡zquez Mitre
Fecha.........: 31/01/2022
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cEmpresa				CHAR(3);
DEFINE shSecuencia			SMALLINT;
DEFINE cNumCte				CHAR(20);
DEFINE cSucursal			CHAR(4);
DEFINE cIp					CHAR(15);
DEFINE iContador			INTEGER;
DEFINE cFechaAlta			CHAR(20);
DEFINE cSexo				CHAR(1);
DEFINE cTipoMov				CHAR(1);
DEFINE cEmpleado			CHAR(8);
DEFINE cTipoSensor			CHAR(2);
DEFINE cSituacion			CHAR(1);
DEFINE cReferencia			CHAR(20);
DEFINE cFechaCambio			CHAR(20);
DEFINE cTipoCliente			CHAR(2);
DEFINE cTipoVerificador		CHAR(2);	
DEFINE iHuellasCap			SMALLINT;
DEFINE cStatus				CHAR(1);

-- SET DEBUG FILE TO '/home/sysifx/sp_consultahuelladeclinea.trc';
-- TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet					= '00001';
LET iSqlErr					= 0;
LET cEmpresa				= '';
LET shSecuencia				= 0;
LET cNumCte					= '';
LET cSucursal				= '';
LET cIp						= '';
LET iContador				= 0;
LET cSexo					= '';
LET cTipoMov				= '';
LET cFechaAlta 				= TO_CHAR(CURRENT, '%m/%d/%Y');
LET cFechaCambio 			= TO_CHAR(CURRENT, '%m/%d/%Y');
LET cEmpleado				= '';
LET cTipoSensor				= '';
LET cSituacion				= '';
LET cReferencia				= '';
LET cTipoCliente			= '';
LET cTipoVerificador		= '';
LET iHuellasCap				= 0;
LET cStatus					= '0';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCte, cSexo, shSecuencia, cIp, cSucursal, cFechaAlta, cTipoMov, cEmpleado, cTipoSensor, cSituacion, 
					cReferencia, cFechaCambio, cTipoCliente, cTipoVerificador,iHuellasCap WITH RESUME;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (NVL(pStatus,'') == '')THEN
		RETURN cCodRet, cNumCte, cSexo, shSecuencia, cIp, cSucursal, cFechaAlta, cTipoMov, cEmpleado, cTipoSensor, cSituacion, cReferencia, 
			cFechaCambio, cTipoCliente, cTipoVerificador,iHuellasCap WITH RESUME;
	ELSE
		FOREACH
			SELECT numcte,secuencia,sexo,sucursal,fecha_alta_huella,
					ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,fecha_ult_cambio,huellas_cap
				INTO cNumCte, shSecuencia,cSexo, cSucursal, cFechaAlta, cIp, cTipoMov, cEmpleado, cTipoSensor, 	cSituacion, cReferencia, 
					cTipoCliente, cTipoVerificador, cFechaCambio, iHuellasCap
			FROM "informix".si_huella_linea_dec
			WHERE status_consulta = pStatus and fecha_consulta=today
			
			LET cCodRet	= '00000';
			
			RETURN cCodRet, cNumCte, cSexo, shSecuencia, cIp, cSucursal, cFechaAlta, cTipoMov, cEmpleado, cTipoSensor, cSituacion, 
				cReferencia,cFechaCambio, cTipoCliente, cTipoVerificador,iHuellasCap WITH RESUME;
		END FOREACH
	END IF;
	
END;
END PROCEDURE;