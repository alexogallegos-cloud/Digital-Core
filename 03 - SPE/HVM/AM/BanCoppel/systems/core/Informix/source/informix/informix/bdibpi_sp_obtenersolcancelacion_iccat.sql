CREATE PROCEDURE "informix".sp_obtenersolcancelacion_iccat(pNumCliente char(9))
				 returning char(5) as CodRet, char(10) as solicitud , char(9) as token,char(3) as estatusSol,char(3) as estatusToken
				
	
	--Elaboró: Francisco Rodríguez Ibarra
    --Actividad: Obtiene la solicitud para realizar cancelación de token y solicitud
    --Solicito: Mauricio León
    --Fecha: 01-10-2010
				
				
	-- DECLARA
	DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vSolicitud char(10);
	DEFINE vToken char(9);
	DEFINE vEstatusSol char(3);
	DEFINE vEstatusToken char(3);
	DEFINE vFechaSol date;
	
	-- INICIALIZA
	LET cod_ret = '00000';
	LET vSolicitud = '';
	LET vToken = '';
	LET vEstatusSol = '';
	LET vEstatusToken = '';
	LET vFechaSol='01-01-1900';
	
	
	--SET DEBUG FILE TO "/home/nubia/sp_obtenersolcancelacion.out";
    --TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vSolicitud, vToken, vEstatusSol, vEstatusToken;
		  END IF ;
		END EXCEPTION ;
		
		
		IF (pNumCliente <>'' OR pNumCliente IS NOT NULL) THEN		
			
			--Se obtiene la fecha mas acutal de la solicitud por el cliente
			SELECT max(date(f_solicitud))	
				INTO vFechaSol
				FROM bdibpi:bpi_tokensolicitud 
				WHERE  numcte=TRIM(pNumCliente)	and id_status <> '199'	
			GROUP BY numcte;
			
			IF (vFechaSol <> '' OR vFechaSol IS NOT NULL) THEN
					SELECT  TS.solicitud,TS.ns_token,TS.id_status,TK.id_status
					INTO vSolicitud,vToken,vEstatusSol,vEstatusToken
					FROM bpi_tokensolicitud AS ts, tkn_nseries AS TK
					WHERE TK.ns_token=TS.ns_token
					AND date(TS.f_solicitud)=vFechaSol
					AND TS.numcte=TRIM(pNumCliente);
					
					IF( vSolicitud = '' OR vSolicitud IS NULL) THEN
						LET cod_ret='00003'; -- El cliente no token asignado
					END IF;
			ELSE				
				LET cod_ret='00002'; -- El cliente no tiene solicitud de token aun
			END IF;
		ELSE		
			LET cod_ret='00001'; -- Error en parametros de entrada
		END IF;
		RETURN cod_ret, vSolicitud, vToken, vEstatusSol, vEstatusToken;
	END;
END PROCEDURE;