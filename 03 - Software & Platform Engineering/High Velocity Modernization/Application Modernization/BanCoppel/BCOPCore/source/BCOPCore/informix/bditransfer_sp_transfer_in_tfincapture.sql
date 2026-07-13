create procedure "informix".sp_transfer_in_tfincapture (
	pnombrearchivo char(23),
	parchivo_origen char(3),
	pnumtarjeta char(16),
	ptipo_conciliacion integer,
	ptransacc char(4),
	ptipotransaccion325 char(2),
	psecuenciaextendida char(15), 
	pmonto325 char(12),
	pidcomercio char(9),
	pfechaopetransfer char(6),
	pnomcomercio325 char(30),
	preferencia23_325 char(23),
	pdivisa325 char(3),
	prfc325 char(15)
)
returning varchar(6),varchar(80);
			
define	sql_err		integer;
define  isam_err    integer;
define  error_info  varchar(80);

define 	p_cod_ret 	char(5);
define 	p_mensaje 	char (80);

define vssecuencia  char (6);
define vsdivisa     char (3);
define vsrfc		char (15);



begin
	on exception set sql_err, isam_err, error_info
		let p_cod_ret  = sql_err;
		let p_mensaje  = error_info;
		
		return p_cod_ret, p_mensaje;
	end exception;

	--set debug file to "/informix/HomeInformix/rrm/sp_transfer_in_tfincapture.out";
	--trace on;

	let p_cod_ret 	= '00000';
	let p_mensaje 	= 'Proceso exitoso';

	let vssecuencia = '';	
	let vsdivisa 	= '';
	let vsrfc 		= '';

	-- Proceso para busqueda de secuencia del MPS para el correcto envio a Transfer 

	-- Inicia Proceso para realizar inserción 
	if psecuenciaextendida is null or psecuenciaextendida = '' /*and vssecuencia = ''*/ then 
		let vssecuencia = '';
	else
		let vssecuencia = substr (psecuenciaextendida, -6);
	end if;

	if parchivo_origen in 
		(
			/*
			28/07/2023       
			El sequential scan que se tiene en la consulta APLICA, ya que la tabla bditransfer.tf_param_transfer solo contiene 114 REGISTROS, tal que funge como un catálogo.
			*/
			select valor 
			from bditransfer:"informix".tf_param_transfer 
			where codigo between 110 and 120 
		)  and ptipo_conciliacion <> 8 
	then 
		
		set isolation to dirty read;
		
		/*
		20/07/2023 Al restructurar la consulta que va a bdicheq:sc_movhis, para emplear el indice idx_movhisnew7(empresa, folio_suc) 
		y idx_movhisnew3(transacc), se observa un aumento en el costo y registros obtenidos, por lo que la consulta actual es la 
		mas optimima y no se requiere modificar el SP. Es importante indicar que el tiempo de ejecución entre una version u otra en tiempo sucede en menos de 1 segundo.
		
		Costo actual 
		Estimated Cost: 12272
        Estimated # of Rows Returned: 2225
		*/
		
		select limit 1 referencia_23 
		into vssecuencia  
		from Bdicheq:"informix".sc_movhis
		where folio_suc = 'i'||psecuenciaextendida
		and transacc in ('0801','0881');
		
		/*
		Costo con cambio
		Estimated Cost: 12865
        Estimated # of Rows Returned: 15541
	 
		select referencia_23, transacc
		from bdicheq:"informix".sc_movhis
		where empresa = '001'
		and folio_suc = 'i'||psecuenciaextendida
		into temp tempReferencia with no log;
		
		if (select count(*) from tempReferencia) > 0 then
			select limit 1 referencia_23 
			into vssecuencia
			from tempReferencia
			where transacc in ('0801','0881');
		else
			let vssecuencia = '';
		end if;
		*/
		
	end if;

	if pdivisa325 is null or pdivisa325 = '' then
		let vsdivisa = '484';
	else
		let vsdivisa = pdivisa325;
	end if;

	if prfc325 is null or prfc325 = '' then
		let vsrfc = '';
	else
		let vsrfc = prfc325;
	end if;

	insert into bditransfer:"informix".tf_incapture 
	( 
		consecutivo,
		nombrearchivo,
		archivo_origen,
		cuenta,
		tipocnc, 
		notransaccion,
		tipotransaccion,
		secuencia, 
		secuenciaextendida,
		monto,
		id_negocio,
		fecha_alta,
		inf_comercio,
		referencia_23,
		moneda_txn,
		rfc
	)
	values 
	( 
		0,
		pnombrearchivo, 
		parchivo_origen,
		pnumtarjeta,
		ptipo_conciliacion,
		ptransacc,
		ptipotransaccion325,
		vsSecuencia,
		psecuenciaextendida,
		pmonto325, 
		pidcomercio,
		pfechaopetransfer,
		substr(pnomcomercio325,1,26),
		preferencia23_325, 
		vsdivisa,
		vsrfc 
	);

	if dbinfo('sqlca.sqlerrd2') > 0  then
			let p_cod_ret = '00000';
	else
			let p_cod_ret = '99999';
	end if;

	return p_cod_ret, p_mensaje;

end

end procedure
DOCUMENT
'Creación: Ricardo Reséndiz Martínez',
'Proyecto: Integracion de Transfer',
'Solicito: Jose Luis Puebla ',
'Descripcion: Se creo el insert la tabla tf_incapture para optimizar codigo',
'Fecha: 2014/09/01',
'Version: 20140901.1330',
'BD: bditransfer',
'',
'Modificacion: Maria Fernanda Ortiz Figueroa',
'Proyecto: Optimizacion SP Conciliacion Automatica',
'Solicito: Produccion y BD',
'Descripcion: Anexo de comentarios para justificar observaciones de BD',
'Fecha: 2023/07/20',
'BD: bditransfer';


grant  execute on function "informix".consnombrenumcte_transfer (char,char,char,char,char,date,char,smallint) to "agnt70ct" as "informix";
grant  execute on function "informix".consnombrenumcte_transfer (char,char,char,char,char,date,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_ctetf (char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_actualiza_ctetf (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_reversatarjeta_tf (char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_actualiza_reversatarjeta_tf (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_errordes_tf (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_errordes_tf (char,integer) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_consctatransfer (char,smallint) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_consctatransfer (char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_error_trama_tf (smallint,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_error_trama_tf (smallint,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_obtiene_datos_trama_tf (smallint) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_obtiene_datos_trama_tf (smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtieneparametro_tf (char,integer) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_obtieneparametro_tf (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_registra_ctafondeo_tf (char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_reversatarjeta_tf (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reversatarjeta_tf (char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_tf_obtiene_paramtrama (smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_tf_obtiene_paramtrama (smallint) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_tf_obtienevalorws (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_tf_obtienevalorws (char,char,integer) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_tf_registraerror (smallint,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tf_registraerror (smallint,integer,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_valida_cta_transfer (char,char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_cta_transfer (char,char,char,integer,integer) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_canc_abono (char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_canc_abono (char,char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_cancelacion_cargo (char,char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_cancelacion_cargo (char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_udi (char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_consulta_udi (char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cpago (char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cpago (char,char,char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_dm_notdep (char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dm_notdep (char,char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_dm_renapo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dm_renapo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_tipo_cambio (char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tipo_cambio (char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_transfer_conadmin_capture (integer,char,char,char,money,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_conadmin_capture (integer,char,char,char,money,char,char,char,char,char,char) to "systrans" as "informix";
grant  execute on function "informix".sp_transfer_conadmin_capture (integer,char,char,char,money,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_transfer_esnumerico (char) to "systrans" as "informix";
grant  execute on function "informix".sp_transfer_esnumerico (char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_transfer_esnumerico (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_guardabitacora (integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_guardabitacora (integer,char,char) to "systrans" as "informix";
grant  execute on function "informix".sp_transfer_guardabitacora (integer,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_consulta_detalle_compensacion (integer,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_detalle_compensacion (integer,char,date) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_consulta_detalle_compensacion (integer,char,date) to "systrans" as "informix";
grant  execute on function "informix".sp_consulta_resumen_compensacion (integer,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_resumen_compensacion (integer,date) to "systrans" as "informix";
grant  execute on function "informix".sp_consulta_resumen_compensacion (integer,date) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_consulta_archivos_transfer (integer,date,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_archivos_transfer (integer,date,date,char) to "systrans" as "informix";
grant  execute on function "informix".sp_consulta_archivos_transfer (integer,date,date,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_transfer_conadmin_sva (char,date,char,char,char,char,char,char,char,char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_conadmin_sva (char,date,char,char,char,char,char,char,char,char,integer,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_actualizanumctetitular (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizanumctetitular (char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_rep_canctactetf (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rep_canctactetf (char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_guardaultimosdotf (char,char,char,money) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_guardaultimosdotf (char,char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_identificarctetfbco (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_identificarctetfbco (char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_buscardetallectatf (char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_buscardetallectatf (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_codret (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_codret (char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_actualizadatos_ctetf (char,char,char,char,char,smallint,smallint,char,char,char,char,char,char,char,char,char,char,char,char,integer,smallint,char,char,char,char,char,char,smallint,integer,integer,date,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_actualizadatos_ctetf (char,char,char,char,char,smallint,smallint,char,char,char,char,char,char,char,char,char,char,char,char,integer,smallint,char,char,char,char,char,char,smallint,integer,integer,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ctes_modif (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_ctes_modif (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_guarda_renapo_curp (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guarda_renapo_curp (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_validacion_cta (char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validacion_cta (char,char,char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_guarda_renapo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guarda_renapo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
grant  execute on function "informix".sp_online_hist () to "c90306542" as "informix";
grant  execute on function "informix".sp_online_hist () to "agnt70ct" as "informix";
grant  execute on function "informix".sp_transfer_bono_alta (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_obtenernombresarchivos (varchar,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_ctafondeo_tf (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtiene_productos_tf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cargo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_renapo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_producto_tf (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_cte_transfer (char,char,char,char,char,char,date,integer,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_nombre_tf (char,char,char,char,char,date,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_consultacte (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_ctetf (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_registra_transadmin (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_guardabitacora_pba (integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_renapo_curp (char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancelactatf (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dskrga_arch_transfer () to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_obtenerregistrottemporal (varchar,varchar,integer,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_pgservicios_transfer () to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_cargaarchivos (varchar,varchar,varchar,integer,varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_integracion (varchar,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_cst_cancela_cta_tf () to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_ins_tfsvaincomming (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_genarch_svaincomming (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_genarch_incapture (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_generaredoctaeje_factelect_transfer_fechaemision (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_mconadmin_success2_totales (date,date,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_msuccess2 (date,date,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_msuccess2_totales (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_msuccess (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_transacciones (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciliacion_trf () to "c90306542" as "informix";
grant  execute on function "informix".sp_conciliacion_baja () to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_valida_cta (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_campana_cta_efec_dig () to "c90306542" as "informix";
grant  execute on function "informix".sp_archivo_opm () to "c90306542" as "informix";
grant  execute on function "informix".sp_ctes_alta (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_bancos () to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_msettlement2 (date,date,char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_msettlement2_totales (date,date,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_generaarch_transfer (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_sms () to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_mconadmin_success (date,date,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_mconadmin_success2 (date,date,char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizanumctetitular_web (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancela_cte_transfer (char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_spei (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,decimal,decimal,decimal,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_genera_bd_transfer () to "c90306542" as "informix";
grant  execute on function "informix".sp_abono_cta (char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_cte_transfer_web (char,char,char,char,char,char,date,integer,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_generaredoctaeje_factelect_transfer_esp (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_generaredoctaeje_factelect_transfer (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_obtenerregistroarchivo (varchar,varchar,integer,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_validaintegridad (char,char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_registro (char,char,char,char,char,char,char,char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_ctes_tf (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_conadmin_success (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancelactatf_batch () to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_ctafondeo_tf_web (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscardetallectatf_web (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancelactatf_web (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_nombre_tf_web (char,char,char,char,char,date,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_error_trama_tf_web (smallint,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guardaultimosdotf_web (char,char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtiene_datos_trama_tf_web (smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtiene_productos_tf_web (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtieneparametro_tf_web (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_registra_ctafondeo_tf_web (char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_rep_canctactetf_web (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tf_obtiene_paramtrama_web (smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_tf_obtienevalorws_web (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_tf_registraerror_web (smallint,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_trans_consultacte_web (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_in_tfincapture (char,char,char,integer,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_transfer_in_tfincapture (char,char,char,integer,char,char,char,char,char,char,char,char,char,char) to "agnt70ct" as "informix";
revoke  execute on function "informix".consnombrenumcte_transfer (char,char,char,char,char,date,char,smallint) from public as "informix";
revoke  execute on function "informix".sp_actualiza_ctetf (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_actualiza_reversatarjeta_tf (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cons_errordes_tf (char,integer) from public as "informix";
revoke  execute on function "informix".sp_consctatransfer (char,smallint) from public as "informix";
revoke  execute on function "informix".sp_error_trama_tf (smallint,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_obtiene_datos_trama_tf (smallint) from public as "informix";
revoke  execute on function "informix".sp_obtieneparametro_tf (char,integer) from public as "informix";
revoke  execute on function "informix".sp_registra_ctafondeo_tf (char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_reversatarjeta_tf (char,char) from public as "informix";
revoke  execute on function "informix".sp_tf_obtiene_paramtrama (smallint) from public as "informix";
revoke  execute on function "informix".sp_tf_obtienevalorws (char,char,integer) from public as "informix";
revoke  execute on function "informix".sp_tf_registraerror (smallint,integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_valida_cta_transfer (char,char,char,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_canc_abono (char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cancelacion_cargo (char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_consulta_udi (char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cpago (char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_dm_notdep (char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_dm_renapo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_tipo_cambio (char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_conadmin_capture (integer,char,char,char,money,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_esnumerico (char) from public as "informix";
revoke  execute on function "informix".sp_transfer_guardabitacora (integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_consulta_detalle_compensacion (integer,char,date) from public as "informix";
revoke  execute on function "informix".sp_consulta_resumen_compensacion (integer,date) from public as "informix";
revoke  execute on function "informix".sp_consulta_archivos_transfer (integer,date,date,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_conadmin_sva (char,date,char,char,char,char,char,char,char,char,integer,char) from public as "informix";
revoke  execute on function "informix".sp_actualizanumctetitular (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_rep_canctactetf (char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_guardaultimosdotf (char,char,char,money) from public as "informix";
revoke  execute on function "informix".sp_identificarctetfbco (char,char) from public as "informix";
revoke  execute on function "informix".sp_buscardetallectatf (char,char) from public as "informix";
revoke  execute on function "informix".sp_consulta_codret (char) from public as "informix";
revoke  execute on function "informix".sp_actualizadatos_ctetf (char,char,char,char,char,smallint,smallint,char,char,char,char,char,char,char,char,char,char,char,char,integer,smallint,char,char,char,char,char,char,smallint,integer,integer,date,char) from public as "informix";
revoke  execute on function "informix".sp_ctes_modif (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) from public as "informix";
revoke  execute on function "informix".sp_guarda_renapo_curp (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_validacion_cta (char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_guarda_renapo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_online_hist () from public as "informix";
revoke  execute on function "informix".sp_transfer_bono_alta (char) from public as "informix";
revoke  execute on function "informix".sp_transfer_obtenernombresarchivos (varchar,date) from public as "informix";
revoke  execute on function "informix".sp_busca_ctafondeo_tf (char,char) from public as "informix";
revoke  execute on function "informix".sp_obtiene_productos_tf (char) from public as "informix";
revoke  execute on function "informix".sp_cargo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_renapo (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_valida_producto_tf (char,char) from public as "informix";
revoke  execute on function "informix".sp_cons_cte_transfer (char,char,char,char,char,char,date,integer,integer,char) from public as "informix";
revoke  execute on function "informix".sp_consulta_nombre_tf (char,char,char,char,char,date,smallint) from public as "informix";
revoke  execute on function "informix".sp_trans_consultacte (char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_consulta_ctetf (char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_registra_transadmin (char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_registra_ctafondeo_tf (char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_guardabitacora_pba (integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_renapo_curp (char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cancelactatf (char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_dskrga_arch_transfer () from public as "informix";
revoke  execute on function "informix".sp_transfer_obtenerregistrottemporal (varchar,varchar,integer,varchar) from public as "informix";
revoke  execute on function "informix".sp_pgservicios_transfer () from public as "informix";
revoke  execute on function "informix".sp_transfer_cargaarchivos (varchar,varchar,varchar,integer,varchar,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_integracion (varchar,integer) from public as "informix";
revoke  execute on function "informix".sp_cst_cancela_cta_tf () from public as "informix";
revoke  execute on function "informix".sp_transfer_ins_tfsvaincomming (date) from public as "informix";
revoke  execute on function "informix".sp_transfer_genarch_svaincomming (date) from public as "informix";
revoke  execute on function "informix".sp_transfer_genarch_incapture (date) from public as "informix";
revoke  execute on function "informix".sp_generaredoctaeje_factelect_transfer_fechaemision (char,date) from public as "informix";
revoke  execute on function "informix".sp_transfer_mconadmin_success2_totales (date,date,char,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_msuccess2 (date,date,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_transfer_msuccess2_totales (date,date) from public as "informix";
revoke  execute on function "informix".sp_transfer_msuccess (date,date) from public as "informix";
revoke  execute on function "informix".sp_transfer_transacciones (integer) from public as "informix";
revoke  execute on function "informix".sp_conciliacion_trf () from public as "informix";
revoke  execute on function "informix".sp_conciliacion_baja () from public as "informix";
revoke  execute on function "informix".sp_transfer_valida_cta (char,char) from public as "informix";
revoke  execute on function "informix".sp_campana_cta_efec_dig () from public as "informix";
revoke  execute on function "informix".sp_archivo_opm () from public as "informix";
revoke  execute on function "informix".sp_ctes_alta (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) from public as "informix";
revoke  execute on function "informix".sp_transfer_bancos () from public as "informix";
revoke  execute on function "informix".sp_transfer_msettlement2 (date,date,char,char,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_transfer_msettlement2_totales (date,date,char,char) from public as "informix";
revoke  execute on function "informix".sp_generaarch_transfer (char) from public as "informix";
revoke  execute on function "informix".sp_transfer_sms () from public as "informix";
revoke  execute on function "informix".sp_transfer_mconadmin_success (date,date,char,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_mconadmin_success2 (date,date,char,char,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_actualizanumctetitular_web (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cancela_cte_transfer (char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_spei (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,decimal,decimal,decimal,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_genera_bd_transfer () from public as "informix";
revoke  execute on function "informix".sp_abono_cta (char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cons_cte_transfer_web (char,char,char,char,char,char,date,integer,integer,char) from public as "informix";
revoke  execute on function "informix".sp_generaredoctaeje_factelect_transfer_esp (char) from public as "informix";
revoke  execute on function "informix".sp_generaredoctaeje_factelect_transfer (char) from public as "informix";
revoke  execute on function "informix".sp_transfer_obtenerregistroarchivo (varchar,varchar,integer,varchar) from public as "informix";
revoke  execute on function "informix".sp_transfer_validaintegridad (char,char,integer,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_registro (char,char,char,char,char,char,char,char,char,money) from public as "informix";
revoke  execute on function "informix".sp_ctes_tf (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_conadmin_success (date) from public as "informix";
revoke  execute on function "informix".sp_cancelactatf_batch () from public as "informix";
revoke  execute on function "informix".sp_busca_ctafondeo_tf_web (char,char) from public as "informix";
revoke  execute on function "informix".sp_buscardetallectatf_web (char,char) from public as "informix";
revoke  execute on function "informix".sp_cancelactatf_web (char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_consulta_nombre_tf_web (char,char,char,char,char,date,smallint) from public as "informix";
revoke  execute on function "informix".sp_error_trama_tf_web (smallint,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_guardaultimosdotf_web (char,char,char,money) from public as "informix";
revoke  execute on function "informix".sp_obtiene_datos_trama_tf_web (smallint) from public as "informix";
revoke  execute on function "informix".sp_obtiene_productos_tf_web (char) from public as "informix";
revoke  execute on function "informix".sp_obtieneparametro_tf_web (char,integer) from public as "informix";
revoke  execute on function "informix".sp_registra_ctafondeo_tf_web (char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_rep_canctactetf_web (char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_tf_obtiene_paramtrama_web (smallint) from public as "informix";
revoke  execute on function "informix".sp_tf_obtienevalorws_web (char,char,integer) from public as "informix";
revoke  execute on function "informix".sp_tf_registraerror_web (smallint,integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_trans_consultacte_web (char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_transfer_in_tfincapture (char,char,char,integer,char,char,char,char,char,char,char,char,char,char) from public as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to ifxcons ;

grant usage on language SPL to ifxdesaa ;

grant usage on language SPL to ifxprod ;

grant usage on language SPL to ifxconsacc ;

grant usage on language SPL to ifxsopsuc ;


create index "informix".idx_accbalancecust_cta on "informix".tf_account_balance_customer 
    (cuenta) using btree  in datos01;
create index "informix".idx_account_balance_customer on "informix"
    .tf_account_balance_customer (fecha_proceso,cuenta) using 
    btree  in dbs_idxinteg;
create index "informix".idx_balancecustomer on "informix".tf_account_balance_customer 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_alltransaction on "informix".tf_all_transaction 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_assignnip on "informix".tf_assign_nip 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_cta_consec on "informix".tf_assign_nip 
    (consecutivo,cuenta) using btree  in datos01;
create index "informix".idx_associationcard on "informix".tf_association_card 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_cancelationcard on "informix".tf_cancelation_card 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_comisiontransac on "informix".tf_comision_transac 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_controledocta on "informix".tf_control_edocta 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_detalleedocta on "informix".tf_detalle_edocta 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_tf_incapture on "informix".tf_incapture 
    (cuenta,status_envio,status_cnc) using btree  in dbs_cierrechqidxanexo;
    
create index "informix".idx_outcapture on "informix".tf_outcapture 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_paramtransfer on "informix".tf_param_transfer 
    (codigo,descripcion,valor) using btree  in dbs_cierrechqidxanexo;
    
create index "informix".idx_resumenedocta on "informix".tf_resumen_edocta 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_tf_resumen_edocta on "informix".tf_resumen_edocta 
    (periodo_fin) using btree  in datos01;
create index "informix".idx_retirecustomer on "informix".tf_retire_customer 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_settlement on "informix".tf_settlement 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_successtransac on "informix".tf_success_transac 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_tf_success_transac2 on "informix".tf_success_transac 
    (fecha_alt,cuenta) using btree  in dbs_cierrechqidxanexo;
    
create index "informix".inx_conadmin_sva on "informix".tf_sva_incoming 
    (tpo_id,cuenta,status_envio,status_cnc) using btree  in dbs_cierrechqidxanexo;
    
create index "informix".idx_svatransaction on "informix".tf_sva_transaction 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_topup on "informix".tf_top_up (nombrearchivo,
    archivo_origen,integridad) using btree  in dbs_cierrechqidxanexo;
    
create index "informix".idx_unresolvedtransac on "informix".tf_unresolved_transac 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_cta_fecha_tf_user on "informix".tf_user_transfer 
    (numcte,fecha_corte) using btree  in datos01;
create index "informix".idx_usertransfer on "informix".tf_user_transfer 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_ctetf on "informix".tf_maecte (numcte_tf) 
    using btree  in datos01;
create index "informix".idx_maecte on "informix".tf_maecte (telefono,
    empresa) using btree  in dbs_cierrechqidxanexo;
create index "informix".idx_maecte_cta_2 on "informix".tf_maecte 
    (num_tarjeta,empresa) using btree  in dbs_cierrechqidxanexo;
    
create index "informix".idx_maecte_ctastat on "informix".tf_maecte 
    (cuenta_tf,status_cta) using btree  in datos00;
create index "informix".idx_maecte_telstat on "informix".tf_maecte 
    (telefono,status_cta) using btree  in datos00;
create index "informix".idx_status_cta on "informix".tf_maecte 
    (status_cta) using btree  in datos01;
create index "informix".idx_tf_maecte on "informix".tf_maecte 
    (num_tarjeta) using btree  in dbs_cierrechqidxanexo;
create index "informix".idx_tf_maecte_2 on "informix".tf_maecte 
    (cuenta_tf,empresa) using btree  in dbssi_cterelaciona;
create index "informix".idx_tf_maecte_3 on "informix".tf_maecte 
    (numcte) using btree  in dbssi_cterelaciona;
create index "informix".idx_tf_maecte_4 on "informix".tf_maecte 
    (apell_paterno,nombre1,nombre2) using btree  in dbssi_cterelaciona;
    
create index "informix".idx_tf_maecte_5 on "informix".tf_maecte 
    (rfc) using btree  in dbssi_cterelaciona;
create index "informix".idx_bconcilia on "informix".tf_concilia_difer 
    (fecha_insert,nombrearchivo) using btree  in datos01;
create index "informix".tf_error on "informix".tf_error (cuenta_transfer,
    fecha_insert) using btree  in datos01;
create index "informix".idx_bonos_transfer_cta on "informix".tf_bonos_transfer 
    (cuenta_tf) using btree  in datos01;
create index "informix".idx_archtrxstrf on "informix".tf_arch_trxs 
    (numcte,cuenta) using btree  in datos01;
create index "informix".idx_archusertrf on "informix".tf_arch_user 
    (numcte,cuenta) using btree  in datos01;
create index "informix".idx_tf_administrative_transac on "informix"
    .tf_administrative_transac (nombrearchivo) using btree  in 
    dbs_cierrechqidxanexo;
create index "informix".idx_bitacoratransadmin on "informix".tf_bitacora_transadmin 
    (numcte_tf,fecha_insert) using btree  in datos01;
create index "informix".tf_conciltrans_idx1 on "informix".tf_conciliacionadmiva_transfer 
    (conciliado) using btree  in dbs_movhis_idx4;
create index "informix".idx_tf_settlement_bank on "informix".tf_settlement_bank 
    (nombrearchivo,archivo_origen,integridad) using btree  in 
    datos01;
create index "informix".idx_secuen_linea_cta on "informix".mnsj_susc_paso 
    (secuencial,linea) using btree  in datos01;
create index "informix".idx_cta_fech_proceso_tmp on "informix"
    .tf_account_balance_customer_tmp (cuenta,fecha_proceso) using 
    btree  in datos01;
create index "informix".idx_cta_consecutivo_tmp on "informix".tf_assign_nip_tmp 
    (cuenta,consecutivo) using btree  in datos01;
create index "informix".idx_cta_fecha_user_tmp on "informix".tf_user_transfer_tmp 
    (numcte,fecha_corte) using btree  in datos01;
create index "informix".idx_clave_rpt on "informix".tf_entidadfed_rpt 
    (clave) using btree  in datos01;
create index "informix".idxtmp_ctasxprocesar_cuenta_tr on "informix"
    .ctasxprocesar_tranf (cuenta) using btree  in datos01;
create index "informix".cancelacionctetf on "informix".tf_cancelacioncte_batch 
    (cuenta_tf,telefono) using btree  in dbs_movhis_idx5;