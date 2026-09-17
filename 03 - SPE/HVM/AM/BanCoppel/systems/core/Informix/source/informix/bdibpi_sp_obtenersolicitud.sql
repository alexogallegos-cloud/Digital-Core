CREATE PROCEDURE "informix".sp_obtenersolicitud (pSucursal char(4), pSolicitud char(10), pToken char(10), pEstatus char(3), pFechaSolicitud char(1), pCliente char(9), pFechaIni char(10), pFechaFin char(10), pRegistros int)
				 returning char(5) as codRet, char(4) as Sucursal, char(10) as FechaSolicitud, char(10) as Solicitud, char(10) as Token, char(9) as Cliente,
							char(3) as Estatus, char(3) as Tipo, char(8) as solicito, char(8) as Envio, char(200) as Comentarios, char(5) as Total

   --Elaboró: Nubia Janeth Montoya Medina
   --Actividad: Genera Reporte de Solicitud
   --Solicito: Mauricio León
   --Fecha: 21-12-2009

   --Modifica: Walber Castro
   --Razón: Se modifica para que el reporte por solicitud tome los comentarios de la tabla bpi_cargarchivoestafetahis.
   --Solicitó: Mauricio León
   --Fecha: 2012-02-15

    -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vSucursal char(4);
	DEFINE vFechaSolicitud char(10);
	DEFINE vToken char(10);
	DEFINE vCliente char(9);
	DEFINE vEstatus char(3); -- smallint
	DEFINE vSolicitud char(10);
	DEFINE vTipo char(3); -- smallint
	DEFINE vSolicito char(8);
	DEFINE vEnvio char(8);
	DEFINE vComentarios char(200);
	DEFINE vTotal integer;

	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vSucursal = '';
	LET vFechaSolicitud = '01-01-1900';
	LET vToken = '';
	LET vCliente = '';
	LET vEstatus = '';
	LET vSolicitud = '';
	LET vTipo = '';
	LET vSolicito = '';
	LET vEnvio = '';
	LET vComentarios = '';
	LET vTotal = 0;

	--SET DEBUG FILE TO "/home/informix/ivonne/sp_obtenerSolicitud.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 10;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
		  END IF ;
		END EXCEPTION ;

		IF (pSucursal IS NOT NULL AND pSucursal <> '') THEN

			IF EXISTS (SELECT sucursal FROM bdibpi:"informix".bpi_tokensolicitud WHERE sucursal = pSucursal) THEN

				FOREACH
					SELECT SKIP pRegistros FIRST 10 sucursal, date(f_solicitud)::char(10) as f_solicitud, solicitud, ns_token, numcte, id_status, tipo, usr_solicita, usr_atiende, comentarios
					INTO vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios
					FROM bdibpi:"informix".bpi_tokensolicitud
					WHERE sucursal = pSucursal and date(f_solicitud) BETWEEN pFechaIni::date and pFechaFin::date

					LET vTotal = vTotal + 1;

					RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vTipo,''), NVL(vSolicito,''), NVL(vEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;

				END FOREACH;

				IF (vSucursal = '') THEN
						LET cod_ret = "00001";
						RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
				END IF;
			ELSE
				LET cod_ret = "00002";
				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
			END IF;

		ELIF (pSolicitud IS NOT NULL AND pSolicitud <> '') THEN
			FOREACH
				SELECT SKIP pRegistros FIRST 10 a.sucursal, date(a.f_solicitud)::char(10) as f_solicitud, a.solicitud, a.ns_token, a.numcte, a.id_status, a.tipo, a.usr_solicita, a.usr_atiende, c.comentarios
				INTO vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios
				--FROM bdibpi:bpi_tokensolicitud
				--WHERE solicitud =  pSolicitud
				FROM bdibpi:"informix".bpi_tokensolicitud a LEFT JOIN bdibpi:"informix".tkn_envios b ON (a.solicitud = b.solicitud)
                LEFT JOIN bdibpi:"informix".bpi_cargarchivoestafetahis c ON (b.num_guia = c.numguia)
				WHERE a.solicitud =  pSolicitud
				AND b.num_guia = (SELECT NUM_GUIA FROM bdibpi:"informix".tkn_envios WHERE solicitud = a.solicitud
                AND NUM_ENVIO = (SELECT MAX(NUM_ENVIO) FROM bdibpi:"informix".tkn_envios WHERE solicitud = a.solicitud ))

				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vTipo,''), NVL(vSolicito,''), NVL(vEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;

			END FOREACH;

			IF (vSolicitud = '') THEN
					LET cod_ret = "00003";
					RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
			END IF;
		ELIF (pToken IS NOT NULL AND pToken <> '') THEN
			FOREACH
				SELECT SKIP pRegistros FIRST 10 sucursal, date(f_solicitud)::char(10) as f_solicitud, solicitud, ns_token, numcte, id_status, tipo, usr_solicita, usr_atiende, comentarios
				INTO vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios
				FROM bdibpi:"informix".bpi_tokensolicitud
				WHERE ns_token = pToken

				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vTipo,''), NVL(vSolicito,''), NVL(vEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;

			END FOREACH;

			IF (vToken = '') THEN
				LET cod_ret = "00004";
				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
			END IF;

		ELIF (pEstatus IS NOT NULL AND pEstatus <> '') THEN

			IF EXISTS (SELECT sucursal FROM bdibpi:"informix".bpi_tokensolicitud WHERE id_status = pEstatus) THEN

				FOREACH
					SELECT SKIP pRegistros FIRST 10 sucursal, date(f_solicitud)::char(10) as f_solicitud, solicitud, ns_token, numcte, id_status, tipo, usr_solicita, usr_atiende, comentarios
					INTO vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios
					FROM bdibpi:"informix".bpi_tokensolicitud
					WHERE id_status = pEstatus and date(f_solicitud) between pFechaIni::date and pFechaFin::date

					LET vTotal = vTotal + 1;

					LET vTotal = vTotal::char(5);

					RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vTipo,''), NVL(vSolicito,''), NVL(vEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;

				END FOREACH;

				IF (vEstatus = '') THEN
						LET cod_ret = "00001";
						RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
				END IF;

			ELSE
				LET cod_ret = "00006";
				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
			END IF;

		ELIF (pFechaSolicitud IS NOT NULL AND pFechaSolicitud <> '') THEN

			FOREACH
				SELECT SKIP pRegistros FIRST 10 sucursal, date(f_solicitud)::char(10) as f_solicitud, solicitud, ns_token, numcte, id_status, tipo, usr_solicita, usr_atiende, comentarios
				INTO vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios
				FROM bdibpi:"informix".bpi_tokensolicitud
				WHERE date(f_solicitud) between pFechaIni::date and pFechaFin::date

				LET vTotal = vTotal + 1;

				LET vTotal = vTotal::char(5);

				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vTipo,''), NVL(vSolicito,''), NVL(vEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;

			END FOREACH;

			IF (vSucursal = '') THEN
				LET cod_ret = "00001";
				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
			END IF;

		ELIF (pCliente IS NOT NULL AND pCliente <> '') THEN
			FOREACH
				SELECT SKIP pRegistros FIRST 10 sucursal, date(f_solicitud)::char(10) as f_solicitud, solicitud, ns_token, numcte, id_status, tipo, usr_solicita, usr_atiende, comentarios
				INTO vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios
				FROM bdibpi:"informix".bpi_tokensolicitud
				WHERE numcte = pCliente

				RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, NVL(vToken,''), NVL(vCliente,''), NVL(vEstatus,''), NVL(vTipo,''), NVL(vSolicito,''), NVL(vEnvio,''), NVL(vComentarios,''), vTotal WITH RESUME;

			END FOREACH;

			IF (vCliente = '') THEN
					LET cod_ret = "00008";
					RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
			END IF;
		ELSE
			LET cod_ret = '00009';
			RETURN cod_ret, vSucursal, vFechaSolicitud, vSolicitud, vToken, vCliente, vEstatus, vTipo, vSolicito, vEnvio, vComentarios, vTotal;
		END IF;

	END;

END PROCEDURE;