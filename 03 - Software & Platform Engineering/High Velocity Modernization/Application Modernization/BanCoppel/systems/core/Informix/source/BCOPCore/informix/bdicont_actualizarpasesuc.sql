CREATE PROCEDURE "informix".actualizarpasesuc(
       pEmpresa       CHAR(3),
       pFechaValor    DATE,
       pSucursal      CHAR(4),
       pFechaCaptura  DATE)
RETURNING
    VARCHAR(5)         -- CodigoRetorno

-- ***********************************************************************************************
-- Objetivo:            Actualizar el status y la fecha en que la sucursal captura el reenvio de su poliza
-- Valores de Entrada:  pEmpresa          Clave de la Empresa
--                      pFechaValor       Fecha Valor de la poliza a reenviar
--                      pSucursal         Sucursal que reenvia la poliza
--                      pFechaCaptura     Fecha en la sucursal reenvia la poliza
-- Valores de Regreso:  Codigo            000 --> Proceso exitoso
-- Creado por:          Julio Cesar Polanco
-- Fecha:               16/04/2009
-- *************************************************************************************************

DEFINE cVarDataErr          VARCHAR(255);
DEFINE iSqlErr              INTEGER;
DEFINE iSamErr              INTEGER;

DEFINE cCodRet              CHAR(5);

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    LET cCodRet = '000';

    --// ********************************************************************
    --// Valida parámetros de entrada, todos son obligatorios
    --// ********************************************************************
    IF pFechaValor IS NULL OR pEmpresa IS NULL OR pEmpresa = '' OR
       pSucursal IS NULL OR pSucursal = '' OR pFechaCaptura IS NULL THEN
        LET cCodRet = '003'; --Parametros nulos
        RETURN cCodRet;
    END IF

    UPDATE bdicont:co_clv_pasesuc
    SET fecha_captura = pFechaCaptura, estatus_uso = 'S'
    WHERE empresa = pEmpresa AND fecha_valida = pFechaValor
    AND sucursal = pSucursal AND estatus_uso = 'N';

    RETURN cCodRet;
END
END PROCEDURE;