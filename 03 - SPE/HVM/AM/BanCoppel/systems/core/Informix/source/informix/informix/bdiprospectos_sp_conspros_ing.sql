CREATE PROCEDURE "informix".sp_conspros_ing( pEmpresa CHAR(3), pNumCte CHAR(20) )
RETURNING CHAR(5),       -- CODIGO DE RETORNO
          CHAR(20),      -- NO. CLIENTE
          CHAR(60),      -- EMPRESA DE TRABAJO
          CHAR(2),       -- PUESTO ESPECIAL
          CHAR(3),       -- PUESTO
          DECIMAL(14,2), -- INGRESO MENSUAL
          INTEGER;       -- PERIOCIDAD


    DEFINE viSqlErr         INTEGER;
    DEFINE viIsamErr        INTEGER;
    DEFINE vcDescErr        CHAR(50);
    DEFINE vcCodRet         CHAR(5);
    DEFINE vcCodRet2        CHAR(5);
    DEFINE vcCodRet3        CHAR(50);

    DEFINE vcNumPros        CHAR(20);
    DEFINE vcNomEmpresa     CHAR(60);
    DEFINE vcPuestoEsp      CHAR(2);
    DEFINE vcPuesto         CHAR(3);
    DEFINE vdIngreso        DECIMAL(14,2);
    DEFINE viPeriocidad     INTEGER;

    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = 0;
    LET vcCodRet     = '00000';
    LET vcCodRet2    = '';
    LET vcCodRet3    = '';

    LET vcNumPros    = '';
    LET vcNomEmpresa = '';
    LET vcPuestoEsp  = '';
    LET vcPuesto     = '';
    LET vdIngreso    = 0.00;
    LET viPeriocidad = 0;

    --- SET DEBUG FILE TO "/tmp/sp_conspros_ing.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/sp_conspros_ing.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet  = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            LET vcNumPros  = '';
            RETURN vcCodRet, vcNumPros, vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF ( pEmpresa is null OR pEmpresa = '' ) OR ( pNumCte  is null OR pNumCte = '' ) THEN
        LET vcCodRet = '00110';
        LET vcNumPros = '';
        RETURN vcCodRet, vcNumPros, vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad;
    END IF;

    SELECT numcte_pros
      INTO vcNumPros
      FROM pr_cliente
     WHERE numcte_pros = pNumCte;

    IF vcNumPros is null OR vcNumPros = '' OR vcNumPros <> pNumCte THEN
        LET vcCodRet = '00110';
        LET vcNumPros = '';
        RETURN vcCodRet, vcNumPros, vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad;
    END IF;

    SELECT nombre_empresa, claveopcionpuesto, clavesubopcionpuesto, ingreso_mensual, periosidad
      INTO vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad
      FROM pr_ingresos
     WHERE numcte_pros = vcNumPros
       AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM pr_ingresos WHERE numcte_pros = vcNumPros);

    IF vcNomEmpresa is null THEN LET vcNomEmpresa = '';    END IF;
    IF vcPuestoEsp  is null THEN LET vcPuestoEsp  = '';    END IF;
    IF vcPuesto     is null THEN LET vcPuesto     = '';    END IF;
    IF vdIngreso    is null THEN LET vdIngreso    = 0.00;  END IF;
    IF viPeriocidad is null THEN LET viPeriocidad = 0;     END IF;

    RETURN vcCodRet, vcNumPros, vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad;

    END;

END PROCEDURE;