CREATE PROCEDURE "informix".sp_valcancelacionespei( pempresa char(3) )
returning char(5);
    
    define vcodret 		    char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr 		    integer;
    define visamerr		    integer;
    define vdescerr		    char(50);
    
    define vfecha_hoy       date;
    define vind_dispon      char(1);
    define vind_cierre      char(1);
    define wvchrvalor       char(10);
    define vfecha_spei      char(10);
    define vhora_ini        datetime hour to second;
    define vhora_fin        datetime hour to second;
    define no_oper          integer;    
    define vCodigoRetorno   CHAR(10);
    
    let vcodret        = '000';
    let vcodret2       = '';
    let vcodret3       = '';
    let vsqlerr 	   = 0;
    let visamerr	   = 0;
    let vdescerr	   = '';
    let vfecha_hoy     = '';
    let vind_dispon    = '0';
    let vind_cierre    = '0';
    let wvchrvalor     = '';
    let vfecha_spei    = '';
    let vhora_ini      = '';
    let vhora_fin      = '';
    let no_oper        = 0;
    let vCodigoRetorno = ''; 
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/resplogifx/conciliachq/spei/sp_valcancelacionespei.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret  = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret;
        end if
    end exception;
    
    --- set debug file to "/resplogifx/conciliachq/spei/sp_valcancelacionespei.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select fecha_hoy, ind_disponible, ind_cierre
      into vfecha_hoy, vind_dispon, vind_cierre
      from sc_fechas
     where empresa = pempresa;
     
    if ( vind_dispon = '0' or vind_cierre = '0' ) then
		let vcodret = '004';
		return vcodret;
	end if;
    
    -- // OBTIENE FECHA SPEI
    select trim(vchrvalor)
      into wvchrvalor
      from bdispei:tblparametros
     where vchrcveparametro = 'FECHA_OPERACION';
     
    let vfecha_spei = substr(wvchrvalor,4,2)||'/'||substr(wvchrvalor,1,2)||'/'||substr(wvchrvalor,7,4);
    
    -- // OBTIENE HORA DE LA ULTIMA EJECUCIÃN DEL PROCESO
    select max(hora_fin)
      into vhora_fin
      from sc_bitcancelacionespei
     where fecha_proc = vfecha_hoy;
     
    if vhora_fin is null then
        let vhora_fin = current;
    end if;
    
    select count(*)
      into no_oper
      from sc_movdia
     where transacc = '0276'
       and cancelad <> 'S'
       --and fech_val = vfecha_spei
       and fech_hor > vhora_fin
	   and fech_alt = vfecha_hoy;
       
    let vhora_ini = vhora_fin;
    let vhora_fin = current;
    
    insert into sc_bitcancelacionespei
    (fecha_proc, hora_ini, hora_fin, fecha_spei, transacc, descripcion, no_trxs)
    values
    (vfecha_hoy, vhora_ini, vhora_fin, vfecha_spei, '0276', 'CANCELACION SPEI', no_oper);
       
    if no_oper > 0 then
        
        execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5539775952',1,0,0,0,0,current,'')
        into vCodigoRetorno;
        
        execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5543885549',1,0,0,0,0,current,'')
        into vCodigoRetorno;			
        
        execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5540778776',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5539887968',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','6671850969',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','6675030641',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5545053772',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','6674765813',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5531880510',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5527106078',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5539999098',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5541419522',1,0,0,0,0,current,'')
        into vCodigoRetorno;
		
		execute procedure bdimnsj:sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','','WARNING: Existen '||no_oper||' cancelaciones spei entra las '||vhora_ini||' y las '||vhora_fin||'','','','','','','','5549098574',1,0,0,0,0,current,'')
        into vCodigoRetorno;	
		
    end if;
    
    return vcodret;
    
    end;
    
end procedure;