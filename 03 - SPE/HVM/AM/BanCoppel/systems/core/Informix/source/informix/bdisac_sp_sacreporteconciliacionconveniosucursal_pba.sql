CREATE PROCEDURE "informix".sp_sacreporteconciliacionconveniosucursal_pba(cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE)

-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(4) AS id_sucursal, INTEGER AS numpagos, CHAR(40) AS nomconvenio, MONEY(16,2) AS importe_pago, MONEY(16,2) AS importe_comision_convenio, MONEY(16,2) AS iva_comision_convenio, MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte, INTEGER AS flag_confirmacion_central, INTEGER AS flag_confirmacion_sucursal;


-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE cNumcategoria            CHAR(2);
DEFINE cIdSucursal              CHAR(4);
DEFINE cNumconvenio             CHAR(3);
DEFINE cNomconvenio             CHAR(40);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComisionConvenio    MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mIVAComisionCte         MONEY(16,2);
DEFINE mImportePago            MONEY(16,2);
DEFINE iConfirmacionCentral     INTEGER;
DEFINE iConfirmacionSucursal    INTEGER;
DEFINE iNumPagos                INTEGER;
DEFINE dFechaTabla			DATE;

--SET DEBUG FILE TO '/informix/adrian/sp_sacreporteconciliacionconveniosucursal_aia.out';
--TRACE ON;

--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cNumcategoria         = SUBSTRING(cConvenio FROM 1 FOR 2);
LET cNumconvenio          = SUBSTRING(cConvenio FROM 3 FOR 3);
LET cIdSucursal           = "";
LET cNomConvenio          = "";
LET mImportePago         = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte      = 0;
LET mIVAComisionCte      = 0;
LET iConfirmacionCentral  = 0;
LET iConfirmacionSucursal = 0;
LET iNumPagos             = 0;
LET dFechaTabla			= '';

BEGIN

    ON EXCEPTION SET iSqlErr

        IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
        END IF;

    END EXCEPTION;
	
	SELECT MIN (fecha_pago)
	INTO dFechaTabla
	FROM bdisac:"informix".sac_conciliaciontotalporconvenio;

    IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
    ELSE
		IF (dFechaIni>=dFechaTabla) THEN --Nuevo Proceso utilizando la tabla sac_conciliaciontotalporconvenio
			IF cConvenio = "00000" THEN      -- Todos los convenios
				IF cSucursal = "0000"  THEN   -- Todos los convenios y todas las sucursales
					FOREACH
						SELECT numcategoria, numconvenio 
						INTO cNumcategoria, cNumconvenio
						FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio					
						FOREACH
							SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
							SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
							SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_conciliaciontotalporconvenio
							WHERE fecha_pago::DATE  >= dFechaIni
							AND fecha_pago::DATE  <= dFechaFin
							AND numcategoria = cNumcategoria
							AND numconvenio = cNumconvenio
							GROUP BY nomconvenio, id_sucursal
							ORDER BY 2,1

							RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH;
					END FOREACH;
				ELSE   --Todos los convenios y una sucursal
					FOREACH
						SELECT numcategoria, numconvenio 
						INTO cNumcategoria, cNumconvenio
						FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
						FOREACH
							SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
							SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
							SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_conciliaciontotalporconvenio
							WHERE fecha_pago::DATE  >= dFechaIni
							AND fecha_pago::DATE  <= dFechaFin
							AND id_sucursal = cSucursal
							AND numcategoria = cNumcategoria
							AND numconvenio = cNumconvenio
							GROUP BY nomconvenio, id_sucursal
							ORDER BY 2,1

							RETURN cCodRet, cIdSucursal, iNumPagos,  cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH
					END FOREACH;
				END IF;
			ELSE
				IF cSucursal = "0000"  THEN   -- Un convenio y todas las sucursales
					FOREACH
						SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
						SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
						SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_conciliaciontotalporconvenio
						WHERE fecha_pago::DATE  >= dFechaIni
						AND fecha_pago::DATE  <= dFechaFin
						AND numcategoria = cNumcategoria
						AND numconvenio = cNumconvenio
						GROUP BY nomconvenio, id_sucursal
						ORDER BY 2,1

						RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						WITH RESUME;
					END FOREACH;
				ELSE   --Un convenio y una sucursal
					FOREACH
						SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
						SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
						SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_conciliaciontotalporconvenio
						WHERE fecha_pago::DATE  >= dFechaIni
						AND fecha_pago::DATE  <= dFechaFin
						AND numcategoria = cNumcategoria
						AND numconvenio = cNumconvenio
						AND id_sucursal = cSucursal
						GROUP BY nomconvenio,id_sucursal					
					
					END FOREACH;
					
					RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;

				END IF;

			END IF;
		ELSE --Proceso anterior consultando los movimiento
		
			IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
			ELSE
				IF cConvenio = "00000" THEN      -- Todos los convenios
					IF cSucursal = "0000"  THEN   -- Todos los convenios y todas las sucursales
						FOREACH
							SELECT numcategoria, numconvenio 
							INTO cNumcategoria, cNumconvenio
							FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
							FOREACH
								SELECT TRIM(b.id_sucursal),TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
								SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
								SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
								INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
								WHERE b.fecha_pago::DATE  >= dFechaIni
								AND b.fecha_pago::DATE  <= dFechaFin
								AND a.numcategoria = b.numcategoria
								AND a.numconvenio = b.numconvenio
								AND b.numcategoria = cNumcategoria
								AND b.numconvenio = cNumconvenio
								AND b.status_cancelado <> 'S'
								AND flag_confirmacion_central = 1
								AND flag_confirmacion_sucursal = 1
								GROUP BY a.nomconvenio, b.id_sucursal
								ORDER BY 2,1

								RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								WITH RESUME;

							END FOREACH;
						END FOREACH;
					ELSE   --Todos los convenios y una sucursal
						FOREACH
							SELECT numcategoria, numconvenio 
							INTO cNumcategoria, cNumconvenio
							FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
							FOREACH
								SELECT TRIM(b.id_sucursal)AS id_sucursal, TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
								SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
								SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
								INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
								WHERE b.fecha_pago::DATE  >= dFechaIni
								AND b.fecha_pago::DATE  <= dFechaFin
								AND a.numcategoria = b.numcategoria
								AND a.numconvenio = b.numconvenio
								AND b.numcategoria = cNumcategoria
								AND b.numconvenio = cNumconvenio
								AND b.id_sucursal = cSucursal
								AND b.status_cancelado <> 'S'
								AND flag_confirmacion_central = 1
								AND flag_confirmacion_sucursal = 1
								GROUP BY a.nomconvenio, b.id_sucursal
								ORDER BY 2, 1

								RETURN cCodRet, cIdSucursal, iNumPagos,  cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								WITH RESUME;
							END FOREACH
						END FOREACH;
					END IF;
				ELSE
					IF cSucursal = "0000"  THEN   -- Un convenio y todas las sucursales
						FOREACH
							SELECT TRIM(b.id_sucursal), TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
							SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
							SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
							WHERE b.fecha_pago::DATE  >= dFechaIni
							AND b.fecha_pago::DATE  <= dFechaFin
							AND b.numcategoria = cNumcategoria
							AND b.numconvenio = cNumconvenio
							AND b.status_cancelado <> 'S'
							AND a.numcategoria = b.numcategoria
							AND a.numconvenio = b.numconvenio
							AND flag_confirmacion_central = 1
							AND flag_confirmacion_sucursal = 1
							GROUP BY a.nomconvenio, b.id_sucursal
							ORDER BY 2, 1

							RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH;
					ELSE   --Un convenio y una sucursal
						SELECT TRIM(b.id_sucursal), TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
						SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
						SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio , iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
						WHERE b.fecha_pago::DATE  >= dFechaIni
						AND b.fecha_pago::DATE  <= dFechaFin
						AND b.numcategoria = cNumcategoria
						AND b.numconvenio = cNumconvenio
						AND b.status_cancelado <> 'S'
						AND a.numcategoria = b.numcategoria
						AND a.numconvenio = b.numconvenio
						AND b.id_sucursal = cSucursal
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY a.nomconvenio, b.id_sucursal;

						RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;

					END IF;

				END IF;

			END IF;
		
		END IF;

    END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener los totales captados por convenio en un rango de fechas especificas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080905',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzaservcpl_pba()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cReferencia1			CHAR(15);
DEFINE cRutaArchDet		CHAR(100);
DEFINE cRutaArchCif		CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cStmt2				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE dFecha_Hoy				DATE;
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE dFechaPago			CHAR(10);
DEFINE cMovimiento			CHAR(2);
DEFINE cTipoMovimiento		CHAR(2);
DEFINE iImporte_Pago		INTEGER;
DEFINE dFecha_Pago			CHAR(10);
DEFINE cTienda				CHAR(4);
DEFINE iNum_Empleado		INTEGER;
DEFINE cEmpresa				CHAR(1);
DEFINE iCiudadCop				INTEGER;
DEFINE cDescripcion			CHAR(50);
DEFINE iCampoFuturo1		INTEGER;
DEFINE iCampoFuturo2		INTEGER;
DEFINE iCampoFuturo3		INTEGER;
DEFINE iCampoFuturo4		INTEGER;
DEFINE cCaja				CHAR(4);
DEFINE iNumeroTicket		BIGINT;
DEFINE iCantidadMovimientos	BIGINT;
DEFINE cStatus				CHAR(1);
DEFINE cFechaFormato		CHAR(10);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET cMensaje				= 'PROCESO EXITOSO';
LET iSqlErr					= 0;
LET cCategoria				= '';
LET cConvenio				= '';
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET iImporte_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchDet			= '/home/systelmex/pagoserviciosdetalleaaaammdd.txt';
LET cRutaArchCif			= '/home/systelmex/pagoservicioscifraAAAAMMDD.txt';
LET iCuantos				= 0;
LET cStmt					= '';
LET cStmt2					='';
LET dFecha_Hoy				= DATE(1);
LET dFechaPago				= '';
LET cMovimiento			= '';
LET cTipoMovimiento		= '';
LET iImporte_Pago		= 0;
LET dFecha_Pago			= '';
LET cTienda				= '0';
LET iNum_Empleado		= 0;
LET cEmpresa				= '';
LET iCiudadCop				= 9999;
LET cDescripcion			= '';
LET iCampoFuturo1		= 0;
LET iCampoFuturo2		= 0;
LET iCampoFuturo3		= 0;
LET iCampoFuturo4		= 0;
LET cCaja				= '0';
LET iNumeroTicket		= 0;
LET iCantidadMovimientos = 0;
LET cStatus  			= '0';
LET cFechaFormato		= '1900-01-01';

	--SET DEBUG FILE TO  '/informix/adrian/sp_generaarchivocobranzaservcpl.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";		

		IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='IND_AC_SC' and fecha_proceso = dFecha_Hoy) THEN
				INSERT INTO bdisac:"informix".sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert) 
				VALUES('IND_AC_SC',dFecha_Hoy,'0','informix',current);
		ELSE
			SELECT status 
			INTO cStatus
			FROM bdisac:"informix".sac_procesos_jobs 
			WHERE proceso='IND_AC_SC' and fecha_proceso = dFecha_Hoy;			
		END IF;
		
		IF cStatus = '0' THEN
		
			--ASIGNA VALOR A LAS VARIABLES
			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');			
			
			--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
			LET cRutaArchDet = REPLACE(cRutaArchDet,'aaaa',cAnio);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'mm',cMes);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'dd',cDia);								
			LET cRutaArchCif = REPLACE(cRutaArchCif,'AAAA',cAnio);
			LET cRutaArchCif = REPLACE(cRutaArchCif,'MM',cMes);
			LET cRutaArchCif = REPLACE(cRutaArchCif,'DD',cDia);					

			--SERVICIOS DE COPPEL ACTIVOS EN BANCO O COPPEL
			FOREACH
				
				SELECT numcategoria, numconvenio, TRIM(movimiento), TRIM(tipomovimiento), TRIM(descripcion)
				INTO cCategoria, cConvenio, cMovimiento, cTipoMovimiento, cDescripcion
				FROM "informix".sac_servicios_cpl		
				
				--ARCHIVO DETALLE
				FOREACH
				
					SELECT importe_pago::integer,
					fecha_pago,
					case when origen = 'CPL' then sucursal_cpl else id_sucursal end,
					usuario::integer,
					case when origen = 'CPL' then 'C' else 'B' end,
					case when origen = 'CPL' then caja_cpl else '0' end,
					folio_suc,
					folio_operacion::integer,
					referencia1,
					flag_confirmacion_central,
					flag_confirmacion_sucursal
					INTO iImporte_Pago, dFechaPago, cTienda, iNum_Empleado, cEmpresa, cCaja, cFolio, iNumeroTicket, cReferencia1, iFlagCen, iFlagSuc
					FROM "informix".sac_movimientos
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio				
					AND fecha_pago = dFecha_Hoy
					AND status_cancelado <> 'S'
					AND (flag_confirmacion_central = 1
					OR flag_confirmacion_sucursal = 1)
						
					--OBTENER EL NUMERO DE CIUDAD CATALOGO COPPEL
					IF EXISTS (SELECT * FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_catciudades b
					WHERE a.sucursal = cTienda AND a.ciudad = b.numerociudad ) THEN
					
						SELECT b.numerociudadcoppel 
						INTO iCiudadCop
						FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_catciudades b
						WHERE a.sucursal = cTienda AND a.ciudad = b.numerociudad;
					ELSE
						LET iCiudadCop = 9999;
					END IF;

					--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
					IF iFlagCen = 0 OR iFlagSuc = 0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							END IF;
						END IF;
					END IF;

					IF iCuantos > 0 THEN
						UPDATE "informix".sac_movimientoshistorial SET flag_confirmacion_sucursal = '1'
						WHERE numcategoria = cCategoria
						AND numconvenio = cConvenio
						AND fecha_pago = dFechaPago
						AND folio_suc = cFolio
						AND referencia1 = cReferencia1
						AND status_cancelado <> 'S'
						AND flag_confirmacion_sucursal = 0;
						
						INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
						VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
					END IF;		

					LET cFechaFormato = YEAR(dFechaPago) || '-' || LPAD(MONTH(dFechaPago),2,'0') || '-' || LPAD(DAY(dFechaPago),2,'0');

					--IMPRIME RENGLON DE LAS OPERACIONES
					LET cStmt = 'echo "' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iImporte_Pago || '|' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iNum_Empleado || '|' || TRIM(cEmpresa) || '|' || iCiudadCop || '|' || TRIM(cDescripcion) || '|' || TRIM(cCaja) || '|' || TRIM(cFolio) || '|' || iNumeroTicket || '|' || iCampoFuturo1 || '|' || iCampoFuturo2 || '|' || iCampoFuturo3 || '|' || iCampoFuturo4 || '" >> ' || cRutaArchDet;
					SYSTEM cStmt;
					
				END FOREACH;
				
				--ARCHIVO CIFRA				
				FOREACH
				
					SELECT fecha_pago,			
					case when origen = 'CPL' then sucursal_cpl else id_sucursal end tienda,
					SUM(importe_pago::integer) importe,
					count(*) AS cantidad_movimientos, 
					case when origen = 'CPL' then 'C' else 'B' end empresa								
					INTO dFecha_Pago, cTienda, iImporte_Pago, iCantidadMovimientos, cEmpresa
					FROM "informix".sac_movimientos
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago = dFecha_Hoy
					AND status_cancelado <> 'S'
					AND (flag_confirmacion_central = 1
					OR flag_confirmacion_sucursal = 1)
					GROUP BY fecha_pago, empresa, tienda
					
					LET cFechaFormato = YEAR(dFecha_Pago) || '-' || LPAD(MONTH(dFecha_Pago),2,'0') || '-' || LPAD(DAY(dFecha_Pago),2,'0');				
					
					--IMPRIME RENGLON DE LAS OPERACIONES
					LET cStmt2 = 'echo "' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iImporte_Pago || '|' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iCantidadMovimientos || '|' || TRIM(cEmpresa) || '" >> ' || cRutaArchCif;
					SYSTEM cStmt2;
				
				END FOREACH;
				
			END FOREACH;

			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt = 'echo "' || '" >> ' || cRutaArchDet;
			SYSTEM cStmt;			
			
			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt2 = 'echo "' || '" >> ' || cRutaArchCif;
			SYSTEM cStmt2;				
			
		END IF;

		UPDATE bdisac:"informix".sac_procesos_jobs SET status = '1' WHERE proceso='IND_AC_SC' and fecha_proceso = dFecha_Hoy;
		RETURN cCodRet, cMensaje; 
		
	END;
END PROCEDURE;