create procedure "informix".stgencont()
   returning char(5);
-- ****************************** Definicion de Variables *********************
-- Variables para st_maetrans
   define va_unidades_divisa money(14,2);
   define va_mto_pagado_mn   money(14,2);
   define va_mto_efec_abono  money(14,2);
   define va_mto_efec_a_div  money(14,2);
   define va_mto_efec_a_val  money(14,2);
   define va_mto_abono_cta   money(14,2);
   define va_monto           money(14,2);
   define va_mto_efec_cargo  money(14,2);
   define va_mto_efec_c_div  money(14,2);
   define va_mto_efec_c_val  money(14,2);
   define va_mto_cargo_cta   money(14,2);
   define va_comision        money(14,2);
   define va_telef_telex     money(14,2);
   define va_total_com       money(14,2);

-- Variables para st_movdia
   define vm_plaza          char(3);
   define vm_sucursal       char(3);
   define vm_usuario        char(8);
   define vm_fecha_hora     datetime year to second;
   define vm_num_transacc   char(4);
   define vm_tipo_movto     char(1);
   define vm_moneda_movto   char(2);
   define vm_tipo_docto     char(2);
   define vm_num_docto      char(10);

-- Variables para bdicent:si_transacc
   define vr_numero         char(4);
   define vr_descripcion    char(40);
   define vr_sistema        char(2);
   define vr_abreviatura    char(14);
   define vr_naturaleza     char(1);
   define vr_tipo_tran      char(2);
   define vr_tran_relac     char(4);
   define vr_realizada_por  char(1);
   define vr_monto_fijo     money(14,2);
   define vr_tasa_aplicada  char(8);
   define vr_tipo_formula   char(1);
   define vr_cod_proced     char(2);
   define vr_valida_docto   char(1);

-- Variables para bdicent:ctas_transacc
   define vc_num_transacc   char(4);
   define vc_aplicacion_a   char(1);
   define vc_ccmayor        char(4);
   define vc_ccsub          char(2);
   define vc_ccsubsub       char(2);
   define vc_ccsssub        char(2);
   define vc_ccssssub       char(2);
   define vc_sector         char(2);
   define vc_cargo_abono    char(1);

-- Variables solo de Trabajo (No pertenecen a ninguna Tabla)
   define n, m              smallint;
   define vt_monto          money(14,2);
   define vt_iva            decimal(2,2);
   define vt_tran_lectura   char(4);
   define vt_existe         smallint;
   define vt_cod_ret        char(5);
   define sql_err, isam_err integer;

-- *************************** Inicializacion de Variables *********************
   let vt_cod_ret = "000";

   set isolation to cursor stability;
   set lock mode to wait;


   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let vt_cod_ret = sql_err;
            return vt_cod_ret;
         end if;
      end exception;

-- *************************** Validaciones y Calculos *************************
begin work;
delete from st_contab;
-- Lectura de Cada Renglon de Movimientos Diarios de Transferencias
foreach genera_contab_cur for
   select st_movdia.plaza, st_movdia.sucursal, st_movdia.usuario,
          st_movdia.fecha_hora, st_movdia.num_transacc, st_movdia.tipo_movto,
	  st_movdia.moneda_movto, st_movdia.tipo_docto, st_movdia.num_docto,
          st_maetrans.unidades_divisa, st_maetrans.monto, st_maetrans.comision,
	  st_maetrans.telef_telex, st_maetrans.total_com
      into vm_plaza, vm_sucursal, vm_usuario,
           vm_fecha_hora, vm_num_transacc, vm_tipo_movto,
	   vm_moneda_movto, vm_tipo_docto, vm_num_docto,
           va_unidades_divisa, va_monto, va_comision,
	   va_telef_telex, va_total_com
      from st_movdia, st_maetrans
      where st_movdia.tipo_docto   = st_maetrans.tipo_docto and
            st_movdia.num_docto    = st_maetrans.num_docto and
            st_movdia.moneda_movto = st_maetrans.moneda
      order by st_movdia.moneda_movto, st_movdia.tipo_docto,
	       st_movdia.fecha_hora, st_movdia.num_docto
      -- No Existio Registro alguno a Procesar
      if vm_sucursal is null then
	 let vt_cod_ret = "208";
	 return vt_cod_ret;
      end if
      -- Selecciona el Porcentaje del IVA a cobrar por la plaza
      select iva into vt_iva from bdicent:si_sucursales
      where sucursal = vm_sucursal;
      -- Selecciona el Detalle de la Transaccion Referenciada
      for n = 1 to 10
	 -- Si es la  pimera iteracion, se considera el numero de transaccion
	 -- contenido en la tabla de movimientos, de lo contrario se considera
	 -- el numero de la posible transaccion relacionada
	 if n = 1 then
	    let vt_tran_lectura = vm_num_transacc;
         else
	    -- Si el ciclo va mas alla de la primera iteracion, y NO existe
	    -- transacc. Relacionada se finalizara el Ciclo.
	    if vr_tran_relac = " " or vr_tran_relac is null then
	       exit for;
	    else
	       let vt_tran_lectura = vr_tran_relac;
            end if
         end if
         trace "Lectura de Inf. de Transacciones (si_transacc)";
         select numero, naturaleza, tipo_tran, tran_relac
   	 into vr_numero, vr_naturaleza, vr_tipo_tran, vr_tran_relac
         from bdicent:si_transacc
	 where numero = vt_tran_lectura;
	    -- No existio la Transaccion indicada en st_movdia
	    if vr_numero is null then
	       let vt_cod_ret = "209";
	       return vt_cod_ret;
            end if
	    -- Si la defincion de la Transaccion definida para el movto. que se
	    -- procesa indica que es de tipo Referencial, este No se Considerara
	    if vr_naturaleza = "R" then
	       exit for;
            end if
	    -- Ciclo para Cargo y Abono de la Transaccion Indicada
            trace "Lectura de Inf. de Ctas. Contables";
            foreach
	       select aplicacion_a, ccmayor,
                      ccsub, ccsubsub,
                      ccsssub, ccssssub,
                      sector, cargo_abono
                  into vc_aplicacion_a, vc_ccmayor,
                       vc_ccsub, vc_ccsubsub,
                       vc_ccsssub, vc_ccssssub,
                       vc_sector, vc_cargo_abono
                  from bdicent:ctas_transacc
		  where num_transacc = vr_numero
		  if vc_ccmayor is null then
		     -- trace "Sale de Ciclo Foreach Cta. Cont";
		     exit foreach;
                  end if
		  -- Instrucciones que indicaran la asignacion de los va-
		  -- lores que posteriormente seran insertados
		  -- Verifica ALTAS
		  if vt_tran_lectura = "0070" or   -- C. Caja
		     vt_tran_lectura = "0082" or   -- C. Cert.
		     vt_tran_lectura = "0073" or   -- G. Banc.
		     vt_tran_lectura = "0075" then -- O. Pago
		     if vc_aplicacion_a = "1" then
		        let vt_monto = va_monto;
                     else
		        let vt_monto = va_unidades_divisa;
		     end if
                  -- Verifica Comision x Docto.
		  elif vt_tran_lectura = "3080" or -- C. Caja
		     vt_tran_lectura = "3088" or   -- C. Cert.
		     vt_tran_lectura = "3094" or   -- G. Banc.
		     vt_tran_lectura = "3099" then -- O. Pago
		     let vt_monto = va_comision;
                  -- Verifica IVA de Comision x Docto.
		  elif vt_tran_lectura = "3081" or -- C. Caja
		     vt_tran_lectura = "3089" or   -- C. Cert.
		     vt_tran_lectura = "3095" or   -- G. Banc.
		     vt_tran_lectura = "3100" then -- O. Pago
		     let vt_monto = va_comision * vt_iva;
                  -- Verifica Gastos de Transmision (O.P. Solamente)
		  elif vt_tran_lectura = "0101" then -- O. Pago
		     let vt_monto = va_telef_telex;
                  -- Verifica IVA de Gastos de Transmision (O.P. Solamente)
		  elif vt_tran_lectura = "0101" then -- O. Pago
		     let vt_monto = va_telef_telex * vt_iva;
                  -- Verifica CANCELACIONES
		  elif vt_tran_lectura = "3080" or -- C. Caja
		     vt_tran_lectura = "0087" or   -- C. Cert.
		     vt_tran_lectura = "0093" or   -- G. Banc.
		     vt_tran_lectura = "0098" then -- O. Pago
		     if vc_aplicacion_a = "1" then
		        let vt_monto = va_monto;
                     else
		        let vt_monto = va_unidades_divisa;
		     end if
                  -- Verifica LIQUIDACIONES
		  elif vt_tran_lectura = "0072" or -- C. Caja
		     vt_tran_lectura = "0083" or   -- C. Cert.
		     vt_tran_lectura = "0074" or   -- G. Banc.
		     vt_tran_lectura = "0076" then -- O. Pago
		     if vc_aplicacion_a = "1" then
		        let vt_monto = va_monto;
                     else
		        let vt_monto = va_unidades_divisa;
		     end if
		  end  if
		  -- Valida por importe en 0 para no generar poliza
		  if vt_monto = 0 then
		     exit foreach;
                  end if

		  -- Inserta en la Tabla de Contabilidad de Transferencias
		  select count(*) into vt_existe
		     from st_contab
		     where sucursal    = vm_sucursal and
			   ccmayor     = vc_ccmayor and
                           ccsub       = vc_ccsub and
			   ccsubsub    = vc_ccsubsub and
                           ccssubsub   = vc_ccsssub and
			   ccsssubsub  = vc_ccssssub and
                           sector      = vc_sector and
			-- suc_cta     = vc_suc_cta and
			   cargo_abono = vc_cargo_abono;
                     if vt_existe < 1 then
		        insert into st_contab
		           values(vm_sucursal,
			          vc_ccmayor,
                                  vc_ccsub,
			          vc_ccsubsub,
                                  vc_ccsssub,
			          vc_ccssssub,
                                  vc_sector,
			          " ",              -- suc_cta ?
			          vc_cargo_abono,
			          vt_monto,
			          vm_moneda_movto);
                     else
			update st_contab
			   set monto = (monto + vt_monto)
		           where sucursal    = vm_sucursal and
			         ccmayor     = vc_ccmayor and
                                 ccsub       = vc_ccsub and
			         ccsubsub    = vc_ccsubsub and
                                 ccssubsub   = vc_ccsssub and
			         ccsssubsub  = vc_ccssssub and
                                 sector      = vc_sector and
			      -- suc_cta     = vc_suc_cta and
			         cargo_abono = vc_cargo_abono;
                     end if
            end foreach
      end for
end foreach;
commit work;
end;      --fin del on exception
return vt_cod_ret;
end procedure;