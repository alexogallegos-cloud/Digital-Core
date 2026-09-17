create procedure "informix".sp_actualizasac_bts_payc(dFecha_hoy date)

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

     --set DEBUG FILE to "/informix/alex/sp_actualizasac_bts_payc.out";
	 --trace on;

     begin

        on exception set iSqlErr, iIsamErr, cInfoErr
            if iSqlErr <> 0 then
                let cCodRet = iSqlErr;
                rollback work;
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_payc");
                return cCodRet, cCodMsj;
            end if;
        end exception;
       
        --Verifico que el job se ejecute una sola vez en el dia
        select count(*) into iRegJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSPAYC' and fecha_proceso = today;

        if iRegJob = '0' then 
            --Se inserta un registro en la tabla sac_procesos_jobs
            insert into "informix".sac_procesos_jobs (proceso, fecha_proceso, status, user_insert, fecha_insert, 
                                                        numero_ejecuciones, nombre_sp, descripcion)
                      values ('MIG_REG_BTSPAYC', today, '0', 'informix', current, 1, 'sp_actualizasac_bts_payc', 'Migracion sac_bts_payc a historico');
        end if;              
                    
        --Se extrae el valur del campo status
        select status into cStatusJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSPAYC' and fecha_proceso = today;

        --Si el campo status contiene un valor '1' ya no se realiza el proceso porque ya fue ejecutado anteriormente
        --solo puede ejecutarce una vez al dia.
        if cStatusJob = '0' then
            --  Migración de registros de 'bdisac:sac_bts_payc' A 'bdisac:sac_bts_payc_old'
            --	Sólo se considera el último día (fecha_insert + 1) de la tabla sac_bts_payc_old'
            select max(fecha_insert) into vmax_fechaold
                from "informix".sac_bts_payc_old;

            let vfecharesp = vmax_fechaold + 1;
            let vfechacomp = dFecha_hoy - 90;  

            select count(*) into vcontregshist
                from "informix".sac_bts_payc
                where fecha_insert::date <= vfechacomp
                and fecha_insert::date >= vfecharesp;

            --	Insert de la tabla bdisac:sac_bts_payc a bdisac:sac_bts_payc_old
            insert into "informix".sac_bts_payc_old 
                    (cnxn_status, agent_trans_type_code, agent_cd, confirmation_nm, process_type_code, 
					bank_ref_nm, bank_concept1, agnt_region_sd, agnt_branch_sd, agnt_state_cd, agnt_country_cd, 
					agnt_user_name, agnt_terminal, agent_dt, agent_tm, type_cd, issuer_cd, issuer_state_cd, 
					issuer_country_cd, identif_nm, expiration_dt, benef_dob_dt, dir_remitente, cd_remitente, 
					rem_state_cd, rem_country_cd, rem_zip_code, rem_phone, opcode, process_msg, err_param_full_name, 
					trans_status_cd, trans_status_dt, process_dt, process_tm, bank_ref_num, promotion_cd, user_insert, fecha_insert)

            select cnxn_status, agent_trans_type_code, agent_cd, confirmation_nm, process_type_code, 
					bank_ref_nm, bank_concept1, agnt_region_sd, agnt_branch_sd, agnt_state_cd, agnt_country_cd, 
					agnt_user_name, agnt_terminal, agent_dt, agent_tm, type_cd, issuer_cd, issuer_state_cd, 
					issuer_country_cd, identif_nm, expiration_dt, benef_dob_dt, dir_remitente, cd_remitente, 
					rem_state_cd, rem_country_cd, rem_zip_code, rem_phone, opcode, process_msg, err_param_full_name, 
					trans_status_cd, trans_status_dt, process_dt, process_tm, bank_ref_num, promotion_cd, user_insert, fecha_insert

               from "informix".sac_bts_payc
                  where fecha_insert::date <= vfechacomp
                  and fecha_insert::date >= vfecharesp;


            select count(*) into vcontregsold
                from "informix".sac_bts_payc_old
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;
              

            if vcontregsold = vcontregshist then
                delete from "informix".sac_bts_payc 
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;

                -- Realizo un Upadate a la tabla sac_procesos_jobs en el campo status = 1 para que sólo se ejecute una sola vez el job
                update sac_procesos_jobs set status = '1' where proceso = 'MIG_REG_BTSPAYC' and fecha_proceso = today; 
                let cCodMsj = 'Proceso Exitoso';
                return cCodRet, cCodMsj;
            else
                let iSqlErr = 9999;
                let iIsamErr = 9999;
                let cInfoErr = 'No se insertaron todos los registros en la tabla bdisac:sac_bts_payc_old.';
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_payc");
            end if;         
        else
            let cCodMsj = 'Este proceso ya fue ejecutado';
            return cCodRet, cCodMsj;
        end if;    
        
    end;

end procedure;