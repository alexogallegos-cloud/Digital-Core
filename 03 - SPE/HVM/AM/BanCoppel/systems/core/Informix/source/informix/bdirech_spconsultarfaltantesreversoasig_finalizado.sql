CREATE PROCEDURE "informix".spconsultarfaltantesreversoasig_finalizado (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4),
							p_sNumZona CHAR(3), p_sNumRegional CHAR(3), p_iIdAsignado SMALLINT, p_dFechaIni DATE, p_dFechaFin DATE)

	RETURNING CHAR(5) AS CodigoRetorno, CHAR(8) AS NumEmpleado, CHAR(45) AS NomEmpleado, CHAR(4) AS Sucursal, CHAR(40) AS NomSucursal, SMALLINT AS IdFaltante, 
		SMALLINT AS IdConcepto, CHAR(80) AS DesConcepto, SMALLINT AS IdRecupera, CHAR(80) AS DesRecupera, SMALLINT AS IdAsignado, CHAR(80) AS DesAsignado, 
		SMALLINT AS IdAsignadoAnt, SMALLINT AS IdEstatus, CHAR(80) AS DesEstatus, MONEY(10,2) AS SaldoActual,DATE AS FechaAsigna, DATE AS FechaRegistro

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sCodRet			CHAR(5);
	DEFINE v_sNumEmpleado		CHAR(8);
	DEFINE v_sNomEmpleado		CHAR(45);
	DEFINE v_sNumSucursal		CHAR(4);
	DEFINE v_sNomSucursal		CHAR(40);
	DEFINE v_iIdFaltante		SMALLINT;
	DEFINE v_iIdConcepto		SMALLINT;
	DEFINE v_sDesConcepto		CHAR(80);
	DEFINE v_iIdRecupera		SMALLINT;
	DEFINE v_sDesRecupera		CHAR(80);
	DEFINE v_iIdAsignado		SMALLINT;
	DEFINE v_sDesAsignado		CHAR(80);
	DEFINE v_iIdEstatus			SMALLINT;
	DEFINE v_sDesEstatus		CHAR(80);
	DEFINE v_iIdEstatusAnt		SMALLINT;
	DEFINE v_mSaldoActual		MONEY(10,2);
	DEFINE v_dFechaAsigna		DATE;
	DEFINE v_dFechaRegistro		DATE;

	--SET DEBUG FILE TO "/dbexport/vladi/spconsultarfaltantesreversoasig_finalizado.out"; 
	--TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'','','','','','','','','','','','','','','','','';
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

		FOREACH
			SELECT RC.numempleado, RC.numsucursal, RC.idfaltante, RC.idconcepto, RC.idrecupera, RC.idasignado, RC.idasignadoant, RC.idestatus, RC.fechaasigna, RC.fecharegistro, RM.saldoActual
				INTO v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_iIdConcepto, v_iIdRecupera, v_iIdAsignado, v_iIdEstatusAnt, v_iIdEstatus, v_dFechaAsigna, v_dFechaRegistro, v_mSaldoActual
			FROM bdirech:"informix".rec_confaltante RC
				inner join bdirech:"informix".rec_movquebrantos RM
				on RC.numempleado=RM.numempleado and RC.idfaltante=RM.idfaltante And trim(RM.tipoperacion)= 'FIN'
			WHERE RC.numempleado = NVL(p_sNumEmpleado,RC.numempleado) AND RC.idfaltante <> 0 AND RC.idconcepto <> '3' /*No robo ó asalto*/
				AND RC.idasignado = 7
				AND RC.idestatus IN(7) /*finalizado*/
				AND RC.numsucursal = NVL(p_sNumSucursal,RC.numsucursal) AND RC.numzona = NVL(p_sNumZona,RC.numzona)
				AND RC.numregional = NVL(p_sNumRegional,RC.numregional)
				AND RM.fechareg BETWEEN NVL(p_dFechaIni, RM.fechareg) AND NVL(p_dFechaFin,RM.fechareg)
			ORDER BY RC.numsucursal, RC.numempleado

			SELECT desasignado INTO v_sDesAsignado FROM bdirech:"informix".rec_catasignado WHERE idasignado = v_iIdAsignado;
			SELECT desconcepto INTO v_sDesConcepto FROM bdirech:"informix".rec_catconcepto WHERE idconcepto = v_iIdConcepto;
			SELECT desestatus INTO v_sDesEstatus FROM bdirech:"informix".rec_catestatus WHERE idestatus = v_iIdEstatus;
			SELECT desrecupera INTO v_sDesRecupera FROM bdirech:"informix".rec_catrecupera WHERE idrecupera = v_iIdRecupera;
			SELECT nombre INTO v_sNomEmpleado FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = v_sNumEmpleado;
			SELECT nombre INTO v_sNomSucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = v_sNumSucursal;
			--SELECT NVL(saldoActual,0) INTO v_mSaldoActual FROM bdirech:"informix".rec_movquebrantos where numempleado=v_sNumEmpleado and idfaltante=v_iIdFaltante And trim(tipoperacion)= 'FINALIZADO';
					
					
			RETURN v_sCodRet, v_sNumEmpleado, v_sNomEmpleado, v_sNumSucursal, v_sNomSucursal, v_iIdFaltante, v_iIdConcepto,
			v_sDesConcepto, v_iIdRecupera, v_sDesRecupera, v_iIdAsignado, v_sDesAsignado, v_iIdEstatusAnt, v_iIdEstatus,
			v_sDesEstatus, NVL(v_mSaldoActual,0), v_dFechaAsigna, v_dFechaRegistro WITH RESUME;
		END FOREACH
	END;
END PROCEDURE
;