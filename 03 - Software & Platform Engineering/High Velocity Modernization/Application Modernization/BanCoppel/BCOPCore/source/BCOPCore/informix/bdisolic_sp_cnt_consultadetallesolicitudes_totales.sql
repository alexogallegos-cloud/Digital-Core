CREATE PROCEDURE "informix".sp_cnt_consultadetallesolicitudes_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSt CHAR(2),
pSolicitud CHAR(1), pAgrupamiento CHAR(35), pNumCte CHAR(20), pNumCred CHAR(20), pSucursal CHAR(4), pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5) AS codret, 
        INTEGER AS total_registros;
                        
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
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
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';    
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
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
	
	BEGIN
			
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE bdicnweb:"informix".status_cnt_detallemonitorsol
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_consultadetallesolicitudes_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdicnweb:"informix".status_cnt_detallemonitorsol WHERE usuario_insert = pUsuario;
		INSERT INTO bdicnweb:"informix".status_cnt_detallemonitorsol(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			UPDATE bdicnweb:"informix".status_cnt_detallemonitorsol
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iRegistros;
		END IF;
			
		-- VALIDACIÓN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".status_cnt_detallemonitorsol
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iRegistros;
		END IF;
		
		DELETE FROM bdicnweb:"informix".sw_cnt_detallemonitorsol WHERE usuario_insert = pUsuario;
		
		IF pAgrupamiento = 'ESTATUS' THEN
			LET pAgrupamiento = 'STATUS';
		END IF;
		
		IF pSucursal <> '' THEN
			SELECT nombre INTO cNombreSuc
			FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pSt <> 'OS' THEN
		
			FOREACH 
				
				EXECUTE PROCEDURE bdisolic:"informix".sp_consultamonitor(cEmpresa, pSolicitud, pSt, pAgrupamiento, '', pFechaInicio, pFechaFin, pNumCte, pNumCred)
				INTO cCodRetSp,iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
				cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
				cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3
				
				LET iCodRet = cCodRetSp::INTEGER;
				IF iCodRet < 0 THEN
					RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP bdisolic:"informix".sp_consultamonitor';
				ELIF iCodRet = 2 AND iRecuperacion = 0 THEN
					LET cCodRet = '00017';
					UPDATE bdicnweb:"informix".status_cnt_detallemonitorsol
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
					RETURN cCodRet, iRegistros;
				ELIF iCodRet = 0 THEN
					
					IF pSucursal <> '' THEN
						IF TRIM(UPPER(cNombre)) = TRIM(UPPER(cNombreSuc)) THEN
							LET iRecuperacion = iRecuperacion + 1;
							INSERT INTO bdicnweb:"informix".sw_cnt_detallemonitorsol (estatusos,numerocobranzas,nombre,abrevia_prod,
							num_solicitud,fechasolic,status_solicitud,nombre_cliente,fecha_nac,folio,fechaos,dias,nombrecalle,	
							numeroextcalle,numerointcalle,complemento,zona,ciudad,estado,telefono1,telefono2,telefono3,nombreregion,num_cliente,usuario_insert,fecha_insert)			
							VALUES(iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
							cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
							cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os,pUsuario,CURRENT);
						END IF;
						
						LET cNombre = '';
						
					ELSE
						LET iRecuperacion = iRecuperacion + 1;
						INSERT INTO bdicnweb:"informix".sw_cnt_detallemonitorsol (estatusos,numerocobranzas,nombre,abrevia_prod,
						num_solicitud,fechasolic,status_solicitud,nombre_cliente,fecha_nac,folio,fechaos,dias,nombrecalle,	
						numeroextcalle,numerointcalle,complemento,zona,ciudad,estado,telefono1,telefono2,telefono3,nombreregion,num_cliente,usuario_insert,fecha_insert)			
						VALUES(iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
						cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
						cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os,pUsuario,CURRENT);
					END IF;
					
				END IF;
				
			END FOREACH;
		
		ELSE
			
			FOREACH 
				
				EXECUTE PROCEDURE bdisolic:"informix".sp_consulta_estatus_os2(pAgrupamiento, pSucursal, '', 'SIF', '0', '0', '0', pFechaInicio, pFechaFin, pNumCte, pNumCred)
				INTO cCodRetSp,iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
				cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
				cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os
				
				LET iCodRet = cCodRetSp::INTEGER;
				IF iCodRet < 0 THEN
					RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP bdisolic:"informix".sp_consulta_estatus_os2';
				ELIF iCodRet = 1 OR iCodRet = 3 THEN
					LET cCodRet = '00003';
					UPDATE bdicnweb:"informix".status_cnt_detallemonitorsol
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
					RETURN cCodRet, iRegistros;
				ELIF iCodRet = 2 OR iCodRet = 4 THEN
					LET cCodRet = '00017';
					UPDATE bdicnweb:"informix".status_cnt_detallemonitorsol
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
					RETURN cCodRet, iRegistros;
				ELIF iCodRet = 0 THEN
					
					LET iRecuperacion = iRecuperacion + 1;
					INSERT INTO bdicnweb:"informix".sw_cnt_detallemonitorsol (estatusos,numerocobranzas,nombre,abrevia_prod,
					num_solicitud,fechasolic,status_solicitud,nombre_cliente,fecha_nac,folio,fechaos,dias,nombrecalle,	
					numeroextcalle,numerointcalle,complemento,zona,ciudad,estado,telefono1,telefono2,telefono3,nombreregion,num_cliente,usuario_insert,fecha_insert)			
					VALUES(iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
					cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
					cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os,pUsuario,CURRENT);
					
				END IF;
				
			END FOREACH;
			
		END IF;
		
		SELECT COUNT(*) INTO iRegistros FROM bdicnweb:"informix".sw_cnt_detallemonitorsol WHERE usuario_insert = pUsuario;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '00017';
			UPDATE bdicnweb:"informix".status_cnt_detallemonitorsol
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iRegistros;
		END IF;
		
		UPDATE bdicnweb:"informix".status_cnt_detallemonitorsol
		SET status = 'T', error_proceso = 'N', num_registros = iRegistros WHERE usuario_insert = pUsuario;
		
		RETURN cCodRet, iRegistros;
			
	END;
END PROCEDURE
