CREATE PROCEDURE "informix".sp_obt_detalle_movimientos_bpi(pFechaApl DATE, pCuenta CHAR(20), pClabe CHAR(30), pClaveRastreo CHAR (40), pFolio CHAR (40))
RETURNING   CHAR (5)  AS CodRet,
            DATETIME YEAR to SECOND as FechaLiq, 
            CHAR (40) as ClaveRastreo, 
            CHAR (30) as ReferenciNum, 
            CHAR (40) as ConceptoPago, 
            CHAR (40) as DenominacionPartici, 
            CHAR (20) AS ClaveCuentaEmisor,
			CHAR (20) AS ClaveCuentaReceptor,
            CHAR (40) AS NombreEmisor, 
            CHAR (40) AS CausaDevDesc,
            CHAR (6) AS IdDenominacionPartici,
            CHAR (4) AS Transaccion,
            CHAR (2) AS Naturaleza;

-- VersiÃ³n   : 6.0
-- Realizo   :  Ricardo Ravago
-- Actividad : Obtiene informaciÃ³n adicional para transacciones SPEI, cumpliendo con la normativa de Banxico para el registro de observaciones
-- Solicita  : Gabriela Aguilar
-- Fecha     : 29/04/2026


    DEFINE intcodret INTEGER;
    DEFINE v_sCodRet CHAR(5);
    DEFINE vcFechaLiq DATETIME YEAR to SECOND;
    DEFINE vcHoraMinutos CHAR(8); 
    DEFINE vcClaveRastreo CHAR(40);
    DEFINE vcReferenciNum CHAR(30);
    DEFINE vcConceptoPago CHAR(40);
    DEFINE vcDenominacionPartici CHAR(40);
    DEFINE vcClaveCuentaEmisor CHAR(20);
	DEFINE vcClaveCuentaReceptor CHAR(20);
    DEFINE vcNombreEmisor CHAR(40);
    DEFINE vcCausaDevDesc CHAR(40);
    DEFINE vcNumCte CHAR (20);
    DEFINE ptransa CHAR(4);
    
    DEFINE vcCtaClabe CHAR(30);
    DEFINE vcReferencia CHAR(40);
    DEFINE vcFolio CHAR(40);
	DEFINE vFolio CHAR(40);
    DEFINE vcCausaDev CHAR(5);
    DEFINE vcIdParticipanteEmisor CHAR(6);
    DEFINE vcTransacc CHAR(4);
	DEFINE vEmpresa CHAR(4);

    DEFINE vcNaturaleza CHAR (2);
    DEFINE vFechaHoy DATE;
    DEFINE iExiste INTEGER;
	DEFINE vdia CHAR(1);
	

    LET vcFechaLiq = "";
    LET vcHoraMinutos = "";
    LET vcClaveRastreo = "";
    LET vcReferenciNum = "";
    LET vcConceptoPago = "";
    LET vcDenominacionPartici = "";
    LET vcClaveCuentaEmisor = "";
	LET vcClaveCuentaReceptor = "";
    LET vcNombreEmisor = "";
    LET vcCausaDevDesc = "";
	LET vEmpresa ='001';

    LET vcCtaClabe = pClabe;
    LET vcReferencia = pClaveRastreo;
    LET vcFolio = pFolio;
    LET vcCausaDev = "";
    LET vcIdParticipanteEmisor = "";
    LET vcTransacc = "";
    LET vcNaturaleza = "";
    LET v_sCodRet = '00000';
    LET iExiste	= 0;
	LET ptransa="";
	
    
BEGIN

    -- Manejo de errores fatales
    ON EXCEPTION SET intcodret
		IF intcodret <> 0 THEN
			LET v_sCodRet  = intcodret;
            RETURN v_sCodRet, vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor, vcNombreEmisor, vcCausaDevDesc, vcIdParticipanteEmisor, vcTransacc, vcNaturaleza;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/home/sysaccapp/sp_obt_detalle_movimientos_bpi.out";
    ---TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --VARIFICA QUE UNO DE ESTOS TRES DATOS OBLIGATORIOS DEL CLIENTE VENGA INFORMACION	
	IF (pFechaApl IS NULL OR pFechaApl = '') AND (pCuenta IS NULL OR pCuenta ='') AND (pClabe IS NULL OR pClabe = '') THEN
	   LET v_sCodRet = '00110';
	   RETURN v_sCodRet, vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor, vcNombreEmisor, vcCausaDevDesc, vcIdParticipanteEmisor, vcTransacc, vcNaturaleza;
	END IF;

		SELECT fecha_hoy
		INTO vFechaHoy
		FROM bdicheq:"informix".sc_fechas;
		

		LET vdia = '0';
		
		IF pClabe<>'' THEN
		    LET ptransa = pClabe;
		END IF;	
		
		IF pFolio <> '' AND pClabe='' THEN			

			FOREACH
				SELECT mm.transacc, mm.folio_suc
				INTO
						vcTransacc,vFolio
				FROM
						bdicheq:"informix".sc_movdia AS mm
				WHERE
						mm.empresa = vEmpresa AND
						mm.cuenta = pCuenta AND
						mm.fech_alt = pFechaApl AND
						mm.cancelad <> "S" AND 
						mm.folio_suc = vcFolio
				UNION
				SELECT mm.transacc, mm.folio_suc
				FROM
						bdicheq:"informix".sc_movhis AS mm
				WHERE
						mm.empresa = vEmpresa AND
						mm.cuenta = pCuenta AND
						mm.fech_alt = pFechaApl AND
						mm.cancelad <> "S" AND
						mm.folio_suc = vcFolio
					
					LET iExiste = 1;
					LET ptransa = vcTransacc;
					
			END FOREACH;
			
		END IF;

		IF (ptransa IS NULL OR ptransa = '') THEN
			LET v_sCodRet = '00120';
			RETURN v_sCodRet, vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor, vcNombreEmisor, vcCausaDevDesc, vcIdParticipanteEmisor, vcTransacc, vcNaturaleza;
		END IF;
		
		LET iExiste = 0;
		-- Obtiene movimientos del dia
		IF pFechaApl = vFechaHoy THEN
			LET vdia = '1';
			FOREACH
				SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
						mm.transacc, mm.referencia, mm.folio_suc, mm.causa_dev, tr.naturaleza
        		INTO    vcTransacc, vcClaveRastreo, vcFolio, vcCausaDev, vcNaturaleza
				FROM    	 
					bdicheq:"informix".sc_movdia AS mm,
					bdinteg:"informix".si_transacc AS tr 
				WHERE
					mm.empresa = vEmpresa AND
					mm.cuenta = pCuenta AND
					mm.fech_alt = vFechaHoy AND
					mm.cancelad <> "S" AND
					mm.empresa = tr.empresa AND
					mm.transacc = tr.numero AND
					tr.se_emite_edocta = "S" AND
					tr.sistema = "01" AND  
					mm.transacc = ptransa
        			AND (
							((vcReferencia IS NOT NULL AND vcReferencia != '') AND mm.referencia = vcReferencia)
						OR 
							((vcFolio IS NOT NULL AND vcFolio != '') AND mm.folio_suc = vcFolio)
						)
					ORDER BY
					mm.fech_alt DESC,
					mm.num_serial DESC

					LET iExiste = 1;
					
			END FOREACH;
		ELSE
			LET vdia = '2';
			FOREACH
				SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}  
						mm.transacc, mm.referencia, mm.folio_suc, mm.causa_dev, tr.naturaleza
				INTO vcTransacc, vcClaveRastreo, vcFolio, vcCausaDev, vcNaturaleza
				FROM
						bdicheq:"informix".sc_movhis AS mm,
						bdinteg:"informix".si_transacc AS tr
				WHERE
						mm.empresa = vEmpresa AND
						mm.cuenta = pCuenta AND						
						mm.fech_alt >= pFechaApl AND
						mm.cancelad <> "S" AND
						mm.transacc = tr.numero AND
						mm.empresa = tr.empresa AND
						tr.se_emite_edocta = "S" AND
						tr.sistema = "01" AND 
						mm.transacc = ptransa
						AND (
								((mm.referencia IS NOT NULL AND mm.referencia != '') AND mm.referencia = vcReferencia)
							OR ((mm.folio_suc IS NOT NULL AND mm.folio_suc != '') AND mm.folio_suc = vcFolio)
							)
					LET iExiste = 1;
			END FOREACH;
		END IF;

	-- Consulta por dia
    IF (iExiste = 1 AND vdia='1' AND vcFolio <>'') THEN
		 
		
        IF vcNaturaleza IS NOT NULL AND vcNaturaleza = 'C' THEN
            --Consulta 1 (Movimiento del dÃ­a, aplicado el mismo dÃ­a)    
            SELECT NVL(COUNT(*),0) INTO iExiste 
            FROM bdispei:"informix".tblpago AS t 
                JOIN bdicheq:"informix".sc_movdia AS h ON h.folio_suc = t.chrfolioprom
                WHERE t.vchrclaverastreo = vcClaveRastreo 
                AND t.chrfolioprom = vcFolio 
                AND t.chrtxop = vcTransacc;

            IF (iExiste = 1) THEN
				
                SELECT TO_DATE(TO_CHAR(h.fech_val, '%Y-%m-%d') || ' ' || TO_CHAR(h.fech_hor, '%H:%M:%S'), '%Y-%m-%d %H:%M:%S'), t.vchrclaverastreo, t.intrefnumerica, t.vchrconceptopago2, b.descripcion, t.vchrcuentaord, t.vchrcuentabenef, t.vchrnombreord, cau.vchrdescripcion, t.cvecesifbcodest
                INTO vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor, vcNombreEmisor, vcCausaDevDesc, vcIdParticipanteEmisor     
                FROM bdispei:"informix".tblpago AS t 
                    INNER JOIN bdicheq:"informix".sc_movdia AS h ON h.folio_suc = t.chrfolioprom
                    LEFT JOIN bdispei:"informix".tblcausadev AS cau ON t.intcvecausadev = cau.intcvecausadev
                    LEFT JOIN bdinteg:"informix".si_bancos AS b ON t.cvecesifbcodest = b.cvecesif
                WHERE t.vchrclaverastreo = vcClaveRastreo 
                AND t.chrfolioprom = vcFolio 
                AND t.chrtxop = vcTransacc;
				
                RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
            
            END IF;
            LET v_sCodRet = '00111';
			
	        RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
               
        ELIF vcNaturaleza = 'A' THEN

            SELECT NVL(COUNT(*),0) INTO iExiste FROM bdispei:"informix".tblabono AS t
            WHERE t.vchrclaverastreo = vcClaveRastreo 
            AND t.vchrfoliosuc = vcFolio 
            AND t.vchrtransacc = vcTransacc;

            IF (iExiste = 1) THEN                    
					SELECT  (to_char(t.dtfechavalor, '%Y-%m-%d') || " " || NVL(to_char(dbinfo('utc_to_datetime', (t.chrfchmjc)/1000),'%H:%M:%S'), "00:00:00"))::DATETIME YEAR TO SECOND,
							t.vchrclaverastreo, t.intrefnumerica, t.vchrconceptopago2, b.descripcion, t.vchrcuentaord, t.vchrcuentabenef, t.vchrnombreord, t.cvecesifbcoord
					INTO    vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor,vcNombreEmisor, vcIdParticipanteEmisor
					FROM bdispei:"informix".tblabono AS t
						LEFT JOIN bdinteg:"informix".si_bancos AS b ON t.cvecesifbcoord = b.cvecesif 
					WHERE t.vchrclaverastreo = vcClaveRastreo 
					AND t.vchrfoliosuc = vcFolio 
					AND t.vchrtransacc = vcTransacc;
				
                RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
			ELSE
				IF  vcTransacc='0277' THEN
					SELECT TO_DATE(TO_CHAR(h.fech_val, '%Y-%m-%d') || ' ' || TO_CHAR(h.fech_hor, '%H:%M:%S'), '%Y-%m-%d %H:%M:%S'), t.vchrclaverastreo, t.intrefnumerica, t.vchrconceptopago2, b.descripcion, t.vchrcuentaord, t.vchrcuentabenef, t.vchrnombreord, cau.vchrdescripcion, t.cvecesifbcodest
					INTO vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor, vcNombreEmisor, vcCausaDevDesc, vcIdParticipanteEmisor     
					FROM bdispei:"informix".tblpago AS t 
						INNER JOIN bdicheq:"informix".sc_movdia AS h ON h.folio_suc = t.chrfolioprom
						LEFT JOIN bdispei:"informix".tblcausadev AS cau ON t.intcvecausadev = cau.intcvecausadev
						LEFT JOIN bdinteg:"informix".si_bancos AS b ON t.cvecesifbcodest = b.cvecesif
					WHERE t.vchrclaverastreo = vcClaveRastreo;
					
					RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
				END IF ;
				
            END IF;
								
            LET v_sCodRet = '00112';
			
	        RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
        END IF;               
	END IF;
	
	-- Consulta por historial
    IF (iExiste = 1 AND vdia='2' AND vcFolio <>'') THEN

            IF vcNaturaleza IS NOT NULL AND vcNaturaleza = 'C' THEN                
                --Consulta 2 (Movimiento de otro dÃ­a, aplicado el dÃ­a actual)
                SELECT NVL(COUNT(*),0) INTO iExiste 
                FROM bdispei:"informix".tblpago AS t 
                INNER JOIN bdicheq:"informix".sc_movhis AS h ON h.folio_suc = t.chrfolioprom
                WHERE t.vchrclaverastreo = vcClaveRastreo 
                AND t.chrfolioprom = vcFolio 
                AND t.chrtxop = vcTransacc;

                IF (iExiste = 1) THEN
                    SELECT TO_DATE(TO_CHAR(h.fech_val, '%Y-%m-%d') || ' ' || TO_CHAR(h.fech_hor, '%H:%M:%S'), '%Y-%m-%d %H:%M:%S'), t.vchrclaverastreo, t.intrefnumerica, t.vchrconceptopago2, b.descripcion, t.vchrcuentaord, t.vchrcuentabenef, t.vchrnombreord, cau.vchrdescripcion, t.cvecesifbcodest
                    INTO vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor, vcNombreEmisor, vcCausaDevDesc, vcIdParticipanteEmisor     
                    FROM bdispei:"informix".tblpago AS t 
                        INNER JOIN bdicheq:"informix".sc_movhis AS h ON h.folio_suc = t.chrfolioprom
                        LEFT JOIN bdispei:"informix".tblcausadev AS cau ON t.intcvecausadev = cau.intcvecausadev
                        LEFT JOIN bdinteg:"informix".si_bancos AS b ON t.cvecesifbcodest = b.cvecesif
                    WHERE t.vchrclaverastreo = vcClaveRastreo 
                        AND t.chrfolioprom = vcFolio 
                        AND t.chrtxop = vcTransacc;
                            
	                RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');

                ELSE
                    --Consulta 3 (Movimiento de otro dÃ­a, aplicado dÃ­a diferente al dÃ­a de hoy)
                    SELECT NVL(COUNT(*),0) INTO iExiste 
                    FROM bdispei:"informix".tblhistpago AS t 
                    INNER JOIN bdicheq:"informix".sc_movhis AS h ON h.folio_suc = t.chrfolioprom
                    WHERE t.vchrclaverastreo = vcClaveRastreo 
                    AND t.chrfolioprom = vcFolio 
                    AND t.chrtxop = vcTransacc;

                    IF (iExiste = 1) THEN

                        SELECT TO_DATE(TO_CHAR(h.fech_val, '%Y-%m-%d') || ' ' || TO_CHAR(h.fech_hor, '%H:%M:%S'), '%Y-%m-%d %H:%M:%S'), t.vchrclaverastreo, t.intrefnumerica, t.vchrconceptopago2, b.descripcion, t.vchrcuentaord, t.vchrcuentabenef, t.vchrnombreord, cau.vchrdescripcion, t.cvecesifbcodest
                        INTO vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor, vcNombreEmisor, vcCausaDevDesc, vcIdParticipanteEmisor     
                        FROM bdispei:"informix".tblhistpago AS t 
                            INNER JOIN bdicheq:"informix".sc_movhis AS h ON h.folio_suc = t.chrfolioprom
                            LEFT JOIN bdispei:"informix".tblcausadev AS cau ON t.intcvecausadev = cau.intcvecausadev
                            LEFT JOIN bdinteg:"informix".si_bancos AS b ON t.cvecesifbcodest = b.cvecesif
                        WHERE t.vchrclaverastreo = vcClaveRastreo 
                        AND t.chrfolioprom = vcFolio 
                        AND t.chrtxop = vcTransacc;
	                    
                        RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');    
                    END IF;
                        LET v_sCodRet = '00113';
	                    RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
                END IF;

            ELIF vcNaturaleza = 'A' THEN

                SELECT NVL(COUNT(*),0) INTO iExiste 
                FROM bdispei:"informix".tblhistabono AS t
                WHERE t.vchrclaverastreo = vcClaveRastreo 
                AND t.vchrfoliosuc = vcFolio 
                AND t.vchrtransacc = vcTransacc;

                IF (iExiste = 1) THEN   
						SELECT  (to_char(t.dtfechavalor, '%Y-%m-%d') || " " || NVL(to_char(dbinfo('utc_to_datetime', (t.chrfchmjc)/1000),'%H:%M:%S'), "00:00:00"))::DATETIME YEAR TO SECOND,
								t.vchrclaverastreo, t.intrefnumerica, t.vchrconceptopago2, b.descripcion, t.vchrcuentaord, t.vchrcuentabenef, t.vchrnombreord, t.cvecesifbcoord
						INTO    vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor, vcNombreEmisor, vcIdParticipanteEmisor
						FROM bdispei:"informix".tblhistabono AS t
							LEFT JOIN bdinteg:"informix".si_bancos AS b ON t.cvecesifbcoord = b.cvecesif 
						WHERE t.vchrclaverastreo = vcClaveRastreo 
						AND t.vchrfoliosuc = vcFolio 
						AND t.vchrtransacc = vcTransacc;
					 
					
	                RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
				ELSE
					IF  vcTransacc='0277' THEN
						SELECT TO_DATE(TO_CHAR(h.fech_val, '%Y-%m-%d') || ' ' || TO_CHAR(h.fech_hor, '%H:%M:%S'), '%Y-%m-%d %H:%M:%S'), t.vchrclaverastreo, t.intrefnumerica, t.vchrconceptopago2, b.descripcion, t.vchrcuentaord, t.vchrcuentabenef, t.vchrnombreord, cau.vchrdescripcion, t.cvecesifbcodest
						INTO vcFechaLiq, vcClaveRastreo, vcReferenciNum, vcConceptoPago, vcDenominacionPartici, vcClaveCuentaEmisor, vcClaveCuentaReceptor, vcNombreEmisor, vcCausaDevDesc, vcIdParticipanteEmisor     
						FROM bdispei:"informix".tblhistpago AS t 
							INNER JOIN bdicheq:"informix".sc_movhis AS h ON h.folio_suc = t.chrfolioprom
							LEFT JOIN bdispei:"informix".tblcausadev AS cau ON t.intcvecausadev = cau.intcvecausadev
							LEFT JOIN bdinteg:"informix".si_bancos AS b ON t.cvecesifbcodest = b.cvecesif
						WHERE t.vchrclaverastreo = vcClaveRastreo;
						
						RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
					END IF;
                END IF;
				
				
			
                LET v_sCodRet = '00114';
	            RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
            END IF;
    END IF;
    
	LET v_sCodRet = '00115';
	RETURN COALESCE(v_sCodRet, ''), vcFechaLiq, COALESCE(vcClaveRastreo, ''), COALESCE(vcReferenciNum, ''), COALESCE(vcConceptoPago, ''), COALESCE(vcDenominacionPartici, ''), COALESCE(vcClaveCuentaEmisor, ''), COALESCE(vcClaveCuentaReceptor, ''), COALESCE(vcNombreEmisor, ''), COALESCE(vcCausaDevDesc, ''), COALESCE(vcIdParticipanteEmisor, ''), COALESCE(vcTransacc, ''), COALESCE(vcNaturaleza, '');
    
END;
END PROCEDURE;