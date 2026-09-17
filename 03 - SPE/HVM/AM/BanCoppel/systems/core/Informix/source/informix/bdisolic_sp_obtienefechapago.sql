CREATE PROCEDURE "informix".sp_obtienefechapago(pEmpresa CHAR(3),pFecha DATE,pNumSol CHAR(20))
RETURNING 	CHAR(6)   AS CodRetorno,  	-- Codigo de retorno
            DATE AS Fecha_PrimerPago,
			INTEGER AS Dia_pago; 	  --fecha del primer pago
		  
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
-- Variables de control de errores
DEFINE isqlerr      	INTEGER;
-- Variables para valores de retorno
DEFINE cCodRet     		CHAR(6); 	      -- Código de retorno de error
DEFINE dtDiaFecha       DATE;
DEFINE dtDiaprimero     DATE;  
DEFINE dtDiaPago        DATE;  
DEFINE dtDiaPagoAux        DATE;  
DEFINE iDiaPago         INTEGER;  
DEFINE iDiastranscurridos         INTEGER;  
DEFINE iFrecuencia         INTEGER;
DEFINE iDiasmenos    INTEGER;  
DEFINE  cMes 			CHAR(2);
DEFINE cAnio			CHAR(4);
DEFINE dDiaprimero		DATE;
DEFINE dDiaUltimo		DATE;
-- ****************************************************************************
-- *           ASIGNACION DE VALORES POR DEFAULT A VARIABLES                  *
-- ****************************************************************************
LET isqlerr     		= 0;

LET cCodRet     		= "000000";
LET dtDiaFecha          = DATE(1);
LET dtDiaprimero        = DATE(1);
LET dtDiaPago           = DATE(1);
LET dtDiaPagoAux           = pFecha;
LET iDiaPago            = 15;
LET iDiastranscurridos  = 0;
LET iFrecuencia  = 0;
LET iDiasmenos       = 0; 
LET dDiaprimero			= '';
LET dDiaUltimo			= '';
LET cMes = '';
LET cAnio = '';

BEGIN
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

ON EXCEPTION SET iSqlErr
      LET cCodRet= iSqlErr;
	  
	  
	  RETURN cCodRet,'',0;
END EXCEPTION;

--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_obtienefechapago.out';
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
 
	IF NVL(pEmpresa,'') = '' OR  NVL(pFecha,"")=""   THEN
		LET cCodRet     = "00001";  --Faltan parametros de entrada
		RETURN cCodRet,'',0;
	END IF;	

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	
	
	  SELECT dia_pago,frecuencia_pgo INTO iDiaPago,iFrecuencia 
	  FROM "informix".ss_sol_nomina  
	  WHERE num_solicitud = pNumSol;
	  
	  IF NVL(iDiaPago,0) =0 OR NVL(iFrecuencia,0) = 0 THEN
		LET cCodRet     = "00002";  --Error al obtener el dia de pago 
		RETURN cCodRet,'',0;
	  END IF;

	  IF iFrecuencia = 1 THEN	
		IF DAY(iDiaPago) IN (29,30,31) THEN
			IF  MONTH(pFecha) = 2 AND DAY(pFecha) NOT IN (28,29) THEN	
				LET cMes = MONTH(pFecha);
				LET cAnio= YEAR (pFecha);
				EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
				INTO cCodRet , dDiaprimero, dDiaUltimo; 
				LET dtDiaPago = dDiaUltimo;
				
				LET iDiastranscurridos =  dtDiaPago - pFecha;	
				IF iDiastranscurridos <= 8 THEN
					CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
					LET cMes = MONTH(dtDiaPago);
					LET cAnio= YEAR (dtDiaPago);
					EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
					INTO cCodRet , dDiaprimero, dDiaUltimo; 
					LET dtDiaPago = dDiaUltimo;					
				END IF;		
				
			ELIF DAY(iDiaPago) = 31 THEN				
				LET cMes = MONTH(pFecha);
				LET cAnio= YEAR (pFecha);
				EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
				INTO cCodRet , dDiaprimero, dDiaUltimo; 
				LET dtDiaPago = dDiaUltimo;			
				
				LET iDiastranscurridos =  dtDiaPago - pFecha;	
				IF iDiastranscurridos <= 8 THEN
					CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
					LET cMes = MONTH(dtDiaPago);
					LET cAnio= YEAR (dtDiaPago);
					EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
					INTO cCodRet , dDiaprimero, dDiaUltimo; 
					LET dtDiaPago = dDiaUltimo;					
				END IF;			
			ELSE 		
				CALL bdicred:"informix".monthadd(pFecha,1) RETURNING dtDiaPagoAux;			
				IF  MONTH(pFecha) = 2 THEN
					LET dtDiaPago = MONTH(dtDiaPagoAux)||"-"||DAY(iDiaPago)||"-"||YEAR(dtDiaPagoAux);	
					
				ELSE 		
					LET dtDiaPago = MONTH(pFecha)||"-"||DAY(iDiaPago)||"-"||YEAR(pFecha);					
				END IF;											
			END IF;
		ELSE
			LET dtDiaPago = MONTH(pFecha)||"-"||DAY(iDiaPago)||"-"||YEAR(pFecha);
		END IF;	
		LET iDiastranscurridos =  dtDiaPago - pFecha;	
		IF iDiastranscurridos < 0  THEN
			LET iDiastranscurridos =  iDiastranscurridos * -1;
			IF iDiastranscurridos >= 8 THEN
					CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
					LET iDiastranscurridos =  dtDiaPago - pFecha;	
			END IF;
		 END IF;
		IF iDiastranscurridos <= 8 THEN
			CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;				
		END IF;
	END IF
	IF iFrecuencia = 2 THEN			  
		  IF  MONTH(pFecha) = 2 THEN
				IF DAY(iDiaPago) = 29  THEN
					LET iDiasmenos =1;
				ELIF DAY(iDiaPago) = 30 THEN
					LET iDiasmenos =2;
				ELIF DAY(iDiaPago) = 31 THEN
					LET iDiasmenos =3;	
				ELSE
					LET iDiasmenos =0;
				END IF;
		 ELSE
				LET iDiasmenos =0;
		 END IF;		
	
		 LET dtDiaPago = MONTH(pFecha)||"-"||DAY(iDiaPago-iDiasmenos)||"-"||YEAR(pFecha);
		 LET iDiastranscurridos =  dtDiaPago - pFecha;	
		
		 IF iDiastranscurridos < 0  THEN
			LET iDiastranscurridos =  iDiastranscurridos * -1;
			IF iDiastranscurridos >= 8 THEN
					CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
					LET iDiastranscurridos =  dtDiaPago - pFecha;	
			END IF;
		 END IF;
		
		 IF iDiastranscurridos <= 8 THEN --- para que se pague esa misma quincena
			IF DAY(dtDiaPago) <= 14  AND MONTH(dtDiaPago) <> 2 THEN 
				LET dtDiaPago = dtDiaPago + 15 UNITS DAY;	
			ELIF DAY(dtDiaPago) <= 13  AND MONTH(dtDiaPago) = 2 THEN 
				LET dtDiaPago = dtDiaPago + 15 UNITS DAY;				
			ELSE
				LET cMes = MONTH(dtDiaPago);
				LET cAnio= YEAR (dtDiaPago);
				EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
				INTO cCodRet , dDiaprimero, dDiaUltimo; 
				LET dtDiaPago = dDiaUltimo;
			END IF;
			
		 END IF;	       		
	END IF		
	RETURN cCodRet,dtDiaPago,iDiaPago;	
END;

END PROCEDURE
