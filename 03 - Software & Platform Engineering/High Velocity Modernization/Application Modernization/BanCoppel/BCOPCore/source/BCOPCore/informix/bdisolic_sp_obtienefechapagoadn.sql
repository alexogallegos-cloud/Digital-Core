CREATE PROCEDURE "informix".sp_obtienefechapagoadn(pEmpresa CHAR(3),pFecha DATE,pNumSol CHAR(20))
RETURNING 	CHAR(6)   AS CodRetorno,  	-- Codigo de retorno
            DATE AS Fecha_PrimerPago,
			INTEGER AS Dia_pago; 	  --fecha del primer pago
		  
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
-- Variables de control de errores
DEFINE isqlerr      	INTEGER;
-- Variables para valores de retorno
DEFINE cCodRet     		CHAR(6); 	      -- Codigo de retorno de error
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

DEFINE dSemana			INTEGER; --RQM 09 616
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

LET dSemana				= 0; --RQM 09 616

BEGIN
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

ON EXCEPTION SET iSqlErr
      LET cCodRet= iSqlErr;
	  
	  
	  RETURN cCodRet,'',0;
END EXCEPTION;

-- SET DEBUG FILE TO '/home/c90271846/sp_obtienefechapagoand.out';
-- TRACE ON;
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
		SELECT dia_pago , frecuencia_pgo
		INTO iDiaPago,iFrecuencia 
		FROM  "informix".ss_adn_solicitudcuenta
		WHERE num_solicitud = pNumSol;	
	END IF;
	  
	IF NVL(iDiaPago,0) =0 OR NVL(iFrecuencia,0) = 0 THEN
		LET cCodRet     = "00002";  --Error al obtener el dia de pago 
		RETURN cCodRet,'',0;
	END IF;

	IF iFrecuencia = 1 THEN	
		IF DAY(iDiaPago) IN (29,30,31) THEN
			IF  MONTH(pFecha) = 2   THEN	
				LET cMes = MONTH(pFecha);
				LET cAnio= YEAR (pFecha);
				EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
				INTO cCodRet , dDiaprimero, dDiaUltimo; 
				LET dtDiaPago = dDiaUltimo;				
				
			ELIF DAY(iDiaPago) = 31 and DAY(pFecha) in (30,31) THEN	
				CALL bdicred:"informix".monthadd(pFecha,1) RETURNING dtDiaPago;				
								
				LET cMes = MONTH(dtDiaPago);
				LET cAnio= YEAR (dtDiaPago);
				EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
				INTO cCodRet , dDiaprimero, dDiaUltimo; 
				LET dtDiaPago = dDiaUltimo;
				--IF dtDiaPago <= pFecha THEN
				--	LET dtDiaPago = MONTH(pFecha)||"-"||DAY(iDiaPago)||"-"||YEAR(pFecha);
				--END IF
			ELSE 						
					--LET dtDiaPago = MONTH(pFecha)||"-"||DAY(iDiaPago)||"-"||YEAR(pFecha);					
				CALL bdicred:"informix".monthadd(pFecha,1) RETURNING dtDiaPagoAux;			
				IF  MONTH(pFecha) = 2 THEN
					LET dtDiaPago = MONTH(dtDiaPagoAux)||"-"||DAY(iDiaPago)||"-"||YEAR(dtDiaPagoAux);
				ELSE 		
					LET dtDiaPago = dtDiaPagoAux;					
				END IF;		
			END IF;
		ELSE
			LET dtDiaPago = MONTH(pFecha)||"-"||DAY(iDiaPago)||"-"||YEAR(pFecha);
		END IF;		
	
		IF dtDiaPago <= pFecha THEN
			CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
			LET dtDiaPago = MONTH(dtDiaPago)||"-"||DAY(iDiaPago)||"-"||YEAR(dtDiaPago);
		END IF 
	END IF
	
	IF iFrecuencia = 2 THEN			  
		IF  MONTH(pFecha) = 2 THEN
			LET cMes = MONTH(pFecha);
			LET cAnio= YEAR (pFecha);
			EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
			INTO cCodRet , dDiaprimero, dDiaUltimo; 
				
			IF DAY(iDiaPago) IN (29,30,31) THEN 
				LET dtDiaPago = dDiaUltimo;
			ELSE 
				LET dtDiaPago = MONTH(pFecha)||"-"||DAY(iDiaPago)||"-"||YEAR(pFecha);
			END IF;
			--IF dDiaUltimo >= pFecha AND (dtDiaPago + 15 UNITS DAY) >= pFecha THEN
			IF  (dtDiaPago + 15 UNITS DAY) >= dDiaUltimo AND DAY(pFecha) >= iDiaPago  THEN
				LET dtDiaPago = dDiaUltimo;
			ELIF (dtDiaPago + 15 UNITS DAY) >  pFecha  THEN				
				LET dtDiaPago = dtDiaPago + 15 UNITS DAY;	
			ELSE
				CALL bdicred:"informix".monthadd(pFecha,1) RETURNING dtDiaPago;	
				LET dtDiaPago = MONTH(dtDiaPago)||"-"||DAY(iDiaPago)||"-"||YEAR(dtDiaPago);
			END IF ;
		ELSE
			LET dtDiaPago = MONTH(pFecha)||"-"||DAY(iDiaPago)||"-"||YEAR(pFecha);
			--LET iDiastranscurridos =  pFecha - dtDiaPago;
			IF  dtDiaPago > pFecha THEN 
				LET dtDiaPago= dtDiaPago;
			ELIF (dtDiaPago + 15 UNITS DAY) > pFecha THEN
				LET dtDiaPago = dtDiaPago + 15 UNITS DAY;	
			ELSE
				CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
			END IF
		END IF;	
		
		IF dtDiaPago = pFecha THEN
			CALL bdicred:"informix".monthadd(pFecha,1) RETURNING dtDiaPago;	
			LET dtDiaPago = MONTH(dtDiaPago)||"-"||DAY(iDiaPago)||"-"||YEAR(dtDiaPago);
		END IF
	END IF	
	
	IF iFrecuencia = 3 THEN	--semanal
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

		 --RQM 09 616
		LET dSemana = CASE WHEN WEEKDAY(pFecha) = 0 THEN 7 ELSE WEEKDAY(pFecha) END;
		LET dSemana = dSemana - iDiaPago;
		LET dtDiaPago = pFecha - dSemana UNITS DAY;
		--LET dtDiaPago = MONTH(pFecha)||"-"||DAY(iDiaPago-iDiasmenos)||"-"||YEAR(pFecha);
		 
		IF dtDiaPago <= pFecha THEN
			LET iDiastranscurridos =  pFecha - dtDiaPago  ;	
			
			IF iDiastranscurridos >= 7 and iDiastranscurridos  < 14 THEN
				LET dtDiaPago = dtDiaPago + 14 UNITS DAY;
			ELIF iDiastranscurridos >= 14 and iDiastranscurridos  < 21 THEN
				LET dtDiaPago = dtDiaPago + 21 UNITS DAY;	
			ELIF iDiastranscurridos >= 21 and iDiastranscurridos  < 28 THEN				
				LET dtDiaPago = dtDiaPago + 28 UNITS DAY;
			ELSE
				LET dtDiaPago = dtDiaPago + 7 UNITS DAY;
			END IF
		END IF
	END IF;
	
	CALL bdicred:"informix".sp_valfechabil(dtDiaPago,'+') RETURNING cCodRet, dtDiaPago;
	RETURN cCodRet,dtDiaPago,iDiaPago;	
END;

END PROCEDURE
