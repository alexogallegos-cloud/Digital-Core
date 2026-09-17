CREATE PROCEDURE "informix".sp_obtiene_montoac_pr(pNumCelular CHAR(10))
   returning CHAR(5),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2);


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
	DEFINE dMontoAcumuladoMesN2 DECIMAL(16,2);
	DEFINE dMontoAcumuladoDiaN2 DECIMAL(16,2);
	DEFINE dFechaRegMesN2 DATETIME YEAR TO SECOND;
	DEFINE dFechaRegDiaN2 DATETIME YEAR TO SECOND;
	
	LET cCodRet  = '00000';
	LET dMontoAcumuladoMes  =0;
	LET dMontoAcumuladoDia =0;
	LET dMontoAcumuladoMesN2  =0;
	LET dMontoAcumuladoDiaN2 =0;
	LET iMesActual  =0;
	LET iDiaActual  =0;
	 
	
  --SET DEBUG FILE TO "/tmp/sp_obtiene_montoac_pr.out";
  --TRACE ON;
  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
            RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia,dMontoAcumuladoMesN2,dMontoAcumuladoDiaN2;
	  END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pNumCelular,'')='')THEN
		LET cCodRet = '00001';
		RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia,dMontoAcumuladoMesN2,dMontoAcumuladoDiaN2;
	END IF;
	
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = '001';
    
    LET iMesActual = MONTH(dFechaHoy);
	LET iDiaActual = DAY(dFechaHoy);
	
	
	SELECT monto_acumulado,fecha 
	INTO dMontoAcumuladoMes,dFechaRegMes
	FROM bdibpi:"informix".pr_control_trans
	WHERE num_celular=pNumCelular;
	
	SELECT monto_acumulado_dia,fecha 
	INTO dMontoAcumuladoDia,dFechaRegDia
	FROM bdibpi:"informix".pr_control_trans
	WHERE num_celular=pNumCelular;
	
	SELECT monto_acumulado,fecha 
	INTO dMontoAcumuladoMesN2,dFechaRegMesN2
	FROM bdibpi:"informix".pr_cuentasniveldos_monto_acumulado
	WHERE num_celular=pNumCelular;
	
	SELECT monto_acumulado_dia,fecha 
	INTO dMontoAcumuladoDiaN2,dFechaRegDiaN2
	FROM bdibpi:"informix".pr_cuentasniveldos_monto_acumulado
	WHERE num_celular=pNumCelular;
	
	--SE VALIDA N4
	IF NVL(dMontoAcumuladoMes,-1)=-1 AND NVL(dMontoAcumuladoDia,-1)=-1 THEN--SE VALIDA SI NO EXISTE REGISTRO LO INICIALIZA
		INSERT INTO bdibpi:"informix".pr_control_trans(num_celular,monto_acumulado,fecha,monto_acumulado_dia)
		VALUES(pNumCelular,0,CURRENT,0);
		LET dMontoAcumuladoMes=0;
		LET dMontoAcumuladoDia=0;
	ELSE
		IF MONTH(dFechaRegMes)<iMesActual THEN--SE VALIDA QUE SEA EL MES ACTUAL, SI NO ACTUALIZA EL REGISTRO A MONTO CERO
			UPDATE bdibpi:"informix".pr_control_trans SET monto_acumulado=0 , fecha=dFechaHoy
			WHERE num_celular=pNumCelular;
			LET dMontoAcumuladoMes=0;
		END IF;
		
		IF DAY(dFechaRegDia)<iDiaActual THEN--SE VALIDA QUE SEA EL DIA ACTUAL, SI NO ACTUALIZA EL REGISTRO A MONTO CERO
			UPDATE bdibpi:"informix".pr_control_trans SET monto_acumulado_dia=0 , fecha=dFechaHoy
			WHERE num_celular=pNumCelular;
			LET dMontoAcumuladoDia=0;
		END IF;
	END IF;
	
	--SE VALIDA N2
	IF NVL(dMontoAcumuladoMesN2,-1)=-1 AND NVL(dMontoAcumuladoDiaN2,-1)=-1 THEN--SE VALIDA SI NO EXISTE REGISTRO LO INICIALIZA
		INSERT INTO bdibpi:"informix".pr_cuentasniveldos_monto_acumulado(num_celular,monto_acumulado,fecha,monto_acumulado_dia)
		VALUES(pNumCelular,0,CURRENT,0);
		LET dMontoAcumuladoMesN2=0;
		LET dMontoAcumuladoDiaN2=0;
	ELSE
		IF MONTH(dFechaRegMesN2)<iMesActual THEN--SE VALIDA QUE SEA EL MES ACTUAL, SI NO ACTUALIZA EL REGISTRO A MONTO CERO
			UPDATE bdibpi:"informix".pr_cuentasniveldos_monto_acumulado SET monto_acumulado=0 , fecha=dFechaHoy
			WHERE num_celular=pNumCelular;
			LET dMontoAcumuladoMesN2=0;
		END IF;
		
		IF DAY(dFechaRegDiaN2)<iDiaActual THEN--SE VALIDA QUE SEA EL DIA ACTUAL, SI NO ACTUALIZA EL REGISTRO A MONTO CERO
			UPDATE bdibpi:"informix".pr_cuentasniveldos_monto_acumulado SET monto_acumulado_dia=0 , fecha=dFechaHoy
			WHERE num_celular=pNumCelular;
			LET dMontoAcumuladoDiaN2=0;
		END IF;
	END IF;
	
    RETURN cCodRet,dMontoAcumuladoMes,dMontoAcumuladoDia,dMontoAcumuladoMesN2,dMontoAcumuladoDiaN2;
   
END 

END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 30/06/2015',
'MODIFICACIÃN..: Se crea stored procedure,para validar el monto acumulado del cliente por mes',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI',

'FOLIO.........:  - ProyectoRayo',
'MODIFICÃ......: Keevyn Adrian Gil Valenzuela',
'FECHA.........: 19/05/2017',
'MODIFICACIÃN..: Se modifica stored procedure, para validar tambien el monto acumulado del cliente por dia',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI',

'FOLIO.........:  - Proyecto B-Ya',
'MODIFICÃ......: Jesus Mercado Alvarez',
'FECHA.........: 27/04/2019',
'MODIFICACIÃN..: Se modifica stored procedure, para validar tambien los montos acumulados del cliente con cuenta N2',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_actualizaservbasico(pNumCte char(9))
RETURNING char(5);
   
   -- CreaciÃ³n: Solser
   -- DescripciÃ³n: Actualiza la tabla: bdibpi:bpi_serviciobasico 
   -- y el tipo de servicio en la tabla: bdinteg:si_bpiusuarios
   -- SolicitÃ³: BanCoppel
   -- Fecha: 16/04/2020 
 
-- ***************************************************************************
-- DefiniciÃ³n de variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;
   DEFINE cantidad integer;

-- ***************************************************************************
-- InicializaciÃ³n de variables
-- ***************************************************************************
   LET cod_ret = "00000";

   
   
   Set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
      END IF;
   END EXCEPTION;
   

    IF (NVL(pNumCte, 0) == 0) OR (pNumCte IS NULL) THEN		
        LET cod_ret = '00001';  -- El parametro de entrada no es valido
    ELSE
		SELECT COUNT (*) INTO cantidad FROM bdibpi:bpi_serviciobasico WHERE numcte = pNumCte;
	
			IF (cantidad>0) THEN
			
				UPDATE bdibpi:bpi_serviciobasico
				SET id_control = 2, id_entendimiento = 1, f_entendimiento = SYSDATE
				WHERE numcte = pNumCte;

				UPDATE bdinteg:si_bpiusuarios
				SET servicio = 2
				WHERE numcte = pNumCte;

				LET cod_ret = '00000';
			ELSE
				LET cod_ret = '00001';  -- No existe el cliente
			END IF;
    END IF;

    RETURN cod_ret;

END

END PROCEDURE;