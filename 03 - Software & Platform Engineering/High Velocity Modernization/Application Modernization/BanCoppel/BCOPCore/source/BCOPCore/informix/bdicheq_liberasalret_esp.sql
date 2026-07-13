create procedure "informix".liberasalret_esp(pempresa char(3))
returning char(5);
    
    -- **********************************************************
    -- *        Programa que libera los cheques retenidos       *
    -- *            Autor : Cristian Campos diaz                *
    -- *            Fecha : 06/Septiembre/2007                  *
    -- *            Ver.  : 1.0                                 *
    -- **********************************************************

    define vdias_ret            integer;
    define vmonto               money(14,2);
    define vfecha_alta          date;
    define vnum_chq             integer;
    define vtransacc            char(4);
    define vmonto_ori           money(14,2);
    define vnumero              char(4);
    define vfecha_hoy           date;
    define vfecha_ant           date;
    define vcuenta              char(20);
    define vcancelado           char(1);
    define vcodret              char(5);
    define vcodret2             char(5);
    define vcodret3             char(50);
    define vsqlerr              integer;
    define visamerr             integer;
    define vdescerr             char(50);
    define vRetenido            DECIMAL(14,2);
    define vabierto             CHAR(1);
    define vcomienza            INTEGER;
    define vmincta              char(20);
    define vmaxcta              char(20);
    define vfolio_suc           char(16);

    let vcodret   = "000";
    let vcodret2  = "000";
    let vcodret3  = "";
    let vsqlerr   = 0;
    let visamerr  = 0;
    let vdescerr  = "";
    let vRetenido = 0;
    let vabierto  = "0";
    let vcomienza = -1;
    let vfolio_suc = '';

    --- set debug file to "liberatranret.out";
    --- trace on;
    
    BEGIN

    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "liberatranret.err";
        trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
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
     
    select min(cuenta), max(cuenta)
      into vmincta, vmaxcta
      from sc_docret;
    
    foreach principal with hold for
        select numero
          into vnumero
          from bdinteg:si_transacc
         where empresa = pempresa
           and sistema = "01"
           and numero like "08%"
           and tipo_tran in ("20","21","22")
           and naturaleza = "C"
         order by numero
        
        foreach with hold
            select {+INDEX(sc_docret idx_docret2)}
                   cuenta, transacc, dias_ret, monto, fecha_alta, cancelado, num_chq, monto_ori, folio_suc
              into vcuenta, vtransacc, vdias_ret, vmonto, vfecha_alta, vcancelado, vnum_chq, vmonto_ori, vfolio_suc
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
               
            IF vabierto = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        end foreach;

    end foreach;
    
    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
    
    return vcodret;

    END;

end procedure;