CREATE PROCEDURE "informix".sp_whatscoppel_valotp( pCteCoppel char(9),  --- NO CLIENTE COPPEL
                                                   pTelMovil CHAR(10),  --- TELEFONO MOVIL
                                                   pOTP CHAR(6) )       --- CLAVE OTP
RETURNING CHAR(5),  --- CODIGO DE RETORNO 
          CHAR(20); --- NO CLIENTE COPPEL
    
    DEFINE Sql_Err     INTEGER;
    DEFINE Isam_Err    INTEGER;
    DEFINE Desc_Err    CHAR(80);
    DEFINE vCodRet1    CHAR(5);
    DEFINE vCodRet2    CHAR(5);
    DEFINE vCodRet3    CHAR(80);
    DEFINE vIntenPerm  SMALLINT;
    DEFINE vIntentos   SMALLINT;
    DEFINE vOtpEnv     CHAR(6);
    DEFINE vEmpresa    CHAR(3);
    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '00000';
    LET vCodRet2    = '';
    LET vCodRet3    = '';
    LET vIntenPerm  = 0;
    LET vIntentos   = 0;
    LET vOtpEnv     = '';
    LET vEmpresa    = '001';
	
	BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_valotp.err";
        --TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            LET vCodRet1 = '00999';
            RETURN vCodRet1, pCteCoppel;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_valotp.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pCteCoppel is null OR pCteCoppel = '' ) OR
       ( pTelMovil is null OR pTelMovil = '' OR LENGTH(pTelMovil) <> 10 ) OR 
       ( pOTP is null OR pOTP = '' OR LENGTH(pOTP) <> 6 ) THEN
        LET vCodRet1 = '00110';
        RETURN vCodRet1, pCteCoppel;
    END IF;
    
    SELECT valor::int
      INTO vIntenPerm
      FROM bdicheq:sc_param
     WHERE empresa = vEmpresa
       AND codparam = 'NoIntenPermCplBot';
    
    SELECT otp_env, no_intentos
      INTO vOtpEnv, vIntentos
      FROM bdinteg:si_enrol_cplbot
     WHERE numctecpl = pCteCoppel;
     
    IF vOtpEnv is null THEN
        LET vCodRet1 = '00111';
        RETURN vCodRet1, pCteCoppel;
    END IF;
     
    IF vIntentos > vIntenPerm THEN
        LET vCodRet1 = '00117';
        RETURN vCodRet1, pCteCoppel;
    END IF;
     
    IF vOtpEnv = pOTP THEN
        UPDATE bdinteg:si_enrol_cplbot
           SET status = 'A',
               otp_rec = pOTP,
               no_intentos = no_intentos + 1,
               fecha_enrol = CURRENT
         WHERE numctecpl = pCteCoppel;
    ELSE
        UPDATE bdinteg:si_enrol_cplbot
           SET no_intentos = no_intentos + 1
         WHERE numctecpl = pCteCoppel;
        
        LET vCodRet1 = '00114';
        RETURN vCodRet1, pCteCoppel;
    END IF;
 
    END; 
    
    RETURN vCodRet1, pCteCoppel;
    
END PROCEDURE;