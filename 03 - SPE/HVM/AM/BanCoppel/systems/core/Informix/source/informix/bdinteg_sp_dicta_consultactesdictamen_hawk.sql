CREATE PROCEDURE "informix".sp_dicta_consultactesdictamen_hawk( pTipoConsulta 	CHAR(1), 
																pPaginacion 	SMALLINT, 
																pSucursal 		CHAR(4), 
																pFechaIni 		DATE, 
																pFechaFin 		DATE, 
																pNumCte 		CHAR(20), 
																pTipoDictamen	CHAR(1), 
																pAnalista 		CHAR(8))
	
	
		--RETORNOS
		RETURNING
	CHAR(6)		AS CodRet,
	DATETIME YEAR TO SECOND AS FechaAlerta,
	DATETIME YEAR TO SECOND AS FechaAtendida,
	SMALLINT	AS Coincidencias,
	CHAR(4)		AS Sucursal,
	CHAR(8)		AS NumEmpProm,
	CHAR(45)	AS NombrePromotor,
	CHAR(20)	AS NumCte,
	CHAR(100)	AS NomCte,
	CHAR(8)		AS EmpAnalista,
	CHAR(45)	AS NomAnalista,
	CHAR(20)	AS TiempoResp,
	CHAR(20)	AS NumCteCoinc,
	CHAR(104)	AS NombreCteCoinc,
	CHAR(25)	AS DescCoinc,
	CHAR(100)	AS DescDictamen,
	CHAR(2)		AS Tipo_Persona,
    CHAR(60)	AS Razon_Social,
    CHAR(26)	AS Apell_Paterno,
    CHAR(26)	AS Apell_Materno,
    CHAR(2)		AS  DireccionLinea2,
    CHAR(10)	AS NumeroExtCalle,
    CHAR(10)	AS NumeroIntCalle,
    CHAR(60)	AS Colonia,
    CHAR(5)		AS Municipio,
    CHAR(3)		AS Ciudad,
    CHAR(2)		AS Estado,
    CHAR(5)		AS Cod_Postal,
    SMALLINT	AS Tipo_tel,
    CHAR(2)		AS Cod_Area,
    CHAR(13)	AS Numero_Tel,
    CHAR(5)		AS Extencion,
    CHAR(2)		AS RelacionLaboral,
    CHAR(2)		AS Nombre_Compania,
    CHAR(2)		AS Area,
    CHAR(2)		AS Puesto,
    CHAR(2)		AS Fecha_ingreso,
    CHAR(2)		AS Fecha_Salida,
    CHAR(1)		AS Tipo_Inmueble,
    CHAR(2)		AS DireccionLinea1,
    CHAR(2)		AS DireccionLinea22,
    CHAR(10)	AS NumeroExtCalle2,
    CHAR(10)	AS NumeroIntCalle2,
    CHAR(60)	AS Colonia2,
    CHAR(5)		AS Municipio2,
    CHAR(3)		AS Ciudad2,
    CHAR(2)		AS Estado2,
    CHAR(5)		AS Cod_Postal2,
    SMALLINT	AS Tipo_tel2,
    CHAR(2)		AS Cod_Area2,
    CHAR(13)	AS Numero_Tel2,
    CHAR(5)		AS Extencion2,
	INTEGER		AS TotalDictamen

	DEFINE iSqlErr			INTEGER; 
	DEFINE cCodRet			CHAR(6);
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
	DEFINE cNombreCteCoinc	CHAR(104);
	DEFINE cDescDictamen	CHAR(100);
	DEFINE cDescCoinc		CHAR(25);
	DEFINE cTipo_Persona	CHAR(2);
	DEFINE cRazon_Social	CHAR(60);
	DEFINE cApell_Paterno	CHAR(26);
	DEFINE cApell_Materno	CHAR(26);
	DEFINE cDireccionLinea2	CHAR(2);
	DEFINE cNumeroExtCalle	CHAR(10);
	DEFINE cNumeroIntCalle	CHAR(10);
	DEFINE cColonia			CHAR(60);
	DEFINE cMunicipio		CHAR(5);
	DEFINE cCiudad			CHAR(3);
	DEFINE cEstado			CHAR(2);
	DEFINE cCod_postal		CHAR(5);
	DEFINE sTipo_tel		SMALLINT;
	DEFINE cCod_Area		CHAR(2);
	DEFINE cNumero_Tel		CHAR(13);
	DEFINE cExtencion		CHAR(5);
	DEFINE cRelacionLaboral	CHAR(2);
	DEFINE cNombre_Compania	CHAR(2);
	DEFINE cArea			CHAR(2);
	DEFINE cPuesto			CHAR(2);
	DEFINE cFecha_ingreso	CHAR(2);
	DEFINE cFecha_Salida	CHAR(2);
	DEFINE cTipo_Inmueble	CHAR(1);
	DEFINE cDireccionLinea1	CHAR(2);
	DEFINE cDireccionLinea22 CHAR(2);
	DEFINE cNumeroExtCalle2	CHAR(10);
	DEFINE cNumeroIntCalle2	CHAR(10);
	DEFINE cColonia2		CHAR(60);
	DEFINE cMunicipio2		CHAR(5);
	DEFINE cCiudad2			CHAR(3);
	DEFINE cEstado2			CHAR(2);
	DEFINE cCod_postal2		CHAR(5);
	DEFINE sTipo_tel2		SMALLINT;
	DEFINE cCod_Area2		CHAR(2);
	DEFINE cNumero_Tel2		CHAR(13);
	DEFINE cExtencion2		CHAR(5);
	DEFINE iTotalDictamen	INTEGER;
	DEFINE cTipoCliente		CHAR(1);
	DEFINE dtFechaIniDicta	DATETIME YEAR TO SECOND;
 
	--Inicializacion de variables
	LET iSqlErr				= 0;
	LET cCodRet				= '000000';
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
	LET cNombreCteCoinc		= '';
	LET cDescDictamen		= '';
	LET cDescCoinc			= '';
	LET cTipo_Persona		= '';
	LET cRazon_Social		= ''; --= 'NA';
	LET cApell_Paterno		= '';
	LET cApell_Materno		= '';
	LET cDireccionLinea2	= 'NA';
	LET cNumeroExtCalle		= '';
	LET cNumeroIntCalle		= '';
	LET cColonia			= '';
	LET cMunicipio			= '';
	LET cCiudad				= '';
	LET cEstado				= '';
	LET cCod_postal    	    = '';
	LET sTipo_tel			= 0;
	LET cCod_Area			= 'NA';
	LET cNumero_Tel			= '';
	LET cExtencion			= '';
	LET cRelacionLaboral	= 'NA';
	LET cNombre_Compania	= 'NA';
	LET cArea				= 'NA';
	LET cPuesto				= 'NA';
	LET cFecha_ingreso		= 'NA';
	LET cFecha_Salida		= 'NA';
	LET cTipo_Inmueble		= ' ';
	LET cDireccionLinea1	= 'NA';
	LET cDireccionLinea22	= 'NA';
	LET cNumeroExtCalle2	= '';
	LET cNumeroIntCalle2	= '';
	LET cColonia2			= '';
	LET cMunicipio2			= '';
	LET cCiudad2			= '';
	LET cEstado2			= '';
	LET cCod_postal2		= '';
	LET sTipo_tel2			= 0;
	LET cCod_Area2			= 'NA';
	LET cNumero_Tel2		= '';
	LET cExtencion2			= '';
	LET iTotalDictamen		= 0;
	LET cTipoCliente		= '';
	LET dtFechaIniDicta		= '';
	

	BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0);
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/Rodolfo/sp_dicta_consultactesdictamen.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- SI NO CUMPLE CON LOS PARAMETROS OBLIGATORIOS REGRESA CODIGO '000001'.
	IF NVL(pPaginacion, 0) = 0 THEN
		LET pPaginacion = 0;
	END IF;
	
	-- VALIDACIÃ?N DE CADA FUNCIONALIDAD DEL PROCEDIMIENTO.
	IF pTipoConsulta = '1' THEN -- CONSULTA POR TODOS LOS DICTAMENES REALIZADOS.
		
		SELECT count(*)
		INTO iTotalDictamen
		FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd 
		WHERE bc.numcte = bd.numcte
		AND bc.status_alerta = '3'
		AND bd.situacion = 'P' and bd.causa = 108
		AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
		AND bd.tipo_dictamen    = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen);

		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT SKIP pPaginacion LIMIT 20 bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = 108
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
              AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			
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
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno), TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle, cNumeroIntCalle, cColonia, cMunicipio, cCiudad, cEstado, cCod_postal 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '1';
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle2, cNumeroIntCalle2, cColonia2, cMunicipio2, cCiudad2, cEstado2, cCod_postal2 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '2';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel, cNumero_Tel, cExtencion
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '1';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel2, cNumero_Tel2, cExtencion2
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '3';
				
				IF cTipoCliente = '1' THEN 
					LET cRazon_Social = 'NA';
				END IF;
				
				RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0);
		END IF;	
		
	ELIF pTipoConsulta = '2' AND TRIM(NVL(pSucursal,"")) <> "" THEN -- CONSULTA POR SUCURSAL.
		
		-- TOTAL ALERTAS DICTAMINADAS.
		FOREACH
			SELECT bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
			  AND bd.sucursal = pSucursal
              AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
              AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
		END FOREACH;
		
		LET iTotalDictamen = DBINFO("sqlca.sqlerrd2");
		
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT SKIP pPaginacion LIMIT 20 bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
			  AND bd.sucursal = pSucursal
              AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
              AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			
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
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno), TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle, cNumeroIntCalle, cColonia, cMunicipio, cCiudad, cEstado, cCod_postal 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '1';
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle2, cNumeroIntCalle2, cColonia2, cMunicipio2, cCiudad2, cEstado2, cCod_postal2 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '2';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel, cNumero_Tel, cExtencion
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '1';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel2, cNumero_Tel2, cExtencion2
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '3';
				
				IF cTipoCliente = '1' THEN 
					LET cRazon_Social = 'NA';
				END IF;
				
				RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0);
		END IF;	
		
	ELIF pTipoConsulta = '3' THEN -- CONSULTA POR FECHAS.
	
		IF NVL(pFechaIni, DATE(1)) = DATE(1) OR NVL(pFechaFin, DATE(1)) = DATE(1) THEN
			LET cCodRet = '000001';
		ELSE
			-- TOTAL ALERTAS DICTAMINADAS.
			FOREACH
				SELECT bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
				INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista
				FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd
				WHERE bc.numcte = bd.numcte
				  AND bc.status_alerta = '3'
				  AND bd.situacion = 'P' 
				  AND bd.causa = '108'
				  AND bd.fecha_dicta_ini::DATE >= pFechaIni
				  AND bd.fecha_dicta_fin::DATE <= pFechaFin
				  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
				  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
				GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			END FOREACH;
			
			LET iTotalDictamen = DBINFO("sqlca.sqlerrd2");
			
			FOREACH
				--SELECT bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
				SELECT bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
				INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista
				FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd
				WHERE bc.numcte = bd.numcte
				  AND bc.status_alerta = '3'
				  AND bd.situacion = 'P' 
				  AND bd.causa = '108'
				  AND bd.fecha_dicta_ini::DATE >= pFechaIni
				  AND bd.fecha_dicta_fin::DATE <= pFechaFin
				  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
				  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
				GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
				
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
					SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno), TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
					INTO cNomCte, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
					FROM "informix".si_cliente
					WHERE numcte = cNumCte;
					
					--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
					SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
					INTO cNumeroExtCalle, cNumeroIntCalle, cColonia, cMunicipio, cCiudad, cEstado, cCod_postal 
					FROM "informix".si_direcciones_actual
					WHERE numcte = cNumCte  AND tipo_dir = '1';
					
					--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
					SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
					INTO cNumeroExtCalle2, cNumeroIntCalle2, cColonia2, cMunicipio2, cCiudad2, cEstado2, cCod_postal2 
					FROM "informix".si_direcciones_actual
					WHERE numcte = cNumCte  AND tipo_dir = '2';
					
					--OBTENER LOS DATOS DE TELEFONO
					SELECT tipo_tel, telefono, extension
					INTO sTipo_tel, cNumero_Tel, cExtencion
					FROM "informix".si_telefonos_actual
					WHERE numcte = cNumCte AND tipo_tel = '1';
					
					--OBTENER LOS DATOS DE TELEFONO
					SELECT tipo_tel, telefono, extension
					INTO sTipo_tel2, cNumero_Tel2, cExtencion2
					FROM "informix".si_telefonos_actual
					WHERE numcte = cNumCte AND tipo_tel = '3';
					
					IF cTipoCliente = '1' THEN 
						LET cRazon_Social = 'NA';
					END IF;
					
					RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0) WITH RESUME;
			END FOREACH;
			
			-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000002'; 
				RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0);
			END IF;	
		END IF;
		
	ELIF pTipoConsulta = '4' AND TRIM(pNumCte) <> ""  THEN -- CONSULTA POR CLIENTE.
		
		-- TOTAL ALERTAS DICTAMINADAS.
			SELECT count (*) into iTotalDictamen
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
		      AND bc.numcte = pNumCte
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen);
			--GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes

		--LET iTotalDictamen = DBINFO("sqlca.sqlerrd2");
		
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT SKIP pPaginacion LIMIT 20 bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
		      AND bc.numcte = pNumCte
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			
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
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno), TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle, cNumeroIntCalle, cColonia, cMunicipio, cCiudad, cEstado, cCod_postal 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '1';
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle2, cNumeroIntCalle2, cColonia2, cMunicipio2, cCiudad2, cEstado2, cCod_postal2 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '2';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel, cNumero_Tel, cExtencion
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '1';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel2, cNumero_Tel2, cExtencion2
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '3';
				
				IF cTipoCliente = '1' THEN 
					LET cRazon_Social = 'NA';
				END IF;
				
				RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0);
		END IF;	
		
	ELIF pTipoConsulta = '5' THEN -- MUESTRA TODOS LOS REGISTROS PARA EXPORTARLOS A EXCEL.
		
		FOREACH
			--SELECT bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd
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
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes
			
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
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno), TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle, cNumeroIntCalle, cColonia, cMunicipio, cCiudad, cEstado, cCod_postal 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '1';
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle2, cNumeroIntCalle2, cColonia2, cMunicipio2, cCiudad2, cEstado2, cCod_postal2 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '2';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel, cNumero_Tel, cExtencion
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '1';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel2, cNumero_Tel2, cExtencion2
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '3';
				
				IF cTipoCliente = '1' THEN 
					LET cRazon_Social = 'NA';
				END IF;
				
				RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0) WITH RESUME;
		END FOREACH;
		
	ELIF pTipoConsulta = '6' AND TRIM(pNumCte) <> "" THEN -- DETALLE DE INFORME DE DICTAMENES.
		
		SELECT COUNT(*) INTO iTotalDictamen-- TOTAL ALERTAS DICTAMINADAS.
		FROM "informix".si_bitacora_dictamenes 
		WHERE numcte = pNumCte;
		
		FOREACH
			SELECT SKIP pPaginacion LIMIT 20 fecha_insert, fecha_dicta_fin, sucursal, numcte, tipo, numcte_coinc, tipo_dictamen, numemp, (fecha_dicta_fin::DATETIME YEAR TO SECOND - fecha_dicta_ini::DATETIME YEAR TO SECOND)
			INTO dtFechaAlerta, dtFechaAtendida, cSucursal, cNumCte, cTipoCoinc, cNumCteCoinc, cTipoDictamen, cEmpAnalista, cTiempoResp
			FROM "informix".si_bitacora_dictamenes 
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
				SELECT descripcion INTO cDescDictamen
				FROM bdisitesp:"informix".se_catdictamenes
				WHERE tipodictamen = cTipoDictamen;
				
							-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno), TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle, cNumeroIntCalle, cColonia, cMunicipio, cCiudad, cEstado, cCod_postal 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '1';
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle2, cNumeroIntCalle2, cColonia2, cMunicipio2, cCiudad2, cEstado2, cCod_postal2 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '2';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel, cNumero_Tel, cExtencion
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '1';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel2, cNumero_Tel2, cExtencion2
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '3';
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE CON EL HIZO COINCIDENCIA.
				SELECT LIMIT 1 nombre INTO cNombreCteCoinc
				FROM "informix".si_huella_linea_resultado
				WHERE cliente = cNumCteCoinc;
				
				IF nvl(cNombreCteCoinc,'') = '' THEN
					SELECT LIMIT 1 nombre INTO cNombreCteCoinc
					FROM "informix".si_huella_linea_resultado_hist
					WHERE cliente = cNumCteCoinc;
				end if;
				
				IF cTipoCliente = '1' THEN 
					LET cRazon_Social = 'NA';
				END IF;
				
				RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0);
		END IF;	
		
	ELIF pTipoConsulta = '7' AND TRIM(pNumCte) <> ""  THEN -- TOTAL DETALLE DE INFORME DE DICTAMENES PARA EXPORTAR A EXCEL.
	
		FOREACH
			SELECT fecha_insert, fecha_dicta_fin, sucursal, numcte, tipo, numcte_coinc, tipo_dictamen, numemp, (fecha_dicta_fin::DATETIME YEAR TO SECOND - fecha_dicta_ini::DATETIME YEAR TO SECOND)
			INTO dtFechaAlerta, dtFechaAtendida, cSucursal, cNumCte, cTipoCoinc, cNumCteCoinc, cTipoDictamen, cEmpAnalista, cTiempoResp
			FROM "informix".si_bitacora_dictamenes 
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
				SELECT descripcion INTO cDescDictamen
				FROM bdisitesp:"informix".se_catdictamenes
				WHERE tipodictamen = cTipoDictamen;
				
							-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno), TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle, cNumeroIntCalle, cColonia, cMunicipio, cCiudad, cEstado, cCod_postal 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '1';
				
				--OBTENER LOS DATOS DE LA DIRECCION DEL CLIENTE
				SELECT TRIM(numeroextcalle), TRIM(numerointcalle), TRIM(colonia), TRIM(municipio), TRIM(ciudad), TRIM(estado), TRIM(cod_postal)
				INTO cNumeroExtCalle2, cNumeroIntCalle2, cColonia2, cMunicipio2, cCiudad2, cEstado2, cCod_postal2 
				FROM "informix".si_direcciones_actual
				WHERE numcte = cNumCte  AND tipo_dir = '2';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel, cNumero_Tel, cExtencion
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '1';
				
				--OBTENER LOS DATOS DE TELEFONO
				SELECT tipo_tel, telefono, extension
				INTO sTipo_tel2, cNumero_Tel2, cExtencion2
				FROM "informix".si_telefonos_actual
				WHERE numcte = cNumCte AND tipo_tel = '3';
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE CON EL HIZO COINCIDENCIA.
				SELECT LIMIT 1 nombre INTO cNombreCteCoinc
				FROM "informix".si_huella_linea_resultado
				WHERE cliente = cNumCteCoinc;
				
				
				IF nvl(cNombreCteCoinc,'') = '' THEN
					SELECT LIMIT 1 nombre INTO cNombreCteCoinc
					FROM "informix".si_huella_linea_resultado_hist
					WHERE cliente = cNumCteCoinc;
				end if;
				
				IF cTipoCliente = '1' THEN 
					LET cRazon_Social = 'NA';
				END IF;
				
				RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0);
		END IF;
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	IF cCodRet <> '000000' THEN
		RETURN TRIM(cCodRet), NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cNombreCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cDescDictamen,'')), TRIM(NVL(cTipo_Persona,'')), TRIM(NVL(cRazon_Social,'')), TRIM(NVL(cApell_Paterno,'')), TRIM(NVL(cApell_Materno,'')), TRIM(NVL(cDireccionLinea2,'NA')), TRIM(NVL(cNumeroExtCalle,'')), TRIM(NVL(cNumeroIntCalle,'')), TRIM(NVL(cColonia,'')), TRIM(NVL(cMunicipio,'')), TRIM(NVL(cCiudad,'')), TRIM(NVL(cEstado,'')), TRIM(NVL(cCod_postal,'')), NVL(sTipo_tel,0), TRIM(NVL(cCod_Area,'NA')), TRIM(NVL(cNumero_Tel,'')), TRIM(NVL(cExtencion,'')), TRIM(NVL(cRelacionLaboral,'NA')), TRIM(NVL(cNombre_Compania,'NA')), TRIM(NVL(cArea,'NA')), TRIM(NVL(cPuesto,'NA')), TRIM(NVL(cFecha_ingreso,'NA')), TRIM(NVL(cFecha_Salida,'NA')), TRIM(NVL(cTipo_Inmueble,' ')), TRIM(NVL(cDireccionLinea1,'NA')), TRIM(NVL(cDireccionLinea22,'NA')), TRIM(NVL(cNumeroExtCalle2,'')), TRIM(NVL(cNumeroIntCalle2,'')), TRIM(NVL(cColonia2,'')), TRIM(NVL(cMunicipio2,'')), TRIM(NVL(cCiudad2,'')), TRIM(NVL(cEstado2,'')), TRIM(NVL(cCod_postal2,'')), NVL(sTipo_tel2,0), TRIM(NVL(cCod_Area2,'NA')), TRIM(NVL(cNumero_Tel2,'')), TRIM(NVL(cExtencion2,'')),NVL(iTotalDictamen,0);
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: 97122114, Luis Alberto Madrid Castro',
'FOLIO: 230142 - 1530  - EvaluaciÃ³n de Resultados de ComparaciÃ³n de Huellas en LÃ­nea en Alta de Cliente ',
'DESCRIPCION: Creacion de SP_DICTA_CONSULTADICTAMEN_HAWK., para llenar el reporte hawk',
'FECHA: 29/01/2016',
'BD:BDINTEG ';

CREATE PROCEDURE "informix".sp_consulta_refclientes(
                                                    sEmpresa    CHAR(3),
                                                    sNumCte     CHAR(20),
                                                    sNumSol     CHAR(20),
                                                    sParentesco CHAR(2),
                                                    sTelefono   CHAR(13),
                                                    sSecuencia  INTEGER
                                                    )
               RETURNING CHAR(5), CHAR(3), CHAR(20), CHAR(20), CHAR(4), INTEGER, CHAR(26), CHAR(26), CHAR(26),
                         CHAR(26), CHAR(13), DATE, CHAR(20), CHAR(1), CHAR(2), CHAR(3), CHAR(18), CHAR(2), CHAR(30), CHAR(2),
                         CHAR(60), CHAR(2), CHAR(26), CHAR(20), CHAR(20), CHAR(8), DATE, CHAR(13), CHAR(13), CHAR(13), CHAR(5);

--DOCUMENTACION:
--Realizó: Daniela Ramírez
--Fecha: 02/06/2011
--Funcionalidad: Consulta la tabla si_refcliente la cual regresa los datos de la referencia del cliente.

-- Se definen variables
DEFINE cCodRet     CHAR(5);
DEFINE iSqlErr     INTEGER;

--Se definen variables de la tabla si_refclientes
DEFINE cEmpresa CHAR(3);
DEFINE cNum_solicitud CHAR(20);
DEFINE cNumcte CHAR(20);
DEFINE cSucursal CHAR(4);
DEFINE iSecuencia INTEGER;
DEFINE cApell_paterno CHAR(26);
DEFINE cApell_materno CHAR(26);
DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE cRfc CHAR(13);
DEFINE cFecha_nac DATE;
DEFINE cCurp CHAR(20);
DEFINE cSexo CHAR(1);
DEFINE cEstado_civil CHAR(2);
DEFINE cNacionalidad CHAR(3);
DEFINE cNo_fm3 CHAR(18);
DEFINE cCodidentifi CHAR(2);
DEFINE cNumidentifi CHAR(30);
DEFINE cPers_domicilio CHAR(2);
DEFINE cEmail CHAR(60);
DEFINE cParentesco CHAR(2);
DEFINE cApellido_cas CHAR(26);
DEFINE cNumcte_ref CHAR(20);
DEFINE cNumcte_banco CHAR(20);
DEFINE cUser_insert CHAR(8);
DEFINE cFecha_insert DATE;
--Se declaran variables tabla si_refdirecciones
DEFINE cTelefono1 CHAR(13);
DEFINE cTelefono2 CHAR(13);
DEFINE cTelefono3 CHAR(13);
DEFINE cExtension CHAR(5);

-- Se inicializan variables
LET cCodRet = "00000";
LET iSqlErr = 0;
--Se inicializan variables tabla si_refclientes
LET cEmpresa = ' '; 
LET cNum_solicitud = ' ';
LET cNumcte = ' '; 
LET cSucursal = ' '; 
LET iSecuencia = 0;
LET cApell_paterno = ' '; 
LET cApell_materno = ' '; 
LET cNombre1 = ' '; 
LET cNombre2 = ' '; 
LET cRfc = ' '; 
LET cFecha_nac = DATE(1);
LET cCurp = ' '; 
LET cSexo = ' '; 
LET cEstado_civil = ' '; 
LET cNacionalidad = ' '; 
LET cNo_fm3 = ' '; 
LET cCodidentifi = ' '; 
LET cNumidentifi = ' '; 
LET cPers_domicilio = ' '; 
LET cEmail = ' '; 
LET cParentesco = ' '; 
LET cApellido_cas = ' '; 
LET cNumcte_ref = ' '; 
LET cNumcte_banco = ' '; 
LET cUser_insert = ' '; 
LET cFecha_insert = DATE(1);
--Se inicializan variables tabla si_refdirecciones
LET cTelefono1 = " ";
LET cTelefono2 = " ";
LET cTelefono3 = " ";
LET cExtension = " ";

--        SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consulta_refclientes.out";
--        TRACE ON;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cEmpresa, cNum_solicitud, cNumcte, cSucursal, iSecuencia, cApell_paterno, cApell_materno, cNombre1, cNombre2, 
                            cRfc, cFecha_nac, cCurp, cSexo, cEstado_civil, cNacionalidad, cNo_fm3, cCodidentifi, cNumidentifi, cPers_domicilio, cEmail, 
                            cParentesco, cApellido_cas, cNumcte_ref, cNumcte_banco, cUser_insert, cFecha_insert, cTelefono1, cTelefono2, cTelefono3, 
                            cExtension;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF (sNumCte <> ' ' AND sNumCte IS NOT NULL) THEN

            SELECT ref.empresa, ref.num_solicitud, ref.numcte, ref.sucursal, ref.secuencia, ref.apell_paterno, ref.apell_materno, ref.nombre1, 
                   ref.nombre2, ref.rfc, ref.fecha_nac, ref.curp, ref.sexo, ref.estado_civil, ref.nacionalidad, ref.no_fm3, ref.codidentifi, ref.numidentifi, 
                   ref.pers_domicilio, ref.email, ref.parentesco, ref.apellido_cas, ref.numcte_ref, ref.numcte_banco, ref.user_insert, ref.fecha_insert, 
                   refdir.telefono1, refdir.telefono2, refdir.telefono3, refdir.extension
            INTO cEmpresa, cNum_solicitud, cNumcte, cSucursal, iSecuencia, cApell_paterno, cApell_materno, cNombre1, cNombre2, 
                 cRfc, cFecha_nac, cCurp, cSexo, cEstado_civil, cNacionalidad, cNo_fm3, cCodidentifi, cNumidentifi, cPers_domicilio, cEmail, 
                 cParentesco, cApellido_cas, cNumcte_ref, cNumcte_banco, cUser_insert, cFecha_insert, cTelefono1, cTelefono2,
                 cTelefono3, cExtension
            FROM bdinteg:"informix".si_refclientes ref 
            LEFT OUTER JOIN bdinteg:"informix".si_refdirecciones refdir 
                 ON (refdir.numcte = ref.numcte
                 AND refdir.secuencia = ref.secuencia)
            WHERE (refdir.telefono1 = sTelefono OR refdir.telefono2 = sTelefono OR refdir.telefono3 = sTelefono)
                 AND ref.empresa = sEmpresa
                 AND ref.numcte = sNumCte 
                 AND ref.num_solicitud = sNumSol
                 AND ref.parentesco = sParentesco
                 AND ref.secuencia = sSecuencia;

           LET cCodRet = "00000"; -- Realiza consulta

   ELSE
            LET cCodRet = "00001";  -- Los parametros que se mandaron son incorrectos
   END IF;

        RETURN cCodRet, cEmpresa, cNum_solicitud, cNumcte, cSucursal, iSecuencia, cApell_paterno, cApell_materno, cNombre1, cNombre2, 
                        cRfc, cFecha_nac, cCurp, cSexo, cEstado_civil, cNacionalidad, cNo_fm3, cCodidentifi, cNumidentifi, cPers_domicilio, cEmail, 
                        cParentesco, cApellido_cas, cNumcte_ref, cNumcte_banco, cUser_insert, cFecha_insert, cTelefono1, cTelefono2, cTelefono3, 
                        cExtension;

END;
END PROCEDURE;