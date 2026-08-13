CREATE PROCEDURE "informix".sp_obtenercanaloperacion (pIdCanal SMALLINT, pNombreCanal CHAR(30), pIdOperaciones SMALLINT, pDescOperacion CHAR(30), pNumproducto CHAR(4), pTipoEjecucion CHAR(1))	
	RETURNING 	CHAR(5),
				SMALLINT,
				CHAR(30),
				SMALLINT,
				CHAR(30);
                			
	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE cCodRet           			CHAR(5);
	DEFINE sClave						SMALLINT;
	DEFINE cDescripcion					CHAR(30);
	DEFINE scvecanal					SMALLINT;
	DEFINE cNombreCanal				    CHAR(30);
	DEFINE sIdOperaciones				SMALLINT;
	DEFINE cDescOperacion				CHAR(30);
	DEFINE sExiste						SMALLINT;

	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET cCodRet              		= '00000';
	LET sClave						= 0;
	LET cDescripcion				= '';
	LET scvecanal					= 0;
	LET cNombreCanal				= '';
	LET sIdOperaciones				= 0;
	LET cDescOperacion				= '';
	LET sExiste						= 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,sClave, cDescripcion, '', '';
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/tmp/anj/sp_obtenercanaloperacion.out"; 
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipoEjecucion = '1' THEN
			--Obtiene los canales de operacion
			FOREACH
				SELECT cve_canal, nombre_canal   
				INTO sClave, cDescripcion
				FROM bdinteg:"informix".si_canal
				ORDER BY cve_canal
				
				RETURN cCodRet, sClave, cDescripcion, '', '' WITH RESUME;
			END FOREACH;
		ELIF pTipoEjecucion = '2' THEN
			--Obtiene las funciones de operacion
			FOREACH
				SELECT cod_operaciones, desc_operacion   
				INTO sClave, cDescripcion
				FROM bdicred:"informix".sd_operaciones
				ORDER BY cod_operaciones
				
				RETURN cCodRet, sClave, cDescripcion, '', '' WITH RESUME;
			END FOREACH;
		ELIF pTipoEjecucion = '3' THEN
			IF pIdCanal <> 0 AND pNombreCanal <> '' AND pIdOperaciones <> 0 AND pDescOperacion <> '' THEN
				--Realiza la insercion a la tabla temporal tmp_operaciones_canal de los datos capturados por el cliente
				INSERT INTO bdicred:"informix".tmp_operaciones_canal(id_canal, nombre_canal, id_operaciones, desc_operacion )
					VALUES(pIdCanal, pNombreCanal, pIdOperaciones, pDescOperacion); 
				
				RETURN cCodRet,sClave, cDescripcion, '', '';
			END IF;
		ELIF pTipoEjecucion = '4' THEN  -- Obten informaciÃ³n actual de canales del producto
		
			SELECT count(*) INTO sExiste 
			FROM "informix".tmp_operaciones_canal;

			IF sExiste = 0 THEN		
				FOREACH
					SELECT c.cve_canal, c.nombre_canal, b.cod_operaciones, b.desc_operacion
					INTO scvecanal, cNombreCanal, sIdOperaciones, cDescOperacion
					FROM "informix".sd_operaciones_canal a
					INNER JOIN bdicred:"informix".sd_operaciones b ON (a.cod_operaciones = b.cod_operaciones)
					INNER JOIN bdinteg:"informix".si_canal c ON (a.cve_canal = c.cve_canal)
					WHERE num_producto = pNumproducto
			
					--Realiza la insercion a la tabla temporal tmp_operaciones_canal de los datos capturados por el cliente
					INSERT INTO bdicred:"informix".tmp_operaciones_canal(id_canal, nombre_canal, id_operaciones, desc_operacion )
						VALUES(scvecanal, cNombreCanal, sIdOperaciones, cDescOperacion); 

				END FOREACH;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					LET cDescripcion = 'No existe informaciÃ³n de digitalizacion para el producto consultado';
					RETURN cCodRet,'','','','';
				END IF;
			END IF;
			FOREACH
				SELECT id_canal, nombre_canal, id_operaciones, desc_operacion 
				INTO scvecanal, cNombreCanal, sIdOperaciones, cDescOperacion
				FROM "informix".tmp_operaciones_canal  
				
				RETURN cCodRet, scvecanal, cNombreCanal, sIdOperaciones, cDescOperacion WITH RESUME;
						
			END FOREACH;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet,sClave, cDescripcion, '', '';
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_obtenercanaloperacion" para obtener los canales de operacion seleccionados por el cliente',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_obtenerdoctosimprimir (pCodigoDocumento CHAR(4), pDescripcionDocumento CHAR(40), pCantidad INTEGER, pNum_producto CHAR(4), pTipoEjecucion CHAR(1))
	RETURNING 	CHAR(5),
				CHAR(4),
				CHAR(40),
				INTEGER;

	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE cCodRet           			CHAR(5);
	DEFINE cCodigoDocumento				CHAR(4);
	DEFINE cDescripcionDocumento		CHAR(40);
	DEFINE iCantidad					INTEGER;
	DEFINE sExiste						SMALLINT;

	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET cCodRet              		= '00000';
	LET cCodigoDocumento			= '';
	LET cDescripcionDocumento		= '';
	LET iCantidad					= 0;
	LET sExiste						= 0;


	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCodigoDocumento, cDescripcionDocumento,0;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/anj/sp_obtenerdoctosimprimir.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pTipoEjecucion = '1' THEN
			--Obtiene los documentos requeridos para la impresiÃÂ³n
			FOREACH
				SELECT codigo_documento,descripcion_documento
				INTO cCodigoDocumento, cDescripcionDocumento
				FROM bdicred:"informix".sd_doctos_imprimir
				ORDER BY codigo_documento

				RETURN cCodRet, cCodigoDocumento, cDescripcionDocumento,0 WITH RESUME;
			END FOREACH;
		ELIF pTipoEjecucion = '2' THEN
			IF pCodigoDocumento <> '' AND pDescripcionDocumento <> '' AND pCantidad <> 0 THEN
				--Realiza la insercion a la tabla tmp_doctos_imprimir de los datos capturados por el cliente
				INSERT INTO bdicred:"informix".tmp_doctos_imprimir(codigo_documento,descripcion_documento,cantidad )
					VALUES(pCodigoDocumento, pDescripcionDocumento, pCantidad );

				RETURN cCodRet,cCodigoDocumento, cDescripcionDocumento, pCantidad;
			END IF;
		ELIF pTipoEjecucion = '3' THEN

			SELECT count(*) INTO sExiste
			FROM "informix".tmp_doctos_imprimir;

			IF sExiste = 0 THEN
				FOREACH
					SELECT a.cod_docto, b.descripcion_documento, a.cantidad
					INTO cCodigoDocumento, cDescripcionDocumento, iCantidad
					FROM bdicred:"informix".sd_doctosimprimexproducto a
					INNER JOIN bdicred:"informix".sd_doctos_imprimir b ON (a.cod_docto = b.codigo_documento)
					WHERE a.num_producto = pNum_producto

					--Realiza la insercion a la tabla tmp_doctos_imprimir de los datos capturados por el cliente
					INSERT INTO bdicred:"informix".tmp_doctos_imprimir(codigo_documento,descripcion_documento,cantidad )
						VALUES(cCodigoDocumento, cDescripcionDocumento, iCantidad);
				END FOREACH;
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					RETURN cCodRet,cCodigoDocumento, cDescripcionDocumento, iCantidad;
				END IF;
			END IF;
			FOREACH
				SELECT codigo_documento,descripcion_documento,cantidad
				INTO cCodigoDocumento, cDescripcionDocumento, iCantidad
				FROM bdicred:"informix".tmp_doctos_imprimir

				RETURN cCodRet,cCodigoDocumento, cDescripcionDocumento, iCantidad WITH RESUME;
			END FOREACH;
		END IF;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet,cCodigoDocumento, cDescripcionDocumento, 0;
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_obtenerdoctosimprimir" para obtener los documentos a imprimir seleccionados por el cliente',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_obtenertasasdiferenciadas (pEmpresa CHAR(3), pProducto CHAR(4),pSubProducto CHAR(4), pGrupo CHAR(1),pModeloHitBuenoOrdnario	DECIMAL(11,6),pModeloHitMaloOrdnario DECIMAL(11,6),pModeloNoHitOrdnario	DECIMAL(11,6),pModeloHitBuenoMoratorio	DECIMAL(11,6),pModeloHitMaloMoratorio DECIMAL(11,6),pModeloNoHitMoratorio DECIMAL(11,6),pTipoEjecucion CHAR(1))	
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(1) AS Grupo,
				DECIMAL(11,6) AS Modelo_Hit_Bueno_ordinario,
				DECIMAL(11,6) AS Modelo_Hit_Malo_ordinario,
				DECIMAL(11,6) AS Modelo_NO_Hit_ordinario,
				DECIMAL(11,6) AS Modelo_Hit_Bueno_moratorio,
				DECIMAL(11,6) AS Modelo_Hit_Malo_moratorio,
				DECIMAL(11,6) AS Modelo_NO_Hit_moratorio;
                			
	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE isam_err         			INTEGER;
	DEFINE error_info       			VARCHAR(60);
	DEFINE cCodRet           			CHAR(5);
	DEFINE cGrupo						CHAR(1);
	DEFINE dHit_bueno_ordnario			DECIMAL(11,6);
	DEFINE dHit_malo_ordnario			DECIMAL(11,6);
	DEFINE dModelo_no_hit_ordinario		DECIMAL(11,6);
	DEFINE dHit_bueno_moratorio			DECIMAL(11,6);
	DEFINE dHit_malo_moratorio			DECIMAL(11,6);
	DEFINE dModelo_no_hit_moratorio		DECIMAL(11,6);
	DEFINE cSubProducto 				CHAR(4);
	
	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET isam_err            		= 0;
	LET error_info          		= "";
	LET cCodRet              		= '00000';
	LET cGrupo						= '';
	LET dHit_bueno_ordnario			= 0;
	LET dHit_malo_ordnario			= 0;
	LET dModelo_no_hit_ordinario	= 0;
	LET dHit_bueno_moratorio		= 0;
	LET dHit_malo_moratorio			= 0;
	LET dModelo_no_hit_moratorio	= 0;
	LET cSubProducto          		= "";
	
	BEGIN
		ON EXCEPTION SET iSqlErr, isam_err, error_info
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'','','','','','','';
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/tmp/anj/sp_obtenertasasdiferenciadas.out"; 
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipoEjecucion = '1' THEN
			IF pProducto <> '' AND pSubProducto = '' THEN
				---Se obtienen las Tasas de interes ordinaria y moratoria del Producto Padre
				FOREACH 
					SELECT a.grupo, a.tasa_int_ordinaria, b.tasa_int_ordinaria, c.tasa_int_ordinaria, a.tasa_int_moratoria, b.tasa_int_moratoria, c.tasa_int_moratoria
					INTO cGrupo, dHit_bueno_ordnario, dHit_malo_ordnario, dModelo_no_hit_ordinario, dHit_bueno_moratorio,dHit_malo_moratorio,dModelo_no_hit_moratorio
					FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas a 
					INNER JOIN bdicred:"informix".sd_tasas_disposiciones_diferenciadas b ON (a.grupo = b.grupo AND a.num_producto = b.num_producto AND b.evalua_cc = '1') --Evalua_cc = 1 --> Modelo Hit Malo
					INNER JOIN bdicred:"informix".sd_tasas_disposiciones_diferenciadas c ON (b.grupo = c.grupo AND b.num_producto = c.num_producto AND c.evalua_cc = 'X') --Evalua_cc = X --> Modelo No Hit  
					WHERE a.num_producto = pProducto AND a.evalua_cc = '0'  --Evalua_cc = 0 --> Modelo Hit Bueno
					ORDER BY grupo
					
					RETURN cCodRet,cGrupo, dHit_bueno_ordnario, dHit_malo_ordnario, dModelo_no_hit_ordinario,dHit_bueno_moratorio,dHit_malo_moratorio,dModelo_no_hit_moratorio WITH resume;
				END FOREACH;
			ELIF pProducto <> '' AND pSubProducto <> '' THEN
				IF LENGTH(TRIM(pSubProducto)) < 2 THEN
					LET cSubProducto = CONCAT(SUBSTR(TRIM(pProducto),1,2), CONCAT('0',pSubProducto));
				ELSE
					LET cSubProducto = CONCAT(SUBSTR(TRIM(pProducto),1,2), pSubProducto);
				END IF;
				---Se obtienen las Tasas de interes ordinaria y moratoria del SubProducto
				FOREACH 
					SELECT a.grupo, a.tasa_int_ordinaria, b.tasa_int_ordinaria, c.tasa_int_ordinaria, a.tasa_int_moratoria, b.tasa_int_moratoria, c.tasa_int_moratoria
					INTO cGrupo, dHit_bueno_ordnario, dHit_malo_ordnario, dModelo_no_hit_ordinario, dHit_bueno_moratorio,dHit_malo_moratorio,dModelo_no_hit_moratorio
					FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas a 
					INNER JOIN bdicred:"informix".sd_tasas_disposiciones_diferenciadas b ON (a.grupo = b.grupo AND a.num_producto = b.num_producto AND b.evalua_cc = '1') --Evalua_cc = 1 --> Modelo Hit Malo
					INNER JOIN bdicred:"informix".sd_tasas_disposiciones_diferenciadas c ON (b.grupo = c.grupo AND b.num_producto = c.num_producto AND c.evalua_cc = 'X') --Evalua_cc = X --> Modelo No Hit  
					WHERE a.num_producto = cSubProducto AND a.id_subproducto = pSubProducto AND a.evalua_cc = '0'  --Evalua_cc = 0 --> Modelo Hit Bueno
					ORDER BY grupo
					
					RETURN cCodRet,cGrupo, dHit_bueno_ordnario, dHit_malo_ordnario, dModelo_no_hit_ordinario,dHit_bueno_moratorio,dHit_malo_moratorio,dModelo_no_hit_moratorio WITH resume;
				END FOREACH;
			
			END IF;
		ELIF pTipoEjecucion = '2' THEN
			IF pEmpresa <> '' AND pProducto <> '' AND pGrupo <> '' AND pModeloHitBuenoOrdnario <> 0 AND pModeloHitMaloOrdnario <> 0 AND pModeloNoHitOrdnario <> 0 AND pModeloHitBuenoMoratorio <> 0 AND pModeloHitMaloMoratorio <> 0 AND pModeloNoHitMoratorio <> 0 THEN
				--Se Registra en la tabla 'tmp_tasas_diferenciadas' los datos capturados por el cliente
				INSERT INTO bdicred:"informix".tmp_tasas_diferenciadas(empresa, num_producto, grupo,modelo_hit_bueno_ordnario,modelo_hit_malo_ordnario,modelo_no_hit_ordinario,modelo_hit_bueno_moratorio,modelo_hit_malo_moratorio,modelo_no_hit_moratorio,fecha_insert)
					VALUES(pEmpresa, pProducto, pGrupo, pModeloHitBuenoOrdnario, pModeloHitMaloOrdnario, pModeloNoHitOrdnario, pModeloHitBuenoMoratorio , pModeloHitMaloMoratorio, pModeloNoHitMoratorio, current); 
				
				RETURN cCodRet,'','','','','','','';
			END IF;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet,'','','','','','','';
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_obtenertasasdiferenciadas" para obtener las tasas de interes de los productos seleccionados por el cliente',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_obtentipoedocta()

RETURNING CHAR(5) AS CodRet, --codigo de retorno
		  CHAR(3) AS id_estdocta, --id de estado de cuenta
		  VARCHAR(40) AS desc_estdocta; --descripcion de estado de cuenta

DEFINE cCodRet CHAR(5);
DEFINE iSqlErr  INTEGER;
DEFINE cid_estdocta VARCHAR(3);
DEFINE cDesc_Estdocta VARCHAR(40);

LET cCodRet = '00000';
LET iSqlErr = 0;
LET cId_Estdocta = '';
LET cDesc_Estdocta = '';

	BEGIN
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cId_Estdocta,cDesc_Estdocta;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/ifxsif01/home/e_efierro/sp_obtentipoedocta.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT id_estdocta,desc_estdocta
			INTO cId_Estdocta,cDesc_Estdocta
			FROM "informix".sd_tipo_edocta

			RETURN cCodRet,TRIM(cId_Estdocta),TRIM(cDesc_Estdocta) WITH RESUME;
		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00001';  --No hay informacion
			RETURN cCodRet,TRIM(cId_Estdocta),TRIM(cDesc_Estdocta);
		END IF;
	END
END PROCEDURE;