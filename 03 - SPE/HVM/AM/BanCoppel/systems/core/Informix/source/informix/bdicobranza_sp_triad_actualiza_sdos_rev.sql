CREATE PROCEDURE "informix".sp_triad_actualiza_sdos_rev(pEjecucion smallint)

-- SPL para actualizar la tabla cb_triad_sdos_inds_tdc con la información histórica de 12 meses atrás


RETURNING char(6), CHAR(70);
 -- vers 1.0.3 20200626, 1.0.2 20190409
 define vEmpresa               char(3);
 define vmensaje               char(70);
 define vcodigo                char(10);
 define iSqlErr                integer;
 define error_data_var         VARCHAR(80);
 define isam_err               integer;
 define vFechaProceso          date;
 define c_Dia_ejecucion        char(2);
 define vFechacorte_24MesesAntes  date;
 define v_fecha_corte_ini      date;
 define v_fecha_corte_fin      date;
 define i_Dia_corte            integer; 
 define iContador              integer;
 define d_InteresesCargados    decimal(18,2);
 define d_Iva_IntsCargados     decimal(18,2);
 define d_Total_IntsCargados   decimal(18,2);
 define d_Dias                 decimal(4,2); 
 define i_Dias_parcial         integer;
 define i_Dias_parcial_2       integer;
 define vFechacorte            date; 
 define vFechacorteant         date;
 define v_fecha_corte_proxmes  date; 
 define v_fecha_corte_proxmes_ini  date; 
 define v_fecha_finmes_corte   date; 
 define vNum_credito           char(20);
 define vStatus_cred           char(4);
 define d_SaldoTotal           decimal(18,2); 
 define d_PagoMinimo           decimal(18,2);
 define d_SumaMontos_1         decimal(18,2);
 define d_SaldoTotalVencido    decimal(18,2);
 define i_Num_pos              integer;  
 define d_Monto_pos            decimal(18,2);
 define i_Num_atm              integer;
 define i_Num_vtn_ch           integer;  
 define d_Monto_atm            decimal(18,2);
 define d_Monto_vtn            decimal(18,2); 
 define i_Num_vencidos         smallint;
 define d_MontoCom_DispEfec    decimal(18,2);
 define d_MontoCom_DispEfec2   decimal(18,2);
 define d_Tot_MontoCom_DispEfec decimal(18,2);
 define d_MontoPagos           decimal(18,2);
 define dDevolAclaracion       decimal(18,2);
 define i_Numpagos_dev         integer;
 define dDevolComprasNoReconoc decimal(18,2);
 define d_SumaDevoluciones     decimal(18,2);
 define v_cod_bloqueo_cta      char(4);
 define v_limite_credito       decimal(18,2); 
 define dDevol_Anualidad       decimal(18,2);
 define dDevol_AbonoCorreccion decimal(18,2);
 define dMonto_otras_tnxs_tot  decimal(18,2);
 define dMonto_otras_tnxs_1    decimal(18,2);
 define dMonto_otras_tnxs_2    decimal(18,2);
 define dMonto_otras_tnxs_3    decimal(18,2);
 define v_comision_anualidad   decimal(18,2); 
 define dSaldoMax_hist         decimal(18,2); 
 define dSaldoMax_registrado   decimal(18,2); 
 define dSaldoMax_nuevo        decimal(18,2); 
 define iContador_for          integer;
 define c_Dia_corte            char(2);
 define cCod_ret_2             char(6);
 define cProceso               char(4);
 define cCodRet			       char(6);
 define iCuantos               integer; 
 define iCuantos_2             integer; 
 define iContador_upd          integer;
 define vFecha_mes12_atras     date;
 define vFecha_hoy             date;
 define vfecha_fin_mes_ant     date;
 define vFecha_PriDiaMes       date;
 define vFecha_convs3m         date;
 define vFecha_convs6m         date;
 define vFecha_convs12m        date;
 define vCount_maesdoshist     smallint; 
 define iCuantos_atras         smallint; 
 define v_cred_ini 		       char(20);
 define v_cred_fin 		       char(20);
 define cEjecucion             char(2);
 define iPeorMora_12m          smallint;
 define vFecha_primera_mora    date;
 define dSaldoMax_hist_IndCred decimal(18,2);
 define iNumConveniosHist      smallint; 
 define iMaximaMoraHist        smallint;
 define iNumVecesMora_1        smallint;
 define iNumVecesMora_2        smallint;
 define iNumVecesMora_3        smallint;
 define iNumVecesMora_4        smallint;
 define iNumConvenios_Cump     smallint;
 define iNumConvenios_NoCump   smallint;
 define vNumConvenios_Cump     smallint;
 define vNumConvenios_NoCump   smallint;
 define vFechacorte_11MesesAntes  date;
 define iExisteCuenta             smallint; 
 
 define v_cod_bloqueo_cta0        char(4);
 define v_sdo_tot_liquidar0       decimal(18,2);
 define v_pago_minimo0            decimal(18,2); 
 define v_monto_pagos0            decimal(18,2);
 define v_monto_pos0              decimal(18,2);
 define v_num_pos0                smallint;
 define v_monto_disp_efectivo0    decimal(18,2);
 define v_num_disp_efectivo0      smallint;
 define v_sdo_tot_vencido0        decimal(18,2);
 define v_limite_credito0         decimal(18,2);
 define v_comision_anualidad0     decimal(18,2);
 define v_comision_disp_efectivo0 decimal(18,2);
 define v_monto_devoluciones0     decimal(18,2);
 define v_monto_otras_trnx0       decimal(18,2);
 define v_intereses_cargados0     decimal(18,2);
 define v_monto_comisiones0       decimal(18,2);
 define v_num_vencidos0           smallint;
 define vNumConvenios_Cump0       smallint;  
 define vNumConvenios_NoCump0     smallint;  
  
 define vfecha_ciclo1             date;
 define v_total_comisiones0       decimal(18,2);
 define v_num_vencidos1           smallint;
 define cCredIni                  char(20);
 define cCredFin                  char(20); 
 define cCredIni_fin              char(20);
 define vEmpresa_2                char(3);
 
 let v_cod_bloqueo_cta0= ''; 
 let v_sdo_tot_liquidar0= 0;
 let v_pago_minimo0= 0;
 let v_monto_pagos0= 0;
 let v_monto_pos0= 0; 
 let v_num_pos0= 0; 
 let v_monto_disp_efectivo0= 0;
 let v_num_disp_efectivo0= 0;
 let v_sdo_tot_vencido0= 0;
 let v_limite_credito0= 0;
 let v_comision_anualidad0= 0;
 let v_comision_disp_efectivo0= 0;
 let v_monto_devoluciones0= 0;
 let v_monto_otras_trnx0= 0;
 let v_intereses_cargados0= 0;
 let v_monto_comisiones0= 0;
 let v_num_vencidos0= 0;
 let vNumConvenios_Cump0 = 0;
 let vNumConvenios_NoCump0 = 0;
 
 let vfecha_ciclo1 = date(1); 
 let v_total_comisiones0 = 0;
 
 let vEmpresa        = '001';
 let vmensaje        = 'Proceso Exitoso';
 let vcodigo         = '000000';
 let iSqlErr         = 0;
 let error_data_var  = '';
 let isam_err        = 0;
 let vNum_credito    = '';
 let vStatus_cred    = '';
 --let vFechahoy       = date(1);
 --let vPriDiaMes      = date(1);
 let vfecha_fin_mes_ant = date(1); 
 let vFechacorte     = date(1);
 let vFechacorteant  = date(1);
 let iCuantos                = 0;
 let iCuantos_2              = 0;
 let i_Num_vencidos          = 0; 
 let v_fecha_corte_ini                 = date(1); --pfecha_corte_ini; 
 let v_fecha_corte_fin                 = date(1); --pfecha_corte_fin;
 let i_Dia_corte                        = 0;
 let d_SaldoTotal                      = 0;
 let d_PagoMinimo                      = 0;
 let d_SumaMontos_1                    = 0;
 let d_SaldoTotalVencido               = 0;
 let d_SumaDevoluciones                = 0; 
 let i_Numpagos_dev                     = 0;
 let d_Monto_pos                       = 0;
 let i_Num_pos                          = 0;  
 let i_Num_atm                          = 0;
 let i_Num_vtn_ch                       = 0;
 let d_Monto_atm                       = 0;
 let d_Monto_vtn                       = 0;
 let v_fecha_finmes_corte              = date(1);
 let d_Dias                            = 0; 
 let i_Dias_parcial                    = 0;
 let i_Dias_parcial_2                  = 12;  
 let v_fecha_corte_proxmes             = date(1);
 let v_fecha_corte_proxmes_ini         = date(1);
 let d_MontoCom_DispEfec               = 0;
 let d_MontoCom_DispEfec2              = 0;  
 let d_MontoPagos                      = 0;
 let d_InteresesCargados               = 0;
 let d_Iva_IntsCargados                = 0;
 let d_Total_IntsCargados              = 0;
 let d_SumaMontos_1                    = 0;   
 let c_Dia_ejecucion                   = '';
 let dSaldoMax_hist                    = 0;
 let vFechacorte_24MesesAntes          = date(1); 
 let dSaldoMax_registrado              = 0;
 let dSaldoMax_nuevo                   = 0;
 let cProceso                          = '0112';
 let cCodRet				           = "000000";
 let cCod_ret_2                        = '';
 let dDevolAclaracion                  = 0;
 let dDevolComprasNoReconoc            = 0;
 let iContador                         = 0;
 let iContador_upd                  = 0;
 let v_cod_bloqueo_cta                 = '';
 let v_limite_credito                  = 0;
 let dDevol_Anualidad                  = 0;
 let dDevol_AbonoCorreccion            = 0; 
 let dMonto_otras_tnxs_tot             = 0;
 let dMonto_otras_tnxs_1               = 0; 
 let dMonto_otras_tnxs_2               = 0; 
 let dMonto_otras_tnxs_3               = 0; 
 let v_comision_anualidad              = 0;
 let iContador_for                     = 0;
 let c_Dia_corte                       = '';
 let vFechaProceso                     = date(1);
 let vFecha_mes12_atras                = date(1);  
 let vFecha_PriDiaMes                  = date(1);
 let vFecha_convs3m                    = date(1);
 let vFecha_convs6m                    = date(1); 
 let vFecha_convs12m                   = date(1);
 let vCount_maesdoshist                = 0;
 let iCuantos_atras                    = 0;
 let v_cred_ini 		               = '';
 let v_cred_fin                        = ''; 
 let cEjecucion                        = pEjecucion;
 let d_Tot_MontoCom_DispEfec           = 0;
 let iPeorMora_12m                     = 0;
 let vFecha_primera_mora               = date(1);
 let dSaldoMax_hist_IndCred            = 0;
 let iNumConveniosHist                 = 0;
 let iMaximaMoraHist                   = 0; 
 let iNumVecesMora_1                   = 0;
 let iNumVecesMora_2                   = 0;
 let iNumVecesMora_3                   = 0;
 let iNumVecesMora_4                   = 0;
 let iNumConvenios_Cump                = 0;
 let iNumConvenios_NoCump              = 0;
 let vNumConvenios_Cump                = 0;
 let vNumConvenios_NoCump              = 0;
 let vFechacorte_11MesesAntes          = date(1);
 let iExisteCuenta                     = 0;
 let v_num_vencidos1                   = 0;
 let cCredIni                          = '';
 let cCredFin                          = '';
 let cCredIni_fin                      = '';
 let vEmpresa_2                        = '';
 
 begin	 

	ON EXCEPTION SET iSqlErr,isam_err, error_data_var
	   IF iSqlErr != 0 THEN
		 let vcodigo = iSqlErr; 
		 let vmensaje = error_data_var;
		 
		 let vmensaje = trim(vcodigo) || ' ' || vNum_credito || '(' || trim(cEjecucion) || ')';
		 
		 CALL bdicobranza:sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, vmensaje, '02') RETURNING cCod_ret_2;
		 
	     RETURN vcodigo, vmensaje; 
	   END IF;
	END EXCEPTION; 
	
	--SET DEBUG FILE TO "/ifxsif01/macf/sp_triad_actualiza_sdos_rev.trc";
	--TRACE ON;

	
 set isolation to dirty read;
 set lock mode to wait 3;
 
 let vmensaje = cEjecucion;
 --CALL bdicobranza:sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, vmensaje, '01') RETURNING cCod_ret_2; 
 CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, vmensaje, '01') RETURNING cCod_ret_2;  
 
	 
	 --select fecha_hoy, pri_dia_mes into vFecha_hoy, vFecha_PriDiaMes
  	 --  from bdicred:sd_fechas 
	 -- where empresa = vEmpresa;
	 
    -- let vFecha_hoy  = mdy('04','20','2020');  --- SOLO TEST MACF
	 --let vFecha_hoy  = mdy('12','18','2018');  --- TEST MACF
    -- let vFecha_PriDiaMes = mdy('04','01','2020');  --- SOLO TEST MACF
     
	 let vFecha_hoy = today - 1; 
	 let vFechacorte = vFecha_hoy; 
	 
     let vFechacorteant = date(vFechacorte -1 units month);
	 
     --let vfecha_fin_mes_ant = date(vFecha_PriDiaMes - 1 units day);
     --let vFechacorte_11MesesAntes = date(v_fecha_corte_ini -11 units month);
		
	   --SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO v_cred_ini, v_cred_fin
         --FROM bdicred:sd_param  WHERE cod_param = (930 + pEjecucion)::CHAR(3);   

       SELECT valor INTO cCredIni_fin
       FROM bdicred:sd_param  WHERE cod_param = (980 + pEjecucion)::CHAR(3);	
 
       let cCredIni = SUBSTR(cCredIni_fin,1,12);
       let cCredFin = SUBSTR(cCredIni_fin,14,25);
	   
	   
 IF day(vFecha_hoy) = 18 THEN     -------------------------------------- TDC ORO Y PLATINO

         if pEjecucion = 1 then
		        let cCredIni = '700000000000'; 
			      let cCredFin = '810900000000';
	     end if;
 
		FOREACH WITH HOLD
			select a.num_credito, nvl(b.sdo_tot_liquidar_ch,0), nvl(b.pago_minimo_ch,0), nvl(b.monto_pagos_ch,0), nvl(b.sdo_tot_vencido_ch,0), 
				   --nvl(b.intereses_periodo_ch,0), nvl(b.num_vencidos,0),nvl(b.monto_pos_ch,0), nvl(b.monto_atm_ch,0) + nvl(b.monto_vtn_ch,0) monto_disp_efectivo, 
				   nvl(b.intereses_periodo_ch,0), nvl(b.num_vencidos_ch,0),nvl(b.monto_pos_ch,0), nvl(b.monto_atm_ch,0) + nvl(b.monto_vtn_ch,0) monto_disp_efectivo, 
				   nvl(b.total_comisiones_ch,0), nvl(b.num_pos_ch,0), nvl(b.num_atm_ch,0) + nvl(b.num_vtn_ch,0) num_disp_efectivo,
				   nvl(b.limite_credito_ch,0), nvl(b.comision_anualidad,0) + nvl(b.comision_disp_efectivo_ch,0), nvl(b.monto_devoluciones_ch,0), nvl(b.monto_otras_trnx_ch,0)
			  into vNum_credito, v_sdo_tot_liquidar0, v_pago_minimo0,v_monto_pagos0, v_sdo_tot_vencido0, v_intereses_cargados0, v_num_vencidos1,
				   v_monto_pos0, v_monto_disp_efectivo0, v_total_comisiones0, v_num_pos0, v_num_disp_efectivo0,
				   v_limite_credito0, v_monto_comisiones0, v_monto_devoluciones0, v_monto_otras_trnx0		   
			  from bdicred:sd_maecred a
									 inner join bdicred:sd_indicador_cred b on (a.num_credito = b.num_credito)
			 where a.num_producto in('7000','8100') and a.status_cred in('AA','BA','BT')  
               and a.num_credito >= cCredIni AND a.num_credito  < cCredFin 			   
			   and a.num_credito not in(select num_credito from bdicobranza:cb_triad_sdos_inds_tdc where num_credito > '600000000001' and fecha_proceso = vFecha_hoy)
			   AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_inactivos_12meses WHERE num_credito > '600000000001')
			
			 if v_num_vencidos1 > 9 then 
				let v_num_vencidos0 = 9;
			 else
				let v_num_vencidos0 =  v_num_vencidos1;
			 end if;			

			
			select limit 1 lpad(cve_causa,4,'0') into v_cod_bloqueo_cta
		      from bdicred:sd_bitacorabloqueocta
		     where cuenta = vNum_credito and fecha between vFechacorteant and vFecha_hoy
		       and tipo_movimiento = 'B'; 

			if v_cod_bloqueo_cta = '' or v_cod_bloqueo_cta = '0' or v_cod_bloqueo_cta is null then let v_cod_bloqueo_cta= '0000'; end if;
			
			select nvl(sum(case when flag_pago = '1' then 1 else 0 end),0) as cumplidos,
				 nvl(sum(case when flag_pago = '0' then 1 else 0 end),0) as nocumplidos
			 into vNumConvenios_Cump0, vNumConvenios_NoCump0
			from bdicobranza:cb_compac_his
			where numcuenta = vNum_credito
			 and fecha_compac between vFechacorteant and vFecha_hoy;
		
		   --select count(*) into iExisteCuenta
		     select empresa into vEmpresa_2
			 from bdicobranza:cb_triad_sdos_inds_tdc
		    where num_credito = vNum_credito;
		
		    if nvl(vEmpresa_2,'') <> '' and vEmpresa_2 <> '' then
			   let iExisteCuenta = 1;
			end if;
		
		if iExisteCuenta > 0 then
		
		BEGIN;

			UPDATE bdicobranza:cb_triad_sdos_inds_tdc SET fecha_proceso = vFecha_hoy, fecha_ciclo1 = vFecha_hoy, cod_bloqueo_cta1= v_cod_bloqueo_cta, 
			 sdo_tot_liquidar1= v_sdo_tot_liquidar0, pago_minimo1= v_pago_minimo0, monto_pagos1= v_monto_pagos0, monto_pos1= v_monto_pos0,
			 num_pos1= v_num_pos0, monto_disp_efectivo1= v_monto_disp_efectivo0, num_disp_efectivo1= v_num_disp_efectivo0,
			 sdo_tot_vencido1= v_sdo_tot_vencido0, limite_credito1= v_limite_credito0, comision_anualidad1= v_comision_anualidad0,
			 comision_disp_efectivo1= v_comision_disp_efectivo0, monto_devoluciones1= v_monto_devoluciones0, monto_otras_trnx1= v_monto_otras_trnx0,
			 intereses_periodo1= v_intereses_cargados0, monto_comisiones1= v_monto_comisiones0, num_vencidos1= v_num_vencidos0,
			 num_convenio_cumplido_1m = vNumConvenios_Cump0, num_convenio_nocumplido_1m = vNumConvenios_NoCump0,
			
			 fecha_ciclo2 = fecha_ciclo1, cod_bloqueo_cta2= cod_bloqueo_cta1, sdo_tot_liquidar2= sdo_tot_liquidar1, pago_minimo2= pago_minimo1, 
			 monto_pagos2= monto_pagos1, monto_pos2= monto_pos1, num_pos2= num_pos1, monto_disp_efectivo2= monto_disp_efectivo1,
			 num_disp_efectivo2= num_disp_efectivo1, sdo_tot_vencido2= sdo_tot_vencido1, limite_credito2= limite_credito1,
			 comision_anualidad2= comision_anualidad1, comision_disp_efectivo2= comision_disp_efectivo1, monto_devoluciones2= monto_devoluciones1,
			 monto_otras_trnx2= monto_otras_trnx1, intereses_periodo2= intereses_periodo1, monto_comisiones2= monto_comisiones1,
			 num_vencidos2= num_vencidos1, num_convenio_cumplido_2m = num_convenio_cumplido_1m, num_convenio_nocumplido_2m = num_convenio_nocumplido_1m,
			
			 fecha_ciclo3 = fecha_ciclo2, cod_bloqueo_cta3= cod_bloqueo_cta2, sdo_tot_liquidar3= sdo_tot_liquidar2, pago_minimo3= pago_minimo2, 
			 monto_pagos3= monto_pagos2, monto_pos3= monto_pos2, num_pos3= num_pos2, monto_disp_efectivo3= monto_disp_efectivo2,
			 num_disp_efectivo3= num_disp_efectivo2, sdo_tot_vencido3= sdo_tot_vencido2, limite_credito3= limite_credito2,
			 comision_anualidad3= comision_anualidad2, comision_disp_efectivo3= comision_disp_efectivo2, monto_devoluciones3= monto_devoluciones2,
			 monto_otras_trnx3= monto_otras_trnx2, intereses_periodo3= intereses_periodo2, monto_comisiones3= monto_comisiones2,
			 num_vencidos3= num_vencidos2, num_convenio_cumplido_3m = num_convenio_cumplido_2m, num_convenio_nocumplido_3m = num_convenio_nocumplido_2m,
			 
			 fecha_ciclo4 = fecha_ciclo3, cod_bloqueo_cta4= cod_bloqueo_cta3, sdo_tot_liquidar4= sdo_tot_liquidar3, pago_minimo4= pago_minimo3, 
			 monto_pagos4= monto_pagos3, monto_pos4= monto_pos3, num_pos4= num_pos3, monto_disp_efectivo4= monto_disp_efectivo3,
			 num_disp_efectivo4= num_disp_efectivo3, sdo_tot_vencido4= sdo_tot_vencido3, limite_credito4= limite_credito3,
			 comision_anualidad4= comision_anualidad3, comision_disp_efectivo4= comision_disp_efectivo3, monto_devoluciones4= monto_devoluciones3,
			 monto_otras_trnx4= monto_otras_trnx3, intereses_periodo4= intereses_periodo3, monto_comisiones4= monto_comisiones3,
			 num_vencidos4= num_vencidos3, num_convenio_cumplido_4m = num_convenio_cumplido_3m, num_convenio_nocumplido_4m = num_convenio_nocumplido_3m,
			 
			 fecha_ciclo5 = fecha_ciclo4, cod_bloqueo_cta5= cod_bloqueo_cta4, sdo_tot_liquidar5= sdo_tot_liquidar4, pago_minimo5= pago_minimo4, 
			 monto_pagos5= monto_pagos4, monto_pos5= monto_pos4, num_pos5= num_pos4, monto_disp_efectivo5= monto_disp_efectivo4,
			 num_disp_efectivo5= num_disp_efectivo4, sdo_tot_vencido5= sdo_tot_vencido4, limite_credito5= limite_credito4,
			 comision_anualidad5= comision_anualidad4, comision_disp_efectivo5= comision_disp_efectivo4, monto_devoluciones5= monto_devoluciones4,
			 monto_otras_trnx5= monto_otras_trnx4, intereses_periodo5= intereses_periodo4, monto_comisiones5= monto_comisiones4,
			 num_vencidos5= num_vencidos4, num_convenio_cumplido_5m = num_convenio_cumplido_4m, num_convenio_nocumplido_5m = num_convenio_nocumplido_4m,
			 
			 fecha_ciclo6 = fecha_ciclo5, cod_bloqueo_cta6= cod_bloqueo_cta5, sdo_tot_liquidar6= sdo_tot_liquidar5, pago_minimo6= pago_minimo5, 
			 monto_pagos6= monto_pagos5, monto_pos6= monto_pos5, num_pos6= num_pos5, monto_disp_efectivo6= monto_disp_efectivo5,
			 num_disp_efectivo6= num_disp_efectivo5, sdo_tot_vencido6= sdo_tot_vencido5, limite_credito6= limite_credito5,
			 comision_anualidad6= comision_anualidad5, comision_disp_efectivo6= comision_disp_efectivo5, monto_devoluciones6= monto_devoluciones5,
			 monto_otras_trnx6= monto_otras_trnx5, intereses_periodo6= intereses_periodo5, monto_comisiones6= monto_comisiones5,
			 num_vencidos6= num_vencidos5, num_convenio_cumplido_6m = num_convenio_cumplido_5m, num_convenio_nocumplido_6m = num_convenio_nocumplido_5m,
			 
			 fecha_ciclo7 = fecha_ciclo6, cod_bloqueo_cta7= cod_bloqueo_cta6, sdo_tot_liquidar7= sdo_tot_liquidar6, pago_minimo7= pago_minimo6, 
			 monto_pagos7= monto_pagos6, monto_pos7= monto_pos6, num_pos7= num_pos6, monto_disp_efectivo7= monto_disp_efectivo6,
			 num_disp_efectivo7= num_disp_efectivo6, sdo_tot_vencido7= sdo_tot_vencido6, limite_credito7= limite_credito6,
			 comision_anualidad7= comision_anualidad6, comision_disp_efectivo7= comision_disp_efectivo6, monto_devoluciones7= monto_devoluciones6,
			 monto_otras_trnx7= monto_otras_trnx6, intereses_periodo7= intereses_periodo6, monto_comisiones7= monto_comisiones6,
			 num_vencidos7= num_vencidos6, num_convenio_cumplido_7m = num_convenio_cumplido_6m, num_convenio_nocumplido_7m = num_convenio_nocumplido_6m,
			 
			 fecha_ciclo8 = fecha_ciclo7, cod_bloqueo_cta8= cod_bloqueo_cta7, sdo_tot_liquidar8= sdo_tot_liquidar7, pago_minimo8= pago_minimo7, 
			 monto_pagos8= monto_pagos7, monto_pos8= monto_pos7, num_pos8= num_pos7, monto_disp_efectivo8= monto_disp_efectivo7,
			 num_disp_efectivo8= num_disp_efectivo7, sdo_tot_vencido8= sdo_tot_vencido7, limite_credito8= limite_credito7,
			 comision_anualidad8= comision_anualidad7, comision_disp_efectivo8= comision_disp_efectivo7, monto_devoluciones8= monto_devoluciones7,
			 monto_otras_trnx8= monto_otras_trnx7, intereses_periodo8= intereses_periodo7, monto_comisiones8= monto_comisiones7,
			 num_vencidos8= num_vencidos7, num_convenio_cumplido_8m = num_convenio_cumplido_7m, num_convenio_nocumplido_8m = num_convenio_nocumplido_7m,
			 
			 fecha_ciclo9 = fecha_ciclo8, cod_bloqueo_cta9= cod_bloqueo_cta8, sdo_tot_liquidar9= sdo_tot_liquidar8, pago_minimo9= pago_minimo8, 
			 monto_pagos9= monto_pagos8, monto_pos9= monto_pos8, num_pos9= num_pos8, monto_disp_efectivo9= monto_disp_efectivo8,
			 num_disp_efectivo9= num_disp_efectivo8, sdo_tot_vencido9= sdo_tot_vencido8, limite_credito9= limite_credito8,
			 comision_anualidad9= comision_anualidad8, comision_disp_efectivo9= comision_disp_efectivo8, monto_devoluciones9= monto_devoluciones8,
			 monto_otras_trnx9= monto_otras_trnx8, intereses_periodo9= intereses_periodo8, monto_comisiones9= monto_comisiones8,
			 num_vencidos9= num_vencidos8, num_convenio_cumplido_9m = num_convenio_cumplido_8m, num_convenio_nocumplido_9m = num_convenio_nocumplido_8m,
			 
			 fecha_ciclo10 = fecha_ciclo9, cod_bloqueo_cta10= cod_bloqueo_cta9, sdo_tot_liquidar10= sdo_tot_liquidar9, pago_minimo10= pago_minimo9, 
			 monto_pagos10= monto_pagos9, monto_pos10= monto_pos9, num_pos10= num_pos9, monto_disp_efectivo10= monto_disp_efectivo9,
			 num_disp_efectivo10= num_disp_efectivo9, sdo_tot_vencido10= sdo_tot_vencido9, limite_credito10= limite_credito9,
			 comision_anualidad10= comision_anualidad9, comision_disp_efectivo10= comision_disp_efectivo9, monto_devoluciones10= monto_devoluciones9,
			 monto_otras_trnx10= monto_otras_trnx9, intereses_periodo10= intereses_periodo9, monto_comisiones10= monto_comisiones9,
			 num_vencidos10= num_vencidos9, num_convenio_cumplido_10m = num_convenio_cumplido_9m, num_convenio_nocumplido_10m = num_convenio_nocumplido_9m,
			 
			 fecha_ciclo11 = fecha_ciclo10, cod_bloqueo_cta11= cod_bloqueo_cta10, sdo_tot_liquidar11= sdo_tot_liquidar10, pago_minimo11= pago_minimo10, 
			 monto_pagos11= monto_pagos10, monto_pos11= monto_pos10, num_pos11= num_pos10, monto_disp_efectivo11= monto_disp_efectivo10,
			 num_disp_efectivo11= num_disp_efectivo10, sdo_tot_vencido11= sdo_tot_vencido10, limite_credito11= limite_credito10,
			 comision_anualidad11= comision_anualidad10, comision_disp_efectivo11= comision_disp_efectivo10, monto_devoluciones11= monto_devoluciones10,
			 monto_otras_trnx11= monto_otras_trnx10, intereses_periodo11= intereses_periodo10, monto_comisiones11= monto_comisiones10,
			 num_vencidos11= num_vencidos10, num_convenio_cumplido_11m = num_convenio_cumplido_10m, num_convenio_nocumplido_11m = num_convenio_nocumplido_10m,
			 num_vencidos12 = num_vencidos11, num_vencidos13 = num_vencidos12, num_vencidos14 = num_vencidos13, num_vencidos15 = num_vencidos14,
			 num_vencidos16 = num_vencidos15, num_vencidos17 = num_vencidos16, num_vencidos18 = num_vencidos17, num_vencidos19 = num_vencidos18,
			 num_vencidos20 = num_vencidos19, num_vencidos21 = num_vencidos20, num_vencidos22 = num_vencidos21, num_vencidos23 = num_vencidos22, empresa = vEmpresa
			 WHERE num_credito = vNum_credito;
	    COMMIT;
		    let iContador_upd = iContador_upd + 1;

			
		else	
	       begin;	
			INSERT INTO informix.cb_triad_sdos_inds_tdc(num_credito, fecha_proceso, fecha_ciclo1, cod_bloqueo_cta1, sdo_tot_liquidar1, pago_minimo1, 
			monto_pagos1, sdo_tot_vencido1, intereses_periodo1, num_vencidos1, monto_pos1, monto_disp_efectivo1, monto_comisiones1, num_pos1, num_disp_efectivo1,
			limite_credito1, comision_anualidad1, comision_disp_efectivo1, monto_devoluciones1, monto_otras_trnx1, num_convenio_cumplido_1m, 
			num_convenio_nocumplido_1m, fecha_ciclo2, cod_bloqueo_cta2, sdo_tot_liquidar2, pago_minimo2, monto_pagos2, sdo_tot_vencido2, intereses_periodo2, 
			num_vencidos2, monto_pos2, monto_disp_efectivo2, monto_comisiones2, num_pos2, num_disp_efectivo2, limite_credito2, comision_anualidad2, 
			comision_disp_efectivo2, monto_devoluciones2, monto_otras_trnx2, num_convenio_cumplido_2m, num_convenio_nocumplido_2m, fecha_ciclo3,
			cod_bloqueo_cta3, sdo_tot_liquidar3, pago_minimo3, monto_pagos3, sdo_tot_vencido3, intereses_periodo3, num_vencidos3, monto_comisiones3,
			monto_pos3, num_pos3, monto_disp_efectivo3, num_disp_efectivo3, limite_credito3, comision_anualidad3, comision_disp_efectivo3, monto_devoluciones3,
			monto_otras_trnx3, num_convenio_cumplido_3m, num_convenio_nocumplido_3m, fecha_ciclo4, cod_bloqueo_cta4, sdo_tot_liquidar4, pago_minimo4, 
			monto_pagos4, sdo_tot_vencido4, intereses_periodo4, num_vencidos4, monto_comisiones4, monto_pos4, num_pos4, monto_disp_efectivo4, 
			num_disp_efectivo4, limite_credito4, comision_anualidad4, comision_disp_efectivo4, monto_devoluciones4, monto_otras_trnx4, 
			num_convenio_cumplido_4m, num_convenio_nocumplido_4m, fecha_ciclo5, cod_bloqueo_cta5, sdo_tot_liquidar5, pago_minimo5, monto_pagos5, 
			sdo_tot_vencido5, intereses_periodo5, num_vencidos5, monto_comisiones5, monto_pos5, num_pos5, monto_disp_efectivo5, num_disp_efectivo5, 
			limite_credito5, comision_anualidad5, comision_disp_efectivo5, monto_devoluciones5, monto_otras_trnx5, num_convenio_cumplido_5m, 
			num_convenio_nocumplido_5m, fecha_ciclo6, cod_bloqueo_cta6, sdo_tot_liquidar6, pago_minimo6, monto_pagos6, sdo_tot_vencido6, intereses_periodo6, 
			num_vencidos6, monto_comisiones6, monto_pos6, num_pos6, monto_disp_efectivo6, num_disp_efectivo6, limite_credito6, comision_anualidad6, 
			comision_disp_efectivo6, monto_devoluciones6, monto_otras_trnx6, num_convenio_cumplido_6m, num_convenio_nocumplido_6m, fecha_ciclo7, 
			cod_bloqueo_cta7, sdo_tot_liquidar7, pago_minimo7, monto_pagos7, sdo_tot_vencido7, intereses_periodo7, num_vencidos7, monto_comisiones7, 
			monto_pos7, num_pos7, monto_disp_efectivo7, num_disp_efectivo7, limite_credito7, comision_anualidad7, comision_disp_efectivo7, 
			monto_devoluciones7, monto_otras_trnx7, num_convenio_cumplido_7m, num_convenio_nocumplido_7m, fecha_ciclo8, cod_bloqueo_cta8, 
			sdo_tot_liquidar8, pago_minimo8, monto_pagos8, sdo_tot_vencido8, intereses_periodo8, num_vencidos8, monto_comisiones8, monto_pos8, num_pos8, 
			monto_disp_efectivo8, num_disp_efectivo8, limite_credito8, comision_anualidad8, comision_disp_efectivo8, monto_devoluciones8, monto_otras_trnx8, 
			num_convenio_cumplido_8m, num_convenio_nocumplido_8m, fecha_ciclo9, cod_bloqueo_cta9, sdo_tot_liquidar9, pago_minimo9, monto_pagos9, 
			sdo_tot_vencido9, intereses_periodo9, num_vencidos9, monto_comisiones9, monto_pos9, num_pos9, monto_disp_efectivo9, num_disp_efectivo9, 
			limite_credito9, comision_anualidad9, comision_disp_efectivo9, monto_devoluciones9, monto_otras_trnx9, num_convenio_cumplido_9m, 
			num_convenio_nocumplido_9m, fecha_ciclo10, cod_bloqueo_cta10, sdo_tot_liquidar10, pago_minimo10, monto_pagos10, sdo_tot_vencido10, 
			intereses_periodo10, num_vencidos10, monto_comisiones10, monto_pos10, num_pos10, monto_disp_efectivo10, num_disp_efectivo10, limite_credito10, 
			comision_anualidad10, comision_disp_efectivo10, monto_devoluciones10, monto_otras_trnx10, num_convenio_cumplido_10m, num_convenio_nocumplido_10m, 
			fecha_ciclo11, cod_bloqueo_cta11, sdo_tot_liquidar11, pago_minimo11, monto_pagos11, sdo_tot_vencido11, intereses_periodo11, num_vencidos11, 
			monto_comisiones11, monto_pos11, num_pos11, monto_disp_efectivo11, num_disp_efectivo11, limite_credito11, comision_anualidad11, 
			comision_disp_efectivo11, monto_devoluciones11, monto_otras_trnx11, num_convenio_cumplido_11m, num_convenio_nocumplido_11m, num_vencidos12, 
			num_vencidos13, num_vencidos14, num_vencidos15, num_vencidos16, num_vencidos17, num_vencidos18, num_vencidos19, num_vencidos20, num_vencidos21, 
			num_vencidos22, num_vencidos23, empresa) 
			VALUES(vNum_credito, vFecha_hoy, vFecha_hoy, '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
			'01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			'01/01/1900', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			'01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
			'01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			'01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, vEmpresa);
	       commit;
           let iContador = iContador + 1;  		
		   
        end if;			
			
     END FOREACH  		
			   
			   
			   
			   
 ELIF  day(vFecha_hoy) = 20 THEN    -------------------------------------- TDC BÁSICA Y CLÁSICA

		 
	 FOREACH WITH HOLD       
		
		 select {+AVOID_FULL (bdicred:sd_maecred)} a.num_credito, nvl(b.sdo_tot_liquidar_ch,0), nvl(b.pago_minimo_ch,0), nvl(b.monto_pagos_ch,0), nvl(b.sdo_tot_vencido_ch,0), 
		       --nvl(b.intereses_periodo_ch,0), nvl(b.num_vencidos,0),nvl(b.monto_pos_ch,0), nvl(b.monto_atm_ch,0) + nvl(b.monto_vtn_ch,0) monto_disp_efectivo, 
			   nvl(b.intereses_periodo_ch,0), nvl(b.num_vencidos_ch,0),nvl(b.monto_pos_ch,0), nvl(b.monto_atm_ch,0) + nvl(b.monto_vtn_ch,0) monto_disp_efectivo, 
			   nvl(b.total_comisiones_ch,0), nvl(b.num_pos_ch,0), nvl(b.num_atm_ch,0) + nvl(b.num_vtn_ch,0) num_disp_efectivo,
               nvl(b.limite_credito_ch,0), nvl(b.comision_anualidad,0) + nvl(b.comision_disp_efectivo_ch,0), nvl(b.monto_devoluciones_ch,0), nvl(b.monto_otras_trnx_ch,0)
	      into vNum_credito, v_sdo_tot_liquidar0, v_pago_minimo0,v_monto_pagos0, v_sdo_tot_vencido0, v_intereses_cargados0, v_num_vencidos1,
               v_monto_pos0, v_monto_disp_efectivo0, v_total_comisiones0, v_num_pos0, v_num_disp_efectivo0,
               v_limite_credito0, v_monto_comisiones0, v_monto_devoluciones0, v_monto_otras_trnx0		   
		  from bdicred:sd_maecred a, bdicred:sd_indicador_cred b
		 where a.num_producto IN('6001','6600') and a.status_cred in('AA','BA','BT')
           and a.empresa = b.empresa and a.num_credito = b.num_credito
           and a.num_credito>= cCredIni AND a.num_credito < cCredFin 		   
		   and a.num_credito not in(select num_credito from bdicobranza:cb_triad_sdos_inds_tdc where num_credito > '600000000001' and fecha_proceso = vFecha_hoy)
		   AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_inactivos_12meses WHERE num_credito > '600000000001')
		   

		 if v_num_vencidos1 > 9 then 
		    let v_num_vencidos0 = 9;
		 else
		    let v_num_vencidos0 =  v_num_vencidos1;
		 end if;
		 
		
		 select limit 1 lpad(cve_causa,4,'0') into v_cod_bloqueo_cta
		   from bdicred:sd_bitacorabloqueocta
		  where cuenta = vNum_credito and fecha between vFechacorteant and vFecha_hoy
		    and tipo_movimiento = 'B'; 

			if v_cod_bloqueo_cta = '' or v_cod_bloqueo_cta = '0' or v_cod_bloqueo_cta is null then let v_cod_bloqueo_cta= '0000'; end if;
			
			select nvl(sum(case when flag_pago = '1' then 1 else 0 end),0) as cumplidos,
				 nvl(sum(case when flag_pago = '0' then 1 else 0 end),0) as nocumplidos
			 into vNumConvenios_Cump0, vNumConvenios_NoCump0
			from bdicobranza:cb_compac_his
			where numcuenta = vNum_credito
			 and fecha_compac between vFechacorteant and vFecha_hoy;
		
		  --select count(*) into iExisteCuenta
		     select empresa into vEmpresa_2
			 from bdicobranza:cb_triad_sdos_inds_tdc
		    where num_credito = vNum_credito;
		
		    if nvl(vEmpresa_2,'') <> '' and vEmpresa_2 <> '' then
			   let iExisteCuenta = 1;
			end if;
		
		
		if iExisteCuenta > 0 then
		
		BEGIN;

			UPDATE bdicobranza:cb_triad_sdos_inds_tdc SET fecha_proceso = vFecha_hoy, fecha_ciclo1 = vFecha_hoy, cod_bloqueo_cta1= v_cod_bloqueo_cta, 
			 sdo_tot_liquidar1= v_sdo_tot_liquidar0, pago_minimo1= v_pago_minimo0, monto_pagos1= v_monto_pagos0, monto_pos1= v_monto_pos0,
			 num_pos1= v_num_pos0, monto_disp_efectivo1= v_monto_disp_efectivo0, num_disp_efectivo1= v_num_disp_efectivo0,
			 sdo_tot_vencido1= v_sdo_tot_vencido0, limite_credito1= v_limite_credito0, comision_anualidad1= v_comision_anualidad0,
			 comision_disp_efectivo1= v_comision_disp_efectivo0, monto_devoluciones1= v_monto_devoluciones0, monto_otras_trnx1= v_monto_otras_trnx0,
			 intereses_periodo1= v_intereses_cargados0, monto_comisiones1= v_monto_comisiones0, num_vencidos1= v_num_vencidos0,
			 num_convenio_cumplido_1m = vNumConvenios_Cump0, num_convenio_nocumplido_1m = vNumConvenios_NoCump0,
			
			 fecha_ciclo2 = fecha_ciclo1, cod_bloqueo_cta2= cod_bloqueo_cta1, sdo_tot_liquidar2= sdo_tot_liquidar1, pago_minimo2= pago_minimo1, 
			 monto_pagos2= monto_pagos1, monto_pos2= monto_pos1, num_pos2= num_pos1, monto_disp_efectivo2= monto_disp_efectivo1,
			 num_disp_efectivo2= num_disp_efectivo1, sdo_tot_vencido2= sdo_tot_vencido1, limite_credito2= limite_credito1,
			 comision_anualidad2= comision_anualidad1, comision_disp_efectivo2= comision_disp_efectivo1, monto_devoluciones2= monto_devoluciones1,
			 monto_otras_trnx2= monto_otras_trnx1, intereses_periodo2= intereses_periodo1, monto_comisiones2= monto_comisiones1,
			 num_vencidos2= num_vencidos1, num_convenio_cumplido_2m = num_convenio_cumplido_1m, num_convenio_nocumplido_2m = num_convenio_nocumplido_1m,
			
			 fecha_ciclo3 = fecha_ciclo2, cod_bloqueo_cta3= cod_bloqueo_cta2, sdo_tot_liquidar3= sdo_tot_liquidar2, pago_minimo3= pago_minimo2, 
			 monto_pagos3= monto_pagos2, monto_pos3= monto_pos2, num_pos3= num_pos2, monto_disp_efectivo3= monto_disp_efectivo2,
			 num_disp_efectivo3= num_disp_efectivo2, sdo_tot_vencido3= sdo_tot_vencido2, limite_credito3= limite_credito2,
			 comision_anualidad3= comision_anualidad2, comision_disp_efectivo3= comision_disp_efectivo2, monto_devoluciones3= monto_devoluciones2,
			 monto_otras_trnx3= monto_otras_trnx2, intereses_periodo3= intereses_periodo2, monto_comisiones3= monto_comisiones2,
			 num_vencidos3= num_vencidos2, num_convenio_cumplido_3m = num_convenio_cumplido_2m, num_convenio_nocumplido_3m = num_convenio_nocumplido_2m,
			 
			 fecha_ciclo4 = fecha_ciclo3, cod_bloqueo_cta4= cod_bloqueo_cta3, sdo_tot_liquidar4= sdo_tot_liquidar3, pago_minimo4= pago_minimo3, 
			 monto_pagos4= monto_pagos3, monto_pos4= monto_pos3, num_pos4= num_pos3, monto_disp_efectivo4= monto_disp_efectivo3,
			 num_disp_efectivo4= num_disp_efectivo3, sdo_tot_vencido4= sdo_tot_vencido3, limite_credito4= limite_credito3,
			 comision_anualidad4= comision_anualidad3, comision_disp_efectivo4= comision_disp_efectivo3, monto_devoluciones4= monto_devoluciones3,
			 monto_otras_trnx4= monto_otras_trnx3, intereses_periodo4= intereses_periodo3, monto_comisiones4= monto_comisiones3,
			 num_vencidos4= num_vencidos3, num_convenio_cumplido_4m = num_convenio_cumplido_3m, num_convenio_nocumplido_4m = num_convenio_nocumplido_3m,
			 
			 fecha_ciclo5 = fecha_ciclo4, cod_bloqueo_cta5= cod_bloqueo_cta4, sdo_tot_liquidar5= sdo_tot_liquidar4, pago_minimo5= pago_minimo4, 
			 monto_pagos5= monto_pagos4, monto_pos5= monto_pos4, num_pos5= num_pos4, monto_disp_efectivo5= monto_disp_efectivo4,
			 num_disp_efectivo5= num_disp_efectivo4, sdo_tot_vencido5= sdo_tot_vencido4, limite_credito5= limite_credito4,
			 comision_anualidad5= comision_anualidad4, comision_disp_efectivo5= comision_disp_efectivo4, monto_devoluciones5= monto_devoluciones4,
			 monto_otras_trnx5= monto_otras_trnx4, intereses_periodo5= intereses_periodo4, monto_comisiones5= monto_comisiones4,
			 num_vencidos5= num_vencidos4, num_convenio_cumplido_5m = num_convenio_cumplido_4m, num_convenio_nocumplido_5m = num_convenio_nocumplido_4m,
			 
			 fecha_ciclo6 = fecha_ciclo5, cod_bloqueo_cta6= cod_bloqueo_cta5, sdo_tot_liquidar6= sdo_tot_liquidar5, pago_minimo6= pago_minimo5, 
			 monto_pagos6= monto_pagos5, monto_pos6= monto_pos5, num_pos6= num_pos5, monto_disp_efectivo6= monto_disp_efectivo5,
			 num_disp_efectivo6= num_disp_efectivo5, sdo_tot_vencido6= sdo_tot_vencido5, limite_credito6= limite_credito5,
			 comision_anualidad6= comision_anualidad5, comision_disp_efectivo6= comision_disp_efectivo5, monto_devoluciones6= monto_devoluciones5,
			 monto_otras_trnx6= monto_otras_trnx5, intereses_periodo6= intereses_periodo5, monto_comisiones6= monto_comisiones5,
			 num_vencidos6= num_vencidos5, num_convenio_cumplido_6m = num_convenio_cumplido_5m, num_convenio_nocumplido_6m = num_convenio_nocumplido_5m,
			 
			 fecha_ciclo7 = fecha_ciclo6, cod_bloqueo_cta7= cod_bloqueo_cta6, sdo_tot_liquidar7= sdo_tot_liquidar6, pago_minimo7= pago_minimo6, 
			 monto_pagos7= monto_pagos6, monto_pos7= monto_pos6, num_pos7= num_pos6, monto_disp_efectivo7= monto_disp_efectivo6,
			 num_disp_efectivo7= num_disp_efectivo6, sdo_tot_vencido7= sdo_tot_vencido6, limite_credito7= limite_credito6,
			 comision_anualidad7= comision_anualidad6, comision_disp_efectivo7= comision_disp_efectivo6, monto_devoluciones7= monto_devoluciones6,
			 monto_otras_trnx7= monto_otras_trnx6, intereses_periodo7= intereses_periodo6, monto_comisiones7= monto_comisiones6,
			 num_vencidos7= num_vencidos6, num_convenio_cumplido_7m = num_convenio_cumplido_6m, num_convenio_nocumplido_7m = num_convenio_nocumplido_6m,
			 
			 fecha_ciclo8 = fecha_ciclo7, cod_bloqueo_cta8= cod_bloqueo_cta7, sdo_tot_liquidar8= sdo_tot_liquidar7, pago_minimo8= pago_minimo7, 
			 monto_pagos8= monto_pagos7, monto_pos8= monto_pos7, num_pos8= num_pos7, monto_disp_efectivo8= monto_disp_efectivo7,
			 num_disp_efectivo8= num_disp_efectivo7, sdo_tot_vencido8= sdo_tot_vencido7, limite_credito8= limite_credito7,
			 comision_anualidad8= comision_anualidad7, comision_disp_efectivo8= comision_disp_efectivo7, monto_devoluciones8= monto_devoluciones7,
			 monto_otras_trnx8= monto_otras_trnx7, intereses_periodo8= intereses_periodo7, monto_comisiones8= monto_comisiones7,
			 num_vencidos8= num_vencidos7, num_convenio_cumplido_8m = num_convenio_cumplido_7m, num_convenio_nocumplido_8m = num_convenio_nocumplido_7m,
			 
			 fecha_ciclo9 = fecha_ciclo8, cod_bloqueo_cta9= cod_bloqueo_cta8, sdo_tot_liquidar9= sdo_tot_liquidar8, pago_minimo9= pago_minimo8, 
			 monto_pagos9= monto_pagos8, monto_pos9= monto_pos8, num_pos9= num_pos8, monto_disp_efectivo9= monto_disp_efectivo8,
			 num_disp_efectivo9= num_disp_efectivo8, sdo_tot_vencido9= sdo_tot_vencido8, limite_credito9= limite_credito8,
			 comision_anualidad9= comision_anualidad8, comision_disp_efectivo9= comision_disp_efectivo8, monto_devoluciones9= monto_devoluciones8,
			 monto_otras_trnx9= monto_otras_trnx8, intereses_periodo9= intereses_periodo8, monto_comisiones9= monto_comisiones8,
			 num_vencidos9= num_vencidos8, num_convenio_cumplido_9m = num_convenio_cumplido_8m, num_convenio_nocumplido_9m = num_convenio_nocumplido_8m,
			 
			 fecha_ciclo10 = fecha_ciclo9, cod_bloqueo_cta10= cod_bloqueo_cta9, sdo_tot_liquidar10= sdo_tot_liquidar9, pago_minimo10= pago_minimo9, 
			 monto_pagos10= monto_pagos9, monto_pos10= monto_pos9, num_pos10= num_pos9, monto_disp_efectivo10= monto_disp_efectivo9,
			 num_disp_efectivo10= num_disp_efectivo9, sdo_tot_vencido10= sdo_tot_vencido9, limite_credito10= limite_credito9,
			 comision_anualidad10= comision_anualidad9, comision_disp_efectivo10= comision_disp_efectivo9, monto_devoluciones10= monto_devoluciones9,
			 monto_otras_trnx10= monto_otras_trnx9, intereses_periodo10= intereses_periodo9, monto_comisiones10= monto_comisiones9,
			 num_vencidos10= num_vencidos9, num_convenio_cumplido_10m = num_convenio_cumplido_9m, num_convenio_nocumplido_10m = num_convenio_nocumplido_9m,
			 
			 fecha_ciclo11 = fecha_ciclo10, cod_bloqueo_cta11= cod_bloqueo_cta10, sdo_tot_liquidar11= sdo_tot_liquidar10, pago_minimo11= pago_minimo10, 
			 monto_pagos11= monto_pagos10, monto_pos11= monto_pos10, num_pos11= num_pos10, monto_disp_efectivo11= monto_disp_efectivo10,
			 num_disp_efectivo11= num_disp_efectivo10, sdo_tot_vencido11= sdo_tot_vencido10, limite_credito11= limite_credito10,
			 comision_anualidad11= comision_anualidad10, comision_disp_efectivo11= comision_disp_efectivo10, monto_devoluciones11= monto_devoluciones10,
			 monto_otras_trnx11= monto_otras_trnx10, intereses_periodo11= intereses_periodo10, monto_comisiones11= monto_comisiones10,
			 num_vencidos11= num_vencidos10, num_convenio_cumplido_11m = num_convenio_cumplido_10m, num_convenio_nocumplido_11m = num_convenio_nocumplido_10m,
			 num_vencidos12 = num_vencidos11, num_vencidos13 = num_vencidos12, num_vencidos14 = num_vencidos13, num_vencidos15 = num_vencidos14,
			 num_vencidos16 = num_vencidos15, num_vencidos17 = num_vencidos16, num_vencidos18 = num_vencidos17, num_vencidos19 = num_vencidos18,
			 num_vencidos20 = num_vencidos19, num_vencidos21 = num_vencidos20, num_vencidos22 = num_vencidos21, num_vencidos23 = num_vencidos22, empresa = vEmpresa
			 WHERE num_credito = vNum_credito;
	    COMMIT;
		    let iContador_upd = iContador_upd + 1;

			
		else	
	       begin;	
			INSERT INTO informix.cb_triad_sdos_inds_tdc(num_credito, fecha_proceso, fecha_ciclo1, cod_bloqueo_cta1, sdo_tot_liquidar1, pago_minimo1, 
			monto_pagos1, sdo_tot_vencido1, intereses_periodo1, num_vencidos1, monto_pos1, monto_disp_efectivo1, monto_comisiones1, num_pos1, num_disp_efectivo1,
			limite_credito1, comision_anualidad1, comision_disp_efectivo1, monto_devoluciones1, monto_otras_trnx1, num_convenio_cumplido_1m, 
			num_convenio_nocumplido_1m, fecha_ciclo2, cod_bloqueo_cta2, sdo_tot_liquidar2, pago_minimo2, monto_pagos2, sdo_tot_vencido2, intereses_periodo2, 
			num_vencidos2, monto_pos2, monto_disp_efectivo2, monto_comisiones2, num_pos2, num_disp_efectivo2, limite_credito2, comision_anualidad2, 
			comision_disp_efectivo2, monto_devoluciones2, monto_otras_trnx2, num_convenio_cumplido_2m, num_convenio_nocumplido_2m, fecha_ciclo3,
			cod_bloqueo_cta3, sdo_tot_liquidar3, pago_minimo3, monto_pagos3, sdo_tot_vencido3, intereses_periodo3, num_vencidos3, monto_comisiones3,
			monto_pos3, num_pos3, monto_disp_efectivo3, num_disp_efectivo3, limite_credito3, comision_anualidad3, comision_disp_efectivo3, monto_devoluciones3,
			monto_otras_trnx3, num_convenio_cumplido_3m, num_convenio_nocumplido_3m, fecha_ciclo4, cod_bloqueo_cta4, sdo_tot_liquidar4, pago_minimo4, 
			monto_pagos4, sdo_tot_vencido4, intereses_periodo4, num_vencidos4, monto_comisiones4, monto_pos4, num_pos4, monto_disp_efectivo4, 
			num_disp_efectivo4, limite_credito4, comision_anualidad4, comision_disp_efectivo4, monto_devoluciones4, monto_otras_trnx4, 
			num_convenio_cumplido_4m, num_convenio_nocumplido_4m, fecha_ciclo5, cod_bloqueo_cta5, sdo_tot_liquidar5, pago_minimo5, monto_pagos5, 
			sdo_tot_vencido5, intereses_periodo5, num_vencidos5, monto_comisiones5, monto_pos5, num_pos5, monto_disp_efectivo5, num_disp_efectivo5, 
			limite_credito5, comision_anualidad5, comision_disp_efectivo5, monto_devoluciones5, monto_otras_trnx5, num_convenio_cumplido_5m, 
			num_convenio_nocumplido_5m, fecha_ciclo6, cod_bloqueo_cta6, sdo_tot_liquidar6, pago_minimo6, monto_pagos6, sdo_tot_vencido6, intereses_periodo6, 
			num_vencidos6, monto_comisiones6, monto_pos6, num_pos6, monto_disp_efectivo6, num_disp_efectivo6, limite_credito6, comision_anualidad6, 
			comision_disp_efectivo6, monto_devoluciones6, monto_otras_trnx6, num_convenio_cumplido_6m, num_convenio_nocumplido_6m, fecha_ciclo7, 
			cod_bloqueo_cta7, sdo_tot_liquidar7, pago_minimo7, monto_pagos7, sdo_tot_vencido7, intereses_periodo7, num_vencidos7, monto_comisiones7, 
			monto_pos7, num_pos7, monto_disp_efectivo7, num_disp_efectivo7, limite_credito7, comision_anualidad7, comision_disp_efectivo7, 
			monto_devoluciones7, monto_otras_trnx7, num_convenio_cumplido_7m, num_convenio_nocumplido_7m, fecha_ciclo8, cod_bloqueo_cta8, 
			sdo_tot_liquidar8, pago_minimo8, monto_pagos8, sdo_tot_vencido8, intereses_periodo8, num_vencidos8, monto_comisiones8, monto_pos8, num_pos8, 
			monto_disp_efectivo8, num_disp_efectivo8, limite_credito8, comision_anualidad8, comision_disp_efectivo8, monto_devoluciones8, monto_otras_trnx8, 
			num_convenio_cumplido_8m, num_convenio_nocumplido_8m, fecha_ciclo9, cod_bloqueo_cta9, sdo_tot_liquidar9, pago_minimo9, monto_pagos9, 
			sdo_tot_vencido9, intereses_periodo9, num_vencidos9, monto_comisiones9, monto_pos9, num_pos9, monto_disp_efectivo9, num_disp_efectivo9, 
			limite_credito9, comision_anualidad9, comision_disp_efectivo9, monto_devoluciones9, monto_otras_trnx9, num_convenio_cumplido_9m, 
			num_convenio_nocumplido_9m, fecha_ciclo10, cod_bloqueo_cta10, sdo_tot_liquidar10, pago_minimo10, monto_pagos10, sdo_tot_vencido10, 
			intereses_periodo10, num_vencidos10, monto_comisiones10, monto_pos10, num_pos10, monto_disp_efectivo10, num_disp_efectivo10, limite_credito10, 
			comision_anualidad10, comision_disp_efectivo10, monto_devoluciones10, monto_otras_trnx10, num_convenio_cumplido_10m, num_convenio_nocumplido_10m, 
			fecha_ciclo11, cod_bloqueo_cta11, sdo_tot_liquidar11, pago_minimo11, monto_pagos11, sdo_tot_vencido11, intereses_periodo11, num_vencidos11, 
			monto_comisiones11, monto_pos11, num_pos11, monto_disp_efectivo11, num_disp_efectivo11, limite_credito11, comision_anualidad11, 
			comision_disp_efectivo11, monto_devoluciones11, monto_otras_trnx11, num_convenio_cumplido_11m, num_convenio_nocumplido_11m, num_vencidos12, 
			num_vencidos13, num_vencidos14, num_vencidos15, num_vencidos16, num_vencidos17, num_vencidos18, num_vencidos19, num_vencidos20, num_vencidos21, 
			num_vencidos22, num_vencidos23, empresa) 
			VALUES(vNum_credito, vFecha_hoy, vFecha_hoy, '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
			'01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			'01/01/1900', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			'01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
			'01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			'01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '01/01/1900', '0000', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, vEmpresa);
	       commit;
           let iContador = iContador + 1;  		
		   
        end if;			
	
     let iExisteCuenta = 0;
	 let vEmpresa_2 = '';
	 
     END FOREACH  		
 END IF;			
 
  
    

--CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, vmensaje|| cEjecucion, '03') RETURNING cCod_ret_2; 
CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, vmensaje, '03') RETURNING cCod_ret_2; 

let vmensaje        = 'Proceso exitoso';
RETURN vcodigo, trim(vmensaje) || ' Actualizadas[' || iContador_upd || '] - Insertadas[' || iContador || ']';



END;
END PROCEDURE;