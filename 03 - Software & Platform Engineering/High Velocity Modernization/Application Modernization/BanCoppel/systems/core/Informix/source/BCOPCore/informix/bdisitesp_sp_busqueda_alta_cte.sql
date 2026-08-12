CREATE PROCEDURE "informix".sp_busqueda_alta_cte(pNumcte 			CHAR(20),	
												 pTipoCliente		CHAR(1),
												 pSucursal 			CHAR(4),
												 pEjecut 			CHAR(8)) 	
	RETURNING 	CHAR(6);			-- Codigo de retorno
	
	DEFINE CodRet           CHAR(6);
	DEFINE sExiste      	SMALLINT;
	DEFINE cNomemp      	CHAR(45);
	DEFINE cSit  	    	CHAR(1);
	DEFINE sCausa	      	SMALLINT;
	DEFINE iSql_err 		INT;
	
	LET CodRet              = '000000';
	LET cNomemp              = '';
	LET sExiste				= 0;
	LET cSit  				= '';
	LET sCausa				= 0;
	LET iSql_err 			= 0;
	
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET CodRet = iSql_err;
                RETURN CodRet;
            END IF;
        END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/respaldosbd/Yaneli/sp_busqueda_alta_cte2.out";
		--TRACE ON;
		
		-- VALIDAR PARAMETROS
		IF (NVL(pNumcte,"") <> "" AND NVL(pTipoCliente,"") <> "") AND (pTipoCliente = '1' OR  pTipoCliente = '2') THEN
			
			IF pTipoCliente = '1' THEN
							
				SELECT COUNT(numcte) INTO sExiste 
				FROM "informix".se_ctessitespcte 
				WHERE situacion= 'U' 
				AND causa ='61' 
				AND numcte=pNumcte;
				
				IF NVL(sExiste,0) > 0 THEN
					
					LET sExiste = 0;
					SELECT COUNT(numcte) INTO sExiste 
					FROM  bdinteg: "informix".si_huella_linea 
					WHERE numcte=pNumcte AND status_consulta='3';
					
				END IF;
				
				IF NVL(sExiste,0) > 0 THEN					
					LET CodRet = '000002'; -- SE MANDARA AL MODULO DE EVALUACION
				ELSE
					LET CodRet = '000000'; -- SE SEGUIRÁ EL FLUJO PRODUCTIVO
				END IF; 

			ELIF pTipoCliente = '2' THEN
									
				IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumcte) THEN
				--IF NVL(sExiste,0) > 0 THEN
					SELECT situacion,causa 
					INTO  cSit,sCausa
					FROM  "informix".se_ctessitespcte
					WHERE numcte=pNumcte 
					AND situacion = situacion 	-- ACTIVAR INDICES
					AND causa = causa;			-- ACTIVAR INDICES
					
					--Valida si encuentra informacion
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						--inserta situacion y causa
						SELECT nombre 
						INTO cNomemp
						FROM bdinteg: "informix".si_ejecut
						WHERE ejecutivo = pEjecut;
						
						INSERT INTO "informix".se_ctessitespcte (empresa,numcte,situacion,causa,cvesitesporigen,sucursal,tipomovto,empleadoefectuo,nombreefectuo,fechamovto,usralta,fchalta,usrmodifica,fchmodifica,motivo_desmarcaje) 
						VALUES ('001',pNumcte,'U',61,'5',pSucursal,'1',pEjecut,cNomemp,CURRENT YEAR TO SECOND,pEjecut,CURRENT YEAR TO SECOND,'','','');
						
						--RETURN CodRet;
					ELIF NVL(csit,'') ='' AND NVL(sCausa,'') = '' THEN
						UPDATE "informix".se_ctessitespcte SET situacion = 'U', causa = 61 WHERE numcte = pNumcte; 
					END IF;
				ELSE
					LET CodRet = '000004'; --No existe cliente en la si_huella_linea
				END IF;
			END IF;
		ELSE 			
			LET CodRet = '000001'; --NO RECIBE LOS PARAMETROS INCORRECTOS		
		END IF; 	
		
		RETURN  CodRet;
		
	END;
END PROCEDURE
