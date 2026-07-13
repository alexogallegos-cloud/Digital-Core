CREATE PROCEDURE "informix".sp_registra_folio_movil(pEmpresa CHAR(3),
												pFolio CHAR(20), 
												pSucursal CHAR(4),
												pNumCte CHAR(20),
												pProducto CHAR(4),												
												pNumCteCop CHAR(20), 
												pIngreso  MONEY(14,2),
												pTpIngreso INTEGER, 
												pPeridicidad  INTEGER,
												pImporteSol   DECIMAL (18,2),
												pEjecutivo CHAR(10))
RETURNING CHAR(6);			
		  
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cCodRet1         CHAR(6); 
DEFINE cCodRet2         CHAR(6); 
DEFINE cCodRet3         CHAR(6); 
DEFINE cCodRet4         CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cMensajeRet2     CHAR(300);
DEFINE cMensajeRet3     CHAR(300);
DEFINE cMensajeRet4     CHAR(300);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cDescripcion		CHAR(40);
DEFINE cProd			CHAR(4);
DEFINE cTipoSol			CHAR(1);
DEFINE cPrioridad		CHAR(2);
DEFINE cNumCte		CHAR(20);
DEFINE cStatus		CHAR(1);
DEFINE cNumSol		CHAR(20);
---
DEFINE cSitPagoBanc1	CHAR(2);
DEFINE cSitPagoBanc2	CHAR(20);
DEFINE cSitPagoBanc3	CHAR(120);
DEFINE cSitPagoBanc4	CHAR(20);
DEFINE cSitPagoBanc5	CHAR(120);
DEFINE cSitPagoBanc6	CHAR(1);
DEFINE cSitPagoBanc7	CHAR(1);
DEFINE cSitPagoBanc8	SMALLINT;
DEFINE cSitPagoBanc9	CHAR(2);
DEFINE cSitPagoBanc10	CHAR(3);
DEFINE cSitPagoBanc11	CHAR(1);
DEFINE cSitPagoBanc12	CHAR(3);
DEFINE cSitPagoBanc13	CHAR(13);
DEFINE cSitPagoBanc14	CHAR(13);
DEFINE cSitPagoBanc15	CHAR(2);
DEFINE cSitPagoBanc16	CHAR(2);
DEFINE cSitPagoBanc17	CHAR(20);
DEFINE cBanderaAlta	CHAR(1);
DEFINE sMensaje	SMALLINT;
DEFINE sSecuencia	SMALLINT;
DEFINE cBandera	CHAR(1);
DEFINE cBanderacop	CHAR(1);
DEFINE cBanderatdc	CHAR(1);
DEFINE cOrigen	CHAR(1);
DEFINE cPuesto	CHAR(3);

 ---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cCodRet1            = "000000";
LET cCodRet2            = "000000";
LET cCodRet3            = "000000";
LET cMensajeRet         = "Se realizÃ³ la consulta correctamente";
LET cMensajeRet2        = "Se realizÃ³ la consulta correctamente";
LET cMensajeRet3        = "Se realizÃ³ la consulta correctamente";
LET cProd			= "";
LET cTipoSol		= "";
LET cPrioridad		= "";
LET cNumCte		= "";
LET cStatus		= "1";
LET cNumSol		= "";

LET cDescripcion	= "";
LET cSitPagoBanc1	= "";
LET cSitPagoBanc2	= "";
LET cSitPagoBanc3	= "";
LET cSitPagoBanc4	= "";
LET cSitPagoBanc5	= "";
LET cSitPagoBanc6	= "";
LET cSitPagoBanc7	= "";
LET cSitPagoBanc8	= 0;
LET cSitPagoBanc9	= "";
LET cSitPagoBanc10	= "";
LET cSitPagoBanc11	= "";
LET cSitPagoBanc12	= "";
LET cSitPagoBanc13	= "";
LET cSitPagoBanc14	= "";
LET cSitPagoBanc15	= "";
LET cSitPagoBanc16	= "";
LET cSitPagoBanc17	= "";
LET cBanderaAlta	= "0";
LET sMensaje	= 0;
LET sSecuencia	= 0;
LET  cBandera = '0';
LET  cBanderacop = '0';
LET  cBanderatdc = '0';
LET  cOrigen = '1';
LET  cPuesto = '1';
       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_registra_folio_movil.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') ='' OR  NVL(pFolio,'') ='' OR NVL(pNumCte,'') =''  THEN
				LET cMensajeRet         = "PARAMETROS DE ENTRADA INVALIDOS";
		RETURN cCodRet;
	ELSE
	
		SELECT numcte 
			INTO   cNumCte 
		FROM "informix".ss_solicitudes_movil							
		WHERE 	empresa  = pEmpresa 
		AND  folio_movil = pFolio
		AND producto = pProducto;
	
		IF NVL(cNumCte,'') = '' THEN
		
			
		
		SELECT puesto
		INTO cPuesto
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pEjecutivo;

		IF NVL(cPuesto,"") <> "" THEN
			LET cOrigen = '1';		ELSE
			LET cOrigen = '2';		END IF;
		
		IF (pProducto ='6500' AND NVL(pNumCteCop,'') <> '') THEN
			LET cStatus = '3'; --finalizado
		ELSE
			LET cStatus = '1';		END IF;
						
		--se registra informacion	
			INSERT INTO "informix".ss_solicitudes_movil
			(empresa ,folio_movil,producto, num_solicitud,status,numcte ,numcte_cop ,sucursal,ingreso  ,tipo_ingreso ,periodicidad ,importe_sol,origen,user_insert ,fecha_insert )
			VALUES(pEmpresa ,pFolio , pProducto,'',cStatus, pNumCte ,pNumCteCop ,pSucursal, pIngreso  ,pTpIngreso , pPeridicidad  ,pImporteSol,cOrigen,pEjecutivo, TODAY   );			
			IF cStatus = '3' THEN
				RETURN cCodRet;
			END IF;
			
		ELSE
			--error esta tramitando el producto 2 veces con el mismo folio
			RETURN cCodRet;
		END IF;
		--se precalifica la solicitud con la informaciÃ³n proporcionada
		EXECUTE PROCEDURE bdisolic:situacion_pago_banco_cjunk(pEmpresa,pNumCte,'6001',pSucursal,pEjecutivo,'0','0')
		INTO cCodRet1,cMensajeRet2, cSitPagoBanc1,cSitPagoBanc2,cSitPagoBanc3,cSitPagoBanc4,cSitPagoBanc5,cSitPagoBanc6,cSitPagoBanc7,
			cSitPagoBanc8,cSitPagoBanc9,cSitPagoBanc10,cSitPagoBanc11,cSitPagoBanc12,cSitPagoBanc13,
			cSitPagoBanc14,cSitPagoBanc15,cSitPagoBanc16,cSitPagoBanc17;
 				
	--si no se rechazo por situacion en banco y trae cliente coppel insertar en la tabla para consultar a copppel y termina el proceso
		IF cCodRet1::INTEGER <> 0 THEN										
			LET cBanderatdc ='1';
		END IF	
		
		IF NVL(pNumCteCop,'') <> '' THEN
		
			SELECT  num_solicitud
			INTO cNumSol
			FROM bdicred:"informix".sd_consultar_infoctecoppel
			WHERE num_solicitud = pFolio
			AND empresa = pEmpresa;
			
			
			IF NVL(cNumSol,'') = '' THEN
				INSERT INTO bdicred:"informix".sd_consultar_infoctecoppel
				(empresa, numcte, numcte_ref, num_solicitud, fecha_envio, hora_envio, status_envio, user_insert, fecha_insert,user_tramite,sucursal,origen)
				VALUES(pEmpresa,pNumCte,pNumCteCop,pFolio,TODAY,CURRENT HOUR TO FRACTION,0,USER,CURRENT,pEjecutivo,pSucursal,'2' );			
				--consultando a coppel
				LET  cBandera = '1';
				RETURN cCodRet;
			ELSE
				LET  cBandera = '0';
			END IF
		END IF;
		IF NVL(cBandera,'') = '0' THEN
			--se ejecuta para validar los datos del cte
			FOREACH EXECUTE PROCEDURE bdinteg:consultacatmensajesmaestro(2,1,'','',pNumCte)
				INTO cCodRet3,sMensaje,sSecuencia,cMensajeRet3
			END FOREACH;
			
			--se ejecuta para validar los datos del cte
			FOREACH EXECUTE PROCEDURE bdinteg:consultacatmensajesmaestro(1,1,'','',pNumCte)
				INTO cCodRet3,sMensaje,sSecuencia,cMensajeRet3
			END FOREACH;

			
		
			--SE VALIDA QUE PRODUCTOS SE VAN A OFRECER
			FOREACH EXECUTE PROCEDURE bdisolic:sp_obtiene_productos_cjunk_club
				( pEmpresa ,pSucursal ,pEjecutivo,'A', pNumCte, '0', '0',cBanderatdc, '0', '0', '0') 
				INTO cCodRet2,cProd,cTipoSol,cDescripcion,cPrioridad
		
				IF cProd= pProducto THEN
					LET cBanderaAlta = '1';
					EXIT FOREACH;
				END IF;			

			END FOREACH;
			
			IF NVL(cBanderaAlta,'') = '1' THEN
				EXECUTE PROCEDURE bdisolic:sp_registra_sol_movil(pEmpresa,pFolio,cProd) INTO cCodRet4,cMensajeRet4 ;				
			ELSE			
				UPDATE "informix".ss_solicitudes_movil		
				SET status = '3'--finalizado
				WHERE 	empresa  = pEmpresa 
				AND  folio_movil = pFolio
				AND producto = pProducto;
			END IF;
					
		END IF;				
		 
		
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
