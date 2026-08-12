CREATE PROCEDURE "informix".sp_cat_cierrellamadas()
       RETURNING CHAR(6), CHAR(150);

--DECLARACION DE VARIABLES
DEFINE sql_err 			        INTEGER;
DEFINE isam_err 		        INTEGER;
DEFINE error_info		        CHAR(150);
DEFINE cMensaje 		        CHAR(150);
DEFINE cCod_ret                 CHAR(6);
DEFINE vempresa                 CHAR(3);
DEFINE vnumcte                  CHAR(20);
DEFINE vtelefono                CHAR (13);
DEFINE vtipo_telefono           INTEGER;
DEFINE vfultimocontacto         DATE;
DEFINE vfecha_aprocesar         DATE;
DEFINE vveces_marcado           INTEGER;
DEFINE vcodigo_resultado        INTEGER;
DEFINE vfch_ult_contacto        INTEGER;
DEFINE vmes_marcado             INTEGER;
DEFINE vfecha_llamada           DATE;
DEFINE vfecha_ultimo_contac     DATE;
DEFINE cproceso                 CHAR(4);
DEFINE vvcCod_ret               CHAR(6);
DEFINE vmes_llama               INTEGER;
DEFINE vmes_contac              INTEGER;
DEFINE vvmes_marcado            INTEGER;
DEFINE vvveces_marcado          INTEGER;
DEFINE vcuenta                  CHAR(2);
DEFINE vfecha					DATE;
DEFINE vBandera					CHAR(1);


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
DEFINE cMensaje2		    	CHAR(300);
DEFINE iCuentasProcesadas   	INTEGER;
DEFINE iCuentasBorradas			INTEGER;
DEFINE cSQL						CHAR(5000);
DEFINE cnomarchivo				CHAR(100);
DEFINE cnombre				CHAR(100);

--	SET DEBUG FILE TO "sp_cierre_llamadas.out";
--	TRACE ON;

	LET cCod_ret				= '000000';
	LET sql_err					= 0;
	LET isam_err				= 0;
	LET error_info				= '';
	LET cMensaje				= 'PROCESO EXITOSO';
	LET vempresa				= '001';
	LET cproceso				= '0009';
	LET vcuenta					= '';
	LET vfecha					=DATE(1);
	LET vBandera				= '';
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
	LET cMensaje2		    	= "";
	LET iCuentasProcesadas   	= 0;
	LET iCuentasBorradas		= 0;
	LET vfecha_aprocesar		= DATE(1);
	LET cSQL					= '';
	LET cnomarchivo				= '';
	LET cnombre					= '';
	
	
	
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		CALL "informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
		RETURNING vvcCod_ret;
		RETURN cCod_ret, cMensaje;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	CALL "informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
	RETURNING vvcCod_ret;

/*	SELECT max(date(horainicio)) 
		INTO vfecha
	FROM "informix".cb_cat_movimientos
	WHERE tipologica >= 0;*/

	SELECT fecha_hoy INTO vfecha FROM bdicred:sd_fechas WHERE empresa=vempresa;

--temporal solo para pruebas
--LET vfecha = MDY('09','12','2018');
--temporal solo para pruebas

	LET cMensaje2 = 'Inicia actualizacion cuentas TV ';
	CALL "informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, TRIM(cMensaje2), '02') RETURNING vvcCod_ret;
	
	FOREACH WITH HOLD
		SELECT cliente, telefonooriginal, tipotelefono, finllamada ,horainicio
		INTO vnumcte, vtelefono, vtipo_telefono, vcodigo_resultado, vfecha_llamada
		FROM "informix".cb_cat_movimientos
		WHERE empresa = vempresa
		AND cvemovimiento = 'L' AND tipomovimiento = 1
		AND cuenta = 'TV'
		AND DATE(horainicio) = vfecha

		BEGIN WORK;
			UPDATE "informix".cb_cat_movimientos SET cuenta = 'PR' 
			 WHERE horainicio = vfecha_llamada 
			   AND cliente = vnumcte 
			   AND tipotelefono = vtipo_telefono
			   AND telefonooriginal = vtelefono 
			   AND finllamada =  vcodigo_resultado
			   AND cuenta = 'TV';
--		COMMIT WORK;

		/*IF EXISTS(SELECT * FROM cb_registro_llamadas
				  WHERE empresa= vempresa AND tipo_telefono = vtipo_telefono AND numcte = vnumcte 
				  AND telefono = vtelefono AND codigo_resultado = vcodigo_resultado) THEN*/

		SELECT FIRST 1 '1' INTO vBandera
		FROM "informix".cb_registro_llamadas
		WHERE empresa= vempresa AND tipo_telefono = vtipo_telefono AND numcte = vnumcte 
		AND telefono = vtelefono AND codigo_resultado = vcodigo_resultado;

		IF vBandera IS NULL THEN LET vBandera = ''; END IF;

		IF vBandera = '1' THEN
			SELECT TO_CHAR(DATE(fecha_insert) , "%Y%m"), mes_marcado, veces_marcado, fecha_insert
			INTO vfch_ult_contacto, vmes_marcado, vveces_marcado, vfecha_ultimo_contac
			FROM "informix".cb_registro_llamadas
			WHERE empresa= vempresa AND numcte = vnumcte
			AND telefono = vtelefono AND tipo_telefono = vtipo_telefono
			AND codigo_resultado = vcodigo_resultado;

			LET vmes_llama = MONTH(vfecha_llamada);
			LET vmes_contac = MONTH(vfecha_ultimo_contac);

			IF vmes_llama > vmes_contac THEN
				LET vvmes_marcado = vmes_marcado + 1;
				LET vvveces_marcado = vveces_marcado + 1;

					UPDATE "informix".cb_registro_llamadas SET veces_marcado = vvveces_marcado, mes_marcado = vvmes_marcado, fecha_insert = vfecha_llamada
					WHERE empresa= vempresa AND numcte = vnumcte AND telefono = vtelefono AND tipo_telefono = vtipo_telefono 
					AND codigo_resultado = vcodigo_resultado;
			ELSE
				LET vvveces_marcado = vveces_marcado + 1;

					UPDATE "informix".cb_registro_llamadas SET veces_marcado = vvveces_marcado, fecha_insert = vfecha_llamada
					WHERE empresa= vempresa AND numcte = vnumcte AND telefono = vtelefono AND tipo_telefono = vtipo_telefono 
					AND codigo_resultado = vcodigo_resultado;
			END IF;
		ELSE
				INSERT INTO "informix".cb_registro_llamadas(empresa, numcte, telefono, tipo_telefono, extension, mes_marcado
							,veces_marcado, codigo_resultado, fecha_insert, user_insert, veces_contemplado) 
				VALUES(vempresa, vnumcte, vtelefono, vtipo_telefono, 0, 1, 1, vcodigo_resultado, vfecha_llamada, USER, 1);
		END IF;
		COMMIT WORK;
	END FOREACH;

	LET cMensaje2 = 'Inicia migracion a tabla historica ';
	CALL "informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, TRIM(cMensaje2), '02') RETURNING vvcCod_ret;
	
	LET vfecha_aprocesar = TODAY - 60 UNITS DAY;
	LET vBandera = '';
	
--NUEVO
	LET cMensaje2 = 'Descarga a archivo tabla de movimientos ';
	CALL "informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, TRIM(cMensaje2), '02') RETURNING vvcCod_ret;

	LET cnombre = 'Archivo_cb_cat_movimientos';

    LET cnomarchivo =  TRIM(cnombre)||to_char(vfecha,'%d%m%Y')||'.unl';
	
	LET cSQL = '';
    LET cSQL = 'echo "UNLOAD TO '''||'/resplogifx/archivoscartera/'||TRIM(cnomarchivo)||''' delimiter '''||'|'||'''" > /resplogifx/archivoscartera/descarga_cb_cat_movimientos.sql';
	SYSTEM cSQL;

	LET cSQL = '';
	LET cSQL = 'echo "SELECT cvemovimiento, tipomovimiento, horainicio, horafin, cliente, tipologica, tipocobranza,'
	|| ' tipoclientecampana, cuenta, tienda, importe, tipoconvenio, plazo, cobranzacat,'
	|| ' sucursal, empresa, usteddebe, usteddebia, vencido, tipotelefono, numext,'
	|| ' telefonooriginal, telefonoreconstruido, finllamada, contacto, tipored, aclaracion, fechahorallamada,'
	|| ' horainiciollamada, horafinllamada, pkwhere, duracionefectiva, cat, ip, numempleado,'
	|| ' observaciones, fechacartera, carrier, numerociudad, numeroestado, keyx'
	|| ' FROM bdicobranza:cb_cat_movimientos'
    || ' WHERE DATE(horainicio) < '''||vfecha_aprocesar||''' " >> /resplogifx/archivoscartera/descarga_cb_cat_movimientos.sql';
	SYSTEM cSQL;

	LET cSQL = '';
	LET cSQL = 'dbaccess bdicobranza /resplogifx/archivoscartera/descarga_cb_cat_movimientos.sql';
	SYSTEM cSQL;
--NUEVO	

{		SELECT cvemovimiento, tipomovimiento, horainicio, horafin, cliente, tipologica, tipocobranza,
			tipoclientecampana, cuenta, tienda, importe, tipoconvenio, plazo, cobranzacat,
			sucursal, empresa, usteddebe, usteddebia, vencido, tipotelefono, numext,
			telefonooriginal, telefonoreconstruido, finllamada, contacto, tipored, aclaracion, fechahorallamada,
			horainiciollamada, horafinllamada, pkwhere, duracionefectiva, cat, ip, numempleado,
			observaciones, fechacartera, carrier, numerociudad, numeroestado, keyx
		INTO v_cvemovimiento, v_tipomovimiento, v_horainicio, v_horafin, v_cliente, v_tipologica, v_tipocobranza,
			v_tipoclientecampana, v_cuenta, v_tienda, v_importe, v_tipoconvenio, v_plazo, v_cobranzacat,
			v_sucursal, v_empresa, v_usteddebe, v_usteddebia, v_vencido, v_tipotelefono, v_numext,
			v_telefonooriginal, v_telefonoreconstruido, v_finllamada, v_contacto, v_tipored, v_aclaracion, v_fechahorallamada,
			v_horainiciollamada, v_horafinllamada, v_pkwhere, v_duracionefectiva, v_cat, v_ip, v_numempleado,
			v_observaciones, v_fechacartera, v_carrier, v_numerociudad, v_numeroestado, v_keyx
		FROM "informix".cb_cat_movimientos
		WHERE horainicio < vfecha_aprocesar }

	LET cMensaje2 = 'Depura tabla de movimientos ';
	CALL "informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, TRIM(cMensaje2), '02') RETURNING vvcCod_ret;

	SELECT cliente, keyx
	FROM bdicobranza:"informix".cb_cat_movimientos
	WHERE horainicio < vfecha_aprocesar
	INTO TEMP ctas_adepurar WITH NO LOG;

	UPDATE STATISTICS MEDIUM FOR TABLE ctas_adepurar;
	
	FOREACH WITH HOLD
		SELECT cliente, keyx
		INTO v_cliente, v_keyx
		FROM ctas_adepurar
		

--------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------
		LET iCuentasProcesadas = iCuentasProcesadas + 1;

		BEGIN WORK;

--------BORRAMOS EL REGISTRO DE LA TABLA cb_cat_movimientos QUE SE HA RESPALDADO--------
		DELETE 
		FROM "informix".cb_cat_movimientos
		WHERE cliente = v_cliente
		AND keyx = v_keyx;

		COMMIT WORK;

--------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------
		LET iCuentasBorradas = iCuentasBorradas + 1;

		LET v_cliente = '';
		LET v_keyx = 0;
	END FOREACH;

	LET cMensaje2 = 'Carga archivo a tabla de movimientos historica ';
	CALL "informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, TRIM(cMensaje2), '02') RETURNING vvcCod_ret;

	LET cSQL = '';
	LET cSQL = 'echo "FILE '''||'/resplogifx/archivoscartera/'||TRIM(cnomarchivo)||''' DELIMITER '''||'|'||''' 41; INSERT INTO cb_cat_movimientos_his; " > /resplogifx/archivoscartera/carga_cb_cat_movimientos_his.sql';
	SYSTEM cSQL;

	LET cSQL = '';
	LET cSQL = 'dbload -d bdicobranza -c /resplogifx/archivoscartera/carga_cb_cat_movimientos_his.sql -l /resplogifx/archivoscartera/carga_cb_cat_movimientos_his.log -n 1000 -k';
	SYSTEM cSQL;

	LET cSQL = '';
	LET cSQL = "gzip /resplogifx/archivoscartera/"||TRIM(cnomarchivo)||" ";
	SYSTEM cSQL;

	
----GENERA CIFRAS DE CONTROL----
	LET cMensaje2 = 'TOTAL cuentas PROCESADAS: ' || iCuentasProcesadas;
	LET cMensaje2 = TRIM(cMensaje2) ||'  TOTAL cuentas BORRADAS: ' || iCuentasBorradas;
	CALL "informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, TRIM(cMensaje2), '02') RETURNING vvcCod_ret;
	LET cMensaje2 = '';

----INICIALIZACION DE VARIABLES DE CONTEO----
	LET cMensaje2 = '';
	LET iCuentasProcesadas = 0;

-------------------------------------------------------------------------------------------------------------------------------------

	CALL "informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
	RETURNING vvcCod_ret;

	RETURN cCod_ret, cMensaje;
END;
END PROCEDURE;