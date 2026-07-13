CREATE PROCEDURE "informix".sp_soe_validatokensasignados(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9))
                RETURNING CHAR(5) AS codret,
                                  DECIMAL(18,2) AS costoIVA,
                                  INTEGER AS limiteTokens;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iCodRetSp INTEGER;
        DEFINE iNumTokens INTEGER;
        DEFINE iNumTknsAsignados INTEGER;
        DEFINE iNumTknsNuevos INTEGER;
        DEFINE iTotalTokens INTEGER;
        DEFINE dCosto DECIMAL(18,2);
        DEFINE dIva DECIMAL(18,2);
        DEFINE dCostoIva DECIMAL(18,2);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iCodRetSp = 0;
        LET iNumTokens = 0;
        LET iNumTknsAsignados = 0;
        LET iNumTknsNuevos = 0;
        LET iTotalTokens = 0;
        LET dCosto = 0;
        LET dIva = 0;
        LET dCostoIva = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, dCostoIva, iTotalTokens;
                END EXCEPTION;
				
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_soe_validatokensasignados.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR  pNumCte = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, dCostoIva, iTotalTokens;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, dCostoIva, iTotalTokens;
                END IF;
                
				-- AGREGADA POR BANCOPPEL
                IF EXISTS(SELECT numcte FROM bdibei:"informix".bei_solicitudtoken WHERE numcte = pNumCte ) THEN 
                        SELECT COUNT (numcte) INTO iNumTknsAsignados FROM bdibei:"informix".bei_tokensolicitud WHERE numcte = pNumCte AND id_status not in(199,220); --No considera cancelados ni cancelados por renovación
                        
                        IF EXISTS (SELECT solicitud FROM bdibei:"informix".bei_solicitudtoken WHERE numcte = pNumCte AND id_status =100) THEN
                            SELECT SUM(unidades) INTO iNumTknsNuevos FROM bdibei:"informix".bei_solicitudtoken WHERE numcte = pNumCte AND id_status in (100, 170, 180);
                        END IF;
                ELSE
                        LET cCodRet = '00022'; --EL NÃ?MERO DE CLIENTE NO EXISTE
                END IF;
                
                LET iNumTokens = iNumTknsAsignados + iNumTknsNuevos;
				
				-- AGREGADA POR BANCOPPEL
				IF iNumTokens < 10 THEN
						IF EXISTS(SELECT valor FROM bdibpi:"informix".tkn_parametros WHERE id_param = 55) THEN 
								LET iTotalTokens = 10 - iNumTokens;
								SELECT valor INTO dCosto FROM bdibpi:"informix".tkn_parametros WHERE id_param = 55;
								SELECT valor INTO dIva FROM bdinteg:"informix".si_param WHERE cod_param = '47';
								LET dCostoIva = (dCosto * dIva) +  dCosto;
						ELSE
								LET cCodRet = '00190';
						END IF;
				ELSE
						LET cCodRet = '00400'; --EL CLIENTE CUENTA CON EL LIMITE DE TOKENS ASIGNADOS, NO ES POSIBLE SOLICITAR MÃ?S TOKENS
				END IF;
                
                
                RETURN cCodRet, dCostoIva, iTotalTokens;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 03/11/2014',
'DESCRIPCION: Procedimiento que valida el numero de token asignados a un usuario y cuantos mas se le pueden asignar en SOE',
'MODIFICA: Viridiana Rosas',
'FECHA: 03/12/2014',
'DESCRIPCION: Se modifica la tabla en que consulta los tokens que tiene asignados el cliente y ademas se suman las nuevas unidades solicitadas',
'MODIFICA: Armando Barrientos Bustamante',
'FECHA: 03/09/2021',
'DESCRIPCION: se agrega "not in" para no contabilizar tokens con estatus cancelados por renovación(220) y cancelados (199)',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_soe_obtenercuentasparatoken(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pSucursal CHAR(4), pCostoToken MONEY(18,2), pCveOperacion CHAR(12), pRegistros INTEGER)
                RETURNING CHAR(5) AS codret,
                                CHAR(20) AS cuenta,
                                CHAR(40) AS tipo_cuenta;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE mIva MONEY(18, 2);
        DEFINE mCosto MONEY(18,2);
        DEFINE cCuenta CHAR(20);
        DEFINE cNombreProducto CHAR(40);
        DEFINE iNoRegistros INTEGER;
        DEFINE iRegistros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cEmpresa = '001';
        LET mIva = 0.0;
        LET mCosto = 0.0;
        LET cCuenta = '';
        LET cNombreProducto = '';
        LET iNoRegistros = 0;
        LET iRegistros = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cCuenta, cNombreProducto;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/viri/sp_soe_obtenercuentasparatoken.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pCostoToken IS NULL OR pNumCliente = '' OR pCveOperacion = '' OR pRegistros IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cCuenta, cNombreProducto;
                END IF;
                                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cCuenta, cNombreProducto;
                END IF;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
                
                SELECT iva
                INTO mIva
                FROM bdinteg:"informix".si_sucursales
                WHERE empresa = cEmpresa AND sucursal = pSucursal;
                
                LET mIva = pCostoToken * mIva;
                LET mCosto = pCostoToken + mIva;

                FOREACH SELECT FIRST pRegistros a.cuenta, b.nombre
                                INTO cCuenta, cNombreProducto
                                FROM bdicheq:"informix".sc_maechq a, bdicheq:"informix".sc_producto b
                                WHERE a.num_cte = pNumCliente
                                        AND a.status_cta = 1
                                        AND sdo_actual >= mCosto
                                        AND a.producto IN (SELECT producto FROM bdinteg:"informix".si_bpipprod WHERE id_oper = pCveOperacion)
                                        AND b.producto = a.producto
                                UNION
                                SELECT a.num_credito, c.nombre_prod
                                FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_maesdos b, bdicred:"informix".sd_definicion c
                                WHERE a.empresa = cEmpresa AND a.numcte = pNumCliente
                                        AND a.status_cred IN ('AA','E1')
										AND (b.monto_vencido + b.mto_venc_trasp) = 0
                                        AND b.num_credito = a.num_credito
                                        AND c.num_producto = a.num_producto
                                        AND NVL(a.id_unidad_prod, 0) NOT IN (3, 4)
                                        AND c.cod_tipcred::INTEGER = 3
                                        AND (b.monto_otorgado - (b.sdo_cap_insoluto + b.sdo_retenido)) >= mCosto

                        RETURN cCodRet, cCuenta, cNombreProducto WITH RESUME;           
                        LET iNoRegistros = iNoRegistros + 1;
                
                END FOREACH;
                
                IF iNoRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, cCuenta, cNombreProducto;
                END IF;
                
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 28/11/2014',
'DESCRIPCION: Consulta las cuentas que tienen saldo (captacion y credito) para poder cobrar el costo del token',
'BD: bdibei';

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