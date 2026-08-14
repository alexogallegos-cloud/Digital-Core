CREATE PROCEDURE "informix".sp_consultareporteconsolidadosic(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(6), pFechaProceso DATE)
		RETURNING CHAR(5) AS codret,
				  CHAR(4) AS cNumProducto,
				  DATE    AS dFechaProceso,
				  CHAR(2) AS cTipoCred,
				  DECIMAL(18,2) AS  dSdoActualSicenv,  
				  DECIMAL(18,2) AS  dSdoVencidoSicenv, 
				  DECIMAL(18,2) AS  dSdoInsolutoSicenv,
				  DECIMAL(18,2) AS  dSdoActualSicexc,  
				  DECIMAL(18,2) AS  dSdoVencidoSicexc, 
				  DECIMAL(18,2) AS  dSdoInsolutoSicexc,
				  DECIMAL(18,2) AS  dSdoActualApp,   	
				  DECIMAL(18,2) AS  dSdoVencidoApp,   
				  DECIMAL(18,2) AS  dSdoInsolutoApp,   
				  DECIMAL(18,2) AS  dSdoActualDif,   	
				  DECIMAL(18,2) AS  dSdoVencidoDif,  	
				  DECIMAL(18,2) AS  dSdoInsolutoDif,  
				  DECIMAL(18,2) AS  dCredEnviados,   	
				  DECIMAL(18,2) AS  dCredExcluidos,   
				  DECIMAL(18,2) AS  dCredCentral,   	
				  DECIMAL(18,2) AS  dCredDiferencia;   
				  
	-- DECLARACION DE VARIABLES			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dSdoActualSicenv  	DECIMAL(18,2);
	DEFINE dSdoVencidoSicenv 	DECIMAL(18,2);
	DEFINE dSdoInsolutoSicenv   DECIMAL(18,2);
	DEFINE dSdoActualSicexc   	DECIMAL(18,2);
	DEFINE dSdoVencidoSicexc   	DECIMAL(18,2);
	DEFINE dSdoInsolutoSicexc   DECIMAL(18,2);
	DEFINE dSdoActualApp   		DECIMAL(18,2);
	DEFINE dSdoVencidoApp   	DECIMAL(18,2);
	DEFINE dSdoInsolutoApp   	DECIMAL(18,2);
	DEFINE dSdoActualDif   		DECIMAL(18,2);
	DEFINE dSdoVencidoDif  		DECIMAL(18,2);
	DEFINE dSdoInsolutoDif  	DECIMAL(18,2);
	DEFINE dCredEnviados   		DECIMAL(18,2);
	DEFINE dCredExcluidos   	DECIMAL(18,2);
	DEFINE dCredCentral   		DECIMAL(18,2);
	DEFINE dCredDiferencia   	DECIMAL(18,2);
	DEFINE cTipoCred  			CHAR(2);
	DEFINE cNumProducto			CHAR(4);
	DEFINE dFechaProceso		DATE;
	DEFINE cNombreProd			CHAR(80);
	
	-- INICIALIZACION DE VARIABLES
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dSdoActualSicenv   = 0;
	LET dSdoVencidoSicenv  = 0;
	LET dSdoInsolutoSicenv = 0;
	LET dSdoActualSicexc   = 0;
	LET dSdoVencidoSicexc  = 0;
	LET dSdoInsolutoSicexc = 0;
	LET dSdoActualApp      = 0;
	LET dSdoVencidoApp     = 0;
	LET dSdoInsolutoApp    = 0;
	LET dSdoActualDif      = 0;
	LET dSdoVencidoDif     = 0;
	LET dSdoInsolutoDif    = 0;
	LET dCredEnviados      = 0;
	LET dCredExcluidos     = 0;
	LET dCredCentral   	   = 0;
	LET	dCredDiferencia    = 0;
	LET cTipoCred = '';
	LET cNumProducto	= 0;
	LET dFechaProceso	= NULL;
	LET cNombreProd = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,
			dSdoActualApp,dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos,dCredCentral,dCredDiferencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultareporteconsolidadosic.out';
		--TRACE ON;
		
		--VALIDACION DE PARAMETROS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR  pNumProducto = '' OR pFechaProceso IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,
			dSdoActualApp,dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos,dCredCentral,dCredDiferencia;
		END IF;
		
		--VALIDACION DE NUMERO DE PRODUCTO VALIDO
		SELECT nombre_prod INTO cNombreProd FROM  bdicred:sd_definicion
		WHERE num_producto = pNumProducto AND num_producto <> '6900'  AND cod_tipcred IN ('03','05');
		IF DBINFO('sqlca.sqlerrd2')= 0 THEN
			LET cCodRet = '00057';
			RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,
			dSdoActualApp,dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos,dCredCentral,dCredDiferencia;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,
			dSdoActualApp,dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos,dCredCentral,dCredDiferencia;
		END IF;
		
		
		IF(pNumProducto IN('6300','6400')) THEN
			FOREACH SELECT tipo_cred,num_producto,fecha_proceso,SUM(sdo_actual_sicenv),SUM(sdo_vencido_sicenv),SUM(sdo_insoluto_sicenv),SUM(sdo_actual_sicexc),SUM(sdo_vencido_sicexc),
							SUM(sdo_insoluto_sicexc),SUM(sdo_actual_app),SUM(sdo_vencido_app),SUM(sdo_insoluto_app),SUM(sdo_actual_dif),SUM(sdo_vencido_dif),SUM(sdo_insoluto_dif),
								SUM(cred_enviados),SUM(cred_excluidos),SUM(cred_central), SUM(cred_diferencia)
					INTO cTipoCred,cNumProducto,dFechaProceso,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,dSdoActualApp,
						 dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos, dCredCentral,dCredDiferencia
					FROM bdiburo:br_concil_consolidado_cnr
					WHERE fecha_proceso = pFechaProceso AND  num_producto = pNumProducto
					GROUP BY num_producto, fecha_proceso, tipo_cred
				RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,
				dSdoActualApp,dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos,dCredCentral,dCredDiferencia WITH RESUME;
			END FOREACH;
			IF DBINFO('sqlca.sqlerrd2')= 0 THEN
				LET cCodRet = '00298';
				RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,
				dSdoActualApp,dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos,dCredCentral,dCredDiferencia;
			END IF;
		ELSE
			FOREACH SELECT tipo_cred,num_producto,fecha_proceso,SUM(sdo_actual_sicenv),SUM(sdo_vencido_sicenv),SUM(sdo_insoluto_sicenv),SUM(sdo_actual_sicexc),SUM(sdo_vencido_sicexc),
								SUM(sdo_insoluto_sicexc),SUM(sdo_actual_app),SUM(sdo_vencido_app),SUM(sdo_insoluto_app),SUM(sdo_actual_dif),SUM(sdo_vencido_dif),SUM(sdo_insoluto_dif),
								SUM(cred_enviados),SUM(cred_excluidos),SUM(cred_central), SUM(cred_diferencia)
					INTO cTipoCred,cNumProducto,dFechaProceso,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,dSdoActualApp,
						 dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos, dCredCentral,dCredDiferencia
					FROM bdiburo:br_concil_consolidado
					WHERE fecha_proceso = pFechaProceso AND  num_producto = pNumProducto
					GROUP BY num_producto, fecha_proceso, tipo_cred
				RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,
				dSdoActualApp,dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos,dCredCentral,dCredDiferencia WITH RESUME;
			END FOREACH;
			IF DBINFO('sqlca.sqlerrd2')= 0 THEN
				LET cCodRet = '00298';
				RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,dSdoActualSicenv,dSdoVencidoSicenv,dSdoInsolutoSicenv,dSdoActualSicexc,dSdoVencidoSicexc,dSdoInsolutoSicexc,
				dSdoActualApp,dSdoVencidoApp,dSdoInsolutoApp,dSdoActualDif,dSdoVencidoDif,dSdoInsolutoDif,dCredEnviados,dCredExcluidos,dCredCentral,dCredDiferencia;
			END IF;
		END IF;	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 05/06/2014',
'DESCRIPCION: Consulta de concentrado para reporte consolidado ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultareportedetallediferenciasic(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(6), pFechaProceso DATE, 
																   pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(4) AS cNumProducto,
				  DATE	  AS dFechaProceso,
				  CHAR(2) AS cTipoCred,
				  CHAR(20) AS cNumCredito,
				  DECIMAL(18,2) AS dSaldoActual,
				  DECIMAL(18,2) AS dSaldoVenc,
				  DECIMAL(18,2) AS dSaldoInsoluto,
				  DECIMAL(18,2) AS dSaldoActualApp,
				  DECIMAL(18,2) AS dSaldoVencApp,
				  DECIMAL(18,2) AS dSaldoInsolutoApp,
				  DECIMAL(18,2) AS dDsaldoActual,
				  DECIMAL(18,2) AS dDSaldoVenc,
				  DECIMAL(18,2) AS dDsaldoInsoluto;		
		
	DEFINE cCodRet 			 CHAR(5);
	DEFINE iSqlErr 			 INTEGER;
	DEFINE iNoRegistros 	 INTEGER;
	DEFINE iRegistros 		 INTEGER;
	DEFINE iRecuperacion 	 INTEGER;
	DEFINE cNumProducto		 CHAR(4);
	DEFINE dFechaProceso	 DATE;
	DEFINE cNombreProd		 CHAR(80);
	DEFINE cTipoCred		 CHAR(2);
	DEFINE cNumCredito		 CHAR(20);
	DEFINE dSaldoActual 	 DECIMAL(18,2);
	DEFINE dSaldoVenc 		 DECIMAL(18,2);
	DEFINE dSaldoInsoluto 	 DECIMAL(18,2);
	DEFINE dSaldoActualApp 	 DECIMAL(18,2);
	DEFINE dSaldoVencApp 	 DECIMAL(18,2);
	DEFINE dSaldoInsolutoApp DECIMAL(18,2);
	DEFINE dDsaldoActual 	 DECIMAL(18,2);
	DEFINE dDSaldoVenc 		 DECIMAL(18,2);
	DEFINE dDsaldoInsoluto 	 DECIMAL(18,2);
	
	
	LET cCodRet 		 = '00000';
	LET iSqlErr 		 = 0;
	LET iNoRegistros 	 = 0;
	LET iRegistros 		 = 0;
	LET iRecuperacion 	 = 0;
	LET cNumProducto	 = 0;
	LET dFechaProceso	 = NULL;
	LET cNombreProd 	 = '';
	LET cTipoCred		 = '';
	LET cNumCredito		 = '';
	LET dSaldoActual 	 = 0;
	LET dSaldoVenc 		 = 0;
	LET dSaldoInsoluto   = 0;
	LET dSaldoActualApp  = 0;
	LET dSaldoVencApp 	 = 0;
	LET dSaldoInsolutoApp = 0;
	LET dDsaldoActual 	 = 0;
	LET dDSaldoVenc 	 = 0;
	LET	dDsaldoInsoluto  = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,cNumCredito,dSaldoActual,dSaldoVenc,dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							   dDSaldoVenc,dDsaldoInsoluto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultareportedetallediferenciasic.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumProducto = '' OR pFechaProceso IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,cNumCredito,dSaldoActual,dSaldoVenc,dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							   dDSaldoVenc,dDsaldoInsoluto;
		END IF;
		
		
		SELECT nombre_prod INTO cNombreProd FROM  bdicred:sd_definicion
		WHERE num_producto = pNumProducto AND num_producto <> '6900'  AND cod_tipcred IN ('03','05');
		IF DBINFO('sqlca.sqlerrd2')= 0 THEN
			LET cCodRet = '00057';
			RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,cNumCredito,dSaldoActual,dSaldoVenc,dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							   dDSaldoVenc,dDsaldoInsoluto;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,cNumCredito,dSaldoActual,dSaldoVenc,dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							   dDSaldoVenc,dDsaldoInsoluto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,cNumCredito,dSaldoActual,dSaldoVenc,dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							   dDSaldoVenc,dDsaldoInsoluto;
		END IF;
		
		
		IF(pNumProducto IN('6300','6400')) THEN
				FOREACH SELECT  SKIP pRegistros FIRST pRecuperacion  num_producto,fecha_proceso,tipo_cred,num_credito,saldo_actual,saldo_venc,saldo_insoluto,saldo_actual_app,saldo_venc_app,saldo_insoluto_app,d_saldo_actual,
							   d_saldo_venc, d_saldo_insoluto
						INTO cNumProducto, dFechaProceso, cTipoCred, cNumCredito, dSaldoActual, dSaldoVenc, dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							 dDSaldoVenc, dDsaldoInsoluto
						FROM  bdiburo:br_concil_diferencias_cnr
						WHERE fecha_proceso = pFechaProceso AND  num_producto = pNumProducto
						
						RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,cNumCredito,dSaldoActual,dSaldoVenc,dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							   dDSaldoVenc,dDsaldoInsoluto WITH RESUME;
				END FOREACH;
				IF DBINFO('sqlca.sqlerrd2')= 0 THEN
					LET cCodRet = '00298';
					RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,cNumCredito,dSaldoActual,dSaldoVenc,dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							   dDSaldoVenc,dDsaldoInsoluto; 
				END IF;
				
		ELSE		
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  num_producto,fecha_proceso,tipo_cred,num_credito,saldo_actual,saldo_venc,saldo_insoluto,saldo_actual_app,saldo_venc_app,saldo_insoluto_app,d_saldo_actual,
							   d_saldo_venc, d_saldo_insoluto
						INTO cNumProducto, dFechaProceso, cTipoCred, cNumCredito, dSaldoActual, dSaldoVenc, dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							 dDSaldoVenc, dDsaldoInsoluto
						FROM  bdiburo:br_concil_diferencias
						WHERE fecha_proceso = pFechaProceso AND  num_producto = pNumProducto
						
						RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,cNumCredito,dSaldoActual,dSaldoVenc,dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							   dDSaldoVenc,dDsaldoInsoluto WITH RESUME;
				END FOREACH;
				IF DBINFO('sqlca.sqlerrd2')= 0 THEN
					LET cCodRet = '00298';
					RETURN cCodRet,cNumProducto,dFechaProceso,cTipoCred,cNumCredito,dSaldoActual,dSaldoVenc,dSaldoInsoluto,dSaldoActualApp,dSaldoVencApp,dSaldoInsolutoApp,dDsaldoActual,
							   dDSaldoVenc,dDsaldoInsoluto; 
				END IF;
	 	END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 05/06/2014',
'DESCRIPCION: Consulta de concentrado para reporte de detalle de diferencias',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validacte_transfer(cNumCtePrincipal CHAR(20))
				returning 
				CHAR(5)     AS Cod_Retorno,
                INT    		AS iTpo_cliente,
				CHAR(20)	AS cNumCte;
				
DEFINE iTpo_cliente		INT;
DEFINE cCodRet			CHAR(5);
DEFINE iExiste			INT; 
DEFINE iSql_err         INT; 
DEFINE cNumCte 			CHAR(20);
DEFINE cNumCteTf 		CHAR(20);

LET iTpo_cliente = 2;
LET iExiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ; 
LET cNumcte = "";
LET cNumcteTf = "";

BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet,iTpo_cliente,cNumCte;
          END IF;
     END EXCEPTION;

	 --SET DEBUG FILE TO "/informix/CHVN/transfer/sp_validacte_transfer.out";
     --TRACE ON;
	 
	 SELECT count(*)
	 INTO iExiste
	 FROM bditransfer:tf_maecte
	 WHERE numcte = cNumCtePrincipal;
	 
	  IF iExiste = 0 THEN
		SELECT FIRST 1 numcte, numcte_tf
		INTO cNumCte, cNumCteTf
		FROM bditransfer:tf_maecte
		WHERE numcte_tf = cNumCtePrincipal;
		IF cNumCteTf IS NOT NULL AND (cNumCte IS NULL or cNumCte = '') THEN
			LET iTpo_cliente = 1;
			LET cNumCtePrincipal = cNumCteTf;
			RETURN cCodRet,iTpo_cliente,cNumCtePrincipal;
		ELSE
		LET iTpo_cliente = 2;
		LET cNumCtePrincipal = cNumCte;
		END IF;
		LET iTpo_cliente = 2;
	 END IF;
	 
	 RETURN cCodRet,iTpo_cliente,cNumCtePrincipal;
END
END PROCEDURE;