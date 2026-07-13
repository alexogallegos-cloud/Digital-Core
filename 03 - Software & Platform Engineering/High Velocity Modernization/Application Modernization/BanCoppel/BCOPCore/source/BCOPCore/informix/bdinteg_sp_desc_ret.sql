CREATE PROCEDURE "informix".sp_desc_ret(sCveSistema CHAR(2),sCodret CHAR(4))
RETURNING VARCHAR(3)  , 
          VARCHAR(50) ;
         
-- *********************************************************************************************** 
-- spObtParam
-- Version              1.0.0
-- Objetivo:            Devuelve la descripcion del 
--                      codigo de retorno de la tabla si_codret de bdinteg
-- Valores de Entrada:  sCveSistema     --> Clave del Sistema
--                                      --> CodigoRetorno
-- Valores de Regreso:  
--                      VARCHAR(3)      --> CodigoRetorno     
--                      VARCHAR(50)     --> DescripcionError  
-- Creado por:          Alejandro Rueda Sanchez
-- Modificado por:      
-- Ultima Modificacion: Agosto-2006
--                      Creación de SPL
-- ************************************************************************************************* 
          
BEGIN

    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cVarDataErr  CHAR(50);
    DEFINE cCodRet      CHAR(5);
    
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
        END IF;
        RETURN cCodRet, cVarDataErr;
    END EXCEPTION;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    

    --// ********************************************************************
    --// Obtenemos el sistema para los mensajes de error
    --// ********************************************************************
    SELECT codigo_retorno, descripcion
    INTO cCodret,cVarDataErr
    FROM si_codret 
    WHERE codigo_retorno = sCodret
    AND sistema = sCveSistema;

    IF cVarDataErr IS NULL OR cVarDataErR = "" THEN
      LET cCodret = '001';
      LET cVarDataErr = 'No existe la descripcion del codigo retorno ' || sCodret;
    END IF

    RETURN cCodret,cVarDataErr;
END;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

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