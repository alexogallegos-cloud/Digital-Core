CREATE PROCEDURE "informix".sp_obtiene_pbehavior()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(2);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE v_numcuentaq                 CHAR(20);
DEFINE v_sresultado					CHAR(50);
DEFINE v_spuntaje					DECIMAL(18,4);
DEFINE v_finmes					     DATE;
--puntajes de las variables
DEFINE v_spuntaje_edad				DECIMAL(18,4);
DEFINE v_spuntaje_sexo				DECIMAL(18,4);
DEFINE v_spuntaje_sdo_corriente		DECIMAL(18,4);
DEFINE v_spuntaje_mnl				DECIMAL(18,4);
DEFINE v_spuntaje_pbl				DECIMAL(18,4);
DEFINE v_spuntaje_snl				DECIMAL(18,4);
DEFINE v_spuntaje_mdl				DECIMAL(18,4);
DEFINE v_spuntaje_ldl				DECIMAL(18,4);
DEFINE v_spuntaje_psp				DECIMAL(18,4);
DEFINE v_spuntaje_cma				DECIMAL(18,4);
DEFINE v_spuntaje_cms				DECIMAL(18,4);
DEFINE v_spuntaje_cmt				DECIMAL(18,4);
DEFINE v_spuntaje_cmn				DECIMAL(18,4);
DEFINE v_spuntaje_ppl				DECIMAL(18,4);
DEFINE v_spuntaje_adp				DECIMAL(18,4);
DEFINE v_spuntaje_adc				DECIMAL(18,4);
DEFINE v_spuntaje_adn				DECIMAL(18,4);
DEFINE v_spuntaje_bc_score			DECIMAL(18,4);		
DEFINE v_spuntaje_adl				DECIMAL(18,4);
DEFINE v_spuntaje_adv4				DECIMAL(18,4);
DEFINE v_spuntajev					DECIMAL(18,4); --variable para llevarme el valor
DEFINE v_sbanderahit				CHAR(1);
DEFINE v_edad				integer;
DEFINE v_sexo				char(1);
DEFINE v_sdocorriente		DECIMAL(18,2);
DEFINE v_mnl				DECIMAL(18,2);
DEFINE v_pbl				DECIMAL(18,2);
DEFINE v_ldl				INTEGER;
DEFINE v_psp				DECIMAL(18,2);
DEFINE v_cma				INTEGER;
DEFINE v_snl				integer;
DEFINE v_mdl				integer;
DEFINE v_cms				integer;
DEFINE v_cmt				integer;
DEFINE v_cmn				integer;
DEFINE v_ppl				integer;
DEFINE v_adp				DECIMAL(18,4);
DEFINE v_adc				DECIMAL(18,4);
DEFINE v_adn				DECIMAL(18,4);
DEFINE v_bc_score			DECIMAL(18,4);
DEFINE v_adl				DECIMAL(18,2);
DEFINE v_adv4				DECIMAL(18,4);
DEFINE i integer;
DEFINE v_cont integer;

    --SET DEBUG FILE TO "/informix/janeth/nva_version/sp_obtiene_pbehavior.out";
   --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET v_numcuentaq      	= '';
	  LET v_sresultado 			= '';
	  LET v_spuntaje 			= 0;
	  LET v_finmes				= DATE(1);
	  --puntajes de las variables
	  LET v_spuntaje_edad				= 0;
	  LET v_spuntaje_sexo				= 0;
	  LET v_spuntaje_sdo_corriente		= 0;
	  LET v_spuntaje_mnl				= 0;
	  LET v_spuntaje_pbl				= 0;
	  LET v_spuntaje_snl				= 0;
	  LET v_spuntaje_mdl				= 0;
	  LET v_spuntaje_ldl				= 0;
	  LET v_spuntaje_psp				= 0;
	  LET v_spuntaje_cma				= 0;
	  LET v_spuntaje_cms				= 0;
	  LET v_spuntaje_cmt				= 0;
	  LET v_spuntaje_cmn				= 0;
	  LET v_spuntaje_ppl				= 0;
	  LET v_spuntaje_adp				= 0;
	  LET v_spuntaje_adc				= 0;
	  LET v_spuntaje_adn				= 0;
	  LET v_spuntaje_bc_score			= 0;		
	  LET v_spuntaje_adl				= 0;
	  LET v_spuntaje_adv4				= 0;
	  LET v_spuntajev  			= 0; --variable para llevarme el puntaje
	  LET v_sbanderahit 		= '';
	  LET v_edad				= 0;
	  LET v_sexo				='';
	  LET v_sdocorriente		= 0;
	  LET v_mnl					= 0;
	  LET v_pbl					= 0;
	  LET v_snl					= 0;
	  LET v_mdl					= 0;
	  LET v_ldl					= 0;
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
	  
	  BEGIN

ON EXCEPTION SET sql_err, isam_err, error_info
	LET cCod_ret = sql_err;
	LET cMensaje = error_info;
	RETURN cCod_ret;
END EXCEPTION;

   
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;
--obtengo las fechas
	select date(pri_dia_mes)-1
	INTO v_finmes
     FROM "informix".sd_fechas 
	WHERE	empresa = '001';

	truncate table sd_behavior_puntaje drop storage;
            
FOREACH WITH HOLD

	SELECT num_credito 
      INTO v_numcuentaq
      FROM bdicred:sd_maecredcont
     WHERE empresa = '001'
	   AND num_producto = '6001'
	   AND fecha = v_finmes
	   --and num_credito in ('600003594568','600000005089','600000005527','600000006988','600000008935','600000016698')
	   
	--Obtener la edad
	select sbanderahit,edad,sexo,saldo_corriente,round(mnl/12,2),pbl,snl,mdl,ldl,
	case when compraspsp <= 0 then 0 else round((monto_ATM / compraspsp)*100,2) end psp,
	cma,cms,cmt,cmn,trunc((ppl/6)*100),adp,adc,adn,bc_score,adl,adv4
	into v_sbanderahit,v_edad,v_sexo,v_sdocorriente,v_mnl,v_pbl,v_snl,v_mdl,v_ldl,v_psp,v_cma,v_cms,v_cmt,v_cmn,v_ppl,v_adp,v_adc,v_adn,v_bc_score,v_adl,v_adv4
	from bdicred:sd_varbehavior
	where num_credito = v_numcuentaq;
	
	-- Puntajes a variables
		--Créditos que son Clean Thick Hit
		if v_sbanderahit = 'S' then
			--variable edad
			if v_edad <= 20 then
					let v_spuntaje_edad = -0.5041;
			elif  v_edad >= 21 and v_edad <= 25 then
					let v_spuntaje_edad = -0.5041;
			elif  v_edad >= 26 and v_edad <= 30 then
					let v_spuntaje_edad = -0.5041;
			elif  v_edad >= 31 and v_edad <= 35 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 36 and v_edad <= 40 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 41 and v_edad <= 45 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 46 and v_edad <= 50 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 51 and v_edad <= 55 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 56 and v_edad <= 60 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 61 and v_edad <= 65 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 66 and v_edad <= 70 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 71 and v_edad <= 75 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 76 and v_edad <= 80 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 81 then
					let v_spuntaje_edad = 0;
			end if;
			--variable sexo
			if v_sexo = 'M' then
				let v_spuntaje_sexo = -0.1551;
			elif v_sexo = 'F' then 
				let v_spuntaje_sexo = 0;
			end if;
			--variable sdo corriente
			if v_sdocorriente <= 0 then
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 0.1 and v_sdocorriente <= 500.99 then 
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 500.1 and v_sdocorriente <= 1000.99 then 
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 1000.1 and v_sdocorriente <= 2000.99 then 
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 2000.1 and v_sdocorriente <= 3000.99 then 
				let v_spuntaje_sdo_corriente = 0;
			elif v_sdocorriente >= 3000.1 and v_sdocorriente <= 4000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 4000.1 and v_sdocorriente <= 5000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 5000.1 and v_sdocorriente <= 6000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 6000.1 and v_sdocorriente <= 7000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 7000.1 and v_sdocorriente <= 8000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente >= 8000.1 and v_sdocorriente <= 9000.99 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			elif v_sdocorriente > 9000 then 
				let v_spuntaje_sdo_corriente = -0.8928;
			end if;
			--variable mnl
			if v_mnl <= 0 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.01 and v_mnl <= 0.08 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.09 and v_mnl <= 0.17 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.18 and v_mnl <= 0.25 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.26 and v_mnl <= 0.33 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.34 and v_mnl <= 0.50 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.51 and v_mnl <= 0.83 then
				let v_spuntaje_mnl = -0.3244;
			elif v_mnl >= 0.84 and v_mnl <= 1.08 then
				let v_spuntaje_mnl = -0.3244;
			elif v_mnl >= 1.09 and v_mnl <= 998 then
				let v_spuntaje_mnl = -0.3244;
			end if;
			--variable pbl
			if v_pbl <= 0 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 0.01 and v_pbl <= 30 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 31 and v_pbl <= 55 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 56 and v_pbl <= 75 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 76 and v_pbl <= 85 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 86 and v_pbl <= 90 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 91 and v_pbl <= 95 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 96 and v_pbl <= 100 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 101 and v_pbl <= 105 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl >= 106 and v_pbl <= 9999999999 then
				let v_spuntaje_pbl = -0.3538;
			elif v_pbl is null then
				let v_spuntaje_pbl = 0;
			end if;
			--variable SNL
			if v_snl <= 1 then
				let v_spuntaje_snl = 0;
			elif v_snl >= 2 and v_snl <= 12 then
				let v_spuntaje_snl = -0.1503;
			end if;
			--variable mdl
			if v_mdl = 0 then
				let v_spuntaje_mdl = 0;
			elif v_mdl = 1 then
				let v_spuntaje_mdl = -0.4655;
			elif v_mdl >= 2 and v_mdl <= 98 then
				let v_spuntaje_mdl = -0.4655;
			end if;
			--variable ldl
			if v_ldl <= 0 then
				let v_spuntaje_ldl = 0;
			elif v_ldl = 1 then
				let v_spuntaje_ldl = 0;
			elif v_ldl >= 1 then
				let v_spuntaje_ldl = 0;
			end if;
			--variable psp
			if v_psp <= 0 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 0.0001 and v_psp <= 25 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 25.01 and v_psp <= 115 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 115.01 and v_psp <= 845 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 845.01 and v_psp <= 9999999999 then
				let v_spuntaje_psp = 0;
			elif v_psp is null then
				let v_spuntaje_psp = 0;
			end if;
			--variable cma
			if v_cma = 0 then
				let v_spuntaje_cma = 0;
			elif v_cma = 1 then
				let v_spuntaje_cma = 0;
			elif v_cma = 2 then
				let v_spuntaje_cma = 0;
			elif v_cma = 3 then
				let v_spuntaje_cma = 0;
			elif v_cma = 4 then
				let v_spuntaje_cma = 0;
			elif v_cma = 5 then
				let v_spuntaje_cma = 0;
			elif v_cma = 6 then
				let v_spuntaje_cma = 0;
			elif v_cma = 7 then
				let v_spuntaje_cma = 0;
			elif v_cma = 8 then
				let v_spuntaje_cma = 0;
			elif v_cma = 9 then
				let v_spuntaje_cma = 0;
			elif v_cma = 10 then
				let v_spuntaje_cma = 0;
			elif v_cma = 11 then
				let v_spuntaje_cma = 0;
			elif v_cma = 12 then
				let v_spuntaje_cma = 0;
			end if;
			--variable cms
			if v_cms = 0 then
				let v_spuntaje_cms = 0;
			elif v_cms = 1 then
				let v_spuntaje_cms = 0;
			elif v_cms = 2 then
				let v_spuntaje_cms = 0;
			elif v_cms = 3 then
				let v_spuntaje_cms = 0;
			elif v_cms = 4 then
				let v_spuntaje_cms = 0;
			elif v_cms = 5 then
				let v_spuntaje_cms = 0;
			elif v_cms = 6 then
				let v_spuntaje_cms = 0;
			end if;
			--variable cmt
			if v_cmt = 0 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 1 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 2 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 3 then
				let v_spuntaje_cmt = 0;
			end if;
			--variable cmn
			if v_cmn = 0 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 1 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 2 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 3 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 4 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 5 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 6 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 7 then
				let v_spuntaje_cmn = 0;
			elif v_cmn >= 8 and v_cmn <= 12 then
				let v_spuntaje_cmn = 0;
			end if;
			--variable ppl
			if v_ppl <= 20 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 20 and v_ppl <= 35 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 35 and v_ppl <= 50 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 50 and v_ppl <= 70 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 70 and v_ppl <= 85 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 85 and v_ppl <= 100 then
				let v_spuntaje_ppl = 0;
			end if;
			--variable ADP
			if v_adp < 0 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 0 and v_adp <= 10.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 11 and v_adp <= 35.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 36 and v_adp <= 55.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 56 and v_adp <= 70.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 71 and v_adp <= 80.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 81 and v_adp <= 90.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp > 90 then
				let v_spuntaje_adp = 0;
			elif v_adp = 9999999999 then
				let v_spuntaje_adp = 0;
			end if;
			--variable adc
			if v_adc <= 1 then
				let v_spuntaje_adc = 0;
			elif v_adc = 2 then
				let v_spuntaje_adc = 0;
			elif v_adc = 3 then
				let v_spuntaje_adc = 0;
			elif v_adc = 4 then
				let v_spuntaje_adc = 0;
			elif v_adc > 4 and v_adc <= 6 then 
				let v_spuntaje_adc = 0;
			elif v_adc > 6 and v_adc <= 9 then 
				let v_spuntaje_adc = -0.2097;
			elif v_adc > 9 and v_adc <= 998 then 
				let v_spuntaje_adc = -0.2097;
			elif v_adc = 999 then
				let v_spuntaje_adc = 0;
			end if;
			--variable adn
			if v_adn <= 0 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=1;
				let v_spuntaje_adn = 0;
			elif v_adn >= 1 and v_adn <= 15.9999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=2;
				let v_spuntaje_adn = 0;
			elif v_adn >= 16 and v_adn <= 35.9999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=3;
				let v_spuntaje_adn = -0.1113;
			elif v_adn >= 36 and v_adn <= 50.9999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=4;
				let v_spuntaje_adn = -0.1113;
			elif v_adn >= 51 and v_adn <= 100.9999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=5;
				let v_spuntaje_adn = -0.1113;
			elif v_adn = 999 then
				--let v_scve_variable=17;
				--let v_ssubcve_variable=6;
				let v_spuntaje_adn = 0;
			end if;
			--variable bc score
			if v_bc_score >= 0 and v_bc_score <= 576 then
				let v_spuntaje_bc_score = -0.9051;
			elif v_bc_score >= 577 and v_bc_score <= 626 then
				let v_spuntaje_bc_score = -0.9051;
			elif v_bc_score >= 627 and v_bc_score <= 661 then
				let v_spuntaje_bc_score = -0.9051;
			elif v_bc_score >= 662 and v_bc_score <= 669 then
				let v_spuntaje_bc_score = -0.9051;
			elif v_bc_score >= 670 and v_bc_score <= 699 then
				let v_spuntaje_bc_score = -0.3533;
			elif v_bc_score >= 700 and v_bc_score <= 705 then
				let v_spuntaje_bc_score = -0.3533;
			elif v_bc_score >= 706 and v_bc_score <= 717 then
				let v_spuntaje_bc_score = -0.3533;
			elif v_bc_score >= 718 and v_bc_score <= 729 then
				let v_spuntaje_bc_score = -0.3533;
			elif v_bc_score >= 730 and v_bc_score <= 746 then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score > 746  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score = 99999  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score < 0  then
				let v_spuntaje_bc_score = 0;
			end if;
			--variable adl
			if v_adl < 0 then
				let v_spuntaje_adl = 0.6614;
			elif v_adl >= 0 and v_adl <= 35.9999 then
				let v_spuntaje_adl = 0.6614;
			elif v_adl >= 36 and v_adl <= 70.9999 then
				let v_spuntaje_adl = 0.6614;
			elif v_adl >= 71 and v_adl <= 90.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl > 90 then
				let v_spuntaje_adl = 0;
			elif v_adl = 9999999999 then
				let v_spuntaje_adl = 0;
			end if;
			--variable adv4
			if v_adv4 = 1 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 2 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 3 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 4 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 5 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 6 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 7 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 8 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 9 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 10 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 11 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 12 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 >= 13 and v_adv4 <= 998 then
				let v_spuntaje_adv4 = -0.0986;
			elif v_adv4 = 999 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 < 0 then
				let v_spuntaje_adv4 = 0;
			end if;
		end if;
		--Créditos que son Clean Thick No Hit
		if v_sbanderahit = 'N' then
			--variable edad
			if v_edad <= 20 then
					let v_spuntaje_edad = -0.3898;
			elif  v_edad >= 21 and v_edad <= 25 then
					let v_spuntaje_edad = -0.3898;
			elif  v_edad >= 26 and v_edad <= 30 then
					let v_spuntaje_edad = -0.3898;
			elif  v_edad >= 31 and v_edad <= 35 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 36 and v_edad <= 40 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 41 and v_edad <= 45 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 46 and v_edad <= 50 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 51 and v_edad <= 55 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 56 and v_edad <= 60 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 61 and v_edad <= 65 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 66 and v_edad <= 70 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 71 and v_edad <= 75 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 76 and v_edad <= 80 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 81 then
					let v_spuntaje_edad = 0;
			end if;
			--variable sexo
			if v_sexo = 'M' then
				let v_spuntaje_sexo = -0.2226;
			elif v_sexo = 'F' then 
				let v_spuntaje_sexo = 0;
			end if;
			--variable sdo corriente
			if v_sdocorriente <= 0 then
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 0.1 and v_sdocorriente <= 500.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 500.1 and v_sdocorriente <= 1000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 1000.1 and v_sdocorriente <= 2000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 2000.1 and v_sdocorriente <= 3000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 3000.1 and v_sdocorriente <= 4000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 4000.1 and v_sdocorriente <= 5000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 5000.1 and v_sdocorriente <= 6000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 6000.1 and v_sdocorriente <= 7000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 7000.1 and v_sdocorriente <= 8000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente >= 8000.1 and v_sdocorriente <= 9000.99 then 
					let v_spuntaje_sdo_corriente = -0.8321;
				elif v_sdocorriente > 9000 then 
					let v_spuntaje_sdo_corriente = -0.8321;
			end if;
			--variable mnl
			if v_mnl <= 0 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.01 and v_mnl <= 0.08 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.09 and v_mnl <= 0.17 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.18 and v_mnl <= 0.25 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.26 and v_mnl <= 0.33 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.34 and v_mnl <= 0.50 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.51 and v_mnl <= 0.83 then
				let v_spuntaje_mnl = -0.4308;
			elif v_mnl >= 0.84 and v_mnl <= 1.08 then
				let v_spuntaje_mnl = -0.4308;
			elif v_mnl >= 1.09 and v_mnl <= 998 then
				let v_spuntaje_mnl = -0.4308;
			end if;
			--variable pbl
			if v_pbl <= 0 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 0.01 and v_pbl <= 30 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 31 and v_pbl <= 55 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 56 and v_pbl <= 75 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 76 and v_pbl <= 85 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 86 and v_pbl <= 90 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 91 and v_pbl <= 95 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 96 and v_pbl <= 100 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 101 and v_pbl <= 105 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl >= 106 and v_pbl <= 9999999999 then
				let v_spuntaje_pbl = -0.4550;
			elif v_pbl is null then
				let v_spuntaje_pbl = 0;
			end if;
			--variable SNL
			if v_snl <= 1 then
				let v_spuntaje_snl = 0;
			elif v_snl >= 2 and v_snl <= 12 then
				let v_spuntaje_snl = 0;
			end if;
			--variable mdl
			if v_mdl = 0 then
				let v_spuntaje_mdl = 0;
			elif v_mdl = 1 then
				let v_spuntaje_mdl = -0.4399;
			elif v_mdl >= 2 and v_mdl <= 98 then
				let v_spuntaje_mdl = -0.4399;
			end if;
			--variable ldl
			if v_ldl <= 0 then
				let v_spuntaje_ldl = 0;
			elif v_ldl = 1 then
				let v_spuntaje_ldl = 0;
			elif v_ldl >= 1 then
				let v_spuntaje_ldl = 0;
			end if;
			--variable psp
			if v_psp <= 0 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 0.0001 and v_psp <= 25 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 25.01 and v_psp <= 115 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 115.01 and v_psp <= 845 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 845.01 and v_psp <= 9999999999 then
				let v_spuntaje_psp = 0;
			elif v_psp is null then
				let v_spuntaje_psp = 0;
			end if;
			--variable cma
			if v_cma = 0 then
				let v_spuntaje_cma = 0;
			elif v_cma = 1 then
				let v_spuntaje_cma = 0;
			elif v_cma = 2 then
				let v_spuntaje_cma = 0;
			elif v_cma = 3 then
				let v_spuntaje_cma = 0;
			elif v_cma = 4 then
				let v_spuntaje_cma = 0;
			elif v_cma = 5 then
				let v_spuntaje_cma = 0;
			elif v_cma = 6 then
				let v_spuntaje_cma = 0;
			elif v_cma = 7 then
				let v_spuntaje_cma = 0;
			elif v_cma = 8 then
				let v_spuntaje_cma = 0;
			elif v_cma = 9 then
				let v_spuntaje_cma = 0;
			elif v_cma = 10 then
				let v_spuntaje_cma = 0;
			elif v_cma = 11 then
				let v_spuntaje_cma = 0;
			elif v_cma = 12 then
				let v_spuntaje_cma = 0;
			end if;
			--variable cms
			if v_cms = 0 then
				let v_spuntaje_cms = 0;
			elif v_cms = 1 then
				let v_spuntaje_cms = 0;
			elif v_cms = 2 then
				let v_spuntaje_cms = 0;
			elif v_cms = 3 then
				let v_spuntaje_cms = 0;
			elif v_cms = 4 then
				let v_spuntaje_cms = 0;
			elif v_cms = 5 then
				let v_spuntaje_cms = 0;
			elif v_cms = 6 then
				let v_spuntaje_cms = 0;
			end if;
			--variable cmt
			if v_cmt = 0 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 1 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 2 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 3 then
				let v_spuntaje_cmt = 0;
			end if;
			--variable cmn
			if v_cmn = 0 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 1 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 2 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 3 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 4 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 5 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 6 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 7 then
				let v_spuntaje_cmn = 0;
			elif v_cmn >= 8 and v_cmn <= 12 then
				let v_spuntaje_cmn = 0;
			end if;
			--variable ppl
			if v_ppl <= 20 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 20 and v_ppl <= 35 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 35 and v_ppl <= 50 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 50 and v_ppl <= 70 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 70 and v_ppl <= 85 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 85 and v_ppl <= 100 then
				let v_spuntaje_ppl = 0;
			end if;
			--variable ADP
			if v_adp < 0 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 0 and v_adp <= 10.9999 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 11 and v_adp <= 35.9999 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 36 and v_adp <= 55.9999 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 56 and v_adp <= 70.9999 then
				let v_spuntaje_adp = 0.2854;
			elif v_adp >= 71 and v_adp <= 80.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp >= 81 and v_adp <= 90.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp > 90 then
				let v_spuntaje_adp = 0;
			elif v_adp = 9999999999 then
				let v_spuntaje_adp = 0;
			end if;
			--variable adc
			if v_adc <= 1 then
				let v_spuntaje_adc = 0;
			elif v_adc = 2 then
				let v_spuntaje_adc = 0;
			elif v_adc = 3 then
				let v_spuntaje_adc = 0;
			elif v_adc = 4 then
				let v_spuntaje_adc = -0.2213;
			elif v_adc > 4 and v_adc <= 6 then
				let v_spuntaje_adc = -0.2213;
			elif v_adc > 6 and v_adc <= 9 then 
				let v_spuntaje_adc = -0.2213;
			elif v_adc > 9 and v_adc <= 998 then 
				let v_spuntaje_adc = -0.2213;
			elif v_adc = 999 then
				let v_spuntaje_adc = 0;
			end if;
			--variable adn
			if v_adn <= 0 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 1 and v_adn <= 15.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 16 and v_adn <= 35.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 36 and v_adn <= 50.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 51 and v_adn <= 100.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn = 999 then
				let v_spuntaje_adn = 0;
			end if;
			--variable bc score
			if v_bc_score >= 0 and v_bc_score <= 576 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 577 and v_bc_score <= 626 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 627 and v_bc_score <= 661 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 662 and v_bc_score <= 669 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 670 and v_bc_score <= 699 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 700 and v_bc_score <= 705 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 706 and v_bc_score <= 717 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 718 and v_bc_score <= 729 then
				let v_spuntaje_bc_score = -0.7237;
			elif v_bc_score >= 730 and v_bc_score <= 746 then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score > 746  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score = 99999  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score < 0  then
				let v_spuntaje_bc_score = 0;
			end if;
			--variable adl
			if v_adl < 0 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 0 and v_adl <= 35.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 36 and v_adl <= 70.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 71 and v_adl <= 90.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl > 90 then
				let v_spuntaje_adl = 0;
			elif v_adl = 9999999999 then
				let v_spuntaje_adl = 0;
			end if;
			--variable adv4
			if v_adv4 = 1 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 2 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 3 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 4 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 5 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 6 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 7 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 8 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 9 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 10 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 11 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 12 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 >= 13 and v_adv4 <= 998 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 999 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 < 0 or v_adv4 > 12 then
				let v_spuntaje_adv4 = 0;
			end if;
		end if;
		--Créditos que son Dirty
		if v_sbanderahit = 'D' then
			--variable edad
			if v_edad <= 20 then
					let v_spuntaje_edad = -0.2261;
			elif  v_edad >= 21 and v_edad <= 25 then
					let v_spuntaje_edad = -0.2261;
			elif  v_edad >= 26 and v_edad <= 30 then
					let v_spuntaje_edad = -0.2261;
			elif  v_edad >= 31 and v_edad <= 35 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 36 and v_edad <= 40 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 41 and v_edad <= 45 then
					let v_spuntaje_edad = 0;
			elif  v_edad >= 46 and v_edad <= 50 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 51 and v_edad <= 55 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 56 and v_edad <= 60 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 61 and v_edad <= 65 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 66 and v_edad <= 70 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 71 and v_edad <= 75 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 76 and v_edad <= 80 then
					let v_spuntaje_edad = 0.1287;
			elif  v_edad >= 81 then
					let v_spuntaje_edad = 0;
			end if;
			--variable sexo
			if v_sexo = 'M' then
				let v_spuntaje_sexo = 0;
			elif v_sexo = 'F' then 
				let v_spuntaje_sexo = 0;
			end if;
			--variable sdo_corriente
			if v_sdocorriente <= 0.99 then
					let v_spuntaje_sdo_corriente = 0.541;
				elif v_sdocorriente >= 0.1 and v_sdocorriente <= 500.99 then 
					let v_spuntaje_sdo_corriente = 0.541;
				elif v_sdocorriente >= 500.1 and v_sdocorriente <= 1000.99 then 
					let v_spuntaje_sdo_corriente = 0.541;
				elif v_sdocorriente >= 1000.1 and v_sdocorriente <= 2000.99 then 
					let v_spuntaje_sdo_corriente = 0.541;
				elif v_sdocorriente >= 2000.1 and v_sdocorriente <= 3000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 3000.1 and v_sdocorriente <= 4000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 4000.1 and v_sdocorriente <= 5000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 5000.1 and v_sdocorriente <= 6000.99 then 
					let v_spuntaje_sdo_corriente = 0;
				elif v_sdocorriente >= 6000.1 and v_sdocorriente <= 7000.99 then 
					let v_spuntaje_sdo_corriente = -0.4399;
				elif v_sdocorriente >= 7000.1 and v_sdocorriente <= 8000.99 then 
					let v_spuntaje_sdo_corriente = -0.4399;
				elif v_sdocorriente >= 8000.1 and v_sdocorriente <= 9000.99 then 
					let v_spuntaje_sdo_corriente = -0.4399;
				elif v_sdocorriente > 9000 then 
					let v_spuntaje_sdo_corriente = -0.4399;
			end if;
			--variable mnl
			if v_mnl <= 0 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.01 and v_mnl <= 0.08 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.09 and v_mnl <= 0.17 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.18 and v_mnl <= 0.25 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.26 and v_mnl <= 0.33 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.34 and v_mnl <= 0.50 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.51 and v_mnl <= 0.83 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 0.84 and v_mnl <= 1.08 then
				let v_spuntaje_mnl = 0;
			elif v_mnl >= 1.09 and v_mnl <= 998 then
				let v_spuntaje_mnl = 0;
			end if;
			--varaible pbl
			if v_pbl <= 0 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 0.01 and v_pbl <= 30 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 31 and v_pbl <= 55 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 56 and v_pbl <= 75 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 76 and v_pbl <= 85 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 86 and v_pbl <= 90 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 91 and v_pbl <= 95 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 96 and v_pbl <= 100 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 101 and v_pbl <= 105 then
				let v_spuntaje_pbl = 0;
			elif v_pbl >= 106 and v_pbl <= 9999999999 then
				let v_spuntaje_pbl = 0;
			elif v_pbl is null then
				let v_spuntaje_pbl = 0;
			end if;
			--variable SNL
			if v_snl <= 1 then
				let v_spuntaje_snl = 0.2366;
			elif v_snl >= 2 and v_snl <= 12 then
				let v_spuntaje_snl = 0;
			end if;
			--variable mdl
			if v_mdl = 0 then
				let v_spuntaje_mdl = 0;
			elif v_mdl = 1 then
				let v_spuntaje_mdl = 0.3575;
			elif v_mdl >= 2 and v_mdl <= 98 then
				let v_spuntaje_mdl = 0;
			end if;
			--variable ldl
			if v_ldl <= 0 then
				let v_spuntaje_ldl = 0;
			elif v_ldl = 1 then
				let v_spuntaje_ldl = 0;
			elif v_ldl >= 1 then
				let v_spuntaje_ldl = -1.3508;
			end if;
			--variable psp
			if v_psp <= 0 then
				let v_spuntaje_psp = 0.1399;
			elif v_psp >= 0.0001 and v_psp <= 25 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 25.01 and v_psp <= 115 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 115.01 and v_psp <= 845 then
				let v_spuntaje_psp = 0;
			elif v_psp >= 845.01 and v_psp <= 9999999999 then
				let v_spuntaje_psp = 0;
			elif v_psp is null then
				let v_spuntaje_psp = 0;
			end if;
			--variable cma
			if v_cma = 0 then
				let v_spuntaje_cma = -0.3138;
			elif v_cma = 1 then
				let v_spuntaje_cma = -0.3138;
			elif v_cma = 2 then
				let v_spuntaje_cma = -0.3138;
			elif v_cma = 3 then
				let v_spuntaje_cma = 0;
			elif v_cma = 4 then
				let v_spuntaje_cma = 0;
			elif v_cma = 5 then
				let v_spuntaje_cma = 0;
			elif v_cma = 6 then
				let v_spuntaje_cma = 0;
			elif v_cma = 7 then
				let v_spuntaje_cma = 0;
			elif v_cma = 8 then
				let v_spuntaje_cma = 0.0807;
			elif v_cma = 9 then
				let v_spuntaje_cma = 0.0807;
			elif v_cma = 10 then
				let v_spuntaje_cma = 0.0807;
			elif v_cma = 11 then
				let v_spuntaje_cma = 0.1124;
			elif v_cma = 12 then
				let v_spuntaje_cma = 0.1124;
			end if;
			--variable cms
			if v_cms = 0 then
				let v_spuntaje_cms = -0.7038;
			elif v_cms = 1 then
				let v_spuntaje_cms = 0;
			elif v_cms = 2 then
				let v_spuntaje_cms = 0;
			elif v_cms = 3 then
				let v_spuntaje_cms = 0;
			elif v_cms = 4 then
				let v_spuntaje_cms = 0;
			elif v_cms = 5 then
				let v_spuntaje_cms = 0.1371;
			elif v_cms = 6 then
				let v_spuntaje_cms = 0.1371;
			end if;
			--variable cmt
			if v_cmt = 0 then
				let v_spuntaje_cmt = -0.336;
			elif v_cmt = 1 then
				let v_spuntaje_cmt = -0.336;
			elif v_cmt = 2 then
				let v_spuntaje_cmt = 0;
			elif v_cmt = 3 then
				let v_spuntaje_cmt = 0.6414;
			end if;
			--variable cmn
			if v_cmn = 0 then
				let v_spuntaje_cmn = 0;
			elif v_cmn = 1 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 2 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 3 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 4 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 5 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 6 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn = 7 then
				let v_spuntaje_cmn = -0.3281;
			elif v_cmn >= 8 and v_cmn <= 12 then
				let v_spuntaje_cmn = -0.3281;
			end if;
			--variable ppl
			if v_ppl <= 20 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 20 and v_ppl <= 35 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 35 and v_ppl <= 50 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 50 and v_ppl <= 70 then
				let v_spuntaje_ppl = 0;
			elif v_ppl > 70 and v_ppl <= 85 then
				let v_spuntaje_ppl = 0.1766;
			elif v_ppl > 85 and v_ppl <= 100 then
				let v_spuntaje_ppl = 0.3474;
			end if;
			--variable adp
			if v_adp < 0 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 0 and v_adp <= 10.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 11 and v_adp <= 35.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 36 and v_adp <= 55.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 56 and v_adp <= 70.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 71 and v_adp <= 80.9999 then
				let v_spuntaje_adp = 0.7086;
			elif v_adp >= 81 and v_adp <= 90.9999 then
				let v_spuntaje_adp = 0;
			elif v_adp > 90 then
				let v_spuntaje_adp = 0;
			elif v_adp = 9999999999 then
				let v_spuntaje_adp = 0;
			end if;
			--variable adc
			if v_adc <= 1 then
				let v_spuntaje_adc = 0;
			elif v_adc = 2 then
				let v_spuntaje_adc = 0;
			elif v_adc = 3 then
				let v_spuntaje_adc = 0;
			elif v_adc = 4 then
				let v_spuntaje_adc = 0;
			elif v_adc > 4 and v_adc <= 6 then 
				let v_spuntaje_adc = 0;
			elif v_adc > 6 and v_adc <= 9 then 
				let v_spuntaje_adc = 0;
			elif v_adc > 9 and v_adc <= 998 then 
				let v_spuntaje_adc = 0;
			elif v_adc = 999 then
				let v_spuntaje_adc = 0;
			end if;
			--variable adn
			if v_adn <= 0 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 1 and v_adn <= 15.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 16 and v_adn <= 35.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 36 and v_adn <= 50.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn >= 51 and v_adn <= 100.9999 then
				let v_spuntaje_adn = 0;
			elif v_adn = 999 then
				let v_spuntaje_adn = 0;
			end if;
			--variable bc socre
			if v_bc_score >= 0 and v_bc_score <= 576 then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score >= 577 and v_bc_score <= 626 then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score >= 627 and v_bc_score <= 661 then
				let v_spuntaje_bc_score = 0.6381;
			elif v_bc_score >= 662 and v_bc_score <= 669 then
				let v_spuntaje_bc_score = 0.6381;
			elif v_bc_score >= 670 and v_bc_score <= 699 then
				let v_spuntaje_bc_score = 0.6381;
			elif v_bc_score >= 700 and v_bc_score <= 705 then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score >= 706 and v_bc_score <= 717 then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score >= 718 and v_bc_score <= 729 then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score >= 730 and v_bc_score <= 746 then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score > 746  then
				let v_spuntaje_bc_score = 1.2889;
			elif v_bc_score = 99999  then
				let v_spuntaje_bc_score = 0;
			elif v_bc_score < 0  then
				let v_spuntaje_bc_score = 0;
			end if;
			--variable adl
			if v_adl < 0 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 0 and v_adl <= 35.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 36 and v_adl <= 70.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl >= 71 and v_adl <= 90.9999 then
				let v_spuntaje_adl = 0;
			elif v_adl > 90 then
				let v_spuntaje_adl = 0;
			elif v_adl = 9999999999 then
				let v_spuntaje_adl = 0;
			end if;
			--variable adv4
			if v_adv4 = 1 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 2 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 3 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 4 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 5 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 6 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 7 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 8 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 9 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 10 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 11 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 12 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 >= 13 and v_adv4 <= 998 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 = 999 then
				let v_spuntaje_adv4 = 0;
			elif v_adv4 < 0 or v_adv4 > 12 then
				let v_spuntaje_adv4 = 0;
			end if;
		end if;

	
	 --end for;
	 insert into bdicred:sd_behavior_puntaje (num_credito,spuntaje_edad,spuntaje_sexo,spuntaje_sdo_corriente,spuntaje_mnl,
												spuntaje_pbl,spuntaje_snl,spuntaje_mdl,spuntaje_ldl,spuntaje_psp,spuntaje_cma,
												spuntaje_cms,spuntaje_cmt,spuntaje_cmn,spuntaje_ppl,spuntaje_adp,spuntaje_adc,
												spuntaje_adn,spuntaje_bc_score,spuntaje_adl,spuntaje_adv4,sbanderahit)
			values (v_numcuentaq,v_spuntaje_edad,v_spuntaje_sexo,v_spuntaje_sdo_corriente,v_spuntaje_mnl,
					v_spuntaje_pbl,v_spuntaje_snl,v_spuntaje_mdl,v_spuntaje_ldl,v_spuntaje_psp,v_spuntaje_cma,
					v_spuntaje_cms,v_spuntaje_cmt,v_spuntaje_cmn,v_spuntaje_ppl,v_spuntaje_adp,v_spuntaje_adc,
					v_spuntaje_adn,v_spuntaje_bc_score,v_spuntaje_adl,v_spuntaje_adv4,v_sbanderahit);
	   
	
	END FOREACH; 
	
     RETURN cCod_ret;
	END;
	
END PROCEDURE;