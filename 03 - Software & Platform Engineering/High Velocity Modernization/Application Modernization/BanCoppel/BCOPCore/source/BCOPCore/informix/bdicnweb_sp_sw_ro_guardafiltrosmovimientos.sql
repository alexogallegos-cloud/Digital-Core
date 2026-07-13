CREATE PROCEDURE "informix".sp_sw_ro_guardafiltrosmovimientos(pUsuario char(10), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int,
			pNumCliente char(20), pNumCuenta char(20), pSistemaCuenta char(2), pFechaInicio char(10), pFechaFin char(10), pSucursal char(4),
			pEmpleadoConsulta char(10), pMonto decimal(18,2), pIp char(15), pMac char(12))

	returning char(5) as codret
	
	define iSqlErr int;
	define cCodRet char(5);
	define pfechaInicio1 date;
	define pfechafin1 date;

	let pfechaInicio1 ='';
	let pfechafin1 ='';	
	
	let iSqlErr = 0;
	let cCodRet = '00000';
	
	begin
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet;
			end if;
		end exception;
		
		
		-- Validaciones de variables
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or
			pNumCliente = '' or pNumCuenta = '' or pSistemaCuenta = '' or pFechaInicio = '' or pFechaFin = '' or
			pIp = '' or pMac = '' then
			
			let cCodRet = '00003';
			return cCodRet;
		end if;
		
		if pSistemaCuenta not in ('01', '03', '06') then
			let cCodRet = '00077';
			return cCodRet;
		end if;
		
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet;
		end if;
		
		delete from sw_ro_filtros_movtos where id_resulcte = pIdCliente and id_busqueda = pIdBusqueda and id_oficio = pIdOficio;
		
		let pfechaInicio1 = EXTEND(MDY(SUBSTR(pfechaInicio,6,2),SUBSTR(pfechaInicio,9,2),SUBSTR(pfechaInicio,1,4)), YEAR TO SECOND);
		let pfechaFin1 =  EXTEND(MDY(SUBSTR(pfechaFin,6,2),SUBSTR(pfechaFin,9,2),SUBSTR(pfechaFin,1,4)), YEAR TO SECOND);
		
		insert into sw_ro_filtros_movtos(id_resulcte, id_busqueda, id_oficio, numcte, cuenta, tipo_cuenta, 
					fecha_inicio, fecha_fin, sucursal, empleado, monto, user_insert, ip_insert, mac_insert)
		values(pIdCliente, pIdBusqueda, pIdOficio, pNumCliente, pNumCuenta, pSistemaCuenta, pfechaInicio1, pfechaFin1, pSucursal, pEmpleadoConsulta, 
				pMonto, pUsuario, pIp, pMac);
		
		return cCodRet;
		
	end;
	
end procedure;