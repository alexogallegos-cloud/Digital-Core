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