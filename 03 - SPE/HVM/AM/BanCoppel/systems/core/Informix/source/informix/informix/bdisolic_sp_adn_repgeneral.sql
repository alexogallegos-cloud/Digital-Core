CREATE PROCEDURE "informix".sp_adn_repgeneral ( pNumCel  CHAR(20))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMen_ret CHAR(80);

DEFINE sParamVencido        SMALLINT;
DEFINE dSdo_vencido         DECIMAL(18,2);
DEFINE dSdo_vencidocrd      DECIMAL(18,2);
DEFINE dMontoMin	DECIMAL(18,2);
DEFINE dMontoMax	DECIMAL(18,2);

DEFINE cNumCte	CHAR(20);
DEFINE cCtaNom	CHAR(20);
DEFINE cNumSol	CHAR(20);
DEFINE cActCob	CHAR(1);
DEFINE dAnticipo	DECIMAL(18,2);
DEFINE mMontoAct	DECIMAL(18,2);
DEFINE mMontoDisp	DECIMAL(18,2);
DEFINE mMontoDispAux	DECIMAL(18,2);
DEFINE mIvaMontoDisp	 DECIMAL(14,2);
DEFINE mIvaMontoAct	 DECIMAL(14,2);
DEFINE cNombreComAct	CHAR(50);
DEFINE cNombreComDisp	CHAR(50);
DEFINE cNumcred	CHAR(20);
DEFINE cProducto	CHAR(4);
DEFINE cNumeroFolio 		CHAR(16);
DEFINE vCveExistente 		INTEGER;
DEFINE dtFechaHoy 		DATE;

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMen_ret     = "Proceso Exitoso";


LET sParamVencido     = 0;
LET dSdo_vencido      = 0;
LET dSdo_vencidocrd   = 0;
LET dMontoMin	= 0;
LET dMontoMax	= 0;

LET cNumCte	= "";
LET cCtaNom	= "";
LET cNumSol = "";
LET cActCob	= "";
LET dAnticipo	= 0;
LET mMontoAct	= 0;
LET mMontoDisp = 0;
LET mMontoDispAux = 0;
LET mIvaMontoDisp	= 0;
LET mIvaMontoAct	 = 0;
LET cNombreComAct	= "";
LET cNombreComDisp	= "";
LET cNumcred	= "";
LET cProducto	= "";
LET cNumeroFolio	= "";
LET vCveExistente	= 0;
LET dtFechaHoy	= DATE(1);


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN cCodRet,cErrorInfo ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/sp_validaradn.out';
	--TRACE ON;

	IF NVL(pNumCel,'') = ''  THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
		
	
		
					
	END IF;		
	RETURN cCodRet,cMen_ret ;
END
END PROCEDURE
