CREATE PROCEDURE "informix".grabarpasesuc(
       pEmpresa       CHAR(3),
       pFechaValor    DATE,
       pSucursal      CHAR(4),
       pFechaAutoriza DATE,
       pUsuario       CHAR(8))
RETURNING
    VARCHAR(5)         -- CodigoRetorno

-- ***********************************************************************************************
-- Objetivo:            Grabar la poliza que reenviara la sucursal en la tabla co_clv_pasesuc,
--                      con esto se autoriza su reenvio
-- Valores de Entrada:  pEmpresa          Clave de la Empresa
--                      pFechaValor       Fecha Valor de la poliza a reenviar
--                      pSucursal         Sucursal que reenviara la poliza
--                      pFechaAutoriza    Fecha en que Contabilidad autoriza el reenvio de la poliza de sucursal
-- Valores de Regreso:  Codigo            000 --> Proceso exitoso
--                                        001 --> Registro a insertar ya existente
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
       pSucursal IS NULL OR pSucursal = '' OR pFechaAutoriza IS NULL OR
       pUsuario IS NULL OR pUsuario = '' THEN
        LET cCodRet = '003'; --Parametros nulos
        RETURN cCodRet;
    END IF

    IF EXISTS ( SELECT sucursal FROM bdicont:co_clv_pasesuc
                WHERE empresa = pEmpresa AND sucursal = pSucursal
                AND fecha_valida = pFechaValor AND fecha_autoriza = pFechaAutoriza ) THEN
        LET cCodRet = '001';
    ELSE
        INSERT INTO bdicont:co_clv_pasesuc
        (empresa, sucursal, fecha_valida, fecha_autoriza, fecha_captura, usuario_autoriza, estatus_uso)
        VALUES
        (pEmpresa, pSucursal, pFechaValor, pFechaAutoriza, '', pUsuario, 'N' );
    END IF

    RETURN cCodRet;
END
END PROCEDURE;