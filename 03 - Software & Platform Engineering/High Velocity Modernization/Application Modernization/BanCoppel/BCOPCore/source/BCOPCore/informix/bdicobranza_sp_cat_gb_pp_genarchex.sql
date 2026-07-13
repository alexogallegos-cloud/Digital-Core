CREATE PROCEDURE "informix".sp_cat_gb_pp_genarchex(pEmpresa  CHAR(3),pFecha_ex DATE)
RETURNING CHAR(6) AS codigo_retorno;

-- AUTOR : Abrham Lopez Lopez. El SP genera un archivo que extrae información de los clientes excluidos para campaña IVR prestamo personal',
-- FECHA : 05/NOVIEMBRE/2011   BD: BDICOBRANZA
-- Modificado por: MAHR. Abril 2012. Se asigna proceso: 2004 a fin de no repetir con otros procesos asignados.


--Declaración de variables        
DEFINE cCodRet              CHAR(6); 
DEFINE cMensajeRet          CHAR(80);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE cSql                 CHAR(2400);
DEFINE cNombreArchivo1      CHAR(50);
DEFINE cNombreArchivo       CHAR(50);
DEFINE cRuta                CHAR(100);
DEFINE iNumreg              INTEGER;
DEFINE iDatos               INTEGER;
DEFINE cEmpresa             CHAR(3);
DEFINE cNombre              CHAR(100);
DEFINE cdelimitador         CHAR(1);
DEFINE cValor_status        CHAR(20);
DEFINE cSql1                CHAR(150);
DEFINE cSql2                CHAR(1500);
DEFINE cSql3                CHAR(100);
DEFINE cCodRetIB            CHAR(6);
DEFINE cMensaje             CHAR(80);
DEFINE cProceso             CHAR(4);
DEFINE vfecha_insert		DATE;


--Inicialización de variables
LET iSqlErr                = 0;
LET iIsamErr               = 0;
LET cErrorInfo             = "";
LET cCodRet                = "000000";
LET cRuta                  = "";
LET cNombreArchivo1        = "";
LET cNombreArchivo         = "";
LET iNumreg                = 0;
LET iDatos                 = 0;
LET cEmpresa               = "";
LET cNombre                = '';
LET cdelimitador           = '';
LET cSql                   = "";
LET cValor_status          = "";
LET cMensajeRet            = 'PROCESO EXITOSO';
LET cSql1                  = "";
LET cSql2                  = "";
LET cSql3                  = "";
LET cCodRetIB              = "000000";
LET cMensaje               = "";
LET cProceso               = '2004'; 
LET vfecha_insert		   = DATE(1);

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet     = iSqlErr;
            LET cMensajeRet = cErrorInfo;
            EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensajeRet,"02")
                     INTO cCodRetIB;
            RETURN cCodRet; 
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/home/syscobra/cat/envios/sp_ctbcpl_gen_arcctesexcluidos.out';
--TRACE ON;

    -- Inserta bitacora de procesos
    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,"","","01")
             INTO cCodRetIB;
        
    -- Validacion de los datos de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet     = "104007";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
    
    SELECT empresa
        INTO cEmpresa 
        FROM bdinteg:si_empresas
        WHERE empresa = pEmpresa;

    IF NVL(cEmpresa,"")= "" then
        LET cCodRet = "104002";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen     = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    IF NVL(pFecha_ex,"") = "" THEN
        LET cCodRet     = "104008";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- obtener la ruta donde se almacenara el archivo que sera enviado a buro de credito
    SELECT valor_alfabetico 
        INTO cRuta
        FROM bdicobranza:cb_param_campania
        WHERE empresa         = pEmpresa
        AND tipo_campania   = '1'
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro   = 36;

    IF NVL(cRuta,"")    = "" THEN
        LET cCodRet     = "104005";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                  INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- Se obtiene del nombre del archivo
    SELECT valor_alfabetico 
        INTO cNombre
        FROM bdicobranza:cb_param_campania
        WHERE empresa         = pEmpresa
        AND tipo_campania   = '1'
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro   = 50;

    IF NVL(cNombre,"") = "" THEN
        LET cCodRet = "104006";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;


    --Obtener caracter delimitador
    SELECT trim(valor_alfabetico)
        INTO cdelimitador
        FROM bdicobranza:cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 25;
    
    IF NVL(cdelimitador,"") = "" THEN
        LET cCodRet     = "104004";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
     
    LET cNombreArchivo1 = 'prueba.txt';
    LET cNombreArchivo  = TRIM(cNombre) || LPAD(TRIM(DAY(pFecha_ex)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(pFecha_ex)::CHAR(2)),2,'0') || YEAR(pFecha_ex) || '.txt';
	
	select max(fecha_insert) INTO Vfecha_insert
    from bdicobranza:cb_cat_directorio_cte 
	WHERE empresa = '001' 
        and tipo_cobranza = 'E' 
        and num_producto = '6300';
   
    FOREACH
        SELECT trim(valor_alfabetico)
            INTO cValor_status
            FROM bdicobranza:cb_param_campania
            WHERE empresa         = pEmpresa
            AND tipo_campania   = '1'
            AND grupo_parametro = 'STATARCHCE'
            AND valor_alfabetico IN ('EX','IN','AC') -- mahr. Solo se contemplan estos status para CAT
     
        SELECT COUNT (numcte)
            INTO iNumreg
			FROM bdicobranza:cb_cat_directorio_cte
			WHERE empresa = pEmpresa
            AND tipo_cobranza = 'E'
            AND status_cliente = cValor_status
			AND fecha_modificacion = pFecha_ex
            AND num_producto = '6300';
		    

        IF iNumreg = 0 THEN
            CONTINUE FOREACH;
        END IF;

		LET iDatos = iDatos + 1;
			
		--se ejecuta para ponerle el encabezado
		let cSql='';
		let csql = 'echo "cliente'||','||'nombre'||','||'tipoproducto'||','||'telcasa'||','||'telcelular'||','||
				 'fechalimitepago'||','||'fechacorte'||'">'||TRIM(cruta)|| cNombreArchivo;   
		system csql; 

        -- para generar el archivo 
		LET cSql1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreArchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

		LET cSql2 = " select  a.numcte as cliente , "
				|| " trim (h.apell_paterno) ||' '|| trim (h.apell_materno)||' '|| trim(h.nombre1) ||' '|| trim(h.nombre2) as nombre , "
				|| " a.num_producto as tipoproducto, " 
				|| " nvl(b.telefono,' ') as telcasa, "
                || " nvl((case when d.carrier = 1 then 5 || trim(substr(d.telefono,length(d.telefono)-9,10))  when d.carrier = 2 then 1 || trim(substr(d.telefono,length(d.telefono)-9,10))  else 1 || d.telefono end),'') as telcelular, "
				|| " (e.prox_fecha_pago) as fechalimitepago, "
				|| " (e.prox_fecha_pago) as fechacorte "
				|| " from bdicobranza:cb_cat_directorio_cte  a "
				|| " join bdinteg:si_cliente h on (h.empresa = a.empresa and h.numcte = a.numcte) "    
				|| " left outer join bdinteg:si_telefonos b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 1) "
				|| " left outer join bdinteg:si_telefonos d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 2) "
				|| " join bdicred:sd_maecredanexocrd e on (e.empresa= a.empresa and e.num_credito = a.num_credito) "
				|| " where a.empresa = '001' "
				|| " and a.tipo_cobranza = 'E' "
                || " and a.status_cliente = '" || cValor_status || "'"  -- IN ('EX','IN') "
                || " and a.fecha_modificacion = '" || pFecha_ex || "'"
				|| " and a.fecha_insert = '" || Vfecha_insert || "'"
				|| " and a.num_producto = '6300' "
				|| " and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> '')) ";
						
        LET cSql3 = ' " > '|| TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql';
            
        LET cSql1 = TRIM(cSql1);
        LET cSql3 = TRIM(cSql3);
            
        LET cSql = cSql1 || cSql2 || cSql3;
			
		SYSTEM cSQL;
		--Permiso para la creacion de archivo.
		LET cSQL = '' ;
		LET cSQL = 'chmod 666 ' || TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql' ;
		LET cSQL = '' ;
		LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql';
		SYSTEM cSQL;
			
		LET cSql = "sed 's/"||cdelimitador||"$//g' "|| TRIM(cRuta) || cNombreArchivo1 || " >> " || TRIM(cRuta) || cNombreArchivo;
        SYSTEM cSql;

		--Borra el archivo de control.
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql';
		SYSTEM cSQL;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || cNombreArchivo1;
		SYSTEM cSQL;
		
    END FOREACH;

    -- Por si el archivo no  se genera 
    IF iDatos = 0 THEN
        LET cCodRet = '104009';
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensajeRet,"03")
             INTO cCodRetIB;

    RETURN cCodRet;

END
END PROCEDURE;