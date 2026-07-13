CREATE PROCEDURE "informix".sp_permite_mensajes_cel( pNumCte CHAR(20) ) -- NO. CLIENTE
RETURNING CHAR(5), -- CODIGO DE RETORNO
          CHAR(1); -- INDICADOR DE MENSAJES
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vsms_cel     CHAR(1);
    DEFINE vExisteCte   INTEGER;
    
    LET vcodret1   = '000';
    LET vcodret2   = '000';
    LET vcodret3   = '';
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = '';
    LET vsms_cel   = '';
    LET vExisteCte = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_permite_mensajes_cel.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vsms_cel;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_permite_mensajes_cel.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pNumCte is null OR pNumCte = '' ) THEN
        LET vcodret1 = '110'; --- DATOS INSUFICIENTES
        RETURN vcodret1, vsms_cel;
    END IF;

    -- // VALIDA EXISTA NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_ctepf
     WHERE numcte = pNumCte;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '104'; --- NO DE CLIENTE NO EXISTE
        RETURN vcodret1, vsms_cel;
    END IF;
    
    SELECT sms_cel
      INTO vsms_cel
      FROM bdinteg:"informix".si_ctepf
     WHERE numcte = pNumCte;
    
    IF vsms_cel is null OR vsms_cel = '' THEN
        LET vsms_cel = 'N';
    END IF;
    
    END; 
    
    RETURN vcodret1, vsms_cel;
    
END PROCEDURE;