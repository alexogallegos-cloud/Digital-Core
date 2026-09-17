CREATE PROCEDURE "informix".sp_devolucion_paquete( 
										pEmpresa char(3), 
										pNumGuia char(30), 
										pNumSolicitud char(10),
										pNumSToken char(9),
										pUsuario char(8),
										pNumEnvio char(3),
										pComentario char(200))
	RETURNING CHAR(5);
	
	--// ***************************************************************************
	--//sp_devolucion_paquete
	--//Version:			 	1.0
	--//Objetivo:			Devolver token
	--//Parametros de Entrada:	
	--//					pEmpresa(El numero de empresa)
	--//					pNumGuia(El numero de Guia)
	--//					pNumSolcitiud(El numero de Solicitud)
	--//					pNumSToken(El numero de  Token)
	--//					pUsuario(El  Usuario)
	--//					pStatus(status): con este estatus se sabe si es devolucion o entrega de token
	--//Parametros salida:
	--//					vsCodRet:codigo de retorno
	--//Autor:	Francisco Rodriguez Ibarra
	--//Fecha: 9 Noviembre 2009	
	--// ***************************************************************************
	
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vNumCliente      CHAR(9);
	DEFINE vStatusAnt       CHAR(4);
	DEFINE vSqlErr          INTEGER;
	DEFINE vStatusAct       SMALLINT;
	--SET DEBUG FILE TO "/tmp/sp_agrega_devolucion";
	--TRACE ON;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vNumCliente='';
	LET vStatusAct=0;
	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
	            RETURN vsCodRet;
	      END IF ;
		END EXCEPTION ;
		
		SELECT 	numcte  INTO vNumCliente 
			FROM tkn_envios 
			WHERE solicitud=TRIM(pNumSolicitud)
			AND num_guia=TRIM(pNumGuia)
			AND num_envio=TRIM(pNumEnvio);
		IF(vNumCliente=='' OR vNumCliente IS NULL) THEN
			let vsCodRet = '00100';		ELSE
			IF EXISTS(SELECT SI.num_cliente FROM bdinteg:si_bpitoken AS SI
						WHERE empresa=TRIM(pEmpresa) 
						AND SI.num_cliente=TRIM(vNumCliente) 
						AND SI.ns_token=TRIM(pNumSToken)) THEN
						
				SELECT id_status INTO vStatusAnt FROM tkn_nseries WHERE ns_token=pNumSToken;
				
				IF (vStatusAnt=='' OR vStatusAnt IS NULL) THEN
					let vsCodRet = '00300';				ELSE
					
						
					UPDATE bpi_tokensolicitud SET id_status=170
						WHERE solicitud=TRIM(pNumSolicitud)
						AND   numcte=TRIM(vNumCliente);
					
					UPDATE tkn_envios SET id_status=170,comentarios=pComentario WHERE solicitud=pNumsolicitud AND num_guia=pNumGuia AND num_envio=pNumEnvio;
						
					UPDATE tkn_nseries SET id_status=105 WHERE ns_token=trim(pNumSToken);
					
					INSERT INTO tkn_stasolicitud VALUES(pNumSolicitud,120,170,CURRENT);
					
					INSERT INTO tkn_status_token VALUES(pNumSToken,105,120,CURRENT,pUsuario);
					
					UPDATE bdinteg:si_bpitoken set id_status_token=0,ns_token=''  WHERE num_cliente=TRIM(vNumCliente);
				END IF;
			ELSE
				let vsCodRet = '00200';			END IF;
		END IF;
		
		RETURN vsCodRet;
	
	END
END PROCEDURE;