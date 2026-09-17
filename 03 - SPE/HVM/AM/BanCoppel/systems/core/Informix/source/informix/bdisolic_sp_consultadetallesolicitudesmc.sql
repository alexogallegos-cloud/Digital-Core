CREATE PROCEDURE "informix".sp_consultadetallesolicitudesmc( pFechaInicio CHAR(10), pFechaFin CHAR(10), pTipoRep SMALLINT )
RETURNING
	CHAR(6) AS CodRet, 
	CHAR(80) AS Mensaje_Ret, 
	CHAR(20) AS NumSolicitud, 
	CHAR(20) AS NumCte, 
	VARCHAR(107) AS NombreCte, 
	DATE AS Fechasol, 
	DATE AS FechaAtencion,
	CHAR(45) AS Analista,
	VARCHAR(10,1) AS TipoMovimiento; 	
	
---DECLARACIONES
DEFINE cCodRet			CHAR(6);
DEFINE cCodRetUDI		CHAR(6);
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cMensajeRet          CHAR(80);
-- VARIABLES DEL PROCESO
DEFINE cNumSolicitud		CHAR(20);
DEFINE cNumSolicitud2		CHAR(20);
DEFINE cNumcte			CHAR(20);
DEFINE vNomCte				VARCHAR(107);
DEFINE dFechasol			DATE;
DEFINE dFechacambio			DATE;
DEFINE cAnalista			CHAR(45);
DEFINE cEjecutivoAtiende    CHAR(10);
DEFINE cInstitucion    CHAR(2);
DEFINE iRegistoID    DECIMAL(18,2);
DEFINE vTipoMovto VARCHAR(10,1);


-- INICIALIZACIONES
LET cCodRet				= '00000';
LET cCodRetUDI			= '00000';
LET iSqlErr				= 0;
LET iSamErr				= 0;
LET cErrorInfo			= '';
LET cMensajeRet         = "SE REALIZÓ LA CONSULTA CORRECTAMENTE";
-- INICIALIZACIÓN DE VARIABLES DEL PROCESO.
LET cNumSolicitud		= '';
LET cNumSolicitud2		= '';
LET cNumcte		= '';
LET vNomCte				= '';
LET dFechasol			= DATE(1);
LET dFechacambio		= DATE(1);
LET cAnalista			= '';
LET cEjecutivoAtiende	= '';
LET cInstitucion 		= '';
LET iRegistoID			= 0;
LET vTipoMovto          = '';
	
BEGIN

	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr::CHAR(8);
			LET cMensajeRet = cErrorInfo;
		    RETURN cCodRet, cMensajeRet,NVL(TRIM(cNumSolicitud), ''),cNumcte, NVL(TRIM(vNomCte), ''), NVL(dFechasol, DATE(1)), NVL(dFechacambio, DATE(1)), NVL(TRIM(cAnalista), ''), NVL(TRIM(vTipoMovto),'');
		END IF;
	END EXCEPTION; 
	
	  --SET DEBUG FILE TO "/informix/jesus/sp_consultadetallesolicitudesmc.out";
	  --TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF NVL(pFechaInicio::DATE, "") = "" OR NVL(pFechaFin::DATE, "") = "" THEN
		LET cCodRet = "00001"; -- PARAMETROS OBLIGATORIOS.
	ELIF CAST(NVL(pFechaInicio, "") AS DATE) > CAST(NVL(pFechaFin, "") AS DATE) THEN
		LET cCodRet = "00002"; -- FECHA INICIAL NO DEBE SER MAYOR A LA FECHA FINAL.
	END IF;
	
	IF cCodRet = '00000' THEN
		IF pTipoRep = 1 THEN 
			FOREACH WITH HOLD			
				SELECT {+INDEX ("informix".ss_autorizacion_especial ix217_2 )  } b.numcte, b.num_solicitud, b.fecha_modif , b.usuario_modif,a.fecha_insert
					INTO  cNumcte,cNumSolicitud, dFechacambio,   cEjecutivoAtiende,dFechasol
				FROM "informix".ss_solicitudes AS a 
				INNER JOIN "informix".ss_autorizacion_especial AS b
				ON b.empresa = a.empresa AND b.num_solicitud = a.num_solicitud 
				WHERE  a.num_producto = '6500' AND b.status_ant ='OA' AND b.status_nvo = 'EE' 
				AND b.fecha_modif BETWEEN pFechaInicio::DATE AND pFechaFin::DATE
							

				SELECT  TRIM(NVL(cte.nombre1,''))||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)
					INTO vNomCte
				FROM bdinteg:"informix".si_cliente cte 
				WHERE empresa = '001'
				AND numcte = cNumcte;
								
				-- OBTENEMOS EL NOMBRE DEL ANALISTA MC
				SELECT nombre INTO cAnalista
				FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = TRIM(cEjecutivoAtiende);
				
				-- SE AGREGA LA VALIDACIÓN PARA IDENTIFICAR EL TIPO DE MOVIMIENTO SI ES UNICO O MIXTO RQM 09 372 PIQV
				SELECT DECODE(NVL(TRIM(num_solicitud_ref),''),'','UNICO','MIXTO')
				  INTO vTipoMovto
				  FROM bdisolic:ss_resum_scor_fin 
				 WHERE empresa = '001'
				   AND num_solicitud = cNumSolicitud;				   
				   
				   IF vTipoMovto IS NULL THEN LET vTipoMovto = "UNICO"; END IF;				   

				RETURN cCodRet, cMensajeRet, NVL(TRIM(cNumSolicitud), ''), cNumcte, NVL(TRIM(vNomCte), ''), NVL(dFechasol, DATE(1)), NVL(dFechacambio, DATE(1)), NVL(TRIM(cAnalista), ''), NVL(TRIM(vTipoMovto),'') WITH RESUME;
			END FOREACH;
		ELIF pTipoRep = 2 THEN 
			
			FOREACH WITH HOLD
									
			select a.numcte,a.numsolicitud,a.fecha_sol,a.fecha_reenvio,a.nombre_cte,a.nombre_analista    
			INTO  cNumcte,cNumSolicitud,dFechasol,dFechacambio,vNomCte,cAnalista
			from bdisolic:ss_mon_buro_rep   a                    
			where  a.empresa ='001' 
			AND a.numcte > '' 
			AND a.fecha_reenvio BETWEEN pFechaInicio::DATE AND pFechaFin::DATE                   
			and a.producto ='6001'                       
			and a.reenvio_exit='1'                       
			and a.numsolicitud in (select b.num_solicitud_sic                       
							 from bdisolic:ss_solicitudes_sic b
							  where b.empresa='001' --and num_solicitud > '' 
								AND b.numcte = a.numcte
								AND b.fecha_insert BETWEEN pFechaInicio::DATE AND pFechaFin::DATE
							   and substr(b.num_solicitud,1,2) = '65' )
					   
							
					LET vTipoMovto = "MIXTO";
					

					RETURN cCodRet, cMensajeRet, NVL(TRIM(cNumSolicitud), ''), cNumcte, NVL(TRIM(vNomCte), ''), NVL(dFechasol, DATE(1)), NVL(dFechacambio, DATE(1)), NVL(TRIM(cAnalista), ''), NVL(TRIM(vTipoMovto),'') WITH RESUME;

				END FOREACH;
			
			
                 										 
	                     
                                                 
                        
			FOREACH WITH HOLD
	
			SELECT  a.numcte,a.numsolicitud,a.fecha_sol,a.fecha_reenvio,a.nombre_cte,a.nombre_analista 
						INTO  cNumcte,cNumSolicitud,dFechasol,dFechacambio,vNomCte,cAnalista
			from bdisolic:ss_mon_buro_rep   a                    
			where  a.empresa ='001' 
			AND a.numcte > '' 
			AND a.fecha_reenvio BETWEEN pFechaInicio::DATE AND pFechaFin::DATE                       
			and a.producto ='6500'                       
			and a.reenvio_exit='1'                       
			and a.numsolicitud in (select b.num_solicitud_sic                       
							 from bdisolic:ss_solicitudes_sic  b                      
							  where b.empresa='001' --and num_solicitud > '' 
								AND b.numcte = a.numcte							  
								and b.fecha_insert between pFechaInicio::DATE AND pFechaFin::DATE                   
							   and substr(b.num_solicitud,1,2) = '65' )  
					
					
							
              
					LET vTipoMovto = "UNICO"; 

					RETURN cCodRet, cMensajeRet, NVL(TRIM(cNumSolicitud), ''), cNumcte, NVL(TRIM(vNomCte), ''), NVL(dFechasol, DATE(1)), NVL(dFechacambio, DATE(1)), NVL(TRIM(cAnalista), ''), NVL(TRIM(vTipoMovto),'') WITH RESUME;

				END FOREACH;

				
		ElIF pTipoRep =3 THEN 
			
			
				FOREACH WITH HOLD
						
					SELECT numcte,fecha_insert,num_solicitud, fecha_determinacion , ejecutivo_atiende
						INTO  cNumcte,dFechasol,cNumSolicitud, dFechacambio,   cEjecutivoAtiende
					FROM bdisolic:"informix".ss_solicitudes_mc 				
					WHERE fecha_insert >= pFechaInicio::DATE
					  AND fecha_insert <= pFechaFin::DATE			 
					  AND ejecutivo_autoriza <> ''
					  AND num_producto = '6500'
					  AND revisado ='S'
					  ORDER BY numcte
					  
					SELECT  TRIM(NVL(cte.nombre1,''))||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)
						INTO vNomCte
					FROM bdinteg:"informix".si_cliente cte 
					WHERE empresa = '001'
					AND numcte = cNumcte;
									
					-- OBTENEMOS EL NOMBRE DEL ANALISTA MC
					SELECT nombre INTO cAnalista
					FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = TRIM(cEjecutivoAtiende);
					
					-- SE AGREGA LA VALIDACIÓN PARA IDENTIFICAR EL TIPO DE MOVIMIENTO SI ES UNICO O MIXTO RQM 09 372 PIQV
					SELECT DECODE(NVL(TRIM(num_solicitud_ref),''),'','UNICO','MIXTO')
				      INTO vTipoMovto
				      FROM bdisolic:ss_resum_scor_fin 
				     WHERE empresa = '001'
				       AND num_solicitud = cNumSolicitud;			

						IF vTipoMovto IS NULL THEN LET vTipoMovto = "UNICO"; END IF;
					
					RETURN cCodRet, cMensajeRet, NVL(TRIM(cNumSolicitud), ''), cNumcte, NVL(TRIM(vNomCte), ''), NVL(dFechasol, DATE(1)), NVL(dFechacambio, DATE(1)), NVL(TRIM(cAnalista), ''), NVL(TRIM(vTipoMovto),'') WITH RESUME;
				END FOREACH;		   
		END IF;
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00003'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.
		END IF;
		
	END IF;
	
	IF cCodRet <> '00000' THEN
	   RETURN cCodRet,cMensajeRet, NVL(TRIM(cNumSolicitud), ''), cNumcte, NVL(TRIM(vNomCte), ''), NVL(dFechasol, DATE(1)), NVL(dFechacambio, DATE(1)), NVL(TRIM(cAnalista), ''), NVL(TRIM(vTipoMovto),'');
	END IF
	
END;

END PROCEDURE
