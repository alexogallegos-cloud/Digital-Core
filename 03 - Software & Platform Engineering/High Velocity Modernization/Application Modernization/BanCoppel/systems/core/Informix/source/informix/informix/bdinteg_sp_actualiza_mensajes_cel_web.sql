CREATE PROCEDURE "informix".sp_actualiza_mensajes_cel_web( pNumCte CHAR(20), -- NO. CLIENTE
                                                       pSmsCel CHAR(1) ) -- INDICADOR SMS
RETURNING CHAR(5); -- CODIGO DE RETORNO
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vcTipoMns        CHAR(1);
    DEFINE vcPlanMns        CHAR(10);
    DEFINE vcProcMns        CHAR(1);
    DEFINE vCodRetRegEven   CHAR(5);
    
    LET vcodret1 = '00000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte     = 0;
    LET vcTipoMns      = '';
    LET vcPlanMns      = '';
    LET vcProcMns      = '';
    LET vCodRetRegEven = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_mensajes_cel.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_mensajes_cel.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pNumCte is null OR pNumCte = '' ) OR
       ( pSmsCel is null OR pSmsCel = '' ) THEN
        LET vcodret1 = '00110'; --- DATOS INSUFICIENTES
        RETURN vcodret1;
    END IF;

    -- // VALIDA EXISTA NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_ctepf
     WHERE numcte = pNumCte;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '00104'; --- NO DE CLIENTE NO EXISTE
        RETURN vcodret1;
    END IF;
    
    UPDATE si_ctepf
       SET sms_cel = pSmsCel
     WHERE numcte = pNumCte;
     
    IF ( ( dbinfo('sqlca.sqlerrd2') = 0 ) AND pSmsCel = 'S' ) THEN
        -- // OBTIENE PARAMETROS PARA MENSAJE DE LATINIA
        SELECT valor
          INTO vcTipoMns
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 85;
        
        SELECT valor
          INTO vcPlanMns
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 86;
           
        SELECT valor
          INTO vcProcMns
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 87;
             
        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
        ( vcTipoMns, vcPlanMns, pNumCte, '', '', vcProcMns, '', CURRENT, '', '', '', '', '', '', '', '', '', '', 1, 0, 0, 0, 0, CURRENT, '' )
        INTO vCodRetRegEven;
    END IF;
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;