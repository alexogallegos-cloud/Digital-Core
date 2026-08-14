CREATE PROCEDURE "informix".sp_consultapreasignacionhuella_web_442(cEmpresa CHAR(3), cNumCte CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR (5),  ---- Código de Retorno
	CHAR (20), ---- Número de Cliente
	SMALLINT,  ---- Secuencia
	CHAR (1),  ---- Status
	CHAR (8),  ---- User insert
	CHAR (8),  ---- Empleado
	CHAR (8),  ---- Usuario3
	CHAR (4),  ---- Sucursal
	DATE;      ---- Fecha insert

	--DEFINICION DE VARIABLES--
	DEFINE cCodRet      CHAR (5);
	DEFINE cNumCliente  CHAR (20);
	DEFINE smSecuencia  SMALLINT;
	DEFINE cStatus      CHAR (1);
	DEFINE cUser_Insert CHAR (8);
	DEFINE cEmpleado    CHAR (8);
	DEFINE cUsuario3    CHAR (8);
	DEFINE cSucursal    CHAR (4);
	DEFINE dFecha_Insert  DATE;
	DEFINE smSecuenciaMax SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET cCodRet = "00000";
	LET cNumCliente = "";
	LET smSecuencia = 0;
	LET cStatus = "";
	LET cUser_Insert = "";
	LET cEmpleado = "";
	LET cUsuario3 = "";
	LET cSucursal = "";
	LET dFecha_Insert = "";
	LET smSecuenciaMax = 0;
	
	--SET DEBUG FILE TO "/informix/sp_consultapreasignacionhuella_web_442.out";
	--TRACE ON;
	BEGIN

		IF cNumCte IS NULL OR Trim(cNumCte) = "" THEN
			LET cCodRet = "00110";
			RETURN cCodRet, cNumCliente, smSecuencia, cStatus, cUser_Insert, cEmpleado, cUsuario3, cSucursal, dFecha_Insert;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF (SELECT count(numcte)  FROM bdinteg:si_cte_huella_dec_temp WHERE numcte = cNumCte) = 0 THEN
			LET cCodRet = "00001";
		END IF;

		SELECT MAX(secuencia)
		INTO smSecuenciaMax
		FROM bdinteg:si_cte_huella_dec_temp
		WHERE numcte = cNumCte;

		SELECT first 1 numcte, secuencia, status, user_insert, empleado, usuario3, sucursal, fecha_insert
		INTO cNumCliente, smSecuencia, cStatus, cUser_Insert, cEmpleado, cUsuario3, cSucursal, dFecha_Insert            
		FROM bdinteg:si_cte_huella_dec_temp
		WHERE numcte = cNumCte
		AND secuencia = smSecuenciaMax;

		RETURN NVL(cCodRet,"00001"), NVL(cNumCliente,""), NVL(smSecuencia,""), NVL(cStatus,""), NVL(cUser_Insert,""), NVL(cEmpleado,""), NVL(cUsuario3,""), NVL(cSucursal,""), dFecha_Insert;
	END;
END PROCEDURE;