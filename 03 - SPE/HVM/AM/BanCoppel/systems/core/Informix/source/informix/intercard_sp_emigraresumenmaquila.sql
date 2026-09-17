CREATE PROCEDURE "informix".sp_emigraresumenmaquila()
RETURNING varchar(6), varchar(80);

/**************************************************************************/
/* Fecha: 10/Enero/2008                                                   */
/* SPL: "informix".sp_emigraResumenMaquila()                              */
/* Actividad: Se encarga de emigrar los datos a los campos nuevos         */
/* clave_tipotarjeta y fecha_generacion                                   */
/* Realizado por: José Angel López Adams                                  */
/**************************************************************************/

DEFINE  vsqlerr                     integer;
DEFINE  isam_err                    integer;
DEFINE  vcodret                     varchar(6);
DEFINE  cCodRet                     varchar(6);
DEFINE  error_info                  varchar(80);
DEFINE  p_mensaje                   varchar(80);
DEFINE  c_mensaje                   varchar(80);

DEFINE  iNumerolote                 integer;
DEFINE  dfechageneracion            datetime year to fraction;
DEFINE  iCantTarjetasSol            integer;
DEFINE  iCveTipoTarjeta             integer;
DEFINE  cClaveSucursal              char(5);
DEFINE  cFechaExp                   char(4);
DEFINE  cCodProdTar                 char(3);

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
    BEGIN WORK;
        FOREACH
            SELECT numerolote, fechageneracion, cantidadtarjetassol, clave_tipotarjeta, clave_sucursal
            INTO iNumerolote, dfechageneracion, iCantTarjetasSol, iCveTipoTarjeta, cClaveSucursal
            FROM lote

            SELECT  LIMIT 1 fechaexp INTO cFechaExp
            FROM tarjeta WHERE numerolote = iNumerolote;

          /*  IF iNumeroLote < 155  THEN
                SELECT  LIMIT 1 fechaexp INTO cFechaExp
                FROM tarjeta WHERE numerolote = iNumerolote;
            ELSE
                SELECT  LIMIT 1 fecha_expiracion INTO cFechaExp
                FROM detalle_maquila WHERE clave_sucursal = cClaveSucursal AND numlote = iNumerolote;
            END IF*/
--          Validar que coincidan el producto
            IF (iCveTipoTarjeta = 1 OR iCveTipoTarjeta = 2) THEN
                LET cCodProdTar = '001';
            ELSE
                IF (iCveTipoTarjeta = 3 OR iCveTipoTarjeta = 4) THEN
                    LET cCodProdTar = '501';
                END IF;
            END IF;

            INSERT INTO resumen_maquila2 (clave_sucursal, cantidad, codproductotarjeta, fechaexp, indicadortipoproceso, flagprocesorealizado,
            clave_tipotarjeta, fecha_generacion)
            VALUES (cClaveSucursal, iCantTarjetasSol, cCodProdTar, cFechaExp, 'P', 'V', iCveTipoTarjeta, dfechageneracion);

        END FOREACH;
        RENAME TABLE intercard:resumen_maquila TO resumen_maquila_res;
        RENAME TABLE intercard:resumen_maquila2 TO resumen_maquila;
    COMMIT WORK;
RETURN vcodret, p_mensaje;
END;
END PROCEDURE




;