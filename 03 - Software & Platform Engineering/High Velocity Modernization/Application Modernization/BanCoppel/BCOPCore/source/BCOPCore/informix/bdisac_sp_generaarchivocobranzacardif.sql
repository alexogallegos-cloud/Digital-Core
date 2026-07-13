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