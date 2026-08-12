CREATE PROCEDURE "informix".spconsultarmovfaltante (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdFaltante SMALLINT,
										 p_dFechaInicial DATE, p_dFechaFinal DATE)
RETURNING CHAR(5)     AS CodigoRetorno,
		  CHAR(8)     AS NumeroEmpleado,
		  CHAR(4)     AS NumeroSucursal,
		  SMALLINT    AS IdFaltante,
		  SMALLINT    AS IdMovimiento,
		  CHAR(1)     AS TipoMovimiento,
		  CHAR(12)    AS Auxiliar,
		  SMALLINT    AS IdRecupera,

		  CHAR(80)	  AS DescRecupera,
		  MONEY(10,0) AS MontoMovimiento,
		  MONEY(10,0) AS SaldoMovimiento,
		  DATE        AS FechaRegistro,
		  CHAR(4)	  AS Transaccion,
		  CHAR(1)     AS Contable,
		  CHAR(8)     AS UsuarioAutoriza,
		  CHAR(26)	  AS Referencia,
		  CHAR(80)	  AS DesConcepto,
		  CHAR(4)     AS SucursalPago;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sCodRet       	CHAR(5);
	DEFINE v_sNumEmpleado 	CHAR(8);
	DEFINE v_sNumSucursal	CHAR(4);
	DEFINE v_iIdFaltante	SMALLINT;
	DEFINE v_iIdMovimiento	SMALLINT;
	DEFINE v_sTipoMov		CHAR(1);
	DEFINE v_sAuxiliar		CHAR(12);
	DEFINE v_iIdRecupera	SMALLINT;
	DEFINE v_iIdConcepto	SMALLINT;
	DEFINE v_sDescRecupera	CHAR(80);
	DEFINE v_mMontoMov		MONEY(10,0);
	DEFINE v_mSaldoMov		MONEY(10,0);
	DEFINE v_mSaldoTotal	MONEY(10,0);
	DEFINE v_mCargoTotal	MONEY(10,0);		
	DEFINE v_mAbonoTotal	MONEY(10,0);
	DEFINE v_dFechaRegistro DATE;
	DEFINE v_dFechaLiquida	DATE;
	DEFINE v_sTransaccion 	CHAR(4);
	DEFINE v_sContable		CHAR(1);
	DEFINE v_sUsuarioAutoriza CHAR(8);
	DEFINE v_sReferencia	CHAR(26);
	DEFINE v_sTransacFaltante	CHAR(4);
	DEFINE v_sTransacElimina 	CHAR(4);
	DEFINE v_sTransacRobo		CHAR(4);
	DEFINE v_sDesConcepto		CHAR(80);
	DEFINE v_sSucursalPago		CHAR(4);
	
	--SET DEBUG FILE TO "/tmp/mfinis/spconsultarmovfaltante.out"; 
	--TRACE ON;
	
	
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '','','','','';
			END IF;
		END EXCEPTION;

		LET v_sCodRet = '00002';
		
		LET v_sNumEmpleado = '';
		LET v_sNumSucursal = '';
		LET v_iIdFaltante = 0;
		LET v_iIdMovimiento = 0;
		LET v_sTipoMov = '';
		LET v_sAuxiliar = '';
		LET v_iIdRecupera = 0;
		LET v_mMontoMov = 0;
		LET v_mSaldoMov = 0;
		LET v_mSaldoTotal = 0;
		LET v_mCargoTotal = 0;
		LET v_mAbonoTotal = 0;
		LET v_dFechaRegistro = '';
		LET v_sTransaccion = '';
		LET v_sContable = '';
				
		--// ********************************************************************
		--// Valida parÃ¡metros de entrada, la fecha es obligatria
		--// ********************************************************************
		
		IF NVL(p_dFechaInicial, '') = '' OR NVL(p_dFechaFinal, '') = ''  OR NVL(p_sNumEmpleado, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '','','','','';
		END IF
				
		IF p_sNumSucursal = '' THEN
			LET p_sNumSucursal = NULL;
		END IF
		
		IF p_iIdFaltante = '' THEN
			LET p_iIdFaltante = NULL;
		END IF
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT valor INTO v_sTransacFaltante FROM bdirech:"informix".rec_param WHERE secuencia = 4;
		SELECT valor INTO v_sTransacElimina FROM bdirech:"informix".rec_param WHERE secuencia = 5;
		SELECT valor INTO v_sTransacRobo FROM bdirech:"informix".rec_param WHERE secuencia = 6;
		
		FOREACH 
			SELECT numsucursal, idfaltante, idrecupera, fechaliquida, idconcepto 
			INTO v_sNumSucursal, v_iIdFaltante, v_iIdRecupera, v_dFechaLiquida, v_iIdConcepto
			FROM bdirech:"informix".rec_confaltante WHERE numempleado = p_sNumEmpleado AND idfaltante = NVL(p_iIdFaltante, idfaltante) 
			AND fecharegistro BETWEEN p_dFechaInicial AND p_dFechaFinal 
			ORDER BY idfaltante
			
			SELECT desrecupera INTO v_sDescRecupera FROM bdirech:"informix".rec_catrecupera WHERE idrecupera = v_iIdRecupera;
			SELECT desconcepto INTO v_sDesConcepto FROM bdirech:"informix".rec_catconcepto WHERE idconcepto = v_iIdConcepto;
			LET v_sCodRet = '00000';
			
			FOREACH
				SELECT idmovimiento, tipomovimiento, auxiliar, montomovimiento, fecharegistro, transaccion, contable, usuarioautoriza,
						referencia,sucursalpago
				INTO v_iIdMovimiento, v_sTipoMov, v_sAuxiliar, v_mMontoMov, v_dFechaRegistro, v_sTransaccion, v_sContable, v_sUsuarioAutoriza,
				v_sReferencia,v_sSucursalPago
				FROM bdirech:"informix".rec_movfaltante WHERE numempleado = p_sNumEmpleado AND idfaltante = v_iIdFaltante
				AND fecharegistro BETWEEN p_dFechaInicial AND p_dFechaFinal 
				ORDER BY idmovimiento				
								
				IF v_sTipoMov = 'C' THEN				
					LET v_mCargoTotal = v_mMontoMov;
					LET v_mSaldoMov = v_mMontoMov;
					LET v_mSaldoTotal = v_mSaldoTotal + v_mMontoMov;
					LET v_mAbonoTotal = 0;
					
				ELIF v_sTipoMov = 'A' THEN				
					LET v_mAbonoTotal = v_mAbonoTotal + v_mMontoMov;
					LET v_mSaldoMov = v_mSaldoMov - v_mMontoMov;
					LET v_mSaldoTotal = v_mSaldoTotal - v_mMontoMov;
					
					--IF v_mCargoTotal <> v_mAbonoTotal THEN						
					--	LET v_dFechaRegistro = '';
					--END IF
					LET v_sDesConcepto = 'Pago';
				ELIF v_sTipoMov = 'F' THEN
					IF v_sTransaccion = v_sTransacFaltante OR v_sTransaccion = v_sTransacRobo THEN
						LET v_sTipoMov = 'C'; --Para que se presente como cargo negativo sin validar en pantalla
						LET v_mSaldoMov = 0;						
						LET v_mSaldoTotal = v_mSaldoTotal + v_mMontoMov;
						LET v_mAbonoTotal = 0;
						
					ELIF v_sTransaccion = v_sTransacElimina THEN
						LET v_sTipoMov = 'A'; --Para que se presente como abono negativo sin validar en pantalla
						LET v_mAbonoTotal = v_mAbonoTotal + v_mMontoMov;
						LET v_mSaldoMov = v_mSaldoMov - v_mMontoMov;
						LET v_mSaldoTotal = v_mSaldoTotal - v_mMontoMov;						
					END IF
					LET v_sDesConcepto = 'Reverso';					
					--LET v_dFechaRegistro = '';
				END IF									
								
				RETURN v_sCodRet, p_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_iIdMovimiento, v_sTipoMov, v_sAuxiliar, v_iIdRecupera,
				v_sDescRecupera, v_mMontoMov, v_mSaldoMov, v_dFechaRegistro, v_sTransaccion, v_sContable, v_sUsuarioAutoriza, v_sReferencia, 
				v_sDesConcepto,v_sSucursalPago WITH RESUME;				
			END FOREACH;			
		END FOREACH;
		
		IF v_sCodRet = '00000' THEN
			RETURN v_sCodRet, '', '', '', '-1', 'T', '', '', '', v_mSaldoTotal, '', '', '', '', '', '','','';
		ELSE
			RETURN v_sCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '','', '','','';
		END IF
	END
END PROCEDURE
