CREATE PROCEDURE "informix".sp_generaarchivocobranzaselecciones(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE iSqlErr						INTEGER;
DEFINE cDia							CHAR(2);
DEFINE cMes							CHAR(2);
DEFINE cAnio						CHAR(4);
DEFINE vDiaPago						CHAR(2);
DEFINE vMesPago						CHAR(2);
DEFINE vAnioPago					CHAR(4);
DEFINE vHoraPago					CHAR(6);
DEFINE cCategoria					CHAR(2);
DEFINE cConvenio					CHAR(3);
DEFINE vReferencia1					CHAR(20);
DEFINE cRutaArchSelecciones			CHAR(100);
DEFINE cNombArchSelecciones			CHAR(35);
DEFINE cStmt						CHAR(250);
DEFINE vFolio						CHAR(16);
DEFINE vTpoOperacion				CHAR(1);
DEFINE dFechaIni					DATE;
DEFINE dFecha_Hoy					DATE;	
DEFINE dFecha_Max_Procesada			DATE;	
DEFINE vImporte_Pago				DECIMAL(9,0);
DEFINE vImporte_Comision			DECIMAL(9,0);
DEFINE vImporte_Iva					DECIMAL(9,0);
DEFINE vNumero_Operaciones			INTEGER;
DEFINE vImporte_Total				DECIMAL(9,0);
DEFINE vImporte_Total_Comision		DECIMAL(9,0);
DEFINE vImporte_Total_Iva			DECIMAL(9,0);
DEFINE iTotal_Pago					DECIMAL(9,0);
DEFINE iFlagCen						INTEGER;
DEFINE iFlagSuc						INTEGER;
DEFINE iCuantos						INTEGER;
DEFINE iNumPagos					INTEGER;
DEFINE vSucursal					CHAR(4);
DEFINE dFechaPago					DATE;
DEFINE vFechaInsert					CHAR(30);
DEFINE iRelleno						INTEGER;
DEFINE cDiaVen						CHAR(2);
DEFINE cMesVen						CHAR(2);
DEFINE cAnioVen						CHAR(2);
DEFINE vNombreMes					CHAR(10);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3 FOR 3);
LET vReferencia1			= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET vDiaPago				= '';
LET vMesPago				= '';
LET vAnioPago				= '';
LET vHoraPago				= '';
LET vImporte_Pago			= 0;
LET vImporte_Comision		= 0;
LET vImporte_Iva			= 0;
LET vNumero_Operaciones		= 0;
LET vImporte_Total			= 0;
LET vImporte_Total_Comision	= 0;
LET vImporte_Total_Iva		= 0;
LET iTotal_Pago				= 0;
LET vFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchSelecciones	= '';
LET cNombArchSelecciones	= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET dFecha_Max_Procesada	= MDY('01','01','1900');
LET vTpoOperacion			= '';
LET iNumPagos				= 0;
LET vSucursal				= '';
LET dFechaPago				= DATE(1);
LET vFechaInsert			= '';
LET iRelleno				= 0;
LET cDiaVen					= '';
LET cMesVen					= '';
LET cAnioVen				= '';
LET vNombreMes				= '';

	--SET DEBUG FILE TO  '/informix/Aaron/sp_generaarchivocobranzaselecciones.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND   numconvenio = cConvenio;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";
		
		
		--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		SELECT fecha_ultimo_archivo
		INTO dFechaIni
		FROM "informix".sac_controlarchivoscobranza
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		
		
		--SI fecha_ultimo_archivo ES IGUAL A HOY, NO GENERA ARCHIVO
		IF dFechaIni = dFecha_Hoy THEN
			RETURN;
		END IF;
		
		--BUSCA LA MAXIMA FECHA DEL PERIODO A PROCESAR, PARA AGREGARLA AL NOMBRE DEL ARCHIVO A GENERAR
		SELECT first 1 fecha_pago INTO dFecha_Max_Procesada FROM "informix".sac_movimientoshistorial
		WHERE numcategoria = cCategoria AND numconvenio = cConvenio AND fecha_pago > dFechaIni
		AND fecha_pago <= dFecha_Hoy AND status_cancelado <> 'S' AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1);
		
		
		--SI NO ENCONTRO MOVIMIENTOS ASIGNA LA FECHA_HOY(SAC_FECHAS) A FECHA_MAXIMA_PROCESADA
		IF DBINFO('sqlca.sqlerrd2') =0 THEN
			LET dFecha_Max_Procesada = dFecha_Hoy;
		END IF;
		
		
		--ASIGNA VALOR A LAS VARIABLES
		LET cDia = LPAD(DAY(dFecha_Max_Procesada::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Max_Procesada::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(dFecha_Max_Procesada::DATE),4,'0');
		
				
		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT ruta_archivo_cobranza, nombre_archivo_cobranza
		INTO cRutaArchSelecciones, cNombArchSelecciones
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		LET cRutaArchSelecciones = TRIM(cRutaArchSelecciones) || TRIM(cNombArchSelecciones) || '.txt';
		

		
		--REEMPLAZA LA MASCARA POR LA FECHA EN EL NOMBRE DEL ARCHIVO
		LET cRutaArchSelecciones = REPLACE(cRutaArchSelecciones,'AAAA',cAnio);
		LET cRutaArchSelecciones = REPLACE(cRutaArchSelecciones,'MM',cMes);
		LET cRutaArchSelecciones = REPLACE(cRutaArchSelecciones,'DD',cDia);

		
		--ASIGNA NOMBRE DE MES
		let vNombreMes = CASE month(dFecha_Max_Procesada)
							WHEN 1 THEN 'ENERO'
							WHEN 2 THEN 'FEBRERO'
							WHEN 3 THEN 'MARZO'
							WHEN 4 THEN 'ABRIL'
							WHEN 5 THEN 'MAYO'
							WHEN 6 THEN 'JUNIO'
							WHEN 7 THEN 'JULIO'
							WHEN 8 THEN 'AGOSTO'
							WHEN 9 THEN 'SEPTIEMBRE'
							WHEN 10 THEN 'OCTUBRE'
							WHEN 11 THEN 'NOVIEMBRE'
							WHEN 12 THEN 'DICIEMBRE'
							END;
		
		
		--DETALLE OPERACIONES
		LET vTpoOperacion ='1';
		
		FOREACH SELECT fecha_pago
				, LPAD(DAY(fecha_pago::DATE), 2, '0')
				, LPAD(MONTH(fecha_pago::DATE), 2, '0')
				, LPAD(YEAR(fecha_pago::DATE), 4, '0')
				, fecha_insert
				, id_sucursal
				, NVL(folio_suc,'')
				, NVL(referencia1,'')
				, NVL(importe_pago*100,0)
				, NVL(importe_comision_convenio*100,0)
				, NVL(iva_comision_convenio*100,0)
				INTO dFechaPago, vDiaPago, vMesPago, vAnioPago, vFechaInsert, vSucursal, vFolio, vReferencia1, vImporte_Pago, vImporte_Comision, vImporte_Iva
				FROM "informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)
				ORDER BY fecha_insert asc
			
			LET vHoraPago = LPAD(substr(vFechaInsert,12,2),2,0) || LPAD(substr(vFechaInsert,15,2),2,0) || LPAD(substr(vFechaInsert,18,2),2,0);
			LET vImporte_Total = vImporte_Total + vImporte_Pago;
			LET vImporte_Total_Comision = vImporte_Total_Comision + vImporte_Comision;
			LET vImporte_Total_Iva = vImporte_Total_Iva + vImporte_Iva;
			
			LET cStmt = 'echo "' || vTpoOperacion || vReferencia1 || LPAD(vImporte_Pago,9,0) || vAnioPago || vMesPago || vDiaPago || vHoraPago || vFolio || chr(13) || '" >> ' || cRutaArchSelecciones;
			SYSTEM cStmt;
			
		END FOREACH;
		
		LET vNumero_Operaciones= DBINFO('sqlca.sqlerrd2');
		
		IF vNumero_Operaciones > 0 THEN
			--COMISION
			LET vTpoOperacion = '2';
			LET cStmt = 'echo "' || vTpoOperacion || LPAD(iRelleno,20,0) || LPAD(vImporte_Total_Comision,9,0) || LPAD(iRelleno,8,0) || LPAD(iRelleno,6,0) || LPAD(iRelleno,16,0) || chr(13) || '" >> ' || cRutaArchSelecciones;
			SYSTEM cStmt;
			
			--IVA
			LET vTpoOperacion = '3';
			LET cStmt = 'echo "' || vTpoOperacion || LPAD(iRelleno,20,0) || LPAD(vImporte_Total_Iva,9,0)  || LPAD(iRelleno,8,0) || LPAD(iRelleno,6,0) || LPAD(iRelleno,16,0) || chr(13) || '" >> ' || cRutaArchSelecciones;
			SYSTEM cStmt;
			
			--TOTAL
			LET vTpoOperacion = '4';
			LET cStmt = 'echo "' || vTpoOperacion || LPAD(vNumero_Operaciones,20,0) || LPAD(vImporte_Total,9,0) || LPAD(iRelleno,8,0) || LPAD(iRelleno,6,0) || LPAD(iRelleno,16,0) || chr(13) || '" >> ' || cRutaArchSelecciones;
			SYSTEM cStmt;
		ELSE
			LET cStmt = 'echo "" >> ' || cRutaArchSelecciones;
			SYSTEM cStmt;
		END IF;
		
		--ACTUALIZA ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE;