CREATE PROCEDURE "informix".sp_altamasivaempnet_busca_pba()
RETURNING CHAR(5);
    
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    
    DEFINE vcCodEmpresa     CHAR(3);
    DEFINE vcNombreArchivo  CHAR(30);
    DEFINE vcNumCte         CHAR(9);
    DEFINE vcCodRetAlta     CHAR(5);
    
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET vcDescErr   = '';
    LET vcCodRet    = '000';
    LET vcCodRet2   = '';
    LET vcCodRet3   = '';
    
    LET vcCodEmpresa    = '';
    LET vcNombreArchivo = '';
    LET vcNumCte        = '';
    LET vcCodRetAlta    = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_busca.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_busca.err";
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
    
    -- // PROCESA LOS ARCHIVOS QUE ESTEN PENDIENTES
    FOREACH WITH HOLD 
        SELECT alta.cod_empresa, alta.nombre_archivo, emp.numcte
          INTO vcCodEmpresa, vcNombreArchivo, vcNumCte
          FROM bdinteg:si_altamasivaempnet_ctrl alta,
               bdicheq:sc_nominaempresas emp
         WHERE alta.cod_empresa = emp.codigo
           AND alta.status = '0'
           
        CALL sp_altamasivaempnet_procesa( vcCodEmpresa, vcNumCte, vcNombreArchivo )
        RETURNING vcCodRetAlta;
    END FOREACH;
    
    RETURN vcCodRet;
    
    END;
    
END PROCEDURE;