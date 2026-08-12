CREATE PROCEDURE "informix".spgrabarconfaltante (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdConcepto SMALLINT, p_iIdRecupera SMALLINT,
									  p_iIdAsignado SMALLINT, p_mSaldo MONEY(10,0), p_dFechaRegistro DATE, p_UsuarioAutoriza CHAR(8))
		
	RETURNING CHAR(5) AS retorno, SMALLINT AS Numfaltante, CHAR (26) AS Referencia;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(5);
	DEFINE v_iIdfaltante	SMALLINT;
	DEFINE v_sAuxiliar		CHAR(12);
	DEFINE v_sNumZona		CHAR(3);
	DEFINE v_sNumRegional	CHAR(3);
	DEFINE v_cReferencia	CHAR(26);
	DEFINE v_cDia 			CHAR(2);
	DEFINE v_cMes 			CHAR(2);
	DEFINE v_cAnio 			CHAR(4);
	DEFINE v_cHora 			CHAR(2);
    DEFINE v_cMinutos 		CHAR(2);
	DEFINE v_cSegundos		CHAR(2);
	DEFINE v_cHoraMinSec	DATETIME HOUR TO SECOND;
	--------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/prisma/spgrabarconfaltante.out"; ";
	--TRACE ON;
	--------------------------------------------------------------------

	LET v_sValRetorno = '00001';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
		
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;		
				RETURN v_sValRetorno, '0','';
			END IF;
		END EXCEPTION;	

			
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sNumEmpleado,'') = '' OR NVL(p_sNumSucursal,'') = '' OR NVL(p_iIdConcepto,'') = ''
			OR NVL(p_iIdRecupera,'') = '' OR NVL(p_iIdAsignado,'') = '' OR NVL(p_dFechaRegistro,'') = '' 
			OR NVL(p_mSaldo,'') = '' OR p_mSaldo = 0 THEN
			RETURN v_sValRetorno, '0','';
		END IF;
		
		LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;
		
		-- OBTIENE EL NUMERO DE FALTANTES DE UN EMPLEADO.
		SELECT NVL(MAX(idfaltante), 0) + 1 INTO v_iIdfaltante FROM bdirech:rec_confaltante WHERE numempleado = p_sNumEmpleado;
	
		SELECT plaza
		INTO v_sNumZona
		FROM bdinteg:si_sucursales
		WHERE sucursal = p_sNumSucursal;
		
		SELECT regional
		INTO v_sNumRegional
		FROM bdinteg:si_plazas
		WHERE plaza = v_sNumZona;
		
		IF NOT EXISTS (SELECT 1 FROM bdirech:rec_confaltante WHERE idfaltante = v_iIdfaltante AND numempleado = p_sNumEmpleado) THEN			
			--Crea la cadena de referencia
			LET v_cDia = LPAD(DAY(p_dFechaRegistro),2,'0');
			LET v_cMes = LPAD(MONTH(p_dFechaRegistro),2,'0');
			LET v_cAnio = YEAR(p_dFechaRegistro);
			LET v_cHoraMinSec = CURRENT;
			LET v_cHora = SUBSTRING(v_cHoraMinSec FROM 1 FOR 2);
			LET v_cMinutos = SUBSTRING(v_cHoraMinSec FROM 4 FOR 5); 
			LET v_cSegundos = SUBSTRING(v_cHoraMinSec FROM 7 FOR 8);			
			
			LET v_cReferencia = p_sNumSucursal  || p_sNumEmpleado || v_cDia || v_cMes || v_cAnio || v_cHora || v_cMinutos || v_cSegundos;
			
			
			INSERT INTO bdirech:rec_confaltante (numempleado, numsucursal, idfaltante, auxiliar, numzona,
			numregional, idconcepto, idrecupera, idasignado, idestatus, saldoinicial,descacumulado, desccalculado,
			saldoactual, bancocheque, fechaliquida, fechaasigna, fecharegistro, usuarioautoriza, referencia)
			VALUES (p_sNumEmpleado, p_sNumSucursal, v_iIdfaltante, v_sAuxiliar, v_sNumZona, 
			v_sNumRegional, p_iIdConcepto, p_iIdRecupera, p_iIdAsignado, 1, p_mSaldo, '0.00', '0.00',
			p_mSaldo, '', '', '', p_dFechaRegistro, p_UsuarioAutoriza, v_cReferencia);
						
			LET v_sValRetorno = '00000';
					
		ELSE
			LET v_sValRetorno = '00002';
		END IF;
		
		RETURN v_sValRetorno, v_iIdfaltante, v_cReferencia;
	END;    
END PROCEDURE

