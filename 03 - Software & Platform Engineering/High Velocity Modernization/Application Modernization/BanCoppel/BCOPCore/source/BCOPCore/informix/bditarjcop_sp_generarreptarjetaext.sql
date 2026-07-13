CREATE PROCEDURE "informix".sp_generarreptarjetaext(

psNumEmpleado CHAR(8),
pdFechaIni DATE,
pdFechaFin DATE
)

RETURNING CHAR(5) AS CodRetorno , CHAR(200) AS Mensaje;

--****************************************************************************************************
-- DESCRIPCION: Generar archivo de intercambio con un listado de tarjetas extraviadas.
-- AUTOR : Osuna Iza Alejandro
-- FECHA : 15/12/2008
-- BD: bditarjcop
-- SISTEMA : Inventario de Tarjetas Caja Unica.
-- MODIFICADO: Casanova Edeza Hector Juan 03/01/2009.
--****************************************************************************************************

--Declaracion de variables
DEFINE vsCodRet CHAR(5);
DEFINE vsSqlErr  SMALLINT;
DEFINE vsNomReporte CHAR(40);
DEFINE vdFechaSer DATE;
DEFINE vsFechRep CHAR(8);
DEFINE v_sIpRep  CHAR(16);
DEFINE vsRuta CHAR(500);
DEFINE vsSQL1  CHAR (100);
DEFINE vsSQL2  CHAR (1000);
DEFINE vsSQL3  CHAR (500);
DEFINE vsSQL  CHAR (1200);
DEFINE vsSQLO CHAR (370);
DEFINE vsNomArchivo CHAR(40);
DEFINE vsMensaje CHAR(200);
DEFINE vsFlagSoloNumeros CHAR (1);

--Inicializacion de Variables
LET vsCodRet = '';
LET vsNomReporte = '';
LET vsFechRep = '';
LET vsSQL = '';
LET vsSQL1 = '';
LET vsSQL2 = '';
LET vsSQL3 = '';
LET vsSQLO = '';
LET vsNomArchivo = '';
LET vsMensaje = '';
LET vsFlagSoloNumeros = '' ;

--SET DEBUG FILE TO "/tmp/SP_GenerarRepTarjetaExt.out";
--TRACE ON;

BEGIN

--Errores de excepcion
ON EXCEPTION SET vsSqlErr
	--GUARDA  REGISTRO DE LA OPERACION EN LA BITACORA
	INSERT INTO bditarjcop:"informix".BitacoraTarCop (Empleado, Fecha, Actividad, NomArchivo, CodRetorno) VALUES (psNumEmpleado, CURRENT, 'REP ENVIOS REC', vsNomArchivo, vsSqlErr);
	LET vsCodRet = vsSqlErr;
	RETURN vsCodRet, '';
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

EXECUTE PROCEDURE bditarjcop:"informix".sp_EsNumerico (psNumEmpleado) INTO vsFlagSoloNumeros;

--Validaciones de datos
IF ( vsFlagSoloNumeros <> 'V' ) THEN 
	--El numero del empleado debe contener solo numeros.
	LET vsCodRet = '00600';
ELIF (LENGTH (TRIM(psNumEmpleado)) < 8) THEN  
	--El numero del emleado debe contener 8 numeros.
	LET vsCodRet = '00601';
ELIF (pdFechaIni = '') OR (pdFechaIni IS NULL)THEN
	--No se ha indicado una fecha de inicio para rango de fechas.
	LET vsCodRet = '00602';
ELIF (pdFechaIni = '') OR (pdFechaIni IS NULL)THEN
	--No se ha indicado una fecha final para rango de fechas.
	LET vsCodRet = '00603';
ELIF(pdFechaIni > pdFechaFin) THEN 
	--La fecha inicial es mayor ala fecha final.
	LET vsCodRet = '00604';
ELSE
--El Sistema de generación de reporte Coppel obtiene la ubicación del directorio donde se generara el archivo de intercambio.
	SELECT valor INTO vsRuta FROM bditarjcop:"informix".paraminvtarcop WHERE descripcion = 'REPOSITORIO';
	--El Sistema de generación de reporte Coppel crea un archivo de intercambio sin contenido alguno con un nombre representativo de su contenido y la fecha actual.
	--Toma de fecha a la tabla bdinteg, para el archivo
	LET vdFechaSer  = CURRENT::DATE;
	LET vsFechRep = SUBSTR(vdFechaSer,7,10) || SUBSTR(vdFechaSer,1,2) || SUBSTR(vdFechaSer,4,5);
	LET vsNomReporte = 'E' || TRIM(vsFechRep) || '.dat';
	--El Sistema de generación de reporte Coppel obtiene todas las claves de empresa, clave de sucursal, números de tarjetas, numero de envió, y fecha de asignación agrupados por clave de 
	--empresa y clave de sucursal de todas las tarjetas numeradas que tengan estatus "Extraviada".
	---Tarjeta Extraviadas
		LET vsNomArchivo = vsNomReporte;
		LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRuta) || '/' || TRIM(vsNomReporte) || ' DELIMITER ' || ''' ''';
		LET vsSQL2 = " SELECT ('001'||'|'||'0000'||'|'||'E'||'|'||"
					 || " ((SELECT COUNT(cvesucursal) FROM bditarjcop:tarjetasnumtarcop WHERE estatustarjeta = 'E' AND FechaAsignacion::DATE  BETWEEN '" || pdFechaIni ||  "' AND '" ||  pdFechaFin || "')::INTEGER + "
					 || " (SELECT COUNT(cvesucursal) FROM bditarjcop:tarjetasrepotarcop WHERE estatustarjeta = 'E' AND FechaAsignacion::DATE  BETWEEN '" || pdFechaIni ||  "' AND '" ||  pdFechaFin || "')::INTEGER)::CHAR(9)) "
					 || " FROM  bditarjcop:paraminvtarcop WHERE descripcion = 'REPOSITORIO' AND Empresa = '001' UNION "
					 || " SELECT (Empresa||'|'||CveSucursal||'|'||'N'||'|'||NumTarjeta::CHAR(9)) FROM bditarjcop:TarjetasNumTarCop WHERE EstatusTarjeta = '"
						|| 'E' || "'  AND FechaAsignacion::DATE  BETWEEN '" || pdFechaIni ||  "' AND '" ||  pdFechaFin || "'UNION "
					 || " SELECT (Empresa||'|'||CveSucursal||'|'||'R'||'|'||NumTarjeta::CHAR(9)) FROM bditarjcop:TarjetasRepoTarCop WHERE EstatusTarjeta = '"
						|| 'E' || "'  AND FechaAsignacion::DATE  BETWEEN '" || pdFechaIni ||  "' AND '" ||  pdFechaFin || "'";
						
		LET vsSQL3 = ' " > '|| TRIM(vsRuta) || '/Reporte_Ext.sql;';
		LET vsSQL1 = TRIM(vsSQL1);
		LET vsSQL3 = TRIM(vsSQL3);
		LET vsSQL = vsSQL1 || ' ' || vsSQL2 || vsSQL3;
		IF ( vsSQL <> '' ) THEN
			SYSTEM vsSQL ;
			--Permiso para la creacion de archivo.
			LET vsSQLO = '';
			LET vsSQLO = 'chmod 666 ' || TRIM(vsRuta) || '/Reporte_Ext.sql';
			LET vsSQLO = TRIM(vsSQLO);
			LET vsSQLO = '';
			LET vsSQLO = 'dbaccess bditarjcop ' || TRIM(vsRuta) || '/Reporte_Ext.sql';
			LET vsSQLO = TRIM(vsSQLO);
			SYSTEM vsSQLO;
			--Borra el archivo de control.
			LET vsSQL = '' ;
			LET vsSQL = 'rm ' || TRIM(vsRuta) || '/Reporte_Ext.sql';
			SYSTEM vsSQL ;
		END IF;
		LET vsCodRet =  '00000';
END IF;

--GUARDA  REGISTRO DE LA OPERACION EN LA BITACORA
	INSERT INTO bditarjcop:"informix".BitacoraTarCop (Empleado, Fecha, Actividad, NomArchivo, CodRetorno) VALUES (psNumEmpleado, CURRENT, 'REP TARJETAS EXT', vsNomArchivo, vsCodRet);

	SELECT mensaje INTO vsMensaje FROM bditarjcop:"informix".mensajestarcop WHERE codmensaje = vsCodRet;
	
	RETURN vsCodRet, vsMensaje;

END
END PROCEDURE
DOCUMENT
'AUTOR: Osuna Iza Alejandro',
'Proyecto: Alta Única',
'Descripcion: Generar archivo de intercambio con un listado de tarjetas extraviadas.',
'Fecha: 2009/01/29',
'Version: 201090129.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_generarreptarjetaext_pba(

psNumEmpleado CHAR(8),
pdFechaIni DATE,
pdFechaFin DATE
)

RETURNING CHAR(5) AS CodRetorno , CHAR(200) AS Mensaje;

--****************************************************************************************************
-- DESCRIPCION: Generar archivo de intercambio con un listado de tarjetas extraviadas.
-- AUTOR : Osuna Iza Alejandro
-- FECHA : 15/12/2008
-- BD: bditarjcop
-- SISTEMA : Inventario de Tarjetas Caja Unica.
-- MODIFICADO: Casanova Edeza Hector Juan 03/01/2009.
--****************************************************************************************************

--Declaracion de variables
DEFINE vsCodRet CHAR(5);
DEFINE vsSqlErr  SMALLINT;
DEFINE vsNomReporte CHAR(40);
DEFINE vdFechaSer DATE;
DEFINE vsFechRep CHAR(8);
DEFINE v_sIpRep  CHAR(16);
DEFINE vsRuta CHAR(500);
DEFINE vsSQL1  CHAR (100);
DEFINE vsSQL2  CHAR (1000);
DEFINE vsSQL3  CHAR (500);
DEFINE vsSQL  CHAR (1200);
DEFINE vsSQLO CHAR (500);
DEFINE vsNomArchivo CHAR(100);
DEFINE vsMensaje CHAR(500);
DEFINE vsFlagSoloNumeros CHAR (1);

--Inicializacion de Variables
LET vsCodRet = '';
LET vsNomReporte = '';
LET vsFechRep = '';
LET vsSQL = '';
LET vsSQL1 = '';
LET vsSQL2 = '';
LET vsSQL3 = '';
LET vsSQLO = '';
LET vsNomArchivo = '';
LET vsMensaje = '';
LET vsFlagSoloNumeros = '' ;

SET DEBUG FILE TO "SP_GenerarRepTarjetaExt.trc";
TRACE ON;

BEGIN

--Errores de excepcion
ON EXCEPTION SET vsSqlErr
	--GUARDA  REGISTRO DE LA OPERACION EN LA BITACORA
	INSERT INTO bditarjcop:"informix".BitacoraTarCop (Empleado, Fecha, Actividad, NomArchivo, CodRetorno) VALUES (psNumEmpleado, CURRENT, 'REP ENVIOS REC', vsNomArchivo, vsSqlErr);
	LET vsCodRet = vsSqlErr;
	RETURN vsCodRet, '';
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

EXECUTE PROCEDURE bditarjcop:"informix".sp_EsNumerico (psNumEmpleado) INTO vsFlagSoloNumeros;

--Validaciones de datos
IF ( vsFlagSoloNumeros <> 'V' ) THEN 
	--El numero del empleado debe contener solo numeros.
	LET vsCodRet = '00600';
ELIF (LENGTH (TRIM(psNumEmpleado)) < 8) THEN  
	--El numero del emleado debe contener 8 numeros.
	LET vsCodRet = '00601';
ELIF (pdFechaIni = '') OR (pdFechaIni IS NULL)THEN
	--No se ha indicado una fecha de inicio para rango de fechas.
	LET vsCodRet = '00602';
ELIF (pdFechaIni = '') OR (pdFechaIni IS NULL)THEN
	--No se ha indicado una fecha final para rango de fechas.
	LET vsCodRet = '00603';
ELIF(pdFechaIni > pdFechaFin) THEN 
	--La fecha inicial es mayor ala fecha final.
	LET vsCodRet = '00604';
ELSE
--El Sistema de generación de reporte Coppel obtiene la ubicación del directorio donde se generara el archivo de intercambio.
	SELECT valor INTO vsRuta FROM bditarjcop:"informix".paraminvtarcop WHERE descripcion = 'REPOSITORIO';
	--El Sistema de generación de reporte Coppel crea un archivo de intercambio sin contenido alguno con un nombre representativo de su contenido y la fecha actual.
	--Toma de fecha a la tabla bdinteg, para el archivo
	LET vdFechaSer  = CURRENT::DATE;
	LET vsFechRep = SUBSTR(vdFechaSer,7,10) || SUBSTR(vdFechaSer,1,2) || SUBSTR(vdFechaSer,4,5);
	LET vsNomReporte = 'E' || TRIM(vsFechRep) || '.dat';
	--El Sistema de generación de reporte Coppel obtiene todas las claves de empresa, clave de sucursal, números de tarjetas, numero de envió, y fecha de asignación agrupados por clave de 
	--empresa y clave de sucursal de todas las tarjetas numeradas que tengan estatus "Extraviada".
	---Tarjeta Extraviadas
		LET vsNomArchivo = vsNomReporte;
		LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRuta) || '/' || TRIM(vsNomReporte) || ' DELIMITER ' || ''' ''';
		LET vsSQL2 = " SELECT ('001'||'|'||'0000'||'|'||'E'||'|'||"
					 || " ((SELECT COUNT(cvesucursal) FROM bditarjcop:tarjetasnumtarcop WHERE estatustarjeta = 'E' AND FechaAsignacion::DATE  BETWEEN '" || pdFechaIni ||  "' AND '" ||  pdFechaFin || "')::INTEGER + "
					 || " (SELECT COUNT(cvesucursal) FROM bditarjcop:tarjetasrepotarcop WHERE estatustarjeta = 'E' AND FechaAsignacion::DATE  BETWEEN '" || pdFechaIni ||  "' AND '" ||  pdFechaFin || "')::INTEGER)::CHAR(9)) "
					 || " FROM  bditarjcop:paraminvtarcop WHERE descripcion = 'REPOSITORIO' AND Empresa = '001' UNION "
					 || " SELECT (Empresa||'|'||CveSucursal||'|'||'N'||'|'||NumTarjeta::CHAR(9)) FROM bditarjcop:TarjetasNumTarCop WHERE EstatusTarjeta = '"
						|| 'E' || "'  AND FechaAsignacion::DATE  BETWEEN '" || pdFechaIni ||  "' AND '" ||  pdFechaFin || "'UNION "
					 || " SELECT (Empresa||'|'||CveSucursal||'|'||'R'||'|'||NumTarjeta::CHAR(9)) FROM bditarjcop:TarjetasRepoTarCop WHERE EstatusTarjeta = '"
						|| 'E' || "'  AND FechaAsignacion::DATE  BETWEEN '" || pdFechaIni ||  "' AND '" ||  pdFechaFin || "'";
						
		LET vsSQL3 = ' " > '|| TRIM(vsRuta) || '/Reporte_Ext.sql;';
		LET vsSQL1 = TRIM(vsSQL1);
		LET vsSQL3 = TRIM(vsSQL3);
		LET vsSQL = vsSQL1 || ' ' || vsSQL2 || vsSQL3;
		IF ( vsSQL <> '' ) THEN
			SYSTEM vsSQL ;
			--Permiso para la creacion de archivo.
			LET vsSQLO = '';
			LET vsSQLO = 'chmod 666 ' || TRIM(vsRuta) || '/Reporte_Ext.sql';
            ---LET vsSQLO = 'chmod 666  /resplogifx/archivoscartera/altaunica/recepcion/Reporte_Ext.sql';
			LET vsSQLO = TRIM(vsSQLO);
			LET vsSQLO = '';
			LET vsSQLO = 'dbaccess bditarjcop ' || TRIM(vsRuta) || '/Reporte_Ext.sql';
			LET vsSQLO = TRIM(vsSQLO);
			SYSTEM vsSQLO;
			--Borra el archivo de control.
			LET vsSQL = '' ;
			LET vsSQL = 'rm ' || TRIM(vsRuta) || '/Reporte_Ext.sql';
			SYSTEM vsSQL ;
		END IF;
		LET vsCodRet =  '00000';
END IF;

--GUARDA  REGISTRO DE LA OPERACION EN LA BITACORA
	INSERT INTO bditarjcop:"informix".BitacoraTarCop (Empleado, Fecha, Actividad, NomArchivo, CodRetorno) VALUES (psNumEmpleado, CURRENT, 'REP TARJETAS EXT', vsNomArchivo, vsCodRet);

	SELECT mensaje INTO vsMensaje FROM bditarjcop:"informix".mensajestarcop WHERE codmensaje = vsCodRet;
	
	RETURN vsCodRet, vsMensaje;

END
END PROCEDURE
DOCUMENT
'AUTOR: Osuna Iza Alejandro',
'Proyecto: Alta Única',
'Descripcion: Generar archivo de intercambio con un listado de tarjetas extraviadas.',
'Fecha: 2009/01/29',
'Version: 201090129.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_cancela_tarjetas(cEmpresa CHAR(3))
RETURNING CHAR(6) AS CODRET, INT AS CANCELADAS;

DEFINE cCodRetorno CHAR(6);
DEFINE iCanceladas INT;
DEFINE iSqlErr INT;

LET cCodRetorno = '000000';
LET iCanceladas = 0;
LET iSqlErr = 0;

--SET DEBUG FILE TO '/tmp/sp_cancela_tarjetas.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRetorno = iSqlErr;
			RETURN cCodRetorno, iCanceladas;
		END IF;
	END EXCEPTION;
	
	SELECT COUNT(*) 
	INTO iCanceladas
	FROM bditarjcop:"informix".tarjetasnumtarcop WHERE empresa = cEmpresa AND estatustarjeta IN ('P','N');
	
	IF iCanceladas > 0 THEN
		UPDATE bditarjcop:"informix".tarjetasnumtarcop SET estatustarjeta = 'C' 
		WHERE empresa = cEmpresa AND estatustarjeta IN ('P','N');
	END IF;
	
	RETURN cCodRetorno, iCanceladas;
END;
END PROCEDURE
DOCUMENT
'AUTOR: VICTOR HUGO NUÑEZ',
'Proyecto: Alta Única',
'Descripcion: Cancelar las tarjetas que se quedaron pendientes en el dia.',
'Fecha: 05/12/2012',
'Version: 20121205.1614',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_tarjeta_pendiente(cEmpresa CHAR(3), cSucursal CHAR(4), cNumeroTarjeta CHAR(9))
RETURNING CHAR(6) AS CODRET;

DEFINE cCodRetorno CHAR(6);
DEFINE iSqlErr SMALLINT;

LET cCodRetorno = '000000';
LET iSqlErr = 0;

--SET DEBUG FILE TO '/tmp/sp_tarjeta_pendiente.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRetorno = iSqlErr;
			RETURN cCodRetorno;
		END IF;
	END EXCEPTION;
	
	IF EXISTS(SELECT empresa FROM bditarjcop:"informix".inventariotarcop WHERE empresa = cEmpresa)THEN
		--Verifica si la clave de sucursal proporcionada cuenta con un inventario de tarjetas.
		IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".inventariotarcop WHERE cvesucursal = cSucursal)THEN
			--Si el tipo de tarjeta es numerada.
			--Verifica si existe el numero de tarjeta indicado.
			IF EXISTS(SELECT numtarjeta FROM bditarjcop:"informix".tarjetasnumtarcop 
			WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numtarjeta = cNumeroTarjeta)THEN
				--Verifica que el numero de tarjeta proporcionado se encuentre con estatus "P".
				IF EXISTS(SELECT numtarjeta FROM bditarjcop:"informix".tarjetasnumtarcop 
				WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numtarjeta = cNumeroTarjeta AND estatustarjeta = 'P')THEN
					--Marca como disponible el numero de tarjeta indicado.
					UPDATE bditarjcop:"informix".tarjetasnumtarcop SET estatustarjeta = 'N' 
					WHERE empresa = cEmpresa 
					AND cvesucursal = cSucursal
					AND numtarjeta = cNumeroTarjeta;
					--La operación se realizo de manera exitosa.
					LET cCodRetorno = '00000';
				ELIF EXISTS(SELECT numtarjeta FROM bditarjcop:"informix".tarjetasnumtarcop 
				WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numtarjeta = cNumeroTarjeta AND estatustarjeta = 'E')THEN
					--Numero de tarjeta marcada como extraviada anteriormente.
					LET cCodRetorno = '00404';
				ELIF EXISTS(SELECT numtarjeta FROM bditarjcop:"informix".tarjetasnumtarcop 
				WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numtarjeta = cNumeroTarjeta AND estatustarjeta = 'A')THEN
					--Numero de tarjeta asignada anteriormente.
					LET cCodRetorno = '00405';
				END IF;
			ELSE
				--No se localizo el numero de tarjeta proporcionado.
				LET cCodRetorno = '00403';
			END IF;
		ELSE
		END IF;
	ELSE
	END IF;
	RETURN cCodRetorno;
END;
END PROCEDURE
DOCUMENT
'AUTOR: VICTOR HUGO NUÑEZ',
'Proyecto: Alta Única',
'Descripcion: Establece en pendiente la tarjeta al abandonar la asignacion de tarjeta.',
'BD:bditarjcop',
'Fecha: 05/12/2012',
'Version: 20121205.1614',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_asignartarjetanumeradacop(p_sempresa CHAR(3),p_scvesucursal CHAR(4))
RETURNING CHAR(5),CHAR(9);

--****************************************************************************************************
-- DESCRIPCION: Asignar un numero de tarjeta/cliente coppel y actualiza el inventario de tarjetas de la sucursal.
-- AUTOR : Osuna Iza Alejandro
-- FECHA : 15/12/2008
-- BD: Intercard
-- SISTEMA : Inventario de Tarjetas Caja Unica.
-- MODIFICADO: Casanova Edeza Hector Juan 03/01/2009.
--*********************************************************************************************************

--declaracion de variables
DEFINE v_sCodRet CHAR(5);
DEFINE v_isql_err  SMALLINT;
DEFINE v_starjeta CHAR(9);
DEFINE v_starjetaultima CHAR(9);
DEFINE v_snum_envio CHAR(9);
DEFINE v_irangofin INTEGER;
--dsb-05/12/2012
DEFINE v_irangoini INTEGER;


--- inicializacion de variables
LET v_sCodRet = '';
LET v_starjeta = '';
LET v_starjetaultima = '';
LET v_snum_envio = '';
LET v_irangofin = 0;
LET v_isql_err = 0;
--dsb-05/12/2012
LET v_irangoini = 0;

--SET DEBUG FILE TO "/tmp/sp_AsginarTarjetaNumeradaCop.out";
--TRACE ON;

BEGIN

--Errores de excepcion
ON EXCEPTION SET  v_isql_err

IF v_isql_err <> 0 THEN
	LET v_sCodRet =  v_isql_err;
	LET v_starjeta = '000000000';
	RETURN v_sCodRet, v_starjeta;
END IF;

END EXCEPTION

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--Verifica si existe la empresa proporcionada.
IF EXISTS(SELECT empresa FROM bditarjcop:"informix".inventariotarcop WHERE empresa = p_sempresa)THEN
--Verifica si la clave de sucursal proporcionada cuenta con un inventario de tarjetas.
IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".inventariotarcop WHERE cvesucursal = p_scvesucursal)THEN
	--Se valida que los datos no vengan en blanco.
	IF (NVL(p_sempresa,'') <> '')  AND (NVL(p_scvesucursal,'') <> '') THEN
		---Se valida que existan tarjetas para aplicar en esa sucursal
		IF EXISTS (SELECT consumo FROM bditarjcop:"informix".inventariotarcop WHERE empresa = p_sempresa and cvesucursal = p_scvesucursal  AND tipotarjeta = 'N' AND existencia <> 0) THEN
			--se obtiene el numero de la ultima tarjeta numerada asignada del primer envio activo de tarjetas numeradas asignado a la sucursal.
			IF EXISTS(SELECT numenvio,ulttarasignada,rangofin FROM bditarjcop:"informix".enviostarcop WHERE enviodisponible = 'A' AND empresa = p_sempresa AND cvesucursal = p_scvesucursal AND tipotarjeta = 'N') THEN

				--dsb-05/12/2012
				--se buscan tarjeta pendiente
				SELECT FIRST 1 numtarjeta INTO v_starjeta 
				FROM bditarjcop:"informix".tarjetasnumtarcop
				WHERE estatustarjeta = 'N'
				AND empresa = p_sempresa
				AND cvesucursal = p_scvesucursal
				AND fechaasignacion::DATE = CURRENT::DATE; --dsb-23/04/2012
				
				
				IF NVL(v_starjeta, '') = '' THEN
					SELECT FIRST 1 numenvio,ulttarasignada::CHAR(9),rangofin
					INTO v_snum_envio,v_starjetaultima,v_irangofin
					FROM TABLE (MULTISET (
					SELECT FIRST 1 numenvio,(ulttarasignada::INT) AS ulttarasignada,rangofin
					FROM bditarjcop:"informix".enviostarcop
					WHERE enviodisponible = 'A'
					AND empresa = p_sempresa
					AND cvesucursal = p_scvesucursal
					AND tipotarjeta = 'N'
					ORDER BY fecharec));

					LET v_starjetaultima = (v_starjetaultima + 1)::INTEGER ;

					UPDATE bditarjcop:"informix".enviostarcop  SET ulttarasignada = v_starjetaultima WHERE empresa = p_sempresa AND cvesucursal = p_scvesucursal AND numenvio = v_snum_envio AND tipotarjeta = 'N' AND v_starjetaultima BETWEEN rangoini AND rangofin;

					--El Sistema de Consumo Tarjetas coppel valida si el numero de la ultima tarjeta asignada es menor al rango final del envio correspondiente al tipo de tarjeta indicado por el sistema caja ú de sucursal.
					IF v_irangofin <= v_starjetaultima THEN
						UPDATE bditarjcop:"informix".enviostarcop  SET EnvioDisponible = 'N' WHERE empresa = p_sempresa AND cvesucursal = p_scvesucursal AND numenvio = v_snum_envio AND tipotarjeta = 'N' AND v_starjetaultima BETWEEN rangoini AND rangofin;
					END IF;

					LET v_starjetaultima = LPAD(TRIM((v_starjetaultima)::CHAR(9)) ,9,'0') ;

					-- El Sistema de Consumo Tarjetas coppel informa al sistema caja ú de sucursal que la operacióe realizo de manera exitosa.
					LET v_starjeta = v_starjetaultima;

					EXECUTE PROCEDURE bditarjcop:"informix".sp_calcularnumverificador (v_starjeta) INTO v_starjeta;
					
					-- El Sistema de Consumo Tarjetas coppel registra el  numero de tarjeta, el numero de identificardor de producto, clave de la empresa, la clave de la sucursal, el tipo de tarjeta, la fecha y hora de la asignació establece su estatus como "Pendiente".
					INSERT INTO bditarjcop:"informix".TarjetasNumTarCop(Empresa,CveSucursal,NumTarjeta,NumEnvio,EstatusTarjeta,FechaAsignacion)
					VALUES(p_sempresa,p_scvesucursal,v_starjeta,v_snum_envio,'P',CURRENT);

					--El Sistema de Consumo Tarjetas coppel actualiza el consumo de tarjetas numeradas incrementándolo en uno de la sucursal en donde  correspondan la clave de la empresa, la clave de la sucursal.
					--El Sistema de Consumo Tarjetas coppel actualiza la existencia de tarjetas numeradas disminuyendolo en uno de la sucursal en donde correspondan la clave de la empresa, la clave de la sucursal.
					UPDATE bditarjcop:"informix".inventariotarcop SET consumo = consumo + 1, existencia = existencia - 1 WHERE empresa = p_sempresa AND cvesucursal = p_scvesucursal AND tipotarjeta = 'N';

					-- El Sistema de Consumo Tarjetas coppel informa al sistema caja ú de sucursal que la operacióe realizo de manera exitosa.
					LET v_sCodRet = '00000';
				ELSE
					--Actualiza la tarjeta como pendiente
					UPDATE bditarjcop:"informix".tarjetasnumtarcop SET estatustarjeta = 'P' 
					WHERE empresa = p_sempresa 
					AND cvesucursal = p_scvesucursal
					AND numtarjeta = v_starjeta;
					LET v_sCodRet = '00000';
				END IF;
			ELSE 
				-- No se obtiene el numero de la ultima tarjeta numerada asignada del primer envio activo de tarjetas numeradas asignado ala sucursal.
				LET v_sCodRet = '00204';
				LET v_starjeta = '000000000';
			END IF;
		ELSE
			--se le informa que la existencia es 0
			LET v_sCodRet = '00203';
			LET v_starjeta = '000000000';
		END IF;
	ELSE
		--Datos en blanco.
		LET v_sCodRet = '00202';
		LET v_starjeta = '000000000';
	END IF;
ELSE
	--La sucursal no cuenta con un inventario de tarjetas.
	LET v_sCodRet = '00201';
	LET v_starjeta = '000000000';
END IF;
ELSE
--La empresa proporcionada no existe.
LET v_sCodRet = '00200';
LET v_starjeta = '000000000';
END IF;

RETURN v_sCodRet,v_starjeta;

END;
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Asignar un numero de tarjeta/cliente coppel y actualiza el inventario de tarjetas de la sucursal.',
'Fecha: 2009/01/29',
'Version: 201090129.1800',
'BD: bditarjcop',
'Modificó: VICTOR HUGO NUÑEZ',
'Proyecto: Alta Única',
'Descripcion: Busca las tarjetas pendientes para la sucursal y en caso de haberlo es asignada.',
'Fecha: 05/12/2012',
'Version: 20121205.1614',
'BD: bditarjcop',
'Modificó: VICTOR HUGO NUÑEZ',
'Proyecto: Alta Única',
'Descripcion: Se modifica para obtener solo del dia actual.',
'Folio: 1301',
'Fecha: 23/04/2013',
'Version: 20130423.1846',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_au_guardarbitacora_pba(psEmpleado VARCHAR(8), psActividad VARCHAR(20), psNomArchivo VARCHAR(20), psCodRetorno VARCHAR(5))

RETURNING VARCHAR(5) AS Cod_Retorno;

--****************************************************************************************************
-- DESCRIPCION: GUARDA REGISTRO EN BITACORA
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 26/12/2011
-- BD: bdiTarCop
-- SISTEMA : Inventario de Tarjetas Alta Unica.
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsRutaAIX VARCHAR(90);
DEFINE vsRutaWIN VARCHAR(90);

DEFINE viSqlError INTEGER;

/* INICIALIZACION DE VARIABLES */
LET vsRutaAIX = '';
LET vsRutaWIN = '';

LET viSqlError = 0;

BEGIN

  ON EXCEPTION SET viSqlError    --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN viSqlError;

    END EXCEPTION;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--GUARDA REGISTRO EN BITACORA
	INSERT INTO bdiTarjCop:"informix".BitacoraTarCop 
	(
		Empleado, 
		Fecha, 
		Actividad, 
		NomArchivo, 
		CodRetorno
	) 
	VALUES 
	(
		psEmpleado, 
		CURRENT, 
		psActividad,
		psNomArchivo, 
		psCodRetorno
	);
	
	
	
	RETURN '00000';

END

END PROCEDURE
DOCUMENT
'AUTOR: Casanova Edeza Hector Juan',
'Proyecto: Alta Única',
'Descripcion: GUARDA REGISTRO EN BITACORA.',
'Fecha: 2011/12/26',
'Version: 20111226.1554',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_au_validanomarchivo_pba(psEmpresa VARCHAR(3), psNomArchivo VARCHAR(15) )

RETURNING VARCHAR(5) AS CodRetorno;

--****************************************************************************************************
-- DESCRIPCION: VALIDA EL NOMBRE DE ARCHIVO DE ENVIOS DE TARJETAS COPPEL
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 23/12/2011
-- BD: bdiTarCop
-- SISTEMA : Inventario de Tarjetas Alta Unica.
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vsFlagSoloNumeros VARCHAR (1);
DEFINE vsCodRetorno VARCHAR (5);

DEFINE viSqlError INTEGER;

/* INICIALIZACION DE VARIABLES */
LET vsFlagSoloNumeros = '';
LET vsCodRetorno = '00000';

LET viSqlError = 0;

BEGIN

  ON EXCEPTION SET viSqlError    --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN viSqlError;

    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/conciliacion/cargarsurt.txt";
	--TRACE ON;
    --set explain on;
	
	--S2011100301.dat
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	EXECUTE PROCEDURE BdiTarjCop:"informix".sp_EsNumerico (SUBSTR(psNomArchivo, 2,10)) INTO vsFlagSoloNumeros;


	IF (LENGTH ( TRIM(psNomArchivo)) <> 15 )  THEN --EL NOMBRE DEL ARCHIVO NO POSEE LA EXTENCION CORRESPONDIENTE
		LET vsCodRetorno = '00001';
		
	ELIF ((SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 1 FOR 1) <> 'S') AND (SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 1 FOR 1) <> 'G')) THEN -- NO ES ARCHIVO DE SURTIDO
		LET vsCodRetorno = '00002';
		
	ELIF ( vsFlagSoloNumeros <> 'V' ) THEN --VALIDA QUE LA FECHA DEL ARCHIVO CONTENGA UNICAMENTE NUMEROS
		LET vsCodRetorno = '00003';
	
	ELIF ((SUBSTR(psNomArchivo, 2,4)::INTEGER < 1900) OR (SUBSTR(psNomArchivo, 2,4)::INTEGER > 2900)) THEN --SE VALIDA QUE EL ANO SEA CORRECTO
		LET vsCodRetorno = '00004';	
	
	ELIF ((SUBSTR(psNomArchivo, 6,2)::INTEGER < 1) OR (SUBSTR(psNomArchivo, 6,2)::INTEGER > 12)) THEN --SE VALIDA QUE EL MES SEA CORRECTO
		LET vsCodRetorno = '00005';	
	
	ELIF  ((SUBSTR(psNomArchivo, 8,2)::INTEGER < 1) OR (SUBSTR(psNomArchivo, 8,2)::INTEGER > 31)) THEN --SE VALIDA QUE EL DIA SEA CORRECTO
		LET vsCodRetorno = '00006';

	ELIF (SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 12 FOR 4) <> '.DAT') THEN -- NO ES ARCHIVO DE EXTENCION DAT
		LET vsCodRetorno = '00007';
	
	ELIF NOT EXISTS (SELECT Empresa FROM BdiTarjCop:"informix".InventarioTarCop WHERE Empresa = psEmpresa ) THEN  --NO EXISTE LA EMPRESA PROPORCIONADA
		LET vsCodRetorno = '00008';	
		
	ELIF EXISTS ( SELECT NomArchivo FROM BdiTarjCop:"informix".BitacoraTarCop WHERE NomArchivo = psNomArchivo AND CodRetorno = '00000') THEN --CHECA QUE EL ARCHIVO NO FUE PROCESADO ANTERIORMENTE.
		LET vsCodRetorno = '00009';
		
	ELSE --OK
		LET vsCodRetorno = '00000';
		
	END IF ;

	RETURN vsCodRetorno;

END

END PROCEDURE
DOCUMENT
'AUTOR: Casanova Edeza Hector Juan',
'Proyecto: Alta Única',
'Descripcion: VALIDA EL NOMBRE DE ARCHIVO DE ENVIOS DE TARJETAS COPPEL.',
'Fecha: 2011/12/23',
'Version: 20111223.1700',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_reversatarjetascoppel(
cEmpresa CHAR(3),
cSucursal CHAR(4),
iNumEnvio INTEGER,
cTarjetaIni CHAR(16),
cTarjetaFin CHAR(16),
cTipoTarjeta CHAR(1)
)

RETURNING CHAR(5) AS cCodRet;


DEFINE iCantidadRec INTEGER;
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE iCantRango INTEGER;
DEFINE dFechaActCU DATETIME YEAR TO FRACTION(1);
DEFINE dFechaActual DATETIME YEAR TO FRACTION(1); 


DEFINE cCvesucursal CHAR(4);
DEFINE cEnvioDisponible CHAR(1);
DEFINE iExistencia	INTEGER;
DEFINE cRangoIni	CHAR(16);
DEFINE cRangoFin	CHAR(16);
DEFINE iConsumo		INTEGER;

LET iCantidadRec = 0;
LET iSqlErr = 0;
LET cCodRet = '';
LET iCantRango = 0;
LET dFechaActCU = CURRENT;
LET dFechaActual = CURRENT;

LET cCvesucursal = '';
LET cEnvioDisponible = '';
LET iExistencia = 0;
LET cRangoIni = '';
LET cRangoFin = '';
LET iConsumo = 0;



BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
    IF iSqlErr <> 0 THEN
	LET cCodRet = iSqlErr;
	RETURN cCodRet;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/Alexis/144/sp_reversatarjetascoppel.out";
--TRACE ON;


SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--Obtiene fecha de activacion de sucursal que recibira lote
SELECT LIMIT 1 fechaactcu INTO dFechaActCU FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = cEmpresa AND cvesucursal = cSucursal;
--Obtiene fecha actual
SELECT LIMIT 1 CURRENT INTO dFechaActual FROM bditarjcop:"informix".sucursalescajaunica;
--Verifica que la fecha de activacion de sucursal sea menor o igual al a fecha actual.
IF(dFechaActCU <= dFechaActual)THEN
	--Verifica si existe la empresa proporcionada.
	SELECT LIMIT 1 empresa INTO cEmpresa FROM bditarjcop:"informix".inventariotarcop WHERE empresa = cEmpresa;
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				--La empresa proporcionada no existe.
				LET cCodRet = '00101';
	ELSE
		--Verifica si la clave de sucursal proporcionada cuenta con un inventario de tarjetas.
		SELECT LIMIT 1 cvesucursal INTO cCvesucursal FROM bditarjcop:"informix".inventariotarcop WHERE cvesucursal = cSucursal;
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				--La sucursal no cuenta con un inventario de tarjetas.
				LET cCodRet = '00102';
		ELSE
			--Verifica que exista un inventario correpondiente a la sucursal y al tipo de tarjeta proporcionados por el sistema Caja Ãnica de Sucursal.
			SELECT LIMIT 1 empresa, cvesucursal, consumo, existencia, tipotarjeta 
					INTO cEmpresa, cCvesucursal, iConsumo, iExistencia, cTipoTarjeta 
					FROM bditarjcop:"informix".inventariotarcop
					WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND tipotarjeta = cTipoTarjeta;
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					--No existe un inventario correpondiente a la sucursal y al tipo de tarjeta
					LET cCodRet = '00103';
			ELSE	
				LET iCantRango = (cTarjetaFin - cTarjetaIni) + 1;
				--Valida que la cantidad del rango de tarjetas corresponda con la cantidad de tarjetas recibidas.
				SELECT LIMIT 1 cantidadrec INTO iCantidadRec FROM bditarjcop:"informix".EnviosTarCop 
				WHERE cvesucursal = cSucursal AND numenvio = iNumEnvio AND rangoini = cTarjetaIni 
				AND rangofin = cTarjetaFin;
				
				IF(iCantRango = iCantidadRec)THEN
					--Verifica que el envio corresponda a la sucursal mediante la clave de la empresa, la clave de la sucursal, el numero del envio y tipo de tarjeta.
					SELECT LIMIT 1 empresa, cvesucursal, tipotarjeta, numenvio, cantidadrec, rangoini, rangofin 
					INTO cEmpresa, cCvesucursal, cTipoTarjeta, iNumEnvio, iCantidadRec, cRangoIni, cRangoFin
					FROM bditarjcop:"informix".EnviosTarCop WHERE empresa = cEmpresa AND cvesucursal = cSucursal
					AND tipotarjeta = cTipoTarjeta AND numenvio = iNumEnvio AND cantidadrec = iCantidadRec 
					AND rangoini = cTarjetaIni AND rangofin = cTarjetaFin;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						--El envio no corresponde a la sucursal y por lo tanto no puede ser aÃ±adido al inventario de esta.
						LET cCodRet = '00105';
					ELSE	
						--Verifica que el envio no se encuentre marcado como "Activo".
						SELECT LIMIT 1 EnvioDisponible INTO cEnvioDisponible FROM bditarjcop:"informix".EnviosTarCop WHERE cvesucursal = cSucursal AND numenvio = iNumEnvio AND EnvioDisponible = 'A' AND tipotarjeta = cTipoTarjeta AND rangoini = cTarjetaIni AND rangofin = cTarjetaFin;
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							--El envio ya fue registrado anteriormente.
							LET cCodRet = '00106';
						ELSE	
							SELECT LIMIT 1 cantidadrec INTO iCantidadRec FROM bditarjcop:"informix".EnviosTarCop WHERE cvesucursal = cSucursal AND numenvio = iNumEnvio AND tipotarjeta = cTipoTarjeta AND rangoini = cTarjetaIni AND rangofin = cTarjetaFin;
							UPDATE bditarjcop:"informix".InventarioTarCop SET existencia = existencia - iCantidadRec WHERE tipotarjeta = cTipoTarjeta AND empresa = cEmpresa
							AND cvesucursal = cSucursal;
							UPDATE bditarjcop:"informix".EnviosTarCop SET EnvioDisponible = "P", FechaRec = CURRENT, empleadorec = "" WHERE numenvio = iNumEnvio
							AND tipotarjeta = cTipoTarjeta AND empresa = cEmpresa AND cvesucursal = cSucursal AND rangoini = cTarjetaIni AND rangofin = cTarjetaFin;
							--Exito de la recepcion del envio
							LET cCodRet = '00000';
						END IF;
					END IF;
				ELSE
					--La cantidad del rango de tarjetas no corresponde con la cantidad de tarjetas recibidas.
					LET cCodRet = '00104';
				END IF;
			END IF;
		END IF;
	END IF;
ELSE
	--La fecha de activacion de sucursal es mayor a la actual.
	LET cCodRet = '00100';
END IF;
RETURN cCodRet;

END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: procedimiento para la reversiÃ³n del proceso de recepciÃ³n de tarjetas Coppel',
'ELABORO: OSCAR ALEXIS IBARRA VERDUGO',
'SOLICITO: Abraham Narvaez', 
'FECHA: 28/11/2016',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_validastatustarjcoppel (pEmpresa char(3), 
											pNumTarjeta char(9), 
											pSucursal char(4), 
											pNumEnvio int )  

   -- DATOS A REGRESAR --
        RETURNING
        char(4),    -- Codigo de retorno
		char(1);    --status de la tarjeta
		
		    -- VARIABLES --
        DEFINE vCodRet  char(4);
		DEFINE Status   char(1);
		DEFINE iSqlErr  SMALLINT;
		
		
		     -- INICIALIZACION DE VARIABLES --
        LET vCodRet  = "0000";
        LET Status = "";
		LET iSqlErr = 0;
		
BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				let vCodRet = iSqlErr;
				RETURN vCodRet,'';
			END IF ;
		END EXCEPTION 

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    --set debug file to '/tmp/sp_validastatustarjcoppel.out';
    --trace on;

		
		IF(pEmpresa<>"" AND pNumTarjeta <> "" AND pSucursal<>"") THEN
		
				SELECT estatustarjeta  INTO  Status
				FROM bditarjcop: "informix".tarjetasnumtarcop 
				where empresa=pEmpresa and cvesucursal=pSucursal and numenvio=pNumEnvio and numtarjeta=pNumTarjeta;
				
				 IF DBINFO('sqlca.sqlerrd2') = 0 THEN
		          LET vCodRet = '1710'; -- tarjeta no existe
				 END IF
		Else
		  LET vCodRet  = "0001"; 
		End IF
		
		RETURN vCodRet, Ltrim(Status);
END
END PROCEDURE
DOCUMENT  "Version 1.00.000",
'NOMBRE: Alvarado Verdugo Jesus Alberto',
'Folio:  RQM 06 220-2 - ADEMDUM- Control y Registro de tarjetas en Sucursal',
'DESCRIPCION: te regresa el status de tarjetas coppel para actualizar la tabla Vtarjetas ',   
'Peticiones involucradas: 144 - ControlRegistrTarjetasSucursal',     
'FECHA: 06-02-2018',
'BD: BDITARJCOP';

CREATE PROCEDURE  "informix".sp_consultarangotarjetascoppel(cEmpresa CHAR(3),cSucursal CHAR(4),iEnvio INTEGER,cTarjetaini CHAR(16),cTarjetafin CHAR(16),iCuantos SMALLINT)
RETURNING 	CHAR (5) AS codRet, CHAR(9) AS numTarjeta;
		
	DEFINE cCodRetorno CHAR(5);
	DEFINE cNumTarjeta CHAR(9);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRetorno = '00000';
	LET cNumTarjeta = '';

	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				let cCodRetorno = iSqlErr;
				RETURN cCodRetorno,'';
			END IF ;
		END EXCEPTION ;
		
		--SET DEBUG FILE TO "/respaldosbd/Ismael/sp_conssolicitudescredito2.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	
		IF (cEmpresa = '' AND cSucursal = '' AND iEnvio = 0 AND cTarjetaini = '' AND cTarjetafin = '') THEN
			--cuando los valores estan vacios mando codigo de retorno 00001
			LET cCodRetorno = '00001';
			RETURN cCodRetorno,'';			
		ELSE
			---consulta de paginado
			FOREACH
				SELECT skip iCuantos numtarjeta
				INTO cNumTarjeta
				FROM bditarjcop: "informix".tarjetasnumtarcop
				WHERE empresa = cEmpresa AND cvesucursal = cSucursal AND numenvio = iEnvio AND numtarjeta BETWEEN cTarjetaini AND cTarjetafin
						
				RETURN cCodRetorno,cNumTarjeta WITH RESUME;
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRetorno = '00002';
				RETURN cCodRetorno, '';
			END IF;
		END IF;
	END
END PROCEDURE
DOCUMENT
'Autor: 97343331 Ismael Lizarraga',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 29-11-2016',
'ModificaciÃ³n: Se crea procedimiento para consultar rango de tarjetas Coppel recibidas',
'Sustento: 144.1 RQM 06 220 Control y Registro de Tarjetas en Sucursal-Contrato',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

CREATE PROCEDURE "informix".sp_esnumerico (psCadena CHAR (20))
	RETURNING CHAR (1) AS Munerico;

--****************************************************************************************************
-- DESCRIPCION:  VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS
-- AUTOR :Martha Aguirre
-- FECHA : 19/08/2008
-- BD: bdinteg
--***************************************************************************************************

	/*  DEFINICION DE VARIABLES */
	DEFINE vsRespuesta CHAR (1);
	DEFINE visqlerr INTEGER;
	
	/* INICIALIZACION DE VARIABLES */
	LET vsRespuesta = 'F';
	LET visqlerr = 0;
	
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
			IF visqlerr = -1213 THEN
				LET vsRespuesta = 'F'; 
			ELSE
				LET vsRespuesta = ' '; 
			END IF;
			RETURN vsRespuesta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/sp_esnumerico.out";
		--TRACE ON;
		
		IF (psCadena >= 0) THEN 
			LET vsRespuesta = 'V';
		ELSE
			LET vsRespuesta = 'F';
		END IF  ;
		
		RETURN vsRespuesta ;
		
	END
END PROCEDURE;