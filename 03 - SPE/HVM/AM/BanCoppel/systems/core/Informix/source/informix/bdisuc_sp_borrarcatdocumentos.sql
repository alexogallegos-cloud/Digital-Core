CREATE PROCEDURE "informix".sp_borrarcatdocumentos(p_sempresa CHAR(3), p_iTipoDocumento SMALLINT)

	RETURNING CHAR(6) AS retorno;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);

	-----------------------------------------------------------------------
	--SET DEBUG FILE TO "/tmp/vladi/sp_BorrarCatDocumentos.out";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno = '000001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_iTipoDocumento,'') = '' THEN
			RETURN v_sValRetorno;
		END IF;

		LET v_sValRetorno = '000000';

		--Elimina el Documento Especificado.
		IF EXISTS (SELECT 1 FROM bdisuc:ss_catdocumentos WHERE empresa = p_sEmpresa
			AND cvedocumento = p_iTipoDocumento) THEN

			DELETE FROM bdisuc:ss_catdocumentos
			WHERE empresa = p_sEmpresa
			AND cvedocumento = p_iTipoDocumento;
		ELSE

			LET v_sValRetorno = '000002';
		END IF;
		RETURN v_sValRetorno;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Vladimir Félix Gálvez',
'FECHA: 05-Agosto-2009',
'CASO DE  USO: PCU-bdisuc\CU-0014-BorrarCatDocumentos-SPL',
'DESCRIPCION: Elimina los documentos especificados de las sucursales.';

CREATE PROCEDURE "informix".sp_borrarcattipocarpeta(p_sEmpresa CHAR(3), p_iTipoCarpeta SMALLINT)
	RETURNING 	CHAR(6) AS retorno;
	
	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_dFechaInsercion				DATE;
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_borrarCatTipoCarpeta.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	LET v_sValRetorno = '000001';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_iTipoCarpeta,'')='' THEN
			RETURN v_sValRetorno;
		END IF;
		
		--SI EXISTE BORRA EL REGISTRO, SI NO EXISTE MANDA UN ERROR
		IF EXISTS (SELECT 1 FROM bdisuc:ss_cattipocarpeta WHERE empresa = p_sEmpresa AND tipocarpeta = p_iTipoCarpeta) THEN

			DELETE FROM bdisuc:ss_cattipocarpeta WHERE empresa = p_sEmpresa AND tipocarpeta = p_iTipoCarpeta;
			
			LET v_sValRetorno = '000000';
		ELSE
			LET v_sValRetorno = '000002';
		END IF;
		RETURN v_sValRetorno;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Erick Zamora',
'FECHA: 05/Agosto/2009',
'DESCRIPCION: Borra un tipo de carpeta del catalogo de tipos de carpeta',
'CASO DE USO: PCU-bdisuc\CU-0014-BorrarCatTipoCarpeta-SPL';

CREATE PROCEDURE "informix".sp_consultarcatcardcarriers(p_sEmpresa CHAR(3), p_sTipoImagen CHAR(1))
	RETURNING	CHAR(6) AS retorno, 
				CHAR(3) AS empresa, 
				CHAR(1) AS tipoimagen,
				CHAR(80) AS descripcion,
				DATE AS fecha_insert;
	
	DEFINE iSqlErr					INTEGER;
	DEFINE v_sValRetorno			CHAR(6);
	DEFINE v_sEmpresa				CHAR(3);
	DEFINE v_sTipoImagen			CHAR(1);
	DEFINE v_sDescripcion			CHAR(80);
	DEFINE v_dFechaInsercion		DATE;
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarCatCardCarriers.out";
	--TRACE ON;
	-----------------------------------------------------------------------------	
	LET v_sValRetorno = '000001';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','';
			END IF;
		END EXCEPTION;
		
		--LA EMPRESA NO DEBE TENER UN VALOR NULO
		IF NVL(p_sEmpresa,'')='' THEN
			RETURN v_sValRetorno,'','','','';
		END IF;
		
		IF p_sTipoImagen = '' THEN
			LET p_sTipoImagen = NULL;
		END IF;
		
		--OBTIENE EL CATALOGO DE CARDCARRIERS DE UN TIPO DE IMAGEN
		FOREACH
			SELECT empresa, tipoimagen, descripcion, fecha_insert
			INTO v_sEmpresa, v_sTipoImagen, v_sDescripcion, v_dFechaInsercion
			FROM bdisuc:ss_catcardcarriers
			WHERE empresa = p_sEmpresa AND tipoimagen = NVL(p_sTipoImagen, tipoimagen)
				
			LET v_sValRetorno = '000000';
			RETURN v_sValRetorno, v_sEmpresa, v_sTipoImagen, v_sDescripcion, v_dFechaInsercion WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Erick Zamora',
'FECHA: 04/Agosto/2009',
'DESCRIPCION: Consulta el catalogo de cardCarriers del tipo de imagen especificado',
'CASO DE USO: PCU-bdisuc\CU-0008-ConsultarCatCardCarriers-SPL.';

CREATE PROCEDURE "informix".sp_consultarcatstatusdoc(p_sEmpresa CHAR(3), p_iCveEstatus CHAR(1), p_iCantRegistros INTEGER)
	RETURNING	CHAR(6)  AS retorno, 
				CHAR(3)  AS empresa, 
				CHAR(1)  AS cveestatus,
				CHAR(80) AS descripcion,				
				DATE     AS fecha_insert;
	
	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_sEmpresa						CHAR(3);
	DEFINE v_sEstatus						CHAR(1);
	DEFINE v_sDescripcion					CHAR(80);	
	DEFINE v_dFechaInsercion				DATE;	
	
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarcatstatusdoc.out";
	--TRACE ON;
	-----------------------------------------------------------------------------	
	
	LET v_sValRetorno = '000001';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','';
			END IF;
		END EXCEPTION;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_iCantRegistros,'')='' THEN
			RETURN v_sValRetorno,'','','','';
		END IF;
		
		IF p_iCveEstatus = '' THEN
			LET p_iCveEstatus = NULL;
		END IF;
		
		--OBTIENE EL CATALOGO DE DOCUMENTOS
		FOREACH
			SELECT SKIP p_iCantRegistros empresa, estatus, descripcion, fecha_insert
			INTO v_sEmpresa, v_sEstatus, v_sDescripcion, v_dFechaInsercion
			FROM bdisuc:ss_catstatusdoc
			WHERE empresa = p_sEmpresa AND estatus = NVL(p_iCveEstatus, estatus)
			ORDER BY descripcion DESC
									
			LET v_sValRetorno = '000000';
			
			RETURN v_sValRetorno, v_sEmpresa, v_sEstatus, v_sDescripcion, v_dFechaInsercion WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Fabiola Corrales',
'FECHA:       15/Oct/2009',
'DESCRIPCION: Consulta el catalogo de estatus de documentos',
'CASO DE USO: Caso de uso asociado PCU-bdisuc\CU-0020-ConsultarCatStatusDoc-SPL';

CREATE PROCEDURE "informix".sp_grabarcattipocarpeta(p_sEmpresa CHAR(3), p_iTipoCarpeta SMALLINT, p_sDescripcion CHAR(80))
	RETURNING 	CHAR(6) AS retorno;
	
	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_iTipoCarpeta					SMALLINT;
	DEFINE v_dFechaInsercion				DATE;
	
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_grabarCatTipoCarpeta.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	LET v_sValRetorno = '000001';
	LET v_dFechaInsercion = CURRENT::DATE;
	LET v_iTipoCarpeta = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' AND NVL(p_sDescripcion,'')='' THEN
			RETURN v_sValRetorno;
		END IF;
		
		--SI EL TIPO DE CARPETA ES NULO, SE BUSCA EL NUMERO CONSECUTIVO SIGUIENTE
		IF NVL(p_iTipoCarpeta,'') = '' THEN
			--OBTIENE EL SIGUIENTE NUMERO CONSECUTIVO
			SELECT NVL(MAX(tipocarpeta),0) INTO v_iTipoCarpeta FROM bdisuc:ss_cattipocarpeta;
			LET v_iTipoCarpeta = v_iTipoCarpeta + 1;
			
			--GUARDA UN TIPO NUEVO TIPO DE CARPETA
			INSERT INTO bdisuc:ss_cattipocarpeta (empresa, tipocarpeta, descripcion, fecha_insert)
			VALUES (p_sEmpresa, v_iTipoCarpeta, p_sDescripcion, v_dFechaInsercion);
			LET v_sValRetorno = '000000';	
		ELSE
			LET v_iTipoCarpeta = p_iTipoCarpeta;
			--SI NO EXISTE GUARDA, SI EXISTE ACTUALIZA
			IF NOT EXISTS (SELECT 1 FROM bdisuc:ss_cattipocarpeta WHERE empresa = p_sEmpresa AND tipocarpeta = v_iTipoCarpeta) THEN
			
				INSERT INTO bdisuc:ss_cattipocarpeta (empresa, tipocarpeta, descripcion, fecha_insert)
				VALUES (p_sEmpresa, v_iTipoCarpeta, p_sDescripcion, v_dFechaInsercion);
			
				LET v_sValRetorno = '000000';
			ELSE
				UPDATE bdisuc:ss_cattipocarpeta 
				SET    descripcion = p_sDescripcion
				WHERE  empresa = p_sEmpresa
				AND    tipocarpeta = v_iTipoCarpeta;
				
				LET v_sValRetorno = '000000';
			END IF;
		END IF
		RETURN v_sValRetorno;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Erick Zamora', 
'FECHA: 05/Agosto/2009',
'DESCRIPCION: Graba un nuevo tipo de carpeta en el catalogo de tipos de carpeta',
'CASO DE USO: PCU-bdisuc\CU-0015-GrabarCatTipoCarpeta-SPL';

CREATE PROCEDURE "informix".sp_consultarcatsucursales(p_sEmpresa CHAR(3), p_sSucursal CHAR(4))
	RETURNING 	CHAR(6) AS retorno,
				CHAR(3) AS empresa, 
				CHAR(4) AS sucursal, 
				CHAR(40) AS nombre, 
				CHAR(40) AS direccion1, 
				CHAR(40) AS direccion2, 
				CHAR(14) AS telefono,
				CHAR(40) AS gerente, 
				CHAR(40) AS subgerente, 
				CHAR(2) AS tpo_sucursal;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(6);
	DEFINE v_sEmpresa 		CHAR(3);
	DEFINE v_sSucursal		CHAR(4);
	DEFINE v_sNombre		CHAR(40);
	DEFINE v_sDireccion1	CHAR(40);
	DEFINE v_sDireccion2	CHAR(40);
	DEFINE v_sTelefono1		CHAR(14);
	DEFINE v_sGerente		CHAR(40);
	DEFINE v_sSubgerente	CHAR(40);	
	DEFINE v_sTipo_sucursal	CHAR(2);

	------------------------------------------------------------------------------------------
	--Creado por Erick Zamora 03/Agosto/2009
	--Obtiene los datos de la sucursal especificada, o de todas las sucursales del catalogo
	--Caso de uso asociado: PCU-bdinteg\CU-0103-ConsultarCatSucursales-SPL
	--SET DEBUG FILE TO "/tmp/sp_consultarCatSucursales.out"; 
	--TRACE ON;
	------------------------------------------------------------------------------------------
	LET v_sValRetorno = '000001';
		
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','';
			END IF;
		END EXCEPTION;

		--DEBE PROPORCIONARSE LA EMPRESA
		IF NVL(p_sEmpresa,'') = '' THEN
			RETURN v_sValRetorno,'','','','','','','','','';
		END IF;
		
		IF p_sSucursal = '' THEN
			LET p_sSucursal = NULL;
		END IF;
		
		FOREACH
			SELECT empresa, sucursal, nombre, direccion1, direccion2, telefono1, gerente, subger, tpo_sucursal
			INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
			FROM bdinteg:si_sucursales
			WHERE empresa = p_sEmpresa AND sucursal = NVL(p_sSucursal, sucursal)
			
			LET v_sValRetorno = '000000';
			
			RETURN v_sValRetorno, v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE;