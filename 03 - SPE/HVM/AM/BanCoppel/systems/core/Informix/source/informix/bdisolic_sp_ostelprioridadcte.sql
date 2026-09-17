CREATE PROCEDURE "informix".sp_ostelprioridadcte( p_secuencia INTEGER)
    RETURNING CHAR(6)  AS	CodRet,
              SMALLINT  AS 	PrioridadCte;
		
	--DECLARACION DE VARIABLES.	
	DEFINE cCodRet				CHAR(6);
	DEFINE iSqlErr		   		INTEGER;
	DEFINE sPrioridadCte	 	SMALLINT;
	DEFINE sSecuenciaTelefono 	INTEGER;
	--variables para la tabla bdisolic:ss_osteltelefonos.
	DEFINE cTelTelefono	 		CHAR(10);
	DEFINE iTelSecuencia	 	INTEGER;
	DEFINE cTelDestino		 	CHAR(1);
	--para uso de flags en la busqueda de la prioridad.
	DEFINE cTelCasa		 		CHAR(1);
	DEFINE cTelCelular	 		CHAR(1);
	DEFINE cTelTrabajo	 		CHAR(1);
	DEFINE cTelReferencia	 	CHAR(1);
	DEFINE cTelOtro		 		CHAR(1);	

	--INICIALIZACION DE VARIABLES.
	LET cCodRet	 				= '000000';
	LET iSqlErr		 			= 0;
	LET sPrioridadCte	 		= 0;
	LET sSecuenciaTelefono 		= 0;
	--variables para la tabla bdisolic:ss_osteltelefonos.
	LET cTelTelefono	 		= '';
	LET iTelSecuencia	 		= 0;
	LET cTelDestino	 			= '';	
	--para uso de flags en la busqueda de la prioridad.
	LET cTelCasa 				= '0';
	LET cTelCelular 			= '0';
	LET cTelTrabajo 			= '0';	
	LET cTelReferencia 			= '0';
	LET cTelOtro 				= '0';
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(sPrioridadCte, 0);
			END IF;
		END EXCEPTION;

		IF NVL(p_secuencia,0) = 0 THEN
			LET cCodRet = '000001'; --PARAMETRO VACIO.
			RETURN cCodRet, NVL(sPrioridadCte, 0);
		END IF;
		
		--SET DEBUG FILE TO '/respaldosbd/hectorb/trase.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--se verifica si existen registros de telefono para el cliente.
		SELECT  NVL(MAX(secuenciatelefono),0)
		INTO  sSecuenciaTelefono
		FROM 	"informix".ss_osteltelefonos
		WHERE	secuenciaostel = p_secuencia
			AND  secuencia = 0;

		--se valida si el cliente tuvo telefonos.
		IF ( sSecuenciaTelefono > 0) THEN
			--se recupera cada telefono del cliente.
			FOREACH

				SELECT NVL(secuencia,0), NVL(telefono,""), NVL(destino,"0")
				INTO iTelSecuencia, cTelTelefono, cTelDestino
				FROM "informix".ss_osteltelefonos
				WHERE secuenciaostel = p_secuencia

				--si el campo telefono estaba en blanco entonces no es necesario agregar telefono.
				IF TRIM(cTelTelefono) <> "" THEN                        					
						
					CALL "informix".fnsolonumerosychar (SUBSTR(cTelDestino, 1, LENGTH(cTelDestino))) RETURNING cTelDestino;	
					
					IF iTelSecuencia = 0 THEN
						-- TELEFONO DEL CLIENTE
						IF TRIM(cTelDestino) = '1' THEN
							--casa
								LET cTelCasa = '1';						
						ELIF TRIM(cTelDestino) = '2' THEN
							--celular
								LET cTelCelular = '1';						
						ELIF TRIM(cTelDestino) = '3' THEN
							--trabajo
								LET cTelTrabajo = '1';						
						ELIF TRIM(cTelDestino) = '4' THEN
							--otro
								LET cTelOtro = '1';
						END IF;
					ELSE
						--TELEFONOS DE REFERENCIAS
						IF TRIM(cTelDestino) = '1' OR TRIM(cTelDestino) = '2' THEN 
							LET cTelReferencia = '1';													
						END IF;
					END IF;
				END IF;

				
			END FOREACH;	


			SELECT NVL(MAX(prioridad),0)
			INTO sPrioridadCte
			FROM "informix". ss_ostelprioridadesmarcacion
			WHERE celcte = TRIM(cTelCelular)
			AND telref = TRIM(cTelReferencia)
			AND telcasa_cte = TRIM(cTelCasa)
			AND teltrabajo_cte = TRIM(cTelTrabajo);
			
			
			--se obtiene la prioridad de marcacion asegun los telefonos proporcionados por el cliente.
			   RETURN cCodRet, NVL(sPrioridadCte, 0);
		ELSE
			LET cCodRet = "000002"; --Secuencia no encontrada
			RETURN cCodRet, NVL(sPrioridadCte, 0);
		END IF;
	END;						  
END PROCEDURE
