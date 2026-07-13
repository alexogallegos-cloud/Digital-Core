create procedure "informix".sp_actualizasac_bts_sdep(dFecha_hoy date)

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

     --set DEBUG FILE to "/informix/alex/sp_actualizasac_bts_sdep.out";
	 --trace on;

     begin

        on exception set iSqlErr, iIsamErr, cInfoErr
            if iSqlErr <> 0 then
                let cCodRet = iSqlErr;
                rollback work;
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_sdep");
                return cCodRet, cCodMsj;
            end if;
        end exception;
       
        --Verifico que el job se ejecute una sola vez en el dia
        select count(*) into iRegJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSSDEP' and fecha_proceso = today;

        if iRegJob = '0' then 
            --Se inserta un registro en la tabla sac_procesos_jobs
            insert into "informix".sac_procesos_jobs (proceso, fecha_proceso, status, user_insert, fecha_insert, 
                                                        numero_ejecuciones, nombre_sp, descripcion)
                      values ('MIG_REG_BTSSDEP', today, '0', 'informix', current, 1, 'sp_actualizasac_bts_sdep', 'Migracion sac_bts_sdep a historico');
        end if;              
                    
        --Se extrae el valur del campo status
        select status into cStatusJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSSDEP' and fecha_proceso = today;

        --Si el campo status contiene un valor '1' ya no se realiza el proceso porque ya fue ejecutado anteriormente
        --solo puede ejecutarce una vez al dia.
        if cStatusJob = '0' then
            --  Migración de registros de 'bdisac:sac_bts_sdep' A 'bdisac:sac_bts_sdep_old'
            --	Sólo se considera el último día (fecha_insert + 1) de la tabla sac_bts_sdep_old'
            select max(fecha_insert) into vmax_fechaold
                from "informix".sac_bts_sdep_old;

            let vfecharesp = vmax_fechaold + 1;
            let vfechacomp = dFecha_hoy - 90;  

            select count(*) into vcontregshist
                from "informix".sac_bts_sdep
                where fecha_insert::date <= vfechacomp
                and fecha_insert::date >= vfecharesp;

            --	Insert de la tabla bdisac:sac_bts_sdep a bdisac:sac_bts_sdep_old
            insert into "informix".sac_bts_sdep_old 
                    (cnxn_status, agent_trans_type_code, agent_cd, session_id, fecha_peticion, hora_peticion, 
					opcode, descr_mensaje, descr_completa_mensaje, fecha_proceso, hora_proceso, num_confirmacion, 
					id_movimiento, fecha_transaccion, hora_transaccion, cod_servicio, tipo_pago_servicio, 
					cod_pais_origen, cod_moneda_origen, cod_pais_destino, cod_moneda_destino, monto_origen, monto_destino, 
					tipo_cambio, cod_divisa, tp_cambio_divisa_org, monto_calc_divisa_org, cod_agente_org, tipo_pago, 
					tp_cta_remitente, cuenta_remitente, cod_banco_remitente, ref_num_remitente, tipo_cta_benef, cuenta_benef, 
					cod_agnt_benef, region_benef, sucursal_benef, nombre1_remitente, nombre2_remitente, ap_paterno_remitente, 
					ap_materno_remitente, dir_remitente, cd_remitente, cod_edo_remitente, cod_pais_remitente, cp_remitente, 
					tel_remitente, nombre1_benef, nombre2_benef, ap_paterno_benef, ap_materno_benef, tp_id_benef, num_id_benef, 
					nombre1_benef_alt, nombre2_benef_alt, ap_paterno_alt, ap_materno_alt, dir_benef, ciudad_benef, cod_edo_benef, 
					cod_pais_benef, cp_benef, tel_benef, cod_tp_id_rmtnte, cod_id_rmtnte, cod_edo_id_rmtnte, cod_pais_id_rmtnte, 
					num_id_rmtnte, fec_exp_id_rmtnte, estatus_sdep, intentos_envio, user_insert, fecha_insert)

            select cnxn_status, agent_trans_type_code, agent_cd, session_id, fecha_peticion, hora_peticion, 
					opcode, descr_mensaje, descr_completa_mensaje, fecha_proceso, hora_proceso, num_confirmacion, 
					id_movimiento, fecha_transaccion, hora_transaccion, cod_servicio, tipo_pago_servicio, 
					cod_pais_origen, cod_moneda_origen, cod_pais_destino, cod_moneda_destino, monto_origen, monto_destino, 
					tipo_cambio, cod_divisa, tp_cambio_divisa_org, monto_calc_divisa_org, cod_agente_org, tipo_pago, 
					tp_cta_remitente, cuenta_remitente, cod_banco_remitente, ref_num_remitente, tipo_cta_benef, cuenta_benef, 
					cod_agnt_benef, region_benef, sucursal_benef, nombre1_remitente, nombre2_remitente, ap_paterno_remitente, 
					ap_materno_remitente, dir_remitente, cd_remitente, cod_edo_remitente, cod_pais_remitente, cp_remitente, 
					tel_remitente, nombre1_benef, nombre2_benef, ap_paterno_benef, ap_materno_benef, tp_id_benef, num_id_benef, 
					nombre1_benef_alt, nombre2_benef_alt, ap_paterno_alt, ap_materno_alt, dir_benef, ciudad_benef, cod_edo_benef, 
					cod_pais_benef, cp_benef, tel_benef, cod_tp_id_rmtnte, cod_id_rmtnte, cod_edo_id_rmtnte, cod_pais_id_rmtnte, 
					num_id_rmtnte, fec_exp_id_rmtnte, estatus_sdep, intentos_envio, user_insert, fecha_insert

               from "informix".sac_bts_sdep
                  where fecha_insert::date <= vfechacomp
                  and fecha_insert::date >= vfecharesp;


            select count(*) into vcontregsold
                from "informix".sac_bts_sdep_old
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;
              

            if vcontregsold = vcontregshist then
                delete from "informix".sac_bts_sdep 
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;

                -- Realizo un Upadate a la tabla sac_procesos_jobs en el campo status = 1 para que sólo se ejecute una sola vez el job
                update sac_procesos_jobs set status = '1' where proceso = 'MIG_REG_BTSSDEP' and fecha_proceso = today; 
                let cCodMsj = 'Proceso Exitoso';
                return cCodRet, cCodMsj;
            else
                let iSqlErr = 9999;
                let iIsamErr = 9999;
                let cInfoErr = 'No se insertaron todos los registros en la tabla bdisac:sac_bts_sdep_old.';
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_sdep");
            end if;         
        else
            let cCodMsj = 'Este proceso ya fue ejecutado';
            return cCodRet, cCodMsj;
        end if;    
        
    end;

end procedure;