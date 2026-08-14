create procedure "informix".fechas( pempresa char(3) )
returning char(5);
    
    define vsqlerr              integer;
    define visamerr             integer;
    define vdescerr             char(50);
    define vcodret              char(5);
    define vcodret2             char(5);
    define vcodret3             char(50);
    define vcodret_movinv       char(5);
    define vfecha_hoy           date;
    define vpri_hab_mes         date;
    define vcuenta              char(20);
    define vmincta              char(20);
    define vmaxcta              char(20);
    define vmontomesant         money(18,2);
    define vfecha_ant           date;
    define vaniomesant          char(6);
    
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = '';
    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vcodret_movinv     = '';
    let vfecha_hoy   = '';
    let vpri_hab_mes = '';
    let vcuenta      = '';
    let vmincta      = '';
    let vmaxcta      = '';
    let vmontomesant = 0.00;
    let vfecha_ant   = '';
    let vaniomesant  = '';
    
--set debug file to "/resplogifx/conciliachq/fechas_chq.out";
--trace on;
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/fechas_chq.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 5;
    
    -- // OBTIENE FECHAS DEL SISTEMA DE CAPTACION
    select {+INDEX(sc_fechas idx_fechas1)} 
           fecha_hoy, pri_hab_mes, fecha_ant
      into vfecha_hoy, vpri_hab_mes, vfecha_ant
      from sc_fechas 
     where empresa = pempresa;
     
    -- // ACTUALIZA INDICADOR DE CIERRE FINALIZADO
    update sc_fechas
       set ind_cierre = '1'
     where empresa = pempresa;
     
    -- // LIMPIA TABLAS DE TRABAJO DE DIFERENTES PROCESOS
    truncate table sc_valpase;
    truncate table sc_totcomp;
    truncate table sc_acumdiacorresp;
    truncate table vedocta;
    truncate table vedoctamov;
    truncate table vedoctamov_proac;
    truncate table sc_acumdiacorrespred;
    truncate table sc_acumdiacorresptec;
    
    -- // PROCESOS ESPECIALES DEL PRIMER DIA DEL MES
    if vfecha_hoy = vpri_hab_mes then
        -- // INICIALIZA TABLA DE DEPOSITOS EN EFECTIVO
        truncate table sc_depositosefectivo;
        
        -- // INICIALIZA TABLA DE RETIROS EN EFECTIVO
        truncate table sc_retirosefectivo;
        
        -- // INICIALIZA TABLA DE PRESTAMOS COPPEL
        truncate table sc_acumtrapres;
    
        -- // PROCESO DE DEPURACION MENSUAL PARA CORRESPONSALES
        let vaniomesant = year(vfecha_ant) || lpad(month(vfecha_ant), 2, '0');
        
        select {+INDEX(sc_param_corresp idx_paramcorresp)}
               valor
          into vmontomesant
          from sc_param_corresp
         where codparam = '003'
           and empresa = pempresa;
           
        insert into sc_corresp_acumulado values(vaniomesant, vmontomesant);
    
        update {+INDEX(sc_param_corresp idx_paramcorresp)} sc_param_corresp
           set valor = 0.00
         where codparam = '003'
           and empresa = pempresa;
           
        update {+INDEX(sc_alertas_corresp idx_alertcorr)} sc_alertas_corresp
           set alertado = 'F'
         where nivel_alerta > 0;
    end if;
    
    -- // ACTUALIZA INVERSIONES CRECIENTES REINVERTIDAS
    foreach with hold
        select {+INDEX(sc_maechq idx_maechq9)} cuenta
          into vcuenta
          from sc_maechq
         where fecha_proceso = '01/01/1900'
           and producto = '1100'
         
        begin work;
        
        update {+INDEX(sc_maechq idx_maechq1)} sc_maechq
           set fecha_proceso = null
         where empresa = pempresa
           and cuenta = vcuenta;
           
        commit work;
    end foreach;
    
    -- // APLICA MOVIMIENTOS PROCEDENTES DEL SISTEMA DE INVERSIONES
    select {+FULL} 
           min(cuenta), max(cuenta) 
      into vmincta, vmaxcta
      from sc_movinver;
    
    delete {+INDEX(sc_movinver ix212_2)} 
      from sc_movinver 
     where cuenta between vmincta and vmaxcta
       and procesado = "S";
       
    call movinver(pempresa) 
    returning vcodret_movinv;
    
    if vcodret_movinv <> "000" then
        insert into sc_valcierre values (pempresa, "MOVINVER", vcodret_movinv);
    end if;
    
    return vcodret;
    
    end;
    
end procedure;