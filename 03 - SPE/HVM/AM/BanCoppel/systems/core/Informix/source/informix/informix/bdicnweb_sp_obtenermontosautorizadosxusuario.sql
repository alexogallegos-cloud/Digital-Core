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