CREATE PROCEDURE "informix".sp_mandamensaje_movil_pbas3 (pEmpresa CHAR(3), pNumCte CHAR(20),pStatusSol CHAR(2),pFolio CHAR(20),pProducto CHAR(4),pStatus CHAR(1))	

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);

DEFINE cNombre1      CHAR(26);
DEFINE cNomProd      CHAR(40);
DEFINE cTelCel      CHAR(13);
DEFINE cCorreo      CHAR(40);
DEFINE idCamp      CHAR(10);
DEFINE idCamp2      CHAR(10);

LET cNombre1   = "";
LET cNomProd   = "";
LET cTelCel    = "";
LET cCorreo    = "";
LET idCamp     = "";
LET idCamp2    = "";

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "000000";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/sp_mandamensaje_movil.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pFolio,'') = '' OR NVL(pProducto,'') = ''  THEN
		RETURN ;
	ELSE
	
		SELECT nombre1 
			INTO   cNombre1 
		FROM bdinteg:"informix".si_cliente 						
		WHERE 	empresa  = pEmpresa 
		AND numcte =pNumCte;
	
		SELECT nombre_prod 
			INTO   cNomProd 
		FROM bdicred:"informix".sd_definicion 						
		WHERE 	empresa  = pEmpresa 
		AND num_producto =pProducto;	
		
		SELECT LIMIT 1 telefono 
			INTO   cTelCel 
		FROM bdinteg:"informix".si_telefonos_actual 						
		WHERE empresa  = pEmpresa 
		AND numcte =pNumCte
		AND tipo_tel = 2;
		
		SELECT LIMIT 1 correo_elec 
			INTO   cCorreo 
		FROM bdinteg:"informix".si_correos 						
		WHERE empresa  = pEmpresa 
		AND numcte =pNumCte;
		
		IF  pStatus = '2' THEN
			LET idCamp ='SOLMOVPA';
			LET idCamp2 ='SOLMOVPA2';
		ELIF pStatus = '1' THEN
			LET idCamp ='SOLMOVTR';
			LET idCamp2 ='SOLMOVTR2';
		ELSE 
			IF  pStatus = '3' THEN
				LET idCamp ='SOLMOVRT';
				LET idCamp2 ='SOLMOVRT2';
			ELSE
				RETURN ;
			END IF;			
			
		END IF;
		
		IF NVL(cTelCel,'') <> '' THEN
			--insertar en la tabla para enviar sms
			--call bdimnsj:"informix".sp_registra_evento (1, idCamp , pNumCte, '' ,'', 1,TRIM(cNombre1),TRIM(pFolio),TRIM(cNomProd),'','',0,0,0,0,0, '', '')RETURNING cCodRet;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , idCamp ,idCamp , '000000000','', '','1', TRIM(cNombre1), TRIM(pFolio), TRIM(cNomProd), '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			UPDATE bdinteg:"informix".si_solicitud_movil 
				SET fecha_msj = CURRENT
			WHERE folio =pFolio;
		END IF;
		
		IF NVL(cCorreo,'') <> '' THEN
			--insertar en la tabla para enviar correo
			--call bdimnsj:"informix".sp_registra_evento (2, idCamp2 , pNumCte, '' ,'', 1,TRIM(cNombre1),TRIM(pFolio),TRIM(cNomProd),'','',0,0,0,0,0, '', '')RETURNING cCodRet;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2 , idCamp2 ,idCamp2 , '000000000','', '','1', TRIM(cNombre1), TRIM(pFolio), TRIM(cNomProd), '', '', '', '', '', '', '', cCorreo, '', 0, 0,0, 0, 0, current, current) INTO cCodRet;		
		END IF;
		
		
		
	END IF;		

RETURN ;

END
END PROCEDURE
