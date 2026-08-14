CREATE PROCEDURE "informix".sp_cat_cargeneracion(pempresa CHAR(3), pfechacorte DATE, pTipoCobranza    CHAR(1))
RETURNING CHAR(6);
--Creado por: Enrique Lizárraga
--23/12/2010
--Proceso para la generación del archivo ctbcpl_generacion_

-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_retIB			CHAR(6);
DEFINE vproceso				CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cFechaCorte          DATE; --CHAR(8);
DEFINE iParamNombreArch     INTEGER;
DEFINE vday					INTEGER;
DEFINE vnum_prod			CHAR(4);
DEFINE vbandera				CHAR(1);
DEFINE vContTrab			INTEGER;
DEFINE vmax_fechacierre		DATE;

--SET DEBUG FILE TO "/home/syscobra/cat/envios/cierre_llamadas.out";
--TRACE ON;

--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_retIB                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0018';
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecSql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET iParamNombreArch		= 0;
LET vday 					= 0;
LET vnum_prod 				= '';
LET vbandera 				= '';
LET vContTrab 				= 0;
LET vmax_fechacierre		= DATE(1);

BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_retIB;
        RETURN cCod_ret;
    END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '01')
    Returning cCod_retIB;

	-- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = "" OR NVL(pTipoCobranza, "") = "" THEN
        LET cCod_Ret= "104001";
        SELECT descripcion
        INTO cMensaje
        FROM bdicobranza:"informix".cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
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

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

	--Obtener caracter delimitador
    SELECT valor_alfabetico
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = pempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 2;

	--Valida que exista el caracter
    IF NVL(cdelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

	--Obtener ruta del archivo
    SELECT valor_alfabetico
        INTO cruta
        FROM bdicobranza:cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 3;

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

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

        -- Se asigna nombre de archivo a generar, dependiendo del Tipo de Cobranza
    IF pTipoCobranza = 'A' THEN
		SELECT MAX(fecha_insert) INTO vmax_fechacierre
			FROM bdicobranza:"informix".cb_cat_directorio_cte
			WHERE empresa = pempresa AND  tipo_cobranza = pTipoCobranza;

		LET vday = DAY(vmax_fechacierre);

		FOREACH WITH HOLD
			SELECT valor_alfabetico INTO vnum_prod
			FROM "informix".cb_param_campania 
			WHERE empresa = pempresa AND tipo_campania = 61
			AND grupo_parametro = pTipoCobranza
			AND valor_numerico = vday

			IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

			SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = pempresa AND valor = vnum_prod;

			IF vbandera IS NULL THEN LET vbandera = ''; END IF;

			IF vbandera = 'S' THEN
				LET vContTrab = vContTrab + 1;
			END IF;
		END FOREACH;

		IF vContTrab = 0 THEN
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '03')
					Returning cCod_retIB;

			RETURN cCod_ret;
		END IF;

		IF vnum_prod = "6001" THEN
			LET iParamNombreArch = 40;
		ELIF vnum_prod = "8100" OR vnum_prod = "8500" THEN
			LET iParamNombreArch = 42;
		END IF;
	END IF;
	IF pTipoCobranza = 'P' THEN LET iParamNombreArch = 40; END IF;
    IF (pTipoCobranza = 'R' or pTipoCobranza = 'E') THEN LET iParamNombreArch = 41; END IF;

                    --Obtener el nombre del archivo
    SELECT valor_alfabetico  INTO cnombre
        FROM bdicobranza:cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = iParamNombreArch;

    LET cFechaGenArchivo =  to_char(pfechacorte,'20%m%Y');  ---A.L.L Se modifica para que ponga siempre el dia 20
	LET cFechaCorte = pfechacorte;

	--Validar que existe el archivo	

	LET cnomarchivo1 =  trim(cnombre)||'_Aux_' || pTipoCobranza ||cFechaGenArchivo||'.txt ';
    LET cnomarchivo =  trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_GenArchGeneracion_' || pTipoCobranza || '.sql';

    LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1)||'';

    IF (pTipoCobranza = 'A' or pTipoCobranza = 'P') THEN   -- Genera query segun el tipo de cobranza

			LET cSQL2 = " SELECT a.numcte cliente,  a.puntualidad, a.eficiencia, a.calificacion, "
				|| " nvl ((select ((d.Porcentaje * a.pago_minimo )/100) "
				|| " from bdicobranza:cb_compac_montomin d "
				|| " where d.Meses_vencido = a.pago_venc "
				|| " and d.Monto_vencido_min <= a.pago_minimo "
				|| " and d.Monto_vencido_max >= a.pago_minimo),0) Conveniominimo , "
				|| " DECODE(nvl(status_cliente,''),'TE',3,0) estatus, "
				|| " a.tipo_logica, a.tipo_cobranza, nvl(fecha_ultimo_contacto, '1900-01-01 00:00:00') , "    
				|| " (to_char(fecha_insert,'%Y-%m-')|| b.dia_corte ) fechacorte, a.prioridad, a.pago_minimo as vencido "
				|| " FROM cb_cat_directorio_cte a, bdicred:sd_maecredanexo b "
				|| " WHERE  a.empresa = b.empresa "
				|| " AND a.num_credito = b.num_credito "
				|| " AND a.empresa = '" || pempresa || "' "
				|| " AND a.tipo_cobranza = '" || pTipoCobranza || "' "
				|| " AND a.fecha_insert ='"|| cFechaCorte || "' "
				|| " AND a.tipo_logica > '0' "
				|| " AND a.canal = '' "
				|| " AND a.status_cliente <> 'NT'; ";
--		IF pTipoCobranza = 'A' THEN
--			LET cSQL2 = " " || TRIM(cSQL2) || " AND a.num_producto = '" ||vnum_prod|| "';";
--		END IF; 
    ELSE  

        LET cSQL2 = " SELECT a.numcte cliente,  a.puntualidad, a.eficiencia, a.calificacion, "
                || " 0 Conveniominimo , "
                || " 0 estatus, "
                || " a.tipo_logica, a.tipo_cobranza, nvl(fecha_ultimo_contacto, '1900-01-01 00:00:00') , "    
                || " (to_char(fecha_insert,'%Y-%m-')|| b.dia_corte ) fechacorte, a.prioridad, a.pago_minimo as vencido "
                || " FROM cb_cat_directorio_cte a, bdicred:sd_maecredanexocrd b "
                || " WHERE  a.empresa = b.empresa "
                || " AND a.num_credito = b.num_credito "
                || " AND a.empresa = '" || pempresa || "' "
                || " AND a.tipo_cobranza = '" || pTipoCobranza || "'  "
                || " AND a.fecha_insert ='"|| cFechaCorte || "' "
                || " AND a.tipo_logica > '0' "
				|| " AND a.canal = '' "
                || " AND a.status_cliente <> 'NT'; ";
    END IF

    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
	-- Quitar compresión de archivo debido a que el cifrado lo comprime. MACF 2014/08/12
  --A.L.L.SE COMPRIME EL ARCHIVO	
	--LET cSql = "gzip " || trim(cruta) || trim(cnomarchivo); 
	--system cSql;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoEjecSql;
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '03')
            Returning cCod_retIB;
	
    RETURN cCod_ret;

END;
END PROCEDURE;