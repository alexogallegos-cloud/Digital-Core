CREATE PROCEDURE "informix".sp_altamasivaempnet_procesa_pba( pidempresa CHAR(3), pnumcte CHAR(9), pnombrearchivo CHAR(30) )
RETURNING CHAR(5); 
       
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE vcCodRet4    CHAR(5);
    DEFINE vcCodRet5    CHAR(5);
    DEFINE vcFolio      CHAR(16);
    DEFINE vcMensaje    CHAR(50);
    DEFINE vusuario     CHAR(8);
    DEFINE vcNumEmp     CHAR(3);
    DEFINE viExisteEmp  SMALLINT;
    DEFINE viExisteCte  SMALLINT;
    
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET vcDescErr   = '';
    LET vcCodRet    = '';
    LET vcCodRet2   = '';
    LET vcCodRet3   = '';
    LET vcCodRet4   = '';
    LET vcCodRet5   = '';
    LET vcFolio     = '';
    LET vcMensaje   = '';
    LET vusuario    = USER;
    LET vcNumEmp    = '';
    LET viExisteEmp = 0;
    LET viExisteCte = 0;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_procesa.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_procesa.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            RETURN vcCodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // VALIDA EL NUMERO DE EMPRESA
    LET vcNumEmp  = SUBSTR(pNombreArchivo, 2, 3);
        
    IF pidempresa <> vcNumEmp THEN
        LET pidempresa = vcNumEmp;
    END IF;
    
    SELECT COUNT(*)
      INTO viExisteEmp
      FROM bdicheq:sc_nominaempresas 
     WHERE codigo = pidempresa;
     
    IF viExisteEmp = 0 THEN
        LET vcCodRet = '188';
        RETURN vcCodRet;
    END IF;
    
    -- // VALIDA QUE EL CLIENTE SEA PERSONA MORAL
    SELECT COUNT(cte.numcte)
      INTO viExisteCte
      FROM bdinteg:si_cliente cte
     INNER JOIN bdinteg:si_tipper tpo ON cte.tpo_persona = tpo.tpo_persona
     WHERE cte.empresa = '001'
       AND cte.numcte = pnumcte
       AND tpo.es_fisica = "N";
    
    IF viExisteCte = 0 THEN
        LET vcCodRet = '104';
        RETURN vcCodRet;
    END IF;
    
    CALL "informix".sp_altamasivaempnet_carga(pnombrearchivo)
    RETURNING vcCodRet4;
    
    IF vcCodRet4 = '000' THEN        
        CALL "informix".sp_altamasivaempnet_registra(pidempresa, pnumcte, vusuario, pnombrearchivo) 
        RETURNING vcCodRet5, vcMensaje;

        IF vcCodRet5 = '00000' THEN
            LET vcCodRet = '000';
        ELSE
            LET vcCodRet = vcCodRet5;
        END IF
    ELSE
        LET vcCodRet = vcCodRet4;
    END IF;

    RETURN vcCodRet;

    END;

END PROCEDURE;