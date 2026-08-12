CREATE PROCEDURE "informix".sp_consulta_telefonos( pEmpresa  CHAR(3),
                                                   pNumCte   CHAR(20),
                                                   pTipoTel  SMALLINT,
                                                   pConsulta CHAR(1) )
RETURNING CHAR(5)  AS vcodret1,
          CHAR(13) AS vTelefono,
          SMALLINT AS vTipoTel,
          SMALLINT AS vSecuencia,
          CHAR(1)  AS vStatus_Tel,
          CHAR(5)  AS vExtension,
          SMALLINT AS vCarrier,
          CHAR(20) AS vNombreCarrier,
          SMALLINT AS StatusValidacion;

    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);

    DEFINE vExisteCte       INTEGER;
    DEFINE vTelefono        CHAR(13);
    DEFINE vTipoTel         SMALLINT;
    DEFINE vStatus_Tel      CHAR(1);
    DEFINE vExtension       CHAR(5);
    DEFINE vCarrier         SMALLINT;
    DEFINE vContacto        SMALLINT;
    DEFINE vNombreCarrier   CHAR(30);
    DEFINE StatusValidacion SMALLINT;
    DEFINE vSecuencia       SMALLINT;
    DEFINE vCofetel         CHAR(1);

    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';

    LET vExisteCte       = 0;
    LET vTelefono        = '';
    LET vTipoTel         = 0;
    LET vStatus_Tel      = '';
    LET vExtension       = '';
    LET vCarrier         = 0;
    LET vContacto        = 0;
    LET vNombreCarrier   = '';
    LET StatusValidacion = 0;
    LET vSecuencia       = 0;
    LET vCofetel         = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_telefonos.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
        END IF;
    END EXCEPTION;

     --SET DEBUG FILE TO "/tmp/pruebasOptimizacion/bloque1/sp_consulta_telefonos_tasf.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR
       (pNumCte is null OR pNumCte = '') OR
       (pTipoTel is null OR pTipoTel = 0) THEN
        LET vcodret1 = '110'; --- DATOS INSUFICIENTES
        RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
    END IF;

    -- // VALIDA EXISTA NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte
     LIMIT 1;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '104'; --- NO DE CLIENTE NO EXISTE
        RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
    END IF;

    -- // OBTIENE INFORMACION DE ACUERDO AL TIPO DE CONSULTA
    IF pConsulta = '0' THEN
        -- // -- TELEFONO MAS RECIENTE DEL TIPO ESPECIFICADO
        SELECT telefono, tipo_tel, secuencia, status_tel, extension, carrier, contacto, cofetel
          INTO vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vContacto, vCofetel
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = pTipoTel
           AND status_tel = 'A';

        SELECT NVL(nombre_carrier, ' ')
          INTO vNombreCarrier
          FROM bdinteg:"informix".si_carriers
         WHERE cve_carrier = vCarrier;

        IF vNombreCarrier is null THEN
            LET vNombreCarrier = '';
        END IF;
        
        IF vCofetel = 'V' THEN
            LET StatusValidacion = 1;
        ELSE
            LET StatusValidacion = 0;
        END IF;

        RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
    ELIF pConsulta = '1' THEN
        -- // TODOS LOS TELEFONOS DEL TIPO ESPECIFICADO
        FOREACH
            SELECT telefono, tipo_tel, secuencia, status_tel, extension, carrier, contacto, cofetel
              INTO vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vContacto, vCofetel
              FROM bdinteg:"informix".si_telefonos
             WHERE numcte = pNumCte
               AND tipo_tel = pTipoTel
             ORDER BY secuencia DESC

            SELECT NVL(nombre_carrier, ' ')
              INTO vNombreCarrier
              FROM bdinteg:"informix".si_carriers
             WHERE cve_carrier = vCarrier;

            IF vNombreCarrier is null THEN
                LET vNombreCarrier = '';
            END IF;
            
            IF vCofetel = 'V' THEN
                LET StatusValidacion = 1;
            ELSE
                LET StatusValidacion = 0;
            END IF;

            RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion WITH RESUME;
        END FOREACH;
    ELIF pConsulta = '2' THEN
        -- // TODOS LOS TELEFONOS
        FOREACH
            SELECT telefono, tipo_tel, secuencia, status_tel, extension, carrier, contacto, cofetel
              INTO vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vContacto, vCofetel
              FROM bdinteg:"informix".si_telefonos
             WHERE numcte = pNumCte
             ORDER BY secuencia DESC

            SELECT NVL(nombre_carrier, ' ')
              INTO vNombreCarrier
              FROM bdinteg:"informix".si_carriers
             WHERE cve_carrier = vCarrier;

            IF vNombreCarrier is null THEN
                LET vNombreCarrier = '';
            END IF;
            
            IF vCofetel = 'V' THEN
                LET StatusValidacion = 1;
            ELSE
                LET StatusValidacion = 0;
            END IF;

            RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion WITH RESUME;
        END FOREACH;
    ELSE
        -- // TIPO DE CONSULTA INVALIDO
        LET vcodret1 = '109';
        RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
    END IF;

    END;

END PROCEDURE;