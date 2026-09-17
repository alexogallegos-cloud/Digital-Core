create procedure "informix".sp_actualizasac_wu_search(dFecha_hoy date)

    RETURNING CHAR(5), char(40);  -- Código de retorno

    define cCodRet          char(5);
    define cCodMsj          char(40);
    define cInfoErr         char(100);
    define iSqlErr          integer;
    define iIsamErr         integer;
    define vfecharesp       date;
	define vfechacomp       date;
    define vmax_fechaold    date;
    define vmin_fechaact    date;
    define vcontregshist    integer;
    define vcontregsold     integer;
    define inumdias         integer;
    define cStatusJob       char(1);
    define iRegJob          char(1);


    let cCodRet          = '00000';
    let cCodMsj          = '';
    let cInfoErr         = '';
	let iSqlErr          = 0;
	let iIsamErr         = 0;
    let vfecharesp       = '';
    let vfechacomp       = '';
    let vmax_fechaold    = '';
    let vmin_fechaact    = '';
    let vcontregshist    = 0;
    let vcontregsold     = 0;
    let inumdias         = 0;    
    let cStatusJob       = '';
    let iRegJob          = '';

     --set DEBUG FILE to "/informix/alex/sp_actualizasac_wu_search.out";
	 --trace on;

     begin

        on exception set iSqlErr, iIsamErr, cInfoErr
            if iSqlErr <> 0 then
                let cCodRet = iSqlErr;
                rollback work;
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_wu_search");
                return cCodRet, cCodMsj;
            end if;
        end exception;
       
        --Verifico que el job se ejecute una sola vez en el dia
        select count(*) into iRegJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_WUSEARCH' and fecha_proceso = today;

        if iRegJob = '0' then 
            --Se inserta un registro en la tabla sac_procesos_jobs
            insert into "informix".sac_procesos_jobs (proceso, fecha_proceso, status, user_insert, fecha_insert, 
                                                        numero_ejecuciones, nombre_sp, descripcion)
                      values ('MIG_REG_WUSEARCH', today, '0', 'informix', current, 1, 'sp_actualizasac_wu_search', 'Migracion sac_wu_search a historico');
        end if;              
                    
        --Se extrae el valur del campo status
        select status into cStatusJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_WUSEARCH' and fecha_proceso = today;

        --Si el campo status contiene un valor '1' ya no se realiza el proceso porque ya fue ejecutado anteriormente
        --solo puede ejecutarce una vez al dia.
        if cStatusJob = '0' then
            --  Migración de registros de 'bdisac:sac_wu_search' A 'bdisac:sac_wu_search_old'
            --	Sólo se considera el último día (fecha_insert + 1) de la tabla sac_wu_search_old'
            select max(fecha_insert) into vmax_fechaold
                from "informix".sac_wu_search_old;

            let vfecharesp = vmax_fechaold + 1;
            let vfechacomp = dFecha_hoy - 90;  

            select count(*) into vcontregshist
                from "informix".sac_wu_search
                where fecha_insert::date <= vfechacomp
                and fecha_insert::date >= vfecharesp;

            --	Insert de la tabla bdisac:sac_wu_search a bdisac:sac_wu_search_old
            insert into "informix".sac_wu_search_old 
                    (txn_status, channel_type, channel_name, channel_version, foreign_rs_system_id_rq, 
                        foreign_rs_refnum_rq, foreign_rs_cntid_rq, mtcn, fecha_hora_rq, retcode, emisor_nametype,
                        emisor_nombre1, emisor_nombre2, emisor_appaterno, emisor_apmaterno, emisor_ciudad, emisor_edo,	
                        emisor_cod_pais, emisor_cod_moneda, emisor_cp, emisor_calle, emisor_telefono, benef_nametype,	
                        benef_nombre1, benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, 	
                        benef_cod_pais, benef_cod_moneda, benef_cp, benef_calle, benef_tel_part, benef_tel_celular,
                        monto_total_origen, monto_total_destino, monto_origen, monto_cargos, cd_origen_pago, tipo_cambio,
                        fecha_alta_remesa, hora_alta_remesa, money_transfer_key, estatus_remesa, new_mtcn, fusion_status,	
                        no_paginas, pagina_actual, num_coincidencias, foreign_rs_system_id_rp, foreign_rs_refnum_rp,
                        foreign_rs_cntid_rp, desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert)

            select txn_status, channel_type, channel_name, channel_version, foreign_rs_system_id_rq, 
                    foreign_rs_refnum_rq, foreign_rs_cntid_rq, mtcn, fecha_hora_rq, retcode, emisor_nametype,
                    emisor_nombre1, emisor_nombre2, emisor_appaterno, emisor_apmaterno, emisor_ciudad, emisor_edo,	
                    emisor_cod_pais, emisor_cod_moneda, emisor_cp, emisor_calle, emisor_telefono, benef_nametype,	
                    benef_nombre1, benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, 	
                    benef_cod_pais, benef_cod_moneda, benef_cp, benef_calle, benef_tel_part, benef_tel_celular,
                    monto_total_origen, monto_total_destino, monto_origen, monto_cargos, cd_origen_pago, tipo_cambio,
                    fecha_alta_remesa, hora_alta_remesa, money_transfer_key, estatus_remesa, new_mtcn, fusion_status,	
                    no_paginas, pagina_actual, num_coincidencias, foreign_rs_system_id_rp, foreign_rs_refnum_rp,
                    foreign_rs_cntid_rp, desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert

               from "informix".sac_wu_search
                  where fecha_insert::date <= vfechacomp
                  and fecha_insert::date >= vfecharesp;


            select count(*) into vcontregsold
                from "informix".sac_wu_search_old
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;
              

            if vcontregsold = vcontregshist then
                delete from "informix".sac_wu_search 
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;

                -- Realizo un Upadate a la tabla sac_procesos_jobs en el campo status = 1 para que sólo se ejecute una sola vez el job
                update sac_procesos_jobs set status = '1' where proceso = 'MIG_REG_WUSEARCH' and fecha_proceso = today; 
                let cCodMsj = 'Proceso Exitoso';
                return cCodRet, cCodMsj;
            else
                let iSqlErr = 9999;
                let iIsamErr = 9999;
                let cInfoErr = 'No se insertaron todos los registros en la tabla bdisac:sac_wu_search_old.';
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_wu_search");
            end if;         
        else
            let cCodMsj = 'Este proceso ya fue ejecutado';
            return cCodRet, cCodMsj;
        end if;    
        
    end;

end procedure;