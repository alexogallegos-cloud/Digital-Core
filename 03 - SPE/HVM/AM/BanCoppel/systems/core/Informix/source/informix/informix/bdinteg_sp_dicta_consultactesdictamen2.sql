CREATE PROCEDURE "informix".sp_dicta_consultactesdictamen2(pTipoConsulta CHAR(1),pSucursal CHAR(4), pFechaIni DATE, pFechaFin DATE, pNumCte CHAR(20), pTipoDictamen CHAR(1), pAnalista CHAR(8))
	--RETORNOS-
	RETURNING
	CHAR(6) AS CodRet,
	DATETIME YEAR TO SECOND AS FechaAlerta,
	DATETIME YEAR TO SECOND AS FechaAtendida,
	SMALLINT AS Coincidencias,
	CHAR(4) AS Sucursal,
	CHAR(8) AS NumEmpProm,
	CHAR(45) AS NombrePromotor,
	CHAR(20) AS NumCte,
	CHAR(100) AS NomCte,
	CHAR(8)	AS EmpAnalista,
	CHAR(45) AS NomAnalista,
	CHAR(20) AS TiempoResp,
	CHAR(20) AS NumCteCoinc,
	CHAR(25) AS DescCoinc,
	CHAR(1) AS Origen,
	CHAR(30) AS DescripOrigen,
	CHAR(50) AS DescDictamen;
	
	--DECLARACION DE VARIABLES--
	DEFINE iSqlErr		    INTEGER; 
	DEFINE iSamErr          SMALLINT;
	DEFINE cErrorInfo       CHAR(40);
	
	DEFINE cCodRet		    CHAR(6);
	DEFINE dtFechaAlerta	DATETIME YEAR TO SECOND;
	DEFINE dtFechaAtendida	DATETIME YEAR TO SECOND;
	DEFINE dtFechaFinDicta	DATETIME YEAR TO SECOND;
	DEFINE cTiempoResp		CHAR(20);
	DEFINE sCoincidencias	SMALLINT;
	DEFINE cSucursal		CHAR(4);
	DEFINE cNumEmpProm		CHAR(8);
	DEFINE cNombrePromotor	CHAR(45);
	DEFINE cNomAnalista		CHAR(45);
	DEFINE cNumCte			CHAR(20);
	DEFINE cNomCte			CHAR(100);
	DEFINE cEmpAnalista		CHAR(8);
	DEFINE cTipoCoinc		CHAR(1);
	DEFINE cNumCteCoinc		CHAR(20);
	DEFINE cTipoDictamen	CHAR(1);
	DEFINE cDescCoinc		CHAR(25);
	DEFINE cOrigen 			CHAR(1);
	DEFINE cDescripOrigen 	CHAR(30);
	DEFINE cDescripDict 	CHAR(50);
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr		     	= 0;
	LET iSamErr		     	= 0;
	LET cErrorInfo		    = '';
	
	LET cCodRet		        = '000000';
	LET dtFechaAlerta		= '';
	LET dtFechaAtendida		= '';
	LET dtFechaFinDicta		= '';
	LET cTiempoResp			= '00:00:00';
	LET sCoincidencias		= 0;
	LET cSucursal			= '';
	LET cNumEmpProm			= '';
	LET cNombrePromotor		= '';
	LET cNomAnalista		= '';
	LET cNumCte				= '';
	LET cNomCte				= '';
	LET cEmpAnalista		= '';
	LET cTipoCoinc			= '';
	LET cNumCteCoinc		= '';
	LET cTipoDictamen		= '';
	LET cDescCoinc			= '';
	LET cOrigen             = '';
	LET cDescripOrigen      = '';
	LET cDescripDict		= '';
	
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		LET cCodRet = iSqlErr;
		RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,''));
	END EXCEPTION;
	
	 --SET DEBUG FILE TO '/tmp/mfinis/sp_dicta_consultactesdictamen2.out';
	 --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- VALIDAMOS LOS PARAMETROS DE ENTRADA DE ACUERDO AL TIPO DE CONSULTA A REALIZAR.
	IF pTipoConsulta = '2' THEN -- CONSULTA POR SUCURSAL.	
		IF TRIM(NVL(pSucursal,"")) = "" THEN
			LET cCodRet = '000001';
		END IF
	ELIF pTipoConsulta = '3' THEN -- CONSULTA POR FECHAS.	
		IF NVL(pFechaIni, DATE(1)) = DATE(1) OR NVL(pFechaFin, DATE(1)) = DATE(1) THEN
			LET cCodRet = '000001';
		END IF
	ELIF pTipoConsulta = '4' THEN -- CONSULTA POR CLIENTE.
		IF TRIM(pNumCte) = "" THEN
			LET cCodRet = '000001';
		END IF
	ELIF pTipoConsulta = '6' THEN -- CONSULTA DETALLE DE INFORME DICTAMEN.
		IF TRIM(NVL(pNumCte,'')) = "" THEN
			LET cCodRet = '000001';
		END IF
	ELIF pTipoConsulta = '7' THEN -- TOTAL DETALLE DE INFORME DE DICTAMENES PARA EXPORTAR A EXCEL.
		IF TRIM(NVL(pNumCte,'')) = "" THEN
			LET cCodRet = '000001';
		END IF
	ELIF pTipoConsulta NOT IN('1','2','3','4','5','6','7') THEN
		LET cCodRet = '000001';
	END IF
	
	-- SI NO CUMPLE CON LOS PARAMETROS OBLIGATORIOS REGRESA CODIGO '000001'.
	IF cCodRet <> '000000' THEN
		RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,''));
	END IF
	
	-- VALIDACIÃ?Â??N DE CADA FUNCIONALIDAD DEL PROCEDIMIENTO.
	IF pTipoConsulta = '1' THEN -- CONSULTA POR TODOS LOS DICTAMENES REALIZADOS.
		
		FOREACH
			SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones AS bc
			INNER JOIN "informix".si_bitacora_dictamenes AS bd ON (bc.numcte = bd.numcte) 
			INNER JOIN "informix".si_catorigenhuellas AS sc ON (bc.origen = sc.cod_origen) 
			WHERE bc.status_alerta = '3' 
			AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			GROUP BY bc.fecha_insert, bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
				INTO cNomCte
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,''));
		END IF;	
		
	ELIF pTipoConsulta = '2' THEN -- CONSULTA POR SUCURSAL.

		FOREACH
			SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones AS bc
			INNER JOIN "informix".si_bitacora_dictamenes AS bd ON (bc.numcte = bd.numcte) 
			INNER JOIN "informix".si_catorigenhuellas AS sc ON (bc.origen = sc.cod_origen) 
			WHERE bc.status_alerta = '3'
		    AND bc.sucursal = pSucursal
			AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			GROUP BY bc.fecha_insert, bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
				INTO cNomCte
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
			  RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,''));
		END IF;	
		
	ELIF pTipoConsulta = '3' THEN -- CONSULTA POR FECHAS.

		FOREACH

			SELECT  {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones AS bc
			INNER JOIN "informix".si_bitacora_dictamenes AS bd ON (bc.numcte = bd.numcte) 
			INNER JOIN "informix".si_catorigenhuellas AS sc ON (bc.origen = sc.cod_origen) 
			WHERE bc.status_alerta = '3'
		    AND bd.fecha_dicta_ini::DATE >= pFechaIni
			AND bd.fecha_dicta_fin::DATE <= pFechaFin
			AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)

            AND bc.fecha_insert in (SELECT   MAX(bc.fecha_insert)		
			FROM "informix".si_bitacora_comparaciones AS bc
			INNER JOIN "informix".si_bitacora_dictamenes AS bd ON (bc.numcte = bd.numcte) 
			INNER JOIN "informix".si_catorigenhuellas AS sc ON (bc.origen = sc.cod_origen) 
         
			WHERE bc.status_alerta = '3'
		    AND bd.fecha_dicta_ini::DATE >= pFechaIni
			AND bd.fecha_dicta_fin::DATE <= pFechaFin
			AND bc.analista_fraudes = DECODE('', "", bc.analista_fraudes, '')  
			AND bd.tipo_dictamen = DECODE('', "", bd.tipo_dictamen, '')
            GROUP BY   bc.numcte)

			GROUP BY bc.fecha_insert, bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen
           
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
				INTO cNomCte
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,''));
		END IF;	
		
	ELIF pTipoConsulta = '4' THEN -- CONSULTA POR CLIENTE.

	--	FOREACH
		    SELECT first 1 {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen, bd.tipo_dictamen
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen, cTipoDictamen 
			FROM "informix".si_bitacora_comparaciones AS bc
			INNER JOIN "informix".si_bitacora_dictamenes AS bd ON (bc.numcte = bd.numcte) 
			INNER JOIN "informix".si_catorigenhuellas AS sc ON (bc.origen = sc.cod_origen) 
			WHERE bc.status_alerta = '3'
		    AND bc.numcte = pNumCte
			AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen) AND bc.fecha_insert = (SELECT MAX(fecha_insert) FROM "informix".si_bitacora_comparaciones WHERE numcte = pNumCte)
			GROUP BY bc.fecha_insert, bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen, bd.tipo_dictamen;
				
				--	
				SELECT descripcion 
				INTO cDescripDict
				FROM bdisitesp:"informix".se_catdictamenes 
				WHERE tipodictamen = cTipoDictamen;

				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(TRIM(nombre1)||' '||TRIM(nombre2))||' '||TRIM(TRIM(apell_paterno)||' '||TRIM(apell_materno))
				INTO cNomCte
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,'')) WITH RESUME;
	--	END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,''));
		END IF;	
		
	ELIF pTipoConsulta = '5' THEN -- MUESTRA TODOS LOS REGISTROS PARA EXPORTARLOS A EXCEL.
		
		FOREACH
			SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen 
			FROM "informix".si_bitacora_comparaciones AS bc
			INNER JOIN "informix".si_bitacora_dictamenes AS bd ON (bc.numcte = bd.numcte) 
			INNER JOIN "informix".si_catorigenhuellas AS sc ON (sc.origen = bc.origen) 
			WHERE bc.status_alerta = '3' 
			  AND bc.numcte = DECODE(pNumCte, "", bc.numcte, pNumCte) 
			  AND bc.sucursal = DECODE(pSucursal, "", bc.sucursal, pSucursal)
			  AND bd.fecha_dicta_ini::DATE >= DECODE(NVL(pFechaIni, DATE(1)), DATE(1), bd.fecha_dicta_ini::DATE, pFechaIni) 
			  AND bd.fecha_dicta_fin::DATE <= DECODE(NVL(pFechaFin, DATE(1)), DATE(1), bd.fecha_dicta_fin::DATE, pFechaFin) 
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			GROUP BY bc.fecha_insert, bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(TRIM(nombre1)||' '||TRIM(nombre2))||' '||TRIM(TRIM(apell_paterno)||' '||TRIM(apell_materno))
				INTO cNomCte
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,'')) WITH RESUME;
		END FOREACH;
		
	ELIF pTipoConsulta = '6' THEN -- DETALLE DE INFORME DE DICTAMENES.
		FOREACH
			SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, bd.fecha_dicta_fin, bd.sucursal,  TRIM(bd.numcte), bd.tipo, TRIM(bd.numcte_coinc), bd.tipo_dictamen, bd.numemp, (bd.fecha_dicta_fin::DATETIME YEAR TO SECOND - bd.fecha_dicta_ini::DATETIME YEAR TO SECOND), bd.origen, sc.desc_origen
			INTO dtFechaAlerta, dtFechaAtendida, cSucursal, cNumCte, cTipoCoinc, cNumCteCoinc, cTipoDictamen, cEmpAnalista, cTiempoResp, cOrigen, cDescripOrigen 
			FROM "informix".si_bitacora_dictamenes AS bd
			INNER JOIN "informix".si_catorigenhuellas AS sc ON (sc.origen = bc.origen) 
			WHERE numcte = pNumCte
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- CONSULTAMOS LA DESCRIPCION DEL TIPO COINCIDENCIA.
				SELECT descripcion INTO cDescCoinc
				FROM "informix".si_empresa_huella
				WHERE numempresa = cTipoCoinc;
				
				-- CONSULTAMOS LA DESCRIPCION DEL TIPO DE DICTAMEN.
				--SELECT descripcion INTO cDescDictamen
				--FROM bdisitesp:"informix".se_catdictamenes
				--WHERE tipodictamen = cTipoDictamen;
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(TRIM(nombre1)||' '||TRIM(nombre2))||' '||TRIM(TRIM(apell_paterno)||' '||TRIM(apell_materno))
				INTO cNomCte
				FROM "informix".si_cliente
				WHERE numcte = TRIM(cNumCte);
						
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,''));
		END IF;	
		
	ELIF pTipoConsulta = '7' THEN -- TOTAL DETALLE DE INFORME DE DICTAMENES PARA EXPORTAR A EXCEL.
	
		FOREACH
			SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, bd.fecha_dicta_fin, bd.sucursal, TRIM(bd.numcte), bd.tipo, TRIM(bd.numcte_coinc), bd.tipo_dictamen, bd.numemp, (bd.fecha_dicta_fin::DATETIME YEAR TO SECOND - bd.fecha_dicta_ini::DATETIME YEAR TO SECOND), bd.origen, sc.desc_origen
			INTO dtFechaAlerta, dtFechaAtendida, cSucursal, cNumCte, cTipoCoinc, cNumCteCoinc, cTipoDictamen, cEmpAnalista, cTiempoResp, cOrigen, cDescripOrigen 
			FROM "informix".si_bitacora_dictamenes AS bd 
			INNER JOIN "informix".si_catorigenhuellas AS sc ON (sc.origen = bc.origen) 
			WHERE numcte = pNumCte
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- CONSULTAMOS LA DESCRIPCION DEL TIPO COINCIDENCIA.
				SELECT descripcion INTO cDescCoinc
				FROM "informix".si_empresa_huella
				WHERE numempresa = cTipoCoinc;
				
				-- CONSULTAMOS LA DESCRIPCION DEL TIPO DE DICTAMEN.
				--SELECT descripcion INTO cDescDictamen
				--FROM bdisitesp:"informix".se_catdictamenes
				--WHERE tipodictamen = cTipoDictamen;
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(TRIM(nombre1)||' '||TRIM(nombre2))||' '||TRIM(TRIM(apell_paterno)||' '||TRIM(apell_materno))
				INTO cNomCte
				FROM "informix".si_cliente
				WHERE numcte = TRIM(cNumCte);
		
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cDescripDict,''));
		END IF;	
	END IF
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃ?Â??N: GENERA UN INFORME PARA EL AREA DE FRAUDES Y TAMBIEN MUESTRA EL DETALLE DE CADA INFORME DEL DICTAMEN.',
'FECHA DE CREACIÃ?Â??N: 10 DE SEPTIEMBRE DE 2014',
'BASE DE DATOS: BDINTEG',
'CREADOR: 93333366 VALENTIN LOPEZ VALENZUELA',
'VERSION: 20140910.1800',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 23/09/2020',
'DESCRIPCION: Se realiza clonacion y adecuaciÃ?Â³n de SP, se agrega el campo Origen y Descripcion Origen.',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/10/2020',
'DESCRIPCION: Se realiza ajuste a SPL para agregar la descripcion del dictamen',
'DESCRIPCION: Se filtra la fecha mas reciente para el tipo 3 y 4',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 28/06/2021';

CREATE PROCEDURE "informix".sp_conciliacion_sepomex(p_Usuario char(8))
RETURNING char(5), char(80);
-----------------------------------------------------------------------------------------------------------------------------------
 --DECLARACION DE VARIABLES
	DEFINE sql_err 		integer;
	DEFINE v_cod_ret 	char(5);
	DEFINE vMensaje 	char(80);
	DEFINE vv_cod_ret 	char(5);
	DEFINE vvMensaje 	char(80);
	DEFINE vvvMensaje 	CHAR(80);
	DEFINE vNumEstado   INTEGER;
	DEFINE cNombreProceso CHAR(30);
	DEFINE vCodRet       CHAR(5);
	DEFINE ISAM_ERR      INTEGER;
    DEFINE ERROR_INFO    VARCHAR(80);
	DEFINE iRegistros    INTEGER;
	DEFINE v_fecha       DATE;

 --INICIALIZACION DE VARIABLES
	LET v_cod_ret 		= '00000';
	LET vvvMensaje 		= "Proceso Finalizado";
	LET vNumEstado      = 0;
	LET cNombreProceso  = 'CONCILIACION CATALOGOS SEPOMEX';
	LET vCodRet         = '11111';
	LET vMensaje        = 'PROCESO INICIALIZADO';
	LET iRegistros      = 0;
	LET v_fecha         = DATE(1);

BEGIN

   on exception set sql_err, ISAM_ERR, ERROR_INFO
      if sql_err <> 0 then
            let v_cod_ret = sql_err;
			LET vMensaje  = ISAM_ERR || '-' || ERROR_INFO;
			
			  INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
              VALUES(cNombreProceso, v_cod_ret, vMensaje, iRegistros ,user, v_fecha,
              (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
			
            return v_cod_ret, vvvMensaje;
      end if
	  
	  
   end exception;
   
   --SET DEBUG FILE TO "/informix/macf/sp_conciliacion_sepomex.trc";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
   SELECT fecha_hoy 
     into v_fecha
     from bdinteg:si_fechas
	 where empresa = '001';
   
   --LET v_fecha = MDY('06','18','2021');  -- Solo test MACF
   
 --VALIDA QUE EL ESTADO Y/O USUARIO NO ESTEN VACIOS
	IF (p_Usuario IS NULL) OR (p_Usuario = "") THEN
		RETURN "00001", "Faltan parametros";
	END IF;
	

	INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
        VALUES(cNombreProceso, vCodRet, vMensaje, iRegistros ,user, v_fecha,
        (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

	
    --Let vMensaje = 'Error en sp_cargarcatalogosepomex';
    --CALL bdinteg:"informix".sp_cargarcatalogosepomex()  -- Ya se realiza en el 206_27_6 los viernes 
    --RETURNING vv_cod_ret, vvMensaje;                    -- Ya se realiza en el 206_27_6 los viernes 
	
	---Modif 20190919 Aquí se podrían truncar las tablas
	TRUNCATE bdinteg:si_catsepomex_colonias;
	TRUNCATE bdinteg:si_catsepomex_ciudades;
	
		--FOREACH
		FOREACH WITH HOLD
	--ALL. SE SACA EL NUMERO DE ESTADO PARA METERLO COMO PARAMETRO EN LOS SP QUE SE MANDAN LLAMAR DENTRO DEL CICLO	
		SELECT ESTADO
				INTO vNumEstado
				FROM bdinteg:si_estados
	
			Let vMensaje = 'Error en sp_conciliar_ciudades_sepomex';
			CALL bdinteg:"informix".sp_conciliar_ciudades_sepomex(vNumEstado, p_Usuario)
			RETURNING vv_cod_ret;
			
			Let vMensaje = 'Error en sp_actualizar_catalogos_sepomex 1';
			CALL bdinteg:"informix".sp_actualizar_catalogos_sepomex(p_Usuario)
			RETURNING vv_cod_ret;
			
			
			Let vMensaje = 'Error en sp_conciliar_colonias_sepomex';
			CALL bdinteg:"informix".sp_conciliar_colonias_sepomex(vNumEstado, p_Usuario)
			RETURNING vv_cod_ret;
			
	
			Let vMensaje = 'Error en sp_actualizar_catalogos_sepomex 2';
			CALL bdinteg:"informix".sp_actualizar_catalogos_sepomex(p_Usuario)
			RETURNING vv_cod_ret;
			
			
		END FOREACH;
    
	
	LET vCodRet = vv_cod_ret;
	--LET vMensaje  = 'PROCESO EXITOSO';
	
	--- MODIF MACF 20210701
	IF vv_cod_ret = '00000' THEN 
	   LET vMensaje  = 'PROCESO EXITOSO';
	ELSE
	   LET vMensaje = 'ERROR EN PROCESO';
	END IF;
	--- MODIF MACF 20210701
	
    INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
          VALUES(cNombreProceso, vCodRet, vMensaje, iRegistros ,user, v_fecha,
          (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

		  
	RETURN v_cod_ret, vvvMensaje;
	
END;

END PROCEDURE
DOCUMENT
"AUTOR: MACF",
"DESCRIPCION: Agregar hold en for each. Agregar registro en bitácora",
"FECHA: 20190926";

CREATE PROCEDURE "informix".sp_elimina_huellas_vacias() RETURNING CHAR(5) AS cod_retorno;



--DEFINICION DE VARIABLES
DEFINE vcodRet 		    VARCHAR(6); 	-- CODIGO DE RETORNO
DEFINE iSqlErr      	integer;
DEFINE cMensaje		    VARCHAR(100);
DEFINE nContador        INT;
DEFINE nfecha			DATE;
DEFINE pnumcte			CHAR(20);


--INICIALIZACION DE VARIABLES
LET vcodRet 			= '00000';
LET iSqlErr             = 0;
LET cMensaje		    = 'ERROR EN PASO: ';
LET nContador       	= 0;
LET nfecha				= '';
LET pnumcte				= '';


	
BEGIN 
			ON EXCEPTION SET iSqlErr
						IF iSqlErr <> 0 THEN
							LET vcodRet = iSqlErr;
						END IF;
			END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/tmp/masv/huellas/sp_elimina_huellas_vacias.out";
		--TRACE ON;
	
		Select fecha_hoy into nfecha from si_fechas;
		
		FOREACH WITH HOLD
		
			select cte_hu.numcte into pnumcte from si_cte_huella cte_hu 
			join si_cliente cte ON cte.numcte  =  cte_hu.numcte
			where cte_hu.fecha_alta = nfecha 
			and cte_hu.dmapa LIKE 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%' 
			and cte.tipo_cliente = 2

			select count(*) into nContador from si_cte_huella_resp resp where resp.numcte = pnumcte;
			
			IF nContador <> 0 THEN 
			
				delete from si_cte_huella_resp resp where  resp.numcte = pnumcte;			
				delete from si_cte_huella cte_hu where cte_hu.numcte = pnumcte;
			end if;
			
			IF nContador == 0 THEN 
				delete from si_cte_huella cte_hu where cte_hu.numcte = pnumcte;
			end if;
			
		END FOREACH; 
		
	LET vCodRet ='00000';
	
	

	return vCodRet;
END;
END PROCEDURE ;