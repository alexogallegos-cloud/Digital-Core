CREATE PROCEDURE "informix".sp_agregar_bitacora_geolocalizacion_bei(
    pFechaOper  DATETIME YEAR TO SECOND, 
    pIdOper     CHAR(4),
    pNumSuc     CHAR(4),
    pIdUsuario  INTEGER,
    pIpUsuario  CHAR(15),
    pFechaApli  DATE,
    pCtaOrigen  CHAR(12),
    pCtaDesti   CHAR(12),
    pMonto      MONEY,
    pSecTrans   CHAR(16),
    pCgen1      CHAR(40),
    pCgen2      CHAR(40),
    pCgen3      CHAR(40),
    pCgen4      CHAR(40),
    pCgen5      CHAR(40),
    pCgen6      CHAR(40),
    pCgen7      CHAR(40),
    pCgen8      CHAR(40),
    pCgen9      CHAR(40),
    pLatitud    VARCHAR(10),
    pLongitud   VARCHAR(11),
    pPlataforma CHAR(40),
    pFlgModo    INTEGER)
RETURNING CHAR(5) AS codigo, CHAR(100) AS mensaje;

-- ******************************************************************************************************************************
-- DESCRIPCION: SP para ejecutar el registro de bitacoras y como adicional por normativa, los datos de geolocalizacion para 
--              operaciones que se realiza a traves de la banca por internet de persona morales, siguiendo las reglas siguientes
--              * En base a una bandera enviada como parametro se determinara si se ejcuta un INSERT de maximo 14 parametros
--                o un INSERT de 19 parametros, tal cual lo hace con los SP actuales de empresanet
--              * Al termino del registro de la bitacora principal, se hara el registro de la geolocalizacion en la tabla designada
--              * pFlgModo -- valores aceptados
--                1 = Bitacora con 14 Parametros (acotado) del operador
--                2 = Bitacora con 19 Parametros (extendido) del operador
--                3 = Bitacora para Administracion
-- Autor: Marco Tinajero
-- FECHA : 29/03/2021
-- SOLICITO : Armando Barrientos
-- ESQUEMA DE BD: bdibei
-- ******************************************************************************************************************************

    -- VARIABLES DE CONTROL
    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE cNumCliente          CHAR(50);
    DEFINE cCodSPGuardaBitacora CHAR(5);
    DEFINE sIdBitacoraAdmin     INTEGER;
    DEFINE cReferencia          CHAR(40);
    DEFINE cMensaje             CHAR(100);
    DEFINE cParamSP             CHAR(10);

    -- VARIABLES DE EJECUCION
    LET cCodRet               = '00000';
    LET cMensaje              = '';
    LET iSqlErr               = 0;
    LET cCodSPGuardaBitacora  = '';
    LET cNumCliente           = '';
    LET cParamSP              = '';
    LET sIdBitacoraAdmin      = 0;
    LET cReferencia           = '';

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr != 0 THEN
                LET cCodRet = '00002';
                LET cMensaje = 'OCURRIO UN ERROR NO CONTROLADO - SqlErr: ' || iSqlErr;

                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;

        IF pIdUsuario IS NOT NULL THEN
            
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			SELECT num_cliente
              INTO cNumCliente
            FROM bdibei:"informix".bei_usuario
            WHERE id_usuario = pIdUsuario;
        ELSE
            LET cCodRet = '00001';
            LET cMensaje = 'EL ID DEL USUARIO NO PUEDE SER NULO O VACIO';
            RETURN cCodRet, cMensaje;
        END IF;

        -- Validacion de operativa de alta de cuentas de nomina por archivo o individual, el cual no genera folio pero si el nombre del archivo en cgenerico2
        IF pIdOper = '3031' THEN
            LET cReferencia = pCgen2;
        ELIF pIdOper = '1015' THEN
            -- Validacion de operativa de trasnferencias SPEI, donde el folio se guarda en cgenerico9
            LET cReferencia = pCgen9;
        ELSE
            -- El folio de referencia para las demas operaciones (bdibei:bei_cat_operaciones) se guarda en cgenerico1: 1008, 1016, 3003, 3004, 3028, 3029, 3030, 1020, 1021
            LET cReferencia = pCgen1;
        END IF;

        -- Si la bandera es valor 1 procedera a ejecutar el SP de bitacora de 14 parametros
        IF pFlgModo = 1 THEN
            LET cParamSP = '14 PARAMS';
            EXECUTE PROCEDURE bdibei:"informix".sp_agregarbitacora_bei(
                pFechaOper,
                pIdOper,
                pNumSuc,
                pIdUsuario,
                pIpUsuario,
                pFechaApli,
                pCtaOrigen,
                pCtaDesti,
                pMonto,
                pSecTrans,
                pCgen1,
                pCgen2,
                pCgen3,
                pCgen4
            ) INTO cCodSPGuardaBitacora;
        ELIF pFlgModo = 2 THEN
            LET cParamSP = '19 PARAMS';
            -- Si la bandera es valor 2, procedera a ejecutar el SP de bitacora de 19 parametros
            EXECUTE PROCEDURE bdibei:"informix".sp_agregarbitacora_bei(
                pFechaOper,
                pIdOper,
                pNumSuc,
                pIdUsuario,
                pIpUsuario,
                pFechaApli,
                pCtaOrigen,
                pCtaDesti,
                pMonto,
                pSecTrans,
                pCgen1,
                pCgen2,
                pCgen3,
                pCgen4,
                pCgen5,
                pCgen6,
                pCgen7,
                pCgen8,
                pCgen9
            ) INTO cCodSPGuardaBitacora;
        ELSE
            -- Si la bandera es valor 3 procedera a ejecutar el SP de bitacora para administracion
            EXECUTE PROCEDURE bdibei:"informix".sp_agregarbitacora_admin_bei(
                pFechaOper, 
                pIdOper,
                pIpUsuario,
                pIdUsuario,
                pCgen1,
                pFechaApli,
                pCtaOrigen,
                pCtaDesti,
                pCgen2,
                pCgen3,
                pCgen4,
                pCgen5,
                pCgen6
            ) INTO cCodSPGuardaBitacora, sIdBitacoraAdmin;

            -- Obtener la llave que se registro para la bitacora de administracion
            IF cCodSPGuardaBitacora = '00000' AND sIdBitacoraAdmin != 0 THEN
                LET cReferencia = sIdBitacoraAdmin;
            END IF;
        END IF;

        -- Registro en bitacora de operaciones con la activacion de la geolocalizacion por normatividad
        INSERT INTO bdibei:"informix".bei_bitacora_geolocalizacion(fecha_hr_oper,
            id_operacion,
            num_cliente,
            id_usuario,
            ip_usuario,
            fecha_aplic,
            referencia,
            latitud,
            longitud,
            plataforma
        ) VALUES (
            pFechaOper,
            pIdOper,
            cNumCliente,
            pIdUsuario,
            pIpUsuario,
            pFechaApli,
            cReferencia,
            pLatitud,
            pLongitud,
            pPlataforma
        );

        IF pFlgModo != 3 AND cCodSPGuardaBitacora != '000' THEN
            LET cMensaje = 'PROCESO EJECUTADO CORRECTO PERO CON ERROR EN: sp_agregarbitacora_bei ' || cParamSP || ' - CODIGO ' || cCodSPGuardaBitacora;
            RETURN cCodRet, cMensaje;
        ELIF pFlgModo = 3 AND cCodSPGuardaBitacora != '00000' THEN
            LET cMensaje = 'PROCESO EJECUTADO CORRECTO PERO CON ERROR EN: sp_agregarbitacora_admin_bei - CODIGO ' || cCodSPGuardaBitacora;
            RETURN cCodRet, cMensaje;
        END IF;

        LET cMensaje = 'PROCESO EJECUTADO CORRECTAMENTE';

    RETURN cCodRet, cMensaje;
    END;

END PROCEDURE;