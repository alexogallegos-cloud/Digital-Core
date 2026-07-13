CREATE PROCEDURE "informix".sp_consulta_sac_reportedomiciliacion( pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha_inicial DATE,pFecha_final DATE, pSucursal CHAR(4),pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,DATE AS fecha_pago, CHAR(20) AS num_cliente, MONEY(16,2) AS importe_pago, 
	MONEY(16,2) AS importe_comision_convenio,MONEY(16,2) AS iva_comision_convenio, INTEGER AS meses,
	CHAR(20) AS numcte_coppel, CHAR(20) AS numcte,CHAR(20) AS num_poliza, MONEY(16,2) AS monto_mes,
	CHAR(4) AS sucursal_alta, CHAR(8) AS promotor, CHAR(45) AS nom_promotor, CHAR(1) AS tipo_plan, DATE AS fecha_alta, DATE AS fecha_cambio;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFecha_pago DATE;
	DEFINE cNum_cliente CHAR(20);
	DEFINE mImporte_pago MONEY(16,2);
	DEFINE mImporte_comision_convenio MONEY(16,2);
	DEFINE mIva_comision_convenio MONEY(16,2);
	DEFINE iMeses INTEGER;
	DEFINE cNumcte_coppel CHAR(20);
	DEFINE cNumcte CHAR(20);
	DEFINE cNum_poliza CHAR(20);
	DEFINE mMonto_mes MONEY(16,2);
	DEFINE cSucursal_alta CHAR(4);
	DEFINE cPromotor CHAR(8);
	DEFINE cNom_promotor CHAR(45);
	DEFINE cTipo_plan CHAR(1);
	DEFINE dFecha_alta DATE;
	DEFINE dFecha_cambio DATE;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFecha_pago =DATE(1);
	LET cNum_cliente ='';
	LET mImporte_pago =0;
	LET mImporte_comision_convenio =0;
	LET mIva_comision_convenio =0;
	LET iMeses =0;
	LET cNumcte_coppel ='';
	LET cNumcte ='';
	LET cNum_poliza ='';
	LET mMonto_mes =0;
	LET cSucursal_alta ='';
	LET cPromotor ='';
	LET cNom_promotor ='';
	LET cTipo_plan ='';
	LET dFecha_alta =DATE(1);
	LET dFecha_cambio =DATE(1);
	LET iRecuperacion=0;
	

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_sac_reportedomiciliaciongrid
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
			
			RETURN cCodRet, dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_sac_reportedomiciliacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pFecha_inicial = '' OR pFecha_final = '' OR pRegistros='' OR pRecuperacion='' THEN
			LET cCodRet = '00003';
			UPDATE "informix".sw_sac_reportedomiciliaciongrid
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
		
			RETURN cCodRet, dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_sac_reportedomiciliaciongrid
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
			RETURN cCodRet, dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF nvl(pSucursal,'') ='' THEN
		
		FOREACH

	    SELECT SKIP pRegistros FIRST pRecuperacion fecha_pago, num_cliente, importe_pago, importe_comision_convenio, iva_comision_convenio, meses, numcte_coppel, numcte, num_poliza, monto_mes, sucursal_alta, promotor, nom_promotor, tipo_plan, fecha_alta, fecha_cambio
		INTO dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio
		FROM bdisac:sac_reportediariodomi_seg
		WHERE fecha_pago BETWEEN pFecha_inicial AND pFecha_final

		LET iRecuperacion = iRecuperacion + 1;
		
		
		
		RETURN cCodRet, dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio WITH RESUME;
		
		END FOREACH;
				
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			
			
			UPDATE "informix".sw_sac_reportedomiciliaciongrid
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
			
			RETURN cCodRet, dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			
			
			UPDATE "informix".sw_sac_reportedomiciliaciongrid
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
			
			RETURN cCodRet, dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio;
			END IF;			
			
			
	    UPDATE "informix".sw_sac_reportedomiciliaciongrid
	    SET  status = 'T', error_proceso = 'N', bandera_det_error = cBanDetError, 
		total_registros = iRecuperacion
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA';
				
		ELSE 
		
		FOREACH

	    SELECT SKIP pRegistros FIRST pRecuperacion fecha_pago, num_cliente, importe_pago, importe_comision_convenio, iva_comision_convenio, meses, numcte_coppel, numcte, num_poliza, monto_mes, sucursal_alta, promotor, nom_promotor, tipo_plan, fecha_alta, fecha_cambio
		INTO dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio
		FROM bdisac:sac_reportediariodomi_seg
		WHERE fecha_pago BETWEEN pFecha_inicial AND pFecha_final AND sucursal_alta=pSucursal

		LET iRecuperacion = iRecuperacion + 1;
		
		RETURN cCodRet, dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio WITH RESUME;
		
		END FOREACH;
				
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			
			
			UPDATE "informix".sw_sac_reportedomiciliaciongrid
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
			
			RETURN cCodRet, dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			
			UPDATE "informix".sw_sac_reportedomiciliaciongrid
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
			
			RETURN cCodRet, dFecha_pago,cNum_cliente,mImporte_pago,mImporte_comision_convenio,mIva_comision_convenio,
			iMeses,cNumcte_coppel,cNumcte,cNum_poliza,
			mMonto_mes,cSucursal_alta,cPromotor,cNom_promotor,cTipo_plan,dFecha_alta,dFecha_cambio;
			END IF;			
	
		UPDATE "informix".sw_sac_reportedomiciliaciongrid
		SET  status = 'T', error_proceso = 'N',total_registros = iRecuperacion
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA';
	
	
		END IF;

	END;		

END PROCEDURE;