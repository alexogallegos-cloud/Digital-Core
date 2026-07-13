CREATE PROCEDURE "informix".sp_consultamovimientoscen_web(cTipo CHAR(1), siRegistros SMALLINT, cSucursal CHAR(4))

    RETURNING
    CHAR(5) AS ccodret,            -- Codigo de Retorno
    CHAR(8) AS ccodusuario,            -- Codigo Usuario
    CHAR(8) AS csecuencia,            -- Secuencia
    CHAR(4) AS ctransaccsuc,            -- Transaccion Sucursal
    MONEY(14,2) AS mmonto,        -- Monto
    CHAR(1) AS ccanrev,            -- Cancelado o Reversado
    CHAR(2) AS csistema             -- Sistema

    --  DEFINICION DE VARIABLES --
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);
    DEFINE cCodUsuario CHAR(8);
    DEFINE cSecuencia CHAR(8);
    DEFINE cTransaccSuc CHAR(4);
    DEFINE mMonto MONEY(14,2);
    DEFINE siCiclo SMALLINT;
    DEFINE cCanRev CHAR(1);
    DEFINE cSistema CHAR(2);
    DEFINE iSecuencia INTEGER;
    DEFINE cfolio_suc CHAR(16);
    DEFINE v_fecha_hoy DATE;

    -- INICIALIZACION DE VARIABLES --
    LET iSqlErr = 0;
    LET cCodRet = '00000';
    LET cCodUsuario = '';
    LET cSecuencia = '';
    LET cTransaccSuc = '';
    LET mMonto = '';
    LET siCiclo = 0;
    LET cCanRev = '';
    LET cSistema = '';
    LET iSecuencia = 0;
    LET cfolio_suc = '';
    LET v_fecha_hoy = DATE(1);

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--    SET DEBUG FILE TO "/RESPALDOSNEW/trace//sp_consultamovimientoscen.out";
--    TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cCodUsuario, cSecuencia, cTransaccSuc, mMonto, cCanRev, cSistema;
            END IF;
        END EXCEPTION;
		
        -- Debito
        SELECT fecha_hoy INTO v_fecha_hoy FROM bdicheq:"informix".sc_fechas;

        IF cTipo = "1" OR cTipo = "4" THEN
            FOREACH
                SELECT {+ INDEX (sc_movdia idx_sucempbdicheq)} SUBSTR(folio_suc, 1, 8), 
				SUBSTR(folio_suc, 9, 16), transacc_suc, monto_tot, cancelad
                INTO cCodUsuario, cSecuencia, cTransaccSuc, mMonto, cCanRev
                FROM bdicheq:"informix".sc_movdia
                WHERE sucursal = cSucursal AND empresa = '001' AND fech_alt = v_fecha_hoy
				GROUP BY folio_suc,transacc_suc, monto_tot, cancelad       ---   se modifica para efecto de vconcilia 31/10/2022
				ORDER BY folio_suc,transacc_suc, monto_tot desc

                LET cSistema = "SC";
                LET siCiclo = siCiclo + 1;
                IF siCiclo <= siRegistros THEN
                    CONTINUE FOREACH;
                END IF;

                RETURN cCodRet, cCodUsuario, cSecuencia, cTransaccSuc, mMonto, cCanRev, cSistema WITH RESUME;
            END FOREACH;
        END IF;

        -- Inversion
        SELECT fecha_hoy INTO v_fecha_hoy FROM bdinvers:"informix".sv_fechas;

        IF cTipo = "2" OR cTipo = "4" THEN
            FOREACH
                SELECT {+ INDEX (sv_movdia idx_sucempbdinvers)} SUBSTR(folio_suc, 1, 8), 
				SUBSTR(folio_suc, 9, 16), transacc_suc, monto_tot, cancelad
                INTO cCodUsuario, cSecuencia, cTransaccSuc, mMonto, cCanRev
                FROM bdinvers:"informix".sv_movdia 
				WHERE empresa = '001' AND sucursal = cSucursal AND fech_alt = v_fecha_hoy

                LET cSistema = "SV";
                LET siCiclo = siCiclo + 1;
                IF siCiclo <= siRegistros THEN
                    CONTINUE FOREACH;
                END IF;

                RETURN cCodRet, cCodUsuario, cSecuencia, cTransaccSuc, mMonto, cCanRev, cSistema WITH RESUME;
            END FOREACH;
        END IF;

		-- Se anexa acceso a la tabla de fechas
        SELECT fecha_hoy INTO v_fecha_hoy FROM bdicred:"informix".sd_fechas;

        -- Credito
        IF cTipo = "3" OR cTipo = "4" THEN
            FOREACH
                -- DSB 25/05/2009
                SELECT folio_suc, MIN(secuencia) INTO cfolio_suc, iSecuencia
                FROM bdicred:"informix".sd_movdia
                WHERE ((codigo_fun IN ("033", "333") AND codigo_ref = 1) OR (codigo_fun = "336" AND codigo_ref = 20) OR (codigo_fun = "002" AND codigo_ref IN (50,60)))
                AND sucursal = cSucursal AND fecha_mov = v_fecha_hoy
                GROUP BY folio_suc
				UNION ALL	-- DSB 16/06/2011
				SELECT folio_suc, MIN(secuencia)
                FROM bdicred:"informix".sd_movdiacrd
                WHERE (codigo_fun IN ("020", "221", "223", "225", "027", "028","021","023","077") AND codigo_ref = 1) --se agrega el codigo_fun 225 ,027 y 028
				AND sucursal = cSucursal AND fecha_mov = v_fecha_hoy
                GROUP BY folio_suc
                        
				FOREACH
	                SELECT SUBSTR(folio_suc, 1, 8), SUBSTR(folio_suc, 9, 16), transacc_suc, monto, reversado
	                INTO cCodUsuario, cSecuencia, cTransaccSuc, mMonto, cCanRev
	                FROM bdicred:"informix".sd_movdia
	                WHERE empresa = '001' AND secuencia = iSecuencia AND fecha_mov = v_fecha_hoy AND hora_mov >= DATE(0)
	                AND sucursal = cSucursal AND num_credito > '' AND folio_suc = cfolio_suc
					UNION ALL	-- DSB 16/06/2011
					SELECT SUBSTR(folio_suc, 1, 8), SUBSTR(folio_suc, 9, 16), transacc_suc, monto, reversado
	                FROM bdicred:"informix".sd_movdiacrd
	                WHERE empresa = '001' AND secuencia = iSecuencia AND fecha_mov = v_fecha_hoy AND hora_mov >= DATE(0)
					AND sucursal = cSucursal AND num_credito > '' AND folio_suc = cfolio_suc
                   
				   -- Se modifica para la transaccion 7380 se cambie por la 6900 que es la que se encuentra en sucursal para conciliarlo con el movimiento sucursal 
                    IF cTransaccSuc ='7380' THEN
                   
					SELECT SUM(monto) INTO mMonto FROM bdicred:"informix".sd_movdia
					WHERE empresa ='001' AND folio_suc = cfolio_suc AND transacc_suc in('7380','6900');
					
                    LET cTransaccSuc ='6900';
				
				   -- FIN DEL BLOQUE DE MODIFICACION
                    END IF;
	                LET cSistema = "SD";
	                LET siCiclo = siCiclo + 1;
	                IF siCiclo <= siRegistros THEN
	                    CONTINUE FOREACH;
	                END IF;

					RETURN cCodRet, cCodUsuario, cSecuencia, cTransaccSuc, mMonto, cCanRev, cSistema WITH RESUME;
				END FOREACH;
            END FOREACH;
        END IF;
    END;
END PROCEDURE;