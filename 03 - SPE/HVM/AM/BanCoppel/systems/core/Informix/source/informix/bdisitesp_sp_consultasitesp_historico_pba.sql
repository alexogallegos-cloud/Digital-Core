CREATE PROCEDURE "informix".sp_consultasitesp_historico_pba(pTipo INTEGER,
											pEmpresa CHAR(3),
											pNumCte CHAR(20),
											pSituacion CHAR(1),
											pCausa SMALLINT) 											
											
RETURNING CHAR(5)  AS cCodRet,     
		  SMALLINT AS sPonderacion,
		  CHAR(1)  AS Situacion,
		  SMALLINT AS Causa;

--Definicion de Variables
DEFINE cCodRet			CHAR(5);
DEFINE sPonderacion		SMALLINT;
DEFINE sPonderacionAct	SMALLINT;
DEFINE iSqlErr 			INTEGER;
DEFINE sNumCte			CHAR(20);
DEFINE cSituacionCte 	CHAR(1);
DEFINE sCausaCte 		SMALLINT;
DEFINE cNumCteAct       CHAR(20); 


--Inicializacion de Variables
LET cCodRet    		= '00000';
LET sPonderacion 	= '0';
LET sPonderacionAct = '0';
LET iSqlErr 		= 0;
LET sNumCte 		= '';
LET cSituacionCte 	= '';
LET sCausaCte 		= 0;
LET cNumCteAct      = '';

--SET DEBUG FILE TO '/tmp/sp_consultasitesp_historico.sql';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,sPonderacion,cSituacionCte,sCausaCte;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
	
		IF 	pTipo = 1 THEN	--Consultar SE en tabla historico
			
			SELECT situacion,causa 
			INTO cSituacionCte,sCausaCte
			FROM bdisitesp:"informix".se_ctessitespcte_his 
			WHERE numcte = pNumCte;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cSituacionCte = '';
				LET sCausaCte = 0;
			END IF;	
			
		ELIF pTipo = 2 THEN --Eliminar SE en tabla historico
			
			SELECT numcte INTO cNumCteAct FROM bdisitesp:se_ctessitespcte_his WHERE numcte = pNumCte and situacion = pSituacion and causa = pCausa;
			
			IF NVL(cNumCteAct,'')= pNumCte THEN 
											
				IF dbinfo("sqlca.sqlerrd2") > 0 THEN 
					DELETE FROM bdisitesp:"informix".se_ctessitespcte_his WHERE numcte = pNumCte and situacion = pSituacion and causa = pCausa;
				END IF;	
					
			ELSE
				LET cSituacionCte ='';
				LET sCausaCte = 0;
				LET sPonderacion ='0';
			END IF;
			
		ELSE
			LET cCodRet = '00004';
		END IF;
	
		
	RETURN cCodRet, sPonderacion,cSituacionCte,sCausaCte;
END;

END PROCEDURE
