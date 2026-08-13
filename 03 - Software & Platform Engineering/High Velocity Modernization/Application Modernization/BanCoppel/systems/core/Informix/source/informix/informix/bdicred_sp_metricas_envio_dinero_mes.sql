CREATE PROCEDURE  "informix".sp_metricas_envio_dinero_mes (pfecharepor DATE)

RETURNING CHAR(5) AS iCodRet, char(50) as iMensaje;
	--GENERAR REPOTE DE METRICAS DE ENVIOS DE DINERO REMESAS Y ENROLAMIENTO--
	
	DEFINE iCodRet 			CHAR(5);
	DEFINE iMensaje			CHAR(50);
	DEFINE cRutaArch 		CHAR(100);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cDia 			CHAR(2);
	DEFINE cMes 			CHAR(2);
	DEFINE cAnio 			CHAR(4);
	DEFINE dFecha_Hoy 		DATE;
	DEFINE cStmt 			CHAR (500);
	DEFINE vValida			INTEGER;
	
	

	DEFINE vfecha_proceso			DATE;
	DEFINE vfecha_procesoI			DATE;
	DEFINE vfecha_procesoF			DATE;
	DEFINE vtipo_remesa				CHAR(3); 
	DEFINE vabono_cuenta			CHAR(2);
	DEFINE vmonto_total				MONEY;
	DEFINE vmonto_dolares			MONEY;
	DEFINE vbeneficiario_nombre1	CHAR(30);
	DEFINE vbeneficiario_nombre2	CHAR(30); 
	DEFINE vbeneficiario_appaterno	CHAR(30);
	DEFINE vbeneficiario_apmaterno	CHAR(30);
	DEFINE vbeneficiario_fecha_nac	DATE;
	DEFINE vbeneficiario_estado		CHAR(50);
	DEFINE vbeneficiario_mncpo_del	CHAR(50);
	DEFINE vbeneficiario_ciudad		CHAR(50);
	DEFINE vbeneficiario_direccion	CHAR(100);
	DEFINE vbeneficiario_colonia	CHAR(80);
	DEFINE vbeneficiario_calle 		CHAR(50);
	DEFINE vsucursal				CHAR(4);
	DEFINE vnum_confirmacion		CHAR(20);
	DEFINE vfolio_sucursal			CHAR(16);
	DEFINE vnumCliente				CHAR(20);
	DEFINE vNombreBenef				CHAR(300);
	
	
	DEFINE vnombre_estado			CHAR(30);
	--DEFINE vsucursal				CHAR(4); 
	DEFINE vtotal_enrolados			INTEGER;
	DEFINE vtotal_penrolados		INTEGER;
	DEFINE vtotal_t1				INTEGER;
	DEFINE vtotal_t2				INTEGER;
	DEFINE vtotal_pt1				INTEGER;
	DEFINE vtotal_pt2				INTEGER;
	DEFINE vtusuarios_enrolados 	INTEGER;
	DEFINE vtusuarios_no_enrolados 	INTEGER;
	DEFINE vPromedio			 	DECIMAL;
	
	
    --SET DEBUG FILE TO '/DBA/JULIO/sp_metricas_envio_dinero.out';
    --TRACE ON; 
	--SET DEBUG FILE TO '/INFORMIXTMP/HMLG/sp_metricas_envio_dinero.out';
	--TRACE ON;
	
	LET vfecha_proceso			= MDY('01','01','1900');
	LET vfecha_procesoF			= MDY('01','01','1900');
	LET vfecha_procesoI			= MDY('01','01','1900');	
	LET iCodRet = "00000";
	LET cRutaArch = '';
	LET iSqlErr = 0;
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET dFecha_Hoy = MDY('01','01','1900');
	LET cStmt = '';
	LET iMensaje = '';
	LET vValida = 0;
	

	LET vtipo_remesa			= '';	
	LET vabono_cuenta			= '';
	LET vmonto_total			= 0;	
	LET vmonto_dolares			= 0;
	LET vbeneficiario_nombre1	= '';
	LET vbeneficiario_nombre2	= '';
	LET vbeneficiario_appaterno	= '';
	LET vbeneficiario_apmaterno	= '';
	LET vbeneficiario_fecha_nac	= MDY('01','01','1900');
	LET vbeneficiario_estado	= '';	
	LET vbeneficiario_mncpo_del	= '';
	LET vbeneficiario_ciudad	= '';	
	LET vbeneficiario_direccion	= '';
	LET vbeneficiario_colonia	= '';
	LET vbeneficiario_calle 	= '';	
	LET vsucursal				= '';
	LET vnum_confirmacion		= '';
	LET vfolio_sucursal			= '';
	LET vnumCliente				= '';
	LET vNombreBenef			= '';	
	
		
	LET vnombre_estado 			= '';						
	LET vtotal_enrolados		= 0;			
	LET vtotal_penrolados		= 0;		
	LET vtotal_t1				= 0;			
	LET vtotal_t2				= 0;			
	LET vtotal_pt1				= 0;			
	LET vtotal_pt2				= 0;			
	LET vtusuarios_enrolados 	= 0;	
	LET vtusuarios_no_enrolados	= 0; 	
	LET vPromedio				= 0.00;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			LET iMensaje = "Proceso NO Exitoso Error BD.";
			
			
			IF cRutaArch IS NOT NULL OR cRutaArch <> "" THEN 
				LET cStmt = 'rm -f ' || cRutaArch;
				SYSTEM cStmt;
			END IF;
			
			drop table if exists tempsuc_pivMovHis1;
			
			DROP TABLE IF EXISTS tempsuc_edo;
			DROP TABLE IF EXISTS tempsuc_periodo;
			DROP TABLE IF EXISTS temptipoctee;
			DROP TABLE IF EXISTS temptipocte1;
			DROP TABLE IF EXISTS temptipocte2;
			DROP TABLE IF EXISTS temptipocte11;
			DROP TABLE IF EXISTS temptipocte22;
			DROP TABLE IF EXISTS tempsuc1;
			DROP TABLE IF EXISTS temp_wu_enrol;
			DROP TABLE IF EXISTS temp_wu_noenrol;
			DROP TABLE IF EXISTS temp_app_enrol;
			DROP TABLE IF EXISTS temp_app_noenrol;
			DROP TABLE IF EXISTS temp_bts_enrol;
			DROP TABLE IF EXISTS temp_bts_noenrol;
			DROP TABLE IF EXISTS tempsuc_piv;
			DROP TABLE IF EXISTS tempsuc_pivMovHis;
			DROP TABLE IF EXISTS tempsuc_edo_t1t2;
			DROP TABLE IF EXISTS temp_totalrempag;
			DROP TABLE IF EXISTS temp_reporteenrolamiento58;
			DROP TABLE IF EXISTS tempsuc_periodot;
			
			
			RETURN iCodRet,iMensaje;
			
		END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
			drop table if exists tempsuc_pivMovHis1;
			DROP TABLE IF EXISTS tempsuc_edo;
			DROP TABLE IF EXISTS tempsuc_periodo;
			DROP TABLE IF EXISTS temptipoctee;
			DROP TABLE IF EXISTS temptipocte1;
			DROP TABLE IF EXISTS temptipocte2;
			DROP TABLE IF EXISTS temptipocte11;
			DROP TABLE IF EXISTS temptipocte22;
			DROP TABLE IF EXISTS tempsuc1;
			DROP TABLE IF EXISTS temp_wu_enrol;
			DROP TABLE IF EXISTS temp_wu_noenrol;
			DROP TABLE IF EXISTS temp_app_enrol;
			DROP TABLE IF EXISTS temp_app_noenrol;
			DROP TABLE IF EXISTS temp_bts_enrol;
			DROP TABLE IF EXISTS temp_bts_noenrol;
			DROP TABLE IF EXISTS tempsuc_piv;
			DROP TABLE IF EXISTS tempsuc_pivMovHis;
			DROP TABLE IF EXISTS tempsuc_edo_t1t2;
			DROP TABLE IF EXISTS temp_totalrempag;
			DROP TABLE IF EXISTS temp_reporteenrolamiento58;
			DROP TABLE IF EXISTS tempsuc_periodot;
		
		
		IF pfecharepor IS NULL OR  pfecharepor = "" THEN
		
			SELECT fecha_hoy 
			INTO dFecha_Hoy 
			FROM bdisac:sac_fechas
			WHERE empresa = "001";
		
			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
		
			LET vfecha_proceso			= dFecha_Hoy;
			LET dFecha_Hoy 				= vfecha_proceso -36;
			
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM sac_movimientoshistorial 
				WHERE fecha_insert >= EXTEND(dFecha_Hoy, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
				AND fecha_insert <= EXTEND(vfecha_proceso, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis1  WITH NO LOG;
			
			
			SELECT FIRST 1 MIN(fecha_insert),MAX(fecha_insert)
				INTO vfecha_procesoI,vfecha_procesoF
				FROM tempsuc_pivMovHis1
				WHERE MONTH(fecha_insert) = MONTH(vfecha_proceso)-1;
				
		ELSE 
		
			LET vfecha_proceso			= pfecharepor;
			LET dFecha_Hoy 				= vfecha_proceso -36;
			
			LET cDia = LPAD(DAY(vfecha_proceso::DATE), 2, '0');
			LET cMEs = LPAD(MONTH(vfecha_proceso::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(vfecha_proceso::DATE), 4, '0');
			
			
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM sac_movimientoshistorial 
				WHERE fecha_insert >= EXTEND(dFecha_Hoy, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
				AND fecha_insert <= EXTEND(vfecha_proceso, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis1  WITH NO LOG;
			
			SELECT FIRST 1 MIN(fecha_insert),MAX(fecha_insert)
				INTO vfecha_procesoI,vfecha_procesoF
				FROM tempsuc_pivMovHis1
				WHERE MONTH(fecha_insert) = MONTH(vfecha_proceso)-1;

		END IF;
				
		
		IF vfecha_procesoI IS NOT NULL OR vfecha_procesoF IS NOT NULL THEN 
				
			--"METRICAS DE ENVIOS DE DINERO REPORTE 2 MENSUAL"
			
			
			--01 Genera tabla Pivote con sucursales que pagaron remesas
				
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM tempsuc_pivMovHis1 
				WHERE fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                AND fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis  WITH NO LOG;
			
			drop table if exists tempsuc_pivMovHis1;
			
			SELECT  id_sucursal as sucursal
				FROM tempsuc_pivMovHis 
				WHERE numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764') 
				AND status_cancelado = 'N'
				GROUP BY id_sucursal
			INTO TEMP tempsuc_piv  WITH NO LOG;
			
			--02 Totales de ususarios enrolados por sucursal de tabla pivote 
			SELECT b.cve_estado,d.nombre AS nombre_estado,a.sucursal
				FROM tempsuc_piv a
				LEFT JOIN bdinteg:si_ptf b on a.sucursal = b.id_ptf and b.tipo in ('S','O')
				LEFT JOIN bdinteg:si_estados d ON b.cve_pais = d.pais
				AND b.cve_estado = d.estado
				GROUP BY a.sucursal, b.cve_estado,d.nombre
			INTO TEMP tempsuc_edo  WITH NO LOG;
			
			--03 Total de enrolados y por periodo del reporte
			SELECT sucursal,NVL(count(*),0) as total_enrolados 
				FROM sac_cte_remesas  /*fechas para totales*/
				WHERE fecha_alta >= vfecha_procesoI
				AND fecha_alta <= vfecha_procesoF
				GROUP BY sucursal
			INTO TEMP tempsuc_periodot  WITH NO LOG; 
			
			SELECT sucursal,NVL(count(*),0) as totale_periodo 
				FROM sac_cte_remesas
				WHERE fecha_alta >= vfecha_procesoI
				AND fecha_alta <= vfecha_procesoF
				GROUP BY sucursal
			INTO TEMP tempsuc_periodo  WITH NO LOG; 
			
			
			--04 Junta tablas temporales tempsuc_edo y tempsuc_periodo
			SELECT a.cve_estado,a.nombre_estado,a.sucursal,NVL(cc.total_enrolados,0) as total_enrolados,NVL(b.totale_periodo,0) AS total_penrolados  
				FROM tempsuc_edo a
				LEFT JOIN tempsuc_periodo b ON a.sucursal = b.sucursal
				LEFT JOIN tempsuc_periodot cc ON a.sucursal = cc.sucursal
			INTO TEMP tempsuc1  WITH NO LOG;
			
			DROP TABLE IF EXISTS tempsuc_edo;
			DROP TABLE IF EXISTS tempsuc_periodo;
			DROP TABLE IF EXISTS tempsuc_periodot;
			
			--05 Busqueda del tipo de cliente de cada enrolado *****
			SELECT a.sucursal,a.numcte,a.fecha_alta,b.tipo_cliente
				FROM bdisac:sac_cte_remesas a
				LEFT JOIN bdinteg:si_cliente b ON a.numcte = b.numcte /*fechas para totales*/
				WHERE a.fecha_alta >= vfecha_procesoI
				AND a.fecha_alta <= vfecha_procesoF
			INTO TEMP temptipoctee  WITH NO LOG;
			
			--06 genera tablas con totales por el tipo de cliente 
			SELECT sucursal,NVL(count(*),0) AS total_ct1
				FROM temptipoctee
				WHERE tipo_cliente = 1
				GROUP BY sucursal 
			INTO TEMP temptipocte1  WITH NO LOG;
				
			SELECT sucursal,NVL(count(*),0) AS total_ct2
				FROM temptipoctee
				WHERE tipo_cliente = 2
				GROUP BY sucursal 
			INTO TEMP temptipocte2  WITH NO LOG;
				
			SELECT sucursal,NVL(count(*),0) AS total_ct1p
				FROM temptipoctee
				WHERE tipo_cliente = 1
				AND fecha_alta >= vfecha_procesoI
				AND fecha_alta <= vfecha_procesoF
				GROUP BY sucursal 
			INTO TEMP temptipocte11  WITH NO LOG;
				
			SELECT sucursal,NVL(count(*),0) AS total_ct2p
				FROM temptipoctee
				WHERE tipo_cliente = 2
				AND fecha_alta >= vfecha_procesoI
				AND fecha_alta <= vfecha_procesoF
				GROUP BY sucursal 
			INTO TEMP temptipocte22  WITH NO LOG;
			
			
			DROP TABLE IF EXISTS temptipoctee;
			
			
			--6 Junta tablas temporales a 1 reporte
			SELECT a.cve_estado,a.nombre_estado,a.sucursal,a.total_enrolados,
				a.total_penrolados,
				NVL(total_ct1,0)AS  total_t1,
				NVL(total_ct2,0)AS total_t2,
				NVL(total_ct1p,0)AS total_pt1,
				NVL(total_ct2p,0)AS total_pt2
				FROM tempsuc1 a
				LEFT JOIN temptipocte1 d ON a.sucursal = d.sucursal
				LEFT JOIN temptipocte2 e ON a.sucursal = e.sucursal
				LEFT JOIN temptipocte11 f ON a.sucursal = f.sucursal
				LEFT JOIN temptipocte22 h ON a.sucursal = h.sucursal
			INTO TEMP tempsuc_edo_t1t2  WITH NO LOG;
			
			DROP TABLE IF EXISTS temptipocte1;
			DROP TABLE IF EXISTS temptipocte2;
			DROP TABLE IF EXISTS temptipocte11;
			DROP TABLE IF EXISTS temptipocte22;
			DROP TABLE IF EXISTS tempsuc1;
			
			--7 BUSQUEDA DE TOTALES POR REMESADORA 
			
				--7.1 BUSQEDA PARA WU
				
					SELECT a.id_sucursal,count(unique(a.referencia1)) as TotalWU_usuenrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_wu_pay w ON a.referencia1 = w.mtcn
						AND a.folio_suc = w.foreign_rs_refnum_rp
						WHERE a.numcategoria = '07'
						AND a.numconvenio IN ('006','007','008')
                        and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND w.numcte <> ''
                        and w.conf_pago = 'P'
                        and w.txn_status = 'A' 
                        and w.retcode = '00000'
						GROUP BY a.id_sucursal
                       INTO TEMP temp_wu_enrol  WITH NO LOG;
					
					SELECT a.id_sucursal,count(unique(a.referencia1)) as TotalWU_usu_no_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_wu_pay w ON a.referencia1 = w.mtcn
						AND a.folio_suc = w.foreign_rs_refnum_rp
						WHERE a.numcategoria = '07'
						AND a.numconvenio IN ('006','007','008')
						and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND w.numcte = ''
                        and w.conf_pago = 'P'
                        and w.txn_status = 'A' 
                        and w.retcode = '00000'
						GROUP BY a.id_sucursal
                       INTO TEMP temp_wu_noenrol  WITH NO LOG;					
			
				--7.2 BUSQUEDA PARA APPRIZA
				
					SELECT trim(ap.nnumber) as sucursal,count(unique(ap.unirefnum)) as TotalAPP_usu_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_app_payi ap ON a.referencia1 = ap.unirefnum
						AND a.folio_suc = ap.refnum
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '009'
                        and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND 
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND ap.numcte <> ''
                        and ap.txn_status = 'A'
                        and ap.r_code_d = 'P000' 
                        and ap.r_code = '0000'
						GROUP BY ap.nnumber
                    INTO TEMP temp_app_enrol   WITH NO LOG;
					
					SELECT trim(ap.nnumber) as sucursal,count(unique(ap.unirefnum)) as TotalAPP_usu_no_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_app_payi ap ON a.referencia1 = ap.unirefnum
						AND a.folio_suc = ap.refnum
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '009'
                        and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND 
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND  
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND ap.numcte = ''
                        and ap.txn_status = 'A'
                        and ap.r_code_d = 'P000' 
                        and ap.r_code = '0000'
						GROUP BY ap.nnumber
                    INTO TEMP temp_app_noenrol   WITH NO LOG;


				--7.3 BUSQUEDA PARA BTS

					SELECT a.id_sucursal as sucursal,count(unique(bt.confirmation_nm)) as TotalBTS_usu_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_bts_payi bt ON a.referencia1 = bt.confirmation_nm
						AND a.folio_suc = bt.bank_ref_nm
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '004'
						and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND 
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
                        AND bt.numcte <> ''
						AND bt.opcode = '1100'
						AND bt.txn_status = 'A'
						GROUP BY a.id_sucursal
                    INTO TEMP temp_bts_enrol   WITH NO LOG;
					
					SELECT a.id_sucursal as sucursal,count(unique(bt.confirmation_nm)) as TotalBTS_usu_no_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_bts_payi bt ON a.referencia1 = bt.confirmation_nm
						AND a.folio_suc = bt.bank_ref_nm
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '004'
						and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
                        AND bt.numcte = ''
						AND bt.opcode = '1100'
						AND bt.txn_status = 'A'
						GROUP BY a.id_sucursal
                    INTO TEMP temp_bts_noenrol   WITH NO LOG;


					
				--7.4 Union de resultados
				
					SELECT a.sucursal,
						(NVL(app1.totalapp_usu_enrol,0) + NVL(bts1.totalbts_usu_enrol,0) + NVL(wu1.totalwu_usuenrol,0)) as tusuarios_enrolados,
						(NVL(app2.totalapp_usu_no_enrol,0) + NVL(bts2.totalbts_usu_no_enrol,0) + NVL(wu2.totalwu_usu_no_enrol,0)) as tusuarios_no_enrolados
						FROM tempsuc_piv a
						LEFT JOIN temp_app_enrol app1 ON a.sucursal = app1.sucursal
						LEFT JOIN temp_bts_enrol bts1 ON a.sucursal = bts1.sucursal
						LEFT JOIN temp_wu_enrol wu1 ON a.sucursal = wu1.id_sucursal
						LEFT JOIN temp_app_noenrol app2 ON a.sucursal = app2.sucursal
						LEFT JOIN temp_bts_noenrol bts2 ON a.sucursal = bts2.sucursal
						LEFT JOIN temp_wu_noenrol wu2 ON a.sucursal = wu2.id_sucursal
					INTO TEMP temp_totalrempag  WITH NO LOG;
					
					DROP TABLE IF EXISTS temp_wu_enrol;
					DROP TABLE IF EXISTS temp_wu_noenrol;
					DROP TABLE IF EXISTS temp_app_enrol;
					DROP TABLE IF EXISTS temp_app_noenrol;
					DROP TABLE IF EXISTS temp_bts_enrol;
					DROP TABLE IF EXISTS temp_bts_noenrol;
					
			--8 GENERA REPORTE 

				SELECT a.nombre_estado,a.sucursal,
				a.total_penrolados,
				a.total_pt1,a.total_pt2,
				b.tusuarios_enrolados,b.tusuarios_no_enrolados,999.99 as promedio
				FROM tempsuc_edo_t1t2 a
				LEFT JOIN temp_totalrempag b ON a.sucursal = b.sucursal
				INTO temp_reporteenrolamiento58;
			
				DROP TABLE IF EXISTS tempsuc_piv;
				DROP TABLE IF EXISTS tempsuc_pivMovHis;
				DROP TABLE IF EXISTS tempsuc_edo_t1t2;
				DROP TABLE IF EXISTS temp_totalrempag;
				
				SELECT COUNT(*) 
				INTO vValida
				FROM temp_reporteenrolamiento58;
				
				
				IF vValida <> 0  THEN
					
				
					LET cRutaArch = '/home/systelmex/metricas_envio_dinero_2_mes_DDMMAAAA.csv';
			
					LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
					LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
					LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);

					LET cStmt = 'rm -f ' || cRutaArch;
					SYSTEM cStmt;			
										
					LET cStmt = 'echo "' || "METRICAS DE ENVIOS DE DINERO REPORTE 2 MENSUAL " || vfecha_procesoI ||" - "|| vfecha_procesoF || '" >> ' || cRutaArch;
					SYSTEM cStmt; 
			
					LET cStmt = 'echo "' || "ESTADO" || "," ||"SUCURSAL" || "," || "CLIENTES ENROLADOS PERIODO" || "," || "CLIENTES ENROLADOS T1 PERIODO" || "," || "CLIENTES ENROLADOS T2 PERIODO" || "," || 
						"TOTAL TRANSACCIONES USUARIO ENROLADO PERIODO" || "," || "TOTAL TRANSACCIONES USUARIO NO ENROLADO PERIODO" || "," || "PROMEDIO USUARIO ENROLADO PERIODO" || '" >> ' || cRutaArch;
						SYSTEM cStmt;
				
					FOREACH
					
						SELECT  sucursal,total_penrolados,tusuarios_enrolados
						INTO vsucursal,vtotal_enrolados,vtusuarios_enrolados
						FROM temp_reporteenrolamiento58
						
						
						
						IF vtusuarios_enrolados <> 0  THEN
							IF vtotal_enrolados <> 0 THEN
								LET vPromedio = ROUND((ROUND(vtusuarios_enrolados,2)/ROUND(vtotal_enrolados,2)),2);
								UPDATE temp_reporteenrolamiento58 SET promedio = vPromedio WHERE sucursal = vsucursal;
							ELSE
								UPDATE temp_reporteenrolamiento58 SET promedio = 0 WHERE sucursal = vsucursal;
							END IF;
						ELSE
							UPDATE temp_reporteenrolamiento58 SET promedio = 0 WHERE sucursal = vsucursal;
						END IF;
						
						
					END FOREACH;
					
					LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinerom_2.csv';
					SYSTEM cStmt;
					
					LET cStmt = 'echo "UNLOAD TO /home/systelmex/metricas_envio_dinerom_2.csv DELIMITER '','' SELECT * FROM temp_reporteenrolamiento58 ORDER BY 1,2;">/home/systelmex/reportemetenrm2.sql';
					SYSTEM cStmt;
				
					let cStmt= 'dbaccess bdisac	/home/systelmex/reportemetenrm2.sql';
					system cStmt;
					
					SYSTEM 'tail -n +1 /home/systelmex/metricas_envio_dinerom_2.csv >> ' || cRutaArch;
					
					LET cStmt = 'rm -f /home/systelmex/reportemetenrm2.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinerom_2.csv';
					SYSTEM cStmt;
					
					DROP TABLE IF EXISTS temp_reporteenrolamiento58;
					LET iCodRet = "00000";				
					LET iMensaje =  "Proceso Exitoso 2 Mensual";
					
					
					INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_2m',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero_mensual','Reporte Metricas de Envio de Dinero y Enrolamiento 2 mensual');
	
				
				ELSE
					LET cStmt = 'rm -f ' || cRutaArch;
					SYSTEM cStmt;
				
					LET iCodRet = "00000";				
					LET iMensaje =  "Proceso Exitoso 2 mensual  Sin Datos";
					INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_2m',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero_mensual','Reporte Metricas de Envio de Dinero y Enrolamiento 2 mensual');
				END IF;
					
		ELSE
			
			LET iCodRet = "00001";				
			LET iMensaje =  "Proceso NO Exitoso";
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('REP_MET_ENV_DIN_ENROL_2m',today,'0','informix',CURRENT,'1','sp_metricas_envio_dinero_mensual','Reporte Metricas de Envio de Dinero y Enrolamiento 2 mensual');
		
		END IF;
		
		
		RETURN iCodRet,iMensaje;
		
	END;

END PROCEDURE;