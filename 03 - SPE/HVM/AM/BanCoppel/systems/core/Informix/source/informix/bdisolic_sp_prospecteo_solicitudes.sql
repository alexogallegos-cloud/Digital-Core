CREATE PROCEDURE "informix".sp_prospecteo_solicitudes(pEmpresa CHAR(3), pNumcte CHAR(20), pNum_producto CHAR(4), pNum_solicitud CHAR(20), pEstatus CHAR(2), pOpcion CHAR(1), pDireccionINE SMALLINT)
RETURNING CHAR(5)  AS cCodRet, 
		  CHAR(20) AS cNumcte,
		  CHAR(4)  AS cNum_Producto,
		  CHAR(20) AS cNum_Solicitud,
          CHAR(1)  AS cCanal;
			
--Declaracion de variables-------------------------------------------------------- 
DEFINE cCodRet 				   CHAR(5);
DEFINE cNumcte		           CHAR(20);
DEFINE cNum_Producto           CHAR(4);
DEFINE cNum_Solicitud          CHAR(20);
DEFINE cEstatus_Solicitud      CHAR(2);
DEFINE sEstSol				   CHAR(2);
DEFINE iSqlErr				   INTEGER;
define cCanal                   char(1);
DEFINE sol_existe              INTEGER;
DEFINE cancelarSol             INTEGER;
DEFINE canalOrigen			   CHAR(1);
--Inicializacion de Variables----------------------------------------------------- 
LET iSqlErr						=		0;
LET cCodRet 					= 		'00001';
LET cNumcte		 				= 		'';
LET sEstSol		 				= 		'';
LET cNum_Producto		 		= 		'';
LET cNum_Solicitud		 		= 		'';
LET cEstatus_Solicitud	 		= 		'';
let cCanal ='0';
LET sol_existe   				=		0;
LET cancelarSol                 =       0;
LET canalOrigen					= 		'';

	--SET DEBUG FILE TO '/informix/Fperaza/NuevosCambios/canales/traces/sp_prospecteo_solicitudes'||pNum_solicitud||'.out';
	--TRACE ON;

	BEGIN 

		ON EXCEPTION SET iSqlerr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNumcte, cNum_Producto, cNum_Solicitud,cCanal;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		IF pOpcion = '1' THEN
			IF pEmpresa = '' OR pNumcte = '' OR pNum_producto = '' OR pNum_solicitud = '' OR pEstatus = '' OR pOpcion = '' THEN
				LET cCodRet = '00001';
					RETURN cCodRet,cNumcte, cNum_Producto, cNum_Solicitud,cCanal;		
			ELSE
										
				 SELECT FIRST 1 1 into cancelarSol
				 FROM bdisolic:"informix".ss_prospecteo_solicitudes 
				 WHERE numcte = pNumcte 
				 AND num_producto = pNum_producto
				 AND estatus = 'A' 
				 AND empresa = '001';
				 
				--- IF dbinfo("sqlca.sqlerrd2") <> 0 THEN			
				---	  LET cancelarSol = 1;
				--- END IF;
				
				IF cancelarSol = 1 THEN 
				    UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
			        SET estatus = 'C'
				    WHERE numcte = pNumcte 
				    AND num_producto = pNum_producto				    
				    AND estatus = 'A' 
				    AND empresa = '001';
			    END IF;
				 
				INSERT INTO bdisolic:"informix".ss_prospecteo_solicitudes (empresa, numcte, num_producto, num_solicitud, estatus, status_solicitud, fecha, domi_ife)
				VALUES (pEmpresa, pNumcte, pNum_producto, pNum_solicitud, pEstatus, NULL, CURRENT, pDireccionINE);
				
				--FJPR inicio
				SELECT canal_sol INTO cCanal FROM  bdisolic:"informix".ss_prospecteo_solicitudes 
				WHERE numcte = pNumcte AND num_solicitud = pNum_solicitud;
				
				SELECT canal_sol INTO canalOrigen FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = pNumcte AND num_solicitud = pNum_solicitud;
				
				IF canalOrigen IS NULL OR canalOrigen = '' OR canalOrigen = '1' THEN
					UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = cCanal
					WHERE numcte = pNumcte AND num_solicitud = pNum_solicitud;
				END IF;
				--FJPR final
				
				LET cCodRet = '00000';
				RETURN cCodRet,cNumcte, cNum_Producto, cNum_Solicitud,cCanal;
			END IF;
			
		ELIF pOpcion = '2' THEN
			IF pEmpresa = '' OR pNumcte = '' OR pOpcion = ''  THEN
				LET cCodRet = '00001';
				RETURN cCodRet,cNumcte, cNum_Producto, cNum_Solicitud,cCanal;
				
				
			ELSE
		
				FOREACH		
					SELECT numcte,num_producto,num_solicitud,canal_sol
					INTO cNumcte, cNum_Producto, cNum_Solicitud,cCanal
					FROM bdisolic:"informix".ss_prospecteo_solicitudes 
					WHERE numcte = pNumcte 
					AND empresa = pEmpresa
					AND estatus = 'A'                   
                    
					SELECT status_solicitud 
					INTO sEstSol
					FROM bdisolic:"informix".ss_solicitudes
					WHERE empresa= pEmpresa
					AND numcte = pNumcte
					AND num_solicitud = cNum_Solicitud;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN			
					LET sol_existe = 1;
					END IF;
					 
					 IF sol_existe = 1 THEN 
					 Update bdisolic:"informix".ss_prospecteo_solicitudes 
						SET estatus = 'C',status_solicitud = sEstSol
						WHERE numcte = pNumcte 
						AND empresa = pEmpresa
						AND num_solicitud = cNum_Solicitud;
					 END IF;
					 
					IF sEstSol = "RT" OR sEstSol = "AN" OR sEstSol = "CN" OR sEstSol = "PC" OR sEstSol="AP" THEN
						Update bdisolic:"informix".ss_prospecteo_solicitudes 
						SET estatus = 'C',status_solicitud = sEstSol
						WHERE numcte = pNumcte 
						AND empresa = pEmpresa
						AND num_solicitud = cNum_Solicitud;
					ELSE
						UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
						SET status_solicitud = sEstSol
						WHERE numcte = pNumcte 
						AND empresa = pEmpresa
						AND num_solicitud = cNum_Solicitud;					
					End IF

				END FOREACH;
			
				FOREACH		
                 
					
					SELECT numcte,num_producto,num_solicitud,canal_sol
					INTO cNumcte, cNum_Producto, cNum_Solicitud,cCanal
					FROM bdisolic:"informix".ss_prospecteo_solicitudes 
					WHERE numcte = pNumcte 
					AND empresa = pEmpresa
					AND estatus = 'A'
					
					IF dbinfo("sqlca.sqlerrd2") <> 0 THEN					
						LET cCodRet = '00000';					
					END IF	
					
						RETURN cCodRet,cNumcte, cNum_Producto, cNum_Solicitud,cCanal WITH RESUME;
				END FOREACH;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN			
					LET cCodRet = '00001';
					RETURN cCodRet, cNumcte, cNum_Producto, cNum_Solicitud,cCanal;					
				END IF		
				
			END IF;
		ELIF pOpcion = '3' THEN
		
			/*SELECT status_solicitud 
			INTO cEstatus_Solicitud
			FROM bdisolic:"informix".ss_solicitudes 
			WHERE num_solicitud = pNum_solicitud
			AND numcte = pNumcte;*/
			
		  SELECT status_solicitud 
		   INTO sEstSol
		  FROM bdisolic:"informix".ss_solicitudes
		  WHERE empresa= pEmpresa
		  AND numcte = pNumcte
		  AND num_solicitud = pNum_Solicitud
		  AND status_solicitud = 'PA';
		  	
		IF dbinfo("sqlca.sqlerrd2") = 1 THEN			
			LET cCodRet = '00000';
			RETURN cCodRet,pNumcte, pNum_producto, pNum_solicitud,cCanal;					
			---
		ELSE 	
	     SELECT status_solicitud 
		   INTO sEstSol
		  FROM bdisolic:"informix".ss_solicitudes
		  WHERE empresa= pEmpresa
		  AND numcte = pNumcte
		  AND num_solicitud = pNum_Solicitud;
		  
			UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
			SET estatus = 'F',status_solicitud = sEstSol
			WHERE numcte = pNumcte
			AND num_solicitud = pNum_solicitud;
			----AND numcte = pNumcte;
			
			-- FJPR inicio
			/*UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = '1'
			 WHERE numcte = pNumcte AND num_solicitud = pNum_solicitud;*/
			 
			-- FJPR final
			
				LET cCodRet = '00000';
			RETURN cCodRet,pNumcte, pNum_producto, pNum_solicitud,cCanal;
			END IF

		END IF;
	END
END PROCEDURE
