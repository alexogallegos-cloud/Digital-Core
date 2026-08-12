CREATE PROCEDURE "informix".sp_genera_estadistica_existencia_adicionales()
            RETURNING char(6), varchar(80);

/**************************************************************************/
/* Fecha: 23/Enero/2008                                                   */
/* SPL: informix".sp_genera_estadistica_existencia()                      */
/* Actividad: Se encarga de generara la estadistica de consumo para cada  */
/* uan de las sucursales que se encuentran en operación                   */
/* Realizado por: José Angel López Adams                                  */
/**************************************************************************/


/**************************************************************************/
/*             D E F I N I C I O N  D E  V A R I A B L E S                */
/**************************************************************************/

            DEFINE     p_mensaje            varchar(80);
            DEFINE     error_info           varchar(80);
            DEFINE     c_mensaje            varchar(80);
            DEFINE     vcodret              varchar(5);
            DEFINE     cCodRet              varchar(6);
            DEFINE     isam_err             integer;
            DEFINE     vsqlerr              integer;

            DEFINE     iNumRegistros        integer;
            DEFINE     iConsumo             integer;
            DEFINE     iConsumoNulo         integer;
            DEFINE     iFlag                integer;
            DEFINE     iExistencia          integer;
            DEFINE     iNumerolote          integer;

            DEFINE     dFechaInicial        DATETIME year to fraction;
            DEFINE     dFechaFinal          DATETIME year to fraction;
            DEFINE     dFechaActual         DATETIME year to fraction;

            DEFINE     cClave_Sucursal      char(5);
            DEFINE     cClave               char(5);
            DEFINE     cCodProd_Tarjeta     char(3);
            DEFINE     cClave_Tarjeta       char(10);
            DEFINE     cProductoImagen      char(10);
            DEFINE     cBin                 char(10);
            DEFINE     cTarjeta_parcial     char(10);
            DEFINE     cMesEstadistica      char(2);
            DEFINE     cAnioEstadistica     char(2);
            DEFINE     cFechaEstadistica    char(10);

--            SET DEBUG FILE TO "/home/informix/exi.out";
--            TRACE ON;

BEGIN
            ON EXCEPTION SET vsqlerr,isam_err, error_info
                   IF vsqlerr <> 0 THEN
                          LET vcodret = vsqlerr;
                          LET  p_mensaje  = error_info;
--                          ROLLBACK WORK;
                          RETURN vcodret, p_mensaje;
                   END IF;
            END EXCEPTION;

            LET vcodret = '000';
            LET p_mensaje = 'PROCESO EXITOSO';
            LET iFlag = 0;

            IF EXISTS(SELECT tabname
                      FROM sysmaster:systabnames
                      WHERE tabname = 'tmpTarjetas') THEN

               DROP TABLE intercard:tmpTarjetas;

            END IF;
  --          BEGIN WORK;

                FOREACH
                    SELECT  clave_sucursal
                    INTO cClave_Sucursal
                    FROM sucursal
                    WHERE clave_sucursal in ('00026','00031','00039','00063','00240',
                                             '00271','00275','00281','00330','00421',
					     '00426','00444','00446','00451','00454',
					     '00470','00491','00713','00764','00774','00775')
                    ORDER BY clave_sucursal

                    FOREACH

                        SELECT clave_tipotarjeta, clave, bin, codproductotarjeta
                        INTO cClave_Tarjeta, cClave, cBin, cCodProd_Tarjeta
                        FROM tipotarjeta

                        SELECT producto
                        INTO cProductoImagen
                        FROM productoimagen
                        WHERE clave  =  cClave;

                        LET cTarjeta_parcial = Trim(cBin) || Trim(cProductoImagen);

                        SELECT numtarjeta, codstatustarjeta, codstatusasignada,fechaasignacion
                        FROM tarjeta
                        WHERE numerolote
                        IN (SELECT numerolote
                            FROM lote
                            WHERE clave_sucursal = cClave_Sucursal AND clave_tipotarjeta = cClave_Tarjeta)
                        INTO TEMP tmpTarjetas WITH NO LOG;

                        SELECT COUNT(numtarjeta)
                        INTO iExistencia
                        FROM tmpTarjetas
                        WHERE
                        codstatusasignada = 'NOA'
                        and codstatustarjeta = 'INA';

                        IF NOT EXISTS ( SELECT clave_sucursal, clave_tipotarjeta
                                        FROM sucursal_tipotarjeta
                                        WHERE clave_sucursal = cClave_Sucursal
                                        AND clave_tipotarjeta = cClave_Tarjeta) THEN
                            INSERT INTO sucursal_tipotarjeta (clave_sucursal, clave_tipotarjeta, existencia, solicitadas)
                            VALUES (cClave_Sucursal, cClave_Tarjeta, iExistencia, '0');

                        END IF;
                        --Fecha inicial cuando inicio operaciones
                        LET dFechaInicial = CURRENT - 15 UNITS DAY; --'2007-05-01 00:00:00.0' - 10 UNITS DAY;
                        LET dFechaActual = CURRENT;
                        LET dFechaFinal = dFechaInicial + 1 UNITS DAY;

                        WHILE (dFechaInicial <= dFechaActual)

                                LET cMesEstadistica = LPAD(MONTH (dFechaInicial),2,"0");
                                LET cAnioEstadistica = SUBSTRING(LPAD(YEAR(dFechaInicial),4,"0") FROM 3 FOR 2) ;
                                LET cFechaEstadistica = TO_CHAR(dFechaInicial,'%Y-%m-%d'); -- cMesEstadistica || cAnioEstadistica;

                                IF MONTH(dFechaInicial) = MONTH(dFechaActual)  AND YEAR(dFechaInicial)= YEAR(dFechaActual) and DAY(dFechaInicial)= DAY(dFechaActual) THEN
                                    LET iFlag = 1;
                                END IF;

                                IF iFlag = 1 THEN

                                    SELECT COUNT(numtarjeta)
                                    INTO iConsumo
                                    FROM tmpTarjetas
                                    WHERE numtarjeta
                                    LIKE ''|| TRIM(cTarjeta_parcial) || '%'
                                    AND codstatustarjeta <> 'INA'
                                    AND codstatusasignada <> 'NOA'
                                    AND fechaasignacion >= dFechaInicial
                                    AND fechaasignacion <= dFechaActual
                                    OR
                                    (codstatustarjeta <> 'INA'
                                    AND codstatusasignada = 'NOA'
                                    AND fechaasignacion >= dFechaInicial
                                    AND fechaasignacion <= dFechaActual);

                                    SELECT COUNT(numtarjeta)
                                    INTO iConsumoNulo
                                    FROM tmpTarjetas
                                    WHERE numtarjeta
                                    LIKE ''|| TRIM(cTarjeta_parcial) || '%'
                                    AND codstatustarjeta <> 'INA'
                                    AND codstatusasignada <> 'NOA'
                                    AND fechaasignacion IS NULL
                                    OR(codstatustarjeta <> 'INA'
                                    AND codstatusasignada = 'NOA'
                                    AND fechaasignacion IS NULL);


                                    LET iConsumo = iConsumo + iConsumoNulo;

                                ELSE

                                    SELECT COUNT(numtarjeta)
                                    INTO iConsumo
                                    FROM  tmpTarjetas
                                    WHERE numtarjeta
                                    LIKE ''|| TRIM(cTarjeta_parcial) || '%'
                                    AND codstatustarjeta <> 'INA'
                                    AND codstatusasignada <> 'NOA'
                                    AND fechaasignacion >= dFechaInicial
                                    AND fechaasignacion < dFechaFinal
                                    OR
                                    (codstatustarjeta <> 'INA'
                                    AND codstatusasignada = 'NOA'
                                    AND fechaasignacion >= dFechaInicial
                                    AND fechaasignacion <= dFechaActual);

                                END IF;

                                IF NOT EXISTS( SELECT clave_sucursal, clave_tipotarjeta, consumo
                                               FROM estadisticatarjetasuc
                                               WHERE clave_sucursal = cClave_Sucursal
                                               AND clave_tipotarjeta = cClave_Tarjeta
                                               AND fecha = TO_DATE(cFechaEstadistica,'%Y-%m-%d')) THEN
                                    INSERT INTO estadisticatarjetasuc (clave_sucursal, clave_tipotarjeta, fecha, consumo)
                                    VALUES (cClave_Sucursal, cClave_Tarjeta, TO_DATE(cFechaEstadistica,'%Y-%m-%d'), iConsumo);

                                ELSE

                                    UPDATE estadisticatarjetasuc
                                    SET consumo = iConsumo
                                    WHERE clave_sucursal = cClave_Sucursal
                                    AND clave_tipotarjeta = cClave_Tarjeta
                                    AND fecha = TO_DATE(cFechaEstadistica,'%Y-%m-%d');

                                END IF;

                                IF iFlag = 1 THEN
                                    LET iFlag = 0;
                                    LET iConsumo = 0;
                                    LET iNumRegistros = 0;
                                    EXIT WHILE;
                                END IF;

                                LET dFechaInicial = dFechaInicial + 1 UNITS DAY;
                                LET dFechaFinal = dFechaInicial + 1 UNITS DAY;
                        END WHILE;
                        DROP TABLE tmpTarjetas;
                    END FOREACH;
                END FOREACH;

            --COMMIT WORK;
RETURN vcodret, p_mensaje;
END;
END PROCEDURE
;