CREATE PROCEDURE "informix".spconantconfalsuc (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4))

RETURNING CHAR(5) AS CodigoRetorno, CHAR(8) AS NumEmpleado, CHAR(45) AS NomEmpleado, CHAR(4) AS Sucursal, CHAR(40) AS NomSucursal, SMALLINT AS IdFaltante, CHAR(12) AS Auxiliar, CHAR(3) AS NumZona,  CHAR(3) AS NumRegion, SMALLINT AS IdConcepto, SMALLINT AS IdRecupera, SMALLINT AS IdAsignado, SMALLINT AS IdEstatus, MONEY(10,2) AS SaldoInicial,  MONEY(10,2) AS DescAcumulado, MONEY(10,2) AS DescCalculado, MONEY(10,2) AS SaldoActual, CHAR(40) AS BancoCheque, DATE AS FechaLiquida, DATE AS FechaAsigna, DATE AS FechaRegistro, CHAR(8) AS UsuarioAutoriza, CHAR(26) AS Referencia


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
	DEFINE v_iIdRecupera	SMALLINT; 	
	DEFINE v_iIdAsignado	SMALLINT; 	     	
	DEFINE v_iIdEstatus		SMALLINT; 	
	DEFINE v_mSaldoInicial	MONEY(10,2); 
	DEFINE v_mDescAcumulado MONEY(10,2); 
	DEFINE v_mDescCalculado MONEY(10,2); 
	DEFINE v_mSaldoActual 	MONEY(10,2); 
	DEFINE v_sBancoCheque 	CHAR(40); 
	DEFINE v_dFechaLiquida 	DATE; 
	DEFINE v_dFechaAsigna 	DATE;         
	DEFINE v_dFechaRegistro	DATE;	
	DEFINE v_sUsuarioAutoriza CHAR(8);
	DEFINE v_sReferencia	CHAR(26);
	
	--SET DEBUG FILE TO "/dbexportb/Fabiola/spconantconfalsuc.out"; 
	--TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00000';				
		
		IF NVL(p_sNumEmpleado,'') = '' OR NVL(p_sNumSucursal,'') = '' THEN
			LET v_sCodRet = '00055';
			RETURN v_sCodRet,'','','','','','','','','','','','','','','','','','','','','','';
		END IF
		
		FOREACH
			SELECT numempleado, numsucursal, idfaltante, auxiliar, numzona, numregional, idconcepto, idrecupera, idasignado, 
			idestatus, saldoinicial, descacumulado, desccalculado, saldoactual, bancocheque, fechaliquida, fechaasigna, 
			fecharegistro, usuarioautoriza, referencia
			INTO v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, v_iIdConcepto, v_iIdRecupera, v_iIdAsignado,
			v_iIdEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,	v_dFechaAsigna,
			v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia
			FROM bdirech:"informix".rec_confaltante
			WHERE numempleado = p_sNumEmpleado AND idfaltante = idfaltante
			AND idconcepto = 1 /*Faltante de sucursal*/AND idasignado = 1 /*A sucursal*/ AND idestatus IN (1,2) /*Aplicado, Por aplicar*/
			AND idrecupera = 1 /*Por sucursal*/ AND saldoactual > 0 /*Con saldo*/
			ORDER BY fecharegistro, idfaltante /*El más antiguo*/
			
			SELECT nombre INTO v_sNomEmpleado FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = v_sNumEmpleado;
			SELECT nombre INTO v_sNomSucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = v_sNumSucursal;	
			
			--No se pone el WITH RESUME para que solo regrese un registro, el mas antiguo por fecha de registro.
			RETURN v_sCodRet, v_sNumEmpleado, v_sNomEmpleado, v_sNumSucursal, v_sNomSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, 
			v_iIdConcepto, v_iIdRecupera, v_iIdAsignado, v_iIdEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, 
			v_sBancoCheque, v_dFechaLiquida, v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia;			
		END FOREACH
		
		LET v_sCodRet = '00053';
		RETURN v_sCodRet, '', '', '', '', 0, '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '', '' ;			
		
	END;
END PROCEDURE
