create procedure "informix".sp_transfer_cargaarchivos ( 
					psruta_repositorio 		varchar (90), 	-- Ruta donde esta el archivo
					psnomarchivo			varchar (50),	-- Nombre del archivo 
					psarchivoorigen 		varchar(3), 	-- Abreviatura del nombre del archivo
					pitipolayout 			integer, 		-- Identificador del tipo layout
					psruta_procesos 		varchar (90),	-- Ruta donde operan los proceso de carga
					psseguridad 			char(1)			-- Bandera para identificar la seguridad del archivo
					)

returning 	
				varchar (5) as codret,
				varchar(250) as mensaje_respuesta,
				integer as tot_registros, 
				integer as elemento;

-- variable para ejecución de comandos 
define vssql char (1150) ;

-- variables de control de errores
define visqlerr integer ;
define vscodret varchar(5);
define vsmensaje_respuesta varchar(250);

-- variables para control de archivos cifrados
define vsnomarchivocifrado varchar (50);
define vsnomarchivosincifrar varchar (50);
define vsnomarchivosincifrar1 varchar (50);
define vsnomarchivooriginal varchar(50);
define vsnomarchivocodificado varchar(50);
define vilongitudarchivo integer;
define vilonguitudnueva integer;

-- Variables para validaciones a detalle del archivo 

define vstiposumario  char(80);
define viiniciocadena_reg integer;
define viiniciocadena_monto integer;
define vsregistros char(1650);
define vsnumregistros	char(13);
define vinumregistros	integer;
define vsflagnumerico_reg char(1);
define vitotalregistros integer;
define vsactividad char(60);

begin

	on exception set visqlerr
	
		set lock mode to wait 3;
		set isolation to dirty read;
		--limpia la tabla
		delete from bditransfer:"informix".tf_carga_transfer;
		-- Se le pone elemento 0 por ser el primer proceso
		let vsactividad = '';
		let vsactividad = 'Error en carga de archivo' || psnomarchivo || ' en proceso ' || trim(vsmensaje_respuesta);
		execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( 0 , vsActividad, 'systrans') into vscodret;
		let vscodret = '00101';
		return 	vsCodRet,
				('[' || vscodret ||  '] Error no controlado (' || visqlerr || '). archivo (' || psnomarchivo || ') ' || trim(vsmensaje_respuesta) ),
				0, 
				1;
	end exception;

--set debug file to "/informix/HomeInformix/rrm/sp_cargaarchivos_transfer.out";
--trace on;

let vssql = '' ;

let visqlerr = 0;    
let vscodret = '00000';
let vsmensaje_respuesta = '';


let vsnomarchivocifrado = '';
let vsnomarchivosincifrar = '';
let vsnomarchivosincifrar1 = '';
let vsnomarchivooriginal  = '';
let vsnomarchivocodificado = '';
let vilongitudarchivo  = 0;
let vilonguitudnueva = 0;

let vstiposumario = '';
let viiniciocadena_reg = 0;
let viiniciocadena_monto = 0;
let vsregistros = '';
let vsnumregistros	= '';
let vinumregistros	= 0;
let vsflagnumerico_reg = '';
let vitotalregistros = 0;

	
	--LIMPIA LA TABLA tabla de carga general para inicializar el proceso
	let vsmensaje_respuesta = 'Limpiar tabla de trabajo.';
	set lock mode to wait 3;
	delete from bditransfer:"informix".tf_carga_transfer;
	
	if (pitipolayout = 9) then  -- Para cargar archivos a tabla temporal de ajustes de saldos SAB
		-- Limpiar tabla de trabajo temporal
		set lock mode to wait 3;
		delete from bditransfer:"informix".tf_sva_transaction_temp;
		
		if psseguridad = 'V' then
			--Creando comando de desencriptacion
			--pgp --decrypt CONTROL_250314_01.txt.pgp --passphrase "inventario" --output CONTROL_250314_01_1.txt --input-cleanup remove
			let vssql = ''; 
			let vssql = 'echo "pgp --decrypt '|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo)|| '--passphrase "inventario"  --input-cleanup remove" > '|| TRIM(psRuta_Procesos) ||'/desencripta.sh';
			system vssql;
			
			-- Da permisos a shell para su ejecucion
			let vssql = '';
			let vssql = 'chmod 777 ' || TRIM(psRuta_Procesos) ||'desencripta.sh';
			system vssql;
			
			--Ejecuta el shell para descifrar el archivo encriptado
			LET vsMensaje_Respuesta = 'Ejecutan shell para descifrar archivo';
			let vssql =  TRIM(psRuta_Procesos) ||'./ desencripta.sh';
			system vssql;
			
			--Obteniendo el nombre del archivo que va ser cargado
			let vsmensaje_respuesta = 'generar nombre de archivo descrifrado';
			let vsnomarchivocifrado = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivocifrado);
			let vilonguitudnueva = vilongitudarchivo - 8;
			let vsnomarchivosincifrar = substr(psnomarchivo,1,vilonguitudnueva);
			let vsnomarchivosincifrar1 = vsnomarchivosincifrar || '_1.CSV';
			let vsnomarchivosincifrar = vsnomarchivosincifrar || '.CSV';
			
			-- Asignando permisos a archivos ya descifrado
			let vssql = '';
			let vssql = 'chmod 777 '|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar);
			system vssql;
			
			-- Eliminando primera linea de archivo 
			let vssql = '';
			let vssql = 'sed -e ''1d'''|| ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(psnomarchivo) || '>'|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar1);
			system vssql;
			
			-- Se ejecuta para la carga del archivo desencriptado
			let vssql = '';
			let vssql = 'echo "LOAD FROM '''|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar1) || "'" || " DELIMITER " || "','"||' INSERT INTO BdiTransfer:"informix".tf_sva_transaction_temp" > ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			system vssql;

			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			let vsmensaje_respuesta = 'Ejecutar carga de archivo.';
			let vssql = 'dbaccess bditransfer ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
			
			--Elimando archivo sin encabezado
			LET vsMensaje_Respuesta = 'Elimino archivo de sin encabezado.';
			let vssql = '';
			LET vsSQL = 'rm -f ' || TRIM(psRuta_Procesos) || '/' || TRIM(vsnomarchivosincifrar1);
			SYSTEM vsSQL;
			
			let vsCodRet = '00000'; 
			let vsmensaje_respuesta = 'Archivo cargado a tabla temporal y eliminado archivo sin encabezado';
		
		else
			
			--Obteniendo el nombre del archivo que va ser cargado
			let vsmensaje_respuesta = 'generar nombre de archivo descrifrado';
			let vsnomarchivocifrado = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivocifrado);
			let vilonguitudnueva = vilongitudarchivo - 4;
			let vsnomarchivosincifrar = substr(psnomarchivo,1,vilonguitudnueva);
			let vsnomarchivosincifrar1 = vsnomarchivosincifrar || '_1.CSV';
			let vsnomarchivosincifrar = vsnomarchivosincifrar || '.CSV';
			
			/*-- ############   PROCESO DE CODIFICACION DE ARCHIVO  ##################
			-- Nombre de archivo original y codificado 
			let vsnomarchivooriginal = psnomarchivo;
			let vsnomarchivocodificado = vsnomarchivosincifrar1;
		
		
			let vsmensaje_respuesta = 'Codificando archivo';
			-- Se codifica el archivo al formato correcto para su adecuada integración 
			let vssql = '';
			let vssql = '/usr/bin/iconv -s -c -f UTF-8 -t ISO8859-1 ' || TRIM(psRuta_Repositorio) || '/' ||TRIM(psnomarchivo) || ' >> ' || TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado);
			system vssql;
			let vssql = '';
			--/usr/bin/iconv -c -f UTF-8 -t ISO8859-1 /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT >> /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT
			
			let vsmensaje_respuesta = 'Borrando archivo original';
			-- Se borra el archivo original con la codificacion incorrecta 
			let vssql = '';
			let vssql = '/usr/bin/rm' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(psnomarchivo);
			system vssql; 
			--/usr/bin/rm /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			
			let vsmensaje_respuesta = 'Se renombra archivo codificado';
			-- Se renombre el archivo codificado con el nombre del archivo original 
			let vssql = '';
			let vssql = '/usr/bin/mv' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado) || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(psnomarchivo);
			system vssql;
			--/usr/bin/mv /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			-- ##################################################################################*/
			
			let vsmensaje_respuesta = 'Eliminando Header de archivo ';
			-- Eliminando primera linea de archivo 
			let vssql = '';
            let vssql = 'sed -e ''1d'''|| ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(psnomarchivo) || '>'|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar1);
			system vssql;
			
			let vsmensaje_respuesta = 'Generar comando de carga.';
			--CREA ARCHIVO DE INSTRUCCION DE CARGA
			let vssql = 'echo "load from '''|| trim(psruta_repositorio) || '/' || trim(vsnomarchivosincifrar1) || "' " || " DELIMITER " || "','"|| ' insert into BdiTransfer:"informix".tf_sva_transaction_temp" > ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
			
			let vsmensaje_respuesta = 'Ejecutar carga de archivo.';
			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			let vssql = 'dbaccess bditransfer ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
			
			--Elimando archivo sin encabezado
			let vsMensaje_Respuesta = 'Elimino archivo de sin encabezado.';
			let vssql = '';
			let vssql = 'rm -f ' || TRIM(psRuta_Procesos) || '/' || TRIM(vsnomarchivosincifrar1);
			system vssql;
			
			let vsCodRet = '00000';
			let vsmensaje_respuesta = 'Archivo cargado a tabla temporal y eliminado archivo sin encabezado';
			
		end if;
		
	elif  (pitipolayout = 17) then  -- Para cargar archivos con delimitadores Encabezados estados de cuenta
	
		-- Limpiar tabla de trabajo temporal
		set lock mode to wait 3;
		delete from bditransfer:"informix".tf_resumen_edocta_temp;

		if psseguridad = 'V' then
			--Creando comando de desencriptacion
			--pgp --decrypt CONTROL_250314_01.txt.pgp --passphrase "inventario" --output CONTROL_250314_01_1.txt --input-cleanup remove
			let vssql = ''; 
			let vssql = 'echo "pgp --decrypt '|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo)|| '--passphrase "inventario"  --input-cleanup remove" > '|| TRIM(psRuta_Procesos) ||'/desencripta.sh';
			system vssql;
			
			-- Da permisos a shell para su ejecucion
			let vssql = '';
			let vssql = 'chmod 777 ' || TRIM(psRuta_Procesos) ||'desencripta.sh';
			system vssql;
			
			--Ejecuta el shell para descifrar el archivo encriptado
			LET vsMensaje_Respuesta = 'Ejecutan shell para descifrar archivo';
			let vssql =  TRIM(psRuta_Procesos) ||'./ desencripta.sh';
			system vssql;
			
			--Obteniendo el nombre del archivo que va ser cargado
			let vsmensaje_respuesta = 'generar nombre de archivo descrifrado';
			let vsnomarchivocifrado = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivocifrado);
			let vilonguitudnueva = vilongitudarchivo - 4;
			let vsnomarchivosincifrar = substr(psnomarchivo,1,vilonguitudnueva);
			
			-- Asignando permisos a archivos ya descifrado
			let vssql = '';
			let vssql = 'chmod 777 '|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar);
			system vssql;
			
			-- Se ejecuta para la carga del archivo desencriptado
			let vssql = '';
			let vssql = 'echo "LOAD FROM '''|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar) || "' DELIMITER " || "'~'"||' INSERT INTO BdiTransfer:"informix".tf_resumen_edocta_temp" > ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			system vssql;

			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			LET vsMensaje_Respuesta = 'EJECUTAR CARGA DE ARCHIVO.';
			LET vsSQL = 'dbaccess bditransfer ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
			
			let vsCodRet = '00000';
			let vsmensaje_respuesta = 'Archivo cargado a tabla temporal ';

		
		else
			/*
			-- ############   PROCESO DE CODIFICACION DE ARCHIVO  ##################
			-- Nombre de archivo original y codificado 
			let vsnomarchivooriginal = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivooriginal);
			let vilonguitudnueva = vilongitudarchivo - 4;   --resumenmpsyyyymmdd_CSSSS.txt
			let vsnomarchivocodificado = substr(psnomarchivo,1,vilonguitudnueva);
			let vsnomarchivocodificado = vsnomarchivocodificado||'_1.txt';
			
		
			let vsmensaje_respuesta = 'Codificando archivo';
			-- Se codifica el archivo al formato correcto para su adecuada integración 
			let vssql = '';
			let vssql = '/usr/bin/iconv -s -c -f UTF-8 -t ISO8859-1 ' || TRIM(psRuta_Repositorio) || '/' ||TRIM(vsnomarchivooriginal) || ' >> ' || TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado);
			system vssql;
			--/usr/bin/iconv -c -f UTF-8 -t ISO8859-1 /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT >> /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT
			
			let vsmensaje_respuesta = 'Borrando archivo original';
			-- Se borra el archivo original con la codificacion incorrecta 
			let vssql = '';
			let vssql = '/usr/bin/rm' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivooriginal);
			system vssql; 
			--/usr/bin/rm /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			
			let vsmensaje_respuesta = 'Se renombra archivo codificado';
			-- Se renombre el archivo codificado con el nombre del archivo original 
			let vssql = '';
			let vssql = '/usr/bin/mv' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado) || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivooriginal);
			system vssql;
			--/usr/bin/mv /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			-- ##################################################################################
			*/
		
			let vsmensaje_respuesta = 'Generar comando de carga.';
			--CREA ARCHIVO DE INSTRUCCION DE CARGA
			let vssql = 'echo "load from '''|| trim(psruta_repositorio) || '/' || trim(psnomarchivo) || "' " || " DELIMITER " || "'~'"|| ' insert into BdiTransfer:"informix".tf_resumen_edocta_temp" > ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
			
			let vsmensaje_respuesta = 'Ejecutar carga de archivo.';
			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			let vssql = 'dbaccess bditransfer ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
			
			let vsCodRet = '00000';
			let vsmensaje_respuesta = 'Archivo cargado a tabla temporal ';

		end if;
	elif  (pitipolayout = 18) then  -- Para cargar archivos con delimitadores  DEC Detalle estados de cuenta 
		-- Limpiar tabla de trabajo temporal
		set lock mode to wait 3;
		delete from bditransfer:"informix".tf_detalle_edocta_temp;
	

		if psseguridad = 'V' then
			--Creando comando de desencriptacion
			--pgp --decrypt CONTROL_250314_01.txt.pgp --passphrase "inventario" --output CONTROL_250314_01_1.txt --input-cleanup remove
			let vssql = ''; 
			let vssql = 'echo "pgp --decrypt '|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo)|| '--passphrase "inventario"  --input-cleanup remove" > '|| TRIM(psRuta_Procesos) ||'/desencripta.sh';
			system vssql;
			
			-- Da permisos a shell para su ejecucion
			let vssql = '';
			let vssql = 'chmod 777 ' || TRIM(psRuta_Procesos) ||'desencripta.sh';
			system vssql;
			
			--Ejecuta el shell para descifrar el archivo encriptado
			LET vsMensaje_Respuesta = 'Ejecutan shell para descifrar archivo';
			let vssql =  TRIM(psRuta_Procesos) ||'./ desencripta.sh';
			system vssql;
			
			--Obteniendo el nombre del archivo que va ser cargado
			let vsmensaje_respuesta = 'generar nombre de archivo descrifrado';
			let vsnomarchivocifrado = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivocifrado);
			let vilonguitudnueva = vilongitudarchivo - 4;
			let vsnomarchivosincifrar = substr(psnomarchivo,1,vilonguitudnueva);
			
			-- Asignando permisos a archivos ya descifrado
			let vssql = '';
			let vssql = 'chmod 777 '|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar);
			system vssql;
		
			-- Se ejecuta para la carga del archivo desencriptado
			let vssql = '';
			let vssql = 'echo "LOAD FROM '''|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar) || "'" || " DELIMITER " || "'~'"||' INSERT INTO BdiTransfer:"informix".tf_detalle_edocta_temp" > ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			system vssql;

			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			LET vsMensaje_Respuesta = 'EJECUTAR CARGA DE ARCHIVO.';
			LET vsSQL = 'dbaccess bditransfer ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
			
			let vsCodRet = '00000';
			let vsmensaje_respuesta = 'Archivo cargado a tabla temporal ';

		else
			/*
			-- ############   PROCESO DE CODIFICACION DE ARCHIVO  ##################
			-- Nombre de archivo original y codificado 
			let vsnomarchivooriginal = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivooriginal);
			let vilonguitudnueva = vilongitudarchivo - 4;   --movimientosmpsyyyymmdd_CSSSS.txt
			let vsnomarchivocodificado = substr(psnomarchivo,1,vilonguitudnueva);
			let vsnomarchivocodificado = vsnomarchivocodificado||'_1.txt';
			
			let vsmensaje_respuesta = 'Codificando archivo';
			-- Se codifica el archivo al formato correcto para su adecuada integración 
			let vssql = '';
			let vssql = '/usr/bin/iconv -s -c -f UTF-8 -t ISO8859-1 ' || TRIM(psRuta_Repositorio) || '/' ||TRIM(vsnomarchivooriginal) || ' >> ' || TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado);
			system vssql;
			--/usr/bin/iconv -c -f UTF-8 -t ISO8859-1 /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT >> /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT
			
			let vsmensaje_respuesta = 'Borrando archivo original';
			-- Se borra el archivo original con la codificacion incorrecta 
			let vssql = '';
			let vssql = '/usr/bin/rm' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivooriginal);
			system vssql; 
			--/usr/bin/rm /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			
			let vsmensaje_respuesta = 'Se renombra archivo codificado';
			-- Se renombre el archivo codificado con el nombre del archivo original 
			let vssql = '';
			let vssql = '/usr/bin/mv' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado) || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivooriginal);
			system vssql;
			--/usr/bin/mv /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			-- ##################################################################################
			*/
			let vsmensaje_respuesta = 'Generar comando de carga.';
			--CREA ARCHIVO DE INSTRUCCION DE CARGA
			let vssql = 'echo "load from '''|| trim(psruta_repositorio) || '/' || trim(psnomarchivo) || "' " || " DELIMITER " || "'~'"|| ' insert into BdiTransfer:"informix".tf_detalle_edocta_temp" > ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
			
			let vsmensaje_respuesta = 'Ejecutar carga de archivo.';
			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			let vssql = 'dbaccess bditransfer ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;

			let vsCodRet = '00000';
			let vsmensaje_respuesta = 'Archivo cargado a tabla temporal ';
		end if;

			
	elif  (pitipolayout = 19) then  -- Para cargar archivos con delimitadores  DEC Detalle estados de cuenta 
		-- Limpiar tabla de trabajo temporal
		set lock mode to wait 3;
		delete from bditransfer:"informix".tf_control_edocta_temp;
		
		if psseguridad = 'V' then
			--Creando comando de desencriptacion
			--pgp --decrypt CONTROL_250314_01.txt.pgp --passphrase "inventario" --output CONTROL_250314_01_1.txt --input-cleanup remove
			let vssql = ''; 
			let vssql = 'echo "pgp --decrypt '|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo)|| '--passphrase "inventario"  --input-cleanup remove" > '|| TRIM(psRuta_Procesos) ||'/desencripta.sh';
			system vssql;
			
			-- Da permisos a shell para su ejecucion
			let vssql = '';
			let vssql = 'chmod 777 ' || TRIM(psRuta_Procesos) ||'desencripta.sh';
			system vssql;
			
			--Ejecuta el shell para descifrar el archivo encriptado
			LET vsMensaje_Respuesta = 'Ejecutan shell para descifrar archivo';
			let vssql =  TRIM(psRuta_Procesos) ||'./ desencripta.sh';
			system vssql;
			
			--Obteniendo el nombre del archivo que va ser cargado
			let vsmensaje_respuesta = 'generar nombre de archivo descrifrado';
			let vsnomarchivocifrado = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivocifrado);
			let vilonguitudnueva = vilongitudarchivo - 4;
			let vsnomarchivosincifrar = substr(psnomarchivo,1,vilonguitudnueva);
			
			-- Asignando permisos a archivos ya descifrado
			let vssql = '';
			let vssql = 'chmod 777 '|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar);
			system vssql;
			
			-- Se ejecuta para la carga del archivo desencriptado
			let vssql = '';
			let vssql = 'echo "LOAD FROM '''|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar) || "'" || " DELIMITER " || "'~'"||' INSERT INTO BdiTransfer:"informix".tf_control_edocta_temp" > ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			system vssql;

			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			LET vsMensaje_Respuesta = 'EJECUTAR CARGA DE ARCHIVO.';
			LET vsSQL = 'dbaccess bditransfer ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
			
			let vsCodRet = '00000';
			let vsmensaje_respuesta = 'Archivo cargado a tabla temporal ';

		else
			/*
			-- ############   PROCESO DE CODIFICACION DE ARCHIVO  ##################  
			-- Nombre de archivo original y codificado 
			let vsnomarchivooriginal = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivooriginal);
			let vilonguitudnueva = vilongitudarchivo - 4;   --mpscontrolyyyymmdd_CSSSS.txt
			let vsnomarchivocodificado = substr(psnomarchivo,1,vilonguitudnueva);
			let vsnomarchivocodificado = vsnomarchivocodificado||'_1.txt';
			
			let vsmensaje_respuesta = 'Codificando archivo';
			-- Se codifica el archivo al formato correcto para su adecuada integración 
			let vssql = '';
			let vssql = '/usr/bin/iconv -s -c -f UTF-8 -t ISO8859-1 ' || TRIM(psRuta_Repositorio) || '/' ||TRIM(vsnomarchivooriginal) || ' >> ' || TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado);
			system vssql;
			--/usr/bin/iconv -c -f UTF-8 -t ISO8859-1 /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT >> /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT
			
			let vsmensaje_respuesta = 'Borrando archivo original';
			-- Se borra el archivo original con la codificacion incorrecta 
			let vssql = '';
			let vssql = '/usr/bin/rm' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivooriginal);
			system vssql; 
			--/usr/bin/rm /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			
			let vsmensaje_respuesta = 'Se renombra archivo codificado';
			-- Se renombre el archivo codificado con el nombre del archivo original 
			let vssql = '';
			let vssql = '/usr/bin/mv' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado) || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivooriginal);
			system vssql;
			--/usr/bin/mv /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			-- ##################################################################################
			*/
		
			let vsmensaje_respuesta = 'Generar comando de carga.';
			--CREA ARCHIVO DE INSTRUCCION DE CARGA
			let vssql = 'echo "load from '''|| trim(psruta_repositorio) || '/' || trim(psnomarchivo) || "' " || " DELIMITER " || "'~'"|| ' insert into BdiTransfer:"informix".tf_control_edocta_temp" > ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
			
			let vsmensaje_respuesta = 'Ejecutar carga de archivo.';
			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			let vssql = 'dbaccess bditransfer ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
			
			let vsCodRet = '00000';
			let vsmensaje_respuesta = 'Archivo cargado a tabla temporal ';

		end if;
	else
		if psseguridad = 'V' then
			--Creando comando de desencriptacion
			--pgp --decrypt CONTROL_250314_01.txt.pgp --passphrase "inventario" --output CONTROL_250314_01_1.txt --input-cleanup remove
			let vssql = ''; 
			let vssql = 'echo "pgp --decrypt '|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo)|| '--passphrase "inventario"  --input-cleanup remove" > '|| TRIM(psRuta_Procesos) ||'/desencripta.sh';
			system vssql;
			
			-- Da permisos a shell para su ejecucion
			let vssql = '';
			let vssql = 'chmod 777 ' || TRIM(psRuta_Procesos) ||'desencripta.sh';
			system vssql;
			
			--Ejecuta el shell para descifrar el archivo encriptado
			LET vsMensaje_Respuesta = 'Ejecutan shell para descifrar archivo';
			let vssql =  TRIM(psRuta_Procesos) ||'./ desencripta.sh';
			system vssql;
			
			--Obteniendo el nombre del archivo que va ser cargado
			let vsmensaje_respuesta = 'generar nombre de archivo descrifrado';
			let vsnomarchivocifrado = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivocifrado);
			let vilonguitudnueva = vilongitudarchivo - 4;
			let vsnomarchivosincifrar = substr(psnomarchivo,1,vilonguitudnueva);
			
			-- Asignando permisos a archivos ya descifrado
			let vssql = '';
			let vssql = 'chmod 777 '|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar);
			system vssql;
			
			-- Se ejecuta para la carga del archivo desencriptado
			let vssql = '';
			let vssql = 'echo "LOAD FROM '''|| TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivosincifrar) || "'" || ' INSERT INTO Bditransfer:"informix".tf_carga_transfer" > ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			system vssql;

			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			LET vsMensaje_Respuesta = 'EJECUTAR CARGA DE ARCHIVO.';
			LET vsSQL = 'dbaccess bditransfer ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
		
		else

			-- ############   PROCESO DE CODIFICACION DE ARCHIVO  ##################
			-- Nombre de archivo original y codificado 
		/*	let vsnomarchivooriginal = psnomarchivo;
			let vilongitudarchivo = length(vsnomarchivooriginal);
			let vilonguitudnueva = vilongitudarchivo - 6;   --???????????????_C.txt
			let vsnomarchivocodificado = substr(psnomarchivo,1,vilonguitudnueva);
			let vsnomarchivocodificado = vsnomarchivocodificado||'_1_1.txt';
			
			let vsmensaje_respuesta = 'Codificando archivo';
			-- Se codifica el archivo al formato correcto para su adecuada integración 
			let vssql = '';
			let vssql = '/usr/bin/iconv -s -c -f UTF-8 -t ISO8859-1 ' || TRIM(psRuta_Repositorio) || '/' ||TRIM(vsnomarchivooriginal) || ' >> ' || TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado);
			system vssql;
			--/usr/bin/iconv -c -f UTF-8 -t ISO8859-1 /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT >> /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT
			
			let vsmensaje_respuesta = 'Borrando archivo original';
			-- Se borra el archivo original con la codificacion incorrecta 
			let vssql = '';
			let vssql = '/usr/bin/rm' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivooriginal);
			system vssql; 
			--/usr/bin/rm /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			
			let vsmensaje_respuesta = 'Se renombra archivo codificado';
			-- Se renombre el archivo codificado con el nombre del archivo original 
			let vssql = '';
			let vssql = '/usr/bin/mv' || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivocodificado) || ' ' ||TRIM(psRuta_Repositorio) || '/' || TRIM(vsnomarchivooriginal);
			system vssql;
			--/usr/bin/mv /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8_1.TXT /home/systrans/outgoing/BCP_NEWREGISTRATIONS_25022015_8.TXT
			-- ##################################################################################
*/
			let vsmensaje_respuesta = 'Generar comando de carga.';
			--CREA ARCHIVO DE INSTRUCCION DE CARGA
			let vssql = 'echo "load from '''|| trim(psruta_repositorio) || '/' || trim(psnomarchivo) || "'" || ' insert into Bditransfer:"informix".tf_carga_transfer" > ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
			
			let vsmensaje_respuesta = 'Ejecutar carga de archivo.';
			--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			let vssql = 'dbaccess bditransfer ' || trim(psruta_procesos) ||  '/load_archivo.sql';
			system vssql;
		end if;
	end if;
	-- Asignado codigo de retorno a archivos los cuales se pasaron a tablas temporales 
	if pitipolayout in (1,2,4,5,6,7,10,11,12,3,8,15,16,20,21) then
		if (not exists (select registro from bditransfer:"informix".tf_carga_transfer  where registro matches ((	case 	when pitipolayout in (1,2,4,5,6,7,10,11,12,20) /*CBA, ALT, TEC, TME, TMF, TIE, ACT, BCT, SCN,TAD*/ then '0*' 
																															when pitipolayout in (3) /*TTE*/ then 'HDRBC*' 
																															when pitipolayout in (8) /*TAT */then '0000137 0*'
																															when pitipolayout in (21) /*TIB */then '1*'  --- OPM-SPEI
																															when pitipolayout in (15,16) /*RAT,RCT*/ then '        3*'
																															--when pitipolayout in (13,14) /* MUS, MSM*/ then '0* ' Se derroga de proceso acuerdo con Nancy respaldo correo
																															--when pitipolayout in (15,16,17,18,19) /* RAT,RCT, EEC,DEC, REC*/ then '*' Se pasa a carga directa
																													else 
																														'*Registro detallado de transacciones por' 
																													end) || '*'))) then --valida que el archivo contenga el encabezado correspondiente
			let vstiposumario = 'Error header';
			let viiniciocadena_reg = -1;
			
		elif (pitipolayout in (7)) then
			let vsTipoSumario = '0 ';
			let viInicioCadena_Reg = 2;
			
		elif (pitipolayout = 21) then  --- OPM-SPEI
			let vsTipoSumario = '0 ';
			let viInicioCadena_Reg = 12; 
			
		elif (piTipoLayOut in (1,2,4,5,6,10,11,12,20)) THEN -- CBA, ALT, TEC, TME, TMF, TIE, ACT, BCT, SCN
			set lock mode to wait 3;
			--borra los registros de encabezado
			delete from bditransfer:"informix".tf_carga_transfer where (registro matches '0*');
			
			LET vsTipoSumario = '9 ';
			LET viInicioCadena_Reg = 2;
			--,2, 13 columanposiciones trailer
		elif (pitipolayout = 3) then -- TTE
			set lock mode to wait 3;
			--borra los registros de encabezado
			delete from bditransfer:"informix".tf_carga_transfer 
				where registro matches 'HDRBC*' ;
			
			LET vsTipoSumario = 'TRLBC ';
			LET viInicioCadena_Reg = 6;
		
		elif (pitipolayout = 8) then -- TAT
			set lock mode to wait 3;
			--borra los registros de encabezado
			delete from bditransfer:"informix".tf_carga_transfer 
				where registro matches '0000137 0*' ;
			
			LET vsTipoSumario = '        7';
			LET viInicioCadena_Reg = 10;
		
		elif (pitipolayout in (15,16) ) then 
			let vsTipoSumario = 'Sin encabezado';
			let viInicioCadena_Reg = 0;
		else -- ERROR
			let vsTipoSumario = 'Error trailer';
			let viInicioCadena_Reg = 0;
		end if;
	end if;	
	-- Validar encabezado y proceso de trailer
	
	if (trim(vstiposumario) = 'Error header') then --error. no contiene el encabezado correspondiente
		let vscodret = '00100';
		let vsmensaje_respuesta = '[' || vscodret ||  ']el archivo (' || psnomarchivo || ') no contiene el encabezado correspondiente al tipo layout: ' || pitipolayout || '.';
	elif (trim(vstiposumario) = 'Error trailer') then --error. no corresponde a ningun layout
		let vscodret = '00101';
		let vsmensaje_respuesta = '[' || vscodret ||  ']el archivo (' || psnomarchivo || ') no corresponde a ningun tipo de layout registrado.';
	else
		
		if 	(piTipoLayOut in (1,2,4,5,6,10,11,12,20)) then
			set isolation to dirty read;
			select first 1 trim(registro), trim(substr(registro,viInicioCadena_Reg,13)) into vsregistros, vsnumregistros from bditransfer:"informix".tf_carga_transfer
				where registro matches '9* ';
			let vinumregistros = cast(vsnumregistros as integer);
		elif (piTipoLayOut in (7)) then
			set isolation to dirty read;
			select first 1 trim(registro), trim(substr(registro,viInicioCadena_Reg,6)) into vsregistros, vsnumregistros from bditransfer:"informix".tf_carga_transfer
				where registro matches '0*';
			let vinumregistros = cast(vsnumregistros as integer);
		elif (pitipolayout = 21) then  --- OPM-SPEI 
			set isolation to dirty read;
			select first 1 trim(registro), trim(substr(registro,viInicioCadena_Reg,10)) into vsregistros, vsnumregistros from bditransfer:"informix".tf_carga_transfer
				where registro matches '1*';
			let vinumregistros = cast(vsnumregistros as integer);			
		elif (pitipolayout = 3) then 
			set isolation to dirty read;   -- Se modifico a 10  de 6 para tomar total de forma correcta
			select first 1 trim(registro), trim(substr(registro,viInicioCadena_Reg,10)) into vsregistros, vsnumregistros from bditransfer:"informix".tf_carga_transfer
				where registro matches 'TRLBC*';
			let vinumregistros = cast(vsnumregistros as integer);
		elif (pitipolayout = 8) then 
			set isolation to dirty read;
			select first 1 registro, trim(substr(registro,viInicioCadena_Reg,6)) into vsregistros, vsnumregistros from bditransfer:"informix".tf_carga_transfer
				where registro matches '        7*';
			let vinumregistros = cast(vsnumregistros as integer);
		end if;
	end if;
	
  
	if (pitipolayout in (1,2,3,4,5,6,7,8,10,11,12,20,21)) then  -- 21 OPM-SPEI
		--valida que contenga solo numeros total registros
		execute procedure bditransfer:"informix".sp_transfer_esnumerico( vsnumregistros ) into vsflagnumerico_reg;
	
		if (vsflagnumerico_reg = 'F') then --error total registros no es numerico
			let vscodret = '00103';
			let vsmensaje_respuesta = '[' || vscodret ||  ']El archivo (' || psnomarchivo || ') contiene un total registros no numerico.';
		else
			set lock mode to wait 3;
			--borra el registro de sumario
			delete from bditransfer:"informix".tf_carga_transfer where registro = vsregistros;
			delete from bditransfer:"informix".tf_carga_transfer where (registro matches vstiposumario||'*');
			let vsmensaje_respuesta = 'Calcular total registros en el archivo.';
			set lock mode to wait 3;
			set isolation to dirty read;
			--Obtiene el numero de registros del archivo
			select count(registro) into vitotalregistros from bditransfer:"informix".tf_carga_transfer;
			let vsmensaje_respuesta = 'Validar discrepancias en el total de registros sumario/trailer vs archivo.';
			if ((vitotalregistros) <> (vinumregistros) ) then --valida lo reportado en el sumario con el contenido el archivo
				let vscodret = '00105'; --cantidades distintas de registros
				let vsmensaje_respuesta = '[' || vscodret ||  ']El archivo (' || trim(psnomarchivo) || ') contiene discrepancias en el total de registros reportados '|| vitotalregistros ||' y los contenidos '|| vinumregistros ||' en el archivo.';
				let vitotalregistros = 0;
			End if;
		end if;
	elif ( pitipolayout in (9)) then 
		set lock mode to wait 3;
		set isolation to dirty read;
		--Obtiene el numero de registros del archivo
		select count(*) into vitotalregistros from bditransfer:"informix".tf_sva_transaction_temp;
		let vsCodRet = '00000';
		let vsMensaje_Respuesta = 'Archivo con delimitador';
	elif ( pitipolayout in (17)) then 
		set lock mode to wait 3;
		set isolation to dirty read;
		--Obtiene el numero de registros del archivo
		select count(*) into vitotalregistros from bditransfer:"informix".tf_resumen_edocta_temp;
		let vsCodRet = '00000';
		let vsMensaje_Respuesta = 'Archivos con delimitador';
	elif ( pitipolayout in (18)) then 
		set lock mode to wait 3;
		set isolation to dirty read;
		--Obtiene el numero de registros del archivo
		select count(*) into vitotalregistros from bditransfer:"informix".tf_detalle_edocta_temp;
		let vsCodRet = '00000';
		let vsMensaje_Respuesta = 'Archivos con delimitador';
	elif ( pitipolayout in (19)) then 
		set lock mode to wait 3;
		set isolation to dirty read;
		--Obtiene el numero de registros del archivo
		select count(*) into vitotalregistros from bditransfer:"informix".tf_control_edocta_temp;
		let vsCodRet = '00000';
		let vsMensaje_Respuesta = 'Archivos con delimitador';
	else 
		set lock mode to wait 3;
		set isolation to dirty read;
		--Obtiene el numero de registros del archivo
		select count(registro) into vitotalregistros from bditransfer:"informix".tf_carga_transfer;
		let vsCodRet = '00000';
		let vsMensaje_Respuesta = 'Archivos sin encabezado o trailer para validar correspondencia con detalle';
	end if;
	
	
	
	RETURN 
			vsCodRet, 
			DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), 
			NVL(viTotalRegistros, 0), 
			 1;
	
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Reséndiz Martínez',
'Proyecto: Integracion de Archivos Transfer',
'Solicito: Jose Luis Puebla',
'Descripcion: Carga un archivo de transfer a la tabla de trabajo (Td_Carga_transfer) para ser procesado con delimitadores o sin delimitadores a tablas temporales',
'Fecha: 2014/07/17',
'Version: 20140717.1400',
'BD: BdiTransfer',
'',
'MODIFICO: Ricardo Reséndiz Martínez',
'Proyecto: Integracion de Archivos Transfer',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega proceso para la correcta codificación de los archivos y bitacoreo de proceso de carga',
'Fecha: 2015/03/03',
'Version: 20150303.1630',
'BD: BdiTransfer',
'',
'Modifico: L.I.A. Ricardo Reséndiz Martinez',
'Proyecto: RQM 10 650 Folio operaciones administrativas',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifica proceso para validacion de numero de registros y carga en tabla de paso de transacciones administrativas',
'Fecha: 2015/08/26',
'Version: 20150824.1500',
'BD: Bditransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 10 721-2 - Transfer OPM SPEI',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Se integra en el ciclo el layout numero 21 que es el asignado para la Transacciones OPM-SPEI',
'Fecha: 2016/08/18',
'Version: 20160818.1800',
'BD: Bditransfer';

create procedure "informix".sp_transfer_integracion (
													psCve_Usuario varchar(10), 
													piHorario integer
													)
returning 
					varchar (5) as codret, 
					varchar (150) as mensaje_respuesta;

-- ### Definición de Variables de errorres y control 

define visqlerr 				integer;			--Descripcion interna del error
define vscodret 				varchar(5);			--Numero del error
define vscodret2 				varchar(5);			--Segunda para el numero del error
define vsmensaje_respuesta 		varchar (250);		--Descripcion del error que se presente
define vielemento 				integer;			--Numero de proceso para control interno del proceso
define vdfecha_hoy_integral 	date;				--Fecha de Integral
define vsdescripcion			char(100);			--Para almacenar descriptivos

-- Control de ciclos 
define vicontadorregistros 		integer;			--Contador para los ciclos
define vsflagentransaccion 		char(1);			--Bandera de transaccion
define vsflag_ciclo_buscararch	char(1);			--Bandera de ciclo para la busqueda de los archivos
define vsflag_archpendiente 	char(1);			--Control de estatus del archivo
define vsflag_ciclo_busrcarreg 	varchar (1);		--Control de registros en archivos 

-- Control general de Archivos

define vitot_registros 			integer;			-- Control de numero de registros
define vmtot_monto 				money;				-- Control de monto de las transacciones contenidas en los archivos

--	Datos de los archivos a ser Integrados 
define vsnombrearchivo			char(50);			-- Nombre del archivo que se va ha ser integrado
define vsarchivo_origen 		char(3);			-- Abreviatura del nombre del archivo 
define vdtfecha_archivo 		date;				-- Pone la fecha del archivo
define vscarga					char(1);			-- Bandera que indica el estatus del archivo
define vsprefijo_archivo		char(30);			-- Almacane el segmento del nombre antes de la fecha
define vsconciliacion_inter		char(1);			-- Bandera que indica que el archivo debe pasar por proceso 
define vsconciliacion_sif		char (1);			-- Bandera que indica que el archivo debe ser mandado a aplicar a central
define vsconciliacion_admin		char (1);			-- Bandera que indica que habra de realizarse un proceso administrativo 
define vsrep_aix				char (90);			-- Almacena directorio donde esta el archivo en el AIX
define vsrep_win				char (90);			-- Almacena ruta donde el archivo fue entregado en el Conect Direct  
define vitipo_layout			integer;			-- Almacena el numero de layout que le corresponde para identificar tabla correspondiente
define vsseguridad				char(1);			-- Variable para identificar si el archivo esta cifrado

begin
	on exception set visqlerr
		-- termina el ultimo bloque de transaccion pendiente.
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
			commit work;
			let vsflagentransaccion = 'F';
		end if;
		set lock mode to wait 3;
		set isolation to dirty read ;
		--libera la bandera de conciliacion en ejecucion
		update bditransfer:"informix".tf_param_transfer 
				set 	valor = 'F',
						fecha_modificacion = current
			where 
					codigo = '001' and 
					descripcion = 'proceso de integración' and 
					TRIM(Valor) = 'V';
		let vielemento = 0;	
		let vscodret = '00020';
		let vsmensaje_respuesta = 'error no controlado (' || visqlerr || '). ' || trim(vsmensaje_respuesta);
		execute procedure bditransfer:"informix".sp_transfer_guardabitacora (vielemento, '(' || vscodret || ') ' || vsmensaje_respuesta, pscve_usuario) into vscodret2;
		return vscodret, vsmensaje_respuesta;
	end exception;
	--en caso de transaccion abierta y tratar de abrir otra
	on exception in (-535)
		commit work; --termina la transaccion actual y continua
	end exception with resume;

	
	--set debug file to "/informix/HomeInformix/rrm/trace_integracion_transfer.out";
	--trace on;
	
	let	 visqlerr = 0; 
	let	 vscodret =	'00000';
	let	 vscodret2=	'00000';
	let	 vsmensaje_respuesta = '';
	let	 vielemento = 0; 
	let	 vdfecha_hoy_integral = '01-01/1900';

-- Control de ciclos 
	let vicontadorregistros = 0;
	let vsflagentransaccion = 'F';
	let vsflag_ciclo_buscararch = 'F';
	let vielemento = 0;
	let vsFlag_Ciclo_BusrcarReg = 'V';

	--	Datos de los archivos a ser Integrados 
	let vsnombrearchivo = '';
	let vsarchivo_origen = '';
	let vdtfecha_archivo = '01-01-1900';
	let vscarga	= 'F';
	let vsprefijo_archivo = '';
	let vsconciliacion_inter = '';
	let vsconciliacion_sif = '';
	let vsconciliacion_admin = '';
	let vsrep_aix = '';
	let vsrep_win = '';
	let vitipo_layout = 0;
	let vsseguridad = '';
	let vsdescripcion = '';

	--Valida fecha de integral
	set lock mode to wait 3;
	set isolation to dirty read;
	select limit 1 fecha_hoy into vdfecha_hoy_integral 
		from bdinteg:"informix".si_fechas
			where empresa = '001';
	--valida que el proceso de integracion no este en ejecución
	if 	(exists(select descripcion  from bditransfer:"informix".tf_param_transfer 
					where 	codigo = '001' and 
							trim(valor) = 'V')) then 
			let vscodret = '00001'; 
			let vsmensaje_respuesta = 'Proceso de Integracion en ejecución';
			
			return 
				vscodret,
				vsmensaje_respuesta;
	-- valida que el sistema de integra este a corde a la del servidor
	elif (vdfecha_hoy_integral < current::date) then 
			let vscodret = '00002'; 
			let vsmensaje_respuesta = 'Fecha integral es menor a la fecha del servidor central';
			
			return 
				vscodret,
				vsmensaje_respuesta;
	else
		-- Iniciamos proceso de integracion
		let vsmensaje_respuesta = 'Marcar integracion transfer en ejecución.';
		set lock mode to wait 3;
		update bditransfer:"informix".tf_param_transfer
			set 	valor = 'V',
					fecha_modificacion = (select dbinfo('utc_to_datetime', sh_curtime)::date from sysmaster:"informix".sysshmvals)
			where 
					codigo = '001' and 
					trim(valor) = 'F';
		
		let vsflag_ciclo_buscararch = 'V';
		let vsflagentransaccion = 'F';
		let vicontadorregistros = 0;
		--Inicia busqueda de archivos pendientes del dia de hoy
		while (vsflag_ciclo_buscararch = 'V')
			let vsflag_ciclo_buscararch = 'F'; --PERMANECE DESACTIVADO EL CICLO EN CASO DE NO ENCONTRAR OTRO REGISTRO.
			let vsflag_archpendiente = 'F';
			let vielemento = 0;
			let vscodret = '00000';
			let vitot_registros = 0;
			let vmtot_monto = 0.0;
			let vsmensaje_respuesta = 'Proceso para obtener archivos a ser integrados.';
			set lock mode to wait 3;
			set isolation to dirty read ;
			select first 1
				flag_archpendiente, nombrearchivo,  archivo_origen, fecha_archivo,carga, 
				prefijo_archivo,  conciliacion_inter, conciliacion_sif, conciliacion_admin, 
				rep_aix, rep_win, tipo_layout, b_seguridad
			into 
				vsflag_archpendiente, vsnombrearchivo,vsarchivo_origen, vdtfecha_archivo, vscarga, 
				vsprefijo_archivo,vsconciliacion_inter, vsconciliacion_sif, vsconciliacion_admin, 
				vsrep_aix, vsrep_win, vitipo_layout, vsseguridad
			from table( multiset 
				(select catarchori.horario_ejecucion_hoy, catarchori.orden_proceso, 
						'V' as flag_archpendiente, archtrans.nombrearchivo, archtrans.archivo_origen, archtrans.fecha_archivo, archtrans.carga, 
						catarchori.prefijo_archivo,  catarchori.conciliacion_inter, catarchori.conciliacion_sif, catarchori.conciliacion_admin, 
						catarchori.rep_aix, catarchori.rep_win, catarchori.tipo_layout, catarchori.b_seguridad
					from 	
						bditransfer:"informix".tf_archivos_transfer as archtrans left join 
						bditransfer:"informix".tf_catarchivo_transfer as catarchori 
						on archtrans.archivo_origen = (case
															when catarchori.Archivo_Origen in ('EE0','EE1', 'EE2', 'EE3', 'EE4', 'EE5') then 'EEC'
															when catarchori.Archivo_Origen in ('DE0','DE1', 'DE2', 'DE3', 'DE4', 'DE5') then 'DEC'
															when catarchori.Archivo_Origen in ('RE0','RE1', 'RE2', 'RE3', 'RE4', 'RE5') then 'REC'
														else
															catarchori.Archivo_Origen
														end ) -- Se agrega para contemplar cambios el las claves de archivo origen
					where 	archtrans.proceso = 'P' and 
							archtrans.fecha_archivo = (vdfecha_hoy_integral - catarchori.dias_desfase)::date and
							catarchori.horario_ejecucion_hoy <= pihorario
					order by catarchori.horario_ejecucion_hoy, catarchori.orden_proceso asc	) );
				
			if (nvl(vsflag_archpendiente, 'F') <> 'V') then --no encontro movimiento normal busca extemporaneo

				let vsmensaje_respuesta = 'Obtener archivos a conciliar extemporaneo.';
				set lock mode to wait 3;
				set isolation to dirty read ;
				select first 1
					flag_archpendiente, nombrearchivo,  archivo_origen, fecha_archivo,carga, 
					prefijo_archivo,  conciliacion_inter, conciliacion_sif, conciliacion_admin, 
					rep_aix, rep_win, tipo_layout, b_seguridad
				into 
					vsflag_archpendiente, vsnombrearchivo,vsarchivo_origen, vdtfecha_archivo, vscarga, 
					vsprefijo_archivo,vsconciliacion_inter, vsconciliacion_sif, vsconciliacion_admin, 
					vsrep_aix, vsrep_win, vitipo_layout, vsseguridad
					from table( multiset 
							(select catarchori.horario_ejecucion_hoy, catarchori.orden_proceso, 
								'V' as flag_archpendiente, archtrans.nombrearchivo, archtrans.archivo_origen, archtrans.fecha_archivo, archtrans.carga, 
								catarchori.prefijo_archivo,  catarchori.conciliacion_inter, catarchori.conciliacion_sif, catarchori.conciliacion_admin, 
								catarchori.rep_aix, catarchori.rep_win, catarchori.tipo_layout, catarchori.b_seguridad
							from 	bditransfer:"informix".tf_archivos_transfer as archtrans left join 
								bditransfer:"informix".tf_catarchivo_transfer as catarchori 
								on archtrans.archivo_origen = (case
																	when catarchori.Archivo_Origen in ('EE0','EE1', 'EE2', 'EE3', 'EE4', 'EE5') then 'EEC'
																	when catarchori.Archivo_Origen in ('DE0','DE1', 'DE2', 'DE3', 'DE4', 'DE5') then 'DEC'
																	when catarchori.Archivo_Origen in ('RE0','RE1', 'RE2', 'RE3', 'RE4', 'RE5') then 'REC'
																else
																		catarchori.Archivo_Origen
																end ) -- Se agrega para contemplar cambios el las claves de archivo origen
							where 	archtrans.proceso = 'P' and 
									archtrans.fecha_archivo <= (vdfecha_hoy_integral - catarchori.dias_desfase)::date and
									horario_ejecucion_hoy <= pihorario
						order by horario_ejecucion_hoy, orden_proceso asc) 
							);
			end if;
				
				--actualiza la hora de inicio de proceso del archivo
			set lock mode to wait 3;
			update bditransfer:"informix".tf_archivos_transfer
			set fecha_hora_ini_proceso = (select dbinfo('utc_to_datetime', sh_curtime)::datetime year to fraction(5) from sysmaster:"informix".sysshmvals),
				fecha_proceso = (select dbinfo('utc_to_datetime', sh_curtime)::date from sysmaster:"informix".sysshmvals)
				where 	nombrearchivo = vsnombrearchivo and 
						archivo_origen = vsarchivo_origen and 
						fecha_archivo = vdtfecha_archivo;
							
			if vsflag_archpendiente = 'V' then 
			
				let vsflag_ciclo_buscararch = 'V';
				
				--Valida que la carga del archivo no fue realizada previamente
				if (vscarga <> 'V') then 
					--carga el archivo a la tabla de paso
					set lock mode to wait 3;
					execute procedure bditransfer:"informix".sp_transfer_cargaarchivos ( 
																						vsrep_aix,  		--Indica ruta donde va tomar el archivo
																						vsnombrearchivo, 	--Indica el nombre del archivo a ser procesado
																						vsarchivo_origen, 	--Indica la abreviatura del nombre del archivo
																						vitipo_layout,		--Indica el tipo de layout para los procesos de integracion
																						vsrep_aix,			--Indica la ruta donde se realizan los procesos de carga
																						vsseguridad			--Indica Proceso para carga de archivo seguro
																						) 
						into 	vscodret,
								vsmensaje_respuesta,
								vitot_registros,
								vielemento; 
				end if;
				if vscodret = '00000' then
					set lock mode to wait 3;
					--Actualiza la hora de fin de la cargar de archivo a la bd
					update bditransfer:"informix".tf_archivos_transfer
						set fecha_hora_carga_archivo = (select dbinfo('utc_to_datetime', sh_curtime)::datetime year to fraction(5) from sysmaster:"informix".sysshmvals),
							fecha_hora_ini_integracion_reg = (select dbinfo('utc_to_datetime', sh_curtime)::datetime year to fraction(5) from sysmaster:"informix".sysshmvals)
						where 	nombrearchivo = vsnombrearchivo and 
								archivo_origen = vsarchivo_origen and 
								fecha_archivo = vdtfecha_archivo;
				end if;		
				
				-- Para para cargar a tablas que no son temporales
				if (vitipo_layout  in (1,2,10,12,4,11,5,6,3,7,15,16,8,20,21) and  (vscodret = '00000') and (vsCarga <> 'V'))  then --Valida si el archivo se cargo a la tabla de paso.
					set lock mode to wait 3;
					--Carga la informacion significativa de la tabla temporal a las tablas correspondientes
					execute procedure bditransfer:"informix".sp_transfer_obtenerregistroarchivo (
																								vsnombrearchivo,
																								vsarchivo_origen,
																								vitipo_layout,
																								pscve_usuario 
																								) 
					into 	vscodret, 
							vsmensaje_respuesta, 
							vielemento;
				--Carga la informacion significativa de la tablas temporales a las tablas definitivas correspondientes
				elif (vitipo_layout  in (9,17,18,19) and  (vscodret = '00000') and (vsCarga <> 'V')) then 
					set lock mode to wait 3;
					execute procedure bditransfer:"informix".sp_transfer_obtenerregistrottemporal (
																								vsnombrearchivo,
																								vsarchivo_origen,
																								vitipo_layout,
																								pscve_usuario
																								)
					into
							vscodret,
							vsmensaje_respuesta,
							vielemento;
				end if;
		
				--if vscodret = '00000' then 
				--actualiza la hora de fin de la cargar en la diferentes tablas que les corresponde ya se general o temporal correspondiente
					set lock mode to wait 3;
					update bditransfer:"informix".tf_archivos_transfer  --fecha_hora_carga_tabla num_registros fecha_hora_ini_integracion_reg
						set 	fecha_hora_carga_tabla = (select dbinfo('utc_to_datetime', sh_curtime)::datetime year to fraction(5) from sysmaster:"informix".sysshmvals),
								num_registros = vitot_registros, 
								carga = decode(vscodret, '00000', 'V', 'F'),
								proceso = DECODE(vsCodRet, '00000', 'T', 'E'),
								fecha_hora_fin_integracion_reg = (select dbinfo('utc_to_datetime', sh_curtime)::datetime year to fraction(5) from sysmaster:"informix".sysshmvals)
						where
								nombrearchivo = vsnombrearchivo and 
								archivo_origen = vsarchivo_origen and
								fecha_archivo = vdtfecha_archivo;
				--end if;
				
				
				-- llamado sp de validacion 
				set lock mode to wait 3;
				execute procedure bditransfer:"informix".sp_transfer_validaintegridad (
																						vsnombrearchivo,
																						vsarchivo_origen,
																						vitipo_layout,
																						pscve_usuario
																						)
				into
								vscodret,
								vsmensaje_respuesta;
				
				if (vscodret = '00000') then 
						--Actualiza la hora de fin de la conciliacion de los registros
						update bditransfer:"informix".tf_archivos_transfer
							set 	fecha_hora_fin_proceso = (select dbinfo('utc_to_datetime', sh_curtime)::datetime year to fraction(5) from sysmaster:"informix".sysshmvals)
						where nombrearchivo = vsnombrearchivo 
							and archivo_origen = vsarchivo_origen 
							and fecha_archivo = vdtfecha_archivo;
				end if;
			end if;
				--LET vsFlag_ArchPendiente = 'F'; 
				--LET vsflag_ciclo_buscararch = 'F'; --TERMINA EL CICLO 
		
		end while;
		
		let vsmensaje_respuesta = 'actualiza la hora de fin de la conciliación de los registros y totales.';
		
		set lock mode to wait 3;
		set isolation to dirty read ;
		--libera la bandera de conciliacion en ejecucion
		update bditransfer:"informix".tf_param_transfer 
			set 	valor = 'F', 
				fecha_modificacion = (select dbinfo('utc_to_datetime', sh_curtime)::datetime year to fraction(5) from sysmaster:"informix".sysshmvals) 
			where 	codigo = '001' and 
					trim(valor) = 'V';
	end if;
	
	let vsmensaje_respuesta = 'Proceso de Integracion Terminado';
	
	RETURN 
			vsCodRet, 
			vsMensaje_Respuesta;
end
end procedure
DOCUMENT
'AUTOR: Ricardo Resendiz Martínez',
'Proyecto: Integración de Archivos Transfer',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Proceso principal de para la integración de archivos',
'Fecha: 2014/06/XX',
'Version: 201406XX.YYYY',
'BD: Bditransfer',
'',
'MODIFICO: L.I.A.Ricardo Resendiz Martínez',
'Proyecto: Integración de Archivos Transfer',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Contemplar proceso por esquemas de variacion en fechas de los estados de Cuenta',
'Fecha: 2015/04/09',
'Version: 20150409.1330',
'BD: Bditransfer',
'',
'MODIFICO: L.I.A.Ricardo Resendiz Martínez',
'Proyecto: RQM 10 650 VR12-2 ATP 0620 Folio Operaciones Administrativas TRANSFER',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Se integra en el ciclo el layout numero 20 que es el asignado para la integración de reporte de transacciones administrativas',
'Fecha: 2015/08/26',
'Version: 20150826.1730',
'BD: Bditransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 10 721-2 - Transfer OPM SPEI',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Se integra en el ciclo el layout numero 21 que es el asignado para la Transacciones OPM-SPEI',
'Fecha: 2016/08/18',
'Version: 20160818.1800',
'BD: Bditransfer';

CREATE PROCEDURE "informix".sp_cst_cancela_cta_tf ()

RETURNING 	CHAR(5) 	AS cCodRet,
		CHAR(20) 	AS cserviceName,
		CHAR(4) 	AS ccountryCode,
		CHAR(4) 	AS cbankId,
		CHAR(4) 	AS caccessMethod,
		CHAR(20) 	AS cCuentaTf,
		CHAR (10) 	AS cidentifierType,	    			
	    CHAR(13) 	AS cTelefono;
			
	
			
---DECLARACION DE VARIABLES
DEFINE iSqlErr      	 	INTEGER;
DEFINE cCodRet      	 	CHAR(5);
DEFINE cserviceName 	 	CHAR(20);
DEFINE ccountryCode 		CHAR(4);
DEFINE cbankId     		CHAR(4);
DEFINE coriginatorTransactionId CHAR(50);
DEFINE caccessMethod        	CHAR(4);
DEFINE ccustomerIdentifier      CHAR(3);
DEFINE cidentifierType    	CHAR(10);
DEFINE cCuentaTf    		CHAR(20);
DEFINE cTelefono	   	CHAR(13);
DEFINE dFecCancelac		CHAR(12);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '0000';
LET cserviceName        = 'getCustomerData';    
LET ccountryCode 	= '484';    
LET cbankId         = '137';
LET coriginatorTransactionId = '';
LET caccessMethod 	= '102';    
LET ccustomerIdentifier = '';    
LET cidentifierType     = '104';    
LET cCuentaTf     	= '';    
LET cTelefono		= '';
LET dFecCancelac	= '';


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','','','','','','';
		END IF;
	END EXCEPTION;
	
		
	--SET DEBUG FILE TO '/informix/mijail/sp_valida_curp.out';
	--TRACE ON;
	
	
	SET LOCK MODE TO WAIT 3;
	
		FOREACH WITH HOLD
		
					SELECT fec_cancelac,cuenta_tf,telefono
		INTO dFecCancelac,cCuentaTf,cTelefono
		FROM bditransfer:"informix".tf_maecte
		WHERE status_cta = '2' 
			
			RETURN cCodret,trim(cserviceName),trim(ccountryCode),trim(cbankId),trim(caccessMethod),trim(cCuentaTf),trim(cidentifierType),cTelefono WITH RESUME;
			
		END FOREACH;		
					
			RETURN cCodRet, '','','','','','','';


END;			
END PROCEDURE;