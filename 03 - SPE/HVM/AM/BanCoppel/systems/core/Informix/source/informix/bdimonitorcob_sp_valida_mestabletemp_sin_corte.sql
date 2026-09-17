CREATE PROCEDURE "informix".sp_valida_mestabletemp_sin_corte(pFecha DATE ,pDato  MONEY(16,2),pConcepto CHAR(4))
RETURNING CHAR(5)
	--17-12-2013
	--Realizo: Jose Ruben Lopez
	--Acomoda los datos de la tabla temporal de la primer disposicion del credito consultado y valida la morosidad del cliente por mes
	--------------------------------------------------------
DEFINE cCod_Ret           CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE iSamErr            INTEGER;
DEFINE vDesErr            CHAR(60);

LET cCod_Ret='00000';
BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret;
    END EXCEPTION;
	--set debug file to "/tmp/sp_replicaparm_ruben.out";
	--Trace on;
	ON EXCEPTION IN (-206)
        LET cCod_Ret = '00002';        RETURN cCod_Ret;
    END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

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
			IF(MONTH(pFecha)=1)THEN
					UPDATE tTempInd SET ene=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=2)THEN
					UPDATE tTempInd SET feb=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=3)THEN
					UPDATE tTempInd SET mar=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=4)THEN
					UPDATE tTempInd SET abr=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=5)THEN
					UPDATE tTempInd SET may=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=6)THEN
					UPDATE tTempInd SET jun=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=7)THEN
					UPDATE tTempInd SET jul=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=8)THEN
					UPDATE tTempInd SET ago=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=9)THEN
					UPDATE tTempInd SET sep=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=10)THEN
					UPDATE tTempInd SET octu=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=11)THEN
					UPDATE tTempInd SET nov=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
				--END IF;
				ELIF(MONTH(pFecha)=12)THEN
					UPDATE tTempInd SET dic=pDato where anio=year(pFecha) AND id_concepto=pConcepto;
			END IF;
		RETURN cCod_Ret;
END;
END PROCEDURE;