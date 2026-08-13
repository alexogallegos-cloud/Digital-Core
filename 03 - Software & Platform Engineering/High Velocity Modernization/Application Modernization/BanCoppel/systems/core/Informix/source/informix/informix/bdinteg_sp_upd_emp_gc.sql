CREATE PROCEDURE "informix".sp_upd_emp_gc()
				returning CHAR(5) AS Cod_Retorno;


DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cTicket			CHAR(20);
DEFINE cEmpleado		CHAR(10);
DEFINE cEmpresa			CHAR(4);
DEFINE cNumcte			CHAR(20);
DEFINE cParam			CHAR(50);
DEFINE cCmd2 			CHAR(500);

--inicializando variables
LET cCodRet = "00000";
LET iSql_err = 0 ;
LET cTicket = "" ;
LET cEmpleado = "" ;
LET cEmpresa = "" ;
LET cNumcte="";
LET cParam = "" ;
LET cCmd2 	 = '';



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

	DELETE FROM "informix".si_empleado_cliente_coppel WHERE empleado in (SELECT {+INDEX (si_ejecut idx_si_ejecut)} ejecutivo FROM bdinteg:si_ejecut WHERE password IN ('BAJA','baja'));
	
	FOREACH
		SELECT {+INDEX (bdinteg:si_huella_linea idx_huellaline4)} NVL(numcte,''), ticket INTO cNumcte, cTicket FROM si_huella_linea WHERE ticket IN
		(SELECT {+INDEX (bdinteg:si_huella_linea_resultado idx_huellalinea_res_mensaje)} DISTINCT ticket FROM si_huella_linea_resultado
		WHERE num_mensaje=602 and empresa NOT IN (4,5) AND (ticket<>0 AND cliente<>0))
		AND numcte NOT IN (SELECT {+INDEX (bdinteg:si_empleado_cliente_coppel idx_cte_emp2)} numcte FROM bdinteg:si_empleado_cliente_coppel)
		AND fecha_consulta >= cParam

		SELECT {+INDEX (bdinteg:si_huella_linea_resultado idx_huellalinea_res_mensaje)} FIRST 1 cliente AS empleado,empresa INTO cEmpleado,cEmpresa
		FROM si_huella_linea_resultado
		WHERE num_mensaje=602 and empresa NOT IN (4,5) AND (ticket = cTicket AND cliente<>0);

		INSERT INTO "informix".si_empleado_cliente_coppel (numcte,empleado,cve_proceso,empresa,fecha,hora,status)
		VALUES (cNumcte,cEmpleado,1,cEmpresa,current year to fraction(3),current year to fraction(3),1);
	END FOREACH;
				

	RETURN cCodRet;
END
END PROCEDURE;