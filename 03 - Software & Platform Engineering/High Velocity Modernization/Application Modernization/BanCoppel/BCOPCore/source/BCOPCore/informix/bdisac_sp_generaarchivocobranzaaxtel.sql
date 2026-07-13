CREATE PROCEDURE "informix".sp_generaarchivocobranzaaxtel(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(2);
DEFINE cAnio2				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cMovimiento			CHAR(2);
DEFINE cTipoMovimiento		CHAR(2);
DEFINE cReferencia1			CHAR(30);
DEFINE cRutaArchAxtel		CHAR(100);  
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE cTpoOperacion			CHAR(1);
DEFINE dFechaIni				DATE;
DEFINE dFecha_Hoy				DATE;
DEFINE iImporte_Pago			DECIMAL(16,2);
DEFINE iTotal_Pago			DECIMAL(16,2);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos				INTEGER;
DEFINE cSucursal				CHAR(4);
DEFINE dFechaPago				DATE;
DEFINE iRelleno				INTEGER;
DEFINE iFlagCopp			INTEGER;
DEFINE vDias                INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3 FOR 3);
LET cMovimiento				= '';
LET cTipoMovimiento			= '';
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cAnio2					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago				= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchAxtel			= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET cTpoOperacion				= '1';
LET iNumPagos				= 0;
LET cSucursal				= '';
LET dFechaPago				= DATE(1);
LET iRelleno				= 0;
LET iFlagCopp           	= 0;
LET vDias               	= 0;

	---SET DEBUG FILE TO  '/informix/rer/sp_generaarchivocobranzaaxtel.out';
	---TRACE ON;
	--SET DEBUG FILE TO  '/tmp/adrian/sp_generaarchivocobranzaaxtel.out';
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

		--ASIGNA VALOR A LAS VARIABLES
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		LET cAnio2 = YEAR(dFecha_Hoy ::DATE); 
		
		
				
		
		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchAxtel
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		
		LET cRutaArchAxtel = REPLACE(cRutaArchAxtel,'DD',cDia);	
		LET cRutaArchAxtel = REPLACE(cRutaArchAxtel,'MM',cMes);
		LET cRutaArchAxtel = REPLACE(cRutaArchAxtel,'AA',cAnio);
		
		--Borramos evidencia de archivo generado anteriormente (En caso de existir)
		LET cStmt = 'rm -f ' || cRutaArchAxtel;
		SYSTEM cStmt;
		
		--OBTENGO VALOR DE DIAS DE GRACIA
		SELECT valor
		INTO   vDias
		FROM   "informix".sac_param
		WHERE  empresa   = '001'
		AND    cod_param = '118';
		
		--OBTENGO EL TIPO DE MOVIMIENTO
		SELECT movimiento, tipomovimiento
		INTO   cMovimiento, cTipoMovimiento
		FROM   sac_servicios_cpl
		WHERE  numcategoria = cCategoria
		AND    numconvenio  = cConvenio;

		--Reviso si existe archivo importado correctamente del dÃ­a
		IF (SELECT COUNT(*)
			FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
			WHERE  movimiento = cMovimiento
			AND    tipomovimiento = cTipoMovimiento
			AND    st_conciliado = '1') > 0 THEN
			LET iFlagCopp = 1;
		END IF;
		
			

		FOREACH

			SELECT fecha_pago,
				LPAD(DAY(fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				case when origen = 'CPL' then NVL(sucursal_cpl,'') else NVL(id_sucursal,'') end,
				NVL(folio_suc,''),
				NVL(referencia1,''),
				NVL(importe_pago,0),
				NVL(flag_confirmacion_central,0),
				NVL(flag_confirmacion_sucursal,0)
				INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM "informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)
				AND origen                    != "CPL"				

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
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
				END IF;
				
				LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
				LET iNumPagos = iNumPagos + 1;

				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || cTpoOperacion || ' ,' || 'TDA ' || RPAD(cSucursal,21,' ') || ',' || cAnioPago || cMesPago || cDiaPago || ',' || '00000' || ',' || SUBSTR(cReferencia1,1,8) || SUBSTR(cReferencia1,9,8) || '000000000' || ',' || SUBSTR(cReferencia1,17,1) || LPAD(iRelleno,24,0) || ',' || LPAD(iImporte_Pago,16,0) || '" >> ' || cRutaArchAxtel;
				SYSTEM cStmt;
		END FOREACH;
		
		IF iFlagCopp = 1 THEN
		
			FOREACH
				--Solo obtengo aquellos registros que estÃ¡n conciliados
				SELECT sm.fecha_pago,
				LPAD(DAY(sm.fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(sm.fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(sm.fecha_pago::DATE), 4, '0'),
				case when origen = 'CPL' then NVL(sm.sucursal_cpl,'') else NVL(sm.id_sucursal,'') end,
				NVL(sm.folio_suc,''),
				NVL(sm.referencia1,''),
				NVL(sm.importe_pago,0),
				NVL(sm.flag_confirmacion_central,0),
				NVL(sm.flag_confirmacion_sucursal,0)
				INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM bdisac:"informix".sac_movimientoshistorial sm,
					 bdisac:"informix".sac_conciliacion_bcpl_cpl sc
				WHERE    sm.numcategoria     = cCategoria
				AND	     sm.numconvenio      = cConvenio
				AND      sm.fecha_pago       > dFechaIni - vDias
				AND      sm.fecha_pago       <= dFecha_Hoy
				AND      sm.status_cancelado <> 'S'
				AND      sm.origen           = "CPL"
				AND      sm.folio_suc        = sc.foliosucursal
				AND      sm.fecha_pago       = sc.fechapago
				AND      (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
				AND      sc.st_conciliado           = 1
				ORDER BY sm.fecha_pago DESC

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
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
				END IF;
				
				LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
				LET iNumPagos = iNumPagos + 1;

				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || cTpoOperacion || ' ,' || 'TDA ' || RPAD(cSucursal,21,' ') || ',' || cAnioPago || cMesPago || cDiaPago || ',' || '00000' || ',' || SUBSTR(cReferencia1,1,8) || SUBSTR(cReferencia1,9,8) || '000000000' || ',' || SUBSTR(cReferencia1,17,1) || LPAD(iRelleno,24,0) || ',' || LPAD(iImporte_Pago,16,0) || '" >> ' || cRutaArchAxtel;
				SYSTEM cStmt;

			END FOREACH;
			
		END IF;
		
		--Busco todos los registros de la tabla sac_bitacora_flags para actualizar en sac_movimientoshistorial
		FOREACH
            SELECT TRIM(referencia) AS referencia, folio_suc, fecha_pago
			INTO   cReferencia1, cFolio, dFechaPago
            FROM   bdisac:"informix".sac_bitacora_flags
            WHERE  numcategoria       = cCategoria
			AND    numconvenio        = cConvenio
			AND    fecha_insert::DATE = TODAY
			
			--Actualizo bandera de 0 a 1
			UPDATE bdisac:sac_movimientoshistorial
			SET    flag_confirmacion_sucursal = '1'
			WHERE  numcategoria               = cCategoria
			AND    numconvenio                = cConvenio
			AND    fecha_pago                 = dFechaPago
			AND    folio_suc                  = cFolio
			AND    referencia1                = cReferencia1
			AND    status_cancelado           <> 'S'
			AND    flag_confirmacion_sucursal = 0;
			
		END FOREACH;
		
		--IMPRIME EL RENGLON DE TOTAL		
		LET cTpoOperacion = '2';
		LET cStmt = 'echo "' || cTpoOperacion || ' ,' || 'REGISTRO DE CONTROL      ' || ',' || cAnio2 || cMEs || cDia || ',' || '00000' || ',' || LPAD(iNumPagos,25,0) || ',' || LPAD(iRelleno,25,0) || ',' || LPAD(iTotal_Pago,16,0) || '" >> ' || cRutaArchAxtel;
		SYSTEM cStmt;		
		
		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
;