CREATE PROCEDURE "informix".sp_actualiza_estatus_correos()
RETURNING CHAR(6), CHAR(100);
	DEFINE cCodRet			CHAR(6);
	DEFINE cErrorSQL		CHAR(100);
	DEFINE i_SqlError		INTEGER;
	DEFINE i_iSamError		INTEGER;
	
	DEFINE cNumcte			CHAR(20);
		
	DEFINE iTrans_abierta	INTEGER;
	DEFINE iTotalReg		INTEGER;
	DEFINE iProcesados		INTEGER;
	DEFINE MAXTRANSACCION	INTEGER;
	
	DEFINE cCorreo		CHAR(20);
	DEFINE iMaxSecuencia	INTEGER;
	DEFINE iCantidad		INTEGER;
	DEFINE cTipo_Correo		CHAR(1);
	DEFINE dFecha_Proceso	DATE;
		
	LET iMaxSecuencia = 0;
	LET iProcesados = 0;
	LET cCodRet = '000000';
	LET MAXTRANSACCION = 300;		
	LET iTrans_abierta= 0;
	LET cErrorSQL = 'PROCESO TERMINADO SATISFACTORIAMENTE';
	
	--SET DEBUG FILE TO "/informix/josea/sp_actualiza_estatus_correos.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET i_SqlError,i_iSamError, cErrorSQL
			IF i_SqlError <> 0 THEN				
				IF iTrans_abierta = 1 THEN
					ROLLBACK WORK;
					LET iTrans_abierta = 0;
				END IF;				
				LET cCodRet = i_SqlError;								
				RETURN cCodRet, cErrorSQL;
			END IF;
		END EXCEPTION;
		
		FOREACH WITH HOLD
			SELECT DISTINCT TRIM(numcte) AS numcte, tipo_correo, COUNT(*) AS cantidad
			INTO cNumcte, cTipo_Correo, iCantidad
			FROM si_correos
			WHERE status_correo = 'A'
			GROUP BY 1,2 HAVING COUNT(*) > 1
			
			IF iProcesados = 0 THEN
				BEGIN WORK;
				LET iTrans_abierta = 1;
			END IF;				
			
			SELECT MAX(secuencia) 
			INTO iMaxSecuencia
			FROM si_correos
			WHERE numcte = cNumcte
			AND tipo_correo = cTipo_Correo;
			
			UPDATE si_correos
			SET status_correo = 'C'
			WHERE numcte = cNumcte
			AND tipo_correo = cTipo_Correo
			AND secuencia < iMaxSecuencia;
			
			UPDATE si_correos
			SET status_correo = 'A'
			WHERE numcte = cNumcte
			AND tipo_correo = cTipo_Correo
			AND secuencia = iMaxSecuencia;
			
			LET iProcesados = iProcesados + 1;
			
			IF iProcesados >= MAXTRANSACCION THEN
				LET iProcesados = 0;
				COMMIT WORK;
				LET iTrans_abierta = 0;
			END IF;
			
		END FOREACH;
					
		IF iProcesados < MAXTRANSACCION THEN
			IF iProcesados > 0 THEN
				COMMIT WORK;
				LET iTrans_abierta = 0;
			END IF;
			LET iProcesados = 0;
		END IF;

		RETURN cCodRet, cErrorSQL;
	END;
END PROCEDURE;