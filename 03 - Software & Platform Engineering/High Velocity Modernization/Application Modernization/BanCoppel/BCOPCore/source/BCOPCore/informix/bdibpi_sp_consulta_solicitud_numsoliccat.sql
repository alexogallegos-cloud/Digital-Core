CREATE PROCEDURE "informix".sp_consulta_solicitud_numsoliccat(pNumCliente char(9),pNumSolicitud char(10))
	RETURNING CHAR(5),CHAR(10),CHAR(10),CHAR(9),CHAR(3),CHAR(30),CHAR(3),CHAR(200),CHAR(5),CHAR(200);

	--// ***************************************************************************
	--//FUNCIONALIDAD: Sp utilizado para consultar la solicitud del cliente para la opcion de reenvio token.
	--// Autor: Francisco Rodriguez Ibarra
	--//Fecha:18 Marzo 2010
	--//Modificó: Mauricio León Ibarra
	--//Fecha: 14-06-2011
	--//Modificación: Se validan comentarios en caso de que vengan nulos.
	--//Modificó: ING ALFONSO CRUZ
	--//Fecha: 03-08-2011
	--//Modificación: Se quita la consulta a la tabla bdibpi:"informix".tkn_agendacte
	--// ***************************************************************************

	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vSqlErr          INTEGER;
	DEFINE vNumSolicitud	char(10);
	DEFINE vNumSerieToken  	CHAR(9);
	DEFINE vFecSolicitud	CHAR(10);
	DEFINE vNumGuia			CHAR(30);
	DEFINE vNumEnvio		SMALLINT;
	DEFINE vStatusSol	    SMALLINT;
	DEFINE vDomicilio 		CHAR(200);
	DEFINE vCosto			CHAR(5);
	DEFINE vComentario		CHAR(200);
	--SET DEBUG FILE TO "/home/nubia/sp_consulta_solicitud.out";
	--TRACE ON;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNumSerieToken = '';
	LET vFecSolicitud = '';
	LET vNumSolicitud = '';
	LET vNumGuia='';
	LET vNumEnvio=0;
	LET vStatusSol = 0;
	LET vDomicilio='';
	LET vCosto='';
	LET vComentario='';

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
				RETURN vsCodRet ,vNumSolicitud,vFecSolicitud , vNumSerieToken,vStatusSol,vNumGuia,vNumEnvio,vDomicilio,vCosto,vComentario;
	      END IF;
		END EXCEPTION;

		SELECT  NVL(TS.solicitud,''),date(TS.f_solicitud)::char(10),
				NVL(TS.id_status,0),NVL(TE.num_guia,''),NVL(TE.num_envio,0), NVL(TS.comentarios,'')
		INTO vNumSolicitud,vFecSolicitud,vStatusSol,vNumGuia,vNumEnvio,vComentario
		FROM bdibpi:"informix".bpi_tokensolicitud AS ts,bdibpi:"informix".tkn_envios AS TE
		WHERE TE.numcte = TS.numcte
		AND TS.solicitud=TE.solicitud
		AND TS.solicitud=TRIM(pNumSolicitud)
		AND TS.numcte=TRIM(pNumCliente);
		
		IF (vNumSolicitud IS NULL OR vNumSolicitud='') THEN
			LET vsCodRet='00001';
		ELSE
			LET vsCodRet=lpad(vStatusSol,5,'0');
			SELECT valor INTO vCosto FROM bdibpi:"informix".tkn_parametros WHERE id_param=8;
		END IF;

		RETURN vsCodRet ,vNumSolicitud,vFecSolicitud , vNumSerieToken,vStatusSol,vNumGuia,vNumEnvio,vDomicilio,vCosto,vComentario;
	END
END PROCEDURE;