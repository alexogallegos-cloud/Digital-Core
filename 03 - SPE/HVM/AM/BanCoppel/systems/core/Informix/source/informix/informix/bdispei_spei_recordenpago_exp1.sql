CREATE PROCEDURE "informix".spei_recordenpago_exp1( pvchrclaverastreo	CHAR(30),       -- clave de rastreo
											   pvchrcuentabenef		CHAR(20),       -- numero de cuenta del beneficiario
											   pmnyimporte			DECIMAL(17,2),  -- importe de la operacion
											   pintrefnumerica		CHAR(7),        -- referencia numerica
											   pvchrconceptopago	CHAR(210),      -- referencia del pago en ventanilla
											   pvchrrefcobranza		CHAR(40),       -- referencia cobranza
											   pchrstatus			CHAR(1), 		-- status
											   pvchrcuentaord		CHAR(20),       -- numero de cuenta del ordenante
											   pvchrtpoctaord		CHAR(2) ,		-- tipo de cuenta ordenante
											   pchartipopago		CHAR(2), 		-- tipo de pago (19,20,21,22) CODI
											   pcharfirma			CHAR(512),		-- firma a validar
											   pnumcelord 			CHAR(10), --
											   pnumcelben 			CHAR (20),
                        					   pdigidord 			INTEGER,
                        					   pdigidben 			INTEGER,
                        					   pfechalimpago 		CHAR(16),
                        					   intBancoOrd 			CHAR(5),
                        					   ppagocomision 		INTEGER,
                        					   pcomision 			DECIMAL(14,2),
                                               pnumseriecert 		CHAR(20),
											   pfolioplataforma 	CHAR(20), --
                                               pchridmjc 			CHAR(20), 
                                               pchrfchmjc 			CHAR(20),
											   pvchrNombreOrd       CHAR(40),
											   pintTipoCtaBenef     CHAR(2),
											   pvchrNombreBenef     CHAR(40)) 
											   
RETURNING CHAR(30), -- folio
          CHAR(2),  -- clave de devolucion
		  CHAR(18), -- rfc
          CHAR(40); -- nombre del cliente

    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vSqlErr          INTEGER;
    DEFINE vIsamErr         INTEGER;
    DEFINE vDescErr         CHAR(50);
    DEFINE wempresa         CHAR(3);
    DEFINE whora            CHAR(15);
    DEFINE wserial_folio    INTEGER;
    DEFINE wfolio_suc       CHAR(30);
    DEFINE wcausa_dev       CHAR(2);
    DEFINE wcuenta          CHAR(20);
	DEFINE vcuenta          CHAR(20);
    DEFINE wnum_tarjeta     CHAR(16);
    DEFINE wmaxsec          SMALLINT;
    DEFINE wsuc_cta         CHAR(4);
    DEFINE wsucursal        CHAR(4);
    DEFINE wusuario         CHAR(8);
    DEFINE wtransacc        CHAR(4);
    DEFINE wtran_suc        CHAR(4);
    DEFINE wdivisa          CHAR(2);
    DEFINE wexiste_mov      INTEGER;
	DEFINE vrfc             CHAR(18);
    DEFINE vnombre_cte      CHAR(40);
	DEFINE wnumcte          CHAR(20);
	DEFINE wnumcte1         CHAR(20);
	DEFINE wnumcte2         CHAR(20);
    DEFINE vind_dispon      CHAR(1);
    DEFINE icodret          INTEGER;
    DEFINE ivueltas         SMALLINT;
	DEFINE whrstatus		CHAR(1);
    DEFINE vfech_spei       CHAR(10);
    DEFINE vfech_val        DATE;
	DEFINE wcuentabenefmsg	CHAR(20);
	DEFINE wcuentabenefemail CHAR(20);
	DEFINE wtpoctabenefmsg  CHAR(25);
    DEFINE wsecuencia       SMALLINT;
	--FIRMA
	DEFINE wcadena_val      CHAR (1000);
	DEFINE codretfirma      INTEGER;
	DEFINE wvchrcodretcodi  CHAR(5);
	DEFINE wimporte         DECIMAL(12,2);
	DEFINE cVarDataErr      CHAR(100);
	DEFINE vtimestamp       LVARCHAR(20);
	DEFINE wtimestamp       CHAR(20);
	--DEFINE pvchrNombreOrd   CHAR (20);
	DEFINE pintBancoDest    CHAR(5);
	--DEFINE pintTipoCtaBenef CHAR (2);
	--DEFINE pvchrNombreBenef CHAR (20);
	DEFINE wcomision 		DECIMAL(14,2);
	DEFINE vcomision        CHAR(7);
	DEFINE vcomision2       CHAR(7);
	DEFINE vcomision3       CHAR(7);
    
    -- ORION
    DEFINE wtpo_prod            CHAR(3);
    DEFINE wes_credito          SMALLINT;
    DEFINE wtpo_credito         CHAR(2);
    DEFINE wcodret_credcomer    CHAR(5);
    DEFINE wcodret_credconsu    CHAR(6);
    DEFINE wmsjret_speicrd      CHAR(100);
    DEFINE vciclo               SMALLINT;
    DEFINE cStatus              CHAR(1);
    DEFINE vSQL                 CHAR(10);
    
    DEFINE ves_fisica           CHAR(1);
    DEFINE vsufijo              CHAR(60);
	
	DEFINE vconta            	SMALLINT; 


    LET vCodRet1      = "000";
    LET vCodRet2      = "";
    LET vCodRet3      = "";
    LET vSqlErr       = 0;
    LET vIsamErr      = 0;
    LET vDescErr      = "";
    LET wempresa      = '001';
    LET whora         = '';
    LET wserial_folio = 0;
    LET wfolio_suc    = '0';
    LET wcausa_dev    = '00';
    LET wcuenta       = '';
	LET vcuenta       = '';
    LET wnum_tarjeta  = '';
    LET wmaxsec       = 0;
    LET wsuc_cta      = '';
    LET wsucursal     = '9201';
    LET wusuario      = 'tranSPEI';
    LET wtransacc     = '';
    LET wtran_suc     = '0000';
    LET wdivisa       = '01';
    LET wexiste_mov   = 0;
	LET vrfc          = ' ';
    LET vnombre_cte   = ' ';
	LET wnumcte       = ' ';
	LET wnumcte1      = ' ';
	LET wnumcte2      = ' ';
    LET vind_dispon   = '0';
    LET icodret       = 0;
    LET ivueltas      = 0;
	LET wcuentabenefmsg = '';
	LET wcuentabenefemail = '';
	LET wtpoctabenefmsg = '';
    LET wsecuencia    = 0;
	LET wcadena_val   = '';
	LET codretfirma   = 0;
	LET wimporte      = pmnyImporte;
	LET cVarDataErr   = 'NO SE PUDO REALIZAR EL ABONO CODI';
	LET vtimestamp    = dbinfo('utc_current') * 1000;
	LET wtimestamp    = vtimestamp;
	--LET pvchrNombreOrd = ' ';
	LET pintBancoDest = '40137';
	LET vcomision2    = '0.00';
	LET vcomision3    = '0';
	--LET pintTipoCtaBenef = ' ';
	--LET pvchrNombreBenef = ' ';
    
    -- // ORION
    LET wtpo_prod = '';
    LET wes_credito = 0;
    LET wtpo_credito = '';
    LET wcodret_credcomer = '';
    LET wcodret_credconsu = '';
    LET wmsjret_speicrd = '';
    LET vciclo = 0;
    LET cStatus = 'N';
    LET vSQL = '';
    
    LET ves_fisica = '';
    LET vsufijo    = '';

    --SET DEBUG FILE TO "/informix/ash/spei/spnew/spei_recordenpago.out";
    --SET DEBUG FILE TO "/informix/ifg/spei_recordenpago.out";
    --SET DEBUG FILE TO "/informix/Priscilla/spei_recordenpago_pbe.out";
    --TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
       SET DEBUG FILE TO "/resplogifx/conciliachq/spei_recordenpago.txt";
       TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1    = vSqlErr;
            LET vCodRet2    = vIsamErr;
            LET vCodRet3    = vDescErr;
			LET wfolio_suc  = '0';
			LET vrfc        = ' ';
            LET vnombre_cte = ' ';
			LET wcausa_dev = '16';
            RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET wcomision = pcomision;
	
	IF pchartipopago IN('19', '20', '21', '22') THEN
		IF wcomision = 0.00 THEN
		   LET vcomision = '0.0';
		ELSE
	       LET vcomision = wcomision;
		END IF;
	ELSE
	   LET vcomision = '0.00';
	END IF;
	
	--GENERA CADENA A VALIDAR
		
	LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
	                  '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
					  '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
					  '|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pintTipoCtaBenef)||'|'||TRIM(pvchrNombreBenef)||'|';
	  
    EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(pcharfirma), 20)
	INTO codretfirma;

	IF codretfirma <> 0 THEN
		LET wcadena_val = '';
		LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
			'|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
			'|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
			'|'||pvchrNombreOrd||'|'||TRIM(pintTipoCtaBenef)||'|'||pvchrNombreBenef||'|';
	  
		EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(pcharfirma), 20)
		INTO codretfirma;
	END IF;
    
	IF codretfirma <> 0 THEN
		LET wcadena_val = '';
		LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
	          '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
			  '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision2)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
			  '|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pintTipoCtaBenef)||'|'||TRIM(pvchrNombreBenef)||'|';

	  
		EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(pcharfirma), 20)
		INTO codretfirma;
	END IF;

	IF codretfirma <> 0 THEN
		LET wcadena_val = '';
		LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
	          '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
			  '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision3)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
			  '|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pintTipoCtaBenef)||'|'||TRIM(pvchrNombreBenef)||'|';

	  
		EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(pcharfirma), 20)
		INTO codretfirma;
	END IF;		
	
    --LET codretfirma = 0;
	--//Valida si el tipo de pago es no presencial o punto a punto
	IF pchartipopago IN('20', '21', '22') THEN
	   LET pnumcelben = pnumseriecert;
	END IF;
	IF codretfirma = 0 THEN

		SELECT COUNT(*)
		INTO vconta
		FROM tblbcobloqueo
		WHERE cvecesif = intBancoOrd
		  AND chrstatus = 'B';
		
		IF vconta > 0 THEN
			LET wfolio_suc  = '0';
			LET wcausa_dev  = '02';
			LET vrfc        = '';
			LET vnombre_cte = '';

			INSERT INTO tblintfallo (vchrcuentaord, dtfech_hor, vchrcuentabenef) VALUES(pvchrcuentaord,CURRENT, pvchrcuentabenef);
						
			IF pchartipopago IN('19', '20', '21', '22') THEN
				EXECUTE PROCEDURE spei_recerrorescodi(wcausa_dev, cVarDataErr,'o',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
								pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  
								pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintTipoCtaBenef
								pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) --pvchrNombreBenef
				INTO wvchrcodretcodi;
			END IF;

			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;
		
		/*****/
		-- // Valida que la cuenta ordenante no este en lista negra
		IF pvchrtpoctaord = 40 THEN
			SELECT COUNT(*)
			INTO whrstatus
			FROM tblclabebloqueo
			WHERE vchrcuentaord = pvchrcuentaord
			AND chrstatus = 'A';

			IF whrstatus > 0 THEN
				LET wfolio_suc  = '0';
				LET wcausa_dev  = '02';
				LET vrfc        = '';
				LET vnombre_cte = '';

				INSERT INTO tblintfallo (vchrcuentaord, dtfech_hor, vchrcuentabenef) VALUES(pvchrcuentaord,CURRENT, pvchrcuentabenef);
						
				IF pchartipopago IN('19', '20', '21', '22') THEN
					EXECUTE PROCEDURE spei_recerrorescodi(wcausa_dev, cVarDataErr,'o',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
									pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  
									pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintTipoCtaBenef
									pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) --pvchrNombreBenef
					INTO wvchrcodretcodi;
				END IF;

				RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
			END IF;
		END IF;
		
		-- // Obtiene fechas del sistema de cheques
		SELECT ind_disponible
		  INTO vind_dispon
		  FROM bdicheq:sc_fechas
		 WHERE empresa = wempresa;

		IF vind_dispon = '0' THEN
			LET wfolio_suc = '0';
			LET wcausa_dev = '16';
			LET vrfc = ' ';
			LET vnombre_cte = ' ';
					
			IF pchartipopago IN('19', '20', '21', '22') THEN
				EXECUTE PROCEDURE spei_recerrorescodi(wcausa_dev, cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
									pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  --falta intBancoOrd
									pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintBancoDest y pintTipoCtaBenef
									pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				INTO wvchrcodretcodi;
			END IF;
						
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;

		IF ( ( pmnyimporte <= 0.00 ) OR ( pchrstatus is null OR pchrstatus = '' OR LENGTH(TRIM(pchrstatus)) <> 1 ) OR
			 ( LENGTH(TRIM(pvchrcuentabenef)) <> 16 AND LENGTH(TRIM(pvchrcuentabenef)) <> 18 AND LENGTH(TRIM(pvchrcuentabenef)) <> 10) ) THEN
			LET wfolio_suc = '0';
			LET wcausa_dev = '01';
			LET vrfc = ' ';
			LET vnombre_cte = ' ';
					
			IF pchartipopago IN('19', '20', '21', '22') THEN
				EXECUTE PROCEDURE spei_recerrorescodi(wcausa_dev, cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
								pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  --falta intBancoOrd
								pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintBancoDest y pintTipoCtaBenef
								pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				INTO wvchrcodretcodi;
			END IF;
					
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;

		SELECT vchrvalor
		  INTO vfech_spei
		  FROM tblparametros
		 WHERE vchrcveparametro = 'FECHA_OPERACION';

		LET vfech_val = SUBSTR(vfech_spei, 4, 2) || '/' || SUBSTR(vfech_spei, 1,2) || '/' || SUBSTR(vfech_spei, 7, 4);

		IF LENGTH(TRIM(pvchrcuentabenef)) = 11 THEN

			LET wcuenta = pvchrcuentabenef;

			SELECT NVL(cuenta, ' '), NVL(num_cte, ' ')
			  INTO vcuenta, wnumcte
			  FROM bdicheq:sc_maechq
			 WHERE empresa = wempresa
			   AND cuenta = wcuenta
			   AND status_cta in('1', '3', '4', '5');

			IF ( wnumcte is null OR wnumcte = '' OR wnumcte = ' ' ) THEN
				IF SUBSTR(wcuenta, 1, 2) = '80' THEN
					SELECT NVL(numcte, ' ')
					  INTO wnumcte
					  FROM bditransfer:tf_maecte
					 WHERE cuenta_tf = wcuenta
					   AND status_cta = '1';
				END IF;
			END IF;
					
		ELIF LENGTH(TRIM(pvchrcuentabenef)) = 16 THEN
			LET wtpoctabenefmsg = 'TARJETA DE DEBITO';
			LET wcuentabenefemail = 'XXXX XXXX XXXX ' || substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);
			SELECT NVL(cuenta, ' '), NVL(numcte, ' ')
				  INTO vcuenta, wnumcte
				  FROM bdicheq:sc_tarjeta
				 WHERE num_tarjeta = pvchrcuentabenef;

			IF ( wnumcte is null OR wnumcte = '' OR wnumcte = ' ' ) THEN
				IF SUBSTR(wcuenta, 1, 2) = '80' THEN
					SELECT NVL(numcte, ' ')
					  INTO wnumcte
					  FROM bditransfer:tf_maecte
					 WHERE cuenta_tf = wcuenta
					   AND status_cta = '1';
				END IF;
			END IF;

			LET wnum_tarjeta = pvchrcuentabenef;
			LET wcuenta = vcuenta;

		ELIF LENGTH(TRIM(pvchrcuentabenef)) = 18 THEN
                    
            LET wtpo_prod = SUBSTR(pvchrcuentabenef, 4, 3);
    
            SELECT {+AVOID_FULL (bdicred:sd_cat_prod_finac)} COUNT(*)
              INTO wes_credito
              FROM bdicred:sd_cat_prod_finac
             WHERE codigo_prod = wtpo_prod;
                     
            IF wes_credito > 0 THEN
               LET wtpoctabenefmsg = 'CUENTA CLABE';
               LET wcuentabenefemail = 'XXXX XXXX XXXX XX' || substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);
                        
				SELECT {+AVOID_FULL (bdicred:sd_cat_prod_finac)} tipocredito
                 INTO wtpo_credito
                 FROM bdicred:sd_cat_prod_finac
                WHERE codigo_prod = wtpo_prod;
                         
               IF wtpo_credito = '03' THEN
                   EXECUTE PROCEDURE sp_inserta_credspei(pvchrcuentabenef, pmnyimporte, pvchrclaverastreo)
                      INTO wcodret_credcomer;
                            
                   WHILE cStatus IN('N','E') 
                        SELECT status
                          INTO cStatus
                          FROM tblpagocred
                         WHERE cve_rastreo = pvchrclaverastreo;
                                   
						IF cStatus IN('F','X') THEN
							EXIT WHILE;
						ELSE
							LET vSQL = 'sleep 3';
							SYSTEM vSQL;
							LET vciclo = vciclo + 1;
							IF vciclo > 5 THEN
								EXIT WHILE; 
							END IF;
						END IF;
                   END WHILE;
                            
				  IF cStatus is null OR cStatus = '' OR cStatus IN('N','E','X') THEN
					 LET wcodret_credcomer = '00013';
				  END IF;
               ELSE
                    EXECUTE PROCEDURE bdicred:sp_valida_spei_cred(pvchrcuentabenef, pmnyimporte)
                       INTO wcodret_credconsu, wmsjret_speicrd, wnumcte, vnombre_cte, vrfc;
                            
                    LET wcodret_credconsu = wcodret_credconsu;
                    LET wmsjret_speicrd = wmsjret_speicrd;
               END IF;
                        
               IF wcodret_credcomer = '000' OR wcodret_credconsu = '000000' THEN
                  CALL sp_obtfoliosuc(wusuario)
                       RETURNING vcodret1, wserial_folio, wfolio_suc;

				  IF vcodret1 <> '000' THEN
                     LET wfolio_suc = 'SPEI'||vfech_val;
                  END IF;
                            
                  IF wtpo_credito = '03' THEN
                     SELECT TRIM(rfc_cte), TRIM(nombre_cliente), no_cte_central
                       INTO vrfc, vnombre_cte, wnumcte
                       FROM tblpagocred
                      WHERE cve_rastreo = pvchrclaverastreo;
                   /*
                   ELSE
                      SELECT trim(rfc), trim(nombre1)||' '||trim(nombre2)||' '||trim(apell_paterno)||' '||trim(apell_materno)||' '||trim(razon_social)
                        INTO vrfc, vnombre_cte
                        FROM bdinteg:si_cliente
                       WHERE numcte = wnumcte;
                   */
				  END IF;
                            
				   LET vnombre_cte = '|'||vnombre_cte;
               ELSE                            
                   LET wfolio_suc = '0';
                   LET wcausa_dev = '16';
                   LET vrfc = ' ';
                   LET vnombre_cte = ' ';
               END IF;
                    
               RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
                    
            ELSE
                    
               LET wtpoctabenefmsg = 'CUENTA CLABE';
               LET wcuentabenefemail = 'XXXX XXXX XXXX XX' || substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);
                   
               LET wcuenta = SUBSTR(pvchrcuentabenef, 7, 11);

               SELECT NVL(cuenta, ' '), NVL(num_cte, ' ')
                 INTO vcuenta, wnumcte
                 FROM bdicheq:sc_maechq
                WHERE empresa = wempresa
                  AND cuenta = wcuenta
                  AND status_cta in('1', '3', '4', '5');

               IF ( wnumcte is null OR wnumcte = '' OR wnumcte = ' ' ) THEN
                   IF SUBSTR(wcuenta, 1, 2) = '80' THEN
                      SELECT NVL(numcte, ' '), NVL(numcte_tf, ' ')
                        INTO wnumcte1, wnumcte2
                        FROM bditransfer:tf_maecte
                       WHERE cuenta_tf = wcuenta
                         AND status_cta = '1';

                       /* Toma el numero de cliente transfer en caso de que la cuenta no se haya abierta en Bancoppel - IFG 09112017 */
                       IF (wnumcte1 is null OR wnumcte1 = '' OR wnumcte1 = ' ' ) THEN
                           LET wnumcte = wnumcte2;
                       ELSE
                           LET wnumcte = wnumcte1;
                       END IF;
                   END IF;
               END IF;

               LET wcuenta = vcuenta;
                        
            END IF;

		ELIF LENGTH(TRIM(pvchrcuentabenef)) = 10 THEN
			 LET wtpoctabenefmsg = 'NUMERO DE TELEFONIA MOVIL';
			 LET wcuentabenefemail = 'XXXXXX' || substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);
			 SELECT cuenta, num_cte
			   INTO vcuenta, wnumcte
			   FROM bdicheq:sc_cuenta_telefono
			  WHERE telefono = pvchrcuentabenef;

			 LET wnum_tarjeta = '';

			 IF vcuenta is null OR vcuenta = '' THEN
				SELECT cuenta_tf, num_tarjeta, numcte
				  INTO vcuenta, wnum_tarjeta, wnumcte
				  FROM bditransfer:tf_maecte
				 WHERE telefono = pvchrcuentabenef
				   AND status_cta = '1';
			 END IF;
					
			 LET wcuenta = vcuenta;

		END IF;

		IF wnumcte is null OR wnumcte = '' THEN
			LET wfolio_suc = '0';
			LET wcausa_dev = '01';
			LET vrfc = ' ';
			LET vnombre_cte = ' ';

			IF pchartipopago IN('19', '20', '21', '22') THEN
				EXECUTE PROCEDURE spei_recerrorescodi(wcausa_dev, cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
								pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  --falta intBancoOrd
								pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintBancoDest y pintTipoCtaBenef
								pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				INTO wvchrcodretcodi;
			END IF;
					
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;

		IF SUBSTR(wcuenta, 1, 2) = '80' THEN
			SELECT trim(rfc), trim(nombre1)||' '||trim(nombre2)||' '||trim(apell_paterno)||' '||trim(apell_materno)
			  INTO vrfc, vnombre_cte
			  FROM bditransfer:tf_maecte
			 WHERE numcte = wnumcte
			   AND status_cta = '1';

			LET vnombre_cte = '|'||vnombre_cte;
		ELSE
			SELECT trim(cte.rfc), trim(cte.nombre1)||' '||trim(cte.nombre2)||' '||trim(cte.apell_paterno)||' '||trim(cte.apell_materno)||' '||trim(cte.razon_social), tip.es_fisica
			  INTO vrfc, vnombre_cte, ves_fisica
			  FROM bdinteg:si_cliente cte,
                   bdinteg:si_tipper tip
			 WHERE cte.numcte = wnumcte
               AND tip.tpo_persona = cte.tpo_persona;
                    
            IF ves_fisica <> 'S' THEN
               SELECT TRIM(suf.descripcion)
                 INTO vsufijo
                 FROM bdinteg:si_ctepm cpm,
                      bdinteg:si_sufijos suf
                 WHERE cpm.numcte = wnumcte
                   AND cpm.sufijo = suf.codigo;
                    
               LET vnombre_cte = TRIM(vnombre_cte)||' '||TRIM(vsufijo);
            END IF;
                    
            LET vnombre_cte = '|'||vnombre_cte;
		END IF;

		SELECT FIRST 1 folio_suc
		  INTO wfolio_suc
		  FROM bdicheq:sc_movdia
		 WHERE empresa = wempresa
		   AND cuenta = wcuenta
		   AND cancelad <> 'S'
		   AND referencia = pvchrclaverastreo
		   AND transacc in('0273','0276','0277','0446')
		   AND fech_val = vfech_val;

		IF ( wfolio_suc is not null OR wfolio_suc <> '' ) THEN
			LET wcausa_dev = '00';

			IF pchartipopago IN('19', '20', '21', '22') THEN
			    LET cVarDataErr = ' ';
				EXECUTE PROCEDURE spei_recerrorescodi(wcausa_dev, cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
								pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  --falta intBancoOrd
								pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintBancoDest y pintTipoCtaBenef
								pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				INTO wvchrcodretcodi;
			END IF;
					
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;

		IF pchrstatus = 'L' THEN 
           --Evaluar si es un CODI
           IF pchartipopago NOT IN('19', '20', '21', '22') THEN
              LET wtransacc = '0273';
           ELSE
              LET wtransacc = '0446';          
           END IF;
		ELIF pchrstatus = 'C' THEN
			 LET wtransacc = '0276';
		ELIF pchrstatus = 'D' THEN
			 LET wtransacc = '0277';
		ELSE
			 LET wfolio_suc = '0';
			 LET wcausa_dev = '01';
					
			 IF pchartipopago IN('19', '20', '21', '22') THEN
				EXECUTE PROCEDURE spei_recerrorescodi(wcausa_dev, cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
								pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  --falta intBancoOrd
								pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintBancoDest y pintTipoCtaBenef
								pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				INTO wvchrcodretcodi;
			 END IF;
					
			 RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;

		CALL sp_obtfoliosuc(wusuario)
			RETURNING vcodret1, wserial_folio, wfolio_suc;

		IF vcodret1 <> '000' THEN
			LET wfolio_suc = 'SPEI'||vfech_val;
			LET wcausa_dev = '00';
			--RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
			IF pchartipopago IN('19', '20', '21', '22') THEN
				EXECUTE PROCEDURE spei_recerrorescodi(wcausa_dev, cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
								pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  --falta intBancoOrd
								pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintBancoDest y pintTipoCtaBenef
								pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				INTO wvchrcodretcodi;
			END IF;
		END IF;

		-- // EJECUTA EL PROCESO PARA DEPOSITO EN CUENTAS DEL SISTEMA DE CHEQUES
		EXECUTE PROCEDURE bdicheq:abono_ref( wempresa, wsucursal, wusuario, wtransacc, wtran_suc, wfolio_suc, wcuenta, 0, pmnyimporte, pmnyimporte, 0, 0, 0, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ' )
		   INTO vcodret1;

		LET icodret = vcodret1::int;
		LET ivueltas = 1;

		WHILE icodret < 0 AND ivueltas <= 3
			SET LOCK MODE TO WAIT 2;

			EXECUTE PROCEDURE bdicheq:abono_ref( wempresa, wsucursal, wusuario, wtransacc, wtran_suc, wfolio_suc, wcuenta, 0, pmnyimporte, pmnyimporte, 0, 0, 0, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ' )
			   INTO vcodret1;

			LET icodret = vcodret1::int;
			LET ivueltas = ivueltas + 1;
		END WHILE;

		--- SI SE GENERA EL ABONO, SE ENVIA LA NOTIFICACION POR EMAIL Y SMS

		IF vcodret1 = '000' THEN
		
			IF pchartipopago IN('19', '20', '21', '22') THEN
			    LET cVarDataErr = ' ';
				EXECUTE PROCEDURE spei_recerrorescodi('0', cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
								pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  --falta intBancoOrd
								pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintBancoDest y pintTipoCtaBenef
								pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				   INTO wvchrcodretcodi;
			END IF;
			
			LET wcuentabenefmsg = substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);

			-- EMAIL
			 EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
			  ('1', 'SPEI_TRREC','SPEI_TRREC',wnumcte,'','','1','',wcuentabenefemail, pmnyimporte, pvchrclaverastreo,wtpoctabenefmsg,'','','','','','','',1,0,0,0,0,current,'')
			 INTO vcodret1;

			-- SMS
			 EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
			 ('2', 'SPEI_SMREC','SPEI_SMREC',wnumcte,'','','1',wcuentabenefmsg,pmnyimporte,'','','','','','','','','','',1,0,0,0,0,current,'')
			  INTO vcodret1;

		ELSE
		   SELECT NVL(LPAD(intcvecausadev,2,0), '00')
			 INTO wcausa_dev
			 FROM bdispei:tblcdev_codret
			WHERE intcvecausadev > 0
			  AND vchrcodigoerror = vcodret1;

		   IF wcausa_dev <> ' ' THEN
			  LET wfolio_suc = '0';
			  LET wcausa_dev = wcausa_dev;
		   ELSE
			  LET wfolio_suc = '0';
			  LET wcausa_dev = '16';
		   END IF;

				   

		   IF pchartipopago IN('19', '20', '21', '22') THEN
				EXECUTE PROCEDURE spei_recerrorescodi('16', cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
								pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  --falta intBancoOrd
								pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintBancoDest y pintTipoCtaBenef
								pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				INTO wvchrcodretcodi;
		   END IF;
			 
		   RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;
	ELSE 
		LET wfolio_suc  = '0';
		LET wcausa_dev  = '16';
		LET vrfc        = '';
		LET vnombre_cte = '';

		--INSERT INTO tblintfallo (vchrcuentaord, dtfech_hor, vchrcuentabenef) VALUES(pvchrcuentaord,CURRENT, pvchrcuentabenef);
			
		IF pchartipopago IN('19', '20', '21', '22') THEN
			EXECUTE PROCEDURE spei_recerrorescodi(wcausa_dev, cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,  
							pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, intBancoOrd,pvchrtpoctaord,  --falta intBancoOrd
							pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,  --pvchrNombreOrd, pintBancoDest y pintTipoCtaBenef
							pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
			INTO wvchrcodretcodi;
		END IF;

		RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
	END IF;

    END;

	RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;

END PROCEDURE;