CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_rep_iccat_v1(pempresa CHAR(3), pnumcte CHAR(9), pNumRegistros SMALLINT)
RETURNING char(9),char(104),char(16), char(1), char(50), char(4), char(40), char(20), char(60), char(1), char(3),char(9),char(9);

--@comment: Declaracion variables para responder
DEFINE ccodret char(9);
DEFINE isam_err integer;
DEFINE error_info varchar(104);
DEFINE isql_err integer;
DEFINE cnomcliente char (104);
DEFINE cnumtarjeta char (16);
DEFINE ctipotar char(1);
DEFINE cestatustar char (50);
-------
DEFINE cproductotar char(4);
DEFINE cnombreproductotar char(40);
-------
DEFINE cnumcuenta char (20);
DEFINE cnumcuentaAux char (20);
DEFINE cstatuscuenta char (3);
DeFINE cstatuscuentadesc char (60);
DEFINE ctitular char (1);
DEFINE ccodestatus char (3);
DEFINE cnombre1 char(20);
DEFINE cnombre2 char(20);
DEFINE paterno char(20);
DEFINE materno char(20);
DEFINE cnumCteTitularCuenta char(9);
DEFINE cnumCteTarjeta char(9);
DEFINE iExiste INTEGER;
DEFINE cExisteCta INTEGER;

LET ccodret = "000000000";
LET cnomcliente = "";
LET cnumtarjeta = "";
LET ctipotar = "";
LET cestatustar = "";
----------------------
LET cproductotar = "";
LET cnombreproductotar = "";
--------------
LET cnumcuenta = "";
LET cnumcuentaAux = "";
LET cstatuscuenta = "";
LET cstatuscuentadesc = "";
LET ctitular = "";
LET ccodestatus = "";
LET cnumCteTitularCuenta="";
LET cnumCteTarjeta="";
LET iExiste = 0;
LET cExisteCta = 0;

BEGIN

	ON EXCEPTION SET isql_err,isam_err, error_info
		IF isql_err <> 0 THEN
			LET ccodret = isql_err;
			LET cnomcliente = error_info;
			
			DROP TABLE IF EXISTS tbl_cuentascliente;
			DROP TABLE IF EXISTS tbl_tarjetascliente;
			
			RETURN ccodret,cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnombreproductotar, cnumcuenta, cstatuscuenta, ctitular, ccodestatus,cnumCteTitularCuenta,cnumCteTarjeta;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/tmp/sp_consultartarjetas_debcred_rep_iccat.out';
	--TRACE ON;

	DROP TABLE IF EXISTS tbl_cuentascliente;
	CREATE TEMP TABLE tbl_cuentascliente(
		numcte CHAR(20),
		producto CHAR(4),
		nombre_producto CHAR(40),
		statuscta CHAR(3),
		tipotar CHAR(1),
		cuenta CHAR(20)
	) WITH NO LOG;

	DROP TABLE IF EXISTS tbl_tarjetascliente;
	CREATE TEMP TABLE tbl_tarjetascliente(
		numtarjeta CHAR(20),
		cuenta CHAR(20),
		numcte CHAR(20)
	) WITH NO LOG;

	--Se llena tabla de paso con cuentas de debito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq mae1)}
		cta.num_cte, cta.producto, def.nombre, cta.status_cta, 'D', cta.cuenta
		INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicheq:'informix'.sc_maechq cta, bdicheq:'informix'.sc_producto def 
			WHERE cta.num_cte = pnumcte
			AND cta.producto = '2400' 
			and def.producto = cta.producto

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con cuentas de credito del cliente
	FOREACH WITH HOLD
	        SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)}
			cta.numcte, cta.num_producto, def.nombre_prod, cta.status_cred, 'C', cta.num_credito
			INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicred:'informix'.sd_maecred cta, bdicred:'informix'.sd_definicion def
			WHERE cta.numcte = pnumcte 
			AND cta.num_producto IN ('7000', '8100') 
			and cta.num_producto = def.num_producto

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con tarjetas de debito del cliente y de los clientes que tienen cuentas relacionadas al cliente titulares o adicionales
	FOREACH WITH HOLD
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'D'
	
		FOREACH WITH HOLD SELECT  {+INDEX(bdicheq:'informix'.sc_tarjeta ix_tarjeta4)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.cuenta = cnumcuenta
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				--MODIFICADO GABRIEL
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} 
				cta.num_cte, cta.producto, def.nombre, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta, bdicheq:'informix'.sc_producto def
				WHERE cta.cuenta = cnumcuenta 
				AND cta.producto = '2400' 
				AND cta.producto = def.producto
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

		END FOREACH;
		
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.cuenta
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')
				

				INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
				VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				--MODIFICADO GABRIEL
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} 
				cta.num_cte, cta.producto, def.nombre, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta, bdicheq:'informix'.sc_producto def
				WHERE cta.cuenta = cnumcuenta 
				AND cta.producto = '2400' 
				AND cta.producto = def.producto
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

	END FOREACH;

	FOREACH WITH HOLD 
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'C'
	
		--Se llena tabla de paso con tarjetas de debito del cliente y de los credito que tienen cuentas relacionadas al cliente titulares o adicionales
		FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta pry_tarjeta)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.num_credito = cnumcuenta 
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--MODIFICADO GABRIEL
			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)}
				cta.numcte, cta.num_producto, def.nombre_prod, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta, bdicred:'informix'.sd_definicion def
				WHERE cta.empresa = pempresa AND cta.num_credito = cnumcuenta 
				AND cta.num_producto IN ('7000', '8100') 
				AND cta.num_producto = def.num_producto
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

		END FOREACH;
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.num_credito
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				--MODIFICADO GABRIEL
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} 
				cta.numcte, cta.num_producto, def.nombre_prod, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta, bdicred:'informix'.sd_definicion def
				WHERE cta.empresa = pempresa AND cta.num_credito = cnumcuenta
				AND cta.num_producto IN ('7000', '8100') 
				AND cta.num_producto = def.num_producto
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, nombre_producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

	END FOREACH;
	
	
	--Una vez obtenidos los datos anteriores se recorren tarjeta por tarjeta y se obtienen los datos faltantes para regresarlos en el retorno del SPL
	FOREACH WITH HOLD
			SELECT SKIP pNumRegistros FIRST 10
				trjasig.numtarjeta, trjasig.cuenta, trjasig.numcte, cta.numcte, cta.producto, cta.nombre_producto, cta.statuscta, cta.tipotar
			INTO cnumtarjeta, cnumcuenta, cnumCteTarjeta, cnumCteTitularCuenta, cproductotar, cnombreproductotar, cstatuscuenta, ctipotar
			FROM 'informix'.tbl_tarjetascliente trjasig INNER JOIN 'informix'.tbl_cuentascliente cta
			ON cta.cuenta = trjasig.cuenta
			WHERE ((cta.numcte = pnumcte)
			OR (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte))
			ORDER BY cta.tipotar DESC, trjasig.numtarjeta ASC

		SELECT trj.nombre, trj.codstatustarjeta, trj.titular, trj.numtarjeta
		INTO cnomcliente, ccodestatus, ctitular, cnumtarjeta
		FROM 'informix'.tarjeta trj
		WHERE trj.numtarjeta = cnumtarjeta AND trj.codstatusasignada = 'SIA';

		SELECT trjest.codstatustarjeta, trjest.descstatustarjeta
		INTO ccodestatus, cestatustar
		FROM 'informix'.statustarjeta trjest
		WHERE trjest.codstatustarjeta = ccodestatus;

		IF TRIM(ctipotar) = 'D' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicheq:'informix'.sc_mae_estatus ctaest WHERE ctaest.cod_estatus = cstatuscuenta;
		ELIF TRIM(ctipotar) = 'C' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicred:'informix'.sd_tipocartera ctaest WHERE ctaest.status_cred = cstatuscuenta;
		END IF;

		LET cnombre1='';
		LET cnombre2='';
		LET paterno='';
		LET materno='';

		FOREACH
			SELECT FIRST 1 s.nombre1,s.nombre2,s.apaterno,s.amaterno
			INTO cnombre1,cnombre2,paterno,materno
			FROM "informix".solicitudtarjeta s INNER JOIN "informix".detalle_maquila d ON (s.idsolicitud = d.idsolicitud)
			WHERE s.numcuenta = cnumcuenta AND d.numtarjeta = cnumtarjeta
			ORDER BY s.fechasolicitud DESC
		END FOREACH
		--ExtracciÃ³n de nombre de tabla alterna
		IF TRIM(NVL(cnombre1,''))='' AND TRIM(NVL(cnombre2,''))='' THEN
			--SELECT s.nombre1,s.nombre2,s.apaterno,s.amaterno
			--INTO cnombre1,cnombre2,paterno,materno
			SELECT s.nombre1, SUBSTRING( TRIM(s.apaterno) FROM 1 FOR ( 20 - char_length(TRIM(s.nombre1)) ) ) AS apaterno
			INTO cnombre1,paterno
			FROM "informix".solicitudtarjeta s INNER JOIN bdicred:"informix".sd_credito_upgrade cu ON (s.numcliente = cu.numcte AND s.numcuenta = cu.num_credito)
			INNER JOIN intercard:"informix".detalle_maquila de ON (s.idsolicitud = de.idsolicitud AND de.numtarjeta = cnumtarjeta)
			WHERE cu.numero_credito_upgrade = cnumcuenta AND cu.numerotarjeta_upgrade = cnumtarjeta;
			
			--IF char_length(TRIM(NVL(cnombre1,'')))<=1 OR char_length(TRIM(NVL(paterno,'')))<=1 THEN	--Se modifica funcion
			IF LENGTH(TRIM(NVL(cnombre1,'')))<=1 OR LENGTH(TRIM(NVL(paterno,'')))<=1 THEN
				SELECT nombre1, SUBSTRING( TRIM(apell_paterno) FROM 1 FOR ( 20 - char_length(TRIM(nombre1)) ) ) AS apaterno
				INTO cnombre1,paterno
				FROM bdinteg:si_cliente WHERE numcte=pnumcte;
			END IF;
		END IF;
		
		IF TRIM(NVL(cnombre1,''))='' THEN
			LET cnombre1='-';
		END IF;
		IF TRIM(NVL(cnombre2,''))='' THEN
			LET cnombre2='-';
		END IF;
		IF TRIM(NVL(paterno,''))='' THEN
			LET paterno='-';
		END IF;
		IF TRIM(NVL(materno,''))='' THEN
			LET materno='-';
		END IF;
		LET cnomcliente = cnombre1||'|'||cnombre2||'|'||paterno||'|'||materno;

		IF cnumtarjeta IS NOT NULL THEN -- TARJETA != 'SIA'
			RETURN ccodret, cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnombreproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta WITH RESUME;
                        --DROP TABLE IF EXISTS tbl_cuentascliente;
                        --DROP TABLE IF EXISTS tbl_tarjetascliente;
		END IF;

		LET iExiste = iExiste + 1;

	END FOREACH
	
	DROP TABLE IF EXISTS tbl_cuentascliente;
    DROP TABLE IF EXISTS tbl_tarjetascliente;

	--En caso de que el cliente no tenga ninguna tarjeta
	IF iExiste = 0 THEN
		RETURN '000000001', 'No tiene tarjetas', cnumtarjeta, ctipotar, cestatustar, cproductotar, cnombreproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta;
                --DROP TABLE IF EXISTS tbl_cuentascliente;
                --DROP TABLE IF EXISTS tbl_tarjetascliente;
	END IF;

END
END PROCEDURE
;