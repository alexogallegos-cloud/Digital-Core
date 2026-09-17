CREATE PROCEDURE "informix".sp_genera_emp_gc()
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

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	  --SET DEBUG FILE TO "/informix/VH/huella/sp_genera_emp_gc.out";
	  --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
		SELECT {+INDEX (bdinteg:si_huella_linea_resultado idx_huellalinea_res_mensaje)} DISTINCT ticket,cliente AS empleado,empresa INTO cTicket,cEmpleado,cEmpresa FROM si_huella_linea_resultado 
		WHERE num_mensaje=602 and empresa NOT IN (4,5) AND (ticket<>0 AND cliente<>0)

		SELECT {+INDEX (bdinteg:si_huella_linea idx_huellaline4)} FIRST 1 NVL(numcte,'') INTO cNumcte FROM si_huella_linea WHERE ticket=cTicket;

		INSERT INTO "informix".si_empleado_cliente_coppel (numcte,empleado,cve_proceso,empresa,fecha,hora,status) 
		VALUES (cNumcte,cEmpleado,1,cEmpresa,current year to fraction(3),current year to fraction(3),1);

	END FOREACH;

	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT {+INDEX (bdicheq:sc_maechq mae1)} DISTINCT num_cte INTO cNumcte FROM bdicheq:sc_maechq
		WHERE num_cte in (SELECT {+INDEX (bdinteg:si_ctepf 225_483)} DISTINCT numcte FROM bdinteg:si_ctepf	WHERE numeric2::CHAR(8) IN (
		SELECT ejecutivo FROM bdinteg:si_ejecut WHERE password NOT IN ('BAJA','baja'))) and producto='1300' and status_cta in(1,3)

		SELECT {+INDEX (bdinteg:si_ctepf 225_483)} FIRST 1 numeric2::CHAR(8) AS empleado,numeric1::CHAR(4) as empresa INTO cEmpleado,cEmpresa FROM si_ctepf WHERE numcte=cNumcte;

		SELECT {+INDEX (bdinteg:si_empleado_cliente_coppel idx_cte_emp2)} FIRST 1 numcte INTO cNumcte2 FROM bdinteg:si_empleado_cliente_coppel WHERE numcte=cNumcte AND empleado=cEmpleado;
		LET iexiste = dbinfo("sqlca.sqlerrd2");
		IF iexiste=0 THEN
			INSERT INTO "informix".si_empleado_cliente_coppel (numcte,empleado,cve_proceso,empresa,fecha,hora,status) 
			VALUES (cNumcte,cEmpleado,2,cEmpresa,current year to fraction(3),current year to fraction(3),1);
		END IF;
	END FOREACH;

	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT num_cte INTO cNumcte FROM bdicheq:sc_maechq WHERE producto='1300' AND status_cta IN(1,3) 
		AND num_cte NOT IN (SELECT {+INDEX (bdinteg:si_empleado_cliente_coppel idx_cte_emp2)} numcte FROM bdinteg:si_empleado_cliente_coppel WHERE cve_proceso=2)

		SELECT {+INDEX (bdinteg:si_empleado_cliente_coppel idx_cte_emp2)} FIRST 1 numcte INTO cNumcte2 FROM bdinteg:si_empleado_cliente_coppel WHERE numcte=cNumcte;
		LET iexiste = dbinfo("sqlca.sqlerrd2");
		IF iexiste=0 THEN
			INSERT INTO "informix".si_empleado_cliente_coppel (numcte,empleado,cve_proceso,empresa,fecha,hora,status) 
			VALUES (cNumcte,NULL,2,null,current year to fraction(3),current year to fraction(3),1);
		END IF;
	END FOREACH;

	SET ISOLATION TO DIRTY READ;
	FOREACH

		SELECT numcte INTO cNumcte FROM si_empleado_cliente_coppel WHERE cve_proceso=2 AND empleado IS NULL

		SELECT FIRST 1 emp INTO cEmpleado FROM si_funciones WHERE emp IN (SELECT {+INDEX (bdinteg:si_ctepf 225_483)} numeric2::char(8) FROM si_ctepf
		WHERE numcte IN (SELECT numcte FROM si_empleado_cliente_coppel WHERE cve_proceso=2 AND empleado IS NULL AND numcte=cNumcte ));

		UPDATE si_empleado_cliente_coppel SET empleado=cEmpleado WHERE numcte=cNumcte AND empleado IS NULL;
	END FOREACH;

/*
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT {+INDEX (bdinteg:si_funciones idx_si_funciones3)} emp,nombre,fnac INTO cEmpleado,cNombreEm,cFnac FROM si_funciones WHERE fnac IS NOT NULL

		FOREACH
			SELECT  {+INDEX (bdinteg:si_cliente idx_si_cliente5)} TRIM(a.nombre1),NVL(TRIM(a.nombre2),''),TRIM(a.apell_paterno),TRIM(a.apell_materno),b.fecha_nac,a.numcte 
			INTO cNombre1,cNombre2,cPaterno,cMaterno,cFnac,cNumcte FROM si_cliente a,si_ctepf b WHERE a.empresa IS NOT NULL AND a.numcte=b.numcte AND a.tipo_cliente=1 AND a.tpo_persona='01' AND b.fecha_nac=cFnac

			IF cNombre2<>'' THEN
				LET cNombreEm2=trim(cPaterno)||" "||trim(cMaterno)||" "||trim(cNombre1)||" "||trim(cNombre2);
				--SELECT {+INDEX (bdinteg:si_funciones idx_si_funciones)} FIRST 1 emp INTO cEmpleado FROM si_funciones WHERE TRIM(nombre)=cNombreEm AND fnac=cFnac;
			ELSE
				LET cNombreEm2=trim(cPaterno)||" "||trim(cMaterno)||" "||trim(cNombre1);
				--SELECT {+INDEX (bdinteg:si_funciones idx_si_funciones)} FIRST 1 emp INTO cEmpleado FROM si_funciones WHERE TRIM(nombre)=cNombreEm AND fnac=cFnac;
			END IF;
			IF TRIM(cNombreEm)=TRIM(cNombreEm2) THEN
				LET iexiste=1;
			ELSE
				LET iexiste=0;	
			END IF;

			--LET iexiste = dbinfo("sqlca.sqlerrd2");
			IF iexiste>0 THEN
				SELECT {+INDEX (bdinteg:si_empleado_cliente_coppel idx_cte_emp2)} numcte INTO cNumcte2 FROM bdinteg:si_empleado_cliente_coppel WHERE numcte=cNumcte AND empleado=cEmpleado;
				LET iexiste = dbinfo("sqlca.sqlerrd2");
					IF iexiste=0 THEN
						INSERT INTO "informix".si_empleado_cliente_coppel (numcte,empleado,cve_proceso,empresa,fecha,hora,status) 
						VALUES (cNumcte,cEmpleado,3,null,current year to fraction(3),current year to fraction(3),1);
					END IF;	
			END IF;
		END FOREACH;	

	END FOREACH;

	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT  {+INDEX (bdinteg:si_cliente idx_si_cliente5)} TRIM(a.nombre1),NVL(TRIM(a.nombre2),''),TRIM(a.apell_paterno),TRIM(a.apell_materno),b.fecha_nac,a.numcte 
		INTO cNombre1,cNombre2,cPaterno,cMaterno,cFnac,cNumcte FROM si_cliente a,si_ctepf b WHERE a.empresa IS NOT NULL AND a.numcte=b.numcte AND a.tipo_cliente=1 AND a.tpo_persona='01'

		IF cNombre2<>'' THEN
			LET cNombreEm=trim(cPaterno)||" "||trim(cMaterno)||" "||trim(cNombre1)||" "||trim(cNombre2);
			SELECT {+INDEX (bdinteg:si_funciones idx_si_funciones)} FIRST 1 emp INTO cEmpleado FROM si_funciones WHERE TRIM(nombre)=cNombreEm AND fnac=cFnac;
		ELSE
			LET cNombreEm=trim(cPaterno)||" "||trim(cMaterno)||" "||trim(cNombre1);
			SELECT {+INDEX (bdinteg:si_funciones idx_si_funciones)} FIRST 1 emp INTO cEmpleado FROM si_funciones WHERE TRIM(nombre)=cNombreEm AND fnac=cFnac;
		END IF;
		
		LET iexiste = dbinfo("sqlca.sqlerrd2");
		IF iexiste>0 THEN
			SELECT {+INDEX (bdinteg:si_empleado_cliente_coppel idx_cte_emp2)} numcte INTO cNumcte2 FROM bdinteg:si_empleado_cliente_coppel WHERE numcte=cNumcte AND empleado=cEmpleado;
			LET iexiste = dbinfo("sqlca.sqlerrd2");
				IF iexiste=0 THEN
					INSERT INTO "informix".si_empleado_cliente_coppel (numcte,empleado,cve_proceso,empresa,fecha,hora,status) 
					VALUES (cNumcte,cEmpleado,3,null,current year to fraction(3),current year to fraction(3),1);
				END IF;	
		END IF;
	END FOREACH;
*/

	RETURN cCodRet;
END
END PROCEDURE;