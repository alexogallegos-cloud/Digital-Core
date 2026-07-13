create procedure "informix".sp_ctes_sincol_catzonas_debito()
returning char(20);

    ---V1 20100210 Crear SP
    define cod_ret char(20);
    define sql_err integer;
    define v_numcte char(9);
    define v_numerociudad smallint;
    define v_numerocolonia integer;
    define v_msj char(50);
    define v_count integer;

    --SET DEBUG FILE TO "/ids10_uc9/sp_ctes_sincol_catzonas_debito.out";
    --TRACE ON;
    
    let cod_ret = "000";
    let v_numcte = "";
    let v_numerociudad = 0;
    let v_numerocolonia = 0;
    let v_msj = '';
    let v_count = 0;
    
    BEGIN

    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            SYSTEM 'echo ---- Error :  --------> ' || cod_ret || '>> ' || 'sp_ctes_sincol_catzonas_debito.log';
            let v_msj = 'Error: ' || cod_ret;
            insert into bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
            values('ctes_sincol_catzonas_debito.sql',cod_ret,  v_msj, 0, '92920268',today,(SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
            return cod_ret;
        end if
    end exception;

    SYSTEM 'echo ---- Inicia proceso --------- ' || '> ' || 'sp_ctes_sincol_catzonas_debito.log';

    foreach
        SELECT numerociudad, numerocolonia 
          INTO v_numerociudad, v_numerocolonia
          FROM bdinteg:si_catzonas_ctesin

        foreach  
            SELECT {+ INDEX (bdinteg:si_direcciones idx_numcolonia)} d.numcte 
              into v_numcte
              FROM bdinteg:si_direcciones d, bdicheq:sc_maechq b 
             WHERE b.empresa = '001' 
               AND b.status_cta in ('1','3','4','5')
               AND b.producto in ('1100','1200','1300','1400','1500','1600','1700','1800','2000','9900','9901')
               AND b.num_cte = d.numcte
               AND d.tipo_dir = '1'
               AND d.secuencia = (SELECT MAX(e.secuencia)
                                    FROM bdinteg:si_direcciones e
                                   WHERE e.numcte = d.numcte
                                     AND e.tipo_dir = '1')
               AND d.numerociudad = v_numerociudad
               AND d.numerocolonia = v_numerocolonia
            
            if v_numcte is null then
                SYSTEM 'echo Cliente no encontrado en si_direcciones ' || '>> ' || 'sp_ctes_sincol_catzonas_debito.log';
                CONTINUE FOREACH;
            end if
            
            let v_count = v_count + 1;
            
            INSERT INTO bdinteg:si_por_asignar (numcte,estado) VALUES (v_count, v_numcte);
        end foreach;
    end foreach;

    end
    
    let cod_ret = "Termina proceso";
    
    insert into bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
    values('obtener_cte_sincol_catzonas.sql','00000',  cod_ret, 0, '92920268',today,(SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

    SYSTEM 'echo ----Termina el proceso-----' || '>> ' || 'obtener_cte_sincolonia_catzonas.log';
    
    return cod_ret;
    
end procedure;