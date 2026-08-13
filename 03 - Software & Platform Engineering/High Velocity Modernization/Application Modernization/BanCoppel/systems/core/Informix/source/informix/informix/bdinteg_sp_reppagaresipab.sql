CREATE PROCEDURE "informix".sp_reppagaresipab( pNumCliente CHAR(20), 
                                               pFechaIni   DATE, 
                                               pFechaFin   DATE, 
                                               pPorcRetSuj DECIMAL(9,6), 
                                               pAniobase   INTEGER,
                                               pIndicador  SMALLINT )
RETURNING CHAR(5);
    
    DEFINE cRegFiscal, cOperArit CHAR(1);
    DEFINE cTpoCuenta CHAR(2);    
    DEFINE cInstbase, cSobretasa CHAR(3);   
    DEFINE cNumProducto, cSucursal CHAR(4);
    DEFINE cCodRet, cCodRet2 CHAR(5); 
    DEFINE cFechaContratacion CHAR(8);
    DEFINE cNumCuenta, cCtaInversion CHAR(20);           
    DEFINE cDesErr, cCodRet3 CHAR(50);           
    DEFINE dtFechaCorte, dtFechaSigCorte, dtFechaContratacion DATE;               
    DEFINE iDivisa, iPlazo, iTipoTasa SMALLINT;           
    DEFINE iDias_Proy, iSqlErr, iSamErr, iDias_Ini, iSucursal INTEGER;
    DEFINE dTasa, dTasa2, dPorcentaje, dSdo_PromInv DECIMAL(9,6); 
    DEFINE mISR_Proy, mInt_Proy, mSdo_Inv_Proy, mInt_al_Inicio, mCapital, mSdo_Ini, mSdo_Prom_Ini, dImp_Isr_Ini, mSdo_Prom_Fin MONEY(18,2);
    
    LET cRegFiscal = 'N'; LET iTipoTasa = 1; LET cOperArit = NULL; 
    LET cTpoCuenta = 'CI'; 
    LET cInstbase = NULL; LET cSobretasa = NULL;
    LET cNumProducto = ""; LET cSucursal = "";
    LET cCodRet = "000"; LET cCodRet2 = ""; 
    LET cFechaContratacion = '';
    LET cNumCuenta = ""; LET cCtaInversion = "";
    LET cDesErr = ""; LET cCodRet3 = ""; 
    LET dtFechaCorte = NULL; LET dtFechaSigCorte = NULL; LET dtFechaContratacion = '';
    LET iDivisa = 1; LET iPlazo = ""; 
    LET iDias_Proy = 0; LET iSqlErr = 0; LET iSamErr = 0; LET iDias_Ini = 0; LET iSucursal = 0;
    LET dTasa = 0; LET dTasa2 = 0; LET dPorcentaje = NULL; LET dSdo_PromInv = NULL;
    LET mISR_Proy = 0; LET mInt_Proy = 0; LET mSdo_Inv_Proy = 0; LET mInt_al_Inicio = 0; LET mCapital = 0.00; LET mSdo_Ini = 0; LET mSdo_Prom_Ini = 0; LET dImp_Isr_Ini = 0; LET mSdo_Prom_Fin = 0;
                      
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/jivan/sp_reppagaresipab.err';
        TRACE ON;
        LET cCodRet = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/jivan/sp_reppagaresipab.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    LET pPorcRetSuj = pPorcRetSuj / 100;
    
    FOREACH
        SELECT cta_cheques, cuenta, capital, cod_instrum, sucursal, fecha_alta, tasa, plazo
          INTO cNumCuenta, cCtaInversion, mCapital, cNumProducto, cSucursal, dtFechaContratacion, dTasa, iPlazo
          FROM bdinvers:sv_maeinv 
         WHERE num_cte = pNumCliente
           AND fecha_alta <= pFechaIni 
           AND fecha_venc > pFechaIni
           AND ( fec_cancelac > pFechaIni or fec_cancelac is null )
        
        LET iSucursal = cSucursal;
        LET dTasa2 = dTasa / 100;
        LET cFechaContratacion = TO_CHAR(dtFechaContratacion,'%Y%m%d');
        
        -- // OBTIENE SALDO PROYECTADO A AL FECHA FINAL DE LA PROYECCION
        LET mSdo_Prom_Fin = mCapital;
        LET iDias_Proy = (pFechaFin - dtFechaContratacion) + 1;
        LET mInt_Proy = (mCapital * dTasa2 * iDias_Proy) / 360;
        
        IF pPorcRetSuj <> 0 THEN
            LET mISR_Proy = (((mCapital * pPorcRetSuj) * iDias_Proy) / pAniobase);
        ELSE
            LET mISR_Proy = 0;
        END IF;
        
        IF pFechaIni = pFechaFin THEN
            LET mSdo_Inv_Proy = mCapital + mInt_Proy;
        ELSE
            LET mSdo_Inv_Proy = ( mCapital + mInt_Proy ) - mISR_Proy;
        END IF;
        
        IF pIndicador = 0 THEN
            -- // INSERTA INFORMACION PATRIMONIAL DEL CLIENTE
            INSERT INTO si_infpattit VALUES
            ( cNumCuenta, cCtaInversion, cNumProducto, cTpoCuenta, cRegFiscal, dPorcentaje, iSucursal, mSdo_Ini, mInt_al_Inicio, dImp_Isr_Ini, 0.00, 
              mSdo_Inv_Proy, iDivisa, dtFechaCorte, cFechaContratacion, iPlazo, iTipoTasa, dTasa, cInstbase, cSobretasa, cOperArit, dtFechaSigCorte, 
              dSdo_PromInv, iDias_Ini, mSdo_Ini, mSdo_Prom_Ini, mInt_al_Inicio, dImp_Isr_Ini, iDias_Proy, mCapital, mSdo_Prom_Fin, mInt_Proy, mISR_Proy );
            
            -- // INSERTA CUENTAS ASOCIADAS DEL CLIENTE
            INSERT INTO si_ctaasotit VALUES 
            ( cNumCuenta, cCtaInversion, pNumCliente, 100.00 );
        ELSE
            -- // INSERTA INFORMACION PATRIMONIAL DEL CLIENTE
            INSERT INTO si_infpattit_comp VALUES
            ( cNumCuenta, cCtaInversion, cNumProducto, cTpoCuenta, cRegFiscal, dPorcentaje, iSucursal, mSdo_Ini, mInt_al_Inicio, dImp_Isr_Ini, 0.00, 
              mSdo_Inv_Proy, iDivisa, dtFechaCorte, cFechaContratacion, iPlazo, iTipoTasa, dTasa, cInstbase, cSobretasa, cOperArit, dtFechaSigCorte, 
              dSdo_PromInv, iDias_Ini, mSdo_Ini, mSdo_Prom_Ini, mInt_al_Inicio, dImp_Isr_Ini, iDias_Proy, mCapital, mSdo_Prom_Fin, mInt_Proy, mISR_Proy );
            
            -- // INSERTA CUENTAS ASOCIADAS DEL CLIENTE
            INSERT INTO si_ctaasotit_comp VALUES 
            ( cNumCuenta, cCtaInversion, pNumCliente, 100.00 );
        END IF;
    END FOREACH;
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;