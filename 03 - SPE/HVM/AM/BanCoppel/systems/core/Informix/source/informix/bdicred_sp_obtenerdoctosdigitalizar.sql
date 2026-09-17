CREATE PROCEDURE "informix".sp_obtenerdoctosdigitalizar(pEmpresa CHAR(3), pNumProducto CHAR(4), pCodigoGrupo CHAR(3),pCodigoDocto CHAR(4),pDescripcion CHAR(50),pTipoEjecucion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER, pNomProducto CHAR(50))	
	RETURNING 	CHAR(5),
				CHAR(40),
				CHAR(50),
				CHAR(4),
				CHAR(4),
				CHAR(50);
                			
	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE isam_err         			INTEGER;
	DEFINE error_info       			VARCHAR(60);
	DEFINE cCodRet           			CHAR(5);
	DEFINE cCodigo    	    			CHAR(4);
	DEFINE cDescripcion        			CHAR(50);
	DEFINE cCodTipcred					CHAR(2);
	DEFINE cCodSistema					CHAR(2);
	DEFINE cCodDefinicion				CHAR(4);
	DEFINE cProdNombre   				CHAR(50);
	DEFINE cCodproducto1				CHAR(4);
	DEFINE cCodproducto2				CHAR(4);
	DEFINE cCodproducto3				CHAR(4);
	DEFINE cCodigoDocto					CHAR(4);
	DEFINE cCodigoGrupo					CHAR(4);
	DEFINE iExiste						INTEGER;
	
	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET isam_err            		= 0;
	LET error_info          		= "";
	LET cCodRet              		= '00000';
	LET cCodigo		           		= '';
	LET cDescripcion           		= '';
	LET cCodTipcred					= '';
	LET cCodSistema					= '';
	LET cCodDefinicion				= '';
	LET cProdNombre					= pNomProducto;
	LET cCodproducto1				= '';
	LET cCodproducto2				= '';
	LET cCodproducto3				= '';
	LET cCodigoDocto				= '';
	LET cCodigoGrupo				= '';	
	LET iExiste						= 0; 	
	
	BEGIN
		ON EXCEPTION SET iSqlErr, isam_err, error_info
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'', '', '','','';
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/tmp/anj/sp_obtenerdoctosdigitalizar.out"; 
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;

		IF pTipoEjecucion = '1' THEN
			--Obtiene los grupos de documentos existentes
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion cod_grupo, descripcion  
				INTO cCodigo, cDescripcion
				FROM bdidigital@coppelimg_tcp:"informix".dg_grupodocto
				WHERE empresa = pEmpresa 
				ORDER BY cod_grupo
				
				RETURN cCodRet, cCodigo, cDescripcion, '','','' WITH RESUME;
			END FOREACH;
		ELIF pTipoEjecucion = '2' THEN
			--Obtiene los tipos de documentos de acuerdo al grupo de documento
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion cod_docto, descripcion 
				INTO cCodigo, cDescripcion
				FROM bdidigital@coppelimg_tcp:"informix".dg_tipodocumento
				WHERE cod_grupo = pCodigoGrupo
				AND empresa = pEmpresa 
				ORDER BY cod_docto
				
				RETURN cCodRet, cCodigo, cDescripcion, '','','' WITH RESUME;
			END FOREACH;
		ELIF pTipoEjecucion = '3' THEN 		
			SELECT cod_definicion, prod_nombre
			INTO cCodDefinicion, cProdNombre
			FROM bdidigital@coppelimg_tcp:dg_definicion
			WHERE empresa = pEmpresa 
			AND cod_sistema = cCodSistema 
			AND cod_producto = pNumProducto;
			
			IF cCodDefinicion <> '' THEN
			
				SELECT cod_tipcred 
				INTO cCodTipcred
				FROM sd_definicion
				WHERE empresa = pEmpresa 
				AND num_producto = pNumProducto;
				
				IF cCodTipcred = '05' THEN
				  LET cCodSistema = 'PP';
				ELSE
				   IF cCodTipcred = '03' THEN
					 LET cCodSistema = 'SD';
				   END IF
				END IF		
				LET cCodproducto1 = CONCAT(SUBSTR(TRIM(pNumProducto),1,2), '01'); 
				LET cCodproducto2 = CONCAT(SUBSTR(TRIM(pNumProducto),1,2), '33');
				
				IF cCodSistema = 'PP' THEN 
					IF pCodigoGrupo IN ('033', '034','816') THEN
						SELECT cod_definicion, prod_nombre
						INTO cCodDefinicion, cProdNombre
						FROM bdidigital@coppelimg_tcp:dg_definicion
						WHERE empresa = pEmpresa 
						AND cod_sistema = cCodSistema 
						AND cod_producto = cCodproducto1;					
					
						SELECT count(*) INTO iExiste 
						FROM "informix".tmp_documentos_digitalizar 
						WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;
						
						IF iExiste = 0 THEN		
							--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
							INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
							VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 				
						END IF;	
					ELIF pCodigoGrupo IN ('002','003','008') THEN
						SELECT cod_definicion, prod_nombre
						INTO cCodDefinicion, cProdNombre
						FROM bdidigital@coppelimg_tcp:dg_definicion
						WHERE empresa = pEmpresa 
						AND cod_sistema = cCodSistema 
						AND cod_producto = cCodproducto2;

				SELECT count(*) INTO iExiste 
						FROM "informix".tmp_documentos_digitalizar 
						WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;
						
						IF iExiste = 0 THEN		
							--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
							INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
							VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 				
						END IF;								
						SELECT cod_definicion, prod_nombre
						INTO cCodDefinicion, cProdNombre
						FROM bdidigital@coppelimg_tcp:dg_definicion
						WHERE empresa = pEmpresa 
						AND cod_sistema = cCodSistema 
						AND cod_producto = pNumProducto;
					
						SELECT count(*) INTO iExiste 
						FROM "informix".tmp_documentos_digitalizar 
						WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;
						
						IF iExiste = 0 THEN		
							--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
							INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
							VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 				
						END IF;								
						

					ELIF pCodigoGrupo = '006' THEN
						SELECT cod_definicion, prod_nombre
						INTO cCodDefinicion, cProdNombre
						FROM bdidigital@coppelimg_tcp:dg_definicion
						WHERE empresa = pEmpresa 
						AND cod_sistema = cCodSistema 
						AND cod_producto = pNumProducto;

					
						SELECT count(*) INTO iExiste 
						FROM "informix".tmp_documentos_digitalizar 
						WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;
						
						IF iExiste = 0 THEN		
							--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
							INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
							VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 				
						END IF;								


					END IF;			
					
				ELIF cCodSistema = 'SD' THEN  	
					IF pNumProducto = '6001' THEN
						IF pCodigoGrupo IN ('002','003','005','008') THEN
							SELECT cod_definicion, prod_nombre
							INTO cCodDefinicion, cProdNombre
							FROM bdidigital@coppelimg_tcp:dg_definicion
							WHERE empresa = pEmpresa 
							AND cod_sistema = cCodSistema 
							AND cod_producto = pNumProducto;
							
							SELECT count(*) INTO iExiste 
							FROM "informix".tmp_documentos_digitalizar 
							WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;							
							IF iExiste = 0 THEN						
								--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
								INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
								VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 						
							END IF;
							
							SELECT cod_definicion, prod_nombre
							INTO cCodDefinicion, cProdNombre
							FROM bdidigital@coppelimg_tcp:dg_definicion
							WHERE empresa = pEmpresa 
							AND cod_sistema = cCodSistema 
							AND cod_producto = '6991';	
							
							SELECT count(*) INTO iExiste 
							FROM "informix".tmp_documentos_digitalizar 
							WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;							
							IF iExiste = 0 THEN						
								--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
								INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
								VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 						
							END IF;						
						ELIF pCodigoGrupo IN ('020','056') THEN
							SELECT cod_definicion, prod_nombre
							INTO cCodDefinicion, cProdNombre
							FROM bdidigital@coppelimg_tcp:dg_definicion
							WHERE empresa = pEmpresa 
							AND cod_sistema = cCodSistema 
							AND cod_producto = '0202';
							SELECT count(*) INTO iExiste 
							FROM "informix".tmp_documentos_digitalizar 
							WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;
							
							IF iExiste = 0 THEN						
								--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
								INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
								VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 						
							END IF;							
						ELIF pCodigoGrupo IN ('006') THEN

							SELECT cod_definicion, prod_nombre
							INTO cCodDefinicion, cProdNombre
							FROM bdidigital@coppelimg_tcp:dg_definicion
							WHERE empresa = pEmpresa 
							AND cod_sistema = cCodSistema 
							AND cod_producto = '6991';


							SELECT count(*) INTO iExiste 
							FROM "informix".tmp_documentos_digitalizar 
							WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;
							
							IF iExiste = 0 THEN						
								--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
								INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
								VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 						
							END IF;												


						END IF;	
					END IF;	
				END IF;
	
			ELSE
				SELECT MAX(cod_definicion)
				INTO cCodDefinicion
				FROM bdidigital@coppelimg_tcp:dg_definicion; 
				
				LET cCodDefinicion = cCodDefinicion::INTEGER + 1;
				
				LET cCodproducto1 = cCodDefinicion::INTEGER + 1;				LET cCodproducto2 = cCodproducto1::INTEGER + 1;
				LET cProdNombre= pNomProducto;

				IF pCodigoGrupo IN ('033', '034','816','020','056') THEN
					SELECT count(*) INTO iExiste 
					FROM "informix".tmp_documentos_digitalizar 
					WHERE cod_definicion = cCodproducto1 AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;

					IF iExiste = 0 THEN		
						--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
						INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
						VALUES(cCodproducto1, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 				
					END IF;								

				ELIF pCodigoGrupo IN ('002','003','005','008') THEN				
					SELECT count(*) INTO iExiste 
					FROM "informix".tmp_documentos_digitalizar 
					WHERE cod_definicion = cCodproducto2 AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;
					
					IF iExiste = 0 THEN		
						--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
						INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
						VALUES(cCodproducto2, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 				
					END IF;												
					SELECT count(*) INTO iExiste 
					FROM "informix".tmp_documentos_digitalizar 
					WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;
					
					IF iExiste = 0 THEN		
						--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
						INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
						VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 				
					END IF;		
				ELIF pCodigoGrupo IN ('006') THEN						
					SELECT count(*) INTO iExiste 
					FROM "informix".tmp_documentos_digitalizar 
					WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;
					
					IF iExiste = 0 THEN		
						--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos seleccionados por el cliente
						INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
						VALUES(cCodDefinicion, cProdNombre, pCodigoGrupo, pCodigoDocto, pDescripcion); 				
					END IF;								
				END IF;			
			END IF;		
			RETURN cCodRet,'Registro Exitoso','','','','';
		ELIF pTipoEjecucion = '4' THEN --Consulta de documentos ya existentes ligados al producto
			SELECT cod_tipcred 
			INTO cCodTipcred
			FROM sd_definicion
			WHERE empresa = pEmpresa 
			AND num_producto = pNumProducto;
			
			IF cCodTipcred = '05' THEN
			  LET cCodSistema = 'PP';
			ELSE
			   IF cCodTipcred = '03' THEN
				 LET cCodSistema = 'SD';
			   END IF;
			END IF;
			IF pNumProducto = '8500' THEN --Producto 8500
				LET cCodproducto1 = '8501';
				LET cCodproducto2 = '8502';
				LET cCodproducto3 = '8503';
			ELIF pNumProducto = '6001' THEN --Producto 6001
				LET cCodproducto1 = '0202';
				LET cCodproducto2 = '6991';
				LET cCodproducto3 = '0410';
			ELIF pNumProducto = '6600' THEN --Producto 6600
				LET cCodproducto1 = '0410';
			ELSE
				LET cCodproducto1 = CONCAT(SUBSTR(TRIM(pNumProducto),1,2), '01'); 
				LET cCodproducto2 = CONCAT(SUBSTR(TRIM(pNumProducto),1,2), '33');
			END IF;

			SELECT count(*) INTO iExiste 
			FROM "informix".tmp_documentos_digitalizar 
			WHERE cod_definicion = cCodDefinicion AND cod_grupo = pCodigoGrupo AND cod_docto = pCodigoDocto;

			IF iExiste = 0 THEN
				FOREACH
					SELECT b.cod_definicion, b.prod_nombre, c.cod_grupo, c.cod_docto, c.descripcion 
					INTO cCodDefinicion, cProdNombre, cCodigoGrupo, cCodigoDocto, cDescripcion
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a 
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_sistema = cCodSistema AND b.cod_producto = pNumProducto
					UNION ALL
					SELECT b.cod_definicion, b.prod_nombre, c.cod_grupo, c.cod_docto, c.descripcion 
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a 
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_sistema = cCodSistema AND b.cod_producto = cCodproducto1
					UNION ALL
					SELECT b.cod_definicion, b.prod_nombre, c.cod_grupo, c.cod_docto, c.descripcion 
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a 
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_sistema = cCodSistema AND b.cod_producto = cCodproducto2 
					UNION ALL
					SELECT b.cod_definicion, b.prod_nombre, c.cod_grupo, c.cod_docto, c.descripcion 
					FROM bdidigital@coppelimg_tcp:dg_definicion_det a 
					INNER JOIN bdidigital@coppelimg_tcp:dg_definicion b ON (a.cod_definicion = b.cod_definicion)
					INNER JOIN bdidigital@coppelimg_tcp:dg_tipodocumento c ON (a.cod_docto = c.cod_docto)
					WHERE b.empresa = pEmpresa AND b.cod_sistema = cCodSistema AND b.cod_producto = cCodproducto3
					
					--Realiza la insercion a la tabla tmp_documentos_digitalizar de los documentos actuales del producto
					INSERT INTO "informix".tmp_documentos_digitalizar(cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion )
					VALUES(cCodDefinicion, cProdNombre, cCodigoGrupo, cCodigoDocto, cDescripcion); 		
				END FOREACH;
			END IF;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
				LET cDescripcion = 'No existe información de digitalizacion para el producto consultado';
				RETURN cCodRet,'','','','','';
			END IF;
			
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion cod_definicion, prod_nombre, cod_grupo, cod_docto, descripcion 
				INTO cCodDefinicion, cProdNombre, cCodigoGrupo, cCodigoDocto, cDescripcion
				FROM "informix".tmp_documentos_digitalizar  
				
				RETURN cCodRet, cCodDefinicion, cProdNombre, cCodigoGrupo, cCodigoDocto,cDescripcion WITH RESUME;
						
			END FOREACH;
			
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			LET cDescripcion = 'No existe información para el producto consultado';
			RETURN cCodRet,'','','','','';
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_obtenerdoctosdigitalizar" para los obtener los documentos a digitalizar seleccionados por el cliente',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_bloqueocuentacrd (
																pEmpresa 	CHAR(3), 
																pNumCuenta 	CHAR(20), 
																cCveBloqueo	INTEGER,
																pCveCausa 	CHAR(2), 
																pEjecutivo 	CHAR(8),
																pTipo		INTEGER
															  )
--EXECUTE PROCEDURE sp_bloqueocuentacrd('001','630090932298',3,'09','informix',1);
RETURNING
	CHAR(6) AS CODIGO,
	CHAR(80) AS MENSAJECOD;
    
--Definicion de variables
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);
DEFINE vFecha        DATE;
DEFINE vCveExistente INTEGER;
DEFINE vCodSP        CHAR(6);
DEFINE vStatusCred   CHAR(2);
DEFINE pClaveBloqueo INTEGER;
DEFINE iCveAnte      INTEGER;
DEFINE cCausa        CHAR(2);

--Set debug file to '/home/sysifx/has/sp_bloqueocuenta.out';
--trace on;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  LET cMensajeRet= cErrorInfo;
		  RETURN 
			   cCodRet,
			   cMensajeRet;  
	   END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
--Inicializar Variables--
LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = '';
LET cCodRet        = '000000';
LET cMensajeRet    = '';

LET vFecha         = date(1);
LET vCveExistente  = 0;
LET vCodSP         = '';
LET vStatusCred    = '';
LET pClaveBloqueo  = 0;
LET iCveAnte       = 0;
LET cCausa		   = '';
        

	IF pEmpresa IS NULL OR pNumCuenta IS NULL OR cCveBloqueo IS NULL OR pCveCausa IS NULL OR pEjecutivo IS NULL OR pTipo IS NULL THEN
		LET cCodRet = '000001';    --Faltan Valores
		LET cMensajeRet = 'Faltan valores para ejecutar el procedimiento.'; 
	ELSE
		IF NOT EXISTS( SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'La empresa no vÃ¡lida';
		ELSE
			IF NOT EXISTS(SELECT clave FROM bdicred:"informix".sd_bloqueoscuenta WHERE clave = cCveBloqueo) THEN
				LET cCodRet = '000003';
				LET cMensajeRet = 'La clave del bloqueo no es vÃ¡lida';
			ELSE
				IF NOT EXISTS(SELECT cod_causa FROM bdicred:"informix".sd_causa_bloqueo WHERE empresa = pEmpresa and cod_causa = pCveCausa) THEN
					LET cCodRet = '000004';
					LET cMensajeRet = 'La clave de la causa del bloqueo no es vÃ¡lida';
				ELSE
					IF NOT EXISTS(SELECT ejecutivo FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo) THEN
						LET cCodRet = '000005';
						LET cMensajeRet = 'La clave de la causa del bloqueo no es vÃ¡lida';
					ELSE
						IF pTipo NOT IN (1,2) THEN
							LET cCodRet = '000006';
							LET cMensajeRet = 'El tipo de bloqueo no es vÃ¡lido';
						ELSE
							EXECUTE PROCEDURE bdicred:"informix".sp_validacreditocrd (pEmpresa, pNumCuenta) 
							INTO vCodSP;
							IF vCodSP::INTEGER <> 0 THEN
								LET cCodRet = '000007';    --No existe el credito en la base de datos
								LET cMensajeRet = 'La cuenta ' || pNumCuenta || ' no existe.'; 
							ELSE    
								SELECT /*NVL(id_unidad_prod, 0),*/ status_Cred--, cod_caract_2
								  INTO /*vCveExistente,*/ vStatusCred--, cCausa
								  FROM "informix".sd_maecredcrd
								 WHERE empresa = pEmpresa 
								   AND num_credito = pNumCuenta;
								
								IF /*vCveExistente = 0 AND*/ vStatusCred IS NULL THEN
									LET cCodRet = '000008';
									LET cMensajeRet = 'CrÃ©dito bloqueado manualmente favor de verificar'; 
								ELSE
									/*IF vCveExistente > 0 AND cCausa IS NOT NULL THEN
									   LET cCodRet = '000009';
									   LET cMensajeRet = 'El crÃ©dito ya se encuentra bloqueado';  
									ELSE  */               
										--IF vCveExistente >= 0 THEN
											IF vStatusCred='FC' THEN
												LET cCodRet = '000012';
												LET cMensajeRet = 'La cuenta ' || pNumCuenta || ' estÃ¡ cancelada.';
											ELIF vStatusCred ='CV' THEN
												LET cCodRet = '000010';
												LET cMensajeRet = 'La cuenta ' || pNumCuenta || ' estÃ¡ en cartera vendida.'; 
											ELSE
												SELECT fecha_hoy
												INTO vFecha
												FROM bdicred:"informix".sd_fechas
												WHERE empresa = pEmpresa;

												INSERT INTO bdicred:"informix".sd_bitacorabloqueocta 
												(cuenta, cve_bloqueo,cve_causa,cve_bloqueAnterior,cve_causa_anterior, ejecutivo, fecha, tipo_bloqueo, tipo_movimiento)
												VALUES (pNumCuenta, cCveBloqueo,pCveCausa, NULL, NULL, pEjecutivo, vFecha, pTipo, 'B');
/*
												UPDATE bdicred:"informix".sd_maecredcrd
												SET id_unidad_prod = cCveBloqueo, Cod_caract_2 = pCveCausa
												WHERE empresa = pEmpresa
												AND num_credito = pNumCuenta;
*/												
												LET cMensajeRet = 'La cuenta ' ||  Trim(pNumCuenta) || ' se ha bloqueado.';
												
												/*IF vCveExistente > 0 THEN
												   LET cCodRet = '000011';  --El bloque se actualizo
												   LET cMensajeRet = 'Se actualizÃ³ el bloqueo de la cuenta ' || pNumCuenta; 
												END IF;*/
											END IF;
										--END IF;
									--END IF;
								END IF;
							END IF;
						END IF
					END IF
				END IF
			END IF
		END IF
	END IF;
        
	RETURN cCodRet,cMensajeRet;  
        
END;
    
END PROCEDURE

DOCUMENT
'Autor: Abraham Ayala Aguilar',
'Descripcion: Bloquea una cuenta e inserta un registro en la tabla sd_bitacorabloqueocta. Bloqueo Cuentas',
'Fecha: 08/01/2009',
'Cambio: se quito la restriccion de cuando ya estaba bloqueada la cuenta y se actualiza  cCveBloqueo   pClaveBloqueo',
'Modifico: Roque Enrique Solis ',
'Cambio: Se cambio el parametro clave del parametro por la descripcion del parametro',
		'Se agrego el parametro del bloqueo anterior para que se inserte el la bitacora',
		'Se agrego el campo para conocer la causa del bloque',
'Modifico: Roque Enrique Solis',
'Cambio: Se agrega de tipo bloqueo (manual o masivo), ademÃ¡s se cambias las clave del bloqueo por su descripcion',
		'tipo_bloqueo  1 = Manual, 2 = Masivo',
'Modifico: Mohamed CarreÃ³n, Abigail Vasavilbazo CaÃ±edo',
'Version: 20120104.1048';

CREATE PROCEDURE "informix".sp_consctedetallecredito(pEmpresa CHAR(3), pNumCte CHAR(20), pNumCredito CHAR(20), pNumTarjeta CHAR(20)) 
RETURNING CHAR(6) 	    AS CodRet,
		  CHAR(150)     AS NomCteTitular,
		  DATE 		    AS FechaNAC,
		  CHAR(13) 	    AS RFC,
		  CHAR(20) 	    AS NumCte,
		  CHAR(20) 	    AS NumCredito, 
		  CHAR(20) 	    AS NumTarjeta,
		  CHAR(40) 	    AS NombreProducto,
		  DATE 		    AS FechaApertura,
		  CHAR(4)       AS CodigoEstatus, --Se agrega variable para retornar codigo de status
		  CHAR(60) 	    AS Estatus, 
		  DATE 		    AS FechaUltMovimiento,
		  DECIMAL(18,2) AS SaldoActual,
		  DECIMAL(18,2) AS SaldoRetenido; --Se agrega variable para retornar saldo retenido
		  
-- DEFINICION DE VARIABLES DEL PROCEDIMIENTO SP_CONSCTEDETALLECREDITO.
DEFINE cCodRet				CHAR(6);
DEFINE dFechaNAC			DATE;
DEFINE cRfc					CHAR(13);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE cStatusCred          CHAR(4);

-- DEFINICION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
DEFINE cCodRetCSG			CHAR(6);
DEFINE cMsjRetCSG			CHAR(80);
DEFINE cNumCreditoCSG		CHAR(20);
DEFINE cCodTCredCSG			CHAR(2);
DEFINE dFechaOrigCSG		DATE;
DEFINE dFechaProxPagCSG 	DATE;
DEFINE dcPagoMinCSG			DECIMAL(18,2);
DEFINE dFechaUltPagCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagRealizadosCSG	INTEGER;
DEFINE dcLinOtorgadaCSG		DECIMAL(18,2);
DEFINE dcTasaInteresCSG		DECIMAL(9,6);
DEFINE dcTasaMoratoriosCSG 	DECIMAL(9,6);
DEFINE dcMontoSbsCSG		DECIMAL(14,2);
DEFINE dcCapVigCSG			DECIMAL(18,2);
DEFINE dcCapTransCSG		DECIMAL(18,2);
DEFINE dcCapVdoExigCSG		DECIMAL(18,2);
DEFINE dcCapVdoNoExigCSG	DECIMAL(18,2);
DEFINE dcSdoActTotCapCSG	DECIMAL(18,2);
DEFINE dcIntVigCSG			DECIMAL(18,2);
DEFINE dcIntVdoCSG			DECIMAL(18,2);
DEFINE dcIntMoratorioCSG	DECIMAL(18,2);
DEFINE dcIntMesCSG			DECIMAL(18,2);
DEFINE dcSodActTotIntCSG	DECIMAL(18,2);
DEFINE dcIvaIntVigCSG		DECIMAL(18,2);
DEFINE dcIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dcIvaIntMorCSG		DECIMAL(18,2);
DEFINE dcIvaIntMesCSG		DECIMAL(18,2);
DEFINE dcSdoActTotIvaCSG	DECIMAL(18,2);
DEFINE dcComPendCSG			DECIMAL(18,2);
DEFINE dcIvaComCSG			DECIMAL(18,2);
DEFINE dcSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dcTotalLiqCSG		DECIMAL(18,2);
DEFINE dcIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcLinDispCSG			DECIMAL(18,2);
DEFINE dcPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqCtaCSG			CHAR(60);
DEFINE cIdCausaBloqCredCSG	CHAR(3);
DEFINE cCausaBloqCtaCSG		CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG 		CHAR(75);

-- DECLARACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO SP_CONSULTACREDITOSCANCELAR
DEFINE cCodRetCCC			CHAR(6);
DEFINE cMsjRetCCC			CHAR(80);
DEFINE cNumCreditoCCC 		CHAR(20);
DEFINE cNumCteCCC 			CHAR(20);
DEFINE cNombreProductoCCC	CHAR(40);
DEFINE cNumTarjetaCCC 		CHAR(20);
DEFINE cNombreClienteCCC 	CHAR(150);

-- VARIABLES DE RETORNO DEL SP_DESC_RET
DEFINE vCodRet 	 		 	VARCHAR(5);
DEFINE vMsjRetorno 		 	VARCHAR(100);

-- INICIALIZACION DE VARIABLES DEL PROCEDIMIENTO SP_CONSCTEDETALLECREDITO.
LET cCodRet					= '00000';
LET dFechaNAC				= DATE(1);
LET cRfc					= '';
LET iSqlErr              	= 0;
LET iIsamErr             	= 0;
LET cErrorInfo           	= '';
LET cStatusCred             = '';

-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
LET cCodRetCSG				= '000000';
LET cMsjRetCSG				= '';
LET cNumCreditoCSG			= '';
LET cCodTCredCSG			= '';
LET dFechaOrigCSG			= DATE(1);
LET dFechaProxPagCSG 		= DATE(1);
LET dcPagoMinCSG			= 0.00;
LET dFechaUltPagCSG			= DATE(1);
LET iPlazoCSG				= 0;
LET iPagRealizadosCSG		= 0;
LET dcLinOtorgadaCSG		= 0.00;
LET dcTasaInteresCSG		= 0.00;
LET dcTasaMoratoriosCSG 	= 0.00;
LET dcMontoSbsCSG			= 0.00;
LET dcCapVigCSG				= 0.00;
LET dcCapTransCSG			= 0.00;
LET dcCapVdoExigCSG			= 0.00;
LET dcCapVdoNoExigCSG		= 0.00;
LET dcSdoActTotCapCSG		= 0.00;
LET dcIntVigCSG				= 0.00;
LET dcIntVdoCSG				= 0.00;
LET dcIntMoratorioCSG		= 0.00;
LET dcIntMesCSG				= 0.00;
LET dcSodActTotIntCSG		= 0.00;
LET dcIvaIntVigCSG			= 0.00;
LET dcIvaIntVdoCSG			= 0.00;
LET dcIvaIntMorCSG			= 0.00;
LET dcIvaIntMesCSG			= 0.00;
LET dcSdoActTotIvaCSG		= 0.00;
LET dcComPendCSG			= 0.00;
LET dcIvaComCSG				= 0.00;
LET dcSdoRetenidoCSG		= 0.00;
LET dcTotalLiqCSG			= 0.00;
LET dcIntDevengadoCSG		= 0.00;
LET dcIvaIntDevengadoCSG	= 0.00;
LET dcLinDispCSG			= 0.00;
LET dcPagosVdosCSG			= 0.00;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqCtaCSG				= '';
LET cIdCausaBloqCredCSG		= '';
LET cCausaBloqCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0;
LET cSitEspCredCSG 			= '';

-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTACREDITOSCANCELAR
LET cCodRetCCC				= '000000';
LET cMsjRetCCC				= '';
LET cNumCreditoCCC 			= '';
LET cNumCteCCC 				= '';
LET cNombreProductoCCC		= '';
LET cNumTarjetaCCC 			= '';
LET cNombreClienteCCC 		= '';

-- INICIALIZACION DE VARIABLES DEL PROCEDIMIENTO SP_DESC_RET
LET vCodRet 	 			= '00000';
LET vMsjRetorno  			= '';

-- SET DEBUG FILE TO '/home/sysifx/vlv/sp_consctedetallecredito.out';
-- TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cNombreClienteCCC = cErrorInfo;
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDAMOS LOS PARAMETROS DE ENTRADA.
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' AND NVL(pNumCredito,'') = '' AND NVL(pNumTarjeta,'') = '' THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','590')
			INTO vCodRet, vMsjRetorno;
			
			LET cCodRet = '00001';
			LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
			RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
				   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
				   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
		END IF
		
		IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pNumCredito,'') <> '' AND NVL(pNumTarjeta,'') <> '' THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','591')
			INTO vCodRet, vMsjRetorno;
			
			LET cCodRet = '00001';
			LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
			RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
				   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
				   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
		END IF
		
		-- CONSULTAMOS SI EXISTE EL VALOR QUE SE DESEA CONSULTAR.
		IF TRIM(NVL(pNumCte,'')) <> '' THEN
			-- VALIDAMOS SI EXISTE EL CLIENTE
			IF NOT EXISTS( SELECT rfc FROM bdinteg:"informix".si_cliente WHERE numcte = TRIM(pNumCte) ) THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','592')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet = '00002';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
			
		ELIF TRIM(NVL(pNumCredito,'')) <> '' THEN
			-- VALIDAMOS SI EXISTE EL CREDITO.
			IF NOT EXISTS (SELECT num_credito, b.cod_prod FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_tipprod b 
						   WHERE a.num_credito = TRIM(pNumCredito) AND a.empresa = TRIM(pEmpresa) AND a.empresa = b.empresa  AND a.num_producto = b.abrevia_prod ) THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','593')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet = '00003';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
		ELIF TRIM(NVL(pNumTarjeta,'')) <> '' THEN
			-- VALIDAMOS SI EXISTE LA TARJETA.
			IF NOT EXISTS (SELECT num_credito FROM bdicred:"informix".sd_tarjeta WHERE empresa = TRIM(pEmpresa) AND num_tarjeta = TRIM(pNumTarjeta) ) THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','594')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet = '00004';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
		END IF
		
		-- CONSULTAMOS LOS DATOS GENERALES DEL CLIENTE.
		FOREACH 
			EXECUTE PROCEDURE bdicred:"informix".sp_consultaCreditosCancelar(TRIM(pEmpresa), TRIM(pNumCte), TRIM(pNumCredito), TRIM(pNumTarjeta))
			INTO cCodRetCCC, cMsjRetCCC, cNumCreditoCCC, cNumCteCCC, cNombreProductoCCC, cNumTarjetaCCC, cNombreClienteCCC , cStatusCred
			
			IF cCodRetCCC = '000001' THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','590') -- DEBE ENVIAR AL MENOS UN PARAMETRO OBLIGATORIO
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet  = '00005';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			ELIF cCodRetCCC = '000005' THEN 
				LET cCodRet  = '00011'; -- CLIENTE NO TIENE CREDITOS POR CANCELAR.
			ELIF cCodRetCCC = '000007' THEN 
				LET cCodRet  = '00013'; -- CREDITO NO PUEDE SER CANCELADO.
			ELIF cCodRetCCC = '000008' THEN 
				LET cCodRet  = '00014'; -- TARJETA NO PUEDE SER CANCELADA.
			ELIF cCodRetCCC = '000006' THEN 
				LET cCodRet  = '00012'; -- NO SE PUEDE CANCELAR CREDITO CON TARJETA ADICIONAL.
				
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			ELIF cCodRetCCC::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:"informix".SP_CONSULTACREDITOSCANCELAR
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','596')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet  = '00007';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
			
			 
				-- CONSULTAMOS EL SALDO GENERAL DEL CREDITO.
				EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(TRIM(pEmpresa), TRIM(cNumCreditoCCC))
				INTO cCodRetCSG, cMsjRetCSG, cNumCreditoCSG, cCodTCredCSG, dFechaOrigCSG, dFechaProxPagCSG, dcPagoMinCSG, dFechaUltPagCSG, iPlazoCSG, iPagRealizadosCSG, dcLinOtorgadaCSG, dcTasaInteresCSG, dcTasaMoratoriosCSG, dcMontoSbsCSG, 
					 dcCapVigCSG, dcCapTransCSG, dcCapVdoExigCSG, dcCapVdoNoExigCSG, dcSdoActTotCapCSG, dcIntVigCSG, dcIntVdoCSG, dcIntMoratorioCSG, dcIntMesCSG, dcSodActTotIntCSG, dcIvaIntVigCSG, dcIvaIntVdoCSG, dcIvaIntMorCSG, dcIvaIntMesCSG,
					 dcSdoActTotIvaCSG, dcComPendCSG, dcIvaComCSG, dcSdoRetenidoCSG, dcTotalLiqCSG, dcIntDevengadoCSG, dcIvaIntDevengadoCSG, dcLinDispCSG, dcPagosVdosCSG, cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqCtaCSG, cIdCausaBloqCredCSG, 
					 cCausaBloqCtaCSG, cIdSitEspCteCSG, iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;
				
				IF cCodRetCSG = '000005' THEN -- OCURRIÓ UN ERROR AL REALIZAR CALCULO
					EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','597')
					INTO vCodRet, vMsjRetorno;
					
					LET cCodRet  = '00008';
					LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
					RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
						   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
						   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
				ELIF cCodRetCSG = '000006' THEN -- NO SE ENCONTRÓ EL FACTOR DE LA COMISIÓN
					EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','598')
					INTO vCodRet, vMsjRetorno;
					
					LET cCodRet  = '00009';
					LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
					RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
						   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
						   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
				ELIF cCodRetCSG::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:"informix".SP_CONSULTA_SALDOS_GENERAL
					EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','599')
					INTO vCodRet, vMsjRetorno;
					
					LET cCodRet  = '00010';
					LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
					RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
						   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
						   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
				END IF
				
				-- VALIDAMOS SI EXISTE EL CLIENTE Y CONSULTAMOS EL RFC DEL CLIENTE.
				SELECT rfc INTO cRfc FROM bdinteg:"informix".si_cliente WHERE numcte = TRIM(cNumCteCCC);
				
				-- CONSULTAMOS LA FECHA DE NACIMIENTO DEL CLIENTE.
				SELECT Fecha_NAC INTO dFechaNAC FROM bdinteg:"informix".si_ctepf WHERE numcte = TRIM(cNumCteCCC);
				
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00) WITH RESUME;
				
		END FOREACH
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para consultar el detalle del credito',
'AUTOR: Valentin Lopez',
'FECHA DE CREACION: 12 de Octubre del 2012',
'VERSION: 20121012.1504',
'BD: bdicred',
'MODIFICÓ: Carlos Ochoa Valenzuela',
'DESCRIPCIÓN: Se declara e incluye una variable para Saldo Retenido y para obtener el codigo de descripcion e incluirlo dentro de los return.', 
'FECHA DE MODIFICACIÓN: 10 de Diciembre del 2012',
'VERSION: 20121210.1814',
'BD: BDICRED';

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