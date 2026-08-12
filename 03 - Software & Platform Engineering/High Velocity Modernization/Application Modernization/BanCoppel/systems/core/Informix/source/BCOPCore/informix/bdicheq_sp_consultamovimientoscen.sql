CREATE PROCEDURE "informix".sp_consultamovimientoscen(cTipo CHAR(1), siRegistros SMALLINT, cSucursal CHAR(4))

    RETURNING
    CHAR(5),            -- Codigo de Retorno
    CHAR(8),            -- Codigo Usuario
    CHAR(8),            -- Secuencia
    CHAR(4),            -- Transaccion Sucursal
    MONEY(14,2),        -- Monto
    CHAR(1),            -- Cancelado o Reversado
    CHAR(2)             -- Sistema

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
    LET cCodRet = '000';
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

    --SET DEBUG FILE TO "/home/sysifx/sp_consultamovimientoscen.out";
    --TRACE ON;

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
                WHERE (codigo_fun IN ("020", "221", "223", "225", "027", "028") AND codigo_ref = 1) --se agrega el codigo_fun 225 ,027 y 028
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
                   
				   -- Se modifica para la transacción 7380 se cambie por la 6900 que es la que se encuentra en sucursal para conciliarlo con el movimiento sucursal 
                    IF cTransaccSuc ='7380' THEN
                   
					SELECT SUM(monto) INTO mMonto FROM bdicred:"informix".sd_movdia
					WHERE empresa ='001' AND folio_suc = cfolio_suc AND transacc_suc in('7380','6900');
					
                    LET cTransaccSuc ='6900';
				
				   -- FIN DEL BLOQUE DE MODIFICACIÓN
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
END PROCEDURE
DOCUMENT
"Consulta Movimientos en Central",
"AUTOR: Iris Arias Zazueta",
"FECHA: 19/03/2009",
"MODIFICACION: 25/05/2009 - Se consulta para obtener la minima secuencia de cada registro",
"REALIZO: Iris Arias Zazueta",
"MODIFICACION: 16/06/2011 - Se consulta los movimientos de prestamos a plazo",
"REALIZO: Iris Arias Zazueta",
"BD: bdicheq";

CREATE PROCEDURE "informix".borramovsdupli_movhisold( pfecha DATE )
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vnum_serial      INTEGER;
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcontador1      = -1;
    LET vnum_serial     = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovsdupli_movhisold.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
        END IF;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovsdupli_movhisold.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT num_serial, COUNT(*) cuantos
      FROM sc_movhis_old
     WHERE fech_alt = pfecha
     GROUP BY 1
      INTO TEMP tmp_seriales WITH NO LOG;
    CREATE INDEX idxtmp_seriales ON tmp_seriales(cuantos) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_seriales;
      
    SELECT num_serial
      FROM tmp_seriales
     WHERE cuantos > 1
      INTO TEMP tmp_movs_dupl WITH NO LOG;
    CREATE INDEX idxtmp_movsdupl ON tmp_movs_dupl(num_serial) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_movs_dupl;
    
    FOREACH cursor_borra WITH HOLD FOR
        SELECT {+INDEX(sc_movhis_old idx_movhis_serial_old)}
               num_serial
          INTO vnum_serial
          FROM sc_movhis_old
         WHERE fech_alt = pfecha
           AND num_serial IN(SELECT num_serial FROM tmp_movs_dupl)
           
        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
            BEGIN WORK;
        END IF;
        
        DELETE FROM sc_movhis_old
         WHERE CURRENT OF cursor_borra;
         
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;

    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;