CREATE PROCEDURE "informix".sp_danado_paquete( 
										pEmpresa char(3), 
										pNumGuia char(30), 
										pNumSolicitud char(10),
										pNumSToken char(9),
										pUsuario char(8),
										pNumEnvio char(3),
										pComentario char(200),
										pCanal char(2))
	RETURNING CHAR(5);
	
	--ElaborÃ³: MoisÃ©s Soriano
	--DescripciÃ³n: Procedimiento que cambia el estatus de los paquetes a daÃ±ado.
	--Fecha: 19-10-2015
	--SolilcitÃ³: JosÃ© de Jesus Nevarez
	
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vNumCliente      CHAR(9);
	DEFINE vStatusAnt       SMALLINT;
	DEFINE vSqlErr          INTEGER;
	DEFINE vStatusAct       SMALLINT;
	DEFINE vStatusSolAnt    SMALLINT;
	DEFINE vTipo       		SMALLINT;
	
	--SET DEBUG FILE TO "/informix/gaby/spdiagnostico/rene/sp_danado_paquete.out";
	--TRACE ON;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNumCliente='';
	LET vStatusAct=0;
	LET vStatusSolAnt=0;
	LET vTipo=0;

	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
	            RETURN vsCodRet;
	      END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		
		SELECT tipo,id_status INTO vTipo,vStatusSolAnt
		FROM bdibpi:"informix".bpi_tokensolicitud
		WHERE solicitud=TRIM(pNumSolicitud)
		  --AND numcte=vNumCliente
		  AND ns_token=TRIM(pNumSToken);
		
		SELECT 	numcte  INTO vNumCliente 
			FROM bdibpi:"informix".tkn_envios 
			WHERE solicitud=TRIM(pNumSolicitud)
			AND num_guia=TRIM(pNumGuia)
			AND num_envio=TRIM(pNumEnvio);
		
		IF(vNumCliente=='' OR vNumCliente IS NULL) THEN
			let vsCodRet = '00100';		
			
			ELSE
			IF (vTipo=='6' OR vTipo=='7') THEN --Si es Renovada.
			
				SELECT id_status INTO vStatusAnt FROM bdibpi:"informix".tkn_nseries WHERE ns_token=pNumSToken and id_status = vStatusSolAnt ;

				--IF (vStatusAnt=='' OR vStatusAnt IS NULL) THEN
				--	let vsCodRet = '00300';

				--ELSE

					UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=200 WHERE solicitud=TRIM(pNumSolicitud) AND   numcte=TRIM(vNumCliente);
					UPDATE bdibpi:"informix".tkn_envios SET id_status=176,comentarios=pComentario WHERE solicitud=pNumsolicitud AND num_guia=pNumGuia AND num_envio=pNumEnvio;
					UPDATE bdibpi:"informix".tkn_nseries SET id_status=176,canal=pCanal WHERE ns_token=trim(pNumSToken) and id_status = vStatusAnt;
					INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(pNumSolicitud,120,176,CURRENT);
					INSERT INTO bdibpi:"informix".tkn_status_token VALUES(pNumSToken,176,120,CURRENT,pUsuario,pCanal);
				--END IF;
				
			ELSE		
			
			IF EXISTS(SELECT SI.num_cliente FROM bdinteg:"informix".si_bpitoken AS SI
						WHERE empresa=TRIM(pEmpresa) 
						AND SI.num_cliente=TRIM(vNumCliente) 
						AND SI.ns_token=TRIM(pNumSToken)) THEN

				--Se obtiene el estatus anterior de las sol
				SELECT id_status 
				INTO vStatusSolAnt
				FROM bdibpi:"informix".bpi_tokensolicitud WHERE solicitud=pNumSolicitud AND numcte=vNumCliente;
						
				SELECT id_status INTO vStatusAnt FROM bdibpi:"informix".tkn_nseries WHERE ns_token=pNumSToken and id_status = vStatusSolAnt;
				
				
				--IF (vStatusAnt=='' OR vStatusAnt IS NULL) THEN
				--	let vsCodRet = '00300';				
				--ELSE
					
					--Actualiza el estatus de solicitud a 100
					UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=100, ns_token='' 
					WHERE solicitud=TRIM(pNumSolicitud)
					AND	   numcte=TRIM(vNumCliente);
					
					--Actualiza el estatus de solicitud a 176(daÃ±ado) y graba comentarios
					UPDATE bdibpi:"informix".tkn_envios SET id_status=176,comentarios=pComentario 
					WHERE solicitud=pNumsolicitud 
					AND num_guia=pNumGuia 
					AND num_envio=pNumEnvio;
					
					--Actualiza el estatus del token  a daÃ±ado	
					UPDATE bdibpi:"informix".tkn_nseries SET id_status=176 WHERE ns_token=trim(pNumSToken) and id_status = vStatusAnt;
					
					--Registra el cambio de estatus de la solicitud de estatus anterior a 100
					INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(pNumSolicitud,vStatusSolAnt,100,CURRENT);
					
					--Registra el cambio de estatus del token de estatus anterior a daÃ±ado
					INSERT INTO bdibpi:"informix".tkn_status_token(ns_token,actual,anterior,f_cambio_status,usr_cambio_status,canal) 
																	VALUES(pNumSToken,176,vStatusAnt,CURRENT,pUsuario,pCanal);
					--Actualiza el estatus de solicitud a 100 en la tabla bdinteg:si_bpitoken
					UPDATE bdinteg:"informix".si_bpitoken set id_status_token=100,ns_token=''  WHERE num_cliente=TRIM(vNumCliente);
				--END IF;
			ELSE
				let vsCodRet = '00200';	
					END IF;
				END IF;
			END IF;
		
		
		RETURN vsCodRet;
	END
END PROCEDURE;