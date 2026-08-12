CREATE PROCEDURE "informix".sp_validactepab (pEmpresa CHAR(3), pNumCliente CHAR(13))

RETURNING CHAR(5);

--Declaracion de Variables.
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE vCte CHAR(13);
DEFINE dFechaHoy date;
DEFINE cont CHAR(16);
DEFINE dfecha1 DATE;
DEFINE resp1 CHAR(10);
DEFINE dfecha2 DATE;
DEFINE resp2 CHAR(10);
DEFINE dfecha3 DATE;
DEFINE resp3 CHAR(10);
DEFINE dMax INTEGER;
DEFINE solicitudes INTEGER;
DEFINE dMsj INTEGER;
DEFINE dDias INTEGER;
--Asignacion de Variables.
LET cCodRet = "";
LET iSqlErr = 0;
LET vCte = "";
LET dFechaHoy = "";
LET cont = "";
LET dfecha1 = "";
LET resp1 = "";
LET dfecha2 = "";
LET resp2 = "";
LET dfecha3 = "";
LET resp3 = "";
LET dMax = 0;
LET solicitudes = "";
LET dMsj = 0;
LET dDias = 0;

--SET DEBUG FILE TO "/tmp/sp_validactepab.out";	
--TRACE ON;													

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;								
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;
	
	SELECT valor
	INTO dMax
	FROM bdicred:"informix".sd_param
	WHERE cod_param = 'PAB';
	
	SELECT valor
	INTO dMsj
	FROM bdicred:"informix".sd_param
	WHERE cod_param = 'MPA';
	
	SELECT valor
	INTO dDias
	FROM bdicred:"informix".sd_param
	WHERE cod_param = 'DSO';	
	
	--Valida si tiene solicitud en proceso o menor a 60 dÃ­as
		SELECT count(*) 
		INTO Solicitudes
		FROM bdisolic:"informix".ss_solicitudes a
		INNER JOIN bdisolic:"informix".ss_autorizacion c on (a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud 
		and c.fecha_entrada =  (SELECT MAX(fecha_entrada) FROM bdisolic:"informix".ss_autorizacion h
                                                            WHERE num_solicitud =a.num_solicitud
											                AND status_solicitud = a.status_solicitud)
															AND c.fecha_entrada >= dFechaHoy - dDias)
		WHERE numcte= pNumCliente 
		AND a.status_solicitud IN ("BC","CC","ST","EA","EE","OA","OS","CE","AT","AP","RT","LC","MC","EC","PA");			

		IF Solicitudes > 0 THEN			
			LET cCodRet = '00001';
				
		ELSE
			LET cCodRet = '00000';
		END IF;
			
	-- Si no tiene solicitudes
	IF cCodRet = '00000' THEN
		--Busca cliente en sd_clientes_pab
		SELECT numcte, contador, fecha1, respuesta1, fecha2, respuesta2, ultimafecha, ultimarespuesta 
		INTO vCte, cont, dfecha1, resp1, dfecha2, resp2, dfecha3, resp3
		FROM bdicred:"informix".sd_clientes_preaprobados
		where numcte = pNumCliente
		AND contador < dMax
		AND (fecha1 is null or fecha2 is null or ultimafecha is null)
		AND (canalcaptacion is null or canalcaptacion = "");
		
		IF dMsj = 1 THEN  -- Mensajes por dÃ­a
		
			IF cont is null or cont = "" THEN  -- Cte no se encontrÃ³ en tabla			
				LET cCodRet = '00001';
			ELSE
				IF cont = 0 THEN  -- Cte sin msjs mostrados
					LET cCodRet = '00000';
			
				ELIF cont = 1 then  -- contador 1
					IF (dfecha1 <> "" OR dfecha1 IS NOT NULL) THEN
						IF (dfecha1 < dFechaHoy) then 			
								LET cCodRet = '00000';
						ELSE
								LET cCodRet = '00001';
						END IF;
					END IF;
				ELIF cont = 2 THEN --contador 2
					IF  (dfecha2 <> "" OR dfecha2 IS NOT NULL) THEN					
						IF  dfecha2 < dFechaHoy then 			
							LET cCodRet = '00000';
						ELSE
							LET cCodRet = '00001';
						END IF;
					END IF;
				ELSE
					IF (cont > 2 OR cont < dMax) THEN	
						IF dfecha3 < dFechaHoy THEN
							LET cCodRet = '00000';						
						ELSE
							LET cCodRet = '00001';
						END IF;
					END IF;
				END IF;		
			END IF;
			
		ELSE	-- mÃ¡s de 1 mensaje por dÃ­a	
			IF cont >= dMax THEN  -- llego al limite de mensajes para clientes pab
				LET cCodRet = '00001';			
			ELSE

				IF cont is null or cont = "" THEN  -- Cte no se encontrÃ³ en tabla			
					LET cCodRet = '00001';
					
				ELIF cont = 0 THEN  -- Cte sin msjs mostrados
					LET cCodRet = '00000';
					
				ELIF cont = 1 THEN
					IF (dfecha1 <> "" OR dfecha1 IS NOT NULL) THEN
						IF dfecha1 <= dFechaHoy THEN
							LET cCodRet = '00000';
						ELSE
							LET cCodRet = '00001';
						END IF;
					END IF;
				ELIF cont = 2 THEN	
					IF  (dfecha2 <> "" OR dfecha2 IS NOT NULL) THEN
						IF dfecha2 <= dFechaHoy THEN
							LET cCodRet = '00000';
						ELSE
							LET cCodRet = '00001';
						END IF;
					END IF;
				ELSE
					IF (cont > 2 OR cont < dMax) THEN	
						IF dfecha3 <= dFechaHoy THEN
							LET cCodRet = '00000';							
						END IF;
					END IF;					
					
				END IF;
			END IF;
			
		END IF; -- Mensajes por dÃ­a
	END IF; -- cod ret 00000 cte sin solicitudes
	
	
RETURN cCodRet;
END
END PROCEDURE
;