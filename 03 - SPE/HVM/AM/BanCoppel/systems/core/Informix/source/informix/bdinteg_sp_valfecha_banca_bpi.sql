CREATE PROCEDURE "informix".sp_valfecha_banca_bpi(pCodPais CHAR(3), 
                                              pPriDiaNaturalMes DATE, 
                                              pDiasBloque integer,
                                              pIdOperacion CHAR(4))
											  
-- Clon del sp_valfecha_banca. Calcula el próximo día hábil para ciertas transacciones de la BPI.
-- Autor : Keevyn Adrian Gil Valenzuela
-- FECHA : 21/Octubre/2016
-- BD    : bdinteg

RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque


DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE cCodRet          CHAR(5);

DEFINE dFechaActual        DATE;
DEFINE i,j              INTEGER;
DEFINE siFeriado        INTEGER;

	--SET DEBUG FILE TO "/respaldosbd/Keevyn/sp_sac_valfecha_banca_bpi.out";
	--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    --// ********************************************************************
    --// Calcula dia por dia si es habil, hasta completar el bloque

    LET i = 0;
    LET j = 0;
    WHILE i <= pDiasBloque
		LET dFechaActual = pPriDiaNaturalMes + j;
		LET siFeriado = 0;

		IF(pIdOperacion ='1034')THEN

			IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) THEN --Lunes a Viernes
				SELECT COUNT(*)
				INTO siFeriado
				FROM bdinteg:"informix".si_feriado_banca
				WHERE fecha =dFechaActual
				AND pais =pCodPais and laborable = "N";
				IF siFeriado IS NULL OR siFeriado = 0 THEN
					LET i = i + 1;
				END IF;
			END IF;

		ELSE 
			
			SELECT COUNT(*)
			INTO siFeriado
			FROM bdinteg:"informix".si_feriado_banca
			WHERE fecha = dFechaActual
			AND pais = pCodPais 
			AND MONTH(dFechaActual) = '12' AND DAY(dFechaActual) = '25'  	--Navidad
			OR 	MONTH(dFechaActual) = '01' AND DAY(dFechaActual) = '01';  	--Año Nuevo
			IF siFeriado IS NULL OR siFeriado = 0 THEN
				LET i = i + 1;
			END IF;
			
		END IF;

    LET j = j + 1;
    END WHILE

   RETURN '000',dFechaActual;
END
END PROCEDURE;