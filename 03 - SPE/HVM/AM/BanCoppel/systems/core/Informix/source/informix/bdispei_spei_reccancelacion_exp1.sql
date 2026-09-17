CREATE PROCEDURE "informix".spei_reccancelacion_exp1( pvchrclaverastreo CHAR(30),       -- clave de rastreo
                                                 pvchrcuentabenef  CHAR(20),       -- numero de cuenta del beneficiario
                                                 pmnyimporte       DECIMAL(17,2),  -- importe de la operaciÃ³n
                                                 pintrefnumerica   CHAR(7),        -- referencia numÃ©rica
												 pcharfirma	       CHAR(512),	   -- firma a validar
												 pchartipopago	   CHAR(2), 	   -- tipo de pago (19,20,21,22) CODI
												 pnumcelord 	   CHAR(10), --
												 pnumcelben 	   CHAR (20),
												 pdigidord 		   INTEGER,
												 pdigidben 		   INTEGER,
												 pfechalimpago 	   CHAR(16),
												 intBancoOrd 	   CHAR(5),
												 ppagocomision 	   INTEGER,
												 pcomision 		   DECIMAL(14,2),
												 pnumseriecert 	   CHAR(20),
												 pfolioplataforma  CHAR(20), --
												 pchridmjc 		   CHAR(20), 
												 pchrfchmjc 	   CHAR(20))
    
RETURNING CHAR(30); -- folio
    
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vSqlErr          INTEGER; 
    DEFINE vIsamErr         INTEGER;
    DEFINE wempresa         CHAR(3);
    DEFINE whora            CHAR(15);
    DEFINE wserial_folio    INTEGER;
    DEFINE wfolio_suc       CHAR(30);
    DEFINE wcuenta          CHAR(20);
    DEFINE wnum_tarjeta     CHAR(16);
    DEFINE wmaxsec          SMALLINT;
    DEFINE wsucursal        CHAR(4);
    DEFINE wusuario         CHAR(8);
    DEFINE wtransacc        CHAR(4);
    DEFINE wtran_suc        CHAR(4);
    DEFINE wdivisa          CHAR(2);
    DEFINE wexiste_mov      INTEGER;
	DEFINE wimporte         DECIMAL(12,2);
	DEFINE cVarDataErr      CHAR(100);
	DEFINE vtimestamp       LVARCHAR(20);
	DEFINE wtimestamp       CHAR(20);
	DEFINE wcomision 		DECIMAL(14,2);
		--FIRMA
	DEFINE wcadena_val      CHAR (1000);
	DEFINE codretfirma      INTEGER;
	DEFINE wvchrcodretcodi  CHAR(5);
	DEFINE pvchrconceptopago CHAR(210);
	DEFINE pvchrtpoctaord	CHAR(2);
	DEFINE pintBancoDest    CHAR(5);
	DEFINE pintTipoCtaBenef CHAR (2);
	DEFINE pvchrNombreBenef CHAR (20);
	DEFINE pvchrcuentaord	CHAR(20);
	DEFINE pvchrNombreOrd   CHAR (20);
	DEFINE pvchrCelOrd      CHAR (10);
	DEFINE pvchrCelBen      CHAR (20);
	DEFINE pvchridmjc	    CHAR (20);
	DEFINE vcomision        CHAR(7);
	

	
	
	
	LET wcadena_val = '';
	LET codretfirma = 0;
    
    LET vCodRet1      = "000";
    LET vCodRet2      = "000";
    LET vSqlErr       = 0;
    LET vIsamErr      = 0;
    LET wempresa      = '001';
    LET whora         = '';
    LET wserial_folio = 0;
    LET wfolio_suc    = '0';
    LET wcuenta       = '';
    LET wnum_tarjeta  = '';
    LET wmaxsec       = 0;
    LET wsucursal     = '9201';
    LET wusuario      = 'tranSPEI';
    LET wtransacc     = '0276';
    LET wtran_suc     = '0000';
    LET wdivisa       = '01';
    LET wexiste_mov   = 0;
	LET wimporte      = pmnyImporte;
	LET cVarDataErr   = 'NO SE PUDO REALIZAR LA TRANSFERENCIA CODI';
	LET vtimestamp    = dbinfo('utc_current') * 1000;
	LET wtimestamp    = vtimestamp;
	LET wvchrcodretcodi = '00000';
    
     --SET DEBUG FILE TO "/informix/ifg/spei_reccancelacion.out";
     --SET DEBUG FILE TO "/informix/Priscilla/spei_reccancelacion_pbe.out";
     --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_reccancelacion.out";
        --SET DEBUG FILE TO "/informix/Priscilla/spei_reccancelacion_pbe_err.out";
        TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            RETURN wfolio_suc; 
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET wcomision = pcomision;
	
	IF wcomision = 0.00 THEN
	   LET vcomision = '0.0';
	ELSE
	   LET vcomision = wcomision;
	END IF;
	
	LET vcomision = vcomision;
	
	--GENERA CADENA A VALIDAR
	LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||
	                  '|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||'|'||intBancoOrd||'|'||ppagocomision||'|'||trim(vcomision)||
					  '|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||'|';
	
	LET wcadena_val = wcadena_val;
					  
	EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(pcharfirma), 20)
	INTO codretfirma;
	LET codretfirma = 0; --- Para prueba
		
	IF codretfirma = 0 THEN
				
				/**/
				
				IF ( ( pmnyimporte <= 0.00 ) OR 
					 ( LENGTH(TRIM(pvchrcuentabenef)) <> 11 AND LENGTH(TRIM(pvchrcuentabenef)) <> 16 AND LENGTH(TRIM(pvchrcuentabenef)) <> 18 AND LENGTH(TRIM(pvchrcuentabenef)) <> 10 ) ) THEN
					LET wfolio_suc = '0';
					RETURN wfolio_suc;
				END IF;
				
				IF LENGTH(TRIM(pvchrcuentabenef)) = 11 THEN
				
					LET wcuenta = pvchrcuentabenef;
					
					SELECT NVL(num_tarjeta, ' ')
					  INTO wnum_tarjeta
					  FROM bdicheq:sc_tarjeta
					 WHERE empresa = wempresa
					   AND cuenta = wcuenta
					   AND secuencia = ( SELECT MAX(secuencia)
										   FROM bdicheq:sc_tarjeta
										  WHERE empresa = wempresa
											AND cuenta = wcuenta
											AND tipo_tarjeta = 'T'
											AND status_tar = 'A' );
					
				ELIF LENGTH(TRIM(pvchrcuentabenef)) = 16 THEN
				
					SELECT NVL(cuenta, ' ')
					  INTO wcuenta
					  FROM bdicheq:sc_tarjeta
					 WHERE empresa = wempresa
					   AND num_tarjeta = pvchrcuentabenef;
					   
					LET wnum_tarjeta = pvchrcuentabenef;
					
				ELIF LENGTH(TRIM(pvchrcuentabenef)) = 18 THEN
				
					LET wcuenta = SUBSTR(pvchrcuentabenef, 7, 11);
					
					SELECT NVL(num_tarjeta, ' ')
					  INTO wnum_tarjeta
					  FROM bdicheq:sc_tarjeta
					 WHERE empresa = wempresa
					   AND cuenta = wcuenta
					   AND secuencia = ( SELECT MAX(secuencia)
										   FROM bdicheq:sc_tarjeta
										  WHERE empresa = wempresa
											AND cuenta = wcuenta
											AND tipo_tarjeta = 'T'
											AND status_tar = 'A' );
											
				ELIF LENGTH(TRIM(pvchrcuentabenef)) = 10 THEN
					
					SELECT cuenta
					  INTO wcuenta
					  FROM bdicheq:sc_cuenta_telefono
					 WHERE telefono = pvchrcuentabenef;
					 
					LET wnum_tarjeta = '';
					   
					IF wcuenta is null OR wcuenta = '' THEN
						SELECT cuenta_tf, num_tarjeta
						  INTO wcuenta, wnum_tarjeta
						  FROM bditransfer:tf_maecte
						 WHERE telefono = pvchrcuentabenef
						   AND status_cta = '1';
					END IF;
					
				END IF;
				
				SELECT COUNT(*)
				  INTO wexiste_mov
				  FROM bdicheq:sc_movdia
				 WHERE empresa = wempresa
				   AND cuenta = wcuenta
				   AND cancelad <> 'S'
				   AND referencia = pvchrclaverastreo
				   AND transacc in('0274', '0447');
				   
				IF wexiste_mov = 0 THEN
					LET wfolio_suc = '0';
					RETURN wfolio_suc;
				END IF;
				
				IF pchartipopago IN('19', '20', '21', '22') THEN
				   SELECT vchrconceptopago2, intcvetipoctaord, cvecesifbcodest, intcvetipoctabene, vchrnombrebenef, vchrcuentaord, vchrnombreord,numcelord,numcelben,folioplataforma
                     INTO pvchrConceptoPago, pvchrtpoctaord, pintBancoDest, pintTipoCtaBenef, pvchrNombreBenef, pvchrCuentaOrd, pvchrNombreOrd,pvchrCelOrd,pvchrCelBen,pvchridmjc    					   
				     FROM bdispei:tblpago 
				    WHERE vchrclaverastreo = pvchrclaverastreo;
				END IF;
				
				CALL sp_obtfoliosuc(wusuario) 
				RETURNING vcodret1, wserial_folio, wfolio_suc;
				
				IF vcodret1 <> '000' THEN
					LET wfolio_suc = '0';
					RETURN wfolio_suc;
				END IF;
				
				EXECUTE PROCEDURE bdicheq:abono_ref( wempresa, wsucursal, wusuario, wtransacc, wtran_suc, wfolio_suc, wcuenta, 0, 
													 pmnyimporte, pmnyimporte, 0, 0, 0, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ' ) 
				INTO vcodret1;
				
				IF vcodret1 = '000' THEN
					UPDATE bdispei:tblpago
					   SET chrestatusenvio = 'C'
					 WHERE vchrclaverastreo = pvchrclaverastreo;
					
					IF pchartipopago IN('19', '20', '21', '22') THEN
					   LET cVarDataErr = ' ';					 
					   EXECUTE PROCEDURE spei_recerrorescodi('22', cVarDataErr,'b',pvchridmjc,wtimestamp,pvchrConceptoPago,wimporte,wtimestamp,  
											pvchrclaverastreo,pintrefnumerica,pvchrCelOrd,pdigidord, intBancoOrd,pvchrtpoctaord,  
											pvchrCuentaOrd,pvchrNombreOrd,pvchrCelBen,pdigidben,pintBancoDest,pintTipoCtaBenef,  
											pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
					   INTO wvchrcodretcodi;
					END IF;
					
				ELSE 
					LET wfolio_suc = '0';
				END IF;
			
		
	ELSE

		IF pchartipopago IN('19', '20', '21', '22') THEN
		   SELECT vchrconceptopago2, intcvetipoctaord, cvecesifbcodest, intcvetipoctabene, vchrnombrebenef, vchrcuentaord, vchrnombreord,numcelord,numcelben,folioplataforma
            INTO pvchrConceptoPago, pvchrtpoctaord, pintBancoDest, pintTipoCtaBenef, pvchrNombreBenef, pvchrCuentaOrd, pvchrNombreOrd,pvchrCelOrd,pvchrCelBen,pvchridmjc     					   
		    FROM bdispei:tblpago 
		   WHERE vchrclaverastreo = pvchrclaverastreo;
		   
		   	LET cVarDataErr = ' ';
			   EXECUTE PROCEDURE spei_recerrorescodi('22', cVarDataErr,'b',pvchridmjc,wtimestamp,pvchrConceptoPago,wimporte,wtimestamp,  
								pvchrclaverastreo,pintrefnumerica,pvchrCelOrd,pdigidord, intBancoOrd,pvchrtpoctaord,  
								pvchrCuentaOrd,pvchrNombreOrd,pvchrCelBen,pdigidben,pintBancoDest,pintTipoCtaBenef,  
								pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
			   INTO wvchrcodretcodi;
		END IF;

			LET wfolio_suc  = '0';
			
			RETURN wfolio_suc;
	END IF;
    
    END;
    
    RETURN wfolio_suc;
    
END PROCEDURE;