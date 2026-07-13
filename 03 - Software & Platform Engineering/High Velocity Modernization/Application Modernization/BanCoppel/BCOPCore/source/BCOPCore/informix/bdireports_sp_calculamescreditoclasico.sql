CREATE PROCEDURE "informix".sp_calculamescreditoclasico(cTrimestre cHAR(5),iMes INTEGER)
returning
char (5),
char(300);

/*
#####################################################################################
#   Creado por: Juan Fco. Ponce Damian												#
#   Fecha: 06/11/2013																#
#   Descripcion: Calcula y genera la información mensual para el reporte trimestral #
#	de VISA, en volumetría crédito.													#
#####################################################################################
*/
--MANEJO DE ERRORES
DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(300);
DEFINE cVarDataErr1     CHAR(100);
DEFINE cVarDataErr2     CHAR(100);
DEFINE cVarDataErr3     CHAR(100);
DEFINE cCodret          CHAR(5);
--GENERALES
DEFINE cNumProducto     CHAR(4);
DEFINE cCodFila          CHAR(3);
--CEN
DEFINE sumiTotalDispATMtotal    DECIMAL;
DEFINE summSaldoDispATMtotal    MONEY(14,2);
DEFINE sumiTotalComprasEntTotal DECIMAL;
DEFINE sumdMontoComprasEntTotal MONEY(14,2);
DEFINE sumiTotalComprasEntTotal05 DECIMAL;
DEFINE sumdMontoComprasEntTotal05 MONEY(14,2);
DEFINE sumiTotalComprasEntTotal01 DECIMAL;
DEFINE sumdMontoComprasEntTotal01 MONEY(14,2);
--VVP
DEFINE sumiTotalDisp       DECIMAL;
DEFINE summSaldoDisp   MONEY(14,2);
DEFINE sumdNumDispATMprop  DECIMAL;
DEFINE summMontoDispATMproptotal MONEY(14,2);
DEFINE sumiTotalComprasTCCTotal DECIMAL;
DEFINE sumdMontoComprasTCCTotal MONEY(14,2);
DEFINE sumiTotalCCPTotal DECIMAL;
DEFINE sumdMontoCCPTotal MONEY(14,2);
--CEI
DEFINE sumiTotalComprasInterTotal DECIMAL;
DEFINE sumdMontoComprasInterTotal DECIMAL;
DEFINE sumiTotalDispAtmIntTotal DECIMAL;
DEFINE sumdMontoAtmIntTotal     MONEY(14,2);
DEFINE sumiTotalComprasInterTotal05 DECIMAL;
DEFINE sumdMontoComprasInterTotal05 MONEY(14,2);
DEFINE sumiTotalComprasInterTotal01 DECIMAL;
DEFINE sumdMontoComprasInterTotal01 MONEY(14,2);

	ON EXCEPTION SET iSqlErr
        
		LET cVarDataErr =  ' ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
		LET cCodret = '-1';
		
        INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_CalculaMesCreditoClasico',iMes,TODAY,'', 0 ,cVarDataErr);
		
		RETURN cCodret, cVarDataErr;
       
	END EXCEPTION;
    
--Set debug file to "/informix/pruebasconciliacion/sp_CalculaMesCreditoClasico.sql";
--trace on;

LET cCodret = '00000';
LET cVarDataErr = '';
LET cVarDataErr1 = '';
LET cVarDataErr2 = '';
LET cVarDataErr3 = '';

--CEN
LET sumiTotalComprasEntTotal = 0;
LET sumdMontoComprasEntTotal = 0;  
LET sumiTotalDispAtmTotal = 0;
LET sumiTotalComprasEntTotal05 = 0;
LET sumdMontoComprasEntTotal05 = 0;
LET sumiTotalComprasEntTotal01 = 0;
LET sumdMontoComprasEntTotal01 = 0;
LET summSaldoDispATMtotal = 0;
--VVP
LET sumdNumDispATMprop = 0.0;
LET summMontoDispATMproptotal = 0.0;
LET sumiTotalComprasTCCTotal = 0;
LET sumdMontoComprasTCCTotal = 0.0;
LET sumiTotalCCPTotal = 0;
LET sumdMontoCCPTotal = 0.0;
--CEI
LET sumiTotalComprasInterTotal = 0;
LET sumdMontoComprasInterTotal = 0;
LET sumiTotalDispAtmIntTotal = 0;
LET sumdMontoAtmIntTotal = 0;
LET sumiTotalComprasInterTotal05 = 0;
LET sumdMontoComprasInterTotal05 = 0;
LET sumiTotalComprasInterTotal01 = 0;
LET sumdMontoComprasInterTotal01 = 0;
		
--INFORMACION DE CREDITO

	LET cCodFila = 'VVP';
	LET cNumProducto = '6001';
	
	IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_volumetria WHERE trimestre = cTrimestre
	AND num_producto = cNumProducto AND id_col = cCodFila AND mes = iMes ) THEN
	
		SET ISOLATION TO dirty read;
		
		SELECT sum(campo_g),sum(campo_h),sum(campo_i),sum(campo_j),sum(campo_k),sum(campo_l),sum(campo_m),sum(campo_n)
		INTO sumiTotalDisp,summSaldoDisp,sumdNumDispATMprop,summMontoDispATMproptotal, sumiTotalComprasTCCTotal,
		sumdMontoComprasTCCTotal,sumiTotalCCPTotal,sumdMontoCCPTotal
		from bdireports:rpt_volumetria_diaria 
		where trimestre = cTrimestre AND num_producto = cNumProducto AND id_col = cCodFila AND mes = iMes;
		
		--Inserta en la base de datos VVP
		INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,
		campo_e,campo_f,campo_g,campo_h,campo_i,campo_j,campo_k,campo_l,campo_m,campo_n)     
		VALUES(cNumProducto,cTrimestre,cCodFila,iMes,0,0,0,0,0,0,sumiTotalDisp,summSaldoDisp,sumdNumDispATMprop, summMontoDispATMproptotal,
		sumiTotalComprasTCCTotal, sumdMontoComprasTCCTotal,sumiTotalCCPTotal, sumdMontoCCPTotal);
	ELSE
		LET cCodret = '00011';
		LET cVarDataErr1 = ' ERROR AL INSERTAR :'||trim(cCodFila)|| ','||trim(cNumProducto)||','|| iMes ||'.';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_CalculaMesCreditoClasico',iMes,TODAY,'', 0 ,cCodret||cVarDataErr1);
	END IF;

--**********  LLenamos Volumetria de CEN *****************************************************************************
	LET cCodFila = 'CEN';
	
	IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_volumetria WHERE trimestre = cTrimestre 
	AND num_producto = cNumProducto AND id_col = cCodFila AND mes = iMes ) THEN
	
		SET ISOLATION TO dirty read;
		
		SELECT sum(campo_a),sum(campo_b),sum(campo_c),sum(campo_d),sum(campo_e),sum(campo_f),sum(campo_i),sum(campo_j)
		INTO sumiTotalComprasEntTotal, sumdMontoComprasEntTotal,sumiTotalComprasEntTotal05, sumdMontoComprasEntTotal05, 
		sumiTotalComprasEntTotal01, sumdMontoComprasEntTotal01,sumiTotalDispAtmTotal, summSaldoDispATMtotal
		FROM bdireports:rpt_volumetria_diaria 
		WHERE trimestre = cTrimestre AND num_producto = cNumProducto AND id_col = cCodFila AND mes = iMes;
		
		--Inserta en la base de datos
		INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,
		campo_e,campo_f,campo_g,campo_h,campo_i,campo_j,campo_k,campo_l,campo_m,campo_n)         
		VALUES(cNumProducto,cTrimestre,cCodFila,iMes,sumiTotalComprasEntTotal,sumdMontoComprasEntTotal,
		sumiTotalComprasEntTotal05 ,sumdMontoComprasEntTotal05 ,sumiTotalComprasEntTotal01,sumdMontoComprasEntTotal01
		,0,0,sumiTotalDispAtmTotal,summSaldoDispATMtotal,0,0,0,0);
	ELSE 
		LET cCodret = '00012';
		LET cVarDataErr2 = ' ERROR AL INSERTAR :'||trim(cCodFila)|| ','||trim(cNumProducto)||','|| iMes ||'.';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_CalculaMesCreditoClasico',iMes,TODAY,'', 0 ,cCodret||cVarDataErr2);
	END IF;
--**********  LLenamos Volumetria de CEN ******************************************************************************
	LET cCodFila = 'CEI';
	
	IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_volumetria WHERE trimestre = cTrimestre  
	AND num_producto = cNumProducto AND id_col = cCodFila AND mes = iMes ) THEN
	
		SET ISOLATION TO dirty read;
		
		SELECT sum(campo_a),sum(campo_b),sum(campo_c),sum(campo_d),sum(campo_e),sum(campo_f),sum(campo_i),sum(campo_j)
		INTO sumiTotalComprasInterTotal, sumdMontoComprasInterTotal,sumiTotalComprasInterTotal05, sumdMontoComprasInterTotal05, 
		sumiTotalComprasInterTotal01, sumdMontoComprasInterTotal01,sumiTotalDispAtmIntTotal, sumdMontoAtmIntTotal
		FROM bdireports:rpt_volumetria_diaria 
		WHERE trimestre = cTrimestre AND num_producto = cNumProducto AND id_col = cCodFila AND mes = iMes;
		
		--Se inserta en la base de datos la informacion
		INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,
		campo_e,campo_f,campo_g,campo_h,campo_i,campo_j,campo_k,campo_l,campo_m,campo_n)     
		VALUES(cNumProducto,cTrimestre,cCodFila,iMes,sumiTotalComprasInterTotal,sumdMontoComprasInterTotal,
		sumiTotalComprasInterTotal05 ,sumdMontoComprasInterTotal05 ,sumiTotalComprasInterTotal01,sumdMontoComprasInterTotal01,
		0,0,sumiTotalDispAtmIntTotal,sumdMontoAtmIntTotal,0,0,0,0);

	ELSE 
		LET cCodret = '00013';
		LET cVarDataErr3 = ' ERROR AL INSERTAR :'||trim(cCodFila)|| ','||trim(cNumProducto)||','|| iMes ||'.';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_CalculaMesCreditoClasico',iMes,TODAY,'', 0 ,cCodret||cVarDataErr3);
	END IF;
	
LET cVarDataErr = trim(cVarDataErr1)||trim(cVarDataErr2)||trim(cVarDataErr3);

RETURN cCodRet,cVarDataErr;

END PROCEDURE;