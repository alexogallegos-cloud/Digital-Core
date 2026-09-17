CREATE PROCEDURE "informix".sp_valida_morosidad_credinomina_tabtemp(pFecha DATE ,pDato  MONEY(16,2),pConcepto CHAR(4),pDiaCorte CHAR(2),pTipoCredito CHAR(4))
RETURNING CHAR(5)
	--31-01-2014
	--Realizo: Jose Ruben Lopez
	--Acomoda los datos de la tabla temporal de la morosidad de credinomina
	--Solicito:Jorge Nuñez
	--BD: bdimonitorcob
	--------------------------------------------------------
DEFINE cCod_Ret           CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE iSamErr            INTEGER;
DEFINE vDesErr            CHAR(60);

DEFINE diaCorte1          CHAR(2);
DEFINE diaFinMes		  CHAR(2);
DEFINE diaCorte2          CHAR(2);
DEFINE fechaAux           DATE;
DEFINE registroTemp       MONEY(16,2);

LET cCod_Ret='00000';
LET registroTemp='';
LET fechaAux=DATE(MONTH(pFecha) || '/01/' || YEAR(pFecha));
LET fechaAux=fechaAux + 1 UNITS MONTH;
LET fechaAux = fechaAux - 1 UNITS DAY;
LET diaFinMes= DAY(fechaAux);

--SET DEBUG FILE TO "/informix/ALL/sp_valida_mes_tabla_temporal.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret;
    END EXCEPTION;
	
	ON EXCEPTION IN (-206)
        LET cCod_Ret = '00002';        RETURN cCod_Ret;
    END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--SE CALCULA LA FECHA DE CORTE DE ACUERDO AL TIPO DE CREDITO REVOLVENTE O PLAZOS
	IF pTipoCredito='revo'THEN-- PRODUCTOS TARJETAS CREDITO
		LET diaCorte1=pDiaCorte;
		LET diaCorte2=pDiaCorte+1;
	ELSE--PLAZ-PRODUCTOS SIN TARJETAS CREDITO
		LET diaCorte1=pDiaCorte/*+1*/;		LET diaCorte2=pDiaCorte +1;
	END IF;
	
	IF pFecha ='' THEN
		LET cCod_Ret = '00001'; -- parametro en blanco.
		RETURN cCod_Ret;
	END IF;
	IF pDato ='' THEN
		LET cCod_Ret = '00001'; -- parametro en blanco.
		RETURN cCod_Ret;
	END IF
	IF pConcepto ='' THEN
		LET cCod_Ret = '00001'; -- parametro en blanco.
		RETURN cCod_Ret;
	END IF
	IF pDiaCorte ='' THEN
		LET cCod_Ret = '00001'; -- parametro en blanco.
		RETURN cCod_Ret;
	END IF
			IF((MONTH(pFecha)=1 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=12 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
					
					IF MONTH(pFecha)=12 THEN
						
						UPDATE tTempInd SET ene=pDato where anio=year(pFecha)+1 AND id_concepto=pConcepto;
					
					ELSE

						UPDATE tTempInd SET ene=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
		
					END IF;
			
		ELIF((MONTH(pFecha)=2 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR ( MONTH(pFecha)=1 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
				
					UPDATE tTempInd SET feb=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			ELIF((MONTH(pFecha)=3 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=2 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
			
					UPDATE tTempInd SET mar=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			ELIF((MONTH(pFecha)=4 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=3 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
				
					UPDATE tTempInd SET abr=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			ELIF((MONTH(pFecha)=5 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=4 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes)  )THEN
				
					UPDATE tTempInd SET may=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			ELIF((MONTH(pFecha)=6 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=5 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
				
					UPDATE tTempInd SET jun=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			ELIF((MONTH(pFecha)=7 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=6 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
			
					UPDATE tTempInd SET jul=pDato where anio=year(pFecha) AND id_concepto=pConcepto;

			ELIF((MONTH(pFecha)=8 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=7 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
			
					UPDATE tTempInd SET ago=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			ELIF((MONTH(pFecha)=9 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=8 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
		
					UPDATE tTempInd SET sep=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			ELIF((MONTH(pFecha)=10 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=9 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
			
					UPDATE tTempInd SET octu=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			ELIF((MONTH(pFecha)=11 AND DAY(pFecha) BETWEEN 1 AND diaCorte1) OR (MONTH(pFecha)=10 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
				
					UPDATE tTempInd SET nov=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			ELIF((MONTH(pFecha)=12 AND DAY(pFecha) BETWEEN 1 AND diaCorte1)  OR (MONTH(pFecha)=11 AND DAY(pFecha) BETWEEN diaCorte2 AND diaFinMes))THEN
			
					UPDATE tTempInd SET dic=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			
			END IF;
		RETURN cCod_Ret;
END;
END PROCEDURE;