CREATE PROCEDURE "informix".sp_ejecutadepuracion(pcFechaCaracter CHAR(10))
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Realiza la depuración de las tablas cuya fecha caducidad es hoy --------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 05/11/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	-- MODIFICACIÓN: Se eliminaron las referencias a la BD bdiresp de los sp's propios de esta.
	-- AUTOR: Moisés Soriano
	-- FECHA : 26/02/2013
	-- BD: bdiresp
	*****************************************************************************************************
	-- MODIFICACION:  Se cambio el order by de la consulta para la depuracion  --------------------------
	-- AUTOR : Roberto Castro ---------------------------------------------------------------------------
	-- FECHA : 17/07/2013  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo				INT;
	DEFINE vcCodRet				CHAR(5);
	DEFINE vcCodRet2			CHAR(5);
	DEFINE vcDescRet			CHAR(100);	
	DEFINE viIdSolicitud 		INT;
	DEFINE vcBaseDeDatos 		CHAR(20);
	DEFINE vcTabla				CHAR(30);
	DEFINE vcCondicion 			CHAR(100);
	DEFINE vcNomArchivo 		CHAR(50);
	DEFINE vcEnTrans 			CHAR(1);
	DEFINE vdFechaRestauracion	DATETIME YEAR TO SECOND;
	DEFINE vcSql				CHAR(1000);
	DEFINE viCodigo2			INT;
	DEFINE vcDescRet2			CHAR(100);
	DEFINE vdFechaInicio		DATE;
	DEFINE vdFechaFinal			DATE;
	DEFINE vcError				CHAR(1);
	DEFINE vdFechaDepuracion	DATE;
	DEFINE vcEncontro			CHAR(1);
	
	LET viCodigo 			= 	0;
	LET vcCodRet 			= 	'00000';
	LET vcCodRet2 			= 	'00000';
	LET vcDescRet 			= 	'';
	LET viIdSolicitud 		= 	0;
	LET vcBaseDeDatos 		= 	'';
	LET vcTabla 			= 	'';
	LET vcCondicion 		= 	'';
	LET vcNomArchivo 		= 	'';
	LET vcEnTrans 			= 	'0';
	LET vdFechaRestauracion	=	CURRENT YEAR TO SECOND;
	LET vcSql 				= 	'';
	LET viCodigo2 			= 	0;
	LET vcDescRet2 			= 	'';
	LET vdFechaInicio		=	'01-01-1900';
	LET vdFechaFinal		=	'01-01-1900';
	LET vcError				=	'';
	LET vdFechaDepuracion	=	'01-01-1900';
	LET vcEncontro			=	'';

--SET DEBUG FILE TO "/home/sysifx/roberto/sp_ejecutadepuracion.out";
--TRACE ON;
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		IF( vcEnTrans = '1' ) THEN
			ROLLBACK WORK;
		END IF;
		
		--LOG DE EVENTOS
		EXECUTE PROCEDURE sp_insertaLog(5001, 'FALLÓ PROCESO DE DEPURACIÓN ' || NVL(vcNomArchivo,''), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
		--LOG DE ERRORES
		EXECUTE PROCEDURE sp_insertaLog(5001, 'PROCESO DE DEPURACIÓN', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_ejecutaDepuracion(' || NVL(pcFechaCaracter,'NULL') || ')') INTO viCodigo2, vcDescRet2;
		--BITÁCORA DE PROCESOS
		EXECUTE PROCEDURE sp_insertaLog(5001, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE DEPURACIÓN', TRIM(vcNomArchivo), "Informix", 2, '') INTO viCodigo2, vcDescRet2;
		EXECUTE PROCEDURE sp_insertaLog(5002, 'FINALIZA PROCESO DE DEPURACIÓN', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;		
		
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,'');
	END EXCEPTION;	
	
	IF ( pcFechaCaracter IS NULL ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	EXECUTE PROCEDURE sp_validaFecha(pcFechaCaracter) INTO vcCodRet2;
	IF ( TRIM(NVL(vcCodRet2,'')) <> '00000' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	LET vdFechaDepuracion = pcFechaCaracter::DATE;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE sp_insertaLog(5000, 'INICIA PROCESO DE DEPURACIÓN', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	BEGIN WORK;
	LET vcEnTrans = '1';	
	FOREACH
		SELECT {+INDEX(bdiresp:rp_respaldos 109_60)} t1.id_solicitud,t1.base_de_datos,t1.tabla,t3.condicion,t1.nombre_archivo, t1.fecha_restauracion, t3.fecha_inicio, t3.fecha_final 
		INTO viIdSolicitud, vcBaseDeDatos, vcTabla, vcCondicion, vcNomArchivo, vdFechaRestauracion, vdFechaInicio, vdFechaFinal
		FROM "informix".rp_tablas_restauradas t1
		INNER JOIN "informix".rp_tabla_aplicacion t2 ON (t1.tabla=t2.tabla)
		INNER JOIN "informix".rp_respaldos t3 ON (t1.nombre_archivo=t3.nombre_archivo)
		WHERE t1.fecha_caducidad::DATE = vdFechaDepuracion AND t1.estatus IN ('1')
		ORDER BY t1.sec_borrado,t2.cve_aplicacion
		LET vcEncontro = '1';
		IF ( TRIM(NVL(vcCondicion,'')) = '' ) THEN
			LET vcError = '1';
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(5001, 'PROCESO DE DEPURACIÓN','' , "Informix", 3, 'CONDICIÓN NO VÁLIDA PARA EL ARCHIVO ' || TRIM(NVL(vcNomArchivo,''))) INTO viCodigo2, vcDescRet2;
			--BITÁCORA DE PROCESOS
			EXECUTE PROCEDURE sp_insertaLog(5001, 'ERROR, SE DETECTÓ UN PROBLEMA EN PROCESO DE DEPURACIÓN', TRIM(vcNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;			
					
			EXIT FOREACH;
		END IF;
		
		LET vcSql = "DELETE FROM " || TRIM(vcBaseDeDatos) || ":" || TRIM(vcTabla) || " WHERE " || TRIM(vcCondicion);
		
		EXECUTE IMMEDIATE vcSql;
		EXECUTE PROCEDURE sp_insertaLog(5001, 'TOTAL REGISTROS DEPURADOS: ' || DBINFO('sqlca.sqlerrd2'), TRIM(vcNomArchivo) , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
		
		UPDATE "informix".rp_tablas_restauradas 
		SET estatus = '3', fecha_depuracion = CURRENT YEAR TO SECOND, user_insert = 'Informix', fecha_insert = CURRENT YEAR TO SECOND
		WHERE id_solicitud = viIdSolicitud AND tabla = TRIM(vcTabla) AND nombre_archivo = TRIM(vcNomArchivo) AND fecha_restauracion::DATE = vdFechaRestauracion::DATE;
		
		UPDATE "informix".rp_restauraciones SET status = '2', user_insert = 'Informix', fecha_insert = CURRENT YEAR TO SECOND WHERE id_solicitud = viIdSolicitud;
		
	END FOREACH;
	
	IF ( vcEnTrans = '1' ) THEN
		COMMIT WORK;
		LET vcEnTrans = '0';	
	END IF;
	IF ( vcError = '1' ) THEN
		--LOG DE EVENTOS
		EXECUTE PROCEDURE sp_insertaLog(5001, 'FALLÓ PROCESO DE DEPURACIÓN ' || NVL(vcNomArchivo,''), '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
	ELSE
		IF ( vcEncontro = '1' ) THEN
			--LOG DE EVENTOS
			EXECUTE PROCEDURE sp_insertaLog(5001, 'CONCLUYÓ EXITOSAMENTE PROCESO DE DEPURACIÓN', '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;		
		ELSE
			--LOG DE EVENTOS
			EXECUTE PROCEDURE sp_insertaLog(5001, 'CONCLUYÓ PROCESO DE DEPURACIÓN SIN INFORMACIÓN POR DEPURAR', '' , "Informix", 1, '') INTO viCodigo2, vcDescRet2;
			--BITÁCORA DE PROCESOS
			EXECUTE PROCEDURE sp_insertaLog(5001, 'NO SE ENCONTRARON DEPURACIONES PENDIENTES POR REALIZAR','', "Informix", 2, '') INTO viCodigo2, vcDescRet2;
		END IF;
	END IF;
	
	--Actualizar indices
	EXECUTE IMMEDIATE 
	"update statistics medium for table " ||TRIM(vcBaseDeDatos)||":"|| TRIM(vcTabla);
	
	--BITÁCORA DE PROCESOS
	EXECUTE PROCEDURE sp_insertaLog(5002, 'FINALIZA PROCESO DE DEPURACIÓN', '' , "Informix", 2, '') INTO viCodigo2, vcDescRet2;
	RETURN vcCodRet, vcDescRet;
	END;
END PROCEDURE;