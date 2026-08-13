CREATE PROCEDURE "informix".sp_calculaintaclaraciones( pfechaini DATE, 
                                                       pfechafin DATE, 
                                                       pcuenta   CHAR(20), 
                                                       pmonto    MONEY(18,2) )

RETURNING CHAR(5), MONEY(18,2);
    
    DEFINE GLOBAL vgcuenta      CHAR(20)    DEFAULT " ";
    DEFINE GLOBAL vgTasaVar     CHAR(1)     DEFAULT "";
    DEFINE GLOBAL vgfecha_hoy   DATE        DEFAULT " ";

    DEFINE vsql_err         INTEGER;
    DEFINE visam_err        INTEGER;
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    
    DEFINE vmonto_calc      MONEY(18,2);
    DEFINE vdias            INTEGER;
    DEFINE vdiasanio        INTEGER;
    DEFINE vempresa         CHAR(3);
    DEFINE vtasa            CHAR(8);
    DEFINE vnum_cte         CHAR(20);
    DEFINE ves_fisica       CHAR(1);
    DEFINE vtipper          CHAR(1);
    DEFINE vfechaini        DATE;
    DEFINE vcapital         MONEY(18,2);
    DEFINE vinteres         MONEY(18,2);
    DEFINE vcapital_acum    MONEY(18,2);
    DEFINE vsdo_promedio    MONEY(18,2);
    DEFINE vvaltasa         DECIMAL(9,6);
    DEFINE vintinvcrece     MONEY(18,2);
    DEFINE vintereses       MONEY(18,2);
    DEFINE vfecha           DATE;
    
    DEFINE vvalorISR        DECIMAL(9,6);
    DEFINE vanio            SMALLINT;
    DEFINE vresiduo         DECIMAL(6,2);
    DEFINE vaniobase        INTEGER;
    DEFINE vsalariomin      DECIMAL(10,2);
    DEFINE vdiassalariomin  SMALLINT;
    DEFINE vbase_excenta    MONEY(18,2);
    DEFINE vbase_gravable   MONEY(18,2);
    DEFINE visr             MONEY(14,2);
    DEFINE vtasa_isr        DECIMAL(9,6);
    
    LET vsql_err        = 0;
    LET visam_err       = 0;
    LET vcodret1        = '';
    LET vcodret2        = '';
    
    LET vmonto_calc     = 0.00;
    LET vdias           = 0;
    LET vdiasanio       = 360;
    LET vempresa        = '001';
    LET vtasa           = '';
    LET vnum_cte        = '';
    LET ves_fisica      = '';
    LET vtipper         = '';
    LET vfechaini       = '';
    LET vcapital        = 0.00;
    LET vinteres        = 0.00;
    LET vcapital_acum   = 0.00;
    LET vsdo_promedio   = 0.00;
    LET vvaltasa        = 0;
    LET vintinvcrece    = 0.00;
    LET vintereses      = 0.00;
    LET vfecha          = '';
    
    LET vvalorISR       = 0;
    LET vanio           = '';
    LET vresiduo        = 0;
    LET vaniobase       = 0;
    LET vsalariomin     = 0.00;
    LET vdiassalariomin = 0;
    LET vbase_excenta   = 0.00;
    LET vbase_gravable  = 0.00;
    LET visr            = 0.00;
    LET vtasa_isr       = 0;
    
    BEGIN
    
    ON EXCEPTION SET vsql_err, visam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_calculaintaclaraciones.err";
        --- TRACE ON;
        IF vsql_err <> 0 THEN
            LET vcodret1 = vsql_err;
            LET vcodret2 = visam_err;
            RETURN vcodret1, vmonto_calc;
        END IF;
    END EXCEPTION;
    
     --SET DEBUG FILE TO "/tmp/pruebasOptimizacion/bloque1/sp_calculaintaclaracionesTASF.out";
     --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    
    IF ( pfechaini is null OR pfechaini = '' OR pfechafin is null OR pfechafin = '' OR pfechafin <= pfechaini ) OR 
       ( pmonto is null OR pmonto = '' OR pmonto <= 0.00 ) OR 
       ( pcuenta is null OR pcuenta = '' ) THEN
        LET vcodret1 = '100';
        RETURN vcodret1, vmonto_calc;
    END IF;
    
    SELECT fecha_hoy
      INTO vgfecha_hoy
      FROM sc_fechas
     WHERE empresa = vempresa;
    
    SELECT mae.cuenta, mae.num_cte, prod.tasa, prod.paga_dividendo
      INTO vgcuenta, vnum_cte, vtasa, vgTasaVar
      FROM sc_maechq mae,
           sc_producto prod
     WHERE mae.empresa = vempresa
       AND mae.cuenta = pcuenta
       AND prod.empresa = mae.empresa
       AND prod.producto = mae.producto;
       
    IF vgcuenta is null OR vgcuenta <> pcuenta THEN
        LET vcodret1 = '100';
        RETURN vcodret1, vmonto_calc;
    END IF;
       
    SELECT {+AVOID_FULL(bdinteg:"informix".si_tipper)} tip.es_fisica
      INTO ves_fisica
      FROM bdinteg:si_cliente cte,
           bdinteg:si_tipper tip
     WHERE cte.numcte = vnum_cte
       AND tip.tpo_persona = cte.tpo_persona;
       
    IF ves_fisica = "S" THEN
        LET vtipper = "F"; 
    ELSE
        LET vtipper = "M"; 
    END IF;
    

    FOREACH
        SELECT FIRST 1 fecha
        INTO vfecha
        FROM bdinteg:si_fechavalor
        WHERE tasa = 'I.S.R.'
        order by fecha desc
    END FOREACH;

    SELECT valor
      INTO vvalorISR
      FROM bdinteg:si_fechavalor
     WHERE tasa = 'I.S.R.'
       AND fecha = vfecha;
       
    LET vvalorISR = vvalorISR / 100;
    
    LET vanio = YEAR(pfechafin);
    LET vresiduo = MOD(vanio, 4);
    
    IF vresiduo = 0 THEN
        LET vaniobase = 366;
    ELSE
        LET vaniobase = 365;
    END IF;
  
    /* ######################## diciembre/2017 ########################
    SELECT valor
      INTO vsalariomin
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'smdf';
    
    SELECT valor
      INTO vdiassalariomin
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'numsmdf';
    
    LET vbase_excenta = vsalariomin * vdiassalariomin * vaniobase;
    ######################## diciembre/2017 ######################## */
    
    SELECT valor 
      INTO vbase_excenta
      FROM sc_param
	 WHERE empresa = vempresa
       AND codparam = "baseexenta"; 
	
    IF vbase_excenta IS NULL THEN
        LET vbase_excenta = 0;
    END IF;
    
    CALL calc_tasa_tasf(vempresa, vtasa, vtipper, pmonto)
    RETURNING vcodret1, vvaltasa, vintinvcrece;
    
    LET vvaltasa = vvaltasa / 100;
    
    LET vdias = (pfechafin - pfechaini); -- Se elimina el + 1 
    
    LET vintereses = (((pmonto * vvaltasa) * vdias) / 360);
    
    IF vvalorISR <> 0 THEN
        LET vtasa_isr = TRUNC( ( ( vvalorISR * vdias ) / vaniobase ), 6 );
        
        IF vtipper = 'F' THEN
            LET vbase_gravable = pmonto - vbase_excenta;
            
            IF vbase_gravable > 0 THEN
                LET visr = TRUNC( ( vbase_gravable * vtasa_isr ), 2 );
            ELSE
                LET visr = 0;
            END IF;
        ELSE
            LET visr = TRUNC( ( pmonto * vtasa_isr ), 2 );
        END IF;
    ELSE
        LET visr = 0;
    END IF;
    
    LET vmonto_calc = (vintereses - visr);
    
    END;

    RETURN vcodret1, vmonto_calc;

END PROCEDURE;