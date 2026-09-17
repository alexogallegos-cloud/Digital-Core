CREATE PROCEDURE "informix".sp_repchequesipab_temp_esp2( pNumCliente  CHAR(20), 
                                                    pFechaIni    DATE, 
                                                    pFechaFin    DATE, 
                                                    pPorcRetSuj  DECIMAL(9,6), 
                                                    pAniobase    INTEGER,
                                                    pBaseExenta  MONEY(18,2),
                                                    pTipoPersona CHAR(1) ) 
RETURNING CHAR(5);
    
    DEFINE cRegFiscal, cOperArit, cTasaVar, cRangoFecha, cStatusCta CHAR(1);
    DEFINE cTpoCuenta, cMoneda, cCodRetCorte, cMotivoBloq CHAR(2);
    DEFINE cInstbase, cSobretasa CHAR(3); 
    DEFINE cNumProducto, cSucursal CHAR(4);
    DEFINE cCodRet, cCodRet2, cCodRetSdos CHAR(5); 
    DEFINE cFechaCorte, cFechaAlta, cFechaSigcorte CHAR(8);
    DEFINE cTasa CHAR(10);
    DEFINE cNumCuenta CHAR(20); 
    DEFINE cProducto, cCodRet3, cDesErr CHAR(50);
    DEFINE dtFechaCorte, dtFechaSigcorte, dtFecAlta, dtFechaAlta, dtFechaCorte2, dtFechaCorte3, dtFechaISR DATE;
    DEFINE iTipoTasa, iAnioMes, iMoneda, iPlazo, iDiasISR, iCtaBloqueada SMALLINT;
    DEFINE iCtaInversion, iSqlErr, iSamErr, iDias_Ini, iDiasProyec INTEGER;
    DEFINE dTasa, dPorcentaje, dPuntos DECIMAL(9,6); 
    DEFINE dImp_isr DECIMAL(14,6); 
    DEFINE mInt_al_Inicio, mBase_gravable, mInt_Proyec, mSdo_Proyec, dImp_Isr_Ini, mSdo_Neto MONEY(18,2); 
    DEFINE mSdo_Prom_Ini, mSdo_Fin, dImp_Isr_Fin, mSdo_Ini, mSdo_Prom_Fin, mSdo_Promedio, mSdo_31, mInt_31 MONEY(18,2); 
    
    LET cRegFiscal = 'N'; LET cOperArit = NULL; LET cTasaVar  = ''; LET cRangoFecha  = ''; LET cStatusCta = '';
    LET cTpoCuenta = 'CI'; LET cMoneda = ''; LET cCodRetCorte =  ''; LET cMotivoBloq = '';
    LET cInstbase = NULL; LET cSobretasa = NULL; 
    LET cNumProducto = ''; LET cSucursal = ''; 
    LET cCodRet = '000'; LET cCodRet2 = ''; LET iPlazo = NULL; LET cCodRetSdos = '';
    LET cFechaCorte = ''; LET cFechaAlta = ''; LET cFechaSigcorte = ''; 
    LET cTasa = ''; 
    LET cNumCuenta = '';
    LET cProducto = ''; LET cCodRet3 = ''; LET cDesErr = ''; 
    LET dtFechaCorte = ''; LET dtFechaSigcorte =  ''; LET dtFecAlta = ''; LET dtFechaAlta = ''; LET dtFechaCorte2 = ''; LET dtFechaCorte3 = '';
    LET iTipoTasa = 1; LET iAnioMes = 0; LET iMoneda = 0;
    LET iCtaInversion = 0; LET iSqlErr = 0; LET iSamErr = 0; LET iDias_Ini = 0; LET iDiasProyec = 0; 
    LET dTasa = 0; LET dPorcentaje = 0; LET dPuntos = 0; 
    LET dImp_isr = 0; 
    LET mInt_al_Inicio = 0; LET mBase_gravable = 0; LET mInt_Proyec = 0; LET mSdo_Proyec = 0; LET dImp_Isr_Ini = 0;
    LET mSdo_Prom_Ini = 0; LET mSdo_Fin = 0; LET dImp_Isr_Fin = 0; LET mSdo_Ini = 0; LET mSdo_Prom_Fin = 0; LET mSdo_Promedio = 0; LET mSdo_31 = 0.00; LET mInt_31 = 0.00;         
    LET dtFechaISR = ''; LET iDiasISR = 0; LET mSdo_Neto = 0; LET iCtaBloqueada = 0; 
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_repchequesipab_temp_esp2.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_repchequesipab_temp_esp2.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // NUMERO DE DIAS DE LA PROYECCION
    LET iDiasProyec = (pFechaFin - pFechaIni);
    
    -- // FOREACH CUENTAS POR CLIENTE
    FOREACH
        SELECT tab.cuenta, tab.producto, tab.sucursal, noc.fecha_alta, pro.nombre nombre_prod, pro.divisa moneda, pro.tasa, pro.paga_dividendo
          INTO cNumCuenta, cNumProducto, cSucursal, dtFecAlta, cproducto, cMoneda, ctasa, cTasaVar
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc,
               bdicheq:sc_producto pro,
               bdinteg:tab_ipab_pba_pums_esp tab
         WHERE mae.num_cte = pNumCliente
           AND noc.cuenta = mae.cuenta
           AND pro.producto = mae.producto
           AND tab.cuenta = mae.cuenta
        
        IF dtFecAlta < pFechaIni THEN
            SELECT COUNT(*)
              INTO iAnioMes
              FROM bdicheq:sc_maehis
             WHERE empresa = '001'
               AND cuenta = cNumCuenta
               AND fechafin <= pFechaIni; 
            
            IF iAnioMes = 0 THEN
                -- // SALDO SIN INTERESES A LA FECHA INICIAL DE LA PROYECCION
                EXECUTE PROCEDURE bdinteg:sp_capintafecha_ipab_esp(cNumCuenta, pFechaIni) 
                INTO cCodRetSdos, mSdo_Ini, mInt_al_Inicio;
                
                IF mSdo_Ini < 0 THEN
                    LET mSdo_Ini = 0;
                    LET mInt_al_Inicio = 0;
                END IF;
                
                LET iDias_Ini = (pFechaIni - dtFecAlta);

                -- // TIPO DE TASA DEL PRODUCTO
                SELECT rangofecha
                  INTO cRangoFecha
                  FROM bdinteg:si_tiptasa
                 WHERE empresa = '001'
                   AND tasa = ctasa;

                -- // VALOR DE LA TASA
                IF cTasaVar = 'N' THEN
                    IF cRangoFecha = 'F' THEN
                        SELECT NVL(valor,0)
                          INTO dTasa
                          FROM bdinteg:si_fechavalor
                         WHERE empresa = '001'
                           AND tasa = ctasa
                           AND fecha = ( SELECT max(fecha) FROM bdinteg:si_fechavalor WHERE empresa = '001' AND tasa = ctasa AND fecha <= pFechaIni );
                    ELIF cRangoFecha = 'R' THEN
                        IF pTipoPersona = 'F' THEN
                            SELECT valorperfis, sobretasafis
                              INTO dPorcentaje, dPuntos
                              FROM bdinteg:si_tasavlor
                             WHERE empresa = '001'
                               AND tasa = ctasa
                               AND rangomin <= mSdo_Ini
                               AND rangomax >= mSdo_Ini;
                        ELSE
                            SELECT valorpermor, sobretasamor
                              INTO dPorcentaje, dPuntos
                              FROM bdinteg:si_tasavlor
                             WHERE empresa = '001'
                               AND tasa = ctasa
                               AND rangomin <= mSdo_Ini
                               AND rangomax >= mSdo_Ini;
                        END IF;
                        LET dTasa = dPorcentaje + dPuntos;
                    END IF;
                ELSE
                    SELECT NVL(valor_tasa,0)
                      INTO dTasa
                      FROM bdinteg:si_tasa_mes
                     WHERE tasa = ctasa
                       AND mes = 1
                       AND tipo_tasa = 'M'
                       AND fecha = ( SELECT MAX(fecha) FROM bdinteg:si_tasa_mes WHERE tasa = ctasa AND mes = 1 AND tipo_tasa = 'M' AND fecha <= pFechaIni );
                END IF;
                
                IF mSdo_Ini >= 0 THEN
                    -- // CALCULA EL SALDO CON INTERESES A LA FECHA INICIAL DE LA PROYECCION
                    LET mSdo_Prom_Ini = mSdo_Ini;
                    LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                    LET dImp_Isr_Ini = 0.00;
                    LET mSdo_Fin = mSdo_Fin - dImp_Isr_Ini;
                    
                    -- // CALCULA EL SALDO CON INTERESES A LA FECHA FINAL DE PROYECCION
                    LET mSdo_Prom_Fin = mSdo_Fin;
                    LET mInt_Proyec = (mSdo_Prom_Fin * (dTasa/100) * iDiasProyec) / 360;
                    LET mSdo_Proyec = mSdo_Fin + mInt_Proyec;
                    LET mBase_gravable = mSdo_Prom_Fin - pBaseExenta;

                    IF pPorcRetSuj <> 0 THEN
                        IF pTipoPersona = 'F' THEN
                            IF mBase_gravable > 0 THEN
                                LET dImp_Isr_Fin = (mBase_gravable * (pPorcRetSuj/100)) * iDiasProyec / pAniobase;
                            ELSE
                                LET dImp_Isr_Fin = 0;
                            END IF;
                        ELSE
                            LET dImp_Isr_Fin = (mSdo_Prom_Fin * (pPorcRetSuj/100)) * iDiasProyec / pAniobase;
                        END IF;
                    ELSE
                        LET dImp_Isr_Fin = 0;
                    END IF;

                    LET mSdo_Promedio = mSdo_Prom_Fin;
                    LET mSdo_Proyec = mSdo_Proyec - dImp_Isr_Fin;
                ELSE
                    LET mSdo_Prom_Ini = mSdo_Ini;
                    LET mInt_al_Inicio = 0.00;
                    LET dImp_Isr_Ini = 0.00;
                    LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                    LET mSdo_Prom_Fin = mSdo_Fin;
                    LET mInt_Proyec = 0.00;
                    LET dImp_Isr_Fin = 0.00;
                    LET mSdo_Promedio = mSdo_Prom_Fin;
                    LET mSdo_Proyec = ( mSdo_Fin + mInt_Proyec ) - dImp_Isr_Fin;
                END IF;

                -- // OBTIENE LA PROXIMA FECHA DE CORTE
                LET dtFechaAlta = dtFecAlta - 1;
                
                EXECUTE PROCEDURE bdinteg:sp_cortesig(dtFechaAlta, 1) 
                INTO cCodRetCorte,dtFechaSigcorte;
                
                LET dtFechaCorte = dtFechaSigcorte;
            ELSE
                -- // OBTIENE INFORMACON DEL ULTIMO MAEHIS
                SELECT NVL(his.tasabruta, 0), his.fechafin
                  INTO dTasa, dtFechaCorte
                  FROM bdicheq:sc_maehis his
                 WHERE his.empresa = '001'
                   AND his.cuenta = cNumCuenta
                   AND his.aniomes = (SELECT MAX(aniomes) FROM bdicheq:sc_maehis WHERE empresa = '001' AND cuenta = cNumCuenta AND fechafin <= pFechaIni);
                                         
                LET dTasa = dTasa * 100;
                
                LET iDias_Ini = (pFechaIni - dtFechaCorte);

                IF iDias_Ini > 0 THEN
                    -- // OBTIENE EL SALDO SIN INTERESES A LA FECHA INICIAL DE LA PROYECCION
                    EXECUTE PROCEDURE bdinteg:sp_capintafecha_ipab_esp(cNumCuenta, pFechaIni) 
                    INTO cCodRetSdos, mSdo_Ini, mInt_al_Inicio;
                    
                    IF mSdo_Ini < 0 THEN
                        LET mSdo_Ini = 0;
                        LET mInt_al_Inicio = 0;
                    END IF;
                    
                    IF mSdo_Ini >= 0 THEN
                        -- // OBTIENE EL SALDO PROMEDIO DE LA FECHA DE CORTE A LA FECHA INICIAL DE LA PROYECCION
                        LET dtFechaCorte2 = dtFechaCorte + 1;
                        LET mSdo_Prom_Ini = mSdo_Ini;

                        -- // CALCULA EL SALDO CON INTERESES A AL FECHA INICIAL DE LA PROYECCION
                        LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                        LET dImp_Isr_Ini = 0.00;
                        LET mSdo_Fin = mSdo_Fin - dImp_Isr_Ini;
                        
                        -- // CALCULA EL SALDO CON INTERESES A LA FECHA FINAL DE LA PROYECCION
                        LET mSdo_Prom_Fin = mSdo_Fin;
                        LET mInt_Proyec = (mSdo_Prom_Fin * (dTasa/100) * iDiasProyec) / 360;
                        LET mSdo_Proyec = mSdo_Fin + mInt_Proyec;
                        LET mBase_gravable = mSdo_Prom_Fin - pBaseExenta;

                        IF pPorcRetSuj <> 0 THEN
                            IF pTipoPersona = 'F' THEN
                                IF mBase_gravable > 0 THEN
                                    LET dImp_Isr_Fin = (mBase_gravable * (pPorcRetSuj/100)) * iDiasProyec / pAniobase;
                                ELSE
                                    LET dImp_Isr_Fin = 0;
                                END IF;
                            ELSE
                                LET dImp_Isr_Fin = (mSdo_Prom_Fin * (pPorcRetSuj/100)) * iDiasProyec / pAniobase;
                            END IF;
                        ELSE
                            LET dImp_Isr_Fin = 0;
                        END IF;

                        LET mSdo_Promedio = mSdo_Prom_Fin;
                        LET mSdo_Proyec = mSdo_Proyec - dImp_Isr_Fin;
                    ELSE
                        LET mSdo_Prom_Ini = mSdo_Ini;
                        LET mInt_al_Inicio = 0.00;
                        LET dImp_Isr_Ini = 0.00;
                        LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                        LET mSdo_Prom_Fin = mSdo_Fin;
                        LET mInt_Proyec = 0.00;
                        LET dImp_Isr_Fin = 0.00;
                        LET mSdo_Promedio = mSdo_Prom_Fin;
                        LET mSdo_Proyec = ( mSdo_Fin + mInt_Proyec ) - dImp_Isr_Fin;
                    END IF;
                ELIF iDias_Ini = 0 THEN
                    -- // OBTIENE EL SALDO DE LA CUENTA
                    EXECUTE PROCEDURE bdinteg:sp_capintafecha_ipab_esp(cNumCuenta, pFechaIni) 
                    INTO cCodRetSdos, mSdo_Ini, mInt_al_Inicio;
                    
                    IF mSdo_Ini < 0 THEN
                        LET mSdo_Ini = 0;
                        LET mInt_al_Inicio = 0;
                    END IF;
                    
                    IF mSdo_Ini >= 0 THEN
                        LET mSdo_Prom_Ini = 0.00;
                        LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                        LET dImp_Isr_Ini = 0.00;
                        LET mSdo_Fin = mSdo_Fin - dImp_Isr_Ini;

                        -- // CALCULA EL SALDO CON INTERESES A LA FECHA FINAL DE LA PROYECCION
                        LET mSdo_Prom_Fin = mSdo_Fin;
                        LET mInt_Proyec = (mSdo_Prom_Fin * (dTasa/100) * iDiasProyec) / 360;
                        LET mSdo_Proyec = mSdo_Fin + mInt_Proyec;
                        LET mBase_gravable = mSdo_Prom_Fin - pBaseExenta;

                        IF pPorcRetSuj <> 0 THEN
                            IF pTipoPersona = 'F' THEN
                                IF mBase_gravable > 0 THEN
                                    LET dImp_Isr_Fin = (mBase_gravable * (pPorcRetSuj/100)) * iDiasProyec / pAniobase;
                                ELSE
                                    LET dImp_Isr_Fin = 0;
                                END IF;
                            ELSE
                                LET dImp_Isr_Fin = (mSdo_Prom_Fin * (pPorcRetSuj/100)) * iDiasProyec / pAniobase;
                            END IF;
                        ELSE
                            LET dImp_Isr_Fin = 0;
                        END IF;

                        LET mSdo_Promedio = mSdo_Prom_Fin;
                        LET mSdo_Proyec = mSdo_Proyec - dImp_Isr_Fin;
                    ELSE
                        LET mSdo_Prom_Ini = mSdo_Ini;
                        LET mInt_al_Inicio = 0.00;
                        LET dImp_Isr_Ini = 0.00;
                        LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                        LET mSdo_Prom_Fin = mSdo_Fin;
                        LET mInt_Proyec = 0.00;
                        LET dImp_Isr_Fin = 0.00;
                        LET mSdo_Promedio = mSdo_Prom_Fin;
                        LET mSdo_Proyec = ( mSdo_Fin + mInt_Proyec ) - dImp_Isr_Fin;
                    END IF;
                END IF;

                -- // OBTIENE LA PROXIMA FECHA DE CORTE
                EXECUTE PROCEDURE bdinteg:sp_CorteSig(dtFechaCorte, 1) 
                INTO cCodRetCorte, dtFechaSigcorte;
            END IF;
        ELIF dtFecAlta = pFechaIni THEN
            -- // OBTIENE EL SALDO DE LA CUENTA
            EXECUTE PROCEDURE bdinteg:sp_capintafecha_ipab_esp(cNumCuenta, pFechaIni) 
            INTO cCodRetSdos, mSdo_Ini, mInt_al_Inicio;
            
            IF mSdo_Ini < 0 THEN
                LET mSdo_Ini = 0;
                LET mInt_al_Inicio = 0;
            END IF;
            
            LET iDias_Ini = 0;
            
            -- // OBTIENE EL TIPO DE TASA DEL PRODUCTO
            SELECT rangofecha
              INTO cRangoFecha
              FROM bdinteg:si_tiptasa
             WHERE empresa = '001'
               AND tasa = ctasa;

            -- // OBTIENE EL VALOR DE LA TASA
            IF cTasaVar = 'N' THEN
                IF cRangoFecha = 'F' THEN
                    SELECT NVL(valor,0)
                      INTO dTasa
                      FROM bdinteg:si_fechavalor
                     WHERE empresa = '001'
                       AND tasa = ctasa
                       AND fecha = ( SELECT max(fecha) FROM bdinteg:si_fechavalor WHERE empresa = '001' AND tasa = ctasa AND fecha <= pFechaIni );
                ELIF cRangoFecha = 'R' THEN
                    IF pTipoPersona = 'F' THEN
                        SELECT valorperfis, sobretasafis
                          INTO dPorcentaje, dPuntos
                          FROM bdinteg:si_tasavlor
                         WHERE empresa = '001'
                           AND tasa = ctasa
                           AND rangomin <= mSdo_Ini
                           AND rangomax >= mSdo_Ini;
                    ELSE
                        SELECT valorpermor, sobretasamor
                          INTO dPorcentaje, dPuntos
                          FROM bdinteg:si_tasavlor
                         WHERE empresa = '001'
                           AND tasa = ctasa
                           AND rangomin <= mSdo_Ini
                           AND rangomax >= mSdo_Ini;
                    END IF;
                    LET dTasa = dPorcentaje + dPuntos;
                END IF;
            ELSE
                SELECT NVL(valor_tasa,0)
                  INTO dTasa
                  FROM bdinteg:si_tasa_mes
                 WHERE tasa = ctasa
                   AND mes = 1
                   AND tipo_tasa = 'M'
                   AND fecha = ( SELECT MAX(fecha) FROM bdinteg:si_tasa_mes WHERE tasa = ctasa AND mes = 1 AND tipo_tasa = 'M' AND fecha <= pFechaIni );
            END IF;
            
            IF mSdo_Ini >= 0 THEN
                -- // CALCULA EL SALDO CON INTERESES A LA FECHA INICIAL DE LA PROYECCION
                LET mSdo_Prom_Ini = 0.00;
                LET dImp_isr_ini = 0.00;
                LET mSdo_Fin = mSdo_Ini;
                LET mSdo_Prom_Fin = mSdo_Fin;

                -- // CALCULA EL SALDO CON INTERESES A LA FECHA FINAL DE LA PROYECCION
                LET mInt_Proyec = (mSdo_Prom_Fin * (dTasa/100) * iDiasProyec) / 360;
                LET mSdo_Proyec = mSdo_Fin + mInt_Proyec;
                LET mBase_gravable = mSdo_Prom_Fin - pBaseExenta;

                IF pPorcRetSuj <> 0 THEN
                    IF pTipoPersona = 'F' THEN
                        IF mBase_gravable > 0 THEN
                            LET dImp_Isr_Fin = (mBase_gravable * (pPorcRetSuj/100)) * iDiasProyec / pAniobase;
                        ELSE
                            LET dImp_Isr_Fin = 0;
                        END IF;
                    ELSE
                        LET dImp_Isr_Fin = (mSdo_Prom_Fin * (pPorcRetSuj/100)) * iDiasProyec / pAniobase;
                    END IF;
                ELSE
                    LET dImp_Isr_Fin = 0;
                END IF;

                LET mSdo_Promedio = mSdo_Prom_Fin;
                LET mSdo_Proyec = mSdo_Proyec - dImp_Isr_Fin;
            ELSE
                LET mSdo_Prom_Ini = mSdo_Ini;
                LET mInt_al_Inicio = 0.00;
                LET dImp_Isr_Ini = 0.00;
                LET mSdo_Fin = mSdo_Ini + mInt_al_Inicio;
                LET mSdo_Prom_Fin = mSdo_Fin;
                LET mInt_Proyec = 0.00;
                LET dImp_Isr_Fin = 0.00;
                LET mSdo_Promedio = mSdo_Prom_Fin;
                LET mSdo_Proyec = ( mSdo_Fin + mInt_Proyec ) - dImp_Isr_Fin;
            END IF;

            -- // OBTIENE LA PROXIMA FECHA DE CORTE
            LET dtFechaAlta = dtFecAlta - 1;
            
            EXECUTE PROCEDURE bdinteg:sp_CorteSig(dtFechaAlta, 1) 
            INTO cCodRetCorte, dtFechaSigcorte;
            
            LET dtFechaCorte = dtFechaSigcorte;
        END IF;
        
        IF pFechaFin = pFechaIni THEN
            LET mSdo_Fin = 0.00;
            LET mSdo_Prom_Fin = 0.00;
            LET mInt_Proyec = 0.00;
            LET dImp_Isr_Fin = 0.00;
            LET mSdo_Proyec = mSdo_Ini + mInt_al_Inicio;
        END IF;
        
        LET iMoneda = cMoneda;
        LET cFechaCorte = TO_CHAR(dtFechaCorte, '%Y%m%d');
        --- LET cFechaAlta = TO_CHAR(dtFecAlta, '%Y%m%d');
        LET cFechaAlta = NULL;
        LET cFechaSigcorte = TO_CHAR(dtFechaSigcorte, '%Y%m%d');
        
        IF dtFechaCorte > pFechaIni THEN
            EXECUTE PROCEDURE bdinteg:sp_CorteSig(dtFechaCorte, -1) 
            INTO cCodRetCorte, dtFechaCorte3;
            
            IF dtFechaCorte3 < dtFecAlta THEN
                LET cFechaCorte = TO_CHAR(dtFecAlta, '%Y%m%d');
            ELSE
                LET cFechaCorte = TO_CHAR(dtFechaCorte3, '%Y%m%d');
            END IF;
        END IF;
        
        LET dtFechaISR = SUBSTR(cFechaCorte,5,2)||'/'||SUBSTR(cFechaCorte,7,2)||'/'||SUBSTR(cFechaCorte,1,4);
        LET iDiasISR = (pFechaFin - dtFechaISR);
        LET mBase_gravable = mSdo_Ini - pBaseExenta;

        IF pPorcRetSuj <> 0 THEN
            IF pTipoPersona = 'F' THEN
                IF mBase_gravable > 0 THEN
                    LET dImp_Isr_Ini = (mBase_gravable * (pPorcRetSuj/100)) * iDiasISR / pAniobase;
                ELSE
                    LET dImp_Isr_Ini = 0;
                END IF;
            ELSE
                LET dImp_Isr_Ini = (mSdo_Prom_Fin * (pPorcRetSuj/100)) * iDiasISR / pAniobase;
            END IF;
        ELSE
            LET dImp_Isr_Ini = 0;
        END IF;
        
        SELECT COUNT(*)
          INTO iCtaBloqueada
          FROM si_infctablq_ipab
         WHERE cuenta = cNumCuenta;
         
        IF iCtaBloqueada > 0 THEN
            LET cStatusCta = '3';
        ELSE
            LET cStatusCta = '1';
        END IF;
        
        IF dTasa is null THEN
            LET dTasa = 0.00;
        END IF;
        
        LET dPorcentaje = 0;
        
        LET mSdo_Neto = (( mSdo_Ini + mInt_al_Inicio ) - dImp_Isr_Ini );

        INSERT INTO si_infpattit_temp VALUES
        ( cNumCuenta, iCtaInversion, cNumProducto, cTpoCuenta, cRegFiscal, dPorcentaje, cSucursal, mSdo_Ini, mInt_al_Inicio, dImp_Isr_Ini, 0.00, mSdo_Neto, 
          iMoneda, cFechaCorte, cFechaAlta, iPlazo, iTipoTasa, dTasa, cInstbase, cSobretasa, cOperArit, cFechaSigcorte, mSdo_Promedio, iDias_Ini, mSdo_Ini, 
          mSdo_Prom_Ini, mInt_al_Inicio, dImp_Isr_Ini, iDiasProyec, mSdo_Fin, mSdo_Prom_Fin, mInt_Proyec, dImp_Isr_Fin, cStatusCta, cMotivoBloq );
        
        INSERT INTO si_ctaasotit_temp VALUES 
        ( cNumCuenta, iCtaInversion, pNumCliente, 100.00 );
        
        LET cNumCuenta = '';
        LET cNumProducto = '';
        LET cSucursal = '';
        LET dtFecAlta = '';
        LET cproducto = '';
        LET cMoneda = '';
        LET ctasa = '';
        LET cTasaVar = '';
        LET iAnioMes = 0;
        LET cCodRetSdos = '';
        LET mSdo_Ini = 0;
        LET mInt_al_Inicio = 0;
        LET iDias_Ini = 0;
        LET cRangoFecha = '';
        LET dTasa = 0;
        LET dPorcentaje = 0;
        LET dPuntos = 0;
        LET mSdo_Prom_Ini = 0;
        LET mSdo_Fin = 0;
        LET dImp_Isr_Ini = 0;
        LET mSdo_Prom_Fin = 0;
        LET mInt_Proyec = 0;
        LET mSdo_Proyec = 0;
        LET mBase_gravable = 0;
        LET dImp_Isr_Fin = 0;
        LET mSdo_Promedio = 0;
        LET dtFechaAlta = '';
        LET cCodRetCorte = '';
        LET dtFechaSigcorte = '';
        LET dtFechaCorte = '';
        LET dtFechaCorte2 = '';
        LET iMoneda = 0;
        LET cFechaCorte = '';
        LET cFechaAlta = '';
        LET cFechaSigcorte = '';
        LET dtFechaCorte3 = '';
        LET cStatusCta = '';
        LET cMotivoBloq = '';
        LET dtFechaISR = ''; 
        LET iDiasISR = 0; 
        LET mSdo_Neto = 0;
        LET iCtaBloqueada = 0;
    END FOREACH;
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;