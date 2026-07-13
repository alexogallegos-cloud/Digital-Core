CREATE PROCEDURE "informix".sp_upd_emp_gc2()
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


DEFINE vcomienza        smallint;
DEFINE ven_transacc     smallint;
DEFINE iCont            INT;
DEFINE cEjecutivo 		CHAR(8);
DEFINE cNumcte2			CHAR(20);
DEFINE cNumeric2		INTEGER;

--inicializando variables
LET cCodRet = "00000";
LET iSql_err = 0 ;
LET cTicket = "" ;
LET cEmpleado = "" ;
LET cEmpresa = "" ;
LET cNumcte="";
LET cParam = "" ;
LET cCmd2 	 = '';


LET vcomienza   =-1;
LET ven_transacc  = 0;
LET iCont       = 0;
LET cEjecutivo = '';
LET cNumcte2 = '';
LET cNumeric2 = 0;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/LIP/sp_upd_emp_gc2.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	TRUNCATE "informix".si_ctepf_paso;
	TRUNCATE "informix".si_ejecut_paso;
	
	LET iCont = 0;
	FOREACH WITH HOLD
		SELECT {+INDEX (si_ejecut idx_si_ejecut)} ejecutivo INTO cEjecutivo FROM si_ejecut WHERE password NOT IN ('BAJA','baja') AND ejecutivo LIKE('9%')
	
		IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
	
		LET iCont=iCont+1;
		
		INSERT INTO "informix".si_ejecut_paso(numcte)
		VALUES(cEjecutivo);
	
		IF iCont >= 500 THEN
			LET iCont = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
	END FOREACH;
	
	
	LET iCont = 0;
	FOREACH WITH HOLD
		SELECT {+INDEX (si_ctepf idx_si_ctepf_numeric2)} numcte,numeric2 INTO cNumcte2,cNumeric2 FROM si_ctepf WHERE numeric2 IS NOT NULL
		AND numeric2 IN (SELECT {+INDEX (si_ejecut_paso idx_numcte_ejecut_paso)} numcte FROM si_ejecut_paso)
		AND numcte NOT IN (SELECT {+INDEX (si_empleado_cliente_coppel idx_cte_emp2)} numcte FROM si_empleado_cliente_coppel)

	
		LET iCont=iCont+1;
	
		INSERT INTO "informix".si_ctepf_paso(numcte, numeric2)
		VALUES(cNumcte2,cNumeric2);
	
		IF iCont >= 500 THEN
			LET iCont = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
	END FOREACH;
	
	--DELETE {+INDEX (si_ctepf_paso idx_numeric2_ctepf_paso)} FROM "informix".si_ctepf_paso WHERE numeric2 
	--NOT IN (SELECT {+INDEX (si_ejecut_paso idx_numcte_ejecut_paso)} numcte FROM si_ejecut_paso);
	
	--DELETE FROM "informix".si_ctepf_paso WHERE numcte 
	--IN (SELECT {+INDEX (si_empleado_cliente_coppel idx_cte_emp2)} numcte FROM si_empleado_cliente_coppel);

    SELECT valor INTO cParam
	FROM "informix".si_param
	WHERE cod_param = 308;
	
	
	LET iCont = 0;
	FOREACH WITH HOLD
		SELECT {+INDEX (bdicheq:sc_maechq mae1)} DISTINCT num_cte INTO cNumcte FROM bdicheq:sc_maechq a, bdicheq:sc_maenoc b
		WHERE a.cuenta=b.cuenta and a.num_cte in (SELECT {+INDEX (si_ctepf_paso idx_numcte_ctepf_paso)} numcte FROM si_ctepf_paso) and producto='1300' and status_cta in(1,3)
		and b.fecha_alta >= cParam

		LET iCont=iCont+1;
		
		SELECT {+INDEX (si_ctepf 225_483)} numeric2::CHAR(10) AS empleado,numeric1::CHAR(4) as empresa INTO cEmpleado,cEmpresa FROM si_ctepf WHERE numcte=cNumcte;

		INSERT INTO "informix".si_empleado_cliente_coppel (numcte,empleado,cve_proceso,empresa,fecha,hora,status)
		VALUES (cNumcte,cEmpleado,2,cEmpresa,current year to fraction(3),current year to fraction(3),1);
		
		IF iCont >= 500 THEN
			LET iCont = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
	END FOREACH;

	
	IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
     END IF;
	
	RETURN cCodRet;
END
END PROCEDURE;