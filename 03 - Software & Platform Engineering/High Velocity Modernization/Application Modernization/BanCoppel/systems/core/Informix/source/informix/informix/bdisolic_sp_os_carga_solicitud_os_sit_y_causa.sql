create procedure "informix".sp_os_carga_solicitud_os_sit_y_causa()
returning char(6)
--Juan Andrés Coronel M., 20-08-2007
--sp para ejecutarse una vez, para cargar en ss_solicitud_os los campos causasituacionespecial y situacionespecial con los datos existentes en ss_osclientesupervisar.
--Estos datos se requieren en esta tabla ya que serán mostrados en pantalla para relanzado de os
--Por lo que es necesario actualizar estos campos en producción.

define sNum_solicitud char(20);
define dfechasol date;
define sSitEsp   char(1);
define iCausa    smallint;
define p_cod_ret char(6);
    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    DEFINE ERROR_INFO       VARCHAR(80);
    DEFINE P_MENSAJE        VARCHAR(80);

Begin
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        ROLLBACK WORK;
        RETURN P_COD_RET;
    END EXCEPTION;

    Begin Work;
    Let P_cod_ret = '000000';
    ForEach
    Select num_solicitud, fechasolicitud, situacionespecial, causasituacionespecial
    Into sNum_solicitud, dfechasol, sSitEsp, iCausa
    From ss_osclientesupervisar
    Where trim(nvl(clave,' ')) <> ''
        Update ss_solicitud_os
        Set situacionespecial = sSitEsp, 
            causasituacionespecial = iCausa
        Where num_solicitud = sNum_solicitud
        and fecha_solicitud = dfechasol;
    End ForEach;
    Commit;
    return p_cod_ret;
End;
End procedure;