CREATE PROCEDURE "informix".sp_adn_inforeportes_web(pEmpresa CHAR(3), pSolicitud CHAR (20))
RETURNING CHAR(5)       AS codigo_retorno,
		  CHAR(20)      As Cuenta,
		  CHAR(6)       As Cat,
		  CHAR(10)      As Periodicidad,
		  DATE          As FechaNac,
		  MONEY(14,2)   As LineaMax,
		  MONEY(14,2)   As LineaMin,
		  MONEY(14,2)   As Porcentaje,
		  MONEY(14,2)   As ComxApert,
		  SMALLINT      As ComxDisp,
		  CHAR(30)      As Reca,
		  DATE          As fecha_sistema;
		 

DEFINE cCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);

DEFINE cCuenta	    CHAR(20);
DEFINE cCat	        CHAR(6);
DEFINE cPeriodicidad CHAR(10);
DEFINE dtFechaNac	DATE;
DEFINE dLineaMin	MONEY(14,2);
DEFINE dLineaMax	MONEY(14,2);
DEFINE dPorcentaje	MONEY(14,2);
DEFINE dComxApert   MONEY(14,2);
DEFINE dComxDisp	SMALLINT;
DEFINE cReca 	    CHAR(30);
DEFINE cNumCte 	    CHAR(20);
DEFINE iFrecPgo 	SMALLINT;
DEFINE cCod 	    CHAR(3);

LET cCodRet			= "00000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET cCuenta	= "";
LET cCat	= "";
LET cPeriodicidad = "";
LET dtFechaNac	= DATE(1);
LET dLineaMin	= 0;
LET dLineaMax	= 0;
LET dPorcentaje	= 0;
LET dComxApert   = 0;
LET dComxDisp	= 0;
LET cReca 	= "";
LET cNumCte 	= "";
LET iFrecPgo 	=0 ;
LET cCod 	='' ;

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN cCodRet ,cCuenta ,cCat, cPeriodicidad , dtFechaNac, dLineaMin,dLineaMax, dPorcentaje, dComxApert, dComxDisp , cReca ,today ;
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/jesus/RQM10617/sp_adn_inforeportes.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa,"")) = "" OR  TRIM(NVL(pSolicitud,"")) = ""  THEN
		LET cCodRet  = "00001";
		RETURN cCodRet ,cCuenta ,cCat, cPeriodicidad , dtFechaNac, dLineaMin,dLineaMax, dPorcentaje, dComxApert, dComxDisp , cReca , TODAY ;
	END IF;

	SELECT valor
	INTO dPorcentaje
	FROM bdicred:"informix".sd_param
	WHERE cod_param ='168';


	SELECT monto_min_cred, monto_max_cred 
	INTO dLineaMin, dLineaMax
	FROM bdicred:sd_definicion 
	WHERE num_producto ='7800';


	SELECT cuenta_nomina, DECODE(frecuencia_pgo,'1','Mensual','2','Quincenal','3','Semanal','Mensual'), numcte ,frecuencia_pgo
		INTO cCuenta, cPeriodicidad , cNumCte, iFrecPgo
	FROM  "informix".ss_adn_solicitudcuenta
	WHERE  num_solicitud = pSolicitud;
	
	SELECT fecha_nac INTO dtFechaNac 
	FROM bdinteg:"informix".si_ctepf  
	WHERE numcte =cNumCte;
		
		
		
	SELECT monto
		INTO dComxApert 
	FROM  bdicred:"informix".sd_tpcomis 
	WHERE empresa = '001' 
	AND cod_comis = '8170';


	--comision por disposicion
	SELECT monto
		INTO dComxDisp 
	FROM  bdicred:"informix".sd_tpcomis 
	WHERE empresa = '001'  
	AND cod_comis = '8172';
			
	IF iFrecPgo =  1 THEN
		LET cCod = "098";
	ELIF  iFrecPgo =  2 THEN	
		LET cCod = "099";	
	ELIF  iFrecPgo =  3 THEN
		LET cCod = "171";
	END IF
	
----VALOR DEL CAT
	SELECT NVL(valor,'') INTO cCat
	FROM bdicred:"informix".sd_param
	WHERE empresa = pempresa
	AND cod_param = cCod;
	
	IF NVL(cReca,'') = '' THEN
		IF iFrecPgo =  1 THEN
			LET cCat = "80.0";
		ELIF  iFrecPgo =  2 THEN	
			LET cCat = "223.7";	
		ELIF  iFrecPgo =  3 THEN
			LET cCat = "1174.0";
		END IF
	END IF;
	--LET cCuenta	= "13000661290";
	--LET cCat	= "0.0";
	--LET cPeriodicidad = "QUINCENAL";
	--LET dtFechaNac	= TODAY;
	--LET dLineaMin	= 200;
	--LET dLineaMax	= 5000;
	--LET dPorcentaje	= 20;
	--LET dComxApert   = 50.00;
	--LET dComxDisp	= 5;
	
	SELECT  NVL(valor,'')
	INTO cReca
	FROM bdicred:"informix".sd_param
	WHERE cod_param ='179';
		
	IF NVL(cReca,'') = '' THEN
		LET cReca = "1654-004-005408/15-01407-0616";
	END IF;	
 
	RETURN cCodRet ,cCuenta ,cCat, cPeriodicidad , dtFechaNac, dLineaMin,dLineaMax, dPorcentaje, dComxApert, dComxDisp , cReca, TODAY  ;
 

END
END PROCEDURE
