CREATE PROCEDURE "informix".sp_repsolrtoscalleautgte (pEmpresa CHAR(3),pSucursal CHAR(4),pUsuario CHAR(10), pFechaIni DATE,pFechaFin DATE,pRegistros INTEGER)	
RETURNING CHAR(5), -- Codigo de Retorno		  
		  CHAR(4), --sucursal
		  CHAR(20), --numero de solicitud
		  CHAR(20),--numero de cliente
		  CHAR(107),--nombre del cliente
		  DATE,--fecha de autorización
		  CHAR(10),--gerente autorizo
		  CHAR(50); -- motivo de autorización

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cMen_ret CHAR(80);

DEFINE cSucursal CHAR(4);
DEFINE cNumSol CHAR(20); 
DEFINE cNumcte CHAR(20);
DEFINE cNomCte CHAR(107);
DEFINE dtFechaAut DATE;
DEFINE cEmpleado CHAR(10);
DEFINE cMotivo CHAR(50);
DEFINE iBandera INTEGER;

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cMen_ret     = "Proceso Exitoso";


LET cSucursal  = "";
LET cNumSol  = "";
LET cNumcte  = "";
LET cNomCte  = "";
LET dtFechaAut = DATE(1);
LET cEmpleado  = "";
LET cMotivo  = "";
LET iBandera  = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr,cSucursal,cNumSol,cNumcte,cNomCte,dtFechaAut,cEmpleado,cMotivo;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/sp_gteactsolrtoscalle.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  OR NVL(pSucursal,'') = '' OR NVL(pFechaIni,'') = '' OR NVL(pFechaFin,'') = '' THEN
		RETURN  '00001',cSucursal,cNumSol,cNumcte,cNomCte,dtFechaAut,cEmpleado,cMotivo;
	ELSE
		FOREACH WITH HOLD
		SELECT 	sucursal,num_credito,numcte,nombre_cte,fecha_aut ,empleado_aut,motivo
			INTO cSucursal,cNumSol,cNumcte,cNomCte,dtFechaAut,cEmpleado,cMotivo
		FROM "informix".ss_solautorizadasgte 
		WHERE empresa = pEmpresa
		AND fecha_aut BETWEEN pFechaIni and pFechaFin
		
		LET iBandera = iBandera+1;

		IF iBandera <= pRegistros THEN				
			CONTINUE FOREACH;
		ELSE				
			RETURN cCodRet,NVL(cSucursal,''),NVL(cNumSol,''),NVL(cNumcte,''),NVL(cNomCte,''),NVL(dtFechaAut,''),NVL(cEmpleado,''),NVL(cMotivo,'') WITH RESUME ;
		END IF;		
		

	    END FOREACH;
	END IF;		
	IF iBandera =0 THEN
		RETURN  '00002',cSucursal,cNumSol,cNumcte,cNomCte,dtFechaAut,cEmpleado,cMotivo;
	END IF;
	
RETURN ;

END
END PROCEDURE
