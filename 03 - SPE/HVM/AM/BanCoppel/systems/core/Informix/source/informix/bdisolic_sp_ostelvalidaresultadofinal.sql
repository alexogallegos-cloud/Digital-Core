CREATE PROCEDURE "informix".sp_ostelvalidaresultadofinal(pNum_solicitud CHAR(20))

DEFINE scod_ret               CHAR(6);
DEFINE vNum_solicitud CHAR(20);
DEFINE vEmpresa CHAR(3);
DEFINE cResultadoOsTel CHAR(1);
DEFINE cTieneOstel CHAR(1);
DEFINE cEnvioCat CHAR(1);
DEFINE iElementoOS SMALLINT;

LET iElementoOS = 0;

LET scod_ret='';
---Modificó : Jesús Manuel Aguilar Heredia
--Fecha: 03-11-2010
--Se agrego una validacion en la consulta a la tabla ss_solicitudes para validar que el estatus de la solicitud sea igual a 'ST', ademas se le quitaron algunas validaciones que no eran necesarias.

--Set debug file to '/tmp/sp_OSTelValidaResultadoFinal.out';
--trace on;
SET ISOLATION TO DIRTY READ;
BEGIN
  FOREACH
    SELECT empresa, num_solicitud
    INTO vEmpresa, vNum_solicitud
    FROM ss_solicitudes
    WHERE num_solicitud = pNum_solicitud
	AND status_solicitud = 'ST'
    
        EXECUTE PROCEDURE sp_OStelConsultaResultado('001', vNum_solicitud)
        INTO scod_ret, cResultadoOsTel,cTieneOstel,cEnvioCat;

        IF cResultadoOsTel   = 'V' THEN 
            LET iElementoOS = 1;
        ELIF cResultadoOsTel = 'I' THEN 
            LET iElementoOS = 2;
        ELIF cResultadoOsTel = 'S' THEN 
            LET iElementoOS = 3;
        END IF;

        IF iElementoOS <> 0 THEN
            EXECUTE PROCEDURE bdisolic:califica_scoring2_cjunk(vEmpresa, vNum_solicitud)
            INTO scod_ret;
        END IF;
        
    END FOREACH;
END;
END PROCEDURE;