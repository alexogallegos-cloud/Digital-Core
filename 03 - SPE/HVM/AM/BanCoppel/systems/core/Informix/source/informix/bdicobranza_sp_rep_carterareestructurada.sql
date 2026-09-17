CREATE PROCEDURE "informix".sp_rep_carterareestructurada(pfechacorte date)


RETURNING CHAR(6);
--Creado por: maria elizabeth anzures ibarguen
--5-07-2011
--Proceso para la generación de archivo cartera reestructurada

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE  vproceso			CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte              CHAR(20);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
define pdia date;
	define pfechaact date;
	define pfechaant date;
	define pfechaarmada date;


--SET DEBUG FILE TO "/home/informix/ALL/CARTERACAT.out";
--TRACE ON; 

--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso	            = '2032';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre		    = "";
LET cnomarchivo             = "";
LET cnomarchivo1            = "";
LET cnumcte                 = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET cCod_RetIB              = "000000";

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02');
        RETURN cCod_ret;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
--SET DEBUG FILE TO "/home/informix/Elizabeth/catreestructu.out";
--TRACE ON;
    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
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

        CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
	--Obtener ruta del archivo
	SELECT TRIM(valor_alfabetico)
	INTO cruta
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
    	--WHERE empresa = '001'
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 34;
	
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

        CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
	--Obtener el nombre del archivo
	SELECT TRIM(valor_alfabetico)
	INTO cnombre
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 33;
	
	--select limit 1 dia_corte into pdia from bdicred:sd_maecredanexo where empresa ='001';
   	--let pfechaarmada = mdy(month(pfechacorte),day(pdia),year(pfechacorte)); --20
	
	let pfechaant = date(pfechacorte)  - 1 units month ;
	let pfechaact = date(pfechacorte); 
	
	--Validar que existe el archivo
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.csv';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.csv';
	
		
	 
	let cSql='';
	let csql = 'echo "Tipo_de_Producto'||','||'Num_Cliente'||','||'Meses_Vencido'||','||'Monto_a_Reestructurar'||','||'Fecha_Contrato'||','||
				 '# Pagos_Plazo'||','||'Días_de_Pago'||','||'Mora_RST'||','||'Fecha_ult_Pago'||','||'Monto_ult_Pago'||','||
'Región_de_Cobranza'||' " >' ||TRIM(cruta)|| cnomarchivo;  ---se ejecuta para ponerle el encabezado 
	system csql;
	
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
   
    
  	
	LET cSQL2 = " SELECT  b.num_producto,b.numcte, d.mto_fin_ven_trasp::integer Pago_Ven_Actual  ,d.monto_otorgado, b.fecha_apertura, b.plazo,"
    || "  (case when day(b.fecha_apertura) between 3 and 16 then 2 when day(b.fecha_apertura) >=17  then 17 when day(b.fecha_apertura) <= 2  then 17 end)dias_pago"
    || "  ,a.mto_fin_ven_trasp::integer Pago_ven_TC ,ca.fecha_ult_pago ,( select sum(h.monto) Monto"
    || "  	from bdicred:sd_movhiscrd h"
    || " where h.empresa = '001'"
    || " and h.fecha_mov = ca.fecha_ult_pago  "
    || " and h.num_credito = b.num_credito"
    || " and h.codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanualcrd)"
    || " and h.codigo_ref = 1 and h.reversado = 'N' ) capital_pagado,   re.nombre_region"
    || " from  bdicred:sd_maecredcrd b,bdicred:sd_maesdoscrd d,"
    || "        bdicred:sd_maesdos a ,bdicred:sd_maecredanexocrd ca"
    || "        ,bdinteg:si_direcciones_actual f"
    || "        ,bdinteg:si_catciudades ci, bdinteg:si_regiones re"
    || " where b.empresa = d.empresa"
    || "       and b.num_credito = d.num_credito "
    || "       and a.empresa= b.empresa"
    || "       and a.num_credito = b.credito_externo"
    || "       and ca.empresa = b.empresa"
    || "       and ca.num_credito = b.num_credito"
    || "       and f.numcte= b.numcte"
    || "       and f.tipo_dir = 1"
    || "       and f.numerociudad = ci.numerociudad"
    || "       and re.numero_region = ci.numero_region"
    || "       and b.num_producto = '6011'"
    || "       and b.fecha_apertura > '" || pfechaant || "' and b.fecha_apertura <= '" || pfechaact|| "' ";
  
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_CarteraReestruccturada.sql';

    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_CarteraReestruccturada.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_CarteraReestruccturada.sql';
    System cSQL;
--/*
    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
--*/
	
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_CarteraReestruccturada.sql';
	SYSTEM cSQL;
--/*
    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;   
--*/
	CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03');

	RETURN cCod_ret;

	
	
END;
END PROCEDURE;