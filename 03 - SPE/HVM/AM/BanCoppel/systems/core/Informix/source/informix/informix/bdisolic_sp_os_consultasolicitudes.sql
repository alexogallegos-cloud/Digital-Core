CREATE PROCEDURE "informix".sp_os_consultasolicitudes
(pEmpresa char(3),  pSucursal CHAR(4),pNumcte CHAR(20), pStatus char(3) , pPaginacion SMALLINT )

RETURNING CHAR(5),    -- CODIGO DE RETORNO
          CHAR(20),   -- NRO DE CLIENTE PROSPECTO
		  CHAR(20),   -- NRO DE CLIENTE TITULAR
          CHAR(120),  -- NOMBRE DEL CLIENTE
          CHAR(15),   -- R.F.C.
          DATE,       -- FECHA DE ALTA          
          CHAR(60),   -- DESCRIPCION DEL STATUS DE LA SOLICITUD
		  INTEGER ,   --DIAS DE VIGENCIA DE LA SOLICITUD EN SU ULTIMO ESTATUS
          CHAR(3),    -- CAUSA DE SOLICITUD
          CHAR(100);  -- DESCRIPCIÓN DE LA CAUSA DE SOLICITUD	    

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

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet, cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta,cStatusOs,iDiasTrans,cCveRec,cDescripcionRec;
       END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
--    SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION COMMITTED READ;
    
	
	--SET DEBUG FILE TO "/informix/josue_coppel/sp_os_consultasolicitudes.out";
	--TRACE ON;
    	
	IF NVL(pNumcte,"") <> "" THEN	
		LET pSucursal = "";
	END IF 
	
	--CONSULTA TODOS	
	IF NVL(pSucursal,"") <> "" THEN--VA CONSULTAR TODOS LOS ESTATUS	O EL ESTATUS QUE SE MANDE
		FOREACH WITH HOLD
			--DETERMINA SI SE GENERO OS	
			--SELECT {+INDEX (bdiprospectos:"informix".pr_cliente idx_pr_cliente2) } 
			SELECT  
				a.numcte_pros,a.numcte,TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),
				a.rfc, a.fecha_alta,d.descripcion,a.status_numcte_pros,c.dias_vigencia,a.fecha_hora,a.fecha_insert
			INTO cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta,cStatusOs, cClave,iDiasVig,dtFechaResp, dtFechaSol			
			FROM bdiprospectos:"informix".pr_cliente a 
				--LEFT OUTER JOIN bdisolic:"informix".ss_osclientesupervisar b ON(a.numcte_pros = b.num_solicitud)
				LEFT OUTER JOIN bdiprospectos:"informix".pr_vigencia_sol_productos c ON (a.status_numcte_pros = c.status_prospecto)
				LEFT OUTER JOIN bdiprospectos:"informix".pr_status_sol  d ON (a.status_numcte_pros = d.status_solicitud )
			WHERE a.empresa = pEmpresa
				AND a.numcte_pros = a.numcte_pros
				AND a.sucursal  = pSucursal
				--AND a.vigencia = 0   ---Ya no se tomara en cuenta el campo vigencia por peticion del cliente. 20/03/2015. 
				AND a.status_numcte_pros NOT IN ('PC','AN','CN')
				AND a.status_numcte_pros = CASE WHEN NVL(pStatus,'T') IN ('T','') THEN a.status_numcte_pros ELSE pStatus END
			ORDER BY   c.descripcion,a.nombre1, a.nombre2, a.apell_paterno,a.apell_materno				
					
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
	
	---CONSULTA POR CLIENTE
	IF NVL(pNumcte,"") <> "" THEN--VA CONSULTAR TODOS LOS ESTATUS	
		FOREACH WITH HOLD
			--DETERMINA SI SE GENERO OS	
			SELECT {+INDEX (bdiprospectos:"informix".pr_cliente idx_pr_cliente2) } 
				a.numcte_pros,a.numcte,TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),
				a.rfc, a.fecha_alta,d.descripcion,a.status_numcte_pros,c.dias_vigencia,a.fecha_hora,a.fecha_insert
			INTO cNumcte_prosp,cNumcte_tit,cNombreCte,cRFC,dtFechaAlta,cStatusOs, cClave,iDiasVig,dtFechaResp, dtFechaSol
			FROM bdiprospectos:"informix".pr_cliente a 			
				LEFT OUTER JOIN bdiprospectos:"informix".pr_vigencia_sol_productos c ON (a.status_numcte_pros = c.status_prospecto)
				LEFT OUTER JOIN bdiprospectos:"informix".pr_status_sol  d ON (a.status_numcte_pros = d.status_solicitud )
			WHERE a.empresa = pEmpresa
				AND a.numcte_pros = pNumcte			
				--AND a.vigencia = 0   ---Ya no se tomara en cuenta el campo vigencia por peticion del cliente. 20/03/2015. 
				AND a.status_numcte_pros NOT IN ('PC','AN','CN')													
				AND a.status_numcte_pros = CASE WHEN NVL(pStatus,'T') IN ('T','') THEN a.status_numcte_pros ELSE pStatus END
			
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
