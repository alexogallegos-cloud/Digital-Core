create procedure "informix".sp_concilia_ctas_chq( pempresa char(3) )
returning char(5), integer, integer;
    
    define vcodret 		    char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr 		    integer;
    define visamerr		    integer;
    define vdescerr		    char(50);
    define vtransacc        smallint;
    define vcontador1       integer;
    define vcontador2       integer;
    define vfecha_hoy       date;
    define vcuenta          char(20);
    define vsdo_dia_ant     money(14,2);
    define vsdo_actual      money(14,2);
    define vretiros 	    money(14,2);
	define vretiros_sbg	    money(14,2);
    define vabonos		    money(14,2);
    define vsdo_calculado   money(14,2);
    define vdiferencia      money(14,2);
    define vind_dispon      char(1);
    define vind_cierre      char(1);
    define vsdo_param       money(14,2);
    define vfecha           char(8);
    define vhora            datetime hour to second;
    define vhora2           char(8);
    define vfecha_hora      char(15);
    define vsql             char(500);
    define vstmt            char(300);
    
    let vcodret        = '000';
    let vcodret2       = '';
    let vcodret3       = '';
    let vsqlerr 	   = 0;
    let visamerr	   = 0;
    let vdescerr	   = '';
    let vtransacc      = 0;
    let vcontador1     = 0;
    let vcontador2     = 0;
    let vfecha_hoy     = '';
    let vcuenta        = '';
    let vsdo_dia_ant   = 0.00;
    let vsdo_actual    = 0.00;
    let vretiros       = 0.00;
	let vretiros_sbg   = 0.00;
    let vabonos        = 0.00;
    let vsdo_calculado = 0.00;
    let vdiferencia    = 0.00;
    let vind_dispon    = '0';
    let vind_cierre    = '0';
    let vsdo_param     = 0.00;
    let vfecha         = '';
    let vhora          = '';
    let vhora2         = '';
    let vfecha_hora    = '';
    let vsql           = '';
    let vstmt          = '';
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/resplogifx/conciliachq/sp_concilia_ctas_chq.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret  = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            if vtransacc = 1 then
                rollback work;
            end if;
            return vcodret, vcontador1, vcontador2;
        end if
    end exception;
    
    --- set debug file to "/resplogifx/conciliachq/sp_concilia_ctas_chq.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select fecha_hoy, ind_disponible, ind_cierre
      into vfecha_hoy, vind_dispon, vind_cierre
      from sc_fechas
     where empresa = pempresa;
     
    if ( vind_dispon = '0' or vind_cierre = '0' ) then
		let vcodret = '004';
		return vcodret, vcontador1, vcontador2;
	end if;
    
    let vfecha = to_char(vfecha_hoy, '%d%m%Y');
    let vhora = current;
    let vhora2 = substr(vhora,1,2)||substr(vhora,4,2)||substr(vhora,7,2);
    let vfecha_hora = vfecha||'_'||vhora2;
    
    truncate table sc_concilia_ctas_chq;
    
    select valor::money(14,2)
      into vsdo_param
      from sc_param
     where codparam = 'MtoParamConciliacion';
    
    foreach with hold 
        select cuenta, sdo_dia_ant, sdo_actual
          into vcuenta, vsdo_dia_ant, vsdo_actual
          from sc_maechq
         where status_cta in('1','3','4','5')
           and sdo_actual >= vsdo_param
         
        begin work;
        let vtransacc = 1;
        
        if vcuenta in('16000000080', '16000000322') then
            commit work;
            let vtransacc = 0;
            continue foreach;
        end if;
        
        let vcontador1 = vcontador1 + 1;
        
        select sum(mov.monto_tot)
          into vretiros
          from sc_movdia mov, 
               bdinteg:si_transacc trx
         where mov.cuenta = vcuenta
           and mov.fech_alt = vfecha_hoy
           and mov.cancelad <> 'S'
           and mov.transacc <> '0232'
           and trx.numero = mov.transacc
           and trx.naturaleza = 'C'
           and trx.se_contabiliza = 'S'
           and trx.sistema = '01'
           and trx.se_emite_edocta = 'S';
		   
        if vretiros is null then
            let vretiros = 0.00;
        end if;
		   
		select sum(monto_tot)
          into vretiros_sbg
          from sc_movdia 
         where cuenta = vcuenta
           and fech_alt = vfecha_hoy
		   and transacc = '3247'
           and cancelad <> 'S';
           
		if vretiros_sbg is null then
            let vretiros_sbg = 0.00;
        end if;
		
		let vretiros = vretiros + vretiros_sbg;
        
        select sum(mov.monto_tot) 
          into vabonos
          from sc_movdia mov, 
               bdinteg:si_transacc trx
         where mov.cuenta = vcuenta
           and mov.fech_alt = vfecha_hoy
           and mov.cancelad <> 'S'
           and mov.transacc = trx.numero
           and trx.naturaleza = 'A'
           and trx.se_contabiliza = 'S'
           and trx.sistema = '01'
           and trx.se_emite_edocta = 'S';
           
        if vabonos is null then
            let vabonos = 0.00;
        end if;
        
        let vsdo_calculado = ( ( vsdo_dia_ant + vabonos ) - vretiros );
        
        let vdiferencia = vsdo_actual - vsdo_calculado;
        
        if vcuenta in('22000001574', '99010000030') then
            if vdiferencia < 0.00 then
                let vdiferencia = vdiferencia * -1;
            end if;
            
            if vdiferencia > 100000.00 then
                let vcontador2 = vcontador2 + 1;
            
                insert into sc_concilia_ctas_chq
                ( fecha_hora, cuenta, estatus, sdo_dia_ant, abonos, retiros, sdo_calculado, sdo_actual, diferencia )
                values
                ( current, vcuenta, 'A', vsdo_dia_ant, vabonos, vretiros, vsdo_calculado, vsdo_actual, vdiferencia );
            end if;
        else
            if vdiferencia <> 0.00 then
                let vcontador2 = vcontador2 + 1;
            
                insert into sc_concilia_ctas_chq
                ( fecha_hora, cuenta, estatus, sdo_dia_ant, abonos, retiros, sdo_calculado, sdo_actual, diferencia )
                values
                ( current, vcuenta, 'A', vsdo_dia_ant, vabonos, vretiros, vsdo_calculado, vsdo_actual, vdiferencia );
            end if;
        end if;
        
        commit work;
        let vtransacc = 0;
        
        let vcuenta = '';
        let vsdo_dia_ant = 0.00;
        let vsdo_actual = 0.00;
        let vretiros = 0.00;
        let vabonos = 0.00;
        let vsdo_calculado = 0.00;
        let vdiferencia = 0.00;
    end foreach;
    
    let vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /resplogifx/conciliachq/concilia_ctas_chq_'||vfecha_hora||'.txt '||
               'SELECT cuenta, sdo_dia_ant, abonos, retiros, sdo_calculado, sdo_actual, diferencia '||
               'FROM sc_concilia_ctas_chq;" > /resplogifx/conciliachq/conciliactaschq.sql';
    system vsql;
    
    let vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliactaschq.sql"; 
    system vstmt;
    
    return vcodret, vcontador1, vcontador2;
    
    end;
    
end procedure;