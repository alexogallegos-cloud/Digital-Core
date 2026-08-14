CREATE PROCEDURE "informix".sp_nominasaplicadas(pEmpresa CHAR(3), pFechaAplicacion CHAR(10))
--valores a regresar
RETURNING   DATE, DATE, INTEGER, CHAR(20), INTEGER, MONEY, MONEY, MONEY, CHAR(16), CHAR(16), MONEY, MONEY;

--definición de variables
DEFINE v_dFechaGenera   DATE;
DEFINE v_dFechaAplica       DATE;
DEFINE v_iFolioArchivo       INTEGER;
DEFINE v_cCuentaCargo   CHAR(20);
DEFINE v_iTotRegistros      INTEGER;
DEFINE v_mImporteTot        MONEY;
DEFINE v_mImporteAplicado   MONEY;
DEFINE v_mImporteNoAplicado MONEY;
DEFINE v_cFolioAcuseRecibo  CHAR(16);
DEFINE v_cFolioDispersion       CHAR(16);
DEFINE v_mIva                               MONEY;
DEFINE v_mComision                  MONEY;
DEFINE v_isql_err             INTEGER;

--inicializacion de variables
LET  v_dFechaGenera  = "";
LET   v_dFechaAplica   = "";
LET   v_iFolioArchivo  = 0;
LET  v_cCuentaCargo = "";
LET  v_iTotRegistros = 0;
LET  v_mImporteTot  = 0.00;
LET  v_mImporteAplicado  = 0.00;
LET v_mImporteNoAplicado = 0.00;
LET v_cFolioAcuseRecibo = "";
LET v_cFolioDispersion = "";
LET  v_mIva  = 0.00;
LET v_mComision = 0.00;
LET v_isql_err  = 0;


BEGIN
    ON EXCEPTION SET v_isql_err 
    IF v_isql_err  <> 0 THEN
        LET   v_iFolioArchivo  =  v_isql_err ;
        RETURN   v_dFechaGenera, v_dFechaAplica, v_iFolioArchivo, v_cCuentaCargo, v_iTotRegistros, 
                         v_mImporteTot, v_mImporteAplicado, v_mImporteNoAplicado, v_cFolioAcuseRecibo, v_cFolioDispersion,  v_mIva,  v_mComision;
    END IF;
    END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_nominasaplicadas.out";
--TRACE ON;

    IF pFechaAplicacion = ""  OR pEmpresa = "" THEN
        LET  v_iFolioArchivo = "999"; --Parametro de Entrada Invalido
     RETURN   v_dFechaGenera, v_dFechaAplica, v_iFolioArchivo, v_cCuentaCargo, v_iTotRegistros, 
                         v_mImporteTot, v_mImporteAplicado, v_mImporteNoAplicado, v_cFolioAcuseRecibo, v_cFolioDispersion,  v_mIva,  v_mComision;
    END IF;

   
    FOREACH

            SELECT fecha_gen, fecha_aplicacion, folio_archivo, cuenta_cargo, total_registros, nvl(importe_tot, 0.00), nvl(importe_aplicado, 0.00),
                            nvl(importe_no_aplicado, 0.00), nvl(folio_acuserecibo, '0'), nvl(folio_dispersion, '0'), nvl(iva, 0.00), nvl(comision, 0.00)   
             INTO   v_dFechaGenera, v_dFechaAplica,   v_iFolioArchivo,  v_cCuentaCargo,  v_iTotRegistros,  v_mImporteTot,
                         v_mImporteAplicado,  v_mImporteNoAplicado,  v_cFolioAcuseRecibo,  v_cFolioDispersion,  v_mIva,  v_mComision 
            FROM     bdicheq:sc_nominaencabezadosumario 
            WHERE empresa =  pEmpresa  AND fecha_aplicacion = pFechaAplicacion
            
           RETURN   v_dFechaGenera, v_dFechaAplica, v_iFolioArchivo, v_cCuentaCargo, v_iTotRegistros, 
                         v_mImporteTot, v_mImporteAplicado, v_mImporteNoAplicado, v_cFolioAcuseRecibo, v_cFolioDispersion,  v_mIva,  v_mComision;

    END FOREACH
END
END PROCEDURE;