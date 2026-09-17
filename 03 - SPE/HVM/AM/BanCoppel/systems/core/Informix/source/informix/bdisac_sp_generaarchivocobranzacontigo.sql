CREATE PROCEDURE "informix".sp_generaarchivocobranzacontigo(pConvenio CHAR(5))

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
DEFINE vFormaPago					CHAR(1);
DEFINE cCategoria					CHAR(2);
DEFINE cConvenio					CHAR(3);
DEFINE vReferencia1					CHAR(13);
DEFINE cRutaArchContigo			    CHAR(100);
DEFINE cStmt						CHAR(250);
DEFINE vFolio						CHAR(16);
DEFINE vTpoOperacion				CHAR(1);
DEFINE vTpoRegistro					CHAR(1);
DEFINE dFechaIni					DATE;
DEFINE dFecha_Hoy					DATE;	
DEFINE dFecha_Max_Procesada			DATE;	
DEFINE vImporte_Pago				DECIMAL(18,0);
DEFINE vImporte_Comision			DECIMAL(18,0);
DEFINE vImporte_Iva					DECIMAL(18,0);
DEFINE vNumero_Operaciones			INTEGER;
DEFINE vImporte_Total				DECIMAL(18,0);
DEFINE vImporte_Total_Comision		DECIMAL(18,0);
DEFINE vImporte_Total_Iva			DECIMAL(18,0);
DEFINE iTotal_Pago					DECIMAL(18,0);
DEFINE iFlagCen						INTEGER;
DEFINE iFlagSuc						INTEGER;
DEFINE iCuantos						INTEGER;
DEFINE iNumPagos					INTEGER;
DEFINE vSucursal					CHAR(4);
DEFINE dFechaPago					DATE;
DEFINE iRelleno						INTEGER;
DEFINE cDiaVen						CHAR(2);
DEFINE cMesVen						CHAR(2);
DEFINE cAnioVen						CHAR(2);
DEFINE cReferencia1                 CHAR(20);
DEFINE cFolio                       CHAR(20);
DEFINE dFecha_Pago                  DATE;

--SET DEBUG FILE TO '/informix/ENP/sp_sac_consulta_ctesremesas.out';
--TRACE ON;

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
LET vFormaPago				= '';
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
LET cRutaArchContigo		= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET dFecha_Max_Procesada	= MDY('01','01','1900');
LET vTpoOperacion			= '';
LET vTpoRegistro			= '';
LET iNumPagos				= 0;
LET vSucursal				= '';
LET dFechaPago				= DATE(1);
LET iRelleno				= 0;
LET cDiaVen					= '';
LET cMesVen					= '';
LET cAnioVen				= '';

SET ISOLATION TO DIRTY READ;	
SET LOCK MODE TO WAIT 3;

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
		SELECT TRIM(ruta_archivo_cobranza ) || TRIM(nombre_archivo_cobranza) || '.txt'
		INTO cRutaArchContigo
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		

		
		--REEMPLAZA LA MASCARA POR LA FECHA EN EL NOMBRE DEL ARCHIVO
		LET cRutaArchContigo = REPLACE(cRutaArchContigo,'AAAA',cAnio);
		LET cRutaArchContigo = REPLACE(cRutaArchContigo,'MM',cMes);
		LET cRutaArchContigo = REPLACE(cRutaArchContigo,'DD',cDia);
		
		
		
		--DETALLE OPERACIONES
		LET vTpoOperacion ='1';
		LET vTpoRegistro  ='D';	
		
		FOREACH SELECT  NVL(referencia1,'')
				, NVL(importe_pago*100,0)
				, LPAD(DAY(fecha_pago::DATE), 2, '0')
				, LPAD(MONTH(fecha_pago::DATE), 2, '0')
				, LPAD(YEAR(fecha_pago::DATE), 4, '0')
				, LPAD(substr(fecha_insert,12,2),2,0) || LPAD(substr(fecha_insert,15,2),2,0) || LPAD(substr(fecha_insert,18,2),2,0)
				, NVL(folio_suc,'')
				, fecha_Pago
				INTO vReferencia1,vImporte_Pago, vDiaPago, vMesPago, vAnioPago, vHoraPago, vFolio ,dFecha_Pago
				FROM "informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)
				ORDER BY fecha_insert asc

			LET vImporte_Total = vImporte_Total + vImporte_Pago;
			
			LET cStmt = 'echo "' || vTpoRegistro || vTpoOperacion || vReferencia1 || LPAD(vImporte_Pago,9,0) || vAnioPago || vMesPago || vDiaPago || vHoraPago || vFolio || chr(13) || '" >> ' || cRutaArchContigo; 
			SYSTEM cStmt;
			
		END FOREACH;
		
		LET vNumero_Operaciones= DBINFO('sqlca.sqlerrd2');
		
		IF vNumero_Operaciones > 0 THEN
			
			--TOTAL
			LET vTpoOperacion ='2';
		    LET vTpoRegistro  ='T';	
			LET cStmt = 'echo "' || vTpoRegistro || vTpoOperacion ||  LPAD(vNumero_Operaciones,13,0) || LPAD(vImporte_Total,9,0) || LPAD(iRelleno,8,0) || LPAD(iRelleno,6,0) || LPAD(iRelleno,16,0) || chr(13) || '" >> ' || cRutaArchContigo;  
			SYSTEM cStmt;
		ELSE
			LET cStmt = 'echo "" >> ' || cRutaArchContigo;
			SYSTEM cStmt;
		END IF;
		

		--ACTUALIZA BANDERA CONFIRMACION SUCURSAL
        FOREACH SELECT referencia1, folio_suc, fecha_pago 
		        		INTO  cReferencia1, cFolio, dFecha_Pago
		        		FROM bdisac:"informix".sac_movimientoshistorial
		        		WHERE fecha_insert::DATE < today 
		        		  AND numcategoria = cCategoria 
		        		  AND numconvenio = cConvenio 
						  and flag_confirmacion_sucursal = 0
						  AND status_cancelado <> 'S'
       			
    		 UPDATE bdisac:"informix".sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio
                AND fecha_pago = dFecha_Pago
				AND folio_suc = cFolio
				AND referencia1 = cReferencia1
                AND status_cancelado <> 'S'
                AND flag_confirmacion_sucursal = 0;
		END FOREACH;
       

		--ACTUALIZA ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE;