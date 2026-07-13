CREATE PROCEDURE "informix".sp_dicta_validaponderacion_sitespcte (pCteNvo		CHAR(20), 	--CLIENTE NUEVO
																   pSitNvo		CHAR(1), 	--SITUACION CTE NUEVO
																   pCausaNvo	SMALLINT,	--CAUSA	CTE NUEVO
																   pCteMatch	CHAR(20), 	--CLIENTE COINCIDENCIA (MATCH)
																   pSitMatch	CHAR(1),	--SITUACION MATCH
																   pCausaMatch	SMALLINT,	--CAUSA MATCH
																   pOrigenMatch	CHAR(4),	--EMPRESA (COPPEL,BANCOPPEL,EMPLEADO, EXEMPLEADO)
																   pActivo		SMALLINT, 	--EMPLEADO 0-ACTIVO O 1-INACTIVO.
																   pBandera     SMALLINT,	--BANDERA (1 MISMA PERSONA 2 DISTINTA PERSONA 3 FRAUDE 4 NO ES POSIBLE DICTAMINAR EL CLIENTE)
																   pSucursal	CHAR (4),
																   pOperador	CHAR (8)) 	--EJECUTIVO
RETURNING CHAR(6) AS 	CodRet,
          CHAR(1) AS 	Situacion,
          SMALLINT AS 	Causa,
          SMALLINT AS  	Parentesco;

	--DECLARACION DE VARIABLES.
	DEFINE cCodRet		CHAR (6);
	DEFINE iSqlErr		INTEGER;
	DEFINE cCteRef		CHAR(20);
	DEFINE cSitFin		CHAR(1);
	DEFINE sCausaFin	SMALLINT;
	DEFINE sParentesco	SMALLINT;
	DEFINE sPondeMATCH	SMALLINT;
	DEFINE sPondeNvo	SMALLINT;
	DEFINE sPondeSitEsp	SMALLINT;
	DEFINE sBand		SMALLINT;
	
	--INICIALIZACION DE VARIABLES.
	LET cCodRet		= '000000';
	LET iSqlErr		= 0;
	LET cCteRef		= '';
	LET cSitFin		= '';
	LET sCausaFin	= 0;
	LET sParentesco	= 0;
	LET sPondeMATCH	= 0;
	LET sPondeNvo	= 0;
	LET sPondeSitEsp	= 0;
	LET sBand		= 0;
	
	--SET DEBUG FILE TO '/informix/jfponce/gabriel/RQI63966/sp_dicta_validaponderacion_sitespcte.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(cCodRet),NVL(cSitFin,''),NVL(sCausaFin,0),NVL(sParentesco,0);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDACION DE PARAMETROS.
		IF NVL(pCteNvo,'')='' OR NVL(pSitNvo,'')='' OR NVL(pCausaNvo,0)=0 OR NVL(pCteMatch,'')='' OR NVL(pOrigenMatch,'')='' OR NVL(pBandera,0)=0 THEN
			LET cCodRet		= '000001';
			
		--VALIDACION DE EMPRESAS.
		ELIF TRIM(pOrigenMatch)NOT IN ('0','1','2','3','4','5') THEN
			LET cCodRet		= '000002';
		
		--VALIDA DICTAMEN DEL ANALISTA SI ES LA MISMA PERSONA, DISTINTA PERSONA O CLIENTE FRAUDE.
		ELIF pBandera NOT IN (1,2,3,4) THEN
			LET cCodRet		= '000003';
		
		--VALIDA LA BANDERA DE EMPLEADO O EXEMPLEADO
		ELIF NVL(pActivo,0) NOT IN (0,1) THEN -- 0 = ACTIVO 1 = INACTIVO
			LET cCodRet		= '000004';
		
		--VALIDA EL PARAMETRO STATUS QUE NO VENGA VACIO O NULL DONDE SE NECESITA.
		ELIF pOrigenMatch = 4 AND NVL(psucursal,'') = '' THEN 
			LET cCodRet		= '000005';
		END IF;

		--VALIDA SI NO ENTRO EN ALGUNA DE LAS VALIDACIONES ANTERIORES.
		IF cCodRet::INTEGER <> 0 THEN
			RETURN TRIM(cCodRet),NVL(cSitFin,''),NVL(sCausaFin,0),NVL(sParentesco,0);
		END IF;
		
		IF pCausaMatch = 27 AND NVL(pSitMatch,'')= '' AND pActivo = 1 AND pOrigenMatch IN (0,1,2,3) THEN
			LET pCausaMatch = 29;
			LET pSitMatch   = 'P';
		END IF;

		--OBTIENE PONDERACION CLIENTE NUEVO
		SELECT ponderacion
		INTO sPondeNvo
		FROM bdisitesp:"informix".se_catsitesp
		WHERE situacion = pSitNvo
		AND causa = pCausaNvo;
		
		--OBTIENE PONDERACION CLIENTE MATCH
		SELECT ponderacion
		INTO sPondeMATCH
		FROM bdisitesp:"informix".se_catsitesp
		WHERE situacion = pSitMatch
		AND causa = pCausaMatch;
		
		

		--*************** EMPLEADO Y EXEMPLEADOS GRUPO COPPEL ****************
		IF TRIM(pOrigenMatch) IN ('0','1','2','3')  AND pBandera IN (1,2) THEN 	
			
		-- <<<<EMPLEADO GRUPO COPPEL>>>>
			IF NVL(pActivo,0) = 0 THEN 
				IF pBandera = 1 THEN -- MISMA PERSONA.
					LET cSitFin		= 'P';
					LET sCausaFin	= 23;
				ELIF pBandera = 2 THEN -- DISTINTA PERSONA.
					LET cSitFin		= 'U';
					LET sCausaFin	= 65;
				END IF;
								
				
				

		-- <<<<EX-EMPLEADO GRUPO COPPEL>>>>
			ELIF pActivo = 1 THEN 
				-- VALIDA SI ES EX-EMPLEADO BANCOPPEL PARA BUSCAR EN LA TABLA DE LISTA NEGRA.
				IF TRIM(pOrigenMatch) = '2' THEN 
					IF NOT EXISTS (SELECT (numcte) FROM bdiauditor:"informix".tbl_listainterna WHERE numcte = TRIM(pCteMatch))THEN
						LET sBand = 0;  -- DESACTIVA BANDERA.
					ELSE
						LET sBand = 1; -- SE ACTIVA BANDERA.
					END IF;
				END IF;
				
				-- MISMA PERSONA BANDERA ENCENDIDA Y EX EMPLEADO BANCO.
				IF pBandera = 1 AND sBand = 1 AND TRIM(pOrigenMatch) = '2' THEN 
						SELECT ponderacion
						INTO sPondeSitEsp
						FROM bdisitesp:"informix".se_catsitesp
						WHERE situacion = 'U'
						AND causa = 60;
						
						--SE VALIDA SI LA PODERACION DEL CTENUEVO ES DE MENOR O IGUAL PESO A LA PONDERACION DE CTE LISTA NEGRA
						IF sPondeNvo >= sPondeSitEsp THEN 
							LET cSitFin		= 'U';
							LET sCausaFin	= 60;
						ELSE 
							LET cSitFin		= pSitNvo;
							LET sCausaFin	= pCausaNvo;
						END IF;
						
				--MISMA PERSONA BANDERA APAGADA Y EX-EMPLEADO DE OTRA EMPRESA.		
				ELIF pBandera = 1 AND TRIM(pOrigenMatch) IN ('0','1','2','3') AND sBand = 0 THEN 
					IF ((pSitMatch||'-'||pCausaMatch) = 'P-29') THEN
						--SE VALIDA SI LA PONDERACION DEL CTENVO ES DE MENOR PESO DE LA PONDERACION CTEMATCH
						IF sPondeNvo >= sPondeMATCH THEN 
							LET cSitFin		= 'P';
							LET sCausaFin	= 29;
						ELIF sPondeNvo <= sPondeMATCH THEN 
							LET cSitFin		= pSitNvo;
							LET sCausaFin	= pCausaNvo;
						END IF;
					ELSE
						--SE VALIDA SI LA PONDERACION DEL CTENVO ES DE MENOR PESO DE LA PONDERACION CTEMATCH
						IF sPondeNvo >= sPondeMATCH THEN 
							LET cSitFin		= pSitMatch;
							LET sCausaFin	= pCausaMatch;
						ELIF sPondeNvo <= sPondeMATCH THEN 
							LET cSitFin		= pSitNvo;
							LET sCausaFin	= pCausaNvo;
						END IF;
					END IF;
					
				--SI ES DISTINTA PERSONA.
				ELIF pBandera = 2 THEN
					LET cSitFin		= 'U';
					LET sCausaFin	= 65;
				END IF;
				
				--CUANDO LA SITUACION ESPECIAL DEL CLIENTE MATCH ESTE VACIA O NULL.
				IF NVL(pSitMatch,'') = '' AND NVL(pCausaMatch,0) = 0 AND NVL(cSitFin,'') = '' and NVL(sCausaFin,0) = 0 THEN
				
					LET cSitFin		= 'U';
					LET sCausaFin	= 65;
					
				END IF;
			END IF;
		




		--***********************CLIENTE COPPEL********************************	
			
		ELIF TRIM(pOrigenMatch) = '4' AND pBandera IN (1,2) THEN
			
			-- MISMA PERSONA.
			IF pBandera = 1 THEN 
			
			-- SE OBTIENE EL NUMCTE_REF DE LA TABLA SI_CLIENTE PARA COMPARALO CON EL CTE QUE HIZO MATCH
				SELECT numcte_ref
				INTO cCteRef
				FROM "informix".si_cliente
				WHERE numcte = TRIM(pCteNvo);
				
				--SI LA REFERENCIA ES DIFERENTE O VIENE VACIA SE REALIZA EL INSERT EN LA TABLA DE SI_BITACORA_CTES_REL
				-- Y SE ACTUALIZARA EL CAMPO NUMCTE_REF DE LA TABLA SI_CLIENTE CON EL NUMERO DE CLIENTE MATCH
				IF TRIM(NVL(cCteRef,''))<> TRIM(pCteMatch)THEN
					
					--ACTUALIZA EL NUMERO DE REFERENCIA DE LA TABLA si_cliente
					UPDATE "informix".si_cliente SET numcte_ref = TRIM(pCteMatch)WHERE numcte = TRIM(pCteNvo);
				
					--SE VALIDA SI EL NUMCTE_REF DE LA SI_CLIENTE VIENE VACIA, LO LLENA CON EL PCTEMATCH PARA REALIZAR EL INSERT.
					IF TRIM(NVL(cCteRef,''))= '' THEN
						LET cCteRef = TRIM(pCteMatch);
						LET pCteMatch = '';
					END IF;
					
					--INSERTA REGISTRO EN LA TABLA si_bitacora_ctes_rel
					INSERT INTO "informix".si_bitacora_ctes_rel (numcte,numcte_ref,numcte_ref_coinc,sucursal,numemp,fecha_insert) 
					VALUES (TRIM(pCteNvo),TRIM(cCteRef),TRIM(pCteMatch),pSucursal,TRIM(pOperador),CURRENT);
					
				END IF;
				
				--VALIDA SU SITUACION Y CAUSA O SU PONDERACION.
				IF pSitNvo = 'U' AND pCausaNvo = 62 THEN
						LET cSitFin		= 'U';
						LET sCausaFin	= 65;
				ELSE
					--VALIDARE LA DE MAS PESO
					IF sPondeNvo >= sPondeMATCH THEN 
						LET cSitFin		= pSitMatch;
						LET sCausaFin	= pCausaMatch;
					ELSE
						LET cSitFin		= pSitNvo;
						LET sCausaFin	= pCausaNvo;
					END IF;		
				END IF;
				
			-- DISTINTA PERSONA.
			ELIF pBandera = 2 THEN 
				IF pSitNvo = 'U' AND pCausaNvo = 62 THEN
					LET cSitFin		= 'U';
					LET sCausaFin	= 65;
				ELSE 
					LET cSitFin		= pSitNvo;
					LET sCausaFin	= pCausaNvo;
				END IF;
			END IF;
			
			

	--*******************CLIENTE BANCOPPEL *************************
		ELIF TRIM(pOrigenMatch) = '5' AND pBandera IN (1,2,3) THEN	 
			
			-- MISMA PERSONA.	
			IF pBandera = 1 THEN					
				LET sParentesco	= 0;
				
				--SI EL CLIENTE ESTA EN SIT-ESP P-35 (CLIENTE REESTRUCTURADO) O T-97 (CRÃÂDITO IRRECUPERABLE VENDIDO)
				-- SE ACTUALIZARA LA SITUACION ESPECIAL U-3 
				IF (pSitMatch||'-'||pCausaMatch) IN ('P-35','T-97')THEN
					LET cSitFin		= 'U';
				    LET sCausaFin	= 3;
					
				-- SI EL CLIENTE MATCH TIENE SITUACION U-60 
				ELIF (pSitMatch||'-'||pCausaMatch) = 'U-60' THEN
				
				--SE COMPARA LA PONDERACION DEL CLIENTE NUEVO SI ES DE MAYOR PESO SE DEJA LA QUE TIENE EL CLIENTE NUEVO.
					IF sPondeNvo <= sPondeMATCH THEN
						LET cSitFin		= pSitNvo;
					    LET sCausaFin	= pCausaNvo;
						
				-- SI LA PONDERACION DEL CLIENTE MATCH ES MAYOR QUE LA PONDERACION DEL CLIENTE NUEVO SE PONDRA LA SITUACION
				-- ESPECIAL U-59 (HUELLA DUPLICADA CON LISTA NEGRA).
					ELIF sPondeNvo > sPondeMATCH THEN
						LET cSitFin		= 'U';
					    LET sCausaFin	= 59;
					END IF;
				
				-- SI LA SITUACION ESPECIAL ES F-42 (CLIENTE FALLECIDO).
				ELIF (pSitMatch||'-'||pCausaMatch) = 'F-42' THEN
				
				-- SI LA PONDERACION DEL CLIENTE NUEVO ES = O MAYOR A LA DEL CLIENTE FALLECIDO SE DEJARA LA DEL CTE NUEVO
					IF sPondeNvo <= sPondeMATCH THEN
						LET cSitFin		= pSitNvo;
					    LET sCausaFin	= pCausaNvo;
						
				-- SI LA PONDERACION DEL CLIENTE MATCH ES MAYOR A LA DE CLIENTE NUEVO SE ACTUALIZARA SU SITUACION ESPECIAL
				-- CON U-59 (PRESUNTO CLIENTE FALLECIDO)
					ELIF sPondeNvo > sPondeMATCH THEN
						LET cSitFin		= 'F';
					    LET sCausaFin	= 43;
					END IF;
					
				-- SI LA SITUACION DEL CTE MATCH ESTA EN U-62 (CLIENTE PENDIENTE DE DICTAMEN.) O U-65 (INFORMATIVA PARA INDICAR QUE YA FUE REVISADO EL CLIENTE) SE DEJARA LA SITUACION ESPECIAL DEL CLIENTE NUEVO.
				ELIF (pSitMatch||'-'||pCausaMatch) IN ('U-62','U-65') THEN
					-- LET cSitFin		= pSitNvo;
					-- LET sCausaFin	= pCausaNvo;
					LET cSitFin		= 'U';
				    LET sCausaFin	= 3;
					
				ELSE
					-- SI NO ENTRA EN NI UNA VALIDACION ANTERIOR SOLO SE VALIDARAN LAS PONDERACIONES
					-- SI LA PONDERACION DEL CTE MATCH ES MAYOR A LA DEL CTE NUEVO SE ACTUALIZARA CON LA SIT ESP DEL CTE MATCH DE LO CONTRARIO PONDRA LA SITUACION U-65 (INFORMATIVA PARA INDICAR QUE YA FUE REVISADO EL CLIENTE).
					IF sPondeNvo >= NVL(sPondeMATCH,0) THEN
						LET cSitFin		= pSitMatch;
					    LET sCausaFin	= pCausaMatch;
					Else 
						LET cSitFin		= 'U';
						LET sCausaFin	= 65;
					END IF;
				END IF;
				
				--VALIDA SI SE MANDA LA PREGUNTA DE CORRECCION DE DATOS.
				IF (pSitMatch||'-'||pCausaMatch) IN ('U-62','T-97','U-65')THEN
					LET cCodRet		= '000100';
				END IF;				
				
			-- DISTINTA PERSONA.
			ELIF pBandera = 2 THEN 
			
				--VALIDAR PARENTESCO
				IF NOT EXISTS (SELECT {+INDEX("informix".si_refclientes idx_si_refclientes1)} numcte FROM "informix".si_refclientes  WHERE numcte = TRIM(pCteMatch) AND empresa = '001' AND parentesco IN ('P','J')) THEN
					LET sParentesco	= 1;
				ELSE 
					LET sParentesco	= 0;
				END IF;
				
				-- VALIDA SI EL CTE NUEVO ESTA CON SITESP U-62 (CLIENTE PENDIENTE DE DICTAMEN.) SE ACTUALIZARA CON LA SITESP U-65 (INFORMATIVA PARA INDICAR QUE YA FUE REVISADO EL CLIENTE).
				IF pSitNvo = 'U' AND pCausaNvo = 62 THEN
					LET cSitFin		= 'U';
					LET sCausaFin	= 65;
				
				-- SI LA SITESP DEL CTE NUEVO ES DISTINTA A U-62.
				ELSE 
					-- SE OBTIENE LA PONDERACION DE LA SITESP P-108 (CLIENTE FRAUDULENTO).
					SELECT ponderacion
					INTO sPondeSitEsp
					FROM bdisitesp:"informix".se_catsitesp
					WHERE situacion = 'P'
					AND causa = 108;
					
					-- SI LA PONDERACION DE LA SITESP P-108 ES MENOR A LA DEL CTE NUEVO SE DEJARA LA SITESP DEL CTE NUEVO
					IF sPondeNvo < sPondeSitEsp THEN
						LET cSitFin		= pSitNvo;
						LET sCausaFin	= pCausaNvo;
					
					-- DE LO CONTRARIO SE ACTUALIZARA CON LA SITESP U-65(INFORMATIVA PARA INDICAR QUE YA FUE REVISADO EL CLIENTE).
					ELSE
						LET cSitFin		= 'U';
					    LET sCausaFin	= 65;
					END IF;
				END IF;
				
				
				-- CLIENTE FRAUDE.
			ELIF pBandera = 3 THEN 
				--RQM 11 187 Clientes situacion especial P-108 
				--CLIENTE SE ACTUALIZA CON LA SITUACION ESPECIAL P-108 (FRAUDE)			
				LET cSitFin		= 'P';
				LET sCausaFin	= 108;
			END IF;
				--LET sParentesco	= 0;				
				--VALIDA SI EL CTE NUEVO ESTA CON SITUACION ESPECIAL U-62 SE ACTUALIZARA CON LA SITUACION ESPECIAL U-3 (HUELLA DUPLICADA)
				/*IF (pSitNvo||'-'||pCausaNvo) = 'U-62' THEN
					LET cSitFin		= 'U';
					LET sCausaFin	= 3;					
					
				--SE VALIDA SI LA PODERACION DEL CTEMATCH ES MENOR O IGUAL A LA PONDERACION DE CTE FRAUDE
				 ELSE
					--SE TOMA PONDERACION DE CLIENTE FRAUDE.
					SELECT ponderacion
					INTO sPondeSitEsp
					FROM bdisitesp:"informix".se_catsitesp
					WHERE situacion = 'P'
					AND causa = 108;				
					
					-- VALIDA QUE LA PONDERACION DEL CLIENTE MATCH TIENE MAYOR PESO QUE LA DEL CLIENTE NUEVO
					IF (sPondeNvo <= sPondeMATCH) OR sPondeMATCH = 0 THEN
					
						--VALIDA QUE LA PONDERACION DEL CLIENTE MATCH SEA MENOR A LA PONDERACION DE CLIENTE FRAUDE (P-108)
						IF (sPondeSitEsp <= sPondeMATCH) OR sPondeMATCH = 0 THEN 
							LET cSitFin		= 'P';
							LET sCausaFin	= 108;
							
						-- DE LO CONTRARIO SE DEJARA LA SITUACION ESPECIAL DEL CLIENTE MATCH
						ELSE 
							LET cSitFin		= pSitMatch;
							LET sCausaFin	= pCausaMatch;
						END IF;
						
					-- LA PONDERACION DEL CLIENTE NUEVO TIENE MAYOR PESO QUE LA PONDERACION DEL CLIENTE MATCH
					ELSE
					
						-- VALIDA QUE LA PONDERACION DEL CLIENTE NUEVO SEA MENOR A LA PONDERACION DE CLIENTE FRAUDE (P-108)
						IF sPondeSitEsp <= sPondeNvo THEN 
							LET cSitFin		= 'P';
							LET sCausaFin	= 108;
							
						-- DE LO CONTRARIO SE DEJARA LA SITUACION ESPECIAL DEL CLIENTE NUEVO
						ELSE 
							LET cSitFin		= pSitNvo;
							LET sCausaFin	= pCausaNvo;
						END IF;
					END IF;
				END IF;
			END IF;*/
			--CUANDO EL CLIENTE MATCH VIENE CON LA SITUACION ESPECIAL VACIA O NULL.
			/*IF NVL(pSitMatch,'') = '' AND NVL(pCausaMatch,0) = 0 AND NVL(cSitFin,'') = '' and NVL(sCausaFin,0) = 0 THEN
				-- DISTINTA PERSONA.
				IF pBandera = 2 THEN
						LET cSitFin		= 'U';
						LET sCausaFin	= 65;
				
				-- MISMA PERSONA.
				ELIF pBandera = 1 THEN
				
					-- LET cSitFin		= pSitNvo;
					-- LET sCausaFin	= pCausaNvo;
					LET cSitFin		= 'U';
					LET sCausaFin	= 3;
					
				
				-- CLIENTE FRAUDE
				ELIF pBandera = 3 THEN
					IF sPondeNvo >= sPondeSitEsp  THEN 
						LET cSitFin		= 'P';
						LET sCausaFin	= 108;
							
					-- DE LO CONTRARIO SE DEJARA LA SITUACION ESPECIAL DEL CLIENTE NUEVO
					ELSE 
						LET cSitFin		= pSitNvo;
						LET sCausaFin	= pCausaNvo;
					END IF;
				END IF;
			END IF*/

		--**********************NO ES POSIBLE DICTAMINAR EL CLIENTE**********************
		ELIF pBandera = 4 THEN
			LET cSitFin		= 'U';
			LET sCausaFin	= 66;
		
		--SI NO ENTRA A NI UNA VALIDACION ANTERIOR SE RETORNARA LA SITUACION ESPECIAL U-65 (INFORMATIVA PARA INDICAR QUE YA FUE REVISADO EL CLIENTE).
		ELSE
			LET cSitFin		= 'U';
			LET sCausaFin	= 65;
		END IF;
		
		-- VALIDA EL CODIGO DE RETORNO SI NO ESTA EN '000000' (EXITOSO), O '000100' (EXITO CON MENSAJE SI EL CLIENTE PRESENTA ERRORES)
		IF cCodRet::INTEGER NOT IN (0,100)THEN
			LET cSitFin		= '';
			LET sCausaFin	= 0;
			LET sParentesco	= 0;
		END IF;
		
		RETURN TRIM(cCodRet),NVL(cSitFin,''),NVL(sCausaFin,0),NVL(sParentesco,0);	
	
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Validara las ponderaciones del cliente nuevo con el cliente match para asignar la de mayor peso.',
'AUTOR: Mario Olivo',   
'FECHA DE CREACION: 07 de NOVIEMBRE DE 2013',
'VERSION: 20131107.1818',
'FOLIO: 1391',
'BD: bdinteg',
'FECHA DE MODIFICACION: 04 de Mayo de 2015',
'Se corrige asignacion de situacion P-23 en match con ex empleado sin situacion especial de riesgo',
'FECHA DE MODIFICACION: 12/06/2020',
'AUTOR: L. Montserrat LeÃ³n Amador',
'DESCRIPCION: Se modifica procedimiento para integrar un nuevo valor en el parametro de entrada pBandera y asignar los valores U 66.',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Modifico: Angel Daniel Hernandez Gallardo',
'RQM: 11 187',
'Fecha: 09-10-2023',
'Modificacion: Se modifica el procedimiento almacenado marcar a clientes con situacion especial P-108',
'Base de datos: bdinteg';

CREATE PROCEDURE "informix".sp_grabaresultado_or (
												pTicket 			CHAR(50),
												pEstatus 			CHAR(1),
												pDescripcion 		CHAR(50),
												pMatchResult 		SMALLINT,
												pNumMatchResult 	SMALLINT,
												pCodResult 			CHAR(3),
												pNumCteMatch 		CHAR(20),
												pEmpresaMatch 		CHAR(1),
												pSitEspMatch 		CHAR(1),
												pPorcMatch 			CHAR(20),
												pOrigenResult		CHAR(1)
												)									
--DATOS A REGRESAR---
RETURNING             	
	CHAR(5) 	AS CodRet;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_grabaresultado_or "
Folio.........: 712.2 - EnvÃ­o de decÃ¡logo de huellas.
Autor.........: 99802161 - Narciso Ivan Cisneros Acosta
Fecha.........: 05/07/2021
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
VersiÃ³n.......: 20/08/2021
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE dFecha		DATETIME YEAR TO SECOND;
DEFINE cCodRetSp	CHAR(5);
DEFINE cNumCteSp	CHAR(20);
DEFINE cSitCteSp 	CHAR(1);
DEFINE sCausaCteSp 	SMALLINT;

--SET DEBUG FILE TO '/informix/jfponce/gabriel/RQI63925MejorasalprocesodemarcajeR2/SP_PRODUCTIVOS_PRUEBAS_26_SEP/sp_grabaresultado_or.out';
--TRACE ON;




-- INICIALIZACION DE VARIABLE.
LET cCodRet			= '00000';
LET iSqlErr			= 0;
LET dFecha			= CURRENT;
LET cCodRetSp		= '00000';
LET cNumCteSp 		= "";
LET cSitCteSp 		= "";
LET sCausaCteSp 	= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF EXISTS (SELECT ticket FROM "informix".si_rostro_linea WHERE ticket=pTicket) THEN
		LET cCodRet = '00000';
		UPDATE "informix".si_rostro_linea
		SET 
		fecha_result = dFecha,
		status_result = pEstatus,
		desc_result = pDescripcion,
		match_result = pMatchResult,
		num_match_result = pNumMatchResult,
    	codret_result = pCodResult,
		origen_result = pOrigenResult,	
		status_consulta = '3'
		WHERE ticket = pTicket;
		IF (NVL(pNumCteMatch,'')<> '') THEN
			INSERT INTO "informix".si_rostro_linea_result(ticket, numcte_match, empresa_match, sitesp_match, porc_match, 
															fecha_insert,origen_result,num_match_result)
			VALUES (pTicket, pNumCteMatch, pEmpresaMatch, pSitEspMatch, pPorcMatch, dFecha,pOrigenResult,pNumMatchResult);
		END IF;

		EXECUTE PROCEDURE bdisitesp:"informix".sp_sitespecialbiofacial('', pTicket, 'B') INTO cCodRetSp, cNumCteSp, cSitCteSp, sCausaCteSp;

	ELSE
		LET cCodRet='00001';
	END IF;
	-- LET cCodRet = '00000';
	RETURN cCodret;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica procedimiento almacenado "sp_grabaresultado_or", agregando el llamado del procedimiento almacenado "sp_sitespecialbiofacial" para situaciones especiales de biometria facial pendientes de procesar.',
'AUTOR : 98786903 - Paul Antonio Garcia Gastelum',
'FECHA : 21/02/2022',
'BD: bdinteg',
'-------------',
'DESCRIPCION: Se agrega las variables de retorno para cuando se manda a llamar al sp_sitespecialbiofacial',
'AUTOR : 90225087 - Victor Hugo Rojas Luis | externo Gabriel Romero Cuauhitzo',
'FECHA : 13/02/2024',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_registra_correos( pEmpresa    CHAR(3),
                                                 pNumCte     CHAR(20), 
                                                 pCorreoElec CHAR(100),
                                                 pTipoCorreo SMALLINT,
                                                 pCanal      SMALLINT,
                                                 pUserInsert CHAR(8) )
RETURNING CHAR(5) AS vcodret1;
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    
    
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vTpoPersona      CHAR(2);
    DEFINE vfecha_insert    DATE;
    DEFINE vSecuenciaMax    SMALLINT;
    DEFINE vExisteCorreo    SMALLINT;
    DEFINE vMaxSec          SMALLINT;
	DEFINE vCorreoNoValido  INTEGER;
	DEFINE cCodRetSp1       CHAR(5);
	DEFINE cCodRetSp2       CHAR(5);
	
	DEFINE correoCli        CHAR(100);
	DEFINE celularCli       CHAR(13);
	DEFINE contCorr         INTEGER;
	--se agrega variable para validar correo en lista NEGRAS
	DEFINE cser_correo CHAR(100);  
    
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
  
    LET vExisteCte    = 0;
    LET vTpoPersona   = '';
    LET vfecha_insert = '';
    LET vSecuenciaMax = 0;
    LET vExisteCorreo = 0;
    LET vMaxSec       = 0;
    LET vCorreoNoValido  = 0;
	LET cCodRetSp1        = '00000';
	LET cCodRetSp2        = '00000';
	LET correoCli         ='';
	LET celularCli        ='';
	LET contCorr          =0;
	LET cser_correo =  '%'||SUBSTRING_INDEX(SUBSTRING_INDEX(pCorreoElec,'@',-1),'.',1)||'%';
 
 
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_correos.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-239)
        LET vcodret1 = '999';
        RETURN vcodret1;
    END EXCEPTION WITH RESUME;
    
    --SET DEBUG FILE TO "/RESPALDOSNEW/enrique/sp_registra_correos.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR
       (pNumCte is null OR pNumCte = '') OR
       (pCorreoElec is null OR pCorreoElec = '') OR
       (pTipoCorreo is null OR pTipoCorreo = 0) OR
       (pCanal is null OR pCanal = 0) OR
       (pUserInsert is null OR pUserInsert = '') THEN
        LET vcodret1 = '110';
        RETURN vcodret1;
    END IF;
    
	-- // VALIDA QUE EL CORREO POR INSERTAR NO SE ENCUENTRE EN LA LISTA DE CORREOS NO VALIDOS
 --se cambia la consulta para evitar busqueda secuencial--
SELECT COUNT(id)
      INTO vCorreoNoValido
      FROM bdinteg:"informix".si_cat_correos_novalidos
     WHERE correo = pCorreoElec;
     

	IF vCorreoNoValido > 0 THEN
        LET vcodret1 = '120';
        RETURN vcodret1;
    END IF;
	
	-- // VALIDA QUE EL CORREO NO SE ENCUENTRE EN LISTAS NEGRAS
	--se cambia el select por un like para hacer la validacion y evitar una busqueda secuencial
 IF EXISTS(SELECT correo FROM bdinteg:si_cat_correos_listnegras WHERE correo like cser_correo) THEN
		LET vcodret1 = '121';
        RETURN vcodret1;
	END IF;
 

    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT tpo_persona, COUNT(*)
      INTO vTpoPersona, vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte
      GROUP BY 1;
     
    IF vExisteCte = 0 THEN
        LET vcodret1 = '104';
        RETURN vcodret1;
    END IF;
    
    SELECT COUNT(*)
      INTO vExisteCorreo
      FROM bdinteg:"informix".si_correos
     WHERE correo_elec = pCorreoElec
       AND status_correo = 'A';
       
    IF vExisteCorreo > 0 THEN
        LET vcodret1 = '999';
        RETURN vcodret1;
    END IF;
    
    -- // ONTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_insert
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = pEmpresa;
	 
	 SELECT correo_elec --Obtiene el correo antiguo que tenia el cliente
		INTO correoCli 
		FROM bdinteg:"informix".si_correos 
		WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A';		
		SELECT COUNT(*) INTO contCorr FROM
		bdinteg:"informix".si_correos 
		WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A';

    -- // INSERTA EN TABLA DE CORREOS
    SELECT MAX(secuencia)
      INTO vMaxSec
      FROM bdinteg:"informix".si_correos
     WHERE numcte = pNumCte;
             
    IF vMaxSec is null OR vMaxSec = '' THEN
        LET vMaxSec = 0;
    END IF;
    
    LET vMaxSec = vMaxSec + 1;
	IF (vMaxSec > 1 AND contCorr >=1 AND pTipoCorreo= 1) THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','NOT_ACT_EM',TRIM(pNumCte),'','','1','',TRIM(correoCli),'',TRIM(pCorreoElec),'','','','','','',TRIM(correoCli),'',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1; ------- NOTIFICACION AL CORREO ANTERIOR
	END IF;
    
    UPDATE bdinteg:"informix".si_correos
       SET status_correo = 'C'
     WHERE numcte = pNumCte
       AND tipo_correo = pTipoCorreo;
    
    INSERT INTO bdinteg:"informix".si_correos
    (empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert)
    VALUES
    (pEmpresa, pNumCte, pCorreoElec, pTipoCorreo, 'A', vMaxSec, pCanal, current, pUserInsert);
	
	IF (vMaxSec > 1 AND contCorr >=1 AND pTipoCorreo= 1) THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','NOT_ACT_EM',TRIM(pNumCte),'','','1','',TRIM(correoCli),'',TRIM(pCorreoElec),'','','','','','',TRIM(pCorreoElec),'',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1; ------- NOTIFICACION DE NUEVO DE CORREO
	END IF;
   
   END;

    RETURN vcodret1;
END PROCEDURE;