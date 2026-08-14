CREATE PROCEDURE "informix".sp_prospecteo_solicitudes_online(pEmpresa CHAR(3), pNumcte CHAR(20), pNum_producto CHAR(4),
													  pNum_solicitud CHAR(20), pEstatus CHAR(2), pOpcion CHAR(1), pDireccionINE SMALLINT,pCanal_sol SMALLINT,pSubCanal CHAR(2),pSucursalFisica CHAR(4) )
RETURNING CHAR(5)  AS cCodRet, 
		  CHAR(20) AS cNumcte,
		  CHAR(4)  AS cNum_Producto,
		  CHAR(20) AS cNum_Solicitud;
			
--Declaracion de variables-------------------------------------------------------- 
DEFINE cCodRet 				   CHAR(5);
DEFINE cNumcte		           CHAR(20);
DEFINE cNum_Producto           CHAR(4);
DEFINE cNum_Solicitud          CHAR(20);
DEFINE cEstatus_Solicitud      CHAR(2);
DEFINE sEstSol				   CHAR(2);
DEFINE iSqlErr				   INTEGER;
DEFINE cCanal_sol              SMALLINT;
--Inicializacion de Variables----------------------------------------------------- 
LET iSqlErr						=		0;
LET cCodRet 					= 		'00001';
LET cNumcte		 				= 		'';
LET sEstSol		 				= 		'';
LET cNum_Producto		 		= 		'';
LET cNum_Solicitud		 		= 		'';
LET cEstatus_Solicitud	 		= 		'';
LET cCanal_sol                  =       0;
	--SET DEBUG FILE TO '/home/sysifx/Lerma/sp_prospecteo_solicitudes.out';
	--TRACE ON;

	BEGIN 

		ON EXCEPTION SET iSqlerr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNumcte, cNum_Producto, cNum_Solicitud;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		IF pOpcion = '1' THEN
			IF pEmpresa = '' OR pNumcte = '' OR pNum_producto = '' OR pNum_solicitud = '' OR pEstatus = '' OR pOpcion = '' THEN
				LET cCodRet = '00001';
				RETURN cCodRet,cNumcte, cNum_Producto, cNum_Solicitud;
			ELSE
				INSERT INTO bdisolic:"informix".ss_prospecteo_solicitudes (empresa, numcte, num_producto, num_solicitud, estatus, status_solicitud, fecha, domi_ife,canal_sol,sub_canal_sol,sucursal_fisica)
				VALUES (pEmpresa, pNumcte, pNum_producto, pNum_solicitud, pEstatus, NULL, CURRENT, pDireccionINE, pCanal_sol,pSubCanal,pSucursalFisica);
				
				LET cCodRet = '00000';
				RETURN cCodRet,cNumcte, cNum_Producto, cNum_Solicitud;
			END IF;
		ELIF pOpcion = '2' THEN
			IF pEmpresa = '' OR pNumcte = '' OR pOpcion = '' THEN
				LET cCodRet = '00001';
				RETURN cCodRet,cNumcte, cNum_Producto, cNum_Solicitud; 
			ELSE
			
				FOREACH		
					SELECT numcte, num_producto, num_solicitud
					INTO cNumcte, cNum_Producto, cNum_Solicitud
					FROM bdisolic:"informix".ss_prospecteo_solicitudes 
					WHERE numcte = pNumcte 
					AND empresa = pEmpresa
					AND estatus = 'A'

					SELECT status_solicitud INTO sEstSol
					FROM bdisolic:"informix".ss_solicitudes
					WHERE empresa= pEmpresa
					AND numcte = pNumcte
					AND num_solicitud = cNum_Solicitud;
					 
					IF sEstSol = "RT" OR sEstSol = "AN" THEN
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
					SELECT numcte, num_producto, num_solicitud
					INTO cNumcte, cNum_Producto, cNum_Solicitud
					FROM bdisolic:"informix".ss_prospecteo_solicitudes 
					WHERE numcte = pNumcte 
					AND empresa = pEmpresa
					AND estatus = 'A'
					
					IF dbinfo("sqlca.sqlerrd2") <> 0 THEN					
						LET cCodRet = '00000';					
					END IF	
					
					RETURN cCodRet, cNumcte, cNum_Producto, cNum_Solicitud WITH RESUME;					
				END FOREACH;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN			
					LET cCodRet = '00001';
					RETURN cCodRet, cNumcte, cNum_Producto, cNum_Solicitud;					
				END IF		
				
			END IF;
		ELIF pOpcion = '3' THEN
		
			SELECT status_solicitud 
			INTO cEstatus_Solicitud
			FROM bdisolic:"informix".ss_solicitudes 
			WHERE num_solicitud = pNum_solicitud
			AND numcte = pNumcte;
			
			UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
			SET estatus = 'F',status_solicitud = cEstatus_Solicitud
			WHERE num_solicitud = pNum_solicitud
			AND numcte = pNumcte;
			
			LET cCodRet = '00000';
			RETURN cCodRet, cNumcte, cNum_Producto, cNum_Solicitud;

		END IF;
	END
END PROCEDURE
