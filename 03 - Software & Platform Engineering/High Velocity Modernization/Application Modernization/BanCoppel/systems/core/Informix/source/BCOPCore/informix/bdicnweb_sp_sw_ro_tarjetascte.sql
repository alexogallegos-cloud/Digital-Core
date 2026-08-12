create procedure "informix".sp_sw_ro_tarjetascte(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, pNumCliente char(20), pRegistros int, pRecuperacion int)
	returning char(5) as codret
	
	define cCodRet char(5);
	define cCodRetSp char(5);
	define cChequera char(1);
	define cCveProducto char(4);
	define cProducto char(40);
	define cNumCuenta char(20);
	define cNumTarjeta char(20);
	define cStatusTarjeta char(15);
	define dFecExpira date;
	define cTipoTarjeta char(15);
	define cSistemaCuenta char(2);
	
	let cCodRet = '00000';
	
	begin
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or pRegistros = '' or 
			pNumcliente = '' or pRecuperacion = '' then
			let cCodRet = '00003';
			return cCodRet;
		end if; 
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet;
		end if;
		
		foreach 
				execute procedure bdinteg:sp_cnsif_cons_tarjetas_cte(pUsuario, pIdFuncion, pNumCliente, pRegistros, pRecuperacion)
				into cCodRetSp, cChequera, cCveProducto, cProducto, cNumCuenta, cNumTarjeta, cStatusTarjeta, dFecExpira, cTipoTarjeta, cSistemaCuenta
			
			if cCodRetSp = '00000' then
				insert into v_sw_ro_tarjetasclientes(id_oficio, id_busqueda, id_resulcte, tipo_cuenta, cuenta, num_tarjeta, status_tarjeta)
				values(pIdOficio, pIdBusqueda, pIdCliente, cSistemaCuenta, cNumCuenta, cNumTarjeta, cStatusTarjeta);
			end if;
			
		end foreach;
		
		return cCodRet;
		
	end;
	

end procedure;