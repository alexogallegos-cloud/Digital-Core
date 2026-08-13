CREATE PROCEDURE "informix".sp_cce_reporterevimg ( pEmpresa	CHAR(3), 
					 pTipoReporte INTEGER, 
					 pFecha CHAR(10), 
					 pFechaFin CHAR(10), 
					 pNumEjecut CHAR(8))

RETURNING CHAR(5) AS CodigoRetorno,
	INTEGER AS NumEjecut,
	CHAR(7) AS Cheque,
	CHAR(8) AS TiempoInicio,
	CHAR(8) AS TiempoFinal,
	CHAR(1) AS Revisado,
	CHAR(8) AS TiempoTotal,
	DATE AS Fecha_revision,
	INTEGER AS secTiempoTotalRevision,
	INTEGER AS secTiempoTotalNoRevision;
		  
		 
    DEFINE cCodRet        CHAR(5);
    DEFINE iSql_Err       INTEGER;
    DEFINE iSam_Err       INTEGER;
    DEFINE iDesc_Err      CHAR(60);
    DEFINE iEjecutivo     INTEGER;
    DEFINE cCheque        CHAR(7);
    DEFINE dTiempoInicio  DATETIME HOUR TO SECOND;
    DEFINE dTiempoFinal   DATETIME HOUR TO SECOND;
    DEFINE cRevisado      CHAR(1);
    DEFINE dTiempoTotal   DATETIME HOUR TO SECOND;
    DEFINE dFechaRevision DATE;
    DEFINE iSecRevisionTotal INTEGER;
    DEFINE iSecNoRevisionTotal INTEGER;
    
    DEFINE cNombreEjecut  CHAR(100);
    DEFINE v_fechaInicio  DATE;
    DEFINE v_fechaFin     DATE;
    
    
    LET cCodRet         = '00000';
    LET iSql_Err        = 0;
    LET iSam_Err        = 0;
    LET iDesc_Err       = '';
    LET iEjecutivo      = 0;
    LET cCheque         = '';
    LET dTiempoInicio   = DATE(1);
    LET dTiempoFinal    = DATE(1);
    LET cRevisado       = '';
    LET dTiempoTotal    = DATE(1);
    LET v_fechaInicio   = pFecha;
    LET v_fechaFin      = pFechaFin;
    LET dFechaRevision  = DATE(1);
    LET iSecRevisionTotal   = 0;
    LET iSecNoRevisionTotal = 0;
    
    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET ENVIRONMENT IFX_BATCHEDREAD_INDEX '1';

	BEGIN

	    ON EXCEPTION SET iSql_Err, iSam_Err, iDesc_Err
	        /*SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtienecheques.err";*/
	        --TRACE ON;
	        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
		  LET cCodRet = iSql_Err;
		  RETURN cCodRet, iEjecutivo, cCheque, dTiempoInicio::CHAR(8), dTiempoFinal::CHAR(8), cRevisado, dTiempoTotal::CHAR(8), dFechaRevision, NVL(iSecRevisionTotal,0), NVL(iSecNoRevisionTotal,0) ;
	        END IF;
	    END EXCEPTION;
	    
	    IF pTipoReporte = 1 THEN 
	    	
	    
		    FOREACH -- // Consulta los ejecutivos que se encuentran en la tabla cce_usuarios_revisión.
		        		SELECT ejecutivo_reviso, numcheque, tiempo_inicio_revision, tiempo_fin_revision, revisado, tiempo_total_revision, fecha_revision
				INTO iEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, cRevisado, dTiempoTotal, dFechaRevision
				FROM bditef:"informix".cce_cheques_revisados 
				WHERE fecha_revision = v_fechaInicio 
				AND ejecutivo_reviso = CASE WHEN NVL(pNumEjecut,'') <> '' THEN pNumEjecut  ELSE ejecutivo_reviso END
				AND revisado IN (1,0)
				ORDER BY ejecutivo_reviso, fecha_revision ASC
				
				--//Obtener tiempo en segundos de revision total y no revision total
				SELECT  sum( hh + mm + ss) INTO iSecRevisionTotal
						FROM TABLE (multiset(
							SELECT 
							(SUBSTR(tiempo_total_revision,1,2)*3600) as hh, 
							(SUBSTR(tiempo_total_revision,4,2)*60)as mm,
							(SUBSTR(tiempo_total_revision,7,2)*1) as ss
							FROM bditef:'informix'.cce_cheques_revisados
							WHERE fecha_revision = v_fechaInicio 							
							AND ejecutivo_reviso = CASE WHEN NVL(pNumEjecut,'') <> '' THEN pNumEjecut  ELSE ejecutivo_reviso END
							AND revisado = 1		

				));
				
				SELECT  sum( hh + mm + ss) INTO iSecNoRevisionTotal
						FROM TABLE (multiset(
							SELECT 
							(SUBSTR(tiempo_total_revision,1,2)*3600) as hh, 
							(SUBSTR(tiempo_total_revision,4,2)*60)as mm,
							(SUBSTR(tiempo_total_revision,7,2)*1) as ss
							FROM bditef:'informix'.cce_cheques_revisados
							WHERE fecha_revision = v_fechaInicio 							
							AND ejecutivo_reviso = CASE WHEN NVL(pNumEjecut,'') <> '' THEN pNumEjecut  ELSE ejecutivo_reviso END
							AND revisado = 0		

				));
			
		        RETURN cCodRet, iEjecutivo, cCheque, dTiempoInicio::CHAR(8), dTiempoFinal::CHAR(8), cRevisado, dTiempoTotal::CHAR(8), dFechaRevision, NVL(iSecRevisionTotal,0),  NVL(iSecNoRevisionTotal,0)  WITH RESUME;
		    END FOREACH;		    
	    ELSE
		 IF pTipoReporte = 2 THEN
				
			 FOREACH -- // Consulta los ejecutivos que se encuentran en la tabla cce_usuarios_revisión.
				SELECT ejecutivo_reviso, numcheque, tiempo_inicio_revision, tiempo_fin_revision, revisado, tiempo_total_revision, fecha_revision
				INTO iEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, cRevisado, dTiempoTotal, dFechaRevision
				FROM bditef:"informix".cce_cheques_revisados
				WHERE  (fecha_revision BETWEEN v_fechaInicio AND v_fechaFin)  
				AND ejecutivo_reviso = CASE WHEN NVL(pNumEjecut,'') <> '' THEN pNumEjecut  ELSE ejecutivo_reviso END
				AND revisado IN (1,0) 
				ORDER BY ejecutivo_reviso, fecha_revision ASC
				
				--//Obtener tiempo en segundos de revision total
				SELECT  sum( hh + mm + ss) INTO iSecRevisionTotal
						FROM TABLE (multiset(
							SELECT 
							(SUBSTR(tiempo_total_revision,1,2)*3600) as hh, 
							(SUBSTR(tiempo_total_revision,4,2)*60)as mm,
							(SUBSTR(tiempo_total_revision,7,2)*1) as ss
							FROM bditef:'informix'.cce_cheques_revisados
							WHERE  (fecha_revision BETWEEN v_fechaInicio AND v_fechaFin)  
							AND ejecutivo_reviso = CASE WHEN NVL(pNumEjecut,'') <> '' THEN pNumEjecut  ELSE ejecutivo_reviso END
							AND revisado = 1		

				));
				
				SELECT  sum( hh + mm + ss) INTO iSecNoRevisionTotal
						FROM TABLE (multiset(
							SELECT 
							(SUBSTR(tiempo_total_revision,1,2)*3600) as hh, 
							(SUBSTR(tiempo_total_revision,4,2)*60)as mm,
							(SUBSTR(tiempo_total_revision,7,2)*1) as ss
							FROM bditef:'informix'.cce_cheques_revisados
							WHERE  (fecha_revision BETWEEN v_fechaInicio AND v_fechaFin)  
							AND ejecutivo_reviso = CASE WHEN NVL(pNumEjecut,'') <> '' THEN pNumEjecut  ELSE ejecutivo_reviso END
							AND revisado = 0		

				));
		 
				
				RETURN cCodRet, iEjecutivo, cCheque, dTiempoInicio::CHAR(8), dTiempoFinal::CHAR(8), cRevisado, dTiempoTotal::CHAR(8), dFechaRevision, NVL(iSecRevisionTotal,0), NVL(iSecNoRevisionTotal,0)  WITH RESUME;
				
			 END FOREACH;	
		 END IF;
	    
	    END IF;
	   	
	    -- // Se verifica si la consulta regreso informacion.
	    IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	        LET cCodRet = '00001';
	         RETURN cCodRet, iEjecutivo, cCheque, dTiempoInicio::CHAR(8), dTiempoFinal::CHAR(8), cRevisado, dTiempoTotal::CHAR(8), dFechaRevision, NVL(iSecRevisionTotal,0), NVL(iSecNoRevisionTotal,0) ;
	    END IF;
	END;
	
END PROCEDURE

DOCUMENT
'AUTOR: Daniel Lazalde',
'FECHA CREACION: 24 de Diciembre del 2014',
'DESCRIPCION: Obtiene información necesaria para la generación del reporte.',
'VERSION: 20141224.0001',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_actualiza_acumtrapres( pEmpresa CHAR(3) )
RETURNING CHAR(5), INTEGER, INTEGER;
    
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE cCuenta      CHAR(20);
    DEFINE cNumCte      CHAR(20);
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '';
    LET vcodret3 = '';
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET cCuenta = '';
    LET cNumCte = '';
    
    --- SET DEBUG FILE TO "sp_actualiza_acumtrapres.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        -- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_acumtrapres.err";
        -- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO cCuenta
          FROM sc_acumtrapres
          
        LET iContador1 = iContador1 + 1;  
        
        BEGIN WORK;
          
        SELECT num_cte
          INTO cNumCte
          FROM sc_maechq
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta;
           
        UPDATE sc_acumtrapres
           SET numcte = cNumCte
         WHERE cuenta = cCuenta;
         
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET iContador2 = iContador2 + 1;
            COMMIT WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        LET cCuenta = '';
        LET cNumCte = '';
    END FOREACH;

    RETURN vcodret1, iContador1, iContador2;

    END;

END PROCEDURE;