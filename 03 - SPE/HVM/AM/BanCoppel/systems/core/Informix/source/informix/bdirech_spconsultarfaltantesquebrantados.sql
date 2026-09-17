CREATE PROCEDURE "informix".spconsultarfaltantesquebrantados (p_dFechaIni DATE, p_dFechaFin DATE)

RETURNING CHAR(5) AS CodigoRetorno, CHAR(8) AS NumEmpleado, CHAR(45) AS NomEmpleado, CHAR(4) AS Sucursal, CHAR(40) AS NomSucursal, 
SMALLINT AS IdFaltante, CHAR(12) AS Auxiliar, CHAR(3) AS NumZona, CHAR(3) AS NumRegion, SMALLINT AS IdConcepto, CHAR(80) AS DesConcepto,
SMALLINT AS IdRecupera, CHAR(80) AS DesRecupera, SMALLINT AS IdAsignado, CHAR(80) AS DesAsignado, SMALLINT AS IdEstatus, CHAR(80) AS DesEstatus,
MONEY(10,0) AS SaldoInicial, MONEY(10,0) AS DescAcumulado, MONEY(10,0) AS DescCalculado, MONEY(10,0) AS SaldoActual, CHAR(40) AS BancoCheque,	
DATE AS FechaLiquida, DATE AS FechaAsigna, DATE AS FechaRegistro, CHAR(8) AS UsuariAutoriza, CHAR(26) AS Referencia, MONEY(10,0) AS DescQuincenaFijo

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
	DEFINE v_mDescQuinFijo  MONEY(10,0); 
	DEFINE v_mSaldoActual 	MONEY(10,0); 
	DEFINE v_sBancoCheque 	CHAR(40); 
	DEFINE v_dFechaLiquida 	DATE; 
	DEFINE v_dFechaAsigna 	DATE;         
	DEFINE v_dFechaRegistro	DATE;	
	DEFINE v_sReferencia	CHAR(26);
	DEFINE v_sUsuarioAutoriza CHAR(8);
	
	--SET DEBUG FILE TO "spconsultarfaltantesquebrantados.out"; 
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
		
		IF NVL(p_dFechaIni,'')= '' OR NVL(p_dFechaFin,'') = ''THEN
			LET p_dFechaIni = NULL;
			LET p_dFechaFin = NULL;
		END IF
				
			FOREACH
				SELECT RC.numempleado, RC.numsucursal, RC.idfaltante, RC.auxiliar, RC.numzona, RC.numregional, RC.idconcepto, RC.idrecupera, RC.idasignado, 
				RC.idestatus, RC.saldoinicial, RC.descacumulado, RC.desccalculado, RC.descquincenafijo, RM.saldoactual, RC.bancocheque, RC.fechaliquida, RM.fechareg, 
				RC.fecharegistro, RC.usuarioautoriza, RC.referencia
				INTO v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, v_iIdConcepto, v_iIdRecupera,
                v_iIdAsignado, v_iIdEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mDescQuinFijo, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
 				v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia
				FROM bdirech:"informix".rec_confaltante RC 
				inner join bdirech:"informix".rec_movquebrantos RM
				ON RC.numempleado=RM.numempleado and RC.idfaltante=RM.idfaltante
				Where RM.fechareg BETWEEN NVL(p_dFechaIni,RM.fechareg) AND NVL(p_dFechaFin,RM.fechareg)
				and RC.idasignado=6
				
				SELECT desasignado INTO v_sDesAsignado FROM bdirech:"informix".rec_catasignado WHERE idasignado = v_iIdAsignado;
				SELECT desconcepto INTO v_sDesConcepto FROM bdirech:"informix".rec_catconcepto WHERE idconcepto = v_iIdConcepto;
				SELECT desestatus INTO v_sDesEstatus FROM bdirech:"informix".rec_catestatus WHERE idestatus = v_iIdEstatus;
				SELECT desrecupera INTO v_sDesRecupera FROM bdirech:"informix".rec_catrecupera WHERE idrecupera = v_iIdRecupera;
				SELECT nombre INTO v_sNomEmpleado FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = v_sNumEmpleado;
				SELECT nombre INTO v_sNomSucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = v_sNumSucursal;	
							
				RETURN v_sCodRet, v_sNumEmpleado, v_sNomEmpleado, v_sNumSucursal, v_sNomSucursal, v_iIdFaltante, v_sAuxiliar, v_sNumZona,
                v_sNumRegional, v_iIdConcepto, v_sDesConcepto, v_iIdRecupera, v_sDesRecupera, v_iIdAsignado, v_sDesAsignado, v_iIdEstatus,
				v_sDesEstatus, v_mSaldoInicial, v_mDescAcumulado, v_mDescCalculado, v_mSaldoActual, v_sBancoCheque, v_dFechaLiquida,
				v_dFechaAsigna, v_dFechaRegistro, v_sUsuarioAutoriza, v_sReferencia, v_mDescQuinFijo WITH RESUME;
			END FOREACH
		
	END;
END PROCEDURE;