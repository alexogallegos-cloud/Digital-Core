CREATE PROCEDURE "informix".sp_grabahuellalinearesultado(
		pTipo SMALLINT,pEstado CHAR(4),pResultado CHAR(10),pCteMatch INTEGER,pEmpresa CHAR(4),pNumCte CHAR(20),pTicket CHAR(20), pSecCpl CHAR(2))
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)  AS CodigoRetorno;
	--DEFINICION DE VARIABLES--
	DEFINE iSql_err  INTEGER;
	DEFINE cCodRet 	 CHAR(5);
	
	DEFINE dFecha	 DATE;
	DEFINE dHora	 DATETIME HOUR TO SECOND;
	DEFINE cNumMsj	 CHAR(3);
	DEFINE iCiclos	 SMALLINT;
	--INICIALIZACION DE VARIABLES--
	LET iSql_err 	 = 0;
	LET cCodRet 	 = '00000';
	
	LET dFecha	= TODAY;
	LET dHora	= CURRENT HOUR TO SECOND;
	LET cNumMsj = "";
	LET iCiclos = 0;

--	SET DEBUG FILE TO "/tmp/Victor/sp_grabahuellalinearesultado_out.sql";
--	TRACE ON;

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy INTO dFecha FROM bdinteg:"informix".si_fechas;
		
		FOR iCiclos = 1 TO LENGTH(pResultado)
			IF SUBSTR(pResultado,iCiclos,1) = 1 THEN
				LET pResultado = iCiclos::CHAR(2);
			END IF;
		END FOR;
		
		IF pResultado <> 10 THEN
			LET pResultado = SUBSTR(pResultado,1,1);
		ELSE
			LET pResultado = SUBSTR(pResultado,1,2);
		END IF;
	
		IF pTipo = 21 THEN --Ejecucion MSJ 601
		
			LET cNumMsj = "601";
			
			IF pEstado = "1" THEN --Se realizó la comparación
				
				--dsb-09/08/2013
				--Validar que no sea el mismo resultado
				IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_huella_linea_resultado WHERE 
				estado_proceso = pEstado AND
				resultado = pResultado AND
				cliente = pCteMatch AND
				ticket = pTicket AND
				empresa = pEmpresa AND
				num_mensaje = cNumMsj AND
				secuenciacpl = pSecCpl) THEN
				
				    IF pTicket <> "0" THEN --Se valida que si es ticket 0 no se inserte
					
						INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
							estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
						VALUES(pEstado,pResultado,pCteMatch,pTicket,dFecha,dHora, pEmpresa, cNumMsj, pSecCpl);
						
				    END IF
					
			END IF;
				
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "1")THEN
				
					IF SUBSTR(pResultado,1,1) <> 0 THEN
						--Hubo Coincidencias
						UPDATE bdinteg:"informix".si_huella_linea
						SET status_consulta = "2", respuesta_msj601 = "1"
						WHERE numcte = pNumCte
						AND ticket = pTicket 
						AND status_consulta = "1";
						
					ELSE
						--No hubo coincidencias
						UPDATE bdinteg:"informix".si_huella_linea
						SET status_consulta = "3", respuesta_msj601 = "1"
						WHERE numcte = pNumCte
						AND ticket = pTicket 
						AND status_consulta = "1";
					
					END IF;
					
				END IF;
			
			ELIF pEstado = "-106" THEN
			
				/*INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"0",0,"0",dFecha,dHora,"0",cNumMsj, pSecCpl);
				*/
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "1")THEN
				
					UPDATE bdinteg:"informix".si_huella_linea
					SET status_consulta = "3", respuesta_msj601 = "0"
					WHERE numcte = pNumCte
					AND ticket = pTicket 
					AND status_consulta = "1";
					
				END IF;
			
			ELIF pEstado <> "1" AND pEstado <> "-106" THEN
			
				/*INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"0",0,"0",dFecha,dHora,"0",cNumMsj,pSecCpl);
				*/
			END IF;
		
		ELIF pTipo = 22 THEN --Ejecucion MSJ 602
		
			LET cNumMsj = "602";
			
			IF pEstado = "1" AND pTicket <> "0" THEN
			
				LET pEstado = "2";
				
				INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"",pCteMatch,pTicket,dFecha,dHora,pEmpresa,cNumMsj,pSecCpl);
				
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "2")THEN
				
					UPDATE bdinteg:"informix".si_huella_linea
					SET status_consulta = "3"
					WHERE numcte = pNumCte
					AND ticket = pTicket 
					AND status_consulta = "2";
					
				END IF;
			
			ELIF pEstado = "-204" THEN
			
				/*INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"",0,"0",dFecha,dHora,pEmpresa,cNumMsj,pSecCpl);
				*/
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "2")THEN
				
					UPDATE bdinteg:"informix".si_huella_linea
					SET status_consulta = "3"
					WHERE numcte = pNumCte
					AND ticket = pTicket 
					AND status_consulta = "2";
					
				END IF;
			
			ELIF pEstado <> "1" AND pEstado <> "-204" THEN
			
				/*INSERT INTO bdinteg:"informix".si_huella_linea_resultado(
					estado_proceso,	resultado, cliente,	ticket,	fecha, hora, empresa, num_mensaje, secuenciacpl)
				VALUES(pEstado,"",0,"0",dFecha,dHora,pEmpresa,cNumMsj,pSecCpl);
				*/
				IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND ticket = pTicket AND status_consulta = "2")THEN
				
					UPDATE bdinteg:"informix".si_huella_linea
					SET status_consulta = "1"
					WHERE numcte = pNumCte
					AND ticket = pTicket 
					AND status_consulta = "2";
					
				END IF;
				
			END IF;
		
		END IF;
		
		RETURN cCodRet;

	END

END PROCEDURE;