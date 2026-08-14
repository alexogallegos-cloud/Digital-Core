CREATE PROCEDURE "informix".sp_consultacambiosstatusmonitor( pEmpresa CHAR(3), pNumSolicitud CHAR(20) )
RETURNING CHAR(6), CHAR(45), DATE, CHAR(40), DATE, CHAR(500);

--Autor: Walber Castro
--27-03-2009
--Obtiene el historico de los cambios de status de una solicitud.

DEFINE sCodRet CHAR(6);
DEFINE iCodRet INTEGER ;

DEFINE vejecutivo CHAR(45);
DEFINE vfecha_salida DATE;
DEFINE vdescripcion CHAR(40);
DEFINE vfecha_entrada DATE;
DEFINE vcomentario CHAR(500);


LET sCodRet = "000";
LET vejecutivo ="";
LET vfecha_salida = '01-01-1900';
LET vdescripcion = "";
LET vfecha_entrada = '01-01-1900';
LET vcomentario = "";

--SET DEBUG FILE TO '/tmp/SP_ConsultaMovtoStatusMonitor.out';
--TRACE ON;

BEGIN
    ON EXCEPTION SET iCodRet
        Let SCodRet = iCodRet;
        RETURN sCodRet, vejecutivo, vfecha_salida, vdescripcion, vfecha_entrada, vcomentario;
    END Exception;

    FOREACH
        SELECT nvl(c.nombre, 'Sistema') ejecutivo, NVL(fecha_salida, ' ')fecha_salida, b.descripcion, NVL(fecha_entrada, ' ') fecha_entrada,  NVL(comentario, ' ') comentario
        INTO vejecutivo, vfecha_salida, vdescripcion, vfecha_entrada, vcomentario
        FROM bdisolic:ss_autorizacion a, bdisolic:ss_status_sol b , outer bdinteg:si_ejecut c
        WHERE a.empresa = pEmpresa   AND a.num_solicitud = pNumSolicitud   AND b.empresa = a.empresa
        AND b.status_solicitud = a.status_solicitud   AND c.empresa = a.empresa
        AND c.ejecutivo = ejecutivo_auto
        ORDER BY fecha_entrada

        RETURN sCodRet, vejecutivo, vfecha_salida, vdescripcion, vfecha_entrada, vcomentario WITH RESUME;
     END FOREACH;
END ;
END PROCEDURE ;