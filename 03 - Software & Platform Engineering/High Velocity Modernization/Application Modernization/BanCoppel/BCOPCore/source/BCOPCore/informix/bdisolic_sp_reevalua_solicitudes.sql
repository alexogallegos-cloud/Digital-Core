CREATE PROCEDURE  "informix".sp_reevalua_solicitudes()
		RETURNING CHAR(8) AS codret;


DEFINE cCodRet CHAR(6);
DEFINE cCodRet2 CHAR(6);
DEFINE cCodSP CHAR(5);
DEFINE cCodSP2 CHAR(5);
DEFINE cCausa_solicitud CHAR(3);
DEFINE iSqlErr INTEGER;
DEFINE cEmpresa          	CHAR(3);
DEFINE cNum_solicitud    	CHAR(20);
DEFINE cNumcte           	CHAR(20);
DEFINE cCo_numcte        	CHAR(20);
DEFINE cCod_funcion      	CHAR(3);
DEFINE cRegional         	CHAR(3);
DEFINE cPlaza            	CHAR(3);
DEFINE cSucursal         	CHAR(4);
DEFINE cTipo_solicitud   	CHAR(1);
DEFINE cStatus_solicitud 	CHAR(2);
DEFINE cStatus_solicitud2 	CHAR(2);
DEFINE cNum_producto     	CHAR(4);
DEFINE cTipo_prestamo    	CHAR(2);
DEFINE dMonto_solicitado 	DECIMAL(18,2);
DEFINE cPeriodo_plazo    	CHAR(1);
DEFINE iPlazo            	INTEGER;
DEFINE cDivisa           	CHAR(2);
DEFINE cTipo_calculo     	CHAR(2);
DEFINE cCod_tasa_base    	CHAR(8);
DEFINE dSobretasa        	DECIMAL(9,6);
DEFINE cFactor_sobretasa 	CHAR(1);
DEFINE dTasa_interes     	DECIMAL(9,6);
DEFINE cTasa_fija_o_var  	CHAR(1);
DEFINE cRev_tasa_var_per 	CHAR(1);
DEFINE iDia_para_revisar 	INTEGER;
DEFINE cTasa_mora_adic   	CHAR(1);
DEFINE cCod_tasa_mora    	CHAR(8);
DEFINE dFact_sobret_mora 	DECIMAL(9,6);
DEFINE dSobretasa_mora   	DECIMAL(9,6);
DEFINE dTasa_moratorios  	DECIMAL(9,6);
DEFINE cFactor_moratorio 	CHAR(1);
DEFINE cPeriodo_pag_cap  	CHAR(1);
DEFINE cPeriodo_pag_int  	CHAR(1);
DEFINE iGracia_cap       	INTEGER;
DEFINE iDiferimiento_int 	INTEGER;
DEFINE cTp_gen_planpago  	CHAR(1);
DEFINE cIndividualizable 	CHAR(1);
DEFINE cCon_integrantes  	CHAR(1);
DEFINE dFecha_apert_prop 	DATE;
DEFINE dFecha_venc_prop  	DATE;
DEFINE cAjuste_de_cuota  	CHAR(1);
DEFINE cAjuste_venc_int  	CHAR(1);
DEFINE cEnvio_coppel     	CHAR(1);
DEFINE cEnvio_parametrico	CHAR(1);
DEFINE cTasa_base_piso   	CHAR(8);
DEFINE dSobretasa_piso   	DECIMAL(9,6);
DEFINE cFactor_piso      	CHAR(1);
DEFINE cTasa_piso        	CHAR(1);
DEFINE cTasa_base_techo  	CHAR(8);
DEFINE dSobretasa_techo  	DECIMAL(9,6);
DEFINE cFactor_techo     	CHAR(1);
DEFINE dCapacidad_pres   	DECIMAL(18,2);
DEFINE dMonto_autorizado 	DECIMAL(18,2);
DEFINE cUser_insert      	CHAR(30);
DEFINE dFecha_insert     	DATE;
DEFINE dFecha_hora       	DATETIME YEAR to SECOND;
DEFINE cCanal_sol        	CHAR(1);
DEFINE bReevaluado			CHAR(1);
DEFINE bBandera			CHAR(1);
DEFINE dIniCopp 			DATE;
DEFINE dFinCopp 			DATE;
DEFINE dIniBanCopp 			DATE;
DEFINE dFinBanCopp 			DATE;
DEFINE iBandera INTEGER;
DEFINE iContador INTEGER;
DEFINE dFecha_insert2     	DATE;
DEFINE dFecha_entrada2     	DATE;
DEFINE dFecha_salida2     	DATE;
DEFINE dFecha_hora2       	DATETIME YEAR to SECOND;
DEFINE dFecha_entrada     	DATE;
DEFINE dFecha_salida     	DATE;
DEFINE mIngreso             MONEY(14,2);
DEFINE iTp_ingreso         INTEGER;
DEFINE iPeriodoIngreso     INTEGER;
DEFINE cNum_solicitud_sic  CHAR(20);
DEFINE iflag_exist         INTEGER; -- 1 existe / 0 no existe 
DEFINE iflag_existcpi     INTEGER;
DEFINE vTransaccion INTEGER;
DEFINE creferencia1        CHAR(20);
DEFINE creferenciaAUX        CHAR(20);
DEFINE creferencia2        CHAR(20);
DEFINE cnombreref_1        CHAR(104);
DEFINE cnombrerefAUX        CHAR(104);
DEFINE cnombreref_2        CHAR(104);
DEFINE cparentesco_1       CHAR(2);
DEFINE cparentescoAUX       CHAR(2);
DEFINE cparentesco_2       CHAR(2);
DEFINE ctelefono_1         CHAR(13);
DEFINE ctelefonoAUX         CHAR(13);
DEFINE ctelefono_2         CHAR(13);
DEFINE cConyuge       CHAR(20);


LET cCodRet = '000000';
LET cCodRet2 = '000000';
LET cCodSP = '00000';
LET cCodSP2 ='00000';
LET iSqlErr = 0;
LET cCausa_solicitud= '';
LET cEmpresa = '001';
LET cNum_solicitud ='';
LET cNumcte        ='';
LET cCo_numcte ='';
LET cCod_funcion  ='';
LET cRegional        ='';
LET cPlaza            	='';
LET cSucursal         	='';
LET cTipo_solicitud   ='';
LET cStatus_solicitud 	='';
LET cStatus_solicitud2 	='';
LET cNum_producto     ='';
LET cTipo_prestamo    	='';
LET dMonto_solicitado 	=0.0;
LET cPeriodo_plazo='';
LET iPlazo           =0;
LET cDivisa           ='';
LET cTipo_calculo ='';
LET cCod_tasa_base   ='';
LET dSobretasa        	=0.0;
LET cFactor_sobretasa 	='';
LET dTasa_interes     =0.0;
LET cTasa_fija_o_var  	='';
LET cRev_tasa_var_per 	='';
LET iDia_para_revisar 	=0;
LET cTasa_mora_adic   	='';
LET cCod_tasa_mora    	='';
LET dFact_sobret_mora 	=0.0;
LET dSobretasa_mora   	=0.0;
LET dTasa_moratorios  	=0.0;
LET cFactor_moratorio ='';
LET cPeriodo_pag_cap  	='';
LET cPeriodo_pag_int  	='';
LET iGracia_cap       =0;
LET iDiferimiento_int 	=0;
LET cTp_gen_planpago  	='';
LET cIndividualizable 	='';
LET cCon_integrantes  	='';
LET dFecha_apert_prop 	='';
LET dFecha_venc_prop  	='';
LET cAjuste_de_cuota  	='';
LET cAjuste_venc_int  	='';
LET cEnvio_coppel     	='';
LET cEnvio_parametrico	='';
LET cTasa_base_piso   	='';
LET dSobretasa_piso   	=0.0;
LET cFactor_piso      	='';
LET cTasa_piso        	='';
LET cTasa_base_techo  	='';
LET dSobretasa_techo  	=0.0;
LET cFactor_techo     	='';
LET dCapacidad_pres   	=0.0;
LET dMonto_autorizado 	=0.0;
LET cUser_insert      	='';
LET dFecha_insert     	='';
LET dFecha_entrada       	='';
LET dFecha_salida     	='';
LET dFecha_hora2       	='';
LET dFecha_insert2     	='';
LET dFecha_entrada2       	='';
LET dFecha_salida2     	='';
LET dFecha_hora       	='';
LET bReevaluado			='0';
LET bBandera			='0';
LET dIniCopp = '';
LET dFinCopp = '';
LET dIniBanCopp ='';
LET dFinBanCopp = '';
LET cCanal_sol        	='';
LET iBandera = 0;
LET iContador=0;
LET mIngreso        =0;
LET iTp_ingreso     =0;
LET iPeriodoIngreso  =0;
LET cNum_solicitud_sic ='';
LET iflag_exist = 0;
LET vTransaccion=0;
LET creferencia1        ='';
LET creferenciaAUX        ='';
LET creferencia2        ='';
LET cnombreref_1        ='';
LET cnombrerefAUX        ='';
LET cnombreref_2        ='';
LET cparentesco_1       ='';
LET cparentescoAUX       ='';
LET cparentesco_2       ='';
LET ctelefono_1         ='';
LET ctelefonoAUX         ='';
LET ctelefono_2         ='';
LET cConyuge            ='';
LET iflag_existcpi =0;
	
	--SET DEBUG FILE TO "/ifxsif01/PabloT/dia7/sp_reevalua_solicitudes.out";
	--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			IF vTransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
		
			RETURN cCodRet;
        END IF;
	END EXCEPTION;
	
	
    ON EXCEPTION IN (-535)
        LET vTransaccion = 1;
		COMMIT WORK;
		BEGIN WORK;
    END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	--SET DEBUG FILE TO "/ifxsif01/PabloT/dia8/sp_reevalua_solicitudes.out";
	--TRACE ON;	

	--OBTENEMOS EL VALOR DE LA FECHA EN LA TABLA SS_PARAM 
	SELECT TO_DATE(valor, '%Y-%m-%d') INTO dIniCopp FROM bdisolic:"informix".ss_param WHERE secuencia = 451;
	SELECT TO_DATE(valor, '%Y-%m-%d') INTO dFinCopp FROM bdisolic:"informix".ss_param WHERE secuencia = 452;
	SELECT TO_DATE(valor, '%Y-%m-%d') INTO dIniBanCopp FROM bdisolic:"informix".ss_param WHERE secuencia = 453;
	SELECT TO_DATE(valor, '%Y-%m-%d') INTO dFinBanCopp FROM bdisolic:"informix".ss_param WHERE secuencia = 454;

	IF vTransaccion = 1 THEN
         COMMIT WORK;
         BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
	--Canceladas por parametrico incompleto  56532
	select a.empresa,a.num_solicitud,a.numcte,a.co_numcte,a.cod_funcion,a.regional,a.plaza,sucursal,a.tipo_solicitud,a.status_solicitud,a.num_producto,
	a.tipo_prestamo,a.monto_solicitado,a.periodo_plazo,a.plazo,a.divisa,a.tipo_calculo,a.cod_tasa_base,a.sobretasa,a.factor_sobretasa,a.tasa_interes,
	a.tasa_fija_o_var,a.rev_tasa_var_per,a.dia_para_revisar,a.tasa_mora_adic,a.cod_tasa_mora,a.fact_sobret_mora,a.sobretasa_mora,a.tasa_moratorios,
	a.factor_moratorio,a.periodo_pag_cap,a.periodo_pag_int,a.gracia_cap,a.diferimiento_int,a.tp_gen_planpago,a.individualizable,a.con_integrantes,
	a.fecha_apert_prop,a.fecha_venc_prop,a.ajuste_de_cuota,a.ajuste_venc_int,a.envio_coppel,a.envio_parametrico,a.tasa_base_piso,a.sobretasa_piso,
	a.factor_piso,a.tasa_piso,a.tasa_base_techo,a.sobretasa_techo,a.factor_techo,a.capacidad_pres,a.monto_autorizado,a.user_insert,a.fecha_insert,
	a.fecha_hora,a.canal_sol
	From bdisolic:ss_solicitudes a
	INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud AND b.status_solicitud='CN' AND b.causa_solicitud ='CPI' AND b.fecha_insert >= mdy(10,15,2022) AND b.fecha_insert <= mdy(10,19,2022))
	 where a.empresa ='001' 
	AND a.num_solicitud IN (select num_solicitud from bdisolic:ss_solic_rt WHERE num_solicitud =a.num_solicitud AND reevaluado = 1)
	AND a.status_solicitud ='CN' 
	AND num_producto IN('6500','6001')
	AND a.canal_sol = '1'
    INTO temp ss_sol_cn_cpi WITH NO LOG;
	
	COMMIT WORK;

	
	FOREACH  WITH HOLD
	SELECT bdisolic:ss_solicitudes.empresa,bdisolic:ss_solicitudes.num_solicitud,bdisolic:ss_solicitudes.numcte,bdisolic:ss_solicitudes.co_numcte,bdisolic:ss_solicitudes.cod_funcion,bdisolic:ss_solicitudes.regional,bdisolic:ss_solicitudes.plaza,bdisolic:ss_solicitudes.sucursal,bdisolic:ss_solicitudes.tipo_solicitud,bdisolic:ss_solicitudes.status_solicitud,bdisolic:ss_solicitudes.num_producto,
	bdisolic:ss_solicitudes.tipo_prestamo,bdisolic:ss_solicitudes.monto_solicitado,bdisolic:ss_solicitudes.periodo_plazo,bdisolic:ss_solicitudes.plazo,bdisolic:ss_solicitudes.divisa,bdisolic:ss_solicitudes.tipo_calculo,bdisolic:ss_solicitudes.cod_tasa_base,bdisolic:ss_solicitudes.sobretasa,bdisolic:ss_solicitudes.factor_sobretasa,bdisolic:ss_solicitudes.tasa_interes,
	bdisolic:ss_solicitudes.tasa_fija_o_var,bdisolic:ss_solicitudes.rev_tasa_var_per,bdisolic:ss_solicitudes.dia_para_revisar,bdisolic:ss_solicitudes.tasa_mora_adic,bdisolic:ss_solicitudes.cod_tasa_mora,bdisolic:ss_solicitudes.fact_sobret_mora,bdisolic:ss_solicitudes.sobretasa_mora,bdisolic:ss_solicitudes.tasa_moratorios,
	bdisolic:ss_solicitudes.factor_moratorio,bdisolic:ss_solicitudes.periodo_pag_cap,bdisolic:ss_solicitudes.periodo_pag_int,bdisolic:ss_solicitudes.gracia_cap,bdisolic:ss_solicitudes.diferimiento_int,bdisolic:ss_solicitudes.tp_gen_planpago,bdisolic:ss_solicitudes.individualizable,bdisolic:ss_solicitudes.con_integrantes,
	bdisolic:ss_solicitudes.fecha_apert_prop,bdisolic:ss_solicitudes.fecha_venc_prop,bdisolic:ss_solicitudes.ajuste_de_cuota,bdisolic:ss_solicitudes.ajuste_venc_int,bdisolic:ss_solicitudes.envio_coppel,bdisolic:ss_solicitudes.envio_parametrico,bdisolic:ss_solicitudes.tasa_base_piso,bdisolic:ss_solicitudes.sobretasa_piso,
	bdisolic:ss_solicitudes.factor_piso,bdisolic:ss_solicitudes.tasa_piso,bdisolic:ss_solicitudes.tasa_base_techo,bdisolic:ss_solicitudes.sobretasa_techo,bdisolic:ss_solicitudes.factor_techo,bdisolic:ss_solicitudes.capacidad_pres,bdisolic:ss_solicitudes.monto_autorizado,bdisolic:ss_solicitudes.user_insert,bdisolic:ss_solicitudes.fecha_insert,
	bdisolic:ss_solicitudes.fecha_hora,bdisolic:ss_solicitudes.canal_sol	
	INTO cEmpresa,cNum_solicitud,cNumcte,cCo_numcte,cCod_funcion,cRegional,cPlaza,cSucursal,cTipo_solicitud,cStatus_solicitud,cNum_producto,
	cTipo_prestamo, dMonto_solicitado, cPeriodo_plazo,iPlazo,cDivisa,cTipo_calculo,cCod_tasa_base,dSobretasa,cFactor_sobretasa,dTasa_interes,
	cTasa_fija_o_var,cRev_tasa_var_per,iDia_para_revisar,cTasa_mora_adic,cCod_tasa_mora,dFact_sobret_mora,dSobretasa_mora,dTasa_moratorios,
	cFactor_moratorio,cPeriodo_pag_cap,cPeriodo_pag_int,iGracia_cap,iDiferimiento_int,cTp_gen_planpago,cIndividualizable,cCon_integrantes,
	dFecha_apert_prop,dFecha_venc_prop,cAjuste_de_cuota,cAjuste_venc_int,cEnvio_coppel,cEnvio_parametrico,cTasa_base_piso,dSobretasa_piso,
	cFactor_piso,cTasa_piso,cTasa_base_techo,dSobretasa_techo,cFactor_techo,dCapacidad_pres,dMonto_autorizado,cUser_insert,dFecha_insert,
	dFecha_hora,cCanal_sol	
	FROM bdisolic:"informix".ss_solicitudes
	JOIN bdisolic:"informix".ss_nuevo_parametrico AS n ON bdisolic:ss_solicitudes.num_solicitud = n.num_solicitud --1
	LEFT JOIN bdisolic:"informix".ss_solic_rt as r ON bdisolic:ss_solicitudes.empresa= r.empresa AND bdisolic:ss_solicitudes.num_solicitud = r.num_solicitud --1
	WHERE  bdisolic:ss_solicitudes.empresa = '001' AND bdisolic:ss_solicitudes.fecha_insert >=dIniCopp AND bdisolic:ss_solicitudes.fecha_insert<=dFinCopp
	AND bdisolic:ss_solicitudes.num_producto='6500' 
	AND bdisolic:ss_solicitudes.status_solicitud IN ('RT','CN')
	AND bdisolic:ss_solicitudes.canal_sol = '1'
	AND r.num_solicitud IS NULL
	UNION ALL
	SELECT bdisolic:ss_solicitudes.empresa,bdisolic:ss_solicitudes.num_solicitud,bdisolic:ss_solicitudes.numcte,bdisolic:ss_solicitudes.co_numcte,bdisolic:ss_solicitudes.cod_funcion,bdisolic:ss_solicitudes.regional,bdisolic:ss_solicitudes.plaza,bdisolic:ss_solicitudes.sucursal,bdisolic:ss_solicitudes.tipo_solicitud,bdisolic:ss_solicitudes.status_solicitud,bdisolic:ss_solicitudes.num_producto,
	bdisolic:ss_solicitudes.tipo_prestamo,bdisolic:ss_solicitudes.monto_solicitado,bdisolic:ss_solicitudes.periodo_plazo,bdisolic:ss_solicitudes.plazo,bdisolic:ss_solicitudes.divisa,bdisolic:ss_solicitudes.tipo_calculo,bdisolic:ss_solicitudes.cod_tasa_base,bdisolic:ss_solicitudes.sobretasa,bdisolic:ss_solicitudes.factor_sobretasa,bdisolic:ss_solicitudes.tasa_interes,
	bdisolic:ss_solicitudes.tasa_fija_o_var,bdisolic:ss_solicitudes.rev_tasa_var_per,bdisolic:ss_solicitudes.dia_para_revisar,bdisolic:ss_solicitudes.tasa_mora_adic,bdisolic:ss_solicitudes.cod_tasa_mora,bdisolic:ss_solicitudes.fact_sobret_mora,bdisolic:ss_solicitudes.sobretasa_mora,bdisolic:ss_solicitudes.tasa_moratorios,
	bdisolic:ss_solicitudes.factor_moratorio,bdisolic:ss_solicitudes.periodo_pag_cap,bdisolic:ss_solicitudes.periodo_pag_int,bdisolic:ss_solicitudes.gracia_cap,bdisolic:ss_solicitudes.diferimiento_int,bdisolic:ss_solicitudes.tp_gen_planpago,bdisolic:ss_solicitudes.individualizable,bdisolic:ss_solicitudes.con_integrantes,
	bdisolic:ss_solicitudes.fecha_apert_prop,bdisolic:ss_solicitudes.fecha_venc_prop,bdisolic:ss_solicitudes.ajuste_de_cuota,bdisolic:ss_solicitudes.ajuste_venc_int,bdisolic:ss_solicitudes.envio_coppel,bdisolic:ss_solicitudes.envio_parametrico,bdisolic:ss_solicitudes.tasa_base_piso,bdisolic:ss_solicitudes.sobretasa_piso,
	bdisolic:ss_solicitudes.factor_piso,bdisolic:ss_solicitudes.tasa_piso,bdisolic:ss_solicitudes.tasa_base_techo,bdisolic:ss_solicitudes.sobretasa_techo,bdisolic:ss_solicitudes.factor_techo,bdisolic:ss_solicitudes.capacidad_pres,bdisolic:ss_solicitudes.monto_autorizado,bdisolic:ss_solicitudes.user_insert,bdisolic:ss_solicitudes.fecha_insert,
	bdisolic:ss_solicitudes.fecha_hora,bdisolic:ss_solicitudes.canal_sol	
	FROM bdisolic:"informix".ss_solicitudes
	LEFT JOIN bdisolic:"informix".ss_solic_rt as r ON bdisolic:ss_solicitudes.empresa= r.empresa AND bdisolic:ss_solicitudes.num_solicitud = r.num_solicitud
	WHERE bdisolic:ss_solicitudes.empresa = '001' AND bdisolic:ss_solicitudes.fecha_insert >=dIniBanCopp AND bdisolic:ss_solicitudes.fecha_insert<=dFinBanCopp
	AND bdisolic:ss_solicitudes.num_producto='6001' 
	AND bdisolic:ss_solicitudes.status_solicitud IN ('RT','CN')
	AND bdisolic:ss_solicitudes.canal_sol = '1'
	AND r.num_solicitud IS NULL
    UNION ALL
    SELECT a.empresa,a.num_solicitud,a.numcte,a.co_numcte,a.cod_funcion,a.regional,a.plaza,sucursal,a.tipo_solicitud,a.status_solicitud,a.num_producto,
	a.tipo_prestamo,a.monto_solicitado,a.periodo_plazo,a.plazo,a.divisa,a.tipo_calculo,a.cod_tasa_base,a.sobretasa,a.factor_sobretasa,a.tasa_interes,
	a.tasa_fija_o_var,a.rev_tasa_var_per,a.dia_para_revisar,a.tasa_mora_adic,a.cod_tasa_mora,a.fact_sobret_mora,a.sobretasa_mora,a.tasa_moratorios,
	a.factor_moratorio,a.periodo_pag_cap,a.periodo_pag_int,a.gracia_cap,a.diferimiento_int,a.tp_gen_planpago,a.individualizable,a.con_integrantes,
	a.fecha_apert_prop,a.fecha_venc_prop,a.ajuste_de_cuota,a.ajuste_venc_int,a.envio_coppel,a.envio_parametrico,a.tasa_base_piso,a.sobretasa_piso,
	a.factor_piso,a.tasa_piso,a.tasa_base_techo,a.sobretasa_techo,a.factor_techo,a.capacidad_pres,a.monto_autorizado,a.user_insert,a.fecha_insert,
	a.fecha_hora,a.canal_sol
    FROM ss_sol_cn_cpi a      

    IF vTransaccion = 1 THEN
         COMMIT WORK;
         BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

		SELECT 1 INTO iflag_exist FROM bdisolic:"informix".ss_solic_rt WHERE empresa = '001' AND num_solicitud=cNum_solicitud;		SELECT 1 INTO iflag_existcpi FROM bdisolic:"informix".ss_sol_cn_cpi WHERE empresa = '001' AND num_solicitud=cNum_solicitud;
		
		IF iflag_exist <> 1 OR iflag_exist IS  NULL OR iflag_existcpi = 1 THEN
			IF iflag_existcpi = 1 THEN
				UPDATE bdisolic: "informix".ss_solic_rt set reevaluado = 0 WHERE empresa = '001' AND num_solicitud=cNum_solicitud;
			ELSE
				INSERT INTO bdisolic: "informix".ss_solic_rt (empresa,num_solicitud,numcte,co_numcte,cod_funcion,regional,plaza,sucursal,tipo_solicitud,status_solicitud,num_producto,
				tipo_prestamo,monto_solicitado,periodo_plazo,plazo,divisa,tipo_calculo,cod_tasa_base,sobretasa,factor_sobretasa,tasa_interes,
				tasa_fija_o_var,rev_tasa_var_per,dia_para_revisar,tasa_mora_adic,cod_tasa_mora,fact_sobret_mora,sobretasa_mora,tasa_moratorios,
				factor_moratorio,periodo_pag_cap,periodo_pag_int,gracia_cap,diferimiento_int,tp_gen_planpago,individualizable,con_integrantes,
				fecha_apert_prop,fecha_venc_prop,ajuste_de_cuota,ajuste_venc_int,envio_coppel,envio_parametrico,tasa_base_piso,sobretasa_piso,
				factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,capacidad_pres,monto_autorizado,user_insert,fecha_insert,
				fecha_hora,canal_sol,reevaluado) 
				VALUES (cEmpresa,cNum_solicitud,cNumcte,cCo_numcte,cCod_funcion,cRegional,cPlaza,cSucursal,cTipo_solicitud,cStatus_solicitud,cNum_producto,
				cTipo_prestamo, dMonto_solicitado, cPeriodo_plazo,iPlazo,cDivisa,cTipo_calculo,cCod_tasa_base,dSobretasa,cFactor_sobretasa,dTasa_interes,
				cTasa_fija_o_var,cRev_tasa_var_per,iDia_para_revisar,cTasa_mora_adic,cCod_tasa_mora,dFact_sobret_mora,dSobretasa_mora,dTasa_moratorios,
				cFactor_moratorio,cPeriodo_pag_cap,cPeriodo_pag_int,iGracia_cap,iDiferimiento_int,cTp_gen_planpago,cIndividualizable,cCon_integrantes,
				dFecha_apert_prop,dFecha_venc_prop,cAjuste_de_cuota,cAjuste_venc_int,cEnvio_coppel,cEnvio_parametrico,cTasa_base_piso,dSobretasa_piso,
				cFactor_piso,cTasa_piso,cTasa_base_techo,dSobretasa_techo,cFactor_techo,dCapacidad_pres,dMonto_autorizado,cUser_insert,dFecha_insert,
				dFecha_hora,cCanal_sol,bReevaluado);
			END IF;
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000001'; -- INSERT NO SE REALIZO
				COMMIT WORK;
				CONTINUE FOREACH;
			ELSE
				IF (cNum_producto = '6500') THEN 
					IF (cStatus_solicitud = 'CN') THEN 
						SELECT LIMIT 1 causa_solicitud INTO cCausa_solicitud FROM ss_autorizacion WHERE empresa = '001' AND num_solicitud = cNum_solicitud AND status_solicitud='CN';
						IF (cCausa_solicitud = 'CR') THEN
							SELECT COUNT(num_solicitud) INTO iContador FROM bdisolic: "informix".ss_solicitudes WHERE empresa = '001' AND numcte = cNumcte AND (fecha_insert >= dIniCopp AND num_producto = '6500');
							IF iContador = 1 THEN
								LET bBandera =1;
							ELSE 
								LET bBandera = 0;
							END IF;
						ELIF (cCausa_solicitud = 'CPI') THEN
							LET bBandera =1;
						ELSE 
							LET bBandera = 0;
						END IF;
					ELSE 
						SELECT COUNT(num_solicitud) INTO iContador FROM bdisolic: "informix".ss_solicitudes WHERE empresa = '001' AND numcte = cNumcte AND (fecha_insert >= dIniCopp AND num_producto = '6500' );
						IF iContador = 1 THEN
							LET bBandera =1;
						ELSE 
							LET bBandera = 0;
						END IF;
					END IF;
				ELSE
					IF (cStatus_solicitud = 'CN') THEN 
						SELECT LIMIT 1 causa_solicitud INTO cCausa_solicitud FROM ss_autorizacion WHERE empresa = '001' AND num_solicitud = cNum_solicitud AND status_solicitud='CN';
						IF (cCausa_solicitud = 'CR') THEN
							SELECT COUNT(num_solicitud) INTO iContador FROM bdisolic: "informix".ss_solicitudes WHERE empresa = '001' AND numcte = cNumcte AND ( fecha_insert >= dIniBanCopp AND num_producto='6001');
							IF iContador = 1 THEN
								LET bBandera =1;							
							ELSE 
								LET bBandera = 0;
							END IF;
						ELIF (cCausa_solicitud = 'CPI') THEN
								LET bBandera =1;								
						ELSE 
							LET bBandera = 0;
						END IF;
					ELSE 
						SELECT COUNT(num_solicitud) INTO iContador FROM bdisolic: "informix".ss_solicitudes WHERE empresa = '001' AND numcte = cNumcte AND ( fecha_insert >= dIniBanCopp AND num_producto='6001');
						IF iContador = 1 THEN
							LET bBandera =1;
						ELSE 
							LET bBandera = 0;
						END IF;
					END IF;
				END IF;
					
					SELECT reevaluado INTO bReevaluado FROM bdisolic:"informix".ss_solic_rt WHERE empresa = '001' AND num_solicitud=cNum_solicitud;
					IF bBandera ='1' AND (bReevaluado='0' OR bReevaluado IS NULL) THEN
					--SI NO HA SIDO RE EVALUADA CON ANTERIORIDAD PROCEDEMOS A INSERTARLA A LA TABLA SS_SOLIC_RT
						LET bReevaluado = '1';
						IF iflag_existcpi = 1 THEN
							UPDATE bdisolic: "informix".ss_solic_rt set reevaluado = 1, fecha_reevaluacion=CURRENT WHERE empresa = '001' AND num_solicitud=cNum_solicitud;
						ELSE
							UPDATE bdisolic: "informix".ss_solic_rt set reevaluado = 1 WHERE empresa = '001' AND num_solicitud=cNum_solicitud;
						END IF;
					
						
						 
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '000001'; -- LA MODIFICACIÃ?N NO SE REALIZO
							COMMIT WORK;
							CONTINUE FOREACH;
						ELSE
							LET iflag_exist = 0;
							SELECT count(num_solicitud) INTO iflag_exist FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = '001' AND num_solicitud = cNum_solicitud;
							--IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = '001' AND num_solicitud = cNum_solicitud ) THEN
							IF NVL(iflag_exist,0) = 0 THEN
								INSERT INTO bdisolic:"informix".ss_resum_scor_fin(empresa, num_solicitud, situacion_pago, situacion_credito, meses_historia, fuente, evalua_cc, motivo_cc, ingreso_mensual, tp_ingreso, periodo_ingreso, pago_minimo, linea_tienda, causa, puntualidad, saldoropa, saldomuebles, saldoprestamos, vencidoropa, vencidomuebles, vencidoprestamos, abonomensualropa, abonomensualmuebles, abonomensualprestamos, fecha_ultima_compra, secuenciaconsulta, origen, smbc, salario_minimo, compromisos_bco, situacion_especial, causa_situacion, grupo, ingreso_lc, valor_cma, valor_tab, linea_teorica, tipo_movimiento, num_solicitud_ref, monto_hipoteca, fechaultimopago, prestamoautorizado, montoautorizado, represtamo)
									 SELECT empresa, num_solicitud, situacion_pago, situacion_credito, meses_historia, fuente, evalua_cc, motivo_cc, ingreso_mensual, tp_ingreso, periodo_ingreso, pago_minimo, linea_tienda, causa, puntualidad, saldoropa, saldomuebles, saldoprestamos, vencidoropa, vencidomuebles, vencidoprestamos, abonomensualropa, abonomensualmuebles, abonomensualprestamos, fecha_ultima_compra, secuenciaconsulta, origen, smbc, salario_minimo, compromisos_bco, situacion_especial, causa_situacion, grupo, ingreso_lc, valor_cma, valor_tab, linea_teorica, tipo_movimiento, num_solicitud_ref, monto_hipoteca, fechaultimopago, prestamoautorizado, montoautorizado, represtamo 
													  FROM bdisolic:"informix".ss_resum_scor_fin_old_2021 WHERE empresa = '001' AND num_solicitud = cNum_solicitud; 
							END  IF;
							LET iflag_exist = 0;
							SELECT count(numcte) INTO iflag_exist FROM bdinteg:"informix".si_direcciones WHERE numcte = cNumcte; 
							
							--IF NOT EXISTS (SELECT numcte FROM bdinteg:"informix".si_direcciones WHERE numcte = cNumcte ) THEN
							IF NVL(iflag_exist,0) = 0 THEN
								INSERT INTO bdinteg:"informix".si_direcciones(numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3)
									SELECT numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3
													  FROM bdinteg:"informix".si_direcciones_his WHERE numcte = cNumcte; 
							END  IF;							
							
							LET iflag_exist = 0;
							SELECT LIMIT 1 fecha_entrada, fecha_salida, fecha_insert, fecha_hora INTO dFecha_entrada,dFecha_salida,dFecha_insert,dFecha_hora --2021
							FROM 	bdisolic:"informix".ss_autorizacion
							WHERE empresa = '001' AND num_solicitud = cNum_solicitud;
							
							EXECUTE PROCEDURE bdisolic:"informix".sp_respaldo_ss_autorizacion(cNum_solicitud) INTO cCodSP;
							EXECUTE PROCEDURE bdisolic:"informix".sp_respaldo_ss_nuevo_parametrico(cEmpresa,cNum_solicitud) INTO cCodSP2;
						
							IF cCodSP <> '00000' THEN
								LET cCodRet = '00002'; --OCURRIO UN ERROR EJECUTANDO LOS RESPALDOS/ELIMINANDO DATOS
								COMMIT WORK;
								CONTINUE FOREACH;
							END IF;
							IF cCodSP2 <> '00000' THEN
								LET cCodRet = '00003'; --OCURRIO UN ERROR EJECUTANDO LOS RESPALDOS/ELIMINANDO DATOS
								COMMIT WORK;
								CONTINUE FOREACH;
							END IF;
							
							DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
							and grupo >= 26 and grupo <= 37 and tpo_persona = '01' and  num_solicitud = cNum_solicitud;  --12
								   
							DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
							and grupo >= 44 and grupo <= 47 and tpo_persona = '01' and  num_solicitud = cNum_solicitud;  --4

							DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
							and grupo in (16,49,50,51,52,53,54,55,56,57,63,64,65,66,67,60,68) and tpo_persona = '01' and  num_solicitud = cNum_solicitud;
							
							
							
							SELECT ingreso_mensual,tp_ingreso,periodo_ingreso INTO mIngreso,iTp_ingreso,iPeriodoIngreso FROM bdisolic: "informix".ss_resum_scor_fin WHERE empresa = '001' AND num_solicitud = cNum_solicitud;
							IF mIngreso IS NULL THEN
								LET mIngreso = '0';
							END IF;
							IF iTp_ingreso IS NULL THEN
								LET iTp_ingreso = '0';
							END IF;
							IF iPeriodoIngreso IS NULL THEN
								LET iPeriodoIngreso = '0';
							END IF;	
							
							EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(cEmpresa, "SISTEMA", cNum_solicitud, "PC","","Solicitud Precalificada por Sistema ") INTO cCodRet2;
							
							LET cCodRet = cCodRet2;
							
							SELECT NVL(numcte_ref,''),NVL(parentesco,''), NVL(nombre_ref,''),NVL(telefono_ref,'')
                            INTO creferencia1,cparentesco_1,cnombreref_1,ctelefono_1
                            FROM "informix".ss_refpersonales
                            WHERE num_solicitud = cNum_solicitud AND numcte_ref = 'R1';

                            IF NVL(creferencia1,'') ='' THEN
                                SELECT NVL(numcte_ref,''),NVL(parentesco,''), NVL(nombre_ref,''),NVL(telefono_ref,'')
                                INTO cConyuge,cparentesco_1,cnombreref_1,ctelefono_1
                                FROM "informix".ss_refpersonales
                                WHERE num_solicitud = cNum_solicitud AND numcte = cNumcte AND parentesco = 'E';
                            END IF;

                            SELECT NVL(numcte_ref,''),NVL(parentesco,''), NVL(nombre_ref,''),NVL(telefono_ref,'')
                            INTO creferencia2,cparentesco_2,cnombreref_2,ctelefono_2
                            FROM "informix".ss_refpersonales
                            WHERE num_solicitud = cNum_solicitud AND numcte_ref = 'R2';

							
							DELETE FROM bdisolic:ss_refpersonales WHERE num_solicitud = cNum_solicitud; 
														

							EXECUTE PROCEDURE bdisolic:"informix".califica_scoring_cjunk_precal(cEmpresa,
															cNum_solicitud,
															creferencia1,
															creferencia2,
															mIngreso,
															iTp_ingreso,                                                    
															iPeriodoIngreso, 
															cConyuge, 
															cnombreref_1,
															cnombreref_2,
															cparentesco_1,
															cparentesco_2,
															ctelefono_1 ,
															ctelefono_2 ,
															dMonto_solicitado) INTO cCodRet2;  
															
							IF cCodRet2 = '453' AND cCodRet = '000000'  THEN
								LET cCodRet= '000000'; -- ocurrio un error al calcular las variables del modelo2
								
							ELIF cCodRet2 <> '453' THEN
								LET cCodRet = cCodRet2;
							END IF;
							SELECT status_solicitud INTO cStatus_solicitud FROM bdisolic: ss_solicitudes WHERE empresa = '001' AND num_solicitud = cNum_solicitud;
					
							IF cStatus_solicitud = 'RT'  THEN
								EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(cEmpresa, "SISTEMA", cNum_solicitud, "CN","","Cancelacion por evaluaciÃ³n automÃ¡tica") INTO cCodRet;
							END IF;		
							
							UPDATE bdisolic:ss_autorizacion SET fecha_insert = dFecha_insert, fecha_entrada = dFecha_entrada, fecha_salida = dFecha_salida, fecha_hora = dFecha_hora WHERE empresa = '001' AND num_solicitud = cNum_solicitud AND status_solicitud = 'PC' ;
							
							
						END IF;
								
					END IF;
					LET bBandera        = '0';
					LET bReevaluado     = '0';
					LET mIngreso        =0;
					LET iTp_ingreso     =0;
					LET iPeriodoIngreso  =0;
					LET creferencia1        ='';
					LET creferenciaAUX        ='';
					LET creferencia2        ='';
					LET cnombreref_1        ='';
					LET cnombrerefAUX        ='';
					LET cnombreref_2        ='';
					LET cparentesco_1       ='';
					LET cparentescoAUX       ='';
					LET cparentesco_2       ='';
					LET ctelefono_1         ='';
					LET ctelefonoAUX         ='';
					LET ctelefono_2         ='';
					LET cConyuge            ='';
					
			END IF;		
		ELSE
			COMMIT WORK;
			CONTINUE FOREACH;		
		END IF;
	COMMIT WORK;
	
	END FOREACH;
	
	RETURN cCodRet;
	
END
END PROCEDURE
