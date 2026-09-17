CREATE PROCEDURE "informix".sp_apercredcoppel2(p_Empresa CHAR(3), 
												p_NumCte VARCHAR (20), 
												p_NumRef VARCHAR(20), 
												p_Usuario VARCHAR(20), 
												p_NumSolicitud VARCHAR(20), 
												p_Gerente CHAR (8), 
												p_Sucursal CHAR(4))
	RETURNING
		CHAR(5); ---cod_ret

	DEFINE cCod_ret      CHAR(5);
	DEFINE iSqlErr        INTEGER;
	DEFINE dFechaHoy      DATE;
	DEFINE cNomPromotor   CHAR(104);
	DEFINE cCodRet        CHAR(6);
	DEFINE cMensajeRet    CHAR(80);
	DEFINE cCliente_pros  CHAR(1);
	DEFINE cParamOS_AltaAutom CHAR(1);

	LET cCod_ret = '00000';
	LET dFechaHoy = '01/01/1900';
	LET cNomPromotor = '';
	LET cCodRet = '';
	LET cMensajeRet = '';
	LET cCliente_pros = '';
    LET cParamOS_AltaAutom = '';
	
	BEGIN

		ON EXCEPTION SET iSqlerr
			IF iSqlErr <> 0 THEN
				LET cCod_ret = iSqlErr;
				RETURN cCod_ret;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/tmp/sp_AperCredCoppel2.out";
		--TRACE ON;

		IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_adiccoppel WHERE numcte =  p_NumCte) THEN
			IF (p_Empresa IS NULL OR p_Empresa = '') OR (p_NumCte IS NULL OR p_NumCte = '') OR (p_NumRef IS NULL OR p_NumRef = '') OR (p_Usuario IS NULL OR p_Usuario = '') OR (p_NumSolicitud IS NULL OR p_NumSolicitud = '') OR (p_Gerente IS NULL OR p_Gerente = '') OR (p_Sucursal IS NULL OR p_Sucursal = '') THEN
				   LET cCod_ret = '00002';
			ELSE
				--- OBTIENE LA FECHA DEL DIA
				SELECT fecha_hoy
				INTO dFechaHoy
				FROM bdinteg:"informix".si_fechas;

				--- ACTUALIZA LA TABLA DE CLIENTES
				
				IF EXISTS (SELECT numcte FROM bdiprospectos:'informix'.pr_cliente WHERE numcte = p_NumCte) THEN
					LET cCliente_pros = '0';
				END IF;
				
				UPDATE bdinteg:"informix".si_cliente
				SET numcte_ref = p_NumRef, fecha_alta = dFechaHoy, user_insert = p_Usuario, cliente_pros = cCliente_pros
				WHERE numcte = p_NumCte;

				--- INSERTA EN LA TABLA DE LA RELACION DE LOS CLIENTES Y SUS ADICIONALES
				INSERT INTO bdinteg:"informix".si_adiccoppel (empresa, numctecoppel, secuencia, sucursal, numtarcoppel, numcte, tipotar, status, fechamov, user_insert)
				VALUES (p_Empresa, p_NumRef, 1, p_Sucursal, p_NumRef, p_NumCte, '1', 'S', dFechaHoy, p_Usuario);

				--REGISTRA LA APERTURA DEL CREDITO EN LA TABLA ss_autorizacion
				SELECT FIRST 1 nombre INTO cNomPromotor FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = p_Gerente;

				LET cNomPromotor = "Apertura de Credito Autorizada por: " || TRIM(cNomPromotor);

				/* INSERT INTO bdisolic:"informix".ss_autorizacion
				(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, fecha_entrada, fecha_salida, user_insert, fecha_insert, revision_cac)
				VALUES
				(p_Empresa, p_Gerente, p_NumSolicitud, 'AP', cNomPromotor, '', dFechaHoy, dFechaHoy, USER, dFechaHoy, 0);

				--- ACTUALIZA LA SOLICITUD CON STATUS DE TARJETA ASIGNADA
				UPDATE bdisolic:"informix".ss_solicitudes
				SET status_solicitud = 'AP'
				WHERE empresa = p_Empresa AND num_solicitud = p_NumSolicitud; */
				
				-- ACTUALIZA EL EJECUTIVO PARA REGISTRAR EL ALTA EN LA CARTERA EN LINEA
				UPDATE bdisolic:"informix".ss_solicitudes
				SET user_insert = p_Usuario
				WHERE empresa = p_Empresa AND num_solicitud = p_NumSolicitud;
				
				
				EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(p_Empresa,p_Gerente,p_NumSolicitud,'AP','',cNomPromotor)
				INTO cCod_ret;

				--- ACTUALIZA CAMPO ESTATUS DE "T" A "S" DE SOL COPPEL CON MARCAJE S-50 DE ALTA DIRECTA ENTREGADAS EL MISMO DIA, PARA ENVIAR A OS
		
				IF EXISTS (SELECT a.num_solicitud
							FROM bdisolic:ss_nuevo_parametrico a
							JOIN bdisolic:ss_autorizacion b ON (b.num_solicitud = a.num_solicitud)
							WHERE a.num_solicitud = p_NumSolicitud 
								AND a.status_solicitud = 'A' 
								AND a.flag_altadirecta_asupervisar = 1
								AND b.status_solicitud = 'AT'
								AND b.fecha_insert = dFechaHoy) THEN
					
					-- Reactivar por medio de bandera la generacion o no de OS  RQM 09 588 MACF
					SELECT valor INTO cParamOS_AltaAutom
                    FROM bdisolic:ss_param WHERE empresa = p_Empresa and secuencia = 450;
					
					
					IF cParamOS_AltaAutom = '1' THEN
					   UPDATE {+INDEX(ss_solicitud_os idx_ss_solicitud_os)} "informix".ss_solicitud_os
					      SET status = 'S'	
					    WHERE num_solicitud = p_NumSolicitud AND fecha_solicitud = dFechaHoy AND status = 'T';
					ELSE
					   UPDATE {+INDEX(ss_solicitud_os idx_ss_solicitud_os)} "informix".ss_solicitud_os
					      SET status = 'C'	---- Se quita el estatus S para mo enviar a OS las S-50 que aperturan el mismo dia y se cancela.
					    WHERE num_solicitud = p_NumSolicitud AND fecha_solicitud = dFechaHoy AND status = 'T';	
                    END IF;
						
				END IF;	

				EXECUTE PROCEDURE bdinteg:"informix".sp_relacion_generarelacion (p_NumCte,p_NumRef,'','1',1) 
				INTO cCodRet,cMensajeRet;

				--dsb-04/09/2013
				--INSERTA EN CLIENTES POR ENVIAR
				EXECUTE PROCEDURE bdinteg:"informix".sp_insertacteporenviar (p_Empresa ,p_Sucursal,p_NumCte,p_NumSolicitud,'000000',0,CURRENT,CURRENT) INTO cCod_ret;

			END IF
		ELSE
			LET cCod_ret = '00001';
		END IF;

		RETURN cCod_ret;

	END;
END PROCEDURE
