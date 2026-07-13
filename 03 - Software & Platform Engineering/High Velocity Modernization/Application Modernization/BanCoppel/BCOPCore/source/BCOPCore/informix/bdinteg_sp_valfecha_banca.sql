CREATE PROCEDURE "informix".sp_valfecha_banca(pCodPais 	  CHAR(3),
			    		pPriDiaNaturalMes DATE,
					pDiasBloque       integer)
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque

-- ***************************************************************************
-- splvalfecha          
-- Version              1.0.0
-- Obejtivo:            Calcula la fecha del mes actual FechaIniMes + DiasBloque - 1
--                      donde Días bloque son número de días hábiles del mes
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima ModIFicacion: Agosto-2006
--                      Creación de SPL
--SE modifico para que se tomen los dias feriados programados por banco no solamente por la banca.
--Modificado por: Alejandro Osuna IZa
--15 de sep de 2009
-- ***************************************************************************

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet          CHAR(5);
DEFINE dFechaActual        DATE;
DEFINE i,j              INTEGER;
DEFINE siFeriado        INTEGER;

	--SET DEBUG FILE TO "/tmp/pitdc/sp_sac_valfecha_banca.out";
	--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;

    --// ********************************************************************
    --// Calcula dia por dia si es habil, hasta completar el bloque

    LET i = 0;
    LET j = 0;	
    WHILE i <= pDiasBloque 
		LET dFechaActual = pPriDiaNaturalMes + j;
		LET siFeriado = 0;

		IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
	           SELECT COUNT(*) 
		     INTO siFeriado       
		    FROM bdinteg:si_feriado_banca
		    WHERE fecha = dFechaActual
		     AND pais = pCodPais and laborable = "N";
		   IF siFeriado IS NULL OR siFeriado = 0 THEN
		     LET i = i + 1;
		   END IF;
		END IF;
		LET j = j + 1;
    END WHILE

   RETURN '000',dFechaActual;
END
END PROCEDURE
                                                                          
;