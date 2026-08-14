create procedure "informix".sp_os_solicitudes_en_espera(iSecuenciaMax integer)
returning 
    char(5), char(20), date, integer;

    define    snum_solicitud  char(20);
    define    ffechasol       date;
    define    ssecuencia      integer;

    DEFINE   SQL_ERR     INTEGER;
    DEFINE   ISAM_ERR    INTEGER;
    DEFINE   ERROR_INFO  VARCHAR(80);
    DEFINE P_COD_RET VARCHAR(5);
    DEFINE P_MENSAJE VARCHAR(80);


begin


    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        --ROLLBACK WORK;
        RETURN P_COD_RET, snum_solicitud, ffechasol, ssecuencia;
    END EXCEPTION;

    LET P_COD_RET = '00000';
    LET P_MENSAJE = 'PROCESO EXITOSO';

    Foreach
    Select num_solicitud, fechasolicitud, secuencia
    Into snum_solicitud, ffechasol, ssecuencia
    From ss_osclientesupervisar
    Where secuencia <= iSecuenciaMax and nvl(clave, '') <> 'A' and  nvl(clave, '') <> 'R'

        Return P_COD_RET, snum_solicitud, ffechasol, ssecuencia WITH RESUME;

    END FOREACH;

END;

END PROCEDURE;