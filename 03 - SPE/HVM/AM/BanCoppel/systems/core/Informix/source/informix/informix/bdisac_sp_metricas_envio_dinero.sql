CREATE PROCEDURE  "informix".sp_metricas_envio_dinero(pNumRep CHAR(1),pfecharepor DATE,pDiasProceso INTEGER)

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
	 
	DEFINE pld INTEGER;
  
	DEFINE Nfecha_proceso              DATE;   
	DEFINE Ntipo_remesa                CHAR(20);   
	DEFINE Nabono_cuenta               CHAR(50);
	DEFINE Nmonto_total                MONEY;   
	DEFINE Nmonto_dolares              MONEY;   
	DEFINE Nbeneficiario_nombre        CHAR(100);   
	DEFINE Nbeneficiario_fecha_nac     DATE;   
	DEFINE Nbeneficiario_estado        CHAR(100);   
	DEFINE Nbeneficiario_mncpo_del     CHAR(100);   
	DEFINE Nbeneficiario_ciudad	       CHAR(100);
	DEFINE Nbeneficiario_direccion     CHAR(100);   
	DEFINE Nbeneficiario_colonia       CHAR(100);   
	DEFINE Nbeneficiario_calle         CHAR(100);   
	DEFINE Nsucursal                   CHAR(100);   
	DEFINE Nnumctee                    CHAR(10);   
   
	LET Nfecha_proceso            = '';
	LET Ntipo_remesa              = '';
	LET Nabono_cuenta             = '';
	LET Nmonto_total              = 0;
	LET Nmonto_dolares            = 0;
	LET Nbeneficiario_nombre      = '';	
	LET Nbeneficiario_fecha_nac   = '';
	LET Nbeneficiario_estado      = '';	
	LET Nbeneficiario_mncpo_del   = '';
	LET Nbeneficiario_ciudad	  = '';
	LET Nbeneficiario_direccion   = '';	
	LET Nbeneficiario_colonia     = '';
	LET Nbeneficiario_calle       = '';
	LET Nsucursal                 = '';
	LET Nnumctee                  = '';
	     
	
	
	
	LET pld =0;	
	--SET DEBUG FILE TO '/informix/VJTF/sp_metricas_envio_dinero_TRACE.out';
	---TRACE ON; 
	--SET DEBUG FILE TO '/INFORMIXTMP/HMLG/sp_metricas_envio_dinero.out';
	--TRACE ON;
	
	LET vfecha_proceso			= pfecharepor;
	LET vfecha_procesoF			= pfecharepor;
	LET vfecha_procesoI			= pfecharepor - pDiasProceso;	
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
	
	LET vfecha_proceso			= MDY('01','01','1900');
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
			
			--DROP TABLE IF EXISTS temp98_sac_pld_remesas;
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
		
		SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:sac_fechas
		WHERE empresa = "001";
		
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
		

		IF pNumRep = "1" THEN 

			SELECT LEAST(COUNT(*), 100) 
			INTO vValida
			FROM sac_pld_remesas 
			WHERE fecha_proceso >= vfecha_procesoI
			AND fecha_proceso <= vfecha_procesoF; 
			--AND sucursal NOT IN ('9250','9251','9764');
			
			LET cRutaArch = '/home/systelmex/metricas_envio_dinero_1_DDMMAAAA.csv';
			LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
			LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
			LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);
			
			LET cStmt = 'rm -f ' || cRutaArch;
			SYSTEM cStmt;
			
			IF vValida <> 0 THEN 
					
				LET vfecha_procesoF = vfecha_procesoF - 1;
					
				LET cStmt = 'echo "' || "METRICAS DE ENVIOS DE DINERO REPORTE 1, " || vfecha_procesoI ||" - "|| vfecha_procesoF || '" >> ' || cRutaArch;
				SYSTEM cStmt; 
			
				LET cStmt = 'echo "' || "FECHA" || "," ||"MARCA"|| "," || "ABONO A CUENTA" || "," || "MONTO EN PESOS" || "," || "MONTO EN DOLARES" || "," ||
				"BENEFICIARIO" || "," || "FECHA DE NACIMIENTO" || "," || "EDO COBRO" || "," || "MUNICIPIO" || "," || "CIUDAD" || "," || "DIRECCION" || "," ||
				"COLONIA" || "," || "CALLE" || "," || "SUCURSAL" || "," || "NUMERO DE CLIENTE"|| "," || '" >> ' || cRutaArch;
				SYSTEM cStmt; 
				
			
				TRUNCATE TABLE temp98_sac_pld_remesas;
				DROP TABLE IF EXISTS tem_pld_remesas3;
				DROP TABLE IF EXISTS sac_pld_remesas2;
				DROP TABLE IF EXISTS tempo2_payis;
				
				--SE RALIZA UNA TABLA TEMPORAL PARA EXTRAER EL RANGO DE DATOS SOLICITADOS 
				SELECT num_confirmacion,folio_sucursal,fecha_proceso, tipo_remesa, abono_cuenta,monto_total, monto_dolares,
				TRIM(beneficiario_nombre1)||' '||TRIM(beneficiario_nombre2)||' '||TRIM(beneficiario_appaterno)||' '||TRIM(beneficiario_apmaterno) AS beneficiario_nombre,
				beneficiario_fecha_nac, beneficiario_estado, beneficiario_mncpo_del, beneficiario_ciudad, beneficiario_direccion, beneficiario_colonia, beneficiario_calle,sucursal
				FROM sac_pld_remesas 
				WHERE  fecha_proceso <= vfecha_procesoF
				AND fecha_proceso >= vfecha_procesoI
				INTO TEMP sac_pld_remesas2 WITH NO LOG;
	
				--	SE UNEN LAS TRES TABLAS PAYIS Y SE EXTRAEN LOS FOLIOS SUC QUE SE ENCUENTRAN EN LA TABLA SAC_PLD REMESAS.			
				SELECT a.num_confirmacion,a.folio_sucursal,a.fecha_proceso, a.tipo_remesa, a.abono_cuenta, a.monto_total, a.monto_dolares, beneficiario_nombre,	a.beneficiario_fecha_nac, a.beneficiario_estado,
				a.beneficiario_mncpo_del, a.beneficiario_ciudad,a.beneficiario_direccion, a.beneficiario_colonia, a.beneficiario_calle,a.sucursal,TRIM(nvl(wu.numcte,' ')) as numctee
				FROM sac_pld_remesas2 a 
				INNER JOIN sac_wu_pay wu ON wu.fecha_insert > vfecha_procesoI-1 and wu.fecha_insert < vfecha_procesoF+1 and a.folio_sucursal = wu.foreign_rs_refnum_rp	AND  a.num_confirmacion = wu.mtcn  
				WHERE a.fecha_proceso >= vfecha_procesoI							
				AND a.fecha_proceso <= vfecha_procesoF
				AND tipo_remesa in ('VIG','WUN','OVA' )	 				
				UNION ALL
				SELECT a.num_confirmacion,a.folio_sucursal,a.fecha_proceso, a.tipo_remesa, a.abono_cuenta, a.monto_total, a.monto_dolares, beneficiario_nombre,	a.beneficiario_fecha_nac, a.beneficiario_estado,
				a.beneficiario_mncpo_del, a.beneficiario_ciudad,a.beneficiario_direccion, a.beneficiario_colonia, a.beneficiario_calle,a.sucursal,TRIM(nvl(bt.numcte,' ')) as numctee
				FROM sac_pld_remesas2 a 
				INNER JOIN sac_bts_payi bt ON bt.fecha_insert > vfecha_procesoI-1 and bt.fecha_insert < vfecha_procesoF+1 and a.num_confirmacion = bt.confirmation_nm AND a.folio_sucursal = bt.bank_ref_nm   
				WHERE a.fecha_proceso >= vfecha_procesoI							
				AND a.fecha_proceso <= vfecha_procesoF
				AND tipo_remesa='BTS'
				UNION ALL
				SELECT a.num_confirmacion,a.folio_sucursal,a.fecha_proceso, a.tipo_remesa, a.abono_cuenta, a.monto_total, a.monto_dolares, beneficiario_nombre, a.beneficiario_fecha_nac, a.beneficiario_estado, 
				a.beneficiario_mncpo_del, a.beneficiario_ciudad,a.beneficiario_direccion, a.beneficiario_colonia, a.beneficiario_calle,a.sucursal,TRIM(nvl(ap.numcte,' ')) as numctee
				FROM sac_pld_remesas2 a 
				INNER JOIN sac_app_payi ap ON ap.fecha > vfecha_procesoI-1 and ap.fecha < vfecha_procesoF+1 and a.num_confirmacion = ap.unirefnum AND a.folio_sucursal = ap.refnum  
				WHERE a.fecha_proceso >= vfecha_procesoI							
				AND a.fecha_proceso <= vfecha_procesoF
				AND tipo_remesa='APP' 
				INTO TEMP tempo2_payis WITH NO LOG;
						
				
				--- SE EXTRAEN LOS FOLIOS SUC QUE SEAN DIFERENTE DE LA TABLA TEMPORAL DE LAS PAYIS.
				select a.fecha_proceso, a.tipo_remesa, a.abono_cuenta, a.monto_total, a.monto_dolares,beneficiario_nombre,a.beneficiario_fecha_nac, a.beneficiario_estado,
				a.beneficiario_mncpo_del, a.beneficiario_ciudad,a.beneficiario_direccion, a.beneficiario_colonia, a.beneficiario_calle,a.sucursal,' ' as numctee
				from sac_pld_remesas2 a
				where a.num_confirmacion not in  (select num_confirmacion from tempo2_payis) 
				and a.folio_sucursal not in (select folio_sucursal from tempo2_payis)
				INTO TEMP tem_pld_remesas3 WITH NO LOG; 
				
				
				-- SE CREA EL FOREACH PARA INSERTAR LOS DATOS DE LA TABLA tem_pld_remesas3  A LA TABLA temp98_sac_pld_remesa, ESTA ES LA TABLA QUE SE UTILIZA PARA CREAR EL ARCHIVO
				BEGIN WORK;
				FOREACH WITH HOLD
				
					SELECT fecha_proceso, a.tipo_remesa, a.abono_cuenta, a.monto_total, a.monto_dolares,a.beneficiario_nombre,a.beneficiario_fecha_nac, a.beneficiario_estado, 
					a.beneficiario_mncpo_del, a.beneficiario_ciudad,a.beneficiario_direccion, a.beneficiario_colonia, a.beneficiario_calle,a.sucursal, numctee						
					INTO Nfecha_proceso, Ntipo_remesa, Nabono_cuenta, Nmonto_total, Nmonto_dolares,Nbeneficiario_nombre, Nbeneficiario_fecha_nac, Nbeneficiario_estado, 
					Nbeneficiario_mncpo_del, Nbeneficiario_ciudad, Nbeneficiario_direccion, Nbeneficiario_colonia, Nbeneficiario_calle, Nsucursal,Nnumctee						
					FROM tem_pld_remesas3 a
			
					INSERT INTO temp98_sac_pld_remesas(fecha_proceso,  tipo_remesa,  abono_cuenta,  monto_total,  monto_dolares,beneficiario_nombre, beneficiario_fecha_nac,  beneficiario_estado,  
					beneficiario_mncpo_del,  beneficiario_ciudad, beneficiario_direccion, beneficiario_colonia,  beneficiario_calle, sucursal, numctee	) 
					values (Nfecha_proceso, Ntipo_remesa, Nabono_cuenta, Nmonto_total, Nmonto_dolares,Nbeneficiario_nombre, Nbeneficiario_fecha_nac, Nbeneficiario_estado, 
					Nbeneficiario_mncpo_del, Nbeneficiario_ciudad,Nbeneficiario_direccion, Nbeneficiario_colonia, Nbeneficiario_calle, Nsucursal,Nnumctee	);
			
					LET pld = pld + 1;
						
						IF pld = 5000 THEN
							COMMIT WORK;
							LET pld = 0;
							BEGIN WORK;
						END IF;				

				END FOREACH;
				
				IF pld < 5000 and pld >= 0 THEN
					COMMIT WORK;
				END IF;
				LET pld = 0;
				
				-- SE CREA EL FOREACH PARA INSERTAR LOS DATOS DE LA TABLA tempo2_payis  A LA TABLA temp98_sac_pld_remesa(ESTA ES LA TABLA QUE SE UTILIZA PARA CREAR EL ARCHIVO)
				BEGIN WORK;
				FOREACH WITH HOLD
				
					SELECT fecha_proceso, a.tipo_remesa, a.abono_cuenta, a.monto_total, a.monto_dolares,a.beneficiario_nombre, a.beneficiario_fecha_nac, a.beneficiario_estado, 
					a.beneficiario_mncpo_del, a.beneficiario_ciudad,a.beneficiario_direccion, a.beneficiario_colonia, a.beneficiario_calle,	sucursal, numctee						
					INTO Nfecha_proceso, Ntipo_remesa, Nabono_cuenta, Nmonto_total, Nmonto_dolares,	Nbeneficiario_nombre, Nbeneficiario_fecha_nac, Nbeneficiario_estado, 
					Nbeneficiario_mncpo_del, Nbeneficiario_ciudad,Nbeneficiario_direccion, Nbeneficiario_colonia, Nbeneficiario_calle, Nsucursal,Nnumctee						
					FROM tempo2_payis a					
							
						INSERT INTO temp98_sac_pld_remesas(fecha_proceso, tipo_remesa, abono_cuenta, monto_total,monto_dolares,beneficiario_nombre, beneficiario_fecha_nac, beneficiario_estado, 
						beneficiario_mncpo_del, beneficiario_ciudad, beneficiario_direccion, beneficiario_colonia, beneficiario_calle, sucursal, numctee) 
						values (Nfecha_proceso, Ntipo_remesa, Nabono_cuenta, Nmonto_total, Nmonto_dolares,Nbeneficiario_nombre, Nbeneficiario_fecha_nac, Nbeneficiario_estado,
						Nbeneficiario_mncpo_del, Nbeneficiario_ciudad,Nbeneficiario_direccion, Nbeneficiario_colonia, Nbeneficiario_calle, Nsucursal,Nnumctee	);						
						LET pld = pld + 1;						
						IF pld = 5000 THEN
							COMMIT WORK;
							LET pld = 0;
							BEGIN WORK;
						END IF;				
						
				END FOREACH;

				IF pld < 5000 and pld >= 0 THEN
					COMMIT WORK;
				END IF;

				
				LET cStmt = 'echo "UNLOAD TO /home/systelmex/metricas_envio_dinero_1_orig.csv SELECT * FROM temp98_sac_pld_remesas ORDER BY fecha_proceso,tipo_remesa;">/home/systelmex/reportemetenr.sql';
				SYSTEM cStmt;
			
				LET cStmt= 'dbaccess bdisac	/home/systelmex/reportemetenr.sql';
				SYSTEM cStmt;
			
				/* ELIMINA CARACTER , DEL REPORTE */
				SYSTEM 'tr -d '',''< /home/systelmex/metricas_envio_dinero_1_orig.csv >/home/systelmex/metricas_envio_dinero_1_sincomas1.csv';
				LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinero_1_orig.csv';
				SYSTEM cStmt;
				
				
				/* CAMBIA DELIMITADOR | POR , */
				SYSTEM 'sed ''s/|/,/g'' /home/systelmex/metricas_envio_dinero_1_sincomas1.csv > /home/systelmex/metricas_envio_dinero_1.csv';
				LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinero_1_sincomas1.csv';
				SYSTEM cStmt;
				
								
				SYSTEM 'tail -n +1 /home/systelmex/metricas_envio_dinero_1.csv >> ' || cRutaArch;
				
				LET cStmt = 'rm -f /home/systelmex/reportemetenr.sql';
				SYSTEM cStmt;

				LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinero_1.csv';
				SYSTEM cStmt; 
				
				LET iCodRet = "00000";				
				LET iMensaje =  "Proceso Exitoso 1";
				
				DROP TABLE IF EXISTS tem_pld_remesas3;
				DROP TABLE IF EXISTS sac_pld_remesas2;
				TRUNCATE TABLE temp98_sac_pld_remesas;
				DROP TABLE IF EXISTS tempo2_payis;
				
				INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_1',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero','Reporte Metricas de Envio de Dinero y Enrolamiento 1 ');
				
			ELSE
			
				DROP TABLE IF EXISTS tem_pld_remesas3;
				DROP TABLE IF EXISTS sac_pld_remesas2;
				TRUNCATE TABLE temp98_sac_pld_remesas;
				DROP TABLE IF EXISTS tempo2_payis;
				
				LET iCodRet = "00000";				
				LET iMensaje =  "Proceso Exitoso 1 Sin Datos";
				INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_1',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero','Reporte Metricas de Envio de Dinero y Enrolamiento 1 ');
			
			END IF;

		
		ELIF pNumRep = "2" THEN 
		
			--"METRICAS DE ENVIOS DE DINERO REPORTE 2"
			
			
			--01 Genera tabla Pivote con sucursales que pagaron remesas
   
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM sac_movimientoshistorial 
				WHERE fecha_insert >= vfecha_procesoI
                AND fecha_insert <= vfecha_procesoF
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis  WITH NO LOG;
			
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
				LEFT JOIN bdisac:sac_cte_remesas e ON a.sucursal = e.sucursal
				LEFT JOIN bdinteg:si_ptf b on a.sucursal = b.id_ptf and b.tipo in ('S','O')
				LEFT JOIN bdinteg:si_estados d ON b.cve_pais = d.pais
				AND b.cve_estado = d.estado
				GROUP BY a.sucursal, b.cve_estado,d.nombre
			INTO TEMP tempsuc_edo  WITH NO LOG;
			/*
			--03 Total de enrolados y por periodo del reporte						   
			SELECT sucursal,NVL(count(*),0) as total_enrolados 
				FROM sac_cte_remesas  /*fechas para totales* /
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
			
			
		SELECT sucursal,NVL(count(*),0) as total_enrolados 
				FROM sac_cte_remesas  /*fechas para totales* /
				WHERE fecha_alta >= vfecha_procesoI
				AND fecha_alta <= vfecha_procesoF
				GROUP BY sucursal
			INTO TEMP tempsuc_periodot  WITH NO LOG; 
								   
			 */
			--03 Total de enrolados y por periodo del reporte			
			DROP TABLE IF EXISTS sac_cte_temsucursal;
			SELECT sucursal FROM sac_cte_remesas
			WHERE fecha_alta >= vfecha_procesoI
			AND fecha_alta <= vfecha_procesoF
			INTO TEMP sac_cte_temsucursal  WITH NO LOG; 
			
			SELECT sucursal,NVL(count(*),0) as total_enrolados 
			FROM sac_cte_temsucursal  /*fechas para totales*/
			where sucursal <> ''								   
			GROUP BY sucursal
			INTO TEMP tempsuc_periodot  WITH NO LOG;
			

			SELECT sucursal, total_enrolados as totale_periodo
			FROM tempsuc_periodot				
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
				AND a.sucursal != ''	
				AND a.numcte <> ''									   
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
                        and a.fecha_insert >= vfecha_procesoI
                        and a.fecha_insert <= vfecha_procesoF 
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
						and a.fecha_insert >= vfecha_procesoI
                        and a.fecha_insert <= vfecha_procesoF 
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
                        and a.fecha_insert >= vfecha_procesoI 
                        and a.fecha_insert <= vfecha_procesoF 
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
                        and a.fecha_insert >= vfecha_procesoI 
                        and a.fecha_insert <= vfecha_procesoF  
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
						and a.fecha_insert >= vfecha_procesoI 
                        and a.fecha_insert <= vfecha_procesoF 
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
						and a.fecha_insert >= vfecha_procesoI
                        and a.fecha_insert <= vfecha_procesoF 
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
				b.tusuarios_enrolados,b.tusuarios_no_enrolados,9999.99 as promedio
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
					
				
					LET cRutaArch = '/home/systelmex/metricas_envio_dinero_2_DDMMAAAA.csv';
			
					LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
					LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
					LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);

					LET cStmt = 'rm -f ' || cRutaArch;
					SYSTEM cStmt;			
					
					LET vfecha_procesoF = vfecha_procesoF - 1;
					
					LET cStmt = 'echo "' || "METRICAS DE ENVIOS DE DINERO REPORTE 2 " || vfecha_procesoI ||" - "|| vfecha_procesoF || '" >> ' || cRutaArch;
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
					
					LET cStmt = 'echo "UNLOAD TO /home/systelmex/metricas_envio_dinero_2.csv DELIMITER '','' SELECT * FROM temp_reporteenrolamiento58 ORDER BY 1,2;">/home/systelmex/reportemetenr2.sql';
					SYSTEM cStmt;
				
					let cStmt= 'dbaccess bdisac	/home/systelmex/reportemetenr2.sql';
					system cStmt;
					
					SYSTEM 'tail -n +1 /home/systelmex/metricas_envio_dinero_2.csv >> ' || cRutaArch;
					
					LET cStmt = 'rm -f /home/systelmex/reportemetenr2.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinero_2.csv';
					SYSTEM cStmt;
					
					DROP TABLE IF EXISTS temp_reporteenrolamiento58;
					LET iCodRet = "00000";				
					LET iMensaje =  "Proceso Exitoso 2";
					
					
					INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_2',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero','Reporte Metricas de Envio de Dinero y Enrolamiento 2 ');
	
				
				ELSE
					LET cStmt = 'rm -f ' || cRutaArch;
					SYSTEM cStmt;
				
					LET iCodRet = "00000";				
					LET iMensaje =  "Proceso Exitoso 2  Sin Datos";
					INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_2',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero','Reporte Metricas de Envio de Dinero y Enrolamiento 2 ');
				END IF;
					
		ELSE
			
			LET iCodRet = "00001";				
			LET iMensaje =  "Proceso NO Exitoso";
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('REP_MET_ENV_DIN_ENROL_2',today,'0','informix',CURRENT,'1','sp_metricas_envio_dinero','Reporte Metricas de Envio de Dinero y Enrolamiento 2 ');
		END IF;
		
		
		RETURN iCodRet,iMensaje;
		
	END;

END PROCEDURE;