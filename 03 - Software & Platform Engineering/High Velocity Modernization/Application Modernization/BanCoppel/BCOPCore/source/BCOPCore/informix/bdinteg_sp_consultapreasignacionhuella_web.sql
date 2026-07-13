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