CREATE PROCEDURE "informix".sp_sitespecialbiofacial(pNumcte CHAR(20), pticket CHAR(50), pSistema CHAR(1))
RETURNING             	
	CHAR(5)  AS CODIGO,
	CHAR(20) AS CLIENTE,
	CHAR(1)  AS SITUACION,
	SMALLINT AS CAUSA;
--**********************************************
--*pSistema = C (Se ejecuta desde caja.)       *
--*pSistema = P (Se ejecuta desde Plataforma.) *
--*pSistema = B (Se ejecuta desde Batch.)	   *
--**********************************************
--Definicion de Variables
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr 			INTEGER;
DEFINE cNumCte			CHAR(20);
DEFINE cCteTicket		CHAR(20);
DEFINE cSituacionCte 	CHAR(1);
DEFINE sCausaCte 		SMALLINT;
DEFINE cStatusres		CHAR(1);
DEFINE cMatch			SMALLINT;
DEFINE cSucursal		CHAR(4); 
DEFINE cNumUsr			CHAR(8);
DEFINE cNomEmp			CHAR(50);
DEFINE cEmpresa			CHAR(3);
DEFINE cPonderacion		SMALLINT;
DEFINE iIdMvtoHis		INTEGER;
DEFINE cNumMatchRes		SMALLINT;
DEFINE sStatusConsulta	CHAR(1);
DEFINE cTicket			CHAR(50);

--Inicializacion de Variables
LET cCodRet    		= '00001';
LET iSqlErr 		= 0;
LET cNumCte 		= "";
LET cCteTicket 		= "";
LET cSituacionCte 	= "";
LET sCausaCte 		= 0;
LET cStatusres		= "";
LET cMatch          = 0;
LET cSucursal		= "";
LET cNumUsr			= "";
LET cNomEmp			= "";
LET cEmpresa 		= "";
LET cPonderacion	= 0;
LET iIdMvtoHis 		= 0;
LET cNumMatchRes	= 0;
LET sStatusConsulta = "";
LET cTicket			= "";


--SET DEBUG FILE TO '/informix/jfponce/gabriel/RQI63925MejorasalprocesodemarcajeR2/SP_PRODUCTIVOS_PRUEBAS_26_SEP/sp_sitespecialbiofacial.out'; 
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumcte, cSituacionCte, sCausaCte;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF UPPER(pSistema) ="C" THEN
		FOREACH
			SELECT numcte, situacion, causa 
			INTO cNumcte, cSituacionCte, sCausaCte
			FROM "informix".se_ctessitespcte 
			WHERE numcte = pNumCte
		END FOREACH
			
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cNumcte 		= "";
			LET cSituacionCte 	= "";
			LET sCausaCte 		= "";
		END IF;
			
		LET cCodRet = "00000";
		RETURN  cCodRet, cNumcte, cSituacionCte, sCausaCte WITH RESUME;
	END IF;
	
	IF NVL(pticket, '') = "" AND UPPER(pSistema) ="P" THEN
		--CONSULTA (PLATAFORMA).
		SELECT numcte, situacion, causa 
		INTO cNumcte, cSituacionCte, sCausaCte
		FROM "informix".se_ctessitespcte 
		WHERE numcte = pNumCte;
			
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cNumcte 		= "";
			LET cSituacionCte 	= "";
			LET sCausaCte 		= "";
		END IF;
		
		--EVALUAR BIOMETRIA DUPLICADA.
		IF cSituacionCte = "R" AND (sCausaCte = "1" OR sCausaCte = "2")  THEN
			LET cCodRet = "00000";
			RETURN  cCodRet, cNumcte, cSituacionCte, sCausaCte WITH RESUME;
		ELSE
			
			IF EXISTS (SELECT * FROM bdinteg:"informix".si_rostro_linea WHERE numcte = pNumcte) THEN

				SELECT cte.empresa, cte.numcte, cte.sucursal, cte.usuario, r.status_consulta, r.match_result, r.num_match_result, r.ticket
				INTO cEmpresa, cNumcte, cSucursal, cNumUsr, sStatusConsulta, cMatch, cNumMatchRes, cTicket
				FROM bdinteg:"informix".si_rostro_linea AS r
				INNER JOIN bdirostros@coppelimg_tcp:"informix".si_cte_rostro As cte ON r.numcte = cte.numcte AND cte.secuencia = 1 AND cte.estado = 'A'
				WHERE r.numcte = pNumcte
				AND r.secuencia = (select max(secuencia) from bdinteg:"informix".si_rostro_linea where numcte = pNumcte);
				
				select nombre into cNomEmp
				from bdinteg:"informix".si_ejecut
				where ejecutivo = cNumUsr;
				
				LET cNomEmp = NVL(cNomEmp, '');
		
				IF sStatusConsulta = "3" AND cMatch >= 1 THEN
				
					SELECT limit 1 num_match_result
					INTO cNumMatchRes
					FROM bdinteg:"informix".si_rostro_linea_result
					WHERE ticket = cTicket AND numcte_match <> pNumcte AND empresa_match=1;
					
					IF dbinfo("sqlca.sqlerrd2") <> 0 THEN 
						EXECUTE PROCEDURE "informix".sp_insertasitesp (1, cEmpresa, pNumcte, 'R', '2', '1', 'S',cSucursal, cNumUsr, cNomEmp, '','') 
						INTO cCodRet, cPonderacion, cSituacionCte, sCausaCte;
					END IF

				ELIF sStatusConsulta = "2" THEN
				
					EXECUTE PROCEDURE "informix".sp_insertasitesp (1, cEmpresa, pNumcte, 'R', '1', '1', 'S',cSucursal, cNumUsr, cNomEmp, '','') 
					INTO cCodRet, cPonderacion, cSituacionCte, sCausaCte;
			
				END IF;
				
				LET cCodRet = "00000";
				RETURN  cCodRet, cNumcte, cSituacionCte, sCausaCte WITH RESUME;
				ELSE
					LET cCodRet = "00000";
					RETURN cCodRet, cNumCte, cSituacionCte, sCausaCte WITH RESUME;
			END IF;
		END IF;
	ELIF NVL(pticket, '') <> "" AND UPPER(pSistema) ="B" THEN
		--BATCH(PARA CLIENTES NO COMPARADOS EN LINEA).
		SELECT situacion, causa, numcte 
		INTO cSituacionCte, sCausaCte, cNumcte
		FROM "informix".se_ctessitespcte
		WHERE numcte = (SELECT numcte FROM bdinteg:"informix".si_rostro_linea WHERE ticket = pticket);
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cNumcte 		= "";
			LET cSituacionCte 	= "";
			LET sCausaCte 		= "";
		END IF;		

		IF cSituacionCte = "R" AND sCausaCte = "1" THEN

			SELECT cte.empresa, cte.numcte, cte.sucursal, cte.usuario, r.status_consulta, r.match_result, r.num_match_result
			INTO cEmpresa, cNumcte, cSucursal, cNumUsr, sStatusConsulta, cMatch, cNumMatchRes
			FROM bdinteg:"informix".si_rostro_linea AS r
			INNER JOIN bdirostros@coppelimg_tcp:"informix".si_cte_rostro As cte ON r.numcte = cte.numcte AND cte.secuencia = 1 AND cte.estado = 'A'
			WHERE r.numcte = cNumcte
			AND r.ticket = pticket;
			
			select nombre into cNomEmp
			from bdinteg:"informix".si_ejecut
			where ejecutivo = cNumUsr;
			
			LET cNomEmp = NVL(cNomEmp, '');
	
			IF sStatusConsulta = "3" AND cMatch >= 1 THEN
			
				SELECT limit 1 num_match_result
				INTO cNumMatchRes
				FROM bdinteg:"informix".si_rostro_linea_result
				WHERE ticket = pticket AND numcte_match <> cNumcte AND empresa_match=1;

				IF dbinfo("sqlca.sqlerrd2") <> 0 THEN 
					EXECUTE PROCEDURE "informix".sp_insertasitesp (1, cEmpresa, cNumcte, 'R', '2', '1', 'S',cSucursal, cNumUsr, cNomEmp, '','')
					INTO cCodRet, cPonderacion, cSituacionCte, sCausaCte;
				ELSE
					SELECT MAX(idmovto)+1
					INTO iIdMvtoHis
					FROM "informix".se_ctessitespcte_his;
					
					INSERT INTO "informix".se_ctessitespcte_his
					SELECT iIdMvtoHis, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica
					FROM "informix".se_ctessitespcte
					WHERE numcte= cNumcte
					AND situacion = cSituacionCte
					AND causa = sCausaCte;
				
					UPDATE "informix".se_ctessitespcte 
					SET situacion = 'U', causa = '65', usrmodifica = cNumUsr, fchmodifica = CURRENT
					WHERE numcte = cNumcte
					AND situacion = cSituacionCte
					AND causa = sCausaCte;

					SELECT numcte, situacion, causa 
					INTO cNumcte, cSituacionCte, sCausaCte
					FROM "informix".se_ctessitespcte 
					WHERE numcte = cNumcte;
					
				END IF
		
			ELIF sStatusConsulta = "3" AND cMatch = 0 THEN

				SELECT MAX(idmovto)+1
				INTO iIdMvtoHis
				FROM "informix".se_ctessitespcte_his;
				
				INSERT INTO "informix".se_ctessitespcte_his
				SELECT iIdMvtoHis, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica
				FROM "informix".se_ctessitespcte
				WHERE numcte= cNumcte
				AND situacion = cSituacionCte
				AND causa = sCausaCte;

				UPDATE "informix".se_ctessitespcte 
				SET situacion = 'U', causa = '65', usrmodifica = cNumUsr, fchmodifica = CURRENT
				WHERE numcte = cNumcte
				AND situacion = cSituacionCte
				AND causa = sCausaCte;
				
				SELECT numcte, situacion, causa 
				INTO cNumcte, cSituacionCte, sCausaCte
				FROM "informix".se_ctessitespcte 
				WHERE numcte = cNumcte;
				
			END IF;
		END IF;
			
		LET cCodRet = "00000";
		--RETURN  cCodRet, cNumcte, cSituacionCte, sCausaCte WITH RESUME;
		RETURN  cCodRet, cNumcte, cSituacionCte, sCausaCte;
			
	END IF;
END;

END PROCEDURE
