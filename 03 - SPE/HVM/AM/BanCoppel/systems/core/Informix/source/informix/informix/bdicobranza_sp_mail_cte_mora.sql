CREATE PROCEDURE "informix".sp_mail_cte_mora()
--  execute PROCEDURE bdicobranza:"informix".sp_mail_cte_mora();

RETURNING CHAR(6);


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
define i integer;
define x integer;
define num smallint;
define contar smallint;



--SET DEBUG FILE TO "/informix/Elizabeth/prestamo.out";
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
LET num = 0;
LET contar = 0;

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
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 38;	
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
	
	let cnombre = 'correos_mora';
	FOR i in (1 to 5)
	
	LET num = 0;
	select count(*) into contar from bdicobranza:cb_mail_cliente  where tipo_mensaje = 1  and pagos_vencidos = i;
	if (contar <= 1000) then
		LET contar = 1;
	else
		LET contar = contar / 1000;
		let contar = (substr(contar, 0,1))+1;
	end if;
	
	
	for x in (1 to contar )
	
	--Validar que existe el archivo
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||'.txt';
    LET cnomarchivo =  trim(cnombre)||i||x||'.txt';
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
   
	
		LET cSQL2 = " SELECT skip "||num||" LIMIT 1000 trim('rcpt to:<')||trim(email)||trim('>')"
		||  " from bdicobranza:cb_mail_cliente"
		|| " where tipo_mensaje = 1 "
		|| " and pagos_vencidos =  '"||i||"'"
		|| " order by numcte ";
	   
		let num = num + 1000;
   
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_archivo.sql';

    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_archivo.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_archivo.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_archivo.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;  
	
	end for
	END FOR

	CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03');
	RETURN cCod_ret;
	
END;
END PROCEDURE;