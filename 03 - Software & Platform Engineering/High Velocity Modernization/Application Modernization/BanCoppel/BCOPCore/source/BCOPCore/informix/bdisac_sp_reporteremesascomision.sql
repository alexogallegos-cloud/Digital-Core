CREATE PROCEDURE "informix".sp_reporteremesascomision()

	RETURNING
		CHAR	(25) as archivo,
		CHAR	(5) as codret,
		CHAR	(100) as mensaje;

	-- DECLARACION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE iSamErr			INTEGER;
	DEFINE sCommit			SMALLINT;
	DEFINE cProceso			CHAR(100);
	DEFINE dFechaIni		DATE;
	DEFINE dFechaFin		DATE;
	DEFINE cCodRet			CHAR(5);
	DEFINE cVarError		CHAR(100);
	DEFINE cRuta			CHAR(50);
	DEFINE cNombreArchivo	CHAR(50);
	DEFINE cSQL 			CHAR(1200);
	DEFINE v_nombre_sucursal1 CHAR(100);
	DEFINE v_id_sucursal1	CHAR (5);
	DEFINE contador1	INTEGER;
	DEFINE contador2	INTEGER;
	
	-- DECLARACION DE VARIABLES PARA EL REPORTE
	DEFINE cFechaIni		DATE;
	DEFINE cFechaFin		DATE;
	DEFINE cid_suc			CHAR(4);
	DEFINE vId_suc			CHAR(4);
	DEFINE cnum_BTS 		INTEGER;
	DEFINE cmto_BTS 		MONEY(16,2);
	DEFINE ccomis_BTS 		MONEY(16,2);
	DEFINE cpago_efec_BTS 	INTEGER;
	DEFINE cpago_abono_BTS 	INTEGER;
	DEFINE cnum_WU 			INTEGER;
	DEFINE cmto_WU 			MONEY(16,2);
	DEFINE ccomis_WU 		MONEY(16,2);
	DEFINE cpago_efec_WU 	INTEGER;
	DEFINE cpago_abono_WU 	INTEGER;
	DEFINE cnum_OV 			INTEGER;
	DEFINE cmto_OV 			MONEY(16,2);
	DEFINE ccomis_OV 		MONEY(16,2);
	DEFINE cpago_efec_OV 	INTEGER;
	DEFINE cpago_abono_OV 	INTEGER;
	DEFINE cnum_VG 			INTEGER;
	DEFINE cmto_VG 			MONEY(16,2);
	DEFINE ccomis_VG 		MONEY(16,2);
	DEFINE cpago_efec_VG 	INTEGER;
	DEFINE cpago_abono_VG 	INTEGER;
	DEFINE cnum_APP 		INTEGER;
	DEFINE cmto_APP 		MONEY(16,2);
	DEFINE ccomis_APP 		MONEY(16,2);
	DEFINE cpago_efec_APP 	INTEGER;
	DEFINE cpago_abono_APP INTEGER;
	DEFINE cnum_TOT 		INTEGER;
	DEFINE cmto_TOT 		MONEY(16,2);
	DEFINE ccomis_TOT 		MONEY(16,2);
	DEFINE cpago_efec_TOT 		INTEGER;
	DEFINE cpago_abono_TOT 		INTEGER;
	DEFINE cAnioMesAct		CHAR(6);
	

	-- INICIALIZAN LAS VARIABLES
	LET cProceso = 'Genera Reporte Remesas Comision';
	LET cCodRet = '00000';
	LET cVarError = 'Ejecucion Exitosa';
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo = 'repremesascom_';
	LET cSQL = '';
	LET sCommit = 0;
    LET v_nombre_sucursal1='';
    LET v_id_sucursal1='';
	LET contador1=0;
	LET contador2=0;

	-- INICIALIZAN LAS VARIABLES DE REPORTE
	LET cFechaIni = '';
	LET cFechaFin = '';
	LET cid_suc	= '';
	LET vId_suc	= '';
	LET cnum_BTS = 0; 	
	LET cmto_BTS = 0;
	LET ccomis_BTS = 0;
	LET cpago_efec_BTS = 0;
	LET cpago_abono_BTS = 0;
	LET cnum_WU = 0;		
	LET cmto_WU = 0;		
	LET ccomis_WU = 0;	
	LET cpago_efec_WU = 0;
	LET cpago_abono_WU = 0;
	LET cnum_OV = 0;		
	LET cmto_OV = 0;		
	LET ccomis_OV = 0;	
	LET cpago_efec_OV = 0;
	LET cpago_abono_OV = 0;
	LET cnum_VG = 0;		
	LET cmto_VG = 0;		
	LET ccomis_VG = 0;	
	LET cpago_efec_VG = 0;
	LET cpago_abono_VG = 0;
	LET cnum_APP = 0;	
	LET cmto_APP = 0;	
	LET ccomis_APP = 0;	
	LET cpago_efec_APP = 0;
	LET cpago_abono_APP = 0;
	LET cnum_TOT = 0;	
	LET cmto_TOT = 0;	
	LET ccomis_TOT = 0;	
	LET cpago_efec_TOT = 0;
	LET cpago_abono_TOT = 0;
	LET cAnioMesAct ='';
	

	BEGIN

	-- CONTROL DE ERRORES
	ON EXCEPTION SET iSqlErr, iSamErr, cVarError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cVarError = 'Error No Controlado';
			INSERT INTO bdisac:"informix".sac_reg_gen_rep_remesas(reporte, fecha_inicio, fecha_fin, status_ejecucion, observacion)
			VALUES (cProceso, CURRENT, CURRENT, cCodRet, cVarError);

			RETURN cProceso, cCodRet, cVarError;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/nmr/remesas/repremesascom_.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- BORRAMOS TABLAS PARA GENERAR UN NUEVO REPORTE
	DROP TABLE IF EXISTS tmp_folio_suc;
	DROP TABLE IF EXISTS tmp_movimientos;
	DROP TABLE IF EXISTS tmp_cheques;
	
	
--OBTIENE LOS DIAS INICIO Y FIN DEL MES ANTERIOR
		SELECT first 1 date(LAST_DAY(ADD_MONTHS(today, -2)) + 1) inicio, date(LAST_DAY(ADD_MONTHS(today, -1))) fin, TO_CHAR(TODAY-1 UNITS MONTH, '%m%Y') mesanio
		INTO cFechaIni, cFechaFin, cAnioMesAct
		FROM systables WHERE tabid = 1;

		--LET cFechaIni=mdy(1,1,2024);
		--LET cFechaFin=mdy(1,10,2024);


--BORRA TABLA FISICA
		DROP INDEX IF EXISTS "informix".idx_reportcomision_id_suc;
		TRUNCATE TABLE "informix".sac_reportcom_rem;

		
-- IDENTIFICAMOS LOS NUMEROS DE FOLIO_SUC DE TODAS LAS REMESAS
	SELECT  DISTINCT (folio_suc) 
		FROM  sac_movimientoshistorial
		WHERE ((numcategoria = '07' and numconvenio='004') 
		or (numcategoria = '07' and numconvenio='006')
		or (numcategoria = '07' and numconvenio='007')
		or (numcategoria = '07' and numconvenio='008')
		or (numcategoria = '07' and numconvenio='009'))
		AND flag_confirmacion_central= 1
		AND flag_confirmacion_sucursal= 1
		AND fecha_pago >= cFechaIni
		AND fecha_pago <= cFechaFin
		AND status_cancelado <> 'S'
		INTO TEMP tmp_folio_suc WITH NO LOG;

	
--INDICE PARA TABLE TEMPORAL DE FOLIO_SUC
	EXECUTE IMMEDIATE 'CREATE INDEX idx_temp_folio_id_suc ON tmp_folio_suc(folio_suc)';
	
-- OBTENEMOS LOS DATOS DE LA TABLA SAC_MOVIMIENTOSHISTORIAL
	SELECT  sac.id_sucursal,sac.folio_suc,sac.numcategoria,sac.numconvenio,sac.forma_pago,sac.importe_pago,sac.importe_comision_convenio,sac.fecha_pago
		FROM sac_movimientoshistorial sac,tmp_folio_suc tempsac
		WHERE tempsac.folio_suc = sac.folio_suc
		and ((numcategoria = '07' and numconvenio='004') 
		or (numcategoria = '07' and numconvenio='006')
		or (numcategoria = '07' and numconvenio='007')
		or (numcategoria = '07' and numconvenio='008')
		or (numcategoria = '07' and numconvenio='009'))
		AND flag_confirmacion_central= 1
		AND flag_confirmacion_sucursal= 1
		AND fecha_pago >= cFechaIni
		AND fecha_pago <= cFechaFin
		AND status_cancelado <> 'S'
		INTO TEMP tmp_movimientos WITH NO LOG;

--INDICE PARA TABLE TEMPORAL DE MOVIMIENTOS
	EXECUTE IMMEDIATE 'CREATE INDEX idx_temp_movtos_id_suc ON tmp_movimientos(folio_suc, id_sucursal)';
	

-- OBTENEMOS LOS DATOS DE LA TABLA SC_MOVHIS_OLD
	SELECT  tempsac.folio_suc 
		FROM bdicheq:"informix".sc_movhis_old mvold,tmp_folio_suc tempsac
		WHERE tempsac.folio_suc = mvold.folio_suc
		AND fech_alt >= cFechaIni
		AND fech_alt <= cFechaFin
		AND transacc IN ('1110','1140','1121','1151','1122','1152','1123','1153','1325','1355')
		AND empresa = '001'
		AND cancelad <> 'S'
	INTO temp tmp_cheques WITH NO LOG;
	

---COMPLEMENTO DE SC_MOVHIS
	INSERT INTO tmp_cheques
    SELECT tempsac.folio_suc
        FROM bdicheq:sc_movhis mv,tmp_folio_suc tempsac
        WHERE  tempsac.folio_suc = mv.folio_suc
        AND fech_alt >= cFechaIni
        AND fech_alt <= cFechaFin
        AND transacc IN ('1110','1140','1121','1151','1122','1152','1123','1153','1325','1355')
        AND empresa = '001'
        AND cancelad <> 'S';

--INDICE PARA TABLE TEMPORAL DE CHEQUES
	EXECUTE IMMEDIATE  'CREATE INDEX idx_tmp_cheques_folio_suc ON tmp_cheques(folio_suc)';

	
--SE LLENAN LOS DATOS DE SUCURSALES EN LA TABLA DEL REPORTE
BEGIN;
FOREACH insertcursor2 WITH HOLD FOR
		SELECT {+INDEX(bdinteg:"informix".si_sucursales idx_sucursal)+INDEX(bdisac:"informix".tmp_cheques idx_tmp_cheques_folio_suc)} DISTINCT REPLACE(REPLACE(REPLACE(REPLACE(S.nombre,"\","-"),"."," "),","," "),"/","-") AS nombre_sucursal,M.id_sucursal 
		INTO v_nombre_sucursal1, v_id_sucursal1	
		FROM tmp_movimientos M, bdinteg:si_sucursales S, tmp_cheques C
		WHERE M.folio_suc= C.folio_suc
		AND M.id_sucursal=S.sucursal
	ORDER BY 2 ASC

	INSERT INTO "informix".sac_reportcom_rem (nombre_sucursal,id_sucursal)
	VALUES (v_nombre_sucursal1, v_id_sucursal1);
	LET contador1=contador1+1;
	IF contador1 >= 1000 THEN 
		COMMIT WORK;
		BEGIN WORK;
		LET contador1=0;
	END IF;

END FOREACH;

COMMIT WORK;

--INDICE PARA TABLA FISICA FINAL
	BEGIN;
	CREATE INDEX "informix".idx_reportcomision_id_suc
	    ON "informix".sac_reportcom_rem(id_sucursal) ONLINE;
	COMMIT;
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_reportcom_rem;
	
	
	BEGIN WORK;
	FOREACH vCursor WITH HOLD FOR SELECT {+INDEX(bdisac:"informix".sac_reportcom_rem idx_reportcomision_id_suc)}id_sucursal INTO vId_suc FROM "informix".sac_reportcom_rem 
		
		SELECT  {+INDEX(bdisac:"informix".tmp_movimientos idx_temp_movtos_id_suc)}a.id_sucursal, 
				sum(case when numconvenio='004' then 1 else 0 end) as num_trans_BTS,
			    sum(case when numconvenio='004' then importe_pago else 0 end) as mto_trans_BTS,
			    sum(case when numconvenio='004' then 0 else 0 end) as comision_BTS, -- se elimina importe_comision_convenio para enviar comision CERO
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='004' THEN 1 ELSE 0 END) efe_bts, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='004' THEN 1 ELSE 0 END) abo_bts,

			    sum(case when numconvenio='006' then 1 else 0 end) as num_trans_WU,
			    sum(case when numconvenio='006' then importe_pago else 0 end) as mto_trans_WU,
			    sum(case when numconvenio='006' then 0 else 0 end) as comision_WU, 
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='006' THEN 1 ELSE 0 END) efe_WU, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='006' THEN 1 ELSE 0 END) abo_WU,

			    sum(case when numconvenio='007' then 1 else 0 end) as num_trans_OV,
			    sum(case when numconvenio='007' then importe_pago else 0 end) as mto_trans_OV,
			    sum(case when numconvenio='007' then 0 else 0 end) as comision_OV, 
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='007' THEN 1 ELSE 0 END) efe_OV, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='007' THEN 1 ELSE 0 END) abo_OV,

			    sum(case when numconvenio='008' then 1 else 0 end) as num_trans_VG,
			    sum(case when numconvenio='008' then importe_pago else 0 end) as mto_trans_VG,
			    sum(case when numconvenio='008' then 0 else 0 end) as comision_VG, 
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='008' THEN 1 ELSE 0 END) efe_VG, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='008' THEN 1 ELSE 0 END) abo_VG,

			    sum(case when numconvenio='009' then 1 else 0 end) as num_trans_APP,
			    sum(case when numconvenio='009' then importe_pago else 0 end) as mto_trans_APP,
			    sum(case when numconvenio='009' then 0 else 0 end) as comision_APP, 
			    SUM(CASE WHEN a.forma_pago='1' and numconvenio='009' THEN 1 ELSE 0 END) efe_APP, 
			    SUM(CASE WHEN a.forma_pago <> '1' and numconvenio='009' THEN 1 ELSE 0 END) abo_APP
	     INTO cid_suc, cnum_BTS, cmto_BTS, ccomis_BTS, cpago_efec_BTS, cpago_abono_BTS, --REMESA BTS
	     			cnum_WU, cmto_WU, ccomis_WU, cpago_efec_WU, cpago_abono_WU, --REMESA WESTERN UNION (WU)	
	     			cnum_OV, cmto_OV, ccomis_OV, cpago_efec_OV, cpago_abono_OV, --REMESA ORLANDI VALUTA (OV)
	     			cnum_VG, cmto_VG, ccomis_VG, cpago_efec_VG, cpago_abono_VG, --REMESA VIGO (VG)
	     			cnum_APP, cmto_APP, ccomis_APP, cpago_efec_APP, cpago_abono_APP --REMESA APPRIZA (APP)	
		 FROM tmp_movimientos a, tmp_cheques b 
	        WHERE a.folio_suc= b.folio_suc 
			and a.id_sucursal= vId_suc
	        group by 1;
	    

	    LET cnum_BTS=nvl(cnum_BTS,0);
		LET cmto_BTS=nvl(cmto_BTS,0);
		LET ccomis_BTS=nvl(ccomis_BTS,0);
		LET cpago_efec_BTS=nvl(cpago_efec_BTS,0);
		LET cpago_abono_BTS=nvl(cpago_abono_BTS,0);
				
	    LET cnum_WU=nvl(cnum_WU,0);
		LET cmto_WU=nvl(cmto_WU,0);
		LET ccomis_WU=nvl(ccomis_WU,0);
		LET cpago_efec_WU=nvl(cpago_efec_WU,0);
		LET cpago_abono_WU=nvl(cpago_abono_WU,0);

	    LET cnum_OV=nvl(cnum_OV,0);
		LET cmto_OV=nvl(cmto_OV,0);
		LET ccomis_OV=nvl(ccomis_OV,0);
		LET cpago_efec_OV=nvl(cpago_efec_OV,0);
		LET cpago_abono_OV=nvl(cpago_abono_OV,0);
					
	    LET cnum_VG=nvl(cnum_VG,0);
		LET cmto_VG=nvl(cmto_VG,0);
		LET ccomis_VG=nvl(ccomis_VG,0);
		LET cpago_efec_VG=nvl(cpago_efec_VG,0);
		LET cpago_abono_VG=nvl(cpago_abono_VG,0);
				
	    LET cnum_APP=nvl(cnum_APP,0);
		LET cmto_APP=nvl(cmto_APP,0);
		LET ccomis_APP=nvl(ccomis_APP,0);
		LET cpago_efec_APP=nvl(cpago_efec_APP,0);
		LET cpago_abono_APP=nvl(cpago_abono_APP,0);
				
		
--SUMA DE NUMERO DE PAGOS EN TRANSACCION	
		LET cnum_TOT = nvl(cnum_BTS,0) + nvl(cnum_WU,0) + nvl(cnum_OV,0) + nvl(cnum_VG,0) + nvl(cnum_APP,0);
		LET cmto_TOT =  nvl(cmto_BTS,0) + nvl(cmto_WU,0) + nvl(cmto_OV,0) + nvl(cmto_VG,0) + nvl(cmto_APP,0);
		LET ccomis_TOT = nvl(ccomis_BTS,0) + nvl(ccomis_WU,0) + nvl(ccomis_OV,0) + nvl(ccomis_VG,0) + nvl(ccomis_APP,0);

		
--SUMA DE NUMERO DE PAGOS EN EFECTIVO Y ABONO
		LET cpago_efec_TOT = nvl(cpago_efec_BTS,0) + nvl(cpago_efec_WU,0) + nvl(cpago_efec_OV,0) + nvl(cpago_efec_VG,0) + nvl(cpago_efec_APP,0);
		LET cpago_abono_TOT = nvl(cpago_abono_BTS,0) + nvl(cpago_abono_WU,0) + nvl(cpago_abono_OV,0) + nvl(cpago_abono_VG,0) + nvl(cpago_abono_APP,0);
		
--		BEGIN WORK;

		UPDATE "informix".sac_reportcom_rem SET num_trans_BTS = cnum_BTS, mto_trans_BTS = cmto_BTS, comision_BTS = ccomis_BTS, pago_efec_BTS = cpago_efec_BTS, pago_abono_BTS = cpago_abono_BTS,
									num_trans_WU=cnum_WU, mto_trans_WU=cmto_WU, comision_WU= ccomis_WU, pago_efec_WU=cpago_efec_WU, pago_abono_WU=cpago_abono_WU,
									num_trans_OV = cnum_OV,mto_trans_OV = cmto_OV, comision_OV =  ccomis_OV, pago_efec_OV = cpago_efec_OV, pago_abono_OV = cpago_abono_OV,
									num_trans_VG = cnum_VG, mto_trans_VG = cmto_VG, comision_VG =  ccomis_VG, pago_efec_VG = cpago_efec_VG, pago_abono_VG = cpago_abono_VG,
									num_trans_APP = cnum_APP,mto_trans_APP = cmto_APP, comision_APP =  ccomis_APP, pago_efec_APP = cpago_efec_APP, pago_abono_APP = cpago_abono_APP,
									num_trans_remtot = cnum_TOT, mto_trans_remtot = cmto_TOT, comision_remtot =  ccomis_TOT, pago_efectivo_TOT = cpago_efec_TOT, pago_abono_TOT = cpago_abono_TOT
								WHERE CURRENT OF vCursor;
		LET contador2 =contador2+1;
		IF contador2>= 1000 THEN 
			COMMIT WORK;
			BEGIN WORK;
			LET contador2=0;
		END IF;
		

	END FOREACH;
	
	COMMIT WORK;
	
	
--NOMBRE DEL ARCHIVO
	LET cRuta = "/RESPALDOSNEW/"; 
	LET cNombreArchivo = 'repremesascom_' || cAnioMesAct || '.csv';
	
	LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreArchivo) || ' DELIMITER ' || ''',''' || ' SELECT * FROM "informix".sac_reportcom_rem union select '' IDsuc'' id_sucursal,'' nombre_sucursal'','' num_trans_bts'','' mto_trans_bts'','' comision_bts'','' pago_efec_bts'','' pago_abono_bts'','' num_trans_wu'','' mto_trans_wu'','' comision_wu'','' pago_efec_wu'','' pago_abono_wu'','' num_trans_ov'','' mto_trans_ov'','' comision_ov'','' pago_efec_ov'','' pago_abono_ov'','' num_trans_vg'','' mto_trans_vg'','' comision_vg'','' pago_efec_vg'','' pago_abono_vg'','' num_trans_app'','' mto_trans_app'','' comision_app'','' pago_efec_app'','' pago_abono_app'','' num_trans_remtot'','' mto_trans_remtot'','' comision_remtot'','' pago_efectivo_tot'','' pago_abono_tot'' FROM sac_fechas order by id_sucursal asc;" >' || TRIM(cRuta) || 'remesas_comision.sql';
	SYSTEM cSQL;

--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'remesas_comision.sql' ;

	LET cSQL='dbaccess bdisac ' || TRIM(cRuta) || 'remesas_comision.sql';
	SYSTEM cSQL;

--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'remesas_comision.sql';
	SYSTEM cSQL;
	LET cSQL = '';
	
--BORRAMOS TABLAS PARA GENERAR UN NUEVO REPORTE
	DROP TABLE IF EXISTS tmp_folio_suc;
	DROP TABLE IF EXISTS tmp_movimientos;
	DROP TABLE IF EXISTS tmp_cheques;


--INSERTAMOS EL REGISTRO DE LA EJECUCION DEL PROCESO
	INSERT INTO bdisac:"informix".sac_reg_gen_rep_remesas(reporte, fecha_inicio, fecha_fin, status_ejecucion, observacion)
	VALUES (cNombreArchivo, cFechaIni, cFechaFin, cCodRet, cVarError);


	RETURN cNombreArchivo, cCodRet, cVarError;

END;
END PROCEDURE;