create procedure "informix".gen_protsdo( pempresa       char(3),
                                         psucursal      char(4),
                                         pusuario       char(8),
                                         ptransacc      char(4),
                                         ptransacc_suc  char(4),
                                         pfolio_suc     char(16),
                                         pcuenta        char(20),
                                         pmonto         money(14,2),
                                         pdocto         integer,
                                         pdivisa        char(2),
                                         pnip           char(4),
                                         preferval      char(40),
                                         ptiporef	    char(1),  --- 0 No valida titularidad
                                                                  --- 1 Valida cta_cheques vs cuenta eje
                                                                  --- 2 Valida Titular
                                                                  --- 3 Valida Cotitular
                                                                  --- 4 No valida titularidad ni tipo persona y nip
                                         pnum_tarjeta   char(16),
                                         pusuautoriza   char(8) )
returning char(5), char(8), money(14,2);

    define cod_ret          char(5);
    define vfecha           date;
    define vfechacalendario date;
    define v_valdoc         char(1);
    define v_tipo_tran      char(2);
    define v_moneda         char(2);
    define v_tpcheque       char(2);
    define v_long_cta       char(2);
    define vcuenta          char(20);
    define v_plaza          char(3);
    define v_succta         char(4);
    define v_producto       char(4);
    define v_numreg         smallint;
    define v_dias           smallint;
    define longitud         smallint;
    define v_mesdia         char(4);
    define v_tranret        char(4);
    define v_cal_int_chq    char(1);
    define v_clave          char(8);
    define v_cvepro         char(8);
    define v_fisica         char(1);
    define v_tipper         char(1);
    define sql_err          integer;
    define v_monto_val_nip  money(16,2);
    define v_disponible     money(16,2);
    define v_nip            char(4);
    define v_numcte         char(20);
    define v_cotit          char(20);
    define v_cteexo         char(20);
    define v_band           char(1);
    define v_tasapl         char(8);
    define v_valortasa      money(14,2);
    define v_comision       money(14,2);
    define vstatus_cta      char(1);
    
    let cod_ret    = "000";
    let v_clave    = "    ";
    let v_comision = 0;
    
    begin
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_clave, v_comision;
        end if;
    end exception;
    
    -- Extrae la fecha del sistema de cheques
    select {+INDEX(sc_fechas idx_fechas1)} fecha_hoy 
      into vfechacalendario 
      from sc_fechas 
     where empresa = pempresa;

    select fecha_proceso, status_cta  
      into vfecha, vstatus_cta
      from sc_maechq
     where empresa = pempresa
       and cuenta = pcuenta;

    if ( vfecha is null or vstatus_cta = '4' or vstatus_cta = '5' ) then
        let vfecha = vfechacalendario;
    end if

    if ( vfecha < vfechacalendario ) then
        let cod_ret = "549";
        return  cod_ret, v_clave, v_comision;
    end if
    
    if ( vstatus_cta in('2','6','7','8') ) then
        let cod_ret = "200";
        return  cod_ret, v_clave, v_comision;
    end if
    
    -- Extrae la informacion de la Cuenta de Cheques
    select cuenta, num_cte, producto, plaza
      into vcuenta, v_numcte, v_producto, v_plaza
      from sc_maechq
     where empresa = pempresa 
       and cuenta = pcuenta;
       
    if vcuenta is null then
        let cod_ret = "100";
        return cod_ret, v_clave, v_comision;
    end if
    
    -- Valida el nip de acuerdo al monto por tipo de cliente
    if ptiporef <> "4" then
        select monto_val_nip 
          into v_monto_val_nip
          from bdinteg:si_cliente clie, 
               bdinteg:si_tipocte tpoclie
         where clie.tipo_cliente = tpoclie.tipo_cliente 
           and numcte = v_numcte;

        if pmonto >= v_monto_val_nip then
            select nip 
              into v_nip 
              from bdinteg:si_servcte
             where numcte = v_numcte;
            
            if v_nip is null then
                let v_nip = " ";
            end if;

            if v_nip <> pnip then
                let cod_ret = "614";
                return cod_ret, v_clave, v_comision;
            end if
        end if

        --- Valida personalidad del cliente
        select {+INDEX(bdinteg:si_tipper ix193_1)} es_fisica 
          into v_fisica
          from bdinteg:si_cliente clie, 
               bdinteg:si_tipper tpe
         where clie.numcte = v_numcte 
           and clie.tpo_persona = tpe.tpo_persona;

        if v_fisica <> "S" or v_fisica is null then
            let cod_ret = "122";
            return cod_ret, v_clave, v_comision;
        end if
    end if

    if ptiporef = "2" then
        --- Valida Titular
        if v_numcte <> preferval then
            let cod_ret = "211";
            return cod_ret, v_clave, v_comision;
        end if
    end if

    if ptiporef = "3" then
        --- Valida Titular y Cotitular
        let v_band = "0";
        
        if v_numcte <> preferval then
            foreach
                select {+INDEX(sc_cotitular idx_cotit2)} nombre 
                  into v_cotit 
                  from sc_cotitular
                 where empresa = pempresa 
                   and cuenta = pcuenta

                if v_cotit <> preferval then
                    continue foreach;
                else
                    let v_band = "1";
                    exit foreach;
                end if
            end foreach
            
            if v_band = "0" then
                let cod_ret="211";
                return cod_ret, v_clave, v_comision;
            end if
        end if
    end if

    select tipo_tran, dias_ret, tasa_aplicada, valida_docto
      into v_tipo_tran,v_dias, v_tasapl, v_valdoc
      from bdinteg:si_transacc
     where empresa = pempresa 
       and numero = ptransacc;

    if v_tipo_tran is null then
        let v_tipo_tran = 0;
    end if;

    if v_tipo_tran < "20" and v_tipo_tran > "29" then
        let cod_ret = "615";
        return cod_ret, v_clave, v_comision;
    end if

    if v_dias is null then
        let v_dias = 0;
    end if
    
    let v_producto = v_producto;

    select divisa 
      into v_moneda
      from sc_producto
     where empresa = pempresa 
       and producto=v_producto;
       
    if v_moneda is null then
        let cod_ret = "110";
        return cod_ret, v_clave, v_comision;
    end if;
    
    if v_valdoc = "S" then
        --- Valida que el Cheque no haya sido protegido previamente
        select count(*) 
          into v_numreg 
          from sc_docret
         where empresa = pempresa 
           and cuenta = pcuenta
           and num_chq = pdocto
           and cancelado = "P"
           and folio_suc = pfolio_suc;
        
        if v_numreg is null then
            let v_numreg = 0;
        end if
        
        if v_numreg > 0 then
            let cod_ret = "616";
            return cod_ret, v_clave, v_comision;
        end if
    end if

    call cargon_ref(pempresa,psucursal, pusuario, ptransacc, ptransacc_suc, pfolio_suc, pcuenta, pdocto, pmonto, v_moneda, preferval, pnum_tarjeta,pusuautoriza)
    returning cod_ret, v_tranret;

    --- let cod_ret = "100"; -- Esto regresaba originalmente el procedimiento cargon_ref, se cambio para que regresara "000

    if cod_ret = "000" then
        if v_valdoc = "S" and pdocto <> 0 then
            delete {+INDEX(sc_histch idx_histch1)} 
              from sc_histch
             where empresa = pempresa 
               and cuenta = pcuenta 
               and numero = pdocto;
               
            insert into sc_histch 
            values(pempresa,pcuenta,pdocto,"R",vfecha,pmonto);
            
            delete {+INDEX(sc_contch idx_contch2)} 
              from sc_contch
             where empresa = pempresa 
               and cuenta = pcuenta 
               and numero = pdocto;
        end if
        
        insert into sc_docret values
        ( pempresa, "SC", pcuenta, v_dias, pmonto, pfolio_suc, pusuario, vfecha, current hour to fraction, "P", preferval, psucursal, pdocto, v_dias, ptransacc, pmonto, '', '' );
        
        update sc_maechq
           set (sdo_actual, sdo_retenido, fec_ult_mov) =
               (sdo_actual + pmonto,sdo_retenido + pmonto, vfecha)
         where empresa = pempresa 
           and cuenta = pcuenta;
           
        if vstatus_cta = '5' then
            update sc_maechq
               set status_cta = '1',
                   fecha_proceso = vfechacalendario
             where empresa = pempresa 
               and cuenta = pcuenta;
        end if
    end if
    
    return cod_ret, v_clave, v_comision;
    
    end
    
end procedure;