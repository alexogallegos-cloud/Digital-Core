CREATE PROCEDURE "informix".inicializa_os_rechazadas() RETURNING CHAR(5);

    DEFINE V_Empresa        LIKE bdisolic:ss_solicitud_os.Empresa;
    DEFINE V_NumSolicitud   LIKE bdisolic:ss_solicitud_os.Num_Solicitud;
    DEFINE V_FechaSolicitud LIKE bdisolic:ss_solicitud_os.Fecha_Solicitud;

    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    DEFINE ERROR_INFO       VARCHAR(80);
    DEFINE P_COD_RET        VARCHAR(5);
    DEFINE P_MENSAJE        VARCHAR(80);

    --Set debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/inicializa_os_rechazadas.out';
    --trace on;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        ROLLBACK WORK;
        RETURN P_COD_RET;
    END EXCEPTION;

    BEGIN WORK;
        LET P_COD_RET = '00000';


        --TOMAR todas las marcadas como rechazadas
        ForEach
        Select empresa, num_solicitud, fecha_solicitud
        Into V_Empresa, V_NumSolicitud, V_FechaSolicitud
        from ss_solicitud_os
        WHERE Status = 'R'

            --Inicializar los estatus
            Update SS_OSCLIENTESUPERVISAR
            Set CLAVE = '',
                SITUACIONESPECIAL = '',
                CAUSASITUACIONESPECIAL = 0,
                fechaimpresion= '01/01/1900'::date,
                fecharespuesta = '01/01/1900'::date
            Where num_solicitud = V_NumSolicitud
            and fechasolicitud = V_FechaSolicitud
            and empresa = V_Empresa;

            --Marcar como ya enviada, en espera de respuesta
            Update SS_SOLICITUD_OS
            Set STATUS = 'P',
                FECHA_RESPUESTA = null,
                USUARIO_GESTOR = ''
            Where empresa = V_Empresa
            and num_solicitud = V_NumSolicitud
            and fecha_solicitud = V_FechaSolicitud;

            --Marcar estatus En estudio, para que pueda aceptar la respuesta de nuevo
            Update ss_solicitudes
            Set status_solicitud = 'EE'
            Where empresa = V_Empresa
            and num_solicitud = V_NumSolicitud;

            delete ss_autorizacion
            where empresa = V_Empresa
            and num_solicitud = V_NumSolicitud
            and status_solicitud = 'RT';

        End ForEach;

        --hacer situacion especial a OS aceptadas
        Update SS_OSCLIENTESUPERVISAR
        Set CAUSASITUACIONESPECIAL = 0
        Where clave = 'A' and causasituacionespecial = 48;

    IF P_cod_ret = "00000" THEN --no hubo errores
        COMMIT WORK;
    ELSE
        ROLLBACK WORK;
    END IF;

    return P_cod_ret;
END;
END PROCEDURE;