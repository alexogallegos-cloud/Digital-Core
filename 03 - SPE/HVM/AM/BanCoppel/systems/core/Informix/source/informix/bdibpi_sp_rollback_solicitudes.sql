CREATE PROCEDURE "informix".sp_rollback_solicitudes(pUsuAtiende VARCHAR(8), pCanal VARCHAR(2),pTipo SMALLINT)
RETURNING CHAR(5), CHAR(5);

	--Elaboró: Javier Calderón
	--Objetivo: Hacer un rollback al cancelar un proceso de solicitudes masivas
	--Fecha: 14/01/2011
	--Solicitó: Mauricio León
	
	--Elaboró: Alfonso Cruz
	--Objetivo: SE ACTUALIZO EL sp_rollback_solicitudes.sql PARA QUE LA TABLA bdinteg:si_bpitoken DONDE A AQUELLOS CLIENTES QUE NO SE LE 	
	--ASIGNO TOKEN DEJE 100 AL CAMPO ID_STATUS_TOKEN Y ASI PUEDAN VOLVER A SER ATENDIDOS.
	--Fecha: 18/03/2011
	--Solicitó: Mary Ivonne Cervantes Bautista
	
	--Elaboró: José de Jesús Nevarez
	--Objetivo: Se agregó el rollback a la tabla bdinteg:si_bpitoken para los clientes de la EmpresaNet.
	--Fecha: 130/09/2011
	--Solicitó: Mauricio León
	
	--Elaboró: Francisco Rodríguez Ibarra
	--Objetivo: Se agrego parametro pTipo para identificar si es cliente normal  o es cliente moral.
	--Fecha: 10/10/2011
	--Solicitó: Mauricio León
	
	--Elaboró: Daniel Lazalde
	--Objetivo: Se agregan tipo 6 de Renovación
	--Fecha: 25/11/2013
	--Solicitó: José de Jesús Nevarez

	DEFINE sql_err	INTEGER;
	DEFINE vCodRet	CHAR(5);
	DEFINE vCodRetInf CHAR(5);

	LET vCodRetInf = '00000';
	
	--SET DEBUG FILE TO "/home/nubia/sp_actualiza_sol_estatus.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRetInf = sql_err;
				RETURN vCodRet, vCodRetInf;
			END IF ;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
		
		--Devuelve la solicitud a estatus 'Nueva' y le desasigna el token
		LET vCodRet = '00001';
		UPDATE bdibpi:"informix".bpi_tokensolicitud 
		SET id_status = CASE WHEN tipo = 6 THEN '200' ELSE '100' END, ns_token = '', f_atencion = CURRENT, usr_atiende = pUsuAtiende  
		WHERE solicitud IN (SELECT solicitud FROM bdibpi:"informix".tkn_solprocesadas WHERE estatus_sol = '1');
		
		--Inserta en la bitacora de cambio de estatus de las solicitudes
		LET vCodRet = '00002';
		INSERT INTO bdibpi:"informix".tkn_stasolicitud (solicitud, anterior, actual, f_registro)
		        SELECT a.solicitud, '110', CASE WHEN b.tipo = 6 THEN '200' ELSE '100' END, CURRENT
			FROM bdibpi:"informix".tkn_solprocesadas a INNER JOIN bdibpi:"informix".bpi_tokensolicitud b on a.solicitud = b.solicitud and a.cliente = b.numcte
			WHERE estatus_sol = '1';
		   
		
		--Devuelve al token a estatus 'Solicitud de pre-activacion'
		LET vCodRet = '00003';
		UPDATE bdibpi:"informix".tkn_nseries 
		SET id_status = '105', f_status = CURRENT, canal = pCanal
		WHERE ns_token IN (SELECT dispositivo FROM bdibpi:"informix".tkn_solprocesadas WHERE estatus_sol = '1'); 
		
		--Inserta en la bitacora de cambio de estatus del los tokens
		LET vCodRet = '00004';
		INSERT INTO bdibpi:"informix".tkn_status_token (ns_token, anterior, actual, f_cambio_status, usr_cambio_status, canal)
		    SELECT dispositivo, '110', '105', CURRENT, pUsuAtiende, pCanal
			FROM bdibpi:"informix".tkn_solprocesadas 
			WHERE estatus_sol = '1' and dispositivo <> '';
		
		--Se les desasigna los tokens a los clientes
		-- DSB ALFONSO CRUZ SE CAMBIA EL id_status_token a 100 cuando tipo = 1
		IF( pTipo = 1) THEN
			LET vCodRet = '00005';
			UPDATE bdinteg:"informix".si_bpitoken
			SET ns_token = '', id_status_token = 100
			WHERE num_cliente IN (SELECT cliente FROM bdibpi:"informix".tkn_solprocesadas a 
					  INNER JOIN bdibpi:"informix".bpi_tokensolicitud b on a.solicitud = b.solicitud and a.cliente = b.numcte
					  WHERE a.estatus_sol = '1' and b.tipo = 1);
		ELIF( pTipo = 2) THEN
			LET vCodRet = '0008';
			--Desasigna los token a los clientes de la EmpresaNet
			UPDATE bdinteg:"informix".si_bpitokenpm
			SET ns_token = '', id_status_token = 100
			WHERE num_cliente IN (SELECT cliente FROM bdibpi:"informix".tkn_solprocesadas WHERE estatus_sol = '1');
		END IF;
		--Se borran de la agenda de clientes
		LET vCodRet = '00006';
		DELETE FROM bdibpi:"informix".tkn_agendacte 
		WHERE numcte IN (SELECT cliente FROM bdibpi:"informix".tkn_solprocesadas WHERE estatus_sol = '1');
		
		--Se borran del guias de los clientes
		LET vCodRet = '00007';
		DELETE FROM bdibpi:"informix".tkn_guias
		WHERE cte_destino IN (SELECT cliente FROM bdibpi:"informix".tkn_solprocesadas WHERE estatus_sol = '1');
		
		-- DSB ALFONSO CRUZ 18/03/2011
		-- SE elimina la tabla tkn_tmpsolproceso
		DELETE FROM bdibpi:"informix".tkn_tmpsolproceso;
		
		LET vCodRet = '00000';
		RETURN vCodRet, vCodRetInf;
	END;
END PROCEDURE;