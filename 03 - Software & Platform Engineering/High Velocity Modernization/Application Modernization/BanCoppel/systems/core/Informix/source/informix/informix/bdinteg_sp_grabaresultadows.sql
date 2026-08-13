CREATE PROCEDURE "informix".sp_grabaresultadows (
                                                pOrigenTicket       CHAR(1),
                                                pEstatus            CHAR(1),
                                                pNumCte             CHAR(20),
                                                pTicket             CHAR(50),
                                                pDescripcion        CHAR(50),
                                                pMatchResult        SMALLINT,
                                                pNumMatchResult     SMALLINT,
                                                pNumCteMatch1       CHAR(20),
                                                pEmpresaMatch1      CHAR(1),
                                                pSitEspMatch1       CHAR(1),
                                                pPorcMatch1         CHAR(20),
                                                pNumCteMatch2       CHAR(20),
                                                pEmpresaMatch2      CHAR(1),
                                                pSitEspMatch2       CHAR(1),
                                                pPorcMatch2         CHAR(20),
                                                pNumCteMatch3       CHAR(20),
                                                pEmpresaMatch3      CHAR(1),
                                                pSitEspMatch3       CHAR(1),
                                                pPorcMatch3         CHAR(20),
                                                pNumCteMatch4       CHAR(20),
                                                pEmpresaMatch4      CHAR(1),
                                                pSitEspMatch4       CHAR(1),
                                                pPorcMatch4         CHAR(20),
                                                pNumCteMatch5       CHAR(20),
                                                pEmpresaMatch5      CHAR(1),
                                                pSitEspMatch5       CHAR(1),
                                                pPorcMatch5         CHAR(20),
                                                pNumCteMatch6       CHAR(20),
                                                pEmpresaMatch6      CHAR(1),
                                                pSitEspMatch6       CHAR(1),
                                                pPorcMatch6         CHAR(20),
                                                pNumCteMatch7       CHAR(20),
                                                pEmpresaMatch7      CHAR(1),
                                                pSitEspMatch7       CHAR(1),
                                                pPorcMatch7         CHAR(20),
                                                pNumCteMatch8       CHAR(20),
                                                pEmpresaMatch8      CHAR(1),
                                                pSitEspMatch8       CHAR(1),
                                                pPorcMatch8         CHAR(20),
                                                pNumCteMatch9       CHAR(20),
                                                pEmpresaMatch9      CHAR(1),
                                                pSitEspMatch9       CHAR(1),
                                                pPorcMatch9         CHAR(20),
                                                pNumCteMatch10      CHAR(20),
                                                pEmpresaMatch10     CHAR(1),
                                                pSitEspMatch10      CHAR(1),
                                                pPorcMatch10        CHAR(20),
                                                pCodResult          CHAR(3)
                                                )																
--DATOS A REGRESAR---
RETURNING             	
	CHAR(5) 	AS CodRet,
	CHAR(50) 	AS Descripcion;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_grabaresultadows "
Folio.........: 712.2 - EnvÃ­o de decÃ¡logo de huellas.
Autor.........: 99802161 - Narciso Ivan Cisneros Acosta
Fecha.........: 05/07/2021
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
VersiÃ³n.......: 20/08/2021
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet		CHAR(5);
DEFINE cDescripcion	CHAR(50);
DEFINE iSqlErr		INTEGER;


-- SET DEBUG FILE TO '/home/sysifx/sp_grabaresultadows.out';
-- TRACE ON;

-- LET CURRENT			= TO_CHAR(CURRENT, '%m/%d/%Y %H:%M:%S');
-- INICIALIZACION DE VARIABLE.
LET cCodRet			= '00000';
LET cDescripcion	= '';
LET iSqlErr			= 0;
LET pTicket			=TRIM(pTicket);

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodret,cDescripcion;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	IF (NVL(pOrigenTicket,'')<> '') THEN	
		IF EXISTS (SELECT ticket FROM "informix".si_rostro_linea WHERE ticket=pTicket) THEN
			LET cDescripcion = 'exito';
			UPDATE "informix".si_rostro_linea
			SET 
			fecha_result = CURRENT,
			status_result = pEstatus,
			desc_result = pDescripcion,
			match_result = pMatchResult,
			num_match_result = pNumMatchResult,
			codret_result = pCodResult,
			origen_result = pOrigenTicket,
			status_consulta = '3'
			WHERE ticket = pTicket;
			IF (NVL(pNumCteMatch1,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch1, pEmpresaMatch1, pSitEspMatch1, pPorcMatch1, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
			
			IF (NVL(pNumCteMatch2,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch2, pEmpresaMatch2, pSitEspMatch2, pPorcMatch2, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
			
			IF (NVL(pNumCteMatch3,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch3, pEmpresaMatch3, pSitEspMatch3, pPorcMatch3, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
			
			IF (NVL(pNumCteMatch4,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch4, pEmpresaMatch4, pSitEspMatch4, pPorcMatch4, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
			
			IF (NVL(pNumCteMatch5,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch5, pEmpresaMatch5, pSitEspMatch5, pPorcMatch5, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
			
			IF (NVL(pNumCteMatch6,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch6, pEmpresaMatch6, pSitEspMatch6, pPorcMatch6, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
			
			IF (NVL(pNumCteMatch7,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch7, pEmpresaMatch7, pSitEspMatch7, pPorcMatch7, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
			
			IF (NVL(pNumCteMatch8,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch8, pEmpresaMatch8, pSitEspMatch8, pPorcMatch8, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
			
			IF (NVL(pNumCteMatch9,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch9, pEmpresaMatch9, pSitEspMatch9, pPorcMatch9, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
			
			IF (NVL(pNumCteMatch10,'')<> '') THEN
				INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, Fecha_insert,origen_result,num_match_result)
				VALUES (pTicket, pNumCteMatch10, pEmpresaMatch10, pSitEspMatch10, pPorcMatch10, CURRENT,pCodResult,pNumMatchResult); 
			END IF;
		ELSE
			LET cCodRet = '00001';
			LET cDescripcion = 'ticket no existe: '|| pTicket;
		END IF;	
	ELSE
			LET cCodRet = '00002';
			LET cDescripcion = 'origen ticket no especificado';
	END IF;
	RETURN cCodret, cDescripcion;
END;
END PROCEDURE;