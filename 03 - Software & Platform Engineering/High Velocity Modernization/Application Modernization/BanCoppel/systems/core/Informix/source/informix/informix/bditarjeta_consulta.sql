create procedure "informix".consulta()
    returning int;

-- VARIABLES PARA RECUPERAR TABLA datos_recibidos
define v_producto             char(4);
define v_tipo_mensaje         char(4);
define v_tipo_comercio        char(4);
define v_codigo_transacc      char(2);
define v_cuenta_origen        char(2);
define v_cuenta_destino       char(2);
define v_fecha_hora_tran      char(10);
define v_bandera_reversa      char(1);
define v_bandera_preauto      char(1);
define v_secuencia_inter      char(6);
define v_secuencia_rastr      char(6);
define v_monto_mon_local      dec(12,2);
define v_moneda_local         char(3);
define v_monto_mon_orige      dec(12,2);
define v_moneda_origen        char(3);
define v_tasa_conversion      dec(14,7);
define v_numero_tarjeta       char(16);
define v_fecha_expedicio      char(4);
define v_id_teminal_orig      char(8);
define v_duenio_terminal      char(22);
define v_localizaciontern     char(13);
define v_pais_terminal        char(3);
define v_tipo_mens_orig_r     char(4);
define v_monto_realmonloc     dec(12,2);
define v_monto_realmonori     dec(12,2);
define v_sec_orig_rev         char(6);
define v_sec_rastreoorire     char(6);
define v_fecha_horaorirev     char(10);
define v_fecha_hora           datetime year to fraction;

-- VARIABLES PARA RECUPERAR TABLA datos_respuesta
define vnumero_tarjeta       char(16);
define vtipo_mensaje         char(4);
define vcodigo_respuesta     char(2);
define vcodigo_autorizac     char(6);
define vfecha_aplicacion     char(4);
define vcuenta_saldo         char(2);
define vtipo_saldo           char(2);
define vcredito_abono        char(1);
define vsdo_disp_lib         dec(12,2);
define vmoneda_saldo         char(3);
define vfecha_hora           datetime year to fraction;

-- VARIABLES PARA RECUPERAR TABLA tarjeta_debito
define vsecuencia            char(6);
define vstatus_tarjeta       char(2);
define vtipo_tarjeta         char(2);
define vcuenta_chq           char(20);
define vcuenta_aho           char(20);
define vcuenta_crd           char(20);
define vnombre_tarjeta       char(25);
define vnombre_adicional     char(25);
define vnumero__anterior     char(16);
define vfecha_alta           date;
define vfecha_vencimiento    char(4);
define vfecha_ini_vigenci    date;
define vfecha_rep_tarjeta    date;
define vlimite_diario_atm    dec(12,2);
define vlimite_diario_tot    dec(12,2);
define vlimite_mensual_to    dec(12,2);
define vmonto_disp_atm_di    dec(12,2);
define vmonto_disp_tot_di    dec(12,2);
define vmonto_disp_tot_me    dec(12,2);
define vejecutivo            char(4);

--VARIABLES VARIAS
define cod_ret int;
define mes     char(2);
define dia     char(2);
define mesdia  char(4);

-- VARIABLES DE RETORNO DE LA CONSULTA
   define w_cod_ret             char(5);
   define w_cuenta              char(20);
   define w_num_cte             char(20);
   define w_apell_pat           char(12);
   define w_apell_mat           char(12);
   define w_nombre1             char(12);
   define w_nombre2             char(12);
   define w_razon_soc           char(35);
   define w_edo_cta             char(1);
   define w_sdo_disp            money(14,2);
   define w_sdo_ret             money(14,2);
   define w_sdo_ccc             money(14,2);
   define w_sdo_disp_ccc        money(14,2);
   define w_sdo_cta             money(14,2);
   define w_tipo_linea          char(1);
   define v_prodnom             char(40);
   define v_moneda              char(40);
   define v_sdo_t1              money(14,2);
   define w_sdo_cong            money(14,2);
   define w_intacum             money(14,2);
   define w_imp_sbg_ccc         money(14,2);
   define w_imp_int_ccc         money(14,2);

on exception set cod_ret
	return cod_ret;
end exception;




-- INICIALIZA VARIABLES
let cod_ret = 0;

--ASEGURA QUE SOLO TENGA UN REGISTRO A LA VEZ
delete from datos_respuesta;

-- RECUPERA INFORMACION DE LA TABLA datos recibidos
select *
    into
        v_numero_tarjeta, v_tipo_comercio, v_tipo_mensaje,
        v_producto, v_codigo_transacc, v_cuenta_origen, v_cuenta_destino,
        v_fecha_hora_tran, v_bandera_reversa, v_bandera_preauto,
        v_secuencia_inter, v_secuencia_rastr, v_monto_mon_local,
        v_moneda_local, v_monto_mon_orige, v_moneda_origen,
        v_tasa_conversion, v_fecha_expedicio, v_id_teminal_orig,
        v_duenio_terminal, v_localizaciontern, v_pais_terminal,
        v_tipo_mens_orig_r, v_monto_realmonloc, v_monto_realmonori,
        v_sec_orig_rev, v_sec_rastreoorire, v_fecha_horaorirev,
        vfecha_hora
    from datos_recibidos;

-- RECUPERA INFORMACION DE LA CUENTA CORRESPONDIENTE A LA TARJETA
-- DE LA TABLA tarjeta_debito
select *
    into
         vnumero_tarjeta, vsecuencia, vstatus_tarjeta, vtipo_tarjeta,
         vcuenta_chq, vcuenta_aho, vcuenta_crd, vnombre_tarjeta,
         vnombre_adicional, vnumero__anterior, vfecha_alta, vfecha_vencimiento,
         vfecha_ini_vigenci, vfecha_rep_tarjeta, vlimite_diario_atm,
         vlimite_diario_tot, vlimite_mensual_to, vmonto_disp_atm_di,
         vmonto_disp_tot_di, vmonto_disp_tot_me, vejecutivo
    from tarjeta_debito
    where numero_tarjeta = v_numero_tarjeta
     and status_tarjeta = '01';

-- VERIFICA SI EXISTE LA TARJETA
if vnumero_tarjeta is null then
    let vcodigo_respuesta = '14';
	let dia = day(current);
	if dia < 10 then
		let dia = '0'||dia;
	end if
	let mes = month(current);
	if mes < 10 then
		let mes = '0'||mes;
	end if
	let mesdia = dia||mes;
    insert into datos_respuesta
        values (v_numero_tarjeta, '0210', '14', v_secuencia_inter,
                mesdia, '00', '00', ' ', 0.00, '000', current);
    return -100;    -- no existe la cuenta
end if

-- REALIZA LA CONSULTA DEL SALDO
let w_cod_ret, w_cuenta, w_num_cte, w_apell_pat, w_apell_mat, w_nombre1,
    w_nombre2, w_razon_soc, w_edo_cta, w_sdo_disp, w_sdo_ret, w_sdo_ccc,
    w_sdo_disp_ccc, w_sdo_cta, w_tipo_linea, v_prodnom, v_moneda, v_sdo_t1,
    w_sdo_cong, w_intacum, w_imp_sbg_ccc, w_imp_int_ccc
  =
    bdicheq:cons_sdos(vcuenta_chq);
-- VERIFICA SI EXISTE LA TARJETA
-- valores de retorno:
--     w_cod_ret = NULL,
--                  110 (cta en blanco o null),
--                  100 (no existe),
--                  104 (cte no existe)
if (w_cod_ret is null) or
   (w_cod_ret in ('110','100','104')) then
    let vcodigo_respuesta = '14';
	let dia = day(current);
	if dia < 10 then
		let dia = '0'||dia;
	end if
	let mes = month(current);
	if mes < 10 then
		let mes = '0'||mes;
	end if
	let mesdia = dia||mes;
    insert into datos_respuesta
        values (v_numero_tarjeta, '0210', '78', v_secuencia_inter,
                mesdia, '00', '00', ' ', 0.00, '000', current);
    return -100;    -- no existe la cuenta
end if

end procedure;