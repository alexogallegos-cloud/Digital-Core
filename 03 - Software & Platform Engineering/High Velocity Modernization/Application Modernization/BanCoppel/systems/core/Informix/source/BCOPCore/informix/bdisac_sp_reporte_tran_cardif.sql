CREATE PROCEDURE "informix".sp_reporte_tran_cardif(pfecharepor DATE)
	
	RETURNING CHAR(5) AS iCodRet, char(50) as iMensaje;
	
	DEFINE iCodRet 			CHAR(5);
	DEFINE iMensaje			CHAR(50);
	DEFINE cRutaArch 		CHAR(100);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCategoria 		CHAR(2);
	DEFINE cConvenio 		CHAR(3);
	DEFINE cNombreServicio 	CHAR(50);
	DEFINE cDia 			CHAR(2);
	DEFINE cMes 			CHAR(2);
	DEFINE cAnio 			CHAR(4);
	DEFINE dFecha_Hoy 		DATE;
	DEFINE iImporte_Pago 	INTEGER;
	DEFINE iCuenta_Pago 	INTEGER;
	DEFINE cStmt 			CHAR (250);
	DEFINE vEstatusConvenio		CHAR(1);
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_reporte_tran_cardif.out';
	--TRACE ON; 
	--SET DEBUG FILE TO '/ifxsif01/HMLG/sp_reporte_tran_cardif.out';
	--TRACE ON;
	
	LET iCodRet = "00000";
	LET cRutaArch = '';
	LET iSqlErr = 0;
	LET cCategoria = '';
	LET cConvenio = '';
	LET cNombreServicio='';
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET dFecha_Hoy = MDY('01','01','1900');
	LET iImporte_Pago = 0;
	LET iCuenta_Pago = 0;
	LET cStmt = '';
	LET iMensaje = '';
	LET vEstatusConvenio = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			LET iMensaje = "Proceso NO Exitoso Error BD.";
			
			IF cRutaArch IS NOT NULL OR cRutaArch <> "" THEN 
				LET cStmt = 'rm -f /home/systelmex/reportetrancardif.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reporte_tran_cardif.txt';
				SYSTEM cStmt;				
			END IF;
					
			DROP TABLE IF EXISTS tempfechaspcardif;
			DROP TABLE IF EXISTS tempfechas6pcardif;
			DROP TABLE IF EXISTS tempfechas12pcardif;
			DROP TABLE IF EXISTS temp101072_sac_reporte_tran_cardif;
			
			RETURN iCodRet,iMensaje;
		END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		SELECT statusconvenio 
		INTO vEstatusConvenio
		FROM sac_convenios 
		WHERE numcategoria = '09'
		AND numconvenio = '023';
		
		
		IF vEstatusConvenio = 'A' THEN  
		
			
			IF pfecharepor IS NULL OR pfecharepor = '' THEN
				SELECT fecha_hoy 
				INTO dFecha_Hoy 
				FROM bdisac:sac_fechas
				WHERE empresa = "001";
			ELSE 
				LET dFecha_Hoy = pfecharepor;
			END IF;
			
			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
			
			LET cRutaArch = '/home/systelmex/REPORTE_TRANSACCIONES_CARDIF_DDMMAAAA.txt';
			
			LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
			LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
			LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);
			
			LET cStmt = 'rm -f ' || cRutaArch;
			SYSTEM cStmt;
			
			LET cStmt = 'echo "' || "REPORTE DE TRANSACCIONES SEGURO DE REPATRIACION DE RESTOS " ||cAnio||"-"||cMes||"-"||cDia||"|"|| '" >> ' || cRutaArch;
			SYSTEM cStmt; 
			
			LET cStmt = 'echo "' || "FECHA" || "|" ||"SEMESTRAL"|| "|" || "ANUAL"|| "|" || '" >> ' || cRutaArch;
			SYSTEM cStmt;

			IF cMes <> "01" then
				LET cMes = Month(dFecha_Hoy - 1 units month);
			ELSE
				LET cMes = Month(dFecha_Hoy - 1 units month);
				LET cAnio = Year(dFecha_Hoy)-1;
			END IF;
			
			SELECT count(*) AS cuenta
			INTO iCuenta_Pago
			FROM sac_cardif_migrante
			WHERE NVL(folio_suc,"") <> ""
				AND estatus = 1
				AND MONTH(fecha_insert) = cMEs
				AND YEAR(fecha_insert) = cAnio;
		
			
			IF iCuenta_Pago <> 0 THEN
			
				DROP TABLE IF EXISTS tempfechaspcardif;
				DROP TABLE IF EXISTS tempfechas6pcardif;
				DROP TABLE IF EXISTS tempfechas12pcardif;
				DROP TABLE IF EXISTS temp101072_sac_reporte_tran_cardif;
					
				--FECHAS
				SELECT fecha_insert::date as fecha, count(*) as cuentaT
				FROM sac_cardif_migrante
				WHERE NVL(folio_suc,"") <> ""
					AND estatus = 1
					AND MONTH(fecha_insert) = cMEs
					AND YEAR(fecha_insert) = cAnio
				GROUP BY fecha
				INTO TEMP tempfechaspcardif  WITH NO LOG;
	
				--SEMESTRAL
				SELECT fecha_insert::date as fecha, count(*) as csemestral
				FROM sac_cardif_migrante
				WHERE NVL(folio_suc,"") <> ""
					AND estatus = 1
					AND tipo_plan = 5
					AND MONTH(fecha_insert) = cMEs
					AND YEAR(fecha_insert) = cAnio
				GROUP BY fecha
				INTO TEMP tempfechas6pcardif  WITH NO LOG;
	
				--ANUAL
				SELECT fecha_insert::date as fecha, count(*) as canual
				FROM sac_cardif_migrante
				WHERE NVL(folio_suc,"") <> ""
					AND estatus = 1
					AND tipo_plan = 4
					AND MONTH(fecha_insert) = cMEs
					AND YEAR(fecha_insert) = cAnio
				GROUP BY fecha
				INTO TEMP tempfechas12pcardif  WITH NO LOG;
	
				/*
				SELECT t.fecha_alta,nvl(csemestral,0) as csemestral, nvl(canual,0) as canual
				FROM tempfechaspcardif t
				LEFT JOIN tempfechas6pcardif s ON t.fecha_alta = s.fecha_alta
				LEFT JOIN tempfechas12pcardif d ON t.fecha_alta = d.fecha_alta
				INTO temp101072_sac_reporte_tran_cardif;
				*/
				
				SELECT t.fecha,to_char(nvl(csemestral,0)) as csemestral, to_char(nvl(canual,0)) as canual
				FROM tempfechaspcardif t
				LEFT JOIN tempfechas6pcardif s ON t.fecha = s.fecha
				LEFT JOIN tempfechas12pcardif d ON t.fecha = d.fecha
				INTO temp101072_sac_reporte_tran_cardif;
				
				LET cStmt = 'echo "UNLOAD TO /home/systelmex/reporte_tran_cardif.txt SELECT * FROM temp101072_sac_reporte_tran_cardif ORDER BY fecha ASC;">/home/systelmex/reportetrancardif.sql';
				SYSTEM cStmt;
					
				LET cStmt= 'dbaccess bdisac	/home/systelmex/reportetrancardif.sql';
				system cStmt;
				
				SYSTEM 'tail -n +1 /home/systelmex/reporte_tran_cardif.txt >> ' || cRutaArch;
				
				LET cStmt = 'rm -f /home/systelmex/reportetrancardif.sql';
				SYSTEM cStmt;
				LET cStmt = 'rm -f /home/systelmex/reporte_tran_cardif.txt';
				SYSTEM cStmt;				
				
				
				LET iCodRet = "00000";				
				LET iMensaje =  "Proceso Exitoso";
				
				DROP TABLE IF EXISTS tempfechaspcardif;
				DROP TABLE IF EXISTS tempfechas6pcardif;
				DROP TABLE IF EXISTS tempfechas12pcardif;
				DROP TABLE IF EXISTS temp101072_sac_reporte_tran_cardif;
			
				INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
				VALUES ('REP_TRAN_CARDIF',today,'1','informix',CURRENT,'1','sp_reporte_tran_cardif','Reporte Mensual Transacciones CARDIF');
			
			ELSE
				
				LET cStmt = 'echo "' || "SIN PAGOS REGISTRADOS PARA PERIODO DEL REPORTE|0|0|" || '" >> ' || cRutaArch;
				SYSTEM cStmt; 
				
				LET iCodRet = "00000";				
				LET iMensaje =  "Proceso Exitoso SIN REGISTROS";
			
			
				INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
				VALUES ('REP_TRAN_CARDIF',today,'1','informix',CURRENT,'1','sp_reporte_tran_cardif','Reporte Mensual Transacciones CARDIF');
			
			END IF;
		ELSE 
			
			LET iCodRet = "00001";				
			LET iMensaje =  "Proceso NO Exitoso, Servicio Inactivo SAC";
		
		END IF;
		
		RETURN iCodRet,iMensaje;
		
	END;

END PROCEDURE;