CREATE PROCEDURE "informix".sp_consultaactualizasolicmc2(pEmpresa CHAR(3), pNumSolicitud CHAR(20), pEjecutivoAtiende CHAR(8), pStatus CHAR(2), pCausa CHAR(3), pObservaciones CHAR(300), pTipo SMALLINT, pInicio INTEGER, pFinal INTEGER)
RETURNING
	CHAR(6) 		AS CodRet,
	CHAR(20) 		AS NumSolicitud,
	CHAR(20) 		AS NumCte,
	CHAR(100) 		AS NombreCte,
	CHAR(13) 		AS Rfc,
	CHAR(4) 		AS Sucursal,
	DATE 			AS FechaInsert,
	DATE 			AS FechaModif,
	DECIMAL(18,2) 	AS MontoSolic,
	DECIMAL(18,2) 	AS Eficiencia,
	SMALLINT 		AS Historial,
	CHAR(2) 		AS StatusIni,
	DECIMAL(18,2) 	AS Seccion1,
	DECIMAL(18,2) 	AS Seccion2,
	CHAR(3) 		AS CausaSolic,
	CHAR(300) 		AS Observaciones,
	CHAR(4) 		AS NumProducto,
	CHAR(2) 		AS StatusFin,
	CHAR(8) 		AS EjecAtiende,
	CHAR(8) 		AS EjecAutoriza,
	DATETIME HOUR TO SECOND	AS HoraInsert,
	DATE 			AS FechaDetermin,
	CHAR(1) 		AS Revisado;

---DECLARACIONES
DEFINE cCodRet			CHAR(6);
DEFINE cCodRet2			CHAR(6);
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);

-- VARIABLES DEL PROCESO
DEFINE cNumSolicitud	CHAR(20);
DEFINE cNumCte			CHAR(20);
DEFINE cNombreCte		CHAR(100);
DEFINE cRfc				CHAR(13);
DEFINE cSucursal		CHAR(4);
DEFINE dFechaInsert		DATE;
DEFINE dFechaModif		DATE;
DEFINE dcMontoSolic		DECIMAL(18,2);
DEFINE cStatusIni		CHAR(2);
DEFINE cCausaSolic		CHAR(3);
DEFINE cObservaciones	CHAR(300);
DEFINE cNumProducto		CHAR(4);
DEFINE cStatusFin		CHAR(2);
DEFINE cEjecAtiende		CHAR(8);
DEFINE cEjecAutoriza	CHAR(8);
DEFINE dtHoraInsert		DATETIME HOUR TO SECOND;
DEFINE dFechaDetermin	DATE;
DEFINE cRevisado		CHAR(1);
DEFINE cTimeTranscurrido	CHAR(40);
DEFINE sDiasTransc		SMALLINT;
DEFINE cHorasTransc		CHAR(10);
DEFINE iTmpMaxMostrar	SMALLINT;
DEFINE iDiaCambio		SMALLINT;
DEFINE dcEficiencia		DECIMAL(18,2);
DEFINE sHistorial		SMALLINT;
DEFINE dcSeccion1		DECIMAL(18,2);
DEFINE dcSeccion2		DECIMAL(18,2);
DEFINE cMinTransc		CHAR(10);
DEFINE cMinutosMax		CHAR(10);
DEFINE iPaso			INTEGER;
DEFINE vHoraActual DATETIME HOUR TO SECOND;
DEFINE vHoraAnterior DATETIME HOUR TO SECOND;
DEFINE dfecha DATE;
DEFINE cHora CHAR(10);
DEFINE cMensaje CHAR(80);
DEFINE cStatusNuevo CHAR(2);
DEFINE iMotivoOs INTEGER;
DEFINE iContOS INTEGER;
--APR
DEFINE cValor_alfabetico CHAR(100);


-- INICIALIZACIONES
LET cCodRet				= '00000';
LET cCodRet2			= '00000';
LET iSqlErr				= 0;
LET iSamErr				= 0;
LET cErrorInfo			= '';

-- INICIALIZACIÓN DE VARIABLES DEL PROCESO.
LET cNumSolicitud		= '';
LET cNumCte				= '';
LET cNombreCte			= '';
LET cRfc				= '';
LET cSucursal			= '';
LET dFechaInsert		= DATE(1);
LET dFechaModif			= DATE(1);
LET dcMontoSolic		= 0.00;
LET cStatusIni			= '';
LET cCausaSolic			= '';
LET cObservaciones		= '';
LET cNumProducto		= '';
LET cStatusFin			= '';
LET cEjecAtiende		= '';
LET cEjecAutoriza		= '';
LET dtHoraInsert		= "";
LET dFechaDetermin		= DATE(1);
LET cRevisado			= 'N';
LET cTimeTranscurrido	= '';
LET sDiasTransc			= 0;
LET cHorasTransc		= '00:00:00';
LET iTmpMaxMostrar		= 0;
LET iDiaCambio		= 0;
LET dcEficiencia		= 0.00;
LET sHistorial			= 0;
LET dcSeccion1			= 0.00;
LET dcSeccion2			= 0.00;
LET cMinTransc			= '00:00:00';
LET cMinutosMax			= '';
LET iPaso				= 0;

LET vHoraActual = CURRENT;


LET dfecha = today;
LET cMensaje = "";
LET cStatusNuevo = "";
LET iMotivoOs    = 0;
LET iContOS = 0;

--APR
LET cValor_alfabetico = "";

BEGIN

	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr::CHAR(8);
			RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)),
				   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00),
				   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''),
				   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
		END IF;
	END EXCEPTION;

	  --SET DEBUG FILE TO "/informix/jesus/sp_consultaactualizasolicmc.out";
	  --TRACE ON;

LET vHoraActual = CURRENT;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF NVL(pEmpresa, "") = "" OR NVL(pStatus, "") = "" OR pTipo NOT IN(1,2,3) THEN
		LET cCodRet = "00001"; -- PARAMETROS OBLIGATORIOS.
		RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)),
			   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00),
			   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''),
			   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
	END IF

	-- OBTENEMOS EL VALOR DE HORAS MAXIMO PARA MOSTRAR LAS SOLICITUDES MC.
	SELECT valor_numerico  INTO iTmpMaxMostrar FROM bdicobranza:"informix".cb_param_campania
	WHERE tipo_campania = '56' AND grupo_parametro = 'MCTRLINEA' AND num_parametro = '1';

	-- LIMITE DE TIEMPO MAXIMO PARA SER ATENDIDA UNA SOLICITUD EN PANTALLA CCONCAC.
	SELECT TRIM(valor_alfabetico),valor_numerico INTO cMinutosMax,iDiaCambio FROM bdicobranza:"informix".cb_param_campania
	WHERE tipo_campania = '56' AND grupo_parametro = 'MCTRLINEA' AND num_parametro = '2';

--LET cHora = vHoraActual - '00:10:00';
LET cHora = vHoraActual - cMinutosMax::DATETIME HOUR TO SECOND;
LET vHoraAnterior = cHora;

	-- VALIDAMOS TODAS LAS SOLICITUDES QUE TENGAN MAS DE 15 MIN SIN SER ATENDIDAS POR UN EJECUTIVO SE PASAN A ORDEN DE SUPERVISION.
	IF pTipo IN(1,2) THEN
		LET iPaso = 0; -- INICIALIZAMOS LA VARIABLE PARA CONTROL DE LA INFORMACIÓN.

        SELECT valor_alfabetico
            INTO cValor_alfabetico
        FROM  "informix".ss_param_solicitudes
        WHERE empresa = pEmpresa
        AND secuencia = 14
        AND grupo_parametro = 'MOTIVOS_OS'
        AND num_parametro = 14;

		FOREACH
			SELECT num_solicitud, numcte, sucursal, status_ini, status_fin, ejecutivo_atiende, fecha_insert,num_producto,motivo_os
			INTO cNumSolicitud, cNumCte, cSucursal, cStatusIni, cStatusFin, cEjecAtiende, dFechaInsert,cNumProducto,iMotivoOs
			FROM "informix".ss_solicitudes_mc
			WHERE status_ini = pStatus
			AND (
				   (status_ini = pStatus AND  status_fin = "")
				    AND NVL(ejecutivo_autoriza,'') =''
					AND NVL(ejecutivo_atiende,'') =''
				    AND ((fecha_determinacion + iDiaCambio UNITS DAY < today )
							OR
						 (fecha_determinacion + iDiaCambio UNITS DAY <= today AND hora_insert <= vHoraAnterior)
						 )

				)


					 -- SI LA SOLICITUD TIENE MAS DE 15 MIN Y AUN NO ES ATENDIDA POR UN EJECUTIVO SE PASA A ORDEN DE SUPERVISION.
						UPDATE "informix".ss_solicitudes_mc
						SET status_fin = "EE",
						observaciones = 'Solicitud paso el tiempo maximo para ser atendida',
						fecha_determinacion = TODAY
						WHERE empresa ='001'
						AND num_solicitud = cNumSolicitud;

						IF NVL(cNumProducto,"") <> "6500" THEN

							SELECT COUNT(num_solicitud)
							  INTO iContOS
							  FROM "informix".ss_solicitud_os
							 WHERE empresa = '001'
							   AND num_solicitud = cNumSolicitud
							   AND fecha_solicitud = TODAY;

							   IF iContOS < 1 THEN
						       INSERT INTO "informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
									VALUES("001", cNumSolicitud, TODAY, "S", "SISTEMA", iMotivoOs);
									LET cMensaje = "Solicitud Enviada a Orden de Supervisión";
									LET cStatusNuevo = "EE";
							   END IF;

						ELSE
							IF EXISTS(SELECT num_solicitud FROM  "informix".ss_os_solautdirecta
							WHERE empresa = pEmpresa  AND num_solicitud = cNumSolicitud) THEN
								LET cStatusNuevo = "AT";
								LET cMensaje = "Solicitud Autorizada";
							ELSE
								LET cMensaje = "Solicitud Enviada a Orden de Supervisión";
								LET cStatusNuevo = "EE";

								INSERT INTO "informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
								VALUES("001", cNumSolicitud, TODAY, "S", "SISTEMA", iMotivoOs);

							END IF;

						END IF;

                        IF NVL(cNumProducto,"") <> "6500" AND iMotivoOs = 14 AND cStatusNuevo = 'EE' THEN
                            LET cMensaje = cValor_alfabetico;
                        END IF

                        -- ACTUALIZAMOS LA SOLICITUD
                        EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(pEmpresa, pEjecutivoAtiende, cNumSolicitud, cStatusNuevo, "",cMensaje)
                        INTO cCodRet2;

						IF cCodRet2 <> '000000' THEN
							LET cCodRet = '00002'; -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD.
						END IF

						LET iPaso = 1; -- VARIABLE PARA CONTROL DE LA INFORMACIÓN.
		END FOREACH
		IF pTipo = 2 THEN
			IF DBINFO("sqlca.sqlerrd2") = 0 OR iPaso = 0 THEN
				LET cCodRet = '00004'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.
			END IF;
			RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)),
			   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00),
			   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''),
			   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
		END IF;

	END IF

	-- CONSULTAMOS TODAS LAS SOLICITUDES CON ESTATUS "MC" PARA SER ATENDIDAS POR EL ANALISTA.
	IF pTipo = 1 THEN

		LET iPaso = 0; -- INICIALIZAMOS VARIABLE PARA CONTROL DE LA INFORMACIÓN.

		FOREACH
			SELECT  skip pInicio first pFinal num_solicitud, numcte, sucursal, fecha_insert,
				   monto_solicitado, status_ini, observaciones, num_producto,  status_fin, ejecutivo_atiende,
				   ejecutivo_autoriza,  fecha_determinacion, revisado,hora_insert
			INTO cNumSolicitud, cNumCte, cSucursal, dFechaInsert,  dcMontoSolic, cStatusIni, cObservaciones,
				 cNumProducto, cStatusFin, cEjecAtiende, cEjecAutoriza, dFechaDetermin, cRevisado,dtHoraInsert
			FROM "informix".ss_solicitudes_mc
			WHERE empresa = pEmpresa
			AND  status_ini = pStatus AND  status_fin = ""
			ORDER BY tipo_alta ASC, num_producto ASC, hora_insert  ASC

					LET dFechaModif = dFechaDetermin;

					SELECT rfc,TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
					INTO cRfc,cNombreCte
					FROM bdinteg:"informix".si_cliente
					WHERE empresa = '001'
					AND numcte = cNumCte;

					-- SE OBTIENEN LOS DATOS DE LA INFORMACIÓN CREDITICIA EN COPPEL/BANCOPPEL.
					SELECT situacion_pago, meses_historia
					INTO dcEficiencia, sHistorial
					FROM "informix".ss_resum_scor_fin
					WHERE empresa = pEmpresa
					  AND num_solicitud = cNumSolicitud;

					-- SE OBTIENE LAS PUNTUACIONES DEL SCORING QUE SE LE REALIZÓ AL CLIENTE.
					SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
						   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2
					INTO dcSeccion1, dcSeccion2
					FROM "informix".ss_resumen_scoring
					WHERE empresa = pEmpresa
					  AND num_solicitud = cNumSolicitud
					  AND seccion IN ('1','2');

					LET iPaso = 1; -- VARIABLE PARA CONTROL DE LA INFORMACIÓN.

						RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)),
							   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00),
							   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''),
							   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'') WITH RESUME;



		END FOREACH

		IF DBINFO("sqlca.sqlerrd2") = 0 OR iPaso = 0 THEN
			LET cCodRet = '00003'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.

			RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)),
				   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00),
				   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''),
				   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
		END IF

	END IF;



	-- GUARDAMOS LA RESPUESTA DEL ANALISTA QUE ATENDIO LA SOLICITUD.
	IF pTipo = 3 THEN

		IF NVL(pEmpresa, "") = "" OR NVL(pEjecutivoAtiende, "") = "" OR NVL(pStatus, "") = "" OR NVL(pNumSolicitud, "") = ""  THEN
			LET cCodRet = "00001"; -- PARAMETROS OBLIGATORIOS.
		END IF

		IF NVL(pStatus, "") IN("CM","RT") AND NVL(pCausa, "") = "" THEN
			LET cCodRet = "00001"; -- PARAMETROS OBLIGATORIOS.
		END IF

		IF cCodRet = "00000" THEN
			-- ACTUALIZAMOS LA RESPUESTA DEL ANALISTA QUE ATENDIO LA SOLICITUD.
			UPDATE "informix".ss_solicitudes_mc
			SET status_fin = pStatus,
			ejecutivo_autoriza = pEjecutivoAtiende,
			observaciones = pObservaciones,
			fecha_determinacion = TODAY,
			revisado = "S"
			WHERE empresa = pEmpresa
			  AND num_solicitud = pNumSolicitud
			  AND status_ini = "MC"
			  AND status_fin = ""
			  AND ejecutivo_atiende = pEjecutivoAtiende;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00005'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.

			ELSE

				-- ACTUALIZAMOS LA SOLICITUD
				EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(pEmpresa, 'sistema', pNumSolicitud, pStatus, pCausa, pObservaciones)
				INTO cCodRet2;

				IF cCodRet2 <> '000000' THEN
					LET cCodRet = '00002'; -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD.
				END IF

				IF NVL(pStatus, "") = "EE" THEN
					INSERT INTO "informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
					VALUES("001", pNumSolicitud, TODAY, "S", "SISTEMA", 4);
				END IF

			END IF

		END IF

		RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)),
			   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00),
			   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''),
			   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');

	END IF

END;

END PROCEDURE
