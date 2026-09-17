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