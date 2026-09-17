create procedure "informix".sp_sw_ro_consctascte(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, pNumCliente char(20), pRegistros int, pRecuperacion int)
	returning char(5) as codret,
		int as id_cta,
		char(20) as cuenta,
		int as id_tipo_participe,
		char(30) as tipo_participe,
		char(2) as tipo_cuenta,
		char(4) as producto,
		char(40) as nombre_producto,
		char(60) as status_cuenta,
		char(10) as fecha_apertura,
		char(10) as ejecutivo_apertura,
		char(4) as sucursal,
		money(14, 2) as saldo,
		char(18) as cuenta_clabe,
		char(10) as fecha_apertura_original,
		char(40) as motivo_bloqueo,
		char(10) as fecha_bloqueo,
		char(14) as indicadores

	define cCodRet char(5);
	define iSqlErr int;
	define iIdCtecta int;
	define cCuenta char(20);
	define iIdTipoParticipe int;
	define cTipoParticipe char(30);
	define cTipoCuenta char(2);
	define cCveProducto char(4);
	define cDescProducto char(40);
	define cStatusCuenta char(60);
	define cFechaApertura char(10);
	define cSucursal char(4);
	define saldo money(14,2);
	define indicadores char(14);
	define iNoRegs int;
	define cFechaAperturaOriginal char(10);
	define cCuentaClabe char(18);
	define cEjecutivoApertura char(8);
	define cMotivoBloqueo char(40);
	define cFechaBloqueo char(10);
	
	let cCodRet = '';
	let iSqlErr = 0;
	let iIdCtecta = 0;
	let cCuenta = '';
	let iIdTipoParticipe = 0;
	let cTipoParticipe = '';
	let cTipoCuenta = '';
	let cCveProducto = '';
	let cDescProducto = '';
	let cStatusCuenta = '';
	let cFechaApertura = '';
	let cSucursal = '';
	let saldo = null;
	let indicadores = '';
	let iNoRegs = 0;
	let cFechaAperturaOriginal = '';
	let cCuentaClabe = '';
	let cEjecutivoApertura = '';
	let cMotivoBloqueo = '';
	let cFechaBloqueo = '';
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iIdCtecta, cCuenta, iIdTipoParticipe, cTipoParticipe, cTipoCuenta, cCveProducto, cDescProducto, cStatusCuenta, 
						cFechaApertura, cEjecutivoApertura, cSucursal, saldo, cCuentaClabe, cFechaAperturaOriginal, cMotivoBloqueo, cFechaBloqueo, indicadores;
			end if;
		end exception;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, iIdCtecta, cCuenta, iIdTipoParticipe, cTipoParticipe, cTipoCuenta, cCveProducto, cDescProducto, cStatusCuenta, 
					cFechaApertura, cEjecutivoApertura, cSucursal, saldo, cCuentaClabe, cFechaAperturaOriginal, cMotivoBloqueo, cFechaBloqueo, indicadores;
		end if;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or pNumCliente = '' or pRegistros = '' or pRecuperacion = '' then
			let cCodRet = '00003';
			return cCodRet, iIdCtecta, cCuenta, iIdTipoParticipe, cTipoParticipe, cTipoCuenta, cCveProducto, cDescProducto, cStatusCuenta, 
					cFechaApertura, cEjecutivoApertura, cSucursal, saldo, cCuentaClabe, cFechaAperturaOriginal, cMotivoBloqueo, cFechaBloqueo, indicadores;
		end if;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		foreach
				select skip pRegistros first pRecuperacion 
						id_ctacte, cuenta, id_tipo_participe, tipo_participe, tipo_cuenta, producto, nombre_producto, status_cuenta, fecha_apertura,
						ejecutivo, sucursal, sdo_actual, cuenta_clabe, fecha_apertura_original, motivo_bloqueo, fecha_bloqueo, 
						ind_cuenta_ya_bloqueada||ind_fecha_apertura||ind_sucursal_apertura||ind_domicilio_sucursal||ind_saldo||
						ind_reportar_status||ind_beneficiarios||ind_facultados||ind_datos_titular||ind_terminado||certifica_imagenes||
						certifica_edocuenta||detalle_movimientos||ind_bloqueo_cta_por_sistema as indicadores
				into iIdCtecta, cCuenta, iIdTipoParticipe, cTipoParticipe, cTipoCuenta, cCveProducto, cDescProducto, cStatusCuenta, cFechaApertura,
						cEjecutivoApertura, cSucursal, saldo, cCuentaClabe, cFechaAperturaOriginal, cMotivoBloqueo, cFechaBloqueo, indicadores
				from sw_ro_ctecta
				where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente and numcte = pNumCliente
				order by id_ctacte
			
			let iNoRegs = iNoRegs + 1;
			return cCodRet, iIdCtecta, cCuenta, iIdTipoParticipe, cTipoParticipe, cTipoCuenta, cCveProducto, cDescProducto, cStatusCuenta, 
					cFechaApertura, cEjecutivoApertura, cSucursal, saldo, cCuentaClabe, cFechaAperturaOriginal, cMotivoBloqueo, cFechaBloqueo, indicadores with resume;
			
		end foreach;
		
		if iNoRegs = 0 and pRegistros = 0 then
			let cCodRet = '00024';
			return cCodRet, iIdCtecta, cCuenta, iIdTipoParticipe, cTipoParticipe, cTipoCuenta, cCveProducto, cDescProducto, cStatusCuenta, 
					cFechaApertura, cEjecutivoApertura, cSucursal, saldo, cCuentaClabe, cFechaAperturaOriginal, cMotivoBloqueo, cFechaBloqueo, indicadores;
		elif iNoRegs = 0 and pRegistros > 0 then
			let cCodRet = '01001';
			return cCodRet, iIdCtecta, cCuenta, iIdTipoParticipe, cTipoParticipe, cTipoCuenta, cCveProducto, cDescProducto, cStatusCuenta, 
					cFechaApertura, cEjecutivoApertura, cSucursal, saldo, cCuentaClabe, cFechaAperturaOriginal, cMotivoBloqueo, cFechaBloqueo, indicadores;
		end if;
	
	end;
		
end procedure;