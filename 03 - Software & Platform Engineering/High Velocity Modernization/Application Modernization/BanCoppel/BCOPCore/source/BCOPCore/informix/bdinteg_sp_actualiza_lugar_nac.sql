CREATE PROCEDURE "informix".sp_actualiza_lugar_nac()
				returning CHAR(5) AS Cod_Retorno,INTEGER as Idreg;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
DEFINE IidErr			INTEGER;
DEFINE sCve_elector     CHAR(18);
DEFINE cNumcte          CHAR(20);

LET sCve_elector        = '';
LET cNumcte				= '';
LET iexiste				=0;
LET iSql_err				   =0;
LET sRetCod          	="99999";
LET cCodRet 			= "00000";
LET IidErr				=0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,IidErr;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/VH/PM/sp_cnsif_consnumcte.out";
	--TRACE ON;
		

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
		SELECT {+  INDEX(bdinteg:si_solicitud_movil idx_movil_cveelector) } numcte,cve_elector INTO cNumcte,sCve_elector FROM si_solicitud_movil WHERE LENGTH(TRIM(cve_elector))=18 AND status_valua IS NOT NULL AND (numcte IS NOT NULL OR numcte<>'') 
		
		IF SUBSTR(TRIM(scve_elector),13,2) NOT IN('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
			LET sCve_elector        = '';
			LET cNumcte				= '';
		ELSE
			LET iexiste=0;
			SELECT COUNT(*) INTO iexiste FROM "informix".si_ctepf WHERE numcte=TRIM(cNumcte) and lugar_nac='';
			IF iexiste<>0 THEN
				UPDATE "informix".si_ctepf set lugar_nac=SUBSTR(TRIM(scve_elector),13,2) WHERE numcte=TRIM(cNumcte);
			END IF;
		END IF;
	END FOREACH;

	RETURN cCodRet,IidErr;
END
END PROCEDURE;