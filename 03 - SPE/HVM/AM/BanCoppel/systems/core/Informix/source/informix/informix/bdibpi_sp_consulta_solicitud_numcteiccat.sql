CREATE PROCEDURE "informix".sp_consulta_solicitud_numcteiccat(pNumCliente CHAR(9))
	RETURNING CHAR(5),CHAR(10),CHAR(10),CHAR(9),CHAR(3),CHAR(30),CHAR(3);
	
	--// ***************************************************************************
	--//FUNCIONALIDAD:   Sp utilizado para consultar la solicitud del cliente para la opcion de entrega de token
	--// Autor: Francisco Rodriguez Ibarra
	--//Fecha:18 Marzo 2010
	
	--03-12-2013
	--Realizo:  Jose Ruben Lopez
	--Se Agrego validacion de para las solicitudes que no tengan estatus 1 o 2
	--Solicito: Jose de Jesus Nevarez
	--BD: bdibpi
	--// ***************************************************************************
	
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vSqlErr          INTEGER;
	DEFINE vNumSolicitud	CHAR(10);
	DEFINE vNumSerieToken  	CHAR(9);
	DEFINE vFecSolicitud	CHAR(10);
	DEFINE vNumGuia			CHAR(30);
	DEFINE vNumEnvio		SMALLINT;
	DEFINE vStatusToken       SMALLINT;
	DEFINE vTipoSolicitud  CHAR(1);
	--SET DEBUG FILE TO "/tmp/sp_consulta_solicitud";
	--TRACE ON;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNumSerieToken = '';
	LET vFecSolicitud = '';
	LET vNumSolicitud = '';
	LET vNumGuia='';
	LET vNumEnvio=0;
	LET vStatusToken = 0;
	LET vTipoSolicitud='';
	
	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
	            RETURN vsCodRet ,vNumSolicitud,vFecSolicitud , vNumSerieToken,vStatusToken,vNumGuia,vNumEnvio;
	      END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT  TS.solicitud,date(TS.f_solicitud)::char(10),TS.ns_token,TS.tipo,TK.id_status,TE.num_guia,TE.num_envio
		INTO vNumSolicitud,vFecSolicitud,vNumSerieToken,vTipoSolicitud,vStatusToken,vNumGuia,vNumEnvio
		FROM bdibpi:"informix".bpi_tokensolicitud AS ts, bdibpi:"informix".tkn_nseries AS TK, bdibpi:"informix".tkn_envios AS TE
		WHERE  TK.ns_token=TS.ns_token
		AND TE.numcte = TS.numcte
		AND TS.solicitud = (select max(solicitud) FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte= pNumCliente)
		AND TE.solicitud = TS.solicitud
        	AND TS.numcte=TRIM(pNumCliente)
        	AND ts.id_status <> '199';
	
		IF (vNumSolicitud IS NULL OR vNumSolicitud='') THEN
			LET vsCodRet='00001';
		ELSE
			IF(vTipoSolicitud <> 1 AND vTipoSolicitud <> 2) THEN
				LET vsCodRet='00004';
			ELIF(vStatusToken<120)THEN
				LET vsCodRet='00002';
			ELIF (vStatusToken>120) THEN
				LET vsCodRet='00003';
			END IF
		END IF
		
		RETURN vsCodRet ,vNumSolicitud,vFecSolicitud , vNumSerieToken,vStatusToken,vNumGuia,vNumEnvio;
	END
END PROCEDURE;