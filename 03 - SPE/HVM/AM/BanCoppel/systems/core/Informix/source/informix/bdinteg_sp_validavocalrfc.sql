CREATE PROCEDURE "informix".sp_validavocalrfc(pEmpresa CHAR(3),pCaracter CHAR(1))
RETURNING CHAR(6),VARCHAR(100);

--Variables de proceso
DEFINE cMensaje   VARCHAR(100);

-- Control de errores
DEFINE vsqlerr  INTEGER;
DEFINE visamerr INTEGER;
DEFINE cCodret  CHAR(6);


--Variables de proceso
LET cMensaje      = "El caracter corresponde a una vocal";

--Control de errores
LET vsqlerr     = 0;
LET visamerr    = 0;
LET cCodret     = "000000";


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET cCodret=vsqlerr;
      RETURN cCodret,cMensaje;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/viridiana/sp_validavocalrfc";
--TRACE ON;

IF NVL(pEmpresa,"") = "" OR NVL(pCaracter,"") = "" THEN
    LET cCodret  = "000001";
    LET cMensaje = "Los datos no se proporcionaron correctamente.";
    RETURN cCodret,cMensaje;
END IF;

IF UPPER(pCaracter) NOT IN ("A","E","I","O","U") THEN
   LET cCodret = '000002';
   LET cMensaje = "El caracter no es una vocal";
END IF;

RETURN cCodret,cMensaje;
END
END PROCEDURE
DOCUMENT
"Descripción: Procedimiento que recibe un caracter y valida si es una vocal.",
"BD: bdinteg",
"Fecha: 06-Abril-2010",
"Autor: Viridiana Osobampo Aguilar";

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