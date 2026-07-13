CREATE PROCEDURE "informix".sp_conspoliticacreditoprod (pEmpresa char(3),pNumProducto char(4), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(4) AS Num_Producto,
				CHAR(1) AS Respuesta_Sic,
				CHAR(50) AS modelo,
				CHAR(1) AS Grupo,
				INT AS ScoreMin_grupo1,
				INT AS ScoreMax_grupo1,
				INT AS ProScoreMin_grupo1,
				INT AS ProScoreMax_grupo1,
				CHAR(2) AS Status_Sol;

	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE cCodRet           			CHAR(5);
	DEFINE cNumProducto					CHAR(4);
	DEFINE cRespuestaSic				CHAR(1);
	DEFINE cGrupo			          	CHAR(1);
	DEFINE cModelo			          	CHAR(50);
	DEFINE cStatusSol			     	CHAR(2);
	DEFINE iBcScoreMin1			    	INT;
	DEFINE iBcScoreMax1			    	INT;
	DEFINE iProScoreMin1		    	INT;
	DEFINE iProScoreMax1		    	INT;

	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET cCodRet              		= '00000';
	LET cNumProducto				= '';
	LET cRespuestaSic				= '';
	LET cGrupo						= '';
	LET cModelo						= '';
	LET cStatusSol					= '';
	LET iBcScoreMin1				= 0;
	LET iBcScoreMax1				= 0;
	LET iProScoreMin1				= 0;
	LET iProScoreMax1				= 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumProducto,cRespuestaSic,cModelo,cGrupo,
					   iBcScoreMin1, iBcScoreMax1,iProScoreMin1,iProScoreMax1,cStatusSol;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/JoseLuisG/Pruebas_Politicas_de_Credito/sp_conspoliticacreditoprod.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF NVL(pEmpresa,'') = '' OR NVL(pNumProducto,'') = ''  THEN
			LET cCodRet = '00001';
			RETURN cCodRet, cNumProducto,cRespuestaSic,cModelo,cGrupo,
					   iBcScoreMin1, iBcScoreMax1,iProScoreMin1,iProScoreMax1,cStatusSol;
		ELSE
			--Obtiene las politicas de credito del producto seleccionado.
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion tot.num_producto,tot.respuesta_sic, CASE WHEN tot.respuesta_sic = '0' THEN 'HIT con InformaciÃ³n' ELSE (CASE WHEN tot.respuesta_sic = 'X' THEN 'NO HIT' ELSE 'HIT sin informaciÃ³n'END) END AS Modelo, tot.grupo,
				  tot.bc_scoremin as BcScoreMin, tot.bc_scoremax as BcScoreMax, tot.pro_scormin as ProScoreMin, tot.pro_scormax as ProScoreMax,
				   tot.status_sol
				INTO cNumProducto,cRespuestaSic,cModelo,cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1,cStatusSol
				FROM bdisolic:'informix'.ss_scoring_modelo2 tot
				WHERE tot.num_producto = pNumProducto AND tot.grupo IN (SELECT DISTINCT grupo FROM bdisolic:'informix'.ss_scoring_modelo2) order by grupo,respuesta_sic

				RETURN cCodRet,cNumProducto,cRespuestaSic,cModelo,cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1,cStatusSol WITH RESUME;

			END FOREACH;

		END IF;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet, cNumProducto,cRespuestaSic,cModelo,cGrupo,
					   iBcScoreMin1, iBcScoreMax1,iProScoreMin1,iProScoreMax1,cStatusSol;
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_conspoliticacreditoprod" para obtener la informaciÃÂÃÂ³n puntajes de Bcscore y Score propietario mÃÂÃÂ­nimo y mÃÂÃÂ¡ximo definidos para ser Autorizada o Rechazada que actualmente tiene registrada el producto',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_conv_productos(pProducto CHAR(4), pTipoEjecucion CHAR(1))
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(2) AS Sistema,
				CHAR(4) AS Num_producto,
				CHAR(40) AS Nombre_producto;

	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE isam_err         			INTEGER;
	DEFINE error_info       			VARCHAR(60);
	DEFINE cCodRet           			CHAR(5);
	DEFINE cNum_producto				CHAR(4);
	DEFINE cNombre_producto				CHAR(40);
	DEFINE cSistema     		    	CHAR(2);

	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET isam_err            		= 0;
	LET error_info          		= "";
	LET cCodRet              		= '00000';
	LET cNum_producto				= '';
	LET cNombre_producto			= '';
	LET cSistema					= '';


	BEGIN
		ON EXCEPTION SET iSqlErr, isam_err, error_info
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'','','';
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/anj/sp_consulta_conv_productos.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;

		IF pTipoEjecucion = '1' THEN
			--Consulta para obtener los productos crÃÂÃÂ©dito y debito disponibles
			FOREACH
				SELECT '06', num_producto,nombre_prod
					INTO cSistema, cNum_producto,cNombre_producto
					FROM bdicred:sd_definicion WHERE num_producto NOT IN ('7200','7300','7400','7500')
					AND num_producto NOT IN (SELECT {+INDEX(bdisolic:ss_tramite_productos_clasif idx_ss_tramite_productos_clasif)} prod_ofrecer FROM bdisolic:ss_tramite_productos_clasif
					   WHERE clasificacion IN (select clasificacion from bdisolic:ss_tramite_productos WHERE prod_actual = pProducto)
					AND sistema = '06')
					UNION ALL
					SELECT {+INDEX(bdicheq:sc_producto idx_producto1)} '01', producto,nombre FROM bdicheq:sc_producto WHERE producto NOT IN ('1200','9900','1600','9901','2200','2300','2500','2600','2700','2800','5000','8000','9999')
					AND producto NOT IN (SELECT {+INDEX(bdisolic:ss_tramite_productos_clasif idx_ss_tramite_productos_clasif)} prod_ofrecer FROM bdisolic:ss_tramite_productos_clasif
					   WHERE clasificacion IN (select clasificacion from bdisolic:ss_tramite_productos WHERE prod_actual = pProducto)
					AND sistema = '01')
										
					IF 	cNum_producto = pProducto THEN
						CONTINUE FOREACH;
					END IF;

				RETURN cCodRet, cSistema, cNum_producto,cNombre_producto WITH RESUME;
			END FOREACH;
		ELIF pTipoEjecucion = '2' THEN
			--Consulta para obtener los productos crÃÂÃÂ©dito y debito ya asignados
			FOREACH
				SELECT b.sistema, a.num_producto, a.nombre_prod
				INTO cSistema, cNum_producto, cNombre_producto
				FROM bdicred:sd_definicion a
				INNER JOIN bdisolic:ss_tramite_productos_clasif b ON (a.num_producto = b.prod_ofrecer)
				INNER JOIN bdisolic:ss_tramite_productos c ON (b.clasificacion = c.clasificacion AND c.prod_actual = pProducto)
				WHERE a.num_producto NOT IN ('7200','7300','7400','7500')
				UNION ALL
				SELECT DISTINCT b.sistema, a.producto, a.nombre
				FROM bdicheq:sc_producto a
				INNER JOIN bdisolic:ss_tramite_productos_clasif b ON (a.producto = b.prod_ofrecer)
				INNER JOIN bdisolic:ss_tramite_productos c ON (b.clasificacion = c.clasificacion AND c.prod_actual = pProducto)
				WHERE a.producto NOT IN ('1200','9900','1600','9901','2200','2300','2500','2600','2700','2800','5000','8000','9999')
				ORDER BY b.sistema

				RETURN cCodRet,cSistema, cNum_producto,cNombre_producto WITH RESUME;
			END FOREACH;
		END IF;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet,'','','';
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_consulta_conv_productos" que tendrÃÂÃÂ¡ como funciÃÂÃÂ³n principal asignar la convivencia con otros productos',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_frecpago(pValor CHAR(2), pTipo_pago VARCHAR(20),pNum_producto CHAR(4),pTipoEjecucion CHAR(1))

RETURNING CHAR(5) AS CodRet,
          CHAR(2) AS Valor,
		  VARCHAR(20) AS TipoPago;
    
DEFINE cCodRet CHAR(5);
DEFINE cValor  CHAR(2);
DEFINE cTipoPago VARCHAR(15);
DEFINE vNum_producto CHAR(4);
DEFINE iSqlErr  INTEGER;

LET cCodRet = '00000';
LET cValor = '';
LET cTipoPago = '';
LET vNum_producto = '';
LET iSqlErr = 0;
    
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cValor,cTipoPago;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/ifxsif01/home/e_efierro/sp_consulta_frecpago.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipoEjecucion = '1' THEN--Consulta Catalogo
			FOREACH
				SELECT valor,tipo_pago
				INTO cValor,cTipoPago
				FROM "informix".sd_cattipopago
			
				RETURN cCodRet, cValor,cTipoPago WITH RESUME;
			END FOREACH;
		
		ELIF pTipoEjecucion = '2' THEN --Guarda los valores seleccionados por el usuario de las frecuencias de pago 
			IF (pValor = '' AND pTipo_pago = '' AND pNum_producto = '') THEN
				LET cCodRet = '00001';
				ELSE
					SELECT COUNT (num_producto) 
					INTO vNum_producto
					FROM tmp_sd_frectipopago;
				
					IF vNum_producto >= 1 THEN
					
						IF vNum_producto <> pNum_producto THEN
							SELECT LIMIT 1 num_producto
							INTO pNum_producto
							FROM tmp_sd_frectipopago;
							--Se eliminan los registros que se crearon para obtener subproducto
							DELETE FROM tmp_sd_frectipopago
							WHERE num_producto = pNum_producto AND valor = 0;
						END IF;
					END IF;
				
					INSERT INTO "informix".tmp_sd_frectipopago(valor, tipo_pago, num_producto)
					VALUES(pValor, pTipo_pago, pNum_producto);
			END IF;
			RETURN cCodRet, TRIM(cValor), TRIM(cTipoPago);
		ELIF pTipoEjecucion = '3' THEN --Elima Opciones seleccionadas 
			DELETE FROM tmp_sd_frectipopago
			WHERE num_producto = pNum_producto AND valor = pValor;
					
			RETURN cCodRet, cValor,cTipoPago;
			
		ELIF pTipoEjecucion = '4' THEN --Consulta los valores asignados por usuario previamente registrados
			SELECT COUNT (num_producto) 
			INTO vNum_producto
			FROM tmp_sd_frectipopago;
			
			IF vNum_producto >= 1 THEN
				SELECT LIMIT 1 num_producto
				INTO pNum_producto
				FROM tmp_sd_frectipopago;
			END IF;
			
			FOREACH
				SELECT valor,tipo_pago
				INTO cValor,cTipoPago
				FROM "informix".sd_frectipopago
				WHERE num_producto = pNum_producto
				ORDER BY valor
			
				RETURN cCodRet, cValor,cTipoPago WITH RESUME;
			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet= '00002';  --No hay informacion
			RETURN cCodRet, TRIM(cValor), TRIM(cTipoPago);
			END IF;
		END IF;
	END
END PROCEDURE;