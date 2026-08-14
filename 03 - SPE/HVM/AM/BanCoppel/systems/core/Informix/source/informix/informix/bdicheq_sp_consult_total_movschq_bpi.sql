CREATE PROCEDURE "informix".sp_consult_total_movschq_bpi(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE)
   RETURNING CHAR(5),INTEGER

-------------------------------------------------------------------------------------------------------
-- Realizó: Jose Ruben Lopez Hernandez
-- Actividad: Obtiene el total de moviemientos de la cuenta para paginar
-- Solicitó: jorge Nuñez
-- Fecha de Solicitud: 26/03/2013
-- BD: bdicheq
-------------------------------------------------------------------------------------------------------

	DEFINE vCodRet					CHAR(5);
	DEFINE vSqlErr, vIsamErr, iAux	INTEGER;
	DEFINE totalReg					INTEGER;
	DEFINE totalReg2				INTEGER;
	DEFINE totalReg3				INTEGER;
  	DEFINE cFech_param				CHAR(10);
	DEFINE cFech_param_ini			CHAR(10);
	DEFINE vFechaHoy				DATE;
	DEFINE dFechaMov				DATE;

	LET vCodRet =		"00000";
	LET dFechaMov =		'01/01/1900';
   	LET vFechaHoy  =	'01/01/1900';
	LET totalReg=        0;
	LET totalReg2=       0;
	LET totalReg3=       0;
	

	BEGIN
		ON EXCEPTION SET vSqlErr, vIsamErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;

				RETURN vCodRet,totalReg;
			END IF;
		END EXCEPTION;

		--Set Debug File To '/home/informix/ivonne/sp_consultmovschq_bpi.out';
		--Trace On;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 2;
    
		--Consulta el valor de fechas limite en tabla de parámetros
		SELECT valor
		INTO cFech_param
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'fechcon_movhis';
		   
		SELECT valor
		INTO cFech_param_ini
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechIniCon_movhis_ol';

		--Consulta fecha de sistema
		SELECT fecha_hoy
		INTO vFechaHoy
		FROM bdicheq:"informix".sc_fechas;
		
		-- Obtiene movimientos del día
		IF pFechaInicial = vFechaHoy AND pFechaFinal = vFechaHoy THEN
				SELECT COUNT(*)
					INTO totalReg
					FROM
						bdicheq:"informix".sc_movdia AS mm,
						bdinteg:"informix".si_transacc AS tr 
					WHERE
						mm.empresa = pEmpresa AND
						mm.cuenta = pCuenta   AND
						mm.fech_alt = vFechaHoy AND
						mm.cancelad <> "S" AND
						mm.empresa = tr.empresa AND
						mm.transacc = tr.numero AND
						tr.se_emite_edocta = "S";	

					RETURN vCodRet,totalReg;
			   
		--END IF;	
		--Consulta de movimientos incluyendo la movhis y la movdia
		ELIF pFechaInicial >= cFech_param THEN
			IF pFechaFinal = vFechaHoy THEN
				SELECT COUNT(*)
					INTO totalReg
					FROM
						bdicheq:"informix".sc_movdia AS mm,
						bdinteg:"informix".si_transacc AS tr 
					WHERE
						mm.empresa = pEmpresa AND
						mm.cuenta =pCuenta AND
						mm.fech_alt = vFechaHoy AND
						mm.cancelad <> "S" AND
						mm.empresa = tr.empresa AND
						mm.transacc = tr.numero AND
						tr.se_emite_edocta = "S";
					
					SELECT COUNT(*)  
					INTO totalReg2
					FROM                                                                        			
						bdicheq:"informix".sc_movhis AS mm,                                            			
						bdinteg:"informix".si_transacc AS tr                                           			
					WHERE                                                                       			
						mm.empresa = pEmpresa AND                                           			
						mm.cuenta = pCuenta AND                                             			
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND    
						mm.fech_alt >= cFech_param AND             			                                    			
						mm.cancelad <> "S" AND                                              			
						mm.transacc = tr.numero AND				            			
						mm.empresa = tr.empresa AND                                         			
						tr.se_emite_edocta = "S" ;  
					
					LET totalReg=totalReg+totalReg2;
					RETURN vCodRet,totalReg;
				
			ELSE 
				
					SELECT COUNT(*)
					INTO totalReg
					FROM                                                                        			
						bdicheq:"informix".sc_movhis AS mm,                                            			
						bdinteg:"informix".si_transacc AS tr                                           			
					WHERE                                                                       			
						mm.empresa = pEmpresa AND                                           			
						mm.cuenta = pCuenta AND                                             			
						mm.fech_alt BETWEEN pFechaInicial  AND pFechaFinal AND               			
						mm.fech_alt >= cFech_param AND                                      			
						mm.cancelad <> "S" AND                                              			
						mm.transacc = tr.numero AND				            			
						mm.empresa = tr.empresa AND                                         			
						tr.se_emite_edocta = "S" ;       		
					RETURN vCodRet,totalReg;
			END IF;	
		
		--Consulta de movimientos incluyendo la movhis_old, la mov_his y la movdia		
		ELIF pFechaInicial >= cFech_param_ini THEN
			IF pFechaFinal = vFechaHoy THEN
					SELECT COUNT(*) 
					INTO totalReg
					FROM
						bdicheq:"informix".sc_movdia AS mm,
						bdinteg:"informix".si_transacc AS tr 
					WHERE
						mm.empresa = pEmpresa AND
						mm.cuenta = pCuenta AND
						mm.fech_alt = vFechaHoy AND
						mm.cancelad <> "S" AND
						mm.empresa = tr.empresa AND
						mm.transacc = tr.numero AND
						tr.se_emite_edocta = "S";
						
					
					SELECT COUNT(*) 
					INTO totalReg2
					FROM                                                                        			
						bdicheq:"informix".sc_movhis AS mm,                                            			
						bdinteg:"informix".si_transacc AS tr                                           			
					WHERE                                                                       			
						mm.empresa = pEmpresa AND                                           			
						mm.cuenta = pCuenta AND                                             			
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND               			
					    mm.fech_alt >= cFech_param AND                                  			
						mm.cancelad <> "S" AND                                              			
						mm.transacc = tr.numero AND				            			
						mm.empresa = tr.empresa AND                                         			
						tr.se_emite_edocta = "S" ; 
						
					SELECT COUNT(*) 
					INTO totalReg3
					FROM
						bdicheq:"informix".sc_movhis_old AS mm,
						bdinteg:"informix".si_transacc AS tr 
					WHERE
						mm.empresa = pEmpresa AND
						mm.cuenta = pCuenta AND
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
						mm.fech_alt >= cFech_param_ini AND 
						mm.cancelad <> "S" AND
						mm.transacc = tr.numero AND				
						mm.empresa = tr.empresa AND
						tr.se_emite_edocta = "S";		

					LET totalReg=totalReg+totalReg2+totalReg3;
					RETURN vCodRet,totalReg;			
			ELSE
				
					SELECT COUNT(*)
					INTO totalReg
					FROM                                                                        			
						bdicheq:"informix".sc_movhis AS mm,                                            			
						bdinteg:"informix".si_transacc AS tr                                           			
					WHERE                                                                       			
						mm.empresa = pEmpresa AND                                           			
						mm.cuenta = pCuenta AND                                             			
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND               			
						mm.fech_alt >= cFech_param AND                                      			
						mm.cancelad <> "S" AND                                              			
						mm.transacc = tr.numero AND				            			
						mm.empresa = tr.empresa AND                                         			
						tr.se_emite_edocta = "S";   

					SELECT COUNT(*) 
					INTO totalReg2
					FROM                                                                                            
						bdicheq:"informix".sc_movhis_old AS mm,                                                            
						bdinteg:"informix".si_transacc AS tr                                                               
					WHERE                                                                                           
						mm.empresa = pEmpresa  AND                                                               
						mm.cuenta = pCuenta AND                                                                 
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND                                   
						mm.fech_alt >= cFech_param_ini AND                                                      
						mm.cancelad <> "S" AND                                                                  
						mm.transacc = tr.numero AND				                                
						mm.empresa = tr.empresa AND                                                             
						tr.se_emite_edocta = "S";	
				
					LET totalReg=totalReg+totalReg2;																
					RETURN vCodRet,totalReg;  
			END IF;	
			--Se retorna un código de retorno 100 en caso de que el movimiento este fuera de los parametros establecidos             	
		ELSE
			LET vCodRet = '100';
			RETURN vCodRet,totalReg;                  
		END IF;
	END;
END PROCEDURE;