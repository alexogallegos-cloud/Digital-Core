create procedure "informix".sp_sw_ro_bitacoraresultadoshom(pUsuario char(8), pIdBusqueda int, pIdOficio int, 
		pApPaterno char(26), pApMaterno char(26), pNombre1 char(26), pNombre2 char(26), 
		pRazonSocial char(60), pRfc char(13), 
		pNumCliente char(20), pNumCuenta char(20), pNumTarjeta char(20), pTipoCuenta char(2),
		pTipoCliente char(1),  pStatusBus int,
		pIp char(15), pMac char(12))
	returning char(5) as codret,
			int as idgenerado
	
	define iSqlErr int;
	define cCodRet char(5);
	define iRows int;
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	let iRows = 0;
	
	begin
		on exception set iSqlErr
			let cCodRet = iSqlErr;
			return cCodRet, iRows;
		end exception;
	
		insert into sw_ro_resulper_homonimos(id_busqueda, id_oficio, apell_paterno, apell_materno, nombre1, nombre2,
			razon_social, rfc, numcte, tipo_cliente, cuenta, num_tarjeta, status_busqueda, user_insert, fecha_insert, ip_insert, mac_insert, tipo_cuenta)
		values(pIdBusqueda, pIdOficio, pApPaterno, pApMaterno, pNombre1, pNombre2, pRazonSocial, pRfc, pNumCliente, pTipoCliente, pNumCuenta, pNumTarjeta, pStatusBus,
			pUsuario, current, pIp, pMac, pTipoCuenta);
		
		let iRows = dbinfo('sqlca.sqlerrd1');
		return cCodRet, iRows;
		
	end;
end procedure;