CREATE PROCEDURE "informix".sp_registrarespuestacoppel_cteprosp( pEmpresa		CHAR(3),
														pNum_Solic		    CHAR(20),
														pCod_ret			CHAR(3),
														pStatus_solic		CHAR (1),
														pSit_Especial	    CHAR(1),
														pCausa_sitesp		INTEGER,
														pPuntos_parcn		SMALLINT,
														pPar_altoriesgo		SMALLINT,
														pPar_celulares		SMALLINT,
														pPar_prestamos		SMALLINT,
														pIngreso_men		INTEGER,
														pCap_siste_abono	INTEGER,
														pTope_abonocoppel 	INTEGER,
														pCapmaxima_abono	INTEGER,
														pCapreal_abono		INTEGER,
														pLincred_real		INTEGER,
														pLincred_tope		INTEGER,
														pFechaLincred_real	CHAR (10),
														pFechaLincred_tope	CHAR (10),
														pCompromisosSic     INTEGER,
														pFlagLinCreditoEsp  SMALLINT,
														pLimiteCredito		INTEGER,
														pLimitecreditopesos INTEGER,
														pParaltoriesgonvo	INTEGER,
														pCampo_1    		CHAR(1),
														pCampo_2   			CHAR(1),
														pCampo_3   			CHAR(1),
														pClienteprospecto	CHAR (10),
														pIdSituaciones		INTEGER,
														pPuntualidadRef1	CHAR(2),
														pPuntualidadRef2	CHAR(2),
														pFlagTestigoParametrico	CHAR(1),
														pFlagAltaDirectaSup CHAR(1),
														pPuntosVarParam		INTEGER,
														pPuntosVarSic		INTEGER,
														pSocreDomicilio		INTEGER,
														pNuevoPuntajeFinal	SMALLINT,
														pCampo_4			INTEGER,
														pPrepuntajealtoriesgo INTEGER,--Campo ya existia pCampo_5 --DSB-14082017
														--pCampo_6			INTEGER		--598.1
														--pCampo_7			INTEGER	    --598.1
														--pCampo_8 			INTEGER	    --598.1
														pFlagPagoIni		CHAR(1),	--598.1
														pPorcPagoIni		CHAR(4),	--598.1
														pMontoPagoIni		INTEGER,	--598.1
														pFlagPrestamo		CHAR(1),	--598.1
														pCanalOrigenSol		CHAR(1),	--598.1
														pGrupoEval			CHAR(1),	--598.1
														pGrupoHit			CHAR(1),	--598.1
														pFlagTipoMsgMotos 	CHAR(1),	--09 541-2 
														pMontoDispMotos 	INTEGER,	--09 541-2 
														pPorcPIMotos 		CHAR(4),	--09 541-2 
														pTipocliente		INTEGER														
)
	RETURNING CHAR(6)  AS COD_RET,
		  CHAR(80) AS MENSAJE_EJEC;

	--DECLARACION DE VARIABLES
	DEFINE iSqlErr         			INTEGER;
	DEFINE iIsamErr        			INTEGER;
	DEFINE iCantReg        			INTEGER;
	DEFINE cErrorInfo      			CHAR(80);
	DEFINE cCodRet         			CHAR(6);
	DEFINE cMensajeRet          	CHAR(80);
	DEFINE dtFechaLincred_real    	DATE;
	DEFINE dtFechaLincred_tope    	DATE;
	DEFINE iEmpCob					INTEGER;
	DEFINE iSolicCte 				INTEGER;
	DEFINE cCodRet2					CHAR(6);
	DEFINE cNumCteBco				CHAR(20);
	DEFINE dFechaHoy       			DATE; --APR
	DEFINE dHoraHoy					DATETIME YEAR to SECOND; --APR
	DEFINE iSecuencia      			SMALLINT; --APR
	DEFINE wBegin       CHAR(1);

	--INICIALIZACION DE VARIABLES
	LET iSqlErr            			= 0;
	LET iIsamErr           			= 0;
	LET iCantReg           			= 0;
	LET cErrorInfo         			= "";
	LET cCodRet            			= "000000";
	LET cCodRet2					= "000000";
	LET cMensajeRet         		= "REGISTRO DE INFORMACION REALIZADO EXITOSAMENTE";
	LET dtFechaLincred_real 		=DATE(1);
	LET dtFechaLincred_tope 		= DATE(1);
	LET iEmpCob						= 0;
	LET iSolicCte					= 0;
	LET cNumCteBco         			= "";
	LET dFechaHoy           		= CURRENT::DATE;
	LET dHoraHoy					= CURRENT YEAR TO SECOND;
	LET iSecuencia          		= 0;
	LET pFlagPagoIni				= TRIM(NVL(pFlagPagoIni,'0'));
	LET pPorcPagoIni				= TRIM(NVL(pPorcPagoIni,'0'));
	LET pMontoPagoIni	            = NVL(pMontoPagoIni,0);
	LET pFlagPrestamo	            = TRIM(NVL(pFlagPrestamo,'0'));
	LET pCanalOrigenSol	            = TRIM(NVL(pCanalOrigenSol,'0'));
	LET pGrupoEval		            = TRIM(NVL(pGrupoEval,'0'));
	LET pGrupoHit		            = TRIM(NVL(pGrupoHit,'0'));
	-- 09 541-2		I		
	LET pFlagTipoMsgMotos			= NVL(pFlagTipoMsgMotos,''); 
	LET pMontoDispMotos 			= NVL(pMontoDispMotos,0);	
	LET pPorcPIMotos 				= NVL(pPorcPIMotos,'');		
	-- 09 541-2		F
	LET wBegin       ='N';
	
	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF wbegin = 'S' THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF;
				RETURN TRIM(cCodRet), TRIM(cMensajeRet);
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-255)
			LET wBegin = "B";
		END EXCEPTION WITH RESUME;

		ON EXCEPTION IN (-535)
			LET wBegin = "S";
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		 --SET DEBUG FILE TO "/home/sysifx/JoseLuis/sp_registrarespuestacoppel_cteprosp";
		 --TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK; 

		IF pFechaLincred_real <> "" THEN
			LET dtFechaLincred_real = SUBSTR(pFechaLincred_real,6,2)||'/'|| SUBSTR(pFechaLincred_real,9,2) ||'/'|| SUBSTR(pFechaLincred_real,1,4);
		ELSE
			LET dtFechaLincred_real = "";
		END IF;
		IF pFechaLincred_real <> "" THEN
			LET dtFechaLincred_tope = SUBSTR(pFechaLincred_tope,6,2)||'/'|| SUBSTR(pFechaLincred_tope,9,2) ||'/'|| SUBSTR(pFechaLincred_tope,1,4);
		ELSE
			LET dtFechaLincred_tope = "";
		END IF;

		--598.1 VALIDAR QUE SI LOS PARAMETROS VIENEN VACIOS GUARDARLOS EN 0
		IF pCanalOrigenSol = ' ' THEN
			LET pCanalOrigenSol = '0';
		END IF;
		
		IF pGrupoEval = ' ' THEN
			LET pGrupoEval = '0';
		END IF;
		
		IF pGrupoHit = ' ' THEN
			LET pGrupoHit = '0';
		END IF;
		
		IF pFlagPagoIni = ' ' THEN
			LET pFlagPagoIni = '0';
		END IF;
					
		IF pPorcPagoIni = ' ' THEN
			LET pPorcPagoIni = '0';
		END IF;
		
		IF pFlagPrestamo = ' ' THEN
			LET pFlagPrestamo = '0';
		END IF;
		--598.1 FIN		
		
		--SE VALIDA EL TIPO DE CLIENTE CON EL PARÃ¿METRO PTIPOCLIENTE PARA IDENTIFICAR QUE FLUJO TOMAR
		IF NVL(pTipocliente, 0 ) = 1 THEN
			
			SELECT numcte INTO cNumCteBco FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pNum_Solic;
			
			EXECUTE PROCEDURE bdiprospectos:"informix".sp_ctepr_validaorigencteprospecto(pNum_Solic)INTO cCodRet2,iSolicCte,iEmpCob;

			IF cCodRet::INTEGER = 0 AND iSolicCte = 1 THEN
				LET pSit_Especial = 'G';
				LET pCausa_sitesp = 57;
				LET cCodRet = cCodRet2;
			END IF;

			
			IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud=pNum_Solic) THEN

				INSERT INTO bdisolic:"informix".ss_nuevo_parametrico( empresa, num_solicitud, status_solicitud, situacion_especial,
						causa_sitesp, puntos_parcn, par_altoriesgo, par_celulares, par_prestamos,ingreso_mensual, cap_sistematica_abono,
						tope_abonocoppel, capmaxima_abono, capreal_abono, lineacredito_real, lineacreditotope, fechalineacreditoreal,
						fechalineacreditotope, compromisossic, flaglineacreditoesp, cod_ret, limitecredito, limitecreditopesos,
						paraaltoriesgonvo, campo_1, campo_2, campo_3, clienteprospecto,id_situaciones,puntualidad_ref1,puntualidad_ref2,
						flagtestigoparametricocn,flag_altadirecta_asupervisar,puntos_var_param,	puntos_var_sic,score_domicilio,
						nuevo_puntajefinal,campo_4, prepuntajealtoriesgo, flag_pagoini, porc_pagoini, monto_disp_pagoini, flag_prestamo,
						canal_origensol, grupo_eval, grupo_hit,flagtipomsgmotos,montodispmotos,porcpimotos)--DSB-14082017
				VALUES (pEmpresa, pNum_Solic, pStatus_solic, pSit_Especial, pCausa_sitesp, pPuntos_parcn, pPar_altoriesgo, 	pPar_celulares, pPar_prestamos,
						pIngreso_men, pCap_siste_abono, pTope_abonocoppel, pCapmaxima_abono, pCapreal_abono, pLincred_real, pLincred_tope,
						dtFechaLincred_real, dtFechaLincred_tope, pCompromisosSic, pFlagLinCreditoEsp, pCod_ret, pLimiteCredito, pLimitecreditopesos,
						pParaltoriesgonvo, pCampo_1, pCampo_2, pCampo_3, pClienteprospecto,pIdSituaciones,pPuntualidadRef1,pPuntualidadRef2,
						pFlagTestigoParametrico,pFlagAltaDirectaSup,pPuntosVarParam,pPuntosVarSic,pSocreDomicilio,pNuevoPuntajeFinal, 
						pCampo_4, pPrepuntajealtoriesgo, pFlagPagoIni, pPorcPagoIni, pMontoPagoIni, pFlagPrestamo, pCanalOrigenSol, pGrupoEval, pGrupoHit,pFlagTipoMsgMotos,pMontoDispMotos,pPorcPIMotos); --598.1
			ELSE
				LET cCodRet            	= "000001";
				LET cMensajeRet         = "NO SE REGISTRO LA INFORMACIÃN";

			END IF;
			
			IF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud=pNum_Solic) THEN
				UPDATE "informix".ss_solicitudes
				SET envio_parametrico = "2"
				WHERE num_solicitud = pNum_Solic
				AND empresa = pEmpresa;
			END IF;
			
		END IF;
		IF	 NVL(pTipocliente, 0 ) = 2 THEN
			
			IF EXISTS (SELECT num_solicitud FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE num_solicitud=pNum_Solic) THEN
			
				SELECT NVL(MAX(num_secuencia),0) INTO iSecuencia FROM bdiprospectos:"informix".pr_nuevo_parametrico_his WHERE num_solicitud = pNum_Solic;
				LET iSecuencia = iSecuencia + 1;

				INSERT INTO bdiprospectos:"informix".pr_nuevo_parametrico_his(empresa, num_solicitud, status_solicitud, situacion_especial, causa_sitesp, 
							puntos_parcn, par_altoriesgo, par_celulares, par_prestamos, ingreso_mensual, cap_sistematica_abono, tope_abonocoppel, capmaxima_abono,
							capreal_abono, lineacredito_real, lineacreditotope, fechalineacreditoreal, fechalineacreditotope, compromisossic, flaglineacreditoesp,
							cod_ret, limitecredito, limitecreditopesos, paraaltoriesgonvo, campo_1, campo_2, campo_3, clienteprospecto, id_situaciones, puntualidad_ref1,
							puntualidad_ref2, flagtestigoparametricocn, flag_altadirecta_asupervisar, puntos_var_param, puntos_var_sic, score_domicilio,
							nuevo_puntajefinal, canal_origenpros, campo_5, campo_6, campo_7, campo_8,num_secuencia, fecha_historico, hora_historico)
				SELECT empresa, num_solicitud, status_solicitud, situacion_especial, causa_sitesp, puntos_parcn, par_altoriesgo, par_celulares, par_prestamos,
				ingreso_mensual, cap_sistematica_abono, tope_abonocoppel, capmaxima_abono, capreal_abono, lineacredito_real, lineacreditotope, fechalineacreditoreal,
				fechalineacreditotope, compromisossic, flaglineacreditoesp, cod_ret, limitecredito, limitecreditopesos, paraaltoriesgonvo, campo_1, campo_2,
				campo_3, clienteprospecto, id_situaciones, puntualidad_ref1, puntualidad_ref2, flagtestigoparametricocn, flag_altadirecta_asupervisar, puntos_var_param,
				puntos_var_sic, score_domicilio, nuevo_puntajefinal, canal_origenpros, pPrepuntajealtoriesgo, campo_6, campo_7, campo_8, iSecuencia,dFechaHoy, dHoraHoy
				FROM bdiprospectos:"informix".pr_nuevo_parametrico 
				WHERE num_solicitud=pNum_Solic;

				DELETE FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE num_solicitud=pNum_Solic;		
			END IF;


			INSERT INTO bdiprospectos:"informix".pr_nuevo_parametrico( empresa, num_solicitud, status_solicitud, situacion_especial,
						causa_sitesp, puntos_parcn, par_altoriesgo, par_celulares, par_prestamos,ingreso_mensual, cap_sistematica_abono,
						tope_abonocoppel, capmaxima_abono, capreal_abono, lineacredito_real, lineacreditotope, fechalineacreditoreal,
						fechalineacreditotope, compromisossic, flaglineacreditoesp, cod_ret, limitecredito, limitecreditopesos,
						paraaltoriesgonvo, campo_1, campo_2, campo_3, clienteprospecto,id_situaciones,puntualidad_ref1,puntualidad_ref2,
						flagtestigoparametricocn,flag_altadirecta_asupervisar,puntos_var_param,	puntos_var_sic,score_domicilio,
						nuevo_puntajefinal, canal_origenpros, campo_5, campo_6, campo_7, campo_8 )--DSB-14082017
				VALUES (pEmpresa, pNum_Solic, pStatus_solic, pSit_Especial, pCausa_sitesp, pPuntos_parcn, pPar_altoriesgo, 	pPar_celulares, pPar_prestamos,
						pIngreso_men, pCap_siste_abono, pTope_abonocoppel, pCapmaxima_abono, pCapreal_abono, pLincred_real, pLincred_tope,
						dtFechaLincred_real, dtFechaLincred_tope, pCompromisosSic, pFlagLinCreditoEsp, pCod_ret, pLimiteCredito, pLimitecreditopesos,
						pParaltoriesgonvo, pCampo_1, pCampo_2, pCampo_3, pClienteprospecto,pIdSituaciones,pPuntualidadRef1,pPuntualidadRef2,
						pFlagTestigoParametrico,pFlagAltaDirectaSup,pPuntosVarParam,pPuntosVarSic,pSocreDomicilio,pNuevoPuntajeFinal, 
						pCanalOrigenSol, pPrepuntajealtoriesgo, pFlagPagoIni, pPorcPagoIni, pMontoPagoIni ); --598.1	

			--SE INSERTAN LOS DATOS DEL CLIENTE TIPO 3 PROSPECTO EN LA PR_NUEVO_PARAMETRICO
			UPDATE bdiprospectos:"informix".pr_cliente
			SET envio_parametrico = "2"
			WHERE numcte_pros = pNum_Solic
			AND empresa = pEmpresa;
		
		END IF;
		
		IF wbegin = 'S' THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
		
		RETURN cCodRet, TRIM(cMensajeRet);
	END;
END PROCEDURE
