CREATE PROCEDURE "informix".sp_consultar_envios_coppel_cteprosp1(pTipoConsulta SMALLINT)
RETURNING CHAR(6)  AS COD_RET,
		  CHAR(80) AS MENSAJE_EJEC,
		  CHAR(3)  AS EMPRESA,
		  CHAR(20) AS NUMCTE,
		  CHAR(20) AS NUM_SOLICITUD,
		  INTEGER  AS TipoCliente;

--DECLARACION DE VARIABLES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE cMensajeRet      CHAR(80);
DEFINE cEmpresa         CHAR(3);
DEFINE cNumCte          CHAR(20);
DEFINE cNumSolicitud    CHAR(20);
DEFINE iNumreg    		INTEGER;
DEFINE iTipocliente 	INTEGER;
DEFINE dFecha           DATETIME YEAR to SECOND;

--INICIALIZACION DE VARIABLES
LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cMensajeRet    = "PROCESO EXITOSO";
LET cEmpresa       = "";
LET cNumCte        = "";
LET cNumSolicitud  = "";
LET iNumreg  	   = 0;
LET iTipoCliente   = 0;
LET dFecha         = DATE(1);

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet = iSqlErr;
		  LET cMensajeRet = cErrorInfo;
		  RETURN TRIM(cCodRet), TRIM(cMensajeRet),"","","","";
	   END IF;
	END EXCEPTION;

	-- SET DEBUG FILE TO "/home/sysifx/Raul/sp_consultar_envios_coppel_cteprosp.out";
	-- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pTipoconsulta IS NULL THEN
		LET cCodRet = "000002";
		LET cMensajeRet = "Parametro nulo";
		RETURN TRIM(cCodRet), TRIM(cMensajeRet),"","","","";
	END IF;
	IF pTipoConsulta NOT IN (1,2,3) THEN
		LET cCodRet = "000003";
		LET cMensajeRet = "Parametro erroneo";
		RETURN TRIM(cCodRet), TRIM(cMensajeRet),"","","","";
	END IF;

	IF pTipoConsulta IN (1,3) THEN
		--CLIENTE TIPO 1
		LET iTipoCliente = 1;
		
		FOREACH WITH HOLD
			SELECT empresa,numcte,num_solicitud
				INTO cEmpresa,cNumCte,cNumSolicitud
			FROM "informix".ss_solicitudes
			WHERE envio_parametrico = "1"	
			AND num_producto = '6001'    
			--and sucursal <= '0815'
			and sucursal = '0000'
			AND status_solicitud = "EC"
			ORDER BY fecha_hora DESC--AUM

			LET iNumreg = iNumreg + 1;

			RETURN cCodRet, cMensajeRet,TRIM(NVL(cEmpresa,"")),TRIM(NVL(cNumCte,"")),TRIM(NVL(cNumSolicitud,"")),NVL(iTipoCliente,0) WITH RESUME;
		END FOREACH;
	END IF;
		--LIMPIAR VARIABLES
		LET cEmpresa 		= "";
		LET cNumCte  		= "";
		LET cNumSolicitud 	= "";
		
	/*	SE COMENTA por que ya se encuentra en el sp: sp_consultar_envios_coppel_cteprosp
	IF pTipoConsulta IN (2,3) THEN
		--CLIENTE TIPO 3 (PROSPECTO)
		LET iTipoCliente = 2;
		FOREACH WITH HOLD
				SELECT empresa,numcte,numcte_pros,fecha_hora
				INTO cEmpresa,cNumCte,cNumSolicitud,dFecha
				FROM bdiprospectos:"informix".pr_cliente
				WHERE envio_parametrico = 0 AND status_numcte_pros = "PC"
				union all
				SELECT empresa,numcte,numcte_pros,fecha_hora
				FROM bdiprospectos:"informix".pr_cliente
				WHERE envio_parametrico = 1 AND status_numcte_pros = "EC"
				ORDER BY fecha_hora DESC --AUM

				LET iNumreg = iNumreg + 1;

				RETURN cCodRet, cMensajeRet,TRIM(NVL(cEmpresa,"")),TRIM(NVL(cNumCte,"")),TRIM(NVL(cNumSolicitud,"")),NVL(iTipoCliente,0) WITH RESUME;

		END FOREACH;
	END IF;
	
	*/
		IF iNumreg = 0 THEN
			LET cCodRet = "000001";
			LET cMensajeRet = "No se encontro informacion";
			RETURN TRIM(cCodRet), TRIM(cMensajeRet),"","","","";
		END IF;
END;
END PROCEDURE
