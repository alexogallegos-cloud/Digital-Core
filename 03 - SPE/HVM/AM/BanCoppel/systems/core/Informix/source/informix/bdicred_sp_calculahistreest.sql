CREATE PROCEDURE "informix".sp_calculahistreest(cEmpresa CHAR(3),cFecha date)
												
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Calcula el cargo y abonos, para Reestructura
--Realizó: Richar 
--Fecha: 27/02/2015
--Modificacion:18 Nov del 2015
--Realizó: Richar
--Observaciones: Se calcula el saldo
--------------------------------------------------------------------													

    --DATOS A REGRESAR---	
	RETURNING CHAR(5);	--codret             
		
			  
	--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	
	DEFINE vFechaHoy date; --Para obtener la fecha de hoy desde la sd_fechas
    DEFINE vMontoFinDiaAnt  Money(18,2); --Para obtener el monto del saldo fin de la fecha anterior
	DEFINE vMontoFinDiaAct  Money(18,2); --Para obtener el monto del saldo fin de la fecha actual	
	DEFINE vTipProd			VarChar(4);
   
   
	--	Variables para las cuentas
	DEFINE vCtaCapVig 		Char(14);
	DEFINE vCtaCapExig 		Char(14);
	DEFINE vCtaCapNoExig 	Char(14);
	DEFINE vCtaCapTrans 	Char(14);
	DEFINE vCtaInteresVig 	Char(14);
	DEFINE vCtaInteresVen	Char(14);
	DEFINE vCtaInteresVenDOr Char(14);
	DEFINE vCtaIVAInteres	Char(14);
	DEFINE vCtaIVAInteresOr	Char(14);
	
	
	--Variables para los saldos del sif
	DEFINE vSdoCapVig 			Money(18,2);
	DEFINE vSdoCapExig 			Money(18,2);
	DEFINE vSdoCapNoExig 		Money(18,2);
	DEFINE vSdoCapTrans 		Money(18,2);
	DEFINE vSdoInteresVig 		Money(18,2);
	DEFINE vSdoInteresVen		Money(18,2);
	DEFINE vSdoInteresVenDOr 	Money(18,2);
	DEFINE vSdoIVAInteres		Money(18,2);
	DEFINE vSdoIVAInteresOr		Money(18,2);
	DEFINE vSdoInteresTransSif		Money(18,2);
	DEFINE vSdoInteresVencBTSif		Money(18,2);
	DEFINE vSdoInteresVencVPSif		Money(18,2);
	
	
	--Variables para los saldos del sif abono
	DEFINE vSdoCapVig_a 			Money(18,2);
	DEFINE vSdoCapExig_a 			Money(18,2);
	DEFINE vSdoCapNoExig_a 		Money(18,2);
	DEFINE vSdoCapTrans_a 		Money(18,2);
	DEFINE vSdoInteresVig_a 		Money(18,2);
	DEFINE vSdoInteresVen_a		Money(18,2);
	DEFINE vSdoInteresVenDOr_a 	Money(18,2);
	DEFINE vSdoIVAInteres_a		Money(18,2);
	DEFINE vSdoIVAInteresOr_a		Money(18,2);
	
	
	
	--Variables para los saldos del sif para el conteo de movimientos
	DEFINE vSdoCapVigCnt 			Money(18,2);
	DEFINE vSdoCapExigCnt 			Money(18,2);
	DEFINE vSdoCapNoExigCnt 		Money(18,2);
	DEFINE vSdoCapTransCnt 			Money(18,2);
	DEFINE vSdoInteresVigCnt 		Money(18,2);
	DEFINE vSdoInteresVenCnt		Money(18,2);
	DEFINE vSdoInteresVenDOrCnt 	Money(18,2);
	DEFINE vSdoIVAInteresCnt		Money(18,2);
	DEFINE vSdoIVAInteresOrCnt		Money(18,2);	
	--Variables para los saldos del sif abono para el conteo de movimientos
	DEFINE vSdoCapVig_aCnt 			Money(18,2);
	DEFINE vSdoCapExig_aCnt 			Money(18,2);
	DEFINE vSdoCapNoExig_aCnt 		Money(18,2);
	DEFINE vSdoCapTrans_aCnt		Money(18,2);
	DEFINE vSdoInteresVig_aCnt 		Money(18,2);
	DEFINE vSdoInteresVen_aCnt		Money(18,2);
	DEFINE vSdoInteresVenDOr_aCnt 	Money(18,2);
	DEFINE vSdoIVAInteres_aCnt		Money(18,2);
	DEFINE vSdoIVAInteresOr_aCnt	Money(18,2);
		
	
	--Variables para los saldos de contabilidad		
	/*DEFINE vSdoCapVigCont 		Money(18,2);
	DEFINE vSdoCapTransCont 	Money(18,2);
	DEFINE vSdoCapNoExigCont 	Money(18,2);
	DEFINE vSdoCapExigCont 		Money(18,2);
	DEFINE vSdoInteresVigCont 	Money(18,2);
	DEFINE vSdoInteresVenCont	Money(18,2);
	DEFINE vSdoInteresVenDOrCont Money(18,2);
	DEFINE vSdoIVAInteresCont	Money(18,2);
	DEFINE vSdoIVAInteresOrCont	Money(18,2);*/
	
	--Variables para los saldos totales del día
	DEFINE vSdoCapVigSif		 	Money(18,2);
	DEFINE vSdoCapExigSif			Money(18,2);
	DEFINE vSdoCapNoExigSif			Money(18,2);
	DEFINE vSdoCapTransSif			Money(18,2);
	DEFINE vSdoInteresVigSif		Money(18,2);
	DEFINE vSdoInteresVenSif		Money(18,2);
	DEFINE vSdoInteresVenDOrSif		Money(18,2);
	DEFINE vSdoIVAInteresSif		Money(18,2);
	DEFINE vSdoIVAInteresOrSif		Money(18,2);
	
	
	--Variables para obtener los saldos del foreach
	DEFINE v_num_credito          CHAR(20);
   DEFINE v_credito_externo      CHAR(20);
   DEFINE v_numcte               CHAR(20);
   DEFINE v_sucursal             CHAR(4);
   DEFINE v_fecha_apertura       DATE;
   DEFINE v_fecha_ult_mov        DATE;
   DEFINE v_plazo                INTEGER;
   DEFINE v_dias_acum_int        INTEGER;
   DEFINE v_monto_otorgado       DECIMAL(18,2);
   DEFINE v_sdo_intereses        DECIMAL(18,2);
   DEFINE v_provision_normal     DECIMAL(18,2);
   DEFINE v_sdo_cap_insoluto     DECIMAL(18,2);
   DEFINE v_sdo_global_int       DECIMAL(18,2);
   DEFINE v_sdo_acum_intper      DECIMAL(18,2);
   DEFINE v_sdo_capital          DECIMAL(18,2);
   DEFINE v_sdo_no_exig          DECIMAL(18,2);
   DEFINE v_iva_vigente          DECIMAL(18,2);
   DEFINE v_mto_venc_tra_int     DECIMAL(18,2);
   DEFINE v_iva_exigible         DECIMAL(18,2);
   DEFINE v_iva_no_exigible      DECIMAL(18,2);
   DEFINE v_monto_vencido        DECIMAL(18,2);
   DEFINE v_sdo_exig_int         DECIMAL(18,2);
   DEFINE v_iva_transitorio      DECIMAL(18,2);
   DEFINE v_mto_venc_trasp       DECIMAL(18,2);
   DEFINE v_cap_tras_no_venci    DECIMAL(18,2);
   DEFINE v_int_tra_no_exig      DECIMAL(18,2);
   DEFINE v_capital_mto_cuota    DECIMAL(14,2);
   DEFINE v_tasa_interes         DECIMAL(9,6);
   DEFINE v_iva                  CHAR(5);
   DEFINE v_fecha_vencim         DATE;
   DEFINE v_fecha_cuota          DATE;
   DEFINE v_producto             CHAR(4);
   DEFINE v_num_cta              CHAR(20);
   DEFINE v_ano_wk               CHAR(04);
   DEFINE v_fecha                CHAR(06);
   DEFINE v_sepa                 CHAR(2);
   DEFINE v_ruta                 CHAR(26);
   DEFINE v_status_cred          CHAR(2);
   DEFINE v_promotor             CHAR(8);
   DEFINE v_pagos_venc           SMALLINT;
    
  
	
		
	--Banderas
	DEFINE v_paso				varchar(50);
	
	--INICIALIZACION DE VARIABLES--
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	
	--Definimos todas las cuentas contables
	
	LET vCtaCapVig = '13110102010032';
	LET vCtaCapExig = '13610102010132';
	LET vCtaCapNoExig = '13610102010232';
	LET vCtaCapTrans = '13110102030032';
	LET vCtaInteresVig = '13110102020032';
	LET vCtaInteresVen = '13610102020032';	
	LET vCtaInteresVenDOr = '77106101020132';	
	LET vCtaIVAInteres = '14020305110432';
	LET vCtaIVAInteresOr = '78376101020132';
	
	
	 LET v_num_credito          = '';
   LET v_credito_externo      = '';
   LET v_numcte               = '';
   LET v_sucursal             = '';
   LET v_fecha_apertura       = '';
   LET v_fecha_ult_mov        = '';
   LET v_plazo                = 0;
   LET v_sdo_intereses        = 0;
   LET v_provision_normal     = 0;
   LET v_dias_acum_int        = 0;
   LET v_sdo_cap_insoluto     = 0;
   LET v_sdo_global_int       = 0;
   LET v_sdo_acum_intper      = 0;
   LET v_sdo_capital          = 0;
   LET v_sdo_no_exig          = 0;
   LET v_iva_vigente          = 0;
   LET v_mto_venc_tra_int     = 0;
   LET v_iva_exigible         = 0;
   LET v_iva_no_exigible      = 0;
   LET v_monto_vencido        = 0;
   LET v_sdo_exig_int         = 0;
   LET v_mto_venc_trasp       = 0;
   LET v_iva_transitorio      = 0;
   LET v_cap_tras_no_venci    = 0;
   LET v_int_tra_no_exig      = 0;
   LET v_monto_otorgado       = '';
   LET v_capital_mto_cuota    = '';
   LET v_tasa_interes         = '';
   LET v_fecha_vencim         = '';
   LET v_fecha_cuota          = '';
   LET v_producto             = '';
   LET v_num_cta              = '';
			
	LET vSdoCapVigSif				= 0;
	LET vSdoCapExigSif				= 0;
	LET vSdoCapNoExigSif			= 0;
	LET vSdoCapTransSif				= 0;
	LET vSdoInteresVigSif			= 0;
	LET vSdoInteresVenSif			= 0;
	LET vSdoInteresVenDOrSif		= 0;
	LET vSdoIVAInteresSif			= 0;
	LET vSdoIVAInteresOrSif			= 0;
	LET vSdoInteresTransSif 		= 0;
	LET vSdoInteresVencBTSif = 0;
	LET vSdoInteresVencVPSif = 0;
	
	LET vTipProd='RTC';	
	LET v_paso ='';
		
	--SET DEBUG FILE TO "sp_calculahistreest.out";
	--TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--Obtenemos la fecha del día de hoy de la sd_fechas
		select fecha_hoy 
		into vFechaHoy
		from bdicred:sd_fechas;

		If vFechaHoy = '' or vFechaHoy is null then
			LET vFechaHoy = today();
		End if;
		
		
		IF cFecha is null or cFecha='' then		
			select fecha_ant 
			into cFecha
			from bdicred:sd_fechas;		
		End if;		
		
		--Calculamos los saldos
		
	 FOREACH  
		  SELECT  {+INDEX (sd_maecredcrd idx_maecrd)}
				  a.num_credito    , b.numcte           , b.sucursal     ,b.fecha_apertura   , a.fecha_ult_mov,
				  a.sdo_intereses  , a.provision_normal , a.dias_acum_int, a.sdo_cap_insoluto, a.sdo_global_int,
				  a.sdo_acum_intper, a.monto_otorgado   , a.sdo_capital,
				  a.mto_venc_trasp , a.cap_tras_no_venci, a.monto_vencido, b.status_cred, b.ejecutivo

		  INTO    v_num_credito    , v_numcte            , v_sucursal       , v_fecha_apertura   , v_fecha_ult_mov,
				  v_sdo_intereses  , v_provision_normal  , v_dias_acum_int  , v_sdo_cap_insoluto , v_sdo_global_int,
				  v_sdo_acum_intper, v_monto_otorgado    , v_sdo_capital    ,
				  v_mto_venc_trasp , v_cap_tras_no_venci ,  v_monto_vencido ,v_status_cred, v_promotor

		  FROM    sd_maesdoscrd a, sd_maecredcrd b
		  WHERE   a.empresa     = cEmpresa
		  AND     b.empresa     = cEmpresa
		  AND     a.num_credito = b.num_credito
		  AND     a.empresa     = b.empresa
		  AND     b.num_producto = '6011'   --FMV 17-MAY-2011: Se omite producto para que genere todos los Producto
		  ORDER BY b.num_producto, b.fecha_apertura  --FMV 09-JUN-2011: Se ordena por Producto

			select sum(case when capital_status in ('1','3') then (nvl(interes_debe,0)-nvl(interes_pagado,0)) else 0 end)interes_vigente,
				   sum(case when capital_status in ('1','3') then (nvl(iva_debe,0)-nvl(iva_pagado,0)) else 0 end)iva_vigente,
				   sum(case when capital_status='2' then (nvl(interes_debe,0)-nvl(interes_pagado,0)) else 0 end)interes_vencido,
				   sum(case when capital_status='2' then (nvl(iva_debe,0)-nvl(iva_pagado,0)) else 0 end)iva_vencido,
				   sum(case when capital_status in ('1','3') then (nvl(interes_debe,0)-nvl(interes_pagado,0)) else 0 end)interes_no_exigible,
				   sum(case when capital_status in ('1','3') then (nvl(iva_debe,0)-nvl(iva_pagado,0)) else 0 end)iva_no_exigible,
				   sum(case when capital_status in ('7') then (nvl(interes_debe,0)-nvl(interes_pagado,0)) else 0 end)interes_transitorio,
				   sum(case when capital_status in ('7') then (nvl(iva_debe,0)-nvl(iva_pagado,0)) else 0 end)iva_transitorio,              
				   sum(case when capital_status in ('2','7') then 1 else 0 end) as pagos_vencidos
			  into v_sdo_no_exig,
				   v_iva_vigente,
				   v_mto_venc_tra_int,
				   v_iva_exigible,
				   v_int_tra_no_exig,
				   v_iva_no_exigible,
				   v_sdo_exig_int,
				   v_iva_transitorio,
				   v_pagos_venc
			  from bdicred:sd_amortiza_creditocrd
			 where empresa=cEmpresa
			   and num_credito=v_num_credito
			   and capital_status in ('2','7','1','3');

			if v_sdo_no_exig is null then let v_sdo_no_exig = 0; end if; 
			if v_iva_vigente is null then let v_iva_vigente = 0; end if; 
			if v_mto_venc_tra_int is null then let v_mto_venc_tra_int = 0; end if; 
			if v_iva_exigible is null then let v_iva_exigible = 0; end if; 
			if v_int_tra_no_exig is null then let v_int_tra_no_exig = 0; end if; 
			if v_iva_no_exigible is null then let v_iva_no_exigible = 0; end if; 
			if v_sdo_exig_int is null then let v_sdo_exig_int = 0; end if; 
			if v_iva_transitorio is null then let v_iva_transitorio = 0; end if; 
			if v_pagos_venc is null then let v_pagos_venc = 0; end if; 

			   IF v_sdo_capital>0 THEN
				  LET v_int_tra_no_exig=0;
				  LET v_iva_no_exigible=0;
			   ELIF v_cap_tras_no_venci>0 THEN
				  LET v_sdo_no_exig=0;
				  LET v_iva_vigente=0;
			   END IF;
			   
			LET vSdoCapVigSif = (case when v_status_cred in ('AA','BA') then NVL(v_sdo_capital,0) + vSdoCapVigSif else vSdoCapVigSif end);
			LET vSdoCapExigSif = (case when v_status_cred in ('BT','VP') then NVL(v_mto_venc_trasp,0) + vSdoCapExigSif else vSdoCapExigSif end);
			LET vSdoCapNoExigSif = (case when v_status_cred in ('BT','VP') then NVL(v_cap_tras_no_venci,0) + vSdoCapNoExigSif else vSdoCapNoExigSif end);
			LET vSdoCapTransSif = (case when v_status_cred in ('BA') then NVL(v_monto_vencido,0) + vSdoCapTransSif else vSdoCapTransSif end);
			
			--Interes vigente = v_provision_normal mas BA + AA + Interes Transitorio BA
			LET vSdoInteresTransSif = (case when v_status_cred in ('BA') then NVL(v_sdo_exig_int,0) else vSdoInteresTransSif end);			
			LET vSdoInteresVigSif = vSdoInteresTransSif + vSdoInteresVigSif;
			LET vSdoInteresVigSif = (case when v_status_cred in ('AA','BA') then NVL(v_provision_normal,0) + vSdoInteresVigSif else vSdoInteresVigSif end);
			----------------------------------------------			
			
			--Interes Vencido
			LET vSdoInteresVencBTSif = (case when v_status_cred in ('BT') then NVL(v_provision_normal,0) + NVL(v_mto_venc_tra_int,0) else vSdoInteresVencBTSif end);
			LET vSdoInteresVencVPSif = (case when v_status_cred in ('VP') then NVL(v_provision_normal,0) + NVL(v_mto_venc_tra_int,0) else vSdoInteresVencVPSif end);
			
			LET vSdoInteresVenSif = (NVL(vSdoInteresVencBTSif,0) + NVL(vSdoInteresVencVPSif,0)) + vSdoInteresVenSif;	
			---------------------------
			
			
			LET vSdoInteresVenDOrSif = (NVL(v_mto_venc_tra_int,0) + NVL(v_int_tra_no_exig,0)) + vSdoInteresVenDOrSif;
			LET vSdoIVAInteresSif = (NVL(v_iva_vigente,0) + NVL(v_iva_exigible,0) + NVL(v_iva_no_exigible,0) + NVL(v_iva_transitorio,0)) + vSdoIVAInteresSif;
			LET vSdoIVAInteresOrSif = (NVL(v_iva_vigente,0) + NVL(v_iva_exigible,0) + NVL(v_iva_no_exigible,0) + NVL(v_iva_transitorio,0)) + vSdoIVAInteresOrSif;
		
			LET vSdoInteresVencBTSif = 0;
			LET vSdoInteresTransSif = 0;
			LET vSdoInteresVencVPSif = 0;		
		
	   END FOREACH;
	   
				
				--Calculamos los cargos y abonos de las cuentas para restructura										
			SELECT 
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaCapVig then monto else 0 End),0) as CapVig,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaCapVig then monto else 0 End),0) as CapVig_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaCapExig then monto else 0 End),0) as CapExig,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaCapExig then monto else 0 End),0) as CapExig_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaCapNoExig then monto else 0 End),0) as CapNoExig,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaCapNoExig then monto else 0 End),0) as CapNoExig_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaCapTrans then monto else 0 End),0) as CapTrans,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaCapTrans then monto else 0 End),0) as CapTrans_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaInteresVig then monto else 0 End),0) as InteresVig,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaInteresVig then monto else 0 End),0) as InteresVig_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaInteresVen then monto else 0 End),0) as InteresVen,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaInteresVen then monto else 0 End),0) as InteresVen_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaInteresVenDOr then monto else 0 End),0) as InteresVenDOr,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaInteresVenDOr then monto else 0 End),0) as InteresVenDOr_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaIVAInteres then monto else 0 End),0) as IVAInteres,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaIVAInteres then monto else 0 End),0) as IVAInteres_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaIVAInteresOr then monto else 0 End),0) as IVAInteresOr,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaIVAInteresOr then monto else 0 End),0) as IVAInteresOr_a
			INTO vSdoCapVig,vSdoCapVig_a, vSdoCapExig,vSdoCapExig_a, vSdoCapNoExig,vSdoCapNoExig_a, vSdoCapTrans,vSdoCapTrans_a, vSdoInteresVig,vSdoInteresVig_a, vSdoInteresVen,vSdoInteresVen_a, vSdoInteresVenDOr,vSdoInteresVenDOr_a, vSdoIVAInteres,vSdoIVAInteres_a, vSdoIVAInteresOr,vSdoIVAInteresOr_a
			FROM   sd_movhiscrd a, sd_transfun b,
				bdinteg:si_transacc c,
				bdinteg:si_prodtran d
			WHERE  a.codigo_fun = b.codigo_fun
				AND   a.codigo_ref = b.codigo_ref
				AND   numero = transacc
				AND   transaccion = transacc
				AND   d.sistema = c.sistema
				AND   a.empresa = cEmpresa
				AND   d.producto = '6011'				
				AND   a.fecha_mov >= cFecha;				


				
				SELECT 
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaCapVig then 1 else 0 End),0) as CapVig,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaCapVig then 1 else 0 End),0) as CapVig_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaCapExig then 1 else 0 End),0) as CapExig,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaCapExig then 1 else 0 End),0) as CapExig_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaCapNoExig then 1 else 0 End),0) as CapNoExig,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaCapNoExig then 1 else 0 End),0) as CapNoExig_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaCapTrans then 1 else 0 End),0) as CapTrans,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaCapTrans then 1 else 0 End),0) as CapTrans_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaInteresVig then 1 else 0 End),0) as InteresVig,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaInteresVig then 1 else 0 End),0) as InteresVig_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaInteresVen then 1 else 0 End),0) as InteresVen,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaInteresVen then 1 else 0 End),0) as InteresVen_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaInteresVenDOr then 1 else 0 End),0) as InteresVenDOr,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaInteresVenDOr then 1 else 0 End),0) as InteresVenDOr_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaIVAInteres then 1 else 0 End),0) as IVAInteres,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaIVAInteres then 1 else 0 End),0) as IVAInteres_a,
				NVL(Sum(Case When trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector)=vCtaIVAInteresOr then 1 else 0 End),0) as IVAInteresOr,
				NVL(Sum(Case When trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector)=vCtaIVAInteresOr then 1 else 0 End),0) as IVAInteresOr_a
			INTO vSdoCapVigCnt,vSdoCapVig_aCnt, vSdoCapExigCnt,vSdoCapExig_aCnt, vSdoCapNoExigCnt,vSdoCapNoExig_aCnt, vSdoCapTransCnt,vSdoCapTrans_aCnt, vSdoInteresVigCnt,vSdoInteresVig_aCnt, vSdoInteresVenCnt,vSdoInteresVen_aCnt, vSdoInteresVenDOrCnt,vSdoInteresVenDOr_aCnt, vSdoIVAInteresCnt,vSdoIVAInteres_aCnt, vSdoIVAInteresOrCnt,vSdoIVAInteresOr_aCnt
			FROM   sd_movhiscrd a, sd_transfun b,
				bdinteg:si_transacc c,
				bdinteg:si_prodtran d
			WHERE  a.codigo_fun = b.codigo_fun
				AND   a.codigo_ref = b.codigo_ref
				AND   numero = transacc
				AND   transaccion = transacc
				AND   d.sistema = c.sistema
				AND   a.empresa = cEmpresa
				AND   d.producto = '6011'				
				AND   a.fecha_mov = cFecha;										
						
						
															
				--Calculamos SdoCapVig
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaCapVig) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaCapVig;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)=vTipProd and trim(cc)=vCtaCapVig;
				
				LET vMontoFinDiaAct= vSdoCapVigSif; --(vMontoFinDiaAnt + vSdoCapVig) - vSdoCapVig_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', vTipProd, vCtaCapVig, cFecha, vSdoCapVig, vSdoCapVig_a, vSdoCapVigCnt, vSdoCapVig_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;		

				--Calculamos SdoCapExig
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaCapExig) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaCapExig;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)=vTipProd and trim(cc)=vCtaCapExig;
				
				LET vMontoFinDiaAct= vSdoCapExigSif; --(vMontoFinDiaAnt + vSdoCapExig) - vSdoCapExig_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', vTipProd, vCtaCapExig, cFecha, vSdoCapExig, vSdoCapExig_a, vSdoCapExigCnt, vSdoCapExig_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;						
				
				--Calculamos SdoCapNoExig
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaCapNoExig) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaCapNoExig;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)=vTipProd and trim(cc)=vCtaCapNoExig;
				
				LET vMontoFinDiaAct= vSdoCapNoExigSif; --(vMontoFinDiaAnt + vSdoCapNoExig) - vSdoCapNoExig_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', vTipProd, vCtaCapNoExig, cFecha, vSdoCapNoExig, vSdoCapNoExig_a, vSdoCapNoExigCnt, vSdoCapNoExig_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;			
				
				
				--Calculamos SdoCapTrans
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaCapTrans) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaCapTrans;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)=vTipProd and trim(cc)=vCtaCapTrans;
				
				LET vMontoFinDiaAct= vSdoCapTransSif; --(vMontoFinDiaAnt + vSdoCapTrans) - vSdoCapTrans_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', vTipProd, vCtaCapTrans, cFecha, vSdoCapTrans, vSdoCapTrans_a, vSdoCapTransCnt, vSdoCapTrans_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;			
				
				
				--Calculamos SdoInteresVig
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaInteresVig) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaInteresVig;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)=vTipProd and trim(cc)=vCtaInteresVig;
				
				LET vMontoFinDiaAct= vSdoInteresVigSif; --(vMontoFinDiaAnt + vSdoInteresVig) - vSdoInteresVig_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', vTipProd, vCtaInteresVig, cFecha, vSdoInteresVig, vSdoInteresVig_a, vSdoInteresVigCnt, vSdoInteresVig_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;		
				
				--Calculamos SdoInteresVen
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaInteresVen) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaInteresVen;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)=vTipProd and trim(cc)=vCtaInteresVen;
				
				LET vMontoFinDiaAct= vSdoInteresVenSif; --(vMontoFinDiaAnt + vSdoInteresVen) - vSdoInteresVen_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', vTipProd, vCtaInteresVen, cFecha, vSdoInteresVen, vSdoInteresVen_a, vSdoInteresVenCnt, vSdoInteresVen_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;		
								
				--Calculamos SdoInteresVenDOr
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaInteresVenDOr) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaInteresVenDOr;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)=vTipProd and trim(cc)=vCtaInteresVenDOr;
				
				LET vMontoFinDiaAct= vSdoInteresVenDOrSif; --(vMontoFinDiaAnt + vSdoInteresVenDOr) - vSdoInteresVenDOr_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', vTipProd, vCtaInteresVenDOr, cFecha, vSdoInteresVenDOr, vSdoInteresVenDOr_a, vSdoInteresVenDOrCnt, vSdoInteresVenDOr_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;		
				
				
				--Calculamos SdoIVAInteres
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaIVAInteres) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaIVAInteres;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)=vTipProd and trim(cc)=vCtaIVAInteres;
				
				LET vMontoFinDiaAct= vSdoIVAInteresSif; --(vMontoFinDiaAnt + vSdoIVAInteres) - vSdoIVAInteres_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', vTipProd, vCtaIVAInteres, cFecha, vSdoIVAInteres, vSdoIVAInteres_a, vSdoIVAInteresCnt, vSdoIVAInteres_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;	
				
				--Calculamos SdoIVAInteresOr
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaIVAInteresOr) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)=vTipProd and trim(cc)=vCtaIVAInteresOr;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)=vTipProd and trim(cc)=vCtaIVAInteresOr;
				
				LET vMontoFinDiaAct= vSdoIVAInteresOrSif; --(vMontoFinDiaAnt + vSdoIVAInteresOr) - vSdoIVAInteresOr_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', vTipProd, vCtaIVAInteresOr, cFecha, vSdoIVAInteresOr, vSdoIVAInteresOr_a, vSdoIVAInteresOrCnt, vSdoIVAInteresOr_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;					
				
							
--			LET cFecha= cFecha + 1;
			
			
				LET cCodRet = '00000';			
				RETURN cCodRet;		
				
	END;
	
END PROCEDURE;