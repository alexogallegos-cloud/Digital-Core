create procedure "informix".sp_transfer_validaintegridad ( 
					psnomarchivo			char (50),	-- Nombre del archivo 
					psarchivoorigen 		char(3), 	-- Abreviatura del nombre del archivo
					pitipolayout 			integer, 	-- Identificador del tipo layout
					pscve_usuario 			char(10)  	-- Clave del Usuario
					)   				
returning 	
				varchar (5) as codret,
				varchar(250) as mensaje_respuesta;
--variables para OutCapture y OutSVA		
define vmonto money;
define vmonto_sva char (18);
define vfecha_alta char(6);
define vcod_error char(6);
define vmsn_error char(150);
define vsnomarchivoout char(30);
define vsstatus_cnc char(1);
define vstipo_cuenta char(1);	
define vscomentario char(150);
define vdfecha_recibido date;	
define visqlerr integer ;
define vscodret varchar(5);
define vsmensaje_respuesta varchar(250);
-- Controlador de fases
define 	vielemento 			integer;
-- Controlador de ciclos
define vsflagentransaccion varchar (1);
define vicontadorregistros integer;
-- Para validaciones de tablas
define viconsecutivo integer;
define vscuenta char(20);
define vstelefono char(10);
define vsnumtarjeta char(16);
define vsintegridad char(1);
define vsactividad  char(250);
define vstransacc char(4);
define vssecuencia char(8);
define vsid_banco_origen char(3);
define vsid_cuenta_origen char(18);
define vsid_banco_destino char(3);
define vsid_cuenta_destino  char (18);
define vsreferencia char(23);
define vsid_transac char(15);
define vsnumcte  char(12);
define vsno_clave char(18);
define vscta_fondeo char(12);
define vscod_postal char(6);
define vstpo_cta char(2);
define vsidcadena char(10);
define vsretailer char(5);
define vsidterminal char(10);
define vsno_txn_telcel char(6);
define vsid_asociacion char(4);
define vsid_cancelacion char(4);
define vsid_banco char(7);
define vsid_negocio char(9);
define vsreferencia_23 char(23);
define vsclabe char(18);
define vsno_txn_mps char(20);
define vinumregistros integer;
define vinum_cuentas integer;
define vmmonto money;
define vdfech_hor_ini  datetime year to fraction (5);
define vdfech_alt	date;
define vssecuenciatransfer char(15);
define vstransaccion char(4);
define vstpo_id_origen char(2);
define vstpo_id_destino char(2);
define vsid_transacc_mps char(20);
define vmetodo_acceso char(3); 
define vflag_ajuste char(1);
define vsmotivo_cancelacion    char(3);define vsid_txn_transfertobank char(20);define vsescuenta, vsestelefono, vsesnumtarjeta, vsestransacc, vsessecuencia, vsesid_banco_origen, vsesid_cuenta_origen, vsesid_banco_destino, vsesid_cuenta_destino char(1);
define vsesreferencia, vsesid_transac, vsesnumcte, vsesno_clave, vsescta_fondeo, vsescod_postal, vsestpo_cta, vsesidcadena, vsesretailer, vsesidterminal char(1);
define vsesno_txn_telcel, vsesid_asociacion, vsesid_cancelacion, vsesid_banco, vsesid_negocio, vsesreferencia_23, vsesclabe, vsesno_txn_mps, vsesnumregistros, vsesnum_cuentas,vsesmotivo_can,vses_id_txn_tobank char(1); 
define vdfecha_alt  date;
begin
	on exception set visqlerr
		let vscodret = '00001';
		let vsmensaje_respuesta = 'Error general de validacion de integridad';
		return 	vsCodRet,
				('[' || vscodret ||  '] Error no controlado ' || visqlerr || '. archivo ' || psnomarchivo ||  ' ' || trim(vsmensaje_respuesta) );
	end exception;	
--set debug file to "/informix/HomeInformix/rrm/sp_transfer_validaintegridad.out";
--trace on;
let visqlerr  = 0;
let vscodret  = '00000';
let vsmensaje_respuesta = 'Iniciando proceso de validacion en diversas tablas';
-- Controlador de fases
let vielemento = 0;
-- Controlador de ciclos
let vsflagentransaccion  = 'F';
let vicontadorregistros  = 0;
-- Para validaciones de tablas
let viconsecutivo = 0;
let vscuenta = '';
let vstelefono = '';
let vsnumtarjeta  = '';
let vsintegridad = '';
let vsactividad = '';
let vielemento = 0;
let vstransacc  = '';
let vssecuencia = '';
let vsid_banco_origen = '';
let vsid_cuenta_origen = '';
let vsid_banco_destino = '';
let vsid_cuenta_destino = '';
let vsreferencia = '';
let vsid_transac = '';
let vsnumcte = '';
let vsno_clave = '';
let vscta_fondeo = '';
let vscod_postal = '';
let vstpo_cta = '';
let vsidcadena = '';
let vsretailer = '';
let vsidterminal = '';
let vsno_txn_telcel = '';
let vsid_asociacion = '';
let vsid_cancelacion = '';
let vsid_banco = '';
let vsid_negocio = '';
let vsreferencia_23 = '';
let vsclabe = '';
let vsno_txn_mps = '';
let vinumregistros = 0;
let vinum_cuentas = 0;
let vmmonto = 0.0;
let vdfech_hor_ini = current;
let vdfech_alt	= '';
let vssecuenciatransfer = '';
let vstransaccion = '';
let vstpo_id_origen = '';
let vstpo_id_destino = '';
let vsid_transacc_mps = '';  
let vmetodo_acceso = '';
let vflag_ajuste = 'F';
let vsmotivo_cancelacion = '';    --- NEW 
let vsid_txn_transfertobank = ''; --- NEW 
-- Para resultados de validaciones
let vsescuenta = '';
let vsestelefono = '';
let vsesnumtarjeta = '';
let vsestransacc  = '';
let vsessecuencia = '';
let vsesid_banco_origen = '';
let vsesid_cuenta_origen = '';
let vsesid_banco_destino = '';
let vsesid_cuenta_destino = '';
let vsesreferencia = '';
let vsesid_transac = '';
let vsesnumcte = '';
let vsesno_clave = '';
let vsescta_fondeo = '';
let vsescod_postal = '';
let vsestpo_cta = '';
let vsesidcadena = '';
let vsesretailer = '';
let vsesidterminal = '';
let vsesno_txn_telcel = '';
let vsesid_asociacion = '';
let vsesid_cancelacion = '';
let vsesid_banco = '';
let vsesid_negocio = '';
let vsesreferencia_23 = '';
let vsesclabe = '';
let vsesno_txn_mps = '';
let vsesnumregistros = '';
let vsesnum_cuentas = '';
let vsflagentransaccion = 'F';
let vmonto = 0.0;
let vmonto_sva = '';
let vfecha_alta = '';
let vcod_error = '000000';
let vmsn_error = '';
let vsnomarchivoout = '';
let vstipo_cuenta='';
let vscomentario='';
let vdfecha_recibido = today;
let vdfecha_alt = today;
let vsesmotivo_can      = ''; --new
let vses_id_txn_tobank  = ''; --new
set isolation to dirty read;
if (pitipolayout = 1) then 
	foreach cusor1 with hold for
		select 	consecutivo, cuenta, telefono, numtarjeta, integridad into viconsecutivo, vscuenta, vstelefono, vsnumtarjeta, vsintegridad
		from bditransfer:"informix".tf_account_balance_customer where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstelefono) into vsestelefono;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsnumtarjeta) into vsesnumtarjeta;
		if ((vsescuenta != 'V' ) or (vsestelefono != 'V')  or (vsesnumtarjeta != 'V')) then
			let vsIntegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_account_balance_customer presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			LET vsIntegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_account_balance_customer
			set integridad = vsIntegridad
		where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and  integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';	--termina el bloque de registros por transaccion
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 2) then 
	foreach cusor1 with hold for
		select 	consecutivo, cuenta, transacc, secuencia, id_banco_origen, id_cuenta_origen, id_banco_destino, id_cuenta_destino,
				referencia,  id_transac, integridad
		into 	viconsecutivo, vscuenta, vstransacc, vssecuencia, vsid_banco_origen, vsid_cuenta_origen, vsid_banco_destino, vsid_cuenta_destino,
				vsreferencia, vsid_transac, vsintegridad
		from Bditransfer:"informix".tf_all_transaction	where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstransacc) into vsestransacc;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vssecuencia) into vsessecuencia;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_banco_origen) into vsesid_banco_origen;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_origen) into vsesid_cuenta_origen;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_banco_destino) into vsesid_banco_destino;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_destino) into vsesid_cuenta_destino;
		--execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsreferencia) into vsesreferencia;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_transac) into vsesid_transac;
		if ((vsescuenta != 'V' ) or (vsestransacc != 'V')  or (vsessecuencia != 'V') or (vsesid_banco_origen != 'V')  or (vsesid_cuenta_origen != 'V')or (vsesid_banco_destino != 'V')  or (vsesid_cuenta_destino != 'V')or /*(vsesreferencia != 'V')  or */(vsesid_transac != 'V')) then
			let vsIntegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_all_transaction presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			LET vsIntegridad = 'V';
			let vscodret = '00000';
		end if;
		update Bditransfer:"informix".tf_all_transaction
			set integridad = vsIntegridad
		where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and  integridad = 'P' and consecutivo = viconsecutivo ;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';	--termina el bloque de registros por transaccion
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 10) then 
	foreach cusor1 with hold for
		select 	consecutivo, cuenta, numcte, telefono, no_clave, numtarjeta, cta_fondeo, cod_postal
			into viconsecutivo, vscuenta, vsnumcte, vstelefono, vsno_clave, vsnumtarjeta, vscta_fondeo, vscod_postal
		from Bditransfer:"informix".tf_user_transfer where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if; -- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstelefono) into vsestelefono;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscod_postal) into vsescod_postal;
		if ((vsescuenta != 'V' ) or  (vsestelefono != 'V') ) then
			LET vsIntegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_user_transfer presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			LET vsIntegridad = 'V';
			let vscodret = '00000';
		end if;
		update Bditransfer:"informix".tf_user_transfer
			set integridad = vsIntegridad
		where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';	--termina el bloque de registros por transaccion
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion'; -- termina el ultimo bloque de transaccion pendiente.
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 12) then
	foreach cusor1 with hold for
		select consecutivo, cuenta, telefono, numcte
			into viconsecutivo, vscuenta, vstelefono, vsnumcte
		from bditransfer:"informix".tf_assign_nip
			where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsnumcte) into vsesnumcte;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstelefono) into vsestelefono;
		if ((vsescuenta != 'V' ) or (vsesnumcte != 'V')  or (vsestelefono != 'V')) then
			LET vsIntegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_assign_nip presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			LET vsIntegridad = 'V';
			let vscodret = '00000';
		end if;
		update Bditransfer:"informix".tf_assign_nip
			set integridad = vsIntegridad
		where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen  and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion'; -- termina el ultimo bloque de transaccion pendiente.
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 4) then
	foreach cusor1 with hold for
		select consecutivo, tpo_cta	into viconsecutivo, vstpo_cta 
		from Bditransfer:"informix".tf_comision_transac	where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;		-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstpo_cta) into vsestpo_cta;
		if (vsestpo_cta != 'V') then 
			let vsIntegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_comision_transac presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsIntegridad = 'V';
			let vscodret = '00000';
		end if;
		update Bditransfer:"informix".tf_comision_transac
			set integridad = vsIntegridad
		where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion'; -- termina el ultimo bloque de transaccion pendiente.
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 11) then
	foreach cusor1 with hold for
		select consecutivo,   cuenta,   telefono,   numtarjeta,            motivo_cancelacion,   id_txn_transfertobank
		into   viconsecutivo, vscuenta, vstelefono, vsnumtarjeta , /*new*/ vsmotivo_cancelacion, vsid_txn_transfertobank
		from Bditransfer:"informix".tf_retire_customer 	where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsnumtarjeta) into vsesnumtarjeta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstelefono) into vsestelefono;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsmotivo_cancelacion)    into  vsesmotivo_can;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_txn_transfertobank) into  vses_id_txn_tobank; 
		if ((vsescuenta != 'V' ) or (vsesnumtarjeta != 'V')  or (vsestelefono != 'V') or (vsesmotivo_can != 'V') or  (vses_id_txn_tobank != 'V'))  then
			LET vsIntegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_retire_customer presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			LET vsIntegridad = 'V';
			let vscodret = '00000';
		end if;
		update Bditransfer:"informix".tf_retire_customer
			set integridad = vsIntegridad
		where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';	--termina el bloque de registros por transaccion
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 5) then
	foreach cusor1 with hold for		
		select consecutivo, cuenta, transacc, secuencia, id_banco_origen, id_cuenta_origen, id_banco_destino, trim(id_cuenta_destino), referencia, fecha_alt, fech_hor_ini, monto, tpo_id_origen, tpo_id_destino,folio_suc, LTRIM(id_transacc_mps,'0'),metodo_acceso -- new
			into viconsecutivo, vscuenta, vstransacc, vssecuencia, vsid_banco_origen, vsid_cuenta_origen, vsid_banco_destino, vsid_cuenta_destino, vsreferencia, vdfecha_alt, vdfech_hor_ini, vmmonto, vstpo_id_origen, vstpo_id_destino, vssecuenciatransfer,vsid_transacc_mps,vmetodo_acceso -- new
		from Bditransfer:"informix".tf_success_transac	where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstransacc) into vsestransacc;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vssecuencia) into vsessecuencia;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_banco_origen) into vsesid_banco_origen;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_origen) into vsesid_cuenta_origen;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_banco_destino) into vsesid_banco_destino;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_destino) into vsesid_cuenta_destino;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsreferencia) into vsesreferencia;
		if ((vsescuenta != 'V' ) or (vsestransacc != 'V')  or (vsessecuencia != 'V') or (vsesid_banco_origen != 'V')  or (vsesid_cuenta_origen != 'V')or (vsesid_banco_destino != 'V')  or (vsesid_cuenta_destino != 'V')or (vsesreferencia != 'V') ) then
			LET vsIntegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_success_transac presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			LET vsIntegridad = 'V';
			let vscodret = '00000';
		end if;
		update Bditransfer:"informix".tf_success_transac
			set integridad = vsIntegridad
		where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo; 
		-------------------------------------------------------------------------------------
		-- ##########    Proceso para grabar registro en SC_MOVDIA #########################
		if (vstransacc in (	'0005', /* SVA to SVA */	  '0031',  /*SVA TO BANK */     '0004', /*Fondeo BANK TO SVA*/'0034','0085',  /* RECARGA TELCEL*/
		                    '0042', /* Pago comerciante*/ '0014',  /* Ajuste de saldo*/ '0036', /* Devolución */	  '0094', /* AportaciónAFORE */ 
							'0095',  /* PAGO NEXTEL */    '0096', /* PAGO IZZI */	    '0080', /* PAGO CFE */ 	      '0081', /* PAGO GDF */ 	      
							'0082', /* PAGO GEDOMEX */	  '0083', /* PAGO DISH */       '0084', /* RECARGA TAG' */    '0086', /* RECARGA MOVISTAR */
							'0087', /* RECARGA IUSACELL*/ '0088', /* RECARGA UNEFON */  '0089', /* RECARGA NEXTEL */  '0090', /* PAGO TELMEX */  
							'0091', /* PAGO TELCEL */     '0092', /* INFONAVIT   Detenida'0032',  SPEI BANK TO SVA*/  '0103', /* PIN FACEBOOK*/ 
							'0104', /* PAYPAL*/           '0110', /*PLAYSTATION*/       '0111', /* PLAYSTATION PLUS*/ '0112', /*SALAMANCA*/ 
							'0113', /*CELAYA*/            '0114', /*FENOSA*/            '0115', /*QUERETARO*/         '0118', /*GUANAJUATO*/
							'0119', /*JALISCO*/           '0120', /*MICHOACAN*/         '0121', /*TLAZCALA*/          '0122', /*COAHUILA*/ 
							'0123', /*MEGACABLE*/         '0124', /*MAXCOM*/            '0125', /*XBOX*/              '0093', /*CINEPOLIS*/ 
							'0106', /*CINECASH*/          '0107', /*KONIBIT*/           '0108', /*STAR TV*/           '0126',/*PAQUETE SL TELCEL*/
							'0132', /*SEGUROS r. civil*/  '0133', /*PETCO*/             '0134', /*MCPO. QUERETARO*/   '0135', /*MCPO. LEON*/
							'0057'  /*DEV. PAGO SERV. */) and vsIntegridad = 'V') then
            ------------------------------------------------------------------------------------- 
			let vflag_ajuste = 'F';
			
			if  (vstransacc = '0014')  then
			    if vmetodo_acceso <> '010' then 
				   let vflag_ajuste = 'V';  -- Solo admitir ajustes realizados por '010' WEBADMIN  
				end if;    
			end if;
					
			if  (vflag_ajuste) = 'F' then
				-------------------------------------------------------------------------------------						
				-- Para llenado de tabla de conciliacion administrativa									
				insert into bditransfer:"informix".tf_conciliacionadmiva_transfer					
					(consecutivo, nombrearchivo, transacc_file, fecha_alt_file, fech_hor_file, folio_suc_file, monto_file,id_mps_file, tpo_registro)
				values					
					(0, psnomarchivo, vstransacc, vdfecha_alt, vdfech_hor_ini, vssecuenciatransfer, vmmonto,vsid_transacc_mps, 'D' );
				-- Para registro de transaccion contable
				execute procedure Bditransfer:"informix".sp_transfer_registro ( 
																				vssecuenciatransfer, 
																				pscve_usuario,
																				vstransacc, 
																				vsid_banco_origen,
																				vstpo_id_origen, 
																				vsid_cuenta_origen,
																				vsid_banco_destino,
																				vstpo_id_destino,
																				vsid_cuenta_destino, 
																				vmmonto
																				)INTO vscodret;				
				if vscodret = '00000' or vscodret = '000' then
					update Bditransfer:"informix".tf_success_transac
						set aplicacion = 'V'
					where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'V' and consecutivo = viconsecutivo;
				else
					update Bditransfer:"informix".tf_success_transac
						set aplicacion = 'F'
					where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'V' and consecutivo = viconsecutivo;
				end if;
				
			 else  -- new 
			        update Bditransfer:"informix".tf_success_transac
				    set aplicacion = 'I' -- Improcedente 
			        where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'V' and consecutivo = viconsecutivo;
					
			end if;		
				
		else 
			update Bditransfer:"informix".tf_success_transac
						set aplicacion = 'I' -- Improcedente 
			where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'V' and consecutivo = viconsecutivo;
		end if;	
		
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 6) then
	foreach cusor1 with hold for
		select consecutivo, cuenta, transacc, secuencia, id_banco_origen, id_cuenta_origen, id_banco_destino, id_cuenta_destino, referencia
			into viconsecutivo, vscuenta, vstransacc, vssecuencia, vsid_banco_origen, vsid_cuenta_origen, vsid_banco_destino, vsid_cuenta_destino, vsreferencia
		from Bditransfer:"informix".tf_unresolved_transac where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstransacc) into vsestransacc;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vssecuencia) into vsessecuencia;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_banco_origen) into vsesid_banco_origen;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_origen) into vsesid_cuenta_origen;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_banco_destino) into vsesid_banco_destino;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_destino) into vsesid_cuenta_destino;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsreferencia) into vsesreferencia;
		if ((vsescuenta != 'V' ) or (vsestransacc != 'V')  or (vsessecuencia != 'V') or 
			(vsesid_banco_origen != 'V')  or (vsesid_cuenta_origen != 'V')or (vsesid_banco_destino != 'V')  or 
			(vsesid_cuenta_destino != 'V')or (vsesreferencia != 'V')) then
			let vsIntegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_unresolved_transac presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			LET vsIntegridad = 'V';
			let vscodret = '00000';
		end if;
		update Bditransfer:"informix".tf_unresolved_transac
			set integridad = vsIntegridad
		where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion'; -- termina el ultimo bloque de transaccion pendiente.
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 3) then
	foreach cusor1 with hold for
		select consecutivo, secuencia, idcadena, idretailer, idterminal, telefono, no_txn_telcel, monto, fech_alt, fech_hor_ini
			into viconsecutivo, vssecuencia, vsidcadena, vsretailer, vsidterminal, vstelefono, vsno_txn_telcel, vmmonto, vdfech_alt, vdfech_hor_ini
		from bditransfer:"informix".tf_top_up
			where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if; -- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vssecuencia) into vsessecuencia;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstelefono) into vsestelefono;
		if ((vsessecuencia != 'V') or (vsestelefono != 'V')) then 
			let vsIntegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_top_up presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_top_up
			set integridad = vsintegridad
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo;
        --  Se borro proceso de integracion de registro contable ya que este se migro a el success transac
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 7) then
	foreach cusor1 with hold for
		select consecutivo, id_cuenta_origen, id_banco_origen, id_cuenta_destino, id_banco_destino
			into viconsecutivo, vsid_cuenta_origen, vsid_banco_origen, vsid_cuenta_destino, vsid_banco_destino
		from Bditransfer:"informix".tf_settlement where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_banco_origen) into vsesid_banco_origen;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_origen) into vsesid_cuenta_origen;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_banco_destino) into vsesid_banco_destino;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_destino) into vsesid_cuenta_destino;
		if ((vsesid_banco_origen != 'V')  or (vsesid_cuenta_origen != 'V')or (vsesid_banco_destino != 'V')  or (vsesid_cuenta_destino != 'V')) then
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_settlement presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_settlement
			set integridad = vsintegridad
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';	--termina el bloque de registros por transaccion
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 15) then
	foreach cusor1 with hold for
		select consecutivo, id_asociacion, numtarjeta, cuenta	into viconsecutivo, vsid_asociacion, vsnumtarjeta, vscuenta
		from Bditransfer:"informix".tf_association_card	where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_asociacion) into vsesid_asociacion;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsnumtarjeta) into vsesnumtarjeta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		if ((vsesid_asociacion != 'V')  or (vsesnumtarjeta != 'V')or (vsescuenta != 'V')  ) then
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_association_card presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_association_card
			set integridad = vsintegridad
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 16) then
	foreach cusor1 with hold for
		select consecutivo, id_cancelacion, numtarjeta, cuenta
			into viconsecutivo, vsid_cancelacion, vsnumtarjeta, vscuenta
		from Bditransfer:"informix".tf_cancelation_card
			where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cancelacion) into vsesid_cancelacion;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsnumtarjeta) into vsesnumtarjeta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		if ((vsesid_cancelacion != 'V')  or (vsesnumtarjeta != 'V')or (vsescuenta != 'V')  ) then
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_cancelation_card presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_cancelation_card
			set integridad = vsintegridad
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion'; --termina el bloque de registros por transaccion
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 8) then
	foreach cusor1 with hold for
		select consecutivo, id_banco, cuenta, secuencia, id_negocio, referencia_23, monto , fecha_alta,cod_error,msn_error,status_cnc
		into viconsecutivo, vsid_banco, vscuenta, vssecuencia, vsid_negocio, vsreferencia_23,vmonto, vfecha_alta,vcod_error,vmsn_error,vsstatus_cnc
		from Bditransfer:"informix".tf_outcapture
			where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_banco) into vsesid_banco;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vssecuencia) into vsessecuencia;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_negocio) into vsesid_negocio;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsreferencia_23) into vsesreferencia_23;
		if ((vsesid_banco != 'V')  or (vsescuenta != 'V')or (vsessecuencia != 'V') or (vsesid_negocio != 'V')or (vsesreferencia_23 != 'V') ) then
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_outcapture presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		
		execute procedure bditransfer:"informix".sp_transfer_conadmin_capture ( 
		viconsecutivo, psnomarchivo, vscuenta , vssecuencia, vmonto,vfecha_alta, vsintegridad, vcod_error,vmsn_error,
		vsstatus_cnc,pscve_usuario) into vsstatus_cnc;
		
		update bditransfer:"informix".tf_outcapture
			set integridad = vsintegridad, status_cnc=vsstatus_cnc
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'  and consecutivo = viconsecutivo;
				
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	--Se actualiza flag de archivo conadmin
	update bditransfer:"informix".tf_archivos_transfer set conadmin='V' 
	where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 9) then
	foreach cusor1 with hold for
		select consecutivo, cuenta,tpo_id,monto,comentario,cod_error,motivo,status_cnc,fecha_recibido
		into viconsecutivo, vsid_cuenta_origen,vstipo_cuenta,vmonto_sva,vscomentario,vcod_error,vmsn_error,vsstatus_cnc,vdfecha_recibido
		from Bditransfer:"informix".tf_sva_transaction	where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_origen) into vsesid_cuenta_origen;
		if (vsesid_cuenta_origen != 'V') then 
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_sva_transaction presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		--inicia Conadmin
		execute procedure bditransfer:"informix".sp_transfer_conadmin_sva ( 
		psnomarchivo,vdfecha_recibido,vstipo_cuenta, vsid_cuenta_origen ,vscomentario, vmonto_sva, vsintegridad, vcod_error,vmsn_error,
		vsstatus_cnc,viconsecutivo,pscve_usuario) into vsstatus_cnc;
		update bditransfer:"informix".tf_sva_transaction
			set integridad = vsintegridad , status_cnc = vsstatus_cnc
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'  and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		--termina el bloque de registros por transaccion
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	--Se actualiza flag de archivo conadmin
	update bditransfer:"informix".tf_archivos_transfer set conadmin='V' 
	where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen;
	
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 17) then
	foreach cusor1 with hold for
		select consecutivo, cuenta,	/*numcte,*/ clabe ,telefono	into viconsecutivo, vscuenta,/* vsnumcte,*/ vsclabe, vstelefono
		from Bditransfer:"informix".tf_resumen_edocta where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		--execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsnumcte) into vsesnumcte; Solución Temporal OPM 
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsclabe) into vsesclabe;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vstelefono) into vsestelefono;
		if ( (vsescuenta != 'V') /*or (vsesnumcte != 'V') */ or (vsesclabe != 'V')or (vsestelefono != 'V') ) then
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_resumen_edocta presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_resumen_edocta
			set integridad = vsintegridad
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and consecutivo = viconsecutivo and integridad = 'P';
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 18) then
	foreach cusor1 with hold for
		select consecutivo, no_txn_mps, cuenta	 into viconsecutivo, vsno_txn_mps, vscuenta
		from Bditransfer:"informix".tf_detalle_edocta	where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;
		-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsno_txn_mps) into vsesno_txn_mps;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		if ( (vsescuenta != 'V')or (vsesno_txn_mps != 'V') ) then
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_detalle_edocta presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_detalle_edocta
			set integridad = vsintegridad
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'  and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		--termina el bloque de registros por transaccion
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 19) then
	foreach	cusor1 with hold for
		select 	consecutivo, num_registros, num_cuentas
			into viconsecutivo, vinumregistros, vinum_cuentas
		from bditransfer:"informix".tf_control_edocta
			where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;
		-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vinumregistros::char(20)) into vsesnumregistros;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vinum_cuentas::char(20)) into vsesnum_cuentas;
		if ( (vsesnumregistros != 'V')or (vsesnum_cuentas != 'V') ) then
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_control_edocta presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_control_edocta
			set integridad = vsintegridad
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen  and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
elif (pitipolayout = 20) then
	foreach	cusor1 with hold for
		select 	consecutivo, cuenta into viconsecutivo, vscuenta
		from bditransfer:"informix".tf_administrative_transac
			where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;
		-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vscuenta) into vsescuenta;
		if  (vsescuenta != 'V')  then
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_administrative_transac presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_administrative_transac
			set integridad = vsintegridad
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen  and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;	
elif (pitipolayout = 21) then
    foreach cusor1 with hold for
		select consecutivo, id_cuenta_origen, id_transacc_mps, id_cuenta_destino
			into viconsecutivo, vsid_cuenta_origen, vsno_txn_mps, vsreferencia   
		from Bditransfer:"informix".tf_settlement_bank where 	nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P'
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	-- Valida integridad de los campos extraidos
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsno_txn_mps) into vsesno_txn_mps;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsid_cuenta_origen) into vsesid_cuenta_origen;
		execute procedure bditransfer:"informix".sp_transfer_esnumerico (vsreferencia) into vsesreferencia;
		if ((vsesno_txn_mps != 'V')  or (vsesid_cuenta_origen != 'V') or (vsesreferencia != 'V')) then
			let vsintegridad = 'E';
			let vielemento = 3;
			let vsActividad = 'El registro con consecutivo '|| viconsecutivo || ' de la tabla tf_settlement presenta error de integridad'; 
			execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
		else
			let vsintegridad = 'V';
			let vscodret = '00000';
		end if;
		update bditransfer:"informix".tf_settlement_bank
			set integridad = vsintegridad
		where nombrearchivo = psnomarchivo and archivo_origen = psarchivoorigen and integridad = 'P' and consecutivo = viconsecutivo;
		let vicontadorregistros = vicontadorregistros + 1;
		let vsmensaje_respuesta = 'terminar transaccion';	--termina el bloque de registros por transaccion
		if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
			commit work;
			let vsflagentransaccion = 'F';
			let vicontadorregistros = 0;
			continue foreach;
		end if;	
	end foreach;
	let vsmensaje_respuesta = 'terminar transaccion';
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;
else
	let vielemento = 3;
	let vsActividad = 'No existe proceso de validacion para el archivo ' || psnomarchivo ;
	execute procedure bditransfer:"informix".sp_transfer_guardabitacora ( vielemento, vsActividad, pscve_usuario) into vscodret;
end if; 
let vsmensaje_respuesta = 'Proceso de Validacion de integridad terminado';
return 
		vscodret,
		vsmensaje_respuesta;
end
end procedure
DOCUMENT
'*AUTOR: Ricardo Reséndiz Martínez Proyecto: Proceso de validacion de  Archivos Transfer',
'Solicito: Jose Luis Puebla Descripcion: Realiza proceso de validacion de archivos  de transfer de los compos significativos ',
'Fecha: 2014/07/28  Version: 20140728.1900 BD: BdiTransfer',
'*Modificado por: Juan Fco. Ponce Damian Modificacion: Se integra la ejecución de la Conadmin TRansfer para el archivo OutCapture (pitipolayout = 8) Fecha: 2014/09/18',
'*Modificado por: Ricardo Resendiz Modificacion: Se modifica proceso de validacion de layout 10 a Solicitud de Gabriela Gudiño Fecha: 2014/10/14',
'*Modificado por: Ricardo Resendiz Modificacion: Se agregan transacciones para generar registro en la MOV dia  Fecha: 2015/03/19', 
'*Modifico: L.I.A. Ricardo Reséndiz Martínez Proyecto: Proceso de registro de Transacciones SVA a  BANK y de BANK a SVA Solicito: Jose Luis Puebla',
'Descripcion: Se integra proceso para el registro de Abonos por Fondeo y Cargos por Transferencias Fecha: 2015/03/23 Version: 20150323.13 BD: BdiTransfer', 
'*MODIFICO: L.I.A. Ricardo Reséndiz Martínez Proyecto: Proceso de registro de Transacciones de Tiempo Aire se quita del Top up y se genera en el Success',
'Solicito: Jose Luis Puebla Descripcion: Se integra proceso para el registro de Abonos por Fondeo y Cargos por Transferencias Fecha: 2015/04/??',
'Version: 20150323.13 BD: BdiTransfer',
'*Modifico: L.I.A. Ricardo Reséndiz Martínez Proyecto: RQM 10650 Folio operaciones administrativas Solicito: Jose Luis Puebla',
'Descripcion: Se integra validación de campos de archivo de transacciones administrativas Fecha: 2015/08/26 Version: 20150323.13 BD: BdiTransfer',
'*Modifico: L.I.A. Ricardo Reséndiz Martínez Proyecto: RQM 10 616 Incorporar pago de servicios Transfer Solicito: Jose Luis Puebla',
'Descripcion: Se integra al proceso de registro nuevas transacciones pagos de servicios Fecha: 2016/06/02 Version: 20150602.1300 BD: BdiTransfer',
'*Modifico: L.I.A. Ricardo Reséndiz Martínez Proyecto:RQM 06 481 - Reportes Conciliación Transfer Solicito: Operaciones',
'Descripcion: Se integra proceso de recuperacion e insert a tabla de conciliación administrativa Fecha: 2016/06/02 Version: 20160602.1300 BD: BdiTransfer',
'*Modifico: L.I Marcos Gerardo Ayala Ponce Proyecto:10 721-2 - Transfer OPM SPEI - Creación de carpeta para archivo OPM SPEI (Addendum) Solicito: Operaciones',
'Descripcion: Se integra layout 21 Trnx SPEI fuera de la plataforma a Ctas Transfer. Fecha: 2016/08/18 Version: 20160818.1600 BD: BdiTransfer',
'*Modifico: L.I Marcos Gerardo Ayala Ponce Proyecto: RQM 10 616-3 Adendum - Incorporar pago de servicios en Transfer Solicito: Productos',
'Descripcion: Se integran 14 nuevas transacciones de pagos de servicios Fecha: 2017/03/28 Version: 20170328.1800 BD: BdiTransfer',
'*Modifico: L.I Marcos Gerardo Ayala Ponce Proyecto: RQM 10 929 Cuenta Efectiva Digital - Incorporar pago de servicios Solicito: Productos',
'Descripcion: Se integran 4 nuevas transacciones de pagos de servicios Fecha: 2017/07/03 Version: 20170703.1200 BD: BdiTransfer',
'*Modifico: L.I Marcos Gerardo Ayala Ponce Proyecto: RQM 06 557 Numero  Referencia Reporte Conciliación Transfer Solicito: Operaciones',
'Descripcion: Se integran campo de referencia MPS en la conciliación Fecha: 2017/07/10 Version: 20170710.1200 BD: BdiTransfer',
'*Modifico: L.I Marcos Gerardo Ayala Ponce Proyecto: RQM 10 929-2 Cuenta Efectiva Digital - Incorporar pago de servicios Solicito: Productos',
'Descripcion: Se integran 5 nuevas transacciones de pagos de servicios y se reemplaza la txn 0133 -> 0032 para SPEI BANK TO SVA  Fecha: 2017/08/18 Version: 20170818.1200 BD: BdiTransfer',
'*Modifico: L.I Marcos Gerardo Ayala Ponce Proyecto: RQM 06 572  Transacciones Nuevas Conciliación Solicito: Operaciones',
'Descripcion: Se añade la transacción 0057 para contabilizar las devoluciones a pagos de servicios Fecha: 2017/10/09 Version: 20171009.1500 BD: BdiTransfer',
'*Modifico: L.I Marcos Gerardo Ayala Ponce Proyecto: RQM 10 1098 Cuenta Móvil-Actualizacion de Reportes Solicito: Productos',
'Descripcion: Se añade la validación de integridad a motivo_cancelacion,id_txn_transfertobank de la tf_retire_customer Fecha: 2018/06/18 Version: 20180618.1800 BD: BdiTransfer';