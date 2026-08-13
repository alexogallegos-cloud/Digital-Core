CREATE PROCEDURE "informix".sp_cap_consdoctatransfersoccomp(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pTransaccTrf CHAR(5), pSerial INTEGER, pFolioSuc CHAR(16))
		RETURNING CHAR(5) AS codret,
			MONEY(14,2) AS mSdoCtaTrf;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE mSdoCtaTrf MONEY(14,2);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET mSdoCtaTrf = 0.00;
		LET iNoRegistros = 0;
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, mSdoCtaTrf;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consdoctatransfersoccomp.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, mSdoCtaTrf;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, mSdoCtaTrf;
			END IF;
			
			EXECUTE PROCEDURE bdicnweb:'informix'.sp_consdoctatransfersoccomp(pCuenta,pTransaccTrf,pSerial,pFolioSuc)
			INTO cCodRetSp, mSdoCtaTrf;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicnweb:sp_consdoctatransfersoccomp';
			ELIF cCodRetSp::INTEGER = 999 THEN
				LET cCodRet = '00710';
			END IF;
			
			RETURN cCodRet, mSdoCtaTrf;
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 11/12/2015',
'MODULO: DÃ©bito',
'FUNCIONALIDAD: DepÃ³sito a Cuentas Transfer de DÃ©bito', 
'DESCRIPCION: SPL que se encarga de calcular el monto de la cuenta transfer.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultabonotransfer(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pTransacc CHAR(4),
pCuenta CHAR(20), pCheque INTEGER, pMonto DECIMAL(14,2), pReferencia CHAR(40), pTarjeta CHAR(16))
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensaje CHAR(80);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensaje = '';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultabonotransfer.out';
		-- TRACE ON;	
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pMonto is null OR pSucursal = '' OR pTransacc = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		EXECUTE PROCEDURE bdicnweb:"informix".sp_abonotransfersoc(pSucursal,pUsuario,pTransacc,pCuenta,pCheque,pMonto,pReferencia,pTarjeta)
		INTO cCodRetSp, cMensaje;		
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_abonotransfersoc';
		END IF;
		
		IF pMonto <= 0.00 OR LENGTH(pSucursal) <> 4 OR LENGTH(pUsuario)  <> 8 OR LENGTH(pTransacc) <> 4 OR LENGTH(pCuenta)   <> 11   AND iCodRetSp = 110 THEN 
		    LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;		
		IF cMensaje = 'PROCESO DE ABONO NO REGISTRADO' AND iCodRetSP = 110  THEN -- proceso de abono  no registrado
			LET cCodRet = '00711';
			RETURN cCodRet;
		END IF;
		IF iCodRetSP = 110 THEN -- proceso no registrado
			LET cCodRet = '00667';
			RETURN cCodRet;
		END IF;
		IF  iCodRetSP = 200  THEN -- cuentas canceladas
			LET cCodRet = '00456';
			RETURN cCodRet;
		END IF;
		IF  iCodRetSP <> 000  THEN 
			LET cCodRet = '00712';
			RETURN cCodRet;
		END IF;				
			RETURN cCodRet;
		
		IF cCodRet = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/11/2015',
'MODULO: Debito',
'FUNCIONALIDAD:DEPÃSITO A CUENTAS TRANSFER DE DÃBITO',
'DESCRIPCION: SPL que consulta los depositos de cuentas transfer',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultacargotransfersoc(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pTransacc CHAR(4), pCuenta CHAR(20),pCheque INTEGER, pMonto DECIMAL(14,2), pReferencia CHAR(40), pTarjeta CHAR(16))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensaje CHAR(40);	
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cMensaje = '';	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultacargotransfersoc.out';
		-- TRACE ON;		
		
		IF pUsuario = '' OR pIdFuncion = '' OR pMonto is null OR pSucursal = '' OR pTransacc = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
				
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdicnweb:"informix".sp_cargotransfersoc( pSucursal, pUsuario,pTransacc,pCuenta, pCheque, pMonto,pReferencia,pTarjeta)
		INTO cCodRetSp, cMensaje;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cargotransfersoc';
		END IF
		
		IF pMonto <= 0.00 OR LENGTH(pSucursal) <> 4 OR LENGTH(pUsuario)  <> 8 OR LENGTH(pTransacc) <> 4 OR LENGTH(pCuenta)   <> 11   AND iCodRetSp = 110 THEN 
		    LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;			
		IF cMensaje = 'PROCESO DE CARGO NO REGISTRADO' AND iCodRetSP = 110  THEN -- proceso de cargo  no registrado
			LET cCodRet = '713';
			RETURN cCodRet;
		END IF;
		IF iCodRetSP = 110 THEN -- proceso no registrado
			LET cCodRet = '00667';
			RETURN cCodRet;
		END IF;
		IF  iCodRetSP = 200  THEN -- cuentas canceladas
			LET cCodRet = '00456';
			RETURN cCodRet;
		END IF;
		IF  iCodRetSP <> 000  THEN 
			LET cCodRet = '00714';
			RETURN cCodRet;
		END IF;
			RETURN cCodRet;
			
		IF cCodRet = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez Rugerio ',
'FECHA: 04/11/2015',
'MODULO: DEBITO',
'FUNCIONALIDAD: DEPÓSITO A CUENTAS TRANSFER CARGO',
'DESCRIPCION: SPL que realiza la consulta de los cargos de transfer del soc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargotransfersoc( pSucursal   CHAR(4), 
                                                 pUsuario    CHAR(8),
                                                 pTransacc   CHAR(4),
                                                 pCuenta     CHAR(20),
                                                 pCheque     INTEGER,
                                                 pMonto      DECIMAL(14,2),
                                                 pReferencia CHAR(40),
                                                 pTarjeta    CHAR(16) )
RETURNING CHAR(5), CHAR(40);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(40);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cProceso     CHAR(13);
    DEFINE cStatusTar   CHAR(1);
    DEFINE cHora        CHAR(15);
    DEFINE cFolio       CHAR(16);
    DEFINE cCodRet4     CHAR(5);
    DEFINE cTrxApli     CHAR(4);
    DEFINE cFechaApli   DATE;
    DEFINE mMtoDisp     DECIMAL(14,2);
    DEFINE mMtoApli     DECIMAL(14,2);
    DEFINE cCodRet5     CHAR(5);
    DEFINE cTrxCom      CHAR(4);
    DEFINE cFechaCom    DATE;
    DEFINE mSdoCom      DECIMAL(14,2);
    DEFINE mMtoCom      DECIMAL(14,2);
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iSamErr    = 0;
    LET cDesErr    = '';
    LET cProceso   = '';
    LET cStatusTar = '';
    LET cHora      = '';
    LET cFolio     = '';
    LET cCodRet4   = '';
    LET cTrxApli   = '';
    LET cFechaApli = '';
    LET mMtoDisp   = 0.00;
    LET mMtoApli   = 0.00;
    LET cCodRet5   = '';
    LET cTrxCom    = '';
    LET cFechaCom  = '';
    LET mSdoCom    = 0.00;
    LET mMtoCom    = 0.00;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_cargotransfersoc.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cCodRet3;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_cargotransfersoc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pMonto     is null OR pMonto <= 0.00 ) OR
       ( pSucursal  is null OR pSucursal = '' OR LENGTH(pSucursal) <> 4 ) OR
       ( pUsuario   is null OR pUsuario  = '' OR LENGTH(pUsuario)  <> 8 ) OR
       ( pTransacc  is null OR pTransacc = '' OR LENGTH(pTransacc) <> 4 ) OR
       ( ( pCuenta  is null OR pCuenta   = '' OR LENGTH(pCuenta)   <> 11 ) AND 
         ( pTarjeta is null OR pTarjeta  = '' OR LENGTH(pTarjeta)  <> 16 ) ) THEN
        LET cCodRet1 = '110';
        LET cCodRet3 = 'PARAMETROS INSUFICENTES';
        RETURN cCodRet1, cCodRet3;
    END IF;
    
    -- // VALIDA PROCESO DE LA TRANSACCION
    SELECT TRIM(proceso)
      INTO cProceso
      FROM bdicheq:sc_trxtrfcargosoc
     WHERE transacc = pTransacc;
     
    IF cProceso is null OR cProceso = '' THEN
        LET cCodRet1 = '110';
        LET cCodRet3 = 'PROCESO NO REGISTRADO';
        RETURN cCodRet1, cCodRet3;
    END IF;
    
    -- // OBTIENE CUENTA SI NO VIENE EN LOS PARAMETROS DE ENTRADA
    IF pCuenta is null OR pCuenta = '' THEN
        SELECT cuenta, status_tar
          INTO pCuenta, cStatusTar
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pTarjeta;
           
        IF pCuenta is null OR cStatusTar is null OR cStatusTar <> 'A' THEN
            LET cCodRet1 = '200';
            LET cCodRet3 = 'CUENTA CANCELADA';
            RETURN cCodRet1, cCodRet3;
        END IF;
    END IF;
    
    -- // OBTIENE TARJETA SI NO VIENE EN LOS PARAMETROS DE ENTRADA
    IF pTarjeta is null OR pTarjeta = '' THEN
        SELECT num_tarjeta
          INTO pTarjeta
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pCuenta
           AND secuencia = (SELECT MAX(secuencia)
                              FROM bdicheq:sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pCuenta)
           AND status_tar = 'A';
           
        IF pTarjeta is null THEN
            LET pTarjeta = '';
        END IF;
    END IF;
    
    -- // APLICA EL CARGO EN LA CUENTA
    IF cProceso = 'cargo_ref' THEN
        
        LET cHora = CURRENT HOUR TO FRACTION;
        LET cFolio = pUsuario||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
        
        CALL bdicheq:cargo_ref( '001', pSucursal, pUsuario, pTransacc, '0000', cFolio, pCuenta, 0, pMonto, '01', pReferencia, pTarjeta, pUsuario ) 
        RETURNING cCodRet4, cTrxApli, cFechaApli, mMtoDisp, mMtoApli;
        
        IF cCodRet4 <> '000' THEN
            LET cCodRet1 = cCodRet4;
            LET cCodRet3 = 'ERROR EN EL PROCESO DE CARGO';
            RETURN cCodRet1, cCodRet3;
        END IF;
        
    ELIF cProceso = 'cargo_ref_cel' THEN 
        
        LET cHora = CURRENT HOUR TO FRACTION;
        LET cFolio = pUsuario||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
        
        CALL bdicheq:cargo_ref_cel( pTarjeta, pSucursal, pUsuario, pTransacc, pTransacc, cFolio, pCuenta, 0, pMonto, 0.00, '', '', 
                                    '01', pReferencia, '', '', '', '', '', '', '', 0.00, '', '', '1', 'F', '', '', '', '', 0.00, '', '' )
        RETURNING cCodRet4, cTrxApli, cFechaApli, mMtoDisp, mMtoApli, cCodRet5, cTrxCom, cFechaCom, mSdoCom, mMtoCom;
        
        IF cCodRet4 <> '000' THEN
            LET cCodRet1 = cCodRet4;
            LET cCodRet3 = 'ERROR EN EL PROCESO DE CARGO';
            RETURN cCodRet1, cCodRet3;
        END IF;
        
    ELSE
        
        LET cCodRet1 = '110';
        LET cCodRet3 = 'PROCESO DE CARGO NO REGISTRADO';
        RETURN cCodRet1, cCodRet3;
        
    END IF;
    
    LET cCodRet1 = '000';
    LET cCodRet3 = 'RETIRO REALIZADO CORRECTAMENTE';

    END;
    
    RETURN cCodRet1, cCodRet3;
    
END PROCEDURE;