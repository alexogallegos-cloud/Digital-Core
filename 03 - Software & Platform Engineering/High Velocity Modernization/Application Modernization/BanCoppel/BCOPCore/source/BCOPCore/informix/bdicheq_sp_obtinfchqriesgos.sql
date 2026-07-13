CREATE PROCEDURE "informix".sp_obtinfchqriesgos( pfecha DATE )
RETURNING CHAR(5), CHAR(5), CHAR(80), INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER;
     
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(80);
    DEFINE isql_err         INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(80);
    DEFINE vcontador        INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE vcontador4       INTEGER;
    DEFINE vcontador5       INTEGER;
    DEFINE vcontador6       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcomienza1       SMALLINT;
    DEFINE vcomienza2       SMALLINT;
    DEFINE vcomienza3       SMALLINT;
    DEFINE vaniomes         CHAR(6);
    DEFINE vhoramax         DATETIME HOUR TO MINUTE;
    DEFINE vprecio_udi      DECIMAL(14,6);   
    DEFINE vfecha_tpcambio  DATE;
    DEFINE vmonto_udis      DECIMAL(18,6);
    DEFINE vnumcte          CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsaldo           DECIMAL(14,2);
    DEFINE vsdo_acum        DECIMAL(18,2);
    DEFINE vclientes        INTEGER;
    DEFINE vmonto_tot       DECIMAL(18,2);
    DEFINE vexedente        DECIMAL(18,2);
    DEFINE vmonto_tot_udis  DECIMAL(18,2);
    DEFINE vmonto_tot_exed  DECIMAL(18,2);
    
    LET vcodret1        = '000';               
    LET vcodret2        = '000';
    LET vcodret3        = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET isql_err        = 0;                   
    LET isam_err        = 0;
    LET desc_err        = '';
    LET vcontador       = 0;
    LET vcontador1      = 0;                   
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET vcontador4      = 0;
    LET vcontador5      = 0;
    LET vcontador6      = 0;
    LET ven_transacc    = 0;                   
    LET vcomienza1      = -1;  
    LET vcomienza2      = -1;  
    LET vcomienza3      = -1;  
    LET vaniomes        = TO_CHAR(pfecha, '%Y%m');
    LET vhoramax        = '';
    LET vprecio_udi     = 0.00;  
    LET vfecha_tpcambio = '';
    LET vmonto_udis     = 0.00; 
    LET vnumcte         = '';
    LET vcuenta         = '';
    LET vsaldo          = 0.00;
    LET vsdo_acum       = 0.00;
    LET vclientes       = 0;
    LET vmonto_tot      = 0.00;
    LET vexedente       = 0.00;
    LET vmonto_tot_udis = 0.00;
    LET vmonto_tot_exed = 0.00;
    
    BEGIN

    ON EXCEPTION SET isql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtinfchqriesgos.err";
        TRACE ON;
        IF isql_err <> 0 THEN
            LET vcodret1 = isql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2, vcontador3, vcontador4, vcontador5, vcontador6;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtinfchqriesgos.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    
    /* ###################################################################################################################################################### */
    
    
    -- // OBTIENE EL VALOR DE LA UDI
    SELECT FIRST 1 MAX(hora_tpcambio) 
      INTO vhoramax
      FROM bdinteg:si_tpcambio 
     WHERE empresa = '001' 
       AND divisa = '09'
       AND fecha_tpcambio = pfecha;
    
    IF vhoramax is null OR vhoramax = '' THEN
        SELECT FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = pfecha;
    ELSE
        SELECT FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio = pfecha
           AND hora_tpcambio = vhoramax;
    END IF;
   
    IF vprecio_udi is null OR vprecio_udi = '' THEN
        SELECT FIRST 1 MAX(fecha_tpcambio) 
          INTO vfecha_tpcambio
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio <= pfecha;
       
        SELECT FIRST 1 MAX(hora_tpcambio) 
          INTO vhoramax
          FROM bdinteg:si_tpcambio 
         WHERE empresa = '001' 
           AND divisa = '09'
           AND fecha_tpcambio = vfecha_tpcambio;
        
        IF vhoramax is null OR vhoramax = '' THEN
            SELECT FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio;
        ELSE
            SELECT FIRST 1 precio_venta
              INTO vprecio_udi
              FROM bdinteg:si_tpcambio
             WHERE empresa = '001'
               AND divisa = '09'
               AND fecha_tpcambio = vfecha_tpcambio
               AND hora_tpcambio = vhoramax;
        END IF;
    END IF;
    
    IF vprecio_udi is null THEN
        SELECT FIRST 1 precio_venta
          INTO vprecio_udi
          FROM bdinteg:si_tpcambio
         WHERE empresa = '001'
           AND divisa = '09'
           AND fecha_tpcambio <= TODAY;
    END IF;
    
    LET vmonto_udis = TRUNC((400000 * vprecio_udi), 2);
    
    
    /* ###################################################################################################################################################### */
    
    
    -- // CREA TABLAS DE TRABAJO TEMPORALES 
    CREATE TEMP TABLE tmp_ctes1( 
        fecha DATE, 
        no_clientes INTEGER, 
        importe DECIMAL(18,2),
        excedente DECIMAL(18,2)
    ) WITH NO LOG;
    CREATE INDEX idxtmp_ctes1 ON tmp_ctes1(fecha) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes1;
    
    INSERT INTO tmp_ctes1 VALUES(pfecha, 0, 0.00, 0.00);
    
    /* ############################################################ */
    
    CREATE TEMP TABLE tmp_ctes2( 
        fecha DATE, 
        no_clientes INTEGER, 
        importe DECIMAL(18,2),
        excedente DECIMAL(18,2)
    ) WITH NO LOG;
    CREATE INDEX idxtmp_ctes2 ON tmp_ctes2(fecha) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes2;
    
    INSERT INTO tmp_ctes2 VALUES(pfecha, 0, 0.00, 0.00);
    
    /* ############################################################ */
    
    CREATE TEMP TABLE tmp_ctes3( 
        fecha DATE, 
        no_clientes INTEGER, 
        importe DECIMAL(18,2),
        excedente DECIMAL(18,2)
    ) WITH NO LOG;
    CREATE INDEX idxtmp_ctes3 ON tmp_ctes3(fecha) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes3;
    
    INSERT INTO tmp_ctes3 VALUES(pfecha, 0, 0.00, 0.00);
    
    /* ############################################################ */
    
    CREATE TEMP TABLE tmp_ctes4( 
        fecha DATE, 
        no_clientes INTEGER, 
        importe DECIMAL(18,2),
        excedente DECIMAL(18,2)
    ) WITH NO LOG;
    CREATE INDEX idxtmp_ctes4 ON tmp_ctes4(fecha) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes4;
    
    INSERT INTO tmp_ctes4 VALUES(pfecha, 0, 0.00, 0.00);
    
    /* ############################################################ */
    
    CREATE TEMP TABLE tmp_ctes5( 
        fecha DATE, 
        no_clientes INTEGER, 
        importe DECIMAL(18,2),
        excedente DECIMAL(18,2)
    ) WITH NO LOG;
    CREATE INDEX idxtmp_ctes5 ON tmp_ctes5(fecha) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes5;
    
    INSERT INTO tmp_ctes5 VALUES(pfecha, 0, 0.00, 0.00);
    
    /* ############################################################ */
    
    CREATE TEMP TABLE tmp_ctes6( 
        fecha DATE, 
        no_clientes INTEGER, 
        importe DECIMAL(18,2),
        excedente DECIMAL(18,2)
    ) WITH NO LOG;
    CREATE INDEX idxtmp_ctes6 ON tmp_ctes6(fecha) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes6;
    
    INSERT INTO tmp_ctes6 VALUES(pfecha, 0, 0.00, 0.00);
    
    
    /* ###################################################################################################################################################### */
    
    
    SELECT {+INDEX(bdinvers:sv_maeinv)}
           num_cte as numcte, cod_instrum as producto
      FROM bdinvers:sv_maeinv
     WHERE status_cta = '1'
    UNION
    SELECT {+INDEX(bdicred:sd_maecred)}
           numcte as numcte, num_producto as producto
      FROM bdicred:sd_maecred
     WHERE status_cred IN('AA','BA','BT','E1','E2','E3')
    UNION
    SELECT {+INDEX(bdicred:sd_maecredcrd)}
           numcte as numcte, num_producto as producto
      FROM bdicred:sd_maecredcrd
     WHERE status_cred IN('AA','BA','BT','E1','E2','E3')
    INTO TEMP tmp_ctes_pags_cred WITH NO LOG;
    CREATE INDEX idxtmp_ctescred_cte ON tmp_ctes_pags_cred(numcte) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_pags_cred;
    
    
    /* ###################################################################################################################################################### */
    
    
    -- // CLIENTES CON SOLO UN PRODUCTO 
    IF DAY(pfecha) = '28' THEN
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo
         WHERE mae.cuenta = sdo.cuenta
           AND sdo.aniomes = vaniomes
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
           AND sdo.statuscta28 IN('1','3','4','5')
           AND mae.num_cte NOT IN(SELECT numcte FROM tmp_ctes_pags_cred)
         GROUP BY 1
        HAVING COUNT(*) = 1
        INTO TEMP tmp_ctes_sencillos WITH NO LOG;
    ELIF DAY(pfecha) = '29' THEN
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo
         WHERE mae.cuenta = sdo.cuenta
           AND sdo.aniomes = vaniomes
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
           AND sdo.statuscta29 IN('1','3','4','5')
           AND mae.num_cte NOT IN(SELECT numcte FROM tmp_ctes_pags_cred)
         GROUP BY 1
        HAVING COUNT(*) = 1
        INTO TEMP tmp_ctes_sencillos WITH NO LOG;
    ELIF DAY(pfecha) = '30' THEN
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo
         WHERE mae.cuenta = sdo.cuenta
           AND sdo.aniomes = vaniomes
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
           AND sdo.statuscta30 IN('1','3','4','5')
           AND mae.num_cte NOT IN(SELECT numcte FROM tmp_ctes_pags_cred)
         GROUP BY 1
        HAVING COUNT(*) = 1
        INTO TEMP tmp_ctes_sencillos WITH NO LOG;
    ELIF DAY(pfecha) = '31' THEN
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo
         WHERE mae.cuenta = sdo.cuenta
           AND sdo.aniomes = vaniomes
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
           AND sdo.statuscta31 IN('1','3','4','5')
           AND mae.num_cte NOT IN(SELECT numcte FROM tmp_ctes_pags_cred)
         GROUP BY 1
        HAVING COUNT(*) = 1
        INTO TEMP tmp_ctes_sencillos WITH NO LOG;
    END IF;
        
    CREATE INDEX idxtmp_ctes_sencillos ON tmp_ctes_sencillos(numcte) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_sencillos;
    
    FOREACH WITH HOLD
        SELECT numcte
          INTO vnumcte
          FROM tmp_ctes_sencillos
           
        IF vcomienza1 = -1 THEN
            LET vcomienza1 = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        IF DAY(pfecha) = '28' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.capvig28
                  INTO vcuenta, vsaldo
                  FROM sc_sdodiarioc sdo,
                       sc_maechq mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND aniomes = vaniomes
                   AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
                   AND sdo.statuscta28 IN('1','3','4','5')
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        ELIF DAY(pfecha) = '29' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.capvig29
                  INTO vcuenta, vsaldo
                  FROM sc_sdodiarioc sdo,
                       sc_maechq mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND aniomes = vaniomes
                   AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
                   AND sdo.statuscta29 IN('1','3','4','5')
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        ELIF DAY(pfecha) = '30' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.capvig30
                  INTO vcuenta, vsaldo
                  FROM sc_sdodiarioc sdo,
                       sc_maechq mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND aniomes = vaniomes
                   AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
                   AND sdo.statuscta30 IN('1','3','4','5')
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        ELIF DAY(pfecha) = '31' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.capvig31
                  INTO vcuenta, vsaldo
                  FROM sc_sdodiarioc sdo,
                       sc_maechq mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND aniomes = vaniomes
                   AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
                   AND sdo.statuscta31 IN('1','3','4','5')
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        END IF;
        
        IF vsdo_acum <= vmonto_udis THEN
            LET vexedente = 0.00;
        
            UPDATE tmp_ctes1
               SET no_clientes = no_clientes + 1,
                   importe = importe + vsdo_acum,
                   excedente = excedente + vexedente
             WHERE fecha = pfecha;
             
            LET vcontador1 = vcontador1 + 1;
        ELIF vsdo_acum > vmonto_udis THEN
            LET vexedente = vsdo_acum - vmonto_udis;
            
            UPDATE tmp_ctes2
               SET no_clientes = no_clientes + 1,
                   importe = importe + vsdo_acum,
                   excedente = excedente + vexedente
             WHERE fecha = pfecha;
             
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        LET vcontador = vcontador + 1;
        
        IF (vcontador >= 5000) THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte = '';
        LET vsdo_acum = 0.00;
        LET vexedente = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET vcontador = 0;
        LET ven_transacc = 0;
    END IF;
    
    
    /* ###################################################################################################################################################### */
    
    
    -- // CLIENTES CON MAS DE UN PRODUCTO DEL SISTEMA DE CHEQUES    
    IF DAY(pfecha) = '28' THEN
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.aniomes = vaniomes
           AND sdo.statuscta28 IN('1','3','4','5')
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
         GROUP BY 1
        HAVING COUNT(*) > 1
        INTO TEMP tmp_ctes_compuestos WITH NO LOG;
        
        INSERT INTO tmp_ctes_compuestos
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.aniomes = vaniomes
           AND sdo.statuscta28 IN('1','3','4','5')
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
           AND mae.num_cte IN(SELECT numcte FROM tmp_ctes_pags_cred)
         GROUP BY 1
        HAVING COUNT(*) = 1;
    ELIF DAY(pfecha) = '29' THEN
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.aniomes = vaniomes
           AND sdo.statuscta29 IN('1','3','4','5')
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
         GROUP BY 1
        HAVING COUNT(*) > 1
        INTO TEMP tmp_ctes_compuestos WITH NO LOG;
        
        INSERT INTO tmp_ctes_compuestos
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.aniomes = vaniomes
           AND sdo.statuscta29 IN('1','3','4','5')
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
           AND mae.num_cte IN(SELECT numcte FROM tmp_ctes_pags_cred)
         GROUP BY 1
        HAVING COUNT(*) = 1;
    ELIF DAY(pfecha) = '30' THEN
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.aniomes = vaniomes
           AND sdo.statuscta30 IN('1','3','4','5')
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
         GROUP BY 1
        HAVING COUNT(*) > 1
        INTO TEMP tmp_ctes_compuestos WITH NO LOG;
        
        INSERT INTO tmp_ctes_compuestos
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.aniomes = vaniomes
           AND sdo.statuscta30 IN('1','3','4','5')
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
           AND mae.num_cte IN(SELECT numcte FROM tmp_ctes_pags_cred)
         GROUP BY 1
        HAVING COUNT(*) = 1;
    ELIF DAY(pfecha) = '31' THEN
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.aniomes = vaniomes
           AND sdo.statuscta31 IN('1','3','4','5')
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
         GROUP BY 1
        HAVING COUNT(*) > 1
        INTO TEMP tmp_ctes_compuestos WITH NO LOG;
        
        INSERT INTO tmp_ctes_compuestos
        SELECT mae.num_cte AS numcte, COUNT(UNIQUE(mae.producto)) AS producto
          FROM sc_maechq mae,
               sc_sdodiarioc sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.aniomes = vaniomes
           AND sdo.statuscta31 IN('1','3','4','5')
           AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
           AND mae.num_cte IN(SELECT numcte FROM tmp_ctes_pags_cred)
         GROUP BY 1
        HAVING COUNT(*) = 1;
    END IF;
        
    CREATE INDEX idxtmp_ctes_compuestos ON tmp_ctes_compuestos(numcte) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_compuestos;
        
    FOREACH WITH HOLD
        SELECT numcte
          INTO vnumcte
          FROM tmp_ctes_compuestos
           
        IF vcomienza2 = -1 THEN
            LET vcomienza2 = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        IF DAY(pfecha) = '28' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.capvig28
                  INTO vcuenta, vsaldo
                  FROM sc_sdodiarioc sdo,
                       sc_maechq mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND aniomes = vaniomes
                   AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
                   AND sdo.statuscta28 IN('1','3','4','5')
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        ELIF DAY(pfecha) = '29' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.capvig29
                  INTO vcuenta, vsaldo
                  FROM sc_sdodiarioc sdo,
                       sc_maechq mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND aniomes = vaniomes
                   AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
                   AND sdo.statuscta29 IN('1','3','4','5')
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        ELIF DAY(pfecha) = '30' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.capvig30
                  INTO vcuenta, vsaldo
                  FROM sc_sdodiarioc sdo,
                       sc_maechq mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND aniomes = vaniomes
                   AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
                   AND sdo.statuscta30 IN('1','3','4','5')
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        ELIF DAY(pfecha) = '31' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.capvig31
                  INTO vcuenta, vsaldo
                  FROM sc_sdodiarioc sdo,
                       sc_maechq mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND aniomes = vaniomes
                   AND mae.producto IN('1100','1300','1400','1500','1700','1800','1900','2000','2300','2400','2500')
                   AND sdo.statuscta31 IN('1','3','4','5')
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        END IF;
        
        IF vsdo_acum <= vmonto_udis THEN
            LET vexedente = 0.00;
            
            UPDATE tmp_ctes3
               SET no_clientes = no_clientes + 1,
                   importe = importe + vsdo_acum,
                   excedente = excedente + vexedente
             WHERE fecha = pfecha;
             
            LET vcontador3 = vcontador3 + 1;
        ELIF vsdo_acum > vmonto_udis THEN
            LET vexedente = vsdo_acum - vmonto_udis;
            
            UPDATE tmp_ctes4
               SET no_clientes = no_clientes + 1,
                   importe = importe + vsdo_acum,
                   excedente = excedente + vexedente
             WHERE fecha = pfecha;
             
            LET vcontador4 = vcontador4 + 1;
        END IF;
        
        LET vcontador = vcontador + 1;
        
        IF (vcontador >= 5000) THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte = '';
        LET vsdo_acum = 0.00;
        LET vexedente = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET vcontador = 0;
        LET ven_transacc = 0;
    END IF;
    
    
    /* ###################################################################################################################################################### */
    
    
    -- // CLIENTES CON PAGARES 
    IF DAY(pfecha) = '28' THEN
        SELECT mae.num_cte AS numcte
          FROM bdinvers:sv_maeinv mae,
               bdinvers:sv_provdia sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.secuencia = mae.secuencia
           AND sdo.aniomes = vaniomes
           AND sdo.cv_dia28 is not null
           AND mae.fecha_alta <= pfecha
           AND mae.fecha_venc > pfecha
        INTO TEMP tmp_ctes_pagares WITH NO LOG;
    ELIF DAY(pfecha) = '29' THEN
        SELECT mae.num_cte AS numcte
          FROM bdinvers:sv_maeinv mae,
               bdinvers:sv_provdia sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.secuencia = mae.secuencia
           AND sdo.aniomes = vaniomes
           AND sdo.cv_dia29 is not null
           AND mae.fecha_alta <= pfecha
           AND mae.fecha_venc > pfecha
        INTO TEMP tmp_ctes_pagares WITH NO LOG;
    ELIF DAY(pfecha) = '30' THEN
        SELECT mae.num_cte AS numcte
          FROM bdinvers:sv_maeinv mae,
               bdinvers:sv_provdia sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.secuencia = mae.secuencia
           AND sdo.aniomes = vaniomes
           AND sdo.cv_dia30 is not null
           AND mae.fecha_alta <= pfecha
           AND mae.fecha_venc > pfecha
        INTO TEMP tmp_ctes_pagares WITH NO LOG;
    ELIF DAY(pfecha) = '31' THEN
        SELECT mae.num_cte AS numcte
          FROM bdinvers:sv_maeinv mae,
               bdinvers:sv_provdia sdo 
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.secuencia = mae.secuencia
           AND sdo.aniomes = vaniomes
           AND sdo.cv_dia31 is not null
           AND mae.fecha_alta <= pfecha
           AND mae.fecha_venc > pfecha
        INTO TEMP tmp_ctes_pagares WITH NO LOG;
    END IF;
    
    CREATE INDEX idxtmp_ctes_pagares ON tmp_ctes_pagares(numcte) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_pagares;
        
    FOREACH WITH HOLD
        SELECT numcte
          INTO vnumcte
          FROM tmp_ctes_pagares
           
        IF vcomienza3 = -1 THEN
            LET vcomienza3 = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        IF DAY(pfecha) = '28' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.cv_dia28
                  INTO vcuenta, vsaldo
                  FROM bdinvers:sv_provdia sdo,
                       bdinvers:sv_maeinv mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND sdo.secuencia = mae.secuencia
                   AND sdo.aniomes = vaniomes
                   AND sdo.cv_dia28 is not null
                   AND mae.fecha_alta <= pfecha
                   AND mae.fecha_venc > pfecha
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        ELIF DAY(pfecha) = '29' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.cv_dia29
                  INTO vcuenta, vsaldo
                  FROM bdinvers:sv_provdia sdo,
                       bdinvers:sv_maeinv mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND sdo.secuencia = mae.secuencia
                   AND sdo.aniomes = vaniomes
                   AND sdo.cv_dia29 is not null
                   AND mae.fecha_alta <= pfecha
                   AND mae.fecha_venc > pfecha
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        ELIF DAY(pfecha) = '30' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.cv_dia30
                  INTO vcuenta, vsaldo
                  FROM bdinvers:sv_provdia sdo,
                       bdinvers:sv_maeinv mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND sdo.secuencia = mae.secuencia
                   AND sdo.aniomes = vaniomes
                   AND sdo.cv_dia30 is not null
                   AND mae.fecha_alta <= pfecha
                   AND mae.fecha_venc > pfecha
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        ELIF DAY(pfecha) = '31' THEN
            FOREACH 
                SELECT mae.cuenta, sdo.cv_dia31
                  INTO vcuenta, vsaldo
                  FROM bdinvers:sv_provdia sdo,
                       bdinvers:sv_maeinv mae
                 WHERE sdo.cuenta = mae.cuenta
                   AND sdo.secuencia = mae.secuencia
                   AND sdo.aniomes = vaniomes
                   AND sdo.cv_dia31 is not null
                   AND mae.fecha_alta <= pfecha
                   AND mae.fecha_venc > pfecha
                   AND mae.num_cte = vnumcte
                   
                LET vsdo_acum = vsdo_acum + vsaldo;
                
                LET vcuenta = '';
                LET vsaldo = 0.00;
            END FOREACH;
        END IF;
        
        IF vsdo_acum <= vmonto_udis THEN
            LET vexedente = 0.00;
            
            UPDATE tmp_ctes5
               SET no_clientes = no_clientes + 1,
                   importe = importe + vsdo_acum,
                   excedente = excedente + vexedente
             WHERE fecha = pfecha;
             
            LET vcontador5 = vcontador5 + 1;
        ELIF vsdo_acum > vmonto_udis THEN
            LET vexedente = vsdo_acum - vmonto_udis;
            
            UPDATE tmp_ctes6
               SET no_clientes = no_clientes + 1,
                   importe = importe + vsdo_acum,
                   excedente = excedente + vexedente
             WHERE fecha = pfecha;
             
            LET vcontador6 = vcontador6 + 1;
        END IF;
        
        LET vcontador = vcontador + 1;
        
        IF (vcontador >= 5000) THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte = '';
        LET vsdo_acum = 0.00;
        LET vexedente = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET vcontador = 0;
        LET ven_transacc = 0;
    END IF;
    
    
    /* ###################################################################################################################################################### */
    
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2, vcontador3, vcontador4, vcontador5, vcontador6;

END PROCEDURE;