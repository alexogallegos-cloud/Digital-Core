CREATE PROCEDURE "informix".spconsultarconfaltante (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_sNumZona CHAR(3), 
										p_sNumRegional CHAR(3), p_iIdAsignado SMALLINT, p_dFechaIni DATE, 
										p_dFechaFin DATE, p_iIdEstatus SMALLINT)

RETURNING 	CHAR(5) AS CodigoRetorno, 
			CHAR(8) AS NumEmpleado, 	
			CHAR(45) AS NomEmpleado, 	
			CHAR(4) AS Sucursal, 	
			CHAR(40) AS NomSucursal, 	
			SMALLINT AS IdFaltante, 	
			CHAR(12) AS Auxiliar, 	
			CHAR(3) AS NumZona,  	
			CHAR(3) AS NumRegion, 	
			SMALLINT AS IdConcepto, 	
			CHAR(80) AS DesConcepto, 	
			SMALLINT AS IdRecupera, 	
			CHAR(80) AS DesRecupera, 	
			SMALLINT AS IdAsignado, 	
			CHAR(80) AS DesAsignado, 	
			SMALLINT AS IdEstatus, 	
			CHAR(80) AS DesEstatus, 	
			MONEY(10,0) AS SaldoInicial,  	
			MONEY(10,0) AS DescAcumulado, 	
			MONEY(10,0) AS DescCalculado, 	
			MONEY(10,0) AS SaldoActual,
			CHAR(40) AS BancoCheque, 	
			DATE AS FechaLiquida, 	
			DATE AS FechaAsigna, 	
			DATE AS FechaRegistro,
			CHAR(8) AS UsuariAutoriza,
			CHAR(26) AS Referencia,
			MONEY(10,0) AS SaldoQueb

	DEFINE iSqlErr			INTEGER;
	
	DEFINE v_sCodRet       	CHAR(5);	
	DEFINE v_sNumEmpleado	CHAR(8);
	DEFINE v_sNomEmpleado	CHAR(45);
	DEFINE v_sNumSucursal	CHAR(4);  
	DEFINE v_sNomSucursal	CHAR(40);
	DEFINE v_iIdFaltante	SMALLINT; 
	DEFINE v_sAuxiliar		CHAR(12); 
	DEFINE v_sNumZona		CHAR(3);	
	DEFINE v_sNumRegional	CHAR(3); 
	DEFINE v_iIdConcepto	SMALLINT; 
	DEFINE v_sDesConcepto	CHAR(80);
	DEFINE v_iIdRecupera	SMALLINT; 
	DEFINE v_sDesRecupera	CHAR(80);
	DEFINE v_iIdAsignado	SMALLINT; 	     
	DEFINE v_sDesAsignado 	CHAR(80);
	DEFINE v_iIdEstatus		SMALLINT; 
	DEFINE v_sDesEstatus	CHAR(80);
	DEFINE v_mSaldoInicial	MONEY(10,0); 
	DEFINE v_mDescAcumulado MONEY(10,0); 
	DEFINE v_mDescCalculado MONEY(10,0); 
	DEFINE v_mSaldoActual 	MONEY(10,0); 
	DEFINE v_mSaldoQueb 	MONEY(10,0); 
	DEFINE v_sBancoCheque 	CHAR(40); 
	DEFINE v_dFechaLiquida 	DATE; 
	DEFINE v_dFechaAsigna 	DATE;         
	DEFINE v_dFechaRegistro	DATE;	
	DEFINE v_sReferencia	CHAR(26);
	DEFINE v_sUsuarioAutoriza CHAR(8);
	
	--SET DEBUG FILE TO "/dbexportb/Fabiola/spconsultarconfaltante.out"; 
	--TRACE ON;
    
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'','','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00000';				
		
		IF NVL(p_sNumEmpleado,'') = '' THEN
			LET p_sNumEmpleado = NULL;
		END IF
		
		IF NVL(p_sNumSucursal,'') = '' THEN 
			LET p_sNumSucursal = NULL;
		END IF
		
		IF NVL(p_sNumZona,'') = '' THEN 
			LET p_sNumZona = NULL;
		END IF
		
		IF NVL(p_sNumRegional,'') = '' THEN
			LET p_sNumRegional = NULL;
		END IF
		
		IF NVL(p_iIdAsignado,'') = '' THEN
			LET p_iIdAsignado = NULL;
		END IF 
		
		IF NVL(p_dFechaIni,'')= '' OR NVL(p_dFechaFin,'') = ''THEN
			LET p_dFechaIni = NULL;
			LET p_dFechaFin = NULL;
		END IF
		
		IF NVL(p_iIdEstatus,'') = '' THEN
			LET p_iIdEstatus = NULL;
		END IF 
		
		LET v_mSaldoQueb = 0;
		
		IF (p_iIdAsignado > 0 OR p_iIdAsignado IS NULL) and (p_iIdEstatus not in (4,7) or p_iIdEstatus IS NULL) THEN --Consulta para cuando el area sea especifica o todas las areas (no asignados,  o
		--area en especifico, o todas las areas sin restriciÃÂ³n)
			FOREACH
				SELECT numempleado, numsucursal, idfaltante, auxiliar, numzona, numregional, idconcepto, idrecupera, idasignado, 
				idestatus, saldoinicial, descacumulado, desccalculado, saldoactual, bancocheque, fechaliquida, fechaasigna, 
				fecharegistro, usuarioautoriza, referencia
				INTO v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, v_iIdConcepto, v_iIdRecupera,
                v_iIdAsignado, v_iIdEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
 				v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia
				FROM bdirech:rec_confaltante
				WHERE idfaltante <> 0 AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numempleado = NVL(p_sNumEmpleado,numempleado)
				AND numzona = NVL(p_sNumZona,numzona) AND numregional = NVL(p_sNumRegional,numregional) 
				AND idasignado = NVL(p_iIdAsignado, idasignado) 
				AND fecharegistro BETWEEN NVL(p_dFechaIni, fecharegistro) AND NVL(p_dFechaFin,fecharegistro) 
				AND idestatus = NVL(p_iIdEstatus, idestatus)

				SELECT desasignado INTO v_sDesAsignado FROM bdirech:rec_catasignado WHERE idasignado = v_iIdAsignado;
				SELECT desconcepto INTO v_sDesConcepto FROM bdirech:rec_catconcepto WHERE idconcepto = v_iIdConcepto;
				SELECT desestatus INTO v_sDesEstatus FROM bdirech:rec_catestatus WHERE idestatus = v_iIdEstatus;
				SELECT desrecupera INTO v_sDesRecupera FROM bdirech:rec_catrecupera WHERE idrecupera = v_iIdRecupera;
				SELECT nombre INTO v_sNomEmpleado FROM bdinteg:si_ejecut WHERE ejecutivo = v_sNumEmpleado;
				SELECT nombre INTO v_sNomSucursal FROM bdinteg:si_sucursales WHERE sucursal = v_sNumSucursal;
				--SELECT NVL(saldoactual,0) INTO v_mSaldoQueb FROM bdirech:rec_movquebrantos WHERE numempleado=v_sNumEmpleado and idfaltante=v_iIdFaltante and auxiliar=v_sAuxiliar;
							
				RETURN v_sCodRet, v_sNumEmpleado, v_sNomEmpleado, v_sNumSucursal, v_sNomSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona,
                v_sNumRegional, v_iIdConcepto, v_sDesConcepto, v_iIdRecupera, v_sDesRecupera, v_iIdAsignado, v_sDesAsignado, v_iIdEstatus,
				v_sDesEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
				v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia, NVL(v_mSaldoQueb,0) WITH RESUME;
			END FOREACH
		ELIF p_iIdEstatus in (4,7) THEN --Consulta para cuando el area sea especifica o todas las areas (no asignados,  o area en especifico, o todas las areas sin restriciÃÂ³n)
		
					if (p_iIdAsignado > 0 OR p_iIdAsignado IS NULL) THEN
							FOREACH
								SELECT RC.numempleado, RC.numsucursal, RC.idfaltante, RC.auxiliar, RC.numzona, RC.numregional, RC.idconcepto, RC.idrecupera, RC.idasignado, 
									RC.idestatus, RC.saldoinicial, RC.descacumulado, RC.desccalculado, RC.saldoactual, RC.bancocheque, RC.fechaliquida, RC.fechaasigna, 
									RC.fecharegistro, RC.usuarioautoriza, RC.referencia, NVL(RM.saldoactual,0)
								INTO v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, v_iIdConcepto, v_iIdRecupera,
									v_iIdAsignado, v_iIdEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
									v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia,v_mSaldoQueb
								FROM bdirech:rec_confaltante RC
									INNER JOIN bdirech:rec_movquebrantos RM
									on RC.numempleado = RM.numempleado and RC.idfaltante=RM.idfaltante and 
									trim(RM.tipoperacion)=(Case when p_iIdEstatus=4 then 'SIF' ELSE 'FINALIZADO' end)--'SIF'
								WHERE RC.idfaltante <> 0 AND RC.numsucursal = NVL(p_sNumSucursal,RC.numsucursal) AND RC.numempleado = NVL(p_sNumEmpleado,RC.numempleado)
									AND RC.numzona = NVL(p_sNumZona,RC.numzona) AND RC.numregional = NVL(p_sNumRegional,RC.numregional) 
									AND RC.idasignado = NVL(p_iIdAsignado, RC.idasignado) 
									AND RM.fechareg BETWEEN NVL(p_dFechaIni, RM.fechareg) AND NVL(p_dFechaFin,RM.fechareg) 
									AND RC.idestatus = NVL(p_iIdEstatus, RC.idestatus)

								SELECT desasignado INTO v_sDesAsignado FROM bdirech:rec_catasignado WHERE idasignado = v_iIdAsignado;
								SELECT desconcepto INTO v_sDesConcepto FROM bdirech:rec_catconcepto WHERE idconcepto = v_iIdConcepto;
								SELECT desestatus INTO v_sDesEstatus FROM bdirech:rec_catestatus WHERE idestatus = v_iIdEstatus;
								SELECT desrecupera INTO v_sDesRecupera FROM bdirech:rec_catrecupera WHERE idrecupera = v_iIdRecupera;
								SELECT nombre INTO v_sNomEmpleado FROM bdinteg:si_ejecut WHERE ejecutivo = v_sNumEmpleado;
								SELECT nombre INTO v_sNomSucursal FROM bdinteg:si_sucursales WHERE sucursal = v_sNumSucursal;
								--SELECT NVL(saldoactual,0) INTO v_mSaldoQueb FROM bdirech:rec_movquebrantos WHERE numempleado=v_sNumEmpleado and idfaltante=v_iIdFaltante and auxiliar=v_sAuxiliar;
											
								RETURN v_sCodRet, v_sNumEmpleado, v_sNomEmpleado, v_sNumSucursal, v_sNomSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona,
								v_sNumRegional, v_iIdConcepto, v_sDesConcepto, v_iIdRecupera, v_sDesRecupera, v_iIdAsignado, v_sDesAsignado, v_iIdEstatus,
								v_sDesEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
								v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia, NVL(v_mSaldoQueb,0) WITH RESUME;
							END FOREACH
							
					ELSE
						FOREACH
								SELECT RC.numempleado, RC.numsucursal, RC.idfaltante, RC.auxiliar, RC.numzona, RC.numregional, RC.idconcepto, RC.idrecupera, RC.idasignado, 
									RC.idestatus, RC.saldoinicial, RC.descacumulado, RC.desccalculado, RC.saldoactual, RC.bancocheque, RC.fechaliquida, RC.fechaasigna, 
									RC.fecharegistro, RC.usuarioautoriza, RC.referencia, NVL(RM.saldoactual,0)
								INTO v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, v_iIdConcepto, v_iIdRecupera,
									v_iIdAsignado, v_iIdEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
									v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia, v_mSaldoQueb
								FROM bdirech:rec_confaltante RC
									INNER JOIN bdirech:rec_movquebrantos RM
									on RC.numempleado = RM.numempleado and RC.idfaltante=RM.idfaltante and 
									trim(RM.tipoperacion)=(Case when p_iIdEstatus=4 then 'SIF' ELSE 'FINALIZADO' end) --'SIF'
								WHERE idfaltante <> 0 AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numempleado = NVL(p_sNumEmpleado,numempleado)
									AND numzona = NVL(p_sNumZona,numzona) AND numregional = NVL(p_sNumRegional,numregional) 
									AND idasignado <> 1 /*(Sucursal)*/ AND fecharegistro BETWEEN NVL(p_dFechaIni,fecharegistro) AND NVL(p_dFechaFin,fecharegistro)
									AND idestatus = NVL(p_iIdEstatus, idestatus)
									--idasignado <> 1 son todas las areas que no sean sucursal.

								SELECT desasignado INTO v_sDesAsignado FROM bdirech:rec_catasignado WHERE idasignado = v_iIdAsignado;
								SELECT desconcepto INTO v_sDesConcepto FROM bdirech:rec_catconcepto WHERE idconcepto = v_iIdConcepto;
								SELECT desestatus INTO v_sDesEstatus FROM bdirech:rec_catestatus WHERE idestatus = v_iIdEstatus;
								SELECT desrecupera INTO v_sDesRecupera FROM bdirech:rec_catrecupera WHERE idrecupera = v_iIdRecupera;
								SELECT nombre INTO v_sNomEmpleado FROM bdinteg:si_ejecut WHERE ejecutivo = v_sNumEmpleado;
								SELECT nombre INTO v_sNomSucursal FROM bdinteg:si_sucursales WHERE sucursal = v_sNumSucursal;									
											
								RETURN v_sCodRet, v_sNumEmpleado, v_sNomEmpleado, v_sNumSucursal, v_sNomSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona,
								v_sNumRegional, v_iIdConcepto, v_sDesConcepto, v_iIdRecupera, v_sDesRecupera, v_iIdAsignado, v_sDesAsignado, v_iIdEstatus,
								v_sDesEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
								v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia, NVL(v_mSaldoQueb,0) WITH RESUME;
							END FOREACH
					End if
		ELSE --Consulta solo para los faltantes que no esten asignados todas las areas que no sean sucursal		
			FOREACH
				SELECT numempleado, numsucursal, idfaltante, auxiliar, numzona, numregional, idconcepto, idrecupera, idasignado, 
				idestatus, saldoinicial, descacumulado, desccalculado, saldoactual, bancocheque, fechaliquida, fechaasigna, 
				fecharegistro, usuarioautoriza, referencia
				INTO v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, v_iIdConcepto, v_iIdRecupera,
                v_iIdAsignado, v_iIdEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
 				v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia
				FROM bdirech:rec_confaltante
				WHERE idfaltante <> 0 AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numempleado = NVL(p_sNumEmpleado,numempleado)
				AND numzona = NVL(p_sNumZona,numzona) AND numregional = NVL(p_sNumRegional,numregional) 
				AND idasignado <> 1 /*(Sucursal)*/ AND fecharegistro BETWEEN NVL(p_dFechaIni,fecharegistro) AND NVL(p_dFechaFin,fecharegistro)
				AND idestatus = NVL(p_iIdEstatus, idestatus)
				-- idasignado <> 1 son todas las areas que no sean sucursal.

				SELECT desasignado INTO v_sDesAsignado FROM bdirech:rec_catasignado WHERE idasignado = v_iIdAsignado;
				SELECT desconcepto INTO v_sDesConcepto FROM bdirech:rec_catconcepto WHERE idconcepto = v_iIdConcepto;
				SELECT desestatus INTO v_sDesEstatus FROM bdirech:rec_catestatus WHERE idestatus = v_iIdEstatus;
				SELECT desrecupera INTO v_sDesRecupera FROM bdirech:rec_catrecupera WHERE idrecupera = v_iIdRecupera;
				SELECT nombre INTO v_sNomEmpleado FROM bdinteg:si_ejecut WHERE ejecutivo = v_sNumEmpleado;
				SELECT nombre INTO v_sNomSucursal FROM bdinteg:si_sucursales WHERE sucursal = v_sNumSucursal;	
				--SELECT NVL(saldoactual,0) INTO v_mSaldoQueb FROM bdirech:rec_movquebrantos WHERE numempleado=v_sNumEmpleado and idfaltante=v_iIdFaltante and auxiliar=v_sAuxiliar;
							
				RETURN v_sCodRet, v_sNumEmpleado, v_sNomEmpleado, v_sNumSucursal, v_sNomSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona,
                v_sNumRegional, v_iIdConcepto, v_sDesConcepto, v_iIdRecupera, v_sDesRecupera, v_iIdAsignado, v_sDesAsignado, v_iIdEstatus,
				v_sDesEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
				v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia, NVL(v_mSaldoQueb,0) WITH RESUME;
			END FOREACH
		END IF
	END;
END PROCEDURE
