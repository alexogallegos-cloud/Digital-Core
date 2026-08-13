CREATE PROCEDURE "informix".sp_cat_cartelefonos(pEmpresa         CHAR(3),                                                   
                                                pFechaGenCartera DATE,
                                                pTipoCobranza    CHAR(1), 
                                                pStatusTel       CHAR(2))
RETURNING CHAR(6) AS COD_RET;

-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R
-----------------------------------------------------------------------------------------------------------------
-- Modificado por: Abrham López López
-- Fecha: Marzo 2013
-- Modificacion: Se modifica proceso para que no meta caracteres no numericos en telefono y extension.
-- execute procedure sp_cat_cartelefonos('001','02-20-2015','A','01');

-- DECLARACIONES
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensaje 		    CHAR(80);
DEFINE cRuta                CHAR(100);
DEFINE cNomArchivo          CHAR(100);
DEFINE cNomArchivoAux       CHAR(100);
DEFINE cNomArchivoEjecSql   CHAR(100);
DEFINE iTipoTelefono        SMALLINT;
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(100);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cEmpresa             CHAR(3);
DEFINE cDelimitador         CHAR(1);
DEFINE cTipoCampania        CHAR(1);
DEFINE cCodRetIB            CHAR(6);
DEFINE cFechaCorte          DATE; --CHAR(8);
DEFINE vproceso				CHAR(30);
DEFINE iParamNombreArch     INTEGER;
DEFINE vday					INTEGER;
DEFINE vnum_prod			CHAR(4);
DEFINE vbandera				CHAR(1);
DEFINE vContTrab			INTEGER;
DEFINE vmax_fechacierre 	DATE;

-- INICIALIZACIONES
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cCodRet                 = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET cRuta                   = "";
LET cNomArchivo             = "";
LET cNomArchivoAux          = "";
LET cNomArchivoEjecSql      = "";
LET iTipoTelefono           = 0;
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cEmpresa                = "000";
LET cDelimitador            = "";
LET cTipoCampania           = "";
LET cCodRetIB               = "000000";
LET vproceso				= '0019';
LET iParamNombreArch        = 0;
LET vday 					= 0;
LET vnum_prod 				= '';
LET vbandera 				= '';
LET vContTrab 				= 0;
LET vmax_fechacierre 		= DATE(1);

-- SET DEBUG FILE TO "/aplicacion/resplogifx/archivoscartera/sp_ctbcpl_gen_arctelefonos.out";
-- TRACE ON;

BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, error_info
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensaje = error_info;
            EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    -- DIRECTIVA PARA TENER LECTURA DE TABLAS AUNQUE ESTEN BLOQEUADAS
    SET ISOLATION TO DIRTY READ;
    -- DIRECTIVA PARA QUE EXISTA UNA ESPERA DE TRES SEGUNDOS AL ACCESO 
    SET LOCK MODE TO WAIT 3;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,"","","01")
             INTO cCodRetIB;
    
    -- VALIDA LOS PARAMETROS DE ENTRADA   
    IF NVL(pEmpresa,"") = "" OR NVL(pTipoCobranza,"") = "" OR NVL(pFechaGenCartera,"")= "" OR NVL(pStatusTel,"") = "" THEN
        LET cCodRet = "104001";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                INTO cCodRetIB;
        RETURN cCodRet;
    END IF
    
    SELECT empresa
        INTO cEmpresa
        FROM bdinteg:si_empresas
        WHERE empresa = pEmpresa;

    IF NVL(cEmpresa,'') = '' THEN
        LET cCodRet = "104002";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    SELECT tipo_cobranza
        INTO cTipoCampania
        FROM bdicobranza:cb_cat_campania
        WHERE empresa     = pEmpresa
        AND tipo_cobranza = pTipoCobranza   
        AND modulo_cob    = 3;

    IF NVL(cTipoCampania,'') = '' THEN
        LET cCodRet = "104003";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
             INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
    
    -- OBTIENE EL CARACTER SEPARADOR
    SELECT TRIM(valor_alfabetico)
        INTO cDelimitador
        FROM bdicobranza:cb_param_campania 
        WHERE empresa       = pEmpresa 
        AND tipo_campania   = 1 
        AND grupo_parametro = "ARCHIVOS" 
        AND num_parametro   = 2;
    
    -- VALIDA QUE EXISTA EL CARACTER
    IF NVL(cDelimitador,"") = "" THEN
        LET cCodRet = "104004";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen     = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- OBTIENE LA RUTA DESTINO DEL ARCHIVO
    SELECT TRIM(valor_alfabetico)
        INTO cRuta
        FROM bdicobranza:cb_param_campania 
        WHERE empresa = pEmpresa
        AND tipo_campania   = 1 
        AND grupo_parametro = "ARCHIVOS" 
        AND num_parametro   = 3;
    
    -- VALIDA QUE EXISTA LA CARPETA
    IF NVL(cRuta,"") = "" THEN
        LET cCodRet = "104005";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen     = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF

    -- OBTIENE EL NOMBRE DEL ARCHIVO
    IF pTipoCobranza = 'A' THEN
		SELECT MAX(fecha_insert) INTO vmax_fechacierre
			FROM bdicobranza:"informix".cb_cat_directorio_cte
			WHERE empresa = pEmpresa AND  tipo_cobranza = pTipoCobranza;

		LET vday = DAY(vmax_fechacierre);

		FOREACH WITH HOLD
			SELECT valor_alfabetico INTO vnum_prod
			FROM "informix".cb_param_campania 
			WHERE empresa = pEmpresa AND tipo_campania = 61
			AND grupo_parametro = pTipoCobranza
			AND valor_numerico = vday

			IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

			SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = pEmpresa AND valor = vnum_prod;

			IF vbandera IS NULL THEN LET vbandera = ''; END IF;
			
			IF vbandera = 'S' THEN
				LET vContTrab = vContTrab + 1;
			END IF;
		END FOREACH;

		IF vContTrab = 0 THEN
			EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,"","","03")
					INTO cCodRetIB;
			RETURN cCodRet;
		END IF;

		IF vnum_prod = "6001" THEN
			LET iParamNombreArch = 44;
		ELIF vnum_prod = "8100" OR vnum_prod = "8500" THEN
			LET iParamNombreArch = 43;
		END IF;
    ELIF pTipoCobranza = 'P' THEN
		LET iParamNombreArch = 44;
	ELSE
        LET iParamNombreArch = 45;   -- pTipoCobranza = 'R' OR pTipoCobranza = 'E'
    END IF;

    SELECT TRIM(valor_alfabetico)  INTO cNomArchivo
        FROM bdicobranza:cb_param_campania 
        WHERE empresa       = pEmpresa 
        AND tipo_campania   = 1 
        AND grupo_parametro = "ARCHIVOS" 
        AND num_parametro   = iParamNombreArch;
    
    -- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
    IF NVL(cNomArchivo,"") = "" THEN
        LET cCodRet = "104006";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen     = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF

    LET cFechaGenArchivo = to_char(pFechaGenCartera,'20%m%Y');  ---A.L.L Se modifica para que ponga siempre el dia 20
    LET cFechaCorte = pFechaGenCartera;

    LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'.txt';
    LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '.txt';
    LET cNomArchivoEjecSql = 'Ejec_GenArchTel_' || pTipoCobranza || '.sql';
    

    LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";

    IF (pTipoCobranza = 'A' or pTipoCobranza = 'P') THEN   --Genera query segun el tipo de cobranza
  
			LET cSQL2 = " SELECT tel.numcte, tel.tipo_tel, TRIM(rpad(nvl(case when bdinteg:val_num(tel.telefono) then replace(replace(replace(tel.telefono,'.',''),'-',''),',','') else '0' end,' '),13,' ')) as telefono, rpad(nvl(case when bdinteg:val_num(tel.extension) then replace(replace(replace(tel.extension,'.',''),'-',''),',','') else '0' end,' '),5,' ')as extension, (to_char(dir.fecha_insert,'%Y-%m-')|| d.dia_corte ) fechacorte "
                || " FROM bdinteg:si_telefonos_actual tel, bdicobranza:cb_cat_directorio_cte dir, bdicred:sd_maecredanexo d  "
                || " WHERE dir.empresa  = tel.empresa  "
                || " AND dir.numcte  = tel.numcte "
                || " AND d.empresa = dir.empresa "
                || " AND d.num_credito = dir.num_credito "
                || " AND  tel.empresa = '" || pEmpresa || "'  "
				|| " AND tel.tipo_tel in (1,2,3) "
                || " AND dir.tipo_cobranza = '" || pTipoCobranza || "' "
                || " AND dir.fecha_insert = '" || cFechaCorte || "' "                
                || " and dir.tipo_logica > '0'"
                || " AND dir.status_cliente <> 'NT' "
				|| " AND dir.canal = '' "
				|| " and tel.cofetel= 'V' ";
--		IF pTipoCobranza = 'A' THEN
--			LET cSQL2 = " " || TRIM(cSQL2) || " and dir.num_producto = '" ||vnum_prod|| "';";
--		END IF;
    ELSE
        
		LET cSQL2 = " SELECT tel.numcte, tel.tipo_tel, TRIM(rpad(nvl(case when bdinteg:val_num(tel.telefono) then replace(replace(replace(tel.telefono,'.',''),'-',''),',','') else '0' end,' '),13,' ')) as telefono, rpad(nvl(case when bdinteg:val_num(tel.extension) then replace(replace(replace(tel.extension,'.',''),'-',''),',','') else '0' end,' '),5,' ')as extension, (to_char(dir.fecha_insert,'%Y-%m-')|| d.dia_corte ) fechacorte "
                || " FROM bdinteg:si_telefonos_actual tel, bdicobranza:cb_cat_directorio_cte dir, bdicred:sd_maecredanexocrd d  "
                || " WHERE dir.empresa  = tel.empresa  "
                || " AND dir.numcte  = tel.numcte "
                || " AND d.empresa = dir.empresa "
                || " AND d.num_credito = dir.num_credito "
				|| " AND tel.tipo_tel in (1,2,3) "
                || " AND  tel.empresa = '" || pEmpresa || "'  "
                || " AND dir.tipo_cobranza = '" || pTipoCobranza || "' "
                || " AND dir.fecha_insert = '" || cFechaCorte || "' "                
                || " and dir.tipo_logica > '0'"                
                || " AND dir.status_cliente <> 'NT' " 
				|| " AND dir.canal = '' " 
				|| " and tel.cofetel= 'V' ";
    END IF;

    LET cSQL3 = ' " > '|| TRIM(cRuta) || cNomArchivoEjecSql;
    
    LET cSQL1 = TRIM(cSQL1);
    LET cSQL3 = TRIM(cSQL3);

    LET cSQL = cSQL1 || cSQL2 || cSQL3;

    -- Verifica que no este vacia la consulta.
    IF ( cSQL <> '' ) THEN 
        SYSTEM cSQL;
        -- Permiso para la creacion de archivo.
        LET cSQL = '' ;
        LET cSQL = 'chmod 666 ' || TRIM(cRuta) || cNomArchivoEjecSql ;
        LET cSQL = '' ;
        LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || cNomArchivoEjecSql ;
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
        LET cSQL = 'rm ' || TRIM(cRuta) || cNomArchivoEjecSql || '  ' || TRIM(cRuta) || TRIM(cNomArchivoAux);
        SYSTEM cSQL;

        -- Operacion exitosa "Archivo Generado".
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,"","","03")
                INTO cCodRetIB;
        RETURN cCodRet;

    END IF;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para generar el archivo de Teléfonos del cliente', 
'AUTOR: Enrique Lizárraga Lugo ',
'VERSION: 20101109.1545';


CREATE PROCEDURE "informix".inserta_bitacora_cob(vempresa CHAR(3),
                                            vproceso CHAR(4), cCod_ret CHAR(5), cMensaje CHAR(80), t_eje CHAR(2))
--declaracion de variables
----------------------------------------------------------------------------------------------
     DEFINE sql_err 			        INTEGER;
     DEFINE isam_err 		        INTEGER;
     DEFINE error_info		        CHAR(80);
     DEFINE vdia						DATE;
     DEFINE vhora					CHAR(8);

     LET sql_err       = 0;
	   LET isam_err      = 0;
	   LET error_info    = '';
	                          
	BEGIN

    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

    IF (t_eje = '01') THEN

            INSERT INTO cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(vempresa, vproceso, today, '000000', 'PROCESO INICIALIZADO', user, vdia, vhora);
	    
    ELIF (t_eje = '02') THEN

        INSERT INTO cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES(vempresa, vproceso, today, cCod_ret, cMensaje, user, vdia, vhora);
    
    ELIF (t_eje = '03') THEN

        INSERT INTO bdicobranza:cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES(vempresa, vproceso, today, '000000', 'PROCESO FINALIZADO', user, vdia,  vhora);

    END IF;

	END;
END PROCEDURE;