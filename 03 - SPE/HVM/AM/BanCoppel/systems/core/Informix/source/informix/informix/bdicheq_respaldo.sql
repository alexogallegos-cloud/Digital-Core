create procedure "informix".respaldo(pempresa char(3), ptipo_resp char(1))
returning char(5);
    
    define vcodret     char(5);
    define vcodret2    char(5);
    define vcodret3    char(50);
    define vsqlerr     integer;
    define visamerr    integer;
    define vdescerr    char(50);
    define vdirectorio char(50);
    define vdia        char(2);
    define vmes        char(2);
    define vano        char(4);
    define vtabla      char(20);
    define vtablaid    integer;
    define vcolnomb    char(20);
    define vsql2       char(1000);
    define vnomtabla   char(400);
    define vproceso    char(10);
    define vfecha_hoy  date;
    define vruta       char(400);
    define vexiste     char(1);
    define vexiste3    char(1);
    define vexiste2    integer;
    define vexistefin  integer;
    define vsistema    char(2);
    define vgusuario   char(10);
    define vproceso2   char(20);
    define vsql        char(600);
    define vstmt       char(250);
    
    let vcodret    = "000";
    let vsistema   = "01";
    let vgusuario  = user;
    let vexiste2   = 0;
    let vexiste3   = '';
    let vexistefin = 0;
    let vproceso2  = "respaciechq";
    let vsql       = '';
    let vstmt      = '';
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
--        set debug file to "/tmp/respaldo.err";
--        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''', '||
                       'status_proc   = '''||'C'||''', '||
                       'codret        = '''||vcodret||''', '||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso2||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasrespacie.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasrespacie.sql';
            SYSTEM vstmt;
            return vcodret;
        end if;
    end exception;
    
    ON EXCEPTION IN (-668) SET vsqlerr
        SET DEBUG FILE TO TRIM(vnomtabla) || " respalda.err";
        TRACE ON;
       LET vcodret = "000";
        LET vsql2 = vsql2;
    END EXCEPTION WITH RESUME;
    
    --- set debug file to "/tmp/respaldo.out";
    --- trace on;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    select fecha_hoy 
      into vfecha_hoy
      from sc_fechas 
     where empresa = pempresa;

    if ptipo_resp = "A" or ptipo_resp = "a" then
        let vruta = "/cheques/a_cierre/";
        let vproceso = "respacie";
    else
        let vruta = "/cheques/d_cierre/";
        let vproceso = "respdcie";
    end if
    
    let vruta = trim(vruta)||"empresa"||pempresa||"/";

    select count(*)   
      into vexiste2
      from bdinteg:sx_contproc  
     where empresa = pempresa  
       and proceso = vproceso2
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste2 = 0 then
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso2||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vgusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horasrespacie.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasrespacie.sql';
        SYSTEM vstmt;
    else
        select count(*)   
          into vexistefin
          from bdinteg:sx_contproc  
         where empresa     = pempresa  
           and proceso     = vproceso2
           and fecha       = vfecha_hoy
           and sistema     = vsistema
           and status_proc = "F"; 

        if vexistefin = 0 then
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso2||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasrespacie.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasrespacie.sql';
            SYSTEM vstmt;
        else
            LET vcodret = '958';
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso2||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasrespacie.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasrespacie.sql';
            SYSTEM vstmt;
        end if
    end if;  
    
    SELECT "1"
      INTO vexiste3
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = vproceso
       AND fecha = vfecha_hoy;

    IF vexiste3 = "1" THEN
        LET vcodret = "958";
        RETURN vcodret;
    END IF

    select valor 
      into vdirectorio
      from sc_param
     where empresa = pempresa 
       and codparam = "rutaresp";

    if vdirectorio is null or vdirectorio = " " then
        let vcodret = "960";
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vgusuario||''','||
                   'status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso2||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horasrespacie.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasrespacie.sql';
        SYSTEM vstmt;
        return vcodret;
    else
        let vdirectorio = TRIM(vdirectorio);
    end if

    let vdia = day(vfecha_hoy);
    let vmes = month(vfecha_hoy);
    let vano = year(vfecha_hoy);

    if vdia <= 9 then
        let vdia = "0"||vdia;
    end if

    if vmes <= 9 then
        let vmes = "0"||vmes;
    end if

    let vruta = TRIM(vdirectorio)||TRIM(vruta)||vdia||vmes||vano;
    let vsql2 = "mkdir -p "||vruta;
    SYSTEM vsql2;
    
    LET vsql2 = '';
    LET vsql2 = '/usr/bin/chmod 755 '||vruta;
    SYSTEM vsql2;
    
    foreach
        select trim(nombre_tabla) 
          into vtabla
          from sc_tablas
         where nombre_tabla = 'sc_maechq'
          
        let vtabla = TRIM(vtabla);
        
        select tabid 
          into vtablaid
          from systables
         where tabname = vtabla;

        -- // Tabla no existe en la base de datos
        if vtablaid is null then
            let vcodret = "961";
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vgusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso2||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasrespacie.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasrespacie.sql';
            SYSTEM vstmt;
            return vcodret;
        end if

        let vnomtabla = TRIM(vruta)||"/"||TRIM(vtabla)||"."||trim(vdia)||trim(vmes)||trim(vano);
        let vnomtabla = trim(vnomtabla);
        let vsql2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||vnomtabla||'SELECT * FROM '||vtabla||'; " > querychq.sql';
        let vsql2 = vsql2;
        SYSTEM vsql2;
        LET vsql2 = "/ifxsif01/bin/dbaccess bdicheq querychq.sql";
        SYSTEM vsql2;
        let vtabla = '';
    end foreach
    
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET status_proc = '''||'F'||''','||
               'codret          = '''||vcodret||''','||
               'hora_fin        = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso2||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horasrespacie.sql';
    SYSTEM vsql;
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasrespacie.sql';
    SYSTEM vstmt;
    
    update sc_contproc
       set fecha = vfecha_hoy
     where empresa = pempresa 
       and proceso = vproceso;

    return vcodret;
    
    end;
    
end procedure;