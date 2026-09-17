CREATE PROCEDURE "informix".sp_sw_ro_consctascteparticipacion(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, pNumCliente char(20), 
				pRecuperacion int, pIp char(15), pMacAddress char(12))
	returning char(5) as codret
	
	define cCodRet char(5);
	define iSqlErr int;
	define cSitemaCuentaConsulta char(2);
	-- Parametros de salida del SP de consprodcte
	define cIndicadorChequera char(1);
	define cSistemaCuenta char(2);
	define cNoCuenta char(20);
	define cClaveProducto char(4);
	define cNombreProducto char(40);
	define dFechaApertura date;
	define cStatusCuenta char(60);
	define dFechaStatusCuenta date;
	define cClaveSucursal char(4);
	define cEjecutivoAperturaCuenta char(8);
	define mSaldoActual money(14,2);
	define cNumTarjeta char(20);
	define cStatusTarjeta char(15);
	define cCuentaClabe char(18);
	define dFechaAperturaOriginal date;
	define cCodRetSp char(5);
	define iRegistros int;
	define iDiaCorte int;
	define cTipoParticipacion char(1);
	define iExiste int;
	define cNumCuentaParticipe char(20);
	define cStatusBloq char(1);
	define dFechaBloqueo date;
	define cMotivoBloqueo char(40);
	define dFechaCancelacion date;
	define cCodEstatusCta char(2);
	
	let cCodRet = '00000';
	let cCodRetSp = '00000';
	let iSqlErr = 0;
	let cSitemaCuentaConsulta = '00'; -- Todas la cuentas
	-- Parametros de salida del SP de consprodcte
	let cIndicadorChequera = '';
	let cSistemaCuenta = '';
	let cNoCuenta = '';
	let cClaveProducto = '';
	let cNombreProducto = '';
	let dFechaApertura = null;
	let cStatusCuenta = '';
	let dFechaStatusCuenta = null;
	let cClaveSucursal = '';
	let cEjecutivoAperturaCuenta = '';
	let mSaldoActual = null;
	let cNumTarjeta = '';
	let cStatusTarjeta = '';
	let cCuentaClabe = '';
	let dFechaAperturaOriginal = '';
	let iRegistros = 0;
	let iDiaCorte = 0;
	let cTipoParticipacion = '';
	let iExiste = 0;
	let cNumCuentaParticipe = '';
	let cStatusBloq = '0';
	let dFechaBloqueo = null;
	let cMotivoBloqueo = '';
	let dFechaCancelacion = '';
	let cCodEstatusCta = '';
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet;
			end if;
		end exception;
		
		-- Cuentas del cliente titular
		let cTipoParticipacion = 'T'; -- en estas cuentas el cliente es titular
		
		while cCodRetSp = '00000'
			set isolation to dirty read;
			foreach execute procedure bdinteg:"informix".sp_cnsif_consprodcte(pUsuario, pIdFuncion, pNumCliente, cSitemaCuentaConsulta, iRegistros, pRecuperacion)
				into cCodRetSp, cIndicadorChequera, cSistemaCuenta, cNoCuenta, cClaveProducto, cNombreProducto, dFechaApertura, 
					cStatusCuenta, dFechaStatusCuenta, cClaveSucursal, cEjecutivoAperturaCuenta, mSaldoActual, cNumTarjeta, cStatusTarjeta, 
					cCuentaClabe, dFechaAperturaOriginal, iDiaCorte, dFechaCancelacion, cCodEstatusCta
				
				if cCodRetSp = '00000' then
				
					-- Se agrega el campo de bloqueo de la cuenta
					let cStatusBloq = '0';
					let dFechaBloqueo = null;
					let cMotivoBloqueo = '';
					
					if iDiaCorte is null then
						let iDiaCorte = 1;
					end if;
					
					execute procedure "informix".sp_sw_ro_consstatusbloqueo(pUsuario, pIdFuncion, cSistemaCuenta, cNoCuenta)
						into cStatusBloq, cMotivoBloqueo, dFechaBloqueo;
					
					insert into "informix".sw_ro_ctascliente_temp(id_oficio, id_busqueda,	id_resulcte, tipo_cuenta, cuenta, clave_producto, nombre_producto, fecha_apertura, 
												status_cuenta, fecha_status_cuenta, clave_suc_apertura,	ejecutivo_apertura,	saldo_actual, num_tarjeta, status_tarjeta,
												cuenta_clabe, fecha_original_apertura, ind_cuenta_ya_bloqueada, motivo_bloqueo, fecha_bloqueo, dia_corte)
					values(pIdOficio, pIdBusqueda, pIdCliente, cSistemaCuenta, cNoCuenta, cClaveProducto, cNombreProducto, dFechaApertura, 
									cStatusCuenta, dFechaStatusCuenta, cClaveSucursal, cEjecutivoAperturaCuenta, mSaldoActual, cNumTarjeta, cStatusTarjeta,
									cCuentaClabe, dFechaAperturaOriginal, cStatusBloq, cMotivoBloqueo, dFechaBloqueo, iDiaCorte);
					--return dbinfo('sqlca.sqlerrd1') with resume;
				end if;
				
			end foreach;
			let iRegistros = iRegistros + pRecuperacion;
			
		end while;
		
		-- Se insertan los registros de las cuentas en las tabla de ctecta
		set isolation to dirty read;
		insert into "informix".sw_ro_ctecta(id_oficio, id_busqueda, id_resulcte, numcte, cuenta, id_tipo_participe, tipo_participe, 
								tipo_cuenta, producto, nombre_producto, status_cuenta, fecha_apertura, sucursal,
								sdo_actual, user_insert, ip_insert, mac_insert, fecha_apertura_original, cuenta_clabe,
								ejecutivo, ind_cuenta_ya_bloqueada, motivo_bloqueo, fecha_bloqueo, dia_corte)
		select distinct id_oficio, id_busqueda, id_resulcte, pNumCliente, cuenta, '1', 'TITULAR',
						tipo_cuenta, clave_producto, nombre_producto, status_cuenta, fecha_apertura, clave_suc_apertura,
						saldo_actual, pUsuario, pIp, pMacAddress, fecha_original_apertura, cuenta_clabe, 
						ejecutivo_apertura, ind_cuenta_ya_bloqueada, motivo_bloqueo, fecha_bloqueo, dia_corte
		from "informix".sw_ro_ctascliente_temp where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente;
		
		
		-- Se consultan las tarjetas del cliente
		let pRecuperacion = iRegistros + pRecuperacion;
		execute procedure "informix".sp_sw_ro_tarjetascte(pUsuario, pIdFuncion, pIdOficio, pIdBusqueda, pIdCliente, pNumCliente, 0, pRecuperacion) into cCodRetSp;
		
		-- Busca la participaciÃ³n en las cuentas
		execute procedure "informix".sp_sw_ro_buscaparticipacion(pUsuario, pIdOficio, pIdBusqueda, pIdCliente, pNumCliente, pIp, pMacAddress) into cCodRet;
		
		return cCodRet;
		
	end;
end procedure;