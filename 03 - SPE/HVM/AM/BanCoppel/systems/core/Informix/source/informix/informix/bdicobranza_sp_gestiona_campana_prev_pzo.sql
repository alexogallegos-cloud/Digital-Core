CREATE PROCEDURE "informix".sp_gestiona_campana_prev_pzo(pEmpresa CHAR(3))
returning VARCHAR(06),
          VARCHAR(80);
-----------------------------------------------------------------------
--  EXECUTE PROCEDURE "informix".sp_gestiona_campana_prev_pzo('001');

DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(80);
DEFINE cCodRet  				CHAR(6);

DEFINE cMensaje  				VARCHAR(200);
DEFINE dFecha					DATE;
DEFINE vDay						VARCHAR(2);
DEFINE vMonth					VARCHAR(2);
DEFINE vYear					VARCHAR(4);
DEFINE cNumCredito				CHAR(20);
DEFINE cNumcte					CHAR(20);
DEFINE cNumProducto				CHAR(04);
DEFINE v_prod_desc				VARCHAR(10);
DEFINE dFech_ini				DATE;
DEFINE dFechaApertura			DATE;
DEFINE vExcluir					CHAR(1);
DEFINE vBandera					CHAR(1);
DEFINE vBandera2				CHAR(1);
DEFINE pReinicio				CHAR(1);
DEFINE pReinicio2				CHAR(1);
DEFINE v_nombre1				VARCHAR(50);
DEFINE v_nombre2				VARCHAR(50);
DEFINE v_nombre					VARCHAR(50);
DEFINE v_apell_paterno			VARCHAR(50);
DEFINE v_apell_materno			VARCHAR(50);
DEFINE v_estado					VARCHAR(50);
DEFINE v_ciudad					VARCHAR(50);
DEFINE v_telcelular				VARCHAR(10);
DEFINE v_telcasa				VARCHAR(10);
DEFINE v_mto_fin_ven_trasp		DECIMAL(18,2);
DEFINE v_fecha_lim_pago			CHAR(10);
DEFINE v_numerociudad			SMALLINT;
DEFINE vTabla_ins				CHAR(1);
DEFINE dPagoMin					DECIMAL(18,2);
DEFINE v_pago_no_gen_int		DECIMAL(18,2);
DEFINE dTotalLiq				DECIMAL(18,2);
DEFINE cNombreArchivo  			VARCHAR(150);
DEFINE cConsulta				CHAR(2500);
DEFINE cEncabezado				CHAR(2500);
DEFINE cSql						CHAR(2500);
DEFINE cRuta 					VARCHAR(100);
DEFINE vSaldoCapIns				DECIMAL(18,2);
DEFINE vSaldoInt				DECIMAL(18,2);
DEFINE cSucursal				CHAR(4);
DEFINE cIva						DECIMAL(5,3);
DEFINE vProd_desc				VARCHAR(10);

DEFINE iTotalInsertadasApert	INTEGER;
DEFINE iTotalInsertadasMesVen3	INTEGER;
DEFINE iTotalInsertadasPrev		INTEGER;
DEFINE iTotalExcluidasCelNoTel	INTEGER;
DEFINE iTotalUpdtApert			INTEGER;
DEFINE iTotalUpdtMesVen3		INTEGER;
DEFINE iTotalUpdtPrev			INTEGER;
DEFINE iTotalExcluidas 			INTEGER;
DEFINE iTotalCuentas			INTEGER;
DEFINE dFechaProcesoAuxIni		DATE;
DEFINE dFechaProcesoAuxFin		DATE;
DEFINE dFechaInicio				DATE;
DEFINE dFechaFin				DATE;
DEFINE dFechaCal				DATE;
DEFINE dDayCal					INTEGER;

BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = 'Erro en la ejecucion proceso. '||cNumCredito;
     CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;
     DROP TABLE IF EXISTS cuentas_sms_pp;
     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

	--SET DEBUG FILE TO "sp_gestiona_campana_prev_pzo.out";
	--TRACE ON;

	LET cProceso            		= '2054';
	LET P_COD_RET           		= '000000';
	LET P_MENSAJE           		= 'El proceso de GESTION CAMPANA PREVPP se ejecuto correctamente.';
	LET cCodRet           			= '000000';

	LET cMensaje					= '';
	LET dFecha						= DATE(1);
	LET vDay						= '';
	LET vMonth						= '';
	LET vYear						= '';
	LET cNumCredito					= '';
	LET cNumcte						= '';
	LET cNumProducto				= '';
	LET v_prod_desc					= '';
	LET dFech_ini					= DATE(1);
	LET dFechaApertura				= DATE(1);
	LET vExcluir					= '';
	LET vBandera					= '';
	LET vBandera2					= '';
	LET pReinicio					= '';
	LET pReinicio2					= '';
	LET v_nombre1					= '';
	LET v_nombre2					= '';
	LET v_nombre					= '';
	LET v_apell_paterno				= '';
	LET v_apell_materno				= '';
	LET v_estado					= '';
	LET v_ciudad					= '';
	LET v_telcelular				= '';
	LET v_telcasa					= '';
	LET v_mto_fin_ven_trasp			= 0;
	LET v_fecha_lim_pago			= '';
	LET v_numerociudad				= 0;
	LET vTabla_ins					= '';
	LET dPagoMin					= 0;
	LET v_pago_no_gen_int			= 0;
	LET dTotalLiq					= 0;
	LET cNombreArchivo				= '';
	LET cConsulta					= '';
	LET cEncabezado					= '';
	LET cSql						= '';
	LET cRuta						= '';
	LET vSaldoCapIns				= 0;
	LET vSaldoInt					= 0;
	LET cSucursal					= '';
	LET cIva						= 0;
	LET vProd_desc					= '';

	LET iTotalInsertadasApert		= 0;
	LET iTotalInsertadasMesVen3		= 0;
	LET iTotalInsertadasPrev		= 0;
	LET iTotalExcluidasCelNoTel		= 0;
	LET iTotalUpdtApert				= 0;
	LET iTotalUpdtMesVen3			= 0;
	LET iTotalUpdtPrev				= 0;
	LET iTotalExcluidas				= 0;
	LET	iTotalCuentas				= 0;
	LET dFechaProcesoAuxIni			= DATE(1);
	LET dFechaProcesoAuxFin			= DATE(1);
	LET dFechaInicio				= DATE(1);
	LET dFechaFin					= DATE(1);
	LET dFechaCal					= DATE(1);
	LET dDayCal						= 0;

	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '01')
		RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
	   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	   RETURN P_COD_RET,P_MENSAJE;
	END IF;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT fecha_hoy INTO dFecha FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

	SELECT FIRST 1 '1' INTO pReinicio FROM "informix".cb_campana_prev_sms WHERE fecha >= MDY(MONTH(dFecha),1,YEAR(dFecha));

	SELECT FIRST 1 '1' INTO pReinicio2 FROM "informix".cb_campana_prev WHERE fecha >= MDY(MONTH(dFecha),1,YEAR(dFecha));

	IF pReinicio IS NULL OR pReinicio = '' THEN
		TRUNCATE TABLE "informix".cb_campana_prev_sms DROP STORAGE;
		TRUNCATE TABLE "informix".cb_resultados_detallado_prev DROP STORAGE;
		CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, 'NUEVOS REGISTROS SMS FECHA '|| dFecha, '02') RETURNING P_COD_RET;
		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
	ELSE
		CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, 'REGISTROS ACTUALES SMS FECHA '|| dFecha, '02') RETURNING P_COD_RET;
		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
	END IF;

	IF pReinicio2 IS NULL OR pReinicio2 = '' THEN
		TRUNCATE TABLE "informix".cb_campana_prev DROP STORAGE;
		TRUNCATE TABLE "informix".cb_resultados_prev DROP STORAGE;
		CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, 'NUEVOS REGISTROS CAT FECHA '|| dFecha, '02') RETURNING P_COD_RET;
		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
	END IF;

---Pruebas---
	--LET dFecha = TODAY;
---Pruebas---

	LET vDay = LPAD(DAY(dFecha),2,'0'); LET vMonth = LPAD(MONTH(dFecha),2,'0'); LET vYear = YEAR(dFecha);

	IF(DAY(dFecha) >= 1 AND DAY(dFecha) <= 5) THEN
		LET dFechaInicio = mdy(vMonth,6,vYear);
		LET dFechaFin = mdy(vMonth,10,vYear);
	ELIF(DAY(dFecha) >= 6 AND DAY(dFecha) <= 10) THEN
		LET dFechaInicio = mdy(vMonth,11,vYear);
		LET dFechaFin = mdy(vMonth,15,vYear);
	ELIF(DAY(dFecha) >= 11 AND DAY(dFecha) <= 15) THEN
		LET dFechaInicio = mdy(vMonth,16,vYear);
		LET dFechaFin = mdy(vMonth,20,vYear);
	ELIF(DAY(dFecha) >= 16 AND DAY(dFecha) <= 20) THEN
		LET dFechaInicio = mdy(vMonth,21,vYear);
		LET dFechaFin = mdy(vMonth,25,vYear);
	ELIF(DAY(dFecha) >= 21 AND DAY(dFecha) <= 25) THEN
		LET dFechaInicio = mdy(vMonth,26,vYear);
		LET dFechaCal = mdy(vMonth,1,vYear) + 1 UNITS MONTH;
		LET dDayCal = DAY(dFechaCal - 1 UNITS DAY);
		IF(dDayCal = 31) THEN LET dDayCal = 30; END IF;
		LET dFechaFin = mdy(vMonth,dDayCal,vYear);
	ELIF(DAY(dFecha) >= 26 AND DAY(dFecha) <= 31) THEN
		LET dFechaCal = mdy(vMonth,1,vYear) + 1 UNITS MONTH;
		LET dDayCal = DAY(dFechaCal - 1 UNITS DAY);
		IF(dDayCal = 31) THEN 
			LET dFechaInicio = mdy(vMonth,dDayCal,vYear);
			LET dFechaFin = mdy(MONTH(dFechaCal),5,YEAR(dFechaCal));
		ELSE
			LET dFechaInicio = dFechaCal;
			LET dFechaFin = MDY(MONTH(dFechaInicio),5,YEAR(dFechaInicio));
		END IF;
	END IF;

	LET dFechaProcesoAuxIni = MDY(MONTH(dFecha),1,YEAR(dFecha)) - 3 UNITS MONTH;
	LET dFechaProcesoAuxFin = dFechaProcesoAuxIni + 1 UNITS MONTH;
	LET dFechaProcesoAuxFin = dFechaProcesoAuxFin - 1 UNITS DAY;

	SELECT a.empresa, a.num_credito, a.numcte, a.num_producto, a.fecha_apertura, d.mto_fin_ven_trasp, b2.capital_mto_cuota AS pago_minimo, a.sucursal
	FROM bdicred:"informix".sd_maecredcrd a
	INNER JOIN bdicred:"informix".sd_maecredanexocrd c ON (c.empresa = a.empresa AND c.num_credito = a.num_credito AND c.prox_fecha_pago >= dFechaInicio AND c.prox_fecha_pago <= dFechaFin)
	INNER JOIN bdicred:"informix".sd_maesdoscrd d ON (d.num_credito = a.num_credito AND d.mto_fin_ven_trasp = 0)
	INNER JOIN bdicred:"informix".sd_amortiza_creditocrd b2 ON (b2.empresa = a.empresa AND b2.num_credito = a.num_credito AND b2.capital_status = "3" AND NVL(b2.capital_mto_cuota,0) >= 50)
	WHERE a.num_credito > ""
	AND a.num_producto IN ('6300','7600','7700')
	AND a.status_cred IN ('AA','E1')
	AND (d.monto_vencido + d.mto_venc_trasp) = 0
	AND a.fecha_apertura > dFech_ini
	INTO TEMP cuentas_sms_pp WITH NO LOG;

	CREATE INDEX inx_empresa_sms_pp ON cuentas_sms_pp(empresa) in dbs_movhis_idx3;
	UPDATE STATISTICS MEDIUM FOR TABLE cuentas_sms_pp;

	FOREACH WITH HOLD
		SELECT num_credito, numcte, num_producto, fecha_apertura, mto_fin_ven_trasp, pago_minimo, sucursal
		INTO cNumCredito, cNumcte, cNumProducto, dFechaApertura, v_mto_fin_ven_trasp, dPagoMin, cSucursal
		FROM cuentas_sms_pp
		WHERE empresa = pEmpresa

		SELECT LIMIT 1 '1'
		INTO vExcluir
		FROM bdicred:"informix".sd_programa_apoyo
		WHERE num_credito = cNumCredito AND bandera = 'A';

		IF(vExcluir IS NULL) THEN LET vExcluir = ''; END IF;

		IF (vExcluir = '1') THEN CONTINUE FOREACH; END IF;

		LET iTotalCuentas = iTotalCuentas + 1;

		SELECT LIMIT 1 '1' INTO vBandera
		FROM bdicred:"informix".sd_maesdoscontcrd
		WHERE empresa = pEmpresa
		AND num_credito = cNumCredito
		AND mto_fin_ven_trasp > 0
		AND fecha = dFechaProcesoAuxFin;

		IF(vBandera IS NULL) THEN LET vBandera = ''; END IF;

		SELECT nombre1, nombre2, apell_paterno, apell_materno
			INTO v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno
		FROM bdinteg:"informix".si_cliente WHERE empresa = pEmpresa AND numcte = cNumcte;

		IF(v_nombre1 IS NULL) THEN LET v_nombre1 = ''; END IF;

		IF(v_nombre2 IS NULL) THEN LET v_nombre2 = ''; END IF;
		
		IF(v_nombre2 = '') THEN 
			LET v_nombre = TRIM(v_nombre1);
		ELSE
			LET v_nombre = TRIM(v_nombre1)||' '||TRIM(v_nombre2);
		END IF;

		IF(v_apell_paterno IS NULL) THEN LET v_apell_paterno = ''; END IF;

		IF(v_apell_materno IS NULL) THEN LET v_apell_materno = ''; END IF;

		SELECT UPPER(d2.descripcion), d3.municipiozona, d1.numerociudad
		INTO v_estado, v_ciudad, v_numerociudad
		FROM bdinteg:"informix".si_direcciones_actual d1
		LEFT OUTER JOIN bdisolic:ss_circulo_edos d2 ON (d2.empresa = pEmpresa AND d2.clave = d1.estado)
		LEFT OUTER JOIN bdinteg:si_catzonas d3 ON (d3.numerociudad = d1.numerociudad and d3.numerocolonia = d1.numerocolonia)
		WHERE d1.numcte = cNumcte
		AND d1.tipo_dir='1';

		IF(v_estado IS NULL) THEN LET v_estado = ''; END IF;

		IF(v_ciudad IS NULL) THEN LET v_ciudad = ''; END IF;

		IF(v_numerociudad IS NULL) THEN LET v_numerociudad = 0; END IF;

		SELECT SUBSTR(telefono,LENGTH(telefono)-9,10)
		INTO v_telcelular
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE numcte = cNumcte
		AND tipo_tel = 2 /* AND cofetel = 'V' */--RQM 09 598"
		AND length(nvl(telefono,'')) >= 10 AND NVL(telefono,'') <> '';

		IF(v_telcelular IS NULL) THEN LET v_telcelular = ''; END IF;
		
		SELECT TO_CHAR(prox_fecha_pago,'%d/%m/%Y')
		INTO v_fecha_lim_pago
		FROM bdicred:"informix".sd_maecredanexocrd
		WHERE num_credito = cNumCredito;

		IF(v_fecha_lim_pago IS NULL) THEN LET v_fecha_lim_pago = ''; END IF;

		SELECT iva
		INTO cIva
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa
		AND	sucursal = cSucursal;

		IF(cIva IS NULL) THEN LET cIva = 0; END IF;

		SELECT sdo_cap_insoluto, sdo_intereses
		INTO vSaldoCapIns, vSaldoInt
		FROM bdicred:"informix".sd_maesdoscrd
		WHERE empresa = pEmpresa 
		AND num_credito = cNumCredito;

		IF(vSaldoCapIns IS NULL) THEN LET vSaldoCapIns = 0; END IF;

		IF(vSaldoInt IS NULL) THEN LET vSaldoInt = 0; END IF;

		LET dTotalLiq = vSaldoCapIns + vSaldoInt + (vSaldoInt*cIva);

		IF(cNumProducto = '6300') THEN
			LET vProd_desc = 'PP12';
		ELIF(cNumProducto = '7600') THEN
			LET vProd_desc = 'PP18';
		ELIF(cNumProducto = '7700') THEN
			LET vProd_desc = 'PP24';
		END IF;

		SELECT LIMIT 1 '1'
		INTO vTabla_ins
		FROM "informix".cb_campana_prev_sms
		WHERE num_credito = cNumCredito
		AND numcte = cNumcte
		AND num_producto = cNumProducto;

		IF(vTabla_ins IS NULL) THEN LET vTabla_ins = ''; END IF;

		IF(v_telcelular = '') THEN --el cliente no tiene un número de celular válido
			SELECT SUBSTR(telefono,LENGTH(telefono)-9,10)
			INTO v_telcasa
			FROM bdinteg:"informix".si_telefonos_actual
			WHERE numcte = cNumcte
			AND tipo_tel = 1 /* AND cofetel = 'V' */--RQM 09 598"
			AND length(nvl(telefono,'')) >= 10 AND NVL(telefono,'') <> '';

			IF(v_telcasa IS NULL) THEN LET v_telcasa = ''; END IF;

			IF(v_telcasa = '') THEN
				LET	iTotalExcluidasCelNoTel = iTotalExcluidasCelNoTel + 1;
				CONTINUE FOREACH;
			ELSE
				SELECT LIMIT 1 '1' INTO vBandera2
				FROM "informix".cb_campana_prev
				WHERE num_credito = cNumCredito
				AND num_producto = cNumProducto;

				IF(vBandera2 IS NULL) THEN LET vBandera2 = ''; END IF;

				IF(vBandera2 = '1') THEN
					BEGIN;
						UPDATE "informix".cb_campana_prev
						SET fecha = dFecha,
							nombre = TRIM(v_nombre),
							prod_desc = vProd_desc,
							no_vencidos = v_mto_fin_ven_trasp,
							fecha_lim_pago = v_fecha_lim_pago,
							pago_minimo = dPagoMin,
							pago_no_gen_int = dTotalLiq,
							saldo_tot_liquidar = dTotalLiq,
							bandera_insert = 'MS',
							procesar = '1'
						WHERE num_credito = cNumCredito
						AND num_producto = cNumProducto;
					COMMIT;

					LET iTotalUpdtPrev = iTotalUpdtPrev + 1;
				ELSE
					BEGIN;
						INSERT INTO "informix".cb_campana_prev(fecha, numcte, nombre, apell_paterno, apell_materno, estado, ciudad, telcasa, telcelular, num_producto, prod_desc, num_credito, no_vencidos, fecha_lim_pago, pago_minimo, pago_no_gen_int, saldo_tot_liquidar, num_ciudad, bandera_insert, campana, procesar, cont_sms)
						VALUES(dFecha, cNumcte, TRIM(v_nombre), TRIM(v_apell_paterno), TRIM(v_apell_materno), TRIM(v_estado), TRIM(v_ciudad), TRIM(v_telcasa), TRIM(v_telcelular), cNumProducto, vProd_desc, cNumCredito, v_mto_fin_ven_trasp,v_fecha_lim_pago, dPagoMin, dTotalLiq, dTotalLiq, v_numerociudad, 'MS', 'CAT', '1', 0);
					COMMIT;

					LET iTotalInsertadasPrev = iTotalInsertadasPrev + 1;
				END IF;
			END IF;
		ELSE
			IF (dFechaApertura >= dFechaProcesoAuxIni) AND (dFechaApertura <= dFechaProcesoAuxFin) THEN --Fecha de otorgamiento de 3 meses previos
				IF vTabla_ins = '1' THEN
					BEGIN;
						UPDATE "informix".cb_campana_prev_sms
						SET fecha = dFecha,
							nombre = TRIM(v_nombre),
							prod_desc = vProd_desc,
							no_vencidos = v_mto_fin_ven_trasp,
							fecha_lim_pago = v_fecha_lim_pago,
							pago_minimo = dPagoMin,
							pago_no_gen_int = dTotalLiq,
							saldo_tot_liquidar = dTotalLiq,
							procesar = '1'
						WHERE num_credito = cNumCredito
						AND numcte = cNumcte
						AND num_producto = cNumProducto;
					COMMIT;
					
					LET iTotalUpdtApert = iTotalUpdtApert + 1;
				ELSE
					BEGIN;
						INSERT INTO "informix".cb_campana_prev_sms(fecha, numcte, nombre, apell_paterno, apell_materno, estado, ciudad, telcasa, telcelular, num_producto, prod_desc, num_credito, no_vencidos, fecha_lim_pago, pago_minimo, pago_no_gen_int, saldo_tot_liquidar, num_ciudad, bandera_insert, campana, procesar, cont_sms)
						VALUES(dFecha, cNumcte, TRIM(v_nombre), TRIM(v_apell_paterno), TRIM(v_apell_materno), TRIM(v_estado), TRIM(v_ciudad), TRIM(v_telcasa), TRIM(v_telcelular), cNumProducto, vProd_desc, cNumCredito, v_mto_fin_ven_trasp,v_fecha_lim_pago, dPagoMin, dTotalLiq, dTotalLiq, v_numerociudad, 'AP', 'SMS', '1', 0);
					COMMIT;

					LET iTotalInsertadasApert = iTotalInsertadasApert + 1;
				END IF;
			ELIF vBandera = '1' THEN --Número de meses vencidos al cierre de tres meses previos > 0
				IF vTabla_ins = '1' THEN
					BEGIN;
						UPDATE "informix".cb_campana_prev_sms
						SET fecha = dFecha,
							nombre = TRIM(v_nombre),
							prod_desc = vProd_desc,
							no_vencidos = v_mto_fin_ven_trasp,
							fecha_lim_pago = v_fecha_lim_pago,
							pago_minimo = dPagoMin,
							pago_no_gen_int = dTotalLiq,
							saldo_tot_liquidar = dTotalLiq,
							procesar = '1'
						WHERE num_credito = cNumCredito
						AND numcte = cNumcte
						AND num_producto = cNumProducto;
					COMMIT;

					LET iTotalUpdtMesVen3 = iTotalUpdtMesVen3 + 1;
				ELSE
					BEGIN;
						INSERT INTO "informix".cb_campana_prev_sms(fecha, numcte, nombre, apell_paterno, apell_materno, estado, ciudad, telcasa, telcelular, num_producto, prod_desc, num_credito, no_vencidos, fecha_lim_pago, pago_minimo, pago_no_gen_int, saldo_tot_liquidar, num_ciudad, bandera_insert, campana, procesar, cont_sms)
						VALUES(dFecha, cNumcte, TRIM(v_nombre), TRIM(v_apell_paterno), TRIM(v_apell_materno), TRIM(v_estado), TRIM(v_ciudad), TRIM(v_telcasa), TRIM(v_telcelular), cNumProducto, vProd_desc, cNumCredito, v_mto_fin_ven_trasp,v_fecha_lim_pago, dPagoMin, dTotalLiq, dTotalLiq, v_numerociudad, 'M3', 'SMS', '1', 0);
					COMMIT;

					LET iTotalInsertadasMesVen3 = iTotalInsertadasMesVen3 + 1;
				END IF;
			ELSE
				LET	iTotalExcluidas = iTotalExcluidas + 1;
			END IF;
		END IF;
	END FOREACH;

	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_campana_prev_sms;

	DROP TABLE cuentas_sms_pp;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas a procesadas PP: ' ||iTotalCuentas;
	LET cMensaje = TRIM(cMensaje) ||'    Cuentas excluidas PP : ' ||iTotalExcluidas;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = "";
	LET cMensaje = 'Cuentas insert Apertura PP : ' ||iTotalInsertadasApert;
	LET cMensaje = TRIM(cMensaje) ||'    Cuentas insert MesVen Mes 3 PP : ' ||iTotalInsertadasMesVen3;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = "";
	LET cMensaje = 'Cuentas insert CAT Prev PP : ' ||iTotalInsertadasPrev;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = "";
	LET cMensaje = 'Cuentas Actualizadas CAT Prev PP : ' ||iTotalUpdtPrev;
	LET cMensaje = TRIM(cMensaje) ||'    Cuentas Actualizadas Apertura PP : ' ||iTotalUpdtApert;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = "";
	LET cMensaje = 'Cuentas Actualizadas MesVen Mes 3 PP : ' ||iTotalUpdtMesVen3;
	LET cMensaje = TRIM(cMensaje) ||'    Cuentas excluidas NO CEL Y NO TEL PP : ' ||iTotalExcluidasCelNoTel;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = "";
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;

	RETURN cCodRet,P_MENSAJE;

END;
END PROCEDURE;