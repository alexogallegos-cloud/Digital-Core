CREATE PROCEDURE "informix".sp_transfer_online_setsvabalance( pTranTrfn CHAR(5), --20023
                                                        pCuenta   CHAR(20), --80
                                                        pFolioSuc CHAR(16),--FOLIO SUC
                                                        pUsuario  CHAR(8), --USUARIO
														pmto_tot DECIMAL(14,2),
														preferencia CHAR(40),
														psucursal CHAR(4),
														pcoment CHAR(200))
RETURNING CHAR(5), INTEGER;
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cWebService  CHAR(128);
    DEFINE cPaisTrnf    CHAR(3);
    DEFINE cBancoTrnf   CHAR(3);
    DEFINE cCanalTrnf   CHAR(3);
    DEFINE cMonedaTrnf  CHAR(3);
    DEFINE cCodRetSer   CHAR(5);
    DEFINE iSerial      INTEGER;
    DEFINE cHora        CHAR(23); 
    DEFINE cFechaHora   CHAR(15);
    DEFINE cTrama       CHAR(600);
    DEFINE cCodigoRet   CHAR(5);
    DEFINE cSucursal    CHAR(14);
    DEFINE cNoAudit     CHAR(15);
    DEFINE cTransaccId  CHAR(35);
    DEFINE cUsuario     CHAR(10);
    DEFINE cStatus      CHAR(1);
	DEFINE cFolioSuc	CHAR(35);
	DEFINE cCuenta		CHAR(18);
	DEFINE cLenCta		INT;
	DEFINE cidentifier	CHAR(3);
	DEFINE cComenta		CHAR(256);
	DEFINE cMonto		CHAR(17);
	DEFINE cReferencia	CHAR(15);
--SET DEBUG FILE TO "/informix/ifg/sp_transfer_online_setsvabalance.out";
--TRACE ON;
    
    LET cCodRet     = '';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr     = 0;
    LET iSamErr     = 0;
    LET cDesErr     = 0;
    LET cWebService = '';
    LET cPaisTrnf   = '';
    LET cBancoTrnf  = '';
    LET cCanalTrnf  = '';
    LET cMonedaTrnf = '';
    LET cCodRetSer  = '';
    LET cTrama      = '';
    LET cCodigoRet  = '';
    LET cSucursal   = '';
    LET cNoAudit    = '';
    LET iSerial     = 0;
    LET cStatus     = 'N';
    LET cUsuario    = '';
	LET cFolioSuc	= TRIM(pFolioSuc);
	LET cCuenta		= TRIM(pCuenta);
	LET cLenCta 	= LEN(cCuenta);
	LET cMonto		= pmto_tot;
	LET	cReferencia = TRIM(preferencia);
	LET cidentifier = '';
	LET cComenta = TRIM(pcoment)||' '||TRIM(preferencia);
    --- LET cTransaccId = pFolioSuc||pCuenta;
    LET cTransaccId = RPAD(TRIM(pFolioSuc)||TRIM(pCuenta), 35, '0');
    LET cHora       = CURRENT;
    --- LET cFechaHora  = SUBSTR(cHora,1,4)||SUBSTR(cHora,6,2)||SUBSTR(cHora,9,2)||SUBSTR(cHora,12,2)||SUBSTR(cHora,15,2)||SUBSTR(cHora,18,2);
    LET cFechaHora  = RPAD(SUBSTR(cHora,1,4)||SUBSTR(cHora,6,2)||SUBSTR(cHora,9,2)||SUBSTR(cHora,12,2)||SUBSTR(cHora,15,2)||SUBSTR(cHora,18,2), 15 , '0');
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_reverso.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet, iSerial;
        END IF;
    END EXCEPTION;
   
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	
    SELECT valor
      INTO cWebService
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCorSdoTransfer';
    
    SELECT valor
      INTO cPaisTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodPaisTransfer';
    
    SELECT valor
      INTO cBancoTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodBancoTransfer';
    
    SELECT valor
      INTO cCanalTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodCanalTransfer';
    
    SELECT valor
      INTO cMonedaTrnf
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'WSCodMonedaTransfer';
    
    CALL sp_transfer_online_serial( pCuenta, pFolioSuc, pTranTrfn)
    RETURNING cCodRetSer, iSerial;
    
    IF cCodRetSer <> '000' OR iSerial = 0 THEN
        LET cCodRet = '999';
        RETURN cCodRet, iSerial;
    END IF;
	
	IF cLenCta = 12 THEN
		LET cidentifier = '101';
	END IF;
	IF cLenCta = 18 THEN
		LET cidentifier = '102';
	END IF;
	IF cLenCta = 11 THEN
		LET cidentifier = '104';
	END IF;
	IF cLenCta = 16 THEN
		LET cidentifier = '103';
	END IF;
    
    LET cTrama = cWebService 	 || --/setSVABalance
                 cFechaHora  	 || --/Variable de SPL
                 cPaisTrnf   	 || --/484
                 cBancoTrnf  	 || --/137
                 cTransaccId 	 || --/foliosuc&cta
				 cFolioSuc	 	 ||--originalOriginatorTransactionId opcional==>pFolioSuc--/Opcional
                 cCanalTrnf  	 || --/el spl toma sucursal (102)
                 cMonedaTrnf 	 || --/484
                 cCuenta	 	 ||--customerIdentifier CLABE numero de tarjeta numero de cuenta()
				 cidentifier	 ||--identifierType depende del dato anterior
				 cComenta	 	 ||--comment--comentario del motivo del reverso 'restauracion del saldo por devolucion de SPEI ||preferencia'
				 cMonto		 	 ||--amount monto a corregir  pmto_tot *-1 
				 cReferencia 	 ||--auditNumber (CLAVE DE SPEI)==preferencia
				 cUsuario    	 || --O
                 cSucursal   	 || --O
                 '$$'; 
    INSERT INTO sc_transfer_online( no_serial, cuenta, folio_suc, id_transacc, trama, cod_ret, status, fecha_hora )
    VALUES( iSerial, pCuenta, pFolioSuc, pTranTrfn, TRIM(cTrama), cCodigoRet, cStatus, current );
    
    IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
        LET cCodRet = '000';
        LET iSerial = iSerial;
    ELSE
        LET cCodRet = '999';
        LET iSerial = 0;
    END IF;
    
    END;
    
    RETURN cCodRet, iSerial;
    
END PROCEDURE;