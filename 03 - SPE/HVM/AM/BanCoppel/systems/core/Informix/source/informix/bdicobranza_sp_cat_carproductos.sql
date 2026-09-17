CREATE PROCEDURE "informix".sp_cat_carproductos(pempresa CHAR(3), pfechacorte DATE, pTipoCobranza  CHAR(1))
RETURNING CHAR(6);
--Creado por: Enrique Lizárraga
--23/12/2010
--Proceso para la generación del archivo ProductosCat_

-- Modificado por: MAHR
-- Fecha de Modificacion: Noviembre 2011. Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R
-- Fecha de Modificacion: Ene 2012: Se agrega el producto credinomina al tipo cobranza R

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cNomArchivoAux   	CHAR(100);
DEFINE cNomArchivoAux_R2   	CHAR(100);
DEFINE cNomArchEjecsql_1    CHAR(100);
DEFINE cNomArchEjecsql_2    CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cFechaCorte          DATE; --CHAR(8);
DEFINE cCodRetIB            CHAR(6);
DEFINE iParamNombreArch     INTEGER;
DEFINE cTipProd6001         CHAR(4);
DEFINE cTipProd8100         CHAR(4);
DEFINE cTipProd6300         CHAR(4);
DEFINE cTipProd6011         CHAR(4);
DEFINE cTipProd6400         CHAR(4);
DEFINE vday					INTEGER;
DEFINE vnum_prod			CHAR(4);
DEFINE vbandera				CHAR(1);
DEFINE vContTrab			INTEGER;
DEFINE vmax_fechacierre 	DATE;

--SET DEBUG FILE TO "/resplogifx/archivoscartera/productos.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0017';
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cNomArchivoAux			= "";
LET cNomArchivoAux_R2   	= "";
LET cNomArchEjecsql_1       = "";
LET cNomArchEjecsql_2       = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET cCodRetIB               = "000000";
LET iParamNombreArch        = 0;
LET cTipProd6001            = "";
LET cTipProd8100			= "";
LET cTipProd6300            = "";
LET cTipProd6011            = "";
LET cTipProd6400            = "";
LET vday 					= 0;
LET vnum_prod 				= "";
LET vbandera 				= "";
LET vContTrab 				= 0;
LET vmax_fechacierre 		= DATE(1);

BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            returning cCodRetIB;
        RETURN cCod_ret;
    END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '01')
            returning cCodRetIB;

	-- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = "" OR NVL(pTipoCobranza, "") = "" THEN
        LET cCod_ret= '104001';
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN  LET cMensaje = "";   END IF;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje,'02')
                INTO cCodRetIB;

        RETURN cCod_ret;
	END IF;

	--Validación de la empresa
    SELECT empresa
        INTO cempresa
        FROM bdinteg:si_empresas
        WHERE empresa = pEmpresa;

	IF NVL (cempresa, '') = '' THEN
        LET cCod_ret= '104002';
        SELECT descripcion
            INTO cMensaje
            FROM cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN   LET cMensaje = "";  END IF;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_ret,cMensaje,'02')
                INTO cCodRetIB;

        RETURN cCod_ret;
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
    IF NVL(cDelimitador,'') = '' THEN
        LET cCod_ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_ret;

        IF cMensaje IS NULL THEN  LET cMensaje = "";  END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_ret,cMensaje,'02')
                INTO cCodRetIB;

        RETURN cCod_ret;
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
        LET cCod_ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN  LET cMensaje = ""; END IF;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_ret,cMensaje,'02')
                INTO cCodRetIB;

        RETURN cCod_ret;
	END IF;

	--Obtener el nombre del archivo
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
			EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,"","",'03')
						  INTO cCodRetIB;

			RETURN cCod_ret;
		END IF;

		IF vnum_prod = "6001" THEN
			LET iParamNombreArch = 46;
		ELIF vnum_prod = "8100" OR vnum_prod = "8500" THEN
			LET iParamNombreArch = 77;
		END IF;
	ELIF pTipoCobranza = 'P' THEN
		LET iParamNombreArch = 46;
    ELSE
        LET iParamNombreArch = 47;   -- pTipoCobranza = 'R' OR pTipoCobranza = 'E'
    END IF;

    SELECT valor_alfabetico
        INTO cnombre
        FROM bdicobranza:cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = iParamNombreArch;

    -- Valida que exista el nombre del archivo
    IF NVL(cnombre,"") = "" THEN
        LET cCod_ret = '104006';
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen     = 3
            AND codigo_error = cCod_ret; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_ret,cMensaje,'02')
                INTO cCodRetIB;
        RETURN cCod_ret;
	END IF;

    LET cFechaGenArchivo = to_char(pfechacorte,'20%m%Y'); ---A.L.L Se modifica para que ponga siempre el dia 20
    LET cFechaCorte = pfechacorte;

    LET cNomArchivoAux = TRIM(cnombre) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'.txt';
	LET cNomArchivo= trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cNomArchEjecsql_1 = 'Ejec_GenArchProductos_' || pTipoCobranza || '.sql';

    -- Obtiene la informacion segun el tipo de cobranza    
    IF (pTipoCobranza = 'A' OR pTipoCobranza = 'P') THEN 

		SELECT valor_alfabetico INTO cTipProd6001
		FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
		AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro = 1 AND valor_numerico = 6001;

		SELECT valor_alfabetico INTO cTipProd8100
		FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
		AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro = 17 AND valor_numerico = 8100;

        LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cruta) || TRIM(cNomArchivoAux)||'';
   
			LET cSQL2 = " select a.numcte, " 
				|| " (case when a.num_producto = '6001' then '" || TRIM(cTipProd6001) || "' when a.num_producto = '8100' then '" || TRIM(cTipProd8100) || "' end) tipoproducto,"
				|| " a.num_credito, b.num_tarjeta,"
                || " (to_char(fecha_insert,'%Y-%m-')|| d.dia_corte ) fechacorte, " 
                || " substr(replace(replace(trim(c.nombre_ref),'|',''),'/',''),1,52)nombrereferencia1,"
                || " substr(replace(replace(trim(c.nombre_ref),'|',''),'/',''),57,26)apellidopaternoreferencia1, " 
                || " substr(replace(replace(trim(c.nombre_ref),'|',''),'/',''),84,26)apellidomaternoreferencia1, "
                || " 'D' sexoreferencia, 'D' estadocivilreferencia "
                || " from bdicobranza:cb_cat_directorio_cte a , bdicred:sd_tarjeta b , bdisolic:ss_refpersonales c, bdicred:sd_maecredanexo d "
                || " where a.empresa = b.empresa "
                || "   and a.num_credito = b.num_credito "
                || "   and b.tipo_tarjeta ='T' "		    
                || " and b.secuencia = (select max(tar2.secuencia) from bdicred:sd_tarjeta tar2 " 
                || "       where tar2.empresa = a.empresa and tar2.num_credito = a.num_credito and tar2.tipo_tarjeta ='T' ) "
                || " and a.numcte = c.numcte "
                || " and a.num_credito = c.num_solicitud "
                || " and a.empresa = d.empresa "
                || " and a.num_credito = d.num_credito "
                || " and a.tipo_cobranza = '"||pTipoCobranza||"'"
                || " and a.fecha_insert = '"|| cFechaCorte || "'"
                || " and a.status_cliente <>'NT'"
                || " and a.tipo_logica > '0' "
				|| " and a.canal > '' "
				|| " and c.numcte_ref = 'R1' ";
--		IF pTipoCobranza = 'A' THEN
--			LET cSQL2 = " " || TRIM(cSQL2) || " and a.num_producto = '" ||vnum_prod|| "';";
--		END IF;
    ELSE ---------------------------------------------------------------------------------------------------------
                                                        -- Obtiene la informacion tipo Cobranza: R
        SELECT valor_alfabetico INTO cTipProd6300
            FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
            AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro = 2 AND valor_numerico = 6300;

        SELECT valor_alfabetico INTO cTipProd6011
            FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
            AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro = 3 AND valor_numerico = 6011;

        SELECT valor_alfabetico INTO cTipProd6400
            FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
            AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro = 4 AND valor_numerico = 6400;

                                                        -- Obtiene informacion para Prestamo Personal y Credinomina   
        LET cNomArchEjecsql_2 = 'Ejec_GenArchProductos_2_' || pTipoCobranza || '.sql';
        LET cNomArchivoAux_R2 = TRIM(cnombre) || cFechaGenArchivo || '_aux2_' || pTipoCobranza ||'.txt';

        LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cruta) || TRIM(cNomArchivoAux_R2)||'';
                            
        LET cSQL2 = " SELECT {+INDEX(bdicred:sd_ctascarg 126_140)} a.numcte, " 
                --|| " (case when a.num_producto = '6011' then 'TR' else 'PP' end) tipoproducto, "
                || " (case when a.num_producto = '6011' then '" || TRIM(cTipProd6011) || "' when a.num_producto = '6300' then '" || TRIM(cTipProd6300) 
                || "' else '" || TRIM(cTipProd6400) || "' end) tipoproducto, "
                || " a.num_credito, b.num_cta, (to_char(fecha_insert,'%Y-%m-')|| d.dia_corte ) fechacorte, "
                || " substr(replace(replace(trim(c.nombre_ref),'|',''),'/',''),1,52)nombrereferencia1, "
                || " substr(replace(replace(trim(c.nombre_ref),'|',''),'/',''),57,26)apellidopaternoreferencia1, "
                || " substr(replace(replace(trim(c.nombre_ref),'|',''),'/',''),84,26)apellidomaternoreferencia1, "
                || " 'D' sexoreferencia, 'D' estadocivilreferencia "
                || " FROM cb_cat_directorio_cte a , bdicred:sd_ctascarg b , bdisolic:ss_refpersonales c, bdicred:sd_maecredanexocrd d "
                || " WHERE a.empresa = b.empresa "
                || "  AND a.num_credito = b.num_credito "
                || " AND b.naturaleza ='A' "
                || " AND a.numcte = c.numcte " 
                || " AND a.num_credito = c.num_solicitud "
                || " AND a.empresa = d.empresa "
                || " AND a.num_credito = d.num_credito "
                || " AND a.tipo_cobranza = '"||pTipoCobranza||"' "
                || " AND a.fecha_insert = '"|| cFechaCorte || "' "
                || " AND a.status_cliente <>'NT' "
                || " AND a.tipo_logica > '0' "
				|| " AND a.canal > '' "
                || " AND c.numcte_ref = 'R1' ";
        
        LET cSQL3 = '">'||TRIM(cruta)|| cNomArchEjecsql_2;                
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        System cSQL;
        LET cSQL = '' ;
        LET cSQL = 'chmod 666 ' || TRIM(cRuta) || cNomArchEjecsql_2 ;
        LET cSQL = '' ;
        LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || cNomArchEjecsql_2 ;
        SYSTEM cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux_R2) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
        SYSTEM cSql;
		
		--A.L.L.SE COMPRIME EL ARCHIVO	
		LET cSql = "gzip " || trim(cRuta) || trim(cNomArchivo); 
		system cSql;

        -- Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cRuta) || cNomArchEjecsql_2 || ' ' || TRIM(cRuta) || TRIM(cNomArchivoAux_R2);
        SYSTEM cSQL;

        ---------------------------------------------------------------------------------------------------------
                                            -- Obtiene la informacion para reestructura  (referencias se obtienen de diferente manera)
        LET cSQL  = "";
        LET cSQL1 = "";
        LET cSQL2 = "";
        LET cSQL3 = "";

        LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cruta) || TRIM(cNomArchivoAux)||'';

        LET cSQL2 = " SELECT {+INDEX(bdicred:sd_ctascarg 126_140)} a.numcte, " 
             -- || " (case when a.num_producto = '6011' then 'TR' else 'PP' end) tipoproducto, "
                || " (case when a.num_producto = '6011' then '" || TRIM(cTipProd6011) || "' else '" || TRIM(cTipProd6300) || "' end) tipoproducto, "
                || " a.num_credito, b.num_cta, (to_char(fecha_insert,'%Y-%m-')|| d.dia_corte ) fechacorte, "
                || " substr(replace(replace(trim(c.nombre_ref),'|',''),'/',''),1,52)nombrereferencia1, "
                || " substr(replace(replace(trim(c.nombre_ref),'|',''),'/',''),57,26)apellidopaternoreferencia1, "
                || " substr(replace(replace(trim(c.nombre_ref),'|',''),'/',''),84,26)apellidomaternoreferencia1, "
                || " 'D' sexoreferencia, 'D' estadocivilreferencia "
                || " FROM cb_cat_directorio_cte a , bdicred:sd_ctascarg b , bdisolic:ss_refpersonales c, "
                || "      bdicred:sd_maecredanexocrd d, bdicred:sd_maecredcrd e "
                || " WHERE a.empresa = b.empresa "
                || " AND a.num_credito = b.num_credito "
                || " AND b.naturaleza ='A' "
                || " AND a.empresa = e.empresa "
                || " AND a.num_credito = e.num_credito "
                || " AND a.numcte = e.numcte "
                || " AND c.empresa = e.empresa "
                || " AND c.numcte = a.numcte "
                || " AND c.num_solicitud = e.credito_externo "
                || " AND a.empresa = d.empresa "
                || " AND a.num_credito = d.num_credito "
                || " AND a.tipo_cobranza = '"||pTipoCobranza||"' "
                || " AND a.fecha_insert = '"|| cFechaCorte || "' "
                || " AND a.status_cliente <> 'NT' "
                || " AND a.tipo_logica > '0' "
				|| " AND a.canal > '' "
                || " AND c.numcte_ref = 'R1' "; 
    END IF;

    LET cSQL3 = '">'||TRIM(cruta)|| cNomArchEjecsql_1;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);

	IF ( cSQL <> '' ) THEN
        System cSQL;

        LET cSQL = '' ;
        LET cSQL = 'chmod 666 ' || TRIM(cRuta) || cNomArchEjecsql_1 ;
        LET cSQL = '' ;
        LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || cNomArchEjecsql_1 ;
        SYSTEM cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
        SYSTEM cSql;
		
		-- Quitar compresión de archivo debido a que el cifrado lo comprime. MACF 2014/08/12
    --A.L.L.SE COMPRIME EL ARCHIVO	
		--LET cSql = "gzip " || trim(cRuta) || trim(cNomArchivo); 
		--system cSql;

        -- Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cRuta) || cNomArchEjecsql_1 || ' ' || TRIM(cRuta) || TRIM(cNomArchivoAux);
        SYSTEM cSQL;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,"","",'03')
                      INTO cCodRetIB;

        RETURN cCod_ret;
    END IF;

END;
END PROCEDURE;