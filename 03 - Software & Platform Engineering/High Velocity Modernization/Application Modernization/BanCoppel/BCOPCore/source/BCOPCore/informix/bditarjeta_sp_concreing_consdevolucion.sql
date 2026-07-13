CREATE PROCEDURE "informix".sp_concreing_consdevolucion( piTipoArchivo INTEGER, psFechaConsulta VARCHAR(10), psNombreArchivo VARCHAR(21))
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
	
		FOREACH WITH HOLD
			SELECT distinct(nomarchivo),fecha,archivoorigen INTO cNombrearchivo,cFechacarga,cArchivoOrigen 
			FROM bditarjeta:"informix".td_devolucionespos 
			WHERE archivoorigen IN('VIC','VNC','VID','VND','MCD','MCC') AND fecha = psFechaConsulta 
			
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
					RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
							cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
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
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END IF;
		END FOREACH;
		
		LET cNombrearchivo = '';
		LET cFechacarga = '';
		LET cArchivoOrigen = '';
		
		FOREACH WITH HOLD -- Se regresa valores en 0 para casos donde no existen devoluciones dentro de archivos.
			SELECT distinct(nombrearchivo),fecha_archivo,archivo_origen INTO cNombrearchivo,cFechacarga,cArchivoOrigen 
			FROM bditarjeta:"informix".td_archivos_conciliacion WHERE fecha_archivo = psFechaConsulta 
			AND fecha_hora_fin_proceso > '1900-01-01 00:00:00.0' AND archivo_origen IN('VIC','VNC','VID','VND') 
			AND nombrearchivo NOT IN (select nomarchivo	from bditarjeta:"informix".td_devolucionespos where fecha = psFechaConsulta)			
						
			IF( cArchivoOrigen = 'VIC' OR cArchivoOrigen = 'VNC' OR cArchivoOrigen = 'MCC') THEN
				LET cTipoArchivo = 'Archivo de crédito sin devoluciones';
				LET iDevrecibidas = 0;
				LET iDevaplicadas = 0;
				LET iDevaplicadasforzadas = 0;
				LET iDevconciliadasSA = 0;
				LET iDevErrorIntegridad = 0;
				LET iDevFaltantes = 0;
				LET cCodRet = '00001';
				
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
				
			ELIF( cArchivoOrigen = 'VID' OR cArchivoOrigen = 'VND' OR cArchivoOrigen = 'MCD') THEN
				LET cTipoArchivo = 'Archivo de débito sin devoluciones';
				LET iDevrecibidas = 0;
				LET iDevaplicadas = 0;
				LET iDevaplicadasforzadas = 0;
				LET iDevconciliadasSA = 0;
				LET iDevErrorIntegridad = 0;
				LET iDevFaltantes = 0;
				LET cCodRet = '00001';
				
				RETURN cCodret,cTipoArchivo,cNombrearchivo,cFechacarga,iDevrecibidas,iDevaplicadas,iDevaplicadasforzadas,iDevconciliadasSA,iDevErrorIntegridad,iDevFaltantes,
						cNumTarjeta,cTipoOperacion,cMotivo,cNomcomercio,cReferencia,mMonto325,mMontocashbackarchivo WITH RESUME;
			END IF;
		END FOREACH;
	
	ELIF piTipoArchivo = 2 THEN -- Archivos de crédito con devoluciones pendientes
		
		FOREACH WITH HOLD
			SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
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
				SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
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
			SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
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
				SELECT distinct(nomarchivo),fecha INTO cNombrearchivo,cFechacarga 
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
			SELECT numtarjeta,fecha,nomcomercio,referencia,montoarchivo,motivo,montocashbackarchivo
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
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_sorteo_sat_pba (
		pdfecha date
		)

RETURNING 
			VARCHAR (5) AS CodRet, 
			VARCHAR(250) AS Mensaje_Respuesta;

--Definición de Variables de Error
DEFINE vicodigo 			integer;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);

--Definición de Variables de Error para central
DEFINE vsCodRet2 			VARCHAR(5);
DEFINE vsPbandera		 	VARCHAR(1);



--Definición de Variables de datos archivo
DEFINE viconsecutivo		integer;
DEFINE vsperiodo			varchar(4);
DEFINE vstporeg				varchar(2);
DEFINE vsemisor				varchar(4);
DEFINE vsfecha				varchar(6);
DEFINE vstarjeta			varchar(16);
DEFINE vsmonto				varchar(12);
DEFINE vmmonto			money;
DEFINE vssecuencia			varchar(6);
DEFINE vssecuencia2		varchar(7);
DEFINE vsreferencia			varchar(12);
DEFINE vsmontopremio		varchar(12);
DEFINE vmmontopremio	money;
DEFINE vsbin				varchar(6);
DEFINE vsproducto			Varchar(1);


	
--Definicion de variables de validaciones
DEFINE vsesreferencia			varchar(1);
DEFINE vsesmonto			varchar(1);
DEFINE vsessecuencia		varchar(1);
DEFINE vsesmontopremio		varchar(1);


--Definicion variables recuperadas de Intercard
DEFINE vssecintercard		varchar(7);
DEFINE vssecextendidainter	varchar(15);
DEFINE vmmontointercard		money;
DEFINE vdFechatransaccion 	DATETIME YEAR TO FRACTION(5);
DEFINE vsrefintercard		varchar(12);
DEFINE vsstatustarjeta		varchar(3);
DEFINE vsnumerocuenta		varchar(13);
DEFINE vsreferencia23_325 	varchar(23);

DEFINE vsfoliosuc    		varchar(16);

DEFINE vsencontrado 		Char(1);

--Definición de datos centrales
DEFINE vsretcentral			varchar(5);
DEFINE vsordenabono			varchar(16);
DEFINE vscoddevolucion		varchar(1);

DEFINE vdfechahoyinte		date;


--Definicion de variable de validacion
DEFINE vsvalidacion			varchar(1);
DEFINE vsErrorIntegridad	varchar(20);
DEFINE vsobservacion		varchar(40);

--Definición de bandera de ciclo
DEFINE vsFlagEnTransaccion 	varchar(1);
DEFINE viContadorRegistros 	integer;

--Para las transacciones a ser utilizadas
DEFINE vstranaplica		 	varchar(4);

-- Para retorno de Principal de Credito
DEFINE 	g_Remanente		money;
DEFINE  g_IntMoraCob   	money;
DEFINE  g_IntVencCob	money;
DEFINE  g_CapVencCob    money;
DEFINE  g_IntVigCob		money;
DEFINE  g_CapVigCob		money;
DEFINE  g_Impuesto		money;
DEFINE  g_Comision		money;
DEFINE	g_Seguro		money;

-- Para generacion de archivo

DEFINE 	vsql			char (1150);
DEFINE  vsfecencabezado   char(10);
DEFINE  vicontador 		integer;
DEFINE  vscontador		char(10);
DEFINE  viincremento	integer;
DEFINE  vicontador2		integer;


BEGIN
	ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				RETURN 	vsCodRet, 
						vsMensaje_Respuesta;

	END EXCEPTION;

SET DEBUG FILE TO '/resplogifx/sp_sorteo_sat.out';
TRACE ON;

-- Inicialización de variables
LET 	vicodigo = 0;
LET		vsCodRet = '00000';
LET		vsMensaje_Respuesta = 'PROCESO TERMINADO SATISFACTORIAMENTE';

--Definición de Variables de Error para central
LET vsCodRet2 = '';
LET vsPbandera = '';

--Inicialización de Variables de datos archivo
LET 	viconsecutivo = 0;
LET 	vsperiodo = '';
LET 	vstporeg = '';
LET 	vsemisor = '';
LET 	vsfecha = '';
LET 	vstarjeta = '';
LET 	vsmonto = '';
LET 	vmmonto	= 0;
LET vssecuencia	= '';
LET vssecuencia2 = '';
LET vsreferencia = '';
LET vsmontopremio = '';
LET vmmontopremio = 0;
LET vsbin = '';
LET vsproducto = '';
	
--Inicilaizacion de variables de validacion

LET vsesreferencia	= '';
LET vsesmonto = '';
LET vsessecuencia = '';
LET vsesmontopremio = '';


--Inicializacion variables recuperadas de Intercard
LET vssecintercard = '';
LET vssecextendidainter = '';
LET vmmontointercard = 0;
LET vdFechatransaccion 	= CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsrefintercard = '';
LET vsstatustarjeta = '';
LET vsnumerocuenta = '';
LET vsreferencia23_325 = '';

LET vsfoliosuc = '';

LET vsencontrado = '';
--Inicialización de datos centrales
LET vsretcentral = '';
LET vsordenabono = '';
LET vscoddevolucion = '';


--Inicialización de variable de validacion
LET vsvalidacion = '';
LET vsErrorIntegridad = '';
LET vsobservacion = '';

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

--Para las transacciones a ser utilizadas
LET vstranaplica  = '';

-- Inicializacion de variables de retorno de credito
LET  g_Remanente 	= 0.00;
LET  g_IntMoraCob 	= 0.00;
LET  g_IntVencCob 	= 0.00;
LET  g_CapVencCob  	= 0.00;
LET  g_IntVigCob	= 0.00;
LET  g_CapVigCob 	= 0.00;
LET  g_Impuesto		= 0.00;
LET  g_Comision 	= 0.00;
LET	 g_Seguro  		= 0.00;

-- Para generacion de archivo

LET 	vsql	= '';
LET     vsfecencabezado = '';
LET 	vicontador = 0;
LET 	vscontador = '';
LET  	viincremento = 0;
LET		vicontador2 = 0;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	Select fecha_hoy into vdfechahoyinte from Bdinteg:"informix".si_fechas;
	
	if pdfecha = vdfechahoyinte then
			FOREACH WITH HOLD
				Select consecutivo, periodofiscal, tporeg, banemisor, fechatransaccion, numtarjeta, montoarchivo, secuenciaarchivo, numrefarchivo, montopremio
						into viconsecutivo, vsperiodo, vstporeg, vsemisor, vsfecha, vstarjeta, vsmonto, vssecuencia, vsreferencia, vsmontopremio 
						from Bditarjeta:"informix".tb_sorteo_sat
							where validaciones = 'V' and 
									periodofiscal = '2014' -- Actualizar periodo para ejecucion 
						
				IF (vsFlagEnTransaccion = 'F') THEN 
					BEGIN WORK;
					LET vsFlagEnTransaccion = 'V';
				END IF;
						
			--		EXECUTE PROCEDURE Bditarjeta:"informix".sp_valida_sorteosat (viconsecutivo,vstarjeta,vsmonto,vssecuencia,vsreferencia,vsmontopremio)
			--			into vsCodRet, vsMensaje_Respuesta, vsvalidacion;
						
			--			if vsCodRet <> '00000' and vsvalidacion = 'F' then
			--				RETURN 		vsCodRet, 
			--								NVL(vsMensaje_Respuesta,'');
			--			else					
								
				LET vstranaplica = (CASE 	
										WHEN TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D')	THEN '0326'
										WHEN TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') THEN '7860'
									END);
								
				EXECUTE PROCEDURE "informix".sp_busmovint_sat (vstarjeta, vssecuencia) 
						into vsCodRet, vssecintercard, vssecextendidainter, vmmontointercard, vdFechatransaccion, vsrefintercard,vsnumerocuenta ,vsstatustarjeta, vsreferencia23_325; 	
								let  vsfoliosuc	= 'i'||vssecextendidainter;
									
				if vsCodRet = '00000' then 
						update Bditarjeta:"informix".tb_sorteo_sat
								set
									secuenciaintercard = vssecintercard,
									secextendidainter = vssecextendidainter,
									montointercard = vmmontointercard,
									fchtransacintercard = vdFechatransaccion,
									numrefintercard = vsrefintercard,
									numcuenta = vsnumerocuenta,
									estatustarjeta = vsstatustarjeta,
									referencia23_325 = vsreferencia23_325,
									ordenabono = LPAD (vsfoliosuc,23,' '),
									tranaplica = vstranaplica
								where
									consecutivo = viconsecutivo;
											
						EXECUTE PROCEDURE "informix".sp_busmovdev_sat ( vstarjeta, vssecuencia )
								into vsCodRet, vsencontrado;
										
						if (vsCodRet = '00001'  and vsencontrado = 'V') then 
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'F',
									observacion = 'Movimiento fue devuelto'
								where
									consecutivo = viconsecutivo;
							LET vsvalidacion = 'F';
											
						elif (vsCodRet = '00000'  and vsencontrado = 'F') then
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'V',
									observacion = 'Movimiento aplica'
								where
									consecutivo = viconsecutivo;
							LET vsvalidacion = 'V';
						end if;
										
										/*    ###### Se comenta para quitar validaciones de los montos 11/12/2014 RRM
										if vmmontointercard <> ((vsmontopremio::MONEY)/100) then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Transaccion con montos diferentes'
												where
											consecutivo = viconsecutivo;
									
											LET vsvalidacion = 'F';
										end if;*/

						if  ((vsmontopremio::MONEY)/100) > 10000 then
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'F',
									observacion = 'Monto premio mayor a $10,000.00'
								where
									consecutivo = viconsecutivo;
											LET vsvalidacion = 'F';
						end if;
										
						if  ((vsmontopremio::MONEY)/100) = 0 then
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'F',
									observacion = 'Monto premio deber ser mayor $0.01'
								where
									consecutivo = viconsecutivo;
									LET vsvalidacion = 'F';
						end if;
										
										
						if vsstatustarjeta <> 'ACT' then
							update Bditarjeta:"informix".tb_sorteo_sat
								set
									validaciones = 'P',
									observacion = 'Tarjeta tiene estatus <> Activo'
								where
									consecutivo = viconsecutivo;
									LET vsvalidacion = 'P';		
						end if;
										
						if vsvalidacion in ('P','V') then 
						-- Se agrega proceso para la recuperacion de la direccción del Cliente premiado 
							EXECUTE PROCEDURE "informix".sp_busEdoPob_sat ( vstarjeta, viconsecutivo )
									into vsCodRet, vsencontrado;	
						end if;
				else
					update Bditarjeta:"informix".tb_sorteo_sat
						set
							secuenciaintercard = 	'000000',
							secextendidainter = 	'000000000000000',
							montointercard = 		0.0,
							fchtransacintercard = 	CAST('1900-10-10 12:00:00' AS DATETIME YEAR TO FRACTION(5)),
							numrefintercard = '0000000000000',
							numcuenta = '00000000000',
							estatustarjeta = 'NOE',
							ordenabono = '00000000000000000000000',
							tranaplica = '0000',
							validaciones = 'F',
							observacion = 'Transaccion no encontrada',
							referencia23_325 = '00000000000000000000000'
						where
							consecutivo = viconsecutivo;
							LET vsvalidacion = 'F';
				end if;
								
				COMMIT WORK;   
				BEGIN WORK;
								
				if (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D')
					and	vsvalidacion in ('P','V')) then

					execute procedure Bdicheq:"informix".abono_ref(
																	'001',						-- empresa
																	'9290',						-- sucursal
																	'informix', 				-- usuario
																	vstranaplica,				-- transaccion aplica
																	'0000', 					-- trasaccion sucursal
																	vsfoliosuc, 				-- Folio suc
																	vsnumerocuenta, 			-- numero de cuenta
																	'0', 						-- numero de documento
																	((vsmontopremio::MONEY)/100),		-- monto total
																	((vsmontopremio::MONEY)/100),		-- monto firme
																	0,							-- monto sbc
																	0,							-- monto remesa
																	0,							-- Dias retenido
																	'01',						-- divisa
																	'Premio Hacienda Buen Fin',	-- Referencia
																	' ',						-- numero de tarjeta
																	' ' 						-- usuario autoriza
																	)
						into vsCodRet;
											
					if 	vsCodRet = '000'	then
						update Bditarjeta:"informix".tb_sorteo_sat
							set
								retcentral = vsCodRet,
								codigodevolucion = '0'
							where
								consecutivo = viconsecutivo;
					else
						update Bditarjeta:"informix".tb_sorteo_sat
							set
								retcentral = vsCodRet,
								codigodevolucion = '1'
							where
								consecutivo = viconsecutivo;
					end if;
									
				elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C')
						and vsvalidacion in ('P','V'))  then
					EXECUTE PROCEDURE Bdicred:"informix".principal(
																	'001',							-- Empresa
																	vsnumerocuenta,					-- Numero de credito
																	1,								-- Tipo de pago
																	((vsmontopremio::MONEY)/100),	-- Monto
																	'informix',						-- Usuario
																	'9290',							-- Sucursal
																	vsfoliosuc,						-- Folio_suc
																	vstranaplica					-- Transaccion aplica
																	)
					into vsCodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
									
					if 	vsCodRet = '000'	then
						update Bditarjeta:"informix".tb_sorteo_sat
							set
								retcentral = vsCodRet,
								codigodevolucion = '0'
							where
								consecutivo = viconsecutivo;
					else
						update Bditarjeta:"informix".tb_sorteo_sat
							set
								retcentral = vsCodRet,
								codigodevolucion = '1'
							where
								consecutivo = viconsecutivo;
					end if;
								
				elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D') 
					and vsvalidacion in ('F'))  then
						
					update Bditarjeta:"informix".tb_sorteo_sat
						set
							retcentral = 'NP',
							codigodevolucion = '1'
						where
							consecutivo = viconsecutivo;
												
				elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') 
					and vsvalidacion in ('F'))  then
					
					update Bditarjeta:"informix".tb_sorteo_sat
						set
							retcentral = 'NP',
							codigodevolucion = '1'
						where
							consecutivo = viconsecutivo;
									
				end if;
								
	--		end if;

				LET viContadorRegistros = viContadorRegistros + 1;

				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					--BEGIN WORK;
					LET vsFlagEnTransaccion = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				END IF;
			END FOREACH;
					
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
				
			LET  vsMensaje_Respuesta = 'Etapa 1 Completa';
		--end if;
	else
			LET	vsCodRet = '00001';
			LET	vsMensaje_Respuesta = 'Existe discrepancia en Fechas integral con ejecucion de proceso';
	end if;

				
	let vsfecencabezado = day(vdfechahoyinte)||'/'||month(vdfechahoyinte)||'/'||year(vdfechahoyinte);
				
	set isolation to dirty read;
	select count(*) into vicontador from Bditarjeta:tb_sorteo_sat
		where periodofiscal = '2014';  -- Actualizar periodo para ejecucion
		
	let vscontador = vicontador::char(10);
		
	LET viincremento = Length(vscontador);
		
	For vicontador2 = viincremento  TO 9 STEP 1
			LET vscontador = '0'||vscontador;
	end for;
	
	
			
				
	-- Primera linea del archivo
	let vsql = 'echo "00|1|SAT           |FECHA|'||vsfecencabezado||'|" >> /resplogifx/EntregaSAT2014.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Para generar comando de descarga de datos -- Actualizar periodo para ejecucion
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||year(fchtransacintercard), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montopremio,ordenabono,codigodevolucion,codpostal,estado,poblacion from bditarjeta:"informix".tb_sorteo_sat where periodofiscal = ''"'||'2014'||'"'';">/resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/EntregaSAT2014.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	-- Agregando pie de archivo
	let vsql = 'echo "99|'||vscontador||'|" >> /resplogifx/EntregaSAT2014.txt';
	system vsql;
	
	LET	vsCodRet = '00000';
	LET  vsMensaje_Respuesta = 'Proceso completo se genero archivo EntregaSAT2014.txt';

	
	RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');

END 

END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso principal de proceso sorteo SAT',
'Fecha: 2013/11/20',
'Version: 20131112.1600',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso principal de proceso sorteo SAT con generacion de archivo de entrega al SAT',
'Fecha: 2013/11/26',
'Version: 20131126.1030',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se optimizo el proceso para busqueda optimizar forma de determinar la transaccion a ser aplicada',
'Fecha: 2013/11/26',
'Version: 20131126.1130',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego spl el cual pemitira validar que el movimiento no se haya devuelto',
'Fecha: 2013/11/29',
'Version: 20131129.1820',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego validaciones de monto premio',
'Fecha: 2013/12/02',
'Version: 20131202.1730',
'BD: bditarjeta',
'',
'Modifica: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrega al proceso SPL el cual se encargara de recuperar los datos de estado y poblacion',
'Fecha: 2013/12/02',
'Version: 20131202.1730',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_reporte_tarjetas_pba()
RETURNING 	CHAR (06) as cod_ret,
			CHAR (80) AS mensaje;
			
--variables de retorno
	DEFINE cod_ret CHAR(06);
	DEFINE mensaje CHAR(80);
	
 --variables de control de errores
	DEFINE  SQL_ERR			INTEGER;
	DEFINE  ISAM_ERR		INTEGER;
	DEFINE  ERROR_INFO		VARCHAR(80);			
	DEFINE	vpaso			INTEGER;	
	
--variables de proceso

	DEFINE vcont 			INTEGER;
	DEFINE vmax				datetime year to fraction(3)  ;
	
	
	--variables para datos
	                                                          
	DEFINE vbin              	char(6)                       ;
	DEFINE vcodstatustarjeta 	varchar(3)                    ;
	DEFINE vcodstatusasignada	varchar(3)                    ;
	DEFINE vtipo             	char(1)                       ;
	DEFINE vfechaexp         	varchar(4)                    ;
	DEFINE vproducto         	char(1)                       ;
	DEFINE vmarca            	char(1)                       ;
	DEFINE vtitular          	char(1)                       ;
	DEFINE vcantidad         	INTEGER                       ;
	DEFINE vfecha_ejecucion  	date                          ;
	DEFINE vfecha_exp			char(04)					  ;
	DEFINE vfecha_exp_min		char(04)					  ;
	DEFINE vfecha_exp_max		char(04)					  ;
	
--SET DEBUG FILE TO "/informix/frg/Rpts_Productos/sp_reporte_tarjetas.out";
--TRACE ON;
	
BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = SQL_ERR || ' ' || ISAM_ERR ||' en paso '|| vpaso ||' '|| ERROR_INFO ;
      RETURN cod_ret, mensaje;
	END EXCEPTION;

	let cod_ret = '00000';
	let mensaje = 'PROCESO EXITOSO';
	
	let vcont  = 0;
	
	set isolation to dirty read;
	
	SELECT {+INDEX(intercard:tarjeta idx_tarjeta2)} min(fechaexp),max(fechaexp)
	INTO vfecha_exp_min, vfecha_exp_max
	FROM intercard:tarjeta;	
	 
	let vpaso = 1;
	let vfecha_exp = lpad(substr( year(date(current)) ,3,2) ,2,'0' ) || lpad(month(date(current)),2,'0') ; 
	SELECT {+INDEX(reporte_tarjetas idx_reporte_tarjetas)} MAX(fecha_ejecucion) INTO vmax FROM reporte_tarjetas;
	
	
	IF vmax IS NOT NULL THEN
		
	 LET vfecha_exp_min = vfecha_exp;
	
	END IF
	
		foreach cursor1 WITH HOLD 
		
		for
		
				select distinct (b.bin),

					   t.codstatustarjeta,

					   t.codstatusasignada,

					  (CASE WHEN tipotar.chip = 'F' THEN 'B'

							WHEN tipotar.chip = 'V' THEN 'C'

							END) as tipo,          

					   t.fechaexp,

					   b.creditodebito as producto,      

					  (CASE WHEN SUBSTR(b.bin,1,1) = 4 THEN 'V'

							WHEN SUBSTR(b.bin,1,1) = 5 THEN 'M' END) as marca,

					  (CASE WHEN t.titular = 'T' THEN 'T'

							WHEN t.titular = 'A' THEN 'A'

							ELSE 'N' END) as titular,      

					   count(*) as cantidad,

					   date(current) as fecha_ejecucion
					   	INTO 	vbin              
							   , vcodstatustarjeta 
							   , vcodstatusasignada
							   , vtipo             
							   , vfechaexp         
							   , vproducto         							     
							   , vmarca            
							   , vtitular          
							   , vcantidad 
							   , vfecha_ejecucion
					   
							from intercard:bines as b, intercard:tarjeta as t, intercard:tipotarjeta as tipotar, intercard:lote as lt

							where b.bin = SUBSTR(t.numtarjeta,1,6)

							and t.fechaexp BETWEEN vfecha_exp_min AND vfecha_exp_max 

							  and tipotar.clave_tipotarjeta=lt.clave_tipotarjeta   

							  and t.numerolote=lt.numerolote

						group by 1,2,3,4,5,6,7,8

						order by 1,2,3,4,5,6,7,8
						
						
				     let vmarca = vmarca;
					 
				if vcont= 0 THEN
					
					BEGIN WORK;
					
				end IF
		
				let vpaso = 3;
				INSERT INTO reporte_tarjetas (bin, codstatustarjeta, codstatusasignada, tipo, fechaexp, producto, marca, titular, cantidad, fecha_ejecucion)
				VALUES( vbin, vcodstatustarjeta, vcodstatusasignada, vtipo, vfechaexp, vproducto, vmarca, vtitular, vcantidad, vfecha_ejecucion);

				let vcont = vcont + 1;      
		
				if vcont= 1000 THEN
					
					let vcont=0;            
					COMMIT WORK;
					
					
				end IF		
				
		
			end foreach;

			if vcont <> 0 THEN
					
					COMMIT WORK;
					
			end IF			
		
	
	
	  RETURN cod_ret, mensaje;	
END
END PROCEDURE;