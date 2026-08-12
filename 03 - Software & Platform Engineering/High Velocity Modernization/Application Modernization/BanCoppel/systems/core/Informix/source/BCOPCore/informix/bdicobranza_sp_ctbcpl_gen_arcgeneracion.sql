CREATE PROCEDURE "informix".sp_ctbcpl_gen_arcgeneracion(pempresa CHAR(3), pfechacorte DATE, ptipocobranza char(1))
RETURNING CHAR(6);
--Creado por: Enrique Lizárraga
--23/12/2010
--Proceso para la generación del archivo ctbcpl_generacion_

-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R

-- Modificado por: Elizabeth Anzures
-- Fecha: Marzo 2012
-- Modificacion: Se modifica proceso para que no tome clientes con estatus en AT

-- Modificado por: Abrham López López, Marzo 2013, Se modifica proceso para que no meta null en el campo numerociudad.

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vempresa				CHAR(3);
DEFINE vproceso				CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecsq1	CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE vnumparametro        SMALLINT;
define vcount				integer;


    --SET DEBUG FILE TO "generacion.out";
    --TRACE ON; 

--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0077';
LET vempresa				= '001';
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecsq1      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET cCod_RetIB              = "000000";
let vcount					= 0;


BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
          --  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING cCod_RetIB;

        RETURN cCod_ret;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01')    RETURNING cCod_RetIB;
	
    LET vnumparametro = 13;
    IF (ptipocobranza = 'A' or ptipocobranza = 'P') then  LET vnumparametro = 13; END IF;
    IF (ptipocobranza = 'R' or ptipocobranza = 'E') then  LET vnumparametro = 15; END IF;

	-- Validacion de parámetros de entrada  
	IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = "" THEN
        LET cCod_Ret= "104001";
        SELECT descripcion INTO cMensaje
        FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret; 
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING cCod_RetIB;

        Return cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa  INTO cempresa
        FROM bdinteg:"informix".si_empresas
            WHERE empresa = pempresa; 
	
    IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
                AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02')  RETURNING cCod_RetIB;
        Return cCod_Ret;
	END IF;
	
	--Obtener caracter delimitador
    SELECT trim(valor_alfabetico) INTO cdelimitador
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 2;
	
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02')  RETURNING cCod_RetIB;

        Return cCod_Ret;
	END IF;
	
	--Obtener ruta del archivo
	SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 3;
	
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
                AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02')    RETURNING cCod_RetIB;
        Return cCod_Ret;
	END IF;
	
	--Obtener el nombre del archivo
	SELECT TRIM(valor_alfabetico) INTO cnombre
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = vnumparametro; --por parametroç
		
		let pfechacorte = date(1);		
		SELECT MAX(fecha_insert) INTO pfechacorte
		FROM bdicobranza:cb_cat_directorio_cte
		WHERE empresa = pempresa
		AND tipo_cobranza = ptipocobranza;
	
	--Validar que existe el archivo
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux_' ||  ptipocobranza || to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivoEjecsq1 =  'Ejecuta_GenArchivoGeneracion_' || ptipocobranza || '.sql';

    LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1)||'';

	LET cSQL2 = " SELECT a.tipo_cobranza, a.fecha_insert, a.numcte, "
	|| " nvl(d.numerociudad,0), decode(a.status_cliente , 'TE',3 ,104 ), a.tipo_logica ,decode(a.status_cliente , 'TE',3 ,104 ), a.empresa " 
    || " FROM bdicobranza:cb_cat_directorio_cte a,  bdinteg:si_direcciones_actual d "
    || " WHERE a.tipo_cobranza ='"||ptipocobranza|| "'"
    || " AND a.fecha_insert ='"|| pfechacorte || "'"        
    || " AND a.tipo_logica > 0 " 
	|| " AND d.numcte = a.numcte "      
    || " AND d.tipo_dir = '1' "     
    || " AND a.status_cliente not in ('NT','EX') " ;

	

	LET cSQL3 = '">'||TRIM(cRuta)||cnomarchivoEjecsq1;

    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||cnomarchivoEjecsq1;
    System cSQL;

    let cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || cnomarchivoEjecsq1;
    System cSQL;

	--A.L.L Se le dan permisos al archivo que se genera con el .sql con chmod 777
	LET cSql = '';
    LET cSql = 'chmod 777 '|| TRIM(cRuta) || TRIM(cnomarchivo1);
    SYSTEM cSql;
	
    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	--A.L.L Se le dan permisos al archivo final con el chmod 777
	LET cSql = '';
    LET cSql = 'chmod 777 '|| TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoEjecsq1;
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;   
		
	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03')   RETURNING cCod_RetIB;

	RETURN cCod_ret;
	
END;
END PROCEDURE;