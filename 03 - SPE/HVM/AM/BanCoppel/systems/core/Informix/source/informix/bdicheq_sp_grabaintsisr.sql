CREATE PROCEDURE "informix".sp_grabaintsisr( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE iContador        INTEGER;
    DEFINE dSMDF            DECIMAL(14,2);
    DEFINE iNumSMDF         SMALLINT;
    DEFINE iAnio            INTEGER;
    DEFINE iResiduo         INTEGER;
    DEFINE iAnioBase        INTEGER;
    DEFINE dTasaISR         DECIMAL(9,6);
    DEFINE cCuenta          CHAR(20);
    DEFINE cProducto        CHAR(4);
    DEFINE cNombreProd      CHAR(40);
    DEFINE cNumCte          CHAR(20);
    DEFINE cFisica          CHAR(1);
    DEFINE mSdoAcum         DECIMAL(18,2);
    DEFINE iDias            SMALLINT;
    DEFINE dTasa            DECIMAL(9,6);
    DEFINE mIntsPagados     DECIMAL(18,2);
    DEFINE mIsrCobrado      DECIMAL(18,2);
    DEFINE mSdoPromedio     DECIMAL(18,2);
    DEFINE mIntsCalculados  DECIMAL(18,2);
    DEFINE mDifIntereses    DECIMAL(18,2);
    DEFINE mBaseExenta      DECIMAL(18,2);
    DEFINE mBaseGravable    DECIMAL(18,2);
    DEFINE mISRCalculado    DECIMAL(14,2);
    DEFINE mDiferenciaISR   DECIMAL(14,2);
    
    LET cCodRet1        = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET iSqlErr	        = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET iTransacc       = 0;
    LET iContador       = 0;
    LET dSMDF           = 0.00;
    LET iNumSMDF        = 0;
    LET iAnio           = 0;
    LET iResiduo        = 0;
    LET iAnioBase       = 0;
    LET dTasaISR        = 0.000000;
    LET cCuenta         = '';
    LET cProducto       = '';
    LET cNombreProd     = '';
    LET cNumCte         = '';
    LET cFisica         = '';
    LET mSdoAcum        = 0.00;
    LET iDias           = 0;
    LET dTasa           = 0.000000;
    LET mIntsPagados    = 0.00;
    LET mIsrCobrado     = 0.00;
    LET mSdoPromedio    = 0.00;
    LET mIntsCalculados = 0.00;
    LET mDifIntereses   = 0.00;
    LET mBaseExenta     = 0.00;
    LET mBaseGravable   = 0.00;
    LET mISRCalculado   = 0.00;
    LET mDiferenciaISR  = 0.00;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_grabaintsisr.err";
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
    
    --- SET DEBUG FILE TO "/tmp/sp_grabaintsisr.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pEmpresa is null OR pEmpresa = '' ) OR
         ( pFecha is null OR pFecha = '' ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    SELECT valor 
      INTO dSMDF
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = "smdf";
    
    SELECT valor 
      INTO iNumSMDF
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = "numsmdf";
       
    LET iAnio = YEAR(pFecha);
    LET iResiduo = MOD(iAnio,4);
    
    IF iResiduo <> 0 THEN
        LET iAnioBase = 365;
    ELSE
        LET iAnioBase = 366;
    END IF;
    
    SELECT valor / 100
      INTO dTasaISR
      FROM bdinteg:si_fechavalor
     WHERE empresa = pEmpresa 
       AND tasa = "I.S.R." 
       AND fecha IN( SELECT MAX(fecha) 
                       FROM bdinteg:si_fechavalor
                      WHERE empresa = pEmpresa 
                        AND tasa = "I.S.R.");
    
    FOREACH WITH HOLD
        SELECT 
		--{+INDEX(sc_maehis idx_maehis2)}
               cuenta, producto, num_cte, acum_sdo_pos, dia_sdo_pos, tasabruta, totintpag, totisrcobrado
          INTO cCuenta, cProducto, cNumCte, mSdoAcum, iDias, dTasa, mIntsPagados, mIsrCobrado
          FROM bdicheq:sc_maehis
         WHERE fechafin = pFecha
		 	  
        -- WHERE empresa = pEmpresa
        --   AND aniomes = aniomes
        --   AND cuenta >= '10000005016'
        --   AND fechaini >= pFecha - 2 UNITS MONTH
        --   AND fechafin = pFecha
        
        SELECT nombre
          INTO cNombreProd
          FROM bdicheq:sc_producto
         WHERE producto = cProducto;
           
        SELECT per.es_fisica
          INTO cFisica
          FROM bdinteg:si_cliente cte,
               bdinteg:si_tipper per
         WHERE cte.numcte = cNumCte
           AND per.tpo_persona = cte.tpo_persona;
        
        IF iTransacc = 0 THEN       
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
               
        LET mSdoPromedio = mSdoAcum / iDias;
        
        LET mIntsCalculados = ROUND((((mSdoPromedio * dTasa) * iDias) / 360),2);
        
        LET mDifIntereses = mIntsPagados - mIntsCalculados;
        
        LET mBaseExenta = ((dSMDF * iAnioBase) * iNumSMDF);
        
        IF mBaseExenta is null THEN
            LET mBaseExenta = 0.00;
        END IF;
        
        LET mBaseGravable = mSdoPromedio - mBaseExenta;
        
        IF cFisica = 'S' THEN
            IF mBaseGravable > 0 THEN
                LET mISRCalculado = (((mBaseGravable * dTasaISR) / iAnioBase) * iDias);
            ELSE
                LET mISRCalculado = 0;
            END IF;
        ELSE
            LET mISRCalculado = (((mSdoPromedio * dTasaISR) / iAnioBase) * iDias);
        END IF;
        
        LET mDiferenciaISR = mIsrCobrado - mISRCalculado;
        
        INSERT INTO sc_pagoints_cobroisr
        ( fecha, producto, nombre, cuenta, num_cte, sdo_promedio, dias, tasa, 
          interes_calculado, interes_pagado, diferencia_interes, 
          isr_calculado, isr_cobrado, diferencia_isr )
        VALUES
        ( pFecha, cProducto, cNombreProd, cCuenta, cNumCte, mSdoPromedio, iDias, dTasa, 
          mIntsCalculados, mIntsPagados, mDifIntereses, mISRCalculado, mIsrCobrado, mDiferenciaISR );
          
        LET iContador = iContador + 1;
        
        IF iContador >= 1000 THEN
            LET iContador = 0;
            LET iTransacc = 0;
            COMMIT WORK;
        END IF;
        
        LET cCuenta = '';
        LET cProducto = '';
        LET cNombreProd = '';
        LET cNumCte = '';
        LET cFisica = '';
        LET mSdoAcum = 0.00;
        LET iDias = 0;
        LET dTasa = 0.000000;
        LET mIntsPagados = 0.00;
        LET mIsrCobrado = 0.00;
        LET mSdoPromedio = 0.00;
        LET mIntsCalculados = 0.00;
        LET mDifIntereses = 0.00;
        LET mBaseExenta = 0.00;
        LET mBaseGravable = 0.00;
        LET mISRCalculado = 0.00;
        LET mDiferenciaISR = 0.00;
    ENd FOREACH;
    
    IF iTransacc = 1 THEN        
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN cCodRet1;
    
END PROCEDURE;