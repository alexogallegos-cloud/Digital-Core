CREATE PROCEDURE "informix".sp_extravio_paquete( 
										pEmpresa char(3), 
										pNumGuia char(30), 
										pNumSolicitud char(10),
										pNumSToken char(9),
										pUsuario char(8),
										pNumEnvio char(3),
										pComentario char(200),
										pCanal char(2))
	RETURNING CHAR(5);
	
	--Modifico:JosÃ© RubÃ©n LÃ³pez
	--Actividad: sp encargado para marcar como extraviado el paquete.
	--Fecha: 26-08-2014
	--SolilcitÃ³: JosÃ© de Jesus Nevarez
	
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vNumCliente      CHAR(9);
	DEFINE vStatusAnt       SMALLINT;
	DEFINE vSqlErr          INTEGER;
	DEFINE vStatusAct       SMALLINT;
	DEFINE vStatusSolAnt    SMALLINT;
	DEFINE vTipo       		SMALLINT;
	
	--SET DEBUG FILE TO "/informix/gaby/spdiagnostico/rene/sp_extravio_paquete";
	--TRACE ON;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNumCliente='';
	LET vStatusAct=0;
	LET vStatusSolAnt=0;
	LET vTipo=0;
	LET vStatusAnt = '';
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
			
				--SELECT id_status INTO vStatusAnt FROM bdibpi:"informix".tkn_nseries WHERE ns_token=pNumSToken;

				--IF (vStatusAnt=='' OR vStatusAnt IS NULL) THEN
				--	let vsCodRet = '00300';

				--ELSE

					UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=200 WHERE solicitud=TRIM(pNumSolicitud) AND   numcte=TRIM(vNumCliente);
					UPDATE bdibpi:"informix".tkn_envios SET id_status=175,comentarios=pComentario WHERE solicitud=pNumsolicitud AND num_guia=pNumGuia AND num_envio=pNumEnvio;
					UPDATE bdibpi:"informix".tkn_nseries SET id_status=175,canal=pCanal WHERE ns_token=trim(pNumSToken) and id_status = vStatusSolAnt;
					INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(pNumSolicitud,120,200,CURRENT);
					INSERT INTO bdibpi:"informix".tkn_status_token VALUES(pNumSToken,175,120,CURRENT,pUsuario,pCanal);
				--END IF;
				
			ELSE
			
			
			
			
				IF EXISTS(SELECT SI.num_cliente FROM bdinteg:"informix".si_bpitoken AS SI
							WHERE empresa=TRIM(pEmpresa) 
							AND SI.num_cliente=TRIM(vNumCliente) 
							AND SI.ns_token=TRIM(pNumSToken)) THEN
					
					--se obtiene el estatus anterior de las sol
					SELECT id_status 
					INTO vStatusSolAnt
					FROM bdibpi:"informix".bpi_tokensolicitud WHERE solicitud=pNumSolicitud AND numcte=vNumCliente;
					
					SELECT id_status INTO vStatusAnt FROM bdibpi:"informix".tkn_nseries WHERE ns_token=pNumSToken and id_status = vStatusSolAnt;
					
					
					
					--IF (vStatusAnt=='' OR vStatusAnt IS NULL) THEN
					--	let vsCodRet = '00300';				
					--ELSE
							
						UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=100
							WHERE solicitud=TRIM(pNumSolicitud)
							AND   numcte=TRIM(vNumCliente);
						
						UPDATE bdibpi:"informix".tkn_envios SET id_status=175,comentarios=pComentario WHERE solicitud=pNumsolicitud AND num_guia=pNumGuia AND num_envio=pNumEnvio;
							
						UPDATE bdibpi:"informix".tkn_nseries SET id_status=175 WHERE ns_token=trim(pNumSToken) and id_status = vStatusAnt ;
						
						INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(pNumSolicitud,vStatusSolAnt,100,CURRENT);
						
						INSERT INTO bdibpi:"informix".tkn_status_token(ns_token,actual,anterior,f_cambio_status,usr_cambio_status,canal) 
																		VALUES(pNumSToken,175,vStatusAnt,CURRENT,pUsuario,pCanal);
						
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