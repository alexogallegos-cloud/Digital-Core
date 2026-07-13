CREATE PROCEDURE "informix".sp_obtvariables_pbehavior()
       RETURNING char(6);

--declaracion de variables
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(2);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE v_fecha						DATE;
DEFINE v_finmes						DATE;
DEFINE v_FechaMes12					DATE;
DEFINE v_FechaMes3					DATE;
DEFINE v_numcuentaq                 CHAR(20);
DEFINE v_evalua_cc					CHAR(1);
DEFINE v_sbanderahit				CHAR(1);
DEFINE v_mora12						integer;
DEFINE v_mora12_hist				integer;
DEFINE v_edad				integer;
DEFINE v_sexo				char(1);
DEFINE v_sdocorriente		DECIMAL(18,2);
DEFINE v_mnl				DECIMAL(18,2);
DEFINE v_pbl				DECIMAL(18,2);
DEFINE v_ldl				INTEGER;
DEFINE v_monto_ATM			DECIMAL(18,2);
DEFINE v_monto_ATM_hist 	DECIMAL(18,2);
DEFINE v_monto_ATM_act		DECIMAL(18,2);
DEFINE v_compraspsp			DECIMAL(18,2);
DEFINE v_compraspsp_hist    DECIMAL(18,2);
DEFINE v_compraspsp_act     DECIMAL(18,2);
DEFINE v_psp				DECIMAL(18,2);
DEFINE v_cma				INTEGER;
DEFINE v_snl				integer;
DEFINE v_mdl				integer;
DEFINE v_cms				integer;
DEFINE v_cmt				integer;
DEFINE v_cmn				integer;
DEFINE v_ppl				DECIMAL(18,2);
DEFINE v_adp				DECIMAL(18,4);
DEFINE v_adc				DECIMAL(18,4);
DEFINE v_adn				DECIMAL(18,4);
DEFINE v_bc_score			DECIMAL(18,4);
DEFINE v_adl				DECIMAL(18,4);
DEFINE v_adv4				DECIMAL(18,4);
--variables auxiliares historicos
DEFINE v_mora_actual		DECIMAL(18,4);
DEFINE v_menos_abonos		DECIMAL(18,4);
DEFINE v_sdo_pagar			DECIMAL(18,4);
DEFINE v_mnl_hist			DECIMAL(18,4);
DEFINE v_mnl_act			DECIMAL(18,4);
DEFINE v_mdl_hist			DECIMAL(18,4);
DEFINE v_ldl_hist			DECIMAL(18,4);
DEFINE v_cma_hist			DECIMAL(18,4);
DEFINE v_cms_hist			DECIMAL(18,4);
DEFINE v_cmt_hist			DECIMAL(18,4);
DEFINE v_cmn_hist			DECIMAL(18,4);
DEFINE v_snl_hist			DECIMAL(18,4);
DEFINE v_ppl_hist			DECIMAL(18,4);
--variable aux
DEFINE v_mes 				char(2);
DEFINE v_retiros			integer;
DEFINE v_pbls				decimal(18,2);

    --SET DEBUG FILE TO "/informix/janeth/nva_version/sp_obtvariables_pbehavior.out";
    --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET v_fecha				= DATE(1);
	  LET v_finmes				= DATE(1);
	  LET v_FechaMes12			= DATE(1);
	  LET v_FechaMes3			= DATE(1);
	  LET v_numcuentaq      	= '';
	  LET v_evalua_cc			= '';
	  LET v_mora12				= 0;
	  LET v_mora12_hist			= 0;
	  LET v_edad				= 0;
	  LET v_sexo				='';
	  LET v_sdocorriente		= 0;
	  LET v_mnl					= 0;
	  LET v_pbl					= 0;
	  LET v_snl					= 0;
	  LET v_mdl					= 0;
	  LET v_ldl					= 0;
	  LET v_monto_ATM			= 0;
	  LET v_monto_ATM_hist 	    = 0;
	  LET v_monto_ATM_act		= 0;
	  LET v_compraspsp			= 0;
	  LET v_compraspsp_hist     = 0;
      LET v_compraspsp_act      = 0;
	  LET v_psp					= 0;
	  LET v_cma					= 0;
	  LET v_cms					= 0;
	  LET v_cmt					= 0;
	  LET v_cmn					= 0;
	  LET v_ppl					= 0;
	  LET v_adp					= 0;
	  LET v_adc					= 0;
	  LET v_adn					= 0;
	  LET v_bc_score			= 0;
	  LET v_adl					= 0;
	  LET v_adv4				= 0;
	  LET v_sbanderahit 		= '';
	  --variables auxiliares historicos
	  LET v_mora_actual		    = 0;
	  LET v_menos_abonos		= 0;
	  LET v_sdo_pagar			= 0;
	  LET v_mnl_hist			= 0;
	  LET v_mnl_act				= 0;
	  LET v_mdl_hist			= 0;
	  LET v_ldl_hist			= 0;
	  LET v_cma_hist			= 0;
      LET v_cms_hist			= 0;
      LET v_cmt_hist			= 0;
      LET v_cmn_hist			= 0;
	  LET v_snl_hist			= 0;
      LET v_ppl_hist			= 0;
--variables aux
	  LET v_mes					='';
	  LET v_retiros				= 0;
	  LET v_pbls				= 0;
	  
	  BEGIN

ON EXCEPTION SET sql_err, isam_err, error_info
	LET cCod_ret = sql_err;
	LET cMensaje = error_info;
	RETURN cCod_ret;
END EXCEPTION;

   
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;
	--obtengo las fechas
	select date(pri_dia_mes)-1,
		   date((date(pri_dia_mes)-1) - 11 units month),
		   date((date(pri_dia_mes)-1) - 2 units month)
	INTO v_finmes,v_FechaMes12,v_FechaMes3
     FROM "informix".sd_fechas 
	WHERE	empresa = '001';

	truncate table sd_varbehavior drop storage;
            
FOREACH WITH HOLD

	SELECT num_credito 
      INTO v_numcuentaq
      FROM bdicred:sd_maecredcont
     WHERE empresa = '001'
	   AND num_producto = '6001'
	   AND fecha = v_finmes  
		--and num_credito in ('600000005089','600000005527','600000006988','600000008935','600000016698')
      
		
		select a.fecha,trunc((a.fecha-b.fecha_nac)/365,0) edad,b.sexo sexo,nvl(c.sdo_cap_insoluto,0) saldo_corriente,
			c.mto_fin_ven_trasp mora
			into v_fecha,v_edad,v_sexo,v_sdocorriente,v_mora_actual
	      from bdicred:sd_maecredcont a
		  left outer join bdinteg:si_ctepf b on (a.empresa=b.empresa and a.numcte=b.numcte)
		  left outer join bdicred:sd_maesdoshist c on (a.empresa=c.empresa and a.num_credito=c.num_credito and c.fecha= mdy(month(v_finmes),20,year(v_finmes)))
		where a.empresa='001'
		and a.fecha = v_finmes
		and a.num_credito = v_numcuentaq;
		
		--obtengo los moras historicos
		select mora12
		INTO v_mora12_hist
		from sd_varbehavior_hist
		where num_credito = v_numcuentaq;
		
		if v_mora_actual is null then let v_mora_actual = 0;  end if;
		if v_mora12_hist is null then let v_mora12_hist = 0;  end if;
		
		--obtengo la mora12
		if v_mora_actual >= v_mora12_hist then
			LET v_mora12 = v_mora_actual;
		else
			LET v_mora12 = v_mora12_hist;
		end if;
		
		if v_mora12 is null then let v_mora12 = 0;  end if;
	   --obtengo hit o no hit
	   select evalua_cc
		into v_evalua_cc
		from bdisolic:ss_resum_scor_fin
		where num_solicitud = v_numcuentaq;
		
		--obtengo banderahit
		if v_evalua_cc = 'X' and v_mora12 = 0 then
			let v_sbanderahit = 'N';
		elif v_evalua_cc <> 'X' and v_mora12 = 0 then
			let v_sbanderahit = 'S';
		elif v_mora12 > 0 then
			let v_sbanderahit = 'D';
		elif v_evalua_cc is null then
			let v_sbanderahit = 'D';
		end if;
	   
	   --obtengo las variable MNL de la historica
		select mnl
		into v_mnl_hist
		from bdicred:sd_varbehavior_hist
		where num_credito = v_numcuentaq;
		
		--MNL
		--sacar los ultimos retiros en efectivo de los ultimos 12 meses
		select nvl(count(num_credito),0) retiros
				into v_mnl_act --into v_retiros
				from bdicred:sd_movhis
				where empresa='001'
				and fecha_mov between mdy(month(v_finmes),01,year(v_finmes)) and v_finmes
				and codigo_fun ='002'
				and codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64,65)
				and num_credito = v_numcuentaq
				and reversado='N';
			
		LET v_mnl = v_mnl_hist + v_mnl_act;
		
		if v_mnl is null then let v_mnl = 0;  end if;
		
		--PBL
		--sacamos los saldos de los ultimos tres meses
		select max(sdo_cap_insoluto) sdo_maxult3mes
		into v_pbls
		from bdicred:sd_maesdoscont 
		where empresa='001'
		and fecha between  v_FechaMes3 and  v_finmes
		and num_credito = v_numcuentaq;
		
		if v_pbls > 0 then
			select trunc((v_pbls/monto_otorgado)*100)
			into v_pbl
			from bdicred:sd_maesdoscont 
			where empresa='001'
			and fecha = v_finmes
			and num_credito = v_numcuentaq;
		else 
			let v_pbl = 0;
		end if;
		
		if v_pbls is null then let v_pbls = 0;  end if;
		if v_pbl is null then let v_pbl = 0;  end if;
		
		--SNL, PPL
		--número de ciclos donde pagos menor que pago minimo en los ultimos 12 meses
		select menos_abonos,sdo_pagar
		into v_menos_abonos, v_sdo_pagar
		from bdicred:sd_info_edocta --bdicred@pld_tcp:sd_encabezado2_edocta a
		where fecha_emision = mdy(month(v_finmes),20,year(v_finmes))
		and num_credito = v_numcuentaq;
		
		--obtengo las variable SNL, PPL de la historica
		select snl,ppl
		into v_snl_hist,v_ppl_hist
		from bdicred:sd_varbehavior_hist
		where num_credito = v_numcuentaq;
		
		--SNL 
		if v_menos_abonos < v_sdo_pagar then
			let v_snl = v_snl_hist + 1;
		else
			let v_snl = v_snl_hist;
		end if;
		--PPL 
		if v_menos_abonos >= v_sdo_pagar then
			let v_ppl = v_ppl_hist + 1;
		else
			let v_ppl = v_ppl_hist;
		end if;
		
		if v_snl is null then let v_snl = 0;  end if;
		if v_ppl is null then let v_ppl = 0;  end if;
		
		
		--MDL, LDL, CMA, CMS, CMT, CMN
		--obtener los numero de moras de los ultimos 36 ciclos
		select mdl,ldl,cma,cms,cmt,cmn
		into v_mdl_hist,v_ldl_hist,v_cma_hist,v_cms_hist,v_cmt_hist,v_cmn_hist
		from bdicred:sd_varbehavior_hist
		where num_credito = v_numcuentaq;
		
		--MDL (maxima morosidad de los ultimos 36 meses)
		if v_mora_actual > v_mdl_hist then
			let v_mdl = v_mora_actual;
		else
			let v_mdl = v_mdl_hist;
		end if;
		
		--LDL (Morosidad en el ultimo ciclo)
		LET v_ldl = v_mora_actual;
		
		--CMA (Contador Mora al dia ultimo año)
		if v_mora_actual = 0 then
			LET v_cma = v_cma_hist + 1;
		else
			LET v_cma = v_cma_hist;
		end if;
		
		--CMS (Contador Mora al dia ultimo semestre)
		if v_mora_actual = 0 then
			LET v_cms = v_cms_hist + 1;
		else
			LET v_cms = v_cms_hist;
		end if;
		
		--CMT (Contador Mora al dia ultimo trimestre)
		if v_mora_actual = 0 then
			LET v_cmt = v_cmt_hist + 1;
		else
			LET v_cmt = v_cmt_hist;
		end if;
		
		--CMN (contador mora 90 ultimo año)
		if v_mora_actual >= 3 then
			LET v_cmn = v_cmn_hist +1;
		else
			LET v_cmn = v_cmn_hist;
		end if;
		
		if v_mdl is null then let v_mdl = 0;  end if; if v_ldl is null then let v_ldl = 0;  end if;
		if v_cma is null then let v_cma = 0;  end if; if v_cms is null then let v_cms = 0;  end if;
		if v_cmt is null then let v_cmt = 0;  end if; if v_cmn is null then let v_cmn = 0;  end if;
		
		
		--obtengo las resultados variables  psp de la historica
		select monto_ATM,compraspsp
		into v_monto_ATM_hist,v_compraspsp_hist
		from bdicred:sd_varbehavior_hist
		where num_credito = v_numcuentaq;
		
		if v_monto_ATM_hist is null then let v_monto_ATM_hist = 0;  end if; 
		if v_compraspsp_hist is null then let v_compraspsp_hist = 0;  end if;
		
		select 
		(select nvl(sum(monto),0)
				from bdicred:sd_movhis
				where empresa=a.empresa
				and fecha_mov between mdy(month(a.fecha),01,year(a.fecha)) and a.fecha
				and codigo_fun ='002'
				and codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64,65)
				and num_credito=a.num_credito
				and reversado='N') monto_ATM_act,
		(select  nvl(sum(monto),0)
					from bdicred:sd_movhis
					where a.empresa=empresa
					and fecha_mov between mdy(month(a.fecha),01,year(a.fecha)) and a.fecha
					and codigo_fun ='002'
					and codigo_ref in (37,57,937,938)
					and a.num_credito = num_credito
					and reversado='N') compraspsp_act
		into v_monto_ATM_act,v_compraspsp_act			
		from bdicred:sd_maecredcont a
		where a.empresa='001'
		and a.num_credito = v_numcuentaq
		and a.fecha = v_finmes;
		--into temp temp_retirospsp with no log;
		--create index inx_temp_retirospsp on temp_retirospsp(num_credito,monto_ATM,compraspsp) online;
		--update statistics high for table temp_retirospsp;
		
		let v_monto_ATM = v_monto_ATM_hist + v_monto_ATM_act;
		let v_compraspsp = v_compraspsp_hist + v_compraspsp_act;
				
		select case when b.adv159 is null then 9999999999 else b.adv159 end ADP,
        case when b.adv304 is null then 999 else b.adv304 end ADC,
        case when b.adv659 is null then 999 else b.adv659 end ADN,
        case when b.adv852 is null then 99999 else b.adv852 end BC_score,
        case when b.adv158 is null then 9999999999 else b.adv158 end ADL,
        case when b.adv4 is null then 999 else b.adv4 end adv4
		  into v_adp,v_adc,v_adn,v_bc_score,v_adl,v_adv4
		  from bdicred:sd_maecredcont a
        left outer join bdicred@pld_tcp:sd_adviser_mensual b on (a.num_credito=b.num_credito)
		where a.empresa='001'
          and a.fecha= v_finmes    
          and a.num_credito  = v_numcuentaq;
	
	   
	 insert into bdicred:sd_varbehavior (fecha,num_credito,mora12,edad,sexo,saldo_corriente,MNL,PBL,SNL,MDL,LDL,monto_ATM,compraspsp,CMA,CMS,CMT,CMN,PPL,ADP,
										ADC,ADN,BC_score,ADL,adv4,sbanderahit)
		values (v_fecha,v_numcuentaq,v_mora12,v_edad,v_sexo,v_sdocorriente,v_mnl,v_pbl,v_snl,v_mdl,v_ldl,v_monto_ATM,v_compraspsp,v_cma,v_cms,v_cmt,v_cmn,v_ppl,v_adp,
										v_adc,v_adn,v_bc_score,v_adl,v_adv4,v_sbanderahit);
	   
	END FOREACH; 
	

     RETURN cCod_ret;
	END;
	
END PROCEDURE;