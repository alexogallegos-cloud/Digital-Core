CREATE PROCEDURE "informix".sp_emigraconsecutivostarjetas()
RETURNING varchar(6), varchar(80);

/**************************************************************************/
/* Fecha: 10/Enero/2008                                                   */
/* SPL: "informix".sp_emigraConsecutivosTarjetas()                        */
/* Actividad: Se encarga de actualizar los campos de los consecutivos de la*/
/* tipotarjeta con los datos de la tabla productoimagen                   */
/* Realizado por: José Angel López Adams                                  */
/**************************************************************************/

DEFINE  vsqlerr                     integer;
DEFINE  isam_err                    integer;
DEFINE  vcodret                     varchar(6);
DEFINE  cCodRet                     varchar(6);
DEFINE  error_info                  varchar(80);
DEFINE  p_mensaje                   varchar(80);
DEFINE  c_mensaje                   varchar(80);

DEFINE  iConsecutivo                integer;
DEFINE  iConsecutivoActual          integer;
DEFINE  iClave                      integer;
DEFINE  cBin                        char(6);

--SET DEBUG FILE TO "/home/informix/cv.out";
--TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
                    LET vcodret = vsqlerr;
                    LET  p_mensaje  = error_info;
                    ROLLBACK WORK;
                    RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;

    LET vcodret = '000';
    LET p_mensaje = 'PROCESO EXITOSO';
    --  ACTUALIZA LOS CONSECUTIVOS DE LA TABLA TIPOTARJETA CON LOS DATOS DE LA TABLA PRODUCTOIMAGEN  --

    BEGIN WORK;
        FOREACH
            SELECT a.consecutivo, a.consecutivo_actual, a.bin, CAST(a.producto AS integer) INTO iConsecutivo, iConsecutivoActual, cBin, iClave
            FROM consecutivoproductoimagen a, tipotarjeta b
            WHERE CAST(a.producto AS integer) = CAST( b.clave AS integer)
            AND a.bin = b.bin

            UPDATE tipotarjeta SET consecutivo = iConsecutivo, consecutivo_actual = iConsecutivoActual
            WHERE bin = cBin AND CAST(clave AS integer) = iClave;
        END FOREACH;
     COMMIT WORK;

RETURN vcodret, p_mensaje;
END;
END PROCEDURE

;