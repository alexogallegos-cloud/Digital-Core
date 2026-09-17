create procedure "informix".sp_sw_ro_eliminamovtos(pUsuario char(8), pFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCte int, pNumeroCuenta char(20))
	returning char(5) as codret,
		int as registros_borrados
	
	define iSqlErr int;
	define cCodRet char(5);
	define iRegBorrados int;
	define iRegs int;
	
	let iSqlErr = 0;
	let cCodRet = '00000';
	let iRegBorrados = 0;
	let iRegs = 0;
	
	begin
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iRegBorrados;
			end if;
		end exception;
	
		if pUsuario = '' or pFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCte = '' or pNumeroCuenta = '' then
			let cCodRet = '00003';
			return cCodRet, iRegBorrados;
		end if;
		
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, iRegBorrados;
		end if;
		
		delete from sw_ro_movtos where id_resulcte = pIdCte and id_busqueda = pIdBusqueda and id_oficio = pIdOficio and cuenta = pNumeroCuenta;
		let iRegBorrados = dbinfo('sqlca.sqlerrd1');
		
		-- Se actualiza en estatus en la tabla de cuentas
		update sw_ro_ctecta set detalle_movimientos = '0' 
		where id_resulcte = pIdCte and id_busqueda = pIdBusqueda and id_oficio = pIdOficio and cuenta = pNumeroCuenta;
		
		-- Se actualiza en estatus en la tabla de clientes
		update sw_ro_resulcte set detalle_movimientos = '0' 
		where id_resulcte = pIdCte and id_busqueda = pIdBusqueda and id_oficio = pIdOficio;
		
		select count(detalle_movimientos)
		into iRegs
		from sw_ro_resulcte where detalle_movimientos = '1' and id_oficio = pIdOficio;
		
		if iRegs > 0 then
			let iRegs = 1;
		end if;
		
		update sw_ro_maeoficios set detalle_movimientos = iRegs
		where id_oficio = pIdOficio;

		return cCodRet, iRegBorrados;
	end;
	
end procedure;