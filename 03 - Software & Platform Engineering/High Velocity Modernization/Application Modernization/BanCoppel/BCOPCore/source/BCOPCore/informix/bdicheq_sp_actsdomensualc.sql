CREATE PROCEDURE "informix".sp_actsdomensualc(pcuenta       CHAR(20),
                                              psucursal     CHAR(4),
                                              psaldoactual  MONEY(14,2),
                                              pintprovnp    MONEY(14,2),
                                              panio         SMALLINT,
                                              pmes          CHAR(2))

    RETURNING CHAR(5);
    
    -- ***********************************************************************************
    -- sp_actsdomensualc
    -- Version              1.0.0
    -- Obejtivo:            Almacena el saldo capital e intereses devengados de captacion.
    -- Creado por:          Alejandro Rueda Sanchez
    -- ModIFicado por:
    -- Ultima ModIFicacion: Junio-2008
    --                      Creación de SPL
    -- ***********************************************************************************

    DEFINE vsqlerr      INTEGER;
    DEFINE vCodRet      CHAR(3);
    DEFINE vcapvigacum  DECIMAL(14,2);
    DEFINE vcapvigprom  DECIMAL(14,2);
    DEFINE vintprovpynp DECIMAL(14,2);
    DEFINE vdiacum      SMALLINT;
    DEFINE vexiste_cta  CHAR(20);

    LET vCodRet = '000';
    LET vsqlerr = 0;
    LET vexiste_cta = '';

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr != 0 THEN
            LET vCodRet=vsqlerr;
            RETURN vCodRet;
        END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "/tmp/sp_actsdomensualc.out";
    -- TRACE ON;

    -- // Calcula el promedio saldo mensual
    SELECT nvl(capvigacum,0), nvl(diacum,0)
      INTO vcapvigacum, vdiacum
      FROM sc_sdodiarioc
     WHERE cuenta = pcuenta
       AND aniomes = panio||pmes;

    IF vdiacum > 0 THEN
        LET vcapvigprom = vcapvigacum / vdiacum;
    ELSE
        LET vcapvigprom = 0;
    END IF 

    -- // Calcula las provisiones pagadas en el mes
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           nvl(sum(monto_tot),0)
      INTO vintprovpynp
      FROM sc_movhis
     WHERE empresa = '001'
       AND cuenta = pcuenta
       AND YEAR(fech_alt) = panio
       AND MONTH(fech_alt) = pmes
       AND cancelad != 'S'
       AND transacc = '3381';
       
    SELECT cuenta
      INTO vexiste_cta
      FROM sc_sdomensualc
     WHERE cuenta = pcuenta
       AND anio = panio;
       
    IF vexiste_cta is not null OR vexiste_cta <> '' THEN
        UPDATE sc_sdomensualc 
           SET capvig1        =  DECODE(pmes,1,psaldoactual,capvig1),
               capvigprom1    =  DECODE(pmes,1,vcapvigprom,capvigprom1),
               intprovnp1     =  DECODE(pmes,1,pintprovnp,intprovnp1),
               intprovpynp1   =  DECODE(pmes,1,vintprovpynp,intprovpynp1),
               capvig2        =  DECODE(pmes,2,psaldoactual,capvig2),
               capvigprom2    =  DECODE(pmes,2,vcapvigprom,capvigprom2),
               intprovnp2     =  DECODE(pmes,2,pintprovnp,intprovnp2),
               intprovpynp2   =  DECODE(pmes,2,vintprovpynp,intprovpynp2),
               capvig3        =  DECODE(pmes,3,psaldoactual,capvig3),
               capvigprom3    =  DECODE(pmes,3,vcapvigprom,capvigprom3),
               intprovnp3     =  DECODE(pmes,3,pintprovnp,intprovnp3),
               intprovpynp3   =  DECODE(pmes,3,vintprovpynp,intprovpynp3),
               capvig4        =  DECODE(pmes,4,psaldoactual,capvig4),
               capvigprom4    =  DECODE(pmes,4,vcapvigprom,capvigprom4),
               intprovnp4     =  DECODE(pmes,4,pintprovnp,intprovnp4),
               intprovpynp4   =  DECODE(pmes,4,vintprovpynp,intprovpynp4),
               capvig5        =  DECODE(pmes,5,psaldoactual,capvig5),
               capvigprom5    =  DECODE(pmes,5,vcapvigprom,capvigprom5),
               intprovnp5     =  DECODE(pmes,5,pintprovnp,intprovnp5),
               intprovpynp5   =  DECODE(pmes,5,vintprovpynp,intprovpynp5),
               capvig6        =  DECODE(pmes,6,psaldoactual,capvig6),
               capvigprom6    =  DECODE(pmes,6,vcapvigprom,capvigprom6),
               intprovnp6     =  DECODE(pmes,6,pintprovnp,intprovnp6),
               intprovpynp6   =  DECODE(pmes,6,vintprovpynp,intprovpynp6),
               capvig7        =  DECODE(pmes,7,psaldoactual,capvig7),
               capvigprom7    =  DECODE(pmes,7,vcapvigprom,capvigprom7),
               intprovnp7     =  DECODE(pmes,7,pintprovnp,intprovnp7),
               intprovpynp7   =  DECODE(pmes,7,vintprovpynp,intprovpynp7),
               capvig8        =  DECODE(pmes,8,psaldoactual,capvig8),
               capvigprom8    =  DECODE(pmes,8,vcapvigprom,capvigprom8),
               intprovnp8     =  DECODE(pmes,8,pintprovnp,intprovnp8),
               intprovpynp8   =  DECODE(pmes,8,vintprovpynp,intprovpynp8),
               capvig9        =  DECODE(pmes,9,psaldoactual,capvig9),
               capvigprom9    =  DECODE(pmes,9,vcapvigprom,capvigprom9),
               intprovnp9     =  DECODE(pmes,9,pintprovnp,intprovnp9),
               intprovpynp9   =  DECODE(pmes,9,vintprovpynp,intprovpynp9),
               capvig10       =  DECODE(pmes,10,psaldoactual,capvig10),
               capvigprom10   =  DECODE(pmes,10,vcapvigprom,capvigprom10),
               intprovnp10    =  DECODE(pmes,10,pintprovnp,intprovnp10),
               intprovpynp10  =  DECODE(pmes,10,vintprovpynp,intprovpynp10),
               capvig11       =  DECODE(pmes,11,psaldoactual,capvig11),
               capvigprom11   =  DECODE(pmes,11,vcapvigprom,capvigprom11),
               intprovnp11    =  DECODE(pmes,11,pintprovnp,intprovnp11),
               intprovpynp11  =  DECODE(pmes,11,vintprovpynp,intprovpynp11),
               capvig12       =  DECODE(pmes,12,psaldoactual,capvig12),
               capvigprom12   =  DECODE(pmes,12,vcapvigprom,capvigprom12),
               intprovnp12    =  DECODE(pmes,12,pintprovnp,intprovnp12),
               intprovpynp12  =  DECODE(pmes,12,vintprovpynp,intprovpynp12)
         WHERE cuenta = pcuenta
           AND anio = panio;
    ELSE
        INSERT INTO sc_sdomensualc
        VALUES (pcuenta, panio, psucursal,
                DECODE(pmes,1,psaldoactual,0),
                DECODE(pmes,1,vcapvigprom,0),
                DECODE(pmes,1,pintprovnp,0),
                DECODE(pmes,1,vintprovpynp,0),
                DECODE(pmes,2,psaldoactual,0),
                DECODE(pmes,2,vcapvigprom,0),
                DECODE(pmes,2,pintprovnp,0),
                DECODE(pmes,2,vintprovpynp,0),
                DECODE(pmes,3,psaldoactual,0),
                DECODE(pmes,3,vcapvigprom,0),
                DECODE(pmes,3,pintprovnp,0),
                DECODE(pmes,3,vintprovpynp,0),
                DECODE(pmes,4,psaldoactual,0),
                DECODE(pmes,4,vcapvigprom,0),
                DECODE(pmes,4,pintprovnp,0),
                DECODE(pmes,4,vintprovpynp,0),
                DECODE(pmes,5,psaldoactual,0),
                DECODE(pmes,5,vcapvigprom,0),
                DECODE(pmes,5,pintprovnp,0),
                DECODE(pmes,5,vintprovpynp,0),
                DECODE(pmes,6,psaldoactual,0),
                DECODE(pmes,6,vcapvigprom,0),
                DECODE(pmes,6,pintprovnp,0),
                DECODE(pmes,6,vintprovpynp,0),
                DECODE(pmes,7,psaldoactual,0),
                DECODE(pmes,7,vcapvigprom,0),
                DECODE(pmes,7,pintprovnp,0),
                DECODE(pmes,7,vintprovpynp,0),
                DECODE(pmes,8,psaldoactual,0),
                DECODE(pmes,8,vcapvigprom,0),
                DECODE(pmes,8,pintprovnp,0),
                DECODE(pmes,8,vintprovpynp,0),
                DECODE(pmes,9,psaldoactual,0),
                DECODE(pmes,9,vcapvigprom,0),
                DECODE(pmes,9,pintprovnp,0),
                DECODE(pmes,9,vintprovpynp,0),
                DECODE(pmes,10,psaldoactual,0),
                DECODE(pmes,10,vcapvigprom,0),
                DECODE(pmes,10,pintprovnp,0),
                DECODE(pmes,10,vintprovpynp,0),
                DECODE(pmes,11,psaldoactual,0),
                DECODE(pmes,11,vcapvigprom,0),
                DECODE(pmes,11,pintprovnp,0),
                DECODE(pmes,11,vintprovpynp,0),
                DECODE(pmes,12,psaldoactual,0),
                DECODE(pmes,12,vcapvigprom,0),
                DECODE(pmes,12,pintprovnp,0),
                DECODE(pmes,12,vintprovpynp,0));
    END IF;

    END
    
    RETURN vCodRet;
    
END PROCEDURE 

DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".cancela_invcrec(pempresa char(3))

RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE nComit           INTEGER;
    DEFINE vsql             CHAR(200);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(20);
    
    DEFINE vcuenta          CHAR(20);
    DEFINE vsucursal        CHAR(4);
    DEFINE vimporte         MONEY(14,2);
    DEFINE vtransacc        CHAR(4);
    DEFINE vfecha_cargo     DATE;
    DEFINE vdispo           MONEY(14,2);
    DEFINE vcargo           MONEY(14,2);
    
    LET vcodret     = "000";
    LET vcodret2    = "000";
    LET sql_err     = 0;
    LET isam_err    = 0;
    LET nComit      = 0;
    LET vcuantos    = -1;
    LET vcontador   = 0;
    LET vsql        = '';
    LET vhora       = '';
    LET vfolio      = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            LET vcodret2 = isam_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vcontador;
        END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "/resplogifx/conciliachq/cancela_invcrec.out";
    -- TRACE ON;
    
    LET vcuenta      = '';
    LET vsucursal    = '';
    LET vimporte     = 0.00;
    LET vtransacc    = '';
    LET vfecha_cargo = '';
    LET vdispo       = 0.00;
    LET vcargo       = 0.00;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'invcrecxcancelar') THEN
        DROP TABLE invcrecxcancelar;
    END IF;
    
    CREATE RAW TABLE invcrecxcancelar( cuenta char(20) ) LOCK MODE ROW;
    
    LET vsql = '';
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/inv_creciente_cancelar.unl INSERT INTO invcrecxcancelar" > /resplogifx/conciliachq/invcrecxcanc.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/invcrecxcanc.sql';
    -- LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/invcrecxcanc.sql';
    SYSTEM vsql;
    
    UPDATE STATISTICS MEDIUM FOR TABLE invcrecxcancelar;

    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta, sucursal, sdo_actual
          INTO vcuenta, vsucursal, vimporte
          FROM sc_maechq
         WHERE empresa = pempresa 
           AND cuenta IN (SELECT cuenta FROM invcrecxcancelar)

        IF vcuantos = -1 THEN
            BEGIN WORK;
            LET nComit = 1;
            LET vcuantos = 0;
        END IF
        
        CALL cargo_ref(pempresa, vsucursal, "informix", "0252", 
                       "0252", vfolio, vcuenta, 0, vimporte, "01", 
                       "CARGO POR CORRECCION", " ", "informix")
        RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;
        
        IF vcodret = '000' THEN
            UPDATE sc_maechq
               SET status_cta = '2'
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF;
        
        LET vcuantos = vcuantos + 1;
        
        IF vcuantos >= 1 THEN
            LET vcontador = vcontador +  vcuantos;
            LET vcuantos = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta = '';
        LET vsucursal = '';
        LET vimporte = 0.00;
        LET vtransacc = '';
        LET vfecha_cargo = '';
        LET vdispo = 0.00;
        LET vcargo = 0.00;

    END FOREACH

    IF nComit = 1 THEN
        LET nComit = 0;
        COMMIT WORK;
    END IF;

    END;
    
    DROP TABLE invcrecxcancelar;

    RETURN vcodret, vcodret2, vcontador;

END PROCEDURE;