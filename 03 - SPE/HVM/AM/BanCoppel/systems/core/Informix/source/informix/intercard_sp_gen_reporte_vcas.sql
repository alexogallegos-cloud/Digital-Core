CREATE PROCEDURE "informix".sp_gen_reporte_vcas()
	RETURNING CHAR(5) AS codret, CHAR(20) AS estatus;

	DEFINE cCodRet					CHAR(5);
	DEFINE iSqlErr					INTEGER;
	DEFINE iIsamErr					INTEGER;
	DEFINE iErrorInfo				CHAR(40);
	DEFINE cSQL						CHAR(1500);
	DEFINE cRuta					CHAR(150);
	DEFINE cEstatus					CHAR(100);
	DEFINE iRegistros				INTEGER;
	DEFINE ilimite					INTEGER;
	DEFINE cCmd1					CHAR(1500); 
	DEFINE cNombreReporte			CHAR(100);
	DEFINE cRutaGral				CHAR(150);

	DEFINE vRutaArchivo				CHAR(150);
	DEFINE vArchiBat				CHAR(50); 
	DEFINE vListArchivo				CHAR(20);
	DEFINE vRutaResultadoCardinal	CHAR(250);
	DEFINE vNombreArchivoRecibido	CHAR(250);
	DEFINE ArchivoRecibido			CHAR(250);
	DEFINE vArchivoProcesar			CHAR(250);
	DEFINE vLinea					INTEGER;
	DEFINE vMensaje					CHAR(250);
	DEFINE vPan						CHAR(4);
	DEFINE sCont					INTEGER;
	DEFINE cRutaRespaldo			CHAR(150);
	DEFINE vAction					CHAR(6);
	DEFINE vNumtarjeta				CHAR(16);
	DEFINE vTelefono				CHAR(13);
	DEFINE vCorreo_elec             CHAR(100);
	DEFINE vNombre_regreso_sp		CHAR(28);
	DEFINE vFecha_alta_correo       DATETIME YEAR to FRACTION(5);
	DEFINE vUsuario_alta_correo     CHAR(12);
	DEFINE vFecha_alta_telefono     DATETIME YEAR to FRACTION(5);
	DEFINE vUsuario_alta_telefono   CHAR(12);
    DEFINE vNumero_cliente          VARCHAR(20);
	DEFINE vLinea_dato              INTEGER;
	DEFINE vFecha_registro			DATETIME YEAR to FRACTION(5);
	DEFINE contador_linea 			INTEGER;
    DEFINE pHora 					DATETIME HOUR TO SECOND;
	DEFINE cencabezado1				CHAR(300);
	
	DEFINE vFlasTransaccion			CHAR(1);
	
	LET cCodRet					= '00000';
	LET iSqlErr 				= 0;
	LET iIsamErr				= 0;
	LET iErrorInfo				= '';
	LET cSQL					= '';
	LET cRuta					= '';
	LET cEstatus				= 'PROCESO EXITOSO';
	LET iRegistros				= 0;
	LET ilimite					= 0;
	LET cCmd1					= '';
	LET cNombreReporte			= '';
	LET cRutaGral				= '';
	LET contador_linea          = 0;

	LET vRutaArchivo 			= '/RESPALDOSNEW/VCAS_reporte/Reporte/';
	LET vArchiBat				= 'ls_bat.bat';
	LET vListArchivo			= 'listado_archivos.txt'; 
	LET vRutaResultadoCardinal 	= '/RESPALDOSNEW/VCAS_reporte/Resultado/';
	LET vNombreArchivoRecibido	= '';
	LET ArchivoRecibido			= '';
	LET vArchivoProcesar		= '';
	LET vLinea					= 0;
	LET vMensaje				= '';
	LET vPan					= '';
	LET sCont					= 0;
	LET cRutaRespaldo			= '/RESPALDOSNEW/VCAS_reporte/Respaldo';
	LET vNombre_regreso_sp		='';
	LET vAction					='';
	
	LET vNumtarjeta				='';
	LET vTelefono				='';
	LET vCorreo_elec            ='';
	
	LET vFecha_alta_correo      ='';
	LET vUsuario_alta_correo    ='';
	LET vFecha_alta_telefono    =''; 
	LET vUsuario_alta_telefono  ='';
	LET vNumero_cliente         = '';
	LET vLinea_dato             = 0;
	LET vFecha_registro			='';
    LET pHora					= CURRENT;
	LET cencabezado1			='';
	
	LET vFlasTransaccion 		= 'F';

	-- Drop a tablas 
	DROP TABLE IF EXISTS intercard:vcas_cardinal;
    DROP TABLE IF EXISTS intercard:nombre_recibido_cardinal;

	-- Se crea tabla para almacenar los datos enviados por cardinal numtarjeta, line de dato y mensaje 
	-- Esta tabla contandra entre 500 a 40000 registros por cada archivo que procese dentro del presente flujo
	CREATE TABLE IF NOT EXISTS intercard:vcas_cardinal
	(
		linea		INTEGER,
		mensaje		CHAR(50),
		pan			CHAR(4) 
	);
	
	-- Se crea tabla para escribir el .bat con los nombres que esten en la ruta de recibido porparte de cardinal
	-- Esta tabla contendra entre 10 a 30 archivos por ejecucion aproximadamente
	CREATE TABLE IF NOT EXISTS intercard:nombre_recibido_cardinal
	(
		nombre CHAR(250)
	);
	
BEGIN

	-- Manejo de error
	ON EXCEPTION SET iSqlErr, iIsamErr, iErrorInfo
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/VCAS_reporte/trace_sp_gen_reporte_vcas_err_" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
		--TRACE ON;
		
		IF vFlasTransaccion = 'V' THEN 
			COMMIT;
			LET vFlasTransaccion = 'F';
		END IF;
		
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cEstatus = 'ERROR EN EL PROCESO ' || iIsamErr || ' ' || iErrorInfo;
			RETURN cCodRet, cEstatus;
			
			
			IF iSqlErr = 255 THEN
			LET cCodRet = iSqlErr;
			LET cEstatus = 'ERROR DE TRANSACCION ' || iIsamErr || ' ' || iErrorInfo;
			COMMIT;
			RETURN cCodRet, cEstatus;
			
			END IF;
		END IF;
	END EXCEPTION;	

	--SET DEBUG FILE TO "/RESPALDOSNEW/VCAS_reporte/trace_sp_gen_reporte_vcas_err_" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	INSERT INTO intercard:bitacora_vcas_reporte ( fecha, codigo_error, detalle )
	VALUES ( CURRENT, '00000', 'Inicio de proceso generacion reporte VCAS');

	-- Lectura de la ruta archivo respuesta de VISA cardinal
	LET cSql = '';
	LET cSql = 'echo "ls " '|| TRIM( vRutaResultadoCardinal ) || ' > ' || TRIM( vRutaResultadoCardinal ) || TRIM( vArchiBat );
	SYSTEM cSql;
	
	LET cSql ='';
	LET cSql = 'chmod 777 ' || TRIM(vRutaResultadoCardinal) || TRIM(vArchiBat);
	SYSTEM cSql;

	LET cSql = ''; 
	LET cSql = TRIM(vRutaResultadoCardinal) || TRIM(vArchiBat) || ' > ' || TRIM(vRutaResultadoCardinal) || TRIM(vListArchivo); 
	SYSTEM cSql; 

	LET cSql = '';
	LET cSql = 'rm ' || RTRIM(vRutaResultadoCardinal) || TRIM(vArchiBat);
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'echo "LOAD FROM '|| TRIM(vRutaResultadoCardinal) || TRIM(vListArchivo) || ' INSERT INTO intercard:nombre_recibido_cardinal;" > ' || TRIM(vRutaResultadoCardinal) || 'load_nombre_archivo.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess intercard ' || TRIM(vRutaResultadoCardinal) || 'load_nombre_archivo.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'rm ' || TRIM(vRutaResultadoCardinal) || TRIM(vListArchivo);
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'rm ' || TRIM(vRutaResultadoCardinal) || 'load_nombre_archivo.sql';
	SYSTEM cSql;
	
	-- ENERO 2025 Tabla de paso que registrara de 1 hasta 20 registros, lo cual corresponde al nombre de los reportes enviados por VISA Cardinal en un dia, con la finalidad de poderlos procesar, la cual se borra en cada ejecucion.
	IF
	(
		SELECT COUNT(*)
		FROM intercard:nombre_recibido_cardinal
		WHERE nombre LIKE '%-BanCoppel - MexicoRESULTS%'
		AND LENGTH(nombre) = 72
	) > 0 THEN 

		-- Se valida que no existan archivos repetidos
		FOREACH WITH hold
			
			-- ENERO 2025 Tabla de paso que registrara de 1 hasta 20 registros, lo cual corresponde al nombre de los reportes enviados por VISA Cardinal en un dia, con la finalidad de poderlos procesar, la cual se borra en cada ejecucion.
			SELECT nombre
			INTO vNombreArchivoRecibido
			FROM intercard:nombre_recibido_cardinal
			WHERE nombre LIKE '%-BanCoppel - MexicoRESULTS%'
			AND LENGTH(nombre) = 72

			-- Se valida que no exista el nombre en la tabla para proceder a insertarlo con la fecha de insercion y el parametro Pendiente para posteriror tomarlo para analizar
			IF NOT EXISTS 
			(
				SELECT nombre_archivo
				FROM intercard:archivos_control_vcas
				WHERE nombre_archivo = vNombreArchivoRecibido
			) THEN

				IF EXISTS 
				(
					SELECT TRIM(nombre_archivo)
					FROM intercard:archivos_control_vcas
					WHERE nombre_archivo = TRIM(vNombreArchivoRecibido[1,28])
				) THEN

					INSERT INTO intercard:archivos_control_vcas ( nombre_archivo, fecha_generacion, tipo_archivo, total_registros, estatus )
					VALUES ( TRIM(vNombreArchivoRecibido), CURRENT, 'Recibido',0, 'Pendiente');
					
				ELSE

					INSERT INTO intercard:bitacora_vcas_reporte ( fecha, codigo_error, detalle )
					VALUES ( CURRENT, '00011', 'No existe informacion asociada a los resultados: ' || TRIM(vNombreArchivoRecibido));
					
				END IF;
				
			ELSE

				INSERT INTO intercard:bitacora_vcas_reporte ( fecha, codigo_error, detalle )
				VALUES ( CURRENT, '00012', 'El archivo ya existe en la tabla control: ' || TRIM(vNombreArchivoRecibido));

			END IF;

		END FOREACH;

		IF 
		(
			SELECT COUNT(*)
			FROM intercard:info_credenciales_vcas
		) <= 0 THEN 
			
			LET cCodRet = '00013';
			LET cEstatus = 'No existe ninguna informacion base para validar';
			
			INSERT INTO intercard:bitacora_vcas_reporte ( fecha, codigo_error, detalle )
			VALUES ( CURRENT, cCodRet, cEstatus );
			LET cEstatus = 'PROCESO EXITOSO';
		ELSE
			LET vArchivoProcesar = TRIM(vArchivoProcesar);
			
			FOREACH WITH hold
				-- Se selecciona nombre del archivo que envia cardinal
				SELECT nombre_archivo
				INTO vArchivoProcesar
				FROM intercard:archivos_control_vcas
				WHERE estatus = 'Pendiente' 
				AND tipo_archivo = 'Recibido'

				-- Lectura de archivo enviando por cardinal para llenar tabla vcas_cardinal
				LET cSql = '';
				LET cSql = "echo " || '"' || "FILE '" || TRIM(vRutaResultadoCardinal) || TRIM(vArchivoProcesar) || "' delimiter '" || ',' || "' " || '3' || "; INSERT INTO " || 'vcas_cardinal' || ";" || '"' || ' > ' || TRIM(vRutaArchivo) || 'paso1.txt';
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

				-- Se actualiza el archivo que ya se proceso a un estatus procesado
				SELECT COUNT(*) 
				INTO iRegistros
				FROM vcas_cardinal;
				
				UPDATE intercard:archivos_control_vcas 
				SET estatus = 'Procesado', total_registros = iRegistros
				WHERE nombre_archivo = TRIM(vArchivoProcesar);
				
				UPDATE intercard:archivos_control_vcas 
				SET estatus = 'Procesado' 
				WHERE nombre_archivo = LEFT(vArchivoProcesar, 28);			
				
				LET iRegistros = 0;

				BEGIN WORK;
				LET vFlasTransaccion = 'V';
				
				FOREACH WITH HOLD

					SELECT linea, mensaje, pan
					INTO vLinea, vMensaje, vPan
					FROM intercard:vcas_cardinal

					UPDATE intercard:info_credenciales_vcas
					SET respuesta = vMensaje
					WHERE nombre_archivo = LEFT(vArchivoProcesar,28) 
					AND linea_dato = vLinea 
					AND RIGHT(numero_tarjeta,4) = vPan;

					LET sCont = sCont + 1;

					IF sCont = 1000 THEN
						COMMIT;
						LET vFlasTransaccion = 'F';
						LET sCont = 0;
						BEGIN WORK;
						LET vFlasTransaccion = 'V';
					END IF;

				END FOREACH;

				COMMIT;
				LET vFlasTransaccion = 'F';
				
				-- Se crea el reporte
				LET cNombreReporte = LEFT(vArchivoProcesar,28) || '-REPORTE' || TO_CHAR(CURRENT,'%d%m%Y%H%M%S');

				LET cEncabezado1 = 'echo "Numero de tarjeta, Fecha alta, Sucursal alta, Numero celular, Usuario alta celular, Fecha alta Celular, Correo electronico, Usuario alta correo, Fecha alta correo, Usuario alta, Respuesta " > ' || TRIM(vRutaArchivo) || 'queryenc.sql';
				System cEncabezado1;

				LET cSql = '';
				LET cSql = 'chmod 777 ' || TRIM(vRutaArchivo) || 'queryenc.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cRutaGral = TRIM(vRutaArchivo) || TRIM(cNombreReporte) || 'Aux1.csv';
				
				LET cSql = '';
				LET cSql = 'echo "UNLOAD TO ''' || TRIM(cRutaGral) || ''' DELIMITER '','' " > ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'chmod 777 ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "SELECT t2.numero_tarjeta as numero_tarjeta,TO_CHAR(t1.fechaasignacion,''%d/%m/%Y %H%M%S'') as fecha_alta, l.clave_sucursal as sucursal_alta," >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "t2.telefono as numero_celular,t2.usuario_alta_telefono as usuario_alta_celular, TO_CHAR(t2.fecha_alta_telefono,''%d/%m/%Y %H%M%S'') as fecha_alta_celular," >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "t2.correo as correo, t2.usuario_alta_correo as usuario_alta_correo, TO_CHAR(t2.fecha_alta_correo,''%d/%m/%Y %H%M%S'') as fecha_alta_correo," >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "t1.usuarioultmodif as usuario_alta, t2.respuesta as respuesta" >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "FROM intercard:tarjeta t1" >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "JOIN intercard:info_credenciales_vcas t2" >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "ON t1.numtarjeta = t2.numero_tarjeta"  >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "JOIN (SELECT numerolote, clave_sucursal FROM intercard:lote) l " >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "ON t1.numerolote = l.numerolote" >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'echo "WHERE t2.nombre_archivo = ''' || LEFT(vArchivoProcesar,28) || ''';" >> ' || TRIM(vRutaArchivo) || 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = 'dbaccess intercard ' || TRIM(vRutaArchivo) || 'queryB1.sql > ' || TRIM(vRutaArchivo) || 'log_query.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'chmod 777 ' || TRIM(vRutaArchivo) || 'log_query.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;

				-- SE ANADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
				LET cSql = "sed 's/$//g' " || TRIM(vRutaArchivo) || "queryenc.sql >> " || TRIM(vRutaArchivo) || "archivoReporteAux2.csv";
				SYSTEM TRIM(cSql);

				LET cSql="";
				LET cSql = "sed 's/$//g' "|| TRIM(cRutaGral) || " >> " || TRIM(vRutaArchivo) || "archivoReporteAux2.csv";
				SYSTEM TRIM(cSql);

				-- SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
				LET cSql = "";
				LET cSql = "sed -e 's/.$//' "|| TRIM(vRutaArchivo) || "archivoReporteAux2.csv" || " >> " || TRIM(vRutaArchivo) ||  TRIM (cNombreReporte) || ".csv";
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = 'chmod 777 ' || TRIM(vRutaArchivo) ||  TRIM (cNombreReporte) || ".csv";
				LET cSql = TRIM(cSql);
				SYSTEM cSql;	

				-- BORRADO ARCHIVOS DE PASO
				LET cSql = '';
				LET cSql = 'rm -rf ' || TRIM(vRutaArchivo) || "archivoReporteAux2.csv";
				LET cSql = TRIM(cSql);
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = 'rm -rf ' || TRIM(cRutaGral);
				LET cSql = TRIM(cSql);
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = 'rm -rf ' || TRIM(vRutaArchivo )|| 'queryB1.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = 'rm -rf ' || TRIM(vRutaArchivo )|| 'queryenc.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'rm -rf ' || TRIM(vRutaArchivo )|| 'log_query.sql';
				LET cSql = TRIM(cSql);
				SYSTEM cSql;
				
				LET cSql = '';
				LET cSql = 'mv ' || TRIM(vRutaResultadoCardinal) || "'" || TRIM(vArchivoProcesar) || "'" || ' ' || cRutaRespaldo;
				SYSTEM cSql;

				DELETE FROM intercard:vcas_cardinal;

			END FOREACH;
			
			TRUNCATE TABLE intercard:ctas_vcas;
			-- Nombre del nuevo archivo	
			LET vNombre_regreso_sp = 'ISSUERNAME' || YEAR(CURRENT) || LPAD(MONTH(CURRENT),2,'0') || LPAD(DAY(CURRENT),2,'0') || SUBSTR(pHora::CHAR(8),1,2) || SUBSTR(pHora::CHAR(8),4,2) || SUBSTR(pHora::CHAR(8),7,2) || '.csv';

			FOREACH WITH HOLD
			
				SELECT LEFT(nombre_archivo,28)
				INTO vArchivoProcesar
				FROM intercard:archivos_control_vcas
				WHERE fecha_generacion >= TODAY
                AND total_registros > 0

				-- Se agregan lineas de codigo para crear de nuevo el archivo que se envia a VISA, por recibir una eqtiqueta de "tarjeta no registra en bd VISA 06/11/2024"
				-- Tambien se agrega la instruccion commit cada 1000 registros insertados
				BEGIN;
				LET vFlasTransaccion = 'V';
				
				FOREACH WITH HOLD
				
					SELECT fecha_alta_correo,usuario_alta_correo,correo,fecha_alta_telefono,
					usuario_alta_telefono,telefono,TRIM(numero_cliente),numero_tarjeta
					INTO vFecha_alta_correo,vUsuario_alta_correo,vCorreo_elec,vFecha_alta_telefono,vUsuario_alta_telefono,
					vTelefono,vNumero_cliente,vNumtarjeta
					FROM info_Credenciales_vcas 
					WHERE nombre_archivo = vArchivoProcesar 
					AND respuesta LIKE '%NO_CONSUMER_ACCOUNT_FOUND_FOR_PAN%'
			
					LET contador_linea = contador_linea + 1;
					
					INSERT INTO intercard:ctas_vcas(action,numtarjeta,telefono,correo_elec,fecha,linea)
					VALUES('ADD', vNumtarjeta, vTelefono, vCorreo_elec, CURRENT, contador_linea);
				
					INSERT INTO intercard:info_credenciales_vcas
					(
						fecha_alta_correo,usuario_alta_correo,correo,fecha_alta_telefono,usuario_alta_telefono,
						telefono,numero_cliente,numero_tarjeta, nombre_archivo,linea_dato,respuesta,fecha_registro
					)
					
					VALUES
					(
						vFecha_alta_correo,vUsuario_alta_correo,vCorreo_elec,vFecha_alta_telefono,vUsuario_alta_telefono,
						vTelefono,vNumero_cliente,vNumtarjeta,vNombre_regreso_sp,contador_linea,'',CURRENT
					);
					
					LET sCont = sCont + 1;

					IF sCont = 1000 THEN
						COMMIT;
						LET vFlasTransaccion = 'F';
						LET sCont = 0;
						BEGIN WORK;
						LET vFlasTransaccion = 'V';
					END IF;
					
				END FOREACH;	
				
				COMMIT;
				
			END FOREACH;
			
			-- ENERO 2025 Todos los SP de VCAS descargan informacion de la tabla de paso por lo que se genera un proceso comun para todos y asi reducir y reutilizar codigo
			-- Por tanto, si la tabla de paso tiene registros se procede a descargar el reporte para su envio a VISA
			IF (( SELECT COUNT(*) FROM intercard:ctas_vcas) > 0 ) THEN 
			
				EXECUTE PROCEDURE intercard:sp_descarga_credenciales_vcas(TRIM(vNombre_regreso_sp)) INTO cCodRet, cEstatus;
			
			END IF;
			
		END IF;
	ELSE 

		LET cCodRet = '00001';
		LET cEstatus = 'No hay archivos resultados de VISA Cardinal a procesar';

		INSERT INTO intercard:bitacora_vcas_reporte ( fecha, codigo_error, detalle )
		VALUES ( CURRENT, cCodRet, cEstatus );

		LET cEstatus = 'PROCESO EXITOSO';

	END IF;
	
	LET cCodRet = '00000';
	LET cEstatus = 'PROCESO EXITOSO';
			
	
	RETURN cCodRet, cEstatus;
END; 

END PROCEDURE
DOCUMENT  
'AUTOR: Christopher Jose Leyva Castro',
'FECHA: 04/07/2024',
'DESCRIPCION: Proceso que se encarga de generar el reporte de credenciales (correo y/o email) VCAS para el area de prevencion de fraudes',
'BD: intercard',
'Modificacion: 21/01/2025',
'Autor: Estefania Obregon Catillo - Christopher Jose Leyva Castro',
'Descripcion: Se realiza el ajuste para manejar el error de envio de actualizacion de informacion siendo que deberia agregarse la informacion NO_CONSUMER_ACCOUNT_FOUND_FOR_PAN dada la confirmacion de PDF';

CREATE PROCEDURE "informix".sp_descarga_credenciales_vcas(pNombreArchivo CHAR(28))
RETURNING CHAR(5) as codret, CHAR(20) as estatus;

	DEFINE codret 			CHAR(5);
	DEFINE estatus			CHAR(20);

	DEFINE v_sql     		CHAR(250);
	DEFINE cEncabezado  	CHAR(250);
	DEFINE vreg_ins			INTEGER;
	
	DEFINE cRuta 			CHAR(250);
	DEFINE cRuta2 			CHAR(250);
	DEFINE cNombreArchivo 	CHAR(250);
	DEFINE cNombreArchivo1 	CHAR(250);
	DEFINE cNombreArchivo2 	CHAR(250);
	
    DEFINE vcod_ret         VARCHAR(10);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(40);
	
	LET codret 			= "000";
	LET estatus			= "DESCARGA EXITOSA";
	
	LET vreg_ins		= 0;
	
	LET cRuta 			= "/RESPALDOSNEW/";
	LET cRuta2 			= "/RESPALDOSNEW/VCAS_resultados/";
	
BEGIN
	
	-- MANEJO DEL ERROR.
	ON EXCEPTION SET sql_err, isam_err, error_info
				
		-- SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_tarj_det_vcas.err.out" WITH APPEND;
		-- TRACE ON;
		
		IF sql_err <> 0 THEN
			LET vcod_ret = sql_err;
			
			RETURN vcod_ret, isam_err||' ' ||error_info;
		END IF;
		
	END EXCEPTION;
	
	-- DESCARGAR ARCHIVO.
				
	--SET DEBUG FILE TO "/RESPALDOSNEW/VCAS_reporte/204.out";
	--TRACE ON;

	-- Definicion de variables de paso para generacion de archivo VCAS con informacion
	LET cNombreArchivo = TRIM(cRuta2) || pNombreArchivo;
	LET cNombreArchivo1 = TRIM(cRuta) || LEFT(TRIM(pNombreArchivo),24)||'_aux.csv';
	LET cNombreArchivo2 = TRIM(cRuta) || LEFT(TRIM(pNombreArchivo),24)||'_aux2.csv';
		
	-- DESCARGA DEL ARCHIVO .CSV.
	LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /RESPALDOSNEW/queryenc.sql';
	System cEncabezado;
	
	LET v_sql = 'chmod 777 /RESPALDOSNEW/queryenc.sql';
	System v_sql;

	LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /RESPALDOSNEW/queryhist.sql ';
	System v_sql;
	
	LET v_sql = 'chmod 777 /RESPALDOSNEW/queryhist.sql';
	System v_sql;

	LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /RESPALDOSNEW/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /RESPALDOSNEW/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo " from intercard:ctas_vcas where numtarjeta <> ''''" >> /RESPALDOSNEW/queryhist.sql';
	System v_sql;

	LET v_sql = 'echo " order by linea asc" >> /RESPALDOSNEW/queryhist.sql';
	System v_sql;

	LET v_sql = "dbaccess intercard /RESPALDOSNEW/queryhist.sql";
	System v_sql;

	LET v_sql="";

	-- SE ANADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
	LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
	SYSTEM TRIM(v_sql);

	LET v_sql="";	
	LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
	SYSTEM TRIM(v_sql);

	-- SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
	LET v_sql = "";
	LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
	SYSTEM v_sql;

	LET v_sql = "";
	LET v_sql = 'chmod 777 '||TRIM(cNombreArchivo);
	SYSTEM v_sql;
	
	-- BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
	LET v_sql = "";
	LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";
	SYSTEM TRIM(v_sql);

	LET v_sql = "";
	LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";
	SYSTEM TRIM(v_sql);

	LET v_sql = "";
	LET v_sql = "rm " || TRIM(cNombreArchivo1);
	SYSTEM TRIM(v_sql);

	LET v_sql = "";
	LET v_sql = "rm " || TRIM(cNombreArchivo2);
	SYSTEM TRIM(v_sql);
	
	-- Insertar en la variable el conteo de registros del archivo procesado
	SELECT COUNT(*)
	INTO vreg_ins
	FROM intercard:ctas_vcas;
	
	--Se inserta en la tabla archivos control el nombre del archivo que se creo
	INSERT INTO intercard:archivos_control_vcas( nombre_archivo, fecha_generacion, tipo_archivo, total_registros, estatus ) 
	VALUES (pNombreArchivo, CURRENT, 'Enviado', vreg_ins, 'Pendiente');
	
	TRUNCATE TABLE intercard:ctas_vcas;
	
	RETURN codret, estatus;
		
END;
		
END PROCEDURE;