CREATE PROCEDURE "informix".sac_bts_movspaso (vempresa char (3))

RETURNING CHAR (5), CHAR (100), CHAR (1), CHAR (1), CHAR (1), CHAR (1), CHAR (1), INTEGER, INTEGER, INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  Proceso de movimientos histórico a tablas _paso para Conciliación Remesas BTS.
-- AUTOR : FRG
-- FECHA : 21/Ene/2014
-- BD: BDISAC
-- SISTEMA : BTS
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE ccodret 				CHAR (5);
DEFINE itot_movssac 		INTEGER;
DEFINE itot_movschqs 		INTEGER;
DEFINE itot_movsbts 		INTEGER;
DEFINE isqlerr      		INTEGER;
DEFINE iisamerr     		INTEGER;
DEFINE cinfoerr     		CHAR (100);
DEFINE cstatussac			CHAR (1);
DEFINE cstatmvhst			CHAR (1);
DEFINE ccuenta_bts			CHAR (20);
DEFINE ctrns_ctrl_efecte	CHAR (4);
DEFINE ctrns_ctrl_crgocte 	CHAR (4);
DEFINE imovsbts_payi		INTEGER;
DEFINE imovsbts_payc		INTEGER;
DEFINE cflg_sac				CHAR (1);
DEFINE cflg_chqs			CHAR (1);
DEFINE cflg_btscj			CHAR (1);
DEFINE cflg_btsab			CHAR (1);
DEFINE cflg_btsrev			CHAR (1);
DEFINE cproceso				CHAR (8);
DEFINE dfechamovs			DATE;
DEFINE iprocsac				INTEGER;
DEFINE cdiamovs				CHAR (2);
DEFINE cmesmovs				CHAR (2);
DEFINE cstmovsbts			CHAR (1);
-- 2014.02.11 FRG-i
DEFINE caniomovs			CHAR (4);
DEFINE cbts_dt				CHAR (8);
-- 2014.02.11 FRG-f

--2014.05.06 EPG
DEFINE cReferencia1         CHAR(20);	
DEFINE iFlagCen             INTEGER;
DEFINE iFlagSuc             INTEGER;
DEFINE cFolio               CHAR(16);
DEFINE dFecha_Pago           DATE;
DEFINE iCuantos             INTEGER;
DEFINE cDescripcionSPJ	 	CHAR(100);
	
	--SET DEBUG FILE TO  '/informix/adrian/sac_bts_movspaso.out';
	--TRACE ON;

/* INICIALIZACION DE VARIABLES */
LET ccodret 				= '00000';
LET itot_movssac 			= 0;
LET itot_movschqs 			= 0;
LET itot_movsbts  			= 0;
LET isqlerr  				= 0;
LET iisamerr  				= 0;
LET cinfoerr 				= "";
LET cstatussac				= "";
LET cstatmvhst				= "";
LET ccuenta_bts				= "";
LET ctrns_ctrl_efecte		= "";
LET ctrns_ctrl_crgocte 		= "";
LET imovsbts_payi			= 0;
LET imovsbts_payc			= 0;
LET cflg_sac				= "0";
LET cflg_chqs				= "0";
LET cflg_btscj				= "0";
LET cflg_btsab				= "0";
LET cflg_btsrev				= "0";
LET cproceso				= "MOVS_BTS";
LET dfechamovs				= CURRENT;
LET iprocsac				= 0;
LET cdiamovs				= "";
LET cmesmovs				= "";
LET cstmovsbts				= "";
-- 2014.02.11 FRG-i
LET caniomovs				= "";
LET cbts_dt			    	= "";
-- 2014.02.11 FRG-i

--2014.05.06 EPG
LET cReferencia1  		    = '';
LET iFlagCen      		    = 0;                 
LET iFlagSuc      		    = 0; 
LET cFolio        		    = ''; 
LET dFecha_Pago             = DATE(1);	
LET	iCuantos      		    = 0;
LET cDescripcionSPJ	 		= 'Inserta movimientos historicos (T-1) BTS a tablas de paso';

	BEGIN
    ON EXCEPTION SET isqlerr, iisamerr, cinfoerr
        IF isqlerr <> 0 THEN
            LET ccodret = isqlerr;
            EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
            RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
        END IF;
    END EXCEPTION;

/*
	Obtención fecha-SAC:
*/
	set isolation to dirty read;
	select {+INDEX(bdisac:sac_fechas 105_11)}
	fecha_hoy 
	into dfechamovs
	from bdisac:sac_fechas
	where empresa = vempresa;
	
	LET dfechamovs = dfechamovs-1;
	
	let cdiamovs = SUBSTR (dfechamovs, 4, 2);
	let cmesmovs = SUBSTR (dfechamovs, 1, 2);
	let caniomovs = SUBSTR (dfechamovs, 7, 4);
	let cbts_dt = caniomovs||cmesmovs||cdiamovs;	
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_BTS_MP', dfechamovs, '0', 'informix', 'sac_bts_movspaso', cDescripcionSPJ);

	if	cmesmovs = '01' AND cdiamovs = '01'
		then
			LET dfechamovs = dfechamovs-1;
		else
			if	cmesmovs = '12' AND cdiamovs = '25'
				then
					LET dfechamovs = dfechamovs-1;
			end if;
	end if;

/*
	Validación término exitoso en proceso de pase movimientos SAC al histórico:
*/
	set isolation to dirty read;
	select count (*) into iprocsac
	from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
	if iprocsac > 0
		then
			select status into cstatussac
			from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
			if cstatussac <> "1"
				then
					update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';					
				else
			end if;
		else
			INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			values (cproceso, dfechamovs, '0', 'informix', current);
	end if;
/*
	Obtención valores parametrizados de transacciones BTS:
*/
	set isolation to dirty read;
	select {+INDEX(bdisac:sac_convenios 103_4)}
	cuenta_prestadora, trans_cen_efectivo_cliente, trans_cen_cargo_cliente
	into ccuenta_bts, ctrns_ctrl_efecte, ctrns_ctrl_crgocte
	from bdisac:sac_convenios
	where numcategoria = '07' and numconvenio = '004';

/*
	Validación termino exitoso en proceso de pase movimientos Cheques al histórico:
*/
	set isolation to dirty read;
	select {+INDEX(bdinteg:sx_contproc 255_612)}
	status_proc into cstatmvhst
	from bdinteg:sx_contproc where fecha = dfechamovs and proceso = 'PasaMovsHist' and sistema = '01';
	
	select status into cstatussac
		from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
	if	cstatussac <> "1" or cstatussac is null
		then
			LET ccodret = "00001";
			LET isqlerr = 0;
			LET iisamerr = 0;
			LET cinfoerr = "Pase de Movimientos Servicios del día a Histórico no ha concluido.";
            EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
            RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
		else
		if	cstatmvhst <> "F" or cstatmvhst is null
			then
				set isolation to dirty read;
				select count (*) into iprocsac
				from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
				if iprocsac > 0
					then
						select status into cstatussac
						from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
						if cstatussac <> "1" or cstatussac is null
							then
								update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';								
							else
								INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
								values (cproceso, dfechamovs, '0', 'informix', current);
						end if;
					else
						INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
						values (cproceso, dfechamovs, '0', 'informix', current);
				end if;
			LET ccodret = "00002";
			LET isqlerr = 0;
			LET iisamerr = 0;
			LET cinfoerr = "Pase de Movimientos Dia a Histórico no ha concluido.";
			EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
			RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
			else
			
			select status into cstmovsbts
			from bdisac:sac_Procesos where proceso = cproceso and fecha_proceso = dfechamovs;
			if cstmovsbts = '1'
				then
					LET ccodret = "00003";
					LET isqlerr = 0;
					LET iisamerr = 0;
					LET cinfoerr = "Pase de Movimientos a tablas _paso ya ha sido ejecutado exitosamente el dia de hoy.";
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
				else
					if cstmovsbts = '0'
						then
							update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = cproceso;							
						else
							INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
							values (cproceso, dfechamovs, '0', 'informix', current);
					end if;
			end if;
			
/*
	se confirma flag_confirmacion_sucursal='1' si la remesa esta en cheques y servicios
*/
    FOREACH
        SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1,flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
			INTO  cReferencia1, iFlagCen, iFlagSuc, cFolio, dFecha_Pago
        FROM bdisac:sac_movimientoshistorial
        WHERE numcategoria = '07'
            AND numconvenio = '004'
            AND fecha_pago = dfechamovs
            AND status_cancelado <> 'S'
            AND flag_confirmacion_sucursal = 0

        IF iFlagCen = 0 or iFlagSuc =0 THEN
            SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
            IF iCuantos = 0 THEN
                SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago;   
                IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                END IF;
            END IF;
            IF iCuantos > 0 THEN            
                UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                WHERE numcategoria = '07'
                    AND numconvenio = '004'
                    AND fecha_pago = dFecha_Pago
                    AND folio_suc = cFolio
                    AND referencia1 = cReferencia1
                    AND status_cancelado <> 'S'
                    AND flag_confirmacion_sucursal = 0;             
            END IF;
        END IF;
	END FOREACH;			
			
/*
	Conteo de registros BTS-SAC del día T-1:
*/
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
			count (*) into itot_movssac		
			from bdisac:sac_movimientoshistorial 
			where 
			numcategoria = '07' and numconvenio = '004'
			and fecha_pago = dfechamovs;

/*
	Conteo de registros BTS-Cheques del día T-1:
*/		
			set isolation to dirty read;
			select {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
			count (*) into itot_movschqs
			from bdicheq:sc_movhis
			where 
			empresa = vempresa and 
			fech_alt = dfechamovs
			and cuenta = ccuenta_bts
			and transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte);

/*
	Conteo de registros BTS-Payi del día T-1:
*/			
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_bts_payi idx_sac_bts_payi3)}
			count (*) into imovsbts_payi
			from "informix".sac_bts_payi
			where 
-- 2014.02.11 FRG-i
			--	fecha_insert::DATE = dfechamovs
			agent_dt = cbts_dt
-- 2014.02.11 FRG-f
			and opcode = '1100';

/*
	Conteo de registros BTS-Payc del día T-1:
*/			
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_bts_payc idx_sac_bts_payc)}
			count (*) into imovsbts_payc
			from "informix".sac_bts_payc
			where 
-- 2014.02.11 FRG-i
			--fecha_insert::DATE = dfechamovs
			agent_dt = cbts_dt
-- 2014.02.11 FRG-f
			and opcode = '1100';
			
			LET itot_movsbts = imovsbts_payi + imovsbts_payc;
			
/*
	Proceso de Inserción de registros del día T-1 en tablas _paso:
*/
			set isolation to dirty read;
			INSERT INTO bdisac:"informix".sac_cheques_paso
				SELECT {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
				folio_suc, fech_alt
				FROM bdicheq:"informix".sc_movhis
				WHERE cuenta = ccuenta_bts
				AND fech_alt = dfechamovs 
				AND transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte)
				and cancelad <> 'S';
				
			set isolation to dirty read;
			INSERT INTO bdisac:"informix".sac_chequesrev_paso
				SELECT {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
				folio_suc, fech_alt
				FROM bdicheq:"informix".sc_movhis
				WHERE cuenta = ccuenta_bts
				AND fech_alt = dfechamovs 
				AND transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte)
				and cancelad = 'S'
				and referencia = 'REV';
			
			LET cflg_chqs = "1";
			
			INSERT INTO bdisac:"informix".sac_servicios_paso
				SELECT {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
				folio_suc, referencia1, status_cancelado, flag_confirmacion_sucursal, fecha_pago, fecha_insert
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria= '07'  
				AND numconvenio='004'
				AND fecha_pago= dfechamovs;
				
			INSERT INTO bdisac:"informix".sac_serviciosrev_paso
				SELECT {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
				folio_suc, referencia1, status_cancelado, fecha_pago
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria= '07'  
				AND numconvenio='004'
				AND fecha_pago= dfechamovs
				AND status_cancelado = 'S';
			
			LET cflg_sac = "1";
			
			INSERT INTO bdisac:"informix".sac_abono_paso
				SELECT {+INDEX(bdisac:sac_bts_payc idx_sac_bts_payc)}
				confirmation_nm, bank_ref_nm, 
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_payc
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1100'
				and process_type_code = 'PAYC';
			
			LET cflg_btsab = "1";
			
			INSERT INTO bdisac:"informix".sac_btscaja_paso
-- 2014.02.11 FRG-i
				--	SELECT confirmation_nm, bank_ref_nm, fecha_insert
				SELECT confirmation_nm, bank_ref_nm, --agent_dt::date
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_payi
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1100';
			
			LET cflg_btscj = "1";
			
			INSERT INTO bdisac:"informix".sac_btsrevi_paso
				SELECT confirmation_nm, bank_ref_nm, --fecha_insert
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_revi
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1200';
			
			LET cflg_btsrev = "1";
			
			if	cflg_chqs = "1" and cflg_sac = "1" and cflg_btsab = "1" and cflg_btscj = "1" and cflg_btsrev = "1"
				then
					LET cinfoerr = 'Inserción en tablas _paso exitoso.';
					update bdisac:sac_procesos set status = '1' where proceso = cproceso and fecha_proceso::date = dfechamovs;
					--ACTUALIZA STATUS EN BITACORA
					EXECUTE PROCEDURE "informix".sp_bitacoraspj (1, 'IND_BTS_MP', dfechamovs, '1', 'informix', 'sac_bts_movspaso', cDescripcionSPJ);
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
				else
					LET ccodret = "00002";
					LET cinfoerr = 'Error en proceso inserción en tablas _paso. Validar Tabla sac_MensajeError.';
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
			end if;
		end if;
	end if;
	END;	
END PROCEDURE;