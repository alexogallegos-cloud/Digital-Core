CREATE PROCEDURE "informix".sps_consulta_avatar_bpi(pEmpresa CHAR(3),pIdUsuario CHAR(11))
RETURNING   CHAR(5),--Codigo de retorno
			CHAR(10),--Nombre magen del avatar
			CHAR(50), -- Frase
			INTEGER, -- Numero de intentos al loguearse
			DATETIME YEAR TO SECOND , -- Fecha de primer intento fallido
			CHAR(1), -- Bloqueo temporal
			CHAR(50); -- Mosaico de avatares ficticios

			--Declaración de variables
DEFINE cCodRet CHAR(5);
DEFINE iSql_err INTEGER;
DEFINE cNumCliente CHAR(9);
DEFINE cNomImagen CHAR(10);
DEFINE cFrase CHAR(50);
DEFINE iNumIntentos INTEGER;
DEFINE dFechaPrimerInt DATETIME YEAR TO SECOND;
DEFINE cBloqueoTemporal CHAR(1);
DEFINE cMosaicoImg CHAR(50);

	--Descripción: Consultar Avatar
	--22/04/2015

--Inicializar variables
LET cNumCliente='';
LET cNomImagen='';
LET cFrase='';
LET cCodRet='00000';
LET iNumIntentos = 0;
LET dFechaPrimerInt = '';
LET cBloqueoTemporal = '';
LET cMosaicoImg = '';

	--set debug file to "/home/informix/ivonne/sp_consulta_avatar_bpi.out";
	--trace on;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, '', '','','','','';
		END IF ;
	END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	IF(pEmpresa <> '' OR pEmpresa IS NOT NULL OR pIdUsuario<>'' OR pIdUsuario IS NOT NULL) THEN

		SELECT NUMCLIENTE INTO cNumCliente FROM bdibpi:"informix".bpi_usuario WHERE ID_USUARIO = TRIM(pIdUsuario);
		
		IF (cNumCliente <> '' OR cNumCliente IS NOT NULL) THEN
            SELECT CASE WHEN LENGTH(TRIM(imagen)) = 7 THEN "a00" || substring(imagen FROM 7 FOR 1) ELSE imagen END, 
                   frase, num_intentos_bloqtemp, fecha_bloqtemp, bloqueo_temporal, mosaico_img
			INTO cNomImagen, cFrase, iNumIntentos, dFechaPrimerInt, cBloqueoTemporal, cMosaicoImg
			FROM  bdibpi:"informix".bpi_avatar WHERE num_cte=cNumCliente;
						
			IF(cNomImagen = '' OR cNomImagen IS NULL OR cFrase ='' OR cFrase IS NULL) THEN
				LET cCodRet='00003';
			END IF;

			IF (cBloqueoTemporal = 'T') THEN
				LET cCodRet = '00004'; --Si hay bloqueo temporal
			    IF ((dFechaPrimerInt +  INTERVAL(1) DAY TO DAY) <=  CURRENT ) THEN --si tiene mas de 24hrs

					LET cBloqueoTemporal = 'F';
					LET iNumIntentos = 0;
					LET dFechaPrimerInt = '';
					LET cMosaicoImg = '';

					UPDATE bdibpi:"informix".bpi_avatar SET bloqueo_temporal = cBloqueoTemporal, num_intentos_bloqtemp = iNumIntentos,
					fecha_bloqtemp = dFechaPrimerInt, mosaico_img = cMosaicoImg WHERE num_cte=cNumCliente;

					LET cCodRet = '00000';
				END IF;

			END IF;
		ELSE
			LET cCodRet='00002';
		END IF;
	ELSE
		LET cCodRet='00001';
	END IF;
	
	RETURN cCodRet,cNomImagen,cFrase,iNumIntentos,dFechaPrimerInt,cBloqueoTemporal,cMosaicoImg;

END
END PROCEDURE
Document
'DESCRIPCION: Nuevo sp utilizado en el nuevo proceso de validacion HSM de datos para el login de la bpi', 
'AUTOR:Ilse Gomez',
'FECHA:19-03-2015',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_actualiza_sol_estatus(pUsuario char(8))
returning char(5) as codRet;

--**************************************************************************************
-- Realizó: Nubia Janeth Montoya Medina
-- Actividad: Actualiza las solicitudes y token con estatus 110
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 09-04-2010
--**************************************************************************************
---------------------------------------------------------------------------------------------
--Realizo: Francisco Rodríguez Ibarra
--Modificación:Se modifico para agregar el canal en la tkn_series y tkn_status_token.
--Solicito: Jorge Nuñez
--Fecha:28/09/2010
---------------------------------------------------------------------------------------------
-- Realizó: Jessica Gutiérrez
-- Modificación: Se modifica para que actualice las solicitudes con estatus 110 de tipo 1 y 3
---------------------------------------------------------------------------------------------
-- Realizó: Jessica Gutiérrez
-- Modificación: Se agregan los tipo 6 y 7 de Renovación
---------------------------------------------------------------------------------------------
-- Realizó: Ilse Gómez
-- Modificación: Se agrega la reversión del cargo por concepto de reenvio de token, para todas aquellas
-- solicitudes reactivadas que no concluyeron con el proceso de asignación.
-- Solicitó: José de Jesus Nevarez
-- Fecha de Solicitud: 06-08-2014
---------------------------------------------------------------------------------------------
-- Realizó: Ilse Gómez
-- Modificación: Se modifica la consulta para obtener el folio_suc de la tabla sc_movdia
-- Solicitó: José de Jesus Nevarez
-- Fecha de Solicitud: 09-09-2014
---------------------------------------------------------------------------------------------
-- Realizó: Manuel Ramos
-- Modificación: Se modifica para que no realice el reverso de solicitudes con estatus 110 sin token asignado con fecha de atención menor a 20 minutos.
-- Solicitó: Walber Castro
-- Fecha de Solicitud: 12-06-2015
--**************************************************************************************
-- DECLARA VARIABLES
--**************************************************************************************
	DEFINE sql_err integer;
	DEFINE codRet char(5);
	DEFINE vEstatus char(3);
	DEFINE vTipo char(10);
	DEFINE vSolicitud char(10);
	DEFINE vToken char(9);
	DEFINE vEstatusT char(3);
	DEFINE vTokenS char(9);
	
	DEFINE vFolioSuc char(16);
	DEFINE vFechaHoy date;
	DEFINE vReferencia char(40);
	DEFINE vCliente char(9);
	DEFINE vSucursal char(4);
	DEFINE vFechaAtencion date;
	DEFINE vHoraAtencion DATETIME HOUR TO SECOND;
	DEFINE vFechaHoraAtencion DATETIME YEAR TO FRACTION;
	
--**************************************************************************************
-- INICIALIZA VARIABLES
--**************************************************************************************
	LET	codRet = '00000';
	LET vEstatus = '';
	LET vTipo = '';
	LET vSolicitud = '';
	LET vToken = '';
	LET vEstatus = '';
	LET vTokenS = '';
	
	LET	vFolioSuc  = '';
	LET vFechaHoy = '01/01/1900';
	LET vReferencia = '';
	LET vCliente = '';
	LET vSucursal = '';
	
	
	
	--SET DEBUG FILE TO '/home/sysifx/Ramos/trace/sp_actualiza_sol_estatus.out';
    --TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
	
	   ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let codRet = sql_err;
				RETURN codRet;
		  END IF ;
	   END EXCEPTION ;
		
		
		SELECT fecha_hoy
		INTO vFechaHoy
		FROM bdicheq:"informix".sc_fechas;
		
		
		FOREACH
			
		
			SELECT id_status, tipo, solicitud , folio_suc, numcte, sucursal, date(f_atencion), f_atencion::datetime hour to second
			INTO vEstatus, vTipo, vSolicitud, vFolioSuc, vCliente, vSucursal, vFechaAtencion, vHoraAtencion
			FROM bdibpi:"informix".bpi_tokensolicitud 
			WHERE id_status = '110' AND (ns_token IS NULL OR ns_token = '')
			
			LET vFechaHoraAtencion = ( YEAR(vFechaAtencion) || '-' || MONTH(vFechaAtencion) || '-' || DAY(vFechaAtencion) || ' ' || vHoraAtencion)::DATETIME YEAR TO FRACTION;
			
			IF (current - vFechaHoraAtencion) > '0 00:20:00' THEN
				IF (vFolioSuc IS NOT NULL OR vFolioSuc <> '') THEN
					IF TRIM(SUBSTRING(vFolioSuc FROM 1 FOR 8)) <> "SINCOMIS" THEN
						
						IF (vTipo= 2 or vTipo = 4 or vTipo=7) THEN
							SELECT folio_suc
							INTO vFolioSuc
							FROM bdicheq:"informix".sc_movdia
							WHERE cuenta IN ( SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE num_cte = vCliente )
							AND fech_alt = vFechaHoy AND cancelad <> "S"
							AND transacc = '3006';
							
							IF (vFolioSuc IS NOT NULL OR vFolioSuc <> '') THEN
								EXECUTE PROCEDURE bdicheq:"informix".reversion('001',
																	  vSucursal,
																	  pUsuario,
																	  vFolioSuc,
																	  'A' )
								INTO codRet ;
							END IF;									  
						END IF;
					END IF;
				END IF;
				
				IF (vTipo = 1 or vTipo = 3) THEN
					UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = '100', ns_token='' WHERE solicitud = vSolicitud;
					INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES (vSolicitud, vEstatus, '100', CURRENT);
				ELIF (vTipo= 2 or vTipo = 4 or vTipo=7) THEN
					UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = '180', ns_token='' WHERE solicitud = vSolicitud;
					INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES (vSolicitud, vEstatus, '180', CURRENT);
				ELIF (vTipo= 6 ) THEN
					UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = '200', ns_token='' WHERE solicitud = vSolicitud;
					INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES (vSolicitud, vEstatus, '200', CURRENT);
				END IF;
			END IF;
			
		END FOREACH;
		
		
		FOREACH 
			SELECT ns.ns_token, ns.id_status, s.ns_token, date(s.f_atencion), s.f_atencion::datetime hour to second
			INTO vToken, vEstatusT, vTokenS, vFechaAtencion, vHoraAtencion 
			FROM bdibpi:"informix".tkn_nseries ns 
			LEFT JOIN bdibpi:"informix".bpi_tokensolicitud s ON ns.ns_token = s.ns_token 
			WHERE ns.id_status = '110' AND (s.ns_token IS NULL OR s.ns_token = '')

			LET vFechaHoraAtencion = ( YEAR(vFechaAtencion) || '-' || MONTH(vFechaAtencion) || '-' || DAY(vFechaAtencion) || ' ' || vHoraAtencion)::DATETIME YEAR TO FRACTION;
			
			IF (current - vFechaHoraAtencion) > '0 00:20:00' THEN
				IF (vToken IS NOT NULL OR vToken <> '') THEN
					UPDATE bdibpi:"informix".tkn_nseries SET id_status = '105',canal='04' WHERE ns_token = vToken;
					INSERT INTO bdibpi:"informix".tkn_status_token VALUES (vToken, '105', vEstatusT, CURRENT, 'sysestaf','04');
				END IF;
			END IF;
			
		END FOREACH;
		
		RETURN codRet;

	END;
	
END PROCEDURE;