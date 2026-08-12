CREATE PROCEDURE "informix".sp_cnt_genreportessolicitudes(pUsuario CHAR(8), pIdFuncion CHAR(10), pSt CHAR(2),
pSolicitud CHAR(1), pAgrupamiento CHAR(35), pNumCte CHAR(20), pNumCred CHAR(20), pSucursal CHAR(4), pFechaInicio DATE, pFechaFin DATE, 
pRutaDescarga CHAR(100), pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iCodRet INTEGER;
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE vsSQL CHAR(2500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(100);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);	
	DEFINE iRegistros INTEGER;
	DEFINE iCountRep INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE iRow INTEGER;
	DEFINE iContBloque INTEGER;
	--
	DEFINE iEstatusos INTEGER;		
	DEFINE sNumerocobranzas SMALLINT;
	DEFINE cNombre CHAR(40);		
	DEFINE cAbrevia_prod CHAR(5);	
	DEFINE cNum_solicitud CHAR(20);	
	DEFINE dFechasolic DATE;		
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE cNombre_cliente CHAR(170);
	DEFINE dFecha_nac DATE;			
	DEFINE cFolio CHAR(50);			
	DEFINE cFechaos CHAR(20);		
	DEFINE iDias INTEGER;			
	DEFINE cNombrecalle CHAR(30);	
	DEFINE cNumeroextcalle CHAR(10);
	DEFINE cNumerointcalle CHAR(10);
	DEFINE cComplemento CHAR(80);	
	DEFINE cZona CHAR(50);			
	DEFINE cCiudad CHAR(10);		
	DEFINE cEstado CHAR(10);		
	DEFINE cTelefono1 CHAR(13);		
	DEFINE cTelefono2 CHAR(13);		
	DEFINE cTelefono3 CHAR(13);
	DEFINE cNombreRegion_os CHAR(30);
	DEFINE cNumCliente_os CHAR(20);
	DEFINE cNombreSuc CHAR(40);
	DEFINE cSt CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iCodRet = 0;
	LET cDesCodRetSp = '';
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET vsSQL = '';
	LET cRutaInformix = '/informix/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';
	LET cNombreReporteHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dHoy = '';
	LET dHora = '';
	LET cStr7 = ''; 
	LET cStr8 = ''; 
	LET iRegistros = 0;
	LET iCountRep = 0;
    LET iRecuperacion = 0;
	LET iNumRegistros = 0;
	LET iRow = 0;
	LET iContBloque = 0;
	--
	LET iEstatusos = 0;		
	LET sNumerocobranzas = 0;
	LET cNombre = '';		
	LET cAbrevia_prod = '';	
	LET cNum_solicitud = '';	
	LET dFechasolic = '';		
	LET cStatus_solicitud = '';
	LET cNombre_cliente = '';
	LET dFecha_nac = '';			
	LET cFolio = '';			
	LET cFechaos = '';		
	LET iDias = 0;			
	LET cNombrecalle = '';	
	LET cNumeroextcalle = '';
	LET cNumerointcalle = '';
	LET cComplemento = '';	
	LET cZona = '';		
	LET cCiudad = '';		
	LET cEstado = '';		
	LET cTelefono1 = '';		
	LET cTelefono2 = '';		
	LET cTelefono3 = '';
	LET cNombreRegion_os = '';
	LET cNumCliente_os = '';
	LET cNombreSuc = '';
	LET cSt = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_genreportessolicitudes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;	
		
		-- SE ASIGNAN VALORES PARA LA GENERACIÓN DEL REPORTE
		IF NVL(pSt,'') = '' THEN
			LET cSt = 'TODAS';
		ELSE
			LET cSt = pSt;
		END IF;
		LET cNombreReporte = 'MONITOR_SOLICITUDES_'||TRIM(cSt)||'_'||TO_CHAR(CURRENT, '%d%m%Y_%H%M%S')||'.txt';
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;
	
		IF pAgrupamiento = 'ESTATUS' THEN
			LET pAgrupamiento = 'STATUS';
		END IF;
		
		IF pSucursal <> '' THEN
			SELECT nombre INTO cNombreSuc
			FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pSt,'') <> 'OS' THEN
			
			EXECUTE PROCEDURE bdisolic:"informix".sp_consultamonitor3(pUsuario,cEmpresa, pSolicitud, pSt, pAgrupamiento, '', pFechaInicio, pFechaFin, pNumCte, pNumCred,cNombreReporte)
			INTO cCodRetSp;
				
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP bdisolic:"informix".sp_consultamonitor3';
			ELIF iCodRet > 0 THEN 
				LET cCodRet = '00017';
				
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				
				RETURN cCodRet;
		    END IF;
			
			LET cCmd1 ="";
			LET cCmd1 = "SELECT 'MATRIZ IMPR.','#COBR.','SUCURSAL','PRODUCTO','NUMERO SOLICITUD','CLIENTE','ESTATUS','FOLIO OS',";
			LET cCmd1 =""||TRIM(cCmd1)||"'FECHA NACIMIENTO','FECHA OS','DIAS TRANSCURRIDOS','CALLE','NO. EXT.','NO. INT.',";
			LET cCmd1 =""||TRIM(cCmd1)||"'COMPLEMENTO DOMICILIO','COLONIA','CIUDAD','ESTADO','TEL. PART.','CELULAR','TEL. TRAB.'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT estatusos::CHAR(11),numerocobranzas::CHAR(6),nombre,abrevia_prod,";
			LET cCmd1 =""||TRIM(cCmd1)||" num_solicitud,nombre_cliente,status_solicitud,folio,NVL(TO_CHAR(fecha_nac, '%d/%m/%Y'), ''),fechaos,";
			LET cCmd1 =""||TRIM(cCmd1)||" dias::CHAR(11),nombrecalle,numeroextcalle,numerointcalle,complemento,zona,ciudad,estado,telefono1,telefono2,telefono3";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cnt_detallemonitorsol";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pUsuario ||"' AND nombre_reporte = '"|| cNombreReporte ||"'";	
			IF pAgrupamiento = 'SUCURSAL' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY nombre, num_solicitud ASC)";
			ELIF pAgrupamiento = 'PRODUCTO' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY abrevia_prod, num_solicitud ASC)";
			ELIF pAgrupamiento = 'CLIENTE' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY nombre_cliente, num_solicitud ASC)";
			ELIF pAgrupamiento = 'STATUS' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY status_solicitud, num_solicitud ASC)";
			ELIF pAgrupamiento = 'ESTADO' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY estado, num_solicitud ASC)";
			ELSE
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";
			END IF;

		
		ELSE
			
			EXECUTE PROCEDURE bdisolic:"informix".sp_consulta_estatus_os3(pUsuario,pAgrupamiento, pSucursal, '', 'SIF', '0', '0', '0', pFechaInicio, pFechaFin, pNumCte, pNumCred,cNombreReporte)
			INTO cCodRetSp;
				
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP bdisolic:"informix".sp_consulta_estatus_os3';
			ELIF iCodRet > 0 THEN 
				LET cCodRet = '00017';					
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;					
				RETURN cCodRet;
			END IF;
								
			LET cCmd1 ="";
			LET cCmd1 = "SELECT 'MATRIZ IMPR.','#COBR.','SUCURSAL','PRODUCTO','NUMERO SOLICITUD','CLIENTE','ESTATUS','FOLIO OS',";
			LET cCmd1 =""||TRIM(cCmd1)||"'FECHA NACIMIENTO','FECHA OS','DIAS TRANSCURRIDOS','CALLE','NO. EXT.','NO. INT.',";
			LET cCmd1 =""||TRIM(cCmd1)||"'COMPLEMENTO DOMICILIO','COLONIA','CIUDAD','ESTADO','TEL. PART.','CELULAR','TEL. TRAB.','REGION','NO. CLIENTE'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT estatusos::CHAR(11),numerocobranzas::CHAR(6),nombre,abrevia_prod,";
			LET cCmd1 =""||TRIM(cCmd1)||"num_solicitud,nombre_cliente,status_solicitud,folio,NVL(TO_CHAR(fecha_nac, '%d/%m/%Y'), ''),fechaos,";
			LET cCmd1 =""||TRIM(cCmd1)||"dias::CHAR(11),nombrecalle,numeroextcalle,numerointcalle,complemento,zona,ciudad,estado,telefono1,telefono2,telefono3,nombreregion,num_cliente";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cnt_detallemonitorsol";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pUsuario ||"' AND nombre_reporte = '"|| cNombreReporte ||"'";	
			IF pAgrupamiento = 'SUCURSAL' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY nombre, num_solicitud ASC)";
			ELIF pAgrupamiento = 'PRODUCTO' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY abrevia_prod, num_solicitud ASC)";
			ELIF pAgrupamiento = 'CLIENTE' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY nombre_cliente, num_solicitud ASC)";
			ELIF pAgrupamiento = 'STATUS' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY status_solicitud, num_solicitud ASC)";
			ELIF pAgrupamiento = 'ESTADO' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY estado, num_solicitud ASC)";
			ELIF pAgrupamiento = 'REGIONES' THEN
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY nombreregion, num_solicitud ASC)";				
			ELSE
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";
			END IF;
		
		END IF;
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);
		
		LET ven_transacc = 1;
		
		LET cSql = '';
		LET vsSQL = TRIM(TRIM(cRutaGral)|| ' ' ||TRIM(cCmd1));
		SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vsSQL)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb >> '||TRIM(cRutaGral)); 
		
		-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
		FOREACH
		
			SELECT nombre_reporte
			INTO cNombreReporteHist
			FROM bdicnweb:"informix".sw_ctrlgenreportesmonitorsolest 
			WHERE usuario_insert = pUsuario --AND nombre_reporte = TRIM(cNombreReporte) 
			AND fecha_reporte < dFechaHoy
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
			SYSTEM TRIM(cSql);
			
			DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesmonitorsolest
			WHERE usuario_insert = pUsuario
			AND nombre_reporte = TRIM(cNombreReporteHist);
			
		END FOREACH;
			
		LET iRow = 0;
	    LET iContBloque = 0;
		
		SET ISOLATION TO DIRTY READ;
		-- DEPURACION TABLA
	    BEGIN WORK;
	    FOREACH WITH HOLD
	    	SELECT id_registro INTO iRow 
	    	FROM bdicnweb:"informix".sw_cnt_detallemonitorsol WHERE usuario_insert = pUsuario AND nombre_reporte = cNombreReporte
	    	
	    	DELETE FROM bdicnweb:"informix".sw_cnt_detallemonitorsol
			WHERE usuario_insert = pUsuario
			AND nombre_reporte = cNombreReporte
			AND id_registro = iRow;	    	
	    	
	    	LET iContBloque = iContBloque + 1;
	    	IF iContBloque = 5000 THEN
	    		LET iContBloque = 0;
	    		COMMIT WORK;
	    		BEGIN WORK;
	    	END IF;
	    END FOREACH;		
	    COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE REGISTRA EN BITÁCORA				
		LET iCountRep = iCountRep + 1;
		SET ISOLATION TO DIRTY READ;
		
		DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesmonitorsolest
		WHERE usuario_insert = pUsuario
		AND nombre_reporte = TRIM(cNombreReporte);
		
		INSERT INTO bdicnweb:"informix".sw_ctrlgenreportesmonitorsolest(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
		VALUES(TRIM(cNombreReporte),dFechaHoy,dHoraHoy,pUsuario);		
		
		/*
		-- NOTIFICACIÓN VÍA CORREO ELECTRÓNICO
		LET cStr7 = 'GENERACIÓN DEL ARCHIVO TXT';
		LET cStr9 = 'SOLICITUDES PARA ESTUDIO';
		LET dHoy = CURRENT;
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
		'1', 
		TRIM(pIdPlantilla),
		TRIM(pIdPlantilla), 
		pUsuario, 
		'',
		'', 
		'1', 
		'',
		'',
		'',
		'',
		'',
		TRIM(pTituloPlantilla),
		TRIM(cStr7),
		'',
		TRIM(cStr9),
		'',
		'',
		'',
		'0',
		'0',
		'0',
		'0',
		'0',
		dHoy,
		dHoy) INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCIÓN DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE
		END IF;
		*/
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
