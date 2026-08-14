CREATE PROCEDURE "informix".sp_generaarchivocobranzayvesrocher(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cReferencia1			CHAR(17);
DEFINE cRutaArchRocher			CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE cTpoOperacion			CHAR(1);
DEFINE dFechaIni				DATE;
DEFINE dFecha_Hoy				DATE;
DEFINE dFecha_Ant				DATE;
DEFINE iImporte_Comision		DECIMAL(11,0);
DEFINE iSumaImporte_Comision		DECIMAL(11,0);
DEFINE iImp_IVA_Com			DECIMAL(11,0);
DEFINE iSumaImporte_IVA_Comision	DECIMAL(11,0);
DEFINE iImporte_Pago			DECIMAL(14,0);
DEFINE iTotal_Pago			DECIMAL(11,0);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos				INTEGER;
DEFINE cNombrelegalempresa		CHAR(40);
DEFINE cNomes				CHAR(15);
DEFINE cHora				CHAR(2);
DEFINE cMinuto	  			CHAR(2);
DEFINE cSucursal				CHAR(5);
DEFINE dFechaPago				DATE;
DEFINE cHoraRuta				CHAR(2);
DEFINE cMinutoRuta			CHAR(2);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3  FOR 3);
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago				= 0;
LET iImporte_Comision			= 0;
LET iSumaImporte_Comision		= 0;
LET iImp_IVA_Com				= 0;
LET iSumaImporte_IVA_Comision		= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchRocher			= '';
LET	iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET dFecha_Ant				= DATE(1);
LET cTpoOperacion				= 'D';
LET iNumPagos				= 0;
LET cNombrelegalempresa			= '';
LET cNomes					= '';
LET cHora					= '';
LET cMinuto					= '';
LET cSucursal				= '';
LET dFechaPago				= DATE(1);
LET cHoraRuta				= '';
LET cMinutoRuta				= '';

--	SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_generaarchivocobranzayvesrocher.out';
--	TRACE ON;
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
		LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');

		--PONE NOMBRE DEL MES
		IF cMes='12' THEN
			LET cNomes =' DE DICIEMBRE DE ';
		END IF;
		IF cMes='11' THEN
			LET cNomes =' DE NOVIEMBRE DE ';
		END IF;
		IF cMes='10' THEN
			LET cNomes =' DE OCTUBRE DE ';
		END IF;
		IF cMes='09' THEN
			LET cNomes =' DE SEPTIEMBRE DE ';
		END IF;
		IF cMes='08' THEN
			LET cNomes =' DE AGOSTO DE ';
		END IF;
		IF cMes='07' THEN
			LET cNomes =' DE JULIO DE ';
		END IF;
		IF cMes='06' THEN
			LET cNomes =' DE JUNIO DE ';
		END IF;
		IF cMes='05' THEN
			LET cNomes =' DE MAYO DE ';
		END IF;
		IF cMes='04' THEN
			LET cNomes =' DE ABRIL DE ';
		END IF;
		IF cMes='03' THEN
			LET cNomes =' DE MARZO DE ';
		END IF;
		IF cMes='02' THEN
			LET cNomes =' DE FEBRERO DE ';
		END IF;
		IF cMes='01' THEN
			LET cNomes =' DE ENERO DE ';
		END IF;

		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza),nomlegalempresa
		INTO cRutaArchRocher,cNombrelegalempresa
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		SELECT LPAD(SUBSTR(DBINFO('utc_to_datetime', sh_curtime),12,2),2,'0'), LPAD(SUBSTR(DBINFO('utc_to_datetime', sh_curtime),15,2),2,'0')
		INTO cHoraRuta,cMinutoRuta
		FROM sysmaster:"informix".sysshmvals;
		
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'mm',cMinutoRuta);
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'hh',cHoraRuta);
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'YYYY',cAnio);
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'MM',cMes);
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'DD',cDia);

		--IMPRIME EL ENCABEZADO DEL ARCHIVO
		LET cStmt='echo "' || cNombrelegalempresa || '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
		LET cStmt='echo "' || 'FECHA: ' ||cDia||" "||TRIM(cNomes)||" "||cAnio|| '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;

		FOREACH

			SELECT fecha_pago,
				LPAD(DAY(fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				LPAD(SUBSTR(fecha_insert,12,2),2,'0'),
				LPAD(SUBSTR(fecha_insert,15,2),2,'0'),
				id_sucursal,
				folio_suc,
				referencia1,
				importe_pago*100,
				importe_comision_convenio * 100,
				iva_comision_convenio * 100,
				flag_confirmacion_central,
				flag_confirmacion_sucursal
				INTO   dFechaPago,cDiaPago,cMesPago,cAnioPago,cHora,cMinuto,cSucursal,cFolio,cReferencia1,iImporte_Pago,iImporte_Comision,iImp_IVA_Com,iFlagCen,iFlagSuc
				FROM "informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)

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
					LET iCuantos = 0;
				END IF;

				LET iSumaImporte_Comision = iSumaImporte_Comision + iImporte_Comision;
				LET iSumaImporte_IVA_Comision = iSumaImporte_IVA_Comision + iImp_IVA_Com;
				LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
				LET iNumPagos = iNumPagos + 1;

				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || cHora || cMinuto || LPAD(TRIM(cSucursal), 5, '0')|| LPAD(cFolio, 16, '0') || LPAD(TRIM(cReferencia1), 17, '0') || LPAD(iImporte_Pago, 14, '0') || '" >> ' || cRutaArchRocher;
				SYSTEM cStmt;
		END FOREACH;

		LET cReferencia1 = '';
		LET cFolio       = '';
		LET cHora		 = '';
		LET cMinuto		 = '';
		LET cSucursal	 = '';

		--IMPRIME EL RENGLON COMISIONES
		IF iSumaImporte_Comision <> 0 THEN
			LET cTpoOperacion = 'C';
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago ||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0') ||LPAD(TRIM(cSucursal), 5, '0') ||LPAD(TRIM(cFolio), 16, '0') || LPAD(TRIM(cReferencia1), 17, '0') || LPAD(iSumaImporte_Comision, 14, '0') || '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
		END IF;

		--IMPRIME EL RENGLON DEL IVA
		IF iSumaImporte_IVA_Comision <> 0 THEN
			LET cTpoOperacion = 'I';
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago ||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0') ||LPAD(TRIM(cSucursal), 5, '0')||LPAD(TRIM(cFolio), 16, '0') || LPAD(TRIM(cReferencia1), 17, '0') || LPAD(iSumaImporte_IVA_Comision, 14, '0') || '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
		END IF;

		--IMPRIME EL RENGLON DE TOTAL
		IF iNumPagos <> 0 THEN
			LET cTpoOperacion = 'T';
			LET iTotal_Pago = ((iTotal_Pago - iSumaImporte_Comision) - iSumaImporte_IVA_Comision);

			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago ||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0')||LPAD(TRIM(cSucursal), 5, '0')||LPAD(TRIM(cFolio), 16, '0') || LPAD(TRIM(TO_CHAR(iNumPagos)), 15, '0')  ||LPAD(iTotal_Pago, 14, '0')|| '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
		END IF;

		--SI NO SE ENCONTRARON REGISTROS SE IMPRIME TOTAL EN CEROS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cTpoOperacion = 'T';
			LET cStmt = 'echo "' || cTpoOperacion || LPAD(TRIM(cDia),2,'0') || LPAD(TRIM(cMes),2,'0') || LPAD(TRIM(cAnio),4,'0') ||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0')||LPAD(TRIM(cSucursal), 5, '0')||LPAD(TRIM(cFolio), 16, '0')||LPAD(TRIM(cReferencia1), 17, '0') || LPAD(iTotal_Pago, 14, '0') || '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
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

		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: Vazquez Herrera Hugo Guadalupe',
'DESCRIPCIÓN: SP que genera un archivo .txt donde se guardan las operacines de pagos rocher.',
'FOLIO:1454',
'FECHA:12/08/2014',
'VERSIÓN: ',
'BASE DE DATOS: bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzacardif(pId_convenio CHAR(5))
	
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr			INTEGER;
	DEFINE cCategoria		CHAR(2);
	DEFINE cConvenio		CHAR(3);
	DEFINE dFechaIni		DATE;
	DEFINE dFecha_Hoy		DATE;
	DEFINE cRutaArch		CHAR(100);
	DEFINE cNomArch			CHAR(30);
	DEFINE cMes				CHAR(2);
	DEFINE cDia				CHAR(2);
	DEFINE cAnio			CHAR(4);
	DEFINE cStmt			CHAR(250);
	
	
	DEFINE cNumPoliza		CHAR(50);
	DEFINE cTipoPlan		CHAR(1);
	DEFINE dFechaAlta		DATE;
	DEFINE dFechaVenc 		DATE;
	DEFINE dFechaInsert		DATE;
	DEFINE cMontoPagado		CHAR(100);
	DEFINE pEmpresa			CHAR(3);
	DEFINE cEstatusConvenio CHAR(1);
	DEFINE cStatus_cancelado CHAR(1);
	DEFINE cFolioSuc 		CHAR (16);
	DEFINE vContador 		INTEGER;
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_generaarchivocobranzacardif.out';
	--TRACE ON;
	
	LET cCodRet				= '00000';
	LET cCategoria			= SUBSTRING(pId_convenio FROM 1 FOR 2);
	LET cConvenio 			= SUBSTRING(pId_convenio FROM 3 FOR 3);
	LET cRutaArch 			= '';
	LET cNomArch 			= '';
	LET cMes 				= '';
	LET cDia 				= '';
	LET cAnio 				= '';
	LET cStmt				= '';
	
	LET cNumPoliza			= '';
	LET cTipoPlan			= '';
	LET cMontoPagado		= '';
	LET cStatus_cancelado   = '';
	LET cFolioSuc			= '';
	LET pEmpresa 			= '001';
	LET vContador 			= 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE bdisac:"informix".sac_controlarchivoscobranza 
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT statusconvenio
		INTO cEstatusConvenio
		FROM sac_convenios 
		WHERE numcategoria = cCategoria 
		AND numconvenio = cConvenio;
		
		IF cEstatusConvenio = 'A' THEN
		
			SELECT fecha_hoy
			INTO dFecha_Hoy
			FROM bdisac:"informix".sac_fechas
			WHERE empresa = pEmpresa;

			SELECT fecha_ultimo_archivo
			INTO dFechaIni
			FROM bdisac:"informix".sac_controlarchivoscobranza
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio;

			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = YEAR(dFecha_Hoy );
			
			SELECT TRIM(ruta_archivo_cobranza), TRIM(nombre_archivo_cobranza)
			INTO cRutaArch, cNomArch
			FROM bdisac:"informix".sac_convenios
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio;
			
			LET cNomArch = REPLACE(cNomArch,'AAAA',cAnio);
			LET cNomArch = REPLACE(cNomArch,'MM',cMes);
			LET cNomArch = REPLACE(cNomArch,'DD',cDia);
			
			LET cNomArch = TRIM(cNomArch) || '.txt';
			
			LET cRutaArch = TRIM(cRutaArch) || TRIM(cNomArch);
			
			Drop table if exists sac_movimientoshistorial_TMP09023;
			LET cStmt = 'rm -rf ' || cRutaArch || '/' || cNomArch;
			SYSTEM cStmt;
			
			SELECT * FROM bdisac:"informix".sac_movimientoshistorial
				WHERE fecha_pago = dFecha_Hoy
				AND numcategoria = cCategoria AND numconvenio = cConvenio
				INTO TEMP sac_movimientoshistorial_TMP09023  WITH NO LOG;
			
			FOREACH
				
				/*
				SELECT num_poliza, tipo_plan, fecha_alta, fecha_vencimiento, fecha_insert 
				INTO cNumPoliza, cTipoPlan, dFechaAlta, dFechaVenc, dFechaInsert 
				FROM bdisac:"informix".sac_cardif_migrante
				WHERE fecha_insert = dFecha_Hoy AND estatus = '1' AND NVL(folio_suc,"") <> "" --estatus=1 (Activo)
				*/
				
				
				SELECT a.num_poliza, a.tipo_plan, a.fecha_alta, a.fecha_vencimiento, a.fecha_insert ,b.status_cancelado,a.folio_suc
				INTO cNumPoliza, cTipoPlan, dFechaAlta, dFechaVenc, dFechaInsert, cStatus_cancelado, cFolioSuc
				FROM bdisac:"informix".sac_cardif_migrante a
                LEFT JOIN sac_movimientoshistorial_TMP09023 b on a.folio_suc = b.folio_suc
				WHERE a.fecha_insert::date = dFecha_Hoy  AND a.estatus = '1' AND NVL(a.folio_suc,"") <> "" 

				LET cMontoPagado = '';
				
				IF cTipoPlan = '4' THEN --Anual
					SELECT valor 
					INTO cMontoPagado
					FROM bdisac:"informix".sac_param 
					WHERE cod_param = '126';				
				ELIF cTipoPlan = '5' THEN --Semestral
					SELECT valor 
					INTO cMontoPagado
					FROM bdisac:"informix".sac_param 
					WHERE cod_param = '127';
                ELIF cTipoPlan = '6' THEN --Anual Paisano
					SELECT valor 
					INTO cMontoPagado
					FROM bdisac:"informix".sac_param 
					WHERE cod_param = '155';
                ELIF cTipoPlan = '7' THEN --Semestral Paisano
					SELECT valor 
					INTO cMontoPagado
					FROM bdisac:"informix".sac_param 
					WHERE cod_param = '156';
				END IF;
				
				
				IF  cStatus_cancelado = 'S' THEN 

					UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 5, observ_siniestro = 'Cambio estatus 1 a 5 x Estado de Cuenta'
					WHERE num_poliza = cNumPoliza
					AND folio_suc = cFolioSuc
					AND tipo_plan = cTipoPlan;

				ELSE
					--IMPRIME RENGLON DE LAS OPERACIONES
					LET cStmt = 'echo "' || RPAD(trim(cNumPoliza), 35) || '|' || RPAD(trim(cTipoPlan), 3) || '|' || dFechaAlta || '|' || dFechaVenc || '|' || dFechaInsert  || '|' || RPAD(trim(cMontoPagado), 20) ||  '" >> ' || cRutaArch;
					SYSTEM cStmt;
				END IF;
				
				
				LET vContador = vContador + 1;
				
			END FOREACH;
			
			IF vContador = 0 THEN
				--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
				LET cStmt = 'echo "' || '" >> ' || cRutaArch;
				SYSTEM cStmt;
			END IF;
			
			UPDATE "informix".sac_controlarchivoscobranza
			SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio;
			
			Drop table if exists sac_movimientoshistorial_TMP09023;

		END IF;
	END;
END PROCEDURE;