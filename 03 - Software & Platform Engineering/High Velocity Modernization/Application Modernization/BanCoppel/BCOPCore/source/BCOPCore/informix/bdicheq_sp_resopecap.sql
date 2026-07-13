CREATE PROCEDURE "informix".sp_resopecap(pempresa CHAR(3))
RETURNING CHAR(5)  AS vcodret1, 
          CHAR(5)  AS vcodret2, 
          CHAR(50) AS vcodret3;

    DEFINE vcodret1      CHAR(5);
    DEFINE vcodret2      CHAR(5);
    DEFINE vcodret3      CHAR(50);
    DEFINE sql_err       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE desc_err      CHAR(50);
    DEFINE vcomienza     SMALLINT;
    DEFINE ventransacc   SMALLINT;
    DEFINE vcontador     INTEGER;
    DEFINE vfecha_ant    DATE;
    DEFINE vpasomovshist DATE;
    DEFINE vsistema      CHAR(2);
    DEFINE vfecha        CHAR(8);
    DEFINE vsql          CHAR(1200);
    DEFINE vstmt         CHAR(100);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET vcodret3      = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = ''; 
    LET vcomienza     = -1;
    LET ventransacc   = 0;
    LET vcontador     = 0;
    LET vfecha_ant    = '';
    LET vpasomovshist = '';
    LET vsistema      = '01';
    LET vfecha        = ''; 
    LET vsql          = '';
    LET vstmt         = '';
    
    BEGIN

    ON EXCEPTION
        SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_resopecap.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_resopecap.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    
    SELECT fecha_ant
      INTO vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    -- // VERIFICA SE HAYA EFECTUADO EL PASO DE MOVS A HISTORICO
    SELECT fecha 
      INTO vpasomovshist
      FROM sc_contproc
     WHERE empresa = pempresa 
       AND proceso = "pasomovshist";

    IF vpasomovshist <> vfecha_ant THEN
        LET vcodret1 = "953";
        LET vcodret2 = "953";
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE sistema = vsistema
           AND codigo_retorno = vcodret1;
        
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    LET vfecha = TO_CHAR(vfecha_ant, '%d%m%Y');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/resopecap_'||vfecha||'.txt '||
               'SELECT {+INDEX(bdicheq:sc_movhis idx_movhisnew6)} '||
               'TRIM(mov.sucursal)||'' ''||TRIM(suc.nombre), '||
               'TRIM(mov.producto)||'' ''||TRIM(pro.nombre), '||
               'TRIM(mov.transacc)||'' ''||TRIM(trx.descripcion), '||
               'TRIM(trx.naturaleza), '||
               'COUNT(mov.num_serial), '||
               'SUM(mov.monto_tot) '||
               'FROM bdicheq:sc_movhis mov, '||
               'bdicheq:sc_producto pro, '||
               'bdinteg:si_divisas div, '||
               'bdinteg:si_transacc trx, '||
               'bdinteg:si_sucursales suc, '||
               'bdinteg:si_plazas pla, '||
               'bdinteg:si_regional reg, '||
               'bdicheq:sc_fechas fec '||
               'WHERE mov.fech_alt = fec.fecha_ant '||  
               'AND mov.cancelad <> ''S'' '||
               'AND pro.empresa = mov.empresa '||   
               'AND pro.producto = mov.producto '||
               'AND div.empresa = pro.empresa '||   
               'AND div.divisa = pro.divisa '||
               'AND trx.empresa = mov.empresa '||   
               'AND trx.numero = mov.transacc '||
               'AND trx.naturaleza in(''A'',''C'') '||
               'AND suc.sucursal = mov.sucursal '||  
               'AND suc.empresa = mov.empresa '||
               'AND pla.plaza = suc.plaza '||     
               'AND pla.empresa = mov.empresa '||
               'AND reg.regional = pla.regional '||  
               'AND reg.empresa = mov.empresa '||
               'AND fec.empresa = mov.empresa '||
               'GROUP BY 1, 2, 3, 4 '||
               'ORDER BY 1, 2, 3, 4; " > /resplogifx/conciliachq/resopecap.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/resopecap.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';

    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;