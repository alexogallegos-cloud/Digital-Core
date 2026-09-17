CREATE PROCEDURE "informix".bm_inicializa_diario( pEmpresa CHAR(3) ) --- Empresa
RETURNING CHAR(5) AS vCodRet1; --- Codigo de Retorno
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vctemin          CHAR(20);
    DEFINE vctemax          CHAR(20);
    
    LET Sql_Err	 = 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '00000';
    LET vCodRet2 = '00000';
    LET vCodRet3 = '';
    LET vctemin  = '';
    LET vctemax  = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_inicializa_diario.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_inicializa_diario.out";
    --- TRACE ON;
    
    IF pEmpresa is null OR pEmpresa = '' THEN
        LET vCodRet1 = '11111';
        RETURN vCodRet1;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vctemin, vctemax
      FROM bdinteg:"informix".si_bm_usuarios;
    
    -- // INICIAIZA LOS ACCESOS DE LOS CLIENTES
    UPDATE bdinteg:"informix".si_bm_usuarios
       SET numaccesos = 0
     WHERE numcte BETWEEN vctemin AND vctemax;
     
    -- // MUEVE BITACORA DEL DIA A BIATCORA HISTORICA
    INSERT INTO bdinteg:"informix".si_bm_bitacorahist
    SELECT * FROM bdinteg:"informix".si_bm_bitacora;
    
    -- // ELIMIA REGISTROS DE BITACORA DEL DIA
    TRUNCATE TABLE bdinteg:"informix".si_bm_bitacora;
    
    -- // INICIALIZA SESSION TOKEN
    UPDATE bdibpi:"informix".tkn_parametros
       SET valor = 0
     WHERE id_param = '52';
    
    END; 

    RETURN vCodRet1;

END PROCEDURE;