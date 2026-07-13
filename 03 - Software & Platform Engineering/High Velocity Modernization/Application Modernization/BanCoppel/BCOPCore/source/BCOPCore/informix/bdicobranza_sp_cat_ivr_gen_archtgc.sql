CREATE PROCEDURE "informix".sp_cat_ivr_gen_archtgc(pempresa CHAR(3), 
						                                        pfechacorte DATE,
                                                    ptipocobranza char(1))
RETURNING CHAR(6), CHAR(150);
-------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE Bit_Cod_ret          CHAR(6);  
DEFINE vempresa				CHAR(3);
DEFINE vproceso				CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cNomArchSql			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE vfechacorte          DATE;
DEFINE vlFechaInsert        DATE;
DEFINE vTipo 				SMALLINT;
DEFINE iParamPagvencidos 	SMALLINT;
DEFINE cNombreOriginal 		CHAR(100);

--SET DEBUG FILE TO "sp_cat_ivr_gen_archtgc.out";
--TRACE ON; 

--InicializaciÃ³n de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET Bit_Cod_ret             = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0068';
LET vempresa				= '001';
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cNomArchSql             = '';
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET iParamPagvencidos		= 0;
LET cNombreOriginal 		= "";

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02')  RETURNING Bit_Cod_ret; 
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01') RETURNING Bit_Cod_ret;
    LET vTipo =1;	
	-- Validacion de parÃ¡metros de entrada  
	IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = "" THEN
        LET cCod_Ret= "104001";
        SELECT descripcion
            INTO cMensaje
		FROM bdicobranza:"informix".cb_errores
		WHERE origen = 3
		AND codigo_error = cCod_Ret; 
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING Bit_Cod_ret;
        RETURN cCod_ret, cMensaje;
    ELSE
        LET vfechacorte = pfechacorte;

		SELECT MAX(fecha_insert) INTO vlFechaInsert 
		FROM bdicobranza:"informix".cb_cat_directorio_cte
		WHERE tipo_cobranza = ptipocobranza	
		AND num_producto = '8500';
		
		IF vlFechaInsert IS NULL OR vlFechaInsert = '' THEN
			LET vlFechaInsert = TODAY;
		END IF;
		
        IF vfechacorte <> vlFechaInsert THEN
            LET vfechacorte = vlFechaInsert;
            LET vTipo =0;         
        END IF;      
    END IF;

    --ValidaciÃ³n de la empresa
    SELECT empresa
        INTO cempresa
	FROM bdinteg:si_empresas
	WHERE empresa = pempresa;
	
    IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
            INTO cMensaje
		FROM cb_errores
		WHERE origen = 3
		AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING Bit_Cod_ret;
        RETURN cCod_ret, cMensaje;
    END IF;
	
    --Obtener caracter delimitador
    SELECT valor_alfabetico
        INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = pempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 25;
	
    --Valida que exista el caracter
    IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
            INTO cMensaje
		FROM cb_errores 
		WHERE origen = 3
		AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING Bit_Cod_ret;
        RETURN cCod_ret, cMensaje;
    END IF;
	
    --Obtener ruta del archivo /resplogifx/archivoscartera/
	SELECT valor_alfabetico
        INTO cruta
	FROM bdicobranza:cb_param_campania
	WHERE empresa = pempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 36;
	
    --Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
            INTO cMensaje
		FROM cb_errores
		WHERE origen = 3
		AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING Bit_Cod_ret;
        RETURN cCod_ret, cMensaje;
    END IF;

	IF (DAY(pfechacorte) = 12) OR (DAY(pfechacorte) = 13) THEN
		--Obtener el nombre del archivo
		SELECT valor_alfabetico
			INTO cnombre
		FROM bdicobranza:cb_param_campania
		WHERE empresa = pempresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 79;
		
		--Validar que existe el archivo.
		LET cnomarchivo1 =  TRIM(cnombre) ||'Aux_' || ptipocobranza || '_'||TO_CHAR(pfechacorte,'%d%m%Y')||'.txt';
		LET cnomarchivo =  TRIM(cnombre) || TO_CHAR(pfechacorte,'%d%m%Y')||'.txt';
		LET cNomArchSql = 'Ejecuta_' || ptipocobranza || '_' ||  'GenArchIVRpreventivatgc.sql';

		---se ejecuta para ponerle el encabezado. 
		LET cSql='';
		LET csql = 'echo "cliente'||','||'nombre'||','||'tipoproducto'||','||'telcasa'||','||'telcelular'||','||
					 'prioridad'||','||'fechalimitepago'||','||'fechacorte'||'" >'||TRIM(cruta)|| cnomarchivo;			 
		SYSTEM csql; 
		
		LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

		LET cSQL2 = " SELECT a.numcte as cliente, "
		|| " TRIM (h.apell_paterno) ||' '|| TRIM (h.apell_materno)||' '|| TRIM(h.nombre1) ||' '|| TRIM(h.nombre2) as nombre, "
		|| " f.num_producto as tipoproducto, " 
		|| " nvl(TRIM(substr(b.telefono,length(b.telefono)-9,10)),' ') as telcasa, "
		|| " nvl(TRIM(substr(d.telefono,length(d.telefono)-9,10)),' ') as telcelular,1, "
		|| " (e.prox_fecha_pago) as fechalimitepago, "
		|| " (day(e.prox_fecha_pago+4 units day))||'/'||lpad(month(e.prox_fecha_pago),2,'0')||'/'||(year(e.prox_fecha_pago-1 units month))fechacorte "
		|| " FROM bdicobranza:cb_cat_directorio_cte a "
		|| " JOIN bdicred:sd_maecred f ON (a.empresa = f.empresa AND a.numcte = f.numcte) "
		|| " JOIN bdinteg:si_cliente h ON (h.empresa = a.empresa AND h.numcte = a.numcte) "     
		|| " LEFT OUTER JOIN bdinteg:si_telefonos_actual b ON ( b.empresa = a.empresa AND b.numcte = a.numcte AND b.tipo_tel = 1 AND b.cofetel = 'V' AND length(nvl(b.telefono,'')) >= 10) "
		|| " LEFT OUTER JOIN bdinteg:si_telefonos_actual d ON ( d.empresa = a.empresa AND d.numcte = a.numcte AND d.tipo_tel = 2 AND d.cofetel = 'V' AND length(nvl(d.telefono,'')) >= 10) "
		|| " JOIN bdicred:sd_maecredanexo e   ON (e.empresa= a.empresa AND e.num_credito = a.num_credito) "    
		|| " WHERE a.empresa = '001' "
		|| " AND a.tipo_cobranza = '" || ptipocobranza || "'" -- = 'P' "
		|| " AND a.fecha_insert ='"|| vfechacorte || "'"
		|| " AND a.status_cliente = 'AC' "
		|| " AND a.venc_mes_anterior ='"||vTipo||"'  " 
		|| " AND a.num_producto = '8500' "
		|| " AND ((nvl(b.telefono,'')<> '') OR (nvl(d.telefono,'') <> '')) ";

		LET cSQL3 = '">'||TRIM(cRuta)|| cNomArchSql; 

		LET cSQL = TRIM(cSQL1) || cSQL2 || TRIM(cSQL3);
		
		System cSQL;

		LET cSQL='chmod 777 '|| TRIM(cRuta)|| cNomArchSql; 
		System cSQL;

		let cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || cNomArchSql; 
		System cSQL;

		LET cSql = cSql;
		LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
		SYSTEM cSql;

		LET cSQL = '' ;
		LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cnomarchivo); 
		System cSQL;

		--Borra el archivo de control.
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNomArchSql;
		SYSTEM cSQL;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
		SYSTEM cSQL;
	ELIF (DAY(pfechacorte) = 19) THEN
-- OBTENEMOS EL NOMBRE DEL ARCHIVO
		SELECT valor_alfabetico
			INTO cnombre
		FROM bdicobranza:cb_param_campania
		WHERE empresa = pempresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 80;

		LET cNombreOriginal = cnombre;

		FOREACH WITH HOLD
			SELECT valor_numerico
				INTO iParamPagvencidos
			FROM bdicobranza:cb_param_campania
			WHERE empresa = pempresa
			AND tipo_campania = 1
			AND grupo_parametro = 'ARCHIVOS_M'

	
			--VALIDA QUE EXISTA EL ARCHIVO
			LET cnombre = TRIM(cNombreOriginal)||iParamPagvencidos;
			LET cnomarchivo1 =  TRIM(cnombre) ||'Aux_' || ptipocobranza || '_'||TO_CHAR(pfechacorte,'%d%m%Y')||'.txt';
			LET cnomarchivo =  TRIM(cnombre) || TO_CHAR(pfechacorte,'%d%m%Y')||'.txt';
			LET cNomArchSql = 'Ejecuta_' || ptipocobranza || '_' ||  'GenArchIVRpreventivatgc.sql';

			--EJECUTAMOS PARA GENERAR LOS ENCABEZADOS DEL ARCHIVO 
			LET cSql='';
			LET csql = 'echo "cliente'||','||'nombre'||','||'tipoproducto'||','||'telcasa'||','||'telcelular'||','||
						 'prioridad'||','||'fechalimitepago'||','||'fechacorte'||'" >'||TRIM(cruta)|| cnomarchivo;			 
			SYSTEM csql; 
			
			LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
			
			LET cSQL2 = " select a.numcte as cliente, 'X', "
			|| " a.num_producto as tipoproducto, " 
			|| " nvl(TRIM(substr(b.telefono,length(b.telefono)-9,10)),' ') as telcasa, " 
			|| " nvl(TRIM(substr(d.telefono,length(d.telefono)-9,10)),' ') as telcelular,1, " 
			|| " (day(e.prox_fecha_pago))||'/'||lpad(month(e.prox_fecha_pago),2,'0')||'/'||(year(e.prox_fecha_pago-1 units month))fechalimitepago, "
			|| " (day(e.prox_fecha_pago+4 units day))||'/'||lpad(month(e.prox_fecha_pago-1 units month),2,'0')||'/'||(year(e.prox_fecha_pago-1 units month))fechacorte "
			|| " from bdicobranza:cb_cat_directorio_cte a "
			|| " left outer join bdinteg:si_telefonos_actual b on (b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 1 and b.cofetel = 'V' and length(nvl(b.telefono,'')) >= 10) " 
			|| " left outer join bdinteg:si_telefonos_actual d on (d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 2 and d.cofetel = 'V' and length(nvl(d.telefono,'')) >= 10) " 
			|| " join bdicred:sd_maecredanexo e on (e.empresa= a.empresa and e.num_credito = a.num_credito) "    
			|| " where a.empresa = '"||pempresa||"' " 
			|| " and a.tipo_cobranza = '" || ptipocobranza || "' " 
			|| " and a.pago_venc =  " || iParamPagvencidos || " " 
			|| " and a.fecha_insert = '"|| vfechacorte || "' "   
			|| " and a.status_cliente = 'AC' " 
			|| " and a.num_producto = '8500' "
			|| " and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> '')) ";

			LET cSQL3 = '">'||TRIM(cRuta)|| TRIM(cNomArchSql); 

			LET cSQL = TRIM(cSQL1) ||RTRIM(cSQL2)|| TRIM(cSQL3);
			System cSQL;

			LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNomArchSql); 
			System cSQL;

			let cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || TRIM(cNomArchSql); 
			System cSQL;

			LET cSql = cSql;
			LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
			SYSTEM cSql;

			LET cSQL = '' ;
			LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cnomarchivo); 
			System cSQL;

			--BORRAMOS ARCHIVO DE CONTROL
			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cruta) || TRIM(cNomArchSql);
			SYSTEM cSQL;
			--BORRAMOS ARCHIVO DE CONTROL
			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cruta) || TRIM(cnomarchivo1);
			SYSTEM cSQL; 
			LET cSQL = '' ;
		END FOREACH;
	END IF;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03') RETURNING Bit_Cod_ret;

	
	RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;