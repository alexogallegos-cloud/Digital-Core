CREATE PROCEDURE "informix".sp_sol_maq_per_dup()
	RETURNING VARCHAR(10) AS CODIGO_RETORNO, VARCHAR(255) AS MENSAJE_RETORNO;
	
	DEFINE vCodRet			VARCHAR(10);
	DEFINE vMenRet			VARCHAR(255);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(40);

    DEFINE vFechaInicio 			DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaFin 				DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaDuplicada			DATETIME YEAR TO FRACTION(5);
	DEFINE vSolicitudDuplicada		CHAR(1);
	DEFINE vSolicitudSucursal		CHAR(1);
	DEFINE vSolicitudDuplicadaP		CHAR(1);
	DEFINE vDuplicado				CHAR(1);
	DEFINE vContadorSolicitudes 	INTEGER;
	
	DEFINE vFlagEjecucion			CHAR(1);
	
	DEFINE vDia						CHAR(2);
	DEFINE vMes						CHAR(2);
	DEFINE vAnio					CHAR(4);
	DEFINE vHoraActual				DATETIME HOUR TO SECOND;
	DEFINE vHora					CHAR(8);
	DEFINE vNombreArchivo			CHAR(250);
	
	DEFINE vSQL						CHAR(500);

	DEFINE vSucursal				VARCHAR(5);
	DEFINE vFechaGeneracion			DATETIME YEAR TO FRACTION(5);
	DEFINE vTipoMaquila				VARCHAR(1);
	DEFINE vClaveTipoTarjeta		INTEGER;
	DEFINE vCodProductoTarjeta		VARCHAR(3);
	DEFINE vUsuario					VARCHAR(8);
	DEFINE vNumCliente				VARCHAR(13);
	DEFINE vNumCuenta				VARCHAR(13);
	DEFINE vNombreTarjeta			VARCHAR(21);
	DEFINE vCodProdCuenta			VARCHAR(4);
	DEFINE vTitular					CHAR(1);
	DEFINE vFechaSolicitud			DATE;
	DEFINE vConsecutivo				INTEGER;
	DEFINE vSucursalAux				VARCHAR(5);
	DEFINE vFechaGeneracionAux		DATETIME YEAR TO FRACTION(5);
	DEFINE vTipoMaquilaAux			VARCHAR(1);
	DEFINE vClaveTipoTarjetaAux		INTEGER;
	DEFINE vCodProductoTarjetaAux	VARCHAR(3);
	DEFINE vUsuarioAux				VARCHAR(8);
	DEFINE vFechaSolicitudAux		DATE;
	DEFINE vConsecutivoAux			INTEGER;
	
	LET vCodRet 		= '00000';       
	LET vMenRet			= '';
    LET sql_err 		= 0;          
    LET isam_err 		= 0;        
    LET error_info 		= '';
	
    LET vFechaInicio 			= CURRENT - 1 UNITS DAY;
    LET vFechaFin 				= CURRENT - 1 UNITS DAY;
	LET vFechaDuplicada			= CURRENT;
	LET vSolicitudDuplicada		= 'F';
	LET vSolicitudSucursal		= 'F';
	LET vSolicitudDuplicadaP	= 'F';
	LET vDuplicado				= 'V';
	LET vContadorSolicitudes 	= 1;
	LET vFlagEjecucion			= 'F';
	
	LET vDia			= '';
	LET vMes			= '';
	LET vAnio			= '';
	LET vHoraActual		= CURRENT;
	LET vHora			= '';
	LET vNombreArchivo	= '';
	
	LET vSQL			= '';
	
	LET vSucursal				= '';
	LET vFechaGeneracion		= CURRENT;
	LET vTipoMaquila			= '';
	LET vClaveTipoTarjeta		= 0;
	LET vCodProductoTarjeta		= '';
	LET vUsuario				= '';
	LET vNumCliente				= '';
	LET vNumCuenta				= '';
	LET vNombreTarjeta			= '';
	LET vCodProdCuenta			= '';
	LET vTitular				= '';
	LET vFechaSolicitud			= TODAY;
	LET vConsecutivo			= 0;
	LET vSucursalAux			= '';
	LET vFechaGeneracionAux		= CURRENT;
	LET vTipoMaquilaAux			= '';
	LET vClaveTipoTarjetaAux	= 0;
	LET vCodProductoTarjetaAux	= '';
	LET vUsuarioAux				= '';
	LET vFechaSolicitudAux		= TODAY;
	LET vConsecutivoAux			= 0;

	BEGIN

		-- MANEJO DEL ERROR
		ON EXCEPTION SET sql_err, isam_err, error_info
		
			--SET DEBUG FILE TO "/RESPALDOSNEW/sp_sol_maq_per_dup_err.out";
			--TRACE ON;	
			
			IF vFlagEjecucion = 'V' THEN 
				COMMIT;
			END IF;
			
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				
				RETURN vCodRet, isam_err|| ' ' ||error_info;
			END IF;
			
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/home/c90265232/prueba_2/sp_sol_maq_per_dup_err.out";
		--TRACE ON;
		
		CREATE TABLE IF NOT EXISTS intercard:temp_datos_maquila_duplicada
		(
			consecutivo			INTEGER, 
			clave_sucursal		VARCHAR(5), 
			fecha_generacion	DATETIME HOUR TO SECOND, 
			tipomaquila			VARCHAR(1), 
			clave_tipotarjeta	INTEGER, 
			codproductotarjeta	VARCHAR(3), 
			usuario				VARCHAR(8),
			tabla				CHAR(2)
		);
		
		TRUNCATE TABLE intercard:temp_datos_maquila_duplicada;
		
		LET vFechaInicio = YEAR(vFechaInicio) || '-' || MONTH(vFechaInicio) || '-' || DAY(vFechaInicio) || ' 00:00:00';
		LET vFechaFin = YEAR(vFechaFin) || '-' || MONTH(vFechaFin) || '-' || DAY(vFechaFin) || ' 23:59:59';
		
		SELECT FIRST 1 fecha_generacion
		FROM intercard:solicitud_maquila
		INTO temp temp_solicitudes_duplicadas WITH NO LOG;
		
		DELETE FROM temp_solicitudes_duplicadas;
		
		WHILE (vDuplicado = 'V')
			
			-- NOTA: De esta consulta se espera obtener de 2 a 6 registros como maximo
			INSERT INTO temp_solicitudes_duplicadas
			SELECT fecha_generacion
			FROM intercard:solicitud_maquila
			WHERE fecha_generacion BETWEEN vfechaInicio AND vfechaFin
			AND indicadortipoproceso = 'P'
			AND tipomaquila = 'E'
			GROUP BY 1
			HAVING COUNT(*) > 1;
			
			IF ( (SELECT COUNT(*) FROM temp_solicitudes_duplicadas) > 0 ) THEN 
				
				FOREACH WITH HOLD
					
					SELECT *
						INTO vFechaDuplicada
					FROM temp_solicitudes_duplicadas
					
					LET vFlagEjecucion = 'V';
					BEGIN WORK;
						FOREACH WITH HOLD
						
							SELECT consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario
								INTO vConsecutivo, vSucursal, vFechaGeneracion, vTipoMaquila, vClaveTipoTarjeta, vCodProductoTarjeta, vUsuario
							FROM intercard:solicitud_maquila
							WHERE fecha_generacion = vFechaDuplicada
							ORDER BY consecutivo ASC
							
							INSERT INTO temp_datos_maquila_duplicada(consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario, tabla)
							VALUES (vConsecutivo, vSucursal, vFechaGeneracion, vTipoMaquila, vClaveTipoTarjeta, vCodProductoTarjeta, vUsuario, 'SM');
							
							UPDATE intercard:solicitud_maquila
							SET fecha_generacion = fecha_generacion + vContadorSolicitudes UNITS MINUTE + vContadorSolicitudes UNITS SECOND
							WHERE consecutivo = vConsecutivo
							AND fecha_generacion = vFechaDuplicada;

							LET vContadorSolicitudes = vContadorSolicitudes + 1;
							
							IF vContadorSolicitudes = 1000 THEN
								COMMIT;
								LET vFlagEjecucion = 'F';
								
								LET vContadorSolicitudes = 1;
								
								LET vFlagEjecucion = 'V';
								BEGIN WORK;
							END IF;
							
						END FOREACH;
					COMMIT;
					LET vFlagEjecucion = 'F';
					
					LET vContadorSolicitudes = 1;
					
					LET vFlagEjecucion = 'V';
					BEGIN WORK;
						FOREACH WITH HOLD
						
							SELECT idsolicitud, sucursal, fechasolicitud, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario
								INTO vConsecutivo, vSucursal, vFechaGeneracion, vTipoMaquila, vClaveTipoTarjeta, vCodProductoTarjeta, vUsuario
							FROM intercard:solicitudtarjeta
							WHERE fechasolicitud = vFechaDuplicada
							ORDER BY idsolicitud ASC
							
							INSERT INTO temp_datos_maquila_duplicada(consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario, tabla)
							VALUES (vConsecutivo, vSucursal, vFechaGeneracion, vTipoMaquila, vClaveTipoTarjeta, vCodProductoTarjeta, vUsuario, 'ST');
							
							UPDATE intercard:solicitudtarjeta 
							SET fechasolicitud = fechasolicitud + vContadorSolicitudes UNITS MINUTE + vContadorSolicitudes UNITS SECOND
							WHERE idsolicitud = vConsecutivo
							AND fechasolicitud = vFechaDuplicada;

							LET vContadorSolicitudes = vContadorSolicitudes + 1;
							
							IF vContadorSolicitudes = 1000 THEN
								COMMIT;
								LET vFlagEjecucion = 'F';
								
								LET vContadorSolicitudes = 1;
								
								LET vFlagEjecucion = 'V';
								BEGIN WORK;
							END IF;
							
						END FOREACH;
					COMMIT;
					LET vFlagEjecucion = 'F';
					
					LET vContadorSolicitudes = 1;
					
				END FOREACH;
				
				IF ( (SELECT COUNT(*) FROM intercard:temp_datos_maquila_duplicada) > 0 ) THEN 
					LET vDia = LPAD(DAY(CURRENT),2,'0');
					LET vMes = LPAD(MONTH(CURRENT),2,'0');
					LET vAnio = YEAR(CURRENT);
					LET vHoraActual = CURRENT;
					LET vHora = vHoraActual::CHAR(8);
				
					LET vNombreArchivo = 'MAQUILA_DUPLICADA_FECHA_' || vAnio || vMes || vDia || SUBSTR(vHora,1,2) || SUBSTR(vHora,4,2) || SUBSTR(vHora,7,2) || '.unl';
					
					LET vSQL = 'echo "UNLOAD TO /RESPALDOSNEW/MaquilaPersonalizada/Procesado/' || TRIM (vNombreArchivo) || ' DELIMITER '',''" > /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup.sql';
					SYSTEM vSQL;
					
					LET vSQL = 'chmod 777 /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup.sql';
					SYSTEM vSQL;
					
					LET vSQL = 'echo "SELECT consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario, tabla" >> /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup.sql';
					SYSTEM vSQL;
				
					LET vSQL = 'echo "FROM intercard:temp_datos_maquila_duplicada;" >> /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup.sql';
					SYSTEM vSQL;
				
					LET vSQL = "dbaccess intercard /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup.sql";
					SYSTEM vSQL;
				
					LET vSQL = "rm /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup.sql";
					SYSTEM vSQL;
					
					LET vSQL = "chmod 777 /RESPALDOSNEW/MaquilaPersonalizada/Procesado/" || TRIM(vNombreArchivo);
					SYSTEM vSQL;
				END IF;
				
				DELETE FROM temp_datos_maquila_duplicada;
				DELETE FROM temp_solicitudes_duplicadas;
				
				LET vSolicitudDuplicada = 'V';
			
			ELSE 
				LET vDuplicado = 'F';
			END IF;
		
		END WHILE;
		
		-- Verificacion de que las solicitudes tengan sucursal existente
		LET vFlagEjecucion = 'V';
		BEGIN WORK;
			FOREACH WITH HOLD
					
				SELECT a.consecutivo, a.clave_sucursal, a.fecha_generacion, a.tipomaquila, a.clave_tipotarjeta, a.codproductotarjeta, a.usuario
				INTO vConsecutivo, vSucursal, vFechaGeneracion, vTipoMaquila, vClaveTipoTarjeta, vCodProductoTarjeta, vUsuario
				FROM intercard:solicitud_maquila a
				LEFT JOIN intercard:sucursal b
				ON a.clave_sucursal = b.clave_sucursal 
				WHERE a.fecha_generacion BETWEEN vfechaInicio AND vfechaFin
				AND (b.clave_sucursal IS NULL OR b.enoperacion = 'F')
				AND a.flagprocesorealizado = 'F'
			
				IF vConsecutivo IS NOT NULL THEN 
					INSERT INTO temp_datos_maquila_duplicada(consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario, tabla)
					VALUES (vConsecutivo, vSucursal, vFechaGeneracion, vTipoMaquila, vClaveTipoTarjeta, vCodProductoTarjeta, vUsuario, 'SM');
					
					UPDATE intercard:solicitud_maquila 
					SET flagprocesorealizado = 'V'
					WHERE consecutivo = vConsecutivo;
					
					IF vTipoMaquila = 'E' THEN 
						SELECT idsolicitud, sucursal, fechasolicitud, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario
							INTO vConsecutivoAux, vSucursalAux, vFechaGeneracionAux, vTipoMaquilaAux, vClaveTipoTarjetaAux, vCodProductoTarjetaAux, vUsuarioAux
						FROM intercard:solicitudtarjeta
						WHERE sucursal = vSucursal
						AND fechasolicitud = vFechaGeneracion
						AND tipomaquila = vTipoMaquila
						AND clave_tipotarjeta = vClaveTipoTarjeta
						AND codproductotarjeta = vCodProductoTarjeta
						AND usuario = vUsuario;
						
						INSERT INTO temp_datos_maquila_duplicada(consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario, tabla)
						VALUES (vConsecutivoAux, vSucursalAux, vFechaGeneracionAux, vTipoMaquilaAux, vClaveTipoTarjetaAux, vCodProductoTarjetaAux, vUsuarioAux, 'ST');
					
						UPDATE intercard:solicitudtarjeta 
						SET estatusproceso = 'V'
						WHERE idsolicitud = vConsecutivoAux;
					
					END IF;

					LET vContadorSolicitudes = vContadorSolicitudes + 1;
					
					IF vContadorSolicitudes = 1000 THEN
						COMMIT;
						LET vFlagEjecucion = 'F';
						
						LET vContadorSolicitudes = 1;
						
						LET vFlagEjecucion = 'V';
						BEGIN WORK;
					END IF;
					
					LET vSolicitudSucursal = 'V';
					
				ELSE 
					LET vSolicitudSucursal = 'F';
					
				END IF;
				
			END FOREACH;
		COMMIT;
		LET vFlagEjecucion = 'F';
		
		IF ( (SELECT COUNT(*) FROM intercard:temp_datos_maquila_duplicada) > 0 ) THEN 
			LET vDia = LPAD(DAY(CURRENT),2,'0');
			LET vMes = LPAD(MONTH(CURRENT),2,'0');
			LET vAnio = YEAR(CURRENT);
			LET vHoraActual = CURRENT;
			LET vHora = vHoraActual::CHAR(8);
		
			LET vNombreArchivo = 'MAQUILA_SIN_SUCURSAL_' || vAnio || vMes || vDia || SUBSTR(vHora,1,2) || SUBSTR(vHora,4,2) || SUBSTR(vHora,7,2)||'.unl';
			
			LET vSQL = 'echo "UNLOAD TO /RESPALDOSNEW/MaquilaPersonalizada/Procesado/' || TRIM (vNombreArchivo) || ' DELIMITER '',''" > /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_suc.sql';
			SYSTEM vSQL;
			
			LET vSQL = 'chmod 777 /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_suc.sql';
			SYSTEM vSQL;
			
			LET vSQL = 'echo "SELECT consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario, tabla" >> /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_suc.sql';
			SYSTEM vSQL;
		
			LET vSQL = 'echo "FROM intercard:temp_datos_maquila_duplicada;" >> /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_suc.sql';
			SYSTEM vSQL;
		
			LET vSQL = "dbaccess intercard /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_suc.sql";
			SYSTEM vSQL;
		
			LET vSQL = "rm /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_suc.sql";
			SYSTEM vSQL;
			
			LET vSQL = "chmod 777 /RESPALDOSNEW/MaquilaPersonalizada/Procesado/" || TRIM(vNombreArchivo);
			SYSTEM vSQL;
		END IF;
		
		DELETE FROM temp_datos_maquila_duplicada;
		
		-- Verificacion de que existan solicitudes duplicadas de un cliente
		LET vFlagEjecucion = 'V';
		BEGIN WORK;
			FOREACH WITH HOLD
				
				SELECT numcliente, numcuenta, nombretarjeta, clave_tipotarjeta, codprodcta, codproductotarjeta, titular, date( fechasolicitud ) as fecha_solicitud, sucursal, usuario, tipomaquila
				INTO vNumCliente, vNumCuenta, vNombreTarjeta, vClaveTipoTarjeta, vCodProdCuenta, vCodProductoTarjeta, vTitular, vFechaSolicitud, vSucursal, vUsuario, vTipoMaquila
				FROM intercard:solicitudtarjeta
				WHERE fechasolicitud >= vfechaInicio
				AND estatusproceso = 'F'
				GROUP BY 1, 2, 3, 4, 5, 6, 7 ,8, 9, 10, 11
				HAVING COUNT(*) > 1

				IF vNumCliente IS NOT NULL THEN 
				
					FOREACH WITH HOLD
						SELECT consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario
							INTO vConsecutivoAux, vSucursalAux, vFechaGeneracionAux, vTipoMaquilaAux, vClaveTipoTarjetaAux, vCodProductoTarjetaAux, vUsuarioAux
						FROM intercard:solicitud_maquila
						WHERE DATE(fecha_generacion) = vFechaSolicitud
						AND nom_cliente = vNombreTarjeta
						AND clave_sucursal = vSucursal
						AND clave_tipotarjeta = vClaveTipoTarjeta
						AND codproductotarjeta = vCodProductoTarjeta
						AND usuario = vUsuario
							
						INSERT INTO temp_datos_maquila_duplicada(consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario, tabla)
						VALUES (vConsecutivoAux, vSucursalAux, vFechaGeneracionAux, vTipoMaquilaAux, vClaveTipoTarjetaAux, vCodProductoTarjetaAux, vUsuarioAux, 'SM');
						
						UPDATE intercard:solicitud_maquila
						SET flagprocesorealizado = 'V'
						WHERE consecutivo = vConsecutivoAux;
						
					END FOREACH;
					
					FOREACH WITH HOLD
						SELECT idsolicitud, sucursal, fechasolicitud, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario
							INTO vConsecutivoAux, vSucursalAux, vFechaGeneracionAux, vTipoMaquilaAux, vClaveTipoTarjetaAux, vCodProductoTarjetaAux, vUsuarioAux
						FROM intercard:solicitudtarjeta
						WHERE DATE(fechasolicitud) = vFechaSolicitud
						AND nombretarjeta = vNombreTarjeta
						AND sucursal = vSucursal
						AND clave_tipotarjeta = vClaveTipoTarjeta
						AND codproductotarjeta = vCodProductoTarjeta
						AND usuario = vUsuario
							
						INSERT INTO temp_datos_maquila_duplicada(consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario, tabla)
						VALUES (vConsecutivoAux, vSucursalAux, vFechaGeneracionAux, vTipoMaquilaAux, vClaveTipoTarjetaAux, vCodProductoTarjetaAux, vUsuarioAux, 'ST');
						
						UPDATE intercard:solicitudtarjeta
						SET estatusproceso = 'V'
						WHERE idsolicitud = vConsecutivoAux;
						
					END FOREACH;
					
					LET vContadorSolicitudes = vContadorSolicitudes + 1;
					
					IF vContadorSolicitudes = 1000 THEN
						COMMIT;
						LET vFlagEjecucion = 'F';
						
						LET vContadorSolicitudes = 1;
						
						LET vFlagEjecucion = 'V';
						BEGIN WORK;
					END IF;
					
					LET vSolicitudDuplicadaP = 'V';
					
				ELSE 
					LET vSolicitudDuplicadaP = 'F';
					
				END IF;
				
			END FOREACH;
		COMMIT;
		LET vFlagEjecucion = 'F';
		
		IF ( (SELECT COUNT(*) FROM intercard:temp_datos_maquila_duplicada) > 0 ) THEN 
			LET vDia = LPAD(DAY(CURRENT),2,'0');
			LET vMes = LPAD(MONTH(CURRENT),2,'0');
			LET vAnio = YEAR(CURRENT);
			LET vHoraActual = CURRENT;
			LET vHora = vHoraActual::CHAR(8);
		
			LET vNombreArchivo = 'MAQUILA_DUPLICADA_CLIENTE_' || vAnio || vMes || vDia || SUBSTR(vHora,1,2) || SUBSTR(vHora,4,2) || SUBSTR(vHora,7,2)||'.unl';
			
			LET vSQL = 'echo "UNLOAD TO /RESPALDOSNEW/MaquilaPersonalizada/Procesado/' || TRIM (vNombreArchivo) || ' DELIMITER '',''" > /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup_c.sql';
			SYSTEM vSQL;
			
			LET vSQL = 'chmod 777 /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup_c.sql';
			SYSTEM vSQL;
			
			LET vSQL = 'echo "SELECT consecutivo, clave_sucursal, fecha_generacion, tipomaquila, clave_tipotarjeta, codproductotarjeta, usuario, tabla" >> /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup_c.sql';
			SYSTEM vSQL;
		
			LET vSQL = 'echo "FROM intercard:temp_datos_maquila_duplicada;" >> /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup_c.sql';
			SYSTEM vSQL;
		
			LET vSQL = "dbaccess intercard /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup_c.sql";
			SYSTEM vSQL;
		
			LET vSQL = "rm /RESPALDOSNEW/MaquilaPersonalizada/Procesado/aux_maq_dup_c.sql";
		SYSTEM vSQL;
			
			LET vSQL = "chmod 777 /RESPALDOSNEW/MaquilaPersonalizada/Procesado/" || TRIM(vNombreArchivo);
			SYSTEM vSQL;
		END IF;
		
		DROP TABLE temp_datos_maquila_duplicada;
		DROP TABLE temp_solicitudes_duplicadas;
		
		IF ( vSolicitudDuplicada = 'F' AND vSolicitudSucursal = 'F' AND vSolicitudDuplicadaP = 'F' ) THEN
		
			LET vCodRet = '00000';
			LET vMenRet = 'DESCARGA EXITOSA';
		ELSE 
			LET vCodRet = '00001';
			LET vMenRet = 'DESCARGA EXITOSA';
			
			IF ( vSolicitudDuplicada = 'V' ) THEN 
		
				LET vMenRet = vMenRet || ' - SE AJUSTARON LOTES DUPLICADOS';
				
			END IF;
			
			IF ( vSolicitudSucursal = 'V' ) THEN 
		
				LET vMenRet = vMenRet || ' - SOLICITUD(ES) SIN SUCURSAL';
				
			END IF;
			
			IF ( vSolicitudDuplicadaP = 'V' ) THEN 
		
				LET vMenRet = vMenRet || ' - SOLICITUD(ES) PERSONALIDAS DUPLICADAS';
				
			END IF;
			
		END IF;
		
		RETURN vCodRet, vMenRet;

	END;

END PROCEDURE
DOCUMENT
'Fecha creacion: 04/06/2024',
'Autor: Maria Fernanda Ortiz Figueroa',
'Descripcion: Proceso que se encarga de ajustar las solicitudes de maquila personalizadas con fecha de solicitud igual, con el fin de solventar el problema de lotes duplicados.',
'Fecha modificacion: 23/12/2024',
'Autor: Maria Fernanda Ortiz Figueroa',
'Descripcion: Se validan solicitudes duplicadas por usuario, asi como agregar validacion de que la sucursal existe';

CREATE PROCEDURE "informix".sp_homologacion_tarjeta_general
(
	inNumeroCaso		INTEGER,
	-- 1: CASO 1	ACT/BLO/BLT			NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	-- 2: CASO 2	ACT/BLO/BLT			NOA/NOE 	SIN informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred
	-- 3: CASO 3	ACT/BLO/BLT			NOA/NOE 	CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	-- 6: CASO 6	ACT/BLO/BLT			SIA    		CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	-- 9: CASO 9	DAN					NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	--10: CASO 10	DAN					NOA/NOE		SIN informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred con registro de numero de cliente en intercard:tarjeta
	--13: CASO 13	CAN/ROB/EXT/FAL		NOA/NOE		SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	--16: CASO 16	CAN/ROB/EXT/FAL		NOA/NOE		CON informacion en intercard:tarjetacuenta y SIN informacion en bdicred:sd_tarjeta/sd_maecred
	--17: CASO 17	CAN/ROB/EXT/FAL		SIA			SIN informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	--20: CASO 20	CAN/ROB/EXT/FAL		SIA			CON informacion en intercard:tarjetacuenta y CON informacion en bdicred:sd_tarjeta/sd_maecred
	inNombreArchivo		VARCHAR(250),
	inTipoEjecucion		CHAR(1)
	-- N: normal 
	-- R: reverso
)
RETURNING CHAR(5) AS outCodigo, VARCHAR(250) AS outMensaje;
	
	-- Variables para manejar error
	DEFINE err_sql				INTEGER;
	DEFINE err_isam				INTEGER;
	DEFINE err_info				CHAR(40);
	
	-- Variable de retorno
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje				VARCHAR(250);

	-- Variable para lectura de archivos
	DEFINE vDia         				CHAR(2);
    DEFINE vMes         				CHAR(2);
    DEFINE vAnio         				CHAR(4);
    DEFINE vHoraAux						DATETIME HOUR TO SECOND;
    DEFINE vHora						CHAR(8);
	DEFINE vRutaArchivo            		CHAR(250);
	DEFINE vRutaArchivoProcesado        CHAR(250);
	DEFINE vRutaArchivoResultado        CHAR(250);
	DEFINE vNombreArchivo   			CHAR(250);
	DEFINE vExecuteSQL      			CHAR(250);
	DEFINE vNombreTXT   				CHAR(250);
	DEFINE vNombreLog   				CHAR(250);
	DEFINE vNombreEjecucionLog  		CHAR(250);
	DEFINE vNombreArchivoResultado		CHAR(250);
	
	-- Inicializacion de variable
	LET err_sql		= 0;
	LET err_isam	= 0;
	LET err_info	= '';

	LET vCodigoRetorno	= '00000';
	LET vMensaje 		= 'PROCESO EXITOSO';
	
	LET vDia						= LPAD(DAY(CURRENT),2,'0');  
	LET vMes						= LPAD(MONTH(CURRENT),2,'0');
	LET vAnio						= YEAR(CURRENT);
	LET vHoraAux					= CURRENT;
	LET vHora						= vHoraAux::CHAR(8);
	LET vRutaArchivo				= '/RESPALDOSNEW/MaquilaPersonalizada/';
	LET vRutaArchivoProcesado		= '/RESPALDOSNEW/MaquilaPersonalizada/Procesado/';
	LET vRutaArchivoResultado		= '/RESPALDOSNEW/MaquilaPersonalizada/Procesado/';
	LET vNombreArchivo				= TRIM(inNombreArchivo);
	LET vExecuteSQL					= '';
	LET vNombreTXT					= 'PasoHomologacion.txt';
	LET vNombreLog					= 'PasoHomologacion.log';
	LET vNombreEjecucionLog			= 'PasoHomologacionRep.log';
	LET vNombreArchivoResultado		= '/RESULTADO_CASO_' || inNumeroCaso || '_' || vAnio || vMes || vDia || SUBSTR(vHora,1,2) || SUBSTR(vHora,4,2) || SUBSTR(vHora,7,2) || '.unl';
	
BEGIN
    -- Manejo de errores
    ON EXCEPTION SET err_sql, err_isam, err_info

		IF ( err_sql <> 0 ) THEN
		
			LET vCodigoRetorno	= err_sql;
			LET vMensaje		= 'Error: ' || err_isam || err_info;
		
			RETURN vCodigoRetorno, vMensaje;
			
		END IF;

    END EXCEPTION;

	--SET DEBUG FILE TO "/home/c90311247/homologacion_sp/cc_32_511_cancelacion/pruebas/sp_homologacion_tarjeta_general.out";
	--TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Tabla de paso para descargar estatus anterior de tarjeta y confirmacion de tarjetas a las que se les aplico cambio
    CREATE TABLE IF NOT EXISTS intercard:tmp_modificacion_homologacion
	(
		numtarjeta			CHAR(16),
		codstatustarjeta	VARCHAR(3),
		codstatusasignada	VARCHAR(3),
		status_tar			CHAR(1)	
    );
	
	CREATE INDEX IF NOT EXISTS tmp_mod_homo_idx1 ON tmp_modificacion_homologacion(numtarjeta) ONLINE;
	
	-- Tabla de paso para leer todas las tarjeta de cada caso  
    CREATE TABLE IF NOT EXISTS intercard:tmp_numtarjeta_homologacion
	(
        numtarjeta            CHAR(16)
    );
	
	CREATE INDEX IF NOT EXISTS tmp_num_homo_idx1 ON tmp_numtarjeta_homologacion(numtarjeta) ONLINE;
	
	TRUNCATE TABLE intercard:tmp_modificacion_homologacion;
	TRUNCATE TABLE intercard:tmp_numtarjeta_homologacion; 
	
	IF inTipoEjecucion = 'N' THEN
	
		-- Se lee el archivo que contiene la lista de tarjetas a trabajar
		LET vExecuteSQL = "echo "||'"'|| "FILE '" || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || "' delimiter '" || '|' || "' " || '1' || "; INSERT INTO "|| 'tmp_numtarjeta_homologacion' || ";" || '"' || ' > '|| TRIM(vRutaArchivo) || TRIM(vNombreTXT);
		SYSTEM vExecuteSQL;
		
	ELSE 
	
		-- Se lee el archivo que contiene la lista de tarjetas a trabajar
		LET vExecuteSQL = "echo "||'"'|| "FILE '" || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || "' delimiter '" || '|' || "' " || '4' || "; INSERT INTO "|| 'tmp_modificacion_homologacion' || ";" || '"' || ' > '|| TRIM(vRutaArchivo) || TRIM(vNombreTXT);
		SYSTEM vExecuteSQL;
		
	END IF;

	LET vExecuteSQL = "chmod 777 " || TRIM(vRutaArchivo) || TRIM(vNombreTXT);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "dbload -d intercard -c " || TRIM(vRutaArchivo) || TRIM(vNombreTXT) || " -l " || TRIM(vRutaArchivo) || TRIM(vNombreLog) || " -n " || 1000 || " -r > " || TRIM(vRutaArchivo) || TRIM(vNombreEjecucionLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "chmod 777 " || TRIM(vRutaArchivo) || TRIM(vNombreLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "chmod 777 " || TRIM(vRutaArchivo) || TRIM(vNombreEjecucionLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "rm -r " || TRIM(vRutaArchivo) || TRIM(vNombreLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "rm -r " || TRIM(vRutaArchivo) || TRIM(vNombreEjecucionLog);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = "rm -r " || TRIM(vRutaArchivo) || TRIM(vNombreTXT);
	SYSTEM vExecuteSQL;
	
	LET vExecuteSQL = "mv " || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || " " || TRIM(vRutaArchivoResultado);
	SYSTEM vExecuteSQL;

	LET vExecuteSQL = '';

	IF inTipoEjecucion = 'N' THEN
	
		IF ((SELECT COUNT(*) FROM intercard:tmp_numtarjeta_homologacion) > 0 ) THEN

			EXECUTE PROCEDURE intercard:sp_homologacion_tarjeta_normal( inNumeroCaso ) INTO vCodigoRetorno, vMensaje;
			
		ELSE 
		
			LET vCodigoRetorno	= '00001';
			LET vMensaje		= 'PROCESO EXITOSO - Archivo vacio, no se proceso ninguna tarjeta';
		
			RETURN vCodigoRetorno, vMensaje;
		
		END IF;
	
		-- Descarga de las tarjetas procesadas, mismo que sirve como un archivo de reverso en caso de aplicar
		IF ((SELECT COUNT(*) FROM intercard:tmp_modificacion_homologacion) > 0 ) THEN
				
			LET vExecuteSQL = 'echo "UNLOAD TO ' || TRIM(vRutaArchivoResultado) || TRIM (vNombreArchivoResultado) || ' DELIMITER '',''" > ' || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;
			
			LET vExecuteSQL = 'chmod 777 ' || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;
		
			LET vExecuteSQL = 'echo "SELECT * FROM intercard:tmp_modificacion_homologacion;" >> ' || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;
		
			LET vExecuteSQL = "dbaccess intercard " || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;
			
			LET vExecuteSQL = "rm -r " || TRIM(vRutaArchivoResultado) || '/querydescarga.sql';
			SYSTEM vExecuteSQL;	
		
			LET vExecuteSQL="";
			
		ELSE 
		
			LET vCodigoRetorno	= '00002';
			LET vMensaje		= 'PROCESO EXITOSO - No se proceso ninguna tarjeta';
			
		END IF;
		
	ELSE 
	
		IF ((SELECT COUNT(*) FROM intercard:tmp_modificacion_homologacion) > 0 ) THEN

			EXECUTE PROCEDURE intercard:sp_homologacion_tarjeta_reverso( inNumeroCaso ) INTO vCodigoRetorno, vMensaje;
			
		ELSE 
		
			LET vCodigoRetorno	= '00001';
			LET vMensaje		= 'PROCESO EXITOSO - Archivo vacio, no se proceso ninguna tarjeta para reversar';
		
			RETURN vCodigoRetorno, vMensaje;
		
		END IF;
	
	END IF;
	
    DROP TABLE IF EXISTS intercard:tmp_modificacion_homologacion;
	DROP TABLE IF EXISTS intercard:tmp_numtarjeta_homologacion; 

	RETURN vCodigoRetorno, vMensaje;

END;
END PROCEDURE;