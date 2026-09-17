CREATE PROCEDURE "informix".sp_extraviado_paquete_bei( 
										pNumGuia char(30), 
										pNumSolicitud char(10),
										pUsuario char(8),
										pComentario char(200),
										pCanal char(2))
	RETURNING CHAR(5);
	
	--Elaboró: Moisés Soriano
	--Descripción: Procedimiento que cambia el estatus de los paquetes de PM a extraviados.
	--Fecha: 19-10-2015
	--Solilcitó: José de Jesus Nevarez
	
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vNumCliente      CHAR(9);
	DEFINE vStatusAnt       CHAR(4);
	DEFINE vSqlErr          INTEGER;
	DEFINE vStatusAct       SMALLINT;
	DEFINE vStatusSolAnt    SMALLINT;
	DEFINE vNumSToken		CHAR(9);
	DEFINE vTotTokens		INT;
	DEFINE vTotAux			INT;
	
	--SET DEBUG FILE TO "/home/sysifx/moises/bdibei/sp_extraviado_paquete_bei.out";
	--TRACE ON;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNumCliente='';
	LET vStatusAct=0;
	LET vStatusSolAnt=0;
	LET vNumSToken = '';
	LET vTotTokens = 0;
	LET vTotAux = 0;
	
	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            LET vsCodRet = vSqlErr;
				RETURN vsCodRet;
	      END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		
		SELECT 	numcte  
			INTO vNumCliente 
			FROM bdibei:"informix".bei_envios 
			WHERE solicitud=TRIM(pNumSolicitud)
			AND num_guia=TRIM(pNumGuia);
		
		SELECT COUNT(ns_token) 
			INTO vTotTokens 
			FROM bdibei:"informix".bei_tokensolicitud 
			WHERE solicitud=TRIM(pNumSolicitud);	
			
		
		IF(vNumCliente=='' OR vNumCliente IS NULL) THEN
			LET vsCodRet = '00100';		
		ELSE
			FOREACH	
				SELECT ns_token INTO 
				vNumSToken FROM bdibei:"informix".bei_tokensolicitud 
				WHERE solicitud=TRIM(pNumSolicitud)
				
				SELECT id_status INTO vStatusAnt FROM bdibpi:"informix".tkn_nseries WHERE ns_token=vNumSToken;
			
				IF (vStatusAnt=='' OR vStatusAnt IS NULL) THEN
					LET vsCodRet = '00200';				
				ELSE

					--Actualiza el estatus del token  a extraviado	
					UPDATE bdibpi:"informix".tkn_nseries SET id_status=175 WHERE ns_token=trim(vNumSToken);
					
					--Registra el cambio de estatus del token de estatus anterior a extraviado
					INSERT INTO bdibpi:"informix".tkn_status_token(ns_token,actual,anterior,f_cambio_status,usr_cambio_status,canal) 
																		VALUES(vNumSToken,175,vStatusAnt,CURRENT,pUsuario,pCanal);
					
					LET vTotAux = vTotAux + 1;
					IF(vTotTokens = vTotAux) THEN
							
						--Se obtiene el estatus anterior de las sol
						SELECT id_status 
						INTO vStatusSolAnt
						FROM bdibei:"informix".bei_solicitudtoken WHERE solicitud=pNumSolicitud AND numcte=vNumCliente;
						
						--Registra el cambio de estatus de la solicitud de estatus anterior a 100
						INSERT INTO bdibei:"informix".bei_stasolicitud VALUES(pNumSolicitud,vStatusSolAnt,100,CURRENT);
						
						--Actualiza el estatus de solicitud a 175(extraviado) y graba comentarios
						UPDATE bdibei:"informix".bei_envios SET id_status=175,comentarios=pComentario 
						WHERE solicitud=pNumsolicitud 
						AND num_guia=pNumGuia;
						
						--Actualiza el estatus de solicitud a 100
							UPDATE bdibei:"informix".bei_solicitudtoken SET id_status=100 
							WHERE solicitud=TRIM(pNumSolicitud)
							AND	   numcte=TRIM(vNumCliente);
						
						--Elimina los registros correspondientes a los tokens asignados a la solicitud
						DELETE FROM bdibei:"informix".bei_tokensolicitud WHERE solicitud = TRIM(pNumSolicitud);
					
					END IF;
				END IF;
			END FOREACH;
		END IF;
		RETURN vsCodRet;
	END
END PROCEDURE;