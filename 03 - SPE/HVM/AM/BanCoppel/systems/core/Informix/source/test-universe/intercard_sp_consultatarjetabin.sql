CREATE PROCEDURE "informix".sp_consultatarjetabin(pEmpresa CHAR(3), pLote INTEGER, pTarjetaini CHAR(16), pTarjetafin CHAR(16), pMigracionVisaActiva CHAR(1))
RETURNING CHAR(5) AS codigo_retorno,CHAR(1) AS tipo;

	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipo CHAR(1);
	DEFINE cBin CHAR(6);
	DEFINE iNumeroLote1 INTEGER;
	DEFINE iNumeroLote2 INTEGER;
	DEFINE iNumeroLote3 INTEGER;

    DEFINE ctipotarjeta INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipo = '';
	LET cBin = '';
	LET iNumeroLote1 = 0;
	LET iNumeroLote2 = 0;
	LET iNumeroLote3 = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr		
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));
			END IF;			
		END EXCEPTION; 	

		  --SET DEBUG FILE TO "/informix/NL/sp_consultatarjetabin.out";
		  --TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		IF pEmpresa = '' OR pLote = '' OR pTarjetaini = '' OR pTarjetafin = ''  THEN		
			LET cCodRet = '00001';
		ELSE		

        	-- RQM MIGRACIÃÂN TDC ORO Y PLATINUM MASTERCARD A VISA
			SELECT numerolote, clave_tipotarjeta INTO iNumeroLote1, ctipotarjeta
			FROM intercard:"informix".lote
			WHERE numerolote = pLote;

			IF ((ctipotarjeta = 10 OR ctipotarjeta = 9 OR ctipotarjeta = 22) AND pMigracionVisaActiva = '1') THEN -- RQM TC Mc a Visa 
				LET cCodRet = '00004';
			ELSE
					
				/*SELECT DISTINCT(numerolote) INTO iNumeroLote2
				FROM intercard:"informix".tarjeta 
				WHERE numtarjeta >= pTarjetaini AND numtarjeta <= pTarjetafin;*/
				
				SELECT numerolote INTO iNumeroLote2 
				FROM intercard:"informix".tarjeta 
				WHERE numtarjeta = pTarjetaini;
				
				SELECT numerolote INTO iNumeroLote3 
				FROM intercard:"informix".tarjeta 
				WHERE numtarjeta = pTarjetafin;
				
				IF (iNumeroLote1 = iNumeroLote2) AND (iNumeroLote1 = iNumeroLote3) THEN
				
					LET cBin = SUBSTR(pTarjetaini,1,6);
					
					SELECT creditodebito INTO cTipo FROM intercard:"informix".bines WHERE bin = cBin;
					
					IF TRIM(NVL(cTipo,'')) = '' THEN			
						LET cCodRet = '00003';
					END IF;			
					
				ELSE
					LET cCodRet = '00002';
				END IF;
			END IF		
		END IF;		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));		
	END;
END PROCEDURE
DOCUMENT
'Autor: 95142134 Mario Gallardo',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 29-11-2016',
'Modificacion: Se crea procedimiento para validar bines de tarjetas',
'Sustento: 144_1_1_1_11_12_1_1_5_.pdf',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

CREATE PROCEDURE "informix".sp_cancelacion_tarjetas_expiradas()

RETURNING CHAR(5) AS codigo_retorno, CHAR(100) AS mensaje_retorno;

	-- Variables manejo de errores
	DEFINE iIsamErr					INTEGER;
	DEFINE iErrorInfo				CHAR(40);
	DEFINE iSqlErr					INTEGER;
	DEFINE cCodigoRetorno			CHAR(5);
	DEFINE cMensajeRetorno			CHAR(100);
	
	-- Variables usadas en el proceso
	DEFINE cSql						CHAR(250);
	DEFINE vNumTarjeta				VARCHAR(16);
	DEFINE vCodEstatusTarjeta		VARCHAR(3);
	DEFINE vCodProductoTarjeta		VARCHAR(3);
	DEFINE vFechaExpiracion			CHAR(4);
	DEFINE vNumeroCliente			CHAR(13);
	DEFINE vNumeroLote				INTEGER;
	DEFINE vTipoTarjeta				CHAR(1);
	DEFINE vNumeroProductoCuenta	CHAR(4);
	DEFINE vDescripcionProdCuenta	CHAR(100);
	DEFINE vClaveSucursal			VARCHAR(5);
	DEFINE vClaveSucursalAux		VARCHAR(4);
	DEFINE vNombreSucursal			VARCHAR(50);
	DEFINE vClaveEstado				CHAR(2);
	DEFINE vNombreEstado			CHAR(30);
	DEFINE vNumeroRegistros			INTEGER;
	DEFINE vEstatusCancelacion		CHAR(1);
	DEFINE vBin						CHAR(6);
	DEFINE vSubBin					CHAR(2);
	DEFINE vContadorRegistros		INTEGER;
	DEFINE vFechaProceso			DATETIME YEAR TO FRACTION(5);
	DEFINE vFlagTransaccion			CHAR(1);

	-- Variables para la lectura de archivo tarjetas extraido ya filtrado
	DEFINE vRutaArchivo				VARCHAR(50);
	DEFINE vArchiBat				CHAR(50);
	DEFINE vListArchivo				CHAR(250);
	DEFINE vRutaRespaldo			CHAR(250);
	DEFINE vNombreArchivo			VARCHAR(100);

	-- Inicializacion de variables manejo de error
	LET iIsamErr				= 0;
	LET iErrorInfo				= '';
	LET iSqlErr					= 0;
	LET cCodigoRetorno			= '00000';
	LET cMensajeRetorno			= 'PROCESO EXITOSO';

	-- Inicializacion de variables usadas en el proceso
	LET cSql					= '';
	LET vNumTarjeta				= '';
	LET vCodEstatusTarjeta		= '';
	LET vCodProductoTarjeta		= '';
	LET vFechaExpiracion		= '';
	LET vNumeroCliente			= '';
	LET vNumeroLote				= 0;
	LET vTipoTarjeta			= '';
	LET vNumeroProductoCuenta	= '';
	LET vDescripcionProdCuenta	= '';
	LET vClaveSucursal			= '';
	LET vClaveSucursalAux		= '';
	LET vNombreSucursal			= '';
	LET vClaveEstado			= '';
	LET vNumeroRegistros		= 0;
	LET vEstatusCancelacion		= '';
	LET vBin					= '';
	LET vSubBin					= '';
	LET vContadorRegistros		= 0;
	LET vFechaProceso			= CURRENT;
	LET vFlagTransaccion		= 'F';
	
	-- Inicializacion de variables para la lectura de archivo de tarjetas expiradas
	LET vRutaArchivo			= '/RESPALDOSNEW/MaquilaPersonalizada/';
	LET vArchiBat				= 'ls_bat.bat';
	LET vListArchivo			= 'listado_archivos.txt';
	LET vRutaRespaldo			= '/RESPALDOSNEW/MaquilaPersonalizada/Procesado/';
	LET vNombreArchivo			= '';
	
	-- SET DEBUG FILE TO "/home/c90265232/trace_manual_err_" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
	-- TRACE ON;
	
	CREATE TABLE IF NOT EXISTS temp_tarjetas_expiradas 
	(
		numtarjeta			VARCHAR(16) NOT NULL, 
		fechaexp			VARCHAR(4)
	);
	
	CREATE INDEX IF NOT EXISTS idx_temp_tar_exp_numtarjeta 
	ON temp_tarjetas_expiradas(numtarjeta);
	
	CREATE TABLE IF NOT EXISTS temp_nombre_archivo_tarjetas_exp
	(
		nombre CHAR(250)
	);
	
	TRUNCATE TABLE temp_tarjetas_expiradas;
	TRUNCATE TABLE temp_nombre_archivo_tarjetas_exp;

	BEGIN
	
		-- Manejo de error
		ON EXCEPTION SET iSqlErr, iIsamErr, iErrorInfo
			
			-- SET DEBUG FILE TO "/home/c90265232/trace_manual_err_" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
			-- TRACE ON;
			
			-- En caso de error se certifica cerrar/terminar la transaccion iniciada a fin de no deja run proceso colgado
			IF vFlagTransaccion = 'V' THEN
				COMMIT;
				LET vFlagTransaccion = 'F';
			END IF;
			
			IF iSqlErr <> 0 THEN
				LET cCodigoRetorno = iSqlErr;
				LET cMensajeRetorno = 'ERROR EN EL PROCESO ' || iIsamErr || ' ' || iErrorInfo;
				RETURN cCodigoRetorno, cMensajeRetorno;
			END IF;
			
		END EXCEPTION;	
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Se lee el contenido de la ruta en donde se espera obtener los insumos
		LET cSql = '';
		LET cSql = 'echo "ls " '|| TRIM( vRutaArchivo ) || ' > ' || TRIM( vRutaArchivo ) || TRIM( vArchiBat );
		SYSTEM cSql;
		
		LET cSql ='';
		LET cSql = 'chmod 777 ' || TRIM(vRutaArchivo) || TRIM(vArchiBat);
		SYSTEM cSql;
		
		LET cSql = ''; 
		LET cSql = TRIM(vRutaArchivo) || TRIM(vArchiBat) || ' > ' || TRIM(vRutaArchivo) || TRIM(vListArchivo); 
		SYSTEM cSql; 
		
		LET cSql = '';
		LET cSql = 'chmod 777 ' || RTRIM(vRutaArchivo) || TRIM(vListArchivo);
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSql = 'echo "LOAD FROM '|| TRIM(vRutaArchivo) || TRIM(vListArchivo) || ' INSERT INTO intercard:temp_nombre_archivo_tarjetas_exp;" > ' || TRIM(vRutaArchivo) || 'load_nombre_archivo.sql';
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSql = 'chmod 777 ' || TRIM(vRutaArchivo) || 'load_nombre_archivo.sql';
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSql = 'dbaccess intercard ' || TRIM(vRutaArchivo) || 'load_nombre_archivo.sql';
		SYSTEM cSql;
		
		LET cSql ='';
		LET cSql = 'rm ' || TRIM(vRutaArchivo) || TRIM(vArchiBat);
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSql = 'rm ' || TRIM(vRutaArchivo) || TRIM(vListArchivo);
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSql = 'rm ' || TRIM(vRutaArchivo) || 'load_nombre_archivo.sql';
		SYSTEM cSql;
		
		-- Se valida que existan archivos a procesar de tarjetas expiradas
		IF EXISTS 
		(
			SELECT nombre
			FROM intercard:temp_nombre_archivo_tarjetas_exp
			WHERE nombre LIKE 'TarjetasExpiradas_%'
		)THEN 
		
			FOREACH WITH HOLD
			
				SELECT TRIM(nombre)
				INTO vNombreArchivo
				FROM intercard:temp_nombre_archivo_tarjetas_exp
				WHERE nombre LIKE 'TarjetasExpiradas_%'
				
				IF NOT EXISTS 
				(
					SELECT nombre_archivo
					FROM intercard:tarjetas_personalizadas_control
					WHERE nombre_archivo = vNombreArchivo
				) THEN

					INSERT INTO intercard:tarjetas_personalizadas_control ( nombre_archivo, fecha_proceso, total_registros, estatus )
					VALUES ( TRIM(vNombreArchivo), CURRENT, 0, 'Pendiente');
					
				END IF;
				
			END FOREACH;
			
		ELSE 
			LET cMensajeRetorno = 'Proceso Exitoso. No hay archivos por procesar';
			LET cCodigoRetorno = '00001';
	
			RETURN cCodigoRetorno, cMensajeRetorno;
		END IF;
		
		IF NOT EXISTS
		(
			SELECT a.nombre_archivo
			FROM intercard:tarjetas_personalizadas_control a
			JOIN intercard:temp_nombre_archivo_tarjetas_exp b
			ON a.nombre_archivo = b.nombre
			WHERE a.nombre_archivo LIKE 'TarjetasExpiradas_%'
			AND a.estatus = 'Pendiente'
		) THEN 
		
			LET cMensajeRetorno = 'Proceso Exitoso. No hay archivos pendientes por procesar';
			LET cCodigoRetorno = '00001';
	
			RETURN cCodigoRetorno, cMensajeRetorno;
			
		END IF;
		
		FOREACH WITH HOLD
		
			SELECT a.nombre_archivo
			INTO vNombreArchivo
			FROM intercard:tarjetas_personalizadas_control a
			JOIN intercard:temp_nombre_archivo_tarjetas_exp b
			ON a.nombre_archivo = b.nombre
			WHERE a.nombre_archivo LIKE 'TarjetasExpiradas_%'
			AND a.estatus = 'Pendiente'
			
			-- Lectura de archivo con la informaciÃ³n de tarjetas expiradas para insertar los datos en una tabla temporal para su procesamiento temp_tarjetas_expiradas
			LET cSql = '';
			LET cSql = "echo " || '"' || "FILE '" || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || "' delimiter '" || '|' || "' " || '2' || "; INSERT INTO " || 'temp_tarjetas_expiradas' || ";" || '"' || ' > ' || TRIM(vRutaArchivo) || 'paso1_tar_exp.txt';
			SYSTEM cSql;
			
			LET cSql = '';
			LET cSql = "dbload -d intercard -c " || TRIM(vRutaArchivo) || 'paso1_tar_exp.txt' || " -l " || TRIM(vRutaArchivo) || 'paso1_tar_exp.log' || " -n " || 1000 || " -r > " || TRIM(vRutaArchivo) || 'paso1_rep_tar_exp.log';
			SYSTEM cSql;
			
			LET cSql = '';
			LET cSql = 'rm ' || TRIM(vRutaArchivo) || 'paso1_tar_exp.txt';
			SYSTEM cSql;
			
			LET cSql = ''; 
			LET cSql ='rm ' || TRIM(vRutaArchivo) || 'paso1_tar_exp.log';
			SYSTEM cSql;
			
			LET cSql = '';
			LET cSql ='rm ' || TRIM(vRutaArchivo) || 'paso1_rep_tar_exp.log';
			SYSTEM cSql;
			
			LET cSql = '';
			LET cSql = 'mv ' || TRIM(vRutaArchivo) || "'" || TRIM(vNombreArchivo) || "'" || ' ' || vRutaRespaldo;
			SYSTEM cSql;
			
			LET vContadorRegistros = 0;
			
			BEGIN WORK;
			LET vFlagTransaccion = 'V';
			
			FOREACH WITH HOLD

				SELECT numtarjeta
				INTO vNumTarjeta
				FROM temp_tarjetas_expiradas
										
				SELECT codstatustarjeta, fechaexp, numcliente, numerolote, codproductotarjeta
				INTO vCodEstatusTarjeta, vFechaExpiracion, vNumeroCliente, vNumeroLote, vCodProductoTarjeta
				FROM intercard:tarjeta
				WHERE numtarjeta = vNumTarjeta;
	
				IF ( vCodEstatusTarjeta IS NOT NULL) AND ( vCodEstatusTarjeta IN ('ACT','BLO','BLT') ) THEN
						
					IF vNumeroCliente IS NOT NULL AND vNumeroLote IS NOT NULL AND vCodProductoTarjeta IS NOT NULL THEN
						
						SELECT creditodebito
						INTO vTipoTarjeta
						FROM intercard:bines
						WHERE bin = SUBSTR(vNumTarjeta, 1, 6);

						IF vTipoTarjeta = 'C' THEN

							SELECT b.num_producto, b.num_producto || ' ' || c.descrip_prod
							INTO vNumeroProductoCuenta, vDescripcionProdCuenta
							FROM bdicred:sd_tarjeta a
							JOIN bdicred:sd_maecred b
							ON a.num_credito = b.num_credito
							JOIN bdicred:sd_tipprod c
							ON b.num_producto = c.abrevia_prod
							WHERE a.num_tarjeta = vNumTarjeta;
							
						ELSE
						
							SELECT a.prodtarjeta, a.prodtarjeta || ' ' || b.nombre
							INTO vNumeroProductoCuenta, vDescripcionProdCuenta
							FROM bdicheq:sc_tarjeta a 
							JOIN bdicheq:sc_producto b 
							ON a.prodtarjeta = b.producto 	
							WHERE a.num_tarjeta = vNumTarjeta;
							
						END IF;

						SELECT clave_sucursal
						INTO vClaveSucursal
						FROM intercard:lote
						WHERE numerolote = vNumeroLote;
						
						LET vClaveSucursalAux = vClaveSucursal[2,5];
						
						SELECT nombre_sucursal
						INTO vNombreSucursal
						FROM intercard:sucursal
						WHERE clave_sucursal = vClaveSucursal;
						
						SELECT b.estado, b.nombre
						INTO vClaveEstado, vNombreEstado
						FROM bdinteg:si_sucursales a
						JOIN bdinteg:si_estados b
						ON a.estado = b.estado
						WHERE a.sucursal = vClaveSucursalAux;
								
						SELECT COUNT(*)
						INTO vNumeroRegistros
						FROM intercard:tarjetacuenta
						WHERE numtarjeta = vNumTarjeta;
							
						IF vNumeroRegistros > 1 THEN 
							LET vEstatusCancelacion = 'E';	
						ELSE
							LET vEstatusCancelacion = 'P';
						END IF;
						
						LET vBin = SUBSTR(vNumTarjeta,1,6);
						LET vSubBin = SUBSTR(vNumTarjeta,7,2);

						IF NOT EXISTS 
						(
							SELECT numtarjeta 
							FROM bitacora_can_fecha_exp
							WHERE numtarjeta = vNumTarjeta 
						) THEN
						
							INSERT INTO bitacora_can_fecha_exp 
							(
								numtarjeta, bin, subbin, fechaexp, numcliente, codproductotarjeta, estatus_ant, producto, tipoproc, estatus_can, 
								numerolote, fecha_proc, clave_sucursal, nombre_sucursal, clave_estado, nombre_estado, codprodcta, descodprodcta
							)
							VALUES 
							(
								vNumTarjeta, vBin, vSubBin, vFechaExpiracion, vNumeroCliente, vCodProductoTarjeta, vCodEstatusTarjeta, vTipoTarjeta, 'MENSUAL', vEstatusCancelacion, 
								vNumeroLote, CURRENT, vClaveSucursal, vNombreSucursal, vClaveEstado, vNombreEstado, vNumeroProductoCuenta, vDescripcionProdCuenta
							);
							
						END IF;
						
						LET vContadorRegistros = vContadorRegistros + 1;
	
						IF vContadorRegistros >= 1000 THEN 
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET vContadorRegistros = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
						LET vBin = '';
						LET vSubBin = '';
								
					ELSE
						LET cMensajeRetorno = 'Existen datos nulos';
						LET cCodigoRetorno = '00003';	
					END IF; 
				
				ELSE						
					LET cMensajeRetorno = 'No existen registros';
					LET cCodigoRetorno = '00004';
				END IF;
				
			END FOREACH;
		
			COMMIT;
			LET vFlagTransaccion = 'F';
			
			LET vContadorRegistros = 0;
			
			BEGIN WORK;
			LET vFlagTransaccion = 'V';
			
			FOREACH WITH HOLD
			
				SELECT numtarjeta, codproductotarjeta, producto, fecha_proc, estatus_can
				INTO vNumTarjeta, vCodProductoTarjeta, vTipoTarjeta, vFechaProceso, vEstatusCancelacion
				FROM intercard:bitacora_can_fecha_exp
				WHERE fechaexp = vFechaExpiracion
				AND estatus_can = 'P'

				IF vTipoTarjeta = 'D' THEN

					UPDATE bdicheq:sc_tarjeta
					SET status_tar = 'C' 
					WHERE num_tarjeta = vNumTarjeta;

				ELIF vTipoTarjeta = 'C' THEN

					UPDATE bdicred:sd_tarjeta
					SET status_tar = 'C' 
					WHERE num_tarjeta = vNumTarjeta;
					
				END IF;

				UPDATE intercard:tarjeta
				SET codstatustarjeta = 'CAN', usuarioultmodif = 'informix', fechaultmodif = CURRENT 
				WHERE numtarjeta = vNumTarjeta;
	
				INSERT INTO intercard:bitacoracancelaciontarjetas(tarjeta, codigoproductotarjeta,fecha, resultado, descripcion, usuario)
				VALUES(vNumTarjeta, vCodProductoTarjeta, CURRENT, '4', 'Cancelacion Mensual de tarjetas por vencimiento', 'informix');
	
				UPDATE intercard:bitacora_can_fecha_exp 
				SET estatus_can = 'T', fecha_proc = CURRENT
				WHERE numtarjeta = vNumTarjeta 
				AND fechaexp = vFechaExpiracion
				AND fecha_proc = vFechaProceso;
				
				LET vContadorRegistros = vContadorRegistros + 1;
				
				IF (vContadorRegistros >= 1000) THEN
					COMMIT;
					LET vFlagTransaccion = 'F';
					LET vContadorRegistros = 0;
					BEGIN WORK;
					LET vFlagTransaccion = 'V';
				END IF;
				
			END FOREACH;
	
			COMMIT;
			LET vFlagTransaccion = 'F';
			
			UPDATE STATISTICS MEDIUM FOR TABLE intercard:bitacora_can_fecha_exp;
			
			SELECT COUNT(*)
			INTO vNumeroRegistros
			FROM temp_tarjetas_expiradas;
			
			UPDATE intercard:tarjetas_personalizadas_control 
			SET estatus = 'Procesado', total_registros = vNumeroRegistros
			WHERE nombre_archivo = TRIM(vNombreArchivo);
			
			TRUNCATE TABLE temp_tarjetas_expiradas;

		END FOREACH;
		
		DROP TABLE temp_tarjetas_expiradas;
		DROP TABLE temp_nombre_archivo_tarjetas_exp;
		
		LET cCodigoRetorno = '00000';
		LET cMensajeRetorno = 'Proceso Exitoso';
		
		RETURN cCodigoRetorno, cMensajeRetorno;
								
	END
	
END PROCEDURE;