CREATE PROCEDURE "informix".sp_cli_consultadocumentos_especificos(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion SMALLINT, pTiposDocumentos CHAR(255), pDireccionMAC CHAR(15), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(4) AS cod_docto,
				CHAR(35) AS desc_docto,
				CHAR(3) AS cod_grupo,
				CHAR(30) AS desc_grupo,
				CHAR(1) AS multi_img,
				INTEGER AS img_tam_max,
				CHAR(3) AS img_formato,
				SMALLINT AS img_compresion,
				DECIMAL AS img_largo,
				DECIMAL AS img_ancho,
				SMALLINT AS img_dpi,
				CHAR(1) AS img_colores,
				CHAR(1) AS generico,
				CHAR(1) AS ligar;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE cCodigoDocto CHAR(4);
	DEFINE cCodDocto CHAR(4);
	DEFINE cDescDocto CHAR(35);
	DEFINE cCodGrupo CHAR(3);
	DEFINE cDescGrupo CHAR(30);
	DEFINE cMultiImg CHAR(1);
	DEFINE iImgTamMax INTEGER;
	DEFINE cImgFormato CHAR(3);
	DEFINE iImgCompresion SMALLINT;
	DEFINE dImgLargo DECIMAL;
	DEFINE dImgAncho DECIMAL;
	DEFINE iImgDPI SMALLINT;
	DEFINE cImgColores CHAR(1);
	DEFINE cGenerico CHAR(1);
	DEFINE cLigar CHAR(1);


	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET cEmpresa = '001';
	LET cCodigoDocto = '';
	LET cCodDocto = '';
	LET cDescDocto = '';
	LET cCodGrupo = '';
	LET cDescGrupo = '';
	LET cMultiImg = '';
	LET iImgTamMax = 0;
	LET cImgFormato = '';
	LET iImgCompresion = 0;
	LET dImgLargo = NULL;
	LET dImgAncho = NULL;
	LET iImgDPI = 0;
	LET cImgColores = '';
	LET cGenerico = '';
	LET cLigar = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_consultadocumentos_especificos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pDireccionMAC = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
		END IF;
		
		IF pTipoOperacion NOT IN (1, 2) THEN	
			LET cCodRet = '00440';
			RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
		END IF;
		
		IF pTipoOperacion = 1 THEN
			IF pTiposDocumentos = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
			END IF;
		END IF;
		
		IF pTipoOperacion = 2 THEN
			IF pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
			END IF;
		
			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
		END IF;
		
		IF pTipoOperacion = 1 THEN
		
			DELETE {+INDEX (bdicnweb:"informix".sw_cli_tmp_docespecificos idx01sw_cli_tmp_docespecificos, idx02sw_cli_tmp_docespecificos)} FROM bdicnweb:"informix".sw_cli_tmp_docespecificos WHERE usuario = pUsuario AND mac = pDireccionMAC;
		
			FOREACH EXECUTE PROCEDURE "informix".sp_split_cadena(pTiposDocumentos, '|') INTO cCodigoDocto
				FOREACH EXECUTE PROCEDURE bdidigital:"informix".sp_dgconsultadocumentoespecifico(cEmpresa, cCodigoDocto)
					INTO cCodRetSp, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar
					
					INSERT INTO bdicnweb:"informix".sw_cli_tmp_docespecificos(usuario, mac, cod_documento, desc_documento, cod_grupo, desc_grupo, multi_img, img_tam_max, img_formato, 
														img_compresion, img_largo, img_ancho, img_dpi, img_colores, generico, ligar)
					VALUES(pUsuario, pDireccionMAC, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar);
					
				END FOREACH;
			END FOREACH;
			
			RETURN cCodRet, "", "", "", "", "", 0, "", 
					0, NULL, NULL, 0, "", "", "";
		END IF;
		
		IF pTipoOperacion = 2 THEN
			SET ISOLATION TO DIRTY READ;
			
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion cod_documento, desc_documento, cod_grupo, desc_grupo, multi_img, img_tam_max, img_formato, 
					img_compresion, img_largo, img_ancho, img_dpi, img_colores, generico, ligar
				INTO cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
						iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar
				FROM bdicnweb:"informix".sw_cli_tmp_docespecificos
				WHERE usuario = pUsuario AND mac = pDireccionMAC
				
				RETURN cCodRet, cCodDocto, UPPER(cDescDocto), cCodGrupo, UPPER(cDescGrupo), cMultiImg, iImgTamMax, UPPER(cImgFormato), 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar WITH RESUME;
					
				LET iNoRegistros = iNoRegistros + 1;
				
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00017';
				ELIF pRegistros > 0 THEN
					DELETE {+INDEX (bdicnweb:"informix".sw_cli_tmp_docespecificos idx01sw_cli_tmp_docespecificos, idx02sw_cli_tmp_docespecificos)} FROM bdicnweb:"informix".sw_cli_tmp_docespecificos WHERE usuario = pUsuario AND mac = pDireccionMAC;
					LET cCodRet = '1001';
				END IF;
				
				RETURN cCodRet, cCodDocto, cDescDocto, cCodGrupo, cDescGrupo, cMultiImg, iImgTamMax, cImgFormato, 
					iImgCompresion, dImgLargo, dImgAncho, iImgDPI, cImgColores, cGenerico, cLigar;
			END IF;
			
			IF iNoRegistros > 0 AND iNoRegistros < pRecuperacion THEN
				DELETE {+INDEX (bdicnweb:"informix".sw_cli_tmp_docespecificos idx01sw_cli_tmp_docespecificos, idx02sw_cli_tmp_docespecificos)} FROM bdicnweb:"informix".sw_cli_tmp_docespecificos WHERE usuario = pUsuario AND mac = pDireccionMAC;
			END IF;
			
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 11/11/2015',
'MODULO: Clientes',
'FUNCIONALIDAD: Mantenimiento a expediten digital',
'DESCRIPCION: Consulta las definiciones de los codigos de documentos enviados',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_catalogoproductoscat(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(4)  AS id_producto,
		CHAR(40) AS desc_producto;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE cIdProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET cIdProducto = '';
	LET cDescProducto = '';
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdProducto, cDescProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_catalogoproductoscat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdProducto, cDescProducto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdProducto, cDescProducto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		FOREACH
		SELECT num_producto, nombre_prod
		INTO cIdProducto, cDescProducto
		FROM bdicred:"informix".sd_definicion
		WHERE num_producto IN(6001, 6011, 6300, 6400, 7600,7700)
		
		RETURN cCodRet, cIdProducto, UPPER(TRIM(cDescProducto)) WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdProducto, cDescProducto;
		END IF;		
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta los productos del Sistema de Cobranzas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultadivisionescat(pUsuario CHAR(8), pIdFuncion CHAR(10))
        RETURNING CHAR(5) AS codret,
        INTEGER  AS id_division,
        CHAR(10) AS desc_divicion;
                
                
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
    DEFINE iCodRetSp INTEGER;
    DEFINE cEmpresa CHAR(3);
    DEFINE cMensajeRet CHAR(80);
    DEFINE cIdDivision INTEGER;
    DEFINE cDescDivision CHAR(10);      
    DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '00000';
    LET iCodRetSp = 0;
    LET cEmpresa = '001';
    LET cMensajeRet = '';
    LET cIdDivision = 0;
    LET cDescDivision = '';
    LET iRecuperacion = 0;
        
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdDivision, cDescDivision;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/tmp/mfinis/sp_x.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdDivision, cDescDivision;
		END IF;
                
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdDivision, cDescDivision;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
            EXECUTE PROCEDURE bdicobranza:"informix".sp_consultardivisiones(cEmpresa)  
            INTO cCodRetSp, cMensajeRet, cIdDivision, cDescDivision
            
            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
                    RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_consultardivisiones';
            ELIF cCodRetSp::INTEGER = 1 THEN
                    LET cCodRet = '00003';
            ELIF cCodRetSp::INTEGER = 2 THEN
                    LET cCodRet = '00017';
            END IF;
            
			LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, cIdDivision,  UPPER(TRIM(cDescDivision)) WITH RESUME;           
        END FOREACH;
                
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cIdDivision, cDescDivision;
		END IF;
    END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta las divisiones que se encuentran dadas de alta en el Sistema de Cobranzas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultafechacorteproducto(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		INTEGER AS dia_corte;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iDiaCorte INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iDiaCorte = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iDiaCorte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultafechacorteproducto.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pProducto ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iDiaCorte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iDiaCorte;
		END IF;
		
			SET ISOLATION TO DIRTY READ;
			FOREACH		
				
				SELECT a.dia_corte
				INTO iDiaCorte
				FROM sw_cr_productodiacorte a
				WHERE a.num_producto=pProducto
				ORDER BY 1 ASC
				
				LET iNoRegistros = iNoRegistros +1;
				
				RETURN cCodRet,iDiaCorte  WITH RESUME;
			END FOREACH;
		
		
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
                        
		IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iDiaCorte;
		END IF;	
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 28/10/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: ADMINISTRACION DE CAMPAÑAS',
'DESCRIPCION: SPL que realiza la consulta los dias de corte del producto',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 11/11/2016',
'MODIFICACION: Cambio de tabla de consulta de dia de corte por producto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultaobtcanalorigencat(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumParam INTEGER)
    RETURNING CHAR(5) AS codret,
    DECIMAL(18,2) AS id_valor_alfabetico,
    CHAR(100) AS des_valor_alfabetico;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(85);
	DEFINE dIdValorAlfabetico DECIMAL(18,2);
	DEFINE cDesValorAlfabetico  CHAR(100);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET dIdValorAlfabetico = 0.00;
	LET cDesValorAlfabetico = '';
	LET iNoRegistros = 0;

    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dIdValorAlfabetico,cDesValorAlfabetico;
        END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultaobtcanalorigencat.out';
        --TRACE ON;

        IF pUsuario = '' OR pIdFuncion = ''  OR pNumParam IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dIdValorAlfabetico,cDesValorAlfabetico;
        END IF;


        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
			RETURN cCodRet,dIdValorAlfabetico,cDesValorAlfabetico;
        END IF;

        SET ISOLATION TO DIRTY READ;
        FOREACH
			EXECUTE PROCEDURE bdicobranza:"informix".sp_obtcanalorigen(pNumParam)
			INTO cCodRetSp, cMensajeRet, dIdValorAlfabetico,cDesValorAlfabetico
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicobranza:sp_obtcanalorigen ";
			ELIF cCodRetSp::INTEGER = 2  THEN
					LET cCodRet = '00017';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, dIdValorAlfabetico,cDesValorAlfabetico WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dIdValorAlfabetico,cDesValorAlfabetico;
		END IF;

    END;

END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza ',
'FECHA: 21/03/2015',
'MODULO: CREDITO',
'FUNCIONALIDAD: ADMINISTRACION DE CAMPAÑAS',
'DESCRIPCION:SPL que realiza la consulta del canar  de origen para la consulta de administracion de campañas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultaregionescat(pUsuario CHAR(8), pIdFuncion CHAR(10), pDivicion SMALLINT)
	RETURNING CHAR(5) AS codret,                
	SMALLINT As id_region,
	CHAR (30) As desc_Region; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cIdRegion SMALLINT;
	DEFINE cDescREgistros CHAR(30);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';   
	LET cIdRegion = 0;
	LET cDescREgistros = '';
	LET iRecuperacion = 0;
	
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdRegion, cDescREgistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultaregionescat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pDivicion IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdRegion, cDescREgistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdRegion, cDescREgistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;    
		FOREACH
			EXECUTE PROCEDURE bdicobranza:"informix".sp_consultarregiones(pDivicion, cEmpresa)
			INTO cCodRetSp, cIdRegion, cDescREgistros
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_consultarregiones';
			ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
		
			RETURN cCodRet, cIdRegion, UPPER(TRIM(cDescREgistros)) WITH RESUME;             
		END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cIdRegion, cDescREgistros;
		END IF;
	END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta las regiones que se encuentran dadas de alta en el Sistema de Cobranzas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultastatusproceso(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(1) AS id_status,
		CHAR(30) AS desc_status;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdStatus CHAR(1);
	DEFINE cDescStatus CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdStatus = '';
	LET cDescStatus = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdStatus, cDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultastatusproceso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
		SELECT id_status, desc_status
		INTO cIdStatus, cDescStatus
		FROM "informix".sw_cr_tipostatus
		WHERE usuario_inserta = pUsuario;
			
		IF cIdStatus  = '' THEN
			RETURN cCodRet, 'I', 'INICIA_PROCESO';
		ELSE 
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 25/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: ADMINISTRACION DE CAMPAÑAS',
'DESCRIPCION: SPL que realiza la consulta de los estatus para monitorear el proceso del spl de sp_cre_consultarcompromisosacuerdoscat y sp_cre_consultarcompromisosacuerdoscat_totales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultasucursalescat(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegion SMALLINT ,pSucursal CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,            
        CHAR(4) AS id_sucursal,
        CHAR(40) AS desc_sucursal;              
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE cIdSucursal CHAR(4);
        DEFINE cDescSucursal CHAR(40);
        DEFINE iNoRegistros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET cIdSucursal = '';
        LET cDescSucursal = '';
        LET iNoRegistros = 0;
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet, cIdSucursal, cDescSucursal;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultasucursalescat.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' OR pRegion IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL  THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cIdSucursal, cDescSucursal;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet, cIdSucursal, cDescSucursal;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			FOREACH
					EXECUTE PROCEDURE bdicobranza:"informix".sp_consultarsucursales2(cEmpresa, pRegion, pSucursal, pRegistros, pRecuperacion)
					INTO cCodRetSp, cIdSucursal, cDescSucursal
					
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_consultarsucursales2';
					ELIF cCodRetSp::INTEGER = 1 THEN
							LET cCodRet = '00105';
					ELIF cCodRetSp::INTEGER = 2 THEN
							LET cCodRet = '00017';
					END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
			
							RETURN cCodRet, cIdSucursal,  UPPER(TRIM(cDescSucursal)) WITH RESUME;           
			END FOREACH;
  
            IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '000002';
				RETURN cCodRet, cIdSucursal, cDescSucursal;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '001001';
				RETURN cCodRet, cIdSucursal, cDescSucursal;
			END IF;		
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta la informacion de las Sucursales de una Determinada Division',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultatiporeporte(pUsuario CHAR(8), pIdFuncion CHAR(10))
        RETURNING CHAR(5) AS codret,                    
		INTEGER AS id_archivo,
		CHAR(80) AS desc_archivo;               
    
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE cDescArchivo CHAR(80);
	DEFINE iIdArchivo INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET iIdArchivo = 0;
	LET cDescArchivo = '';
        
    BEGIN
        
		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdArchivo, cDescArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-958)
        END EXCEPTION WITH RESUME;
                
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultatiporeporte.out';
		--TRACE ON;
                
		IF pUsuario = '' OR pIdFuncion = ''  THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iIdArchivo,  cDescArchivo;
		END IF;
                
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, iIdArchivo,  cDescArchivo;
		END IF;
        
		-- CREACION DE TABLA TEMPORAL
		CREATE TEMP TABLE sw_compac_tipo_reporte_tmp(usuario_tmp CHAR(20), cMensajeRet_tmp CHAR(80),iIdArchivo_tmp INTEGER, cDescArchivo_tmp CHAR(80)) WITH NO LOG;
		DELETE FROM sw_compac_tipo_reporte_tmp WHERE usuario_tmp = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
			EXECUTE PROCEDURE bdicobranza:"informix".sp_compac_tipo_reporte()
			INTO cCodRetSp, cMensajeRet, iIdArchivo,  cDescArchivo
					
			LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_compac_tipo_reporte';
			END IF;
			
			INSERT INTO sw_compac_tipo_reporte_tmp (usuario_tmp, cMensajeRet_tmp, iIdArchivo_tmp, cDescArchivo_tmp)
			VALUES (pUsuario, cMensajeRet, iIdArchivo,  cDescArchivo);
		END FOREACH;
		
		FOREACH 
			SELECT iIdArchivo_tmp, cDescArchivo_tmp 
			INTO iIdArchivo,  cDescArchivo
			FROM sw_compac_tipo_reporte_tmp
			WHERE usuario_tmp = pUsuario
			AND iIdArchivo_tmp IN (1,2,3, 5)
			ORDER BY iIdArchivo_tmp
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdArchivo,  cDescArchivo WITH RESUME;
		
		END FOREACH;
		 
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		
		IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdArchivo, cDescArchivo;
		END IF;
    END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 23/03/2016',
'MODULO: CREDITO  ',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL que consulta la informacion de las Sucursales de una Determinada Division',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 11/08/2016',
'DESCRIPCION:Se modifica el spl para q solo muestre los tipos de reportes especificados en la consulta de las Sucursales de una Determinada Division',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_genreporteconveniosifcat(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(80) AS Nombre_archivo,
		CHAR(80) AS ruta;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNombreArchivo CHAR(80);
	DEFINE cMensajeRet CHAR(80);
	DEFINE cRuta CHAR(80);
	DEFINE bTransaccion BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET cNombreArchivo = '';
	LET cMensajeRet = '';
	LET cRuta = '';
	LET bTransaccion = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreArchivo, cRuta;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			LET bTransaccion = 't';
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_genreporteconveniosifcat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaInicio IS NULL OR pFechaFin IS NULL OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreArchivo, cRuta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo, cRuta;
		END IF;
		
		BEGIN WORK;
		IF bTransaccion = 'f' THEN
			COMMIT;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdicred:"informix".sp_rep_convenios_sif2_tmp(cEmpresa, pFechaInicio, pFechaFin, pUsuario, pProducto)
		INTO cCodRetSp, cMensajeRet, cNombreArchivo, cRuta;
		
		IF bTransaccion = 't' THEN
			BEGIN WORK;
		END IF;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicobranza:sp_consultardivisiones';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			END IF;
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreArchivo, cRuta;
		END IF;
		
		RETURN cCodRet, cNombreArchivo, cRuta;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 02/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE ESTADÍSTICA DE CONVENIOS EN SUCURSAL',
'DESCRIPCION:SPL que genera los reportes de estadistica convenio sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_conscambiostatustarjetas(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaBusqueda DATE, pNoTarjeta CHAR(16), pEstatus CHAR(20), pTramaTarjeta CHAR(250), pOperacion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)							
		RETURNING CHAR(5) AS codret,
			CHAR(19) AS numero_inicial,
			CHAR(19) AS numero_final,
			CHAR(20) AS estatus,
			CHAR(5) AS periodo_exp,
			DATE AS fecha_solicitud,
			CHAR(60) AS comentario,
			CHAR(8) as usuario;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE iTotalDisponibles INTEGER;
	DEFINE cNumeroInicial CHAR(19);
	DEFINE cNumeroFinal CHAR(19);
	DEFINE cStatus CHAR(20);
	DEFINE cPeriodoExp CHAR(5);
	DEFINE dFechaSolicitud DATE;
	DEFINE cComentario CHAR(60);
	DEFINE cBin CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cSerialFinal CHAR(19);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	LET iTotalDisponibles = 0;
	LET cNumeroInicial = '';
	LET cNumeroFinal = '';
	LET cStatus = '';
	LET cPeriodoExp = '';
	LET dFechaSolicitud = '';
	LET cComentario = '';
	LET cBin = '';
	LET cUsuario = '';
	LET cSerialFinal = '';

	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud,  cComentario, cUsuario;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_conscambiostatustarjetas.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
		END IF;					
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
		END IF;				
		
		--REALIZO SOLO LA CONSULTA A atm_tarjeta_admin
		IF pOperacion = 1  THEN
			
			IF pFechaBusqueda <> '' OR pFechaBusqueda IS NOT NULL THEN
			
				FOREACH 
					SELECT  SKIP pRegistros FIRST pRecuperacion numtarjetadmin, numtarjetasustituta, estatus, 
						periodoexptarjeta, DATE(fechasolicitud) AS fechasolicitud, descripcion_coment, usuario 
						INTO cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario
						--FROM  bdiatmist:"informix".atm_tarjeta_admin WHERE DATE(fechaSolicitud) = pFechaBusqueda
                          FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE DATE(fechaSolicitud) = pFechaBusqueda						
						ORDER BY numtarjetadmin										
			
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario WITH RESUME;
				END FOREACH;	
			
			ELIF pNoTarjeta <> '' THEN	
			
				--OBTENER VALOR DE CODIGO BIN
				SELECT valor
				INTO cBin
				--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 1;
				FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 1;
				
				LET cSerialFinal = (trim(cBin) || trim(pNoTarjeta));
				LET cSerialFinal = SUBSTRING(cSerialFinal FROM 1 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 5 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 9 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 13 FOR 4);
				
				FOREACH 
					SELECT  SKIP pRegistros FIRST pRecuperacion numtarjetadmin, numtarjetasustituta, estatus, 
						periodoexptarjeta, DATE(fechasolicitud) AS fechasolicitud, descripcion_coment, usuario 
						INTO cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario
						--FROM  bdiatmist:"informix".atm_tarjeta_admin WHERE numtarjetadmin = cSerialFinal
						FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE numtarjetadmin = cSerialFinal
						ORDER BY numtarjetadmin										
				
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario,cUsuario WITH RESUME;
				END FOREACH;
			
			ELIF pEstatus <> '' THEN
			
				FOREACH 
					SELECT  SKIP pRegistros FIRST pRecuperacion numtarjetadmin, numtarjetasustituta, estatus, 
						periodoexptarjeta, DATE(fechasolicitud)AS fechasolicitud, descripcion_coment, usuario 
						INTO cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario
						--FROM  bdiatmist:"informix".atm_tarjeta_admin WHERE estatus = pEstatus
						FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus = pEstatus
						ORDER BY numtarjetadmin										
				
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario WITH RESUME;
				END FOREACH;
			
			END IF;		
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
			END IF;	
			
		END IF;
	
		IF pOperacion = 2  THEN
		
			FOREACH 
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaTarjeta, '|')
				INTO cNumeroInicial
			
				SELECT estatus 
				INTO pEstatus
				--FROM bdiatmist:"informix".atm_tarjeta_admin
				FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
				WHERE numtarjetadmin = cNumeroInicial;
				
				IF pEstatus = 'SOL' THEN
					LET pEstatus = 'ENT';
				ELIF pEstatus = 'ENT' THEN
					LET pEstatus = 'ACT';
				END IF

				--UPDATE bdiatmist:"informix".atm_tarjeta_admin
                UPDATE bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 				
				SET estatus = pEstatus
				WHERE numtarjetadmin = cNumeroInicial;
			END FOREACH;	
		
			RETURN cCodRet, cNumeroInicial, cNumeroFinal, cStatus, cPeriodoExp, dFechaSolicitud, cComentario, cUsuario;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que realiza Consulta y Actualizacion de Estatus de Tarjetas Administrativas',	
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consestatustarjeta(pUsuario CHAR(8), pIdFuncion CHAR(10))							
		RETURNING CHAR(5) AS codret,
		    INTEGER AS id_tipo, 
			CHAR(60) AS desc_reposicion,
			CHAR(4) AS des_corta;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE cDesCorta CHAR(4);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET cDesCorta = '';
	LET iNoRegistros = 0;
	
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTipo, cDescripcion, cDesCorta;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consestatustarjeta.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTipo, cDescripcion, cDesCorta;
		END IF;					
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTipo, cDescripcion, cDesCorta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;                
		
		FOREACH 
			SELECT id_tipo, descripcion, des_corta
			INTO iTipo, cDescripcion, cDesCorta
			--FROM bdiatmist:atm_tipo_estatus
			FROM bdiatmist@stag_ids1170:"informix".atm_tipo_estatus
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iTipo, UPPER(TRIM(cDescripcion)), UPPER(TRIM(cDesCorta)) WITH RESUME;
		END FOREACH;
	
		IF iNoRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, iTipo, cDescripcion, cDesCorta;
        END IF;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 10/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta para llenado de combo de Estatus Tarjetas Administrativas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consparamsolicitartarjeta(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumTarjSolicitar CHAR(4), pFechaSolicitud DATE, pPeriodoExpTarjeta CHAR(3), pOperacion CHAR(1))							
		RETURNING CHAR(5) AS codret,
			CHAR(10) AS valor_bin, 
			CHAR(19) AS serial_final;					
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cBin CHAR(10);			
	DEFINE cSerialFinal CHAR(100);
	DEFINE iLote INTEGER;
	DEFINE iSerialFinal INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE index_var INTEGER;
	DEFINE iInicio INTEGER;
	DEFINE dFechaCancelada DATE;
	DEFINE cTarjetaSustituta CHAR(16);
	DEFINE cStatus CHAR(3);
	DEFINE cDescripComent CHAR(60);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cBin = '';
	LET iLote = '';
	LET cSerialFinal = '';
	LET iSerialFinal = 0;
	LET iNoRegistros = 0;
	LET index_var = 0;
	LET iInicio = 0;
	LET dFechaCancelada = '';
	LET cTarjetaSustituta = '';
	LET cStatus = 'SOL';
	LET cDescripComent = '';	
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBin, cSerialFinal;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consparamsolicitartarjeta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cBin, cSerialFinal;
		END IF;	
		
		IF pOperacion = 2 THEN
			IF pNumTarjSolicitar = '' OR pFechaSolicitud = '' OR pPeriodoExpTarjeta = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBin, cSerialFinal;
			END IF;
		END IF;		
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cBin, cSerialFinal;
		END IF;
		
		--OBTENER NUMERO INICIO-NUMERO FINAL
		IF pOperacion = '1' THEN
		
			--OBTENER VALOR DE CODIGO BIN
			FOREACH 
				SELECT valor
					INTO cBin
				--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 1
				FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 1
				
				--OBTENER VALOR DE SERIALFINAL
				SELECT valor
					INTO cSerialFinal
				--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 2;
				FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 2;
				
				LET iNoRegistros = iNoRegistros + 1;
				
				IF iNoRegistros > 0 THEN
					LET cCodRet = '00000';
				END IF;
				
				RETURN cCodRet, TRIM(cBin), (TRIM(cBin) || TRIM(cSerialFinal)) WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cBin, cSerialFinal;
			END IF;						
		
		END IF;
		
		IF pOperacion = '2' THEN	
		
			--OBTENER VALOR DE CODIGO BIN
			SELECT valor
				   INTO cBin
			--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 1;
			FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 1;
			
			--OBTENER VALOR DE SERIALFINAL
			SELECT valor
				   INTO cSerialFinal
			--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 2;
			FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 2;
			
			--OBTENER VALOR DE LOTE
			SELECT valor
				   INTO iLote
			--FROM  bdiatmist:"informix".atm_param WHERE cod_param = 3;
            FROM  bdiatmist@stag_ids1170:"informix".atm_param WHERE cod_param = 3;			
			
			LET iSerialFinal = cSerialFinal - 1;																
			
			WHILE(iInicio < pNumTarjSolicitar) LOOP
				LET iInicio = iInicio + 1;
				LET iSerialFinal = iSerialFinal + 1;
				LET cSerialFinal = TRIM(cBin) || LPAD(iSerialFinal, 10, '0');
				LET cSerialFinal = SUBSTRING(cSerialFinal FROM 1 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 5 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 9 FOR 4) || ' ' || SUBSTRING(cSerialFinal FROM 13 FOR 4);
				
				--INSERT INTO bdiatmist:"informix".atm_tarjeta_admin VALUES(iLote, cSerialFinal, CURRENT, dFechaCancelada, cTarjetaSustituta, cStatus, pPeriodoExpTarjeta, cDescripComent, pUsuario, '');	
                INSERT  INTO bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin VALUES(iLote, cSerialFinal, CURRENT, dFechaCancelada, cTarjetaSustituta, cStatus, pPeriodoExpTarjeta, cDescripComent, pUsuario, '');					
				
				IF iInicio = pNumTarjSolicitar THEN
				
					LET iSerialFinal = iSerialFinal + 1;
					LET iLote = iLote + 1;
					
					--ACTUALIZA SERIAL FINAL
					--UPDATE bdiatmist:"informix".atm_param SET valor = LPAD(iSerialFinal, 10, '0') WHERE cod_param = 2;
					UPDATE bdiatmist@stag_ids1170:"informix".atm_param SET valor = LPAD(iSerialFinal, 10, '0') WHERE cod_param = 2;
					--ACTUALIZA NUMERO DE LOTE
					--UPDATE bdiatmist:"informix".atm_param SET valor = iLote WHERE cod_param = 3;
					UPDATE bdiatmist@stag_ids1170:"informix".atm_param SET valor = iLote WHERE cod_param = 3;
				
				END IF			
				
				EXIT WHEN iInicio = pNumTarjSolicitar;
			END LOOP;	
			
			RETURN cCodRet, cBin, cSerialFinal;
			
		END IF;			
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta parametros para Opcion Solicitar Tarjeta',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 18/11/2016',
'DESCRIPCION: Se Modifica sp para insertar la fecha de cancelacion vacia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_constarjetasmotivoreposicion(pUsuario CHAR(8), pIdFuncion CHAR(10))							
		RETURNING CHAR(5) AS codret,
		    INTEGER AS id_tipo, 
			CHAR(60) AS desc_reposicion;					
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTipo, cDescripcion;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_constarjetasmotivoreposicion.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTipo, cDescripcion;
		END IF;					
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTipo, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;                
		
		FOREACH 
			SELECT id_tipo, descripcion
			INTO iTipo, cDescripcion
			--FROM bdiatmist:"informix".atm_tipo_reposicion
			FROM bdiatmist@stag_ids1170:"informix".atm_tipo_reposicion
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iTipo, UPPER(TRIM(cDescripcion)) WITH RESUME;
		END FOREACH;
	
		IF iNoRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, iTipo, cDescripcion;
        END IF;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta Tipo de Reposicion para llenado de combo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_tarjetamotivoreposicion(pUsuario CHAR(8), pIdFuncion CHAR(10), pRangoDe CHAR(16), pRangoHasta CHAR(16), 
pPeriodoExpTarjeta CHAR(3), pTotalRango CHAR(4), pFechaCancelacion DATE, pComentario CHAR(60), pOperacion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)							
		RETURNING CHAR(5) AS codret,
			CHAR(19) AS tarjeta_sustituir,
			CHAR(19) AS tarjeta_sustituta,
			CHAR(5) AS fecha_expira;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTipo INTEGER;
	DEFINE cDescripcion CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE iTotalDisponibles INTEGER;
	DEFINE cTarjetaSustituir CHAR(19);
	DEFINE cTarjetaSutituta CHAR(19);
	DEFINE cBin CHAR(10);	
	DEFINE cTotalRango CHAR(4);
	DEFINE cDe CHAR(19);
	DEFINE cHasta CHAR(19);
	DEFINE cFechaExp CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTipo = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	LET iTotalDisponibles = 0;
	LET cTarjetaSustituir = '';
	LET cTarjetaSutituta = '';
	LET cBin = '';		
	LET cTotalRango = pTotalRango;
	LET cDe = ''; 
	LET cHasta = '';	
	LET cFechaExp = '';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_tarjetamotivoreposicion.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;					
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;		
		
		--OBTENER VALOR DE CODIGO BIN
		SELECT valor
	        INTO cBin
		--FROM  bdiatmist:"informix".atm_param 
		FROM  bdiatmist@stag_ids1170:"informix".atm_param 
		WHERE cod_param = 1;
		
		LET pRangoDe = TRIM(cBin) || pRangoDe;
		LET pRangoHasta = TRIM(cBin) || pRangoHasta;
		
		LET cDe = SUBSTRING(pRangoDe FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 13 FOR 4);
		LET cHasta = SUBSTRING(pRangoHasta FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 13 FOR 4);		
		
		-- VALIDACION QUE EXISTAN TARJETAS PARA REALIZAR REPOSICION	
		SELECT COUNT(*) 
			INTO iTotalDisponibles
		---FROM bdiatmist:atm_tarjeta_admin 
		FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
		WHERE estatus = 'ENT';
		
		SELECT COUNT(*) 
			INTO cTotalRango
		--FROM bdiatmist:atm_tarjeta_admin 
		FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
		WHERE numtarjetadmin 
		BETWEEN cDe AND cHasta	
		AND numtarjetasustituta = ''
		AND estatus <> 'ENT';
		
		IF iTotalDisponibles <  cTotalRango THEN 
			LET cCodRet = '00891';
			RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
		END IF;
		
		--REALIZO SOLO LA CONSULTA A atm_tarjeta_admin
		IF pOperacion = 1  THEN
			
			FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion numtarjetadmin, periodoexptarjeta
						INTO cTarjetaSustituir, cFechaExp
					--FROM  bdiatmist:"informix".atm_tarjeta_admin  
					FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					WHERE numtarjetadmin 
					BETWEEN cDe AND cHasta
					AND estatus IN ('SOL','ACT')
					AND numtarjetasustituta = ''
					ORDER BY numtarjetadmin											
				FOREACH cTarjetaSustituir FOR			
					SELECT numtarjetadmin		
						INTO cTarjetaSutituta
					--FROM  bdiatmist:"informix".atm_tarjeta_admin 
					FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					WHERE estatus = 'ENT' 						
					AND numtarjetadmin > cTarjetaSutituta
					ORDER BY numtarjetadmin DESC														
				END FOREACH; 
			
				LET iNoRegistros = iNoRegistros + 1;
			
				RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp WITH RESUME;
			END FOREACH;				
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN  cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN  cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp;
			END IF;	
		END IF;
	
		--Realiza actualizacion de Estatus 
		IF pOperacion = 2 THEN			
			
			FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion numtarjetadmin, periodoexptarjeta
					INTO cTarjetaSustituir, cFechaExp
				--FROM  bdiatmist:"informix".atm_tarjeta_admin
                  FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin  				
				WHERE numtarjetadmin 
				BETWEEN cDe AND cHasta 
				AND estatus IN ('SOL','ACT')
				AND numtarjetasustituta = ''
				ORDER BY numtarjetadmin									
				
				FOREACH cTarjetaSustituir FOR					
					SELECT  numtarjetadmin		
						INTO cTarjetaSutituta
					--FROM  bdiatmist:"informix".atm_tarjeta_admin 
					FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					WHERE estatus = 'ENT'						
					AND numtarjetadmin > cTarjetaSutituta
					ORDER BY numtarjetadmin DESC
					
					--UPDATE bdiatmist:"informix".atm_tarjeta_admin  
					UPDATE bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 
					SET fechacancelacion = CURRENT,
						numtarjetasustituta = cTarjetaSutituta,
						estatus = 'CAN',							
						descripcion_coment = pComentario
					WHERE numtarjetadmin =	cTarjetaSustituir;																	
				END FOREACH; 
				
				FOREACH 
					SELECT  numtarjetasustituta	
						INTO cTarjetaSutituta
					--FROM  bdiatmist:"informix".atm_tarjeta_admin
                    FROM  bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin 					
					WHERE numtarjetadmin 
					BETWEEN cDe AND cHasta
					AND numtarjetasustituta IS NOT NULL
					AND numtarjetasustituta <> ''
					AND estatus = 'CAN'   
				
					--UPDATE bdiatmist:"informix".atm_tarjeta_admin
					UPDATE bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
					SET  estatus = 'ACT'
					WHERE numtarjetadmin = cTarjetaSutituta
					AND numtarjetasustituta = ''
					AND estatus = 'ENT';	
				END FOREACH;									
	
				RETURN cCodRet, cTarjetaSustituir, cTarjetaSutituta, cFechaExp WITH RESUME;				
			
			END FOREACH;	
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que realiza Consulta para Reposicion de Tarjetas',	
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 18/11/2016',
'DESCRIPCION: Se Modifica sp para realizar sustitucion de tarjetas con tarjetas con estatus ENT',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_tarjetamotivoreposicion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pRangoDe CHAR(16), pRangoHasta CHAR(16), 
pPeriodoExpTarjeta CHAR(3), pTotalRango CHAR(4), pFechaCancelacion DATE, pComentario CHAR(60), pOperacion CHAR(1))							
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros,
			INTEGER AS num_porasignar;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iNoRegPorAsignar INTEGER;
	DEFINE cStatus CHAR(3);
    DEFINE cNumeroTarjeta CHAR(3);	
	DEFINE dFecha DATE;
	DEFINE cBin CHAR(10);
	DEFINE cDe CHAR(19);
	DEFINE cHasta CHAR(19);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iNoRegPorAsignar = 0;
	LET cBin = '';		
	LET cDe = ''; 
	LET cHasta = '';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_tarjetamotivoreposicion_totales.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF pOperacion = 1 THEN	
		
			SELECT COUNT(*),
			--(SELECT COUNT(*) FROM bdiatmist:"informix".atm_tarjeta_admin WHERE estatus='ENT')
			(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
            INTO iNoRegistros, iNoRegPorAsignar
           -- FROM bdiatmist:"informix".atm_tarjeta_admin;  
		     FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin;  
		
		ELIF pOperacion = 2 THEN 
		
			--OBTENER VALOR DE CODIGO BIN
			SELECT valor
			INTO cBin
			--FROM bdiatmist:"informix".atm_param 
			FROM bdiatmist@stag_ids1170:"informix".atm_param 
			WHERE cod_param = 1;
		
			LET pRangoDe = TRIM(cBin) || pRangoDe;
			LET pRangoHasta = TRIM(cBin) || pRangoHasta;
			LET cDe = SUBSTRING(pRangoDe FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoDe FROM 13 FOR 4);
			LET cHasta = SUBSTRING(pRangoHasta FROM 1 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 5 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 9 FOR 4) || ' ' || SUBSTRING(pRangoHasta FROM 13 FOR 4);		
			
			SELECT COUNT(*),
			--(SELECT COUNT(*) FROM bdiatmist:"informix".atm_tarjeta_admin WHERE estatus='ENT')
			(SELECT COUNT(*) FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin WHERE estatus='ENT')
			INTO iNoRegistros, iNoRegPorAsignar
			--FROM bdiatmist:"informix".atm_tarjeta_admin
			FROM bdiatmist@stag_ids1170:"informix".atm_tarjeta_admin
			WHERE numtarjetasustituta = '' AND numtarjetadmin 
			BETWEEN cDe AND cHasta; 
			
		END IF;			 				
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00000';
			LET iNoRegistros = 0;
			LET iNoRegPorAsignar = 0;
		END IF;	
		
		RETURN cCodRet, iNoRegistros, iNoRegPorAsignar;		
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/10/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Gestor Tarjetas Administrativas',
'DESCRIPCION: SPL que consulta Totales de Tarjetas Administrativas',
'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 09/11/2016',
'DESCRIPCION: Se Modifica sp para atencion del cambio de formato de Tarjeta Solicitada y Tarjeta Sustituta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_portanom_obtieneruta(pUsuario CHAR(8), pIdFuncion CHAR(10), pOperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(50) AS ruta_archivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cRutaArchivo CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cRutaArchivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cRutaArchivo;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_portanom_obtieneruta.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cRutaArchivo;
		END IF;
		
		IF pOperacion NOT IN (1, 2, 3, 4, 5) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cRutaArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cRutaArchivo;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_obtrutasportabilidad(pOperacion)
		INTO cCodRetSp, cRutaArchivo;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP ";
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00044';
		END IF;
		
		RETURN cCodRet, cRutaArchivo;
	
	END;
	
END PROCEDURE;