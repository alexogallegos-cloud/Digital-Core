CREATE PROCEDURE "informix".spconsultardescquincena2 (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_dFechaDescuento DATE,pRegistros INTEGER, pRecuperacion INTEGER )
RETURNING CHAR(5) AS retorno, CHAR(8) AS numempleado, CHAR(4) AS numsucursal, CHAR(12) AS auxiliar, DATE AS fechadesc,
		MONEY(10,0) AS sueldoquincena, MONEY (10,0) AS desccalculado, MONEY (10,0) AS descaplicado;

DEFINE sql_err 				INTEGER;
DEFINE v_sCodRet			CHAR(5);
DEFINE v_sAuxiliar			CHAR(12);
DEFINE v_sSucursal			CHAR(4);
DEFINE v_sEmpleado			CHAR(8);
DEFINE v_mSueldoQuincenal	MONEY(10,2);
DEFINE v_mDescCalculado		MONEY(10,2);
DEFINE v_mDescAplicado		MONEY(10,2);

 --****************************************************************
 --SET DEBUG FILE TO "/tmp/prisma/spconsultardescquincena.out"; --* 
 --TRACE ON;                                            		--*
 --****************************************************************

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				RETURN v_sCodRet,'','','','','','','';
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00000';
			
		IF NVL(p_dFechaDescuento, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet,'','','','','','','';
		END IF;
		
		IF p_sNumEmpleado = '' THEN
			LET p_sNumEmpleado = NULL;
		END IF
		
		IF p_sNumSucursal = '' THEN
			LET p_sNumSucursal = NULL;
		END IF
		
		FOREACH
		    SELECT SKIP pRegistros FIRST pRecuperacion
			numempleado, numsucursal, sueldoquincena, desccalculado, descaplicado INTO v_sEmpleado, v_sSucursal, 
				v_mSueldoQuincenal, v_mDescCalculado, v_mDescAplicado
			FROM bdirech:rec_descquincena 
			WHERE numempleado = NVL(p_sNumEmpleado, numempleado) AND numsucursal = NVL(p_sNumSucursal, numsucursal)
			AND fechadesc = p_dFechaDescuento
			
			LET v_sAuxiliar = v_sSucursal || v_sEmpleado;
			
			RETURN v_sCodRet, v_sEmpleado, v_sSucursal, v_sAuxiliar, p_dFechaDescuento, v_mSueldoQuincenal, v_mDescCalculado, v_mDescAplicado WITH RESUME;
		END FOREACH;
	END;
	
END PROCEDURE

