CREATE PROCEDURE "informix".sp_sw_ro_guardaimagenes(pUsuarioC CHAR(8), pIdFuncionC CHAR(10), pIdOficio INT, pIdBusqueda INT, 
											pIdCte INT,	pTipoCuenta CHAR(2), pNumCte CHAR(20), pNumCta CHAR(20), 
											pProducto CHAR(4), pDescProducto CHAR(40), pCodDocto CHAR(4),pDescripcionDocto CHAR(35), 
											pSecuencia INT, pCodGpo CHAR(3), pDescGpo CHAR(30), pFechaRegistro CHAR(10), 
											pIndOmitido CHAR(1), pIp CHAR(15), pMac CHAR(15))
		RETURNING CHAR(5) AS codret
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE pFechaRegistro1 date;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET pFechaRegistro1 = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncionC) 
		INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		-- Validación de campos requeridos
		IF pUsuarioC = ''OR pIdFuncionC = ''
				OR pIdOficio = ''
				OR pIdBusqueda = ''
				OR pIdCte = ''
				OR pTipoCuenta = ''
				OR pNumCte = ''
				OR pNumCta = ''
				OR pProducto = ''
				OR pDescProducto = ''
				OR pCodDocto = ''
				OR pDescripcionDocto = ''
				OR pSecuencia = ''
				OR pCodGpo = ''
				OR pDescGpo = ''
				OR pFechaRegistro = ''
				OR pIp = ''
				OR pMac = ''
				OR pIndOmitido = '' 
			THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
		END IF;
		IF pIndOmitido NOT IN ('0', '1') THEN
			LET cCodRet = '00108';  -- El indicador no es compatible o algo así
			RETURN cCodRet;
		END IF;
		IF pTipoCuenta NOT IN('01', '03', '06', '00') THEN
			LET cCodRet = '00109'; -- El tipo de sistema busqueda es incorrecto
			RETURN cCodRet;
		END IF;
		
		let pFechaRegistro1 = EXTEND(MDY(SUBSTR(pFechaRegistro,6,2),SUBSTR(pFechaRegistro,9,2),SUBSTR(pFechaRegistro,1,4)), YEAR TO SECOND);
		INSERT INTO sw_ro_cteexp(id_oficio, id_busqueda,id_resulcte, tipo_cuenta, 
									numcte, cuenta, producto, descripcion_producto,
									cod_documento, descripcion_documento, secuencia, grupo, 
									descripcion_grupo, fecha_registro, user_INSERT, ip_INSERT, 
									mac_INSERT, ind_omitido)
			VALUES(pIdOficio, pIdBusqueda, pIdCte, pTipoCuenta, 
					pNumCte, pNumCta, pProducto, pDescProducto, 
					pCodDocto, pDescripcionDocto, pSecuencia, pCodGpo, 
					pDescGpo, pFechaRegistro1, pUsuarioC, pIp, 
					pMac, pIndOmitido);
		IF pProducto = '9999' THEN
			UPDATE sw_ro_resulcte 
			SET ind_expdig = '1' 
			WHERE id_resulcte = pIdCte 
				AND id_busqueda = pIdBusqueda 
				AND id_oficio = pIdOficio;
			-- Actualización de la tabla maeoficios
			UPDATE sw_ro_maeoficios 
			SET certifica_imagenes = '1' 
			WHERE id_oficio = pIdOficio;
		ELSE
			-- Se actualiza en estatus en la tabla de cuentas
			UPDATE sw_ro_ctecta 
			SET certifica_imagenes = '1' 
			WHERE id_resulcte = pIdCte 
				AND id_busqueda = pIdBusqueda 
				AND id_oficio = pIdOficio 
				AND cuenta = pNumCta;
			-- Se actualiza en estatus en la tabla de clientes
			UPDATE sw_ro_resulcte 
			SET certifica_imagenes = '1' 
			WHERE id_resulcte = pIdCte 
			AND id_busqueda = pIdBusqueda 
			AND id_oficio = pIdOficio;
			-- Se actualiza en estatus en la tabla de clientes
			UPDATE sw_ro_maeoficios 
			SET certifica_imagenes = '1' 
			WHERE id_oficio = pIdOficio;
		END IF;
		RETURN cCodRet;
	END
END PROCEDURE;