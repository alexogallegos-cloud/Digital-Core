CREATE PROCEDURE "informix".sp_sacreportedetalletransaccionsucursal_soc (cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE, pEjecutivo CHAR(8))
-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(8) AS usuario,
CHAR(16) AS folio_suc,
CHAR(40) AS nomconvenio,
CHAR(20) AS referencia1,
CHAR(20) AS referencia2,
MONEY(16,2) AS importe_pago,
MONEY(16,2) AS importe_comision_convenio,
MONEY(16,2) AS iva_comision_convenio,
MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte,
CHAR(1) AS forma_pago,
CHAR(12) AS cuenta_cargo,
CHAR(40) AS region;


-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE cUsuario                 CHAR(8);
DEFINE cFolioSuc                CHAR(16);
DEFINE cNumcategoria            CHAR(2);
DEFINE cNumconvenio             CHAR(3);
DEFINE cNomconvenio             CHAR(40);
DEFINE cReferencia1             CHAR(20);
DEFINE cReferencia2             CHAR(20);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComisionConvenio    MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mIVAComisionCte         MONEY(16,2);
DEFINE mImportePago            MONEY(16,2);
DEFINE cFormaPago               CHAR(1);
DEFINE cCuentaCargo             CHAR(12);
DEFINE cRegion                  CHAR(40);

--SET DEBUG FILE TO "/home/informix/exi.out";
--TRACE ON;


--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cUsuario              = "";
LET cFolioSuc             = "";
LET cNumcategoria         = SUBSTRING(cConvenio FROM 1 FOR 2);
LET cNumconvenio          = SUBSTRING(cConvenio FROM 3 FOR 3);
LET cNomConvenio          = "";
LET cReferencia1          = "";
LET cReferencia2          = "";
LET mImportePago         = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte      = 0;
LET mIVAComisionCte      = 0;
LET cFormaPago            = "";
LET cCuentaCargo          = "";
LET cRegion               = "";

BEGIN

    ON EXCEPTION SET iSqlErr

        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
        END IF;

    END EXCEPTION;

    IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
        LET cCodRet = "00001";
        RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
    ELSE
        IF cConvenio = "00000" THEN   -- Todos los convenios y una sucursal
            INSERT INTO tmp_movs_soc
            SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
            b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre, pEjecutivo
            FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
            WHERE b.fecha_pago::DATE  >= dFechaIni
            AND b.fecha_pago::DATE  <= dFechaFin
            AND a.numcategoria = b.numcategoria
            AND a.numconvenio = b.numconvenio
            AND b.id_sucursal = cSucursal
            AND b.status_cancelado <> 'S'
            AND flag_confirmacion_central = 1
            AND flag_confirmacion_sucursal = 1
            AND c.sucursal = b.id_sucursal
            AND d.plaza = c.plaza
            AND e.regional = d.regional;
            
            --ORDER BY 3, 2 ASC
            /*FOREACH
                SELECT usuario, folio_suc, nomconvenio, referencia1, referencia2, importe_pago, importe_comision_convenio, iva_comision_convenio,
                    importe_comision_cte, iva_comision_cte, forma_pago, cuenta_cargo, nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:tmp_movs_soc ORDER BY folio_suc, nomconvenio

                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;*/
        ELSE   --Un convenio y una sucursal
            --FOREACH
                INSERT INTO tmp_movs_soc
                SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
                b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre, pEjecutivo
                FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
                WHERE b.fecha_pago::DATE >= dFechaIni
                AND b.fecha_pago::DATE  <= dFechaFin
                AND b.numcategoria = cNumcategoria
                AND b.numconvenio = cNumconvenio
                AND a.numcategoria = b.numcategoria
                AND a.numconvenio = b.numconvenio
                AND b.id_sucursal = cSucursal
                AND b.status_cancelado <> 'S'
                AND flag_confirmacion_central = 1
                AND flag_confirmacion_sucursal = 1
                AND c.sucursal = b.id_sucursal
                AND d.plaza = c.plaza
                AND e.regional = d.regional;
        END IF;
    END IF;
RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener la conciliacion por convenio y sucursales en un rango de fechas especificas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080906',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reportedetalletransucursalsac(pUsuario CHAR(8), pIdfuncion CHAR(10), pConvenio CHAR(5), pSucursal CHAR(4), pFechaIni DATE, 
pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codigoretorno, --Codigo de Retorno
	CHAR(8) AS usuario,
	CHAR(16) AS foliosuc,
	CHAR(40) AS nomconvenio,
	CHAR(20) AS referencia1,
	CHAR(20) AS referencia2,
	MONEY(16,2) AS importePago,
	MONEY(16,2) AS importeComisionConvenio,
	MONEY(16,2) AS ivaComisionConvenio,
	MONEY(16,2) AS importeComisionCte,
	MONEY(16,2) AS ivaComisionCte,
	CHAR(1) AS formaCago,
	CHAR(12) AS cuentaCargo,
	CHAR(40) AS region,
	CHAR(3) AS numconvenio,
	CHAR(2) AS numcategoria;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cUsuario CHAR(16);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cNomConvenio CHAR(40);
	DEFINE cReferencia1 CHAR(20);
	DEFINE cReferencia2 CHAR(20);
	DEFINE mImportePago MONEY(16,2);
	DEFINE mImporteComisionConvenio MONEY(16,2);
	DEFINE mIvaComisionConvenio MONEY(16,2);
	DEFINE mImporteComisionCte MONEY(16,2);
	DEFINE mIivaComisionCte MONEY(16,2);
	DEFINE cFormaCago CHAR(1);
	DEFINE cCuentaCargo CHAR(12);
	DEFINE cRegion CHAR(40);				
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNumCategoria CHAR(2);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cUsuario = '';
	LET cFolioSuc  = '';
	LET cNomConvenio  = '';
	LET cReferencia1  = '';
	LET cReferencia2  = '';
	LET mImportePago = 0;
	LET mImporteComisionConvenio = 0;
	LET mIvaComisionConvenio  = 0;
	LET mImporteComisionCte  = 0;
	LET mIivaComisionCte  = 0;
	LET cFormaCago = '';
	LET cCuentaCargo = '';
	LET cRegion = '';				
	LET iRegistros = 0;
	LET iNoRegs  = 0;
	LET iRecuperacion = 0;
	LET cNumConvenio = '';
	LET cNumCategoria = '';
			
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodret = iSqlErr;
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportedetalletransucursalsac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdfuncion = '' OR LENGTH(pConvenio) <> 5 OR LENGTH(pSucursal) <> 4 OR pFechaIni = '' OR pFechaFin = '' OR pRegistros = '' OR pRecuperacion = ''THEN
			LET cCodret = '00003';
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria;
		END IF;
		IF pRecuperacion < 0 THEN
			LET cCodret = '00098';
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria;
		END IF;


		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria;
		END IF;
		
		FOREACH 
			EXECUTE PROCEDURE bdisac:sp_sacreportedetalletransaccionsucursal(pConvenio, pSucursal, pFechaIni, pFechaFin) INTO
			cCodRetSp, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion
			IF cCodRetSp = '00000' THEN
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						SELECT numconvenio, numcategoria  INTO cNumConvenio, cNumCategoria FROM bdisac:sac_convenios WHERE nomconvenio = cNomConvenio;
						LET iRecuperacion = iRecuperacion + 1;							
					RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
						mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria
						WITH RESUME;
						LET iNoRegs = iNoRegs + 1;
					END IF;
				END IF;
					LET iRegistros = iRegistros + 1;
			ELSE
				LET cCodRet = cCodRetSp;
				RETURN cCodRet, '', '', '', '', '', 0, 0, 0, 0, 0, '', '', '', '', '';
			END IF;
		END FOREACH;
		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, '', '', '', '', '', 0, 0, 0, 0, 0, '', '', '', '', '';
		END IF;
		IF  iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', '', '', 0, 0, 0, 0, 0, '', '', '', '', '';
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR: Esparza Brenis Fernando Martin",
"FECHA:  12/12/2013 ",
"DESCRIPCION: SP para el detalle de las sucursales",
"DB: bdisac";

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