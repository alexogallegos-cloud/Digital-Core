CREATE PROCEDURE "informix".sp_constotmovschq_bei(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE,pTipoMov CHAR(1), pBanderaUltHora INTEGER)
   RETURNING CHAR(5),INTEGER

-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------

	DEFINE vCodRet					CHAR(5);
	DEFINE vSqlErr, vIsamErr		INTEGER;
	DEFINE iAux, iReg				INTEGER;
   	DEFINE cFech_param				CHAR(10);
	DEFINE cFech_param_ini			CHAR(10);
	DEFINE vFechaHoy				DATE;
    DEFINE vHrInicial DATETIME YEAR TO FRACTION(3);
    DEFINE vHrFinal DATETIME YEAR TO FRACTION(3);

	LET vCodRet =		"000";
	LET iAux =		0;
	LET iReg =		0;
   	LET vFechaHoy =	'01/01/1900';

	BEGIN
		ON EXCEPTION SET vSqlErr, vIsamErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;

				RETURN vCodRet, iAux;
			END IF;
		END EXCEPTION;

		--Set Debug File To '/home/informix/Berenice/sp_constotmovschq_bei.out';
		--Trace On;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 2;
    
		--Consulta el valor de fechas limite en tabla de parÃ¡metros
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
		
        IF NVL(pBanderaUltHora,0) = 1 THEN
            LET vHrFinal = CURRENT; 
            LET vHrInicial= vHrFinal - INTERVAL(1) HOUR TO HOUR;
        END IF;
		-- Obtiene movimientos del dÃ­a
		IF pFechaInicial = vFechaHoy AND pFechaFinal = vFechaHoy THEN
			
				SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
					COUNT(*)
				INTO                                                                            
					iReg 
				FROM    	 
					bdicheq:"informix".sc_movdia AS mm,
					bdinteg:"informix".si_transacc AS tr 
				WHERE
					mm.empresa = pEmpresa AND
					mm.cuenta = pCuenta AND
					mm.fech_alt = vFechaHoy AND
                    (pBanderaUltHora =0 OR mm.fech_hor  between vHrInicial and vHrFinal) AND
					mm.cancelad <> "S" AND
					mm.empresa = tr.empresa AND
					mm.transacc = tr.numero AND
					tr.se_emite_edocta = "S" AND
					tr.sistema= '01' AND 
                     (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'));
				
			
				
				RETURN vCodRet, iReg;
			
			
		--Consulta de movimientos incluyendo la movhis y la movdia
		ELIF pFechaInicial >= cFech_param THEN
			IF pFechaFinal = vFechaHoy THEN
				
					SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
						COUNT(*)
					INTO                                                                           					
						iAux 
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
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND 
                         (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'));
					
					LET	iReg = iAux;		
					
					SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}  
						COUNT(*)
					INTO                                                                           					
						iAux 
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
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND 
                         (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'));

					LET	iReg = iReg + iAux;
			
					RETURN vCodRet, iReg;
				 
			ELSE 
				 
					SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}
						COUNT(*)
					INTO                                                                           					
						iAux 
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
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND 
                        (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'));	
 
					LET	iReg = iAux;	 
					
		
					RETURN vCodRet, iReg;
				 
			END IF;	
		
		--Consulta de movimientos incluyendo la movhis_old, la mov_his y la movdia		
		ELIF pFechaInicial >= cFech_param_ini THEN
			IF pFechaFinal = vFechaHoy THEN
				
					SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
						COUNT(*)
					INTO                                                                           					
						iAux 
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
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND 
                        (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'));
						
					LET	iReg = iAux;
					
					
					SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}
						COUNT(*)
					INTO                                                                           					
						iAux 
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
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND 
                        (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'));
						
					LET	iReg = iReg + iAux;		
					
					SELECT {+INDEX(bdicheq:"informix".sc_movhis_old movhis1)}
						COUNT(*)
					INTO                                                                           					
						iAux 
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
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND 
                        (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'));
					
					LET	iReg = iReg + iAux;		
 

					RETURN vCodRet, iReg;
					
			ELSE
				 
					SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}
						COUNT(*)
					INTO                                                                           					
						iAux 
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
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND 
                        (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'));
						
					LET	iReg = iAux;
					 
					SELECT {+INDEX(bdicheq:"informix".sc_movhis_old movhis1)}                                                  
						COUNT(*)
					INTO                                                                           					
						iAux                                        
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
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND 
                        (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'));                                                              
						
					LET	iReg = iReg + iAux;	
											
					RETURN vCodRet, iReg;  
				 
			END IF;	
		ELSE
			--Se retorna un cÃ³digo de retorno 100 en caso de que el movimiento este fuera de los parametros establecidos             	
			LET vCodRet = '100';
			RETURN vCodRet, iReg;                  
		END IF;
	END;
END PROCEDURE;