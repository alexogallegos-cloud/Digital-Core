CREATE PROCEDURE "informix".sp_geninfmovscorresp_201106(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50);

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    
    DEFINE vfecha_ini       DATE;
    DEFINE vfecha_fin       DATE;
    
    DEFINE vsucursal        CHAR(4);
    DEFINE vfecha           DATE;
    DEFINE vno_transacc     INTEGER;
    DEFINE vmonto_tot       DECIMAL(18,2);
    DEFINE vcuantos         INTEGER;
    DEFINE vmonto           DECIMAL(18,2);
    DEFINE vlocalidad       CHAR(12);
    DEFINE vciudad          CHAR(60);
    
    DEFINE vexiste_suc      INTEGER;
    DEFINE vaniomes         CHAR(6);
    DEFINE vsql             CHAR(500);
    
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    
    LET vfecha_ini   = '';
    LET vfecha_fin   = '';
    
    LET vsucursal    = '';
    LET vfecha       = '';
    LET vno_transacc = 0;
    LET vmonto_tot   = 0.00;
    LET vcuantos     = 0;
    LET vmonto       = 0.00;
    LET vlocalidad   = '';
    LET vciudad      = '';
    
    LET vexiste_suc = 0;
    LET vaniomes    = '';
    LET vsql        = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_geninfmovscorresp_201106.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_geninfmovscorresp_201106.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET vfecha_ini = '06/01/2011';
    LET vfecha_fin = '06/30/2011';
    
    -- // MOVIMIENTOS DE CRÉDITO
    CREATE TEMP TABLE sc_movs_cred_corresp(
        sucursal        char(4),
        no_movs_cred    integer,
        monto_cred      decimal(18,2),
        fecha           char(10) ) 
    EXTENT SIZE 1024 NEXT SIZE 512 LOCK MODE ROW;
begin;
    CREATE INDEX idx_movscrecorr ON sc_movs_cred_corresp(sucursal) ONLINE;
commit;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_cred_corresp;
    
    LET vsucursal = '';
    LET vfecha = '';
    LET vno_transacc = 0;
    LET vmonto_tot = 0.00;
    
    FOREACH
        SELECT SUBSTR(folio_suc,1,4), fecha_mov, COUNT(*), SUM(monto)
          INTO vsucursal, vfecha, vno_transacc, vmonto_tot
          FROM bdicred:sd_movhis
         WHERE codigo_fun = '700'
           AND codigo_ref = 1
           AND fecha_mov BETWEEN vfecha_ini AND vfecha_fin
           AND reversado = 'N'
           AND transacc_suc = '6282'
         GROUP BY 1, 2
           
        INSERT INTO sc_movs_cred_corresp(sucursal, no_movs_cred, monto_cred, fecha)
        VALUES(vsucursal, vno_transacc, vmonto_tot, vfecha);
        
        LET vsucursal = '';
        LET vfecha = '';
        LET vno_transacc = 0;
        LET vmonto_tot = 0.00;
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_cred_corresp;
    
    -- // INSERTA MOVIMIENTOS DE CRÉDITO
    LET vsucursal = '';
    LET vcuantos = 0;
    LET vmonto = 0.00;
    LET vfecha = '';
    LET vexiste_suc = 0;
    
    FOREACH
        SELECT sucursal, no_movs_cred, monto_cred, fecha
          INTO vsucursal, vcuantos, vmonto, vfecha
          FROM sc_movs_cred_corresp
          
        SELECT COUNT(*)
          INTO vexiste_suc
          FROM sc_movs_corresp
         WHERE fecha = vfecha
           AND sucursal = vsucursal;
         
        IF vexiste_suc = 0 THEN
            INSERT INTO sc_movs_corresp(sucursal, no_movs_capt, monto_capt, no_movs_cred, monto_cred, fecha)
            VALUES(vsucursal, 0, 0.00, vcuantos, vmonto, vfecha);
        ELSE
            UPDATE sc_movs_corresp
               SET no_movs_cred = vcuantos,
                   monto_cred = vmonto
             WHERE fecha = vfecha
               AND sucursal = vsucursal;
        END IF;
        
        LET vsucursal = '';
        LET vcuantos = 0;
        LET vmonto = 0.00;
        LET vfecha = '';
        LET vexiste_suc = 0;
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_corresp;
    
    -- // INSERTA LAS CIUDADES DE LAS SUCURSALES
    FOREACH
        SELECT UNIQUE sucursal
          INTO vsucursal
          FROM sc_movs_corresp
          
        SELECT localidad_inegi
          INTO vlocalidad
          FROM bdirepaut:sp_r026_establecimiento
         WHERE clave = vsucursal;
           
        SELECT LIMIT 1 ciudad||' '||TRIM(nombre)
          INTO vciudad
          FROM bdinteg:si_ciudades
         WHERE localidad_inegi = vlocalidad;
          
        UPDATE sc_movs_corresp
           SET ciudad = vciudad
         WHERE sucursal = vsucursal;
         
        LET vsucursal = '';
        LET vlocalidad = '';
        LET vciudad = '';
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_movs_corresp;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vaniomes = TO_CHAR(vfecha_fin, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/movscorrespxfechasuc_'||vaniomes||'.txt '||
               ' SELECT ciudad, sucursal, no_movs_capt, monto_capt, no_movs_cred, monto_cred, fecha[4,5]||fecha[1,2]||fecha[9,10]'||
               ' FROM sc_movs_corresp WHERE fecha BETWEEN '''||vfecha_ini||''' AND '''||vfecha_fin||''' ORDER BY fecha, sucursal" > /resplogifx/conciliachq/movtoscorresp.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movtoscorresp.sql"; 
    SYSTEM vsql;
       
    LET vcodret3 = 'EL PROCESO SE REALIZO SATISFACTORIAMENTE';

    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;