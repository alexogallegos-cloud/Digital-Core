CREATE PROCEDURE "informix".sp_consultamovimientoscen_pba(cTipo CHAR(1), siRegistros SMALLINT, cSucursal CHAR(4))

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

CREATE PROCEDURE "informix".pasamovshistoldcomp1_pba(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER, INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vexiste          SMALLINT;
    DEFINE vexistefin       SMALLINT;
    DEFINE vfechaproc       SMALLINT;
    DEFINE vsql             char(600);
    DEFINE vstmt            char(250);
    DEFINE vexistefinproc   CHAR(1);
    DEFINE vproceso         CHAR(20);
    DEFINE vsistema         CHAR(2);
    DEFINE vusuario         CHAR(10);
    DEFINE vexiste_fecha    SMALLINT;
    
    DEFINE vcodretparam     CHAR(5);
    DEFINE vserial_inicial  INTEGER;
    DEFINE vserial_final    INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vcont_commit     INTEGER;
    DEFINE vnum_serial      INTEGER;
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET ven_transacc    = 0; 
    
    LET vfecha_hoy      = ''; 
    LET vfecha_ant      = '';
    LET vexiste         = 0;
    LET vexistefin      = 0;
    LET vfechaproc      = 0;
    LET vsql            = '';
    LET vstmt           = '';
    LET vexistefinproc  = '';
    LET vproceso        = 'PasaMovsHistOldComp1';
    LET vsistema        = '01';
    LET vusuario        = user;
    LET vexiste_fecha   = 0;
    
    LET vcodretparam    = '';    
    LET vserial_inicial = 0;
    LET vserial_final   = 0;
    LET vcomienza       = -1;
    LET vcont_commit    = 0;
    LET vnum_serial     = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistoldcomp1.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold1.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold1.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistoldcomp1.out";
    --- TRACE ON;
    
    SET OPTIMIZATION HIGH;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    SELECT valor
      INTO vfecha_ant
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'PasoMovhis_MovhisOld';
        
    -- // VALIDA HAYA INICIADO EL PROCESO PRINCIPAL
    WHILE vfechaproc = 0
        SET ISOLATION TO DIRTY READ;
    
        SELECT COUNT(*)
          INTO vfechaproc
          FROM sc_contproc
         WHERE empresa = pempresa
           AND proceso = 'ini_pasomovshistold'
           AND fecha = vfecha_ant;
    END WHILE;
    
    -- // Guarda inicio de proceso     
    SELECT COUNT(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;

    IF vexiste = 0 THEN
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaspasamovsold1.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold1.sql';
        SYSTEM vstmt;
    ELSE
        SELECT COUNT(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa = pempresa
           AND proceso = vproceso
           AND fecha   = vfecha_hoy
           AND sistema = vsistema
           AND status_proc = "F";
           
        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_fin      = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold1.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold1.sql';
            SYSTEM vstmt;
        ELSE
            SELECT "1"
              INTO vexistefinproc
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "pasomovshistoldcomp1"
               AND fecha = vfecha_ant;
               
            IF vexistefinproc = "1" THEN
                LET vcodret1 = "958";
                RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
            END IF
        END IF;
    END IF;
    
    -- // OBTIENE VALORES PARA RANGO DE SERIALES A PROCESAR
    SELECT valor::integer
      INTO vserial_inicial
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'SerIniPasoMovHisOld1';
       
    SELECT valor::integer
      INTO vserial_final
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'SerIniPasoMovHisOld2';
       
    -- // OBTIENE EL NUMERO DE REGISTROS A TRASPASAR
    SELECT {+INDEX(sc_movhis idx_movhis_serial)}
           COUNT(*)
      INTO vcontador1
      FROM sc_movhis
     WHERE fech_alt = vfecha_ant
       AND num_serial >= vserial_inicial
       AND num_serial < vserial_final;
    
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_movhis idx_movhis_serial)}
               num_serial
          INTO vnum_serial
          FROM sc_movhis
         WHERE fech_alt = vfecha_ant
           AND num_serial >= vserial_inicial
           AND num_serial < vserial_final
           
        /*
        IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = 1;
        END IF;
        */
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        INSERT INTO sc_movhis_old
        SELECT {+INDEX(sc_movhis idx_movhis_serial)}
               mov.*
          FROM sc_movhis mov
         WHERE mov.fech_alt = vfecha_ant
           AND mov.num_serial = vnum_serial;
         
        DELETE {+INDEX(sc_movhis idx_movhis_serial)}
          FROM sc_movhis
         WHERE fech_alt = vfecha_ant
           AND num_serial = vnum_serial;
         
        LET vcont_commit = vcont_commit + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        /*
        IF vcont_commit >= 5000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vcont_commit = 0;
        END IF;
        */
    END FOREACH;
    
    /*
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET ven_transacc = 0;
    END IF;
    */
    
    SELECT {+INDEX(sc_movhis_old idx_movhis_serial_old)}
           COUNT(*)
      INTO vcontador2
      FROM sc_movhis_old
     WHERE fech_alt = vfecha_ant
       AND num_serial >= vserial_inicial
       AND num_serial < vserial_final;
     
    SELECT {+INDEX(sc_movhis idx_movhis_serial)}
           COUNT(*)
      INTO vcontador3
      FROM sc_movhis
     WHERE fech_alt = vfecha_ant
       AND num_serial >= vserial_inicial
       AND num_serial < vserial_final;
       
    IF vcontador1 = vcontador2 THEN
        LET vcodret1 = '000'; -- // PROCESO CONCLUIDO SATISFACTORIAMENTE
        LET vcodret2 = '000';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vusuario||''','||
                   'status_proc   = '''||'F'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold1.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold1.sql';
        SYSTEM vstmt;
           
        UPDATE sc_contproc
           SET fecha   = vfecha_ant
         WHERE empresa = pempresa
           AND proceso = 'pasomovshistoldcomp1';
    ELSE
        LET vcodret1 = '999'; -- // LOS MOVIMIENTOS TRASPASADOS NO COINCIDEN CON LOS MOVIMIENTOS A TRASAPASAR
        LET vcodret2 = '999';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold1.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold1.sql';
        SYSTEM vstmt;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;

END PROCEDURE;