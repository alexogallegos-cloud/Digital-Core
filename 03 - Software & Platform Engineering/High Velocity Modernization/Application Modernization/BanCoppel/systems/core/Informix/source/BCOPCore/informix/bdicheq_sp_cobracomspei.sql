CREATE PROCEDURE "informix".sp_cobracomspei( pEmpresa CHAR(3), pTransacc CHAR(4) )
RETURNING CHAR(5), INTEGER, INTEGER;
    
    DEFINE iSqlError   INTEGER;
    DEFINE iSamError   INTEGER;
    DEFINE cDesError   CHAR(50);
    DEFINE cSqlErr     CHAR(5);
    DEFINE cIsamErr    CHAR(5);
    DEFINE cDescErr    CHAR(50);
    DEFINE cCodRet     CHAR(5);
    DEFINE dFecha      DATE;
    DEFINE iSerialMin  INTEGER;
    DEFINE iExiste     INTEGER;
    DEFINE cCuenta     CHAR(20);
    DEFINE cSucursal   CHAR(4);
    DEFINE iNumSerial  INTEGER;
    DEFINE iSerial     INTEGER;
    DEFINE cHora       CHAR(15);
    DEFINE cFolio      CHAR(16);
    DEFINE cCodRetCom  CHAR(5);
    DEFINE iContador1  INTEGER;
    DEFINE iContador2  INTEGER;
    DEFINE cStatusProc CHAR(1);
    DEFINE mMontoCom   DECIMAL(14,2);
    
    LET iSqlError   = 0;
    LET iSamError   = 0;
    LET cDesError   = '';
    LET cSqlErr     = '';
    LET cIsamErr    = '';
    LET cDescErr    = '';
    LET cCodRet     = '000';
    LET dFecha      = '';
    LET iSerialMin  = 0;
    LET iExiste     = 0;
    LET cCuenta     = '';
    LET cSucursal   = '';
    LET iNumSerial  = 0;
    LET iSerial     = 0;
    LET cHora       = '';
    LET cFolio      = '';
    LET cCodRetCom  = '';
    LET iContador1  = 0;
    LET iContador2  = 0;
    LET cStatusProc = '';
    LET mMontoCom   = 0.00;
    
    BEGIN

    ON EXCEPTION SET iSqlError, iSamError, cDesError
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobracomspei.err";
        TRACE ON;
        IF iSqlError <> 0 THEN
            LET cSqlErr  = iSqlError;
            LET cIsamErr = iSamError;
            LET cDescErr = cDesError;
            UPDATE bdispei:tblctrlproceso
               SET chrstatus = '0'
             WHERE intcveproceso = 7;
            LET cCodRet = '999';
            RETURN cCodRet, iContador1, iContador2;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobracomspei.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    /* #####################################################################################################################################################
    SELECT chrstatus
      INTO cStatusProc
      FROM bdispei:tblctrlproceso
     WHERE intcveproceso = 7;
     
    IF cStatusProc = '0' THEN 
        UPDATE bdispei:tblctrlproceso
           SET chrstatus = '1'
         WHERE intcveproceso = 7;
    
        SELECT fecha_hoy
          INTO dFecha
          FROM sc_fechas
         WHERE empresa = pEmpresa;
         
        SELECT valor::INT
          INTO iSerialMin
          FROM sc_param
         WHERE empresa = pEmpresa
           AND codparam = 'NumSerialCargoSpei';
        
        SELECT {+INDEX(sc_ctecobcomspei idx_ctecobcomspei)}
               COUNT(*)
          INTO iExiste
          FROM sc_movdia mov,
               sc_maechq mae,
               sc_ctecobcomspei cte
         WHERE mov.cuenta = mae.cuenta
           AND cte.num_cte = mae.num_cte
           AND mov.transacc = pTransacc
           AND mov.sucursal IN('5003','5011')
           AND mov.num_serial > iSerialMin;
           
        LET iContador1 = iExiste;
           
        IF iExiste > 0 THEN 
            FOREACH 
                SELECT {+INDEX(sc_ctecobcomspei idx_ctecobcomspei),
                        +INDEX(sc_ctecobcomspei_grupo idx_ctecobcomspei_grupo)}
                       mov.cuenta, mae.sucursal, mov.num_serial, gpo.monto_com
                  INTO cCuenta, cSucursal, iNumSerial, mMontoCom
                  FROM sc_movdia mov,
                       sc_maechq mae,
                       sc_ctecobcomspei cte,
                       sc_ctecobcomspei_grupo gpo
                 WHERE mov.cuenta = mae.cuenta
                   AND cte.num_cte = mae.num_cte
                   AND gpo.tipo_grupo = cte.tipo_grupo
                   AND mov.transacc = pTransacc
                   AND mov.sucursal IN('5003','5011')
                   AND mov.num_serial > iSerialMin
                 ORDER BY mov.num_serial
                 
                LET iContador2 = iContador2 + 1;
                 
                LET iSerial = iNumSerial;
                
                IF mMontoCom > 0.00 THEN
                    LET cHora = CURRENT HOUR TO FRACTION;
                    LET cFolio = 'informix'||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
                       
                    EXECUTE PROCEDURE cargo_comisiones( pEmpresa, cCuenta, '0546', mMontoCom, cFolio, cSucursal, 'informix', 0, '01', dFecha )
                    INTO cCodRetCom;
                END IF;
                
                LET cCuenta = '';
                LET cSucursal = '';
                LET iNumSerial = 0;
                LET cHora = '';
                LET cFolio = '';
                LET cCodRetCom = '';
                LET mMontoCom = 0.00;
            END FOREACH;
            
            IF iSerial <> iSerialMin THEN
                UPDATE sc_param
                   SET valor = iSerial
                 WHERE empresa = pEmpresa
                   AND codparam = 'NumSerialCargoSpei';
            END IF;
        END IF;
        
        UPDATE bdispei:tblctrlproceso
           SET chrstatus = '0'
         WHERE intcveproceso = 7;
    ELSE
        LET cCodRet = '003';
    END IF;
    ##################################################################################################################################################### */
    
    END;
    
    RETURN cCodRet, iContador1, iContador2;
    
END PROCEDURE;