CREATE PROCEDURE "informix".sp_tramarecargatae( pNumCategoria CHAR (2), pNumConvenio CHAR (3), pFolioSucursal CHAR (16), pRef1 CHAR (40), pId_Sucursal CHAR (4), pFecha_Pago DATE, pNumTrama INTEGER, pTimeStamp CHAR (10), pIdTransaccion CHAR (9), pFirma CHAR (40))
RETURNING CHAR (5)   AS cCodRet, CHAR (163) AS cTrama;
   
   -- DeclaraciÃ³n de variables 
	DEFINE cCodRet 			CHAR (5);
	DEFINE cTrama			CHAR (163);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cTrans_MotorS	CHAR (5); -- Trans_MotorS
	DEFINE cNum_Sucursal 	CHAR (9);
	DEFINE cTipo_Operacion	CHAR (9);
	DEFINE cLlave			CHAR (4);
	DEFINE cNum_Clave		CHAR (2);
	DEFINE cNum_Seguridad	CHAR (1);
	DEFINE cNum_Version		CHAR (1);
	DEFINE cNum_Tienda		CHAR (9);
	DEFINE cClv_Area		CHAR (1);
	DEFINE cNum_Caja		CHAR (9);
	DEFINE cNum_Folio		CHAR (9);
	DEFINE cImporte		   	CHAR (9);
	DEFINE cNum_Cliente		CHAR (9);
	DEFINE cUser_Insert    	CHAR (8);
	DEFINE cNum_Telefono	CHAR (10);
	DEFINE cNum_Origen		CHAR (9);
	DEFINE cRefer2		    CHAR (40);
	DEFINE cTrans_Suc	   CHAR (4);
	DEFINE cTrans_Central  CHAR (5);
	DEFINE cTrans_Interact CHAR (5);
	
	LET cCodRet		= '00000';
	LET iSqlErr		= 0;
	LET cTrama		='';
	LET cTrans_MotorS	= '';
	LET cNum_Sucursal = RPAD(pId_Sucursal, 9, ' ');
	LET cTipo_Operacion = '';
	LET cLlave = '';
	LET cNum_Clave = '';
	LET cNum_Seguridad = '';
	LET cNum_Version = '';
	LET cNum_Tienda = RPAD(pId_Sucursal, 9, ' ');
	LET cClv_Area = '';
	LET cNum_Caja = '';
	LET cNum_Folio = pIdTransaccion;
	LET cNum_Cliente = '';
	LET cNum_Telefono = pRef1;
	LET cNum_Origen = '';
	LET cRefer2 = '';
	LET cTrans_Suc = '';
	LET cTrans_Central = '';
	LET cTrans_Interact = '';
	LET cImporte = '';
	LET cUser_Insert ='';
   
   BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cTrama, '');
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/EPG/sp_tramarecargatae.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
	
		IF NVL(pFecha_Pago, '') = '' OR NVL(pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL(pFolioSucursal, '') = '' OR NVL (pRef1, '') = '' OR NVL(pId_Sucursal, '') = '' OR NVL(pNumTrama, '') = '' OR NVL(pTimeStamp, '') = '' OR NVL(pIdTransaccion, '') = '' OR NVL(pFirma, '') = '' THEN
			LET cCodRet = '00002'; --DATOS VACIOS, ERROR.
			RETURN cCodRet, NVL(cTrama, '');
		END IF;
		
		--Obtenemos la codigo del interac requeridos  de bdisac:"informix".sac_intrfz_serv
		SELECT trans_interact, trans_servicio INTO  cTrans_Interact, cTrans_MotorS FROM   bdisac: "informix".sac_intrfz_serv WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND num_trama = pNumTrama;
			IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Interact= '' Or cTrans_MotorS= '' THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			END IF;
		
		--Obtenemos los parametros de la sac_param para la generacion de la trama
		SELECT TRIM(valor) INTO cTipo_Operacion FROM  bdisac:"informix".sac_param  where cod_param = 90;
			IF DBINFO("sqlca.sqlerrd2") = 0 Or cTipo_Operacion = ''THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			END IF;
		
		SELECT TRIM(valor) INTO cLlave FROM  bdisac:"informix".sac_param  where cod_param = 92;
			IF DBINFO("sqlca.sqlerrd2") = 0 Or cLlave= '' THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			END IF;
		
		--Verificamos y guardamos la clave de la compaÃ±ia telefonica en cNum_Clave
		SELECT referencia2, RPAD (REPLACE(REPLACE(REPLACE (importe_pago, '.', ''), ',', ''), '$', ''), 9, ' '), RPAD (usuario, 8, ' ')
		INTO   cRefer2, cImporte, cUser_Insert FROM   bdisac: "informix".sac_movimientos 
		WHERE  numcategoria = pNumCategoria  AND  numconvenio = pNumConvenio AND id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND  referencia1 = pRef1 AND fecha_pago=pFecha_Pago;	
			IF DBINFO("sqlca.sqlerrd2") = 0 Or cRefer2 = '' Or cImporte= '' THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			END IF;
		
		IF UPPER(cRefer2) = 'TELCEL' THEN
			SELECT TRIM(valor) INTO cNum_Clave FROM  bdisac:"informix".sac_param  where cod_param = 97;
		ELSE
			IF UPPER(cRefer2) = 'MOVISTAR' THEN
				SELECT TRIM(valor) INTO cNum_Clave FROM  bdisac:"informix".sac_param  where cod_param = 98;
			ELSE
				IF UPPER(cRefer2) = 'AT&T' THEN
					SELECT TRIM(valor) INTO cNum_Clave FROM  bdisac:"informix".sac_param  where cod_param = 99;
				ELSE 
					IF UPPER(cRefer2) = 'UNEFON' THEN
						SELECT TRIM(valor) INTO cNum_Clave FROM  bdisac:"informix".sac_param  where cod_param = 100;
					END IF;
				END IF;
			END IF;
		END IF;
		
		--Obtenemos parametros de bdisac: sac_param para la generaciÃ³n de la trama
		SELECT TRIM(valor) INTO cNum_Seguridad FROM  bdisac:"informix".sac_param  where cod_param = 102;
		SELECT TRIM(valor) INTO cNum_Version FROM  bdisac:"informix".sac_param  where cod_param = 103;
		SELECT TRIM(valor) INTO cClv_Area FROM  bdisac:"informix".sac_param  where cod_param = 104;
		SELECT TRIM(valor) INTO cNum_Caja FROM  bdisac:"informix".sac_param  where cod_param = 105;
		SELECT TRIM(valor) INTO cNum_Cliente FROM  bdisac:"informix".sac_param  where cod_param = 95;
		SELECT TRIM(valor) INTO cNum_Origen FROM  bdisac:"informix".sac_param  where cod_param = 96;

	
		--Agrupa los datos para la generacion de la trama
		LET cTrama = cTrans_MotorS||cNum_Sucursal||cTipo_Operacion||cLlave||pTimeStamp||RPAD(trim(pIdTransaccion), 9, ' ')||lower(pFirma)||cNum_Clave||cNum_Seguridad||cNum_Version||cNum_Tienda||cClv_Area||cNum_Caja||cNum_Folio||cImporte||cNum_Cliente||cUser_Insert||cNum_Telefono||cNum_Origen;
	
	SELECT trans_suc_efectivo, trans_cen_efectivo_cliente INTO cTrans_Suc, cTrans_Central FROM bdisac:"informix".sac_convenios WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio;
			IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Suc= '' Or  cTrans_Central=''THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			END IF;
	
	--Inserta la trama generada en la tabla sac_msw_solicitud de la bdisac
	INSERT INTO bdisac:"informix".sac_msw_solicitud(numcategoria, numconvenio, id_sucursal, trans_suc, trans_central, trans_interact, folio_suc, fecha_pago, num_trama, campo1, campo2, campo3, campo4, campo5, campo6 , campo7, campo8, campo9, campo10, campo11, campo12, campo13, campo14, campo15, campo16, campo17, campo18, campo19, campo20, campo21, campo22, campo23, campo24, campo25, campo26, campo27, campo28, campo29, campo30, campo31, campo32, campo33, campo34, campo35, campo36, campo37, campo38, campo39, campo40, user_insert, fecha_insert) VALUES (pNumCategoria, pNumConvenio, pId_Sucursal, cTrans_Suc, cTrans_Central, cTrans_Interact, pFolioSucursal, pFecha_Pago, pNumTrama, cTrans_MotorS, cNum_Sucursal, cTipo_Operacion, cLlave, pTimeStamp, RPAD(trim(pIdTransaccion), 9, ' '), lower(pFirma), cNum_Clave, cNum_Seguridad, cNum_Version, cNum_Tienda, cClv_Area, cNum_Caja, cNum_Folio, cImporte, cNum_Cliente, cUser_Insert, cNum_Telefono, cNum_Origen, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', cUser_Insert, current);
		
	  
	RETURN cCodRet, NVL(cTrama, '');

END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: SPL que recupera datos (Tiempo Aire) para generar la trama a enviar a Interact.',
'FOLIO: 1485 - ModificacionVtaTiempoAireDobleConsulta',
'FECHA : 21-05-2015',
'VERSION: 20150521.1435',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

create procedure "informix".sp_actualizasac_bts_payi(dFecha_hoy date)

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

     --set DEBUG FILE to "/informix/alex/sp_actualizasac_bts_payi.out";
	 --trace on;

     begin

        on exception set iSqlErr, iIsamErr, cInfoErr
            if iSqlErr <> 0 then
                let cCodRet = iSqlErr;
                rollback work;
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_payi");
                return cCodRet, cCodMsj;
            end if;
        end exception;
       
        --Verifico que el job se ejecute una sola vez en el dia
        select count(*) into iRegJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSPAYI' and fecha_proceso = today;

        if iRegJob = '0' then 
            --Se inserta un registro en la tabla sac_procesos_jobs
            insert into "informix".sac_procesos_jobs (proceso, fecha_proceso, status, user_insert, fecha_insert, 
                                                        numero_ejecuciones, nombre_sp, descripcion)
                      values ('MIG_REG_BTSPAYI', today, '0', 'informix', current, 1, 'sp_actualizasac_bts_payi', 'Migracion sac_bts_payi a historico');
        end if;              
                    
        --Se extrae el valur del campo status
        select status into cStatusJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSPAYI' and fecha_proceso = today;

        --Si el campo status contiene un valor '1' ya no se realiza el proceso porque ya fue ejecutado anteriormente
        --solo puede ejecutarce una vez al dia.
        if cStatusJob = '0' then
            --  Migración de registros de 'bdisac:sac_bts_payi' A 'bdisac:sac_bts_payi_old'
            --	Sólo se considera el último día (fecha_insert + 1) de la tabla sac_bts_payi_old'
            select max(fecha_insert) into vmax_fechaold
                from "informix".sac_bts_payi_old;

            let vfecharesp = vmax_fechaold + 1;
            let vfechacomp = dFecha_hoy - 90;  

            select count(*) into vcontregshist
                from "informix".sac_bts_payi
                where fecha_insert::date <= vfechacomp
                and fecha_insert::date >= vfecharesp;

            --	Insert de la tabla bdisac:sac_bts_payi a bdisac:sac_bts_payi_old
            insert into "informix".sac_bts_payi_old 
                    (txn_status, agent_trans_type_code, agent_cd, confirmation_nm, bank_ref_nm, region_sd, 
                     branch_sd, state_cd, country_cd, user_name, terminal, agent_dt, agent_tm, r_first_name, 
                     r_middle_name, r_last_name, r_mother_m_name, r_type_cd, r_issuer_cd, r_issuer_state_cd, 
                     r_issuer_country_cd, r_identif_type, r_identif_nm, r_expiration_dt, r_fecha_nac, r_nacionalidad, 
                     r_pais_nac, r_nom_calle, r_num_ext, r_num_int, r_depto, r_colonia, r_cp, r_mncpo_deleg, r_ciudad, 
                     r_estado, r_telefono, tipo_pago, sucursal, opcode, process_msg, error_param_full_name, trans_status_cd, 
                     trans_status_dt, process_dt, process_tm, user_insert, fecha_insert,numcte)

            select txn_status, agent_trans_type_code, agent_cd, confirmation_nm, bank_ref_nm, region_sd, 
                     branch_sd, state_cd, country_cd, user_name, terminal, agent_dt, agent_tm, r_first_name, 
                     r_middle_name, r_last_name, r_mother_m_name, r_type_cd, r_issuer_cd, r_issuer_state_cd, 
                     r_issuer_country_cd, r_identif_type, r_identif_nm, r_expiration_dt, r_fecha_nac, r_nacionalidad, 
                     r_pais_nac, r_nom_calle, r_num_ext, r_num_int, r_depto, r_colonia, r_cp, r_mncpo_deleg, r_ciudad, 
                     r_estado, r_telefono, tipo_pago, sucursal, opcode, process_msg, error_param_full_name, trans_status_cd, 
                     trans_status_dt, process_dt, process_tm, user_insert, fecha_insert,numcte

               from "informix".sac_bts_payi
                  where fecha_insert::date <= vfechacomp
                  and fecha_insert::date >= vfecharesp;


            select count(*) into vcontregsold
                from "informix".sac_bts_payi_old
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;
              

            if vcontregsold = vcontregshist then
                delete from "informix".sac_bts_payi 
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;

                -- Realizo un Upadate a la tabla sac_procesos_jobs en el campo status = 1 para que sólo se ejecute una sola vez el job
                update sac_procesos_jobs set status = '1' where proceso = 'MIG_REG_BTSPAYI' and fecha_proceso = today; 
                let cCodMsj = 'Proceso Exitoso';
                return cCodRet, cCodMsj;
            else
                let iSqlErr = 9999;
                let iIsamErr = 9999;
                let cInfoErr = 'No se insertaron todos los registros en la tabla bdisac:sac_bts_payi_old.';
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_payi");
            end if;         
        else
            let cCodMsj = 'Este proceso ya fue ejecutado';
            return cCodRet, cCodMsj;
        end if;    
        
    end;

end procedure;