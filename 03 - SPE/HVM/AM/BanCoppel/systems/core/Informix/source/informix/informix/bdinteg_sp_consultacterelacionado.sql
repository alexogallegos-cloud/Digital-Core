CREATE PROCEDURE "informix".sp_consultacterelacionado (cTipo CHAR (1), cAux1 CHAR(10), cAux2 CHAR(10))

RETURNING CHAR(5), CHAR(20), CHAR(100), CHAR(11), CHAR(12), CHAR(1), CHAR(100);

-- DECLARACION DE  VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);
DEFINE cNombreCompleto CHAR(104);
DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE cApellidopaterno CHAR(26);
DEFINE cApellidoMaterno CHAR(26);
DEFINE cTipoCte CHAR(1);
DEFINE cDescripcionCorta CHAR(100);
DEFINE cCuentas CHAR(11);
DEFINE cCreditos CHAR(12);
DEFINE iNumCuentas INT;
DEFINE iNumCreditos INT;
DEFINE cContador INT;

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '000';
LET cNumCte = '';
LET cNombreCompleto = '';
LET cNombre1 = '';
LET cNombre2 = '';
LET cApellidoPaterno = '';
LET cApellidoMaterno = '';
LET cTipoCte = '0';
LET cDescripcionCorta = '';
LET cCuentas = '';
LET cCreditos = '';
LET iNumCuentas = 0;
LET iNumCreditos = 0;
LET cContador = 0;

--SET DEBUG FILE TO "/tmp/sp_ConsultaCteRelacionado.out";
--TRACE ON;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr !=0 THEN
            LET cCodRet = iSqlErr;
            IF EXISTS(SELECT 1 FROM tmp_siCliente) THEN
                DROP TABLE tmp_siCliente;
            END IF;
            IF EXISTS(SELECT 1 FROM tmp_Cuentas) THEN
                DROP TABLE tmp_Cuentas;
            END IF;
            IF EXISTS(SELECT 1 FROM tmp_Creditos) THEN
                DROP TABLE tmp_Creditos;
            END IF;
            IF EXISTS(SELECT 1 FROM tmp_siCteRelacionado) THEN
                DROP TABLE tmp_siCteRelacionado;
            END IF;
            IF EXISTS(SELECT 1 FROM tmpReporte) THEN
                DROP TABLE tmpReporte;
            END IF;
            RETURN cCodRet, cNumCte, cNombreCompleto, cCuentas, cCreditos, cTipoCte, cDescripcionCorta;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;

    IF cTipo = '1' THEN

        SELECT DISTINCT numcte
        FROM si_cte_bitacora
        WHERE fecha_insert BETWEEN cAux1 AND cAux2
        AND numeric2_nvo <> 0
        ORDER BY numcte
        INTO TEMP tmp_siCte
        WITH NO LOG;

        SELECT a.numcte, b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.numeric2
        FROM tmp_siCte a, si_cliente b
        WHERE a.numcte = b.numcte
        AND numeric2 <> 0
        ORDER BY a.numcte
        INTO TEMP tmp_siCliente
        WITH NO LOG;

        DROP TABLE tmp_siCte;

    ELIF cTipo = '2' THEN
        SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno, numeric2
        FROM si_cliente
        WHERE numcte = cAux1
        AND numeric2 <> 0
        ORDER BY numcte
        INTO TEMP tmp_siCliente
        WITH NO LOG;

    ELIF cTipo = '3' THEN
        SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno, numeric2
        FROM si_cliente
        WHERE  numeric2 = cAux1
        ORDER BY numcte
        INTO TEMP tmp_siCliente
        WITH NO LOG;
    END IF;

    CREATE INDEX idx_tmpnumcte ON tmp_siCliente(numcte);
    UPDATE statistics high FOR TABLE tmp_siCliente(numcte);

    SELECT b.num_cte, b.cuenta
    FROM tmp_siCliente a, bdicheq:sc_maechq b
    WHERE  a.numcte = b.num_cte
    ORDER BY cuenta
    INTO TEMP tmp_Cuentas
    WITH NO LOG;

    CREATE INDEX idx_tmpcuentas ON tmp_Cuentas(num_cte);
    UPDATE statistics high FOR TABLE tmp_Cuentas(num_cte);

    SELECT b.numcte, b.num_credito
    FROM tmp_siCliente a, bdicred:sd_maecred b
    WHERE  a.numcte = b.numcte
    ORDER BY num_credito
    INTO TEMP tmp_Creditos
    WITH NO LOG;

    CREATE INDEX idx_tmpcreditos ON tmp_Creditos(numcte);
    UPDATE statistics high FOR TABLE tmp_Creditos(numcte);

    SELECT clavetipo, descripcioncorta
    FROM si_catcterelacionado
    WHERE clavetipo <> 0
    INTO TEMP tmp_siCteRelacionado
    WITH NO LOG;

    CREATE INDEX idx_tmpcterelacionado ON tmp_siCteRelacionado(clavetipo);
    UPDATE statistics high FOR TABLE tmp_siCteRelacionado(clavetipo);

    CREATE TEMP TABLE tmpReporte
    (
    numcte CHAR(9),
    nomcte CHAR(104),
    cuentas CHAR(11),
    creditos CHAR(12),
    tipocte CHAR(1),
    desccorta CHAR(100),
    contador CHAR(5)
    );
				
    FOREACH

        SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
        INTO cNumCte, cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno
        FROM tmp_siCliente

        LET cNombreCompleto = TRIM(nvl(cNombre1,' ')) || ' ' ||
                                                        TRIM(nvl(cNombre2, ' ')) || ' ' ||
                                                        TRIM(nvl(cApellidoPaterno, ' ')) || ' ' ||
                                                        TRIM(nvl(cApellidoMaterno, ' '));

        SELECT a.numeric2, b.descripcioncorta
        INTO cTipoCte, cDescripcionCorta
        FROM  tmp_siCliente a, tmp_sicterelacionado b
        WHERE numcte = cNumCte
        AND a.numeric2 = b.clavetipo;
        
        SELECT COUNT(cuenta) INTO iNumCuentas FROM tmp_Cuentas WHERE num_cte = cNumCte;
        SELECT COUNT(num_credito) INTO iNumCreditos FROM tmp_Creditos WHERE numcte = cNumCte;

        IF iNumCuentas >= iNumCreditos THEN

            LET cContador = 0;

                IF iNumCuentas = 0 THEN
			
                    INSERT INTO tmpReporte(numcte, nomcte, cuentas, creditos, tipocte, desccorta, contador)
                    VALUES (cNumCte, cNombreCompleto, '', '', cTipoCte, cDescripcionCorta, cContador);
	
                ELSE

                    FOREACH
		
                        SELECT cuenta 
			INTO cCuentas 
			FROM tmp_Cuentas 
			WHERE num_cte = cNumCte 
			ORDER BY cuenta

			LET cContador = cContador + 1;

			INSERT INTO tmpReporte(numcte, nomcte, cuentas, creditos, tipocte, desccorta, contador)
			VALUES (cNumCte, cNombreCompleto, cCuentas, '', cTipoCte, cDescripcionCorta, cContador);
	
                    END FOREACH;
	
                END IF

                LET cContador = 0;

                FOREACH

                    SELECT num_credito
                    INTO cCreditos 
                    FROM tmp_Creditos 
                    WHERE numcte = cNumCte 
                    ORDER BY num_credito

                    LET cContador = cContador + 1;

                    UPDATE tmpReporte
                    SET creditos = cCreditos
                    WHERE contador = cContador;

                END FOREACH;

            ELSE

                LET cContador = 0;

                FOREACH

                SELECT num_credito
                INTO cCreditos 
                FROM tmp_Creditos 
                WHERE numcte = cNumCte 
                ORDER BY num_credito

		LET cContador = cContador + 1;

		INSERT INTO tmpReporte(numcte, nomcte, cuentas, creditos, tipocte, desccorta, contador)
		VALUES (cNumCte, cNombreCompleto, '', cCreditos, cTipoCte, cDescripcionCorta, cContador);
		
            END FOREACH;
	
            LET cContador = 0;

            FOREACH
             
                SELECT cuenta 
		INTO cCuentas 
		FROM tmp_Cuentas 
		WHERE num_cte = cNumCte 
		ORDER BY cuenta

                LET cContador = cContador + 1;

                UPDATE tmpReporte
                SET cuentas = cCuentas
		WHERE contador = cContador;

            END FOREACH;

        END IF;

    END FOREACH;

    FOREACH

        SELECT numcte, nomcte, cuentas, creditos, tipocte, desccorta
	INTO cNumCte, cNombreCompleto, cCuentas, cCreditos, cTipoCte, cDescripcionCorta
	FROM tmpReporte

        RETURN cCodRet, cNumCte, cNombreCompleto, cCuentas, cCreditos, cTipoCte, cDescripcionCorta WITH RESUME;

    END FOREACH;

    DROP TABLE tmp_siCliente;
    DROP TABLE tmp_Cuentas;
    DROP TABLE tmp_Creditos;
    DROP TABLE tmp_siCteRelacionado;
    DROP TABLE tmpReporte;

END;

END PROCEDURE;