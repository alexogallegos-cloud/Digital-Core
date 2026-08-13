CREATE PROCEDURE "informix".sp_carga_tabla_movimientos_agex(pfecha DATE, popcion CHAR(1))

RETURNING CHAR(6), CHAR(80);
/*
___________________________________________________________________________________________________________________________________________________________________________
	MODIFICADO POR: Abrham Lopez Lopez.
	FECHA: 24-01-2012.
	DESCRIPCION: Se modifica para que se quede registro de la ejecucion de SP en bitacora.
	BASE DE DATOS: bdicobranza.
Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯Â¯
 Modificacion: Marco A. Campos
 Descripcion: Eliminar llamado a sp_carga_sms_latinia porque ahora se carga la informacion por proceso batch. 2013-12-18.
*/
--DECLARACION DE VARIABLES
DEFINE sql_err					INTEGER;
DEFINE isam_err					INTEGER;
DEFINE error_info				CHAR(80);
DEFINE cCod_ret					CHAR(6);
DEFINE vempresa     			CHAR(3);
DEFINE cproceso     			CHAR(4);
DEFINE vvcCod_ret   			CHAR(6);
DEFINE cMensaje					CHAR(80);
DEFINE cCadena					CHAR(500);
DEFINE vRuta					CHAR(100);
DEFINE cSql         			CHAR(2204);	
DEFINE vNomArch     			CHAR(2204);	
DEFINE X 						CHAR(100);
DEFINE pNomArch 				CHAR(100);
DEFINE vfecha 					DATE;
DEFINE vRutasql					CHAR(50);
DEFINE vRutasql2				CHAR(50);
DEFINE v_clienteact				CHAR(20);
DEFINE v_clienteant 			CHAR(20);
DEFINE v_cvemovimiento       	CHAR(1);
DEFINE v_tipomovimiento      	SMALLINT;
DEFINE v_horainicio          	DATETIME YEAR to SECOND;
DEFINE v_horafin             	DATETIME YEAR to SECOND;
DEFINE v_cliente             	CHAR(20);
DEFINE v_tipologica          	SMALLINT;
DEFINE v_tipocobranza        	CHAR(1);
DEFINE v_tipoclientecampana  	SMALLINT;
DEFINE v_cuenta              	CHAR(4);
DEFINE v_tienda              	CHAR(20);
DEFINE v_importe             	DECIMAL(18,2);
DEFINE v_tipoconvenio        	SMALLINT;
DEFINE v_plazo               	CHAR(2);
DEFINE v_cobranzacat         	SMALLINT;
DEFINE v_sucursal            	CHAR(4);
DEFINE v_empresa             	CHAR(3);
DEFINE v_usteddebe           	DECIMAL(18,2);
DEFINE v_usteddebia          	DECIMAL(18,2);
DEFINE v_vencido             	DECIMAL(18,2);
DEFINE v_tipotelefono        	SMALLINT;
DEFINE v_numext              	CHAR(5);
DEFINE v_telefonooriginal    	CHAR(13);
DEFINE v_telefonoreconstruido	CHAR(13);
DEFINE v_finllamada          	SMALLINT;
DEFINE v_contacto            	CHAR(2);
DEFINE v_tipored             	CHAR(1);
DEFINE v_aclaracion          	SMALLINT;
DEFINE v_fechahorallamada    	DATETIME YEAR to SECOND;
DEFINE v_horainiciollamada   	DATETIME HOUR to SECOND;
DEFINE v_horafinllamada      	DATETIME HOUR to SECOND;
DEFINE v_pkwhere             	CHAR(50);
DEFINE v_duracionefectiva    	SMALLINT;
DEFINE v_cat                 	VARCHAR(40);
DEFINE v_ip                  	VARCHAR(40);
DEFINE v_numempleado         	CHAR(8);
DEFINE v_observaciones       	CHAR(80);
DEFINE v_fechacartera        	DATETIME YEAR to SECOND;
DEFINE v_carrier             	SMALLINT;
DEFINE v_numerociudad        	SMALLINT;
DEFINE v_numeroestado        	CHAR(2);
DEFINE v_keyx                	INTEGER;
DEFINE v_bandera				CHAR(1);
DEFINE cMensaje2		    	CHAR(300);
DEFINE iCuentasProcesadas   	INTEGER;
DEFINE iCuentasDuplicadas	  	INTEGER;
DEFINE iCuentasInsertadas   	INTEGER;
	
--	 SET DEBUG FILE TO "sp_carga_tabla_movimientos_agex.out ";
--	 TRACE ON;

--DEFINICION DE VARIABLES
LET cCod_ret  				= "000000";
LET sql_err   				= 0;
LET cMensaje  				= "PROCESO EXITOSO";
LET cCadena   				= "";
LET vRuta     				= "";
LET cSql      				= "";
LET vempresa    			= '001';
LET cproceso    			= '0060';
LET vNomArch    			= "";
LET X 						= '';
LET pNomArch 				= '';
let vfecha 					= DATE(1);
LET vRutasql 				= "/ifxsif01/Control-M/";
LET vRutasql2 				= "/ifxsif01/scripts/";
LET v_clienteact 			= "";
LET v_clienteant 				= "";
LET v_cvemovimiento       	= "";
LET v_tipomovimiento      	= 0;
LET v_horainicio          	= DATE(1);
LET v_horafin             	= DATE(1);
LET v_cliente             	= "";
LET v_tipologica          	= 0;
LET v_tipocobranza        	= "";
LET v_tipoclientecampana  	= 0;
LET v_cuenta              	= "";
LET v_tienda              	= "";
LET v_importe             	= 0;
LET v_tipoconvenio        	= 0;
LET v_plazo               	= "";
LET v_cobranzacat         	= 0;
LET v_sucursal            	= "";
LET v_empresa             	= "";
LET v_usteddebe           	= 0;
LET v_usteddebia          	= 0;
LET v_vencido             	= 0;
LET v_tipotelefono        	= 0;
LET v_numext              	= "";
LET v_telefonooriginal    	= "";
LET v_telefonoreconstruido	= "";
LET v_finllamada          	= 0;
LET v_contacto            	= "";
LET v_tipored             	= "";
LET v_aclaracion          	= 0;
LET v_fechahorallamada    	= DATE(1);
LET v_horainiciollamada   	= DATE(1);
LET v_horafinllamada      	= DATE(1);
LET v_pkwhere             	= "";
LET v_duracionefectiva    	= 0;
LET v_cat                 	= "";
LET v_ip                  	= "";
LET v_numempleado         	= "";
LET v_observaciones       	= "";
LET v_fechacartera        	= DATE(1);
LET v_carrier             	= 0;
LET v_numerociudad        	= 0;
LET v_numeroestado        	= "";
LET v_keyx                	= 0;
LET v_bandera				= "";
LET cMensaje2		    	= "";
LET iCuentasProcesadas   	= 0;
LET iCuentasDuplicadas	  	= 0;
LET iCuentasInsertadas   	= 0;

BEGIN
	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
		RETURNING vvcCod_ret;

		RETURN cCod_ret, cMensaje;	    
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL INICIO DE LA EJECUCION DE SP
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
	RETURNING vvcCod_ret;

	--SELECCIONAMOS LA RUTA 
	select valor_alfabetico 
	into vRuta 
	from bdicobranza:cb_param_campania
	where empresa = '001'
	and tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 9;
	
	-----RUTA DE PRUEBAS-----
	--LET vRuta = '/aplicacion/Carlos/';
	-------------------------	

	IF popcion = "1" THEN
		--SELECCIONAMOS LA FECHA DEL DIA
		SELECT fecha_hoy 
		INTO vfecha 
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = '001';

		--temporal solo para pruebas
		--let vfecha = mdy('07','10','2019');
		--temporal solo para pruebas

		--ASIGNAMOS NOMBRE AL ARCHIVO
		LET pNomArch = 'movimientosctbcpl_'|| to_char(vfecha,'%d%m%Y')||'_AE.txt.gz';

		--DESCOMPRIMIMOS EL ARCHIVO
		LET cSql = "gunzip "  || trim(vRuta) || trim(pNomArch); 
		system cSql;

		--TOMAMOS EL NOMBRE DE ARCHIVO YA DESCOMPRIMIDO SIN LOS 3 ULTIMOS CARACTERES 
		LET X = length(pNomArch);
		LET vNomArch = substr(pNomArch,0,X-3);

		--SE ENVIAR EL NOMBRE DEL ARCHIVO A CARGAR AL SCRIPT
		LET cCadena = 'cat ' || TRIM(vRutasql) || 'pro_206_37_56_carga_movimientos_pentafon_archivo.sql | sed "s/vnom_archivo/' || TRIM(VNomArch) || '/g" > ' || TRIM(vRuta) || 'catmovimientosctbcplagex.sql';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdicobranza -c ' || TRIM(vRuta) || 'catmovimientosctbcplagex.sql -l ' || TRIM(vRuta) || 'catmovimientosctbcplagex.log -n 1000 -k';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		--BORRA EL ARCHIVO 
		let cCadena = 'rm ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcplagex.sql';
		System SUBSTR(cCadena,1,LENGTH(cCadena));

		let cCadena = 'rm ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcplagex.log';
		System SUBSTR(cCadena,1,LENGTH(cCadena));

		--SE COMPRIME DE NUEVO EL ARCHIVO	
		LET cSql = "gzip " || trim(vRuta) || trim(vNomArch); 
		system cSql;

		--SE ACTUALIZA CAMPO CON LPAD A CAMPO CLIENTE
		FOREACH WITH HOLD
			SELECT cliente
			INTO v_clienteant
			FROM "informix".cb_cat_movimientos
			WHERE date(horainicio) = vfecha

			IF LENGTH(TRIM(v_clienteant)) < 9 THEN
				LET v_clienteact = lpad (trim(v_clienteant),9,'0');
			ELSE
				CONTINUE FOREACH;
			END IF;

			BEGIN WORK;
				UPDATE "informix".cb_cat_movimientos
				SET cliente = v_clienteact
				WHERE date(horainicio) = vfecha
				AND cliente = v_clienteant;
			COMMIT WORK;
		END FOREACH
	ELIF popcion = "2" THEN
		--ASIGNAMOS NOMBRE AL ARCHIVO
		LET pNomArch = 'movimientosctbcpl_'|| TO_CHAR(pfecha,'%d%m%Y')||'_AE.txt.gz';

		--DESCOMPRIMIMOS EL ARCHIVO
		LET cSql = "";
		LET cSql = "gunzip "  || TRIM(vRuta) || TRIM(pNomArch); 
		SYSTEM cSql;

		--TOMAMOS EL NOMBRE DE ARCHIVO YA DESCOMPRIMIDO SIN LOS 3 ULTIMOS CARACTERES 
		LET X = LENGTH(pNomArch);
		LET vNomArch = SUBSTR(pNomArch,0,X-3);

		--BORRAMOS LA INFORMACION QUE CONTIENE LA TABLA CON LA QUE VAMOS A TRABAJAR
		TRUNCATE TABLE "informix".cb_cat_movimientos_peticion DROP STORAGE;

		--SE ENVIAR EL NOMBRE DEL ARCHIVO A CARGAR AL SCRIPT
		LET cCadena = 'cat ' || TRIM(vRutasql2) || '206_37_56_carga_movimientos_pentafon_archivo.sql | sed "s/vnom_archivo/' || TRIM(VNomArch) || '/g" > ' || TRIM(vRuta) || 'catmovimientosctbcplagex_peticion.sql';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdicobranza -c ' || TRIM(vRuta) || 'catmovimientosctbcplagex_peticion.sql -l ' || TRIM(vRuta) || 'catmovimientosctbcplagex_peticion.log -n 1000 -k';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		--BORRA EL ARCHIVO
		LET cCadena = "";
		LET cCadena = 'rm -f ' || TRIM(vRuta) || 'catmovimientosctbcplagex_peticion.sql';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		LET cCadena = "";
		LET cCadena = 'rm -f ' || TRIM(vRuta) || 'catmovimientosctbcplagex_peticion.log';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		--SE COMPRIME DE NUEVO EL ARCHIVO
		LET cSql = "";
		LET cSql = "gzip " || TRIM(vRuta) || TRIM(vNomArch); 
		SYSTEM cSql;

		--SE ACTUALIZA CAMPO CLIENTE CON CEROS A LA IZQUIERDA HASTA QUE LA CADENA CLIENTE CUMPLA CON LOS 9 DIGITOS
		FOREACH WITH HOLD
			SELECT cliente
			INTO v_clienteant
			FROM "informix".cb_cat_movimientos_peticion
			WHERE date(horainicio) = vfecha

			IF LENGTH(TRIM(v_clienteant)) < 9 THEN
				LET v_clienteact = lpad (trim(v_clienteant),9,'0');
			ELSE
				CONTINUE FOREACH;
			END IF;

			BEGIN WORK;
				UPDATE "informix".cb_cat_movimientos_peticion
				SET cliente = v_clienteact
				WHERE date(horainicio) = vfecha
				AND cliente = v_clienteant;
			COMMIT WORK;
		END FOREACH

-------------------------------------------------------------------------------------------------------------------------------------
		UPDATE statistics medium FOR TABLE "informix".cb_cat_movimientos_peticion;

		FOREACH WITH HOLD
			SELECT cvemovimiento, tipomovimiento, horainicio, horafin, cliente,
				tipologica, tipocobranza, tipoclientecampana, cuenta, tienda,
				importe, tipoconvenio, plazo, cobranzacat, sucursal,
				empresa, usteddebe, usteddebia, vencido, tipotelefono,
				numext, telefonooriginal, telefonoreconstruido, finllamada, contacto,
				tipored, aclaracion, fechahorallamada, horainiciollamada, horafinllamada,
				pkwhere, duracionefectiva, cat, ip, numempleado, observaciones,
				fechacartera, carrier, numerociudad, numeroestado, keyx
			INTO v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente,
				v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda,
				v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal,
				v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono,
				v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto,
				v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada,
				v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones,
				v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx
			FROM "informix".cb_cat_movimientos_peticion
			WHERE DATE(horainicio) = pfecha

			--VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS
			LET iCuentasProcesadas = iCuentasProcesadas + 1;

			--BUSCAMOS SI EXISTE EL REGISTRO
			SELECT 1 INTO v_bandera
			FROM "informix".cb_cat_movimientos
			WHERE cvemovimiento = v_cvemovimiento
			AND tipomovimiento = v_tipomovimiento
			AND horainicio = v_horainicio
			AND cliente = v_cliente
			AND tipologica = v_tipologica
			AND tipocobranza = v_tipocobranza
			AND tienda = v_tienda
			AND keyx = v_keyx;

			--SI EL REGISTRO NO EXISTE ES NULO Y POR LO TANTO SE IGUALA A VACIO PARA QUE NO MARQUE ERROR EN LA COMPARACION
			IF v_bandera IS NULL THEN LET v_bandera = ""; END IF;

			--SI EXISTE EL REGISTRO SE BORRA Y DESPUES DE INSERTA EN LA TABLA cb_cat_movimientos
			IF v_bandera = "1" THEN
				BEGIN WORK;
					--BORRAMOS EL REGISTRO DE LA TABLA cb_cat_movimientos PARA EVITAR DUPLICADOS	
					DELETE 
					FROM "informix".cb_cat_movimientos 
					WHERE cvemovimiento = v_cvemovimiento
					AND tipomovimiento = v_tipomovimiento
					AND horainicio = v_horainicio
					AND cliente = v_cliente
					AND tipologica = v_tipologica
					AND tipocobranza = v_tipocobranza
					AND tienda = v_tienda
					AND keyx = v_keyx;

					--VARIABLE PARA EL CONTEO DE CUENTAS DUPLICADAS
					LET iCuentasDuplicadas = iCuentasDuplicadas +1;

					--INSERTAMOS EL REGISTRO EN LA TABLA cb_cat_movimientos		

					INSERT INTO "informix".cb_cat_movimientos
						(cvemovimiento, tipomovimiento, horainicio, horafin, cliente,
						tipologica, tipocobranza, tipoclientecampana, cuenta, tienda,
						importe, tipoconvenio, plazo, cobranzacat, sucursal,
						empresa, usteddebe, usteddebia, vencido, tipotelefono,
						numext, telefonooriginal, telefonoreconstruido, finllamada, contacto,
						tipored, aclaracion, fechahorallamada, horainiciollamada, horafinllamada,
						pkwhere, duracionefectiva, cat, ip, numempleado, observaciones,
						fechacartera, carrier, numerociudad, numeroestado, keyx)
					VALUES (v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente,
						v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda,
						v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal,
						v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono,
						v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto,
						v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada,
						v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones,
						v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx);

					--VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS
					LET iCuentasInsertadas = iCuentasInsertadas + 1;
				COMMIT WORK;

				LET v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente = "", 0, DATE(1), DATE(1), "";
				LET v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda = 0, "", 0, "", "";
				LET v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal = 0, 0, "", 0, "";
				LET v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono = "", 0, 0, 0, 0;
				LET v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto = "", "", "", 0, "";
				LET v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada = "", 0, DATE(1), DATE(1), DATE(1);
				LET v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones = "", 0, "", "", "","";
				LET v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx, v_bandera = DATE(1), 0, 0, "", 0, "";
			ELSE
				BEGIN WORK;
					--INSERTAMOS EL REGISTRO EN LA TABLA cb_cat_movimientos				
					INSERT INTO "informix".cb_cat_movimientos
						(cvemovimiento, tipomovimiento, horainicio, horafin, cliente,
						tipologica, tipocobranza, tipoclientecampana, cuenta, tienda,
						importe, tipoconvenio, plazo, cobranzacat, sucursal,
						empresa, usteddebe, usteddebia, vencido, tipotelefono,
						numext, telefonooriginal, telefonoreconstruido, finllamada, contacto,
						tipored, aclaracion, fechahorallamada, horainiciollamada, horafinllamada,
						pkwhere, duracionefectiva, cat, ip, numempleado, observaciones,
						fechacartera, carrier, numerociudad, numeroestado, keyx)
					VALUES (v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente,
						v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda,
						v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal,
						v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono,
						v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto,
						v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada,
						v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones,
						v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx);

					--VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS
					LET iCuentasInsertadas = iCuentasInsertadas + 1;
				COMMIT WORK;

				LET v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente = "", 0, DATE(1), DATE(1), "";
				LET v_tipologica, v_tipocobranza, v_tipoclientecampana, v_cuenta, v_tienda = 0, "", 0, "", "";
				LET v_importe, v_tipoconvenio, v_plazo, v_cobranzacat, v_sucursal = 0, 0, "", 0, "";
				LET v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono = "", 0, 0, 0, 0;
				LET v_numext, v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto = "", "", "", 0, "";
				LET v_tipored, v_aclaracion, v_fechahorallamada, v_horainiciollamada, v_horafinllamada = "", 0, DATE(1), DATE(1), DATE(1);
				LET v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado, v_observaciones = "", 0, "", "", "","";
				LET v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx, v_bandera = DATE(1), 0, 0, "", 0, "";
			END IF;
		END FOREACH;

		--------GENERA CIFRAS DE CONTROL--------
		LET cMensaje2 = 'TOTAL cuentas PROCESADAS: ' || iCuentasProcesadas;
		LET cMensaje2 = TRIM(cMensaje2) ||'  TOTAL cuentas DUPLICADAS: ' || iCuentasDuplicadas;
		LET cMensaje2 = TRIM(cMensaje2) ||'  TOTAL cuentas INSERTADAS: ' || iCuentasInsertadas;
		CALL "informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, TRIM(cMensaje2), '02') RETURNING vvcCod_ret;

		--------INICIALIZACION DE VARIABLES DE CONTEO--------
		LET cMensaje2 = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasDuplicadas = 0;
		LET iCuentasInsertadas = 0;
	END IF;

	UPDATE statistics medium FOR TABLE "informix".cb_cat_movimientos;

	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL FINAL DE LA EJECUCION DE SP
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
	RETURNING vvcCod_ret;

	RETURN cCod_ret, cMensaje;
END;
END PROCEDURE;