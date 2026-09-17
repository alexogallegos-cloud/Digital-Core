CREATE PROCEDURE "informix".spgrabarconfalsuc(p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdConcepto SMALLINT, p_iIdRecupera SMALLINT,
p_iIdAsignado SMALLINT, p_mSaldo MONEY(10,2), p_dFechaRegistro DATE, p_sUsuarioAutoriza CHAR(8), p_sTransaccion CHAR(4), p_sFolioSucursal CHAR(16))

	RETURNING CHAR(5) AS retorno, SMALLINT AS Numfaltante, CHAR (26) AS Referencia;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(5);
	DEFINE v_iIdfaltante	SMALLINT;
	DEFINE v_sAuxiliar		CHAR(12);
	DEFINE v_sNumZona		CHAR(3);
	DEFINE v_sNumRegional	CHAR(3);
	DEFINE v_sReferencia	CHAR(26);
	DEFINE v_sDia 			CHAR(2);
	DEFINE v_sMes 			CHAR(2);
	DEFINE v_sAnio 			CHAR(4);
	DEFINE v_sHora 			CHAR(2);
    DEFINE v_sMinutos 		CHAR(2);
	DEFINE v_sSegundos		CHAR(2);
	DEFINE v_dHoraMinSec	DATETIME HOUR TO SECOND;
	DEFINE v_iTransaccion	INTEGER;
	DEFINE v_sSucFaltante   CHAR(4);
	
	LET v_iTransaccion = 0;
	
	--------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/spgrabarconfalsuc.out"; ";
	--TRACE ON;
	--------------------------------------------------------------------
		
	BEGIN
		ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET v_sValRetorno = iSqlErr;
			IF v_iTransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			RETURN v_sValRetorno, '0','';
		END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET v_iTransaccion = 1;
		END EXCEPTION WITH resume;
		
		IF v_iTransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sNumEmpleado,'') = '' OR NVL(p_sNumSucursal,'') = '' OR NVL(p_iIdConcepto,'') = '' OR NVL(p_iIdRecupera,'') = '' 
		OR NVL(p_iIdAsignado,'') = ''  OR NVL(p_dFechaRegistro,'') = '' OR NVL(p_mSaldo,'') = '' OR p_mSaldo = 0 
		OR NVL(p_sUsuarioAutoriza,'') = '' OR NVL(p_sTransaccion,'') = '' OR NVL(p_sFolioSucursal,'') = '' THEN
			LET v_sValRetorno = '00055';
			RETURN v_sValRetorno, '0','';
		END IF;
		
		-- OBTIENE EL NUMERO DE FALTANTES DE UN EMPLEADO.
		SELECT NVL(MAX(idfaltante), 0) + 1 INTO v_iIdfaltante FROM bdirech:"informix".rec_confaltante WHERE numempleado = p_sNumEmpleado;
		-- OBTIEN EL NÚMERO DE PLAZA
		SELECT plaza INTO v_sNumZona FROM bdinteg:"informix".si_sucursales WHERE sucursal = p_sNumSucursal;
		-- OBTIENE EL NÚMERO DE REGION
		SELECT regional INTO v_sNumRegional FROM bdinteg:"informix".si_plazas WHERE plaza = v_sNumZona;
					
		--Crea la cadena de referencia
		LET v_sDia = LPAD(DAY(p_dFechaRegistro),2,'0');
		LET v_sMes = LPAD(MONTH(p_dFechaRegistro),2,'0');
		LET v_sAnio = YEAR(p_dFechaRegistro);
		LET v_dHoraMinSec = CURRENT;
		LET v_sHora = SUBSTRING(v_dHoraMinSec FROM 1 FOR 2);
		LET v_sMinutos = SUBSTRING(v_dHoraMinSec FROM 4 FOR 5); 
		LET v_sSegundos = SUBSTRING(v_dHoraMinSec FROM 7 FOR 8);			
		
		LET v_sReferencia = p_sNumSucursal  || p_sNumEmpleado || v_sDia || v_sMes || v_sAnio || v_sHora || v_sMinutos || v_sSegundos;
		LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;
		
		INSERT INTO bdirech:"informix".rec_confaltante (numempleado, numsucursal, idfaltante, auxiliar, numzona,
		numregional, idconcepto, idrecupera, idasignado, idestatus, saldoinicial,descacumulado, desccalculado,
		saldoactual, bancocheque, saldodec, fechaliquida, fechaasigna, fecharegistro, usuarioautoriza, referencia)
		VALUES (p_sNumEmpleado, p_sNumSucursal, v_iIdfaltante, v_sAuxiliar, v_sNumZona, 
		v_sNumRegional, p_iIdConcepto, p_iIdRecupera, p_iIdAsignado, 1, p_mSaldo, '0.00', '0.00',
		p_mSaldo,'', p_mSaldo, '','', p_dFechaRegistro, p_sUsuarioAutoriza, v_sReferencia);
		
		INSERT INTO bdirech:"informix".rec_movfaltante 
		(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar, idrecupera,  
         montomovimiento, fecharegistro, contable, usuarioautoriza, referencia, foliosuc, sucursalpago)
		VALUES (p_sNumEmpleado, p_sNumSucursal, v_iIdfaltante, p_sTransaccion, '0', 'C', v_sAuxiliar, p_iIdRecupera, 
        p_mSaldo, p_dFechaRegistro, '0', p_sUsuarioAutoriza, v_sReferencia, p_sFolioSucursal, '');
		
		LET v_sValRetorno = '00000';
		
		IF v_iTransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			COMMIT WORK;
		END IF;
		
		RETURN v_sValRetorno, v_iIdfaltante, v_sReferencia;
	END;    
END PROCEDURE

