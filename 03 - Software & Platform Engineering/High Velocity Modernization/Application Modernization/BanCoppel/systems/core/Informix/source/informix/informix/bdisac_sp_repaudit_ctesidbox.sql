CREATE PROCEDURE "informix".sp_repaudit_ctesidbox(MesAnio CHAR(6))

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
	DEFINE cNombreArchivo1	CHAR(50);
	DEFINE cNombreArchivo2	CHAR(50);
	DEFINE cNombreArchivo3	CHAR(50);
	DEFINE cSQL 			CHAR(4000);
	DEFINE cAnioMesAct		CHAR(6);
	DEFINE cFechaIni		DATE;
	DEFINE cFechaFin		DATE;
	

	-- INICIALIZAN LAS VARIABLES
	LET cProceso = 'ArchsAuditCtesIDbox';
	LET cCodRet = '00000';
	LET cVarError = 'Ejecucion Exitosa';
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo1 = 'si_cliente_';
	LET cNombreArchivo2 = 'si_ctepf_';
	LET cNombreArchivo3 = 'si_bitacora_ife_';
	LET cSQL = '';
	LET cAnioMesAct='';
	LET cFechaIni = '';
	LET cFechaFin = '';
	

	BEGIN

	-- CONTROL DE ERRORES
	ON EXCEPTION SET iSqlErr, iSamErr, cVarError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cVarError = 'Error No Controlado';

			SET DEBUG FILE TO "/RESPALDOSNEW/sp_repaudit_ctesidbox.out";
			TRACE ON;

			INSERT INTO "informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
  			VALUES(trim(cProceso) || ': ' || iSqlErr, Today, '0', 'informix', current, 1, 'sp_repaudit_ctesidbox', 'Generar Archivos Mensuales Para Auditoria de Clientes y IDBOX');


			RETURN cProceso, cCodRet, cVarError;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/noe/41922/sp_repaudit_ctesidbox.out";
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

	
--NOMBRE DEL ARCHIVO
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo1 = 'si_cliente_' || cAnioMesAct || '.unl';
	LET cNombreArchivo2 = 'si_ctepf_' || cAnioMesAct || '.unl';
	LET cNombreArchivo3 = 'si_bitacora_ife_' || cAnioMesAct || '.unl';

--BORRA ARCHIVOS SI YA EXISTIERAN
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo1) || '.gz';
	SYSTEM TRIM(cSQL);
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo2) || '.gz';
	SYSTEM TRIM(cSQL);
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo3) || '.gz';
	SYSTEM TRIM(cSQL);

	
--ARCHIVO 1 (ENCABEZADOS)
	LET cSQL = '';  
	LET cSQL = 'echo "empresa|numcte|status_cte|sucursal|ejecutivo|tpo_persona|tipo_cliente|apell_paterno|apell_materno|nombre1|nombre2|razon_social|rfc|sector|segmento|actividad_princ|grupo|subgrupo|residencia|fecha_alta|apell_casada|distrito|numcte_ref|string1|string2|numeric1|numeric2|money1|date1|puesto_ppes|familiar_ppes|actividad_esp|ejecut_autoriza|user_insert|fecha_insert|rfc_alterno|tpo_biometria|cliente_pros|envio_movtos|" >' || TRIM(cRuta) || TRIM(cNombreArchivo1);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
--ARCHIVO 1 (DESCARGA)
	LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempCL.unl' || ' DELIMITER ' || '''|''' || ' SELECT CL.* FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || ''');" >' || TRIM(cRuta) || 'genArchRepAudit1.sql';
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempCL.unl' || ' DELIMITER ' || '''|''' || ' SELECT CL.* FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and PF.codidentifi=''A'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || ''');" >' || TRIM(cRuta) || 'genArchRepAudit1.sql';
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'genArchRepAudit1.sql' ;
--EJECUTA EL ARCHIVO
	LET cSQL='dbaccess bdinteg ' || TRIM(cRuta) || 'genArchRepAudit1.sql';
	SYSTEM TRIM(cSQL);
--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'genArchRepAudit1.sql';
	SYSTEM TRIM(cSQL);
	LET cSQL = '';
--AGREGA ENCABEZADOS
	LET cSQL = 'tail -n +1 ' || TRIM(cRuta) || 'tempCL.unl >> ' || TRIM(cRuta) || TRIM(cNombreArchivo1);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'tempCL.unl';
	SYSTEM TRIM(cSQL);

	



--ARCHIVO 2 (ENCABEZADOS)
	LET cSQL = '';  
	LET cSQL = 'echo "empresa|numcte|fecha_nac|lugar_nac|nacionalidad|no_fm3|estado_civil|regim_matrimonio|profesion|sexo|curp|codifi|numidentifi|no_imss|dependientes|tutor|nom_conyuge|seguro_defunc|escolaridad|habita_en|anios_habita|nombre_prop|imp_hipo_renta|actividadogiro|numeroife|numerotutor|numeroconyuge|string1|string2|numeric1|numeric2|money1|date1|user_insert|fecha_insert|sms_cel|hora_insert|validacurp|id_pais|" >' || TRIM(cRuta) || TRIM(cNombreArchivo2);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
--ARCHIVO 2 (DESCARGA)
	LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempPF.unl' || ' DELIMITER ' || '''|''' || ' SELECT PF.* FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || ''');" >' || TRIM(cRuta) || 'genArchRepAudit2.sql';
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempPF.unl' || ' DELIMITER ' || '''|''' || ' SELECT PF.* FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and PF.codidentifi=''A'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || ''');" >' || TRIM(cRuta) || 'genArchRepAudit2.sql';
	SYSTEM TRIM(cSQL);
--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'genArchRepAudit2.sql' ;
--EJECUTA EL ARCHIVO
	LET cSQL='dbaccess bdinteg ' || TRIM(cRuta) || 'genArchRepAudit2.sql';
	SYSTEM TRIM(cSQL);
--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'genArchRepAudit2.sql';
	SYSTEM TRIM(cSQL);
	LET cSQL = '';
--AGREGA ENCABEZADOS
	LET cSQL = 'tail -n +1 ' || TRIM(cRuta) || 'tempPF.unl >> ' || TRIM(cRuta) || TRIM(cNombreArchivo2);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'tempPF.unl';
	SYSTEM TRIM(cSQL);


--ARCHIVO 3 (ENCABEZADOS)
	LET cSQL = '';  
	LET cSQL = 'echo "numcte|ejecutivo|sucursal|cadena_anverso|cadena_reverso|flag_idbox|flag_ws|flag_captura|resultado|causa_rechazo|fecha|cod_resp_ife|resp_ife|time_ife|access_ife|stamp_ife|ocr_ife|appat_ife|apmat_ife|nombre_ife|callenum_ife|colcp_ife|mpoent_ife|folional_ife|anioreg_ife|emision_ife|cveelec_ife|curp_ife|localidad_ife|seccion_ife|anioemision_ife|vigencia_ife|edad_ife|sexo_ife|ansi2_ife|ansi7_ife|modelo_ife|actualizado|test_uv_reflec_anv|test_uv_shape_anv|test_ir_ink_anv|test_uv_reflectance_rev|test_ir_ink_rev|" >' || TRIM(cRuta) || TRIM(cNombreArchivo3);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
--ARCHIVO 3 (DESCARGA)
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and length(trim(resp_ife)) > 0 and resp_ife not in(''Consulta no exitosa al procesar peticiÃÂÃÂÃÂÃÂ³n'',''Desconectado'',''No se ha enviado OCR'') AND cod_resp_ife not in (''          '',''00'') AND resp_ife not in ('''') AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂÃÂÃÂ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂÃÂÃÂ³n''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and ((length(trim(resp_ife)) > 0 and trim(modelo_ife) <> ''IDMEXG1'') OR (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) and resp_ife not in(''Consulta no exitosa al procesar peticiÃÂÃÂ³n'',''Desconectado'',''No se ha enviado OCR'') AND ((cod_resp_ife not in (''          '',''00'') and trim(modelo_ife) <> ''IDMEXG1'') OR (cod_resp_ife in (''          '',''00'') and trim(modelo_ife) = ''IDMEXG1'')) AND ((resp_ife not in ('''') and trim(modelo_ife) <> ''IDMEXG1'') OR (resp_ife in ('''') and trim(modelo_ife) = ''IDMEXG1'')) AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂ³n'' or trim(resp_ife)=''Consulta no exitosa al procesar peticion'')) OR (trim(resultado)=''Falso'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) OR (trim(resultado)=''Verdadero'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and ((length(trim(resp_ife)) > 0 and trim(modelo_ife) <> ''IDMEXG1'') OR (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) and resp_ife not in(''Consulta no exitosa al procesar peticiÃÂÃÂ³n'',''Desconectado'',''No se ha enviado OCR'') AND ((cod_resp_ife not in (''          '',''00'') and trim(modelo_ife) <> ''IDMEXG1'') OR (cod_resp_ife in (''          '',''00'') and trim(modelo_ife) = ''IDMEXG1'')) AND ((resp_ife not in ('''') and trim(modelo_ife) <> ''IDMEXG1'') OR (resp_ife in ('''') and trim(modelo_ife) = ''IDMEXG1'')) AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂ³n'' or trim(resp_ife)=''Consulta no exitosa al procesar peticion'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Falso'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) OR (trim(resultado)=''Verdadero'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
    --LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and ((length(trim(resp_ife)) > 0 and trim(modelo_ife) <> ''IDMEXG1'') OR (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) and resp_ife not in(''Consulta no exitosa al procesar peticiÃ³n'',''Desconectado'',''No se ha enviado OCR'') AND ((cod_resp_ife not in (''          '',''00'') and trim(modelo_ife) <> ''IDMEXG1'') OR (cod_resp_ife in (''          '',''00'') and trim(modelo_ife) = ''IDMEXG1'')) AND ((resp_ife not in ('''') and trim(modelo_ife) <> ''IDMEXG1'') OR (resp_ife in ('''') and trim(modelo_ife) = ''IDMEXG1'')) AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃ³n'' or trim(resp_ife)=''Consulta no exitosa al procesar peticion'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Falso'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) OR (trim(resultado)=''Verdadero'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and PF.codidentifi=''A'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
      LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, case when trim(resp_ife)=''VALIDACION DUMMY'' then ''La transaccion fue atendida con exito.'' else resp_ife end resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and ((length(trim(resp_ife)) > 0 and trim(modelo_ife) <> ''IDMEXG1'') OR (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) and resp_ife not in(''Consulta no exitosa al procesar peticiÃ³n'',''Desconectado'',''No se ha enviado OCR'') AND ((cod_resp_ife not in (''          '',''00'') and trim(modelo_ife) <> ''IDMEXG1'') OR (cod_resp_ife in (''          '',''00'') and trim(modelo_ife) = ''IDMEXG1'')) AND ((resp_ife not in ('''') and trim(modelo_ife) <> ''IDMEXG1'') OR (resp_ife in ('''') and trim(modelo_ife) = ''IDMEXG1'')) AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''VALIDACION DUMMY'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃ³n'' or trim(resp_ife)=''Consulta no exitosa al procesar peticion'' or trim(resp_ife)=''VALIDACION DUMMY'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Falso'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) OR (trim(resultado)=''Verdadero'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and PF.codidentifi=''A'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	SYSTEM TRIM(cSQL);
--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'genArchRepAudit3.sql' ;
--EJECUTA EL ARCHIVO
	LET cSQL='dbaccess bdinteg ' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	SYSTEM TRIM(cSQL);
--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	SYSTEM TRIM(cSQL);
--AGREGA ENCABEZADOS
	LET cSQL = 'tail -n +1 ' || TRIM(cRuta) || 'tempIFE.unl >> ' || TRIM(cRuta) || TRIM(cNombreArchivo3);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'tempIFE.unl';
	SYSTEM TRIM(cSQL);
	

--COMPRIME ARCHIVOS
	LET cSQL = '';
	LET cSQL = 'gzip ' || TRIM(cRuta) || TRIM(cNombreArchivo1);
	SYSTEM TRIM(cSQL);

	LET cSQL = '';  
	LET cSQL = 'gzip ' || TRIM(cRuta) || TRIM(cNombreArchivo2);
	SYSTEM TRIM(cSQL);

	LET cSQL = '';  
	LET cSQL = 'gzip ' || TRIM(cRuta) || TRIM(cNombreArchivo3);
	SYSTEM TRIM(cSQL);



--REGISTRA EN BITACORA
	INSERT INTO "informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
  	VALUES(trim(cProceso) || ': ' || cCodRet, Today, '1', 'informix', current, 1, 'sp_repaudit_ctesidbox', 'Generar Archivos Mensuales Para Auditoria de Clientes y IDBOX');
	
	RETURN cProceso, cCodRet, cVarError;

END;
END PROCEDURE;