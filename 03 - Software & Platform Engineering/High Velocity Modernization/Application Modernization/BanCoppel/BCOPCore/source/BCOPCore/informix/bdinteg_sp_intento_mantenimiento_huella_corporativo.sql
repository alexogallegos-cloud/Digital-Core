CREATE PROCEDURE "informix".sp_intento_mantenimiento_huella_corporativo(p_Empresa CHAR(5), p_sNumeroCliente CHAR(30), p_sNumeroCuenta CHAR(30), p_sNumeroTarjeta CHAR(30), 
				p_sPrimerNombre CHAR(30), p_sSegundoNombre CHAR(30), p_sPrimerApellido CHAR(30), p_sSegundoApellido CHAR(30), p_skip INTEGER)

     RETURNING	CHAR(20) AS numeroCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, 
        CHAR(30) AS segundoNombre, CHAR(5) AS numeroMantenimiento, CHAR(1) AS estatus, CHAR(40) AS nombreSucursal, 
        CHAR(45) AS nombrePromotor, CHAR(8) AS numeroPromotor, DATE AS fechaAltaHuella;

	--definicion de variables--
	DEFINE resultado_numeroCliente          CHAR(20);
    	DEFINE resultado_primerApellido         CHAR(30);
	DEFINE resultado_segundoApellido        CHAR(30);
    	DEFINE resultado_primerNombre           CHAR(30);
    	DEFINE resultado_segundoNombre          CHAR(30);
    	DEFINE resultado_numeroMantenimiento    CHAR(5);
    	DEFINE resultado_estatus                CHAR(1);
    	DEFINE resultado_nombreSucursal         CHAR(40);
    	DEFINE resultado_nombrePromotor         CHAR(45);
    	DEFINE resultado_numeroPromotor         CHAR(8);
    	DEFINE resultado_fechaAltaHuella        DATE;
    	DEFINE cuenta_tarjeta                   CHAR(30);
    	DEFINE iSqlErr                          INTEGER;

     -- InicializaciÃ³n de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
   	LET resultado_numeroMantenimiento = '';
    LET resultado_estatus = '';
    LET resultado_nombreSucursal = '';
	LET resultado_nombrePromotor = '';
	LET resultado_numeroPromotor = '';
    LET resultado_fechaAltaHuella = '';

    SET ISOLATION TO DIRTY READ;

	BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroCliente = '';
                LET resultado_primerApellido = '';
                LET resultado_segundoApellido = '';
                LET resultado_primerNombre = '';
                LET resultado_segundoNombre = '';
                LET resultado_numeroMantenimiento = '';
                LET resultado_estatus = '';
                LET resultado_nombreSucursal = '';
                LET resultado_nombrePromotor = '';
                LET resultado_numeroPromotor = '';
                LET resultado_fechaAltaHuella = '';
                RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                    resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, 
                    resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor,resultado_fechaAltaHuella;
            END IF;
        END EXCEPTION;

        IF p_sNumeroCliente IS NOT NULL AND p_sNumeroCliente <> '' THEN
            FOREACH
                SELECT SKIP p_skip DISTINCT bdinteg:si_huella_temp.numcte, apell_paterno, apell_materno, nombre1, nombre2, bdinteg:si_huella_temp.secuencia, 
                    bdinteg:si_huella_temp.status, si_sucursales.nombre, operador, si_huella_temp.fecha_alta
                INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                    resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, 
                    resultado_nombreSucursal, resultado_numeroPromotor, resultado_fechaAltaHuella     
                FROM bdinteg:si_huella_temp 
                    LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_huella_temp.numcte)
                    LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_huella_temp.sucursal)
                WHERE bdinteg:si_huella_temp.numcte = p_sNumeroCliente
                ORDER BY si_huella_temp.numcte asC, bdinteg:si_huella_temp.secuencia asC

                SELECT nombre 
                INTO resultado_nombrePromotor
                FROM si_ejecut
                WHERE ejecutivo = resultado_numeroPromotor;

                RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_fechaAltaHuella WITH RESUME;
            END FOREACH;
        ELSE
            IF p_sNumeroCuenta IS NOT NULL AND p_sNumeroCuenta <> '' THEN
                FOREACH
                    SELECT num_cte
                    INTO resultado_numeroCliente
                    FROM bdicheq:sc_maechq
                    WHERE empresa = p_Empresa
                      AND cuenta = p_sNumeroCuenta
                    union
                    SELECT num_cte
                    FROM bdinvers:sv_maeinv
                    WHERE empresa = p_Empresa
                      AND cuenta = p_sNumeroCuenta
                    union
                    SELECT numcte
                    FROM bdicred:sd_maecred
                    WHERE empresa = p_Empresa
                      AND num_credito = p_sNumeroCuenta
                END FOREACH;
                IF (resultado_numeroCliente IS NOT NULL AND resultado_numeroCliente <> '') THEN
                    FOREACH
                        SELECT SKIP p_skip DISTINCT bdinteg:si_huella_temp.numcte, apell_paterno, apell_materno, nombre1, nombre2, bdinteg:si_huella_temp.secuencia, 
                            bdinteg:si_huella_temp.status, si_sucursales.nombre, operador, si_huella_temp.fecha_alta
                        INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                            resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, 
                            resultado_nombreSucursal, resultado_numeroPromotor, resultado_fechaAltaHuella     
                        FROM bdinteg:si_huella_temp 
                            LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_huella_temp.numcte)
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_huella_temp.sucursal)
                        WHERE bdinteg:si_huella_temp.numcte = resultado_numeroCliente
                        ORDER BY si_huella_temp.numcte asC, bdinteg:si_huella_temp.secuencia asC

                        SELECT nombre 
                        INTO resultado_nombrePromotor
                        FROM si_ejecut
                        WHERE ejecutivo = resultado_numeroPromotor;

                        RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_fechaAltaHuella WITH RESUME;
                    END FOREACH;
                END IF;
            ELSE
                IF p_sNumeroTarjeta IS NOT NULL AND p_sNumeroTarjeta <> '' THEN

                    SELECT numcuenta
                    INTO cuenta_tarjeta
                    FROM intercard:tarjetacuenta
                    WHERE intercard:tarjetacuenta.numtarjeta = p_sNumeroTarjeta;

                    FOREACH
                        SELECT num_cte
                        into resultado_numeroCliente
                        FROM bdicheq:sc_maechq
                        WHERE empresa = p_Empresa
                          and cuenta = cuenta_tarjeta
                        union
                        SELECT num_cte
                        FROM bdinvers:sv_maeinv
                        WHERE empresa = p_Empresa
                          and cuenta = cuenta_tarjeta
                        union
                        SELECT numcte
                        FROM bdicred:sd_maecred
                        WHERE empresa = p_Empresa
                          and num_credito = cuenta_tarjeta
                    END FOREACH;

                    IF (resultado_numeroCliente IS NOT NULL AND resultado_numeroCliente <> '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_huella_temp.numcte, apell_paterno, apell_materno, nombre1, nombre2, bdinteg:si_huella_temp.secuencia, 
                                bdinteg:si_huella_temp.status, si_sucursales.nombre, operador, si_huella_temp.fecha_alta
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_fechaAltaHuella     
                            FROM bdinteg:si_huella_temp 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_huella_temp.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_huella_temp.sucursal)
                            WHERE bdinteg:si_huella_temp.numcte = resultado_numeroCliente
                            ORDER BY si_huella_temp.numcte asC, bdinteg:si_huella_temp.secuencia asC

                            SELECT nombre 
                            INTO resultado_nombrePromotor
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroPromotor;

                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_fechaAltaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                ELSE
                    IF(p_sSegundoNombre IS NULL OR p_sSegundoNombre = '') AND (p_sSegundoApellido IS NULL OR p_sSegundoApellido = '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_huella_temp.numcte, apell_paterno, apell_materno, nombre1, nombre2, bdinteg:si_huella_temp.secuencia, 
                                bdinteg:si_huella_temp.status, si_sucursales.nombre, operador, si_huella_temp.fecha_alta
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_fechaAltaHuella     
                            FROM bdinteg:si_huella_temp 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_huella_temp.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_huella_temp.sucursal)
                                WHERE nombre1 LIKE (p_sPrimerNombre || '%') 
                                    AND apell_paterno LIKE (p_sPrimerApellido || '%')
                            ORDER BY si_huella_temp.numcte asC, bdinteg:si_huella_temp.secuencia asC

                            SELECT nombre 
                            INTO resultado_nombrePromotor
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroPromotor;

                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_fechaAltaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                    IF(p_sSegundoNombre IS NULL OR p_sSegundoNombre = '') AND (p_sSegundoApellido IS NOT NULL AND p_sSegundoApellido <> '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_huella_temp.numcte, apell_paterno, apell_materno, nombre1, nombre2, bdinteg:si_huella_temp.secuencia, 
                                bdinteg:si_huella_temp.status, si_sucursales.nombre, operador, si_huella_temp.fecha_alta
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_fechaAltaHuella     
                            FROM bdinteg:si_huella_temp 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_huella_temp.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_huella_temp.sucursal)
                                WHERE nombre1 LIKE (p_sPrimerNombre || '%') 
                                    AND apell_paterno LIKE (p_sPrimerApellido || '%')  
                                    AND apell_materno LIKE (p_sSegundoApellido || '%')
                            ORDER BY si_huella_temp.numcte asC, bdinteg:si_huella_temp.secuencia asC

                            SELECT nombre 
                            INTO resultado_nombrePromotor
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroPromotor;

                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_fechaAltaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                    IF(p_sSegundoNombre IS NOT NULL AND p_sSegundoNombre <> '') AND (p_sSegundoApellido IS NULL OR p_sSegundoApellido = '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_huella_temp.numcte, apell_paterno, apell_materno, nombre1, nombre2, bdinteg:si_huella_temp.secuencia, 
                                bdinteg:si_huella_temp.status, si_sucursales.nombre, operador, si_huella_temp.fecha_alta
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_fechaAltaHuella     
                            FROM bdinteg:si_huella_temp 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_huella_temp.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_huella_temp.sucursal)
                            WHERE nombre1 LIKE (p_sPrimerNombre || '%') 
                                AND apell_paterno LIKE (p_sPrimerApellido || '%')  
                                AND nombre2 LIKE (p_sSegundoNombre || '%')
                            ORDER BY si_huella_temp.numcte asC, bdinteg:si_huella_temp.secuencia asC

                            SELECT nombre 
                            INTO resultado_nombrePromotor
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroPromotor;

                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_fechaAltaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                    IF(p_sSegundoNombre IS NOT NULL AND p_sSegundoNombre <> '') AND (p_sSegundoApellido IS NOT NULL AND p_sSegundoApellido <> '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_huella_temp.numcte, apell_paterno, apell_materno, nombre1, nombre2, bdinteg:si_huella_temp.secuencia, 
                                bdinteg:si_huella_temp.status, si_sucursales.nombre, operador, si_huella_temp.fecha_alta
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_fechaAltaHuella     
                            FROM bdinteg:si_huella_temp 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_huella_temp.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_huella_temp.sucursal)
                            WHERE nombre1 LIKE (p_sPrimerNombre || '%') 
                                AND apell_paterno LIKE (p_sPrimerApellido || '%')  
                                AND nombre2 LIKE (p_sSegundoNombre || '%') 
                                AND apell_materno LIKE (p_sSegundoApellido || '%')
                            ORDER BY si_huella_temp.numcte asC, bdinteg:si_huella_temp.secuencia asC

                            SELECT nombre 
                            INTO resultado_nombrePromotor
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroPromotor;

                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_fechaAltaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                END IF;
            END IF;
        END IF;
    END;
END PROCEDURE;