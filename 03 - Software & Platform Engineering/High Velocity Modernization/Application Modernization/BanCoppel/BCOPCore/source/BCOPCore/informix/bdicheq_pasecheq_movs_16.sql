create procedure "informix".pasecheq_movs_16(pempresa char(3))
    returning char(5);

    define vcodret char(5);
    define vfecha_hoy date;
    define vsqlerr integer;
    define vsucopero      char(4);
    define vproducto      char(4);
    define vmoneda        char(2);
    define vtransacc      char(4);
    define vmonto_tot     money(14,2);
    define vexento_isr    char(1);
    define vsector        char(2);
    define vvaloriza      char(1);
    define vcancelad      char(1);
    define vsuccta      char(4);
    define wabreviatura   char(20);
    define wdescripcion   char(30);
    define vfechaproc     date;
    define vporcentaje decimal(9,6);
    define vtasa_bruta, vsobretasa decimal(9,6);
    define vtpcambval  decimal(14,6);
    define vmonto1, vmonto2 money(14,2);
    define vdivisa_cambio char(2);
    define vcodigo_mn char(2);
    define vtransacc_t1,vtranprovint char(4);
    define vcobraisr char(1);

    let vcodret       = "000";

    --SET DEBUG FILE TO "pasecheqhis_ash.out";
    -- TRACE ON ;

    begin
        on exception set vsqlerr
            if vsqlerr <> 0 then
                let vcodret = vsqlerr;
                return vcodret;
            end if;
        end exception;

        --************************
        -- Asigna la fecha de hoy
        --************************
        select fecha_hoy into vfecha_hoy
        from sc_fechas where empresa = pempresa;

        truncate table sc_contab;
        truncate aux_auditerr;
        truncate aux_contab;

        --***************************************************************
        -- Extrae tasa base para el calculo de tasa exenta y param de T+1
        --***************************************************************
        select valor into vdivisa_cambio
        from bdinteg:si_param
        where empresa = pempresa and descripcion = "divisa cambio";

        select valor into vcodigo_mn
        from bdinteg:si_param
        where empresa = pempresa and descripcion = "codigo mn";

        select valor into vtransacc_t1
        from sc_param
        where empresa = pempresa and codparam = "tranlibsbc";

        select valor into vtranprovint
        from sc_param
        where empresa = pempresa and codparam = "tranprov";

        --*********************************
        --Extrae tipo de cambio valorizado
        --*********************************
        select precio_venta into vtpcambval
        from bdinteg:si_tpcambio
        where empresa = pempresa 
        and divisa = vdivisa_cambio 
        and fecha_tpcambio = vfecha_hoy 
        and clase_tpcambio = "O";

        if vtpcambval is null then
            select precio_venta into vtpcambval
            from bdinteg:si_histdiv
            where empresa = pempresa
            and divisa = vdivisa_cambio
            and fecha_tc = vfecha_hoy
            and clase_tpcambio = "O"
            and hora_tc = (SELECT MAX(hora_tc)
                           FROM bdinteg:si_histdiv
                           WHERE empresa = pempresa
                           AND divisa = vdivisa_cambio
                           AND fecha_tc = vfecha_hoy
                           AND clase_tpcambio = "O");
   
            if vtpcambval is null then
                let vtpcambval = 1;
            end if
        end if

        set isolation to dirty read;

        --**************************
        --    FOREACH PRINCIPAL
        --**************************
        FOREACH
            select md.sucursal,md.producto,divisa,transacc,monto_tot,
                   exento_isr,cl.sector,tr.valoriza,cancelad,tasa_bruta,
                   ac.sobretasa, mc.sucursal,abreviatura,mc.cobraisr
              into vsucopero,vproducto,vmoneda,vtransacc,vmonto_tot,
                   vexento_isr,vsector,vvaloriza,vcancelad,vtasa_bruta,
                   vsobretasa,vsuccta,wabreviatura,vcobraisr
              from sc_movhis_mov16 md,
                   sc_maechq mc,
             outer sc_auxcont ac,
                   sc_producto pr,
	           bdinteg:si_transacc tr,
                   bdinteg:si_cliente cl,
                   bdinteg:si_tipper tp
             where mc.empresa = pempresa
               and mc.cuenta = md.cuenta
               and ac.empresa = pempresa
               and ac.cuenta = md.cuenta
               and pr.empresa = pempresa
               and pr.producto = md.producto
               and tr.empresa = pempresa
               and tr.numero = md.transacc
               and cl.numcte = mc.num_cte
               and tp.tpo_persona = cl.tpo_persona
               and md.cancelad <> "S"
               and transacc not in(vtransacc_t1,"0231","0232","3313","3314")
               and tr.se_contabiliza = "S"
            union all
            select md.sucursal,ma.producto,divisa,transacc,monto_tot,"N",
	           cl.sector,tr.valoriza,cancelad,0,0,ma.sucursal,
                   tr.abreviatura,ma.cobraisr
	      from sc_movhis_mov16 md,
                   sc_maechq ma,
                   sc_producto pr,
                   bdinteg:si_cliente cl,
                   bdinteg:si_transacc tr
             where ma.empresa = pempresa
               and ma.cuenta = md.cuenta
               and pr.empresa = pempresa
               and pr.producto = md.producto
               and numcte = num_cte
               and tr.empresa = pempresa
               and tr.numero = md.transacc
               and transacc in (vtransacc_t1,"0231","0232","3313","3314")
               and tr.se_contabiliza = "S"
          order by 12,2,4

            let wdescripcion = " ";
            
            if vcobraisr <> "" then
                if vcobraisr = "S" then
                    let vexento_isr = "N";
                else
                    let vexento_isr = "S";
                end if
            end if

            --***************************************************
            -- Verifica si es Transaccion de provision de Interes
            --***************************************************
            if vtransacc = vtranprovint then
                if vmoneda = vcodigo_mn then
                    call extrae_cont(pempresa,1,vmonto_tot,vsucopero,
                                     vproducto,vmoneda,vtransacc,vsector,
                                     vcancelad,vsuccta,wdescripcion) 
                      returning vcodret;
	            continue foreach;
	        end if
	
                if vmoneda != vcodigo_mn and vvaloriza = "S" then
	            call extrae_cont(pempresa,1,vmonto_tot,vsucopero,
                                     vproducto,vmoneda,vtransacc,vsector,
                                     vcancelad,vsuccta,wdescripcion) 
                      returning vcodret;
                
                    let vmonto2 = vmonto_tot * vtpcambval;
	   
                    call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,
                                     vcodigo_mn,vtransacc,vsector,vcancelad,
		                     vsuccta, wdescripcion) 
                      returning vcodret;
                
                    continue foreach;
                end if
            end if

            --**************************************
            -- Verifica si es movimiento valorizado
            --**************************************
            if vmoneda <> vcodigo_mn and vvaloriza = "S"  then
                let vmonto2 = vmonto_tot * vtpcambval;
	
                call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,
                                 vcodigo_mn,vtransacc,vsector,vcancelad,
	                         vsuccta,wdescripcion) 
                  returning vcodret;
            end if

            if vtransacc <> "0231" and vtransacc <> "0232" and
               vtransacc <> "3313" and vtransacc <> "3314" and
               vtransacc <> vtransacc_t1 then
                
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,
                                 vmoneda,vtransacc,vsector,vcancelad,
	                         vsuccta,wdescripcion)  
                  returning vcodret;
            end if

            --**********************************
            -- Contabiliza Camara,231,232,3246
            --**********************************
            if vtransacc = "0231" or vtransacc = "0232" or
               vtransacc = "3313" or vtransacc = "3314" or
               vtransacc = vtransacc_t1 then
        
                call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,
                                 vmoneda,vtransacc,vsector,vcancelad,
	                         vsuccta,wdescripcion)  
                  returning vcodret;
                if vtransacc = vtransacc_t1 then
                    call extrae_cont(pempresa,2,vmonto_tot,vsucopero,
                                     vproducto,vmoneda,vtransacc,vsector,
                                     vcancelad,vsuccta,wdescripcion) 
                      returning vcodret;
                end if
            end if
        END FOREACH

        insert into sc_contab
        select empresa,secuencia,sucursal,succta,ccmayor,ccsub,
               ccsubsub,ccssubsub,ccsssubsub,sector,auxiliar,
               tot_cargo,tot_abono,moneda,descripcion 
          from aux_contab;
  
        call auditor(pempresa) returning vcodret;

        if vcodret = "000" then
            call pasecont(pempresa,vfecha_hoy) returning vcodret;
            if vcodret = "000" then
                update sc_contproc
                set fecha = vfecha_hoy
                where empresa = pempresa and proceso = "pase";
            end if
        end if
        return vcodret;
    end
end procedure;