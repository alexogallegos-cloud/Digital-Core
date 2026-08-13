create procedure "informix".sp_sw_ro_consparamsedocta(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, 
			pNumCliente char(20), pNumCuenta char(20), pTipoCuenta char(2), pIp char(15), pMacAddress char(12))
	returning char(5) as codret,
			char(10) as fecha_inicio,
			char(10) as fecha_fin,
			char(4) as producto
	
	define iSqlErr int;
	define cCodRet char(5);
	define dFechaInicio char(10);
	define dFechaFin char(10);
	define cProducto char(4);
	
	let iSqlErr = 0;
	let cCodRet = '00000';
	let dFechaInicio = null;
	let dFechaFin = null;
	let cProducto = '';
	
	begin
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, dFechaInicio, dFechaFin, cProducto;
			end if;
		end exception;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		
		if cCodRet <> '00000' then
			return cCodRet, dFechaInicio, dFechaFin, cProducto;
		end if;
	
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or
			pNumCliente = '' or pNumCuenta = '' or pTipoCuenta = '' then -- or pIp = '' or pMacAddress = ''
			
			let cCodRet = '00003';
			return cCodRet, dFechaInicio, dFechaFin, cProducto;
		end if;
		
		if pTipoCuenta not in('01', '03', '06') then
			let cCodRet = '00048';
			return cCodRet, dFechaInicio, dFechaFin, cProducto;
		end if;
		
		select a.fecha_inicio, a.fecha_fin, b.producto
		into dFechaInicio, dFechaFin, cProducto 
		from sw_ro_edocta a left join sw_ro_ctecta b 
			on (b.id_busqueda = a.id_busqueda and b.id_resulcte = a.id_resulcte and b.id_oficio = a.id_oficio and b.cuenta = a.cuenta)
		where a.id_busqueda = pIdBusqueda
				and a.id_oficio = pIdOficio
				and a.id_resulcte = pIdCliente
				and a.numcte = pNumCliente
				and a.cuenta = pNumCuenta
				and a.tipo_cuenta = pTipoCuenta
				and a.user_insert = pUsuario;
				
		
		return cCodRet, dFechaInicio, dFechaFin, cProducto;
	end;
end procedure;