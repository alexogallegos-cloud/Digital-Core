CREATE PROCEDURE "informix".sp_conspros_ctepf( pEmpresa CHAR(3), pNumCte CHAR(20) )
RETURNING CHAR(5),      -- CODIGO DE RETORNO
          CHAR(20),     -- NO. CLIENTE
          CHAR(26),     -- PRIMER NOMBRE
          CHAR(26),     -- SEGUNDO NOMBRE
          CHAR(26),     -- APELLIDO PATERNO
          CHAR(26),     -- APELLIDO MATERNO
          DATE,         -- FECHA DE NACIMIENTO
          CHAR(13),     -- RFC
          CHAR(20),     -- CURP
          CHAR(1),      -- SEXO
          CHAR(2),      -- EDO CIVIL
          CHAR(26),     -- APELLIDO CASADA
          CHAR(3),      -- NACIONALIDAD
          CHAR(18),     -- NO. FM3
          CHAR(3),      -- OCUPACION
          CHAR(2),      -- TIPO DE CASA
          CHAR(60),     -- DEPENDIENTES
          CHAR(2),      -- TIPO DE IDENTIFICACION
          CHAR(30),     -- NO. IDENTIFICACION
          CHAR(100);    -- CORREO ELECTRONICO

    DEFINE viSqlErr         INTEGER;
    DEFINE viIsamErr        INTEGER;
    DEFINE vcDescErr        CHAR(50);
    DEFINE vcCodRet         CHAR(5);
    DEFINE vcCodRet2        CHAR(5);
    DEFINE vcCodRet3        CHAR(50);
    
    DEFINE vcNumPros        CHAR(20);
    DEFINE vcNombre1        CHAR(26);
    DEFINE vcNombre2        CHAR(26);
    DEFINE vcApellPaterno   CHAR(26);
    DEFINE vcApellMaterno   CHAR(26);
    DEFINE vdFechaNac       DATE;
    DEFINE vcRfc            CHAR(13);
    DEFINE vcCurp           CHAR(20);
    DEFINE vcSexo           CHAR(1);
    DEFINE vcEdoCivil       CHAR(2);
    DEFINE vcApellCasada    CHAR(26);
    DEFINE vcNacionalidad   CHAR(3);
    DEFINE vcFM3            CHAR(18);
    DEFINE vcOcupacion      CHAR(3);
    DEFINE vcTipoCasa       CHAR(2);
    DEFINE vcDependientes   CHAR(60);
    DEFINE vcTipoId         CHAR(2);
    DEFINE vcNumId          CHAR(30);
    DEFINE vcCorreo         CHAR(100);
    
    LET viSqlErr       = 0;
    LET viIsamErr      = 0;
    LET vcDescErr      = 0;
    LET vcCodRet       = '00000';
    LET vcCodRet2      = '';
    LET vcCodRet3      = '';
    
    LET vcNumPros      = '';
    LET vcNombre1      = '';
    LET vcNombre2      = '';
    LET vcApellPaterno = '';
    LET vcApellMaterno = '';
    LET vdFechaNac     = '';
    LET vcRfc          = '';
    LET vcCurp         = '';
    LET vcSexo         = '';
    LET vcEdoCivil     = '';
    LET vcApellCasada  = '';
    LET vcNacionalidad = '';
    LET vcFM3          = '';
    LET vcOcupacion    = '';
    LET vcTipoCasa     = '';
    LET vcDependientes = '';
    LET vcTipoId       = '';
    LET vcNumId        = '';
    LET vcCorreo       = '';

    --- SET DEBUG FILE TO "/tmp/sp_conspros_ctepf.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/sp_conspros_ctepf.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet  = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            LET vcNumPros  = '';
            RETURN vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCurp, vcSexo, 
                   vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcOcupacion, vcTipoCasa, vcDependientes, vcTipoId, vcNumId, vcCorreo;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa is null OR pEmpresa = '' ) OR ( pNumCte  is null OR pNumCte = '' ) THEN
        LET vcCodRet = '00110';
        LET vcNumPros = '';
        RETURN vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCurp, vcSexo, 
               vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcOcupacion, vcTipoCasa, vcDependientes, vcTipoId, vcNumId, vcCorreo;
    END IF;
    
    SELECT numcte_pros
      INTO vcNumPros
      FROM pr_cliente
     WHERE numcte_pros = pNumCte;
     
    IF vcNumPros is null OR vcNumPros = '' OR vcNumPros <> pNumCte THEN
        LET vcCodRet = '00110';
        LET vcNumPros = '';
        RETURN vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCurp, vcSexo, 
               vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcOcupacion, vcTipoCasa, vcDependientes, vcTipoId, vcNumId, vcCorreo;
    END IF;
    
    SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, pf.fecha_nac, cte.rfc, pf.curp, pf.sexo, pf.estado_civil, cte.apell_casada, 
           pf.nacionalidad, pf.no_fm3, pf.profesion, pf.habita_en, cte.string2, pf.codidentifi, pf.numidentifi
      INTO vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCurp, vcSexo, vcEdoCivil, vcApellCasada,
           vcNacionalidad, vcFM3, vcOcupacion, vcTipoCasa, vcDependientes, vcTipoId, vcNumId 
      FROM pr_cliente cte
      INNER JOIN pr_ctepf pf ON ( pf.numcte_pros = cte.numcte_pros )
     WHERE cte.numcte_pros = vcNumPros;
      
     SELECT correo_elec
     INTO vcCorreo
     FROM pr_correos
     WHERE numcte_pros = vcNumPros
     AND status_correo = 'A';
     
    IF vcNombre1      is null THEN LET vcNombre1      = ''; END IF;
    IF vcNombre2      is null THEN LET vcNombre2      = ''; END IF;
    IF vcApellPaterno is null THEN LET vcApellPaterno = ''; END IF;
    IF vcApellMaterno is null THEN LET vcApellMaterno = ''; END IF;
    IF vdFechaNac     is null THEN LET vdFechaNac     = ''; END IF;
    IF vcRfc          is null THEN LET vcRfc          = ''; END IF;
    IF vcCurp         is null THEN LET vcCurp         = ''; END IF;
    IF vcSexo         is null THEN LET vcSexo         = ''; END IF;
    IF vcEdoCivil     is null THEN LET vcEdoCivil     = ''; END IF;
    IF vcApellCasada  is null THEN LET vcApellCasada  = ''; END IF;
    IF vcNacionalidad is null THEN LET vcNacionalidad = ''; END IF;
    IF vcFM3          is null THEN LET vcFM3          = ''; END IF;
    IF vcOcupacion    is null THEN LET vcOcupacion    = ''; END IF;
    IF vcTipoCasa     is null THEN LET vcTipoCasa     = ''; END IF;
    IF vcDependientes is null THEN LET vcDependientes = ''; END IF;
    IF vcTipoId       is null THEN LET vcTipoId       = ''; END IF;
    IF vcNumId        is null THEN LET vcNumId        = ''; END IF;
    IF vcCorreo       is null THEN LET vcCorreo       = ''; END IF;
    
    RETURN vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCurp, vcSexo, 
           vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcOcupacion, vcTipoCasa, vcDependientes, vcTipoId, vcNumId, vcCorreo;
    
    END;
    
END PROCEDURE;