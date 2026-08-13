CREATE PROCEDURE "informix".sp_consulta_cat_estados(pNombre CHAR(30))
RETURNING 	CHAR(6)   AS CodRetorno,
			CHAR(2)  AS NumEdo,
			CHAR(30)	AS NomEdo;

--Declaración de variables
DEFINE isqlerr      	INTEGER;
DEFINE cCodRet     		CHAR(6); 
DEFINE cNumEstado		  CHAR(2);
DEFINE cNombreEdo		  CHAR(30);
DEFINE iRegistro		  INTEGER; 

--Asinación de valores
LET isqlerr     		= 0;
LET cCodRet     		= '000000';
LET cNumEstado			= '';
LET cNombreEdo			= '';
LET iRegistro			  = 0;

--SET DEBUG FILE TO '/tmp/sp_consulta_cat_estados.out';
--TRACE ON;

BEGIN
--Control de errores
	ON EXCEPTION SET iSqlErr
	      LET cCodRet= iSqlErr;
	      RETURN cCodRet, cNumEstado, cNombreEdo;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;	
	
	IF pNombre = '' OR pNombre IS NULL THEN
	
		--Consulta TODOS LOS ESTADOS
		FOREACH 			
			
			SELECT estado, TRIM(nombre)
			INTO cNumEstado, cNombreEdo
			FROM bdinteg:"informix".si_estados
			ORDER BY estado
			
			RETURN cCodRet, cNumEstado, cNombreEdo WITH RESUME;
			
		END FOREACH
		LET iRegistro = dbinfo("sqlca.sqlerrd2");		
		
	ELSE
		--Consulta POR NOMBRE DE ESTADOS
		FOREACH
		
			SELECT estado, TRIM(nombre)
			INTO cNumEstado, cNombreEdo
			FROM bdinteg:"informix".si_estados
			WHERE  UPPER(TRIM(nombre)) LIKE CASE when pNombre = '' THEN UPPER(nombre) 
						ELSE '%'||UPPER(TRIM(pNombre))||'%' END   
			ORDER BY estado
						
			RETURN cCodRet, cNumEstado, cNombreEdo WITH RESUME;
			
		END FOREACH
		
		LET iRegistro = dbinfo("sqlca.sqlerrd2");				
	END IF		
	
	--Valida si se encontro información
	IF iRegistro = 0 THEN
		LET cCodRet = '000002'; --No hay información 
		RETURN cCodRet, cNumEstado, cNombreEdo;
	END IF;	
	
END;

END PROCEDURE
DOCUMENT
'Descripcion:  Consulta los estados del catalogo de estados',
'AUTOR :Abigail Vasavilbazo Cañedo',
'FECHA :Agosto/2011',
'BD    : BDINTEG',
'Version: 20110826.0959';

CREATE PROCEDURE "informix".sp_consulta_cat_zonas(pEstado CHAR(2), pCiudad CHAR(3), pNombre CHAR(32))
RETURNING 	CHAR(6)  AS CodRetorno,
			      INTEGER  AS NumZona,
			      CHAR(32) AS NomZona,
			      CHAR(5)	 AS CP;

--Declaración de variables
DEFINE isqlerr      	INTEGER;
DEFINE cCodRet     		CHAR(6); 
DEFINE iNumColonia		INTEGER;
DEFINE cNombreCol		  CHAR(32);
DEFINE cCP				    CHAR(5);
DEFINE iCiudadCoppel 	INTEGER; 
DEFINE iRegistro		  INTEGER; 

--Asinación de valores
LET isqlerr     		= 0;
LET cCodRet     		= '000000';
LET iNumColonia			= 0;
LET cNombreCol			= '';
LET cCP					    = '';
LET iCiudadCoppel		= 0;
LET iRegistro			  = 0;

--SET DEBUG FILE TO '/tmp/sp_consulta_cat_zonas.out';
--TRACE ON;

BEGIN
--Control de errores
	ON EXCEPTION SET iSqlErr
	      LET cCodRet= iSqlErr;
	      RETURN cCodRet, iNumColonia, cNombreCol, cCP;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;	
	
	
	IF pEstado IS NULL OR pEstado= '' OR pCiudad IS NULL OR pCiudad= '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet, iNumColonia, cNombreCol, cCP;
	END IF 		
	
	SELECT ciudad_coppel
	INTO iCiudadCoppel
	FROM bdinteg:"informix".si_ciudades
	WHERE estado=pEstado
	AND ciudad= pCiudad;	
	
	IF pNombre = '' OR pNombre IS NULL THEN
	
		--Consulta Colonias x Estado Y Ciudad
		FOREACH 			
			
			SELECT numerocolonia, TRIM(nombrezona), codigopostalzona
			INTO iNumColonia, cNombreCol, cCP
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad= iCiudadCoppel
			ORDER BY nombrezona
			
			RETURN cCodRet, iNumColonia, cNombreCol, cCP WITH RESUME;
			
		END FOREACH
		LET iRegistro = dbinfo("sqlca.sqlerrd2");		
		
	ELSE
		--Consulta Colonias x Estado Y Ciudad y Nombre
		FOREACH
		
			SELECT numerocolonia, TRIM(nombrezona), codigopostalzona
			INTO iNumColonia, cNombreCol, cCP
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad= iCiudadCoppel
			AND UPPER(TRIM(nombrezona)) LIKE CASE when pNombre = '' THEN UPPER(nombrezona)   ELSE '%'||UPPER(TRIM(pNombre))||'%' END   
			ORDER BY nombrezona
			
			RETURN cCodRet, iNumColonia, cNombreCol, cCP WITH RESUME;
			
		END FOREACH
		
		LET iRegistro = dbinfo("sqlca.sqlerrd2");				
	END IF		
	
	--Valida si se encontro información
	IF iRegistro = 0 THEN
		LET cCodRet = '000002'; --No hay información 
		RETURN cCodRet, iNumColonia, cNombreCol, cCP;
	END IF;	
	
END;

END PROCEDURE
DOCUMENT
'Descripcion:  Consulta las colonias por estado/ciudad',
'AUTOR :Abigail Vasavilbazo Cañedo',
'FECHA :Agosto/2011',
'BD    : BDINTEG',
'Version: 20110826.0959';

CREATE PROCEDURE "informix".sp_mail_enviavencidos(pempresa CHAR(3))
RETURNING CHAR(6);
--   execute PROCEDURE bdinteg:"informix".sp_mail_enviavencidos('001')

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE vempresa				CHAR(3);
DEFINE vproceso				CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnumcte              CHAR(20);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(2004);
DEFINE cSQL4                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE vdia				    DATE;
DEFINE vhora				CHAR(8);
DEFINE ctipocampania        CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE vnumparametro        SMALLINT;
define cfor smallint;
define i integer;
define contar smallint;

    -- SET DEBUG FILE TO "/home/informix/Elizabeth/enviomail.out";
    --TRACE ON; 

--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '2033';
LET vempresa				= '001';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnumcte                 = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL4                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET vdia				    = DATE(1);
LET vhora				    = "";
LET ctipocampania           = "";
LET cCod_RetIB              = "000000";
let contar = 0;


BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02');
        RETURN cCod_ret;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01');
	
	-- Validacion de parámetros de entrada  
	IF NVL(pEmpresa,"") = "" THEN
        LET cCod_Ret= "104001";
        SELECT descripcion
        INTO cMensaje
        FROM bdicobranza:"informix".cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret; 
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;

	
	IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM bdicobranza:cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01');
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
        FROM bdicobranza:cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
	execute PROCEDURE bdicobranza:"informix".sp_mail_cte_mora() into cCod_ret;
	
	FOR cfor IN (1 TO 5)
	
	select count(*) into contar from bdicobranza:cb_mail_cliente where tipo_mensaje = 1 and pagos_vencidos = cfor;
	if (contar <= 1000) then
		LET contar = 1;
	else
		LET contar = contar / 1000;
		let contar = (substr(contar, 0,1))+1;
	end if;
	
	FOR i in (1 to contar)
		
    LET cSQL1 = "echo '#!/bin/sh  \n" ;
	LET cSQL2 = "(sleep 1 \n" ||
                'echo "ehlo msgbancoppel.com" \n' ||
                "sleep 1 \n"||
                'echo "mail from:<cobranzabancoppel@msgbancoppel.com>" \n'||
                "sleep 1 \n"	||
                "while read line  \n"||
			    "do  \n"	||
			    'echo  " $line" \n' ||
			    "done < correos_mora"||cfor||i||".txt \n"||
                "sleep 1 \n"	||
                'echo "data" \n'||
                "sleep 1 \n" ||
                'echo "subject:Aviso Bancoppel" \n'||
				"sleep 1 \n"||
				"while read line \n"||
				"do \n"||
				'echo  "$line" \n'||
				"done < mora"||cfor||".txt \n"||
				"sleep 1 \n"|| 
                'echo "." \n'||
                "sleep 1 \n"|| 
                'echo "QUIT" \n'||
                ')|telnet 10.36.176.16 25 \n';
				
    
	LET cSQL3 = "'>"||TRIM(cRuta)||'Ejecuta_Shell'||cfor||i||'.sh';
	LET cSQL = trim(cSQL1) || trim(cSQL2) || trim(cSQL3);
  --insert into cb_bitacora (mensaje ) values ( cSQL);
	System cSQL;

    LET cSQL='chmod +x Ejecuta_Shell'||cfor||i||'.sh'; 
	System cSQL;
    let cSQL = './Ejecuta_Shell'||cfor||i||'.sh';
	System cSQL;
	
	--BORRA ARCHIVOS CORREOS_MORA  Y ARCHIVOS SHELL
	LET cSQL = '';
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_Shell'||cfor||i||'.sh';
	SYSTEM cSQL;
		
	LET cSQL = '';
	LET cSQL = 'rm ' || TRIM(cruta) || 'correos_mora'||cfor||i||'.txt';
	SYSTEM cSQL; 
	
	end for;
	
	END FOR;
	
	CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03');
	RETURN cCod_ret;
	
END;
END PROCEDURE;