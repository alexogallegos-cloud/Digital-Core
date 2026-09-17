CREATE PROCEDURE "informix".sp_consultmovschq_bpi(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro SMALLINT)
        RETURNING CHAR(5),DATE,CHAR(16),CHAR(40),CHAR(1),MONEY(14,2),MONEY(14,2),CHAR(40),CHAR(4),CHAR(30)

-------------------------------------------------------------------------------------------------------
-- Realiz?: Mauricio Le?n
-- Actividad: Se modificaron los parametros de retorno referencia y descripci?n
-- Solicit?: Mauricio Le?n
-- Fecha de Solicitud: 10/09/2008
-- Modific?: Arturo Cruz
-- Actividad: Se especializa el proceso de consulta y se incluye la consulta a la sc_mov_his_old
-- Modific?: Manuel Ramos Figueroa
-- Actividad: Se modifica para retornar el concepto de pago de transacciones SPEI
-- Fecha de Solicitud: 26/09/2012
-- Modific?: Bibiana Gaxiola
-- Actividad: Se modifica para consultar la bdispei:tblpago solo para pagos del mismo d?a y la bdispei:tblhistpago para pagos de otros dias y/o abonos
-- Fecha de Solicitud: 10/2012
-- Modific?:  Alek
-- Actividad: Se modifica para consultar la bdicheq:sc_movhis_old2 para que se pueda realizar la consulta de tres meses atr?s
-- Fecha de Solicitud: 03/2015

--Modifico:Berenice Noriega Guevara - BanCoppel - GM3 - Coordinaci?n Internet
--Actividad: Se modifica para que consulte la tabla bpi_bitacora y bpi_bitacora_historial
--Fecha: 10-2018-Septiembre
-------------------------------------------------------------------------------------------------------

        DEFINE vCodRet                                  CHAR(5);
        DEFINE vSqlErr, vIsamErr, iAux  INTEGER;
        DEFINE dFechaMov                                DATE;
        DEFINE cReferencia                              CHAR(30);
        DEFINE cTransacc                                CHAR(30);
        DEFINE xCuenta                          CHAR(20);
        DEFINE cDescripcion                             CHAR(50);
        DEFINE mRetiro,
                        mDeposito,
                        mSaldo,
                        mMonto                                  MONEY(14, 2);
        DEFINE cNaturaleza                              CHAR(1);
        DEFINE cFech_param                              CHAR(10);
        DEFINE cFech_param_ini                  CHAR(10);
        DEFINE cFech_param_old                  CHAR(10);
        DEFINE vFechaHoy                                DATE;
        DEFINE vTrans                                   CHAR(4);
        DEFINE cConceptoPago                    CHAR(40);
        DEFINE cCveEnvio                                CHAR(60);
        DEFINE cFolioSuc                                CHAR(16);
    DEFINE cDescripcionMovdescpos       CHAR(50);

        LET vCodRet =           "000";
        LET dFechaMov =         '01/01/1900';
        LET vFechaHoy  =        '01/01/1900';
        LET cReferencia =       "";
        LET cTransacc    =      "";
        LET cDescripcion =      "";
        LET cNaturaleza =       "";
        LET mSaldo =            0;
        LET mMonto =            0;
        LET pCuenta =           TRIM(pCuenta);
        LET vTrans =            "";
        LET cConceptoPago =     "";
        LET cCveEnvio =         "";
        LET cFolioSuc =         "";
    LET cDescripcionMovdescpos =        "";

        BEGIN
                ON EXCEPTION SET vSqlErr, vIsamErr
                        IF vSqlErr != 0 THEN
                                LET vCodRet = vSqlErr;

                                RETURN vCodRet, dFechaMov, TRIM(SUBSTRING(cReferencia FROM 1 FOR 16)), cDescripcion, cNaturaleza, mMonto, mSaldo, cConceptoPago, vTrans, cReferencia;
                        END IF;
                END EXCEPTION;

                --Set Debug File To '/informix/gaby/ArchivosOut/sp_consultmovschq_bpi.out';
                --Trace On;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                --Consulta el valor de fechas limite en tabla de parametros
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

                SELECT valor
                INTO cFech_param_old
                FROM bdicheq:"informix".sc_param
                WHERE empresa = pEmpresa
                AND codparam = 'FechaIniMovhisOld2';

                --Consulta fecha de sistema
                SELECT fecha_hoy
                INTO vFechaHoy
                FROM bdicheq:"informix".sc_fechas;

                SELECT  cuenta_clabe INTO xCuenta FROM bdicheq:sc_maechq
                WHERE empresa= pEmpresa AND cuenta=pCuenta;

                -- Obtiene movimientos del dia
                IF pFechaInicial = vFechaHoy AND pFechaFinal = vFechaHoy THEN
                        FOREACH
                                SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
                                        SKIP pRegistro FIRST 10
                                        num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                        mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                INTO
                                        iAux, dFechaMov, cReferencia, cTransacc, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans,cFolioSuc
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
                                        tr.sistema = "01"
                                        ORDER BY
                                        mm.fech_alt DESC,
                                        mm.num_serial DESC

                                IF NVL(TRIM(cReferencia),'') = ''  THEN
                                        LET cReferencia = cTransacc ;
                                END IF;

                                IF vTrans = '3333' THEN
                                        LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
                                ELIF vTrans = '0231' THEN
                                        LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
                                        LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
                                ELIF (vTrans = '3320' OR vTrans = '3321') THEN
                                        LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
                                        LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
                                END IF;

                                LET cConceptoPago =     "";

                                IF vTrans = '0274' OR vTrans = '0276' THEN

                                        SELECT vchrconceptopago2
                                        INTO cConceptoPago
                                        FROM bdispei:tblpago
                                        WHERE vchrcuentaord = xCuenta
                                        AND cReferencia = vchrclaverastreo;
                                END IF;

                                IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
                                        SELECT vchrconceptopago
                                        INTO cConceptoPago
                                        FROM bdispei:tblhistpago
                                        WHERE cReferencia = vchrclaverastreo
                                        AND pFechaInicial = dtfechavalor
                                        AND intcvetipopago <> 0;

                                END IF;

                                IF vTrans = '1134' THEN -- orden pago
                                        SELECT cgenerico5 --cgenerico5,
                                        into cCveEnvio
                                        FROM bdibpi:"informix".bpi_bitacora
                                        WHERE cuenta_origen = pCuenta
                                        and fecha_aplic = vFechaHoy
                                        and id_operacion = '1034'
                                        and folio = cFolioSuc;

                                        LET cReferencia = 'CVE' || " " ||TRIM(cCveEnvio);
                                END IF;

                                IF vTrans = '1135' THEN -- Comision
                                        LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 22) );
                                END IF;

                                IF vTrans = '1136' THEN -- Iva
                                        LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 26) );
                                END IF;

                IF (vTrans = '0813' or vTrans = '0830') THEN

                        SELECT NVL(TRIM(referencia),'')  INTO cDescripcionMovdescpos FROM bdicheq:sc_movdescpos WHERE cuenta = pCuenta AND  folio_suc = cFolioSuc;

                        IF cDescripcionMovdescpos  <> '' THEN
                            LET cReferencia = TRIM(cDescripcionMovdescpos);
                        END IF;
                 END IF;

                                RETURN vCodRet, dFechaMov, TRIM(SUBSTRING(cReferencia FROM 1 FOR 16)), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, cReferencia WITH RESUME;
                        END FOREACH;

                --Consulta de movimientos incluyendo la movhis y la movdia
                ELIF pFechaInicial >= cFech_param THEN
                        IF pFechaFinal = vFechaHoy THEN
                                FOREACH
                                        SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
                                                SKIP pRegistro FIRST 10
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        INTO
                                                iAux, dFechaMov, cReferencia, cTransacc, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans,cFolioSuc
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
                                                tr.sistema = "01"
                                        UNION
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)} num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
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
                                                tr.sistema = "01"
                                                ORDER BY
                                                mm.fech_alt DESC,
                                                mm.num_serial DESC

                                        IF NVL(TRIM(cReferencia),'') = ''  THEN
                                                LET cReferencia = cTransacc ;
                                        END IF;


                                        IF vTrans = '3333' THEN
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
                                        ELIF vTrans = '0231' THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
                                        ELIF (vTrans = '3320' OR vTrans = '3321') THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
                                        END IF;


                                        LET cConceptoPago =     "";

                                        IF vTrans = '0274' OR vTrans = '0276' THEN

                                                IF  dFechaMov = pFechaFinal THEN
                                                        SELECT vchrconceptopago2
                                                        INTO cConceptoPago
                                                        FROM bdispei:tblpago
                                                        WHERE vchrcuentaord = xCuenta
                                                        AND cReferencia = vchrclaverastreo;
                                                ELSE
                                                        SELECT vchrconceptopago2
                                                        INTO cConceptoPago
                                                        FROM bdispei:tblhistpago
                                                        WHERE vchrcuentaord = xCuenta
                                                        AND cReferencia = vchrclaverastreo;
                                                END IF;
                                        END IF;

                                        IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
                                                SELECT vchrconceptopago
                                                INTO cConceptoPago
                                                FROM bdispei:tblhistpago
                                                WHERE cReferencia = vchrclaverastreo
                                                AND dFechaMov = dtfechavalor
                                                AND intcvetipopago <> 0;
                                        END IF;

                                        IF vTrans = '1134' THEN -- orden pago
                                                IF  dFechaMov = pFechaFinal THEN
                                                        SELECT cgenerico5
                                                        into cCveEnvio
                                                        FROM bdibpi:"informix".bpi_bitacora
                                                        WHERE cuenta_origen = pCuenta
                                                        and fecha_aplic= vFechaHoy
                                                        and id_operacion = '1034'
                                                        and folio = cFolioSuc;
                                                ELSE

                                                        SELECT cgenerico5
                                                        into cCveEnvio
                                                        FROM bdibpi:"informix".bpi_bitacora_historial
                                                        WHERE cuenta_origen = pCuenta
                                                        and fecha_aplic BETWEEN pFechaInicial AND pFechaFinal
                                                        and fecha_aplic>= cFech_param
                                                        and id_operacion = '1034'
                                                        and folio = cFolioSuc;
                                                END IF;
                                                ----------------------------------------------------------------------------------
                                                LET cReferencia = 'CVE' || " " ||TRIM(cCveEnvio);
                                        END IF;

                                        IF vTrans = '1135' THEN -- Comision
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 22) );
                                        END IF;

                                        IF vTrans = '1136' THEN -- Iva
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 26) );
                                        END IF;

                    IF (vTrans = '0813' or vTrans = '0830') THEN

                        SELECT NVL(TRIM(referencia),'')  INTO cDescripcionMovdescpos FROM bdicheq:sc_movdescpos WHERE cuenta = pCuenta AND  folio_suc = cFolioSuc;

                        IF cDescripcionMovdescpos  <> '' THEN
                            LET cReferencia = TRIM(cDescripcionMovdescpos);
                        END IF;
                    END IF;

                                        RETURN vCodRet, dFechaMov, TRIM(SUBSTRING(cReferencia FROM 1 FOR 16)), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, cReferencia WITH RESUME;
                                END FOREACH;
                        ELSE
                                FOREACH
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}
                                                SKIP pRegistro FIRST 10
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        INTO
                                                iAux, dFechaMov, cReferencia, cTransacc, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans,cFolioSuc
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
                                                tr.sistema = "01"
                                                ORDER BY
                                                mm.fech_alt DESC,
                                                mm.num_serial DESC

                                        IF NVL(TRIM(cReferencia),'') = ''  THEN
                                                LET cReferencia = cTransacc ;
                                        END IF;

                                        IF vTrans = '3333' THEN
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
                                        ELIF vTrans = '0231' THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
                                        ELIF (vTrans = '3320' OR vTrans = '3321') THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
                                        END IF;

                                        LET cConceptoPago =     "";

                                        IF vTrans = '0274' OR vTrans = '0276' THEN

                                                SELECT vchrconceptopago2
                                                INTO cConceptoPago
                                                FROM bdispei:tblhistpago
                                                WHERE vchrcuentaord = xCuenta
                                                AND cReferencia = vchrclaverastreo;
                                        END IF;

                                        IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
                                                SELECT vchrconceptopago
                                                INTO cConceptoPago
                                                FROM bdispei:tblhistpago
                                                WHERE cReferencia = vchrclaverastreo
                                                AND dFechaMov = dtfechavalor
                                                AND intcvetipopago <> 0;
                                        END IF;

                                        IF vTrans = '1134' THEN -- orden pago

                                                SELECT cgenerico5
                                                into cCveEnvio
                                                FROM bdibpi:"informix".bpi_bitacora_historial
                                                WHERE cuenta_origen = pCuenta
                                                and fecha_aplic BETWEEN pFechaInicial AND pFechaFinal
                                                and fecha_aplic>= cFech_param
                                                and id_operacion = '1034'
                                                and folio = cFolioSuc;
                                                ----------------------------------------------------------------------------------
                                                LET cReferencia = 'CVE' || " " ||TRIM(cCveEnvio);
                                        END IF;
                                        IF vTrans = '1135' THEN -- Comision
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 22) );
                                        END IF;

                                        IF vTrans = '1136' THEN -- Iva
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 26) );
                                        END IF;

                    IF (vTrans = '0813' or vTrans = '0830') THEN

                        SELECT NVL(TRIM(referencia),'')  INTO cDescripcionMovdescpos FROM bdicheq:sc_movdescpos WHERE cuenta = pCuenta AND  folio_suc = cFolioSuc;

                        IF cDescripcionMovdescpos  <> '' THEN
                            LET cReferencia = TRIM(cDescripcionMovdescpos);
                        END IF;
                     END IF;

                                        RETURN vCodRet, dFechaMov, TRIM(SUBSTRING(cReferencia FROM 1 FOR 16)), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, cReferencia WITH RESUME;
                                END FOREACH;
                        END IF;

                --Consulta de movimientos incluyendo la movhis_old, la mov_his y la movdia
                ELIF pFechaInicial >= cFech_param_ini THEN
                        IF pFechaFinal = vFechaHoy THEN
                                FOREACH
                                        SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
                                                SKIP pRegistro FIRST 10
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        INTO
                                                iAux, dFechaMov, cReferencia, cTransacc, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans, cFolioSuc
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
                                                tr.sistema = "01"
                                        UNION
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
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
                                                tr.sistema = "01"
                                        UNION
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis_old movhis1)}
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        FROM
                                                bdicheq:"informix".sc_movhis_old AS mm,
                                                bdinteg:"informix".si_transacc AS tr
                                        WHERE
                                                mm.empresa = pEmpresa AND
                                                mm.cuenta = pCuenta AND
                                                mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
                                                mm.fech_alt >= cFech_param_ini AND
                        mm.fech_alt < cFech_param AND
                                                mm.cancelad <> "S" AND
                                                mm.transacc = tr.numero AND
                                                mm.empresa = tr.empresa AND
                                                tr.se_emite_edocta = "S" AND
                                                tr.sistema = "01"
                                        ORDER BY
                                                mm.fech_alt DESC,
                                                mm.num_serial DESC

                                        IF NVL(TRIM(cReferencia),'') = ''  THEN
                                                LET cReferencia = cTransacc ;
                                        END IF;

                                        IF vTrans = '3333' THEN
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
                                        ELIF vTrans = '0231' THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
                                        ELIF (vTrans = '3320' OR vTrans = '3321') THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
                                        END IF;


                                        LET cConceptoPago =     "";

                                        IF vTrans = '0274' OR vTrans = '0276' THEN

                                                IF  dFechaMov = pFechaFinal THEN
                                                        SELECT vchrconceptopago2
                                                        INTO cConceptoPago
                                                        FROM bdispei:tblpago
                                                        WHERE vchrcuentaord = xCuenta
                                                        AND cReferencia = vchrclaverastreo;
                                                ELSE
                                                        SELECT vchrconceptopago2
                                                        INTO cConceptoPago
                                                        FROM bdispei:tblhistpago
                                                        WHERE vchrcuentaord = xCuenta
                                                        AND cReferencia = vchrclaverastreo;
                                                END IF;
                                        END IF;

                                        IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
                                                SELECT vchrconceptopago
                                                INTO cConceptoPago
                                                FROM bdispei:tblhistpago
                                                WHERE cReferencia = vchrclaverastreo
                                                AND dFechaMov = dtfechavalor
                                                AND intcvetipopago <> 0;
                                        END IF;

                                        IF vTrans = '1134' THEN -- orden pago
                                                IF  dFechaMov = pFechaFinal THEN
                                                        SELECT cgenerico5 --cgenerico5,
                                                        into cCveEnvio
                                                        FROM bdibpi:"informix".bpi_bitacora
                                                        WHERE cuenta_origen = pCuenta
                                                        and fecha_aplic = vFechaHoy
                                                        and id_operacion = '1034'
                                                        and folio = cFolioSuc;
                                                ELSE
                                                        SELECT cgenerico5
                                                        into cCveEnvio
                                                        FROM bdibpi:"informix".bpi_bitacora_historial
                                                        WHERE cuenta_origen = pCuenta
                                                        and fecha_aplic BETWEEN pFechaInicial AND pFechaFinal
                                                        and id_operacion = '1034'
                                                        and folio = cFolioSuc;
                                                END IF;
                                                ----------------------------------------------------------------------------------
                                        LET cReferencia = 'CVE' || " " ||TRIM(cCveEnvio);

                                        END IF;

                                        IF vTrans = '1135' THEN -- Comision
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 22) );
                                        END IF;

                                        IF vTrans = '1136' THEN -- Iva
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 26) );
                                        END IF;

                    IF (vTrans = '0813' or vTrans = '0830') THEN

                            SELECT NVL(TRIM(referencia),'')  INTO cDescripcionMovdescpos FROM bdicheq:sc_movdescpos WHERE cuenta = pCuenta AND  folio_suc = cFolioSuc;

                            IF cDescripcionMovdescpos  <> '' THEN
                                LET cReferencia = TRIM(cDescripcionMovdescpos);
                            END IF;
                     END IF;
                                        RETURN vCodRet, dFechaMov, TRIM(SUBSTRING(cReferencia FROM 1 FOR 16)), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, cReferencia WITH RESUME;
                                END FOREACH;
                        ELSE
                                FOREACH
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}
                                                SKIP pRegistro FIRST 10
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        INTO
                                                iAux, dFechaMov, cReferencia, cTransacc, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans, cFolioSuc
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
                                                tr.sistema = "01"
                                        UNION
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis_old movhis1)}
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        FROM
                                                bdicheq:"informix".sc_movhis_old AS mm,
                                                bdinteg:"informix".si_transacc AS tr
                                        WHERE
                                                mm.empresa = pEmpresa AND
                                                mm.cuenta = pCuenta AND
                                                mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
                                                mm.fech_alt >= cFech_param_ini AND
                        mm.fech_alt < cFech_param AND
                                                mm.cancelad <> "S" AND
                                                mm.transacc = tr.numero AND
                                                mm.empresa = tr.empresa AND
                                                tr.se_emite_edocta = "S" AND
                                                tr.sistema = "01"
                                        ORDER BY
                                                mm.fech_alt DESC,
                                                mm.num_serial DESC

                                        IF NVL(TRIM(cReferencia),'') = ''  THEN
                                                LET cReferencia = cTransacc ;
                                        END IF;


                                        IF vTrans = '3333' THEN
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
                                        ELIF vTrans = '0231' THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
                                        ELIF (vTrans = '3320' OR vTrans = '3321') THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
                                        END IF;

                                        LET cConceptoPago =     "";

                                        IF vTrans = '0274' OR vTrans = '0276' THEN

                                                SELECT vchrconceptopago2
                                                INTO cConceptoPago
                                                FROM bdispei:tblhistpago
                                                WHERE vchrcuentaord = xCuenta
                                                AND cReferencia = vchrclaverastreo;
                                        END IF;

                                        IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
                                                SELECT vchrconceptopago
                                                INTO cConceptoPago
                                                FROM bdispei:tblhistpago
                                                WHERE cReferencia = vchrclaverastreo
                                                AND dFechaMov = dtfechavalor
                                                AND intcvetipopago <> 0;
                                        END IF;

                                        IF vTrans = '1134' THEN -- orden pago

                                                SELECT cgenerico5
                                                into cCveEnvio
                                                FROM bdibpi:"informix".bpi_bitacora_historial
                                                WHERE cuenta_origen = pCuenta
                                                and fecha_aplic BETWEEN pFechaInicial AND pFechaFinal
                                                AND fecha_aplic>= cFech_param
                                                and id_operacion = '1034'
                                                and folio = cFolioSuc;

                                                ----------------------------------------------------------------------------------
                                                LET cReferencia = 'CVE' || " " ||TRIM(cCveEnvio);

                                                END IF;

                                        IF vTrans = '1135' THEN -- Comision
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 22) );
                                        END IF;

                                        IF vTrans = '1136' THEN -- Iva
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 26) );
                                        END IF;

                    IF (vTrans = '0813' or vTrans = '0830') THEN

                            SELECT NVL(TRIM(referencia),'')  INTO cDescripcionMovdescpos FROM bdicheq:sc_movdescpos WHERE cuenta = pCuenta AND  folio_suc = cFolioSuc;

                            IF cDescripcionMovdescpos  <> '' THEN
                                LET cReferencia = TRIM(cDescripcionMovdescpos);
                            END IF;
                     END IF;
                                        RETURN vCodRet, dFechaMov, TRIM(SUBSTRING(cReferencia FROM 1 FOR 16)), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, cReferencia WITH RESUME;
                                END FOREACH;
                        END IF;
/*-----*/
                --cFech_param_old
                --Consulta de movimientos incluyendo la movhis_old, la mov_his y la movdia
                ELIF pFechaInicial >= cFech_param_old THEN
                        IF pFechaFinal = vFechaHoy THEN
                                FOREACH
                                        SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
                                                SKIP pRegistro FIRST 10
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        INTO
                                                iAux, dFechaMov, cReferencia, cTransacc, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans, cFolioSuc
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
                                                tr.sistema = "01"
                                        UNION
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero , mm.folio_suc
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
                                                tr.sistema = "01"
                                        UNION
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis_old movhis1)}
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        FROM
                                                bdicheq:"informix".sc_movhis_old AS mm,
                                                bdinteg:"informix".si_transacc AS tr
                                        WHERE
                                                mm.empresa = pEmpresa AND
                                                mm.cuenta = pCuenta AND
                                                mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
                                                mm.fech_alt >= cFech_param_ini AND
                        mm.fech_alt < cFech_param AND
                                                mm.cancelad <> "S" AND
                                                mm.transacc = tr.numero AND
                                                mm.empresa = tr.empresa AND
                                                tr.se_emite_edocta = "S" AND
                                                tr.sistema = "01"
                                        UNION
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis_old2 movhis1_old2)}
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        FROM
                                                bdicheq:"informix".sc_movhis_old2 AS mm,
                                                bdinteg:"informix".si_transacc AS tr
                                        WHERE
                                                mm.empresa = pEmpresa AND
                                                mm.cuenta = pCuenta AND
                                                mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
                                                mm.fech_alt >= cFech_param_old AND
                        mm.fech_alt < cFech_param_ini AND
                                                mm.cancelad <> "S" AND
                                                mm.transacc = tr.numero AND
                                                mm.empresa = tr.empresa AND
                                                tr.se_emite_edocta = "S" AND
                                                tr.sistema = "01"
                                        ORDER BY
                                                mm.fech_alt DESC,
                                                mm.num_serial DESC


                                        IF NVL(TRIM(cReferencia),'') = ''  THEN
                                                LET cReferencia = cTransacc ;
                                        END IF;

                                        IF vTrans = '3333' THEN
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
                                        ELIF vTrans = '0231' THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
                                        ELIF (vTrans = '3320' OR vTrans = '3321') THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
                                        END IF;

                                        LET cConceptoPago =     "";

                                        IF vTrans = '0274' OR vTrans = '0276' THEN

                                                IF  dFechaMov = pFechaFinal THEN
                                                        SELECT vchrconceptopago2
                                                        INTO cConceptoPago
                                                        FROM bdispei:tblpago
                                                        WHERE vchrcuentaord = xCuenta
                                                        AND cReferencia = vchrclaverastreo;
                                                ELSE
                                                        SELECT vchrconceptopago2
                                                        INTO cConceptoPago
                                                        FROM bdispei:tblhistpago
                                                        WHERE vchrcuentaord = xCuenta
                                                        AND cReferencia = vchrclaverastreo;
                                                END IF;
                                        END IF;

                                        IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
                                                SELECT vchrconceptopago
                                                INTO cConceptoPago
                                                FROM bdispei:tblhistpago
                                                WHERE cReferencia = vchrclaverastreo
                                                AND dFechaMov = dtfechavalor
                                                AND intcvetipopago <> 0;
                                        END IF;

                                        IF vTrans = '1134' THEN -- orden pago
                                                IF  dFechaMov = pFechaFinal THEN
                                                        SELECT cgenerico5 --cgenerico5,
                                                        into cCveEnvio
                                                        FROM bdibpi:"informix".bpi_bitacora
                                                        WHERE cuenta_origen = pCuenta
                                                        and fecha_aplic = vFechaHoy
                                                        and fecha_aplic >= cFech_param
                                                        and id_operacion = '1034'
                                                        and folio = cFolioSuc;
                                                ELSE
                                                        SELECT cgenerico5
                                                        into cCveEnvio
                                                        FROM bdibpi:"informix".bpi_bitacora_historial
                                                        WHERE cuenta_origen = pCuenta
                                                        and fecha_aplic BETWEEN pFechaInicial AND pFechaFinal
                                                        and fecha_aplic>= cFech_param
                                                        and id_operacion = '1034'
                                                        and folio = cFolioSuc;
                                                END IF;
                                                ----------------------------------------------------------------------------------
                                                LET cReferencia = 'CVE' || " " ||TRIM(cCveEnvio);

                                                END IF;

                                        IF vTrans = '1135' THEN -- Comision
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 22) );
                                        END IF;

                                        IF vTrans = '1136' THEN -- Iva
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 26) );
                                        END IF;

                    IF (vTrans = '0813' or vTrans = '0830') THEN

                            SELECT NVL(TRIM(referencia),'')  INTO cDescripcionMovdescpos FROM bdicheq:sc_movdescpos WHERE cuenta = pCuenta AND  folio_suc = cFolioSuc;

                            IF cDescripcionMovdescpos  <> '' THEN
                                LET cReferencia = TRIM(cDescripcionMovdescpos);
                            END IF;
                     END IF;
                                        RETURN vCodRet, dFechaMov, TRIM(SUBSTRING(cReferencia FROM 1 FOR 16)), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, cReferencia WITH RESUME;
                                END FOREACH;
                        ELSE
                                FOREACH
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}
                                                SKIP pRegistro FIRST 10
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero , mm.folio_suc
                                        INTO
                                                iAux, dFechaMov, cReferencia, cTransacc, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans, cFolioSuc
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
                                                tr.sistema = "01"
                                        UNION
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis_old movhis1)}
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        FROM
                                                bdicheq:"informix".sc_movhis_old AS mm,
                                                bdinteg:"informix".si_transacc AS tr
                                        WHERE
                                                mm.empresa = pEmpresa AND
                                                mm.cuenta = pCuenta AND
                                                mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
                                                mm.fech_alt >= cFech_param_ini AND
                        mm.fech_alt < cFech_param AND
                                                mm.cancelad <> "S" AND
                                                mm.transacc = tr.numero AND
                                                mm.empresa = tr.empresa AND
                                                tr.se_emite_edocta = "S" AND
                                                tr.sistema = "01"
                                        UNION
                                        SELECT {+INDEX(bdicheq:"informix".sc_movhis_old2 movhis1_old2)}
                                                num_serial, mm.fech_alt, mm.referencia, mm.transacc, tr.descripcion,
                                                mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero, mm.folio_suc
                                        FROM
                                                bdicheq:"informix".sc_movhis_old2 AS mm,
                                                bdinteg:"informix".si_transacc AS tr
                                        WHERE
                                                mm.empresa = pEmpresa AND
                                                mm.cuenta = pCuenta AND
                                                mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
                                                mm.fech_alt >= cFech_param_old AND
                        mm.fech_alt < cFech_param_ini AND
                                                mm.cancelad <> "S" AND
                                                mm.transacc = tr.numero AND
                                                mm.empresa = tr.empresa AND
                                                tr.se_emite_edocta = "S" AND
                                                tr.sistema = "01"
                                        ORDER BY
                                                mm.fech_alt DESC,
                                                mm.num_serial DESC

                                        IF NVL(TRIM(cReferencia),'') = ''  THEN
                                                LET cReferencia = cTransacc ;
                                        END IF;

                                        IF vTrans = '3333' THEN
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
                                        ELIF vTrans = '0231' THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
                                        ELIF (vTrans = '3320' OR vTrans = '3321') THEN
                                                LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
                                                LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
                                        END IF;

                                        LET cConceptoPago =     "";

                                        IF vTrans = '0274' OR vTrans = '0276' THEN

                                                SELECT vchrconceptopago2
                                                INTO cConceptoPago
                                                FROM bdispei:tblhistpago
                                                WHERE vchrcuentaord = xCuenta
                                                AND cReferencia = vchrclaverastreo;
                                        END IF;

                                        IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
                                                SELECT vchrconceptopago
                                                INTO cConceptoPago
                                                FROM bdispei:tblhistpago
                                                WHERE cReferencia = vchrclaverastreo
                                                AND dFechaMov = dtfechavalor
                                                AND intcvetipopago <> 0;
                                        END IF;

                                        IF vTrans = '1134' THEN -- orden pago

                                                SELECT cgenerico5
                                                into cCveEnvio
                                                FROM bdibpi:"informix".bpi_bitacora_historial
                                                WHERE cuenta_origen = pCuenta
                                                and fecha_aplic BETWEEN pFechaInicial AND pFechaFinal
                                                and fecha_aplic>= cFech_param
                                                and id_operacion = '1034'
                                                and folio = cFolioSuc;

                                                ----------------------------------------------------------------------------------
                                                LET cReferencia = 'CVE' || " " ||TRIM(cCveEnvio);

                                        END IF;

                                        IF vTrans = '1135' THEN -- Comision
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 22) );
                                        END IF;

                                        IF vTrans = '1136' THEN -- Iva
                                                LET cReferencia = TRIM(SUBSTRING(cDescripcion FROM 1 FOR 26) );
                                        END IF;
                                        IF (vTrans = '0813' or vTrans = '0830') THEN

                        SELECT NVL(TRIM(referencia),'')  INTO cDescripcionMovdescpos FROM bdicheq:sc_movdescpos WHERE cuenta = pCuenta AND  folio_suc = cFolioSuc;

                        IF cDescripcionMovdescpos  <> '' THEN
                            LET cReferencia = TRIM(cDescripcionMovdescpos);
                        END IF;
                    END IF;
                                        RETURN vCodRet, dFechaMov, TRIM(SUBSTRING(cReferencia FROM 1 FOR 16)), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, cReferencia WITH RESUME;
                                END FOREACH;
                        END IF;
/*-------*/
                        --Se retorna un codigo de retorno 100 en caso de que el movimiento este fuera de los parametros establecidos
                ELSE
                        LET vCodRet = '100';
                        RETURN vCodRet, dFechaMov, TRIM(SUBSTRING(cReferencia FROM 1 FOR 16)), cDescripcion, cNaturaleza, mMonto, mSaldo, cConceptoPago, vTrans, cReferencia WITH RESUME;
                END IF;

        END;

END PROCEDURE;