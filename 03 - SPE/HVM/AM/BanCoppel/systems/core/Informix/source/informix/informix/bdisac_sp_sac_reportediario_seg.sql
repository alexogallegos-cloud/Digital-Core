CREATE PROCEDURE "informix".sp_sac_reportediario_seg(pfecharepor DATE)

RETURNING CHAR(5), VARCHAR(200), VARCHAR(200), VARCHAR(200);


		--Definicion de Variables
    DEFINE cCodRet          	CHAR(5);
    DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr 			INTEGER;
    DEFINE cInfoErr         	CHAR(100);
	DEFINE cMensaje				VARCHAR(200);
	DEFINE cMensaje2			VARCHAR(200);
	DEFINE cMensaje3			VARCHAR(200);
		
	DEFINE cFecha_proceso 	    DATE;
	DEFINE cNum_meses 	     	INTEGER;
	DEFINE cDiasRespaldos 	    INTEGER;
	DEFINE cImporte_total 	    MONEY;
	DEFINE cComision 	     	MONEY;
	DEFINE cIva 	     		MONEY;
	DEFINE cComisionUnidad 	    MONEY;
	DEFINE cIvaUnidad 	     	MONEY;
	DEFINE cImporte_pago_coppel MONEY;
	DEFINE cConteo  	     	INTEGER;
	DEFINE cConteo2  	     	INTEGER;
	DEFINE cConteoV  	     	INTEGER;
	DEFINE cConteoD 	     	INTEGER;
	
	DEFINE cMeses_vent 			INTEGER;
	DEFINE cImporte_vent 	    MONEY;
	DEFINE cMeses_domi    		INTEGER;
	DEFINE cImporte_domi 		MONEY;
	DEFINE cRutaArch 			CHAR(100);
	DEFINE cStmt 				CHAR (500);
	DEFINE cNumCte          	CHAR(10);
	DEFINE cFecha_cte 			DATE;
	DEFINE cTab 				INTEGER;

	
	--SET DEBUG FILE TO '/informix/HMLG/sp_sac_reportediario_seg.out';
	--TRACE ON; 
	--SET DEBUG FILE TO '/INFORMIXTMP/HMLG/sp_sac_reportediario_seg.out';
	--TRACE ON;
	
	-- Inicializa variables
	LET cCodRet            		= "00000";
	LET cMensaje				= 'PROCESO EXITOSO';
	LET cMensaje2				= '';
	LET cMensaje3				= '';
	LET cFecha_proceso 			= MDY('01','01','1900');
	LET cNum_meses 				= 0;
	LET cImporte_total 			= 0;
	LET cComision 				= 0;
	LET cIva 					= 0;
	LET cComisionUnidad 		= 0;
	LET cIvaUnidad 				= 0;
	LET cImporte_pago_coppel 	= 0;
	LET cConteo 	= 0;
	LET cConteo2 	= 0;
	LET cConteoV 	= 0;
	LET cConteoD 	= 0;
	LET cMeses_vent 	= 0;
	LET cImporte_vent 	= 0;
	LET cMeses_domi 	= 0;
	LET cImporte_domi 	= 0;
	LET cStmt = '';
	LET cRutaArch = '';
	LET cNumCte = '';
	LET cFecha_cte = MDY('01','01','1900');
	LET cTab = '';
	
	--DIAS PARA MIGRACION A PROCESOS HISTORICOS
	LET cDiasRespaldos = 95;

	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envÃÂ­o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sac_reportediario_seg");
				
				DROP TABLE IF EXISTS sac_movimientos_dia_62860;
				DROP TABLE IF EXISTS sac_cons_seg_dia_62860;
				DROP TABLE IF EXISTS sac_abono_seg_dia_62860;
				DROP TABLE IF EXISTS si_plan_proteccion_dia_62860;
				DROP TABLE IF EXISTS reporte_parcial_dia_62860;
				DROP TABLE IF EXISTS reporte_domi_101346;
				
				DROP TABLE IF EXISTS tmp_reportediariovent_seg;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.unl';
				SYSTEM cStmt;
				
				DROP TABLE IF EXISTS tmp_reportediariodomi_seg;
				LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.unl';
				SYSTEM cStmt;
				
				
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP BDD";
				
                RETURN cCodRet,cMensaje,cMensaje2,cMensaje3;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		IF pfecharepor IS NULL OR pfecharepor = '' THEN 
			SELECT fecha_hoy -1
			INTO cFecha_proceso 
			FROM bdisac:sac_fechas
			WHERE empresa = "001";
		ELSE 
			LET cFecha_proceso = pfecharepor ;
		END IF;
		
		SELECT COUNT(*)
		INTO cConteo
		FROM sac_reportediario_seg
		WHERE fecha_proceso = cFecha_proceso
		AND reportesoc = 1;
		
		IF cConteo IS NULL THEN
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			
			UPDATE sac_reportediario_seg SET reportesoc = 0 where fecha_proceso = cFecha_proceso and reportesoc = 1;
			
		END IF;
		
		LET cConteo = 0;
		
		DROP TABLE IF EXISTS sac_movimientos_dia_62860;
		DROP TABLE IF EXISTS sac_cons_seg_dia_62860;
		DROP TABLE IF EXISTS sac_abono_seg_dia_62860;
		DROP TABLE IF EXISTS si_plan_proteccion_dia_62860;
		DROP TABLE IF EXISTS reporte_parcial_dia_62860;
		DROP TABLE IF EXISTS reporte_domi_101346;
		


		SELECT a.*,b.nombre as nom_cajero
			FROM sac_movimientoshistorial a
			LEFT JOIN  bdinteg:si_ejecut b on a.usuario = b.ejecutivo
			WHERE a.fecha_insert >= EXTEND(cFecha_proceso, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND  
			AND a.fecha_insert <= EXTEND(cFecha_proceso, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
			AND a.numcategoria = '01'
			AND a.numconvenio = '002'
			AND a.status_cancelado = 'N'
			AND a.flag_confirmacion_central = 1 
			AND a.flag_confirmacion_sucursal = 1
			INTO TEMP sac_movimientos_dia_62860 WITH NO LOG;
			
			
		SELECT COUNT(*) AS CUENTA 
		INTO cConteoV
		FROM sac_movimientos_dia_62860;
		
		IF cConteoV IS NULL THEN 
			LET cConteoV = 0;
		END IF;
		
		IF cConteoV = 0 then 
			
			--valores unitarios para comision e iva de comision si no hay registros del dia para ventanilla, esto para preparar si hay registros Domiciliacion
			SELECT FIRST 1 a.importe_comision_convenio,a.iva_comision_convenio 
				INTO cComisionUnidad,cIvaUnidad
				FROM sac_movimientoshistorial a
				WHERE a.fecha_insert >= EXTEND(cFecha_proceso-1, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND  
				AND a.fecha_insert <= EXTEND(cFecha_proceso-1, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND a.numcategoria = '01'
				AND a.numconvenio = '002'
				AND a.status_cancelado = 'N'
				AND a.flag_confirmacion_central = 1 
				AND a.flag_confirmacion_sucursal = 1;
			
		END IF;
		
		IF cConteoV <> 0 THEN 
					
			SELECT FIRST 1 importe_comision_convenio,iva_comision_convenio 
			INTO cComisionUnidad,cIvaUnidad
			FROM sac_movimientos_dia_62860;
		
			SELECT DISTINCT numcliente,fecha,costo 
				FROM sac_cons_seg
				WHERE fecha_insert::DATE = cFecha_proceso
				and status = '1'
				INTO TEMP sac_cons_seg_dia_62860 WITH NO LOG;
				
			SELECT DISTINCT numcliente,fecha,importe,mesespagados,recibo 
				FROM sac_abono_seg
				WHERE fecha_insert::DATE = cFecha_proceso
				AND estatus = '1'
				INTO TEMP sac_abono_seg_dia_62860 WITH NO LOG;
			
		
			SELECT DISTINCT a.numcte as numcte1, a.numcte_coppel,lpad(trim(a.numcte_coppel),9,'0') AS numcte ,a.num_poliza,a.fecha_alta,a.fecha_cambio,a.meses_pagar,a.monto_pagar,a.monto_mes,
                a.suc_alta as Sucursal_alta,a.tipo_plan,a.ejecutivo as promotor,b.nombre as nom_promotor 
				FROM bdinteg:si_club_proteccion a
                LEFT JOIN  bdinteg:si_ejecut b on a.ejecutivo = b.ejecutivo
				WHERE a.fecha_cambio =  cFecha_proceso
				AND a.aceptada = '1'
				INTO TEMP si_plan_proteccion_dia_62860 WITH NO LOG;
				
			SELECT a.fecha_pago,a.referencia1,a.importe_pago,a.importe_comision_convenio,a.iva_comision_convenio,
				nvl(nvl(nvl((a.importe_pago/b.costo),cc.mesespagados),e.meses_pagar),1) AS meses, a.id_sucursal as sucursal_pago_ventanilla, a.forma_pago,a.usuario as cajero,a.nom_cajero,
                e.numcte_coppel,e.numcte1,e.num_poliza,e.monto_mes,e.sucursal_alta,e.promotor,e.nom_promotor,e.tipo_plan,e.fecha_alta,e.fecha_cambio
				FROM sac_movimientos_dia_62860 a
				LEFT JOIN sac_cons_seg_dia_62860 b ON  a.referencia1 = b.numcliente and a.importe_pago = b.costo
				LEFT JOIN sac_abono_seg_dia_62860 cc ON  a.referencia1 = cc.numcliente and a.referencia2 = cc.recibo
				LEFT JOIN si_plan_proteccion_dia_62860 e ON a.referencia1 = e.numcte or a.referencia1 = e.numcte_coppel and a.fecha_pago = e.fecha_cambio
				INTO TEMP reporte_parcial_dia_62860 WITH NO LOG;
				
			SELECT SUM(meses) AS num_mesesvent,
				SUM(importe_pago) AS importe_vent
				INTO cMeses_vent,cImporte_vent
				FROM reporte_parcial_dia_62860;
				
			--VALIDACION PARA INSERTAR O NO REGISTROS ENCONTRADOS	
			SELECT COUNT(*) 
			INTO cConteo
			FROM sac_reportediariovent_seg 
			WHERE fecha_pago = cFecha_proceso;
			
			IF cConteo IS NULL THEN 
				LET cConteo = 0;
			END IF;
					
			IF cConteo > 0 THEN 
			
				SELECT COUNT(*) 
				INTO cConteo2
				FROM reporte_parcial_dia_62860; 
			
			
				IF cConteo2 IS NULL THEN 
					LET cConteo2 = 0;
				END IF;
				
				IF cConteo <> cConteo2 THEN
					DELETE FROM sac_reportediariovent_seg WHERE fecha_pago = cFecha_proceso;
					LET cConteo = 1;
				END IF;
			ELSE 
				LET cConteo = 1;
			END IF;
			
			IF cConteo = 1 THEN
			
				DROP TABLE IF EXISTS tmp_reportediariovent_seg;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.unl';
				SYSTEM cStmt;
				
				SELECT * FROM reporte_parcial_dia_62860 
					INTO tmp_reportediariovent_seg;
					
				LET cStmt = 'echo "UNLOAD TO /home/systelmex/reportediariovent_seg.unl SELECT * FROM tmp_reportediariovent_seg;">/home/systelmex/reportediariovent_seg.sql';
				SYSTEM cStmt;
					
				LET cStmt= 'dbaccess bdisac	/home/systelmex/reportediariovent_seg.sql';
				SYSTEM cStmt;
					
				LET cStmt = 'echo "LOAD FROM /home/systelmex/reportediariovent_seg.unl INSERT INTO sac_reportediariovent_seg;">/home/systelmex/reportediariovent_seg_up.sql';
				SYSTEM cStmt;
					
				LET cStmt= 'dbaccess bdisac	/home/systelmex/reportediariovent_seg_up.sql';
				SYSTEM cStmt;
			
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.unl';
				SYSTEM cStmt;
				DROP TABLE IF EXISTS tmp_reportediariovent_seg;
				
			END IF;
			
			LET cConteo = 0;
		ELSE
			
			LET cMeses_vent = 0;
			LET cImporte_vent = 0;
			
		END IF;
				
		/*Domiciliacion*/
		
		SELECT COUNT(*) AS CUENTAD
		INTO cConteoD
		FROM bdinteg:si_club_domiciliacion
		WHERE fecha_hora::DATE = cFecha_proceso;
		
		if cConteoD is null then 
			LET cConteoD = 0;
		end if;
		
		LET cTab = 0;
		
		IF cConteoD = 0 THEN 
			
			LET cConteoD = 0;
			
			SELECT COUNT(*) AS CUENTAD
			INTO cConteoD
			FROM bdinteg:si_club_domiciliacion_hist
			WHERE fecha_hora::DATE = cFecha_proceso;
			
			if cConteoD is null then 
				LET cConteoD = 0;
			end if;
			
			IF cConteoD <> 0 THEN 
				LET cTab = 1;
			END IF;
			
		END IF;
		
		IF cConteoD <> 0 THEN  
			
			DROP TABLE IF EXISTS reporte_domi_101346;	
			
				IF cTab = 0 THEN 
					SELECT a.fecha_hora::date as fecha_pago,
						a.num_cliente,a.imp_importe, cComisionUnidad as importe_comision_convenio,cIvaUnidad as iva_comision_convenio,1 as meses,
						b.numcte_coppel,b.numcte,b.num_poliza,b.monto_mes,b.suc_alta as sucursal_alta,b.ejecutivo as promotor,d.nombre as nom_promotor,
						b.tipo_plan,b.fecha_alta,b.fecha_cambio
						FROM bdinteg:si_club_domiciliacion a 
						LEFT JOIN bdinteg:si_club_proteccion b ON a.num_cliente = b.numcte_coppel AND b.aceptada = 1
						LEFT JOIN  bdinteg:si_ejecut d on b.ejecutivo = d.ejecutivo 
						WHERE to_date(a.fec_paquete, '%Y-%m-%d') = cFecha_proceso
						AND a.procesado = '1'
						INTO TEMP reporte_domi_101346 WITH NO LOG;
				ELSE
					SELECT a.fecha_hora::date as fecha_pago,
						a.num_cliente,a.imp_importe, cComisionUnidad as importe_comision_convenio,cIvaUnidad as iva_comision_convenio,1 as meses,
						b.numcte_coppel,b.numcte,b.num_poliza,b.monto_mes,b.suc_alta as sucursal_alta,b.ejecutivo as promotor,d.nombre as nom_promotor,
						b.tipo_plan,b.fecha_alta,b.fecha_cambio
						FROM bdinteg:si_club_domiciliacion_hist a 
						LEFT JOIN bdinteg:si_club_proteccion b ON a.num_cliente = b.numcte_coppel AND b.aceptada = 1
						LEFT JOIN  bdinteg:si_ejecut d on b.ejecutivo = d.ejecutivo 
						WHERE to_date(a.fec_paquete, '%Y-%m-%d') = cFecha_proceso
						AND a.procesado = '1'
						INTO TEMP reporte_domi_101346 WITH NO LOG;
				END IF;
				
				SELECT SUM (cuentaC) AS cuenta 
				INTO cConteo
				FROM(SELECT  COUNT(*) AS cuentaC
						FROM reporte_domi_101346
						GROUP BY num_cliente
						HAVING COUNT(*) >= 2);			
				
				/*
				SELECT count(*) AS cuenta
					into cConteo
					FROM reporte_domi_101346
					group by num_cliente
					having count(*) >= 2;
				*/
					if cConteo is null then 
						LET cConteo = 0;
					end if;
				
				IF cConteo > 0 THEN 
					FOREACH
					
						SELECT num_cliente
							INTO cNumCte
							FROM reporte_domi_101346
							GROUP BY num_cliente
							HAVING COUNT(*) >= 2
						

							SELECT MAX(fecha_cambio) AS fh
								INTO cFecha_cte						
								FROM reporte_domi_101346 
								WHERE num_cliente = cNumCte;

							DELETE FROM reporte_domi_101346 WHERE num_cliente = cNumCte AND  fecha_cambio <> cFecha_cte;
							
							LET cNumCte = '';
							LET cFecha_cte = MDY('01','01','1900');
						
					END FOREACH;
				END IF;	
				
				SELECT SUM(meses) AS num_mesesdomi,
					SUM(imp_importe::MONEY) AS importe_domi
					INTO cMeses_domi,cImporte_domi
					FROM reporte_domi_101346;
					--WHERE numcte_coppel IS NOT NULL;
					
				LET cConteo = 0;
				LET cConteo2 = 0;
				
				--VALIDACION PARA INSERTAR O NO REGISTROS ENCONTRADOS	
				SELECT COUNT(*) 
					INTO cConteo
					FROM sac_reportediariodomi_seg 
					WHERE fecha_pago = cFecha_proceso;
			
				IF cConteo IS NULL THEN 
					LET cConteo = 0;
				END IF;
					
				IF cConteo > 0 THEN 
			
					SELECT COUNT(*) 
					INTO cConteo2
					FROM reporte_domi_101346; 
			
					IF cConteo2 IS NULL THEN 
						LET cConteo2 = 0;
					END IF;
				
					IF cConteo <> cConteo2 THEN
						DELETE FROM sac_reportediariodomi_seg WHERE fecha_pago = cFecha_proceso;
						LET cConteo = 1;
					END IF;
				ELSE 
					LET cConteo = 1;
				END IF;
					
				IF 	cConteo = 1 THEN
				
					DROP TABLE IF EXISTS tmp_reportediariodomi_seg;
					LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg_up.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.unl';
					SYSTEM cStmt;
					
					
					SELECT * FROM reporte_domi_101346 
					INTO tmp_reportediariodomi_seg;
					
					LET cStmt = 'echo "UNLOAD TO /home/systelmex/reportediariodomi_seg.unl SELECT * FROM tmp_reportediariodomi_seg;">/home/systelmex/reportediariodomi_seg.sql';
					SYSTEM cStmt;
					
					LET cStmt= 'dbaccess bdisac	/home/systelmex/reportediariodomi_seg.sql';
					SYSTEM cStmt;
					
					LET cStmt = 'echo "LOAD FROM /home/systelmex/reportediariodomi_seg.unl INSERT INTO sac_reportediariodomi_seg;">/home/systelmex/reportediariodomi_seg_up.sql';
					SYSTEM cStmt;
					
					LET cStmt= 'dbaccess bdisac	/home/systelmex/reportediariodomi_seg_up.sql';
					SYSTEM cStmt;
			
					LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg_up.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.unl';
					SYSTEM cStmt;
					DROP TABLE IF EXISTS tmp_reportediariodomi_seg;
					
			END IF;
		ELSE
		
			LET cMeses_domi = 0;
			LET cImporte_domi = 0;
			
		END IF;		
				
		/*Fin Domiciliacion*/
				
		LET cConteo = 0;
		
		LET cConteo = cConteoV + cConteoD;
		
		IF cConteo <> 0 THEN 
				
				LET cNum_meses = cMeses_vent + cMeses_domi;
				LET cImporte_total = cImporte_vent + cImporte_domi;
				
				LET cComision = cNum_meses * cComisionUnidad;
				LET cIva = cNum_meses * cIvaUnidad;
				LET cImporte_pago_coppel = (cImporte_total - (cComision + cIva ));
	
				LET cCodRet = "00000";				
				LET cMensaje =  "Proceso Exitoso|";
				LET cMensaje2 = 'FECHA_PROCESO|NUM_MESES|IMP_TOTAL|COMISION|IVA|PAGO_COPPEL|';
				LET cMensaje3 =  cFecha_proceso||"|"||cNum_meses||"|"||cImporte_total||"|"||cComision||"|"||cIva||"|"||cImporte_pago_coppel||"|";
				
				INSERT INTO sac_reportediario_seg (fecha_proceso,num_meses,importe_total,comision,iva,importe_pago_coppel,fecha_insert,codret,mensajeret,num_mesesvent,importe_vent,num_mesesdomi,importe_domi,reportesoc) VALUES (cFecha_proceso,cNum_meses,cImporte_total,cComision,cIva,cImporte_pago_coppel,CURRENT,cCodRet,TRIM(cMensaje)||'|'||TRIM(cMensaje3),cMeses_vent,cImporte_vent,cMeses_domi,cImporte_domi,1);
				
				DROP TABLE IF EXISTS sac_movimientos_dia_62860;
				DROP TABLE IF EXISTS sac_cons_seg_dia_62860;
				DROP TABLE IF EXISTS sac_abono_seg_dia_62860;
				DROP TABLE IF EXISTS si_plan_proteccion_dia_62860;
				DROP TABLE IF EXISTS reporte_parcial_dia_62860;
				DROP TABLE IF EXISTS reporte_domi_101346;
				
	
				INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
					VALUES ('SAC_REPORTEDIARIO_SEG',today,'1','informix',CURRENT,'1','sp_sac_reportediario_seg','Reporte Diario de totales de Club de Proteccion Meses');
				
		ELSE
		
				LET cCodRet = "00001";				
				LET cMensaje =  "Proceso Sin Datos|";
				LET cMensaje2 = 'FECHA_PROCESO|NUM_MESES|IMP_TOTAL|COMISION|IVA|PAGO_COPPEL|';
				LET cMensaje3 = cFecha_proceso||"|"||0||"|"||0||"|"||0||"|"||0||"|"||0||"|";
				
				
				INSERT INTO sac_reportediario_seg (fecha_proceso,num_meses,importe_total,comision,iva,importe_pago_coppel,fecha_insert,codret,mensajeret,num_mesesvent,importe_vent,num_mesesdomi,importe_domi,reportesoc) VALUES (cFecha_proceso,0,0,0,0,0,CURRENT,cCodRet,TRIM(cMensaje)||'|'||TRIM(cMensaje3),0,0,0,0,1);
				
				INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
					VALUES ('SAC_REPORTEDIARIO_SEG',today,'0','informix',CURRENT,'1','sp_sac_reportediario_seg','Reporte Diario de totales de Club de Proteccion Meses Sin Datos');
					
				DROP TABLE IF EXISTS sac_movimientos_dia_62860;
				DROP TABLE IF EXISTS reporte_domi_101346;
		
		END IF;
		
		
		--RESPALDOS HISTORICOS VENTANILLA
		LET cConteo = 0;
		
		
		SELECT count(*)
		INTO cConteo
		FROM sac_reportediariovent_seg 
		WHERE fecha_pago <= cFecha_proceso - cDiasRespaldos;
		
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			DROP TABLE IF EXISTS tmp_reportediariovent_seg;
			LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.unl';
			SYSTEM cStmt;
				
			SELECT * FROM sac_reportediariovent_seg 
				WHERE fecha_pago <= cFecha_proceso - cDiasRespaldos
				INTO tmp_reportediariovent_seg;
					
				LET cStmt = 'echo "UNLOAD TO /home/systelmex/reportediariovent_seg.unl SELECT * FROM tmp_reportediariovent_seg;">/home/systelmex/reportediariovent_seg.sql';
				SYSTEM cStmt;
					
				LET cStmt= 'dbaccess bdisac	/home/systelmex/reportediariovent_seg.sql';
				SYSTEM cStmt;
					
				LET cStmt = 'echo "LOAD FROM /home/systelmex/reportediariovent_seg.unl INSERT INTO sac_reportediarioventhis_seg;">/home/systelmex/reportediariovent_seg_up.sql';
				SYSTEM cStmt;
					
				LET cStmt= 'dbaccess bdisac	/home/systelmex/reportediariovent_seg_up.sql';
				SYSTEM cStmt;
			
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg_up.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reportediariovent_seg.unl';
				SYSTEM cStmt;
				DROP TABLE IF EXISTS tmp_reportediariovent_seg;
				
				
				DELETE FROM sac_reportediariovent_seg WHERE fecha_pago <= cFecha_proceso - cDiasRespaldos;
		END IF;
		
		--RESPALDOS HISTORICOS DOMICILIACION
		LET cConteo = 0;
		
		
		SELECT count(*)
		INTO cConteo
		FROM sac_reportediariodomi_seg 
		WHERE fecha_pago <= cFecha_proceso - cDiasRespaldos;
		
		
		IF cConteo IS NULL THEN 
			LET cConteo = 0;
		END IF;
		
		IF cConteo <> 0 THEN 
			
			
			DROP TABLE IF EXISTS tmp_reportediariodomi_seg;
			LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.unl';
			SYSTEM cStmt;
			
			
			SELECT * FROM sac_reportediariodomi_seg 
			WHERE fecha_pago <= cFecha_proceso - cDiasRespaldos
			INTO tmp_reportediariodomi_seg;
			
			LET cStmt = 'echo "UNLOAD TO /home/systelmex/reportediariodomi_seg.unl SELECT * FROM tmp_reportediariodomi_seg;">/home/systelmex/reportediariodomi_seg.sql';
			SYSTEM cStmt;
			
			LET cStmt= 'dbaccess bdisac	/home/systelmex/reportediariodomi_seg.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'echo "LOAD FROM /home/systelmex/reportediariodomi_seg.unl INSERT INTO sac_reportediariodomihis_seg;">/home/systelmex/reportediariodomi_seg_up.sql';
			SYSTEM cStmt;
			
			LET cStmt= 'dbaccess bdisac	/home/systelmex/reportediariodomi_seg_up.sql';
			SYSTEM cStmt;
			
			LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg_up.sql';
			SYSTEM cStmt;
			LET cStmt = 'rm -f /home/systelmex/reportediariodomi_seg.unl';
			SYSTEM cStmt;
			DROP TABLE IF EXISTS tmp_reportediariodomi_seg;
				
			DELETE FROM sac_reportediariodomi_seg WHERE fecha_pago <= cFecha_proceso - cDiasRespaldos;
			
		END IF;
		
	RETURN cCodRet,cMensaje,cMensaje2,cMensaje3;
		
	END;
END PROCEDURE;