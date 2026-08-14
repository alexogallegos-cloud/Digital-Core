CREATE PROCEDURE "informix".sp_solicitud_manual_maquila_tarjetas_personalizadas()
	RETURNING CHAR(5) AS cCodRet, CHAR(100) AS cEstatus;
	
	DEFINE cCodRet					CHAR(5);
	DEFINE cEstatus					CHAR(100);
	DEFINE vArchiBat				CHAR(50); 
	DEFINE vListArchivo				CHAR(20);
	DEFINE iIsamErr					INTEGER;
	DEFINE iErrorInfo				CHAR(40);
	DEFINE iSqlErr					INTEGER;
	DEFINE cSql						CHAR(250);
	
	DEFINE vNumero_cliente					VARCHAR(13);
	DEFINE vNumero_cuenta					VARCHAR(13);		
	DEFINE vNombre1							VARCHAR(20);
	DEFINE vNombre2							VARCHAR(20);
	DEFINE vApaterno						VARCHAR(20);
	DEFINE vAmaterno						VARCHAR(20);
	DEFINE vDireccion_calle1				VARCHAR(30);
	DEFINE vDireccion_calle2				VARCHAR(30);
	DEFINE vDireccion_colonia				VARCHAR(50);
	DEFINE vDireccion_municipio				VARCHAR(15);
	DEFINE vDireccion_estado				VARCHAR(13);
	DEFINE vDireccion_cp					VARCHAR(5);
	DEFINE vClave_tipo_tarjeta				INTEGER;
	DEFINE vTitular							CHAR(1);
	DEFINE vTipoenvio						CHAR(1);
	DEFINE vNombre_tarjeta					CHAR(21);
	DEFINE vNumero_tarjeta					CHAR(16);
	DEFINE vFlagdiseno						CHAR(1);
	DEFINE vId_diseno 						INTEGER;
	DEFINE vFlagmaster						CHAR(1);
	DEFINE vFlagemision						CHAR(1);
	DEFINE vMembersince						CHAR(2);
	DEFINE vWkit							CHAR(1);
	DEFINE vCat								DECIMAL(4,2);
	DEFINE vIntanuord						DECIMAL(4,2);	
	DEFINE vIntanumor						DECIMAL(4,2);
	DEFINE vLineacredito					INTEGER;
	DEFINE vFlagsms							CHAR(1);
	DEFINE vSucursal						CHAR(5);
	DEFINE vTipoDeTarjetaaSolicitar 		CHAR(2);
	DEFINE vProductoCuentaaSolicitar 		CHAR(4);
	DEFINE vCodigoProductoTarjetaaSolicitar CHAR(3);
	
	DEFINE vfecha_vigencia  		VARCHAR(4);
	DEFINE vCont					INTEGER;
	DEFINE vSegundos				INTEGER;
	DEFINE vMinutos					INTEGER;
	DEFINE vHoras					INTEGER;
	DEFINE vDia						VARCHAR(2);
	DEFINE vMes						VARCHAR(2);
	DEFINE vYear					VARCHAR(4);
	DEFINE vRutaArchivo				VARCHAR(50);
	DEFINE vNombreArchivo			VARCHAR(100);
	DEFINE vRutaProcesado			VARCHAR(100);
	DEFINE vRegistros				INTEGER;
	
	LET cEstatus				= 'Proceso Exitoso.';
	LET cCodRet					= '00000';
	LET vArchiBat				= 'ls_bat.bat';
	LET vListArchivo			= 'listado_archivos.txt';
	LET iIsamErr				= 0;
	LET iErrorInfo				= '';
	LET iSqlErr 				= 0;
	LET cSql 					='';
	
	LET vNumero_cliente						= '';
	LET vNumero_cuenta						= ''; 
	LET vNombre1							= ''; 
	LET vNombre2							= ''; 
	LET vApaterno							= ''; 
	LET vAmaterno							= ''; 
	LET vDireccion_calle1					= ''; 
	LET vDireccion_calle2					= ''; 
	LET vDireccion_colonia					= ''; 
	LET vDireccion_municipio				= ''; 
	LET vDireccion_estado					= ''; 
	LET vDireccion_cp						= ''; 
	LET vClave_tipo_tarjeta					= 0;   
	LET vTitular							= ''; 
	LET vTipoenvio							= ''; 
	LET vNombre_tarjeta						= ''; 
	LET vNumero_tarjeta						= ''; 
	LET vFlagdiseno							= ''; 
	LET vId_diseno 							= 0;  
	LET vFlagmaster							= ''; 
	LET vFlagemision						= ''; 
	LET vMembersince						= ''; 
	LET vWkit								= ''; 
	LET vCat								= 0.0;
	LET vIntanuord							= 0.0;
	LET vIntanumor							= 0.0;
	LET vLineacredito						= 0;  
	LET vFlagsms							= ''; 
	LET vSucursal							= ''; 
	LET vTipoDeTarjetaaSolicitar 			= '';
	LET vProductoCuentaaSolicitar 		    = '';
	LET vCodigoProductoTarjetaaSolicitar 	= '';
	
	LET vfecha_vigencia			= '';
	LET vCont					= 0;
	LET vSegundos				= 0;
	LET vMinutos				= 30;
	LET vHoras					= 22;
	LET vDia					= '';
	LET vMes					= '';
	LET vYear					= '';
	LET vRutaArchivo			= '/RESPALDOSNEW/MaquilaPersonalizada/';
	LET vNombreArchivo			= '';
	LET vRegistros				= 0;
	LET vRutaProcesado			= '/RESPALDOSNEW/MaquilaPersonalizada/Procesado/';
		
	SELECT FIRST 1 SUBSTR(year(today)+5, 3, 2) || LPAD(MONTH(TODAY), 2, '0')
	INTO vfecha_vigencia
	FROM intercard:bines;
	
	SELECT FIRST 1 DAY(today)
	INTO vDia
	FROM intercard:bines;
	
	SELECT FIRST 1 MONTH(today)
	INTO vMes
	FROM intercard:bines;
	
	SELECT FIRST 1 YEAR(today)
	INTO vYear
	FROM intercard:bines;
		
	-- Se crea tabla temporal para almacenar los datos del archivo
	CREATE TABLE IF NOT EXISTS intercard:tmp_solicitud_tarjeta 
	(			
		numero_cliente						VARCHAR(13),
		numero_cuenta						VARCHAR(13),		
		nombre1								VARCHAR(20),
		nombre2								VARCHAR(20),
		apaterno							VARCHAR(20),
		amaterno							VARCHAR(20),
		direccion_calle1					VARCHAR(30),
		direccion_calle2					VARCHAR(30),
		direccion_colonia					VARCHAR(50),
		direccion_municipio					VARCHAR(15),
		direccion_estado					VARCHAR(13),
		direccion_cp						VARCHAR(5),
		clave_tipo_tarjeta					INTEGER,
		titular								CHAR(1),
		tipoenvio							CHAR(1),
		nombre_tarjeta						CHAR(21),
		numero_tarjeta						CHAR(16),
		flagdiseno							CHAR(1),
		id_diseno 							INTEGER,
		flagmaster							CHAR(1),
		flagemision							CHAR(1),
		membersince							CHAR(2),
		wkit								CHAR(1),
		cat									DECIMAL(4,2),
		intanuord							DECIMAL(4,2),	
		intanumor							DECIMAL(4,2),	
		lineacredito						INTEGER,
		flagsms								CHAR(1),
		sucursal							CHAR(5),
		tipoDeTarjetaaSolicitar 			CHAR(2),
		productoCuentaaSolicitar 			CHAR(4),
		codigoProductoTarjetaaSolicitar 	CHAR(3)
		
	);
			
	CREATE TABLE IF NOT EXISTS intercard:nombre_archivo_tarjetas
	(
		nombre CHAR(250)
	);
	
	TRUNCATE TABLE intercard:tmp_solicitud_tarjeta;
	TRUNCATE TABLE intercard:nombre_archivo_tarjetas;
	
BEGIN
	
	-- Manejo de error
	ON EXCEPTION SET iSqlErr, iIsamErr, iErrorInfo
		
		-- SET DEBUG FILE TO "/home/c90265232/trace_manual_err_" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
		-- TRACE ON;
		
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cEstatus = 'ERROR EN EL PROCESO ' || iIsamErr || ' ' || iErrorInfo;
			RETURN cCodRet, cEstatus;
		END IF;
	END EXCEPTION;	

	-- SET DEBUG FILE TO "/home/c90265232/trace_manual" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
		--Lectura de ruta de archivos
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
		LET cSql = 'echo "LOAD FROM '|| TRIM(vRutaArchivo) || TRIM(vListArchivo) || ' INSERT INTO intercard:nombre_archivo_tarjetas;" > ' || TRIM(vRutaArchivo) || 'load_nombre_archivo.sql';
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
		
		IF EXISTS 
		(
			SELECT nombre
			FROM intercard:nombre_archivo_tarjetas
			WHERE nombre LIKE 'SOLICITUD_MAQUILA_%'
		)THEN 
		
			FOREACH WITH HOLD
			
				SELECT TRIM(nombre)
				INTO vNombreArchivo
				FROM intercard:nombre_archivo_tarjetas
				WHERE nombre LIKE 'SOLICITUD_MAQUILA_%'
				
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
			LET cEstatus = 'Proceso Exitoso. No hay archivos por procesar';
			LET cCodRet = '00001';
	
			RETURN cCodRet, cEstatus;
		END IF;
		
		IF NOT EXISTS
		(
			SELECT nombre_archivo
			FROM intercard:tarjetas_personalizadas_control
			WHERE estatus = 'Pendiente'
		) THEN 
		
			LET cEstatus = 'Proceso Exitoso. No hay archivos pendientes por procesar';
			LET cCodRet = '00001';
	
			RETURN cCodRet, cEstatus;
			
		END IF;
		
		FOREACH WITH HOLD
		
			SELECT nombre_archivo
			INTO vNombreArchivo
			FROM intercard:tarjetas_personalizadas_control
			WHERE estatus = 'Pendiente'
			
			--Lectura de archivo para llenar tabla temporal
			LET cSql = '';
			LET cSql = "echo " || '"' || "FILE '" || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || "' delimiter '" || '|' || "' " || '32' || "; INSERT INTO " || 'tmp_solicitud_tarjeta' || ";" || '"' || ' > ' || TRIM(vRutaArchivo) || 'paso1.txt';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = "dbload -d intercard -c " || TRIM(vRutaArchivo) || 'paso1.txt' || " -l " || TRIM(vRutaArchivo) || 'paso1.log' || " -n " || 1000 || " -r > " || TRIM(vRutaArchivo) || 'paso1_rep.log';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = 'rm ' || TRIM(vRutaArchivo) || 'paso1.txt';
			SYSTEM cSql;

			LET cSql = '';  
			LET cSql ='rm ' || TRIM(vRutaArchivo) || 'paso1.log';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql ='rm ' || TRIM(vRutaArchivo) || 'paso1_rep.log';
			SYSTEM cSql;
			
			SELECT COUNT(*) 
			INTO vRegistros
			FROM tmp_solicitud_tarjeta;
			
			IF vRegistros >= 1 THEN
			
				LET vCont = 0;
				
				BEGIN WORK;
				
				FOREACH WITH HOLD
		
					--Obtencion de valores de tabla temporal
					SELECT numero_cliente, numero_cuenta, nombre1, nombre2, apaterno, amaterno, direccion_calle1, direccion_calle2, direccion_colonia,	
					direccion_municipio, direccion_estado, direccion_cp, clave_tipo_tarjeta, titular, tipoenvio, nombre_tarjeta, numero_tarjeta, flagdiseno,			
					id_diseno, flagmaster, flagemision, membersince, wkit, cat, intanuord, intanumor, lineacredito, flagsms, sucursal, tipoDeTarjetaaSolicitar, 		
					productoCuentaaSolicitar, codigoProductoTarjetaaSolicitar					
					INTO vNumero_cliente,vNumero_cuenta,vNombre1,vNombre2,vApaterno,vAmaterno,vDireccion_calle1,vDireccion_calle2,vDireccion_colonia,
					vDireccion_municipio,vDireccion_estado,vDireccion_cp,vClave_tipo_tarjeta,vTitular,vTipoenvio,vNombre_tarjeta,vNumero_tarjeta,vFlagdiseno,
					vId_diseno,vFlagmaster,vFlagemision,vMembersince,vWkit,vCat,vIntanuord,vIntanumor,vLineacredito,vFlagsms,vSucursal, vTipoDeTarjetaaSolicitar, 		
					vProductoCuentaaSolicitar, vCodigoProductoTarjetaaSolicitar
					FROM intercard:tmp_solicitud_tarjeta
			
					--Insertdesolicitudmaquila
					INSERT INTO intercard:solicitud_maquila
					(
						consecutivo,clave_sucursal,indicadortipoproceso,clave_tipotarjeta,fechaexp,codproductotarjeta,cantidad,
						fecha_generacion,nom_cliente,flagprocesorealizado,usuario,tipomaquila,flagdiseno,id_diseno
					)
					VALUES
					(
						secuencia_solmaquila.nextVal,vSucursal,'P',vTipoDeTarjetaaSolicitar,vfecha_vigencia,vCodigoProductoTarjetaaSolicitar,1,
						EXTEND(MDY(vMes, vDia, vYear), YEAR TO SECOND)+ vHoras UNITS HOUR + vMinutos UNITS MINUTE + vSegundos UNITS SECOND,vNombre_tarjeta,'F','intercar','E',vFlagdiseno,vId_diseno
					); 
				
					--Insertdesolicitudtarjeta
					INSERT INTO intercard:solicitudtarjeta
					( 
						idsolicitud,numcliente,numcuenta,nombre1,nombre2,apaterno,amaterno,direccion_calle1,direccion_calle2,direccion_colonia,
						direccion_municipio,direccion_estado,direccion_cp,clave_tipotarjeta,codprodcta,codproductotarjeta,titular,tipoenvio,nombretarjeta,fechaexp,numtarjeta,flagdiseno,
						id_diseno,flagmaster,flagemision,membersince,wkit,cat,intanuord,intanumor,lineacredito,flagsms,tipomaquila,usuario,canal,sucursal,
						fechasolicitud,estatusproceso
					)
					VALUES
					(
						(SELECT idsolicitudtarjeta FROM intercard:paraminventarios),vNumero_cliente,vNumero_cuenta,vNombre1,vNombre2,vApaterno,vAmaterno,vDireccion_calle1,vDireccion_calle2,vDireccion_colonia,
						vDireccion_municipio,vDireccion_estado,vDireccion_cp,vTipoDeTarjetaaSolicitar,vProductoCuentaaSolicitar,vCodigoProductoTarjetaaSolicitar,vTitular,vTipoenvio,vNombre_tarjeta,vfecha_vigencia,vNumero_tarjeta,vFlagdiseno,
						vId_diseno,vFlagmaster,vFlagemision,vMembersince,vWkit,vCat,vIntanuord,vIntanumor,vlineacredito,vflagsms,'E','intercar','informix',vSucursal,
						EXTEND(MDY(vMes, vDia, vYear),YEAR TO SECOND) + vHoras UNITS HOUR + vMinutos UNITS MINUTE + vSegundos UNITS SECOND,'F'
					);
					
					UPDATE intercard:paraminventarios
					SET idsolicitudtarjeta = idsolicitudtarjeta + 1;
					
					--Contadordetarjetas
					LET vCont = vCont + 1;

					IF vCont = 500 THEN
						COMMIT;
						LET vCont = 0;
						BEGIN WORK;
					END IF;
					
					IF vSegundos < 55 THEN
						LET vSegundos = vSegundos + 5;
					ELSE
						LET vSegundos = 0;
							IF vMinutos < 59 THEN
								LET vMinutos = vMinutos + 1;
							ELSE
								LET vMinutos = 0;
									IF vHoras < 23 THEN
									LET vHoras = vHoras + 1;
									ELSE
									LET vHoras = 0;
									END IF;			
							END IF;
					END IF;		
				END FOREACH;
				
				COMMIT;
				
				UPDATE intercard:tarjetas_personalizadas_control 
				SET estatus = 'Procesado', total_registros = vRegistros
				WHERE nombre_archivo = TRIM(vNombreArchivo);
				
				TRUNCATE TABLE tmp_solicitud_tarjeta;
				
				LET cSql = '';
				LET cSql = 'mv ' || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || ' ' || vRutaProcesado;
				SYSTEM cSql;
				
			ELSE 
		
				LET cEstatus = 'Proceso Exitoso. Uno o varios archivos procesados estÃ¡n vacios';
				LET cCodRet = '00002';
			
			END IF;
			
		END FOREACH;
			
	-- Se elimina la tabla temporal
	DROP TABLE tmp_solicitud_tarjeta;
	DROP TABLE nombre_archivo_tarjetas;
	
	RETURN cCodRet, cEstatus;
	
END;	
END PROCEDURE
;