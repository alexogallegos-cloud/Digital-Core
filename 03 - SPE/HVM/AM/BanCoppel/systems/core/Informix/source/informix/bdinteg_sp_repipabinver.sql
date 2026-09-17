CREATE PROCEDURE "informix".sp_repipabinver(pFechaIni DATE, pFechaFin DATE, pNumCliente CHAR(20), pPersona CHAR(2))
RETURNING CHAR(5);

    DEFINE cPfisica, cExento_isr, cRegFiscal, cTipoTasa, cOperArit, cSujRet CHAR(1);
    DEFINE cTpoCuenta, cDivisa CHAR(2);    
    DEFINE cPorcentaje, cInstbase, cSobretasa CHAR(3);   
    DEFINE cNumProducto, cSucursal CHAR(4);
    DEFINE dSdo_PromInv, cPlazo, P_COD_RET, P_COD_RET2 CHAR(5); 
    DEFINE cNumCuenta, cCtaInversion CHAR(20);           
    DEFINE cNomProducto, DESC_ERR, P_COD_RET3 CHAR(40);           
    DEFINE dFechaCorte, dFechaSigCorte, dFechaContratacion DATE;               
    DEFINE sAnio, sCauRev, vexcluido SMALLINT;           
    DEFINE iDias_Proy, iAniobase, SQL_ERR, ISAM_ERR, iDias_Ini INTEGER;
    DEFINE sResiduo DECIMAL(9,3);
    DEFINE dtasa, dPorRetencionSuj, dtasax2 DECIMAL(9,6); 
    DEFINE mISR_Proy, mInt_Proy, mSdo_Inv_Proy, mInt_al_Inicio, mCapital, mSdo_Ini, mSdo_Prom_Ini, dImp_Isr_Ini, mSdo_Prom_Fin MONEY(18,2);

    LET cPfisica           = "";            LET cExento_isr        = "";            LET cRegFiscal         = "N";
    LET cTipoTasa          = "1";           LET cOperArit          = NULL;          LET cSujRet            = "S";
    LET cTpoCuenta         = "CI";          LET cDivisa            = "";            LET cPorcentaje        = NULL;
    LET cInstbase          = NULL;          LET cSobretasa         = NULL;          LET cNumProducto       = "";            
    LET cSucursal          = "";            LET dSdo_PromInv       = NULL;          LET cPlazo             = "";            
    LET P_COD_RET          = "00000";       LET P_COD_RET2         = "00000";       LET cNumCuenta         = "";            
    LET cCtaInversion      = "";            LET cNomProducto       = "";            LET DESC_ERR           = "";            
    LET P_COD_RET3         = "";            LET dFechaCorte        = NULL;          LET dFechaSigCorte     = NULL;          
    LET dFechaContratacion = "01-01-1900";  LET sAnio              = 0;             LET sCauRev            = 0;             
    LET vexcluido          = 0;             LET iDias_Proy         = 0;             LET iAniobase          = 0;             
    LET SQL_ERR            = 0;             LET ISAM_ERR           = 0;             LET iDias_Ini 		   = 0;             
    LET sResiduo           = 0;             LET dtasa              = 0;             LET dPorRetencionSuj   = 0;      
    LET dtasax2            = 0;             LET mISR_Proy          = 0;             LET mInt_Proy          = 0;             
    LET mSdo_Inv_Proy      = 0;             LET mInt_al_Inicio 	   = 0;             LET mCapital           = 0.00;          
    LET mSdo_Ini 		   = 0;             LET mSdo_Prom_Ini 	   = 0;             LET dImp_Isr_Ini 	   = 0;             
    LET mSdo_Prom_Fin 	   = 0;
                      
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_repipabinver.out';
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, DESC_ERR
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_repipabinver.err';
        TRACE ON;
        LET P_COD_RET = SQL_ERR;
        LET P_COD_RET2 = ISAM_ERR;
        LET P_COD_RET3 = DESC_ERR;
        RETURN P_COD_RET;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;

    SELECT valor
      INTO dPorRetencionSuj
      FROM bdinteg:si_fechavalor
     WHERE tasa = "I.S.R." 
       AND fecha = (SELECT max(fecha)
                      FROM bdinteg:si_fechavalor
                     WHERE tasa = "I.S.R.");

    LET sAnio = year(pFechaFin);
    LET sResiduo = mod(sAnio, 4);

    IF sResiduo = 0 THEN
        LET iAniobase = 366;
    ELSE
        LET iAniobase = 365;
    END IF;

    LET dPorRetencionSuj = dPorRetencionSuj / 100;

    FOREACH
        SELECT nvl(cta_cheques, ''), nvl(cuenta, ''), nvl(capital , 0), nvl(cod_instrum, ''), 
               nvl(sucursal, ''), nvl(fecha_alta, '05/01/2007'), nvl(tasa, 0), nvl(plazo, 0)
          INTO cNumCuenta, cCtaInversion, mCapital, cNumProducto, cSucursal, dFechaContratacion, dtasa, cPlazo
          FROM bdinvers:sv_maeinv 
         WHERE num_cte = pNumCliente
           AND fecha_alta <= pFechaIni 
           AND fecha_venc > pFechaIni
           AND ( fec_cancelac > pFechaIni or fec_cancelac is null )
        
        SELECT es_fisica, exento_isr
          INTO cPfisica, cExento_isr
          FROM bdinteg:si_tipper
         WHERE tpo_persona = pPersona;

        IF cExento_isr = 'N' THEN
            LET cSujRet = 'S';
        ELSE
            LET cSujRet = 'N';
        END IF;

        IF cSujRet <> 'S' THEN                
            LET dPorRetencionSuj = 0;
        END IF;   

        SELECT COUNT(*)
          INTO vexcluido
          FROM bdinteg:si_excluidosipab 
         WHERE numcte = pNumCliente;

        IF vexcluido > 0 THEN
            LET sCauRev = 1;
        ELSE
            LET sCauRev = 0;
        END IF;
        
        LET dtasax2 = dtasa / 100;

        -- // OBTIENE EL NOMBRE DEL PRODUCTO Y LA MONEDA
        SELECT nombre, substring (nvl(moneda, ' ') from 2 for 1)
          INTO cNomProducto, cDivisa
          FROM bdinvers:sv_instrum
         WHERE cod_instrum  = cNumProducto;
        
        -- // OBTIENE SALDO PROYECTADO A AL FECHA FINAL DE LA PROYECCION
        LET mSdo_Prom_Fin = mCapital;
        LET iDias_Proy = (pFechaFin - dFechaContratacion) + 1;
        LET mInt_Proy = (mCapital * dtasax2 * iDias_Proy) / 360;
        
        IF dPorRetencionSuj <> 0 THEN
            LET mISR_Proy = (((mCapital * dPorRetencionSuj) * iDias_Proy) / iAniobase);
        ELSE
            LET mISR_Proy = 0;
        END IF;
        
        IF pFechaIni = pFechaFin THEN
            LET mSdo_Inv_Proy = mCapital + mInt_Proy;
        ELSE
            LET mSdo_Inv_Proy = ( mCapital + mInt_Proy ) - mISR_Proy;
        END IF;

        -- // INSERTA INFORMACION PATRIMONIAL DEL CLIENTE
        INSERT INTO si_infpattit_tmp VALUES
        ( UPPER(cNumCuenta), UPPER(cCtaInversion),  UPPER(cTpoCuenta), UPPER(cRegFiscal), cPorcentaje, 0, UPPER(cNomProducto), UPPER(cSucursal), 
          NVL(mSdo_Inv_Proy,0), UPPER(cDivisa), dFechaCorte, dFechaContratacion, cPlazo, cTipoTasa, NVL(dtasa,0), cInstbase, cSobretasa, cOperArit, dFechaSigCorte, 
          dSdo_PromInv, iDias_Ini, mSdo_Ini, mSdo_Prom_Ini, mInt_al_Inicio, dImp_Isr_Ini, iDias_Proy, mCapital, mSdo_Prom_Fin, mInt_Proy, mISR_Proy );

        -- // INSERTA CUENTAS ASOCIADAS DEL CLIENTE
        INSERT INTO si_ctaasotit_tmp VALUES
        ( UPPER(cNumCuenta), UPPER(cCtaInversion), UPPER(pNumCliente), 100.00 );
    END FOREACH;

    RETURN P_COD_RET;

    END;

END PROCEDURE;