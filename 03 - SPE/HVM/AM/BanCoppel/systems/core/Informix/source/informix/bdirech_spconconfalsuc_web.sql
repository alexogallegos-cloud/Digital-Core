CREATE PROCEDURE "informix".spconconfalsuc_web(p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdConcepto CHAR(1), p_iIdEstatus CHAR(1), p_iRegistros SMALLINT)

RETURNING CHAR(5) AS CodigoRetorno, CHAR(8) AS NumEmpleado, CHAR(45) AS NomEmpleado, CHAR(4) AS Sucursal, CHAR(40) AS NomSucursal, SMALLINT AS IdFaltante, 
CHAR(12) AS Auxiliar, CHAR(3) AS NumZona,  CHAR(3) AS NumRegion, SMALLINT AS IdConcepto, CHAR(80) AS DesConcepto, SMALLINT AS IdRecupera, CHAR(80) AS DesRecupera,
SMALLINT AS IdAsignado, CHAR(80) AS DesAsignado, SMALLINT AS IdEstatus, CHAR(80) AS DesEstatus, MONEY(10,2)AS SaldoInicial,  MONEY(10,2)AS DescAcumulado, 
MONEY(10,2)AS DescCalculado, MONEY(10,2)AS SaldoActual, CHAR(40) AS BancoCheque, DATE AS FechaLiquida, DATE AS FechaAsigna, DATE AS FechaRegistro, 
CHAR(8) AS UsuarioAutoriza, CHAR(26) AS Referencia

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
	DEFINE v_mSaldoInicial	MONEY(10,2); 
	DEFINE v_mDescAcumulado MONEY(10,2); 
	DEFINE v_mDescCalculado MONEY(10,2); 
	DEFINE v_mSaldoActual 	MONEY(10,2); 
	DEFINE v_sBancoCheque 	CHAR(40); 
	DEFINE v_dFechaLiquida 	DATE; 
	DEFINE v_dFechaAsigna 	DATE;         
	DEFINE v_dFechaRegistro	DATE;
	DEFINE v_sUsuarioAutoriza CHAR(8);
	DEFINE v_sReferencia 	CHAR(26);
	
	--SET DEBUG FILE TO "/dbexportb/Fabiola/spconconfalsuc.out"; 
	--TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;		
				
		IF NVL(p_sNumEmpleado,'') = '' THEN
			LET p_sNumEmpleado = NULL;
		END IF
		
		IF NVL(p_sNumSucursal,'') = '' THEN 
			LET p_sNumSucursal = NULL;
		END IF
		
		IF NVL(p_iIdConcepto,'') = '' THEN
			LET p_iIdConcepto = NULL;
		END IF 
		
		IF NVL(p_iIdEstatus,'') = '' THEN
			LET p_iIdEstatus = NULL;
		END IF 
		
		IF NVL(p_iRegistros,'') = '' THEN
			LET p_iRegistros = 0;
		END IF		
				
		FOREACH
			SELECT --{+ INDEX (rec_confaltante rec_confaltante)} {+ INDEX (rec_confaltante idx_sucempbdicheq)}
			SKIP p_iRegistros numempleado, numsucursal, idfaltante, auxiliar, numzona, numregional, idconcepto, idrecupera, idasignado, 
			idestatus, saldoinicial, descacumulado, desccalculado, saldoactual, bancocheque, fechaliquida, fechaasigna, fecharegistro, 
			usuarioautoriza, referencia
			INTO v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, v_iIdConcepto, v_iIdRecupera, v_iIdAsignado, 
			v_iIdEstatus, 
			v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida, v_dFechaAsigna, v_dFechaRegistro, 
			v_sUsuarioAutoriza, v_sReferencia
			FROM bdirech:rec_confaltante
			WHERE idconcepto = NVL(p_iIdConcepto, idconcepto) AND idestatus = NVL(p_iIdEstatus, idestatus)
			AND numempleado = NVL(p_sNumEmpleado, numempleado) AND numsucursal = NVL(p_sNumSucursal, numsucursal) 				
			 
									
			SELECT desasignado INTO v_sDesAsignado FROM bdirech:rec_catasignado WHERE idasignado = v_iIdAsignado;
			SELECT desconcepto INTO v_sDesConcepto FROM bdirech:rec_catconcepto WHERE idconcepto = v_iIdConcepto;
			SELECT desestatus INTO v_sDesEstatus FROM bdirech:rec_catestatus WHERE idestatus = v_iIdEstatus;
			SELECT desrecupera INTO v_sDesRecupera FROM bdirech:rec_catrecupera WHERE idrecupera = v_iIdRecupera;
			SELECT nombre INTO v_sNomEmpleado FROM bdinteg:si_ejecut WHERE ejecutivo = v_sNumEmpleado;
			SELECT nombre INTO v_sNomSucursal FROM bdinteg:si_sucursales WHERE sucursal = v_sNumSucursal;				
			LET v_sCodRet = '00000';				
			
			RETURN v_sCodRet, v_sNumEmpleado, v_sNomEmpleado, v_sNumSucursal, v_sNomSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, v_iIdConcepto, 
			v_sDesConcepto, v_iIdRecupera, v_sDesRecupera, v_iIdAsignado, v_sDesAsignado, v_iIdEstatus,	v_sDesEstatus, v_mSaldoInicial, v_mDescAcumulado, 
			v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida, v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia WITH RESUME;
		END FOREACH		
	END;
END PROCEDURE
