CREATE PROCEDURE "informix".sp_actualizasufijospm(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdOperacion CHAR(1), 
		pCodSufijo CHAR(2), pDescSufijo CHAR(60), pStatus CHAR(1))
					
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;	
		DEFINE codSufijo CHAR(2);
		DEFINE descSufijo CHAR(60);
		DEFINE iRecuperacion INTEGER;
		DEFINE iRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET iSqlErr = 0;	
		LET codSufijo = '';
		LET descSufijo = '';
		LET iRecuperacion = 0;
		LET iRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_actualizasufijospm.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pIdOperacion = '' OR pCodSufijo = '' OR pDescSufijo = '' OR pStatus = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			-- VALIDA OPERACION
			IF pIdOperacion = 1 THEN

				-- VALIDAMOS QUE NO EXISTA LA CLAVE YA
				IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_sufijos WHERE codigo::INTEGER = pCodSufijo::INTEGER) THEN
					-- VALIDA QUE NO EXISTE UN SIFIJO PARECIDO
					IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_sufijos WHERE LOWER(REPLACE(REPLACE(REPLACE(descripcion, ' ', ''), ',', ''), '.', '')) = LOWER(REPLACE(REPLACE(REPLACE(pDescSufijo, ' ', ''), ',', ''), '.', ''))) THEN
						INSERT INTO bdinteg:"informix".si_sufijos(empresa, codigo, descripcion, usuario_alta, fecha_alta, usuario_modifica, fecha_modifica, status)
						VALUES ('001', pCodSufijo, pDescSufijo, pUsuario, DATE(CURRENT), '', '', pStatus);					
						
						LET iRegistros = DBINFO('sqlca.sqlerrd2');
						IF iRegistros = 0 THEN
							LET cCodRet = '00282';
						END IF;
							
					ELSE
						LET cCodRet = '00004';
					END IF;
				ELSE
					LET cCodRet = '00519'; --EL CÃDIGO NO PERTENECE AL SIGUIENTE CONSECUTIVO DISPONIBLE
				END IF;
			
			ELIF pIdOperacion = 2 THEN
				IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_sufijos WHERE codigo::INTEGER = pCodSufijo::INTEGER) THEN
				
					UPDATE bdinteg:"informix".si_sufijos
					SET usuario_modifica = pUsuario,
						fecha_modifica = DATE(CURRENT),
						status = pStatus
					WHERE codigo = pCodSufijo;
					
					LET iRegistros = DBINFO('sqlca.sqlerrd2');
					IF iRegistros = 0 THEN
						LET cCodRet = '00001';
						RETURN cCodRet;	
					END IF;
					
					-- SI EL NOMBRE ES EL MIMSMO NO SE HACE ACTUALIZACION
					IF (SELECT LOWER(TRIM(descripcion)) FROM bdinteg:"informix".si_sufijos WHERE codigo::INTEGER = pCodSufijo::INTEGER) <> LOWER(TRIM(pDescSufijo)) THEN
						IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_sufijos WHERE LOWER(REPLACE(REPLACE(REPLACE(descripcion, ' ', ''), ',', ''), '.', '')) = LOWER(REPLACE(REPLACE(REPLACE(pDescSufijo, ' ', ''), ',', ''), '.', ''))) THEN
							UPDATE bdinteg:"informix".si_sufijos
							SET usuario_modifica = pUsuario,
								descripcion = pDescSufijo,
								fecha_modifica = DATE(CURRENT)
							WHERE codigo = pCodSufijo;
						ELSE
							LET cCodRet = '00520';
						END IF;
					END IF;
				END IF;

			END IF;
		
			RETURN cCodRet;			
		
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 07/05/2015',
'DESCRIPCION: SPL que hace la actualizacion a la tabla bdinteg:si_sufijos del catalogo sufijos persona moral;',
'donde pIdOperacion = 1 se refiere a un insert y pIdOperacion = 2 hace un update.',
'FUNCIONALIDAD: Mantenimiento CatÃ¡logo Sufijos', 
'MODULO: Clientes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_busquedabancos(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveBanco INTEGER, pNombreCorto CHAR(20), pNombreBanco CHAR(40), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				INTEGER AS clave_banco, 
				CHAR(20) AS nombre_corto_banco,
				CHAR(60) AS nombre_banco;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCveBanco INTEGER;
	DEFINE cNombreCorto CHAR(20);
	DEFINE cNombreLargo CHAR(40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCveBanco = 0;
	LET cNombreCorto = '';
	LET cNombreLargo = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCveBanco, cNombreCorto, cNombreLargo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_busquedabancos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR (pClaveBanco IS NULL AND pNombreCorto = '' AND pNombreBanco = '') OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCveBanco, cNombreCorto, cNombreLargo;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iCveBanco, cNombreCorto, cNombreLargo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumSolicitud, '06', '1') INTO cCodRet;
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iCveBanco, cNombreCorto, cNombreLargo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion cvecesif, UPPER(vchrnombrecorto), UPPER(descripcion)
				INTO iCveBanco, cNombreCorto, cNombreLargo
				FROM bdinteg:'informix'.si_bancos
				WHERE cvecesif IS NOT NULL AND cvecesif !=0
					AND cvecesif||'' LIKE CASE WHEN pClaveBanco IS NULL THEN TRIM(cvecesif||'') ELSE '%'||TRIM(pClaveBanco||'')||'%' END
					AND vchrnombrecorto LIKE CASE WHEN pNombreCorto = '' THEN vchrnombrecorto ELSE '%'||TRIM(pNombreCorto)||'%' END
					AND descripcion LIKE CASE WHEN pNombreBanco = '' THEN descripcion ELSE '%'||TRIM(pNombreBanco)||'%' END
				ORDER BY vchrnombrecorto
			
			RETURN cCodRet, iCveBanco, cNombreCorto, cNombreLargo WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iCveBanco, cNombreCorto, cNombreLargo;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iCveBanco, cNombreCorto, cNombreLargo;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 09/06/2015',
'MODULO: Catalogos',
'FUNCIONALIDAD: Busqueda de bancos',
'DESCRIPCION: Consulta los bancos que coinciden con los criterios de entrada',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadatosbanco(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveBanco INTEGER)
		RETURNING CHAR(5) AS codret,
				INTEGER AS clave_banco,
				CHAR(60) AS nombre_banco,
				CHAR(20) AS nombre_corto_banco,
				DATE AS fecha_operacion,
				CHAR(1) AS ind_spei,
				CHAR(1) AS ind_cheques,
				CHAR(1) AS ind_nomina,
				CHAR(1) AS ind_tef_receptor,
				CHAR(1) AS ind_tef_presentador,
				CHAR(1) AS ind_domi_receptor,
				CHAR(1) AS ind_domi_presentador;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iClaveBanco INTEGER;
	DEFINE cNombreLargo CHAR(40);
	DEFINE cNombreCorto CHAR(20);
	DEFINE dFecha DATE;
	DEFINE iIndSpei CHAR(1);
	DEFINE iIndCheques CHAR(1);
	DEFINE iIndNomina CHAR(1);
	DEFINE iIndTefR CHAR(1);
	DEFINE iIndTefP CHAR(1);
	DEFINE iIndDomiR CHAR(1);
	DEFINE iIndDomiP CHAR(1);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iClaveBanco = 0;
	LET cNombreLargo = '';
	LET cNombreCorto = '';
	LET dFecha = NULL;
	LET iIndSpei = '';
	LET iIndCheques = '';
	LET iIndNomina = '';
	LET iIndTefR = '';
	LET iIndTefP = '';
	LET iIndDomiR = '';
	LET iIndDomiP = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iClaveBanco, cNombreLargo, cNombreCorto, dFecha, iIndSpei, iIndCheques, iIndNomina, iIndTefR, iIndTefP, iIndDomiR, iIndDomiP;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadatosbanco.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pClaveBanco IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iClaveBanco, cNombreLargo, cNombreCorto, dFecha, iIndSpei, iIndCheques, iIndNomina, iIndTefR, iIndTefP, iIndDomiR, iIndDomiP;
		END IF;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iClaveBanco, cNombreLargo, cNombreCorto, dFecha, iIndSpei, iIndCheques, iIndNomina, iIndTefR, iIndTefP, iIndDomiR, iIndDomiP;
		END IF;

		EXECUTE PROCEDURE bdinteg:'informix'.sp_consultabanco(pClaveBanco)
		INTO cCodRetSp, iClaveBanco, cNombreLargo, cNombreCorto, dFecha, iIndSpei, iIndCheques, iIndNomina, iIndTefR, iIndTefP, iIndDomiR, iIndDomiP;

		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00518'; -- LA CLAVE DEL BANCO NO EXISTE
		ELSE
			IF cNombreLargo IS NULL AND cNombreCorto IS NULL AND dFecha IS NULL THEN
				LET cCodRet = '00017';
			END IF;
		END IF;

		RETURN cCodRet, iClaveBanco, cNombreLargo, cNombreCorto, dFecha, iIndSpei, iIndCheques, iIndNomina, iIndTefR, iIndTefP, iIndDomiR, iIndDomiP;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 09/06/2015',
'MODULO: Catalogo',
'FUNCIONALIDAD: Actualizacion de datos del banco',
'DESCRIPCION: Consulta los datos e indicadores de un banco por medio de la clave',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultalistabancos(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoConsulta SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(5) AS clave_banco,
				CHAR(20) AS nombre_banco;


	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cClaveBanco CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cNombreBanco CHAR(20);
	DEFINE iSpSkip INTEGER;
	DEFINE iSpSkipInc SMALLINT;
	DEFINE bConsultaTerminada BOOLEAN;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClaveBanco = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cNombreBanco = '';
	LET iSpSkip = 0;
	LET iSpSkipInc = 10;
	LET bConsultaTerminada = 'f';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClaveBanco, cNombreBanco;
		END EXCEPTION;

		ON EXCEPTION IN (-958)
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultalistabancos.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipoConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClaveBanco, cNombreBanco;
		END IF;

		IF pTipoConsulta NOT IN (1, 2, 3) THEN
			LET cCodRet = '00440';
			RETURN cCodRet, cClaveBanco, cNombreBanco;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cClaveBanco, cNombreBanco;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClaveBanco, cNombreBanco;
		END IF;

		-- CREACIÓN DE TABLA TEMPORAL
		--CREATE TEMP TABLE IF NOT EXISTS cat_bancos_tmp(usuario CHAR(20), clave_banco CHAR(5), nombre_banco CHAR(20)) WITH NO LOG;
		CREATE TEMP TABLE cat_bancos_tmp(usuario CHAR(20), clave_banco CHAR(5), nombre_banco CHAR(20)) WITH NO LOG;
		DELETE FROM cat_bancos_tmp WHERE usuario = pUsuario;

		SET LOCK MODE TO WAIT 3;

		WHILE NOT bConsultaTerminada

			FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_listaltabancos(iSpSkip, pTipoConsulta)
			INTO cClaveBanco, cNombreBanco

				LET iCodRetSp = cClaveBanco::INTEGER;
				IF iCodRetSp < 0 THEN
					LET cClaveBanco = '';
					RAISE EXCEPTION iCodRetSp, 0, 'bdinteg:"informix".sp_listaltabancos';
				END IF;

				INSERT INTO cat_bancos_tmp(usuario, clave_banco, nombre_banco) VALUES (pUsuario, cClaveBanco, cNombreBanco);
				IF DBINFO('sqlca.sqlerrd2') = 1 THEN
					LET iNoRegistros = iNoRegistros + 1;
				END IF;

			END FOREACH;

			IF iNoRegistros = 0 THEN
				LET bConsultaTerminada = 't';
			ELSE
				LET iSpSkip = iSpSkip + iSpSkipInc;
				LET iNoRegistros = 0;
			END IF;

		END WHILE;

		SET ISOLATION TO DIRTY READ;
		LET iNoRegistros = 0;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion clave_banco, nombre_banco
				INTO cClaveBanco, cNombreBanco
				FROM cat_bancos_tmp
				WHERE usuario = pUsuario
				ORDER BY nombre_banco

			RETURN 	cCodRet, cClaveBanco, cNombreBanco WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;

		END FOREACH;

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cClaveBanco, cNombreBanco;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClaveBanco, cNombreBanco;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 04/06/2015',
'MODULO: CATALOGOS',
'FUNCIONALIDAD: Administracion de Bancos; Alta/modificacion de bancos',
'DESCRIPCION: Consulta el catalogo de bancos',
'pTipoConsulta = 1 - TODOS, 2 - SOLO ACTUALIZADOS, 3 - BAJAS SPEI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mantenimientobancos(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion SMALLINT, pFechaOperacion DATE, pClaveBanco INTEGER, pNombreBanco CHAR(60), pNombreBancoCorto CHAR(20), pSPEI CHAR(1), pCheques CHAR(1), pNomina CHAR(1), pTefRecibe CHAR(1), pTefPresentador CHAR(1), pDomiRecibe CHAR(1), pDomiPresentador CHAR(1))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mantenimientobancos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pClaveBanco IS NULL OR pFechaOperacion = '' OR pNombreBanco = '' OR pNombreBancoCorto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN -- TIPO DE OPERACION INVALIDA
			LET cCodRet = '00440';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- VALIDAMOS QUE LA CLAVE DEL BANCO NO EXISTA
		--IF EXISTS (SELECT 1 FROM bdinteg:'informix'.si_bancos WHERE SUBSTR(cvecesif, 3, 3) = SUBSTR(pClaveBanco, 3, 3)) AND pTipoOperacion = 1 THEN
		--	LET cCodRet = '00516';
		--	RETURN cCodRet;
		--END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_adminbancos(pClaveBanco, pNombreBanco, pNombreBancoCorto, pFechaOperacion, pTipoOperacion, pUsuario, pSPEI, pCheques, pNomina, pTefRecibe, pTefPresentador, pDomiRecibe, pDomiPresentador)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_adminbancos';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00516'; -- LA CLAVE DEL BANCO YA EXISTE
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 04/06/2015',
'MODULO: CATALOGOS',
'FUNCIONALIDAD: Administracion de Bancos; Alta/modificacion de bancos',
'DESCRIPCION: Da de alta o actualiza un banco en el catalogo',
'pTipoOperacion = 1 - ALTA, 2 - MODIFICACION',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_carga_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10), pArchivo CHAR(150))
	RETURNING CHAR(5) AS codret,
			INT AS lote;

	DEFINE cFechaCarga DATETIME YEAR TO FRACTION(3);
	DEFINE pArchivoTemp CHAR(150);
	DEFINE cCmd1 CHAR(500);
	DEFINE cCmd2 CHAR(500);
	DEFINE cCmd3 CHAR(500);
	DEFINE cCmd4 CHAR(500);
	DEFINE cCodRet CHAR(5);
	DEFINE iLote INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cCampos CHAR(1024);
	DEFINE cTablaDst CHAR(150);
	DEFINE cBaseDatos CHAR(50);
	DEFINE iSqlErr INT;
	DEFINE cUsrBin CHAR(15);

	LET pArchivoTemp = '';
	LET cCmd1 = '';
	LET cCodRet = '00000';
	LET iLote = 0;
	LET cCampos = '';
	LET cTablaDst = '';
	LET iSqlErr = 0;
	LET cUsrBin = '/usr/bin/';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iLote;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/CHVN/sp_carga_masiva.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iLote;
		END IF;

		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iLote;
		END IF;

		SELECT FIRST 1 CURRENT
		INTO cFechaCarga
		FROM systables;

		EXECUTE PROCEDURE bdicnweb:"informix".sp_obtienesiguientelote(pUsuario, pIdFuncion) INTO cCodRetSp, iLote;
		IF cCodRetSp <> '00000' THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, iLote;
		END IF;
		LET pArchivoTemp = TRIM(pArchivo)||".tmp";

		LET cCmd1 = TRIM(cUsrBin)||"awk '{ sub(";
		LET cCmd2 = '"\r$", ""); print }';
		LET cCmd3 = "' "||TRIM(pArchivo)||" > "||TRIM(pArchivoTemp);
		SYSTEM TRIM(cCmd1)||TRIM(cCmd2)||TRIM(cCmd3);

		LET cCmd3 = TRIM(cUsrBin)||"rm -rf "||TRIM(pArchivo);
		SYSTEM TRIM(cCmd3);

		LET cCmd3 = TRIM(cUsrBin)||"mv "||TRIM(pArchivoTemp)||" "||TRIM(pArchivo);
		SYSTEM TRIM(cCmd3);

		LET cCmd1 = TRIM(cUsrBin)||"cat "||TRIM(pArchivo)||" | "||TRIM(cUsrBin)||"awk '{print";
		LET cCmd2 = TRIM(pIdFuncion)||'|'||cFechaCarga||'|'||iLote||'|'||TRIM(pArchivo)||'|'||TRIM(pUsuario)||'|"';
		LET cCmd3 = TRIM(cCmd1)||' "'||TRIM(cCmd2)||'$0}';
		LET cCmd4 = TRIM(cCmd3)||"' > "||TRIM(pArchivoTemp);

		-- Ejecucucion del comando Shell para el llenado del archivo de carga
		SYSTEM TRIM(cCmd4);

		SELECT base_datos, tabla, campos
		INTO cBaseDatos, cTablaDst, cCampos
		FROM bdicnweb:"informix".sw_tr_info_tablas
		WHERE id_funcion = pIdFuncion;

		LET cCmd1 = TRIM(cUsrBin)||"echo 'LOAD FROM "||TRIM(pArchivoTemp)||" INSERT INTO "||TRIM(cBaseDatos)||":"||TRIM(cTablaDst)||"(";
		LET cCmd2 = TRIM(cCmd1)||TRIM(cCampos)||")' | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1";

		SYSTEM TRIM(cCmd2);

		LET cCmd1 = TRIM(cUsrBin)||"rm -rf "||TRIM(pArchivoTemp);
		SYSTEM TRIM(cCmd1);

		RETURN cCodRet, iLote;
	END;

END PROCEDURE
DOCUMENT "Autor: M.C. Oscar Flores Conde",
"Fecha de creacion: 04/06/2013",
"Descripcion: Carga de archivos por medio de un LOAD pasando como argumento el archivo a cargar, los campos son dinamicos y se encuentran en la tabla sw_tr_info_tablas";

CREATE PROCEDURE "informix".sp_consultareportesdofisicosregcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), 
		pIdProvCaja CHAR(4), pFechaConsulta DATE, pRecuperacion INTEGER, pRegistros INTEGER)
					
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS id_proveedor,
			CHAR(40) AS desc_proveedor, 
			CHAR(4) AS id_sucursal, 
			CHAR(40) AS desc_sucursal, 
			MONEY(14,2) AS saldo_total_suc, 
			MONEY(14,2) AS saldo_total_caja,
			MONEY(14,2) AS saldo_total,
			DATE AS fecha;
		
			
		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;
		DEFINE cMensajeRet CHAR(255);
		DEFINE cEmpresa CHAR(3);
		DEFINE pTipoSucursal CHAR(1);
		DEFINE cIdProveedor CHAR(4);
		DEFINE cDescProveedor CHAR(40);
		DEFINE cIdSucursal CHAR(4);
		DEFINE cDescSucursal CHAR(40);
		DEFINE mSaldoTotalSuc MONEY(14,2);
		DEFINE mSaldoTotalCaja MONEY(14,2);
		DEFINE mSaldoTotalSucursal MONEY(14,2);
		DEFINE mSaldoTotal MONEY(14,2);
		DEFINE dFecha DATE;
		DEFINE iProcExitoso INTEGER;
		DEFINE iRecuperacion INTEGER;
		DEFINE vTransaccion INTEGER;
		
		LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;	
		LET cMensajeRet = '';
		LET cEmpresa = '001';
		LET pTipoSucursal = 'S';
		LET cIdProveedor = '';
		LET cDescProveedor = '';
		LET cIdSucursal = '';
		LET cDescSucursal = '';
		LET mSaldoTotalSuc = 0.00;
		LET mSaldoTotalCaja = 0.00;
		LET mSaldoTotalSucursal = 0.00;
		LET mSaldoTotal = 0.00;
		LET dFecha = '';
		LET iProcExitoso = 0;
		LET iRecuperacion = 0;
		LET vTransaccion = 0;
		
		BEGIN		
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cIdProveedor, cDescProveedor, cIdSucursal, cDescSucursal, mSaldoTotalSuc, mSaldoTotalCaja, mSaldoTotal, dFecha;
			END EXCEPTION;
			
			ON EXCEPTION IN (-535)
				COMMIT;
				LET vTransaccion = 1;
			END EXCEPTION WITH RESUME;
			
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultareportesdofisicosregcaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pIdProvCaja = '' OR pFechaConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cIdProveedor, cDescProveedor, cIdSucursal, cDescSucursal, mSaldoTotalSuc, mSaldoTotalCaja, mSaldoTotal, dFecha;
            END IF;
			
			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cIdProveedor, cDescProveedor, cIdSucursal, cDescSucursal, mSaldoTotalSuc, mSaldoTotalCaja, mSaldoTotal, dFecha;
			END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cIdProveedor, cDescProveedor, cIdSucursal, cDescSucursal, mSaldoTotalSuc, mSaldoTotalCaja, mSaldoTotal, dFecha;
			END IF;
			
			BEGIN WORK;
			IF vTransaccion = 0 THEN
				COMMIT;
			END IF;
			
			IF pRecuperacion = 0 THEN
				SET LOCK MODE TO WAIT;
			
				EXECUTE PROCEDURE bdisuc:'informix'.sp_saldos_suc_cont(cEmpresa, pFechaConsulta, pTipoSucursal) 
				INTO cCodRetSp, cMensajeRet;
				
				LET iProcExitoso = cCodRetSp::INTEGER;
				IF iProcExitoso < 0 THEN
					IF vTransaccion = 1 THEN
						BEGIN WORK;
					END IF;
				
					RAISE EXCEPTION iProcExitoso, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:"informix".sp_saldos_suc_cont';
				ELIF iProcExitoso = 1 THEN
					IF vTransaccion = 1 THEN
						BEGIN WORK;
					END IF;
					
					LET cCodRet = '00472';
					RETURN cCodRet, cIdProveedor, cDescProveedor, cIdSucursal, cDescSucursal, mSaldoTotalSuc, mSaldoTotalCaja, mSaldoTotal, dFecha;
				END IF;
			
			END IF;
			
			SELECT saldo_total INTO mSaldoTotalCaja FROM bdisuc:ss_cajageneral WHERE cod_proveedor = pIdProvCaja;
			LET mSaldoTotal =  mSaldoTotalCaja;
			
			SET ISOLATION TO DIRTY READ;
			FOREACH SELECT SKIP pRecuperacion FIRST pRegistros cod_proveedor, descprovedor, sucursal, descsucursal, saldosuc, fecha_concil
					INTO  cIdProveedor, cDescProveedor, cIdSucursal, cDescSucursal, mSaldoTotalSuc, dFecha		
					FROM bdisuc:ss_concilsdocont WHERE cod_proveedor = pIdProvCaja AND fecha_concil = pFechaConsulta
				
				LET mSaldoTotal = mSaldoTotal + mSaldoTotalSuc;
				
				RETURN cCodRet, NVL(cIdProveedor,''), NVL(UPPER(cDescProveedor),''), NVL(cIdSucursal,''), NVL(UPPER(cDescSucursal),''), 
						NVL(mSaldoTotalSuc,0), NVL(mSaldoTotalCaja,0), NVL(mSaldoTotal,0), NVL(dFecha,'') WITH RESUME;
				
				LET iRecuperacion = iRecuperacion + 1;
				
			END FOREACH;
			
			IF vTransaccion = 1 THEN	
				BEGIN WORK; 
			END IF;
			
			IF iRecuperacion = 0 AND pRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cIdProveedor, cDescProveedor, cIdSucursal, cDescSucursal, mSaldoTotalSuc, mSaldoTotalCaja, mSaldoTotal, dFecha;
			ELIF iRecuperacion = 0 AND pRecuperacion > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cIdProveedor, cDescProveedor, cIdSucursal, cDescSucursal, mSaldoTotalSuc, mSaldoTotalCaja, mSaldoTotal, dFecha;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/06/2015',
'DESCRIPCION: SPL que realiza la consulta para la generaciÃ³n de los reportes.',
'FUNCIONALIDAD: Saldos FÃ­sicos Regionales Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bloqueoctacre_masivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INTEGER, pIdPlantilla CHAR(25), pTituloPlantilla CHAR(255))
        RETURNING CHAR(5) AS codret,
                        INTEGER AS registros_procesados;
                        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE cMensajeRetorno CHAR(80);
        DEFINE iNoRegistros INTEGER;
        DEFINE iExiste INTEGER;
        DEFINE iRegistrosExitosos INTEGER;
        DEFINE iRegistrosFallidos INTEGER;
        DEFINE iCodRet INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE cCuenta CHAR(20);
        DEFINE iTipoBloqueo INTEGER;
        DEFINE cCausaBloqueo CHAR(2);
        DEFINE cResultado CHAR(15);
        DEFINE cStatus CHAR(1);
        DEFINE cMotivoRechazo CHAR(80);
        DEFINE mSaldoCuenta MONEY(14,2);
        DEFINE cCodRetSpSal CHAR(5);
        DEFINE dFechaProceso DATETIME YEAR TO FRACTION(3);
        DEFINE iIdRegistro INTEGER;
        DEFINE cFechaCargaLote DATE;
        DEFINE iTotalRegsLote INTEGER;
        DEFINE mMontoLote MONEY(14, 2);
        DEFINE iRegsAceptadosLote INTEGER;
        DEFINE iRegsRechazoLote INTEGER;
        DEFINE cArchivo CHAR(150);
        DEFINE cStatusLote CHAR(1);
        DEFINE dHoy DATETIME YEAR TO FRACTION(3);
		
		DEFINE cAreaSolicita CHAR(150);
		DEFINE cJustificacion CHAR(150);
		DEFINE dSaldoCapital DECIMAL(18,2);
        
        LET cCodRet = '';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cMensajeRetorno = '';
        LET iNoRegistros = 0;
        LET iExiste = 0;
        LET iRegistrosExitosos = 0;
        LET iRegistrosFallidos = 0;
        LET iCodRet = 0;
        LET cEmpresa = '001';
        LET cCuenta = '';
        LET iTipoBloqueo = 0;
        LET cCausaBloqueo = '';
        LET cResultado = '';
        LET cStatus = '';
        LET cMotivoRechazo = '';
        LET mSaldoCuenta = NULL;
        LET cCodRetSpSal = '';
        LET dFechaProceso = NULL;
        LET iIdRegistro = 0;
        LET cFechaCargaLote = NULL;
        LET iTotalRegsLote = 0;
        LET mMontoLote = NULL;
        LET iRegsAceptadosLote = 0;
        LET iRegsRechazoLote = 0;
        LET cArchivo = '';
        LET cStatusLote = '';
        LET dHoy = NULL;
		
		LET cAreaSolicita = '';
		LET cJustificacion = '';
		LET dSaldoCapital = NULL;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iNoRegistros;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_bloqueoctacre_masivo.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iNoRegistros;
                END IF;
                
                -- VALIDACIION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iNoRegistros;
                END IF;
                
                -- BUSQUEDA DEL LOTE            
                SET ISOLATION TO DIRTY READ;
                SELECT COUNT(id_registro)
                INTO iExiste
                FROM 
                        (SELECT id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre
                        WHERE lote = pLote
                        UNION
                        SELECT id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre_hist
                        WHERE lote = pLote);
                        
                IF iExiste = 0 THEN
                        LET cCodRet = '00200';
                        RETURN cCodRet, iNoRegistros;
                END IF;
                        
                -- ACTUALIZACIÃN DEL ESTATUS DEL LOTE
                UPDATE bdicnweb:'informix'.sw_tr_totales_masivo
                SET status_lote = 'P'
                WHERE id_lote = pLote AND id_funcion = pIdFuncion AND usuario = pIdFuncion;
                
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                FOREACH SELECT id_registro, cuenta, tipo_bloqueo, causa_bloqueo, area_solicita, justificacion
                        INTO iIdRegistro, cCuenta, iTipoBloqueo, cCausaBloqueo, cAreaSolicita, cJustificacion
                        FROM bdicnweb:'informix'.sw_tr_cargamasiva_bloqueocre
                        WHERE lote = pLote
                                AND usuario = pUsuario
                                AND status = 'C'
								
                        --EXECUTE PROCEDURE bdicred:sp_bloqueocuenta(cEmpresa, cCuenta, iTipoBloqueo, cCausaBloqueo, pUsuario, 2) INTO cCodRetSp, cMensajeRetorno;
						EXECUTE PROCEDURE bdicred:sp_bloqueocuenta(cEmpresa, cCuenta, iTipoBloqueo, cCausaBloqueo, pUsuario, 2, cAreaSolicita, cJustificacion) INTO cCodRetSp, cMensajeRetorno;
                        LET iCodRet = cCodRetSp::INTEGER;
                        
                        IF iCodRet < 0 THEN
                                RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCIÃN DEL SP sp_bloqueocuenta EN PROCESO MASIVO';
                        ELIF iCodRet <> 0 THEN
                                LET cResultado = 'NO APLICADO';
                                LET cStatus = 'P';
                                LET iRegistrosFallidos = iRegistrosFallidos + 1;
                                LET cMotivoRechazo = cMensajeRetorno;
                        ELIF iCodRet = 0 THEN
                                LET cResultado = 'APLICADO';
                                LET cStatus = 'S';
                                LET iRegistrosExitosos = iRegistrosExitosos + 1;
                                LET cMotivoRechazo = NULL;
                        END IF;
                        
                        -- CONSULTA DEL SALDO ACTUAL DE LA CUENTA DE CREDITO
                        EXECUTE PROCEDURE bdicnweb:sp_consaldodisp(pUsuario, pIdFuncion, cCuenta, '06') INTO cCodRetSpSal, mSaldoCuenta;
                        
						-- CONSULTA DEL SALDO CAPITAL (SALDO INSOLUTO)
						SET ISOLATION TO DIRTY READ;
						SELECT NVL(sdo_cap_insoluto, 0)
						INTO dSaldoCapital
						FROM bdicred:'informix'.sd_maesdos a
						WHERE num_credito = cCuenta
							AND fecha_ult_mov = (SELECT MAX(fecha_ult_mov)
												FROM bdicred:'informix'.sd_maesdos
												WHERE num_credito = a.num_credito);
						
                        LET dFechaProceso = CURRENT;
                        
                        -- ACTUALIZACIÃN DE LA TABLA
                        UPDATE 'informix'.sw_tr_cargamasiva_bloqueocre
                        SET fecha_proceso = dFechaProceso,
                                status = cStatus,
                                resultado = cResultado,
                                codret_proceso = cCodRetSp,
                                motivo_rechazo = cMotivoRechazo,
                                saldo_cuenta = mSaldoCuenta,
                                fecha_bloqueo = dFechaProceso,
								saldo_capital = dSaldoCapital
                        WHERE id_registro = iIdRegistro;
                        
                        IF iCodRet = 0 THEN
                                INSERT INTO bdicnweb:'informix'.sw_tr_cargamasiva_bloqueocre_hist
                                SELECT * FROM bdicnweb:'informix'.sw_tr_cargamasiva_bloqueocre WHERE id_registro = iIdRegistro;
                        END IF;
                        
                        LET iNoRegistros = iNoRegistros + 1;
                        
                END FOREACH;
                
                
                -- Actualizamos el estatus en la tabla de los resumenes masivos
                EXECUTE PROCEDURE "informix".sp_totalesbloqueocre(pUsuario, pIdFuncion, pLote)
                INTO cCodRetSp, cFechaCargaLote, iTotalRegsLote, mMontoLote, iRegsAceptadosLote, iRegsRechazoLote, cArchivo, cStatusLote;
                
                SELECT COUNT(id_registro)
                INTO iRegsRechazoLote
                FROM bdicnweb:sw_tr_cargamasiva_bloqueocre 
                WHERE lote = pLote AND (codret_proceso::INTEGER <> 0 OR status = 'E');

                UPDATE bdicnweb:"informix".sw_tr_totales_masivo
                SET status_lote = 'T',
                        registros_rechazados = iRegsRechazoLote,
                        registros_aceptados = iTotalRegsLote - (iRegsRechazoLote)
                WHERE id_lote = pLote AND id_funcion = pIdFuncion;
                
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                DELETE FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre WHERE status = 'S' and lote = pLote and codret_proceso::INTEGER = 0;
                
                -- NotificaciÃ³n de correo electrÃ³nico
                LET dHoy = current;
                EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
                        '1', 
                        TRIM(pIdPlantilla), 
                        pUsuario, 
                        '',
                        '', 
                        '1', 
                        pLote,
                        NVL(iTotalRegsLote, 0),
                        TRIM(TO_CHAR(NVL(mMontoLote, 0.00), "#,###,###,###,###.##")),
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        TRIM(pTituloPlantilla),
                        '',
                        '',
                        '0',
                        '0',
                        '0',
                        '0',
                        '0',
                        dHoy,
                        dHoy) INTO cCodRetSp;
                
                RETURN cCodRet, iNoRegistros;
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/03/2014',
'DESCRIPCION: Bloqueo las cuentas de credito en proceso masivo',
'AUTOR: Oscar Flores Conde',
'FECHA: 10/02/2015',
'DESCRIPCION: Se agregan los datos del area que solicita, la justificaciÃ³n y se actualiza el saldo capital',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consbloqueomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pRegistros INT, pRecuperacion INT)
        RETURNING CHAR(5) AS codret,
                        INT AS id,
                        CHAR(20) AS no_credito,
                        CHAR(20) AS no_cliente,
                        CHAR(15) AS resultado,
                        CHAR(6) AS codretsp,
                        CHAR(80) AS motivo_rechazo,
                        MONEY(14,2) AS saldo,
                        CHAR(107) AS nombre_cliente,
                        INTEGER AS tipo_bloqueo,
                        CHAR(2) AS causa_bloqueo,
                        DATE AS fecha_bloqueo,
                        CHAR(8) AS empleado,
                        CHAR(45) AS nombre_empleado,
                        CHAR(1) AS status,
						CHAR(150) AS area_solicitante,
						CHAR(150) AS justificacion,
						DECIMAL(18, 2) AS saldo_capital;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iIdRegistro INTEGER;
        DEFINE cNoCuenta CHAR(20);
        DEFINE cNoCliente CHAR(20);
        DEFINE cResultado CHAR(15);
        DEFINE cCodRetSp CHAR(6);
        DEFINE cMotivoRechazo CHAR(80);
        DEFINE mSaldo MONEY(14,2);
        DEFINE cNombreCliente CHAR(107);
        DEFINE iTipoBloqueo INTEGER;
        DEFINE cCausaBloqueo CHAR(2);
        DEFINE dFechaBloqueo DATE;
        DEFINE cEmpleado CHAR(8);
        DEFINE cNombreEmpleado CHAR(45);
        DEFINE cStatusRegistro CHAR(1);
        DEFINE iExiste INTEGER;
        DEFINE iNoRegistros INTEGER;
		DEFINE cAreaSolicita CHAR(150);
		DEFINE cJustificacion CHAR(150);
		DEFINE dSaldoCapital DECIMAL(18,2);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iIdRegistro = 0;
        LET cNoCuenta = '';
        LET cNoCliente = '';
        LET cResultado = '';
        LET cCodRetSp = '';
        LET cMotivoRechazo = '';
        LET mSaldo = NULL;
        LET cNombreCliente = '';
        LET iTipoBloqueo = 0;
        LET cCausaBloqueo = '';
        LET dFechaBloqueo = NULL;
        LET cEmpleado = '';
        LET cNombreEmpleado = '';
        LET cStatusRegistro = '';
        LET iExiste = 0;
        LET iNoRegistros = 0;
		LET cAreaSolicita = '';
		LET cJustificacion = '';
		LET dSaldoCapital = NULL;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente, iTipoBloqueo, cCausaBloqueo, 
                               dFechaBloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicita, cJustificacion, dSaldoCapital;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consbloqueomasivocre.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente, iTipoBloqueo, cCausaBloqueo, 
                               dFechaBloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicita, cJustificacion, dSaldoCapital;
                END IF;
                
                IF pRegistros < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente, iTipoBloqueo, cCausaBloqueo, 
                               dFechaBloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicita, cJustificacion, dSaldoCapital;
                END IF;
                
                -- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente, iTipoBloqueo, cCausaBloqueo, 
                               dFechaBloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicita, cJustificacion, dSaldoCapital;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                SELECT COUNT(id_registro)
                INTO iExiste
                FROM 
                        (SELECT id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre
                        WHERE lote = pLote
                        UNION
                        SELECT {+INDEX (bdicnweb:sw_tr_cargamasiva_bloqueocre_hist sw_tr_cargamasiva_bloqueocre_hist)} id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre_hist
                        WHERE lote = pLote);
                
                IF iExiste = 0 THEN
                        LET cCodRet = '00200';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente, iTipoBloqueo, cCausaBloqueo, 
                               dFechaBloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicita, cJustificacion, dSaldoCapital;
                END IF;
                
                -- ACTUALIZACIÃN DEL ESTATUS POR VALIDACION
                UPDATE bdicnweb:sw_tr_cargamasiva_bloqueocre
                SET resultado = 'NO APLICADO',
                        motivo_rechazo = 'ERROR POR VALIDACION'
                WHERE lote = pLote AND status = 'E';
                
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, 
                                        tipo_bloqueo, causa_bloqueo, fecha_bloqueo, usuario, status, area_solicita, justificacion, saldo_capital
                        INTO iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo,
                                        iTipoBloqueo, cCausaBloqueo, dFechaBloqueo, cEmpleado, cStatusRegistro,
										cAreaSolicita, cJustificacion, dSaldoCapital
                        FROM
                                (SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, 
                                                tipo_bloqueo, causa_bloqueo, fecha_bloqueo, usuario, usuario, status, area_solicita, justificacion, saldo_capital
                                FROM bdicnweb:sw_tr_cargamasiva_bloqueocre
                                WHERE usuario = pUsuario
                                        AND lote = pLote
                                UNION
                                SELECT {+INDEX (bdicnweb:sw_tr_cargamasiva_bloqueocre_hist sw_tr_cargamasiva_bloqueocre_hist)} id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, 
                                                tipo_bloqueo, causa_bloqueo, fecha_bloqueo, usuario, usuario, status, area_solicita, justificacion, saldo_capital
                                FROM bdicnweb:sw_tr_cargamasiva_bloqueocre_hist
                                WHERE usuario = pUsuario
                                        AND lote = pLote)
                        ORDER BY id_registro
                        
                        
                        IF cNoCliente IS NULL OR cNoCliente = '' THEN
                                SELECT NVL(a.numcte, '')
                                INTO cNoCliente
                                FROM bdicred:sd_maecred a
                                WHERE num_credito = cNoCuenta;
                                
                                UPDATE bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre
                                SET numcte = cNoCliente
                                WHERE id_registro = iIdRegistro;
                                
                                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                                        UPDATE bdicnweb:"informix".sw_tr_cargamasiva_bloqueocre_hist
                                        SET numcte = cNoCliente
                                        WHERE id_registro = iIdRegistro;
                                END IF;
                        END IF;
                        
                        SELECT NVL(TRIM(TRIM(TRIM(b.nombre1)||' '||TRIM(b.nombre2))||' '||TRIM(TRIM(b.apell_paterno)||' '||TRIM(b.apell_materno))), '') as nombre
                        INTO cNombreCliente
                        FROM bdinteg:si_cliente b
                        WHERE numcte = cNoCliente;
                        
                        SELECT NVL(nombre, '')
                        INTO cNombreEmpleado
                        FROM bdinteg:si_ejecut
                        WHERE ejecutivo = cEmpleado;
                        
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, UPPER(cMotivoRechazo), mSaldo, cNombreCliente, iTipoBloqueo, cCausaBloqueo, 
                               dFechaBloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicita, cJustificacion, dSaldoCapital WITH RESUME;
                                   
                        LET iNoRegistros = iNoRegistros + 1;
                        
                END FOREACH;
                
                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente, iTipoBloqueo, cCausaBloqueo, 
                               dFechaBloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicita, cJustificacion, dSaldoCapital;
                ELIF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente, iTipoBloqueo, cCausaBloqueo, 
                               dFechaBloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicita, cJustificacion, dSaldoCapital;
                END IF;
                
        END;
                        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/07/2014',
'DESCRIPCION: Consulta de los registros de un lote masivo de cuentas a ser bloqueadas',
'AUTOR: Oscar Flores Conde',
'FECHA: 10/02/2015',
'DESCRIPCION: Se agrega a la salida los parametros de area que solicita el bloque, la justificaciÃ³n y el dato del saldo capital',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_desbloqueoctacre_masivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INTEGER, pIdPlantilla CHAR(25), pTituloPlantilla CHAR(255))
        RETURNING CHAR(5) AS codret,
                        INTEGER AS registros_procesados;
                        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE cMensajeRetorno CHAR(80);
        DEFINE iNoRegistros INTEGER;
        DEFINE iExiste INTEGER;
        DEFINE iRegistrosExitosos INTEGER;
        DEFINE iRegistrosFallidos INTEGER;
        DEFINE iCodRet INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE cCuenta CHAR(20);
        DEFINE cResultado CHAR(15);
        DEFINE cStatus CHAR(1);
        DEFINE cMotivoRechazo CHAR(80);
        DEFINE mSaldoCuenta MONEY(14,2);
        DEFINE cCodRetSpSal CHAR(5);
        DEFINE dFechaProceso DATETIME YEAR TO FRACTION(3);
        DEFINE iIdRegistro INTEGER;
        DEFINE cFechaCargaLote DATE;
        DEFINE iTotalRegsLote INTEGER;
        DEFINE mMontoLote MONEY(14, 2);
        DEFINE iRegsAceptadosLote INTEGER;
        DEFINE iRegsRechazoLote INTEGER;
        DEFINE cArchivo CHAR(150);
        DEFINE cStatusLote CHAR(1);
        DEFINE dHoy DATETIME YEAR TO FRACTION(3);
		DEFINE cAreaSolicitante CHAR(150);
		DEFINE cJustificacion CHAR(150);
		DEFINE dSaldoCapital DECIMAL(18,2);
        
        LET cCodRet = '';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cMensajeRetorno = '';
        LET iNoRegistros = 0;
        LET iExiste = 0;
        LET iRegistrosExitosos = 0;
        LET iRegistrosFallidos = 0;
        LET iCodRet = 0;
        LET cEmpresa = '001';
        LET cCuenta = '';
        LET cResultado = '';
        LET cStatus = '';
        LET cMotivoRechazo = '';
        LET mSaldoCuenta = NULL;
        LET cCodRetSpSal = '';
        LET dFechaProceso = NULL;
        LET iIdRegistro = 0;
        LET cFechaCargaLote = NULL;
        LET iTotalRegsLote = 0;
        LET mMontoLote = NULL;
        LET iRegsAceptadosLote = 0;
        LET iRegsRechazoLote = 0;
        LET cArchivo = '';
        LET cStatusLote = '';
        LET dHoy = NULL;
		LET cAreaSolicitante = '';
		LET cJustificacion = '';
		LET dSaldoCapital = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iNoRegistros;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_desbloqueoctacre_masivo.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iNoRegistros;
                END IF;
                
                -- VALIDACIION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iNoRegistros;
                END IF;
                
                -- BUSQUEDA DEL LOTE            
                SET ISOLATION TO DIRTY READ;
                SELECT COUNT(id_registro)
                INTO iExiste
                FROM 
                        (SELECT id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre
                        WHERE lote = pLote
                        UNION
                        SELECT id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre_hist
                        WHERE lote = pLote);
                        
                IF iExiste = 0 THEN
                        LET cCodRet = '00200';
                        RETURN cCodRet, iNoRegistros;
                END IF;
                        
                -- ACTUALIZACIÃN DEL ESTATUS DEL LOTE
                UPDATE bdicnweb:'informix'.sw_tr_totales_masivo
                SET status_lote = 'P'
                WHERE id_lote = pLote AND id_funcion = pIdFuncion AND usuario = pIdFuncion;
				
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                FOREACH SELECT id_registro, cuenta, area_solicita, justificacion
                        INTO iIdRegistro, cCuenta, cAreaSolicitante, cJustificacion
                        FROM bdicnweb:'informix'.sw_tr_cargamasiva_desbloqueocre
                        WHERE lote = pLote
                                AND usuario = pUsuario
                                AND status = 'C'
                        
                        --EXECUTE PROCEDURE bdicred:'informix'.sp_desbloqueocuenta(cEmpresa, cCuenta, pUsuario, 2) INTO cCodRetSp, cMensajeRetorno;
						EXECUTE PROCEDURE bdicred:'informix'.sp_desbloqueocuenta(cEmpresa, cCuenta, pUsuario, 2, cAreaSolicitante, cJustificacion) INTO cCodRetSp, cMensajeRetorno;
                        LET iCodRet = cCodRetSp::INTEGER;
                        
                        IF iCodRet < 0 THEN
                                RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCIÃN DEL SP sp_bloqueocuenta EN PROCESO MASIVO';
                        ELIF iCodRet <> 0 THEN
                                LET cResultado = 'NO APLICADO';
                                LET cStatus = 'P';
                                LET iRegistrosFallidos = iRegistrosFallidos + 1;
                                LET cMotivoRechazo = cMensajeRetorno;
                        ELIF iCodRet = 0 THEN
                                LET cResultado = 'APLICADO';
                                LET cStatus = 'S';
                                LET iRegistrosExitosos = iRegistrosExitosos + 1;
                                LET cMotivoRechazo = NULL;
                        END IF;
                        
                        -- CONSULTA DEL SALDO ACTUAL DE LA CUENTA DE CREDITO
                        EXECUTE PROCEDURE bdicnweb:sp_consaldodisp(pUsuario, pIdFuncion, cCuenta, '06') INTO cCodRetSpSal, mSaldoCuenta;
						
						-- CONSULTA DEL SALDO CAPITAL (SALDO INSOLUTO)
						SET ISOLATION TO DIRTY READ;
						SELECT NVL(sdo_cap_insoluto, 0)
						INTO dSaldoCapital
						FROM bdicred:'informix'.sd_maesdos a
						WHERE num_credito = cCuenta
							AND fecha_ult_mov = (SELECT MAX(fecha_ult_mov)
												FROM bdicred:'informix'.sd_maesdos
												WHERE num_credito = a.num_credito);
                        
                        LET dFechaProceso = CURRENT;
                        
                        -- ACTUALIZACIÃN DE LA TABLA
                        UPDATE 'informix'.sw_tr_cargamasiva_desbloqueocre
                        SET fecha_proceso = dFechaProceso,
                                status = cStatus,
                                resultado = cResultado,
                                codret_proceso = cCodRetSp,
                                motivo_rechazo = cMotivoRechazo,
                                saldo_cuenta = mSaldoCuenta,
                                fecha_desbloqueo = dFechaProceso,
								saldo_capital = dSaldoCapital
                        WHERE id_registro = iIdRegistro;
                        
                        IF iCodRet = 0 THEN
                                INSERT INTO bdicnweb:'informix'.sw_tr_cargamasiva_desbloqueocre_hist
                                SELECT * FROM bdicnweb:'informix'.sw_tr_cargamasiva_desbloqueocre WHERE id_registro = iIdRegistro;
                        END IF;
                        
                        LET iNoRegistros = iNoRegistros + 1;
                        
                END FOREACH;
                
                
                -- Actualizamos el estatus en la tabla de los resumenes masivos
                EXECUTE PROCEDURE "informix".sp_totalesdesbloqueocre(pUsuario, pIdFuncion, pLote)
                INTO cCodRetSp, cFechaCargaLote, iTotalRegsLote, mMontoLote, iRegsAceptadosLote, iRegsRechazoLote, cArchivo, cStatusLote;
                
                SELECT COUNT(id_registro)
                INTO iRegsRechazoLote
                FROM bdicnweb:sw_tr_cargamasiva_desbloqueocre 
                WHERE lote = pLote AND (codret_proceso::INTEGER <> 0 OR status = 'E');

                UPDATE bdicnweb:"informix".sw_tr_totales_masivo
                SET status_lote = 'T',
                        registros_rechazados = iRegsRechazoLote,
                        registros_aceptados = iTotalRegsLote - (iRegsRechazoLote)
                WHERE id_lote = pLote AND id_funcion = pIdFuncion;
                
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                DELETE FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre WHERE status = 'S' and lote = pLote and codret_proceso::INTEGER = 0;
                
                -- NotificaciÃ³n de correo electrÃ³nico
                -- Se llama al procedimiento del registro del event
                LET dHoy = current;
                EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
                        '1', 
                        TRIM(pIdPlantilla), 
                        pUsuario, 
                        '',
                        '', 
                        '1', 
                        pLote,
                        NVL(iTotalRegsLote, 0),
                        TRIM(TO_CHAR(NVL(mMontoLote, 0.00), "#,###,###,###,###.##")),
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        TRIM(pTituloPlantilla),
                        '',
                        '',
                        '0',
                        '0',
                        '0',
                        '0',
                        '0',
                        dHoy,
                        dHoy) INTO cCodRetSp;
                
                RETURN cCodRet, iNoRegistros;
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/03/2014',
'DESCRIPCION: Bloque las cuentas de credito en proceso masivo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_atencionsolicitud(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdRegSolicitud INTEGER, pStatusRespuesta INTEGER, pFolioTransaccion CHAR(16), pCodError CHAR(5), pDescripcionError CHAR(100))
        RETURNING CHAR(5) AS codret,
                          INTEGER AS idxRegSol;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE bInTransaction BOOLEAN;
        DEFINE iIdx INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET bInTransaction='f';
        LET iIdx = 0;

         BEGIN
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdx;
			END EXCEPTION;

			ON EXCEPTION IN (-535)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
			END EXCEPTION WITH RESUME;

			ON EXCEPTION IN (-691)
				ROLLBACK;
				LET cCodRet = '00284';

				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;

				RETURN cCodRet, iIdx;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_atencionsolicitud.out';
			--TRACE ON;

			---VALIDACION DE DATOS REQUERIDOS
			IF pUsuario = '' OR pIdFuncion = '' OR pIdRegSolicitud IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iIdx;
			END IF;

			IF pStatusRespuesta NOT IN (0,1) THEN
				LET cCodRet = '00148';
				RETURN cCodRet, iIdx;
			END IF;

			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, iIdx;
			END IF;

			BEGIN WORK;

			IF pStatusRespuesta = 0 THEN ---SI LA TRANSACCION DE LA SOLICITUD FUE EXITOSA

				BEGIN WORK;
				--- CREA BACK DE LA SOLICITUD
				SET LOCK MODE TO WAIT 3;

				INSERT INTO bdicnweb:'informix'.sw_gs_registrosolicitud(folio_solicitud,id_solicitud,fecha_solicitud,id_area_solicitante,usuario_solicitante,
								id_area_responsable,usuario_responsable,id_status_solicitud,fecha_cambio,hora_cambio,num_reintentos,cliente,cuenta,clave_transaccion,
								documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
								motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
								concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote)
				SELECT folio_solicitud,id_solicitud,fecha_solicitud,id_area_solicitante,usuario_solicitante,
								id_area_responsable,usuario_responsable,3,CURRENT, CURRENT,num_reintentos,cliente,cuenta,clave_transaccion,
								documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
								motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
								concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote
				FROM bdicnweb:'informix'.sw_gs_registrosolicitud WHERE id_registro_solicitud=pIdRegSolicitud AND status='t';

				IF DBINFO('sqlca.sqlerrd2') = 1 THEN
						LET iIdx = DBINFO('sqlca.sqlerrd1');
				END IF;

				IF DBINFO('sqlca.sqlerrd2')     = 0 THEN
						LET cCodRet = '00236';
						ROLLBACK WORK;
						RETURN cCodRet, iIdx;
				END IF;

				COMMIT;

				BEGIN;
				---ACTUALIZA SOLICITUD ORIGINAL
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
				SET status = 'f' --, fecha_cambio = CURRENT, hora_cambio=CURRENT
				WHERE id_registro_solicitud = pIdRegSolicitud;

				--- ACTUALIZA SOLICITUD NUEVA INSERTADA
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
				SET id_status_solicitud= '3' , fecha_cambio = CURRENT, hora_cambio=CURRENT, fecha_atencion = CURRENT,
				folio_transaccion = pFolioTransaccion
				WHERE id_registro_solicitud=iIdx;

				--ACTUALIZA COMENTARIOS
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:'informix'.sw_gs_comentarios
				SET id_registro_solicitud =  iIdx
				WHERE id_registro_solicitud = pIdRegSolicitud;

				COMMIT;


				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;

				RETURN cCodRet, iIdx;
			END IF;
			IF pStatusRespuesta = 1 THEN ---SI LA TRANSACCION DE LA SOLICITUD NO FUE EXITOSA

				BEGIN WORK;
				--- CREA BACK DE LA SOLICITUD
				SET LOCK MODE TO WAIT 3;

				INSERT INTO bdicnweb:'informix'.sw_gs_registrosolicitud(folio_solicitud,id_solicitud,fecha_solicitud,id_area_solicitante,usuario_solicitante,
								id_area_responsable,usuario_responsable,id_status_solicitud,fecha_cambio,hora_cambio,num_reintentos,cliente,cuenta,clave_transaccion,
								documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
								motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
								concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote)
				SELECT folio_solicitud,id_solicitud,fecha_solicitud,id_area_solicitante,usuario_solicitante,
								id_area_responsable,usuario_responsable,2,CURRENT,CURRENT,num_reintentos,cliente,cuenta,clave_transaccion,
								documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
								motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
								concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote
				FROM bdicnweb:'informix'.sw_gs_registrosolicitud WHERE id_registro_solicitud=pIdRegSolicitud AND status='t';

				IF DBINFO('sqlca.sqlerrd2') = 1 THEN
						LET iIdx = DBINFO('sqlca.sqlerrd1');
				END IF;

				IF DBINFO('sqlca.sqlerrd2')     = 0 THEN
						LET cCodRet = '00236';
						ROLLBACK WORK;
						RETURN cCodRet, iIdx;
				END IF;

				COMMIT;

				BEGIN;
				---ACTUALIZA SOLICITUD ORIGINAL
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
				SET status = 'f' --, fecha_cambio = CURRENT, hora_cambio=CURRENT
				WHERE id_registro_solicitud = pIdRegSolicitud;

				--- ACTUALIZA SOLICITUD NUEVA INSERTADA
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
				SET id_status_solicitud= '2' , fecha_cambio = CURRENT, hora_cambio=CURRENT, fecha_atencion = CURRENT,
				folio_transaccion = pFolioTransaccion, cod_error = pCodError, desc_error = pDescripcionError
				WHERE id_registro_solicitud=iIdx;

				--ACTUALIZA COMENTARIOS
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:'informix'.sw_gs_comentarios
				SET id_registro_solicitud =  iIdx
				WHERE id_registro_solicitud = pIdRegSolicitud;

				COMMIT;

				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;

				RETURN cCodRet, iIdx;
			END IF;
	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 20/06/2014',
'DESCRIPCION: AtenciÃ³n de la solicitud de gestor de operaciones en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/12/2014',
'DESCRIPCION: Se modifica para insertar fecha cambio y hora cambio para control de cambios status en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 17/02/2014',
'DESCRIPCION: modificaciÃ³n en tabla sw_gs_registrosolicitud y sw_gs_registrosolicitud_hist, se agregan columnas area_persona_solicita y motivo_bloqueo_desbloqueo',
'para el tratado del bloqueo y desbloqueo de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_cancelarsolicitud(pUsuario CHAR(8),   pIdFuncion CHAR(10), pIdRegSolicitud INTEGER, pIMotivo INTEGER)
        RETURNING CHAR(5) AS codret,
				  INTEGER AS idxRegSol;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE bInTransaction BOOLEAN;
        DEFINE iIdx INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET bInTransaction='f';
        LET iIdx = 0;

         BEGIN
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdx;
			END EXCEPTION;

			ON EXCEPTION IN (-535)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
			END EXCEPTION WITH RESUME;

			ON EXCEPTION IN (-691)
				ROLLBACK;
				LET cCodRet = '00284';

				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;

				RETURN cCodRet, iIdx;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_cancelarsolicitud.out';
			--TRACE ON;

			---VALIDACION DE DATOS REQUERIDOS
			IF pUsuario = '' OR pIdFuncion = '' OR pIdRegSolicitud IS NULL OR pIMotivo IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iIdx;
			END IF;

			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, iIdx;
			END IF;

			BEGIN WORK;
			--- CREA BACK DE LA SOLICITUD
			SET LOCK MODE TO WAIT 3;

			INSERT INTO bdicnweb:'informix'.sw_gs_registrosolicitud(folio_solicitud,id_solicitud,fecha_solicitud,id_area_solicitante,usuario_solicitante,
						id_area_responsable,usuario_responsable,id_status_solicitud,fecha_cambio,hora_cambio,num_reintentos,cliente,cuenta,clave_transaccion,
						documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
						motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
						concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote)
			SELECT folio_solicitud,id_solicitud,fecha_solicitud,id_area_solicitante,usuario_solicitante,
						id_area_responsable,usuario_responsable,1,CURRENT,CURRENT,num_reintentos,cliente,cuenta,clave_transaccion,
						documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
						motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
						concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote
			FROM bdicnweb:'informix'.sw_gs_registrosolicitud WHERE id_registro_solicitud=pIdRegSolicitud AND status='t';

			IF DBINFO('sqlca.sqlerrd2') = 1 THEN
				LET iIdx = DBINFO('sqlca.sqlerrd1');
			END IF;

			IF DBINFO('sqlca.sqlerrd2')     = 0 THEN
				LET cCodRet = '00236';
				ROLLBACK WORK;
				RETURN cCodRet, iIdx;
			END IF;

			COMMIT;

			BEGIN;
			---ACTUALIZA SOLICITUD ORIGINAL
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
			SET status = 'f' --, fecha_cambio = CURRENT, hora_cambio=CURRENT
			WHERE id_registro_solicitud = pIdRegSolicitud;

			--- ACTUALIZA SOLICITUD NUEVA INSERTADA
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
			SET id_motivo_cancelacion =  pIMotivo , id_status_solicitud= '1' , fecha_cambio = CURRENT, hora_cambio=CURRENT, fecha_atencion = CURRENT
			WHERE id_registro_solicitud=iIdx;

			--ACTUALIZA COMENTARIOS
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_comentarios
			SET id_registro_solicitud =  iIdx
			WHERE id_registro_solicitud = pIdRegSolicitud;

			COMMIT;


			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, iIdx;

	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 04/06/2014',
'DESCRIPCION: Cancela solicitud para atender en gestor de operaciones en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/12/2014',
'DESCRIPCION: Se modifica para insertar fecha cambio y hora cambio para control de cambios status en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 17/02/2014',
'DESCRIPCION: modificaciÃ³n en tabla sw_gs_registrosolicitud y sw_gs_registrosolicitud_hist, se agregan columnas area_persona_solicita y motivo_bloqueo_desbloqueo',
'para el tratado del bloqueo y desbloqueo de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_cancelarsolicitudreintento(pUsuario CHAR(8),  pIdFuncion CHAR(10), pIdRegSolicitud INTEGER)
        RETURNING CHAR(5) AS codret,
				  INTEGER AS idxRegSol;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE bInTransaction BOOLEAN;
        DEFINE iIdx INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET bInTransaction='f';
        LET iIdx = 0;

         BEGIN
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdx;
			END EXCEPTION;

			ON EXCEPTION IN (-535)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
			END EXCEPTION WITH RESUME;

			ON EXCEPTION IN (-691)
				ROLLBACK;
				LET cCodRet = '00284';

				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;

				RETURN cCodRet, iIdx;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_cancelarsolicitudreintento.out';
			--TRACE ON;

			---VALIDACION DE DATOS REQUERIDOS
			IF pUsuario = '' OR pIdFuncion = '' OR pIdRegSolicitud IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iIdx;
			END IF;

			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, iIdx;
			END IF;

			BEGIN WORK;
			--- CREA BACK DE LA SOLICITUD
			SET LOCK MODE TO WAIT 3;

			INSERT INTO bdicnweb:'informix'.sw_gs_registrosolicitud(folio_solicitud,id_solicitud,fecha_solicitud,id_area_solicitante,usuario_solicitante,
						id_area_responsable,usuario_responsable,id_status_solicitud,fecha_cambio,hora_cambio,num_reintentos,cliente,cuenta,clave_transaccion,
						documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
						motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
						concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote)
			SELECT folio_solicitud,id_solicitud,fecha_solicitud,id_area_solicitante,usuario_solicitante,
						id_area_responsable,usuario_responsable,1,CURRENT,CURRENT,num_reintentos,cliente,cuenta,clave_transaccion,
						documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
						motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
						concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote
			FROM bdicnweb:'informix'.sw_gs_registrosolicitud WHERE id_registro_solicitud=pIdRegSolicitud AND status='t';

			IF DBINFO('sqlca.sqlerrd2') = 1 THEN
				LET iIdx = DBINFO('sqlca.sqlerrd1');
			END IF;

			IF DBINFO('sqlca.sqlerrd2')     = 0 THEN
				LET cCodRet = '00236';
				ROLLBACK WORK;
				RETURN cCodRet, iIdx;
			END IF;

			COMMIT;

			BEGIN;
			---ACTUALIZA SOLICITUD ORIGINAL
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
			SET status = 'f' --, fecha_cambio = CURRENT, hora_cambio=CURRENT
			WHERE id_registro_solicitud = pIdRegSolicitud;

			--- ACTUALIZA SOLICITUD NUEVA INSERTADA
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
			SET id_motivo_cancelacion =  NULL , id_status_solicitud= '1' , fecha_cambio = CURRENT, hora_cambio=CURRENT,  fecha_atencion = CURRENT
			WHERE id_registro_solicitud=iIdx;

			--ACTUALIZA COMENTARIOS
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_comentarios
			SET id_registro_solicitud =  iIdx
			WHERE id_registro_solicitud = pIdRegSolicitud;

			COMMIT;

			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, iIdx;

	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 13/08/2014',
'DESCRIPCION: Cancela solicitud cuando se termina el numero de los reintentos de una solicitud en gestor de operaciones en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/12/2014',
'DESCRIPCION: Se modifica para insertar fecha cambio y hora cambio para control de cambios status en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 17/02/2014',
'DESCRIPCION: modificaciÃ³n en tabla sw_gs_registrosolicitud y sw_gs_registrosolicitud_hist, se agregan columnas area_persona_solicita y motivo_bloqueo_desbloqueo',
'para el tratado del bloqueo y desbloqueo de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_detalleregistrosolicitud(pUsuario CHAR(8),pIdFuncion CHAR(10),pIdRegistroSolicitud INTEGER)
        RETURNING CHAR(5) AS codret,
					CHAR(20) AS cliente,
					CHAR(20) AS cuenta,
					CHAR(4) AS claveTransaccion,
					INTEGER AS documentoCheque,
					DECIMAL(16,2) AS importe,
					CHAR(40) AS referencia,
					CHAR(4) AS sucursal,
					CHAR(8) AS usuarioRev,
					CHAR(16) AS folioReverso,
					INTEGER AS claveBloqueo,
					INTEGER AS opcionBloqueo,
					INTEGER AS areaSolicitanteBloqueo,
					INTEGER AS motivoBloqueo,
					CHAR(150) AS areaPersonaSolicita,
					CHAR(150) AS motivoBloqueoDesbloqueo,
					DATE AS fechaVencimiento,
					CHAR(20) AS cuentaReferencia,
					INTEGER AS instruccionVencimiento,
					INTEGER AS tipoBloqueo,
					INTEGER AS causaBloqueo,
					CHAR(2) AS concepto,
					CHAR(50) AS observaciones,
					INTEGER AS motivoCancelacion,
					INTEGER AS lote,        
					INTEGER AS idSolicitud,
					CHAR(20) AS folioSolicitud,
					DATE AS fechaSolicitud,
					CHAR(50) AS descripcionArea,
					CHAR(8) AS ejecutivo,
					CHAR(45) AS nombreEjecutivo,
					DATE AS fechaDel,
					DATE AS fechaAl;
                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;         
        DEFINE cCliente CHAR(20);
        DEFINE cCuenta CHAR(20);
        DEFINE cClaveTransaccion CHAR(4);                      
        DEFINE iDocumentoCheque INTEGER;
        DEFINE dImporte DECIMAL(16,2);
        DEFINE cReferencia CHAR(40);
        DEFINE cSucursal CHAR(4);
        DEFINE cUsuarioRev CHAR(8);
        DEFINE cFolioReverso CHAR(16);
        DEFINE iClaveBloqueo INTEGER;
        DEFINE iOpcionBloqueo INTEGER;
        DEFINE iAreaSolicitanteBloqueo INTEGER;
        DEFINE iMotivoBloqueo INTEGER;
		DEFINE cAreaPersonaSolicita CHAR(150);
		DEFINE cMotivoBloqueoDesbloqueo CHAR(150);
        DEFINE dFechaVencimiento DATE;
        DEFINE cCuentaReferencia CHAR(20);
        DEFINE iInstruccionVencimiento INTEGER;
        DEFINE iTipoBloqueo INTEGER;
        DEFINE iCausaBloqueo INTEGER;
        DEFINE cConcepto CHAR(2);
        DEFINE cObservaciones CHAR(50);
        DEFINE iMotivoCancelacion INTEGER;
        DEFINE iLote INTEGER;   
        DEFINE iIdSolicitud INTEGER;    
        DEFINE iNoRegistros INTEGER;
        DEFINE iFolioSolicitud CHAR(20);
        DEFINE dFechaSolicitud DATE;
        DEFINE cDescripcionArea CHAR(50);
        DEFINE cEjecutivo CHAR(8);
        DEFINE cNombreEjecutivo CHAR(45);
        DEFINE dFechaDel DATE;
        DEFINE dFechaAl DATE;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;                
        LET cCliente = '';
        LET cCuenta = '';
        LET cClaveTransaccion = '';                      
        LET iDocumentoCheque = 0;
        LET dImporte = 0;
        LET cReferencia = '';
        LET cSucursal = '';
        LET cUsuarioRev = '';
        LET cFolioReverso = '';
        LET iClaveBloqueo = 0;
        LET iOpcionBloqueo = 0;
        LET iAreaSolicitanteBloqueo = 0;
        LET iMotivoBloqueo = 0;
		LET cAreaPersonaSolicita = '';
		LET cMotivoBloqueoDesbloqueo = '';
        LET dFechaVencimiento = NULL;
        LET cCuentaReferencia = '';
        LET iInstruccionVencimiento = 0;
        LET iTipoBloqueo = 0;
        LET iCausaBloqueo = 0;
        LET cConcepto = '';
        LET cObservaciones = '';
        LET iMotivoCancelacion = 0;
        LET iLote = 0;
        LET iIdSolicitud = 0;
        LET iNoRegistros = 0;
        LET iFolioSolicitud = '';
        LET dFechaSolicitud = NULL;
        LET cDescripcionArea = '';
        LET cEjecutivo = '';
        LET cNombreEjecutivo = '';
        LET dFechaDel = NULL;
        LET dFechaAl = NULL;
        
         BEGIN
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cCliente,cCuenta,cClaveTransaccion,iDocumentoCheque,dImporte,cReferencia,cSucursal,cUsuarioRev,cFolioReverso,iClaveBloqueo,iOpcionBloqueo,
								iAreaSolicitanteBloqueo,iMotivoBloqueo,cAreaPersonaSolicita,cMotivoBloqueoDesbloqueo,dFechaVencimiento,cCuentaReferencia,iInstruccionVencimiento,iTipoBloqueo,
								iCausaBloqueo,cConcepto,cObservaciones,iMotivoCancelacion,iLote,iIdSolicitud,iFolioSolicitud,dFechaSolicitud,cDescripcionArea,
								cEjecutivo,cNombreEjecutivo,dFechaDel,dFechaAl;
			END EXCEPTION;
	 
			----SET DEBUG FILE TO '/tmp/mfinis/sp_gs_detalleregistrosolicitud.out';
			----TRACE ON;
			
			---VALIDACION DE CAMPOS REQUERIDOS
			IF pUsuario = '' OR pIdFuncion = '' OR pIdRegistroSolicitud IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cCliente,cCuenta,cClaveTransaccion,iDocumentoCheque,dImporte,cReferencia,cSucursal,cUsuarioRev,cFolioReverso,iClaveBloqueo,iOpcionBloqueo,
								iAreaSolicitanteBloqueo,iMotivoBloqueo,cAreaPersonaSolicita,cMotivoBloqueoDesbloqueo,dFechaVencimiento,cCuentaReferencia,iInstruccionVencimiento,iTipoBloqueo,
								iCausaBloqueo,cConcepto,cObservaciones,iMotivoCancelacion,iLote,iIdSolicitud,iFolioSolicitud,dFechaSolicitud,cDescripcionArea,
								cEjecutivo,cNombreEjecutivo,dFechaDel,dFechaAl; 
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet,cCliente,cCuenta,cClaveTransaccion,iDocumentoCheque,dImporte,cReferencia,cSucursal,cUsuarioRev,cFolioReverso,iClaveBloqueo,iOpcionBloqueo,
								iAreaSolicitanteBloqueo,iMotivoBloqueo,cAreaPersonaSolicita,cMotivoBloqueoDesbloqueo,dFechaVencimiento,cCuentaReferencia,iInstruccionVencimiento,iTipoBloqueo,
								iCausaBloqueo,cConcepto,cObservaciones,iMotivoCancelacion,iLote,iIdSolicitud,iFolioSolicitud,dFechaSolicitud,cDescripcionArea,
								cEjecutivo,cNombreEjecutivo,dFechaDel,dFechaAl;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			FOREACH SELECT cliente,cuenta,clave_transaccion,documento_cheque,importe,referencia,sucursal,usuario_rev,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
							   motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo, causa_bloqueo,concepto,observaciones,
							   motivo_cancelacion,lote,id_solicitud,folio_solicitud,fecha_solicitud,descripcion_area,ejecutivo,nombre, fecha_del, fecha_al
					INTO cCliente,cCuenta,cClaveTransaccion,iDocumentoCheque,dImporte,cReferencia,cSucursal,cUsuarioRev,cFolioReverso,iClaveBloqueo,iOpcionBloqueo,
						   iAreaSolicitanteBloqueo,iMotivoBloqueo,cAreaPersonaSolicita,cMotivoBloqueoDesbloqueo,dFechaVencimiento,cCuentaReferencia,iInstruccionVencimiento,iTipoBloqueo,
						   iCausaBloqueo,cConcepto,cObservaciones,iMotivoCancelacion,iLote,iIdSolicitud,iFolioSolicitud,dFechaSolicitud,cDescripcionArea,
							   cEjecutivo,cNombreEjecutivo,dFechaDel,dFechaAl
					FROM
					(SELECT a.cliente,a.cuenta,a.clave_transaccion,a.documento_cheque,a.importe,referencia,a.sucursal,a.usuario_rev,a.folio_reverso,a.clave_bloqueo,a.opcion_bloqueo,a.area_solicitante_bloqueo,
									a.motivo_bloqueo,a.area_persona_solicita,a.motivo_bloqueo_desbloqueo,a.fecha_vencimiento,a.cuenta_referencia,a.instruccion_vencimiento,a.tipo_bloqueo,a.causa_bloqueo,a.concepto,a.observaciones,
									a.motivo_cancelacion,a.lote,a.id_solicitud,a.folio_solicitud,a.fecha_solicitud,b.descripcion_area,c.ejecutivo,c.nombre,a.fecha_del,a.fecha_al
					FROM (bdicnweb:sw_gs_registrosolicitud a
					LEFT JOIN bdicnweb:sw_gs_area b ON a.id_area_solicitante=b.id_area)
					LEFT JOIN bdinteg:si_ejecut c ON c.ejecutivo=a.usuario_solicitante
					WHERE a.id_registro_solicitud = pIdRegistroSolicitud AND a.status = 't'
					UNION   
					SELECT a.cliente,a.cuenta,a.clave_transaccion,a.documento_cheque,a.importe,a.referencia,a.sucursal,a.usuario_rev,a.folio_reverso,a.clave_bloqueo,a.opcion_bloqueo,a.area_solicitante_bloqueo,
									a.motivo_bloqueo,a.area_persona_solicita,a.motivo_bloqueo_desbloqueo,a.fecha_vencimiento,a.cuenta_referencia,a.instruccion_vencimiento,a.tipo_bloqueo,a.causa_bloqueo,a.concepto,a.observaciones,
									a.motivo_cancelacion,a.lote,a.id_solicitud,a.folio_solicitud,a.fecha_solicitud,b.descripcion_area,c.ejecutivo,c.nombre,a.fecha_del,a.fecha_al
					FROM (bdicnweb:sw_gs_registrosolicitud_hist a
					LEFT JOIN bdicnweb:sw_gs_area b ON a.id_area_solicitante=b.id_area)
					LEFT JOIN bdinteg:si_ejecut c ON c.ejecutivo=a.usuario_solicitante
					WHERE a.id_registro_solicitud = pIdRegistroSolicitud AND a.status = 't')
					RETURN cCodRet,cCliente,cCuenta,cClaveTransaccion,iDocumentoCheque,dImporte,cReferencia,cSucursal,cUsuarioRev,cFolioReverso,iClaveBloqueo,iOpcionBloqueo,
							iAreaSolicitanteBloqueo,iMotivoBloqueo,cAreaPersonaSolicita,cMotivoBloqueoDesbloqueo,dFechaVencimiento,cCuentaReferencia,iInstruccionVencimiento,iTipoBloqueo,
							iCausaBloqueo,cConcepto,cObservaciones,iMotivoCancelacion,iLote,iIdSolicitud, LPAD(TRIM(iFolioSolicitud),13, '0'),dFechaSolicitud,cDescripcionArea,
							cEjecutivo,cNombreEjecutivo,dFechaDel,dFechaAl;
					LET iNoRegistros = iNoRegistros +  1;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cCliente,cCuenta,cClaveTransaccion,iDocumentoCheque,dImporte,cReferencia,cSucursal,cUsuarioRev,cFolioReverso,iClaveBloqueo,iOpcionBloqueo,
						iAreaSolicitanteBloqueo,iMotivoBloqueo,cAreaPersonaSolicita,cMotivoBloqueoDesbloqueo,dFechaVencimiento,cCuentaReferencia,iInstruccionVencimiento,iTipoBloqueo,
						iCausaBloqueo,cConcepto,cObservaciones,iMotivoCancelacion,iLote,iIdSolicitud,iFolioSolicitud,dFechaSolicitud,cDescripcionArea,
						cEjecutivo,cNombreEjecutivo,dFechaDel,dFechaAl;
			END IF; 
                
         END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 28/05/2014',
'DESCRIPCION: Consulta el detalle de un registro de solicitud en gestor de operaciones en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 17/02/2014',
'DESCRIPCION: modificaciÃ³n en tabla sw_gs_registrosolicitud y sw_gs_registrosolicitud_hist, se agregan columnas area_persona_solicita y motivo_bloqueo_desbloqueo',
'para el tratado del bloqueo y desbloqueo de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_reasignarsolicitud(pUsuario CHAR(8),  pIdFuncion CHAR(10), pIdRegSolicitud INTEGER, pAreaResponsable INTEGER, pUsuarioResponsable CHAR(8))
        RETURNING CHAR(5) AS codret,
				  INTEGER AS idxRegSol;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE bInTransaction BOOLEAN;
        DEFINE iIdx INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET bInTransaction='f';
        LET iIdx = 0;

         BEGIN
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdx;
			END EXCEPTION;

			ON EXCEPTION IN (-535)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
			END EXCEPTION WITH RESUME;

			ON EXCEPTION IN (-691)
				ROLLBACK;
				LET cCodRet = '00284';

				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;

				RETURN cCodRet, iIdx;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_reasignarsolicitud.out';
			--TRACE ON;

			---VALIDACION DE DATOS REQUERIDOS
			IF pUsuario = '' OR pIdFuncion = '' OR pIdRegSolicitud IS NULL OR pAreaResponsable IS NULL OR  pUsuarioResponsable = ''  THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iIdx;
			END IF;

			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, iIdx;
			END IF;

			BEGIN WORK;

			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdicnweb:'informix'.sw_gs_registrosolicitud(folio_solicitud,id_solicitud,id_area_solicitante,usuario_solicitante,
					id_area_responsable,usuario_responsable,id_status_solicitud,fecha_cambio,hora_cambio,num_reintentos,cliente,cuenta,clave_transaccion,
					documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
					motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
					concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote)
			SELECT folio_solicitud,id_solicitud,id_area_solicitante,usuario_solicitante,
					pAreaResponsable,pUsuarioResponsable,0,CURRENT, CURRENT,num_reintentos,cliente,cuenta,clave_transaccion,
					documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
					motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
					concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote
			FROM bdicnweb:'informix'.sw_gs_registrosolicitud WHERE id_registro_solicitud=pIdRegSolicitud AND status='t';

			IF DBINFO('sqlca.sqlerrd2') = 1 THEN
				LET iIdx = DBINFO('sqlca.sqlerrd1');
			END IF;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00236';
				ROLLBACK WORK;
				RETURN cCodRet, iIdx;
			END IF;

			--- Se actualiza solicitud anterior
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
			SET status = 'f' --, fecha_cambio = CURRENT, hora_cambio=CURRENT
			WHERE id_registro_solicitud = pIdRegSolicitud;

			--Actualizamos comentarios
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_comentarios
			SET id_registro_solicitud =  iIdx
			WHERE id_registro_solicitud = pIdRegSolicitud;

			COMMIT;

			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, iIdx;

	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 04/06/2014',
'DESCRIPCION: Reasigna solicitud para atender en gestor de operaciones en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/12/2014',
'DESCRIPCION: Se modifica para insertar fecha cambio y hora cambio para control de cambios status en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 17/02/2014',
'DESCRIPCION: modificaciÃ³n en tabla sw_gs_registrosolicitud y sw_gs_registrosolicitud_hist, se agregan columnas area_persona_solicita y motivo_bloqueo_desbloqueo',
'para el tratado del bloqueo y desbloqueo de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_registrosolicitud(
        pUsuario CHAR(8),
        pIdFuncion CHAR(10),
        pIdSolicitud INTEGER,
        pIdAreaSolicitante INTEGER,
        pUsuarioSolicitante     CHAR(8),
        pAreaResponsable INTEGER,
        pUsuarioResponsable CHAR(8),
        pCte CHAR(20),
        pCta CHAR(20),
        pCveTransaccion CHAR(4),
        pDoctoCheque INTEGER,
        pImporte DECIMAL(16,2),
        pReferencia CHAR(40),
        pSucursal CHAR(4),
        pUsuarioRev CHAR(8),
        pFolioReverso CHAR(16),
        pCveBloqueo INTEGER,
        pOptBloqueo INTEGER,
		pAreaSolicitanteBloqueo INTEGER,
        pMotivoBloqueo INTEGER,
		pAreaPersonaSolicita CHAR(150),
		pMotivoBloqueoDesbloqueo CHAR(150),
        pFechaVencimiento DATE,
        pCuentaReferencia CHAR(20),
        pInstruccionVencimiento INTEGER,
		pTipoBloqueo INTEGER,
        pCausaBloqueo INTEGER,
        pConcepto CHAR(2),
        pObservaciones CHAR(50),
        pMotivoCancelacion INTEGER,
        pFechaDel DATE,
        pFechaAl DATE,
        pLote INTEGER)
        RETURNING CHAR(5) AS codret,
                  INTEGER AS idxRegSol;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iFolio BIGINT;
        DEFINE bInTransaction BOOLEAN;
        DEFINE iReintentos INTEGER;
        DEFINE iIdx INTEGER;
        DEFINE dFechaParam DATE;
        DEFINE cConsecutivoParam CHAR(5);
        DEFINE cAnio CHAR(10);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iFolio=0;
        LET bInTransaction='f';
        LET iReintentos=0;
        LET iIdx = 0;
        LET dFechaParam = NULL;
        LET cConsecutivoParam = '';
        LET cAnio = '';

		BEGIN
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet, iIdx;
			END EXCEPTION;

			ON EXCEPTION IN (-535)
					LET bInTransaction = 't';
					COMMIT WORK;
					BEGIN WORK;
			END EXCEPTION WITH RESUME;

			ON EXCEPTION IN (-691)
					ROLLBACK;
					LET cCodRet = '00284';

					IF bInTransaction = 't' THEN
							BEGIN WORK;
					END IF;

					RETURN cCodRet, iIdx;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_registrosolicitud.out';
			--TRACE ON;

			---VALIDACION DE DATOS REQUERIDOS
			IF pUsuario = '' OR pIdFuncion = '' OR pIdSolicitud IS NULL OR  pIdAreaSolicitante IS NULL OR pUsuarioSolicitante='' OR pAreaResponsable IS NULL OR pUsuarioResponsable='' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, iIdx;
			END IF;

			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet, iIdx;
			END IF;

			---CALCULAMOS EL FOLIO
			SELECT DATE(TRIM(valor))
			INTO dFechaParam
			FROM bdicnweb:'informix'.sw_gs_param WHERE codparam = '1';

			SELECT TRIM(valor)
			INTO cConsecutivoParam
			FROM bdicnweb:'informix'.sw_gs_param WHERE codparam = '2';

			IF(dFechaParam < DATE(CURRENT)) THEN
					LET cAnio= TRIM(SUBSTR(DATE(CURRENT),4,2) || SUBSTR(DATE(CURRENT),0,2) || SUBSTR(DATE(CURRENT),7,10));
					LET cAnio= LPAD(TRIM(cAnio),8, '0');
					LET iFolio=  TRIM(cAnio) || LPAD(TRIM('1'),5, '0');
					BEGIN WORK;
							SET LOCK MODE TO WAIT 3;
							UPDATE bdicnweb:'informix'.sw_gs_param SET valor=DATE(CURRENT) WHERE codparam = '1';
							SET LOCK MODE TO WAIT 3;
							UPDATE bdicnweb:'informix'.sw_gs_param SET valor='1' WHERE codparam = '2';
					COMMIT WORK;
			ELSE
					LET cAnio= TRIM(SUBSTR(dFechaParam,4,2) || SUBSTR(dFechaParam,0,2) || SUBSTR(dFechaParam,7,10));
					LET cAnio= LPAD(TRIM(cAnio),8, '0');
					LET iFolio=  TRIM(cAnio) || LPAD(TRIM(TO_CHAR(cConsecutivoParam::INTEGER + 1 )),5, '0');
					BEGIN WORK;
							SET LOCK MODE TO WAIT 3;
							UPDATE bdicnweb:'informix'.sw_gs_param SET valor = cConsecutivoParam::INTEGER + 1  WHERE codparam = '2';
					COMMIT WORK;
			END IF;


			BEGIN WORK;

			SET LOCK MODE TO WAIT 3;

			INSERT INTO bdicnweb:'informix'.sw_gs_registrosolicitud(folio_solicitud,id_solicitud,id_area_solicitante,usuario_solicitante,
							id_area_responsable,usuario_responsable,id_status_solicitud,fecha_cambio,hora_cambio,num_reintentos,cliente,cuenta,clave_transaccion,
							documento_cheque,importe,referencia,sucursal,usuario_rev,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
							motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
							concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote)
			VALUES(iFolio,pIdSolicitud,pIdAreaSolicitante,pUsuarioSolicitante,pAreaResponsable,pUsuarioResponsable,0,CURRENT,CURRENT,iReintentos,pCte,pCta,
							pCveTransaccion,pDoctoCheque,pImporte,pReferencia,pSucursal,pUsuarioRev,pFolioReverso,pCveBloqueo,pOptBloqueo,pAreaSolicitanteBloqueo,pMotivoBloqueo,
							pAreaPersonaSolicita,pMotivoBloqueoDesbloqueo,pFechaVencimiento,pCuentaReferencia,pInstruccionVencimiento,pTipoBloqueo,pCausaBloqueo,pConcepto,pObservaciones,pMotivoCancelacion,pFechaDel,pFechaAl,pLote);

			IF DBINFO('sqlca.sqlerrd2')     = 0 THEN
					LET cCodRet = '00236';
					ROLLBACK WORK;
					RETURN cCodRet, iIdx;
			END IF;

			IF DBINFO('sqlca.sqlerrd2') = 1 THEN
					LET iIdx = DBINFO('sqlca.sqlerrd1');
			END IF;

			COMMIT;

			IF bInTransaction = 't' THEN
					BEGIN WORK;
			END IF;

			RETURN cCodRet, iIdx;
		END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/05/2014',
'DESCRIPCION: Inserta solicitud al gestor de operaciones en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/12/2014',
'DESCRIPCION: Se modifica para insertar fecha cambio y hora cambio para control de cambios status en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 17/02/2014',
'DESCRIPCION: modificaciÃ³n en tabla sw_gs_registrosolicitud, se agregan columnas area_persona_solicita y motivo_bloqueo_desbloqueo',
'para el tratado del bloqueo y desbloqueo de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_registrosolicitudhistorico(pOperacion INTEGER)
        RETURNING CHAR(5) AS codret,
                          INTEGER AS totalReg;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE bInTransaction BOOLEAN;
        DEFINE iTotReg INTEGER;
        DEFINE iIdRegistroSolicitud INTEGER;
        DEFINE iFolioSolicitud BIGINT;
        DEFINE iIdSolicitud INTEGER;
        DEFINE dFechaSolicitud DATE;
        DEFINE iIdAreaSolicitante INTEGER;
        DEFINE cUsuarioSolicitante CHAR(8);
        DEFINE iIdAreaResponsable INTEGER;
        DEFINE cUsuarioResponsable CHAR(8);
        DEFINE iIdStatusSolicitud INTEGER;
        DEFINE dFechaCambio DATETIME YEAR to FRACTION(3);
        DEFINE dHoraCambio DATETIME HOUR to FRACTION(3);
        DEFINE iCodError CHAR(5);
        DEFINE cDescError CHAR(100);
        DEFINE iIdMotivoCancelacion INTEGER;
        DEFINE cFolioTransaccion CHAR(16);
        DEFINE dFechaAtencion DATE;
        DEFINE iNumReintentos INTEGER;
        DEFINE bStatus BOOLEAN;
        DEFINE cCliente CHAR(20);
        DEFINE cCuenta CHAR (20);
        DEFINE cClaveTransaccion CHAR(4);
        DEFINE iDocumentoCheque INTEGER;
        DEFINE dImporte DECIMAL(16,2);
        DEFINE cReferencia CHAR(40);
        DEFINE cSucursal CHAR(4);
        DEFINE cUsuarioRev CHAR(8);
        DEFINE cFolioReverso CHAR(16);
        DEFINE iClaveBloqueo INTEGER;
        DEFINE iOpcionBloqueo INTEGER;
        DEFINE iAreaSolicitanteBloqueo INTEGER;
        DEFINE iMotivoBloqueo INTEGER;
		DEFINE cAreaPersonaSolicita CHAR(150);
		DEFINE cMotivoBloqueoDesbloqueo CHAR(150);
        DEFINE dFechaVencimiento DATE;
        DEFINE cCuentaReferencia CHAR(20);
        DEFINE iInstruccionVencimiento INTEGER;
        DEFINE iTipoBloqueo INTEGER;
        DEFINE iCausaBloqueo INTEGER;
        DEFINE cConcepto CHAR(2);
        DEFINE cObservaciones CHAR(50);
        DEFINE iMotivoCancelacion INTEGER;
        DEFINE dFechaDel DATE;
        DEFINE dFechaAl DATE;
        DEFINE cNombreReporte CHAR(80);
        DEFINE iLote INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET bInTransaction='f';
        LET iTotReg = 0;
        LET iIdRegistroSolicitud = 0;
        LET iFolioSolicitud = 0;
        LET iIdSolicitud = 0;
        LET dFechaSolicitud = NULL;
        LET iIdAreaSolicitante = 0;
        LET cUsuarioSolicitante = '';
        LET iIdAreaResponsable = 0;
        LET cUsuarioResponsable = '';
        LET iIdStatusSolicitud = 0;
        LET dFechaCambio = NULL;
        LET dHoraCambio = NULL;
        LET iCodError = '';
        LET cDescError = '';
        LET iIdMotivoCancelacion = 0;
        LET cFolioTransaccion = '';
        LET dFechaAtencion = NULL;
        LET iNumReintentos = 0;
        LET bStatus = 'f';
        LET cCliente = '';
        LET cCuenta = '';
        LET cClaveTransaccion = '';
        LET iDocumentoCheque = 0;
        LET dImporte = 0;
        LET cReferencia = '';
        LET cSucursal = '';
        LET cUsuarioRev = '';
        LET cFolioReverso = '';
        LET iClaveBloqueo = 0;
        LET iOpcionBloqueo = 0;
        LET iAreaSolicitanteBloqueo = 0;
        LET iMotivoBloqueo = 0;
		LET cAreaPersonaSolicita = '';
		LET cMotivoBloqueoDesbloqueo = '';
        LET dFechaVencimiento = NULL;
        LET cCuentaReferencia = '';
        LET iInstruccionVencimiento = 0;
        LET iTipoBloqueo = 0;
        LET iCausaBloqueo = 0;
        LET cConcepto = '';
        LET cObservaciones = '';
        LET iMotivoCancelacion = 0;
        LET dFechaDel = NULL;
        LET dFechaAl = NULL;
        LET cNombreReporte = '';
        LET iLote = 0;

         BEGIN
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iTotReg;
			END EXCEPTION;

			ON EXCEPTION IN (-535)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
			END EXCEPTION WITH RESUME;

			ON EXCEPTION IN (-691)
				ROLLBACK;
				LET cCodRet = '00284';

				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;

				RETURN cCodRet, iTotReg;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_registrosolicitudhistorico.out';
			--TRACE ON;

			IF pOperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotReg;
			END IF;

			BEGIN WORK;
			IF pOperacion = 1 THEN
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				FOREACH SELECT id_registro_solicitud, folio_solicitud, id_solicitud, fecha_solicitud, id_area_solicitante,
							   usuario_solicitante, id_area_responsable, usuario_responsable, id_status_solicitud, fecha_cambio, hora_cambio, cod_error, desc_error,
							   id_motivo_cancelacion, folio_transaccion, fecha_atencion, num_reintentos, status, cliente, cuenta,
							   clave_transaccion, documento_cheque, importe, referencia, sucursal, usuario_rev, folio_reverso, clave_bloqueo, opcion_bloqueo,
							   area_solicitante_bloqueo, motivo_bloqueo, area_persona_solicita, motivo_bloqueo_desbloqueo, fecha_vencimiento, cuenta_referencia, instruccion_vencimiento,
							   tipo_bloqueo, causa_bloqueo, concepto, observaciones, motivo_cancelacion, fecha_del, fecha_al, nombre_reporte, lote
						INTO iIdRegistroSolicitud,iFolioSolicitud,iIdSolicitud,dFechaSolicitud,iIdAreaSolicitante,cUsuarioSolicitante,iIdAreaResponsable,
							   cUsuarioResponsable,iIdStatusSolicitud,dFechaCambio,dHoraCambio,iCodError,cDescError,iIdMotivoCancelacion,cFolioTransaccion,dFechaAtencion,iNumReintentos,
							   bStatus,cCliente,cCuenta,cClaveTransaccion,iDocumentoCheque,dImporte,cReferencia,cSucursal,cUsuarioRev,cFolioReverso,iClaveBloqueo,iOpcionBloqueo,
							   iAreaSolicitanteBloqueo,iMotivoBloqueo,cAreaPersonaSolicita,cMotivoBloqueoDesbloqueo,dFechaVencimiento,cCuentaReferencia,iInstruccionVencimiento,iTipoBloqueo,iCausaBloqueo,
							   cConcepto,cObservaciones,iMotivoCancelacion,dFechaDel,dFechaAl,cNombreReporte,iLote
						FROM bdicnweb:sw_gs_registrosolicitud WHERE status='f' OR id_status_solicitud IN(1,2,3)

						INSERT INTO bdicnweb:sw_gs_registrosolicitud_hist(id_registro_solicitud, folio_solicitud, id_solicitud,
									fecha_solicitud, id_area_solicitante, usuario_solicitante, id_area_responsable, usuario_responsable,
									id_status_solicitud, fecha_cambio, hora_cambio, cod_error,desc_error, id_motivo_cancelacion, folio_transaccion, fecha_atencion, num_reintentos,
									status, cliente, cuenta, clave_transaccion, documento_cheque, importe, referencia, sucursal,usuario_rev, folio_reverso,
									clave_bloqueo, opcion_bloqueo, area_solicitante_bloqueo, motivo_bloqueo, area_persona_solicita, motivo_bloqueo_desbloqueo, fecha_vencimiento, cuenta_referencia,
									instruccion_vencimiento, tipo_bloqueo, causa_bloqueo, concepto, observaciones, motivo_cancelacion, fecha_del, fecha_al, nombre_reporte, lote)
						VALUES (iIdRegistroSolicitud,iFolioSolicitud,iIdSolicitud,dFechaSolicitud,iIdAreaSolicitante,cUsuarioSolicitante,iIdAreaResponsable,
									cUsuarioResponsable,iIdStatusSolicitud,dFechaCambio,dHoraCambio,iCodError,cDescError,iIdMotivoCancelacion,cFolioTransaccion,dFechaAtencion,iNumReintentos,
									bStatus,cCliente,cCuenta,cClaveTransaccion,iDocumentoCheque,dImporte,cReferencia,cSucursal,cUsuarioRev,cFolioReverso,iClaveBloqueo,iOpcionBloqueo,
									iAreaSolicitanteBloqueo,iMotivoBloqueo,cAreaPersonaSolicita,cMotivoBloqueoDesbloqueo,dFechaVencimiento,cCuentaReferencia,iInstruccionVencimiento,iTipoBloqueo,iCausaBloqueo,
									cConcepto,cObservaciones,iMotivoCancelacion,dFechaDel,dFechaAl,cNombreReporte,iLote);

				LET iTotReg = iTotReg + 1;

				END FOREACH

				IF iTotReg = 0 THEN
					LET cCodRet = '00236';
					ROLLBACK WORK;

					IF bInTransaction = 't' THEN
							BEGIN WORK;
					END IF;

					RETURN cCodRet, iTotReg;
				END IF;

				COMMIT WORK;

				--- se eliminan registros de la tabla
				SET LOCK MODE TO WAIT 3;
				BEGIN WORK;
					DELETE bdicnweb:sw_gs_registrosolicitud
					WHERE status = 'f' OR id_status_solicitud IN(1,2,3);
				COMMIT;
			END IF;

			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, iTotReg;

	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 05/06/2014',
'DESCRIPCION: Copia registros a historicos de solicitudes Canceladas=1, Rechazadas=2, Exitosas=3 y aquellos registros',
'con estatus inactivo en gestor de operaciones en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 17/02/2014',
'DESCRIPCION: modificaciÃ³n en tabla sw_gs_registrosolicitud y sw_gs_registrosolicitud_hist, se agregan columnas area_persona_solicita y motivo_bloqueo_desbloqueo',
'para el tratado del bloqueo y desbloqueo de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_reintentarsolicitud(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdRegSolicitud INTEGER)
        RETURNING CHAR(5) AS codret,
                          INTEGER AS idxRegSol;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE bInTransaction BOOLEAN;
        DEFINE iIdx INTEGER;
        DEFINE iNumReintentos INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET bInTransaction='f';
        LET iIdx = 0;
        LET iNumReintentos = 0;

         BEGIN
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdx;
			END EXCEPTION;

			ON EXCEPTION IN (-535)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
			END EXCEPTION WITH RESUME;

			ON EXCEPTION IN (-691)
				ROLLBACK;
				LET cCodRet = '00284';

				IF bInTransaction = 't' THEN
						BEGIN WORK;
				END IF;

				RETURN cCodRet, iIdx;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_reintentarsolicitud.out';
			--TRACE ON;

			---VALIDACION DE DATOS REQUERIDOS
			IF pUsuario = '' OR pIdFuncion = '' OR pIdRegSolicitud IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iIdx;
			END IF;

			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, iIdx;
			END IF;

			--CALCULAMOS REINTENTOS
			SET ISOLATION TO DIRTY READ;
			SELECT MAX(num_reintentos)
			INTO iNumReintentos
			FROM bdicnweb:'informix'.sw_gs_registrosolicitud
			WHERE id_registro_solicitud = pIdRegSolicitud;

			LET iNumReintentos = iNumReintentos + 1;

			BEGIN WORK;

			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdicnweb:'informix'.sw_gs_registrosolicitud(folio_solicitud,id_solicitud,id_area_solicitante,usuario_solicitante,
					id_area_responsable,usuario_responsable,id_status_solicitud,fecha_cambio,hora_cambio,num_reintentos,cliente,cuenta,clave_transaccion,
					documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
					motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
					concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote)
			SELECT folio_solicitud,id_solicitud,id_area_solicitante,usuario_solicitante,
					id_area_responsable,usuario_responsable,0,CURRENT,CURRENT,iNumReintentos,cliente,cuenta,clave_transaccion,
					documento_cheque,importe,referencia,folio_reverso,clave_bloqueo,opcion_bloqueo,area_solicitante_bloqueo,
					motivo_bloqueo,area_persona_solicita,motivo_bloqueo_desbloqueo,fecha_vencimiento,cuenta_referencia,instruccion_vencimiento,tipo_bloqueo,causa_bloqueo,
					concepto,observaciones,motivo_cancelacion,fecha_del,fecha_al,lote
			FROM bdicnweb:'informix'.sw_gs_registrosolicitud WHERE id_registro_solicitud = pIdRegSolicitud AND status='t';

			IF DBINFO('sqlca.sqlerrd2') = 1 THEN
				LET iIdx = DBINFO('sqlca.sqlerrd1');
			END IF;

			IF DBINFO('sqlca.sqlerrd2')     = 0 THEN
				LET cCodRet = '00236';
				ROLLBACK WORK;
				RETURN cCodRet, iIdx;
			END IF;

			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_registrosolicitud
			SET status='f' --, fecha_cambio = CURRENT, hora_cambio=CURRENT
			WHERE id_registro_solicitud = pIdRegSolicitud;

			--Actualizamos comentarios
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:'informix'.sw_gs_comentarios
			SET id_registro_solicitud =  iIdx
			WHERE id_registro_solicitud = pIdRegSolicitud;

			COMMIT;

			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, iIdx;

	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 04/06/2014',
'DESCRIPCION: Reintenta solicitud para atender en gestor de operaciones en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/12/2014',
'DESCRIPCION: Se modifica para insertar fecha cambio y hora cambio para control de cambios status en SOCWEB',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 17/02/2014',
'DESCRIPCION: modificaciÃ³n en tabla sw_gs_registrosolicitud y sw_gs_registrosolicitud_hist, se agregan columnas area_persona_solicita y motivo_bloqueo_desbloqueo',
'para el tratado del bloqueo y desbloqueo de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reportefechaclaveblodescre(pUsuario CHAR(8), pIdFuncion CHAR(10), pOpcion SMALLINT, pFechaInicio DATE, pFechaFin DATE, pClave INTEGER)
        RETURNING CHAR(5) AS codret, 
                        CHAR(3)   AS empresa, 
                    CHAR(20)  AS cuenta, 
                    CHAR(9)   AS cliente, 
                    CHAR(50)  AS nombre, 
                    CHAR(4)   AS sucursal, 
                    CHAR(30)  AS bloqueo,
                    CHAR(50)  AS causa,    
                    CHAR(2)   AS estatus, 
                    DATE      AS fecha_bloq,
					DECIMAL(18, 2) AS saldo_capital,
					CHAR(60)  AS persona_aplica,
					CHAR(150) AS area_solicita,
					CHAR(150) AS justificacion;
                        
        --DEFINICION DE VARIABLES
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRet INTEGER;
        DEFINE iSqlErr INTEGER;
    DEFINE cEmpresa CHAR(3);    
        DEFINE cCuenta CHAR(20);        
        DEFINE cCliente CHAR(9);                
        DEFINE cNombre CHAR(50);        
        DEFINE cSucursal CHAR(4);       
        DEFINE cBloqueo CHAR(30);       
        DEFINE cCausa CHAR(50);         
        DEFINE cEstatus CHAR(2);        
        DEFINE dFechaBloq DATE;
	DEFINE dSaldoCapital DECIMAL(18, 2);
	DEFINE cPersonaAplica CHAR(60);
	DEFINE cAreaSolicita CHAR(150);
	DEFINE cJustificacion CHAR(150);

        --INICIALIZACION DE VARIABLES
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iCodRet = 0;
        LET iSqlErr = 0;
    LET cEmpresa = '';
        LET cCuenta = '';
        LET cCliente = ''; 
        LET cNombre = '';
        LET cSucursal = '';
        LET cBloqueo = '';
        LET cCausa = '';  
        LET cEstatus = ''; 
        LET dFechaBloq = NULL;
	LET dSaldoCapital = NULL;
	LET cPersonaAplica = '';
	LET cAreaSolicita = '';
	LET cJustificacion = '';
	
        BEGIN
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                    RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_reportefechaclaveblodescre.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pOpcion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion;
                END IF;
                
                IF pOpcion NOT IN (1, 2) THEN
                        LET cCodRet = '00044';
                        RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion;
                END IF;
                
                IF pOpcion = 1 THEN
                        IF pClave IS NULL THEN  
                                LET cCodRet = '00003';
                                RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion;
                        END IF;
                ELIF pOpcion = 2 THEN
                        IF pFechaInicio IS NULL OR pFechaFin IS NULL THEN
                                LET cCodRet = '00003';
                                RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion;
                        END IF;
                END IF;
                
                -- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion;
                END IF;
                
                IF pOpcion = '1' THEN -- If pOpcion = 1: CLAVE
                        FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultaclave('001', pClave)
                                        INTO cCodRetSp, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion
                                        
                                        LET iCodRet = cCodRetSp::INTEGER;
                                        IF iCodRet < 0 THEN
                                                RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultaclave';
                                        END IF;
                                        
                                        RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion WITH RESUME;
                        END FOREACH;
                        
                        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                                LET cCodRet = '00017';
                                RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion;
                        END IF;
                ELIF pOpcion = '2' THEN -- If pOpcion = 2: PERIODO
                        FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultafecha(pFechaInicio, pFechaFin)
                                        INTO cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion
                                        LET iCodRet = cCodRetSp::INTEGER;
                                        IF iCodRet < 0 THEN
                                                RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultafecha';
                                        END IF
                                        
                                        RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion WITH RESUME;
                        END FOREACH;
                        
                        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                                LET cCodRet = '00017';
                                RETURN cCodRet, cEmpresa, cCuenta, cCliente, cNombre, cSucursal, cBloqueo, cCausa, cEstatus, dFechaBloq, dSaldoCapital, cPersonaAplica, cAreaSolicita, cJustificacion;
                        END IF;
                        
                END IF;
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 07/03/2014',
'DESCRIPCION: Genera un reporte de bloqueo y desbloqueo de las Cuentas de Credito, SOCWEB',
'AUTOR: Oscar Flores Conde',
'FECHA: 18/02/2015',
'DESCRIPCION: Se agrega a la salida el saldo capital, el ejecutivo que aplico, el area que solicita y la justificacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_calificacion_scoring(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pSeccion SMALLINT)
		RETURNING CHAR(5) AS codret,
				DECIMAL(5, 2) AS evaluacion;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dEvaluacion DECIMAL(5, 2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dEvaluacion = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dEvaluacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_calificacion_scoring.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' OR pSeccion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dEvaluacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dEvaluacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT evaluacion
		INTO dEvaluacion
		FROM bdisolic:'informix'.ss_resumen_scoring
		WHERE empresa = cEmpresa
			AND num_solicitud = pNumSolicitud
			AND seccion = pSeccion;
		
		IF dEvaluacion IS NULL THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, dEvaluacion;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 04/07/2015',
'MODULO: Creditos',
'FUNCIONALIDAD: Consulta de Solicitudes/Cambio de estatus (Monitor de solicitudes)',
'DESCRIPCION: Consulta la evaluaciÃ³n del resumen de scoring dado una secciÃ³n para una solicitud',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaparametros(pUsuario CHAR(8), pIdFuncion CHAR(10), pValorParametro CHAR(60), pTipoBusqueda SMALLINT, pSistemaCuenta CHAR(2))
	RETURNING CHAR(5) AS codret,
			CHAR(100) AS resultado_busqueda;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cValor = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaparametros.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR TRIM(pValorParametro) = '' OR pTipoBusqueda IS NULL OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValor;
		END IF;
		
		IF pTipoBusqueda NOT IN (1, 2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cValor;
		END IF;
		
		IF pSistemaCuenta NOT IN ('00', '01', '03', '06') THEN
			LET cCodRet = '00048';
			RETURN cCodRet, cValor;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		IF pSistemaCuenta = '00' THEN
			IF pTipoBusqueda = 1 THEN
				SELECT valor
				INTO cValor
				FROM bdinteg:"informix".si_param
				WHERE cod_param = pValorParametro;
				
				RETURN cCodRet, TRIM(cValor);
			ELIF pTipoBusqueda = 2 THEN
				SELECT valor
				INTO cValor
				FROM bdinteg:"informix".si_param
				WHERE descripcion = pValorParametro;
				
				RETURN cCodRet, TRIM(cValor);
			END IF;
		ELIF pSistemaCuenta = '01' THEN
			IF pTipoBusqueda = 1 THEN
				SELECT valor
				INTO cValor
				FROM bdicheq:"informix".sc_param
				WHERE codparam = pValorParametro;
				
				RETURN cCodRet, TRIM(cValor);
			ELIF pTipoBusqueda = 2 THEN
				SELECT valor
				INTO cValor
				FROM bdicheq:"informix".sc_param
				WHERE descripcion = pValorParametro;
				
				RETURN cCodRet, TRIM(cValor);
			END IF;
		ELIF pSistemaCuenta = '03' THEN
			IF pTipoBusqueda = 1 THEN
				SELECT valor
				INTO cValor
				FROM bdinvers:"informix".sv_param
				WHERE codparam = pValorParametro;
				
				RETURN cCodRet, TRIM(cValor);
			ELIF pTipoBusqueda = 2 THEN
				SELECT valor
				INTO cValor
				FROM bdinvers:"informix".sv_param
				WHERE descripcion = pValorParametro;
				
				RETURN cCodRet, TRIM(cValor);
			END IF;
		ELIF pSistemaCuenta = '06' THEN
			IF pTipoBusqueda = 1 THEN
				SELECT valor
				INTO cValor
				FROM bdicred:"informix".sd_param
				WHERE cod_param = pValorParametro;
				
				RETURN cCodRet, TRIM(cValor);
			ELIF pTipoBusqueda = 2 THEN
				SELECT valor
				INTO cValor
				FROM bdicred:"informix".sd_param
				WHERE descripcion = pValorParametro;
				
				RETURN cCodRet, TRIM(cValor);
			END IF;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 27/01/2014',
'DESCRIPCION: Consulta paramentros de tablas dependiendo del sistema cuenta: pTipoBusqeuda = 1 para buscar por codigo de parametro, 2 = por descripcion del parametro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogocajageneral(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS cIdProvCaja,
            CHAR(30) AS cDescCaja;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdProvCaja CHAR(4);
    DEFINE cDescCaja CHAR(30);
	DEFINE cPlazaCaja CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdProvCaja = '';
	LET cDescCaja = '';
	LET cPlazaCaja = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocajageneral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;
		
		--SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		 
		-- COMBOBOX CAJA GENERAL 
		IF pTipo = '1' THEN --Por codigo
		
			FOREACH		
				SELECT cod_proveedor, descripcion, plaza 
				INTO cIdProvCaja, cDescCaja, cPlazaCaja FROM bdisuc:'informix'.ss_proveedores ORDER BY descripcion
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		ELIF pTipo = '2' THEN --Por descripcion
		
			FOREACH	 
				SELECT cod_proveedor, descripcion, plaza
				INTO cIdProvCaja, cDescCaja, cPlazaCaja FROM bdisuc:'informix'.ss_proveedores ORDER BY descripcion
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 07/01/2015',
'DESCRIPCION: SPL, que hace la consulta para el llenado del combobox caja general, Monitor de Operaciones Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoperacionescaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(2))
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS cIdMostrar,
			CHAR(35) AS cDescMostrar;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdMostrar CHAR(4);
	DEFINE cDescMostrar CHAR(35);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdMostrar = '';
	LET cDescMostrar = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdMostrar, cDescMostrar;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoperacionescaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdMostrar, cDescMostrar;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdMostrar, cDescMostrar;
		END IF;
		
		--SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		
		-- COMBOBOX MOSTRAR POR	
		IF pTipoSucursal = 'S' THEN
			FOREACH
				SELECT codigo,descripcion 
				INTO cIdMostrar,cDescMostrar 
				FROM bdisuc:'informix'.ss_param_cajagen
				WHERE codigo IN('0001','0002','0003','0004','0010') ORDER BY descripcion
				RETURN cCodret, cIdMostrar, UPPER(cDescMostrar) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodret, cIdMostrar, UPPER(cDescMostrar);
			END IF;
		ELIF pTipoSucursal = 'C' THEN
			FOREACH
				SELECT codigo,descripcion 
				INTO cIdMostrar,cDescMostrar
				FROM bdisuc:'informix'.ss_param_cajagen
				WHERE codigo IN('0036','0041') ORDER BY descripcion
				RETURN cCodret, cIdMostrar, UPPER(cDescMostrar) WITH RESUME;				
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodret, cIdMostrar, UPPER(cDescMostrar);
			END IF;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 07/01/2015',
'DESCRIPCION: SPL, que hace la consulta para el llenado del combobox mostrar por, Monitor de Operaciones Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_portanom_generacionarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaRegistro DATE)
		RETURNING CHAR(5) AS codret,
				INTEGER AS total_solicitudes,
				CHAR(80) AS ruta_archivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cRutaArchivo CHAR(80);
	DEFINE cArchivo CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET cRutaArchivo = '';
	LET cArchivo = 'sporta40137E'||TO_CHAR(CURRENT, '%Y%m%d%M%S');
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros, cRutaArchivo;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_portanom_generacionarchivo.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaRegistro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros, cRutaArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros, cRutaArchivo;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:'informix'.sp_generarchivoportab(pFechaRegistro, cArchivo)
		INTO cCodRetSp, iNoRegistros, cRutaArchivo;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:'informix'.sp_generarchivoportab";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003'; -- OCURRIO UN PROBLEMA EN LA GENERACIÃN DEL ARCHIVO
		END IF;
		
		RETURN cCodRet, iNoRegistros, cRutaArchivo; 
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 08/09/2015',
'MODULO: Operaciones',
'FUNCIONALIDAD: Portabilidad de nomina - Solicitudes',
'DESCRIPCION: CreaciÃ³n de archivos con las solicitudes previamente consultadas para el proceso de portabilidad de nominaa',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_portanom_reporte_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicial DATE, pFechaFinal DATE, pTipoSolicitud INTEGER)
		RETURNING CHAR(5) AS codret,
				INTEGER AS no_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_portanom_reporte_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pTipoSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:'informix'.sp_rptportab2_totales(pFechaInicial, pFechaFinal, pTipoSolicitud)
		INTO cCodRetSp, iNoRegistros;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:'informix'.sp_rptportab2_totales";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00450';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 09/10/2015',
'MODULO: Operaciones',
'FUNCIONALIDAD: Portabilidad de nomina - Reportes',
'DESCRIPCION: Realiza la consulta del total de las solicitudes indicadas en el rango de fehcas y tipo de solicitud',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultareportecomprascaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicial DATE, pFechaFinal DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret, 
			CHAR(8) AS cFolioOperacion,
			DATE AS dFechaOperacion,
			CHAR(8) AS cOperacion,
			CHAR(12) AS cInstitucion,
			CHAR(30) AS cCajaGeneral,
			CHAR(4) AS cCC,
			CHAR(8) AS cDenominacion,
			MONEY(14,2) AS mTotal20,
			MONEY(14,2) AS mTotal50,
			MONEY(14,2) AS mTotal100,
			MONEY(14,2) AS mTotal200,
			MONEY(14,2) AS mTotal500,
			MONEY(14,2) AS mTotal1000,
			MONEY(14,2) AS mTotalBilletes,
			MONEY(14,2) AS mTotalMoneda,
			MONEY(14,2) AS mTotalGeneral;		
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cFolioOperacion CHAR(8);
		DEFINE dFechaOperacion DATE;
		DEFINE cCodTrans CHAR(4);
		DEFINE cOperacion CHAR(8);
		DEFINE cInstitucion CHAR(12);
		DEFINE cCajaGeneral CHAR(30);
		DEFINE cProcedencia CHAR(4);
		DEFINE cCC CHAR(4);
		DEFINE cDenominacion CHAR(8);
		DEFINE mTotal20 MONEY(14,2);
		DEFINE mTotal50 MONEY(14,2);
		DEFINE mTotal100 MONEY(14,2);
		DEFINE mTotal200 MONEY(14,2);
		DEFINE mTotal500 MONEY(14,2);
		DEFINE mTotal1000 MONEY(14,2);
		DEFINE mTotalBilletes MONEY(14,2);
		DEFINE mTotalMoneda MONEY(14,2);
		DEFINE mTotalGeneral MONEY(14,2);
		DEFINE iRecuperacion INTEGER; 
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cFolioOperacion = '';
		LET dFechaOperacion = '';
		LET cCodTrans = '';
		LET cOperacion = '';
		LET cInstitucion = '';
		LET cCajaGeneral = '';
		LET cProcedencia = '';
		LET cCC = '';
		LET cDenominacion = '';
		LET mTotal20 = NULL;
		LET mTotal50 = NULL;
		LET mTotal100 = NULL;
		LET mTotal200 = NULL;
		LET mTotal500 = NULL;
		LET mTotal1000 = NULL;
		LET mTotalBilletes = NULL;
		LET mTotalMoneda = NULL;
		LET mTotalGeneral = NULL;
        LET iRecuperacion = 0; 
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, UPPER(cOperacion), UPPER(cInstitucion), UPPER(cCajaGeneral), cCC, UPPER(cDenominacion), 
				mTotal20, mTotal50, mTotal100, mTotal200, mTotal500, mTotal1000, mTotalBilletes, mTotalMoneda, mTotalGeneral;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultareportecomprascaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, UPPER(cOperacion), UPPER(cInstitucion), UPPER(cCajaGeneral), cCC, UPPER(cDenominacion), 
				mTotal20, mTotal50, mTotal100, mTotal200, mTotal500, mTotal1000, mTotalBilletes, mTotalMoneda, mTotalGeneral;
            END IF;
			
			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, UPPER(cOperacion), UPPER(cInstitucion), UPPER(cCajaGeneral), cCC, UPPER(cDenominacion), 
				mTotal20, mTotal50, mTotal100, mTotal200, mTotal500, mTotal1000, mTotalBilletes, mTotalMoneda, mTotalGeneral;
			END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, UPPER(cOperacion), UPPER(cInstitucion), UPPER(cCajaGeneral), cCC, UPPER(cDenominacion), 
				mTotal20, mTotal50, mTotal100, mTotal200, mTotal500, mTotal1000, mTotalBilletes, mTotalMoneda, mTotalGeneral;
			END IF;
			
			SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;
			
			-- INSTITUCION
			LET cInstitucion = ''; --'NO HAY DATO'
			LET cCC = '';		   --'NO HAY DATO'
			LET cDenominacion = 'MONTO';
			
			FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT NVL(ope.folio_oper,''), NVL(ope.fecha_operacion,''), NVL(ope.cod_trans,''), NVL(pro.descripcion,''), NVL(ope.procedencia,''), 
			    NVL((ope.cantidad_6 * ope.denominacion_6::INTEGER),0) AS total_6,
				NVL((ope.cantidad_5 * ope.denominacion_5::INTEGER),0) AS total_5,
				NVL((ope.cantidad_4 * ope.denominacion_4::INTEGER),0) AS total_4,
				NVL((ope.cantidad_3 * ope.denominacion_3::INTEGER),0) AS total_3,
				NVL((ope.cantidad_2 * ope.denominacion_2::INTEGER),0) AS total_2,
				NVL((ope.cantidad_1 * ope.denominacion_1::INTEGER),0) AS total_1,
			    NVL(ope.cantidad_7,0)
			
				INTO cFolioOperacion, dFechaOperacion, cCodTrans, cCajaGeneral, cProcedencia,  
				mTotal20, mTotal50, mTotal100, mTotal200, mTotal500, mTotal1000,
				mTotalMoneda
				
				FROM bdisuc:"informix".ss_operaciones AS ope, bdisuc:"informix".ss_mae_entradasalida AS mae,
				bdisuc:"informix".ss_proveedores AS pro, bdisuc:"informix".ss_cajageneral AS caj
				WHERE ope.fecha_operacion BETWEEN pFechaInicial AND pFechaFinal
				AND ope.cod_trans = '0004'
				AND ope.folio_oper = mae.folio_oper
				AND mae.cod_proveedor = pro.cod_proveedor
				AND pro.cod_proveedor = caj.cod_proveedor
			
				-- DEFINE OPERACION
				IF cCodTrans = '0003' THEN
					LET cOperacion = 'VENTA';
				ELIF cCodTrans = '0004' THEN
					LET cOperacion = 'COMPRA';
				END IF;
				
				LET mTotalBilletes = mTotal20 + mTotal50 + mTotal100 + mTotal200 + mTotal500 + mTotal1000;
				LET mTotalGeneral = mTotalBilletes + mTotalMoneda;
			
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, UPPER(cOperacion), UPPER(cInstitucion), UPPER(cCajaGeneral), cCC, UPPER(cDenominacion), 
				mTotal20, mTotal50, mTotal100, mTotal200, mTotal500, mTotal1000, mTotalBilletes, mTotalMoneda, mTotalGeneral WITH RESUME;
				LET iRecuperacion = iRecuperacion + 1;
			END FOREACH;
			
			IF iRecuperacion = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00151'; 
				ELIF pRegistros > 0 THEN
					LET cCodRet = '1001'; 
				END IF;
				
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, UPPER(cOperacion), UPPER(cInstitucion), UPPER(cCajaGeneral), cCC, UPPER(cDenominacion), 
				mTotal20, mTotal50, mTotal100, mTotal200, mTotal500, mTotal1000, mTotalBilletes, mTotalMoneda, mTotalGeneral;
			END IF;
				
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/03/2015',
'DESCRIPCION: SPL que realiza la consulta de los detalles de ventas de efectivo.',
'FUNCIONALIDAD: Compras y DepÃ³sitos Caja General', 
'MODULO: Caja General',
'AUTOR: Oscar Flores Conde',
'FECHA: 22/09/2015',
'DESCRIPCION: Se agregan parametros de paginaciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultareporteventascaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicial DATE, pFechaFinal DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		
		RETURNING CHAR(5) AS codret, 
			CHAR(8) AS cFolioOperacion,
			DATE AS dFechaOperacion,
			CHAR(8) AS cOperacion,
			CHAR(12) AS cInstitucion,
			CHAR(30) AS cCajaGeneral,
			CHAR(4) AS cCC,
			MONEY(14,2) AS mImporteTotal;		
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cFolioOperacion CHAR(8);
		DEFINE dFechaOperacion DATE;
		DEFINE cOperacion CHAR(8);
		DEFINE cInstitucion CHAR(12);
		DEFINE cCajaGeneral CHAR(30);
		DEFINE cProcedencia CHAR(4);
		DEFINE cCC CHAR(4);
		DEFINE mImporteTotal MONEY(14,2);
		DEFINE cCodTrans CHAR(4);
		DEFINE iRecuperacion INTEGER; 
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cFolioOperacion = '';
		LET dFechaOperacion = '';
		LET cOperacion = '';
		LET cInstitucion = '';
		LET cCajaGeneral = '';
		LET cProcedencia = '';
		LET cCC = '';
		LET mImporteTotal = NULL;
		LET cCodTrans = '';
        LET iRecuperacion = 0; 
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, cOperacion, cInstitucion, cCajaGeneral, cCC, mImporteTotal;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultareporteventascaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, cOperacion, cInstitucion, cCajaGeneral, cCC, mImporteTotal;
            END IF;
			
			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, cOperacion, cInstitucion, cCajaGeneral, cCC, mImporteTotal;
			END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, cOperacion, cInstitucion, cCajaGeneral, cCC, mImporteTotal;
			END IF;
			
			SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;
			
			-- INSTITUCION
			LET cInstitucion = ''; --'NO HAY DATO'
			LET cCC = '';		   --'NO HAY DATO'
			
			FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT NVL(ope.folio_oper,''), NVL(ope.fecha_operacion,''), NVL(ope.cod_trans,''), NVL(pro.descripcion,''), NVL(ope.procedencia,''), NVL(ope.monto,0)
				INTO cFolioOperacion, dFechaOperacion, cCodTrans, cCajaGeneral, cProcedencia, mImporteTotal 
				FROM bdisuc:"informix".ss_operaciones AS ope, bdisuc:"informix".ss_mae_entradasalida AS mae,
				bdisuc:"informix".ss_proveedores AS pro
				WHERE ope.fecha_operacion BETWEEN pFechaInicial AND pFechaFinal
				AND ope.cod_trans = '0003' 
				AND ope.folio_oper = mae.folio_oper
				AND mae.cod_proveedor = pro.cod_proveedor
			
				-- DEFINE OPERACION
				IF cCodTrans = '0003' THEN
					LET cOperacion = 'VENTA';
				ELIF cCodTrans = '0004' THEN
					LET cOperacion = 'COMPRA';
				END IF;
			
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, UPPER(cOperacion), UPPER(cInstitucion), UPPER(cCajaGeneral), cCC, mImporteTotal WITH RESUME;
				LET iRecuperacion = iRecuperacion + 1;
			END FOREACH;	
			
			IF iRecuperacion = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00151'; 
				ELIF pRegistros > 0 THEN					
					LET cCodRet = '1001';
				END IF;
				RETURN cCodRet, cFolioOperacion, dFechaOperacion, cOperacion, cInstitucion, cCajaGeneral, cCC, mImporteTotal;
			END IF;
				
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/03/2015',
'DESCRIPCION: SPL que realiza la consulta de los detalles de ventas de efectivo.',
'AUTOR: Oscar Flores Conde',
'FECHA: 23/09/2015',
'DESCRIPCION: Se agregan parametros de paginaciÃ³n',
'FUNCIONALIDAD: Compras y DepÃ³sitos Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultareporter24d(pUsuario CHAR(8), pIdFuncion CHAR(10), pMes CHAR(2), pAnio CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR (4) AS transaccion,
				MONEY(18,2) AS monto,
				INTEGER AS num_transaccion;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cTransaccion CHAR(4);
	DEFINE mMonto MONEY;
	DEFINE iNumTransaccion INTEGER;
	DEFINE dFechaInicio DATE;
	DEFINE dFechaFin DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cTransaccion = '';
	LET mMonto = 0;
	LET iNumTransaccion = 0;
	LET dFechaInicio = NULL;
	LET dFechaFin = NULL;

	BEGIN
	
		ON EXCEPTION SET iSqlErr    
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTransaccion, mMonto, iNumTransaccion;
		END EXCEPTION;
		
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultareporter24d.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pMes = '' OR pAnio= '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTransaccion, mMonto, iNumTransaccion;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, ctransaccion, mMonto, iNumTransaccion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTransaccion, mMonto, iNumTransaccion;
		END IF;
		
		-- Fecha Inicial
		LET dFechaInicio = MDY(pMes::INTEGER, 1, pAnio::INTEGER);
		-- Fecha Final
		LET dFechaFin = LAST_DAY(dFechaInicio);
		
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion transaccion, SUM(monto) AS monto, SUM(numtransacc) AS num_transacc
			INTO cTransaccion, mMonto, iNumTransaccion
			FROM bdicheq:"informix".sc_valr24d
			WHERE fecha BETWEEN dFechaInicio AND dFechaFin
			GROUP BY 1
			
			LET  iNoRegistros = iNoRegistros + 1;
			
			RETURN cCodRet, cTransaccion, mMonto, iNumTransaccion WITH RESUME;
		END FOREACH
	
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cTransaccion, mMonto, iNumTransaccion ;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cTransaccion, mMonto, iNumTransaccion ;
		END IF;

	END;
	
END PROCEDURE

DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 30/07/2015',
'MODULO: Debito',
'FUNCIONALIDAD: Generar el reporte regulatorio R24D.',
'DESCRIPCION: Consulta de las transacciones con sus rangos de fechas correspondientes ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultafechasr24d(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				CHAR(2) AS mes,
				CHAR(4) AS anio,
				CHAR(15) AS descrip_mes;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cMes CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cDescripcionMes CHAR(15);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cMes = '';
	LET cAnio = '';
	LET cDescripcionMes = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMes, cAnio, cDescripcionMes;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultafechasr24d.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMes, cAnio, cDescripcionMes;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMes, cAnio, cDescripcionMes;
		END IF;
		
		FOREACH SELECT TO_CHAR(fecha, "%m") AS mes, TO_CHAR(fecha, "%Y") AS anio,
				DECODE(TO_CHAR(fecha, "%m"), "01", "ENERO", "02", "FEBRERO", "03", "MARZO",
                                 "04", "ABRIL", "05", "MAYO", "06", "JUNIO",
                                 "07", "JULIO", "08", "AGOSTO", "09", "SEPTIEMBRE",
                                 "10", "OCTUBRE", "11", "NOVIEMBRE", "12", "DICIEMBRE") AS desc_mes
				INTO cMes, cAnio, cDescripcionMes
				FROM bdicheq:"informix".sc_valr24d
				GROUP BY 1,2,3
				ORDER BY 2 DESC, 1 DESC
				
			LET iNoRegistros = iNoRegistros + 1;

			RETURN cCodRet, cMes, cAnio, cDescripcionMes WITH RESUME;
		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cMes, cAnio, cDescripcionMes;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 29/07/2015',
'MODULO: DEBITO',
'FUNCIONALIDAD: Generar el reporte regulatorio R24D.',
'DESCRIPCION: Consulta de fechas de la tabla sc_valr24d para la generacion del reporte',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 19/10/2015',
'DESCRIPCION: Se realizÃ³ la modificaciÃ³n para obtener la agrupaciÃ³n y el ordenamiento de la consulta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_admintransaciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1), pSistemaCuenta CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)

		RETURNING CHAR(5) AS codret,
		CHAR (4) AS numero_transaccion,
		CHAR (50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cTransaccion CHAR (4);
	DEFINE cDescripcion CHAR (50);
	DEFINE bRegulatorios BOOLEAN;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	lET cTransaccion = '';
	lET cDescripcion = '';
	LET bRegulatorios = 'f';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTransaccion, cDescripcion;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_admintransaciones.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pTipoOperacion = '' OR pSistemaCuenta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTransaccion, cDescripcion;
		END IF;
		
		-- Validación del tipo de operacion
		IF pTipoOperacion NOT IN ('0', '1') THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cTransaccion, cDescripcion;
		END IF;
		
		IF pSistemaCuenta NOT IN ('01', '03', '06') THEN
			LET cCodRet = '00037';
			RETURN cCodRet, cTransaccion, cDescripcion;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cTransaccion, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTransaccion, cDescripcion;
		END IF;
		
		IF pTipoOperacion = '1' THEN
			LET bRegulatorios = 't';
		end if;
		
		IF bRegulatorios THEN
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion 
					numero, descripcion   -- <= 68 registros
				INTO cTransaccion, cDescripcion
				FROM bdinteg:"informix".si_transacc
				WHERE regulatorios = '1'
					AND sistema = pSistemaCuenta
				
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cTransaccion, UPPER(cDescripcion) WITH RESUME;

			end foreach;
		ELSE
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion 
				numero, descripcion   -- <= 68 registros
				INTO cTransaccion, cDescripcion
				FROM bdinteg:"informix".si_transacc
				WHERE (regulatorios IS NULL OR regulatorios = '0')
					AND sistema = pSistemaCuenta
				
				LET iNoRegistros = iNoRegistros + 1;				
				RETURN cCodRet, cTransaccion, UPPER(cDescripcion) WITH RESUME;

			end foreach;
		
		END IF;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cTransaccion, cDescripcion;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cTransaccion, cDescripcion;
		END IF;
			
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/08/2015',
'MODULO: Debito',
'FUNCIONALIDAD: Generar el reporte regulatorio R24D.',
'DESCRIPCION: Consulta de los Catalogos correspondientes 0 = Catalogo de Captacion y 1= Transacciones R24D ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualiza_admintransaciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pTransaccion CHAR(4), pSistemaCuenta CHAR(2), pRegulatorio CHAR (1))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_afectados;
		
	DEFINE cCodRet CHAR(5);	
	DEFINE iRegistros_afectados INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iRegistros_afectados = 0 ;
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualiza_admintransaciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pTransaccion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistros_afectados;
		END IF;
		
		IF pSistemaCuenta NOT IN ('01', '03', '06') THEN
			LET cCodRet = '00037';
			RETURN cCodRet, iRegistros_afectados;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegistros_afectados;		
		END IF;
		
		--Actualiza Catalogo 
		UPDATE bdinteg:'informix'.si_transacc 
		SET regulatorios = pRegulatorio
		WHERE numero = pTransaccion
		AND sistema = pSistemaCuenta;
			
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00458';
			RETURN cCodRet, iRegistros_afectados;
		END IF;
		IF iNoRegistros > 0 THEN
			LET iRegistros_afectados = iRegistros_afectados + 1;
			RETURN cCodRet, iRegistros_afectados;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/08/2015',
'MODULO: Debito',
'FUNCIONALIDAD: Generar el reporte regulatorio R24D.',
'DESCRIPCION: Actualizacion de Catalogo de TransccionesR24D',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultareporter24d_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pMes CHAR(2), pAnio CHAR(4))
		RETURNING CHAR(5) AS codret,
				INTEGER AS num_registros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE dFechaInicio DATE;
	DEFINE dFechaFin DATE;

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET dFechaInicio = NULL;
	LET dFechaFin = NULL;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr    
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultareporter24d_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pMes = '' OR pAnio= '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- Fecha Inicial
		LET dFechaInicio = MDY(pMes::INTEGER, 1, pAnio::INTEGER);
		-- Fecha Final
		LET dFechaFin = LAST_DAY(dFechaInicio);
		
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM 
			(SELECT transaccion, SUM(monto) AS monto, SUM(numtransacc) AS num_transacc
			FROM bdicheq:"informix".sc_valr24d
			WHERE fecha BETWEEN dFechaInicio AND dFechaFin
			GROUP BY 1);
		
		RETURN cCodRet, iNoRegistros;
	
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 30/07/2015',
'MODULO: Debito',
'FUNCIONALIDAD: Generar el reporte regulatorio R24D.',
'DESCRIPCION: Obtiene el numero total de las transacciones en el mes correspondientes ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizaregistrodevolverext_tef(pUsuario CHAR(8), pIdFuncion CHAR(10), pDatosMotDevolucion CHAR(250))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_procesados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCadenaValores CHAR(15);
	DEFINE cCadena CHAR(15);
	DEFINE iIdxDevolver INTEGER;
	DEFINE cMotivoDevolucion CHAR(2);
	DEFINE iNoRegsProcesados INTEGER;
	DEFINE iParams SMALLINT;
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCadenaValores = '';
	LET cCadena = '';
	LET iIdxDevolver = 0;
	LET cMotivoDevolucion = '';
	LET iNoRegsProcesados = 0;
	LET iParams = 0;
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_actualizaregistrodevolverext_tef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDatosMotDevolucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pDatosMotDevolucion, '|')
					INTO cCadenaValores
					
					LET iParams = 0;
					FOREACH EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(cCadenaValores, ',')
						INTO cCadena
						
						IF iParams = 0 THEN
							LET iIdxDevolver = cCadena::INTEGER;
							LET iParams = iParams + 1;
						ELIF iParams = 1 THEN
							LET cMotivoDevolucion = TRIM(cCadena);
							EXIT FOREACH;
						END IF;
						
					END FOREACH;
					
					--Actualizacion de los registros a devolver
					SET LOCK MODE TO WAIT 3;
					UPDATE bdicnweb:"informix".sw_tf_consdevext_tef
					SET motivo_devolucion = cMotivoDevolucion
					WHERE idx = iIdxDevolver;
					
					LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');	
					
			END FOREACH;
		COMMIT;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iNoRegsProcesados;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 06/08/2015',
'DESCRIPCION: Actualiza los motivos de devolucion para ejecutar la devolucion extemporanea tef',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_buscarchivosprocesarafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoBusqueda CHAR(1),
		pTipoArchivo CHAR(1), pNombreArchivo CHAR(30), pFechaInicial DATE, pFechaFinal DATE, pEstatus CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
					
		RETURNING CHAR(5) AS codret,
			CHAR(30) AS tipo_archivo,      	
			CHAR(30) AS nombre_archivo,    	
			DATE AS fecha_generacion, 		    
			CHAR(2) AS estatus,	  		    
			INTEGER AS no_movimientos,    	    
			CHAR(30) AS estado_descripcion,  	
			CHAR(32) AS estado_num_des;       	
			
		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;	
		DEFINE cEmpresa CHAR(3);
		DEFINE cMensajeRet CHAR(200);
		DEFINE cTipoArchivo CHAR(30);
		DEFINE cNombreArchivo CHAR(30);
		DEFINE dFechaGeneracion DATE;
		DEFINE cEstatus CHAR(2);
		DEFINE iNoMovimientos INTEGER;
		DEFINE cEstadoDescripcion CHAR(30);
		DEFINE cEstadoNumDes CHAR(32);
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;	
		LET cEmpresa = '001';
		LET cMensajeRet = '';
		LET cTipoArchivo = '';
		LET cNombreArchivo = '';
		LET dFechaGeneracion = '';
		LET cEstatus = '';
		LET iNoMovimientos = 0;
		LET cEstadoDescripcion = '';
		LET cEstadoNumDes = '';
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_buscarchivosprocesarafore.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoBusqueda = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
            END IF;
            
			-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
            END IF;
			
            -- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
			END IF;
			
			-- VALIDA TIPO DE BUSQUEDA
			IF pTipoBusqueda = '1' THEN
			
				LET pTipoArchivo = 'P';
				LET pNombreArchivo = '';
				LET pFechaInicial = DATE(CURRENT);
				LET pFechaFinal = DATE(CURRENT);
				LET pEstatus = '19';
				
			ELIF pTipoBusqueda = '2' THEN	
				
				IF NVL(pFechaInicial, '') = '' AND NVL(pFechaFinal, '') = '' THEN
					LET pFechaInicial = MDY(1,1,1900);
					LET pFechaFinal = MDY(1,1,1900);
                END IF
			
			END IF;
			
			FOREACH
				EXECUTE PROCEDURE bdiprog:"informix".sp_aforebuscararchivosprocesar2(pTipoArchivo,pNombreArchivo,pFechaInicial,pFechaFinal,pEstatus,pRegistros,pRecuperacion)
				INTO cCodRetSp, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes
			
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_aforebuscararchivosprocesar2';
				ELIF cCodRetSp::INTEGER > 0 THEN
					EXECUTE PROCEDURE bdiprog:"informix".sp_afore_mensajeretorno(cCodRetSp) 
					INTO cCodRetSp, cMensajeRet;
					
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_afore_mensajeretorno';
					ELIF cCodRetSp::INTEGER = 10000 THEN	
						LET cCodRet = '00481'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10001 THEN	
						LET cCodRet = '00482'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10002 THEN	
						LET cCodRet = '00483'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10003 THEN	
						LET cCodRet = '00484'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10004 THEN	
						LET cCodRet = '00485'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10005 THEN	
						LET cCodRet = '00486'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10006 THEN	
						LET cCodRet = '00487';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10007 THEN	
						LET cCodRet = '00488';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10008 THEN	
						LET cCodRet = '00489'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10009 THEN	
						LET cCodRet = '00490'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10010 THEN	
						LET cCodRet = '00491';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10011 THEN	
						LET cCodRet = '00492'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10012 THEN	
						LET cCodRet = '00493'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10013 THEN	
						LET cCodRet = '00494';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10014 THEN	
						LET cCodRet = '00438'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10015 THEN	
						LET cCodRet = '00495';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10016 THEN	
						LET cCodRet = '00496'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10017 THEN	
						LET cCodRet = '00497';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10018 THEN	
						LET cCodRet = '00498'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10019 THEN	
						LET cCodRet = '00499';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10020 THEN	
						LET cCodRet = '00500'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10021 THEN	
						LET cCodRet = '00501'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10022 THEN	
						LET cCodRet = '00496'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10023 THEN	
						LET cCodRet = '00502'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10024 THEN	
						LET cCodRet = '00503';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10025 THEN	
						LET cCodRet = '00504'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10026 THEN	
						LET cCodRet = '00505'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10027 THEN	
						LET cCodRet = '00017'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10028 THEN	
						LET cCodRet = '00506'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10029 THEN	
						LET cCodRet = '00507'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10030 THEN	
						LET cCodRet = '00508'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10031 THEN	
						LET cCodRet = '00509';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10032 THEN	
						LET cCodRet = '00510';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10549 THEN
						LET cCodRet = '00511'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10034 THEN
						LET cCodRet = '00512';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10035 THEN
						LET cCodRet = '00513'; 
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					ELIF cCodRetSp::INTEGER = 10036 THEN
						LET cCodRet = '00514';
						RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
					END IF;				
				ELSE	
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, UPPER(cTipoArchivo), UPPER(cNombreArchivo), dFechaGeneracion, cEstatus, iNoMovimientos, UPPER(cEstadoDescripcion), UPPER(cEstadoNumDes) WITH RESUME;
				END IF;
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cTipoArchivo, cNombreArchivo, dFechaGeneracion, cEstatus, iNoMovimientos, cEstadoDescripcion, cEstadoNumDes;
			END IF;	
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 02/06/2015', 
'DESCRIPCION: SPL que realiza la busqueda de los archivos que ya fueron generados y enviados por afore coppel, para poder crear', 
'las consultas correspondientes. Retorna datos como el tipo de archivo, el nombre del archivo, la fecha de creacion, el estado y el numero de movimientos.',
'Tipo de Busqueda = 1 se refiere a la busqueda para la EjecuciÃ³n de Pagos Pendientes y a la Cancelacion de Archivos', 
'Tipo de Busqueda = 2 realiza la carga de archivos para la Consulta de Archivos.',
'FUNCIONALIDAD: EjecuciÃ³n de Pagos Pendientes â Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cancelarprocejecpagosafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(30), pTipoCancelacion SMALLINT)
		
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;	
		DEFINE cHoraProceso CHAR(21);
		DEFINE cHoraServidor CHAR(21);
		DEFINE pTipoArchivo CHAR(1);
		DEFINE cMensajeRet CHAR(200);
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;	
		LET cHoraProceso = '';
		LET cHoraServidor = '';
		LET pTipoArchivo = '';
		LET cMensajeRet = '';
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_cancelarprocejecpagosafore.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pTipoCancelacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA El LIMITE DE HORARIO PERMITIDO
			SELECT valor INTO cHoraProceso FROM bdisac:"informix".sac_param WHERE cod_param = '6036';
			IF cHoraProceso = '' OR cHoraProceso IS NULL THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA LA HR DEL SERVIDOR
			EXECUTE PROCEDURE bdiprog:"informix".sp_validahoraejec('001') INTO cCodRetSp, cHoraServidor;
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_validahoraejec';
			ELIF cCodRetSp::INTEGER > 0 THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- VALIDA NOMENCLATURA			
			IF SUBSTRING(pNombreArchivo FROM 15 FOR 2) = 'OB' THEN 
				IF (cHoraServidor > cHoraProceso) THEN
					LET cCodRet = '00434';
					RETURN cCodRet;
				ELSE
					LET pTipoArchivo = '2';
				END IF;
			ELSE 
				LET pTipoArchivo = '1';
			END IF;
		 
			-- GENERA EL LLAMADO AL PROCESO DE CANCELACIÃN DE ARCHIVOS
			EXECUTE PROCEDURE bdiprog:"informix".sp_aforecancelarprocejecpagos(pNombreArchivo, pUsuario, pTipoCancelacion, pTipoArchivo) 
			INTO cCodRetSp;
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_aforecancelarprocejecpagos';
			ELIF cCodRetSp::INTEGER = 10015 THEN	
				LET cCodRet = '00003';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10024 THEN	
				LET cCodRet = '00503';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10025 THEN	
				LET cCodRet = '00504'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10026 THEN	
				LET cCodRet = '00505'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10028 THEN	
				LET cCodRet = '00506'; 
				RETURN cCodRet;
			ELSE					 
				RETURN cCodRet;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/05/2015',
'DESCRIPCION: SPL encargado de suspender de manera temporal y/o definitiva la ejecuciÃ³n del proceso automÃ¡tico', 
'que realizar la dispersiÃ³n de pagos pendientes enviados por afore coppel.',
'FUNCIONALIDAD: CancelaciÃ³n de Archivos â Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargenmanualarchivostef(pUsuario CHAR(8),pIdFuncion CHAR(10),pNombreArchivo CHAR(20),pIndicador CHAR(1))
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(100);
	DEFINE cNomArchivo CHAR(20);
	DEFINE iNoRegistros INTEGER;
	DEFINE bTransacInteract BOOLEAN;
	DEFINE codigoDocto CHAR(10);
	DEFINE bError BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET cNomArchivo = '';
	LET iNoRegistros = 0;
	LET bTransacInteract = 'f';
	LET codigoDocto ='';
	LET bError = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet;
		END EXCEPTION;
		
		---SET DEBUG FILE TO '/tmp/mfinis/sp_cargenmanualarchivostef.out';
		--SET DEBUG FILE TO '/home/systef/procesar/sp_cargenmanualarchivostef.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pIndicador = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
						
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
	
		-- CARGA DE ARCHIVOS
		IF pIndicador = 'C' THEN
			BEGIN -- INICIO DEL BLOQUE
				ON EXCEPTION IN (-535)
					LET bTransacInteract = 't';
					COMMIT WORK;
				END EXCEPTION WITH RESUME;
				
				BEGIN WORK;
			
				IF bTransacInteract = 'f' THEN
					COMMIT WORK;
				END IF;
				
				
				LET codigoDocto = SUBSTRING(TRIM(pNombreArchivo) FROM 11 FOR 2);
				-- ARCHIVO 61, 62 y 63
				IF ((SUBSTRING (TRIM(pNombreArchivo) FROM 11 FOR 2) = '61') OR (SUBSTRING (TRIM(pNombreArchivo) FROM 11 FOR 2) = '62') OR (SUBSTRING (TRIM(pNombreArchivo) FROM 11 FOR 2) = '63')) THEN
				
					FOREACH
						EXECUTE PROCEDURE bditef:"informix".sp_tef_presentador_r(pNombreArchivo,pUsuario)
						INTO cNomArchivo,cCodRetSp,cDescCodRet
						
						IF cCodRetSp::INTEGER < 0 THEN 
							--RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂN DEL SP bditef:sp_tef_presentador_r';
							LET cCodRet = cCodRetSp;
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 201 THEN
							LET cCodRet = '00521'; -- LA RUTA DEL ARCHIVO A PROCESAR NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 202 THEN
							LET cCodRet = '00522'; -- LA RUTA DEL ARCHIVO RESPUESTA NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 203 THEN
							LET cCodRet = '00523'; -- LA RUTA DE ARCHIVOS PROCESADOS NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 204 THEN
							LET cCodRet = '00524'; -- LA RUTA DE ARCHIVOS ERRONEOS NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 205 THEN
							LET cCodRet = '00525'; -- LA CLAVE BANCARIA BANCOPPEL NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 206 THEN
							LET cCodRet = '00526'; -- NO EXISTE EL BIN CORRESPONDIENTE A LA TARJETA DE DÃÂBITO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 207 THEN
							LET cCodRet = '00527'; -- NO EXISTE LA SUCURSAL CONTABLE TEF
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 208 THEN
							LET cCodRet = '00528'; -- NO EXISTE LA TRANSACCIÃÂN DE CARGO TEF
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 209 THEN
							LET cCodRet = '00529'; -- NO EXISTE LA TRANSACCIÃÂN DE ABONO TEF
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 210 THEN
							LET cCodRet = '00530'; -- EL IMPORTE MÃÂXIMO DE CECOBAN NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 212 THEN
							LET cCodRet = '00522'; -- LA RUTA DEL ARCHIVO RESPUESTA NO EXISTE (Se supone marcarÃÂ­a '00531', checar la consulta en productivo)
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 213 THEN
							LET cCodRet = '00532'; -- DIA NO LABORAL, VERIFIQUE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 214 THEN
							LET cCodRet = '00533'; -- EL PARÃÂMETRO FECHA_HOY NO SE ENCUENTRA EN LA TABLA SC_FECHA 
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 215 THEN
							LET cCodRet = '00003'; 
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 216 THEN
							LET cCodRet = '00534'; -- EL NÃÂMERO DE EMPLEADO NO CONTIENE LOS 8 DÃÂGITOS REQUERIDOS, VERIFIQUE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 217 THEN
							LET cCodRet = '00535'; -- EL NÃÂMERO DE EMPLEADO CONTIENE CARACTERES INVALIDOS, VERIFIQUE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 218 THEN
							LET cCodRet = '00481'; -- '00539'
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 219 THEN
							LET cCodRet = '00537'; -- EL ARCHIVO YA FUE PROCESADO PREVIAMENTE 
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 220 THEN
							LET cCodRet = '00538'; -- EL ARCHIVO SE ENCUENTRA PROCESANDO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 221 THEN
							LET cCodRet = '00549'; -- ERROR AL CARGAR EL ARCHIVO EN LAS TABLAS DE PASO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 222 THEN
							LET cCodRet = '00550'; -- ERROR AL VALIDAR LA INTEGRIDAD DEL ARCHIVO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 223 THEN
							LET cCodRet = '00551'; -- ERROR AL PROCESAR EL ARCHIVO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 224 THEN
							LET cCodRet = '00552'; -- ERROR AL MOVER LOS REGISTROS DEL ARCHIVO ORIGINAL AL HISTÃÂRICO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 225 THEN
							LET cCodRet = '00540'; -- ERROR AL LIMPIAR LA INFORMACIÃÂN EN LAS TABLAS DE PASO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 226 THEN
							LET cCodRet = '00553'; -- EL ARCHIVO A PROCESAR NO SE ENCUENTRA EN LA RUTA INDICADA
							LET bError = 't';
							EXIT FOREACH;
						ELSE
							LET iNoRegistros = iNoRegistros + 1;
							RETURN cCodRet WITH RESUME;
						END IF;
						
						--LET vsCodRetorno = '00162';
						--LET vsCodRetorno = '00230';
						--LET vsCodRetorno = '00261'
						--LET vsCodRetorno = '10106';
					END FOREACH;
					
					IF bTransacInteract = 't' THEN
							BEGIN WORK;
					END IF;
					
					IF bError = 't' THEN
						RETURN cCodRet;
					END IF;
					
				-- ARCHIVO 10 y 60
				ELIF ((SUBSTRING (TRIM(pNombreArchivo) FROM 11 FOR 2) = '10') OR (SUBSTRING (TRIM(pNombreArchivo) FROM 11 FOR 2) = '60')) THEN
			
					FOREACH
						EXECUTE PROCEDURE bditef:"informix".sp_tef_receptor_r(pNombreArchivo,pUsuario)
						INTO cNomArchivo,cCodRetSp,cDescCodRet
						
						IF cCodRetSp::INTEGER < 0 THEN 
							RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂN DEL SP bditef:sp_tef_receptor_r';
						ELIF cCodRetSp::INTEGER = 401 THEN
							LET cCodRet = '00521'; -- LA RUTA DEL ARCHIVO A PROCESAR NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 402 THEN
							LET cCodRet = '00522'; -- LA RUTA DEL ARCHIVO RESPUESTA NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 403 THEN
							LET cCodRet = '00523'; -- LA RUTA DE ARCHIVOS PROCESADOS NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 404 THEN
							LET cCodRet = '00524'; -- LA RUTA DE ARCHIVOS ERRONEOS NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 405 THEN
							LET cCodRet = '00525'; -- LA CLAVE BANCARIA BANCOPPEL NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 406 THEN
							LET cCodRet = '00526'; -- NO EXISTE EL BIN CORRESPONDIENTE A LA TARJETA DE DÃÂBITO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 407 THEN
							LET cCodRet = '00527'; -- NO EXISTE LA SUCURSAL CONTABLE TEF
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 408 THEN
							LET cCodRet = '00528'; -- NO EXISTE LA TRANSACCIÃÂN DE CARGO TEF
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 409 THEN
							LET cCodRet = '00529'; -- NO EXISTE LA TRANSACCIÃÂN DE ABONO TEF
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 410 THEN
							LET cCodRet = '00530'; -- EL IMPORTE MÃÂXIMO DE CECOBAN NO EXISTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 412 THEN
							LET cCodRet = '00531'; -- NO EXISTEN REGISTROS PARA LA CLAVE DEL PRODUCTO EN LA TABLA TEF_PROD_PERMITIDOS 
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 413 THEN
							LET cCodRet = '00532'; -- DIA NO LABORAL, VERIFIQUE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 414 THEN
							LET cCodRet = '00533'; -- EL PARÃÂMETRO FECHA_HOY NO SE ENCUENTRA EN LA TABLA SC_FECHA
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 415 THEN
							LET cCodRet = '00003';  
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 416 THEN
							LET cCodRet = '00534'; -- EL NÃÂMERO DE EMPLEADO NO CONTIENE LOS 8 DÃÂGITOS REQUERIDOS, VERIFIQUE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 417 THEN
							LET cCodRet = '00535'; -- EL NÃÂMERO DE EMPLEADO CONTIENE CARACTERES INVALIDOS, VERIFIQUE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 418 THEN
							LET cCodRet = '00481'; -- '00539'
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 419 THEN
							LET cCodRet = '00537'; -- EL ARCHIVO YA FUE PROCESADO PREVIAMENTE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 420 THEN
							LET cCodRet = '00538'; -- EL ARCHIVO SE ENCUENTRA PROCESANDO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 421 THEN
							LET cCodRet = '00549'; -- ERROR AL CARGAR EL ARCHIVO EN LAS TABLAS DE PASO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 422 THEN
							LET cCodRet = '00550'; -- ERROR AL VALIDAR LA INTEGRIDAD DEL ARCHIVO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 423 THEN
							LET cCodRet = '00551'; -- ERROR AL PROCESAR EL ARCHIVO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 424 THEN
							LET cCodRet = '00554'; -- ERROR AL GENERAR EL ARCHIVO DE RESPUESTA 61
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 425 THEN
							LET cCodRet = '00555'; -- ERROR AL GENERAR EL ARCHIVO DE RESPUESTA
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 426 THEN
							LET cCodRet = '00552'; -- ERROR AL MOVER LOS REGISTROS DEL ARCHIVO ORIGINAL AL HISTÃÂRICO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 427 THEN
							LET cCodRet = '00556'; -- ERROR AL MOVER LOS REGISTROS DEL ARCHIVO 61 AL HISTÃÂRICO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 428 THEN
							LET cCodRet = '00557'; -- ERROR AL MOVER LOS REGISTROS DEL ARCHIVO 11 AL HISTÃÂRICO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 429 THEN
							LET cCodRet = '00558'; -- ERROR AL MOVER LOS REGISTROS DEL ARCHIVO 62 AL HISTÃÂRICO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 430 THEN
							LET cCodRet = '00540'; -- ERROR AL LIMPIAR LA INFORMACIÃÂN EN LAS TABLAS DE PASO
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 432 THEN
							LET cCodRet = '00536'; -- EL USUARIO NO TIENE PRIVILEGIOS PARA REALIZAR ÃÂSTA OPERACIÃÂN, VERIFIQUE
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 434 THEN
							LET cCodRet = '00559'; -- LA FECHA DEL ENCABEZADO NO CORRESPONDEN A LA FECHA ACTUAL
							LET bError = 't';
							EXIT FOREACH;
						ELIF cCodRetSp::INTEGER = 435 THEN
							LET cCodRet = '00553'; -- EL ARCHIVO A PROCESAR NO SE ENCUENTRA EN LA RUTA INDICADA
							LET bError = 't';
							EXIT FOREACH;
						ELSE
							LET iNoRegistros = iNoRegistros + 1;
							RETURN cCodRet WITH RESUME;
						END IF;
					END FOREACH;
			
					--LET cCodRetorno = '00461'
					--LET cCodRetorno = '00462';
					--LET cCodRetorno = '00603';
					IF bTransacInteract = 't' THEN
						BEGIN WORK;
					END IF;
						
					IF bError = 't' THEN
						RETURN cCodRet;
					END IF;
				ELSE
					LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA                                   
					LET bError = 't';
				END IF;
			END;
		-- GENERACIÃÂN DE ARCHIVOS
		ELIF pIndicador = 'G' THEN
		
			-- ARCHIVO 60
			IF(SUBSTRING (TRIM(pNombreArchivo) FROM 14 FOR 2) = '60') THEN 
			
				BEGIN -- INICIO DE BLOQUE
				
					-- TRATADO DE EXCEPCIONES
					ON EXCEPTION IN (-535)
						LET bTransacInteract = 't';
						COMMIT WORK;
					END EXCEPTION WITH RESUME;
					
					BEGIN WORK;
			
					FOREACH
						EXECUTE PROCEDURE bditef:"informix".sp_tef_presentador_g(pNombreArchivo,pUsuario)
						INTO cNomArchivo,cCodRetSp,cDescCodRet
						
						IF cCodRetSp::INTEGER < 0 THEN 
							RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂN DEL SP bditef:sp_tef_presentador_g';
						ELIF cCodRetSp::INTEGER = 100 THEN
							LET cCodRet = '00521'; -- LA RUTA DEL ARCHIVO A PROCESAR NO EXISTE
						ELIF cCodRetSp::INTEGER = 101 THEN
							LET cCodRet = '00522'; -- LA RUTA DEL ARCHIVO RESPUESTA NO EXISTE
						ELIF cCodRetSp::INTEGER = 102 THEN
							LET cCodRet = '00523'; -- LA RUTA DE ARCHIVOS PROCESADOS NO EXISTE
						ELIF cCodRetSp::INTEGER = 103 THEN
							LET cCodRet = '00524'; -- LA RUTA DE ARCHIVOS ERRONEOS NO EXISTE
						ELIF cCodRetSp::INTEGER = 104 THEN
							LET cCodRet = '00525'; -- LA CLAVE BANCARIA BANCOPPEL NO EXISTE
						ELIF cCodRetSp::INTEGER = 105 THEN
							LET cCodRet = '00526'; -- NO EXISTE EL BIN CORRESPONDIENTE A LA TARJETA DE DÃÂBITO
						ELIF cCodRetSp::INTEGER = 106 THEN
							LET cCodRet = '00527'; -- NO EXISTE LA SUCURSAL CONTABLE TEF
						ELIF cCodRetSp::INTEGER = 107 THEN
							LET cCodRet = '00528'; -- NO EXISTE LA TRANSACCIÃÂN DE CARGO TEF
						ELIF cCodRetSp::INTEGER = 108 THEN
							LET cCodRet = '00529'; -- NO EXISTE LA TRANSACCIÃÂN DE ABONO TEF
						ELIF cCodRetSp::INTEGER = 109 THEN
							LET cCodRet = '00530'; -- EL IMPORTE MÃÂXIMO DE CECOBAN NO EXISTE
						ELIF cCodRetSp::INTEGER = 111 THEN
							LET cCodRet = '00531'; -- NO EXISTEN REGISTROS PARA LA CLAVE DEL PRODUCTO EN LA TABLA TEF_PROD_PERMITIDOS
						ELIF cCodRetSp::INTEGER = 112 THEN
							LET cCodRet = '00532'; -- DIA NO LABORAL, VERIFIQUE
						ELIF cCodRetSp::INTEGER = 113 THEN
							LET cCodRet = '00533'; -- EL PARÃÂMETRO FECHA_HOY NO SE ENCUENTRA EN LA TABLA SC_FECHA
						ELIF cCodRetSp::INTEGER = 114 THEN
							LET cCodRet = '00003';
						ELIF cCodRetSp::INTEGER = 115 THEN
							LET cCodRet = '00534'; -- EL NÃÂMERO DE EMPLEADO NO CONTIENE LOS 8 DÃÂGITOS REQUERIDOS, VERIFIQUE
						ELIF cCodRetSp::INTEGER = 116 THEN
							LET cCodRet = '00535'; -- EL NÃÂMERO DE EMPLEADO CONTIENE CARACTERES INVALIDOS, VERIFIQUE
						ELIF cCodRetSp::INTEGER = 117 THEN
							LET cCodRet = '00536'; -- EL USUARIO NO TIENE PRIVILEGIOS PARA REALIZAR ÃÂSTA OPERACIÃÂN, VERIFIQUE
						ELIF cCodRetSp::INTEGER = 118 THEN
							LET cCodRet = '00537'; -- EL ARCHIVO YA FUE PROCESADO PREVIAMENTE
						ELIF cCodRetSp::INTEGER = 119 THEN
							LET cCodRet = '00538'; -- EL ARCHIVO SE ENCUENTRA PROCESANDO
						ELIF cCodRetSp::INTEGER = 121 THEN
							LET cCodRet = '00481'; -- '00539'
						ELIF cCodRetSp::INTEGER = 122 THEN
							LET cCodRet = '00540'; -- ERROR AL LIMPIAR LA INFORMACIÃÂN EN LAS TABLAS DE PASO
						ELIF cCodRetSp::INTEGER = 123 THEN
							LET cCodRet = '00541'; -- ERROR AL GENERAR LA INFORMACIÃÂN EN LAS TABLAS DE PASO
						ELIF cCodRetSp::INTEGER = 124 THEN
							LET cCodRet = '00542'; -- NO EXISTEN REGISTROS PARA EL NOMBRE DEL ARCHIVO INDICADO EN LA TABLA TEF_CCE_ENCABEZADO_PASO
						ELIF cCodRetSp::INTEGER = 125 THEN
							LET cCodRet = '00543'; -- NO EXISTEN REGISTROS PARA EL NOMBRE DEL ARCHIVO INDICADO EN LA TABLA TEF_CCE_DETALLE_PASO
						ELIF cCodRetSp::INTEGER = 126 THEN
							LET cCodRet = '00544'; -- NO EXISTEN REGISTROS PARA EL NOMBRE DEL ARCHIVO INDICADO EN LA TABLA TEF_CCE_SUMARIO_PASO
						ELIF cCodRetSp::INTEGER = 127 THEN
							LET cCodRet = '00545'; -- ERROR AL GUARDAR LA INFORMACIÃÂN EN LA TABLA TEF_CCE_ARCHIVOS
						ELIF cCodRetSp::INTEGER = 128 THEN
							LET cCodRet = '00546'; -- ERROR AL DESCARGAR EL ARCHIVO AL REPOSITORIO
						ELIF cCodRetSp::INTEGER = 129 THEN
							LET cCodRet = '00547'; -- ERROR AL GUARDAR LA INFORMACIÃÂN EN TABLAS HISTORICO
						ELSE
							LET iNoRegistros = iNoRegistros + 1;
						END IF;
					END FOREACH;
					
					IF bTransacInteract = 't' THEN
						BEGIN WORK;
					END IF;
					
					IF iNoRegistros = 0 AND cCodRet = '00000' THEN
						LET cCodRet = '00017';
					END IF;
					
					RETURN cCodRet;
				
				END; -- FIN DE BLOQUE 
		
			-- ARCHIVO 63
			ELIF(SUBSTRING (TRIM(pNombreArchivo) FROM 14 FOR 2) = '63') THEN
				BEGIN --INICIO DE BLOQUE
					LET bTransacInteract = 't';
					COMMIT WORK;
					
					FOREACH
						EXECUTE PROCEDURE bditef:"informix".sp_tef_receptor_g(pNombreArchivo,pUsuario)
						INTO cNomArchivo,cCodRetSp,cDescCodRet
						
						IF cCodRetSp::INTEGER < 0 THEN 
							RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂN DEL SP bditef:sp_tef_receptor_g';
						ELIF cCodRetSp::INTEGER = 300 THEN 
							LET cCodRet = '00521'; -- LA RUTA DEL ARCHIVO A PROCESAR NO EXISTE
						ELIF cCodRetSp::INTEGER = 301 THEN
							LET cCodRet = '00522'; -- LA RUTA DEL ARCHIVO RESPUESTA NO EXISTE
						ELIF cCodRetSp::INTEGER = 302 THEN
							LET cCodRet = '00523'; -- LA RUTA DE ARCHIVOS PROCESADOS NO EXISTE
						ELIF cCodRetSp::INTEGER = 303 THEN
							LET cCodRet = '00524'; -- LA RUTA DE ARCHIVOS ERRONEOS NO EXISTE 
						ELIF cCodRetSp::INTEGER = 304 THEN
							LET cCodRet = '00525'; -- LA CLAVE BANCARIA BANCOPPEL NO EXISTE
						ELIF cCodRetSp::INTEGER = 305 THEN
							LET cCodRet = '00526'; -- NO EXISTE EL BIN CORRESPONDIENTE A LA TARJETA DE DÃÂBITO
						ELIF cCodRetSp::INTEGER = 306 THEN
							LET cCodRet = '00527'; -- NO EXISTE LA SUCURSAL CONTABLE TEF
						ELIF cCodRetSp::INTEGER = 307 THEN
							LET cCodRet = '00528'; -- NO EXISTE LA TRANSACCIÃÂN DE CARGO TEF
						ELIF cCodRetSp::INTEGER = 308 THEN
							LET cCodRet = '00529'; -- NO EXISTE LA TRANSACCIÃÂN DE ABONO TEF
						ELIF cCodRetSp::INTEGER = 309 THEN
							LET cCodRet = '00530'; -- EL IMPORTE MÃÂXIMO DE CECOBAN NO EXISTE
						ELIF cCodRetSp::INTEGER = 311 THEN
							LET cCodRet = '00531'; -- NO EXISTEN REGISTROS PARA LA CLAVE DEL PRODUCTO EN LA TABLA TEF_PROD_PERMITIDOS
						ELIF cCodRetSp::INTEGER = 312 THEN
							LET cCodRet = '00532'; -- DIA NO LABORAL, VERIFIQUE
						ELIF cCodRetSp::INTEGER = 313 THEN
							LET cCodRet = '00533'; -- EL PARÃÂMETRO FECHA_HOY NO SE ENCUENTRA EN LA TABLA SC_FECHA
						ELIF cCodRetSp::INTEGER = 314 THEN
							LET cCodRet = '00003';
						ELIF cCodRetSp::INTEGER = 315 THEN
							LET cCodRet = '00534'; -- EL NÃÂMERO DE EMPLEADO NO CONTIENE LOS 8 DÃÂGITOS REQUERIDOS, VERIFIQUE
						ELIF cCodRetSp::INTEGER = 316 THEN
							LET cCodRet = '00535'; -- EL NÃÂMERO DE EMPLEADO CONTIENE CARACTERES INVALIDOS, VERIFIQUE
						ELIF cCodRetSp::INTEGER = 317 THEN
							LET cCodRet = '00536'; -- EL USUARIO NO TIENE PRIVILEGIOS PARA REALIZAR ÃÂSTA OPERACIÃÂN, VERIFIQUE
						ELIF cCodRetSp::INTEGER = 318 THEN
							LET cCodRet = '00537'; -- EL ARCHIVO YA FUE PROCESADO PREVIAMENTE
						ELIF cCodRetSp::INTEGER = 319 THEN
							LET cCodRet = '00538'; -- EL ARCHIVO SE ENCUENTRA PROCESANDO
						ELIF cCodRetSp::INTEGER = 321 THEN
							LET cCodRet = '00481'; -- '00539'
						ELIF cCodRetSp::INTEGER = 322 THEN
							LET cCodRet = '00540'; -- ERROR AL LIMPIAR LA INFORMACIÃÂN EN LAS TABLAS DE PASO
						ELIF cCodRetSp::INTEGER = 323 THEN
							LET cCodRet = '00541'; -- ERROR AL GENERAR LA INFORMACIÃÂN EN LAS TABLAS DE PASO
						ELIF cCodRetSp::INTEGER = 324 THEN
							LET cCodRet = '00542'; -- NO EXISTEN REGISTROS PARA EL NOMBRE DEL ARCHIVO INDICADO EN LA TABLA TEF_CCE_ENCABEZADO_PASO
						ELIF cCodRetSp::INTEGER = 325 THEN
							LET cCodRet = '00543'; -- NO EXISTEN REGISTROS PARA EL NOMBRE DEL ARCHIVO INDICADO EN LA TABLA TEF_CCE_DETALLE_PASO
						ELIF cCodRetSp::INTEGER = 326 THEN
							LET cCodRet = '00544'; -- NO EXISTEN REGISTROS PARA EL NOMBRE DEL ARCHIVO INDICADO EN LA TABLA TEF_CCE_SUMARIO_PASO
						ELIF cCodRetSp::INTEGER = 327 THEN
							LET cCodRet = '00546'; -- ERROR AL DESCARGAR EL ARCHIVO AL REPOSITORIO
						ELIF cCodRetSp::INTEGER = 328 THEN
							LET cCodRet = '00545'; -- ERROR AL GUARDAR LA INFORMACIÃÂN EN LA TABLA TEF_CCE_ARCHIVOS
						ELIF cCodRetSp::INTEGER = 329 THEN
							LET cCodRet = '00547'; -- ERROR AL GUARDAR LA INFORMACIÃÂN EN TABLAS HISTORICO
						ELIF cCodRetSp::INTEGER = 330 THEN
							LET cCodRet = '00548'; -- NO EXISTE EL PARÃÂMETRO DE DÃÂAS NATURALES PARA REVERSOS			
						ELSE
							LET iNoRegistros = iNoRegistros + 1;
						END IF;
					END FOREACH;
					
					IF bTransacInteract = 't' THEN
						BEGIN WORK;
					END IF;
					
					IF iNoRegistros = 0 AND cCodRet = '00000' THEN
						LET cCodRet = '00017';
					END IF;
					
					RETURN cCodRet;		
				END;
			ELSE
				LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA                                   
				LET bError = 't';
			END IF;
		END IF;
		
		IF bTransacInteract = 't' THEN
			BEGIN WORK;
		END IF;
		IF bError = 't' THEN
			RETURN cCodRet;
		END IF;
					
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;	
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA: 14/07/2015',
'DESCRIPCION: SPL encargado de realizar la carga y/o generaciÃÂ³n manual de archivos tef.',
'pIndicador = C -- Corresponde a la Carga Manual de Archivos Tef',
'pIndicador = G -- Corresponde a la GeneraciÃÂ³n Manual de Archivos Tef',
'FUNCIONALIDAD: Generacion Manual de Archivos TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoarchivotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pRuta CHAR(100))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS nom_archivo;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNomArchivo CHAR(50);
	DEFINE iNoRegistros INTEGER;
	DEFINE bInTrans BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cNomArchivo = '';
	LET iNoRegistros = 0;
	LET bInTrans = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			IF bInTrans THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, cNomArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			LET bInTrans = 't';
		END EXCEPTION WITH RESUME;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoarchivotef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRuta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNomArchivo;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomArchivo;
		END IF;
		
		BEGIN WORK;
		IF NOT bInTrans THEN
			COMMIT WORK;
		END IF;
		SET ISOLATION TO DIRTY READ;
	
		FOREACH		
		
			EXECUTE PROCEDURE bditef:"informix".sp_buscararchivos_tef(pRuta)
			INTO cCodRetSp, cNomArchivo
		    
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditef:sp_buscararchivos_tef';
			ELIF cCodRetSp::INTEGER = 1	THEN
				IF bInTrans THEN
					BEGIN WORK;
				END IF;
				
				LET cCodRet = '00003';
				RETURN cCodRet, cNomArchivo;
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, UPPER(cNomArchivo) WITH RESUME;
	
		END FOREACH;
		
		IF bInTrans THEN
			BEGIN WORK;
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00560'; -- NO SE ENCONTRARON ARCHIVOS PARA EL PROCESO DE RECEPCIÓN
			RETURN cCodRet, cNomArchivo;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 07/07/2015',
'DESCRIPCION: SPL que realiza la consulta de archivos a tratar de acuerdo a la ruta proporcionada.',
'FUNCIONALIDAD: Envío/Recepción Archivos Bancoppel - Cecoban', 
'MODULO: TEF',
'BD: bditef';

CREATE PROCEDURE "informix".sp_catalogocodbancotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoCuenta CHAR(2), pCuenta CHAR(20))
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS cod_banco, 
			CHAR(40) AS desc_banco;			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(80);
	DEFINE cCodBanco CHAR(3);
	DEFINE cDescBanco CHAR(40);
	DEFINE iTipo INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET cCodBanco = '';
	LET cDescBanco = '';
	LET iTipo = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodBanco, cDescBanco;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocodbancotef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodBanco, cDescBanco;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodBanco, cDescBanco;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
			
		IF pTipoCuenta = '40' THEN
			LET iTipo = 3;
		ELIF pTipoCuenta = '03' THEN
			LET iTipo = 2;
		ELIF pTipoCuenta = '11' OR pTipoCuenta = '12' OR pTipoCuenta = '13' THEN
			LET iTipo = 1;
		END IF;		
		
		FOREACH	
			EXECUTE PROCEDURE bditef:"informix".sp_tef_obtcodbanco(iTipo,pCuenta)
			INTO cCodRetSp, cDescCodRet, cCodBanco, cDescBanco
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditef:sp_tef_obtcodbanco';
			ELIF cCodRetSp::INTEGER = 1	THEN
				LET cCodRet = '00450';
				RETURN cCodRet, cCodBanco, cDescBanco;
			ELIF cCodRetSp::INTEGER = 2	THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCodBanco, cDescBanco;
			END IF;

			IF cCodRetSp::INTEGER = 0 AND NVL(cCodBanco,'') <> '' AND NVL(cDescBanco,'') <> '' THEN
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cCodBanco, TRIM(UPPER(cDescBanco)) WITH RESUME;
			END IF;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodBanco, cDescBanco;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/07/2015',
'DESCRIPCION: SPL que obtiene los códigos de banco para operaciones TEF en central.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogofechaaptef(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
                        DATE AS fecha_aplicacion;                       
                        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE cFechaHoy CHAR(10);
        DEFINE dFechaAp DATE;
        DEFINE iNoRegistros INTEGER;
		DEFINE bFechas BOOLEAN;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cFechaHoy = '';
        LET dFechaAp = '';
        LET iNoRegistros = 0;
		LET bFechas = 't';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, dFechaAp;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_catalogofechaaptef.out';
                -- TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, dFechaAp;
                END IF;
                                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, dFechaAp;
                END IF;
                
                -- CONSULTA FECHA ACTUAL
                SELECT fecha_hoy INTO cFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = '001';               
                
                
                SET ISOLATION TO DIRTY READ;             
				WHILE(bFechas = 't')
                        EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(cFechaHoy)
                        INTO cCodRetSp, dFechaAp;
                        
                        IF cCodRetSp::INTEGER < 0 THEN
								LET bFechas = 'f';
                                RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂN DEL SP bditef:cal_fecha_pre_fh';
                        ELIF cCodRetSp::INTEGER = 110   THEN
                                LET cCodRet = '00003';
								LET bFechas = 'f';
                                RETURN cCodRet, dFechaAp;
                        ELSE                                        
                                LET iNoRegistros = iNoRegistros + 1;  
								LET cFechaHoy = dFechaAp;
                                RETURN cCodRet, dFechaAp WITH RESUME;   
                        END IF;
						
						IF(iNoRegistros = 2) THEN
							LET bFechas = 'f';
						END IF;
				END WHILE;		
                
                IF iNoRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, dFechaAp;
                ELSE
                
                END IF;
                
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA: 28/07/2015',
'DESCRIPCION: SPL que obtiene las fechas hÃÂ¡biles para realizar las operaciones TEF en central.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogotipoctatef(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS tipo_cuenta, 
			CHAR(20) AS desc_cuenta;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(80);
	DEFINE cTipoCuenta CHAR(2);
	DEFINE cDescCuenta CHAR(50);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET cTipoCuenta = '';
	LET cDescCuenta = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTipoCuenta, cDescCuenta;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_catalogotipoctatef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTipoCuenta, cDescCuenta;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTipoCuenta, cDescCuenta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;

		FOREACH	
			EXECUTE PROCEDURE bditef:"informix".sp_tef_obttipocta()
			INTO cCodRetSp, cDescCodRet, cTipoCuenta, cDescCuenta
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditef:sp_tef_obttipocta';
			ELIF cCodRetSp::INTEGER = 1	THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cTipoCuenta, cDescCuenta;
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cTipoCuenta, TRIM(UPPER(cDescCuenta)) WITH RESUME;	
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cTipoCuenta, cDescCuenta;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/07/2015',
'DESCRIPCION: SPL que obtiene los tipos de cuentas para operaciones TEF en central.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consmotdevolucion_tef(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				CHAR(2) AS idDevolucion,
				CHAR(70) AS descipcionMotivo;


	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdDevolucion CHAR(2);
	DEFINE cDescipcionMotivo CHAR(70);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdDevolucion = '';
	LET cDescipcionMotivo = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdDevolucion, cDescipcionMotivo;
		END EXCEPTION;

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consmotdevolucion_tef.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdDevolucion, cDescipcionMotivo;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdDevolucion, cDescipcionMotivo;
		END IF;

		FOREACH	SELECT id_devolucion, descipcion_motivo_devolucion
			INTO cIdDevolucion, cDescipcionMotivo
			FROM bdicnweb:"informix".sw_tf_motivos_devolucion
			RETURN cCodRet, cIdDevolucion, cDescipcionMotivo WITH RESUME;
		END FOREACH;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017'; --NO SE ENCONTRARON RESULTADOS
			RETURN cCodRet, cIdDevolucion, UPPER(cDescipcionMotivo);
		END IF;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martín',
'FECHA: 04/08/2014',
'DESCRIPCION: sp que consulta los motivos de devolución, para TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadevexttef(pUsuario CHAR(8), pIdFuncion CHAR(10),pTipoOperacion CHAR(1), pFechaArch CHAR(8), pRegistros INT, pRecuperacion INT)
		RETURNING CHAR(5) AS codret,
					INT AS idx,
	                CHAR(8) AS fechaAbono,
					CHAR(20) AS cuenta,
					CHAR(18) AS referencia,
					CHAR(40) AS banco,
					CHAR(30) AS importe,
					CHAR(10) AS estatus,
					CHAR(1) AS confirmado,
					CHAR(7) AS numSecuencia,
					CHAR(30) AS claveRastreo,
					CHAR(2) AS cveStatus,
					CHAR(2) AS motDev,
					CHAR(1) AS estatusReg;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iNoRegistrosC INTEGER;
	DEFINE iIdx INTEGER;
	DEFINE vsFechaAbono CHAR(8);
	DEFINE vsCuenta CHAR(20);
	DEFINE vsReferencia CHAR(18);
	DEFINE vsBanco CHAR(40);
	DEFINE vsImporte CHAR(30);
	DEFINE vsEstatus CHAR(10);
	DEFINE vsConfirmado CHAR(1);
	DEFINE vsNumSecuencia CHAR(7);
	DEFINE vsClaveRastreo CHAR(30);
	DEFINE vsCveStatus CHAR(2);
	DEFINE vsMotDev CHAR(2);
	DEFINE vsEstatusReg CHAR(1);
	
	LET cCodRet = '00000';
	LET cCodRetSp= '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iNoRegistrosC = 0;
	LET iIdx =  0;
	LET vsFechaAbono = "";
	LET vsCuenta = "";
	LET vsReferencia = "";
	LET vsBanco = "";
	LET vsImporte = "";
	LET vsEstatus = "";
	LET vsConfirmado = "";
	LET vsNumSecuencia = "";
	LET vsClaveRastreo = "";
	LET vsCveStatus = "";
	LET vsMotDev = '';
	LET vsEstatusReg = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultadevexttef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaArch = '' OR pRegistros = '' OR pRecuperacion = '' OR pTipoOperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg;
		END IF;
		
		IF pTipoOperacion NOT IN('1','2') THEN
			LET cCodRet = '00102';
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg;
		END IF;
		
		IF pTipoOperacion = '1' THEN
			--DEPURACION TABLA TEMP
			IF pRegistros = 0 THEN
				SET LOCK MODE TO WAIT 3;
				DELETE FROM bdicnweb:"informix".sw_tf_consdevext_tef
				WHERE fecha_abono = pFechaArch;
			END IF;
			
			---	EJECUCION SP PRODUCTIVO
			IF pRegistros = 0 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH	EXECUTE PROCEDURE bditef:sp_consdevext_tef('1' , pFechaArch , '', '', '', '')
					INTO cCodRetSp, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus 
					INSERT INTO bdicnweb:"informix".sw_tf_consdevext_tef(fecha_abono,cuenta,referencia,banco,importe,estatus,confirmado,num_secuencia,clave_rastreo,cve_status,motivo_devolucion,estatus_reg)
					VALUES (vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus,'',DECODE(vsCveStatus, '02', 'E', '03', 'E', 'P'));
					LET iNoRegistros = iNoRegistros + DBINFO('sqlca.sqlerrd2');	
				END FOREACH;
				
				IF iNoRegistros = 0 THEN
					LET cCodRet='00017'; ---NO SE OBTUVIERON RESULTADOS
					RETURN cCodRet, 0, '', '', '', '', '', '', '', '', '', '', '', '';
				END IF;
			END IF;
		END IF;	
		
		---CONSULTA DE DATOS
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion idx, fecha_abono, cuenta, referencia, banco, importe, estatus, confirmado, num_secuencia, clave_rastreo, cve_status, motivo_devolucion, estatus_reg
			INTO iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg
			FROM bdicnweb:"informix".sw_tf_consdevext_tef WHERE fecha_abono = pFechaArch ORDER BY idx
			LET iNoRegistrosC = iNoRegistrosC +	1;
			RETURN cCodRet, iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg with resume;
		END FOREACH;
		
		IF pRegistros > 0 AND iNoRegistrosC = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, 0, '', '', '', '', '', '', '', '', '', '', '', '';
				
		END IF;
		
		IF iNoRegistrosC = 0 THEN
			LET cCodRet = '00017'; ---NO SE OBTUVIERON RESULTADOS
			RETURN cCodRet, 0, '', '', '', '', '', '', '', '', '', '', '', '';
		END IF;		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 04/08/2015',
'DESCRIPCION: pTipoOperacion: 1=consulta, 2=exportado ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaestatusdevext_tef(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaArch CHAR(8))
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS estatus_proceso;		

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE vsEstatusProceso CHAR(1);
	DEFINE vsTotalEnProceso INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET vsEstatusProceso = '';
	LET vsTotalEnProceso = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vsEstatusProceso;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultaestatusdevext_tef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaArch = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vsEstatusProceso;
		END IF;
		
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vsEstatusProceso;
		END IF;

		---CONSULTA TOTAL DE REGISTROS EN PROCESO
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*) INTO vsTotalEnProceso FROM bdicnweb:"informix".sw_tf_consdevext_tef 
		WHERE fecha_abono  = pFechaArch 
		AND motivo_devolucion !='' 
		AND estatus_reg = 'P';
		
		IF vsTotalEnProceso > 0 THEN
			LET vsEstatusProceso = '1';
		ELSE
			LET vsEstatusProceso = '0';
		END IF;
		
		RETURN cCodRet, vsEstatusProceso;			
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 07/08/2015',
'DESCRIPCION: Consulta si hay registros de devolucion en ejecucion del dia consultado',
'1 = archivos en proceso, 0 = archivos en No proceso ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfsdostef(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pNumTarjeta CHAR(16))	
		RETURNING CHAR(5) AS codret,           
			CHAR(20) AS cCuenta,               
		    CHAR(20) AS cNoCliente,            
		    CHAR(26) AS cApPaterno,            
		    CHAR(26) AS cApMaterno,            
		    CHAR(26) AS cNombre1,              
		    CHAR(26) AS cNombre2,              
		    CHAR(60) AS cRazonSocial,          
		    CHAR(1) AS cStatusCuenta,          
		    MONEY(14,2) AS mSaldoDisponible,   
		    MONEY(14,2) AS mSaldoRetenido,     
		    MONEY(14,2) AS mSaldoCCC,          
		    MONEY(14,2) AS mSaldoCCCDisp,      
		    MONEY(14,2) AS mSaldoCuenta,       
		    CHAR(1) AS cTipoLinea,             
		    CHAR(40) AS cDescripcion1,         
		    CHAR(40) AS cDescripcion2,         
		    MONEY(14,2) AS mSaldoT1,           
		    MONEY(14,2) AS mSaldoCongelado,    
		    MONEY(14,2) AS mSaldoSBC,          
		    CHAR(8) AS cUsuarioBloqueo,        
		    DATE AS dFechaBloqueo,             
		    CHAR(16) AS cNoTarjeta,            
		    CHAR(18) AS cCuentaClabe,          
		    DATE AS dFechaExpTarjeta,          
			CHAR(4) AS cProducto;              

		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cEmpresa CHAR(3);
		DEFINE cCuenta CHAR(20);
		DEFINE cNoCliente CHAR(20);
		DEFINE cApPaterno CHAR(26);
		DEFINE cApMaterno CHAR(26);
		DEFINE cNombre1 CHAR(26); 
		DEFINE cNombre2 CHAR(26); 
		DEFINE cRazonSocial CHAR(60);
		DEFINE cStatusCuenta CHAR(1);
		DEFINE mSaldoDisponible MONEY(14,2);  
		DEFINE mSaldoRetenido MONEY(14,2);  
		DEFINE mSaldoCCC MONEY(14,2);  
		DEFINE mSaldoCCCDisp MONEY(14,2);  
		DEFINE mSaldoCuenta MONEY(14,2);  
		DEFINE cTipoLinea CHAR(1);     
		DEFINE cDescripcion1 CHAR(40);   
		DEFINE cDescripcion2 CHAR(40);   
		DEFINE mSaldoT1 MONEY(14,2);
		DEFINE mSaldoCongelado MONEY(14,2); 
		DEFINE mSaldoSBC MONEY(14,2);
		DEFINE cUsuarioBloqueo CHAR(8);     
		DEFINE dFechaBloqueo DATE;       
		DEFINE cNoTarjeta CHAR(16);  
		DEFINE cCuentaClabe CHAR(18);
		DEFINE dFechaExpTarjeta DATE;   
		DEFINE cProducto CHAR(4);
		DEFINE cFechaHoy CHAR(10);
		DEFINE cHora CHAR(10);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cEmpresa = '001';
		LET cCuenta = '';
		LET cNoCliente = '';
		LET cApPaterno = '';
		LET cApMaterno = '';
		LET cNombre1 = ''; 
		LET cNombre2 = ''; 
		LET cRazonSocial = '';
		LET cStatusCuenta = '';
		LET mSaldoDisponible = 0.00;  
		LET mSaldoRetenido = 0.00;  
		LET mSaldoCCC = 0.00;   
		LET mSaldoCCCDisp = 0.00;  
		LET mSaldoCuenta = 0.00;   
		LET cTipoLinea = ''; 
		LET cDescripcion1 = '';   
		LET cDescripcion2 = '';   
		LET mSaldoT1 = 0.00;  
		LET mSaldoCongelado = 0.00;  
		LET mSaldoSBC = 0.00;  
		LET cUsuarioBloqueo = '';  
		LET dFechaBloqueo = '';     
		LET cNoTarjeta = '';
		LET cCuentaClabe = '';
		LET dFechaExpTarjeta = '';
		LET cProducto = '';
		LET cFechaHoy = '';
		LET cHora = '';
		LET iNoRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfsdostef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			END IF;
		 
			SET ISOLATION TO DIRTY READ;
		
			IF NVL(pCuenta,'') = '' THEN
				LET pCuenta = '00000000000';
			END IF;
			IF NVL(pNumTarjeta,'') = '' THEN
				LET pNumTarjeta = '0000000000000000';
			END IF;
			
			EXECUTE PROCEDURE bdicheq:"informix".cons_sdos2(cEmpresa,pCuenta,pNumTarjeta)
			INTO cCodRetSp, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
			mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
			mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:cons_sdos2';
			ELIF cCodRetSp::INTEGER = 100 THEN
				
				IF pCuenta::BIGINT > 0 THEN
					LET cCodRet = '00009'; --EL NUMERO DE CUENTA NO EXISTE
					RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
					mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
					mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
				ELIF pNumTarjeta::BIGINT > 0 THEN
					LET cCodRet = '00029'; --EL NUMERO DE TARJETA NO EXISTE
					RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
					mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
					mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
				END IF;
				
			ELIF cCodRetSp::INTEGER = 104 THEN
				LET cCodRet = '00564'; --HAY INCONGRUENCIA DE INFORMACIÃN CON EL NÃMERO DE CLIENTE, VERIFIQUE
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			ELIF cCodRetSp::INTEGER = 110 THEN
				LET cCodRet = '00565'; --DEBE INGRESAR AL MENOS UN NÃMERO DE CUENTA O UN NÃMERO DE TARJETA VÃLIDO
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			ELIF cCodRetSp::INTEGER = 122 THEN
				LET cCodRet = '00566'; --LA TARJETA DE DÃBITO NO ESTÃ ACTIVA, VERIFIQUE
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			ELIF cCodRetSp::INTEGER = 855 THEN
				LET cCodRet = '00567'; --TRANSACCIÃN NO PERMITIDA CON PRODUCTO 8000-TRANSFER
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			END IF;

			IF cCodRetSp::INTEGER = 0 THEN
				IF NVL(cDescripcion1,'') <> '' THEN
					LET cProducto = SUBSTRING (TRIM(cDescripcion1) FROM 1 FOR 5);
				END IF;
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCuenta, cNoCliente, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, cDescripcion1, cDescripcion2,   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			ELSE	
				RETURN cCodRet, cCuenta, cNoCliente, UPPER(cApPaterno), UPPER(cApMaterno), UPPER(cNombre1), UPPER(cNombre2), UPPER(cRazonSocial), cStatusCuenta,
				mSaldoDisponible, mSaldoRetenido, mSaldoCCC, mSaldoCCCDisp, mSaldoCuenta, cTipoLinea, UPPER(cDescripcion1), UPPER(cDescripcion2),   
				mSaldoT1, mSaldoCongelado, mSaldoSBC, cUsuarioBloqueo, dFechaBloqueo, cNoTarjeta, cCuentaClabe, dFechaExpTarjeta, cProducto;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/07/2015',
'DESCRIPCION: SPL que consulta la informaciÃ³n del cliente respecto al nÃºmero de cuenta o nÃºmero de tarjeta ingresado.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultanombrearchivotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS nom_archivo;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNomArchivo CHAR(20);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cNomArchivo = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cNomArchivo;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultanombrearchivotef.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNomArchivo;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomArchivo;
		END IF;
	
		FOREACH		
			EXECUTE PROCEDURE bditef:"informix".sp_obtenernomarch_tef(pIdConsulta)
			INTO cCodRetSp, cNomArchivo
		    
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditef:sp_obtenernomarch_tef';
			--ELIF cCodRetSp::INTEGER = 1 THEN
			--	LET cCodRet = ''; -- Valida Fecha
			--	RETURN cCodRet, cNomArchivo;
			END IF;
			
			IF cCodRetSp::INTEGER = 0 AND NVL(cNomArchivo,'') <> '' THEN
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(cNomArchivo) WITH RESUME;
			END IF;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNomArchivo;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 09/07/2015',
'DESCRIPCION: SPL que realiza el armado de los nombres de los archivos correspondientes para su carga, proceso y generación manual.',
'FUNCIONALIDAD: Generación Manual de Archivos TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaparametrosgenerales(pUsuario CHAR(8), pIdFuncion CHAR(10), pWhere CHAR(15), pIdParametro CHAR(15))
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS valor;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(100);
	DEFINE cQuery CHAR(500);
	DEFINE sIdFuncion CHAR(10);
	DEFINE sNombreBase CHAR(12);
	DEFINE sNmbreTabla CHAR(40);
	DEFINE sCampo CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cValor = '';
	LET cQuery = '';
	LET sIdFuncion = '';
	LET sNombreBase = '';
	LET sNmbreTabla = '';
	LET sCampo = '';


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaparametrosgenerales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pWhere = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValor;
		END IF;

			IF pWhere <> '' THEN
				
				IF pIdParametro = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cValor;
				END IF;
				
				SELECT id_funcion, nombre_base, nombre_tabla, nombre_campo
				INTO  sIdFuncion, sNombreBase, sNmbreTabla, sCampo
				FROM bdicnweb:"informix".sw_parametros_generales 
				WHERE id_funcion = pIdFuncion 
				AND id_parametro = pIdParametro;

				IF NVL(sIdFuncion,'') = '' OR NVL(sNombreBase,'') = '' OR NVL(sNmbreTabla,'') = '' OR NVL(sCampo,'') = '' THEN
					LET cCodRet = '00190'; --NO EXISTE VALOR PARA ESTE PARAMETRO
					RETURN cCodRet, cValor;			
				END IF;
			
				LET cQuery = "SELECT" || " "||TRIM(sCampo) || " " ||"FROM" || " " || TRIM(sNombreBase) || ":" ||"'informix'."||TRIM(sNmbreTabla)|| " " ||
				"WHERE" || " " || TRIM(pWhere) || " " ||"=" || " '" || TRIM(pIdParametro) ||"';";
				
				PREPARE countQry FROM TRIM(cQuery);
				DECLARE countcur CURSOR FOR countQry;
				OPEN countcur;
				FETCH countcur INTO cValor;
				IF (SQLCODE = 100) THEN
					LET cCodRet = '00190'; --NO EXISTE VALOR PARA ESTE PARAMETRO
					RETURN cCodRet, cValor;
				END IF;
				WHILE(SQLCODE = 0)
					RETURN cCodRet, cValor WITH RESUME;
					FETCH countcur INTO cValor;
				END WHILE
				CLOSE countcur;
				FREE countcur;
				FREE countQry;
				
			END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 08/07/2015',
'DESCRIPCION: SPL que realiza la consulta de algun parametro de acuerdo a los datos insertados.',
'Donde: pWhere se refiere al nombre del campo a comparar y pIdParametro al valor del parametro a comparar.',
'FUNCIONALIDAD: Envío/Recepción Archivos Bancoppel - Cecoban', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarchivosafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
			
		RETURNING CHAR(5) AS codret,  			
			CHAR(1) 	  AS cTipoRegistro,
			CHAR(10)	  AS cNoContratoEmpresa,
			DATE 		  AS dFechaGen,
			DATE 		  AS dFechaInicialInformacion,
			DATE 		  AS dFechaFinalInformacion,
			CHAR(9) 	  AS cNoMovimientosContenidos,
			CHAR(232)	  AS cFiller,
			CHAR(2)   	  AS cFinLinea,
			CHAR(11) 	  AS cNSS,
			CHAR(40) 	  AS cNombreBeneficiario,
			CHAR(40) 	  AS cApellidoPaternoBeneficiario,
			CHAR(40) 	  AS cApellidoMaternoBeneficiario,
			CHAR(1)  	  AS cFormasPago,
			CHAR(18) 	  AS cCLABE,
			DATE     	  AS dFechaCaptura,
			CHAR(15) 	  AS cImporteDocumentoNetoPagar,
			CHAR(15) 	  AS cImporteDocumentoAntesImpuesto,
			CHAR(11) 	  AS cImpuestoRetenido,
			CHAR(8)  	  AS cNumeroFolioServicio,
			CHAR(4)  	  AS cNumeroTienda,
			CHAR(3)  	  AS cTipoRetiro,
			CHAR(10) 	  AS cConsecutivoRetiro,
			CHAR(18) 	  AS cCURP,
			CHAR(10) 	  AS cRFC,
			CHAR(16) 	  AS cFolio_suc,
			CHAR(2)  	  AS cNumeroTotalMovimientosContenidos,
			CHAR(17) 	  AS cImporteTotalNeto,
			CHAR(17) 	  AS cImporteTotalAntesImpuesto,
			CHAR(17) 	  AS cImporteRetenido,
			CHAR(17) 	  AS cImporteTotalRetirosPagadosEfectivo,
			CHAR(17) 	  AS cImporteTotalRetirosPagadosDeposito,
			DATE     	  AS dFechaMovimientos,
			CHAR(2)  	  AS cEstatus,
			INTEGER  	  AS iSumaMov,
			MONEY(10,2)   AS mMonto,
			MONEY(12,2)   AS mSumaMonto;
			
		DEFINE cCodRet							   CHAR(5);
		DEFINE cCodRetSp 						   CHAR(6);
        DEFINE iSqlErr 							   INTEGER;	
		DEFINE cMensajeRet 						   CHAR(200); 			
		DEFINE cTipoRegistro                       CHAR(1); 	  
		DEFINE cNoContratoEmpresa                  CHAR(10);	  
		DEFINE dFechaGen                           DATE; 		  
		DEFINE dFechaInicialInformacion            DATE; 		  
		DEFINE dFechaFinalInformacion              DATE; 		  
		DEFINE cNoMovimientosContenidos            CHAR(9); 	  
		DEFINE cFiller                             CHAR(232);	  
		DEFINE cFinLinea                           CHAR(2);   	  
		DEFINE cNSS                                CHAR(11); 	  
		DEFINE cNombreBeneficiario                 CHAR(40); 	  
		DEFINE cApellidoPaternoBeneficiario        CHAR(40); 	  
		DEFINE cApellidoMaternoBeneficiario        CHAR(40); 	  
		DEFINE cFormasPago                         CHAR(1); 	  
		DEFINE cCLABE                              CHAR(18); 	  
		DEFINE dFechaCaptura                       DATE; 	  
		DEFINE cImporteDocumentoNetoPagar          CHAR(15); 	  
		DEFINE cImporteDocumentoAntesImpuesto      CHAR(15); 	  
		DEFINE cImpuestoRetenido                   CHAR(11); 	  
		DEFINE cNumeroFolioServicio                CHAR(8); 	  
		DEFINE cNumeroTienda                       CHAR(4); 	  
		DEFINE cTipoRetiro                         CHAR(3); 	  
		DEFINE cConsecutivoRetiro                  CHAR(10); 	  
		DEFINE cCURP                               CHAR(18); 	  
		DEFINE cRFC                                CHAR(10); 	  
		DEFINE cFolio_suc                          CHAR(16); 	  
		DEFINE cNumeroTotalMovimientosContenidos   CHAR(2); 	  	
		DEFINE cImporteTotalNeto                   CHAR(17); 	  
		DEFINE cImporteTotalAntesImpuesto          CHAR(17); 	  
		DEFINE cImporteRetenido                    CHAR(17); 	  
		DEFINE cImporteTotalRetirosPagadosEfectivo CHAR(17); 	  
		DEFINE cImporteTotalRetirosPagadosDeposito CHAR(17); 	  
		DEFINE dFechaMovimientos                   DATE; 	  
		DEFINE cEstatus                            CHAR(2); 	  
		DEFINE iSumaMov                            INTEGER; 	  
		DEFINE mMonto                              MONEY(10,2);   
		DEFINE mSumaMonto                          MONEY(12,2);  
		DEFINE pTipoArchivo 					   CHAR(1);
		DEFINE iRecuperacion 					   INTEGER;
		
		DEFINE cNoContratoEmpresaTmp               CHAR(10);	  
		DEFINE dFechaGenTmp                        DATE; 		  
		DEFINE dFechaInicialInformacionTmp         DATE; 		  
		DEFINE dFechaFinalInformacionTmp           DATE; 		  
		DEFINE cNoMovimientosContenidosTmp         CHAR(9);
		DEFINE dFecha_Hoy						   DATE;
		
		DEFINE bConsultaTerminada 				   BOOLEAN;
		DEFINE iSpSkip                             INTEGER;
		DEFINE iSpSkipInc                          SMALLINT;
		DEFINE iNoRegistros 					   INTEGER;
		DEFINE totalInserts						   INTEGER;		
		DEFINE cNombre                             CHAR(30);
		DEFINE iMaximo							   INTEGER;
		DEFINE iMinimo                             INTEGER;
		
		LET cCodRet 							   = '00000';
		LET cCodRetSp 							   = '';
        LET iSqlErr 							   = 0;	
		LET cMensajeRet 						   = ''; 			
		LET cTipoRegistro                          = '';	  
		LET cNoContratoEmpresa                     = '';	  
		LET dFechaGen                              = ''; 		  
		LET dFechaInicialInformacion               = ''; 		  
		LET dFechaFinalInformacion                 = ''; 		  
		LET cNoMovimientosContenidos               = '';	  
		LET cFiller                                = '';	  
		LET cFinLinea                              = ''; 	  
		LET cNSS                                   = '';	  
		LET cNombreBeneficiario                    = '';	  
		LET cApellidoPaternoBeneficiario           = '';	  
		LET cApellidoMaternoBeneficiario           = '';	  
		LET cFormasPago                            = '';	  
		LET cCLABE                                 = '';	  
		LET dFechaCaptura                          = ''; 	  
		LET cImporteDocumentoNetoPagar             = ''; 	  
		LET cImporteDocumentoAntesImpuesto         = ''; 	  
		LET cImpuestoRetenido                      = ''; 	  
		LET cNumeroFolioServicio                   = '';	  
		LET cNumeroTienda                          = '';	  
		LET cTipoRetiro                            = '';	  
		LET cConsecutivoRetiro                     = ''; 	  
		LET cCURP                                  = ''; 	  
		LET cRFC                                   = ''; 	  
		LET cFolio_suc                             = ''; 	  
		LET cNumeroTotalMovimientosContenidos      = '';	  	
		LET cImporteTotalNeto                      = ''; 	  
		LET cImporteTotalAntesImpuesto             = ''; 	  
		LET cImporteRetenido                       = ''; 	  
		LET cImporteTotalRetirosPagadosEfectivo    = ''; 	  
		LET cImporteTotalRetirosPagadosDeposito    = ''; 	  
		LET dFechaMovimientos                      = ''; 	  
		LET cEstatus                               = ''; 	  
		LET iSumaMov                               = 0; 	  
		LET mMonto                                 = '';  
		LET mSumaMonto                             = '';   
		LET pTipoArchivo 						   = '';
		LET iRecuperacion 						   = 0;
	  
		LET cNoContratoEmpresaTmp                  = '';	  
		LET dFechaGenTmp                           = ''; 		  
		LET dFechaInicialInformacionTmp            = ''; 		  
		LET dFechaFinalInformacionTmp              = ''; 		  
		LET cNoMovimientosContenidosTmp            = '';
		LET dFecha_Hoy							   = '';
		
		LET bConsultaTerminada                     = 'f';
		LET iSpSkip                                = 0;
		LET iSpSkipInc                             = 10;
		LET iNoRegistros                           = 0;
		LET totalInserts                           = 0;
		LET cNombre                                = '';
		LET iMaximo								   = 0;
		LET iMinimo                                = 0;
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
			END EXCEPTION;
			
			ON EXCEPTION IN (-958)
			END EXCEPTION WITH RESUME;
			
			ON EXCEPTION IN (-206)
			END EXCEPTION WITH RESUME;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultarchivosafore.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
            END IF;
            
			-- VALIDACION DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
			END IF;
			
			-- VALIDA NOMENCLATURA			
			IF SUBSTRING(pNombreArchivo FROM 15 FOR 2) = 'OB' OR SUBSTRING(pNombreArchivo FROM 5 FOR 2) = 'OB' THEN 
				LET pTipoArchivo = '2';
			ELSE 
				LET pTipoArchivo = '1';
			END IF;
			
			-- ELIMINACIÃN DE TABLA TEMPORAL SI EXISTE
			DROP TABLE sw_af_registros_tmp;
			
			-- CREACION DE TABLA TEMPORAL
			CREATE TEMP TABLE IF NOT EXISTS sw_af_registros_tmp(consecutivo SERIAL, usuario_tmp CHAR(20), cNSS_tmp CHAR(11), cNombreBeneficiario_tmp CHAR(40), 
			cApellidoPaternoBeneficiario_tmp CHAR(40), cApellidoMaternoBeneficiario_tmp CHAR(40), cFormasPago_tmp CHAR(1), cCLABE_tmp CHAR(18), 
			dFechaCaptura_tmp DATE, cImporteDocumentoNetoPagar_tmp CHAR(15), cImporteDocumentoAntesImpuesto_tmp CHAR(15), cImpuestoRetenido_tmp CHAR(11), 
			cNumeroFolioServicio_tmp CHAR(8), cNumeroTienda_tmp CHAR(4), cTipoRetiro_tmp CHAR(3), cConsecutivoRetiro_tmp CHAR(10), 
			cCURP_tmp CHAR(18), cRFC_tmp CHAR(10), cEstatus_tmp CHAR(2), cFolio_suc_tmp CHAR(16), cMonto_tmp MONEY(10,2), iSumaMov_tmp INTEGER) WITH NO LOG;
			DELETE FROM sw_af_registros_tmp WHERE usuario_tmp = pUsuario;
			
			SET LOCK MODE TO WAIT 3; 
		 
				FOREACH
				
					EXECUTE PROCEDURE bdiprog:"informix".sp_aforeconsultaarchivos(pNombreArchivo, pTipoArchivo) 
					INTO cCodRetSp, cTipoRegistro, cNoContratoEmpresaTmp, dFechaGenTmp, dFechaInicialInformacionTmp, dFechaFinalInformacionTmp, 
					cNoMovimientosContenidosTmp, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
					cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
					cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
					cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
					cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
					cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto
					
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂN DEL SP bdiprog:sp_aforeconsultaarchivos';					 
					ELIF cCodRetSp::INTEGER = 10000 THEN	
						LET cCodRet = '00481'; 
						RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
					END IF;

					INSERT INTO sw_af_registros_tmp(usuario_tmp, cNSS_tmp, cNombreBeneficiario_tmp, cApellidoPaternoBeneficiario_tmp, cApellidoMaternoBeneficiario_tmp, 
					cFormasPago_tmp, cCLABE_tmp, dFechaCaptura_tmp, cImporteDocumentoNetoPagar_tmp, cImporteDocumentoAntesImpuesto_tmp, cImpuestoRetenido_tmp, 
					cNumeroFolioServicio_tmp, cNumeroTienda_tmp, cTipoRetiro_tmp, cConsecutivoRetiro_tmp, cCURP_tmp, cRFC_tmp, cEstatus_tmp, cFolio_suc_tmp, cMonto_tmp, iSumaMov_tmp) 
					VALUES (pUsuario, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario, cFormasPago, cCLABE, 
					dFechaCaptura, cImporteDocumentoNetoPagar, cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio,
					cNumeroTienda, cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cEstatus, cFolio_suc, mMonto, iSumaMov);
					
					IF DBINFO('sqlca.sqlerrd2') = 1 THEN
						LET iNoRegistros = iNoRegistros + 1;
					END IF;
					
				END FOREACH;
			
			SET ISOLATION TO DIRTY READ;
			LET iNoRegistros = 0;
			
			SELECT MIN(consecutivo)
			INTO iMinimo FROM sw_af_registros_tmp;

			SELECT MAX(consecutivo)
			INTO iMaximo FROM sw_af_registros_tmp;
			
			FOREACH --WITH HOLD
				
				SELECT SKIP pRegistros FIRST pRecuperacion cNSS_tmp, cNombreBeneficiario_tmp, cApellidoPaternoBeneficiario_tmp, cApellidoMaternoBeneficiario_tmp, 
				cFormasPago_tmp, cCLABE_tmp, dFechaCaptura_tmp, cImporteDocumentoNetoPagar_tmp, cImporteDocumentoAntesImpuesto_tmp, cImpuestoRetenido_tmp, 
				cNumeroFolioServicio_tmp, cNumeroTienda_tmp, cTipoRetiro_tmp, cConsecutivoRetiro_tmp, cCURP_tmp, cRFC_tmp, cEstatus_tmp, cFolio_suc_tmp, cMonto_tmp, iSumaMov_tmp
				INTO cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario, cFormasPago, cCLABE, 
				dFechaCaptura, cImporteDocumentoNetoPagar, cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio,
				cNumeroTienda, cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cEstatus, cFolio_suc, mMonto, iSumaMov--cNumeroTotalMovimientosContenidos
				FROM sw_af_registros_tmp
				WHERE consecutivo NOT IN (iMaximo,iMinimo) 
				AND usuario_tmp = pUsuario
				
				-- DATOS DEL ENCABEZADO	
				IF pNombreArchivo LIKE 'PAGOS%' OR pNombreArchivo LIKE 'CONF%' THEN 
					IF pNombreArchivo LIKE 'CONF%' THEN
						IF pTipoArchivo = '1' THEN  
							LET cNombre = 'PAGOS'||SUBSTR(pNombreArchivo,5,9)||'A'||SUBSTR(pNombreArchivo,15,30);
						ELIF pTipoArchivo = '2' THEN
							LET cNombre = 'PAGOS' || SUBSTR(pNombreArchivo,7,9) || 'OBA' || SUBSTR(pNombreArchivo,17,30);
						END IF; 
					ELSE
						LET cNombre = pNombreArchivo;
					END IF;
					
					SELECT contrato, fecha_gen, fecha_ini, fecha_fin, no_mov
					INTO cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, cNoMovimientosContenidos
					FROM bdiprog:pp_Encabezado WHERE nombre_arch = cNombre; 
				ELSE 
					--DATOS DEL ENCABEZADO
					LET cTipoRegistro = 'E';
		
					SELECT fecha_hoy INTO dFecha_Hoy FROM Bdinteg:si_fechas;
					LET dFechaGen = dFecha_Hoy;
					LET dFechaMovimientos = dFecha_Hoy;
				END IF;
				
				RETURN 	cCodRet, NVL(UPPER(cTipoRegistro),''), NVL(cNoContratoEmpresa,''), NVL(dFechaGen,''), NVL(dFechaInicialInformacion,''), NVL(dFechaFinalInformacion,''), 
				NVL(cNoMovimientosContenidos,''), NVL(cFiller,''), NVL(cFinLinea,''), NVL(cNSS,''), NVL(UPPER(cNombreBeneficiario),''), NVL(UPPER(cApellidoPaternoBeneficiario),''), 
				NVL(UPPER(cApellidoMaternoBeneficiario),''), NVL(cFormasPago,''), NVL(cCLABE,''), NVL(dFechaCaptura,''), NVL(cImporteDocumentoNetoPagar,0), 
				NVL(cImporteDocumentoAntesImpuesto,0), NVL(cImpuestoRetenido,0), NVL(cNumeroFolioServicio,''), NVL(cNumeroTienda,''), NVL(cTipoRetiro,''), 
				NVL(cConsecutivoRetiro,''), NVL(UPPER(cCURP),''), NVL(UPPER(cRFC),''), NVL(cFolio_suc,''), NVL(cNumeroTotalMovimientosContenidos,''), NVL(cImporteTotalNeto,0), 
				NVL(cImporteTotalAntesImpuesto,0), NVL(cImporteRetenido,0), NVL(cImporteTotalRetirosPagadosEfectivo,0), 
				NVL(cImporteTotalRetirosPagadosDeposito,0), NVL(dFechaMovimientos,''), NVL(cEstatus,''), NVL(iSumaMov,0), NVL(mMonto,0), NVL(mSumaMonto,0) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion, 
						cNoMovimientosContenidos, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
						cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
						cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
						cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
						cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
						cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto;
			END IF;	
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/06/2015',
'DESCRIPCION: SPL encargado de consultar los archivos de pagos, confirmacion y control Afore.',
'FUNCIONALIDAD: Consulta de Archivos - Proceso AFORE', 
'MODULO: AFORE',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/10/2015',
'DESCRIPCION: Se realizÃ³ la modificaciÃ³n para el llenado del detalle de los encabezados y el detalle de los registros a mostrar en el grid',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_devolucionextemporanea_tef(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaArch CHAR(8), pPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
		
	DEFINE cCodRet		CHAR(5);
	DEFINE cCodRetSp	CHAR(5);
	DEFINE iSqlErr		INTEGER;
	DEFINE iNoRegs		INTEGER;
	DEFINE iInTrans		INTEGER;
	DEFINE iTotalRegs	INTEGER;
	DEFINE mTotalMonto	MONEY(14,2);
	DEFINE dFechaMail	DATETIME YEAR TO SECOND;
	----R
	DEFINE cValorSucContTef CHAR(100);
	DEFINE cValorTransacCargoTef CHAR(100);
	DEFINE cNumeroFolio CHAR(16);
	DEFINE iIdx INTEGER;
	DEFINE vsFechaAbono CHAR(8);
	DEFINE vsCuenta CHAR(20);
	DEFINE vsReferencia CHAR(18);
	DEFINE vsBanco CHAR(40);
	DEFINE vsImporte CHAR(30);
	DEFINE vsEstatus CHAR(10);
	DEFINE vsConfirmado CHAR(1);
	DEFINE vsNumSecuencia CHAR(7);
	DEFINE vsClaveRastreo CHAR(30);
	DEFINE vsCveStatus CHAR(2);
	DEFINE vsMotDev CHAR(2);
	DEFINE vsEstatusReg CHAR(1);
	DEFINE vsAuxCta CHAR(11);
	DEFINE vsAuxTarjeta CHAR(16);
	DEFINE vsImporteAux CHAR(30);
	DEFINE vTranret CHAR(4);
	DEFINE vFechoy DATE;
	DEFINE vSdodisp MONEY(14,2);
	DEFINE vMontoret MONEY(14,2);
	
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iNoRegs = 0;
	LET iInTrans = 0;
	LET iTotalRegs = 0;
	LET mTotalMonto	= NULL;	
	----R
	LET cValorSucContTef = '';
	LET cValorTransacCargoTef = '';
	LET cNumeroFolio = '';
	LET iIdx =  0;
	LET vsFechaAbono = "";
	LET vsCuenta = "";
	LET vsReferencia = "";
	LET vsBanco = "";
	LET vsImporte = "";
	LET vsEstatus = "";
	LET vsConfirmado = "";
	LET vsNumSecuencia = "";
	LET vsClaveRastreo = "";
	LET vsCveStatus = "";
	LET vsMotDev = '';
	LET vsEstatusReg = '';
	LET vsAuxCta = '';
	LET vsAuxTarjeta = '';
	LET vsImporteAux = '';
	LET vTranret = '';
	LET vFechoy = NULL;
	LET vSdodisp = 0;
	LET vMontoret = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF iInTrans = 1 THEN
				BEGIN WORK;
			END IF;
			RETURN cCodRet, iNoRegs;				
		END EXCEPTION;

		ON EXCEPTION IN(-535)
			LET iInTrans = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		--
		--ON EXCEPTION IN(-255)
		--	LET iInTrans = 1;
		--	COMMIT WORK;
		--	BEGIN WORK;
		--END EXCEPTION WITH RESUME;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_devolucionextemporanea_tef.out';
		-- TRACE ON;
				
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaArch = '' OR pPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		BEGIN WORK;
		--	
		--IF iInTrans = 0 THEN
		--	COMMIT WORK;
		--END IF
			
		--Consulta de parametros
		SET ISOLATION TO DIRTY READ;
		SELECT FIRST 1 valor 
		INTO cValorSucContTef
		FROM bditef:tef_parametros 
		WHERE cod_param = '77';
		
		SET ISOLATION TO DIRTY READ;
		SELECT FIRST 1 valor 
		INTO cValorTransacCargoTef
		FROM bditef:tef_parametros 
		WHERE cod_param = '78';
		
		--Consulta de folio nomina
		EXECUTE FUNCTION bdicheq:"informix".sp_generafolionomina(pUsuario) INTO cCodRetSp , cNumeroFolio;
		IF cCodRetSp::INTEGER > 0 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
				
		-- Se recorre la tabla
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD SELECT idx, fecha_abono, cuenta, referencia, banco, importe, estatus, confirmado, num_secuencia, clave_rastreo, cve_status, motivo_devolucion, estatus_reg
			INTO iIdx, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus, vsMotDev, vsEstatusReg
			FROM bdicnweb:"informix".sw_tf_consdevext_tef
			WHERE motivo_devolucion != '' and estatus_reg = 'P'

			LET vsAuxTarjeta = '';
			LET vsAuxCta = '';
			LET cCodRetSp = '';
			LET vsImporteAux = '';

			LET vsImporteAux = SUBSTRING(TRIM(vsImporte) FROM 1 FOR (LENGTH(vsImporte)-2)) ||'.'||SUBSTRING(TRIM(vsImporte) FROM (LENGTH(vsImporte)-1) FOR  2);
			
			IF SUBSTRING(TRIM(vsCuenta) FROM  1 FOR 4) = '0000' THEN
				LET vsAuxTarjeta = SUBSTRING(TRIM(vsCuenta) FROM  5 FOR 16);
			ELIF SUBSTRING(TRIM(vsCuenta) FROM  1 FOR 2) = '00' THEN
				LET vsAuxCta = SUBSTRING(TRIM(vsCuenta) FROM  9 FOR 11);
			END IF;
			
			IF vsAuxCta = '' AND vsAuxTarjeta !='' THEN 
				EXECUTE FUNCTION bdicheq:"informix".sp_obtener_cta_con_num_tar('001', vsAuxTarjeta) INTO cCodRetSp, vsAuxCta;
			END IF;
			
			---genera cargo
			EXECUTE FUNCTION bdicheq:"informix".cargo_ref('001', cValorSucContTef, pUsuario, cValorTransacCargoTef, '0000', cNumeroFolio, vsAuxCta, 0, vsImporteAux, '01', vsClaveRastreo, vsAuxTarjeta, pUsuario) INTO cCodRetSp, vTranret, vFechoy, vSdodisp, vMontoret;

			IF cCodRetSp::INTEGER > 0 OR cCodRetSp::INTEGER < 0 THEN 
				--Graba error
				SET LOCK MODE TO WAIT 3;
				INSERT INTO bditef:"informix".tef_errores (fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
				VALUES (CURRENT::DATE, CURRENT, cCodRetSp, '','bdicheq:cargo_ref','', pUsuario, CURRENT::DATE);
			ELSE 
				FOREACH EXECUTE FUNCTION bditef:"informix".sp_consdevext_tef('2', vsFechaAbono, vsMotDev , vsNumSecuencia, vsCuenta , vsReferencia)
					INTO cCodRetSp, vsFechaAbono, vsCuenta, vsReferencia, vsBanco, vsImporte, vsEstatus, vsConfirmado, vsNumSecuencia, vsClaveRastreo, vsCveStatus
				END FOREACH;
				LET iNoRegs = iNoRegs + 1;
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_tf_consdevext_tef
			SET estatus_reg = 'E', motivo_devolucion = ''
			WHERE idx = iIdx;		
			
			--IF iInTrans=1 THEN
			--	COMMIT WORK;
			--	BEGIN WORK;
			--END IF;
			
			--COMMIT WORK;
			
			IF iInTrans = 1 THEN
				COMMIT;
				BEGIN WORK;
			ELSE
				COMMIT WORK;
			END IF;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
	--r	-- Notificación de correo electronico
	--r	SELECT total_registros, total_monto
	--r	INTO iTotalRegs, mTotalMonto
	--r	FROM sw_tr_totales_masivo
	--r	WHERE id_funcion = pIdFuncion AND id_lote = pLote;
	--r	
	--r	LET dFechaMail = current;
	--r	EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
	--r		('1'
	--r		, TRIM(pPlantilla)
	--r		, TRIM(pPlantilla)			
	--r		, pUsuario
	--r		,''
	--r		,''
	--r		,'1'
	--r		, pLote
	--r		,NVL(iTotalRegs, 0)
	--r		,TRIM(TO_CHAR(NVL(mTotalMonto, 0.00), "#,###,###,###,###.##"))
	--r		,''
	--r		,''
	--r		,''
	--r		,''
	--r		,''
	--r		,''
	--r		, TRIM(pTituloPlantilla)
	--r		,''
	--r		,''
	--r		,'0'
	--r		,'0'
	--r		,'0'
	--r		,'0'
	--r		,'0'
	--r		,dFechaMail
	--r		,dFechaMail) INTO cCodRetSp;
	--r	
		--IF iInTrans = 1 THEN
		--	BEGIN WORK;
		--END IF;
		
		RETURN cCodRet, iNoRegs;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Rodolfo Conde Flores",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza las devoluciones extemporaneas Tef SOCWEB",
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dispersionafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(30))
					
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;	
		DEFINE cHoraProceso CHAR(21);
		DEFINE cHoraServidor CHAR(21);
		DEFINE pTipoArchivo CHAR(1);
		DEFINE cMensajeRet CHAR(50);
		DEFINE iRecuperacion INTEGER;
		DEFINE bInTrans BOOLEAN;
		
		LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;	
		LET cHoraProceso = '';
		LET cHoraServidor = '';
		LET pTipoArchivo = '';
		LET cMensajeRet = '';
		LET iRecuperacion = 0;
		LET bInTrans = 'f';

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
			
			ON EXCEPTION IN (-535)
				LET bInTrans = 't';
				COMMIT WORK;
			END EXCEPTION WITH RESUME;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_dispersionafore.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA El LIMITE DE HORARIO PERMITIDO
			SELECT valor INTO cHoraProceso FROM bdisac:"informix".sac_param WHERE cod_param = '6036';
			IF cHoraProceso = '' OR cHoraProceso IS NULL THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA LA HR DEL SERVIDOR
			EXECUTE PROCEDURE bdiprog:"informix".sp_validahoraejec('001') INTO cCodRetSp, cHoraServidor;
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_validahoraejec';
			ELIF cCodRetSp::INTEGER > 0 THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- VALIDA NOMENCLATURA		
			IF SUBSTRING(pNombreArchivo FROM 15 FOR 2) = 'OB' THEN 
				IF (cHoraServidor > cHoraProceso) THEN
					LET cCodRet = '00434';
					RETURN cCodRet;
				ELSE
					LET pTipoArchivo = '2';
				END IF;
			ELSE 
				LET pTipoArchivo = '1';
			END IF;
		 
			-- GENERA EL LLAMADO AL PROCESO DE PAGOS DE ARCHIVOS
			BEGIN WORK;
			IF bInTrans = 'f' THEN
				COMMIT WORK;
			END IF;
			
			EXECUTE PROCEDURE bdiprog:"informix".sp_afore_dispersion(pNombreArchivo, pUsuario, pTipoArchivo) 
			INTO cCodRetSp, cMensajeRet;
			
			IF bInTrans = 't' THEN
				BEGIN WORK;
			END IF;
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_afore_dispersion';
			ELIF cCodRetSp::INTEGER = 10000 THEN
				LET cCodRet = '00481'; 
			ELIF cCodRetSp::INTEGER = 10001 THEN	
				LET cCodRet = '00482'; 
			ELIF cCodRetSp::INTEGER = 10002 THEN
				LET cCodRet = '00483'; 
			ELIF cCodRetSp::INTEGER = 10003 THEN	
				LET cCodRet = '00484'; 
			ELIF cCodRetSp::INTEGER = 10004 THEN
				LET cCodRet = '00485'; 
			ELIF cCodRetSp::INTEGER = 10005 THEN	
				LET cCodRet = '00486'; 
			ELIF cCodRetSp::INTEGER = 10006 THEN
				LET cCodRet = '00487';
			ELIF cCodRetSp::INTEGER = 10007 THEN
				LET cCodRet = '00488';
			ELIF cCodRetSp::INTEGER = 10008 THEN
				LET cCodRet = '00489'; 
			ELIF cCodRetSp::INTEGER = 10009 THEN	
				LET cCodRet = '00490'; 
			ELIF cCodRetSp::INTEGER = 10010 THEN	
				LET cCodRet = '00491';
			ELIF cCodRetSp::INTEGER = 10011 THEN
				LET cCodRet = '00492'; 
			ELIF cCodRetSp::INTEGER = 10012 THEN
				LET cCodRet = '00493'; 
			ELIF cCodRetSp::INTEGER = 10013 THEN	
				LET cCodRet = '00494';
			ELIF cCodRetSp::INTEGER = 10014 THEN	
				LET cCodRet = '00438'; 
			ELIF cCodRetSp::INTEGER = 10015 THEN
				LET cCodRet = '00495';
			ELIF cCodRetSp::INTEGER = 10016 THEN
				LET cCodRet = '00496'; 
			ELIF cCodRetSp::INTEGER = 10017 THEN
				LET cCodRet = '00497';
			ELIF cCodRetSp::INTEGER = 10018 THEN	
				LET cCodRet = '00498'; 
			ELIF cCodRetSp::INTEGER = 10019 THEN	
				LET cCodRet = '00499';
			ELIF cCodRetSp::INTEGER = 10020 THEN	
				LET cCodRet = '00500'; 
			ELIF cCodRetSp::INTEGER = 10021 THEN
				LET cCodRet = '00501'; 
			ELIF cCodRetSp::INTEGER = 10022 THEN	
				LET cCodRet = '00496'; 
			ELIF cCodRetSp::INTEGER = 10023 THEN
				LET cCodRet = '00502'; 
			ELIF cCodRetSp::INTEGER = 10024 THEN	
				LET cCodRet = '00503';
			ELIF cCodRetSp::INTEGER = 10025 THEN	
				LET cCodRet = '00504'; 
			ELIF cCodRetSp::INTEGER = 10026 THEN	
				LET cCodRet = '00505'; 
			ELIF cCodRetSp::INTEGER = 10027 THEN	
				LET cCodRet = '00017'; 
			ELIF cCodRetSp::INTEGER = 10028 THEN
				LET cCodRet = '00506'; 
			ELIF cCodRetSp::INTEGER = 10029 THEN
				LET cCodRet = '00507'; 
			ELIF cCodRetSp::INTEGER = 10030 THEN
				LET cCodRet = '00508'; 
			ELIF cCodRetSp::INTEGER = 10031 THEN	
				LET cCodRet = '00509';
			ELIF cCodRetSp::INTEGER = 10032 THEN	
				LET cCodRet = '00510';
			ELIF cCodRetSp::INTEGER = 10549 THEN
				LET cCodRet = '00511'; 
			ELIF cCodRetSp::INTEGER = 10034 THEN
				LET cCodRet = '00512';
			ELIF cCodRetSp::INTEGER = 10035 THEN
				LET cCodRet = '00513'; 
			ELIF cCodRetSp::INTEGER = 10036 THEN
				LET cCodRet = '00514';
			END IF;
				
			RETURN cCodRet;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/05/2015',
'DESCRIPCION: SPL encargado de generar el pago de las cuentas de afore segÃºn el archivo y sus importes.',
'FUNCIONALIDAD: EjecuciÃ³n de Pagos Pendientes â Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportealtaoptef(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveRastreo CHAR(30))
		RETURNING CHAR(5) AS codret,
			DATE 	  AS fecha_trans,
			CHAR(30)  AS clave_rastreo,
			CHAR(10)  AS importe_tef,
			DATE 	  AS fecha_programacion,
			CHAR(45)  AS nombre_usuario,
			CHAR(16)  AS folio_suc,
			CHAR(30)  AS nombre_cte_ord,
			CHAR(20)  AS num_cte_ord,
			CHAR(20)  AS num_cta_ord,
			CHAR(30)  AS tipo_cta_ord_desc,
			CHAR(5)	  AS comision_tef,
			CHAR(5)	  AS iva_tef,
			CHAR(30)  AS nombre_ben,
			CHAR(30)  AS tipo_cta_ben_desc,
			CHAR(20)  AS num_cuenta_tarj_ben,
			CHAR(15)  AS rfc_ben,
			CHAR(50)  AS concepto_pago,
			CHAR(7)	  AS ref_num,
			CHAR(8)   AS hora_trans;

		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE dFechaTrans DATE;
		DEFINE cClaveRastreo CHAR(30);
		DEFINE cImporteTef CHAR(10);
		DEFINE dFechaProgramacion DATE;
		DEFINE cNombreUsuario CHAR(45);
		DEFINE cFolioSuc CHAR(16);
		DEFINE cNombreCteOrd CHAR(30);
		DEFINE cNumCteOrd CHAR(20);
		DEFINE cNumCtaOrd CHAR(20);
		--DEFINE cTipoCtaOrd CHAR(2);
		DEFINE cTipoCtaOrdDesc CHAR(30);
		DEFINE cComisionTef CHAR(5);
		DEFINE cIvaTef CHAR(5);
		DEFINE cNombreBen CHAR(30);
		--DEFINE cTipoCtaBen CHAR(2);
		DEFINE cTipoCtaBenDes CHAR(30);
		DEFINE cNumCtaTarjBen CHAR(20);
		DEFINE cRfcBen CHAR(15);
		DEFINE cConceptoPago CHAR(50);
		DEFINE cRefNum CHAR(7);
		--DEFINE cUsuario CHAR(8);
		DEFINE cHoraTrans CHAR(8);
		DEFINE iNoRegistros INTEGER;

		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET dFechaTrans = '';
		LET cClaveRastreo = '';
		LET cImporteTef = '';
		LET dFechaProgramacion = '';
		LET cNombreUsuario = '';
		LET cFolioSuc = '';
		LET cNombreCteOrd = '';
		LET cNumCteOrd = '';
		LET cNumCtaOrd = '';
		--LET cTipoCtaOrd = '';
		LET cTipoCtaOrdDesc = '';
		LET cComisionTef = '';
		LET cIvaTef = '';
		LET cNombreBen = '';
		--LET cTipoCtaBen = '';
		LET cTipoCtaBenDes = '';
		LET cNumCtaTarjBen = '';
		LET cRfcBen = '';
		LET cConceptoPago = '';
		LET cRefNum = '';
		--LET cUsuario = '';
		LET cHoraTrans = '';
		LET iNoRegistros = 0;

		BEGIN

			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			END EXCEPTION;

            -- SET DEBUG FILE TO '/tmp/mfinis/sp_genreportealtaoptef.out';
            -- TRACE ON;

            IF pUsuario = '' OR pIdFuncion = '' OR pClaveRastreo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
            END IF;

            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			END IF;

			SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;

			EXECUTE PROCEDURE bditef:"informix".sp_tef_obtinforpt(pClaveRastreo)
			INTO cCodRetSp, cDescCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc,
				 cNombreCteOrd, cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes,
				 cNumCtaTarjBen, cRfcBen, cConceptoPago, cRefNum, cHoraTrans;

			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_obtinforpt';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			END IF;

			IF cCodRetSp::INTEGER = 0 THEN
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, dFechaTrans, UPPER(cClaveRastreo), cImporteTef, dFechaProgramacion, UPPER(cNombreUsuario), cFolioSuc, UPPER(cNombreCteOrd),
			           cNumCteOrd, cNumCtaOrd, UPPER(cTipoCtaOrdDesc), cComisionTef, cIvaTef, UPPER(cNombreBen), UPPER(cTipoCtaBenDes), cNumCtaTarjBen,
			           UPPER(cRfcBen), UPPER(cConceptoPago), cRefNum, cHoraTrans;
			END IF;

			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dFechaTrans, cClaveRastreo, cImporteTef, dFechaProgramacion, cNombreUsuario, cFolioSuc, cNombreCteOrd,
			           cNumCteOrd, cNumCtaOrd, cTipoCtaOrdDesc, cComisionTef, cIvaTef, cNombreBen, cTipoCtaBenDes, cNumCtaTarjBen,
			           cRfcBen, cConceptoPago, cRefNum, cHoraTrans;
			END IF;

		END;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 05/08/2015',
'DESCRIPCION: SPL que se encarga de obtener la informacion para visualizar el reporte de alta operaciones TEF.',
'FUNCIONALIDAD: Captura de Operaciones TEF',
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportepagdiariosafore(pUsuario CHAR(8),pIdFuncion CHAR(10),pFechaConsulta DATE, pRegistros INTEGER, pRecuperacion INTEGER)
					
		RETURNING CHAR(5) AS codret,
			CHAR(18) AS clabe,
			CHAR(40) AS tipo_cuenta,
			CHAR(120) AS nombre_cliente,
			MONEY(17,2) AS importe,
			MONEY(17,2) AS comision,
			DECIMAL(18,2) AS iva,
			CHAR(30) AS estados_pago,
			CHAR(2) AS estado,
			DATE AS fecha_hoy,
			INTEGER AS num_total_pagados,
			MONEY(17,2) AS imp_total_pagados,
			INTEGER AS num_total_no_pagados,
			MONEY(17,2) AS imp_total_no_pagados,
			CHAR(1) AS tipo_archivo;
		
			
		DEFINE cCodRet 			   CHAR(5);
		DEFINE cCodRetSp           CHAR(6);
        DEFINE iSqlErr             INTEGER;
		DEFINE cCLABE              CHAR(18);
		DEFINE cTipoCuenta         CHAR(40);
		DEFINE cNombreCliente      CHAR(120);
		DEFINE mImporte            MONEY(17,2);
		DEFINE mComision           MONEY(17,2);
		DEFINE dIVA                DECIMAL(18,2);
		DEFINE cEstadosPago        CHAR(30);
		DEFINE cEstado             CHAR(2);
		DEFINE dFechaHoy           DATE;
		DEFINE iNumTotalPagados    INTEGER;
		DEFINE mImpTotalPagados    MONEY(17,2);
		DEFINE iNumTotalNoPagados  INTEGER;
		DEFINE mImpTotalNoPagados  MONEY(17,2);
		DEFINE cTipoArchivo        CHAR(1);
		DEFINE iRecuperacion       INTEGER;
		
		LET cCodRet 		       = '00000';
		LET cCodRetSp              = '';
        LET iSqlErr                = 0;	
		LET cCLABE                 = '';
		LET cTipoCuenta            = '';
		LET cNombreCliente         = '';
		LET mImporte               = 0.00;
		LET mComision              = 0.00;
		LET dIVA                   = 0.00;
		LET cEstadosPago           = '';
		LET cEstado                = '';
		LET dFechaHoy              = '';
		LET iNumTotalPagados       = 0;
		LET mImpTotalPagados       = 0.00;
		LET iNumTotalNoPagados     = 0;
		LET mImpTotalNoPagados     = 0.00;
		LET cTipoArchivo           = '';
		LET iRecuperacion          = 0;
		

		BEGIN		
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
					   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_genreportepagdiariosafore.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
					   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
					   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
			END IF;
			
			FOREACH
				EXECUTE PROCEDURE bdiprog:"informix".sp_aforegenerarreportedetallepagosdiarios2(pFechaConsulta, pRegistros, pRecuperacion) 
				INTO cCodRetSp,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
					 cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo
				
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdiprog:sp_aforegenerarreportedetallepagosdiarios';
				ELIF cCodRetSp::INTEGER = 10010 THEN	
					LET cCodRet = '00491'; 
					RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
						   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
				ELSE
					IF cCLABE <> "" AND cTipoCuenta <> "" AND cNombreCliente <> ""  AND cEstadosPago <> "" AND cEstado <> "" THEN
						LET iRecuperacion = iRecuperacion + 1;
						RETURN cCodRet,cCLABE,UPPER(cTipoCuenta),UPPER(cNombreCliente),mImporte,mComision,dIVA,UPPER(cEstadosPago),
							   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo WITH RESUME;
					END IF;
				END IF;
			END FOREACH;

			IF iRecuperacion = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00017'; 
				ELIF pRegistros > 0 THEN
					LET cCodRet = '1001'; 
				END IF;
				RETURN cCodRet,cCLABE,cTipoCuenta,cNombreCliente,mImporte,mComision,dIVA,cEstadosPago,
			   cEstado,dFechaHoy,iNumTotalPagados,mImpTotalPagados,iNumTotalNoPagados,mImpTotalNoPagados,cTipoArchivo;
			END IF;
		END;
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 04/06/2015',
'DESCRIPCION: SPL que realiza la consulta para obtener el detalle de pagos diarios afore.',
'AUTOR: Esparza Brenis Fernando Martín',
'FECHA: 28/09/2015',
'DESCRIPCION: Se modifica el SPL para que no regrese registros en blanco y se agrega paginado',
'FUNCIONALIDAD: Reportes de Pagos de Afore  Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporteresumpagafore(pUsuario CHAR(8),pIdFuncion CHAR(10),pFechaConsulta DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret, 
			DATE AS fecha_hoy,
			DATE AS fecha_pago,
			INTEGER AS num_operacion,
			DECIMAL(16, 2) AS comision,
			DECIMAL(16, 2) AS total_iva,
			DECIMAL(16, 2) AS total,
			CHAR(1) AS tipo_archivo;
		

		DEFINE cCodRet 			CHAR(5);
		DEFINE cCodRetSp        CHAR(6);
        DEFINE iSqlErr          INTEGER;
		DEFINE dFechaHoy        DATE;
		DEFINE dFechaPago       DATE;
		DEFINE iNumOperacion    INTEGER;
		DEFINE dComision        DECIMAL(16, 2); 
		DEFINE dTotalIva        DECIMAL(16, 2); 
		DEFINE dTotal           DECIMAL(16, 2); 
		DEFINE cTipoArchivo     CHAR(1);
		DEFINE iRecuperacion    INTEGER;
		
		LET cCodRet 		    = '00000';
		LET cCodRetSp           = '';
        LET iSqlErr             = 0;	
		LET dFechaHoy           = '';
		LET dFechaPago          = '';
		LET iNumOperacion       = 0;
		LET dComision           = 0.00; 
		LET dTotalIva           = 0.00; 
		LET dTotal              = 0.00; 
		LET cTipoArchivo        = '';
		LET iRecuperacion       = 0;
		
		BEGIN		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_genreporteresumpagafore.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
			END IF;
			
			FOREACH
				EXECUTE PROCEDURE bdiprog:"informix".sp_aforegenerarreporteresumpagproc2(pFechaConsulta, pRegistros, pRecuperacion) 
				INTO cCodRetSp, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo
				
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdiprog:sp_aforegenerarreporteresumpagproc';
				ELIF cCodRetSp::INTEGER = 10015 THEN	
					LET cCodRet = '00003'; 
					RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
				ELSE
					IF dFechaPago IS NOT NULL THEN 
						LET iRecuperacion = iRecuperacion + 1;
						RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo WITH RESUME;
					END IF;
				END IF;
			END FOREACH;
			
			IF iRecuperacion = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00017'; 
				ELIF pRegistros > 0 THEN
					LET cCodRet = '1001'; 
				END IF;
				RETURN cCodRet, dFechaHoy, dFechaPago, iNumOperacion, dComision, dTotalIva, dTotal, cTipoArchivo;
			END IF;
		END;
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat León Amador', 
'FECHA: 04/06/2015',
'DESCRIPCION: SPL que realiza la consulta para obtener el resumen de pagos mensuales, totalizados por día.',
'Mostrando así la cantidad de pagos que fueron procesados diariamente, el detalle diario de las comisiones a cobrar,',
'el iva total calculado en base al total de la comision en el mes y el total de comisión más iva en el mes.',
'AUTOR: Esparza Brenis Fernando Martín', 
'FECHA: 30/09/2015',
'DESCRIPCION: Se le agrega paginado.',
'FUNCIONALIDAD: Reportes de Pagos de Afore  Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_grabaoperaciontef(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pNumeroCtaOrd CHAR(20),
	pTipoCtaOrd CHAR(2), pFechaProg DATE, pCveRastreo CHAR(30), pNombreCteOrd CHAR(30), pRfcCteOrd CHAR(15), pImpTef CHAR(10),
	pComisionTef CHAR(5), pIvaTef CHAR(5), pImpTotTef CHAR(10), pTipoCtaBen CHAR(2), pNombreBen CHAR(30), pNumCtaTarjBen CHAR(20),
	pCveBancoRec CHAR(3), pRfcBen CHAR(15), pConceptoPago CHAR(50), pRefNum CHAR(7), pReferencia CHAR(40), pNumCuenta CHAR(20))
	
		RETURNING CHAR(5) AS codret,
			CHAR(5) AS codret_reversion;
		
		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetOpTef CHAR(5);
		DEFINE cCodRetRev CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cFechaHoy CHAR(10);
		DEFINE cHoraFolio CHAR(10);
		DEFINE cFolioSucursal CHAR(16);
		DEFINE cEmpresa CHAR(3);
		DEFINE cSucursal CHAR(4);
		DEFINE cTipoOperacion CHAR(2);
		DEFINE cCveCanal CHAR(2);
		DEFINE cMotivoDev CHAR(2);
		DEFINE cDivisa CHAR(2);
		DEFINE cTransacSuc CHAR(4);
		DEFINE cNumeroCtaOrd CHAR(20);
		DEFINE cNumTarjeta CHAR(16);
		DEFINE iNoRegistros INTEGER;
		DEFINE bInTrans BOOLEAN;
		
		LET cCodRet = '00000';
		LET cCodRetOpTef = '00000';
		LET cCodRetRev = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cFechaHoy = '';
		LET cHoraFolio = '';
		LET cFolioSucursal = '';
		LET cEmpresa = '001';
		LET cSucursal = '9250';
		LET cTipoOperacion = '01';
		LET cCveCanal = '02';
		LET cMotivoDev = '00';
		LET cDivisa = '01';
		LET cTransacSuc = '0000';
		LET cNumeroCtaOrd = '';
		LET cNumTarjeta = ''; 
		LET iNoRegistros = 0;
		LET bInTrans = 'f';

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,cCodRetRev;
			END EXCEPTION;
			
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_grabaoperaciontef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pNumeroCtaOrd = '' OR pTipoCtaOrd = '' OR pFechaProg IS NULL OR pCveRastreo = '' 
			OR pNombreCteOrd = '' OR pRfcCteOrd = '' OR pImpTef = '' OR pComisionTef = '' OR pIvaTef = '' OR pImpTotTef = '' OR pTipoCtaBen = '' 
			OR pNombreBen = '' OR pNumCtaTarjBen = '' OR pConceptoPago = '' OR pRefNum = '' OR pReferencia = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cCodRetRev;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,cCodRetRev;
			END IF;
		 
			SET ISOLATION TO DIRTY READ;
			
			-- CONSULTA FECHA ACTUAL
			SELECT fecha_hoy INTO cFechaHoy FROM bdinvers:"informix".sv_fechas WHERE empresa = '001';	
			
			-- CONSULTA HORA
			LET cHoraFolio = TO_CHAR(CURRENT,'%H%M%S%F');
			IF NVL(cHoraFolio,'') = '' THEN
				LET cCodRet = '00573';
				RETURN cCodRet,cCodRetRev;
			ELSE
				LET cFolioSucursal = TRIM(pUsuario) || TRIM(cHoraFolio);
			END IF;
			
			IF pTipoCtaOrd = '40' THEN        --CUENTA
				LET cNumeroCtaOrd = pNumeroCtaOrd;
				LET cNumTarjeta = '';
			ELSE --pTipoCtaOrd = '03' THEN    --TARJETA
				LET cNumeroCtaOrd = pNumCuenta; 
				LET cNumTarjeta = pNumeroCtaOrd;
			END IF;
			
			
			BEGIN -- Bloque de la primera ejecuciÃ³n
				-- EJECUTA pTipo = '1'
				
				ON EXCEPTION IN (-255)
				END EXCEPTION WITH RESUME;
				
				ON EXCEPTION IN (-535)
					COMMIT WORK;
					LET bInTrans = 't';
					BEGIN WORK;
				END EXCEPTION WITH RESUME;
				
				BEGIN WORK;
					EXECUTE PROCEDURE bditef:"informix".sp_tef_grabaoperacion(pTipo,cEmpresa,cFechaHoy,cFolioSucursal,cSucursal,cNumeroCtaOrd,
						pTipoCtaOrd,pFechaProg,cTipoOperacion,pCveRastreo,TRIM(pNombreCteOrd),pRfcCteOrd,pImpTef,pComisionTef,pIvaTef,
						pImpTotTef,pTipoCtaBen,TRIM(pNombreBen),pNumCtaTarjBen,pCveBancoRec,pRfcBen,TRIM(pConceptoPago),pRefNum,
						TRIM(pReferencia),cCveCanal,cMotivoDev,cDivisa,cTransacSuc,cNumTarjeta,pUsuario)
					INTO cCodRetSp, cDescCodRet;
				COMMIT;
				
				IF bInTrans = 't' THEN
					BEGIN WORK;
				END IF;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_grabaoperacion';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00574'; 
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00562';
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00563'; 
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00003'; 
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00575'; 
				ELIF cCodRetSp::INTEGER = 6 THEN
					LET cCodRet = '00576'; 
				ELIF cCodRetSp::INTEGER = 11 THEN
					LET cCodRet = '00577'; 
				ELIF cCodRetSp::INTEGER = 13 THEN
					LET cCodRet = '00578'; 
				ELIF cCodRetSp::INTEGER = 100 THEN
					LET cCodRet = '00121';
				ELIF cCodRetSp::INTEGER = 106 THEN
					LET cCodRet = '00581'; 
				ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00582'; 
				ELIF cCodRetSp::INTEGER = 200 THEN
					LET cCodRet = '00456'; 
				ELIF cCodRetSp::INTEGER = 211 THEN
					LET cCodRet = '00105'; 
				ELIF cCodRetSp::INTEGER = 300 THEN
					LET cCodRet = '00392'; 
				ELIF cCodRetSp::INTEGER = 400 THEN
					LET cCodRet = '00460'; 
				ELIF cCodRetSp::INTEGER = 420 THEN
					LET cCodRet = '00118'; 
				ELIF cCodRetSp::INTEGER = 500 THEN
					LET cCodRet = '00583'; 
				ELIF cCodRetSp::INTEGER = 520 THEN
					LET cCodRet = '00584';
				ELIF cCodRetSp::INTEGER = 549 THEN
					LET cCodRet = '00457'; 
				ELIF cCodRetSp::INTEGER = 550 THEN
					LET cCodRet = '00458'; 
				ELIF cCodRetSp::INTEGER = 560 THEN
					LET cCodRet = '00585';
				ELIF cCodRetSp::INTEGER = 600 THEN
					LET cCodRet = '00586'; 
				ELIF cCodRetSp::INTEGER = 700 THEN
					LET cCodRet = '00587';
				ELIF cCodRetSp::INTEGER = 701 THEN
					LET cCodRet = '00588'; 
				ELIF cCodRetSp::INTEGER = 702 THEN
					LET cCodRet = '00589'; 
				ELIF cCodRetSp::INTEGER = 703 THEN
					LET cCodRet = '00590'; 
				ELIF cCodRetSp::INTEGER = 704 THEN
					LET cCodRet = '00591';
				ELIF cCodRetSp::INTEGER = 705 THEN
					LET cCodRet = '00592'; 
				ELIF cCodRetSp::INTEGER = 777 THEN
					LET cCodRet = '00459'; 
				ELIF cCodRetSp::INTEGER = 951 THEN
					LET cCodRet = '00127'; 
				ELIF cCodRetSp::INTEGER = 957 THEN
					LET cCodRet = '00593'; 
				ELIF cCodRetSp::INTEGER = 962 THEN
					LET cCodRet = '00455'; 
				ELIF cCodRetSp::INTEGER = 999 THEN
					LET cCodRet = '00454'; 
				END IF;
				
				IF cCodRet <> '00000' THEN
					EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa,'9250',pUsuario,cFolioSucursal,'')
					INTO cCodRetSp;
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:reversion';
					ELIF cCodRetSp::INTEGER = 170 THEN
						LET cCodRetRev = '00112'; 
					ELIF cCodRetSp::INTEGER = 413 THEN
						LET cCodRetRev = '00113'; 
					ELIF cCodRetSp::INTEGER = 999 THEN
						LET cCodRetRev = '00454'; 
					END IF;
					
					RETURN cCodRet,cCodRetRev;
					
				END IF;
				
			END; -- Fin del primer bloque de ejecuciÃ³n
			
			BEGIN -- Bloque de la segundo ejecuciÃ³n
				-- EJECUTA pTipo = '1'
				
				ON EXCEPTION IN (-255)
				END EXCEPTION WITH RESUME;
				
				ON EXCEPTION IN (-535)
					COMMIT WORK;
					LET bInTrans = 't';
					BEGIN WORK;
				END EXCEPTION WITH RESUME;
				
				
				LET pTipo = 2;
				BEGIN WORK;
					EXECUTE PROCEDURE bditef:"informix".sp_tef_grabaoperacion(pTipo,cEmpresa,cFechaHoy,cFolioSucursal,cSucursal,cNumeroCtaOrd,
						pTipoCtaOrd,pFechaProg,cTipoOperacion,pCveRastreo,TRIM(pNombreCteOrd),pRfcCteOrd,pImpTef,pComisionTef,pIvaTef,
						pImpTotTef,pTipoCtaBen,TRIM(pNombreBen),pNumCtaTarjBen,pCveBancoRec,pRfcBen,TRIM(pConceptoPago),pRefNum,
						TRIM(pReferencia),cCveCanal,cMotivoDev,cDivisa,cTransacSuc,cNumTarjeta,pUsuario)
					INTO cCodRetSp, cDescCodRet;
				COMMIT;
				
				IF bInTrans = 't' THEN
					BEGIN WORK;
				END IF;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_grabaoperacion';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00574'; 
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00562';
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00563'; 
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00003'; 
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00575'; 
				ELIF cCodRetSp::INTEGER = 6 THEN
					LET cCodRet = '00576'; 
				ELIF cCodRetSp::INTEGER = 11 THEN
					LET cCodRet = '00577'; 
				ELIF cCodRetSp::INTEGER = 13 THEN
					LET cCodRet = '00578'; 
				ELIF cCodRetSp::INTEGER = 100 THEN
					LET cCodRet = '00121';
				ELIF cCodRetSp::INTEGER = 106 THEN
					LET cCodRet = '00581'; 
				ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00582'; 
				ELIF cCodRetSp::INTEGER = 200 THEN
					LET cCodRet = '00456'; 
				ELIF cCodRetSp::INTEGER = 211 THEN
					LET cCodRet = '00105'; 
				ELIF cCodRetSp::INTEGER = 300 THEN
					LET cCodRet = '00392'; 
				ELIF cCodRetSp::INTEGER = 400 THEN
					LET cCodRet = '00460'; 
				ELIF cCodRetSp::INTEGER = 420 THEN
					LET cCodRet = '00118'; 
				ELIF cCodRetSp::INTEGER = 500 THEN
					LET cCodRet = '00583'; 
				ELIF cCodRetSp::INTEGER = 520 THEN
					LET cCodRet = '00584';
				ELIF cCodRetSp::INTEGER = 549 THEN
					LET cCodRet = '00457'; 
				ELIF cCodRetSp::INTEGER = 550 THEN
					LET cCodRet = '00458'; 
				ELIF cCodRetSp::INTEGER = 560 THEN
					LET cCodRet = '00585';
				ELIF cCodRetSp::INTEGER = 600 THEN
					LET cCodRet = '00586'; 
				ELIF cCodRetSp::INTEGER = 700 THEN
					LET cCodRet = '00587';
				ELIF cCodRetSp::INTEGER = 701 THEN
					LET cCodRet = '00588'; 
				ELIF cCodRetSp::INTEGER = 702 THEN
					LET cCodRet = '00589'; 
				ELIF cCodRetSp::INTEGER = 703 THEN
					LET cCodRet = '00590'; 
				ELIF cCodRetSp::INTEGER = 704 THEN
					LET cCodRet = '00591';
				ELIF cCodRetSp::INTEGER = 705 THEN
					LET cCodRet = '00592'; 
				ELIF cCodRetSp::INTEGER = 777 THEN
					LET cCodRet = '00459'; 
				ELIF cCodRetSp::INTEGER = 951 THEN
					LET cCodRet = '00127'; 
				ELIF cCodRetSp::INTEGER = 957 THEN
					LET cCodRet = '00593'; 
				ELIF cCodRetSp::INTEGER = 962 THEN
					LET cCodRet = '00455'; 
				ELIF cCodRetSp::INTEGER = 999 THEN
					LET cCodRet = '00454'; 
				END IF;
				
				IF cCodRet <> '00000' THEN
					EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa,'9250',pUsuario,cFolioSucursal,'')
					INTO cCodRetSp;
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:reversion';
					ELIF cCodRetSp::INTEGER = 170 THEN
						LET cCodRetRev = '00112'; 
					ELIF cCodRetSp::INTEGER = 413 THEN
						LET cCodRetRev = '00113'; 
					ELIF cCodRetSp::INTEGER = 999 THEN
						LET cCodRetRev = '00454'; 
					END IF;
					
					RETURN cCodRet,cCodRetRev;
				ELSE
					LET iNoRegistros = iNoRegistros + 1;
				END IF;

			END; -- Fin del segundo bloque de ejecuciÃ³n

			IF iNoRegistros = 0 THEN
				LET cCodRet = '00236'; --'ERROR AL PROCESAR LA SOLICITUD'
			END IF;	
			
			RETURN cCodRet,cCodRetRev;	
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 04/08/2015',
'DESCRIPCION: SPL que se encarga de realizar el alta de operaciones TEF en central.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtienecverastreotef(pUsuario CHAR(8), pIdFuncion CHAR(10))	
		RETURNING CHAR(5) AS codret,          
			CHAR(30) AS clave_rastreo;
		
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cEmpresa CHAR(3);
		DEFINE cCveRastreo CHAR(30);		
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cEmpresa = '001';
		LET cCveRastreo = '';
		LET iNoRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cCveRastreo;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_obtienecverastreotef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCveRastreo;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCveRastreo;
			END IF;
		 
			SET ISOLATION TO DIRTY READ;
			
			EXECUTE PROCEDURE bditef:"informix".sp_obtienecveratreo('9250',pUsuario)
			INTO cCodRetSp, cCveRastreo;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_obtienecveratreo';
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '00003'; 
				RETURN cCodRet, cCveRastreo;
			ELIF cCodRetSp::INTEGER = 4 THEN
				LET cCodRet = '00572'; --EL NÃMERO CONSECUTIVO TEF ESTÃ VACÃO
				RETURN cCodRet, cCveRastreo;
			END IF;

			IF cCodRetSp::INTEGER = 0 THEN	
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(cCveRastreo);
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00579'; --NO FUE POSIBLE OBTENER LA CLAVE DE RASTREO, VERIFIQUE
				RETURN cCodRet, cCveRastreo;		
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 31/07/2015',
'DESCRIPCION: SPL que se encarga de obtener la clave de rastreo para las operaciones TEF.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesarchivosprocesarafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoBusqueda CHAR(1),
		pTipoArchivo CHAR(1), pNombreArchivo CHAR(30), pFechaInicial DATE, pFechaFinal DATE, pEstatus CHAR(2))
					
		RETURNING CHAR(5) AS codret,  
			INTEGER AS totalRegistros; 		  
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE iTotalRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET iTotalRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, iTotalRegistros; 
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesarchivosprocesarafore.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoBusqueda = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros; 
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros;  
			END IF;
				
			-- VALIDA TIPO DE BUSQUEDA
			IF pTipoBusqueda = '1' THEN
			
				LET pTipoArchivo = 'P';
				LET pNombreArchivo = '';
				LET pFechaInicial = DATE(CURRENT);
				LET pFechaFinal = DATE(CURRENT);
				LET pEstatus = '19';
				
			ELIF pTipoBusqueda = '2' THEN	
				
				IF NVL(pFechaInicial, '') = '' AND NVL(pFechaFinal, '') = '' THEN
					LET pFechaInicial = MDY(1,1,1900);
					LET pFechaFinal = MDY(1,1,1900);
                END IF
			
			END IF;
			
			FOREACH
				EXECUTE PROCEDURE bdiprog:"informix".sp_aforebuscararchivosprocesar2_totales(pTipoArchivo,pNombreArchivo,pFechaInicial,pFechaFinal,pEstatus) 
				INTO cCodRetSp,iTotalRegistros				 
					 
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_aforebuscararchivosprocesar2_totales';
				END IF;
			END FOREACH;
				
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			ELSE
				RETURN cCodRet, iTotalRegistros;
			END IF;	

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/06/2015',
'DESCRIPCION: SPL que obtiene el numero total de archivos (de pago, confirmaciÃ³n y/o cifras de control) enviados por afore coppel.', 
'FUNCIONALIDAD: EjecuciÃ³n de Pagos Pendientes â Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesconsultarchivosafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(30))
			
		RETURNING CHAR(5) AS codret,  
			INTEGER AS totalRegistros; 
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE pTipoArchivo CHAR(1);
		DEFINE iTotalRegistros INTEGER;
		
		DEFINE cTipoRegistro                       CHAR(1); 	
		DEFINE cNoContratoEmpresaTmp               CHAR(10);	  
		DEFINE dFechaGenTmp                        DATE; 		  
		DEFINE dFechaInicialInformacionTmp         DATE; 		  
		DEFINE dFechaFinalInformacionTmp           DATE; 		  
		DEFINE cNoMovimientosContenidosTmp         CHAR(9); 	  
		DEFINE cFiller                             CHAR(232);	  
		DEFINE cFinLinea                           CHAR(2);   	  
		DEFINE cNSS                                CHAR(11); 	  
		DEFINE cNombreBeneficiario                 CHAR(40); 	  
		DEFINE cApellidoPaternoBeneficiario        CHAR(40); 	  
		DEFINE cApellidoMaternoBeneficiario        CHAR(40); 	  
		DEFINE cFormasPago                         CHAR(1); 	  
		DEFINE cCLABE                              CHAR(18); 	  
		DEFINE dFechaCaptura                       DATE; 	  
		DEFINE cImporteDocumentoNetoPagar          CHAR(15); 	  
		DEFINE cImporteDocumentoAntesImpuesto      CHAR(15); 	  
		DEFINE cImpuestoRetenido                   CHAR(11); 	  
		DEFINE cNumeroFolioServicio                CHAR(8); 	  
		DEFINE cNumeroTienda                       CHAR(4); 	  
		DEFINE cTipoRetiro                         CHAR(3); 	  
		DEFINE cConsecutivoRetiro                  CHAR(10); 	  
		DEFINE cCURP                               CHAR(18); 	  
		DEFINE cRFC                                CHAR(10); 	  
		DEFINE cFolio_suc                          CHAR(16); 	  
		DEFINE cNumeroTotalMovimientosContenidos   CHAR(2); 	  	
		DEFINE cImporteTotalNeto                   CHAR(17); 	  
		DEFINE cImporteTotalAntesImpuesto          CHAR(17); 	  
		DEFINE cImporteRetenido                    CHAR(17); 	  
		DEFINE cImporteTotalRetirosPagadosEfectivo CHAR(17); 	  
		DEFINE cImporteTotalRetirosPagadosDeposito CHAR(17); 	  
		DEFINE dFechaMovimientos                   DATE; 	  
		DEFINE cEstatus                            CHAR(2); 	  
		DEFINE iSumaMov                            INTEGER; 	  
		DEFINE mMonto                              MONEY(10,2);   
		DEFINE mSumaMonto                          MONEY(12,2);  
		DEFINE iNoRegistros 					   INTEGER;	
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET pTipoArchivo = '';
		LET iTotalRegistros = 0;
		
		LET cTipoRegistro                          = '';	
		LET cNoContratoEmpresaTmp                  = '';	  
		LET dFechaGenTmp                           = ''; 		  
		LET dFechaInicialInformacionTmp            = ''; 		  
		LET dFechaFinalInformacionTmp              = ''; 		  
		LET cNoMovimientosContenidosTmp            = '';	  
		LET cFiller                                = '';	  
		LET cFinLinea                              = ''; 	  
		LET cNSS                                   = '';	  
		LET cNombreBeneficiario                    = '';	  
		LET cApellidoPaternoBeneficiario           = '';	  
		LET cApellidoMaternoBeneficiario           = '';	  
		LET cFormasPago                            = '';	  
		LET cCLABE                                 = '';	  
		LET dFechaCaptura                          = ''; 	  
		LET cImporteDocumentoNetoPagar             = ''; 	  
		LET cImporteDocumentoAntesImpuesto         = ''; 	  
		LET cImpuestoRetenido                      = ''; 	  
		LET cNumeroFolioServicio                   = '';	  
		LET cNumeroTienda                          = '';	  
		LET cTipoRetiro                            = '';	  
		LET cConsecutivoRetiro                     = ''; 	  
		LET cCURP                                  = ''; 	  
		LET cRFC                                   = ''; 	  
		LET cFolio_suc                             = ''; 	  
		LET cNumeroTotalMovimientosContenidos      = '';	  	
		LET cImporteTotalNeto                      = ''; 	  
		LET cImporteTotalAntesImpuesto             = ''; 	  
		LET cImporteRetenido                       = ''; 	  
		LET cImporteTotalRetirosPagadosEfectivo    = ''; 	  
		LET cImporteTotalRetirosPagadosDeposito    = ''; 	  
		LET dFechaMovimientos                      = ''; 	  
		LET cEstatus                               = ''; 	  
		LET iSumaMov                               = 0; 	  
		LET mMonto                                 = '';  
		LET mSumaMonto                             = '';  
		LET iNoRegistros                           = 0;
		
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, iTotalRegistros; 
			END EXCEPTION;
            
			ON EXCEPTION IN (-206)
			END EXCEPTION WITH RESUME;
		
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesconsultarchivosafore.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros; 
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros; 
			END IF;
			
			-- VALIDA NOMENCLATURA			
			IF SUBSTRING(pNombreArchivo FROM 15 FOR 2) = 'OB' OR SUBSTRING(pNombreArchivo FROM 5 FOR 2) = 'OB' THEN 
				LET pTipoArchivo = '2';
			ELSE 
				LET pTipoArchivo = '1';
			END IF;
			
			SET LOCK MODE TO WAIT 3; 
		 
				FOREACH
				
					EXECUTE PROCEDURE bdiprog:"informix".sp_aforeconsultaarchivos(pNombreArchivo, pTipoArchivo) 
					INTO cCodRetSp, cTipoRegistro, cNoContratoEmpresaTmp, dFechaGenTmp, dFechaInicialInformacionTmp, dFechaFinalInformacionTmp, 
					cNoMovimientosContenidosTmp, cFiller, cFinLinea, cNSS, cNombreBeneficiario, cApellidoPaternoBeneficiario, 
					cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar, 
					cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda, cTipoRetiro, 
					cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
					cImporteTotalAntesImpuesto, cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, 
					cImporteTotalRetirosPagadosDeposito, dFechaMovimientos, cEstatus, iSumaMov, mMonto, mSumaMonto
					
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_aforeconsultaarchivos';					 
					ELIF cCodRetSp::INTEGER = 10000 THEN	
						LET cCodRet = '00481'; 
						RETURN cCodRet, iTotalRegistros;
					END IF;
					
					IF DBINFO('sqlca.sqlerrd2') = 1 THEN
						LET iNoRegistros = iNoRegistros + 1;
					END IF;
					
				END FOREACH;
			
			LET iTotalRegistros = iNoRegistros - 2;
			
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			ELSE 
				RETURN cCodRet, iTotalRegistros;
			END IF;	
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/06/2015',
'DESCRIPCION: SPL que obtiene el nÃºmero total de archivos de pagos, confirmacion y control Afore.',
'FUNCIONALIDAD: Consulta de Archivos - Proceso AFORE', 
'MODULO: AFORE',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/10/2015',
'DESCRIPCION: Se hizo la modificaciÃ³n al calculo del nÃºmero total de registros, ya que 2 de los registros a retornar,',
'corresponden: el primero al encabezado y el Ãºltimo al sumario.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaarchcod60tef(pUsuario CHAR(8), pIdFuncion CHAR(10))	
		RETURNING CHAR(5) AS codret,
			CHAR(1) AS cTipo_Proc,
			CHAR(10) AS cFecha_Proc,
			CHAR(20) AS cClave_Proc,
			CHAR(60) AS cDescripcion_Proc,
			CHAR(1) AS  cEstatus_Proc;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cTipoProceso CHAR(1); 
		DEFINE dFechaProceso CHAR(10);
		DEFINE cClaveProceso CHAR(20);
		DEFINE cDescripcion CHAR(60);
		DEFINE cEstatus CHAR(1);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cTipoProceso = '';
		LET dFechaProceso = '';
		LET cClaveProceso = '';
		LET cDescripcion = '';
		LET cEstatus = '';
		LET iNoRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validaarchcod60tef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus; 
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			
			-- VALIDA ARCHIVO 60
			FOREACH
				EXECUTE PROCEDURE bditef:"informix".sp_tef_validarchcod60('','GENARCH_60.01')
				INTO cCodRetSp, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_validarchcod60';
				ELIF cCodRetSp::INTEGER = 1	THEN
					LET cCodRet = '00335'; --'SOLAMENTE DEBE ENVIAR UN SOLO PARAMETRO'
					RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
				ELIF cCodRetSp::INTEGER = 2	THEN
					LET cCodRet = '00563'; --NO ES POSIBLE REGISTRAR LA OPERACIÃN TEF, EL PROCESO DE GENERACIÃN DE ARCHIVOS YA HA INICIADO
					RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
				END IF;
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(cTipoProceso), dFechaProceso, UPPER(cClaveProceso), UPPER(cDescripcion), cEstatus WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cTipoProceso, dFechaProceso, cClaveProceso, cDescripcion, cEstatus;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 29/07/2015',
'DESCRIPCION: SPL que valida si ya inicio o no la generaciÃ³n del Archivo CÃ³digo 60 TEF.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validactabeneficiariotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoCuenta CHAR(2), pNumCuenta CHAR(20))	
		RETURNING CHAR(5) AS codret,          
			CHAR(3) AS clave_banco,  
			CHAR(1) AS digito_verificador;
		
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cEmpresa CHAR(3);
		DEFINE iTipo INTEGER;
		DEFINE cTarjeta CHAR(20);
		DEFINE cClaveBanco CHAR(3);
		DEFINE cCtaClabe CHAR(20);
		DEFINE cDigito CHAR(1);
		DEFINE cDigVerificador CHAR(1);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cEmpresa = '001';
		LET iTipo = 0;
		LET cTarjeta = '';
		LET cClaveBanco = '';
		LET cCtaClabe = '';
		LET cDigito = '';
		LET cDigVerificador = '';
		LET iNoRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cClaveBanco, cDigito;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validactabeneficiariotef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoCuenta = '' OR pNumCuenta = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cClaveBanco, cDigito;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cClaveBanco, cDigito;
			END IF;
		 
			IF pTipoCuenta = '40' THEN
				LET iTipo = 3;
			ELIF pTipoCuenta = '03' THEN
				LET iTipo = 2;
			ELIF pTipoCuenta = '11' OR pTipoCuenta = '12' OR pTipoCuenta = '13' THEN
				LET iTipo = 1;
			END IF;	
		
			SET ISOLATION TO DIRTY READ;
			
			IF pTipoCuenta = '03' THEN
				
				LET cTarjeta = SUBSTRING (TRIM(pNumCuenta) FROM 1 FOR 6);
				
				-- VALIDA BIN
				EXECUTE PROCEDURE bditef:"informix".sp_obtbines_sif(cTarjeta)
				INTO cCodRetSp, cDescCodRet, cClaveBanco;
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_obtbines_sif';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00569'; --TARJETA INVALIDA, VERIFIQUE
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00526'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00570'; --El BIN NO PERTENECE A LA TARJETA DE DÃBITO, VERIFIQUE
					RETURN cCodRet, cClaveBanco, cDigito;
				END IF;
			
			ELIF pTipoCuenta = '40' THEN
				
				LET cCtaClabe = SUBSTRING (TRIM(pNumCuenta) FROM 1 FOR 17);
				LET cDigVerificador = SUBSTRING (TRIM(pNumCuenta) FROM 17 FOR 1);
				
				-- VALIDA DÃGITO
				EXECUTE PROCEDURE bdicheq:"informix".digverclabe(cCtaClabe)
				INTO cCodRetSp, cDigito;
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:digverclabe';
				END IF;
				
				IF NVL(cDigito,'') <> NVL(cDigVerificador,'') OR (NVL(cDigito,'') = '' OR NVL(cDigVerificador,'') = '') THEN 
					LET cCodRet = '00240'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				END IF;
				
			END IF;
			
			IF cCodRetSp::INTEGER = 0 THEN 
			
				-- VALIDA RECEPCIÃN
				EXECUTE PROCEDURE bditef:"informix".sp_tef_validarecepcion(iTipo,pNumCuenta)
				INTO cCodRetSp, cDescCodRet;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_validarecepcion';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00431'; 
					RETURN cCodRet, cClaveBanco, cDigito;
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00571'; --TRANSFERENCIAS BANCOPPEL NO OPERAN TEF, VERIFIQUE
					RETURN cCodRet, cClaveBanco, cDigito;
				END IF;
				
				IF cCodRetSp::INTEGER = 0 THEN 
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cClaveBanco, cDigito;
				END IF;
				
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cClaveBanco, cDigito;			
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/08/2015',
'DESCRIPCION: SPL que se encarga de validar que la cuenta sea valida para la recepcion de operaciones TEF en central.',
'Y dependiendo del tipo de cuenta realiza las siguientes validaciones:',
'Si pTipoCuenta = 03, valida el bin de la tarjeta y obtiene la clave del banco.',
'Si pTipoCuenta = 40, valida que el dÃ­gito verificador sea correcto.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validahrfechaprocaptef(pUsuario CHAR(8), pIdFuncion CHAR(10))
					
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cFechaHoy CHAR(10);
		DEFINE cHora CHAR(10);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cFechaHoy = '';
		LET cHora = '';
		LET iNoRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validahrfechaprocaptef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet; 
			END IF;
			
			-- CONSULTA FECHA ACTUAL
			SELECT fecha_hoy INTO cFechaHoy FROM bdinvers:"informix".sv_fechas WHERE empresa = '001';	
		 
			SET ISOLATION TO DIRTY READ;
			
			-- VALIDA DÃA HÃBIL
			EXECUTE PROCEDURE bditef:"informix".sp_validadiahabiltef(cFechaHoy)
			INTO cCodRetSp,cCodRetSp2;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_validadiahabiltef';
			ELIF cCodRetSp2::INTEGER = 1	THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			ELIF cCodRetSp2::INTEGER = 2	THEN
				LET cCodRet = '00561'; --NO ES POSIBLE REGISTRAR LA OPERACIÃN TEF, DÃA INVÃLIDO
				RETURN cCodRet;
			END IF;

			IF cCodRetSp::INTEGER = 0 AND cCodRetSp2::INTEGER = 0 THEN
				
				LET cHora = TO_CHAR(CURRENT,'%H:%m');
				
				-- VALIDA HORARÃO
				EXECUTE PROCEDURE bditef:"informix".sp_tef_validahorario(cHora)
				INTO cCodRetSp, cDescCodRet;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_tef_validahorario';
				ELIF cCodRetSp::INTEGER = 1	THEN
					LET cCodRet = '00562'; --NO ES POSIBLE REGISTRAR LA OPERACIÃN TEF, EL HORARIO EXCEDE DEL TIEMPO MÃXIMO ESTABLECIDO
					RETURN cCodRet;
				END IF;
				
				IF cCodRetSp::INTEGER = 0 THEN
					LET iNoRegistros = iNoRegistros + 1;
				END IF;
				
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet;
			ELSE	
				RETURN cCodRet;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 29/07/2015',
'DESCRIPCION: SPL que verificar si la fecha de ejecuciÃ³n corresponde a un dÃ­a hÃ¡bil bancario y',
'si la hora de ejecuciÃ³n se encuentra dentro del horario permitido para poder realizar las operaciones TEF en central.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaproductotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pNumCliente CHAR(9))	
		RETURNING CHAR(5) AS codret,          
			DECIMAL(6,2) AS imp_comision,              
		    CHAR(13) AS rfc,
			CHAR(50) AS descripcion_iva,
			CHAR(100) AS valor_iva;
		
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cCodRetSp2 CHAR(5);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cEmpresa CHAR(3);
		DEFINE dImpComision DECIMAL(6,2);
		DEFINE cRFC CHAR(13);
		DEFINE cDescripcionIva CHAR(50);
		DEFINE cValorIva CHAR(100);		
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cCodRetSp2 = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cEmpresa = '001';
		LET dImpComision = 0.00;
		LET cRFC = '';
		LET cDescripcionIva = '';
		LET cValorIva = '';
		LET iNoRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validaproductotef.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pProducto = '' OR pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
			END IF;
		 
			SET ISOLATION TO DIRTY READ;
			
			EXECUTE PROCEDURE bditef:"informix".sp_validaproductopermitido(pProducto,pNumCliente)
			INTO cCodRetSp, dImpComision, cRFC;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:sp_validaproductopermitido';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003'; 
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00568'; --NO ES PRODUCTO PERMITIDO, VERIFIQUE
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;
			END IF;

			IF cCodRetSp::INTEGER = 0 THEN				
				
				-- CONSULTA VALOR IVA
				FOREACH
					EXECUTE PROCEDURE bdinteg:"informix".sp_obtenerparametros(47,'001')
					INTO cDescripcionIva, cValorIva
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdinteg:sp_obtenerparametros';
					ELIF cCodRetSp::INTEGER = 0 THEN					
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, NVL(dImpComision,0), UPPER(cRFC), UPPER(cDescripcionIva), NVL(cValorIva,'') WITH RESUME;
					END IF; 
					
				END FOREACH
				
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dImpComision, cRFC, cDescripcionIva, cValorIva;				
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 31/07/2015',
'DESCRIPCION: SPL que se encarga de validar si el producto es permitido, y si cobra comision.',
'Regresa la cantidad cobrada, el RFC del cliente, y el valor de IVA.',
'FUNCIONALIDAD: Captura de Operaciones TEF', 
'MODULO: TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validarcargarchivoafore(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(30))
		RETURNING CHAR(5) AS codret;
		
		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;	
		DEFINE cHoraProceso CHAR(21);
		DEFINE cHoraServidor CHAR(21);
		DEFINE pTipoArchivo CHAR(1);
		DEFINE cMensajeRet CHAR(200);
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;	
		LET cHoraProceso = '';
		LET cHoraServidor = '';
		LET pTipoArchivo = '';
		LET cMensajeRet = '';
		LET iRecuperacion = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
			
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_validarcargarchivoafore.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA El LIMITE DE HORARIO PERMITIDO
			SELECT valor INTO cHoraProceso FROM bdisac:"informix".sac_param WHERE cod_param = '6036';
			IF cHoraProceso = '' OR cHoraProceso IS NULL THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- CONSULTA LA HR DEL SERVIDOR
			EXECUTE PROCEDURE bdiprog:"informix".sp_validahoraejec('001') INTO cCodRetSp, cHoraServidor;
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_validahoraejec';
			ELIF cCodRetSp::INTEGER > 0 THEN
				LET cCodRet = '00515'; --NO SE PUDO OBTENER LA HORA DEL SERVIDOR
				RETURN cCodRet;
			END IF;
			
			-- VALIDA NOMENCLATURA
			IF SUBSTRING(pNombreArchivo FROM 15 FOR 2) = 'OB' THEN 
				IF (cHoraServidor > cHoraProceso) THEN
					LET cCodRet = '00434';
					RETURN cCodRet;
				ELSE
					LET pTipoArchivo = '2';
				END IF;
			ELSE 
				LET pTipoArchivo = '1';
			END IF;
		 
			-- GENERA EL LLAMADO AL PROCESO DE RECEPCION DE ARCHIVOS
			EXECUTE PROCEDURE bdiprog:"informix".sp_aforevalidacargaarchivo(pNombreArchivo, pUsuario, pTipoArchivo) 
			INTO cCodRetSp, cMensajeRet;
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiprog:sp_aforevalidacargaarchivo';
			ELIF cCodRetSp::INTEGER = 10000 THEN	
				LET cCodRet = '00481'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10001 THEN	
				LET cCodRet = '00482'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10002 THEN	
				LET cCodRet = '00483'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10003 THEN	
				LET cCodRet = '00484'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10004 THEN	
				LET cCodRet = '00485'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10005 THEN	
				LET cCodRet = '00486'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10006 THEN	
				LET cCodRet = '00487';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10007 THEN	
				LET cCodRet = '00488';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10008 THEN	
				LET cCodRet = '00489'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10009 THEN	
				LET cCodRet = '00490'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10010 THEN	
				LET cCodRet = '00491';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10011 THEN	
				LET cCodRet = '00492'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10012 THEN	
				LET cCodRet = '00493'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10013 THEN	
				LET cCodRet = '00494';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10014 THEN	
				LET cCodRet = '00438'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10015 THEN	
				LET cCodRet = '00495';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10016 THEN	
				LET cCodRet = '00496'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10017 THEN	
				LET cCodRet = '00497';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10018 THEN	
				LET cCodRet = '00498'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10019 THEN	
				LET cCodRet = '00499';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10020 THEN	
				LET cCodRet = '00500'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10021 THEN	
				LET cCodRet = '00501'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10022 THEN	
				LET cCodRet = '00496'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10023 THEN	
				LET cCodRet = '00502'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10024 THEN	
				LET cCodRet = '00503';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10025 THEN	
				LET cCodRet = '00504'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10026 THEN	
				LET cCodRet = '00505'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10027 THEN	
				LET cCodRet = '00017'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10028 THEN	
				LET cCodRet = '00506'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10029 THEN	
				LET cCodRet = '00507'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10030 THEN	
				LET cCodRet = '00508'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10031 THEN	
				LET cCodRet = '00509';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10032 THEN	
				LET cCodRet = '00510';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10549 THEN
				LET cCodRet = '00511'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10034 THEN
				LET cCodRet = '00512';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10035 THEN
				LET cCodRet = '00513'; 
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 10036 THEN
				LET cCodRet = '00514';
				RETURN cCodRet;
			ELSE					 
				RETURN cCodRet;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 02/06/2015',
'DESCRIPCION: SPL que recibe y obtiene toda la informacion de un archivo enviado por afore coppel.',
'Se valida la informacion contenida en el archivo, y se almacena en la base de datos.',
'FUNCIONALIDAD: RecepciÃ³n de Archivos de Afore Coppel â Procesos AFORE', 
'MODULO: AFORE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_consctascteparticipacion(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, pNumCliente char(20), 
				pRecuperacion int, pIp char(15), pMacAddress char(12))
	returning char(5) as codret
	
	define cCodRet char(5);
	define iSqlErr int;
	define cSitemaCuentaConsulta char(2);
	-- Parametros de salida del SP de consprodcte
	define cIndicadorChequera char(1);
	define cSistemaCuenta char(2);
	define cNoCuenta char(20);
	define cClaveProducto char(4);
	define cNombreProducto char(40);
	define dFechaApertura date;
	define cStatusCuenta char(60);
	define dFechaStatusCuenta date;
	define cClaveSucursal char(4);
	define cEjecutivoAperturaCuenta char(8);
	define mSaldoActual money(14,2);
	define cNumTarjeta char(20);
	define cStatusTarjeta char(15);
	define cCuentaClabe char(18);
	define dFechaAperturaOriginal date;
	define cCodRetSp char(5);
	define iRegistros int;
	define iDiaCorte int;
	define cTipoParticipacion char(1);
	define iExiste int;
	define cNumCuentaParticipe char(20);
	define cStatusBloq char(1);
	define dFechaBloqueo date;
	define cMotivoBloqueo char(40);
	define dFechaCancelacion date;
	define cCodEstatusCta char(2);
	
	let cCodRet = '00000';
	let cCodRetSp = '00000';
	let iSqlErr = 0;
	let cSitemaCuentaConsulta = '00'; -- Todas la cuentas
	-- Parametros de salida del SP de consprodcte
	let cIndicadorChequera = '';
	let cSistemaCuenta = '';
	let cNoCuenta = '';
	let cClaveProducto = '';
	let cNombreProducto = '';
	let dFechaApertura = null;
	let cStatusCuenta = '';
	let dFechaStatusCuenta = null;
	let cClaveSucursal = '';
	let cEjecutivoAperturaCuenta = '';
	let mSaldoActual = null;
	let cNumTarjeta = '';
	let cStatusTarjeta = '';
	let cCuentaClabe = '';
	let dFechaAperturaOriginal = '';
	let iRegistros = 0;
	let iDiaCorte = 0;
	let cTipoParticipacion = '';
	let iExiste = 0;
	let cNumCuentaParticipe = '';
	let cStatusBloq = '0';
	let dFechaBloqueo = null;
	let cMotivoBloqueo = '';
	let dFechaCancelacion = '';
	let cCodEstatusCta = '';
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet;
			end if;
		end exception;
		
		-- Cuentas del cliente titular
		let cTipoParticipacion = 'T'; -- en estas cuentas el cliente es titular
		
		while cCodRetSp = '00000'
			set isolation to dirty read;
			foreach execute procedure bdinteg:"informix".sp_cnsif_consprodcte(pUsuario, pIdFuncion, pNumCliente, cSitemaCuentaConsulta, iRegistros, pRecuperacion)
				into cCodRetSp, cIndicadorChequera, cSistemaCuenta, cNoCuenta, cClaveProducto, cNombreProducto, dFechaApertura, 
					cStatusCuenta, dFechaStatusCuenta, cClaveSucursal, cEjecutivoAperturaCuenta, mSaldoActual, cNumTarjeta, cStatusTarjeta, 
					cCuentaClabe, dFechaAperturaOriginal, iDiaCorte, dFechaCancelacion, cCodEstatusCta
				
				if cCodRetSp = '00000' then
				
					-- Se agrega el campo de bloqueo de la cuenta
					let cStatusBloq = '0';
					let dFechaBloqueo = null;
					let cMotivoBloqueo = '';
					
					if iDiaCorte is null then
						let iDiaCorte = 1;
					end if;
					
					execute procedure "informix".sp_sw_ro_consstatusbloqueo(pUsuario, pIdFuncion, cSistemaCuenta, cNoCuenta)
						into cStatusBloq, cMotivoBloqueo, dFechaBloqueo;
					
					insert into "informix".sw_ro_ctascliente_temp(id_oficio, id_busqueda,	id_resulcte, tipo_cuenta, cuenta, clave_producto, nombre_producto, fecha_apertura, 
												status_cuenta, fecha_status_cuenta, clave_suc_apertura,	ejecutivo_apertura,	saldo_actual, num_tarjeta, status_tarjeta,
												cuenta_clabe, fecha_original_apertura, ind_cuenta_ya_bloqueada, motivo_bloqueo, fecha_bloqueo, dia_corte)
					values(pIdOficio, pIdBusqueda, pIdCliente, cSistemaCuenta, cNoCuenta, cClaveProducto, cNombreProducto, dFechaApertura, 
									cStatusCuenta, dFechaStatusCuenta, cClaveSucursal, cEjecutivoAperturaCuenta, mSaldoActual, cNumTarjeta, cStatusTarjeta,
									cCuentaClabe, dFechaAperturaOriginal, cStatusBloq, cMotivoBloqueo, dFechaBloqueo, iDiaCorte);
					--return dbinfo('sqlca.sqlerrd1') with resume;
				end if;
				
			end foreach;
			let iRegistros = iRegistros + pRecuperacion;
			
		end while;
		
		-- Se insertan los registros de las cuentas en las tabla de ctecta
		set isolation to dirty read;
		insert into "informix".sw_ro_ctecta(id_oficio, id_busqueda, id_resulcte, numcte, cuenta, id_tipo_participe, tipo_participe, 
								tipo_cuenta, producto, nombre_producto, status_cuenta, fecha_apertura, sucursal,
								sdo_actual, user_insert, ip_insert, mac_insert, fecha_apertura_original, cuenta_clabe,
								ejecutivo, ind_cuenta_ya_bloqueada, motivo_bloqueo, fecha_bloqueo, dia_corte)
		select distinct id_oficio, id_busqueda, id_resulcte, pNumCliente, cuenta, '1', 'TITULAR',
						tipo_cuenta, clave_producto, nombre_producto, status_cuenta, fecha_apertura, clave_suc_apertura,
						saldo_actual, pUsuario, pIp, pMacAddress, fecha_original_apertura, cuenta_clabe, 
						ejecutivo_apertura, ind_cuenta_ya_bloqueada, motivo_bloqueo, fecha_bloqueo, dia_corte
		from "informix".sw_ro_ctascliente_temp where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente;
		
		
		-- Se consultan las tarjetas del cliente
		let pRecuperacion = iRegistros + pRecuperacion;
		execute procedure "informix".sp_sw_ro_tarjetascte(pUsuario, pIdFuncion, pIdOficio, pIdBusqueda, pIdCliente, pNumCliente, 0, pRecuperacion) into cCodRetSp;
		
		-- Busca la participaciÃ³n en las cuentas
		execute procedure "informix".sp_sw_ro_buscaparticipacion(pUsuario, pIdOficio, pIdBusqueda, pIdCliente, pNumCliente, pIp, pMacAddress) into cCodRet;
		
		return cCodRet;
		
	end;
end procedure;