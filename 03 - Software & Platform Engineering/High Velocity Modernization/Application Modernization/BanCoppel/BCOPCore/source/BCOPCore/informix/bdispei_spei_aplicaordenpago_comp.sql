CREATE PROCEDURE "informix".spei_aplicaordenpago_comp( pRegistros INTEGER, pOrigen CHAR(1) ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cDescErr         CHAR(50);
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE cCodRet4         CHAR(5);
    DEFINE cCodRet5         CHAR(5);
    DEFINE cCodRet6         CHAR(5);
    DEFINE cCodRet7         CHAR(5);
    DEFINE iContador1       INTEGER;
    DEFINE iContador2       INTEGER;
    DEFINE iComienza        SMALLINT;
    DEFINE iAbierto         SMALLINT;
    DEFINE cDisponible      CHAR(1);
    DEFINE cStatusProc      CHAR(1);
    DEFINE cCveRastreo      CHAR(30);
    DEFINE cCuenta          CHAR(20);
    DEFINE mMonto           DECIMAL(14,2);
    DEFINE dFechaVal        DATE;
    DEFINE cCtaBenef        CHAR(20);
    DEFINE cNumCte          CHAR(20);
    DEFINE cCtaBenefEmail   CHAR(20);
    DEFINE cTpoCtaBenefMsg  CHAR(25);
    DEFINE cTransacc        CHAR(4);
    DEFINE iSerialFolio     INTEGER;
    DEFINE cFolioSuc        CHAR(30);
    DEFINE iExiste          INTEGER;
    DEFINE cCtaBenefMsg     CHAR(20);
    DEFINE iCodRet          SMALLINT;
    DEFINE iVueltas         SMALLINT;
    
    DEFINE wchrconceptopago2  CHAR(40);
    DEFINE wintrefnumerica    DECIMAL(7,0);
    DEFINE wcvecesifbcoord    INTEGER;
    DEFINE wintcvetipoctaord  INTEGER;
    DEFINE wvchrcuentaord     CHAR(20);
    DEFINE wvchrnombreord     CHAR(40);
    DEFINE wintcvetipoctabene INTEGER;
    DEFINE wvchrnombrebenef   CHAR(40);
    DEFINE vtimestamp         LVARCHAR(20);
    DEFINE wtimestamp         CHAR(20);
    DEFINE wchrtipopago       CHAR(2); 
    DEFINE wchridmjc          CHAR(20);
    DEFINE wchrfchmjc         CHAR(20);
    DEFINE wchrnumcelord      CHAR(10);
    DEFINE wintdigidord       INTEGER;
    DEFINE wchrnumcelben      CHAR(20);
    DEFINE wintdigidben       INTEGER;
    DEFINE wchrnumseriecert   CHAR(20);
    DEFINE wvchrcodretcodi    CHAR(5);
    
    DEFINE wcadena_val      CHAR (1000);
    DEFINE wvchrrefcobranza CHAR(40);
    DEFINE wchrfechalimpago CHAR(16);
    DEFINE wintpagocomision INTEGER;
    DEFINE wvcomision 		DECIMAL(14,2);
    DEFINE vcomision        CHAR(7);
	DEFINE vcomision2       CHAR(7);
	DEFINE vcomision3       CHAR(7);
    DEFINE wchrfolioplataf CHAR(20);
    DEFINE wvchrfirma       CHAR(512);
    DEFINE codretfirma      INTEGER;
    DEFINE wcomision 		DECIMAL(14,2);
    DEFINE wchrstatus       CHAR(1);
    
    LET iSqlErr	        = 0;
    LET iIsamErr        = 0;
    LET cDescErr        = '';
    LET cCodRet1        = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET cCodRet4        = '';
    LET cCodRet5        = '';
    LET cCodRet6        = '';
    LET cCodRet7        = '';    
    LET iContador1      = 0;
    LET iContador2      = 0;
    LET iComienza       = -1;
    LET iAbierto        = 0;
    LET cDisponible     = '0';
    LET cStatusProc     = '';
    LET cCveRastreo     = '';
    LET cCuenta         = '';
    LET mMonto          = 0.00;
    LET dFechaVal       = '';
    LET cCtaBenef       = '';
    LET cNumCte         = '';
    LET cCtaBenefEmail  = '';
    LET cTpoCtaBenefMsg = '';
    LET cTransacc       = '';
    LET iSerialFolio    = 0;
    LET cFolioSuc       = '';
    LET iExiste         = 0;
    LET cCtaBenefMsg    = '';
    LET iCodRet         = 0;
    LET iVueltas        = 0;
    
    LET wchrconceptopago2  = '';
    LET wintrefnumerica    = 0;
    LET wcvecesifbcoord    = 0;
    LET wintcvetipoctaord  = 0;
    LET wvchrcuentaord     = '';
    LET wvchrnombreord     = '';
    LET wintcvetipoctabene = 0;
    LET wvchrnombrebenef   = '';
    LET vtimestamp         = dbinfo('utc_current') * 1000;
    LET wtimestamp         = vtimestamp;
    LET wchrtipopago       = '';
    LET wchridmjc          = '';
    LET wchrfchmjc         = '';
    LET wchrnumcelord      = '';
    LET wintdigidord       = 0;
    LET wchrnumcelben      = '';
    LET wintdigidben       = 0;
    LET wchrnumseriecert   = '';
    LET wvchrcodretcodi    = '';
    
    LET wcadena_val      = '';
    LET wvchrrefcobranza = '';
    LET wchrfechalimpago = '';
    LET wintpagocomision = '';
    LET wvcomision       = 0.00;
    LET vcomision        = '';
	LET vcomision2       = '0.00';
	LET vcomision3       = '0';
    LET wchrfolioplataf  = '';
    LET wvchrfirma       = '';
    LET codretfirma      = 0;
    LET wcomision        = 0.00;
    LET wchrstatus       = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_aplicaordenpago_comp.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF iAbierto = 1 THEN
                ROLLBACK WORK;
            END IF;
            UPDATE tblctrlproceso
               SET chrstatus = '0'
             WHERE intcveproceso = 18;
            RETURN cCodRet1, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_aplicaordenpago_comp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT chrstatus 
      INTO cStatusProc 
      FROM tblctrlproceso 
     WHERE intcveproceso = 18;
     
    IF cStatusProc = '0' THEN
        
        UPDATE tblctrlproceso 
           SET chrstatus = '1' 
         WHERE intcveproceso = 18;
    
        SELECT ind_disponible
          INTO cDisponible
          FROM bdicheq:sc_fechas
         WHERE empresa = '001';
         
        IF cDisponible is null OR cDisponible = '' OR cDisponible = '0' THEN
            LET cCodRet1 = '004';
            RETURN cCodRet1, iContador1, iContador2;
        END IF;
        
        FOREACH WITH HOLD
            SELECT {+INDEX(tblabono idx_tblabono_estatus)}
                   FIRST pRegistros
                   vchrclaverastreo, vchrcuentachq, mnyimporte, dtfechavalor, vchrcuentabenef, vchrnumctechq, vchrctabenefemail, vchrtpoctabenefmsg, vchrtransacc, vchrfoliosuc,
                   vchrconceptopago2, intrefnumerica, cvecesifbcoord, intcvetipoctaord, vchrcuentaord, vchrnombreord, intcvetipoctabene, vchrnombrebenef,
                   chrtipopago, chridmjc, chrfchmjc, chrnumcelord, intdigidord, chrnumcelben, intdigidben, chrnumseriecert,
                   vchrrefcobranza, fechalimpago, pagocomision, comision, folioplataforma, vchrfirma, chrestatusenvio
              INTO cCveRastreo, cCuenta, mMonto, dFechaVal, cCtaBenef, cNumCte, cCtaBenefEmail, cTpoCtaBenefMsg, cTransacc, cFolioSuc,
                   wchrconceptopago2, wintrefnumerica, wcvecesifbcoord, wintcvetipoctaord, wvchrcuentaord, wvchrnombreord, wintcvetipoctabene, wvchrnombrebenef,
                   wchrtipopago, wchridmjc, wchrfchmjc, wchrnumcelord, wintdigidord, wchrnumcelben, wintdigidben, wchrnumseriecert,
                   wvchrrefcobranza, wchrfechalimpago, wintpagocomision, wvcomision, wchrfolioplataf, wvchrfirma, wchrstatus
              FROM tblabono 
             WHERE chrestatusenvio = pOrigen
             ORDER BY intnumserial
            
            BEGIN WORK;
            LET iAbierto = 1;
            
            LET iContador1 = iContador1 + 1;
            
            -- // DETERMINA LA COMISION
            LET wcomision = wvcomision;
            
            IF wchrtipopago IN('19', '20', '21', '22') THEN
                IF wcomision = 0.00 THEN
                   LET vcomision = '0.0';
                ELSE
                   LET vcomision = wcomision;
                END IF;
            ELSE
                LET vcomision = '0.00';
            END IF;
            
            LET wchrstatus = 'L';
            
            -- // GENERA CADENA A VALIDAR
            LET wcadena_val = '|'||TRIM(cCveRastreo)||'|'||TRIM(cCtaBenef)||'|'||mMonto||'|'||wintrefnumerica||'|'||TRIM(wchrconceptopago2)||'|'||TRIM(wvchrrefcobranza)||'|'||TRIM(wchrstatus)||
                              '|'||TRIM(wvchrcuentaord)||'|'||wintcvetipoctaord||'|'||TRIM(wchrtipopago)||'|'||TRIM(wchrnumcelord)||'|'||TRIM(wchrnumcelben)||'|'||wintdigidord||'|'||wintdigidben||'|'||TRIM(wchrfechalimpago)||
                              '|'||wcvecesifbcoord||'|'||wintpagocomision||'|'||TRIM(vcomision)||'|'||TRIM(wchrnumseriecert)||'|'||TRIM(wchrfolioplataf)||'|'||trim(wchridmjc)||'|'||trim(wchrfchmjc)||
                              '|'||TRIM(wvchrnombreord)||'|'||wintcvetipoctabene||'|'||TRIM(wvchrnombrebenef)||'|';
              
            EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(wvchrfirma), 21)
            INTO codretfirma;

            IF codretfirma <> 0 THEN
                LET wcadena_val = '';
                LET wcadena_val = '|'||TRIM(cCveRastreo)||'|'||TRIM(cCtaBenef)||'|'||mMonto||'|'||wintrefnumerica||'|'||TRIM(wchrconceptopago2)||'|'||TRIM(wvchrrefcobranza)||'|'||TRIM(wchrstatus)||
                                  '|'||TRIM(wvchrcuentaord)||'|'||wintcvetipoctaord||'|'||TRIM(wchrtipopago)||'|'||TRIM(wchrnumcelord)||'|'||TRIM(wchrnumcelben)||'|'||wintdigidord||'|'||wintdigidben||'|'||TRIM(wchrfechalimpago)||
                                  '|'||wcvecesifbcoord||'|'||wintpagocomision||'|'||TRIM(vcomision)||'|'||TRIM(wchrnumseriecert)||'|'||TRIM(wchrfolioplataf)||'|'||trim(wchridmjc)||'|'||trim(wchrfchmjc)||
                                  '|'||TRIM(wvchrnombreord)||'|'||wintcvetipoctabene||'|'||TRIM(wvchrnombrebenef)||'|';
              
                EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(wvchrfirma), 21)
                INTO codretfirma;
            END IF;
            
            IF codretfirma <> 0 THEN
                LET wcadena_val = '';
                LET wcadena_val = '|'||TRIM(cCveRastreo)||'|'||TRIM(cCtaBenef)||'|'||mMonto||'|'||wintrefnumerica||'|'||TRIM(wchrconceptopago2)||'|'||TRIM(wvchrrefcobranza)||'|'||TRIM(wchrstatus)||
                                  '|'||TRIM(wvchrcuentaord)||'|'||wintcvetipoctaord||'|'||TRIM(wchrtipopago)||'|'||TRIM(wchrnumcelord)||'|'||TRIM(wchrnumcelben)||'|'||wintdigidord||'|'||wintdigidben||'|'||TRIM(wchrfechalimpago)||
                                  '|'||wcvecesifbcoord||'|'||wintpagocomision||'|'||TRIM(vcomision2)||'|'||TRIM(wchrnumseriecert)||'|'||TRIM(wchrfolioplataf)||'|'||trim(wchridmjc)||'|'||trim(wchrfchmjc)||
                                  '|'||TRIM(wvchrnombreord)||'|'||wintcvetipoctabene||'|'||TRIM(wvchrnombrebenef)||'|';

              
                EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(wvchrfirma), 21)
                INTO codretfirma;
            END IF;

            IF codretfirma <> 0 THEN
                LET wcadena_val = '';
                LET wcadena_val = '|'||TRIM(cCveRastreo)||'|'||TRIM(cCtaBenef)||'|'||mMonto||'|'||wintrefnumerica||'|'||TRIM(wchrconceptopago2)||'|'||TRIM(wvchrrefcobranza)||'|'||TRIM(wchrstatus)||
                                  '|'||TRIM(wvchrcuentaord)||'|'||wintcvetipoctaord||'|'||TRIM(wchrtipopago)||'|'||TRIM(wchrnumcelord)||'|'||TRIM(wchrnumcelben)||'|'||wintdigidord||'|'||wintdigidben||'|'||TRIM(wchrfechalimpago)||
                                  '|'||wcvecesifbcoord||'|'||wintpagocomision||'|'||TRIM(vcomision3)||'|'||TRIM(wchrnumseriecert)||'|'||TRIM(wchrfolioplataf)||'|'||trim(wchridmjc)||'|'||trim(wchrfchmjc)||
                                  '|'||TRIM(wvchrnombreord)||'|'||wintcvetipoctabene||'|'||TRIM(wvchrnombrebenef)||'|';

              
                EXECUTE FUNCTION "informix".syn_verify(TRIM(wcadena_val), TRIM(wvchrfirma), 21)
                INTO codretfirma;
            END IF;	
            
            IF codretfirma = 0 THEN
            
                SELECT COUNT(*)
                  INTO iExiste
                  FROM bdicheq:sc_movdia
                 WHERE transacc IN('0273','0276','0277','0446')
                   AND fech_val = dFechaVal
                   AND cancelad <> 'S'
                   AND referencia = cCveRastreo
                   AND cuenta = cCuenta;
                   
                IF iExiste > 0 THEN
                    UPDATE tblabono
                       SET chrestatusenvio = 'M'
                     WHERE vchrclaverastreo = cCveRastreo
                       AND vchrcuentabenef = cCtaBenef
                       AND mnyimporte = mMonto
                       AND vchrfoliosuc = cFolioSuc;
                     
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                        LET iContador2 = iContador2 + 1;
                    END IF;
                    
                    COMMIT WORK;
                    LET iAbierto = 0;
                    
                    CONTINUE FOREACH;
                END IF;
                
                IF cFolioSuc is null OR cFolioSuc = '' THEN
                    CALL sp_obtfoliosuc('tranSPEI')
                    RETURNING cCodRet4, iSerialFolio, cFolioSuc;

                    IF cCodRet4 <> '000' THEN
                        LET cFolioSuc = 'SPEI'||dFechaVal;
                    END IF;
                END IF;
                
                EXECUTE PROCEDURE bdicheq:abono_ref('001', '9201', 'tranSPEI', cTransacc, '0000', cFolioSuc, cCuenta, 0, mMonto, mMonto, 0, 0, 0, '01', cCveRastreo, '', '')
                INTO cCodRet5;
                
                LET iCodRet = cCodRet5::INT;
                
                IF cCodRet5 = '000' THEN
                    UPDATE tblabono
                       SET chrestatusenvio = 'L'
                     WHERE vchrclaverastreo = cCveRastreo
                       AND vchrcuentabenef = cCtaBenef
                       AND mnyimporte = mMonto
                       AND vchrfoliosuc = cFolioSuc;
                     
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                        LET iContador2 = iContador2 + 1;
                    END IF;
                    
                    IF wchrtipopago IN('19', '20', '21', '22') THEN
                        CALL spei_recerrorescodi('0', ' ', 'b', wchridmjc, wchrfchmjc, wchrconceptopago2, mMonto, wtimestamp, cCveRastreo, wintrefnumerica, 
                                                 wchrnumcelord, wintdigidord, wcvecesifbcoord, wintcvetipoctaord, wvchrcuentaord, wvchrnombreord, wchrnumcelben,
                                                 wintdigidben, '40137', wintcvetipoctabene, cCtaBenef, wvchrnombrebenef, wchrnumseriecert) 
                        RETURNING wvchrcodretcodi;
                    END IF;
                    
                    LET cCtaBenefMsg = SUBSTR(cCtaBenef,(LENGTH(cCtaBenef)-3),4);
                    
                    -- // EMAIL
                     /*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                     ('1', 'SPEI_TRREC', 'SPEI_TRREC', cNumCte, '', '', '1', '', cCtaBenefEmail, mMonto, cCveRastreo, cTpoCtaBenefMsg, '', '', '', '', '', '', '', 1, 0, 0, 0, 0, current, '')
                     INTO cCodRet6;*/
					 
					 -- // EMAIL // SMS
                     EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                     ('1', 'SPEI_TRREC', 'SPEI_TRREC', cNumCte, '', '', '1', cCtaBenefMsg, cCtaBenefEmail, mMonto, cCveRastreo, cTpoCtaBenefMsg, '', '', '', '', '', '', '', 1, 0, 0, 0, 0, current, '')
                     INTO cCodRet6;

                    -- // SMS
                     /*EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
                     ('2', 'SPEI_SMREC', 'SPEI_SMREC', cNumCte, '', '', '1', cCtaBenefMsg, mMonto, '', '', '', '', '', '', '', '', '', '', 1, 0, 0, 0, 0, current, '')
                     INTO cCodRet7;*/
                     
                ELIF ( cCodRet5 <> '000' AND iCodRet < 0 ) THEN
                    
                    UPDATE tblabono
                       SET chrestatusenvio = 'S'
                     WHERE vchrclaverastreo = cCveRastreo
                       AND vchrcuentabenef = cCtaBenef
                       AND mnyimporte = mMonto
                       AND vchrfoliosuc = cFolioSuc;
                     
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                        LET iContador2 = iContador2 + 1;
                    END IF;
                    
                ELIF ( cCodRet5 <> '000' AND iCodRet > 0 ) THEN
                    
                    UPDATE tblabono
                       SET chrestatusenvio = 'X'
                     WHERE vchrclaverastreo = cCveRastreo
                       AND vchrcuentabenef = cCtaBenef
                       AND mnyimporte = mMonto
                       AND vchrfoliosuc = cFolioSuc;
                     
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                        LET iContador2 = iContador2 + 1;
                    END IF;
                     
                    IF wchrtipopago IN('19', '20', '21', '22') THEN
                        CALL spei_recerrorescodi('16', 'NO SE PUDO REALIZAR EL ABONO CODI', 'b', wchridmjc, wchrfchmjc, wchrconceptopago2 ,mMonto, wtimestamp, cCveRastreo, wintrefnumerica,
                                                 wchrnumcelord, wintdigidord, wcvecesifbcoord, wintcvetipoctaord, wvchrcuentaord, wvchrnombreord, wchrnumcelben,
                                                 wintdigidben, '40137', wintcvetipoctabene, cCtaBenef, wvchrnombrebenef, wchrnumseriecert) 
                        RETURNING wvchrcodretcodi;
                    END IF;
                END IF;
            ELSE
                UPDATE tblabono
                   SET chrestatusenvio = 'F'
                 WHERE vchrclaverastreo = cCveRastreo
                   AND vchrcuentabenef = cCtaBenef
                   AND mnyimporte = mMonto
                   AND vchrfoliosuc = cFolioSuc;
                 
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET iContador2 = iContador2 + 1;
                END IF;
                 
                IF wchrtipopago IN('19', '20', '21', '22') THEN
                    CALL spei_recerrorescodi('16', 'NO SE PUDO REALIZAR EL ABONO CODI', 'b', wchridmjc, wchrfchmjc, wchrconceptopago2 ,mMonto, wtimestamp, cCveRastreo, wintrefnumerica,
                                             wchrnumcelord, wintdigidord, wcvecesifbcoord, wintcvetipoctaord, wvchrcuentaord, wvchrnombreord, wchrnumcelben,
                                             wintdigidben, '40137', wintcvetipoctabene, cCtaBenef, wvchrnombrebenef, wchrnumseriecert) 
                    RETURNING wvchrcodretcodi;
                END IF;
            END IF;
                
            COMMIT WORK;
            LET iAbierto = 0;
            
            LET cCveRastreo     = '';
            LET cCuenta         = '';
            LET mMonto          = 0.00;
            LET dFechaVal       = '';
            LET cCtaBenef       = '';
            LET cNumCte         = '';
            LET cCtaBenefEmail  = '';
            LET cTpoCtaBenefMsg = '';
            LET cTransacc       = '';
            LET iSerialFolio    = 0;
            LET cFolioSuc       = '';
            LET iExiste         = 0;
            LET cCtaBenefMsg    = '';
            LET iCodRet         = 0;
            LET iVueltas        = 0;
            LET cCodRet4        = '';
            LET cCodRet5        = '';
            LET cCodRet6        = '';
            LET cCodRet7        = '';
            
            LET wchrconceptopago2  = '';
            LET wintrefnumerica    = 0;
            LET wcvecesifbcoord    = 0;
            LET wintcvetipoctaord  = 0;
            LET wvchrcuentaord     = '';
            LET wvchrnombreord     = '';
            LET wintcvetipoctabene = 0;
            LET wvchrnombrebenef   = '';
            LET wchrtipopago       = '';
            LET wchridmjc          = '';
            LET wchrfchmjc         = '';
            LET wchrnumcelord      = '';
            LET wintdigidord       = 0;
            LET wchrnumcelben      = '';
            LET wintdigidben       = 0;
            LET wchrnumseriecert   = '';
            LET wvchrcodretcodi    = '';
            
            LET wcadena_val      = '';
            LET wvchrrefcobranza = '';
            LET wchrfechalimpago = '';
            LET wintpagocomision = '';
            LET wvcomision       = 0.00;
            LET vcomision        = '';
            LET vcomision2       = '0.00';
            LET vcomision3       = '0';
            LET wchrfolioplataf  = '';
            LET wvchrfirma       = '';
            LET codretfirma      = 0;
            LET wcomision        = 0.00;
        END FOREACH;
            
        UPDATE tblctrlproceso 
           SET chrstatus = '0' 
         WHERE intcveproceso = 18;
        
    ELSE
    
        LET cCodRet1 = '003';
        RETURN cCodRet1, iContador1, iContador2;
        
    END IF;
    
    END; 
    
    RETURN cCodRet1, iContador1, iContador2;
    
END PROCEDURE;