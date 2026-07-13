CREATE PROCEDURE "informix".sp_consulta_sac_reportediario( pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha_inicial DATE,pFecha_final DATE,pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,DATE AS FechaProceso, INTEGER AS num_mesesvent, MONEY(16,2) AS importe_vent, 
	INTEGER AS num_mesesdomi,MONEY(16,2) AS Importe_domi, INTEGER AS num_meses,MONEY(16,2) AS importe_total,MONEY(16,2) AS comision,
	MONEY(16,2) AS iva,MONEY(16,2) AS importe_pago_coppel;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotales INTEGER;
	DEFINE dFechaProceso DATE;
	DEFINE iNum_mesesvent INTEGER;
	DEFINE mImporte_vent MONEY(16,2);
	DEFINE iNum_mesesdomi INTEGER;
	DEFINE mImporte_domi MONEY(16,2);
	DEFINE iNum_meses INTEGER;
	DEFINE mImporte_total MONEY(16,2);
	DEFINE mComision MONEY(16,2);
	DEFINE mIva MONEY(16,2);
	DEFINE mImporte_pago_coppel MONEY(16,2);
    DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotales = 0;
	LET dFechaProceso=DATE(1);
	LET iNum_mesesvent =0;
	LET mImporte_vent =0;
	LEt iNum_mesesdomi=0;
	LET mImporte_domi=0;
	LET iNum_meses=0;
	LET mImporte_total=0;
	LET mComision=0;
	LET mIva=0;
	LET mImporte_pago_coppel=0;
	LET iRecuperacion=0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,iNum_meses,mImporte_domi,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_sac_reportediario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pFecha_inicial = '' OR pFecha_final = ''THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

       FOREACH

		SELECT SKIP pRegistros FIRST pRecuperacion fecha_proceso,num_mesesvent,importe_vent ,num_mesesdomi,importe_domi,num_meses,importe_total,comision,iva,importe_pago_coppel
		INTO dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel
		FROM bdisac:sac_reportediario_seg  
     	WHERE fecha_proceso BETWEEN pFecha_inicial AND pFecha_final and reportesoc ='1'
      ORDER BY fecha_proceso ASC

       LET iRecuperacion = iRecuperacion + 1;
        
      RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel WITH RESUME;
       END FOREACH;

		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;	
		

	END;		

END PROCEDURE;