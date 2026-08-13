CREATE PROCEDURE "informix".sp_obtfoliosuc(pusuario CHAR(8)) 
RETURNING CHAR(5), INTEGER, CHAR(16); 
    
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vSqlErr      INTEGER; 
    DEFINE vIsamErr     INTEGER;
    DEFINE wfecha_hoy    DATE;
    DEFINE wfecha        CHAR(8);
    DEFINE wfecha_fol    CHAR(4);
    DEFINE wserial_folio INTEGER;
    DEFINE wfolio_suc    CHAR(16);
    DEFINE intRowId      INTEGER;
    DEFINE intSerial     INTEGER;
    
    LET vCodRet1 = '000';
    LET vCodRet2 = '';
    LET vSqlErr = 0;
    LET vIsamErr = 0;
    LET wfecha_hoy = '';
    LET wfecha = '';
    LET wfecha_fol = '';
    LET wserial_folio = 0;
    LET wfolio_suc = ''; 
    LET intRowId  = 0;
    LET intSerial = 0;
    
    --- SET DEBUG FILE TO "/ids10_2uc5/jivan/spei/sp_obtfoliosuc.out";
    --- TRACE ON;

    BEGIN  
    
    ON EXCEPTION SET vSqlErr, vIsamErr
        --- SET DEBUG FILE TO "/ids10_2uc5/jivan/spei/sp_obtfoliosuc.err";
        --- TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            RETURN vCodRet1, wserial_folio, 'error'; 
        END IF;
    END EXCEPTION;   
    
    SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 3; 
    
    SELECT fecha_hoy
      INTO wfecha_hoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = '001';
     
    LET wfecha = TO_CHAR(wfecha_hoy, '%m%d%Y');
    LET wfecha_fol = wfecha[1,2]||wfecha[3,4];
      
    SELECT MAX(intserial_folio)
      INTO wserial_folio
      FROM bdispei:"informix".tblserialfolio;
      
    IF wserial_folio is null OR wserial_folio = '' THEN
        LET wserial_folio = 0;
    END IF;
    
    LET wserial_folio = wserial_folio + 1;
    
    IF   wserial_folio <= 9 THEN
        LET wfolio_suc = SUBSTR(pusuario, 5, 4) || wfecha_fol || '0000000' || wserial_folio;
    ELIF wserial_folio <= 99 THEN
        LET wfolio_suc = SUBSTR(pusuario, 5, 4) || wfecha_fol || '000000' || wserial_folio;
    ELIF wserial_folio <= 999 THEN
        LET wfolio_suc = SUBSTR(pusuario, 5, 4) || wfecha_fol || '00000' || wserial_folio;
    ELIF wserial_folio <= 9999 THEN
        LET wfolio_suc = SUBSTR(pusuario, 5, 4) || wfecha_fol || '0000' || wserial_folio;
    ELIF wserial_folio <= 99999 THEN
        LET wfolio_suc = SUBSTR(pusuario, 5, 4) || wfecha_fol || '000' || wserial_folio;
    ELIF wserial_folio <= 999999 THEN
        LET wfolio_suc = SUBSTR(pusuario, 5, 4) || wfecha_fol || '00' || wserial_folio;
	ELIF wserial_folio <= 9999999 THEN
        LET wfolio_suc = SUBSTR(pusuario, 5, 4) || wfecha_fol || '0' || wserial_folio;
	ELIF wserial_folio <= 99999999 THEN
        LET wfolio_suc = SUBSTR(pusuario, 5, 4) || wfecha_fol || '' || wserial_folio;
    ELSE
        LET vCodRet1 = '999';
    END IF;    
	
	IF vCodRet1 <> '999' THEN
		INSERT INTO tblserialfolio VALUES(wserial_folio);
	END IF;
    
    END;
    
    RETURN vCodRet1, wserial_folio, wfolio_suc;
    
END PROCEDURE;