CREATE PROCEDURE "informix".sp_actualiza_sol_estatus()
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
--**************************************************************************************
-- DECLARA VARIABLES
--**************************************************************************************
        DEFINE sql_err integer ;
        DEFINE codRet char(5);
	DEFINE vEstatus char(3);
	DEFINE vTipo char(10);
	DEFINE vSolicitud char(10);
	DEFINE vToken char(9);
	DEFINE vEstatusT char(3);
	DEFINE vTokenS char(9);
	
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
	
	--SET DEBUG FILE TO "/home/nubia/sp_actualiza_sol_estatus.out";
    --TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET LOCK MODE TO WAIT 3;

	BEGIN
	
	   ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let codRet = sql_err;
				RETURN codRet;
		  END IF ;
	   END EXCEPTION ;
		
		FOREACH
                        SELECT id_status, tipo, solicitud 
                        INTO vEstatus, vTipo, vSolicitud
                        FROM bdibpi:bpi_tokensolicitud 
                        WHERE id_status = '110' AND (ns_token IS NULL OR ns_token = '')

                        IF (vTipo = 1 or VTipo = 3) THEN
                                UPDATE bdibpi:bpi_tokensolicitud SET id_status = '100', ns_token='' WHERE solicitud = vSolicitud;
                                INSERT INTO bdibpi:tkn_stasolicitud VALUES (vSolicitud, vEstatus, '100', CURRENT);
                        ELIF (vTipo= 2 or VTipo = 4 or VTipo=7) THEN
                                UPDATE bdibpi:bpi_tokensolicitud SET id_status = '180', ns_token='' WHERE solicitud = vSolicitud;
                                INSERT INTO bdibpi:tkn_stasolicitud VALUES (vSolicitud, vEstatus, '180', CURRENT);
						ELSE
						        UPDATE bdibpi:bpi_tokensolicitud SET id_status = '200', ns_token='' WHERE solicitud = vSolicitud;
                                INSERT INTO bdibpi:tkn_stasolicitud VALUES (vSolicitud, vEstatus, '200', CURRENT);
                        END IF;
		END FOREACH;
		
		
		FOREACH 
                        SELECT ns.ns_token, ns.id_status, s.ns_token 
                        INTO vToken, vEstatusT, vTokenS 
                        FROM bdibpi:tkn_nseries ns 
                        LEFT JOIN bdibpi:bpi_tokensolicitud s ON ns.ns_token = s.ns_token 
                        WHERE ns.id_status = '110' AND (s.ns_token IS NULL OR s.ns_token = '')

                            UPDATE bdibpi:tkn_nseries SET id_status = '105',canal='04' WHERE ns_token = vToken;
                            INSERT INTO bdibpi:tkn_status_token VALUES (vToken, '105', vEstatusT, CURRENT, 'sysestaf','04');

		END FOREACH;
		
		RETURN codRet;

	END;
	
END PROCEDURE;