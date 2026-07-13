CREATE PROCEDURE "informix".sp_parametros_kiosko(pUsuario CHAR(8), pIdFuncion CHAR(10), pMac CHAR(12))
			RETURNING CHAR(5) AS codret,
				CHAR(1) AS usa_touch,
				CHAR(1) AS usa_img_huella,
				CHAR(1)	AS idx_archivo_huella,
				INTEGER AS posicion_top_huella,
				INTEGER AS posicion_izquierda_huella,
				CHAR(1) AS usa_img_lectora,
				CHAR(1)	AS idx_archivo_lectora,
				INTEGER AS posicion_top_lectora,
				INTEGER AS posicion_izquierda_lectora;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cUsaTouch CHAR(1);
	DEFINE cUsaImgHuella CHAR(1);
	DEFINE cUsaImgLectora CHAR(1);
	DEFINE cIndImgHuella CHAR(1);
	DEFINE cIndImgLectora CHAR(1);
	DEFINE iPosTopHuella INTEGER;
	DEFINE iPosLeftHuella INTEGER;
	DEFINE iPosTopLectora INTEGER;
	DEFINE iPosLeftLectora INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cUsaTouch = '';
	LET cUsaImgHuella = '';
	LET cUsaImgLectora = '';
	LET cIndImgHuella = '';
	LET cIndImgLectora = '';
	LET iPosTopHuella = 0;
	LET iPosLeftHuella = 0;
	LET iPosTopLectora = 0;
	LET iPosLeftLectora = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cUsaTouch, cUsaImgHuella, cIndImgHuella, iPosTopHuella, iPosLeftHuella, cUsaImgLectora, cIndImgLectora, iPosTopLectora, iPosLeftLectora;
		END EXCEPTION;

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_parametros_kiosko.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cUsaTouch, cUsaImgHuella, cIndImgHuella, iPosTopHuella, iPosLeftHuella, cUsaImgLectora, cIndImgLectora, iPosTopLectora, iPosLeftLectora;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUsaTouch, cUsaImgHuella, cIndImgHuella, iPosTopHuella, iPosLeftHuella, cUsaImgLectora, cIndImgLectora, iPosTopLectora, iPosLeftLectora;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		SELECT usa_touch
		INTO cUsaTouch
		FROM bdicnweb:"informix".kw_sucursal_touch
		WHERE direccion_mac = pMac;
		
		-- SELECCION DE PARAMETROS DE IMAGENES PARA INSTRUCCIONES DE HUELLA Y DE LECTORA DE TARJETAS
		SELECT usar_img_huella, id_img_huella, img_huella_top, img_huella_left, usar_img_lectora, id_img_lectora, img_lectora_top, img_lectora_left
		INTO cUsaImgHuella, cIndImgHuella, iPosTopHuella, iPosLeftHuella, cUsaImgLectora, cIndImgLectora, iPosTopLectora, iPosLeftLectora
		FROM bdicnweb:"informix".kw_sucursal_indimg
		WHERE direccion_mac = pMac;

		RETURN cCodRet, NVL(cUsaTouch, '0'), NVL(cUsaImgHuella, '0'), cIndImgHuella, iPosTopHuella, iPosLeftHuella, NVL(cUsaImgLectora, '0'), cIndImgLectora, iPosTopLectora, iPosLeftLectora;

	END;
END PROCEDURE

DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 09/03/2015',
'DESCRIPCION: Procedimiento de que devuelve parametros relacionados al kiosko',
'Usa touch: determina si la dirección mac de entrada utiliza touchscreen para que se pueda utilizar el teclado virtual',
'FECHA: 17/02/2016',
'UsaImgHuella: determina si se usara la imagen de huella',
'IndImgHuella: determina el numero de archivo que se utilizara para ser mostrado en el front-end',
'PosTopHuella: Si es -1 la imagen se centrara en lo vertical en el front-end; en otro caso se colocara de acuerdo al valor en el front-end',
'PosLeftHuella: Si es -1 la imagen se centrara en lo horizontal en el front-end; en otro caso se colocara de acuerdo al valor en el front-end',
'Aplican los mismos parametros para UsaImgLectora',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtenermontosautorizadosxusuario(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				MONEY(14, 2) AS monto_max_debito_cargo, 
				MONEY(14, 2) AS monto_max_debito_abono, 
				MONEY(14, 2) AS monto_max_debito_reverso, 
				MONEY(14, 2) AS monto_max_credito_cargo, 
				MONEY(14, 2) AS monto_max_credito_abono, 
				MONEY(14, 2) AS monto_max_credito_reverso,
				CHAR(8) AS id_usuario_autoriza;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE mMontoMaxDebCargo MONEY(14, 2);
	DEFINE mMontoMaxDebAbono MONEY(14, 2);
	DEFINE mMontoMaxDebReverso MONEY(14, 2);
	DEFINE mMontoMaxCredCargo MONEY(14, 2);
	DEFINE mMontoMaxCredAbono MONEY(14, 2);
	DEFINE mMontoMaxCredReverso MONEY(14, 2);
	DEFINE cUsuarioAutoriza CHAR(8);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET mMontoMaxDebCargo = NULL;
	LET mMontoMaxDebAbono = NULL;
	LET mMontoMaxDebReverso = NULL;
	LET mMontoMaxCredCargo = NULL;
	LET mMontoMaxCredAbono = NULL;
	LET mMontoMaxCredReverso = NULL;
	LET cUsuarioAutoriza = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, mMontoMaxDebCargo, mMontoMaxDebAbono, mMontoMaxDebReverso, mMontoMaxCredCargo, mMontoMaxCredAbono, mMontoMaxCredReverso, cUsuarioAutoriza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtenermontosautorizadosxusuario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, mMontoMaxDebCargo, mMontoMaxDebAbono, mMontoMaxDebReverso, mMontoMaxCredCargo, mMontoMaxCredAbono, mMontoMaxCredReverso, cUsuarioAutoriza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		SELECT monto_max_deb_cargo, monto_max_deb_abono, monto_max_deb_reverso, monto_max_cred_cargo, monto_max_cred_abono, monto_max_cred_reverso, id_usuario_autoriza
		INTO mMontoMaxDebCargo, mMontoMaxDebAbono, mMontoMaxDebReverso, mMontoMaxCredCargo, mMontoMaxCredAbono, mMontoMaxCredReverso, cUsuarioAutoriza
		FROM bdinteg:si_seg_montos_autorizados
		WHERE id_usuario = pUsuario;
		
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
			
		RETURN cCodRet, mMontoMaxDebCargo, mMontoMaxDebAbono, mMontoMaxDebReverso, mMontoMaxCredCargo, mMontoMaxCredAbono, mMontoMaxCredReverso, cUsuarioAutoriza;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 18/09/2014',
'DESCRIPCION: Consulta los montos autorizados por usuario para poder realizar transacciones',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarfctpocterelacionadocli(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(13) AS rfc,
			CHAR(13) AS rfc_alterno,
			SMALLINT AS tipo_relacion_cliente;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cRfc CHAR(13);
	DEFINE cRfcAlterno CHAR(13);
	DEFINE iTipoRelacionCliente SMALLINT;
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cRfc = '';
	LET cRfcAlterno = '';
	LET iTipoRelacionCliente = 0;	
	LET iExiste = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarfctpocterelacionadocli.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
		END IF;
		
		-- ValidaciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumCliente;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00053';
			RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
		END IF;
		
		SELECT rfc, rfc_alterno, numeric2
		INTO cRfc, cRfcAlterno, iTipoRelacionCliente
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumCliente;
		
		RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
	
	END;
			
END PROCEDURE;