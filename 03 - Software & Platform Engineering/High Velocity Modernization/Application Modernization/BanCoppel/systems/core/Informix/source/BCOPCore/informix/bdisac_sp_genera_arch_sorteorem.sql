CREATE PROCEDURE "informix".sp_genera_arch_sorteorem(MesAnio CHAR(6))

	RETURNING
		CHAR	(25) as archivo,
		CHAR	(5) as codret,
		CHAR	(100) as mensaje;

	-- DECLARACION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE iSamErr			INTEGER;
	DEFINE cProceso			CHAR(100);
	DEFINE cCodRet			CHAR(5);
	DEFINE cVarError		CHAR(100);
	DEFINE cRuta			CHAR(50);
	DEFINE cNombreArchivo	CHAR(50);
	DEFINE cSQL 			CHAR(2400);
	DEFINE cAnioMesAct		CHAR(6);
	DEFINE cFechaIni		DATE;
	DEFINE cFechaFin		DATE;
	DEFINE vFolioSorteo		INTEGER;
	

	-- INICIALIZAN LAS VARIABLES
	LET cProceso = 'ArchsSorteoRemesas';
	LET cCodRet = '00000';
	LET cVarError = 'Ejecucion Exitosa';
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo = 'sorteoRem_';
	LET cSQL = '';
	LET cAnioMesAct='';
	LET cFechaIni = '';
	LET cFechaFin = '';
	LET vFolioSorteo = 0;
	

	BEGIN

	-- CONTROL DE ERRORES
	ON EXCEPTION SET iSqlErr, iSamErr, cVarError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cVarError = 'Error No Controlado';

			SET DEBUG FILE TO "/informix/RESPALDOSNEW/sp_genera_arch_sorteorem.out";
			TRACE ON;

			INSERT INTO "informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
  			VALUES(trim(cProceso) || ': ' || iSqlErr, Today, '0', 'informix', current, 1, 'sp_genera_arch_sorteorem', 'Genera Archivo Mensual del Sorteo Remesas 2020');


			RETURN cProceso, cCodRet, cVarError;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/noe/sp_genera_arch_sorteorem.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	
--OBTIENE LOS DIAS INICIO Y FIN DEL MES ANTERIOR
	IF length(MesAnio)=6 THEN
		SELECT first 1 mdy(SUBSTR(MesAnio,1,2),'01',SUBSTR(MesAnio,3,4)) inicio, CAST((mdy(SUBSTR(MesAnio,1,2),'01',SUBSTR(MesAnio,3,4))+01 UNITS MONTH)-1 UNITS DAY AS DATE) fin 
		INTO cFechaIni, cFechaFin
		FROM sac_fechas;
		
		LET cAnioMesAct=MesAnio;
	ELSE
		SELECT first 1 date(LAST_DAY(ADD_MONTHS(today, -2)) + 1), date(LAST_DAY(ADD_MONTHS(today, -1))), TO_CHAR(TODAY-1 UNITS MONTH, '%m%Y')
		INTO cFechaIni, cFechaFin, cAnioMesAct
		FROM systables WHERE tabid = 1;
	END IF;

--SE HABILITA PARA CONCURSOS 2021------
	SELECT date((SELECT to_date(substr(valor,1,10),'%d/%m/%Y') FROM sac_param WHERE cod_param='200')), date((SELECT to_date(substr(valor,12,10),'%d/%m/%Y') FROM sac_param WHERE cod_param='200')), TO_CHAR(TODAY-1 UNITS MONTH, '%m%Y')
	INTO cFechaIni, cFechaFin, cAnioMesAct
	FROM sac_fechas;
---------------------------------------


--ARCHIVO 1
	--NOMBRE DEL ARCHIVO
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo = 'sorteoRem_' || cAnioMesAct || '.unl';
	--BORRA ARCHIVOS SI YA EXISTIERAN
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.gz';
	SYSTEM cSQL;
	--ARCHIVO 
	LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || cNombreArchivo || ' DELIMITER ' || '''|''' || ' SELECT lpad(consecutivo,10,' || '''0''' || ') folio, ciudad, servicio, fecha_movto, trim(nom_cte), telefono, trim(correo) correo from sac_sorteo_remesas where fecha_cheques between ''' || cFechaIni || ''' AND ''' || cFechaFin || ''' and enviado=' || '''0''' || ' order by folio,fecha_movto asc;" >' || TRIM(cRuta) || 'descargaArchSortRem.sql';
	SYSTEM cSQL;
	LET cSQL = '';
	--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'descargaArchSortRem.sql' ;
	--EJECUTA EL ARCHIVO
	LET cSQL='dbaccess bdisac ' || TRIM(cRuta) || 'descargaArchSortRem.sql';
	SYSTEM cSQL;
	--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'descargaArchSortRem.sql';
	SYSTEM cSQL;
	LET cSQL = '';
	--COMPRIME ARCHIVOS
	LET cSQL = '';
	LET cSQL = 'gzip ' || TRIM(cRuta) || TRIM(cNombreArchivo);
	SYSTEM cSQL;
	--SE BORRA ARCHIVO SIN COMPRIMIR
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo);
	SYSTEM cSQL;
	LET cSQL = '';

--ARCHIVO 2
	--NOMBRE DEL ARCHIVO
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo = 'sorteoRem_' || cAnioMesAct || '_bcpl.unl';
	--BORRA ARCHIVOS SI YA EXISTIERAN
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.gz';
	SYSTEM cSQL;
	--ARCHIVO 
	LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || cNombreArchivo || ' DELIMITER ' || '''|''' || ' SELECT lpad(consecutivo,10,' || '''0''' || ') folio, ciudad, servicio, fecha_movto, trim(nom_cte) nom_cte, telefono, trim(correo) correo, remesa cve_envio, trim(case when numconvenio=' || '''004''' || ' then ' || '''BTS''' || ' when numconvenio=' || '''006''' || ' then ' || '''WESTERN UNION''' || ' when numconvenio=' || '''007''' || ' then ' || '''ORLANDI VALUTA''' || ' when numconvenio=' || '''008''' || ' then ' || '''VIGO''' || ' when numconvenio=' || '''009''' || ' then ' || '''APPRIZA''' || ' end) remesadora, sucursal, estado from sac_sorteo_remesas where fecha_cheques between ''' || cFechaIni || ''' AND ''' || cFechaFin || ''' and enviado=' || '''0''' || ' order by folio,fecha_movto asc;" >' || TRIM(cRuta) || 'descargaArchSortRem.sql';
	SYSTEM cSQL;
	LET cSQL = '';
	--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'descargaArchSortRem.sql' ;
	--EJECUTA EL ARCHIVO
	LET cSQL='dbaccess bdisac ' || TRIM(cRuta) || 'descargaArchSortRem.sql';
	SYSTEM cSQL;
	--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'descargaArchSortRem.sql';
	SYSTEM cSQL;
	LET cSQL = '';
	--COMPRIME ARCHIVOS
	LET cSQL = '';
	LET cSQL = 'gzip ' || TRIM(cRuta) || TRIM(cNombreArchivo);
	SYSTEM cSQL;
	--SE BORRA ARCHIVO SIN COMPRIMIR
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo);
	SYSTEM cSQL;
	LET cSQL = '';

--ACTUALIZA ESTATUS ENVIADO DE LOS REGISTROS

	FOREACH CUR_UPDATE WITH HOLD FOR SELECT consecutivo INTO vFolioSorteo FROM sac_sorteo_remesas WHERE fecha_cheques BETWEEN cFechaIni AND cFechaFin AND enviado='0'
	
		UPDATE sac_sorteo_remesas SET enviado='1' WHERE CURRENT OF CUR_UPDATE;
		
    END FOREACH;

--ACTUALIZA FECHA PARA NUEVO CONCURSO
    UPDATE "informix".sac_param SET valor ='21/05/2021.21/06/2021' WHERE cod_param='200';

--MIGRA TABLA DEL SORTE Y REINICIA FOLIOS
    EXECUTE PROCEDURE "informix".sp_migra_sorteorem() INTO cProceso, cCodRet, cVarError;

--REGISTRA EN BITACORA
	INSERT INTO "informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
  	VALUES(trim(cProceso) || ': ' || cCodRet, Today, '1', 'informix', current, 1, 'sp_genera_arch_sorteorem', 'Genera Archivo Mensual del Sorteo Remesas 2020');
	
	RETURN cProceso, cCodRet, cVarError;

END;
END PROCEDURE;