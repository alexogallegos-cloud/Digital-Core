CREATE PROCEDURE "informix".sp_generaarchivocobranzajapac(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(2);
DEFINE cAnio2				CHAR(4);
DEFINE cDiaI				CHAR(2);
DEFINE cMesI				CHAR(2);
DEFINE cAnioI				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cReferencia1			CHAR(22);
DEFINE cRutaArchJAPAC		CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE cTpoOperacion			CHAR(1);
DEFINE dFechaIni				DATE;
DEFINE dFecha_Hoy				DATE;
DEFINE iImporte_Pago			DECIMAL(9,0);
DEFINE iTotal_Pago			DECIMAL(12,0);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos				INTEGER;
DEFINE cHora				CHAR(2);
DEFINE cMinuto	  			CHAR(2);
DEFINE cSucursal				CHAR(4);
DEFINE dFechaPago				DATE;
DEFINE cNombreSuc			CHAR(25);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3 FOR 3);
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cAnio2					= '';
LET cDiaI					= '';
LET cMesI					= '';
LET cAnioI					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago				= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchJAPAC			= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET cTpoOperacion				= '2';
LET iNumPagos				= 0;
LET cHora					= '';
LET cMinuto					= '';
LET cSucursal				= '';
LET dFechaPago				= DATE(1);
LET cNombreSuc				= '';

	--SET DEBUG FILE TO  '/informix/adrian/sp_generaarchivocobranzajapac.out';
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

		--ASIGNA VALOR PARA FECHA INICIAL
		IF dFechaIni = dFecha_Hoy THEN
			LET cDiaI = LPAD(DAY(dFechaIni::DATE) , 2, '0');
		ELSE
			LET cDiaI = LPAD(DAY((dFechaIni + 1 UNITS DAY)::DATE) , 2, '0');
		END IF;
		LET cMEsI = LPAD(MONTH(dFechaIni::DATE), 2, '0');
		LET cAnioI = LPAD(YEAR(dFechaIni::DATE),4,'0');
		
		--ASIGNA VALOR PARA FECHA FIN
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		LET cAnio2 = YEAR(dFecha_Hoy ::DATE); 

		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchJAPAC
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		
		LET cRutaArchJAPAC = REPLACE(cRutaArchJAPAC,'DD',cDia);
		LET cRutaArchJAPAC = REPLACE(cRutaArchJAPAC,'MM',cMes);
		LET cRutaArchJAPAC = REPLACE(cRutaArchJAPAC,'AA',cAnio);
	

		--IMPRIME EL ENCABEZADO DEL ARCHIVO
		LET cStmt='echo "' || '1,001 JAPAC           ,' || cAnioI || cMEsI || cDiaI || ',' || cAnio2 || cMes || cDia || '" >> ' || cRutaArchJAPAC;
			SYSTEM cStmt;
			
		FOREACH

			SELECT fecha_pago,
				LPAD(DAY(fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				LPAD(SUBSTR(fecha_insert,12,2),2,'0'),
				LPAD(SUBSTR(fecha_insert,15,2),2,'0'),
				case when origen = 'CPL' then LPAD(REPLACE(NVL(sucursal_cpl,''),'','0'),4,'0') else LPAD(REPLACE(NVL(id_sucursal,''),'','0'),4,'0') end,
				NVL(folio_suc,''),
				NVL(referencia1,''),
				NVL(importe_pago,0)*100,
				NVL(flag_confirmacion_central,0),
				NVL(flag_confirmacion_sucursal,0)
				INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cHora,cMinuto,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM "informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)		
				
				IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal) THEN
					SELECT NVL(REPLACE(nombre,',',' '),'')
					INTO cNombreSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal;
				ELSE
					LET cNombreSuc = '';
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
				END IF;

				LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
				LET iNumPagos = iNumPagos + 1;

				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || cTpoOperacion || ',' || SUBSTR(cReferencia1,4,9) || ',' || SUBSTR(cReferencia1,13,9) || ',' || LPAD(iImporte_Pago,9,0) || ',' || cAnioPago || cMesPago || cDiaPago || ',' || cHora || cMinuto || '  ,' || cSucursal || ' ' || RPAD(cNombreSuc, 25,' ') || '" >> ' || cRutaArchJAPAC;
				SYSTEM cStmt;
		END FOREACH;		

		--IMPRIME RENGLON DE TOTAL
		LET cTpoOperacion = '3';			
		LET cStmt = 'echo "' || cTpoOperacion || ',' || RPAD((iNumPagos::CHAR), 4, ' ') || ',' || LPAD(iTotal_Pago, 12, 0) || '" >> ' || cRutaArchJAPAC;
		SYSTEM cStmt;
		
		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE;