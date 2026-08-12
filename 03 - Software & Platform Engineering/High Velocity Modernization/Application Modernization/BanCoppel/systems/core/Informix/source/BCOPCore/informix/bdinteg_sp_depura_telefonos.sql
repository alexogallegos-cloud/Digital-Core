CREATE PROCEDURE "informix".sp_depura_telefonos( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE iTransacc    SMALLINT;
    DEFINE iContador    INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE cNumCte      CHAR(20);
    DEFINE iTipoTel     SMALLINT;
    DEFINE iMaxSec      SMALLINT;
    DEFINE iCuantos     SMALLINT;
    DEFINE cTelefono    CHAR(13);
    DEFINE iSecuencia   SMALLINT;
    DEFINE cExtension   CHAR(5);
    DEFINE iCarrier     SMALLINT;
    DEFINE iCanal       SMALLINT;
    DEFINE iContacto    SMALLINT;
    DEFINE cCofetel     CHAR(1);
    DEFINE dFecha       DATETIME YEAR TO SECOND;
    DEFINE cUser        CHAR(8);
    DEFINE cMovil       CHAR(1);
    DEFINE cStatus      CHAR(1);
    
    LET cCodRet    = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iIsamErr   = 0;
    LET cDescErr   = '';
    LET iTransacc  = 0;
    LET iContador  = 0;
    LET iContador2 = 0;
    LET cNumCte    = '';
    LET iTipoTel   = 0;
    LET iMaxSec    = 0;
    LET iCuantos   = 0;
    LET cTelefono  = '';
    LET iSecuencia = 0;
    LET cExtension = '';
    LET iCarrier   = 0;
    LET iCanal     = 0;
    LET iContacto  = 0;
    LET cCofetel   = '';
    LET dFecha     = '';
    LET cUser      = '';
    LET cMovil     = '';
    LET cStatus    = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/informix/jivan/sp_depura_telefonos.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, iContador, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/jivan/sp_depura_telefonos.out";
    --- TRACE ON;
    
    UPDATE STATISTICS MEDIUM FOR TABLE si_ctesdepurados;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTIENE CLIENTES A PROCESAR
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO cNumCte
          FROM si_telefonos
         WHERE numcte NOT IN( SELECT numcte FROM si_ctesdepurados )
           AND tipo_tel IN( 1, 2, 3, 4 ) 
           AND status_tel = 'A'
         
        -- // ABRE TRANSACCION
        BEGIN WORK;
        LET iTransacc = 1;
        
        -- // TIPOS DE TELEFONO POR CLIENTE
        FOREACH WITH HOLD
            SELECT UNIQUE tipo_tel
              INTO iTipoTel
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND status_tel = 'A'
        
            SELECT MAX(secuencia)
              INTO iMaxSec
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND status_tel = 'A';
               
            -- // VALIDACIONES EN TABLA DE TELEFONOS
            SELECT COUNT(*)
              INTO iCuantos
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND secuencia < iMaxSec
               AND status_tel = 'A';
           
            IF iCuantos > 0 THEN               
                UPDATE si_telefonos
                   SET status_tel = 'C'
                 WHERE numcte = cNumCte
                   AND tipo_tel = iTipoTel
                   AND secuencia < iMaxSec
                   AND status_tel = 'A';
            END IF;
            
            -- // VALIDACIONES EN TABLA DE TELEFONOS ACTUALES
            SELECT telefono, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel
              INTO cTelefono, cExtension, iCarrier, iCanal, iContacto, cCofetel, dFecha, cUser, cMovil, cStatus
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND secuencia = iMaxSec;
            
            SELECT COUNT(*)
              INTO iCuantos
              FROM si_telefonos_actual
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND secuencia = iMaxSec
               AND status_tel = 'A'
               AND telefono = cTelefono
               AND extension = cExtension
               AND carrier = iCarrier
               AND canal = iCanal
               AND contacto = iContacto
               AND cofetel = cCofetel
               AND fecha_hora = dFecha
               AND user_insert = cUser
               AND movil_fijo = cMovil
               AND status_stel = cStatus;
           
            IF iCuantos = 0 THEN 
                SELECT COUNT(*)
                  INTO iCuantos
                  FROM si_telefonos_actual
                 WHERE numcte = cNumCte
                   AND tipo_tel = iTipoTel;
                   
                IF iCuantos > 0 THEN 
                    UPDATE si_telefonos_actual
                       SET secuencia = iMaxSec,
                           status_tel = 'A',
                           telefono = cTelefono,
                           extension = cExtension,
                           carrier = iCarrier,
                           canal = iCanal,
                           contacto = iContacto,
                           cofetel = cCofetel,
                           fecha_hora = dFecha,
                           user_insert = cUser,
                           movil_fijo = cMovil,
                           status_stel = cStatus
                     WHERE numcte = cNumCte
                       AND tipo_tel = iTipoTel;
                ELSE
                    INSERT INTO si_telefonos_actual VALUES
                    ( pEmpresa, cNumCte, cTelefono, iTipoTel, 'A', iMaxSec, cExtension, iCarrier, iCanal, iContacto, cCofetel, dFecha, cUser, cMovil, cStatus );
                END IF;
                
                LET iContador2 = iContador2 + 1;
            END IF;
            
            LET iCuantos   = 0;
            LET iTipoTel   = 0;
            LET iMaxSec    = 0;
            LET cTelefono  = '';
            LET iSecuencia = 0;
            LET cExtension = '';
            LET iCarrier   = 0;
            LET iCanal     = 0;
            LET iContacto  = 0;
            LET cCofetel   = '';
            LET dFecha     = '';
            LET cUser      = '';
            LET cMovil     = '';
            LET cStatus    = '';
        END FOREACH;
        
        -- // REGISTRA CLIENTE PROCESADO
        INSERT INTO si_ctesdepurados VALUES(cNumCte);
        
        LET iContador = iContador + 1;
        
        -- // CIERRA TRANSACCION
        COMMIT WORK;
        LET iTransacc = 0;
        
        LET cNumCte = '';
    END FOREACH;
    
    END;
    
    RETURN cCodRet, iContador, iContador2;
    
END PROCEDURE;