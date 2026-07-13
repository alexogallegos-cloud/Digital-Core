CREATE PROCEDURE "informix".sp_mantenimiento_huella_corporativo(p_Empresa CHAR(5), p_sNumeroCliente CHAR(30), p_sNumeroCuenta CHAR(30), p_sNumeroTarjeta CHAR(30), 
				p_sPrimerNombre CHAR(30), p_sSegundoNombre CHAR(30), p_sPrimerApellido CHAR(30), p_sSegundoApellido CHAR(30), p_skip INTEGER)

      RETURNING	CHAR(20) AS numeroCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, 
        CHAR(30) AS segundoNombre, DATE AS fechaAlta, CHAR(5) AS numeroMantenimiento, CHAR(1) AS estatus, CHAR(40) AS nombreSucursal, 
        CHAR(45) AS nombrePromotor, CHAR(8) AS numeroPromotor, CHAR (45) AS nombreGerente, CHAR(8) AS numeroGerente, 
        CHAR(45) AS nombreCajero, CHAR(8) AS numeroCajero, DATE AS fechaAltaHuella, DATE AS fechaBajaHuella;

	--definicion de variables--
	DEFINE resultado_numeroCliente          CHAR(20);
   	DEFINE resultado_primerApellido         CHAR(30);
	DEFINE resultado_segundoApellido        CHAR(30);
   	DEFINE resultado_primerNombre           CHAR(30);
   	DEFINE resultado_segundoNombre          CHAR(30);
    	DEFINE resultado_fechaAlta              DATE;
    	DEFINE resultado_numeroMantenimiento    CHAR(5);
    	DEFINE resultado_estatus                CHAR(1);
    	DEFINE resultado_nombreSucursal         CHAR(40);
    	DEFINE resultado_nombrePromotor         CHAR(45);
    	DEFINE resultado_numeroPromotor         CHAR(8);
    	DEFINE resultado_nombreGerente          CHAR(45);
    	DEFINE resultado_numeroGerente          CHAR(8);
    	DEFINE resultado_numeroUsuario          CHAR(8);
    	DEFINE resultado_nombreCajero           CHAR(45);
    	DEFINE resultado_numeroCajero           CHAR(8);
    	DEFINE resultado_fechaAltaHuella        DATE;
    	DEFINE resultado_fechaBajaHuella        DATE;
    	DEFINE cuenta_tarjeta                   CHAR(30);
    	DEFINE iSqlErr                          INTEGER;

     -- InicializaciÃ³n de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
    LET resultado_fechaAlta = '';
    LET resultado_numeroMantenimiento = '';
    LET resultado_estatus = '';
    LET resultado_nombreSucursal = '';
	LET resultado_nombrePromotor = '';
	LET resultado_numeroPromotor = '';
	LET resultado_nombreGerente = '';
	LET resultado_numeroGerente = '';
    LET resultado_numeroUsuario =  '';
    LET resultado_nombreCajero = '';
    LET resultado_numeroCajero = '';
    LET resultado_fechaAltaHuella = '';
    LET resultado_fechaBajaHuella = '';

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
                LET resultado_fechaAlta = '';
                LET resultado_numeroMantenimiento = '';
                LET resultado_estatus = '';
                LET resultado_nombreSucursal = '';
                LET resultado_nombrePromotor = '';
                LET resultado_numeroPromotor = '';
                LET resultado_nombreGerente = '';
                LET resultado_numeroGerente = '';
		LET resultado_numeroUsuario =  '';
                LET resultado_nombreCajero = '';
                LET resultado_numeroCajero = '';
                LET resultado_fechaAltaHuella = '';
                LET resultado_fechaBajaHuella = '';
                RETURN 	resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
						resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, 
						resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_nombreGerente, 
						resultado_numeroGerente, resultado_nombreCajero, resultado_numeroCajero, resultado_fechaAltaHuella, 
						resultado_fechaBajaHuella;
            END IF;
        END EXCEPTION;
        
        IF p_sNumeroCliente IS NOT NULL AND p_sNumeroCliente <> '' THEN
            FOREACH
                SELECT SKIP p_skip DISTINCT bdinteg:si_cte_huella.numcte, apell_paterno, apell_materno, nombre1, nombre2, si_cliente.fecha_alta, bdinteg:si_cte_huella.secuencia, 
                    bdinteg:si_cte_huella.estado, si_sucursales.nombre, operador, empleado, usuario3, si_cte_huella.fecha_alta, bdinteg:si_cte_huella.usuario
                INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                    resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, 
                    resultado_nombreSucursal, resultado_numeroPromotor, resultado_numeroGerente, resultado_numeroCajero, 
                    resultado_fechaAltaHuella, resultado_numeroUsuario
                FROM bdinteg:si_cte_huella 
                    LEFT JOIN bdinteg:si_cliente 
                        ON (bdinteg:si_cliente.numcte = bdinteg:si_cte_huella.numcte)
                    LEFT JOIN bdinteg:si_sucursales 
                        ON (bdinteg:si_sucursales.empresa =  p_Empresa
                            AND bdinteg:si_sucursales.sucursal = bdinteg:si_cte_huella.sucursal)
                    LEFT JOIN bdinteg:si_huella_temp 
                        ON (bdinteg:si_cte_huella.numcte = bdinteg:si_huella_temp.numcte 
                            AND bdinteg:si_cte_huella.secuencia - 1 =  bdinteg:si_huella_temp.secuencia
                            AND bdinteg:si_cte_huella.fecha_alta = Date(bdinteg:si_huella_temp.fecha_alta)
	                    AND bdinteg:si_cte_huella.usuario = bdinteg:si_huella_temp.operador)
                WHERE bdinteg:si_cte_huella.numcte = p_sNumeroCliente
                ORDER BY si_cte_huella.numcte asC, bdinteg:si_cte_huella.secuencia asC

				IF resultado_numeroMantenimiento == 1 THEN
                   LET resultado_nombrePromotor = 'ALTA DE HUELLA';
                   LET resultado_numeroPromotor = resultado_numeroUsuario;
                ELSE
					SELECT nombre 
			        INTO resultado_nombrePromotor
			        FROM si_ejecut
			        WHERE ejecutivo = resultado_numeroPromotor;
				END IF;

                SELECT nombre 
                INTO resultado_nombreGerente
                FROM si_ejecut
                WHERE ejecutivo = resultado_numeroGerente;

                SELECT nombre 
                INTO resultado_nombreCajero
                FROM si_ejecut
                WHERE ejecutivo = resultado_numeroCajero;

                SELECT fecha_alta 
                INTO resultado_fechaBajaHuella
                FROM bdinteg:si_cte_huella
                WHERE secuencia = resultado_numeroMantenimiento + 1
                    AND numcte = resultado_numeroCliente;
                RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_nombreGerente, resultado_numeroGerente, resultado_nombreCajero, resultado_numeroCajero, resultado_fechaAltaHuella, resultado_fechaBajaHuella WITH RESUME;
            END FOREACH;
        ELSE
            IF p_sNumeroCuenta IS NOT NULL AND p_sNumeroCuenta <> '' THEN
                FOREACH
                    SELECT num_cte
                    INTO resultado_numeroCliente
                    FROM bdicheq:sc_maechq
                    WHERE cuenta = p_sNumeroCuenta
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
                        SELECT SKIP p_skip DISTINCT bdinteg:si_cte_huella.numcte, apell_paterno, apell_materno, nombre1, nombre2, si_cliente.fecha_alta, bdinteg:si_cte_huella.secuencia, 
                            bdinteg:si_cte_huella.estado, si_sucursales.nombre, operador, empleado, usuario3, si_cte_huella.fecha_alta, bdinteg:si_cte_huella.usuario
                        INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                            resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, 
                            resultado_nombreSucursal, resultado_numeroPromotor, resultado_numeroGerente, resultado_numeroCajero, 
                            resultado_fechaAltaHuella, resultado_numeroUsuario   
                        FROM bdinteg:si_cte_huella 
                            LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_cte_huella.numcte)
                            LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_cte_huella.sucursal)
                            LEFT JOIN bdinteg:si_huella_temp ON (bdinteg:si_cte_huella.numcte = bdinteg:si_huella_temp.numcte 
                                AND bdinteg:si_cte_huella.secuencia - 1 =  bdinteg:si_huella_temp.secuencia 
                                AND bdinteg:si_cte_huella.fecha_alta = Date(bdinteg:si_huella_temp.fecha_alta)
	                    AND bdinteg:si_cte_huella.usuario = bdinteg:si_huella_temp.operador)
                        WHERE bdinteg:si_cte_huella.numcte = resultado_numeroCliente
                        ORDER BY si_cte_huella.numcte asC, bdinteg:si_cte_huella.secuencia asC

						IF resultado_numeroMantenimiento == 1 THEN
		                   LET resultado_nombrePromotor = 'ALTA DE HUELLA';
		                   LET resultado_numeroPromotor = resultado_numeroUsuario;
		                ELSE
			                SELECT nombre 
			                INTO resultado_nombrePromotor
			                FROM si_ejecut
			                WHERE ejecutivo = resultado_numeroPromotor;
						END IF;

                        SELECT nombre 
                        INTO resultado_nombreGerente
                        FROM si_ejecut
                        WHERE ejecutivo = resultado_numeroGerente;

                        SELECT nombre 
                        INTO resultado_nombreCajero
                        FROM si_ejecut
                        WHERE ejecutivo = resultado_numeroCajero;

                        SELECT fecha_alta 
                        INTO resultado_fechaBajaHuella
                        FROM bdinteg:si_cte_huella
                        WHERE secuencia = resultado_numeroMantenimiento + 1
                            AND numcte = resultado_numeroCliente;
                        RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_nombreGerente, resultado_numeroGerente, resultado_nombreCajero, resultado_numeroCajero, resultado_fechaAltaHuella, resultado_fechaBajaHuella WITH RESUME;
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
                          AND cuenta = cuenta_tarjeta
                        union
                        SELECT num_cte
                        FROM bdinvers:sv_maeinv
                        WHERE empresa = p_Empresa
                          AND cuenta = cuenta_tarjeta
                        union
                        SELECT numcte
                        FROM bdicred:sd_maecred
                        WHERE empresa = p_Empresa
                          AND num_credito = cuenta_tarjeta
                    END FOREACH;

                    IF (resultado_numeroCliente IS NOT NULL AND resultado_numeroCliente <> '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_cte_huella.numcte, apell_paterno, apell_materno, nombre1, nombre2, si_cliente.fecha_alta, bdinteg:si_cte_huella.secuencia, 
                                bdinteg:si_cte_huella.estado, si_sucursales.nombre, operador, empleado, usuario3, si_cte_huella.fecha_alta, bdinteg:si_cte_huella.usuario
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_numeroGerente, resultado_numeroCajero, 
                                resultado_fechaAltaHuella, resultado_numeroUsuario      
                            FROM bdinteg:si_cte_huella 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_cte_huella.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_cte_huella.sucursal)
                                LEFT JOIN bdinteg:si_huella_temp ON (bdinteg:si_cte_huella.numcte = bdinteg:si_huella_temp.numcte 
                                    AND bdinteg:si_cte_huella.secuencia - 1 =  bdinteg:si_huella_temp.secuencia 
                                    AND bdinteg:si_cte_huella.fecha_alta = Date(bdinteg:si_huella_temp.fecha_alta)
		                    AND bdinteg:si_cte_huella.usuario = bdinteg:si_huella_temp.operador)
                            WHERE bdinteg:si_cte_huella.numcte = resultado_numeroCliente
                            ORDER BY si_cte_huella.numcte asC, bdinteg:si_cte_huella.secuencia asC

			    			IF resultado_numeroMantenimiento == 1 THEN
					           LET resultado_nombrePromotor = 'ALTA DE HUELLA';
					           LET resultado_numeroPromotor = resultado_numeroUsuario;
					        ELSE
				                SELECT nombre 
				                INTO resultado_nombrePromotor
				                FROM si_ejecut
				                WHERE ejecutivo = resultado_numeroPromotor;
							END IF;

                            SELECT nombre 
                            INTO resultado_nombreGerente
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroGerente;

                            SELECT nombre 
                            INTO resultado_nombreCajero
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroCajero;

                            SELECT fecha_alta 
                            INTO resultado_fechaBajaHuella
                            FROM bdinteg:si_cte_huella
                            WHERE secuencia = resultado_numeroMantenimiento + 1
                                AND numcte = resultado_numeroCliente;
                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_nombreGerente, resultado_numeroGerente, resultado_nombreCajero, resultado_numeroCajero, resultado_fechaAltaHuella, resultado_fechaBajaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                ELSE
                    IF(p_sSegundoNombre IS NULL OR p_sSegundoNombre = '') AND (p_sSegundoApellido IS NULL OR p_sSegundoApellido = '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_cte_huella.numcte, apell_paterno, apell_materno, nombre1, nombre2, si_cliente.fecha_alta, bdinteg:si_cte_huella.secuencia, 
                                bdinteg:si_cte_huella.estado, si_sucursales.nombre, operador, empleado, usuario3, si_cte_huella.fecha_alta, bdinteg:si_cte_huella.usuario
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_numeroGerente, resultado_numeroCajero, 
                                resultado_fechaAltaHuella, resultado_numeroUsuario      
                            FROM bdinteg:si_cte_huella 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_cte_huella.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_cte_huella.sucursal)
                                LEFT JOIN bdinteg:si_huella_temp ON (bdinteg:si_cte_huella.numcte = bdinteg:si_huella_temp.numcte 
                                    AND bdinteg:si_cte_huella.secuencia - 1 =  bdinteg:si_huella_temp.secuencia 
                                    AND bdinteg:si_cte_huella.fecha_alta = Date(bdinteg:si_huella_temp.fecha_alta)
		                    AND bdinteg:si_cte_huella.usuario = bdinteg:si_huella_temp.operador)
                                WHERE nombre1 LIKE (TRIM(p_sPrimerNombre) || '%') 
                                    AND apell_paterno LIKE (TRIM(p_sPrimerApellido) || '%')
                            ORDER BY si_cte_huella.numcte asC, bdinteg:si_cte_huella.secuencia asC

			    			IF resultado_numeroMantenimiento == 1 THEN
					           LET resultado_nombrePromotor = 'ALTA DE HUELLA';
					           LET resultado_numeroPromotor = resultado_numeroUsuario;
					        ELSE
		                        SELECT nombre 
		                        INTO resultado_nombrePromotor
		                        FROM si_ejecut
		                        WHERE ejecutivo = resultado_numeroPromotor;
							END IF;

                            SELECT nombre 
                            INTO resultado_nombreGerente
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroGerente;

                            SELECT nombre 
                            INTO resultado_nombreCajero
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroCajero;

                            SELECT fecha_alta 
                            INTO resultado_fechaBajaHuella
                            FROM bdinteg:si_cte_huella
                            WHERE secuencia = resultado_numeroMantenimiento + 1
                                AND numcte = resultado_numeroCliente;
                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_nombreGerente, resultado_numeroGerente, resultado_nombreCajero, resultado_numeroCajero, resultado_fechaAltaHuella, resultado_fechaBajaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                    IF(p_sSegundoNombre IS NULL OR p_sSegundoNombre = '') AND (p_sSegundoApellido IS NOT NULL AND p_sSegundoApellido <> '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_cte_huella.numcte, apell_paterno, apell_materno, nombre1, nombre2, si_cliente.fecha_alta, bdinteg:si_cte_huella.secuencia, 
                                bdinteg:si_cte_huella.estado, si_sucursales.nombre, operador, empleado, usuario3, si_cte_huella.fecha_alta, bdinteg:si_cte_huella.usuario
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_numeroGerente, resultado_numeroCajero, 
                                resultado_fechaAltaHuella, resultado_numeroUsuario      
                            FROM bdinteg:si_cte_huella 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_cte_huella.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_cte_huella.sucursal)
                                LEFT JOIN bdinteg:si_huella_temp ON (bdinteg:si_cte_huella.numcte = bdinteg:si_huella_temp.numcte 
                                    AND bdinteg:si_cte_huella.secuencia - 1 =  bdinteg:si_huella_temp.secuencia 
                                    AND bdinteg:si_cte_huella.fecha_alta = Date(bdinteg:si_huella_temp.fecha_alta)
		                    AND bdinteg:si_cte_huella.usuario = bdinteg:si_huella_temp.operador)
                                WHERE nombre1 LIKE (TRIM(p_sPrimerNombre) || '%') 
                                    AND apell_paterno LIKE (TRIM(p_sPrimerApellido) || '%')  
                                    AND apell_materno LIKE (TRIM(p_sSegundoApellido) || '%')
                            ORDER BY si_cte_huella.numcte asC, bdinteg:si_cte_huella.secuencia asC

			    			IF resultado_numeroMantenimiento == 1 THEN
					           LET resultado_nombrePromotor = 'ALTA DE HUELLA';
					           LET resultado_numeroPromotor = resultado_numeroUsuario;
					        ELSE
		                        SELECT nombre 
		                        INTO resultado_nombrePromotor
		                        FROM si_ejecut
		                        WHERE ejecutivo = resultado_numeroPromotor;
							END IF;

                            SELECT nombre 
                            INTO resultado_nombreGerente
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroGerente;

                            SELECT nombre 
                            INTO resultado_nombreCajero
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroCajero;

                            SELECT fecha_alta 
                            INTO resultado_fechaBajaHuella
                            FROM bdinteg:si_cte_huella
                            WHERE secuencia = resultado_numeroMantenimiento + 1
                                AND numcte = resultado_numeroCliente;
                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_nombreGerente, resultado_numeroGerente, resultado_nombreCajero, resultado_numeroCajero, resultado_fechaAltaHuella, resultado_fechaBajaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                    IF(p_sSegundoNombre IS NOT NULL AND p_sSegundoNombre <> '') AND (p_sSegundoApellido IS NULL OR p_sSegundoApellido = '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_cte_huella.numcte, apell_paterno, apell_materno, nombre1, nombre2, si_cliente.fecha_alta, bdinteg:si_cte_huella.secuencia, 
                                bdinteg:si_cte_huella.estado, si_sucursales.nombre, operador, empleado, usuario3, si_cte_huella.fecha_alta, bdinteg:si_cte_huella.usuario
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_numeroGerente, resultado_numeroCajero, 
                                resultado_fechaAltaHuella, resultado_numeroUsuario      
                            FROM bdinteg:si_cte_huella 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_cte_huella.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_cte_huella.sucursal)
                                LEFT JOIN bdinteg:si_huella_temp ON (bdinteg:si_cte_huella.numcte = bdinteg:si_huella_temp.numcte 
                                    AND bdinteg:si_cte_huella.secuencia - 1 =  bdinteg:si_huella_temp.secuencia 
                                    AND bdinteg:si_cte_huella.fecha_alta = Date(bdinteg:si_huella_temp.fecha_alta)
		                    AND bdinteg:si_cte_huella.usuario = bdinteg:si_huella_temp.operador)
                            WHERE nombre1 LIKE (TRIM(p_sPrimerNombre) || '%') 
                                AND apell_paterno LIKE (TRIM(p_sPrimerApellido) || '%')  
                                AND nombre2 LIKE (TRIM(p_sSegundoNombre) || '%')
                            ORDER BY si_cte_huella.numcte asC, bdinteg:si_cte_huella.secuencia asC

			    			IF resultado_numeroMantenimiento == 1 THEN
					           LET resultado_nombrePromotor = 'ALTA DE HUELLA';
					           LET resultado_numeroPromotor = resultado_numeroUsuario;
					        ELSE
			                    SELECT nombre 
		                        INTO resultado_nombrePromotor
		                        FROM si_ejecut
		                        WHERE ejecutivo = resultado_numeroPromotor;
							END IF;

                            SELECT nombre 
                            INTO resultado_nombreGerente
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroGerente;

                            SELECT nombre 
                            INTO resultado_nombreCajero
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroCajero;

                            SELECT fecha_alta 
                            INTO resultado_fechaBajaHuella
                            FROM bdinteg:si_cte_huella
                            WHERE secuencia = resultado_numeroMantenimiento + 1
                                AND numcte = resultado_numeroCliente;
                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_nombreGerente, resultado_numeroGerente, resultado_nombreCajero, resultado_numeroCajero, resultado_fechaAltaHuella, resultado_fechaBajaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                    IF(p_sSegundoNombre IS NOT NULL AND p_sSegundoNombre <> '') AND (p_sSegundoApellido IS NOT NULL AND p_sSegundoApellido <> '') THEN
                        FOREACH
                            SELECT SKIP p_skip DISTINCT bdinteg:si_cte_huella.numcte, apell_paterno, apell_materno, nombre1, nombre2, si_cliente.fecha_alta, bdinteg:si_cte_huella.secuencia, 
                                bdinteg:si_cte_huella.estado, si_sucursales.nombre, operador, empleado, usuario3, si_cte_huella.fecha_alta, bdinteg:si_cte_huella.usuario
                            INTO resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, 
                                resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, 
                                resultado_nombreSucursal, resultado_numeroPromotor, resultado_numeroGerente, resultado_numeroCajero, 
                                resultado_fechaAltaHuella, resultado_numeroUsuario      
                            FROM bdinteg:si_cte_huella 
                                LEFT JOIN bdinteg:si_cliente ON (bdinteg:si_cliente.numcte = bdinteg:si_cte_huella.numcte)
                                LEFT JOIN bdinteg:si_sucursales ON (bdinteg:si_sucursales.sucursal = bdinteg:si_cte_huella.sucursal)
                                LEFT JOIN bdinteg:si_huella_temp ON (bdinteg:si_cte_huella.numcte = bdinteg:si_huella_temp.numcte 
                                    AND bdinteg:si_cte_huella.secuencia - 1 =  bdinteg:si_huella_temp.secuencia 
                                    AND bdinteg:si_cte_huella.fecha_alta = Date(bdinteg:si_huella_temp.fecha_alta)
		                    AND bdinteg:si_cte_huella.usuario = bdinteg:si_huella_temp.operador)
                            WHERE nombre1 LIKE (TRIM(p_sPrimerNombre) || '%') 
                                AND apell_paterno LIKE (TRIM(p_sPrimerApellido) || '%')
                                AND nombre2 LIKE (TRIM(p_sSegundoNombre) || '%') 
                                AND apell_materno LIKE (TRIM(p_sSegundoApellido) || '%')
                            ORDER BY si_cte_huella.numcte asC, bdinteg:si_cte_huella.secuencia asC

			    			IF resultado_numeroMantenimiento == 1 THEN
					           LET resultado_nombrePromotor = 'ALTA DE HUELLA';
					           LET resultado_numeroPromotor = resultado_numeroUsuario;
					        ELSE
		                        SELECT nombre 
		                        INTO resultado_nombrePromotor
		                        FROM si_ejecut
		                        WHERE ejecutivo = resultado_numeroPromotor;
							END IF;

                            SELECT nombre 
                            INTO resultado_nombreGerente
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroGerente;

                            SELECT nombre 
                            INTO resultado_nombreCajero
                            FROM si_ejecut
                            WHERE ejecutivo = resultado_numeroCajero;

                            SELECT fecha_alta 
                            INTO resultado_fechaBajaHuella
                            FROM bdinteg:si_cte_huella
                            WHERE secuencia = resultado_numeroMantenimiento + 1
                                AND numcte = resultado_numeroCliente;
                            RETURN resultado_numeroCliente, resultado_primerApellido, resultado_segundoApellido, resultado_primerNombre, resultado_segundoNombre, resultado_fechaAlta, resultado_numeroMantenimiento, resultado_estatus, resultado_nombreSucursal, resultado_nombrePromotor, resultado_numeroPromotor, resultado_nombreGerente, resultado_numeroGerente, resultado_nombreCajero, resultado_numeroCajero, resultado_fechaAltaHuella, resultado_fechaBajaHuella WITH RESUME;
                        END FOREACH;
                    END IF;
                END IF;
            END IF;
        END IF;
    END;
END PROCEDURE;