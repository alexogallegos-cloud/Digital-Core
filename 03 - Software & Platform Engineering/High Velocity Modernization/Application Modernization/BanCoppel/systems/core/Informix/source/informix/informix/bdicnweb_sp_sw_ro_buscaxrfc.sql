create procedure "informix".sp_sw_ro_buscaxrfc(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pRfc char(15), pIp char(15), pMac char(12))
	returning char(5)  as codret,
			  char(20) as numerocliente,
			  char(13) as rfc,
			  char(1)  as nivelcliente,
			  char(26) as nombre1,
			  char(26) as nombre2,
			  char(26) as ap_paterno,
			  char(26) as ap_materno,
			  char(60) as razon_social,
			  char(2)  as tipo_persona,
			  char(1)  as tipo_cliente,
			  int      as status_busqueda,
			  char(20) as desc_status_busqueda,
			  int      as id_encontrado
			  
	define cCodRet char(5);
	define iSqlErr int;
	define cNumCte char(20);
	define cNumCta char(20);
	define cNumTar char(20);
	
	-- Variables de retorno
	define cNumeroCliente char(20);
	define cRfc char(13);
	define cNivelCliente char(1);
	define cNombre1 char(26);
	define cNombre2 char(26);
	define cApPaterno char(26);
	define cApMaterno char(26);
	define cRazonSocial char(60);
	define iNoRegistros int;
	define cEtiqueta char(20);
	define iStatusBusqueda smallint;
	define cTipoPersona char(2);
	define cTipoCliente char(1);
	define cCodRetSp char(5);
	define iRegsProc int;
	define iIdGenerado int;
	
	define cDescTipoCliente char(40);
	define dFechaNacimiento date;
	define cSexo char(1);
	define cDescTipoPersona char(20);
	define dFechaAlta date;
	define cCveSucursalAltaCte char(4);
	define cPlazaAlta char(3);
	define cCveSitEspecial char(5);
	define cDescSitEspecial char(75);
	define iSecuencia int;
	define cCalle char(40);
	define cNoExt char(10);
	define cNoInt char(10);
	define cDepto char(6);
	define cColonia char(60);
	define cDelMun char(60);
	define cCiudad char(60);
	define cEstado char(30);
	define cPais char(20);
	define cCodPostal char(5);
	define cTelParticular char(13);
	define cTelCelular char(13);
	define cTelOficina char(13);
	define cExt char(5);
	define iNivelCliente int;
	define cDescNivelCliente char(60);
	define cTipoCuenta char(2);
	define cTipoBusquedaPersona char(1);
	define cNoCteRfcAlterno char(20);
	define cNoCteRfc char(20);
	
	let cCodRet = '00000';
	let cCodRetSp = '';
	let cNumeroCliente = '';
	let cRfc = '';
	let cNivelCliente = '';
	let cNombre1 = '';
	let cNombre2 = '';
	let cApPaterno = '';
	let cApMaterno = '';
	let cRazonSocial = '';
	let iNoRegistros = 0;
	let cEtiqueta = 'NO LOCALIZADO';
	let iStatusBusqueda = 0; -- 0. No encontrado, 1. Encontrado, 2. Homonimo
	let cTipoPersona = '';
	let cTipoCliente = '';
	let cCodRetSp = '';
	let iRegsProc = 0;
	let iIdGenerado = 0;
	let cNumCte = '';
	let cNumCta = '';
	let cNumTar = '';
	let cNoCteRfcAlterno = '';
	let cNoCteRfc = '';
	
	let cDescTipoCliente = '';
	let dFechaNacimiento = null;
	let cSexo = '';
	let cDescTipoPersona = '';
	let dFechaAlta = null;
	let cCveSucursalAltaCte = '';
	let cPlazaAlta = '';
	let cCveSitEspecial = '';
	let cDescSitEspecial = '';
	let iSecuencia = 0;
	let cCalle = '';
	let cNoExt = '';
	let cNoInt = '';
	let cDepto = '';
	let cColonia = '';
	let cDelMun = '';
	let cCiudad = '';
	let cEstado = '';
	let cPais = '';
	let cCodPostal = '';
	let cTelParticular = '';
	let cTelCelular = '';
	let cTelOficina = '';
	let cExt = '';
	let iNivelCliente = 0;
	let cDescNivelCliente = '';
	let cTipoCuenta = '';

	begin
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cNumeroCliente, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
			end if;
		end exception;
	
		-- Se busca al cliente primero por el rfc alterno
		select rfc_alterno, count(numcte)
		into cNoCteRfcAlterno, iRegsProc
		from bdinteg:si_cliente
		where rfc_alterno = pRfc
		group by rfc_alterno;
		
		if cNoCteRfcAlterno is null or cNoCteRfcAlterno = '' then
			select rfc, count(numcte)
			into cNoCteRfc, iRegsProc
			from bdinteg:si_cliente
			where rfc = pRfc
			group by rfc;
		end if
		
		if iRegsProc = 1 then
			if cNoCteRfcAlterno is not null or cNoCteRfcAlterno <> '' then
				select numcte, rfc_alterno, nombre1, nombre2, apell_paterno, apell_materno, razon_social, tpo_persona, tipo_cliente 
				into cNumeroCliente, cRfc,  cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente
				from bdinteg:si_cliente where rfc_alterno = pRfc;
			elif cNoCteRfc is not null or cNoCteRfc <> '' then
				select numcte, rfc, nombre1, nombre2, apell_paterno, apell_materno, razon_social, tpo_persona, tipo_cliente 
				into cNumeroCliente, cRfc,  cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente
				from bdinteg:si_cliente where rfc = pRfc;
			end if;
			
			let iNivelCliente = 9; -- Falta buscar el nivel del cliente
			let iStatusBusqueda = 1;
			let cNivelCliente = iNivelCliente;
			let cEtiqueta = 'LOCALIZADO';
			
			-- Se almacena la busqueda
			execute procedure sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, 
						cApPaterno, cApMaterno, cNombre1, cNombre2, 
						cRazonSocial, cRfc, 
						cNumeroCliente, cNumCta, cNumTar, cTipoCuenta,
						cTipoCliente, iStatusBusqueda, pIp, pMac)
			into cCodRetSp, iIdGenerado;
				
			if cCodRetSp <> '00000' then
				return cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
			end if;
			
			
			-- Se almacena al cliente encontrado
			execute procedure sp_sw_ro_bitacoracteenc(pUsuario, pIdBusqueda, pIdOficio, iIdGenerado, cNumeroCliente, 
								cApPaterno, cApMaterno, cNombre1, cNombre2, 
								cRazonSocial, cRfc, pIp, pMac)
			into cCodRetSp, iRegsProc;
			
			if cCodRetSp <> '00000' then
				return cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
			end if;
			
			-- Se buscan las cuentas y participaciones del cliente
			if cTipoCliente = '1' then
				execute procedure sp_sw_ro_consctascteparticipacion(pUsuario, pIdFuncion, pIdOficio, pIdBusqueda, iRegsProc, cNumeroCliente, 
							50, pIp, pMac) into cCodRetSp;
				if cCodRetSp <> '00000' then
					return cCodRetSp, 'En 1 part', cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, iRegsProc;
				end if;
			elif cTipoCliente = '2' then
				execute procedure sp_sw_ro_buscaparticipacion(pUsuario, pIdOficio, pIdBusqueda, iRegsProc, cNumeroCliente, pIp, pMac) into cCodRetSp;
				if cCodRetSp <> '00000' then
					return cCodRetSp, 'en 2 part', cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, iRegsProc;
				end if;
			end if;
			
			return cCodRet, cNumeroCliente, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, iRegsProc with resume;
		elif iRegsProc = 0 then
			execute procedure sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, 
							cApPaterno, cApMaterno, cNombre1, cNombre2, 
							cRazonSocial, cRfc, 
							cNumCte, cNumCta, cNumTar, cTipoCuenta,
							cTipoCliente, iStatusBusqueda, pIp, pMac)
			into cCodRetSp, iRegsProc;
			
			if cCodRetSp <> '00000' then
				return cCodRetSp, cNumCte, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
			end if;
			
			let cCodRet = '00000';
			let cNivelCliente = '9';
			return cCodRet, cNumCte, pRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
		elif iRegsProc > 1 then
			let iNivelCliente = 9; -- Falta buscar el nivel del cliente
			let iStatusBusqueda = 2;
			let cNivelCliente = iNivelCliente;
			let cEtiqueta = 'HOMONIMO';
		
			if cNoCteRfcAlterno is not null or cNoCteRfcAlterno <> '' then
				foreach select numcte, rfc_alterno, nombre1, nombre2, apell_paterno, apell_materno, razon_social, tpo_persona, tipo_cliente 
					into cNumeroCliente, cRfc,  cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente
					from bdinteg:si_cliente where rfc_alterno = pRfc
					
					execute procedure sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, 
							cApPaterno, cApMaterno, cNombre1, cNombre2, 
							cRazonSocial, cRfc, 
							cNumeroCliente, cNumCta, cNumTar, cTipoCuenta,
							cTipoCliente, iStatusBusqueda, pIp, pMac)
					into cCodRetSp, iRegsProc;
					
					if cCodRetSp <> '00000' then
						return cCodRetSp, cNumCte, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
					end if;
					
					return cCodRet, cNumeroCliente, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, iRegsProc with resume;
					
				end foreach;
			elif cNoCteRfc is not null or cNoCteRfc <> '' then
				foreach select numcte, rfc, nombre1, nombre2, apell_paterno, apell_materno, razon_social, tpo_persona, tipo_cliente 
					into cNumeroCliente, cRfc,  cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente
					from bdinteg:si_cliente where rfc = pRfc
					
					execute procedure sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, 
							cApPaterno, cApMaterno, cNombre1, cNombre2, 
							cRazonSocial, cRfc, 
							cNumeroCliente, cNumCta, cNumTar, cTipoCuenta,
							cTipoCliente, iStatusBusqueda, pIp, pMac)
					into cCodRetSp, iRegsProc;
					
					if cCodRetSp <> '00000' then
						return cCodRetSp, cNumCte, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
					end if;
					
					return cCodRet, cNumeroCliente, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, iRegsProc with resume;
					
				end foreach;
			end if;
		end if;
	end;
end procedure;