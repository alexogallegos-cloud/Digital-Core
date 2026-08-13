CREATE PROCEDURE "informix".sp_actualizaremesa(p_categoria CHAR(2), p_convenio CHAR(5), p_referencia CHAR(40), p_nombre1 CHAR(40), p_nombre2 CHAR(40), p_appaterno CHAR(40), p_apmaterno CHAR(40), p_fecha_nac DATE, p_moneda_origen VARCHAR(3), p_importe_origen MONEY)
RETURNING CHAR(5), INTEGER;

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
	DEFINE vCodRet          CHAR(5);
	DEFINE vnombres			CHAR(85);
	DEFINE vRfc				CHAR(13);
	DEFINE vcuenta			INTEGER;
    DEFINE iSqlErr			INTEGER;

	-- Inicializa variables
	LET iSqlErr				= 0;
	LET cCodRet            	= "00000";
	LET vcuenta				= 0;
	LET vCodRet				= '00000';
	LET vRfc				= '';
	
	--SET DEBUG FILE TO '/tmp/sp_actualizaremesa.out';
	--TRACE ON;

    BEGIN
	
        ON EXCEPTION SET iSqlErr
			--Manejo de errores, en caso de error, envío codigo de error
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, vcuenta;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Junto ambos nombres
		LET vnombres = TRIM(p_nombre1) || " " || TRIM(p_nombre2);
		
		--Calculo el RFC del beneficiario
		EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(p_appaterno, p_apmaterno, vnombres, p_fecha_nac)
		INTO vCodRet, vRfc;
		
		--Busco la cuenta del no. de registros con la referencia enviada
		SELECT COUNT(*)
		INTO   vcuenta
		FROM   sac_remesas_estadistica
		WHERE  referencia   = p_referencia
		AND    numcategoria = p_categoria
		AND    numconvenio  = p_convenio;
		
		IF vcuenta IS NULL THEN
			LET vcuenta = 0;
		END IF;
		
		--Realizo la actualizacion de la remesa
		UPDATE sac_remesas_estadistica
		SET    nombre1        = p_nombre1,
			   nombre2        = p_nombre2,
			   appaterno      = p_appaterno,
			   apmaterno      = p_apmaterno,
			   fecha_nac      = p_fecha_nac,
			   rfc            = vRfc,
			   moneda_origen  = p_moneda_origen,
			   importe_origen = p_importe_origen
		WHERE  referencia     = p_referencia
		AND    numcategoria = p_categoria
		AND    numconvenio  = p_convenio;
		
		RETURN cCodRet, vcuenta;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de actualizar los datos de Nombre, fecha de nacimiento y RFC del beneficiario',
'FECHA CREACION : 31 de Mayo de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_grabaremadic(p_categoria CHAR(2), p_convenio CHAR(5), p_referencia CHAR(40), p_moneda_origen CHAR(3), p_importe_origen MONEY)
RETURNING CHAR(5);

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr			INTEGER;
	DEFINE vCuenta			INTEGER;

	-- Inicializa variables
	LET iSqlErr				= 0;
	LET cCodRet            	= "00000";
	LET vCuenta				= 0;
	
	--SET DEBUG FILE TO '/tmp/sp_grabaremadic.out';
	--TRACE ON;

    BEGIN
	
        ON EXCEPTION SET iSqlErr
			--Manejo de errores, en caso de error, envío codigo de error
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Valido que no vengan nulos los valores
		IF p_referencia = '' OR p_moneda_origen = '' OR p_importe_origen IS NULL THEN
			LET cCodRet = "00001";	--Viene vacio el parametro
			RETURN cCodRet;
		END IF;
		
		--Busco el RFC con la referencia enviada
		SELECT NVL(COUNT(*), 0)
		INTO   vCuenta
		FROM   sac_remesas_adic
		WHERE  referencia   = p_referencia
		AND    numcategoria = p_categoria
		AND    numconvenio  = p_convenio;
		
		IF vCuenta = 0 THEN --Si no existen resultados
		
			INSERT INTO sac_remesas_adic (numcategoria, numconvenio, referencia, moneda_origen, importe_origen)
			VALUES (p_categoria, p_convenio, p_referencia, p_moneda_origen, p_importe_origen);
			
		ELSE
			
			LET cCodRet = "00002";	--No se guardo registro dado que ya existe
		
		END IF;
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de guardar los valores obtendos de los Qrys y guarda en tabla sac_remesas_',
'FECHA CREACION : 4 de Junio de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_obtienedatosremaut(p_categoria CHAR(2), p_convenio CHAR(5), p_referencia CHAR(40), p_sucursal CHAR(4))
RETURNING CHAR(5), VARCHAR(40), VARCHAR(40), VARCHAR(40), VARCHAR(40), VARCHAR(13), DATE, VARCHAR(20), CHAR(3), MONEY;

	--Definicion de Variables
    DEFINE cCodRet          	CHAR(5);
    DEFINE iSqlErr				INTEGER;
	DEFINE v_nombre1			VARCHAR(40);
	DEFINE v_nombre2			VARCHAR(40);
	DEFINE v_appaterno			VARCHAR(40);
	DEFINE v_apmaterno			VARCHAR(40);
	DEFINE v_fecha_nac			DATE;
	DEFINE v_rfc				VARCHAR(13);
	DEFINE v_moneda_origen		CHAR(3);
	DEFINE v_importe_origen		MONEY;
	DEFINE v_cta_benef			VARCHAR(20);
	DEFINE v_num_cte			CHAR(20);
	DEFINE v_tipo_cuenta_benef	CHAR(20);
	DEFINE v_id_tpo_cta			INTEGER;

	-- Inicializa variables
	LET iSqlErr					= 0;
	LET cCodRet            		= "00000";
	LET v_nombre1				= '';
	LET v_nombre2				= '';
	LET v_appaterno				= '';
	LET v_apmaterno				= '';
	LET v_fecha_nac				= '';
	LET v_rfc					= '';
	LET v_moneda_origen			= '';
	LET v_importe_origen		= 0;
	LET v_cta_benef				= '';
	LET v_num_cte				= '';
	LET v_tipo_cuenta_benef		= '';
	LET v_id_tpo_cta			= 0;
	
	--SET DEBUG FILE TO '/tmp/sp_obtienedatosremaut.out';
	--TRACE ON;

    BEGIN
	
        ON EXCEPTION SET iSqlErr
			--Manejo de errores, en caso de error, envío codigo de error
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF p_categoria != '' AND p_convenio != '' AND p_referencia != '' AND p_sucursal != '' THEN
			
			--Determino si es automatica
			IF p_sucursal = '9250' OR p_sucursal = '9251' OR p_sucursal = '9764' THEN
			
				--Es automática
				IF p_sucursal = '9250' THEN
				
					--Es BTS automática
					--Busco el registro en la tabla maestra
					SELECT a.cuenta_benef, a.cod_moneda_origen, a.monto_origen
					INTO   v_tipo_cuenta_benef, v_moneda_origen, v_importe_origen
					FROM   bdisac:"informix".sac_bts_sdep a
					WHERE  num_confirmacion = p_referencia
					AND    estatus_sdep     = '02';
					
					LET v_id_tpo_cta = LENGTH(TRIM(v_tipo_cuenta_benef));
					
					--Busco el numero de cuenta de cliente segun corresponda el tipo de cuenta
					IF v_id_tpo_cta = 11 THEN
						--Corresponde a una cuenta
						SELECT TRIM(cuenta), num_cte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicheq:"informix".sc_maechq
						WHERE  empresa = '001'
						AND    cuenta  = v_tipo_cuenta_benef;
					ELIF v_id_tpo_cta = 16 THEN
						--Corresponde a una tarjeta de credito/debito
						SELECT TRIM(cuenta), numcte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicheq:"informix".sc_tarjeta
						WHERE  empresa     = '001'
						AND    num_tarjeta = v_tipo_cuenta_benef;
					ELIF v_id_tpo_cta = 18 THEN
						--Corresponde a una cuenta CLABE
						SELECT TRIM(cuenta), num_cte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicheq:"informix".sc_maechq
						WHERE  cuenta_clabe = v_tipo_cuenta_benef;
					END IF;
					
					--Busco el registro en la tabla de clientes
					SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
					INTO   v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc
					FROM   bdinteg:si_cliente
					WHERE  numcte = v_num_cte;
					
					SELECT fecha_nac
					INTO   v_fecha_nac
					FROM   bdinteg:si_ctepf
					WHERE  numcte = v_num_cte;
					
					--IF v_rfc IS NOT NULL THEN
					--	IF v_rfc != '' THEN
					--		LET v_anio = SUBSTR(v_rfc,5,2);
					--		IF v_anio > 0 AND v_anio < YEAR(TODAY) THEN
					--			LET v_fecha_nac = MDY(SUBSTR(v_rfc,7,2), SUBSTR(v_rfc,9,2), 1900+v_anio);
					--		ELSE
					--			LET v_fecha_nac = MDY(SUBSTR(v_rfc,7,2), SUBSTR(v_rfc,9,2), 2000+v_anio);
					--		END IF;
					--	END IF
					--END IF

					RETURN cCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
					
				ELIF p_sucursal = '9764' THEN
					--Es APP automática
					
					--Busco el registro en la tabla maestra
					SELECT a.accountnumbersenderpay, a.currencycodeorigin, a.originamount
					INTO   v_tipo_cuenta_benef, v_moneda_origen, v_importe_origen
					FROM   bdisac:"informix".sac_app_getorder a
					WHERE  uniquereferencenumber = p_referencia
					AND    estatus_getorder      = '02';
					
					LET v_id_tpo_cta = LENGTH(TRIM(v_tipo_cuenta_benef));
					
					--Busco el numero de cuenta de cliente segun corresponda el tipo de cuenta
					IF v_id_tpo_cta = 11 THEN
						--Corresponde a una cuenta
						SELECT TRIM(cuenta), num_cte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicheq:"informix".sc_maechq
						WHERE  empresa = '001'
						AND    cuenta  = v_tipo_cuenta_benef;
					ELIF v_id_tpo_cta = 16 THEN
						--Corresponde a una tarjeta de credito/debito
						SELECT TRIM(cuenta), numcte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicheq:"informix".sc_tarjeta
						WHERE  empresa     = '001'
						AND    num_tarjeta = v_tipo_cuenta_benef;
					ELIF v_id_tpo_cta = 18 THEN
						--Corresponde a una cuenta CLABE
						SELECT TRIM(cuenta), num_cte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicheq:"informix".sc_maechq
						WHERE  cuenta_clabe = v_tipo_cuenta_benef;
					END IF;
					
					--Busco el registro en la tabla de clientes
					SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
					INTO   v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc
					FROM   bdinteg:si_cliente
					WHERE  numcte = v_num_cte;
					
					SELECT fecha_nac
					INTO   v_fecha_nac
					FROM   bdinteg:si_ctepf
					WHERE  numcte = v_num_cte;
					
					--IF v_rfc IS NOT NULL THEN
					--	IF v_rfc != '' THEN
					--		LET v_anio = SUBSTR(v_rfc,5,2);
					--		IF v_anio > 0 AND v_anio < YEAR(TODAY) THEN
					--			LET v_fecha_nac = MDY(SUBSTR(v_rfc,7,2), SUBSTR(v_rfc,9,2), 1900+v_anio);
					--		ELSE
					--			LET v_fecha_nac = MDY(SUBSTR(v_rfc,7,2), SUBSTR(v_rfc,9,2), 2000+v_anio);
					--		END IF;
					--	END IF
					--END IF
					
					RETURN cCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
					
				ELIF p_sucursal = '9251' AND p_convenio = '004' THEN
					--Es BTS Crédito automática
					
					--Busco el registro en la tabla maestra
					SELECT a.cuenta_benef, a.cod_moneda_origen, a.monto_origen
					INTO   v_tipo_cuenta_benef, v_moneda_origen, v_importe_origen
					FROM   bdisac:"informix".sac_bts_sdep a
					WHERE  num_confirmacion = p_referencia
					AND    estatus_sdep     = '02';
					
					LET v_id_tpo_cta = LENGTH(TRIM(v_tipo_cuenta_benef));
					
					--Busco el numero de cuenta de cliente segun corresponda el tipo de cuenta
					IF v_id_tpo_cta = 11 THEN
						--Corresponde a una cuenta
						SELECT num_credito, numcte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicred:sd_maecred
						WHERE  empresa     = '001'
						AND    num_credito = v_tipo_cuenta_benef;
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN --Si la busqueda no arroja resultados
							--Busco ahora en la tabla sd_maecredcrd
							SELECT num_credito, numcte
							INTO   v_cta_benef, v_num_cte
							FROM   bdicred:sd_maecredcrd
							WHERE  empresa     = '001'
							AND    num_credito = v_tipo_cuenta_benef;
						END IF;
					ELIF v_id_tpo_cta = 16 THEN
						--Corresponde a una tarjeta de credito/debito
						SELECT num_credito, numcte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicred:"informix".sd_tarjeta
						WHERE  empresa     = '001'
						AND    num_tarjeta = v_tipo_cuenta_benef;
					ELIF v_id_tpo_cta = 18 THEN
						--Corresponde a una cuenta CLABE
						----No estoy seguro que entre aqui
					END IF;
					
					--Busco el registro en la tabla de clientes
					SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
					INTO   v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc
					FROM   bdinteg:si_cliente
					WHERE  numcte = v_num_cte;
					
					SELECT fecha_nac
					INTO   v_fecha_nac
					FROM   bdinteg:si_ctepf
					WHERE  numcte = v_num_cte;
					
					--IF v_rfc IS NOT NULL THEN
					--	IF v_rfc != '' THEN
					--		LET v_anio = SUBSTR(v_rfc,5,2);
					--		IF v_anio > 0 AND v_anio < YEAR(TODAY) THEN
					--			LET v_fecha_nac = MDY(SUBSTR(v_rfc,7,2), SUBSTR(v_rfc,9,2), 1900+v_anio);
					--		ELSE
					--			LET v_fecha_nac = MDY(SUBSTR(v_rfc,7,2), SUBSTR(v_rfc,9,2), 2000+v_anio);
					--		END IF;
					--	END IF
					--END IF
					
					RETURN cCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
					
				ELIF p_sucursal = '9251' AND p_convenio = '009' THEN
					--Es APP Crédito automática
					
					--Busco el registro en la tabla maestra
					SELECT a.accountnumbersenderpay, a.currencycodeorigin, a.originamount
					INTO   v_tipo_cuenta_benef, v_moneda_origen, v_importe_origen
					FROM   bdisac:"informix".sac_app_getorder a
					WHERE  uniquereferencenumber = p_referencia
					AND    estatus_getorder      = '02';
					
					LET v_id_tpo_cta = LENGTH(TRIM(v_tipo_cuenta_benef));
					
					--Busco el numero de cuenta de cliente segun corresponda el tipo de cuenta
					IF v_id_tpo_cta = 11 THEN
						--Corresponde a una cuenta
						SELECT num_credito, numcte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicred:sd_maecred
						WHERE  empresa     = '001'
						AND    num_credito = v_tipo_cuenta_benef;
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN --Si la busqueda no arroja resultados
							--Busco ahora en la tabla sd_maecredcrd
							SELECT num_credito, numcte
							INTO   v_cta_benef, v_num_cte
							FROM   bdicred:sd_maecredcrd
							WHERE  empresa     = '001'
							AND    num_credito = v_tipo_cuenta_benef;
						END IF;
					ELIF v_id_tpo_cta = 16 THEN
						--Corresponde a una tarjeta de credito/debito
						SELECT num_credito, numcte
						INTO   v_cta_benef, v_num_cte
						FROM   bdicred:"informix".sd_tarjeta
						WHERE  empresa     = '001'
						AND    num_tarjeta = v_tipo_cuenta_benef;
					ELIF v_id_tpo_cta = 18 THEN
						--Corresponde a una cuenta CLABE
						----No estoy seguro que entre aqui
					END IF;
					
					--Busco el registro en la tabla de clientes
					SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
					INTO   v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc
					FROM   bdinteg:si_cliente
					WHERE  numcte = v_num_cte;
					
					SELECT fecha_nac
					INTO   v_fecha_nac
					FROM   bdinteg:si_ctepf
					WHERE  numcte = v_num_cte;
					
					--IF v_rfc IS NOT NULL THEN
					--	IF v_rfc != '' THEN
					--		LET v_anio = SUBSTR(v_rfc,5,2);
					--		IF v_anio > 0 AND v_anio < YEAR(TODAY) THEN
					--			LET v_fecha_nac = MDY(SUBSTR(v_rfc,7,2), SUBSTR(v_rfc,9,2), 1900+v_anio);
					--		ELSE
					--			LET v_fecha_nac = MDY(SUBSTR(v_rfc,7,2), SUBSTR(v_rfc,9,2), 2000+v_anio);
					--		END IF;
					--	END IF
					--END IF
					
					RETURN cCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
					
				END IF;
				
			END IF;
			
		ELSE
		
			LET cCodRet 				= "00001";	--Viene vacio algun parametro
			LET v_nombre1				= '';
			LET v_nombre2				= '';
			LET v_appaterno				= '';
			LET v_apmaterno				= '';
			LET v_fecha_nac				= '';
			LET v_rfc					= '';
		
		END IF;
		
		RETURN cCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de obtener los datos del beneficiario de las remesas automáticas',
'FECHA CREACION : 12 de Junio de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_obtieneremadic(p_categoria CHAR(2), p_convenio CHAR(5), p_referencia CHAR(40))
RETURNING CHAR(5), CHAR(3), MONEY;

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr			INTEGER;
	DEFINE vCuenta			INTEGER;
	DEFINE p_moneda_origen 	CHAR(3);
	DEFINE p_importe_origen MONEY;

	-- Inicializa variables
	LET iSqlErr				= 0;
	LET cCodRet            	= "00000";
	LET vCuenta				= 0;
	LET p_moneda_origen		= '';
	LET p_importe_origen	= 0;
	
	--SET DEBUG FILE TO '/tmp/sp_obtieneremadic.out';
	--TRACE ON;

    BEGIN
	
        ON EXCEPTION SET iSqlErr
			--Manejo de errores, en caso de error, envío codigo de error
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, p_moneda_origen, p_importe_origen;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Valido que no vengan nulos los valores
		IF p_referencia = '' THEN
			LET cCodRet = "00001";	--Viene vacio el parametro
			RETURN cCodRet, p_moneda_origen, p_importe_origen;
		END IF;
		
		--Busco la moneda origen y el importe origen con la referencia enviada
		SELECT FIRST 1 moneda_origen, importe_origen
		INTO   p_moneda_origen, p_importe_origen
		FROM   sac_remesas_adic
		WHERE  referencia   = p_referencia
		AND    numcategoria = p_categoria
		AND    numconvenio  = p_convenio;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN --SI LA BUSQUEDA NO ARROJA RESULTADOS
			LET cCodRet 			= "00001";
			LET p_moneda_origen		= '';
			LET p_importe_origen	= 0;
		END IF;
		
		RETURN cCodRet, p_moneda_origen, p_importe_origen;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de obtener los valores obtenidos de los Qrys',
'FECHA CREACION : 5 de Junio de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_obtienerfcremesa(p_categoria CHAR(2), p_convenio CHAR(5), p_referencia CHAR(40))
RETURNING CHAR(5), CHAR(13);

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
	DEFINE vRfc				CHAR(13);
    DEFINE iSqlErr			INTEGER;
	DEFINE vCuenta			INTEGER;

	-- Inicializa variables
	LET iSqlErr				= 0;
	LET cCodRet            	= "00000";
	LET vRfc				= '';
	LET vCuenta				= 0;
	
	--SET DEBUG FILE TO '/tmp/sp_obtienerfcremesa.out';
	--TRACE ON;

    BEGIN
	
        ON EXCEPTION SET iSqlErr
			--Manejo de errores, en caso de error, envío codigo de error
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, vRfc;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF p_referencia != '' THEN
		
			--Busco el RFC con la referencia enviada
			SELECT COUNT(*)
			INTO   vCuenta
			FROM   sac_remesas_estadistica
			WHERE  referencia   = p_referencia
			AND    numcategoria = p_categoria
			AND    numconvenio  = p_convenio;
		
			--Busco el RFC con la referencia enviada
			SELECT rfc
			INTO   vRfc
			FROM   sac_remesas_estadistica
			WHERE  referencia = p_referencia
			AND    numcategoria = p_categoria
			AND    numconvenio  = p_convenio;
			
			IF vCuenta = 0 THEN --SI LA BUSQUEDA NO ARROJA RESULTADOS
				LET cCodRet = "00001";
				LET vRfc    = '';
			END IF;
			
		ELSE
		
			LET cCodRet = "00002";	--Viene vacio el parametro
			LET vRfc    = '';
		
		END IF;
		
		RETURN cCodRet, vRfc;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de obtener el RFC del beneficiario cargado en la tabla sac_remesas_estadistica',
'FECHA CREACION : 4 de Junio de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_truncaremadic()
RETURNING CHAR(5), CHAR(80);

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr 		INTEGER;
    DEFINE cInfoErr         CHAR(100);
	DEFINE vCuenta			INTEGER;
	DEFINE cMensaje			CHAR(80);

	-- Inicializa variables
	LET cCodRet            	= "00000";
	LET cMensaje			= 'PROCESO EXITOSO';
	LET vCuenta				= 0;
	
	--SET DEBUG FILE TO '/tmp/sp_grabaremadic.out';
	--TRACE ON;

    BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envío codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_truncaremadic");
				
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP";
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Borro los datos de la tabla sac_remesas_adic
		TRUNCATE bdisac:sac_remesas_adic;
		UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_remesas_adic;
		
		RETURN cCodRet, cMensaje;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de truncar la tabla sac_remesas_adic',
'FECHA CREACION : 13 de Junio de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_guardarespuestaqryi(pSucursal CHAR (4), 
                                        pTxn_Status CHAR(1), 
										pConfirmation_nm CHAR (11), 
										pUser_name CHAR (20), 
										pTerminal CHAR(15),
                                        pAgent_Dt CHAR(8), 
										pAgent_Tm CHAR(6), 
										pOpCode CHAR(4), 
										pProcess_Msg CHAR(255), 
										pError_Param_Full_Name CHAR(255), 
										pTrans_Status_Cd CHAR(3), 
	                                    pTrans_Status_Dt CHAR(8), 
										pProcess_Dt CHAR(8), 
										pProcess_Tm CHAR(6), 
										pService_Cd CHAR(3), 
										pPayment_Type_Cd CHAR(3), 
	                                    pOrig_Country_Cd CHAR(3), 
										pOrig_Currency_Cd CHAR(3), 
										pDest_Country_Cd CHAR(3), 
										pDest_Currency_Cd CHAR(3), 
										pOrigin_Am CHAR(20), 
                                    	pDestination_Am CHAR(20), 
										pExch_Rate_Fx CHAR(21), 
										pS_Agent_Cd CHAR(3), 
										pS_Payment_Type_Cd CHAR(3), 
										pS_Account_Type_Cd CHAR(3), 
	                                    pS_Account_Nm CHAR(30), 
										pS_Bank_Cd CHAR(30), 
										pS_Bank_Ref_Nm CHAR(20), 
										pR_Account_Type_Cd CHAR(3), 
										pR_Account_Nm CHAR(30),
										pR_Agent_Cd CHAR(3), 
										pR_Agent_Region_Sd CHAR(15), 
										pR_Agent_Branch_Sd CHAR(15), 
										pS_First_Name CHAR(40), 
										pS_Middle_Name CHAR(40),
										pS_Last_Name CHAR(40), 
										pS_Mother_M_Name CHAR(40), 
										pS_Address CHAR(80), 
										pS_City CHAR(40), 
										pS_State_Cd CHAR(3), 
										pS_Country_Cd CHAR(3), 
										pS_Zip_Code CHAR(10), 
										pS_Phone CHAR(15), 
										pR_First_Name CHAR(40), 
										pR_Middle_Name CHAR(40), 
										pR_Last_Name CHAR(40), 
										pR_Mother_M_Name CHAR(40), 
										pR_Identif_Type_Cd CHAR(3), 
										pR_Identif_Nm CHAR(20), 
										pF_First_Name CHAR(40), 
										pF_Middle_Name CHAR(40), 
										pF_Last_Name CHAR(40), 
										pF_Mother_M_Name CHAR(40), 
										pR_Address CHAR(80), 
										pR_City CHAR(40), 
										pR_State_Cd CHAR(3), 
										pR_Country_Cd CHAR(3), 
										pR_Zip_Code CHAR(10), 
										pR_Phone CHAR(15), 
										pR_Type_Cd CHAR(3), 
										pR_Issuer_Cd CHAR(3), 
										pR_Issuer_State_Cd CHAR(3), 
										pR_Issuer_Country_Cd CHAR(3), 
	                                    pRi_Identif_Nm CHAR(20), 
										pR_Expiration_Dt CHAR(8), 
										pS_Type_Cd CHAR(3), 
										pS_Issuer_Cd CHAR(3), 
										pS_Issuer_State_Cd CHAR(3),	
										pS_Issuer_Country_Cd CHAR(3), 
										pS_Identif_Nm CHAR(20), 
										pS_Expiration_Dt CHAR(8), 
										pUsuario CHAR(8),
										pModo SMALLINT)

	--DATOS A REGRESAR---
    RETURNING
    CHAR(5);   -- Codigo de Retorno
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err                INT;
    DEFINE cCodRet                CHAR(5);
	DEFINE cAgent_Trans_Type_Code CHAR(4);
	DEFINE cAgent_Cd              CHAR(3);
	DEFINE cRegion_Sd             CHAR(15);
	DEFINE cBranch_Sd             CHAR(15);
	DEFINE cState_Cd              CHAR(3);
	DEFINE cCountry_Cd            CHAR(3);
    DEFINE cStatus                CHAR(1);
	DEFINE cCod_estado_sucursal CHAR(2);
	DEFINE cCod_estado_remesa		CHAR(2);
	
	DEFINE cSPCodRet CHAR(5); 
	DEFINE iMensaje CHAR(50);
	DEFINE cid_ptf CHAR(5); 
	DEFINE ccve_pais CHAR(3);
	DEFINE cnompais CHAR(20);
	DEFINE ccalle VARCHAR(100); 
	DEFINE cnum_ext VARCHAR(6); 
	DEFINE cnum_int VARCHAR(5); 
	DEFINE ccve_col CHAR(8);
	DEFINE cnomcol VARCHAR(100);
	DEFINE ccve_mun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE ccve_localidad CHAR(14);
	DEFINE cnomlocalidad VARCHAR(60);
	DEFINE ccp CHAR(5); 
	DEFINE ccve_ciudad CHAR(3);
	DEFINE cnomciudad VARCHAR(60);
	DEFINE ccve_estado CHAR(2); 
	DEFINE cnomestado VARCHAR(30);
	DEFINE ctel1 VARCHAR(14); 
	DEFINE ctel2 VARCHAR(14);
	DEFINE ctipo VARCHAR(5);	
	DEFINE vCodRet          CHAR(5);
	DEFINE vCategoria			CHAR(2);
	DEFINE vConvenio			CHAR(5);
	
	/*VARIABLES PARA ELIMINAR SELECT DE IF*/
	DEFINE cvalidaselif INTEGER;
	LET cvalidaselif =0;
	
    --INICIALIZACION DE VARIABLES--
    LET sql_err                = 0;
    LET cCodRet                = '00000';
	LET cAgent_Trans_Type_Code = 'QRYI';
	LET cAgent_Cd              = '';
	LET cRegion_Sd             = '';
	LET cBranch_Sd             = '';
	LET cState_Cd              = '';
	LET cCountry_Cd            = '';
	LET cStatus = '';
	LET cCod_estado_sucursal = '';
	LET cCod_estado_remesa = '';
	
	LET cSPCodRet = '00000';
	LET iMensaje = '';
	LET cid_ptf = '';
	LET ccve_pais = '';
	LET cnompais = '';
	LET ccalle = '';
	LET cnum_ext = ''; 
	LET cnum_int = '';
	LET ccve_col = '';
	LET cnomcol = '';
	LET ccve_mun = '';
	LET cnommunicipio = '';
	LET ccve_localidad = '';
	LET cnomlocalidad = '';
	LET ccp = '';
	LET ccve_ciudad = '';
	LET cnomciudad = '';
	LET ccve_estado = ''; 
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';	
	LET vCodRet = '00000';
	LET vCategoria				= '07';
	LET vConvenio				= '004';
	
	--SET DEBUG FILE TO '/tmp/adrian/sp_guardarespuestaqryi.out';
    --TRACE ON;
	
	BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	IF pSucursal = "" OR  pSucursal IS NULL OR pTxn_Status = "" OR pTxn_Status IS NULL OR pConfirmation_nm = "" OR pConfirmation_nm IS NULL 
	    OR pUser_name = "" OR pUser_name IS NULL OR pTerminal = "" OR pTerminal IS NULL OR pAgent_Dt = "" OR pAgent_Dt IS NULL 
		OR pAgent_Tm = "" OR pAgent_Tm IS NULL OR pUsuario = "" OR pUsuario IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet;
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE BDISAC:sp_consultasucursal (pSucursal) 
	INTO cCodRet, cAgent_Cd, cRegion_Sd, cBranch_Sd, cState_Cd, cCountry_Cd;
	IF cCodRet = "00000" THEN
		INSERT INTO sac_bts_qryi (txn_status, agent_trans_type_code, agent_cd, confirmation_nm, region_sd, branch_sd, state_cd, country_cd, user_name, terminal, 
	             agent_dt, agent_tm, opcode, process_msg, error_param_full_name, trans_status_cd, trans_status_dt, process_dt, process_tm, service_cd, payment_type_cd,
	             orig_country_cd, orig_currency_cd, dest_country_cd, dest_currency_cd, origin_am, destination_am, exch_Rate_fx, s_agent_cd, s_payment_type_cd,
	             s_account_type_cd, s_account_nm, s_bank_cd, s_bank_Ref_nm, r_account_type_cd, r_account_nm, r_agent_cd, r_agent_region_sd, r_agent_branch_sd, 
	             s_first_name, s_middle_name, s_last_name, s_mother_m_name, s_address, s_city, s_state_cd, s_country_cd, s_zip_code, s_phone, r_first_name,
	             r_middle_name, r_last_name, r_mother_m_name, r_identif_type_cd, r_identif_nm, f_first_name, f_middle_name, f_last_name, f_mother_m_name,
	             r_address, r_city, r_state_cd, r_country_cd, r_zip_code, r_phone, r_type_cd, r_issuer_cd, r_issuer_state_cd, r_issuer_country_cd, ri_identif_nm, 
	             r_expiration_dt, s_type_cd, s_issuer_cd, s_issuer_state_cd, s_issuer_country_cd, s_identif_nm, s_expiration_dt, user_insert, fecha_insert)
		VALUES(pTxn_Status, cAgent_Trans_Type_Code, cAgent_Cd, pConfirmation_nm, cRegion_Sd, cBranch_Sd, cState_cd, cCountry_cd, pUser_name, pTerminal, 
	             pAgent_Dt, pAgent_tm, pOpCode, pProcess_Msg, pError_Param_Full_Name, pTrans_Status_Cd, pTrans_Status_Dt, pProcess_Dt, pProcess_Tm, pService_Cd, pPayment_Type_Cd,
	             pOrig_Country_Cd, pOrig_Currency_Cd, pDest_Country_Cd, pDest_Currency_Cd, pOrigin_Am, pDestination_Am, pExch_Rate_Fx, pS_Agent_Cd, pS_Payment_Type_Cd,
	             pS_Account_Type_Cd, pS_Account_Nm, pS_bank_Cd, pS_Bank_Ref_Nm, pR_Account_Type_Cd, pR_Account_Nm, pR_Agent_Cd, pR_Agent_Region_Sd, pR_Agent_Branch_Sd, 
	             pS_First_Name, pS_Middle_Name, pS_Last_Name, pS_Mother_M_Name, pS_Address, pS_City, pS_State_Cd, pS_Country_Cd, pS_Zip_Code, pS_Phone, pR_First_Name,
	             pR_Middle_Name, pR_Last_Name, pR_Mother_M_Name, pR_Identif_Type_Cd, pR_Identif_Nm, pF_First_Name, pF_Middle_Name, pF_Last_Name, pF_Mother_M_Name,
	             pR_Address, pR_City, pR_State_Cd, pR_Country_Cd, pR_Zip_Code, pR_Phone, pR_Type_Cd, pR_Issuer_Cd, pR_Issuer_State_Cd, pR_Issuer_Country_Cd, pRi_Identif_Nm, 
	             pR_Expiration_Dt, pS_Type_Cd, pS_Issuer_Cd, pS_Issuer_State_Cd, pS_Issuer_Country_Cd, pS_Identif_Nm, pS_Expiration_Dt, pUsuario, CURRENT);			 
	
		--Se guardan datos adicionales de remesas para validacion de Limites de remesas
		EXECUTE PROCEDURE bdisac:"informix".sp_grabaremadic(vCategoria, vConvenio, pConfirmation_nm, pOrig_Currency_Cd, pOrigin_Am)
		INTO vCodRet;
		
	-- Nueva validaci?n por duplicidad de pagos. JGP. 26-Sep-11
		SELECT status_cancelado INTO cStatus FROM bdisac:sac_movimientos 
			WHERE numcategoria = '07' AND numconvenio = '004' AND referencia1 = pConfirmation_nm 
			AND status_cancelado = 'N' AND flag_confirmacion_sucursal = '0';
			IF cStatus ='N' AND pTrans_Status_Cd = 'ONP' THEN -- Si encontr? un intento de pago previo y no ha sido reversado
			   LET cCodRet = '00756'; -- Se tiene que reversar primero antes de intentar el pago nuevamente
			   RETURN cCodRet;
			END IF;
   		IF pPayment_Type_Cd = 'ACC' AND cBranch_Sd <> '9250' THEN -- La remesa es para abono en cuenta
		   LET cCodRet = '00756'; -- No se permite el pago
		   RETURN cCodRet;
		END IF;
	END IF;
	
	 IF pOpCode = '1000' AND TRIM(pTrans_Status_Cd) = 'ONP' THEN
				--SELECT estado INTO cCod_estado_sucursal FROM bdinteg:"informix".si_sucursales where sucursal=pSucursal;
				execute procedure bdisac:"informix".sp_sac_consucursales(TRIM(pSucursal)) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,cCod_estado_sucursal,cnomestado,ctel1,ctel2,ctipo;
				IF cSPCodRet <> '00000' THEN
					RETURN cCodRet;	
				END IF;
				SELECT cod_estado INTO  cCod_estado_remesa FROM "informix".sac_estaremesasorig where cve_prov_estado=pR_State_Cd AND remesadora='BTS';
				
				Select COUNT(*) INTO cvalidaselif from "informix".sac_estaremesasorig where cve_prov_estado = pR_State_Cd  and remesadora='BTS';
				IF cvalidaselif > 0 THEN
					IF cCod_estado_sucursal = cCod_estado_remesa THEN
						return cCodRet;
					ELSE
						LET cvalidaselif = 0;
						SELECT COUNT(*) INTO cvalidaselif FROM "informix".sac_edosremorigexcep WHERE cod_estado = cCod_estado_remesa and remesadora = 'BTS';
						IF cvalidaselif > 0 THEN 
							LET cvalidaselif = 0;
							SELECT COUNT(*) INTO cvalidaselif FROM "informix".sac_edosremorigexcep WHERE remesadora ='BTS' and cod_estado = cCod_estado_remesa and ((cod_excep = TO_CHAR(pSucursal) AND tipo_excep = 'S') OR (cod_excep = cCod_estado_sucursal AND tipo_excep = 'E'));
							IF cvalidaselif > 0 THEN	
								RETURN cCodRet;
							ELSE
								INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pSucursal,cCod_estado_sucursal,pR_State_Cd,cCod_estado_remesa,'001',pConfirmation_nm,'BTS',CURRENT);
								LET cCodRet = '00005';
								RETURN cCodRet;
							END IF;
						ELSE
							INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pSucursal,cCod_estado_sucursal,pR_State_Cd,cCod_estado_remesa,'001',pConfirmation_nm,'BTS',CURRENT);
							LET cCodRet = '00005';
							RETURN cCodRet;
						END IF;
					END IF;
				ELSE
					/*
					INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pSucursal,cCod_estado_sucursal,pR_State_Cd,cCod_estado_remesa,'002',pConfirmation_nm,'BTS',CURRENT);
					LET cCodRet = '00004';
					*/
					RETURN cCodRet;
				END IF;
	ELSE
			RETURN cCodRet;
	END IF;
END;
END PROCEDURE;