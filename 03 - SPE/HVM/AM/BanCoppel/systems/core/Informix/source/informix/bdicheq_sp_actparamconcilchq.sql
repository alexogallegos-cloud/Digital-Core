CREATE PROCEDURE "informix".sp_actparamconcilchq(pempresa CHAR(3))
RETURNING CHAR(5);
     
    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(50);
    DEFINE vpromedio        INTEGER;
    DEFINE vcont            SMALLINT;
    DEFINE vbrinca          INTEGER;
    DEFINE vcuenta          CHAR(20);
    DEFINE vfecha_hoy       DATE;
    DEFINE vdia             SMALLINT;
    
    LET vcodret    = "000";
    LET vcodret2   = "000";
    LET vcodret3   = " ";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vpromedio  = 0;
    LET vcont      = 0;
    LET vbrinca    = 0;
    LET vcuenta    = '';
    LET vfecha_hoy = '';
    LET vdia       = -1;
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamconcilchq.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparamconcilchq.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vdia = WEEKDAY(vfecha_hoy);
    
    IF vdia = 6 THEN
     
        -- // VALIDA LA FECHA DE AYER HAYA SIDO HABIL
        LET vfecha_hoy = vfecha_hoy - 1 UNITS DAY;
        
        CALL sp_valfechabil(vfecha_hoy, '-') 
        RETURNING vcodret, vfecha_hoy;
         
       /* -- // OBTIENE EL PROMEDIO DE CUENTAS A PROCESAR POR CADA COMPLEMENTO
        SELECT ROUND(COUNT(*)/9)
          INTO vpromedio
          FROM sc_maechq chq,
               sc_maenoc noc
         WHERE chq.producto = '2000'
           AND ( chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy )
           AND noc.cuenta = chq.cuenta
           AND noc.fecha_alta <= vfecha_hoy; */
		  		   					
        SELECT ROUND(COUNT(*)/9)
		INTO   vpromedio
	    FROM   sc_maechq chq
        WHERE  chq.producto = '2000'
        AND    ( (chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy ) OR (chq.status_cta IN('1', '2', '3') AND chq.fecha_proceso IS NULL));
		   

        LET vcont = 1;  
        
        WHILE vcont <= 8         
            IF vcont = 1 THEN
                LET vbrinca = vpromedio;
                FOREACH
				
				    SELECT SKIP vbrinca FIRST 1 chq.cuenta
				    INTO   vcuenta
                    FROM   sc_maechq chq
				    WHERE  chq.producto = '2000'
                    AND    ( (chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy ) OR (chq.status_cta IN('1', '2', '3') AND chq.fecha_proceso IS NULL))
                    ORDER BY chq.cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniConcilChqComp1';
					   
                END FOREACH;
            ELIF vcont = 2 THEN
                LET vbrinca = vpromedio * 2;
                FOREACH
				
				    SELECT SKIP vbrinca FIRST 1 chq.cuenta
				    INTO   vcuenta
                    FROM   sc_maechq chq
				    WHERE  chq.producto = '2000'
                    AND    ( (chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy ) OR (chq.status_cta IN('1', '2', '3') AND chq.fecha_proceso IS NULL))
                    ORDER BY chq.cuenta
				                
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniConcilChqComp2';
					   
                END FOREACH;
            ELIF vcont = 3 THEN
                LET vbrinca = vpromedio * 3;
                FOREACH
				
				    SELECT SKIP vbrinca FIRST 1 chq.cuenta
				    INTO   vcuenta
                    FROM   sc_maechq chq
				    WHERE  chq.producto = '2000'
                    AND    ( (chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy ) OR (chq.status_cta IN('1', '2', '3') AND chq.fecha_proceso IS NULL))
                    ORDER BY chq.cuenta
                 
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniConcilChqComp3';
					   
                END FOREACH;
            ELIF vcont = 4 THEN
                LET vbrinca = vpromedio * 4;
                FOREACH
				
				    SELECT SKIP vbrinca FIRST 1 chq.cuenta
				    INTO   vcuenta
                    FROM   sc_maechq chq
				    WHERE  chq.producto = '2000'
                    AND    ( (chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy ) OR (chq.status_cta IN('1', '2', '3') AND chq.fecha_proceso IS NULL))
                    ORDER BY chq.cuenta
				                    
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniConcilChqComp4';
					   
                END FOREACH;
            ELIF vcont = 5 THEN
                LET vbrinca = vpromedio * 5;
                FOREACH
				
				    SELECT SKIP vbrinca FIRST 1 chq.cuenta
				    INTO   vcuenta
                    FROM   sc_maechq chq
				    WHERE  chq.producto = '2000'
                    AND    ( (chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy ) OR (chq.status_cta IN('1', '2', '3') AND chq.fecha_proceso IS NULL))
                    ORDER BY chq.cuenta
				
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniConcilChqComp5';
					   
                END FOREACH;
            ELIF vcont = 6 THEN
                LET vbrinca = vpromedio * 6;
                FOREACH
				
				    SELECT SKIP vbrinca FIRST 1 chq.cuenta
				    INTO   vcuenta
                    FROM   sc_maechq chq
				    WHERE  chq.producto = '2000'
                    AND    ( (chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy ) OR (chq.status_cta IN('1', '2', '3') AND chq.fecha_proceso IS NULL))
                    ORDER BY chq.cuenta
                    
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniConcilChqComp6';
					   
                END FOREACH;
            ELIF vcont = 7 THEN
                LET vbrinca = vpromedio * 7;
                FOREACH
				
				    SELECT SKIP vbrinca FIRST 1 chq.cuenta
				    INTO   vcuenta
                    FROM   sc_maechq chq
				    WHERE  chq.producto = '2000'
                    AND    ( (chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy ) OR (chq.status_cta IN('1', '2', '3') AND chq.fecha_proceso IS NULL))
                    ORDER BY chq.cuenta
				                    
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniConcilChqComp7';
					   
                END FOREACH;
            ELIF vcont = 8 THEN
                LET vbrinca = vpromedio * 8;
                FOREACH
				
				   SELECT SKIP vbrinca FIRST 1 chq.cuenta
                     INTO vcuenta
                     FROM sc_maechq chq
                    WHERE chq.producto = '2000'
                      AND ( (chq.status_cta <> '2' OR chq.fecha_proceso >= vfecha_hoy ) OR (chq.status_cta IN('1', '2', '3') AND chq.fecha_proceso IS NULL))
                    ORDER BY chq.cuenta
			                    
                    UPDATE sc_param
                       SET valor = vcuenta
                     WHERE empresa = pempresa
                       AND codparam = 'CtaIniConcilChqComp8';
                END FOREACH;
            END IF;
            LET vcont = vcont + 1;  
            LET vcuenta = '';
        END WHILE;  
    END IF;

    RETURN vcodret;

    END;

END PROCEDURE;