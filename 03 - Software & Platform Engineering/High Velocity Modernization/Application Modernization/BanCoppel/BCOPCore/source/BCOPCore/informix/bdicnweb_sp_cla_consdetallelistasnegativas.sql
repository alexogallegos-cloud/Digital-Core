CREATE PROCEDURE "informix".sp_cla_consdetallelistasnegativas(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecutivo CHAR(20), pFechaInicio DATE, pFechaFin DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_cliente,
		CHAR(60) AS razon_social,
		DATE AS fecha_constitucion,
		CHAR(15) AS rfc,
		CHAR(250) AS comentarios,
		DATE AS fecha_inclusion,
		CHAR(15) AS usuario,
		CHAR(8) AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNum_cliente CHAR(20);
	DEFINE cNom_cliente CHAR(110);
	DEFINE cTipo_persona CHAR(10);
	DEFINE cRazon_social CHAR(60);
	DEFINE dFecha_constitucion DATE;
	DEFINE cRfc CHAR(15);
	DEFINE cComentarios CHAR(250);
	DEFINE dFecha_inclusion DATE;
	DEFINE cUsuario CHAR(15);
	DEFINE cStatus CHAR(8);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNum_cliente = '';
	LET cNom_cliente = '';
	LET cTipo_persona = '';
	LET cRazon_social = '';
	LET dFecha_constitucion = '';
	LET cRfc = '';
	LET cComentarios = '';
	LET dFecha_inclusion = '';
	LET cUsuario = '';
	LET cStatus = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNum_cliente,cRazon_social,dFecha_constitucion,cRfc,cComentarios,dFecha_inclusion,cUsuario,cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cla_consdetallelistasnegativas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNum_cliente,cRazon_social,dFecha_constitucion,cRfc,cComentarios,dFecha_inclusion,cUsuario,cStatus;
		END IF;
		
		IF pIdFuncion = 'CLA002' THEN
			IF pFechaInicio IS NULL OR pFechaFin IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cNum_cliente,cRazon_social,dFecha_constitucion,cRfc,cComentarios,dFecha_inclusion,cUsuario,cStatus;
			END IF;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNum_cliente,cRazon_social,dFecha_constitucion,cRfc,cComentarios,dFecha_inclusion,cUsuario,cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNum_cliente,cRazon_social,dFecha_constitucion,cRfc,cComentarios,dFecha_inclusion,cUsuario,cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT {+INDEX (bdinteg:si_mant_listainterna idx_lisint)} SKIP pRegistros FIRST pRecuperacion 
			num_cliente,nom_cliente,tipo_persona,razon_social,fecha_constitucion,rfc,comentarios,fecha_inclusion,usuario,status
			INTO cNum_cliente,cNom_cliente,cTipo_persona,cRazon_social,dFecha_constitucion,cRfc,cComentarios,dFecha_inclusion,cUsuario,cStatus
			FROM bdinteg:"informix".si_mant_listainterna
			WHERE fecha_inclusion <= (CASE WHEN pFechaFin IS NULL THEN fecha_inclusion ELSE pFechaFin END) AND fecha_inclusion >= (CASE WHEN pFechaInicio IS NULL THEN fecha_inclusion ELSE pFechaInicio END)
			AND status = 'A'
			ORDER BY fecha_inclusion ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNum_cliente,cRazon_social,dFecha_constitucion,cRfc,cComentarios,dFecha_inclusion,cUsuario,cStatus WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNum_cliente,cRazon_social,dFecha_constitucion,cRfc,cComentarios,dFecha_inclusion,cUsuario,cStatus;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNum_cliente,cRazon_social,dFecha_constitucion,cRfc,cComentarios,dFecha_inclusion,cUsuario,cStatus;
		END IF;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 07/11/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: ALTA Y BAJA DE PERSONAS MORALES EN LISTAS NEGATIVAS', 
'DESCRIPCION: SPL encargado de consultar el detalle de las listas negativas de clientes de tipo moral.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cla_consdetallelistasnegativas_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecutivo CHAR(20), pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cla_consdetallelistasnegativas_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		IF pIdFuncion = 'CLA002' THEN
			IF pFechaInicio IS NULL OR pFechaFin IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,iNumRegistros;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		SELECT {+INDEX (bdinteg:si_mant_listainterna idx_lisint)} COUNT(*)
		INTO iNumRegistros
		FROM bdinteg:"informix".si_mant_listainterna
		WHERE fecha_inclusion <= (CASE WHEN pFechaFin IS NULL THEN fecha_inclusion ELSE pFechaFin END) AND fecha_inclusion >= (CASE WHEN pFechaInicio IS NULL THEN fecha_inclusion ELSE pFechaInicio END)
		AND status = 'A';
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017'; 
		END IF;	
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 07/11/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: ALTA Y BAJA DE PERSONAS MORALES EN LISTAS NEGATIVAS', 
'DESCRIPCION: SPL encargado de consultar el número total de registros de las listas negativas de clientes de tipo moral.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cla_eliminactelistasnegativas(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecutivo CHAR(20), pStatus CHAR(8))
	RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cla_eliminactelistasnegativas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecutivo = '' OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		UPDATE bdinteg:"informix".si_mant_listainterna SET status = pStatus, usuario = pUsuario, fecha_inclusion = CURRENT WHERE num_cliente = pEjecutivo;
		
		-- Valida Eliminación
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00283';
		END IF;
		
		RETURN cCodRet;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 08/11/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: ALTA Y BAJA DE PERSONAS MORALES EN LISTAS NEGATIVAS', 
'DESCRIPCION: SPL encargado de hacer la eliminación de personas morales de las listas negativas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cla_genrepdetallelistasnegativas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRuta CHAR(100), pFechaInicio DATE, pFechaFin DATE)
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS archivo_generado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	DEFINE iRegistros INTEGER;
	DEFINE cQuery CHAR(255);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cReporte CHAR(100);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	LET iRegistros = 0;
	LET cQuery = '';
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET cUsrBin = '/usr/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;
	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cReporte = '';
	LET cNombreArchivo = '';
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				IF ven_transacc = 1 THEN
					ROLLBACK WORK; --		
				END IF;
				
				RETURN cCodRet,cNombreArchivo;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535,-255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cla_genrepdetallelistasnegativas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRuta = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE
		LET pRuta = TRIM(pRuta) || '/';		
		LET cReporte = 'LISTAS_NEGATIVAS';
		LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.xls';
		LET cNombreArchivo = TRIM(cReporte)||'.xls';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cCmd1 ="";
			LET cCmd1 = "SELECT 'NO. DE CLIENTE','RAZON SOCIAL','FECHA DE CONSTITUCION','RFC','COMENTARIOS','FECHA DE INCLUSION','USUARIO','STATUS' FROM systables WHERE tabid = 1";	
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT ''''||num_cliente,razon_social,TO_CHAR(fecha_constitucion, '%d/%m/%Y'),rfc,comentarios,TO_CHAR(fecha_inclusion, '%d/%m/%Y'),usuario,status";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_mant_listainterna WHERE fecha_inclusion BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"' AND status = 'A' ORDER BY fecha_inclusion ASC);";
						
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)|| ' DELIMITER '|| '''	'''|| ' ' ||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo query.sql
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la línea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,cNombreArchivo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 09/11/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: REPORTE DE LISTAS NEGATIVAS',
'DESCRIPCION: SPL encargado de generar el reporte de listas negativas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cla_insertactelistasnegativas(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecutivo CHAR(20), pNombreCte CHAR(110), pTipoPersona CHAR(10), 
pRazonSocial CHAR(60), pFechaCon DATE, pRfc CHAR(13), pComentarios CHAR(250), pFechaInc DATE, pStatus CHAR(8))
	RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iExiste = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cla_insertactelistasnegativas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecutivo = '' OR pComentarios = '' OR pFechaInc IS NULL OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdinteg:si_mant_listainterna idx_lisint)} COUNT(num_cliente) INTO iExiste 
		FROM bdinteg:"informix".si_mant_listainterna WHERE num_cliente = pEjecutivo;
		
		IF NVL(iExiste,0) = 0 THEN
		
			INSERT INTO bdinteg:"informix".si_mant_listainterna (num_cliente,nom_cliente,tipo_persona,razon_social,fecha_constitucion,rfc,comentarios,fecha_inclusion,usuario,status)
			VALUES (pEjecutivo,pNombreCte,pTipoPersona,pRazonSocial,pFechaCon,pRfc,pComentarios,pFechaInc,pUsuario,pStatus);
		
			-- Valida Inserción
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
			END IF;
		
		ELSE 
			
			UPDATE bdinteg:"informix".si_mant_listainterna SET comentarios = pComentarios, fecha_inclusion = pFechaInc, usuario = pUsuario WHERE num_cliente = pEjecutivo;
			
			-- Valida Actualización
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
		
		END IF;
		
		RETURN cCodRet;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 08/11/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: ALTA Y BAJA DE PERSONAS MORALES EN LISTAS NEGATIVAS', 
'DESCRIPCION: SPL encargado de hacer la inserción de personas morales a las listas negativas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cla_validactelistasnegativas(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecutivo CHAR(20), pEjecucion CHAR(1))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS valida_existe,
		CHAR(8) AS status;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cStatus CHAR(8);
	DEFINE iExiste INTEGER;
	DEFINE iValidaExiste CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cStatus = '';
	LET iExiste = 0;
	LET iValidaExiste = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iValidaExiste, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cla_validactelistasnegativas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecutivo = '' OR pEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iValidaExiste, cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iValidaExiste, cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Valida si el cliente ya existe
		IF pEjecucion = '1' THEN
		
			SELECT {+INDEX (bdinteg:si_mant_listainterna idx_lisint)} status INTO cStatus 
			FROM bdinteg:"informix".si_mant_listainterna WHERE num_cliente = pEjecutivo;
			
			IF cStatus <> '' THEN
				LET iValidaExiste = 't';
			ELSE
				LET iValidaExiste = 'f';			
			END IF;
		
		-- Actualiza
		ELIF pEjecucion = '2' THEN
				
			UPDATE bdinteg:"informix".si_mant_listainterna SET status = 'A', usuario = pUsuario, fecha_inclusion = DATE(CURRENT) WHERE num_cliente = pEjecutivo;
			
			-- Valida Actualización
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
		
		END IF;
		
		RETURN cCodRet, iValidaExiste, cStatus;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 08/11/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: ALTA Y BAJA DE PERSONAS MORALES EN LISTAS NEGATIVAS', 
'DESCRIPCION: SPL encargado de validar si el cliente ya existe en listas negativas y colocar su status = A (Activo).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generareporte_desactualizadasbc(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(150), pFecha CHAR(4))
        RETURNING CHAR(5) AS codret,
				  CHAR(150) AS archivo_generado;

        DEFINE cCodRet 				CHAR(5);
        DEFINE iSqlErr 				INT;
        DEFINE iExiste				INT;
        DEFINE cCmd1 				CHAR(3000);
		DEFINE cCmd2 				CHAR(3000);
		DEFINE cNivelDesactualizada CHAR(3);
		DEFINE cMemberKob 			CHAR(2);
		DEFINE cNameReport          CHAR(60);
		DEFINE cArchivoAux 			CHAR(150);
		DEFINE cArchDescarga		CHAR(150);
		DEFINE iNoRegistros         INT;
		DEFINE cCodRetSp		    CHAR(5);
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iExiste = 0;
        LET cCmd1 = '';
		LET cCmd2 = '';
		LET cNivelDesactualizada = '';
		LET cMemberKob = '';
		LET cNameReport = '';
		LET cArchivoAux = '';
		LET cArchDescarga = '';
		LET iNoRegistros = 0;
		LET cCodRetSp = '00000';
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet,cArchDescarga;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_generareporte_desactualizadasbc.out';
			--TRACE ON;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			IF pIdUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR pFecha = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cArchDescarga;
			END IF;
			
			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet,cArchDescarga;
			END IF;
			
			FOREACH SELECT DISTINCT nivel_desactualizada, member_kob 
					INTO cNivelDesactualizada, cMemberKob
					FROM bdicred:'informix'.sd_desactualizadas_buro
					WHERE fecha_proceso = TRIM(pFecha)
					
					LET cNameReport = '3056_'||TRIM(cMemberKob)||'_desact_'||TRIM(cNivelDesactualizada)||'.'||TRIM(pFecha)||'.txt';

					LET cArchDescarga = TRIM(TRIM(pRutaDescarga)||TRIM(cNameReport));
					LET cCmd1 ="";
					LET cCmd1 ="duplicada, nivel_desactualizada, member_code, member_kob, num_credito, fecha_reporte, id_expediente,";				
					LET cCmd1 =""||TRIM(cCmd1)||"rfc, apellido_paterno, apellido_materno, apellido_adicional, primer_nombre, segundo_nombre, fecha_apertura,";				
					LET cCmd1 =""||TRIM(cCmd1)||"tipo_contrato, tipo_cuenta, limite_credito, historico_pago, id_interno, clave_observacion, forma_pago,";				
					LET cCmd1 =""||TRIM(cCmd1)||"saldo_actual, saldo_vencido, importe_pago, fecha_cierre, saldo_actual_1, saldo_vencido_1, importe_pago_1, forma_pago_1, clave_observa_1, num_credito_ext ";
					
					LET cCmd2 =" nivel_desactualizada='"||TRIM(cNivelDesactualizada)||"' AND member_kob = '"||TRIM(cMemberKob)||"' AND fecha_proceso ='"||TRIM(pFecha)||"'";
					
					SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cArchDescarga)||' SELECT '||TRIM(cCmd1)||' FROM bdicred:sd_desactualizadas_buro WHERE '||TRIM(cCmd2)||';" | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1');
					
					-- EjecuciÃ³n del SP para la carga de los encabezados
					EXECUTE PROCEDURE bdicnweb:"informix".sp_obtieneencabezadomasivo(pIdFuncion, TRIM(cArchDescarga)) INTO cCodRetSp;
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, '';
					END IF;
					
					LET iNoRegistros = iNoRegistros + 1;
					
					RETURN cCodRet,cArchDescarga WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cArchDescarga;
			END IF;		
        END;
END PROCEDURE
DOCUMENT "AUTOR: Rodolfo Conde Flores",
"FECHA: 01/12/2015",
'MODULO: CrÃ©dito',
'FUNCIONALIDAD: Cuentas Desactualizadas de BurÃ³ de CrÃ©dito',
"DESCRIPCIÃ?N: Genera los reportes txt para respuesta a BurÃ³ de CrÃ©dito",
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaexpediente_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pNumRegs CHAR(6))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	                 
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	DEFINE cEmpresa CHAR(3);
	DEFINE cCuenta CHAR(20);
	DEFINE cProdNombre   CHAR(40);
	DEFINE cCodDocto CHAR(4);
	DEFINE cFechaAlta DATE;
	DEFINE cCodGrupo CHAR(3);
	DEFINE cDescripGpo CHAR(30);
	DEFINE cDescripDocto CHAR(35);
	DEFINE cDescrip2 CHAR(30);
	DEFINE cMultiImg CHAR(1);
	DEFINE cSecuencia SMALLINT;

	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';    
	LET iNumRegistros = 0;
	LET iRecuperacion = 0;
	
	LET cCuenta  = '';
	LET cProdNombre  = '';
	LET cCodDocto  = '';
	LET cFechaAlta = '';
	LET cCodGrupo  = '';
	LET cDescripGpo  = '';
	LET cDescripDocto  = '';
	LET cDescrip2 = '';
	LET cMultiImg = '';
	LET cSecuencia = '0';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".status_consultaexpediente
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;			
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaexpediente_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_consultaexpediente WHERE usuario_insert = pUsuario;
		DELETE FROM "informix".sw_datos_consultaexpediente WHERE usuario_insert = pUsuario;
		INSERT INTO "informix".status_consultaexpediente(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".status_consultaexpediente
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".status_consultaexpediente
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			EXECUTE PROCEDURE bdidigital:"informix".cons_expediente(cEmpresa, pNumCliente, pNumRegs)
			INTO cCodRetSp, cCuenta, cProdNombre, cCodDocto, cFechaAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultiImg, cSecuencia
			
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:"informix".cons_expediente';
				ELIF iCodRetSp = 110 THEN
					LET cCodRet = '00003';
					UPDATE "informix".status_consultaexpediente
			        SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			        RETURN cCodRet,iNumRegistros;
				ELSE
					IF iCodRetSp = 0 THEN
						INSERT INTO "informix".sw_datos_consultaexpediente(usuario_insert,cuenta,producto_nombre,cod_docto,fecha_alta,cod_grupo,descrip_gpo,descrip_docto,descrip_2,multi_img,secuencia)
						VALUES (pUsuario,cCuenta,cProdNombre,cCodDocto,cFechaAlta,cCodGrupo,cDescripGpo,cDescripDocto,cDescrip2,cMultiImg,cSecuencia);
						LET iRecuperacion = iRecuperacion + 1;
					ELSE
						LET cCodRet = cCodRetSp;
						UPDATE "informix".status_consultaexpediente
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
						RETURN cCodRet,iNumRegistros;
					END IF;
				END IF;
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iNumRegistros 
		FROM "informix".sw_datos_consultaexpediente 
		WHERE usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".status_consultaexpediente
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		UPDATE "informix".status_consultaexpediente
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;
		
		RETURN cCodRet, iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA 16/05/2019',
'DESCRIPCION: Spl encargado de consultar los registros existentes de expediente del cliente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaexpediente2(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pNumRegs CHAR(6), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(20) AS cuenta,
				CHAR(40) AS prodNombre,
				CHAR(4)  AS codDocto,
				DATE     AS fechaAlta,
				CHAR(3)  AS codGrupo,
				CHAR(30) AS descripGpo,
				CHAR(35) AS descripDocto,
				CHAR(30) AS descrip2,
				CHAR(1)  AS multiImg,
				SMALLINT AS secuencia;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCuenta CHAR(20);
	DEFINE cProdNombre   CHAR(40);
	DEFINE cCodDocto CHAR(4);
	DEFINE cFechaAlta DATE;
	DEFINE cCodGrupo CHAR(3);
	DEFINE cDescripGpo CHAR(30);
	DEFINE cDescripDocto CHAR(35);
	DEFINE cDescrip2 CHAR(30);
	DEFINE cMultiImg CHAR(1);
	DEFINE cSecuencia SMALLINT;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegs INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cCuenta  = '';
	LET cProdNombre  = '';
	LET cCodDocto  = '';
	LET cFechaAlta = '';
	LET cCodGrupo  = '';
	LET cDescripGpo  = '';
	LET cDescripDocto  = '';
	LET cDescrip2 = '';
	LET cMultiImg = '';
	LET cSecuencia = '0';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, cFechaAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultiImg, cSecuencia;
		END EXCEPTION;
		
		IF pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, cFechaAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultiImg, cSecuencia;
		END IF;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaexpediente2.out';
		--TRACE ON;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, cFechaAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultiImg, cSecuencia;
		END IF;
		
		IF pUsuario = '' OR pIdFuncion = '' OR NVL(pNumCliente, '') = '' OR NVL(pNumRegs, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, cFechaAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultiImg, cSecuencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion cuenta,producto_nombre,cod_docto,fecha_alta,cod_grupo,descrip_gpo,descrip_docto,descrip_2,multi_img,secuencia
			INTO cCuenta, cProdNombre, cCodDocto, cFechaAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultiImg, cSecuencia
			FROM "informix".sw_datos_consultaexpediente
			WHERE usuario_insert = pUsuario
			
			LET iNoRegs = iNoRegs + 1;
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, cFechaAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultiImg, cSecuencia WITH RESUME;
			
		END FOREACH;
		
		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, cFechaAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultiImg, cSecuencia;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', '', '', '', '', '', '', '';
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 16/05/2019',
'DESCRIPCION: Consulta los registros existentes de Expediente Digital',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusexpediente(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusexpediente.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM bdicnweb:"informix".status_consultaexpediente
		WHERE usuario_insert = pUsuario;
				
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA 16/05/2019',
'DESCRIPCION: SPL encargado de verificar el status de la consulta de expediente digital',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardainfoctemoral_may29(pUsuario CHAR(8),										
												  pIdFuncion 		 	CHAR(10),
												  pfuncion           	CHAR(1),
												  pnumcte            	CHAR(20),
												  pstatuscte         	CHAR(2),
												  psucursal          	CHAR(4),
												  ptp_persona        	CHAR(2),
												  ptp_cliente        	CHAR(1),
												  prazon_social      	CHAR(40),
												  prfc               	CHAR(13),
												  pfechaalta         	DATE,
												  pnacionalidad      	CHAR(2),
												  pnombrecorto       	CHAR(30),
												  pnombrecontacto    	CHAR(48),
												  ptelefonocontacto  	CHAR(13),
												  psufijo            	CHAR(2),
												  pgiro              	CHAR(20),
												  pactividad_princ   	CHAR(3),
												  ppaginainternet    	CHAR(30),
												  psecuenciadirecciones SMALLINT,
												  ptipodir 				CHAR(1),
												  pcalle				CHAR(40),
												  pcolonia 				CHAR(60),
												  pmunicipio 			CHAR(5),
												  pentre_calles 		CHAR(40),
												  ppais 				CHAR(3),
												  pentidad 				CHAR(2),
												  plocalidad 			CHAR(3),
												  pcodpostal			CHAR(5),
												  ptipotel1 			CHAR(1),
												  ptelefono1 			CHAR(13),
												  ptipotel2 			CHAR(1),
												  ptelefono2 			CHAR(13),
												  ptipotel3 			CHAR(1),
												  ptelefono3 			CHAR(13),
												  pextension 			CHAR(5),
												  pestado_inegi 		CHAR(2),
												  pmunicipio_inegi 		CHAR(3),
												  plocalidad_inegi 		CHAR(4),
												  pnociudad 			SMALLINT,
												  pnoext 				CHAR(10),
												  pnoint 				CHAR(10),
												  pdepto 				CHAR(6),
												  pnocalle 				INTEGER,
												  pnocolonia 			INTEGER,
												  ppuntocar 			CHAR(1),
												  punihabi 				CHAR(1),
												  pmanz 				SMALLINT,
												  ppotros 				SMALLINT,
												  pandador 				SMALLINT,
												  petapa 				SMALLINT,
												  plote 				SMALLINT,
												  pedif 				SMALLINT,
												  pentrada 				SMALLINT,
												  pobserva 				CHAR(80), 
												  psecuenciaapoderados  INTEGER, 
												  pNumCteApode 			CHAR(20), 
												  pNomApodera 			CHAR(60), 
												  pFecha 				DATE,
												  pEscConstitu   		CHAR(30),
												  pNombNotario   		CHAR(30),
												  pNumNotaria    		CHAR(5),
												  pCdNotaria     		CHAR(30),
												  pFecInscrip    		DATE,
												  pFecConstitu   		DATE,
												  pNumFolMerca   		CHAR(30),
												  pCdFolMerca    		CHAR(30),
												  pEscriPoder    		CHAR(30),
												  pNombNotpd     		CHAR(30),
												  pNumNotariopd  		CHAR(30),
												  pCdNotariopd   		CHAR(30),
												  pFecInscripd   		DATE,
												  pFecEscritupd  		DATE,
												  pFolMercapd    		CHAR(30),
												  pCdFolMercaPd  		CHAR(30),
												  pNomSociedad   		CHAR(30),
												  pEmail         		CHAR(100),
												  pSat_fea       		CHAR(25),
												  pDoc_legal     		CHAR(100),
												  pTpo_Poder     		CHAR(3),
												  pTpo_Admin     		CHAR(3),
												  pTpo_Org       		CHAR(3))
	RETURNING CHAR(5) AS codret,
			  CHAR(20) AS cNumcte;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumcte CHAR(20);
	DEFINE bInTrasaction BOOLEAN;
	
	DEFINE cCodRetLN	   CHAR(6);
	DEFINE sFolio          CHAR(12);
	DEFINE sNumcte         CHAR(20);
	DEFINE sFechaLN        CHAR(10);	
	DEFINE sApellPaterno   CHAR(20);
	DEFINE sApellMaterno   CHAR(20);
	DEFINE sNombre1        CHAR(20);
	DEFINE sNombre2        CHAR(20);	
	DEFINE sFechaNac	   CHAR(10);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumcte = '';
	LET bInTrasaction = 'f';
	
	LET cCodRetLN           ='';
	LET sFolio              ='';
	LET sNumcte             ='';       
	LET sFechaLN            ='';
	LET sApellPaterno       ='';
	LET sApellMaterno       ='';
	LET sNombre1            ='';
	LET sNombre2            ='';	
	LET sFechaNac           ='';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumcte;
		END EXCEPTION;
		ON EXCEPTION IN (-535)
				COMMIT WORK;
				LET bInTrasaction = 't';
		END EXCEPTION WITH RESUME;
		
		 SET DEBUG FILE TO '/controlcambios/P-BD-20192905-01/sp_guardainfoctemoral.txt';
		 TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumcte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumcte;
		END IF;
		
		-----VALIDA EN LISTA NEGRA-------------------------------------------
        SELECT apell_paterno, apell_materno, nombre1, nombre2 INTO sApellPaterno, sApellMaterno, sNombre1, sNombre2 FROM bdinteg:"informix".si_cliente where numcte = pNumCteApode;
		SELECT fecha_nac INTO sFechaNac FROM bdinteg:"informix".si_ctepf where numcte = pNumCteApode;				
        
        EXECUTE PROCEDURE bdiauditor:"informix".sp_busqueda_cte_listanegra(sNombre1, sNombre2, sApellPaterno, sApellMaterno, sFechaNac) INTO cCodRetLN;

        IF(cCodRetLN = '000002') THEN
            LET cNumcte = 'En lista negra';
			LET cCodRet = '00995';
            
            INSERT INTO bdinteg:"informix".si_bitacora_lista_negra(folio, numcliente, apell_paterno, apell_materno, nombre1, nombre2, fecha_nacimiento, fecha)
            VALUES('',pNumCteApode,sApellPaterno,sApellMaterno,sNombre1,sNombre2,sFechaNac,TODAY);           
			
			RETURN cCodRet,cNumcte;	
        END IF;        
				
        ----------------------------------------------------------
		
		LET pnombrecontacto = TRIM(pNumCteApode);
		
		EXECUTE PROCEDURE bdicnweb:"informix".sp_guardactemoral(pUsuario, pIdFuncion, pfuncion, pnumcte, pstatuscte, psucursal, ptp_persona, ptp_cliente, prazon_social, prfc,               
											  pfechaalta, pnacionalidad, pnombrecorto, pnombrecontacto, ptelefonocontacto, psufijo, pgiro, pactividad_princ, ppaginainternet)    
		INTO cCodRetSp, cNumcte;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_guardactemoral';
		END IF;
		
		IF cCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumcte;
		END IF;
		
		LET pnumcte = cNumcte;
		LET cCodRetSp = '';
		EXECUTE PROCEDURE bdicnweb:"informix".sp_guardadireccionesctemoral(pUsuario, pIdFuncion, pfuncion, pnumcte,	psecuenciadirecciones, ptipodir, pcalle, pcolonia, pmunicipio, pentre_calles, 		
																		   ppais, pentidad, plocalidad, pcodpostal, ptipotel1, ptelefono1, ptipotel2, ptelefono2, ptipotel3, ptelefono3, 		
																		   pextension, pestado_inegi, pmunicipio_inegi, plocalidad_inegi, pnociudad, pnoext, pnoint, pdepto, pnocalle, 			
																		   pnocolonia, ppuntocar, punihabi, pmanz, ppotros, pandador, petapa, plote, pedif, pentrada, pobserva, pSucursal)			
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_guardadireccionesctemoral';
		END IF;
			
		IF cCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumcte;
		END IF;
		
		
		IF pfuncion = 'A' THEN
			LET psecuenciaapoderados = '1';
		END IF;
		
		LET cCodRetSp = '';
		
		SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy
		INTO pfecha
		FROM bdinteg:si_fechas
		WHERE empresa = '001';
		
		EXECUTE PROCEDURE bdicnweb:"informix".sp_guardaapoderadosctemoral(pUsuario, pIdFuncion, pNumCte, psecuenciaapoderados, pNumCteApode, pNomApodera, pFecha) 		
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_guardaapoderadosctemoral';
		END IF;
			
		IF cCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumcte;
		END IF;
			
		LET cCodRetSp = '';
		LET  pEmail = LOWER(pEmail);
		
		BEGIN;
		EXECUTE PROCEDURE bdicnweb:"informix".sp_guardadatoslegalesctemoral(pUsuario, pIdFuncion, pNumCte, pEscConstitu, pNombNotario, pNumNotaria, pCdNotaria, pFecInscrip, pFecConstitu,   
																			pNumFolMerca, pCdFolMerca, pEscriPoder, pNombNotpd, pNumNotariopd, pCdNotariopd, pFecInscripd, pFecEscritupd,  
																			pFolMercapd, pCdFolMercaPd, pNomSociedad, pEmail, pSat_fea, pDoc_legal, pTpo_Poder, pTpo_Admin, pTpo_Org)														  		
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_guardaapoderadosctemoral';
		END IF;
			
		IF cCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumcte;
		END IF;

		IF bInTrasaction = 't' THEN
			begin;
		END IF;


		LET cCodRet = cCodRetSp;
		RETURN cCodRet, cNumcte;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 28/05/2014',
'DESCRIPCION: Guarda datos,direccion, apoderado y datos legales  de cliente moral',
'AUTOR: M.D.S.Sandra Cano',
'FECHA: 03/10/2016',
'DESCRIPCION: Se actualiza para ampliar campo correo a CHAR(100)',
'ID REQUERIMIENTO TASF: CLI-01-10-03-B-0450',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cattiporeporteart61(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS id_reporte, 
			CHAR(45) AS desc_reporte;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdReporte CHAR(2);
	DEFINE cDescReporte CHAR(45);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdReporte = '';
	LET cDescReporte = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdReporte, cDescReporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cattiporeporteart61.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdReporte, cDescReporte;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdReporte, cDescReporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT reporte, desc_reporte INTO cIdReporte, cDescReporte 
			FROM bdicnweb:"informix".sw_tiporeporte ORDER BY reporte ASC
			
			RETURN cCodret, cIdReporte, cDescReporte WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdReporte, UPPER(cDescReporte);
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 17/01/2019',
'MODULO: DEBITO',
'FUNCIONALIDAD: REPORTE CUENTAS INACTIVAS (ART 61)',
'DESCRIPCION: SPL encargado de consultar el llenado del catálogo Tipo de Reporte.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportesgeneradosmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(100) AS nombre_reporte,
		DATE AS fecha_reporte,
		DATETIME HOUR TO SECOND AS hr_reporte;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesgeneradosmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion 
			nombre_reporte, fecha_reporte, hr_reporte
			INTO cNombre_reporte,dFecha_reporte,dHr_reporte
			FROM bdicnweb:"informix".sw_ctrlgenreportesmc
			WHERE fecha_reporte = DATE(CURRENT)
			AND usuario_insert = pUsuario
			ORDER BY hr_reporte ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 29/03/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTES MESA DE CONTROL',
'DESCRIPCION: SPL encargado de consultar el detalle de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportesgeneradosmc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesgeneradosmc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesmc
		WHERE fecha_reporte = DATE(CURRENT)
		AND usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;	
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 29/03/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTES MESA DE CONTROL',
'DESCRIPCION: SPL encargado de consultar el número total de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultapanel(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS cve_producto,
			CHAR(35) AS id_panel,
			CHAR(2) AS id_funcion,
			CHAR(1) AS estatus;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cCve_producto CHAR(4);
	DEFINE cId_panel CHAR(35);
	DEFINE cId_funcion CHAR(2);
	DEFINE cEstatus CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET cCve_producto = '';
	LET cId_panel = '';
	LET cId_funcion = '';
	LET cEstatus = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCve_producto, cId_panel, cId_funcion, cEstatus;
		END EXCEPTION;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCve_producto, cId_panel, cId_funcion, cEstatus;
		END IF;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultapanel.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT cve_producto, id_panel, id_funcion, estatus
			INTO cCve_producto, cId_panel, cId_funcion, cEstatus
			FROM bdicnweb:"informix".sw_mc_idproducto
			WHERE estatus = '1' ORDER BY id_registro ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cCve_producto, cId_panel, cId_funcion, cEstatus WITH RESUME;
		END FOREACH;
		
		IF NVL(iNoRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCve_producto, cId_panel, cId_funcion, cEstatus;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 15/03/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: CAMBIO DE ESTATUS',
'DESCRIPCION: SPL encargado de consultar los productos con estatus activo.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarinforeportecacmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pArea CHAR(2), pFechaInicial DATE, pFechaFinal DATE, pStatusInicial CHAR(2), pStatusFinal CHAR(2), pCveProducto CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
        RETURNING CHAR(5) AS codret,
                        INTEGER AS solicitudes_analizadas,
                        INTEGER AS solicitudes_rechazadas,
                        DECIMAL(10,2) AS porcentaje_rechazadas,
                        INTEGER AS sol_ee,
                        DECIMAL(10,2) AS porcentaje_ee,
                        INTEGER AS solicitudes_autorizadas,
                        DECIMAL(10,2) AS porcentaje_at,
                        INTEGER AS solicitudes_ce,
                        DECIMAL(10,2) AS porcentaje_ce,
                        INTEGER AS solicitudes_en_proceso,
                        DECIMAL(10,2) AS procentaje_sol_en_proceso,
                        CHAR(20) AS numero_solicitud,
                        CHAR(20) AS numero_cliente,
                        CHAR(104) AS nombre_cliente,
                        CHAR(4) AS sucursal,
                        CHAR(2) AS estatus_inicial,
                        CHAR(2) AS estatus_final,
                        DATE AS fecha_solicitud,
                        DATE AS fecha_cambio,
                        CHAR(3) AS motivo,
                        CHAR(250) AS justificacion,
                        CHAR(45) AS analista,
                        CHAR(10) AS tipo_movto,
                        CHAR(50) AS producto,
						CHAR(3) AS motivo2;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE cEmpresa CHAR(3);
        DEFINE iCodRet INTEGER;
        DEFINE iSolAnalizadas INTEGER;
        DEFINE iSolRechazadas INTEGER;
        DEFINE dPorcRechazadas DECIMAL(10,2);
        DEFINE iSolEE INTEGER;
        DEFINE dPorcEE DECIMAL(10,2);
        DEFINE iSolAutorizadas INTEGER;
        DEFINE dPorcAT DECIMAL(10,2);
        DEFINE iSolCE INTEGER;
        DEFINE dProcCE DECIMAL(10,2);
        DEFINE iSolProceso INTEGER;
        DEFINE dPorcSolProceso DECIMAL(10,2);
        DEFINE cNumSolicitud CHAR(20);
        DEFINE cNumCliente CHAR(20);
        DEFINE cNombreCliente CHAR(104);
        DEFINE cSucursal CHAR(4);
        DEFINE cStatusInicial CHAR(2);
        DEFINE cStatusFinal CHAR(2);
        DEFINE dFechaSolicitud DATE;
        DEFINE dFechaCambio DATE;
        DEFINE cMotivo CHAR(3);
        DEFINE cJustificacion CHAR(250);
        DEFINE cAnalista CHAR(45);
        DEFINE cTipoMovimiento CHAR(10);
        DEFINE cProducto CHAR(50);
        DEFINE iRegistros INTEGER;
        DEFINE iRecuperacion INTEGER;
		DEFINE cMotivo2 CHAR(3);
        
        LET cCodRet = '00000';
        LET cEmpresa = '001';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRet = 0;
        LET iSolAnalizadas = 0;
        LET iSolRechazadas = 0;
        LET dPorcRechazadas = NULL;
        LET iSolEE = 0;
        LET dPorcEE = NULL;
        LET iSolAutorizadas = 0;
        LET dPorcAT = NULL;
        LET iSolCE = 0;
        LET dProcCE = NULL;
        LET iSolProceso = 0;
        LET dPorcSolProceso = NULL;
        LET cNumSolicitud = '';
        LET cNumCliente = '';
        LET cNombreCliente = '';
        LET cSucursal = '';
        LET cStatusInicial = '';
        LET cStatusFinal = '';
        LET dFechaSolicitud = NULL;
        LET dFechaCambio = NULL;
        LET cMotivo = '';
        LET cJustificacion = '';
        LET cAnalista = '';
        LET cTipoMovimiento = '';
        LET cProducto = '';
        LET iRegistros = 0;
        LET iRecuperacion = 0;
		LET cMotivo2 = '';
        
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
                                        iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
                                        cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
                                        dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consultarinforeportecacmc.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pArea = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
                                        iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
                                        cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
                                        dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2;
                END IF;
                
                IF pRegistros < 0 THEN 
                        LET cCodRet = '00098';
                        RETURN cCodRet, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
                                        iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
                                        cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
                                        dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2;
                END IF;
                
                -- VALIDACIÓN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
                                        iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
                                        cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
                                        dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2;
                END IF;
                
                IF pArea NOT IN ('01', '02', 'CS') THEN
                        LET cCodRet = '00005';
                        RETURN cCodRet, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
                                        iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
                                        cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
                                        dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2;
                END IF;
                
                IF pArea = 'CS' THEN
                        IF pFechaInicial IS NULL OR pFechaFinal IS NULL OR pStatusFinal = '' THEN
						LET cCodRet = '00003';
						RETURN cCodRet, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
										iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
										cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
										dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2;
                        END IF;
                END IF;
                
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				FOREACH 
				
					SELECT SKIP pRegistros FIRST pRecuperacion cod_ret, sol_analizada, sol_rechazada, porc_rechazada, sol_ee, sol_ee,
					sol_autorizad, porc_at, sol_ce, porc_ce, sol_en_proceso, porc_en_proceso, num_solicitud,
					num_cte, nom_cliente, sucursal, sta_inicial, sta_final, fecha_sol,
					fecha_cambio, motivo, justificacion, analista, tipo_movto, producto, motivo2
					INTO cCodRetSp, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
										iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
										cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
										dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2
					FROM "informix".sw_reportecambioestatusmc
					WHERE usuario = pUsuario
					
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
										iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
										cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
										dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2 WITH RESUME;
								
				END FOREACH;
				
                IF pRegistros = 0 AND iRecuperacion = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
										iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
										cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
										dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2;
                ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
										iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
										cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
										dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2;
                END IF;
                
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 04/03/2014',
'DESCRIPCION: Consulta información para el reporte de CAC',
'AUTOR: Oscar Flores Conde',
'FECHA: 11/01/2016',
'DESCRIPCION: Se agrega parametro de salida motivo2',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 19/03/2019',
'DESCRIPCION: Se cancela ejecución de spl bdicred:sp_consultarinforeportecac y se agrega tabla sw_reportecambioestatusmc para recuperar la información del reporte CAC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultartotinforeportecacmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pArea CHAR(2), pFechaInicial DATE, pFechaFinal DATE, pStatusInicial CHAR(2), pStatusFinal CHAR(2), pCveProducto CHAR(4))
        RETURNING CHAR(5) AS codret,
                        INTEGER AS total_registros;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE cEmpresa CHAR(3);
        DEFINE iCodRet INTEGER;
        DEFINE iSolAnalizadas INTEGER;
        DEFINE iSolRechazadas INTEGER;
        DEFINE dPorcRechazadas DECIMAL(10,2);
        DEFINE iSolEE INTEGER;
        DEFINE dPorcEE DECIMAL(10,2);
        DEFINE iSolAutorizadas INTEGER;
        DEFINE dPorcAT DECIMAL(10,2);
        DEFINE iSolCE INTEGER;
        DEFINE dProcCE DECIMAL(10,2);
        DEFINE iSolProceso INTEGER;
        DEFINE dPorcSolProceso DECIMAL(10,2);
        DEFINE cNumSolicitud CHAR(20);
        DEFINE cNumCliente CHAR(20);
        DEFINE cNombreCliente CHAR(104);
        DEFINE cSucursal CHAR(4);
        DEFINE cStatusInicial CHAR(2);
        DEFINE cStatusFinal CHAR(2);
        DEFINE dFechaSolicitud DATE;
        DEFINE dFechaCambio DATE;
        DEFINE cMotivo CHAR(3);
        DEFINE cJustificacion CHAR(250);
        DEFINE cAnalista CHAR(45);
        DEFINE cTipoMovimiento CHAR(10);
        DEFINE cProducto CHAR(50);
        DEFINE iRegistros INTEGER;
		DEFINE cMotivo2 CHAR(3);
        
        LET cCodRet = '00000';
        LET cEmpresa = '001';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRet = 0;
        LET iSolAnalizadas = 0;
        LET iSolRechazadas = 0;
        LET dPorcRechazadas = NULL;
        LET iSolEE = 0;
        LET dPorcEE = NULL;
        LET iSolAutorizadas = 0;
        LET dPorcAT = NULL;
        LET iSolCE = 0;
        LET dProcCE = NULL;
        LET iSolProceso = 0;
        LET dPorcSolProceso = NULL;
        LET cNumSolicitud = '';
        LET cNumCliente = '';
        LET cNombreCliente = '';
        LET cSucursal = '';
        LET cStatusInicial = '';
        LET cStatusFinal = '';
        LET dFechaSolicitud = NULL;
        LET dFechaCambio = NULL;
        LET cMotivo = '';
        LET cJustificacion = '';
        LET cAnalista = '';
        LET cTipoMovimiento = '';
        LET cProducto = '';
        LET iRegistros = 0;
		LET cMotivo2 = '';
        
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
						UPDATE "informix".status_repcambioestatusmc
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                        RETURN cCodRet, iRegistros;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consultartotinforeportecacmc.out';
                --TRACE ON;
				
				-- LIMPIEZA DE TABLA POR USUARIO
				DELETE FROM "informix".status_repcambioestatusmc WHERE usuario_insert = TRIM(pUsuario);
				INSERT INTO "informix".status_repcambioestatusmc(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
				IF pUsuario = '' OR pIdFuncion = '' OR pArea = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iRegistros;
                END IF;
                
                -- VALIDACIÓN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
						UPDATE "informix".status_repcambioestatusmc
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                        RETURN cCodRet, iRegistros;
                END IF;
                
                IF pArea NOT IN ('01', '02', 'CS') THEN
                        LET cCodRet = '00005';
                        RETURN cCodRet, iRegistros;
                END IF;
                
                IF pArea = 'CS' THEN
                        IF pFechaInicial IS NULL OR pFechaFinal IS NULL OR pStatusFinal = '' THEN
                                LET cCodRet = '00003';
                                RETURN cCodRet, iRegistros;
                        END IF;
                END IF;
                
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				DELETE FROM bdicnweb:"informix".sw_reportecambioestatusmc WHERE usuario = pUsuario;
				
                FOREACH EXECUTE PROCEDURE bdicred:sp_consultarinforeportecac(cEmpresa, pArea, pFechaInicial, pFechaFinal, pStatusInicial, pStatusFinal, pCveProducto)
                        INTO cCodRetSp, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
                                                iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
                                                cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
                                                dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2
                        
                        LET iCodRet = cCodRetSp::INTEGER;
                        IF iCodRet < 0 THEN
                                RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultarinforeportecac';
                        ELIF iCodRet IN (1, 2) THEN
                                LET cCodRet = '00030';
								UPDATE "informix".status_repcambioestatusmc
								SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                                RETURN cCodRet, iRegistros;
                        ELSE
                                LET iRegistros = iRegistros + 1;
                        END IF;
						
						
						INSERT INTO bdicnweb:"informix".sw_reportecambioestatusmc(cod_ret,sol_analizada,sol_rechazada,porc_rechazada,sol_ee,porc_ee,sol_autorizad,porc_at,	sol_ce,	porc_ce ,sol_en_proceso,porc_en_proceso	,
						num_solicitud ,num_cte,nom_cliente,	sucursal,sta_inicial,sta_final,	fecha_sol,fecha_cambio,	motivo ,justificacion ,analista,tipo_movto,producto,motivo2 ,usuario) 
						VALUES(cCodRetSp, iSolAnalizadas, iSolRechazadas, dPorcRechazadas, iSolEE, dPorcEE, 
                               iSolAutorizadas, dPorcAT, iSolCE, dProcCE, iSolProceso, dPorcSolProceso, cNumSolicitud, 
                               cNumCliente, cNombreCliente, cSucursal, cStatusInicial, cStatusFinal, dFechaSolicitud, 
                               dFechaCambio, cMotivo, cJustificacion, cAnalista, cTipoMovimiento, cProducto, cMotivo2, pUsuario);
                
                END FOREACH;
                
                IF iRegistros = 0 THEN
                        LET cCodRet = '00017';
						UPDATE "informix".status_repcambioestatusmc
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                        RETURN cCodRet, iRegistros;
                END IF;
				
				UPDATE "informix".status_repcambioestatusmc
				SET status = 'T', error_proceso = 'N', num_registros = iRegistros WHERE usuario_insert = pUsuario;
                
                RETURN cCodRet, iRegistros;
                
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 04/03/2014',
'DESCRIPCION: Consulta información para el reporte de CAC',
'AUTOR: Oscar Flores Conde',
'FECHA: 11/01/2016',
'DESCRIPCION: Se agrega parametro de salida',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 19/03/2019',
'DESCRIPCION: Se agrega tratamiento por volumetria, se anexa tabla status_repcambioestatusmc, sw_reportecambioestatusmc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificacambioestatusmc(pUsuario CHAR(8), pIdFuncion CHAR(10))
        RETURNING CHAR(5) AS codret,
                CHAR(1) AS status,
                INTEGER AS num_registros,
                CHAR(1) AS error_proceso,
                CHAR(5) AS error;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cStatus CHAR(1);
        DEFINE cErrorProceso CHAR(1);
        DEFINE cError CHAR(5);
        DEFINE iNumRegistros INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cStatus = '';
        LET cErrorProceso = '';
        LET cError = '';
        LET iNumRegistros = 0;

        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_verificacambioestatusmc.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
                END IF;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                SELECT status,num_registros,error_proceso,error
                INTO cStatus,iNumRegistros,cErrorProceso,cError
                FROM "informix".status_repcambioestatusmc WHERE usuario_insert = pUsuario;

                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					RETURN cCodRet,'I','','','';
                ELSE
					RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
                END IF;

        END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 19/03/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE CAMBIO DE ESTATUS',
'DESCRIPCION: SPL encargado verificar el status del reporte',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rep_prod_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,						  
		INTEGER AS tot_exitoso,
		INTEGER AS tot_no_exitoso;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cDescMensaje CHAR(100);
	DEFINE iExitoso INTEGER;
	DEFINE iNoExitoso INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cDescMensaje = '';
	LET iExitoso = 0;
	LET iNoExitoso = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN  cCodRet, iExitoso, iNoExitoso;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_prod_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, iExitoso, iNoExitoso;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, iExitoso, iNoExitoso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*) INTO iExitoso
		FROM bdicnweb:"informix".sw_cred_cambioproducto 
		WHERE us_insert = pUsuario AND resultado = 'EXITOSO';
		
		SELECT COUNT(*) INTO iNoExitoso
		FROM bdicnweb:"informix".sw_cred_cambioproducto 
		WHERE us_insert = pUsuario AND resultado = 'NO EXITOSO';
				
		RETURN  cCodRet, iExitoso, iNoExitoso;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/06/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE CAMBIO DE PRODUCTO', 
'DESCRIPCION: SPL encargado de consultar el número total de los registros cargados exitosamente.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_validacargaarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret;		

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iExiste SMALLINT;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iExiste = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_validacargaarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		SELECT COUNT(*) INTO iExiste 
		FROM bdicred:"informix".sd_rep_detallearchivotdc
		WHERE nombre_archivo = pNombreArchivo;
		
		IF iExiste = 0 THEN
		
			SELECT COUNT(*) INTO iExiste 
			FROM bdicred:"informix".sd_credito_upgrade
			WHERE nombre_archivo = pNombreArchivo; 
		
		END IF;
		
		IF iExiste > 0 THEN
			LET cCodRet = '01121'; --EL ARCHIVO QUE DESEA PROCESAR YA FUE CARGADO PREVIAMENTE, VERIFIQUE
		END IF;			
		
		RETURN cCodRet;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de validar si el archivo ya fue cargado previamente.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 05/06/2019',
'DESCRIPCION: Se modifica spl para validar si el archivo ya fue cargado a las tablas finales (sd_rep_detallearchivotdc, sd_credito_upgrade).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_grabadetallearchivotdc(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1),
pCredito CHAR(20), pNumCte CHAR(20), pNumTarjeta CHAR(20), pTit CHAR(3), pNombre CHAR(107), pEmbozado CHAR(21), pMaster CHAR(1), 
pTipoDomicilio CHAR(1), pTipoProceso CHAR(1), pNombreArchivo CHAR(100), pProdUpgrade CHAR(4), pError CHAR(1), pMensajeError CHAR(120))
	RETURNING CHAR(5) AS codret;	

DEFINE cCodRet CHAR(5);
DEFINE cCodRetSp CHAR(6);
DEFINE cDesCodRetSp CHAR(100);
DEFINE iSqlErr INTEGER;
DEFINE cEmpresa CHAR(3);
DEFINE iExiste SMALLINT;
DEFINE cMensajeError CHAR(120);

LET cCodRet = '00000';
LET cCodRetSp = '';
LET cDesCodRetSp = '';
LET iSqlErr = 0;
LET cEmpresa = '001';
LET iExiste = 0;
LET cMensajeError = '';

BEGIN

	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_grabadetallearchivotdc.out';
	--TRACE ON;
	
	IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pIdEjecucion = '' THEN
		LET cCodRet = '00003';
		RETURN cCodRet;
	END IF;
	
	-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet;
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--Registro Desmarcado
	--AAME RQM 10 682-4 Se contempla que si el usuario desmarca un registro del proceso se indique la descripción ya que se esta mandando con opcion 3
	IF pIdEjecucion IN ('1','3') THEN
		
		EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(pCredito,pNumTarjeta,pProdUpgrade,
		pTit,pNombre,pError,'NO','NO',pMensajeError,pUsuario,pNombreArchivo,CURRENT)
		INTO cCodRetSp,cDesCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_grabadetallearchivotdc';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
		END IF;
		--AAME RQM 10 682-4 Se contempla el grabado del resultado en la tabla de paso que cuenta el total de registros procesados
		IF pError = "1" THEN
			INSERT INTO bdicnweb:"informix".sw_cred_cambioproducto(descripcion,numero_credito,num_tarjeta,tipo_tarjeta,nombre_embozado,fecha,resultado,marcaje,sol_plastico,mensaje_error,us_insert,fecha_insert) 
			VALUES(cDesCodRetSp,pCredito,pNumTarjeta,pTit,pNombre,CURRENT,'NO EXITOSO','NO','NO',pMensajeError,pUsuario,current);
		ELIF pError = "0" THEN
			INSERT INTO bdicnweb:"informix".sw_cred_cambioproducto(descripcion,numero_credito,num_tarjeta,tipo_tarjeta,nombre_embozado,fecha,resultado,marcaje,sol_plastico,mensaje_error,us_insert,fecha_insert) 
			VALUES(cDesCodRetSp,pCredito,pNumTarjeta,pTit,pNombre,CURRENT,'EXITOSO','SI','SI',pMensajeError,pUsuario,current);	
		END IF;		
		
	END IF;
	
	RETURN cCodRet;
	
END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de grabar la información a reportería (se ejecuta spl sp_grabadetallearchivotdc).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_bitacoraerrormanualtdc(pUsuario CHAR(8), pIdFuncion CHAR(10),pBandera CHAR(1), pNomProceso CHAR(35), pNumCredito CHAR(20), 
pNumCte CHAR(20), pNumTarjeta CHAR(17),pTipoTarjeta CHAR(4),pMensajeError CHAR(100), pDirMac CHAR(12),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(35) AS nombre_proceso,
		CHAR(20) AS numero_credito,
		CHAR(20) AS numero_cliente, 
		CHAR(17) AS numero_tarjeta, 
		CHAR(4)  AS tipo_tarjeta, 		
		CHAR(100) AS mensaje_error,
		INTEGER AS num_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreProceso CHAR(35);
	DEFINE cNumeroCredito CHAR(20);
	DEFINE cNumeroCliente CHAR(20);
	DEFINE cNumeroTarjeta CHAR(17);
	DEFINE cTipoTarjeta CHAR(4);
	DEFINE cMensajeError CHAR(100);			
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
    DEFINE iErrorInf INTEGER;	DEFINE cMensajeRet CHAR(100);	
	DEFINE cNomArchivo CHAR(35);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNombreProceso = '';
	LET cNumeroCredito = '';
	LET cNumeroCliente = '';
	LET cNumeroTarjeta = '';
	LET cTipoTarjeta = '';
	LET cMensajeError = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
    LET iErrorInf = 0; --- AAME 20190218 RQM 10682-4 iErrorInf, cMensajeRet, cNomArchivo
	LET cMensajeRet = '';
	LET cNomArchivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_bitacoraerrormanualtdc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		END IF;
		
		IF pBandera = '1' THEN
		
			--- AAME 20190218 RQM 10682-4 SE VALIDA QUE SEA POR FUNCIONALIDAD DE MASIVO, EN CASO CONTRARIO SE REGISTRARÁ NORMALMENTE LOS ERRORES
			IF pIdFuncion = 'CCP102' THEN
				SELECT nombre_archivo INTO cNomArchivo
				FROM  bdicred:"informix".sd_credito_upgrade 
				WHERE num_credito = pNumCredito AND numerotarjeta=pNumTarjeta ;
							
				IF pNomProceso ='EJECUTA TRAMA' OR pNomProceso = 'sp_cp_obtensolicitudmaquilatdc' OR pNomProceso = 'sp_cp_graba_prod_upgrade' THEN
					LET iErrorInf= CHARINDEX('-',pMensajeError);
				   
					IF  iErrorInf = 0 THEN 
						IF pNomProceso = 'sp_cp_graba_prod_upgrade' THEN
							--- AAME 20190218 RQM 10682-4 SE GUARDA INFORMACIÓN DE REPORTERÍA
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(pNumCredito ,pNumTarjeta,'', pTipoTarjeta, '','1','NO','NO',cMensajeError,pUsuario,cNomArchivo,'')
							INTO cCodRet,cMensajeRet;
						ELSE
							--- AAME 20190218 RQM 10682-4 SE GUARDA INFORMACIÓN DE REPORTERÍA
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(pNumCredito ,pNumTarjeta,'', pTipoTarjeta, '','1','SI','NO',cMensajeError,pUsuario,cNomArchivo,'')
							INTO cCodRet,cMensajeRet;
						END IF;
					ELSE
						--- AAME 20190218 RQM 10682-4 SE GUARDA BITACORA DE ERROR SI SE PRESENTA ERROR DE INFORMIX
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc(nombre_proceso, numero_credito, numero_cliente, numero_tarjeta, tipo_tarjeta, mensaje_error, usuario, direccion_mac)
						VALUES(pNomProceso , pNumCredito, pNumCte, pNumTarjeta, pTipoTarjeta, pMensajeError, pUsuario, pDirMac);                    
					END IF;
				ELSE
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc(nombre_proceso, numero_credito, numero_cliente, numero_tarjeta, tipo_tarjeta, mensaje_error, usuario, direccion_mac)
					VALUES(pNomProceso , pNumCredito, pNumCte, pNumTarjeta, pTipoTarjeta, pMensajeError, pUsuario, pDirMac);
				END IF;
			ELSE
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc(nombre_proceso, numero_credito, numero_cliente, numero_tarjeta, tipo_tarjeta, mensaje_error, usuario, direccion_mac)
				VALUES(pNomProceso , pNumCredito, pNumCte, pNumTarjeta, pTipoTarjeta, pMensajeError, pUsuario, pDirMac);
			END IF;				
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN  
				LET cCodRet = '00282';
			END IF;
			
			RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		
		ELIF pBandera = '2' THEN
		
				SELECT COUNT(*) AS total
				INTO iNoRegistros
				FROM bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc
				WHERE usuario = pUsuario;
				
				RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,NVL(iNoRegistros,0);
		
		ELIF pBandera = '3' THEN
		
			FOREACH	
				SELECT SKIP pRegistros FIRST pRecuperacion nombre_proceso, numero_credito, numero_cliente, numero_tarjeta, tipo_tarjeta, mensaje_error
				INTO cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError			
				FROM bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc
				WHERE usuario = pUsuario
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros WITH RESUME;	
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
			END IF;
			
		ELIF pBandera = '4' THEN
		
			DELETE FROM bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc WHERE usuario = pUsuario;
			
			/*IF DBINFO('sqlca.sqlerrd2') = 0 THEN  
				LET cCodRet = '00862';
			END IF;*/
			
			RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		
		END IF;
					
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL Y MASIVO',
'DESCRIPCION: ESTE PROCEDIMIENTO CAPTURA LOS ERRORES QUE SE PUEDAN GENERAR EN EL PROCESO DE GUARDADO DE DATOS, MAQUILA Y EJECUCION DE LA TRANSACCION 30116',
'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'DESCRIPCION: CAMBIO PARA CORREGIR LOS DUPLICADOS EN EL RETORNO DE LA INFORMACION',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_consultadetcuentas(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pNombreArchivo CHAR(35),
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_tarjeta,
		CHAR(2) AS status_cred, 
		CHAR(20) AS num_credito,
		CHAR(3) AS tipo_tarjeta,
		CHAR(30) AS nombre_cliente,
		CHAR(21) AS nombre_embozado,
		CHAR(2) AS master,
		CHAR(1) AS domicilio_envio,
		CHAR(20) AS desc_domicilio_envio,
		CHAR(4) AS sucursal,
		CHAR(40) AS desc_sucursal,
		CHAR(20) AS num_cliente,
		CHAR(4) AS prod_destino,
		CHAR(40) AS desc_prod_destino,
		CHAR(1) AS origen_reg,
		INTEGER AS id_registro;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cStatusCred CHAR(2);
	DEFINE cNumCredito CHAR(20);
	DEFINE cTipoTarjeta CHAR(3);
	DEFINE cNombreCliente CHAR(30);
	DEFINE cNombreEmbozado CHAR(21);
	DEFINE cMaster CHAR(2);
	DEFINE cDomicilioEnvio CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cNumCliente CHAR(20);
	DEFINE cProdDestino CHAR(4);
	DEFINE cDescProdDestino CHAR(40);
	DEFINE cOrigenReg CHAR(1);
	DEFINE iIdRegistro INTEGER;
	DEFINE cDescDomEnvio CHAR(20);
	DEFINE cDescSucursal CHAR(40);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNumTarjeta = '';
	LET cStatusCred = '';
	LET cNumCredito = '';
	LET cTipoTarjeta = '';
	LET cNombreCliente = '';
	LET cNombreEmbozado = '';
	LET cMaster = '';
	LET cDomicilioEnvio = '';
	LET cSucursal = '';
	LET cNumCliente = '';
	LET cProdDestino = '';
	LET cDescProdDestino = '';
	LET cOrigenReg = '';
	LET iIdRegistro = 0;
	LET cDescDomEnvio = '';
	LET cDescSucursal = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_consultadetcuentas.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pNombreArchivo = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;			
		--AAME RQM 10 682-4 Se quita Trim del WHERE del Query principal y se le aplica trim por separado
		LET pNombreArchivo = TRIM(pNombreArchivo);
		
		FOREACH
			SELECT {+INDEX(bdicnweb:"informix".sw_cp_datosctastdc idx_sw_cp_datosctastdc_2)} SKIP pRegistros FIRST pRecuperacion num_tarjeta,status_cred,num_credito,tipo_tarjeta,
			nombre_cliente,nombre_embozado,master,
			--CASE WHEN master = 'M' THEN 'SI' WHEN master = 'V' THEN 'NO' ELSE '' END,
			domicilio_envio,sucursal,num_cliente,prod_destino,desc_prod_destino,origen_reg,id_registro
			INTO cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,
			cMaster,cDomicilioEnvio,cSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro
			FROM bdicnweb:"informix".sw_cp_datosctastdc 
			WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
			--AND num_tarjeta NOT IN (SELECT num_tarjeta
			AND num_credito NOT IN (SELECT num_credito			
									FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
									WHERE error_proceso = 'N' 
									AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac)
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
			ORDER BY num_credito,num_tarjeta ASC
			
			--AAME RQM 10 682-4 Se quita Case When del Select por reglas de BD. y se reemplaza por condicionales
			IF NVL(cMaster,'') = 'M' THEN 
				LET cMaster = 'SI'; 
			ELIF NVL(cMaster,'')= 'V' THEN 
				LET cMaster='NO'; 
			ELSE 
				LET cMaster = ''; 
			END IF;
			
			-- RECUPERA DOMICILIO ENVÍO DEL TITULAR PARA HOMOLOGAR TARJETAS ADICIONALES
			IF NVL(cTipoTarjeta,'') = 'ADI' THEN
				
				SELECT domicilio_envio, sucursal, prod_destino, desc_prod_destino INTO cDomicilioEnvio, cSucursal, cProdDestino, cDescProdDestino
				FROM bdicnweb:"informix".sw_cp_datosctastdc
				WHERE num_credito = cNumCredito AND tipo_tarjeta = 'TIT' 
				AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
				
				UPDATE bdicnweb:"informix".sw_cp_datosctastdc SET domicilio_envio = cDomicilioEnvio, sucursal = cSucursal, prod_destino = cProdDestino, desc_prod_destino = cDescProdDestino
				WHERE id_registro = iIdRegistro AND num_credito = cNumCredito AND tipo_tarjeta = cTipoTarjeta 
				AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
				
			END IF;
			
			IF NVL(cDomicilioEnvio,'') <> '' THEN
				SELECT desc_tipo_dir 
				INTO cDescDomEnvio	
				FROM bdinteg:"informix".si_tipo_dir_upg WHERE empresa = '001' AND tipo_dir = cDomicilioEnvio;
				
				IF NVL(cDomicilioEnvio,'') = '3' THEN
					SELECT nombre
					INTO cDescSucursal
					FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND sucursal = cSucursal;
				ELSE 
					--LET cSucursal = '';
					LET cDescSucursal = '';
				END IF;
			ELSE
				LET cDescDomEnvio = '';
				LET cDescSucursal = '';
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumTarjeta, UPPER(cStatusCred),cNumCredito,UPPER(cTipoTarjeta),UPPER(cNombreCliente),UPPER(cNombreEmbozado),
			UPPER(cMaster),cDomicilioEnvio,NVL(UPPER(cDescDomEnvio),''),cSucursal,NVL(UPPER(cDescSucursal),''),
			cNumCliente,cProdDestino,UPPER(cDescProdDestino),cOrigenReg,iIdRegistro WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de consultar el detalle de las cuentas a las cuales se les va a aplicar el cambio de producto.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 23/05/2019',
'DESCRIPCION: Se modifica spl para cambiar el filtro que descarta los registros con errores de negocio (num_credito por num_tarjeta).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_consultadetcuentas_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_consultadetcuentas_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;			

		LET pNombreArchivo = TRIM(pNombreArchivo);
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_cp_datosctastdc 
		WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
		--AND num_tarjeta NOT IN (SELECT num_tarjeta 
		AND num_credito NOT IN (SELECT num_credito
								FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
								WHERE error_proceso = 'N' 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac);			
			
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de consultar el número total de las cuentas a las cuales se les va a aplicar el cambio de producto.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 23/05/2019',
'DESCRIPCION: Se modifica spl para cambiar el filtro que descarta los registros con errores de negocio (num_credito por num_tarjeta).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_rep_prod_upgrade2(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaIni DATE, pFechaFin DATE, pTipo CHAR(1), pStatus CHAR(1), pArchivo CHAR(50), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,		
		CHAR(20) AS num_credito,
		CHAR(20) AS num_tarjeta,		  
        CHAR(10) AS tipo_tarjeta,
		CHAR(100) AS nombre,
		DATE AS fecha,
        CHAR(15) AS resultado,
		CHAR(3) AS marcaje,
		CHAR(2) AS sol_plastico,
		CHAR(100) AS mensaje_error;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cNombreEmbozado CHAR(100);
	DEFINE cNumCredito   CHAR(20);
	DEFINE cTipoTarjeta  CHAR(10);
	DEFINE cMiembro       CHAR(2);
	DEFINE dFecha		  DATE;
	DEFINE cResultado     CHAR(15);
	DEFINE cDescripcion   CHAR(100);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cMarcaje CHAR(3);
	DEFINE cSolPlastico CHAR(2);
	DEFINE cMensajeError CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cNombreEmbozado = '';
	LET cNumCredito = '';
	LET cTipoTarjeta = '';
	LET cMiembro = '';
	LET dFecha = date(1);
	LET cResultado = '';
	LET cDescripcion = '';
	LET cNumTarjeta = '';
	LET cMarcaje = '';
	LET cSolPlastico = '';
	LET cMensajeError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_rep_prod_upgrade2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaIni = '' OR pFechaFin = '' OR pTipo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_rep_prod_upgrade2(cEmpresa, pFechaIni, pFechaFin, pTipo, pStatus, pArchivo, pRegistros, pRecuperacion)
			--INTO cCodRetSp,cDescripcion,cNombreEmbozado,cNumCredito,cTipoTarjeta,cMiembro,dFecha,cResultado
			INTO cCodRetSp,cDescripcion,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError		  
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:bdicred:sp_rep_prod_upgrade2";		
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00973';
				RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			--RETURN cCodRet, NVL(UPPER(cNombreEmbozado),''), NVL(UPPER(cNumCredito),''), NVL(UPPER(cTipoTarjeta),''), NVL(UPPER(cMiembro),''), NVL(dFecha,''), NVL(UPPER(cResultado),'') WITH RESUME;
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,NVL(UPPER(cNombreEmbozado),''),dFecha,NVL(UPPER(cResultado),''),cMarcaje,cSolPlastico,NVL(UPPER(cMensajeError),'') WITH RESUME;
			
		END FOREACH;
		
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP CLONADO QUE LLENA EL COMBO PARA LA PANTALLA DE REPORTES Y LLENA EL GRID DE ESTA MISMA',
'AUTOR: L. Montserrat León Amador',
'FECHA: 03/05/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_updatedatoscuentastdc(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS bandera_det_error; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cCampo CHAR(35);
	DEFINE cDesMensajeError CHAR(120);
	DEFINE iContador INTEGER;
	DEFINE cBanDetError CHAR(1);
	
	DEFINE cNumCredito_Sol CHAR(20);
	
	DEFINE cNumCredito_Up CHAR(20);
	DEFINE cNumTarjeta_Up CHAR(20);
	DEFINE cMaster_Up CHAR(1);
	DEFINE cDomicilio_Up CHAR(1);
	DEFINE cSucursal_Up CHAR(4);
	DEFINE cProdDestino_Up CHAR(4);
	DEFINE cDescProdDestino_Up CHAR(40);
	DEFINE cNumCredito_sp CHAR(20);
	DEFINE cStatusCred_sp CHAR(2);		  
	DEFINE cTipoTarjeta_sp CHAR(3);
	DEFINE cNomCliente_sp CHAR(30);
	DEFINE cNomEmbozado_sp CHAR(21);
	DEFINE cNumTarjeta_sp CHAR(20);
	DEFINE cNumCliente_sp CHAR(20);	
	DEFINE cNumTarjeta CHAR(20);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cCampo = '';
	LET cDesMensajeError = '';
	LET iContador = 0;
	LET cBanDetError = 'f';
	
	LET cNumCredito_Sol = '';
	
	LET cNumCredito_Up = '';
	LET cNumTarjeta_Up = '';
	LET cMaster_Up = '';
	LET cDomicilio_Up = '';
	LET cSucursal_Up = '';
	LET cProdDestino_Up = '';
	LET cDescProdDestino_Up = '';
	
	LET cNumCredito_sp = '';
	LET cStatusCred_sp = '';		  
	LET cTipoTarjeta_sp = '';
	LET cNomCliente_sp = '';
	LET cNomEmbozado_sp = '';
	LET cNumTarjeta_sp = '';
	LET cNumCliente_sp = '';	
	LET cNumTarjeta = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			    
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
				SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
				WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND nombre_archivo = TRIM(pNombreArchivo);
				
				RETURN cCodRet,cBanDetError; 
			END IF;
		END EXCEPTION;			
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_updatedatoscuentastdc.out';
		--TRACE ON;
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pDireccionMac = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';

			UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN

			UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError; 
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		DELETE FROM bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
		WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND nombre_archivo = TRIM(pNombreArchivo);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_cp_statuslecturadatosctastdc(usuario,nombre_archivo,status,bandera_det_error,error_proceso,tipo_proceso,error)
		VALUES(pUsuario,TRIM(pNombreArchivo),'I','','','LECTURA','');

		-- LIMPIA TABLA PRINCIPAL
		DELETE FROM bdicnweb:"informix".sw_cp_datosctastdc WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
		-- AAME 12062019 RQM 10 682-4 LIMPIA TABLA DE CONTEO DE REGISTROS EXITOSOS Y NO EXITOSOS
		DELETE FROM bdicnweb:"informix".sw_cred_cambioproducto WHERE us_insert = pUsuario AND fecha_insert = DATE(CURRENT);
		   
		
		FOREACH
		
			SELECT DISTINCT num_credito INTO cNumCredito_Sol
			FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc
			WHERE tipo_tarjeta = 'T' AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
			
			FOREACH
				/* AAME 24062019 RQM 10 682-4 SE QUITA INSERT- SELECT A PETICION DE BD
				INSERT INTO bdicnweb:"informix".sw_cp_datosctastdc(num_tarjeta,status_cred,num_credito,tipo_tarjeta,nombre_cliente,
				nombre_embozado,master,domicilio_envio,sucursal,num_cliente,prod_destino,desc_prod_destino,origen_reg,usuario,
				nombre_archivo,direccion_mac,fecha_insert)
				--SELECT cNumTarjeta_sp,cStatusCred_sp,cNumCredito_sp,cTipoTarjeta_sp,cNomCliente_sp,
				SELECT cNumTarjeta_sp,cStatusCred_sp,cNumCredito_Sol,cTipoTarjeta_sp,cNomCliente_sp,
				cNomEmbozado_sp,'','','',cNumCliente_sp,'','','B',pUsuario,pNombreArchivo,pDireccionMac,DATE(CURRENT)
				FROM TABLE (PROCEDURE bdicred:"informix".sp_mostrar_grid_upgrade('001',cNumCredito_Sol,'0',''))
				AS sp_mostrar_grid_upgrade(cCodRetSp, cNumCredito_sp, cStatusCred_sp, cTipoTarjeta_sp, cNomCliente_sp, cNomEmbozado_sp, cNumTarjeta_sp, cNumCliente_sp);*/
				
				EXECUTE PROCEDURE bdicred:"informix".sp_mostrar_grid_upgrade('001',cNumCredito_Sol,'0','')
				INTO cCodRetSp, cNumCredito_sp, cStatusCred_sp, cTipoTarjeta_sp, cNomCliente_sp, cNomEmbozado_sp, cNumTarjeta_sp, cNumCliente_sp

				INSERT INTO bdicnweb:"informix".sw_cp_datosctastdc(num_tarjeta,status_cred,num_credito,tipo_tarjeta,nombre_cliente,
				nombre_embozado,master,domicilio_envio,sucursal,num_cliente,prod_destino,desc_prod_destino,origen_reg,usuario,
				nombre_archivo,direccion_mac,fecha_insert)
				VALUES(cNumTarjeta_sp, cStatusCred_sp, cNumCredito_Sol, cTipoTarjeta_sp, cNomCliente_sp, cNomEmbozado_sp,'','','',cNumCliente_sp,'','','B',pUsuario,pNombreArchivo,pDireccionMac,DATE(CURRENT));
			
			END FOREACH;
						
		END FOREACH;
		
		FOREACH
			SELECT num_credito,num_tarjeta,aceptacion,domicilio_envio,sucursal,prod_destino 
			INTO cNumCredito_Up,cNumTarjeta_Up,cMaster_Up,cDomicilio_Up,cSucursal_Up,cProdDestino_Up 
			FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
			WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
			ORDER BY id_registro ASC
			
			SELECT num_tarjeta 
			INTO cNumTarjeta
			FROM bdicnweb:"informix".sw_cp_datosctastdc 
			WHERE num_credito = cNumCredito_Up AND num_tarjeta = cNumTarjeta_Up
			AND usuario = pUsuario AND direccion_mac = pDireccionMac AND nombre_archivo = pNombreArchivo;
			--AAME 25062019 Se quita if exists a peticion de BD.
			IF cNumTarjeta <> '' THEN
			
				SELECT nombre_prod
				INTO cDescProdDestino_Up
				FROM bdicred:"informix".sd_definicion WHERE empresa = '001' AND num_producto = cProdDestino_Up;
	
				UPDATE bdicnweb:"informix".sw_cp_datosctastdc
				SET master = cMaster_Up, domicilio_envio = cDomicilio_Up, sucursal = cSucursal_Up, 
				prod_destino = cProdDestino_Up, desc_prod_destino = cDescProdDestino_Up, origen_reg = 'A'
				WHERE num_credito = cNumCredito_Up AND num_tarjeta = cNumTarjeta_Up
				AND usuario = pUsuario AND direccion_mac = pDireccionMac AND nombre_archivo = pNombreArchivo;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
					LET cBanDetError = 't';
					LET cCodRet = '00283';
					
					UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
					SET  status = 'E', error_proceso = 'S', error = cCodRet
					WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
					
					RETURN cCodRet,cBanDetError;
				END IF;	
	
			--ELSE
			
			END IF;
		END FOREACH;
		
		LET cBanDetError = TRIM(UPPER(cBanDetError));
		UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
		SET status = 'T', error_proceso = 'N', bandera_det_error = cBanDetError
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
		
		RETURN cCodRet,cBanDetError; 
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de consultar y agregar el detalle de todas las tarjetas adicionales que tienen las cuentas titulares',
'y que no se encontraron en el archivo de carga.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 23/05/2019',
'DESCRIPCION: Se modifica spl para asegurar el número de credito en la tabla sw_cp_datosctastdc de cada registro (cNumCredito_Sol).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_verificastatusarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS bandera_det_error,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS total,
		INTEGER AS procesados,
		INTEGER AS no_procesados;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cBanDetError CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iTotal INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE iNoProcesados INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cBanDetError = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iTotal = 0;
	LET iProcesados = 0;
	LET iNoProcesados = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_verificastatusarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;	
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,bandera_det_error,error_proceso,error,total_registros,total_procesados,total_noprocesados
		INTO cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados
		FROM bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
		WHERE usuario = TRIM(pUsuario) AND nombre_archivo = TRIM(pNombreArchivo);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'I','','','',0,0,0;			
		ELSE 			
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de hacer la validación inicio/fin para el proceso de lectura de archivos.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_usuario_movil_ws(pEjecutivoAlta CHAR(8), pPassword  CHAR(20), pImei CHAR(20),pImeiAnt CHAR(20),
                                                                                        pActivo CHAR(1), pNombre CHAR(60), pCentro_costos CHAR(8), pSucursal CHAR(4),
                                                                                        pNo_telefono CHAR(10), pGenerico1 CHAR(20), pGenerico2 CHAR(30), 
                                                                                        pGenerico3 CHAR(40), ptipoOperacion INTEGER)
                RETURNING CHAR(5) AS codret,INTEGER AS iNoRegistros;
                
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iCodRetSp INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE bExisteUsuario BOOLEAN;
		DEFINE inoImei INTEGER;
		DEFINE bInTransaction BOOLEAN;
		DEFINE pUsuario CHAR(8);
		DEFINE vEjecutivo CHAR(8);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iCodRetSp = 0;
        LET iNoRegistros = 0;
        LET bExisteUsuario = 'f';
        LET inoImei = 0;
		LET bInTransaction = 'f';
		LET pUsuario = 'admonusr';
		LET vEjecutivo = '';
		
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iNoRegistros;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/informix/LIP/sp_usuario_movil_ws.out';
                --TRACE ON;
        
				IF pPassword = '' OR   pImei = '' OR pActivo= '' OR pNombre = '' OR
                   pSucursal = '' OR pNo_telefono = '' OR ptipoOperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iNoRegistros;
                END IF;
		
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
		
                IF ptipoOperacion = 1 THEN
					-- Se valida que el ejecutivo no exista en la tabla
					
					SELECT ejecutivo
					INTO vEjecutivo
					FROM bdinteg:"informix".si_usuario_movil
					WHERE  ejecutivo = pEjecutivoAlta
					AND imei = pImei;
					
					IF (vEjecutivo IS NOT NULL AND vEjecutivo <> '')THEN
						LET cCodRet = '00479';
					ELSE	
						INSERT INTO bdinteg:"informix".si_usuario_movil (ejecutivo, password, imei, activo, nombre,centro_costos,
									no_telefono, generico1, generico2, generico3, fecha_insert,	user_insert, fecha_baja, user_baja, sucursal) 
						VALUES (pEjecutivoAlta, pPassword, pImei, pActivo, pNombre, pCentro_costos, pNo_telefono, pGenerico1,
									pGenerico2, pGenerico3, CURRENT, pUsuario, NULL, NULL,pSucursal);
																					
								LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
								IF iNoRegistros = 0 THEN -- 
									LET cCodRet = '00282';
								END IF;
                                                        
					END IF;
					RETURN cCodRet, iNoRegistros;
                
                END IF;

                IF  ptipoOperacion = 2 THEN 		
					IF pImei = pImeiAnt THEN
						UPDATE bdinteg:"informix".si_usuario_movil SET
                        password= pPassword,
                        imei= pImei,
                        activo= pActivo,
                        nombre = pNombre,
                        centro_costos=pCentro_costos,
                        no_telefono= pNo_telefono, 
                        generico1= pGenerico1, 
                        generico2= pGenerico2, 
                        generico3= pGenerico3, 
                        sucursal=pSucursal
                        WHERE ejecutivo=pEjecutivoAlta
						AND imei= pImeiAnt;
						
						IF(pActivo = '0') THEN
							UPDATE bdinteg:"informix".si_usuario_movil SET
							fecha_baja= CURRENT, 
							user_baja= pUsuario
							WHERE ejecutivo=pEjecutivoAlta
							AND imei= pImeiAnt;
						END IF
                        
                        LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
                        IF iNoRegistros = 0 THEN
                                LET cCodRet = '00001';
                        ELIF iNoRegistros > 1 THEN
                                LET cCodRet = '00283'; -- Se actulizaron mas de 1 registro
                        END IF;
						RETURN cCodRet, iNoRegistros;
					ELSE
						BEGIN
							ON EXCEPTION IN (-535)
								COMMIT; -- Transaccion del interact
								BEGIN WORK;
								LET bInTransaction = 't';
							END EXCEPTION WITH RESUME;
						
							BEGIN WORK;
							UPDATE bdinteg:"informix".si_usuario_movil SET
							password= pPassword,
							imei= pImei,
							activo= pActivo,
							nombre = pNombre,
							centro_costos=pCentro_costos,
							no_telefono= pNo_telefono, 
							generico1= pGenerico1, 
							generico2= pGenerico2, 
							generico3= pGenerico3, 
							sucursal=pSucursal
							WHERE ejecutivo=pEjecutivoAlta
							AND imei= pImeiAnt;
							
							IF(pActivo = '0') THEN
								UPDATE bdinteg:"informix".si_usuario_movil SET
								fecha_baja= CURRENT, 
								user_baja= pUsuario
								WHERE ejecutivo=pEjecutivoAlta
								AND imei= pImeiAnt;
							END IF
							
							SELECT COUNT(imei) INTO inoImei FROM bdinteg:"informix".si_usuario_movil WHERE imei= pImei AND ejecutivo = pEjecutivoAlta;
							IF inoImei = 1 THEN
								COMMIT WORK;
							ELSE
								ROLLBACK WORK;
								LET cCodRet = '00480'; -- El imei ya fue asignado anteriormente a este usuario
							END IF;
							
							IF bInTransaction THEN
								BEGIN WORK; -- APERTURA DE LA TRANSACCION DEL INTERACT
							END IF;
							
							RETURN cCodRet, iNoRegistros;
						END;
					END IF;
					
                END IF;
        END;
        
END PROCEDURE;