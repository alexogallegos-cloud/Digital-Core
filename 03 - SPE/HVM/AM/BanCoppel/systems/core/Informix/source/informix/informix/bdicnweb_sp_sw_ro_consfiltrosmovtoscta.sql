create procedure "informix".sp_sw_ro_consfiltrosmovtoscta(pUsuario char(8), pIdFuncion char(10), pNumCliente char(20), pIdOficio int, pIdCliente int, pNumCuenta char(20))
	returning char(5) as codret,
			char(20) as numcliente,
			char(2) as tipo_cuenta,
			date as fechaInicio,
			date as fechaFin,
			char(4) as sucursal,
			char(8) as empleado,
			decimal(18,2) as monto
	

	define iSqlErr int;
	define cCodRet char(5);
	define cNoCte char(20);
	define cSistemaCuenta char(2);
	define dFechaInicio date;
	define dFechaFin date;
	define cSucursal char(4);
	define cEmpleado char(8);
	define decMonto decimal(18,2);
	
	let iSqlErr = 0;
	let cCodRet = '00000';
	let cNoCte = '';
	let cSistemaCuenta = '';
	let dFechaInicio = '';
	let dFechaFin = '';
	let cSucursal = '';
	let cEmpleado = '';
	let decMonto = 0.0;
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cNoCte, cSistemaCuenta, dFechaInicio, dFechaFin, cSucursal, cEmpleado, decMonto;
			end if;
		end exception;
		
		
		-- Validaciones de variables
		if pUsuario = '' or pIdFuncion = '' or pNumCliente = '' or pIdOficio = '' or  pIdCliente = '' or pNumCuenta = '' then
			let cCodRet = '00003';
			return cCodRet, cNoCte, cSistemaCuenta, dFechaInicio, dFechaFin, cSucursal, cEmpleado, decMonto;
		end if;
		
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, cNoCte, cSistemaCuenta, dFechaInicio, dFechaFin, cSucursal, cEmpleado, decMonto;
		end if;
		
		select numcte, tipo_cuenta, fecha_inicio, fecha_fin, sucursal, empleado, nvl(monto, 0.0)
		into cNoCte, cSistemaCuenta, dFechaInicio, dFechaFin, cSucursal, cEmpleado, decMonto
		from sw_ro_filtros_movtos where id_oficio =  pIdOficio and numcte = pNumCliente and id_resulcte = pIdCliente
			and cuenta = pNumCuenta;
		
		return cCodRet, cNoCte, cSistemaCuenta, dFechaInicio, dFechaFin, cSucursal, cEmpleado, decMonto;
	end;
	
end procedure;