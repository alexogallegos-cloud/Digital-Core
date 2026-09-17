CREATE PROCEDURE "informix".sp_consultaingresostrab_web(pNumCte CHAR(20), pTipoIngres CHAR(1))
	RETURNING 	CHAR(5), CHAR(3), CHAR(20), SMALLINT, CHAR(1), CHAR(60), CHAR (3), CHAR(2), DECIMAL(4,2), CHAR(40), CHAR(60), MONEY(14,2),
				CHAR(8), DATE, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cEmpres CHAR(3);
DEFINE cNumCte CHAR(20);
DEFINE sSecIng SMALLINT;
DEFINE cTipIng CHAR(1);
DEFINE cNomEmp CHAR(60);
DEFINE cPuesto CHAR(3);
DEFINE cPutEsp CHAR(2);
DEFINE dAntigd DECIMAL(4,2);
DEFINE cNomDep CHAR(40);
DEFINE cJefInm CHAR(60);
DEFINE mIngMen MONEY(14,2);
DEFINE cUsrInt CHAR(8);
DEFINE dFecInt DATE;
DEFINE iCvePst INTEGER;
DEFINE iCveOPt INTEGER;
DEFINE iCveSOP INTEGER;
DEFINE iSisCot INTEGER;
DEFINE iNumELa INTEGER;
DEFINE iPerios INTEGER;
DEFINE iTipIEx INTEGER;

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';
LET cEmpres = '';
LET cNumCte = '';
LET sSecIng = 0;
LET cTipIng = '';
LET cNomEmp = '';
LET cPuesto = '';
LET cPutEsp = '';
LET dAntigd = 0;
LET cNomDep = '';
LET cJefInm = '';
LET mIngMen = 0;
LET cUsrInt = '';
LET dFecInt = DATE(1);
LET iCvePst = 0;
LET iCveOPt = 0;
LET iCveSOP = 0;
LET iSisCot = 0;
LET iNumELa = 0;
LET iPerios = 0;
LET iTipIEx = 0;

--SET DEBUG FILE TO '/tmp/sp_ConsultaIngresosCliente.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
			iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pNumCte = '' OR pTipoIngres = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
		iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx;
	END IF;
	
	IF (SELECT COUNT(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = pNumCte AND tipo_ingreso = pTipoIngres) > 0 THEN
		FOREACH
				SELECT empresa, numcte, sec_ingreso, tipo_ingreso, nombre_empresa, puesto, puesto_esp, antiguedad, nombre_depto, jefe_inmediato, ingreso_mensual,
				user_insert, fecha_insert, clavepuesto, claveopcionpuesto, clavesubopcionpuesto, sis_cotiza, num_emp_lab, periosidad, tipo_ingreso_ext
				INTO cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
				iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx
				FROM bdinteg:"informix".si_ingresos 
				WHERE numcte = pNumCte 			
				AND tipo_ingreso = pTipoIngres
			    return cCodRet, cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
	                   iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx with resume;
		END FOREACH;
	ELSE
		SELECT id_act, id_subact INTO iCveOPt, iCveSOP FROM bdinteg:"informix".si_bitacoraapertura 
		WHERE numcte = pNumCte AND id_pregunta = 6
		AND id_secuencia = (SELECT MAX(id_secuencia) FROM bdinteg:"informix".si_bitacoraapertura WHERE numcte = pNumCte AND id_pregunta = 6);
		
		IF NVL(iCveOPt, 0) = 0 OR NVL(iCveSOP, 0) = 0 THEN
			LET iCveOPt = 0;
			LET iCveSOP = 0;
			LET cCodRet = '00001';
		END IF;
	END IF;
	
	RETURN cCodRet, cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
	iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta datos de ingresos del cliente, si no existe informacion consulta en bitacora',
'AUTOR : Gonzalo Garcia ',
'FECHA : Mayo de 2019',
'VERSION: 20190522.001',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultapreasignacionhuella_web(cEmpresa CHAR(3), cNumCte CHAR(20))

        --DATOS A REGRESAR---
        RETURNING
        CHAR (5),  ---- Codigo de Retorno
        CHAR (3),  ---- Empresa
        CHAR (20), ---- Numero de Cliente
        SMALLINT,  ---- Secuencia
        CHAR (1),  ---- Status
        CHAR (8),  ---- Oerador
        CHAR (8),  ---- Empleado
        CHAR (8),  ---- Usuario3
        CHAR (4),  ---- Sucursal
        CHAR (20), ---- Nueva Identificacion
        CHAR (20), ---- Numero de Referencia
        DATE,      ---- Fecha de Alta
        CHAR (942), --- Dmapa
        CHAR (942); --- Imapa

        --DEFINICION DE VARIABLES--
        DEFINE cCodRet      CHAR (5);
        DEFINE cEmpresa     CHAR (3);
        DEFINE cNumCliente  CHAR (20);
        DEFINE smSecuencia  SMALLINT;
        DEFINE cStatus      CHAR (1);
        DEFINE cOperador    CHAR (8);
        DEFINE cEmpleado    CHAR (8);
        DEFINE cUsuario3    CHAR (8);
        DEFINE cSucursal    CHAR (4);
        DEFINE cNueva_ident CHAR (20);
        DEFINE cNum_refer   CHAR (20);
        DEFINE dFecha_Alta  DATE;
        DEFINE cDmapa       CHAR (942);
        DEFINE cImapa       CHAR (942);
        DEFINE smSecuenciaMax SMALLINT;

        --INICIALIZACION DE VARIABLES--
        LET cCodRet = "00000";
        LET cNumCliente = "";
        LET cEmpresa = "";
        LET smSecuencia = 0;
        LET cStatus = "";
        LET cOperador = "";
        LET cEmpleado = "";
        LET cUsuario3 = "";
        LET cSucursal = "";
        LET cNueva_ident = "";
        LET cNum_refer = "";
        LET dFecha_Alta = "";
        LET cDmapa = "";
        LET cImapa = "";
        LET smSecuenciaMax = 0;

            IF cNumCte IS NULL OR Trim(cNumCte) = "" THEN
                LET cCodRet = "00110";
                RETURN cCodRet,cEmpresa,cNumCliente,smSecuencia,cStatus,cOperador,cEmpleado,cUsuario3,
                       cSucursal, cNueva_ident, cNum_refer, dFecha_Alta, cDmapa,cImapa;
            END IF;

            IF NOT EXISTS (SELECT numcte  FROM bdinteg:si_huella_temp WHERE numcte = cNumCte) THEN
                    LET cCodRet = "00001";
            END IF;
			
			SET ISOLATION DIRTY READ;
			SET LOCK MODE TO WAIT 3;

            SELECT MAX(secuencia)
            INTO smSecuenciaMax
            FROM bdinteg:si_huella_temp
            WHERE numcte = cNumCte;

            SELECT empresa,numcte,secuencia,status,operador,empleado,usuario3,sucursal, nueva_ident, num_refer, fecha_alta,dmapa,imapa
            INTO cEmpresa,cNumCliente,smSecuencia,cStatus,cOperador,cEmpleado,cUsuario3,cSucursal, cNueva_ident, cNum_refer, dFecha_Alta, cDmapa,cImapa
            FROM bdinteg:si_huella_temp
            WHERE numcte = cNumCte
            AND secuencia = smSecuenciaMax;

            RETURN cCodRet,cEmpresa,cNumCliente,smSecuencia,cStatus,cOperador,cEmpleado,cUsuario3,
                   cSucursal, cNueva_ident, cNum_refer, dFecha_Alta, cDmapa,cImapa;
END PROCEDURE
DOCUMENT
"Consulta Preasignacion de Huella de cliente persona fisica",
"AutOR : Priscilla Mercado CampaÃ±a.",
"FECHA : 13-11-2008",
"BD    : bdinteg",
"VER   : 1.1",
"Se modifica para consultar si el cliente no existe en la tabla temporal de huellas",
"FECHA: 13-01-2009";

CREATE PROCEDURE "informix".sp_obtener_num_serie_token_web(pNumCte char(9))
		RETURNING char(5), char(10);

	--Define variables
	define sql_err integer;
	define cod_ret char (5);
	define vNumSerie char(9);

	--Inicializa Variables
	LET sql_err = 0;
	LET cod_ret = '00000';
	LET vNumSerie = '';

	--Realizo: Javier Calderon
	--Fecha: 30/12/08
	--Solicito: Mauricio Leon
	--Actividad: Obtiene el numero de serie del token asignado a un cliente


	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret, vNumSerie;
		END IF;
	 END EXCEPTION;

	 SET ISOLATION TO DIRTY READ;
	 SET LOCK MODE TO WAIT 3;
	 
	 IF EXISTS(SELECT numcte FROM si_bpiusuarios WHERE numcte = pNumCte) THEN
				SELECT ns_token INTO vNumSerie FROM si_bpitoken WHERE empresa = '001' AND  num_cliente = pNumCte;

	 ELSE
			LET cod_ret = '00001'; --El Cliente no existe
	 END IF;

	 RETURN cod_ret, NVL(vNumSerie,'');

	END;

END PROCEDURE;