CREATE PROCEDURE "informix".sp_cte_ilocalilzable( pNumCte       CHAR(20),  -- NO. CLIENTE
                                                  pCanal        SMALLINT,  -- CANAL
                                                  pSucursal     CHAR(4),   -- SUCURSAL
                                                  pUserInsert   CHAR(8) )  -- USUARIO
RETURNING CHAR(5); -- CODIGO DE RETORNO
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vExisteCte   INTEGER;
    
    LET vcodret1   = '000';
    LET vcodret2   = '000';
    LET vcodret3   = '';
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = '';
    LET vExisteCte = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cte_ilocalilzable.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cte_ilocalilzable.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pNumCte is null OR pNumCte = '' ) THEN
        LET vcodret1 = '110'; --- DATOS INSUFICIENTES
        RETURN vcodret1;
    END IF;

    -- // VALIDA EXISTA NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '104'; --- NO DE CLIENTE NO EXISTE
        RETURN vcodret1;
    END IF;
    
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_bitacora_tel
     WHERE numcte = pNumCte;
     
    IF vExisteCte = 0 THEN
        INSERT INTO bdinteg:"informix".si_bitacora_tel
        ( numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper )
        VALUES
        ( pNumCte, '9', '9', pCanal, pSucursal, pUserInsert, CURRENT );
    ELSE 
        UPDATE bdinteg:"informix".si_bitacora_tel
           SET ind_telefono = '9',
               ind_correo   = '9',
               canal        = pCanal,
               sucursal     = pSucursal,
               user_insert  = pUserInsert,
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    END IF;
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;