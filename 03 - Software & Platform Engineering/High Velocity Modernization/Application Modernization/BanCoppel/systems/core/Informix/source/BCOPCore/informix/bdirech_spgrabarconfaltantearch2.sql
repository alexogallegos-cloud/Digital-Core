CREATE PROCEDURE "informix".spgrabarconfaltantearch2 (p_sUsuarioAutoriza CHAR(8), p_dFechaAsigna DATE, p_sNombreArchivo CHAR(20))
		
	RETURNING CHAR(5) AS Retorno;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(5);
	DEFINE v_iIdfaltante	SMALLINT;
	DEFINE v_sAuxiliar		CHAR(12);
	DEFINE v_sNumZona		CHAR(3);
	DEFINE v_sNumRegional	CHAR(3);
	DEFINE v_sNumSucursal   CHAR(4);
	DEFINE v_sNumEmpleado	CHAR(8);
	DEFINE v_mSaldoInicial 	MONEY(10,0);	
	DEFINE v_dFechaRegistro	DATE;
	DEFINE v_sReferencia	CHAR(26);
	DEFINE v_sDia 			CHAR(2);
	DEFINE v_sMes 			CHAR(2);
	DEFINE v_sAnio 			CHAR(4);
	DEFINE v_sHora 			CHAR(2);
	DEFINE v_sMinutos 		CHAR(2);
	DEFINE v_sSegundos		CHAR(2);
	DEFINE v_dHoraMinSec	DATETIME HOUR TO SECOND;
	DEFINE ven_transacc 	SMALLINT;
	DEFINE bInTransaction 	BOOLEAN;
	
	LET bInTransaction 		= 'f';
	LET ven_transacc 		= 0;
    LET  v_sValRetorno	='00000';
		
	--------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/mfinis/spgrabarconfaltantearch2.out";
	--TRACE ON;
	--------------------------------------------------------------------	
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;		
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				RETURN v_sValRetorno;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)			
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;	
		
		SET LOCK MODE TO WAIT 3;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sUsuarioAutoriza,'') = '' OR NVL(p_dFechaAsigna,'') = ''THEN
			LET v_sValRetorno = '00001';
			RETURN v_sValRetorno;
		END IF;		
		
		BEGIN WORK;	
			
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
			
		
			FOREACH
				SELECT numsucursal, numempleado, ROUND(saldoinicial), fecharegistro 
				INTO v_sNumSucursal, v_sNumEmpleado, v_mSaldoInicial, v_dFechaRegistro FROM bdirech:"informix".rec_faltantesarch WHERE nombrearchivo = p_sNombreArchivo 		
				
				-- OBTIENE EL NUMERO DE FALTANTES DE UN EMPLEADO.
				SELECT NVL(MAX(idfaltante), 0) + 1 INTO v_iIdfaltante FROM bdirech:"informix".rec_confaltante WHERE numempleado = v_sNumEmpleado;
				-- OBTIEN EL NÃ?MERO DE PLAZA
				SELECT plaza INTO v_sNumZona FROM bdinteg:"informix".si_sucursales WHERE sucursal = v_sNumSucursal;
				-- OBTIENE EL NÃ?MERO DE REGION
				SELECT regional INTO v_sNumRegional FROM bdinteg:"informix".si_plazas WHERE plaza = v_sNumZona;
							
				--Crea la cadena de referencia
				LET v_sDia = LPAD(DAY(v_dFechaRegistro),2,'0');
				LET v_sMes = LPAD(MONTH(v_dFechaRegistro),2,'0');
				LET v_sAnio = YEAR(v_dFechaRegistro);
				LET v_dHoraMinSec = CURRENT;
				LET v_sHora = SUBSTRING(v_dHoraMinSec FROM 1 FOR 2);
				LET v_sMinutos = SUBSTRING(v_dHoraMinSec FROM 4 FOR 5); 
				LET v_sSegundos = SUBSTRING(v_dHoraMinSec FROM 7 FOR 8);			
				
				LET v_sReferencia = v_sNumSucursal  || v_sNumEmpleado || v_sDia || v_sMes || v_sAnio || v_sHora || v_sMinutos || v_sSegundos;
				LET v_sAuxiliar = v_sNumSucursal || v_sNumEmpleado;
				
				INSERT INTO bdirech:"informix".rec_confaltante (numempleado, numsucursal, idfaltante, auxiliar, numzona, numregional, idconcepto, idrecupera, idasignado, 
				idestatus, saldoinicial, descacumulado, desccalculado, saldoactual, bancocheque, fechaliquida, fechaasigna, fecharegistro, usuarioautoriza, referencia)
				VALUES (v_sNumEmpleado, v_sNumSucursal, v_iIdfaltante, v_sAuxiliar, v_sNumZona, v_sNumRegional, '1', '2', '2', 
				'1', v_mSaldoInicial, '0', '0', v_mSaldoInicial, '', '', p_dFechaAsigna, v_dFechaRegistro, p_sUsuarioAutoriza, v_sReferencia);							
												
				INSERT INTO bdirech:"informix".rec_movfaltante 
				(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar, idrecupera, montomovimiento, 
				fecharegistro, contable, usuarioautoriza, referencia, sucursalpago)
				VALUES (v_sNumEmpleado, v_sNumSucursal, v_iIdfaltante, '0017', '0', 'C', v_sAuxiliar, '1', v_mSaldoInicial,
				v_dFechaRegistro, '0', p_sUsuarioAutoriza, v_sReferencia, v_sNumSucursal);
				
				INSERT INTO bdirech:"informix".rec_movfaltante 
				(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar, idrecupera, montomovimiento, 
				fecharegistro, contable, usuarioautoriza, referencia, sucursalpago)
				VALUES (v_sNumEmpleado, v_sNumSucursal, v_iIdfaltante, '0050', '1', 'R', v_sAuxiliar, '2', v_mSaldoInicial,
				p_dFechaAsigna, '0', p_sUsuarioAutoriza, v_sReferencia, v_sNumSucursal);
				
				LET v_sValRetorno = '00000';
			END FOREACH
			
			DELETE FROM bdirech:"informix".rec_faltantesarch WHERE nombrearchivo = p_sNombreArchivo;
			UPDATE bdirech:"informix".rec_archivos SET estatus = 1 WHERE nombrearchivo = p_sNombreArchivo;
			
		--COMMIT WORK;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN v_sValRetorno;
	END;    
END PROCEDURE

