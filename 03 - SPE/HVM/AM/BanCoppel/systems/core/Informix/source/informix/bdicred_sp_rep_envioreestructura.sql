CREATE PROCEDURE "informix".sp_rep_envioreestructura()
RETURNING CHAR(5), CHAR(90);

DEFINE cCodRet				CHAR(5);
DEFINE cMenRet				CHAR(90);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cEmpresa 			CHAR(3);
DEFINE cArchEnvioReest		CHAR(30);
DEFINE cNumCredito			CHAR(15);
DEFINE cNumCreditoRees		CHAR(15);
DEFINE cProducto			CHAR(4);
DEFINE cProductoRees		CHAR(5);
DEFINE cNumCte				CHAR(15);
DEFINE cCommand				CHAR(1000);
DEFINE cRutaArchivo			CHAR(100);
DEFINE cCorreoEnvio			CHAR(30);
DEFINE cTelefonoCte			CHAR(10);
DEFINE dFechaHoy			DATE;
DEFINE dFechaConcentra		DATE;
DEFINE iSqlErr				INTEGER;
DEFINE iPlazo				INTEGER;
DEFINE iCountReg			INTEGER;
DEFINE dcSdoReest			DECIMAL(18,2);
DEFINE cPrimer_dia 		DATE;
DEFINE cUltimo_dia 		DATE;

LET iSqlErr 			= 0;
LET iPlazo				= 0;
LET dcSdoReest			= 0;
LET iCountReg			= 0;
LET cCodRet 			= '00000';
LET cMenRet				= 'PROCESO EXITOSO';
LET cDia				= '';
LET cMes				= '';
LET cAnio				= '';
LET dFechaHoy			= '';
LET dFechaConcentra		= '';
LET cArchEnvioReest		= 'EnvioReestructura_';
LET cRutaArchivo		= '/RESPALDOSNEW/'; --PRODUCCIÃN
--LET cRutaArchivo		= '/RESPALDOSNEW/gpe/'; -- DESARROLLO
LET cNumCredito			= '';
LET cNumCte				= '';
LET cProducto			= '';
LET cNumCreditoRees		= '';
LET cCommand			= '';
LET cCorreoEnvio		= '';
LET cTelefonoCte		= '';
LET cPrimer_dia 		= ''; 
LET cUltimo_dia 		= '';
LET cEmpresa 			= '001';



BEGIN
		ON EXCEPTION SET iSqlErr
		
			drop table if exists temp_envio_reestructura;
			
			IF iSqlErr = -668 THEN
				LET cCodRet = '00001';
				LET cMenRet = 'Proceso con terminancion -668.';
				
				RETURN cCodRet, cMenRet;
			ELIF iSqlErr != -668 THEN
				LET cCodRet = '00002';
				LET cMenRet = 'Error al ejecutar el proceso ' || iSqlErr;
				
				RETURN cCodRet, cMenRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/informix/roman/digitalizacion_documentos/sp_rep_envioreestructura.out";
		--TRACE ON;
		
		SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy), pri_dia_mes - 1 units month, ult_dia_mes - 1 units month
		INTO dFechaHoy, cDia, cMes, cAnio, cPrimer_dia, cUltimo_dia
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = cEmpresa;
		
		--PARA PRUEBAS
	/*	LET dFechaHoy = MDY('03','08','2021');
		LET cDia = DAY(dFechaHoy);
		LET cMes = MONTH(dFechaHoy);
		LET cAnio = YEAR(dFechaHoy);*/
		
		IF MONTH(dFechaHoy) < 10 THEN
			LET cMes = '0' || TRIM(cMes);
		END IF;
		
		IF DAY(dFechaHoy) < 10 THEN
			LET cDia = '0' || TRIM(cDia);
		END IF;
		
		LET cArchEnvioReest = TRIM(cArchEnvioReest) || cDia || cMes || cAnio || '.txt';
		
		--CREACIÃN TABLA TEMPORAL PARA ALMACENAR DATOS DE VALIDACIÃN
		IF NOT EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_envio_reestructura' ) THEN
			CREATE TABLE temp_envio_reestructura      	
				(fecha_contratacion     DATE,  
				fecha_envio    			DATE,
				numcte					CHAR(9),
				num_cred		   		CHAR(20),
				producto		    	CHAR(4),
				num_cred_origen         CHAR(20),
				producto_origen	        CHAR(5),
				canal_envio		       	CHAR(20),
				telefono_envio			CHAR(12),
				correo_envio            CHAR(30)
			) in dbs_cfd_06 extent size 88904 next size 53342; 
		END IF;
		
		FOREACH
			SELECT numcte, correo_electronico
			INTO cNumcte, cCorreoEnvio
			FROM bdicred:"informix".sd_programacion_reestructuras_aut
			WHERE fecha = dFechaHoy
			
			--NÃMERO DE CRÃDITO Y PRODUCTO ORIGEN
			SELECT num_credito, num_producto
			INTO cNumCredito, cProducto
			FROM bdicred:"informix".sd_maecred 
			WHERE numcte = cNumcte;
			
			SELECT COUNT(a.num_credito)
			INTO iCountReg
			FROM bdicred:"informix".sd_maecredcrd a
			INNER JOIN bdicred:"informix".sd_maesdoscrd b on a.num_credito = b.num_credito
			WHERE a.numcte = cNumcte AND a.num_producto in ('6011','8600')
			AND a.fecha_apertura between cPrimer_dia AND cUltimo_dia;
			
			IF iCountReg > 0 THEN
				--NÃMERO DE CRÃDITO Y PRODUCTO REESTRUCTURA.
				SELECT a.num_credito, a.num_producto, a.fecha_apertura, a.plazo, b.sdo_cap_insoluto
				INTO cNumCreditoRees, cProductoRees,dFechaConcentra,iPlazo,dcSdoReest
				FROM bdicred:"informix".sd_maecredcrd a
				INNER JOIN bdicred:"informix".sd_maesdoscrd b on a.num_credito = b.num_credito
				WHERE a.numcte = cNumcte AND a.num_producto in ('6011','8600')
				AND a.fecha_apertura between cPrimer_dia AND cUltimo_dia;
				
				SELECT telefono INTO cTelefonoCte
				FROM bdinteg:si_telefonos WHERE numcte = cNumcte AND status_tel = 'A' AND
					 secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_telefonos WHERE numcte = cNumcte);
				
				INSERT INTO temp_envio_reestructura VALUES (dFechaConcentra, today, cNumcte, cNumCreditoRees, cProductoRees, cNumCredito, cProducto, 'Correo', cTelefonoCte, cCorreoEnvio); 
			END IF;
		END FOREACH;
		
		--GENERACIÃN ARCHIVO EnvioReestructura_DDMMAAAA.txt
		LET cCommand = 'echo "UNLOAD TO ' || TRIM(cRutaArchivo) || 'EnvioReestructura_' || cDia || cMes || cAnio || "_1.txt DELIMITER " || "'" || '|' || "'" || '" > ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_EnvioResstructura.sql;';
		SYSTEM TRIM(cCommand);
			
		LET cCommand = 'echo "SELECT * FROM temp_envio_reestructura; " >> ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_EnvioResstructura.sql;';
		SYSTEM TRIM(cCommand);
			
		LET cCommand = 'chmod 777 ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_EnvioResstructura.sql;';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'dbaccess bdicred ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_EnvioResstructura.sql;';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = "sed 's/|$//g' " || TRIM(cRutaArchivo) || 'EnvioReestructura_' || cDia || cMes || cAnio || '_1.txt > ' || TRIM(cRutaArchivo) || TRIM(cArchEnvioReest);
		SYSTEM TRIM(cCommand);
		
		--ELIMINACIÃN TABLA Y ARCHIVOS
		DROP TABLE temp_envio_reestructura;
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || 'EnvioReestructura_' || cDia || cMes || cAnio || '_1.txt';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_EnvioResstructura.sql;';
		SYSTEM TRIM(cCommand);
		
		RETURN cCodRet, cMenRet;
	END
END PROCEDURE;