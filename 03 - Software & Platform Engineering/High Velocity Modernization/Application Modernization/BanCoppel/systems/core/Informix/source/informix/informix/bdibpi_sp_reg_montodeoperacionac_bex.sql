CREATE PROCEDURE "informix".sp_reg_montodeoperacionac_bex(pNumCelular CHAR(10), pNumCte CHAR(10), pMonto  DECIMAL(16,2))
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
	
	
	LET cCodRet  = '00000';
	LET dMontoAcumuladoMes  =0;
	LET dMontoAcumuladoDia =0;
	LET iMesActual  =0;
	LET iDiaActual  =0;
	 
	
  --SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_reg_montodeoperacionac_bex.out";
  --TRACE ON;
  
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
		LET cCodRet = '00001'; --FALTAN DATOS
		RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia;
	END IF;

	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = '001';
    
    LET iMesActual = MONTH(dFechaHoy);
	LET iDiaActual = DAY(dFechaHoy);
	
	IF EXISTS(SELECT num_celular,num_cte FROM bdibpi:"informix".bpi_control_trans_bex WHERE num_celular=pNumCelular AND num_cte = pNumCte) THEN 
	
		--SE ACTUALIZA ACUMULADO DE ORIGEN
		SELECT monto_acumulado  
		INTO dMontoAcumuladoMes
		FROM bdibpi:"informix".bpi_control_trans_bex
		WHERE num_celular=pNumCelular AND num_cte = pNumCte;

		LET dMontoAcumuladoMes=dMontoAcumuladoMes+pMonto;
		UPDATE bdibpi:"informix".bpi_control_trans_bex SET monto_acumulado=dMontoAcumuladoMes
		WHERE num_celular=pNumCelular AND num_cte = pNumCte;
		
		--SE ACTUALIZA ACUMULADO DE ORIGEN DIA
		SELECT monto_acumulado_dia   
		INTO dMontoAcumuladoDia
		FROM bdibpi:"informix".bpi_control_trans_bex
		WHERE num_celular=pNumCelular AND num_cte = pNumCte;

		LET dMontoAcumuladoDia=dMontoAcumuladoDia+pMonto;
		UPDATE bdibpi:"informix".bpi_control_trans_bex SET monto_acumulado_dia=dMontoAcumuladoDia
		WHERE num_celular=pNumCelular AND num_cte = pNumCte;
	ELSE
		LET cCodRet = '00002'; --NO EXITE REGISTRO
	END IF;
	
	
    RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia;
   
END

END PROCEDURE
;