create procedure "informix".sp_actualizasac_bts_qryi(dFecha_hoy date)

    RETURNING CHAR(5), char(40);  -- CÃ³digo de retorno

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
	
	DEFINE cStmt 			CHAR (500);
	LET cStmt = '';

    let cCodRet          = '00000';
    let cCodMsj          = '';
    let cInfoErr         = '';
	let iSqlErr          = 0;
	let iIsamErr         = 0;
    let vfecharesp       = MDY('01','01','1900');
    let vfechacomp       = MDY('01','01','1900');
    let vmax_fechaold    = '';
    let vmin_fechaact    = '';
    let vcontregshist    = 0;
    let vcontregsold     = 0;
    let inumdias         = 0;    
    let cStatusJob       = '';
    let iRegJob          = '';
		
	 --420_MIGRACION_BTS_QRYI_PRO
     --set DEBUG FILE to "/RESPALDOSNEW/depuraremesas/sp_actualizasac_bts_qryi.out";
	 --trace on;

     begin

        on exception set iSqlErr, iIsamErr, cInfoErr
            if iSqlErr <> 0 then
                let cCodRet = iSqlErr;
                rollback work;
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_qryi");
                return cCodRet, cCodMsj;
            end if;
        end exception;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
       
        --Verifico que el job se ejecute una sola vez en el dia
        select count(*) into iRegJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSQRYI' and fecha_proceso = today;

		
        if iRegJob = '0' then 
            --Se inserta un registro en la tabla sac_procesos_jobs
            insert into "informix".sac_procesos_jobs (proceso, fecha_proceso, status, user_insert, fecha_insert, 
                                                        numero_ejecuciones, nombre_sp, descripcion)
                      values ('MIG_REG_BTSQRYI', today, '0', 'informix', current, 1, 'sp_actualizasac_bts_qryi', 'Migracion sac_bts_qryi a historico');
        end if;              
                    
        --Se extrae el valur del campo status
        select status into cStatusJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSQRYI' and fecha_proceso = today;

        --Si el campo status contiene un valor '1' ya no se realiza el proceso porque ya fue ejecutado anteriormente
        --solo puede ejecutarce una vez al dia.
        if cStatusJob = '0' then
            --  MigraciÃ³n de registros de 'bdisac:sac_bts_qryi' A 'bdisac:sac_bts_qryi_old'
            --	SÃ³lo se considera el Ãºltimo dÃ­a (fecha_insert + 1) de la tabla sac_bts_qryi_old'
            select max(fecha_insert) into vmax_fechaold
                from "informix".sac_bts_qryi_old;

            let vfecharesp = vmax_fechaold + 1;
            let vfechacomp = dFecha_hoy - 90;  

            select count(*) into vcontregshist
                from "informix".sac_bts_qryi
                where fecha_insert::date <= vfechacomp
                and fecha_insert::date >= vfecharesp;
				
				drop table if exists temp988_sac_bts_remesas;
				
				select *
                from "informix".sac_bts_qryi
                where fecha_insert::date <= vfechacomp
                and fecha_insert::date >= vfecharesp
				INTO temp988_sac_bts_remesas;

/*
            --	Insert de la tabla bdisac:sac_bts_qryi a bdisac:sac_bts_qryi_old
            insert into "informix".sac_bts_qryi_old 
                    (txn_status, agent_trans_type_code, agent_cd, confirmation_nm, region_sd, branch_sd, state_cd, 
                    country_cd, user_name, terminal, agent_dt, agent_tm, opcode, process_msg, error_param_full_name, 
                    trans_status_cd, trans_status_dt, process_dt, process_tm, service_cd, payment_type_cd, orig_country_cd, 
                    orig_currency_cd, dest_country_cd, dest_currency_cd, origin_am, destination_am, exch_rate_fx, s_agent_cd, 
                    s_payment_type_cd, s_account_type_cd, s_account_nm, s_bank_cd, s_bank_ref_nm, r_account_type_cd, r_account_nm, 
                    r_agent_cd, r_agent_region_sd, r_agent_branch_sd, s_first_name, s_middle_name, s_last_name, s_mother_m_name, 
                    s_address, s_city, s_state_cd, s_country_cd, s_zip_code, s_phone, r_first_name, r_middle_name, r_last_name, 
                    r_mother_m_name, r_identif_type_cd, r_identif_nm, f_first_name, f_middle_name, f_last_name, f_mother_m_name, 
                    r_address, r_city, r_state_cd, r_country_cd, r_zip_code, r_phone, r_type_cd, r_issuer_cd, r_issuer_state_cd, 
                    r_issuer_country_cd, ri_identif_nm, r_expiration_dt, s_type_cd, s_issuer_cd, s_issuer_state_cd, s_issuer_country_cd, 
                    s_identif_nm, s_expiration_dt, user_insert, fecha_insert)

            select txn_status, agent_trans_type_code, agent_cd, confirmation_nm, region_sd, branch_sd, state_cd, 
                    country_cd, user_name, terminal, agent_dt, agent_tm, opcode, process_msg, error_param_full_name, 
                    trans_status_cd, trans_status_dt, process_dt, process_tm, service_cd, payment_type_cd, orig_country_cd, 
                    orig_currency_cd, dest_country_cd, dest_currency_cd, origin_am, destination_am, exch_rate_fx, s_agent_cd, 
                    s_payment_type_cd, s_account_type_cd, s_account_nm, s_bank_cd, s_bank_ref_nm, r_account_type_cd, r_account_nm, 
                    r_agent_cd, r_agent_region_sd, r_agent_branch_sd, s_first_name, s_middle_name, s_last_name, s_mother_m_name, 
                    s_address, s_city, s_state_cd, s_country_cd, s_zip_code, s_phone, r_first_name, r_middle_name, r_last_name, 
                    r_mother_m_name, r_identif_type_cd, r_identif_nm, f_first_name, f_middle_name, f_last_name, f_mother_m_name, 
                    r_address, r_city, r_state_cd, r_country_cd, r_zip_code, r_phone, r_type_cd, r_issuer_cd, r_issuer_state_cd, 
                    r_issuer_country_cd, ri_identif_nm, r_expiration_dt, s_type_cd, s_issuer_cd, s_issuer_state_cd, s_issuer_country_cd, 
                    s_identif_nm, s_expiration_dt, user_insert, fecha_insert
               from "informix".sac_bts_qryi
                  where fecha_insert::date <= vfechacomp
                  and fecha_insert::date >= vfecharesp;
*/
				
				LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_bts_qryi.unl select * from temp988_sac_bts_remesas;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
				SYSTEM cStmt;
				LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
				SYSTEM cStmt;
				
				
				drop table if exists temp988_sac_bts_remesas;
				LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
				SYSTEM cStmt;
				
				LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_bts_qryi.unl INSERT INTO sac_bts_qryi_old;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
				SYSTEM cStmt;
				LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
				SYSTEM cStmt;
				
				LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
				SYSTEM cStmt;
				
				
				LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_bts_qryi.unl';
				SYSTEM cStmt;
				
            select count(*) into vcontregsold
                from "informix".sac_bts_qryi_old
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;
              

            if vcontregsold = vcontregshist then
			
                delete from "informix".sac_bts_qryi 
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;
					
                -- Realizo un Upadate a la tabla sac_procesos_jobs en el campo status = 1 para que sÃ³lo se ejecute una sola vez el job
                update sac_procesos_jobs set status = '1' where proceso = 'MIG_REG_BTSQRYI' and fecha_proceso = today; 
                let cCodMsj = 'Proceso Exitoso';
                return cCodRet, cCodMsj;
            else
                let iSqlErr = 9999;
                let iIsamErr = 9999;
                let cInfoErr = 'No se insertaron todos los registros en la tabla bdisac:sac_bts_qryi_old.';
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_qryi");
            end if;         
        else
            let cCodMsj = 'Este proceso ya fue ejecutado';
            return cCodRet, cCodMsj;
        end if;    
        
    end;

end procedure;