CREATE PROCEDURE "informix".sp_consultacampaniajerarquia_max(cEmpresa CHAR(3),sIdCampania SMALLINT, sIdEjecucion SMALLINT)

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Se consulta el valor máximo de la campaña y jerarquía
--Realizó: Nancy Sevilla Camacho
--Fecha: 04/04/2012                    
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5)  AS codigo_retorno,
INTEGER  AS idCampania,
INTEGER  AS idJerarq;
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr     INTEGER;
DEFINE cCodRet     CHAR(5);	
DEFINE idCampania  INTEGER;
DEFINE idJerarq    INTEGER;

--INICIALIZACION DE VARIABLES--
LET iSqlErr     = 0;
LET cCodRet     = '00000';
LET idCampania  = 0;
LET idJerarq    = 0;
	
	--SET DEBUG FILE TO "/home/sysifx/Nancy/sp_consultacampaniajerarquia_max.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,idCampania,idJerarq;
			END IF;
		END EXCEPTION;	
		
	-- Se valida que los parámetros de entrada no vengan vacíos		
		IF NVL(cEmpresa,"") = "" THEN
			-- Parámetros de entrada vacíos
			LET cCodRet = "00001";	
			RETURN cCodRet,
			       idCampania,
				   idJerarq;
		END IF
				
		IF sIdEjecucion = 1 THEN    -- MAXIMA CAMPAÑA
				
			-- Se obtiene el valor max del idCampaña
			SELECT MAX(idcamp)
			  INTO idCampania
			  FROM bdinteg:"informix".si_maecamp
			  Where empresa='001' and idcamp>0;

			IF NVL(idCampania,0) = "" OR idCampania IS NULL THEN
			    LET idCampania = 0;
			END IF;

		ELIF sIdEjecucion = 2 THEN	 -- MAXIMA JERARQUIA

			-- Se obtiene el valor max del idJerarquia
			SELECT MAX(idjerarquia)
			  INTO idJerarq
			  FROM bdinteg:"informix".si_maecamp
			 WHERE empresa = cEmpresa
			   AND idcamp = sIdCampania;
		
			IF NVL(idJerarq,0) = "" OR idJerarq IS NULL THEN
				LET idJerarq = 0;
			END IF;
		
		END IF;		

		  RETURN cCodRet,
				 idCampania,
				 idJerarq;
					  
	END
END PROCEDURE;