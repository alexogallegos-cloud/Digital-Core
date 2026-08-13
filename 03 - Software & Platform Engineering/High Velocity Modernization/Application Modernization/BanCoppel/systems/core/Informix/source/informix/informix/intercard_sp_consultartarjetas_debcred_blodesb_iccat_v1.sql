CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_blodesb_iccat_v1 (pempresa CHAR(3), pnumcte CHAR(9), pusuario CHAR(8), pNumRegistros SMALLINT)
RETURNING CHAR(9), CHAR(104), CHAR(16), CHAR(1), CHAR(50), CHAR(4), CHAR(40), CHAR(20), CHAR(60), CHAR(1), CHAR(3), CHAR(9), CHAR(9), CHAR(1);

--@comment Declaracion variables para responder
DEFINE ccodret CHAR(9);
DEFINE error_info VARCHAR(104);
DEFINE isam_err INTEGER;
DEFINE isql_err INTEGER;
DEFINE cnomcliente CHAR(104);
DEFINE cnumtarjeta CHAR(16);
DEFINE ctipotar CHAR(1);
DEFINE cestatustar CHAR(50);
-------------------------
DEFINE cproductotar CHAR(4);
DEFINE cnombreproductotar CHAR(40);
-------------------------
DEFINE cnumcuenta CHAR(20);
DEFINE cnumcuentaAux CHAR(20);
DEFINE cstatuscuenta VARCHAR(3);
DEFINE cstatuscuentadesc CHAR(60);
DEFINE ctitular CHAR(1);
DEFINE ccodestatus CHAR(3);
DEFINE cnumCteTitularCuenta CHAR(9);
DEFINE cnumCteTarjeta CHAR(9);
DEFINE tarjetaBloq CHAR(20);
DEFINE bandBloqueo CHAR(1);
DEFINE cFecha DATETIME YEAR TO FRACTION(3);
DEFINE iExiste INTEGER;
DEFINE cExisteCta INTEGER;
DEFINE cCteCoppelPay CHAR(20);
DEFINE cnumsolicitud CHAR(20);

LET ccodret = "000000000";
LET cnomcliente = "";
LET cnumtarjeta = "";
LET ctipotar = "";
LET cestatustar = "";
-------------------------
LET cproductotar = "";
LET cnombreproductotar = "";
-------------------------
LET cnumcuenta = "";
LET cnumcuentaAux = "";
--LET cstatuscuenta = "";
LET cstatuscuentadesc = "";
LET ctitular = "";
LET ccodestatus = "";
LET cnumCteTitularCuenta="";
LET cnumCteTarjeta="";
LET tarjetaBloq = "";
LET bandBloqueo = "";
LET cFecha = DATE(1);
LET iExiste = 0;
LET cExisteCta = 0;
-------------------------
LET cCteCoppelPay = "";		
LET cnumsolicitud = "";			   

BEGIN
	ON EXCEPTION SET isql_err, isam_err, error_info
		IF isql_err <> 0 THEN
			LET ccodret = isql_err;
			LET cnomcliente = error_info;
			
			DROP TABLE IF EXISTS tbl_cuentascliente;
			DROP TABLE IF EXISTS tbl_tarjetascliente;
			DROP TABLE IF EXISTS tbl_tarjetaspay;
			DROP TABLE IF EXISTS tbl_cuentaspay;
			
			RETURN ccodret, cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnombreproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta, bandBloqueo;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO 'homesysifxElmer713-.out';
	--TRACE ON;

	DROP TABLE IF EXISTS tbl_cuentascliente;
	CREATE TEMP TABLE tbl_cuentascliente (
		numcte CHAR(20),
		producto CHAR(4),
		nombre_producto CHAR(40),
		statuscta CHAR(3),
		tipotar CHAR(1),
		cuenta CHAR(20)
	) WITH NO LOG;
	
	DROP TABLE IF EXISTS tbl_tarjetascliente;
	CREATE TEMP TABLE tbl_tarjetascliente (
	    numtarjeta CHAR(20),
		cuenta CHAR(20),
		numcte CHAR(20)
	) WITH NO LOG;
	
	DROP TABLE IF EXISTS tbl_tarjetaspay;
	CREATE TEMP TABLE tbl_tarjetaspay (
		numtarjeta CHAR(20),
		cuenta CHAR(20),
		numctebanco CHAR(20),
		numctecoppel CHAR(20)
	) WITH NO LOG;
	
	DROP TABLE IF EXISTS tbl_cuentaspay;
	CREATE TEMP TABLE tbl_cuentaspay (
		numtarjeta CHAR(20),
		numero_cuenta CHAR(20),
		numctebanco CHAR(20),
		numctecoppel CHAR(20),
		desccodprodcta CHAR(40),
		codprodcta CHAR(4)
	) WITH NO LOG;

	-- Se llena tabla de paso con cuentas de dÃ©bito del cliente - Nombre Producto Agregado - Modificado Gabriel
	FOREACH WITH HOLD
		SELECT{+INDEX(bdicheq:'informix'.sc_maechq mae1)}
		    cta.num_cte, cta.producto, def.nombre, cta.status_cta, 'D', cta.cuenta
		INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta
		FROM bdicheq:'informix'.sc_maechq cta, bdicheq:'informix'.sc_producto def 
		WHERE cta.producto = def.producto AND cta.num_cte = pnumcte
		
		INSERT INTO 'informix'.tbl_cuentascliente (numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta);
	END FOREACH;

	-- Se llena tabla de paso con cuentas de crÃ©dito del cliente - Modificado Gabriel
	FOREACH WITH HOLD
		SELECT{+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)}
			cta.numcte, cta.num_producto, def.nombre_prod, cta.status_cred, 'C', cta.num_credito
		INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta
		FROM bdicred:'informix'.sd_maecred cta, bdicred:'informix'.sd_definicion def
		WHERE cta.num_producto = def.num_producto AND cta.empresa = pempresa AND cta.numcte = pnumcte

		INSERT INTO 'informix'.tbl_cuentascliente (numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta);
	END FOREACH;

    -- Se llena tabla de paso con cuentas Coppel Pay
    INSERT INTO tbl_cuentaspay (numtarjeta, numero_cuenta, numctebanco, numctecoppel, desccodprodcta, codprodcta)
        SELECT tarcta.numtarjeta, tarcta.numcuenta, rel.numcte_banco, rel.cliente, bin.desccodprodcta, bin.codprodcta		
        FROM bdinteg:'informix'.si_relacion_ctebcplcpl AS rel
        INNER JOIN intercard:'informix'.tarjeta AS tar
            ON rel.numcte_banco = tar.numcliente AND SUBSTR(rel.num_tar_coppelaplazos, 0, 6) = '514014'
        INNER JOIN intercard:'informix'.tarjetacuenta AS tarcta
            ON tar.numtarjeta = tarcta.numtarjeta  	
        INNER JOIN intercard:'informix'.binproducto AS bin
            ON tar.codproductotarjeta = bin.codproductotarjeta AND SUBSTR(bin.codprodcta, 0, 2) = '65' AND bin.producto = SUBSTR(tarcta.numtarjeta, 7, 2)
        WHERE rel.numcte_banco = pnumcte;

    -- Se llena tabla de paso con cuentas de crÃ©dito Coppel Pay del cliente
    FOREACH WITH HOLD
        SELECT numtarjeta, numero_cuenta, numctebanco, numctecoppel
        INTO cnumtarjeta, cnumcuenta, cnumCteTarjeta, cCteCoppelPay
        FROM tbl_cuentaspay

        INSERT INTO 'informix'.tbl_tarjetaspay (numtarjeta, cuenta, numctebanco, numctecoppel)
        VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta, cCteCoppelPay);	

        -- En caso de que se encuentre una tarjeta Coppel Pay, se debe consultar su titular
        SELECT COUNT(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
        IF cExisteCta = 0 THEN
            FOREACH WITH HOLD
                SELECT {+INDEX(bdinteg:'informix'.si_relacion_ctebcplcpl idx_si_relacion_ctebcplcpl_pay)}
                    cpay.numctebanco, cpay.codprodcta, cpay.desccodprodcta, 'Activo', 'C', cpay.numero_cuenta
                INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
                FROM tbl_cuentaspay AS cpay                			
                WHERE cpay.numero_cuenta = cnumcuenta

                INSERT INTO tbl_cuentascliente (numcte, producto, nombre_producto,statuscta , tipotar, cuenta)
                VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
            END FOREACH;
        END IF;
    END FOREACH;

    -- Tarjetas de dÃ©bito
	FOREACH WITH HOLD 
		SELECT DISTINCT(cuenta) INTO cnumcuenta FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'D'

		-- Se llena tabla de paso con tarjetas de dÃ©bito del cliente y de los clientes que tienen cuentas relacionadas al cliente titulares o adicionales
		FOREACH WITH HOLD
			SELECT{+INDEX(bdicheq:'informix'.sc_tarjeta ix_tarjeta4)}
			    trjasig.num_tarjeta, trjasig.numcte
			INTO cnumtarjeta, cnumCteTarjeta
			FROM bdicheq:'informix'.sc_tarjeta trjasig
			WHERE trjasig.cuenta = cnumcuenta AND trjasig.numcte != pnumcte AND trjasig.tipo_tarjeta IN ('T', 'A')

			INSERT INTO 'informix'.tbl_tarjetascliente (numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			-- En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de dÃ©bito relacionada
			SELECT COUNT(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN

				-- Modificado Gabriel
				FOREACH WITH HOLD 
					SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq) } 
					    cta.num_cte, cta.producto, def.nombre, cta.status_cta, 'D', cta.cuenta
					INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
					FROM bdicheq:'informix'.sc_maechq cta, bdicheq:'informix'.sc_producto def
					WHERE cta.producto = def.producto AND cta.cuenta = cnumcuenta

					INSERT INTO tbl_cuentascliente (numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
					VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				END FOREACH;
			END IF;
		END FOREACH;
	END FOREACH;

	FOREACH WITH HOLD
		SELECT{+INDEX(bdicheq:'informix'.sc_tarjeta idx_sd_tarjeta1)}
		    trjasig.num_tarjeta, trjasig.numcte, trjasig.cuenta
		INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
		FROM bdicheq:'informix'.sc_tarjeta trjasig
		WHERE trjasig.numcte = pnumcte AND trjasig.tipo_tarjeta IN ('T', 'A')

		INSERT INTO 'informix'.tbl_tarjetascliente (numtarjeta, cuenta, numcte)
		VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

		-- En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de dÃ©bito relacionada
		SELECT COUNT(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
		IF cExisteCta = 0 THEN

			-- Modificado Gabriel
			FOREACH WITH HOLD
                SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)}
                    cta.num_cte, cta.producto, def.nombre, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta, bdicheq:'informix'.sc_producto def
 				WHERE cta.producto = def.producto AND cta.cuenta = cnumcuenta

				INSERT INTO tbl_cuentascliente (numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
				VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
			END FOREACH;
		END IF;
	END FOREACH;

	-- Se llena tabla de paso con tarjetas de dÃ©bito del cliente y de los crÃ©ditos que tienen cuentas relacionadas al cliente titulares o adicionales
	FOREACH WITH HOLD
		SELECT DISTINCT(cuenta) INTO cnumcuenta FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'C'

		FOREACH WITH HOLD
            SELECT {+INDEX(bdicred:'informix'.sd_tarjeta pry_tarjeta)}
				trjasig.num_tarjeta, trjasig.numcte
			INTO cnumtarjeta, cnumCteTarjeta
			FROM  bdicred:'informix'.sd_tarjeta trjasig
			WHERE trjasig.num_credito = cnumcuenta AND trjasig.numcte != pnumcte AND trjasig.tipo_tarjeta IN ('T', 'A')

			INSERT INTO 'informix'.tbl_tarjetascliente (numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			-- En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de crÃ©dito relacionada
			SELECT COUNT(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN

				-- Modificado Gabriel
				FOREACH WITH HOLD 
					SELECT{+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} 
					    cta.numcte, cta.num_producto, def.nombre_prod, cta.status_cred, 'C', cta.num_credito
					INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
					FROM bdicred:'informix'.sd_maecred cta, bdicred:'informix'.sd_definicion def
					WHERE cta.num_producto = def.num_producto AND cta.empresa = pempresa AND cta.num_credito = cnumcuenta

					INSERT INTO 'informix'.tbl_cuentascliente (numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
					VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				END FOREACH;
			END IF;
		END FOREACH;
	END FOREACH;

	FOREACH WITH HOLD
		SELECT{+INDEX(bdicred:'informix'.sd_tarjeta idx_sd_tarjeta1)}
			trjasig.num_tarjeta, trjasig.numcte, trjasig.num_credito
		INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
		FROM  bdicred:'informix'.sd_tarjeta trjasig
		WHERE trjasig.numcte = pnumcte AND trjasig.tipo_tarjeta IN ('T', 'A')

		INSERT INTO 'informix'.tbl_tarjetascliente (numtarjeta, cuenta, numcte)
		VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

		-- En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de crÃ©dito relacionada
		SELECT COUNT(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
		IF cExisteCta = 0 THEN

			-- Modificado Gabriel
			FOREACH WITH HOLD 
				SELECT{+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} 
                    cta.numcte, cta.num_producto, def.nombre_prod, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta, bdicred:'informix'.sd_definicion def
				WHERE cta.empresa = pempresa AND cta.num_credito = cnumcuenta AND cta.num_producto = def.num_producto

				INSERT INTO 'informix'.tbl_cuentascliente (numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
				VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
			END FOREACH;
		END IF;
	END FOREACH;

	-- Una vez obtenidos los datos anteriores se recorren tarjeta por tarjeta y se obtienen los datos faltantes para regresarlos en el retorno del SP
	FOREACH WITH HOLD
		SELECT SKIP pNumRegistros FIRST 10 DISTINCT(numtarjeta), cuenta, numctebanco, numcte, producto, nombre_producto, statuscta, tipotar, numctecoppel
		INTO cnumtarjeta, cnumcuenta, cnumCteTarjeta, cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar,cCteCoppelPay
		FROM (
			SELECT
				trjasig.numtarjeta, 
				trjasig.cuenta,
				trjasig.numcte AS numctebanco,
				cta.numcte,
                cta.producto,
                cta.nombre_producto,
                cta.statuscta,
                cta.tipotar,
                '' as numctecoppel
			FROM intercard:'informix'.tbl_cuentascliente cta
			LEFT JOIN intercard:'informix'.tbl_tarjetascliente trjasig
				ON cta.cuenta = trjasig.cuenta
			WHERE ((cta.numcte = pnumcte) OR (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte))
			UNION ALL
			SELECT
				trjpay.numtarjeta, 
				trjpay.cuenta,
				trjpay.numctebanco,
				cta.numcte,
                cta.producto,
                cta.nombre_producto,
                cta.statuscta,
                cta.tipotar,
                trjpay.numctecoppel
			FROM intercard:'informix'.tbl_cuentascliente cta
			LEFT JOIN intercard:'informix'.tbl_tarjetaspay AS trjpay
				ON cta.cuenta = trjpay.cuenta
			WHERE cta.numcte = pnumcte
		)
		WHERE numtarjeta IS NOT NULL
		ORDER BY tipotar DESC, numtarjeta ASC
	
		SELECT trj.nombre, trj.codstatustarjeta, trj.titular, trj.numtarjeta
		INTO cnomcliente, ccodestatus, ctitular, cnumtarjeta
		FROM 'informix'.tarjeta trj
		WHERE trj.numtarjeta = cnumtarjeta AND trj.codstatusasignada = 'SIA';

		SELECT trjest.codstatustarjeta, trjest.descstatustarjeta
		INTO ccodestatus, cestatustar
		FROM 'informix'.statustarjeta trjest
		WHERE trjest.codstatustarjeta = ccodestatus;
		
        /*
		IF cestatustar = 'Bloqueada' THEN
			LET cestatustar = 'Bloqueo Temporal';
		END IF;
		
		IF ccodestatus = 'BLT' THEN
			LET ccodestatus = 'BLO';
		END IF;
        */

		IF (cCteCoppelPay != '' OR cCteCoppelPay IS NOT NULL) THEN
			LET cstatuscuentadesc = 'Activo';
		ELIF ctipotar = 'D' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicheq:'informix'.sc_mae_estatus ctaest WHERE ctaest.cod_estatus = cstatuscuenta;
		ELIF ctipotar = 'C' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicred:'informix'.sd_tipocartera ctaest WHERE ctaest.status_cred = cstatuscuenta;
		END IF;

		SELECT MAX(fechahora) INTO cFecha
		FROM intercard:bitacoracambiosstatustarjeta
		WHERE tarjeta = cnumtarjeta;

		SELECT tarjeta
		INTO tarjetaBloq
		FROM intercard:bitacoracambiosstatustarjeta
		WHERE
            fechahora = cFecha
            AND codstatustarjetanvo IN ('BLT', 'BLO')
            AND usuario = pusuario AND tarjeta = cnumtarjeta;

		LET tarjetaBloq = NVL(tarjetaBloq, '');
        
		IF (tarjetaBloq <> '')  THEN
			LET bandBloqueo = 'T';
		ELSE
			LET bandBloqueo = 'F';
		END IF;

		IF cnumtarjeta IS NOT NULL THEN -- TARJETA != 'SIA'
			LET iExiste = iExiste + 1;
			RETURN ccodret,cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnombreproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta, bandBloqueo WITH RESUME;
		END IF;
	END FOREACH;

	DROP TABLE IF EXISTS tbl_cuentascliente;
	DROP TABLE IF EXISTS tbl_tarjetascliente;
	DROP TABLE IF EXISTS tbl_tarjetaspay;
	DROP TABLE IF EXISTS tbl_cuentaspay;

	-- En caso de que el cliente no tenga ninguna tarjeta
	IF iExiste = 0 THEN
		RETURN '000000001', 'No tiene tarjetas', cnumtarjeta, ctipotar, cestatustar, cproductotar, cnombreproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta, bandBloqueo;
	END IF;
END
END PROCEDURE;