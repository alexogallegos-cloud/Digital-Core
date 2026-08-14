create procedure "informix".sp_sw_ro_bitacoracteenc(
		pUsuario char(8), pIdBusqueda int, pIdOficio int, pIdResulPer int,
		pNumCliente char(20),
		pApPaterno char(26), pApMaterno char(26), pNombre1 char(26), pNombre2 char(26), 
		pRazonSocial char(60), pRfc char(13),
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
		
		insert into sw_ro_resulcte(id_busqueda, id_oficio, id_resulper,
									numcte, 
									apell_paterno, apell_materno, nombre1, nombre2,
									razon_social, rfc,
									user_insert, fecha_insert, ip_insert, mac_insert)
		values(pIdBusqueda, pIdOficio, pIdResulPer,
				pNumCliente,
				pApPaterno, pApMaterno, pNombre1, pNombre2, 
				pRazonSocial, pRfc,
				pUsuario, current, pIp, pMac);

		let iRows = dbinfo('sqlca.sqlerrd1');
		return cCodRet, iRows;
		
	end;
end procedure;