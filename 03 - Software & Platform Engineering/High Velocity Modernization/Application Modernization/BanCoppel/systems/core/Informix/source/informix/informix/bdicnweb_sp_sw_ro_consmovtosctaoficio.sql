create procedure "informix".sp_sw_ro_consmovtosctaoficio(pUsuario char(8), pIdFuncion char(20), pIdOficio int, pIdCliente int, pNumCuenta char(20), pRegistros int, pRecuperacion int)
	returning char(5) as codret, 
	char(10) as fecha_movimiento,
	char(50) as descripcion_transaccion,
	decimal(18,2) as monto,
	char(4) as sucursal,
	char(40) as nombre_sucursal,
	char(60) as ciudad,
	char(30) as estado
	
	define cCodRet char(5);
	define iSqlErr int;
	define dFechaMovto date;
	define cDescMovto char(50);
	define dMonto decimal(18,2);
	define cSucursal char(4);
	define cNombreSuc char(40);
	define cCiudad char(60);
	define cEstado char(30);
	define iNoRegistros int;
	define cBuscarMovtos char(1);
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	let dFechaMovto = null;
	let cDescMovto = '';
	let dMonto = 0;
	let cSucursal = '';
	let cNombreSuc = '';
	let cCiudad = '';
	let cEstado = '';
	let iNoRegistros = 0;
	let cBuscarMovtos = '';
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, dFechaMovto, cDescMovto, dMonto, cSucursal, cNombreSuc, cCiudad, cEstado;
			end if;
		end exception;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdCliente = '' or pNumCuenta = '' or pRegistros = '' or pRecuperacion = '' then
			let cCodRet = '00003';
			return cCodRet, dFechaMovto, cDescMovto, dMonto, cSucursal, cNombreSuc, cCiudad, cEstado;
		end if;
		
		if pRecuperacion <= 0 then
			let cCodRet = '00098';
			return cCodRet, dFechaMovto, cDescMovto, dMonto, cSucursal, cNombreSuc, cCiudad, cEstado;
		end if;
		
		if pRegistros < 0 then
			let cCodRet = '00098';
			return cCodRet, dFechaMovto, cDescMovto, dMonto, cSucursal, cNombreSuc, cCiudad, cEstado;
		end if;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, dFechaMovto, cDescMovto, dMonto, cSucursal, cNombreSuc, cCiudad, cEstado;
		end if;
		
		-- Validamos si hay movimientos por mostrar
		select detalle_movimientos
		into cBuscarMovtos
		from sw_ro_ctecta
		where id_oficio = pIdOficio and id_resulcte = pIdCliente and cuenta = pNumCuenta;
		
		if cBuscarMovtos = '1' then
			foreach
					select skip pRegistros first pRecuperacion fecha_mov, descripcion_transaccion, monto, sucursal, nombre_sucursal, ciudad_nombre, estado_nombre
					into dFechaMovto, cDescMovto, dMonto, cSucursal, cNombreSuc, cCiudad, cEstado
					from sw_ro_movtos
					where id_oficio = pIdOficio and id_resulcte = pIdCliente and cuenta = pNumCuenta
					and ind_omitido = '0' and status = '1'
				
				let iNoRegistros = iNoRegistros + 1;
				return cCodRet, dFechaMovto, cDescMovto, dMonto, cSucursal, cNombreSuc, cCiudad, cEstado with resume;

			end foreach;
			
			if iNoRegistros = 0 then
				let cCodRet = '01001';
				return cCodRet, dFechaMovto, cDescMovto, dMonto, cSucursal, cNombreSuc, cCiudad, cEstado;
			end if;
		else
			let cCodRet = '01001';
			return cCodRet, dFechaMovto, cDescMovto, dMonto, cSucursal, cNombreSuc, cCiudad, cEstado;
		end if;
		
	end;
	
end procedure;