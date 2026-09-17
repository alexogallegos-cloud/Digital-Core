CREATE PROCEDURE "informix".sp_cancelaportanom_bpi (pEmpresa CHAR(3),pNumcte CHAR(20),pCtaOrdenante CHAR(20),pFolio CHAR(30),pFolioCancela CHAR(30),pUserCancela CHAR(8),pSucCancela CHAR(4))
RETURNING
	CHAR(5)   AS	vcCodRet;
	
	--DECLARA VARIABLES
	DEFINE cCodRet					CHAR (5);
	DEFINE cSqlErr					SMALLINT;
	DEFINE vcNumCte					CHAR(20);
	DEFINE viNumReg					SMALLINT;
	DEFINE vcCuenta					CHAR(20);
	
	--INICIALIZA VARIABLES
	LET cCodRet					= '00000';
	LET cSqlErr					= 0;
	LET vcNumCte				= '';
	LET	viNumReg				= 0;
	LET vcCuenta				= '';
	
	BEGIN
		ON EXCEPTION SET cSqlErr
			IF cSqlErr <> 0 THEN
				LET cCodRet = cSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		
		  --SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_cancelaportanom_bpi.out";
		  --TRACE ON;
		
		SET LOCK MODE TO WAIT 3;	
		
		SELECT cta_ordenante INTO vcCuenta FROM bdicheq:"informix".sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pNumcte AND folio_solicitud = pFolio;
				
		IF EXISTS (SELECT num_cte FROM bdicheq:"informix".sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pNumcte 	AND cta_ordenante = vcCuenta  AND folio_solicitud = pFolio) then
			
			SELECT {+INDEX (sc_maechq, idx_ctaclabe)} cuenta INTO vcCuenta FROM bdicheq:"informix".sc_maechq WHERE cuenta_clabe=pCtaOrdenante;
			IF EXISTS(SELECT cliente FROM bdicheq:"informix".sc_portabilidadnomina WHERE empresa = pEmpresa AND cliente = pNumcte and cuenta_abono = vcCuenta)THEN
							
				UPDATE bdicheq:"informix".sc_portabilidadnomina 
				SET estatus='02', user_cancel='transBPI', fecha_cancel=TODAY, origen_cancel='WEB', sucursal_cancel='5003' 
				WHERE empresa = pEmpresa AND cliente = pNumcte and cuenta_abono = vcCuenta;
				
				UPDATE bdicheq:"informix".sc_portacec_solicitud
				SET estatus_portabilidad='4', clave_sentido='0', folio_cancelacion=pFolioCancela, fecha_estatus_portabilidad= year(today)||lpad(month(today),2,0)||lpad(day(today),2,0)   ,fecha_solca_portabilidad= year(today)||lpad(month(today),2,0)||lpad(day(today),2,0) , clave_origen= '2', suc_cancela='5003', user_cancela='transBPI'
				WHERE empresa = pEmpresa AND num_cte = pNumcte AND cta_ordenante = pCtaOrdenante 
				AND folio_solicitud = pFolio;
				
			ELSE
				LET cCodRet = '002';			END IF;
		ELSE
			LET cCodRet = '001';		END IF;

		RETURN cCodRet;
	END;
END PROCEDURE;