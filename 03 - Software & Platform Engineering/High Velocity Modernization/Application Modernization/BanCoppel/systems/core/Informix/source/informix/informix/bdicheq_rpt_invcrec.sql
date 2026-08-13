CREATE PROCEDURE "informix".rpt_invcrec(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vdesc_err        CHAR(50);
    
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
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vtransaccion     INTEGER;
    
    DEFINE vfechconmovhis       char(10);
    DEFINE vfechconmovhisold    char(10);
    DEFINE vfechconmovhisold2   char(10);
    DEFINE vfechaconmovhisold3  char(10);
	DEFINE vfecha_operacion     DATE;

    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vcodret3     = '';
    LET vhora        = current hour to fraction;
    LET vhoraw       = vhora;
    LET vhoraw       = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    LET vfolio_suc   = "informix" ||vhoraw[1,8];
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcomienza    = -1;
    LET vtransaccion = 0;
    
    LET vfechconmovhis      = '';
    LET vfechconmovhisold   = '';
    LET vfechconmovhisold2  = '';
    LET vfechaconmovhisold3 = '';
	LET vfecha_operacion    = TODAY;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/rpt_invcrec.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdesc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/rpt_invcrec.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdesc_err;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
            END IF
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentas_crecientes') THEN
        DROP TABLE cuentas_crecientes;
    END IF;
    
    CREATE TABLE cuentas_crecientes(
        cuenta          CHAR(20),
        sdo_actual      MONEY(18,2),
        sdo_calculado   MONEY(18,2),
        diferencia      MONEY(18,2))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_rptintctascrec ON cuentas_crecientes(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE cuentas_crecientes;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    SELECT valor 
      INTO vfechconmovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor 
      INTO vfechconmovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT valor 
      INTO vfechconmovhisold2
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechaIniMovhisOld2';
       
    SELECT valor
      INTO vfechaconmovhisold3
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'vfechconmovhisold3';
    
    SELECT cuenta 
      FROM sc_movhis_old4
     WHERE producto = "1100"
       AND transacc IN("3280","0270","0239","0223","0205")
       AND fech_alt < vfechaconmovhisold3
       AND cancelad <> "S"
    UNION ALL
    SELECT cuenta 
      FROM sc_movhis_old3
     WHERE producto = "1100"
       AND transacc IN("3280","0270","0239","0223","0205")
       AND fech_alt >= vfechaconmovhisold3
       AND fech_alt < vfechconmovhisold2
       AND cancelad <> "S"
    UNION ALL
    SELECT cuenta 
      FROM sc_movhis_old2
     WHERE producto = "1100"
       AND transacc IN("3280","0270","0239","0223","0205")
       AND fech_alt >= vfechconmovhisold2
       AND fech_alt < vfechconmovhisold
       AND cancelad <> "S"
    UNION ALL
    SELECT cuenta 
      FROM sc_movhis_old
     WHERE producto = "1100"
       AND transacc IN("3280","0270","0239","0223","0205")
       AND fech_alt >= vfechconmovhisold
       AND fech_alt < vfechconmovhis
       AND cancelad <> "S"
    UNION ALL
    SELECT cuenta 
      FROM sc_movhis
     WHERE producto = "1100"
       AND transacc IN("3280","0270","0239","0223","0205")
       AND fech_alt >= vfechconmovhis
       AND cancelad <> "S"
    UNION ALL
    SELECT cuenta 
      FROM sc_movdia
     WHERE producto = "1100"
       AND transacc IN("3280","0270","0239","0223","0205")
       AND cancelad <> "S"
      INTO TEMP tmp_movhis WITH NO LOG;
    CREATE INDEX idx_tmp ON tmp_movhis(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movhis;

    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.sdo_actual, mae.sucursal, mae.producto, mae.status_cta
          INTO vcuenta, vsdo_actual, vsucursal, vproducto, vstatus
          FROM sc_maechq mae
         WHERE mae.producto = '1100'
           AND mae.status_cta IN('1','3')
           AND mae.cuenta NOT IN(SELECT cuenta FROM tmp_movhis)
           AND mae.cuenta <> '11003026819'
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF

        -- // MONTO DE APERTURA DE LA INVERSION
        SELECT monto_tot
          INTO vmonto_apertura
          FROM sc_movhis_old4
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND fech_alt < vfechaconmovhisold3
           AND cancelad <> 'S'
           AND transacc = '0202';
           
        IF vmonto_apertura is null OR vmonto_apertura = '' THEN
        
            SELECT monto_tot
              INTO vmonto_apertura
              FROM sc_movhis_old3
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND fech_alt >= vfechaconmovhisold3
               AND fech_alt < vfechconmovhisold2
               AND cancelad <> 'S'
               AND transacc = '0202';
               
            IF vmonto_apertura is null OR vmonto_apertura = '' THEN
            
                SELECT monto_tot
                  INTO vmonto_apertura
                  FROM sc_movhis_old2
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND fech_alt >= vfechconmovhisold2
                   AND fech_alt < vfechconmovhisold
                   AND cancelad <> 'S'
                   AND transacc = '0202';
                   
                IF vmonto_apertura is null OR vmonto_apertura = '' THEN
                
                    SELECT monto_tot
                      INTO vmonto_apertura
                      FROM sc_movhis_old
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta
                       AND fech_alt >= vfechconmovhisold
                       AND fech_alt < vfechconmovhis
                       AND cancelad <> 'S'
                       AND transacc = '0202';
                       
                    IF vmonto_apertura is null OR vmonto_apertura = '' THEN
                    
                        SELECT monto_tot
                          INTO vmonto_apertura
                          FROM sc_movhis
                         WHERE empresa = pempresa
                           AND cuenta = vcuenta
                           AND fech_alt >= vfechconmovhis
                           AND cancelad <> 'S'
                           AND transacc = '0202';
                           
                        IF vmonto_apertura is null OR vmonto_apertura = '' THEN
                        
                            SELECT monto_tot
                              INTO vmonto_apertura
                              FROM sc_movdia
                             WHERE empresa = pempresa
                               AND cuenta = vcuenta
                               AND transacc = '0202'
                               AND cancelad <> 'S';
                               
                            IF vmonto_apertura is null OR vmonto_apertura = '' THEN
                            
                                LET vmonto_apertura = 0.00;
                                
                            END IF;
                               
                        END IF;
                        
                    END IF;
                    
                END IF;
                
            END IF;
            
        END IF;
            
        -- // INVERSION PASADA
        LET vintereses = 0.00;
        LET vsdo_nuevo = 0.00;
        LET vint_acum  = 0.00;
        LET visr       = 0.00;
        LET vexiste1   = 0;
        
        SELECT NVL(COUNT(*), 0)
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
        END IF;

        IF visr is null THEN
            LET visr = 0.00;
        END IF;

        LET vintereses = vint_acum - visr;
        
        -- // INVERSION ACTUAL
        LET vint_acum  = 0.00;
        LET visr       = 0.00;
        LET vexiste2   = 0;
        
        SELECT NVL(COUNT(*), 0)
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
                
                INSERT INTO sc_movdia VALUES
                (0, vfolio_suc, vsucursal, "informix", vfecha_hoy, vfecha_hoy, vhora, "3381", vsucursal, vproducto, 
                 pempresa, vcuenta, "", 0, vdiferencia, vdiferencia, 0, 0, 0, "", vstatus, vsdo_actual, "0000", "", 0, "", "", "", vfecha_operacion);
                
                INSERT INTO sc_movdia VALUES
                (0, vfolio_suc, vsucursal, "informix", vfecha_hoy, vfecha_hoy, vhora, "3276", vsucursal, vproducto, 
                 pempresa, vcuenta, "", 0, vdiferencia, vdiferencia, 0, 0, 0,  "", vstatus, vsdo_actual, "0000", "", 0, "", "", "", vfecha_operacion);
                 
                UPDATE sc_maechq
                   SET sdo_actual = vsdo_nuevo
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
                INSERT INTO cuentas_crecientes VALUES(vcuenta, vsdo_actual, vsdo_nuevo, vdiferencia);
                
                LET vcontador2 = vcontador2 + 1;
                
            END IF;
            
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
    END FOREACH;
    
    IF vtransaccion = 1 THEN
        LET vtransaccion = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cuentas_crecientes;
    
    LET vfecha = TO_CHAR(vfecha_hoy, '%Y/%m/%d');
    LET vdia = vfecha[9,10];
    LET vmes = vfecha[6,7];
    LET vanio = vfecha[3,4];
    LET vfechades = vdia||vmes||vanio;
    LET vnombre = 'rptinvcrec_'||vfechades||'.txt';

    -- // GENERA EL ARCHIVO DE DESCARGA
    LET vsql = '';
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/'||vnombre||' SELECT * FROM cuentas_crecientes" > /resplogifx/conciliachq/rptinvcrec.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptinvcrec.sql"; 
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = 'chmod 664 /resplogifx/conciliachq/'||vnombre;
    SYSTEM vsql;
    LET vsql = "";
    
    LET vcodret3 = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';

    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;

END PROCEDURE;