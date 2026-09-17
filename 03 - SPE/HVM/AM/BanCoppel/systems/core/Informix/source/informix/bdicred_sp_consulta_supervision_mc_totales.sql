CREATE PROCEDURE "informix".sp_consulta_supervision_mc_totales
(pEmpresa      CHAR(3),
pNumSolicitud  VARCHAR(20,1),
pNumCte        VARCHAR(20,1),
pFechaIni      DATE,
pFechaFin      DATE,
pStatus        CHAR(2),
pProducto      CHAR(4))
RETURNING
	CHAR(6) 	    AS CodRet,
	INTEGER AS num_registros;	
	
---DECLARACIONES
DEFINE cCodRet        CHAR(6); 
DEFINE iSqlErr        INTEGER;
DEFINE iIsamErr       INTEGER;
DEFINE iNumReg        INTEGER;

DEFINE cEmpresa             CHAR(3);
DEFINE cNumSolic            VARCHAR(20,1);
DEFINE cNumCte              VARCHAR(20,1);
DEFINE cNomCte              VARCHAR(130,1);
DEFINE dtFechaSolic         DATE;
DEFINE dtFechaCambioSolic   DATE;
DEFINE cStatusSolic         CHAR(2);
DEFINE cSityCausa           VARCHAR(8,1);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cCodRet             = "000000";
LET iNumReg             = 0;

LET cEmpresa            = '';
LET cNumSolic           = '';
LET cNumCte             = '';
LET cNomCte             = '';
LET dtFechaSolic        = DATE(1);
LET dtFechaCambioSolic  = DATE(1);
LET cStatusSolic        = '';
LET cSityCausa          = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet,iNumReg;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_consulta_supervision_mc.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
  INTO cEmpresa     
  FROM bdinteg:si_empresas 
 WHERE empresa= pEmpresa;
  
IF cEmpresa IS NULL THEN
  LET cCodRet = '000001';
  RETURN cCodRet,iNumReg;
END IF;
/*
IF NVL(pNumSolicitud,'') = '' THEN
	LET pNumSolicitud = NULL;
END IF;    

IF NVL(pNumCte,'') = '' THEN
	LET pNumCte = NULL;
END IF;    

IF NVL(pFechaIni,'') = '' THEN
	LET pFechaIni = DATE(1);
END IF;

IF NVL(pFechaFin,'') = '' THEN
	LET pFechaFin = CURRENT;
END IF;

IF NVL(pStatus,'') = '' THEN
	LET pStatus = NULL;
END IF;

IF NVL(pProducto,'') = '' THEN
	LET pProducto = NULL;
END IF;*/

IF  pNumSolicitud  <> '' THEN --numero de solicitud

			SELECT 	COUNT(*)		 
			INTO  iNumReg
			FROM bdisolic:"informix".ss_solicitudes sol
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
																	  AND aut.empresa= sol.empresa 
																	  AND aut.status_solicitud= sol.status_solicitud
																	  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																							   FROM bdisolic:ss_autorizacion aut_aux
																							   WHERE aut_aux.empresa= sol.empresa 
																							   AND aut_aux.num_solicitud= sol.num_solicitud 
																							   AND aut_aux.status_solicitud= sol.status_solicitud))
			INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
			INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
			WHERE sol.empresa = pEmpresa
				AND sol.num_solicitud =  pNumSolicitud 
				AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso where numcte = cli.numcte);

			IF iNumReg = 0 THEN
				LET cCodRet = "000002";
			END IF;

			RETURN cCodRet,iNumReg;
	
	ELIF  pNumCte  <> '' THEN --numero de cliente
	
			SELECT 	COUNT(*)		 
			INTO  iNumReg
			FROM bdisolic:"informix".ss_solicitudes sol
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
																	  AND aut.empresa= sol.empresa 
																	  AND aut.status_solicitud= sol.status_solicitud
																	  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																							   FROM bdisolic:ss_autorizacion aut_aux
																							   WHERE aut_aux.empresa= sol.empresa 
																							   AND aut_aux.num_solicitud= sol.num_solicitud 
																							   AND aut_aux.status_solicitud= sol.status_solicitud))
			INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
			INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
			WHERE sol.empresa = pEmpresa 
				AND sol.numcte = pNumCte
				AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso where numcte = cli.numcte);

			IF iNumReg = 0 THEN
				LET cCodRet = "000002";
			END IF;

			RETURN cCodRet,iNumReg;
	
	ELSE --otros criterios
	
			SELECT 	COUNT(*)		 
			INTO  iNumReg
			FROM bdisolic:"informix".ss_solicitudes sol
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
																	  AND aut.empresa= sol.empresa 
																	  AND aut.status_solicitud= sol.status_solicitud
																	  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																							   FROM bdisolic:ss_autorizacion aut_aux
																							   WHERE aut_aux.empresa= sol.empresa 
																							   AND aut_aux.num_solicitud= sol.num_solicitud 
																							   AND aut_aux.status_solicitud= sol.status_solicitud))
			INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
			INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
			WHERE sol.empresa = pEmpresa
				AND sol.fecha_insert >= pFechaIni
				AND  sol.fecha_insert <= pFechaFin
				AND sol.status_solicitud = pStatus
				AND sol.num_producto = pProducto
				AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso where numcte = cli.numcte);

			IF iNumReg = 0 THEN
				LET cCodRet = "000002";
			END IF;

			RETURN cCodRet,iNumReg;
	
	END IF;
END
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 05/05/2016',
'DESCRIPCION: Se realiza procedimiento para la obtencion del número total de registros del Monitor de Supervisión.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_depura_sd_movhis_new()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 		INTEGER;
DEFINE isam_err 	INTEGER;
DEFINE error_info	CHAR(150);
DEFINE cMensaje 	CHAR(150);
DEFINE cCod_ret     CHAR(6);
DEFINE vrowid       INTEGER;
DEFINE VlNumCredito	CHAR(20);
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

	--SET DEBUG FILE TO "/informix/c91691184/sp_depura_sd_movhis_new_trace.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select trim(valor) into cValor 
	from "informix".sd_param 
	where empresa = '001' and cod_param = 'DT1';

	select date((pri_dia_mes - 2 units year) - 1 units day) into dFecha 
	from "informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from "informix".temp_creditos_depurar;

	if iCont > 0 and cValor = '1' then

		update "informix".sd_param set valor = '2'
		where empresa = '001' and cod_param = 'DT1';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select num_credito
		into VlNumCredito  
		from "informix".temp_creditos_depurar

		BEGIN WORK;

			DELETE FROM bdicred:"informix".sd_movhis_new 
			WHERE empresa = '001' and  num_credito = VlNumCredito and fecha_mov <= dFecha;
			delete from "informix".temp_creditos_depurar where num_credito = VlNumCredito;

		COMMIT WORK;

	END FOREACH;

	update "informix".sd_param set valor = '0'
	where empresa = '001' and cod_param = 'DT1';

	RETURN cCod_ret;

	END;

END PROCEDURE;