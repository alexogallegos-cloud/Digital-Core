create procedure "informix".sp_sw_ro_guardabloqueoctas(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, pTipoBloqueo char(1),
											pNumCliente char(20), pTipoCuenta char(2), pNumCuenta char(20), pMontoBloqueo money(14,2), pIdCausaBloqueo char(3),
											pCausaBloqueo char(40), pFolioOperacion char(16), pIp char(15), pMac char(12))
	returning char(5) as codret,
		smallint as reg_insertados
	
	define cCodRet char(5);
	define iSqlErr int;
	define iRegGuardados smallint;
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	let iRegGuardados = 0;
	
	begin
		
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iRegGuardados;
			end if;
		end exception;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or pTipoBloqueo = '' or
			pNumCliente = '' or pTipoCuenta = '' or pNumCuenta = '' or pIdCausaBloqueo = '' or
			pCausaBloqueo = '' or pFolioOperacion = '' or pIp = '' or pMac = '' then
			
			let cCodRet = '00003';
			return cCodRet, iRegGuardados;
			
		end if;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		
		if cCodRet <> '00000' then
			return cCodRet, iRegGuardados;
		end if;
		
		if pTipoCuenta = '01' then
			if pMontoBloqueo = '' then
				let cCodRet = '00003';
				return cCodRet, iRegGuardados;
			end if;
		elif pTipoCuenta = '06' then
			let pMontoBloqueo = 0;
		end if;
		
		insert into sw_ro_bloqueos(id_oficio, id_busqueda, id_resulcte, numcliente, cuenta, tipo_bloqueo, monto_bloqueo, id_causa_bloqueo, causa_bloqueo,
									tipo_cuenta, folio_operacion, user_insert, ip_insert, mac_insert, fecha_insert)
		values(pIdOficio, pIdBusqueda, pIdCliente, pNumCliente, pNumCuenta, pTipoBloqueo, pMontoBloqueo, pIdCausaBloqueo, pCausaBloqueo, pTipoCuenta, pFolioOperacion, pUsuario, pIp, pMac, current);
		
		let iRegGuardados = dbinfo('sqlca.sqlerrd2');
		
		update sw_ro_ctecta
		set ind_cuenta_ya_bloqueada = '1',
			ind_bloqueo_cta_por_sistema = '1',
			motivo_bloqueo = pCausaBloqueo,
			fecha_bloqueo = current
		where id_oficio = pIdOficio
			and id_busqueda = pIdBusqueda
			and id_resulcte = pIdCliente
			and numcte = pNumCliente
			and cuenta = pNumCuenta;
			
		-- Se actualiza en la tabla de clientes encontrados (resulcte)
		update sw_ro_resulcte
		set bloqueo_cuentas = '1'
		where id_oficio = pIdOficio
			and id_busqueda = pIdBusqueda
			and id_resulcte = pIdCliente
			and numcte = pNumCliente;
			
		let iRegGuardados = dbinfo('sqlca.sqlerrd2');
		return cCodRet, iRegGuardados;
		
	end;
	
end procedure;