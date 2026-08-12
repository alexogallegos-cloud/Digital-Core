CREATE PROCEDURE "informix".sp_carga_tabla_movimientos_peticion_org(pfecha DATE)

RETURNING CHAR(6), CHAR(80);
/*
___________________________________________________________________________________________________________________________________________________________________________
	Creado: Carlos Valenzuela
	FECHA: 08-03-2016.
	DESCRIPCION: Carga de archivos de movimientos con fecha a peticion.
	BASE DE DATOS: bdicobranza.
*/
--DECLARACION DE VARIABLES
DEFINE sql_err					INTEGER;
DEFINE isam_err					INTEGER;
DEFINE error_info				CHAR(80);
DEFINE cCod_ret					CHAR(6);
DEFINE vempresa     			CHAR(3);
DEFINE cproceso     			CHAR(4);
DEFINE vvcCod_ret				CHAR(6);
DEFINE cMensaje					CHAR(80);
DEFINE cCadena					CHAR(500);
DEFINE vRuta					CHAR(100);
DEFINE cSql         			CHAR(2204);	
DEFINE vNomArch     			CHAR(2204);	
DEFINE X 						CHAR(100);
DEFINE pNomArch 				CHAR(100);
DEFINE v_cvemovimiento       	CHAR(1);
DEFINE v_tipomovimiento      	SMALLINT;
DEFINE v_horainicio          	DATETIME YEAR to SECOND;
DEFINE v_horafin             	DATETIME YEAR to SECOND;
DEFINE v_cliente             	CHAR(20);
DEFINE v_tipologica          	SMALLINT;
DEFINE v_tipocobranza        	CHAR(1);
DEFINE v_tipoclientecampana  	SMALLINT;
DEFINE v_cuenta              	CHAR(2);
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
	
--DEFINICIAON DE VARIABLES
LET cCod_ret  				= "000000";
LET sql_err   				= 0;
LET cMensaje  				= "PROCESO EXITOSO";
LET cCadena   				= "";
LET vRuta     				= "";
LET cSql      				= "";
LET vempresa   				= '001';
LET cproceso    			= '0095';
LET vNomArch    			= "";
LET X 						= '';
LET pNomArch 				= '';
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

--SET DEBUG FILE TO "/aplicacion/Carlos/catmovimientosctbcpl_peticion.out ";
--TRACE ON;

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
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING vvcCod_ret;

	--SELECCIONAMOS LA RUTA 
	select valor_alfabetico into vRuta 
	from bdicobranza:cb_param_campania
	where empresa = '001'
	and tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 9;	

	-----PRUEBAS-----
	--LET vRuta = '/respaldos/Carlos/predictivo/';
	-----------------				

	--ASIGNAMOS NOMBRE AL ARCHIVO
	LET pNomArch = 'movimientosctbcpl_'|| TO_CHAR(pfecha,'%d%m%Y')||'.txt.gz';

	--ASIGNAMOS PERMISOS AL ARCHIVO
	LET cSql = "chmod 777 " || TRIM(vRuta) || TRIM(pNomArch); 
	SYSTEM cSql;

	--DESCOMPRIMIMOS EL ARCHIVO
	LET cSql = "";
	LET cSql = "gunzip "  || TRIM(vRuta) || TRIM(pNomArch); 
	SYSTEM cSql;

	--TOMAMOS EL NOMBRE DE ARCHIVO YA DESCOMPRIMIDO SIN LOS 3 ULTIMOS CARACTERES 
	LET X = LENGTH(pNomArch);
	LET vNomArch = SUBSTR(pNomArch,0,X-3);

	--ASIGNAMOS PERMISOS AL ARCHIVO
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(vRuta) || TRIM(vNomArch); 
	SYSTEM cSql;

	--BORRAMOS LA INFORMACION QUE CONTIENE LA TABLA CON LA QUE VAMOS A TRABAJAR
	TRUNCATE TABLE "informix".cb_cat_movimientos_peticion DROP STORAGE;

	--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
	LET cCadena = 'echo " LOAD FROM ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || SUBSTR(VNomArch,1,
	LENGTH(VNomArch))  || ' INSERT INTO bdicobranza:cb_cat_movimientos_peticion " >' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl_peticion.sql';
	SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

	--EJECUTAMOS EL ARCHIVO QUE CONTIENE LA CADENA
	LET cCadena = "";
	LET cCadena = 'dbaccess bdicobranza ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl_peticion.sql';
	SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

	--BORRA EL ARCHIVO 
	LET cCadena = "";
	LET cCadena = 'rm ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl_peticion.sql';
	SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

	--SE COMPRIME DE NUEVO EL ARCHIVO
	LET cSql = "";
	LET cSql = "gzip " || TRIM(vRuta) || TRIM(vNomArch); 
	SYSTEM cSql;

	--ASIGNAMOS PERMISOS AL ARCHIVO
	LET cSql = "";
	LET cSql = "chmod 777 " || TRIM(vRuta) || TRIM(pNomArch); 
	SYSTEM cSql;

	--SE ACTUALIZA CAMPO CLIENTE CON CEROS A LA IZQUIERDA HASTA QUE LA CADENA CLIENTE CUMPLA CON LOS 9 DIGITOS
	UPDATE "informix".cb_cat_movimientos_peticion
	SET cliente = LPAD(TRIM(cliente),9,'0')
	WHERE DATE(horainicio) = pfecha;

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
		--WHERE DATE(horainicio) = pfecha

--------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------
		LET iCuentasProcesadas = iCuentasProcesadas + 1;
		
--------BUSCAMOS SI EXISTE EL REGISTRO--------
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

--------SI EL REGISTRO NO EXISTE ES NULO Y POR LO TANTO SE IGUALA A VACIO PARA QUE NO MARQUE ERROR EN LA COMPARACION--------
		IF v_bandera IS NULL THEN LET v_bandera = ""; END IF;

--------SI EXISTE EL REGISTRO SE BORRA Y DESPUES DE INSERTA EN LA TABLA cb_cat_movimientos--------
		IF v_bandera = "1" THEN
			BEGIN WORK;
----------------BORRAMOS EL REGISTRO DE LA TABLA cb_cat_movimientos PARA EVITAR DUPLICADOS----------------	
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

----------------VARIABLE PARA EL CONTEO DE CUENTAS DUPLICADAS----------------
				LET iCuentasDuplicadas = iCuentasDuplicadas +1;

----------------INSERTAMOS EL REGISTRO EN LA TABLA cb_cat_movimientos----------------		

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

----------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS----------------
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
----------------INSERTAMOS EL REGISTRO EN LA TABLA cb_cat_movimientos----------------				
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

----------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS----------------
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
-------------------------------------------------------------------------------------------------------------------------------------

	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL FINAL DE LA EJECUCION DE SP
	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03') RETURNING vvcCod_ret;

	--SE MANDA LLAMAR SP CIERRE LLAMADAS PARA REALIZAR EL CONTEO DE LLAMADAS POR CLIENTE
	CALL bdicobranza:"informix".sp_cat_cierrellamadas() RETURNING cCod_ret, cMensaje;

	--SE MANDA LLAMAR SP PARA ACTUALIZAR EN LA TABLA SI_TELEFONOS_ACTUAL EL CAMPO "CONTACTO"
	CALL bdicobranza:"informix".sp_actualiza_contacto_exitoso() RETURNING cCod_ret, cMensaje;
		
	UPDATE statistics medium FOR TABLE "informix".cb_cat_movimientos;
		
	RETURN cCod_ret, cMensaje;
END;
END PROCEDURE;