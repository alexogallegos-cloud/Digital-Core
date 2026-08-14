CREATE PROCEDURE "informix".extrae_cont_ant(pempresa     char(3),
                                        psecuencia   smallint,
                                        pmonto_tot   money(14,2),
                                        psucope      char(4),
                                        pproducto    char(4),
                                        pmoneda      char(2),
                                        ptransacc    char(4),
                                        psector      char(2),
                                        pcancelad    char(1),
                                        psuccta      char(4),
                                        pdescripcion char(30))
returning char(5);
    
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';

    define vcodret           char(5); 
    define vsqlerr           integer;
    define vp_num_cte        char(9);
    define v_tipo_cuenta     char(1);
    define v_auxiliar        char(9);
    define v_aux             integer;
    define w_secuencia       smallint;
    define vw_auxiliar       char(1);
    define v_sectoriza_cta   char(1);
    define vsuctmp           char(4);
    define vc_ccmayor        char(10);
    define vc_ccsub          char(10);
    define vc_ccsubsub       char(10);
    define vc_ccsssub        char(10);
    define vc_ccssssub       char(10);
    define vc_sector         char(10);
    define va_ccmayor        char(10);
    define va_ccsub          char(10);
    define va_ccsubsub       char(10);
    define va_ccsssub        char(10);
    define va_ccssssub       char(10);
    define va_sector         char(10);
    define viva_ccmayor      char(10);
    define viva_ccsub        char(10);
    define viva_ccsubsub     char(10);
    define viva_ccsssub      char(10);
    define viva_ccssssub     char(10);
    define viva_sector       char(10);
    define vitr_ccmayor      char(10);
    define vitr_ccsub        char(10);
    define vitr_ccsubsub     char(10);
    define vitr_ccsssub      char(10);
    define vitr_ccssssub     char(10);
    define vitr_sector       char(10);

    let vcodret           = '000';
    let vsqlerr           = 0;
    let vp_num_cte        = ' ';
    let v_tipo_cuenta     = ' ';
    let v_auxiliar        = ' ';
    let v_aux             = 0;
    let w_secuencia       = 0;
    let vw_auxiliar       = ' ';
    let v_sectoriza_cta   = ' ';
    let vsuctmp           = ' ';
    let vc_ccmayor        = ' ';
    let vc_ccsub          = ' ';
    let vc_ccsubsub       = ' ';
    let vc_ccsssub        = ' ';
    let vc_ccssssub       = ' ';
    let vc_sector         = ' ';
    let va_ccmayor        = ' ';
    let va_ccsub          = ' ';
    let va_ccsubsub       = ' ';
    let va_ccsssub        = ' ';
    let va_ccssssub       = ' ';
    let va_sector         = ' ';
    let viva_ccmayor      = ' ';
    let viva_ccsub        = ' ';
    let viva_ccsubsub     = ' ';
    let viva_ccsssub      = ' ';
    let viva_ccssssub     = ' ';
    let viva_sector       = ' ';
    let vitr_ccmayor      = ' ';
    let vitr_ccsub        = ' ';
    let vitr_ccsubsub     = ' ';
    let vitr_ccsssub      = ' ';
    let vitr_ccssssub     = ' ';
    let vitr_sector       = ' ';

    begin

    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret;
        end if;
    end exception;

    let viva_ccmayor  = substr(vgcta_iva, 1, 4);
    let viva_ccsub    = substr(vgcta_iva, 5, 2);
    let viva_ccsubsub = substr(vgcta_iva, 7, 2);
    let viva_ccsssub  = substr(vgcta_iva, 9, 2);
    let viva_ccssssub = substr(vgcta_iva, 11, 2);
    let viva_sector   = substr(vgcta_iva, 13, 2);

    let vitr_ccmayor  = substr(vgcta_itr, 1, 4);
    let vitr_ccsub    = substr(vgcta_itr, 5, 2);
    let vitr_ccsubsub = substr(vgcta_itr, 7, 2);
    let vitr_ccsssub  = substr(vgcta_itr, 9, 2);
    let vitr_ccssssub = substr(vgcta_itr, 11, 2);
    let vitr_sector   = substr(vgcta_itr, 13, 2);

    select c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector,
           a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
      into vc_ccmayor, vc_ccsub, vc_ccsubsub, vc_ccsssub, vc_ccssssub, vc_sector,
           va_ccmayor, va_ccsub, va_ccsubsub, va_ccsssub, va_ccssssub, va_sector
      from bdinteg:si_prodtran
     where empresa = pempresa 
       and producto = pproducto 
       and sistema = vg_sistema 
       and transaccion = ptransacc 
       and secuencia = psecuencia;

    -- / / / / / / / / / /    CUENTA CARGO   / / / / / / / / / /
    if vc_ccmayor is null then 
        let vc_ccmayor = " "; 
    end if;
    
    if vc_ccsub is null then 
        let vc_ccsub = " "; 
    end if;
    
    if vc_ccsubsub is null then 
        let vc_ccsubsub = " "; 
    end if;
    
    if vc_ccsssub is null then 
        let vc_ccsssub = " "; 
    end if;
    
    if vc_ccssssub is null then 
        let vc_ccssssub = " "; 
    end if;

    select tipo_cuenta, sectoriza_cta, auxiliar 
      into v_tipo_cuenta, v_sectoriza_cta, vw_auxiliar
      from bdinteg:si_catalog
     where empresa    = pempresa    
       and ccmayor    = vc_ccmayor    
       and ccsub      = vc_ccsub     
       and ccsubsub   = vc_ccsubsub   
       and ccssubsub  = vc_ccsssub   
       and ccsssubsub = vc_ccssssub   
       and sector     = vc_sector;
       
    if v_sectoriza_cta = "N" then  
        let vc_sector = "00"; -- // La cuenta NO se sectoriza
    else
        let vc_sector = psector;
    end if;
-- Se agrega la transacción de Pago de Cheque Propio por Cámara
    if ptransacc = vgtransacc_t1 or ptransacc = vgtransacc_t2 or ptransacc = '0231' then
        if vc_ccmayor = "1102" then
            let vc_sector = "21";
        end if;
    end if;

    if ptransacc = "1171" then
        if vc_ccmayor = "2402" then
            let vc_sector = "31";
        end if;	 
    end if;

    if ptransacc = vgtransacc_corresp then
        if vc_ccmayor = "1402" then
            let vc_sector = "31";
        end if;
    end if;

    if pcancelad = "V" then
        let pmoneda = vgcodigo_mn;
    end if;

    if vc_ccmayor  = viva_ccmayor  AND 
       vc_ccsub    = viva_ccsub    AND 
       vc_ccsubsub = viva_ccsubsub AND 
       vc_ccsssub  = viva_ccsssub  AND 
       vc_ccssssub = viva_ccssssub THEN
        let vc_sector = viva_sector;
    end if;

    if vc_ccmayor  = vitr_ccmayor   AND
       vc_ccsub    = vitr_ccsub     AND
       vc_ccsubsub = vitr_ccsubsub  AND
       vc_ccsssub  = vitr_ccsssub   AND
       vc_ccssssub = vitr_ccssssub  THEN
        let vc_sector = vitr_sector;
    end if;

    insert into aux_auditerr values
    (pempresa,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,v_auxiliar,pproducto,ptransacc,pmonto_tot);

    let vc_ccmayor = trim(vc_ccmayor);
    let vc_ccsub   = trim(vc_ccsub);
    
    if (ptransacc = '0273' OR ptransacc = '0277') AND vc_ccmayor||vc_ccsub = '951207' THEN
        let psucope = '9201';
    end if;
    
    if (ptransacc = '0276') AND vc_ccmayor||vc_ccsub = '951102' THEN
        let psucope = '9201';
    end if;

    -- // Para cuentas de enlace..
    IF vc_ccmayor[1,2] = "95" THEN 
        insert into sc_contab values
        (pempresa, w_secuencia, psucope, psucope, vc_ccmayor, vc_ccsub, vc_ccsubsub, 
         vc_ccsssub, vc_ccssssub, vc_sector, v_auxiliar, pmonto_tot, 0, pmoneda, pdescripcion);
    ELSE -- // Para el resto de las cuentas...
        insert into sc_contab values
        (pempresa, w_secuencia, psucope, psuccta, vc_ccmayor, vc_ccsub, vc_ccsubsub,
         vc_ccsssub, vc_ccssssub, vc_sector, v_auxiliar, pmonto_tot, 0, pmoneda, pdescripcion);
    END IF;
    
    -- / / / / / / / / / /   CUENTA ABONO   / / / / / / / / / / 
    if va_ccmayor is null then 
        let va_ccmayor = " "; 
    end if;
    
    if va_ccsub is null then 
        let va_ccsub = " "; 
    end if;
    
    if va_ccsubsub is null then 
        let va_ccsubsub = " "; 
    end if;
    
    if va_ccsssub is null then 
        let va_ccsssub = " "; 
    end if;
    
    if va_ccssssub is null then 
        let va_ccssssub = " "; 
    end if;
    
    if va_sector is null then 
        let va_sector = " "; 
    end if;

    select tipo_cuenta, sectoriza_cta, auxiliar 
      into v_tipo_cuenta, v_sectoriza_cta, vw_auxiliar
      from bdinteg:si_catalog
     where empresa    = pempresa    
       and ccmayor    = va_ccmayor    
       and ccsub      = va_ccsub     
       and ccsubsub   = va_ccsubsub   
       and ccssubsub  = va_ccsssub   
       and ccsssubsub = va_ccssssub   
       and sector     = va_sector;
       
    if v_sectoriza_cta = "N" then 
        let va_sector = "00";    -- // La cuenta NO se sectoriza
    else
        let va_sector = psector; -- // Se respeta el sector del cliente
    end if;
-- Se agrega la transacción de Pago de Cheque Propio por Cámara
    if ptransacc = vgtransacc_t1 or ptransacc = vgtransacc_t2 or ptransacc = '0231' then
        if va_ccmayor = "1102" then
            let va_sector = "21";
        end if;
    end if;

    if ptransacc = "1141" then
        if va_ccmayor = "2402" then
            let va_sector = "31";
        end if;	 
    end if;

    if ptransacc = vgtransacc_corresp then
        if va_ccmayor = "1402" then
            let va_sector = "31";
        end if;
    end if;

    if pcancelad = "V" then
        let pmoneda = vgcodigo_mn;
    end if;

    if va_ccmayor  = viva_ccmayor   AND
       va_ccsub    = viva_ccsub     AND
       va_ccsubsub = viva_ccsubsub  AND
       va_ccsssub  = viva_ccsssub   AND
       va_ccssssub = viva_ccssssub  THEN
        let va_sector = viva_sector;
    end if;

    if va_ccmayor  = vitr_ccmayor   AND
       va_ccsub    = vitr_ccsub     AND
       va_ccsubsub = vitr_ccsubsub  AND
       va_ccsssub  = vitr_ccsssub   AND
       va_ccssssub = vitr_ccssssub  THEN
        let va_sector = vitr_sector;
    end if;

    insert into aux_auditerr values
    (pempresa,va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector,v_auxiliar,pproducto,ptransacc,pmonto_tot);

    let va_ccmayor = trim(va_ccmayor);
    let va_ccsub   = trim(va_ccsub);
    
    if ptransacc = '0274' AND va_ccmayor||va_ccsub = '951102' THEN
        let psucope = '9201';
    end if;

    -- // Para cuentas de enlace..
    IF va_ccmayor[1,2] = "95" THEN 
        insert into sc_contab values
        (pempresa, w_secuencia, psucope, psucope, va_ccmayor, va_ccsub, va_ccsubsub, 
         va_ccsssub, va_ccssssub, va_sector, v_auxiliar, 0, pmonto_tot, pmoneda, pdescripcion);
    ELSE -- // Para el resto de las cuentas...
        insert into sc_contab values
        (pempresa, w_secuencia, psucope, psuccta, va_ccmayor, va_ccsub, va_ccsubsub,
         va_ccsssub, va_ccssssub, va_sector, v_auxiliar, 0, pmonto_tot, pmoneda, pdescripcion);
    END IF;

    end;

    return vcodret;

end procedure;