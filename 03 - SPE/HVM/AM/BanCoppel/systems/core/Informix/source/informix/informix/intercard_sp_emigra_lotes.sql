CREATE PROCEDURE "informix".sp_emigra_lotes()
            RETURNING char(6), varchar(80);

/**************************************************************************/
/* Fecha: 23/Enero/2008                                                   */
/* SPL: "informix".sp_emigra_lotes()                                      */
/* Actividad: Se encarga de emigrar los datos de lote de la tabla tarjetas a  */
/* la tabla lote, que es con la cual trabajará el sistema de inventarios  */
/* Realizado por: José Angel López Adams                                  */
/**************************************************************************/

            DEFINE     vsqlerr              integer;
            DEFINE     p_mensaje            varchar(80);
            DEFINE     error_info           varchar(80);
            DEFINE     vcodret              varchar(5);
            DEFINE     isam_err             integer;
            DEFINE     cClave_Sucursal      char(5);
            DEFINE     iNumGuia             integer;
            DEFINE     iNumLote             integer;
            DEFINE     dFechaGeneracion     DATETIME YEAR TO FRACTION;
            DEFINE     cCodProductoTarjeta  char(3);
            DEFINE     cNumTarjeta          char(8);
            DEFINE     iCantTarjetas        integer;
            DEFINE     iClaveTipoTarjeta    integer;


            --SET DEBUG FILE TO "/home/informix/proc.out";
            --TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 THEN
                    LET vcodret = vsqlerr;
                    LET  p_mensaje  = error_info;
                   -- ROLLBACK WORK;
                    RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;

    LET vcodret = '000';
    LET p_mensaje = 'PROCESO EXITOSO';



    LET dFechaGeneracion = CURRENT::DATETIME YEAR TO FRACTION;
--    BEGIN WORK;

        FOREACH
            SELECT DISTINCT (numerolote) INTO iNumLote FROM tarjeta ORDER BY numerolote

            SELECT numtarjeta, numerolote, codstatustarjeta FROM tarjeta WHERE numerolote = iNumLote INTO TEMP tmpTarjeta  WITH NO LOG;

                FOREACH
                    SELECT DISTINCT SUBSTRING(numtarjeta FROM 1 FOR 8)
                    INTO cNumTarjeta
                    FROM tmpTarjeta
                    WHERE numerolote = iNumLote

                    IF cNumTarjeta = '42680701' AND iNumLote = 1 OR cNumTarjeta = '42680701' AND iNumLote = 5  OR cNumTarjeta = '42680701' AND iNumLote = 107 THEN

                    ELSE
                        SELECT COUNT(*)
                        INTO iCantTarjetas
                        FROM tmpTarjeta
                        WHERE numtarjeta LIKE ''|| TRIM(cNumTarjeta) || '%'
                        AND numerolote = iNumLote;

                        IF cNumTarjeta = '42680701' THEN
                            LET iClaveTipoTarjeta = 1;
                        ELSE
                            IF cNumTarjeta = '42680702' THEN
                                LET iClaveTipoTarjeta = 2;
                            ELSE
                                IF cNumTarjeta = '40081901' THEN
                                    LET iClaveTipoTarjeta = 3;
                                ELSE
                                    IF cNumTarjeta = '40081902' THEN
                                        LET iClaveTipoTarjeta = 4;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;


                        --LET dFechaGeneracion = dFechaGeneracion + 1 UNITS MINUTE;

                        IF iNumLote <= 154 THEN
                            IF iClaveTipoTarjeta = 1 OR iClaveTipoTarjeta = 2  AND iNumLote <= 154 THEN

                                SELECT LIMIT 1  LPAD(a.sucursal, 5, '0')
                                INTO cClave_Sucursal
                                FROM bdicred:sd_maecred a, bdicred:sd_tarjeta b, tmpTarjeta c
                                WHERE a.sucursal IS NOT NULL
                                AND a.num_credito = b.num_credito
                                AND b.num_tarjeta = c.numtarjeta
                                AND c.numerolote = iNumLote
                                AND c.codstatustarjeta = 'ACT';
                            ELSE
                                SELECT LIMIT 1  LPAD(a.sucursal, 5, '0')
                                INTO cClave_Sucursal
                                FROM bdicheq:sc_maechq a, bdicheq:sc_tarjeta b, tmpTarjeta c
                                WHERE a.sucursal IS NOT NULL
                                AND a.cuenta = b.cuenta
                                AND b.num_tarjeta = c.numtarjeta
                                AND c.numerolote = iNumLote
                                AND c.codstatustarjeta = 'ACT';

                            END IF;

                            SELECT LIMIT 1 fecha
                            INTO dFechaGeneracion
                            FROM flujotarjeta
                            WHERE numtarjeta
                            IN (SELECT numtarjeta
                                FROM tmpTarjeta
                                WHERE numerolote = iNumLote);

                        ELSE
                            SELECT clave_sucursal
                            INTO cClave_Sucursal
                            FROM lotesnuevos
                            WHERE numerolote = iNumLote;

                            SELECT LIMIT 1 fecha_generacion
                            INTO dFechaGeneracion
                            FROM detalle_maquila
                            WHERE numlote = iNumLote;

                        END IF;

                        INSERT INTO lote (numerolote, fechageneracion, cantidadtarjetassol, clave_tipotarjeta, clave_sucursal)
                        VALUES (iNumLote, dFechaGeneracion, iCantTarjetas, iClaveTipoTarjeta, cClave_Sucursal);

                    END IF;
                END FOREACH;
            DROP TABLE tmpTarjeta;
        END FOREACH;
        --Estos lotes pertenecen al corporativo
        UPDATE lote SET clave_sucursal = '00000' WHERE numerolote = 1;
        UPDATE lote SET clave_sucursal = '00000' WHERE numerolote = 2;
        UPDATE lote SET clave_sucursal = '00000' WHERE numerolote = 3;
        UPDATE lote SET clave_sucursal = '00000' WHERE numerolote = 4;
    --COMMIT WORK;
RETURN vcodret, p_mensaje;
END;
END PROCEDURE;