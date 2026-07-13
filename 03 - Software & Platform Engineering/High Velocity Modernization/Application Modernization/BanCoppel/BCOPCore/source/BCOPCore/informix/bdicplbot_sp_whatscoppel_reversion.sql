CREATE PROCEDURE "informix".sp_whatscoppel_reversion( pCteCoppel CHAR(9),  --- NO CLIENTE COPPEL
                                                      pFolio     CHAR(16) ) --- FOLIO SUC
RETURNING CHAR(5),  --- CODIGO DE RETORNO 
          CHAR(20); --- NO CLIENTE COPPEL
       
    DEFINE Sql_Err     INTEGER;
    DEFINE Isam_Err    INTEGER;
    DEFINE Desc_Err    CHAR(80);
    DEFINE vCodRet1    CHAR(5);
    DEFINE vCodRet2    CHAR(5);
    DEFINE vCodRet3    CHAR(80);
    DEFINE vEnTransacc SMALLINT;
    DEFINE vReversado  SMALLINT;
    DEFINE vSucursal   CHAR(4);
    DEFINE vUsuario    CHAR(8);
    DEFINE vEmpresa    CHAR(3);
    DEFINE vCodRetRev  CHAR(5);
    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '00000';
    LET vCodRet2    = '';
    LET vCodRet3    = '';
    LET vEnTransacc = 0;
    LET vReversado  = 0;
    LET vSucursal   = '';
    LET vUsuario    = '';
    LET vEmpresa    = '001'; 
    LET vCodRetRev  = '';
	
	BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_reversion.err";
        --TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN vCodRet1, pCteCoppel;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vEnTransacc = 1;
    END EXCEPTION WITH resume;
    
    --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_reversion.out";
    --TRACE ON;
    
    IF vEnTransacc = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pCteCoppel is null OR pCteCoppel = '' ) OR
       ( pFolio is null OR pFolio = '' OR LENGTH(pFolio) <> 16 ) THEN
        LET vCodRet1 = '00110';
        IF vEnTransacc = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, pCteCoppel;
    END IF;
    
    SELECT COUNT(*)
      INTO vReversado
      FROM bdicheq:sc_movdia
     WHERE cancelad = 'S'
       AND folio_suc = pFolio;
       
    IF vReversado > 0 THEN
        LET vCodRet1 = '00000';
    ELSE
        SELECT valor
          INTO vSucursal
          FROM bdicheq:sc_param
         WHERE empresa = vEmpresa
           AND codparam = 'SucursalCoppelBot';
           
        SELECT valor
          INTO vUsuario
          FROM bdicheq:sc_param
         WHERE empresa = vEmpresa
           AND codparam = 'UsuarioCoppelBot';
           
        IF ( vSucursal is null OR vSucursal = '' OR LENGTH(vSucursal) <> 4 ) OR 
           ( vUsuario is null OR vUsuario = '' OR LENGTH(vUsuario) <> 8 ) THEN
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vCodRet1 = '00111';
            RETURN vCodRet1, pCteCoppel;
        END IF;
        
        EXECUTE PROCEDURE bdicheq:reversion(vEmpresa, vSucursal, vUsuario, pFolio, 'A')
        INTO vCodRetRev;
        
        IF vCodRetRev <> '000' THEN
            LET vCodRet1 = '00999';
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, pCteCoppel;
        END IF;
    END IF;
    
    IF vEnTransacc = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK; 
    END IF;
    
    END; 
    
    RETURN vCodRet1, pCteCoppel;
    
END PROCEDURE;