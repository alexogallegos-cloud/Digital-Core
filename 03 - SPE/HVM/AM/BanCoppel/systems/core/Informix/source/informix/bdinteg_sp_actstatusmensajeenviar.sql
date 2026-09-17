CREATE PROCEDURE "informix".sp_actstatusmensajeenviar(pFecha datetime year to fraction,pNumCte char(10),pNumCta char(16),pEnviado char(1),pObservaciones varchar(80),pFecha_Envio datetime year to fraction)

	RETURNING  CHAR(5);
	--************************************
	--sp_actstatusmensajeenviar
	--Objetivo:Actualiza el estatus de los clientes a los que ya se les envió correo.
	--Autor: Francisco Rodriguez Ibarra
	--Fecha: 12/07/2010
	--Actualización:Se modificó para poder recibir la fecha en datetime y así realizar la busqueda
	--Fecha:15/07/2010
	--Autor:Francisco Rodriguez Ibarra
	--Actualización: Se agrego nuevo parámetro para guardar la fecha con hora del registro de envio del correo.
	--Fecha: 24/11/2010
	--Autor: Walber Castro	
	--****************************************
	
	--DEFINICION DE VARIABLES
	DEFINE vSqlErr          INTEGER;		--variable usada par obtener el numero de error de informix en caso de que ocurra un error interno de informix.
	DEFINE vsCodRet        	CHAR(5);		--variable para el codigo de retorno
	DEFINE v_sNumCte 		CHAR(10);
	
	--ASIGNACION DE VALORES A LAS VARIABLES
	LET vSqlErr =0;
	LET vsCodRet ="00000";
	LET v_sNumCte="";	
	
	BEGIN
		ON EXCEPTION
			SET vSqlErr
			IF vSqlErr <> 0 THEN
				LET vsCodRet = vSqlErr;
				RETURN vsCodRet;
			END IF;
		END EXCEPTION;

		IF ( NVL( pFecha, '' ) = '' ) OR ( NVL( pNumCte, '' ) = '' ) OR ( NVL( pNumCta, '' ) = '' ) THEN
			--Error en datos de parametros invalidos
			LET vsCodRet = '00001';
			
		ELSE

			SELECT LIMIT 1 numcte  INTO v_sNumCte
				FROM bdinteg:si_mensajes_enviar
				WHERE f_mensaje = pFecha
				AND enviado='F'
				AND numcte = TRIM(pNumCte)
				AND cuenta = TRIM(pNumCta);
			
			IF(v_sNumCte <>'' OR v_sNumCte IS NOT NULL) THEN
				UPDATE bdinteg:si_mensajes_enviar SET enviado=TRIM(pEnviado) , f_enviado=pFecha_Envio , observaciones=TRIM(pObservaciones)
					WHERE f_mensaje = pFecha
					AND enviado='F'
					AND numcte = TRIM(pNumCte)
					AND cuenta = TRIM(pNumCta);
					
			ELSE
				LET vsCodRet="00002";			END IF
		
		END IF;
		
		RETURN vsCodRet;
	END;
END PROCEDURE;