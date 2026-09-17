create procedure "informix".diasretcta(pempresa char(3),
                                       pcuenta char(20),
                                       pimporte money(14,2),
                                       pnum_chq integer,
                                       pbanco char(4),
                                       pusuario char(8),
                                       ptipolib char(1))
returning char(5);

    define vreferencia                      char(40);
    define sql_err,vrowid                   integer;
    define vcodret                          char (5);
    define vplaza                           char(3);
    define vsuccta,vsucursal                char(4);
    define vfecha                           date;
    define vproducto,vtranlibsbc,vtransuc   char(4);
    define vsdo_actual,vmonto,vimpliberar   money(14,2);
    define vfolsuc                          char(16);
    define vdocto                           integer;
    define vcero                            smallint;
    define vabierto,vstatus                 char(1);
    define vsiglas                          char(2);
    define vcuenta                          char(20);
    define vsecuencia                       smallint;
    define vnum_tarjeta                     char(16);
    define vmaxsec                          smallint;
    define vfecha_alta                      date;
    define vbanco                           char(3);
    define vnumcuenta                       char(20);
	define vfecha_operacion                 date;

    let vabierto = "0";
    let vtransuc = "0000";
    let vdocto   = 0;
    let vcodret  = "000";
    let vcero    = 0;
    let vfecha_alta = '';
    let vbanco = '';
    let vnumcuenta = '';
	let vfecha_operacion = TODAY;

    begin
    
    on exception set sql_err
        if sql_err <> 0 then
            let vcodret = sql_err;
            if vabierto = "1" then
                rollback work;
            end if;
            return vcodret;
        end if;
    end exception;

     --set debug file to "/informix/moha/diasretcta.out";
     --trace on;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    select {+INDEX(sc_fechas idx_fechas1)} fecha_hoy 
      into vfecha 
      from sc_fechas 
     where empresa = pempresa;

    if ptipolib = "D" then -- Devolucion de cheque
        select valor 
          into vtranlibsbc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranlibsbcxdev";
    else
        select valor 
          into vtranlibsbc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranlibsbc";
    end if
    
    begin work;
    
    let vbanco = pbanco;
    let vabierto = "1";
    
    foreach
        select cuenta, monto, folio_suc, referencia, sucursal, num_chq, siglas, fecha_alta, banco, numcuenta
          into vcuenta, vmonto, vfolsuc, vreferencia, vsucursal, vdocto, vsiglas, vfecha_alta, vbanco, vnumcuenta
          from sc_docret_sbc     --MOHA
         where empresa = pempresa 
           and cuenta = pcuenta 
           and banco = vbanco 
           and num_chq = pnum_chq 
           and monto_ori = pimporte 
           and cancelado <> "S"
           
        let vimpliberar = vmonto;
        let vstatus = "D";
        
        if vsiglas = "SC" then
            select mc.sucursal,mc.producto,mc.sdo_actual
              into vsuccta,vproducto,vsdo_actual
              from sc_maechq mc,sc_producto pr
             where mc.empresa = pempresa 
               and mc.cuenta = vcuenta
               and pr.empresa = mc.empresa 
               and pr.producto = mc.producto;
            
            /*
            select max(secuencia) 
              into vmaxsec
              from sc_tarjeta
             where empresa = pempresa 
               and cuenta = pcuenta 
               and tipo_tarjeta = "T";
            
            select num_tarjeta 
              into vnum_tarjeta
              from sc_tarjeta
             where empresa = pempresa 
               and cuenta = pcuenta 
               and secuencia = vmaxsec;
            */
            
            IF vtranlibsbc <> "3249" THEN
                insert into sc_movdia
                values(0,vfolsuc,vsucursal,pusuario,vfecha,vfecha,
                       current hour to fraction(3),vtranlibsbc,vsuccta,vproducto,
                       pempresa,vcuenta," ",vdocto,vimpliberar,vimpliberar,vcero,
                       vcero,vcero," "," ",vsdo_actual,vtransuc,vreferencia,vcero,
                       '',"","",vfecha_operacion);
            END IF;
            
            -- // Se modifico el update para que actualice el imp_chq_sbc en lugar de sdo_retenido
            update sc_maechq
               set imp_chq_sbc = imp_chq_sbc - vimpliberar
             where empresa = pempresa 
               and cuenta = vcuenta;

        else
            select {+INDEX(bdinvers:sv_instrum idx_instrum)}
                   mv.sucursal,mv.cod_instrum,mv.capital,mv.plaza,mv.secuencia
              into vsuccta,vproducto,vsdo_actual,vplaza,vsecuencia
              from bdinvers:sv_maeinv mv,bdinvers:sv_instrum pr
             where mv.empresa = pempresa 
               and mv.cuenta = vcuenta 
               and mv.status_cta <> "4" 
               and pr.cod_instrum = mv.cod_instrum 
               and pr.empresa = mv.empresa;
            
            insert into bdinvers:sv_movdia
            values(pempresa,0,vfolsuc,vplaza,vsucursal,pusuario,vfecha,
                   current hour to fraction(3),vtranlibsbc,vsuccta,vcuenta,
                   vproducto,vcero,vimpliberar,vimpliberar,vcero,vcero," ",
                   vsdo_actual,vtransuc);
            
            update bdinvers:sv_maeinv
               set sdo_retenido = sdo_retenido - vimpliberar
             where empresa = pempresa 
               and cuenta = vcuenta 
               and secuencia = vsecuencia;
        end if
        
        update sc_docret_sbc			--MOHA
           set cancelado = vstatus,
               monto = 0
         where cuenta = vcuenta
           and banco = vbanco
           and numcuenta = vnumcuenta
           and num_chq = vdocto
           and fecha_alta = vfecha_alta
           and monto_ori = pimporte;
        --- where rowid = vrowid;
         
        exit foreach;
        
    end foreach
    
    commit work;
    
    return vcodret;
    
    end;
    
end procedure;