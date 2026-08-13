CREATE PROCEDURE "informix".sp_rptmovsdiariospeicron( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50);
    
    DEFINE vcodret1     char(5);
    DEFINE vcodret2     char(5);
    DEFINE vcodret3     char(50);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE desc_err     char(50);
    DEFINE vfecha_hoy   CHAR(10);
    DEFINE vsql         CHAR(900);
    DEFINE vstmt        CHAR(300);
    DEFINE vfechades    CHAR(15);
    DEFINE vfecha_spei  CHAR(10);
    DEFINE vfecha       char(8);
    DEFINE vhora        datetime hour to second;
    DEFINE vhora2       char(8);
    
    LET vcodret1    = "000";               
    LET vcodret2    = '000';
    LET vcodret3    = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err     = 0;                   
    LET isam_err    = 0;
    LET desc_err    = '';  
    LET vfecha_hoy  = ''; 
    LET vsql        = '';
    LET vstmt       = '';
    LET vfechades   = '';
    LET vfecha_spei = '';
    LET vfecha         = '';
    LET vhora          = '';
    LET vhora2         = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptmovsdiariospeicron.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptmovsdiariospeicron.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT vchrvalor
      INTO vfecha_spei
      FROM bdispei:tblparametros
     WHERE vchrcveparametro = 'FECHA_OPERACION';
     
    LET vfecha_hoy = SUBSTR(vfecha_spei,4,2)||'/'||SUBSTR(vfecha_spei,1,2)||'/'||SUBSTR(vfecha_spei,7,4);
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vfecha = SUBSTR(vfecha_spei,1,2)||SUBSTR(vfecha_spei,4,2)||SUBSTR(vfecha_spei,7,4);
    LET vhora  = current;
    LET vhora2 = substr(vhora,1,2)||substr(vhora,4,2)||substr(vhora,7,2);
    
    LET vfechades = vfecha||'_'||vhora2;
    
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
               'ORDER BY 4, 5 DESC;" > /resplogifx/conciliachq/spei/movsspeicron.sql';
    SYSTEM vsql;
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/spei/movsspeicron.sql"; 
    SYSTEM vstmt;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3;
    
END PROCEDURE;