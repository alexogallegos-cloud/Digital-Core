create procedure "informix".cancela(pempresa char(3),
                           psucursal char(4),
                           pusuario char(8),
                           ptransacc char(4),
                           pcuenta char(20),
			   pfolio_suc char(16),
			   ptransacc_suc char(4),
			   pcap_int char(1))

returning char(5),money(14,2),decimal(9,6),money(14,2),money(14,2),
          money(14,2),money(14,2),char(3);

define v_serial,sql_err,isam_err integer;
define v_fech_reinv date;
define v_contab char(1);
define v_dias_prov,vsecuencia smallint;
define vstatus_cta,vfisica,vexento_isr,vinserta char(1);
define transacc char(4);
define v_provision money(14,2);
define v_cta_cheques char(20);
define vtip_per,v_opcion_retiro,
	v_tipo_instrum,v_moneda char(2);
define v_plazo smallint;
define v_sdo money(14,2);
define w_hora datetime hour to fraction;
define cod_ret char(5);
define vcod,v_plaza char(3);
define vsuc_cta, v_sucursal char(4);
define vcod_instrum char(4);
define vtasa, v_usuario char(8);
define v_bandera char(1);
define vnum_cte char(20);
define vcuenta char(20);
define v_trans_int,v_trans_ret,v_trans_isr,v_trans_prov,
       v_trans_vtopas2,v_transacc_suc,v_trans_recap,v_trans_reint char(4);
define vvalor_tasa,vval,v_sobretasa,v_tasa decimal(9,6);
define v_tasains  char(9);
define vacum_sdo_pos,vsdo_actual,vsdo_retenido,vsdo_cong,vsdo_prom,
	vtot_int,visr,vtot_canc,v_capital,v_intereses,v_isr,
        v_int_neto  money(14,2);
define vnum_dias_int,vdia_sdo_pos,v_cant_dias,
        v_fol_suc smallint;
define hoy,v_prox,v_pri_dia date;
define v_fecha_venc date;
define v_per_acred_int char(1);
define w_fol_suc char(5);
define w_folio char(16);
define v_dia1,v_dia2,v_day,v_day2,v_fecha1,v_fecha2 smallint;
define v_long_param char(2);

-- *********************************************************************
-- Inicializa variables
-- *********************************************************************
let 	vsdo_prom 	= 0;
let 	vvalor_tasa 	= 0;
let 	vsdo_actual 	= 0;
let 	vtot_int 	= 0;
let 	visr 		= 0;
let 	v_isr 		= 0;
let 	v_int_neto	= 0;
let 	vtot_canc 	= 0;
let 	vinserta 	= "1";
let 	cod_ret 	= "000";
let     vsuc_cta        = "0000";

   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,vsdo_prom,vvalor_tasa,vsdo_actual,v_int_neto,
            	   v_isr,vtot_canc,vsuc_cta;
         end if;
      end exception;

   select ejecutivo into v_usuario from bdinteg:si_ejecut
      where ejecutivo = pusuario;
   if v_usuario <> pusuario or v_usuario is null then
      let cod_ret = "107";
      return cod_ret,vsdo_prom,vvalor_tasa,vsdo_actual,v_int_neto,
       	     v_isr,vtot_canc,vsuc_cta;
   end if;

-- *********************************************************************
-- Extrae datos de la cuenta de Inversion
-- *********************************************************************
select mv.cuenta,secuencia,fecha_venc,fec_reinversion,mv.cod_instrum,
	dia_sdo_pos,acum_sdo_pos,
       	status_cta,sdo_retenido,sdo_cong,capital,intereses,
	isr,tasa,sobretasa,opcion_retiro,plazo,mv.plaza,
        sucursal,mv.per_acred_int,trans_int,trans_vtopas2,
        trans_isr,trans_prov,trans_recap,trans_reint,num_cte,
	num_dias_int,moneda,cta_cheques,provision_int 
   into
        vcuenta,vsecuencia,v_fecha_venc,v_fech_reinv,vcod_instrum,vdia_sdo_pos,
	vacum_sdo_pos,vstatus_cta,vsdo_retenido,vsdo_cong,
	v_capital,v_intereses,v_isr,v_tasa,v_sobretasa,
	v_opcion_retiro,v_plazo,v_plaza,v_sucursal,
	v_per_acred_int,v_trans_int,v_trans_vtopas2,
	v_trans_isr,v_trans_prov,v_trans_recap, v_trans_reint,
        vnum_cte,vnum_dias_int,v_moneda,v_cta_cheques,v_contab
   from sv_maeinv mv,sv_instrum pr
   where mv.empresa = pempresa and cuenta = pcuenta and status_cta <> "4" and
   	pr.empresa = mv.empresa and mv.cod_instrum = pr.cod_instrum;

let vsuc_cta = v_sucursal;
if vcuenta is null then
	let cod_ret = "100";
        return cod_ret,vsdo_prom,vvalor_tasa,vsdo_actual,v_int_neto,
            	v_isr,vtot_canc,vsuc_cta;
end if
if v_sobretasa is null then
   let v_sobretasa = 0;
end if

if v_per_acred_int is null then
      	let cod_ret="333";
      	return cod_ret,vsdo_prom,vvalor_tasa,vsdo_actual,v_int_neto,
        v_isr,vtot_canc,vsuc_cta;
end if

   --- Verifica que la cuenta no este cancelada
if vstatus_cta = "2" or vstatus_cta="4" then
	let cod_ret = "200";
      	return cod_ret,vsdo_prom,vvalor_tasa,vsdo_actual,v_int_neto,
             v_isr,vtot_canc,vsuc_cta;
end if;

   --- Verifica que la cuenta no este bloqueada
if vstatus_cta = "3" then
	let cod_ret = "303";
      	return cod_ret,vsdo_prom,vvalor_tasa,vsdo_actual,v_int_neto,
             v_isr,vtot_canc,vsuc_cta;
end if;

   --- Verifica que la cuenta no tenga saldo congelado o retenido
if vsdo_cong != 0 or vsdo_retenido != 0 then
    	let cod_ret = "305";
      	return cod_ret,vsdo_prom,vvalor_tasa,vsdo_actual,v_int_neto,
             	v_isr,vtot_canc,vsuc_cta;
end if;

-- Determina Fecha
select fecha_hoy,weekday(fecha_hoy),day(fecha_hoy),prox_fecha,pri_dia_mes
   into hoy,v_day,v_day2,v_prox,v_pri_dia 
   from sv_fechas
   where empresa = pempresa;

   let v_cant_dias = v_prox - hoy;

-- Determina que tipo de cuenta es para realizar el pago de intereses.
if v_per_acred_int="V" or v_per_acred_int <> "M" then
	if v_fecha_venc!=hoy then
	   let cod_ret="334";
      	   return cod_ret,vsdo_prom,vvalor_tasa,vsdo_actual,v_int_neto,
             		v_isr,vtot_canc,vsuc_cta;
	else
	   select importe into v_int_neto
	      from sv_maeinstrucc
	      where empresa = pempresa and cuenta = pcuenta and 
                    cap_int = "I" and aplicado <> "S" and
		    (inst_vento = "01" or inst_vento = "04");
           if v_int_neto is not null then
              let v_int_neto = v_intereses - v_isr;
	   else
	      let v_int_neto = 0;
	      let v_isr = 0;
	      let v_intereses = 0;
	   end if;
	   select importe into v_capital
	      from sv_maeinstrucc
	      where empresa = pempresa and cuenta = pcuenta and 
                    cap_int = "C" and aplicado <> "S" and
		    (inst_vento = "01" or inst_vento = "04");
	   if v_capital is null then
	      let v_capital = 0;
	   end if;
	   if pcap_int = "I" then
              let vsdo_actual = v_int_neto;
	      let v_intereses = v_int_neto + v_isr;
	   else
      	      let vsdo_actual = v_capital + (v_int_neto + v_isr );
      	      let v_intereses = v_int_neto +  v_isr;
	   end if;
           --- Realiza el movimiento del deposito de los intereses
   		if v_intereses > 0 and v_int_neto > 0 then
			if v_contab="V" then
				if v_fech_reinv < v_pri_dia then
					let v_dias_prov=hoy-v_pri_dia;
					let v_provision=(v_intereses/
					    v_plazo)*v_dias_prov;
				else
					let v_provision=v_intereses;
				end if;
                  		let v_transacc_suc = "0000";
                  		let w_hora = current hour to fraction;
                  		insert into sv_movdia
                    		   values(pempresa,0,pfolio_suc,v_plaza,
                                        psucursal,pusuario,hoy,w_hora,
                                        v_trans_prov,v_sucursal,vcuenta,
                                        vsecuencia,vcod_instrum,
					0,v_provision,v_provision,0,
					0,"", v_capital,
					v_transacc_suc);
		                let v_serial = 0;
				insert into sv_auxcont
				  values (pempresa,vcuenta,v_tasa,v_sobretasa);
			end if;
                  	let v_transacc_suc = "0000";
                  	let w_hora     = current hour to fraction;
                  	insert into sv_movdia
                    	values(pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,
                          hoy,w_hora,v_trans_int,v_sucursal,
                          vcuenta,vsecuencia,vcod_instrum,0,v_intereses,
                          v_intereses,0,0,"", v_capital,v_transacc_suc);
   		end if

                --- Realiza el movimiento del cargo de isr
   		if v_isr > 0  and v_int_neto > 0 then
                  	let v_transacc_suc = "0000";
                  	let w_hora = current hour to fraction;
                  	insert into sv_movdia
                    	   values(pempresa,0,pfolio_suc,v_plaza,
                                psucursal,pusuario,
                          	hoy,w_hora,v_trans_isr,v_sucursal,
                           	vcuenta,vsecuencia,vcod_instrum,0,v_isr,v_isr,
				0,0,"", v_capital,v_transacc_suc);
   		end if

                --- Realiza el movimiento del cargo de total de la cancelacion
   		if v_int_neto > 0 or v_capital > 0 then
                   let v_transacc_suc = "0000";
                   if v_int_neto > 0 then
                      let w_hora = current hour to fraction;
                      insert into sv_movdia
                    	values(pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,
                           	hoy,w_hora,v_trans_reint,v_sucursal,
                           	vcuenta,vsecuencia,vcod_instrum,0,v_int_neto,
                           	v_int_neto,0,0,"", vsdo_actual,
                           	v_transacc_suc);
                   end if
                   if v_capital > 0 and pcap_int <> "I" then
                      let w_hora = current hour to fraction;
                      insert into sv_movdia
                    	values(pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,
                           	hoy,w_hora,v_trans_recap,v_sucursal,
                           	vcuenta,vsecuencia,vcod_instrum,0,v_capital,
                           	v_capital,0,0,"", vsdo_actual,
                           	v_transacc_suc);
                   end if
		   if pcap_int <> "I" then
                  	insert into sv_movdia
                    	values(pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,
                           	hoy,w_hora,v_trans_vtopas2,v_sucursal,
                           	vcuenta,vsecuencia,vcod_instrum,0,v_capital,
                           	v_capital,0,0,"", v_capital,
                           	v_transacc_suc);
   			-- Actualiza el Maestro de Inversiones
     			update sv_maeinv
    			   set status_cta   = "2",
       			   fec_cancelac = hoy,
      			   modificado   = pusuario,
       			   fecha_mod    = hoy
     			   where empresa = pempresa and cuenta=pcuenta and
                                 secuencia = vsecuencia;
  			-- Actualiza el maestro de instrucciones
                        update sv_maeinstrucc
                           set aplicado = "S"
                  	   where empresa = pempresa and cuenta = pcuenta;
		    else
		       update sv_maeinstrucc
			  set aplicado = "S"
			  where empresa = pempresa and cuenta = pcuenta 
                                and cap_int = "I";
		    end if;
   		end if
	end if;
else
if v_per_acred_int="M" then
	if v_opcion_retiro is not null and v_opcion_retiro!= " "
            and v_opcion_retiro <> "0"  then
		select dia1,dia2,fecha1,fecha2
			into v_dia1,v_dia2,v_fecha1,v_fecha2
			from sv_opcretiro
			where empresa = pempresa and cod_retiro=v_opcion_retiro;
		if v_dia1 is null and v_dia2 is null
			 and v_fecha1 is null and v_fecha2 is null then
			let cod_ret="335";
      			return cod_ret,vsdo_prom,vvalor_tasa,v_capital,
                               v_int_neto,v_isr,vtot_canc,vsuc_cta;
		else
			if v_day !=v_dia1 or v_day!=v_dia2 or
			   v_day2 !=v_fecha1 or v_day2!=v_fecha2 then
				let cod_ret="336";
			else
      			   if vdia_sdo_pos > 0 then
         		      let vsdo_prom=vacum_sdo_pos/vdia_sdo_pos;
			      let v_bandera="1";
      			   else
         		      let vsdo_prom = 0;
			      let v_bandera="1";
      			   end if
			end if
		end if
	else
	   if v_fecha_venc!=hoy then
	      let cod_ret="334";
      	      return cod_ret,vsdo_prom,vvalor_tasa,v_capital,
                     v_int_neto,v_isr,vtot_canc,vsuc_cta;
	   else
	      if v_fech_reinv < v_pri_dia then
		 let v_dias_prov = hoy - v_pri_dia;
	      else
		 let v_dias_prov = hoy - v_fech_reinv;
	      end if;
	      select importe into v_int_neto
	         from sv_maeinstrucc
	         where empresa = pempresa and cuenta = pcuenta and 
                       cap_int = "I" and
		       (inst_vento = "01" or inst_vento = "04");
	      if v_int_neto is not null then
                 let v_int_neto = v_intereses - v_isr;
	      else
	         let v_int_neto = 0;
	         let v_isr = 0;
	         let v_intereses = 0;
	      end if;
	      select importe into v_capital
	         from sv_maeinstrucc
	         where empresa = pempresa and cuenta = pcuenta and 
                    cap_int = "C" and
		    (inst_vento = "01" or inst_vento = "04");
	      if v_capital is null then
	         let v_capital = 0;
	      end if;
	      let v_intereses = v_intereses / v_plazo * v_dias_prov;
	      let v_isr = v_isr / v_plazo * v_dias_prov;
	      if pcap_int = "I" then
		 let vtot_canc = v_intereses - v_isr;
	  	 let vsdo_actual = vtot_canc;
		 let v_int_neto = vtot_canc;
	      else
      	         let vtot_canc   = v_capital + (v_intereses - v_isr);
      	         let vsdo_actual = vtot_canc;
		 let v_int_neto = v_intereses - v_isr;
	      end if;
  	      --- Realiza el movimiento del deposito de los intereses
   	      if v_intereses > 0  and v_int_neto > 0 then
                  let v_transacc_suc = "0000";
                  let w_hora     = current hour to fraction;
                  insert into sv_movdia
                    values(pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,
                           hoy,w_hora,v_trans_int,v_sucursal,
                           vcuenta,vsecuencia,vcod_instrum,0,v_intereses,
                           v_intereses,0,0,"", v_capital,
                           v_transacc_suc);
                  insert into sv_movdia
                    values(pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,
                           hoy,w_hora,v_trans_prov,v_sucursal,
                           vcuenta,vsecuencia,vcod_instrum,0,v_intereses,
                           v_intereses,0,0,"", v_capital,
                           v_transacc_suc);
		  let v_serial = 0;
		  insert into sv_auxcont
		     values (pempresa,vcuenta,v_tasa,v_sobretasa);
   	      end if

   	      --- Realiza el movimiento del cargo de isr
   	      if v_isr > 0 and v_int_neto > 0  then
                  let v_transacc_suc = "0000";
                  let w_hora     = current hour to fraction;
                  insert into sv_movdia
                    values(pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,
                           hoy,w_hora,v_trans_isr,v_sucursal,
                           vcuenta,vsecuencia,vcod_instrum,0,v_isr,
                           v_isr,0,0,"", v_capital,
                           v_transacc_suc);
   	      end if

              --- Realiza el movimiento del cargo de total de la cancelacion
   		if vtot_canc > 0 then
                  let v_transacc_suc = "0000";
                  let w_hora     = current hour to fraction;
                  insert into sv_movdia
                    values(pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,
                           hoy,w_hora,v_trans_recap,v_sucursal,
                           vcuenta,vsecuencia,vcod_instrum,0,vtot_canc,
                           vtot_canc,0,0,"", v_capital,
                           v_transacc_suc);
   		end if
		   if pcap_int <> "I" then
                  	insert into sv_movdia
                    	values(pempresa,0,pfolio_suc,v_plaza,psucursal,pusuario,
                           	hoy,w_hora,v_trans_vtopas2,v_sucursal,
                           	vcuenta,vsecuencia,vcod_instrum,0,v_capital,
                           	v_capital,0,0,"", v_capital,
                           	v_transacc_suc);
   			-- Actualiza el Maestro de Inversiones
     			update sv_maeinv
    			   set status_cta   = "2",
       			   fec_cancelac = hoy,
      			   modificado   = pusuario,
       			   fecha_mod    = hoy
     			   where empresa = pempresa and cuenta=pcuenta and
                                 secuencia = vsecuencia;
  			-- Actualiza el maestro de instrucciones
                        update sv_maeinstrucc
                           set aplicado = "S"
                  	   where empresa = pempresa and cuenta = pcuenta;
		    else
		       update sv_maeinstrucc
			  set aplicado = "S"
			  where empresa = pempresa and cuenta = pcuenta 
                                and cap_int = "I";
   		end if
   		return cod_ret,vsdo_prom,vvalor_tasa,v_capital,
                       v_int_neto,v_isr,vtot_canc,vsuc_cta;
		end if;
	end if;
else
	let vsdo_prom=v_capital;
	let v_bandera="1";
end if

      -- Determina el tipo de persona
      select tpo_persona into vtip_per from bdinteg:si_cliente
      where numcte = vnum_cte;

      select es_fisica,exento_isr into vfisica,vexento_isr
      from bdinteg:si_tipper
      where tpo_persona = vtip_per;

      if vfisica = "S" then
         let vtip_per = "F ";
      else
         let vtip_per = "M ";
      end if

      -- Extrae la tasa con que se va a pagar interes
if v_bandera="1" then
      if vsdo_prom > 0 then
         select UNIQUE(tasa) into v_tasains from sv_plazotasa
            where empresa = pempresa and cod_instrum = vcod_instrum and
                  plaza = v_plaza and
                  plazo_min <= v_plazo and plazo_max >= v_plazo;
         foreach
         execute procedure  calc_tasa(pempresa,v_tasains,vtip_per,vsdo_prom)
                                      into vcod,vval
         end foreach
         if vcod = "000" then
            let vvalor_tasa = vval / 100;
	    if v_per_acred_int="D" then
            		let v_intereses = (vsdo_prom * vvalor_tasa) /
                                           vnum_dias_int;
	    else
            		let v_intereses=((vsdo_prom * vvalor_tasa)/
                                          vnum_dias_int)*v_day2;
	    end if;

            foreach
            execute procedure
	 	calc_isr(pempresa,v_intereses,v_cant_dias,vnum_dias_int)
                into vcod,visr
            end foreach
            let v_isr = visr;
 	 else
	    let cod_ret="901";
      	    return cod_ret,vsdo_prom,vvalor_tasa,vsdo_actual,v_int_neto,
           	   v_isr,vtot_canc,vsuc_cta;
         end if
      end if
      let vtot_canc = v_capital + v_intereses - visr;
      let vsdo_actual = vtot_canc;
      let v_int_neto = v_intereses - visr;
   end if
end if;
return cod_ret,vsdo_prom,vvalor_tasa,v_capital,v_int_neto,
	v_isr,vtot_canc,vsuc_cta;
end;   -- fin del on exception
end procedure;