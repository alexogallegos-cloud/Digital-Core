CREATE PROCEDURE "informix".sp_agregafechaenvio(pNumSerieToken CHAR(9),
									pNumSolicitud CHAR(10),
									pNumEnvio SMALLINT,
									pStatusSol SMALLINT,
									pComentarios VARCHAR(200),
									pFecEnvio DATE ,
									pNumGuia CHAR(30),
									pNumCliente CHAR(9),
									pTipo CHAR(1),
									pUsuario CHAR(8),
									pCanal char(2)
									)
	RETURNING CHAR(5);
--************************************
--sp_agregaFechaEnvio
--objetivo: Asigna fecha de envios a un paquete.
--Autor: Rrancisco Rodriguez Ibarra
--Fecha: 06 /Enero/ 2010
--****************************************
---------------------------------------------------------------------------------------------
--Realizo: Francisco Rodríguez Ibarra
--Modificación:Se modifico para agregar el canal en la tkn_series y tkn_status_token.
--Solicito: Jorge Nuñez
--Fecha:28/09/2010
---------------------------------------------------------------------------------------------
--Realizo: Ilse Jazmin Gómez Pérez
--Modificación:Se modifico para agregar el tipo Nueva Rnv
--Solicito: José de Jesus Nevarez
--Fecha:22/11/2013
---------------------------------------------------------------------------------------------
	--Declaracion de Variables
	DEFINE vsCodRet CHAR(5);
	DEFINE vSqlErr	INTEGER;
	DEFINE vNumEnvio       SMALLINT;
	
	--Asignacion de Valores a Variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNumEnvio=0;
	
	--SET DEBUG FILE TO "/tmp/sp_agregafechaenvio.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	
	BEGIN
	
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
				--ROLLBACK WORK;
				
	            RETURN vsCodRet;
	      END IF;
		END EXCEPTION;
		
		--Se verifica si la solicitud es nueva o reprocesada
		IF(pTipo=='1') THEN
		--La solicitud es nueva, por lo cual solo se actualiza la fecha de envio
			UPDATE bdibpi:"informix".tkn_envios SET f_envio=pFecEnvio, id_status=120 WHERE solicitud=TRIM(pNumSolicitud) AND num_guia=TRIM(pNumGuia);
            UPDATE bdinteg:"informix".si_bpitoken SET id_status_token=120 WHERE num_cliente=TRIM(pNumCliente);

		ELIF(pTipo=='3') THEN
        -- La solicitud es nueva de Personas Morales, por lo tanto se actualiza en la tabla si_bpitokenpm
       		UPDATE bdibpi:"informix".tkn_envios SET f_envio=pFecEnvio, id_status=120 WHERE solicitud=TRIM(pNumSolicitud) AND num_guia=TRIM(pNumGuia);
            UPDATE bdinteg:"informix".si_bpitokenpm SET id_status_token=120 WHERE num_cliente=TRIM(pNumCliente);
		ELIF(pTipo=='6') THEN
		 -- La solicitud es nueva Rnv, por lo cual solo se actualiza la fecha de envio
       		UPDATE bdibpi:"informix".tkn_envios SET f_envio=pFecEnvio, id_status=120 WHERE solicitud=TRIM(pNumSolicitud) AND num_guia=TRIM(pNumGuia);
		ELSE
		--la solicitud es reprocesada, por lo cual se inserta un regsitro nuevo con numero de envio + 1
			LET vNumEnvio=pNumEnvio+1;
			UPDATE bdibpi:"informix".tkn_envios SET f_envio=pFecEnvio, id_status=120, num_envio=vNumEnvio, comentarios=pComentarios WHERE solicitud=TRIM(pNumSolicitud) AND num_guia=TRIM(pNumGuia);
		END IF;
		--BEGIN WORK;
					
		UPDATE bdibpi:"informix".tkn_nseries SET id_status=120,canal=pCanal WHERE ns_token=trim(pNumSerieToken);
		
		UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = 120 WHERE solicitud = pNumSolicitud;
		
		INSERT INTO bdibpi:"informix".tkn_status_token VALUES(pNumSerieToken, 120,110,CURRENT,pUsuario,pCanal);
		
		INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(pNumSolicitud,110,120,CURRENT);
		
		IF(pTipo=='2') THEN
			UPDATE bdinteg:"informix".si_bpitoken SET id_status_token=120 WHERE num_cliente=TRIM(pNumCliente);
		ELIF (pTipo=='4') THEN
			UPDATE bdinteg:"informix".si_bpitokenpm SET id_status_token=120 WHERE num_cliente=TRIM(pNumCliente);
		END IF;
		--COMMIT WORK;
		
		RETURN vsCodRet;
	END
END PROCEDURE;