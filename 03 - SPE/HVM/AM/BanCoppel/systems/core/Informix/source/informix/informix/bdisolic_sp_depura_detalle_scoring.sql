CREATE PROCEDURE "informix".sp_depura_detalle_scoring(vBloque CHAR(2))

	RETURNING CHAR(5), INTEGER
	
	--Declaracion de variables
	DEFINE iSqlErr                  INTEGER;
	DEFINE cCodRet                  CHAR(6); 
	DEFINE iRegCommit               INTEGER;
	DEFINE iCont                    INTEGER;
	DEFINE iCont2                   INTEGER;
	DEFINE vNumSolicitud            CHAR(20);

	--Inicializacion de variables
	LET cCodRet      	                = '00000'; 
	LET iRegCommit      	            = 1000;
	LET iCont      	                    = 0;
	LET iCont2      	                = 0;
	LET vNumSolicitud      	            ="";
	
	--DECLARACION DE VARIABLES DE ERROR
	LET iSqlErr							= 0;	
	
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO '/home/c90236357/Pruebas/Trace/sp_depura_detalle_scoring.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
					ROLLBACK;
				RETURN cCodRet, iCont2;
		   END IF;
		END EXCEPTION;
			
BEGIN WORK;	
			FOREACH WITH HOLD
					
					SELECT num_solicitud
					INTO vNumSolicitud
					FROM depura_ss_detalle_scoring
					WHERE Bloque = trim(vBloque)
														
				    LET iCont = iCont + 1;
					LET iCont2 = iCont2 + 1;
					
					INSERT INTO bdisolic:ss_detalle_scoring_hist
						SELECT *,today FROM bdisolic:ss_detalle_scoring
						WHERE empresa = '001' AND num_solicitud = vNumSolicitud;
					
					DELETE bdisolic:ss_detalle_scoring
						WHERE num_solicitud = vNumSolicitud;
				
					INSERT INTO bdisolic:ss_detalle_modelo_resp
						SELECT * FROM bdisolic:ss_detalle_modelo
						WHERE empresa = '001' AND num_solicitud = vNumSolicitud;

					DELETE bdisolic:ss_detalle_modelo
						WHERE empresa = '001' AND num_solicitud = vNumSolicitud;
					
					DELETE bdisolic:depura_ss_detalle_scoring
						WHERE num_solicitud = vNumSolicitud
						  AND Bloque = trim(vBloque);
									
				   	
				IF iCont >= iRegCommit THEN						
						LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			
COMMIT WORK;

RETURN cCodRet, iCont2;

	END;
END PROCEDURE;