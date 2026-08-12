CREATE PROCEDURE "informix".sp_upd_emp_gc3()
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
DEFINE iCampos			INT;

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
LET iCampos=7;


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
		
	LET cCmd1 = "/usr/bin/echo '" || "SET ISOLATION TO DIRTY READ; UNLOAD TO '"|| TRIM(cRuta) ||"tmp_funciones.unl' "||" SELECT {+AVOID_FULL(si_funciones )}emp, nombre FROM si_funciones;" ||
	"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	SYSTEM TRIM(cCmd1);

	LET cCmd1 = 'SELECT {+AVOID_FULL(si_cliente)} cte.numcte, TRIM(TRIM(cte.apell_paterno) ||" "|| TRIM(cte.apell_materno) ||" "|| TRIM(cte.nombre1) ||" "|| TRIM(cte.nombre2)) FROM si_cliente AS cte';
	LET cCmd1 = TRIM(cCmd1)|| ' WHERE cte.tpo_persona = "01" AND cte.tipo_cliente = 1 AND cte.fecha_alta >= "'||TRIM(cParam)||'"';
	LET cCmd1 = TRIM(cCmd1)|| ' AND NOT EXISTS (SELECT 1 FROM si_empleado_cliente_coppel AS ecc WHERE ecc.numcte=cte.numcte);';

	LET cCmd2 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; UNLOAD TO '"||TRIM(cRuta)||"tmp_clientes.unl' "
	||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	SYSTEM TRIM(cCmd2);
	
	LET cCmd1 = "/usr/bin/awk -v "||TRIM(dFecha)||" -v "||TRIM(dHora)||" -v OFS='|' -F '|' 'NR==FNR{a[$2]=$1;next } $2 in a {print $1,a[$2],'3','0',date,hora,'1'}";
	LET cCmd2 = "' "||TRIM(cRuta)||"tmp_funciones.unl "||TRIM(cRuta)||"tmp_clientes.unl > "||TRIM(cRuta)||"tmp_compara.unl";
	SYSTEM TRIM(cCmd1)||TRIM(cCmd2);


	--Arma cargardatos_si_empleado_cliente_coppel.sh.sh
	LET cCmd1 = 'echo "FILE ' ||''''||TRIM(cRuta)||'tmp_compara.unl'||''''||' DELIMITER '||'''|'' '||iCampos ||';" > '||TRIM(cRuta)||'cargardatos_si_empleado_cliente_coppel.sh';
	SYSTEM cCmd1;
	LET cCmd1 = 'echo "INSERT INTO '||'''informix''.si_empleado_cliente_coppel;" >> '||TRIM(cRuta)||'cargardatos_si_empleado_cliente_coppel.sh';
	SYSTEM cCmd1;
	LET cCmd1 = 'chmod 755 '||TRIM(cRuta)||'cargardatos_si_empleado_cliente_coppel.sh';
	SYSTEM cCmd1;

	--Arma dbload_si_empleado_cliente_coppel.sh
	LET cCmd1 ='echo "nice -n -30 dbload -d bdinteg -c '||TRIM(cRuta)||'cargardatos_si_empleado_cliente_coppel.sh -n 5000 -l '||TRIM(cRuta)||'dbload_si_empleado_cliente_coppel.log" > '||TRIM(cRuta)||'dbload_si_empleado_cliente_coppel.sh';
	SYSTEM TRIM(cCmd1);
	
	LET cCmd1 = 'chmod 755 '||TRIM(cRuta)||'dbload_si_empleado_cliente_coppel.sh';
	SYSTEM cCmd1;
	
	--ejecuta dbload_si_empleado_cliente_coppel.sh
	LET cCmd1 = TRIM(cRuta)||'dbload_si_empleado_cliente_coppel.sh > dbload_si_empleado_cliente_coppel.log';
	SYSTEM cCmd1;
	
	
	SYSTEM '/usr/bin/rm -rf '||TRIM(cRuta)||'tmp_funciones.unl ' ||TRIM(cRuta)||'tmp_clientes.unl ' ||TRIM(cRuta)||'tmp_compara.unl';
				
	UPDATE si_param set valor = TODAY WHERE cod_param = 308;

	RETURN cCodRet;
END
END PROCEDURE;