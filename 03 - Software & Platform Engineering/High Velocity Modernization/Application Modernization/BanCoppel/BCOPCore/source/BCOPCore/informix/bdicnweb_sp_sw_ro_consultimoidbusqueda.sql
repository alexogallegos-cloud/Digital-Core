create procedure "informix".sp_sw_ro_consultimoidbusqueda(pTipoBusqueda smallint, pIdOficio int, pApPaterno char(26), pApMaterno char(26), pNombre1 char(26), pNombre2 char(26), 
											pRazonSocial char(60), pRfc char(13), pNumcte char(20), pCuenta char(20), pNumTarjeta char(20), 
											pUsuario char(8), pIp char(15), pMac char(12))
	returning int as id_busqueda

	define iIdBusqueda int;
	define iSqlErr int;
	
	let iIdBusqueda = 0;
	let iSqlErr = 0;
	
	begin
		on exception set iSqlErr
			if iSqlErr <> 0 then
				return iSqlErr;
			end if;
		end exception;
	
		select max(id_busqueda)
		into iIdBusqueda
		from sw_ro_buscaper
		where id_tipobusqueda = pTipoBusqueda
			and id_oficio = pIdOficio
			and apell_paterno = pApPaterno
			and apell_materno = pApMaterno
			and nombre1 = pNombre1
			and nombre2 = pNombre2
			and razon_social = pRazonSocial
			and rfc = pRfc
			and numcte = pNumcte
			and cuenta = pCuenta
			and num_tarjeta = pNumTarjeta
			and user_insert = pUsuario
			and ip_insert = pIp
			and mac_insert = pMac
			and to_char(fecha_insert, '%Y-%m-%d') = to_char(current, '%Y-%m-%d');
			
		return iIdBusqueda;
	end;
end procedure;