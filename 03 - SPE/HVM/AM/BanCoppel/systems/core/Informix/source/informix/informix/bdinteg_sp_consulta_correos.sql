CREATE PROCEDURE "informix".sp_consulta_correos( pEmpresa    CHAR(3),
                                                 pNumCte     CHAR(20),
                                                 pTipoCorreo SMALLINT,
                                                 pConsulta   CHAR(1) )
RETURNING CHAR(5)   AS vcodret1,
          CHAR(100) AS vCorreoElec,
          SMALLINT  AS vTipoCorreo,
          CHAR(1)   AS vStatusCorreo;

    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);

    DEFINE vExisteCte       INTEGER;
    DEFINE vfecha_insert    DATE;
    DEFINE vExisteCorreo    SMALLINT;
    DEFINE vMaxSec          SMALLINT;
    DEFINE vCorreoElec      CHAR(100);
    DEFINE vTipoCorreo      SMALLINT;
    DEFINE vStatusCorreo    CHAR(1);

    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';

    LET vExisteCte = 0;
    LET vfecha_insert = '';
    LET vExisteCorreo = 0;
    LET vMaxSec = 0;
    LET vCorreoElec = '';
    LET vTipoCorreo = 0;
    LET vStatusCorreo = '';

    BEGIN

    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_correos.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vCorreoElec, vTipoCorreo, vStatusCorreo;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_correos.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR
       (pNumCte is null OR pNumCte = '') OR
       (pTipoCorreo is null OR pTipoCorreo = 0) OR
       (pConsulta is null OR pConsulta = '') THEN
        LET vcodret1 = '110';
        RETURN vcodret1, vCorreoElec, vTipoCorreo, vStatusCorreo;
    END IF;

    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '104';
        RETURN vcodret1, vCorreoElec, vTipoCorreo, vStatusCorreo;
    END IF;

    -- // OBTIENE INFORMACION DE ACUERDO AL TIPO DE CONSULTA
    IF pConsulta = 0 THEN
        -- // CORREO MAS RECIENTE DEL TIPO ESPECIFICADO
        SELECT NVL(correo_elec, ' '), tipo_correo, status_correo
          INTO vCorreoElec, vTipoCorreo, vStatusCorreo
          FROM bdinteg:"informix".si_correos
         WHERE numcte = pNumCte
           AND tipo_correo = pTipoCorreo
           AND status_correo = 'A';

        RETURN vcodret1, vCorreoElec, vTipoCorreo, vStatusCorreo;
    ELIF pConsulta = 1 THEN
        -- // TODOS LOS CORREOS DEL TIPO ESPECIFICADO
        FOREACH
            SELECT NVL(correo_elec, ' '), tipo_correo, status_correo
              INTO vCorreoElec, vTipoCorreo, vStatusCorreo
              FROM bdinteg:"informix".si_correos
             WHERE numcte = pNumCte
               AND tipo_correo = pTipoCorreo
             ORDER BY secuencia DESC

            RETURN vcodret1, vCorreoElec, vTipoCorreo, vStatusCorreo WITH RESUME;
        END FOREACH;
    ELIF pConsulta = 2 THEN
        -- // TODOS LOS CORREOS
        FOREACH
            SELECT NVL(correo_elec, ' '), tipo_correo, status_correo
              INTO vCorreoElec, vTipoCorreo, vStatusCorreo
              FROM bdinteg:"informix".si_correos
             WHERE numcte = pNumCte
             ORDER BY secuencia DESC

            RETURN vcodret1, vCorreoElec, vTipoCorreo, vStatusCorreo WITH RESUME;
        END FOREACH;
    ELSE
        -- // TIPO DE CONSULTA INVALIDO
        LET vcodret1 = '109';
        RETURN vcodret1, vCorreoElec, vTipoCorreo, vStatusCorreo;
    END IF;

    END;

END PROCEDURE;