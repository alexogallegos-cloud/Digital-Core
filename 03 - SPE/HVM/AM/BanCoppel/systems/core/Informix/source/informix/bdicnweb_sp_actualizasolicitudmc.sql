CREATE PROCEDURE "informix".sp_actualizasolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pSucursal CHAR(4), pTipoOperacion SMALLINT)
	RETURNING CHAR(5) AS codret,
			CHAR(45) AS nombre_atiende;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNombreEjecutivo CHAR(45);
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cNombreEjecutivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreEjecutivo;
		END EXCEPTION;
	
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_actualizasolicitudmc.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' OR pSucursal = '' OR pTipoOperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreEjecutivo;
		END IF;
		
		-- VALIDACCIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreEjecutivo;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cNombreEjecutivo;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_actualizasolicmc(pNumSolicitud, pSucursal, pUsuario, pTipoOperacion) INTO cCodRetSp, cNombreEjecutivo;
		
		IF cCodRetSp::SMALLINT = 3 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT = 4 THEN
			LET cCodRet = '90000'; -- LA SOLICITUD YA ESTA SIENDO ATENDIDA POR OTRO USUARIO
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT = 5 THEN
			LET cCodRet = '90001'; -- LA SOLICITUD YA FUE ATENDIDA POR OTRO USUARIO
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT = 6 THEN
			LET cCodRet = '90002'; -- SOLICITUD SE ENVIO A ORDEN SUPERVISION CALLE POR SISTEMA
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT = 6 THEN
			LET cCodRet = '90003'; -- LA SOLICITUD NO FUE REESTABLECIDA
			RETURN cCodRet, cNombreEjecutivo;
		ELIF cCodRetSp::SMALLINT < 0 THEN
			RAISE EXCEPTION cCodRetSp::SMALLINT;
		END IF;
		
		RETURN cCodRet, cNombreEjecutivo;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 12/12/2013",
"DESCRIPCION: Actualiza el estatus de una solicitud de credito para que el usuario pueda atenderla",
"BD: bdisolic";

CREATE PROCEDURE "informix".sp_consultacatalogo_productosmc(pIdFuncionDummy CHAR(10))
	RETURNING CHAR(5) AS codret,
			CHAR(40) AS nombre_prod,
			CHAR(4) AS num_producto;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cNombreProducto CHAR(40);
	DEFINE cNumProducto CHAR(4);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cMensajeRetorno = '';
	LET cNombreProducto = '';
	LET cNumProducto = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreProducto, cNumProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatalogo_productosmc.out';
		--TRACE ON;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_consulta_productos()
			INTO cCodRetSp, cMensajeRetorno, cNombreProducto, cNumProducto
			
			IF cCodRetSp = '00001' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNombreProducto, cNumProducto;
			ELSE
				RETURN cCodRet, cNombreProducto, cNumProducto WITH RESUME;
			END IF;
			
		END FOREACH;
	
	END;
	
END PROCEDURE;