create procedure "informix".sp_transfer_conadmin_success (
					pdfecha     		date
					)
returning 	
				varchar (5) as codret, 
				varchar (150) as mensaje_respuesta;
-- Definicion de retorno
define 	vscodret 				char(5);
define  vsmensaje_respuesta     char(150);

define  vsnombrearchivo 		char(50);
define  vsproceso				char(1);
define  visqlerr				integer;


-- Datos para pivote
define  vsconsecutivo 			integer;
define  vsfolio_suc_file		char(16);
define  vsconciliacion			char(1);
define  vsflagentransaccion     char(1);
define  vicontadorregistros		integer;
define  vicontador				integer;
define  vstransacc_file		    char(4);
define  vstransaccion           char(4);
define  vstransaccion1          char(4);
define  vsnaturaleza 			char(1);
define  vdfecha_hoy_integral    date;

define  viminserial 			integer;
define  vimaxserial 			integer;


-- Datos para recuperar transaccion cargo
define 	vdfech_alt_cargo 		date;
define 	vstransacc_cargo		char(4);
define	vsproducto_cargo		char(4);
define 	vsfoliosuc_cargo		char(16);
define  vimonto_tot_cargo		money; 
define  vsreferencia_cargo		char(40);
define  vscuenta_cargo			char(20);
define  vsristrac_cargo			char(19);
define  vsristraa_cargo			char(19);

-- Datos para recuperar transaccion abono
define 	vdfech_alt_abono 		date;
define 	vstransacc_abono		char(4);
define	vsproducto_abono		char(4);
define 	vsfoliosuc_abono		char(16);
define  vimonto_tot_abono		money;
define  vsreferencia_abono		char(40);
define  vscuenta_abono			char(20);
define  vsristrac_abono			char(19);
define  vsristraa_abono			char(19);

				
begin
	on exception set visqlerr
		
		let vscodret = vsCodRet;
		
		return vscodret, vsmensaje_respuesta;
				
	end exception;
	
--set debug file to "/informix/HomeInformix/rrm/sp_transfer_conadmin_success.out";
--trace on;

-- Inicializacion de retorno
Let  vscodret = '00000';
let  vsmensaje_respuesta = '';

let  vsnombrearchivo = '';
let  vsproceso = '';


-- Datos para pivote
let  vsconsecutivo = 0;
let  vsfolio_suc_file = '';
let  vsconciliacion	= '';
let  vsflagentransaccion = '';
let  vicontadorregistros = 0;
let  vicontador = 0;
let  vstransaccion = '';
let  vstransaccion1 = '';
let  vsnaturaleza = '';

let vdfecha_hoy_integral = '01/01/1900';

let viminserial = 0;
let vimaxserial = 0;

-- Datos para recuperar transaccion cargo
let 	vdfech_alt_cargo = '01/01/1900';
let 	vstransacc_cargo = '';
let		vsproducto_cargo = '';
let 	vsfoliosuc_cargo = '';
let  	vimonto_tot_cargo = 0;
let  	vscuenta_cargo	= '';
let 	vsreferencia_cargo = '';
let  	vsristrac_cargo	= '';
let  	vsristraa_cargo	= '';

-- Datos para recuperar transaccion abono
let 	vdfech_alt_abono = '01/01/1900';
let 	vstransacc_abono = '';
let		vsproducto_abono = '';
let 	vsfoliosuc_abono = '';
let  	vimonto_tot_abono = 0;
let  	vscuenta_abono	= '';
let		vsreferencia_abono = '';
let  	vsristrac_abono	= '';
let  	vsristraa_abono	= '';


--Valida fecha de integral
set lock mode to wait 3;
set isolation to dirty read;
select limit 1 fecha_hoy into vdfecha_hoy_integral 
	from bdinteg:"informix".si_fechas
		where empresa = '001';
		
if (vdfecha_hoy_integral < current::date) then 
	let vscodret = '00001'; 
	let vsmensaje_respuesta = 'Fecha integral es menor a la fecha del servidor central';
			
	return 
		vscodret,
		vsmensaje_respuesta;
end if;

select  limit 1 nombrearchivo, proceso
	into vsnombrearchivo, vsproceso	
from Bditransfer:"informix".tf_archivos_transfer
	where 	fecha_proceso = pdfecha and 
			archivo_origen = 'TME';

			
if (vsnombrearchivo = '' or vsnombrearchivo is null) then 
	let vscodret = '00002'; 
	let vsmensaje_respuesta = 'El archivo no fue entregado';
	
	return 
		vscodret,
		vsmensaje_respuesta;
		
elif (vsnombrearchivo <> '' or vsnombrearchivo is not null) and vsproceso = 'E' then
	let vscodret = '00003'; 
	let vsmensaje_respuesta = 'El archivo se entrego con error en integraciÃ³n';
	
	return 
		vscodret,
		vsmensaje_respuesta;
end if;

foreach cursor1 with hold for
		select consecutivo, folio_suc_file, conciliado 
			into vsconsecutivo, vsfolio_suc_file, vsconciliacion 
		from Bditransfer:"informix".tf_conciliacionadmiva_transfer
			where --fecha_alt_file = pdfecha-1 and
				  conciliado = 'P'
		
		if (vsflagentransaccion = 'F') then 
			begin work;
			let vsflagentransaccion = 'V';
		end if;	
		
		select count(*) into vicontador 
			from bdicheq:sc_movdia 
				where folio_suc = vsfolio_suc_file;
				
		if vicontador = 1 then 
			
			select transacc
				into vstransaccion
			from bdicheq:sc_movdia
				where folio_suc = vsfolio_suc_file;
				
			select first 1 naturaleza into vsnaturaleza from bditransfer:"informix".tf_param_transfer
				where trim(valor) = vstransaccion;
				
			if vsnaturaleza = 'C' then 
			
				select fech_alt, transacc,producto,monto_tot, cuenta, referencia, folio_suc
					into vdfech_alt_cargo, vstransacc_cargo, vsproducto_cargo,vimonto_tot_cargo, vscuenta_cargo, vsreferencia_cargo, vsfoliosuc_cargo
				from bdicheq:"informix".sc_movdia
					where folio_suc = vsfolio_suc_file;
				
				if vsfoliosuc_cargo <> '' or vsfoliosuc_cargo is not null then
									
					select first 1 
							trim (c_ccmayor) || '-' || trim (c_ccsub) || '-' || trim (c_ccsubsub) || '-' || trim (c_ccsssub) || '-' || trim (c_ccssssub) || '-' || trim (c_sector) as cuentac,
							trim (a_ccmayor) || '-' || trim (a_ccsub) || '-' || trim (a_ccsubsub) || '-' || trim (a_ccsssub) || '-' || trim (a_ccssssub) || '-' || trim (a_sector)  as cuentaa
						into vsristrac_cargo, vsristraa_cargo
					from bdinteg:"informix".si_prodtran
						where 	empresa = '001'
								and producto = vsproducto_cargo
								and sistema is not null
								and transaccion = vstransacc_cargo
								and secuencia = 1;

					update bditransfer:"informix".tf_conciliacionadmiva_transfer
						set 
							cuenta_cargo_chq =  vscuenta_cargo,
							transacc_cargo_chq = vstransacc_cargo,
							fecha_alt_cargo = vdfech_alt_cargo,
							folio_suc_cargo_chq	= 	vsfoliosuc_cargo,
							monto_cargo_chq	= vimonto_tot_cargo,
							referencia_cargo = vsreferencia_cargo,
							rccontable_cargo = 	vsristrac_cargo,
							racontable_cargo =  vsristraa_cargo,
							conciliado = 'V'
					where 
						consecutivo = vsconsecutivo and
						conciliado = 'P';
				
				else
				
					update bditransfer:"informix".tf_conciliacionadmiva_transfer
						set 
							cuenta_cargo_chq =  '',
							transacc_cargo_chq = '',
							fecha_alt_cargo = '01/01/1900',
							folio_suc_cargo_chq	= 	'',
							monto_cargo_chq	= 0,
							referencia_cargo = '',
							rccontable_cargo = 	'',
							racontable_cargo =  '',
							conciliado = 'E'
					where 
						consecutivo = vsconsecutivo and
						conciliado = 'P';
				end if;
				
			elif vsnaturaleza = 'A' then 
					
				select fech_alt, transacc,producto,monto_tot, cuenta, referencia, folio_suc
					into vdfech_alt_abono, vstransacc_abono, vsproducto_abono,vimonto_tot_abono, vscuenta_abono, vsreferencia_abono, vsfoliosuc_abono
				from bdicheq:"informix".sc_movdia
					where folio_suc = vsfolio_suc_file;
				
				if vsfoliosuc_abono <> '' or vsfoliosuc_abono is not null then
									
					select first 1 
							trim (c_ccmayor) || '-' || trim (c_ccsub) || '-' || trim (c_ccsubsub) || '-' || trim (c_ccsssub) || '-' || trim (c_ccssssub) || '-' || trim (c_sector) as cuentac,
							trim (a_ccmayor) || '-' || trim (a_ccsub) || '-' || trim (a_ccsubsub) || '-' || trim (a_ccsssub) || '-' || trim (a_ccssssub) || '-' || trim (a_sector)  as cuentaa
						into vsristrac_abono, vsristraa_abono
					from bdinteg:"informix".si_prodtran
						where 	empresa = '001'
								and producto = vsproducto_abono
								and sistema is not null
								and transaccion = vstransacc_abono
								and secuencia = 1;

					update bditransfer:"informix".tf_conciliacionadmiva_transfer
						set 
							cuenta_abono_chq =  vscuenta_abono,
							transacc_abono_chq = vstransacc_abono,
							fecha_alt_abono = vdfech_alt_abono,
							folio_suc_abono_chq	= 	vsfoliosuc_abono,
							monto_abono_chq	= vimonto_tot_abono,
							referencia_abono = vsreferencia_abono,
							rccontable_abono = 	vsristrac_abono,
							racontable_abono =  vsristraa_abono,
							conciliado = 'V'
					where 
						consecutivo = vsconsecutivo and
						conciliado = 'P';
				
				else
				
					update bditransfer:"informix".tf_conciliacionadmiva_transfer
						set 
							cuenta_abono_chq =  '',
							transacc_abono_chq = '',
							fecha_alt_abono = '01/01/1900',
							folio_suc_abono_chq	= 	'',
							monto_abono_chq	= 0,
							referencia_abono = '',
							rccontable_abono = 	'',
							racontable_abono =  '',
							conciliado = 'E'
					where 
						consecutivo = vsconsecutivo and
						conciliado = 'P';
				end if;
			end if;
			
		elif vicontador = 2 then 	
		
			select  min(num_serial), max(num_serial) 
				into viminserial, vimaxserial
			from bdicheq:"informix".sc_movdia
				where  folio_suc = vsfolio_suc_file;
		
			select limit 1 
				             fech_alt,   transacc,           producto,        monto_tot,         cuenta,         referencia,         folio_suc
				into vdfech_alt_cargo, vstransacc_cargo, vsproducto_cargo,vimonto_tot_cargo, vscuenta_cargo, vsreferencia_cargo, vsfoliosuc_cargo
			from bdicheq:"informix".sc_movdia
				where folio_suc = vsfolio_suc_file and
						num_serial = viminserial;
			--order by num_serial;
			
			select limit 1 
				fech_alt, transacc,producto,monto_tot, cuenta, referencia, folio_suc
				into vdfech_alt_abono, vstransacc_abono, vsproducto_abono,vimonto_tot_abono, vscuenta_abono, vsreferencia_abono, vsfoliosuc_abono
			from bdicheq:"informix".sc_movdia
				where 	folio_suc = vsfolio_suc_file and
						num_serial = vimaxserial;
			--order by num_serial desc;
			
			if 	(vsfoliosuc_cargo <> '' or vsfoliosuc_cargo is not null) and 
				(vsfoliosuc_abono <> '' or vsfoliosuc_abono is not null) then
				
				select first 1 
					trim (c_ccmayor) || '-' || trim (c_ccsub) || '-' || trim (c_ccsubsub) || '-' || trim (c_ccsssub) || '-' || trim (c_ccssssub) || '-' || trim (c_sector) as cuentac,
					trim (a_ccmayor) || '-' || trim (a_ccsub) || '-' || trim (a_ccsubsub) || '-' || trim (a_ccsssub) || '-' || trim (a_ccssssub) || '-' || trim (a_sector)  as cuentaa
				into vsristrac_cargo, vsristraa_cargo
					from bdinteg:"informix".si_prodtran
						where 	empresa = '001'
								and producto = vsproducto_cargo
								and sistema is not null
								and transaccion = vstransacc_cargo
								and secuencia = 1;
			
				select first 1 
					trim (c_ccmayor) || '-' || trim (c_ccsub) || '-' || trim (c_ccsubsub) || '-' || trim (c_ccsssub) || '-' || trim (c_ccssssub) || '-' || trim (c_sector) as cuentac,
					trim (a_ccmayor) || '-' || trim (a_ccsub) || '-' || trim (a_ccsubsub) || '-' || trim (a_ccsssub) || '-' || trim (a_ccssssub) || '-' || trim (a_sector)  as cuentaa
				into vsristrac_abono, vsristraa_abono
					from bdinteg:"informix".si_prodtran
						where 	empresa = '001'
								and producto = vsproducto_abono
								and sistema is not null
								and transaccion = vstransacc_abono
								and secuencia = 1;
								
				update bditransfer:"informix".tf_conciliacionadmiva_transfer
						set 
							--Cargo
							cuenta_cargo_chq =  vscuenta_cargo,
							transacc_cargo_chq = vstransacc_cargo,
							fecha_alt_cargo = vdfech_alt_cargo,
							folio_suc_cargo_chq	= 	vsfoliosuc_cargo,
							monto_cargo_chq	= vimonto_tot_cargo,
							referencia_cargo = vsreferencia_cargo,
							rccontable_cargo = 	vsristrac_cargo,
							racontable_cargo =  vsristraa_cargo,
							-- Abono
							cuenta_abono_chq =  vscuenta_abono,
							transacc_abono_chq = vstransacc_abono,
							fecha_alt_abono = vdfech_alt_abono,
							folio_suc_abono_chq	= 	vsfoliosuc_abono,
							monto_abono_chq	= vimonto_tot_abono,
							referencia_abono = vsreferencia_abono,
							rccontable_abono = 	vsristrac_abono,
							racontable_abono =  vsristraa_abono,
							conciliado = 'V'
					where 
						consecutivo = vsconsecutivo and
						conciliado = 'P';
				
			else
				
				update bditransfer:"informix".tf_conciliacionadmiva_transfer
						set 
							--Cargo
							cuenta_cargo_chq =  '',
							transacc_cargo_chq = '',
							fecha_alt_cargo = '01-01-1900',
							folio_suc_cargo_chq	= 	'',
							monto_cargo_chq	= 0,
							referencia_cargo = '',
							rccontable_cargo = 	'',
							racontable_cargo =  '',
							-- Abono
							cuenta_abono_chq =  '',
							transacc_abono_chq = '',
							fecha_alt_abono = '01-01-1900',
							folio_suc_abono_chq	= 	'',
							monto_abono_chq	= 0,
							referencia_abono = '',
							rccontable_abono = 	'',
							racontable_abono =  '',
							conciliado = 'E'
				where 
						consecutivo = vsconsecutivo and
						conciliado = 'P';	
				
			end if;
		
		else 
				
				update bditransfer:"informix".tf_conciliacionadmiva_transfer
						set 
							--Cargo
							cuenta_cargo_chq =  '',
							transacc_cargo_chq = '',
							fecha_alt_cargo = '01-01-1900',
							folio_suc_cargo_chq	= 	'',
							monto_cargo_chq	= 0,
							referencia_cargo = '',
							rccontable_cargo = 	'',
							racontable_cargo =  '',
							-- Abono
							cuenta_abono_chq =  '',
							transacc_abono_chq = '',
							fecha_alt_abono = '01-01-1900',
							folio_suc_abono_chq	= 	'',
							monto_abono_chq	= 0,
							referencia_abono = '',
							rccontable_abono = 	'',
							racontable_abono =  '',
							conciliado = 'E'
				where 
						consecutivo = vsconsecutivo and
						conciliado = 'P';
				
		
		end if;
		
	let vicontadorregistros = vicontadorregistros + 1;
	--let vsmensaje_respuesta = 'terminar transaccion';	--termina el bloque de registros por transaccion
	if (vicontadorregistros = 1000) then --verifica si alcanso el maximo de transacciones por bloque
		commit work;
		let vsflagentransaccion = 'F';
		let vicontadorregistros = 0;
		continue foreach;
	end if;
end foreach;


let vsCodRet = '00000';
let vsmensaje_respuesta = 'Proceso Terminado';	


if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
	commit work;
	let vsflagentransaccion = 'F';
end if;


let vsCodRet = '00000';
--let vsmensaje_respuesta = 'Proceso de Conciliacion Administrativa de Transacciones Terminado';
   let vsmensaje_respuesta = 'Proceso Terminado';	
	
RETURN 
	vsCodRet, 
	vsMensaje_Respuesta;
end
end procedure
DOCUMENT
'AUTOR: L.I.A. Ricardo ResÃ©ndiz MartÃ­nez',
'Proyecto: RQM 06 481 - Reportes ConciliaciÃ³n Transfer',
'Solicito: Operaciones TRANSFER',
'Descripcion: Se realiza proceso de conciliacion administrativa de los proceso de transacciones Exitosas',
'Fecha: 2016/07/04',
'Version: 20160704.1100',
'BD: Bditransfer';