CREATE PROCEDURE "informix".sp_ostelvalidaautomatico()

DEFINE vHoraActual DATETIME HOUR TO SECOND;
DEFINE vHoraAnterior DATETIME HOUR TO SECOND;
DEFINE dfecha DATE;
DEFINE cHora CHAR(10);
DEFINE vNum_solicitud CHAR(20);
DEFINE vNum_referencia INTEGER;
DEFINE vSecuenciaostel INTEGER;
DEFINE v_numcte CHAR(20);
DEFINE v_numerociudad INTEGER;
DEFINE v_NombreCiudad CHAR(40);
DEFINE v_fecha_insert DATETIME YEAR TO SECOND;
DEFINE v_tipo_ciudad SMALLINT;

--SET DEBUG FILE TO '/tmp/sp_ostelvalidaautomatico.out';
--TRACE ON;

BEGIN

	LET vHoraActual = CURRENT;
	--LET vHora2 = '00:10:00';
	LET cHora = vHoraActual - '00:15:00';
	LET vHoraAnterior = cHora;
	LET v_tipo_ciudad = 0;
	LET dfecha = CURRENT;

	SET ISOLATION TO DIRTY READ;

	FOREACH WITH HOLD

		SELECT {+INDEX("informix".ss_ostelrefsolicitud_pendientes idx_secuenciaostel_pend)} num_solicitud, secuenciaostel
		INTO vNum_solicitud, vSecuenciaostel
		FROM "informix".ss_ostelrefsolicitud_pendientes
		WHERE fecha < dfecha
		OR (fecha = dfecha
		AND hora < vHoraAnterior)
		GROUP BY num_solicitud, secuenciaostel

		UPDATE {+INDEX("informix".ss_ostelrefsolicitud secuenciaostel_idx)} "informix".ss_ostelrefsolicitud SET automatico = '1'
			WHERE num_solicitud = vNum_solicitud AND secuenciaostel = vSecuenciaostel;

		FOREACH 
			/*
			select a.numcte, a.numerociudad, a.ciudad_nombre, a.fecha_insert, b.tipo_ciudad
			into v_numcte, v_numerociudad, v_NombreCiudad, v_fecha_insert, v_tipo_ciudad
			from "informix".ss_osclientesupervisartel a, bdinteg:si_catciudades b
			where a.numerociudad = b.numerociudad
			AND secuenciaostel = vSecuenciaostel
			*/
			SELECT numcte, numerociudad, ciudad_nombre, fecha_insert, ciudadantigua
			INTO v_numcte, v_numerociudad, v_NombreCiudad, v_fecha_insert, v_tipo_ciudad
			FROM "informix".ss_osclientesupervisartel
			WHERE secuenciaostel = vSecuenciaostel

			IF NOT EXISTS(SELECT {+INDEX("informix".ss_ostelSolVigenciaVencida idx_ostelvigven)} SecuenciaOSTel FROM "informix".ss_ostelSolVigenciaVencida WHERE SecuenciaOSTel = vSecuenciaostel) THEN

				INSERT INTO "informix".ss_ostelSolVigenciaVencida(SecuenciaOSTel, Numcte, Ciudad, NombreCiudad, Tipociudad, FechaHoraInicio, FechaHoraFin, InteractionID, Enviada)
					VALUES(vSecuenciaostel, v_numcte, v_numerociudad, v_NombreCiudad, v_tipo_ciudad, v_fecha_insert, vHoraActual, '', '0');

			END IF;

			IF EXISTS(SELECT 1 FROM "informix".ss_ostelrefsolicitud WHERE num_solicitud = vNum_solicitud AND secuenciaostel = vSecuenciaostel AND automatico = '1') THEN

				DELETE {+INDEX("informix".ss_ostelrefsolicitud_pendientes idx_secuenciaostel_pend)} FROM "informix".ss_ostelrefsolicitud_pendientes WHERE Secuenciaostel = vSecuenciaostel;

			END IF;

		END FOREACH;

	END FOREACH;

END;

END PROCEDURE;