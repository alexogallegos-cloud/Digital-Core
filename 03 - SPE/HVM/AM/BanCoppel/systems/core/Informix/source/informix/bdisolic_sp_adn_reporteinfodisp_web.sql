CREATE PROCEDURE "informix".sp_adn_reporteinfodisp_web(pEmpresa CHAR(3), pSolicitud CHAR (20))
RETURNING CHAR(5)       AS codigo_retorno,
		  INTEGER       As MontoMax,
		  INTEGER       As ComisionActi,
		  INTEGER       As ComisionDisp,
		  INTEGER       As ComisionDisp2,
		  INTEGER       As MontoDisp1,
		  INTEGER       As MontoDisp2,
		  INTEGER       As MontoMin,
		  INTEGER       As ComDisp,		
		  CHAR(6)       As CatPromM,
		  CHAR(6)       As CatPromQ,
		  CHAR(6)       As CatPromS,	  
		  CHAR(26)      As fecha1,
		  CHAR(26)      As fecha2;
		 

DEFINE cCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);


DEFINE iMontoMax	INTEGER;
DEFINE iComisionActi	INTEGER;
DEFINE iComisionDisp	INTEGER;
DEFINE iComisionDisp2	INTEGER;
DEFINE iMontoDisp1	INTEGER;
DEFINE iMontoDisp2	INTEGER;
DEFINE iMontoMin	INTEGER;
DEFINE iComDisp	INTEGER;
DEFINE mCatPromM	CHAR(6);
DEFINE mCatPromQ	CHAR(6);
DEFINE mCatPromS	CHAR(6);
DEFINE cfecha1	CHAR(26);
DEFINE cfecha2	CHAR(26);


DEFINE dAnticipo	DECIMAL(18,2);
DEFINE dMontoAct	DECIMAL(18,2);
DEFINE mMontoAct	DECIMAL(18,2);
DEFINE mMontoDisp	DECIMAL(18,2);
DEFINE mMontoDispAux	DECIMAL(18,2);
DEFINE mIvaMontoDisp	 DECIMAL(14,2);
DEFINE mIvaMontoAct	 DECIMAL(14,2);


LET cCodRet			= "00000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET iMontoMax	= 0;
LET iComisionActi	= 0;
LET iComisionDisp	= 0;
LET iComisionDisp2	= 0;
LET iMontoDisp1	= 0;
LET iMontoDisp2= 0;
LET iMontoMin	= 0;
LET iComDisp	= 0;
LET mCatPromM	= '0.0';
LET mCatPromQ	= '0.0';
LET mCatPromS	= '0.0';
LET cfecha1	= "";
LET cfecha2	= "";

LET dAnticipo	= 0;
LET dMontoAct	= 0;
LET mMontoAct	= 0;
LET mMontoDisp = 0;
LET mMontoDispAux = 0;
LET mIvaMontoDisp	= 0;
LET mIvaMontoAct	 = 0;

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN cCodRet , NVL(iMontoMax,0),  NVL(iComisionActi,0),  NVL(iComisionDisp,0),  NVL(iComisionDisp2,0),  NVL(iMontoDisp1,0),  NVL(iMontoDisp2,0) , NVL(iMontoMin,0),  NVL(iComDisp,0),  NVL(mCatPromM,0.0),  NVL(mCatPromQ,0.0),  NVL(mCatPromS,0.0),  NVL(cfecha1,'')	,  NVL(cfecha2,'');
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/jesus/RQM10617/sp_adn_inforeportes.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa,"")) = "" OR  TRIM(NVL(pSolicitud,"")) = ""  THEN
		LET cCodRet  = "00001";
		RETURN cCodRet , NVL(iMontoMax,0),  NVL(iComisionActi,0),  NVL(iComisionDisp,0),  NVL(iComisionDisp2,0),  NVL(iMontoDisp1,0),  NVL(iMontoDisp2,0) , NVL(iMontoMin,0),  NVL(iComDisp,0),  NVL(mCatPromM,0.0),  NVL(mCatPromQ,0.0),  NVL(mCatPromS,0.0),  NVL(cfecha1,'')	,  NVL(cfecha2,'');
	END IF;

		SELECT linea
			INTO iMontoMax
		FROM  "informix".ss_adn_solicitudcuenta
		WHERE  num_solicitud = pSolicitud
		AND  empresa = pEmpresa;
		
		IF iMontoMax = 0 THEN
		LET cCodRet  = "00002";		RETURN cCodRet ,NVL(iMontoMax,0),  NVL(iComisionActi,0),  NVL(iComisionDisp,0),  NVL(iComisionDisp2,0),  NVL(iMontoDisp1,0),  NVL(iMontoDisp2,0) , NVL(iMontoMin,0),  NVL(iComDisp,0),  NVL(mCatPromM,0.0),  NVL(mCatPromQ,0.0),  NVL(mCatPromS,0.0),  NVL(cfecha1,'')	,  NVL(cfecha2,'');
		END IF;
		
		SELECT monto_min_cred 
		INTO iMontoMin
		FROM bdicred:"informix".sd_definicion 
		WHERE num_producto ='7800';
		
		--comision por activacion
		SELECT monto
		INTO mMontoAct 
		FROM  bdicred:"informix".sd_tpcomis 
		WHERE empresa = '001' 
		AND cod_comis = '8170';
		
		LET mIvaMontoAct = mMontoAct * 0.16 ;
		
		LET iComisionActi = mMontoAct + mIvaMontoAct;

		--comision por disposicion
		SELECT monto
		INTO mMontoDisp 
		FROM  bdicred:"informix".sd_tpcomis 
		WHERE empresa = '001'  
		AND cod_comis = '8172';
		LET mMontoDispAux  =  iMontoMax * (mMontoDisp/100) ;
		LET mIvaMontoDisp = mMontoDispAux * 0.16 ;
		
		LET iComisionDisp = mMontoDispAux + mIvaMontoDisp ;
		LET iComisionDisp2 = mMontoDispAux + mIvaMontoDisp ;
		
		LET iComDisp =  mMontoDisp;
		LET iMontoDisp1 = iMontoMax -  (iComisionActi + iComisionDisp) ;
		LET iMontoDisp2 = iMontoMax -  iComisionDisp2  ;

		----VALOR DEL CAT
		SELECT valor INTO mCatPromM
		FROM bdicred:"informix".sd_param
		WHERE empresa = pempresa
		AND cod_param = '098';


		IF mCatPromM IS NULL THEN
		LET mCatPromM =80.0;
		END IF

		SELECT valor INTO mCatPromQ
		FROM bdicred:"informix".sd_param
		WHERE empresa = pempresa
		AND cod_param = '099'; 

		IF mCatPromQ IS NULL THEN
			LET mCatPromQ = 223.7;
		END IF


		SELECT valor INTO mCatPromS
		FROM bdicred:"informix".sd_param
		WHERE empresa = pempresa
		AND cod_param = '171'; 

		IF mCatPromS IS NULL THEN
			LET mCatPromS = 1174.0;
		END IF
		
		SELECT valor
		INTO cfecha1
		FROM bdicred:"informix".sd_param
		WHERE cod_param ='180';
		
		SELECT valor
		INTO cfecha2
		FROM bdicred:"informix".sd_param
		WHERE cod_param ='181';
		
 
	RETURN cCodRet ,NVL(iMontoMax,0),  NVL(iComisionActi,0),  NVL(iComisionDisp,0),  NVL(iComisionDisp2,0),  NVL(iMontoDisp1,0),  NVL(iMontoDisp2,0) , NVL(iMontoMin,0),  NVL(iComDisp,0),  NVL(mCatPromM,0.0),  NVL(mCatPromQ,0.0),  NVL(mCatPromS,0.0),  NVL(cfecha1,'')	,  NVL(cfecha2,'');
 

END
END PROCEDURE
