CREATE PROCEDURE "informix".sp_ctedigital_actualizaestatus(pNumCte CHAR(20), pConsecutivo INTEGER, pEstatus_Envio INTEGER, pDescEstatus CHAR(200))

--RETORNOS-
RETURNING
CHAR(6)     AS codret;

--DECLARACION DE VARIABLES--
DEFINE iSql_err		    INTEGER; 
DEFINE cCodret		    CHAR(6);
DEFINE iConsecutivo     INTEGER;

--INICIALIZACION DE VARIABLES--
LET iSql_err		     = 0;
LET cCodret		         = '000000';
LET iConsecutivo         = 9;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret);
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/tmp/cyrv/sp_ctedigital_actualizaestatus.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	    
	/*
	ESTATUS_ENVIO:
		pEstatus_Envio = 0 --NO SE ENVIO LA TRAMA
		pEstatus_Envio = 2 --TRAMA RECIBIDA
		pEstatus_Envio = 3 --ERROR EN ENVIO/RECEPCION DE TRAMA
		pEstatus_Envio = 4 --TRAMA RECIBIDA CON no.CTE COPPEL
	*/
	  
	IF NVL(pNumCte,'') = '' OR NVL(pEstatus_Envio,9) NOT IN (0,2,3,4) OR NVL(pConsecutivo,0) = 0 THEN
		LET cCodret = '000001'; --ERROR EN LOS PARAMETROS
		RETURN TRIM(cCodret);
	END IF;
	  
	--************************************************************************************
	---------------****************BLOQUE DE CONSULTA*************************************
	--************************************************************************************
	
	--Se quitan espacios en blanco a variable entrada
	LET pNumCte = TRIM(pNumCte);
	
	--CAMBIA EL ESTATUS AL QUE HAYA SIDO INDICADO POR EL SERVICIO
	UPDATE "informix".si_clientes_digital 
	SET estatus_envio = pEstatus_Envio, error = pDescEstatus
	WHERE  num_cte_banco = pNumCte; --consecutivo = pConsecutivo AND
	
	RETURN TRIM(cCodret);	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: PROCEDIMIENTO QUE ACTUALIZA EL ESTATUS_ENVIO DEL REGISTRO A COMO EL SERVICIO LO INDIQUE DEPENDIENDO SI HUBO EXITO O NO EN EL ENVIO DE LA TRAMA A E-COMMERCE.',
'FECHA: 15 DE NOVIEMBRE DE 2013',
'BASE DE DATOS: BDINTEG',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 20131115.1630';

CREATE PROCEDURE "informix".sp_upd_emp_gc3_exp()
				returning CHAR(5) AS Cod_Retorno;


DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cTicket			CHAR(20);
DEFINE cEmpleado		CHAR(10);
DEFINE cEmpresa			CHAR(4);
DEFINE cNumcte			CHAR(20);
DEFINE cParam			CHAR(50);
DEFINE cRuta			CHAR(100);
DEFINE cCmd1 			CHAR(500);
DEFINE cCmd2 			CHAR(500);
DEFINE dFecha			CHAR(100);
DEFINE dHora			CHAR(100);

--inicializando variables
LET cCodRet = "00000";
LET iSql_err = 0 ;
LET cTicket = "" ;
LET cEmpleado = "" ;
LET cEmpresa = "" ;
LET cNumcte="";
LET cParam = "" ;
LET cCmd1 	 = '';
LET cCmd2 	 = '';
LET cRuta	 = '/RESPALDOSNEW/procesomasivo/';
LET dFecha	 ='date="$(date +"%x")"';
LET dHora	 ='hora="$(date +"%T")"';



BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/CHVN/tmp/sp_upd_emp_gc.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT valor INTO cParam
	FROM "informix".si_param
	WHERE cod_param = 308;		

	
--COMPARACION NOMBRES
		
	LET cCmd1 = "/usr/bin/echo '" || "SET ISOLATION TO DIRTY READ; UNLOAD TO '"|| TRIM(cRuta) ||"tmp_funciones.unl' "||" SELECT emp, nombre FROM si_funciones;" ||
	"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	SYSTEM TRIM(cCmd1);

	LET cCmd1 = 'SELECT {+INDEX (si_cliente idx_si_cliente), AVOID_FULL(si_cliente)} numcte, apell_paterno ||" "|| apell_materno ||" "|| nombre1 ||" "|| nombre2 FROM si_cliente';
	LET cCmd1 = TRIM(cCmd1)|| ' WHERE tpo_persona = "01" AND tipo_cliente = 1 AND fecha_alta >= "'||TRIM(cParam)||'";';

	LET cCmd2 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; UNLOAD TO '"||TRIM(cRuta)||"tmp_clientes.unl' "
	||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	SYSTEM TRIM(cCmd2);
	
	LET cCmd1 = "/usr/bin/awk -v "||TRIM(dFecha)||" -v "||TRIM(dHora)||" -v OFS='|' -F '|' 'NR==FNR{a[$2]=$1;next } $2 in a {print $1,a[$2],'3','0',date,hora,'1'}";
	LET cCmd2 = "' "||TRIM(cRuta)||"tmp_funciones.unl "||TRIM(cRuta)||"tmp_clientes.unl > "||TRIM(cRuta)||"tmp_compara.unl";
	SYSTEM TRIM(cCmd1)||TRIM(cCmd2);

	
	LET cCmd1 = "/usr/bin/echo '" || "SET ISOLATION TO DIRTY READ; DBLOAD FROM '"|| TRIM(cRuta) ||"tmp_compara.unl' "||
	" INSERT INTO si_empleado_cliente_coppel;" || "' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1"; 
	SYSTEM TRIM(cCmd1);

	
	SYSTEM '/usr/bin/rm -rf '||TRIM(cRuta)||'tmp_funciones.unl ' ||TRIM(cRuta)||'tmp_clientes.unl ' ||TRIM(cRuta)||'tmp_compara.unl';
				
	UPDATE si_param set valor = TODAY WHERE cod_param = 308;

	RETURN cCodRet;
END
END PROCEDURE;