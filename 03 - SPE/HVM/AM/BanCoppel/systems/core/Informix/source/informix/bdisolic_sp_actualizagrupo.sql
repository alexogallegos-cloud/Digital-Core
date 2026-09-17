CREATE PROCEDURE "informix".sp_actualizagrupo(pFechaIni date, pfechaFin date) 
	RETURNING 
	CHAR(6) AS codret;
	--CHAR(80) AS Mensaje,

	---DECLARACION DE VARIABLES
	DEFINE cCodRet CHAR(6);
	DEFINE ptipogrupo CHAR(1);
	DEFINE phit CHAR(6);
	DEFINE VSQL  CHAR(6000);
	DEFINE iSqlErr INTEGER;
	DEFINE dPaso  SMALLINT;
	DEFINE error_info CHAR(80);
	DEFINE isam_err INTEGER;
	DEFINE pempresa CHAR(3);
	DEFINE pproceso CHAR(30);
	DEFINE pMensaje CHAR(80);
	DEFINE cCod_RetIB CHAR(6);
	DEFINE pmeses_historia SMALLINT;
	DEFINE psituacion_pago DECIMAL(5,2);
	DEFINE pgrupo CHAR(1);
	DEFINE pevalua_cc CHAR(1);
	DEFINE pfuente CHAR(1);
	DEFINE pnum_producto CHAR(4);
	DEFINE pnumcte CHAR(20);
	DEFINE ptipo_alta CHAR(1);
	DEFINE pnum_solicitud CHAR(20);
	DEFINE vlFecha	DATE;
	DEFINE vlCteLargo smallint;
	
	--SET DEBUG FILE TO "/informix/marcov/sp_actualizagrupo.out";
	--TRACE ON;

	---INICIALIZACION DE VARIABLES
	LET cCodRet  = '000000';
	LET ptipogrupo = '';
	LET phit = '';
	LET VSQL = '';
	LET iSqlErr = 0;
	LET dPaso = 0;
	LET pMensaje = 'PROCESO EXITOSO';
	LET pproceso = '2119';
	LET pempresa = '001';
	LET cCod_RetIB	= "000000";
	LET pmeses_historia = 0;
	LET psituacion_pago = 0;
	LET pgrupo = '';
	LET pevalua_cc = '';
	LET pfuente = '';
	LET pnum_producto = '';
	LET pnumcte = '';
	LET ptipo_alta = '';
	LET pnum_solicitud = '';
	LET vlFecha = DATE(1);
	LET vlCteLargo =0;

	BEGIN

	ON EXCEPTION SET iSqlErr/*, isam_err, error_info*/
	LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END EXCEPTION;
		
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy 
	  into vlFecha
	 FROM bdicred:sd_fechas
	 WHERE empresa = '001';
	
FOREACH WITH HOLD
	SELECT a.meses_historia,a.situacion_pago,a.grupo,a.evalua_cc,a.fuente,a.num_solicitud,b.num_producto,b.numcte--,nvl(c.tipo_alta,'')
	INTO pmeses_historia,psituacion_pago,pgrupo,pevalua_cc,pfuente,pnum_solicitud,pnum_producto,pnumcte --,ptipo_alta
	FROM bdisolic:ss_resum_scor_fin a, bdisolic:ss_solicitudes b --, outer bdiprospectos:pr_cliente c
    WHERE a.empresa = pEmpresa 
	AND a.empresa = b.empresa
	AND a.num_solicitud = b.num_solicitud 
	/*AND b.num_producto <> '6500'*/ and status_solicitud <>'AN'
	and ( nvl(A.Grupo,'') ='' or nvl(A.Grupo,'') ='0')
---	AND b.numcte = c.numcte 
	and b.fecha_insert >= pFechaIni  
	and b.fecha_insert <= pfechaFin 
	
	SELECT count(*) into vlCteLargo
	FROM "informix".ss_clienteslargos
	WHERE numcte = pnumcte
	  AND fecha_vig_ini<= vlFecha 
	  AND fecha_vig_fin >= vlFecha;
	  
	IF nvl(vlCteLargo,0) > 0 then
	   BEGIN WORK;
		UPDATE bdisolic:ss_resum_scor_fin
		SET grupo = '8' 
		WHERE empresa = pempresa
		AND num_solicitud = pnum_solicitud;
	   COMMIT WORK;
	
	ELSE  


	IF pmeses_historia >= 13 AND psituacion_pago >= 85 AND NVL(pgrupo,'') NOT IN ('6','A') THEN
		BEGIN WORK;
		UPDATE bdisolic:ss_resum_scor_fin
		SET grupo = '1' 
		WHERE empresa = pempresa
		AND num_solicitud = pnum_solicitud;
		COMMIT WORK;

	ELIF pmeses_historia >= 6 AND pmeses_historia < 13 AND psituacion_pago >= 85 AND NVL(pgrupo,'') NOT IN ('6','A') THEN
		BEGIN WORK;
		UPDATE bdisolic:ss_resum_scor_fin
		SET grupo = '2' 
		WHERE empresa = pempresa
		AND num_solicitud = pnum_solicitud;
		COMMIT WORK;
		
	ELIF ((pmeses_historia < 6 AND psituacion_pago >= 85)) AND NVL(pgrupo,'') NOT IN ('6','A') THEN
		BEGIN WORK;	
		UPDATE bdisolic:ss_resum_scor_fin
		SET grupo = '3' 
		WHERE empresa = pempresa
		AND num_solicitud = pnum_solicitud;
		COMMIT WORK;

	ELIF pmeses_historia >= 6 AND psituacion_pago >= 0 AND psituacion_pago < 85 AND NVL(pgrupo,'') NOT IN ('6','A') THEN
		BEGIN WORK;
		UPDATE bdisolic:ss_resum_scor_fin
		SET grupo = '4' 
		WHERE empresa = pempresa
		AND num_solicitud = pnum_solicitud;
		COMMIT WORK;

	ELIF ((NVL(psituacion_pago,0) = 0 AND NVL(pmeses_historia,0) = 0) OR (NVL(psituacion_pago,0) = -1) OR (pmeses_historia < 6 AND psituacion_pago < 85))  AND NVL(pgrupo,'') NOT IN ('6','A') THEN
		BEGIN WORK;
		UPDATE bdisolic:ss_resum_scor_fin
		SET grupo = '5' 
		WHERE empresa = pempresa
		AND num_solicitud = pnum_solicitud;
		COMMIT WORK;

	END IF;
	END IF;
END FOREACH;

FOREACH WITH HOLD
	SELECT a.meses_historia,a.situacion_pago,a.grupo,a.evalua_cc,a.fuente,a.num_solicitud,b.num_producto,b.numcte,nvl(c.tipo_alta,'')
	INTO pmeses_historia,psituacion_pago,pgrupo,pevalua_cc,pfuente,pnum_solicitud,pnum_producto,pnumcte,ptipo_alta
	FROM bdisolic:ss_resum_scor_fin a, bdisolic:ss_solicitudes b, bdiprospectos:pr_cliente c
    WHERE a.empresa = pEmpresa 
	AND a.num_solicitud = b.num_solicitud 
	AND b.numcte = c.numcte 
	AND b.num_producto = '6500' and status_solicitud <>'AN'
	--and ( nvl(A.Grupo,'') ='' or nvl(A.Grupo,'') ='0')
	and b.fecha_insert >= pFechaIni  
	and b.fecha_insert <= pfechaFin 	


	IF pnum_producto = '6500' AND ptipo_alta = '2' THEN
		BEGIN WORK;
		UPDATE bdisolic:ss_resum_scor_fin
		SET grupo = '7' 
		WHERE empresa = pempresa
		AND num_solicitud = pnum_solicitud;
		COMMIT WORK;

	END IF;
END FOREACH;

RETURN cCodRet;
END
END PROCEDURE
