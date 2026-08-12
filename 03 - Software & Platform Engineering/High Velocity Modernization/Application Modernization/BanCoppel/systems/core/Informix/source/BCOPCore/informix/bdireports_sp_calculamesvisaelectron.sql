CREATE PROCEDURE "informix".sp_calculamesvisaelectron(cTrimestre CHAR(5),iMes INTEGER)
returning
char (5),
char(300);

/*
#####################################################################################
#   Creado por: Juan Fco. Ponce Damian												#
#   Fecha: 06/11/2013																#
#   Descripcion: Calcula y genera la información mensual para el reporte trimestral #
#	de VISA, en volumetría debito.													#
#####################################################################################
*/

DEFINE cCodFila         CHAR(8);

DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(300);
DEFINE cVarDataErr1     CHAR(100);
DEFINE cVarDataErr2     CHAR(100);
DEFINE cVarDataErr3     CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cProducto        CHAR(4);
--VVP
DEFINE sumiTotalDisp    DECIMAL;
DEFINE summSaldoDisp   MONEY(14,2);
DEFINE sumdNumDispATMprop  DECIMAL;
DEFINE summMontoDispATMproptotal MONEY(14,2);
DEFINE sumiTotalComprasTCDTotal DECIMAL;
DEFINE sumdMontoComprasTCDTotal MONEY(14,2);
DEFINE sumiTotalCCDTotal DECIMAL;
DEFINE sumdMontoCCDTotal MONEY(14,2);
--CEN
DEFINE sumiTotalDispATMtotal    DECIMAL;
DEFINE summSaldoDispATMtotal    MONEY(14,2);
DEFINE sumiTotalComprasEntTotal DECIMAL;
DEFINE sumdMontoComprasEntTotal MONEY(14,2);
DEFINE sumiTotalComprasEntTotal01 DECIMAL;
DEFINE sumdMontoComprasEntTotal01 MONEY(14,2);
DEFINE sumiTotalComprasEntTotal05 DECIMAL;
DEFINE sumdMontoComprasEntTotal05 MONEY(14,2);
--CEI
DEFINE sumiTotalDispAtmIntTotal DECIMAL;
DEFINE sumdMontoAtmIntTotal     MONEY(14,2);
DEFINE sumiTotalComprasInterTotal DECIMAL;
DEFINE sumdMontoComprasInterTotal MONEY(14,2);
DEFINE sumiTotalComprasInterTotal05 DECIMAL;
DEFINE sumdMontoComprasInterTotal05 MONEY(14,2);
DEFINE sumiTotalComprasInterTotal01 DECIMAL;
DEFINE sumdMontoComprasInterTotal01 MONEY(14,2);


  ON EXCEPTION SET iSqlErr
        
		LET cVarDataErr = ' ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
		LET cCodret = '-1';
        INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_CalculaMesVisaElectron',iMes,TODAY,'', 0 ,cVarDataErr);
		RETURN cCodret, cVarDataErr;
       
  END EXCEPTION;

--Set debug file to "/informix/pruebasconciliacion/sp_CalculaMesVisaElectron.sql";
--trace on;

LET cCodret = '00000';
LET cVarDataErr = ' ';
LET cVarDataErr1 = '';
LET cVarDataErr2 = '';
LET cVarDataErr3 = '';
--VVP
LET sumiTotalDisp = 0;
LET summSaldoDisp = 0;
LET sumdNumDispATMprop = 0;
LET summMontoDispATMproptotal = 0.0;
LET sumiTotalComprasTCDTotal = 0;
LET sumdMontoComprasTCDTotal = 0.0;
LET sumiTotalCCDTotal = 0;
LET sumdMontoCCDTotal = 0.0;
--CEN
LET sumiTotalDispAtmTotal = 0;
LET summSaldoDispATMtotal = 0;
LET sumiTotalComprasEntTotal = 0;
LET sumdMontoComprasEntTotal = 0;
LET sumiTotalComprasEntTotal05 = 0;
LET sumdMontoComprasEntTotal05 = 0;
LET sumiTotalComprasEntTotal01 = 0;
LET sumdMontoComprasEntTotal01 = 0;
--CEI
LET sumiTotalComprasInterTotal = 0;
LET sumdMontoComprasInterTotal = 0;
LET sumiTotalDispAtmIntTotal = 0;
LET sumdMontoAtmIntTotal = 0;
LET sumiTotalComprasInterTotal05 = 0;
LET sumdMontoComprasInterTotal05 = 0;
LET sumiTotalComprasInterTotal01 = 0;
LET sumdMontoComprasInterTotal01 = 0;

--**********  LLenamos Volumetria de VVP ************

	--Inserta en la base de datos
SET ISOLATION TO dirty read;
	LET cCodFila = 'VVP';
	LET cProducto = '2000';
	
	IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_volumetria WHERE  trimestre = cTrimestre
	AND num_producto = cProducto AND id_col = cCodFila AND mes = iMes ) THEN
		
		SELECT sum(campo_g),sum(campo_h),sum(campo_i),sum(campo_j),sum(campo_k),sum(campo_l),sum(campo_m),sum(campo_n)
		INTO sumiTotalDisp,summSaldoDisp,sumdNumDispATMprop,summMontoDispATMproptotal, sumiTotalComprasTCDTotal,
		sumdMontoComprasTCDTotal,sumiTotalCCDTotal,sumdMontoCCDTotal
		from bdireports:rpt_volumetria_diaria 
		where trimestre = cTrimestre AND num_producto = cProducto AND id_col = cCodFila AND mes = iMes;
		
		--Inserta en la base de datos VVP calculado del mes.
		INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,
		campo_e,campo_f,campo_g,campo_h,campo_i,campo_j,campo_k,campo_l,campo_m,campo_n)     
		VALUES(cProducto,cTrimestre,cCodFila,iMes,0,0,0,0,0,0,sumiTotalDisp,summSaldoDisp,sumdNumDispATMprop,
		summMontoDispATMproptotal,sumiTotalComprasTCDTotal,sumdMontoComprasTCDTotal,sumiTotalCCDTotal,sumdMontoCCDTotal);
	ELSE
		LET cCodret = '00011';  
		LET cVarDataErr1 = ' ERROR AL INSERTAR :'||trim(cCodFila)|| ','||trim(cProducto)||','|| iMes ||'.';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_CalculaMesVisaElectron',iMes,TODAY,'', 0 ,cCodret||cVarDataErr1);
	END IF;
	
--**********  LLenamos Volumetria de CEN ************

	LET cCodFila = 'CEN';
	
	IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_volumetria WHERE  trimestre = cTrimestre
	AND num_producto = cProducto AND id_col = cCodFila AND mes = iMes ) THEN
		
		SELECT sum(campo_a),sum(campo_b),sum(campo_c),sum(campo_d),sum(campo_e),sum(campo_f),sum(campo_i),sum(campo_j)
		INTO sumiTotalComprasEntTotal, sumdMontoComprasEntTotal,sumiTotalComprasEntTotal05, sumdMontoComprasEntTotal05, 
		sumiTotalComprasEntTotal01, sumdMontoComprasEntTotal01,sumiTotalDispAtmTotal, summSaldoDispATMtotal
		FROM bdireports:rpt_volumetria_diaria 
		WHERE trimestre = cTrimestre AND num_producto = cProducto AND id_col = cCodFila AND mes = iMes;
		
		--Inserta en la base de datos CEN
		INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,
		campo_e,campo_f,campo_g,campo_h,campo_i,campo_j,campo_k,campo_l,campo_m,campo_n)         
		VALUES(cProducto,cTrimestre,cCodFila,iMes,sumiTotalComprasEntTotal,sumdMontoComprasEntTotal,sumiTotalComprasEntTotal05 ,
		sumdMontoComprasEntTotal05 ,sumiTotalComprasEntTotal01,sumdMontoComprasEntTotal01
		,0,0,sumiTotalDispAtmTotal,summSaldoDispATMtotal,0,0,0,0);
	ELSE
		LET cCodret = '00012';
		LET cVarDataErr2 = ' ERROR AL INSERTAR :'||trim(cCodFila)|| ','||trim(cProducto)||','|| iMes ||'.';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_CalculaMesVisaElectron',iMes,TODAY,'', 0 ,cCodret||cVarDataErr2);
	END IF;
--**********  LLenamos Volumetria de CEI ************
	LET cCodFila = 'CEI';
	
	IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_volumetria WHERE trimestre = cTrimestre
	AND num_producto = cProducto AND id_col = cCodFila AND mes = iMes ) THEN
		
		SELECT sum(campo_a),sum(campo_b),sum(campo_c),sum(campo_d),sum(campo_e),sum(campo_f),sum(campo_i),sum(campo_j)
		INTO sumiTotalComprasInterTotal, sumdMontoComprasInterTotal,sumiTotalComprasInterTotal05, sumdMontoComprasInterTotal05, 
		sumiTotalComprasInterTotal01, sumdMontoComprasInterTotal01,sumiTotalDispAtmIntTotal, sumdMontoAtmIntTotal
		FROM bdireports:rpt_volumetria_diaria 
		WHERE trimestre = cTrimestre AND num_producto = cProducto AND id_col = cCodFila AND mes = iMes;

		--Se inserta informacion en la base de datos.
		INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,
		campo_e,campo_f,campo_g,campo_h,campo_i,campo_j,campo_k,campo_l,campo_m,campo_n)     
		VALUES(cProducto,cTrimestre,cCodFila,iMes,sumiTotalComprasInterTotal, sumdMontoComprasInterTotal,sumiTotalComprasInterTotal05, sumdMontoComprasInterTotal05,
		sumiTotalComprasInterTotal01, sumdMontoComprasInterTotal01,0,0,sumiTotalDispAtmIntTotal, sumdMontoAtmIntTotal,0,0,0,0);
	ELSE
		LET cCodret = '00013';
		LET cVarDataErr3 = ' ERROR AL INSERTAR :'||trim(cCodFila)|| ','||trim(cProducto)||','|| iMes ||'.';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_CalculaMesVisaElectron',iMes,TODAY,'', 0 ,cCodret||cVarDataErr3);
	END IF;

LET cVarDataErr = trim(cVarDataErr1)||trim(cVarDataErr2)||trim(cVarDataErr3);
	
RETURN cCodret,cVarDataErr;

END PROCEDURE;