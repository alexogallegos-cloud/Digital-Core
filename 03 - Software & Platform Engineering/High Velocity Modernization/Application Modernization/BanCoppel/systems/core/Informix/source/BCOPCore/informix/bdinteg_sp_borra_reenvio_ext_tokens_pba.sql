CREATE PROCEDURE "informix".sp_borra_reenvio_ext_tokens_pba()
	RETURNING CHAR(5) as codRet;

	--************************************************************************************************************************************************
	--Modificó: Manuel Ramos Figueroa.
	--Objetivo: Depurar y cancelar las solicitudes que se encuentren en estatus de reactivada (180) con un periodo de días mayor al valor del campo 
	--			bdibpi:bpi_param.valor donde el valor del campo bdibpi:bpi_param.id_param sea igual a 17.
	--Solicitó: Aida Valenzuela (BanCoppel).
	--Fecha: 2015-07-20.
	--BD:bdinteg.
	--************************************************************************************************************************************************

	DEFINE cod_ret CHAR(5);
	DEFINE sql_err INTEGER;
	DEFINE cDiasDepuracion CHAR(40);
	DEFINE iDiasDepuracion INTEGER;
	DEFINE cDiasVigencia CHAR(40);
	DEFINE iDiasVigencia INTEGER;
	DEFINE cSolicitud CHAR(10);
	DEFINE cStatus SMALLINT;
	DEFINE cNumCte CHAR(9);
	DEFINE cSolicitudesDepuradas CHAR(7);
	DEFINE iSolicitudesDepuradas INTEGER;
	DEFINE cEmailUsuarioAdmToken CHAR(40);

	--Variables de retorno del SP sp_cons_detenvios_token
	DEFINE vCodRet CHAR(5);
	DEFINE vFolioSuc CHAR(16);
	DEFINE vCuenta CHAR(20);
	DEFINE vFecha DATE;
	DEFINE vSucursal CHAR(4);
	DEFINE vCargoTot MONEY(16,2);

	--Variable de retorno del SP sp_registra_evento
	DEFINE vCodRet2 CHAR(5);

	LET cod_ret = '00000';
	LET cDiasDepuracion = '';
	LET iDiasDepuracion = 0;
	LET cDiasVigencia = '';
	LET iDiasVigencia = 0;
	LET cSolicitud = '00000';
	LET cStatus = 0;
	LET cNumCte = '';
	LET cSolicitudesDepuradas = '';
	LET iSolicitudesDepuradas = 0;
	LET cEmailUsuarioAdmToken = '';

	LET vCodRet = '';
	LET vFolioSuc = '';
	LET vCuenta = '';
	LET vSucursal = '';
	LET vCargoTot = 0;

	LET vCodRet2 = '';

	SET DEBUG FILE TO 'sp_borra_reenvio_ext_tokens.out';
	TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				RETURN cod_ret;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		SELECT valor 
		INTO cDiasDepuracion 
		FROM bdibpi:"informix".bpi_param 
		WHERE id_param = '17';

		SELECT valor 
		INTO cDiasVigencia 
		FROM bdibpi:"informix".bpi_param 
		WHERE id_param = '18';

		LET iDiasDepuracion = TRIM(cDiasDepuracion)::INTEGER;
		LET iDiasVigencia = TRIM(cDiasVigencia)::INTEGER;

		DELETE {+INDEX(bdibpi:"informix".bpi_bitacora_reenvios idx_bitacora_reenvios)} FROM bdibpi:"informix".bpi_bitacora_reenvios WHERE fecha_depuracion < CURRENT YEAR TO SECOND - iDiasVigencia UNITS DAY;

		FOREACH

			SELECT  {+INDEX (bdibpi:"informix".bpi_tokensolicitud idx_bpi_tokensolicitud)}solicitud, id_status, numcte 
			INTO cSolicitud, cStatus, cNumCte 
			FROM bdibpi:"informix".bpi_tokensolicitud 
			WHERE id_status = 180 
			AND f_atencion < CURRENT YEAR TO SECOND - iDiasDepuracion UNITS DAY

			EXECUTE PROCEDURE bdibpi:"informix".sp_cons_detenvios_token('001',cSolicitud)
			INTO vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;

			IF TRIM(NVL(vCodRet, '')) = '002' THEN

				INSERT INTO bdibpi:"informix".bpi_bitacora_reenvios(num_solicitud,numcliente,estatus_depuracion,fecha_depuracion) VALUES(cSolicitud,cNumCte,cStatus,current);

				UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = 199 WHERE solicitud = cSolicitud;
				
				INSERT INTO bdibpi:"informix".tkn_stasolicitud(solicitud,anterior,actual,f_registro) VALUES(cSolicitud,'180','199',current);

				UPDATE {+INDEX(bdibpi:"informix".tkn_envios idx_tkn_envios_sol)} bdibpi:"informix".tkn_envios SET id_status = 199, comentarios = 'La solicitud fue cancelada' WHERE solicitud = cSolicitud;

				LET iSolicitudesDepuradas = iSolicitudesDepuradas + 1;

			END IF;

		END FOREACH;

		IF iSolicitudesDepuradas > 0 THEN

			LET cSolicitudesDepuradas = iSolicitudesDepuradas::CHAR(7);

			SELECT valor 
			INTO cEmailUsuarioAdmToken 
			FROM bdibpi:"informix".bpi_param 
			WHERE id_param = '16';

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','PORTAL_BPI','BPI_DRTOKN', '000000000', '','','1', cSolicitudesDepuradas,'','','','', '','','','0','',cEmailUsuarioAdmToken,'',1,0,0,0,0,current,'')
			INTO vCodRet2;

		ELSE

			--No se encontraron solicitudes a depurar.
			LET cod_ret = '00001';

		END IF;

		RETURN cod_ret;
	END;
END PROCEDURE;