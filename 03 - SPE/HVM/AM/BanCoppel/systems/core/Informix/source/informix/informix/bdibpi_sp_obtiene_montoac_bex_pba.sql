CREATE PROCEDURE "informix".sp_obtiene_montoac_bex_pba(pNumCelular CHAR(10), pNumCte CHAR(10))
   returning CHAR(5),DECIMAL(16,2),DECIMAL(16,2);


    DEFINE sql_err INTEGER ;
    DEFINE cCodRet CHAR(5);
	DEFINE dMontoAcumuladoMes DECIMAL(16,2);
	DEFINE dMontoAcumuladoDia DECIMAL(16,2);
	DEFINE dFechaRegMes DATETIME YEAR TO SECOND;
	DEFINE dFechaRegDia DATETIME YEAR TO SECOND;
	DEFINE dFechaReg DATETIME YEAR TO SECOND;
	DEFINE dFechaHoy DATETIME YEAR TO SECOND;
	DEFINE iMesActual INTEGER;
	DEFINE iDiaActual INTEGER;
	DEFINE iDiaReg INTEGER;
	
	LET cCodRet  = '00000';
	LET dMontoAcumuladoMes  =0;
	LET dMontoAcumuladoDia =0;
	LET iMesActual  =0;
	LET iDiaActual  =0;
	LET iDiaReg = 0;
	  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
            RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia;
	  END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pNumCelular,'')='') OR (NVL(pNumCte,'')='') THEN
		LET cCodRet = '00001';
		RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia;
	END IF;
	
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = '001';
    
    LET iMesActual = MONTH(dFechaHoy);
	LET iDiaActual = DAY(dFechaHoy);
	
	
	SELECT monto_acumulado,fecha 
	INTO dMontoAcumuladoMes,dFechaRegMes
	FROM bdibpi:"informix".bpi_control_trans_bex
	WHERE num_celular=pNumCelular AND num_cte = pNumCte;
	
	SELECT monto_acumulado_dia,fecha 
	INTO dMontoAcumuladoDia,dFechaRegDia
	FROM bdibpi:"informix".bpi_control_trans_bex
	WHERE num_celular=pNumCelular AND num_cte = pNumCte;
	
	
	LET iDiaReg = DAY(dFechaRegDia);
	
	IF NVL(dMontoAcumuladoMes,-1)=-1 AND NVL(dMontoAcumuladoDia,-1)=-1 THEN--SE VALIDA SI NO EXISTE REGISTRO LO INICIALIZA
		INSERT INTO bdibpi:"informix".bpi_control_trans_bex(num_cte,num_celular,monto_acumulado,fecha,monto_acumulado_dia,canal)
		VALUES(pNumCte,pNumCelular,0,CURRENT,0,0);
		LET dMontoAcumuladoMes=0;
		LET dMontoAcumuladoDia=0;
	ELSE
		IF YEAR(dFechaRegMes)<YEAR(dFechaHoy) THEN --VALIDA EL AÃO 
			UPDATE bdibpi:"informix".bpi_control_trans_bex SET monto_acumulado=0, monto_acumulado_dia=0, fecha=dFechaHoy
			WHERE num_cte = pNumCte 
			AND num_celular=pNumCelular;
			LET dMontoAcumuladoMes=0;
			LET dMontoAcumuladoDia=0;
		END IF;
			
		IF MONTH(dFechaRegMes)<iMesActual THEN--SE VALIDA QUE SEA EL MES ACTUAL, SI NO, ACTUALIZA EL REGISTRO A MONTO CERO
			UPDATE bdibpi:"informix".bpi_control_trans_bex SET monto_acumulado=0, monto_acumulado_dia=0 , fecha=dFechaHoy
			WHERE num_cte = pNumCte 
			AND num_celular=pNumCelular;
			LET dMontoAcumuladoMes=0;
			LET dMontoAcumuladoDia=0;
		END IF;
			
		IF dFechaRegDia<dFechaHoy THEN--SE VALIDA QUE SEA EL DIA ACTUAL, SI N, ACTUALIZA EL REGISTRO A MONTO CERO
			UPDATE bdibpi:"informix".bpi_control_trans_bex SET monto_acumulado_dia=0 , fecha=dFechaHoy
			WHERE num_cte = pNumCte 
			AND num_celular=pNumCelular;
			LET dMontoAcumuladoDia=0;
		END IF;
	END IF;
	
    RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia;
   
END

END PROCEDURE;