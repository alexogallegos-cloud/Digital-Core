CREATE PROCEDURE "informix".sp_se_ctes_vencidos()
	RETURNING CHAR(6), CHAR(150);

    --Fecha: 08/05/2009
    --Quien: Abraham Ayala
    --Definicion: Se modificó este SP para el marcaje de clientes con situacion especial G1 y Y41.

    DEFINE vCodRet              CHAR(6);
    DEFINE vMensaje             CHAR(150);
    DEFINE SQL_ERR              INTEGER;
    DEFINE ISAM_ERR             INTEGER;
    DEFINE ERROR_INFO           VARCHAR(150);
    DEFINE v_pagosvenc          CHAR(3);
    DEFINE v_fechaultpago       DATE;
    DEFINE vv_numcliente        CHAR(20);
    DEFINE vv_pagosvenc         CHAR(3);
    DEFINE vv_fecha_ult_pag     DATE;
    DEFINE v_numcte             CHAR(20);
  	DEFINE v_empresa		    CHAR(3);
    DEFINE v_situacion			CHAR(1);
	DEFINE v_causa				SMALLINT;
    DEFINE v_cvesitesporigen    SMALLINT; 
    DEFINE v_sucursal           CHAR(4);
    DEFINE v_tipomovto          CHAR(1);
    DEFINE v_empleadoefectuo    CHAR(8);       
    DEFINE v_nombreefectuo      CHAR(40);
    DEFINE v_fechamovto         DATE;
    DEFINE v_usralta            CHAR(8);
    DEFINE v_fchalta            DATE;
    DEFINE vdia					DATE;
    DEFINE vhora				CHAR(8);
    DEFINE vinstruccion         CHAR(1);
	DEFINE vvalidacion			CHAR(4);

    LET vCodRet          = "00000";
    LET vMensaje         = "EJECUCION EXITOSA";
    
BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET vCodRet = SQL_ERR;
		LET vMensaje = ERROR_INFO;
        RETURN vCodRet, vMensaje;

    END EXCEPTION;

        --SET DEBUG FILE TO "/ids10_uc9/jtrujillo/modifica_situacion.out";
        --TRACE ON;

    CALL bdisitesp:sp_se_ctes_vencidos_desmarcaje()
        RETURNING vCodRet, vMensaje;

	  DELETE FROM bdisitesp:se_marcamenyg;

    FOREACH
		SELECT DISTINCT c.numcte, COUNT(*) pagos_venc, d.fecha_ult_pago
		INTO vv_numcliente, vv_pagosvenc, vv_fecha_ult_pag
		FROM bdicred:sd_amortiza_credito b
		INNER JOIN bdicred:sd_maecred c ON (c.empresa = b.empresa AND c.num_credito = b.num_credito)
		LEFT OUTER JOIN bdicred:sd_maecredanexo d ON (d.empresa = b.empresa AND d.num_credito = b.num_credito)
		WHERE b.empresa = '001'
		AND b.num_credito > 0
		AND b.capital_status IN ('2','7','6')
		GROUP BY b.num_credito, c.numcte, d.fecha_ult_pago
		HAVING COUNT(*) >= 3

		INSERT INTO bdisitesp:se_marcamenyg (numcliente, fecha_mov, pagosvenc)
		VALUES (vv_numcliente, vv_fecha_ult_pag, vv_pagosvenc);

    END FOREACH;

    FOREACH

		SELECT DISTINCT a.numcliente, a.pagosvenc, a.fecha_mov, b.situacion, b.causa
		INTO v_numcte, v_pagosvenc, v_fechaultpago, v_situacion, v_causa
		FROM bdisitesp:se_marcamenyg a, bdisitesp:se_ctessitespcte b
        WHERE a.numcliente = b.numcte

		LET vinstruccion = '';
		
        SELECT FIRST 1 NVL(instruccion, '')
        INTO   vinstruccion
        FROM   bdisitesp:se_situacionaccion
        WHERE  situacion= v_situacion
        AND    causa= v_causa
        AND    idaccion = 10;
        
        -- 1 INDICA QUE SE PUEDE MODIFICAR LA SITUACION ESPECIAL
        -- 0 INDICA QUE LA SITUACION ESPECIAL NO SE PUEDE MODIFICAR

        IF (vinstruccion = 1) OR (NVL(vinstruccion, '') = '') THEN
            IF (v_fechaultpago IS NULL) OR (v_fechaultpago = '') THEN  -------------VALIDA SI NO TIENE FECHA DE PAGO
            
                IF EXISTS (SELECT numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = v_numcte) THEN
                    SELECT  empresa, situacion, causa, cvesitesporigen, sucursal, tipomovto, nombreefectuo, usralta, fchalta
                    INTO    v_empresa, v_situacion, v_causa, v_cvesitesporigen, v_sucursal, v_tipomovto, 
                        v_nombreefectuo, v_usralta, v_fchalta
                    FROM bdisitesp:se_ctessitespcte
                    WHERE numcte = v_numcte;
					
					LET vvalidacion = '';
					LET vvalidacion = v_situacion || v_causa;

                    IF vvalidacion <> 'G1' THEN
                        INSERT INTO bdisitesp:se_ctessitespcte_his(tipomovto, numcte, empresa, situacion, 
                            causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
                            
                        VALUES (v_tipomovto, v_numcte, v_empresa, v_situacion, v_causa, v_cvesitesporigen, v_sucursal, v_nombreefectuo,
                            v_usralta, v_fchalta, USER, CURRENT);

                        UPDATE bdisitesp:se_ctessitespcte
                        SET situacion = 'G', causa = 1, tipomovto = 'S', empleadoefectuo = USER, usrmodifica = '99999999', fchmodifica = CURRENT
                        WHERE numcte = v_numcte;
                    END IF;
                ELSE
                    INSERT INTO bdisitesp:se_ctessitespcte(empresa, numcte, situacion, causa, cvesitesporigen, sucursal, 
                        tipomovto, nombreefectuo, usralta, fchalta) 
                    VALUES('001', v_numcte, 'G', 1, 9, '999', 'M', USER, '99999999', CURRENT);

                END IF;

            ELSE ---- VALIDA QUE SI TIENE FECHA DE PAGO -----
                IF EXISTS (SELECT numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = v_numcte) THEN
                    SELECT  empresa, situacion, causa, cvesitesporigen, sucursal, tipomovto, nombreefectuo, usralta, fchalta
                    INTO    v_empresa, v_situacion, v_causa, v_cvesitesporigen, v_sucursal, v_tipomovto, 
                        v_nombreefectuo, v_usralta, v_fchalta
                    FROM bdisitesp:se_ctessitespcte
                    WHERE numcte = v_numcte;
					
					LET vvalidacion = '';
					LET vvalidacion = v_situacion || v_causa;

                    IF vvalidacion <> 'Y41' THEN
                        INSERT INTO bdisitesp:se_ctessitespcte_his(tipomovto, numcte, empresa, situacion, 
                            causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
                        VALUES (v_tipomovto, v_numcte, v_empresa, v_situacion, v_causa, v_cvesitesporigen, v_sucursal, v_nombreefectuo,
                            v_usralta, v_fchalta, USER, CURRENT);

                        UPDATE bdisitesp:se_ctessitespcte
                        SET situacion = 'Y', causa = 41, tipomovto = 'S', empleadoefectuo = USER, usrmodifica = '99999999', fchmodifica = CURRENT
                        WHERE numcte = v_numcte;
                    END IF;
                ELSE
                    INSERT INTO bdisitesp:se_ctessitespcte(empresa, numcte, situacion, causa, cvesitesporigen, sucursal, 
                        tipomovto, nombreefectuo, usralta, fchalta) 
                    VALUES('001', v_numcte, 'Y', 41, 9, '999', 'M', USER, '99999999', CURRENT);

                END IF;
            END IF;
        END IF;    
    END FOREACH;
END
       
	RETURN vCodRet, vMensaje;
END PROCEDURE;