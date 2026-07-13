CREATE PROCEDURE "informix".sp_borra_reenvio_ext_tokens()
	RETURNING CHAR(5) as codRet;

	--************************************************************************************************************************************************
	--ModificÃ³: Manuel Ramos Figueroa.
	--Objetivo: Depurar y cancelar las solicitudes que se encuentren en estatus de reactivada (180) con un periodo de dÃ­as mayor al valor del campo 
	--			Âbdibpi:bpi_param.valorÂ donde el valor del campo Âbdibpi:bpi_param.id_paramÂ sea igual a Â17Â.
	--SolicitÃ³: Aida Valenzuela (BanCoppel).
	--Fecha: 2015-07-20.
	--BD:bdinteg.
	-- Se agrega la insersiÃ³n en la tabla histÃ³rica si_bpitokenhis y la eliminaciÃ³n del registro en la tabla si_bpitoken
	-- Alejandro VÃ¡zquez
	-- Fecha: 22/12/2015
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

	--Variables de retorno del SP sp_consulta_saldo_cuentas
	DEFINE vCodRet CHAR(5);
	DEFINE cod_val CHAR(5);
	

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
	LET cod_val = "000";

	LET vCodRet2 = '';

	--SET DEBUG FILE TO '/informix/Aida/sp_borra_reenvio_ext_tokens.out';
	--TRACE ON;

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

			
			
			EXECUTE PROCEDURE bdicheq:"informix".sp_consulta_saldo_cuentas ('001',cSolicitud)
			INTO vCodRet, cod_val;
			
			IF TRIM(NVL(vCodRet, '')) = '002' and TRIM(NVL(cod_val, ''))='099' THEN

				INSERT INTO bdibpi:"informix".bpi_bitacora_reenvios(num_solicitud,numcliente,estatus_depuracion,fecha_depuracion) VALUES(cSolicitud,cNumCte,cStatus,current);

				UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = 199 WHERE solicitud = cSolicitud;
				
				INSERT INTO bdibpi:"informix".tkn_stasolicitud(solicitud,anterior,actual,f_registro) VALUES(cSolicitud,'180','199',current);

				UPDATE {+INDEX(bdibpi:"informix".tkn_envios idx_tkn_envios_sol)} bdibpi:"informix".tkn_envios SET id_status = 199, comentarios = 'La solicitud fue cancelada' WHERE solicitud = cSolicitud;
				
				INSERT INTO bdinteg:"informix".si_bpitokenhis(empresa,num_cliente,ns_token,suc_registro,folio_token,id_status_token,f_status,f_registro) 
					SELECT  TS.empresa, TS.num_cliente, '', TS.suc_registro, TS.folio_token, CASE WHEN TS.id_status_token = 0 THEN 199 ELSE TS.id_status_token  END, TS.f_status::date, TS.f_registro::date					
					FROM bdinteg:"informix".si_bpitoken AS TS, bdibpi:"informix".bpi_tokensolicitud AS TK
					WHERE TS.empresa = TK.empresa
					AND TK.numcte = TS.num_cliente
					AND TS.num_cliente=TRIM(cNumCte) 										
					AND TK.solicitud = TRIM(cSolicitud);
		
				DELETE bdinteg:"informix".si_bpitoken WHERE  num_cliente=TRIM(cNumCte) AND ns_token='';


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