create procedure "informix".sp_sw_ro_eliminaparamsedocta(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, 
			pNumCliente char(20), pNumCuenta char(20), pTipoCuenta char(2))
	returning char(5) as codret,
			smallint as registros_eliminados
	
	define iSqlErr int;
	define cCodRet char(5);
	define iNoRegsProcesados smallint;
	define iRegs int;
	
	let iSqlErr = 0;
	let cCodRet = '00000';
	let iNoRegsProcesados = 0;
	let iRegs = 0;
	
	begin
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iNoRegsProcesados;
			end if;
		end exception;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		
		if cCodRet <> '00000' then
			return cCodRet, iNoRegsProcesados;
		end if;
	
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or
			pNumCliente = '' or pNumCuenta = '' or pTipoCuenta = '' then
			let cCodRet = '00003';
			return cCodRet, iNoRegsProcesados;
		end if;
		
		if pTipoCuenta not in('01', '03', '06') then
			let cCodRet = '00048';
			return cCodRet, iNoRegsProcesados;
		end if;
		
		delete from sw_ro_edocta
		where id_busqueda = pIdBusqueda
				and id_oficio = pIdOficio
				and id_resulcte = pIdCliente
				and numcte = pNumCliente
				and cuenta = pNumCuenta
				and tipo_cuenta = pTipoCuenta
				and user_insert = pUsuario;
				
		update sw_ro_ctecta
		set certifica_edocuenta = '0'
		where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente and cuenta = pNumCuenta;
		
		select count(certifica_edocuenta)
		into iRegs
		from sw_ro_ctecta
		where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente and certifica_edocuenta = '1';
		
		if iRegs > 0 then
			let iRegs = 1;
		end if;
		
		update sw_ro_resulcte
		set certifica_edocuenta = iRegs
		where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente;
		
		select count(certifica_edocuenta)
		into iRegs
		from sw_ro_resulcte
		where id_oficio = pIdOficio and certifica_edocuenta = '1';
		
		if iRegs > 0 then
			let iRegs = 1;
		end if;
		
		update sw_ro_maeoficios
		set certifica_edocuenta = iRegs
		where id_oficio = pIdOficio;
		
			
		let iNoRegsProcesados = dbinfo('sqlca.sqlerrd2');
		
		return cCodRet, iNoRegsProcesados;
	end;
end procedure;