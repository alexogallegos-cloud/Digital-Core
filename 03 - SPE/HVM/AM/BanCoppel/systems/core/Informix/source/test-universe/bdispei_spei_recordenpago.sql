CREATE PROCEDURE "informix".spei_recordenpago( pvchrclaverastreo	CHAR(30),       -- clave de rastreo
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
											   pnumcelord 			CHAR(10), 
											   pnumcelben 			CHAR (20),
                        					   pdigidord 			INTEGER,
                        					   pdigidben 			INTEGER,
                        					   pfechalimpago 		CHAR(16),
                        					   intBancoOrd 			CHAR(5),
                        					   ppagocomision 		INTEGER,
                        					   pcomision 			DECIMAL(14,2),
                                               pnumseriecert 		CHAR(20),
											   pfolioplataforma 	CHAR(20), 
                                               pchridmjc 			CHAR(20), 
                                               pchrfchmjc 			CHAR(20),
											   pvchrNombreOrd       CHAR(40),
											   pintTipoCtaBenef     CHAR(2),
											   pvchrNombreBenef     CHAR(40),
											   presfirm             INTEGER)  --resultado validacion firma 0 correcta 1 incorrecta 29 01 2026
											   
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
    
	-- // FIRMA
	DEFINE wcadena_val      CHAR (1000);
	DEFINE codretfirma      INTEGER;
	DEFINE wvchrcodretcodi  CHAR(5);
	DEFINE wimporte         DECIMAL(12,2);
	DEFINE cVarDataErr      CHAR(100);
	DEFINE vtimestamp       LVARCHAR(20);
	DEFINE wtimestamp       CHAR(20);
    --- DEFINE pvchrNombreOrd   CHAR (20);
	DEFINE pintBancoDest    CHAR(5);
    --- DEFINE pintTipoCtaBenef CHAR (2);
    --- DEFINE pvchrNombreBenef CHAR (20);
	DEFINE wcomision 		DECIMAL(14,2);
	DEFINE vcomision        CHAR(7);
	DEFINE vcomision2       CHAR(7);
	DEFINE vcomision3       CHAR(7);
    
    -- // ORION
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
    DEFINE vfecha_hoy           DATE;
    DEFINE wstatus_cta          CHAR(1);
    DEFINE wmotivo              CHAR(2);
    DEFINE iExiste              SMALLINT;
    DEFINE wopcion              INTEGER;
    DEFINE wabono               CHAR(1);
    
    DEFINE vproducto            CHAR(4);
    DEFINE vExisLimProd         SMALLINT;
    DEFINE vTrxExentaLimProd    SMALLINT;
    DEFINE vhoramax             DATETIME HOUR TO MINUTE;
    DEFINE vprecio_udi          DECIMAL(14,6);
    DEFINE vfecha_tpcambio      DATE;
    DEFINE vnomaxudis           INTEGER;
    DEFINE vmtoacumcta          DECIMAL(18,6);
    DEFINE vmonto_udi           DECIMAL(18,6);
    DEFINE vmtopagosudi         DECIMAL(18,6);
    DEFINE vlim_cuenta          DECIMAL(18,6);
    
    DEFINE wvchrorigen          CHAR(1);
    DEFINE wchrdigito           CHAR(1);
    
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
    --- LET pvchrNombreOrd = ' ';
	LET pintBancoDest = '40137';
	LET vcomision2    = '0.00';
	LET vcomision3    = '0';
    --- LET pintTipoCtaBenef = ' ';
    --- LET pvchrNombreBenef = ' ';
    
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
    LET vsufijo = '';
    LET vfecha_hoy = '';
    LET wstatus_cta = '';
    LET wmotivo = '';
    LET iExiste = 0;
    LET wopcion = 0;
    LET wabono = '';
    LET vfech_val = '';
    
    LET vproducto         = '';
    LET vExisLimProd      = 0;
    LET vTrxExentaLimProd = 0;
    LET vhoramax          = '';
    LET vprecio_udi       = 0.00; 
    LET vfecha_tpcambio   = '';
    LET vnomaxudis        = 0;
    LET vmtoacumcta       = 0.00;
    LET vmonto_udi        = 0.00;
    LET vmtopagosudi      = 0.00;
    LET vlim_cuenta       = 0.00;
    
    LET wvchrorigen = '';
    LET wchrdigito  = '';

     --SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_recordenpago.out";
     --TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_recordenpago.err";
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
	
    -- // DETERMINA LA COMISION
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
    
    -- // DETERMINA LA TRANSACCION A UTILIZAR
    IF pchrstatus = 'L' THEN 
        IF pchartipopago NOT IN('19', '20', '21', '22') THEN --- Evaluar si es un CODI
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
            CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                     intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
            RETURNING wvchrcodretcodi;
        END IF;
        
        INSERT INTO tblabono 
        ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
          vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
          chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
          fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
        VALUES
        ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
          pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
          pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
          pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                
        RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
    END IF;
    
    -- // VALIDA EL TIPO DE CUENTA
    IF LENGTH(TRIM(pvchrcuentabenef)) = 11 THEN
        
        LET wcuenta = pvchrcuentabenef;

        SELECT NVL(cuenta, ' '), NVL(num_cte, ' ')
          INTO vcuenta, wnumcte
          FROM bdicheq:sc_maechq
         WHERE empresa = wempresa
           AND cuenta = wcuenta
           AND status_cta in('1', '3', '4', '5');
           
    ELIF LENGTH(TRIM(pvchrcuentabenef)) = 16 THEN
    
        LET wtpoctabenefmsg = 'TARJETA DE DEBITO';
        LET wcuentabenefemail = 'XXXX XXXX XXXX ' || substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);
        
        SELECT NVL(cuenta, ' '), NVL(numcte, ' ')
              INTO vcuenta, wnumcte
              FROM bdicheq:sc_tarjeta
             WHERE num_tarjeta = pvchrcuentabenef;

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
                EXECUTE PROCEDURE bdicred:sp_valida_spei_cred(pvchrclaverastreo,pvchrcuentabenef, pmnyimporte)
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
        LET wcuenta = vcuenta;
        
    END IF;
    
    -- // OBTIENE DATOS DE LA CUENTA
    SELECT status_cta, motivo, producto
      INTO wstatus_cta, wmotivo, vproducto
      FROM bdicheq:sc_maechq
     WHERE cuenta = wcuenta;
    
    IF wtransacc = '04446' OR vproducto = '2900' THEN

/* -- SE COMENTA LA VALIDACION DE FIRMA 29 01 2026
        -- // GENERA CADENA A VALIDAR
        LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
                          '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
                          '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
                          '|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pintTipoCtaBenef)||'|'||TRIM(pvchrNombreBenef)||'|';
          
        EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(pcharfirma), 21)
        INTO codretfirma;

        IF codretfirma <> 0 THEN
            LET wcadena_val = '';
            LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
                '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
                '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
                '|'||pvchrNombreOrd||'|'||TRIM(pintTipoCtaBenef)||'|'||pvchrNombreBenef||'|';
          
            EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(pcharfirma), 21)
            INTO codretfirma;
        END IF;
        
        IF codretfirma <> 0 THEN
            LET wcadena_val = '';
            LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
                  '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
                  '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision2)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
                  '|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pintTipoCtaBenef)||'|'||TRIM(pvchrNombreBenef)||'|';

          
            EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(pcharfirma), 21)
            INTO codretfirma;
        END IF;

        IF codretfirma <> 0 THEN
            LET wcadena_val = '';
            LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
                  '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
                  '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision3)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
                  '|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pintTipoCtaBenef)||'|'||TRIM(pvchrNombreBenef)||'|';

          
            EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(pcharfirma), 21)
            INTO codretfirma;
        END IF;	

*/ -- SE COMENTA LA VALIDACION DE FIRMA 29 01 2026

	LET codretfirma = presfirm;
        
        --- LET codretfirma = 0;
        
        -- // Valida si el tipo de pago es no presencial o punto a punto
        IF pchartipopago IN('20', '21', '22') THEN
           LET pnumcelben = pnumseriecert;
        END IF;
        
        -- // VALIDA LIMITES PARA CUENTAS NIVEL 2
        IF vproducto = '2900' THEN
            SELECT COUNT(*)
              INTO vExisLimProd
              FROM bdicheq:sc_limites_producto
             WHERE producto = vproducto;
             
            IF vExisLimProd > 0 THEN
                SELECT COUNT(*)
                  INTO vTrxExentaLimProd
                  FROM bdicheq:sc_transacc_exentas_limprod
                 WHERE transacc = wtransacc;
                 
                IF vTrxExentaLimProd = 0 THEN
                    -- // OBTIENE EL VALOR DE LA UDI
                    SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                           FIRST 1 MAX(hora_tpcambio) 
                      INTO vhoramax
                      FROM bdinteg:si_tpcambio 
                     WHERE empresa = wempresa 
                       AND divisa = '09'
                       AND fecha_tpcambio = vfecha_hoy;
                    
                    IF vhoramax is null OR vhoramax = '' THEN
                        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                               FIRST 1 precio_venta
                          INTO vprecio_udi
                          FROM bdinteg:si_tpcambio
                         WHERE empresa = wempresa
                           AND divisa = '09'
                           AND fecha_tpcambio = vfecha_hoy;
                    ELSE
                        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                               FIRST 1 precio_venta
                          INTO vprecio_udi
                          FROM bdinteg:si_tpcambio
                         WHERE empresa = wempresa
                           AND divisa = '09'
                           AND fecha_tpcambio = vfecha_hoy
                           AND hora_tpcambio = vhoramax;
                    END IF;
                   
                    IF vprecio_udi is null OR vprecio_udi = '' THEN
                        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                               FIRST 1 MAX(fecha_tpcambio) 
                          INTO vfecha_tpcambio
                          FROM bdinteg:si_tpcambio
                         WHERE empresa = wempresa 
                           AND divisa = '09'
                           AND fecha_tpcambio <= vfecha_hoy;
                       
                        SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                               FIRST 1 MAX(hora_tpcambio) 
                          INTO vhoramax
                          FROM bdinteg:si_tpcambio 
                         WHERE empresa = wempresa 
                           AND divisa = '09'
                           AND fecha_tpcambio = vfecha_tpcambio;
                        
                        IF vhoramax is null OR vhoramax = '' THEN
                            SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                                   FIRST 1 precio_venta
                              INTO vprecio_udi
                              FROM bdinteg:si_tpcambio
                             WHERE empresa = wempresa
                               AND divisa = '09'
                               AND fecha_tpcambio = vfecha_tpcambio;
                        ELSE
                            SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
                                   FIRST 1 precio_venta
                              INTO vprecio_udi
                              FROM bdinteg:si_tpcambio
                             WHERE empresa = wempresa
                               AND divisa = '09'
                               AND fecha_tpcambio = vfecha_tpcambio
                               AND hora_tpcambio = vhoramax;
                        END IF;
                    END IF;
                    
                    -- // OBTIENE EL VALOR MAXIMO DE UDIS 
                    SELECT valor::int
                      INTO vnomaxudis
                      FROM bdicheq:sc_param
                     WHERE codparam = "UdisMaxDepCtaNvl2"
                       AND empresa = wempresa;
                       
                    IF vnomaxudis is null THEN
                        LET wfolio_suc = '0';
                        LET wcausa_dev = '01';
                        LET vrfc = ' ';
                        LET vnombre_cte = ' ';
                                
                        IF pchartipopago IN('19', '20', '21', '22') THEN
                            CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                                     intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
                            RETURNING wvchrcodretcodi;
                        END IF;
                        
                        INSERT INTO tblabono 
                        ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                          vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                          chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                          fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                        VALUES
                        ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                          pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                          pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                          pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                                
                        RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
                    END IF;
                    
                    -- // OBTIENE EL ACUMULADO DE LA CUENTA
                    SELECT monto_acum
                      INTO vmtoacumcta
                      FROM bdicheq:sc_acummesctanvl2
                     WHERE cuenta = wcuenta;
                     
                    IF vmtoacumcta is null THEN
                        LET vmtoacumcta = 0.00;
                    END IF;
                    
                    -- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
                    LET vmonto_udi = pmnyimporte / vprecio_udi;
                
                    -- // CONVIERTE ACUMULADO DE LA CUENTA EN UDIS
                    LET vmtopagosudi = vmtoacumcta / vprecio_udi;
                    
                    -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
                    LET vlim_cuenta = vmonto_udi + vmtopagosudi;
                    
                    -- // VALIDA QUE EL ACUMULADO DE LA CUENTA NO REBASE EL LIMITE PERMITIDO 
                    IF ( vlim_cuenta > vnomaxudis ) THEN
                        LET wfolio_suc = '0';
                        LET wcausa_dev = '01';
                        LET vrfc = ' ';
                        LET vnombre_cte = ' ';
                                
                        IF pchartipopago IN('19', '20', '21', '22') THEN
                            CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                                     intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
                            RETURNING wvchrcodretcodi;
                        END IF;
                        
                        INSERT INTO tblabono 
                        ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                          vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                          chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                          fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                        VALUES
                        ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                          pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                          pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                          pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                                
                        RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
                    END IF; 
                END IF;
            END IF;
        END IF;
    ELSE
        LET codretfirma = 0;
    END IF;
    
    -- // VALIDA QUE LA FIRMA SE HAYA GENERADO CORRECTAMENTE
	IF codretfirma = 0 THEN
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
					CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'o',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord,
                                             intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert)
					RETURNING wvchrcodretcodi;
				END IF;
                
                INSERT INTO tblabono 
                ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                  vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                  chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                  fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                VALUES
                ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                  pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                  pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                  pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );

				RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
			END IF;
		END IF;
		
		-- // Obtiene fechas del sistema de cheques
		SELECT ind_disponible, fecha_hoy
		  INTO vind_dispon, vfecha_hoy
		  FROM bdicheq:sc_fechas
		 WHERE empresa = wempresa;

		IF vind_dispon = '0' THEN
			LET wfolio_suc = '0';
			LET wcausa_dev = '16';
			LET vrfc = ' ';
			LET vnombre_cte = ' ';
					
			IF pchartipopago IN('19', '20', '21', '22') THEN
				CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi;
			END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
						
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;
        
        -- // VALIDA PARAMETROS DE ENTRADA
		IF ( ( pmnyimporte <= 0.00 ) OR ( pchrstatus is null OR pchrstatus = '' OR LENGTH(TRIM(pchrstatus)) <> 1 ) OR
			 ( LENGTH(TRIM(pvchrcuentabenef)) <> 16 AND LENGTH(TRIM(pvchrcuentabenef)) <> 18 AND LENGTH(TRIM(pvchrcuentabenef)) <> 10) ) THEN
			LET wfolio_suc = '0';
			LET wcausa_dev = '01';
			LET vrfc = ' ';
			LET vnombre_cte = ' ';
					
			IF pchartipopago IN('19', '20', '21', '22') THEN
				CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi;
			END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
					
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;
        
        -- // OBTIENE LA FECHA OPERACION DEL SPEI
		SELECT vchrvalor
		  INTO vfech_spei
		  FROM tblparametros
		 WHERE vchrcveparametro = 'FECHA_OPERACION';

		LET vfech_val = SUBSTR(vfech_spei,4,2)||'/'||SUBSTR(vfech_spei,1,2)||'/'||SUBSTR(vfech_spei,7,4);
        
        -- // VALIDA ESTATUS DE LA CUENTA
        IF wstatus_cta = '3' THEN
            SELECT COUNT(*)
              INTO iExiste
              FROM bdicheq:sc_ctabloqueo
             WHERE cuenta = wcuenta;
              
            IF iExiste > 0 THEN
                SELECT opcion::int
                  INTO wopcion
                  FROM bdicheq:sc_ctabloqueo
                 WHERE cuenta = wcuenta;
                 
                IF wopcion IN(2,4) THEN
                    LET wfolio_suc = '0';
                    LET wcausa_dev = '01';
                    LET vrfc = ' ';
                    LET vnombre_cte = ' ';

                    IF pchartipopago IN('19', '20', '21', '22') THEN
                        CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                                 intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
                        RETURNING wvchrcodretcodi;
                    END IF;
                    
                    INSERT INTO tblabono 
                    ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                      vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                      chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                      fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                    VALUES
                    ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                      pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                      pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                      pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                            
                    RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
                END IF;
            ELSE
                SELECT abono
                  INTO wabono
                  FROM bdicheq:sc_bloqueo
                 WHERE codigo = wmotivo;
                 
                IF wabono = 'N' THEN
                    LET wfolio_suc = '0';
                    LET wcausa_dev = '01';
                    LET vrfc = ' ';
                    LET vnombre_cte = ' ';

                    IF pchartipopago IN('19', '20', '21', '22') THEN
                        CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                                 intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
                        RETURNING wvchrcodretcodi;
                    END IF;
                    
                    INSERT INTO tblabono 
                    ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                      vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                      chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                      fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                    VALUES
                    ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                      pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                      pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                      pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                            
                    RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
                END IF;
            END IF;
        ELIF wstatus_cta IN('2','6','7','8') THEN
            LET wfolio_suc = '0';
            LET wcausa_dev = '01';
            LET vrfc = ' ';
            LET vnombre_cte = ' ';

            IF pchartipopago IN('19', '20', '21', '22') THEN
                CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
                RETURNING wvchrcodretcodi;
            END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                    
            RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
        END IF;
        
        -- // VALIDA EL NUMERO DE CLIENTE 
		IF wnumcte is null OR wnumcte = '' THEN
			LET wfolio_suc = '0';
			LET wcausa_dev = '01';
			LET vrfc = ' ';
			LET vnombre_cte = ' ';

			IF pchartipopago IN('19', '20', '21', '22') THEN
				CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi;
			END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
					
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;
        
        -- // OBTIENE DATOS DEL CLLIENTE
        SELECT trim(cte.rfc), trim(cte.nombre1)||' '||trim(cte.nombre2)||' '||trim(cte.apell_paterno)||' '||trim(cte.apell_materno)||' '||trim(cte.razon_social), tip.es_fisica
          INTO vrfc, vnombre_cte, ves_fisica
          FROM bdinteg:si_cliente cte,
               bdinteg:si_tipper tip
         WHERE cte.numcte = wnumcte
           AND tip.tpo_persona = cte.tpo_persona;
		   
    	LET vnombre_cte = REPLACE(vnombre_cte, 'Ñ', 'N');
		LET vnombre_cte = REPLACE(vnombre_cte, 'ñ', 'n');
		LET vnombre_cte = REPLACE(vnombre_cte, 'á', 'a');
		LET vnombre_cte = REPLACE(vnombre_cte, 'é', 'e');
		LET vnombre_cte = REPLACE(vnombre_cte, 'í', 'i');
		LET vnombre_cte = REPLACE(vnombre_cte, 'ó', 'o');
		LET vnombre_cte = REPLACE(vnombre_cte, 'ú', 'u');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Á', 'A');
		LET vnombre_cte = REPLACE(vnombre_cte, 'É', 'E');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Í', 'I');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ó', 'O');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ú', 'U');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ü', 'U');
		LET vnombre_cte = REPLACE(vnombre_cte, 'ý', 'X');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ý', 'X');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ã', 'A');	   
                
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
        
        -- // VALIDA QUE NO SE HAYA APLICADO LA OPERACION PREVIAMENTE
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
				CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi;
			END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
					
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
		END IF;
        
        -- // GENERA EL FOLIO
		CALL sp_obtfoliosuc(wusuario)
		RETURNING vcodret1, wserial_folio, wfolio_suc;

		IF vcodret1 <> '000' THEN
			LET wfolio_suc = 'SPEI'||vfech_val;
			LET wcausa_dev = '00';
            
			IF pchartipopago IN('19', '20', '21', '22') THEN
				CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi;
			END IF;
		END IF;
        
        -- // TRANSACCIONES CODI
        IF wtransacc = '0446' THEN
            -- // EJECUTA EL PROCESO PARA DEPOSITO EN CUENTAS DEL SISTEMA DE CHEQUES
            EXECUTE PROCEDURE bdicheq:abono_ref(wempresa, wsucursal, wusuario, wtransacc, wtran_suc, wfolio_suc, wcuenta, 0, pmnyimporte, pmnyimporte, 0, 0, 0, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ')
            INTO vcodret1;
            
            LET icodret = vcodret1::int;
            LET ivueltas = 1;
            
            WHILE icodret < 0 AND ivueltas <= 3
                --- SET LOCK MODE TO WAIT 2;
                
                EXECUTE PROCEDURE bdicheq:abono_ref(wempresa, wsucursal, wusuario, wtransacc, wtran_suc, wfolio_suc, wcuenta, 0, pmnyimporte, pmnyimporte, 0, 0, 0, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ')
                INTO vcodret1;

                LET icodret = vcodret1::int;
                LET ivueltas = ivueltas + 1;
            END WHILE;
            
            -- // SI SE GENERA EL ABONO, SE ENVIA LA NOTIFICACION POR EMAIL Y SMS
            IF vcodret1 = '000' THEN
                IF pchartipopago IN('19', '20', '21', '22') THEN
                    LET cVarDataErr = ' ';
                    CALL spei_recerrorescodi('0',cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                             intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
                    RETURNING wvchrcodretcodi;
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
                    CALL spei_recerrorescodi('16',cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                             intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
                    RETURNING wvchrcodretcodi;
                END IF;
                 
                RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
            END IF;
            
        -- // TRANSACCIONES SPEI
        ELSE
            -- // OBTIENE EL ESTATUS DE ACUERDO AL BANCO
            SELECT vchrorigen
              INTO wvchrorigen
              FROM tblbancoabono
             WHERE cvecesif = intBancoOrd;
            
            -- // INSERTA EN TBLABONO
            IF wvchrorigen is null OR wvchrorigen = '' OR wvchrorigen = ' ' THEN
                INSERT INTO tblabono 
                ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                  vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                  chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                  fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                VALUES
                ( 0, pmnyimporte, intBancoOrd, 'N', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                  pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                  pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                  pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
            ELSE
                /* #################################################################################
                IF intBancoOrd = '40012' THEN
                    LET wchrdigito = SUBSTR(pvchrclaverastreo, LENGTH(pvchrclaverastreo), 1);
                    
                    IF wchrdigito IN('1','2') THEN
                        LET wvchrorigen = 'G';
                    ELIF wchrdigito IN('3','4') THEN
                        LET wvchrorigen = 'H';
                    ELIF wchrdigito IN('5','6') THEN
                        LET wvchrorigen = 'I';
                    ELIF wchrdigito IN('7','8') THEN
                        LET wvchrorigen = 'J';
                    ELIF wchrdigito IN('9','0') THEN
                        LET wvchrorigen = 'K';
                    ELSE
                        LET wvchrorigen = wvchrorigen;
                    END IF;
                ELSE
                    LET wvchrorigen = wvchrorigen;
                END IF;
                ################################################################################# */
                
                LET wvchrorigen = wvchrorigen;
                
                INSERT INTO tblabono 
                ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                  vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                  chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                  fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                VALUES
                ( 0, pmnyimporte, intBancoOrd, wvchrorigen, pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                  pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                  pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                  pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
            END IF;              
        END IF;
	ELSE 
		LET wfolio_suc  = '0';
		LET wcausa_dev  = '16';
		LET vrfc        = '';
		LET vnombre_cte = '';
        
		--- INSERT INTO tblintfallo (vchrcuentaord, dtfech_hor, vchrcuentabenef) VALUES(pvchrcuentaord,CURRENT, pvchrcuentabenef);
        
		IF pchartipopago IN('19', '20', '21', '22') THEN
			CALL spei_recerrorescodi(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                     intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
			RETURNING wvchrcodretcodi;
		END IF;
        
        INSERT INTO tblabono 
        ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
          vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
          chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
          fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
        VALUES
        ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
          pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
          pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
          pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );

		RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;
	END IF;

    END;

	RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte;

END PROCEDURE
DOCUMENT
'Autor Modificacion: MARIO GONZALEZ VAZQUEZ',
'Fecha: 29/01/2026',
'Descripcion: Se comenta en llamado a validacion de la firma y se modifica la consulta insert a tblabono para agregar un nuevo campo que se asignara a la variable codretfirma que se le asignaria el resultado de la validacion',
'BD:BDISPEI';

CREATE PROCEDURE "informix".spei_recordenpago_ws( pvchrclaverastreo CHAR(30),       -- clave de rastreo
                                                  pvchrcuentabenef  CHAR(20),       -- numero de cuenta del beneficiario
                                                  pmnyimporte       DECIMAL(17,2),  -- importe de la operacion
                                                  pintrefnumerica   CHAR(7),        -- referencia numerica
                                                  pvchrconceptopago CHAR(210),      -- referencia del pago en ventanilla
                                                  pvchrrefcobranza  CHAR(40),       -- referencia cobranza
                                                  pchrstatus        CHAR(1), 		-- status
                                                  pvchrcuentaord    CHAR(20),       -- numero de cuenta del ordenante
                                                  pvchrtpoctaord    CHAR(2) ,		-- tipo de cuenta ordenante
                                                  pchartipopago     CHAR(2), 		-- tipo de pago (19,20,21,22) CODI
                                                  pcharfirma        CHAR(512),		-- firma a validar
                                                  pnumcelord        CHAR(10), 
                                                  pnumcelben        CHAR (20),
                                                  pdigidord         INTEGER,
                                                  pdigidben         INTEGER,
                                                  pfechalimpago     CHAR(16),
                                                  intBancoOrd       CHAR(5),
                                                  ppagocomision     INTEGER,
                                                  pcomision         DECIMAL(14,2),
                                                  pnumseriecert     CHAR(20),
                                                  pfolioplataforma  CHAR(20), 
                                                  pchridmjc         CHAR(20), 
                                                  pchrfchmjc        CHAR(20),
                                                  pvchrNombreOrd    CHAR(40),
                                                  pintTipoCtaBenef  CHAR(2),
                                                  pvchrNombreBenef  CHAR(40),
												  presfirm          INTEGER) --resultado validacion firma 0 correcta 1 incorrecta 29 01 2026
											   
RETURNING CHAR(30),         -- folio
          CHAR(2),          -- clave de devolucion
		  CHAR(18),         -- rfc
          CHAR(40),         -- nombre del cliente
          INTEGER,          -- num_serial_codi
          CHAR(2),          -- tipo_aviso_proc_codi
          CHAR(2),          -- codigo_codi
          CHAR(20),         -- identificador_mensaje_codi
          CHAR(20),         -- fecha_mensaje_cobro_codi
          CHAR(50),         -- concepto_pago_codi
          DECIMAL(12,2),    -- importe_pago_codi
          CHAR(23),         -- fecha_procesamiento_pago_codi
          CHAR(30),         -- clave_rastreo_codi
          CHAR(7),          -- referencia_numerica_codi
          CHAR(10),         -- alias_ordenante_codi
          CHAR(3),          -- digito_verificador_ordenante_codi
          CHAR(5),          -- banco_ordenante_codi
          CHAR(2),          -- tipo_cuenta_ordenante_codi
          CHAR(20),         -- cuenta_ordenante_codi
          CHAR(40),         -- nombre_ordenante_codi
          CHAR(20),         -- alias_beneficiario_codi
          CHAR(3),          -- digito_verificador_beneficiario_codi
          CHAR(5),          -- banco_beneficiario_codi
          CHAR(2),          -- tipo_cuenta_beneficiario_codi
          CHAR(20),         -- cuenta_beneficiario_codi
          CHAR(40);         -- nombre_beneficiario_codi
          
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
    
	-- // FIRMA
	DEFINE wcadena_val      CHAR (1000);
	DEFINE codretfirma      INTEGER;
	DEFINE wvchrcodretcodi  CHAR(5);
	DEFINE wimporte         DECIMAL(12,2);
	DEFINE cVarDataErr      CHAR(100);
	DEFINE vtimestamp       LVARCHAR(20);
	DEFINE wtimestamp       CHAR(20);
 -- DEFINE pvchrNombreOrd   CHAR (20);
	DEFINE pintBancoDest    CHAR(5);
 -- DEFINE pintTipoCtaBenef CHAR (2);
 -- DEFINE pvchrNombreBenef CHAR (20);
	DEFINE wcomision 		DECIMAL(14,2);
	DEFINE vcomision        CHAR(7);
	DEFINE vcomision2       CHAR(7);
	DEFINE vcomision3       CHAR(7);
    
    -- // ORION
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
    DEFINE vfecha_hoy           DATE;
    DEFINE wstatus_cta          CHAR(1);
    DEFINE wmotivo              CHAR(2);
    DEFINE iExiste              SMALLINT;
    DEFINE wopcion              INTEGER;
    DEFINE wabono               CHAR(1);
    
    DEFINE vnumserialcodi           INTEGER;
    DEFINE vtpoavisoproccodi        CHAR(2);
    DEFINE vcodigocodi              CHAR(2);
    DEFINE videntifmensajecodi      CHAR(20);
    DEFINE vfechamensajecobrocodi   CHAR(20);
    DEFINE vconceptopagocodi        CHAR(50);
    DEFINE vimportepagocodi         DECIMAL(12,2);
    DEFINE vfechaprocpagocodi       CHAR(23);
    DEFINE vcverastreocodi          CHAR(30);
    DEFINE vrefernumcodi            CHAR(7);
    DEFINE valiasordcodi            CHAR(10);
    DEFINE vdigitoverifordcodi      CHAR(3);
    DEFINE vbancoordcodi            CHAR(5);
    DEFINE vtpoctaordcodi           CHAR(2);
    DEFINE vctaordcodi              CHAR(20);
    DEFINE vnombreordcodi           CHAR(40);
    DEFINE valiasbenefcodi          CHAR(20);
    DEFINE vdigitoverifbenefcodi    CHAR(3);
    DEFINE vbancobenefcodi          CHAR(5);
    DEFINE vtpoctabenefcodi         CHAR(2);
    DEFINE vctabenefcodi            CHAR(20);
    DEFINE vnombrebenefcodi         CHAR(40);
    
    DEFINE wvchrorigen          CHAR(1);
    DEFINE wchrdigito           CHAR(1);
    
    DEFINE vproducto            CHAR(4);
    DEFINE vExisLimProd         SMALLINT;
    DEFINE vTrxExentaLimProd    SMALLINT;
    DEFINE vhoramax             DATETIME HOUR TO MINUTE;
    DEFINE vprecio_udi          DECIMAL(14,6);
    DEFINE vfecha_tpcambio      DATE;
    DEFINE vnomaxudis           INTEGER;
    DEFINE vmtoacumcta          DECIMAL(18,6);
    DEFINE vmonto_udi           DECIMAL(18,6);
    DEFINE vmtopagosudi         DECIMAL(18,6);
    DEFINE vlim_cuenta          DECIMAL(18,6);
	
	DEFINE iTransaccion INTEGER;
	
	
	DEFINE vInicioDigitos_CreditoHip CHAR(7);
	DEFINE vNumClabeConcentradora_creditoHip CHAR(18);
	DEFINE vNumCtaDestino_inicioDigitos CHAR(7);
	DEFINE vNumCuentaDestino_creditoHip  CHAR(18);
	
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
 -- LET pvchrNombreOrd = ' ';
	LET pintBancoDest = '40137';
	LET vcomision2    = '0.00';
	LET vcomision3    = '0';
 -- LET pintTipoCtaBenef = ' ';
 -- LET pvchrNombreBenef = ' ';
    
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
    LET vsufijo = '';
    LET vfecha_hoy = '';
    LET wstatus_cta = '';
    LET wmotivo = '';
    LET iExiste = 0;
    LET wopcion = 0;
    LET wabono = '';
    LET vfech_val = '';
    
    LET vnumserialcodi         = 0;
    LET vtpoavisoproccodi      = '';
    LET vcodigocodi            = '';
    LET videntifmensajecodi    = '';
    LET vfechamensajecobrocodi = '';
    LET vconceptopagocodi      = '';
    LET vimportepagocodi       = 0.00;
    LET vfechaprocpagocodi     = '';
    LET vcverastreocodi        = '';
    LET vrefernumcodi          = '';
    LET valiasordcodi          = '';
    LET vdigitoverifordcodi    = '';
    LET vbancoordcodi          = '';
    LET vtpoctaordcodi         = '';
    LET vctaordcodi            = '';
    LET vnombreordcodi         = '';
    LET valiasbenefcodi        = '';
    LET vdigitoverifbenefcodi  = '';
    LET vbancobenefcodi        = '';
    LET vtpoctabenefcodi       = '';
    LET vctabenefcodi          = '';
    LET vnombrebenefcodi       = '';
    
    LET wvchrorigen = '';
    LET wchrdigito  = '';
    
    LET vproducto         = '';
    LET vExisLimProd      = 0;
    LET vTrxExentaLimProd = 0;
    LET vhoramax          = '';
    LET vprecio_udi       = 0.00; 
    LET vfecha_tpcambio   = '';
    LET vnomaxudis        = 0;
    LET vmtoacumcta       = 0.00;
    LET vmonto_udi        = 0.00;
    LET vmtopagosudi      = 0.00;
    LET vlim_cuenta       = 0.00;
	
    
    LET vInicioDigitos_CreditoHip = '';
	LET vNumClabeConcentradora_creditoHip = '';
	LET vNumCtaDestino_inicioDigitos = '';
	LET vNumCuentaDestino_creditoHip  = '';
	
	LET iTransaccion = 0;

     --SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_recordenpago_ws.out";
     --TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
       SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_recordenpago_ws.err";
       TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1    = vSqlErr;
            LET vCodRet2    = vIsamErr;
            LET vCodRet3    = vDescErr;
			LET wfolio_suc  = '0';
			LET vrfc        = ' ';
            LET vnombre_cte = ' ';
			LET wcausa_dev = '16';
			IF (iTransaccion = 1) THEN
				BEGIN WORK;
			END IF;			
            RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                   vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                   vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                   vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
        END IF;
    END EXCEPTION;

	ON EXCEPTION IN (-535)
        LET iTransaccion = 1;
        --- COMMIT WORK;
        --- BEGIN WORK;
	END EXCEPTION WITH RESUME;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
	COMMIT WORK;
    
    -- // DETERMINA LA COMISION
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
    
    -- // DETERMINA LA TRANSACCION A UTILIZAR
    IF pchrstatus = 'L' THEN 
        IF pchartipopago NOT IN('19', '20', '21', '22') THEN --- Evaluar si es un CODI
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
            CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                     intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
            RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                      vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                      vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
        END IF;
        
        INSERT INTO tblabono 
        ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
          vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
          chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
          fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
        VALUES
        ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
          pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
          pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
          pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                
        IF (iTransaccion = 1) THEN
            BEGIN WORK;
        END IF;
                
        RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
               vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
               vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
               vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
    END IF;
    
    -- // VALIDA EL TIPO DE CUENTA
    IF LENGTH(TRIM(pvchrcuentabenef)) = 11 THEN
        LET wcuenta = pvchrcuentabenef;

        SELECT NVL(cuenta, ' '), NVL(num_cte, ' ')
          INTO vcuenta, wnumcte
          FROM bdicheq:sc_maechq
         WHERE cuenta = wcuenta
           AND status_cta in('1', '3', '4', '5');
    ELIF LENGTH(TRIM(pvchrcuentabenef)) = 16 THEN
        LET wtpoctabenefmsg = 'TARJETA DE DEBITO';
        LET wcuentabenefemail = 'XXXX XXXX XXXX ' || substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);
        
        SELECT NVL(cuenta, ' '), NVL(numcte, ' ')
              INTO vcuenta, wnumcte
              FROM bdicheq:sc_tarjeta
             WHERE num_tarjeta = pvchrcuentabenef;

        LET wnum_tarjeta = pvchrcuentabenef;
        LET wcuenta = vcuenta;
    ELIF LENGTH(TRIM(pvchrcuentabenef)) = 18 THEN
        LET wtpo_prod = SUBSTR(pvchrcuentabenef, 4, 3);

        SELECT {+AVOID_FULL (bdicred:sd_cat_prod_finac)} COUNT(*)
          INTO wes_credito
          FROM bdicred:sd_cat_prod_finac
         WHERE codigo_prod = wtpo_prod;
         
        --Buscar los primeros 7 digitos de las cuentas de credito hipotecario por usuario
        LET vInicioDigitos_CreditoHip = (select trim(valor) from bdicheq:sc_param where codparam = 'cuentaclbcredhip');
        
        IF vInicioDigitos_CreditoHip IS NOT NULL AND vInicioDigitos_CreditoHip != '' THEN
        
            LET vNumCtaDestino_inicioDigitos = substr(pvchrcuentabenef,0,7);
            
            IF vInicioDigitos_CreditoHip = vNumCtaDestino_inicioDigitos THEN
                LET wes_credito = 0;
            END IF;
        END IF;
                 
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
                EXECUTE PROCEDURE bdicred:sp_valida_spei_cred(pvchrclaverastreo,pvchrcuentabenef, pmnyimporte)
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
                END IF;
                        
                LET vnombre_cte = '|'||vnombre_cte;
            ELSE                            
                LET wfolio_suc = '0';
                LET wcausa_dev = '16';
                LET vrfc = ' ';
                LET vnombre_cte = ' ';
            END IF;
                
            IF (iTransaccion = 1) THEN
                BEGIN WORK;
            END IF;
                
            RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                   vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                   vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                   vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
        ELSE
            LET wtpoctabenefmsg = 'CUENTA CLABE';
            LET wcuentabenefemail = 'XXXX XXXX XXXX XX' || substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);
               
            LET wcuenta = SUBSTR(pvchrcuentabenef, 7, 11);
			
            ---- Validacion para reconocer las cuentas de credito hipotecario            
            IF vInicioDigitos_CreditoHip = vNumCtaDestino_inicioDigitos THEN
                   
				LET vNumCuentaDestino_creditoHip = pvchrcuentabenef;
				
				LET wcuenta = (select valor from bdicheq:sc_param where codparam = 'cuentaconccredhip');
				
				IF wcuenta IS NOT NULL AND wcuenta != '' THEN   
					
					LET wcuenta = wcuenta;

				END IF;
            END IF;

            SELECT NVL(cuenta, ' '), NVL(num_cte, ' ')
              INTO vcuenta, wnumcte
              FROM bdicheq:sc_maechq
             WHERE cuenta = wcuenta
               AND status_cta in('1', '3', '4', '5');

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
        LET wcuenta = vcuenta;
    END IF;
    
    -- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
    SELECT status_cta, motivo, producto
      INTO wstatus_cta, wmotivo, vproducto
      FROM bdicheq:sc_maechq
     WHERE cuenta = wcuenta;
	
    -- // VALIDA FIRMA PARA TRANSACCIONES CODI Y CUENTAS N2
    IF ( wtransacc = '0446' OR vproducto = '2900' ) THEN

/* -- SE COMENTA LA VALIDACION DE FIRMA 29 01 2026
        -- // GENERA CADENA A VALIDAR
        LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
                          '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
                          '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
                          '|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pintTipoCtaBenef)||'|'||TRIM(pvchrNombreBenef)||'|';
          
        EXECUTE FUNCTION "informix".syn_verify2(TRIM(wcadena_val), TRIM(pcharfirma), 21)
        INTO codretfirma;

        IF codretfirma <> 0 THEN
            LET wcadena_val = '';
            LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
                '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
                '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
                '|'||pvchrNombreOrd||'|'||TRIM(pintTipoCtaBenef)||'|'||pvchrNombreBenef||'|';
          
            EXECUTE FUNCTION "informix".syn_verify2(TRIM(wcadena_val), TRIM(pcharfirma), 21)
            INTO codretfirma;
        END IF;
        
        IF codretfirma <> 0 THEN
            LET wcadena_val = '';
            LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
                  '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
                  '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision2)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
                  '|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pintTipoCtaBenef)||'|'||TRIM(pvchrNombreBenef)||'|';

          
            EXECUTE FUNCTION "informix".syn_verify2(TRIM(wcadena_val), TRIM(pcharfirma), 21)
            INTO codretfirma;
        END IF;

        IF codretfirma <> 0 THEN
            LET wcadena_val = '';
            LET wcadena_val = '|'||TRIM(pvchrclaverastreo)||'|'||TRIM(pvchrcuentabenef)||'|'||pmnyimporte||'|'||TRIM(pintrefnumerica)||'|'||TRIM(pvchrconceptopago)||'|'||TRIM(pvchrrefcobranza)||'|'||TRIM(pchrstatus)||
                  '|'||TRIM(pvchrcuentaord)||'|'||TRIM(pvchrtpoctaord)||'|'||TRIM(pchartipopago)||'|'||TRIM(pnumcelord)||'|'||TRIM(pnumcelben)||'|'||pdigidord||'|'||pdigidben||'|'||TRIM(pfechalimpago)||
                  '|'||TRIM(intBancoOrd)||'|'||ppagocomision||'|'||TRIM(vcomision3)||'|'||TRIM(pnumseriecert)||'|'||TRIM(pfolioplataforma)||'|'||trim(pchridmjc)||'|'||trim(pchrfchmjc)||
                  '|'||TRIM(pvchrNombreOrd)||'|'||TRIM(pintTipoCtaBenef)||'|'||TRIM(pvchrNombreBenef)||'|';

          
            EXECUTE FUNCTION "informix".syn_verify2(TRIM(wcadena_val), TRIM(pcharfirma), 21)
            INTO codretfirma;
        END IF;	
*/ -- SE COMENTA LA VALIDACION DE FIRMA 29 01 2026

LET codretfirma = presfirm;

    ELSE
        LET codretfirma = 0;
    
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'Ñ', 'N');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'ñ', 'n');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'á', 'a');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'é', 'e');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'í', 'i');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'ó', 'o');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'ú', 'u');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'Á', 'A');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'É', 'E');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'Í', 'I');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'Ó', 'O');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'Ú', 'U');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'Ü', 'U');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'ý', 'X');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'Ý', 'X');
        LET pvchrconceptopago = REPLACE(pvchrconceptopago, 'Ã', 'A');
    
    END IF;
	
    --- LET codretfirma = 0;
    
	-- // Valida si el tipo de pago es no presencial o punto a punto
	IF pchartipopago IN('20', '21', '22') THEN
	   LET pnumcelben = pnumseriecert;
	END IF;
    
    -- // VALIDA QUE LA FIRMA SE HAYA GENERADO CORRECTAMENTE
	IF codretfirma = 0 THEN
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
					CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'o',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord,
                                             intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert)
					RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
							  vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
							  vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
				END IF;
                
                INSERT INTO tblabono 
                ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                  vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                  chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                  fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
 
				  VALUES
                ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                  pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                  pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                  pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );

				IF (iTransaccion = 1) THEN
					BEGIN WORK;
				END IF;

				RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                       vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                       vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                       vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
			END IF;
		END IF;
		
		-- // Obtiene fechas del sistema de cheques
		SELECT ind_disponible, fecha_hoy
		  INTO vind_dispon, vfecha_hoy
		  FROM bdicheq:sc_fechas
		 WHERE empresa = wempresa;

		IF vind_dispon = '0' THEN
			LET wfolio_suc = '0';
			LET wcausa_dev = '16';
			LET vrfc = ' ';
			LET vnombre_cte = ' ';
					
			IF pchartipopago IN('19', '20', '21', '22') THEN
				CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                          vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                          vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
			END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );

			IF (iTransaccion = 1) THEN
				BEGIN WORK;
			END IF;
						
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                   vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                   vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                   vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
		END IF;
        
        -- // VALIDA PARAMETROS DE ENTRADA
		IF ( ( pmnyimporte <= 0.00 ) OR ( pchrstatus is null OR pchrstatus = '' OR LENGTH(TRIM(pchrstatus)) <> 1 ) OR
			 ( LENGTH(TRIM(pvchrcuentabenef)) <> 16 AND LENGTH(TRIM(pvchrcuentabenef)) <> 18 AND LENGTH(TRIM(pvchrcuentabenef)) <> 10) ) THEN
			LET wfolio_suc = '0';
			LET wcausa_dev = '01';
			LET vrfc = ' ';
			LET vnombre_cte = ' ';
					
			IF pchartipopago IN('19', '20', '21', '22') THEN
				CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                          vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                          vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
			END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );

			IF (iTransaccion = 1) THEN
				BEGIN WORK;
			END IF;
					
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                   vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                   vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                   vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
		END IF;
        
        -- // OBTIENE LA FECHA OPERACION DEL SPEI
		SELECT vchrvalor
		  INTO vfech_spei
		  FROM tblparametros
		 WHERE vchrcveparametro = 'FECHA_OPERACION';

		LET vfech_val = SUBSTR(vfech_spei,4,2)||'/'||SUBSTR(vfech_spei,1,2)||'/'||SUBSTR(vfech_spei,7,4);
        
        -- // VALIDA SI LA CUENTA ESTA BLOQUEADA PARA ABONOS
        IF wstatus_cta = '3' THEN
            SELECT COUNT(*)
              INTO iExiste
              FROM bdicheq:sc_ctabloqueo
             WHERE cuenta = wcuenta;
              
            IF iExiste > 0 THEN
                SELECT opcion::int
                  INTO wopcion
                  FROM bdicheq:sc_ctabloqueo
                 WHERE cuenta = wcuenta;
                 
                IF wopcion IN(2,4) THEN
                    LET wfolio_suc = '0';
                    LET wcausa_dev = '01';
                    LET vrfc = ' ';
                    LET vnombre_cte = ' ';

                    IF pchartipopago IN('19', '20', '21', '22') THEN
                        CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                                 intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
						RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
								  vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
								  vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
                    END IF;
                    
                    INSERT INTO tblabono 
                    ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                      vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                      chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                      fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                    VALUES
                    ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                      pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                      pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                      pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                            
					IF (iTransaccion = 1) THEN
						BEGIN WORK;
					END IF;
							
                    RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                           vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                           vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                           vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
                END IF;
            ELSE
                SELECT abono
                  INTO wabono
                  FROM bdicheq:sc_bloqueo
                 WHERE codigo = wmotivo;
                 
                IF wabono = 'N' THEN
                    LET wfolio_suc = '0';
                    LET wcausa_dev = '01';
                    LET vrfc = ' ';
                    LET vnombre_cte = ' ';

                    IF pchartipopago IN('19', '20', '21', '22') THEN
                        CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                                 intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
						RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
								  vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
								  vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
                    END IF;
                    
                    INSERT INTO tblabono 
                    ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                      vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                      chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                      fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                    VALUES
                    ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                      pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                      pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                      pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                            
					IF (iTransaccion = 1) THEN
						BEGIN WORK;
					END IF;
							
                    RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                           vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                           vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                           vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
                END IF;
            END IF;
        ELIF wstatus_cta IN('2','6','7','8') THEN
            LET wfolio_suc = '0';
            LET wcausa_dev = '01';
            LET vrfc = ' ';
            LET vnombre_cte = ' ';

            IF pchartipopago IN('19', '20', '21', '22') THEN
                CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                          vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                          vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
           END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );

			IF (iTransaccion = 1) THEN
				BEGIN WORK;
			END IF;

            RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                   vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                   vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                   vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
        END IF;
        
        -- // VALIDA EL NUMERO DE CLIENTE 
		IF wnumcte is null OR wnumcte = '' THEN
			LET wfolio_suc = '0';
			LET wcausa_dev = '01';
			LET vrfc = ' ';
			LET vnombre_cte = ' ';

			IF pchartipopago IN('19', '20', '21', '22') THEN
				CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                          vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                          vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
			END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );

			IF (iTransaccion = 1) THEN
				BEGIN WORK;
			END IF;
				
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                   vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                   vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                   vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
		END IF;
        
        -- // OBTIENE DATOS DEL CLLIENTE
        SELECT TRIM(cte.rfc), TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)||' '||TRIM(cte.razon_social), tip.es_fisica
          INTO vrfc, vnombre_cte, ves_fisica
          FROM bdinteg:si_cliente cte,
               bdinteg:si_tipper tip
         WHERE cte.numcte = wnumcte
           AND tip.tpo_persona = cte.tpo_persona;
		
    	LET vnombre_cte = REPLACE(vnombre_cte, 'Ñ', 'N');
		LET vnombre_cte = REPLACE(vnombre_cte, 'ñ', 'n');
		LET vnombre_cte = REPLACE(vnombre_cte, 'á', 'a');
		LET vnombre_cte = REPLACE(vnombre_cte, 'é', 'e');
		LET vnombre_cte = REPLACE(vnombre_cte, 'í', 'i');
		LET vnombre_cte = REPLACE(vnombre_cte, 'ó', 'o');
		LET vnombre_cte = REPLACE(vnombre_cte, 'ú', 'u');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Á', 'A');
		LET vnombre_cte = REPLACE(vnombre_cte, 'É', 'E');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Í', 'I');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ó', 'O');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ú', 'U');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ü', 'U');
		LET vnombre_cte = REPLACE(vnombre_cte, 'ý', 'X');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ý', 'X');
		LET vnombre_cte = REPLACE(vnombre_cte, 'Ã', 'A');
   
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
        
        -- // VALIDA QUE NO SE HAYA APLICADO LA OPERACION PREVIAMENTE
        SELECT COUNT(*)
		  INTO wexiste_mov
		  FROM bdicheq:sc_movdia
		 WHERE transacc in('0273','0276','0277','0446')
		   AND fech_val = vfech_val
           AND cancelad <> 'S'
           AND referencia = pvchrclaverastreo
           AND cuenta = wcuenta;

		IF ( wexiste_mov > 0 ) THEN
			LET wcausa_dev = '00';
            
			IF pchartipopago IN('19', '20', '21', '22') THEN
			    LET cVarDataErr = ' ';
				CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                          vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                          vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
			END IF;
            
            INSERT INTO tblabono 
            ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
              vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
              chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
              fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
            VALUES
            ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
              pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
              pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
              pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
              
			IF (iTransaccion = 1) THEN
				BEGIN WORK;
			END IF;
			  
			RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                   vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                   vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                   vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
		END IF;
        
        -- // VALIDA LIMITES PARA CUENTAS NIVEL 2
		IF vproducto = '2900' THEN
			SELECT COUNT(*)
			  INTO vExisLimProd
			  FROM bdicheq:sc_limites_producto
			 WHERE producto = vproducto;
			 
			IF vExisLimProd > 0 THEN
				SELECT COUNT(*)
				  INTO vTrxExentaLimProd
				  FROM bdicheq:sc_transacc_exentas_limprod
				 WHERE transacc = wtransacc;
				 
				IF vTrxExentaLimProd = 0 THEN
					-- // OBTIENE EL VALOR DE LA UDI
					SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
						   FIRST 1 MAX(hora_tpcambio) 
					  INTO vhoramax
					  FROM bdinteg:si_tpcambio 
					 WHERE empresa = wempresa 
					   AND divisa = '09'
					   AND fecha_tpcambio = vfecha_hoy;
					
					IF vhoramax is null OR vhoramax = '' THEN
						SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
							   FIRST 1 precio_venta
						  INTO vprecio_udi
						  FROM bdinteg:si_tpcambio
						 WHERE empresa = wempresa
						   AND divisa = '09'
						   AND fecha_tpcambio = vfecha_hoy;
					ELSE
						SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
							   FIRST 1 precio_venta
						  INTO vprecio_udi
						  FROM bdinteg:si_tpcambio
						 WHERE empresa = wempresa
						   AND divisa = '09'
						   AND fecha_tpcambio = vfecha_hoy
						   AND hora_tpcambio = vhoramax;
					END IF;
				   
					IF vprecio_udi is null OR vprecio_udi = '' THEN
						SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
							   FIRST 1 MAX(fecha_tpcambio) 
						  INTO vfecha_tpcambio
						  FROM bdinteg:si_tpcambio
						 WHERE empresa = wempresa 
						   AND divisa = '09'
						   AND fecha_tpcambio <= vfecha_hoy;
					   
						SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
							   FIRST 1 MAX(hora_tpcambio) 
						  INTO vhoramax
						  FROM bdinteg:si_tpcambio 
						 WHERE empresa = wempresa 
						   AND divisa = '09'
						   AND fecha_tpcambio = vfecha_tpcambio;
						
						IF vhoramax is null OR vhoramax = '' THEN
							SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
								   FIRST 1 precio_venta
							  INTO vprecio_udi
							  FROM bdinteg:si_tpcambio
							 WHERE empresa = wempresa
							   AND divisa = '09'
							   AND fecha_tpcambio = vfecha_tpcambio;
						ELSE
							SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
								   FIRST 1 precio_venta
							  INTO vprecio_udi
							  FROM bdinteg:si_tpcambio
							 WHERE empresa = wempresa
							   AND divisa = '09'
							   AND fecha_tpcambio = vfecha_tpcambio
							   AND hora_tpcambio = vhoramax;
						END IF;
					END IF;
					
					-- // OBTIENE EL VALOR MAXIMO DE UDIS 
					SELECT valor::int
					  INTO vnomaxudis
					  FROM bdicheq:sc_param
					 WHERE codparam = "UdisMaxDepCtaNvl2"
					   AND empresa = wempresa;
					   
					IF vnomaxudis is null THEN
						LET wfolio_suc = '0';
                        LET wcausa_dev = '01';
                                
                        IF pchartipopago IN('19', '20', '21', '22') THEN
                            CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                                     intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
                            RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                                      vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                                      vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
                        END IF;
                        
                        INSERT INTO tblabono 
                        ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                          vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                          chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                          fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                        VALUES
                        ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                          pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                          pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                          pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );

						IF (iTransaccion = 1) THEN
							BEGIN WORK;
						END IF;
                                
                        RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                               vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                               vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                               vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
					END IF;
					
					-- // OBTIENE EL ACUMULADO DE LA CUENTA
					SELECT monto_acum
					  INTO vmtoacumcta
					  FROM bdicheq:sc_acummesctanvl2
					 WHERE cuenta = wcuenta;
					 
					IF vmtoacumcta is null THEN
						LET vmtoacumcta = 0.00;
					END IF;
					
					-- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
					LET vmonto_udi = pmnyimporte / vprecio_udi;
				
					-- // CONVIERTE ACUMULADO DE LA CUENTA EN UDIS
					LET vmtopagosudi = vmtoacumcta / vprecio_udi;
					
					-- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
					LET vlim_cuenta = vmonto_udi + vmtopagosudi;
					
					-- // VALIDA QUE EL ACUMULADO DE LA CUENTA NO REBASE EL LIMITE PERMITIDO 
					IF ( vlim_cuenta > vnomaxudis ) THEN
						LET wfolio_suc = '0';
                        LET wcausa_dev = '21';
                                
                        IF pchartipopago IN('19', '20', '21', '22') THEN
                            CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                                     intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
                            RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                                      vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                                      vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
                        END IF;
                        
                        INSERT INTO tblabono 
                        ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                          vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                          chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                          fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                        VALUES
                        ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                          pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                          pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                          pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
                                
						IF (iTransaccion = 1) THEN
							BEGIN WORK;
						END IF;
								
                        RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                               vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                               vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                               vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
					END IF; 
				END IF;
			END IF;
		END IF;
        
        -- // GENERA EL FOLIO
		CALL sp_obtfoliosuc(wusuario)
		RETURNING vcodret1, wserial_folio, wfolio_suc;

		IF vcodret1 <> '000' THEN
			LET wfolio_suc = 'SPEI'||vfech_val;
			LET wcausa_dev = '00';
            
			IF pchartipopago IN('19', '20', '21', '22') THEN
				CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                         intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
				RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                          vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                          vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
			END IF;
		END IF;
        
        -- // APLICA EL ABONO PARA TRANSACCIONES CODI Y CUENTAS N2
        IF ( wtransacc = '0446' OR vproducto = '2900' ) THEN
            -- // EJECUTA EL PROCESO PARA DEPOSITO EN CUENTAS DEL SISTEMA DE CHEQUES
            EXECUTE PROCEDURE bdicheq:abono_ref(wempresa, wsucursal, wusuario, wtransacc, wtran_suc, wfolio_suc, wcuenta, 0, pmnyimporte, pmnyimporte, 0, 0, 0, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ')
            INTO vcodret1;
            
            LET icodret = vcodret1::int;
            LET ivueltas = 1;
            
            WHILE icodret < 0 AND ivueltas <= 3
                EXECUTE PROCEDURE bdicheq:abono_ref(wempresa, wsucursal, wusuario, wtransacc, wtran_suc, wfolio_suc, wcuenta, 0, pmnyimporte, pmnyimporte, 0, 0, 0, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ')
                INTO vcodret1;

                LET icodret = vcodret1::int;
                LET ivueltas = ivueltas + 1;
            END WHILE;
            
            -- // SI SE GENERA EL ABONO, SE ENVIA LA NOTIFICACION POR EMAIL Y SMS
            IF vcodret1 = '000' THEN
                IF pchartipopago IN('19', '20', '21', '22') THEN
                    LET cVarDataErr = ' ';
                    
                    CALL spei_recerrorescodi_ws('0',cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                             intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
					RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
							  vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
							  vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
                END IF;
                
                LET wcuentabenefmsg = substr(pvchrcuentabenef,(length(pvchrcuentabenef)-3),4);

                -- // EMAIL
                /*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                ('1', 'SPEI_TRREC','SPEI_TRREC',wnumcte,'','','1','',wcuentabenefemail, pmnyimporte, pvchrclaverastreo,wtpoctabenefmsg,'','','','','','','',1,0,0,0,0,current,'')
                INTO vcodret1;*/
				
				-- // EMAIL // SMS
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                ('1', 'SPEI_TRREC','SPEI_TRREC',wnumcte,'','','1',wcuentabenefmsg,wcuentabenefemail, pmnyimporte, pvchrclaverastreo,wtpoctabenefmsg,'','','','','','','',1,0,0,0,0,current,'')
                INTO vcodret1;

                -- // SMS
                /*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                ('2', 'SPEI_SMREC','SPEI_SMREC',wnumcte,'','','1',wcuentabenefmsg,pmnyimporte,'','','','','','','','','','',1,0,0,0,0,current,'')
                INTO vcodret1;*/
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
                    CALL spei_recerrorescodi_ws('16',cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                             intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
					RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
							  vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
							  vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
                END IF;

				IF (iTransaccion = 1) THEN
					BEGIN WORK;
				END IF;
                 
                RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
                       vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                       vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                       vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
            END IF;
            
        -- // TRANSACCIONES SPEI DISTINTAS A CODI Y CUENTAS DISTINTAS A N2
        ELSE
            -- // OBTIENE EL ESTATUS DE ACUERDO AL BANCO
            SELECT vchrorigen
              INTO wvchrorigen
              FROM tblbancoabono
             WHERE cvecesif = intBancoOrd::int;

            IF vNumCuentaDestino_creditoHip = pvchrcuentabenef THEN

                INSERT INTO bdicheq:sc_creditohipotecario (clabe_concentradora,clabe_referencia,monto,fecha,folio_suc,cveRastreo,status_envio)
                    VALUES (wcuenta,vNumCuentaDestino_creditoHip,pmnyimporte,vfecha_hoy,wfolio_suc,pvchrclaverastreo,'N');
            
            END IF;
            
            
            -- // INSERTA EN TBLABONO
            --- IF intBancoOrd <> '40012' THEN
            IF ( wvchrorigen is null OR wvchrorigen = '' OR wvchrorigen = ' ' ) THEN
                INSERT INTO tblabono 
                ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                  vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                  chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                  fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                VALUES
                ( 0, pmnyimporte, intBancoOrd, 'N', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                  pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                  pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                  pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
            ELSE
                /* #################################################################################
                IF intBancoOrd = '40012' THEN
                    LET wchrdigito = SUBSTR(pvchrclaverastreo, LENGTH(pvchrclaverastreo), 1);
                    
                    IF wchrdigito IN('1','2') THEN
                        LET wvchrorigen = 'G';
                    ELIF wchrdigito IN('3','4') THEN
                        LET wvchrorigen = 'H';
                    ELIF wchrdigito IN('5','6') THEN
                        LET wvchrorigen = 'I';
                    ELIF wchrdigito IN('7','8') THEN
                        LET wvchrorigen = 'J';
                    ELIF wchrdigito IN('9','0') THEN
                        LET wvchrorigen = 'K';
                    ELSE
                        LET wvchrorigen = wvchrorigen;
                    END IF;
                ELSE
                    LET wvchrorigen = wvchrorigen;
                END IF;
                ################################################################################# */
                
                LET wvchrorigen = wvchrorigen;
                --- LET wvchrorigen = 'G';
                
                INSERT INTO tblabono 
                ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
                  vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                  chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                  fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
                VALUES
                ( 0, pmnyimporte, intBancoOrd, wvchrorigen, pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
                  pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
                  pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
                  pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );
            END IF; 
        END IF;
	ELSE 
		LET wfolio_suc  = '0';
		LET wcausa_dev  = '16';
		LET vrfc        = '';
		LET vnombre_cte = '';
        
		--- INSERT INTO tblintfallo (vchrcuentaord, dtfech_hor, vchrcuentabenef) VALUES(pvchrcuentaord,CURRENT, pvchrcuentabenef);
        
		IF pchartipopago IN('19', '20', '21', '22') THEN
			CALL spei_recerrorescodi_ws(wcausa_dev,cVarDataErr,'b',pchridmjc,pchrfchmjc,pvchrConceptoPago,wimporte,wtimestamp,pvchrclaverastreo,pintrefnumerica,pnumcelord,pdigidord, 
                                     intBancoOrd,pvchrtpoctaord,pvchrCuentaOrd,pvchrNombreOrd,pnumcelben,pdigidben,pintBancoDest,pintTipoCtaBenef,pvchrcuentabenef,pvchrNombreBenef,pnumseriecert) 
			RETURNING wvchrcodretcodi, vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
                      vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
                      vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
		END IF;
        
        INSERT INTO tblabono 
        ( intnumserial, mnyimporte, cvecesifbcoord, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, intrefnumerica, 
          vchrrefcobranza, vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, vchrcuentachq, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
          chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
          fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, resfirm )
        VALUES
        ( 0, pmnyimporte, intBancoOrd, 'D', pvchrNombreOrd, pvchrCuentaOrd, vrfc, pvchrtpoctaord, pvchrNombreBenef, pintTipoCtaBenef, pvchrcuentabenef, pintrefnumerica, 
          pvchrrefcobranza, pvchrconceptopago, vfech_val, vfecha_hoy, pvchrclaverastreo, wcuenta, wnumcte, wcuentabenefemail, wtpoctabenefmsg, wtransacc, wfolio_suc,
          pchartipopago, pchridmjc, pchrfchmjc, pnumcelord, pdigidord, pnumcelben, pdigidben, pnumseriecert,
          pfechalimpago, ppagocomision, vcomision, pfolioplataforma, pcharfirma, presfirm );

		IF (iTransaccion = 1) THEN
			BEGIN WORK;
		END IF;

		RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
               vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
               vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
               vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
	END IF;

    END;

	IF (iTransaccion = 1) THEN
		BEGIN WORK;
	END IF;
  
	RETURN wfolio_suc, wcausa_dev, vrfc, vnombre_cte,
           vnumserialcodi, vtpoavisoproccodi, vcodigocodi, videntifmensajecodi, vfechamensajecobrocodi, vconceptopagocodi, vimportepagocodi, 
           vfechaprocpagocodi, vcverastreocodi, vrefernumcodi, valiasordcodi, vdigitoverifordcodi, vbancoordcodi, vtpoctaordcodi, vctaordcodi,
           vnombreordcodi, valiasbenefcodi, vdigitoverifbenefcodi, vbancobenefcodi, vtpoctabenefcodi, vctabenefcodi, vnombrebenefcodi;
		   
END PROCEDURE
DOCUMENT
'Folio: N/A',
'Autor: 90435114',
'Fecha: 24/09/2025',
'DescripciÃ³n: Se modifica el SP para validar la recepciÃ³n de dinero de cuentas de credito hipotecario',
'se validan por el numero de cuenta clabe que es a 18 digitos y',
'las cuentas inician con estos primeros 7 digitos 1379734',
'Sustento: DEF - Operaciones Hipotecario 2025 .docx',
'Solicita: Marcela Ozuna Reynosa',
'Autor Modificacion: MARIO GONZALEZ VAZQUEZ',
'Fecha: 29/01/2026',
'Descripcion: Se comenta en llamado a validacion de la firma y se modifica la consulta insert a tblabono para agregar un nuevo campo que se asignara a la variable codretfirma que se le asignaria el resultado de la validacion',
'BD:BDISPEI';

CREATE PROCEDURE "informix".spei_upd_status_firma_envio(presfirm INTEGER, pvchrclaverastreo CHAR(30))
RETURNING CHAR(5); 
    
    DEFINE iSqlErr          INTEGER;
    DEFINE cCodRet1         CHAR(5);
    DEFINE vtransaccion     INTEGER;
       
    
    LET iSqlErr	        = 0;
    LET cCodRet1        = '000';
    LET vtransaccion    = 0;

       BEGIN

    ON EXCEPTION SET iSqlErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_upd_status_firma_envio.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;        
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
           RETURN cCodRet1;
        END IF;
    END EXCEPTION;

    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;

    --SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_upd_status_firma_envio.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

  
IF presfirm != 0 THEN

LET vtransaccion = 1;

UPDATE bdispei:tblpago
SET chrestatusenvio = 'F'
WHERE vchrclaverastreo = pvchrclaverastreo
AND chrestatusenvio = 'E';

                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET cCodRet1 = '000';

                	IF vtransaccion = 1 THEN
                    		COMMIT WORK;
                    		BEGIN WORK;
                	ELSE
                    		COMMIT WORK;
                    		BEGIN WORK;
                	END IF;
		
				RETURN cCodRet1;

                ELSE --dbinfo('sqlca.sqlerrd2') = 0
		    LET cCodRet1 = '131'; --FALLO EN REALIZAR EL UPDATE

                		IF vtransaccion = 1 THEN
                    			COMMIT WORK;
                    			BEGIN WORK;
                		ELSE
                    			COMMIT WORK;
                    			BEGIN WORK;
                		END IF;

				RETURN cCodRet1; --FALLO EN REALIZAR EL UPDATE
                END IF; --dbinfo('sqlca.sqlerrd2') > 0

ELSE --presfirm = 0 

LET cCodRet1 = '000';

                		IF vtransaccion = 1 THEN
                    			COMMIT WORK;
                    			BEGIN WORK;
                		ELSE
                    			COMMIT WORK;
                    			BEGIN WORK;
                		END IF;

				RETURN cCodRet1;

END IF; --presfirm != 0


    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;


RETURN cCodRet1;
     
END; 
    
END PROCEDURE
DOCUMENT
'Autor: MARIO GONZALEZ VAZQUEZ',
'Fecha: 30/01/2026',
'Descripcion: Se crea SP para en el escenario de que falle el generar la firma en el flujo de envio realice un update en tblpago de cambio de estatus de E a F',
'BD:BDISPEI';

CREATE PROCEDURE "informix".sp_regordenctecte_web( pEmpresa  CHAR(3),           --- EMPRESA
                                               pchrSucursal CHAR(4),            --- SUCURSAL
                                               pchrUsuario CHAR(8),             --- USUARIO
                                               pintBancoDest INTEGER,           --- NUMERO DEL BANCO DESTINO
                                               pmnyImporte MONEY(14,2),         --- IMPORTE TRANSACCION
                                               pchrTransuc  CHAR(4),            --- TRANSACCION
                                               pchrFolioSuc CHAR(16),           --- FOLIO
                                               pdtfechacaptura DATE,            --- FECHA CAPTURA
                                               pmnyComision MONEY(14,2),        --- COMISION
                                               pmnyIvaComis MONEY(14,2),        --- IVA DE LA COMISION 
                                               pvchrNombreOrd VARCHAR(40),      --- NOMBRE DEL ORDENANTE
                                               pintTipoCtaOrd INTEGER,          --- TIPO DE CUENTA DEL ORDENANTE
                                               pvchrCuentaOrd VARCHAR(20),      --- CUENTA DEL ORDENANTE
                                               pvchrRfcOrd VARCHAR(18),         --- RFC DEL ORDENANTE
                                               pvchrNombreBenef VARCHAR(40),    --- NOMBRE DEL BENEFICIARIO
                                               pintTipoCtaBenef INTEGER,        --- TIPO DE CUENTA DEL BEBEFICIARIO
                                               pvchrCtaBenef VARCHAR(20),       --- CUENTA DEL BENEFICIARIO
                                               pvchrRFCBenef VARCHAR(18),       --- RFC DEL BENEFICIARIO
                                               pvchrConceptoPago VARCHAR(40),   --- CONCEPTO DEL PAGO
                                               pmnyIVA MONEY(14,2),             --- IVA
                                               pdecRefNum DECIMAL(7,0),         --- REFERENCIA NUMERICA
                                               pvchrRefCobranza1 VARCHAR(40) )  --- REFERENCIA COBRANZA
RETURNING CHAR(5), CHAR(100), CHAR(30);
    
    DEFINE cVarDataErr      CHAR(100);
    DEFINE vchrcodret 	    CHAR(5);
    DEFINE vintcodret	    INTEGER;
    DEFINE vchrCveRastreo	CHAR(30);
    DEFINE vintPermiteCta11 INTEGER;
    DEFINE vchrFuente       CHAR(7);
    DEFINE vchrTranscargo   CHAR(4);
    DEFINE vchrComis        CHAR(4);
    DEFINE vchrIvaComis     CHAR(4);
    DEFINE vchrtranret      CHAR(4);
    DEFINE dteFechacargo    DATE;
    DEFINE vmnySdoDisp      MONEY(14,2);
    DEFINE vmnyMontoRet     MONEY(14,2);
    DEFINE vchrTarjeta      CHAR(20);
    DEFINE vtransaccion     INTEGER;
    DEFINE vchrparametro    VARCHAR(255);
    DEFINE vchrFechaValor   VARCHAR(10);
    DEFINE dIva             DECIMAL(5,3);
    DEFINE vmnyMontoLibre   MONEY(14,2);
    DEFINE vdigitoverifica  SMALLINT;
    DEFINE vexiste_cta      CHAR(20);
    DEFINE vexiste_suc      CHAR(4);
	DEFINE vchrCtaOrdClabe  VARCHAR(20);
	DEFINE vchrCtaOrdtblp   VARCHAR(20);
    DEFINE vchrTelefono     CHAR(10); 
    DEFINE intpktblpago     INTEGER;
    DEFINE vchrtopologia    CHAR(1);
    DEFINE intBancoOrd      INTEGER;
    DEFINE vintCveCesif     INTEGER;
    DEFINE vsintLongCveRast SMALLINT;
    DEFINE vdecRefNum       DECIMAL(7,0);
    DEFINE vexiste_clave    CHAR(40);
    DEFINE vind_dispon      CHAR(1);
    DEFINE vchrExisteCta    SMALLINT;
	DEFINE pvchrCuentaBenef	CHAR(20);
	DEFINE pvchrCveTransfer INTEGER;
	DEFINE vchrestatusenvio CHAR(1);
	DEFINE vfecha_hoy		DATE;
	DEFINE vcodret1         CHAR(5);
	DEFINE vfechaHabil		DATE;
    DEFINE wmedioent        CHAR(3);
    DEFINE wvchrnombreord   CHAR(40);
    DEFINE wvchrnombrebenef CHAR(40);
    DEFINE wvchrconceptopago2 CHAR(40);
    DEFINE wvchrrefcobranza CHAR(40);
    DEFINE wvchrrfcbenef 	CHAR(18);
    DEFINE wvchrrfcord 		CHAR(18);
    DEFINE wmnyImporte 		DECIMAL (14,2);
    DEFINE wmnyIVA 			DECIMAL (14,2);
	
	-- // FIRMA
	DEFINE ret						INTEGER;
	DEFINE wvchrfirma 			    CHAR(512);
	DEFINE wchrcadena_00			CHAR(3000);
	DEFINE wchrcadena_01			CHAR(200);
	DEFINE wchrcadena_02			CHAR(200);
	DEFINE wchrcadena_03			CHAR(200);
	DEFINE wchrcadena_04			CHAR(200);
	DEFINE wvchrnombre				CHAR(30);
	DEFINE vchrFechaValor2			VARCHAR(10);

    LET vtransaccion = 0;
    LET cVarDataErr = '';
    LET vdigitoverifica = 0;
    LET vexiste_cta = '';
    LET vexiste_suc = '';
    LET vchrExisteCta = 0;
	LET pvchrCuentaBenef='';
	LET pvchrCveTransfer = 90684;
	LET vchrestatusenvio = 'N';
	LET vfecha_hoy      = '';
	LET vcodret1       = "00000";
    LET wvchrnombreord = '';
    LET wvchrnombrebenef = '';
    LET wvchrconceptopago2 = '';
    LET wvchrrefcobranza = '';
    LET wvchrrfcbenef = '';
    LET wvchrrfcord = '';
	
	-- // FIRMA
	LET ret           = 0;
	LET wvchrfirma    = '';
	LET wchrcadena_00 = '';
	LET wchrcadena_01 = '';
	LET wchrcadena_02 = '';
	LET wchrcadena_03 = '';
	LET wchrcadena_04 = '';
	LET wvchrnombre   = '';
	LET vchrFechaValor2 = '';
	
	--- SET DEBUG FILE TO '/resplogifx/conciliachq/spei/sp_regordenctecte_web.out';
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vintcodret
		SET DEBUG FILE TO '/resplogifx/conciliachq/spei/sp_regordenctecte_web.err';
		TRACE ON;
        IF vintcodret <> 0 THEN
            LET vchrcodret = vintcodret;
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
    END EXCEPTION;

    ON EXCEPTION IN (-535)
        let vtransaccion = 1;
    END EXCEPTION WITH resume;

    -- // Iniciar la transaccion
    IF vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    -- // Inicializacion de variables
    LET vchrcodret = '00000';
    LET vchrCveRastreo = '';
    LET vchrTarjeta = '';
    LET vind_dispon = '0';    
    LET pintTipoCtaOrd = pintTipoCtaOrd;
    LET pvchrCuentaOrd = pvchrCuentaOrd;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT ind_disponible, fecha_hoy, fecha_hoy
      INTO vind_dispon, vfecha_hoy, vfechaHabil
    FROM bdicheq:sc_fechas 
    WHERE empresa = pEmpresa;

    LET vchrFechaValor2 = to_char(vfechaHabil, '%Y%m%d');
     
    IF vind_dispon = '0' THEN
        LET vchrcodret = '00004'; -- // Falta parametro Fecha de Operacion
        LET cVarDataErr = 'SISTEMA DE CHEQUES NO DISPONIBLE.';
        RETURN vchrcodret, cVarDataErr, '';
    END IF

    -- // valida canal internet
    IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
        if pchrSucursal = '5003' then
            EXECUTE PROCEDURE sp_validaspei_bpi(pvchrCuentaOrd, pvchrCtaBenef)
            INTO vchrcodret, cVarDataErr;
            
            IF trim(vchrcodret) <> '000' THEN
                RETURN '00'||vchrcodret, cVarDataErr, '';    
            end if;
        end if;
    END IF;

    -- // Obtiene el numero de tarjeta
    IF pintTipoCtaOrd = 3 THEN
        SELECT num_tarjeta
          INTO vchrTarjeta
          FROM bdicheq:sc_tarjeta
         WHERE empresa = pEmpresa
           AND num_tarjeta = trim(pvchrCuentaOrd)
           AND status_tar = 'A';
        
        IF (vchrTarjeta is null) OR (vchrTarjeta = '') then
            LET vchrcodret = '00019'; -- // Tarjeta no vigente Ã³ no asignada
            LET cVarDataErr = 'Tarjeta no vigente Ã³ no asignada';
            RETURN vchrcodret, cVarDataErr, '';
        ELSE             
            -- // Verifica si se encuentra activa la cuenta de cheques
            IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
                SELECT mae.cuenta 
                  INTO pvchrCuentaOrd 
                  FROM bdicheq:sc_maechq mae,
                       bdicheq:sc_tarjeta tar
                 WHERE mae.empresa = pEmpresa
                   AND mae.cuenta = tar.cuenta
                   AND mae.status_cta <> "2"
                   AND tar.empresa = pEmpresa
                   AND tar.num_tarjeta = vchrTarjeta
                   AND tar.status_tar = 'A';
            ELSE
                SELECT mae.cuenta_tf 
                  INTO pvchrCuentaOrd 
                  FROM bditransfer:tf_maecte mae,
                       bdicheq:sc_tarjeta tar
                 WHERE mae.cuenta_tf = tar.cuenta
                   AND mae.status_cta = "1"
                   AND tar.empresa = pEmpresa
                   AND tar.num_tarjeta = vchrTarjeta
                   AND tar.status_tar = 'A';
            END IF;
            
            IF pvchrCuentaOrd IS NULL OR pvchrCuentaOrd = '' THEN
                LET vchrcodret = '00020'; -- // La cuenta Ord. no se encuentra activa
                LET cVarDataErr = 'La cuenta Ord. no se encuentra activa';
                RETURN vchrcodret, cVarDataErr, '';
            END IF
        END IF
    END IF

    -- // Valida la fecha del Movimiento
    IF (pdtfechacaptura is null) or (pdtfechacaptura = '') then
        LET vchrcodret = '00001'; -- // Falta parametro Fecha de Operacion
        LET cVarDataErr = 'Falta parÃ¡metro Fecha de OperaciÃ³n';
        RETURN vchrcodret, cVarDataErr, '';
    END IF

    -- // Obtiene el Iva General
    SELECT valor
      INTO dIva
      FROM bdinteg:si_param
     WHERE cod_param = 47
       AND empresa = pEmpresa;
     
    IF dIva IS NULL THEN
        LET vchrcodret = '00011';
        LET cVarDataErr = 'ParÃ¡metro no encontrado';
        RETURN vchrcodret, cVarDataErr, '';
    END IF;
	
    -- // Obtiene la fecha de operacion
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'FECHA_OPERACION';
     
    IF vchrparametro IS NULL THEN
        LET vchrcodret = '00011';
        LET cVarDataErr = 'ParÃ¡metro no encontrado';
        RETURN vchrcodret, cVarDataErr, '';
    END IF;

    -- // Formatea la fecha a mm/dd/aaaa
    LET vchrFechaValor = SUBSTR(TRIM(vchrparametro),4,2) || '/' || SUBSTR(TRIM(vchrparametro),0,2) || '/' || SUBSTR(TRIM(vchrparametro),7,4);
	LET vchrFechaValor2 = SUBSTR(TRIM(vchrparametro),7,4) || SUBSTR(TRIM(vchrparametro),4,2) || SUBSTR(TRIM(vchrparametro),1,2);

       -- // Verifica  la cuenta del ordenante a 18 digitos
    IF pintTipoCtaOrd = 40 THEN
        IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
            SELECT cuenta_clabe
              INTO vchrCtaOrdClabe
              FROM bdicheq:sc_maechq
             WHERE cuenta = pvchrCuentaOrd;
        ELSE
            SELECT cta_clabe
              INTO vchrCtaOrdClabe
              FROM bditransfer:tf_maecte
             WHERE cuenta_tf = pvchrCuentaOrd;
        END IF;
        
        IF vchrCtaOrdClabe IS NULL THEN
            LET vchrCtaOrdClabe = '00021'; -- // No se tiene cuenta clabe.
            LET cVarDataErr = 'Cuenta No vÃ¡lida. ';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        IF vchrCtaOrdClabe IS NOT NULL THEN
			IF LENGTH(vchrCtaOrdClabe) >= 16 AND LENGTH(vchrCtaOrdClabe) < 18 THEN
				LET vchrCtaOrdClabe = LPAD(vchrCtaOrdClabe,18,'0');
            ELIF LENGTH(vchrCtaOrdClabe) > 18 THEN
                LET vchrcodret = '00020'; -- // La cuenta debe ser de 18 digitos.
                LET cVarDataErr = 'La cuenta Clave del Ord. debe ser de 18 dÃ­gitos';
                RETURN vchrcodret, cVarDataErr, '';
            END IF;

            -- // Verifica si existe la cuenta de cheques
            IF SUBSTR(pvchrCuentaOrd, 1, 2) <> '80' THEN
                SELECT cuenta
                  INTO vexiste_cta
                  FROM bdicheq:sc_maechq 
                 WHERE empresa = pEmpresa
                   AND cuenta = pvchrCuentaOrd 
                   AND status_cta <> "2";
            ELSE
                SELECT cuenta
                  INTO vexiste_cta
                  FROM bditransfer:tf_maecte 
                 WHERE cuenta_tf = pvchrCuentaOrd 
                   AND status_cta = "1";
            END IF;
               
            IF vexiste_cta is null OR vexiste_cta = '' THEN
                LET vchrcodret = '00020'; -- // La cuenta Ord. no existe.
                LET cVarDataErr = 'La cuenta Ord. no existe Ã³ no se encuentra activa';
                RETURN vchrcodret, cVarDataErr, '';
            END IF
        ELIF LENGTH(pvchrCuentaOrd) = 11 THEN
            LET vchrcodret = '00020'; -- // La cuenta Ord. no permite 11 digitos.
            LET cVarDataErr = 'La cuenta Ord. no permite solo 11 digitos';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
    END IF;
    
    IF pintTipoCtaOrd = 10 THEN
        IF LENGTH(pvchrCuentaOrd) = 10 THEN
            SELECT cuenta, telefono
              INTO vexiste_cta, vchrTelefono
              FROM bdicheq:sc_cuenta_telefono
             WHERE telefono = pvchrCuentaOrd;
        ELIF LENGTH(pvchrCuentaOrd) = 11 THEN
            SELECT cuenta, telefono
              INTO vexiste_cta, vchrTelefono
              FROM bdicheq:sc_cuenta_telefono
             WHERE cuenta = pvchrCuentaOrd;
        ELSE
            LET vchrcodret = '00020'; -- // La cuenta Ord. no existe.
            LET cVarDataErr = 'La cuenta ordenante no existe';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
        
        IF vexiste_cta is null OR vexiste_cta = '' THEN
            LET vchrcodret = '00020'; -- // La cuenta Ord. no existe.
            LET cVarDataErr = 'La cuenta Ord. no existe Ã³ no se encuentra activa';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
        
        SELECT cuenta
          INTO pvchrCuentaOrd
          FROM bdicheq:sc_maechq
         WHERE empresa = pEmpresa
           AND cuenta = vexiste_cta 
           AND status_cta <> "2";
            
        IF pvchrCuentaOrd is null OR pvchrCuentaOrd = '' THEN
            LET vchrcodret = '00020'; -- // La cuenta Ord. no existe.
            LET cVarDataErr = 'La cuenta Ord. no existe Ã³ no se encuentra activa';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
    END IF;

    -- // Verifica la longitud de la cta benef
    IF pintTipoCtaBenef = 40 THEN
        IF LENGTH(pvchrCtaBenef) >= 16 AND LENGTH(pvchrCtaBenef) < 18 THEN
            LET pvchrCtaBenef = LPAD(pvchrCtaBenef,18,'0');
            
            EXECUTE PROCEDURE sp_validadv(pvchrCtaBenef)
            INTO vchrcodret, vdigitoverifica;
            
            IF vdigitoverifica = 0 THEN
                LET vchrcodret = '00020'; -- // La Cuenta Clabe del Benefciario es Invalida
                LET cVarDataErr = 'La Cuenta Clabe del Benefciario es Invalida ';
                RETURN vchrcodret, cVarDataErr, '';
            END IF
        ELIF LENGTH(pvchrCtaBenef) <> 18 THEN
            LET vchrcodret = '00020'; -- // La cuenta Benef debe ser de 18 digitos.
            LET cVarDataErr = 'La cuenta Benef debe ser de 18 digitos';
            RETURN vchrcodret, cVarDataErr, '';
        END IF;
	ELIF pintTipoCtaBenef = 10 AND pintBancoDest = pvchrCveTransfer  THEN
		SELECT cuenta_tf
			INTO pvchrCuentaBenef
			FROM bditransfer:tf_maecte
		WHERE telefono = pvchrCtaBenef
			AND status_cta = "1";
			IF pvchrCuentaBenef is null OR pvchrCuentaBenef = '' THEN
				SELECT cuenta
					INTO pvchrCuentaBenef
					FROM bdicheq:sc_cuenta_telefono
				WHERE telefono =pvchrCtaBenef;
			END IF;
			IF LENGTH(pvchrCuentaBenef) > 0 THEN
				LET vchrcodret = '01168';
				LET cVarDataErr = 'Cuenta destino Transfer, ingresa al menÃº: Transfer/Traspaso a cuenta Transfer';
                 RETURN vchrcodret, cVarDataErr, '';
			END IF;
    END IF;

    -- // Trae la transaccion de Cargo.
    SELECT vchrValor
      INTO vchrTranscargo
      FROM tblparametros
     WHERE vchrcveparametro = 'TRANSACC_CARGO';

    IF vchrTranscargo IS NULL OR vchrTranscargo = '' THEN
        LET vchrcodret = '00022'; -- // Falta parametro de transaccion comision.
        RETURN vchrcodret, cVarDataErr, '';
    END IF;

    FOREACH WITH HOLD
        -- // Trae la transaccion de la Comision
        SELECT vchrValor
          INTO vchrComis
          FROM tblparametros
         WHERE vchrcveparametro = 'TRANSACC_COMISION'

        IF vchrComis IS NULL OR vchrCOmis = '' THEN
            LET vchrcodret = '00023'; -- // Falta parametro de transaccion comision.
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        -- // Trae la transaccion del IVA de la Comision
        SELECT vchrValor
          INTO vchrIvaComis
          FROM tblparametros
         WHERE vchrcveparametro = 'TRANSACC_IVACOM';

        IF vchrIvaComis IS NULL OR vchrIvaComis = '' THEN
            LET vchrcodret = '00023'; -- // Falta parametro de transaccion iva.
            RETURN vchrcodret, cVarDataErr, '';
        END IF;

        -- // Valida si existe la transaccion de la sucursal
        IF TRIM(pchrTransuc) = '' THEN
            --- LET pchrTransuc = LPAD(TRIM(vchrTranscargo), 4, '0');
            LET pchrTransuc = '0000';
        END IF;
		
		-- // GUARDA REGISTRO EN BDISPEI:TBLPAGO 
		IF pintTipoCtaOrd = '40' THEN
			LET vchrCtaOrdtblp = vchrCtaOrdClabe;
        ELIF pintTipoCtaOrd = '10' THEN
			LET vchrCtaOrdtblp = vchrTelefono;
		ELSE
			LET vchrCtaOrdtblp = vchrTarjeta;
		END IF;

        EXECUTE PROCEDURE sp_regordenpagospei(pEmpresa,         --- Empresa.
                                              pchrUsuario,      --- Usuario.
                                              pchrSucursal,     --- Sucursal.
                                              pchrFolioSuc,     --- Folio Sucursal.
                                              pintBancoDest,    --- Clave Banco Beneficiario.
                                              pdtfechacaptura,  --- Fecha Valor.
                                              1,                --- Tipo de pago CLIENTE-CLIENTE.
                                              NULL,             --- Clave de tipo de operacion.
                                              pmnyImporte,      --- Importe de la operacion.
                                              pvchrNombreOrd,   --- Nombre del Ordenante.
                                              vchrCtaOrdtblp,   --- Cuenta del ordenante.
                                              pvchrRfcOrd,      --- Rfc del Ordenante
                                              pvchrNombreBenef, --- Nombre del Beneficiario.
                                              pvchrCtaBenef,    --- Cuenta del Beneficiario.
                                              pvchrRFCBenef,    --- Rfc del Beneficiario.
                                              pmnyIVA,          --- Importe del Iva.
                                              pdecRefNum,       --- Referencia Numerica.
                                              pvchrRefCobranza1,--- Referencia de cobranza.
                                              NULL,             --- Concepto de pago con longitud de 210 pos.
                                              NULL,             --- Clave para el pago.
                                              NULL,             --- Nombre del beneficiario2.
                                              NULL,             --- Rfc Beneficiario2.
                                              NULL,             --- Concepto de pago2 a 40 pos.
                                              pvchrConceptoPago,--- Concepto de pago con longitud de 40 pos.
                                              vchrTranscargo,   --- chrtxop.
                                              pintTipoCtaOrd,   --- Tipo cuenta Ordenante.
                                              pintTipoCtaBenef) --- Tipo cuenta Beneficiario.
        INTO vchrcodret, cVarDataErr, vchrCveRastreo, intpktblpago, vchrFechaValor, vchrtopologia, intBancoOrd, vintCveCesif, vsintLongCveRast, vdecRefNum;

        IF trim(vchrcodret) <> '000' THEN
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
            
            RETURN '00'||vchrcodret, cVarDataErr, '';
        END IF;

        -- // Busca si aplica comision e iva especial
        SELECT suc.sucursal
          INTO vexiste_suc
        FROM bdinteg:si_sucursales suc, 
               bdinteg:si_param par 
        WHERE par.cod_param = 47
           AND suc.sucursal = pchrSucursal
           AND par.valor = suc.iva
           AND par.empresa = suc.empresa
           AND par.empresa = pEmpresa;
           
        IF vexiste_suc is null OR vexiste_suc = '' THEN
            -- // Trae la transaccion de la Comision especial
            SELECT trancivaesp
              INTO vchrtranret
            FROM bdinteg:si_transacc
            WHERE numero = vchrComis
               AND empresa = pEmpresa
               AND sistema = '01';
               
            LET vchrComis = trim(vchrtranret);

            -- // Trae la transaccion del IVA especial
            SELECT trancivaesp
              INTO vchrtranret
              FROM bdinteg:si_transacc
             WHERE numero = vchrIvaComis
               AND empresa = pEmpresa
               AND sistema = '01';
            
            LET vchrIvaComis = trim(vchrtranret);
        END IF

        -- // Aplicar el Cargo de la operacion SPEI - Ejecutar cargo a cheques
        EXECUTE PROCEDURE bdicheq:cargo_ref( pEmpresa,       --- empresa
                                             pchrSucursal,   --- sucursal
                                             pchrUsuario,    --- usuario
                                             vchrTranscargo, --- transaccion
                                             pchrTransuc,    --- transaccion suc
                                             pchrFolioSuc,   --- folio suc
                                             pvchrCuentaOrd, --- cuenta
                                             0,              --- no. cheque
                                             pmnyImporte,    --- monto
                                             "01",           --- divisa
                                             vchrCveRastreo, --- referencia
                                             vchrTarjeta,    --- no. tarjeta
                                             pchrUsuario)    --- usuario autoriza
        INTO vchrcodret, vchrtranret,dteFechacargo,vmnySdoDisp,vmnyMontoRet;
        
        -- // Valida si se pudo realizar el cargo
        IF trim(vchrcodret) <> '000' THEN
            LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';
            
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN '00'||vchrcodret, cVarDataErr, '';
        END IF;

        -- // Registra el detalle de la transaccion del pago
        INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
        VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrTranscargo, pEmpresa, pvchrCuentaOrd, pmnyImporte, vchrCveRastreo);
        
        -- // Aplicar la Comision de la operacion
        IF pmnyComision > 0 THEN
            EXECUTE PROCEDURE bdicheq:cargo_ref( pEmpresa,       --- empresa
                                                 pchrSucursal,   --- sucursal
                                                 pchrUsuario,    --- usuario
                                                 vchrComis,      --- transaccion
                                                 pchrTransuc,    --- transaccion suc
                                                 pchrFolioSuc,   --- folio suc
                                                 pvchrCuentaOrd, --- cuenta
                                                 0,              --- no. cheque
                                                 pmnyComision,   --- monto
                                                 "01",           --- divisa
                                                 vchrCveRastreo, --- referencia
                                                 vchrTarjeta,    --- no. tarjeta
                                                 pchrUsuario)    --- usuario autoriza
            INTO vchrcodret, vchrtranret,dteFechacargo,vmnySdoDisp,vmnyMontoRet;
            
            -- // Valida si se pudo realizar el cargo
            IF trim(vchrcodret) <> '000' THEN
                LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';
                
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                
                RETURN '00'||vchrcodret, cVarDataErr, '';
            END IF;

            -- // Registra el detalle de la transaccion de la comision
            INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
            VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrComis, pEmpresa, pvchrCuentaOrd, pmnyComision, vchrCveRastreo);
        END IF;

        -- // Aplicar el IVA de la Comision
        IF pmnyIvaComis > 0 THEN
            EXECUTE PROCEDURE bdicheq:cargo_ref( pEmpresa,       --- empresa
                                                 pchrSucursal,   --- sucursal
                                                 pchrUsuario,    --- usuario
                                                 vchrIvaComis,   --- transaccion
                                                 pchrTransuc,    --- transaccion suc
                                                 pchrFolioSuc,   --- folio suc
                                                 pvchrCuentaOrd, --- cuenta
                                                 0,              --- no. cheque
                                                 pmnyIvaComis,   --- monto
                                                 "01",           --- divisa
                                                 vchrCveRastreo, --- referencia
                                                 vchrTarjeta,    --- no. tarjeta
                                                 pchrUsuario)    --- usuario autoriza
            INTO vchrcodret, vchrtranret,dteFechacargo,vmnySdoDisp,vmnyMontoRet;
            
            -- // Valida si se pudo realizar el cargo
            IF trim(vchrcodret) <> '000' THEN
                LET cVarDataErr = 'No fue posible ejecutar el cargo a la cuenta de cheques';
                
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                    
                RETURN '00'||vchrcodret, cVarDataErr, '';
            END IF;

            -- // Registra el detalle de la transaccion del iva de la comision
            INSERT INTO tbldetranpago(folio_suc, sucursal, usuario, fech_alt, transacc, empresa, cuenta, monto_tot, clave_rastreo)
            VALUES(pchrFolioSuc, pchrSucursal, pchrUsuario, pdtfechacaptura, vchrIvaComis, pEmpresa, pvchrCuentaOrd, pmnyIvaComis, vchrCveRastreo);
        END IF;
        
        SELECT referencia
          INTO vexiste_clave
          FROM bdicheq:sc_movdia
         WHERE empresa = pEmpresa
           AND cuenta = pvchrCuentaOrd
           AND transacc = vchrTranscargo
           AND cancelad <> 'S'
           AND referencia = vchrCveRastreo;
           
        IF vexiste_clave = vchrCveRastreo THEN
            -- CONTROL DE ESTATUS DE ENVIO EN HORARIO DE LIQUIDACION FINAL
            IF CURRENT HOUR TO fraction > '17:58:00' AND CURRENT HOUR TO fraction < '19:00:00' THEN
				SELECT vchrvalor
				  INTO vchrparametro
				  FROM tblparametros
				  WHERE vchrcveparametro = 'BLOQUEO_A_USUARIOS';
				  
					IF vchrparametro IS NOT NULL THEN
						IF (vchrparametro * 1) = 1 THEN
							LET vchrestatusenvio='E';
                
							CALL "informix".sp_validafecha(pEmpresa, vfecha_hoy)
								RETURNING vcodret1, vfechaHabil;
                
							LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');
							LET vchrFechaValor2 = to_char(vfechaHabil, '%Y%m%d');
						END IF;
					END IF;
            END IF;
            
			-- // NUEVOS CAMBIOS PARA GENERAR EL CIFRADO
            IF pmnyImporte > 400000.00 THEN
                LET wmedioent = 'h2h';
            ELSE
                LET wmedioent = '';
            END IF;
            
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ñ', 'N');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Á', 'A');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'É', 'E');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Í', 'I');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ó', 'O');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ú', 'U');
            LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ü', 'U');
			LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'ý', 'X');
			LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ý', 'X');
			LET pvchrNombreOrd = REPLACE(pvchrNombreOrd, 'Ã', 'A');
            
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ñ', 'N');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Á', 'A');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'É', 'E');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Í', 'I');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ó', 'O');
            LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ú', 'U');
			LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ü', 'U');
			LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'ý', 'X');
			LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ý', 'X');
			LET pvchrNombreBenef = REPLACE(pvchrNombreBenef, 'Ã', 'A');
   
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ñ', 'N');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ñ', 'n');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'á', 'a');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'é', 'e');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'í', 'i');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ó', 'o');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ú', 'u');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Á', 'A');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'É', 'E');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Í', 'I');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ó', 'O');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ú', 'U');
            LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ü', 'U');
			LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'ý', 'X');
			LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ý', 'X');
			LET pvchrConceptoPago = REPLACE(pvchrConceptoPago, 'Ã', 'A');
            
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ñ', 'N');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ñ', 'n');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'á', 'a');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'é', 'e');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'í', 'i');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ó', 'o');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ú', 'u');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Á', 'A');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'É', 'E');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Í', 'I');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ó', 'O');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ú', 'U');
            LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ü', 'U');
			LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'ý', 'X');
			LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ý', 'X');
			LET pvchrRefCobranza1 = REPLACE(pvchrRefCobranza1, 'Ã', 'A');
                    
            LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'Ñ', 'N');
			LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'ý', 'X');
			LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'Ý', 'X');
			LET pvchrRFCBenef = REPLACE(pvchrRFCBenef, 'Ã', 'A');
			
            LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'Ñ', 'N');
			LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'ý', 'X');
			LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'Ý', 'X');
			LET pvchrRFCOrd   = REPLACE(pvchrRFCOrd, 'Ã', 'A');

			
            LET wmnyImporte = pmnyImporte;
            LET wmnyIVA = pmnyIVA;

            LET wchrcadena_01 = '||'||vintCveCesif||'|'||'Bancoppel'||'|'||vchrFechaValor2||'|'||'|'||TRIM(vchrCveRastreo)||'|'||intBancoOrd||'|';
            LET wchrcadena_02 = wmnyImporte||'|'||'1'::integer||'|'||pintTipoCtaOrd||'|'||TRIM(pvchrNombreOrd)||'|'||TRIM(vchrCtaOrdtblp)||'|'||TRIM(pvchrRFCOrd)||'|';
            LET wchrcadena_03 = pintTipoCtaBenef||'|'||TRIM(pvchrNombreBenef)||'|'||TRIM(pvchrCtaBenef)||'|'||TRIM(pvchrRFCBenef)||'||||||'||TRIM(pvchrConceptoPago)||'|||||'||TRIM(pvchrRefCobranza1)||'|';
            LET wchrcadena_04 = vdecRefNum||'||'||TRIM(vchrtopologia)||'|'||''||TRIM(wmedioent)||'|'||'|'||'0'||'|'||wmnyIVA||'||';
            LET wchrcadena_00 = TRIM(wchrcadena_01)||TRIM(wchrcadena_02)||TRIM(wchrcadena_03)||TRIM(wchrcadena_04);
            
-- SE COMENTA 11 03 2026 PARA COMENTAR EL USO DE BINARIO FIRMA Y vchrfirma = wchrcadena_00
            --LET wvchrfirma = space(512);
            
            --EXECUTE function bdispei:syn_sign(TRIM(wchrcadena_00), wvchrfirma, 21) 
            --INTO ret;
            
            --IF ret = 0 THEN 
                -- // INSERTA REGISTRO DE LA OPERACION EN LA TBLPAGO
				INSERT INTO tblpago
				( intpkpago, mnyimporte, chrestatusenvio, vchrnombreord, vchrcuentaord, vchrrfcord, intcvetipoctaord, vchrnombrebenef,
				  intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, mnyiva, intrefnumerica, vchrconceptopago2, vchrrefcobranza,
				  chrusuarioprom, intcvetipopago, chrsentidopago, dtfechavalor, vchrclaverastreo, chrfolioprom, dtfechacaptura,
				  chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, cvecesifbcoord, cvecesifbcodest, chrtxop, sintlongcverastreo, vchrfirma )
				VALUES
				( intpktblpago, pmnyImporte, vchrestatusenvio, pvchrNombreOrd, vchrCtaOrdtblp, pvchrRFCOrd, pintTipoCtaOrd, pvchrNombreBenef,
				  pintTipoCtaBenef, pvchrCtaBenef, pvchrRFCBenef, pmnyIVA, vdecRefNum, pvchrConceptoPago, pvchrRefCobranza1,
				  pchrUsuario, 1, 'E', vchrFechaValor, vchrCveRastreo, pchrFolioSuc, pdtfechacaptura,
				  '', '', vchrtopologia, '0', intBancoOrd, vintCveCesif, vchrTranscargo, vsintLongCveRast, wchrcadena_00);
            --ELSE
				--CONTINUE FOREACH;
            --END IF;
-- SE COMENTA 11 03 2026 PARA COMENTAR EL USO DE BINARIO FIRMA Y vchrfirma = wchrcadena_00
        END IF;
    END FOREACH;

    -- // Aplica la transaccion 
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    -- // Regresa el codigo de retorno y clave de rastreo.
    RETURN '00'||vchrcodret, cVarDataErr, vchrCveRastreo;

    END;    
END PROCEDURE;