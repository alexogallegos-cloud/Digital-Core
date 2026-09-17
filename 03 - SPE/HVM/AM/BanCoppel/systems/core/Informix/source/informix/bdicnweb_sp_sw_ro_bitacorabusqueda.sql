create procedure "informix".sp_sw_ro_bitacorabusqueda(pTipoBusqueda smallint, pIdOficio int, pApPaterno char(26), pApMaterno char(26), pNombre1 char(26), pNombre2 char(26), 
											pRazonSocial char(60), pRfc char(13), pNumcte char(20), pCuenta char(20), pNumTarjeta char(20), 
											pUsuario char(8), pIp char(15), pMac char(12))
	returning char(5) as codret,
			int as reg_insertados
	
	define cCodRet char(5);
	define iSqlErr int;
	define iRegsAfectados int;
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	let iRegsAfectados = 0;
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iRegsAfectados;
			end if;
		end exception;
		
		insert into sw_ro_buscaper(id_tipobusqueda, id_oficio, apell_paterno, apell_materno, nombre1, nombre2,
									razon_social, rfc, numcte, cuenta, num_tarjeta, user_insert, fecha_insert, ip_insert, mac_insert)
		values(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, pNombre1, pNombre2, pRazonSocial, pRfc, pNumcte, pCuenta, pNumTarjeta, pUsuario, current, pIp, pMac);
		
		return cCodRet, dbinfo('sqlca.sqlerrd1');
	end;
	
end procedure;