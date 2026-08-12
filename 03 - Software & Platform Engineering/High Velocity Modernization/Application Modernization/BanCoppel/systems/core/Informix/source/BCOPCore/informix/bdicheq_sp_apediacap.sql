CREATE PROCEDURE "informix".sp_apediacap(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador        INTEGER;
    DEFINE ven_transacc     SMALLINT; 
    DEFINE vfecha_ant       CHAR(10);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsucursal        CHAR(4);  
    DEFINE vplaza           CHAR(3);
    DEFINE vproducto        CHAR(4);  
    DEFINE vnum_cte         CHAR(20);  
    DEFINE vnombre_cte      CHAR(120);
    DEFINE vsdo_dia_ant     MONEY(18,2);
    DEFINE vnombre_suc      CHAR(40);
    DEFINE vnombre_prod     CHAR(40);
    DEFINE vdivisa          CHAR(2);    
    DEFINE vejecutivo       CHAR(8);
    DEFINE vnombre_plaza    CHAR(40);
    DEFINE vregional        CHAR(3);
    DEFINE vfecha           CHAR(10);   
    DEFINE vdesc_divisa     CHAR(30);
    DEFINE vnombre_region   CHAR(40);
    DEFINE vsql             CHAR(400);
    DEFINE vstmt            CHAR(200);
    DEFINE vfechades        CHAR(8);
    DEFINE vdia             CHAR(2);
    DEFINE vmes             CHAR(2);
    DEFINE vanio            CHAR(4);
    DEFINE vfecultdep       DATE;
    DEFINE vtipo_alta       CHAR(8);
    
    LET vcodret1         = '000';
    LET vcodret2         = '000';
    LET vcodret3         = '';
    LET sql_err	         = 0;
    LET isam_err         = 0;
    LET desc_err         = '';
    LET vcontador        = 0;
    LET ven_transacc     = 0;
    LET vcuenta          = '';
    LET vsucursal        = '';
    LET vplaza           = '';
    LET vproducto        = '';
    LET vnum_cte         = '';
    LET vnombre_cte      = '';
    LET vsdo_dia_ant     = 0.00;
    LET vnombre_suc      = '';
    LET vnombre_prod     = '';
    LET vdivisa          = '';
    LET vejecutivo       = '';
    LET vnombre_plaza    = '';
    LET vregional        = '';
    LET vfecha           = ''; 
    LET vdesc_divisa     = '';
    LET vnombre_region   = '';
    LET vsql             = '';
    LET vstmt            = '';
    LET vfecha_ant       = '';
    LET vfechades        = '';
    LET vdia             = '';
    LET vmes             = '';
    LET vanio            = '';
    LET vfecultdep       = '';
    LET vtipo_alta       = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_apediacap.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_apediacap.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'aperdiariascapt') THEN
        DROP TABLE bdicheq:"informix".aperdiariascapt;
    END IF;
    
    CREATE TABLE bdicheq:"informix".aperdiariascapt
      (
        cuenta                  CHAR(20),
        sucursal                CHAR(4),   
        plaza                   CHAR(3),
        producto                CHAR(4),  
        num_cte                 CHAR(20),
        nombre_cte              CHAR(104),
        sdo_dia_ant             MONEY(18,2),
        nombre_suc              CHAR(40),
        nombre_prod             CHAR(40),
        divisa                  CHAR(2),
        ejecutivo               CHAR(8),
        nombre_plaza            CHAR(40),
        regional                CHAR(3),
        fecha                   CHAR(10),
        desc_divisa             CHAR(30),
        nombre_region           CHAR(40),
        tipo_alta               CHAR(8)
      )
    EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
    
    SELECT fecha_ant
      INTO vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    FOREACH WITH HOLD
        SELECT TRIM(noc.cuenta), TRIM(noc.ejecutivo), TRIM(chq.sucursal), TRIM(chq.plaza), TRIM(chq.producto), 
               TRIM(chq.num_cte), chq.sdo_dia_ant, TRIM(prod.nombre), TRIM(prod.divisa), chq.fecultdep
          INTO vcuenta, vejecutivo, vsucursal, vplaza, vproducto, vnum_cte, vsdo_dia_ant, vnombre_prod, vdivisa, vfecultdep
          FROM sc_maenoc noc,
               sc_maechq chq,
               sc_producto prod
         WHERE noc.empresa = pempresa
           AND noc.cuenta = chq.cuenta
           AND noc.fecha_alta = vfecha_ant
           AND chq.empresa = noc.empresa
           AND chq.cuenta = noc.cuenta
           AND prod.empresa = chq.empresa
           AND prod.producto = chq.producto
		   AND chq.status_cta <> '2'
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        SELECT TRIM(nombre1)||" "||TRIM(nombre2)||" "||TRIM(apell_paterno)||" "||TRIM(apell_materno)
          INTO vnombre_cte
          FROM bdinteg:si_cliente
         WHERE numcte = vnum_cte;
         
        SELECT TRIM(nombre)
          INTO vnombre_suc
          FROM bdinteg:si_sucursales
         WHERE sucursal = vsucursal
           AND empresa = pempresa;
           
        SELECT TRIM(nombre), TRIM(regional)
          INTO vnombre_plaza, vregional
          FROM bdinteg:si_plazas
         WHERE plaza = vplaza
           AND empresa = pempresa;
           
        SELECT TRIM(nombre)
          INTO vnombre_region
          FROM bdinteg:si_regional
         WHERE regional = vregional
           AND empresa = pempresa;
        
        SELECT TRIM(descripcion)
          INTO vdesc_divisa
          FROM bdinteg:si_divisas
         WHERE empresa = pempresa
           AND divisa = vdivisa;
           
        IF vproducto = '1100' THEN
            IF vfecultdep < vfecha_ant THEN
                LET vtipo_alta = 'RENOVADA';
            ELSE
                LET vtipo_alta = 'ALTA';
            END IF;
        ELSE
            LET vtipo_alta = 'ALTA';
        END IF;
        
        INSERT INTO aperdiariascapt VALUES 
        ( vcuenta, vsucursal, vplaza, vproducto, vnum_cte, vnombre_cte, vsdo_dia_ant, vnombre_suc, vnombre_prod, 
          vdivisa, vejecutivo, vnombre_plaza, vregional, vfecha_ant, vdesc_divisa, vnombre_region, vtipo_alta );
        
        LET vcontador = vcontador + 1;
        COMMIT WORK;
        LET ven_transacc = 0;
    END FOREACH;
    
    CREATE INDEX "informix".idx_apediacap ON bdicheq:"informix".aperdiariascapt(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE aperdiariascapt;
    
    LET vfecha_ant = vfecha_ant;
    LET vdia  = SUBSTR(vfecha_ant, 4, 2);
    LET vmes  = SUBSTR(vfecha_ant, 1, 2);
    LET vanio = SUBSTR(vfecha_ant, 7, 4);
    LET vdia  = TRIM(vdia);
    LET vmes  = TRIM(vmes);
    LET vanio = TRIM(vanio);
    LET vfechades = vmes||vdia||vanio;
    
    
    LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/apediacap_'||vfechades||'.txt '||
               ' select * from aperdiariascapt order by divisa, sucursal, producto, cuenta;" > /resplogifx/conciliachq/apediacap.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/apediacap.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    EXECUTE PROCEDURE "informix".sp_candiacap(pempresa)
    INTO vcodret2;
    
    END;
    
    RETURN vcodret1, vcodret2, vcontador;
    
END PROCEDURE;