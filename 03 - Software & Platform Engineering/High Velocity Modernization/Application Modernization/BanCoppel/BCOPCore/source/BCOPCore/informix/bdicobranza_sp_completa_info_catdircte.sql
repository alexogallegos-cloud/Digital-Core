CREATE PROCEDURE "informix".sp_completa_info_catdircte(pTipo_Cobranza char(1), pFecha date)
RETURNING 
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;

--execute PROCEDURE "informix".sp_completa_info_catdircte('R', today);

DEFINE P_COD_RET    CHAR(6);
DEFINE viSqlErr     INTEGER;
DEFINE error_info   CHAR(80);
DEFINE isam_err     INTEGER;
DEFINE P_MENSAJE    CHAR(150);
DEFINE cNumCte      CHAR(20);
DEFINE pempresa     CHAR(3);
DEFINE cNumCredito  CHAR(20);
DEFINE cPagoMinimo  CHAR(20);
DEFINE cCiudad      CHAR(3);
DEFINE cEstado      CHAR(2);
DEFINE cApell_Paterno CHAR(26);
DEFINE cApell_Materno CHAR(26);
DEFINE cNombre1     CHAR(26);
DEFINE cNombre2     CHAR(26);
DEFINE cProceso     CHAR(30);
DEFINE vvcCod_ret   CHAR(6);
DEFINE dFechaProc   DATE;
DEFINE iCuentasProcesadas   INTEGER;
DEFINE iNombresNulos        INTEGER;
DEFINE iCuentas   	  INTEGER;
--DEFINE iCuentas8100   INTEGER;
DEFINE iCuentas6011   INTEGER;
DEFINE iCuentas6300   INTEGER;
DEFINE iCuentas7600   INTEGER;
DEFINE iCuentas7700   INTEGER;
DEFINE iCuentas6400   INTEGER;
DEFINE iCuentas6800   INTEGER;
DEFINE cMensaje     CHAR (100);
DEFINE cCod_ret     CHAR(6);
DEFINE cNumProducto CHAR(04);
DEFINE vday			INTEGER;
DEFINE vnum_prod	CHAR(4);
DEFINE vbandera		CHAR(1);


LET viSqlErr    = 0;
LET isam_err    = 0;
LET cCod_ret    = '000000';
LET P_COD_RET   = '000000';
LET P_MENSAJE   = 'El proceso de COMPLEMENTA NOMBRE CATDIRECTORIOCTE se realizó correctamente.';
LET pempresa    = '001';
LET cNumCte     = '';
LET cNumCredito = '';
LET cPagoMinimo = '0';
LET cApell_Paterno = '';
LET cApell_Materno = '';
LET cNombre1    = '';
LET cNombre2    = '';
LET cProceso    = '0085';
LET vvcCod_ret  = '';
let cCiudad     = '';
let cEstado     = '';
LET dFechaProc  = pFecha;
LET iCuentasProcesadas  = 0;
LET cMensaje    = '';
LET iNombresNulos = 0;
LET cNumProducto = '';
LET iCuentas = 0;
--LET iCuentas8100 = 0;
LET iCuentas6011 = 0;
LET iCuentas6300 = 0;
LET iCuentas7600 = 0;
LET iCuentas7700 = 0;
LET iCuentas6400 = 0;
LET iCuentas6800 = 0;
LET vday		= 0;
LET vnum_prod	= '';
LET vbandera	= '';

BEGIN
    ON EXCEPTION SET viSqlErr, isam_err, error_info
        LET P_COD_RET = viSqlErr;
        LET P_MENSAJE = error_info;
        CALL "informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02') RETURNING vvcCod_ret;
        RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;

    --SET DEBUG FILE TO "sp_completa_info_catdircte.out";
    --TRACE ON;

    CALL "informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '01') RETURNING vvcCod_ret;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;

	IF pTipo_Cobranza = 'A' THEN
		BEGIN WORK;
			UPDATE "informix".cb_param SET valor = 'I' WHERE empresa = "001" AND cod_param = 88;
		COMMIT WORK;

		SELECT MAX(fecha_insert) INTO dFechaProc
		FROM "informix".cb_cat_directorio_cte
		WHERE empresa = pempresa
		AND tipo_cobranza = pTipo_Cobranza
		AND fecha_insert <= pFecha;

		LET vday = DAY(dFechaProc);

		FOREACH WITH HOLD
			SELECT valor_alfabetico INTO vnum_prod
			FROM "informix".cb_param_campania 
			WHERE empresa = pempresa AND tipo_campania = 61
			AND grupo_parametro = pTipo_Cobranza
			AND valor_numerico = vday

			IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

			SELECT descripcion INTO vbandera FROM "informix".cb_param WHERE empresa = pempresa AND valor = vnum_prod;

			IF vbandera IS NULL THEN LET vbandera = ''; END IF;

			IF vbandera = 'N' OR vbandera = '' THEN
				LET vbandera = '';
				CONTINUE FOREACH;
			END IF;

			SELECT MAX(fecha_insert) INTO dFechaProc
			FROM "informix".cb_cat_directorio_cte
			WHERE empresa = pempresa
			AND tipo_cobranza = pTipo_Cobranza
			AND fecha_insert <= pFecha
			AND num_producto = vnum_prod;

			SELECT cat.numcte, cat.num_credito, cat.num_producto
			FROM "informix".cb_cat_directorio_cte cat
			WHERE cat.tipo_cobranza = pTipo_Cobranza
			AND cat.fecha_insert = dFechaProc
			AND cat.nombre1 is null
			AND cat.num_producto = vnum_prod
			INTO temp ctes_nombres WITH NO LOG;

			CREATE INDEX inx_cred_ctes_nomb ON ctes_nombres(num_credito) ONLINE;
			UPDATE STATISTICS MEDIUM FOR TABLE ctes_nombres;
			
			FOREACH WITH HOLD
				SELECT numcte, num_credito, num_producto
				  INTO cNumCte, cNumCredito, cNumProducto
				  FROM ctes_nombres
				  WHERE num_credito > ""

				let iCuentasProcesadas = iCuentasProcesadas + 1;

				SELECT cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2
				  INTO cApell_Paterno, cApell_Materno, cNombre1, cNombre2
				  FROM bdinteg:"informix".si_cliente cte 
				 WHERE numcte = cNumCte;

				IF cApell_Paterno IS NULL THEN LET cApell_Paterno = ''; END IF;
				IF cApell_Materno IS NULL THEN LET cApell_Materno = ''; END IF;
				IF cNombre1 IS NULL THEN LET cNombre1 = ''; LET iNombresNulos = iNombresNulos + 1; END IF;
				IF cNombre2 IS NULL THEN LET cNombre2 = ''; END IF;

				LET iCuentas = iCuentas + 1;

				BEGIN WORK;
					UPDATE "informix".cb_cat_directorio_cte
					   SET apell_paterno = cApell_Paterno, 
						   apell_materno = cApell_Materno,
						   nombre1 = cNombre1, 
						   nombre2 = cNombre2
					 WHERE empresa = pempresa
					   AND tipo_cobranza = pTipo_Cobranza
					   AND fecha_insert = dFechaProc
					   AND num_credito = cNumCredito;
				COMMIT WORK;     
			END FOREACH;

			DROP TABLE ctes_nombres;

		--Genera cifras de control
			if iCuentasProcesadas > 0 then
			   let cMensaje = 'Cuentas procesadas '||vnum_prod||' : ' ||iCuentas;
			   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
			end if;
		--Genera cifras de control
			LET iCuentas = 0;
		END FOREACH;

		if iCuentasProcesadas > 0 then
		   let cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
		   let cMensaje = trim(cMensaje) ||'    Nombres nulos : ' ||iNombresNulos;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
		end if;

		BEGIN WORK;
			UPDATE "informix".cb_param SET valor = 'F' WHERE empresa = "001" AND cod_param = 88;
		COMMIT WORK;
	ELSE
		SELECT MAX(fecha_insert) INTO dFechaProc
		FROM "informix".cb_cat_directorio_cte
		WHERE empresa = pempresa
		AND tipo_cobranza = pTipo_Cobranza
		AND fecha_insert <= pFecha;

		-- Temporal solo para pruebas
		--let dFechaProc = mdy('06','20','2015');
		-- Temporal solo para pruebas
		
		SELECT cat.numcte, cat.num_credito, cat.num_producto
		FROM "informix".cb_cat_directorio_cte cat
		WHERE cat.tipo_cobranza = pTipo_Cobranza
		AND cat.fecha_insert = dFechaProc
		AND cat.nombre1 is null
		INTO temp ctes_nombres WITH NO LOG;

		CREATE INDEX inx_cred_ctes_nomb ON ctes_nombres(num_credito) ONLINE;
		UPDATE STATISTICS MEDIUM FOR TABLE ctes_nombres;

		FOREACH WITH HOLD
			SELECT numcte, num_credito, num_producto
			  INTO cNumCte, cNumCredito, cNumProducto
			  FROM ctes_nombres
			  WHERE num_credito > ""

			let iCuentasProcesadas = iCuentasProcesadas + 1;

			SELECT cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2
			  INTO cApell_Paterno, cApell_Materno, cNombre1, cNombre2
			  FROM bdinteg:"informix".si_cliente cte 
			 WHERE numcte = cNumCte;

			IF cApell_Paterno IS NULL THEN LET cApell_Paterno = ''; END IF;
			IF cApell_Materno IS NULL THEN LET cApell_Materno = ''; END IF;
			IF cNombre1 IS NULL THEN LET cNombre1 = ''; LET iNombresNulos = iNombresNulos + 1; END IF;
			IF cNombre2 IS NULL THEN LET cNombre2 = ''; END IF;

			IF cNumProducto = '6011' THEN LET iCuentas6011 = iCuentas6011 + 1; END IF;
			IF cNumProducto = '6300' THEN LET iCuentas6300 = iCuentas6300 + 1; END IF;
			IF cNumProducto = '7600' THEN LET iCuentas7600 = iCuentas7600 + 1; END IF;
			IF cNumProducto = '7700' THEN LET iCuentas7700 = iCuentas7700 + 1; END IF;
			IF cNumProducto = '6400' THEN LET iCuentas6400 = iCuentas6400 + 1; END IF;
			IF cNumProducto = '6800' THEN LET iCuentas6800 = iCuentas6800 + 1; END IF;

			BEGIN WORK;
				UPDATE "informix".cb_cat_directorio_cte
				   SET apell_paterno = cApell_Paterno, 
					   apell_materno = cApell_Materno,
					   nombre1 = cNombre1, 
					   nombre2 = cNombre2
				 WHERE empresa = pempresa
				   AND tipo_cobranza = pTipo_Cobranza
				   AND fecha_insert = dFechaProc
				   AND num_credito = cNumCredito;
			COMMIT WORK;     
		END FOREACH;

		DROP TABLE ctes_nombres;

	--Genera cifras de control
		if iCuentasProcesadas > 0 then
		   let cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
		   let cMensaje = trim(cMensaje) ||'    Nombres nulos : ' ||iNombresNulos;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
		   let cMensaje = '';
		   let cMensaje = 'Cuentas procesadas 6300 : ' ||iCuentas6300;
		   let cMensaje = trim(cMensaje) ||'    Cuentas procesadas 6011 : ' ||iCuentas6011;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
		   let cMensaje = '';
		   let cMensaje = 'Cuentas procesadas 7600 : ' ||iCuentas7600;
		   let cMensaje = trim(cMensaje) ||'    Cuentas procesadas 7700 : ' ||iCuentas7700;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
		   let cMensaje = '';
		   let cMensaje = 'Cuentas procesadas 6400 : ' ||iCuentas6400;
		   let cMensaje = trim(cMensaje) ||'    Cuentas procesadas 6800 : ' ||iCuentas6800;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
		end if;
	--Genera cifras de control
	END IF;

    UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_cat_directorio_cte;

    CALL "informix".sp_inserta_bitacora_cob(pempresa, cProceso,'', '','03' ) RETURNING vvcCod_ret;

    RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE
DOCUMENT 
'MODIFICACIÓN: Complementa la tabla cat_directorio_cte con el nombre del cliente.',
'AUTOR : ',
'FECHA : 2015-06-24',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_carga_tabla_movimientos()

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
	DEFINE sql_err		INTEGER;
	DEFINE isam_err		INTEGER;
	DEFINE error_info	CHAR(80);
	DEFINE cCod_ret		CHAR(6);
	DEFINE vempresa     CHAR(3);
	DEFINE cproceso     CHAR(4);
	DEFINE vvcCod_ret   CHAR(6);
	DEFINE cMensaje		CHAR(80);
	DEFINE cCadena		CHAR(500);
	DEFINE vRuta		CHAR(100);
	DEFINE cSql         CHAR(2204);	
	DEFINE vNomArch     CHAR(2204);	
	DEFINE X 			CHAR(100);
	DEFINE pNomArch 	CHAR(100);
	DEFINE vfecha 		DATE;
	DEFINE vRutasql		CHAR(50);
	DEFINE v_clienteact	CHAR(9);
	DEFINE v_cliente 	CHAR(9);
	
--	 SET DEBUG FILE TO "sp_carga_tabla_movimientos.out ";
--	 TRACE ON;

--DEFINICION DE VARIABLES
	LET cCod_ret  	= "000000";
	LET sql_err   	= 0;
	LET cMensaje  	= "PROCESO EXITOSO";
	LET cCadena   	= "";
	LET vRuta     	= "";
	LET cSql      	= "";
	LET vempresa    = '001';
	LET cproceso    = '2000';
	LET vNomArch    = "";
	LET X 			= '';
	LET pNomArch 	= '';
	let vfecha 		= DATE(1);
	LET vRutasql 	= "/ifxsif01/Control-M/";
	LET v_clienteact = "";
	LET v_cliente 	= "";

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
 
 --SELECCIONAMOS LA FECHA DEL DIA
	select fecha_hoy 
		into vfecha 
		from bdicred:sd_fechas 
		where empresa = '001';

--temporal solo para pruebas
--let vfecha = mdy('09','12','2018');
--temporal solo para pruebas
			
		--SELECCIONAMOS LA RUTA 
            select valor_alfabetico 
			into vRuta 
            from bdicobranza:cb_param_campania
            where empresa = '001'
				and tipo_campania = 1
				and grupo_parametro = 'ARCHIVOS'
				and num_parametro = 9;	--9 RUTA EN PRODUCCION			
		
		--ASIGNAMOS NOMBRE AL ARCHIVO
		LET pNomArch = 'movimientosctbcpl_'|| to_char(vfecha,'%d%m%Y')||'.txt.gz';

		--DESCOMPRIMIMOS EL ARCHIVO
		  LET cSql = "gunzip "  || trim(vRuta) || trim(pNomArch); 
          system cSql;
		  
		--TOMAMOS EL NOMBRE DE ARCHIVO YA DESCOMPRIMIDO SIN LOS 3 ULTIMOS CARACTERES 
		 LET X = length(pNomArch);
		 LET vNomArch = substr(pNomArch,0,X-3);
		
/*       LET cCadena = 'echo " load from ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || SUBSTR(VNomArch,1,
		  LENGTH(VNomArch))  || ' insert into bdicobranza:cb_cat_movimientos " >' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));*/

		--SE ENVIAR EL NOMBRE DEL ARCHIVO A CARGAR AL SCRIPT
		LET cCadena = 'cat ' || TRIM(vRutasql) || '206_3_40_carga_movimientos_cat_archivo.sql | sed "s/vnom_archivo/' || TRIM(VNomArch) || '/g" > ' || TRIM(vRuta) || 'catmovimientosctbcpl.sql';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		--CREAMOS EL ARCHIVO CON LA CADENA A EJECUTAR
		LET cCadena = "";
		LET cCadena = 'dbload -d bdicobranza -c ' || TRIM(vRuta) || 'catmovimientosctbcpl.sql -l ' || TRIM(vRuta) || 'catmovimientosctbcpl.log -n 1000 -k';
		SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));

		--BORRA EL ARCHIVO 
          let cCadena = 'rm ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
		  
	--SE COMPRIME DE NUEVO EL ARCHIVO	
		LET cSql = "gzip " || trim(vRuta) || trim(vNomArch); 
		system cSql;
	--SE ACTUALIZA CAMPO CON LPAD A CAMPO CLIENTE
	FOREACH WITH HOLD
		SELECT cliente
		INTO v_cliente
		FROM "informix".cb_cat_movimientos
		WHERE date(horainicio) = vfecha
		
		IF LENGTH(TRIM(v_cliente)) < 9 THEN
			LET v_clienteact = lpad (trim(v_cliente),9,'0');
		ELSE
			CONTINUE FOREACH;
		END IF;

		BEGIN WORK;
			UPDATE "informix".cb_cat_movimientos
			SET cliente = v_clienteact
			WHERE date(horainicio) = vfecha
			AND cliente = v_cliente;
		COMMIT WORK;
	END FOREACH
	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL FINAL DE LA EJECUCION DE SP
		 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
			RETURNING vvcCod_ret;
	--SE MANDA LLAMAR SP CIERRE LLAMADAS PARA REALIZAR EL CONTEO DE LLAMADAS POR CLIENTE
--		 CALL bdicobranza:"informix".sp_cat_cierrellamadas()
--			RETURNING cCod_ret, cMensaje;
	--SE MANDA LLAMAR SP PARA ACTUALIZAR EN LA TABLA SI_TELEFONOS_ACTUAL EL CAMPO "CONTACTO"
--		 CALL bdicobranza:"informix".sp_actualiza_contacto_exitoso()
--			RETURNING cCod_ret, cMensaje;
	--SE MANDA LLAMAR AL SP QUE CARGA REGISTROS DE ATENTO
		--CALL bdicobranza:"informix".sp_carga_info_atento() RETURNING cCod_ret, cMensaje;
	--SE MANDA LLAMAR AL SP QUE CARGA REGISTROS DE LATINIA
		--CALL bdicobranza:"informix".sp_carga_sms_latinia() RETURNING cCod_ret, cMensaje;
		
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;