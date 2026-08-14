CREATE PROCEDURE "informix".spconsultarfaltante_reporte (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_sNumZona CHAR(3), 
										p_sNumRegional CHAR(3), p_iIdAsignado SMALLINT, p_dFechaIni DATE, 
										p_dFechaFin DATE, p_iIdEstatus SMALLINT)

RETURNING 	CHAR(8) AS numempleado, 	
			CHAR(4) AS numsucursal,
			SMALLINT AS idfaltante,			
			CHAR(45) AS nombre, 	
			DATE AS fecharegistro,			
			MONEY(10,0) AS saldoActual,			
			CHAR(10) AS estatus,
			CHAR(8) AS operador
			
			

	DEFINE iSqlErr			INTEGER;
	
	DEFINE v_sCodRet       	CHAR(5);	
	DEFINE v_sNumEmpleado	CHAR(8);
	DEFINE v_sNomEmpleado	CHAR(45);
	DEFINE v_sNumSucursal	CHAR(4);  	
	DEFINE v_iIdFaltante	SMALLINT; 		
	DEFINE v_iIdEstatus		Char(10); 			 
	DEFINE v_mSaldoQueb 	MONEY(10,0); 	    
	DEFINE v_dFechaRegistro	DATE;		
	DEFINE v_sUsuarioAutoriza CHAR(8);
	
	--SET DEBUG FILE TO "/spconsultarfaltante_reporte.out"; 
	--TRACE ON;
    
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'Error','','','','','','';
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
		
		IF p_iIdAsignado > 0 OR p_iIdAsignado IS NULL THEN --Consulta para cuando el area sea especifica o todas las areas (no asignados,  o
		--area en especifico, o todas las areas sin restrición)
			FOREACH
				SELECT RC.numempleado, RC.numsucursal, RC.idfaltante, SE.nombre, RC.fecharegistro, RM.saldoActual,RE.desestatus as estatus, 
				RM.usuarioautoriza as operador
				into v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante,v_sNomEmpleado, v_dFechaRegistro, v_mSaldoQueb, v_iIdEstatus, v_sUsuarioAutoriza
				FROM bdirech:rec_confaltante RC 
				left join bdinteg:si_ejecut SE on RC.numempleado=SE.ejecutivo 
				left join bdirech:rec_movquebrantos RM on RC.numempleado=RM.numempleado and RC.idfaltante=RM.idfaltante 
				And trim(RM.tipoperacion)=(
											Case when p_iIdEstatus=4 then 'SIF' 
												 when p_iIdEstatus=7 then 'FIN'
											ELSE RM.tipoperacion end
										   )--'SIF'
				inner join bdirech:rec_catestatus RE on RC.idestatus=RE.idestatus 				
				WHERE RC.idfaltante <> 0 AND RC.numsucursal = NVL(p_sNumSucursal,RC.numsucursal) AND RC.numempleado = NVL(p_sNumEmpleado,RC.numempleado)
				AND RC.numzona = NVL(p_sNumZona,RC.numzona) AND RC.numregional = NVL(p_sNumRegional,RC.numregional) 
				AND RC.idasignado = NVL(p_iIdAsignado, RC.idasignado) 
				AND RM.fechareg BETWEEN NVL(p_dFechaIni, RM.fechareg) AND NVL(p_dFechaFin,RM.fechareg) 
				AND RC.idestatus = NVL(p_iIdEstatus, RC.idestatus)
												
				RETURN v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante,v_sNomEmpleado, v_dFechaRegistro, nvl(v_mSaldoQueb,0), v_iIdEstatus, v_sUsuarioAutoriza WITH RESUME;
			END FOREACH
		ELSE --Consulta solo para los faltantes que no esten asignados todas las areas que no sean sucursal		
			FOREACH
				SELECT RC.numempleado, RC.numsucursal, RC.idfaltante, SE.nombre, RC.fecharegistro, RM.saldoActual,RE.desestatus as estatus, 
				RM.usuarioautoriza as operador
				into v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante,v_sNomEmpleado, v_dFechaRegistro, v_mSaldoQueb, v_iIdEstatus, v_sUsuarioAutoriza
				FROM bdirech:rec_confaltante RC 
				left join bdinteg:si_ejecut SE on RC.numempleado=SE.ejecutivo 
				left join bdirech:rec_movquebrantos RM on RC.numempleado=RM.numempleado and RC.idfaltante=RM.idfaltante 
				And trim(RM.tipoperacion)=(
											Case when p_iIdEstatus=4 then 'SIF' 
												 when p_iIdEstatus=7 then 'FIN'
											ELSE RM.tipoperacion end
										   )--'SIF'
				inner join bdirech:rec_catestatus RE on RC.idestatus=RE.idestatus
				WHERE idfaltante <> 0 AND numsucursal = NVL(p_sNumSucursal,RC.numsucursal) AND numempleado = NVL(p_sNumEmpleado,RC.numempleado)
				AND numzona = NVL(p_sNumZona,RC.numzona) AND numregional = NVL(p_sNumRegional,RC.numregional) 
				AND idasignado <> 1 /*(Sucursal)*/ AND RM.fechareg BETWEEN NVL(p_dFechaIni,RM.fechareg) AND NVL(p_dFechaFin,RM.fechareg)
				AND idestatus = NVL(p_iIdEstatus, RC.idestatus)
				-- idasignado <> 1 son todas las areas que no sean sucursal.
							
				RETURN v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante,v_sNomEmpleado, v_dFechaRegistro, nvl(v_mSaldoQueb,0), v_iIdEstatus, v_sUsuarioAutoriza WITH RESUME;
			END FOREACH
		END IF
	END;
END PROCEDURE

;