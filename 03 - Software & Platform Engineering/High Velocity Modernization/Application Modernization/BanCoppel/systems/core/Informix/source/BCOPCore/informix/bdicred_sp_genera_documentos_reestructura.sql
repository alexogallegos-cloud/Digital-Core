CREATE PROCEDURE "informix".sp_genera_documentos_reestructura()
RETURNING CHAR(5), CHAR(30);

--DECLARACIÃN DE VARIABLES
DEFINE cCodRet							CHAR(5);
DEFINE cMensajeRet						CHAR(30);
DEFINE cRutaJar							CHAR(100);
DEFINE cRutaArchivo						CHAR(100);
DEFINE cRutaLectura						CHAR(100);
DEFINE cRutaJava						CHAR(100);
DEFINE cNombreArchivoReestructura		CHAR(100);
DEFINE cNombreArchivoReestructuraAux	CHAR(100);
DEFINE cCommand							CHAR(2000);
DEFINE cNumCliente						CHAR(9);
DEFINE cNumCredito						CHAR(20);
DEFINE cNumCreditoExterno				CHAR(20);
DEFINE cCuenta							CHAR(20);

DEFINE cEmpresa							CHAR(3);
DEFINE cIdentificador					CHAR(1);
DEFINE cIdentificador2					CHAR(1);
DEFINE cIdentificador3					CHAR(1);
DEFINE cProducto						CHAR(4);
DEFINE cProductoReestructura			CHAR(4);
DEFINE cDescripProductoReestructura		CHAR(40);
DEFINE cDescripProducto					CHAR(40);
DEFINE cSucursal						CHAR(4);
DEFINE cNombreSucursal					CHAR(40);
DEFINE cCorreoElectronico				CHAR(100);

DEFINE dFechaHoy						DATE;
DEFINE dcSdoReest						DECIMAL(18,2);
DEFINE dValorPreferencial				DECIMAL(18,2);
DEFINE dTasaInteres						DECIMAL(9,6);
DEFINE iSqlErr							INTEGER;
DEFINE iContador						INTEGER;
DEFINE iPlazo							INTEGER;


DEFINE cContadorCuenta					SMALLINT;

LET cCodRet								= '00000';
LET cMensajeRet							= 'EL PROCESO FUE EXITOSO';
/* DESARROLLO
LET cRutaJar							= '/informix/roman/digitalizacion_documentos/caratulasCredito/';--RUTA DONDE SE ENCUENTRA EL JAR FÃSICAMENTE.
LET cRutaArchivo						= '/informix/roman/digitalizacion_documentos/caratulasCredito/';--RUTA DE DONDE OBTENDRÃ EL JAR LAS PLANTILLAS PARA SU PROCESO
LET cRutaLectura						= '/informix/roman/digitalizacion_documentos/caratulasCredito/archivosLectura/'; --RUTA DONDE COLOCARÃ LOS ARCHIVOS QUE LEERÃ EL JAR PARA SU PROCESO
*/

--PRODUCCIÃN
LET cRutaJar							= '/RESPALDOSNEW/digitalizacion_documentos/';
LET cRutaArchivo						= '/RESPALDOSNEW/digitalizacion_documentos/';
LET cRutaLectura						= '/RESPALDOSNEW/digitalizacion_documentos/caratulasCredito/'; --RUTA DONDE COLOCARÃ LOS ARCHIVOS QUE LEERÃ EL JAR PARA SU PROCESO

LET cRutaJava							= '/usr/java8/bin/java -jar ';
LET cIdentificador						= '#';
LET cIdentificador2						= '-';
LET cIdentificador3						= '_';
LET cCommand							= '';
LET iSqlErr								= 0;
LET iContador							= 0;
LET iPlazo								= 0;
LET dcSdoReest							= 0;
LET dValorPreferencial					= 0;
LET dTasaInteres						= 0;


LET cNumCliente							= '';
LET cNumCredito							= '';
LET cNumCreditoExterno					= '';

LET dFechaHoy							= '';
LET cEmpresa							= '001';
LET cProducto							= '';
LET cProductoReestructura				= '';
LET cDescripProducto					= '';
LET cDescripProductoReestructura		= '';
LET cSucursal							= '';
LET cNombreSucursal						= '';
LET cCorreoElectronico					= '';
LET cCuenta								= '';

LET cContadorCuenta						= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		LET cMensajeRet = 'OCURRIÃ UN ERROR EN LA EJECUCIÃN';
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/informix/roman/digitalizacion_documentos/sp_genera_documentos_reestructura.out';
	--TRACE ON;
	
	--OBTENEMOS FECHA ACTUAL
	SELECT fecha_hoy INTO dFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = cEmpresa;
	--LET dFechaHoy = today;
	



	--REALIZAMOS UNA BÃSQUEDA A LA TABLA sd_programacion_reestructuras_aut PARA VERIFICAR SI EXISTEN CLIENTES CON FECHA_HOY
	--PARA LA CREACIÃN DE CARATULAS.
	SELECT COUNT(numcte) INTO iContador FROM bdicred:"informix".sd_programacion_reestructuras_aut where fecha = dFechaHoy;
	
	--SI EXISTE POR LO MENOS UN CLIENTE SE REALIZA EL PROCESO
	IF iContador > 0 THEN
		FOREACH
			SELECT numcte, num_credito, correo_electronico, num_producto
			INTO cNumCliente, cNumCredito, cCorreoElectronico, cProducto
			FROM bdicred:"informix".sd_programacion_reestructuras_aut where fecha = dFechaHoy
			

			LET cNombreArchivoReestructura = 'DatosReestructura_' || cNumCliente || '.txt';
			LET cNombreArchivoReestructuraAux = 'DatosReestructuraAux_' || cNumCliente || '.txt';
			
			LET cCommand = 'echo "UNLOAD TO ' || TRIM(cRutaLectura) || TRIM(cNombreArchivoReestructuraAux) || ' DELIMITER ''|'' "> ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql;';
			SYSTEM TRIM(cCommand);
			
			--GENERAMOS LA CONSULTA PARA EXTRAER LA INFORMACIÃN PERSONAL DEL CLIENTE, FECHA DE NACIEMIENTO Y NOMBRE COMPLETO
			LET cCommand = 'echo "SELECT ''' || cIdentificador || ''', ''' || dFechaHoy || ''', ' || cNumCliente || ',a.fecha_nac, TRIM(b.nombre1) ||' || ''' ''' || ' || TRIM(b.nombre2) || ' || ''' ''' || ' || TRIM(b.apell_paterno) || ' || ''' ''' || ' || TRIM(b.apell_materno), '
							|| '''' || TRIM(cCorreoElectronico) || ''' FROM bdinteg:si_ctepf a INNER JOIN bdinteg:si_cliente b ON a.numcte = b.numcte WHERE b.numcte=' ||cNumCliente || ';" >> ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql;';
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'chmod 777 ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql;';
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'dbaccess bdicred ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql;';
			SYSTEM TRIM(cCommand);
			
			LET cCommand = "sed 's/|$//g' " || TRIM(cRutaLectura) || cNombreArchivoReestructuraAux || ' > ' || TRIM(cRutaLectura) || cNombreArchivoReestructura;
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'rm ' || TRIM(cRutaLectura) || TRIM(cNombreArchivoReestructuraAux);
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'rm ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql';
			SYSTEM TRIM(cCommand);
			
			--SE AGREGA SEPARACIÃN DE INFORMACIÃN ENTRE DATOS PERSONALES Y DATOS DE LA CUENTA
			LET cCommand = 'echo "-----------------------------------------" >> ' || TRIM(cRutaLectura) || cNombreArchivoReestructura;
			SYSTEM TRIM(cCommand);
			
			--SE REALIZA LA CONSULTA A LA TABLA MAECREDCRD PARA OBTENER LOS CREDITOS EXTERNOS
			IF (cProducto = '6001') THEN --CRÃDITO
				
				SELECT  credito_externo
				INTO cNumCreditoExterno


				FROM bdicred:"informix".sd_maecred
				WHERE num_credito = cNumCredito;
				
			ELSE -- PRESTAMO PERSONAL
			
				SELECT credito_externo
				INTO cNumCreditoExterno
				FROM bdicred:"informix".sd_maecredcrd
				WHERE num_credito = cNumCredito;
			
			END IF;
			
			SELECT monto_solicitado INTO dcSdoReest FROM bdisolic:ss_solicitudes WHERE num_solicitud = cNumCreditoExterno;
			
			SELECT plazo, valor_preferencial, sucursal, tasa_interes, num_producto
			INTO iPlazo, dValorPreferencial, cSucursal, dTasaInteres, cProductoReestructura
			FROM bdicred:sd_maecredcrd WHERE num_credito = TRIM(cNumCreditoExterno);
		
			--SE REALIZA LA CONSULTA A LA TABLA SD_DEFINICION PARA OBTENER EL TITULO DEL ARCHIVO REESTRUCTURAS.
			SELECT nombre_prod INTO cDescripProductoReestructura FROM bdicred:sd_definicion WHERE num_producto = cProductoReestructura;

			
			--SE REALIZA VALIDACIÃN PARA DETERMINAR A QUE TABLAS SE VA A DIRIGIR

			





		select count(*) into cContadorCuenta FROM bdicheq:sc_maechq WHERE num_cte = cNumCliente AND status_cta = 1; 
			
			IF cContadorCuenta > 0 then
				SELECT cuenta INTO cCuenta FROM bdicheq:sc_maechq WHERE num_cte = cNumCliente AND status_cta = 1;
			END IF

			
			SELECT descrip_prod INTO cDescripProducto FROM bdicred:"informix".sd_tipprod WHERE abrevia_prod = cProducto;



			
			SELECT nombre INTO cNombreSucursal FROM bdinteg:si_sucursales WHERE sucursal = cSucursal;








		
			LET cCommand = 'echo ' || cIdentificador2 || '''|''' || TRIM(cDescripProducto) || '''|''' || iPlazo || '''|''' || dcSdoReest || '''|''' || cNombreSucursal || '''|''' || dValorPreferencial || 
						'''|''' || cDescripProductoReestructura || '''|''' || cNumCredito || '''|''' || cNumCreditoExterno || '''|''' || cCuenta || '''|''' || dTasaInteres ||'>> '
							|| TRIM(cRutaLectura) || cNombreArchivoReestructura;
			SYSTEM TRIM(cCommand);
			
			--SE AGREGA SEPARACIÃN DE INFORMACIÃN ENTRE DATOS PERSONALE, DATOS DE LA CUENTA Y AMORTIZACIÃN
			LET cCommand = 'echo "-----------------------------------------" >> ' || TRIM(cRutaLectura) || cNombreArchivoReestructura;
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'echo "UNLOAD TO ' || TRIM(cRutaLectura) || TRIM(cNombreArchivoReestructuraAux) || ' DELIMITER ''|'' "> ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql;';
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'echo "SELECT '''|| cIdentificador3 || ''', SUM(1) OVER (ORDER BY rowid) AS rownumber, fecha_cuota, capital_mto_cuota ' || 
						 'FROM bdicred:sd_amortiza_creditocrd WHERE num_credito=''' || TRIM(cNumCreditoExterno) || '''' || ';" >> ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql;';
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'chmod 777 ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql;';
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'dbaccess bdicred ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql;';
			SYSTEM TRIM(cCommand);
			
			LET cCommand = "sed 's/|$//g' " || TRIM(cRutaLectura) || cNombreArchivoReestructuraAux || ' >> ' || TRIM(cRutaLectura) || cNombreArchivoReestructura;
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'rm ' || TRIM(cRutaLectura) || TRIM(cNombreArchivoReestructuraAux);
			SYSTEM TRIM(cCommand);
			
			LET cCommand = 'rm ' || TRIM(cRutaLectura) || 'ejecutaReestructura.sql';
			SYSTEM TRIM(cCommand);
		END FOREACH;
		
		--EL PROCESO ANTERIOR TERMIAN DE GENERAR LOS ARCHIVOS CORRESPONDIENTES A LOS CLIENTES ENCONTRADOS
		--Y SE REALIZA EL LAMADO AL COMPONENTE CaratulasCredito.jar PARA REALIZAR EL SIGUIENTE PROCESO.
		LET cCommand = TRIM(cRutaJava) || ' ' || TRIM(cRutaArchivo) || 'CaratulasCredito.jar ' || cRutaLectura || ' ' || cRutaArchivo;
		SYSTEM TRIM(cCommand);
		
	ELSE
		BEGIN;
		INSERT INTO  bdicred:"informix".sd_bitacora_mec values 
		('001', '0011', today, '00001', 'NO SE ENCONTRO INFORMACION PARA PROCESAR.', user, today, current );
		LET cCodRet   = '00000';
		LET cMensajeRet = 'NO SE ENCONTRO INFORMACION PARA PROCESAR.';
		COMMIT;
	END IF;
	
	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE;