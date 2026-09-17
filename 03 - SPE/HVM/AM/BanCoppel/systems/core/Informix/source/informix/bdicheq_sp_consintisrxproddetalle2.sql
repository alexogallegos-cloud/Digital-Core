CREATE PROCEDURE "informix".sp_consintisrxproddetalle2(pFecha DATE, pProducto CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER) 
RETURNING CHAR(5), DATE, CHAR(4), CHAR(40), CHAR(20), CHAR(20), DECIMAL(18,2), INTEGER, DECIMAL(9,6), 
          DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE dFecha       DATE;
    DEFINE cProducto    CHAR(4);
    DEFINE cNombre      CHAR(40);
    DEFINE cCuenta      CHAR(20);
    DEFINE cCliente     CHAR(20);
    DEFINE mSdoPromedio DECIMAL(18,2);
    DEFINE iDias        SMALLINT;
    DEFINE dTasa        DECIMAL(9,6);
    DEFINE mInteresCalc DECIMAL(18,2);
    DEFINE mInteresPag  DECIMAL(18,2);
    DEFINE mDifInteres  DECIMAL(18,2);
    DEFINE mIsrCalc     DECIMAL(18,2);
    DEFINE mIsrCobrado  DECIMAL(18,2);
    DEFINE mDifIsr      DECIMAL(18,2);
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
    LET dFecha       = '';
    LET cProducto    = '';
    LET cNombre      = '';
    LET cCuenta      = '';
    LET cCliente     = '';
    LET mSdoPromedio = 0.00;
    LET iDias        = 0;
    LET dTasa        = 0.000000;
    LET mInteresCalc = 0.00;
    LET mInteresPag  = 0.00;
    LET mDifInteres  = 0.00;
    LET mIsrCalc     = 0.00;
    LET mIsrCobrado  = 0.00;
    LET mDifIsr      = 0.00;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        --SET DEBUG FILE TO "/tmp/sp_consintisrxproddetalle2.err";
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, 
                   mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrCobrado, mDifIsr;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consintisrxproddetalle2.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pFecha is null OR pFecha = '' ) OR
       ( pProducto is null OR pProducto = '' ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, 
               mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrCobrado, mDifIsr;
    END IF;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_pagoints_cobroisr
     WHERE fecha = pFecha;
           
    IF iExiste = 0 THEN
        LET cCodRet1 = '100';
        RETURN cCodRet1, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, 
               mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrCobrado, mDifIsr;
    ELSE
        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion fecha, producto, nombre, cuenta, num_cte, sdo_promedio, dias, tasa, 
                   interes_calculado, interes_pagado, diferencia_interes, isr_calculado, isr_cobrado, diferencia_isr
              INTO dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa,
                   mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrCobrado, mDifIsr
              FROM bdicheq:sc_pagoints_cobroisr
             WHERE fecha = pFecha
               AND producto = pProducto
             
            RETURN cCodRet1, dFecha, cProducto, cNombre, cCuenta, cCliente, mSdoPromedio, iDias, dTasa, 
                   mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrCobrado, mDifIsr WITH RESUME;
            
            LET dFecha       = '';
            LET cProducto    = '';
            LET cNombre      = '';
            LET cCuenta      = '';
            LET cCliente     = '';
            LET mSdoPromedio = 0.00;
            LET iDias        = 0;
            LET dTasa        = 0.000000;
            LET mInteresCalc = 0.00;
            LET mInteresPag  = 0.00;
            LET mDifInteres  = 0.00;
            LET mIsrCalc     = 0.00;
            LET mIsrCobrado  = 0.00;
            LET mDifIsr      = 0.00;
        END FOREACH;
    END IF;
     
    END;
    
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: Conciliacion de Intereses Pagados en Cuentas de Captacion',
'DESCRIPCION: Realiza la consulta de los datos para el llenado del grid de la pantalla modal de la funcionalidad',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_consintisrxproddetalle2_totales(pFecha DATE, pProducto CHAR(4)) 
RETURNING CHAR(5), INTEGER;
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
    
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        --SET DEBUG FILE TO "/tmp/sp_consintisrxproddetalle2_totales.err";
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, iExiste;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consintisrxproddetalle2_totales.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pFecha is null OR pFecha = '' ) OR
       ( pProducto is null OR pProducto = '' ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, iExiste;
    END IF;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_pagoints_cobroisr
	  WHERE fecha = pFecha
	  AND producto = pProducto;
           
    IF iExiste = 0 THEN
        LET cCodRet1 = '100';
        RETURN cCodRet1, iExiste;
    ELSE
        RETURN cCodRet1, iExiste;
    END IF;
     
    END;
    
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: Conciliacion de Intereses Pagados en Cuentas de Captacion',
'DESCRIPCION: Realiza la consulta de los datos para el llenado del grid de la pantalla modal de la funcionalidad',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_finintisrxprodcedula( pFecha DATE ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_finintisrxprodcedula.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_finintisrxprodcedula.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pFecha is null OR pFecha = '' )  THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_intisrxprodcedula
     WHERE fecha = pFecha;
       
    IF iExiste > 0 THEN
        UPDATE bdicheq:sc_intisrxprodcedula
           SET editable = '1'
         WHERE fecha = pFecha;
           
        RETURN cCodRet1;
    ELSE
        LET cCodRet1 = '100';
        RETURN cCodRet1;
    END IF;
     
    END;
    
END PROCEDURE;