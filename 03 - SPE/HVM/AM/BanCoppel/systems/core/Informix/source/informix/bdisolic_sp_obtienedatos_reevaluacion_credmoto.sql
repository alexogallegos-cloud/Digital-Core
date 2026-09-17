CREATE PROCEDURE "informix".sp_obtienedatos_reevaluacion_credmoto(pEmpresa CHAR(3),pDias INTEGER, pNumSol CHAR(20),pNumCte CHAR(20),pSucursal CHAR(4))

	RETURNING 	CHAR(6) 					AS Cod_Ret,
				CHAR(1) 					AS FlagPagoInicial,
				CHAR(4)						AS PorcPagoInicial,
				INTEGER						AS MtoPagoInicial,
				CHAR(1)						AS FlagPrestamo,
				CHAR(1)						AS SituacionEspecial,
				INTEGER						AS CausaSitEsp,
				INTEGER						AS LineaCreditoReal,
				SMALLINT					AS FlagLineaCredEsp,
				INTEGER						AS LineaCreditoPesos,
				SMALLINT					AS NuevoPuntFinal,
				INTEGER						AS PrePuntAltoRiesgo,
				SMALLINT					AS CiudadSucursal,
				CHAR(1) 					AS FlagTipoMsgMotos,
				INTEGER						AS MontoDispMotos,
				CHAR(4) 					AS PorcPIMotos,
				CHAR(1)						AS FlagMotosCoppel,
				CHAR(1)						AS FactorTecho;

				

	DEFINE cCod_Ret						CHAR(6);	
	DEFINE iSqlErr						INTEGER;	
	DEFINE dtFechaInsert				DATE;
	DEFINE dtFechaHoy					DATE;
	DEFINE iDiasDiff					INTEGER;
	DEFINE cFlagPagoIni					CHAR(1);
	DEFINE cPorcPagoIni					CHAR(4);
	DEFINE iMontoDispPagIni				INTEGER;
	DEFINE cFlagPrestamo				CHAR(1);
	DEFINE cSitEspecial					CHAR(1);
	DEFINE iCasuaSitEsp					INTEGER;
	DEFINE iLineaCred					INTEGER;
	DEFINE iFlagLinCred					INTEGER;
	DEFINE iLinCredPesos				INTEGER;
	DEFINE sPuntFinal					SMALLINT;
	DEFINE iPuntRiesgo					INTEGER;
	DEFINE sCiudadSuc					SMALLINT;	
	DEFINE cFlagTipoMsgMotos			CHAR(1);
	DEFINE iMontoDispMotos				INTEGER;
	DEFINE cPorcPIMotos					CHAR(4);
	DEFINE cFlag_MotosCoppel			CHAR(1);
	DEFINE cFactor_Techo				CHAR(1);
	
	--VARIABLES DE RETORNO
	LET cCod_Ret						= '000000';	
	LET iSqlErr							= 0;
	LET dtFechaInsert					= DATE(1);
	LET dtFechaHoy						= DATE(1);
	LET iDiasDiff						= 0;
	LET cFlagPagoIni 					= '0'; 	--BANDERA PARA MENSAJE DE PAGO INICIAL.
	LET cPorcPagoIni 					= '0';	--PORCENTAJE DEL PAGO INICIAL
	LET iMontoDispPagIni				= 0;	--MONTO DISPONIBLE PARA EL PAGO INICIAL
	LET cFlagPrestamo 					= '0';	--BANDERA PARA MENSAJE DE PRESTAMO.
	LET cSitEspecial 					= '';	--SITUACIÃN ESPECIAL
	LET iCasuaSitEsp 					= 0;	--CAUSA DE SITUACIÃN ESPECIAL
	LET iLineaCred                      = 0;	--LÃNEA DE CRÃDITO REAL
	LET iFlagLinCred                    = 0;	--FLAG LINEA DE CRÃDITO ESPECIAL
	LET iLinCredPesos                   = 0;	--LÃNEA DE CRÃDITO PESOS
	LET sPuntFinal                      = 0;	--NUEVO PUNTAJE FINAL
	LET iPuntRiesgo                     = 0;	--PRE PUNTAJE ALTO RIESGO
	LET sCiudadSuc                    	= 0;	--CIUDAD DE LA SUCURSAL
	LET pEmpresa 						= TRIM(NVL(pEmpresa,''));
	LET pDias 							= NVL(pDias,0);
	LET pNumSol 						= TRIM(NVL(pNumSol,''));	
	LET pNumCte 						= TRIM(NVL(pNumCte,''));
	LET pSucursal 						= TRIM(NVL(pSucursal,''));
	LET cFlagTipoMsgMotos				= '0';
	LET iMontoDispMotos					= 0;
	LET cPorcPIMotos					= '';
	LET cFlag_MotosCoppel				= '0';
	LET cFactor_Techo					= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCod_Ret = iSqlErr;
			RETURN cCod_Ret,cFlagPagoIni,cPorcPagoIni, iMontoDispPagIni, cFlagPrestamo, cSitEspecial, iCasuaSitEsp,iLineaCred, iFlagLinCred,
				iLinCredPesos, sPuntFinal, iPuntRiesgo, sCiudadSuc,cFlagTipoMsgMotos,iMontoDispMotos,cPorcPIMotos,cFlag_MotosCoppel,cFactor_Techo;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_obtienedatos_reevaluacion.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa <> '' AND pNumCte <> '' AND pNumSol <> '' AND pSucursal <> '' THEN
			
			SELECT fecha_hoy
			INTO dtFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = pEmpresa;
		
			--FECHA DE ALTA DE LA SOLICITUD
			SELECT fecha_insert
			INTO dtFechaInsert
			FROM  "informix".ss_solicitudes
			WHERE empresa = pEmpresa
			AND num_solicitud = pNumSol
			AND numcte = pNumcte;
		
			LET dtFechaInsert = NVL(dtFechaInsert,DATE(1));
			LET dtFechaHoy = NVL(dtFechaHoy,DATE(1));
			LET iDiasDiff =  NVL(dtFechaHoy - dtFechaInsert,0);	
			
			IF pDias < 0 THEN
				LET pDias = 1;
			END IF
			
			IF iDiasDiff >= pDias THEN
				--SE ENVIAN LOS DATOS PARA REEVALUAR LA SOLICITUD DE COPPEL,
				-- YA QUE SE REALIZO EN DIA DIFERENTE AL QUE SE DIO DE ALTA
				SELECT situacion_especial, causa_sitesp, lineacredito_real,
				flaglineacreditoesp, limitecreditopesos, nuevo_puntajefinal,
				prepuntajealtoriesgo
				INTO cSitEspecial, iCasuaSitEsp, iLineaCred, 
				iFlagLinCred, iLinCredPesos, sPuntFinal,
				iPuntRiesgo
				FROM "informix".ss_nuevo_parametrico
				WHERE Empresa = pEmpresa
				AND num_solicitud = pNumSol;
				
				--CIUDAD DE LA SUCURSAL
				SELECT cve_ciudad::SMALLINT
				INTO sCiudadSuc
				FROM  bdinteg: "informix".si_ptf 
				WHERE id_ptf = pSucursal
				AND tipo = 'S';

				LET cCod_Ret = '000002';
				
			ELSE
				--NO SE NECESITA ENVIAR LA SOLICITUD DE COPPEL A REEVALUAR,
				-- YA QUE SE REALIZO EL MISMO DIA EN QUE SE DIO DE ALTA
				SELECT flag_pagoini, porc_pagoini,flag_prestamo, monto_disp_pagoini, flagtipomsgmotos, montodispmotos, porcpimotos
				INTO cFlagPagoIni,cPorcPagoIni, cFlagPrestamo,iMontoDispPagIni,cFlagTipoMsgMotos,iMontoDispMotos,cPorcPIMotos
				FROM "informix".ss_nuevo_parametrico 
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol;
				
			END IF;
			
			SELECT factor_piso,factor_techo
			INTO cFlag_MotosCoppel, cFactor_Techo
			FROM bdisolic:"informix".ss_solicitudes
			WHERE numcte = pNumCte AND num_solicitud = pNumSol;
			
			LET cFlagPagoIni = TRIM(NVL(cFlagPagoIni,'0'));
			LET cPorcPagoIni = TRIM(NVL(cPorcPagoIni,'0'));
			LET iMontoDispPagIni = NVL(iMontoDispPagIni,0);
			LET cFlagPrestamo = TRIM(NVL(cFlagPrestamo,'0'));
			LET cSitEspecial = TRIM(NVL(cSitEspecial,''));
			LET iCasuaSitEsp = NVL(iCasuaSitEsp,0);
			LET iLineaCred = NVL(iLineaCred,0);
			LET iFlagLinCred = NVL(iFlagLinCred,0);
			LET iLinCredPesos = NVL(iLinCredPesos,0);
			LET sPuntFinal = NVL(sPuntFinal,0);
			LET iPuntRiesgo = NVL(iPuntRiesgo,0);
			LET sCiudadSuc = NVL(sCiudadSuc,0);
			LET cFlagTipoMsgMotos = TRIM(NVL(cFlagTipoMsgMotos,"0"));
			LET iMontoDispMotos = NVL(iMontoDispMotos,0);
			LET cPorcPIMotos = TRIM(NVL(cPorcPIMotos,"0")); 
			LET cFlag_MotosCoppel = TRIM(NVL(cFlag_MotosCoppel,'0'));
			LET cFactor_Techo = TRIM(NVL(cFactor_Techo,''));
				
		ELSE
			LET cCod_Ret = '000001';	
		END IF;
		
		RETURN cCod_Ret,cFlagPagoIni,cPorcPagoIni, iMontoDispPagIni, cFlagPrestamo, cSitEspecial, iCasuaSitEsp,iLineaCred, iFlagLinCred,
				iLinCredPesos, sPuntFinal, iPuntRiesgo, sCiudadSuc,cFlagTipoMsgMotos,iMontoDispMotos,cPorcPIMotos,cFlag_MotosCoppel,cFactor_Techo;
		
	END;				
END PROCEDURE
