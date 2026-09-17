CREATE PROCEDURE "informix".sp_dicta_consultactesdictamen_hawk2(pTipoConsulta CHAR(1), pSucursal CHAR(4), pFechaIni DATE, pFechaFin DATE, pNumCte CHAR(20), pTipoDictamen CHAR(1), pAnalista CHAR(8))
		--RETORNOS
		RETURNING
		CHAR(6)		AS CodRet,
		DATETIME YEAR TO SECOND AS FechaAlerta,
		DATETIME YEAR TO SECOND AS FechaAtendida,
		SMALLINT	AS Coincidencias,
		CHAR(4)		AS NumSucursal,
		CHAR(8)		AS NumEmpProm,
		CHAR(45)	AS NombrePromotor,
		CHAR(20)	AS NumCte,
		CHAR(100)	AS NomCte,
		CHAR(8)		AS EmpAnalista,
		CHAR(45)	AS NomAnalista,
		CHAR(20)	AS TiempoResp,
		CHAR(20)	AS NumCteCoinc,
		--CHAR(104)	AS NombreCteCoinc,
		CHAR(25)	AS DescCoinc,
		
		CHAR(1) AS Origen,
		CHAR(30) AS DescripOrigen,
		CHAR(40) AS NomSucursal,
		CHAR(30) AS EstadoSucursal,
		CHAR(60) AS CiudadSucursal;
		

	DEFINE iSqlErr INTEGER; 
	DEFINE cCodRet CHAR(6);
	DEFINE dtFechaAlerta DATETIME YEAR TO SECOND;
	DEFINE dtFechaAtendida DATETIME YEAR TO SECOND;
	DEFINE dtFechaFinDicta	DATETIME YEAR TO SECOND;
	DEFINE cTiempoResp CHAR(20);
	DEFINE sCoincidencias SMALLINT;
	DEFINE cSucursal CHAR(4);
	DEFINE cNumEmpProm CHAR(8);
	DEFINE cNombrePromotor CHAR(45);
	DEFINE cNomAnalista CHAR(45);
	DEFINE cNumCte CHAR(20);
	DEFINE cNomCte CHAR(100);
	DEFINE cEmpAnalista CHAR(8);
	DEFINE cTipoCoinc CHAR(1);
	DEFINE cNumCteCoinc CHAR(20);
	DEFINE cTipoDictamen CHAR(1);

	DEFINE cDescCoinc CHAR(25);
	
	DEFINE dtFechaIniDicta	DATETIME YEAR TO SECOND;
	DEFINE cOrigen CHAR(1);
	DEFINE cDescripOrigen CHAR(30);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cEstadoSuc CHAR(30);
	DEFINE cCiudadSuc CHAR(60);
	
 
	--Inicializacion de variables
	LET iSqlErr = 0;
	LET cCodRet = '000000';
	LET dtFechaAlerta = '';
	LET dtFechaAtendida = '';
	LET dtFechaFinDicta = '';
	LET cTiempoResp = '00:00:00';
	LET sCoincidencias = 0;
	LET cSucursal = '';
	LET cNumEmpProm = '';
	LET cNombrePromotor = '';
	LET cNomAnalista = '';
	LET cNumCte = '';
	LET cNomCte = '';
	LET cEmpAnalista = '';
	LET cTipoCoinc			= '';
	LET cNumCteCoinc		= '';
	LET cTipoDictamen		= '';

	LET cDescCoinc			= '';

	LET dtFechaIniDicta		= '';
	LET cOrigen = '';
	LET cDescripOrigen = '';
	LET cNomSucursal = '';
	LET cEstadoSuc = '';
	LET cCiudadSuc = ''; 
	

	BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_dicta_consultactesdictamen_hawk2.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
		
	-- VALIDACIÃ?N DE CADA FUNCIONALIDAD DEL PROCEDIMIENTO.
	IF pTipoConsulta = '1' THEN -- CONSULTA POR TODOS LOS DICTAMENES REALIZADOS.
		
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = 108
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
              AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			  AND bc.origen = sc.cod_origen 
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
				
					-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)--, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				
			
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')),TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')),TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '2' AND TRIM(NVL(pSucursal,"")) <> "" THEN -- CONSULTA POR SUCURSAL.
		
	
		
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd,"informix".si_catorigenhuellas sc
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
			  AND bd.sucursal = pSucursal
              AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
              AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			  AND bc.origen = sc.cod_origen 
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
				
					-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)--, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --,cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
			
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')),TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')),TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '3' THEN -- CONSULTA POR FECHAS.
	
		IF NVL(pFechaIni, DATE(1)) = DATE(1) OR NVL(pFechaFin, DATE(1)) = DATE(1) THEN
			LET cCodRet = '000001';
		ELSE
			
			
			FOREACH
				--SELECT bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
				SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
				INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
				FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
				WHERE bc.numcte = bd.numcte
				  AND bc.status_alerta = '3'
				  AND bd.situacion = 'P' 
				  AND bd.causa = '108'
				  AND bd.fecha_dicta_ini::DATE >= pFechaIni
				  AND bd.fecha_dicta_fin::DATE <= pFechaFin
				  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
				  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
				  AND bc.origen = sc.cod_origen 
				GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
				
					-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
					SELECT nombre INTO cNombrePromotor
					FROM "informix".si_ejecut
					WHERE ejecutivo = cNumEmpProm;
					
					-- OBTENEMOS EL NOMBRE DEL ANALISTA.
					SELECT nombre INTO cNomAnalista
					FROM "informix".si_ejecut
					WHERE ejecutivo = cEmpAnalista;
					
					-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
					--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
					SELECT  {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
					FROM "informix".si_bitacora_dictamenes
					WHERE numcte = cNumCte;
					
					-- CALCULAMOS EL TIEMPO DE RESPUESTA.
					--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
					LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
					
						-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
					SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
					INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
					FROM "informix".si_cliente
					WHERE numcte = cNumCte;
					
					--OBTENEMOS LOS DATOS DE LA SUCURSAL
					SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
					INTO cNomSucursal,cEstadoSuc,cCiudadSuc
					FROM "informix".si_sucursales ss 
					INNER JOIN "informix".si_estados se ON ss.estado = se.estado
					INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
					AND ss.ciudad = sc.ciudad 
					WHERE ss.sucursal = cSucursal;
					
				
					
					RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
			END FOREACH;
			
			-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000002'; 
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
			END IF;	
		END IF;
		
	ELIF pTipoConsulta = '4' AND TRIM(pNumCte) <> ""  THEN -- CONSULTA POR CLIENTE.
		
				
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
		      AND bc.numcte = pNumCte
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			  AND bc.origen = sc.cod_origen 
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				SELECT MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
				
					-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '5' THEN -- MUESTRA TODOS LOS REGISTROS PARA EXPORTARLOS A EXCEL.
		
		FOREACH
			--SELECT bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
			  AND bc.numcte = DECODE(pNumCte, "", bc.numcte, pNumCte) 
			  AND bd.sucursal = DECODE(pSucursal, "", bd.sucursal, pSucursal)
			  AND bd.fecha_dicta_ini::DATE >= DECODE(NVL(pFechaIni, DATE(1)), DATE(1), bd.fecha_dicta_ini::DATE, pFechaIni) 
			  AND bd.fecha_dicta_fin::DATE <= DECODE(NVL(pFechaFin, DATE(1)), DATE(1), bd.fecha_dicta_fin::DATE, pFechaFin) 
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			  AND bc.origen = sc.cod_origen 
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				SELECT MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
				
						-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '6' AND TRIM(pNumCte) <> "" THEN -- DETALLE DE INFORME DE DICTAMENES.
		
	
		
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 fecha_insert, fecha_dicta_fin, sucursal, numcte, tipo, numcte_coinc, tipo_dictamen, numemp, (fecha_dicta_fin::DATETIME YEAR TO SECOND - fecha_dicta_ini::DATETIME YEAR TO SECOND)
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, bd.fecha_dicta_fin, bd.sucursal, bd.numcte, bd.tipo, numcte_coinc, bd.tipo_dictamen, bd.numemp, (bd.fecha_dicta_fin::DATETIME YEAR TO SECOND - bd.fecha_dicta_ini::DATETIME YEAR TO SECOND), bd.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, cSucursal, cNumCte, cTipoCoinc, cNumCteCoinc, cTipoDictamen, cEmpAnalista, cTiempoResp, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_dictamenes bd,"informix".si_catorigenhuellas sc
			WHERE bd.numcte = pNumCte
			AND bd.origen = sc.cod_origen 
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- CONSULTAMOS LA DESCRIPCION DEL TIPO COINCIDENCIA.
				SELECT descripcion INTO cDescCoinc
				FROM "informix".si_empresa_huella
				WHERE numempresa = cTipoCoinc;
				
					
							-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '7' AND TRIM(pNumCte) <> ""  THEN -- TOTAL DETALLE DE INFORME DE DICTAMENES PARA EXPORTAR A EXCEL.
	
		FOREACH
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, bd.fecha_dicta_fin, bd.sucursal, bd.numcte, bd.tipo, bd.numcte_coinc, bd.tipo_dictamen, bd.numemp, (bd.fecha_dicta_fin::DATETIME YEAR TO SECOND - bd.fecha_dicta_ini::DATETIME YEAR TO SECOND), bd.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, cSucursal, cNumCte, cTipoCoinc, cNumCteCoinc, cTipoDictamen, cEmpAnalista, cTiempoResp, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
			WHERE bd.numcte = pNumCte
			AND bd.origen = sc.cod_origen 
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- CONSULTAMOS LA DESCRIPCION DEL TIPO COINCIDENCIA.
				SELECT descripcion INTO cDescCoinc
				FROM "informix".si_empresa_huella
				WHERE numempresa = cTipoCoinc;
				

							-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	IF cCodRet <> '000000' THEN
		RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: 97122114, Luis Alberto Madrid Castro',
'FOLIO: 230142 - 1530  - EvaluaciÃÂ³n de Resultados de ComparaciÃÂ³n de Huellas en LÃÂ­nea en Alta de Cliente ',
'DESCRIPCION: Creacion de SP_DICTA_CONSULTADICTAMEN_HAWK., para llenar el reporte hawk',
'FECHA: 29/01/2016',
'BD:BDINTEG ';

CREATE PROCEDURE "informix".sp_cifra_archivo_medalia( pCodigo CHAR(20) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3	        CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr	        CHAR(150);
    DEFINE vUsuario         CHAR(20);
    DEFINE vLLave           CHAR(200);
    DEFINE vNomarch         CHAR(100);
    DEFINE vRutaOrigen      CHAR(100);
    DEFINE vRutaDestino     CHAR(100);
    DEFINE vNomarchSalida   CHAR(100);
    DEFINE vRutaOriginales  CHAR(100);
    DEFINE vNomarch_salida  CHAR(100);
    
    
    LET cCodRet         = '';
    LET cCodRet2        = 0;
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_medalia.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
--    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_masttro.out";
--    TRACE ON;
    
    FOREACH
        SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida), TRIM(ruta_destino), TRIM(ruta_originales)
          INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales    
          FROM bdinteg:si_configura_pgp_chq
         WHERE codigo = pCodigo
         ORDER BY secuencia
        
        IF vUsuario <> user THEN
            LET cCodRet = '200';
            RETURN cCodRet;
        END IF;
        
        SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/'||TRIM(vUsuario)||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin" > '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        SYSTEM 'echo "export HOME=/home/'||TRIM(vUsuario)||'" >> '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' -r '||''''||TRIM(vLLave)||''''||" --armor --compression --output "||TRIM(vRutaDestino)||TRIM(vNomarch_salida)||'" >> '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        SYSTEM '/usr/bin/chmod 777 '||TRIM(vRutaOrigen)||'blinda_medalia.sh';   
        SYSTEM '/usr/bin/sh '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' '||vRutaOriginales; 
    END FOREACH;
    
    LET cCodRet = '00000';
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;