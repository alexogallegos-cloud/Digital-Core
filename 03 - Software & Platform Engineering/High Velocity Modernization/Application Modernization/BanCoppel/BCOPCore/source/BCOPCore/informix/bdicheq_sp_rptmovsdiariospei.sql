CREATE PROCEDURE "informix".sp_rptmovsdiariospei( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50);
    
    DEFINE vcodret1             char(5);
    DEFINE vcodret2             char(5);
    DEFINE vcodret3             char(50);
    DEFINE sql_err              integer;
    DEFINE isam_err             integer;
    DEFINE desc_err             char(50);
    DEFINE vfecha_hoy           date;
    DEFINE vsql                 CHAR(900);
    DEFINE vstmt                CHAR(300);
    DEFINE vfechades            CHAR(8);
    
    LET vcodret1   = "000";               
    LET vcodret2   = '000';
    LET vcodret3   = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err    = 0;                   
    LET isam_err   = 0;
    LET desc_err   = '';  
    LET vfecha_hoy = ''; 
    LET vsql       = '';
    LET vstmt      = '';
    LET vfechades  = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptmovsdiariospei.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptmovsdiariospei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pempresa;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vfechades = TO_CHAR(vfecha_hoy, '%d%m%Y');
    
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/spei/movs_spei_'||vfechades||'.csv '||
               'SELECT mov.fech_alt, mov.fech_hor, mov.cuenta, mov.transacc||'' ''||trx.descripcion, mov.monto_tot, mov.referencia '||
               'FROM bdicheq:sc_movdia mov, bdinteg:si_transacc trx '||
               'WHERE mov.cancelad <> ''S'' '||
               'AND mov.transacc in(''0273'',''0274'',''0276'',''0277'',''0446'',''0447'') '||
               'AND trx.numero = mov.transacc '||
               'AND mov.fech_val = '''||vfecha_hoy||''' '||
               'UNION ALL '||
               'SELECT mov.fech_alt, mov.fech_hor, mov.cuenta, mov.transacc||'' ''||trx.descripcion, mov.monto_tot, mov.referencia '||
               'FROM bdicheq:sc_movhis mov, bdinteg:si_transacc trx '||
               'WHERE mov.cancelad <> ''S'' '||
               'AND mov.transacc in(''0273'',''0274'',''0276'',''0277'',''0446'',''0447'') '||
               'AND trx.numero = mov.transacc '||
               'AND mov.fech_val = '''||vfecha_hoy||''' '||
               'ORDER BY 4, 5 DESC;" > /resplogifx/conciliachq/spei/movsspei.sql';
    SYSTEM vsql;
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/spei/movsspei.sql"; 
    SYSTEM vstmt;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3;
    
END PROCEDURE;