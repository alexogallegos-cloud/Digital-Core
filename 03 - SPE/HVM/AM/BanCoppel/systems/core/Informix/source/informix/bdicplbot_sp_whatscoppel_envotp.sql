CREATE PROCEDURE "informix".sp_whatscoppel_envotp( pCteCoppel CHAR(9),  --- NO CLIENTE COPPEL
                                                   pTelMovil CHAR(10) ) --- TELEFONO MOVIL
RETURNING CHAR(5),  --- CODIGO DE RETORNO 
          CHAR(20), --- NO CLIENTE COPPEL
          CHAR(6),  --- CLAVE OTP
          CHAR(20); --- NO CLIENTE BANCO
    
    DEFINE Sql_Err     INTEGER;
    DEFINE Isam_Err    INTEGER;
    DEFINE Desc_Err    CHAR(80);
    DEFINE vCodRet1    CHAR(5);
    DEFINE vCodRet2    CHAR(5);
    DEFINE vCodRet3    CHAR(80);
    DEFINE vCodRetGen  CHAR(5);
    DEFINE vCteCoppel  CHAR(9);
    DEFINE vOTP        CHAR(6);
    DEFINE vNumCteBco  CHAR(9);
    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '00000';
    LET vCodRet2    = '';
    LET vCodRet3    = '';
    LET vCodRetGen  = '';
    LET vCteCoppel  = '';
    LET vOTP        = '';
    LET vNumCteBco  = '';
	
	BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_envotp.err";
        --TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, pCteCoppel, vOTP, vNumCteBco;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_envotp.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pCteCoppel is null OR pCteCoppel = '' ) OR
       ( pTelMovil is null OR pTelMovil = '' OR LENGTH(pTelMovil) <> 10 ) THEN
        LET vCodRet1 = '00110';
        RETURN vCodRet1, pCteCoppel, vOTP, vNumCteBco;
    END IF;
    
    SELECT numctebco
      INTO vNumCteBco
      FROM bdinteg:si_enrol_cplbot
     WHERE numctecpl = pCteCoppel;
       
    IF vNumCteBco is null OR vNumCteBco = '' OR LENGTH(vNumCteBco) <> 9 THEN
        LET vCodRet1 = '00111';
        RETURN vCodRet1, pCteCoppel, vOTP, vNumCteBco;
    END IF;
    
    EXECUTE PROCEDURE sp_whatscoppel_genotp( pCteCoppel, pTelMovil )
    INTO vCodRetGen, vCteCoppel, vOTP;

    IF ( vCodRetGen = '00000' AND ( vOTP is not null AND vOTP <> '' AND LENGTH(vOTP) = 6 ) ) THEN
        UPDATE bdinteg:si_enrol_cplbot
           SET otp_env = vOTP
         WHERE numctecpl = pCteCoppel;
    ELSE
        LET vCodRet1 = '00999';
        RETURN vCodRet1, pCteCoppel, vOTP, vNumCteBco;
    END IF;
 
    END; 
    
    RETURN vCodRet1, pCteCoppel, vOTP, vNumCteBco;
    
END PROCEDURE;