CREATE PROCEDURE "informix".sp_candiacap(pempresa CHAR(3))
RETURNING CHAR(5);

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcontador    INTEGER;
    DEFINE ven_transacc SMALLINT;
    DEFINE vfecha_ant   CHAR(10);
    DEFINE vsucursal    CHAR(4);  
    DEFINE vcuenta      CHAR(20);
    DEFINE vstatus_cta  CHAR(1);
    DEFINE vnum_cte     CHAR(20);  
    DEFINE vproducto    CHAR(4);  
    DEFINE vfecha_canc  DATE;
    DEFINE vsdo_dia_ant MONEY(18,2);
    DEFINE vsql         CHAR(400);
    DEFINE vstmt        CHAR(200);
    DEFINE vdia         CHAR(2);
    DEFINE vmes         CHAR(2);
    DEFINE vanio        CHAR(4);
    DEFINE vfechades    CHAR(8);
    
    LET vcodret1     = '000';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador    = -1;
    LET ven_transacc = 0;
    LET vfecha_ant   = '';
    LET vsucursal    = '';
    LET vcuenta      = '';
    LET vstatus_cta  = '';
    LET vnum_cte     = '';
    LET vproducto    = '';
    LET vfecha_canc  = '';
    LET vsdo_dia_ant = 0.00;
    LET vsql         = '';
    LET vstmt        = '';
    LET vdia         = '';
    LET vmes         = '';
    LET vanio        = '';
    LET vfechades    = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_candiacap.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_candiacap.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'canceldiariascapt') THEN
        DROP TABLE bdicheq:"informix".canceldiariascapt;
    END IF;
    
    CREATE TABLE bdicheq:"informix".canceldiariascapt
      (
        sucursal                CHAR(4), 
        cuenta                  CHAR(20),
        status_cta              CHAR(1),
        num_cte                 CHAR(20),
        producto                CHAR(4),  
        fecha_canc              DATE,
        sdo_dia_ant             MONEY(18,2),                   
        fecha                   CHAR(10)
      )
    EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;
    
    SELECT fecha_ant
      INTO vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    FOREACH WITH HOLD
        SELECT mae.sucursal, mae.cuenta, mae.status_cta, mae.num_cte, mae.producto, mae.fec_cancelac, mae.sdo_dia_ant 
          INTO vsucursal, vcuenta, vstatus_cta, vnum_cte, vproducto, vfecha_canc, vsdo_dia_ant 
          FROM sc_maechq mae,
               sc_maenoc noc      
         WHERE mae.empresa = noc.empresa
           AND mae.cuenta = noc.cuenta
           AND mae.producto <> '1100'
           AND mae.status_cta = '2'
           AND mae.fec_cancelac = vfecha_ant
           AND noc.fecha_alta < vfecha_ant
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        INSERT INTO canceldiariascapt(sucursal, cuenta, status_cta, num_cte, producto, fecha_canc, sdo_dia_ant, fecha)
        VALUES(vsucursal, vcuenta, vstatus_cta, vnum_cte, vproducto, vfecha_canc, vsdo_dia_ant, vfecha_ant);
        
        LET vcontador = vcontador + 1;
        COMMIT WORK;
        LET ven_transacc = 0;
    END FOREACH;
    
    FOREACH WITH HOLD
        SELECT mae.sucursal, mae.cuenta, mae.status_cta, mae.num_cte, mae.producto, mae.fec_cancelac, mae.sdo_dia_ant
          INTO vsucursal, vcuenta, vstatus_cta, vnum_cte, vproducto, vfecha_canc, vsdo_dia_ant 
          FROM sc_maechq mae,
               sc_maenoc noc      
         WHERE mae.empresa = noc.empresa
           AND mae.cuenta = noc.cuenta
           AND mae.producto = '1100'
           AND mae.status_cta = '2'
           AND mae.fec_cancelac = vfecha_ant 
           AND noc.fecha_alta <> mae.fecultret
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        INSERT INTO canceldiariascapt(sucursal, cuenta, status_cta, num_cte, producto, fecha_canc, sdo_dia_ant, fecha)
        VALUES(vsucursal, vcuenta, vstatus_cta, vnum_cte, vproducto, vfecha_canc, vsdo_dia_ant, vfecha_ant);
        
        LET vcontador = vcontador + 1;
        COMMIT WORK;
        LET ven_transacc = 0;
    END FOREACH;
    
    FOREACH WITH HOLD
        SELECT mae.sucursal, mae.cuenta, mae.status_cta, mae.num_cte, mae.producto, mae.fec_cancelac, mae.sdo_dia_ant
          INTO vsucursal, vcuenta, vstatus_cta, vnum_cte, vproducto, vfecha_canc, vsdo_dia_ant 
          FROM sc_maechq mae,
               sc_maenoc noc      
         WHERE mae.empresa = noc.empresa
           AND mae.cuenta = noc.cuenta
           AND mae.producto = '1100'
           AND mae.status_cta = '2'
           AND mae.fec_cancelac = vfecha_ant 
           AND noc.fecha_alta = mae.fecultret
           AND mae.fecultdep < noc.fecha_alta
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        INSERT INTO canceldiariascapt(sucursal, cuenta, status_cta, num_cte, producto, fecha_canc, sdo_dia_ant, fecha)
        VALUES(vsucursal, vcuenta, vstatus_cta, vnum_cte, vproducto, vfecha_canc, vsdo_dia_ant, vfecha_ant);
        
        LET vcontador = vcontador + 1;
        COMMIT WORK;
        LET ven_transacc = 0;
    END FOREACH;
    
    CREATE INDEX "informix".idx_candiacap ON bdicheq:"informix".canceldiariascapt(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE canceldiariascapt;
    
    LET vfecha_ant = vfecha_ant;
    LET vdia  = SUBSTR(vfecha_ant, 4, 2);
    LET vmes  = SUBSTR(vfecha_ant, 1, 2);
    LET vanio = SUBSTR(vfecha_ant, 7, 4);
    LET vdia  = TRIM(vdia);
    LET vmes  = TRIM(vmes);
    LET vanio = TRIM(vanio);
    LET vfechades = vmes||vdia||vanio;
    
    LET vsql = 'echo "unload to /resplogifx/conciliachq/candiacap_'||vfechades||'.txt '||
               'select * from canceldiariascapt;" > /resplogifx/conciliachq/candiacap.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/candiacap.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;