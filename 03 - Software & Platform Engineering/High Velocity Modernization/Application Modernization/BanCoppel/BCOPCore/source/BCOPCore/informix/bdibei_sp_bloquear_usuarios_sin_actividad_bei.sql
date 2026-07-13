CREATE PROCEDURE "informix".sp_bloquear_usuarios_sin_actividad_bei()
RETURNING CHAR(5) AS codigo, CHAR(65) AS mensaje;
-- ************************************************************************************************************************************************************************
-- DESCRIPCION: SP que realizara un cambio de estatus (BLOQUEO) a aquellos usuarios sin actividad en la banca empresarial 
--              durante un periodo de tiempo, con el objetivo de denegar el acceso y disminuir riesgos de seguridad con usuarios activos sin usar.
--              Reglas de negocio:
--                1.- Se bloquearan solo usuarios operadores que esten con un estatus ACTIVO (30) y tengan token asociado
--                2.- El estatus al que se cambiaran aquellos usuarios sin actividad es 70 (BLOQUEADO)
--                3.- El periodo de inactividad de los usuarios sera de maximo 1 anio, pasado ese tiempo se bloqueara
--                4.- Se cambiaran los estatus de los tokens asociados a aquellos usuarios a bloquear, actualizando el estatus a 170 (BLOQUEADO)
--                5.- Ambas tablas (bdibei:bei_token y bdibpi:tkn_nseries) sufriran el cambio de estatus para que exista cohesion al momento de desbloquear
--                6.- Se debera registrar los cambios de estatus (historico) del token y usuario en las tablas bdibei:bei_cambiostusuario y bdibpi:tkn_status_token
--              La referencia del id de estatus que se tomaron provienen de la tabla bdinteg:si_bpistatus
-- Autor: Marco Tinajero
-- FECHA : 28/02/2022
-- SOLICITO : Armando Barrientos
-- ESQUEMA DE BD: bdibei
-- ************************************************************************************************************************************************************************

    -- VARIABLES DE CONTROL
    DEFINE iSqlErr              INTEGER;
    DEFINE cCodRet              CHAR(5);
    DEFINE cCodRet2             CHAR(5);
    DEFINE cMensaje             CHAR(100);
    DEFINE cMensajeEjec         CHAR(50);
    DEFINE cRegistroEjec        CHAR(50);
    DEFINE iTransaccion         INTEGER;

    -- VARIABLES DE SELECT INTO
    DEFINE iUsuario             INTEGER;
    DEFINE cNumCliente          CHAR(9);
    DEFINE vNumTokenAsociado    VARCHAR(10);
    DEFINE cNumTokenSerial      CHAR(10);
    DEFINE dFechaUltimoAcceso   DATE;
    DEFINE iTotalRegistros      INTEGER;
    DEFINE sIdEstatusUsr        SMALLINT;
    DEFINE sIdEstatusTknAsoc    SMALLINT;
    DEFINE sIdEstatusTknSerial  SMALLINT;

    -- VARIABLES DE EJECUCION
    DEFINE sEstatusBloqueoUsr   SMALLINT;
    DEFINE sEstatusBloqueoTkn   SMALLINT;
    DEFINE cSucursal            CHAR(4);
    DEFINE cUsuarioPortal       CHAR(8);
    DEFINE cDireccionIpGenerica CHAR(15);
    DEFINE cCanal               CHAR(2);
    DEFINE iContandor           INTEGER;

    -- INIT VARIABLES
    LET iSqlErr                 = 0;
    LET cCodRet                 = '00000';
    LET cCodRet2                = '';
    LET cMensaje                = '';
    LET cMensajeEjec            = '';
    LET cRegistroEjec           = '';
    LET iTransaccion            = 0;

    LET iUsuario                = 0;
    LET cNumCliente             = '';
    LET vNumTokenAsociado       = '';
    LET cNumTokenSerial         = '';
    LET dFechaUltimoAcceso      = TODAY;
    LET iTotalRegistros         = 0;
    LET sIdEstatusUsr           = 0;
    LET sIdEstatusTknAsoc       = 0;
    LET sIdEstatusTknSerial     = 0;

    -- ID de estatus 70 Bloqueo de Usuario Operador
    LET sEstatusBloqueoUsr      = 70;
    -- ID de estatus 170 Bloqueo de Token
    LET sEstatusBloqueoTkn      = 170;
    LET cSucursal               = '5008';
    LET cUsuarioPortal          = 'transBEI';
    LET cDireccionIpGenerica    = '0.0.0.0';
    LET cCanal                  = '03';
    LET iContandor              = 0;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr != 0 THEN
                LET cCodRet = '00001';
                LET cMensaje = 'OCURRIO UN ERROR SQL ' || iSqlErr || ' en '||TRIM(cMensajeEjec) || ' ' || TRIM(cRegistroEjec);

                ROLLBACK WORK;

                RETURN cCodRet, cMensaje;

            END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

        -- COUNT total de usuarios con inactividad en empresanet
        SELECT SUM(usuarios.total_usuarios) AS total_usuarios_sin_actividad
        INTO iTotalRegistros
        FROM (
            -- USUARIOS QUE INGRESARON A LA BANCA y TENGAN TOKEN
            SELECT COUNT(usu.id_usuario) AS total_usuarios
            FROM bdibei:"informix".bei_usuario usu
                INNER JOIN bdibei:"informix".bei_token tkn ON tkn.num_cliente = usu.num_cliente AND tkn.id_usuario = usu.id_usuario
                INNER JOIN bdibpi:"informix".tkn_nseries tkns ON tkns.ns_token = tkn.ns_token 
            WHERE usu.f_ultimo_acceso < (MDY(MONTH(TODAY), DAY(TODAY), YEAR(TODAY)) - 1 UNITS YEAR) --FECHA ACTUAL MENOS UN ANIO
                AND usu.id_status = 30 --SOLO USRS ACTIVOS
                AND usu.id_tipo_usuario = 2 --SOLO USRS OPERADORES
            UNION
            -- USUARIOS QUE NUNCA INGRESARON A LA BANCA Y TENGAN TOKEN
            SELECT COUNT(usu.id_usuario) AS total_usuarios
            FROM bdibei:"informix".bei_usuario usu 
                INNER JOIN bdibei:"informix".bei_token tkn ON tkn.num_cliente = usu.num_cliente AND tkn.id_usuario = usu.id_usuario
                INNER JOIN bdibpi:"informix".tkn_nseries tkns ON tkns.ns_token = tkn.ns_token 
            WHERE usu.f_ultimo_acceso IS NULL
                AND usu.f_registro < (MDY(MONTH(TODAY), DAY(TODAY), YEAR(TODAY)) - 1 UNITS YEAR) --FECHA ACTUAL MENOS UN ANIO
                AND usu.id_status = 30 --SOLO USRS ACTIVOS
                AND usu.id_tipo_usuario = 2 --SOLO USRS OPERADORES
        ) AS usuarios;

        -- Validar el total de registros a bloquear
        IF iTotalRegistros = 0 THEN
            LET cCodRet = '00000';
            LET cMensaje = 'PROCESO EXITOSO - NO HAY ACTUALIZACIONES';

            RETURN cCodRet, cMensaje;
        END IF;

        BEGIN WORK;

            FOREACH WITH HOLD
                -- USUARIOS QUE INGRESARON A LA BANCA y TENGAN TOKEN
                SELECT 
                    usu.id_usuario, 
                    usu.id_status, 
                    usu.num_cliente, 
                    CAST(usu.f_ultimo_acceso AS DATE) AS fecharegistro_o_ultimoacceso, 
                    tkn.ns_token, 
                    tkn.id_status_token, 
                    tkns.ns_token,
                    tkns.id_status 
                INTO
                    iUsuario, 
                    sIdEstatusUsr, 
                    cNumCliente, 
                    dFechaUltimoAcceso, 
                    vNumTokenAsociado, 
                    sIdEstatusTknAsoc, 
                    cNumTokenSerial, 
                    sIdEstatusTknSerial 
                FROM bdibei:"informix".bei_usuario usu
                    INNER JOIN bdibei:"informix".bei_token tkn ON tkn.num_cliente = usu.num_cliente AND tkn.id_usuario = usu.id_usuario
                    INNER JOIN bdibpi:"informix".tkn_nseries tkns ON tkns.ns_token = tkn.ns_token 
                WHERE usu.f_ultimo_acceso < (MDY(MONTH(TODAY), DAY(TODAY), YEAR(TODAY)) - 1 UNITS YEAR) --FECHA ACTUAL MENOS UN ANIO
                    AND usu.id_status = 30 --SOLO USRS ACTIVOS
                    --AND usu.id_tipo_usuario = 2 --SOLO USRS OPERADORES
                UNION
                -- USUARIOS QUE NUNCA INGRESARON A LA BANCA Y TENGAN TOKEN
                SELECT 
                    usu.id_usuario, 
                    usu.id_status, 
                    usu.num_cliente, 
                    usu.f_registro AS fecharegistro_o_ultimoacceso, 
                    tkn.ns_token, 
                    tkn.id_status_token, 
                    tkns.ns_token,
                    tkns.id_status  
                FROM bdibei:"informix".bei_usuario usu 
                    INNER JOIN bdibei:"informix".bei_token tkn ON tkn.num_cliente = usu.num_cliente AND tkn.id_usuario = usu.id_usuario
                    INNER JOIN bdibpi:"informix".tkn_nseries tkns ON tkns.ns_token = tkn.ns_token 
                WHERE usu.f_ultimo_acceso IS NULL
                    AND usu.f_registro < (MDY(MONTH(TODAY), DAY(TODAY), YEAR(TODAY)) - 1 UNITS YEAR) --FECHA ACTUAL MENOS UN ANIO
                    AND usu.id_status = 30 --SOLO USRS ACTIVOS
                    --AND usu.id_tipo_usuario = 2 --SOLO USRS OPERADORES
                ORDER BY fecharegistro_o_ultimoacceso DESC

                LET cRegistroEjec = iUsuario;

                LET cMensajeEjec = 'UPDATE usr';
                -- Actualizar el estatus del usuario
                UPDATE bdibei:"informix".bei_usuario SET id_status = sEstatusBloqueoUsr, f_status = CURRENT WHERE id_usuario = iUsuario;

                LET cMensajeEjec = 'INSERT hist usr';
                -- Realizar el registro historico de cambio de estatus del usuario 
                INSERT INTO bdibei:"informix".bei_cambiostusuario (
                    id_usuario,
                    numcliente, 
                    id_statusanterior, 
                    id_statusactual, 
                    ipusuario, 
                    fecha_cambio, 
                    suc_cambio, 
                    usuario_cambio
                ) VALUES (
                    iUsuario, 
                    cNumCliente, 
                    sIdEstatusUsr, 
                    sEstatusBloqueoUsr, 
                    cDireccionIpGenerica, 
                    CURRENT, 
                    cSucursal, 
                    cUsuarioPortal
                );

                LET cMensajeEjec = 'UPDATE usr-tkn';
                -- Actualizar el estatus del asocie de ususario - token
                UPDATE bdibei:"informix".bei_token SET id_status_token = sEstatusBloqueoTkn, f_status = CURRENT 
                WHERE id_usuario = iUsuario AND num_cliente = cNumCliente AND ns_token = vNumTokenAsociado;

                LET cMensajeEjec = 'UPDATE tkn';
                -- Actualizar el estatus del token
                UPDATE bdibpi:"informix".tkn_nseries SET id_status = sEstatusBloqueoTkn, f_status = CURRENT WHERE ns_token = vNumTokenAsociado;

                LET cMensajeEjec = 'INSERT hist tkn';
                -- Realizar el registro historico de cambio de estatus del token
                INSERT INTO bdibpi:"informix".tkn_status_token (
                    ns_token,
                    actual, 
                    anterior, 
                    f_cambio_status, 
                    usr_cambio_status, 
                    canal
                ) VALUES (
                    cNumTokenSerial, 
                    sEstatusBloqueoTkn, 
                    sIdEstatusTknSerial, 
                    CURRENT, 
                    cUsuarioPortal,
                    cCanal
                );

                -- Contador de ayuda de registros que se actualizaron para el mensaje de salida
                LET iContandor = iContandor + 1;

            END FOREACH;

        COMMIT WORK;

        LET cCodRet = '00000';
        LET cMensaje = 'PROCESO EXITOSO - ACTUALIZADOS: ' ||  iContandor || ' de ' || iTotalRegistros;

    RETURN cCodRet, cMensaje;
    END;

END PROCEDURE;