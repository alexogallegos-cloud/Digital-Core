CREATE PROCEDURE "informix".sp_ctepr_registraparametrico
(
	pEmpresa    	 CHAR (3),  	
	pSeccion    	 SMALLINT, 
	pGrupo   		 SMALLINT, 	
	pDescripcion	 CHAR(80),
	pTpoPersona		 CHAR (2),
	pNumSolicitud 	 CHAR (20),
	pValor 			 DECIMAL
)

RETURNING
	CHAR (6) AS cCodRet;

DEFINE	cCodRet CHAR (6);
DEFINE 	iSqlErr INTEGER;
DEFINE  sElemento SMALLINT;
DEFINE  vElemento INTEGER;
	
LET cCodRet	= '00000';
LET iSqlErr = 0;
LET sElemento = 0;
LET vElemento = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/sp_ctepr_registraparametrico.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3; 
		
		-- VALIDAR PARAMETROS DE ENTRADA
		IF NVL(pEmpresa,'') = '' OR NVL(pSeccion,0) = 0 OR NVL(pGrupo, 0) = 0 OR NVL(pDescripcion, '') = '' OR NVL (pTpoPersona, '') = '' OR NVL(pNumsolicitud, '') = '' THEN 
			LET cCodRet = '00001';
			RETURN cCodRet;
		ELSE		
		
			SELECT count(*) INTO vElemento
			FROM "informix".pr_scoring_element
			WHERE grupo = pGrupo
			AND SUBSTR(TRIM(descripcion), 0, 2) = SUBSTR(TRIM(pDescripcion), 0, 2);
			
			IF (vElemento) > 0 THEN 
  
				SELECT LIMIT 1 elemento INTO sElemento
				FROM "informix".pr_scoring_element
				WHERE grupo = pGrupo
				AND SUBSTR(TRIM(descripcion), 0, 2) = SUBSTR(TRIM(pDescripcion), 0, 2);
			
				IF  (SELECT count(*) FROM pr_detalle_scoring WHERE elemento = sElemento and empresa = pEmpresa and grupo = pGrupo and num_solicitud = pNumsolicitud and seccion = pSeccion and tpo_persona = pTpoPersona) = 0 THEN
				
					INSERT INTO "informix".pr_detalle_scoring  (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor) 
					VALUES (pEmpresa, pSeccion, pGrupo, sElemento, pTpoPersona, pNumsolicitud, pValor);	
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00002';
						RETURN cCodRet;
					END IF;
				ELSE 
					UPDATE pr_detalle_scoring SET valor = pValor WHERE elemento = sElemento and empresa = pEmpresa and grupo = pGrupo and num_solicitud = pNumsolicitud and seccion = pSeccion and tpo_persona = pTpoPersona;
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00002';
						RETURN cCodRet;
					END IF;
				END IF;
			ELSE 
				LET cCodRet = '00001';
			END IF;
		END IF;		
		RETURN cCodRet;
	END;
	
END PROCEDURE

