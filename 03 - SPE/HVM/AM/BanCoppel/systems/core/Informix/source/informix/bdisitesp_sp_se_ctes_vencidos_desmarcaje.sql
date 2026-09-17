CREATE PROCEDURE "informix".sp_se_ctes_vencidos_desmarcaje()
            RETURNING CHAR(6), CHAR(150);

    --Fecha: 08/05/2009
    --Quien: Abraham Ayala
    --Definicion: Se creo este SP para el desmarcaje de clientes con situacion especial G1 y Y41.

    DEFINE vCodRet             CHAR(6);
    DEFINE vMensaje            CHAR(150);
    DEFINE SQL_ERR             INTEGER;
    DEFINE ISAM_ERR            INTEGER;
    DEFINE ERROR_INFO          VARCHAR(150);
    DEFINE v_numcliente        CHAR(20);
    DEFINE vv_numcliente       CHAR(20);
    DEFINE vv_pagosvenc        CHAR(3);
    DEFINE v_empresa           CHAR(3);
    DEFINE v_situacion         CHAR(1); 
    DEFINE v_causa             SMALLINT;
    DEFINE v_cvesitesporigen   SMALLINT;
    DEFINE v_sucursal          CHAR(4);
    DEFINE v_tipomovto         CHAR(1);
    DEFINE v_nombreefectuo     CHAR(20);
    DEFINE v_usralta           CHAR(8);
    DEFINE v_fchalta           DATE;
    
    LET vCodRet          = "00000";
    LET vMensaje         = "EJECUCION EXITOSA";
    
BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
                        LET vCodRet = SQL_ERR;
                        LET vMensaje = ERROR_INFO;
                        RETURN vCodRet, vMensaje;
    END EXCEPTION;

            --SET DEBUG FILE TO "/ids10_uc9/jtrujillo/sp_se_ctes_ctes_vencidos_Desmarcaje07052009.out";
            --TRACE ON;

    SET ISOLATION TO dirty READ;

    SELECT {+INDEX(se_ctessitespcte se_ctessitespcte_idx2)} distinct numcte  
    FROM bdisitesp:se_ctessitespcte
    WHERE situacion IN ('Y', 'G')
    AND causa IN (41, 1)
    INTO TEMP tmp_ctes_venc WITH NO LOG;

    FOREACH

                        SELECT distinct numcte
                        INTO v_numcliente
                        FROM tmp_ctes_venc

                        SELECT COUNT(*) pagos_venc
                        INTO vv_pagosvenc
                        FROM bdicred:sd_amortiza_credito b
                        INNER JOIN bdicred:sd_maecred c ON (c.empresa = b.empresa AND c.num_credito = b.num_credito)
                        WHERE b.empresa = '001'
                        AND b.num_credito > 0
                        AND b.capital_status IN ('2','7','6')
                        AND c.numcte = v_numcliente;

                        IF vv_pagosvenc < 3 THEN

                                   SELECT LIMIT 1 numcte, empresa, situacion, causa, cvesitesporigen, sucursal, tipomovto, nombreefectuo, usralta, fchalta
                                   INTO vv_numcliente, v_empresa, v_situacion, v_causa, v_cvesitesporigen, v_sucursal, v_tipomovto, v_nombreefectuo, v_usralta, v_fchalta
                                   FROM bdisitesp:se_ctessitespcte
                                   WHERE numcte = v_numcliente;

                                   --IF (v_situacion = 'G' AND v_causa = 1) OR (v_situacion = 'Y' AND v_causa = 41) THEN
                                               INSERT INTO bdisitesp:se_ctessitespcte_his(numcte, empresa, situacion, causa, cvesitesporigen, sucursal, 
                                                        tipomovto, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
                                               VALUES (v_numcliente, v_empresa, v_situacion, v_causa, v_cvesitesporigen, v_sucursal, 
                                                        v_tipomovto, v_nombreefectuo, v_usralta, v_fchalta, USER, CURRENT);

                                               --BEGIN WORK;
                                                    DELETE FROM bdisitesp:se_ctessitespcte WHERE numcte = vv_numcliente;
                                               --COMMIT WORK;
                                               
                                   --END IF;
                        END IF;
    END FOREACH;
END
            RETURN vCodRet, vMensaje;
END PROCEDURE;