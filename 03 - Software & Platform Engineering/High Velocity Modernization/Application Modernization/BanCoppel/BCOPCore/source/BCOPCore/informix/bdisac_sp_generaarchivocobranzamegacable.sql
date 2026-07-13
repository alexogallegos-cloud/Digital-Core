CREATE PROCEDURE "informix".sp_generaarchivocobranzamegacable(pCatConv CHAR (5))

--DEFINIR VARIABLES
DEFINE iSqlErr          	INTEGER;
DEFINE cCodRet          	CHAR(5);
DEFINE cCategoria       	CHAR(2);
DEFINE cConvenio        	CHAR(3);
DEFINE cRutaArch			CHAR(100);
DEFINE cNomArchivo			CHAR(35);
DEFINE dFecha_Hoy       	DATE;
DEFINE cFechaPago       	CHAR(8);
DEFINE cRef1				CHAR(27);
DEFINE cStmt		    	CHAR(200);
DEFINE cIdentificador		CHAR(25);
DEFINE cIdSucursal			CHAR(4);
DEFINE cHoraFecha			CHAR(5);
DEFINE iTotRegistros    	INTEGER;
DEFINE cImporte_pago		CHAR(16);
DEFINE deImporte_archivo 	DECIMAL(16,2);
DEFINE deImporte_pago	 	DECIMAL(16,2);
DEFINE cNombreSuc			CHAR(25);
DEFINE dFechaIni            DATE;
DEFINE cDia                 CHAR(2);
DEFINE cMes                 CHAR(2);
DEFINE cAnio                CHAR(4);
DEFINE cMovimiento			CHAR(2);
DEFINE cTipoMovimiento		CHAR(2);
DEFINE iFlagCopp			INTEGER;

--INICIALIZAR VARIABLES
LET iSqlErr         	= 0;
-- LET cCodRet         	= '00002'; --Inicializado como error, cambia durante la ejecucion del sp en caso de Exito.
LET cCodRet         	= '00000';
LET cCategoria      	= '';
LET cConvenio       	= '';
LET cRutaArch			= '';
LET cNomArchivo			= '';
LET dFecha_Hoy			= DATE(1);
LET cFechaPago      	= '';
LET cRef1				= '';
LET cStmt				= '';
LET cIdentificador  	= '';
LET cIdSucursal			= '';
LET cHoraFecha			= '';
LET iTotRegistros		= 0;
LET cImporte_pago   	= '';
LET deImporte_archivo 	= 0;
LET deImporte_pago    	= 0;
LET cNombreSuc			= '';
LET dFechaIni           = DATE(1);
LET cDia                = '';
LET cMes                = '';
LET cAnio               = '';
LET cMovimiento			= '';
LET cTipoMovimiento		= '';
LET iFlagCopp			= 0;

	--SET DEBUG FILE TO '/tmp/sp_generaarchivocobranzamegacable.out';
	--TRACE ON;
		
	BEGIN
		-- Errores de Informix
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
					UPDATE bdisac:"informix".sac_controlarchivoscobranza
					SET retorno = cCodRet
					WHERE numcategoria = cCategoria
					AND   numconvenio = cConvenio;
					
			END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		--Validamos parametros de entrada
		IF NVL(pCatConv,'') = '' THEN
			LET cCodRet = '00001';
            UPDATE bdisac:"informix".sac_controlarchivoscobranza
            SET    fecha_ultimo_archivo = CURRENT::DATE, retorno = cCodRet
            WHERE  numcategoria = '06' AND numconvenio = '005';
				
		ELSE
			--Obtenemos categoria y convenio
			LET cCategoria  = SUBSTRING(pCatConv FROM 1 FOR 2); -- Separar  categoria 
			LET cConvenio   = SUBSTRING(pCatConv FROM 3 FOR 3); --    del convenio
		
			--Obtenemos nombre de archivo de cobranza desde la tabla "bdisac:sac_convenios"
			SELECT nombre_archivo_cobranza, ruta_archivo_cobranza 
			INTO   cNomArchivo, cRutaArch
			FROM   bdisac:"informix".sac_convenios 
			WHERE  numcategoria = cCategoria
			AND    numconvenio  = cConvenio;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00002';
                UPDATE bdisac:"informix".sac_controlarchivoscobranza
                SET    fecha_ultimo_archivo = CURRENT::DATE, retorno = cCodRet
                WHERE  numcategoria = cCategoria AND numconvenio = cConvenio;
				
				
			ELSE						
				--Obtenemos fecha de bdisac:sac_fechas
				SELECT fecha_hoy 
				INTO   dFecha_Hoy
				FROM   bdisac:"informix".sac_fechas;
				
				SELECT fecha_ultimo_archivo
				INTO dFechaIni
				FROM bdisac:"informix".sac_controlarchivoscobranza
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
								
				LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
				LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
				LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');
								
				--Reemplazamos el nombre del archivo consultado previamente en "bdisac:sac_convenios" y le agregamos los datos de la fecha actual.
				LET cNomArchivo = REPLACE(cNomArchivo,'AAAA',cAnio);
				LET cNomArchivo = REPLACE(cNomArchivo,'MM',cMes);
				LET cNomArchivo = REPLACE(cNomArchivo,'DD',cDia);
				
				--OBTENGO EL TIPO DE MOVIMIENTO
				SELECT movimiento, tipomovimiento
				INTO   cMovimiento, cTipoMovimiento
				FROM   sac_servicios_cpl
				WHERE  numcategoria = cCategoria
				AND    numconvenio  = cConvenio;

				--Reviso si existe archivo importado correctamente del dia
				IF (SELECT COUNT(*)
					FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  movimiento = cMovimiento
					AND    tipomovimiento = cTipoMovimiento
					AND    st_conciliado = '1') > 0 THEN
						LET iFlagCopp = 1;
				END IF;
				
				--Combinamos la ruta del archivo con el nombre de archivo actualizado.
				LET cRutaArch = TRIM(cRutaArch) || TRIM(cNomArchivo);
				--Imprimir solo filas de la consulta (sin encabezados)
				LET cIdentificador = RPAD('BANCOPPEL', 25, ' ');
				
				FOREACH				
					SELECT					
					LPAD(TRIM(id_sucursal), 4, '0'),
					SUBSTR(fecha_pago, 7, 4) || SUBSTR(fecha_pago, 1, 2) || SUBSTR(fecha_pago, 4, 2),
					SUBSTRING(fecha_insert::DATETIME HOUR TO SECOND FROM 1 FOR 5),
					LPAD(TRIM(referencia1), 27, '0'),
					LPAD(REPLACE(importe_pago, '$', ''), 16, '0'),
					NVL(importe_pago, 0)
					INTO     cIdSucursal, cFechaPago, cHoraFecha, cRef1, cImporte_pago, deImporte_pago
					FROM     bdisac:"informix".sac_movimientoshistorial
					WHERE    numcategoria     = cCategoria 
					AND	     numconvenio      = cConvenio
					AND fecha_pago > dFechaIni
					AND fecha_pago <= dFecha_Hoy
					AND      status_cancelado = 'N'
					AND origen != 'CPL'
					ORDER BY fecha_pago DESC
					
					SELECT sucursal || ' ' || NVL(REPLACE(nombre,',',''),'')
					INTO cNombreSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cIdSucursal;
					
					LET cStmt = 'echo "'
					|| RPAD(cIdentificador, 25, ' ') || "," || RPAD(cNombreSuc, 25, ' ') || "," ||cFechaPago || "," || cHoraFecha || "," || LPAD(cRef1, 50, '0') ||  ","|| LPAD(cImporte_pago, 16, '0') || '" >> ' || cRutaArch;
					
					SYSTEM cStmt;
					
					LET iTotRegistros = iTotRegistros +1;
					LET deImporte_archivo = deImporte_archivo + deImporte_pago;
					CONTINUE FOREACH;
					
				END FOREACH;
				
				--Imprimir solo filas de la consulta (sin encabezados)
				LET cIdentificador = RPAD('COPPEL', 25, ' ');
				
				--Si hay pagos confirmados de Coppel se agregan al archivo de cobranza
				--IF iFlagCopp = 1 THEN LET iFlagCopp = 1; --habilitar para enviar solo movimientos CPL conciliados: 24sep2020-NMR
					FOREACH				
						SELECT					
						LPAD(TRIM(id_sucursal), 4, '0'),
						SUBSTR(fecha_pago, 7, 4) || SUBSTR(fecha_pago, 1, 2) || SUBSTR(fecha_pago, 4, 2),
						SUBSTRING(fecha_insert::DATETIME HOUR TO SECOND FROM 1 FOR 5),
						LPAD(TRIM(referencia1), 27, '0'),
						LPAD(REPLACE(importe_pago, '$', ''), 16, '0'),
						NVL(importe_pago, 0)
						INTO     cIdSucursal, cFechaPago, cHoraFecha, cRef1, cImporte_pago, deImporte_pago
						FROM     bdisac:"informix".sac_movimientoshistorial
						WHERE    numcategoria     = cCategoria 
						AND	     numconvenio      = cConvenio
						AND fecha_pago > dFechaIni
						AND fecha_pago <= dFecha_Hoy
						AND      status_cancelado = 'N'
						AND origen = 'CPL'
						ORDER BY fecha_pago DESC
						
						SELECT sucursal || ' ' || NVL(REPLACE(nombre,',',''),'')
						INTO cNombreSuc
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cIdSucursal;
						
						LET cStmt = 'echo "'
						|| RPAD(cIdentificador, 25, ' ') || "," || RPAD(cNombreSuc, 25, ' ') || "," ||cFechaPago || "," || cHoraFecha || "," || LPAD(cRef1, 50, '0') ||  ","|| LPAD(cImporte_pago, 16, '0') || '" >> ' || cRutaArch;
						
						SYSTEM cStmt;
						
						LET iTotRegistros = iTotRegistros +1;
						LET deImporte_archivo = deImporte_archivo + deImporte_pago;
						CONTINUE FOREACH;
						
					END FOREACH;
				--END IF; --habilitar para enviar solo movimientos CPL conciliados: 24sep2020-NMR
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			--Consulta sin resultados, imprimir el archivo en blanco (sin encabezados, sin datos).
						LET cStmt = 'echo "" >> ' || cRutaArch;
						SYSTEM cStmt;

				END IF;					
				
				UPDATE bdisac:"informix".sac_controlarchivoscobranza
				SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				
			END IF;

		END IF;		
		
	END
END PROCEDURE
DOCUMENT
'Autor: 95992243 - Trinidad Hernandez',
'Folio: 132 - RQM 10 760-Pagos referenciados Megacable',
'Descripcion: Genera el reporte de liquidacion de pagos de MEGACABLE',
'Fecha: 17-10-2016',
'Version: 20161017.0901',
'BD: bdisac';

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