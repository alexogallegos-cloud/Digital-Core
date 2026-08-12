create procedure "informix".liberasalret(pempresa char(3), pejecutivo char(10))
returning char(5);
    
    -- **********************************************************
    -- *        Programa que libera los cheques retenidos       *
    -- *            Autor : Cristian Campos diaz                *
    -- *            Fecha : 06/Septiembre/2007                  *
    -- *            Ver.  : 1.0                                 *
    -- **********************************************************

    define vdias_ret            integer;
    define vdia_res             integer;
    define vmonto               money(14,2);
    define vfecha_alta          date;
    define vnum_chq             integer;
    define vtransacc            char(4);
    define vmonto_ori           money(14,2);
    define vnumero              char(4);
    define vsistema             char(2);
    define vfecha_hoy           date;
    define vfecha_ant           date;
    define vfechab_ant          date;
    define vcuenta              char(20);
    define vcancelado           char(1);
    --- define vrowid               integer;
    define vcodret              char(5);
    define vcodret2             char(5);
    define vcodret3             char(50);
    define vsqlerr              integer;
    define visamerr             integer;
    define vdescerr             char(50);
    define vconproc             integer;
    define vproceso             char(20);
    define vexiste              integer;
    define vexistefin           integer;
    define vRetenido            DECIMAL(14,2);
    define vabierto             CHAR(1);
    define vcomienza            INTEGER;
    define vsql                 char(600);
    define vstmt                char(250);
    define vmincta              char(20);
    define vmaxcta              char(20);
    define vexisteproc          char(12);
    define vcodretsbg1          char(5);
    define vcodretsbg2          char(5);
    define vcontsbg1            integer;
    define vcontsbg2            integer;
    define vcodret_libinterpza  char(5);
    define vcodret_pasamovsret  char(5);
    define vfolio_suc           char(16);
    define vcodret_libspei      char(5);

    let vcodret   = "000";
    let vcodret2  = "000";
    let vcodret3  = "";
    let vsqlerr   = 0;
    let visamerr  = 0;
    let vdescerr  = "";
    let vconproc  = 0;
    let vproceso  = "libsalretchq";
    let vsistema  = "01";
    let vRetenido = 0;
    let vabierto  = "0";
    let vcomienza = -1;
    let vsql      = '';
    let vstmt     = '';
    let vcodretsbg1 = '';
    let vcodretsbg2 = '';
    let vcontsbg1   = 0;
    let vcontsbg2   = 0;
    let vcodret_libinterpza = '';
    let vcodret_pasamovsret = '';
    let vfolio_suc = '';
    let vcodret_libspei = '';

    --- set debug file to "/DBA/INC/20220610/liberatranret.out";
    --- trace on;
    
    BEGIN

    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "liberatranret.err";
        trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||pejecutivo||''', '||
                       'status_proc   = '''||'C'||''', '||
                       'codret        = '''||vcodret||''', '||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
            SYSTEM vstmt;
            
            if vabierto = "1" then
                ROLLBACK WORK;
            end if;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select fecha_hoy, fecha_ant
      into vfecha_hoy, vfecha_ant 
      from sc_fechas  
     where empresa = pempresa;
     
    -- // VALIDA HAYA FINALIZADO CIERRE DE CAPTACION
    select proceso
      into vexisteproc
      from sc_contproc
     where empresa = pempresa
       and proceso = 'cierre'
       and fecha = vfecha_ant;
    
    if vexisteproc is null or vexisteproc = '' then
        let vcodret = "962";       
        return vcodret;
    END IF
    
    -- // VERIFICA CONTROL DE PROCESOS EN INTEGRAL
    select count(*)   
      into vexiste
      from bdinteg:sx_contproc  
     where empresa = pempresa  
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        let vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||pejecutivo||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaslibsalret.sql';
        SYSTEM vsql;
        
        let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
        SYSTEM vstmt;
    else
        select count(*)   
          into vexistefin
          from bdinteg:sx_contproc  
         where empresa     = pempresa  
           and proceso     = vproceso
           and fecha       = vfecha_hoy
           and sistema     = vsistema
           and status_proc = "F"; 

        if vexistefin = 0 then
            let vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||pejecutivo||''', '||
                       'status_proc   = '''||'I'||''', '||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
            SYSTEM vsql;
            
            let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
            SYSTEM vstmt;
        else
            let vcodret = "971";
            
            -- // VERIFICA CONTROL DE PROCESOS EN CHEQUES
            select count(*) 
              into vconproc
              from sc_contproc
             where empresa = pempresa
               and proceso = vproceso
               and fecha = vfecha_hoy;

            if vconproc > 0 then
                if vabierto = 1 then
                    ROLLBACK WORK;  
                end if;
                
                return vcodret;
            end if;     
        end if
    end if; 
    
    execute procedure cal_habil_ant(vfecha_hoy) 
    into vcodret, vfechab_ant;

    if vcodret <> "000" then
        if vabierto = 1 then
            ROLLBACK WORK;  
        end if;
        
        let vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||pejecutivo||''', '||
                   'status_proc   = '''||'C'||''', '||
                   'codret        = '''||vcodret||''', '||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
        SYSTEM vsql;
        
        let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
        SYSTEM vstmt;
        
        return vcodret;
    end if;  

    select min(cuenta), max(cuenta)
      into vmincta, vmaxcta
      from sc_docret;
	  
	select numero from bdinteg:si_transacc
	where empresa = "001"
	and sistema = "01"
	and numero like "08%"
	and tipo_tran in ("20","21","22")
	and naturaleza = "C"
	into temp tmp_tran_pos with no log;

	create index indx_temp_tran_pos on tmp_tran_pos(numero);
    
    foreach principal with hold for

        select numero
          into vnumero
          from tmp_tran_pos
		order by numero
        
        foreach with hold
            select {+INDEX(sc_docret idx_docret2)}
                   /*rowid,*/ cuenta, transacc, dias_ret, monto, fecha_alta, cancelado, num_chq, monto_ori, folio_suc
              into /*vrowid,*/ vcuenta, vtransacc, vdias_ret, vmonto, vfecha_alta, vcancelado, vnum_chq, vmonto_ori, vfolio_suc
              from sc_docret
             where cuenta between vmincta and vmaxcta
               and transacc = vnumero
               and cancelado = 'P'
               and (vfecha_hoy - fecha_alta) >= dias_ret 
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET vabierto = "1";
            END IF;
            
            SELECT sdo_retenido
              INTO vRetenido
              FROM sc_maechq
             where empresa = pempresa
               and cuenta = vcuenta;

            LET vRetenido = vRetenido - vmonto;	

            IF vRetenido >= 0 THEN
                update sc_maechq
                   set sdo_retenido = sdo_retenido - vmonto
                 where empresa = pempresa
                   and cuenta = vcuenta;
            ELSE
                update sc_maechq
                   set sdo_retenido = 0
                 where empresa = pempresa
                   and cuenta = vcuenta;
            END IF
            
            update sc_docret
               set cancelado = "L",
                   dias_ret = 0
             where cuenta = vcuenta
               and transacc = vtransacc
               and cancelado = 'P'
               and fecha_alta = vfecha_alta
               and num_chq = vnum_chq
               and monto_ori = vmonto_ori
               and folio_suc = vfolio_suc;
               --- and rowid = vrowid;
               
            IF vabierto = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        end foreach;

    end foreach;
    
    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
    
    -- // REALIZA LIBERACION DE RETENIDOS INTERPLAZA
    --execute procedure "informix".sp_liberaretinterpza(pempresa)
    --into vcodret_libinterpza;
    
    -- // REALIZA LIBERACION DE RETENIDOS SPEI
    --execute procedure "informix".sp_liberaretspei(pempresa)
    --into vcodret_libspei;
    
    -- // REALIZA COBRO DE SOBREGIROS
    --execute procedure "informix".sp_cobrosbg(pempresa)
    --into vcodretsbg1, vcodretsbg2, vcontsbg1, vcontsbg2;
    
    -- // REALIZA DEPURACION DE MOVS POS 
    --execute procedure "informix".sp_pasamovsret(pempresa)
    --into vcodret_pasamovsret;

    -- // REGISTRA FINALIZACION DEL PROCESO
    update sc_contproc
       set fecha = vfecha_hoy
     where empresa = pempresa
       and proceso = vproceso;

    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||pejecutivo||''', '||
               'status_proc   = '''||'F'||''', '||
               'codret        = '''||vcodret||''', '||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
    SYSTEM vstmt;
    
    return vcodret;

    END;

end procedure;