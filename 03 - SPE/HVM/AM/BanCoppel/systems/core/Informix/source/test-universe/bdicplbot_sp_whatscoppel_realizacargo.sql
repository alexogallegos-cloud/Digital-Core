CREATE PROCEDURE "informix".sp_whatscoppel_realizacargo( pCteCoppel CHAR(9),        --- NO CLIENTE COPPEL
                                                         pSucursal  CHAR(4),        --- SUCURSAL
                                                         pTransacc  CHAR(4),        --- TRANSACCION
                                                         pMoneda    CHAR(3),        --- MONEDA
                                                         pFecha     DATE,           --- FECHA
                                                         pFolio     CHAR(16),       --- FOLIO SUC
                                                         pTarjeta   CHAR(4),        --- NO TARJETA
                                                         pMonto     DECIMAL(14,2) ) --- MONTO
RETURNING CHAR(5),  --- CODIGO DE RETORNO 
          CHAR(20), --- NO CLIENTE COPPEL
          DATE,     --- FECHA OPERACION 
          DATE;     --- FECHA APLICACION
       
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(80);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(80);
    DEFINE vEnTransacc  SMALLINT;
    DEFINE vFechaApli   DATE;
    DEFINE vFechaOper   DATE;
    DEFINE vNumCteBco   CHAR(9);
    DEFINE vEmpresa     CHAR(3);
    DEFINE vUsuario     CHAR(8);
    DEFINE vTrxSuc      CHAR(4);
    DEFINE vNoChq       SMALLINT;
    DEFINE vCuenta      CHAR(20);
    DEFINE vTarjeta     CHAR(16);
    DEFINE vReferencia  CHAR(9);
    DEFINE vCodRetCgo   CHAR(5);
    DEFINE vTrxCgo      CHAR(4);
    DEFINE vFechaCgo    DATE;
    DEFINE vSdoDispCgo  DECIMAL(14,2);
    DEFINE vMontoCgo    DECIMAL(14,2);
    DEFINE vProceso     CHAR(1);
    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '00000';
    LET vCodRet2    = '';
    LET vCodRet3    = '';
    LET vEnTransacc = 0;
    LET vFechaApli  = '';
    LET vFechaOper  = '';
    LET vUsuario    = '';
    LET vNumCteBco  = '';
    LET vEmpresa    = '001'; 
    LET vTrxSuc     = '0000';
    LET vNoChq      = 0;
    LET vCuenta     = '';
    LET vTarjeta    = '';
    LET vReferencia = pCteCoppel; 
    LET vCodRetCgo  = '';
    LET vTrxCgo     = '';
    LET vFechaCgo   = '';
    LET vSdoDispCgo = 0.00;
    LET vMontoCgo   = 0.00;
    LET vProceso    = '0';
	
	BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_realizacargo.err";
        --TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            IF vProceso = '1' THEN
                LET vCodRet1 = '00000';
            ELSE
                LET vCodRet1 = '00999';
            END IF;
            RETURN vCodRet1, pCteCoppel, vFechaApli, vFechaOper;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vEnTransacc = 1;
    END EXCEPTION WITH resume;
    
    --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_realizacargo.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF vEnTransacc = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    IF ( pCteCoppel is null OR pCteCoppel = '' ) OR
       ( pSucursal is null OR pSucursal = '' OR LENGTH(pSucursal) <> 4 ) OR
       ( pTransacc is null OR pTransacc = '' OR LENGTH(pTransacc) <> 4 ) OR
       ( pMoneda is null OR pMoneda = '' OR LENGTH(pMoneda) <> 3 ) OR
       ( pFecha is null OR pFecha = '' ) OR
       ( pFolio is null OR pFolio = '' OR LENGTH(pFolio) <> 16 ) OR
       ( pTarjeta is null OR pTarjeta = '' OR LENGTH(pTarjeta) <> 4 ) OR
       ( pMonto is null OR pMonto <= 0.00 ) THEN
        IF vEnTransacc = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vCodRet1 = '00110';
        RETURN vCodRet1, pCteCoppel, vFechaApli, vFechaOper;
    END IF;
    
    --- LET pMonto = pMonto / 100;
    
    IF LENGTH(pMoneda) = 3 THEN
        LET pMoneda = pMoneda[2,3]; 
    END IF;
    
    SELECT valor
      INTO vUsuario
      FROM bdicheq:sc_param
     WHERE empresa = vEmpresa
       AND codparam = 'UsuarioCoppelBot';
       
    IF vUsuario is null OR vUsuario = '' OR LENGTH(vUsuario) <> 8 THEN
        IF vEnTransacc = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vCodRet1 = '00111';
        RETURN vCodRet1, pCteCoppel, vFechaApli, vFechaOper;
    END IF;
    
    SELECT numctebco
      INTO vNumCteBco
      FROM bdinteg:si_enrol_cplbot
     WHERE numctecpl = pCteCoppel
       AND status = 'A';
       
    IF vNumCteBco is null OR vNumCteBco = '' OR LENGTH(vNumCteBco) <> 9 THEN
        IF vEnTransacc = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vCodRet1 = '00111';
        RETURN vCodRet1, pCteCoppel, vFechaApli, vFechaOper;
    END IF;
    
    SELECT cuenta, num_tarjeta
      INTO vCuenta, vTarjeta
      FROM bdicheq:sc_tarjeta
     WHERE numcte = vNumCteBco
       AND SUBSTR(num_tarjeta, -8, 4) = pTarjeta;
    
    EXECUTE PROCEDURE bdicheq:cargo_ref( vEmpresa, pSucursal, vUsuario, pTransacc, vTrxSuc, pFolio, vCuenta, vNoChq, pMonto, pMoneda, vReferencia, vTarjeta, vUsuario )
    INTO vCodRetCgo, vTrxCgo, vFechaCgo, vSdoDispCgo, vMontoCgo;
    
    IF vCodRetCgo = '000' THEN
        LET vProceso = '1';
        LET vCodRet1 = '00000';
        LET vFechaApli = vFechaCgo;
        LET vFechaOper = CURRENT;
    ELSE
        IF vCodRetCgo = '400' THEN
            LET vCodRet1 = '00010';
        ELIF vCodRetCgo = '300' THEN
            LET vCodRet1 = '00301';
		ELIF vCodRetCgo = '951' THEN  --- Se agrega validación de código de Moneda
			LET vCodRet1 = '00951';
        ELSE
            LET vCodRet1 = '00999';
        END IF;
    
        IF vEnTransacc = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
    
        RETURN vCodRet1, pCteCoppel, vFechaApli, vFechaOper;
    END IF;
    
    IF vEnTransacc = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    END; 
    
    RETURN vCodRet1, pCteCoppel, vFechaApli, vFechaOper;
    
END PROCEDURE;