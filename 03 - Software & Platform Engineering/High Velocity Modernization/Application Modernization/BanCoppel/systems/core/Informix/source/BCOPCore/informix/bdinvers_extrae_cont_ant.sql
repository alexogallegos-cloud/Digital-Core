CREATE PROCEDURE "informix".extrae_cont_ant(pempresa   char(3),
                                            psecuencia smallint,
                                            pmonto_tot money(14,2),
                                            psucope    char(4),
                                            pproducto  char(4),
                                            pmoneda    char(2),
                                            ptransacc  char(4),
                                            psector    char(2),
                                            pcancelad  char(1),
                                            psuc_cuen  char(4),
                                            pdescripcion char(30),
                                            pcuenta char(20),
                                            pplaza char(3))
returning char(5);

    define vcodret       char(5);
    define vsqlerr       integer;
    define v_tipo_cuenta char(1);
    define vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,
           vc_ccssssub,vc_sector char(10);
    define va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,
           va_ccssssub,va_sector char(10);
    define v_auxiliar char(9);
    define w_secuencia smallint;
    define vw_auxiliar char(1);
    define vcodigo_mn char(2);
    define v_sectoriza_cta char(1);
    define v_sistema char(2);
    define v_plazo smallint;

    let vcodret = "000";
    let v_auxiliar = " ";
    let w_secuencia = 0;

    --- set debug file to "extraecont.out";
    --- trace on;

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;

    select valor 
      into vcodigo_mn
      from bdinteg:si_param
     where empresa = pempresa 
       and descripcion = "codigo mn";

    select sistema 
      into v_sistema
      from bdinteg:si_sistema
     where siglas = "SV";

    -- // Obtine la secuencia
    SELECT plazo 
      INTO v_plazo
      FROM bdinvers:sv_maeinv
     WHERE empresa = pempresa
       AND cuenta = pcuenta
       AND status_cta IN ("1","2");

    IF v_plazo IS NULL THEN
        LET psecuencia = 1;
    ELSE
        SELECT secuencia 
          INTO psecuencia
          FROM bdinvers:sv_plazotasa
         WHERE cod_instrum = pproducto
           AND plaza = pplaza
           AND v_plazo BETWEEN plazo_min AND plazo_max;
    END IF

    IF psecuencia IS NULL THEN
        LET psecuencia = 1;
    END IF

    select c_ccmayor,c_ccsub,c_ccsubsub,c_ccsssub,c_ccssssub,c_sector,
           a_ccmayor,a_ccsub,a_ccsubsub,a_ccsssub,a_ccssssub,a_sector
      into vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,
           vc_sector,va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,
           va_ccssssub,va_sector
      from bdinteg:si_prodtran
     where empresa = pempresa 
       and producto = pproducto 
       and sistema = v_sistema 
       and transaccion = ptransacc 
       and secuencia = psecuencia;

    if vc_ccmayor   is null then let vc_ccmayor   = " "; end if
    if vc_ccsub     is null then let vc_ccsub     = " "; end if
    if vc_ccsubsub  is null then let vc_ccsubsub  = " "; end if
    if vc_ccsssub   is null then let vc_ccsssub   = " "; end if
    if vc_ccssssub  is null then let vc_ccssssub  = " "; end if

    select tipo_cuenta,sectoriza_cta,auxiliar 
      into v_tipo_cuenta,v_sectoriza_cta,vw_auxiliar
      from bdinteg:si_catalog
     where empresa    = pempresa    
       and ccmayor    = vc_ccmayor    
       and ccsub      = vc_ccsub     
       and ccsubsub   = vc_ccsubsub   
       and ccssubsub  = vc_ccsssub   
       and ccsssubsub = vc_ccssssub   
       and sector     = vc_sector;
       
    if v_sectoriza_cta = "N" then  -- La cuenta NO se sectoriza
        let vc_sector = "00";
    else 
        let vc_sector = psector;
    end if

    if pcancelad = "V" then
        let pmoneda = vcodigo_mn;
    end if

    insert into aux_auditerr
    values(pempresa,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,v_auxiliar,pproducto,ptransacc,pmonto_tot);

    LET vc_ccmayor = Trim(vc_ccmayor);

    IF vc_ccmayor[1,2] = "95" THEN -- // Para cuentas de enlace..
        insert into aux_contab
        values(pempresa,w_secuencia,psucope,psucope,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,v_auxiliar,pmonto_tot,0,pmoneda,pdescripcion);    
    ELSE -- // Para el resto de las cuentas...
        insert into aux_contab
        values(pempresa,w_secuencia,psucope,psuc_cuen,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,v_auxiliar,pmonto_tot,0,pmoneda,pdescripcion);
    END IF;

    if va_ccmayor  is null then let va_ccmayor   = " "; end if
    if va_ccsub    is null then let va_ccsub     = " "; end if
    if va_ccsubsub is null then let va_ccsubsub  = " "; end if
    if va_ccsssub  is null then let va_ccsssub   = " "; end if
    if va_ccssssub is null then let va_ccssssub  = " "; end if
    if va_sector   is null then let va_sector    = " "; end if

    select tipo_cuenta,sectoriza_cta,auxiliar 
      into v_tipo_cuenta,v_sectoriza_cta,vw_auxiliar
      from bdinteg:si_catalog
     where empresa    = pempresa    
       and ccmayor    = va_ccmayor    
       and ccsub      = va_ccsub     
       and ccsubsub   = va_ccsubsub   
       and ccssubsub  = va_ccsssub   
       and ccsssubsub = va_ccssssub   
       and sector     = va_sector;
       
    if v_sectoriza_cta = "N" then -- // La cuenta NO se sectoriza
        let va_sector = "00";
    else
        let va_sector = psector;
    end if

    -- // Graba cuenta de CREDITO - ABONO
    if pcancelad = "V" then
        let pmoneda = vcodigo_mn;
    end if

    insert into aux_auditerr
    values(pempresa,va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector,v_auxiliar,pproducto,ptransacc,pmonto_tot);

    LET va_ccmayor = Trim(va_ccmayor);

    IF va_ccmayor[1,2] = "95" THEN --//Para cuentas de enlace..
        insert into aux_contab
        values(pempresa,w_secuencia,psucope,psucope,va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector,v_auxiliar,0,pmonto_tot,pmoneda,pdescripcion);    
    ELSE
        insert into aux_contab
        values(pempresa,w_secuencia,psucope,psuc_cuen,va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector,v_auxiliar,0,pmonto_tot,pmoneda,pdescripcion);
    END IF;  

    end;
    
    return vcodret;
    
end procedure;