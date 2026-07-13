CREATE PROCEDURE "informix".cuadra_invcrec19(pempresa char(3))
RETURNING CHAR(5);

    DEFINE vcodret          CHAR(5);
    DEFINE vsqlerr          INTEGER;
    DEFINE vfecha_hoy		DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vsdo_actual		DECIMAL(14,2);
    DEFINE vsdo_nuevo		DECIMAL(14,2);
    DEFINE vint_acum		DECIMAL(14,2);
    DEFINE visr             DECIMAL(14,2);
    DEFINE vintereses		DECIMAL(14,2);
    DEFINE vmonto_apertura	DECIMAL(14,2);
    DEFINE vhoraw       	CHAR(15);
    DEFINE vhora        	DATETIME HOUR TO FRACTION;
    DEFINE vfolio_suc   	CHAR(16);
    DEFINE vsucursal		CHAR(4);
    DEFINE vproducto		CHAR(4);
    DEFINE vstatus          CHAR(1);
    DEFINE vdiferencia		DECIMAL(14,2);
    DEFINE vexiste1         INTEGER;
    DEFINE vexiste2         INTEGER;
    DEFINE vsql             CHAR(500);
    DEFINE vfecha           CHAR(10);
    DEFINE vfechades        CHAR(6);
    DEFINE vdia             CHAR(2);
    DEFINE vmes             CHAR(2);
    DEFINE vanio            CHAR(2);
    DEFINE vnombre          VARCHAR(50);

    LET vcodret = "000";
    LET vhora = current hour to fraction;
    LET vhoraw = vhora;
    LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    LET vfolio_suc = "informix" ||vhoraw[1,8];

    --- SET DEBUG FILE TO "calsdoinvcrec";
    --- TRACE ON;

    BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    IF EXISTS (SELECT tabname FROM sysmaster:systabnames
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'cuentas_crecientes') THEN
        DROP TABLE cuentas_crecientes;
        CREATE RAW TABLE cuentas_crecientes(
            cuenta          CHAR(20),
            sdo_actual      MONEY(18,2),
            sdo_calculado   MONEY(18,2),
            diferencia      MONEY(18,2));
    ELSE
        CREATE RAW TABLE cuentas_crecientes(
            cuenta          CHAR(20),
            sdo_actual      MONEY(18,2),
            sdo_calculado   MONEY(18,2),
            diferencia      MONEY(18,2));
    END IF;

    SELECT {+INDEX(sc_movhis idxmovhistranspba)} cuenta 
      FROM sc_movhis_old
     WHERE transacc IN("3280","0270","0239","0223","0205")
       AND producto = "1100"
       AND cancelad <> "S"
       AND empresa = pempresa
    UNION ALL
    SELECT {+INDEX(sc_movhis idx_movhisnew3)} cuenta 
      FROM sc_movhis
     WHERE transacc IN("3280","0270","0239","0223","0205")
       AND producto = "1100"
       AND cancelad <> "S"
       AND empresa = pempresa
      INTO TEMP tmp_movhis WITH NO LOG;
    CREATE INDEX idx_tmp ON tmp_movhis(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movhis;

    SELECT {+INDEX(sc_fechas idx_fechas1)}
           fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    FOREACH
        SELECT {+INDEX(sc_maechq idxscmaechqpba)}
               mae.cuenta,mae.imp_chq_rem,mae.sdo_actual,
               mae.sucursal,mae.producto,mae.status_cta
          INTO vcuenta,vmonto_apertura,vsdo_actual,
               vsucursal,vproducto,vstatus
          FROM sc_maechq mae
         WHERE mae.producto = '1100'
           AND mae.status_cta IN('1','3')
           AND mae.cuenta NOT IN(SELECT cuenta 
                                   FROM tmp_movhis 
                                  WHERE cuenta = mae.cuenta)
           AND mae.cuenta NOT IN('11000067794','11000067905','11000068090','11000068103',
                                 '11000068138','11000068154','11002412758','11003026819')
		   AND day(mae.fecultdep) = "19"	

        IF vsdo_actual is NULL THEN
            LET vsdo_actual = 0.00;
        END IF

        -- // INVERSION PASADA
        LET vintereses = 0.00;
        LET vsdo_nuevo = 0.00;
        LET vint_acum  = 0.00;
        LET visr       = 0.00;
        LET vexiste1   = 0;
        
        SELECT COUNT(*)
          INTO vexiste1
          FROM sc_tasa_var_hist
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND inicio_periodo < vfecha_hoy
           AND tipo_tasa in("M","P");
        
        IF vexiste1 > 0 THEN
            SELECT SUM(int_acum), SUM(isr)
              INTO vint_acum, visr
              FROM sc_tasa_var_hist
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND inicio_periodo < vfecha_hoy
               AND tipo_tasa in("M","P");
        END IF

        IF vint_acum is null THEN
            LET vint_acum = 0.00;
        END IF

        IF visr is null THEN
            LET visr = 0.00;
        END IF

        LET vintereses = vint_acum - visr;
        
        -- // INVERSION ACTUAL
        LET vint_acum  = 0.00;
        LET visr       = 0.00;
        LET vexiste2   = 0;
        
        SELECT COUNT(*)
          INTO vexiste2
          FROM sc_tasa_variable
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND inicio_periodo < vfecha_hoy
           AND tipo_tasa in("M","P")
           AND fin_periodo < vfecha_hoy;
           
        IF vexiste2 > 0 THEN
            SELECT SUM(int_acum), SUM(isr)
              INTO vint_acum, visr
              FROM sc_tasa_variable
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND inicio_periodo < vfecha_hoy
               AND tipo_tasa in("M","P")
               AND fin_periodo < vfecha_hoy;
        END IF

        IF vint_acum is null THEN
            LET vint_acum = 0.00;
        END IF

        IF visr is null THEN
            LET visr = 0.00;
        END IF

        LET vintereses = vintereses + (vint_acum - visr);

        LET vsdo_nuevo = vmonto_apertura + vintereses;
        LET vdiferencia = 0.00;

        IF vsdo_nuevo <> vsdo_actual THEN
        
            LET vdiferencia = vsdo_nuevo - vsdo_actual;

            IF vdiferencia > 0.00 THEN
            
                INSERT INTO cuentas_crecientes 
                VALUES(vcuenta, vsdo_actual, vsdo_nuevo, vdiferencia);
                
            END IF
            
            UPDATE sc_maechq
               SET sdo_actual = vsdo_nuevo
             WHERE empresa = pempresa 
               AND cuenta = vcuenta;
            
        END IF
        
    END FOREACH

    UPDATE STATISTICS MEDIUM FOR TABLE cuentas_crecientes;

    LET vfecha = TO_CHAR(vfecha_hoy, '%Y/%m/%d');
    LET vdia = vfecha[9,10];
    LET vmes = vfecha[6,7];
    LET vanio = vfecha[3,4];
    LET vfechades = vdia||vmes||vanio;
    LET vnombre = 'rptinvcrec_'||vfechades||'.txt';

    -- // GENERA EL ARCHIVO DE DESCARGA
    LET vsql = '';
    -- LET vsql = 'echo "UNLOAD TO /home/informix/jivan/invcrec/'||vnombre||' SELECT * FROM cuentas_crecientes" > /home/informix/jivan/invcrec/rptinvcrec.sql';
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/'||vnombre||' SELECT * FROM cuentas_crecientes" > /resplogifx/conciliachq/rptinvcrec.sql';
    SYSTEM vsql;
    LET vsql = '';
    -- LET vsql = "dbaccess bdicheq /home/informix/jivan/invcrec/rptinvcrec.sql"; 
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptinvcrec.sql"; 
    SYSTEM vsql;
    LET vsql = '';
    -- LET vsql = 'chmod 664 /home/informix/jivan/invcrec/'||vnombre;
    LET vsql = 'chmod 664 /resplogifx/conciliachq/'||vnombre;
    SYSTEM vsql;
    LET vsql = "";

    END;

    RETURN vcodret;

END PROCEDURE;