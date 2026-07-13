CREATE PROCEDURE "informix".sp_verifica_retiro_efectivo( pSucursal CHAR(4), pCuenta CHAR(20), pMonto DECIMAL(14,2), pFechaHoy DATE, pFechaIni DATE )
RETURNING CHAR(3), DATE, DECIMAL(14,2);
	
	DEFINE vsqlerr   	INTEGER;
    DEFINE visamerr   	INTEGER;
    DEFINE vdescerr   	CHAR(50);
    DEFINE vcodret   	CHAR(5);
    DEFINE vcodret2  	CHAR(5);
    DEFINE vcodret3     CHAR(50);
    
    DEFINE cTpoLimite   CHAR(1);
    DEFINE mMtoLimite   DECIMAL(14,2);
    DEFINE iPlazo       SMALLINT;
    DEFINE mMontoAcum   DECIMAL(16,2);
    DEFINE dtFecha      DATE;
    DEFINE cDia         CHAR(2);
    DEFINE cAnioMes     CHAR(6);
    DEFINE mSdoCuenta   DECIMAL(14,2);
    DEFINE iExisteSuc   SMALLINT;
    DEFINE iPeriodicidad SMALLINT;
	
	LET vsqlerr    = 0; 
    LET visamerr   = 0; 
    LET vdescerr   = 0; 
    LET vcodret    = '000'; 
    LET vcodret2   = ''; 
    LET vcodret3   = ''; 
    
    LET cTpoLimite = '';
    LET mMtoLimite = 0.00;
    LET iPlazo     = 0;
    LET mMontoAcum = 0.00;
    LET dtFecha    = '';
    LET cDia       = '';  
    LET cAnioMes   = '';  
    LET mSdoCuenta = 0.00;
    LET iExisteSuc = 0;
    LET iPeriodicidad = 0;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifica_retiro_efectivo.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            RETURN vcodret, dtFecha, mSdoCuenta;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifica_retiro_efectivo.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor 
      INTO cTpoLimite
      FROM sc_param
     WHERE codparam = 'LimSuc/Gen';
    
    IF cTpoLimite = 'S' THEN
        SELECT COUNT(*)
          INTO iExisteSuc
          FROM sc_limiteretiro
         WHERE sucursal = pSucursal;  
         
        IF iExisteSuc > 0 THEN
            SELECT monto, plazo, periodicidad   
              INTO mMtoLimite, iPlazo, iPeriodicidad
              FROM sc_limiteretiro                         
             WHERE sucursal = pSucursal;  
             
            IF pMonto <= mMtoLimite THEN
                SELECT {+INDEX(sc_retirosefectivo idx_retirosefectivo_ctafectrasuc)}
                       NVL(SUM(monto), 0.00) 
                  INTO mMontoAcum
                  FROM sc_retirosefectivo
                 WHERE cuenta = pCuenta
                   AND fecha = pFechaHoy
                   AND transacc = '0223'
                   AND sucursal = pSucursal;
                
                LET mMontoAcum = mMontoAcum + pMonto;
                
                IF mMontoAcum > mMtoLimite THEN 
                    LET vcodret = '777';
                    LET dtFecha = (pFechaHoy - iPlazo);
                    RETURN vcodret, dtFecha, mSdoCuenta;
                ELSE
                    LET vcodret = '000';
                    LET dtFecha = pFechaHoy;
                    RETURN vcodret, dtFecha, mSdoCuenta;
                END IF;
            END IF;
            
            IF pMonto > mMtoLimite OR iPeriodicidad = 1 THEN
                LET dtFecha = (pFechaHoy - iPlazo);
                
                LET cDia = LPAD(DAY(dtFecha),2,'0'); 
                LET cAnioMes = YEAR(dtFecha)||LPAD(MONTH(dtFecha),2,'0'); 
                
                SELECT DECODE( cDia, '01', capvig1,  '02', capvig2,  '03', capvig3,  '04', capvig4,  '05', capvig5,  
                                     '06', capvig6,  '07', capvig7,  '08', capvig8,  '09', capvig9,  '10', capvig10, 
                                     '11', capvig11, '12', capvig12, '13', capvig13, '14', capvig14, '15', capvig15, 
                                     '16', capvig16, '17', capvig17, '18', capvig18, '19', capvig19, '20', capvig20, 
                                     '21', capvig21, '22', capvig22, '23', capvig23, '24', capvig24, '25', capvig25, 
                                     '26', capvig26, '27', capvig27, '28', capvig28, '29', capvig29, '30', capvig30, 
                                     '31', capvig31, 0.00 )
                  INTO mSdoCuenta
                  FROM sc_sdodiarioc
                 WHERE cuenta = pCuenta
                   AND aniomes = cAnioMes;
                
                IF pMonto > mSdoCuenta THEN
                    LET vcodret = '777';
                    LET dtFecha = (pFechaHoy - iPlazo);
                    RETURN vcodret, dtFecha, mSdoCuenta;
                ELSE
                    LET vcodret = '000';
                    LET dtFecha = pFechaHoy;
                    RETURN vcodret, dtFecha, mSdoCuenta;
                END IF;
            END IF;
        ELSE
            SELECT monto, plazo, periodicidad   
              INTO mMtoLimite, iPlazo, iPeriodicidad
              FROM sc_limiteretiro                         
             WHERE sucursal = '9999';  
             
            IF pMonto <= mMtoLimite THEN
                SELECT {+INDEX(sc_retirosefectivo idx_retirosefectivo_ctafectrasuc)}
                       NVL(SUM(monto), 0.00) 
                  INTO mMontoAcum
                  FROM sc_retirosefectivo
                 WHERE cuenta = pCuenta
                   AND fecha = pFechaHoy
                   AND transacc = '0223';
                   --AND sucursal = pSucursal;
                
                LET mMontoAcum = mMontoAcum + pMonto;
                
                IF mMontoAcum > mMtoLimite THEN 
                    LET vcodret = '777';
                    LET dtFecha = (pFechaHoy - iPlazo);
                    RETURN vcodret, dtFecha, mSdoCuenta;
                ELSE
                    LET vcodret = '000';
                    LET dtFecha = pFechaHoy;
                    RETURN vcodret, dtFecha, mSdoCuenta;
                END IF;
            END IF;
            
            IF pMonto > mMtoLimite OR iPeriodicidad = 1 THEN
                LET dtFecha = (pFechaHoy - iPlazo);
                
                LET cDia = LPAD(DAY(dtFecha),2,'0'); 
                LET cAnioMes = YEAR(dtFecha)||LPAD(MONTH(dtFecha),2,'0'); 
                
                SELECT DECODE( cDia, '01', capvig1,  '02', capvig2,  '03', capvig3,  '04', capvig4,  '05', capvig5,  
                                     '06', capvig6,  '07', capvig7,  '08', capvig8,  '09', capvig9,  '10', capvig10, 
                                     '11', capvig11, '12', capvig12, '13', capvig13, '14', capvig14, '15', capvig15, 
                                     '16', capvig16, '17', capvig17, '18', capvig18, '19', capvig19, '20', capvig20, 
                                     '21', capvig21, '22', capvig22, '23', capvig23, '24', capvig24, '25', capvig25, 
                                     '26', capvig26, '27', capvig27, '28', capvig28, '29', capvig29, '30', capvig30, '31', capvig31, 0.00 )
                  INTO mSdoCuenta
                  FROM sc_sdodiarioc
                 WHERE cuenta = pCuenta
                   AND aniomes = cAnioMes;
                
                IF pMonto > mSdoCuenta THEN
                    LET vcodret = '777';
                    LET dtFecha = (pFechaHoy - iPlazo);
                    RETURN vcodret, dtFecha, mSdoCuenta;
                ELSE
                    LET vcodret = '000';
                    LET dtFecha = pFechaHoy;
                    RETURN vcodret, dtFecha, mSdoCuenta;
                END IF;
            END IF;
        END IF;
    ELSE  
        SELECT monto, plazo, periodicidad   
          INTO mMtoLimite, iPlazo, iPeriodicidad
          FROM sc_limiteretiro                         
         WHERE sucursal = '9999';  
         
        IF pMonto <= mMtoLimite THEN
            SELECT {+INDEX(sc_retirosefectivo idx_retirosefectivo_ctafectrasuc)}
                   NVL(SUM(monto), 0.00) 
              INTO mMontoAcum
              FROM sc_retirosefectivo
             WHERE cuenta = pCuenta
               AND fecha = pFechaHoy
               AND transacc = '0223';
               --AND sucursal = pSucursal;
            
            LET mMontoAcum = mMontoAcum + pMonto;
            
            IF mMontoAcum > mMtoLimite THEN 
                LET vcodret = '777';
                LET dtFecha = (pFechaHoy - iPlazo);
                RETURN vcodret, dtFecha, mSdoCuenta;
            ELSE
                LET vcodret = '000';
                LET dtFecha = pFechaHoy;
                RETURN vcodret, dtFecha, mSdoCuenta;
            END IF;
        END IF;
        
        IF pMonto > mMtoLimite OR iPeriodicidad = 1 THEN
            LET dtFecha = (pFechaHoy - iPlazo);
            
            LET cDia = LPAD(DAY(dtFecha),2,'0'); 
            LET cAnioMes = YEAR(dtFecha)||LPAD(MONTH(dtFecha),2,'0'); 
            
            SELECT DECODE( cDia, '01', capvig1,  '02', capvig2,  '03', capvig3,  '04', capvig4,  '05', capvig5,  
                                 '06', capvig6,  '07', capvig7,  '08', capvig8,  '09', capvig9,  '10', capvig10, 
                                 '11', capvig11, '12', capvig12, '13', capvig13, '14', capvig14, '15', capvig15, 
                                 '16', capvig16, '17', capvig17, '18', capvig18, '19', capvig19, '20', capvig20, 
                                 '21', capvig21, '22', capvig22, '23', capvig23, '24', capvig24, '25', capvig25, 
                                 '26', capvig26, '27', capvig27, '28', capvig28, '29', capvig29, '30', capvig30, '31', capvig31, 0.00 )
              INTO mSdoCuenta
              FROM sc_sdodiarioc
             WHERE cuenta = pCuenta
               AND aniomes = cAnioMes;
            
            IF pMonto > mSdoCuenta THEN
                LET vcodret = '777';
                LET dtFecha = (pFechaHoy - iPlazo);
                RETURN vcodret, dtFecha, mSdoCuenta;
            ELSE
                LET vcodret = '000';
                LET dtFecha = pFechaHoy;
                RETURN vcodret, dtFecha, mSdoCuenta;
            END IF;
        END IF;
    END IF;
    
    /* #################################################################################################################################
    LET dtFecha = (pFechaHoy - iPlazo);
    
    IF dtFecha < pFechaHoy THEN
        LET cDia = LPAD(DAY(dtFecha),2,'0'); 
        LET cAnioMes = YEAR(dtFecha)||LPAD(MONTH(dtFecha),2,'0'); 
        
        SELECT DECODE( cDia, '01', capvig1,  '02', capvig2,  '03', capvig3,  '04', capvig4,  '05', capvig5,  
                             '06', capvig6,  '07', capvig7,  '08', capvig8,  '09', capvig9,  '10', capvig10, 
                             '11', capvig11, '12', capvig12, '13', capvig13, '14', capvig14, '15', capvig15, 
                             '16', capvig16, '17', capvig17, '18', capvig18, '19', capvig19, '20', capvig20, 
                             '21', capvig21, '22', capvig22, '23', capvig23, '24', capvig24, '25', capvig25, 
                             '26', capvig26, '27', capvig27, '28', capvig28, '29', capvig29, '30', capvig30, '31', capvig31, 0.00 )
          INTO mSdoCuenta
          FROM sc_sdodiarioc
         WHERE cuenta = pCuenta
           AND aniomes = cAnioMes;
           
        IF mMontoAcum > mSdoCuenta THEN
            LET vcodret = '777';
            RETURN vcodret, dtFecha, mSdoCuenta;
        END IF;
    END IF;
    
    RETURN vcodret, dtFecha, mSdoCuenta;
    ################################################################################################################################# */
	  
    END;
    
END PROCEDURE;