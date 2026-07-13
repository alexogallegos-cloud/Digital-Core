CREATE PROCEDURE "informix".sp_actsdotrimestralc( pcuenta   CHAR(20),
                                                  psucursal CHAR(4),
                                                  panio     SMALLINT,
                                                  pmes      CHAR(2) )
RETURNING CHAR(5);

    DEFINE vCodRet      CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vsqlerr      INTEGER;
    DEFINE visamerr     INTEGER;
    DEFINE vdescerr     CHAR(50);
    DEFINE vcapvigprom1 DECIMAL(18,2);
    DEFINE vcapvigprom2 DECIMAL(18,2);
    DEFINE vcapvigprom3 DECIMAL(18,2);
    DEFINE vcappromtrim DECIMAL(18,2);
    DEFINE vexiste_cta  SMALLINT;

    LET vCodRet      = '000';
    LET vCodRet2     = '';
    LET vCodRet3     = '';
    LET vsqlerr      = 0;
    LET visamerr     = 0;
    LET vdescerr     = 0;
    LET vcapvigprom1 = 0.00;
    LET vcapvigprom2 = 0.00;
    LET vcapvigprom3 = 0.00;
    LET vcappromtrim = 0.00;
    LET vexiste_cta  = 0;

    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        IF vsqlerr != 0 THEN
            LET vCodRet  = vsqlerr;
            LET vCodRet2 = visamerr;
            LET vCodRet3 = vdescerr;
            RETURN vCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/tmp/sp_actsdomensualc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // GUARDA REGISTROS EN TABLA DE SALDOS TRIMESTRALES
    IF pmes = '03' THEN
        SELECT capvigprom1, capvigprom2, capvigprom3
          INTO vcapvigprom1, vcapvigprom2, vcapvigprom3
          FROM sc_sdomensualc
         WHERE cuenta = pcuenta
           AND anio = panio;
    ELIF pmes = '06' THEN
        SELECT capvigprom4, capvigprom5, capvigprom6
          INTO vcapvigprom1, vcapvigprom2, vcapvigprom3
          FROM sc_sdomensualc
         WHERE cuenta = pcuenta
           AND anio = panio;
    ELIF pmes = '09' THEN
        SELECT capvigprom7, capvigprom8, capvigprom9
          INTO vcapvigprom1, vcapvigprom2, vcapvigprom3
          FROM sc_sdomensualc
         WHERE cuenta = pcuenta
           AND anio = panio;
    ELIF pmes = '12' THEN
        SELECT capvigprom10, capvigprom11, capvigprom12
          INTO vcapvigprom1, vcapvigprom2, vcapvigprom3
          FROM sc_sdomensualc
         WHERE cuenta = pcuenta
           AND anio = panio;
    END IF;
    
    LET vcappromtrim = ( ( vcapvigprom1 + vcapvigprom2 + vcapvigprom3) / 3 );
    
    SELECT COUNT(*)
      INTO vexiste_cta
      FROM sc_sdotrimestralc
     WHERE cuenta = pcuenta
       AND anio = panio;
    
    IF vexiste_cta > 0 THEN
        IF pmes = '03' THEN
            UPDATE sc_sdotrimestralc
               SET cappromtrim1 = vcappromtrim
             WHERE cuenta = pcuenta
               AND anio = panio;
        ELIF pmes = '06' THEN
            UPDATE sc_sdotrimestralc
               SET cappromtrim2 = vcappromtrim
             WHERE cuenta = pcuenta
               AND anio = panio;
        ELIF pmes = '09' THEN
            UPDATE sc_sdotrimestralc
               SET cappromtrim3 = vcappromtrim
             WHERE cuenta = pcuenta
               AND anio = panio;
        ELIF pmes = '12' THEN
            UPDATE sc_sdotrimestralc 
               SET cappromtrim4 = vcappromtrim 
             WHERE cuenta = pcuenta 
               AND anio = panio;
        END IF;
    ELSE
        IF pmes = '03' THEN
            INSERT INTO sc_sdotrimestralc VALUES
            ( pcuenta, panio, psucursal, vcappromtrim, 0.00, 0.00, 0.00 );
        ELIF pmes = '06' THEN
            INSERT INTO sc_sdotrimestralc VALUES
            ( pcuenta, panio, psucursal, 0.00, vcappromtrim, 0.00, 0.00 );
        ELIF pmes = '09' THEN
            INSERT INTO sc_sdotrimestralc VALUES
            ( pcuenta, panio, psucursal, 0.00, 0.00, vcappromtrim, 0.00 );
        ELIF pmes = '12' THEN
            INSERT INTO sc_sdotrimestralc VALUES
            ( pcuenta, panio, psucursal, 0.00, 0.00, 0.00, vcappromtrim );
        END IF;   
    END IF;
    
    END;
    
    RETURN vCodRet;
    
END PROCEDURE;