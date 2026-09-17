CREATE PROCEDURE "informix".sp_buscaarchivo_tef(pUsuario CHAR(8), pIdFuncion CHAR(10), pRuta CHAR(100), pNombreArchivo CHAR(50))
		RETURNING CHAR(5)  AS codret,
				  CHAR(1) AS existearchivo;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE FlagExiste CHAR(1);
	DEFINE bTransacInteract BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET FlagExiste = '';
	LET bTransacInteract = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, FlagExiste;
		END EXCEPTION;
		ON EXCEPTION IN (-535)
			LET bTransacInteract = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
				
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_buscaarchivo_tef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRuta = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, FlagExiste;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, FlagExiste;
		END IF;
		
		
				
		BEGIN WORK;
		
		IF bTransacInteract = 'f' THEN
			COMMIT WORK;
		END IF;
		
		---Bandera   *** V > Existe el Archivo en la Ruta, *** F > No existe el Archivo
		EXECUTE PROCEDURE bditef:"informix".sp_tef_buscararchivo(pRuta, pNombreArchivo)
		INTO cCodRetSp, FlagExiste;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_buscararchivo';
		END IF;
		
		IF bTransacInteract = 't' THEN
				BEGIN WORK;
		END IF;
		
		RETURN cCodRet, FlagExiste;			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 20/11/2015',
'DESCRIPCION: PROCEDIMIENTO PARA BUSCAR UN ARCHIVO EN UNA RUTA PROPORCIONADA.',
'FUNCIONALIDAD: EnvÃ­o/RecepciÃ³n Archivos Bancoppel - Cecoban', 
'MODULO: TEF',
'BD: bditef';

CREATE PROCEDURE "informix".sp_eliminaarchivo_tef(pUsuario CHAR(8), pIdFuncion CHAR(10), pRuta CHAR(100), pNombreArchivo CHAR(50))
		RETURNING CHAR(5)  AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE vsCadSql CHAR(500);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET vsCadSql = "";
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		ON EXCEPTION IN (-668)
			RETURN cCodRet;
		END EXCEPTION;
		
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_eliminaarchivo_tef.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRuta = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		--Borra el archivo temporal.
        LET vsCadSql = '' ;
        LET vsCadSql = 'rm ' || TRIM(pRuta) || pNombreArchivo;
        SYSTEM vsCadSql;
		
		
		RETURN cCodRet;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 20/11/2015',
'DESCRIPCION: PROCEDIMIENTO PARA ELIMINAR UN ARCHIVO EN UNA RUTA PROPORCIONADA.',
'FUNCIONALIDAD: EnvÃ­o/RecepciÃ³n Archivos Bancoppel - Cecoban', 
'MODULO: TEF',
'BD: bditef';

CREATE PROCEDURE "informix".sp_tef_buscararchivo(psRuta VARCHAR(100), psNombreArchivo VARCHAR(50))
RETURNING CHAR(5) AS CodRet, CHAR(1) AS FlagExiste; ---Bandera   *** V > Existe el Archivo en la Ruta, *** F > No existe el Archivo

--****************************************************************************************************
-- DESCRIPCION:  PROCEDIMIENTO PARA BUSCAR UN ARCHIVO EN UNA RUTA PROPORCIONADA.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 10/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************


---DECLARACIONES
DEFINE vsCodRet          CHAR(5);
DEFINE viSqlErr          INTEGER;
DEFINE viSamErr          INTEGER;

DEFINE vsFlagExiste      CHAR(1);
DEFINE vsCadSql          LVARCHAR (500);
DEFINE vsLinea           VARCHAR(50);
DEFINE cHora             CHAR(8);
DEFINE cFechaArchivoOUT	 CHAR(15);
DEFINE iTemporales		 SMALLINT;
DEFINE iPaso			 SMALLINT;


---INICIALIZACIONES
LET iTemporales			= 0;
LET iPaso				= 0;
LET vsCadSql             = "";
LET vsFlagExiste         = "F";
LET vsLinea              = "";
LET cHora                = TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
LET cFechaArchivoOUT     = YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';


BEGIN

ON EXCEPTION
	SET viSqlErr, viSamErr
	IF viSqlErr <> 0 THEN
		LET vsCodRet = viSqlErr;
	END IF;
	
	RETURN vsCodRet,NULL;
END EXCEPTION;

ON EXCEPTION IN(-668) SET viSqlErr
	IF iTemporales = 1 AND iPaso <> 2 THEN 
		LET vsCodRet = viSqlErr;
		RETURN vsCodRet,NULL;
	END IF;
END EXCEPTION WITH RESUME;


	--SET DEBUG FILE TO "/informix/Ingrid/sp_tef_buscararchivo.out";
	--TRACE ON;

	LET vsCodRet = '00000';

	IF (NVL(psRuta,'') = '') THEN --VALIDA KE LA RUTA CONTENGA INFORMACION
		LET vsFlagExiste = NULL;
		LET vsCodRet = '00750';
	ELIF (NVL(psNombreArchivo,'') = '') THEN --VALIDA KE EL NOMBRE DE ARCHIVO CONTENGA INFORMACION
		LET vsFlagExiste = NULL;
		LET vsCodRet = '00751';
	ELSE

		--- BORRAR LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
		IF (EXISTS (SELECT tabname FROM systables WHERE tabname = 'tef_tmp_busca_archivo')) THEN
			DROP TABLE "informix".tef_tmp_busca_archivo;
		END IF;

		--- CREAR LA TABLA DE TRABAJO
		CREATE TABLE "informix".tef_tmp_busca_archivo
		(linea LVARCHAR(50));

		--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
		LET iPaso = 1;
		LET vsCadSql = 'ls ' || TRIM(psRuta) || ' > ' || TRIM(psRuta) || 'buscar.bus';
		SYSTEM vsCadSql;		
		LET iTemporales = 1;
		
		LET iPaso = 2;
		LET vsCadSql = 'chmod 777 ' || TRIM(psRuta) ||'buscar.bus';
		SYSTEM vsCadSql; 
		
		LET iPaso = 3;
		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO  *.SQL
		LET vsCadSql = 'echo "LOAD FROM ' || TRIM(psRuta) || 'buscar.bus' || ' INSERT INTO tef_tmp_busca_archivo" > '|| TRIM(psRuta) ||TRIM(cFechaArchivoOUT)|| 'EjecutaScripts_sp_Tef_BuscarArchivo.sql';
		SYSTEM vsCadSql;
		
		--RAISE EXCEPTION -668, 0, 'PRUEBA';
		LET iPaso = 4;
		LET vsCadSql = 'chmod 777 ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaScripts_sp_Tef_BuscarArchivo.sql';
		SYSTEM vsCadSql;

		LET iPaso = 5;
		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		--- PRODUCCION 
		LET vsCadSql = '/ifxsif01/bin/dbaccess bditef ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)|| 'EjecutaScripts_sp_Tef_BuscarArchivo.sql > '||TRIM(psRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaScripts_sp_Tef_BuscarArchivo.out 2>&1'; 
		
		--- DESARROLLO
		--LET vsCadSql = '/informix/bin/dbaccess bditef ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)|| 'EjecutaScripts_sp_Tef_BuscarArchivo.sql > '||TRIM(psRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaScripts_sp_Tef_BuscarArchivo.out 2>&1'; 
		SYSTEM vsCadSql;
		
		LET iPaso = 6;
		LET vsCadSql = 'chmod 777 ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaScripts_sp_Tef_BuscarArchivo.out';
			SYSTEM vsCadSql ;			
			
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--- CICLO PARA BARRER  LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
		FOREACH
			SELECT linea
			INTO vsLinea
			FROM "informix".tef_tmp_busca_archivo

			IF vsLinea = psNombreArchivo THEN
				LET vsFlagExiste = "V";
				EXIT FOREACH;
			END IF

		END FOREACH

		DROP TABLE tef_tmp_busca_archivo;

    	--Borra el archivo temporal buscar.bus.
		LET iPaso = 7;
    	LET vsCadSql = 'rm ' || TRIM(psRuta) || 'buscar.bus';
        SYSTEM vsCadSql;
		
    	--Borra el archivo temporal EjecutaScripts_sp_Tef_BuscarArchivo.sql.
		LET iPaso = 8;
    	LET vsCadSql = 'rm ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)|| 'EjecutaScripts_sp_Tef_BuscarArchivo.sql';
    	SYSTEM vsCadSql;
		
		--Borra el archivo temporal EjecutaScripts_sp_Tef_BuscarArchivo.out		
		LET iPaso = 9;
		LET vsCadSql = 'rm ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)|| 'EjecutaScripts_sp_Tef_BuscarArchivo.out';
		SYSTEM vsCadSql;

	END IF;

	RETURN vsCodRet, vsFlagExiste;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCEDIMIENTO PARA BUSCAR UN ARCHIVO EN UNA RUTA PROPORCIONADA.',
'Fecha: 2011/03/10',
'Version: 20110310.1535',
'BD: BdiTef',
'Modifico: Ingrid Pamela Cázarez Villegas',
'Fecha: 2016/02/18',
'Descripcion: Se modifica para concatenar fechas en los archivos .sql y .out generados para facilitar el seguimiento de incidencias',
'Ademas, se les asignan privilegios 777 a los mismos archivos para evitar errores de uso compartido con los usuarios que participan en TEF',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_bitacora(psTipoProceso CHAR(1), pdtFechaProceso DATE, psCveProceso VARCHAR(20), psDescripcion CHAR(60), psEstatus CHAR(1), psCodRet CHAR(5), psUsuario CHAR(8), psNomSPLlamado VARCHAR(50), psNomArchivo VARCHAR(20), psFechaPres CHAR(8), psCvEstatus CHAR(2))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- Descripcion:  PROCEDIMIENTO PARA INSERTAR EN LA TABLA TEF_PROCESOS Y TEF_ERRORES PARA REGISTRAR EL ESTADO DEL PROCESO.',
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 09/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

---DECLARACIONES
DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;

DEFINE vsDescMensajeError VARCHAR(100);
DEFINE viTotReg INTEGER;
DEFINE vdtFecha_Proceso DATE;
DEFINE vsFechaAplicacion CHAR(8);
DEFINE vdFechaAplicacion DATE;

---INICIALIZACIONES
LET vsCodRet = '00000';
LET vsDescMensajeError = "";
LET viTotReg = 0;
LET vdFechaAplicacion = CURRENT;
LET vsFechaAplicacion = '';

BEGIN

ON EXCEPTION
	SET viSqlErr, viSamErr
	IF viSqlErr <> 0 THEN
		LET vsCodRet = viSqlErr;
	END IF;

	RETURN vsCodRet;
END EXCEPTION;

--SET DEBUG FILE TO "/dbexport/TEF/trace/sp_tef_bitacora.out";
--TRACE ON;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(psFechaPres)INTO vsCodRet;

	IF (vsCodRet = '00000') THEN
		LET vdtFecha_Proceso = SUBSTR(psFechaPres,5,2) || "/" || SUBSTR(psFechaPres,7,2) || "/" || SUBSTR(psFechaPres,1,4);
	ELSE
		LET vdtFecha_Proceso = CURRENT;
	END IF;

	LET vsCodRet = '00000';

	--- VALIDA QUE SEA UNA TIPO DE OPERACION AUTOMATICA O MANUAL
	IF UPPER(psTipoProceso) NOT IN ("A","M") THEN
		EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("00400") INTO vsCodRet, vsDescMensajeError;
		RETURN vsCodRet;
		LET vsCodRet = '00900'; --TIPO DE OPERACION DESCONOCIDO
	ELSE
	
		--- VALIDA QUE CUANDO EL CODIGO DE RETORNO LO MANDE EN CEROS EL PROCESO ESTA TRABAJANDO SIN ERRORES Y REALIZA UNA NUEVA INSERCION CUANDO ES LA PRIMERA VEZ O ACTUALIZA LOS DATOS SI YA EXISTE
		IF psCodRet = "00000" THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			IF NOT EXISTS (SELECT Cve_Proceso FROM BdiTef:"informix".Tef_Procesos WHERE Cve_Proceso = psCveProceso AND  Fecha_Proceso = vdtFecha_Proceso AND Tipo_Proceso = psTipoProceso) THEN
				INSERT INTO BdiTef:"informix".Tef_Procesos (Tipo_Proceso,Fecha_Proceso,Cve_Proceso,Descripcion,Estatus,Cod_Retorno,User_Insert,Fecha_Insert)
				VALUES (UPPER(psTipoProceso),vdtFecha_Proceso,psCveProceso,psDescripcion,psEstatus,psCodRet,psUsuario,CURRENT);
			ELSE
				UPDATE BdiTef:"informix".Tef_Procesos
				SET Descripcion = psDescripcion, Estatus = psEstatus, Cod_Retorno = psCodRet, User_Insert = psUsuario
				WHERE Cve_Proceso = psCveProceso AND Tipo_Proceso = psTipoProceso AND Fecha_Proceso = vdtFecha_Proceso;
			END IF
		ELSE
		--- CUANDO TRAE UN CODIGO DE RETORNO DIFERENTE DE CEROS ACTUALIZA EN LA TABLA Tef_Procesos E INSERTA EN LA TABLA Tef_Errores
			UPDATE BdiTef:"informix".Tef_Procesos
			SET Descripcion = psDescripcion, Estatus = psEstatus, Cod_Retorno = psCodRet
			WHERE Cve_Proceso = psCveProceso AND Tipo_Proceso = psTipoProceso AND Fecha_Proceso = vdtFecha_Proceso;

			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT LIMIT 1 Descripcion
			INTO vsDescMensajeError
			FROM BdiTef:"informix".Tef_Cat_Rechazos
			WHERE Cve_Rechazo::INTEGER = psCodRet::INTEGER;

			LET vsCodRet = psCodRet;

			IF vsDescMensajeError IS NULL THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(psCodRet) INTO vsCodRet, vsDescMensajeError;
			END IF;

			INSERT INTO Tef_Errores(fecha_error,hora_error,cod_error,Nombre_Arch,sp_llamado,mensaje_error,User_Insert,Fecha_Insert)
			VALUES (CURRENT,CURRENT HOUR TO FRACTION,NVL(psCodRet,''),NVL(psNomArchivo,''),NVL(psNomSPLlamado,''),NVL(vsDescMensajeError,''),psUsuario,CURRENT);

		END IF;

		IF psCvEstatus <> "11" THEN
			IF psCvEstatus = "02" THEN
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				SELECT FIRST 1 NVL(Num_Operaciones,'0')::INTEGER
				INTO viTotReg
				FROM BdiTef:"informix".Tef_Cce_Sumario
				WHERE Nombre_Arch = psNomArchivo
                AND Fecha_Presentacion = psFechaPres;

				--SELECT  LIMIT 1 SUBSTR(Fecha_Aplica,5,2)||SUBSTR(Fecha_Aplica,7,2)||SUBSTR(Fecha_Aplica,1,4)
				SELECT  FIRST 1 NVL(Fecha_Aplica,'')
				INTO vsFechaAplicacion
				FROM BdiTef:"informix".Tef_Cce_Detalle
				WHERE Nombre_Arch = psNomArchivo
                AND Fecha_Presentacion = psFechaPres;

			ELSE
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				SELECT FIRST 1 NVL(Num_Operaciones,'0')::INTEGER
				INTO viTotReg
				FROM BdiTef:"informix".Tef_Cce_Sumario_Paso
				WHERE Nombre_Arch = psNomArchivo
                AND Fecha_Presentacion = psFechaPres;
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				--SELECT  LIMIT 1 SUBSTR(Fecha_Aplica,5,2)||SUBSTR(Fecha_Aplica,7,2)||SUBSTR(Fecha_Aplica,1,4)
				SELECT  FIRST 1 NVL(Fecha_Aplica,'')
				INTO vsFechaAplicacion
				FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
				WHERE Nombre_Arch = psNomArchivo
                AND Fecha_Presentacion = psFechaPres;
			END IF;
			
			IF (NVL(vsFechaAplicacion,'') = '') THEN
				LET vsFechaAplicacion =  LPAD(YEAR(CURRENT),4,'0') || LPAD(MONTH(CURRENT),2,'0') ||  LPAD(DAY(CURRENT),2,'0');
			END IF;
			
			LET vdFechaAplicacion = SUBSTR(vsFechaAplicacion, 5,2)/*MES*/ || '/' || SUBSTR(vsFechaAplicacion, 7,2)/*DIA*/ || '/' || SUBSTR(vsFechaAplicacion, 1,4)/*ANO*/ ;
			
			IF viTotReg IS NULL THEN
				LET viTotReg = 0;
			END IF;

			IF (NOT EXISTS(SELECT Nombre_Arch FROM BdiTef:"informix".Tef_Cce_Archivos WHERE Nombre_Arch = psNomArchivo   AND Fecha_Presentacion = psFechaPres)) THEN
				
				LET vsFechaAplicacion = NVL(psNomArchivo, '') || ' ' ||
					NVL(psFechaPres, '') ||  ' ' ||
					NVL(vdFechaAplicacion, CURRENT) ||  ' ' ||
					NVL(psCveStatus, '')  ||  ' ' ||
					NVL(viTotReg, 0)  ||  ' ' ||
					NVL(psUsuario, '');
					
				INSERT INTO BdiTef:"informix".Tef_Cce_Archivos(Nombre_Arch,Fecha_Presentacion,Fecha_Aplicacion,Cve_Status,Tot_Registros,User_Insert,Fecha_Insert)
				VALUES (
					NVL(psNomArchivo, ''),
					NVL(psFechaPres, ''),
					NVL(vdFechaAplicacion, CURRENT),
					NVL(psCveStatus, ''),
					NVL(viTotReg, 0),
					NVL(psUsuario, ''),
					CURRENT);
			ELSE
				UPDATE BdiTef:"informix".Tef_Cce_Archivos
				SET Cve_Status = NVL(psCveStatus, ''), 
				Fecha_Aplicacion = NVL(vdFechaAplicacion, CURRENT), 
				User_Insert = NVL(psUsuario, ''), 
				Tot_Registros = NVL(viTotReg, 0)
				WHERE Nombre_Arch = psNomArchivo AND Fecha_Presentacion = psFechaPres;
			END IF;
		END IF;
	END IF;
	
RETURN vsCodRet;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCEDIMIENTO PARA INSERTAR EN LA TABLA TEF_PROCESOS Y TEF_ERRORES PARA REGISTRAR EL ESTADO DEL PROCESO.',
'Fecha: 2011/03/09',
'Version: 20110309.1044',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_buscararchivos_tef(psRuta VARCHAR(100))

RETURNING CHAR(5) AS CodRet, VARCHAR(50) AS NomArchivo;
--****************************************************************************************************
-- DESCRIPCION:  PROCEDIMIENTO PARA BUSCAR UN ARCHIVO EN UNA RUTA PROPORCIONADA.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA.
-- FECHA : 10/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

---DECLARACIONES
DEFINE vsCodRet           CHAR(5);
DEFINE viSqlErr           INTEGER;
DEFINE viSamErr           INTEGER;

DEFINE vsCadSql           LVARCHAR(500);
DEFINE vsLinea            VARCHAR(50);
DEFINE cHora              CHAR(8);
DEFINE cFechaArchivoOUT	  CHAR(15);
DEFINE iTemporales		  SMALLINT;
DEFINE iPaso			  SMALLINT;

---INICIALIZACIONES
LET iTemporales			  = 0;
LET iPaso				  = 0;
LET vsCadSql              = "";
LET vsLinea               = "";
LET cHora                 = TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
LET cFechaArchivoOUT      = YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';

BEGIN

ON EXCEPTION SET viSqlErr
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsLinea;
	END IF;
END EXCEPTION;

ON EXCEPTION IN(-668) SET viSqlErr
	IF iPaso NOT IN(6,7,8) THEN 
		LET vsCodRet = viSqlErr;
		RETURN vsCodRet,NULL;
	END IF;
END EXCEPTION WITH RESUME;
	
--SET DEBUG FILE TO "/informix/Ingrid/sp_buscararchivos_tef.out";
--TRACE ON;
	LET vsCodRet = '00000';
	IF (NVL(psRuta,'') = '') THEN --VALIDA QUE LA RUTA CONTENGA INFORMACION
		LET vsCodRet = '00001';
	ELSE--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO
		IF (EXISTS (SELECT tabname FROM systables WHERE tabname = 'tef_busca_archivos')) THEN
			TRUNCATE TABLE"informix".tef_busca_archivos;
		END IF;
		--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
		LET iPaso = 1;
		LET vsCadSql = 'ls ' || TRIM(psRuta) || ' > ' ||TRIM(psRuta) || TRIM(cFechaArchivoOUT) ||'.bus';
		SYSTEM vsCadSql;
		LET iTemporales = 1;
		
		--- SE LE ASIGNAN PERMISOS AL ARCHIVO
		LET iPaso = 2;
		LET vsCadSql = 'chmod 777 ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT) ||'.bus';
		SYSTEM vsCadSql;
		
		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET iPaso = 3;
		LET vsCadSql = 'echo "LOAD FROM ' || TRIM(psRuta) || TRIM(cFechaArchivoOUT) ||'.bus' || ' INSERT INTO tef_busca_archivos" > '|| TRIM(psRuta) || TRIM(cFechaArchivoOUT)|| '.sql';
		SYSTEM vsCadSql;
		
		--- SE LE ASIGNAN PERMISOS AL ARCHIVO
		LET iPaso = 4;
		LET vsCadSql = 'chmod 777 ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)||'.sql';
		SYSTEM vsCadSql ;
		
		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		--PRODUCCION
		LET iPaso = 5;
		LET vsCadSql = '/ifxsif01/bin/dbaccess bditef ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)|| '.sql > '||TRIM(psRuta) || TRIM(cFechaArchivoOUT)||'.out 2>&1'; 
		
		--DESARROLLO
		--LET vsCadSql = '/informix/bin/dbaccess bditef ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)|| '.sql > '||TRIM(psRuta)|| TRIM(cFechaArchivoOUT) ||'.out 2>&1'; 
		SYSTEM vsCadSql;
		
		--Borra el archivo de buscar.bus.
		LET iPaso = 6;
		LET vsCadSql = 'rm ' || TRIM(psRuta)|| TRIM(cFechaArchivoOUT) ||'.bus';
		SYSTEM vsCadSql;
		
		--Borra el archivo de .
		LET iPaso = 7;
		LET vsCadSql = 'rm ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)|| '.sql';
		SYSTEM vsCadSql;
		
		--Borra el archivo .out
		LET iPaso = 8;
		LET vsCadSql = 'rm ' || TRIM(psRuta) ||TRIM(cFechaArchivoOUT)|| '.out';
		SYSTEM vsCadSql;		
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		DELETE "informix".tef_busca_archivos 
		WHERE linea LIKE ('%.bus') OR linea LIKE ('%.sql') OR linea LIKE ('%.out')OR linea LIKE ('%.resp') OR linea LIKE ('%.bat');
		--- CICLO PARA BARRER  LA TABLA DE TRABAJO Y BUSCAR LOS NOMBRES DE ARCHIVOS
		FOREACH
			SELECT linea
			INTO vsLinea
			FROM "informix".tef_busca_archivos
			ORDER BY SUBSTR(TRIM(linea),9,4)||SUBSTR(TRIM(linea),7,2)||SUBSTR(TRIM(linea),5,2) DESC
			
			RETURN vsCodRet, vsLinea WITH RESUME;
		END FOREACH
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCEDIMIENTO PARA BUSCAR ARCHIVOS EN UNA RUTA PARAMETRIZADA.',
'Fecha: 2011/03/10',
'Version: 20110310.1535',
'Modifico: VICTOR HUGO NUNEZ',
'Descripcion: Se sustituyo el uso de la tabla temporal tef_tmp_busca_archivos',
'			  por una tabla fija.',
'Fecha: 2012/02/16',
'Version: 20120216.0840',
'BD: BdiTef',
'Modifico: Ingrid Pamela CÃ?Â¡zarez Villegas',
'Fecha: 2016/02/18',
'Descripcion: Se modifica para concatenar fechas en los archivos .sql y .out generados para facilitar el seguimiento de incidencias',
'Ademas, se les asignan privilegios 777 a los mismos archivos para evitar errores de uso compartido con los usuarios que participan en TEF',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_generaarchivo(piTipoArchivo INTEGER, psNombreArchivo CHAR(20), psFechaPres CHAR(8), psId CHAR(2))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  GENERA UN ARCHIVO DE INTERCAMBIO DE TEF
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 09/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************


DEFINE viSqlErr          INTEGER;
DEFINE vsRepositorio     CHAR(100);
DEFINE vsCodRet          CHAR(5);
DEFINE vsSQL             CHAR(2204);
DEFINE vsSQL1            CHAR(100);
DEFINE vsSQL2            CHAR(2004);
DEFINE vsSQL3            CHAR(100);
DEFINE vsArchTemp        CHAR(15);
DEFINE vsArchTemp1       CHAR(15);
DEFINE vsUsoFutBanc      CHAR(12);
DEFINE cHora             CHAR(8);
DEFINE cFechaArchivoOUT	 CHAR(15);
DEFINE iPaso			 SMALLINT;

LET viSqlErr             = 0;
LET vsRepositorio        = '';
LET vsCodRet             = '';
LET vsSQL                = '';
LET vsSQL1               = '';
LET vsSQL2               = '';
LET vsSQL3               = '';
LET vsArchTemp           = '';
LET vsArchTemp1          = '';
LET vsUsoFutBanc         = '';
LET cHora                = TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
LET cFechaArchivoOUT     = YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
LET iPaso				 = 0;

--SET DEBUG FILE TO "/home/systef/procesar/sp_tef_GeneraArchivo.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado.
	IF viSqlErr <> 0 THEN
	RETURN viSqlErr;
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--Se le quitan espacion en blanco a nombre de archivo
LET psNombreArchivo = TRIM(psNombreArchivo);
IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso WHERE nombre_arch = psNombreArchivo)THEN
	IF EXISTS(SELECT cod_param FROM BdiTef:"informix".Tef_Parametros WHERE cod_param = psId)THEN
		IF (piTipoArchivo IN ('10','11','60','61','62','63')) THEN--VALIDA QUE EL TIPO DE ARCHIVO SEA VALIDO
		--((piTipoArchivo >= 60) AND (piTipoArchivo <= 63)) OR (piTipoArchivo = 11) )
			--Selecciona el repositorio del archivo a generar.
			SELECT valor INTO vsRepositorio FROM BdiTef:"informix".Tef_Parametros WHERE cod_param = psId;
			--Genera archivo.
			LET iPaso = 1;
			LET vsArchTemp = 'temporal.txt';
			LET vsArchTemp1 = 'temporal1.txt';
			LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT)|| TRIM (vsArchTemp) || ' DELIMITER ' || '''£''';
				
			
			IF ((piTipoArchivo = 60) OR (piTipoArchivo = 61) OR (piTipoArchivo = 10) OR (piTipoArchivo = 11)) THEN 
				--ARCHIVO 60  - 61 (422 CARACTERES)
				LET vsSQL2 = " SELECT tpo_registro || num_secuencia || cod_operacion || cve_banco || sentido || servicio || num_bloque || fecha_presentacion ||"
				|| " cod_divisa || cve_rechazo_bl || modalidad || '                                                                                                                                                                                                                                                                                                                                                                                                  Ø' FROM BdiTef:Tef_Cce_Encabezado_Paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'"
				|| " UNION"
				|| " SELECT tipo_registro || num_secuencia || cod_operacion || cod_divisa || fecha_trans || banco_presentador || banco_receptor || "
				|| " importe || uso_futuro_ccen || tipo_operacion || fecha_aplica || tipo_cta_ord || num_cta_ord || nombre_ord || rfc_ord || "
				|| " tipo_cta_rec || num_cta_rec ||nombre_rec || rfc_rec || ref_servicio || nombre_titular_serv || importe_iva || ref_numerica || "
				|| " ref_leyenda || clave_rastreo || motivo_dev || fecha_pres_ini ||Solicitud_Confirmacion|| '           Ø' "
				|| " FROM BdiTef:Tef_Cce_Detalle_Paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'" 
				|| " UNION"
				|| " SELECT tipo_registro || num_secuencia || cod_operacion || num_bloque || num_operaciones || "
				|| " imp_operaciones || '                                                                                                                                                                                                                                                                                                                                                                                           Ø' FROM BdiTef:Tef_Cce_Sumario_Paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'";
				
			ELIF (piTipoArchivo = 62) THEN 
				--Archivo 62 (422 CARACTERES) --CAMBIA DETALLE + 2 CAMPOS
				LET vsSQL2 = " SELECT tpo_registro||num_secuencia||cod_operacion||cve_banco||sentido||servicio||num_bloque||fecha_presentacion||"
				|| "cod_divisa||cve_rechazo_bl||modalidad||'                                                                                                                                                                                                                                                                                                                                                                                                                      Ø' FROM BdiTef:Tef_Cce_Encabezado_Paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'"
				|| " UNION"
				|| " SELECT tipo_registro||num_secuencia||cod_operacion||cod_divisa||fecha_trans||banco_presentador||banco_receptor||"
				|| " importe||uso_futuro_ccen||tipo_operacion||fecha_aplica||tipo_cta_ord||num_cta_ord||nombre_ord||rfc_ord||"
				|| " tipo_cta_rec||num_cta_rec||nombre_rec||rfc_rec||ref_servicio||nombre_titular_serv||importe_iva||ref_numerica||"
				|| " ref_leyenda||clave_rastreo||motivo_dev||fecha_pres_ini||Solicitud_Confirmacion||LPAD(REF_CONFIRMACION,30,' ')||' Ø' /* REF_CONFIRMACION (30) + Uso_Futuro_Cce(1) */ "
				|| " FROM BdiTef:Tef_Cce_Detalle_Paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'"
				|| " UNION"
				|| " SELECT tipo_registro||num_secuencia||cod_operacion||num_bloque||num_operaciones||"
				|| " imp_operaciones || '                                                                                                                                                                                                                                                                                                                                                                                                               Ø' FROM BdiTef:Tef_Cce_Sumario_Paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'";
				
				ELIF (piTipoArchivo = 63) THEN 
				--Archivo 63 (447 CARACTERES)
				LET vsSQL2 = " SELECT tpo_registro||num_secuencia||cod_operacion||cve_banco||sentido||servicio||num_bloque||fecha_presentacion||"
				|| " cod_divisa||cve_rechazo_bl||modalidad||'                                                                                                                                                                                                                                                                                                                                                                                                  Ø' FROM BdiTef:Tef_Cce_Encabezado_Paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'"
				|| " UNION"
				|| " SELECT tipo_registro||num_secuencia||cod_operacion||cod_divisa||fecha_trans||banco_presentador||banco_receptor||"
				|| " importe||uso_futuro_ccen||tipo_operacion||fecha_aplica||tipo_cta_ord||num_cta_ord||nombre_ord||"
				|| " rfc_ord||tipo_cta_rec||num_cta_rec||nombre_rec||rfc_rec||ref_servicio||nombre_titular_serv||"
				|| " importe_iva||ref_numerica||ref_leyenda||clave_rastreo||motivo_dev||fecha_pres_ini||Solicitud_Confirmacion||"
				--|| " '           '||LPAD(TRIM(Tasa_Tiie_Prom),7,'0')||LPAD(TRIM(Dias_Retraso),3,'0')||LPAD(TRIM(Imp_Tot_Int),15,'0')" 
				|| "'           Ø'"
				|| " FROM BdiTef:Tef_Cce_Detalle_Paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'"
				|| " UNION"
				|| " SELECT tipo_registro||num_secuencia||cod_operacion||num_bloque||num_operaciones||"
				|| " imp_operaciones|| '                                                                                                                                                                                                                                                                                                                                                                                           Ø' FROM BdiTef:Tef_Cce_Sumario_Paso WHERE nombre_arch = '"||psNombreArchivo||"' AND fecha_presentacion = '"||psFechaPres||"'";
			END IF;
			
			
			LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT)|| 'control_reporte.sql';
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL3 = TRIM(vsSQL3);
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
			--Verifica que no este vacia la consulta.
			LET iPaso = 2;
			IF ( vsSQL <> '' ) THEN
				SYSTEM vsSQL;
				
				--Permiso para la creacion de archivo.
				LET iPaso = 3;
				LET vsSQL = 'chmod 777 ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT)|| 'control_reporte.sql' ;
				SYSTEM vsSQL ;
				
				LET vsSQL = '' ;
				--PRODUCCION
				LET iPaso = 4;
				LET vsSQL = '/ifxsif01/bin/dbaccess bditef ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT) ||'control_reporte.sql > '||TRIM(vsRepositorio)|| TRIM(cFechaArchivoOUT)|| 'control_reporte.out 2>&1';
				
				--DESARROLLO
			    --LET vsSQL = '/informix/bin/dbaccess bditef ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT) || 'control_reporte.sql > '||TRIM(vsRepositorio)|| TRIM(cFechaArchivoOUT)|| 'control_reporte.out 2>&1';
				SYSTEM vsSQL ;
				
				--Permiso para la creacion de archivo.
				LET iPaso = 5;
				LET vsSQL = 'chmod 777 ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT)|| 'control_reporte.out' ;
				SYSTEM vsSQL ;
				
				--Permiso para la creacion de archivo temporal.txt.
				LET iPaso = 6;
				LET vsSQL = 'chmod 777 ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT)|| TRIM (vsArchTemp) ;
				SYSTEM vsSQL ;
				
				--Borra el archivo de control.
				LET iPaso = 7;
				LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT)|| 'control_reporte.sql';
				SYSTEM vsSQL;
				
				--Borra el archivo control_reporte.out
				LET iPaso = 8;
				LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT)|| 'control_reporte.out';
				SYSTEM vsSQL;
				
				--Elimina el caracter delimitador '?'.
				LET iPaso = 9;
				LET vsSQL =  "sed 's/£$//g' " || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT) || TRIM (vsArchTemp) || " > " || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT) || TRIM (vsArchTemp1);
				SYSTEM vsSQL;
				
				--Permiso para la creacion de archivo temporal1.txt	
				LET iPaso = 10;
				LET vsSQL = 'chmod 777 ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT)|| TRIM (vsArchTemp1) ;
				SYSTEM vsSQL ;
				
				--Elimina el caracter delimitador 'x'.
				LET iPaso = 11;
				LET vsSQL =  "sed 's/Ø$//g' " || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT) || TRIM (vsArchTemp1) || " > " || TRIM(vsRepositorio) || TRIM (psNombreArchivo);
				SYSTEM vsSQL;
				
				LET iPaso = 12;
				LET vsSQL = 'cp ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo)  ||' '|| TRIM(vsRepositorio)|| TRIM (psNombreArchivo)  ||'.resp';
				SYSTEM vsSQL;

				/*LET iPaso = 13;
				LET vsSQL = 'grep -lr -e "1" ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo)  ||'.resp | xargs sed ''s/\\\\/\\/g'' > '|| TRIM(vsRepositorio) || TRIM (psNombreArchivo);
				SYSTEM vsSQL;  */                               
				
				--Borra el archivo temporal.
				LET iPaso = 13;
				LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT) || TRIM(vsArchTemp);
				SYSTEM vsSQL;
				
				--Borra el archivo temporal1.
				LET iPaso = 14;
				LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(cFechaArchivoOUT) || TRIM(vsArchTemp1);
				SYSTEM vsSQL;
				
				--Operacion exitosa "Archivo Generado".
				--se dan permiso a todos para el archivo 
				LET iPaso = 15;
				LET vsSQL = 'chmod 666 ' || TRIM(vsRepositorio) || TRIM (psNombreArchivo);
				SYSTEM vsSQL ;
				LET vsCodRet = '00000';
			ELSE
				--No fue posible generar el archivo.
				LET vsCodRet = '01002';
			END IF ;
		ELSE
			--EL TIPO DE ARCHIVO NO ES VALIDO.
			LET vsCodRet = '01003';
		END IF;
	ELSE
	--El Id proporcionado no fue localizado.
	LET vsCodRet = '01001';
	END IF;
ELSE
	--El nombre del archivo proporcionado no fue localizado.
	LET vsCodRet = '01000';
END IF;

RETURN vsCodRet;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: ESTE PROCEDIMIENTO SE ENCARGA DE PASAR/BORRAR LOS DATOS QUE SE ENCUENTRAN EN LAS TABLAS DE PASO A LAS TABLAS MAESTRAS EN BASE AL NOMBRE DE ARCHIVO Y LA FECHA.',
'Fecha: 2011/03/09',
'Version: 20110309.1400',
'BD: BdiTef',
'-------------------------------------------------------------------------------------------------',
'Modifico: Ingrid Pamela Cázarez Villegas',
'Fecha: 2016/02/18',
'Descripcion: Se modifica para concatenar fechas en los archivos .sql y .out generados para facilitar el seguimiento de incidencias',
'Ademas, se les asignan privilegios 777 a los mismos archivos para evitar errores de uso compartido con los usuarios que participan en TEF',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_cce_cedulausrmtto
(
	pOperacion    INTEGER,		-- 1 â Guardar, 2 â Eliminar o 3 - Consultar
	pNumEjecut    INTEGER,		-- Numero del ejecutivo.
	pNombreEjecut CHAR (100),   -- Nombre del ejecutivo.
	pFecha        DATE,			-- Fecha del sistema.
	pImagenRuta   CHAR (500)	-- Ruta de la imagen de la firma del ejecutivo.
)

RETURNING
	CHAR(5)  AS cod_ret,    --Codigo de retorno.
	CHAR(8)  AS num_ejecut, --Numero de ejecutivo.
	CHAR(50) AS nom_ejecut; --Nombre de ejecutivo.

DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);	
DEFINE cNumEjecut 	CHAR(9);
DEFINE cNomEjecut	CHAR(50);
DEFINE cRutaImg		CHAR (500);

LET cCodRet 	= '00001'; --Inicializado con error (parametros de entrada incorrectos), cambia a codigo de exito si termina el flujo.
LET cNumEjecut  = '';
LET cNomEjecut  = '';
LET iSqlErr 	=  0;
LET cRutaImg	= '';

	--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/40/sp_cce_cedulausrmtto.out';
	-- TRACE ON;
		
	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumEjecut, cNomEjecut;	
		END IF;
		END EXCEPTION;
			 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pOperacion, 0) NOT IN (1, 2, 3) THEN 
			RETURN cCodRet, cNumEjecut, cNomEjecut; --cod_ret = '00001'; "Numero de operacion incorrecto".
			
		ELSE
			--INSERTAR.
			IF   pOperacion = 1 AND NVL(pNumEjecut, 0) <> 0 AND NVL(pNombreEjecut, '') <> '' AND NVL(pFecha, '') <> '' THEN
				IF NOT EXISTS 
				(
					SELECT ejecutivo 
					FROM   "informix".cce_usuarios_cedula_contable
					WHERE  ejecutivo = pNumEjecut
				) THEN
				
					LET cRutaImg = TRIM(NVL(pImagenRuta, '')); --La insercion de imagen de firma es opcional de acuerdo con la peticion del cliente.
					
					IF cRutaImg <> '' THEN 
					
						INSERT INTO "informix".cce_usuarios_cedula_contable 
						(
							ejecutivo, nombre, firma_img, fecha_alta
						)
						VALUES
						(
							pNumEjecut, pNombreEjecut, FILETOBLOB(TRIM(cRutaImg), 'informix'), pFecha
						);	
						
							LET cCodRet = '00000'; 
							RETURN cCodRet, cNumEjecut, cNomEjecut; --cod_ret = '00000'; "Se ejecuto correctamente".
											
					ELSE
						
						INSERT INTO "informix".cce_usuarios_cedula_contable 
						(
							ejecutivo, nombre, firma_img, fecha_alta
						)
						VALUES
						(
							pNumEjecut, pNombreEjecut, NULL, pFecha
						);	
						
							LET cCodRet = '00000'; 
							RETURN cCodRet, cNumEjecut, cNomEjecut; --cod_ret = '00000'; "Se ejecuto correctamente".
						
					END IF;
				ELSE
					LET cCodRet = '00002'; 
					RETURN cCodRet, cNumEjecut, cNomEjecut; --cod_ret = '00002'; "Ya existe el ejecutivo que se desea guardar".
					
				END IF;		
				
			--ELIMINAR
			ELIF pOperacion = 2 AND NVL(pNumEjecut, 0) <> 0 THEN
				IF EXISTS 
				( 
					SELECT ejecutivo 
					FROM   "informix".cce_usuarios_cedula_contable
					WHERE  ejecutivo = pNumEjecut
				) THEN
					
					DELETE FROM "informix".cce_usuarios_cedula_contable
					WHERE ejecutivo = pNumEjecut;
						
					LET cCodRet = '00000';
					RETURN cCodRet, cNumEjecut, cNomEjecut; --cod_ret = '00000'; "Se ejecuto correctamente".
					
				ELSE
					LET cCodRet = '00003';
					RETURN cCodRet, cNumEjecut, cNomEjecut; --cod_ret = '00003'; "No existe ejecutivo que se desea eliminar".
					
				END IF;
			
			--CONSULTAR
			ELIF pOperacion = 3 THEN --Consultar ejecutivos, recupera numeros y nombres.			
				LET cCodRet = '00000';
				
				FOREACH
					SELECT   ejecutivo, nombre 
					INTO     cNumEjecut, cNomEjecut
					FROM     "informix".cce_usuarios_cedula_contable
					ORDER BY ejecutivo
					
						RETURN cCodRet, cNumEjecut, cNomEjecut WITH RESUME;
				END FOREACH;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00004';
					RETURN cCodRet, cNumEjecut, cNomEjecut; --cod_ret = '00004'; "No existen ejecutivos para consultar".				
				END IF;		
				
			ELSE				
				RETURN cCodRet, cNumEjecut, cNomEjecut; --cod_ret = '00001'; "Uno o mas parametros de entrada obligatorios viene(n) vacio(s)."				
				
			END IF;			
		END IF;		
	END
END PROCEDURE
DOCUMENT
'AUTOR: 96273763 - Antonio Cebreros Perez',
'FOLIO: 230142 - 40 - MejoraCedulaContChqs',
'DESCRIPCION: Guarda, elimina o consulta informacion en la tabla bditef:"informix".cce_usuarios_cedula_contable en base a parametros de entrada.',
'FECHA: 15/04/2015',
'BD: BDITEF';

CREATE PROCEDURE "informix".sp_tef_graba_cam_arch41
(pEjecutivo CHAR(8),
pNumero_registros INTEGER,
pImporte DECIMAL(14,2),
pCodigo_operacion INTEGER,
pClave_archivo  CHAR(30),
pNumero_archivo SMALLINT,
pModalidad INTEGER
)

RETURNING CHAR(6) AS COD_RET,
		  CHAR(80) AS MENSAJERETORNO;

DEFINE iNumeroArch 		INTEGER;
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRetorno  CHAR(80);
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);

LET iNumeroArch     = 0;		
LET cCodRet		    = "000000";  
LET cMensajeRetorno = "PROCESO EXITOSO";
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr <> 0 THEN
		  LET cCodRet = iSqlErr;
		  LET cMensajeRetorno = cErrorInfo;
		  RETURN TRIM(cCodRet), TRIM(cMensajeRetorno);
		
	   END IF;
	END EXCEPTION;
	
--	SET DEBUG FILE TO "/home/sysifx/vlv/sp_tef_graba_cam_arch41.out";
--	TRACE ON;
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		  
	IF NVL(pEjecutivo,' ') =' ' OR  NVL(pNumero_registros,0) = 0 OR NVL(pImporte,0.00) = 0.00 OR NVL(pClave_archivo,' ') =' ' OR NVL(pCodigo_operacion,0) = 0 OR NVL(pNumero_archivo,0) = 0 OR NVL(pModalidad,0) NOT IN(1,2) THEN
		 LET cCodRet = '000002';
		 LET cMensajeRetorno = 'SE REQUIERE QUE LA INFORMACIÓN SE ENCUENTRE COMPLETA';
		 return cCodRet,cMensajeRetorno;
		
	END IF;

	IF pModalidad = 1 THEN
			--validar si ya existe un registro con  la fecha del sistema.
		SELECT 1 INTO iNumeroArch FROM BDITEF:"informix".cce_archivos_camara 
		WHERE clave_archivo = pClave_archivo AND fecha::DATE = TODAY AND numero_archivo=pNumero_archivo;
		
		IF NVL(iNumeroArch,0) = 0 THEN
		
			INSERT INTO bditef:'informix'.cce_archivos_camara (ejecutivo,numero_archivo,numero_registros,importe,codigo_operacion,fecha,clave_archivo) 
			VALUES (pEjecutivo,pNumero_archivo,pNumero_registros,pImporte,pCodigo_operacion,CURRENT,pClave_archivo);
			
		ELSE 
				LET cCodRet = '000001';
				LET cMensajeRetorno = 'YA EXISTE REGISTRO, DESEA ACTUALIZAR';
		END IF;
		
			RETURN cCodRet, cMensajeRetorno;
						
	END IF;

	IF pModalidad = 2 THEN
		--se actualizan los valores del ejecutivo,numero_registros, importe
		UPDATE bditef:'informix'.cce_archivos_camara
		SET ejecutivo = pEjecutivo,numero_registros = pNumero_registros,importe= pImporte
		WHERE fecha::DATE = TODAY AND numero_archivo = pNumero_archivo AND clave_archivo = pClave_archivo;

		RETURN cCodRet, cMensajeRetorno;
		
	END IF;			
END; 
END PROCEDURE
DOCUMENT
'FOLIO: 230142 - 40 - MejoraCedulaContChqs',
'AUTOR: 96591307 - Viridiana Paredes Romero',
'FECHA: 18-04-2016',
'DESCRIPCION: Se crea procedimiento para guardar datos en la tabla cce_archivos_camara y en caso de existir registro poder actualizarlo',
'BASE DE DATOS: BDITEF',
'SOLICITA: Juan Carlos Lopez Carrasco.';

CREATE PROCEDURE "informix".sp_tef_obt_arch_cam_recib41(pCodOper INTEGER, pClvArchivo CHAR(30))

	--Variables que se retornan.
	RETURNING
		CHAR(6)     AS cCodRet,
		CHAR(14)    AS NumeroArchivo,
		CHAR(14)    AS CodigoOperacion,
		INTEGER     AS NumeroRegistros,
		MONEY(16,2) AS mImporte;

	--Variables necesarias, declaramos.
	DEFINE cCodRet          CHAR(6);
	DEFINE iSqlErr          INTEGER;
	DEFINE intNumArchivo    INTEGER;
	DEFINE intCodOperacion  INTEGER;
	DEFINE intNumRegistros  INTEGER;
	DEFINE monImport        MONEY(16,2);
	DEFINE dtFechaHoy       DATE;
	DEFINE intSumRegistros  INTEGER;
	DEFINE monSumaImporte   MONEY(16,2);
	
	--inicializaar variables
	LET  cCodRet        = '000000';
	LET iSqlErr         = 0;
	LET intNumArchivo   = 0;
	LET intCodOperacion = 0;
	LET intNumRegistros = 0;
	LET monImport       = 0;
	LET dtFechaHoy      = DATE(1);
	LET intSumRegistros = 0;
	LET monSumaImporte  = 0;
	
	--SET DEBUG FILE TO "/tmp/Rodolfo/sp_tef_obt_arch_cam_recib41.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr    -- por si ocurre un error en el transcurso del SP de informix
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
				RETURN cCodRet, 0, 0, 0, 0; --regresa estos valores.
		   END IF;
		END EXCEPTION;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT fecha_hoy
		  INTO dtFechaHoy
		  FROM bdinteg:"informix".si_fechas;
		  
		IF NVL(pCodOper, 0) IN (41) AND pClvArchivo <> '' THEN
			
			FOREACH
				SELECT numero_archivo , codigo_operacion , numero_registros , importe
				  INTO intNumArchivo, intCodOperacion, intNumRegistros, monImport
				  FROM bditef:"informix".cce_archivos_camara
				 WHERE codigo_operacion = pCodOper 
				   AND fecha::DATE = dtFechaHoy
				   AND clave_archivo LIKE pClvArchivo
				 ORDER BY numero_archivo::integer Desc 
				
				RETURN cCodRet, intNumArchivo, intCodOperacion, intNumRegistros, monImport WITH resume;
				
				LET intSumRegistros = intSumRegistros + NVL(intNumRegistros,0);
				LET monSumaImporte = monSumaImporte + NVL(monImport,0);
				
			END FOREACH;
		ELSE
			LET cCodRet = '000001';
		END IF;
		
		RETURN cCodRet, 'CCTI', 'CCTI', NVL(intSumRegistros,0), NVL(monSumaImporte,0);
	
END 
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta la tabla cce_archivos_camara para mostrar los registros de las devoluciones.',
'AUTOR : Rodolfo Tortolero',
'FECHA : 21/04/2016',
'BD    : BDITEF';

CREATE PROCEDURE "informix".sp_grabaoperaciontef(
                        pTipo CHAR(1), 
						pEmpresa CHAR(3),
						pFecha_Trans DATE,
						pFolio_Suc CHAR(16),
						pSucursal CHAR(4), 
						pNum_Cta_Ord CHAR(20),
						pTipo_Cta_Ord CHAR(2),
						pFecha_Prog DATE,
						pTipo_Oper CHAR(2),
						pCve_Rastreo CHAR(30),
						pNombre_Cte_Ord CHAR(30),
						pRfc_Cte_Ord CHAR(15),
						pImp_Tef CHAR(10),
						pComision_Tef CHAR(5),
						pIva_Tef CHAR(5),
						pImp_Tot_Tef CHAR(10),
						pTipo_Cta_Ben CHAR(2),
						pNombre_Ben CHAR(30),
						pNum_Cta_Tarj_Ben CHAR(20),
						pCve_Banco_Rec CHAR(3),
						pRfc_Ben CHAR(15),
						pConcep_Pago CHAR(50),
						pRef_Num CHAR(7),
						pReferencia CHAR(40),
						pCve_Canal CHAR(2),
						pMotivo_Dev CHAR(2), 
						pDivisa CHAR(2),
						pTransacSuc CHAR(4),
						pNumTarjeta  CHAR(16),
						pUsuario CHAR (8))
						
						
						
 RETURNING
 CHAR(5), CHAR(5);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr       INTEGER;
	DEFINE cCodRet1      CHAR (5); --Código Retorno
    DEFINE cCodRet2      CHAR (5); --Código Retorno controlado para arma envios
	DEFINE cCodRet3      CHAR (5); --Código Retorno 1 para sp de parámetros
	DEFINE cCodRet4      CHAR (5); --Código Retorno 2 para sp de parámetros
    DEFINE cNumSerial    CHAR (12);
  
	DEFINE vTrans        CHAR(4);
	DEFINE dFecha        DATE;
	DEFINE mSaldo        MONEY(14,2);
	DEFINE mMonto        MONEY(14,2);
	DEFINE vTransaccion  INTEGER;
	DEFINE cTranscargo   CHAR(4);
	DEFINE cComis        CHAR(4);
	DEFINE cIvaComis     CHAR(4);
	DEFINE cNumTran      CHAR(4);
    --DEFINE sFINALIZADO	 CHAR(1);
	DEFINE cProducto	 CHAR(4);
	DEFINE cTpoPersona	 CHAR(1);
	DEFINE mComServTranTef MONEY;
	DEFINE dValIva		 DECIMAL(9,6);
    


--INICIALIZACION DE VARIABLES
    LET iSqlErr      = 0;
	LET cCodRet1     = "00000";
    LET cCodRet2     = "00000";
	LET cCodRet3     = "00000";
	LET cCodRet4     = "00000";
	LET cNumSerial   = "";
	
	LET vTransaccion = 0;
	LET vTrans       = "";
	LET dFecha       = '01/01/1900';
	LET mSaldo       = 0.00;
	LET mMonto       = 0.00;
	LET cTranscargo  = "";
	LET cComis       = "";
	LET cIvaComis    = "";
    LET cNumTran     = "";
	--LET sFINALIZADO	 = '1';
	LET cProducto	 = "";
	LET cTpoPersona	 = "";
	LET mComServTranTef = 0.0;
	LET dValIva		 = 0.0;
    
    
   -- SET DEBUG FILE TO "/home/sysifx/Trinidad/homo_APP/sp_GrabaOperacionTEF.out";
   -- TRACE ON;

 BEGIN
	
	ON EXCEPTION SET iSqlErr --Manejador de Errores
        IF iSqlErr <> 0 then
            LET cCodRet1 = iSqlErr;
            IF vTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN cCodRet1, cCodRet2;
        END IF;
    END EXCEPTION;
	
	
	
    ON EXCEPTION IN (-535)
        LET vTransaccion = 1;
    END EXCEPTION WITH RESUME;

    IF vTransaccion = 1 THEN
         COMMIT WORK;
         BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
	
	SET LOCK MODE TO WAIT 3;
    
    IF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = pFecha_Trans AND cve_proceso ='GENARCH_60.01' ) THEN  --EL ARCHIVO FUE GENERADO PREVIAMENTE
        LET cCodRet2 = '00233';
        RETURN cCodRet1, cCodRet2;
    END IF;

	IF pTipo = 1 THEN --Aplicar cargo
	
	    IF pEmpresa IS NULL OR pEmpresa = "" OR pSucursal IS NULL OR pSucursal = "" OR
		   pUsuario IS NULL OR pUsuario = "" OR pFolio_Suc IS NULL OR pFolio_Suc = "" OR
		   pNum_Cta_Ord IS NULL OR pNum_Cta_Ord = "" OR pImp_Tef IS NULL OR pImp_Tef = "" OR
		   pDivisa IS NULL OR pDivisa = "" OR pCve_Rastreo IS NULL OR pCve_Rastreo = "" OR
		   pUsuario IS NULL OR pUsuario = "" THEN
		       LET cCodRet2 = "00010";
		       RETURN cCodRet1, cCodRet2;
		END IF;
	
	    SELECT TRIM(valor) 
		INTO cTranscargo  --Transaccion cargo
		FROM bditef:"informix".tef_parametros
		WHERE cod_param = '06';	

		IF cTranscargo IS NULL OR cTranscargo = '' THEN
			LET cCodRet2 = '00012'; --Falta parametro de transaccion cargo.
	        RETURN cCodRet1, cCodRet2;
		END IF;	
	
		--validar si se va a cobrar comision
	
		SELECT TRIM(valor)  
		INTO cComis --Transaccion cargo comision
		FROM bditef:"informix".tef_parametros
		WHERE cod_param = '07';
	
		IF cComis IS NULL OR cComis = '' THEN
	        LET cCodRet2 = '00012'; --Falta parametro de transaccion comision.
	        RETURN cCodRet1, cCodRet2;
	    END IF;
			
		SELECT TRIM(valor)  
		INTO cIvaComis --Transaccion cargo iva
	    FROM bditef:"informix".tef_parametros
	    WHERE cod_param = '08';
		
		IF cIvaComis IS NULL OR cIvaComis = '' THEN
	        LET cCodRet2 = '00012'; --Falta parametro de transaccion iva.
	        RETURN cCodRet1, cCodRet2;
	    END IF;
		
		---Se aplica cargo por importe operacion TEF
		EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pUsuario, cTranscargo, pTransacSuc, pFolio_Suc, pNum_Cta_Ord, 0,  pImp_Tef,  pDivisa,TRIM(pNum_Cta_Tarj_Ben)||" "||TRIM(pCve_Rastreo), pNumTarjeta, pUsuario)
		INTO cCodRet2, vTrans, dFecha, mSaldo, mMonto;
	    IF CAST(cCodRet2 AS INT) <> 0 THEN
	        IF vTransaccion = 1 THEN
	            ROLLBACK WORK;
	            BEGIN WORK;
	        ELSE
	            ROLLBACK WORK;
	        END IF;
	    ELSE
		    ---Se aplica cargo por comision en caso de que la comision sea mayor que 0
			
			
			IF CAST(pComision_Tef AS MONEY(14,2)) > 0 THEN
				SELECT producto
				  INTO cProducto
				  FROM bdicheq:"informix".sc_maechq
				 WHERE empresa = "001"
				   AND cuenta = pNum_Cta_Ord;
				   
				SELECT tpper_valida
				INTO cTpoPersona
				FROM bdicheq:"informix".sc_producto
				WHERE empresa = "001" 
				AND producto = cProducto;
				
				IF cTpoPersona IN ("2","4","5") AND cProducto <> "2600" THEN
					SELECT serv_tran_tef
					INTO mComServTranTef
					FROM bdicheq:"informix".sc_maecomtasserv_pm
					WHERE cuenta = pNum_Cta_Ord;
					
					IF mComServTranTef IS NOT NULL THEN
						SELECT TRIM(valor)
						INTO dValIva
						FROM bdinteg:"informix".si_param
						WHERE empresa = "001"
						AND cod_param = 47;
						
						LET pComision_Tef = mComServTranTef;
						LET pIva_Tef = mComServTranTef * dValIva;
					END IF
				END IF
			
				EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pUsuario, cComis, pTransacSuc, pFolio_Suc, pNum_Cta_Ord, 0, pComision_Tef, pDivisa,pCve_Rastreo, pNumTarjeta, pUsuario)
				INTO cCodRet2, vTrans, dFecha, mSaldo, mMonto;
				IF CAST(cCodRet2 AS INT) <> 0 THEN
					IF vTransaccion = 1 THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						ROLLBACK WORK;
					END IF;
				ELSE
					---Se aplica cargo por iva comision
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pUsuario, cIvaComis, pTransacSuc, pFolio_Suc, pNum_Cta_Ord, 0, pIva_Tef,  pDivisa,pCve_Rastreo, pNumTarjeta, pUsuario)
					INTO cCodRet2, vTrans, dFecha, mSaldo, mMonto;
					IF CAST(cCodRet2 AS INT) <> 0 THEN
						IF vTransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
					--ELSE
					END IF;
			    END IF;
			END IF;
	    END IF;
		
				
	
	ELIF pTipo = 2 THEN --Grabar en TEF
	
		IF pFecha_Trans IS NULL OR pFecha_Trans = "" OR pFolio_Suc IS NULL OR pFolio_Suc = "" OR
		   pSucursal IS NULL OR pSucursal = "" OR pNum_Cta_Ord IS NULL OR pNum_Cta_Ord = "" OR 
		   pTipo_Cta_Ord IS NULL OR pTipo_Cta_Ord = "" OR pFecha_Prog IS NULL OR pFecha_Prog = "" OR 
		   pTipo_Oper IS NULL OR pTipo_Oper = "" OR pCve_Rastreo IS NULL OR pCve_Rastreo = "" OR 
		   pNombre_Cte_Ord IS NULL OR pNombre_Cte_Ord = "" OR pRfc_Cte_Ord IS NULL OR pRfc_Cte_Ord = "" OR 
		   pImp_Tef IS NULL OR pImp_Tef = "" OR pComision_Tef IS NULL OR pComision_Tef = "" OR 
		   pIva_Tef IS NULL OR pIva_Tef = "" OR pImp_Tot_Tef IS NULL OR pImp_Tot_Tef = "" OR 
		   pTipo_Cta_Ben IS NULL OR pTipo_Cta_Ben = "" OR pNombre_Ben IS NULL OR pNombre_Ben = "" OR 
		   pNum_Cta_Tarj_Ben IS NULL OR pNum_Cta_Tarj_Ben = "" OR pConcep_Pago IS NULL OR pConcep_Pago = "" OR
		   pRef_Num IS NULL OR pRef_Num = ""  OR pCve_Canal IS NULL OR pCve_Canal = "" OR 
		   pMotivo_Dev IS NULL OR pMotivo_Dev = "" OR pUsuario IS NULL OR pUsuario = "" THEN
		       LET cCodRet2 = "00010";
		       RETURN cCodRet1, cCodRet2;
			
		END IF;
	       
		SELECT TRIM(valor) 
		INTO cNumTran --Transaccion cargo TEF
		FROM bditef:"informix".tef_parametros
		WHERE cod_param = '06';
		
		IF cNumTran IS NULL OR cNumTran = '' THEN
	        LET cCodRet2 = '00012'; --Falta parametro de transaccion cargo TEF
	        RETURN cCodRet1, cCodRet2;
	    END IF;
					  		
		SELECT num_serial 
		INTO cNumSerial 
		FROM bdicheq:"informix".sc_movdia
	    WHERE folio_suc = pFolio_Suc
		AND empresa = pEmpresa
		AND transacc = cNumTran;
		
	    IF cNumSerial IS NULL OR cNumSerial = "" THEN
		     LET cCodRet2 = "00011"; --NO EXISTE FOLIO SUCURSAL
		ELSE
		    IF TRIM(pReferencia) = "" THEN
			    SELECT TRIM(valor) 
				INTO pReferencia --Transaccion cargo TEF
				FROM bditef:"informix".tef_parametros
				WHERE cod_param = '04';
			    
				IF pReferencia IS NULL OR pReferencia = '' THEN
	                LET cCodRet2 = '00012'; --Falta parametro de REFERENCIA
	                RETURN cCodRet1, cCodRet2;
	            END IF;
        END IF;

        IF pTipo_Cta_Ben IN ('11','12','13') THEN
          LET pTipo_Oper = '06';
        END IF
			
		EXECUTE PROCEDURE  bditef:"informix".sp_ValidaHorarioTEF()
		INTO cCodRet3, cCodRet4;
		IF CAST(cCodRet3 AS INTEGER) <> 0 THEN
			LET cCodRet2  = cCodRet3;
		ELIF CAST(cCodRet4 AS INTEGER) <> 0 THEN
			LET cCodRet2 = cCodRet4;
		ELSE
			      
			INSERT INTO bditef:"informix".tef_operaciones(fecha_trans,folio_suc,num_serial, sucursal, num_cta_ord,tipo_cta_ord,fecha_programacion,
				tipo_operacion,clave_rastreo,nombre_cte_ord,rfc_cte_ord,importe_tef,comision_tef,iva_tef,importe_tot_tef,
				tipo_cta_ben,nombre_ben,num_cuenta_tarj_ben,cve_banco_rec,rfc_ben,concepto_pago,ref_num,referencia,cve_canal,
				cve_status, motivo_dev, hora_insert, user_insert,fecha_insert)
				
			VALUES(pFecha_Trans,pFolio_Suc, cNumSerial, pSucursal, pNum_Cta_Ord, '40', pFecha_Prog,
				pTipo_Oper, pCve_Rastreo, pNombre_Cte_Ord, pRfc_Cte_Ord, pImp_Tef, pComision_Tef, pIva_Tef,	pImp_Tot_Tef,
				pTipo_Cta_Ben, pNombre_Ben, pNum_Cta_Tarj_Ben, pCve_Banco_Rec, pRfc_Ben, pConcep_Pago, NVL(LPAD(trim(pRef_Num),7,'0'),''), pReferencia, pCve_Canal,
				'PE', pMotivo_Dev, SUBSTR(CURRENT HOUR TO SECOND,1,2)||SUBSTR(CURRENT HOUR TO SECOND,4,2)||SUBSTR(CURRENT HOUR TO SECOND,7,2), pUsuario, CURRENT);
		END IF;		
			
	END IF;
ELSE
	LET cCodRet2 = "00013";
END IF; 
RETURN cCodRet1, cCodRet2;


 END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramirez',
'DESCRIPCION: Se encarga de registrar las operaciones TEF',
'EJECUTADO O LLAMADO POR: ',
'FECHA : MARZO 2011',
'VERSION: 20110311',
'BD    : bditef',
'AUTOR : Viridiana Paredes R',
'DESCRIPCION:  se concateno el valor de la cuenta destino campo "pNum_Cta_Ord al valor de la clave rastreo',
'FECHA : MAYO 2015',
'VERSION: 20150528',
'BD    : bditef',
'AUTOR : Trinidad Hernández',
'DESCRIPCION:  "Homologación de caja appriza con RQM 10-239-5 Y RQM 10-495 y cambio BTS_parametro sucursal"; Homologación con Vers. Prod., Pago de remesas Appriza',
'FECHA : 16/06/2016',
'VERSION: 20160616.1749',
'BD    : bditef';

CREATE PROCEDURE "informix".sp_reportearchivos_tef (pnombrearchivo char(20),ptipoarchivo char(4),pfechainicial char(8),pfechafinal char(8),ptiporeporte smallint)
	RETURNING 
	char(5) as codigo, 
	char(10) as fecha_presentacion, 
	char(20) as nombre_arch, 
	char(2) as cod_operacion, 
	char(4) as no_sucursal, 
	char(40) as nombre_ord, 
	char(20)as num_cta_ord, 
	char(50) as tipo_operacion, 
	char(7) as ref_numerica, 
	decimal(11,2) as importe, 
	char(40) as nombre_rec, 
	char(20) as num_cta_rec, 
	char(7) as num_secuencia, 
	char(40) as tipo_cta_destino, 
	char(40) as bancodestino, 
	char(20) as status, 
	decimal(18,2) as imp_operaciones, 
	char(8) as fecha_presentacion2, 
	char(2) as motivo_dev, 
	char(50) as descripcion,
	integer as registrosCod61,
	decimal(18,2) as totalImporteCod61,
	integer as registrosCod62,
	decimal(18,2) as totalImporteCod62;

	DEFINE vsqlerr				INTEGER;
    DEFINE cCodret				CHAR(5);
	DEFINE cFechaPresentacion	CHAR(10);
	DEFINE cNombreArchivo		CHAR(20);
	DEFINE cCodOperacion		CHAR(2);
	DEFINE cSucursal			CHAR(4);
	DEFINE cNombreOrd			CHAR(40);
	DEFINE cNumCtaOrd			CHAR(20);
	DEFINE cTipoOperacion		CHAR(50);
	DEFINE cRefNumerica			CHAR(7);
	DEFINE dImporte				DECIMAL(11,2);
	DEFINE cNombreDestino		CHAR(40);
	DEFINE cNumCtaDestino		CHAR(20);
	DEFINE cSecuencia			CHAR(7);
	DEFINE cTipoCtaDestino		CHAR(40);
	DEFINE cBanco				CHAR(40);
	DEFINE cStatus				CHAR(20);
	DEFINE dImpOperaciones		DECIMAL(18,2);
	DEFINE cMotivoDev			CHAR(2);
	DEFINE cDescripcionDev		CHAR(50);
	DEFINE cRegistrosCod61		INTEGER;
	DEFINE cTotalImporteCod61	DECIMAL(18,2);
	DEFINE cRegistrosCod62		INTEGER;
	DEFINE cTotalImporteCod62	DECIMAL(18,2);
	
	
    LET cCodret	= '00000';
	LET cFechaPresentacion = '';
	LET cNombreArchivo = '';
	LET cCodOperacion = '';
	LET cSucursal = '';
	LET cNombreOrd = '';
	LET cNumCtaOrd = '';
	LET cTipoOperacion = '';
	LET cRefNumerica = '';
	LET dImporte = 0.00;
	LET cNombreDestino= '';
	LET cNumCtaDestino = '';
	LET cSecuencia = '';
	LET cTipoCtaDestino = '';
	LET cBanco = '';
	LET cStatus = '';
	LET dImpOperaciones = 0.00;
	LET cMotivoDev = '';
	LET cDescripcionDev = '';
	LET cRegistrosCod61 = 0;
	LET cTotalImporteCod61 = 0.00;
	LET cRegistrosCod62 = 0;
	LET cTotalImporteCod62 = 0.00;
	
	--SET DEBUG FILE TO "/tmp/ALAN/TESF/TEF/sp_reportearchivos_tef.out";
	--TRACE ON;

	
	BEGIN
		ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN	
                LET cCodret = vsqlerr;
				
				INSERT INTO tef_errores (fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
				VALUES (CURRENT, CURRENT, cCodret, pnombrearchivo, 'sp_reportearchivos_tef', 'ERROR AL GENERAR ARCHIVO',USER, CURRENT);
				
                RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
				cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
				cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62;
								
        END IF;
				
        END EXCEPTION;
		
		IF (NVL(pnombrearchivo, '') <> '') OR (NVL(ptipoarchivo, '') <> '' AND pfechainicial IS NOT NULL AND pfechafinal IS NOT NULL AND NVL(ptiporeporte, 0) <> 0) THEN
			IF ptiporeporte = 1 OR ptiporeporte = 4 OR ptiporeporte = 5 OR ptiporeporte = 6 OR ptiporeporte = 7 THEN
				IF ptiporeporte = 1 OR ptiporeporte = 4 THEN
					IF ptiporeporte = 1 THEN -- Presentados Cod. 60
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						IF pnombrearchivo = '' THEN 
							SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
							INTO cRegistrosCod61, cTotalImporteCod61 
							FROM bditef:"informix".tef_cce_detalle a
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'E' 
									AND a.cve_status = '02'
									AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
							
							LET cTotalImporteCod61 = cTotalImporteCod61 / 100;
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
							INTO cRegistrosCod62, cTotalImporteCod62
							FROM bditef:"informix".tef_cce_detalle a
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'E' 
									AND a.cve_status = '01'
									AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal
									AND a.ref_confirmacion <> ''; 

							LET cTotalImporteCod62 = cTotalImporteCod62 / 100;
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
						
								SELECT sum(imp_operaciones::decimal(18,2)) 
								INTO dImpOperaciones
								FROM bditef:"informix".tef_cce_sumario
								WHERE cod_operacion = ptipoarchivo
								AND substr(nombre_arch,1,1) = 'E'
								--AND substr(nombre_arch,1,1) = 'S'
								AND fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
								LET dImpOperaciones = dImpOperaciones / 100;
						ELSE
								SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
								INTO cRegistrosCod61, cTotalImporteCod61 
								FROM bditef:"informix".tef_cce_detalle a
								WHERE a.cod_operacion = ptipoarchivo 
										AND substr(a.nombre_arch,1,1) = 'E' 
										AND a.cve_status = '02'
										AND a.nombre_arch = pnombrearchivo;
								
								LET cTotalImporteCod61 = cTotalImporteCod61 / 100;
								SET LOCK MODE TO WAIT 3;
								SET ISOLATION TO DIRTY READ;
								SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
								INTO cRegistrosCod62, cTotalImporteCod62
								FROM bditef:"informix".tef_cce_detalle a
								WHERE a.cod_operacion = ptipoarchivo 
										AND substr(a.nombre_arch,1,1) = 'E' 
										AND a.cve_status = '01'
										AND a.nombre_arch = pnombrearchivo
										AND a.ref_confirmacion <> ''; 

								LET cTotalImporteCod62 = cTotalImporteCod62 / 100;
								SET LOCK MODE TO WAIT 3;
								SET ISOLATION TO DIRTY READ;
						
								SELECT sum(imp_operaciones::decimal(18,2)) 
								INTO dImpOperaciones
								FROM bditef:"informix".tef_cce_sumario
								WHERE cod_operacion = ptipoarchivo
								AND substr(nombre_arch,1,1) = 'E'
								--AND substr(nombre_arch,1,1) = 'S'
								AND nombre_arch = pnombrearchivo;
								LET dImpOperaciones = dImpOperaciones / 100;
						END IF;	

						IF NVL(pnombrearchivo, '') <> '' THEN
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							FOREACH
							
								SELECT a.fecha_presentacion, a.nombre_arch, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
								a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
								a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
								INTO cFechaPresentacion, cNombreArchivo, cSucursal, cNombreDestino, cNumCtaOrd, cTipoOperacion, 
								cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
								FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
								WHERE a.cod_operacion = ptipoarchivo 
								AND substr(a.nombre_arch,1,1) = 'E'
								--AND substr(a.nombre_arch,1,1) = 'S'
								AND a.tipo_cta_rec = b.tipo_cta 
								AND a.banco_receptor = c.banco 
								AND a.cve_status = d.cve_status 
								AND a.tipo_operacion = e.codigo 
								AND a.motivo_dev = f.motivo_dev
								AND a.nombre_arch = pnombrearchivo
								ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
								
								LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
								LET dImporte = dImporte / 100;
								RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, 
								cTipoOperacion, cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, 
								cStatus, dImpOperaciones, cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, 
								cRegistrosCod62, cTotalImporteCod62 WITH RESUME;
							END FOREACH;
						ELSE
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							FOREACH
							
								SELECT a.fecha_presentacion, a.nombre_arch, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
								a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
								a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
								INTO cFechaPresentacion, cNombreArchivo, cSucursal, cNombreDestino, cNumCtaOrd, cTipoOperacion, 
								cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
								FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
								WHERE a.cod_operacion = ptipoarchivo 
								AND substr(a.nombre_arch,1,1) = 'E' 
								--AND substr(a.nombre_arch,1,1) = 'S'
								AND a.tipo_cta_rec = b.tipo_cta 
								AND a.banco_receptor = c.banco 
								AND a.cve_status = d.cve_status 
								AND a.tipo_operacion = e.codigo 
								AND a.motivo_dev = f.motivo_dev
								AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal
								ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
								
								LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || 
								substr(cFechaPresentacion,1,4);
								LET dImporte = dImporte / 100;

								RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, 
								cTipoOperacion, cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, 
								cStatus, dImpOperaciones, cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, 
								cRegistrosCod62, cTotalImporteCod62 WITH RESUME;

							END FOREACH;
						END IF
					ELSE -- Recibidos Cod. 60
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						IF pnombrearchivo = '' THEN
							SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
							INTO cRegistrosCod61, cTotalImporteCod61 
							FROM bditef:"informix".tef_cce_detalle a 
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'S' 
									AND a.cve_status = '02'
									AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
						
							LET cTotalImporteCod61 = cTotalImporteCod61 / 100;
							
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT COUNT(cod_operacion), SUM(importe::INTEGER)::decimal(18,2)
							INTO cRegistrosCod62, cTotalImporteCod62 
							FROM bditef:"informix".tef_cce_detalle a
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'S' 
									AND a.cve_status = '01'
									AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal;

							LET cTotalImporteCod62 = (cTotalImporteCod62 / 100)::decimal(18,2);
							
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT sum(imp_operaciones::decimal(18,2)) 
							INTO dImpOperaciones
							FROM bditef:"informix".tef_cce_sumario 
							WHERE cod_operacion = ptipoarchivo
							AND substr(nombre_arch,1,1) = 'S'
							--AND substr(nombre_arch,1,1) = 'E'
							AND fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
							LET dImpOperaciones = dImpOperaciones / 100;											
						ELSE												
							SELECT COUNT(cod_operacion), SUM(importe::decimal(18,2)) 
							INTO cRegistrosCod61, cTotalImporteCod61 
							FROM bditef:"informix".tef_cce_detalle a 
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'S' 
									AND a.cve_status = '02'
									AND a.nombre_arch = pnombrearchivo;
						
							LET cTotalImporteCod61 = cTotalImporteCod61 / 100;
							
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT COUNT(cod_operacion), SUM(importe::INTEGER)::decimal(18,2)
							INTO cRegistrosCod62, cTotalImporteCod62 
							FROM bditef:"informix".tef_cce_detalle a
							WHERE a.cod_operacion = ptipoarchivo 
									AND substr(a.nombre_arch,1,1) = 'S' 
									AND a.cve_status = '01'
									AND a.nombre_arch = pnombrearchivo;

							LET cTotalImporteCod62 = (cTotalImporteCod62 / 100)::decimal(18,2);
							
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT sum(imp_operaciones::decimal(18,2)) 
							INTO dImpOperaciones
							FROM bditef:"informix".tef_cce_sumario 
							WHERE cod_operacion = ptipoarchivo
							AND substr(nombre_arch,1,1) = 'S'
							--AND substr(nombre_arch,1,1) = 'E'
							AND nombre_arch = pnombrearchivo;

							LET dImpOperaciones = dImpOperaciones / 100;
						END IF;	
						
						IF NVL(pnombrearchivo, '') <> '' THEN
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							FOREACH
								SELECT a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
								a.nombre_rec, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
								a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
								INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
								cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
								FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
								WHERE a.cod_operacion = ptipoarchivo 
								AND substr(a.nombre_arch,1,1) = 'S'
								--AND substr(nombre_arch,1,1) = 'E'
								AND a.tipo_cta_rec = b.tipo_cta 
								AND a.banco_receptor = c.banco 
								AND a.cve_status = d.cve_status 
								AND a.tipo_operacion = e.codigo 
								AND a.motivo_dev = f.motivo_dev
								AND a.nombre_arch = pnombrearchivo
								ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
								
								LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
								LET dImporte = dImporte / 100;
								
								RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, 
								cTipoOperacion, cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, 
								cStatus, dImpOperaciones, cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, 
								cRegistrosCod62, cTotalImporteCod62 WITH RESUME;
							END FOREACH;
						ELSE
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							FOREACH
								SELECT a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
								a.nombre_rec, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
								a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
								INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
								cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
								FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
								WHERE a.cod_operacion = ptipoarchivo 
								AND substr(a.nombre_arch,1,1) = 'S'
								--AND substr(nombre_arch,1,1) = 'E'
								AND a.tipo_cta_rec = b.tipo_cta 
								AND a.banco_receptor = c.banco 
								AND a.cve_status = d.cve_status 
								AND a.tipo_operacion = e.codigo 
								AND a.motivo_dev = f.motivo_dev 
								AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal 
								ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
								
								LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
								LET dImporte = dImporte / 100;
								RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, 
								cTipoOperacion, cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, 
								cStatus, dImpOperaciones, cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, 
								cRegistrosCod62, cTotalImporteCod62 WITH RESUME;
							END FOREACH;
						END IF
					END IF
				END IF
				IF ptiporeporte = 7 THEN -- Recibidos Cod. 63
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					IF pnombrearchivo = '' THEN
						SELECT sum(imp_operaciones::decimal(18,2)) 
						INTO dImpOperaciones
						FROM bditef:"informix".tef_cce_sumario
						WHERE cod_operacion = ptipoarchivo
						--AND substr(nombre_arch,1,1) = 'E'
						AND substr(nombre_arch,1,1) = 'S'
						AND fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
						LET dImpOperaciones = dImpOperaciones / 100;
					ELSE
						SELECT sum(imp_operaciones::decimal(18,2)) 
						INTO dImpOperaciones
						FROM bditef:"informix".tef_cce_sumario
						WHERE cod_operacion = ptipoarchivo
						--AND substr(nombre_arch,1,1) = 'E'
						AND substr(nombre_arch,1,1) = 'S'
						AND nombre_arch = pnombrearchivo;
						LET dImpOperaciones = dImpOperaciones / 100;
					END IF;		
					IF NVL(pnombrearchivo, '') <> '' THEN
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						FOREACH
							SELECT a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
							a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
							a.num_secuencia, b.descripcion AS TipoCtaOrdenante, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
							INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
							FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
							WHERE a.cod_operacion = ptipoarchivo 
							--AND substr(a.nombre_arch,1,1) = 'E'
							AND substr(a.nombre_arch,1,1) = 'S'
							AND a.tipo_cta_ord = b.tipo_cta 
							AND a.banco_presentador = c.banco 
							AND a.cve_status = d.cve_status 
							AND a.tipo_operacion = e.codigo
							AND a.motivo_dev = f.motivo_dev
							AND a.nombre_arch = pnombrearchivo
							ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
							LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
							LET dImporte = dImporte / 100;
							RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
							cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, 
							cTotalImporteCod62 WITH RESUME;
						END FOREACH;
					ELSE
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						FOREACH
							SELECT a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
							a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
							a.num_secuencia, b.descripcion AS TipoCtaOrdenante, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev AS CausaDev, f.descripcion AS DescDev
							INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev
							FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e, bditef:"informix".tef_cat_devoluciones AS f
							WHERE a.cod_operacion = ptipoarchivo 
							--AND substr(a.nombre_arch,1,1) = 'E'
							AND substr(a.nombre_arch,1,1) = 'S'
							AND a.tipo_cta_ord = b.tipo_cta 
							AND a.banco_presentador = c.banco 
							AND a.cve_status = d.cve_status 
							AND a.tipo_operacion = e.codigo
							AND a.motivo_dev = f.motivo_dev
							AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal 
							ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
							
							LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
							LET dImporte = dImporte / 100;
							RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
							cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, 
							cTotalImporteCod62 WITH RESUME;
						END FOREACH;
					END IF
				END IF
				IF ptiporeporte = 5 OR ptiporeporte = 6 THEN
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					IF pnombrearchivo = '' THEN
						SELECT sum(imp_operaciones::decimal(18,2)) 
						INTO dImpOperaciones
						FROM bditef:"informix".tef_cce_sumario 
						WHERE cod_operacion = ptipoarchivo
						AND fecha_presentacion BETWEEN pfechainicial AND pfechafinal;
						LET dImpOperaciones = dImpOperaciones / 100;
					ELSE
						SELECT sum(imp_operaciones::decimal(18,2)) 
						INTO dImpOperaciones
						FROM bditef:"informix".tef_cce_sumario 
						WHERE cod_operacion = ptipoarchivo
						AND nombre_arch = pnombrearchivo;
						LET dImpOperaciones = dImpOperaciones / 100;
					END IF;	
					IF NVL(pnombrearchivo, '') <> '' THEN
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						FOREACH
							SELECT a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
							a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
							a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status 
							INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus 
							FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e 
							WHERE a.cod_operacion = ptipoarchivo 
							AND a.tipo_cta_rec = b.tipo_cta 
							AND a.banco_receptor = c.banco 
							AND a.cve_status = d.cve_status 
							AND a.tipo_operacion = e.codigo 
							AND a.nombre_arch = pnombrearchivo
							ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
							LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
                                                        LET dImporte = dImporte / 100;
							RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
							cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, 
							cTotalImporteCod62 WITH RESUME;
						END FOREACH;
					ELSE
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						FOREACH
							SELECT a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, 
							a.nombre_ord, a.num_cta_ord, e.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, 
							a.num_secuencia, b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status 
							INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus 
							FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_tipo_oper AS e 
							WHERE a.cod_operacion = ptipoarchivo 
							AND a.tipo_cta_rec = b.tipo_cta 
							AND a.banco_receptor = c.banco 
							AND a.cve_status = d.cve_status 
							AND a.tipo_operacion = e.codigo 
							AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal 
							ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
							
							
							LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
							LET dImporte = dImporte / 100;

							RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
							cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
							cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, 
							cTotalImporteCod62 WITH RESUME;
						END FOREACH;
					END IF
				END IF
			END IF
			IF ptiporeporte = 2 THEN -- Presentados Cod. 63
				IF NVL(pnombrearchivo, '') <> '' THEN
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					FOREACH

						SELECT a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, a.nombre_rec, 
						f.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, a.num_secuencia, 
						b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev, e.descripcion 
						INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreDestino, cTipoOperacion, cRefNumerica, dImporte, 
						cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev 
						FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_cat_devoluciones as e, 
						tef_tipo_oper AS f 
						WHERE a.cod_operacion = ptipoarchivo 
						--AND substr(a.nombre_arch,1,1) = 'S'
						AND substr(a.nombre_arch,1,1) = 'E'
						AND a.tipo_cta_rec = b.tipo_cta 
						AND a.banco_receptor = c.banco 
						AND a.cve_status = d.cve_status 
						AND a.motivo_dev = e.motivo_dev
						AND a.tipo_operacion = f.codigo 
						AND a.nombre_arch = pnombrearchivo
						ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia

						LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
						LET dImporte = dImporte / 100;

						RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
						cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
						cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62 
						WITH RESUME;

					END FOREACH;
				ELSE
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					FOREACH

						SELECT a.fecha_presentacion, a.nombre_arch, a.cod_operacion, substr(a.clave_rastreo, 8, 4) AS no_sucursal, a.nombre_rec, 
						f.descripcion AS TipoPago, a.ref_numerica, a.importe::decimal(11,2), a.num_cta_rec, a.num_secuencia, 
						b.descripcion AS TipoCtaDestino, c.descripcion AS BancoDestino, d.descripcion AS Status, a.motivo_dev, e.descripcion 
						INTO cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreDestino, cTipoOperacion, cRefNumerica, dImporte, 
						cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, cMotivoDev, cDescripcionDev 
						FROM bditef:"informix".tef_cce_detalle AS a, bditef:"informix".tef_tipo_cta AS b, bdinteg:"informix".si_bancos AS c, bditef:"informix".tef_status_pago AS d, bditef:"informix".tef_cat_devoluciones as e, 
						tef_tipo_oper AS f 
						WHERE a.cod_operacion = ptipoarchivo 
						--AND substr(a.nombre_arch,1,1) = 'S'
						AND substr(a.nombre_arch,1,1) = 'E'
						AND a.tipo_cta_rec = b.tipo_cta 
						AND a.banco_receptor = c.banco 
						AND a.cve_status = d.cve_status 
						AND a.motivo_dev = e.motivo_dev
						AND a.tipo_operacion = f.codigo 
						AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal
						ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
						
						LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
						LET dImporte = dImporte / 100;

						RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
						cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
						cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62 
						WITH RESUME;

					END FOREACH;
				END IF
			END IF

			IF ptiporeporte = 3 THEN -- Recibidos Cod. 10
				IF NVL(pnombrearchivo, '') <> '' THEN
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					FOREACH
						SELECT a.fecha_presentacion, a.nombre_arch, a.num_cta_ord, a.importe::decimal(11,2), a.num_cta_rec, 
						e.descripcion AS TipoCtaDestino, a.num_secuencia, b.descripcion AS BancoDestino, c.descripcion AS Status, a.motivo_dev, 
						d.descripcion 
						INTO cFechaPresentacion, cNombreArchivo, cNumCtaOrd, dImporte, cNumCtaDestino, cTipoCtaDestino, cSecuencia, cBanco, 
						cStatus, cMotivoDev, cDescripcionDev 
						FROM bditef:"informix".tef_cce_detalle AS a, bdinteg:"informix".si_bancos AS b, bditef:"informix".tef_status_pago AS c, bditef:"informix".tef_cat_devoluciones as d, bditef:"informix".tef_tipo_cta AS e
						WHERE a.cod_operacion = ptipoarchivo 
						AND a.banco_receptor = b.banco 
						AND a.cve_status = c.cve_status 
						AND a.motivo_dev = d.motivo_dev 
						AND a.tipo_cta_rec = e.tipo_cta 
						AND a.nombre_arch = pnombrearchivo
						ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia

						LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || substr(cFechaPresentacion,1,4);
						LET dImporte = dImporte / 100;

						RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
						cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
						cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62 
						WITH RESUME;
					END FOREACH;
				ELSE
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					FOREACH

						SELECT a.fecha_presentacion, a.nombre_arch, a.num_cta_ord, a.importe::decimal(11,2), a.num_cta_rec, 
						e.descripcion AS TipoCtaDestino, a.num_secuencia, b.descripcion AS BancoDestino, c.descripcion AS Status, a.motivo_dev, 
						d.descripcion 
						INTO cFechaPresentacion, cNombreArchivo, cNumCtaOrd, dImporte, cNumCtaDestino, cTipoCtaDestino, cSecuencia, cBanco, 
						cStatus, cMotivoDev, cDescripcionDev 
						FROM bditef:"informix".tef_cce_detalle AS a, bdinteg:"informix".si_bancos AS b, bditef:"informix".tef_status_pago AS c, bditef:"informix".tef_cat_devoluciones as d, bditef:"informix".tef_tipo_cta AS e
						WHERE a.cod_operacion = ptipoarchivo 
						AND a.banco_receptor = b.banco 
						AND a.cve_status = c.cve_status 
						AND a.motivo_dev = d.motivo_dev 
						AND a.tipo_cta_rec = e.tipo_cta 
						AND a.fecha_presentacion BETWEEN pfechainicial AND pfechafinal 
						ORDER BY a.fecha_presentacion, a.nombre_arch, a.num_secuencia
						
						LET cFechaPresentacion = substr(cFechaPresentacion,7,2) || "/" || substr(cFechaPresentacion,5,2) || "/" || 
						substr(cFechaPresentacion,1,4);
						LET dImporte = dImporte / 100;

						RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, 
						cRefNumerica, dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, 
						cFechaPresentacion, cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62 
						WITH RESUME;
					END FOREACH;
				END IF
			END IF
		ELSE
			LET cCodret = '00001';
			
			RETURN cCodret, cFechaPresentacion, cNombreArchivo, cCodOperacion, cSucursal, cNombreOrd, cNumCtaOrd, cTipoOperacion, cRefNumerica, 
			dImporte, cNombreDestino, cNumCtaDestino, cSecuencia, cTipoCtaDestino, cBanco, cStatus, dImpOperaciones, cFechaPresentacion, 
			cMotivoDev, cDescripcionDev, cRegistrosCod61, cTotalImporteCod61, cRegistrosCod62, cTotalImporteCod62;
		END IF
	END;
END PROCEDURE

DOCUMENT
'FECHA: 06/Mayo/2011',
'AUTOR: Manuel Ramos Figueroa.',
'DESCRIPCION: Sp para generaciÃ?Â³n de reportes de operaciones TEF',
'BD: BDITEF',
'FECHA: 08/Agosto/2011',
'AUTOR: Manuel Ramos Figueroa.',
'DESCRIPCION: Sp para generaciÃ?Â³n de reportes de operaciones TEF',
'BD: BDITEF';

CREATE PROCEDURE "informix".sp_tef_generararchivo62(cNombreArchivo CHAR(20), cUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet;

--DEFINICION DE VARIABLES.
DEFINE dFechaHoy				DATE;
DEFINE dFechaHabil				DATE;
DEFINE cFechaPresentacionGen	CHAR(8);

DEFINE cCodRet					CHAR(5);
DEFINE cCodRet2					CHAR(5);
DEFINE cCodRet3					CHAR(5);
DEFINE cStatus_tar				CHAR(2);
DEFINE cPrefijoTarjeta			CHAR(6);

DEFINE cCuenta					CHAR(12);
DEFINE cStatus_Cta				CHAR(1);
DEFINE cProducto				CHAR(4);
DEFINE cNombreArch				CHAR(20);
DEFINE cFechaPresentacion		CHAR(8);
DEFINE cTipoRegistro			CHAR(2);
DEFINE cNumSecuencia			CHAR(7);
DEFINE cCodOperacion			CHAR(2);
DEFINE cCodDivisa				CHAR(2);
DEFINE cFechaTrans				CHAR(8);
DEFINE cBancoPresentador		CHAR(3);
DEFINE cBancoReceptor			CHAR(3);
DEFINE cImporte					CHAR(15);
DEFINE cUsoFuturoCcen			CHAR(16);
DEFINE cTipoOperacion			CHAR(2);
DEFINE cFechaAplica				CHAR(8);
DEFINE cTipoCtaOrd				CHAR(2);
DEFINE cNumCtaOrd				CHAR(20);
DEFINE cNombreOrd				CHAR(40);
DEFINE cRfcOrd					CHAR(18);
DEFINE cTipoCtaRec				CHAR(2);
DEFINE cNumCtaRec				CHAR(20);
DEFINE cNombreRec				CHAR(40);
DEFINE cRfcRec					CHAR(18);
DEFINE cRefServicio				CHAR(40);
DEFINE cNombreTitularServ		CHAR(40);
DEFINE cImporteIva				CHAR(15);
DEFINE cRefNumerica				CHAR(7);
DEFINE cRefLeyenda				CHAR(40);
DEFINE cClaveRastreo			CHAR(30);
DEFINE cMotivoDev				CHAR(2);
DEFINE cFechaPresIni			CHAR(8);
DEFINE cSolicitudConfirmacion	CHAR(1);
DEFINE cUsoFuturoBanco			CHAR(11);
DEFINE cRefConfirmacion			CHAR(30);
DEFINE cUsoFuturoCce			CHAR(1);
DEFINE cTasaTiieProm			CHAR(7);
DEFINE cDiasRetraso				CHAR(3);
DEFINE cImpTotInt				CHAR(15);
DEFINE cCveEstatus				CHAR(11);
DEFINE cFolioSuc				CHAR(30);

DEFINE cClaveBancaria			CHAR(3);
DEFINE cPrefijoTarjetaDebito	CHAR(100);
DEFINE cSucursalContable		CHAR(4);
DEFINE cNumeroFolioAbono		CHAR(16);
DEFINE cTransaccAbono			CHAR(4);

DEFINE mSaldoAPagar				MONEY(16,2);
DEFINE cTransacAbonoCred		CHAR(4);

DEFINE iContadorSecuencia62		INTEGER;
DEFINE iImporteTotalArchivo62	INT8;
--*
DEFINE cNumCte 					CHAR(20);
DEFINE sCanal					SMALLINT;
DEFINE cEsTransfer				CHAR(1);
DEFINE cUserInsert				CHAR(8);
DEFINE dtFechaHoraInsert		DATETIME YEAR TO SECOND;
--*

--ENCABEZADO
DEFINE cCveBancoE				CHAR(3);
DEFINE cServicioE				CHAR(1);
DEFINE cNumBloqueE				CHAR(7);
DEFINE cCodDivisaE				CHAR(2);
DEFINE cCveRechazoblE			CHAR(2);
DEFINE cModalidadE				CHAR(1);
DEFINE cUsoFuturoCcenE			CHAR(41);
DEFINE cUsoFuturoBancoE		CHAR(370);

--SUMARIO
DEFINE cNumBloqueS				CHAR(7);
DEFINE cUsoFuturoCcenS			CHAR(40);
DEFINE cUsoFuturoBancoS			CHAR(364);


DEFINE cNombreArchivoAUX		CHAR(20);
DEFINE iContadorSecuenciaAUX	INTEGER;

--REVERSOS
DEFINE cTransaccCargo			CHAR(4);
DEFINE cTranRet					CHAR(4);


DEFINE mSaldoDisponible			MONEY(16,2);
DEFINE mMontoRetenido			MONEY(16,2);

--TRANSACCIONES
DEFINE cFlagEnTransaccion		CHAR (1);
DEFINE iContadorRegistros		INTEGER;

DEFINE iSQLerr					INTEGER;

--RETORNO DEL PRINCIPAL
DEFINE mRemanente				MONEY(14,2);
DEFINE mIntMoraCob				MONEY(14,2);
DEFINE mIntVencCob				MONEY(14,2);
DEFINE mCapVencCob				MONEY(14,2);
DEFINE mIntVigCob				MONEY(14,2);
DEFINE mCapVigCob				MONEY(14,2);
DEFINE mImpuesto				MONEY(14,2);
DEFINE mComision				MONEY(14,2);
DEFINE mSeguro					MONEY(14,2);

--NOMBRES DE LOS ARCHIVOS
DEFINE cNomArchivo62			CHAR(20);
DEFINE iNumArchivos				INTEGER;

--FLAG ARCHIVO 62
DEFINE cFlagArch62				CHAR(1);

--TIPO DE PROCESO MANUAL O AUTOMATICO
DEFINE cFlagTipoProceso 		CHAR (1);

--DESCRIPCION DEL PROCESO
DEFINE cDescripcionProceso		CHAR (60);

--CONSTANTES
DEFINE cPROCESANDO				CHAR(1);
DEFINE cERROR 					CHAR(1);
DEFINE cFINALIZADO				CHAR(1);

--SET DEBUG FILE TO '/tmp/josea/sp_generararchivo62.out';
--TRACE ON;

--INICIALIZACION DE VARIABLES.
LET cCodRet					= '';
LET cCodRet2				= '';
LET cCodRet3				= '';

LET cPrefijoTarjeta			= '';

LET cCuenta					= '';
LET cStatus_Cta				= '';
LET cProducto				= '';
LET dFechaHoy				= CURRENT;
LET dFechaHabil				= CURRENT;
LET cStatus_tar				= '';
LET cFechaPresentacionGen 	= '';

LET cNombreArch				= '';
LET cFechaPresentacion		= '';
LET cTipoRegistro			= '';
LET cNumSecuencia			= '';
LET cCodOperacion			= '';
LET cCodDivisa				= '';
LET cFechaTrans				= '';
LET cBancoPresentador		= '';
LET cBancoReceptor			= '';
LET cImporte				= '';
LET cUsoFuturoCcen			= '';
LET cTipoOperacion			= '';
LET cFechaAplica			= '';
LET cTipoCtaOrd				= '';
LET cNumCtaOrd				= '';
LET cNombreOrd				= '';
LET cRfcOrd					= '';
LET cTipoCtaRec				= '';
LET cNumCtaRec				= '';
LET cNombreRec				= '';
LET cRfcRec					= '';
LET cRefServicio			= '';
LET cNombreTitularServ		= '';
LET cImporteIva				= '';
LET cRefNumerica			= '';
LET cRefLeyenda				= '';
LET cClaveRastreo			= '';
LET cMotivoDev				= '';
LET cFechaPresIni			= '';
LET cSolicitudConfirmacion = '';
LET cUsoFuturoBanco			= '';
LET cRefConfirmacion		= '';
LET cUsoFuturoCce			= '';
LET cTasaTiieProm			= '';
LET cDiasRetraso			= '';
LET cImpTotInt				= '';
LET cCveEstatus				= '';
LET cFolioSuc				= '';

LET cClaveBancaria			= '';
LET cPrefijoTarjetaDebito	= '';
LET cSucursalContable		= '';
LET cNumeroFolioAbono		= '';
LET cTransaccAbono			= '';
LET mSaldoAPagar			= 0.0;
LET cTransacAbonoCred		= '';


LET iContadorSecuencia62	= 0;
LET iImporteTotalArchivo62	= 0;
--*
LET cNumCte 				= "";
LET sCanal					= 0;
LET cEsTransfer				= "";
LET cUserInsert				= "";
LET dtFechaHoraInsert		= DATE(1);
--*

--ENCABEZADO
LET cCveBancoE				= '';
LET cServicioE				= '';
LET cNumBloqueE				= '';
LET cCodDivisaE				= '';
LET cCveRechazoblE			= '';
LET cModalidadE				= '';
LET cUsoFuturoCcenE			= '';
LET cUsoFuturoBancoE		= '';


--SUMARIO
LET cNumBloqueS				= '';
LET cUsoFuturoCcenS			= '';
LET cUsoFuturoBancoS		= '';

LET cNombreArchivoAUX		= '';
LET iContadorSecuenciaAUX	= '';

--REVERSOS
LET cTransaccCargo			= '';
LET cTranRet				= '';
LET dFechaHoy				= CURRENT;
LET mSaldoDisponible		= 0.0;
LET mMontoRetenido			= 0.0;

--RETORNO DEL PRINCIPAL
LET mRemanente				=0;
LET mIntMoraCob				=0;
LET mIntVencCob				=0;
LET mCapVencCob				=0;
LET mIntVigCob				=0;
LET mCapVigCob				=0;
LET mImpuesto				=0;
LET mComision				=0;
LET mSeguro					=0;


--TRANSACCIONES
LET cFlagEnTransaccion		='F';
LET iContadorRegistros		=0;

--NOMBRES ARCHIVOS
--LET cNomArchivo61			='';
LET cNomArchivo62			='';
LET iNumArchivos			=0;

--FLAG ARCHIVO 62
LET cFlagArch62				='F';

--TIPO DE PROCESO MANUAL O AUTOMATICO
LET cFlagTipoProceso 		='';

--DESCRIPCION DEL PROCESO
LET cDescripcionProceso		='';

--CONSTANTES
LET cPROCESANDO 			='0';
LET cFINALIZADO				='1';
LET cERROR					='3';

LET iSQLerr					=0;

BEGIN
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cDescripcionProceso = 'Error en el proceso';
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, 'RECARCH_' || 62 || '.' || SUBSTRING (TRIM(cNombreArchivo) FROM 15 FOR 2), cDescripcionProceso,
		cERROR, iSqlErr, cUsuario, 'ERROR NO CONTROLADO', TRIM(cNombreArchivo), cFechaPresentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRet;
	
		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((iContadorRegistros > 0) OR (cFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET cFlagEnTransaccion = 'F';
		END IF;

		LET cFlagEnTransaccion = 'F';
		LET iContadorRegistros = 0;

		--EN CASO DE ERROR NO CONTROLADO SE REVERSAN LOS ABONOS
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS REGISTROS VALIDOS DEL ARCHIVO 60 PARA PROCESAR
		FOREACH WITH HOLD
			SELECT
			Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans,
			Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord,
			Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio,
			Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini,
			Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso,
			Imp_Tot_Int, Cve_Status, Folio_Suc
			INTO
			cNombreArch, cFechaPresentacion, cTipoRegistro, cNumSecuencia, cCodOperacion, cCodDivisa, cFechaTrans,
			cBancoPresentador, cBancoReceptor, cImporte, cUsoFuturoCcen, cTipoOperacion, cFechaAplica, cTipoCtaOrd,
			cNumCtaOrd, cNombreOrd, cRfcOrd, cTipoCtaRec, cNumCtaRec, cNombreRec, cRfcRec, cRefServicio,
			cNombreTitularServ, cImporteIva, cRefNumerica, cRefLeyenda, cClaveRastreo, cMotivoDev, cFechaPresIni,
			cSolicitudConfirmacion, cUsoFuturoBanco, cRefConfirmacion, cUsoFuturoCce, cTasaTiieProm, cDiasRetraso,
			cImpTotInt, cCveEstatus, cFolioSuc
			FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
			WHERE Nombre_Arch = cNomArchivo62 AND Cod_operacion = '62'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (cFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET cFlagEnTransaccion = 'V';
			END IF;
			LET cCodRet = '00000';
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT FIRST 1 Valor INTO cSucursalContable FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77'; --SUCURSAL CONTABLE
			IF ( TRIM(cTipoCtaRec)='11') THEN   --VALIDACION PARA SABER SI ES CREDITO, SE OBTIENE EL NUMERO DE CREDITO
				LET cCuenta = SUBSTR(cNumCtaRec,9,12);
				--LA CUENTA ES DE CREDITO
				IF ( EXISTS ( SELECT Num_Credito FROM BdiCred:Sd_MaeCred
					WHERE Empresa = '001' AND Num_Credito = cCuenta ) )  THEN --VALIDA NUMERO DE CREDITO
					IF ( EXISTS ( SELECT NUM_CREDITO FROM BDICRED:"informix".Sd_MaeCred
						WHERE EMPRESA = '001' AND NUM_CREDITO = cCuenta AND status_cred IN ('AA','BT','BA') ) ) THEN
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						SELECT NVL(VALOR,'') INTO cTransacAbonoCred FROM BDITEF:"informix".tef_parametros WHERE cod_param='83';
						LET cNumeroFolioAbono = '';
						LET mSaldoAPagar = ((cImporte::INTEGER)/100);
						--REALIZA EL CARGO REVERSADO
						EXECUTE PROCEDURE bdicred:"informix".reversion ('001', cSucursalContable, cUsuario,cFolioSuc, "M") INTO cCodRet;
					ELSE
						LET cMotivoDev = '02'; --LA CUENTA DE CREDITO NO ESTA ACTIVA
					END IF;
				ELSE
					LET cMotivoDev = '01'; --LA CUENTA DE CREDITO NO EXISTE
				END IF;
			ELSE
				
				IF (TRIM(NVL(cTipoCtaRec, '')) = '10') THEN -- VALIDAMOS TIPO CUENTA MOVIL
				-- EJECUTAMOS EL PROCEDIMIENTO NUEVO 
				--*
				EXECUTE PROCEDURE bdicheq:"informix".sp_tef_constelctacte (SUBSTR(cNumCtaRec, 11,10)) -- OBTENEMOS LA CUENTA DEL NUMERO MOVIL 
				INTO cCodRet, cNumCte, cCuenta, sCanal, cEsTransfer, cUserInsert, dtFechaHoraInsert; -- REGRESA CUENTA DEL TELEFONO MOVIL
				
				-- SI NO HAY CUENTA PARA EL  MOVIL, ASIGNAMOS MOTIVO DEVOLUCIÃÂÃÂN.
				IF NVL(cCuenta, '') = '' THEN	
					LET cMotivoDev = '01'; -- CUENTA INEXISTENTE.
				END IF;
				--*
				ELIF ( TRIM(cTipoCtaRec)='40') THEN    --VALIDACION PARA CONOCER SI ES CREDITO O DEBITO
					LET cCuenta = SUBSTR(cNumCtaRec,9,11);
				ELIF ( TRIM(cTipoCtaRec)='03') THEN
					SELECT FIRST 1 NVL(Cuenta,''),status_tar INTO cCuenta,cStatus_tar FROM BdiCheq:"informix".Sc_Tarjeta 
					WHERE Empresa = '001' AND Num_Tarjeta = SUBSTR(TRIM(cNumCtaRec),5,16);
				ELSE
					LET cMotivoDev = '06'; --CUENTA NO PERTENECE AL BANCO RECEPTOR
				END IF;
				
				IF (cStatus_tar = 'C') THEN
					LET cMotivoDev = '03';
				END IF;
				
				LET cStatus_tar = ' ';
				LET cNumeroFolioAbono = '';
				LET mSaldoAPagar = ((cImporte::INTEGER)/100);
				
				--OBTIENE FOLIO DEL CARGO
				EXECUTE PROCEDURE BdiCheq:"informix".Sp_GeneraFolioNomina(cUsuario) INTO cCodRet, cNumeroFolioAbono;
				LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
				
				IF (cCodRet <> '00000') THEN --ERROR AL OBTENER EL FOLIO DEL ABONO
					LET cCodRet = '02304';
				ELSE --OK
					--REALIZA EL CARGO
					EXECUTE PROCEDURE BdiCheq:"informix".Cargo_Ref ("001", cSucursalContable, cUsuario,  cTransaccCargo, 
									"0000", cNumeroFolioAbono, cCuenta,0, mSaldoAPagar, '01', cRefLeyenda, '', cUsuario) INTO cCodRet, cTranRet, 
									dFechaHoy, mSaldoDisponible, mMontoRetenido;
				END IF;
			END IF;
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (iContadorRegistros = 1000) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET cFlagEnTransaccion = 'F';
				LET iContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
		END FOREACH;
		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((iContadorRegistros > 0) OR (cFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET cFlagEnTransaccion = 'F';
		END IF;
		--USAR SP DE BORRADO PARA LOS 2 ARCHIVOS.
		--BORRA LOS REGISTROS DE LOS ARCHIVOS 62
		LET cDescripcionProceso = 'BORRA LOS REGISTROS DE LOS ARCHIVOS 62';
		EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(cNomArchivo62, cFechaPresentacionGen, 'B', '') INTO cCodRet;
		LET cCodRet = iSQLerr;
		RETURN cCodRet;
	END IF;
END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;
	
	-------SE OBTIENEN LOS PARAMETROS----
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cClaveBancaria FROM BdiTef:"informix".Tef_Parametros WHERE cod_param = '75';
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cPrefijoTarjetaDebito FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76'; -- PREFIJO TARJETA DEBITO
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cSucursalContable FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77'; --SUCURSAL CONTABLE
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cTransaccCargo FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '78'; --TRANSACCION CARGO TEF
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO cTransaccAbono FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '79'; --TRANSACCION ABONO TEF
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--EXTRAE LA FECHA HOY EN EL SISTEMA
	SELECT FIRST 1 Fecha_hoy INTO dFechaHoy FROM BdiCheq:"informix".sc_fechas;
	
	--ASIGNA UN FORMATO DE FECHA PARA FUTURA FECHA DE PRESENTACION
	LET cFechaPresentacionGen = YEAR(dFechaHoy)|| LPAD(MONTH (dFechaHoy),2,'0') || LPAD(DAY (dFechaHoy),2,'0');
	
	--VALIDA LA FECHA ACTUAL
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(cFechaPresentacionGen) INTO cCodRet3;
	
	--VALIDA QUE LA FECHA ACTUAL SEA DIA HABIL
	EXECUTE PROCEDURE BdInteg:"informix".sp_Valfecha_Banca('001', dFechaHoy, 0 ) INTO cCodRet2,dFechaHabil;
	
	IF cNombreArchivo = '' THEN --AUTOMATICO 
		LET cFlagTipoProceso = 'A';
	ELSE 
		LET cFlagTipoProceso = 'M';
	END IF;
	
	IF (NOT EXISTS (SELECT Sucursal FROM BdInteg:"informix".Si_Sucursales WHERE Sucursal = cSucursalContable)) THEN --VALIDAR SI EXISTE EN EL CATÃÂÃÂLOGO LA SUCURSAL CONTABLE.
		LET cCodRet = '02300';
	--ELIF (cCodRet2 <> '000') THEN -- VALIDA KE LA FECHA HOY SEA UN DIA HABIL
	ELIF (dFechaHoy <> dFechaHabil) THEN -- VALIDA KE LA FECHA HOY SEA UN DIA HABIL
		LET cCodRet = '02302';
	ELIF (cCodRet3 <> '00000') THEN -- VALIDA KE LA FECHA HOY SEA VALIDA
		LET cCodRet = '02303';
	ELSE
		LET cFlagEnTransaccion = 'F';
		LET iContadorRegistros = 0;
		LET iContadorSecuencia62 = 1; --A PARTIR DE 2 ES PARA EL DETALLE
		LET iImporteTotalArchivo62 = 0;
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF cNombreArchivo = '' THEN --AUTOMATICO 
			LET cFlagTipoProceso = 'A';
			IF EXISTS(SELECT Nombre_Arch 
			FROM BdiTef:"informix".Tef_Cce_Detalle dhist
			WHERE dhist.Fecha_aplica = cFechaPresentacionGen AND dhist.Cod_operacion = '60' 
			AND dhist.Cve_Status = '00') THEN
				IF EXISTS (SELECT 1 FROM tef_cce_detalle_paso WHERE fecha_aplica = cFechaPresentacionGen AND cod_operacion = '60' AND cve_Status = '00') THEN
					DELETE FROM tef_cce_detalle_paso WHERE fecha_aplica = cFechaPresentacionGen AND cod_operacion = '60' AND cve_Status = '00';
				END IF;
				INSERT INTO BdiTef:"informix".tef_cce_detalle_paso 
				(Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, Banco_Presentador, 
				Banco_Receptor, Importe, Uso_Futuro_Ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, Num_Cta_Ord, Nombre_Ord, Rfc_Ord, 
				Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, 
				Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, 
				Tasa_Tiie_Prom, Dias_Retraso, Imp_Tot_Int, Cve_Status, Folio_Suc, User_Insert, Fecha_Insert) 
				SELECT dhist.Nombre_Arch, dhist.Fecha_Presentacion, dhist.Tipo_Registro, dhist.Num_Secuencia, dhist.Cod_Operacion, dhist.Cod_Divisa, dhist.Fecha_Trans, dhist.Banco_Presentador, 
				dhist.Banco_Receptor, dhist.Importe, dhist.Uso_Futuro_Ccen, dhist.Tipo_Operacion, dhist.Fecha_Aplica, dhist.Tipo_Cta_Ord, dhist.Num_Cta_Ord, dhist.Nombre_Ord, dhist.Rfc_Ord, 
				dhist.Tipo_Cta_Rec, dhist.Num_Cta_Rec, dhist.Nombre_Rec, dhist.Rfc_Rec, dhist.Ref_Servicio, dhist.Nombre_Titular_Serv, dhist.Importe_Iva, dhist.Ref_Numerica, dhist.Ref_Leyenda, 
				dhist.Clave_Rastreo, dhist.Motivo_Dev, dhist.Fecha_Pres_Ini, dhist.Solicitud_Confirmacion, dhist.Uso_Futuro_Banco, dhist.Ref_Confirmacion, dhist.Uso_Futuro_Cce, 
				dhist.Tasa_Tiie_Prom, dhist.Dias_Retraso, dhist.Imp_Tot_Int, dhist.Cve_Status, dhist.Folio_Suc, dhist.User_Insert, Fecha_Insert 
				FROM BdiTef:"informix".Tef_Cce_Detalle dhist
				WHERE dhist.Fecha_aplica = cFechaPresentacionGen AND dhist.Cod_operacion = '60' 
				AND dhist.Cve_Status = '00';
			END IF;
		ELSE--MANUAL
			LET cFlagTipoProceso = 'M';
			LET cNombreArchivo = cNombreArchivo;
			IF EXISTS (SELECT 1 FROM tef_cce_detalle_paso WHERE nombre_arch = cNombreArchivo AND cod_operacion = '60' AND cve_Status = '00') THEN
				DELETE FROM tef_cce_detalle_paso WHERE nombre_arch = cNombreArchivo AND cod_operacion = '60' AND cve_Status = '00';
			END IF;
			
			INSERT INTO tef_cce_detalle_paso 
			(Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, Banco_Presentador, 
			Banco_Receptor, Importe, Uso_Futuro_Ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, Num_Cta_Ord, Nombre_Ord, Rfc_Ord, 
			Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, 
			Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, 
			Tasa_Tiie_Prom, Dias_Retraso, Imp_Tot_Int, Cve_Status, Folio_Suc, User_Insert, Fecha_Insert) 
			SELECT dhist.Nombre_Arch, dhist.Fecha_Presentacion, dhist.Tipo_Registro, dhist.Num_Secuencia, dhist.Cod_Operacion, dhist.Cod_Divisa, dhist.Fecha_Trans, dhist.Banco_Presentador, 
			dhist.Banco_Receptor, dhist.Importe, dhist.Uso_Futuro_Ccen, dhist.Tipo_Operacion, dhist.Fecha_Aplica, dhist.Tipo_Cta_Ord, dhist.Num_Cta_Ord, dhist.Nombre_Ord, dhist.Rfc_Ord, 
			dhist.Tipo_Cta_Rec, dhist.Num_Cta_Rec, dhist.Nombre_Rec, dhist.Rfc_Rec, dhist.Ref_Servicio, dhist.Nombre_Titular_Serv, dhist.Importe_Iva, dhist.Ref_Numerica, dhist.Ref_Leyenda, 
			dhist.Clave_Rastreo, dhist.Motivo_Dev, dhist.Fecha_Pres_Ini, dhist.Solicitud_Confirmacion, dhist.Uso_Futuro_Banco, dhist.Ref_Confirmacion, dhist.Uso_Futuro_Cce, 
			dhist.Tasa_Tiie_Prom, dhist.Dias_Retraso, dhist.Imp_Tot_Int, dhist.Cve_Status, dhist.Folio_Suc, dhist.User_Insert, dhist.Fecha_Insert 
			FROM BdiTef:"informix".Tef_Cce_Detalle dhist
			WHERE dhist.Cod_operacion = '60' 
			AND dhist.Cve_Status = '00' AND dhist.Nombre_Arch = cNombreArchivo;
		END IF;
		
		LET cDescripcionProceso		= 'Validacion inicial en tabla de detalle ';
		IF DBINFO('sqlca.sqlerrd2') > 0 THEN		
		
			FOREACH WITH HOLD
				SELECT DISTINCT nombre_arch INTO cNombreArchivo
				FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
				WHERE Cod_operacion = '60' AND Cve_Status = '00'
				LET cDescripcionProceso = 'Validacion de procesamientos previos.';
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, 'RECARCH_' || 62 || '.' || SUBSTRING (TRIM(cNombreArchivo) FROM 15 FOR 2), cDescripcionProceso,
				--cPROCESANDO, cCodRet, cUsuario, 'sp_tef_generararchivo62', TRIM(cNombreArchivo), cFechaPresentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRet;
				
				LET cCodRet = '00000';
				--NUMERO DE ARCHIVO
				LET iNumArchivos = 1;
				
				LET cNomArchivo62 = 'E'
					|| TRIM(cClaveBancaria) --ID BANCARIA BANCOPPEL 137
					|| LPAD(DAY(dFechaHoy),2,'0') --dd
					|| LPAD(MONTH(dFechaHoy),2,'0') --mm
					|| YEAR(dFechaHoy)  --aaaa
					|| '.62'--oo
					|| LPAD (iNumArchivos, 2, '0'); --cc
				
				
				--OBTIENE LOS REGISTROS VALIDOS DEL ARCHIVO 60 PARA PROCESAR
				FOREACH WITH HOLD
					SELECT
					Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans,
					Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord,
					Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio,
					Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini,
					Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso,
					Imp_Tot_Int, Cve_Status, Folio_Suc
					INTO
					cNombreArch, cFechaPresentacion, cTipoRegistro, cNumSecuencia, cCodOperacion, cCodDivisa, cFechaTrans,
					cBancoPresentador, cBancoReceptor, cImporte, cUsoFuturoCcen, cTipoOperacion, cFechaAplica, cTipoCtaOrd,
					cNumCtaOrd, cNombreOrd, cRfcOrd, cTipoCtaRec, cNumCtaRec, cNombreRec, cRfcRec, cRefServicio,
					cNombreTitularServ, cImporteIva, cRefNumerica, cRefLeyenda, cClaveRastreo, cMotivoDev, cFechaPresIni,
					cSolicitudConfirmacion, cUsoFuturoBanco, cRefConfirmacion, cUsoFuturoCce, cTasaTiieProm, cDiasRetraso,
					cImpTotInt, cCveEstatus, cFolioSuc
					FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
					WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60'
					AND Cve_Status = '00'
					ORDER BY Num_Secuencia ASC
					
					--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
					IF (cFlagEnTransaccion = 'F') THEN
						 BEGIN WORK;
						 LET cFlagEnTransaccion = 'V';
					END IF;
					
					LET cMotivoDev = '00';
					LET cStatus_Cta = '';
					LET cCodRet = '00000';
					
					--VALIDACION DE CUENTAS
					-- 1.- Motivo 06 "CUENTA NO PERTENECE AL BANCO RECEPTOR" 
					IF ( TRIM(cTipoCtaRec) IN ('11','12','13') ) THEN    --VALIDACION PARA CONOCER SI ES CREDITO O DEBITO
						--LA CUENTA ES DE CREDITO
						LET cCuenta = SUBSTR(cNumCtaRec,9,12);
						
						IF ( EXISTS ( SELECT Num_Credito FROM BdiCred:Sd_MaeCred
							WHERE Empresa = '001' AND Num_Credito = cCuenta ) )  THEN --VALIDA NUMERO DE CREDITO
							IF ( EXISTS ( SELECT NUM_CREDITO FROM BDICRED:"informix".Sd_MaeCred
								WHERE EMPRESA = '001' AND NUM_CREDITO = cCuenta AND status_cred IN ('AA','BT','BA') ) ) THEN
								
								SET LOCK MODE TO WAIT 3;
								SET ISOLATION TO DIRTY READ;
								SELECT NVL(VALOR,'') INTO cTransacAbonoCred FROM BDITEF:"informix".tef_parametros WHERE cod_param='83';
								LET cNumeroFolioAbono = '';
								LET mSaldoAPagar = ((cImporte::INTEGER)/100);
								
								--OBTIENE FOLIO DEL ABONO
								EXECUTE PROCEDURE BdiCheq:"informix".Sp_GeneraFolioNomina(cUsuario) INTO cCodRet, cNumeroFolioAbono;
								LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
								
								IF (cCodRet <> '00000') THEN --ERROR AL OBTENER EL FOLIO DEL ABONO
									LET cCodRet = '02304';
								ELSE --OK
									--REALIZA EL ABONO
									EXECUTE PROCEDURE bdicred:"informix".principal(
									'001',					--Empresa
									cNumCtaRec,				--numcredito
									2,						--Tipo de pago
									mSaldoAPagar,			--Monto
									cUsuario, 				--Usuario
									cSucursalContable,		--Sucursal
									cNumeroFolioAbono, 		--Folio
									cTransacAbonoCred		--Transaccion
									) INTO
									cCodRet, mRemanente, mIntMoraCob, mIntVencCob, mCapVencCob,
									mIntVigCob, mCapVigCob, mImpuesto, mComision, mSeguro;
								END IF;
							ELSE
								LET cMotivoDev = '02'; --LA CUENTA DE CREDITO NO ESTA ACTIVA
							END IF;
						ELSE
							LET cMotivoDev = '01'; --LA CUENTA DE CREDITO NO EXISTE
						END IF;
					ELSE
						--*
						IF (TRIM(NVL(cTipoCtaRec, '')) = '10') THEN -- VALIDAMOS TIPO CUENTA MOVIL
							-- EJECUTAMOS EL PROCEDIMIENTO NUEVO 
							EXECUTE PROCEDURE bdicheq:"informix".sp_tef_constelctacte (SUBSTR(cNumCtaRec, 11,10)) -- OBTENEMOS LA CUENTA DEL NUMERO MOVIL 
							INTO cCodRet, cNumCte, cCuenta, sCanal, cEsTransfer, cUserInsert, dtFechaHoraInsert;
		
							-- SI NO HAY CUENTA PARA EL  MOVIL, ASIGNAMOS MOTIVO DEVOLUCIÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂN.
							IF TRIM(cCuenta) = '' THEN	
								LET cMotivoDev = '01'; -- CUENTA INEXISTENTE.
							END IF;
							--*
						ELIF ( TRIM(cTipoCtaRec) = '40') THEN    --ES UNA NUEVA CLABE
							LET cCuenta = SUBSTR(cNumCtaRec,9,11);
						ELIF ( TRIM(cTipoCtaRec) = '03') THEN  --
							SELECT FIRST 1 NVL(Cuenta,''), status_tar INTO cCuenta, cStatus_tar FROM BdiCheq:"informix".Sc_Tarjeta WHERE Empresa = '001' AND Num_Tarjeta = SUBSTR(TRIM(cNumCtaRec),5,16);
						ELSE
							LET cMotivoDev = '06'; --CUENTA NO PERTENECE AL BANCO RECEPTOR
						END IF;
						
						IF (cStatus_tar = 'C') THEN
							LET cMotivoDev = '03';
						END IF;
						LET cStatus_tar = ' ';     
						
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						
						--OBTIENE DATOS DE LA CUENTA
						SELECT FIRST 1 NVL(Status_Cta, ''), NVL(Producto, '') INTO cStatus_Cta, cProducto FROM BdiCheq:"informix".Sc_MaeChq WHERE Empresa = '001' AND Cuenta = cCuenta;
						
						IF (NOT EXISTS (SELECT Cve_Producto FROM BdiTef:"informix".Tef_Prod_Permitidos WHERE Cve_Producto = cProducto) ) THEN --VALIDA QUE SEA UN PRODUCTO PERMITIDO
							LET cMotivoDev = '06'; --CLIENTE NO TIENE AUTORIZADO EL SERVICIO
						ELIF (NVL(cStatus_Cta, '') = '') THEN --VALIDA KE EXISTA LA CUENTA
							LET cMotivoDev = '01'; --CUENTA INEXISTENTE
						ELIF (cStatus_Cta = '3') THEN --VALIDA KE  LA CUENTA NO ESTE BLOQUEADA
							LET cMotivoDev = '02';
						ELIF (cStatus_Cta = '2') THEN --VALIDA KE  LA CUENTA NO ESTE CANCELADA
							LET cMotivoDev = '03';
						ELIF (NOT EXISTS (SELECT Divisa FROM BdiCheq:"informix".Sc_Producto WHERE Empresa = '001' AND Producto = cProducto AND Divisa = '01')) THEN
							LET cMotivoDev = '05';
						END IF;
						
						IF ((cMotivoDev = '00') AND --VALIDA SI NO HA SIDO RECHAZADO POR ALGUN MOTIVO
						(EXISTS (SELECT Num_Secuencia
						FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
						WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60'
						AND Banco_Presentador = cBancoPresentador
						AND Banco_Receptor = cBancoReceptor
						AND Importe = cImporte
						AND Fecha_Aplica = cFechaAplica
						AND Num_Cta_Ord = cNumCtaOrd
						AND Rfc_Ord = cRfcOrd
						AND Tipo_Cta_Rec = cTipoCtaRec
						AND nombre_ord = cNombreOrd
						AND Ref_Leyenda = cRefLeyenda
						AND Ref_Numerica = cRefNumerica
						AND num_cta_rec = cNumCtaRec
						AND clave_rastreo = cClaveRastreo
						AND Num_Secuencia::INTEGER < cNumSecuencia::INTEGER))) THEN --VALIDA KE NO SE REPITA EL REGISTRO
							LET cMotivoDev = '07';
						END IF;
						
						IF (cMotivoDev = '00') THEN --REGISTRO OK
							--APLICAR ABONO
							LET cNumeroFolioAbono = '';
							LET mSaldoAPagar = ((cImporte::INTEGER)/100);
							--OBTIENE FOLIO DEL ABONO
							EXECUTE PROCEDURE BdiCheq:"informix".Sp_GeneraFolioNomina(cUsuario) INTO cCodRet, cNumeroFolioAbono;
							LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
							IF (cCodRet <> '00000') THEN --ERROR AL OBTENER EL FOLIO DEL ABONO
							
								INSERT INTO Tef_Errores(fecha_error,hora_error,cod_error,Nombre_Arch,sp_llamado,mensaje_error,User_Insert,Fecha_Insert)
								VALUES (CURRENT,CURRENT HOUR TO FRACTION,NVL(cCodRet,''),NVL(cNombreArchivo,''),'Sp_GeneraFolioNomina','Error al obtener folio de abono',cUsuario,CURRENT);

								LET cCodRet = '02304';
							ELSE --OK
								--REALIZA EL ABONO
								EXECUTE PROCEDURE BdiCheq:"informix".Abono_Ref ("001", cSucursalContable, cUsuario,  cTransaccAbono, "0000", cNumeroFolioAbono, cCuenta,
								0, mSaldoAPagar, mSaldoAPagar, 0, 0, 0, "01",TRIM(cNumCtaOrd)||" "||TRIM(cRefLeyenda), '', cUsuario) INTO cCodRet;
							END IF;
						END IF;
					END IF;				
					LET cSolicitudConfirmacion = cSolicitudConfirmacion;
					IF ((cCodRet::INTEGER <> 0) OR (cMotivoDev <> '00')) THEN -- ERROR AL REALIZAR EL ABONO  / REGISTRO RECHAZADO 63
						--PASA A GENERACION ARCHIVO 63
						LET cMotivoDev = DECODE (cCodRet::INTEGER, 0, cMotivoDev, '06');
						LET cNombreArchivoAUX = '';
						LET cCveEstatus = '03';
						INSERT INTO Tef_Errores(fecha_error,hora_error,cod_error,Nombre_Arch,sp_llamado,mensaje_error,User_Insert,Fecha_Insert)
						VALUES (CURRENT,CURRENT HOUR TO FRACTION,NVL(cCodRet,''),NVL(cNombreArchivo,''),'Abono_Ref','Error al realizar abono a cuenta',cUsuario,CURRENT);
						
					ELIF (cCodRet::INTEGER = 0 AND cMotivoDev = '00')THEN --OK  62
						--GUARDA EL REGISTRO  CON  DE ABONO CORRECTO  EN EL ARCHIVO 62
						IF (cSolicitudConfirmacion = '1') THEN
							LET iContadorSecuencia62 = iContadorSecuencia62 + 1;
							LET iImporteTotalArchivo62 = iImporteTotalArchivo62 + NVL(cImporte,0)::INTEGER ;
							LET cMotivoDev = '00';
						END IF;
						LET cNombreArchivoAUX = cNomArchivo62;
						LET iContadorSecuenciaAUX = iContadorSecuencia62;
						LET cCveEstatus = '01';
					END IF;
					
					IF ((cCodRet::INTEGER = 0) AND (cSolicitudConfirmacion = '1'))THEN
						--INSERTA EL REGISTRO RECHAZADO EN EL ARCHIVO 62 o INSERTA EL REGISTRO 62 EN CASO DE CONFIRMACION
						INSERT INTO BdiTef:"informix".Tef_Cce_Detalle_Paso
						(	Nombre_Arch, Fecha_Presentacion, Tipo_Registro,Num_Secuencia,Cod_Operacion,Cod_Divisa,Fecha_Trans,Banco_Presentador,
							Banco_Receptor,Importe,Uso_Futuro_Ccen,Tipo_Operacion,Fecha_Aplica,Tipo_Cta_Ord,Num_Cta_Ord,Nombre_Ord,Rfc_Ord,
							Tipo_Cta_Rec,Num_Cta_Rec,Nombre_Rec,Rfc_Rec,Ref_Servicio,Nombre_Titular_Serv,Importe_Iva,Ref_Numerica,Ref_Leyenda,
							Clave_Rastreo,Motivo_Dev,Fecha_Pres_Ini,Solicitud_Confirmacion,Uso_Futuro_Banco,Ref_Confirmacion,Uso_Futuro_Cce,
							Tasa_Tiie_Prom,Dias_Retraso,Imp_Tot_Int,Cve_Status,Folio_Suc,User_Insert,Fecha_Insert
						)
						VALUES
						(
							NVL(cNombreArchivoAUX,''),
							NVL(cFechaPresentacionGen,''), -- cFechaPresentacionGen
							NVL(cTipoRegistro,''),
							NVL(LPAD(iContadorSecuenciaAUX,7,'0'),''),--NUM_SECUENCIA
							62, --CODIGO DE OPERACION / ARCHIVO
							NVL(cCodDivisa,''),
							NVL(cFechaTrans,''),
							NVL(cBancoReceptor,''),  --BANCO PRESENTADOR
							NVL(cBancoPresentador,''),  --BANCO RECEPTOR
							NVL(cImporte,''),
							NVL(cUsoFuturoCcen,''),
							NVL(cTipoOperacion,''),
							NVL(cFechaAplica,''),
							NVL(cTipoCtaOrd,''),
							NVL(cNumCtaOrd,''),
							NVL(cNombreOrd,''),
							NVL(cRfcOrd,''),
							NVL(cTipoCtaRec,''),
							NVL(cNumCtaRec,''),
							NVL(cNombreRec,''),
							NVL(cRfcRec,''),
							NVL(cRefServicio,''),
							NVL(cNombreTitularServ,''),
							NVL(cImporteIva,''),
							NVL(cRefNumerica,''),
							NVL(cRefLeyenda,''),
							NVL(cClaveRastreo,''),
							NVL(cMotivoDev,''), --MOTIVO DEVOLUCION
							NVL(cFechaPresIni,''),
							NVL(cSolicitudConfirmacion,''),
							NVL(cUsoFuturoBanco,''),
							NVL(DECODE (cNombreArchivoAUX, cNomArchivo62, (DECODE(cSolicitudConfirmacion,'1',cNumeroFolioAbono,cRefConfirmacion)), cRefConfirmacion),''),--REF_CONFIRMACION
							NVL(cUsoFuturoCce,''),
							NVL(cTasaTiieProm,''),
							NVL(cDiasRetraso,''),
							NVL(cImpTotInt,''),
							NVL(cCveEstatus,''),
							NVL(DECODE (cNombreArchivoAUX, cNomArchivo62, cNumeroFolioAbono, cFolioSuc),''), -- FOLIO_SUC
							cUsuario, --USUARIO_INSERT
							CURRENT::DATE --FECHA_INSERT
						);
					END IF;
					
					LET cDescripcionProceso = 'ACTUALIZA LA TABLA Tef_Cce_Detalle';
					LET cNomArchivo62 = cNomArchivo62;
					
					--dbs-02/07/2012 se cambia error por 03 para que se vaya por el archivo 63
					--ACTUALIZA EL REGISTRO DEL  ARCHIVO 60
					UPDATE BdiTef:"informix".Tef_Cce_Detalle
					SET Cve_Status = DECODE (cNombreArchivoAUX, cNomArchivo62, '01'/*OK*/, '03'/*ERROR*/),
					Folio_Suc = DECODE (cNombreArchivoAUX, cNomArchivo62, cNumeroFolioAbono, cFolioSuc),
					motivo_dev = cMotivoDev
					WHERE Nombre_Arch = cNombreArchivo
					AND Cod_operacion = '60'
					AND Banco_Presentador = cBancoPresentador
					AND Banco_Receptor = cBancoReceptor
					AND Importe = cImporte
					AND Fecha_Aplica = cFechaAplica
					AND Num_Cta_Ord = cNumCtaOrd
					AND Rfc_Ord = cRfcOrd
					AND Tipo_Cta_Rec = cTipoCtaRec
					AND Ref_Leyenda = cRefLeyenda
					AND Num_Secuencia = cNumSecuencia;
					
					--dbs-02/07/2012 se cambia error por 03 para que se vaya por el archivo 63
					--ACTUALIZA EL REGISTRO DEL  ARCHIVO 60 EN LA TABLA DE PASO
					UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso
					SET Cve_Status = DECODE (cNombreArchivoAUX, cNomArchivo62, '01'/*OK*/, '03'/*ERROR*/),
					Folio_Suc = DECODE (cNombreArchivoAUX, cNomArchivo62, cNumeroFolioAbono, cFolioSuc),
					motivo_dev = cMotivoDev
					WHERE Nombre_Arch = cNombreArchivo
					AND Cod_operacion = '60'
					AND Banco_Presentador = cBancoPresentador
					AND Banco_Receptor = cBancoReceptor
					AND Importe = cImporte
					AND Fecha_Aplica = cFechaAplica
					AND Num_Cta_Ord = cNumCtaOrd
					AND Rfc_Ord = cRfcOrd
					AND Tipo_Cta_Rec = cTipoCtaRec
					AND Ref_Leyenda = cRefLeyenda
					AND Num_Secuencia = cNumSecuencia;
					
					LET iContadorRegistros = iContadorRegistros + 1;
					
					--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
					COMMIT WORK;
					LET cFlagEnTransaccion = 'F';
					
				END FOREACH;
			END FOREACH;
			
			-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
			IF ((iContadorRegistros > 0) OR (cFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				LET cFlagEnTransaccion = 'F';
			END IF;

			IF iNumArchivos > 0 THEN
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--OBTIENE LOS DATOS DEL REGISTRO DE ENCABEZADO ORIGINAL 60
				SELECT FIRST 1 Cve_Banco, Servicio, Num_Bloque, Cod_Divisa, Cve_Rechazo_bl,
				Modalidad, Uso_Futuro_Ccen, Uso_Futuro_Banco
				INTO cCveBancoE, cServicioE, cNumBloqueE, cCodDivisaE, cCveRechazoblE,
				cModalidadE, cUsoFuturoCcenE, cUsoFuturoBancoE
				FROM BdiTef:"informix".Tef_Cce_Encabezado --ES TOMADO DEL HISTORICO
				WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60';
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--OBTIENE LOS DATOS DEL REGISTRO DE SUMARIO ORIGINAL 60
				SELECT FIRST 1 Num_Bloque, Uso_Futuro_ccen, Uso_Futuro_banco
				INTO cNumBloqueS, cUsoFuturoCcenS, cUsoFuturoBancoS
				FROM BdiTef:"informix".Tef_Cce_Sumario --ES TOMADO DEL HISTORICO
				WHERE Nombre_Arch = cNombreArchivo AND Cod_operacion = '60';
				
				IF (iContadorSecuencia62 > 1) THEN --VALIDA SI EXISTEN REGISTROS PARA EL ARCHIVO 62
					--FORMA EL REGISTRO DE ENCABEZADO
					--ENCABEZADO
					INSERT INTO BdiTef:"informix".Tef_Cce_Encabezado_Paso
					(
						Nombre_Arch,
						Fecha_Presentacion,
						Tpo_Registro,
						Num_Secuencia,
						Cod_Operacion,
						Cve_Banco,
						Sentido,
						Servicio,
						Num_Bloque,
						Cod_Divisa,
						Cve_Rechazo_bl,
						Modalidad,
						Uso_Futuro_Ccen,
						Uso_Futuro_Banco,
						User_Insert,
						Fecha_Insert
					)
					VALUES
					(
						NVL(cNomArchivo62,'') ,
						NVL(cFechaPresentacionGen,''),
						'01', --TIPO REGISTRO
						NVL(LPAD('1',7,'0'),''), --'0000001', --SECUENCIA
						'62', --ARCHIVO
						NVL(cCveBancoE,''), --BANCOPEL 137
						'E', --SENTIDO
						NVL(cServicioE,''), --SERVICIO
						NVL(SUBSTR(cFechaPresentacionGen, 7, 2) || LPAD((SUBSTR(cNomArchivo62,(LENGTH(TRIM(cNomArchivo62)) - 1), 2)),5,'0'),''), --NUM BLOQUE
						NVL(cCodDivisaE,''), --DIVISA
						NVL(cCveRechazoblE,''),--CVE_RECHAZO_BL
						NVL(cModalidadE,''),--MODALIDAD
						NVL(cUsoFuturoCcenE,''), --USO_FUTURO_CCEN
						NVL(cUsoFuturoBancoE,''),--USO_FUTURO_BANCO
						cUsuario,
						CURRENT::DATE
					);
					
					--FORMA EL REGISTRO DE SUMARIO
					--SUMARIO
					INSERT INTO BdiTef:"informix".Tef_Cce_Sumario_Paso
					(
						Nombre_Arch,
						Fecha_Presentacion,
						Tipo_Registro,
						Num_Secuencia,
						Cod_Operacion,
						Num_Bloque,
						Num_Operaciones,
						Imp_Operaciones,
						Uso_Futuro_ccen,
						Uso_Futuro_banco,
						User_Insert,
						Fecha_Insert
					)
					VALUES
					(
						NVL(cNomArchivo62,''), --NOMBRE_ARCH
						NVL(cFechaPresentacionGen,''), --FECHA_PRESENTACION
						'09', --TIPO_REGISTRO
						NVL(LPAD((iContadorSecuencia62+1),7,'0'),''), --SECUENCIA
						'62', --COD_OPERACION
						NVL(SUBSTR(cFechaPresentacionGen, 7, 2) || LPAD((SUBSTR(cNomArchivo62,(LENGTH(TRIM(cNomArchivo62)) - 1), 2)),5,'0'),''), --NUM BLOQUE
						NVL(LPAD((iContadorSecuencia62-1),7,'0'),''),--NUM_OPERACIONES -- REGISTROS EN EL DETALLE
						NVL(LPAD(iImporteTotalArchivo62,18,'0'),''),--IMPORTE TOTAL DE OPERACIONES
						NVL(cUsoFuturoCcenS,''),--USO_FUTURO_CCEN
						NVL(cUsoFuturoBancoS,''),--USO_FUTURO_BANCO
						cUsuario, --USUARIO_INSERT
						CURRENT::DATE --FECHA_INSERT
					);
				END IF;
				
				LET cCodRet = '00000';
				LET cDescripcionProceso = 'CREAR EL ARCHIVO 62.';
			
				IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE nombre_arch = TRIM(cNomArchivo62))THEN 
					IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE nombre_arch = TRIM(cNomArchivo62))THEN
						IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Sumario_Paso WHERE nombre_arch = TRIM(cNomArchivo62))THEN
							LET cFlagArch62 = 'V';
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT LIMIT 1 Fecha_Presentacion INTO cFechaPresentacion FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(cNomArchivo62) ;
							EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GeneraArchivo (62, TRIM (cNomArchivo62), cFechaPresentacion, '72'/*RUTA ARCHIVO RESPUESTA*/ ) INTO cCodRet;
						END IF;
					END IF;
				END IF;
				
				LET cDescripcionProceso = 'Mover Registros Procesados a la Tabla de Historico.';
				IF (cCodRet = '00000') THEN -- VALIDA QUE EL ARCHIVO SE HA GENERADO CORRECTAMENTE
					IF (cFlagArch62 = 'V') THEN 
						EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cUsuario, TRIM (cNomArchivo62), cFechaPresentacion, '01') INTO cCodRet;
						
						IF (cCodRet = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO
							LET cDescripcionProceso = 'VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO';
							EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (cNomArchivo62), cFechaPresentacion, 'T', '') INTO cCodRet;
						ELSE --ERROR
						END IF;
					END IF;
					IF (cCodRet = '00000') THEN --VALIDA QUE EL REGISTRO SE PASO ADECUADAMENTE AL HISTORICO
						--BORRAR DEL HISTORICO EL REGISTRO DEL ARCHIVO
						LET cDescripcionProceso = 'BORRAR DEL HISTORICO EL REGISTRO DEL ARCHIVO';
						EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(TRIM(cNombreArchivo), '', 'B', '') INTO cCodRet;
					END IF;
				ELSE 
				END IF;
			ELSE 
				--NO SE ENCONTRARON REGISTROS POR PROCESAR
				LET cCodRet = '00325';
			END IF --IF DE ARCHIVOS PROCESADOS		
		ELSE
			--NO SE ENCONTRARON REGISTROS EN TABLAS DE DETALLE
			LET cCodRet = '02305';
		END IF;
	END IF; --	IF DE SUCURSAL
	
	IF (cCodRet = '00000') THEN
		LET cDescripcionProceso = 'TEF Finalizado Exitosamente.';
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE,'RECARCH_' || 62 || '.' || SUBSTRING (TRIM(cNombreArchivo) FROM 15 FOR 2), cDescripcionProceso,cFINALIZADO, cCodRet, cUsuario, 'sp_tef_generararchivo62.sql', TRIM(cNomArchivo62) , cFechaPresentacion, '02'/*EXITO*/ ) INTO cCodRet;
	ELSE 
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, 'RECARCH_' || 62 || '.' || SUBSTRING (TRIM(cNombreArchivo) FROM 15 FOR 2), cDescripcionProceso,cERROR, cCodRet, cUsuario, 'sp_tef_generararchivo62.sql', TRIM(cNomArchivo62) , cFechaPresentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRet;
	END IF
	RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'Autor: Victor Hugo NuÃÂÃÂ±ez',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Javier Vazquez',
'Descripcion: Procesa los abonos y generacion del archivo 62',
'Fecha: 02/05/2012',
'Version: 20120502.0913',
'BD: BdiTef',
'Modifico: Victor Hugo NuÃÂÃÂ±ez',
'Modificacion: Se modifica para que valida que el archivo 61 no haya sido generado anteriormente y no lo mueva al hstorico nuevamente',
'Solicito: Javier Vazquez',
'Fecha: 01/06/2012',
'Version: 20120601.1900',
'BD: BdiTef',
'Modifico: Victor Hugo NuÃÂÃÂ±ez',
'Modificacion: Se elimina generacion del archivo 61 se pasa el estado a 03 para generacion de archivo 63 en caso de error',
'Solicito: Javier Vazquez',
'Fecha: 02/07/2012',
'Version: 20120702.1900',
'BD: BdiTef',
'',
'Modificado: Francisco Eduardo Benitez Baez',
'Proyecto: NÃÂÃÂºmero mÃÂÃÂ³vil en transferencias TEF',
'Solicito: MartÃÂÃÂ­n Pineda',
'Descripcion: Se agrega nuevo procedimiento de busqueda de telefono',
'		y se valida en caso de que no haya despliega mensaje', 
'Fecha: 24/09/2014',
'Version: 20140924.0937',
'AUTOR : Viridiana PR',
'DESCRIPCION: se concateno el valor de la cuenta origen con la 	referencia leyenda',
'FECHA : MAYO 2015',
'VERSION: 20150528',
'BD    : bditef',
'Modificado: Francisco Eduardo Benitez Baez',
'Proyecto: RQI 64 125 - Mantenimiento Generacion Archivo 62 TEF',
'Modifico: Jose Angel Lopez Adams',
'Descripcion: Se agrega registro en la tabla tef_errores en caso de que la respuesta del SP abono_ref no sea exitosa',
'Fecha: 06/11/2015',
'********************************************************************************************************************',
'Proyecto: RQI 64 157 - Mantenimiento generacion 62 TEF',
'Descripcion: Se modifica validacion para que el proceso no se ejecute en dias inhabiles segun respuesta del SP sp_Valfecha_Banca',
'Fecha: 31/03/2016',
'********************************************************************************************************************',
'MODIFICACION',
'MODIFICO: Trinidad HernÃÂÃÂ¡ndez',
'folio: 73',
'DESCRIPCION: "HomologaciÃÂÃÂ³n de caja appriza con RQM 10-239-5 Y RQM 10-495 y cambio BTS_parametro sucursal"; HomologaciÃÂÃÂ³n con Vers. Prod., Pago de remesas Appriza',
'FECHA : 22/06/2016',
'VERSION: 20160622.1019',
'BD    : BdiTef';

CREATE PROCEDURE "informix".sp_obtenerchequescce_pba3(pEmpresa CHAR(3),pBanco CHAR(3),pNumCta CHAR(20), pNumChq CHAR(7),pFormato CHAR(3), pFechaAlta DATE)
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(3),        -- BANCO
            CHAR(40),       -- DESCRIPCION BANCO           
			CHAR(20),		-- CUENTA
			CHAR(7),		-- NUMERO CHEQUE
			CHAR(1),   		-- LADO
			DATE,  		    -- FECHA ALTA
			DATE,			--FECHA PRESENTA
			CHAR(8);		--USUARIO ALTA
			
DEFINE iSqlErr       	INT;
DEFINE cCodret       	CHAR(5);  
DEFINE cBanco		 	CHAR(3);
DEFINE cDescripcion		CHAR(40);
DEFINE cNumcta		 	CHAR(20);
DEFINE cNumchq		 	CHAR(7);
DEFINE cLado 		 	CHAR(1);
DEFINE dFechaAlta	 	DATE;
DEFINE dFechaPresenta	DATE;
DEFINE cUsuarioAlta		CHAR(8);

LET cCodret			= '00000';  
LET cBanco			= '';
LET cDescripcion	= '';
LET cNumcta			= '';
LET cNumchq			= '';
LET cLado 			= '';
LET dFechaAlta		= '';
LET dFechaPresenta	= '';
LET cUsuarioAlta	= '';
LET iSqlErr         = 0;


BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta;   
        END IF;
   END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--	TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pFechaAlta IS NULL OR pFechaAlta = '' THEN

	
		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE
			SELECT {+MULTI_INDEX(bditef:cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC, a.fecha_alta ASC 	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH

	ELSE 

		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE

			SELECT {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img2)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				AND a.fecha_alta = pFechaAlta 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH
	END IF;
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100305.0831';

CREATE PROCEDURE "informix".sp_obtenerchequescce_pbas2(pEmpresa CHAR(3),pBanco CHAR(3),pNumCta CHAR(20), pNumChq CHAR(7),pFormato CHAR(3), pFechaAlta DATE)
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(3),        -- BANCO
            CHAR(40),       -- DESCRIPCION BANCO           
			CHAR(20),		-- CUENTA
			CHAR(7),		-- NUMERO CHEQUE
			CHAR(1),   		-- LADO
			DATE,  		    -- FECHA ALTA
			DATE,			--FECHA PRESENTA
			CHAR(8);		--USUARIO ALTA
			
DEFINE iSqlErr       	INT;
DEFINE cCodret       	CHAR(5);  
DEFINE cBanco		 	CHAR(3);
DEFINE cDescripcion		CHAR(40);
DEFINE cNumcta		 	CHAR(20);
DEFINE cNumchq		 	CHAR(7);
DEFINE cLado 		 	CHAR(1);
DEFINE dFechaAlta	 	DATE;
DEFINE dFechaPresenta	DATE;
DEFINE cUsuarioAlta		CHAR(8);

LET cCodret			= '00000';  
LET cBanco			= '';
LET cDescripcion	= '';
LET cNumcta			= '';
LET cNumchq			= '';
LET cLado 			= '';
LET dFechaAlta		= '';
LET dFechaPresenta	= '';
LET cUsuarioAlta	= '';
LET iSqlErr         = 0;


BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta;   
        END IF;
   END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--	TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pFechaAlta IS NULL OR pFechaAlta = '' THEN

	
		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE
			SELECT -- {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC, a.fecha_alta ASC 	

			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH

	ELSE 

		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE

			SELECT -- {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				AND a.fecha_alta = pFechaAlta 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH
	END IF;
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100305.0831';

CREATE PROCEDURE "informix".sp_obtenerchequescce(pEmpresa CHAR(3),pBanco CHAR(3),pNumCta CHAR(20), pNumChq CHAR(7),pFormato CHAR(3), pFechaAlta DATE)
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(3),        -- BANCO
            CHAR(40),       -- DESCRIPCION BANCO           
			CHAR(20),		-- CUENTA
			CHAR(7),		-- NUMERO CHEQUE
			CHAR(1),   		-- LADO
			DATE,  		    -- FECHA ALTA
			DATE,			--FECHA PRESENTA
			CHAR(8);		--USUARIO ALTA
			
DEFINE iSqlErr       	INT;
DEFINE cCodret       	CHAR(5);  
DEFINE cBanco		 	CHAR(3);
DEFINE cDescripcion		CHAR(40);
DEFINE cNumcta		 	CHAR(20);
DEFINE cNumchq		 	CHAR(7);
DEFINE cLado 		 	CHAR(1);
DEFINE dFechaAlta	 	DATE;
DEFINE dFechaPresenta	DATE;
DEFINE cUsuarioAlta		CHAR(8);

LET cCodret			= '00000';  
LET cBanco			= '';
LET cDescripcion	= '';
LET cNumcta			= '';
LET cNumchq			= '';
LET cLado 			= '';
LET dFechaAlta		= '';
LET dFechaPresenta	= '';
LET cUsuarioAlta	= '';
LET iSqlErr         = 0;


BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta;   
        END IF;
   END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--	TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pFechaAlta IS NULL OR pFechaAlta = '' THEN

	
		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE
			SELECT --{+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC, a.fecha_alta ASC 	

			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH

	ELSE 

		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE

			SELECT -- {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				AND a.fecha_alta = pFechaAlta 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH
	END IF;
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100305.0831';

create procedure "informix".cons_img_nula(pempresa       char(3),
                                          pcvebanco   	 char(3),
                                          pnumcuenta   	 char(20),
                                          pnumcheque   	 char(7),
                                          plado_ft       char(1),
                                          pfechapresenta char(10))
RETURNING char(5);  

    DEFINE v_codret char(5);
    DEFINE sql_err,isam_err int;   
    --DEFINE v_existe char(1);
	DEFINE iimagen  int;

    -- // Inicializa variables
    LET v_codret    = "000";
    --LET v_existe    = "0";
	LET iimagen     = "0";
    
    -- // Valida la informacion de entrada
    IF pempresa    	  is null or
       pcvebanco      is null or
       pnumcuenta     is null or
       pnumcheque     is null or
       plado_ft       is null or
       pfechapresenta is null THEN
        LET v_codret = 110; -- // datos de entrada incompletos
        RETURN v_codret; 
    END IF;
    
    BEGIN

		on exception set sql_err,isam_err
			if sql_err <> 0 or isam_err <> 0 then
				let v_codret = sql_err;
				return v_codret;
			end if;
		end exception;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	

		select length(imagen::lvarchar) 
		INTO iimagen
		from "informix".cce_cheques_img
		 where empresa = pempresa
		   and cvebanco = pcvebanco
		   and numcuenta = pnumcuenta
		   and numcheque = pnumcheque
		   and lado_ft = plado_ft
		   and fechapresenta = pfechapresenta;

        IF iimagen is null or iimagen = '' THEN
            LET v_codret = 130; 
            RETURN v_codret;                 
        END IF;
    
    END;    

    RETURN v_codret;

END PROCEDURE;