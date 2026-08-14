CREATE PROCEDURE "informix".sp_upd_emp_gc_2()
				returning CHAR(5) AS Cod_Retorno;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cTicket			CHAR(20);
DEFINE cEmpleado		CHAR(10);
DEFINE cEmpresa			CHAR(4);
DEFINE cNumcte			CHAR(20);
DEFINE cNumcte2			CHAR(20);
DEFINE cValidanumcte	CHAR(20);
DEFINE iNumRows			INTEGER;
DEFINE cNombreEm		CHAR(104);
DEFINE cNombreEm2		CHAR(104);
DEFINE cFnac			DATE;
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cPaterno			CHAR(26);
DEFINE cMaterno			CHAR(26);
DEFINE cFecha			DATE;
DEFINE cParam			CHAR(50);


--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;
LET cTicket = "" ;
LET cEmpleado = "" ;
LET cEmpresa = "" ;
LET cNumcte="";
LET cValidanumcte="";
LET iNumRows=0;
LET cNombreEm="";
LET cNombreEm2="";
LET cNombre1="";
LET cNombre2="";
LET cPaterno="";
LET cMaterno="";
LET cNumcte2="";
LET cParam = "" ;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/ArmandoM/sp_upd_emp_gc_2.out";
	--TRACE ON;

	SELECT valor INTO cParam
	FROM si_param
	WHERE cod_param = 308;

	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT  b.emp, a.numcte, TRIM(nombre1)|| ' ' ||TRIM(nombre2)|| ' '||TRIM(apell_paterno)|| ' ' ||TRIM(apell_materno) INTO cEmpleado,cNumcte,cNombreEm
		FROM si_funciones b, si_cliente a, si_ctepf c
		WHERE b.fnac=c.fecha_nac
		AND TRIM(b.nombre)=TRIM(apell_paterno)|| ' ' ||TRIM(apell_materno)|| ' ' ||TRIM(nombre1)|| ' ' ||TRIM(nombre2)
		AND a.numcte=c.numcte
		AND b.emp NOT IN (SELECT {+INDEX (bdinteg:si_ejecut idx_si_ejecut)} ejecutivo FROM bdinteg:si_ejecut WHERE password NOT IN ('BAJA','baja'))
		AND a.tipo_cliente = '1'
		AND a.fecha_alta >= cParam
		
		SELECT {+INDEX (bdinteg:si_empleado_cliente_coppel idx_cte_emp2)} FIRST 1 numcte INTO cNumcte2 FROM bdinteg:si_empleado_cliente_coppel WHERE numcte=cNumcte;
		LET iexiste = dbinfo("sqlca.sqlerrd2");
		IF iexiste=0 THEN
			INSERT INTO "informix".si_empleado_cliente_coppel (numcte,empleado,cve_proceso,empresa,fecha,hora,status) 
			VALUES (cNumcte,cEmpleado,3,null,current year to fraction(3),current year to fraction(3),1);
		ELSE
			UPDATE bdinteg:si_empleado_cliente_coppel SET empleado= cEmpleado WHERE numcte=cNumcte AND empleado IS NULL;
		END IF;	
	END FOREACH;
	
	UPDATE si_param set valor = TODAY WHERE cod_param = 308;
	
	RETURN cCodRet;
END
END PROCEDURE;