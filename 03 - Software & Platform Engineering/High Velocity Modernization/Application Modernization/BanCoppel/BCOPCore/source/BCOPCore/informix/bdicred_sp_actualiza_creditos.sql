CREATE PROCEDURE "informix".sp_actualiza_creditos(pTipoProceso CHAR(3), pFechaInicial DATE, pFechaFinal DATE)

RETURNING 
		CHAR(100) AS Proceso,
		CHAR(6) AS CodRet,
		CHAR(100) AS DataError;

	 --DEFINICION DE VARIABLES--
    DEFINE iSqlErr					INTEGER;
	DEFINE iSamErr					INTEGER;
    DEFINE cCodRet      			CHAR(6);
	DEFINE dFechaIni        		DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaFin        		DATETIME YEAR TO FRACTION(5); 
	DEFINE cNumCte					CHAR(20);
	DEFINE cEstatus         		CHAR(1);
	DEFINE dFechaOper				DATETIME YEAR TO FRACTION(5);
	DEFINE cProceso					CHAR(100);
	DEFINE cVarDataErr				CHAR(100);
	DEFINE iEstatus,i				INTEGER;
	DEFINE sCommit          		SMALLINT;
	DEFINE iCont            		INTEGER;
	DEFINE iContador                INTEGER;
	DEFINE dFechaUltAcceso  		DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaReg				DATETIME YEAR TO FRACTION(5);
	DEFINE sServicio 				SMALLINT;
	DEFINE sExiste          		SMALLINT;
	DEFINE dNumVueltas      		DECIMAL(14,2);
	DEFINE sConsulta				SMALLINT;
	DEFINE cNumProducto       		CHAR(4);
	DEFINE cStatusCred        		CHAR(2);
	DEFINE iPlazo             		INTEGER;
	DEFINE cNumCredito        		CHAR(20);
	DEFINE dMontoOtorgado     		DECIMAL(14,2);
	DEFINE dFechaAlta         		DATE;
	DEFINE dFechaVencido      		DATE;
	DEFINE iDiasAtraso        		INTEGER;
	DEFINE dFechaUltimoPago   		DATE;
	DEFINE dFechaUltimoPagoh  		DATE;
	DEFINE dMontoUltimoPago   		DECIMAL(14,2);
	DEFINE dMontoUltimoPagoh  		DECIMAL(14,2);
	DEFINE cCumplioConvenio   		CHAR(1);
	DEFINE dSdoCapInsoluto    		DECIMAL(14,2);
	DEFINE cSucursal        		CHAR(4);
	DEFINE dFechaApertura  			DATE;
	DEFINE dNoTcAdi       			DECIMAL(14,2);
	DEFINE sSecuencia       		SMALLINT;
	DEFINE cNumTarjeta    	 		CHAR(20);
	DEFINE dExpiracion      		DATE;
	DEFINE cTipoTarjeta    			CHAR(1);
	DEFINE cStatusTar      			CHAR(1);
	DEFINE cTipoIngreso				CHAR(1);
	DEFINE dIngresoMensual			DECIMAL(14,2);
	DEFINE cPuesto					CHAR(2);
	DEFINE cNombreEmpresa			CHAR(60);
	DEFINE dAntiguedad				DECIMAL(14,2);
	DEFINE dAltaSol					DATE;
	DEFINE dF_primer_compra      	DATE;                               
	DEFINE dMonto_primer_compra  	DECIMAL(14,2);                      
	DEFINE cTrans_primer_compra  	CHAR(4);                            
	DEFINE dF_primer_disp        	DATE;                               
	DEFINE dMonto_primer_disp    	DECIMAL(14,2);                      
	DEFINE cTrans_primer_disp    	CHAR(4);                             
	DEFINE dTrans_ultimo_pago    	CHAR(4);                            
	DEFINE dAtm_disp_monto       	DECIMAL(14,2);                      
	DEFINE dAtm_disp_fecha       	DATE;                               
	DEFINE cAtm_disp_transacc    	CHAR(4);                            
	DEFINE dPos_disp_monto       	DECIMAL(14,2);                      
	DEFINE dPos_disp_fecha       	DATE;                               
	DEFINE cPos_disp_transacc    	CHAR(4);                            
	DEFINE dVnt_disp_monto       	DECIMAL(14,2);                      
	DEFINE dVnt_disp_fecha       	DATE;                               
	DEFINE dSaldo_maximo         	DECIMAL(14,2);                      
	DEFINE dFecha_sdo_maximo     	DATE;                               
	DEFINE dSaldo_max_facturado  	DECIMAL(14,2);                      
	DEFINE dFecha_ult_convenio   	DATE;                               
	DEFINE iNum_atm              	INTEGER;                            
	DEFINE dMonto_atm            	DECIMAL(14,2);                      
	DEFINE iNum_pos              	INTEGER;                            
	DEFINE dMonto_pos            	DECIMAL(14,2);                      
	DEFINE iNum_vtn              	INTEGER;                            
	DEFINE dMonto_vtn            	DECIMAL(14,2);                      
	DEFINE iNum_pagos            	INTEGER;                            
	DEFINE dMonto_pagos          	DECIMAL(14,2);                      
	DEFINE dFecha_vencido        	DATE;                               
	DEFINE dFecha_cancelacion    	DATE;                               
	DEFINE sNum_vencidos_his     	SMALLINT;                            
	DEFINE sNum_vencidos         	SMALLINT;                              
	DEFINE dAtm_disp_monto_h     	DECIMAL(14,2);                      
	DEFINE dAtm_disp_fecha_h     	DATE;                               
	DEFINE cAtm_disp_transacc_h  	CHAR(4);                            
	DEFINE dPos_disp_monto_h     	DECIMAL(14,2);                      
	DEFINE dPos_disp_fecha_h     	DATE;                               
	DEFINE cPos_disp_transacc_h  	CHAR(4);                            
	DEFINE dVnt_disp_monto_h     	DECIMAL(14,2);                      
	DEFINE dVnt_disp_fecha_h     	DATE;                               
	DEFINE dSaldo_maximo_h       	DECIMAL(14,2);                      
	DEFINE dFecha_sdo_maximo_h   	DATE;                               
	DEFINE dSaldo_max_facturado_h	DECIMAL(14,2);                      
	DEFINE dPago_mayor_h         	DECIMAL(14,2);                      
	DEFINE iNum_atm_h            	INTEGER;                            
	DEFINE dMonto_atm_h          	DECIMAL(14,2);                      
	DEFINE iNum_pos_h            	INTEGER;                            
	DEFINE dMonto_pos_h          	DECIMAL(14,2);                      
	DEFINE iNum_vtn_h            	INTEGER;                            
	DEFINE dMonto_vtn_h          	DECIMAL(14,2);                      
	DEFINE iNum_pagos_h          	INTEGER;                            
	DEFINE dMonto_pagos_h        	DECIMAL(14,2);                      
	DEFINE dFecha_vencido_h      	DATE;                               
	DEFINE dFecha_cancelacion_h  	DATE;                                
	DEFINE dFecha_ultima_compra  	DATE;                               
	DEFINE dMonto_ultima_compra  	DECIMAL(14,2);                      
	DEFINE cCumplio_convenio     	CHAR(1);                             
	DEFINE dFecha_ultima_compra_h	DATE;                               
	DEFINE dMonto_ultima_compra_h	DECIMAL(14,2);                      
	DEFINE dFecha_ultimo_pago_ch 	DATE;                               
	DEFINE dSaldo_maximo_ch      	DECIMAL(14,2);                      
	DEFINE dFecha_sdo_maximo_ch  	DATE;                               
	DEFINE dFecha_ultima_compra_ch	DATE;                               
	DEFINE dMonto_ultima_compra_ch	DECIMAL(14,2);                      
	DEFINE dAtm_disp_monto_ch     	DECIMAL(14,2);                      
	DEFINE dAtm_disp_fecha_ch     	DATE;                               
	DEFINE dPos_disp_monto_ch     	DECIMAL(14,2);                      
	DEFINE dPos_disp_fecha_ch     	DATE;                               
	DEFINE dVnt_disp_monto_ch     	DECIMAL(14,2);                      
	DEFINE dVnt_disp_fecha_ch     	DATE;                               
	DEFINE sNum_vencidos_ch       	SMALLINT;                           
	DEFINE dSaldo_max_facturado_ch	DECIMAL(14,2);                      
	DEFINE sNum_atm_ch            	SMALLINT;                           
	DEFINE dMonto_atm_ch          	DECIMAL(14,2);                      
	DEFINE sNum_pos_ch            	SMALLINT;                           
	DEFINE dMonto_pos_ch          	DECIMAL(14,2);                      
	DEFINE sNum_vtn_ch            	SMALLINT;                           
	DEFINE dMonto_vtn_ch          	DECIMAL(14,2);                      
	DEFINE sNum_pagos_ch          	SMALLINT;                           
	DEFINE dMonto_pagos_ch        	DECIMAL(14,2);                      
	DEFINE sNum_atmc              	SMALLINT;                           
	DEFINE dMonto_atmc            	DECIMAL(14,2);                      
	DEFINE sNum_posc              	SMALLINT;                           
	DEFINE dMonto_posc            	DECIMAL(14,2);                      
	DEFINE sNum_vtnc              	SMALLINT;                           
	DEFINE dMonto_vtnc            	DECIMAL(14,2);                      
	DEFINE sNum_pagosc            	SMALLINT;                           
	DEFINE dMonto_pagosc          	DECIMAL(14,2);                      
	DEFINE sComportamiento        	SMALLINT;                           
	DEFINE dFechaultimocambio     	DATETIME YEAR TO FRACTION(3); 
	DEFINE dFechaInicialIvr         DATE;
	DEFINE dFechaFinalIvr           DATE;
	DEFINE cNomMod					CHAR(100);
	DEFINE dFechaInicialCrd			DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaFinalCrd			DATETIME YEAR TO FRACTION(5);
	DEFINE cStmt                    CHAR (500);
	DEFINE cRutaOltp                CHAR(50);

	--INICIALIZACION DE VARIABLES--
    LET iSqlErr 				= 0;
    LET cCodRet 				= '00000';
	LET dFechaIni   			= '';
	LET dFechaFin	    		= '';
	LET cNumCte	     			= '';
	LET cEstatus  				= '';
	LET dFechaOper     			= '';
	LET cProceso 				= 'sp_actualiza_creditos';
	LET cVarDataErr 			= 'EJECUCION EXITOSA';
	LET iEstatus        		= 1;
	LET iCont	        		= 0;
	LET iContador				= 0;
	LET sCommit         		= 0;
	LET dFechaUltAcceso 		= '';
	LET dFechaReg				= '';
	LET sServicio 				= 0;
	LET sExiste         		= 0;
	LET dNumVueltas     		= 0.00;
	LET sConsulta				= 0; 
	LET cNumProducto       		= '';     
	LET cStatusCred        		= '';    
	LET iPlazo             		= 0;
	LET cNumCredito        		= '';    
	LET dMontoOtorgado     		= '';       
	LET dFechaAlta         		= '';   
	LET dFechaVencido      		= '';      
	LET iDiasAtraso        		= 0;    
	LET dFechaUltimoPago   		= '';         
	LET dFechaUltimoPagoh  		= '';          
	LET dMontoUltimoPago   		= '';         
	LET dMontoUltimoPagoh  		= '';          
	LET cCumplioConvenio   		= '';         
	LET dSdoCapInsoluto    		= '';
	LET cSucursal          		= '';     
	LET dFechaApertura     		= '';
	LET dNoTcAdi           		= '';
	LET sSecuencia         		= 0;
	LET cNumTarjeta        		= '';
	LET dExpiracion        		= '';  
	LET cTipoTarjeta       		= '';
	LET cStatusTar         		= '';
	LET cTipoIngreso			= '';		
	LET dIngresoMensual			= '';
	LET cPuesto					= '';
	LET cNombreEmpresa			= '';
	LET dAntiguedad				= '';
	LET dAltaSol				= '';
	LET dF_primer_compra  		  = '';              	
	LET dMonto_primer_compra  	  = '';  
	LET cTrans_primer_compra  	  = '';        
	LET dF_primer_disp        	  = '';           
	LET dMonto_primer_disp    	  = '';  
	LET cTrans_primer_disp    	  = '';  
	LET dTrans_ultimo_pago    	  = '';  
	LET dAtm_disp_monto       	  = '';  
	LET dAtm_disp_fecha       	  = '';  
	LET cAtm_disp_transacc    	  = '';  
	LET dPos_disp_monto       	  = '';  
	LET dPos_disp_fecha       	  = '';  
	LET cPos_disp_transacc    	  = '';  
	LET dVnt_disp_monto       	  = '';  
	LET dVnt_disp_fecha       	  = '';  
	LET dSaldo_maximo         	  = '';  
	LET dFecha_sdo_maximo     	  = '';  
	LET dSaldo_max_facturado  	  = '';  
	LET dFecha_ult_convenio   	  = '';  
	LET iNum_atm              	  = 0;   
	LET dMonto_atm            	  = '';  
	LET iNum_pos              	  = 0;   
	LET dMonto_pos            	  = '';  
	LET iNum_vtn              	  = 0;   
	LET dMonto_vtn            	  = '';  
	LET iNum_pagos            	  = 0;   
	LET dMonto_pagos          	  = '';  
	LET dFecha_vencido        	  = '';  
	LET dFecha_cancelacion    	  = '';  
	LET sNum_vencidos_his     	  = 0;   
	LET sNum_vencidos         	  = 0;   
	LET dAtm_disp_monto_h     	  = '';  
	LET dAtm_disp_fecha_h     	  = '';  
	LET cAtm_disp_transacc_h  	  = '';  
	LET dPos_disp_monto_h     	  = '';  
	LET dPos_disp_fecha_h     	  = '';  
	LET cPos_disp_transacc_h  	  = '';  
	LET dVnt_disp_monto_h     	  = '';  
	LET dVnt_disp_fecha_h     	  = '';  
	LET dSaldo_maximo_h       	  = '';  
	LET dFecha_sdo_maximo_h   	  = '';  
	LET dSaldo_max_facturado_h	  = '';  
	LET dPago_mayor_h         	  = '';  
	LET iNum_atm_h            	  = 0;   
	LET dMonto_atm_h          	  = '';  
	LET iNum_pos_h            	  = 0;   
	LET dMonto_pos_h          	  = '';  
	LET iNum_vtn_h            	  = 0;   
	LET dMonto_vtn_h          	  = '';  
	LET iNum_pagos_h          	  = 0;   
	LET dMonto_pagos_h        	  = '';  
	LET dFecha_vencido_h      	  = '';  
	LET dFecha_cancelacion_h  	  = '';  
	LET dFecha_ultima_compra  	  = '';  
	LET dMonto_ultima_compra  	  = '';  
	LET cCumplio_convenio     	  = '';  
	LET dFecha_ultima_compra_h	  = '';  
	LET dMonto_ultima_compra_h	  = '';  
	LET dFecha_ultimo_pago_ch 	  = '';  
	LET dSaldo_maximo_ch      	  = '';  
	LET dFecha_sdo_maximo_ch  	  = '';  
	LET dFecha_ultima_compra_ch	  = '';  
	LET dMonto_ultima_compra_ch	  = '';  
	LET dAtm_disp_monto_ch     	  = '';  
	LET dAtm_disp_fecha_ch     	  = '';  
	LET dPos_disp_monto_ch     	  = '';  
	LET dPos_disp_fecha_ch     	  = '';  
	LET dVnt_disp_monto_ch     	  = '';  
	LET dVnt_disp_fecha_ch     	  = '';  
	LET sNum_vencidos_ch       	  = 0;   
	LET dSaldo_max_facturado_ch	  = '';  
	LET sNum_atm_ch            	  = 0;   
	LET dMonto_atm_ch          	  = '';  
	LET sNum_pos_ch            	  = 0;   
	LET dMonto_pos_ch          	  = '';  
	LET sNum_vtn_ch            	  = 0;   
	LET dMonto_vtn_ch          	  = '';  
	LET sNum_pagos_ch          	  = 0;   
	LET dMonto_pagos_ch        	  = '';  
	LET sNum_atmc              	  = 0;   
	LET dMonto_atmc            	  = '';  
	LET sNum_posc              	  = 0;   
	LET dMonto_posc            	  = '';  
	LET sNum_vtnc              	  = 0;   
	LET dMonto_vtnc            	  = '';  
	LET sNum_pagosc            	  = 0;   
	LET dMonto_pagosc          	  = '';  
	LET sComportamiento        	  = 0;   
	LET dFechaultimocambio     	  = '';  
	LET dF_primer_compra  		  = '';              	
	LET dMonto_primer_compra  	  = '';  
	LET cTrans_primer_compra  	  = '';        
	LET dF_primer_disp        	  = '';           
	LET dMonto_primer_disp    	  = '';  
	LET cTrans_primer_disp    	  = '';  
	LET dTrans_ultimo_pago    	  = '';  
	LET dAtm_disp_monto       	  = '';  
	LET dAtm_disp_fecha       	  = '';  
	LET cAtm_disp_transacc    	  = '';  
	LET dPos_disp_monto       	  = '';  
	LET dPos_disp_fecha       	  = '';  
	LET cPos_disp_transacc    	  = '';  
	LET dVnt_disp_monto       	  = '';  
	LET dVnt_disp_fecha       	  = '';  
	LET dSaldo_maximo         	  = '';  
	LET dFecha_sdo_maximo     	  = '';  
	LET dSaldo_max_facturado  	  = '';  
	LET dFecha_ult_convenio   	  = '';  
	LET iNum_atm              	  = 0;   
	LET dMonto_atm            	  = '';  
	LET iNum_pos              	  = 0;   
	LET dMonto_pos            	  = '';  
	LET iNum_vtn              	  = 0;   
	LET dMonto_vtn            	  = '';  
	LET iNum_pagos            	  = 0;   
	LET dMonto_pagos          	  = '';  
	LET dFecha_vencido        	  = '';  
	LET dFecha_cancelacion    	  = '';  
	LET sNum_vencidos_his     	  = 0;   
	LET sNum_vencidos         	  = 0;   
	LET dAtm_disp_monto_h     	  = '';  
	LET dAtm_disp_fecha_h     	  = '';  
	LET cAtm_disp_transacc_h  	  = '';  
	LET dPos_disp_monto_h     	  = '';  
	LET dPos_disp_fecha_h     	  = '';  
	LET cPos_disp_transacc_h  	  = '';  
	LET dVnt_disp_monto_h     	  = '';  
	LET dVnt_disp_fecha_h     	  = '';  
	LET dSaldo_maximo_h       	  = '';  
	LET dFecha_sdo_maximo_h   	  = '';  
	LET dSaldo_max_facturado_h	  = '';  
	LET dPago_mayor_h         	  = '';  
	LET iNum_atm_h            	  = 0;   
	LET dMonto_atm_h          	  = '';  
	LET iNum_pos_h            	  = 0;   
	LET dMonto_pos_h          	  = '';  
	LET iNum_vtn_h            	  = 0;   
	LET dMonto_vtn_h          	  = '';  
	LET iNum_pagos_h          	  = 0;   
	LET dMonto_pagos_h        	  = '';  
	LET dFecha_vencido_h      	  = '';  
	LET dFecha_cancelacion_h  	  = '';  
	LET dFecha_ultima_compra  	  = '';  
	LET dMonto_ultima_compra  	  = '';  
	LET cCumplio_convenio     	  = '';  
	LET dFecha_ultima_compra_h	  = '';  
	LET dMonto_ultima_compra_h	  = '';  
	LET dFecha_ultimo_pago_ch 	  = '';  
	LET dSaldo_maximo_ch      	  = '';  
	LET dFecha_sdo_maximo_ch  	  = '';  
	LET dFecha_ultima_compra_ch	  = '';  
	LET dMonto_ultima_compra_ch	  = '';  
	LET dAtm_disp_monto_ch     	  = '';  
	LET dAtm_disp_fecha_ch     	  = '';  
	LET dPos_disp_monto_ch     	  = '';  
	LET dPos_disp_fecha_ch     	  = '';  
	LET dVnt_disp_monto_ch     	  = '';  
	LET dVnt_disp_fecha_ch     	  = '';  
	LET sNum_vencidos_ch       	  = 0;   
	LET dSaldo_max_facturado_ch	  = '';  
	LET sNum_atm_ch            	  = 0;   
	LET dMonto_atm_ch          	  = '';  
	LET sNum_pos_ch            	  = 0;   
	LET dMonto_pos_ch          	  = '';  
	LET sNum_vtn_ch            	  = 0;   
	LET dMonto_vtn_ch          	  = '';  
	LET sNum_pagos_ch          	  = 0;   
	LET dMonto_pagos_ch        	  = '';  
	LET sNum_atmc              	  = 0;   
	LET dMonto_atmc            	  = '';  
	LET sNum_posc              	  = 0;   
	LET dMonto_posc            	  = '';  
	LET sNum_vtnc              	  = 0;   
	LET dMonto_vtnc            	  = '';  
	LET sNum_pagosc            	  = 0;   
	LET dMonto_pagosc          	  = '';  
	LET sComportamiento        	  = 0;   
	LET dFechaultimocambio     	  = '';  
	LET dFechaInicialIvr         = '';
	LET dFechaFinalIvr           = '';
	LET cNomMod					 ='';
	LET dFechaInicialCrd		 ='';
	LET dFechaFinalCrd			 ='';
	LET cStmt                    = '';
	LET cRutaOltp                = '/RESPALDOSNEW/depuraremesas/';

    --SET DEBUG FILE TO "/RESPALDOSNEW/enrique/sp_actualiza_creditos_ljfs.out";
    --TRACE ON;
	
	BEGIN
		--MANEJO DEL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
				IF iSqlErr <> 0 THEN
					LET cCodRet=iSqlErr;
				IF (sCommit = -1) THEN
					ROLLBACK WORK;
				END IF;
				LET cVarDataErr = 'ERROR NO CONTROLADO'||' '||TRIM(pTipoProceso);
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, tipo_proceso)
				VALUES (cProceso, dFechaIni, CURRENT, cCodRet , cVarDataErr, pTipoProceso);
					
				RETURN cProceso,cCodRet, cVarDataErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaIni
		FROM    sysmaster:"informix".sysshmvals;
		
		-- USA INDICADORES CREDITO MODIFICADO POR LJFS 23/01/2017
		TRUNCATE TABLE bdicred:"informix".tmp_unica_paso;
		TRUNCATE TABLE bdicred:"informix".tmp_unica_univ;
		-- FIN
		-- USA PLAZO CREDITO MODIFICADO POR LJFS 23/01/2017
		DROP TABLE IF EXISTS bdicred:tmp_plazo_cred_1;
		DROP TABLE IF EXISTS bdicred:tmp_uni_cred_plazo;
		-- FIN
		-- USA CREDITO MODIFICADO POR LJFS 23/01/2017
		DROP TABLE IF EXISTS bdicred:tmp_credito_1;
		DROP TABLE IF EXISTS bdicred:tmp_uni_credito;
		-- FIN
		-- USA VAR CREDITO MODIFICADO POR LJFS 23/01/2017
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_1;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_2;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_3;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_4;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_actual;
		-- FIN
		
		---VALIDA PARAMETROS 
		IF NVL(pTipoProceso,'') = '' OR NVL(pFechaInicial,'')='' OR NVL(pFechaFinal,'')='' THEN
			LET cCodRet =   '00001';
			LET iEstatus=0;
			
			LET cVarDataErr = 'UNO O MAS PARAMETROS VACIOS'||' '||TRIM(pTipoProceso);
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion, tipo_proceso)
			VALUES (cProceso, dFechaIni, CURRENT, iEstatus, cVarDataErr, pTipoProceso);
				
			RETURN cProceso,cCodRet, cVarDataErr;
		END IF;
		
		IF pFechaFinal > CURRENT::DATE THEN
			LET cCodRet =   '00002'; 
			LET iEstatus=0;
			LET cVarDataErr="FECHA FINAL ES MAYOR A LA FECHA DE HOY"||' '||TRIM(pTipoProceso);
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
			VALUES (cProceso, dFechaIni, CURRENT, iEstatus, cVarDataErr, pTipoProceso);
					
			RETURN cProceso,cCodRet, cVarDataErr;
		END IF;
		
		IF pFechaInicial > pFechaFinal THEN
			LET cCodRet =   '00003'; 
			LET iEstatus=0;
			LET cVarDataErr="FECHA INICIO ES MAYOR A LA FECHA FIN"||' '||TRIM(pTipoProceso);
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin,status_ejecucion, observacion, tipo_proceso)
			VALUES (cProceso, dFechaIni, CURRENT, iEstatus, cVarDataErr, pTipoProceso);
			RETURN cProceso,cCodRet, cVarDataErr;
			
		END IF; --TERMINNA DE VALIDAR PARAMETROS
	
	
	
	IF (UPPER(pTipoProceso) = 'PCR') THEN --UNI_CRED_PLAZO PROCESO MODIFICADO POR LJFS 23/08/2018

		SELECT DISTINCT e.num_credito 
						FROM TABLE(MULTISET(
											SELECT  a.num_credito
											FROM    bdicred:"informix".sd_maecredcrd a
											WHERE   a.empresa = '001'
											AND     a.fecha_apertura > pFechaInicial
											AND     a.fecha_apertura <= pFechaFinal
											UNION
											SELECT  b.num_credito
											FROM    bdicred:"informix".sd_indicador_cred_crd b
											WHERE   b.empresa = '001'
											AND     (b.fecha_alta > pFechaInicial OR fecha_vencido > pFechaInicial OR fecha_ultimo_pago > pFechaInicial OR fecha_ultimo_pago_h > pFechaInicial)
											AND     (b.fecha_alta <= pFechaFinal OR fecha_vencido <= pFechaFinal OR fecha_ultimo_pago <= pFechaFinal OR fecha_ultimo_pago_h <= pFechaFinal)
								  )) e
		INTO TEMP tmp_plazo_cred_1 WITH NO LOG;
		DROP TABLE IF EXISTS tmp_uni_cred_plazo;
		SELECT  h.numcte,
				h.num_producto,
				h.status_cred,
				h.plazo,
				f.num_credito,
				j.monto_otorgado as linea_credito,
				i.fecha_alta,
				i.fecha_vencido,
				i.dias_atraso,
				i.fecha_ultimo_pago,
				i.fecha_ultimo_pago_h,
				i.monto_ultimo_pago,
				i.monto_ultimo_pago_h,
				i.cumplio_convenio,
				j.sdo_cap_insoluto
		FROM    bdicred:tmp_plazo_cred_1 f,
				bdicred:"informix".sd_maecredcrd h,
				bdicred:"informix".sd_indicador_cred_crd i,
				bdicred:"informix".sd_maesdoscrd j
		WHERE   h.num_credito = f.num_credito
		AND     i.num_credito = f.num_credito
		AND     j.num_credito = f.num_credito
		INTO tmp_uni_cred_plazo;
		
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'uni_cred1_pcr.unl SELECT * FROM tmp_uni_cred_plazo;">' || TRIM(cRutaOltp) || 'u_uni_cred_plazo.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_uni_cred_plazo.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdicred ' || TRIM(cRutaOltp) || 'u_uni_cred_plazo.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_uni_cred_plazo.sql';
		SYSTEM cStmt;
		
		
		LET cVarDataErr = 'EJECUCION EXITOSA PCR';

		DROP TABLE bdicred:tmp_plazo_cred_1;
		DROP TABLE IF EXISTS tmp_uni_cred_plazo;

		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTA REGISTRO SOBRE EL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProceso);
		
	END IF;
	
	
		
	IF (UPPER(pTipoProceso) = 'CRD') THEN --UNI_CREDITO PROCESO MODIFICADO POR LJFS 23/08/2018

		--===========CREA TABLAS TEMPORALES PARA CONSIDERAR CAMBIOS EN TARJETAS Y CREDITOS APERTURADOS EL DIA ANTERIOR  |  NMR 05MAR19==================
			DROP TABLE IF EXISTS tmp_credito_1;
			DROP TABLE IF EXISTS tmp_uni_credito;
			DROP TABLE IF EXISTS creditoDia;
			DROP TABLE IF EXISTS tarjetaConcentrado;

			--BUSCA CREDITOS APERTURADOS EL DÃÂA DE AYER
			SELECT trim(num_credito)num_credito FROM bdicred:sd_maecred 
	        WHERE fecha_apertura=today-1 
	        INTO temp creditoDia WITH NO LOG;

	        --BUSCA TARJETAS DE CREDITOS APERTURADOS EL DÃÂA DE AYER
	        SELECT num_tarjeta FROM bdicred:sd_tarjeta 
	        WHERE num_credito in(SELECT * FROM creditoDia)
	        INTO TEMP tarjetaConcentrado WITH NO LOG;

	        --AGREGA A LA TABLA TEMPORAL LAS TARJETAS ASIGNADAS/ACTIVADAS EL DÃÂA DE AYER
	        INSERT INTO tarjetaConcentrado
	        SELECT numtarjeta FROM intercard:bitasignacionactivaciontarjeta 
	        WHERE (numtarjeta like '426807%' or numtarjeta like '554948%' or numtarjeta like '510148%')
	        AND fecharegistro between EXTEND(TODAY-1, YEAR to SECOND)+0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND 
	                            AND EXTEND(TODAY, YEAR to SECOND)+0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND ;

	        --AGREGA A LA TABLA TEMPORAL LAS TARJETAS CON CAMBIO DE ESTATUS EL DÃÂA DE AYER
	        INSERT INTO tarjetaConcentrado
	        SELECT tarjeta FROM intercard:bitacoracambiosstatustarjeta 
	        WHERE (tarjeta like '426807%' or tarjeta like '554948%' or tarjeta like '510148%')
	        AND fechahora between EXTEND(TODAY-1, YEAR to SECOND)+0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND 
	                                    AND EXTEND(TODAY, YEAR to SECOND)+0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND;

	        --TARJETAS CON OTROS CAMBIOS EL DÃÂA DE AYER
	        INSERT INTO tarjetaConcentrado
	        SELECT tarjeta FROM intercard:bitacoracambiostarjeta 
	        WHERE (tarjeta like '426807%' or tarjeta like '554948%' or tarjeta like '510148%')
	        and fechacambio between EXTEND(TODAY-1, YEAR to SECOND)+0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND 
	                            AND EXTEND(TODAY, YEAR to SECOND)+0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND;

	        --LLENA TABLA TEMPORAL DE CREDITOS
	        SELECT DISTINCT b.num_credito 
            FROM TABLE(MULTISET(
                                SELECT a.num_credito
                                FROM bdicred:"informix".sd_tarjeta a
                                WHERE num_tarjeta in (SELECT * FROM tarjetaConcentrado)
                                )) b
            INTO TEMP tmp_credito_1 WITH NO LOG;
	        CREATE INDEX idx_num_cred_temp ON tmp_credito_1(num_credito);
	        UPDATE STATISTICS MEDIUM FOR TABLE tmp_credito_1;

			DROP TABLE IF EXISTS tmp_uni_credito;
	        SELECT d.numcte, 
		        t.num_credito,
		        d.num_producto,
		        d.sucursal,
		        d.status_cred,
		        d.fecha_apertura, 
		        f.monto_otorgado AS linea_credito,
		        (SELECT	COUNT(g.tipo_tarjeta)
			        FROM bdicred:"informix".sd_tarjeta g
			        WHERE g.status_tar = 'A'
			        AND	g.tipo_tarjeta = 'A' 
			        AND	g.num_credito = d.num_credito) AS no_tc_adi,
		        e.secuencia,
		        e.num_tarjeta,
		        e.expiracion,
		        e.tipo_tarjeta,
		        e.status_tar
	        FROM bdicred:tmp_credito_1 t,
		        bdicred:"informix".sd_maecred d,
		        bdicred:"informix".sd_tarjeta e,
		        bdicred:"informix".sd_maesdos f
	        WHERE t.num_credito = d.num_credito
		        AND d.num_credito = e.num_credito
		        AND d.num_credito = f.num_credito
		        AND e.num_tarjeta in(SELECT distinct num_tarjeta FROM tarjetaConcentrado)
	        GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
	        INTO tmp_uni_credito;
		--================================================================================================================================================
			
			LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'uni_cred1_crd.unl SELECT * FROM tmp_uni_credito;">' || TRIM(cRutaOltp) || 'u_uni_credito.sql';
			SYSTEM cStmt;
			LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_uni_credito.sql';
			SYSTEM cStmt;
			LET cStmt= 'dbaccess bdicred ' || TRIM(cRutaOltp) || 'u_uni_credito.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_uni_credito.sql';
			SYSTEM cStmt;
					  
			LET cVarDataErr = 'EJECUCION EXITOSA CRD';

			DROP TABLE IF EXISTS tmp_credito_1;
			DROP TABLE IF EXISTS tmp_uni_credito;
			DROP TABLE IF EXISTS creditoDia;
			DROP TABLE IF EXISTS tarjetaConcentrado;
			DROP TABLE IF EXISTS tmp_uni_credito;

			SELECT  DBINFO('utc_to_datetime',sh_curtime)
			INTO    dFechaFin
			FROM    sysmaster:"informix".sysshmvals;

			--INSERTA REGISTRO SOBRE EL PROCESO
			INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
			VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProceso);

	END IF;


		
	IF (UPPER(pTipoProceso) = 'VCR') THEN -- UNI_VAR_CREDITO PROCESO MODIFICADO POR LJFS 23/08/2018
	
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_1;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_2;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_3;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_4;
		DROP TABLE IF EXISTS bdicred:tmp_uni_var_credito;
		DROP TABLE IF EXISTS tmp_uni_credito_vcr;

		SELECT  DISTINCT b.numcte, b.num_credito, b.num_producto, b.fecha_apertura
		FROM    TABLE(MULTISET(
							   SELECT  a.numcte,
									   a.num_credito,
									   a.num_producto,
									   a.fecha_apertura
							   FROM    bdicred:"informix".sd_maecred a
							   WHERE   a.empresa = '001'
							   AND     (a.fecha_apertura > pFechaInicial OR a.fecha_pago_cap > pFechaInicial OR a.fecha_pago_int > pFechaInicial)
							   AND     (a.fecha_apertura <= pFechaFinal OR a.fecha_pago_cap <= pFechaFinal OR a.fecha_pago_int <= pFechaFinal)
							 ))b
		INTO TEMP tmp_var_credito_1 WITH NO LOG;

		SELECT  DISTINCT f.numcte, f.secing
		FROM    TABLE(MULTISET(
							   SELECT   d.numcte,
										MAX(e.sec_ingreso) AS secing
							   FROM     bdicred:tmp_var_credito_1 d,
										bdinteg:"informix".si_ingresos e
							   WHERE    e.empresa = '001'
							   AND      e.numcte = d.numcte
							   GROUP BY d.numcte
							 )) f
		INTO TEMP tmp_var_credito_2 WITH NO LOG;

		SELECT  DISTINCT j.numcte, j.num_solicitud, j.alta_sol
		FROM    TABLE(MULTISET(
							   SELECT  h.numcte,
									   num_solicitud,
									   fecha_insert AS  alta_sol
							   FROM    tmp_var_credito_1 h,
									   bdisolic:"informix".ss_solicitudes i
							   WHERE   i.numcte = h.numcte
							   AND     i.num_solicitud = h.num_credito
							)) j
		INTO TEMP tmp_var_credito_3 WITH NO LOG;

		SELECT  l.numcte,
				l.num_credito,
				l.num_producto,
				l.fecha_apertura,
				n.secing,
				o.alta_sol
		FROM    bdicred:tmp_var_credito_1 l,
				bdicred:tmp_var_credito_2 n,
				bdicred:tmp_var_credito_3 o
		WHERE   n.numcte = l.numcte
		AND     o.numcte = l.numcte
		INTO TEMP tmp_var_credito_4 WITH NO LOG;

		SELECT  q.numcte,
				r.tipo_ingreso,
				r.ingreso_mensual,
				r.puesto,
				r.nombre_empresa,
				r.antiguedad,
				q.num_credito,
				q.num_producto,
				q.fecha_apertura,
				q.alta_sol
		FROM    bdicred:tmp_var_credito_4 q,
				bdinteg:"informix".si_ingresos r
		WHERE   r.numcte = q.numcte
		AND     r.sec_ingreso = q.secing
		INTO TEMP tmp_uni_var_credito WITH NO LOG;
		
		SELECT	s.numcte, s.tipo_ingreso, s.ingreso_mensual, s.puesto, s.nombre_empresa,
				s.antiguedad, s.num_credito, s.num_producto, s.fecha_apertura, s.alta_sol		
		FROM 	bdicred:tmp_uni_var_credito s
		INTO tmp_uni_credito_vcr;
		
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'uni_cred2_vcr.unl SELECT * FROM tmp_uni_credito_vcr;">' || TRIM(cRutaOltp) || 'u_uni_vcr_credito.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_uni_vcr_credito.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdicred ' || TRIM(cRutaOltp) || 'u_uni_vcr_credito.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_uni_vcr_credito.sql';
		SYSTEM cStmt;

		LET cVarDataErr = 'EJECUCION EXITOSA VCR';
		
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_1;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_2;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_3;
		DROP TABLE IF EXISTS bdicred:tmp_var_credito_4;
		DROP TABLE IF EXISTS bdicred:tmp_uni_var_credito;
		DROP TABLE IF EXISTS tmp_uni_credito_vcr;
		
		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTA REGISTRO SOBRE EL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProceso);
		
	END IF;

	
	
	IF (UPPER(pTipoProceso) = 'ICR') THEN --UNI_IND_CREDITO PROCESO MODIFICADO POR LJFS 23/08/2018
	
		LET dFechaInicialIvr = (MDY(SUBSTRING(pFechaInicial FROM 1 FOR 2),SUBSTRING(pFechaInicial FROM 4 FOR 2),SUBSTRING(pFechaInicial FROM 7 FOR 4)));       
		LET dFechaFinalIvr = (MDY(SUBSTRING(pFechaFinal FROM 1 FOR 2),SUBSTRING(pFechaFinal FROM 4 FOR 2),SUBSTRING(pFechaFinal FROM 7 FOR 4)));

		-- EJECUTAR LA CONSULTA PARA INSERTAR LOS DATOS CLAVE DE ACUERDO AL RAGO DE FECHAS
		INSERT INTO bdicred:"informix".tmp_unica_paso (num_credito)
		SELECT  	num_credito
		FROM    	bdicred:"informix".sd_indicador_cred
		WHERE   	(fecha_alta > dFechaInicialIvr AND fecha_alta <= dFechaFinalIvr)
			OR      (f_primer_compra > dFechaInicialIvr AND f_primer_compra <= dFechaFinalIvr)
			OR      (f_primer_disp > dFechaInicialIvr AND f_primer_disp <= dFechaFinalIvr)
			OR      (fecha_ultimo_pago > dFechaInicialIvr AND fecha_ultimo_pago <= dFechaFinalIvr)
			OR      (atm_disp_fecha > dFechaInicialIvr AND atm_disp_fecha <= dFechaFinalIvr)
			OR      (pos_disp_fecha > dFechaInicialIvr AND pos_disp_fecha <= dFechaFinalIvr)
			OR      (vnt_disp_fecha > dFechaInicialIvr AND vnt_disp_fecha <= dFechaFinalIvr)
			OR      (fecha_sdo_maximo > dFechaInicialIvr AND fecha_sdo_maximo <= dFechaFinalIvr)
			OR      (fecha_ult_convenio > dFechaInicialIvr AND fecha_ult_convenio <= dFechaFinalIvr)
			OR      (fecha_vencido > dFechaInicialIvr AND fecha_vencido <= dFechaFinalIvr)
			OR      (fecha_cancelacion > dFechaInicialIvr AND fecha_cancelacion <= dFechaFinalIvr)
			OR      (fecha_ultimo_pago_h > dFechaInicialIvr AND fecha_ultimo_pago_h <= dFechaFinalIvr)
			OR      (atm_disp_fecha_h > dFechaInicialIvr AND atm_disp_fecha_h <= dFechaFinalIvr)
			OR      (pos_disp_fecha_h > dFechaInicialIvr AND pos_disp_fecha_h <= dFechaFinalIvr)
			OR      (vnt_disp_fecha_h > dFechaInicialIvr AND vnt_disp_fecha_h <= dFechaFinalIvr)
			OR      (fecha_sdo_maximo_h > dFechaInicialIvr AND fecha_sdo_maximo_h <= dFechaFinalIvr)
			OR      (fecha_ult_convenio_h > dFechaInicialIvr AND fecha_ult_convenio_h <= dFechaFinalIvr)
			OR      (fecha_vencido_h > dFechaInicialIvr AND fecha_vencido_h <= dFechaFinalIvr)
			OR      (fecha_cancelacion_h > dFechaInicialIvr AND fecha_cancelacion_h <= dFechaFinalIvr)
			OR      (fecha_ultimo_pago_rev > dFechaInicialIvr AND fecha_ultimo_pago_rev <= dFechaFinalIvr)
			OR      (atm_disp_fecha_rev > dFechaInicialIvr AND atm_disp_fecha_rev <= dFechaFinalIvr)
			OR      (pos_disp_fecha_rev > dFechaInicialIvr AND pos_disp_fecha_rev <= dFechaFinalIvr)
			OR      (vnt_disp_fecha_rev > dFechaInicialIvr AND vnt_disp_fecha_rev <= dFechaFinalIvr)
			OR      (fecha_ult_respaldo > dFechaInicialIvr AND fecha_ult_respaldo <= dFechaFinalIvr)
			OR      (fecha_ultima_compra > dFechaInicialIvr AND fecha_ultima_compra <= dFechaFinalIvr)
			OR      (fecha_ultima_compra_h > dFechaInicialIvr AND fecha_ultima_compra_h <= dFechaFinalIvr)
			OR      (fecha_ultimo_pago_ch > dFechaInicialIvr AND fecha_ultimo_pago_ch <= dFechaFinalIvr)
			OR      (fecha_sdo_maximo_ch > dFechaInicialIvr AND fecha_sdo_maximo_ch <= dFechaFinalIvr)
			OR      (fecha_ultima_compra_ch > dFechaInicialIvr AND fecha_ultima_compra_ch <= dFechaFinalIvr)
			OR      (atm_disp_fecha_ch > dFechaInicialIvr AND atm_disp_fecha_ch <= dFechaFinalIvr)
			OR      (pos_disp_fecha_ch > dFechaInicialIvr AND pos_disp_fecha_ch <= dFechaFinalIvr)
			OR      (vnt_disp_fecha_ch > dFechaInicialIvr AND vnt_disp_fecha_ch <= dFechaFinalIvr)
			OR      (fecha_1er_anualidad > dFechaInicialIvr AND fecha_1er_anualidad <= dFechaFinalIvr)
			OR      (fecha_prox_anualidad > dFechaInicialIvr AND fecha_prox_anualidad <= dFechaFinalIvr)
			OR      (fechaultimocambio > MDY(SUBSTRING(pFechaInicial FROM 1 FOR 2),SUBSTRING(pFechaInicial FROM 4 FOR 2),SUBSTRING(pFechaInicial FROM 7 FOR 4)) AND fechaultimocambio <= MDY(SUBSTRING(pFechaFinal FROM 1 FOR 2),SUBSTRING(pFechaFinal FROM 4 FOR 2),SUBSTRING(pFechaFinal FROM 7 FOR 4)))
			OR      (fecha_trasp_devol_anual > MDY(SUBSTRING(pFechaInicial FROM 1 FOR 2),SUBSTRING(pFechaInicial FROM 4 FOR 2),SUBSTRING(pFechaInicial FROM 7 FOR 4)) AND fecha_trasp_devol_anual <= MDY(SUBSTRING(pFechaFinal FROM 1 FOR 2),SUBSTRING(pFechaFinal FROM 4 FOR 2),SUBSTRING(pFechaFinal FROM 7 FOR 4)))
			OR      (fecha_devol_anual > MDY(SUBSTRING(pFechaInicial FROM 1 FOR 2),SUBSTRING(pFechaInicial FROM 4 FOR 2),SUBSTRING(pFechaInicial FROM 7 FOR 4)) AND fecha_devol_anual <= MDY(SUBSTRING(pFechaFinal FROM 1 FOR 2),SUBSTRING(pFechaFinal FROM 4 FOR 2),SUBSTRING(pFechaFinal FROM 7 FOR 4)))
			OR      (fecha_pre_devol_anual > MDY(SUBSTRING(pFechaInicial FROM 1 FOR 2),SUBSTRING(pFechaInicial FROM 4 FOR 2),SUBSTRING(pFechaInicial FROM 7 FOR 4)) AND fecha_pre_devol_anual <= MDY(SUBSTRING(pFechaFinal FROM 1 FOR 2),SUBSTRING(pFechaFinal FROM 4 FOR 2),SUBSTRING(pFechaFinal FROM 7 FOR 4)))
		GROUP BY	num_credito;
		
		DROP TABLE IF EXISTS tmp_uni_credito_icr;
		SELECT    	tp.num_credito,icr.f_primer_compra,icr.monto_primer_compra,icr.trans_primer_compra,icr.f_primer_disp,icr.monto_primer_disp,icr.trans_primer_disp,icr.fecha_ultimo_pago,icr.monto_ultimo_pago,icr.trans_ultimo_pago,icr.atm_disp_monto,icr.atm_disp_fecha,icr.atm_disp_transacc,icr.pos_disp_monto,icr.pos_disp_fecha,icr.pos_disp_transacc,icr.vnt_disp_monto,icr.vnt_disp_fecha,icr.saldo_maximo,icr.fecha_sdo_maximo,     icr.saldo_max_facturado,icr.fecha_ult_convenio,icr.num_atm,icr.monto_atm,icr.num_pos,icr.monto_pos,icr.num_vtn,icr.monto_vtn,icr.num_pagos,icr.monto_pagos,icr.fecha_vencido,icr.fecha_cancelacion,icr.num_vencidos_his,icr.num_vencidos,icr.fecha_ultimo_pago_h,icr.monto_ultimo_pago_h,icr.atm_disp_monto_h,icr.atm_disp_fecha_h,icr.atm_disp_transacc_h,icr.pos_disp_monto_h,icr.pos_disp_fecha_h,icr.pos_disp_transacc_h,icr.vnt_disp_monto_h,icr.vnt_disp_fecha_h,icr.saldo_maximo_h,icr.fecha_sdo_maximo_h,icr.saldo_max_facturado_h,icr.pago_mayor_h,icr.num_atm_h,icr.monto_atm_h,icr.num_pos_h,icr.monto_pos_h,icr.num_vtn_h,icr.monto_vtn_h,icr.num_pagos_h,icr.monto_pagos_h,icr.fecha_vencido_h, icr.fecha_cancelacion_h,icr.dias_atraso,icr.fecha_ultima_compra,icr.monto_ultima_compra,icr.cumplio_convenio,icr.fecha_ultima_compra_h,icr.monto_ultima_compra_h,icr.fecha_ultimo_pago_ch,  icr.saldo_maximo_ch,icr.fecha_sdo_maximo_ch,icr.fecha_ultima_compra_ch,icr.monto_ultima_compra_ch,icr.atm_disp_monto_ch,icr.atm_disp_fecha_ch,icr.pos_disp_monto_ch,icr.pos_disp_fecha_ch,icr.vnt_disp_monto_ch,icr.vnt_disp_fecha_ch,icr.num_vencidos_ch,icr.saldo_max_facturado_ch,icr.num_atm_ch,icr.monto_atm_ch,icr.num_pos_ch,icr.monto_pos_ch,icr.num_vtn_ch,icr.monto_vtn_ch,icr.num_pagos_ch,icr.monto_pagos_ch,icr.num_atmc,icr.monto_atmc,icr.num_posc,icr.monto_posc,icr.num_vtnc,icr.monto_vtnc,icr.num_pagosc,icr.monto_pagosc,icr.comportamiento,icr.fechaultimocambio
		FROM      	bdicred:"informix".tmp_unica_paso tp
	    INNER JOIN	bdicred:"informix".sd_indicador_cred icr ON (tp.num_credito = icr.num_credito)
		INTO tmp_uni_credito_icr;
		
		LET cStmt = 'echo "UNLOAD TO ' || TRIM(cRutaOltp) || 'uni_cred2_icr.unl SELECT * FROM tmp_uni_credito_icr;">' || TRIM(cRutaOltp) || 'u_uni_icr_credito.sql';
		SYSTEM cStmt;
		LET cStmt = 'chmod 777 ' || TRIM(cRutaOltp) || 'u_uni_icr_credito.sql';
		SYSTEM cStmt;
		LET cStmt= 'dbaccess bdicred ' || TRIM(cRutaOltp) || 'u_uni_icr_credito.sql';
		SYSTEM cStmt;
		LET cStmt = 'rm -f ' || TRIM(cRutaOltp) || 'u_uni_icr_credito.sql';
		SYSTEM cStmt;

		LET cVarDataErr = 'EJECUCION EXITOSA ICR';

		TRUNCATE TABLE bdicred:"informix".tmp_unica_paso;
		DROP TABLE IF EXISTS tmp_uni_credito_icr;

		SELECT  DBINFO('utc_to_datetime',sh_curtime)
		INTO    dFechaFin
		FROM    sysmaster:"informix".sysshmvals;

		--INSERTA REGISTRO SOBRE EL PROCESO
		INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion,tipo_proceso)
		VALUES (cProceso, dFechaIni, dFechaFin, iEstatus, cVarDataErr, pTipoProceso);

	END IF;
		
	RETURN cProceso,cCodRet, cVarDataErr;

	END;
END PROCEDURE;