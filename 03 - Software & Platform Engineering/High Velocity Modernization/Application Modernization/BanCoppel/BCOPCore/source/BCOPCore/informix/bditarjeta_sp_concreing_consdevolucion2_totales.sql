CREATE PROCEDURE "informix".sp_concreing_consdevolucion2_totales(piTipoArchivo INTEGER, psFechaConsulta VARCHAR(10), psNombreArchivo VARCHAR(21))
RETURNING 	VARCHAR(5)  AS CodRet,
			INTEGER AS numero_registros;

--****************************************************************************************************
-- DESCRIPCION: OBTENCION DE DEVOLUCIONES POS
-- AUTOR : Arturo MÃ©ndez CÃ¡rdenas
-- FECHA : 12/ABRIL/2012
-- BD: bditarjeta
-- SISTEMA : DevolucionesPOS
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE cCodret CHAR(5);
DEFINE iNoRegistros INTEGER;
DEFINE iDevrecibidas INTEGER;
DEFINE iEncontrado INTEGER;
DEFINE cArchivoOrigenAnt CHAR(23);
DEFINE cArchivoOrigen CHAR(3);

/* INICIALIZACION DE VARIABLES */
--CONTROL GENERAL
LET cCodret = '00000';
LET iNoRegistros = 0;
LET iDevrecibidas = 0;
LET iEncontrado = 0;
LET cArchivoOrigenAnt = '';
LET cArchivoOrigen = '';

BEGIN
	
ON EXCEPTION SET iDevrecibidas 
   IF iDevrecibidas != 0 THEN
      LET cCodret = iDevrecibidas;      
      RETURN cCodret, iNoRegistros;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/home/sysifx/ilse/cashBack/sp_concreing_pba.txt';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF piTipoArchivo = 1 THEN -- Todos los tipos de archivos
	
		SELECT SUM(totales)
		INTO iNoRegistros
		FROM (
			SELECT COUNT(distinct(nomarchivo)) AS totales
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VIC','VNC','VID','VND','MCD','MCC') AND fecha = psFechaConsulta
			UNION
			SELECT count(distinct(nombrearchivo)) AS totales
			FROM bditarjeta:"informix".td_archivos_conciliacion WHERE fecha_archivo = psFechaConsulta 
			AND fecha_hora_fin_proceso > '1900-01-01 00:00:00.0' AND archivo_origen IN('VIC','VNC','VID','VND') 
			AND nombrearchivo NOT IN (select nomarchivo	from bditarjeta:"informix".td_devolucionespos where fecha = psFechaConsulta));
		
		RETURN cCodret, iNoRegistros;
	
	ELIF piTipoArchivo = 2 THEN -- Archivos de crÃ©dito con devoluciones pendientes
		
		SELECT COUNT(distinct(nomarchivo))
		INTO iNoRegistros 
		FROM bditarjeta:"informix".td_devolucionespos 
		WHERE archivoorigen IN('VIC','VNC','MCC') AND fecha = psFechaConsulta 
		AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
			 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))); -- (tipo_conciliaciÃ³n 0,10,12 y 15)
					
		RETURN cCodret, iNoRegistros;
		
	ELIF piTipoArchivo = 3 THEN -- Archivos de crÃ©dito sin devoluciones pendientes
				
		IF NOT EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos 
						WHERE archivoorigen IN('VIC','VNC','MCC') AND fecha = psFechaConsulta 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							(encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN
		
			
			SELECT COUNT(distinct(nomarchivo))
			INTO iNoRegistros
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VIC','VNC','MCC') AND fecha = psFechaConsulta 
			AND((encontrado = 'V' AND estado = 'F' AND aplicado = 'V') OR 
				(encontrado = 'V' AND estado = 'A' AND aplicado = 'V')); -- (tipo_conciliacion 11 y 14)
				
		END IF;
		
		RETURN cCodret, iNoRegistros;
	
	ELIF piTipoArchivo = 4 THEN -- Archivos de dÃ©bito con devoluciones pendientes
	
		SELECT COUNT(distinct(nomarchivo))
		INTO iNoRegistros
		FROM bditarjeta:"informix".td_devolucionespos 
		WHERE archivoorigen IN('VID','VND','MCD') AND fecha = psFechaConsulta 
		AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
			 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))); -- (tipo_conciliaciÃ³n 0,10,12 y 15)
		
		RETURN cCodret, iNoRegistros;
	
	ELIF piTipoArchivo = 5 THEN -- Archivos de dÃ©bito sin devoluciones pendientes
				
		IF NOT EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos 
						WHERE archivoorigen IN('VID','VND','MCD') AND fecha = psFechaConsulta 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							(encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN
		
			SELECT COUNT(distinct(nomarchivo))
			INTO iNoRegistros
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VID','VND','MCD') AND fecha = psFechaConsulta 
			AND((encontrado = 'V' AND estado = 'F' AND aplicado = 'V') OR 
				(encontrado = 'V' AND estado = 'A' AND aplicado = 'V')); -- (tipo_conciliacion 11 y 14)
						
		END IF;
		
		RETURN cCodret, iNoRegistros;
	
	ELIF piTipoArchivo = 6 THEN -- Datos Detalle
	
		SELECT COUNT(nomarchivo)
		INTO iNoRegistros
		FROM bditarjeta:"informix".td_devolucionespos 
		WHERE nomarchivo = psNombreArchivo AND fecha = psFechaConsulta;
		
		RETURN cCodret, iNoRegistros;
	
	END IF;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Arturo MÃ©ndez CÃ¡rdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Fecha: 2012/04/12',
'Version: 20120412.1605',
'BD: BdiTarjeta',
'',
'MODIFICACION: Arturo MÃ©ndez CÃ¡rdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Fecha: 2012/05/23',
'Version: 20120523.1542',
'BD: BdiTarjeta',
'',
'MODIFICACION: Arturo MÃ©ndez CÃ¡rdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Cambio: Se modifica para obtener archivos sin devoluciones',
'Fecha: 2012/06/22',
'Version: 20120622.0845',
'BD: BdiTarjeta',
'',
'MODIFICACION: GÃ³mez PÃ©rez Ilse JazmÃ­n',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Cambio: Se integra un nuevo campo al proceso de estracciÃ³n, para retornar el monto de transacciones Cash Back.',
'Fecha: 2013/08/27',
'Version: 20130821.1441',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃ©ndiz Martinez',
'Proyecto: Conciliacion MasterCard',
'Solicito: Luis Antonio Gomez',
'Cambio: Se integra archivos MCD y MCC para el procesos de clasificacion de ',
'Fecha: 2014/04/04',
'Version: 20140404.1322',
'BD: BdiTarjeta',
'',
'MODIFICACION: Oscar Flores Conde',
'Proyecto: SOCWEB - Conciliacion MasterCard',
'Cambio: Se agrega el manejo de paginaciÃ³n de registros',
'Fecha: 2015/08/24',
'Version: 20140404.1322',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consdevolucion2(piTipoArchivo INTEGER, psFechaConsulta VARCHAR(10), psNombreArchivo VARCHAR(21), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING 	VARCHAR(5)  AS CodRet, 
			VARCHAR(48) AS TipoArchivo, 
			VARCHAR(23) AS NombreArchivo,
			DATE		AS FechaCarga,
			INTEGER 	AS DevRecibidas, 
			INTEGER 	AS DevAplicadas,
			INTEGER 	AS DevAplicadasForzadas, 
			INTEGER 	AS DevConciliadasSA, 
			INTEGER 	AS DevErrorIntegridad, 
			INTEGER 	AS DevFaltantes,
			VARCHAR(16) AS NumTarjeta,
			VARCHAR(5)  AS TipoOperacion,
			VARCHAR(61) AS Motivo,
			VARCHAR(30) AS NomComercio,
			VARCHAR(40) AS Referencia,
			MONEY		AS Monto,
			MONEY		AS montocashbackarchivo;

--****************************************************************************************************
-- DESCRIPCION: OBTENCION DE DEVOLUCIONES POS
-- AUTOR : Arturo Méndez Cárdenas
-- FECHA : 12/ABRIL/2012
-- BD: bditarjeta
-- SISTEMA : DevolucionesPOS
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

--CONTROL GENERAL
DEFINE cCodret CHAR(5);
DEFINE cTipoarchivo CHAR(48);
DEFINE cNombrearchivo CHAR(23);
DEFINE cFechacarga DATE;
DEFINE iDevrecibidas INTEGER;
DEFINE iDevaplicadas INTEGER;
DEFINE iDevaplicadasforzadas INTEGER;
DEFINE iDevconciliadassa INTEGER;
DEFINE iDeverrorintegridad INTEGER;
DEFINE iDevfaltantes INTEGER;
DEFINE iEncontrado INTEGER;
DEFINE cArchivoOrigenAnt CHAR(23);
DEFINE cArchivoOrigen CHAR(3);

-- Variables de Detalle
DEFINE cNumTarjeta CHAR(16);
DEFINE cTipoOperacion CHAR(5);
DEFINE cMotivo CHAR(61);
DEFINE cNomcomercio CHAR(30);
DEFINE cReferencia CHAR(40);
DEFINE mMonto325 MONEY;
DEFINE mMontocashbackarchivo MONEY;
DEFINE iProceso SMALLINT;

/* INICIALIZACION DE VARIABLES */
--CONTROL GENERAL
LET cCodret = '00000';
LET cTipoArchivo = '';
LET cNombrearchivo = '';
LET cFechacarga = CURRENT::DATE;
LET iDevrecibidas = 0;
LET iDevaplicadas = 0;
LET iDevaplicadasforzadas = 0;
LET iDevconciliadasSA = 0;
LET iDevErrorIntegridad = 0;
LET iDevFaltantes = 0;
LET iEncontrado = 0;
LET cArchivoOrigenAnt = '';
LET cArchivoOrigen = '';

-- Variables de Detalle
LET cNumTarjeta = '';
LET cTipoOperacion = '';
LET cMotivo = '';
LET cNomcomercio = '';
LET cReferencia = '';
LET mMonto325 = 0.0;
LET mMontocashbackarchivo = 0.0;
LET iProceso = 0;

BEGIN
	
ON EXCEPTION SET iDevrecibidas 
   IF iDevrecibidas != 0 THEN
      LET cCodret = iDevrecibidas;      
      RETURN cCodret,cTipoArchivo, cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
				cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/home/sysifx/ilse/cashBack/sp_concreing_pba.txt';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF piTipoArchivo = 1 THEN -- Todos los tipos de archivos
	
		SET ISOLATION TO DIRTY READ;
		
		FOREACH SELECT *
			INTO cNombrearchivo,cFechacarga,cArchivoOrigen,iProceso
			FROM(
				SELECT distinct(nomarchivo),fecha,archivoorigen,1
				FROM bditarjeta:"informix".td_devolucionespos 
				WHERE archivoorigen IN('VIC','VNC','VID','VND','MCD','MCC') AND fecha = psFechaConsulta 
				UNION
				SELECT distinct(nombrearchivo),fecha_archivo,archivo_origen,2
				FROM bditarjeta:"informix".td_archivos_conciliacion WHERE fecha_archivo = psFechaConsulta 
				AND fecha_hora_fin_proceso > '1900-01-01 00:00:00.0' AND archivo_origen IN('VIC','VNC','VID','VND') 
				AND nombrearchivo NOT IN (select nomarchivo	from bditarjeta:"informix".td_devolucionespos where fecha = psFechaConsulta))
				ORDER BY 4
		
			IF iProceso = 1 THEN
			
				LET iEncontrado = 0;
					
				-- Archivos con devoluciones pendientes(Crédito o Débito).
				IF EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos WHERE nomarchivo = cNombreArchivo 
							AND fecha = psFechaConsulta AND archivoorigen = cArchivoOrigen 
							AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
								(encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN	-- (tipo_conciliación 0,10,12 y 15)
				
					IF(iEncontrado = 0 OR cArchivoOrigen <> cArchivoOrigenAnt) THEN
						IF cArchivoOrigen IN('VIC','VNC','MCC') THEN
							IF iEncontrado = 0 THEN					
								LET cTipoArchivo = 'Archivo de crédito con devoluciones pendientes';
								LET iEncontrado= 1;
								LET cArchivoOrigenAnt = cArchivoOrigen;
							END IF;
						ELIF cArchivoOrigen IN('VID','VND','MCD') THEN
							IF iEncontrado = 0 THEN
								LET cTipoArchivo = 'Archivo de débito con devoluciones pendientes';
								LET iEncontrado = 1;
								LET cArchivoOrigenAnt = cArchivoOrigen;
							END IF;
						END IF;
							
						-- Total Devoluciones Recibidas.
						SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
						WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
						
						-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
						SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
						WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
						
						-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
						SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
						WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
						
						-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
						SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
						WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
						
						-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
						SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
						WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
						
						-- Total Devoluciones Faltantes.
						SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
						FROM bditarjeta:"informix".td_devolucionespos;
						
						IF iDevrecibidas > 0 THEN
							LET cCodRet = '00001';
						END IF;
					END IF;
				ELSE	-- Archivos sin devoluciones(Crédito o Débito).
					IF cArchivoOrigen IN('VIC','VNC','MCC') THEN
						LET cTipoArchivo = 'Archivo de crédito sin devoluciones pendientes';
					ELIF cArchivoOrigen IN('VID','VND','MCD') THEN
						LET cTipoArchivo = 'Archivo de débito sin devoluciones pendientes';
					END IF;
						
					-- Total Devoluciones Recibidas.
					SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
					
					-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
					SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
					
					-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
					SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
					
					-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
					SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
					
					-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
					SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
					WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
					
					-- Total Devoluciones Faltantes.
					SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
					FROM bditarjeta:"informix".td_devolucionespos;
					
					IF iDevrecibidas > 0 THEN
						LET cCodRet = '00001';
					END IF;
				END IF;
			ELIF iProceso = 2 THEN
				IF( cArchivoOrigen = 'VIC' OR cArchivoOrigen = 'VNC' OR cArchivoOrigen = 'MCC') THEN
					LET cTipoArchivo = 'Archivo de crédito sin devoluciones';
					LET iDevrecibidas = 0;
					LET iDevaplicadas = 0;
					LET iDevaplicadasforzadas = 0;
					LET iDevconciliadasSA = 0;
					LET iDevErrorIntegridad = 0;
					LET iDevFaltantes = 0;
					LET cCodRet = '00001';
					
				ELIF( cArchivoOrigen = 'VID' OR cArchivoOrigen = 'VND' OR cArchivoOrigen = 'MCD') THEN
					LET cTipoArchivo = 'Archivo de débito sin devoluciones';
					LET iDevrecibidas = 0;
					LET iDevaplicadas = 0;
					LET iDevaplicadasforzadas = 0;
					LET iDevconciliadasSA = 0;
					LET iDevErrorIntegridad = 0;
					LET iDevFaltantes = 0;
					LET cCodRet = '00001';
					
				END IF;
			END IF;
			
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;

		END FOREACH;
	
	ELIF piTipoArchivo = 2 THEN -- Archivos de crédito con devoluciones pendientes
		
		FOREACH WITH HOLD
			SELECT SKIP pRegistros FIRST pRecuperacion distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VIC','VNC','MCC') AND fecha = psFechaConsulta 
			AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
				 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) -- (tipo_conciliación 0,10,12 y 15)
						
			LET cTipoArchivo = 'Archivo de crédito con devoluciones pendientes';
			
			-- Total Devoluciones Recibidas.
			SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
			
			-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
			SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
			
			-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
			SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
			
			-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
			SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
			
			-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
			SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
			
			-- Total Devoluciones Faltantes.
			SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
			FROM bditarjeta:"informix".td_devolucionespos;
									
			IF iDevrecibidas > 0 THEN
				LET cCodRet = '00001';
			END IF;
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
		END FOREACH;
		
	ELIF piTipoArchivo = 3 THEN -- Archivos de crédito sin devoluciones pendientes
				
		IF NOT EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos 
						WHERE archivoorigen IN('VIC','VNC','MCC') AND fecha = psFechaConsulta 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							(encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN
		
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
				FROM bditarjeta:"informix".td_devolucionespos 
				WHERE archivoorigen IN('VIC','VNC','MCC') AND fecha = psFechaConsulta 
				AND((encontrado = 'V' AND estado = 'F' AND aplicado = 'V') OR 
					(encontrado = 'V' AND estado = 'A' AND aplicado = 'V')) -- (tipo_conciliacion 11 y 14)
					
				LET cTipoArchivo = 'Archivo de crédito sin devoluciones pendientes';
				
				-- Total Devoluciones Recibidas.
				SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
				
				-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
				SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
				
				-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
				SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
				
				-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
				SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
				
				-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
				SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
				
				-- Total Devoluciones Faltantes.
				SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
				FROM bditarjeta:"informix".td_devolucionespos;
				
				IF iDevrecibidas > 0 THEN
					LET cCodRet = '00001';
				END IF;
				
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END FOREACH;
		END IF;
	
	ELIF piTipoArchivo = 4 THEN -- Archivos de débito con devoluciones pendientes
	
		FOREACH WITH HOLD
			SELECT SKIP pRegistros FIRST pRecuperacion distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VID','VND','MCD') AND fecha = psFechaConsulta 
			AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
				 (encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) -- (tipo_conciliación 0,10,12 y 15)
			
			LET cTipoArchivo = 'Archivo de débito con devoluciones pendientes';
			
			-- Total Devoluciones Recibidas.
			SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
			
			-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
			SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
			
			-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
			SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
			
			-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
			SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
			
			-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
			SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
			
			-- Total Devoluciones Faltantes.
			SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
			FROM bditarjeta:"informix".td_devolucionespos;
					
			IF iDevrecibidas > 0 THEN
				LET cCodRet = '00001';
			END IF;
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
		END FOREACH;
	
	ELIF piTipoArchivo = 5 THEN -- Archivos de débito sin devoluciones pendientes
				
		IF NOT EXISTS( SELECT nomarchivo FROM bditarjeta:"informix".td_devolucionespos 
						WHERE archivoorigen IN('VID','VND','MCD') AND fecha = psFechaConsulta 
						AND ((encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E')) OR 
							(encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F'))) ) THEN
		
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
				FROM bditarjeta:"informix".td_devolucionespos 
				WHERE archivoorigen IN('VID','VND','MCD') AND fecha = psFechaConsulta 
				AND((encontrado = 'V' AND estado = 'F' AND aplicado = 'V') OR 
					(encontrado = 'V' AND estado = 'A' AND aplicado = 'V')) -- (tipo_conciliacion 11 y 14)
							
				LET cTipoArchivo = 'Archivo de débito sin devoluciones pendientes';
				
				-- Total Devoluciones Recibidas.
				SELECT COUNT(nomarchivo) INTO iDevrecibidas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombreArchivo AND fecha = psFechaConsulta;
				
				-- Total Devoluciones Aplicadas (tipo_conciliacion = 14).
				SELECT COUNT(nomarchivo) INTO iDevaplicadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'A' AND aplicado = 'V';
				
				-- Total Devoluciones Aplicadas Forzadas (tipo_conciliacion = 11).
				SELECT COUNT(nomarchivo) INTO iDevaplicadasforzadas FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado = 'F' AND aplicado = 'V';
				
				-- Total Devoluciones Conciliadas sin Aplicar (tipo_conciliacion 10 y 15).
				SELECT COUNT(nomarchivo) INTO iDevconciliadasSA FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'V' AND estado IN('P','A','F') AND aplicado IN('F','E');
				
				-- Total Devoluciones con Error de Integridad (tipo_conciliacion 0 y 12).
				SELECT COUNT(nomarchivo) INTO iDevErrorIntegridad FROM bditarjeta:"informix".td_devolucionespos 
				WHERE nomarchivo = cNombrearchivo AND fecha = psFechaConsulta AND encontrado = 'F' AND estado = 'P' AND aplicado IN('E','F');
				
				-- Total Devoluciones Faltantes.
				SELECT FIRST 1 iDevrecibidas - ( iDevaplicadas + iDevaplicadasforzadas ) INTO iDevFaltantes 
				FROM bditarjeta:"informix".td_devolucionespos;
				
				IF iDevrecibidas > 0 THEN
					LET cCodRet = '00001';
				END IF;
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END FOREACH;
		END IF;
	
	ELIF piTipoArchivo = 6 THEN -- Datos Detalle
	
		FOREACH WITH HOLD		
			SELECT SKIP pRegistros FIRST pRecuperacion numtarjeta,fecha,nomcomercio,referencia,montoarchivo,motivo,montocashbackarchivo
			INTO cNumTarjeta,cFechacarga,cNomcomercio,cReferencia,mMonto325,cMotivo,mMontocashbackarchivo
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE nomarchivo = psNombreArchivo AND fecha = psFechaConsulta
			
			LET cTipoOperacion = 'ABONO'; -- Valor por Default.
			LET cCodret = '00001';
					
			RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
					cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END FOREACH;
	END IF;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Arturo Méndez Cárdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Fecha: 2012/04/12',
'Version: 20120412.1605',
'BD: BdiTarjeta',
'',
'MODIFICACION: Arturo Méndez Cárdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Fecha: 2012/05/23',
'Version: 20120523.1542',
'BD: BdiTarjeta',
'',
'MODIFICACION: Arturo Méndez Cárdenas',
'Proyecto: ReingenieriaConciliacionAutomatica',
'Solicito: Jose Luis Puebla',
'Cambio: Se modifica para obtener archivos sin devoluciones',
'Fecha: 2012/06/22',
'Version: 20120622.0845',
'BD: BdiTarjeta',
'',
'MODIFICACION: Gómez Pérez Ilse Jazmín',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Cambio: Se integra un nuevo campo al proceso de estracción, para retornar el monto de transacciones Cash Back.',
'Fecha: 2013/08/27',
'Version: 20130821.1441',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Conciliacion MasterCard',
'Solicito: Luis Antonio Gomez',
'Cambio: Se integra archivos MCD y MCC para el procesos de clasificacion de ',
'Fecha: 2014/04/04',
'Version: 20140404.1322',
'BD: BdiTarjeta',
'',
'MODIFICACION: Oscar Flores Conde',
'Proyecto: SOCWEB - Conciliacion MasterCard',
'Cambio: Se agrega el manejo de paginación de registros',
'Fecha: 2015/08/24',
'Version: 20140404.1322',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultaarchivosconciliacion2_totales (pFecha DATE)
	RETURNING CHAR(5), INTEGER;

        DEFINE cod_ret      CHAR(5);
        DEFINE sql_err      SMALLINT;
		DEFINE v_registros   INTEGER;
                
        LET cod_ret       = "000";
        LET sql_err       = "";
		LET v_registros   = 0;
        
	BEGIN

		ON EXCEPTION SET sql_err
			LET cod_ret = sql_err;
			RETURN    cod_ret, v_registros;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 10;

		--CONSULTA DE ARCHIVOS DE CONCILIACION CORRESPONDIENTES A LA FECHA
		SELECT COUNT(*)
		INTO v_registros
		FROM bditarjeta:'informix'.td_archivos_conciliacion 
		WHERE proceso <> 'T';
		--WHERE fecha_proceso = pFecha
		--AND proceso IN ('P', 'F')

		RETURN  cod_ret, v_registros;


	END;
END PROCEDURE
DOCUMENT
'AUTOR: Adilene Lara Armenta',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: Funcion de Consulta de Archivos de conciliacion.',
'Fecha: 2011/10/12',
'Version: 20110622.1125',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA EL FILTRO DE LA CONSULTA, SE REALIZA SOLAMENTE POR PRECESO <> V.',
'Fecha: 2012/03/13',
'Version: 20120313.1000',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA EL FILTRO DE LA CONSULTA, SE REALIZA SOLAMENTE POR PRECESO <> T.',
'Fecha: 2012/03/14',
'Version: 20120325.1110',
'BD: BdiTarjeta',
'',
'MODIFICACION: Oscar Flores Conde',
'Proyecto: Conciliacion - SOCWEB',
'Solicito: Jose Luis Puebla',
'Descripcion: Cuenta el numero de registros a devolver',
'Fecha: 2015/08/19',
'Version: 20150819.1032',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultaarchivosconciliacion2 (pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
					RETURNING CHAR(5), CHAR(30), CHAR(5),  CHAR(1), DATE;

	--Definición de Variables
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	DEFINE v_nombre_archivo         CHAR(30);
	DEFINE v_archivo_origen            CHAR(5);
	DEFINE v_proceso                        CHAR(1);
	DEFINE v_fecha_archivo            DATE;

	--Inicializacion de Variables
	LET cod_ret       = "000";
	LET sql_err       = "";
	LET v_nombre_archivo        = "";
	LET v_archivo_origen        = "";
	LET v_proceso      = "";
	LET v_fecha_archivo     = '01-01-1900';

	BEGIN

		ON EXCEPTION SET sql_err
			LET cod_ret = sql_err;
			RETURN    cod_ret, "", "", "", '01-01-1900';
		END EXCEPTION;

		SET LOCK MODE TO WAIT 10;
		--CONSULTA DE ARCHIVOS DE CONCILIACION CORRESPONDIENTES A LA FECHA
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion nombrearchivo, archivo_origen, proceso, fecha_archivo
			INTO   v_nombre_archivo, v_archivo_origen, v_proceso, v_fecha_archivo 
			FROM bditarjeta:'informix'.td_archivos_conciliacion 
			WHERE proceso <> 'T'
			--WHERE fecha_proceso = pFecha
			--AND proceso IN ('P', 'F')


			RETURN  cod_ret, NVL(v_nombre_archivo, ""), NVL(v_archivo_origen, ""), NVL(v_proceso, ""), 
			NVL(v_fecha_archivo, '01-01-1900')  WITH RESUME;

		END FOREACH;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: Adilene Lara Armenta',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: Funcion de Consulta de Archivos de conciliacion.',
'Fecha: 2011/10/12',
'Version: 20110622.1125',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA EL FILTRO DE LA CONSULTA, SE REALIZA SOLAMENTE POR PRECESO <> V.',
'Fecha: 2012/03/13',
'Version: 20120313.1000',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA EL FILTRO DE LA CONSULTA, SE REALIZA SOLAMENTE POR PRECESO <> T.',
'Fecha: 2012/03/14',
'Version: 20120325.1110',
'BD: BdiTarjeta',
'',
'MODIFICACION: Oscar Flores Conde',
'Proyecto: Conciliacion - SOCWEB',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega el paginado para recuperación de registros',
'Fecha: 2015/08/18',
'Version: 20150818.1915',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultausuario (psCve_usuario char(10))

returning 	varchar(5) as codigo,
			varchar(50) as mensaje_respuesta,
			varchar(90) as nombre_colaborador;

define vscodigo char(5);
define vsmensaje_respuesta char(50);
define vsnombre_colaborador char (90);
define visqlerr integer ;

begin
	on exception set visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

	return 
				visqlerr, 
				NVL (vsmensaje_respuesta, ''),
				NVL (vsnombre_colaborador,'');

	end exception;
	
--SET DEBUG FILE TO '/informix/HomeInformix/rrm/consultausuario.out';
--TRACE ON;

let vscodigo = '';
let vsnombre_colaborador = '';

if not exists (select * from Bdinteg:"informix".si_ejecut where ejecutivo = psCve_usuario ) then 
	let vscodigo = '00001';
	let vsmensaje_respuesta = 'El colaborador no existe alta no procede';
else
	set isolation to dirty read;
	select nombre into vsnombre_colaborador from Bdinteg:si_ejecut where ejecutivo = psCve_usuario;
	let vscodigo = '00000';
	let vsmensaje_respuesta = 'El colaborador existe';
end if;

RETURN 
		NVL(vsCodigo, ''),
		NVL(vsmensaje_respuesta, ''),
		NVL (vsnombre_colaborador,'');
End 
End Procedure
Document
'Creado: L.I.A. Ricardo Resendiz Martinez',
'Proyecto : Migracion de Font End de SIF a SOC de Conciliacion',
'Solicito: Jose Luis Puebla',
'Fecha: 2015-0924',
'Version : 20150904.1015';

CREATE PROCEDURE "informix".sp_concreing_monarchcr2_totales(psFlag CHAR(1), psUsuario CHAR(8), pdFecha DATE)
	RETURNING CHAR(5), INTEGER;

--***********************************************************************************************************
-- DESCRIPCION: Realiza consulta para obtener detalle de los archivos de conciliacion, y para realizar
--              un paro de emergencia en caso de necesitarse.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/10/24
-- BD: bditarjeta
-- SISTEMA : Conciliacion Reingenieria
--***********************************************************************************************************

DEFINE dtfecha_hoy_integral             DATE;
DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE vNoRegistros INTEGER;

LET dtfecha_hoy_integral = CURRENT::DATE;
LET vsCodRet = "00000";
LET viSqlErr = 0;
LET vNoRegistros = 0;

--SET DEBUG FILE TO "/dbexport/sp_concreing_monarchcr.sql";
--TRACE ON;

BEGIN

	ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
        IF viSqlErr <> 0 THEN
                RETURN viSqlErr, vNoRegistros;
        END IF;
	END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        --OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
        SELECT LIMIT 1 Fecha_Hoy INTO dtfecha_hoy_integral FROM bdinteg:"informix".Si_Fechas;

        --Obtiene registros de tabla con proceso diferente a V.
        IF(psFlag = "1")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;

				SELECT COUNT(*)
				INTO
				vNoRegistros
				FROM bditarjeta:"informix".td_archivos_conciliacion 
				WHERE Proceso <> 'T' 
				OR Fecha_Proceso = dtfecha_hoy_integral;

				RETURN vsCodRet, vNoRegistros;
        --Obtiene registros con proceso igual a P.
        ELIF (psFlag = "2")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
				
				SELECT COUNT(*)
				INTO vNoRegistros
				FROM bditarjeta:"informix".td_archivos_conciliacion AS archcon LEFT JOIN BdiTarjeta:"informix".td_archivo_origentmp AS archori
				ON archcon.archivo_origen = archori.archivo_origen
				WHERE proceso = 'P';
								
				RETURN vsCodRet, vNoRegistros;
        END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: Oscar Flores Conde',
'Proyecto: Conciliacion - SOCWEB',
'Descripcion: Conteo de numero de registros a devolver por las consultas',
'Fecha: 2015/09/07',
'Version: 20150907.1152',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_concreing_monarchcr2(psFlag CHAR(1), psUsuario CHAR(8), pdFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5), CHAR(23), CHAR(3), CHAR(20), CHAR(10), CHAR(16), CHAR(10), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25), CHAR(25),
		CHAR(1), CHAR(1), CHAR(1), CHAR(20), CHAR(16), CHAR(20), CHAR(16), CHAR(1), INTEGER, INTEGER;

--***********************************************************************************************************
-- DESCRIPCION: Realiza consulta para obtener detalle de los archivos de conciliacion, y para realizar
--              un paro de emergencia en caso de necesitarse.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/10/24
-- BD: bditarjeta
-- SISTEMA : Conciliacion Reingenieria
--***********************************************************************************************************

DEFINE vsnombrearchivo                  CHAR(23);
DEFINE vsarchivo_origen                 CHAR(3);
DEFINE vsnum_registros325                       CHAR(20);
DEFINE vsfecha_archivo                  CHAR(10);
DEFINE vsmonto325                                       CHAR(16);
DEFINE vsfecha_proceso                  CHAR(10);
DEFINE vsfecha_hora_transferencia       CHAR(25);
DEFINE vsfecha_hora_ini_proceso CHAR(25);
DEFINE vsfecha_hora_carga_archivo       CHAR(25);
DEFINE vsfecha_hora_carga_tabla CHAR(25);
DEFINE vsfecha_hora_ini_concilia_reg    CHAR(25);
DEFINE vsfecha_hora_fin_concilia_reg    CHAR(25);
DEFINE vsfecha_hora_fin_proceso CHAR(25);
DEFINE vsfecha_hora_gen_conadmin        CHAR(25);
DEFINE vstransferencia                  CHAR(1);
DEFINE vscarga                                  CHAR(1);
DEFINE vsconadmin                                       CHAR(1);
DEFINE vsnum_cargo                              CHAR(20);
DEFINE vsmonto_cargo                            CHAR(16);
DEFINE vsnum_abono                              CHAR(20);
DEFINE vsmonto_abono                            CHAR(16);
DEFINE vsproceso                                        CHAR(1);
DEFINE dtfecha_hoy_integral             DATE;
DEFINE viordenproceso                   INTEGER;
DEFINE vicron                                   INTEGER;

DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;

LET vsnombrearchivo = "";
LET vsarchivo_origen = "";
LET vsnum_registros325 = "";
LET vsfecha_archivo = "";
LET vsmonto325 = "";
LET vsfecha_proceso = "";
LET vsfecha_hora_transferencia = "";
LET vsfecha_hora_ini_proceso = "";
LET vsfecha_hora_carga_archivo = "";
LET vsfecha_hora_carga_tabla = "";
LET vsfecha_hora_ini_concilia_reg = "";
LET vsfecha_hora_fin_concilia_reg = "";
LET vsfecha_hora_fin_proceso = "";
LET vsfecha_hora_gen_conadmin = "";
LET vstransferencia = "";
LET vscarga = "";
LET vsconadmin = "";
LET vsnum_cargo = "";
LET vsmonto_cargo = "";
LET vsnum_abono = "";
LET vsmonto_abono = "";
LET vsproceso = "";
LET dtfecha_hoy_integral = CURRENT::DATE;
LET viordenproceso = 0;
LET vicron = 0;

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_concreing_monarchcr.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
        IF viSqlErr <> 0 THEN
                RETURN viSqlErr, vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
                           vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
                           vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
                           vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso, 0, 0;
        END IF;
END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        --OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
        SELECT LIMIT 1 Fecha_Hoy INTO dtfecha_hoy_integral FROM bdinteg:"informix".Si_Fechas;

        --Obtiene registros de tabla con proceso diferente a V.
        IF(psFlag = "1")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion
                        nombrearchivo, archivo_origen, num_registros325, fecha_archivo, monto325, fecha_proceso,
                        fecha_hora_transferencia, fecha_hora_carga_tabla /*fecha_hora_ini_proceso*/, fecha_hora_carga_archivo, fecha_hora_carga_tabla,
                        fecha_hora_ini_concilia_reg, fecha_hora_fin_concilia_reg, fecha_hora_fin_proceso, fecha_hora_gen_conadmin,
                        transferencia, carga, conadmin, num_cargo, monto_cargo, num_abono, monto_abono, proceso
                        INTO
                        vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
                        vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
                        vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
                        vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso
                        FROM bditarjeta:"informix".td_archivos_conciliacion 
                        WHERE Proceso <> 'T' 
                        OR Fecha_Proceso = dtfecha_hoy_integral
                        ORDER BY proceso

                        RETURN vsCodRet, vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
                                   vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
                                   vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
                                   vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso, 0, 0 WITH RESUME;
                END FOREACH
        --Obtiene registros con proceso igual a P.
        ELIF (psFlag = "2")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion
                        archori.orden_proceso, 
                        (CASE WHEN archcon.fecha_archivo = (dtfecha_hoy_integral::DATE - archori.dias_desfase)::DATE THEN archori.horario_ejecucion_hoy ELSE archori.horario_ejecucion_ext END) AS cron,
                        archcon.nombrearchivo, archcon.archivo_origen, archcon.fecha_hora_carga_tabla /*archcon.fecha_hora_ini_proceso*/, archcon.fecha_hora_carga_archivo, archcon.fecha_hora_carga_tabla, archcon.fecha_hora_ini_concilia_reg,
                        archcon.fecha_hora_fin_concilia_reg, archcon.fecha_hora_fin_proceso, archcon.fecha_hora_gen_conadmin, archcon.carga, archcon.conadmin, archcon.proceso
                        INTO
                        viordenproceso, vicron, vsnombrearchivo, vsarchivo_origen, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla, vsfecha_hora_ini_concilia_reg, 
                        vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin, vscarga, vsconadmin, vsproceso
                        FROM bditarjeta:"informix".td_archivos_conciliacion AS archcon LEFT JOIN BdiTarjeta:"informix".td_archivo_origentmp AS archori
                        ON archcon.archivo_origen = archori.archivo_origen
                        WHERE proceso = 'P'
                        ORDER BY cron, archori.orden_proceso
                                        
                        RETURN vsCodRet, vsnombrearchivo, vsarchivo_origen, '', '', '', '', '', vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, 
                                        vsfecha_hora_carga_tabla, vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, 
                                        vsfecha_hora_gen_conadmin, '', vscarga, vsconadmin, '', '', '', '', vsproceso, viordenproceso, vicron WITH RESUME;
                END FOREACH
                
        --Actualiza en F la conciliacion automatica en caso de paro de emergencia e inserta en bitacora hora, actividad, usuario.
        ELIF (psFlag = "3")THEN
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
                UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = 'F' WHERE codigo = '002';
                EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (8, 'PARO DE EMERGENCIA EN CONCILIACION AUTOMATICA', psUsuario) INTO vsCodRet;
                RETURN vsCodRet, vsnombrearchivo, vsarchivo_origen, vsnum_registros325, vsfecha_archivo, vsmonto325, vsfecha_proceso,
                           vsfecha_hora_transferencia, vsfecha_hora_ini_proceso, vsfecha_hora_carga_archivo, vsfecha_hora_carga_tabla,
                           vsfecha_hora_ini_concilia_reg, vsfecha_hora_fin_concilia_reg, vsfecha_hora_fin_proceso, vsfecha_hora_gen_conadmin,
                           vstransferencia, vscarga, vsconadmin, vsnum_cargo, vsmonto_cargo, vsnum_abono, vsmonto_abono, vsproceso, 0, 0;
        END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: Realiza consulta para obtener detalle de los archivos de conciliacion, y para realizar un paro de emergencia en caso de necesitarse.',
'Fecha: 2011/10/24',
'Version: 20111024.1800',
'BD: bditarjeta',
'',
'MODIFICADO: Casanova Edeza Hector Juan',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: Se quito el campo fecha de los criterios de busqueda y se dejo solamente el campo proceso.',
'Fecha: 2012/03/17',
'Version: 20120317.1557',
'BD: bditarjeta',
'',
'MODIFICADO: Casanova Edeza Hector Juan',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: SE MODIFICO EL CRITERIO DEL FILTRO PARA LA CONSULTA DE LOS ARCHIVOS PENDIENTES QUE CORRESPONDAN CON EL DIA ACTUAL, ADEMAS SE CAMBIA LA FECHA INI_PROCESO POR LA DE CARGA_ARCHIVO, PARA INDICAR EL INICIO DE TRABAJO DE CADA ARCHIVO.',
'Fecha: 2012/06/27',
'Version: 20120627.1637',
'BD: bditarjeta',
'',
'MODIFICADO: Oscar Flores Conde',
'Proyecto: Conciliacion - SOCWEB',
'Descripcion: Se agregan parametros para el manejo de paginado en la consulta',
'Fecha: 2015/09/07',
'Version: 20150907.1152',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_concreing_movimientosretenidos2_totales ( pTipo CHAR(1), pdtFechaIni DATE, pdtFechaFin DATE)
RETURNING CHAR(5), INTEGER;

--************************************************************
-- Creado por Adilene Lara Armenta.
--12/ 10/2011
-- Funcion de Consulta de movimientos retenidos pendientes por liberar de cheques & credito.
-- Hector Juan Casanova Edeza -- 22/05/2012 -SE MODIFICO LA LOGICA DEL PROCEDIMIENTO PARA QUE HACEPTE LOS PARAMETROS DE FECHA INICIAL Y FINAL PARA ACOTAR EL ESPACIO DE BUSQUEDA DE LA CONSULTA.
-----------------------------------------------------------------------------

--DefiniciÃ³n de Variables
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	DEFINE vNoRegistros INTEGER;
	
--Inicializacion de Variables

	LET cod_ret       = "000";
	LET sql_err       = "";
    LET vNoRegistros = 0;
	
BEGIN

--Control de Errores 

ON EXCEPTION SET sql_err
  LET cod_ret = sql_err;
  RETURN cod_ret, vNoRegistros;
END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/Tracemovimientosretenidos.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--CONSULTA DE MOVIMIENTOS RETENIDOS PENDIENTES POR LIBERAR

	SELECT COUNT(*)					
	INTO vNoRegistros
	FROM bditarjeta:"informix".td_retenidos
	WHERE tipo = NVL(pTipo,'')
	AND fecha_retencion BETWEEN NVL(pdtFechaIni, '01/01/1900') AND NVL(pdtFechaFin, '01/01/1900');
	
	RETURN 	cod_ret, vNoRegistros;
	
END;
END PROCEDURE;