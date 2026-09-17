CREATE PROCEDURE "informix".sp_depura_actualiza_triad_salida(pTipoProceso CHAR(1))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;          

-- pTipoProceso = '1' depura tabla
-- pTipoProceso = '2' actualiza tabla
		  
---DECLARACIONES          
DEFINE cEmpresa			CHAR(03);
DEFINE cNumCte			CHAR(20);
DEFINE cNum_cred		CHAR(20);
DEFINE cCodRet			CHAR(06); 
DEFINE cCodRet2			CHAR(06); 
DEFINE cMensajeRet		CHAR(80);
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE dFechaHoy		DATE;
DEFINE cSQL				CHAR(1000);
DEFINE dFechaInsert		DATE;
DEFINE sDiaCorte		SMALLINT;
DEFINE iTotalCuentasProcesadas		INTEGER;
DEFINE iTotalCuentasDepuradas		INTEGER;
DEFINE iTotalCuentasActualizadas	INTEGER;
DEFINE iTotalCuentasInsertadas		INTEGER;
DEFINE cMensaje			CHAR(80);
DEFINE sExiste			SMALLINT;
DEFINE cCodRetBitacora	CHAR(06);
DEFINE cReinicio		CHAR(01);

DEFINE	cOutSpid				CHAR(03);
DEFINE	cOutCuCat				CHAR(02);
DEFINE	cOutRvCat				CHAR(02);
DEFINE	cOutLnCat				CHAR(02);
DEFINE	cOutCollScenId			CHAR(04);
DEFINE	cOutCollStgyId			CHAR(03);
DEFINE	cOutCollActionCtr		CHAR(01);
DEFINE	cOutCollNextCallDays	INTEGER;
DEFINE	cOutCollDateBillEqv		CHAR(08);
DEFINE	cOutDateFirstCollsDa	CHAR(08);
DEFINE	cOutCollBalanceInitial	CHAR(10);
DEFINE	cOutCollOooType			CHAR(01);
DEFINE	cOutCollDelq			CHAR(02);
DEFINE	cOutCollAmtArrears		CHAR(10);
DEFINE	cOutCollAmtExcessOvlm	CHAR(10);
DEFINE	cOutCollBalance			CHAR(10);
DEFINE	cOutCollBalanceActual	CHAR(10);
DEFINE	cOutCollLimit			CHAR(10);
DEFINE	cOutCollPtp				CHAR(01);
DEFINE	cOutCollTelephoneInd	CHAR(01);
DEFINE	cOutCollAddressInd		CHAR(01);
DEFINE	cOutCollBlockCode		CHAR(04);
DEFINE	cOutCollWorstCycDelq	CHAR(02);
DEFINE	cOutCollTotalOooAmt		CHAR(10);
DEFINE	cOutScrdId				CHAR(05);
DEFINE	cOutRawScore			CHAR(08);
DEFINE	cOutAlignedScore		CHAR(08);
DEFINE	cOutBarFactor			CHAR(09);
DEFINE	cOutRecoveryFactor		CHAR(09);
DEFINE	cOutScrdId2				CHAR(05);
DEFINE	cOutRawScore2			CHAR(08);
DEFINE	cOutAlignedScore2		CHAR(08);
DEFINE	cOutBarFactor2			CHAR(09);
DEFINE	cOutCuCustomerId		CHAR(20);
DEFINE	cOutRvAccountId			CHAR(20);
DEFINE	cOutLnAccountId			CHAR(20);
DEFINE	cOutCoAccountId			CHAR(20);
DEFINE	cProceso				CHAR(04);
DEFINE  iExisteTabla    INTEGER;
DEFINE  iExisteIndice   INTEGER;
DEFINE vnom_arch        char(30);
DEFINE vnom_arch_fin    char(30);
DEFINE vRutaArch        char(30);		
DEFINE v_num_credito    char(20);

---INICIALIZACIONES
LET cEmpresa	= '001';
LET cNumCte		= '';
LET cNum_cred	= '';
LET cProceso	= '0002';
LET iSqlErr		= 0;
LET iIsamErr	= 0;
LET cErrorInfo	= '';
LET cCodRet		= '000000';
LET cMensajeRet	= 'Depuracion EXITOSA.';
LET dFechaHoy	= DATE(1);
LET cSQL		= '';
LET dFechaInsert	= DATE(1);
LET sDiaCorte	= 0;
LET iTotalCuentasProcesadas	= 0;
LET iTotalCuentasDepuradas	= 0;
LET iTotalCuentasActualizadas	= 0;
LET iTotalCuentasInsertadas		= 0;
LET cMensaje	= '';
LET sExiste		= 0;
LET cCodRetBitacora	= '000000';
LET cReinicio	= '';

LET	cOutSpid				= '';
LET	cOutCuCat				= '';
LET	cOutRvCat				= '';
LET	cOutLnCat				= '';
LET	cOutCollScenId			= '';
LET	cOutCollStgyId			= '';
LET	cOutCollActionCtr		= '';
LET	cOutCollNextCallDays	= 0;
LET	cOutCollDateBillEqv		= '';
LET	cOutDateFirstCollsDa	= '';
LET	cOutCollBalanceInitial	= '';
LET	cOutCollOooType			= '';
LET	cOutCollDelq			= '';
LET	cOutCollAmtArrears		= '';
LET	cOutCollAmtExcessOvlm	= '';
LET	cOutCollBalance			= '';
LET	cOutCollBalanceActual	= '';
LET	cOutCollLimit			= '';
LET	cOutCollPtp				= '';
LET	cOutCollTelephoneInd	= '';
LET	cOutCollAddressInd		= '';
LET	cOutCollBlockCode		= '';
LET	cOutCollWorstCycDelq	= '';
LET	cOutCollTotalOooAmt		= '';
LET	cOutScrdId				= '';
LET cOutRawScore			= '';
LET	cOutAlignedScore		= '';
LET	cOutBarFactor			= '';
LET	cOutRecoveryFactor		= '';
LET	cOutScrdId2				= '';
LET	cOutRawScore2			= '';
LET	cOutAlignedScore2		= '';
LET	cOutBarFactor2			= '';
LET	cOutCuCustomerId		= '';
LET	cOutRvAccountId			= '';
LET	cOutLnAccountId			= '';
LET	cOutCoAccountId			= '';
LET iExisteIndice       = 0; 
LET iExisteTabla        = 0;
LET vnom_arch           = '';
LET vnom_arch_fin       = '';
LET vRutaArch           = '';
LET v_num_credito       = '';

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr--, cErrorInfo
        LET cCodRet = iSqlErr;
--        LET cMensajeRet = cErrorInfo;
		LET cMensajeRet = 'ERROR al ejecutar el proceso.';
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCodRetBitacora;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO '/respaldos/htm/sp_depura_actualiza_triad_salida.out';
-- TRACE ON;


    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensajeRet, '01') Returning cCodRetBitacora;
--- SET DEBUG FILE TO '/respaldos/htm/sp_depura_actualiza_triad_salidaacall.out';
--- TRACE ON;
    SELECT fecha_hoy INTO dFechaHoy
    FROM bdicred:sd_fechas
    WHERE empresa = cEmpresa;

--rss temporal para pruebas
--    let p_PriDiaMes = mdy('04','01','2018');
--rss temporal para pruebas
----Obtencion de parametros

IF pTipoProceso = '1' THEN	-- Depura tabla1
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', 'INICIO depuracion de tabla por ser dia de corte', '02') Returning cCodRetBitacora;

	LET sDiaCorte = DAY(dFechaHoy);

	FOREACH WITH HOLD
		SELECT fecha_insert, out_co_account_id
		  INTO dFechaInsert, cOutCoAccountId
--		SELECT fecha_insert, out_cu_customer_id, out_rv_account_id, out_ln_account_id, out_co_account_id
--		  INTO dFechaInsert, cOutCuCustomerId,   cOutRvAccountId,   cOutLnAccountId,   cOutCoAccountId
		  FROM bdicobranza:cb_triad_salida
		 WHERE DAY(fecha_insert) = sDiaCorte 

		LET iTotalCuentasProcesadas = iTotalCuentasProcesadas + 1;
		
		BEGIN WORK;
		DELETE bdicobranza:cb_triad_salida WHERE out_co_account_id = cOutCoAccountId;
--solo para pruebas		DELETE bdicobranza:cb_triad_salida WHERE fecha_insert = dFechaInsert AND out_co_account_id = cOutCoAccountId;

		LET iTotalCuentasDepuradas = iTotalCuentasDepuradas + 1;
		COMMIT WORK;
	END FOREACH;

	LET cMensaje = 'TOTAL cuentas procesadas : '||iTotalCuentasProcesadas;
    LET cMensaje = trim(cMensaje) ||'    Total cuentas depuradas : ' || iTotalCuentasDepuradas;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', trim(cMensaje), '02') Returning cCodRetBitacora;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', 'FIN depuracion de tabla', '02') Returning cCodRetBitacora;
	LET cMensajeRet = trim(cMensajeRet) || ' ' || iTotalCuentasDepuradas || ' Cuentas eliminadas. ';
ELIF pTipoProceso = '2' THEN	-- Actualiza tabla
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', 'INICIO carga de tabla cb_triad_salida', '02') Returning cCodRetBitacora;

	SELECT valor INTO cReinicio FROM bdicobranza:cb_param WHERE empresa = cEmpresa AND cod_param = 3;

	IF NVL(cReinicio,"") = "" THEN
		LET cCodRet     = "000019";
		LET cMensajeRet = "Error al obtener el parametro de reinicio";
		RETURN cCodRet, cMensajeRet;
	END IF;


  IF cReinicio = '0' THEN
        LET vnom_arch           = 'PP20OUT-0001.dat';
        LET vnom_arch_fin       = 'carga_final.txt';
        --LET vRutaArch           = '/descarga_info/macf/'; 
		LET vRutaArch           = '/triad/salida/'; 
		LET cSQL = '';

 	    let cSQL = ' awk ' || '''{print substr($0,269,3)"|"substr($0,274,2)"|"substr($0,308,2)"|"substr($0,356,2)"|"substr($0,9387,4)"|"substr($0,9397,3)"|"substr($0,9414,1)"|"substr($0,9451,2)"|"substr($0,9455,8)"|"substr($0,9463,8)"|"substr($0,9471,10)"|"substr($0,9481,1)"|"substr($0,9482,2)"|"substr($0,9484,10)"|"substr($0,9494,10)"|"substr($0,9504,10)"|"substr($0,9514,10)"|"substr($0,9524,10)"|"substr($0,9534,1)"|"substr($0,9535,1)"|"substr($0,9536,1)"|"substr($0,9537,4)"|"substr($0,9541,2)"|"substr($0,9543,10)"|"substr($0,9560,5)"|"substr($0,9565,8)"|"substr($0,9573,8)"|"substr($0,9591,9)"|"substr($0,9591,9)"|"substr($0,10094,5)"|"substr($0,10099,8)"|"substr($0,10107,8)"|"substr($0,10125,9)"|"substr($0,28739,20)"|"substr($0,28759,20)"|"substr($0,28779,20)"|"substr($0,28799,20)}''' || ' ' ||trim(vRutaArch) || trim(vnom_arch) || ">" ||  trim(vRutaArch) || trim(vnom_arch_fin);
		SYSTEM cSQL;


		UPDATE bdicobranza:cb_param SET valor = '1'	WHERE empresa = cEmpresa AND cod_param = 3;
	END IF;
	
	
  UPDATE bdicobranza:cb_param SET valor = '1'	WHERE empresa = cEmpresa AND cod_param = 3;
	
  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', 'Valida la existencia de la tabla cb_triad_salida_temp y la crea', '02') Returning cCodRetBitacora;

	SELECT valor INTO cReinicio FROM bdicobranza:cb_param WHERE empresa = cEmpresa AND cod_param = 3;

	IF NVL(cReinicio,"") = "" THEN
		LET cCodRet     = "000019";
		LET cMensajeRet = "Error al obtener el parametro de reinicio";
		RETURN cCodRet, cMensajeRet;
	END IF;

	IF cReinicio = '1' THEN
		SELECT count(*) into iExisteTabla
		  FROM systables 
      WHERE tabname= 'cb_triad_salida_temp';
    
    IF iExisteTabla > 0 THEN
       DROP TABLE "informix".cb_triad_salida_temp;
    END IF;
      
		SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_cuenta_tmp';
     
     IF iExisteIndice > 0 THEN
        DROP INDEX "informix".idx_cuenta_tmp;
     END IF; 

		CREATE TABLE "informix".cb_triad_salida_temp ( 
			out_spid                	CHAR(03),
			out_cu_cat              	CHAR(02),
			out_rv_cat              	CHAR(02),
			out_ln_cat              	CHAR(02),
			out_coll_scen_id        	CHAR(04),
			out_coll_stgy_id        	CHAR(03),
			out_coll_action_ctr     	CHAR(01),
			out_coll_next_call_days 	INTEGER,
			out_coll_date_bill_eqv  	CHAR(08),
			out_date_first_colls_da 	CHAR(08),
			out_coll_balance_initial	CHAR(10),
			out_coll_ooo_type       	CHAR(01),
			out_coll_delq           	CHAR(02),
			out_coll_amt_arrears    	CHAR(10),
			out_coll_amt_excess_ovlm	CHAR(10),
			out_coll_balance        	CHAR(10),
			out_coll_balance_actual 	CHAR(10),
			out_coll_limit          	CHAR(10),
			out_coll_ptp            	CHAR(01),
			out_coll_telephone_ind  	CHAR(01),
			out_coll_address_ind    	CHAR(01),
			out_coll_block_code     	CHAR(04),
			out_coll_worst_cyc_delq 	CHAR(02),
			out_coll_total_ooo_amt  	CHAR(10),
			out_scrd_id             	CHAR(05),
			out_raw_score				CHAR(08),
			out_aligned_score       	CHAR(08),
			out_bar_factor          	CHAR(09),
			out_recovery_factor     	CHAR(09),
			out_scrd_id2            	CHAR(05),
			out_raw_score2          	CHAR(08),
			out_aligned_score2      	CHAR(08),
			out_bar_factor2         	CHAR(09),
			out_cu_customer_id      	CHAR(20),
			out_rv_account_id       	CHAR(20),
			out_ln_account_id       	CHAR(20),
			out_co_account_id       	CHAR(20)
			) in datos03 extent size 523438 next size 52343 lock mode row;   
			

		CREATE INDEX "informix".idx_cuenta_tmp ON "informix".cb_triad_salida_temp(out_co_account_id) in dbs_cfd_05;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_triad_salida_temp;
		
		UPDATE bdicobranza:cb_param SET valor = '2'	WHERE empresa = cEmpresa AND cod_param = 3;
	END IF;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', 'Carga archivo a la tabla cb_triad_salida_temp', '02') Returning cCodRetBitacora;

	SELECT valor INTO cReinicio FROM bdicobranza:cb_param WHERE empresa = cEmpresa AND cod_param = 3;

	IF NVL(cReinicio,"") = "" THEN
		LET cCodRet     = "000019";
		LET cMensajeRet = "Error al obtener el parametro de reinicio";
		RETURN cCodRet, cMensajeRet;
	END IF;

	IF cReinicio = '2' THEN
		LET cSQL = '';
	    --LET cSQL = 'echo "FILE /RESPALDOS/carga_final.txt DELIMITER '''||'|'||''' 37; INSERT INTO "informix".cb_triad_salida_temp; " > /RESPALDOS/carga_cb_triad_salida_temp.sql';
		LET cSQL = 'echo "FILE '|| trim(vRutaArch) || trim(vnom_arch_fin) || ' DELIMITER '''||'|'||''' 37; INSERT INTO "informix".cb_triad_salida_temp; " > ' || trim(vRutaArch) || 'carga_cb_triad_salida_temp.sql';
		SYSTEM cSQL;
		
		
		LET cSQL = '';
		--LET cSQL = 'dbload -d bdicobranza -c /descarga_info/macf/carga_cb_triad_salida_temp.sql -l /descarga_info/macf/carga_cb_triad_salida_temp.log -n 1000 -k';
		LET cSQL = 'dbload -d bdicobranza -c ' || trim(vRutaArch) || 'carga_cb_triad_salida_temp.sql -l ' || trim(vRutaArch) || 'carga_cb_triad_salida_temp.log -n 1000 -k';
		--LET cSQL = 'dbload -d bdicobranza -c /triad/salida/carga_cb_triad_salida_temp.sql -l /triad/salida/carga_cb_triad_salida_temp.log -n 1000 -k';

		SYSTEM cSQL;

		UPDATE bdicobranza:cb_param SET valor = '3'	WHERE empresa = cEmpresa AND cod_param = 3;
		
	END IF;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', 'Actualiza tabla cb_triad_salida', '02') Returning cCodRetBitacora;

	SELECT valor INTO cReinicio FROM bdicobranza:cb_param WHERE empresa = cEmpresa AND cod_param = 3;

	IF NVL(cReinicio,"") = "" THEN
		LET cCodRet     = "000019";
		LET cMensajeRet = "Error al obtener el parametro de reinicio";
		RETURN cCodRet, cMensajeRet;
	END IF;
	
	IF cReinicio = '3' THEN
		FOREACH WITH HOLD
			SELECT	out_spid, out_cu_cat, out_rv_cat, out_ln_cat, out_coll_scen_id, out_coll_stgy_id, out_coll_action_ctr, out_coll_next_call_days, out_coll_date_bill_eqv, 
					out_date_first_colls_da, out_coll_balance_initial, out_coll_ooo_type, out_coll_delq, out_coll_amt_arrears, out_coll_amt_excess_ovlm, out_coll_balance, 
					out_coll_balance_actual, out_coll_limit, out_coll_ptp, out_coll_telephone_ind, out_coll_address_ind, out_coll_block_code, out_coll_worst_cyc_delq, 
					out_coll_total_ooo_amt, out_scrd_id, out_raw_score, out_aligned_score, out_bar_factor, out_recovery_factor, out_scrd_id2, out_raw_score2, out_aligned_score2, out_bar_factor2, 
					out_cu_customer_id, out_rv_account_id, out_ln_account_id, out_co_account_id
			  INTO  cOutSpid, cOutCuCat, cOutRvCat, cOutLnCat, cOutCollScenId, cOutCollStgyId, cOutCollActionCtr, cOutCollNextCallDays, cOutCollDateBillEqv, 
					cOutDateFirstCollsDa, cOutCollBalanceInitial, cOutCollOooType, cOutCollDelq, cOutCollAmtArrears, cOutCollAmtExcessOvlm, cOutCollBalance, 
					cOutCollBalanceActual, cOutCollLimit, cOutCollPtp, cOutCollTelephoneInd, cOutCollAddressInd, cOutCollBlockCode, cOutCollWorstCycDelq, 
					cOutCollTotalOooAmt, cOutScrdId, cOutRawScore, cOutAlignedScore, cOutBarFactor, cOutRecoveryFactor, cOutScrdId2, cOutRawScore2, cOutAlignedScore2, cOutBarFactor2, 
					cOutCuCustomerId, cOutRvAccountId, cOutLnAccountId, cOutCoAccountId
			FROM bdicobranza:cb_triad_salida_temp

			LET iTotalCuentasProcesadas = iTotalCuentasProcesadas + 1;
			
			if nvl(cOutCoAccountId,'') <> '' then 
			   let v_num_credito = substr(cOutCoAccountId,9,12);
			else
			   let v_num_credito = ''; 
			end if;   
			
			BEGIN WORK;
			SELECT COUNT(*) INTO sExiste
			FROM bdicobranza:cb_triad_salida 
			WHERE out_co_account_id = cOutCoAccountId;

			IF sExiste > 0 THEN
				UPDATE bdicobranza:cb_triad_salida 
				   SET	out_spid = cOutSpid, out_cu_cat = cOutCuCat, out_rv_cat = cOutRvCat, out_ln_cat = cOutLnCat, out_coll_scen_id = cOutCollScenId, out_coll_stgy_id = cOutCollStgyId, out_coll_action_ctr = cOutCollActionCtr, out_coll_next_call_days = cOutCollNextCallDays, out_coll_date_bill_eqv = cOutCollDateBillEqv, 
						out_date_first_colls_da = cOutDateFirstCollsDa, out_coll_balance_initial = cOutCollBalanceInitial, out_coll_ooo_type = cOutCollOooType, out_coll_delq = cOutCollDelq, out_coll_amt_arrears = cOutCollAmtArrears, out_coll_amt_excess_ovlm = cOutCollAmtExcessOvlm, out_coll_balance = cOutCollBalance, 
						out_coll_balance_actual = cOutCollBalanceActual, out_coll_limit = cOutCollLimit, out_coll_ptp = cOutCollPtp, out_coll_telephone_ind = cOutCollTelephoneInd, out_coll_address_ind = cOutCollAddressInd, out_coll_block_code = cOutCollBlockCode, out_coll_worst_cyc_delq = cOutCollWorstCycDelq, 
						out_coll_total_ooo_amt = cOutCollTotalOooAmt, out_scrd_id = cOutScrdId, out_raw_score = cOutRawScore, out_aligned_score = cOutAlignedScore, out_bar_factor = cOutBarFactor, out_recovery_factor = cOutRecoveryFactor, out_scrd_id2 = cOutScrdId2, out_raw_score2 = cOutRawScore2, out_aligned_score2 = cOutAlignedScore2, out_bar_factor2 = cOutBarFactor2
				WHERE out_co_account_id = cOutCoAccountId;

				LET iTotalCuentasActualizadas = iTotalCuentasActualizadas + 1;
			ELSE
				INSERT INTO informix.cb_triad_salida(fecha_insert, out_spid, out_cu_cat, out_rv_cat, out_ln_cat, out_coll_scen_id, out_coll_stgy_id, out_coll_action_ctr, out_coll_next_call_days, out_coll_date_bill_eqv, 
					out_date_first_colls_da, out_coll_balance_initial, out_coll_ooo_type, out_coll_delq, out_coll_amt_arrears, out_coll_amt_excess_ovlm, out_coll_balance, 
					out_coll_balance_actual, out_coll_limit, out_coll_ptp, out_coll_telephone_ind, out_coll_address_ind, out_coll_block_code, out_coll_worst_cyc_delq, 
					out_coll_total_ooo_amt, out_scrd_id, out_raw_score, out_aligned_score, out_bar_factor, out_recovery_factor, out_scrd_id2, 
					out_raw_score2, out_aligned_score2, out_bar_factor2, out_cu_customer_id, out_rv_account_id, out_ln_account_id, out_co_account_id, num_credito) 
					VALUES(dFechaHoy, cOutSpid, cOutCuCat, cOutRvCat, cOutLnCat, cOutCollScenId, cOutCollStgyId, cOutCollActionCtr, cOutCollNextCallDays, cOutCollDateBillEqv, 
					cOutDateFirstCollsDa, cOutCollBalanceInitial, cOutCollOooType, cOutCollDelq, cOutCollAmtArrears, cOutCollAmtExcessOvlm, cOutCollBalance, 
					cOutCollBalanceActual, cOutCollLimit, cOutCollPtp, cOutCollTelephoneInd, cOutCollAddressInd, cOutCollBlockCode, cOutCollWorstCycDelq, 
					cOutCollTotalOooAmt, cOutScrdId, cOutRawScore, cOutAlignedScore, cOutBarFactor, cOutRecoveryFactor, cOutScrdId2, 
					cOutRawScore2, cOutAlignedScore2, cOutBarFactor2, cOutCuCustomerId, cOutRvAccountId, cOutLnAccountId, cOutCoAccountId, v_num_credito);

					LET iTotalCuentasInsertadas = iTotalCuentasInsertadas + 1;
			END IF;
			COMMIT WORK;
		END FOREACH;

		DROP TABLE "informix".cb_triad_salida_temp;

		UPDATE bdicobranza:cb_param SET valor = '4'	WHERE empresa = cEmpresa AND cod_param = 3;
		
		LET cMensaje = 'TOTAL cuentas procesadas : '||iTotalCuentasProcesadas;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', trim(cMensaje), '02') Returning cCodRetBitacora;
		LET cMensaje = 'TOTAL cuentas actualizadas : '||iTotalCuentasActualizadas;
		LET cMensaje = trim(cMensaje) ||'    Total cuentas insertadas : ' || iTotalCuentasInsertadas;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', trim(cMensaje), '02') Returning cCodRetBitacora;
	END IF;
--SET DEBUG FILE TO 'sp_depura_actualiza_triad_salida.out';
--TRACE ON;
	
	SELECT valor INTO cReinicio FROM bdicobranza:cb_param WHERE empresa = cEmpresa AND cod_param = 3;

	IF NVL(cReinicio,"") = "" THEN
		LET cCodRet     = "000019";
		LET cMensajeRet = "Error al obtener el parametro de reinicio";
		RETURN cCodRet, cMensajeRet;
	END IF;

	IF cReinicio = '4' THEN
		LET cSQL = '';
		LET cSQL = 'rm ' || trim(vRutaArch) || 'carga_final.txt ' || trim(vRutaArch) || 'carga_cb_triad_salida_temp.sql ' || trim(vRutaArch) || 'carga_cb_triad_salida_temp.log';
		--LET cSQL = 'rm /RESPALDOS/carga_final.txt /RESPALDOS/carga_cb_triad_salida_temp.sql /RESPALDOS/carga_cb_triad_salida_temp.log';
		SYSTEM cSQL;									     
	END IF;
		
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, '000000', 'FIN carga de tabla cb_triad_salida', '02') Returning cCodRetBitacora;
		
	UPDATE bdicobranza:cb_param SET valor = '0'	WHERE empresa = cEmpresa AND cod_param = 3;
	LET cMensajeRet	= 'Actualizacion EXITOSA.';
	
ELSE
	LET cCodRet		= '000100';
	LET cMensajeRet	= 'ERROR en el parametro de entrada';
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensajeRet), '02') Returning cCodRetBitacora;

	RETURN cCodRet, cMensajeRet;
END IF;	

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensajeRet, '03') Returning cCodRetBitacora;
RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Proceso que depura y actualiza la informaciÃ³n en la tabla cb_triad_salida',
'AUTOR : ',
'FECHA : 04/AGOSTO/2018',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_triad_actualiza_sdos_cnr(pEjecucion smallint)

RETURNING CHAR(6), CHAR(75);
 -- vers 1.0.2 20190409
 DEFINE vEmpresa               CHAR(3);
 DEFINE vmensaje               CHAR(75);
 DEFINE vcodigo                CHAR(6);
 DEFINE cCodRet2               CHAR(5);
 DEFINE iSqlErr                INTEGER;
 DEFINE error_data_var         VARCHAR(80);
 DEFINE isam_err               INTEGER;
 DEFINE vNum_credito           CHAR(20);
 DEFINE vPriDiaMes             DATE;
 DEFINE vFechahoy              DATE;
 DEFINE vfecha_fin_mes_ant     DATE;
 DEFINE vFechacorte            DATE;
 DEFINE vFechacorteant         DATE;
 DEFINE vFechacorte_2          DATE;
 DEFINE vFechacorteant_2       DATE;
 DEFINE iCuantos               INTEGER;
 
 DEFINE v_fecha_corte_ini      DATE;
 DEFINE v_fecha_corte_fin      DATE;
 DEFINE v_fecha_corte          DATE;
 DEFINE i_Dia_corte            INTEGER;
 DEFINE d_SaldoTotal           DECIMAL(18,2);
 DEFINE d_PagoMinimo           DECIMAL(18,2);
 DEFINE d_SumaMontos_1         DECIMAL(18,2);
 DEFINE d_SaldoTotalVencido    DECIMAL(18,2);
 DEFINE d_SumaDevoluciones     DECIMAL(18,2);
 DEFINE i_Numpagos_dev         INTEGER; 
 DEFINE v_fecha_finmes_corte   DATE;
 DEFINE d_Dias                 DECIMAL(4,2); 
 DEFINE i_Dias_parcial         INTEGER;
 DEFINE v_fecha_corte_proxmes  DATE; 
 DEFINE v_fecha_corte_proxmes_ini  DATE;
 DEFINE d_MontoCom_DispEfec    DECIMAL(18,2);
 DEFINE d_MontoPagos           DECIMAL(18,2);
 DEFINE d_InteresesCobrados_1  DECIMAL(18,2);
 DEFINE d_InteresesCobrados_2  DECIMAL(18,2);
 DEFINE d_InteresesCobrados_3  DECIMAL(18,2);
 DEFINE d_InteresesCobrados_tot    DECIMAL(18,2);
 DEFINE vFechaIniciaProc       DATE;
 DEFINE cNum_producto          CHAR(2); 
 DEFINE i_Dia_proceso          INTEGER;
 DEFINE i_Dia_fecha_corte_ini  INTEGER;
 DEFINE i_ContadorGral         INTEGER;
 DEFINE cProceso               CHAR(4);
 DEFINE d_InteresesCargados    DECIMAL(18,2);
 DEFINE d_Iva_IntsCargados     DECIMAL(18,2);
 DEFINE d_Total_IntsCargados   DECIMAL(18,2);
 DEFINE i_ContadorGral_2       INTEGER;
 DEFINE vCount_maesdoshist     SMALLINT;
 DEFINE i_dia_ini              SMALLINT;
 DEFINE i_dia_fin              SMALLINT; 
 DEFINE c_Dia_corte            CHAR(2);
 DEFINE i_Num_vencidos         SMALLINT;
 DEFINE i_Num_vencidos_2       SMALLINT;   
 DEFINE iContador_for          INTEGER;
 DEFINE iCuantos_atras         SMALLINT;
 DEFINE vFecha_mes12_atras     DATE;
 DEFINE iCuantos_2             INTEGER;
 
 DEFINE v_cod_bloqueo_cta      CHAR(4);
 DEFINE v_comision_anualidad   DECIMAL(18,2);
 DEFINE v_cred_ini 		       char(20);
 DEFINE v_cred_fin 		       char(20);
 DEFINE vCount_maesdoshistcrd  smallint;
 
 define iPeorMora_12m          smallint;
 define vFecha_primera_mora    date;
 define dSaldoMax_hist_IndCredcrd decimal(18,2);
 define iNumPagoshist          smallint;
 define iNumConveniosHist      smallint; 
 define iNumConvenios_Cump     smallint;
 define iNumConvenios_NoCump   smallint;
 define vNumConvenios_Cump     smallint;
 define vNumConvenios_NoCump   smallint;
 define vFechacorte_11MesesAntes  date;
 define cBlockCode             char(2);
 define cBlockCodeNull         char(2);
 define cBlockCode2            char(2); 
 define cIdOrigen              char(2);
 define cStatus_cred           char(2);
 define iMescorte              smallint;
 define iDia_corte_nuevo       smallint;
 define iMes_corte_nuevo       smallint;
 define vFechacorte_nuevo      date;
 
 define vNumConvenios_Cump0       smallint;
 define vNumConvenios_NoCump0     smallint;
 define iExisteCuenta             smallint; 
 
 let vNumConvenios_Cump0 = 0;
 let vNumConvenios_NoCump0 = 0;
 
 LET vEmpresa        = '001';
 LET vmensaje        = 'Proceso exitoso';
 LET vcodigo         = '000000';
 LET cCodRet2        = '';
 LET iSqlErr         = 0;
 LET error_data_var  = '';
 LET isam_err        = 0;
 LET vNum_credito    = '';
 LET vFechahoy       = DATE(1);
 LET vPriDiaMes      = DATE(1);
 LET vfecha_fin_mes_ant = DATE(1); 
 LET vFechacorte     = DATE(1);
 LET vFechacorteant  = DATE(1);
 LET vFechacorte_2   = DATE(1);
 LET vFechacorteant_2 = DATE(1);
 LET iCuantos                = 0;
   
 LET v_fecha_corte_ini                 = date(1); --pfecha_corte_ini; 
 LET v_fecha_corte_fin                 = date(1); --pfecha_corte_fin;
 LET v_fecha_corte                     = DATE(1);
 LET i_Dia_corte                        = 0;
 LET d_SaldoTotal                      = 0;
 LET d_PagoMinimo                      = 0;
 LET d_SumaMontos_1                    = 0;
 LET d_SaldoTotalVencido               = 0;
 LET d_SumaDevoluciones                = 0; 
 LET i_Numpagos_dev                     = 0;
 LET v_fecha_finmes_corte              = DATE(1);
 LET d_Dias                            = 0; 
 LET i_Dias_parcial                    = 0;
 LET v_fecha_corte_proxmes             = DATE(1);
 LET v_fecha_corte_proxmes_ini         = DATE(1);
 LET d_MontoCom_DispEfec               = 0;
 LET d_MontoPagos                      = 0;
 LET d_InteresesCobrados_1    		   = 0;
 LET d_InteresesCobrados_2             = 0;
 LET d_InteresesCobrados_3   		   = 0;
 LET d_InteresesCobrados_tot    	   = 0;	
 LET cCodRet2                          = '';
 LET d_SumaMontos_1                    = 0;   
 LET vFechaIniciaProc                  = DATE(1);   
 LET cNum_producto                     = '';   
 LET i_Dia_proceso                     = 0;
 LET i_Dia_fecha_corte_ini             = 0;
 LET i_ContadorGral                    = 0;
 LET cProceso                          = '0113';
 LET d_InteresesCargados               = 0;
 LET d_Iva_IntsCargados                = 0;
 LET d_Total_IntsCargados              = 0;
 LET i_ContadorGral_2                  = 0;
 LET vCount_maesdoshist                = 0;
 LET i_dia_ini                         = 0;
 LET i_dia_fin                         = 0;
 LET c_Dia_corte                       = '';
 LET i_Num_vencidos                    = 0;
 LET i_Num_vencidos_2                  = 0;  
 LET iContador_for                     = 0;
 LET iCuantos_atras                    = 0;
 LET vFecha_mes12_atras                = DATE(1);
 LET iCuantos_2                        = 0;
 LET v_cod_bloqueo_cta                 = '';
 LET v_comision_anualidad              = 0;
 let v_cred_ini 		               = '';
 let v_cred_fin                        = ''; 
 let vCount_maesdoshistcrd             = 0;
 let iPeorMora_12m                     = 0;
 let vFecha_primera_mora               = date(1);
 let dSaldoMax_hist_IndCredcrd         = 0; 
 let iNumPagoshist                     = 0; 
 let iNumConveniosHist                 = 0; 
 let iNumConvenios_Cump                = 0;
 let iNumConvenios_NoCump              = 0;
 let vNumConvenios_Cump                = 0; 
 let vNumConvenios_NoCump              = 0; 
 let vFechacorte_11MesesAntes          = date(1);
 let cBlockCode                        = '';
 let cBlockCodeNull                    = '';
 let cBlockCode2                       = '';
 let cIdOrigen                         = '';
 let cStatus_cred                      = '';
 let iMescorte                         = 0;
 let iDia_corte_nuevo                  = 0; 
 let iMes_corte_nuevo                  = 0; 
 let vFechacorte_nuevo                 = date(1);
 let iExisteCuenta                     = 0;
 
BEGIN	 

ON EXCEPTION SET iSqlErr,isam_err, error_data_var
	IF iSqlErr != 0 THEN
	 LET vcodigo = iSqlErr; 
	 LET vmensaje = error_data_var || '-' || TRIM(vNum_credito);
	 
	CALL bdicobranza:sp_inserta_bitacora_cob(vEmpresa, cProceso, vcodigo, vmensaje, '02') RETURNING cCodRet2;
	 
	  --RETURN vcodigo, vmensaje || '-' || TRIM(vNum_credito); 
	  RETURN vcodigo, vmensaje;
	END IF;
END EXCEPTION; 

 --SET DEBUG FILE TO "/ifxsif01/macf/sp_triad_actualiza_sdos_cnr.trc";
 --TRACE ON;	

 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, vcodigo, vmensaje, '01') RETURNING cCodRet2; 
  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
 
-- La fecha de corte para el proceso que correra diario será la fecha_hoy de sd_fechas -1 día
SELECT fecha_hoy INTO vFechahoy
  FROM bdicred:sd_fechas
 WHERE empresa = vEmpresa;
 
--LET i_dia_ini = DAY(v_fecha_corte_ini);
--LET i_dia_fin = DAY(v_fecha_corte_fin);

let v_fecha_corte = vFechahoy;
LET i_Dia_fecha_corte_ini = DAY(v_fecha_corte);

--let vFechacorte_11MesesAntes = v_fecha_corte_ini -11 units month;  
 --comienza en el 972 al 977
 --SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO v_cred_ini, v_cred_fin
 --     FROM bdicred:sd_param  WHERE cod_param = (971 + pEjecucion)::CHAR(3);   

--LET vFechaIniciaProc = v_fecha_corte_ini;   

	FOREACH WITH HOLD

		SELECT a.num_credito, a.num_producto, NVL(b.dia_corte,0) dia_corte, a.status_cred, nvl(d.sdo_tot_liquidar_ch,0), nvl(d.pago_minimo_ch,0), 
		       nvl(d.monto_pagos_ch,0), nvl(d.sdo_tot_vencido_ch,0), nvl(d.intereses_periodo_ch,0), nvl(d.num_vencidos_ch,0)
		INTO vNum_credito, cNum_producto, i_Dia_corte, cStatus_cred, d_SaldoTotal, d_PagoMinimo, d_MontoPagos, d_SaldoTotalVencido, 
		     d_Total_IntsCargados, i_Num_vencidos_2 
		FROM bdicred:sd_maecredcrd a
			   inner join bdicred:sd_maecredanexocrd b on (a.empresa = b.empresa and a.num_credito = b.num_credito)
			   --inner join bdicred:sd_maesdoscrd c on (a.empresa = c.empresa and a.num_credito = c.num_credito and c.sdo_cap_insoluto >0)
			   inner join bdicred:sd_indicador_cred_crd d on (a.empresa = d.empresa and a.num_credito = d.num_credito)
		WHERE a.empresa = '001'
		  and a.num_credito >= '600000000001'       ---a.num_credito in('630010572182','630107160206')   v_cred_ini and a.num_credito < v_cred_fin
		  --and a.num_credito in('610000214722','610000226999','610000229753','630139955318','630139955359','630139955367','630139955409','630139955474')
          and a.num_credito not in(select num_credito from cb_triad_sdos_inds_cnr where num_credito > '600000000001' and fecha_proceso = vFechahoy)
		  and a.num_producto IN('6011','6300','6400','7600','7700')
		  and a.status_cred IN('AA','BA','BT','VP')
		  and a.fecha_apertura >= MDY('08','13','2009') AND a.fecha_apertura <= vFechahoy 
		  and b.dia_corte = i_Dia_fecha_corte_ini


 	    IF i_Dia_corte <= 0 THEN
			CONTINUE FOREACH;
		END IF;
        
		
		if i_Num_vencidos_2 > 9 then 
			let i_Num_vencidos = 9;
		else
			let i_Num_vencidos =  i_Num_vencidos_2;
		end if;	
		
		let vFechacorteant = date(v_fecha_corte -1 units month);
		
		select nvl(sum(case when flag_pago = '1' then 1 else 0 end),0) as cumplidos,
		  	   nvl(sum(case when flag_pago = '0' then 1 else 0 end),0) as nocumplidos
		  into vNumConvenios_Cump0, vNumConvenios_NoCump0
		  from bdicobranza:cb_compac_his
		 where numcuenta = vNum_credito
		   and fecha_compac between vFechacorteant and v_fecha_corte;
		
		select count(*) into iExisteCuenta
		  from bdicobranza:cb_triad_sdos_inds_cnr
		 where num_credito = vNum_credito;
		
		if iExisteCuenta > 0 then
	     BEGIN;
			 UPDATE "informix".cb_triad_sdos_inds_cnr 
				SET num_credito= vNum_credito, cod_bloqueo_cta1='0000', sdo_tot_liquidar1= d_SaldoTotal, pago_minimo1= d_PagoMinimo, monto_pagos1= d_MontoPagos, 
				sdo_tot_vencido1= d_SaldoTotalVencido, intereses_periodo1= d_Total_IntsCargados, num_vencidos1=i_Num_vencidos,
				 num_convenio_cumplido_1m= vNumConvenios_Cump0, num_convenio_nocumplido_1m=vNumConvenios_NoCump0, 

				cod_bloqueo_cta2= cod_bloqueo_cta1, sdo_tot_liquidar2= sdo_tot_liquidar1, pago_minimo2= pago_minimo1, monto_pagos2= monto_pagos1, 
				sdo_tot_vencido2=sdo_tot_vencido1, intereses_periodo2= intereses_periodo1, num_vencidos2= num_vencidos1, num_convenio_cumplido_2m= num_convenio_cumplido_1m,
				num_convenio_nocumplido_2m= num_convenio_nocumplido_1m, 

				cod_bloqueo_cta3= cod_bloqueo_cta2, sdo_tot_liquidar3= sdo_tot_liquidar2, pago_minimo3= pago_minimo2, monto_pagos3= monto_pagos2, 
				sdo_tot_vencido3=sdo_tot_vencido2, intereses_periodo3= intereses_periodo2, num_vencidos3= num_vencidos2, num_convenio_cumplido_3m= num_convenio_cumplido_2m,
				num_convenio_nocumplido_3m= num_convenio_nocumplido_2m,

				cod_bloqueo_cta4= cod_bloqueo_cta3, sdo_tot_liquidar4= sdo_tot_liquidar3, pago_minimo4= pago_minimo3, monto_pagos4= monto_pagos3, 
				sdo_tot_vencido4=sdo_tot_vencido3, intereses_periodo4= intereses_periodo3, num_vencidos4= num_vencidos3, num_convenio_cumplido_4m= num_convenio_cumplido_3m,
				num_convenio_nocumplido_4m= num_convenio_nocumplido_3m,
				
				cod_bloqueo_cta5= cod_bloqueo_cta4, sdo_tot_liquidar5= sdo_tot_liquidar4, pago_minimo5= pago_minimo4, monto_pagos5= monto_pagos4, 
				sdo_tot_vencido5=sdo_tot_vencido4, intereses_periodo5= intereses_periodo4, num_vencidos5= num_vencidos4, num_convenio_cumplido_5m= num_convenio_cumplido_4m,
				num_convenio_nocumplido_5m= num_convenio_nocumplido_4m,
				
				cod_bloqueo_cta6= cod_bloqueo_cta5, sdo_tot_liquidar6= sdo_tot_liquidar5, pago_minimo6= pago_minimo5, monto_pagos6= monto_pagos5, 
				sdo_tot_vencido6=sdo_tot_vencido5, intereses_periodo6= intereses_periodo5, num_vencidos6= num_vencidos5, num_convenio_cumplido_6m= num_convenio_cumplido_5m,
				num_convenio_nocumplido_6m= num_convenio_nocumplido_5m,

				cod_bloqueo_cta7= cod_bloqueo_cta6, sdo_tot_liquidar7= sdo_tot_liquidar6, pago_minimo7= pago_minimo6, monto_pagos7= monto_pagos6, 
				sdo_tot_vencido7=sdo_tot_vencido6, intereses_periodo7= intereses_periodo6, num_vencidos7= num_vencidos6, num_convenio_cumplido_7m= num_convenio_cumplido_6m,
				num_convenio_nocumplido_7m= num_convenio_nocumplido_6m,

				cod_bloqueo_cta8= cod_bloqueo_cta7, sdo_tot_liquidar8= sdo_tot_liquidar7, pago_minimo8= pago_minimo7, monto_pagos8= monto_pagos7, 
				sdo_tot_vencido8=sdo_tot_vencido7, intereses_periodo8= intereses_periodo7, num_vencidos8= num_vencidos7, num_convenio_cumplido_8m= num_convenio_cumplido_7m,
				num_convenio_nocumplido_8m= num_convenio_nocumplido_7m,

				cod_bloqueo_cta9= cod_bloqueo_cta8, sdo_tot_liquidar9= sdo_tot_liquidar8, pago_minimo9= pago_minimo8, monto_pagos9= monto_pagos8, 
				sdo_tot_vencido9=sdo_tot_vencido8, intereses_periodo9= intereses_periodo8, num_vencidos9= num_vencidos8, num_convenio_cumplido_9m= num_convenio_cumplido_8m,
				num_convenio_nocumplido_9m= num_convenio_nocumplido_8m,

				cod_bloqueo_cta10= cod_bloqueo_cta9, sdo_tot_liquidar10= sdo_tot_liquidar9, pago_minimo10= pago_minimo9, monto_pagos10= monto_pagos9, 
				sdo_tot_vencido10=sdo_tot_vencido9, intereses_periodo10= intereses_periodo9, num_vencidos10= num_vencidos9, num_convenio_cumplido_10m= num_convenio_cumplido_9m,
				num_convenio_nocumplido_10m= num_convenio_nocumplido_9m,

				cod_bloqueo_cta11= cod_bloqueo_cta10, sdo_tot_liquidar11= sdo_tot_liquidar10, pago_minimo11= pago_minimo10, monto_pagos11= monto_pagos10, 
				sdo_tot_vencido11=sdo_tot_vencido10, intereses_periodo11= intereses_periodo10, num_vencidos11= num_vencidos10, num_convenio_cumplido_11m= num_convenio_cumplido_10m,
				num_convenio_nocumplido_11m= num_convenio_nocumplido_10m,
				
				num_vencidos12=num_vencidos11, num_vencidos13=num_vencidos12, num_vencidos14=num_vencidos13, num_vencidos15=num_vencidos14, num_vencidos16=num_vencidos15,
				num_vencidos17=num_vencidos16, num_vencidos18=num_vencidos17, num_vencidos19=num_vencidos18, num_vencidos20=num_vencidos19, num_vencidos21=num_vencidos20,
				num_vencidos22=num_vencidos21, num_vencidos23=num_vencidos22, empresa='001', fecha_proceso= vFechahoy
				WHERE num_credito = vNum_credito;
				
				LET i_ContadorGral_2 = i_ContadorGral_2 + 1;
		 COMMIT;
		
		else
		
		  begin;
		   INSERT INTO bdicobranza:cb_triad_sdos_inds_cnr(num_credito, cod_bloqueo_cta1, sdo_tot_liquidar1, pago_minimo1, monto_pagos1, sdo_tot_vencido1,
		    intereses_periodo1, num_vencidos1, num_convenio_cumplido_1m, num_convenio_nocumplido_1m, cod_bloqueo_cta2, sdo_tot_liquidar2, pago_minimo2, 
			monto_pagos2, sdo_tot_vencido2, intereses_periodo2, num_vencidos2, num_convenio_cumplido_2m, num_convenio_nocumplido_2m, cod_bloqueo_cta3, 
			sdo_tot_liquidar3, pago_minimo3, monto_pagos3, sdo_tot_vencido3, intereses_periodo3, num_vencidos3, num_convenio_cumplido_3m, 
			num_convenio_nocumplido_3m, cod_bloqueo_cta4, sdo_tot_liquidar4, pago_minimo4, monto_pagos4, sdo_tot_vencido4, intereses_periodo4, num_vencidos4,
			num_convenio_cumplido_4m, num_convenio_nocumplido_4m, cod_bloqueo_cta5, sdo_tot_liquidar5, pago_minimo5, monto_pagos5, sdo_tot_vencido5, 
			intereses_periodo5, num_vencidos5, num_convenio_cumplido_5m, num_convenio_nocumplido_5m, cod_bloqueo_cta6, sdo_tot_liquidar6, pago_minimo6, 
			monto_pagos6, sdo_tot_vencido6, intereses_periodo6, num_vencidos6, num_convenio_cumplido_6m, num_convenio_nocumplido_6m, cod_bloqueo_cta7, 
			sdo_tot_liquidar7, pago_minimo7, monto_pagos7, sdo_tot_vencido7, intereses_periodo7, num_vencidos7, num_convenio_cumplido_7m, 
			num_convenio_nocumplido_7m, cod_bloqueo_cta8, sdo_tot_liquidar8, pago_minimo8, monto_pagos8, sdo_tot_vencido8, intereses_periodo8, 
			num_vencidos8, num_convenio_cumplido_8m, num_convenio_nocumplido_8m, cod_bloqueo_cta9, sdo_tot_liquidar9, pago_minimo9, monto_pagos9, 
			sdo_tot_vencido9, intereses_periodo9, num_vencidos9, num_convenio_cumplido_9m, num_convenio_nocumplido_9m, cod_bloqueo_cta10, sdo_tot_liquidar10, 
			pago_minimo10, monto_pagos10, sdo_tot_vencido10, intereses_periodo10, num_vencidos10, num_convenio_cumplido_10m, num_convenio_nocumplido_10m, 
			cod_bloqueo_cta11, sdo_tot_liquidar11, pago_minimo11, monto_pagos11, sdo_tot_vencido11, intereses_periodo11, num_vencidos11, 
			num_convenio_cumplido_11m, num_convenio_nocumplido_11m, num_vencidos12, num_vencidos13, num_vencidos14, num_vencidos15, num_vencidos16, 
			num_vencidos17, num_vencidos18, num_vencidos19, num_vencidos20, num_vencidos21, num_vencidos22, num_vencidos23, empresa, fecha_proceso) --114
            VALUES(vNum_credito, '0000', d_SaldoTotal, d_PagoMinimo, d_MontoPagos, d_SaldoTotalVencido, d_Total_IntsCargados, i_Num_vencidos, vNumConvenios_Cump0,
			vNumConvenios_NoCump0, '0000', 0, 0, 0, 0, 0, 0, 0, 0, '0000', 0, 0, 0, 0, 0, 0, 0, 0, '0000', 0, 0, 0, 0, 0, 0, 0, 0, '0000', 0, 0, 0, 0, 0, 0, 0,
			0, '0000', 0, 0, 0, 0, 0, 0, 0, 0, '0000', 0, 0, 0, 0, 0, 0, 0, 0, '0000', 0, 0, 0, 0, 0, 0, 0, 0, '0000', 0, 0, 0, 0, 0, 0, 0, 0, '0000', 0, 0, 0,
			0, 0, 0, 0, 0, '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '001', vFechahoy);
          commit; 
		  LET i_ContadorGral = i_ContadorGral + 1;
		
		end if;  
		
	END FOREACH
	

 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, vcodigo, vmensaje, '03') RETURNING cCodRet2; 

 --RETURN vcodigo, TRIM(vmensaje);
 RETURN vcodigo, TRIM(vmensaje) || ' Insertados[' || i_ContadorGral || '] - Actualizados[' || i_ContadorGral_2 ||']' ;
 

END;
END PROCEDURE;