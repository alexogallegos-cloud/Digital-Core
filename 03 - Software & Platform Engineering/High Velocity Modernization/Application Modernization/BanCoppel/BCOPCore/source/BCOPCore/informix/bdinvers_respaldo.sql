create procedure "informix".respaldo( pempresa char(3), ptipo_resp char(1) )
returning char(5);

    define vcodret     char(5);
    define vdirectorio char(50);
    define vdia        char(2);
    define vmes        char(2);
    define vano        char(4);
    define vtabla      char(20);
    define vtablaid    integer;
    define vcolnomb    char(20);
    define vsql        char(200);
    define vnomtabla   char(800);
    define vproceso    char(10);
    define vfecha_hoy  date;
    define vruta       char(400);
    define vsqlerr     integer;
    define vexiste     char(1);
    define vEjecutado  SMALLINT;

    let vcodret = "000";
    
    begin
    
    on exception set vsqlerr
        set debug file to "/resplogifx/concicliachq/respaldo_inv.err";
        trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            UPDATE bdinteg:sx_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   codret      = CodRet
             WHERE empresa = pEmpresa
               AND proceso = 'RespInv'
               AND fecha   = vfecha_hoy;
            return vcodret;
        end if;
    end exception;
    
    --- set debug file to "/resplogifx/concicliachq/respaldo_inv.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 3;

    select fecha_hoy 
      into vfecha_hoy
      from sv_fechas 
     where empresa = pempresa;

    SELECT COUNT(*) 
      INTO vEjecutado
      FROM bdinteg:sx_contproc
     WHERE empresa = pEmpresa
       AND proceso = 'RespInv'
       AND fecha   = vfecha_hoy;
       
    IF vEjecutado IS NULL OR vEjecutado = 0 THEN
        INSERT INTO bdinteg:sx_contproc
        ( empresa, proceso, fecha, sistema, status_proc, ejecutivo, hora_ini, hora_fin, codret )
        VALUES
        ( pEmpresa, 'RespInv', vfecha_hoy, '03', 'I', USER, CURRENT, NULL, '000' );
    END IF;
    
    if ptipo_resp = "A" or ptipo_resp = "a" then
        let vruta = "/inversion/a_cierre/";
        let vproceso = "respacie";
    else
        let vruta = "/inversion/d_cierre/";
        let vproceso = "respdcie";
    end if;
    
    let vruta = trim(vruta)||"empresa"||pempresa||"/";

    select valor 
      into vdirectorio
      from bdicheq:sc_param
     where empresa = pempresa 
       and codparam = "rutaresp";

    if vdirectorio is null or vdirectorio = " " then
        let vcodret = "960";
        return vcodret;
    else
        let vdirectorio = TRIM(vdirectorio);
    end if;
    
    select fecha_hoy 
      into vfecha_hoy
      from sv_fechas 
     where empresa = pempresa;
     
    let vdia = day(vfecha_hoy);
    let vmes = month(vfecha_hoy);
    let vano = year(vfecha_hoy);

    if vdia <= 9 then
        let vdia = "0"||vdia;
    end if;

    if vmes <= 9 then
        let vmes = "0"||vmes;
    end if;

    let vruta = TRIM(vdirectorio)||TRIM(vruta)||vdia||vmes||vano;
    let vsql = "mkdir -p "||vruta;
    SYSTEM vsql;
    
    foreach
        select nombre_tabla 
          into vtabla
          from sv_tablas
        
        let vtabla = TRIM(vtabla);
        
        select tabid 
          into vtablaid
          from systables
         where tabname = vtabla;
        
        -- // Tabla no existe en la base de datos
        if vtablaid is null then
            let vcodret = "961";
            return vcodret;
        end if;
        
        let vnomtabla = TRIM(vruta)||"/"||TRIM(vtabla)||"."||vdia||vmes||vano;
        
        -- // Verifica si existe empresa en la tabla
        select 1 
          into vexiste
          from syscolumns
         where tabid = vtablaid 
           and colname = "empresa";
           
        if vexiste is null then
            let vsql = 'echo "UNLOAD TO '|| TRIM(vnomtabla) ||' SELECT * FROM '|| TRIM(vtabla) ||'"'||' > resp_inv.sql';
        else
            let vsql = 'echo "UNLOAD TO '|| TRIM(vnomtabla) ||' SELECT * FROM '|| TRIM(vtabla) ||' WHERE empresa = '|| pempresa ||'"'||' > resp_inv.sql';
        end if;
        
        let vsql = vsql;
        SYSTEM vsql;
        
        LET vsql = "dbaccess bdinvers resp_inv.sql";
        SYSTEM vsql;
    end foreach;

    update sv_contproc
       set fecha = vfecha_hoy
     where empresa = pempresa 
       and proceso = vproceso;

    UPDATE bdinteg:sx_contproc
       SET status_proc = 'F',
           hora_fin    = CURRENT,
           codret      = vcodret
     WHERE empresa = pEmpresa
       AND proceso  = 'RespInv'
       AND fecha    = vfecha_hoy;
        
    return vcodret;
    
    end;
    
end procedure;