CREATE PROCEDURE "informix".sp_generacedulaintsisr( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE dFecha           DATE;
    DEFINE cProducto        CHAR(4);
    DEFINE cNombreProd      CHAR(40);
    DEFINE mIntsCalculados  DECIMAL(18,2);
    DEFINE mIntsPagados     DECIMAL(18,2);
    DEFINE mDifIntereses    DECIMAL(18,2);
    DEFINE mISRCalculado    DECIMAL(14,2);
    DEFINE mIsrCobrado      DECIMAL(18,2);
    DEFINE mDiferenciaISR   DECIMAL(14,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    
    LET cCodRet1        = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET iSqlErr	        = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET iTransacc       = 0;
    LET dFecha          = '';
    LET cProducto       = '';
    LET cNombreProd     = '';
    LET mIntsCalculados = 0.00;
    LET mIntsPagados    = 0.00;
    LET mDifIntereses   = 0.00;
    LET mISRCalculado   = 0.00;
    LET mIsrCobrado     = 0.00;
    LET mDiferenciaISR  = 0.00;
    LET cObservaciones  = '';
    LET cEditable       = '0';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_generacedulaintsisr.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    on exception in (-535)
        let iTransacc = 1;
    end exception with resume;
	
	IF iTransacc = 1 THEN
       COMMIT WORK;
	   LET iTransacc = 0;
    END IF;
	
	--- SET DEBUG FILE TO "/tmp/sp_generacedulaintsisr.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pEmpresa is null OR pEmpresa = '' ) OR
         ( pFecha is null OR pFecha = '' ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    FOREACH WITH HOLD
        SELECT fecha, producto, nombre, 
               SUM(interes_calculado), SUM(interes_pagado), SUM(diferencia_interes), 
               SUM(isr_calculado), SUM(isr_cobrado), SUM(diferencia_isr)
          INTO dFecha, cProducto, cNombreProd, 
               mIntsCalculados, mIntsPagados, mDifIntereses, 
               mISRCalculado, mIsrCobrado, mDiferenciaISR
          FROM bdicheq:sc_pagoints_cobroisr
         WHERE fecha = pFecha
         GROUP BY 1, 2, 3
         ORDER BY 1, 2
            
        BEGIN WORK;
        LET iTransacc = 1;
               
        INSERT INTO bdicheq:sc_intisrxprodcedula
        ( fecha, producto, nombre, interes_calculado, interes_pagado, diferencia_interes, isr_calculado, isr_cobrado, diferencia_isr, observaciones, editable )
        VALUES
        ( dFecha, cProducto, cNombreProd, mIntsCalculados, mIntsPagados, mDifIntereses, mISRCalculado, mIsrCobrado, mDiferenciaISR, cObservaciones, cEditable );
        
        COMMIT WORK;
        LET iTransacc = 0;
        
        LET dFecha = '';
        LET cProducto = '';
        LET cNombreProd = '';
        LET mIntsCalculados = 0.00;
        LET mIntsPagados = 0.00;
        LET mDifIntereses = 0.00;
        LET mISRCalculado = 0.00;
        LET mIsrCobrado = 0.00;
        LET mDiferenciaISR = 0.00;
    ENd FOREACH;
    
    END;
    
    RETURN cCodRet1;
    
END PROCEDURE;