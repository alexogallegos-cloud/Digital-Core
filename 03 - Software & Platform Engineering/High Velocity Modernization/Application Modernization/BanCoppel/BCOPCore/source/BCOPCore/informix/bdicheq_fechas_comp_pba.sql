create procedure "informix".fechas_comp_pba( pempresa char(3) )
returning char(5);
    
    define vsqlerr              integer;
    define visamerr             integer;
    define vdescerr             char(50);
    define vcodret              char(5);
    define vcodret2             char(5);
    define vcodret3             char(50);
    
    define vcodret_ctasdesc     char(5);
    define vcodret_ctasdesc2    char(5);
    define vcodret_ctasdesc3    char(5);
    define vcodret_ctasdesc4    integer;
    define vcodret_ctasdesc5    integer;
    define vcodret_ctasefecn    char(5);
    define vcodret_ctasefecj    char(5);
    define vcodret_invsincta    char(5);
    define vcodret_invsincta2   char(60);
    define vcodret_invconcta    char(5);
    define vcodret_invconcta2   char(60);
    define vcodret_pagconcta    char(5);
    define vcodret_pagconcta2   char(60);
    define vcodret_desbivr      char(5);
    define vfecha_hoy           date;
    define vpri_hab_mes         date;
    define vfecha_ant           date;
    
    let vsqlerr  = 0;
    let visamerr = 0;
    let vdescerr = '';
    let vcodret  = "000";
    let vcodret2 = "";
    let vcodret3 = "";
    let vcodret_ctasdesc   = '';
    let vcodret_ctasdesc2  = '';
    let vcodret_ctasdesc3  = '';
    let vcodret_ctasdesc4  = 0;
    let vcodret_ctasdesc5  = 0;
    let vcodret_ctasefecn  = '';
    let vcodret_ctasefecj  = '';
    let vcodret_invsincta  = '';
    let vcodret_invsincta2 = '';
    let vcodret_invconcta  = '';
    let vcodret_invconcta2 = '';
    let vcodret_pagconcta  = '';
    let vcodret_pagconcta2 = '';
    let vcodret_desbivr    = '';
    let vfecha_hoy   = '';
    let vpri_hab_mes = '';
    let vfecha_ant   = '';
    
    --- set debug file to "/resplogifx/conciliachq/fechas_comp_chq.out";
    --- trace on;
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/fechas_comp_chq.err";
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
    select {+index(sc_fechas idx_fechas1)} 
           fecha_hoy, pri_hab_mes, fecha_ant
      into vfecha_hoy, vpri_hab_mes, vfecha_ant
      from sc_fechas 
     where empresa = pempresa;
/*    
    -- // TABLA PARA LA CONCILIACION DE SALDOS E INTERESES DE CAPTACION
    if exists( select dbsname, tabname from sysmaster:systabnames where partnum > 0 and tabname = 'conciliachq') then
        drop table bdicheq:"informix".conciliachq;        
    end if;
    
    create table bdicheq:"informix".conciliachq
      (
        fecha                   date,           
        cuenta                  char(20),
        producto                char(4),        
        num_cte                 char(20),
        genero                  char(1),
        sucursal                char(4),        
        ejecutivo               char(8),
        capital_anterior        money(18,2),    
        movs_cargo              money(18,2),
        movs_abono              money(18,2),    
        capital_calculado       money(18,2),
        capital_actual          money(18,2),
        diferencia_capital      money(18,2),
        interes_anterior        money(18,2),    
        movs_cargo_interes      money(18,2),
        movs_abono_interes      money(18,2),    
        interes_calculado       money(18,2),
        interes_actual          money(18,2),    
        diferencia_interes      money(18,2)
      ) 
    fragment by round robin in dbs_cierrecred1, dbs_cierrecred2, dbs_cierrecred3, dbs_cierrecred4 
    extent size 512000 next size 51200 lock mode row;
    
    create index "informix".idx_conciliachq_cta on bdicheq:"informix".conciliachq(cuenta) in datos03 online;
    create index "informix".idx_conciliachq_prod on bdicheq:"informix".conciliachq(producto) in datos03 online;
	create index "informix".idx_conciliachq_cte on bdicheq:"informix".conciliachq(num_cte) in datos03 online;
    create index "informix".idx_conciliachq_sdo on bdicheq:"informix".conciliachq(capital_actual) in datos03 online;
    update statistics medium for table conciliachq;
    
    -- // TABLA DE DIFERENCIAS PARA LA CONCILIACION DE SALDOS E INTERESES DE CAPTACION
    if exists( select dbsname, tabname from sysmaster:systabnames where partnum > 0 and tabname = 'conciliachq_dif') then
        drop table bdicheq:"informix".conciliachq_dif;
    end if
    
    create table bdicheq:"informix".conciliachq_dif
      (
        fecha                   date,           
        cuenta                  char(20),
        producto                char(4),        
        num_cte                 char(20),
        genero                  char(1),
        sucursal                char(4),        
        ejecutivo               char(8),
        capital_anterior        money(18,2),    
        movs_cargo              money(18,2),
        movs_abono              money(18,2),    
        capital_calculado       money(18,2),
        capital_actual          money(18,2),
        diferencia_capital      money(18,2),
        interes_anterior        money(18,2),    
        movs_cargo_interes      money(18,2),
        movs_abono_interes      money(18,2),    
        interes_calculado       money(18,2),
        interes_actual          money(18,2),    
        diferencia_interes      money(18,2)
      ) 
    extent size 8000 next size 800 lock mode row;
    
    create index "informix".idx_conciliachq_dif on bdicheq:"informix".conciliachq_dif(cuenta) in dbs_idxinteg online;
    update statistics medium for table conciliachq_dif;
 */   
    -- // PROCESO PARA VERIFICAR NUMERO DE DIAS DE CUENTAS DESCONCENTRADAS
    call sp_verifctasdesconcentradas(pempresa) 
    returning vcodret_ctasdesc, vcodret_ctasdesc2, vcodret_ctasdesc3, vcodret_ctasdesc4, vcodret_ctasdesc5;
       
    -- // PROCESO PARA BLOQUEAR O CANCELAR CUENTAS EFECTIVAS NIÑOS CON MAYORIA DE EDAD
    call sp_valmayoedadctaefecnos() 
    returning vcodret_ctasefecn;
    
    -- // PROCESO PARA BLOQUEAR O CANCELAR CUENTAS EFECTIVAS JOVENES CON MAYORIA DE EDAD
    call sp_valmayoedadctaefecjovenes() 
    returning vcodret_ctasefecj;
    
    -- // PROCESO PARA REPORTE DE INVERSIONES CRECIENTES SIN CUENTA EJE CON MAS DE 3 AÑOS
    call sp_rptainvcrecsincta3anios() 
    returning vcodret_invsincta, vcodret_invsincta2;
    
    -- // PROCESO PARA REPORTE DE INVERSIONES CRECIENTES CON MAS DE 3 AÑOS
    call sp_rptainvcrecconcta3anios() 
    returning vcodret_invconcta, vcodret_invconcta2;
    
    -- // PROCESO PARA REPORTE DE INVERSIONES CRECIENTES CON MAS DE 3 AÑOS
    call sp_rptapagares3anios() 
    returning vcodret_pagconcta, vcodret_pagconcta2;
    
    -- // PROCESO PARA DESBLOQUEO DE CLIENTES IVR
    execute procedure bdivr:"informix".ivr_desbloq_ctes()
    into vcodret_desbivr;
    
    set lock mode to not wait;
    
    return vcodret;
    
    end;
    
end procedure;