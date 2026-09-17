CREATE PROCEDURE "informix".sp_obtengrupocliente(pnumcte CHAR(20)) 
	RETURNING 
	CHAR(5) AS codret,
	--CHAR(80) AS Mensaje,
	Char(1) AS grupoCliente;
	

	---DECLARACION DE VARIABLES
	DEFINE cCodRet CHAR(5);
	DEFINE ptipogrupo CHAR(1);
	DEFINE phit CHAR(6);
	DEFINE VSQL  CHAR(6000);
	DEFINE iSqlErr INTEGER;
	DEFINE dPaso  SMALLINT;
	DEFINE error_info CHAR(80);
	DEFINE isam_err INTEGER;	
	DEFINE vlCteLargo SMALLINT;
	DEFINE vlFecha	DATE;
	DEFINE	vlGrupoCte CHAR(1);
	
	--SET DEBUG FILE TO "/informix/marcov/sp_obtienegrupo.out";
	--TRACE ON;

	---INICIALIZACION DE VARIABLES
	LET cCodRet  = '00000';
	LET ptipogrupo = '';
	LET phit = '';
	LET VSQL = '';
	LET iSqlErr = 0;
	LET dPaso = 0;	
	LET vlCteLargo ='';
	LET	vlFecha = DATE(1);
	LET vlGrupoCte = '';

	BEGIN

	ON EXCEPTION SET iSqlErr, isam_err, error_info
	LET cCodRet = iSqlErr;
		RETURN cCodRet,'';
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy 
	  into vlFecha
	 FROM bdicred:sd_fechas
	 WHERE empresa = '001';
		
	SELECT count(*) into vlCteLargo
	FROM "informix".ss_clienteslargos
	WHERE numcte = pNumCte
	  AND fecha_vig_ini<= vlFecha 
	  AND fecha_vig_fin >= vlFecha
	  AND status ='AC';
	if vlCteLargo is null then let vlCteLargo = 0; end if;  
	if vlCteLargo >0 then  LET vlGrupoCte = '8'; END IF;  

	RETURN cCodRet, vlGrupoCte;

END
END PROCEDURE
