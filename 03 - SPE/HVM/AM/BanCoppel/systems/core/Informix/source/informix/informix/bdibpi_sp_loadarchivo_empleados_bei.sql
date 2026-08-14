CREATE PROCEDURE "informix".sp_loadarchivo_empleados_bei( psNomArchivo VARCHAR (23), psRuta_Procesos VARCHAR (90),psIdEmpresa CHAR(3),psCteEmpresa CHAR(10))              
RETURNING CHAR(5), CHAR(50);                                                                                                                                              
                                                                                                                                                                          
--****************************************************************************************************                                                                    
-- DESCRIPCION:  CARGA LOS REGISTROS DEL ARCHIVO A LA TABLA bpi_empleadospm PARA SER PROCESADO                                                                            
-- AUTOR : Francisco Rodríguez Ibarra                                                                                                                                     
-- FECHA : 26/08/2011                                                                                                                                                     
-- BD: bdibpi                                                                                                                                                              
-- SOLICITO :Mauricio León                                                                                                                                                
--***************************************************************************************************                                                                     
-- DESCRIPCION:  SE VALIDA QUE LAS CUENTAS SEAN VALIDAS                                                                                                                   
-- AUTOR : Walber Castro                                                                                                                                                  
-- FECHA : 02/12/2011                                                                                                                                                     
-- BD: bdibpi                                                                                                                                                              
-- SOLICITO :Mauricio León                                                                                                                                                
--***************************************************************************************************                                                                     
                                                                                                                                                                          
/*  DEFINICION DE VARIABLES */                                                                                                                                            
DEFINE cSqlerr			 INTEGER;                                                                                                                                 
DEFINE cCodret      	 CHAR(5);                                                                                                                                         
DEFINE cMensaje CHAR(50);                                                                                                                                                 
DEFINE vsRuta_Repositorio VARCHAR(90);                                                                                                                                    
DEFINE vsNomArchivo CHAR(17);                                                                                                                                             
DEFINE iNumReg INTEGER;                                                                                                                                                   
DEFINE cCveBanco char(3);                                                                                                                                                 
Define cSQL CHAR(250);                                                                                                                                                    
Define cRenglon CHAR(150);                                                                                                                                                
DEFINE cNumEmp  CHAR(10);                                                                                                                                                 
DEFINE cNombres  CHAR(30);                                                                                                                                                
DEFINE cApePat  CHAR(30);                                                                                                                                                 
DEFINE cApeMat CHAR(20);                                                                                                                                                  
DEFINE cNumCta  CHAR(18);                                                                                                                                                 
DEFINE i smallint;                                                                                                                                                        
DEFINE iPosAnt integer;                                                                                                                                                   
DEFINE cCadAux varchar(150);                                                                                                                                              
DEFINE iColumna integer;                                                                                                                                                  
DEFINE cExiste integer;                                                                                                                                                   
DEFINE cPosReg integer;                                                                                                                                                   
DEFINE cEmpExist CHAR(10);                                                                                                                                                
DEFINE v_ctavalida CHAR(5);                                                                                                                                               
                                                                                                                                                                          
/* INICIALIZACION DE VARIABLES */                                                                                                                                         
                                                                                                                                                                          
LET cCodret = '00000' ;                                                                                                                                                   
LET cSqlerr = 0;                                                                                                                                                          
LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE';                                                                                                                   
LET cExiste=0;                                                                                                                                                            
LET cPosReg=0;                                                                                                                                                            
LET cEmpExist='';                                                                                                                                                         
LET v_ctavalida = "";                                                                                                                                                     
                                                                                                                                                                          
--SET debug FILE TO "/home/informix/ivonne/sp_loadarchivo_empleados_bei.out";                                                                                               
--Trace ON;                                                                                                                                                                 
                                                                                                                                                                          
BEGIN                                                                                                                                                                     
                                                                                                                                                                          
	ON EXCEPTION SET cSqlerr   --Obtiene el error en caso de que exista y regresa un valor predeterminado                                                             
				                                                                                                                                          
		Let cCodret = cSqlerr;                                                                                                                                    
        RETURN cCodret, cMensaje;                                                                                                                                         
		                                                                                                                                                          
    END EXCEPTION;                                                                                                                                                        
	                                                                                                                                                                  
	SET LOCK MODE TO WAIT ;                                                                                                                                           
	SET ISOLATION DIRTY READ ;                                                                                                                                        
	--LIMPIAR LAS TABLAS TEMPORALES                                                                                                                                   
	DELETE FROM bdibpi:"informix".bpi_empleadosarchtemp WHERE id_empresa = psIdEmpresa AND num_serial is not null;                                                    
		                                                                                                                                                          
	SELECT valor INTO psRuta_Procesos 
	FROM BDICHEQ:sc_param 
	WHERE empresa = "001" 
	AND codparam = 'NomRutaDestino_BPI';                                                           
	                                                                                                                                                                  
	---------Se carga archivo ( LOAD)---------                                                                                                                        
	Let cSQL = '';                                                                                                                                                    
	Let  cSQL = 'echo "load from '||TRIM(psRuta_Procesos) || TRIM(psNomArchivo) ||                                                                                    
				' delimiter ' || '''$''' || ' insert into bpi_empleadosarchtemp(columna,id_empresa); " > '||TRIM(psRuta_Procesos) ||'querynom_empbei.sql';
	System cSQL;                                                                                                                                                      
	Let cSQL = '';                                                                                                                                                    
	--Let cSQL = 'dbaccess bdibpi '||TRIM(psRuta_Procesos) ||'querynom_empbei.sql';  --Se activa para desarrollo                                                        
	Let cSQL = '/ifxsif01/bin/dbaccess bdibpi '||TRIM(psRuta_Procesos) ||'querynom_empbei.sql ';  --Se activa para Produccion                                                
	System cSQL;                                                                                                                                                      
	------------------------------------------------------------------------------------------                                                                        
	                                                                                                                                                                  
	--Se valida que el archivo no venga vacio----                                                                                                                     
	SELECT COUNT(*)::INTEGER INTO iNumReg FROM bdibpi:"informix".bpi_empleadosarchtemp WHERE id_empresa = psIdEmpresa;                                                
	                                                                                                                                                                  
	IF iNumReg=0 THEN                                                                                                                                                 
		 RETURN '001', 'EL ARCHIVO SE ENCUENTRA VACIO';                                                                                                           
	ELSE                                                                                                                                                              
		FOREACH                                                                                                                                                   
			SELECT columna INTO cRenglon FROM bdibpi:"informix".bpi_empleadosarchtemp WHERE id_empresa = psIdEmpresa ORDER BY(num_serial)                     
			LET iPosAnt=1;                                                                                                                                    
			LET iColumna=0;                                                                                                                                   
			FOR i = 1 TO LENGTH (cRenglon)                                                                                                                    
				IF (iColumna=4)THEN                                                                                                                       
					LET cCadAux=SUBSTR(cRenglon,i,LENGTH(cRenglon)-(iPosAnt-1));                                                                      
					LET cNumCta = cCadAux;                                                                                                            
					 EXIT FOR;                                                                                                                        
				ELIF ( SUBSTR(cRenglon,i,1) = '|' ) THEN                                                                                                  
					LET cCadAux=SUBSTR(cRenglon,iPosAnt,i-iPosAnt);                                                                                   
					IF (iColumna=0)THEN                                                                                                               
						LET cNumEmp = cCadAux;                                                                                                    
					ELIF (iColumna=1)THEN                                                                                                             
						LET cNombres = cCadAux;                                                                                                   
					ELIF (iColumna=2)THEN                                                                                                             
						LET cApePat = cCadAux;                                                                                                    
					ELIF (iColumna=3)THEN                                                                                                             
						LET cApeMat = cCadAux;                                                                                                    
					END IF;                                                                                                                           
					LET iPosAnt=i+1;                                                                                                                  
					LET iColumna=iColumna+1;		                                                                                          
				END IF;				                                                                                                          
			END FOR;                                                                                                                                          
				LET cPosReg=cPosReg+1;                                                                                                                    
			IF TRIM(cNumEmp) = '' OR (cNumEmp IS null) OR TRIM(cNombres) = '' OR (cNombres IS null) OR                                                        
			   TRIM(cApePat) = '' OR (cApePat IS null) OR TRIM(cNumCta) = '' OR (cNumCta IS null)   THEN                                                      
				--Error Un valor nULLOS En EL Archivo                                                                                                     
				LET cCodret = '182';                                                                                                                      
				--Obtener los mensajes de retorno                                                                                                         
				SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;                     
				RETURN cCodret, cMensaje;                                                                                                                 
			END IF;                                                                                                                                           
			                                                                                                                                                  
			IF LENGTH(cNumCta) = 11 THEN                                                                                                                      
				LET cCveBanco='137';                                                                                                                      
			ELSE                                                                                                                                              
				LET cCveBanco=SUBSTR(cNumCta,1,3);                                                                                                        
			END IF                                                                                                                                            
			                                                                                                                                                  
			EXECUTE PROCEDURE bdicheq:"informix".sp_consula_cta_activa(cNumCta) INTO v_ctavalida;                                                             
			                                                                                                                                                  
			IF ( v_ctavalida <> "000" ) THEN                                                                                                                  
				LET cExiste=1;                                                                                                                            
				LET cCodret = '001';                                                                                                                      
				LET cMensaje="LA CUENTA "||cNumCta||" NO ES VALIDA";                                                                                      
				EXIT FOREACH;                                                                                                                             
			END IF                                                                                                                                            
			                                                                                                                                                  
			--select banco INTO cVeBanco from bdinteg:si_bancos where banco=SUBSTR(cNumCta,1,3);                                                              
			SELECT num_empleado INTO cEmpExist FROM bdibpi:"informix".bpi_empleadospm                                                                         
				WHERE id_empresa=psIdEmpresa                                                                                                              
				AND num_empleado =cNumEmp;                                                                                                                
				                                                                                                                                          
			IF(cEmpExist IS NULL OR cEmpExist='') THEN                                                                                                        
				INSERT INTO bdibpi:"informix".bpi_empleadospm(num_empleado,                                                                               
													cte_empresa,                                                      
													id_empresa,                                                       
													nombre_empleado,                                                  
													apell_pat,                                                        
													apell_mat,                                                        
													cta_empleado,                                                     
													cve_banco,                                                        
													f_registro,                                                       
													usr_registro,                                                     
													f_modifica,                                                       
													usr_modifica,                                                     
													activo,                                                           
													f_baja,                                                           
													usr_baja,                                                         
													monto)                                                            
											VALUES(cNumEmp,                                                                   
													psCteEmpresa,                                                     
													psIdEmpresa,                                                      
													cNombres,                                                         
													cApePat,                                                          
													cApeMat,                                                          
													cNumCta,                                                          
													cCveBanco,                                                        
													current,                                                          
													'transBEI',                                                       
													current,                                                          
													'',                                                               
													'1',                                                              
													null,                                                             
													null,                                                             
													'0.00');                                                          
			ELSE                                                                                                                                              
				LET cExiste=1;                                                                                                                            
				LET cCodret = '001';                                                                                                                      
				LET cMensaje="EL CLIENTE "||cEmpExist||"YA SE ENCUENTRA REGISTRADO";                                                                      
				EXIT FOREACH;                                                                                                                             
			END IF                                                                                                                                            
                                                                                                                                                                          
		END FOREACH;                                                                                                                                              
		                                                                                                                                                          
		                                                                                                                                                          
		IF(cExiste=1)THEN                                                                                                                                         
			FOREACH                                                                                                                                           
				SELECT columna INTO cRenglon FROM bdibpi:"informix".bpi_empleadosarchtemp WHERE id_empresa = psIdEmpresa ORDER BY(num_serial)             
				LET cPosReg=cPosReg-1;                                                                                                                    
				IF (cPosReg=0) THEN                                                                                                                       
					EXIT FOREACH;                                                                                                                     
				END IF;                                                                                                                                   
				--LET cCadAux=SUBSTR(cRenglon,i,LENGTH(cRenglon)-(iPosAnt-1));                                                                            
				FOR i = 1 TO LENGTH (cRenglon)                                                                                                            
					IF(SUBSTR(cRenglon,i,1) = '|' ) THEN                                                                                              
						LET cCadAux=SUBSTR(cRenglon,1,i-1);                                                                                       
						LET cNumEmp = cCadAux;                                                                                                    
						EXIT FOR;                                                                                                                 
					END IF;                                                                                                                           
				END FOR;                                                                                                                                  
				DELETE bdibpi:"informix".bpi_empleadospm  WHERE id_empresa=psIdEmpresa AND num_empleado =cNumEmp;                                         
				                                                                                                                                          
			END FOREACH;                                                                                                                                      
		END IF;                                                                                                                                                   
		                                                                                                                                                          
	END IF                                                                                                                                                            
	                                                                                                                                                                  
	                                                                                                                                                                  
	RETURN cCodret, cMensaje;                                                                                                                                         
	                                                                                                                                                                  
END                                                                                                                                                                       
                                                                                                                                                                          
END PROCEDURE;