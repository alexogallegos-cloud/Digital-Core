CREATE PROCEDURE "informix".sp_whatscoppel_enrola( pCteCoppel CHAR(20),  --- NO CLIENTE COPPEL
                                                   pFechaNac  DATE,      --- FECHA NACIMIENTO
                                                   pTelMovil  CHAR(13) ) --- TELEFONO MOVIL
RETURNING CHAR(5),  --- CODIGO DE RETORNO 
          CHAR(20); --- NO CLIENTE COPPEL
    
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(80);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(80);
    DEFINE vComienza    INTEGER;
    DEFINE vEnTransacc  SMALLINT;
    DEFINE vContador1   INTEGER;
    DEFINE iExisteEnrol SMALLINT;
    DEFINE cNumCteBco   CHAR(9);
    DEFINE cEmpresa     CHAR(3);
    DEFINE iExisteCel   SMALLINT;
    DEFINE dFechaNac    DATE;
    DEFINE cStatus      CHAR(1);
    DEFINE cOtp_rec     CHAR(6);
    DEFINE cIntentos    SMALLINT;
    DEFINE cFecenrol    DATETIME YEAR TO FRACTION(5);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc  = 0;
    LET vContador1   = 0;
    LET iExisteEnrol = 0;
    LET cNumCteBco   = '';
    LET cEmpresa     = '001';
    LET iExisteCel   = 0;
    LET dFechaNac    = '';
    LET cStatus      = '';
    LET cOtp_rec     = '';
    LET cIntentos    = 0;
    LET cFecenrol    = CAST('2020-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(3));
    	
	BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_enrola.err";
        --TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, pCteCoppel;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_enrola.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
     
    IF ( pFechaNac is null OR pFechaNac = '' ) OR
       ( pTelMovil is null OR pTelMovil = '' OR LENGTH(pTelMovil) <> 10 ) THEN
        LET vCodRet1 = '00110';
        RETURN vCodRet1, pCteCoppel;
    END IF;
    
    SELECT COUNT(*)
      INTO iExisteEnrol
      FROM bdinteg:si_enrol_cplbot
     WHERE numctecpl = pCteCoppel;
    
    IF iExisteEnrol = 0 THEN
    
        SELECT numcte
          INTO cNumCteBco
          FROM bdinteg:si_cliente
         WHERE numcte_ref = pCteCoppel;
         
        IF ( cNumCteBco is null OR cNumCteBco = '' ) THEN
            SELECT numcte_banco
              INTO cNumCteBco
              FROM bdinteg:si_relacion_ctebcplcpl
             WHERE empresa = cEmpresa
               AND cliente = pCteCoppel;
               
            IF ( cNumCteBco is null OR cNumCteBco = '' ) THEN
                LET vCodRet1 = '00111';
                RETURN vCodRet1, pCteCoppel;
            END IF;
        END IF;
        
        SELECT COUNT(*)
          INTO iExisteCel
          FROM bdinteg:si_telefonos
         WHERE numcte = cNumCteBco
           AND tipo_tel = 2
           AND telefono = pTelMovil
           AND status_tel = 'A'
           AND verificado = 'V'
           AND secuencia = ( SELECT MAX(secuencia)
                               FROM bdinteg:si_telefonos 
                              WHERE numcte = cNumCteBco
                                AND tipo_tel = 2
                                AND telefono = pTelMovil
                                AND status_tel = 'A'
                                AND verificado = 'V');
           
        IF iExisteCel = 0 THEN
            SELECT COUNT(*)
              INTO iExisteCel
              FROM bdinteg:si_telefonos_actual
             WHERE numcte = cNumCteBco
               AND tipo_tel = 2
               AND status_tel = 'A'
               AND tel_confirmado = '1'
               AND telefono = pTelMovil;
               
            IF iExisteCel = 0 THEN
                LET vCodRet1 = '00112';
                RETURN vCodRet1, pCteCoppel;
            END IF;
        END IF;
        
        SELECT fecha_nac
          INTO dFechaNac
          FROM bdinteg:si_ctepf
         WHERE numcte = cNumCteBco;
         
        IF ( dFechaNac is null OR dFechaNac = '' OR dFechaNac <> pFechaNac ) THEN
            LET vCodRet1 = '00113';
            RETURN vCodRet1, pCteCoppel;
        END IF;
        
        INSERT INTO bdinteg:si_enrol_cplbot
        ( numctecpl, numctebco, status, tel_movil, otp_env, otp_rec, no_intentos, fecha_enrol )
        VALUES
        ( pCteCoppel, cNumCteBco, 'N', pTelMovil, '', '', 0, '' );
        
    ELIF iExisteEnrol > 0 THEN
        
        SELECT numctebco,status,otp_rec,no_intentos,fecha_enrol
          INTO cNumCteBco,cStatus,cOtp_rec,cIntentos,cFecenrol
          FROM bdinteg:si_enrol_cplbot
         WHERE numctecpl = pCteCoppel;
		
        IF cStatus = 'A' THEN
		
            LET vCodRet1 = '00109';
            RETURN vCodRet1, pCteCoppel;
			
        -- // Se agrego funcion, cuando el usuario deja incompleto el enrolamiento, pueda enrolarse de nuevo si no ha mandado OTP
        ELIF cStatus = 'N' AND  cOtp_rec = '' AND cFecenrol IS NULL THEN
		
			DELETE FROM bdinteg:si_enrol_cplbot 
             WHERE numctecpl = pCteCoppel 
               AND status ='N' 
               AND otp_rec = '';
		
			INSERT INTO bdinteg:si_enrol_cplbot
			( numctecpl, numctebco, status, tel_movil, otp_env, otp_rec, no_intentos, fecha_enrol )
			VALUES
			( pCteCoppel, cNumCteBco, 'N', pTelMovil, '', '', 0, '' );
			
		ELIF cStatus <> 'A'	THEN
		
			LET vCodRet1 = '00111';
            RETURN vCodRet1, pCteCoppel;

        END IF;
        
    END IF;    
 
    END; 
    
    RETURN vCodRet1, pCteCoppel;
    
END PROCEDURE;