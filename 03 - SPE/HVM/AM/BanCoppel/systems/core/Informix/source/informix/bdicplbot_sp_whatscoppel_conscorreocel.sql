CREATE PROCEDURE "informix".sp_whatscoppel_conscorreocel( pCteCoppel CHAR(9) )  --- NO CLIENTE COPPEL
RETURNING CHAR(5),   --- CODIGO DE RETORNO 
          CHAR(20),  --- NO CLIENTE COPPEL
          CHAR(100), --- CORREO ELECTRONICO
          CHAR(13);  --- TELEFONO MOVIL
       
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(80);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(80);
    DEFINE vCorreo      CHAR(100);
    DEFINE vCelular     CHAR(13);
    DEFINE vNoCteBanco  CHAR(9);
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '';
    LET vCodRet3     = '';
    LET vCorreo      = '';
    LET vCelular     = '';
    LET vNoCteBanco  = '';
	
	BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_conscorreocel.err";
        --TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, pCteCoppel, vCorreo, vCelular;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_conscorreocel.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
     IF pCteCoppel is null OR pCteCoppel = '' THEN
        LET vCodRet1 = '00110';
        LET vCorreo = '';
        LET vCelular = '';
        RETURN vCodRet1, pCteCoppel, vCorreo, vCelular;
    END IF;
    
    SELECT numctebco
      INTO vNoCteBanco
      FROM bdinteg:si_enrol_cplbot
     WHERE numctecpl = pCteCoppel;
     
    IF vNoCteBanco is null OR vNoCteBanco = '' THEN 
        LET vCodRet1 = '00111';
        LET vCorreo = '';
        LET vCelular = '';
        RETURN vCodRet1, pCteCoppel, vCorreo, vCelular;
    END IF;
    
    SELECT NVL(correo_elec,'')
      INTO vCorreo
      FROM bdinteg:si_correos
     WHERE numcte = vNoCteBanco
       AND tipo_correo = 2
       AND status_correo = 'A';
       
    SELECT NVL(telefono,'')
      INTO vCelular
      FROM bdinteg:si_telefonos
     WHERE numcte = vNoCteBanco
       AND tipo_tel = 2
       AND status_tel = 'A'
       AND verificado = 'V'
       AND secuencia = ( SELECT MAX(secuencia)
                           FROM bdinteg:si_telefonos 
                          WHERE numcte = vNoCteBanco
                            AND tipo_tel = 2
                            AND status_tel = 'A'
                            AND verificado = 'V');
                            
    IF ( vCelular is null OR vCelular = '' ) THEN
        SELECT NVL(telefono,'')
          INTO vCelular
          FROM bdinteg:si_telefonos_actual
         WHERE numcte = vNoCteBanco
           AND tipo_tel = 2
           AND status_tel = 'A'
           AND tel_confirmado = '1';
    END IF;
        
    END; 
    
    RETURN vCodRet1, pCteCoppel, vCorreo, vCelular;
    
END PROCEDURE;