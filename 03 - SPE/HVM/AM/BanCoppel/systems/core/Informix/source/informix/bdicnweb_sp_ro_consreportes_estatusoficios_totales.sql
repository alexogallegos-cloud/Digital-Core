CREATE PROCEDURE "informix".sp_ro_consreportes_estatusoficios_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, pTipoBusqueda SMALLINT)
		RETURNING CHAR(5) AS codret,
				INTEGER AS totales;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdOficio INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdOficio = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_consreportes_estatusoficios_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pTipoBusqueda IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoBusqueda NOT IN (0, 1, 2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- BUSQUEDA DEL ID DE OFICIO
		SET ISOLATION TO DIRTY READ;
		SELECT id_oficio
		INTO iIdOficio
		FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml
		WHERE id_expediente = pIdExpediente;
		
		IF iIdOficio IS NULL THEN
			LET cCodRet = '00110';
			RETURN cCodRet, iNoRegistros;
		END IF;

		IF pTipoBusqueda IN (0, 1) THEN -- DIRIGIDOS A BANCOPPEL, 0 NEGATIVOS, 1 POSITIVOS
			IF pTipoBusqueda = 0 THEN
				
				SELECT COUNT(*)
				INTO iNoRegistros
				FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a, bdicnweb:"informix".sw_ro_cuentasconocidas b,
					bdicnweb:"informix".sw_ro_maeoficios c, bdicnweb:"informix".sw_ro_resulper d,
					bdicnweb:"informix".sw_ro_personassolicitud e
				WHERE a.id_expediente = pIdExpediente
					AND b.id_expediente = a.id_expediente 
					AND c.id_oficio = a.id_oficio
					AND d.id_oficio = c.id_oficio
					AND d.id_busqueda = b.id_busqueda
					AND d.status_busqueda = 0
					AND e.id_expediente = a.id_expediente
					AND e.id_solicitud_especifica = b.id_solicitud_especifica
					AND e.id_persona = b.id_persona;

				IF iNoRegistros = 0 THEN
					LET cCodRet = '00017';
				END IF;
					
				RETURN cCodRet, iNoRegistros;
					
			ELIF pTipoBusqueda = 1 THEN
				
				SELECT COUNT(*)
				INTO iNoRegistros
				FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a, bdicnweb:"informix".sw_ro_cuentasconocidas b,
					bdicnweb:"informix".sw_ro_maeoficios c, bdicnweb:"informix".sw_ro_resulper d,
					bdicnweb:"informix".sw_ro_personassolicitud e
				WHERE a.id_expediente = pIdExpediente
					AND b.id_expediente = a.id_expediente 
					AND c.id_oficio = a.id_oficio
					AND d.id_oficio = c.id_oficio
					AND d.id_busqueda = b.id_busqueda
					AND d.status_busqueda = 1
					AND e.id_expediente = a.id_expediente
					AND e.id_solicitud_especifica = b.id_solicitud_especifica
					AND e.id_persona = b.id_persona;
					
				IF iNoRegistros = 0 THEN
					LET cCodRet = '00017';
				END IF;
						
				RETURN cCodRet, iNoRegistros;
				
			END IF;
			
		ELIF pTipoBusqueda = 2 THEN -- CONSULTA DE OFICIOS POSITIVOS
		
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM (
				SELECT CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'fisica' THEN '1' ELSE '0' END AS persona_fisica
					, CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'moral' THEN '1' ELSE '0' END AS persona_moral
					, TRIM(TRIM(c.nombre)||' '||TRIM(c.ap_paterno)||' '||TRIM(c.ap_materno)) AS nombre
					, DECODE(d.status_busqueda, 2, '1', '') AS homonimo
					, '' AS referencia
					, d.id_busqueda
				FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
					bdicnweb:"informix".sw_ro_solicitudpartes c, bdicnweb:"informix".sw_ro_resulper d
				WHERE a.id_expediente = pIdExpediente
					AND b.id_oficio = a.id_oficio
					AND c.id_expediente = a.id_expediente
					AND d.id_oficio = b.id_oficio
					AND d.id_busqueda = c.id_busqueda
					AND d.status_busqueda IN (1, 2)
				UNION
				SELECT CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'fisica' THEN '1' ELSE '0' END AS persona_fisica
					, CASE WHEN TRIM(LOWER(c.des_tipo_persona)) = 'moral' THEN '1' ELSE '0' END AS persona_moral
					, TRIM(TRIM(c.nombre)||' '||TRIM(c.ap_paterno)||' '||TRIM(c.ap_materno)) AS nombre
					, '' AS homonimo
					, d.numcte AS referencia
					, d.id_busqueda
				FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
					bdicnweb:"informix".sw_ro_personassolicitud c, bdicnweb:"informix".sw_ro_resulper d
				WHERE a.id_expediente = pIdExpediente
					AND b.id_oficio = a.id_oficio
					AND c.id_expediente = a.id_expediente
					AND d.id_oficio = b.id_oficio
					AND d.id_busqueda = c.id_busqueda
					AND d.status_busqueda IN (1, 2)
				);
		
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
			END IF;
				
			RETURN cCodRet, iNoRegistros;
		
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 30/12/2015',
'MODULO: CONTESTACIÓN A OFICIOS',
'FUNCIONALIDAD: Reportes de estatus de oficios',
'DESCRIPCION: Consulta el total de registros de los reportes dirigidos a bancoppel (negativos y positivos) y los positivos no dirigidos a bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_consreportestatusoficioneg(pUsuario CHAR(8), pIdFuncion CHAR(10),	pIdExpediente INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS folio,
			CHAR(4) AS anio_oficio,
			CHAR(60) AS num_oficio,
			CHAR(60) AS num_expediente,
			CHAR(10) AS fecha_publicacion,	
			CHAR(32) AS area,			
			CHAR(2) AS dias_plazo,
			DATE AS fecha_vencimiento,	
			INTEGER AS persona_fisica,      
			INTEGER AS persona_moral;	 
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdSolicitudEsp INTEGER;
	DEFINE iIdOficio INTEGER;
	DEFINE iFolio INTEGER;
	DEFINE dAnioOficio CHAR(4);
	DEFINE cNumOficio CHAR(60);
	DEFINE cNumExpediente CHAR(60);
	DEFINE dFechaPublicacion CHAR(25);
	DEFINE cArea CHAR(32);
	DEFINE iIdArea CHAR(2);
	DEFINE cDescArea CHAR(30);
	DEFINE iDiasPlazo CHAR(2);
	DEFINE dFecha_Ven DATE;
	DEFINE cFechaVencimiento DATE;
	DEFINE iPersonaFisica INTEGER;
	DEFINE iPersonaMoral INTEGER;
	DEFINE iPerFisicaPartes INTEGER;
	DEFINE iPerMoralPartes INTEGER;
	DEFINE iPerFisicaSol INTEGER;
	DEFINE iPerMoralSol INTEGER;
	DEFINE iHayDatos INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdSolicitudEsp = 0;
	LET iIdOficio = 0;
	LET iFolio = 0;
	LET dAnioOficio = '';
	LET cNumOficio = '';
	LET cNumExpediente = '';
	LET dFechaPublicacion = '';	
	LET cArea = '';
	LET iIdArea = '';
	LET cDescArea = '';
	LET iDiasPlazo = '';
	LET dFecha_Ven = '';
	LET cFechaVencimiento = '';
	LET iPersonaFisica = 0;              
	LET iPersonaMoral = 0;               
	LET iPerFisicaPartes = 0;
	LET iPerMoralPartes = 0;
	LET iPerFisicaSol = 0;
	LET iPerMoralSol = 0;	
	LET iHayDatos = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_consreportestatusoficioneg.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH			
		
			SELECT SKIP pRegistros FIRST pRecuperacion folio, anio_oficio, a.num_oficio, num_expediente
				, MDY(SUBSTR(fecha_publicacion, 6, 2), SUBSTR(fecha_publicacion, 9, 2), SUBSTR(fecha_publicacion, 1, 4)) AS fecha_publicacion
				, c.desc_tipooficio AS area, a.dias_plazo
				, EXTEND(MDY(SUBSTR(fecha_publicacion, 6, 2), SUBSTR(fecha_publicacion, 9, 2), SUBSTR(fecha_publicacion, 1, 4)), YEAR TO DAY) + dias_plazo::INTEGER UNITS DAY AS fecha_vencimiento
			INTO iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, iDiasPlazo, cFechaVencimiento
			FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
			bdicnweb:"informix".sw_ro_tipooficios c, bdicnweb:"informix".sw_ro_resulper d
			WHERE a.id_expediente = pIdExpediente
			AND b.id_oficio = a.id_oficio
			AND c.id_tipooficio = b.id_tipooficio
			AND d.id_oficio = b.id_oficio
			AND d.status_busqueda = 0
			
			SELECT COUNT(id_persona)
			INTO iPerMoralPartes
			FROM bdicnweb:"informix".sw_ro_solicitudpartes
			WHERE id_expediente = pIdExpediente
			AND LOWER(des_tipo_persona) = 'moral';

			SELECT COUNT(id_persona)
			INTO iPerFisicaPartes
			FROM bdicnweb:"informix".sw_ro_solicitudpartes
			WHERE id_expediente = pIdExpediente
			AND LOWER(des_tipo_persona) = 'fisica';

			SELECT COUNT(id_persona)
			INTO iPerMoralSol
			FROM bdicnweb:"informix".sw_ro_personassolicitud
			WHERE id_expediente = pIdExpediente
			AND LOWER(des_tipo_persona) = 'moral';

			SELECT COUNT(id_persona)
			INTO iPerFisicaSol
			FROM bdicnweb:"informix".sw_ro_personassolicitud
			WHERE id_expediente = pIdExpediente
			AND LOWER(des_tipo_persona) = 'fisica';
		
			LET iPersonaFisica = NVL(iPerFisicaPartes, 0) + NVL(iPerFisicaSol, 0);
			LET iPersonaMoral = NVL(iPerMoralPartes, 0) + NVL(iPerMoralSol, 0);
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral WITH RESUME;
		
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iFolio, dAnioOficio, cNumOficio, cNumExpediente, dFechaPublicacion, cArea, 
			iDiasPlazo, cFechaVencimiento, iPersonaFisica, iPersonaMoral;
		END IF;		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE DE STATUS DE OFICIOS', 
'DESCRIPCION: SPL que hace la consulta para el llenado del detalle de los reportes oficios negativos.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 17/05/2016',
'DESCRIPCION: Se agregÃ³ el filtro para consultar el status_busqueda igual a 0 en la tabla bdicnweb:sw_ro_resulper.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_consreportestatusoficioneg_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;	 
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdSolicitudEsp INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdSolicitudEsp = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_consreportestatusoficioneg_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(a.id_expediente)
		INTO iNoRegistros
		FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml a,  bdicnweb:"informix".sw_ro_maeoficios b,
		bdicnweb:"informix".sw_ro_tipooficios c, bdicnweb:"informix".sw_ro_resulper d
		WHERE a.id_expediente = pIdExpediente
		AND b.id_oficio = a.id_oficio
		AND c.id_tipooficio = b.id_tipooficio
		AND d.id_oficio = b.id_oficio
		AND d.status_busqueda = 0;
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017'; 
		END IF;
		
		RETURN cCodRet, iNoRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE DE STATUS DE OFICIOS', 
'DESCRIPCION: SPL que consulta el numero total de registros correspondientes a los reportes oficios negativos.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 17/05/2016',
'DESCRIPCION: Se agregÃ³ el filtro para consultar el status_busqueda igual a 0 en la tabla bdicnweb:sw_ro_resulper.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_conssolicitudespecificaarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, 
	pIdSolEspecifica INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS id_persona,
            CHAR(30) AS caracter,
			CHAR(10) AS tipo_persona,
			CHAR(150) AS nombre,
			CHAR(26) AS apell_paterno,
			CHAR(26) AS apell_materno,
			CHAR(15) AS rfc,
			CHAR(50) AS relacion,
			CHAR(150) AS domicilio,
			CHAR(150) AS complementarios,
			CHAR(1) AS indicador;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE cCaracter CHAR(30);
	DEFINE cDescTipoPersona CHAR(10);
	DEFINE cNombre CHAR(150);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cRFC CHAR(15);
	DEFINE cRelacion CHAR(50);
	DEFINE cDomicilio CHAR(150);
	DEFINE cComplementarios CHAR(150);
	DEFINE iExiste INTEGER;
	DEFINE cIndicador CHAR(1);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdPersona = 0;
	LET cCaracter = '';
	LET cDescTipoPersona = '';
	LET cNombre = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cRFC = '';
	LET cRelacion = '';
	LET cDomicilio = '';
	LET cComplementarios = '';
	LET iExiste = 0;
	LET cIndicador = '';
	LET iRecuperacion = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_conssolicitudespecificaarchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pIdSolEspecifica IS NULL 
		OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END IF;
			
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		FOREACH	
			SELECT SKIP pRegistros FIRST pRecuperacion id_persona, caracter, des_tipo_persona, ap_paterno, ap_materno, nombre, rfc,
			relacion, domicilio, complementarios
			INTO iIdPersona, cCaracter, cDescTipoPersona, cApellPaterno, cApellMaterno, cNombre, cRFC,
			cRelacion, cDomicilio, cComplementarios
			FROM bdicnweb:"informix".sw_ro_personassolicitud 
			WHERE id_expediente = pIdExpediente 
			AND id_solicitud_especifica = pIdSolEspecifica
			
			SELECT COUNT(*)
			INTO  iExiste
			FROM bdicnweb:"informix".sw_ro_cuentasconocidas 
			WHERE id_expediente = pIdExpediente 
			AND id_solicitud_especifica = pIdSolEspecifica
			AND id_persona = iIdPersona;
			
			IF NVL(iExiste,0) = 0 THEN
				LET cIndicador = '0';
			ELIF NVL(iExiste,0) <> 0 THEN
				LET cIndicador = '1';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdPersona, TRIM(UPPER(cCaracter)), TRIM(UPPER(cDescTipoPersona)), TRIM(UPPER(cNombre)), TRIM(UPPER(cApellPaterno)), TRIM(UPPER(cApellMaterno)), TRIM(UPPER(cRFC)),
			TRIM(UPPER(cRelacion)), TRIM(UPPER(cDomicilio)), TRIM(UPPER(cComplementarios)), cIndicador WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC, 
			cRelacion, cDomicilio, cComplementarios, cIndicador;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que hace la consulta para el llenado del Detalle Solicitud Especifica Archivo XML.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_conssolicitudpartesarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, 
	pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS id_persona,
            CHAR(30) AS caracter,
			CHAR(10) AS tipo_persona,
			CHAR(150) AS nombre,
			CHAR(26) AS apell_paterno,
			CHAR(26) AS apell_materno,
			CHAR(15) AS rfc;
			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE cCaracter CHAR(30);
	DEFINE cDescTipoPersona CHAR(10);
	DEFINE cNombre CHAR(150);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cRFC CHAR(15);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdPersona = 0;
	LET cCaracter = '';
	LET cDescTipoPersona = '';
	LET cNombre = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cRFC = '';
	LET iRecuperacion = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_conssolicitudpartesarchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END IF;
			
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		FOREACH	
			SELECT SKIP pRegistros FIRST pRecuperacion id_persona, caracter, des_tipo_persona, ap_paterno, ap_materno, nombre, rfc
			INTO iIdPersona, cCaracter, cDescTipoPersona, cApellPaterno, cApellMaterno, cNombre, cRFC
			FROM bdicnweb:"informix".sw_ro_solicitudpartes 
			WHERE id_expediente = pIdExpediente 
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdPersona, TRIM(UPPER(cCaracter)), TRIM(UPPER(cDescTipoPersona)), TRIM(UPPER(cNombre)), TRIM(UPPER(cApellPaterno)), TRIM(UPPER(cApellMaterno)), TRIM(UPPER(cRFC)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdPersona, cCaracter, cDescTipoPersona, cNombre, cApellPaterno, cApellMaterno, cRFC;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que hace la consulta para el llenado del Detalle Solicitud Partes Archivo XML.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_cuentasconocidasarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, 
	pIdSolEspecifica INTEGER, pIdPersona INTEGER)
		RETURNING CHAR(5) AS codret,
            CHAR(50) AS entidad_cc,
			CHAR(20) AS cuenta_cc,
			CHAR(9000) AS instrucciones_cc;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE cEntidad CHAR(50);
	DEFINE cCuenta CHAR(20);
	DEFINE cInstrucciones CHAR(9000);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdPersona = 0;
	LET cEntidad = '';
	LET cCuenta = '';
	LET cInstrucciones = '';
	LET iRecuperacion = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEntidad, cCuenta, cInstrucciones;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_cuentasconocidasarchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pIdSolEspecifica IS NULL OR pIdPersona IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEntidad, cCuenta, cInstrucciones;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEntidad, cCuenta, cInstrucciones;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT entidad, cuenta, intrucciones
		INTO cEntidad, cCuenta, cInstrucciones
		FROM bdicnweb:"informix".sw_ro_cuentasconocidas 
		WHERE id_expediente = pIdExpediente 
		AND id_solicitud_especifica = pIdSolEspecifica
		AND id_persona = pIdPersona;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, TRIM(UPPER(cEntidad)), TRIM(cCuenta), TRIM(cInstrucciones);
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 01/12/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que hace la consulta para obtener el detalle de cuentas conocidas de la Solicitud Especifica Archivo XML.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_extraevalor_tagxml(pIdRow INTEGER, pEtiqueta VARCHAR(50))
                RETURNING CHAR(5) AS cod_ret,
                        LVARCHAR(32739) AS valor_tag;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cValor LVARCHAR(32739);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cValor = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cValor;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_ro_extraevalor_tagxml.out';
                -- TRACE ON;
                
                IF pIdRow IS NULL OR pEtiqueta = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cValor;
                END IF;
                
                SET ISOLATION TO DIRTY READ;

                SELECT REPLACE(REPLACE(TRIM(REPLACE(REPLACE(REPLACE(xmlfile_data, pEtiqueta, ''), '/>', '>'), '<>', '')),chr(13) || chr(10),''),chr(9),'')
                INTO cValor
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE id_registro = pIdRow;

                RETURN cCodRet, cValor;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 24/11/2015',
'MODULO: Oficios',
'FUNCIONALIDAD: Carga de archivos XML',
'DESCRIPCION: Busca una etiqueta dentro de la cadena XML regresa el valor',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_instruccionescuentasxconocerarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS id_solicitud_especifica,
            CHAR (9000) AS instrucciones_cxc;
			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdExpediente INTEGER;
	DEFINE iIdSolicitudEsp INTEGER;
	DEFINE cInstruccionesCxC CHAR (9000);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdExpediente = 0;
	LET iIdSolicitudEsp = 0;
	LET cInstruccionesCxC = '';
	LET iRecuperacion = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdSolicitudEsp, cInstruccionesCxC;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_instruccionescuentasxconocerarchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdSolicitudEsp, cInstruccionesCxC;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdSolicitudEsp, cInstruccionesCxC;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdSolicitudEsp, cInstruccionesCxC;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
			
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion id_solicitud_especifica, instrucciones_cuentas_x_conocer
			INTO iIdSolicitudEsp, cInstruccionesCxC
			FROM bdicnweb:"informix".sw_ro_solicitudespecifica 
			WHERE id_expediente = pIdExpediente
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdSolicitudEsp, TRIM(UPPER(cInstruccionesCxC)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			IF pRecuperacion = 0 THEN
				LET cCodRet = '00017';
			ELIF pRecuperacion > 0 THEN
				LET cCodRet = '1001';
			END IF;
			
			RETURN cCodRet, iIdSolicitudEsp, TRIM(UPPER(cInstruccionesCxC));
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que hace la consulta de las instruciones cuentas por conocer del Detalle Solicitud Especifica Archivo XML.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_procesaencabezadoxml(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
                        CHAR(60) AS num_oficio,
                        INTEGER AS id_oficio;
                
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(5);
        DEFINE iSqlErr INTEGER;
        
        --Declaro Encabezado
        DEFINE iNumIndiceEnc INTEGER;
        DEFINE iTopeEnc INTEGER;
        DEFINE cNumOficio CHAR(60);
        DEFINE cNumExpediente CHAR(60);
        DEFINE cSolSiara CHAR(60);
        DEFINE iNumFolio INTEGER;
        DEFINE cAnioOficio CHAR(4);
        DEFINE cIdArea CHAR(2);
        DEFINE cDescArea CHAR(30);
        DEFINE dFechaPublicacion CHAR(10);
        DEFINE cDiazPlazo CHAR(2);
        DEFINE cNomAutoridad CHAR(60);
        DEFINE cNomAutoridadEsp CHAR(60);
        DEFINE cNomSolicitante CHAR(60);
        DEFINE cReferencia CHAR(60);
        DEFINE cReferencia1 CHAR(60);
        DEFINE cReferencia2 CHAR(60);
        DEFINE cAseguramiento CHAR(5);
        DEFINE iTotalRegistros INTEGER; 
        DEFINE iIdOficio INTEGER;
        
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iSqlErr = 0;
        
        --Inicializo Encabezado
        LET iNumIndiceEnc = 0;
        LET iTopeEnc = 0;
        LET cNumOficio = '';
        LET cNumExpediente = '';
        LET cSolSiara = '';
        LET iNumFolio = 0;
        LET cAnioOficio = '';
        LET cIdArea = '';
        LET cDescArea = '';
        LET dFechaPublicacion = '';
        LET cDiazPlazo = '';
        LET cNomAutoridad = '';
        LET cNomAutoridadEsp = '';
        LET cNomSolicitante = '';
        LET cReferencia = '';
        LET cReferencia1 = '';
        LET cReferencia2 = '';
        LET cAseguramiento = '';
        LET iTotalRegistros = 0;
        LET iIdOficio = 0;
        
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,cNumOficio,iIdOficio;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesaencabezadoxml.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,cNumOficio,iIdOficio;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,cNumOficio,iIdOficio;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                
                -- Numero de oficio
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_NumeroOficio>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_NumeroOficio') INTO cCodRetSp, cNumOficio;
                
                -- Numero de expediente
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_NumeroExpediente>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_NumeroExpediente') INTO cCodRetSp, cNumExpediente;
                
                -- Numero de oslicitud siara
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_SolicitudSiara>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_SolicitudSiara') INTO cCodRetSp, cSolSiara;

                -- Numero de folio
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_Folio>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_Folio') INTO cCodRetSp, iNumFolio;
                
                -- Anio de oficio
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_OficioYear>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_OficioYear') INTO cCodRetSp, cAnioOficio;
                
                -- Clave de area
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_AreaClave>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_AreaClave') INTO cCodRetSp, cIdArea;
                
                -- Descripcion de area
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_AreaDescripcion>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_AreaDescripcion') INTO cCodRetSp, cDescArea;
                
                -- Fecha de publicación
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_FechaPublicacion>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_FechaPublicacion') INTO cCodRetSp, dFechaPublicacion;
                
                -- Dias plazo
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Cnbv_DiasPlazo>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Cnbv_DiasPlazo') INTO cCodRetSp, cDiazPlazo;
                
                -- Nombre de autoridad
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<AutoridadNombre>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'AutoridadNombre') INTO cCodRetSp, cNomAutoridad;
                
                -- Nombre de autoridad especifica
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<AutoridadEspecificaNombre>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'AutoridadEspecificaNombre') INTO cCodRetSp, cNomAutoridadEsp;
                
                -- Nombre Solicitante
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<NombreSolicitante>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'NombreSolicitante') INTO cCodRetSp, cNomSolicitante;
                
                -- Referencia
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Referencia>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Referencia') INTO cCodRetSp, cReferencia;
                
                -- Referencia 1 
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Referencia1>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Referencia1') INTO cCodRetSp, cReferencia1;
                
                -- Referencia 2
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<Referencia2>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'Referencia2') INTO cCodRetSp, cReferencia2;
                
                -- Tiene aseguramiento
                SELECT id_registro
                INTO iNumIndiceEnc
                FROM bdicnweb:"informix".oficios_xml_tmp
                WHERE TRIM(xmlfile_data) LIKE '<TieneAseguramiento>%';
                
                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iNumIndiceEnc, 'TieneAseguramiento') INTO cCodRetSp, cAseguramiento;
                
                -- Guardado de los datos
                INSERT INTO bdicnweb:"informix".sw_ro_encabezadoexparchxml(num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,
                        fecha_publicacion,dias_plazo,nombre_autoridad,nombre_autoridad_especifica,nombre_solicitante,referencia,referencia1,referencia2,
                        aseguramiento,total_registros,usuario_insert,fecha_insert)
                VALUES(NVL(cNumOficio,''),NVL(cNumExpediente,''),NVL(cSolSiara,''),NVL(iNumFolio,''),NVL(cAnioOficio,''),NVL(cIdArea,''),NVL(cDescArea,''),
                        NVL(dFechaPublicacion,''),NVL(cDiazPlazo,''),NVL(cNomAutoridad,''),NVL(cNomAutoridadEsp,''),NVL(cNomSolicitante,''),
                        NVL(cReferencia,''),NVL(cReferencia1,''),NVL(cReferencia2,''),NVL(cAseguramiento,''),NVL(iTotalRegistros,''),NVL(pUsuario,''),CURRENT);
                
                
                SELECT MAX(id_expediente)
                INTO iIdOficio 
                FROM bdicnweb:"informix".sw_ro_encabezadoexparchxml
                WHERE num_oficio = TRIM(cNumOficio);
                
                RETURN cCodRet, TRIM(cNumOficio), iIdOficio;
                
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 11/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA DE ARCHIVOS XML', 
'DESCRIPCION: SPL que se encarga del llenado de las tablas, de acuerdo al contenido del archivo xml procesado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_procesararchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(60) AS num_oficio,
			INTEGER AS id_oficio;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNumOficio CHAR(60);
	DEFINE iIdOficio INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNumOficio = '';
	LET iIdOficio = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumOficio, iIdOficio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesararchivoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		-- 1. Procesar el encabezado del archivo
		EXECUTE PROCEDURE "informix".sp_ro_procesaencabezadoxml(pUsuario, pIdFuncion) INTO cCodRetSp, cNumOficio, iIdOficio;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ''informix''.sp_ro_procesaencabezadoxml';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		-- 2. Procesamiento de las solicitudes partes
		EXECUTE PROCEDURE "informix".sp_ro_procesarsolic_partes(pUsuario, pIdFuncion, iIdOficio) INTO cCodRetSp;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP "informix".sp_ro_procesarsolic_partes';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		-- 3. Procesamiento de las solicitudes especificas
		EXECUTE PROCEDURE "informix".sp_ro_procesarsolic_especifica(pUsuario, pIdFuncion, iIdOficio) INTO cCodRetSp;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP "informix".sp_ro_procesarsolic_especifica';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumOficio, iIdOficio;
		END IF;
		
		DELETE FROM "informix".oficios_xml_tmp;
		
		RETURN cCodRet, cNumOficio, iIdOficio;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 24/11/2015',
'MODULO: Oficios',
'FUNCIONALIDAD: Carga de archivos XML de oficios',
'DESCRIPCION: Procesa un archivo XML cargado en una tabla temporal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_procesarsolic_especifica(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
                RETURNING CHAR(5) AS codret;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE iIdSolicitudEspecifica INTEGER;
        DEFINE iIdRowMinEspecifica INTEGER;
        DEFINE iIdRowMaxEspecifica INTEGER;
        DEFINE iIdRowMin INTEGER;
        DEFINE iIdRowMax INTEGER;
        DEFINE iIdRow INTEGER;
        DEFINE iIdMinRowInstruccionesXConocer INTEGER;
        DEFINE iIdMaxRowInstruccionesXConocer INTEGER;
        DEFINE iPersonaId INTEGER;
        DEFINE cCaracter CHAR(30);
        DEFINE cDescTipoPersona CHAR(10);
        DEFINE cApellidoPaterno CHAR(26);
        DEFINE cApellidoMaterno CHAR(26);
        DEFINE cNombre CHAR(150);
        DEFINE cRfc CHAR(15);
        DEFINE cRelacion CHAR(50);
        DEFINE cDomicilio CHAR(150);
        DEFINE cComplementarios CHAR(50);
        DEFINE cInstruccionesCuentasPorConocer LVARCHAR(2000);
        
        DEFINE cEntidad CHAR(50);
        DEFINE cCuenta CHAR(20);
        DEFINE cInstrucciones LVARCHAR(2500);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET iIdSolicitudEspecifica = 0;
        LET iIdRowMinEspecifica = 0;
        LET iIdRowMaxEspecifica = 0;
        LET iIdRowMin = 0;
        LET iIdRowMax = 0;
        LET iIdRow = 0;
        LET iIdMinRowInstruccionesXConocer = 0;
        LET iIdMaxRowInstruccionesXConocer = 0;
        
        LET cInstruccionesCuentasPorConocer = '';
        LET iPersonaId = 0;
        LET cCaracter = '';
        LET cDescTipoPersona = '';
        LET cApellidoPaterno = '';
        LET cApellidoMaterno = '';
        LET cNombre = '';
        LET cRfc = '';
        LET cRelacion = '';
        LET cDomicilio = '';
        LET cComplementarios = '';
        
        LET cEntidad = '';
        LET cCuenta = '';
        LET cInstrucciones = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesarsolic_especifica.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                
                FOREACH SELECT id_registro
                        INTO iIdRowMinEspecifica
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<SolicitudEspecifica>%'
                        
                        SELECT first 1 id_registro
                        INTO iIdRowMaxEspecifica
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '</SolicitudEspecifica>%'
                        AND id_registro > iIdRowMin;
                                
                        -- Id. solicitud
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<SolicitudEspecificaId>%'
                        AND id_registro > iIdRowMinEspecifica AND id_registro < iIdRowMaxEspecifica;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'SolicitudEspecificaId') INTO cCodRetSp, iIdSolicitudEspecifica;
                        
                        -- Instrucciones cuentas por conocer
                        SELECT id_registro
                        INTO iIdMinRowInstruccionesXConocer
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<InstruccionesCuentasPorConocer>%'
                        AND id_registro > iIdRowMinEspecifica AND id_registro < iIdRowMaxEspecifica;
                                
                        SELECT FIRST 1 id_registro
                        INTO iIdMaxRowInstruccionesXConocer
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '%</InstruccionesCuentasPorConocer>%'
                        AND id_registro >= iIdMinRowInstruccionesXConocer;
                                
                        
                        FOREACH SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE id_registro BETWEEN iIdMinRowInstruccionesXConocer AND iIdMaxRowInstruccionesXConocer
                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'InstruccionesCuentasPorConocer') INTO cCodRetSp, cInstruccionesCuentasPorConocer;
                                
                                INSERT INTO bdicnweb:"informix".sw_ro_solicitudespecifica(id_expediente, id_solicitud_especifica, instrucciones_cuentas_x_conocer)
                                VALUES (pIdExpediente, iIdSolicitudEspecifica, TRIM(cInstruccionesCuentasPorConocer));
                        
                        END FOREACH;
                        
                        -- Esta parte de abajo ya funciona
                        FOREACH SELECT id_registro
                                INTO iIdRowMin
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<PersonasSolicitud>%'
                                AND id_registro > iIdRowMinEspecifica AND id_registro < iIdRowMaxEspecifica
                                
                                SELECT first 1 id_registro
                                INTO iIdRowMax
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '</PersonasSolicitud>%'
                                AND id_registro > iIdRowMin;
                                        
                                --      Id. Persona
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<PersonaId>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'PersonaId') INTO cCodRetSp, iPersonaId;
                                
                                --      Caracter
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Caracter>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Caracter') INTO cCodRetSp, cCaracter;
                                
                                --      Persona
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Persona>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Persona') INTO cCodRetSp, cDescTipoPersona;
                                
                                --      Paterno
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Paterno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Paterno') INTO cCodRetSp, cApellidoPaterno;
                                
                                --      Materno
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Materno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Materno') INTO cCodRetSp, cApellidoMaterno;
                                
                                --      Nombre
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Nombre>%'
								AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Nombre') INTO cCodRetSp, cNombre;
                                
                                --      RFC
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Rfc>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Rfc') INTO cCodRetSp, cRfc;
                                
                                --      Relacion
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Relacion>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Relacion') INTO cCodRetSp, cRelacion;
                                
                                --      Domicilio
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Domicilio>%'
								AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Domicilio') INTO cCodRetSp, cDomicilio;
                                
                                --      Complementarios
                                SELECT id_registro
                                INTO iIdRow
                                FROM bdicnweb:"informix".oficios_xml_tmp
                                WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Complementarios>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                        
                                EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Complementarios') INTO cCodRetSp, cComplementarios;
                                
                                -- INSERCIÃN EN TABLA
                                INSERT INTO bdicnweb:"informix".sw_ro_personassolicitud(id_expediente, id_solicitud_especifica, id_persona, caracter, des_tipo_persona, 
                                        ap_paterno, ap_materno, nombre, rfc, relacion, domicilio, complementarios)
                                VALUES (pIdExpediente, iIdSolicitudEspecifica, iPersonaId, cCaracter, cDescTipoPersona, cApellidoPaterno, cApellidoMaterno, cNombre, cRfc, 
                                                cRelacion, cDomicilio, cComplementarios);
                                
                                -- CUENTAS CONOCIDAS
                                FOREACH SELECT id_registro
                                        INTO iIdRowMin
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<CuentasConocidas>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax
                                        
                                        SELECT first 1 id_registro
                                        INTO iIdRowMax
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '</CuentasConocidas>%'
                                        AND id_registro > iIdRowMin;
                                
                                        --      Entidad
                                        SELECT id_registro
                                        INTO iIdRow
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Entidad>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                                
                                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Entidad') INTO cCodRetSp, cEntidad;
                                        
                                        --      Cuenta
                                        SELECT id_registro
                                        INTO iIdRow
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Cuenta>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                                
                                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Cuenta') INTO cCodRetSp, cCuenta;
                                        
                                        --Instrucciones
                                        SELECT id_registro
                                        INTO iIdRow
                                        FROM bdicnweb:"informix".oficios_xml_tmp
                                        WHERE REPLACE(REPLACE(TRIM(xmlfile_data),chr(13) || chr(10),''),chr(9),'') LIKE '<Instrucciones>%'
                                        AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                                
                                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Instrucciones') INTO cCodRetSp, cInstrucciones;
                                        
                                        -- INSERCIÃN EN TABLA
                                        INSERT INTO bdicnweb:"informix".sw_ro_cuentasconocidas(id_expediente, id_solicitud_especifica, id_persona, entidad, cuenta, intrucciones)
                                        VALUES (pIdExpediente, iIdSolicitudEspecifica, iPersonaId, cEntidad, cCuenta, cInstrucciones);
                                
                                END FOREACH;
                                
                        END FOREACH;
                END FOREACH;
                
                RETURN cCodRet;
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 24/11/2015',
'MODULO: Oficios',
'FUNCIONALIDAD: Carga de archivos XML de oficios',
'DESCRIPCION: Prodcesa la parte de solicitudes especificas del archivo xml cargado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ro_procesarsolic_partes(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdExpediente INTEGER)
                RETURNING CHAR(5) AS codret;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE iIdSolicitudEspecifica INTEGER;
        DEFINE iIdRowMin INTEGER;
        DEFINE iIdRowMax INTEGER;
        DEFINE iIdRow INTEGER;
        DEFINE iParteId INTEGER;
        DEFINE cCaracter CHAR(30);
        DEFINE cDescTipoPersona CHAR(10);
        DEFINE cApellidoPaterno CHAR(26);
        DEFINE cApellidoMaterno CHAR(26);
        DEFINE cNombre CHAR(150);
        DEFINE cRfc CHAR(15);
        DEFINE cRelacion CHAR(50);
        DEFINE cDomicilio CHAR(150);
        DEFINE cComplementarios CHAR(50);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET iIdSolicitudEspecifica = 0;
        LET iIdRowMin = 0;
        LET iIdRowMax = 0;
        LET iIdRow = 0;
        
        
        LET iParteId = 0;
        LET cCaracter = '';
        LET cDescTipoPersona = '';
        LET cApellidoPaterno = '';
        LET cApellidoMaterno = '';
        LET cNombre = '';
        LET cRfc = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ro_procesarsolic_partes.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pIdExpediente IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                FOREACH SELECT id_registro
                        INTO iIdRowMin
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<SolicitudPartes>%'
                        
                        SELECT first 1 id_registro
                        INTO iIdRowMax
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '</SolicitudPartes>%'
                                AND id_registro > iIdRowMin;
                        
                        --      Id. Parte
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<ParteId>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'ParteId') INTO cCodRetSp, iParteId;
                        
                        --      Caracter
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Caracter>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Caracter') INTO cCodRetSp, cCaracter;
                        
                        --      Persona
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Persona>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Persona') INTO cCodRetSp, cDescTipoPersona;
                        
                        --      Paterno
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Paterno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Paterno') INTO cCodRetSp, cApellidoPaterno;
                        
                        --      Materno
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Materno>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Materno') INTO cCodRetSp, cApellidoMaterno;
                        
                        --      Nombre
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Nombre>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Nombre') INTO cCodRetSp, cNombre;
                        
                        --      RFC
                        SELECT id_registro
                        INTO iIdRow
                        FROM bdicnweb:"informix".oficios_xml_tmp
                        WHERE TRIM(xmlfile_data) LIKE '<Rfc>%'
                                AND id_registro > iIdRowMin AND id_registro < iIdRowMax;
                                
                        EXECUTE PROCEDURE "informix".sp_ro_extraevalor_tagxml(iIdRow, 'Rfc') INTO cCodRetSp, cRfc;
                        
                        -- INSERCIÓN EN TABLA
                        INSERT INTO bdicnweb:"informix".sw_ro_solicitudpartes(id_expediente, id_persona, caracter, des_tipo_persona, ap_paterno, ap_materno, nombre, rfc)
                        VALUES (pIdExpediente, iParteId, cCaracter, cDescTipoPersona, cApellidoPaterno, cApellidoMaterno, cNombre, cRfc);
                        
                END FOREACH;
                
                RETURN cCodRet;
        END;
        
END PROCEDURE;