CREATE PROCEDURE "informix".sp_os_consultasolicitudes_web
(pEmpresa char(3),  pSucursal CHAR(4),pNumcte CHAR(20), pStatus char(3) ,pRFC CHAR(15), pPaginacion SMALLINT )

RETURNING CHAR(5),    -- CODIGO DE RETORNO
          CHAR(20),   -- NRO DE CLIENTE PROSPECTO
		  CHAR(20),   -- NRO DE CLIENTE TITULAR
          CHAR(120),  -- NOMBRE DEL CLIENTE
          CHAR(15),   -- R.F.C.
          DATE,       -- FECHA DE ALTA  
		  CHAR(60),   -- DESCRIPCION DEL STATUS DE LA SOLICITUD
		  INTEGER ,   -- DIAS DE VIGENCIA DE LA SOLICITUD EN SU ULTIMO ESTATUS
          CHAR(3),    -- CAUSA DE SOLICITUD
          CHAR(100);  -- DESCRIPCION DE LA CAUSA DE SOLICITUD	    

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE cNumcte_prosp	CHAR(20);
DEFINE cNumcte_tit 		CHAR(20);
DEFINE cNombreCte 		CHAR(120);
DEFINE cRFC				CHAR(15);
DEFINE dtFechaAlta		DATE;
DEFINE cStatusOs 		CHAR(60);
DEFINE iDiasTrans		INTEGER;
DEFINE cCveRec			CHAR(3);
DEFINE cDescripcionRec 	CHAR(100);
DEFINE iBandera 		INTEGER;
DEFINE iDiasVig 		INTEGER;
DEFINE cClave 			CHAR(2);
DEFINE dtFechaResp 		DATE;
DEFINE dtFechaSol 		DATE;
DEFINE iBandRet 		INTEGER;
DEFINE icontador		INTEGER;
DEFINE vStatus 			CHAR(2);
DEFINE iStatus 			INTEGER;


---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'PROCESO EXITOSO';
LET cNumcte_prosp		= '';
LET cNumcte_tit			= '';
LET cNombreCte 			= '';
LET cRFC				= '';
LET dtFechaAlta			= DATE(1);
LET cStatusOs 			= '';
LET iDiasTrans			= 0;
LET cCveRec				= '';
LET cDescripcionRec 	= '';
LET iBandera 			=  0;
LET iDiasVig 			=  0;
LET cClave				= '';
LET dtFechaResp			= DATE(1);
LET dtFechaSol			= DATE(1);
LET iBandRet 			=  0;
LET icontador			=  0;
LET vStatus				= '';
LET iStatus 			=  0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet, cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta,cStatusOs,iDiasTrans,cCveRec,cDescripcionRec;
       END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO '/informix/sp_os_consultasolicitudes_web.out';
	--TRACE ON;
    	
	IF NVL(pNumcte,"") <> "" THEN	
		LET pSucursal = "";
	END IF

	IF TRIM(pStatus) = 'T' OR pStatus = '' THEN
		LET iStatus = 1;
	END IF 
	
	--CONSULTA TODOS	
	IF NVL(pSucursal,"") <> "" THEN--VA CONSULTAR TODOS LOS ESTATUS	O EL ESTATUS QUE SE MANDE
		
		IF iStatus = 1 THEN
			FOREACH WITH HOLD
				--DETERMINA SI SE GENERO OS	
				SELECT  
					a.numcte_pros,a.numcte,TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),
					a.rfc, a.fecha_alta, d.descripcion,a.status_numcte_pros,c.dias_vigencia,a.fecha_hora,a.fecha_insert
				INTO cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta, cStatusOs, cClave,iDiasVig,dtFechaResp, dtFechaSol			
				FROM bdiprospectos:"informix".pr_cliente a 
					--LEFT OUTER JOIN bdisolic:"informix".ss_osclientesupervisar b ON(a.numcte_pros = b.num_solicitud)
					LEFT OUTER JOIN bdiprospectos:"informix".pr_vigencia_sol_productos c ON (a.status_numcte_pros = c.status_prospecto and a.empresa = c.empresa)
					INNER JOIN bdiprospectos:"informix".pr_status_sol  d ON (a.status_numcte_pros = d.status_solicitud AND d.monitor_visible = 1)
				WHERE a.empresa = pEmpresa
					AND a.numcte_pros = a.numcte_pros
					AND a.sucursal  = pSucursal
					--AND a.vigencia = 0   ---Ya no se tomara en cuenta el campo vigencia por peticion del cliente. 20/03/2015. 
					AND a.status_numcte_pros = a.status_numcte_pros 
				ORDER BY d.descripcion,a.nombre1, a.nombre2, a.apell_paterno,a.apell_materno				
						
				IF (NVL(dtFechaSol,DATE(1)) = DATE(1)) THEN
					CONTINUE FOREACH;
				END IF;							
				
				IF NVL(dtFechaResp,DATE(1)) = DATE(1) THEN
					LET iDiasTrans = TODAY - dtFechaSol;	
				ELSE
					LET iDiasTrans = TODAY - dtFechaResp;
				END IF;					
				
				--SE OBTIENE LA CLAVE DE LA CAUSA DEL RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
				SELECT causa_solicitud
				INTO cCveRec
				FROM bdiprospectos:"informix".pr_autorizacion 
				WHERE num_solicitud = cNumcte_prosp
					AND status_solicitud = cClave
					AND fecha_entrada = (SELECT MAX(fecha_entrada)
										 FROM bdiprospectos:"informix".pr_autorizacion 
										 WHERE num_solicitud = cNumcte_prosp
											AND status_solicitud = cClave
										);
				--SE OBTIENE LA DESCRIPCION DE LA CAUSA DE RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
				IF NVL(cCveRec,"") <> "" THEN
					SELECT descripcion 
					INTO cDescripcionRec
					FROM bdiprospectos:"informix".pr_causas_sol
					WHERE status_solicitud = cClave
						AND causa_solicitud = cCveRec;
				END IF;			
				
				IF iDiasTrans > iDiasVig THEN
					UPDATE bdiprospectos:"informix".pr_cliente 
						SET vigencia = 1
					WHERE empresa =pEmpresa
						AND numcte_pros = cNumcte_prosp;
					
					CONTINUE FOREACH;
				END IF;
				
				LET iBandera = iBandera+1;
				
				IF iBandera <= pPaginacion THEN
					LET iDiasTrans		= 0;
					LET cCveRec			= '';
					LET cDescripcionRec = '';
					CONTINUE FOREACH;
				ELSE				
					RETURN cCodRet, NVL(cNumcte_prosp,""),NVL(cNumcte_tit,""),NVL(cNombreCte,""),NVL(cRFC,""),NVL(dtFechaAlta,DATE(1)),NVL(cStatusOs,""),NVL(iDiasTrans,0),NVL(cCveRec,""),NVL(cDescripcionRec,"") WITH RESUME;
					LET iBandRet =  1;
				END IF;	
			
				LET iDiasTrans		= 0;
				LET cCveRec			= '';
				LET cDescripcionRec = '';
				
			END FOREACH;
		    ------------------------------------------termina el IF 
	    ELSE
	
			FOREACH WITH HOLD
				--DETERMINA SI SE GENERO OS	
				SELECT  
					a.numcte_pros,a.numcte,TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),
					a.rfc, a.fecha_alta, d.descripcion,a.status_numcte_pros,c.dias_vigencia,a.fecha_hora,a.fecha_insert
				INTO cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta, cStatusOs, cClave,iDiasVig,dtFechaResp, dtFechaSol			
				FROM bdiprospectos:"informix".pr_cliente a 
					--LEFT OUTER JOIN bdisolic:"informix".ss_osclientesupervisar b ON(a.numcte_pros = b.num_solicitud)
					LEFT OUTER JOIN bdiprospectos:"informix".pr_vigencia_sol_productos c ON (a.status_numcte_pros = c.status_prospecto and a.empresa = c.empresa)
					INNER JOIN bdiprospectos:"informix".pr_status_sol  d ON (a.status_numcte_pros = d.status_solicitud AND d.monitor_visible = 1)
				WHERE a.empresa = pEmpresa
					AND a.numcte_pros = a.numcte_pros
					AND a.sucursal  = pSucursal
					--AND a.vigencia = 0   ---Ya no se tomara en cuenta el campo vigencia por peticion del cliente. 20/03/2015. 
					AND a.status_numcte_pros = pStatus 
				ORDER BY   d.descripcion,a.nombre1, a.nombre2, a.apell_paterno,a.apell_materno				
						
				IF (NVL(dtFechaSol,DATE(1)) = DATE(1)) THEN
					CONTINUE FOREACH;
				END IF;							
				
				IF NVL(dtFechaResp,DATE(1)) = DATE(1) THEN
					LET iDiasTrans = TODAY - dtFechaSol;	
				ELSE
					LET iDiasTrans = TODAY - dtFechaResp;
				END IF;					
				
				--SE OBTIENE LA CLAVE DE LA CAUSA DEL RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
				SELECT causa_solicitud
				INTO cCveRec
				FROM bdiprospectos:"informix".pr_autorizacion 
				WHERE num_solicitud = cNumcte_prosp
					AND status_solicitud = cClave
					AND fecha_entrada = (SELECT MAX(fecha_entrada)
										 FROM bdiprospectos:"informix".pr_autorizacion 
										 WHERE num_solicitud = cNumcte_prosp
											AND status_solicitud = cClave
										);
				--SE OBTIENE LA DESCRIPCION DE LA CAUSA DE RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
				IF NVL(cCveRec,"") <> "" THEN
					SELECT descripcion 
					INTO cDescripcionRec
					FROM bdiprospectos:"informix".pr_causas_sol
					WHERE status_solicitud = cClave
						AND causa_solicitud = cCveRec;
				END IF;			
				
				IF iDiasTrans > iDiasVig THEN
					UPDATE bdiprospectos:"informix".pr_cliente 
						SET vigencia = 1
					WHERE empresa =pEmpresa
						AND numcte_pros = cNumcte_prosp;
					
					CONTINUE FOREACH;
				END IF;
				
				LET iBandera = iBandera+1;
				
				IF iBandera <= pPaginacion THEN
					LET iDiasTrans		= 0;
					LET cCveRec			= '';
					LET cDescripcionRec = '';
					CONTINUE FOREACH;
				ELSE				
					RETURN cCodRet, NVL(cNumcte_prosp,""),NVL(cNumcte_tit,""),NVL(cNombreCte,""),NVL(cRFC,""),NVL(dtFechaAlta,DATE(1)),NVL(cStatusOs,""),NVL(iDiasTrans,0),NVL(cCveRec,""),NVL(cDescripcionRec,"") WITH RESUME;
					LET iBandRet =  1;
				END IF;	
			
				LET iDiasTrans		= 0;
				LET cCveRec			= '';
				LET cDescripcionRec = '';
				
			END FOREACH;
	    END IF;
	END IF;
	
	---CONSULTA POR CLIENTE
	IF NVL(pNumcte,"") <> "" THEN--VA CONSULTAR TODOS LOS ESTATUS	
		IF iStatus = 1 THEN
			FOREACH WITH HOLD
				--DETERMINA SI SE GENERO OS	
				SELECT  
					a.numcte_pros,a.numcte,TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),
					a.rfc, a.fecha_alta,d.descripcion,a.status_numcte_pros,c.dias_vigencia,a.fecha_hora,a.fecha_insert
				INTO cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta,cStatusOs, cClave,iDiasVig,dtFechaResp, dtFechaSol
				FROM bdiprospectos:"informix".pr_cliente a 			
					LEFT OUTER JOIN bdiprospectos:"informix".pr_vigencia_sol_productos c ON (a.status_numcte_pros = c.status_prospecto and a.empresa = c.empresa)
					INNER JOIN bdiprospectos:"informix".pr_status_sol  d ON (a.status_numcte_pros = d.status_solicitud and d.monitor_visible = 1)
				WHERE a.empresa = pEmpresa
					AND a.numcte_pros = pNumcte			
					--AND a.vigencia = 0   ---Ya no se tomara en cuenta el campo vigencia por peticion del cliente. 20/03/2015. 
					AND a.status_numcte_pros = a.status_numcte_pros
				
				IF (NVL(dtFechaSol,DATE(1)) = DATE(1)) THEN
					CONTINUE FOREACH;
				END IF;							
				
				IF NVL(dtFechaResp,DATE(1)) = DATE(1) THEN
					LET iDiasTrans = TODAY - dtFechaSol;	
				ELSE
					LET iDiasTrans = TODAY - dtFechaResp;
				END IF;					
				
				--SE OBTIENE LA CLAVE DE LA CAUSA DEL RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
				SELECT causa_solicitud
				INTO cCveRec
				FROM bdiprospectos:"informix".pr_autorizacion 
				WHERE num_solicitud = cNumcte_prosp
					AND status_solicitud = cClave
					AND fecha_entrada = (SELECT MAX(fecha_entrada)
										 FROM bdiprospectos:"informix".pr_autorizacion 
										 WHERE num_solicitud = cNumcte_prosp
											AND status_solicitud = cClave
										);
				--SE OBTIENE LA DESCRIPCION DE LA CAUSA DE RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
				IF NVL(cCveRec,"") <> "" THEN
					SELECT descripcion 
					INTO cDescripcionRec
					FROM bdiprospectos:"informix".pr_causas_sol
					WHERE status_solicitud = cClave
						AND causa_solicitud = cCveRec;
				END IF;	
				
				IF iDiasTrans > iDiasVig THEN
					UPDATE bdiprospectos:"informix".pr_cliente 
						SET vigencia = 1
					WHERE empresa =pEmpresa
					AND numcte_pros = cNumcte_prosp;
					LET iBandera = 1;
					
					CONTINUE FOREACH;
				END IF;			
						
				LET iBandera = iBandera+1;
				
				IF iBandera <= pPaginacion THEN
					LET iDiasTrans		= 0;
					LET cCveRec			= '';
					LET cDescripcionRec = '';
					CONTINUE FOREACH;
				ELSE				
					RETURN cCodRet, NVL(cNumcte_prosp,""),NVL(cNumcte_tit,""),NVL(cNombreCte,""),NVL(cRFC,""),NVL(dtFechaAlta,DATE(1)),NVL(cStatusOs,""),NVL(iDiasTrans,0),NVL(cCveRec,""),NVL(cDescripcionRec,"") WITH RESUME;
					LET iBandRet =  1;
				END IF;	
			
				LET iDiasTrans		= 0;
				LET cCveRec			= '';
				LET cDescripcionRec = '';
			END FOREACH;
		ELSE
			FOREACH WITH HOLD
				--DETERMINA SI SE GENERO OS	
				SELECT  
					a.numcte_pros,a.numcte,TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),
					a.rfc, a.fecha_alta,d.descripcion,a.status_numcte_pros,c.dias_vigencia,a.fecha_hora,a.fecha_insert
				INTO cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta,cStatusOs, cClave,iDiasVig,dtFechaResp, dtFechaSol
				FROM bdiprospectos:"informix".pr_cliente a 			
					LEFT OUTER JOIN bdiprospectos:"informix".pr_vigencia_sol_productos c ON (a.status_numcte_pros = c.status_prospecto and a.empresa = c.empresa)
					INNER JOIN bdiprospectos:"informix".pr_status_sol  d ON (a.status_numcte_pros = d.status_solicitud and d.monitor_visible = 1)
				WHERE a.empresa = pEmpresa
					AND a.numcte_pros = pNumcte			
					--AND a.vigencia = 0   ---Ya no se tomara en cuenta el campo vigencia por peticion del cliente. 20/03/2015. 
					AND a.status_numcte_pros = pStatus
				
				IF (NVL(dtFechaSol,DATE(1)) = DATE(1)) THEN
					CONTINUE FOREACH;
				END IF;							
				
				IF NVL(dtFechaResp,DATE(1)) = DATE(1) THEN
					LET iDiasTrans = TODAY - dtFechaSol;	
				ELSE
					LET iDiasTrans = TODAY - dtFechaResp;
				END IF;					
				
				--SE OBTIENE LA CLAVE DE LA CAUSA DEL RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
				SELECT causa_solicitud
				INTO cCveRec
				FROM bdiprospectos:"informix".pr_autorizacion 
				WHERE num_solicitud = cNumcte_prosp
					AND status_solicitud = cClave
					AND fecha_entrada = (SELECT MAX(fecha_entrada)
										 FROM bdiprospectos:"informix".pr_autorizacion 
										 WHERE num_solicitud = cNumcte_prosp
											AND status_solicitud = cClave
										);
				--SE OBTIENE LA DESCRIPCION DE LA CAUSA DE RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
				IF NVL(cCveRec,"") <> "" THEN
					SELECT descripcion 
					INTO cDescripcionRec
					FROM bdiprospectos:"informix".pr_causas_sol
					WHERE status_solicitud = cClave
						AND causa_solicitud = cCveRec;
				END IF;	
				
				IF iDiasTrans > iDiasVig THEN
					UPDATE bdiprospectos:"informix".pr_cliente 
						SET vigencia = 1
					WHERE empresa =pEmpresa
					AND numcte_pros = cNumcte_prosp;
					LET iBandera = 1;
					
					CONTINUE FOREACH;
				END IF;			
						
				LET iBandera = iBandera+1;
				
				IF iBandera <= pPaginacion THEN
					LET iDiasTrans		= 0;
					LET cCveRec			= '';
					LET cDescripcionRec = '';
					CONTINUE FOREACH;
				ELSE				
					RETURN cCodRet, NVL(cNumcte_prosp,""),NVL(cNumcte_tit,""),NVL(cNombreCte,""),NVL(cRFC,""),NVL(dtFechaAlta,DATE(1)),NVL(cStatusOs,""),NVL(iDiasTrans,0),NVL(cCveRec,""),NVL(cDescripcionRec,"") WITH RESUME;
					LET iBandRet =  1;
				END IF;	
			
				LET iDiasTrans		= 0;
				LET cCveRec			= '';
				LET cDescripcionRec = '';
			
			END FOREACH;
		END IF;
	END IF;


    IF NVL(pRFC,"") <> "" THEN--VA CONSULTAR TODOS LOS ESTATUS	
		
			--DETERMINA SI SE GENERO OS	
			SELECT Count(a.rfc) INTO icontador 
			FROM bdiprospectos:"informix".pr_cliente a 			
			WHERE a.empresa = pEmpresa
				AND a.rfc = pRFC			
				AND a.status_numcte_pros IN (SELECT status_solicitud FROM bdiprospectos:"informix".pr_status_sol WHERE monitor_visible = 1);
				
				
			SELECT status_numcte_pros INTO vStatus 
			FROM bdiprospectos:"informix".pr_cliente a 			
			WHERE a.empresa = pEmpresa
				AND a.rfc = pRFC			
				AND a.status_numcte_pros IN (SELECT status_solicitud FROM bdiprospectos:"informix".pr_status_sol WHERE monitor_visible = 1);
						
			IF icontador = 0 OR ( icontador > 0  AND TRIM(vStatus) = 'CP') THEN 
			
				SELECT  		
					b.num_solicitud, 
					a.numcte,
					TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),
					a.rfc, 
					b.fecha_insert,
					d.descripcion, 
					b.status_solicitud 
				INTO cNumcte_prosp,
					cNumcte_tit,
					cNombreCte,
					cRFC,
					dtFechaAlta,
					cStatusOs,
					cCveRec
				FROM bdinteg:"informix".si_cliente a 
					LEFT OUTER JOIN bdisolic:"informix".ss_solicitudes b ON (a.numcte = b.numcte)
					LEFT OUTER JOIN bdisolic:"informix".ss_status_sol  d ON (b.status_solicitud = d.status_solicitud )
				WHERE b.empresa= pEmpresa
					AND b.num_producto = '6500'
					AND rfc = pRFC
					AND b.status_solicitud IN ("BC","CC","ST","EA","EE","OA","OS","CE","AT","AP","RT","LC","MC","EC");

				LET iDiasTrans		= 0;	
				LET cDescripcionRec = '';
							
				
				IF cNumcte_prosp = '' OR cNumcte_prosp IS NULL THEN
					LET cCodRet				= '02202';		
					RETURN cCodRet, "","","","",DATE(1),"",0,"","";	
				ELSE       
					RETURN cCodRet, NVL(cNumcte_prosp,""),NVL(cNumcte_tit,""),NVL(cNombreCte,""),NVL(cRFC,""),NVL(dtFechaAlta,DATE(1)),NVL(cStatusOs,""),NVL(iDiasTrans,0),NVL(cCveRec,""),NVL(cDescripcionRec,"");
				END IF  
			
			END IF;
			
			IF iStatus = 1 THEN
				FOREACH WITH HOLD
					SELECT  
						a.numcte_pros,a.numcte,TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),
						a.rfc, a.fecha_alta,d.descripcion,a.status_numcte_pros,c.dias_vigencia,a.fecha_hora,a.fecha_insert
					INTO cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta,cStatusOs, cClave,iDiasVig,dtFechaResp, dtFechaSol
					FROM bdiprospectos:"informix".pr_cliente a 			
						LEFT OUTER JOIN bdiprospectos:"informix".pr_vigencia_sol_productos c ON (a.status_numcte_pros = c.status_prospecto and a.empresa = c.empresa)
						INNER JOIN bdiprospectos:"informix".pr_status_sol  d ON (a.status_numcte_pros = d.status_solicitud AND d.monitor_visible = 1)
					WHERE a.empresa = pEmpresa
						AND a.rfc = pRFC			
						--AND a.vigencia = 0   ---Ya no se tomara en cuenta el campo vigencia por peticion del cliente. 20/03/2015. 
						AND a.status_numcte_pros = a.status_numcte_pros
								
					IF (NVL(dtFechaSol,DATE(1)) = DATE(1)) THEN
						CONTINUE FOREACH;
					END IF;							
					
					IF NVL(dtFechaResp,DATE(1)) = DATE(1) THEN
						LET iDiasTrans = TODAY - dtFechaSol;	
					ELSE
						LET iDiasTrans = TODAY - dtFechaResp;
					END IF;					
					
					--SE OBTIENE LA CLAVE DE LA CAUSA DEL RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
					SELECT causa_solicitud
					INTO cCveRec
					FROM bdiprospectos:"informix".pr_autorizacion 
					WHERE num_solicitud = cNumcte_prosp
						AND status_solicitud = cClave
						AND fecha_entrada = (SELECT MAX(fecha_entrada)
											 FROM bdiprospectos:"informix".pr_autorizacion 
											 WHERE num_solicitud = cNumcte_prosp
												AND status_solicitud = cClave
											);
					--SE OBTIENE LA DESCRIPCION DE LA CAUSA DE RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
					IF NVL(cCveRec,"") <> "" THEN
						SELECT descripcion 
						INTO cDescripcionRec
						FROM bdiprospectos:"informix".pr_causas_sol
						WHERE status_solicitud = cClave
							AND causa_solicitud = cCveRec;
					END IF;	
					
					IF iDiasTrans > iDiasVig THEN
						UPDATE bdiprospectos:"informix".pr_cliente 
							SET vigencia = 1
						WHERE empresa =pEmpresa
						AND numcte_pros = cNumcte_prosp;
						LET iBandera = 1;
						
						CONTINUE FOREACH;
					END IF;			
							
					LET iBandera = iBandera+1;
					
					IF iBandera <= pPaginacion THEN
						LET iDiasTrans		= 0;
						LET cCveRec			= '';
						LET cDescripcionRec = '';
						CONTINUE FOREACH;
					ELSE				
						RETURN cCodRet, NVL(cNumcte_prosp,""),NVL(cNumcte_tit,""),NVL(cNombreCte,""),NVL(cRFC,""),NVL(dtFechaAlta,DATE(1)),NVL(cStatusOs,""),NVL(iDiasTrans,0),NVL(cCveRec,""),NVL(cDescripcionRec,"") WITH RESUME;
						LET iBandRet =  1;
					END IF;	
				
					LET iDiasTrans		= 0;
					LET cCveRec			= '';
					LET cDescripcionRec = '';
				END FOREACH;
			ELSE
				FOREACH WITH HOLD
					SELECT  
						a.numcte_pros,a.numcte,TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),
						a.rfc, a.fecha_alta,d.descripcion,a.status_numcte_pros,c.dias_vigencia,a.fecha_hora,a.fecha_insert
					INTO cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta,cStatusOs, cClave,iDiasVig,dtFechaResp, dtFechaSol
					FROM bdiprospectos:"informix".pr_cliente a 			
						LEFT OUTER JOIN bdiprospectos:"informix".pr_vigencia_sol_productos c ON (a.status_numcte_pros = c.status_prospecto and a.empresa = c.empresa)
						INNER JOIN bdiprospectos:"informix".pr_status_sol  d ON (a.status_numcte_pros = d.status_solicitud AND d.monitor_visible = 1)
					WHERE a.empresa = pEmpresa
						AND a.rfc = pRFC			
						--AND a.vigencia = 0   ---Ya no se tomara en cuenta el campo vigencia por peticion del cliente. 20/03/2015. 
						AND a.status_numcte_pros = pStatus
								
					IF (NVL(dtFechaSol,DATE(1)) = DATE(1)) THEN
						CONTINUE FOREACH;
					END IF;							
					
					IF NVL(dtFechaResp,DATE(1)) = DATE(1) THEN
						LET iDiasTrans = TODAY - dtFechaSol;	
					ELSE
						LET iDiasTrans = TODAY - dtFechaResp;
					END IF;					
					
					--SE OBTIENE LA CLAVE DE LA CAUSA DEL RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
					SELECT causa_solicitud
					INTO cCveRec
					FROM bdiprospectos:"informix".pr_autorizacion 
					WHERE num_solicitud = cNumcte_prosp
						AND status_solicitud = cClave
						AND fecha_entrada = (SELECT MAX(fecha_entrada)
											 FROM bdiprospectos:"informix".pr_autorizacion 
											 WHERE num_solicitud = cNumcte_prosp
												AND status_solicitud = cClave
											);
					--SE OBTIENE LA DESCRIPCION DE LA CAUSA DE RECHAZO O CANCELACION DE LA SOLICITUD DEL CLIENTE PROSPECTO.
					IF NVL(cCveRec,"") <> "" THEN
						SELECT descripcion 
						INTO cDescripcionRec
						FROM bdiprospectos:"informix".pr_causas_sol
						WHERE status_solicitud = cClave
							AND causa_solicitud = cCveRec;
					END IF;	
					
					IF iDiasTrans > iDiasVig THEN
						UPDATE bdiprospectos:"informix".pr_cliente 
							SET vigencia = 1
						WHERE empresa =pEmpresa
						AND numcte_pros = cNumcte_prosp;
						LET iBandera = 1;
						
						CONTINUE FOREACH;
					END IF;			
							
					LET iBandera = iBandera+1;
					
					IF iBandera <= pPaginacion THEN
						LET iDiasTrans		= 0;
						LET cCveRec			= '';
						LET cDescripcionRec = '';
						CONTINUE FOREACH;
					ELSE				
						RETURN cCodRet, NVL(cNumcte_prosp,""),NVL(cNumcte_tit,""),NVL(cNombreCte,""),NVL(cRFC,""),NVL(dtFechaAlta,DATE(1)),NVL(cStatusOs,""),NVL(iDiasTrans,0),NVL(cCveRec,""),NVL(cDescripcionRec,"") WITH RESUME;
						LET iBandRet =  1;
					END IF;	
				
					LET iDiasTrans		= 0;
					LET cCveRec			= '';
					LET cDescripcionRec = '';				
				END FOREACH;
			END IF;
	END IF;
	
	IF iBandera = 0 THEN
		LET cCodRet				= '00001';		
		RETURN cCodRet, "","","","",DATE(1),"",0,"","";	
     ELSE			
		IF iBandRet = 0 THEN
			RETURN cCodRet, NVL(cNumcte_prosp,""),NVL(cNumcte_tit,""),NVL(cNombreCte,""),NVL(cRFC,""),NVL(dtFechaAlta,DATE(1)),NVL(cStatusOs,""),NVL(iDiasTrans,0),NVL(cCveRec,""),NVL(cDescripcionRec,"") WITH RESUME;
		END IF;
	END IF;

	
END
END PROCEDURE
