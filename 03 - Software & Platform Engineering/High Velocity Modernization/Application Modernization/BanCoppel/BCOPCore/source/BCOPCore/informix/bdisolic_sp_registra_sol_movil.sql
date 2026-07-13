CREATE PROCEDURE "informix".sp_registra_sol_movil(pEmpresa CHAR(3),pFolio CHAR(20),pProdSol CHAR(4))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;
		  
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cNumCte          CHAR(20);
DEFINE cNumCteCop       CHAR(20);
DEFINE cSolicitud       CHAR(20);
DEFINE cSolicitud2      CHAR(20);
DEFINE cSucursal        CHAR(4);
DEFINE cTipoSol         CHAR(1);
DEFINE dIngreso         MONEY(14,2);
DEFINE iTpIngreso       INTEGER;
DEFINE iPeriodicidad    INTEGER;
DEFINE dImporteSol      DECIMAL (18,2);
DEFINE iEficiencia      INTEGER;
DEFINE iMeseshist       INTEGER;
DEFINE iCreditoaut      INTEGER;
DEFINE sCausa      		SMALLINT;
DEFINE cPuntualidad     CHAR(1);
DEFINE cSitEsp	        CHAR(1);
DEFINE iSdoropa     	INTEGER;
DEFINE iSdomuebles      INTEGER;
DEFINE iSdoprestamos    INTEGER;
DEFINE iVdoropa         INTEGER;
DEFINE iVdomuebles      INTEGER;
DEFINE iVdoprestamos    INTEGER;
DEFINE iAbonomesropa    INTEGER;
DEFINE iAbonomesmuebles INTEGER;
DEFINE iAbonomesprestamos  INTEGER;
DEFINE cFecha_ult_compra   CHAR(13) ;
DEFINE dtFechaUltCompra   CHAR(13) ;
DEFINE cUsuario   CHAR(10) ;
DEFINE iSecuencia       INTEGER;

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";
LET cNumCte          = "";
LET cNumCteCop       = "";
LET cSolicitud       = "";
LET cSolicitud2      = "";
LET cSucursal        = "";
LET cTipoSol        = "";
LET dIngreso         = 0;
LET iTpIngreso       = 0;
LET iPeriodicidad    = 0;
LET dImporteSol      = 0;
LET iEficiencia     = 0;
LET iMeseshist      = 0;
LET iCreditoaut     = 0;
LET sCausa      	 = 0;
LET cPuntualidad    = '';
LET cSitEsp		    = '';
LET iSdoropa     	 = 0;
LET iSdomuebles     = 0;
LET iSdoprestamos   = 0;
LET iVdoropa        = 0;
LET iVdomuebles     = 0;
LET iVdoprestamos   = 0;
LET iAbonomesropa   = 0;
LET iAbonomesmuebles = 0;
LET iAbonomesprestamos  = 0;
LET cFecha_ult_compra   = '';
LET dtFechaUltCompra   = '';
LET cUsuario   = '';
LET iSecuencia   = 0;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet;   
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_registra_sol_movil.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') ='' OR  NVL(pFolio,'') =''  THEN
		LET cCodRet             = "000001";
		LET cMensajeRet         = "PARAMETROS DE ENTRADA INVALIDOS";
	ELSE
		
		SELECT NVL(mov.numcte,'') , NVL(mov.sucursal,''),NVL(graba.eficiencia,0),NVL(graba.sitespecial,''),NVL(graba.meseshist,0),NVL(mov.ingreso,0),NVL(graba.creditoaut,0),NVL(graba.causa,0), NVL(graba.puntualidad,''),NVL(graba.sdoropa,0),
			NVL(graba.sdomuebles,0),NVL(graba.sdoprestamos,0),NVL(graba.vdoropa,0),NVL(graba.vdomuebles,0),NVL(graba.vdoprestamos,0),NVL(graba.abonomesropa,0),NVL(graba.abonomesmuebles,0),
			NVL(graba.abonomesprestamos,0),NVL(graba.fecha_ult_compra,''),
			mov.tipo_ingreso ,mov.periodicidad ,mov.importe_sol, mov.user_insert
		INTO   cNumCte ,  cSucursal, iEficiencia,cSitEsp,iMeseshist,dIngreso,iCreditoaut,sCausa,cPuntualidad,iSdoropa,iSdomuebles,	iSdoprestamos,iVdoropa,
		iVdomuebles,iVdoprestamos,iAbonomesropa,iAbonomesmuebles,iAbonomesprestamos,cFecha_ult_compra,
		iTpIngreso,iPeriodicidad,dImporteSol,cUsuario
		FROM "informix".ss_solicitudes_movil mov
		LEFT JOIN bdicred:"informix".sd_graba_respuesta_conscoppel graba ON (graba.empresa = pEmpresa AND graba.num_solicitud = pFolio) 
		WHERE 	mov.empresa  = pEmpresa 
		AND  mov.folio_movil = pFolio
		AND mov.producto = pProdSol;
		
		
		
		IF cFecha_ult_compra <> "" THEN
			LET dtFechaUltCompra = SUBSTR(cFecha_ult_compra,6,2)||'/'|| SUBSTR(cFecha_ult_compra,9,2) ||'/'|| SUBSTR(cFecha_ult_compra,1,4);
		ELSE
			LET dtFechaUltCompra = "";
		END IF;
			
		IF cNumCte <> '' THEN
				
			EXECUTE  PROCEDURE bdisolic:alta_sol_tc_cjunk
			(pEmpresa,cNumCte,pProdSol,cSucursal,cUsuario,'','',iEficiencia,cSitEsp,iMeseshist,dIngreso,
			iCreditoaut,sCausa,cPuntualidad,iSdoropa,iSdomuebles,iSdoprestamos,iVdoropa,iVdomuebles,iVdoprestamos,
			iAbonomesropa,iAbonomesmuebles,iAbonomesprestamos,dtFechaUltCompra )
			INTO cCodRet,cSolicitud;

			IF cCodRet::INTEGER  <> 0 THEN 
			--se registra información				
				UPDATE "informix".ss_solicitudes_movil		
				SET status = '3'--finalizado
				WHERE 	empresa  = pEmpresa 
				AND  folio_movil = pFolio
				AND producto = pProdSol;	
				RETURN cCodRet, "Ocurrio un error en la alta de la solicitud";  				
			ELSE
				UPDATE "informix".ss_solicitudes_movil		
				SET num_solicitud =cSolicitud 
				WHERE 	empresa  = pEmpresa 
				AND  folio_movil = pFolio
				AND producto = pProdSol;		
				
				UPDATE "informix".ss_solicitudes
				SET canal_sol = '2' WHERE numcte = cNumCte AND
				num_solicitud = cSolicitud; -- FJPR

				
				UPDATE bdinteg:"informix".si_solicitud_movil		
				SET num_tdc_coppel = CASE WHEN pProdSol = '6500' THEN cSolicitud ELSE num_tdc_coppel END  ,
				 num_prestamo = CASE WHEN pProdSol = '6300' THEN cSolicitud ELSE num_prestamo END  ,
				 num_tdc_bcoppel = CASE WHEN pProdSol = '6001' THEN cSolicitud ELSE num_tdc_bcoppel END   
				WHERE folio = pFolio;			

				-- ACTUALIZAMOS LA SOLICITUD 
				SELECT MAX(secuencia+1) INTO iSecuencia FROM "informix".ss_autorizacion_especial 
				WHERE empresa=pEmpresa 
				AND num_solicitud=cSolicitud;	
					
				INSERT INTO "informix".ss_autorizacion_especial
				(empresa,num_solicitud,numcte,secuencia,comentario,causa_solicitud,montolinea_ant,montolinea_nvo,status_ant,status_nvo,usuario_modif,fecha_modif,tipo_movimiento ) 
				VALUES(pEmpresa,cSolicitud,cNumCte,NVL(iSecuencia,1),"SOLICITUD MOVIL","",0,0,"","",cUsuario,today,'');
							

			END IF;
					
			SELECT  tp_solicitud  
				INTO cTipoSol
			FROM ss_solic_producto 
			WHERE num_producto =pProdSol;
					  
			INSERT INTO "informix".ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor )
			SELECT mov.empresa, mov.seccion, mov.grupo, mov.elemento,'01',cSolicitud, pesos.valor 		
			FROM "informix".ss_detalle_scoring_movil mov
			INNER join  "informix".ss_scoring_pesos pesos ON ( pesos. empresa = mov.empresa 
															   AND pesos.tp_solicitud = cTipoSol
															   AND pesos.grupo = mov.grupo
															   AND pesos.elemento = mov.elemento
															   AND pesos.seccion = mov.seccion)
			WHERE 	mov.empresa  = pEmpresa 
			AND  mov.folio_movil = pFolio;

			
				UPDATE "informix".ss_solicitudes_movil		
				SET status = '1'
				WHERE 	empresa  = pEmpresa 
				AND  folio_movil = pFolio
				AND producto = pProdSol;
				
				
			--se califica la solicitud
			
			EXECUTE PROCEDURE bdisolic:califica_scoring_cjunk 
			( pEmpresa ,cSolicitud ,'',	'',	dIngreso,iTpIngreso,iPeriodicidad, 	'',	'',	'',	'',	'',	'',	'',	dImporteSol)
			INTO cCodRet;	
			
			IF pProdSol = '6500' THEN
			
				SELECT num_solicitud 
					INTO   cSolicitud2 
				FROM "informix".ss_solicitudes_movil							
				WHERE 	empresa  = pEmpresa 
				AND  folio_movil = pFolio
				AND producto = '6001';	
				  
				 			 
				UPDATE "informix".ss_resum_scor_fin
				SET num_solicitud_ref = cSolicitud
				WHERE empresa =  '001'
				AND num_solicitud =  cSolicitud2;
				
				UPDATE "informix".ss_resum_scor_fin
				SET num_solicitud_ref = cSolicitud2
				WHERE empresa =  '001'
				AND num_solicitud =  cSolicitud;

				  
			END IF;
			
			
		END IF;
	END IF;
	
	RETURN cCodRet, cMensajeRet;  
END
END PROCEDURE
