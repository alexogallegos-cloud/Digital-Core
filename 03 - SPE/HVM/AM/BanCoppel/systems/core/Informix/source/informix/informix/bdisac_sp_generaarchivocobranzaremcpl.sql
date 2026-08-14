CREATE PROCEDURE "informix".sp_generaarchivocobranzaremcpl(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE iSqlErr						INTEGER;
DEFINE cDia							CHAR(2);
DEFINE cMes							CHAR(2);
DEFINE cAnio						CHAR(4);
DEFINE dFechaIni					DATE;
DEFINE dFecha_Hoy					DATE;	
DEFINE cRutaArchRemCpl				CHAR(38);
DEFINE cStmt						CHAR(500);
DEFINE vRegistro					CHAR(150);
DEFINE fechaArchivo                 CHAR(8);
DEFINE nombreArch                   CHAR(30);
DEFINE apuntador                    INTEGER;
DEFINE numRegistros                 INTEGER;
DEFINE cFolioSuc				    CHAR(20);
DEFINE cRef1      					CHAR(30);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET cRutaArchRemCpl			= '';
LET cStmt					= '';
LET fechaArchivo            = '';
LET nombreArch              = '';
LET apuntador               = 1;
LET numRegistros            = 0;
LET cRef1                   = '';
LET vRegistro               = '';
LET cFolioSuc               = '';

	--SET DEBUG FILE TO  '/RESPALDOSNEW/enrique/sp_generaarchivocobranzaremcpl.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE nom_rutina ='sp_generaarchivocobranzaremcpl';
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
		WHERE nom_rutina ='sp_generaarchivocobranzaremcpl';
		
		
--SI fecha_ultimo_archivo ES IGUAL A HOY, NO GENERA ARCHIVO
		IF dFechaIni = dFecha_Hoy THEN
			RETURN;
		END IF;
		

--ASIGNA VALOR A LAS VARIABLES  DE FECHA
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE),4,'0');
		LET fechaArchivo = TRIM(cAnio || cMEs || cDia); 


--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		
		SELECT distinct trim(ruta_archivo_cobranza) || trim(nombre_archivo_cobranza)  
		INTO cRutaArchRemCpl
		FROM "informix".sac_convenios 
		WHERE numcategoria='07' and numconvenio in('004','006','007','008','009') AND statusconvenio='A';


		
--REEMPLAZA LA MASCARA POR LA FECHA EN EL NOMBRE DEL ARCHIVO
		LET cRutaArchRemCpl = REPLACE(cRutaArchRemCpl,'AAAA',cAnio);
		LET cRutaArchRemCpl = REPLACE(cRutaArchRemCpl,'MM',cMes);
		LET cRutaArchRemCpl = REPLACE(cRutaArchRemCpl,'DD',cDia);



	--Busca movimientos en las fechas especificadas
		LET apuntador = 1; 
		FOREACH 
					SELECT 
					folio_suc, --folio,
					referencia1, --num_remesa,
					--rpad(Trim(nomconvenio),22,' ') || '|' ||--marca,
					(case when numconvenio='004' then 'BTS'
					    when numconvenio='006' then 'WESTERN UNION'
					    when numconvenio='007' then 'ORLANDI VALUTA'
					    when numconvenio='008' then 'VIGO'
					    when numconvenio='009' then 'APPRIZA'
					end) || '|' ||
					TO_CHAR(importe_pago, "<<<<<<<<<.##") || '|' ||--monto,
					--fecha_pago,
					year(fecha_pago) || lpad(month(fecha_pago),2,'0') || lpad(day(fecha_pago),2,'0') || '|' ||--fecha,
					hora || '|' ||sucursal_cpl
					INTO cFolioSuc,cRef1,vRegistro
					FROM sac_movimientoshistorial
					WHERE fecha_pago > dFechaIni and fecha_pago <= dFecha_Hoy 
					and origen='CPL' 
					and flag_confirmacion_central='1' 
					and flag_confirmacion_sucursal='1' 
					and status_cancelado <> 'S' 
					and (numcategoria='07' and numconvenio in('004','006','007','008','009'))
					order by fecha_insert asc
				
				SELECT COUNT(*) INTO numRegistros FROM sac_movimientoshistorial WHERE fecha_pago > dFechaIni and fecha_pago <= dFecha_Hoy and origen='CPL' and flag_confirmacion_central='1' and flag_confirmacion_sucursal='1' and status_cancelado <> 'S' and (numcategoria='07' and numconvenio in('004','006','007','008','009'));
				
				IF apuntador = numRegistros THEN

					IF exists(SELECT folio_suc FROM bdicheq:sc_movdia WHERE folio_suc=cFolioSuc and cancelad <> 'S') THEN

						LET cStmt = 'echo "' || trim(cFolioSuc) || '|' || trim(cRef1) || '|' || trim(vRegistro) ||  '\c"  >> ' || trim(cRutaArchRemCpl);
						SYSTEM cStmt;

					ELIF exists(SELECT folio_suc FROM bdicheq:sc_movhis WHERE folio_suc=cFolioSuc and cancelad <> 'S') THEN
							
						LET cStmt = 'echo "' || trim(cFolioSuc) || '|' || trim(cRef1) || '|' || trim(vRegistro) || '\c" >> ' || trim(cRutaArchRemCpl);
						SYSTEM cStmt;

					END IF;
				ELSE
					IF exists(SELECT folio_suc FROM bdicheq:sc_movdia WHERE folio_suc=cFolioSuc and cancelad <> 'S') THEN

						LET cStmt = 'echo "' || trim(cFolioSuc) || '|' || trim(cRef1) || '|' || trim(vRegistro) || '"  >> ' || trim(cRutaArchRemCpl);
						SYSTEM cStmt;

					ELIF exists(SELECT folio_suc FROM bdicheq:sc_movhis WHERE folio_suc=cFolioSuc and cancelad <> 'S') THEN
							
						LET cStmt = 'echo "' || trim(cFolioSuc) || '|' || trim(cRef1) || '|' || trim(vRegistro) || '" >> ' || trim(cRutaArchRemCpl);
						SYSTEM cStmt;

					END IF;
				END IF;
				LET apuntador = apuntador + 1;
		END FOREACH;
		
--SI NO HUBO MOVIMIENTOS GENERA ARCHIVO EN BLANCO
		IF DBINFO('sqlca.sqlerrd2')=0 THEN
			LET cStmt = 'echo "" >> ' || trim(cRutaArchRemCpl);
			SYSTEM cStmt;
		END IF;
		
		
		
--ACTUALIZA ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE nom_rutina ='sp_generaarchivocobranzaremcpl';

	END;
END PROCEDURE;