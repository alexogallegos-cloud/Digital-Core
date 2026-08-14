CREATE PROCEDURE "informix".sp_generatablatempcv()
RETURNING varchar(6), varchar(80);
/**************************************************************************/
/* Fecha: 28/Enero/2008                                                   */
/* SPL: "informix".sp_generaTablaTempCV()                                 */
/* Actividad: Se encarga de generar un tabla temporal para almacenar los  */
/* los registros necesarios para generar los datos de la tabla            */
/* mi_carteravencidatotal                                                 */
/* Realizado por: José Angel López Adams                                  */
/**************************************************************************/

DEFINE  vsqlerr                     integer;
DEFINE  isam_err                    integer;
DEFINE  vcodret                     varchar(6);
DEFINE  error_info                  varchar(80);
DEFINE  p_mensaje                   varchar(80);

--SET DEBUG FILE TO "/home/informix/cv.out";
--TRACE ON;
BEGIN
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
                    LET vcodret = vsqlerr;
                    LET  p_mensaje  = error_info;
                    RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;

    LET vcodret = '000';
    LET p_mensaje = 'PROCESO EXITOSO';

CREATE TEMP TABLE bdmis:tmpCarteraVencida(
    numcte char(20),
    num_credito char(20),
    status_cred char(11),
    pago_vdos integer,
    tot_capital decimal,
    cap_vigente decimal,
    cap_transitorio decimal,
    cap_vdo_exible decimal,
    cap_vdo_no_exible decimal,
    interes decimal,
    iva decimal,
    monto_financiado decimal
    )WITH NO LOG;

RETURN vcodret, p_mensaje;
END;
END PROCEDURE

;