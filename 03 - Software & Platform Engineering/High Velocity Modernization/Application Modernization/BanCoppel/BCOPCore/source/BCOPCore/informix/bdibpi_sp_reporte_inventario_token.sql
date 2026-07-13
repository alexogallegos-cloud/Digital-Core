CREATE PROCEDURE "informix".sp_reporte_inventario_token(pTipoCons smallint, pNumToken char(9), pFecIni date, pFecFin date, pReg int)
        RETURNING char(5) AS codRetorno,  --Cod. Retorno
				  char(9) AS numSerie,    --Num. Serie Token
				  char(10) AS solcitud,	  --Num. Solicitud
				  smallint AS idStatus,   --Id Status 
				  char(9) AS numCliente,  --Num. Cliente
				  date AS fecSolicitud,   --Fecha Solicitud
				  char(8) AS perSolicita, --Persona que solicita
				  char(4) AS sucursal,    --Sucursal
				  date AS fecAsigacion,   --Fecha Asigancion a cliente
				  date AS fecEnvio,       --Fecha Envio
				  char(8) AS perEnvio,    --Persona que envio
				  date AS fecConfirmacion,--Fecha Conf. de Entrega
				  char(8) AS perConfirma; --Persona que confirma entrega

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obtiene un reporte de inventario de tokens asignados, enviados y entregados
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 11/05/2010

	DEFINE vcodret			char(5);
	DEFINE vNumToken		char(9);
	DEFINE vSolicitud		char(10);
	DEFINE vIdStatus		smallint;
	DEFINE vNumCliente		char(9);
	DEFINE vFecSolicitud	date;
	DEFINE vPerSolicita		char(8);
	DEFINE vSucursal		char(4);
	DEFINE vFecAsignacion	date;
	DEFINE vFecEnvio		date;
	DEFINE vPerEnvio		char(8);
	DEFINE vFecEntrega		date;
	DEFINE vPerConfirma		char(8);
	DEFINE sql_err			integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
			   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma;
       END IF;
END EXCEPTION;

--SET debug file to "/tmp/sp_reporte_inventario_token.out";
--TRACE ON;

LET vcodret = '000';
LET vNumToken = '';
LET vSolicitud = '';
LET vIdStatus = 0;
LET vNumCliente = '';
LET vFecSolicitud = '01-01-1900';
LET vPerSolicita = '';
LET vSucursal = '';
LET vFecAsignacion = '01-01-1900';
LET vFecEnvio = '01-01-1900';
LET vPerEnvio = '';
LET vFecEntrega = '01-01-1900';
LET vPerConfirma = '';

BEGIN

	IF pTipoCons = 2 THEN
		IF NOT EXISTS(SELECT ns_token FROM tkn_nseries WHERE ns_token = pNumToken) THEN
			RETURN '001', vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
			   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma;
		END IF;
	
		IF NOT EXISTS(SELECT ns_token FROM tkn_nseries WHERE ns_token = pNumToken AND (id_status = 110 OR id_status = 120 OR id_status = 130)) THEN
			RETURN '002', vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
			   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma;
		END IF;
		
		SELECT ns_token, id_status 
		INTO vNumToken, vIdStatus
		FROM tkn_nseries 
		WHERE ns_token = pNumToken AND (id_status = 110 OR id_status = 120 OR id_status = 130);
		
		SELECT solicitud, numcte, f_solicitud, usr_solicita, sucursal
		INTO vSolicitud, vNumCliente, vFecSolicitud, vPerSolicita, vSucursal
		FROM bpi_tokensolicitud
		WHERE ns_token = pNumToken;
		
		SELECT MAX(f_cambio_status)
		INTO vFecAsignacion
		FROM tkn_status_token
		WHERE ns_token = pNumToken AND actual = 110 AND anterior = 105;
		
		SELECT f_envio
		INTO vFecEnvio
		FROM tkn_envios
		WHERE solicitud = vSolicitud;
		
		SELECT usr_cambio_status
		INTO vPerEnvio
		FROM tkn_status_token
		WHERE ns_token = pNumToken AND actual = 120 AND anterior = 110;
		
		SELECT MAX(f_cambio_status), usr_cambio_status
		INTO vFecEntrega, vPerConfirma
		FROM tkn_status_token
		WHERE ns_token = pNumToken AND actual = 130 AND anterior = 120
		GROUP BY usr_cambio_status;
		
		RETURN vcodret, vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
			   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma;
	ELSE
		FOREACH
			SELECT SKIP pReg FIRST 10 ns_token, id_status 
			INTO vNumToken, vIdStatus
			FROM tkn_nseries 
			WHERE f_status::date BETWEEN pFecIni AND pFecFin AND (id_status = 110 OR id_status = 120 OR id_status = 130)
			ORDER BY ns_token
			
			SELECT solicitud, numcte, f_solicitud, usr_solicita, sucursal
			INTO vSolicitud, vNumCliente, vFecSolicitud, vPerSolicita, vSucursal
			FROM bpi_tokensolicitud
			WHERE ns_token = vNumToken;
			
			SELECT MAX(f_cambio_status)
			INTO vFecAsignacion
			FROM tkn_status_token
			WHERE ns_token = vNumToken AND actual = 110 AND anterior = 105;
			
			SELECT f_envio
			INTO vFecEnvio
			FROM tkn_envios
			WHERE solicitud = vSolicitud;
			
			SELECT usr_cambio_status
			INTO vPerEnvio
			FROM tkn_status_token
			WHERE ns_token = vNumToken AND actual = 120 AND anterior = 110;
			
			SELECT MAX(f_cambio_status), usr_cambio_status
			INTO vFecEntrega, vPerConfirma
			FROM tkn_status_token
			WHERE ns_token = vNumToken AND actual = 130 AND anterior = 120
			GROUP BY usr_cambio_status;
		
			RETURN vcodret, vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
				   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma WITH RESUME;
		END FOREACH;
	END IF;
	
END;

END PROCEDURE;